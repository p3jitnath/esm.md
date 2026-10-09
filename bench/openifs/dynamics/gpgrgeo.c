/* Check horizontal geopotential derivatives in their model coordinate units.
 * Analytic height profiles provide independent physical expectations.
 * Protected arrays test mutation, boundaries and scalar final columns. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#define GRGEO_ARGS const void *geometry,const int32_t *np,const int32_t *ks, \
 const int32_t *ke,const int32_t *nl,const double *h,const double *gl, \
 const double *gm,const double *depth,const double *alpha,const double *xy, \
 const double *ol,const double *om,double *fl,double *fm,double *hl,double *hm, \
 const int32_t *nh,const double *ratio,const double *ql,const double *qm, \
 double *nlout,double *nmout
void gpgrgeo_(GRGEO_ARGS);
void gpgrgeo_assembly_(GRGEO_ARGS);
typedef struct {void *map;size_t bytes,usable,count;double *data;int tail;} buffer;
enum {H,GL,GM,DEPTH,ALPHA,XY,OL,OM,RATIO,QL,QM,INPUTS};
static const double guard=-777.75;
static int32_t *fieldmap;
static uint64_t calls,total_bytes,mode_calls[2],flag_calls[3],presence_calls[4];
static void fail(const char *message) {
    fprintf(stderr,"GPGRGEO check failed %s\n",message);exit(2);
}
static uint64_t bits(double x) {uint64_t n;memcpy(&n,&x,8);return n;}
static uint64_t fpcr(void) {uint64_t n;__asm__ volatile("mrs %0,fpcr":"=r"(n));return n;}
static buffer make_buffer(size_t count,int tail) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE),entries=count+2-(size_t)tail;
    size_t usable=(entries*8+page-1)/page*page;
    void *map=mmap(NULL,usable+2*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(map==MAP_FAILED || mprotect((char *)map+page,usable,PROT_READ|PROT_WRITE))
        fail("buffer pages");
    double *data=(double *)((char *)map+page+usable-entries*8)+1;
    for(size_t k=0;k<entries;++k) data[(ptrdiff_t)k-1]=guard;
    return (buffer){map,usable+2*page,usable,count,data,tail};
}
static void readonly(buffer *b) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    if(mprotect((char *)b->map+page,b->usable,PROT_READ)) fail("read-only input");
}
static void release(buffer *b) {if(munmap(b->map,b->bytes)) fail("release");}
static void integer(void *object,size_t off,int32_t n) {memcpy((char *)object+off,&n,4);}
static void pointer(void *object,size_t off,const void *p) {memcpy((char *)object+off,&p,8);}
static void rank1(void *object,size_t off,buffer *b,int64_t lower,int64_t upper) {
    uint64_t words[8]={(uintptr_t)b->data,(uint64_t)(-lower),8,
        UINT64_C(0x0000030100000000),8,1,(uint64_t)lower,(uint64_t)upper};
    memcpy((char *)object+off,words,sizeof words);
}
static void rank2(void *object,size_t off,buffer *b,int64_t rows,int64_t columns,
                  int64_t lower1,int64_t lower2) {
    uint64_t words[11]={(uintptr_t)b->data,(uint64_t)(-lower1-lower2*rows),8,
        UINT64_C(0x0000030200000000),8,1,(uint64_t)lower1,
        (uint64_t)(lower1+rows-1),(uint64_t)rows,(uint64_t)lower2,
        (uint64_t)(lower2+columns-1)};
    memcpy((char *)object+off,words,sizeof words);
}
static void physics(double actual,long double expected,const char *what) {
    long double tolerance=1.0e-11L+1.0e-12L*fabsl(expected);
    if(!isfinite(actual) || fabsl((long double)actual-expected)>tolerance) {
        fprintf(stderr,"physical quantity %s actual=%.17g expected=%.21Lg\n",what,actual,expected);
        fail(what);
    }
}
static long double corrected_height(long double x) {
    long double h=65536.0L+4.0L*x,w=7.0L*logl(2.0L)+(7.0L/4096.0L)*x;
    return 32.0L*x+0.75L*h*w*expl(-x/65536.0L);
}
static void independent_difference(void) {
    long double step=0x1p-4L,w=7.0L*logl(2.0L),dw=7.0L/4096.0L;
    long double expected=32.0L+0.75L*(4.0L*w+65536.0L*dw-w);
    long double actual=(corrected_height(step)-corrected_height(-step))/(2.0L*step);
    if(fabsl(actual-expected)>2.0e-9L+1.0e-12L*fabsl(expected))
        fail("independent symmetric derivative of corrected height");
}
static void compare(int number,int mode,const char *field,buffer *a,buffer *r,
                    int32_t np,int32_t ks,int32_t ke,int32_t nl,int half,
                    int present,const double *incoming,FILE *af,FILE *rf) {
    size_t entries=a->count+2-(size_t)a->tail;
    for(size_t k=0;k<entries;++k) {
        double av=a->data[(ptrdiff_t)k-1],rv=r->data[(ptrdiff_t)k-1];
        size_t cell=k?k-1:0;
        if(bits(av)!=bits(rv)) {
            fprintf(stderr,"Mismatch stage=GPGRGEO case=%d mode=%d field=%s level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                number,mode,field,cell/(size_t)np+(half?0:1),cell%(size_t)np+1,bits(av),bits(rv));
            exit(1);
        }
        int active=present && k>0 && k<=a->count &&
            (half || nl>0) && (int32_t)(cell%(size_t)np)+1>=ks &&
            (int32_t)(cell%(size_t)np)+1<=ke;
        double before=k>0 && k<=a->count?incoming[cell]:guard;
        if(!active && bits(av)!=bits(before)) fail("inactive cell or guard changed");
        if(active && !isfinite(av)) fail("nonfinite active output");
    }
    if(present) {
        if(fwrite(a->data-1,8,entries,af)!=entries ||
           fwrite(r->data-1,8,entries,rf)!=entries) fail("canonical output write");
        total_bytes+=(uint64_t)entries*8;
    }
}
static long double sum_indices(int32_t begin,int32_t end) {
    return end>begin?((long double)begin+end-1)*(end-begin)*0.5L:0.0L;
}
static void check_case(int number,int mode,int ibc,int32_t np,int32_t ks,
                       int32_t ke,int32_t nl,int pattern,int flag,int presence,
                       int tail,int alternate,int64_t lower,FILE *af,FILE *rf) {
    int32_t ndim=(alternate==1 || alternate==3)?9:6,nh=flag>0;
    int32_t capacity=alternate==3?6:ndim;
    int32_t indices[4]={1,2,3,4};
    if(alternate==1) {indices[0]=9;indices[1]=2;indices[2]=6;indices[3]=1;}
    if(alternate==2) {indices[2]=1;indices[3]=2;}
    if(mode) {indices[2]=-999;indices[3]=999;}
    int32_t oldmap[10],mapcopy[10];
    memcpy(oldmap,fieldmap,sizeof oldmap);
    for(int k=0;k<10;++k) fieldmap[k]=1;
    memcpy(fieldmap,indices,sizeof indices);fieldmap[9]=ndim;
    memcpy(mapcopy,fieldmap,sizeof mapcopy);
    size_t count=(size_t)np*(size_t)nl,half=(size_t)np*((size_t)nl+1);
    buffer g=make_buffer(2137,0),cv=make_buffer(27,0),vt=make_buffer(40,0),
        vf=make_buffer(272,0),input[INPUTS],out[6],ref[6],coord={0},matrix={0};
    memset(g.data,0,17096);memset(cv.data,0,216);
    memset(vt.data,0,320);memset(vf.data,0,2176);
    pointer(g.data,3248,vt.data);pointer(g.data,3256,vf.data);pointer(g.data,3264,cv.data);
    integer(cv.data,52,mode);integer(cv.data,36,ibc);
    for(int f=0;f<INPUTS;++f) {
        size_t n=f==XY?count*(size_t)capacity:(f==OL || f==OM)?(size_t)np:count;
        input[f]=make_buffer(n,tail);
    }
    for(int f=0;f<6;++f) {
        out[f]=make_buffer(f<2?half:count,tail);
        ref[f]=make_buffer(f<2?half:count,tail);
    }
    double *incoming[6];
    for(int f=0;f<6;++f) {
        incoming[f]=malloc((out[f].count?out[f].count:1)*8);
        if(!incoming[f]) fail("incoming allocation");
    }
    for(size_t k=0;k<input[XY].count;++k) input[XY].data[k]=-13.25;
    for(int32_t j=0;j<nl;++j) for(int32_t i=0;i<np;++i) {
        size_t k=(size_t)j*(size_t)np+(size_t)i;
        double h=65536.0,gl=4.0,gm=-8.0,d=log(2.0),a=0.5*log(2.0),
            dl=0x1p-12,dm=-0x1p-11,al=0x1p-13,am=-0x1p-12,
            c=0.75,ql=0x1p-16,qm=-0x1p-15;
        if(pattern==1) {
            h=32768.0+1024.0*j;gl=8.0+j;gm=-2.0*gl;
            d=0.125;a=0.0625;dl=0x1p-10;dm=-0x1p-9;al=0x1p-11;am=-0x1p-10;
            c=0.5;ql=0.0;qm=0.0;
        }
        if(pattern==2) {c=1.0;ql=0.0;qm=0.0;}
        if(pattern==3) {gl=gm=dl=dm=al=am=ql=qm=0.0;}
        if(pattern==4) {
            h=i%2?-0.0:0.0;gl=j%2?-0.0:0.0;gm=-gl;d=j%2?0.0:-0.0;
            a=-d;dl=i%2?0.0:-0.0;dm=-dl;al=-dl;am=dl;
            c=i%2?-0.0:0.0;ql=dl;qm=dm;
        }
        if(pattern==5) {
            h=1.0;gl=i%2?-0x0.0000000000001p-1022:0x0.0000000000001p-1022;
            gm=-gl;d=1.0;a=0.5;dl=gl;dm=gm;al=gl;am=gm;c=1.0;ql=gl;qm=gm;
        }
        if(pattern==6) {
            h=1.0;gl=0x1p54;gm=-0x1p54;d=a=1.0;
            dl=al=1.0;dm=am=-1.0;c=1.0;ql=qm=0.0;
        }
        if(pattern==7) {
            h=i%2?0x1p500:0x1p-500;gl=i%2?0x1p-500:0x1p500;gm=-gl;
            d=0x1p-500;a=0x1p500;dl=0x1p-500;dm=-dl;al=0x1p-500;am=-al;
            c=0x1p-10;ql=0x1p-500;qm=-ql;
        }
        if(mode) {
            d=nl?1.0/(double)nl:0.0;a=0.0;dl=dm=al=am=0.0;
            h=65536.0;gl=4.0;gm=-8.0;c=0.75;ql=0x1p-16;qm=-0x1p-15;
            if(pattern==4) {h=i%2?-0.0:0.0;gl=0.0;gm=-0.0;ql=0.0;qm=-0.0;}
            if(pattern==5) {h=1.0;gl=0x0.0000000000001p-1022;gm=-gl;ql=qm=0.0;}
        }
        const double values[INPUTS]={h,gl,gm,d,a,0.0,0.0,0.0,c,ql,qm};
        for(int f=0;f<INPUTS;++f) if(f!=XY && f!=OL && f!=OM) input[f].data[k]=values[f];
        input[XY].data[(size_t)(indices[0]-1)*count+k]=dl;
        input[XY].data[(size_t)(indices[1]-1)*count+k]=dm;
        if(!mode) {
            input[XY].data[(size_t)(indices[2]-1)*count+k]=al;
            input[XY].data[(size_t)(indices[3]-1)*count+k]=am;
        }
    }
    for(int32_t i=0;i<np;++i) {
        double ol=32.0+i,om=-64.0+2.0*i;
        if(pattern==4 || pattern==5) {ol=i%2?-0.0:0.0;om=-ol;}
        if(pattern==6) {ol=-0x1p54;om=0x1p54;}
        if(pattern==7) {ol=i%2?0x1p500:0.0;om=-ol;}
        input[OL].data[i]=ol;input[OM].data[i]=om;
    }
    if(mode) {
        size_t nc=nl>0?(size_t)((int64_t)nl-lower+1):1;
        coord=make_buffer(nc,tail);
        for(size_t k=0;k<nc;++k) coord.data[k]=(double)(nl?nl:1);
        rank1(vt.data,256,&coord,lower,lower+(int64_t)nc-1);
        int64_t rows=(int64_t)nl+1,cols=(int64_t)nl+((ibc==1 || ibc==3)?2:0);
        matrix=make_buffer((size_t)rows*(size_t)cols,tail);
        for(int64_t column=0;column<cols;++column)
            for(int64_t row=0;row<rows;++row) {
                int64_t j=column-((ibc==1 || ibc==3)?1:0);
                double w=0.0;
                if(j>=0 && j<nl && nl>0) {
                    if(row==nl || j<row) w=1.0/(double)nl;
                    else if(j==row) w=0.5/(double)nl;
                }
                matrix.data[(size_t)column*(size_t)rows+(size_t)row]=w;
            }
        rank2(vf.data,ibc==0?64:ibc==2?1296:240,&matrix,rows,cols,lower,lower-1);
        readonly(&coord);readonly(&matrix);
    }
    for(int f=0;f<6;++f) {
        if(out[f].count) {
            memcpy(ref[f].data,out[f].data,out[f].count*8);
            memcpy(incoming[f],out[f].data,out[f].count*8);
        }
    }
    for(int f=0;f<INPUTS;++f) readonly(&input[f]);
    readonly(&g);readonly(&cv);readonly(&vt);readonly(&vf);
    int active=nl>0 && ke>=ks,surface=ke>=ks;
    const int32_t *flagptr=flag<0?NULL:&nh;
    const double *hp=active?input[H].data:NULL,*glp=active?input[GL].data:NULL;
    const double *gmp=active?input[GM].data:NULL,*dp=active?input[DEPTH].data:NULL;
    const double *ap=active && !mode?input[ALPHA].data:NULL,*xp=active?input[XY].data:NULL;
    const double *op=surface?input[OL].data:NULL,*mp=surface?input[OM].data:NULL;
    const double *cp=nh?input[RATIO].data:NULL,*qp=nh?input[QL].data:NULL,*rp=nh?input[QM].data:NULL;
    uint64_t control=fpcr();
    gpgrgeo_(g.data,&np,&ks,&ke,&nl,hp,glp,gmp,dp,ap,xp,op,mp,
        active?ref[2].data:NULL,active?ref[3].data:NULL,
        surface?ref[0].data:NULL,surface?ref[1].data:NULL,
        flagptr,cp,qp,rp,presence&1?ref[4].data:NULL,presence&2?ref[5].data:NULL);
    gpgrgeo_assembly_(g.data,&np,&ks,&ke,&nl,hp,glp,gmp,dp,ap,xp,op,mp,
        active?out[2].data:NULL,active?out[3].data:NULL,
        surface?out[0].data:NULL,surface?out[1].data:NULL,
        flagptr,cp,qp,rp,presence&1?out[4].data:NULL,presence&2?out[5].data:NULL);
    if(fpcr()!=control) fail("changed FPCR");
    if(memcmp(fieldmap,mapcopy,sizeof mapcopy)) fail("changed field map");
    ++calls;++mode_calls[mode];++flag_calls[flag+1];++presence_calls[presence];
    const char *names[6]={"PHIHL","PHIHM","PHIFL","PHIFM","PNH1L","PNH1M"};
    for(int f=0;f<6;++f)
        compare(number,mode,names[f],&out[f],&ref[f],np,ks,ke,nl,f<2,
            f<4 || (f==4?(presence&1):(presence&2)),incoming[f],af,rf);

    if(surface) for(int32_t i=ks-1;i<ke;++i) {
        size_t k=(size_t)nl*(size_t)np+(size_t)i;
        if(bits(out[0].data[k])!=bits(input[OL].data[i]) ||
           bits(out[1].data[k])!=bits(input[OM].data[i])) fail("surface anchor");
    }
    if(active && pattern<=3) for(int direction=0;direction<2;++direction)
        for(int32_t i=ks-1;i<ke;++i) for(int32_t level=0;level<nl;++level) {
            long double s=input[direction?OM:OL].data[i],m=nl-level;
            long double expected_h,expected_f;
            if(mode) {
                long double thermal=direction?-8.0L:4.0L;
                if(nh) thermal=0.75L*(direction?-6.0L:3.0L);
                expected_h=s+thermal*m/nl;
                expected_f=s+thermal*(m-0.5L)/nl;
            } else if(pattern==1) {
                long double sumj=sum_indices(level,nl),below=m-1;
                long double hsum=32768.0L*m+1024.0L*sumj;
                long double gsum=8.0L*m+sumj;
                long double hj=32768.0L+1024.0L*level,gj=8.0L+level;
                long double hbelow=32768.0L*below+1024.0L*sum_indices(level+1,nl);
                long double gbelow=8.0L*below+sum_indices(level+1,nl);
                long double sign=direction?-2.0L:1.0L,c=nh?0.5L:1.0L;
                expected_h=s+c*sign*(0.125L*gsum+hsum/1024.0L);
                expected_f=s+c*sign*(0.125L*gbelow+hbelow/1024.0L+
                    0.0625L*gj+hj/2048.0L);
            } else if(pattern==3) expected_h=expected_f=s;
            else {
                long double g0=direction?-8.0L:4.0L,d0=direction?-0x1p-11L:0x1p-12L;
                long double q0=direction?-0x1p-15L:0x1p-16L,c=nh?0.75L:1.0L;
                if(pattern==2) {q0=0.0L;c=1.0L;}
                if(!nh) q0=0.0L;
                long double factor=g0-65536.0L*q0;
                expected_h=s+c*(factor*m*logl(2.0L)+65536.0L*m*d0);
                expected_f=s+c*(factor*(m-0.5L)*logl(2.0L)+65536.0L*(m-0.5L)*d0);
            }
            size_t k=(size_t)level*(size_t)np+(size_t)i;
            physics(out[direction].data[k],expected_h,"independent boundary derivative");
            physics(out[direction+2].data[k],expected_f,"independent full derivative");
            if(presence&(1<<direction)) {
                long double expected_n=nh?-(long double)input[H].data[k]*
                    (long double)input[direction?QM:QL].data[k]:0.0L;
                physics(out[direction+4].data[k],expected_n,"independent pressure correction");
            }
        }
    if(active && pattern==6 && nl==1) {
        for(int32_t i=ks-1;i<ke;++i) {
            if(bits(out[0].data[i])!=bits(1.0) || bits(out[1].data[i])!=bits(-1.0) ||
               bits(out[2].data[i])!=bits(1.0) || bits(out[3].data[i])!=bits(-1.0))
                fail("two separately rounded additions");
        }
    }
    if(active && !nh) for(int f=4;f<6;++f) if(presence&(1<<(f-4)))
        for(int32_t j=0;j<nl;++j) for(int32_t i=ks-1;i<ke;++i)
            if(bits(out[f].data[(size_t)j*(size_t)np+(size_t)i])!=0)
                fail("positive zero optional correction");
    if(mode) {release(&coord);release(&matrix);}
    for(int f=0;f<INPUTS;++f) release(&input[f]);
    for(int f=0;f<6;++f) {release(&out[f]);release(&ref[f]);free(incoming[f]);}
    release(&g);release(&cv);release(&vt);release(&vf);
    memcpy(fieldmap,oldmap,sizeof oldmap);
}
int main(int argc,char **argv) {
    if(argc!=3 && (argc!=4 || strcmp(argv[3],"--finite-element")))
        fail("two output paths and optional --finite-element required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    fieldmap=dlsym(RTLD_DEFAULT,"__intdyn_mod_MOD_yytxybder");
    if(!fieldmap) fail("field map symbol");
    if(hook) *hook=0;
    uint64_t control=fpcr();
    if(control&UINT64_C(0x03c80000)) fail("FPCR rounding or underflow");
    independent_difference();
    FILE *af=fopen(argv[1],"wb"),*rf=fopen(argv[2],"wb");
    if(!af || !rf) fail("output open");
    const int32_t shapes[][4]={{1,1,1,0},{1,1,1,1},{2,1,2,2},{3,1,3,3},
        {7,2,6,5},{9,1,9,19},{13,13,13,20},{3,2,1,7},{8,1,8,32}};
    int number=0;
    for(size_t k=0;k<sizeof shapes/sizeof shapes[0];++k)
        for(int flag=-1;flag<=1;++flag) for(int pattern=0;pattern<=2;++pattern)
            check_case(++number,0,0,shapes[k][0],shapes[k][1],shapes[k][2],shapes[k][3],
                pattern,flag,(int)(k+(size_t)pattern+(size_t)(flag+1))%4,0,0,1,af,rf);
    for(int pattern=3;pattern<=7;++pattern) for(int flag=-1;flag<=1;++flag)
        for(int width=1;width<=3;++width)
            check_case(++number,0,0,width,1,width,5,pattern,flag,(width+flag+1)%4,0,0,1,af,rf);
    const int32_t tails[][4]={{1,1,1,1},{3,1,3,19},{4,2,4,3},{7,1,7,5}};
    for(size_t k=0;k<sizeof tails/sizeof tails[0];++k) for(int flag=-1;flag<=1;++flag)
        check_case(++number,0,0,tails[k][0],tails[k][1],tails[k][2],tails[k][3],
            0,flag,3,1,1,1,af,rf);
    for(int flag=-1;flag<=1;++flag) {
        check_case(++number,0,0,7,2,6,19,0,flag,3,0,1,1,af,rf);
        check_case(++number,0,0,3,1,3,3,3,flag,3,1,2,1,af,rf);
        check_case(++number,0,0,1,1,1,1,6,flag,3,1,0,1,af,rf);
    }
    for(int flag=-1;flag<=1;++flag)
        check_case(++number,0,0,7,2,6,19,0,flag,3,1,3,1,af,rf);
    if(argc==4) {
        for(int ibc=0;ibc<4;++ibc) for(int lower=-1;lower<=1;++lower)
            for(int flag=-1;flag<=1;++flag)
                check_case(++number,1,ibc,7,2,6,19,0,flag,3,1,1,lower,af,rf);
        for(int flag=-1;flag<=1;++flag) {
            check_case(++number,1,3,1,1,1,0,0,flag,3,0,0,0,af,rf);
            check_case(++number,1,3,1,1,1,1,0,flag,3,1,0,1,af,rf);
            check_case(++number,1,3,3,2,1,7,0,flag,3,1,0,-1,af,rf);
            for(int pattern=4;pattern<=5;++pattern)
                check_case(++number,1,3,3,1,3,3,pattern,flag,3,1,0,0,af,rf);
        }
    }
    if(fpcr()!=control) fail("changed FPCR");
    if(fclose(af) || fclose(rf)) fail("output close");
    printf("GPGRGEO PASS cases=%d calls=%" PRIu64 " bytes=%" PRIu64
        " differing_bytes=0 conventional=%" PRIu64 " finite_element=%" PRIu64
        " absent_flag=%" PRIu64 " false_flag=%" PRIu64 " true_flag=%" PRIu64
        " presence_0=%" PRIu64 " presence_1=%" PRIu64 " presence_2=%" PRIu64
        " presence_3=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        number,calls,total_bytes,mode_calls[0],mode_calls[1],flag_calls[0],flag_calls[1],
        flag_calls[2],presence_calls[0],presence_calls[1],presence_calls[2],presence_calls[3],control);
    return 0;
}

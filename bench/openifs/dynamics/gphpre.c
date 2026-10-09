/* Verify complete GPHPRE pressure outputs and the prescribed layer methods.
 * Pressure uses Pa. Independent layer integrals use long-double arithmetic. */
#define _GNU_SOURCE
#include <complex.h>
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
#define HP_ARGS const int32_t *np,const int32_t *nf,const int32_t *ks, \
 const int32_t *ke,const void *vab,const void *cver,double *ph,double *xy,double *pf
void gphpre_(HP_ARGS);
void gphpre_assembly_(HP_ARGS);
extern int32_t __intdyn_mod_MOD_yytxyb[8];
extern double __yomvert_MOD_toppres,__yomcst_MOD_rd,__yomcst_MOD_rcvd;
typedef struct {void *map;size_t bytes,usable,count;double *data;int tail;} buffer;
static const double guard=-777.75;
static uint64_t calls,total_bytes,mode_calls[4],option_calls[4];
static void fail(const char *message) {
    fprintf(stderr,"GPHPRE check failed %s\n",message);exit(2);
}
static uint64_t bits(double x) {uint64_t n;memcpy(&n,&x,8);return n;}
static uint64_t fpcr(void) {uint64_t n;__asm__ volatile("mrs %0,fpcr":"=r"(n));return n;}
static buffer make_buffer(size_t count,int tail) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE),entries=count+2-(size_t)tail;
    size_t usable=(entries*8+page-1)/page*page;
    void *map=mmap(NULL,usable+2*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(map==MAP_FAILED || mprotect((char *)map+page,usable,PROT_READ|PROT_WRITE)) fail("buffer pages");
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
static void descriptor(void *object,size_t off,buffer *b,int64_t lo,int64_t hi) {
    int64_t entries[8]={(int64_t)(uintptr_t)b->data,-lo,8,INT64_C(3302829850624),8,1,lo,hi};
    memcpy((char *)object+off,entries,64);
}
static void close_value(double actual,long double expected,long double absolute,
                        long double extra,const char *name) {
    long double limit=absolute+1.0e-12L*fabsl(expected)+extra;
    if(!isfinite(actual) || fabsl((long double)actual-expected)>limit) {
        fprintf(stderr,"Independent %s actual=%.17g expected=%.21Lg limit=%.5Lg\n",name,actual,expected,limit);
        fail("physical relationship");
    }
}
/* Integrate log pressure between moving affine boundaries.
 * The imaginary perturbation obtains the derivative without subtraction. */
static long double mean_log(long double a,long double b) {
    return (b*(logl(b)-1.0L)-a*(logl(a)-1.0L))/(b-a);
}
static long double integral_derivative(long double a,long double b,
                                      long double bu,long double bl) {
    const long double h=1.0e-16L;
    long double complex x=a+I*bu*h,y=b+I*bl*h;
    long double complex value=(y*(clogl(y)-1.0L)-x*(clogl(x)-1.0L))/(y-x);
    return cimagl(value)/h;
}
static double coefficient(buffer *coeff,int field,int j,int64_t lo) {
    return coeff[field].data[(int64_t)j-lo];
}
static void check_case(int number,int mode,int opts,int lap,int top,int map,
                       int64_t lo,int32_t np,int32_t nf,int32_t ks,int32_t ke,
                       int pattern,int tail,FILE *af,FILE *rf) {
    int fe=mode==0,nd=fe?9:mode-1,active=nf>0 && ke>=ks;
    int32_t indices[8]={1,2,3,4,5,6,7,7};
    if(map) {
        const int32_t reversed[8]={7,6,5,4,3,2,1,9};
        memcpy(indices,reversed,32);
    }
    if(fe && map) {indices[5]=0;indices[6]=-1;}
    memcpy(__intdyn_mod_MOD_yytxyb,indices,32);
    buffer vab=make_buffer(64,0),cver=make_buffer(27,0),coeff[7];
    memset(vab.data,0,512);memset(cver.data,0,216);
    integer(cver.data,0,lap);integer(cver.data,4,nd);integer(cver.data,52,fe);
    double rhydr=log(2.0);
    memcpy((char *)cver.data+8,&rhydr,8);
    const size_t offsets[7]={128,64,256,320,384,448,192};
    size_t count=(size_t)((int64_t)nf-lo+1);
    for(int f=0;f<7;++f) {
        coeff[f]=make_buffer(count,tail);
        for(int64_t j=lo;j<=nf;++j) {
            double t=nf?(double)j/(double)nf:0.0;
            double a=j==nf?0.0:512.0*(1.0-t),b=t;
            if(pattern==1) {a=0.0;b=j==0?0.5:j==1?0.5005:1.0;}
            if(pattern==2) {a=0.0;b=t;}
            if(j==0 && pattern!=1) {
                if(top==0) {a=512.0;b=0.0;}
                if(top==1) {a=0.0;b=0.0;}
                if(top==2) {a=__yomvert_MOD_toppres;b=0.0;}
                if(top==3) {a=0.025;b=0.0;}
                if(top==4) {a=-1.0;b=0x1p-16;}
                if(pattern==2) {a=-1.0;b=1.0+0x1p-27;}
                if(pattern==3) {a=-0.0;b=-0.0;}
            }
            if(f==0) coeff[f].data[j-lo]=a;
            else if(f==1) coeff[f].data[j-lo]=b;
            else coeff[f].data[j-lo]=0.0;
        }
    }
    for(int32_t j=1;j<=nf;++j) {
        double au=coefficient(coeff,0,j-1,lo),al=coefficient(coeff,0,j,lo);
        double bu=coefficient(coeff,1,j-1,lo),bl=coefficient(coeff,1,j,lo);
        coeff[2].data[j-lo]=(au+al)*0.5;
        coeff[3].data[j-lo]=(bu+bl)*0.5;
        if(pattern==4) {coeff[2].data[j-lo]=((double)j-0.5)*20000.0;coeff[3].data[j-lo]=-0.0;}
        double factor=fe?(j%2?1.125:0.875):1.0;
        coeff[4].data[j-lo]=(al-au)*factor;
        coeff[5].data[j-lo]=(bl-bu)*factor;
        coeff[6].data[j-lo]=al*bu-au*bl;
    }
    for(int f=0;f<7;++f) {
        int used=active && (f<2 || (opts && (fe?(f>=2 && f<=5):(f==5 || (f==6 && !(nf==1 && top==1))))));
        if(used) descriptor(vab.data,offsets[f],&coeff[f],lo,nf);
        readonly(&coeff[f]);
    }
    readonly(&vab);readonly(&cver);
    size_t cells=(size_t)np*(size_t)nf;
    size_t sizes[3]={(size_t)np*((size_t)nf+1),cells*(size_t)indices[7],cells};
    buffer out[3],ref[3];
    for(int f=0;f<3;++f) {out[f]=make_buffer(sizes[f],tail);ref[f]=make_buffer(sizes[f],tail);}
    for(int32_t i=0;i<np;++i) {
        double ps=pattern==2?1.0-0x1p-27:65536.0+4096.0*i;
        out[0].data[(size_t)nf*(size_t)np+(size_t)i]=ps;
        ref[0].data[(size_t)nf*(size_t)np+(size_t)i]=ps;
    }
    size_t phentries=sizes[0]+2-(size_t)tail;
    double *before=malloc(phentries*8);
    if(!before) fail("pressure snapshot");
    memcpy(before,out[0].data-1,phentries*8);
    const void *vv=active?vab.data:NULL,*cv=opts?cver.data:NULL;
    uint64_t control=fpcr();
    gphpre_(&np,&nf,&ks,&ke,vv,cv,active?ref[0].data:NULL,
            opts&1?ref[1].data:NULL,opts&2?ref[2].data:NULL);
    if(fpcr()!=control) fail("reference changed FPCR");
    gphpre_assembly_(&np,&nf,&ks,&ke,vv,cv,active?out[0].data:NULL,
                     opts&1?out[1].data:NULL,opts&2?out[2].data:NULL);
    if(fpcr()!=control) fail("assembly changed FPCR");
    ++calls;++mode_calls[mode];++option_calls[opts];
    for(int f=0;f<3;++f) {
        size_t entries=sizes[f]+2-(size_t)tail;
        for(size_t k=0;k<entries;++k) {
            double actual=out[f].data[(ptrdiff_t)k-1],expected=ref[f].data[(ptrdiff_t)k-1];
            if(bits(actual)!=bits(expected)) {
                size_t cell=k?k-1:0;
                fprintf(stderr,"Mismatch stage=GPHPRE case=%d mode=%d output=%d field=%zu level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                    number,mode,f,cells?cell/cells+1:0,cell/(size_t)np,cell%(size_t)np+1,bits(actual),bits(expected));exit(1);
            }
            int interior=k>0 && k<=sizes[f];
            size_t cell=k?k-1:0;
            int used=interior && active && (int32_t)(cell%(size_t)np)+1>=ks && (int32_t)(cell%(size_t)np)+1<=ke;
            if(f==0) used=used && cell/(size_t)np<(size_t)nf;
            else used=used && (opts&(f==1?1:2));
            if(f==1 && interior && (opts&1)) {
                size_t field=cell/cells+1;
                int selected=0;
                for(int g=0;g<(fe?5:7);++g) if(field==(size_t)indices[g]) selected=1;
                if((!used || !selected) && bits(actual)!=0) fail("positive-zero coefficient padding");
            } else if(!used && bits(actual)!=bits(f==0?before[k]:guard)) fail("inactive output storage");
        }
        if(fwrite(out[f].data-1,8,entries,af)!=entries || fwrite(ref[f].data-1,8,entries,rf)!=entries) fail("output write");
        total_bytes+=(uint64_t)entries*8;
    }
    if(active) {
        int first=1;
        if(opts) for(int32_t i=ks-1;i<ke;++i)
            if(out[0].data[i]<=__yomvert_MOD_toppres) first=2;
        for(int32_t i=ks-1;i<ke;++i) {
            long double ps=out[0].data[(size_t)nf*(size_t)np+(size_t)i],sum=0.0L,weights=0.0L;
            for(int32_t j=0;j<nf;++j) {
                long double expected=(long double)coefficient(coeff,0,j,lo)+(long double)coefficient(coeff,1,j,lo)*ps;
                close_value(out[0].data[(size_t)j*(size_t)np+(size_t)i],expected,1.0e-10L,0,"hybrid boundary");
            }
            for(int32_t j=1;j<=nf;++j) {
                size_t cell=(size_t)(j-1)*(size_t)np+(size_t)i;
                long double a=out[0].data[(size_t)(j-1)*(size_t)np+(size_t)i];
                long double b=out[0].data[(size_t)j*(size_t)np+(size_t)i];
                long double bu=coefficient(coeff,1,j-1,lo),bl=coefficient(coeff,1,j,lo);
                long double w=b-a,e=1.0L/w,d=0,alpha=0,t=0,h=1.0L/b,q=0,full=0,extra=0;
                sum+=w;
                if(!opts) continue;
                if(fe) {
                    w=(long double)coefficient(coeff,4,j,lo)+(long double)coefficient(coeff,5,j,lo)*ps;
                    full=(long double)coefficient(coeff,2,j,lo)+(long double)coefficient(coeff,3,j,lo)*ps;
                    e=1.0L/w;d=w/full;alpha=b/full-1.0L;
                    t=(long double)coefficient(coeff,3,j,lo)/full;h=0;q=0;
                    if(!(full>a && full<b && w>0)) fail("finite-element pressure bounds");
                } else if(j<first) {
                    if(nd==0) {
                        d=logl(b/(long double)__yomvert_MOD_toppres);alpha=rhydr;
                        q=1.0L/(b*(long double)__yomvert_MOD_toppres);
                        full=lap?(a+b)*0.5L:b*expl(-(long double)rhydr);
                    } else {
                        w=b;e=1.0L/b;d=nd==1?2.0L+(long double)__yomcst_MOD_rcvd/(long double)__yomcst_MOD_rd:2.0L;
                        alpha=1.0L;q=(d/b)*(d/b);full=b/d;
                    }
                    t=e*(long double)coefficient(coeff,5,j,lo);
                } else {
                    if(!(a>0 && b>a)) fail("ordered positive layer pressures");
                    long double logdepth=logl(b)-logl(a);
                    if(nd==0) {
                        long double mean=mean_log(a,b);
                        d=logdepth;alpha=logl(b)-mean;
                        full=lap?(a+b)*0.5L:expl(mean);
                        t=integral_derivative(a,b,bu,bl);
                        extra=64.0L*DBL_EPSILON*0.5L*(1.0L+a/(b-a));
                    } else {
                        d=2.0L*sinhl(logdepth*0.5L);full=sqrtl(a*b);
                        long double z=sqrtl(a/b),error=(1.0L-z)/(1.0L+z)*(bl/b-bu/a)*0.5L;
                        alpha=1.0L-z;t=(bu/a+bl/b)*0.5L+error;
                        if(d<logdepth) fail("approximate depth excess");
                        if(pattern==1 && j==1) {
                            long double ratio=(d-logdepth)/(logdepth*logdepth*logdepth/24.0L);
                            if(fabsl(ratio-1.0L)>2.0e-6L) fail("cubic thin-layer limit");
                        }
                    }
                    q=1.0L/(a*b);
                    if(!(full>a && full<b)) fail("interior full-pressure bounds");
                }
                weights+=w;
                long double expected[7]={w,e,d,alpha,t,h,q};
                if(opts&1) for(int f=0;f<(fe?5:7);++f) {
                    double actual=out[1].data[((size_t)indices[f]-1)*cells+cell];
                    long double absolute=f==0?1.0e-10L:f==1 || f==4 || f==5?1.0e-16L:f==6?1.0e-20L:1.0e-12L;
                    close_value(actual,expected[f],absolute,f==3?extra:0,"layer coefficient");
                }
                if(opts&2) close_value(out[2].data[cell],full,1.0e-10L,extra*fabsl(full),"full pressure");
            }
            long double actualdepth=ps-(long double)out[0].data[i];
            if(fabsl(sum-actualdepth)>1.0e-10L+1.0e-12L*fabsl(actualdepth)) fail("hydrostatic column mass");
            if(opts && !fe) {
                long double expected=nd>0 && first==2?ps:actualdepth;
                if(fabsl(weights-expected)>1.0e-10L+1.0e-12L*fabsl(expected)) fail("prescribed depth-weight sum");
            }
        }
    }
    if(memcmp(__intdyn_mod_MOD_yytxyb,indices,32)) fail("changed field map");
    free(before);
    for(int f=0;f<3;++f) {release(&out[f]);release(&ref[f]);}
    for(int f=0;f<7;++f) release(&coeff[f]);
    release(&vab);release(&cver);
}
int main(int argc,char **argv) {
    if(argc!=3) fail("two output paths required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(hook) *hook=0;
    __yomvert_MOD_toppres=0.1;__yomcst_MOD_rd=287.06;__yomcst_MOD_rcvd=717.6;
    uint64_t constants[3]={bits(__yomvert_MOD_toppres),bits(__yomcst_MOD_rd),bits(__yomcst_MOD_rcvd)};
    uint64_t control=fpcr();if(control&UINT64_C(0x03c80000)) fail("FPCR rounding or underflow");
    FILE *af=fopen(argv[1],"wb"),*rf=fopen(argv[2],"wb");if(!af || !rf) fail("output open");
    int number=0;
    for(int mode=0;mode<4;++mode) for(int opts=0;opts<4;++opts) for(int lap=0;lap<2;++lap)
        for(int top=0;top<5;++top)
            check_case(++number,mode,opts,lap,top,0,0,5,4,1,5,0,0,af,rf);
    for(int mode=0;mode<4;++mode) for(int opts=1;opts<4;++opts)
        for(int map=0;map<2;++map)
            check_case(++number,mode,opts,1,4,map,-2,7,19,2,6,0,0,af,rf);
    const int32_t shapes[][4]={{1,1,1,1},{1,19,1,1},{9,5,1,9},{13,20,13,13},{3,0,1,3},{3,7,2,1},{2,1,1,2}};
    for(size_t n=0;n<sizeof shapes/sizeof shapes[0];++n) {
        const int32_t *s=shapes[n];
        check_case(++number,1,0,0,0,0,0,s[0],s[1],s[2],s[3],0,0,af,rf);
        if(s[1]>0 && s[3]>=s[2]) for(int mode=0;mode<4;++mode)
            check_case(++number,mode,3,0,0,0,0,s[0],s[1],s[2],s[3],0,1,af,rf);
    }
    for(int mode=1;mode<4;++mode) {
        check_case(++number,mode,3,0,0,0,0,3,2,1,3,1,0,af,rf);
        check_case(++number,mode,3,0,1,0,0,3,3,1,3,2,0,af,rf);
    }
    // A single closed top layer does not read the absent VC allocation.
    for(int mode=0;mode<3;++mode) for(int opts=1;opts<4;++opts)
        check_case(++number,mode,opts,0,1,1,-2,3,1,2,2,0,1,af,rf);
    // Preserve a negative-zero top and a negative-zero active gradient weight.
    check_case(++number,1,0,0,1,0,0,3,3,1,3,3,0,af,rf);
    check_case(++number,0,3,0,0,0,0,3,3,1,3,4,0,af,rf);
    if(fpcr()!=control) fail("changed FPCR");
    if(constants[0]!=bits(__yomvert_MOD_toppres) || constants[1]!=bits(__yomcst_MOD_rd) || constants[2]!=bits(__yomcst_MOD_rcvd)) fail("changed module constants");
    if(fclose(af) || fclose(rf)) fail("close");
    printf("GPHPRE PASS cases=%d calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 finite_element=%" PRIu64 " logarithmic=%" PRIu64 " approximate_1=%" PRIu64 " approximate_2=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        number,calls,total_bytes,mode_calls[0],mode_calls[1],mode_calls[2],mode_calls[3],control);
    return 0;
}

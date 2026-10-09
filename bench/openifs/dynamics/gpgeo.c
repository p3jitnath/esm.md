/* Check gravitational potential in m²/s² against independent physical profiles.
 * Protected arrays test the active columns, surface row and vector remainder.
 * The optional FE corpus requires the separately verified direct dependency. */
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

#define GEO_ARGS const int32_t *np,const int32_t *ks,const int32_t *ke, \
 const int32_t *nl,double *phi,double *phif,const double *t,const double *r, \
 const double *depth,const double *alpha,const void *geometry
void gpgeo_(GEO_ARGS);
void gpgeo_assembly_(GEO_ARGS);
typedef struct {void *map;size_t bytes,usable,count;double *data;int tail;} buffer;
static const double guard=-777.75;
static uint64_t calls,total_bytes,mode_calls[2];
static void fail(const char *message) {
    fprintf(stderr,"GPGEO check failed %s\n",message);exit(2);
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
    long double tolerance=1.0e-10L+1.0e-12L*fabsl(expected);
    if(!isfinite(actual) || fabsl((long double)actual-expected)>tolerance) fail(what);
}
static void compare(int number,int mode,const char *field,buffer *a,buffer *r,
                    int32_t np,int32_t ks,int32_t ke,int32_t nl,int half,
                    const double *incoming,FILE *af,FILE *rf) {
    size_t entries=a->count+2-(size_t)a->tail;
    for(size_t k=0;k<entries;++k) {
        double av=a->data[(ptrdiff_t)k-1],rv=r->data[(ptrdiff_t)k-1];
        size_t cell=k?k-1:0;
        if(bits(av)!=bits(rv)) {
            fprintf(stderr,"Mismatch stage=GPGEO case=%d mode=%d field=%s level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                number,mode,field,cell/(size_t)np+(half?0:1),cell%(size_t)np+1,bits(av),bits(rv));
            exit(1);
        }
        int active=k>0 && k<=a->count && nl>0 &&
            (int32_t)(cell%(size_t)np)+1>=ks && (int32_t)(cell%(size_t)np)+1<=ke;
        if(half && cell/(size_t)np==(size_t)nl) active=0;
        double before=k>0 && k<=a->count?incoming[cell]:guard;
        if(!active && bits(av)!=bits(before)) fail("surface, inactive cell or guard changed");
        if(active && !isfinite(av)) fail("nonfinite active output");
    }
    if(fwrite(a->data-1,8,entries,af)!=entries ||
       fwrite(r->data-1,8,entries,rf)!=entries) fail("canonical output write");
    total_bytes+=(uint64_t)entries*8;
}
static void check_case(int number,int mode,int ibc,int32_t np,int32_t ks,
                       int32_t ke,int32_t nl,int pattern,int tail,
                       int64_t lower,FILE *af,FILE *rf) {
    size_t count=(size_t)np*(size_t)nl,half=(size_t)np*((size_t)nl+1);
    buffer g=make_buffer(404,0),input[4],out[2],ref[2],coord={0},matrix={0};
    memset(g.data,0,3232);
    integer(g.data,3068,mode);integer(g.data,3052,ibc);
    for(int f=0;f<4;++f) input[f]=make_buffer(count,tail);
    out[0]=make_buffer(half,tail);ref[0]=make_buffer(half,tail);
    out[1]=make_buffer(count,tail);ref[1]=make_buffer(count,tail);
    double *incoming[2]={malloc((half?half:1)*8),malloc((count?count:1)*8)};
    if(!incoming[0] || !incoming[1]) fail("incoming state allocation");

    for(int32_t j=0;j<nl;++j) for(int32_t i=0;i<np;++i) {
        size_t k=(size_t)j*(size_t)np+(size_t)i;
        double values[4]={280.0,287.0,log(2.0),0.5*log(2.0)};
        if(pattern==1) {
            values[0]=256.0+4.0*j;values[1]=288.0;
            values[2]=0.125;values[3]=0.0625;
        }
        if(pattern==2) values[1]=143.5;
        if(pattern==3) {
            values[0]=i%2?-1.0:1.0;values[1]=i%2?-0.0:0.0;
            values[2]=j%2?-0.0:0.0;values[3]=j%2?0.0:-0.0;
        }
        if(pattern==4) {
            values[0]=1.0;values[1]=i%2?-0x0.0000000000001p-1022:0x0.0000000000001p-1022;
            values[2]=1.0;values[3]=0.5;
        }
        if(pattern==5) {
            values[0]=0x1.fffffffffffffp-1;values[1]=0x1.fffffffffffffp-1;
            values[2]=0x1.0000000000001p0;values[3]=0x1.0000000000001p0;
        }
        if(pattern==6) {
            values[0]=i%2?0x1p500:0x1p-500;
            values[1]=i%2?0x1p-500:0x1p500;
            values[2]=0x1p-500;values[3]=i%2?0x1p500:0x1p-500;
        }
        if(mode) {
            values[0]=256.0;values[1]=256.0;
            values[2]=nl?1.0/(double)nl:0.0;values[3]=0.0;
            if(pattern==3) values[1]=i%2?-0.0:0.0;
            if(pattern==4) {values[0]=1.0;values[1]=0x0.0000000000001p-1022;}
        }
        for(int f=0;f<4;++f) input[f].data[k]=values[f];
    }
    for(int32_t i=0;i<np;++i) {
        double surface=1024.0+32.0*i;
        if(pattern==3 || pattern==4) surface=i%2?-0.0:0.0;
        if(pattern==5) surface=-1.0;
        if(pattern==6) surface=i%2?-0x1p500:0.0;
        out[0].data[(size_t)nl*(size_t)np+(size_t)i]=surface;
    }
    memcpy(ref[0].data,out[0].data,half*8);
    if(count) memcpy(ref[1].data,out[1].data,count*8);
    memcpy(incoming[0],out[0].data,half*8);
    if(count) memcpy(incoming[1],out[1].data,count*8);
    for(int f=0;f<4;++f) readonly(&input[f]);

    if(mode) {
        size_t nc=nl>0?(size_t)((int64_t)nl-lower+1):1;
        coord=make_buffer(nc,tail);
        for(size_t k=0;k<nc;++k) coord.data[k]=(double)(nl?nl:1);
        rank1(g.data,776,&coord,lower,lower+(int64_t)nc-1);
        int64_t rows=(int64_t)nl+1,cols=(int64_t)nl+((ibc==1 || ibc==3)?2:0);
        matrix=make_buffer((size_t)rows*(size_t)cols,tail);
        for(int64_t column=0;column<cols;++column)
            for(int64_t row=0;row<rows;++row) {
                int64_t j=column-((ibc==1 || ibc==3)?1:0);
                double weight=0.0;
                if(j>=0 && j<nl && nl>0) {
                    if(row==nl || j<row) weight=1.0/(double)nl;
                    else if(j==row) weight=0.5/(double)nl;
                }
                matrix.data[(size_t)column*(size_t)rows+(size_t)row]=weight;
            }
        size_t off=840+(ibc==0?64:ibc==2?1296:240);
        rank2(g.data,off,&matrix,rows,cols,lower,lower-1);
        readonly(&coord);readonly(&matrix);
    }
    readonly(&g);
    int active=nl>0 && ke>=ks;
    const double *t=active?input[0].data:NULL,*r=active?input[1].data:NULL;
    const double *d=active?input[2].data:NULL;
    const double *a=active && !mode?input[3].data:NULL;
    double *ah=active?out[0].data:NULL,*afull=active?out[1].data:NULL;
    double *rh=active?ref[0].data:NULL,*rfull=active?ref[1].data:NULL;
    uint64_t control=fpcr();
    gpgeo_(&np,&ks,&ke,&nl,rh,rfull,t,r,d,a,g.data);
    gpgeo_assembly_(&np,&ks,&ke,&nl,ah,afull,t,r,d,a,g.data);
    if(fpcr()!=control) fail("changed FPCR");
    ++calls;++mode_calls[mode];
    compare(number,mode,"PHI",&out[0],&ref[0],np,ks,ke,nl,1,incoming[0],af,rf);
    compare(number,mode,"PHIF",&out[1],&ref[1],np,ks,ke,nl,0,incoming[1],af,rf);

    if(active && ((!mode && pattern<=2) || (mode && pattern<=2))) {
        for(int32_t i=ks-1;i<ke;++i) {
            long double surface=incoming[0][(size_t)nl*(size_t)np+(size_t)i];
            for(int32_t level=0;level<nl;++level) {
                long double expected_h,expected_f;
                if(mode) {
                    expected_h=surface+65536.0L*((long double)nl-level)/(long double)nl;
                    expected_f=surface+65536.0L*((long double)nl-level-0.5L)/(long double)nl;
                } else if(pattern==1) {
                    long double m=(long double)nl-level;
                    long double sum=256.0L*m+2.0L*m*((long double)level+nl-1);
                    expected_h=surface+36.0L*sum;
                    long double below=m-1;
                    long double sum_below=256.0L*below+2.0L*below*((long double)level+nl);
                    expected_f=surface+36.0L*sum_below+18.0L*(256.0L+4.0L*level);
                } else {
                    long double rt=(pattern==2?143.5L:287.0L)*280.0L;
                    expected_h=surface+rt*((long double)nl-level)*logl(2.0L);
                    expected_f=surface+rt*((long double)nl-level-0.5L)*logl(2.0L);
                }
                size_t k=(size_t)level*(size_t)np+(size_t)i;
                physics(out[0].data[k],expected_h,"independent boundary profile");
                physics(out[1].data[k],expected_f,"independent full-level profile");
                double low=out[0].data[k+(size_t)np],high=out[0].data[k],full=out[1].data[k];
                if(high<low || full<low || full>high) fail("physical height ordering");
            }
        }
    }
    if(mode) {release(&coord);release(&matrix);}
    for(int f=0;f<4;++f) release(&input[f]);
    for(int f=0;f<2;++f) {release(&out[f]);release(&ref[f]);free(incoming[f]);}
    release(&g);
}
int main(int argc,char **argv) {
    if(argc!=3 && (argc!=4 || strcmp(argv[3],"--finite-element")))
        fail("two output paths and optional --finite-element required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    if(hook) *hook=0;
    uint64_t control=fpcr();
    if(control&UINT64_C(0x03c80000)) fail("FPCR rounding or underflow");
    FILE *af=fopen(argv[1],"wb"),*rf=fopen(argv[2],"wb");
    if(!af || !rf) fail("output open");
    const int32_t shapes[][4]={{1,1,1,0},{1,1,1,1},{2,1,2,2},{3,1,3,3},
        {7,2,6,5},{9,1,9,19},{13,13,13,20},{3,2,1,7},{8,1,8,32}};
    int number=0;
    for(size_t k=0;k<sizeof shapes/sizeof shapes[0];++k)
        for(int pattern=0;pattern<=2;++pattern)
            check_case(++number,0,0,shapes[k][0],shapes[k][1],shapes[k][2],shapes[k][3],
                       pattern,0,1,af,rf);
    for(int pattern=3;pattern<=6;++pattern)
        for(int width=1;width<=3;++width)
            check_case(++number,0,0,width,1,width,5,pattern,0,1,af,rf);
    const int32_t tails[][4]={{1,1,1,1},{3,1,3,19},{4,2,4,3},{7,1,7,5}};
    for(size_t k=0;k<sizeof tails/sizeof tails[0];++k)
        check_case(++number,0,0,tails[k][0],tails[k][1],tails[k][2],tails[k][3],0,1,1,af,rf);
    if(argc==4) {
        for(int ibc=0;ibc<4;++ibc) for(int lower=-1;lower<=1;++lower) {
            check_case(++number,1,ibc,3,1,3,5,0,0,lower,af,rf);
            check_case(++number,1,ibc,7,2,6,19,0,1,lower,af,rf);
        }
        for(int pattern=3;pattern<=4;++pattern)
            check_case(++number,1,3,3,1,3,3,pattern,1,0,af,rf);
        check_case(++number,1,3,3,2,1,4,0,0,1,af,rf);
        check_case(++number,1,3,1,1,1,0,0,0,0,af,rf);
        check_case(++number,1,3,1,1,1,1,0,1,1,af,rf);
    }
    if(fpcr()!=control) fail("changed FPCR");
    if(fclose(af) || fclose(rf)) fail("output close");
    printf("GPGEO PASS cases=%d calls=%" PRIu64 " bytes=%" PRIu64
           " differing_bytes=0 conventional=%" PRIu64 " finite_element=%" PRIu64
           " FPCR=%016" PRIx64 "\n",number,calls,total_bytes,mode_calls[0],mode_calls[1],control);
    return 0;
}

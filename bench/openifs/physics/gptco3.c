/* Check ozone mass in kg/m² and signed moisture-column rates in kg/m²/s.
 * Exact bytes also verify signed diagnostic inputs and ordered FP64 rounding. */
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
#define GPTCO3_ARGS const int32_t *np,const int32_t *ks,const int32_t *ke, \
 const int32_t *nl,const double *dp,const double *q,double *mass
void gptco3_(GPTCO3_ARGS);
void gptco3_assembly_(GPTCO3_ARGS);
typedef struct {void *map;size_t map_bytes,usable_bytes,count;double *data;int tail;} buffer;
static const double guard=-777.75;
static uint64_t total_bytes,total_calls;
static double *gravity;
static void fail(const char *message) {
    fprintf(stderr,"GPTCO3 check failed %s\n",message);exit(2);
}
static uint64_t bits(double value) {
    uint64_t result;memcpy(&result,&value,8);return result;
}
static uint64_t fpcr(void) {
    uint64_t value;__asm__ volatile("mrs %0,fpcr":"=r"(value));return value;
}
static buffer make_buffer(size_t count,int tail) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE),entries=count+2-(size_t)tail;
    size_t usable=(entries*8+page-1)/page*page;
    void *map=mmap(NULL,usable+2*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(map==MAP_FAILED || mprotect((char *)map+page,usable,PROT_READ|PROT_WRITE)) fail("buffer pages");
    double *data=(double *)((char *)map+page+usable-entries*8)+1;
    for(size_t i=0;i<entries;++i) data[(ptrdiff_t)i-1]=guard;
    return (buffer){map,usable+2*page,usable,count,data,tail};
}
static void readonly(buffer *value) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    if(mprotect((char *)value->map+page,value->usable_bytes,PROT_READ)) fail("read-only input");
}
static void release(buffer *value) {
    if(munmap(value->map,value->map_bytes)) fail("release pages");
}
static void check_case(int number,int32_t np,int32_t ks,int32_t ke,int32_t nl,
                       int pattern,int tail,FILE *af,FILE *rf) {
    size_t cells=(size_t)np*(size_t)nl;
    buffer dp=make_buffer(cells,tail),q=make_buffer(cells,tail);
    buffer a=make_buffer((size_t)np,tail),r=make_buffer((size_t)np,tail);
    double g=pattern>=4?1.0:pattern==2?2.0:9.80665;*gravity=g;
    for(int32_t j=1;j<=nl;++j) for(int32_t i=0;i<np;++i) {
        size_t k=(size_t)(j-1)*(size_t)np+(size_t)i;
        dp.data[k]=512.0+8.0*j+i;q.data[k]=0x1p-20;
        if(pattern==1) q.data[k]=0.0;
        if(pattern==2) q.data[k]=0x1p-20*(j+i+1.0);
        if(pattern==3) q.data[k]=-0.0;
        if(pattern==4) {q.data[k]=0x0.0000000000001p-1022;dp.data[k]=1.0;}
        if(pattern==5) {q.data[k]=(j&1)?-1.0:1.0;dp.data[k]=1.0;}
        if(pattern==7) q.data[k]=0x1p-20*((j&1)?-(double)j:(double)j);
        if(pattern==6) {q.data[k]=j==1?-1.0:1.0+0x1p-27;dp.data[k]=j==1?1.0:1.0-0x1p-27;}
    }
    readonly(&dp);readonly(&q);
    int empty=nl==0 || ke<ks;
    gptco3_(&np,&ks,&ke,&nl,empty?NULL:dp.data,empty?NULL:q.data,r.data);
    gptco3_assembly_(&np,&ks,&ke,&nl,empty?NULL:dp.data,empty?NULL:q.data,a.data);
    ++total_calls;
    size_t entries=(size_t)np+2-(size_t)tail;
    for(size_t k=0;k<entries;++k) {
        double av=a.data[(ptrdiff_t)k-1],rv=r.data[(ptrdiff_t)k-1];
        if(bits(av)!=bits(rv)) {
            fprintf(stderr,"Mismatch stage=GPTCO3 case=%d column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                number,k,bits(av),bits(rv));exit(1);
        }
        if(k==0 || k>(size_t)np || (int32_t)k<ks || (int32_t)k>ke)
            if(bits(av)!=bits(guard)) fail("inactive column or guard");
    }
    for(int32_t i=ks-1;i<ke;++i) {
        long double depth=0.0L,expected=0.0L,scale=0.0L;
        for(int32_t j=0;j<nl;++j) {
            size_t k=(size_t)j*(size_t)np+(size_t)i;
            long double layer=(long double)q.data[k]*(long double)dp.data[k]/(long double)g;
            expected+=layer;scale+=fabsl(layer);depth+=dp.data[k];
        }
        if(pattern==0) expected=0x1p-20L*depth/(long double)g;
        long double tolerance=128.0L*DBL_EPSILON*scale+1.0e-300L;
        if(!isfinite(a.data[i]) || fabsl((long double)a.data[i]-expected)>tolerance) fail("independent ozone-column mass");
        if(pattern>=5) {
            long double water0=0.0L,water1=0.0L,dt=1.0L/64.0L,q0=1.0L/16.0L;
            for(int32_t j=0;j<nl;++j) {
                size_t k=(size_t)j*(size_t)np+(size_t)i;
                long double air=(long double)dp.data[k]/g,q1=q0+dt*(long double)q.data[k];
                if(q1<0.0L) fail("inadmissible water fixture");
                water0+=q0*air;water1+=q1*air;
            }
            long double budget=water1-water0-dt*(long double)a.data[i];
            long double bound=256.0L*DBL_EPSILON*(fabsl(water0)+fabsl(water1))+1.0e-300L;
            if(fabsl(budget)>bound) fail("independent water-column rate balance");
        }
        if(pattern<5 && a.data[i]<0.0) fail("negative physical ozone mass");
        if((nl==0 || pattern==1 || pattern==3 || pattern==6) && bits(a.data[i])!=0) fail("zero column or separate-rounding witness");
    }
    if(bits(*gravity)!=bits(g)) fail("changed gravity");
    if(fwrite(a.data-1,8,entries,af)!=entries || fwrite(r.data-1,8,entries,rf)!=entries) fail("trajectory write");
    total_bytes+=(uint64_t)entries*8;
    release(&dp);release(&q);release(&a);release(&r);
}
int main(int argc,char **argv) {
    if(argc!=3) fail("two output paths required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(hook) *hook=0;
    gravity=dlsym(RTLD_DEFAULT,"__yomcst_MOD_rg");if(!gravity) fail("gravity scalar");
    uint64_t control=fpcr();if(control & UINT64_C(0x03c80000)) fail("FPCR rounding or underflow");
    FILE *af=fopen(argv[1],"wb"),*rf=fopen(argv[2],"wb");if(!af || !rf) fail("output open");
    const int32_t shapes[][4]={{1,1,1,0},{1,1,1,1},{1,1,1,19},{7,2,6,5},
        {9,1,9,19},{13,13,13,20},{3,2,1,7},{2,1,2,1},{5,1,5,3}};
    int number=0;
    for(size_t c=0;c<sizeof shapes/sizeof shapes[0];++c) for(int pattern=0;pattern<6;++pattern)
        check_case(++number,shapes[c][0],shapes[c][1],shapes[c][2],shapes[c][3],pattern,0,af,rf);
    for(int32_t np=1;np<=3;++np) check_case(++number,np,1,np,2,6,0,af,rf);
    for(int32_t nl=0;nl<=2;++nl) check_case(++number,3,1,3,nl,0,1,af,rf);
    const int32_t rate_levels[3]={1,4,19};
    for(int k=0;k<3;++k) {
        check_case(++number,3,1,3,rate_levels[k],7,1,af,rf);
        check_case(++number,7,2,6,rate_levels[k],7,0,af,rf);
    }
    if(fpcr()!=control) fail("changed FPCR");
    if(fclose(af) || fclose(rf)) fail("output close");
    printf("GPTCO3 PASS cases=%d calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",number,total_calls,total_bytes,control);
    return 0;
}

/* Verify complete spectral filtering, with vorticity in s^-1.
 * Closed factors are calculated independently at 110 decimal digits.
 * Full allocations retain padding, signed zeros and divergence bytes. */
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
typedef void (*solver)(const void *,const int32_t *,const int32_t *,void *,void *);
void spfilt_(const void *,const int32_t *,const int32_t *,void *,void *);
#ifndef SPFILT_FREEZE_ONLY
void spfilt_assembly_(const void *,const int32_t *,const int32_t *,void *,void *);
void spfilt_abi_bridge(void *);
uint64_t vertical_abi_call(void (*)(void *),void *);
#endif
typedef struct {void *map;size_t map_bytes,usable,bytes;unsigned char *data;} buffer;
static uint64_t calls,returned_bytes,science,inactive,abi_calls;
static void fail(const char *what) {fprintf(stderr,"SPFILT failed %s\n",what);exit(2);}
static uint64_t fpcr(void) {uint64_t u;__asm__ volatile("mrs %0,fpcr":"=r"(u));return u;}
static uint64_t word(const void *p) {uint64_t u;memcpy(&u,p,8);return u;}
static int32_t integer(const void *p) {int32_t n;memcpy(&n,p,4);return n;}
static int64_t stride(const void *p) {int64_t n;memcpy(&n,p,8);return n;}
static buffer allocate(size_t bytes) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    size_t usable=((bytes?bytes:1)+page-1)/page*page;
    void *m=mmap(NULL,usable+2*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(m==MAP_FAILED||mprotect((char *)m+page,usable,PROT_READ|PROT_WRITE)) fail("protected allocation");
    return (buffer){m,usable+2*page,usable,bytes,(unsigned char *)m+page+usable-bytes};
}
static void readonly(buffer *b) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    if(mprotect((char *)b->map+page,b->usable,PROT_READ)) fail("read-only storage");
}
static void release(buffer *b) {if(munmap(b->map,b->map_bytes)) fail("release");}
static void get(FILE *f,void *p,size_t n) {if(n&&fread(p,1,n,f)!=n) fail("corpus length");}
static void put(FILE *f,const void *p,size_t n) {if(n&&fwrite(p,1,n,f)!=n) fail("record write");}
static void equal(const char *field,const void *a,const void *b,size_t n) {
    const unsigned char *x=a,*y=b;
    for(size_t k=0;k<n;++k) if(x[k]!=y[k]) {
        size_t offset=(k/8)*8,remaining=n-offset;
        uint64_t aw=0,bw=0;memcpy(&aw,x+offset,remaining<8?remaining:8);memcpy(&bw,y+offset,remaining<8?remaining:8);
        fprintf(stderr,"Mismatch stage=SPFILT call=%"PRIu64" field=%s byte=%zu assembly=%016"PRIx64" source=%016"PRIx64"\n",calls,field,k,aw,bw);exit(1);
    }
}
static void descriptor(uint64_t d[11],double *data,int64_t rows,int64_t cols,
                       int64_t rs,int64_t cs,int64_t rl,int64_t cl) {
    uint64_t init[11]={(uintptr_t)data,(uint64_t)(-rl*rs-cl*cs),8,
        UINT64_C(0x0000030200000000),8,(uint64_t)rs,(uint64_t)rl,
        (uint64_t)(rl+rows-1),(uint64_t)cs,(uint64_t)cl,(uint64_t)(cl+cols-1)};
    memcpy(d,init,88);
}
static void physics(const unsigned char h[128],const double *before,const double *after,
                    const double *factor,const int32_t *nv) {
    int32_t ns=integer(h+16),nf=integer(h+20),cols=integer(h+28);
    int32_t ks=integer(h+32),ke=integer(h+36),nvlow=integer(h+40);
    int64_t rs=stride(h+48),cs=stride(h+56),base=stride(h+64);
    size_t words=(size_t)word(h+72);
    unsigned char *active=calloc(words,1);if(!active) fail("active map");
    for(int32_t j=1;j<=cols;++j) if(!(factor[j-1]>=1.0/1025.0&&factor[j-1]<=1.0)) fail("closed factor bounds");
    for(int32_t j=ks;j<=ke;++j) for(int32_t l=0;l<nf;++l) {
        ptrdiff_t k=(ptrdiff_t)(base+l*rs+(j-1)*cs);
        if(k<0||(size_t)k>=words||active[k]) fail("selected buffer contract");
        active[k]=1;
        long double expected=(long double)factor[j-1]*before[k];
        long double limit=64.0L*DBL_EPSILON*fabsl(expected)+8.0L*DBL_TRUE_MIN;
        if(!isfinite(after[k])||fabsl((long double)after[k]-expected)>limit) {
            fprintf(stderr,"science call=%"PRIu64" degree=%d level=%d got=%.17g expected=%.21Lg limit=%.9Lg\n",calls,nv[j-nvlow],l+1,after[k],expected,limit);
            fail("independent closed filter");
        }
        if(fabsl(after[k])>fabsl(before[k])+8.0L*DBL_TRUE_MIN) fail("amplitude increase");
        if(ns==21&&nv[j-nvlow]==1&&word(after+k)!=word(before+k)) fail("rigid rotation");
        ++science;
    }
    for(size_t k=0;k<words;++k) if(!active[k]) {
        if(word(after+k)!=word(before+k)) fail("inactive storage");
        ++inactive;
    }
    free(active);
}
static void run_case(FILE *input,FILE *af,FILE *rf,unsigned char h[128]) {
    int32_t ns=integer(h+16),nf=integer(h+20),rows=integer(h+24),cols=integer(h+28);
    int32_t ks=integer(h+32),ke=integer(h+36),nvlow=integer(h+40),nvcap=integer(h+44);
    int64_t rs=stride(h+48),cs=stride(h+56),base=stride(h+64);
    size_t vw=(size_t)word(h+72),dw=(size_t)word(h+80),nvbytes=((size_t)nvcap*4+7)/8*8;
    if(ns<0||ns>4096||nf<0||nf>4096||rows<nf||cols<0||nvcap<0||ks<1||ke>cols||ke<ks-1||vw<1||dw<1) fail("corpus domain");
    buffer nv=allocate(nvbytes),g=allocate(17096),av=allocate(vw*8),rv=allocate(vw*8),dv=allocate(dw*8);
    double *before=malloc(vw*8),*divbefore=malloc(dw*8),*factors=malloc((cols?cols:1)*8);
    if(!before||!divbefore||!factors) fail("fixture copies");
    get(input,nv.data,nvbytes);get(input,before,vw*8);get(input,divbefore,dw*8);get(input,factors,(size_t)cols*8);
    memcpy(av.data,before,vw*8);memcpy(rv.data,before,vw*8);memcpy(dv.data,divbefore,dw*8);
    memset(g.data,0,17096);memcpy(g.data+5172,&ns,4);memcpy(g.data+5228,&nf,4);
    uint64_t nd[8]={(uintptr_t)nv.data,(uint64_t)-(int64_t)nvlow,4,UINT64_C(0x0000010100000000),4,1,(uint64_t)(int64_t)nvlow,(uint64_t)(int64_t)(nvlow+nvcap-1)};
    memcpy(g.data+3848,nd,64);
    uint64_t ad[11],rd[11],dd[11],adbefore[11],rdbefore[11],ddbefore[11];
    descriptor(ad,(double *)av.data+base,rows,cols,rs,cs,stride(h+104),stride(h+112));
    descriptor(rd,(double *)rv.data+base,rows,cols,rs,cs,stride(h+104),stride(h+112));
    descriptor(dd,(double *)dv.data,1,(int64_t)dw,1,1,-2,3);
    memcpy(adbefore,ad,88);memcpy(rdbefore,rd,88);memcpy(ddbefore,dd,88);
    readonly(&g);readonly(&nv);readonly(&dv);
    if(fpcr()) fail("entry FPCR");
    spfilt_(g.data,&ks,&ke,rd,dd);
    if(fpcr()) fail("source return FPCR");
    physics(h,before,(double *)rv.data,factors,(int32_t *)nv.data);
#ifndef SPFILT_FREEZE_ONLY
    void *args[5]={g.data,&ks,&ke,ad,dd};
    uint64_t canary=vertical_abi_call(spfilt_abi_bridge,args);
    if(canary) {fprintf(stderr,"ABI mask=%"PRIx64"\n",canary);fail("preserved registers or FPCR");}
    ++abi_calls;
    equal("vorticity",av.data,rv.data,vw*8);
    physics(h,before,(double *)av.data,factors,(int32_t *)nv.data);
    put(af,h,128);put(af,av.data,vw*8);put(af,dv.data,dw*8);
#else
    (void)af;
#endif
    equal("source descriptor",rd,rdbefore,88);equal("native descriptor",ad,adbefore,88);equal("divergence descriptor",dd,ddbefore,88);
    equal("divergence",dv.data,divbefore,dw*8);
    put(rf,h,128);put(rf,rv.data,vw*8);put(rf,dv.data,dw*8);
    returned_bytes+=128+vw*8+dw*8;++calls;
    free(before);free(divbefore);free(factors);
    release(&nv);release(&g);release(&av);release(&rv);release(&dv);
}
int main(int argc,char **argv) {
#ifdef SPFILT_FREEZE_ONLY
    if(argc!=3) fail("usage freeze corpus source-output");
#else
    if(argc!=4) fail("usage verify corpus native-output source-output");
#endif
    __asm__ volatile("msr fpcr,xzr");
    int *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(hook) *hook=0;
    FILE *input=fopen(argv[1],"rb");if(!input) fail("open corpus");
#ifdef SPFILT_FREEZE_ONLY
    FILE *af=NULL,*rf=fopen(argv[2],"wb");
#else
    FILE *af=fopen(argv[2],"wb"),*rf=fopen(argv[3],"wb");if(!af) fail("open native records");
#endif
    if(!rf) fail("open source records");
    unsigned char h[128];
    while(1) {
        size_t n=fread(h,1,128,input);if(!n&&feof(input)) break;
        if(n!=128||memcmp(h,"SPFC0001",8)||word(h+8)!=calls) fail("case header");
        run_case(input,af,rf,h);
    }
    if(fclose(input)||fclose(rf)||(af&&fclose(af))) fail("record close");
    printf("{\"cases\":%"PRIu64",\"returned_record_bytes\":%"PRIu64",\"independent_active_values\":%"PRIu64",\"inactive_values\":%"PRIu64",\"protected_calls\":%"PRIu64",\"abi_calls\":%"PRIu64",\"different_bytes\":0,\"fpcr\":%"PRIu64"}\n",calls,returned_bytes,science,inactive,calls,abi_calls,fpcr());
    return 0;
}

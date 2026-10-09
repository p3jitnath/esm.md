/* Check complete surface-pressure conversion and both horizontal derivatives.
 * Guarded storage protects the surface row and unused previous-time-level arrays. */
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
#define SPV_ARGS const void *g,const void *d,const void *a,const void *s, \
 const int32_t *tl,const int32_t *ks,const int32_t *ke, \
 const double *p0,const double *p0l,const double *p0m, \
 const double *p9,const double *p9l,const double *p9m, \
 double *r0,double *r0l,double *r0m,double *r9,double *r9l,double *r9m
void gp_spv_(SPV_ARGS);
void gp_spv_assembly_(SPV_ARGS);
typedef struct {void *map;size_t bytes,usable,count;double *data;int tail;} buffer;
static const double guard=-777.75;
static uint64_t calls,total_bytes;
static void fail(const char *message) {
    fprintf(stderr,"GP_SPV check failed %s\n",message);exit(2);
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
static int previous(int flags,int iteration) {
    int tl=flags&1,simple=(flags>>1)&1,nh=(flags>>2)&1,two=(flags>>3)&1,full=(flags>>4)&1;
    if(tl && !simple && !nh) return 0;
    if(!two) return 1;
    return iteration>0 && full;
}
static void check_case(int number,int flags,int iteration,int32_t np,int32_t ks,
                       int32_t ke,int32_t nf,int pattern,int tail,FILE *af,FILE *rf) {
    buffer g=make_buffer(2137,0),d=make_buffer(590,0),a=make_buffer(57,0),s=make_buffer(21,0);
    memset(g.data,0,17096);memset(d.data,0,4720);memset(a.data,0,456);memset(s.data,0,168);
    integer(g.data,5144,np);integer(g.data,5224,nf);integer(d.data,2580,iteration);
    integer(a.data,8,(flags>>2)&1);integer(a.data,20,(flags>>3)&1);
    integer(a.data,336,(flags>>4)&1);integer(s.data,0,(flags>>1)&1);
    readonly(&g);readonly(&d);readonly(&a);readonly(&s);
    buffer inputs[6],out[6],ref[6];
    size_t count[6]={(size_t)np*((size_t)nf+1),(size_t)np,(size_t)np,
                      (size_t)np*((size_t)nf+1),(size_t)np,(size_t)np};
    for(int f=0;f<6;++f) {
        inputs[f]=make_buffer((size_t)np,tail);out[f]=make_buffer(count[f],tail);ref[f]=make_buffer(count[f],tail);
        for(int32_t i=0;i<np;++i) {
            double x;
            if(f==0 || f==3) x=log(65536.0+128.0*i+4096.0*(f==3));
            else x=(f%3==1?1.0:-2.0)*(double)(i+1)/65536.0;
            if(pattern==1 && f%3) x=f%3==1?-0.0:0.0;
            if(pattern==2 && f%3) x=f%3==1?0x0.0000000000001p-1022:-0x0.0000000000001p-1022;
            if(pattern==3) x=f%3==0?(i%2?700.0:-700.0):(i%2?0x1p-700:0x1p700);
            if(pattern==4 && f%3==0) x=(double)i*log(2.0)/128.0;
            inputs[f].data[i]=x;
        }
        readonly(&inputs[f]);
    }
    int prev=previous(flags,iteration),empty=ke<ks;int32_t tl=flags&1;
    const double *in[6];
    double *av[6],*rv[6];
    for(int f=0;f<6;++f) {
        int used=!empty && (f<3 || prev);
        in[f]=used?inputs[f].data:NULL;av[f]=used?out[f].data:NULL;rv[f]=used?ref[f].data:NULL;
    }
    gp_spv_(g.data,d.data,a.data,s.data,&tl,&ks,&ke,in[0],in[1],in[2],in[3],in[4],in[5],
             rv[0],rv[1],rv[2],rv[3],rv[4],rv[5]);
    gp_spv_assembly_(g.data,d.data,a.data,s.data,&tl,&ks,&ke,in[0],in[1],in[2],in[3],in[4],in[5],
                      av[0],av[1],av[2],av[3],av[4],av[5]);
    ++calls;
    for(int f=0;f<6;++f) {
        size_t entries=count[f]+2-(size_t)tail;
        for(size_t k=0;k<entries;++k) {
            double actual=out[f].data[(ptrdiff_t)k-1],expected=ref[f].data[(ptrdiff_t)k-1];
            if(bits(actual)!=bits(expected)) {
                size_t cell=k?k-1:0;
                fprintf(stderr,"Mismatch stage=GP_SPV case=%d time=%d field=%d row=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                    number,f>=3?9:0,f%3,cell/(size_t)np,cell%(size_t)np+1,bits(actual),bits(expected));exit(1);
            }
            int active=k>0 && k<=count[f] && !empty && (f<3 || prev);
            size_t cell=k?k-1:0;
            active=active && (f%3 || cell/(size_t)np==(size_t)nf) &&
                (int32_t)(cell%(size_t)np)+1>=ks && (int32_t)(cell%(size_t)np)+1<=ke;
            if(!active && bits(actual)!=bits(guard)) fail("inactive storage");
        }
        if(fwrite(out[f].data-1,8,entries,af)!=entries || fwrite(ref[f].data-1,8,entries,rf)!=entries) fail("output write");
        total_bytes+=(uint64_t)entries*8;
    }
    for(int time=0;time<2;++time) if(!empty && (!time || prev)) {
        int base=time*3;
        for(int32_t i=ks-1;i<ke;++i) {
            long double pressure=expl((long double)inputs[base].data[i]);
            for(int f=0;f<3;++f) {
                long double expected=f?pressure*(long double)inputs[base+f].data[i]:pressure;
                double actual=out[base+f].data[f?(size_t)i:(size_t)nf*(size_t)np+(size_t)i];
                long double tolerance=1.0e-300L+32.0L*DBL_EPSILON*fabsl(expected);
                if(!isfinite(actual) || (actual<0.0 && f==0) || fabsl((long double)actual-expected)>tolerance)
                    fail("independent pressure and chain rule");
            }
        }
    }
    for(int f=0;f<6;++f) {release(&inputs[f]);release(&out[f]);release(&ref[f]);}
    release(&g);release(&d);release(&a);release(&s);
}
int main(int argc,char **argv) {
    if(argc!=3) fail("two output paths required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(hook) *hook=0;
    uint64_t control=fpcr();if(control&UINT64_C(0x03c80000)) fail("FPCR rounding or underflow");
    FILE *af=fopen(argv[1],"wb"),*rf=fopen(argv[2],"wb");if(!af || !rf) fail("output open");
    int number=0;
    for(int flags=0;flags<32;++flags) for(int it=-1;it<=1;++it)
        check_case(++number,flags,it,3,1,3,2,0,0,af,rf);
    const int32_t shapes[][4]={{1,1,1,0},{1,1,1,19},{7,2,6,5},{9,1,9,19},
                              {13,13,13,20},{3,2,1,7},{2,1,2,1},{5,1,5,3}};
    for(size_t k=0;k<sizeof shapes/sizeof shapes[0];++k) for(int flags=0;flags<=1;++flags)
        check_case(++number,flags,1,shapes[k][0],shapes[k][1],shapes[k][2],shapes[k][3],0,0,af,rf);
    for(int pattern=1;pattern<=4;++pattern) for(int flags=0;flags<=1;++flags)
        check_case(++number,flags,1,3,1,3,4,pattern,0,af,rf);
    for(int flags=0;flags<=1;++flags) check_case(++number,flags,1,3,1,3,2,0,1,af,rf);
    if(fpcr()!=control) fail("changed FPCR");
    if(fclose(af) || fclose(rf)) fail("close");
    printf("GP_SPV PASS cases=%d calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",number,calls,total_bytes,control);
    return 0;
}

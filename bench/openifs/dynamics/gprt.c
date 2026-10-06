/* Verify GPRT with independent product-rule balances and exact Fortran bytes.
 * Arrays hold FP64 values in Fortran order. R uses J/(kg K), T uses K,
 * RT uses m²/s² and gradients use the supplied coordinate scale.
 * Guard pages protect inputs and the final vector remainder. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#define GPRT_ARGS const int32_t *virt,const int32_t *np,const int32_t *ks, \
 const int32_t *ke,const int32_t *nl,const double *rd,const double *rv, \
 const double *r,const double *t,const double *tl,const double *tm, \
 const double *ql,const double *qm,double *h,double *hl,double *hm, \
 const double *rl,const double *rm
typedef void (*kernel)(GPRT_ARGS);
void gprt_(GPRT_ARGS);
void gprt_assembly_(GPRT_ARGS);
enum {R,T,TL,TM,QL,QM,RL,RM,NFIELDS};
typedef struct {
    void *map;
    size_t map_bytes,usable_bytes,count;
    double *data;
    int tail;
} buffer;
static const double guard=-777.75;
static uint64_t total_bytes,total_calls;

static void fail(const char *message) {
    fprintf(stderr,"GPRT check failed %s\n",message);
    exit(2);
}
static uint64_t bits(double value) {
    uint64_t result;
    memcpy(&result,&value,8);
    return result;
}
static uint64_t fpcr(void) {
    uint64_t value;
    __asm__ volatile("mrs %0,fpcr":"=r"(value));
    return value;
}
static buffer make_buffer(size_t count,int tail) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    size_t entries=count+2-(size_t)tail;
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
static void call(kernel fn,int mode,int32_t np,int32_t ks,int32_t ke,int32_t nl,
                 double rd,double rv,buffer fields[NFIELDS],buffer outputs[3]) {
    int32_t virt=mode==0 || mode==4 || mode==5;
    const double *rl=(mode==1 || mode==4 || mode==5)?fields[RL].data:NULL;
    const double *rm=(mode==1 || mode==3 || mode==4)?fields[RM].data:NULL;
    const double *ql=mode==2 || mode==3?fields[QL].data:NULL;
    const double *qm=mode==2 || mode==3?fields[QM].data:NULL;
    fn(&virt,&np,&ks,&ke,&nl,&rd,&rv,fields[R].data,fields[T].data,
       fields[TL].data,fields[TM].data,ql,qm,
       outputs[0].data,outputs[1].data,outputs[2].data,rl,rm);
}
static void check_case(int number,int mode,int32_t np,int32_t ks,int32_t ke,int32_t nl,
                       int pattern,int protected_tail,FILE *afile,FILE *rfile) {
    size_t count=(size_t)np*(size_t)nl;
    buffer fields[NFIELDS],a[3],r[3];
    double rd=256.0,rv=512.0;
    for(int f=0;f<NFIELDS;++f) fields[f]=make_buffer(count,protected_tail);
    for(int f=0;f<3;++f) {
        a[f]=make_buffer(count,protected_tail);
        r[f]=make_buffer(count,protected_tail);
    }
    for(size_t i=0;i<count;++i) {
        double q=0.125+(double)(i%4)/32.0;
        double temperature=256.0+(double)(i%7)*2.0;
        double tl=(double)((int)(i%5)-2)/16.0,tm=(double)((int)(i%3)-1)/8.0;
        double ql=1.0/1024.0,qm=-1.0/2048.0;
        if(pattern==1) tl=tm=ql=qm=0.0;
        fields[R].data[i]=rd+(rv-rd)*q;
        fields[T].data[i]=temperature;
        fields[QL].data[i]=ql;
        fields[QM].data[i]=qm;
        fields[RL].data[i]=(rv-rd)*ql;
        fields[RM].data[i]=(rv-rd)*qm;
        int virt=mode==0 || mode==4 || mode==5;
        fields[TL].data[i]=virt?(temperature*fields[RL].data[i]+fields[R].data[i]*tl)/rd:tl;
        fields[TM].data[i]=virt?(temperature*fields[RM].data[i]+fields[R].data[i]*tm)/rd:tm;
        if(pattern==2) {
            fields[T].data[i]=i%2?-0.0:0.0;
            fields[TL].data[i]=-0.0;
            fields[TM].data[i]=0.0;
            fields[QL].data[i]=-0.0;
            fields[QM].data[i]=0.0;
            fields[RL].data[i]=-0.0;
            fields[RM].data[i]=0.0;
        }
        if(pattern==3) {
            fields[T].data[i]=0x0.0000000000001p-1022;
            fields[TL].data[i]=-0x0.0000000000001p-1022;
            fields[TM].data[i]=0x0.0000000000001p-1022;
        }
        if(pattern==4) {
            fields[R].data[i]=1.0;
            fields[T].data[i]=1.0-0x1p-27;
            fields[TL].data[i]=-1.0;
            fields[RL].data[i]=1.0+0x1p-27;
            fields[TM].data[i]=1.0;
            fields[RM].data[i]=-1.0-0x1p-27;
        }
    }
    for(int f=0;f<NFIELDS;++f) readonly(&fields[f]);
    call(gprt_,mode,np,ks,ke,nl,rd,rv,fields,r);
    call(gprt_assembly_,mode,np,ks,ke,nl,rd,rv,fields,a);
    ++total_calls;
    for(int f=0;f<3;++f) {
        size_t entries=count+2-(size_t)protected_tail;
        for(size_t i=0;i<entries;++i) {
            double av=a[f].data[(ptrdiff_t)i-1],rvv=r[f].data[(ptrdiff_t)i-1];
            if(bits(av)!=bits(rvv)) {
                fprintf(stderr,"Mismatch stage=GPRT case=%d mode=%d field=%d level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                        number,mode,f,i?((i-1)/(size_t)np):0,i?((i-1)%(size_t)np+1):0,bits(av),bits(rvv));
                exit(1);
            }
            if(i==0 || i>count || (int32_t)((i-1)%(size_t)np+1)<ks || (int32_t)((i-1)%(size_t)np+1)>ke)
                if(bits(av)!=bits(guard)) fail("inactive output or guard");
        }
        if(fwrite(a[f].data-1,8,entries,afile)!=entries || fwrite(r[f].data-1,8,entries,rfile)!=entries) fail("trajectory write");
        total_bytes+=(uint64_t)entries*8;
    }
    for(int32_t j=0;j<nl;++j) for(int32_t i=ks-1;i<ke;++i) {
        size_t k=(size_t)j*(size_t)np+(size_t)i;
        long double gas=fields[R].data[k],temperature=fields[T].data[k];
        long double expected[3]={gas*temperature,0.0L,0.0L};
        for(int direction=0;direction<2;++direction) {
            long double dt=fields[TL+direction].data[k];
            if(mode==0 || mode==4 || mode==5) expected[direction+1]=(long double)rd*dt;
            else {
                long double dg=mode==1?fields[RL+direction].data[k]:
                    ((long double)rv-rd)*fields[QL+direction].data[k];
                expected[direction+1]=temperature*dg+gas*dt;
            }
        }
        for(int f=0;f<3;++f) {
            long double error=fabsl((long double)a[f].data[k]-expected[f]);
            long double tolerance=64.0L*DBL_EPSILON*fmaxl(1.0L,fabsl(expected[f]));
            if(!isfinite(a[f].data[k]) || error>tolerance) fail("independent product rule");
        }
        if(pattern==4 && bits(a[1].data[k])!=0) fail("separate-rounding witness");
    }
    for(int f=0;f<NFIELDS;++f) release(&fields[f]);
    for(int f=0;f<3;++f) {release(&a[f]);release(&r[f]);}
}
int main(int argc,char **argv) {
    if(argc!=3) fail("two output paths required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    if(hook) *hook=0;
    uint64_t control=fpcr();
    if(control & UINT64_C(0x03c80000)) fail("FPCR rounding or underflow");
    FILE *afile=fopen(argv[1],"wb"),*rfile=fopen(argv[2],"wb");
    if(!afile || !rfile) fail("output open");
    const int32_t shapes[][4]={{1,1,1,0},{1,1,1,1},{1,1,1,19},{7,2,6,5},
        {9,1,9,19},{13,13,13,20},{3,2,1,7},{2,1,2,1},{5,1,5,3}};
    int number=0;
    for(size_t c=0;c<sizeof shapes/sizeof shapes[0];++c)
        for(int mode=0;mode<6;++mode)
            check_case(++number,mode,shapes[c][0],shapes[c][1],shapes[c][2],shapes[c][3],c==1?1:0,0,afile,rfile);
    for(int pattern=2;pattern<=3;++pattern) for(int mode=0;mode<6;++mode)
        check_case(++number,mode,3,1,3,4,pattern,0,afile,rfile);
    check_case(++number,1,3,1,3,2,4,0,afile,rfile);
    for(int mode=0;mode<6;++mode) check_case(++number,mode,3,1,3,1,0,1,afile,rfile);
    if(fpcr()!=control) fail("changed FPCR");
    if(fclose(afile) || fclose(rfile)) fail("output close");
    printf("GPRT PASS cases=%d calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",
           number,total_calls,total_bytes,control);
    return 0;
}

/* Verify complete GPMKTEND state-change rates and unchanged buffer entries.
 * Wind states use m/s, temperature uses K, and tracer fractions use kg/kg.
 * A tendency is a change per second. Read-only pages protect earlier states. */
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
#define GPMKTEND_ARGS const void *geometry,const void *gfl,const int32_t *ks, \
 const int32_t *ke,const double *dt,double *u,double *v,double *t,double *q, \
 const double *u9,const double *v9,const double *t9,const double *q9,double *qd
typedef void (*kernel)(GPMKTEND_ARGS);
void gpmktend_(GPMKTEND_ARGS);
void gpmktend_assembly_(GPMKTEND_ARGS);
typedef struct {void *map;size_t map_bytes,usable_bytes,count;double *data;int tail;} buffer;
static const double guard=-777.75;
static uint64_t total_bytes,total_calls;
static void fail(const char *message) {
    fprintf(stderr,"GPMKTEND check failed %s\n",message);exit(2);
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
static void set_integer(void *object,size_t offset,int32_t value) {
    memcpy((char *)object+offset,&value,4);
}
static void call(kernel fn,const void *geometry,const void *gfl,int32_t ks,int32_t ke,
                 double dt,buffer earlier[4],buffer out[5],int no_tracers) {
    fn(geometry,gfl,&ks,&ke,&dt,out[0].data,out[1].data,out[2].data,
       no_tracers?NULL:out[3].data,earlier[0].data,earlier[1].data,earlier[2].data,
       no_tracers?NULL:earlier[3].data,no_tracers?NULL:out[4].data);
}
static void check_case(int number,int mode,int32_t np,int32_t ks,int32_t ke,
                       int32_t nl,int pattern,int tail,int trajectory,FILE *af,FILE *rf) {
    size_t cells=(size_t)np*(size_t)nl,tracers=mode==3?0:4,full=cells*tracers;
    int32_t descriptors=mode==3?0:mode==0?3:mode==4?2:4;
    int32_t active[4]={1,1,1,0},target[4]={1,2,3,-19},old[4]={1,2,3,-21};
    if(mode==1) {
        int32_t ta[4]={3,-19,1,4},oa[4]={4,-21,2,1},ac[4]={1,0,1,1};
        memcpy(target,ta,sizeof ta);memcpy(old,oa,sizeof oa);memcpy(active,ac,sizeof ac);
    } else if(mode==2) {
        for(int f=0;f<4;++f) {active[f]=0;target[f]=old[f]=-99;}
    } else if(mode==4) {
        target[0]=target[1]=1;old[0]=1;old[1]=2;
    }
    buffer geometry=make_buffer(17096/8,0),gfl=make_buffer(1359136/8,0);
    memset(geometry.data,0,17096);memset(gfl.data,0,1359136);
    set_integer(geometry.data,5144,np);set_integer(geometry.data,5224,nl);
    set_integer(gfl.data,0,descriptors);set_integer(gfl.data,48,(int32_t)tracers);
    set_integer(gfl.data,64,(int32_t)tracers);
    for(int d=0;d<descriptors;++d) {
        size_t offset=3848+(size_t)d*368;
        set_integer(gfl.data,offset+92,active[d]);set_integer(gfl.data,offset+188,target[d]);
        set_integer(gfl.data,offset+184,old[d]);
    }
    double dt=pattern==4?10.0:pattern==0?(trajectory>=0?3.0:8.0+(number%3)*1796.0):8.0;
    const double rate[3]={8.0,-4.0,2.0},base[3]={-16.0,24.0,288.0};
    int iteration=trajectory<0?0:trajectory;
    buffer earlier[4],a[5],r[5];
    for(int f=0;f<4;++f) earlier[f]=make_buffer(f==3?full:cells,tail);
    for(int f=0;f<5;++f) {a[f]=make_buffer(f>=3?full:cells,tail);r[f]=make_buffer(f>=3?full:cells,tail);}
    for(int f=0;f<3;++f) for(size_t k=0;k<cells;++k) {
        double before=base[f]+rate[f]*dt*iteration,after=before+rate[f]*dt;
        if(pattern==1) after=before;
        if(pattern==2) {before=f==1?-0.0:0.0;after=f==0?-0.0:0.0;}
        if(pattern==3) {before=0.0;after=f==1?-0x0.0000000000001p-1022:0x0.0000000000001p-1022;}
        if(pattern==4) {before=0.0;after=f==1?-3.0:3.0;}
        earlier[f].data[k]=before;a[f].data[k]=r[f].data[k]=after;
    }
    for(size_t f=0;f<tracers;++f) for(size_t k=0;k<cells;++k) {
        double qr=((f&1)?-1.0:1.0)*(double)(f+1)*0x1p-22;
        earlier[3].data[f*cells+k]=1.0/64.0+(double)f/1024.0+qr*dt*iteration;
        a[3].data[f*cells+k]=r[3].data[f*cells+k]=0.125+(double)f/128.0;
        a[4].data[f*cells+k]=r[4].data[f*cells+k]=guard;
    }
    for(int d=0;d<descriptors;++d) if(active[d]) for(size_t k=0;k<cells;++k) {
        size_t dest=((size_t)target[d]-1)*cells+k,source=((size_t)old[d]-1)*cells+k;
        double qr=((target[d]&1)?1.0:-1.0)*(double)target[d]*0x1p-22;
        double after=earlier[3].data[source]+qr*dt;
        if(mode==4) after=0.125;
        if(pattern==1) after=earlier[3].data[source];
        if(pattern==2) {earlier[3].data[source]=0.0;after=-0.0;}
        if(pattern==3) {earlier[3].data[source]=0.0;after=0x0.0000000000001p-1022;}
        if(pattern==4) {earlier[3].data[source]=0.0;after=3.0;}
        a[3].data[dest]=r[3].data[dest]=after;
    }
    double *incoming[5];
    for(int f=0;f<5;++f) {
        size_t entries=a[f].count+2-(size_t)tail;
        incoming[f]=malloc(entries*8);
        if(!incoming[f]) fail("incoming copy");
        memcpy(incoming[f],a[f].data-1,entries*8);
    }
    readonly(&geometry);readonly(&gfl);
    for(int f=0;f<4;++f) readonly(&earlier[f]);
    call(gpmktend_,geometry.data,gfl.data,ks,ke,dt,earlier,r,mode==3);
    call(gpmktend_assembly_,geometry.data,gfl.data,ks,ke,dt,earlier,a,mode==3);
    ++total_calls;
    for(int f=0;f<5;++f) {
        size_t entries=a[f].count+2-(size_t)tail;
        for(size_t k=0;k<entries;++k) {
            double av=a[f].data[(ptrdiff_t)k-1],rv=r[f].data[(ptrdiff_t)k-1];
            if(bits(av)!=bits(rv)) {
                size_t cell=k && cells?(k-1)%cells:0;
                fprintf(stderr,"Mismatch stage=GPMKTEND case=%d mode=%d field=%d tracer=%zu level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                    number,mode,f,k && cells?(k-1)/cells+1:0,cell/(size_t)np+1,cell%(size_t)np+1,bits(av),bits(rv));exit(1);
            }
            int changed=0;
            if(k && k<=a[f].count && cells) {
                int32_t column=(int32_t)((k-1)%(size_t)np)+1;
                changed=column>=ks && column<=ke;
                if(f>=3) {
                    int selected=0;
                    int32_t tracer=(int32_t)((k-1)/cells)+1;
                    for(int d=0;d<descriptors;++d) if(active[d] && target[d]==tracer) selected=1;
                    changed=changed && selected;
                }
            }
            if(!changed && bits(av)!=bits(incoming[f][k])) fail("inactive entry or guard");
        }
        if(fwrite(a[f].data-1,8,entries,af)!=entries || fwrite(r[f].data-1,8,entries,rf)!=entries) fail("trajectory write");
        total_bytes+=(uint64_t)entries*8;
    }
    for(int32_t j=0;j<nl;++j) for(int32_t i=ks-1;i<ke;++i) {
        size_t k=(size_t)j*(size_t)np+(size_t)i;
        if(pattern<=1) for(int f=0;f<3;++f) {
            long double expected=pattern==1?0.0L:(long double)rate[f];
            if(fabsl((long double)a[f].data[k]-expected)>32.0L*DBL_EPSILON*fmaxl(1.0L,fabsl(expected))) fail("independent wind or temperature rate");
        }
        if(pattern==0 && mode!=4) for(int d=0;d<descriptors;++d) if(active[d]) {
            long double expected=((target[d]&1)?1.0L:-1.0L)*(long double)target[d]*0x1p-22L;
            size_t dest=((size_t)target[d]-1)*cells+k;
            if(fabsl((long double)a[3].data[dest]-expected)>32.0L*DBL_EPSILON) fail("independent tracer rate");
        }
        if(mode==4 && pattern==0) {
            long double before1=earlier[3].data[k],before2=earlier[3].data[cells+k];
            long double expected=(0.125L-before1-(long double)dt*before2)/((long double)dt*dt);
            if(fabsl((long double)a[3].data[k]-expected)>64.0L*DBL_EPSILON) fail("ordered repeated field");
        }
        if(pattern==4) {
            volatile double one=1.0,ten=10.0,three=3.0;
            volatile double reciprocal=one/ten;
            double multiplied=three*reciprocal,direct=three/ten;
            if(bits(multiplied)==bits(direct) || bits(a[0].data[k])!=bits(multiplied)) fail("reciprocal-multiplication witness");
        }
        for(int d=0;d<descriptors;++d) if(active[d]) {
            size_t dest=((size_t)target[d]-1)*cells+k;
            if(bits(a[3].data[dest])!=bits(a[4].data[dest])) fail("copied tracer rate");
        }
        for(int f=0;f<3;++f) if(!isfinite(a[f].data[k])) fail("finite tendency");
    }
    release(&geometry);release(&gfl);
    for(int f=0;f<4;++f) release(&earlier[f]);
    for(int f=0;f<5;++f) {free(incoming[f]);release(&a[f]);release(&r[f]);}
}
int main(int argc,char **argv) {
    if(argc!=3) fail("two output paths required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    if(hook) *hook=0;
    uint64_t control=fpcr();
    if(control & UINT64_C(0x03c80000)) fail("FPCR rounding or underflow");
    FILE *af=fopen(argv[1],"wb"),*rf=fopen(argv[2],"wb");
    if(!af || !rf) fail("output open");
    const int32_t shapes[][4]={{1,1,1,0},{1,1,1,1},{1,1,1,19},{7,2,6,5},
        {9,1,9,19},{13,13,13,20},{3,2,1,7},{2,1,2,1},{5,1,5,3}};
    int number=0;
    for(size_t c=0;c<sizeof shapes/sizeof shapes[0];++c) for(int mode=0;mode<5;++mode)
        check_case(++number,mode,shapes[c][0],shapes[c][1],shapes[c][2],shapes[c][3],c==1?1:0,0,-1,af,rf);
    for(int pattern=2;pattern<=4;++pattern) check_case(++number,1,3,1,3,4,pattern,0,-1,af,rf);
    for(int mode=0;mode<5;++mode) check_case(++number,mode,3,1,3,2,0,1,-1,af,rf);
    for(int iteration=0;iteration<16;++iteration) check_case(++number,1,5,2,4,3,0,0,iteration,af,rf);
    if(fpcr()!=control) fail("changed FPCR");
    if(fclose(af) || fclose(rf)) fail("output close");
    printf("GPMKTEND PASS cases=%d calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",number,total_calls,total_bytes,control);
    return 0;
}

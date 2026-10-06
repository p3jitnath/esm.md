/* Verify complete physics increments, vertical boundaries and output bytes.
 * Rates use m/s² for wind, K/s for temperature and kg/kg/s for tracers.
 * Read-only inputs and inaccessible final pages protect the buffer contract. */
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
#define GPADDSLPHY_ARGS const void *geometry,const void *physics,const void *gfl, \
 const int32_t *first,const int32_t *ks,const int32_t *ke,const double *dt, \
 const double *tend,const double *tracer,double *u,double *v,double *t,double *q
typedef void (*kernel)(GPADDSLPHY_ARGS);
void gpaddslphy_(GPADDSLPHY_ARGS);
void gpaddslphy_assembly_(GPADDSLPHY_ARGS);
typedef struct {void *map;size_t map_bytes,usable_bytes,count;double *data;int tail;} buffer;
static const double guard=-777.75;
static uint64_t total_bytes,total_calls;
static void fail(const char *message) {
    fprintf(stderr,"GPADDSLPHY check failed %s\n",message);exit(2);
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
static void call(kernel fn,const void *geometry,const void *physics,const void *gfl,
                 int32_t first,int32_t ks,int32_t ke,double dt,buffer rates[2],
                 buffer out[4],int unused,int no_selected,int no_tracers) {
    fn(geometry,physics,gfl,&first,&ks,&ke,&dt,unused?NULL:rates[0].data,
       unused || no_selected?NULL:rates[1].data,out[0].data,out[1].data,out[2].data,
       no_tracers?NULL:out[3].data);
}
static void check_case(int number,int mode,int32_t first,int32_t np,int32_t ks,
                       int32_t ke,int32_t nl,int32_t lower,int32_t upper,
                       int pattern,int tail,int iteration,FILE *af,FILE *rf) {
    size_t cells=(size_t)np*(size_t)nl,ns=(size_t)((int64_t)upper-lower+1);
    size_t slab=(size_t)np*ns,ndim=mode==3?0:4,nv=5;
    int32_t num=mode==3?0:mode==4?2:mode==0?3:4;
    int32_t selected[4]={1,1,1,0},field[4]={1,2,3,-99};
    int32_t indices[3]={1,2,3};
    if(mode==1) {
        int32_t ac[4]={1,0,1,1},ix[4]={3,-99,1,4};
        memcpy(selected,ac,sizeof ac);memcpy(field,ix,sizeof ix);
        indices[0]=5;indices[1]=2;indices[2]=4;
    } else if(mode==2) {
        for(int d=0;d<4;++d) {selected[d]=0;field[d]=-99;}
    } else if(mode==4) field[0]=field[1]=1;
    buffer geometry=make_buffer(17096/8,0),physics=make_buffer(360/8,0),gfl=make_buffer(1359136/8,0);
    memset(geometry.data,0,17096);memset(physics.data,0,360);memset(gfl.data,0,1359136);
    set_integer(geometry.data,5144,np);set_integer(geometry.data,5224,nl);
    set_integer(geometry.data,5244,lower);set_integer(geometry.data,5248,upper);
    set_integer(physics.data,64,first?0:(int32_t)nv);
    set_integer(physics.data,344,first?-31:indices[0]);
    set_integer(physics.data,348,first?-32:indices[1]);
    set_integer(physics.data,352,first?-33:indices[2]);
    set_integer(gfl.data,0,num);set_integer(gfl.data,72,(int32_t)ndim);
    for(int d=0;d<num;++d) {
        size_t offset=3848+(size_t)d*368;
        set_integer(gfl.data,offset+100,selected[d]);set_integer(gfl.data,offset+204,field[d]);
    }
    double dt=pattern==5?0.0:pattern==6?-0.0:pattern==4?1.0+0x1p-27:iteration>=0?8.0:8.0+(number%3)*1796.0;
    const double rate[3]={0.125,-0.0625,1.0/1024.0},base[3]={-16.0,24.0,288.0};
    int trajectory=iteration<0?0:iteration;
    buffer rates[2]={make_buffer(cells*nv,tail),make_buffer(cells*ndim,tail)},a[4],r[4];
    for(int f=0;f<4;++f) {a[f]=make_buffer(f==3?slab*ndim:slab,tail);r[f]=make_buffer(f==3?slab*ndim:slab,tail);}
    for(size_t k=0;k<cells*nv;++k) rates[0].data[k]=0.0;
    for(int f=0;f<3;++f) {
        double value=pattern==1?0.0:rate[f],state=base[f]+rate[f]*dt*trajectory;
        if(pattern==2) {value=f==1?-0.0:0.0;state=-0.0;}
        if(pattern==3) {value=f==1?-0x0.0000000000001p-1022:0x0.0000000000001p-1022;state=0.0;}
        if(pattern==4) {value=1.0-0x1p-27;state=-1.0;}
        if(pattern==6) state=-0.0;
        for(size_t k=0;k<cells;++k) rates[0].data[((size_t)indices[f]-1)*cells+k]=value;
        for(size_t k=0;k<slab;++k) a[f].data[k]=r[f].data[k]=state;
    }
    for(size_t f=0;f<ndim;++f) {
        double qr=(double)(f+1)*0x1p-24,state=0.0625+(double)f/128.0+qr*dt*trajectory;
        if(pattern==1) qr=0.0;
        if(pattern==2) {qr=-0.0;state=-0.0;}
        if(pattern==3) {qr=0x0.0000000000001p-1022;state=0.0;}
        if(pattern==4) {qr=1.0-0x1p-27;state=-1.0;}
        if(pattern==6) state=-0.0;
        for(size_t k=0;k<cells;++k) rates[1].data[f*cells+k]=qr;
        for(size_t k=0;k<slab;++k) a[3].data[f*slab+k]=r[3].data[f*slab+k]=state;
    }
    double *incoming[4];
    for(int f=0;f<4;++f) {
        size_t entries=a[f].count+2-(size_t)tail;
        incoming[f]=malloc(entries*8);if(!incoming[f]) fail("incoming copy");
        memcpy(incoming[f],a[f].data-1,entries*8);
    }
    readonly(&geometry);readonly(&physics);readonly(&gfl);readonly(&rates[0]);readonly(&rates[1]);
    int unused=first || nl==0 || ke<ks,no_selected=mode==2 || mode==3;
    call(gpaddslphy_,geometry.data,physics.data,gfl.data,first,ks,ke,dt,rates,r,unused,no_selected,mode==3);
    call(gpaddslphy_assembly_,geometry.data,physics.data,gfl.data,first,ks,ke,dt,rates,a,unused,no_selected,mode==3);
    ++total_calls;
    for(int f=0;f<4;++f) {
        size_t entries=a[f].count+2-(size_t)tail;
        for(size_t k=0;k<entries;++k) {
            double av=a[f].data[(ptrdiff_t)k-1],rv=r[f].data[(ptrdiff_t)k-1];
            if(bits(av)!=bits(rv)) {
                size_t local=k && slab?(k-1)%slab:0;
                fprintf(stderr,"Mismatch stage=GPADDSLPHY case=%d first=%d field=%d tracer=%zu level=%" PRId64 " column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                    number,first,f,k && slab?(k-1)/slab+1:0,(int64_t)(local/(size_t)np)+lower,local%(size_t)np+1,bits(av),bits(rv));exit(1);
            }
            int changed=0;
            if(!first && k && k<=a[f].count && slab) {
                size_t local=(k-1)%slab;
                int64_t level=(int64_t)(local/(size_t)np)+lower;
                int32_t column=(int32_t)(local%(size_t)np)+1;
                changed=level>=1 && level<=nl && column>=ks && column<=ke;
                if(f==3) {
                    int visits=0,tracer=(int)((k-1)/slab)+1;
                    for(int d=0;d<num;++d) if(selected[d] && field[d]==tracer) ++visits;
                    changed=changed && visits;
                }
            }
            if(!changed && bits(av)!=bits(incoming[f][k])) fail("boundary, inactive entry or guard");
        }
        if(fwrite(a[f].data-1,8,entries,af)!=entries || fwrite(r[f].data-1,8,entries,rf)!=entries) fail("trajectory write");
        total_bytes+=(uint64_t)entries*8;
    }
    if(!first) for(int32_t j=1;j<=nl;++j) for(int32_t i=ks-1;i<ke;++i) {
        size_t k=(size_t)(j-lower)*(size_t)np+(size_t)i;
        if(pattern<=1) {
            for(int f=0;f<3;++f) {
                long double expected=(long double)incoming[f][k+1]+(pattern==1?0.0L:(long double)rate[f]*dt);
                if(fabsl((long double)a[f].data[k]-expected)>64.0L*DBL_EPSILON*fmaxl(1.0L,fabsl(expected))) fail("independent wind or heating increment");
            }
            for(size_t f=0;f<ndim;++f) {
                int visits=0;
                for(int d=0;d<num;++d) if(selected[d] && field[d]==(int32_t)f+1) ++visits;
                size_t index=f*slab+k;
                long double expected=(long double)incoming[3][index+1]+(pattern==1?0.0L:(long double)visits*(f+1)*0x1p-24L*dt);
                if(fabsl((long double)a[3].data[index]-expected)>64.0L*DBL_EPSILON) fail("independent tracer increment");
            }
        }
        if(pattern==4) for(int f=0;f<3;++f) if(bits(a[f].data[k])!=0) fail("separate-rounding witness");
        if(pattern==5) for(int f=0;f<3;++f) if(bits(a[f].data[k])!=bits(incoming[f][k+1])) fail("zero interval");
        if(pattern==6) for(int f=0;f<3;++f) if(bits(a[f].data[k])!=(f==1?0:UINT64_C(0x8000000000000000))) fail("signed zero interval");
        for(int f=0;f<3;++f) if(!isfinite(a[f].data[k])) fail("finite updated state");
    }
    release(&geometry);release(&physics);release(&gfl);release(&rates[0]);release(&rates[1]);
    for(int f=0;f<4;++f) {free(incoming[f]);release(&a[f]);release(&r[f]);}
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
    for(size_t c=0;c<sizeof shapes/sizeof shapes[0];++c) for(int mode=0;mode<5;++mode) for(int32_t first=0;first<2;++first)
        check_case(++number,mode,first,shapes[c][0],shapes[c][1],shapes[c][2],shapes[c][3],c%2?-1:1,shapes[c][3]+(int32_t)(c%3),c==1?1:0,0,-1,af,rf);
    for(int pattern=2;pattern<=6;++pattern) for(int32_t first=0;first<2;++first)
        check_case(++number,1,first,3,1,3,4,0,5,pattern,0,-1,af,rf);
    for(int mode=0;mode<5;++mode) check_case(++number,mode,0,3,1,3,2,1,2,0,1,-1,af,rf);
    for(int iteration=0;iteration<12;++iteration) check_case(++number,1,0,5,2,4,3,0,4,0,0,iteration,af,rf);
    if(fpcr()!=control) fail("changed FPCR");
    if(fclose(af) || fclose(rf)) fail("output close");
    printf("GPADDSLPHY PASS cases=%d calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",number,total_calls,total_bytes,control);
    return 0;
}

/* Verify complete wind accelerations and their separate FP64 arithmetic.
 * Wind uses m/s, force uses m/s², and rotation and damping use 1/s.
 * Independent work checks test perpendicular rotation and dissipative damping. */
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
#define WIND_ARGS const void *geometry,void *gmv,const void *physics,const void *dyn, \
 const int32_t *ks,const int32_t *ke,const double *f,const double *l,const double *m, \
 const double *sl,const double *sm,const double *state,double *tu,double *tv,double *u0,double *v0
typedef void (*kernel)(WIND_ARGS);
void gp_tndlagadiab_uv_(WIND_ARGS);
void wind_tendency_assembly_(WIND_ARGS);
enum {F,L,M,SL,SM,STATE,NFIELDS};
typedef struct {void *map;size_t map_bytes,usable_bytes,count;double *data;int tail;} buffer;
static const double guard=-777.75;
static uint64_t total_bytes,total_calls;
static int32_t *plane;
static void fail(const char *message) {
    fprintf(stderr,"Wind tendency check failed %s\n",message);exit(2);
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
static void call(kernel fn,const void *geometry,void *gmv,const void *physics,const void *dyn,
                 int32_t ks,int32_t ke,int mode,buffer f[NFIELDS],buffer out[4],int empty) {
    fn(geometry,gmv,physics,dyn,&ks,&ke,empty?NULL:f[F].data,
       empty || mode!=3?NULL:f[L].data,empty || mode!=3?NULL:f[M].data,
       empty?NULL:f[SL].data,empty?NULL:f[SM].data,empty?NULL:f[STATE].data,
       out[0].data,out[1].data,out[2].data,out[3].data);
}
static void check_case(int number,int configuration,int alternate,int32_t np,int32_t ks,
                       int32_t ke,int32_t nl,int pattern,int tail,FILE *af,FILE *rf) {
    static const int32_t settings[][5]={{0,1,0,0,1},{1,1,0,1,2},{1,0,0,0,1},
        {1,0,0,0,2},{1,0,0,1,1},{1,1,1,1,2},{1,0,1,1,2}};
    const int32_t *s=settings[configuration];
    int mode=(!s[0] || s[2])?0:s[1]?1:(!s[3] && s[4]==1)?2:3;
    int32_t mu=alternate?4:1,mv=alternate==2?4:alternate?1:2,ndim=4;
    *plane=s[3];
    size_t cells=(size_t)np*(size_t)nl;
    int64_t lower=alternate==2?0:alternate?-1:1,upper=nl;
    size_t coefficients=(size_t)(upper-lower+1);
    buffer geometry=make_buffer(17096/8,0),gmv=make_buffer(1560/8,0);
    buffer physics=make_buffer(448/8,0),dyn=make_buffer(4720/8,0),coef=make_buffer(coefficients,tail);
    memset(geometry.data,0,17096);memset(gmv.data,0,1560);
    memset(physics.data,0,448);memset(dyn.data,0,4720);
    set_integer(geometry.data,5144,np);set_integer(geometry.data,5224,nl);set_integer(geometry.data,7520,s[4]);
    set_integer(gmv.data,992,ndim);set_integer(gmv.data,1012,mu);set_integer(gmv.data,1016,mv);
    set_integer(physics.data,24,s[2]);set_integer(dyn.data,2132,s[0]);set_integer(dyn.data,2136,s[1]);
    if(mode) {
        int64_t descriptor[8]={(int64_t)(intptr_t)coef.data,-lower,8,INT64_C(3302829850624),8,1,lower,upper};
        memcpy((char *)dyn.data+2368,descriptor,sizeof descriptor);
    }
    size_t sizes[NFIELDS]={(size_t)np,(size_t)np,(size_t)np,cells,cells,cells*(size_t)ndim};
    buffer f[NFIELDS],a[4],r[4];
    for(int field=0;field<NFIELDS;++field) {
        f[field]=make_buffer(sizes[field],tail);
        for(size_t k=0;k<sizes[field];++k) f[field].data[k]=0.0;
    }
    for(int field=0;field<4;++field) {a[field]=make_buffer(cells,tail);r[field]=make_buffer(cells,tail);}
    for(int32_t i=0;i<np;++i) {
        f[F].data[i]=(i&1)?-1.0/8192.0:1.0/8192.0;
        f[L].data[i]=0.6;f[M].data[i]=0.8;
        if(pattern==1 || pattern==5) f[F].data[i]=0.0;
        if(pattern==2) {f[F].data[i]=-0.0;f[L].data[i]=-0.0;f[M].data[i]=1.0;}
        if(pattern==3) f[F].data[i]=0x0.0000000000001p-1022;
        if(pattern==4) f[F].data[i]=1.0+0x1p-27;
    }
    for(size_t k=0;k<coefficients;++k) coef.data[k]=0.0;
    for(int32_t j=1;j<=nl;++j) {
        double coefficient=1.0/1024.0+(double)j/1048576.0;
        if(pattern==1 || pattern==4 || pattern==5 || pattern==6) coefficient=0.0;
        if(pattern==2) coefficient=-0.0;
        if(pattern==3) coefficient=0x0.0000000000001p-1022;
        coef.data[(size_t)((int64_t)j-lower)]=coefficient;
        for(int32_t i=0;i<np;++i) {
            size_t k=(size_t)(j-1)*(size_t)np+(size_t)i;
            double u=16.0+0.25*i,v=-8.0+0.125*j,sl=1.0/16.0,sm=-1.0/32.0;
            if(pattern==1) sl=sm=0.0;
            if(pattern==2) {u=-0.0;v=0.0;sl=-0.0;sm=0.0;}
            if(pattern==3) {u=1.0;v=-1.0;sl=sm=0.0;}
            if(pattern==4) {u=1.0;v=1.0-0x1p-27;sl=1.0;sm=0.0;}
            if(pattern==6) sl=sm=0.0;
            f[STATE].data[((size_t)mu-1)*cells+k]=u;f[STATE].data[((size_t)mv-1)*cells+k]=v;
            f[SL].data[k]=sl;f[SM].data[k]=sm;
        }
    }
    readonly(&geometry);readonly(&gmv);readonly(&physics);readonly(&dyn);readonly(&coef);
    for(int field=0;field<NFIELDS;++field) readonly(&f[field]);
    int empty=nl==0 || ke<ks;
    call(gp_tndlagadiab_uv_,geometry.data,gmv.data,physics.data,dyn.data,ks,ke,mode,f,r,empty);
    call(wind_tendency_assembly_,geometry.data,gmv.data,physics.data,dyn.data,ks,ke,mode,f,a,empty);
    ++total_calls;
    for(int field=0;field<4;++field) {
        size_t entries=cells+2-(size_t)tail;
        for(size_t k=0;k<entries;++k) {
            double av=a[field].data[(ptrdiff_t)k-1],rv=r[field].data[(ptrdiff_t)k-1];
            if(bits(av)!=bits(rv)) {
                fprintf(stderr,"Mismatch stage=wind case=%d mode=%d field=%d level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                    number,mode,field,k?(k-1)/(size_t)np+1:0,k?(k-1)%(size_t)np+1:0,bits(av),bits(rv));exit(1);
            }
            if(k==0 || k>cells || (int32_t)((k-1)%(size_t)np+1)<ks || (int32_t)((k-1)%(size_t)np+1)>ke)
                if(bits(av)!=bits(guard)) fail("inactive output or guard");
        }
        if(fwrite(a[field].data-1,8,entries,af)!=entries || fwrite(r[field].data-1,8,entries,rf)!=entries) fail("trajectory write");
        total_bytes+=(uint64_t)entries*8;
    }
    for(int32_t j=1;j<=nl;++j) for(int32_t i=ks-1;i<ke;++i) {
        size_t k=(size_t)(j-1)*(size_t)np+(size_t)i;
        long double u=f[STATE].data[((size_t)mu-1)*cells+k],v=f[STATE].data[((size_t)mv-1)*cells+k];
        long double force_u=0.0L,force_v=0.0L,coefficient=coef.data[(size_t)((int64_t)j-lower)];
        if(mode==1) {force_u=-coefficient*u;force_v=-coefficient*v;}
        if(mode==2) force_u=-coefficient*u;
        if(mode==3) {
            long double l=f[L].data[i],m=f[M].data[i],across=m*u-l*v;
            force_u=-coefficient*m*across;force_v=coefficient*l*across;
        }
        long double pressure_u=f[SL].data[k],pressure_v=f[SM].data[k],rotation=f[F].data[i];
        long double expected[4]={-pressure_u+force_u+rotation*v,-pressure_v+force_v-rotation*u,
            -pressure_u+force_u,-pressure_v+force_v};
        for(int field=0;field<4;++field) {
            long double tolerance=128.0L*DBL_EPSILON*fmaxl(1.0L,fabsl(expected[field]));
            if(!isfinite(a[field].data[k]) || fabsl((long double)a[field].data[k]-expected[field])>tolerance) fail("independent wind acceleration");
        }
        if(pattern==0 || pattern==5 || pattern==6) {
            long double coriolis_work=u*((long double)a[0].data[k]-a[2].data[k])+v*((long double)a[1].data[k]-a[3].data[k]);
            long double damping_work=u*((long double)a[2].data[k]+pressure_u)+v*((long double)a[3].data[k]+pressure_v);
            long double scale=fmaxl(1.0L,u*u+v*v),tolerance=256.0L*DBL_EPSILON*scale;
            if(fabsl(coriolis_work)>tolerance || damping_work>tolerance) fail("Coriolis work or damping sign");
            long double physical_work=u*force_u+v*force_v;
            if(fabsl(damping_work-physical_work)>tolerance) fail("independent damping work");
        }
        if(pattern==4 && bits(a[0].data[k])!=0) fail("separate-rounding witness");
    }
    if(*plane!=s[3]) fail("changed plane flag");
    release(&geometry);release(&gmv);release(&physics);release(&dyn);release(&coef);
    for(int field=0;field<NFIELDS;++field) release(&f[field]);
    for(int field=0;field<4;++field) {release(&a[field]);release(&r[field]);}
}
int main(int argc,char **argv) {
    if(argc!=3) fail("two output paths required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    if(hook) *hook=0;
    plane=dlsym(RTLD_DEFAULT,"__yomct0_MOD_lrplane");if(!plane) fail("plane flag");
    uint64_t control=fpcr();if(control & UINT64_C(0x03c80000)) fail("FPCR rounding or underflow");
    FILE *af=fopen(argv[1],"wb"),*rf=fopen(argv[2],"wb");if(!af || !rf) fail("output open");
    const int32_t shapes[][4]={{1,1,1,0},{1,1,1,1},{1,1,1,19},{7,2,6,5},
        {9,1,9,19},{13,13,13,20},{3,2,1,7},{2,1,2,1},{5,1,5,3}};
    int number=0;
    for(size_t c=0;c<sizeof shapes/sizeof shapes[0];++c) for(int configuration=0;configuration<6;++configuration) for(int alternate=0;alternate<2;++alternate)
        check_case(++number,configuration,alternate,shapes[c][0],shapes[c][1],shapes[c][2],shapes[c][3],c==1?1:0,0,af,rf);
    for(int pattern=2;pattern<=4;++pattern) for(int configuration=0;configuration<6;++configuration)
        check_case(++number,configuration,1,3,1,3,4,pattern,0,af,rf);
    for(int configuration=0;configuration<6;++configuration) check_case(++number,configuration,1,3,1,3,2,0,1,af,rf);
    check_case(++number,6,1,3,1,3,4,0,0,af,rf);
    for(int configuration=0;configuration<=3;configuration+=3) check_case(++number,configuration,2,3,1,3,4,0,0,af,rf);
    check_case(++number,0,1,3,1,3,4,5,0,af,rf);check_case(++number,3,1,3,1,3,4,6,0,af,rf);
    if(fpcr()!=control) fail("changed FPCR");
    if(fclose(af) || fclose(rf)) fail("output close");
    printf("WIND PASS cases=%d calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",number,total_calls,total_bytes,control);
    return 0;
}

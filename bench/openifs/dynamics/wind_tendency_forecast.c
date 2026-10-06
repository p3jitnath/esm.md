/* Compare all four horizontal-wind accelerations in the coarse forecast.
 * Whole outputs keep inactive caller bytes. The driver supplies no force.
 * Pressure, rotation and damping are calculated by each complete routine. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define WIND_ARGS const void *geometry,void *gmv,const void *physics,const void *dyn, \
 const int32_t *ks,const int32_t *ke,const double *f,const double *l,const double *m, \
 const double *sl,const double *sm,const double *state,double *tu,double *tv,double *u0,double *v0
typedef void (*kernel)(WIND_ARGS);
void wind_tendency_assembly_(WIND_ARGS);
static kernel reference;
static const int32_t *step,*plane;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,mode_calls[4];
static void fail(const char *message) {
    fprintf(stderr,"Wind forecast check failed %s\n",message);_Exit(2);
}
static int32_t integer(const void *object,size_t offset) {
    int32_t value;memcpy(&value,(const char *)object+offset,4);return value;
}
static int64_t long_integer(const void *object,size_t offset) {
    int64_t value;memcpy(&value,(const char *)object+offset,8);return value;
}
static uint64_t bits(double value) {
    uint64_t result;memcpy(&result,&value,8);return result;
}
static void write_bytes(FILE *file,const void *data,size_t count) {
    if(count && fwrite(data,1,count,file)!=count) fail("capture write");
}
static int overlap(const void *a,size_t na,const void *b,size_t nb) {
    uintptr_t pa=(uintptr_t)a,pb=(uintptr_t)b;
    if(pa>UINTPTR_MAX-na || pb>UINTPTR_MAX-nb) fail("buffer address overflow");
    return na && nb && pa<pb+nb && pb<pa+na;
}
__attribute__((destructor)) static void finish(void) {
    if(!ao) return;
    if(fclose(ao) || fclose(ro) || fclose(io)) fail("capture close");
    fprintf(stderr,"WIND FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 no_damping=%" PRIu64 " isotropic=%" PRIu64 " untilted=%" PRIu64 " tilted=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        calls,bytes,mode_calls[0],mode_calls[1],mode_calls[2],mode_calls[3],last_fpcr);
}
void gp_tndlagadiab_uv_(WIND_ARGS) {
    __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
    if(last_fpcr & UINT64_C(0x03c80000)) fail("floating-point control");
    if(!geometry || !gmv || !physics || !dyn || !ks || !ke) fail("configuration pointers");
    int32_t np=integer(geometry,5144),nl=integer(geometry,5224),nst=integer(geometry,7520);
    int32_t ndim=integer(gmv,992),mu=integer(gmv,1012),mv=integer(gmv,1016);
    int32_t lr=integer(dyn,2132),iso=integer(dyn,2136),leg=integer(physics,24);
    if(np<=0 || nl<0 || ndim<0 || *ks<1 || *ks>np || *ke<*ks-1 || *ke>np) fail("shape or interval");
    int active=nl>0 && *ke>=*ks;
    if(active && (mu<1 || mu>ndim || mv<1 || mv>ndim)) fail("wind field indices");
    if((size_t)np>(size_t)INT64_MAX/8/(nl?(size_t)nl:1)) fail("cell extent");
    size_t cells=(size_t)np*(size_t)nl,size=cells*8;
    if(ndim && cells>(size_t)INT64_MAX/8/(size_t)ndim) fail("wind extent");
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gp_tndlagadiab_uv_");
        if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);
        step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");plane=dlsym(RTLD_NEXT,"__yomct0_MOD_lrplane");
        if(!step || !plane) fail("forecast globals");
        ao=fopen("wind-assembly.bin","wb");ro=fopen("wind-fortran.bin","wb");io=fopen("wind-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    int32_t plane_before=*plane;
    int mode=(!lr || leg)?0:iso?1:(!plane_before && nst==1)?2:3;
    int64_t lower=0,upper=0;
    size_t coefficient_bytes=0,coefficient_first=0;
    const double *coefficient=NULL;
    if(mode && nl) {
        memcpy(&coefficient,(const char *)dyn+2368,sizeof coefficient);
        lower=long_integer(dyn,2416);upper=long_integer(dyn,2424);
        __int128 count=(__int128)upper-lower+1;
        if(!coefficient || ((uintptr_t)coefficient&7) || lower>1 || upper<nl ||
           count<0 || count>INT64_MAX/8 || long_integer(dyn,2408)!=1 ||
           long_integer(dyn,2384)!=8 || long_integer(dyn,2400)!=8 ||
           (__int128)long_integer(dyn,2376)!=-(__int128)lower) fail("coefficient allocation");
        coefficient_bytes=(size_t)count*8;coefficient_first=(size_t)((__int128)1-lower);
    }
    const double *inputs[7]={f,sl,sm,state,l,m,coefficient};
    size_t sizes[7]={(size_t)np*8,size,size,size*(size_t)ndim,(size_t)np*8,(size_t)np*8,coefficient_bytes};
    int used[7]={active,active,active,active,active && mode==3,active && mode==3,mode && nl};
    double *out[4]={tu,tv,u0,v0},*shadow[4];
    void *copies[7]={0};
    unsigned char geometry_before[17096],gmv_before[1560],physics_before[448],dyn_before[4720];
    memcpy(geometry_before,geometry,17096);memcpy(gmv_before,gmv,1560);
    memcpy(physics_before,physics,448);memcpy(dyn_before,dyn,4720);
    for(int field=0;field<4;++field) {
        if(size && (!out[field] || ((uintptr_t)out[field]&7))) fail("output storage");
        if(overlap(out[field],size,geometry,17096) || overlap(out[field],size,gmv,1560) ||
           overlap(out[field],size,physics,448) || overlap(out[field],size,dyn,4720)) fail("output overlaps configuration");
        for(int d=0;d<field;++d) if(overlap(out[field],size,out[d],size)) fail("outputs overlap");
        shadow[field]=malloc(size?size:8);if(!shadow[field]) fail("output copy");
        if(size) memcpy(shadow[field],out[field],size);
    }
    for(int field=0;field<7;++field) if(used[field]) {
        if(sizes[field] && (!inputs[field] || ((uintptr_t)inputs[field]&7))) fail("input storage");
        for(int d=0;d<4;++d) if(overlap(inputs[field],sizes[field],out[d],size)) fail("output overlaps input");
        copies[field]=malloc(sizes[field]?sizes[field]:8);if(!copies[field]) fail("input copy");
        if(sizes[field]) memcpy(copies[field],inputs[field],sizes[field]);
    }
    if(mode) for(int32_t j=1;j<=nl;++j)
        if(!isfinite(coefficient[coefficient_first+(size_t)j-1]) || coefficient[coefficient_first+(size_t)j-1]<0.0) fail("damping rate");
    if(active) for(int32_t j=0;j<nl;++j) for(int32_t i=*ks-1;i<*ke;++i) {
        size_t k=(size_t)j*(size_t)np+(size_t)i;
        if(!isfinite(f[i]) || !isfinite(sl[k]) || !isfinite(sm[k]) ||
           !isfinite(state[((size_t)mu-1)*cells+k]) || !isfinite(state[((size_t)mv-1)*cells+k])) fail("nonfinite active input");
        if(mode==3 && (!isfinite(l[i]) || !isfinite(m[i]))) fail("north direction");
    }
    ++calls;++mode_calls[mode];
    int32_t dims[12]={np,*ks,*ke,nl,ndim,mu,mv,lr,iso,leg,plane_before,nst};
    for(int field=0;field<3;++field) {
        FILE *file=field==0?ao:field==1?ro:io;
        write_bytes(file,&calls,8);write_bytes(file,step,4);write_bytes(file,dims,48);
        write_bytes(file,&lower,8);write_bytes(file,&upper,8);
    }
    for(int field=0;field<4;++field) write_bytes(io,out[field],size);
    for(int field=0;field<7;++field) if(used[field])
        write_bytes(io,field==6?coefficient+coefficient_first:inputs[field],field==6?(size_t)nl*8:sizes[field]);
    reference(geometry,gmv,physics,dyn,ks,ke,f,l,m,sl,sm,state,shadow[0],shadow[1],shadow[2],shadow[3]);
    wind_tendency_assembly_(geometry,gmv,physics,dyn,ks,ke,f,l,m,sl,sm,state,tu,tv,u0,v0);
    for(int field=0;field<4;++field) {
        for(size_t k=0;k<cells;++k) {
            if(bits(out[field][k])!=bits(shadow[field][k])) {
                fprintf(stderr,"Mismatch stage=wind step=%d call=%" PRIu64 " mode=%d field=%d level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                    *step,calls,mode,field,k/(size_t)np+1,k%(size_t)np+1,bits(out[field][k]),bits(shadow[field][k]));_Exit(1);
            }
            int32_t column=(int32_t)(k%(size_t)np)+1;
            if(column>=*ks && column<=*ke && !isfinite(out[field][k])) fail("nonfinite active output");
        }
        write_bytes(ao,out[field],size);write_bytes(ro,shadow[field],size);free(shadow[field]);
    }
    for(int field=0;field<7;++field) {
        if(used[field] && sizes[field] && memcmp(inputs[field],copies[field],sizes[field])) fail("changed input");
        free(copies[field]);
    }
    if(memcmp(geometry_before,geometry,17096) || memcmp(gmv_before,gmv,1560) ||
       memcmp(physics_before,physics,448) || memcmp(dyn_before,dyn,4720) || *plane!=plane_before) fail("changed configuration");
    uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));if(after!=last_fpcr) fail("changed FPCR");
    bytes+=76+4*(uint64_t)size;
}

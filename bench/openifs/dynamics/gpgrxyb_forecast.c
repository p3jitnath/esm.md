/* Compare complete pressure-gradient routines during the coarse forecast.
 * Capture every output byte and preserve input and configuration bytes.
 * Pressures use Pa and coefficients use 1/Pa. No stage is supplied here. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define GPGRXYB_ARGS const int32_t *np,const int32_t *ks,const int32_t *ke, \
 const int32_t *nl,const int32_t *save,const void *vab,const void *cver, \
 const double *pl,const double *pm,const double *xyb,double *der
typedef void (*kernel)(GPGRXYB_ARGS);
void gpgrxyb_assembly_(GPGRXYB_ARGS);
static kernel reference;
static const int32_t *step,*xi,*di,*caller_xi,*caller_di;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,mode_calls[4],coefficient_calls;
static void fail(const char *message) {
    fprintf(stderr,"GPGRXYB forecast check failed %s\n",message);_Exit(2);
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
    fprintf(stderr,"GPGRXYB FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 finite_element=%" PRIu64 " logarithmic=%" PRIu64 " approximate_1=%" PRIu64 " approximate_2=%" PRIu64 " coefficients=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        calls,bytes,mode_calls[0],mode_calls[1],mode_calls[2],mode_calls[3],coefficient_calls,last_fpcr);
}
void gpgrxyb_(GPGRXYB_ARGS) {
    __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
    if(last_fpcr & UINT64_C(0x03c80000)) fail("floating-point control");
    if(!vab || !cver || !np || !ks || !ke || !nl || !save) fail("configuration or scalar address");
    int32_t fe,nd;
    memcpy(&fe,(const char *)cver+52,4);memcpy(&nd,(const char *)cver+4,4);
    fe=fe!=0;
    if(*np<=0 || *nl<0 || *ks<1 || *ks>*np || *ke<*ks-1 || *ke>*np || (!fe && (nd<0 || nd>2))) fail("shape or mode");
    int mode=fe?0:nd+1,active=*nl>0 && *ke>=*ks;
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gpgrxyb_");
        if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);
        step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");
        xi=dlsym(RTLD_NEXT,"__intdyn_mod_MOD_yytxyb");di=dlsym(RTLD_NEXT,"__intdyn_mod_MOD_yytxybder");
        caller_xi=dlsym(RTLD_NEXT,"__intdyn_mod_MOD_yytxyb0");
        caller_di=dlsym(RTLD_NEXT,"__intdyn_mod_MOD_yytxybder0");
        if(!step || !xi || !di || !caller_xi || !caller_di) fail("forecast configuration");
        ao=fopen("gpgrxyb-assembly.bin","wb");ro=fopen("gpgrxyb-fortran.bin","wb");io=fopen("gpgrxyb-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    int used_x[7]={0,fe,fe || mode>1,mode>1,!0,mode==1,!fe};
    int used_d[9]={1,1,!fe,!fe,!fe,!fe,*save!=0,!fe && *save!=0,!fe && *save!=0};
    int32_t capacities[2]={caller_xi[7],caller_di[9]};
    if(xi[7]<=0 || di[9]<=0 || capacities[0]<=0 || capacities[1]<=0) fail("field count");
    if(active) {
        for(int f=0;f<7;++f) if(used_x[f] && (xi[f]<1 || xi[f]>xi[7] || xi[f]>capacities[0] || xi[f]!=caller_xi[f])) fail("input field index");
        for(int f=0;f<9;++f) if(used_d[f]) {
            if(di[f]<1 || di[f]>di[9] || di[f]>capacities[1] || di[f]!=caller_di[f]) fail("output field index");
            for(int g=0;g<f;++g) if(used_d[g] && di[g]==di[f]) fail("duplicate output field");
        }
    }
    size_t cells=(size_t)*np*(size_t)*nl;
    if(cells>(size_t)INT64_MAX/8/(size_t)capacities[0] || cells>(size_t)INT64_MAX/8/(size_t)capacities[1]) fail("buffer extent");
    size_t size=cells*(size_t)capacities[1]*8;
    const double *inputs[6]={pl,pm,xyb,NULL,NULL,NULL};
    size_t sizes[6]={(size_t)*np*8,(size_t)*np*8,cells*(size_t)capacities[0]*8,0,0,0};
    int used[6]={active,active,active,active && fe,active && !fe,active && mode==1};
    int64_t bounds[6]={0};const double *level_values[3]={NULL,NULL,NULL};
    const size_t offsets[3]={448,192,64};
    for(int f=0;f<3;++f) if(used[f+3]) {
        const char *descriptor=(const char *)vab+offsets[f];
        int64_t element,stride;
        memcpy(&inputs[f+3],descriptor,8);
        memcpy(&element,descriptor+16,8);memcpy(&stride,descriptor+40,8);
        memcpy(&bounds[2*f],descriptor+48,8);memcpy(&bounds[2*f+1],descriptor+56,8);
        int64_t lo=bounds[2*f],hi=bounds[2*f+1];
        if(!inputs[f+3] || element!=8 || stride!=1 || lo>1 || hi<*nl || lo==INT64_MIN ||
           hi-lo<0 || (uint64_t)(hi-lo)>(uint64_t)INT64_MAX/8-1) fail("coefficient allocation");
        sizes[f+3]=(size_t)(hi-lo+1)*8;
        level_values[f]=inputs[f+3]+(1-lo);
    }
    unsigned char vab_before[512],cver_before[216];int32_t xi_before[8],di_before[10];
    memcpy(vab_before,vab,512);memcpy(cver_before,cver,216);memcpy(xi_before,xi,32);memcpy(di_before,di,40);
    if(size && (!der || ((uintptr_t)der&7))) fail("output storage");
    if(overlap(der,size,vab,512) || overlap(der,size,cver,216)) fail("output overlaps configuration");
    double *shadow=malloc(size?size:8),*copies[6]={0};
    if(!shadow) fail("output copy allocation");
    if(size) memcpy(shadow,der,size);
    for(int f=0;f<6;++f) if(used[f]) {
        if(!inputs[f] || ((uintptr_t)inputs[f]&7) || overlap(der,size,inputs[f],sizes[f])) fail("input storage or overlap");
        copies[f]=malloc(sizes[f]?sizes[f]:8);if(!copies[f]) fail("input copy allocation");
        if(sizes[f]) memcpy(copies[f],inputs[f],sizes[f]);
    }
    if(active) for(int32_t j=0;j<*nl;++j) for(int32_t i=*ks-1;i<*ke;++i) {
        size_t k=(size_t)j*(size_t)*np+(size_t)i;
        if(!isfinite(pl[i]) || !isfinite(pm[i])) fail("nonfinite pressure gradient");
        for(int f=0;f<7;++f) if(used_x[f] && !isfinite(xyb[((size_t)xi[f]-1)*cells+k])) fail("nonfinite pressure input");
        if(mode>1 && xyb[((size_t)xi[2]-1)*cells+k]==0.0) fail("zero approximate depth");
        for(int f=0;f<3;++f) if(used[f+3] && !isfinite(level_values[f][j])) fail("nonfinite coefficient");
    }
    ++calls;++mode_calls[mode];if(*save) ++coefficient_calls;
    int32_t dims[7]={*np,*ks,*ke,*nl,fe,nd,*save};
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);write_bytes(file,step,4);write_bytes(file,dims,28);write_bytes(file,capacities,8);
        write_bytes(file,xi_before,32);write_bytes(file,di_before,40);write_bytes(file,bounds,48);
    }
    write_bytes(io,der,size);
    for(int f=0;f<3;++f) if(used[f]) write_bytes(io,inputs[f],sizes[f]);
    for(int f=0;f<3;++f) if(used[f+3]) write_bytes(io,level_values[f],(size_t)*nl*8);
    reference(np,ks,ke,nl,save,vab,cver,pl,pm,xyb,shadow);
    gpgrxyb_assembly_(np,ks,ke,nl,save,vab,cver,pl,pm,xyb,der);
    for(size_t k=0;k<size/8;++k) if(bits(der[k])!=bits(shadow[k])) {
        fprintf(stderr,"Mismatch stage=GPGRXYB step=%d call=%" PRIu64 " field=%zu level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
            *step,calls,k/cells+1,(k%cells)/(size_t)*np+1,k%(size_t)*np+1,bits(der[k]),bits(shadow[k]));_Exit(1);
    }
    if(active) for(int f=0;f<9;++f) if(used_d[f]) for(int32_t j=0;j<*nl;++j) for(int32_t i=*ks-1;i<*ke;++i)
        if(!isfinite(der[((size_t)di[f]-1)*cells+(size_t)j*(size_t)*np+(size_t)i])) fail("nonfinite gradient output");
    write_bytes(ao,der,size);write_bytes(ro,shadow,size);free(shadow);
    for(int f=0;f<6;++f) {
        if(copies[f] && sizes[f] && memcmp(inputs[f],copies[f],sizes[f])) fail("changed input bytes");
        free(copies[f]);
    }
    uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));
    if(memcmp(vab_before,vab,512) || memcmp(cver_before,cver,216) || memcmp(xi_before,xi,32) ||
       memcmp(di_before,di,40) || after!=last_fpcr) fail("changed configuration or FPCR");
    bytes+=168+size;
}

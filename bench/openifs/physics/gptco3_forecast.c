/* Compare complete pressure-weighted integrations inside the coarse forecast.
 * CPEDIA supplies moisture rates in 1/s, producing column rates in kg/m²/s. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define GPTCO3_ARGS const int32_t *np,const int32_t *ks,const int32_t *ke, \
 const int32_t *nl,const double *dp,const double *q,double *mass
typedef void (*kernel)(GPTCO3_ARGS);
void gptco3_assembly_(GPTCO3_ARGS);
static kernel reference;
static const int32_t *step;
static const double *gravity;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,signed_calls;
static void fail(const char *message) {
    fprintf(stderr,"GPTCO3 forecast check failed %s\n",message);_Exit(2);
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
    fprintf(stderr,"GPTCO3 FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 signed_calls=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        calls,bytes,signed_calls,last_fpcr);
}
void gptco3_(GPTCO3_ARGS) {
    __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
    if(last_fpcr & UINT64_C(0x03c80000)) fail("floating-point control");
    if(!np || !ks || !ke || !nl || *np<=0 || *nl<0 || *ks<1 || *ks>*np || *ke<*ks-1 || *ke>*np) fail("shape or interval");
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gptco3_");
        if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);
        step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");gravity=dlsym(RTLD_NEXT,"__yomcst_MOD_rg");
        if(!step || !gravity) fail("forecast configuration");
        ao=fopen("gptco3-assembly.bin","wb");ro=fopen("gptco3-fortran.bin","wb");io=fopen("gptco3-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    double g=*gravity;if(!isfinite(g) || g<=0.0) fail("gravity");
    size_t cells=(size_t)*np*(size_t)*nl;
    if(cells>(size_t)INT64_MAX/8) fail("buffer extent");
    size_t size=(size_t)*np*8,input_size=cells*8;
    int active=*nl>0 && *ke>=*ks;
    if(!mass || ((uintptr_t)mass&7)) fail("output storage");
    const double *inputs[2]={dp,q};
    double *shadow=malloc(size),*copies[2]={NULL,NULL};
    if(!shadow) fail("output copy allocation");
    memcpy(shadow,mass,size);
    if(active) for(int f=0;f<2;++f) {
        if(!inputs[f] || ((uintptr_t)inputs[f]&7) || overlap(mass,size,inputs[f],input_size)) fail("input storage or overlap");
        copies[f]=malloc(input_size?input_size:8);if(!copies[f]) fail("input copy allocation");
        if(input_size) memcpy(copies[f],inputs[f],input_size);
    }
    int signed_input=0;
    if(active) for(int32_t j=0;j<*nl;++j) for(int32_t i=*ks-1;i<*ke;++i) {
        size_t k=(size_t)j*(size_t)*np+(size_t)i;
        if(!isfinite(dp[k]) || !isfinite(q[k]) || dp[k]<0.0) fail("physical input");
        if(q[k]<0.0) signed_input=1;
    }
    ++calls;signed_calls+=(uint64_t)signed_input;
    int32_t dims[4]={*np,*ks,*ke,*nl};
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);write_bytes(file,step,4);write_bytes(file,dims,16);write_bytes(file,&g,8);
    }
    write_bytes(io,mass,size);
    if(active) {write_bytes(io,dp,input_size);write_bytes(io,q,input_size);}
    reference(np,ks,ke,nl,dp,q,shadow);
    gptco3_assembly_(np,ks,ke,nl,dp,q,mass);
    for(size_t i=0;i<(size_t)*np;++i) {
        if(bits(mass[i])!=bits(shadow[i])) {
            fprintf(stderr,"Mismatch stage=GPTCO3 step=%d call=%" PRIu64 " column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                *step,calls,i+1,bits(mass[i]),bits(shadow[i]));_Exit(1);
        }
        if((int32_t)i+1>=*ks && (int32_t)i+1<=*ke && !isfinite(mass[i])) fail("nonfinite column mass");
    }
    write_bytes(ao,mass,size);write_bytes(ro,shadow,size);free(shadow);
    for(int f=0;f<2;++f) {
        if(copies[f] && input_size && memcmp(inputs[f],copies[f],input_size)) fail("changed input bytes");
        free(copies[f]);
    }
    uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));
    if(bits(*gravity)!=bits(g) || after!=last_fpcr) fail("changed gravity or FPCR");
    bytes+=36+size;
}

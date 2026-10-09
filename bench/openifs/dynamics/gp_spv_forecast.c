/* Compare the full GP_SPV body inside the coarse forecast.
 * Surface pressure uses Pa and gradients use the caller's coordinate scale. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SPV_ARGS const void *g,const void *d,const void *a,const void *s, \
 const int32_t *tl,const int32_t *ks,const int32_t *ke, \
 const double *p0,const double *p0l,const double *p0m, \
 const double *p9,const double *p9l,const double *p9m, \
 double *r0,double *r0l,double *r0m,double *r9,double *r9l,double *r9m
typedef void (*kernel)(SPV_ARGS);
void gp_spv_assembly_(SPV_ARGS);
static kernel reference;
static const int32_t *step;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,previous_calls,last_fpcr;
static void fail(const char *message) {
    fprintf(stderr,"GP_SPV forecast check failed %s\n",message);_Exit(2);
}
static int32_t integer(const void *obj,size_t offset) {
    int32_t n;memcpy(&n,(const char *)obj+offset,4);return n;
}
static uint64_t bits(double x) {uint64_t n;memcpy(&n,&x,8);return n;}
static void write_bytes(FILE *f,const void *p,size_t n) {
    if(n && fwrite(p,1,n,f)!=n) fail("capture write");
}
static int overlap(const void *p,size_t n,const void *q,size_t m) {
    uintptr_t a=(uintptr_t)p,b=(uintptr_t)q;
    if(a>UINTPTR_MAX-n || b>UINTPTR_MAX-m) fail("address overflow");
    return n && m && a<b+m && b<a+n;
}
__attribute__((destructor)) static void finish(void) {
    if(!ao) return;
    if(fclose(ao) || fclose(ro) || fclose(io)) fail("capture close");
    fprintf(stderr,"GP_SPV FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 previous_calls=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        calls,bytes,previous_calls,last_fpcr);
}
void gp_spv_(SPV_ARGS) {
    __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
    if(last_fpcr&UINT64_C(0x03c80000)) fail("floating-point control");
    if(!g || !d || !a || !s || !tl || !ks || !ke) fail("configuration pointers");
    int32_t np=integer(g,5144),nf=integer(g,5224),iteration=integer(d,2580);
    int32_t simple=integer(s,0),nh=integer(a,8),two=integer(a,20),full=integer(a,336);
    if(np<=0 || nf<0 || *ks<1 || *ks>np || *ke<*ks-1 || *ke>np) fail("shape or interval");
    if((*tl&~1) || (simple&~1) || (nh&~1) || (two&~1) || (full&~1)) fail("logical representation");
    int prev=(!*tl || simple || nh) && (!two || (iteration>0 && full)),active=*ke>=*ks;
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gp_spv_");if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");
        if(!step) fail("forecast step");
        ao=fopen("gp_spv-assembly.bin","wb");ro=fopen("gp_spv-fortran.bin","wb");io=fopen("gp_spv-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    size_t surface=(size_t)np*8,pressure=(size_t)np*((size_t)nf+1)*8;
    if(pressure>(size_t)INT64_MAX) fail("buffer extent");
    const double *inputs[6]={p0,p0l,p0m,p9,p9l,p9m};
    double *outputs[6]={r0,r0l,r0m,r9,r9l,r9m},*shadows[6],*copies[6]={0};
    size_t sizes[6]={pressure,surface,surface,pressure,surface,surface};
    const void *objects[4]={g,d,a,s};size_t object_sizes[4]={17096,4720,456,168};void *object_copies[4];
    for(int f=0;f<4;++f) {
        object_copies[f]=malloc(object_sizes[f]);if(!object_copies[f]) fail("object copy");
        memcpy(object_copies[f],objects[f],object_sizes[f]);
    }
    for(int f=0;f<6;++f) {
        if(!outputs[f] || ((uintptr_t)outputs[f]&7)) fail("output storage");
        shadows[f]=malloc(sizes[f]);if(!shadows[f]) fail("output copy");
        memcpy(shadows[f],outputs[f],sizes[f]);
        for(int j=0;j<f;++j) if(overlap(outputs[f],sizes[f],outputs[j],sizes[j])) fail("output overlap");
        if(active && (f<3 || prev)) {
            if(!inputs[f] || ((uintptr_t)inputs[f]&7)) fail("input storage");
            copies[f]=malloc(surface);if(!copies[f]) fail("input copy");
            memcpy(copies[f],inputs[f],surface);
            for(int j=0;j<6;++j) if(overlap(inputs[f],surface,outputs[j],sizes[j])) fail("input output overlap");
            for(int32_t i=*ks-1;i<*ke;++i) {
                if(!isfinite(inputs[f][i])) fail("finite input");
                if(f%3==0 && (inputs[f][i]<-745.0 || inputs[f][i]>709.0)) fail("logarithm range");
            }
        }
    }
    ++calls;previous_calls+=(uint64_t)(active && prev);
    int32_t header[8]={np,nf,*ks,*ke,*tl,prev,iteration,0};
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);write_bytes(file,step,4);write_bytes(file,header,32);
    }
    for(int f=0;f<6;++f) write_bytes(io,outputs[f],sizes[f]);
    if(active) for(int f=0;f<6;++f) if(f<3 || prev) write_bytes(io,inputs[f],surface);
    reference(g,d,a,s,tl,ks,ke,p0,p0l,p0m,p9,p9l,p9m,
              shadows[0],shadows[1],shadows[2],shadows[3],shadows[4],shadows[5]);
    gp_spv_assembly_(g,d,a,s,tl,ks,ke,p0,p0l,p0m,p9,p9l,p9m,r0,r0l,r0m,r9,r9l,r9m);
    for(int f=0;f<6;++f) {
        for(size_t k=0;k<sizes[f]/8;++k) {
            if(bits(outputs[f][k])!=bits(shadows[f][k])) {
                fprintf(stderr,"Mismatch stage=GP_SPV step=%d call=%" PRIu64 " time=%d field=%d row=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                    *step,calls,f>=3?9:0,f%3,k/(size_t)np,k%(size_t)np+1,bits(outputs[f][k]),bits(shadows[f][k]));_Exit(1);
            }
            if(active && (f<3 || prev) && (f%3 || k/(size_t)np==(size_t)nf) &&
               (int32_t)(k%(size_t)np)+1>=*ks && (int32_t)(k%(size_t)np)+1<=*ke &&
               (!isfinite(outputs[f][k]) || (f%3==0 && outputs[f][k]<=0.0))) fail("physical output");
        }
        write_bytes(ao,outputs[f],sizes[f]);write_bytes(ro,shadows[f],sizes[f]);free(shadows[f]);bytes+=sizes[f];
        if(copies[f] && memcmp(copies[f],inputs[f],surface)) fail("changed input");
        free(copies[f]);
    }
    for(int f=0;f<4;++f) {
        if(memcmp(object_copies[f],objects[f],object_sizes[f])) fail("changed configuration");
        free(object_copies[f]);
    }
    uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));if(after!=last_fpcr) fail("changed FPCR");
    bytes+=44;
}

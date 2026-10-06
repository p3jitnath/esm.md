/* Compare the complete pressure-force body during the coarse forecast.
 * RT uses m²/s². Inputs and outputs retain the model's coordinate scaling.
 * Selected inputs remain unchanged and all output bits are compared. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define GPGRP_ARGS const void *geometry,const int32_t *ks,const int32_t *ke, \
 const double *h,const double *gl,const double *gm,const double *pl,const double *pm, \
 const double *xyb,const double *der,const double *bhl,const double *bhm, \
 const double *bfl,const double *bfm,double *sl,double *sm
typedef void (*kernel)(GPGRP_ARGS);
void gpgrp_assembly_(GPGRP_ARGS);
static kernel reference;
static const int32_t *step,*xi,*di;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,mode_calls[2];
static void fail(const char *message) {
    fprintf(stderr,"GPGRP forecast check failed %s\n",message);_Exit(2);
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
    fprintf(stderr,"GPGRP FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 conventional=%" PRIu64 " finite_element=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        calls,bytes,mode_calls[0],mode_calls[1],last_fpcr);
}
void gpgrp_(GPGRP_ARGS) {
    __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
    if(last_fpcr & UINT64_C(0x03c80000)) fail("floating-point control");
    if(!geometry) fail("geometry object");
    int32_t np,nl,mode;
    const void *configuration;
    memcpy(&np,(const char *)geometry+5144,4);
    memcpy(&nl,(const char *)geometry+5224,4);
    memcpy(&configuration,(const char *)geometry+3264,sizeof configuration);
    if(!configuration) fail("vertical configuration");
    memcpy(&mode,(const char *)configuration+52,4);
    mode=mode!=0;
    if(np<=0 || nl<0 || *ks<1 || *ks>np || *ke<*ks-1 || *ke>np) fail("shape or interval");
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gpgrp_");
        if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);
        step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");
        xi=dlsym(RTLD_NEXT,"__intdyn_mod_MOD_yytxyb");
        di=dlsym(RTLD_NEXT,"__intdyn_mod_MOD_yytxybder");
        if(!step || !xi || !di) fail("forecast configuration");
        ao=fopen("gpgrp-assembly.bin","wb");ro=fopen("gpgrp-fortran.bin","wb");io=fopen("gpgrp-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    if(xi[7]<=0 || (mode?(xi[4]<1 || xi[4]>xi[7]):
       (xi[3]<1 || xi[3]>xi[7] || di[9]<=0 || di[4]<1 || di[4]>di[9] || di[5]<1 || di[5]>di[9]))) fail("field index");
    size_t count=(size_t)np*(size_t)nl,half=(size_t)np*((size_t)nl+1);
    if(count>(size_t)INT64_MAX/8/(size_t)xi[7] ||
       (!mode && count>(size_t)INT64_MAX/8/(size_t)di[9]) || half>(size_t)INT64_MAX/8) fail("buffer extent");
    size_t size=count*8;
    const double *inputs[11]={h,gl,gm,pl,pm,xyb,der,bhl,bhm,bfl,bfm};
    const int used[11]={1,!mode,!mode,mode,mode,1,!mode,!mode,!mode,mode,mode};
    size_t sizes[11]={size,size,size,(size_t)np*8,(size_t)np*8,size*(size_t)xi[7],
        !mode?size*(size_t)di[9]:0,half*8,half*8,size,size};
    double *out[2]={sl,sm},*shadow[2],*copies[11]={0};
    unsigned char geometry_before[17096],configuration_before[216];
    int32_t xi_before[8],di_before[10];
    memcpy(geometry_before,geometry,17096);memcpy(configuration_before,configuration,216);
    memcpy(xi_before,xi,32);memcpy(di_before,di,40);
    if(!sl || !sm || ((uintptr_t)sl&7) || ((uintptr_t)sm&7) || overlap(sl,size,sm,size)) fail("output storage");
    for(int f=0;f<2;++f) {
        shadow[f]=malloc(size?size:8);
        if(!shadow[f]) fail("output copy allocation");
        if(size) memcpy(shadow[f],out[f],size);
    }
    for(int f=0;f<11;++f) if(used[f]) {
        if(!inputs[f] || ((uintptr_t)inputs[f]&7)) fail("active input storage");
        for(int d=0;d<2;++d) if(overlap(out[d],size,inputs[f],sizes[f])) fail("output overlaps input");
        copies[f]=malloc(sizes[f]?sizes[f]:8);
        if(!copies[f]) fail("input copy allocation");
        if(sizes[f]) memcpy(copies[f],inputs[f],sizes[f]);
    }
    for(int32_t j=0;j<nl;++j) for(int32_t i=*ks-1;i<*ke;++i) {
        size_t k=(size_t)j*(size_t)np+(size_t)i;
        double values[8];
        if(mode) {
            values[0]=h[k];values[1]=xyb[((size_t)xi[4]-1)*count+k];
            values[2]=pl[i];values[3]=pm[i];values[4]=bfl[k];values[5]=bfm[k];
        } else {
            values[0]=h[k];values[1]=gl[k];values[2]=gm[k];
            values[3]=xyb[((size_t)xi[3]-1)*count+k];
            values[4]=der[((size_t)di[4]-1)*count+k];values[5]=der[((size_t)di[5]-1)*count+k];
            values[6]=bhl[k+(size_t)np];values[7]=bhm[k+(size_t)np];
        }
        for(int f=0;f<(mode?6:8);++f) if(!isfinite(values[f])) fail("nonfinite active input");
    }
    ++calls;++mode_calls[mode];
    int32_t dims[4]={np,*ks,*ke,nl};
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);write_bytes(file,step,4);write_bytes(file,dims,16);
        write_bytes(file,&mode,4);write_bytes(file,xi_before,32);write_bytes(file,di_before,40);
    }
    write_bytes(io,sl,size);write_bytes(io,sm,size);
    for(int f=0;f<11;++f) if(used[f]) write_bytes(io,inputs[f],sizes[f]);
    reference(geometry,ks,ke,h,gl,gm,pl,pm,xyb,der,bhl,bhm,bfl,bfm,shadow[0],shadow[1]);
    gpgrp_assembly_(geometry,ks,ke,h,gl,gm,pl,pm,xyb,der,bhl,bhm,bfl,bfm,sl,sm);
    for(int f=0;f<2;++f) {
        for(size_t k=0;k<count;++k) {
            if(bits(out[f][k])!=bits(shadow[f][k])) {
                fprintf(stderr,"Mismatch stage=GPGRP step=%d call=%" PRIu64 " field=%d level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                    *step,calls,f,k/(size_t)np+1,k%(size_t)np+1,bits(out[f][k]),bits(shadow[f][k]));_Exit(1);
            }
            int32_t column=(int32_t)(k%(size_t)np)+1;
            if(column>=*ks && column<=*ke && !isfinite(out[f][k])) fail("nonfinite active output");
        }
        write_bytes(ao,out[f],size);write_bytes(ro,shadow[f],size);free(shadow[f]);
    }
    for(int f=0;f<11;++f) {
        if(copies[f] && sizes[f] && memcmp(inputs[f],copies[f],sizes[f])) fail("changed input bytes");
        free(copies[f]);
    }
    if(memcmp(geometry_before,geometry,17096) || memcmp(configuration_before,configuration,216) ||
       memcmp(xi_before,xi,32) || memcmp(di_before,di,40)) fail("changed geometry or indices");
    bytes+=104+2*size;
}

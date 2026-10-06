/* Compare all GPMKTEND rates inside the coarse forecast.
 * The driver records whole arrays, including inactive columns and tracers.
 * It supplies no state update. Rates retain each state's unit per second. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define GPMKTEND_ARGS const void *geometry,const void *gfl,const int32_t *ks, \
 const int32_t *ke,const double *dt,double *u,double *v,double *t,double *q, \
 const double *u9,const double *v9,const double *t9,const double *q9,double *qd
typedef void (*kernel)(GPMKTEND_ARGS);
void gpmktend_assembly_(GPMKTEND_ARGS);
static kernel reference;
static const int32_t *step;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,selected_calls;
static void fail(const char *message) {
    fprintf(stderr,"GPMKTEND forecast check failed %s\n",message);_Exit(2);
}
static int32_t integer(const void *object,size_t offset) {
    int32_t value;memcpy(&value,(const char *)object+offset,4);return value;
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
    fprintf(stderr,"GPMKTEND FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 selected_descriptor_calls=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        calls,bytes,selected_calls,last_fpcr);
}
void gpmktend_(GPMKTEND_ARGS) {
    __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
    if(last_fpcr & UINT64_C(0x03c80000)) fail("floating-point control");
    if(!geometry || !gfl || !ks || !ke || !dt) fail("configuration pointers");
    int32_t np=integer(geometry,5144),nl=integer(geometry,5224);
    int32_t num=integer(gfl,0),ndim=integer(gfl,48),ndim1=integer(gfl,64);
    if(np<=0 || nl<0 || ndim<0 || ndim1<0 || num<0 || num>2163 ||
       *ks<1 || *ks>np || *ke<*ks-1 || *ke>np || !isfinite(*dt) || *dt<=0.0 || !isfinite(1.0/ *dt)) fail("shape or interval");
    if((size_t)np>(size_t)INT64_MAX/8/(nl?(size_t)nl:1)) fail("cell extent");
    size_t cells=(size_t)np*(size_t)nl,size=cells*8;
    if((ndim && cells>(size_t)INT64_MAX/8/(size_t)ndim) ||
       (ndim1 && cells>(size_t)INT64_MAX/8/(size_t)ndim1)) fail("tracer extent");
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gpmktend_");
        if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);
        step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");
        if(!step) fail("forecast step");
        ao=fopen("gpmktend-assembly.bin","wb");ro=fopen("gpmktend-fortran.bin","wb");io=fopen("gpmktend-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    int32_t *descriptors=malloc((size_t)(num?num:1)*12);
    if(!descriptors) fail("descriptor copy");
    for(int32_t d=0;d<num;++d) {
        size_t offset=3848+(size_t)d*368;
        descriptors[3*d]=integer(gfl,offset+92);
        descriptors[3*d+1]=integer(gfl,offset+188);
        descriptors[3*d+2]=integer(gfl,offset+184);
        if(descriptors[3*d] && (descriptors[3*d+1]<1 || descriptors[3*d+1]>ndim1 ||
           descriptors[3*d+2]<1 || descriptors[3*d+2]>ndim)) fail("selected tracer index");
    }
    double *out[5]={u,v,t,q,qd},*shadow[5];
    const double *inputs[4]={u9,v9,t9,q9};
    size_t sizes[5]={size,size,size,size*(size_t)ndim1,size*(size_t)ndim1};
    size_t input_sizes[4]={size,size,size,size*(size_t)ndim};
    void *copies[4],*gfl_before=malloc(1359136);
    unsigned char geometry_before[17096];
    if(!gfl_before) fail("configuration copy");
    memcpy(geometry_before,geometry,17096);memcpy(gfl_before,gfl,1359136);
    for(int f=0;f<5;++f) {
        if(sizes[f] && (!out[f] || ((uintptr_t)out[f]&7))) fail("output storage");
        if(overlap(out[f],sizes[f],geometry,17096) || overlap(out[f],sizes[f],gfl,1359136)) fail("output overlaps configuration");
        for(int d=0;d<f;++d) if(overlap(out[f],sizes[f],out[d],sizes[d])) fail("outputs overlap");
        shadow[f]=malloc(sizes[f]?sizes[f]:8);
        if(!shadow[f]) fail("output copy");
        if(sizes[f]) memcpy(shadow[f],out[f],sizes[f]);
    }
    for(int f=0;f<4;++f) {
        if(input_sizes[f] && (!inputs[f] || ((uintptr_t)inputs[f]&7))) fail("input storage");
        for(int d=0;d<5;++d) if(overlap(inputs[f],input_sizes[f],out[d],sizes[d])) fail("output overlaps earlier state");
        copies[f]=malloc(input_sizes[f]?input_sizes[f]:8);
        if(!copies[f]) fail("earlier-state copy");
        if(input_sizes[f]) memcpy(copies[f],inputs[f],input_sizes[f]);
    }
    for(int32_t j=0;j<nl;++j) for(int32_t i=*ks-1;i<*ke;++i) {
        size_t k=(size_t)j*(size_t)np+(size_t)i;
        for(int f=0;f<3;++f) if(!isfinite(out[f][k]) || !isfinite(inputs[f][k])) fail("nonfinite active state");
        for(int32_t d=0;d<num;++d) if(descriptors[3*d]) {
            size_t target=((size_t)descriptors[3*d+1]-1)*cells+k,old=((size_t)descriptors[3*d+2]-1)*cells+k;
            if(!isfinite(q[target]) || !isfinite(q9[old])) fail("nonfinite selected tracer");
        }
    }
    ++calls;
    int32_t dims[7]={np,*ks,*ke,nl,ndim,ndim1,num};
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);write_bytes(file,step,4);write_bytes(file,dims,28);
        write_bytes(file,dt,8);write_bytes(file,descriptors,(size_t)num*12);
    }
    for(int f=0;f<5;++f) write_bytes(io,out[f],sizes[f]);
    for(int f=0;f<4;++f) write_bytes(io,inputs[f],input_sizes[f]);
    reference(geometry,gfl,ks,ke,dt,shadow[0],shadow[1],shadow[2],shadow[3],u9,v9,t9,q9,shadow[4]);
    gpmktend_assembly_(geometry,gfl,ks,ke,dt,u,v,t,q,u9,v9,t9,q9,qd);
    for(int f=0;f<5;++f) {
        size_t count=sizes[f]/8;
        for(size_t k=0;k<count;++k) if(bits(out[f][k])!=bits(shadow[f][k])) {
            size_t cell=cells?k%cells:0;
            fprintf(stderr,"Mismatch stage=GPMKTEND step=%d call=%" PRIu64 " field=%d tracer=%zu level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                *step,calls,f,cells?k/cells+1:0,cell/(size_t)np+1,cell%(size_t)np+1,bits(out[f][k]),bits(shadow[f][k]));_Exit(1);
        }
        write_bytes(ao,out[f],sizes[f]);write_bytes(ro,shadow[f],sizes[f]);
        bytes+=(uint64_t)sizes[f];free(shadow[f]);
    }
    for(int32_t j=0;j<nl;++j) for(int32_t i=*ks-1;i<*ke;++i) {
        size_t k=(size_t)j*(size_t)np+(size_t)i;
        for(int f=0;f<3;++f) if(!isfinite(out[f][k])) fail("nonfinite rate");
        for(int32_t d=0;d<num;++d) if(descriptors[3*d]) {
            size_t target=((size_t)descriptors[3*d+1]-1)*cells+k;
            if(!isfinite(q[target]) || bits(q[target])!=bits(qd[target])) fail("copied tracer rate");
        }
    }
    for(int f=0;f<4;++f) {
        if(input_sizes[f] && memcmp(inputs[f],copies[f],input_sizes[f])) fail("changed earlier state");
        free(copies[f]);
    }
    if(memcmp(geometry_before,geometry,17096) || memcmp(gfl_before,gfl,1359136)) fail("changed configuration");
    uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));
    if(after!=last_fpcr) fail("changed FPCR");
    for(int32_t d=0;d<num;++d) if(descriptors[3*d]) ++selected_calls;
    bytes+=48+(uint64_t)num*12;
    free(gfl_before);free(descriptors);
}

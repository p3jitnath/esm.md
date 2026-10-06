/* Verify complete physics increments in the upstream coarse forecast.
 * Whole output buffers include unchanged vertical boundaries and tracers.
 * The driver supplies no physical tendency and no transport stage. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define GPADDSLPHY_ARGS const void *geometry,const void *physics,const void *gfl, \
 const int32_t *first,const int32_t *ks,const int32_t *ke,const double *dt, \
 const double *tend,const double *tracer,double *u,double *v,double *t,double *q
typedef void (*kernel)(GPADDSLPHY_ARGS);
void gpaddslphy_assembly_(GPADDSLPHY_ARGS);
static kernel reference;
static const int32_t *step;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,first_calls,update_calls,selected_calls;
static void fail(const char *message) {
    fprintf(stderr,"GPADDSLPHY forecast check failed %s\n",message);_Exit(2);
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
    fprintf(stderr,"GPADDSLPHY FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 first_step=%" PRIu64 " update=%" PRIu64 " selected_descriptor_calls=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        calls,bytes,first_calls,update_calls,selected_calls,last_fpcr);
}
void gpaddslphy_(GPADDSLPHY_ARGS) {
    __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
    if(last_fpcr & UINT64_C(0x03c80000)) fail("floating-point control");
    if(!geometry || !physics || !gfl || !first || !ks || !ke || !dt) fail("configuration pointers");
    int32_t np=integer(geometry,5144),nl=integer(geometry,5224),lower=integer(geometry,5244),upper=integer(geometry,5248);
    int32_t nv=integer(physics,64),indices[3]={integer(physics,344),integer(physics,348),integer(physics,352)};
    int32_t num=integer(gfl,0),ndim=integer(gfl,72),is_first=*first!=0;
    int64_t ns=(int64_t)upper-lower+1;
    if(np<=0 || nl<0 || lower>1 || upper<nl || ns<0 || ndim<0 || nv<0 || num<0 || num>2163 ||
       *ks<1 || *ks>np || *ke<*ks-1 || *ke>np || !isfinite(*dt) || *dt<0.0) fail("shape or interval");
    if((size_t)np>(size_t)INT64_MAX/8/(nl?(size_t)nl:1) ||
       (size_t)np>(size_t)INT64_MAX/8/(ns?(size_t)ns:1)) fail("vertical extent");
    size_t cells=(size_t)np*(size_t)nl,slab=(size_t)np*(size_t)ns;
    if((nv && cells>(size_t)INT64_MAX/8/(size_t)nv) ||
       (ndim && (cells>(size_t)INT64_MAX/8/(size_t)ndim || slab>(size_t)INT64_MAX/8/(size_t)ndim))) fail("field extent");
    int active_update=!is_first && nl>0 && *ke>=*ks;
    if(active_update) for(int f=0;f<3;++f) if(indices[f]<1 || indices[f]>nv) fail("wind or temperature field");
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gpaddslphy_");
        if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);
        step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");
        if(!step) fail("forecast step");
        ao=fopen("gpaddslphy-assembly.bin","wb");ro=fopen("gpaddslphy-fortran.bin","wb");io=fopen("gpaddslphy-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    int32_t *descriptors=malloc((size_t)(num?num:1)*8);
    if(!descriptors) fail("descriptor copy");
    int has_selected=0;
    for(int32_t d=0;d<num;++d) {
        size_t offset=3848+(size_t)d*368;
        descriptors[2*d]=integer(gfl,offset+100);descriptors[2*d+1]=integer(gfl,offset+204);
        if(active_update && descriptors[2*d]) {
            has_selected=1;
            if(descriptors[2*d+1]<1 || descriptors[2*d+1]>ndim) fail("selected tracer field");
        }
    }
    size_t out_size=slab*8,sizes[4]={out_size,out_size,out_size,out_size*(size_t)ndim};
    const double *inputs[2]={tend,tracer};
    size_t input_sizes[2]={cells*8*(size_t)nv,cells*8*(size_t)ndim};
    int used[2]={active_update,has_selected};
    double *out[4]={u,v,t,q},*shadow[4];
    void *copies[2]={0},*gfl_before=malloc(1359136);
    unsigned char geometry_before[17096],physics_before[360];
    if(!gfl_before) fail("configuration copy");
    memcpy(geometry_before,geometry,17096);memcpy(physics_before,physics,360);memcpy(gfl_before,gfl,1359136);
    for(int f=0;f<4;++f) {
        if(sizes[f] && (!out[f] || ((uintptr_t)out[f]&7))) fail("output storage");
        if(overlap(out[f],sizes[f],geometry,17096) || overlap(out[f],sizes[f],physics,360) ||
           overlap(out[f],sizes[f],gfl,1359136)) fail("output overlaps configuration");
        for(int d=0;d<f;++d) if(overlap(out[f],sizes[f],out[d],sizes[d])) fail("outputs overlap");
        shadow[f]=malloc(sizes[f]?sizes[f]:8);
        if(!shadow[f]) fail("output copy");
        if(sizes[f]) memcpy(shadow[f],out[f],sizes[f]);
    }
    for(int f=0;f<2;++f) if(used[f]) {
        if(input_sizes[f] && (!inputs[f] || ((uintptr_t)inputs[f]&7))) fail("rate storage");
        for(int d=0;d<4;++d) if(overlap(inputs[f],input_sizes[f],out[d],sizes[d])) fail("output overlaps rate");
        copies[f]=malloc(input_sizes[f]?input_sizes[f]:8);
        if(!copies[f]) fail("rate copy");
        if(input_sizes[f]) memcpy(copies[f],inputs[f],input_sizes[f]);
    }
    if(active_update) for(int32_t j=1;j<=nl;++j) for(int32_t i=*ks-1;i<*ke;++i) {
        size_t source=(size_t)(j-1)*(size_t)np+(size_t)i,target=(size_t)((int64_t)j-lower)*(size_t)np+(size_t)i;
        for(int f=0;f<3;++f) if(!isfinite(out[f][target]) || !isfinite(tend[((size_t)indices[f]-1)*cells+source])) fail("nonfinite active state or rate");
        for(int32_t d=0;d<num;++d) if(descriptors[2*d]) {
            size_t field=(size_t)descriptors[2*d+1]-1;
            if(!isfinite(q[field*slab+target]) || !isfinite(tracer[field*cells+source])) fail("nonfinite tracer or rate");
        }
    }
    ++calls;
    if(is_first) ++first_calls;else ++update_calls;
    int32_t dims[10]={np,*ks,*ke,nl,lower,upper,nv,ndim,num,is_first};
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);write_bytes(file,step,4);write_bytes(file,dims,40);
        write_bytes(file,dt,8);write_bytes(file,indices,12);write_bytes(file,descriptors,(size_t)num*8);
    }
    for(int f=0;f<4;++f) write_bytes(io,out[f],sizes[f]);
    for(int f=0;f<2;++f) if(used[f]) write_bytes(io,inputs[f],input_sizes[f]);
    reference(geometry,physics,gfl,first,ks,ke,dt,tend,tracer,shadow[0],shadow[1],shadow[2],shadow[3]);
    gpaddslphy_assembly_(geometry,physics,gfl,first,ks,ke,dt,tend,tracer,u,v,t,q);
    for(int f=0;f<4;++f) {
        size_t count=sizes[f]/8;
        for(size_t k=0;k<count;++k) if(bits(out[f][k])!=bits(shadow[f][k])) {
            size_t local=slab?k%slab:0;
            fprintf(stderr,"Mismatch stage=GPADDSLPHY step=%d call=%" PRIu64 " field=%d tracer=%zu level=%" PRId64 " column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                *step,calls,f,slab?k/slab+1:0,(int64_t)(local/(size_t)np)+lower,local%(size_t)np+1,bits(out[f][k]),bits(shadow[f][k]));_Exit(1);
        }
        write_bytes(ao,out[f],sizes[f]);write_bytes(ro,shadow[f],sizes[f]);
        bytes+=(uint64_t)sizes[f];free(shadow[f]);
    }
    if(active_update) for(int32_t j=1;j<=nl;++j) for(int32_t i=*ks-1;i<*ke;++i) {
        size_t k=(size_t)((int64_t)j-lower)*(size_t)np+(size_t)i;
        for(int f=0;f<3;++f) if(!isfinite(out[f][k])) fail("nonfinite updated state");
        for(int32_t d=0;d<num;++d) if(descriptors[2*d] && !isfinite(q[((size_t)descriptors[2*d+1]-1)*slab+k])) fail("nonfinite updated tracer");
    }
    for(int f=0;f<2;++f) {
        if(used[f] && input_sizes[f] && memcmp(inputs[f],copies[f],input_sizes[f])) fail("changed rate");
        free(copies[f]);
    }
    if(memcmp(geometry_before,geometry,17096) || memcmp(physics_before,physics,360) ||
       memcmp(gfl_before,gfl,1359136)) fail("changed configuration");
    uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));
    if(after!=last_fpcr) fail("changed FPCR");
    if(active_update) for(int32_t d=0;d<num;++d) if(descriptors[2*d]) ++selected_calls;
    bytes+=72+(uint64_t)num*8;
    free(gfl_before);free(descriptors);
}

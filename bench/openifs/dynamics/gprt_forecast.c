/* Compare the complete GPRT body during the coarse OpenIFS forecast.
 * RT uses m²/s². Gradients retain the supplied horizontal coordinate scale.
 * The driver supplies no numerical stage and preserves incoming output bytes. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define GPRT_ARGS const int32_t *virt,const int32_t *np,const int32_t *ks, \
 const int32_t *ke,const int32_t *nl,const double *rd,const double *rv, \
 const double *r,const double *t,const double *tl,const double *tm, \
 const double *ql,const double *qm,double *h,double *hl,double *hm, \
 const double *rl,const double *rm
typedef void (*kernel)(GPRT_ARGS);
void gprt_assembly_(GPRT_ARGS);
static kernel reference;
static const int32_t *step;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,mode_calls[3];
static void fail(const char *message) {
    fprintf(stderr,"GPRT forecast check failed %s\n",message);
    _Exit(2);
}
static uint64_t bits(double value) {
    uint64_t result;
    memcpy(&result,&value,8);
    return result;
}
static void write_bytes(FILE *file,const void *data,size_t count) {
    if(count && fwrite(data,1,count,file)!=count) fail("capture write");
}
static int overlap(const void *a,const void *b,size_t count) {
    uintptr_t pa=(uintptr_t)a,pb=(uintptr_t)b;
    if(pa>UINTPTR_MAX-count || pb>UINTPTR_MAX-count) fail("buffer address overflow");
    return count && pa<pb+count && pb<pa+count;
}
__attribute__((destructor)) static void finish(void) {
    if(!ao) return;
    if(fclose(ao) || fclose(ro) || fclose(io)) fail("capture close");
    fprintf(stderr,"GPRT FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 virtual=%" PRIu64 " explicit=%" PRIu64 " moisture=%" PRIu64 " FPCR=%016" PRIx64 "\n",
            calls,bytes,mode_calls[0],mode_calls[1],mode_calls[2],last_fpcr);
}
void gprt_(GPRT_ARGS) {
    __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
    if(last_fpcr & UINT64_C(0x03c80000)) fail("floating-point control");
    if(*np<=0 || *nl<0 || *ks<1 || *ks>*np || *ke<*ks-1 || *ke>*np) fail("shape or interval");
    int mode=*virt?0:rl?1:2;
    if(mode==1 && !rm) fail("absent meridional gas derivative");
    if(!isfinite(*rd) || *rd<=0 || !isfinite(*rv) || *rv<=0) fail("gas constants");
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gprt_");
        if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);
        step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");
        if(!step) fail("forecast step");
        ao=fopen("gprt-assembly.bin","wb");
        ro=fopen("gprt-fortran.bin","wb");
        io=fopen("gprt-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    size_t count=(size_t)*np*(size_t)*nl;
    if(count>(size_t)INT64_MAX/8) fail("buffer extent");
    size_t size=count*8;
    const double *inputs[8]={r,t,tl,tm,ql,qm,rl,rm};
    double *outputs[3]={h,hl,hm},*shadow[3],*snapshots[8];
    for(int f=0;f<3;++f) {
        if(!outputs[f] || ((uintptr_t)outputs[f]&7)) fail("output alignment");
        for(int other=0;other<f;++other) if(overlap(outputs[f],outputs[other],size)) fail("overlapping outputs");
        for(int input=0;input<8;++input) if(inputs[input] && overlap(outputs[f],inputs[input],size)) fail("output overlaps input");
        shadow[f]=malloc(size?size:8);
        if(!shadow[f]) fail("output copy allocation");
        if(size) memcpy(shadow[f],outputs[f],size);
    }
    for(int f=0;f<8;++f) {
        if((f<4 || (mode==2 && (f==4 || f==5))) && !inputs[f]) fail("required active input");
        snapshots[f]=NULL;
        if(inputs[f]) {
            if((uintptr_t)inputs[f]&7) fail("input alignment");
            snapshots[f]=malloc(size?size:8);
            if(!snapshots[f]) fail("input copy allocation");
            if(size) memcpy(snapshots[f],inputs[f],size);
        }
    }
    for(int32_t j=0;j<*nl;++j) for(int32_t i=*ks-1;i<*ke;++i) {
        size_t k=(size_t)j*(size_t)*np+(size_t)i;
        for(int f=0;f<8;++f) {
            int used=f<4 || (mode==2 && (f==4 || f==5)) || (mode==1 && f>=6);
            if(used && !isfinite(inputs[f][k])) fail("nonfinite active input");
        }
        if(r[k]<=0 || t[k]<=0) fail("physical gas constant or temperature");
    }
    ++calls;
    ++mode_calls[mode];
    int32_t dims[4]={*np,*ks,*ke,*nl};
    uint32_t flags=(*virt?1U:0U)|(rl?2U:0U)|(rm?4U:0U)|(ql?8U:0U)|(qm?16U:0U);
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);
        write_bytes(file,step,4);
        write_bytes(file,dims,16);
        write_bytes(file,&flags,4);
    }
    write_bytes(io,rd,8);
    write_bytes(io,rv,8);
    for(int f=0;f<3;++f) write_bytes(io,outputs[f],size);
    for(int f=0;f<8;++f) if(inputs[f]) write_bytes(io,inputs[f],size);
    reference(virt,np,ks,ke,nl,rd,rv,r,t,tl,tm,ql,qm,shadow[0],shadow[1],shadow[2],rl,rm);
    gprt_assembly_(virt,np,ks,ke,nl,rd,rv,r,t,tl,tm,ql,qm,h,hl,hm,rl,rm);
    for(int f=0;f<3;++f) {
        for(size_t k=0;k<count;++k) {
            if(bits(outputs[f][k])!=bits(shadow[f][k])) {
                fprintf(stderr,"Mismatch stage=GPRT step=%d call=%" PRIu64 " field=%d level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                        *step,calls,f,k/(size_t)*np+1,k%(size_t)*np+1,bits(outputs[f][k]),bits(shadow[f][k]));
                _Exit(1);
            }
            int32_t column=(int32_t)(k%(size_t)*np)+1;
            if(column>=*ks && column<=*ke && !isfinite(outputs[f][k])) fail("nonfinite active output");
        }
        write_bytes(ao,outputs[f],size);
        write_bytes(ro,shadow[f],size);
        free(shadow[f]);
    }
    for(int f=0;f<8;++f) {
        if(snapshots[f] && size && memcmp(inputs[f],snapshots[f],size)) fail("changed input bytes");
        free(snapshots[f]);
    }
    bytes+=32+3*size;
}

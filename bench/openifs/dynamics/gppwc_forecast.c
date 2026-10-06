/* Check the complete pressure-layer water integral during OpenIFS.
 * The comparison supplies no model stage. FP64 arrays use Fortran order.
 * Fractions use kg/kg, pressure uses Pa and water mass uses kg/m². */
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define GPPWC_ARGS const int32_t *np,const int32_t *ks,const int32_t *kp,const int32_t *nl, \
 double *w,const double *q,const double *p
typedef void (*gppwc_kernel)(GPPWC_ARGS);
void gppwc_assembly_(GPPWC_ARGS);
static gppwc_kernel reference;
static const int32_t *step;
static const double *gravity;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,signed_calls;
static void fail(const char *message) {
    fprintf(stderr,"GPPWC forecast check failed %s\n",message);
    _Exit(2);
}
static uint64_t bits(double value) {
    uint64_t u;memcpy(&u,&value,8);return u;
}
static void write_bytes(FILE *file,const void *data,size_t size) {
    if(size && fwrite(data,1,size,file)!=size) fail("capture write");
}
static int overlap(const void *a,size_t na,const void *b,size_t nb) {
    uintptr_t pa=(uintptr_t)a,pb=(uintptr_t)b;
    if(pa>UINTPTR_MAX-na || pb>UINTPTR_MAX-nb) fail("buffer address overflow");
    return na && nb && pa<pb+nb && pb<pa+na;
}
__attribute__((destructor)) static void finish(void) {
    if(!ao) return;
    if(fclose(ao)||fclose(ro)||fclose(io)) fail("capture close");
    fprintf(stderr,"GPPWC FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 signed_calls=%" PRIu64 " FPCR=%016" PRIx64 "\n",calls,bytes,signed_calls,last_fpcr);
}
void gppwc_(GPPWC_ARGS) {
    __asm__ volatile("mrs %0, fpcr":"=r"(last_fpcr));
    if(last_fpcr & UINT64_C(0x03c80000)) fail("floating-point control");
    if(*np<=0 || *ks<1 || *ks>*np || *kp<*ks-1 || *kp>*np || *nl<0)
        fail("shape or interval");
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gppwc_");
        if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);
        step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");
        gravity=dlsym(RTLD_NEXT,"__yomcst_MOD_rg");
        if(!step||!gravity) fail("forecast configuration");
        ao=fopen("gppwc-assembly.bin","wb");
        ro=fopen("gppwc-fortran.bin","wb");
        io=fopen("gppwc-inputs.bin","wb");
        if(!ao||!ro||!io) fail("capture open");
    }
    size_t nq=(size_t)*np*(size_t)*nl;
    size_t nw=(size_t)*np*((size_t)*nl+1);
    if(nw>(size_t)INT64_MAX/8) fail("buffer size overflow");
    size_t wbytes=nw*8,qbytes=nq*8;
    if(!w || !p || (qbytes && !q) || ((uintptr_t)w&7) ||
       ((uintptr_t)p&7) || (qbytes && ((uintptr_t)q&7))) fail("buffer alignment");
    if(overlap(w,wbytes,p,wbytes)||overlap(w,wbytes,q,qbytes)) fail("output overlaps input");
    if(!isfinite(*gravity) || *gravity<=0) fail("gravity");
    int signed_input=0;
    for(int column=*ks-1;column<*kp;++column) {
        for(int level=0;level<=*nl;++level) {
            size_t i=(size_t)level*(size_t)*np+(size_t)column;
            if(!isfinite(p[i]) || p[i]<0) fail("pressure");
            if(level) {
                size_t previous=i-(size_t)*np;
                if(p[i]<p[previous] || !isfinite(q[previous])) {
                    fprintf(stderr,"GPPWC input violation step=%d call=%" PRIu64 " field=PQ cell=%zu p=%016" PRIx64 " p_previous=%016" PRIx64 " q=%016" PRIx64 "\n",
                      *step,calls+1,previous,bits(p[i]),bits(p[previous]),bits(q[previous]));
                    fail("pressure order or nonfinite layer quantity");
                }
                if(q[previous]<0) signed_input=1;
            }
        }
    }
    double *shadow=malloc(wbytes),*pressure_copy=malloc(wbytes),*fraction_copy=malloc(qbytes?qbytes:8);
    if(!shadow||!pressure_copy||!fraction_copy) fail("buffer allocation");
    memcpy(shadow,w,wbytes);memcpy(pressure_copy,p,wbytes);
    if(qbytes) memcpy(fraction_copy,q,qbytes);
    ++calls;
    signed_calls+=(uint64_t)signed_input;
    int32_t dims[4]={*np,*ks,*kp,*nl};
    uint32_t schema=1;
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);
        write_bytes(file,step,4);
        write_bytes(file,dims,16);
        write_bytes(file,&schema,4);
        write_bytes(file,gravity,8);
    }
    write_bytes(io,w,wbytes);write_bytes(io,q,qbytes);write_bytes(io,p,wbytes);
    reference(np,ks,kp,nl,shadow,q,p);
    gppwc_assembly_(np,ks,kp,nl,w,q,p);
    for(size_t i=0;i<nw;++i) {
        if(bits(w[i])!=bits(shadow[i])) {
            fprintf(stderr,"Mismatch stage=GPPWC step=%d call=%" PRIu64 " field=PWCH boundary=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
              *step,calls,i/(size_t)*np,i%(size_t)*np+1,bits(w[i]),bits(shadow[i]));
            _Exit(1);
        }
        int column=(int)(i%(size_t)*np)+1;
        if(column>=*ks && column<=*kp) {
            if(!isfinite(w[i])) fail("column-water admissibility");
            if(i<(size_t)*np && bits(w[i])!=0) fail("top water mass");
            if(i>=(size_t)*np) {
                size_t previous=i-(size_t)*np;
                if((q[previous]>=0 && w[i]<w[previous]) ||
                   (q[previous]<0 && w[i]>w[previous])) fail("layer contribution sign");
            }
        }
    }
    if(memcmp(p,pressure_copy,wbytes) || (qbytes && memcmp(q,fraction_copy,qbytes))) fail("changed input");
    write_bytes(ao,w,wbytes);write_bytes(ro,shadow,wbytes);
    bytes+=40+wbytes;
    free(shadow);free(pressure_copy);free(fraction_copy);
}

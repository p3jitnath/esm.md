/* Compare complete CTVTOT calls from the SCAN2M whole-GFL-block caller.
 * SUSC2C allocates GFL(NPROMA,NFLEVG,NDIM,NGPBLKS); SCAN2M passes one
 * contiguous block and a separate GMV temperature field. Temperature uses
 * kelvin, gas constants use J/(kg K), and fractions use kg/kg.
 * This driver supplies no numerical stage. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CTV_ARGS const void *geometry,const void *gfl_config,const int32_t *ks, \
 const int32_t *ke,double *temperature,const double *gfl
typedef void (*kernel)(CTV_ARGS);
void ctvtot_assembly_(CTV_ARGS);
static kernel reference;
static void (*reference_begin)(void),(*reference_end)(void);
static unsigned char **global_config;
static const double *constants[6];
static const int32_t *step;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,science_values,direct_dependencies,shadow_dependencies,last_fpcr;
static void fail(const char *message) {
    fprintf(stderr,"CTVTOT forecast check failed %s\n",message);_Exit(2);
}
static uint64_t bits(double x) {uint64_t u;memcpy(&u,&x,8);return u;}
static uint64_t fpcr(void) {uint64_t u;__asm__ volatile("mrs %0,fpcr":"=r"(u));return u;}
static int32_t integer(const void *p,size_t off) {
    int32_t v;memcpy(&v,(const char *)p+off,4);return v;
}
static double real_value(const void *p,size_t off) {
    double v;memcpy(&v,(const char *)p+off,8);return v;
}
static void *symbol(const char *name) {
    void *p=dlsym(RTLD_NEXT,name);if(!p) fail(name);return p;
}
static void *copy_bytes(const void *p,size_t n) {
    void *c=malloc(n?n:8);if(!c) fail("copy allocation");
    if(n) memcpy(c,p,n);
    return c;
}
static void write_bytes(FILE *f,const void *p,size_t n) {
    if(n && fwrite(p,1,n,f)!=n) fail("capture write");
}
static int overlap(const void *a,size_t na,const void *b,size_t nb) {
    uintptr_t pa=(uintptr_t)a,pb=(uintptr_t)b;
    if(pa>UINTPTR_MAX-na || pb>UINTPTR_MAX-nb) fail("buffer address overflow");
    return na && nb && pa<pb+nb && pb<pa+na;
}
static void unchanged(const void *geometry,const void *argument,const void *global,
                      const double *gfl,size_t gfl_bytes,const void *geo_before,
                      const void *arg_before,const void *global_before,
                      const void *gfl_before,const uint64_t values[6],uint64_t control) {
    if(fpcr()!=control) fail("changed FPCR");
    if(*global_config!=global) fail("changed global configuration pointer");
    if(memcmp(geometry,geo_before,17096) || memcmp(argument,arg_before,1359136) ||
       (global_before && memcmp(global,global_before,1359136)) ||
       (gfl_bytes && memcmp(gfl,gfl_before,gfl_bytes))) fail("changed declared input");
    for(int f=0;f<6;++f) if(bits(*constants[f])!=values[f]) fail("changed module constant");
}
__attribute__((destructor)) static void finish(void) {
    if(!ao) return;
    if(fclose(ao)||fclose(ro)||fclose(io)) fail("capture close");
    fprintf(stderr,"CTVTOT FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64
        " differing_bytes=0 science_values=%" PRIu64
        " native_GPRCP_dependencies=%" PRIu64 " source_shadow_GPRCP=%" PRIu64
        " paired_accounting_hooks=%d FPCR=%016" PRIx64 "\n",
        calls,bytes,science_values,direct_dependencies,shadow_dependencies,
        reference_begin!=NULL,last_fpcr);
}
void ctvtot_(CTV_ARGS) {
    last_fpcr=fpcr();
    if(last_fpcr&UINT64_C(0x03c80000)) fail("floating-point control");
    if(!geometry || !gfl_config || !ks || !ke || !temperature || !gfl)
        fail("argument addresses");
    if(!reference) {
        void *p=symbol("ctvtot_");memcpy(&reference,&p,sizeof reference);
        global_config=symbol("__yom_ygfl_MOD_ygfl");
        const char *names[6]={"__yomcst_MOD_rd","__yomcst_MOD_rv","__yomcst_MOD_rcpd",
                             "__yomcst_MOD_rcpv","__yomcst_MOD_rcw","__yomcst_MOD_rcs"};
        for(int f=0;f<6;++f) constants[f]=symbol(names[f]);
        step=symbol("__yomct3_MOD_nstep");
        void *begin=dlsym(RTLD_DEFAULT,"gprcp_forecast_reference_begin");
        void *end=dlsym(RTLD_DEFAULT,"gprcp_forecast_reference_end");
        if(begin && end) {
            memcpy(&reference_begin,&begin,sizeof reference_begin);
            memcpy(&reference_end,&end,sizeof reference_end);
        }
        ao=fopen("ctvtot-assembly.bin","wb");ro=fopen("ctvtot-fortran.bin","wb");
        io=fopen("ctvtot-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    const unsigned char *global=*global_config;
    if(!global) fail("global configuration");
    int32_t np=integer(geometry,5144),nl=integer(geometry,5224);
    int32_t capacity=integer(gfl_config,48),ndim=integer(global,48),nf=integer(global,0);
    if(np<=0 || nl<0 || *ks<1 || *ks>np || *ke<*ks-1 || *ke>np ||
       capacity<0 || capacity!=ndim || nf<0 || nf>2163)
        fail("shape, configuration or SCAN2M allocation");
    size_t n=(size_t)np*(size_t)nl;
    if(n>(size_t)INT64_MAX/8 ||
       (capacity && n>(size_t)INT64_MAX/8/(size_t)capacity)) fail("buffer extent");
    size_t output_bytes=n*8,gfl_bytes=output_bytes*(size_t)capacity;
    if(((uintptr_t)temperature&7) || ((uintptr_t)gfl&7) ||
       overlap(temperature,output_bytes,gfl,gfl_bytes) ||
       overlap(temperature,output_bytes,geometry,17096) ||
       overlap(temperature,output_bytes,gfl_config,1359136) ||
       overlap(temperature,output_bytes,global,1359136)) fail("storage or overlap");
    int selected=0;
    for(int32_t f=0;f<nf;++f) {
        const unsigned char *p=global+3848+(size_t)f*368;
        if(!integer(p,68)) continue;
        int32_t field=integer(p,168);
        double r=real_value(p,72),cp=real_value(p,80);
        if(field<1 || field>capacity || !isfinite(r) || r<0.0 ||
           !isfinite(cp) || cp<=0.0) fail("selected constituent");
        ++selected;
    }
    uint64_t constant_bits[6];
    for(int f=0;f<6;++f) {
        if(!isfinite(*constants[f]) || *constants[f]<=0.0) fail("physical constant");
        constant_bits[f]=bits(*constants[f]);
    }
    double *incoming=copy_bytes(temperature,output_bytes);
    double *shadow=copy_bytes(temperature,output_bytes);
    void *gfl_before=copy_bytes(gfl,gfl_bytes);
    void *geo_before=copy_bytes(geometry,17096);
    void *arg_before=copy_bytes(gfl_config,1359136);
    void *global_before=global==gfl_config?NULL:copy_bytes(global,1359136);
    ++calls;++shadow_dependencies;
    if(nl>0 && *ke>=*ks) ++direct_dependencies;
    int32_t dims[9]={np,*ks,*ke,nl,capacity,ndim,nf,selected,1};
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);write_bytes(file,step,4);
        write_bytes(file,dims,sizeof dims);
        for(int c=0;c<6;++c) write_bytes(file,constants[c],8);
    }
    for(int32_t f=0;f<nf;++f) {
        const unsigned char *p=global+3848+(size_t)f*368;
        write_bytes(io,p+68,4);write_bytes(io,p+168,4);
        write_bytes(io,p+72,8);write_bytes(io,p+80,8);
    }
    write_bytes(io,gfl,gfl_bytes);write_bytes(io,incoming,output_bytes);
    if(reference_begin) reference_begin();
    reference(geometry,gfl_config,ks,ke,shadow,gfl);
    if(reference_end) reference_end();
    unchanged(geometry,gfl_config,global,gfl,gfl_bytes,geo_before,arg_before,
              global_before,gfl_before,constant_bits,last_fpcr);
    ctvtot_assembly_(geometry,gfl_config,ks,ke,temperature,gfl);
    unchanged(geometry,gfl_config,global,gfl,gfl_bytes,geo_before,arg_before,
              global_before,gfl_before,constant_bits,last_fpcr);
    for(size_t k=0;k<n;++k) {
        if(bits(temperature[k])!=bits(shadow[k])) {
            fprintf(stderr,"Mismatch stage=CTVTOT step=%d call=%" PRIu64
                " field=PT level=%zu column=%zu assembly=%016" PRIx64
                " reference=%016" PRIx64 "\n",*step,calls,k/(size_t)np+1,
                k%(size_t)np+1,bits(temperature[k]),bits(shadow[k]));_Exit(1);
        }
        int32_t column=(int32_t)(k%(size_t)np)+1;
        if(column<*ks || column>*ke) {
            if(bits(temperature[k])!=bits(incoming[k])) fail("changed inactive PT");
            continue;
        }
        if(!isfinite(incoming[k])) fail("nonfinite virtual temperature");
        long double mass=0.0L,gas=0.0L,scale=0.0L;
        for(int32_t f=0;f<nf;++f) {
            const unsigned char *p=global+3848+(size_t)f*368;
            if(!integer(p,68)) continue;
            int32_t field=integer(p,168);
            double q=gfl[(size_t)(field-1)*n+k],r=real_value(p,72);
            if(!isfinite(q) || q<0.0) fail("invalid selected mass fraction");
            mass+=(long double)q;gas+=(long double)q*r;
            scale+=fabsl(((long double)r-*constants[0])*q);
        }
        if(mass>1.0L) fail("selected mass sum");
        long double rm=(1.0L-mass)* *constants[0]+gas;
        if(!(rm>0.0L)) fail("positive mixture constant");
        long double expected=(long double)*constants[0]*incoming[k]/rm;
        long double condition=1.0L+scale/rm;
        long double tolerance=(64.0L+8.0L*selected)*DBL_EPSILON*
            fmaxl(1.0L,fabsl(expected))*condition+16.0L*DBL_TRUE_MIN;
        if(!isfinite(temperature[k]) ||
           fabsl((long double)temperature[k]-expected)>tolerance)
            fail("independent dry or moist temperature identity");
        ++science_values;
    }
    write_bytes(ao,temperature,output_bytes);write_bytes(ro,shadow,output_bytes);
    bytes+=96+output_bytes;
    free(incoming);free(shadow);free(gfl_before);free(geo_before);free(arg_before);
    free(global_before);
}

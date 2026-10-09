/* Compare complete GPRCP calls inside OpenIFS, with no driver-side update.
 * Arrays are FP64 in Fortran order. Only requested outputs may change.
 * Frozen GNU 12.3 configuration offsets are defined in the md2asm contract. */
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define GPRCP_ARGS const int32_t *np,const int32_t *ks,const int32_t *kp,const int32_t *nl, \
 const double *q,const double *qi,const double *ql,const double *qr,const double *qs,const double *qg, \
 double *cp,double *r,double *kap,const double *gfl,const int32_t *kind,const int32_t *thermal
typedef void (*gprcp_kernel)(GPRCP_ARGS);
void gprcp_assembly_(GPRCP_ARGS);
static gprcp_kernel reference;
static unsigned char **configuration;
static const double *constants[6];
static const int32_t *step;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,genuine_calls,comparison_calls;
static _Thread_local uint32_t comparison_depth;
static const size_t water_slots[6]={799840,799848,799856,799920,799912,799928};
static void fail(const char *message) {
    fprintf(stderr,"GPRCP forecast check failed %s\n",message);
    _Exit(2);
}
/* Mark source calls made only to compare another complete assembly routine.
 * These markers change accounting, never model fields or numerical work. */
void gprcp_forecast_reference_begin(void) {
    if(comparison_depth==UINT32_MAX) fail("comparison depth overflow");
    ++comparison_depth;
}
void gprcp_forecast_reference_end(void) {
    if(!comparison_depth) fail("unbalanced comparison marker");
    --comparison_depth;
}
static void unchanged_inputs(const double *const input[7],double *const copy[7],
                             const size_t size[7],const char *stage) {
    for(int f=0;f<7;++f) if(copy[f] && memcmp(copy[f],input[f],size[f])) {
        size_t byte=0;
        while(byte<size[f] && ((const unsigned char *)copy[f])[byte]==
              ((const unsigned char *)input[f])[byte]) ++byte;
        size_t word=byte/8;
        uint64_t before,after;
        memcpy(&before,(const char *)copy[f]+word*8,8);
        memcpy(&after,(const char *)input[f]+word*8,8);
        fprintf(stderr,"Mismatch stage=GPRCP input after %s step=%d call=%" PRIu64
            " field=%d cell=%zu byte=%zu before=%016" PRIx64 " after=%016" PRIx64 "\n",
            stage,*step,calls,f,word,byte,before,after);
        fail("changed declared input");
    }
}
static void *symbol(const char *name) {
    void *p=dlsym(RTLD_NEXT,name);
    if(!p) fail(name);
    return p;
}
static uint64_t bits(double x) {
    uint64_t u;memcpy(&u,&x,8);return u;
}
static int32_t integer(const unsigned char *p,size_t offset) {
    int32_t value;memcpy(&value,p+offset,4);return value;
}
static int overlap(const void *a,size_t na,const void *b,size_t nb) {
    uintptr_t pa=(uintptr_t)a,pb=(uintptr_t)b;
    if(pa>UINTPTR_MAX-na || pb>UINTPTR_MAX-nb) fail("buffer address overflow");
    return na && nb && pa<pb+nb && pb<pa+na;
}
static void write_bytes(FILE *file,const void *data,size_t size) {
    if(size && fwrite(data,1,size,file)!=size) fail("capture write");
}
__attribute__((destructor)) static void finish(void) {
    if(!ao) return;
    if(fclose(ao)||fclose(ro)||fclose(io)) fail("capture close");
    fprintf(stderr,"GPRCP FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 genuine_calls=%" PRIu64 " comparison_calls=%" PRIu64 " FPCR=%016" PRIx64 "\n",calls,bytes,genuine_calls,comparison_calls,last_fpcr);
}
void gprcp_(GPRCP_ARGS) {
    const double *inputs[7]={q,qi,ql,qr,qs,qg,gfl};
    double *outputs[3]={cp,r,kap},*shadow[3]={0};
    double *copies[7]={0};
    size_t sizes[7];
    uint32_t present=0;
    __asm__ volatile("mrs %0, fpcr":"=r"(last_fpcr));
    if(last_fpcr & UINT64_C(0x03c80000)) fail("floating-point control");
    if(*np<=0 || *ks<1 || *ks>*np || *kp<*ks-1 || *kp>*np || *nl<0)
        fail("shape or interval");
    if(!reference) {
        void *p=symbol("gprcp_");
        memcpy(&reference,&p,sizeof reference);
        configuration=symbol("__yom_ygfl_MOD_ygfl");
        const char *names[6]={"__yomcst_MOD_rd","__yomcst_MOD_rv","__yomcst_MOD_rcpd",
                             "__yomcst_MOD_rcpv","__yomcst_MOD_rcw","__yomcst_MOD_rcs"};
        for(int f=0;f<6;++f) constants[f]=symbol(names[f]);
        step=symbol("__yomct3_MOD_nstep");
        ao=fopen("gprcp-assembly.bin","wb");
        ro=fopen("gprcp-fortran.bin","wb");
        io=fopen("gprcp-inputs.bin","wb");
        if(!ao||!ro||!io) fail("capture open");
    }
    if(!*configuration) fail("configuration object");
    int32_t ndim=integer(*configuration,48),numflds=integer(*configuration,0);
    int32_t map=kind?*kind:0,override=thermal?*thermal:-1;
    /* CPGLAG supplies NDIM1 fields for map 1. The observed map 0 and map 9
     * callers supply full NDIM blocks. Other modes need a caller audit first. */
    int32_t capacity=gfl?(map==1?integer(*configuration,64):ndim):0;
    if(gfl && (ndim<0 || capacity<0 || (map==1 && capacity>ndim) ||
       numflds<0 || numflds>2163 || !(map==0||map==1||map==9)))
        fail("unreviewed generic buffer or configuration");
    size_t n=(size_t)*np*(size_t)*nl;
    if(n>INT64_MAX/8 || (capacity && n>(size_t)INT64_MAX/8/(size_t)capacity))
        fail("buffer size overflow");
    size_t output_size=n*8;
    for(int f=0;f<7;++f) {
        sizes[f]=f==6?output_size*(size_t)capacity:output_size;
        if(inputs[f]) present|=UINT32_C(1)<<f;
        if(inputs[f] && sizes[f]) {
            if((uintptr_t)inputs[f]&7) fail("input alignment");
            copies[f]=malloc(sizes[f]);
            if(!copies[f]) fail("input copy allocation");
            memcpy(copies[f],inputs[f],sizes[f]);
        }
    }
    for(int f=0;f<3;++f) if(outputs[f]) {
        present|=UINT32_C(1)<<(7+f);
        if(output_size) {
            if((uintptr_t)outputs[f]&7) fail("output alignment");
            shadow[f]=malloc(output_size);
            if(!shadow[f]) fail("output copy allocation");
            memcpy(shadow[f],outputs[f],output_size);
        } else {
            shadow[f]=malloc(8);
            if(!shadow[f]) fail("empty output allocation");
        }
    }
    for(int a=0;a<3;++a) if(outputs[a]) {
        for(int b=a+1;b<3;++b) if(outputs[b] &&
           overlap(outputs[a],output_size,outputs[b],output_size)) fail("overlapping outputs");
        for(int b=0;b<7;++b) if(inputs[b] &&
           overlap(outputs[a],output_size,inputs[b],sizes[b])) fail("output overlaps input");
    }
    int32_t water_flags[6]={0};
    if(!gfl) for(int j=0;j<6;++j) {
        water_flags[j]=override;
        if(!thermal) {
            unsigned char *component;
            memcpy(&component,*configuration+water_slots[j],sizeof component);
            if(!component) fail("default water pointer");
            water_flags[j]=integer(component,68);
        }
    }
    for(int j=0;j<6;++j) if(!isfinite(*constants[j]) || *constants[j]<=0)
        fail("physical constant");
    for(int level=0;level<*nl;++level) for(int column=*ks-1;column<*kp;++column) {
        size_t cell=(size_t)level*(size_t)*np+(size_t)column;
        double total=0;
        int count=gfl?numflds:6;
        for(int j=0;j<count;++j) {
            double fraction;
            if(gfl) {
                const unsigned char *component=*configuration+3848+368*(size_t)j;
                if(!integer(component,68)) continue;
                size_t off=map==1?188:map==5?192:map==9?184:map==101?216:168;
                int32_t index=integer(component,off);
                double gas,heat;
                memcpy(&gas,component+72,8);
                memcpy(&heat,component+80,8);
                if(index<1 || index>capacity || !isfinite(gas) || gas<0 ||
                   !isfinite(heat) || heat<=0) fail("constituent properties or index");
                fraction=gfl[(size_t)(index-1)*n+cell];
            } else {
                if(!inputs[j] || !water_flags[j]) continue;
                fraction=inputs[j][cell];
            }
            if(!isfinite(fraction) || fraction<0) fail("constituent mass fraction");
            total+=fraction;
        }
        if(total>1) fail("selected mass exceeds mixture mass");
    }
    if(kind) present|=UINT32_C(1)<<10;
    if(thermal) present|=UINT32_C(1)<<11;
    /* Record deterministic dimensions and constants, never pointer addresses. */
    ++calls;
    if(comparison_depth) ++comparison_calls;else ++genuine_calls;
    uint32_t comparison_only=comparison_depth?1:0;
    int32_t dims[4]={*np,*ks,*kp,*nl};
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);
        write_bytes(file,step,4);
        write_bytes(file,dims,16);
        write_bytes(file,&present,4);
        write_bytes(file,&map,4);
        write_bytes(file,&override,4);
        write_bytes(file,&ndim,4);
        write_bytes(file,&numflds,4);
        for(int j=0;j<6;++j) write_bytes(file,constants[j],8);
    }
    /* The input record adds actual capacity and call role after its fixed
     * 96-byte header. Output records retain their original byte format. */
    write_bytes(io,&capacity,4);
    write_bytes(io,&comparison_only,4);
    if(gfl) {
        size_t map_offset=map==1?188:map==5?192:map==9?184:map==101?216:168;
        for(int j=0;j<numflds;++j) {
            const unsigned char *component=*configuration+3848+368*(size_t)j;
            int32_t flag=integer(component,68),index=integer(component,map_offset);
            if(flag && (index<1 || index>capacity)) fail("generic field index");
            write_bytes(io,&flag,4);
            write_bytes(io,&index,4);
            write_bytes(io,component+72,8);
            write_bytes(io,component+80,8);
        }
    } else {
        write_bytes(io,water_flags,sizeof water_flags);
    }
    for(int f=0;f<7;++f) if(inputs[f]) write_bytes(io,inputs[f],sizes[f]);
    for(int f=0;f<3;++f) if(outputs[f]) write_bytes(io,outputs[f],output_size);
    reference(np,ks,kp,nl,q,qi,ql,qr,qs,qg,shadow[0],shadow[1],shadow[2],gfl,kind,thermal);
    unchanged_inputs(inputs,copies,sizes,"Fortran");
    gprcp_assembly_(np,ks,kp,nl,q,qi,ql,qr,qs,qg,cp,r,kap,gfl,kind,thermal);
    unchanged_inputs(inputs,copies,sizes,"assembly");
    bytes+=96;
    for(int f=0;f<3;++f) if(outputs[f]) {
        for(size_t i=0;i<n;++i) {
            if(bits(outputs[f][i])!=bits(shadow[f][i])) {
                fprintf(stderr,"Mismatch stage=GPRCP step=%d call=%" PRIu64 " field=%d cell=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                  *step,calls,f,i,bits(outputs[f][i]),bits(shadow[f][i]));
                _Exit(1);
            }
            int column=(int)(i%(size_t)*np)+1;
            if(column>=*ks && column<=*kp && !isfinite(outputs[f][i]))
                fail("nonfinite active output");
        }
        write_bytes(ao,outputs[f],output_size);
        write_bytes(ro,shadow[f],output_size);
        bytes+=output_size;
        free(shadow[f]);
    }
    for(int f=0;f<7;++f) if(copies[f]) {
        free(copies[f]);
    }
}

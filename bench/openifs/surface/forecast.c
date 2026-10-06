
/* Verify and record the complete CPSPE update during the upstream forecast.
 * Other forecast calculations remain Fortran. This driver adds no update. */
#include "cpspe.h"
#include <dlfcn.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
static const unsigned char kinds[23]={1,0,1,1,0,2,2,2,2,2,0,0,0,0,0,0,0,3,4,5,5,5,5};
static FILE *assembly_out,*reference_out,*inputs_out;
static cpspe_kernel reference;
static const int32_t *forecast_step;
static uint64_t calls,bytes_written,last_fpcr;
static void fail(const char *message) {
    fprintf(stderr,"CPSPE forecast check failed %s\n",message);
    _Exit(2);
}
static uint64_t bits(double x) {
    uint64_t u;memcpy(&u,&x,8);return u;
}
static void write_bytes(FILE *file,const void *data,size_t bytes) {
    if(bytes && fwrite(data,1,bytes,file)!=bytes) fail("output write");
}
__attribute__((destructor)) static void finish(void) {
    if(!assembly_out) return;
    if(fclose(assembly_out)||fclose(reference_out)||fclose(inputs_out)) fail("output close");
    fprintf(stderr,"CPSPE FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",calls,bytes_written,last_fpcr);
}
void cpspe_(CPSPE_PARAMS) {
    int32_t dims[9]={*d0,*d1,*d2,*d3,*d4,*d5,*d6,*d7,*d8};
    const double *rates[23]={t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22};
    double *states[23]={s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21,s22},*shadow[23],*rate_copy[23];
    size_t sizes[23];
    uint64_t fpcr;
    __asm__ volatile("mrs %0, fpcr":"=r"(fpcr));
    last_fpcr=fpcr;
    if(fpcr & ((UINT64_C(3)<<22)|(UINT64_C(1)<<24)|(UINT64_C(1)<<19)|(UINT64_C(1)<<25))) fail("floating-point control");
    if(dims[0]<=0 || dims[1]<1 || dims[1]>dims[0] ||
       dims[2]<dims[1]-1 || dims[2]>dims[0] || !isfinite(*dt))
        fail("dimension or interval contract");
    for(int f=3;f<9;++f) if(dims[f]<0) fail("negative field extent");
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"cpspe_");
        if(!symbol) fail("strict Fortran symbol");
        memcpy(&reference,&symbol,sizeof reference);
        forecast_step=dlsym(RTLD_DEFAULT,"__yomct3_MOD_nstep");
        if(!forecast_step) fail("forecast step symbol");
        assembly_out=fopen("cpspe-assembly.bin","wb");
        reference_out=fopen("cpspe-fortran.bin","wb");
        inputs_out=fopen("cpspe-inputs.bin","wb");
        if(!assembly_out||!reference_out||!inputs_out) fail("output open");
    }
    for(int f=0;f<23;++f) {
        size_t planes=kinds[f]==1?(size_t)dims[3]:kinds[f]==2?(size_t)dims[6]:
          kinds[f]==3?(size_t)dims[4]*dims[7]:kinds[f]==4?(size_t)dims[8]:
          kinds[f]==5?(size_t)dims[5]:1;
        if(planes>(size_t)INT64_MAX/(size_t)dims[0]/8) fail("array size overflow");
        sizes[f]=planes*(size_t)dims[0]*8;
        if(sizes[f] && (!states[f] || !rates[f] ||
           ((uintptr_t)states[f]&7) || ((uintptr_t)rates[f]&7)))
            fail("buffer alignment");
        if(sizes[f] && ((uintptr_t)states[f]>UINTPTR_MAX-sizes[f] ||
           (uintptr_t)rates[f]>UINTPTR_MAX-sizes[f])) fail("buffer address overflow");
        for(size_t i=0;i<sizes[f]/8;++i) {
            int col=(int)(i%(size_t)dims[0])+1;
            if(col>=dims[1] && col<=dims[2] &&
               (!isfinite(states[f][i]) || !isfinite(rates[f][i])))
                fail("nonfinite active input");
        }
        shadow[f]=malloc(sizes[f]+16);
        rate_copy[f]=malloc(sizes[f]+16);
        if(!shadow[f]||!rate_copy[f]) fail("buffer allocation");
        if(sizes[f]) {
            memcpy(shadow[f],states[f],sizes[f]);
            memcpy(rate_copy[f],rates[f],sizes[f]);
        }
    }
    for(int a=0;a<46;++a) for(int b=a+1;b<46;++b) {
        size_t na=sizes[a%23],nb=sizes[b%23];
        uintptr_t pa=(uintptr_t)(a<23?(const double *)states[a]:rates[a-23]);
        uintptr_t pb=(uintptr_t)(b<23?(const double *)states[b]:rates[b-23]);
        if(na && nb && pa<pb+nb && pb<pa+na) fail("overlapping field buffers");
    }
    ++calls;
    for(int output=0;output<3;++output) {
        FILE *file=output==0?assembly_out:output==1?reference_out:inputs_out;
        write_bytes(file,&calls,8);
        write_bytes(file,forecast_step,4);
        write_bytes(file,dims,36);
        write_bytes(file,dt,8);
    }
    for(int f=0;f<23;++f) {
        write_bytes(inputs_out,states[f],sizes[f]);
        write_bytes(inputs_out,rates[f],sizes[f]);
    }
    reference(d0,d1,d2,d3,d4,d5,d6,d7,d8,dt,t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22,shadow[0],shadow[1],shadow[2],shadow[3],shadow[4],shadow[5],shadow[6],shadow[7],shadow[8],shadow[9],shadow[10],shadow[11],shadow[12],shadow[13],shadow[14],shadow[15],shadow[16],shadow[17],shadow[18],shadow[19],shadow[20],shadow[21],shadow[22]);
    cpspe_assembly_(d0,d1,d2,d3,d4,d5,d6,d7,d8,dt,t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22,s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21,s22);
    bytes_written+=56;
    for(int f=0;f<23;++f) {
        if(sizes[f] && memcmp(shadow[f],states[f],sizes[f])) {
            for(size_t i=0;i<sizes[f]/8;++i) if(bits(shadow[f][i])!=bits(states[f][i])) {
                fprintf(stderr,"Mismatch stage=CPSPE step=%d call=%" PRIu64 " field=%d cell=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                  *forecast_step,calls,f,i,bits(states[f][i]),bits(shadow[f][i]));
                _Exit(1);
            }
        }
        if(sizes[f] && memcmp(rate_copy[f],rates[f],sizes[f])) fail("changed tendency");
        for(size_t i=0;i<sizes[f]/8;++i) {
            int col=(int)(i%dims[0])+1;
            if(col>=dims[1]&&col<=dims[2]&&!isfinite(states[f][i])) fail("nonfinite active state");
        }
        write_bytes(assembly_out,states[f],sizes[f]);
        write_bytes(reference_out,shadow[f],sizes[f]);
        bytes_written+=sizes[f];
        free(shadow[f]);free(rate_copy[f]);
    }
}

/* Replace complete SPFILT calls while comparing all caller allocation bytes.
 * SPCM supplies the full SUALSPA module arrays, with vorticity in s^-1.
 * Independent factors check damping; the observer supplies no solver stage. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define ARGS const void *g,const int32_t *ks,const int32_t *ke,void *vor,void *div
typedef void (*kernel)(ARGS);
void spfilt_assembly_(ARGS);
#ifndef SPFILT_FACTOR_FILE
#error "Set the frozen independent-factor file"
#endif
static kernel reference;
static const uint64_t *module_vor,*module_div;
static const int32_t *step;
static FILE *assembly_file,*reference_file,*input_file;
static pthread_mutex_t lock=PTHREAD_MUTEX_INITIALIZER;
static uint64_t calls,allocation_bytes,record_bytes,science,inactive,rigid_values;
static double factors[22];
static void fail(const char *s) {fprintf(stderr,"SPFILT forecast failed %s\n",s);_Exit(2);}
static uint64_t control(void) {uint64_t n;__asm__ volatile("mrs %0,fpcr":"=r"(n));return n;}
static uint64_t bits(const void *p) {uint64_t n;memcpy(&n,p,8);return n;}
static int32_t integer(const void *p,size_t off) {int32_t n;memcpy(&n,(const char *)p+off,4);return n;}
static int64_t signed_word(const void *p,size_t off) {int64_t n;memcpy(&n,(const char *)p+off,8);return n;}
static void write_bytes(FILE *f,const void *p,size_t n) {if(n&&fwrite(p,1,n,f)!=n) fail("capture write");}
static void compare(const char *field,const void *a,const void *b,size_t bytes) {
    const unsigned char *x=a,*y=b;
    for(size_t k=0;k<bytes;++k) if(x[k]!=y[k]) {
        size_t offset=k/8*8,n=bytes-offset;if(n>8)n=8;
        uint64_t aw=0,bw=0;memcpy(&aw,x+offset,n);memcpy(&bw,y+offset,n);
        fprintf(stderr,"Mismatch stage=SPFILT call=%"PRIu64" step=%d field=%s byte=%zu assembly=%016"PRIx64" source=%016"PRIx64"\n",calls,step?*step:-1,field,k,aw,bw);_Exit(1);
    }
}
static void initialize(void) {
    if(reference)return;
    void *symbol=dlsym(RTLD_NEXT,"spfilt_");if(!symbol)fail("source entry");
    memcpy(&reference,&symbol,sizeof symbol);
    module_vor=dlsym(RTLD_NEXT,"__yomsp_MOD_spvor_flt");
    module_div=dlsym(RTLD_NEXT,"__yomsp_MOD_spdiv_flt");
    step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");
    if(!module_vor||!module_div||!step)fail("source module descriptors or step");
    FILE *f=fopen(SPFILT_FACTOR_FILE,"rb");
    if(!f||fread(factors,8,22,f)!=22||fgetc(f)!=EOF||fclose(f))fail("independent factors");
    assembly_file=fopen("spfilt-assembly.bin","wb");reference_file=fopen("spfilt-fortran.bin","wb");input_file=fopen("spfilt-inputs.bin","wb");
    if(!assembly_file||!reference_file||!input_file)fail("capture files");
}
static size_t allocation(const uint64_t d[11],const uint64_t *module,
                         int64_t *rows,int64_t *cols) {
    *rows=(int64_t)d[7]-(int64_t)d[6]+1;*cols=(int64_t)d[10]-(int64_t)d[9]+1;
    if(!d[0]||d[2]!=8||d[4]!=8||*rows<1||*cols<1||d[5]!=1||(int64_t)d[8]!=*rows)fail("full dense module extent");
    if((uint64_t)*rows>UINT64_MAX/8/(uint64_t)*cols)fail("allocation size");
    for(int k=0;k<11;++k)if(d[k]!=module[k])fail("caller does not supply whole module allocation");
    return (size_t)(*rows * *cols)*8;
}
static void physical(const double *before,const double *after,int64_t rows,
                     int64_t cols,int32_t nf,int32_t ks,int32_t ke,
                     const int32_t *degrees,int64_t degree_low) {
    for(int64_t j=1;j<=cols;++j)for(int64_t l=0;l<rows;++l) {
        size_t k=(size_t)((j-1)*rows+l);
        if(j<ks||j>ke||l>=nf) {
            if(bits(before+k)!=bits(after+k))fail("inactive vorticity");
            ++inactive;continue;
        }
        int32_t n=degrees[j-degree_low];if(n<0||n>21)fail("actual degree range");
        long double expected=(long double)factors[n]*before[k];
        long double limit=64.0L*DBL_EPSILON*fabsl(expected)+8.0L*DBL_TRUE_MIN;
        if(!isfinite(after[k])||fabsl((long double)after[k]-expected)>limit) {
            fprintf(stderr,"SPFILT science call=%"PRIu64" step=%d degree=%d level=%"PRId64" got=%.17g expected=%.21Lg limit=%.9Lg\n",calls,*step,n,l+1,after[k],expected,limit);fail("closed factor");
        }
        if(fabsl(after[k])>fabsl(before[k])+8.0L*DBL_TRUE_MIN)fail("amplitude increase");
        if(n==1) {if(bits(before+k)!=bits(after+k))fail("rigid rotation");++rigid_values;}
        ++science;
    }
}
void spfilt_(ARGS) {
    Dl_info caller={0};
    if(!dladdr(__builtin_return_address(0),&caller)||!caller.dli_sname||strcmp(caller.dli_sname,"spcm_"))fail("caller must be SPCM");
    if(pthread_mutex_lock(&lock))fail("lock");
    initialize();
    if(control())fail("entry FPCR");
    int32_t ns=integer(g,5172),nf=integer(g,5228),first=*ks,last=*ke;
    if(ns!=21||nf!=19||first<1||last<first)fail("frozen T21 configuration");
    uint64_t vd[11],dd[11],rvd[11],rdd[11];memcpy(vd,vor,88);memcpy(dd,div,88);
    int64_t vr,vc,dr,dc;
    size_t vb=allocation(vd,module_vor,&vr,&vc),db=allocation(dd,module_div,&dr,&dc);
    if(nf>vr||last>vc)fail("active extent");
    const unsigned char *nd=(const unsigned char *)g+3848;
    int64_t nl=signed_word(nd,48),nu=signed_word(nd,56);
    if(bits(nd+16)!=4||bits(nd+32)!=4||signed_word(nd,40)!=1||nl>first||nu<last||nu<nl)fail("degree allocation");
    size_t nb=(size_t)(nu-nl+1)*4;
    const int32_t *degrees=(const int32_t *)(uintptr_t)bits(nd);
    if(!degrees)fail("degree pointer");
    double *v=(double *)(uintptr_t)vd[0],*d=(double *)(uintptr_t)dd[0];
    double *before_v=malloc(vb),*before_d=malloc(db),*source_v=malloc(vb),*source_d=malloc(db);
    unsigned char *before_g=malloc(17096),*before_nv=malloc(nb);
    if(!before_v||!before_d||!source_v||!source_d||!before_g||!before_nv)fail("snapshot allocation");
    memcpy(before_v,v,vb);memcpy(before_d,d,db);memcpy(source_v,v,vb);memcpy(source_d,d,db);
    memcpy(before_g,g,17096);memcpy(before_nv,degrees,nb);
    memcpy(rvd,vd,88);memcpy(rdd,dd,88);rvd[0]=(uintptr_t)source_v;rdd[0]=(uintptr_t)source_d;
    uint64_t rvd_before[11],rdd_before[11];memcpy(rvd_before,rvd,88);memcpy(rdd_before,rdd,88);
    uint64_t header[32]={UINT64_C(0x31544346465053),calls+1,(uint64_t)(int64_t)*step,
        (uint64_t)ns,(uint64_t)nf,(uint64_t)first,(uint64_t)last,
        (uint64_t)vr,(uint64_t)vc,(uint64_t)dr,(uint64_t)dc,(uint64_t)nl,(uint64_t)nu,
        (uint64_t)vb,(uint64_t)db,(uint64_t)nb,1};
    write_bytes(input_file,header,256);write_bytes(input_file,degrees,nb);write_bytes(input_file,before_v,vb);write_bytes(input_file,before_d,db);
    int32_t shadow_first=first,shadow_last=last;
    reference(g,&shadow_first,&shadow_last,rvd,rdd);
    if(control()||shadow_first!=first||shadow_last!=last)fail("source FPCR or argument mutation");
    compare("source geometry",g,before_g,17096);compare("source degrees",degrees,before_nv,nb);
    compare("source vorticity descriptor",rvd,rvd_before,88);compare("source divergence descriptor",rdd,rdd_before,88);
    spfilt_assembly_(g,ks,ke,vor,div);
    if(control()||*ks!=first||*ke!=last)fail("native FPCR or argument mutation");
    ++calls;
    compare("vorticity",v,source_v,vb);compare("divergence",d,source_d,db);compare("unchanged divergence",d,before_d,db);
    compare("geometry",g,before_g,17096);compare("degrees",degrees,before_nv,nb);
    compare("vorticity descriptor",vor,vd,88);compare("divergence descriptor",div,dd,88);
    physical(before_v,v,vr,vc,nf,first,last,degrees,nl);
    write_bytes(assembly_file,header,256);write_bytes(assembly_file,degrees,nb);write_bytes(assembly_file,v,vb);write_bytes(assembly_file,d,db);
    write_bytes(reference_file,header,256);write_bytes(reference_file,degrees,nb);write_bytes(reference_file,source_v,vb);write_bytes(reference_file,source_d,db);
    if(calls==1) {
        FILE *f=fopen("spfilt-nvalue.bin","wb");if(!f)fail("degree map archive");
        write_bytes(f,degrees,nb);if(fclose(f))fail("degree map close");
    }
    allocation_bytes+=vb+db;record_bytes+=256+nb+vb+db;
    free(before_v);free(before_d);free(source_v);free(source_d);free(before_g);free(before_nv);
    if(pthread_mutex_unlock(&lock))fail("unlock");
}
__attribute__((destructor))static void finish(void) {
    if(!assembly_file)return;
    if(fclose(assembly_file)||fclose(reference_file)||fclose(input_file))fail("capture close");
    FILE *f=fopen("spfilt-verification.json","w");if(!f)fail("verification record");
    fprintf(f,"{\"calls\":%"PRIu64",\"allocation_bytes\":%"PRIu64",\"record_bytes\":%"PRIu64",\"independent_active_values\":%"PRIu64",\"inactive_values\":%"PRIu64",\"rigid_rotation_values\":%"PRIu64",\"different_bytes\":0,\"fpcr\":%"PRIu64",\"whole_module_allocations\":true}\n",calls,allocation_bytes,record_bytes,science,inactive,rigid_values,control());
    if(fclose(f))fail("verification record close");
    fprintf(stderr,"SPFILT FORECAST PASS calls=%"PRIu64" bytes=%"PRIu64" allocation_bytes=%"PRIu64" independent=%"PRIu64" inactive=%"PRIu64" rigid=%"PRIu64" FPCR=%"PRIu64" differing_bytes=0\n",calls,record_bytes,allocation_bytes,science,inactive,rigid_values,control());
}

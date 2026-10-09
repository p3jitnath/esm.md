/* Capture each complete elemental optical transform before native emission.
 * Optical depths and the mean scattering cosine are dimensionless.
 * The three separate scalar buffers are mutable, aligned, and eight bytes each. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef void (*kernel)(double *,double *,double *);
void delta_eddington_scat_od_assembly_(double *,double *,double *) __attribute__((weak));
static kernel reference;
static const int32_t *step;
static const void *image;
static FILE *inputs,*source,*native;
static uint64_t calls,bytes,independent,phases[25],sites[3];
static const uintptr_t offsets[3]={0xb06fb4,0xb07118,0xb07324};
static double minima[3]={DBL_MAX,DBL_MAX,DBL_MAX},maxima[3]={-DBL_MAX,-DBL_MAX,-DBL_MAX};
static void fail(const char *message){fprintf(stderr,"DELTA SCAT OD failed %s\n",message);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static void physical(const double *before,const double *after){
 const long double t=before[0],s=before[1],g=before[2];
 const long double absorption=t-s,retained=s*(1-g)*(1+g);
 const long double expected[2]={absorption+retained,retained};
 const long double scale=fmaxl(1,fabsl(t)+fabsl(s));
 const long double tolerance=1024*DBL_EPSILON*scale+16*DBL_TRUE_MIN;
 if(t< -tolerance||s< -tolerance||s>t+tolerance||g<0||g>1)fail("declared input optical domain");
 for(int k=0;k<3;++k)if(!isfinite(after[k]))fail("finite output");
 if(fabsl((long double)after[0]-expected[0])>tolerance||
    fabsl((long double)after[1]-expected[1])>tolerance)fail("independent retained scattering");
 if(fabsl(((long double)after[0]-after[1])-absorption)>tolerance)fail("absorption invariant");
 if(fabsl((long double)after[2]*(1+g)-g)>1024*DBL_EPSILON+16*DBL_TRUE_MIN)fail("independent cosine identity");
 if(after[0]<-tolerance||after[1]<-tolerance||after[1]>after[0]+tolerance||after[2]<0||after[2]>.5+1024*DBL_EPSILON)fail("transformed optical domain");
 const long double old_transport=t-s*g;
 const long double new_transport=(long double)after[0]-(long double)after[1]*after[2];
 if(fabsl(new_transport-old_transport)>tolerance)fail("transport optical-depth invariant");
 independent+=5;
}
__attribute__((destructor)) static void finish(void){
 if(!source)return;
 if(fclose(inputs)||fclose(source)||(native&&fclose(native)))fail("capture close");
 if(calls==0)fail("no genuine source calls");
 FILE *f=fopen("delta-scat-od-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"complete_record_bytes\":%" PRIu64 ",\"independent_relations\":%" PRIu64 ",\"native_compared\":%s,\"differing_bytes\":0,\"FPCR_zero_every_entry\":true,\"source_sites\":[",calls,bytes,independent,native?"true":"false");
 for(int q=0;q<3;++q)fprintf(f,"%s{\"return_offset\":\"0x%" PRIxPTR "\",\"calls\":%" PRIu64 "}",q?",":"",offsets[q],sites[q]);
 fputs("],\"input_domain\":[",f);
 for(int q=0;q<3;++q)fprintf(f,"%s[%.17g,%.17g]",q?",":"",minima[q],maxima[q]);
 fputs("],\"step_calls\":[",f);
 for(int q=0;q<25;++q)fprintf(f,"%s%" PRIu64,q?",":"",phases[q]);
 fputs("]}\n",f);if(fclose(f))fail("metadata close");
 fprintf(stderr,"DELTA SCAT OD %s PASS calls=%" PRIu64 " complete_record_bytes=%" PRIu64 " independent=%" PRIu64 " differing_bytes=0 FPCR=0\n",native?"NATIVE":"SOURCE",calls,bytes,independent);
}
void __radiation_cloud_optics_MOD_delta_eddington_scat_od(double *od,double *scat,double *g){
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("every-entry FPCR");
 if(!reference){
  void *s=dlsym(RTLD_NEXT,"__radiation_cloud_optics_MOD_delta_eddington_scat_od");
  if(!s)fail("unchanged source binding");memcpy(&reference,&s,sizeof reference);
  Dl_info original={0};if(!dladdr(s,&original)||!original.dli_fbase)fail("source image");
  image=original.dli_fbase;step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");if(!step)fail("original forecast step");
  inputs=fopen("delta-scat-od-inputs.bin","wb");source=fopen("delta-scat-od-fortran.bin","wb");
  if(delta_eddington_scat_od_assembly_)native=fopen("delta-scat-od-assembly.bin","wb");
  if(!inputs||!source||(delta_eddington_scat_od_assembly_&&!native))fail("capture open");
  if(setvbuf(inputs,NULL,_IOFBF,1<<20)||setvbuf(source,NULL,_IOFBF,1<<20)||(native&&setvbuf(native,NULL,_IOFBF,1<<20)))fail("capture buffers");
 }
 Dl_info caller={0};void *ret=__builtin_return_address(0);
 if(!dladdr(ret,&caller)||caller.dli_fbase!=image)fail("undeclared caller image");
 const uintptr_t offset=(uintptr_t)ret-(uintptr_t)image;
 int site=-1;for(int q=0;q<3;++q)if(offset==offsets[q])site=q;
 if(site<0||*step<0||*step>24)fail("declared original site and phase");
 double *out[3]={od,scat,g},before[3],shadow[3],after[3];
 for(int q=0;q<3;++q){
  const uintptr_t p=(uintptr_t)out[q];
  if(!p||p%8||p>UINTPTR_MAX-8)fail("complete aligned scalar capacity");
  for(int j=0;j<q;++j){const uintptr_t z=(uintptr_t)out[j];if(p<z+8&&z<p+8)fail("overlapping in-place scalars");}
  memcpy(&before[q],out[q],8);if(!isfinite(before[q]))fail("finite input");
 }
 int32_t h[2]={*step,site+1};
 FILE *streams[3]={inputs,source,native};
 for(int q=0;q<3;++q)if(streams[q]){writeall(streams[q],&calls,8);writeall(streams[q],h,8);}
 writeall(inputs,before,24);memcpy(shadow,before,24);
 if(native){reference(&shadow[0],&shadow[1],&shadow[2]);delta_eddington_scat_od_assembly_(od,scat,g);}
 else{reference(od,scat,g);for(int q=0;q<3;++q)memcpy(&shadow[q],out[q],8);}
 __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved FPCR");
 for(int q=0;q<3;++q){
  memcpy(&after[q],out[q],8);
  if(native&&memcmp(&after[q],&shadow[q],8)){
   fprintf(stderr,"DELTA first mismatch call=%" PRIu64 " step=%d site=%d field=%d source=%016" PRIx64 " native=%016" PRIx64 "\n",calls,*step,site+1,q+1,bits(shadow[q]),bits(after[q]));
   fail("complete output bytes");
  }
  minima[q]=fmin(minima[q],before[q]);maxima[q]=fmax(maxima[q],before[q]);
 }
 physical(before,after);writeall(source,shadow,24);if(native)writeall(native,after,24);
 ++calls;++sites[site];++phases[*step];bytes+=40;
}

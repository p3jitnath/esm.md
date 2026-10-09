/* Capture full band-26 storage before direct assembly generation.
 * Molecular amounts use units of 10^20 molecules per square centimetre.
 * Rayleigh coefficients use the inverse scaled-column unit.
 * Solar spectrum uses W/m^2. Optical depth is dimensionless.
 * Untouched output bytes are captured as incoming storage, including night. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PARAMETERS void *a0,void *a1,void *a2,void *a3,void *a4,void *a5,void *a6,void *a7,void *a8,void *a9
#define ARGUMENTS a0,a1,a2,a3,a4,a5,a6,a7,a8,a9
typedef void (*kernel)(PARAMETERS);
void srtm_taumol26_assembly_(PARAMETERS) __attribute__((weak));
static kernel reference;
static const int32_t *step;
static const double *rayleigh,*solar;
static const void *image;
static FILE *inputs,*source,*native;
static uint64_t calls,bytes,input_bytes,independent,phases[25],day_columns,night_columns,active_rayleigh,solar_copies,preserved_bytes;
static double min_column=DBL_MAX,max_column=-DBL_MAX,min_mu=DBL_MAX,max_mu=-DBL_MAX;
static int32_t min_trop=INT32_MAX,max_trop=INT32_MIN,min_dims[4]={INT32_MAX,INT32_MAX,INT32_MAX,INT32_MAX},max_dims[4]={0,0,0,0};
static void fail(const char *s){fprintf(stderr,"SRTM26 failed %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static void physical(const int32_t *d,const double *column,const int32_t *trop,const double *mu,const double *coeff,const double *flux,const unsigned char *const *before,const double *const *out,int require_defined_solar){
 const int n=d[1]-d[0]+1,lev=d[2],stride=d[3];
 for(int j=0;j<n;++j){
  if(!isfinite(mu[j])||mu[j]<-1||mu[j]>1)fail("finite solar zenith cosine");
  const int day=mu[j]>0;
  if(day){++day_columns;if(require_defined_solar&&(lev<1||trop[j]<1||trop[j]>lev))fail("active solar output undefined before caller read");}
  else ++night_columns;
  for(int g=0;g<16;++g){
   const size_t solar_ix=(size_t)j+(size_t)n*g;
   const int sun=day&&g<6&&trop[j]>=1&&trop[j]<=lev;
   if(sun){
    if(!isfinite(flux[g])||flux[g]<0||bits(out[0][solar_ix])!=bits(flux[g]))fail("complete active fixed solar spectrum");
    ++solar_copies;++independent;
   }else{
    if(memcmp((const unsigned char *)out[0]+solar_ix*8,before[0]+solar_ix*8,8))fail("unchanged complete solar storage");
    preserved_bytes+=8;++independent;
   }
   for(int k=0;k<stride;++k){
    const size_t ix=(size_t)j+(size_t)n*(k+stride*g),c=(size_t)j+(size_t)n*k;
    if(day&&g<6&&k<lev){
     if(!isfinite(column[c])||column[c]<0||!isfinite(coeff[g])||coeff[g]<0)fail("nonnegative finite active molecular scattering inputs");
     if(bits(out[1][ix])!=0)fail("complete active absorption positive zero");
     const long double expected=(long double)column[c]*coeff[g];
     const long double tol=16*DBL_EPSILON*fabsl(expected)+4*DBL_TRUE_MIN;
     if(!isfinite(out[2][ix])||out[2][ix]<0||fabsl((long double)out[2][ix]-expected)>tol)fail("independent molecular Rayleigh optical depth");
     if(column[c]==0&&out[2][ix]!=0)fail("zero molecular column scattering limit");
     if(coeff[g]==0&&out[2][ix]!=0)fail("zero scattering cross section limit");
     independent+=3;++active_rayleigh;
     if(column[c]==0x1p20&&coeff[g]==0x1p-20){
      if(bits(out[2][ix])!=UINT64_C(0x3ff0000000000000))fail("known unit Rayleigh depth");++independent;
     }
     if(j>0&&mu[j-1]>0&&column[c]==2*column[c-1]&&out[2][ix-1]>=DBL_MIN&&out[2][ix-1]<=DBL_MAX/2){
      if(out[2][ix]!=2*out[2][ix-1])fail("exact doubled molecular-column scattering");++independent;
     }
    }else{
     for(int z=1;z<3;++z)if(memcmp((const unsigned char *)out[z]+ix*8,before[z]+ix*8,8))fail("unchanged complete night inactive-level or unused-point storage");
     preserved_bytes+=16;independent+=2;
    }
   }
  }
 }
}
static void capture_provenance(void){
 const char *names[7]={"__yoesrta26_MOD_sfluxref","__yoesrta26_MOD_rayl","__yoesrta26_MOD_sfluxrefc","__yoesrta26_MOD_raylc","__yoesrtwn_MOD_rwgt","__yoesrtm_MOD_ngn","__yoesrtwn_MOD_ngc"};
 const size_t sizes[7]={128,128,128,128,1792,896,56};
 FILE *f=fopen("srtm26-coefficient-provenance.bin","wb");if(!f)fail("coefficient provenance open");
 for(int k=0;k<7;++k){void *p=dlsym(RTLD_NEXT,names[k]);if(!p)fail("original coefficient provenance binding");writeall(f,p,sizes[k]);}
 void *p=dlsym(RTLD_NEXT,"__yoesrtwn_MOD_ngs");if(!p)fail("original spectral group cumulative count");writeall(f,p,56);
 if(fclose(f))fail("coefficient provenance close");
}
__attribute__((destructor)) static void finish(void){
 if(!source)return;
 if(fclose(inputs)||fclose(source)||(native&&fclose(native)))fail("capture close");
 if(!calls)fail("no original forecast calls");
 FILE *f=fopen("srtm26-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"complete_record_bytes\":%" PRIu64 ",\"complete_input_bytes\":%" PRIu64 ",\"independent_relations\":%" PRIu64 ",\"day_columns\":%" PRIu64 ",\"night_columns\":%" PRIu64 ",\"active_rayleigh_values\":%" PRIu64 ",\"solar_copies\":%" PRIu64 ",\"preserved_storage_bytes\":%" PRIu64 ",\"native_compared\":%s,\"differing_bytes\":0,\"FPCR_zero_every_entry\":true,\"source_return_offset\":\"0x872b80\",\"active_points\":6,\"complete_points\":16,\"column_range\":[%.17g,%.17g],\"cosine_range\":[%.17g,%.17g],\"tropopause_range\":[%d,%d],\"dimensions\":[",calls,bytes,input_bytes,independent,day_columns,night_columns,active_rayleigh,solar_copies,preserved_bytes,native?"true":"false",min_column,max_column,min_mu,max_mu,min_trop,max_trop);
 for(int k=0;k<4;++k)fprintf(f,"%s[%d,%d]",k?",":"",min_dims[k],max_dims[k]);
 fputs("],\"step_calls\":[",f);for(int k=0;k<25;++k)fprintf(f,"%s%" PRIu64,k?",":"",phases[k]);
 fputs("]}\n",f);if(fclose(f))fail("metadata close");
 fprintf(stderr,"SRTM26 %s PASS calls=%" PRIu64 " full_return_bytes=%" PRIu64 " full_input_bytes=%" PRIu64 " independent=%" PRIu64 " differing_bytes=0 FPCR=0\n",native?"NATIVE":"SOURCE",calls,bytes,input_bytes,independent);
}
void srtm_taumol26_(PARAMETERS){
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("every-entry FPCR");
 if(!reference){
  void *s=dlsym(RTLD_NEXT,"srtm_taumol26_");if(!s)fail("original body binding");memcpy(&reference,&s,sizeof reference);
  Dl_info original={0};if(!dladdr(s,&original)||!original.dli_fbase)fail("original image");image=original.dli_fbase;
  step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");rayleigh=dlsym(RTLD_NEXT,"__yoesrta26_MOD_raylc");solar=dlsym(RTLD_NEXT,"__yoesrta26_MOD_sfluxrefc");if(!step||!rayleigh||!solar)fail("read-only numerical global inputs");
  inputs=fopen("srtm26-inputs.bin","wb");source=fopen("srtm26-fortran.bin","wb");if(srtm_taumol26_assembly_)native=fopen("srtm26-assembly.bin","wb");
  if(!inputs||!source||(srtm_taumol26_assembly_&&!native))fail("capture open");
  if(setvbuf(inputs,NULL,_IOFBF,1<<20)||setvbuf(source,NULL,_IOFBF,1<<20)||(native&&setvbuf(native,NULL,_IOFBF,1<<20)))fail("capture buffers");
  capture_provenance();
 }
 Dl_info caller={0};void *ret=__builtin_return_address(0);
 if(!dladdr(ret,&caller)||caller.dli_fbase!=image||(uintptr_t)ret-(uintptr_t)image!=0x872b80||*step<0||*step>24)fail("original source-scoped caller and phase");
 void *all[10]={ARGUMENTS};int32_t d[4];
 for(int k=0;k<4;++k)if(!all[k]||(uintptr_t)all[k]%4)fail("derived dimension and integer alignment");
 memcpy(&d[0],a1,4);memcpy(&d[1],a2,4);memcpy(&d[2],a3,4);memcpy(&d[3],a0,4);
 const int n=d[1]-d[0]+1,lev=d[2],stride=d[3];if(d[0]<1||n<0||n>4096||lev<0||stride<lev||stride>512)fail("complete source-only capacity contract");
 const size_t sizes[10]={32,4,4,4,(size_t)n*stride*8,(size_t)n*4,(size_t)n*16*8,(size_t)n*stride*16*8,(size_t)n*stride*16*8,(size_t)n*8};
 for(int k=0;k<10;++k)if(sizes[k]&&(!all[k]||(uintptr_t)all[k]%(k<4||k==5?4:8)||(uintptr_t)all[k]>UINTPTR_MAX-sizes[k]))fail("complete aligned argument capacity");
 for(int k=6;k<9;++k)for(int z=0;z<10;++z)if(z!=k&&sizes[z]){
  const uintptr_t a=(uintptr_t)all[k],b=(uintptr_t)all[z];if(a<b+sizes[z]&&b<a+sizes[k])fail("disjoint output and input buffers");
 }
 for(int k=6;k<9;++k)for(int z=0;z<2;++z){
  const uintptr_t a=(uintptr_t)all[k],b=(uintptr_t)(z?solar:rayleigh);if(a<b+128&&b<a+sizes[k])fail("disjoint output and coefficient globals");
 }
 unsigned char *snap[7];const int input_args[7]={0,1,2,3,4,5,9};double coefficients[32];
 memcpy(coefficients,rayleigh,128);memcpy(coefficients+16,solar,128);
 for(int k=0;k<7;++k){size_t size=sizes[input_args[k]];snap[k]=malloc(size?size:1);if(!snap[k])fail("read-only input snapshot allocation");memcpy(snap[k],all[input_args[k]],size);}
 unsigned char *before[3],*shadow[3];for(int k=0;k<3;++k){
  before[k]=malloc(sizes[k+6]?sizes[k+6]:1);shadow[k]=malloc(sizes[k+6]?sizes[k+6]:1);if(!before[k]||!shadow[k])fail("whole mutable storage allocation");
  memcpy(before[k],all[k+6],sizes[k+6]);memcpy(shadow[k],before[k],sizes[k+6]);
 }
 int32_t h[2]={*step,1};FILE *streams[3]={inputs,source,native};
 for(int k=0;k<3;++k)if(streams[k]){writeall(streams[k],&calls,8);writeall(streams[k],h,8);writeall(streams[k],d,16);}
 writeall(inputs,a0,32);writeall(inputs,coefficients,256);writeall(inputs,a4,sizes[4]);writeall(inputs,a5,sizes[5]);writeall(inputs,a9,sizes[9]);
 for(int k=0;k<3;++k)writeall(inputs,before[k],sizes[k+6]);
 if(native){
  reference(a0,a1,a2,a3,a4,a5,shadow[0],shadow[1],shadow[2],a9);
  srtm_taumol26_assembly_(ARGUMENTS);
 }else{
  reference(ARGUMENTS);for(int k=0;k<3;++k)memcpy(shadow[k],all[k+6],sizes[k+6]);
 }
 __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved FPCR");
 for(int k=0;k<7;++k){if(memcmp(snap[k],all[input_args[k]],sizes[input_args[k]]))fail("complete read-only input unchanged");free(snap[k]);}
 if(memcmp(rayleigh,coefficients,128)||memcmp(solar,coefficients+16,128))fail("complete read-only coefficients unchanged");
 const double *out[3]={(double *)shadow[0],(double *)shadow[1],(double *)shadow[2]};
 physical(d,a4,a5,a9,coefficients,coefficients+16,(const unsigned char *const *)before,out,1);
 size_t returned=32;
 for(int k=0;k<3;++k){
  if(native&&memcmp(shadow[k],all[k+6],sizes[k+6])){
   size_t first=0;unsigned char *actual=all[k+6];while(shadow[k][first]==actual[first])++first;
   fprintf(stderr,"SRTM26 first mismatch call=%" PRIu64 " phase=%d field=%d byte=%zu source=%02x native=%02x\n",calls,*step,k+1,first,shadow[k][first],actual[first]);fail("complete native returned bytes");
  }
  writeall(source,shadow[k],sizes[k+6]);if(native)writeall(native,all[k+6],sizes[k+6]);returned+=sizes[k+6];free(before[k]);free(shadow[k]);
 }
 const double *col=a4,*mu=a9;const int32_t *trop=a5;
 for(int j=0;j<n;++j){min_mu=fmin(min_mu,mu[j]);max_mu=fmax(max_mu,mu[j]);min_trop=trop[j]<min_trop?trop[j]:min_trop;max_trop=trop[j]>max_trop?trop[j]:max_trop;if(mu[j]>0)for(int k=0;k<lev;++k){double v=col[j+n*k];min_column=fmin(min_column,v);max_column=fmax(max_column,v);}}
 for(int k=0;k<4;++k){min_dims[k]=d[k]<min_dims[k]?d[k]:min_dims[k];max_dims[k]=d[k]>max_dims[k]?d[k]:max_dims[k];}
 ++calls;++phases[*step];bytes+=returned;input_bytes+=320+sizes[4]+sizes[5]+sizes[9]+returned-32;
}

/* Capture complete shortwave band-25 source inputs before assembly emission.
 * H2O, O3 and total columns use 10^20 molecules/cm^2.
 * Absorption and Rayleigh coefficients use the corresponding inverse column unit.
 * Solar values use W/m^2. Complete output storage includes every unused byte. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PARAMETERS void *a0, void *a1, void *a2, void *a3, void *a4, void *a5, void *a6, void *a7, void *a8, void *a9, void *a10, void *a11, void *a12, void *a13, void *a14, void *a15, void *a16, void *a17, void *a18
#define ARGUMENTS a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18
typedef void (*kernel)(PARAMETERS);
void srtm_taumol25_assembly_(PARAMETERS) __attribute__((weak));
static kernel reference;
static const int32_t *step;
static const void *image;
static double *absa,*solar,*rayleigh,*ozone_a,*ozone_b;
static int32_t *reference_layer,*species;
static FILE *inputs,*source,*native;
static uint64_t calls,bytes,input_bytes,independent,phases[25],day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,lookahead_reads,negative_factors;
static double min_factor=DBL_MAX,max_factor=-DBL_MAX,max_absorption;
static void fail(const char *s){fprintf(stderr,"SRTM25 failed %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static const char *global_names[7]={"yoesrta25.eq.0_","__yoesrta25_MOD_sfluxrefc","__yoesrta25_MOD_raylc","__yoesrta25_MOD_abso3ac","__yoesrta25_MOD_abso3bc","__yoesrta25_MOD_layreffr","__yoesrtwn_MOD_nspa"};
static const size_t global_sizes[7]={8320,128,128,128,128,4,56};
static void *globals[7];
static void bind_globals(void){
 for(int k=0;k<7;++k){globals[k]=dlsym(RTLD_NEXT,global_names[k]);if(!globals[k])fail("all declared coefficient/global input bindings");}
 absa=globals[0];solar=globals[1];rayleigh=globals[2];ozone_a=globals[3];ozone_b=globals[4];reference_layer=globals[5];species=globals[6];
}
static void physical(const int32_t *d,void *const *a,const unsigned char *const *before,const double *const *out,int require_solar){
 const int n=d[1]-d[0]+1,H=d[2],V=d[3],S=species[9],ref=*reference_layer;
 const double *f00=a[4],*f01=a[5],*f10=a[6],*f11=a[7],*water=a[11],*molecules=a[12],*ozone=a[13],*mu=a[18];
 const int32_t *jp=a[8],*jt=a[9],*jt1=a[10],*trop=a[14];
 if(S!=1||ref<1||ref>13)fail("declared absorption table species count and solar reference");
 for(int j=0;j<n;++j){
  if(!isfinite(mu[j])||mu[j]<-1||mu[j]>1)fail("finite solar zenith cosine");
  int day=mu[j]>0,sol=trop[j],written=0;
  if(day)++day_columns;else ++night_columns;
  if(day){
   if(trop[j]<0||trop[j]>H)fail("supported tropopause bounds");
   for(int k=0;k<H&&k<trop[j];++k){
    size_t ix=j+(size_t)n*k;
    if(k+1>=V)fail("active next-pressure row outside complete input capacity");
    ++lookahead_reads;
    if(jp[ix]<ref&&jp[ix+n]>=ref)sol=(k+2<trop[j]?k+2:trop[j]);
    if(k+1==sol)written=1;
   }
   if(require_solar&&!written)fail("consumed solar spectrum not defined before caller read");
  }
  for(int g=0;g<16;++g){
   size_t sun=j+(size_t)n*g;
   if(day&&g<6&&written){
    if(!isfinite(solar[g])||solar[g]<0||bits(out[0][sun])!=bits(solar[g]))fail("complete fixed solar spectrum");
    ++solar_copies;++independent;
   }else{
    if(memcmp((unsigned char *)out[0]+sun*8,before[0]+sun*8,8))fail("complete untouched solar storage");
    preserved_bytes+=8;++independent;
   }
   for(int k=0;k<V;++k){
    size_t ix=j+(size_t)n*(k+V*g),ci=j+(size_t)n*k;
    if(day&&g<6&&k<H){
     if(!isfinite(molecules[ci])||molecules[ci]<0||!isfinite(ozone[ci])||ozone[ci]<0||!isfinite(rayleigh[g])||rayleigh[g]<0)fail("finite nonnegative active columns and scattering");
     long double tau=(long double)molecules[ci]*rayleigh[g];
     if(!isfinite(out[2][ix])||out[2][ix]<0||fabsl((long double)out[2][ix]-tau)>16*DBL_EPSILON*fabsl(tau)+4*DBL_TRUE_MIN)fail("independent dimensionless molecular scattering");

     if(molecules[ci]==0x1p20&&rayleigh[g]==0x1p-20){
      if(bits(out[2][ix])!=UINT64_C(0x3ff0000000000000))fail("known unit molecular scattering depth");++independent;
     }
     long double expected,condition;
     if(k<trop[j]){
      if(jp[ci]<1||jp[ci]>12||jt[ci]<1||jt[ci]>4||jt1[ci]<1||jt1[ci]>4)fail("complete four-point absorption table bounds");
      if(!isfinite(water[ci])||water[ci]<0)fail("finite nonnegative water column");
      int i0=(jp[ci]-1)*5+jt[ci]-1,i1=jp[ci]*5+jt1[ci]-1;
      double f[4]={f00[ci],f10[ci],f01[ci],f11[ci]},r[4]={absa[i0+65*g],absa[i0+1+65*g],absa[i1+65*g],absa[i1+1+65*g]};
      long double sum=0,weighted=0,absolute=0;
      for(int z=0;z<4;++z){
       if(!isfinite(f[z])||!isfinite(r[z])||r[z]<0)fail("finite interpolation factors and nonnegative table coefficients");
       sum+=f[z];weighted+=(long double)f[z]*r[z];absolute+=fabsl((long double)f[z]*r[z]);
       if(f[z]<0)++negative_factors;min_factor=fmin(min_factor,f[z]);max_factor=fmax(max_factor,f[z]);
      }
      if(fabsl(sum-1)>64*DBL_EPSILON)fail("independent pressure-temperature weights sum to one");
      if(!isfinite(ozone_a[g])||ozone_a[g]<0)fail("nonnegative lower ozone coefficient");
      expected=(long double)water[ci]*weighted+(long double)ozone[ci]*ozone_a[g];
      condition=(long double)water[ci]*absolute+(long double)ozone[ci]*ozone_a[g];
      ++lower_layers;independent+=2;
      if(water[ci]==0&&ozone[ci]==0&&out[1][ix]!=0)fail("zero absorbing species limit");
     }else{
      if(!isfinite(ozone_b[g])||ozone_b[g]<0)fail("nonnegative upper ozone coefficient");
      expected=(long double)ozone[ci]*ozone_b[g];condition=fabsl(expected);++upper_layers;
      if(ozone[ci]==0&&out[1][ix]!=0)fail("zero upper ozone absorption limit");
     }
     if(!isfinite(out[1][ix])||out[1][ix]<0||fabsl((long double)out[1][ix]-expected)>64*DBL_EPSILON*condition+8*DBL_TRUE_MIN)fail("independent scaled water plus ozone absorption");
     if(molecules[ci]==0&&out[2][ix]!=0)fail("zero molecular scattering limit");

     if(k<trop[j]&&ozone[ci]==0&&f00[ci]==1&&f01[ci]==0&&f10[ci]==0&&f11[ci]==0){
      int base=(jp[ci]-1)*5+jt[ci]-1;
      if(absa[base+65*g]==0x1p-8&&(water[ci]==256||water[ci]==512||water[ci]==1024)){
       if(bits(out[1][ix])!=bits(water[ci]*0x1p-8))fail("known unit and exact doubled water absorption");++independent;
      }
     }
     if(k>=trop[j]&&ozone[ci]==256&&ozone_b[g]==0x1p-9){
      if(bits(out[1][ix])!=UINT64_C(0x3fe0000000000000))fail("known upper ozone optical depth");++independent;
     }
     max_absorption=fmax(max_absorption,out[1][ix]);independent+=3;
    }else{
     for(int z=1;z<3;++z)if(memcmp((unsigned char *)out[z]+ix*8,before[z]+ix*8,8))fail("complete untouched night extra-layer unused-slot storage");
     preserved_bytes+=16;independent+=2;
    }
   }
  }
 }
}
static void provenance(void){
 const char *names[13]={"__yoesrta25_MOD_ka_d","__yoesrta25_MOD_ka","yoesrta25.eq.0_","__yoesrta25_MOD_sfluxref","__yoesrta25_MOD_rayl","__yoesrta25_MOD_abso3a","__yoesrta25_MOD_abso3b","__yoesrta25_MOD_sfluxrefc","__yoesrta25_MOD_raylc","__yoesrta25_MOD_abso3ac","__yoesrta25_MOD_abso3bc","__yoesrtwn_MOD_rwgt","__yoesrtm_MOD_ngn"};
 const size_t sizes[13]={8320,8320,8320,128,128,128,128,128,128,128,128,1792,896};
 FILE *f=fopen("srtm25-coefficient-provenance.bin","wb");if(!f)fail("coefficient provenance open");
 for(int k=0;k<13;++k){void *p=dlsym(RTLD_NEXT,names[k]);if(!p)fail("original raw coefficient provenance");writeall(f,p,sizes[k]);}
 for(int k=0;k<4;++k){const char *name=k==0?"__yoesrtwn_MOD_ngc":k==1?"__yoesrtwn_MOD_ngs":k==2?"__yoesrtwn_MOD_nspa":"__yoesrta25_MOD_layreffr";void *p=dlsym(RTLD_NEXT,name);if(!p)fail("coefficient group/source integer provenance");writeall(f,p,k==3?4:56);}
 if(fclose(f))fail("coefficient provenance close");
}
__attribute__((destructor)) static void finish(void){
 if(!source)return;
 if(fclose(inputs)||fclose(source)||(native&&fclose(native)))fail("capture close");if(!calls)fail("no original calls");
 FILE *f=fopen("srtm25-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"complete_return_bytes\":%" PRIu64 ",\"complete_input_bytes\":%" PRIu64 ",\"independent_relations\":%" PRIu64 ",\"day_columns\":%" PRIu64 ",\"night_columns\":%" PRIu64 ",\"lower_spectral_layers\":%" PRIu64 ",\"upper_spectral_layers\":%" PRIu64 ",\"solar_copies\":%" PRIu64 ",\"preserved_storage_bytes\":%" PRIu64 ",\"active_next_pressure_reads\":%" PRIu64 ",\"negative_interpolation_factors\":%" PRIu64 ",\"factor_range\":[%.17g,%.17g],\"max_absorption\":%.17g,\"native_compared\":%s,\"differing_bytes\":0,\"FPCR_zero_every_entry\":true,\"source_return_offset\":\"0x872bf0\",\"active_points\":6,\"complete_points\":16,\"step_calls\":[",calls,bytes,input_bytes,independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,lookahead_reads,negative_factors,min_factor,max_factor,max_absorption,native?"true":"false");
 for(int k=0;k<25;++k)fprintf(f,"%s%" PRIu64,k?",":"",phases[k]);fputs("]}\n",f);if(fclose(f))fail("metadata close");
 fprintf(stderr,"SRTM25 %s PASS calls=%" PRIu64 " full_return_bytes=%" PRIu64 " full_input_bytes=%" PRIu64 " independent=%" PRIu64 " differing_bytes=0 FPCR=0\n",native?"NATIVE":"SOURCE",calls,bytes,input_bytes,independent);
}
void srtm_taumol25_(PARAMETERS){
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("every-entry FPCR");
 if(!reference){
  void *s=dlsym(RTLD_NEXT,"srtm_taumol25_");if(!s)fail("original body binding");memcpy(&reference,&s,sizeof reference);
  Dl_info original={0};if(!dladdr(s,&original)||!original.dli_fbase)fail("original image");image=original.dli_fbase;
  step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");if(!step)fail("source forecast phase");bind_globals();
  inputs=fopen("srtm25-inputs.bin","wb");source=fopen("srtm25-fortran.bin","wb");if(srtm_taumol25_assembly_)native=fopen("srtm25-assembly.bin","wb");
  if(!inputs||!source||(srtm_taumol25_assembly_&&!native))fail("capture open");
  if(setvbuf(inputs,NULL,_IOFBF,1<<20)||setvbuf(source,NULL,_IOFBF,1<<20)||(native&&setvbuf(native,NULL,_IOFBF,1<<20)))fail("capture buffers");
  provenance();
 }
 Dl_info caller={0};void *ret=__builtin_return_address(0);if(!dladdr(ret,&caller)||caller.dli_fbase!=image||(uintptr_t)ret-(uintptr_t)image!=0x872bf0||*step<0||*step>24)fail("original source-scoped caller/phase");
 void *all[19]={ARGUMENTS};int32_t d[4];
 for(int k=0;k<4;++k)if(!all[k]||(uintptr_t)all[k]%4)fail("dimensions alignment");
 memcpy(d,a1,4);memcpy(d+1,a2,4);memcpy(d+2,a3,4);memcpy(d+3,a0,4);
 const int n=d[1]-d[0]+1,H=d[2],V=d[3];if(d[0]<1||n<0||n>4096||H<0||V<H||V>512)fail("complete source capacity");
 size_t sizes[19]={32,4,4,4};
 for(int k=4;k<14;++k)sizes[k]=(size_t)n*V*(k>=8&&k<=10?4:8);
 sizes[14]=(size_t)n*4;sizes[15]=(size_t)n*16*8;sizes[16]=sizes[17]=(size_t)n*V*16*8;sizes[18]=(size_t)n*8;
 for(int k=0;k<19;++k)if(sizes[k]&&(!all[k]||(uintptr_t)all[k]%((k<4||k>=8&&k<=10||k==14)?4:8)||(uintptr_t)all[k]>UINTPTR_MAX-sizes[k]))fail("all complete argument capacities/alignment");
 for(int k=15;k<18;++k){
  for(int z=0;z<19;++z)if(z!=k&&sizes[z]){uintptr_t a=(uintptr_t)all[k],b=(uintptr_t)all[z];if(a<b+sizes[z]&&b<a+sizes[k])fail("complete disjoint output storage");}
  for(int z=0;z<7;++z){uintptr_t a=(uintptr_t)all[k],b=(uintptr_t)globals[z];if(a<b+global_sizes[z]&&b<a+sizes[k])fail("output disjoint from all numerical globals");}
 }

 /* Prove each active look-ahead row and table index before the original call. */
 const double *mu0=a18;const int32_t *trop0=a14,*jp0=a8,*jt0=a9,*jt10=a10;
 for(int j=0;j<n;++j)if(mu0[j]>0){
  if(trop0[j]<0||trop0[j]>H||(trop0[j]>0&&trop0[j]>=V))fail("active lower-layer next-pressure input capacity before execution");
  for(int k=0;k<H&&k<trop0[j];++k){
   size_t ix=j+(size_t)n*k;
   if(jp0[ix]<1||jp0[ix]>12||jt0[ix]<1||jt0[ix]>4||jt10[ix]<1||jt10[ix]>4)fail("active four-point input table bounds before execution");
  }
 }
 unsigned char constants[8892];size_t co=0;
 for(int k=0;k<7;++k){memcpy(constants+co,globals[k],global_sizes[k]);co+=global_sizes[k];}if(co!=sizeof constants)fail("complete numerical global record");
 unsigned char *snap[19]={0};for(int k=0;k<19;++k)if(k<15||k==18){snap[k]=malloc(sizes[k]?sizes[k]:1);if(!snap[k])fail("complete readonly snapshot");memcpy(snap[k],all[k],sizes[k]);}
 unsigned char *before[3],*shadow[3];for(int k=0;k<3;++k){size_t sz=sizes[k+15];before[k]=malloc(sz?sz:1);shadow[k]=malloc(sz?sz:1);if(!before[k]||!shadow[k])fail("complete incoming output storage");memcpy(before[k],all[k+15],sz);memcpy(shadow[k],before[k],sz);}
 int32_t hs[2]={*step,1};FILE *streams[3]={inputs,source,native};
 for(int k=0;k<3;++k)if(streams[k]){writeall(streams[k],&calls,8);writeall(streams[k],hs,8);writeall(streams[k],d,16);}
 writeall(inputs,a0,32);writeall(inputs,constants,sizeof constants);
 for(int k=4;k<15;++k)writeall(inputs,all[k],sizes[k]);writeall(inputs,a18,sizes[18]);for(int k=0;k<3;++k)writeall(inputs,before[k],sizes[k+15]);
 if(native){reference(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,shadow[0],shadow[1],shadow[2],a18);srtm_taumol25_assembly_(ARGUMENTS);}else{reference(ARGUMENTS);for(int k=0;k<3;++k)memcpy(shadow[k],all[k+15],sizes[k+15]);}
 __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved FPCR");
 for(int k=0;k<19;++k)if(snap[k]){if(memcmp(snap[k],all[k],sizes[k]))fail("all complete inputs unchanged");free(snap[k]);}
 co=0;for(int k=0;k<7;++k){if(memcmp(constants+co,globals[k],global_sizes[k]))fail("all complete numerical globals unchanged");co+=global_sizes[k];}
 const double *out[3]={(double *)shadow[0],(double *)shadow[1],(double *)shadow[2]};physical(d,all,(const unsigned char *const *)before,out,1);
 size_t returned=32,received=32+32+sizeof constants;
 for(int k=4;k<15;++k)received+=sizes[k];received+=sizes[18];
 for(int k=0;k<3;++k){
  if(native&&memcmp(shadow[k],all[k+15],sizes[k+15])){
   size_t first=0;unsigned char *actual=all[k+15];while(shadow[k][first]==actual[first])++first;
   fprintf(stderr,"SRTM25 first mismatch call=%" PRIu64 " phase=%d field=%d byte=%zu source=%02x native=%02x\n",calls,*step,k+1,first,shadow[k][first],actual[first]);fail("complete native returned bytes");
  }
  writeall(source,shadow[k],sizes[k+15]);if(native)writeall(native,all[k+15],sizes[k+15]);returned+=sizes[k+15];received+=sizes[k+15];free(before[k]);free(shadow[k]);
 }
 ++calls;++phases[*step];bytes+=returned;input_bytes+=received;
}

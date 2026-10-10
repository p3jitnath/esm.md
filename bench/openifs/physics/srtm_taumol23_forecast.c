/* Verify complete band-23 water absorption and molecular scattering.
 * Columns use 10^20 molecules/cm^2. Depth and continuum density factors
 * are dimensionless. Solar flux uses W/m^2. Keep complete incoming storage. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PARAMETERS void *a0, void *a1, void *a2, void *a3, void *a4, void *a5, void *a6, void *a7, void *a8, void *a9, void *a10, void *a11, void *a12, void *a13, void *a14, void *a15, void *a16, void *a17, void *a18, void *a19, void *a20, void *a21, void *a22, void *a23
#define ARGUMENTS a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23
typedef void (*kernel)(PARAMETERS);
void srtm_taumol23_assembly_(PARAMETERS) __attribute__((weak));
static double *absa,*self,*foreign,*solar,*rayleigh,*giver;
static int32_t *reference_layer,*species;
static uint64_t independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,negative_factors,solar_crossings;
static double min_factor=DBL_MAX,max_factor=-DBL_MAX,max_absorption;
static double min_self_fraction=DBL_MAX,max_self_fraction=-DBL_MAX,min_foreign_fraction=DBL_MAX,max_foreign_fraction=-DBL_MAX;
static void fail(const char *s){fprintf(stderr,"SRTM23 failed %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static const char *global_names[8]={"yoesrta23.eq.0_","__yoesrta23_MOD_selfrefc","__yoesrta23_MOD_forrefc","__yoesrta23_MOD_sfluxrefc","__yoesrta23_MOD_raylc","__yoesrta23_MOD_givfac","__yoesrta23_MOD_layreffr","__yoesrtwn_MOD_nspa"};
static const size_t global_sizes[8]={8320,1280,384,128,128,8,4,56};
static void *globals[8];
static void bind_globals(void){
 for(int k=0;k<8;++k){globals[k]=dlsym(RTLD_NEXT,global_names[k]);if(!globals[k])fail("all declared coefficient/global bindings");}
 absa=globals[0];self=globals[1];foreign=globals[2];solar=globals[3];rayleigh=globals[4];giver=globals[5];reference_layer=globals[6];species=globals[7];
}
static void capacities(const int32_t *d,void *const *a,size_t *sizes){
 int n=d[1]-d[0]+1,H=d[2],V=d[3];
 if(d[0]<1||n<0||n>4096||H<0||V<H||V>512)fail("complete shape bounds");
 sizes[0]=32;for(int z=1;z<4;++z)sizes[z]=4;
 for(int z=4;z<20;++z)sizes[z]=(size_t)n*V*((z>=8&&z<=10)||z==16||z==19?4:8);
 sizes[13]=(size_t)n*4;sizes[20]=(size_t)n*16*8;sizes[21]=sizes[22]=(size_t)n*V*16*8;sizes[23]=(size_t)n*8;
 for(int z=0;z<24;++z)if(sizes[z]&&(!a[z]||(uintptr_t)a[z]%((z<4||z>=8&&z<=10||z==13||z==16||z==19)?4:8)||(uintptr_t)a[z]>UINTPTR_MAX-sizes[z]))fail("complete capacity and alignment");
 const double *mu=a[23];const int32_t *trop=a[13],*jp=a[8],*jt=a[9],*jt1=a[10],*is=a[16],*iff=a[19];
 if(species[7]!=1||*reference_layer<1||*reference_layer>13)fail("declared coefficient species and solar reference");
 for(int j=0;j<n;++j){
  if(!isfinite(mu[j])||mu[j]<-1||mu[j]>1)fail("finite solar zenith cosine");
  if(mu[j]<=0)continue;
  if(trop[j]<0||trop[j]>H||(H&&(trop[j]<1||trop[j]>=V)))fail("positive solar layer and next-pressure capacity");
  for(int k=0;k<H&&k<trop[j];++k){
   size_t i=j+(size_t)n*k;
   if(k+1>=V||jp[i]<1||jp[i]>12||jt[i]<1||jt[i]>4||jt1[i]<1||jt1[i]>4)fail("lower table and next-pressure bounds before original execution");
   if(is[i]<1||is[i]>9||iff[i]<1||iff[i]>2)fail("two continuum rows before original execution");
  }
 }
}
static void physical(const int32_t *d,void *const *a,const unsigned char *const *before,const double *const *out,int require_solar){
 int n=d[1]-d[0]+1,H=d[2],V=d[3],ref=*reference_layer;
 const double *f00=a[4],*f01=a[5],*f10=a[6],*f11=a[7],*water=a[11],*molecules=a[12],*sf=a[14],*sx=a[15],*ff=a[17],*fx=a[18],*mu=a[23];
 const int32_t *jp=a[8],*jt=a[9],*jt1=a[10],*trop=a[13],*is=a[16],*iff=a[19];
 for(int j=0;j<n;++j){
  int day=mu[j]>0,sol=trop[j],written=0;if(day)++day_columns;else ++night_columns;
  if(day)for(int k=0;k<H&&k<trop[j];++k){
   size_t ci=j+(size_t)n*k;++previous_reads;
   if(jp[ci]<ref&&jp[ci+n]>=ref){sol=k+2<trop[j]?k+2:trop[j];++solar_crossings;}
   if(k+1==sol)written=1;
  }
  if(day&&require_solar&&H&&!written)fail("consumed daylight solar spectrum not defined before caller read");
  for(int g=0;g<16;++g){
   size_t sun=j+(size_t)n*g;
   if(day&&g<10&&written){
    if(!isfinite(solar[g])||solar[g]<0||bits(out[0][sun])!=bits(solar[g]))fail("complete fixed solar spectrum");
    ++solar_copies;++independent;
   }else{
    if(memcmp((const unsigned char *)out[0]+sun*8,before[0]+sun*8,8))fail("complete unchanged solar storage");
    preserved_bytes+=8;++independent;
   }
   for(int k=0;k<V;++k){
    size_t ci=j+(size_t)n*k,ix=j+(size_t)n*(k+V*g);
    if(day&&g<10&&k<H){
     if(!isfinite(molecules[ci])||molecules[ci]<0||!isfinite(rayleigh[g])||rayleigh[g]<0)fail("finite nonnegative molecular scattering inputs");
     long double scattering=(long double)molecules[ci]*rayleigh[g];
     if(!isfinite(out[2][ix])||out[2][ix]<0||fabsl((long double)out[2][ix]-scattering)>16*DBL_EPSILON*fabsl(scattering)+4*DBL_TRUE_MIN)fail("independent dimensionless molecular scattering");
     if(k<trop[j]){
      int i0=(jp[ci]-1)*5+jt[ci]-1,i1=jp[ci]*5+jt1[ci]-1;
      double f[4]={f00[ci],f10[ci],f01[ci],f11[ci]},r[4]={absa[i0+65*g],absa[i0+1+65*g],absa[i1+65*g],absa[i1+1+65*g]};
      long double sum=0,weighted=0,absolute=0;
      for(int z=0;z<4;++z){
       if(!isfinite(f[z])||!isfinite(r[z])||r[z]<0)fail("finite interpolation and nonnegative absorption table");
       sum+=f[z];weighted+=(long double)f[z]*r[z];absolute+=fabsl((long double)f[z]*r[z]);
       if(f[z]<0)++negative_factors;min_factor=fmin(min_factor,f[z]);max_factor=fmax(max_factor,f[z]);
      }
      if(fabsl(sum-1)>64*DBL_EPSILON)fail("pressure-temperature factors sum to one");
      double s0=self[is[ci]-1+10*g],s1=self[is[ci]+10*g],b0=foreign[iff[ci]-1+3*g],b1=foreign[iff[ci]+3*g];
      if(!isfinite(water[ci])||water[ci]<0||!isfinite(*giver)||*giver<0||!isfinite(sf[ci])||sf[ci]<0||!isfinite(ff[ci])||ff[ci]<0||!isfinite(sx[ci])||!isfinite(fx[ci])||!isfinite(s0)||s0<0||!isfinite(s1)||s1<0||!isfinite(b0)||b0<0||!isfinite(b1)||b1<0)fail("finite nonnegative columns, continuum factors and coefficient tables");
      /* Expand the continuum weights independently of the source subtraction
       * and interpolation tree. Extrapolated fractions remain supported. */
      long double self_term=(long double)sf[ci]*((1-(long double)sx[ci])*s0+(long double)sx[ci]*s1);
      long double foreign_term=(long double)ff[ci]*((1-(long double)fx[ci])*b0+(long double)fx[ci]*b1);
      long double absorption=(long double)water[ci]*((long double)*giver*weighted+self_term+foreign_term);
      long double condition=(long double)water[ci]*(fabsl((long double)*giver)*absolute+(long double)sf[ci]*(fabsl(1-(long double)sx[ci])*s0+fabsl((long double)sx[ci])*s1)+(long double)ff[ci]*(fabsl(1-(long double)fx[ci])*b0+fabsl((long double)fx[ci])*b1));
      long double tiny=64*(long double)DBL_TRUE_MIN*(1+water[ci])*(1+*giver+sf[ci]+ff[ci]);
      if(!isfinite(out[1][ix])||out[1][ix]<0||fabsl((long double)out[1][ix]-absorption)>128*DBL_EPSILON*condition+tiny)fail("independent water absorption with self and foreign continua");
      if(water[ci]==0&&out[1][ix]!=0)fail("zero water absorption limit");
      if(f00[ci]==1&&f01[ci]==0&&f10[ci]==0&&f11[ci]==0&&r[0]==0x1p-8&&*giver==1&&sf[ci]==0&&ff[ci]==0&&(water[ci]==256||water[ci]==512||water[ci]==1024)){
       if(bits(out[1][ix])!=bits(water[ci]*0x1p-8))fail("known unit and doubled water optical depth");++independent;
      }
      min_self_fraction=fmin(min_self_fraction,sx[ci]);max_self_fraction=fmax(max_self_fraction,sx[ci]);min_foreign_fraction=fmin(min_foreign_fraction,fx[ci]);max_foreign_fraction=fmax(max_foreign_fraction,fx[ci]);
      ++lower_layers;independent+=6;
     }else{
      if(bits(out[1][ix])!=0)fail("upper-layer positive-zero absorption");++upper_layers;independent+=2;
     }
     if(molecules[ci]==0&&out[2][ix]!=0)fail("zero molecular scattering limit");
     if(molecules[ci]==0x1p20&&rayleigh[g]==0x1p-20){if(bits(out[2][ix])!=UINT64_C(0x3ff0000000000000))fail("known unit molecular scattering");++independent;}
     max_absorption=fmax(max_absorption,out[1][ix]);++independent;
    }else{
     for(int z=1;z<3;++z)if(memcmp((const unsigned char *)out[z]+ix*8,before[z]+ix*8,8))fail("complete unchanged night unused-point extra-layer storage");
     preserved_bytes+=16;independent+=2;
    }
   }
  }
 }
}
static kernel reference;
static const int32_t *step;
static const void *image;
static FILE *inputs,*source,*native;
static uint64_t calls,bytes,input_bytes,phases[25];
static void provenance(void){
 const char *names[15]={"__yoesrta23_MOD_ka_d","__yoesrta23_MOD_ka","yoesrta23.eq.0_","__yoesrta23_MOD_selfref","__yoesrta23_MOD_forref","__yoesrta23_MOD_sfluxref","__yoesrta23_MOD_rayl","__yoesrta23_MOD_selfrefc","__yoesrta23_MOD_forrefc","__yoesrta23_MOD_sfluxrefc","__yoesrta23_MOD_raylc","__yoesrta23_MOD_givfac","__yoesrtwn_MOD_rwgt","__yoesrtm_MOD_ngn","__yoesrta23_MOD_layreffr"};
 const size_t sizes[15]={8320,8320,8320,1280,384,128,128,1280,384,128,128,8,1792,896,4};
 FILE *f=fopen("srtm23-coefficient-provenance.bin","wb");if(!f)fail("provenance open");
 for(int z=0;z<15;++z){void *p=dlsym(RTLD_NEXT,names[z]);if(!p)fail("raw coefficient provenance");writeall(f,p,sizes[z]);}
 for(int z=0;z<3;++z){const char *name=z==0?"__yoesrtwn_MOD_ngc":z==1?"__yoesrtwn_MOD_ngs":"__yoesrtwn_MOD_nspa";void *p=dlsym(RTLD_NEXT,name);if(!p)fail("group/species provenance");writeall(f,p,56);}
 if(fclose(f))fail("provenance close");
}
__attribute__((destructor)) static void finish(void){
 if(!source)return;
 if(fclose(inputs)||fclose(source)||(native&&fclose(native)))fail("capture close");if(!calls)fail("no original calls");
 FILE *f=fopen("srtm23-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"complete_return_bytes\":%" PRIu64 ",\"complete_input_bytes\":%" PRIu64 ",\"independent_relations\":%" PRIu64 ",\"day_columns\":%" PRIu64 ",\"night_columns\":%" PRIu64 ",\"lower_spectral_layers\":%" PRIu64 ",\"upper_spectral_layers\":%" PRIu64 ",\"solar_copies\":%" PRIu64 ",\"preserved_storage_bytes\":%" PRIu64 ",\"active_next_pressure_reads\":%" PRIu64 ",\"solar_crossings\":%" PRIu64 ",\"negative_interpolation_factors\":%" PRIu64 ",\"factor_range\":[%.17g,%.17g],\"max_absorption\":%.17g,\"native_compared\":%s,\"differing_bytes\":0,\"FPCR_zero_every_entry\":true,\"source_return_offset\":\"0x872d38\",\"active_points\":10,\"complete_points\":16,\"step_calls\":[",calls,bytes,input_bytes,independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,solar_crossings,negative_factors,min_factor,max_factor,max_absorption,native?"true":"false");
 for(int z=0;z<25;++z)fprintf(f,"%s%" PRIu64,z?",":"",phases[z]);fputs("]}\n",f);if(fclose(f))fail("metadata close");
 fprintf(stderr,"SRTM23 %s PASS calls=%" PRIu64 " full_return_bytes=%" PRIu64 " full_input_bytes=%" PRIu64 " independent=%" PRIu64 " differing_bytes=0 FPCR=0\n",native?"NATIVE":"SOURCE",calls,bytes,input_bytes,independent);
}
void srtm_taumol23_(PARAMETERS){
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("every-entry FPCR");
 if(!reference){
  void *s=dlsym(RTLD_NEXT,"srtm_taumol23_");if(!s)fail("original body");memcpy(&reference,&s,sizeof reference);
  Dl_info original={0};if(!dladdr(s,&original)||!original.dli_fbase)fail("original image");image=original.dli_fbase;
  step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");if(!step)fail("forecast phase");bind_globals();
  inputs=fopen("srtm23-inputs.bin","wb");source=fopen("srtm23-fortran.bin","wb");if(srtm_taumol23_assembly_)native=fopen("srtm23-assembly.bin","wb");
  if(!inputs||!source||(srtm_taumol23_assembly_&&!native))fail("capture open");
  if(setvbuf(inputs,NULL,_IOFBF,1<<20)||setvbuf(source,NULL,_IOFBF,1<<20)||(native&&setvbuf(native,NULL,_IOFBF,1<<20)))fail("capture buffers");provenance();
 }
 Dl_info caller={0};void *ret=__builtin_return_address(0);if(!dladdr(ret,&caller)||caller.dli_fbase!=image||(uintptr_t)ret-(uintptr_t)image!=0x872d38||*step<0||*step>24)fail("original scoped caller/phase");
 void *all[24]={ARGUMENTS};int32_t d[4];memcpy(d,a1,4);memcpy(d+1,a2,4);memcpy(d+2,a3,4);memcpy(d+3,a0,4);size_t sizes[24];capacities(d,all,sizes);
 for(int z=20;z<23;++z){
  for(int k=0;k<24;++k)if(k!=z&&sizes[k]){uintptr_t x=(uintptr_t)all[z],y=(uintptr_t)all[k];if(x<y+sizes[k]&&y<x+sizes[z])fail("disjoint complete outputs");}
  for(int k=0;k<8;++k){uintptr_t x=(uintptr_t)all[z],y=(uintptr_t)globals[k];if(x<y+global_sizes[k]&&y<x+sizes[z])fail("outputs disjoint from globals");}
 }
 unsigned char constants[10308];size_t co=0;for(int z=0;z<8;++z){memcpy(constants+co,globals[z],global_sizes[z]);co+=global_sizes[z];}if(co!=sizeof constants)fail("complete global record");
 unsigned char *snap[24]={0};for(int z=0;z<24;++z)if(z<20||z==23){snap[z]=malloc(sizes[z]?sizes[z]:1);if(!snap[z])fail("readonly snapshots");memcpy(snap[z],all[z],sizes[z]);}
 unsigned char *before[3],*shadow[3];for(int z=0;z<3;++z){size_t sz=sizes[z+20];before[z]=malloc(sz?sz:1);shadow[z]=malloc(sz?sz:1);if(!before[z]||!shadow[z])fail("complete incoming storage");memcpy(before[z],all[z+20],sz);memcpy(shadow[z],before[z],sz);}
 int32_t hs[2]={*step,1};FILE *streams[3]={inputs,source,native};for(int z=0;z<3;++z)if(streams[z]){writeall(streams[z],&calls,8);writeall(streams[z],hs,8);writeall(streams[z],d,16);}
 writeall(inputs,a0,32);writeall(inputs,constants,sizeof constants);for(int z=4;z<20;++z)writeall(inputs,all[z],sizes[z]);writeall(inputs,a23,sizes[23]);for(int z=0;z<3;++z)writeall(inputs,before[z],sizes[z+20]);
 if(native){reference(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,shadow[0],shadow[1],shadow[2],a23);srtm_taumol23_assembly_(ARGUMENTS);}else{reference(ARGUMENTS);for(int z=0;z<3;++z)memcpy(shadow[z],all[z+20],sizes[z+20]);}
 __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved FPCR");
 for(int z=0;z<24;++z)if(snap[z]){if(memcmp(snap[z],all[z],sizes[z]))fail("complete readonly arguments unchanged");free(snap[z]);}
 co=0;for(int z=0;z<8;++z){if(memcmp(constants+co,globals[z],global_sizes[z]))fail("complete numerical globals unchanged");co+=global_sizes[z];}
 const double *out[3]={(double *)shadow[0],(double *)shadow[1],(double *)shadow[2]};physical(d,all,(const unsigned char *const *)before,out,1);
 size_t returned=32,received=32+32+sizeof constants;for(int z=4;z<20;++z)received+=sizes[z];received+=sizes[23];
 for(int z=0;z<3;++z){
  if(native&&memcmp(shadow[z],all[z+20],sizes[z+20])){size_t first=0;const unsigned char *p=all[z+20];while(shadow[z][first]==p[first])++first;fprintf(stderr,"SRTM23 mismatch call=%" PRIu64 " phase=%d field=%d byte=%zu source=%02x native=%02x\n",calls,*step,z,first,shadow[z][first],p[first]);fail("complete native bytes");}
  writeall(source,shadow[z],sizes[z+20]);if(native)writeall(native,all[z+20],sizes[z+20]);returned+=sizes[z+20];received+=sizes[z+20];free(before[z]);free(shadow[z]);
 }
 ++calls;++phases[*step];bytes+=returned;input_bytes+=received;
}

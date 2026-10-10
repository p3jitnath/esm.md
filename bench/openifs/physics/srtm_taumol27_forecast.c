/* Verify ozone absorption and molecular scattering in shortwave band 27.
 * Columns use 10^20 molecules/cm^2 and coefficients use the inverse column unit.
 * Solar values use W/m^2. Preserve every complete incoming storage byte. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PARAMETERS void *a0, void *a1, void *a2, void *a3, void *a4, void *a5, void *a6, void *a7, void *a8, void *a9, void *a10, void *a11, void *a12, void *a13, void *a14, void *a15, void *a16, void *a17
#define ARGUMENTS a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17
typedef void (*kernel)(PARAMETERS);
void srtm_taumol27_assembly_(PARAMETERS) __attribute__((weak));
static double *absa,*absb,*solar,*rayleigh,*scale;
static int32_t *reference_layer,*species_a,*species_b;
static uint64_t independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,negative_factors,solar_crossings;
static double min_factor=DBL_MAX,max_factor=-DBL_MAX,max_absorption;
static void fail(const char *s){fprintf(stderr,"SRTM27 failed %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static const char *global_names[8]={"yoesrta27.eq.1_","yoesrta27.eq.0_","__yoesrta27_MOD_sfluxrefc","__yoesrta27_MOD_raylc","__yoesrta27_MOD_scalekur","__yoesrta27_MOD_layreffr","__yoesrtwn_MOD_nspa","__yoesrtwn_MOD_nspb"};
static const size_t global_sizes[8]={8320,30080,128,128,8,4,56,56};
static void *globals[8];
static void bind_globals(void){
 for(int k=0;k<8;++k){globals[k]=dlsym(RTLD_NEXT,global_names[k]);if(!globals[k])fail("all declared coefficient/global bindings");}
 absa=globals[0];absb=globals[1];solar=globals[2];rayleigh=globals[3];scale=globals[4];reference_layer=globals[5];species_a=globals[6];species_b=globals[7];
}
static void capacities(const int32_t *d,void *const *a,size_t *sizes){
 int n=d[1]-d[0]+1,H=d[2],V=d[3];
 if(d[0]<1||n<0||n>4096||H<0||V<H||V>512)fail("complete shape bounds");
 sizes[0]=32;for(int z=1;z<4;++z)sizes[z]=4;
 for(int z=4;z<13;++z)sizes[z]=(size_t)n*V*(z>=8&&z<=10?4:8);
 sizes[13]=(size_t)n*4;sizes[14]=(size_t)n*16*8;sizes[15]=sizes[16]=(size_t)n*V*16*8;sizes[17]=(size_t)n*8;
 for(int z=0;z<18;++z)if(sizes[z]&&(!a[z]||(uintptr_t)a[z]%((z<4||z>=8&&z<=10||z==13)?4:8)||(uintptr_t)a[z]>UINTPTR_MAX-sizes[z]))fail("complete capacity and alignment");
 const double *mu=a[17];const int32_t *trop=a[13],*jp=a[8],*jt=a[9],*jt1=a[10];
 if(species_a[11]!=1||species_b[11]!=1||*reference_layer<13||*reference_layer>59)fail("declared lower/upper coefficient species and solar reference");
 for(int j=0;j<n;++j){
  if(!isfinite(mu[j])||mu[j]<-1||mu[j]>1)fail("finite solar zenith cosine");
  if(mu[j]<=0)continue;
  if(trop[j]<0||trop[j]>H||(H&&trop[j]==0))fail("positive lower layers protect previous-pressure input");
  for(int k=0;k<H;++k){
   size_t i=j+(size_t)n*k;
   if(jt[i]<1||jt[i]>4||jt1[i]<1||jt1[i]>4)fail("temperature corners before original execution");
   if(k<trop[j]){if(jp[i]<1||jp[i]>12)fail("lower pressure corners before original execution");}
   else{if(k<1||jp[i]<13||jp[i]>58)fail("upper pressure corners and previous-row capacity before original execution");}
  }
 }
}
static void physical(const int32_t *d,void *const *a,const unsigned char *const *before,const double *const *out,int require_solar){
 int n=d[1]-d[0]+1,H=d[2],V=d[3],ref=*reference_layer,sol=H;
 const double *f00=a[4],*f01=a[5],*f10=a[6],*f11=a[7],*molecules=a[11],*ozone=a[12],*mu=a[17];
 const int32_t *jp=a[8],*jt=a[9],*jt1=a[10],*trop=a[13];
 unsigned char *written=calloc(n?n:1,1);if(!written)fail("solar definition flags");
 /* The original solar-layer scalar belongs to the whole upper pass.
  * Preserve increasing layer and column order when proving its writes. */
 for(int k=0;k<H;++k)for(int j=0;j<n;++j)if(mu[j]>0&&k>=trop[j]){
  size_t ci=j+(size_t)n*k;++previous_reads;
  if(jp[ci-n]<ref&&jp[ci]>=ref){sol=k+1;++solar_crossings;}
  if(k+1==sol)written[j]=1;
 }
 for(int j=0;j<n;++j){
  int day=mu[j]>0;if(day)++day_columns;else ++night_columns;
  if(day&&require_solar&&!written[j])fail("consumed daylight solar spectrum not defined before caller read");
  for(int g=0;g<16;++g){
   size_t sun=j+(size_t)n*g;
   if(day&&g<8&&written[j]){
    if(!isfinite(*scale)||*scale<0||!isfinite(solar[g])||solar[g]<0)fail("nonnegative finite solar inputs");
    long double expected=(long double)*scale*solar[g];
    if(!isfinite(out[0][sun])||out[0][sun]<0||fabsl((long double)out[0][sun]-expected)>8*DBL_EPSILON*fabsl(expected)+4*DBL_TRUE_MIN||bits(out[0][sun])!=bits(*scale*solar[g]))fail("complete corrected fixed solar spectrum");
    ++solar_copies;independent+=2;
   }else{
    if(memcmp((const unsigned char *)out[0]+sun*8,before[0]+sun*8,8))fail("complete unchanged solar storage");
    preserved_bytes+=8;++independent;
   }
   for(int k=0;k<V;++k){
    size_t ci=j+(size_t)n*k,ix=j+(size_t)n*(k+V*g);
    if(day&&g<8&&k<H){
     if(!isfinite(molecules[ci])||molecules[ci]<0||!isfinite(ozone[ci])||ozone[ci]<0||!isfinite(rayleigh[g])||rayleigh[g]<0)fail("finite nonnegative active columns and scattering");
     long double scattering=(long double)molecules[ci]*rayleigh[g];
     if(!isfinite(out[2][ix])||out[2][ix]<0||fabsl((long double)out[2][ix]-scattering)>16*DBL_EPSILON*fabsl(scattering)+4*DBL_TRUE_MIN)fail("independent dimensionless molecular scattering");
     int lower=k<trop[j],rows=lower?65:235;
     const double *table=lower?absa:absb;
     int i0=(jp[ci]-(lower?1:13))*5+jt[ci]-1,i1=(jp[ci]-(lower?0:12))*5+jt1[ci]-1;
     double f[4]={f00[ci],f10[ci],f01[ci],f11[ci]},r[4]={table[i0+rows*g],table[i0+1+rows*g],table[i1+rows*g],table[i1+1+rows*g]};
     long double sum=0,weighted=0,absolute=0;
     for(int z=0;z<4;++z){
      if(!isfinite(f[z])||!isfinite(r[z])||r[z]<0)fail("finite interpolation and nonnegative table");
      sum+=f[z];weighted+=(long double)f[z]*r[z];absolute+=fabsl((long double)f[z]*r[z]);
      if(f[z]<0)++negative_factors;min_factor=fmin(min_factor,f[z]);max_factor=fmax(max_factor,f[z]);
     }
     if(fabsl(sum-1)>64*DBL_EPSILON)fail("pressure-temperature factors sum to one");
     long double absorption=(long double)ozone[ci]*weighted,condition=(long double)ozone[ci]*absolute;
     if(!isfinite(out[1][ix])||out[1][ix]<0||fabsl((long double)out[1][ix]-absorption)>64*DBL_EPSILON*condition+8*DBL_TRUE_MIN)fail("independent lower/upper ozone optical depth");
     if(ozone[ci]==0&&out[1][ix]!=0)fail("zero ozone absorption limit");
     if(molecules[ci]==0&&out[2][ix]!=0)fail("zero molecular scattering limit");
     if(f00[ci]==1&&f01[ci]==0&&f10[ci]==0&&f11[ci]==0&&r[0]==0x1p-8&&(ozone[ci]==256||ozone[ci]==512||ozone[ci]==1024)){
      if(bits(out[1][ix])!=bits(ozone[ci]*0x1p-8))fail("known unit and doubled ozone optical depth");++independent;
     }
     if(molecules[ci]==0x1p20&&rayleigh[g]==0x1p-20){
      if(bits(out[2][ix])!=UINT64_C(0x3ff0000000000000))fail("known unit molecular scattering");++independent;
     }
     if(lower)++lower_layers;else ++upper_layers;
     max_absorption=fmax(max_absorption,out[1][ix]);independent+=5;
    }else{
     for(int z=1;z<3;++z)if(memcmp((const unsigned char *)out[z]+ix*8,before[z]+ix*8,8))fail("complete unchanged night unused-point extra-layer storage");
     preserved_bytes+=16;independent+=2;
    }
   }
  }
 }
 free(written);
}

static kernel reference;
static const int32_t *step;
static const void *image;
static FILE *inputs,*source,*native;
static uint64_t calls,bytes,input_bytes,phases[25];
static void provenance(void){
 const char *names[14]={"__yoesrta27_MOD_ka_d","__yoesrta27_MOD_kb_d","__yoesrta27_MOD_ka","__yoesrta27_MOD_kb","yoesrta27.eq.1_","yoesrta27.eq.0_","__yoesrta27_MOD_sfluxref","__yoesrta27_MOD_rayl","__yoesrta27_MOD_sfluxrefc","__yoesrta27_MOD_raylc","__yoesrta27_MOD_scalekur","__yoesrtwn_MOD_rwgt","__yoesrtm_MOD_ngn","__yoesrta27_MOD_layreffr"};
 const size_t sizes[14]={8320,30080,8320,30080,8320,30080,128,128,128,128,8,1792,896,4};
 FILE *f=fopen("srtm27-coefficient-provenance.bin","wb");if(!f)fail("provenance open");
 for(int z=0;z<14;++z){void *p=dlsym(RTLD_NEXT,names[z]);if(!p)fail("raw coefficient provenance");writeall(f,p,sizes[z]);}
 for(int z=0;z<4;++z){const char *name=z==0?"__yoesrtwn_MOD_ngc":z==1?"__yoesrtwn_MOD_ngs":z==2?"__yoesrtwn_MOD_nspa":"__yoesrtwn_MOD_nspb";void *p=dlsym(RTLD_NEXT,name);if(!p)fail("group/species provenance");writeall(f,p,56);}
 if(fclose(f))fail("provenance close");
}
__attribute__((destructor)) static void finish(void){
 if(!source)return;
 if(fclose(inputs)||fclose(source)||(native&&fclose(native)))fail("capture close");if(!calls)fail("no original calls");
 FILE *f=fopen("srtm27-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"complete_return_bytes\":%" PRIu64 ",\"complete_input_bytes\":%" PRIu64 ",\"independent_relations\":%" PRIu64 ",\"day_columns\":%" PRIu64 ",\"night_columns\":%" PRIu64 ",\"lower_spectral_layers\":%" PRIu64 ",\"upper_spectral_layers\":%" PRIu64 ",\"solar_copies\":%" PRIu64 ",\"preserved_storage_bytes\":%" PRIu64 ",\"active_previous_pressure_reads\":%" PRIu64 ",\"solar_crossings\":%" PRIu64 ",\"negative_interpolation_factors\":%" PRIu64 ",\"factor_range\":[%.17g,%.17g],\"max_absorption\":%.17g,\"native_compared\":%s,\"differing_bytes\":0,\"FPCR_zero_every_entry\":true,\"source_return_offset\":\"0x872b54\",\"active_points\":8,\"complete_points\":16,\"step_calls\":[",calls,bytes,input_bytes,independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,solar_crossings,negative_factors,min_factor,max_factor,max_absorption,native?"true":"false");
 for(int z=0;z<25;++z)fprintf(f,"%s%" PRIu64,z?",":"",phases[z]);fputs("]}\n",f);if(fclose(f))fail("metadata close");
 fprintf(stderr,"SRTM27 %s PASS calls=%" PRIu64 " full_return_bytes=%" PRIu64 " full_input_bytes=%" PRIu64 " independent=%" PRIu64 " differing_bytes=0 FPCR=0\n",native?"NATIVE":"SOURCE",calls,bytes,input_bytes,independent);
}
void srtm_taumol27_(PARAMETERS){
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("every-entry FPCR");
 if(!reference){
  void *s=dlsym(RTLD_NEXT,"srtm_taumol27_");if(!s)fail("original body");memcpy(&reference,&s,sizeof reference);
  Dl_info original={0};if(!dladdr(s,&original)||!original.dli_fbase)fail("original image");image=original.dli_fbase;
  step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");if(!step)fail("forecast phase");bind_globals();
  inputs=fopen("srtm27-inputs.bin","wb");source=fopen("srtm27-fortran.bin","wb");if(srtm_taumol27_assembly_)native=fopen("srtm27-assembly.bin","wb");
  if(!inputs||!source||(srtm_taumol27_assembly_&&!native))fail("capture open");
  if(setvbuf(inputs,NULL,_IOFBF,1<<20)||setvbuf(source,NULL,_IOFBF,1<<20)||(native&&setvbuf(native,NULL,_IOFBF,1<<20)))fail("capture buffers");provenance();
 }
 Dl_info caller={0};void *ret=__builtin_return_address(0);if(!dladdr(ret,&caller)||caller.dli_fbase!=image||(uintptr_t)ret-(uintptr_t)image!=0x872b54||*step<0||*step>24)fail("original scoped caller/phase");
 void *all[18]={ARGUMENTS};int32_t d[4];memcpy(d,a1,4);memcpy(d+1,a2,4);memcpy(d+2,a3,4);memcpy(d+3,a0,4);size_t sizes[18];capacities(d,all,sizes);
 for(int z=14;z<17;++z){
  for(int k=0;k<18;++k)if(k!=z&&sizes[k]){uintptr_t x=(uintptr_t)all[z],y=(uintptr_t)all[k];if(x<y+sizes[k]&&y<x+sizes[z])fail("disjoint complete outputs");}
  for(int k=0;k<8;++k){uintptr_t x=(uintptr_t)all[z],y=(uintptr_t)globals[k];if(x<y+global_sizes[k]&&y<x+sizes[z])fail("outputs disjoint from globals");}
 }
 unsigned char constants[38780];size_t co=0;for(int z=0;z<8;++z){memcpy(constants+co,globals[z],global_sizes[z]);co+=global_sizes[z];}if(co!=sizeof constants)fail("complete global record");
 unsigned char *snap[18]={0};for(int z=0;z<18;++z)if(z<14||z==17){snap[z]=malloc(sizes[z]?sizes[z]:1);if(!snap[z])fail("readonly snapshots");memcpy(snap[z],all[z],sizes[z]);}
 unsigned char *before[3],*shadow[3];for(int z=0;z<3;++z){size_t sz=sizes[z+14];before[z]=malloc(sz?sz:1);shadow[z]=malloc(sz?sz:1);if(!before[z]||!shadow[z])fail("complete incoming storage");memcpy(before[z],all[z+14],sz);memcpy(shadow[z],before[z],sz);}
 int32_t hs[2]={*step,1};FILE *streams[3]={inputs,source,native};for(int z=0;z<3;++z)if(streams[z]){writeall(streams[z],&calls,8);writeall(streams[z],hs,8);writeall(streams[z],d,16);}
 writeall(inputs,a0,32);writeall(inputs,constants,sizeof constants);for(int z=4;z<14;++z)writeall(inputs,all[z],sizes[z]);writeall(inputs,a17,sizes[17]);for(int z=0;z<3;++z)writeall(inputs,before[z],sizes[z+14]);
 if(native){reference(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,shadow[0],shadow[1],shadow[2],a17);srtm_taumol27_assembly_(ARGUMENTS);}else{reference(ARGUMENTS);for(int z=0;z<3;++z)memcpy(shadow[z],all[z+14],sizes[z+14]);}
 __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved FPCR");
 for(int z=0;z<18;++z)if(snap[z]){if(memcmp(snap[z],all[z],sizes[z]))fail("complete readonly arguments unchanged");free(snap[z]);}
 co=0;for(int z=0;z<8;++z){if(memcmp(constants+co,globals[z],global_sizes[z]))fail("complete numerical globals unchanged");co+=global_sizes[z];}
 const double *out[3]={(double *)shadow[0],(double *)shadow[1],(double *)shadow[2]};physical(d,all,(const unsigned char *const *)before,out,1);
 size_t returned=32,received=32+32+sizeof constants;for(int z=4;z<14;++z)received+=sizes[z];received+=sizes[17];
 for(int z=0;z<3;++z){
  if(native&&memcmp(shadow[z],all[z+14],sizes[z+14])){size_t first=0;const unsigned char *p=all[z+14];while(shadow[z][first]==p[first])++first;fprintf(stderr,"SRTM27 mismatch call=%" PRIu64 " phase=%d field=%d byte=%zu source=%02x native=%02x\n",calls,*step,z,first,shadow[z][first],p[first]);fail("complete native bytes");}
  writeall(source,shadow[z],sizes[z+14]);if(native)writeall(native,all[z+14],sizes[z+14]);returned+=sizes[z+14];received+=sizes[z+14];free(before[z]);free(shadow[z]);
 }
 ++calls;++phases[*step];bytes+=returned;input_bytes+=received;
}

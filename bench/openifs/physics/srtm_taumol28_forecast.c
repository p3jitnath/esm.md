/* Check complete shortwave band-28 ozone and oxygen absorption.
 * Molecular columns count approximately 10^20 molecules/cm^2.
 * Coefficients have the inverse column unit. Optical depth has no unit.
 * Solar flux uses W/m^2. Preserve every complete incoming storage byte. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PARAMETERS void *a0, void *a1, void *a2, void *a3, void *a4, void *a5, void *a6, void *a7, void *a8, void *a9, void *a10, void *a11, void *a12, void *a13, void *a14, void *a15, void *a16, void *a17, void *a18, void *a19
#define ARGUMENTS a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19
typedef void (*kernel)(PARAMETERS);
void srtm_taumol28_assembly_(PARAMETERS) __attribute__((weak));
static double *absa,*absb,*solar,*rayleigh,*ratio_weight;
static int32_t *reference_layer,*species_a,*species_b;
static uint64_t independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,negative_factors,solar_crossings,mixture_checks[2],clamped_mixtures[2],mixture_bins[2][8];
static double min_factor=DBL_MAX,max_factor=-DBL_MAX,max_absorption,min_mixture[2]={DBL_MAX,DBL_MAX},max_mixture[2]={-DBL_MAX,-DBL_MAX};
static void fail(const char *s){fprintf(stderr,"SRTM28 failed %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static const char *global_names[8]={"yoesrta28.eq.1_","yoesrta28.eq.0_","__yoesrta28_MOD_sfluxrefc","__yoesrta28_MOD_rayl","__yoesrta28_MOD_layreffr","__yoesrta28_MOD_strrat","__yoesrtwn_MOD_nspa","__yoesrtwn_MOD_nspb"};
static const size_t global_sizes[8]={74880,150400,640,8,4,8,56,56};
static void *globals[8];
static void bind_globals(void){
 for(int k=0;k<8;++k){globals[k]=dlsym(RTLD_NEXT,global_names[k]);if(!globals[k])fail("complete declared coefficients and globals");}
 absa=globals[0];absb=globals[1];solar=globals[2];rayleigh=globals[3];reference_layer=globals[4];ratio_weight=globals[5];species_a=globals[6];species_b=globals[7];
}
static void sizes_for_shape(int n,int V,size_t *sizes){
 sizes[0]=32;for(int z=1;z<4;++z)sizes[z]=4;
 for(int z=4;z<15;++z)sizes[z]=(size_t)n*V*(z>=8&&z<=10?4:8);
 sizes[11]=(size_t)n*8;sizes[15]=(size_t)n*4;sizes[16]=(size_t)n*16*8;sizes[17]=sizes[18]=(size_t)n*V*16*8;sizes[19]=(size_t)n*8;
}
static void capacities(const int32_t *d,void *const *a,size_t *sizes){
 int64_t count=(int64_t)d[1]-(int64_t)d[0]+1;int H=d[2],V=d[3];
 if(d[0]<1||d[1]>INT32_MAX-1||count<0||count>4096||H<0||V<H||V>512)fail("complete shape bounds");
 int n=(int)count;sizes_for_shape(n,V,sizes);
 for(int z=0;z<20;++z)if(sizes[z]&&(!a[z]||(uintptr_t)a[z]%((z<4||z>=8&&z<=10||z==15)?4:8)||(uintptr_t)a[z]>UINTPTR_MAX-sizes[z]))fail("complete capacity and alignment");
 if(species_a[12]!=9||species_b[12]!=5||*reference_layer<13||*reference_layer>59||!isfinite(*ratio_weight)||*ratio_weight<=0||*ratio_weight>0x1p16)fail("original lower-nine upper-five table strides and ratio");
 const double *mu=a[19],*cap=a[11],*oxygen=a[13],*ozone=a[14];const int32_t *trop=a[15],*jp=a[8],*jt=a[9],*jt1=a[10];
 for(int j=0;j<n;++j){
  if(!isfinite(mu[j])||mu[j]<-1||mu[j]>1)fail("finite solar zenith cosine");
  if(mu[j]<=0)continue;
  if(!isfinite(cap[j])||cap[j]<=0||cap[j]>=1)fail("positive mixture cap below one");
  if(trop[j]<0||trop[j]>H||(H&&trop[j]==0))fail("positive tropopause prevents source previous-layer underflow");
  for(int k=0;k<H;++k){
   size_t i=j+(size_t)n*k;int lower=k<trop[j];
   if(jt[i]<1||jt[i]>4||jt1[i]<1||jt1[i]>4)fail("temperature corners before original execution");
   if(lower){if(jp[i]<1||jp[i]>12)fail("complete lower pressure corners");}
   else if(k<1||jp[i]<13||jp[i]>58)fail("upper pressure corners and complete previous-pressure row");
   for(int z=4;z<8;++z){double v=((const double*)a[z])[i];if(!isfinite(v)||fabs(v)>0x1p20)fail("finite bounded pressure-temperature factors");}
   for(int z=12;z<=14;++z){double v=((const double*)a[z])[i];if(!isfinite(v)||v<0||v>0x1p300)fail("finite nonnegative molecular columns");}
   double combined=ozone[i]+*ratio_weight*oxygen[i];
   if(!isfinite(combined)||combined<DBL_MIN)fail("normal positive finite active mixture denominator");
   double fraction=ozone[i]/combined;if(fraction>=cap[j])fraction=cap[j];
   double multiple=(lower?8.:4.)*fraction;
   if(!isfinite(multiple)||multiple<0||multiple>=(lower?8.:4.))fail("bounded source INT and MOD mixture argument");
  }
 }
 for(int g=0;g<6;++g){
  for(int b=0;b<5;++b)if(!isfinite(solar[g+16*b])||solar[g+16*b]<0||solar[g+16*b]>0x1p100)fail("finite nonnegative full solar mixture table");
  for(int z=0;z<585;++z)if(!isfinite(absa[z+585*g])||absa[z+585*g]<0||absa[z+585*g]>0x1p100)fail("complete active lower mixture table");
  for(int z=0;z<1175;++z)if(!isfinite(absb[z+1175*g])||absb[z+1175*g]<0||absb[z+1175*g]>0x1p100)fail("complete active upper mixture table");
 }
 if(!isfinite(*rayleigh)||*rayleigh<0||*rayleigh>0x1p100)fail("finite nonnegative Rayleigh coefficient");
}
/* The upper solar selector is shared by all columns. Track its writes in
 * original layer-major order, including every change by another column. */
static int *solar_layers(const int32_t *d,void *const *a,int required,int count){
 int n=d[1]-d[0]+1,H=d[2],sol=H;
 const double *mu=a[19];const int32_t *jp=a[8],*trop=a[15];
 int *last=malloc((n?n:1)*sizeof *last);if(!last)fail("complete solar-write flags");
 for(int j=0;j<n;++j)last[j]=-1;
 for(int k=0;k<H;++k)for(int j=0;j<n;++j)if(mu[j]>0&&k>=trop[j]){
  size_t i=j+(size_t)n*k;if(count)++previous_reads;
  if(jp[i-n]<*reference_layer&&jp[i]>=*reference_layer){sol=k+1;if(count)++solar_crossings;}
  if(k+1==sol)last[j]=k;
 }
 if(required&&H)for(int j=0;j<n;++j)if(mu[j]>0&&last[j]<0)fail("each consumed daylight solar cell must be defined");
 return last;
}
static void solar_scope(const int32_t *d,void *const *a,int required){int *s=solar_layers(d,a,required,0);free(s);}
static void physical(const int32_t *d,void *const *a,const unsigned char *const *before,const double *const *out,int require_solar){
 int n=d[1]-d[0]+1,H=d[2],V=d[3];
 const double *f00=a[4],*f01=a[5],*f10=a[6],*f11=a[7],*cap=a[11],*molecules=a[12],*oxygen=a[13],*ozone=a[14],*mu=a[19];
 const int32_t *jp=a[8],*jt=a[9],*jt1=a[10],*trop=a[15];
 int *last=solar_layers(d,a,require_solar,1);
 for(int j=0;j<n;++j){
  int day=mu[j]>0;if(day)++day_columns;else ++night_columns;
  for(int g=0;g<16;++g){
   size_t sun=j+(size_t)n*g;
   if(day&&g<6&&last[j]>=0){
    size_t i=j+(size_t)n*last[j];long double combined=(long double)ozone[i]+(long double)*ratio_weight*oxygen[i],fraction=(long double)ozone[i]/combined;
    if(fraction>=cap[j])fraction=cap[j];
    long double grid=4*fraction;int bin=(int)grid;long double f=grid-bin;
    long double lo=solar[g+16*bin],hi=solar[g+16*(bin+1)],expected=(1-f)*lo+f*hi,condition=0;
    for(int b=0;b<5;++b)condition+=fabsl(solar[g+16*b]);
    if(!isfinite(out[0][sun])||out[0][sun]<0||fabsl((long double)out[0][sun]-expected)>512*DBL_EPSILON*condition+256*DBL_TRUE_MIN)fail("independent five-node upper mixture solar flux");
    ++solar_copies;independent+=3;
   }else{
    if(memcmp((const unsigned char*)out[0]+sun*8,before[0]+sun*8,8))fail("complete preserved solar storage");
    preserved_bytes+=8;++independent;
   }
   for(int k=0;k<V;++k){
    size_t i=j+(size_t)n*k,ix=j+(size_t)n*(k+V*g);
    if(day&&g<6&&k<H){
     long double scattering=(long double)molecules[i]**rayleigh;
     if(!isfinite(out[2][ix])||out[2][ix]<0||fabsl((long double)out[2][ix]-scattering)>16*DBL_EPSILON*fabsl(scattering)+4*DBL_TRUE_MIN)fail("independent dimensionless molecular scattering");
     int lower=k<trop[j],pass=lower?0:1,stride=lower?9:5,rows=lower?585:1175;
     const double *table=lower?absa:absb;double f[4]={f00[i],f10[i],f01[i],f11[i]};long double sum=0;
     for(int z=0;z<4;++z){sum+=f[z];if(f[z]<0)++negative_factors;min_factor=fmin(min_factor,f[z]);max_factor=fmax(max_factor,f[z]);}
     if(fabsl(sum-1)>64*DBL_EPSILON)fail("pressure-temperature weights sum to one");
     long double combined=(long double)ozone[i]+(long double)*ratio_weight*oxygen[i],mixture=(long double)ozone[i]/combined;
     if(mixture>=cap[j]){mixture=cap[j];++clamped_mixtures[pass];}
     long double grid=(lower?8:4)*mixture;int bin=(int)grid;long double fraction=grid-bin;
     if(bin<0||bin>=(lower?8:4)||fraction<0||fraction>=1)fail("independent bounded mixture fraction");
     ++mixture_checks[pass];++mixture_bins[pass][bin];min_mixture[pass]=fmin(min_mixture[pass],(double)mixture);max_mixture[pass]=fmax(max_mixture[pass],(double)mixture);
     int i0=((jp[i]-(lower?1:13))*5+jt[i]-1)*stride+bin,i1=((jp[i]-(lower?0:12))*5+jt1[i]-1)*stride+bin;
     int corner[4]={i0,i0+stride,i1,i1+stride};long double value=0,absolute=0;
     /* Expand eight mathematical weights independently of the source's
      * two rounded four-product brackets. Both passes include both gases. */
     for(int z=0;z<4;++z){
      long double lo=table[corner[z]+rows*g],hi=table[corner[z]+1+rows*g];
      value+=(long double)f[z]*((1-fraction)*lo+fraction*hi);
      absolute+=fabsl((long double)f[z])*((1-fraction)*lo+fraction*hi);
     }
     long double expected=combined*value,tiny=256*(long double)DBL_TRUE_MIN*(1+ozone[i]+*ratio_weight*oxygen[i]);
     if(!isfinite(out[1][ix])||out[1][ix]<0||fabsl((long double)out[1][ix]-expected)>512*DBL_EPSILON*combined*absolute+tiny)fail("independent complete ozone-oxygen optical depth");
     if(molecules[i]==0&&out[2][ix]!=0)fail("zero molecular scattering limit");
     if(molecules[i]==0x1p20&&*rayleigh==0x1p-20){if(bits(out[2][ix])!=UINT64_C(0x3ff0000000000000))fail("known unit molecular scattering");++independent;}
     if(lower)++lower_layers;else ++upper_layers;
     max_absorption=fmax(max_absorption,out[1][ix]);independent+=8;
    }else{
     for(int z=1;z<3;++z)if(memcmp((const unsigned char*)out[z]+ix*8,before[z]+ix*8,8))fail("complete preserved night unused-point extra-layer storage");
     preserved_bytes+=16;independent+=2;
    }
   }
  }
 }
 free(last);
}

static kernel reference;
static const int32_t *step;
static const void *image;
static uintptr_t return_offset;
static FILE *inputs,*source,*native;
static uint64_t calls,bytes,input_bytes,phases[25];
static void provenance(void){
 const char *names[17]={"__yoesrta28_MOD_ka_d","__yoesrta28_MOD_kb_d","__yoesrta28_MOD_ka","__yoesrta28_MOD_kb","yoesrta28.eq.1_","yoesrta28.eq.0_","__yoesrta28_MOD_sfluxref","__yoesrta28_MOD_sfluxrefc","__yoesrta28_MOD_rayl","__yoesrta28_MOD_layreffr","__yoesrta28_MOD_strrat","__yoesrtwn_MOD_rwgt","__yoesrtm_MOD_ngn","__yoesrtwn_MOD_ngc","__yoesrtwn_MOD_ngs","__yoesrtwn_MOD_nspa","__yoesrtwn_MOD_nspb"};
 const size_t sizes[17]={74880,150400,74880,150400,74880,150400,640,640,8,4,8,1792,896,56,56,56,56};
 FILE *f=fopen("srtm28-coefficient-provenance.bin","wb");if(!f)fail("complete coefficient provenance open");
 for(int z=0;z<17;++z){void *p=dlsym(RTLD_NEXT,names[z]);if(!p)fail("raw converted and reduced coefficient provenance");writeall(f,p,sizes[z]);}
 if(fclose(f))fail("complete coefficient provenance close");
}
__attribute__((destructor)) static void finish(void){
 if(!source)return;
 if(fclose(inputs)||fclose(source)||(native&&fclose(native)))fail("capture close");if(!calls)fail("no original calls");
 FILE *f=fopen("srtm28-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"complete_return_bytes\":%" PRIu64 ",\"complete_input_bytes\":%" PRIu64 ",\"independent_relations\":%" PRIu64 ",\"day_columns\":%" PRIu64 ",\"night_columns\":%" PRIu64 ",\"lower_spectral_layers\":%" PRIu64 ",\"upper_spectral_layers\":%" PRIu64 ",\"solar_copies\":%" PRIu64 ",\"preserved_storage_bytes\":%" PRIu64 ",\"active_previous_pressure_reads\":%" PRIu64 ",\"solar_crossings\":%" PRIu64 ",\"negative_interpolation_factors\":%" PRIu64 ",\"factor_range\":[%.17g,%.17g],\"max_absorption\":%.17g,\"native_compared\":%s,\"differing_bytes\":0,\"FPCR_zero_every_entry\":true,\"source_return_offset\":\"0x%lx\",\"active_points\":6,\"complete_points\":16,\"step_calls\":[",calls,bytes,input_bytes,independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,solar_crossings,negative_factors,min_factor,max_factor,max_absorption,native?"true":"false",(unsigned long)return_offset);
 for(int z=0;z<25;++z)fprintf(f,"%s%" PRIu64,z?",":"",phases[z]);fputs("]}\n",f);if(fclose(f))fail("metadata close");
 fprintf(stderr,"SRTM28 %s PASS calls=%" PRIu64 " full_return_bytes=%" PRIu64 " full_input_bytes=%" PRIu64 " independent=%" PRIu64 " differing_bytes=0 FPCR=0\n",native?"NATIVE":"SOURCE",calls,bytes,input_bytes,independent);
}
void srtm_taumol28_(PARAMETERS){
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("every-entry FPCR");
 if(!reference){
  void *s=dlsym(RTLD_NEXT,"srtm_taumol28_");if(!s)fail("original body");memcpy(&reference,&s,sizeof reference);
  Dl_info original={0};if(!dladdr(s,&original)||!original.dli_fbase)fail("original image");image=original.dli_fbase;
  step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");if(!step)fail("forecast phase");bind_globals();
  inputs=fopen("srtm28-inputs.bin","wb");source=fopen("srtm28-fortran.bin","wb");if(srtm_taumol28_assembly_)native=fopen("srtm28-assembly.bin","wb");
  if(!inputs||!source||(srtm_taumol28_assembly_&&!native))fail("capture open");
  if(setvbuf(inputs,NULL,_IOFBF,1<<20)||setvbuf(source,NULL,_IOFBF,1<<20)||(native&&setvbuf(native,NULL,_IOFBF,1<<20)))fail("capture buffers");provenance();
 }
 Dl_info caller={0};void *ret=__builtin_return_address(0);if(!dladdr(ret,&caller)||caller.dli_fbase!=image||!caller.dli_sname||strcmp(caller.dli_sname,"srtm_gas_optical_depth_")||*step<0||*step>24)fail("original scoped caller/phase");
 if(!return_offset)return_offset=(uintptr_t)ret-(uintptr_t)image;if(return_offset!=(uintptr_t)ret-(uintptr_t)image)fail("one frozen original caller site");
 void *all[20]={ARGUMENTS};int32_t d[4];memcpy(d,a1,4);memcpy(d+1,a2,4);memcpy(d+2,a3,4);memcpy(d+3,a0,4);size_t sizes[20];capacities(d,all,sizes);solar_scope(d,all,1);
 for(int z=16;z<19;++z){
  for(int k=0;k<20;++k)if(k!=z&&sizes[k]){uintptr_t x=(uintptr_t)all[z],y=(uintptr_t)all[k];if(x<y+sizes[k]&&y<x+sizes[z])fail("disjoint complete outputs");}
  for(int k=0;k<8;++k){uintptr_t x=(uintptr_t)all[z],y=(uintptr_t)globals[k];if(x<y+global_sizes[k]&&y<x+sizes[z])fail("outputs disjoint from globals");}
 }
 unsigned char constants[226052];size_t co=0;for(int z=0;z<8;++z){memcpy(constants+co,globals[z],global_sizes[z]);co+=global_sizes[z];}if(co!=sizeof constants)fail("complete global record");
 unsigned char *snap[20]={0};for(int z=0;z<20;++z)if(z<16||z==19){snap[z]=malloc(sizes[z]?sizes[z]:1);if(!snap[z])fail("readonly snapshots");if(sizes[z])memcpy(snap[z],all[z],sizes[z]);}
 unsigned char *before[3],*shadow[3];for(int z=0;z<3;++z){size_t sz=sizes[z+16];before[z]=malloc(sz?sz:1);shadow[z]=malloc(sz?sz:1);if(!before[z]||!shadow[z])fail("complete incoming storage");if(sz){memcpy(before[z],all[z+16],sz);memcpy(shadow[z],before[z],sz);}}
 int32_t hs[2]={*step,1};FILE *streams[3]={inputs,source,native};for(int z=0;z<3;++z)if(streams[z]){writeall(streams[z],&calls,8);writeall(streams[z],hs,8);writeall(streams[z],d,16);}
 writeall(inputs,a0,32);writeall(inputs,constants,sizeof constants);for(int z=4;z<16;++z)writeall(inputs,all[z],sizes[z]);writeall(inputs,a19,sizes[19]);for(int z=0;z<3;++z)writeall(inputs,before[z],sizes[z+16]);
 if(native){reference(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,shadow[0],shadow[1],shadow[2],a19);srtm_taumol28_assembly_(ARGUMENTS);}else{reference(ARGUMENTS);for(int z=0;z<3;++z)if(sizes[z+16])memcpy(shadow[z],all[z+16],sizes[z+16]);}
 __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved FPCR");
 for(int z=0;z<20;++z)if(snap[z]){if(sizes[z]&&memcmp(snap[z],all[z],sizes[z]))fail("complete readonly arguments unchanged");free(snap[z]);}
 co=0;for(int z=0;z<8;++z){if(memcmp(constants+co,globals[z],global_sizes[z]))fail("complete numerical globals unchanged");co+=global_sizes[z];}
 const double *out[3]={(double *)shadow[0],(double *)shadow[1],(double *)shadow[2]};physical(d,all,(const unsigned char *const *)before,out,1);
 if(native){const double *native_out[3]={a16,a17,a18};physical(d,all,(const unsigned char *const *)before,native_out,1);}
 size_t returned=32,received=32+32+sizeof constants;for(int z=4;z<16;++z)received+=sizes[z];received+=sizes[19];
 for(int z=0;z<3;++z){
  if(native&&sizes[z+16]&&memcmp(shadow[z],all[z+16],sizes[z+16])){size_t first=0;const unsigned char *p=all[z+16];while(shadow[z][first]==p[first])++first;fprintf(stderr,"SRTM28 mismatch call=%" PRIu64 " phase=%d field=%d byte=%zu source=%02x native=%02x\n",calls,*step,z,first,shadow[z][first],p[first]);fail("complete native bytes");}
  writeall(source,shadow[z],sizes[z+16]);if(native)writeall(native,all[z+16],sizes[z+16]);returned+=sizes[z+16];received+=sizes[z+16];free(before[z]);free(shadow[z]);
 }
 ++calls;++phases[*step];bytes+=returned;input_bytes+=received;
}

/* Record the selected continuum option while running the unchanged original
 * setup. A null pointer represents the original absent OPTIONAL argument. */
#ifndef SRTM28_OMIT_INIT_RELAY
void srtm_init_(const int32_t *option){
 typedef void (*setup)(const int32_t *);
 void *address=dlsym(RTLD_NEXT,"srtm_init_");setup original_setup;
 if(!address)fail("original SRTM_INIT");memcpy(&original_setup,&address,sizeof original_setup);
 Dl_info body={0},caller={0};
 if(!dladdr(address,&body)||!dladdr(__builtin_return_address(0),&caller)||body.dli_fbase!=caller.dli_fbase||!caller.dli_sname||strcmp(caller.dli_sname,"suecrad_"))fail("source-only continuum setup caller");
 int32_t selected=option?*option:0;uint64_t entry_fpcr;
 __asm__ volatile("mrs %0,fpcr":"=r"(entry_fpcr));if(entry_fpcr)fail("setup FPCR");
 original_setup(option);
 if(option&&*option!=selected)fail("readonly optional setup flag");
 uint64_t after_fpcr;__asm__ volatile("mrs %0,fpcr":"=r"(after_fpcr));if(after_fpcr)fail("setup preserves FPCR");
 FILE *out=fopen("srtm28-continuum-option.json","wx");if(!out)fail("one immutable continuum setup record");
 fprintf(out,"{\"source_only_original_setup\":true,\"optional_argument_present\":%s,\"selected_value\":%d,\"band28_modification_active\":%s,\"FPCR\":0}\n",option?"true":"false",selected,"false");
 if(fclose(out))fail("continuum option record close");
}

#endif

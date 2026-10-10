/* Independently check complete band-16 water and methane absorption.
 * Molecular columns count approximately 10^20 molecules/cm^2.
 * Coefficients have the inverse column unit, optical depths have no unit,
 * and solar flux uses W/m^2. Retain every incoming output byte. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PARAMETERS void *a0, void *a1, void *a2, void *a3, void *a4, void *a5, void *a6, void *a7, void *a8, void *a9, void *a10, void *a11, void *a12, void *a13, void *a14, void *a15, void *a16, void *a17, void *a18, void *a19, void *a20, void *a21, void *a22, void *a23, void *a24, void *a25
#define ARGUMENTS a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25
typedef void (*kernel)(PARAMETERS);
void srtm_taumol16_assembly_(PARAMETERS) __attribute__((weak));
static double *absa,*absb,*self,*foreign,*solar,*rayleigh,*ratio_weight;
static int32_t *reference_layer,*species_a,*species_b;
static uint64_t independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,negative_factors,solar_crossings,mixture_checks,clamped_mixtures,mixture_bins[8];
static double min_factor=DBL_MAX,max_factor=-DBL_MAX,max_absorption,min_mixture=DBL_MAX,max_mixture=-DBL_MAX,min_cap=DBL_MAX,max_cap=-DBL_MAX;
static void fail(const char *s){fprintf(stderr,"SRTM16 failed %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static const char *global_names[10]={"yoesrta16.eq.1_","yoesrta16.eq.0_","__yoesrta16_MOD_selfrefc","__yoesrta16_MOD_forrefc","__yoesrta16_MOD_sfluxrefc","__yoesrta16_MOD_rayl","__yoesrta16_MOD_layreffr","__yoesrta16_MOD_strrat1","__yoesrtwn_MOD_nspa","__yoesrtwn_MOD_nspb"};
static const size_t global_sizes[10]={74880,30080,1280,384,128,8,4,8,56,56};
static void *globals[10];
static void bind_globals(void){
 for(int k=0;k<10;++k){globals[k]=dlsym(RTLD_NEXT,global_names[k]);if(!globals[k])fail("complete declared coefficients and globals");}
 absa=globals[0];absb=globals[1];self=globals[2];foreign=globals[3];solar=globals[4];rayleigh=globals[5];reference_layer=globals[6];ratio_weight=globals[7];species_a=globals[8];species_b=globals[9];
}
static void capacities(const int32_t *d,void *const *a,size_t *sizes){
 int n=d[1]-d[0]+1,H=d[2],V=d[3];
 if(d[0]<1||n<0||n>4096||H<0||V<H||V>512)fail("complete shape bounds");
 sizes[0]=32;for(int z=1;z<4;++z)sizes[z]=4;
 for(int z=4;z<22;++z)sizes[z]=(size_t)n*V*((z>=8&&z<=10)||z==18||z==21?4:8);
 sizes[11]=(size_t)n*8;sizes[15]=(size_t)n*4;sizes[22]=(size_t)n*16*8;sizes[23]=sizes[24]=(size_t)n*V*16*8;sizes[25]=(size_t)n*8;
 for(int z=0;z<26;++z)if(sizes[z]&&(!a[z]||(uintptr_t)a[z]%((z<4||z>=8&&z<=10||z==15||z==18||z==21)?4:8)||(uintptr_t)a[z]>UINTPTR_MAX-sizes[z]))fail("complete capacity and alignment");
 if(species_a[0]!=9||species_b[0]!=1||*reference_layer<13||*reference_layer>59||!isfinite(*ratio_weight)||*ratio_weight<=0||*ratio_weight>0x1p16)fail("original table strides and finite positive mixture ratio");
 const double *mu=a[25],*cap=a[11];const int32_t *trop=a[15],*jp=a[8],*jt=a[9],*jt1=a[10],*is=a[18],*iff=a[21];
 for(int j=0;j<n;++j){
  if(!isfinite(mu[j])||mu[j]<-1||mu[j]>1)fail("finite solar zenith cosine");
  if(mu[j]<=0)continue;
  if(!isfinite(cap[j])||cap[j]<=0||cap[j]>=1)fail("strictly positive mixture cap below one");
  if(trop[j]<0||trop[j]>H||(H&&trop[j]==0))fail("positive lower layers protect prior pressure reads");
  for(int k=0;k<H;++k){
   size_t i=j+(size_t)n*k;
   if(jt[i]<1||jt[i]>4||jt1[i]<1||jt1[i]>4)fail("temperature corners before original execution");
   if(k<trop[j]){
    if(jp[i]<1||jp[i]>12||is[i]<1||is[i]>9||iff[i]<1||iff[i]>2)fail("lower pressure and adjacent continuum rows before source");
    double combined=((const double*)a[12])[i]+*ratio_weight*((const double*)a[13])[i];
    if(!isfinite(combined)||combined<=0)fail("positive finite lower mixture denominator before source");
    double fraction=((const double*)a[12])[i]/combined;if(fraction>=cap[j])fraction=cap[j];double multiple=8*fraction;
    if(!isfinite(multiple)||multiple<0||multiple>=8||(int)multiple<0||(int)multiple>7)fail("bounded original INT and MOD mixture indices before source");
   }else if(k<1||jp[i]<13||jp[i]>58)fail("upper pressure and prior-row capacity before source");
   for(int z=4;z<8;++z){double v=((const double*)a[z])[i];if(!isfinite(v)||fabs(v)>0x1p20)fail("finite bounded pressure-temperature factors");}
   for(int z=12;z<=14;++z){double v=((const double*)a[z])[i];if(!isfinite(v)||v<0||v>0x1p300)fail("finite nonnegative bounded molecular columns");}
   if(k<trop[j])for(int z=16;z<=20;++z)if(z!=18){double v=((const double*)a[z])[i];if(!isfinite(v)||fabs(v)>0x1p20||((z==16||z==19)&&v<0))fail("finite continuum densities and fractions");}
  }
 }
 for(int g=0;g<6;++g){
  if(!isfinite(solar[g])||solar[g]<0)fail("finite nonnegative solar spectrum");
  for(int r=0;r<585;++r)if(!isfinite(absa[r+585*g])||absa[r+585*g]<0||absa[r+585*g]>0x1p100)fail("complete lower mixture-table bounds");
  for(int r=0;r<235;++r)if(!isfinite(absb[r+235*g])||absb[r+235*g]<0||absb[r+235*g]>0x1p100)fail("complete upper table bounds");
  for(int r=0;r<10;++r)if(!isfinite(self[r+10*g])||self[r+10*g]<0||self[r+10*g]>0x1p100)fail("complete active self-table bounds");
  for(int r=0;r<3;++r)if(!isfinite(foreign[r+3*g])||foreign[r+3*g]<0||foreign[r+3*g]>0x1p100)fail("complete active foreign-table bounds");
 }
 if(!isfinite(*rayleigh)||*rayleigh<0||*rayleigh>0x1p100)fail("finite bounded Rayleigh coefficient");
}
static void solar_scope(const int32_t *d,void *const *a,int required){
 int n=d[1]-d[0]+1,H=d[2],ref=*reference_layer,sol=H;
 const double *mu=a[25];const int32_t *jp=a[8],*trop=a[15];unsigned char *written=calloc(n?n:1,1);if(!written)fail("solar scope flags");
 for(int k=0;k<H;++k)for(int j=0;j<n;++j)if(mu[j]>0&&k>=trop[j]){
  size_t i=j+(size_t)n*k;if(jp[i-n]<ref&&jp[i]>=ref)sol=k+1;if(k+1==sol)written[j]=1;
 }
 if(required&&H)for(int j=0;j<n;++j)if(mu[j]>0&&!written[j])fail("all consumed daylight solar entries defined");
 free(written);
}
static void physical(const int32_t *d,void *const *a,const unsigned char *const *before,const double *const *out,int require_solar){
 int n=d[1]-d[0]+1,H=d[2],V=d[3],ref=*reference_layer,sol=H;
 const double *f00=a[4],*f01=a[5],*f10=a[6],*f11=a[7],*cap=a[11],*water=a[12],*methane=a[13],*molecules=a[14],*sf=a[16],*sx=a[17],*ff=a[19],*fx=a[20],*mu=a[25];
 const int32_t *jp=a[8],*jt=a[9],*jt1=a[10],*trop=a[15],*is=a[18],*iff=a[21];
 unsigned char *written=calloc(n?n:1,1);if(!written)fail("solar definition flags");
 /* The shared upper solar selection follows increasing layers and columns. */
 for(int k=0;k<H;++k)for(int j=0;j<n;++j)if(mu[j]>0&&k>=trop[j]){
  size_t i=j+(size_t)n*k;++previous_reads;
  if(jp[i-n]<ref&&jp[i]>=ref){sol=k+1;++solar_crossings;}if(k+1==sol)written[j]=1;
 }
 for(int j=0;j<n;++j){
  int day=mu[j]>0;if(day)++day_columns;else ++night_columns;
  if(day&&require_solar&&H&&!written[j])fail("consumed daylight solar storage defined");
  if(day){min_cap=fmin(min_cap,cap[j]);max_cap=fmax(max_cap,cap[j]);}
  for(int g=0;g<16;++g){
   size_t sun=j+(size_t)n*g;
   if(day&&g<6&&written[j]){if(bits(out[0][sun])!=bits(solar[g]))fail("complete fixed solar spectrum");++solar_copies;++independent;}
   else{if(memcmp((const unsigned char*)out[0]+sun*8,before[0]+sun*8,8))fail("complete preserved solar storage");preserved_bytes+=8;++independent;}
   for(int k=0;k<V;++k){
    size_t i=j+(size_t)n*k,ix=j+(size_t)n*(k+V*g);
    if(day&&g<6&&k<H){
     long double scattering=(long double)molecules[i]**rayleigh;
     if(!isfinite(out[2][ix])||out[2][ix]<0||fabsl((long double)out[2][ix]-scattering)>16*DBL_EPSILON*fabsl(scattering)+4*DBL_TRUE_MIN)fail("independent dimensionless molecular scattering");
     int lower=k<trop[j];double f[4]={f00[i],f10[i],f01[i],f11[i]};long double sum=0;
     for(int z=0;z<4;++z){sum+=f[z];if(f[z]<0)++negative_factors;min_factor=fmin(min_factor,f[z]);max_factor=fmax(max_factor,f[z]);}
     if(fabsl(sum-1)>64*DBL_EPSILON)fail("pressure-temperature factors sum to one");
     long double absorption,condition,tiny=256*(long double)DBL_TRUE_MIN*(1+water[i]+methane[i])*(1+(lower?sf[i]+ff[i]:0));
     if(lower){
      long double combined=(long double)water[i]+(long double)*ratio_weight*methane[i];
      long double mixture=(long double)water[i]/combined;if(mixture>=cap[j]){mixture=cap[j];++clamped_mixtures;}
      long double grid=8*mixture;int bin=(int)grid;long double fraction=grid-bin;
      if(bin<0||bin>7||fraction<0||fraction>=1)fail("independent bounded mixture-table fraction");
      min_mixture=fmin(min_mixture,(double)mixture);max_mixture=fmax(max_mixture,(double)mixture);++mixture_bins[bin];++mixture_checks;
      int i0=((jp[i]-1)*5+jt[i]-1)*9+bin,i1=(jp[i]*5+jt1[i]-1)*9+bin;
      int rows[4]={i0,i0+9,i1,i1+9};long double value=0,absolute=0;
      /* Expand the three-dimensional interpolation into eight barycentric
       * weights, rather than repeating the source's two rounded brackets. */
      for(int z=0;z<4;++z){
       long double lo=absa[rows[z]+585*g],hi=absa[rows[z]+1+585*g];
       value+=(long double)f[z]*((1-fraction)*lo+fraction*hi);
       absolute+=fabsl((long double)f[z])*((1-fraction)*lo+fraction*hi);
      }
      double s0=self[is[i]-1+10*g],s1=self[is[i]+10*g],b0=foreign[iff[i]-1+3*g],b1=foreign[iff[i]+3*g];
      long double st=(long double)sf[i]*((1-(long double)sx[i])*s0+(long double)sx[i]*s1),ft=(long double)ff[i]*((1-(long double)fx[i])*b0+(long double)fx[i]*b1);
      absorption=combined*value+(long double)water[i]*(st+ft);
      condition=combined*absolute+(long double)water[i]*((long double)sf[i]*(fabsl(1-(long double)sx[i])*s0+fabsl((long double)sx[i])*s1)+(long double)ff[i]*(fabsl(1-(long double)fx[i])*b0+fabsl((long double)fx[i])*b1));
      ++lower_layers;independent+=8;
     }else{
      int i0=(jp[i]-13)*5+jt[i]-1,i1=(jp[i]-12)*5+jt1[i]-1,rows[4]={i0,i0+1,i1,i1+1};long double value=0,absolute=0;
      for(int z=0;z<4;++z){value+=(long double)f[z]*absb[rows[z]+235*g];absolute+=fabsl((long double)f[z]*absb[rows[z]+235*g]);}
      absorption=(long double)methane[i]*value;condition=(long double)methane[i]*absolute;++upper_layers;independent+=4;
      if(methane[i]==0&&out[1][ix]!=0)fail("zero upper methane-column limit");
     }
     if(!isfinite(out[1][ix])||out[1][ix]<0||fabsl((long double)out[1][ix]-absorption)>512*DBL_EPSILON*condition+tiny)fail("independent mixed absorber and water continuum depth");
     if(molecules[i]==0&&out[2][ix]!=0)fail("zero scattering-column limit");
     if(molecules[i]==0x1p20&&*rayleigh==0x1p-20){if(bits(out[2][ix])!=UINT64_C(0x3ff0000000000000))fail("known unit molecular scattering");++independent;}
     max_absorption=fmax(max_absorption,out[1][ix]);++independent;
    }else{
     for(int z=1;z<3;++z)if(memcmp((const unsigned char*)out[z]+ix*8,before[z]+ix*8,8))fail("complete preserved night unused-channel extra-layer storage");
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
static uintptr_t return_offset;
static FILE *inputs,*source,*native;
static uint64_t calls,bytes,input_bytes,phases[25];
static void provenance(void){
 const char *names[21]={"__yoesrta16_MOD_ka_d","__yoesrta16_MOD_kb_d","__yoesrta16_MOD_ka","__yoesrta16_MOD_kb","yoesrta16.eq.1_","yoesrta16.eq.0_","__yoesrta16_MOD_selfref","__yoesrta16_MOD_forref","__yoesrta16_MOD_sfluxref","__yoesrta16_MOD_selfrefc","__yoesrta16_MOD_forrefc","__yoesrta16_MOD_sfluxrefc","__yoesrta16_MOD_rayl","__yoesrta16_MOD_layreffr","__yoesrta16_MOD_strrat1","__yoesrtwn_MOD_rwgt","__yoesrtm_MOD_ngn","__yoesrtwn_MOD_ngc","__yoesrtwn_MOD_ngs","__yoesrtwn_MOD_nspa","__yoesrtwn_MOD_nspb"};
 const size_t sizes[21]={74880,30080,74880,30080,74880,30080,1280,384,128,1280,384,128,8,4,8,1792,896,56,56,56,56};
 FILE *f=fopen("srtm16-coefficient-provenance.bin","wb");if(!f)fail("provenance open");
 for(int z=0;z<21;++z){void *p=dlsym(RTLD_NEXT,names[z]);if(!p)fail("raw coefficient provenance");writeall(f,p,sizes[z]);}
 if(fclose(f))fail("provenance close");
}
__attribute__((destructor)) static void finish(void){
 if(!source)return;
 if(fclose(inputs)||fclose(source)||(native&&fclose(native)))fail("capture close");if(!calls)fail("no original calls");
 FILE *f=fopen("srtm16-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"complete_return_bytes\":%" PRIu64 ",\"complete_input_bytes\":%" PRIu64 ",\"independent_relations\":%" PRIu64 ",\"day_columns\":%" PRIu64 ",\"night_columns\":%" PRIu64 ",\"lower_spectral_layers\":%" PRIu64 ",\"upper_spectral_layers\":%" PRIu64 ",\"solar_copies\":%" PRIu64 ",\"preserved_storage_bytes\":%" PRIu64 ",\"active_prior_pressure_reads\":%" PRIu64 ",\"solar_crossings\":%" PRIu64 ",\"negative_interpolation_factors\":%" PRIu64 ",\"factor_range\":[%.17g,%.17g],\"max_absorption\":%.17g,\"native_compared\":%s,\"differing_bytes\":0,\"FPCR_zero_every_entry\":true,\"source_return_offset\":\"0x%lx\",\"active_points\":6,\"complete_points\":16,\"step_calls\":[",calls,bytes,input_bytes,independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,solar_crossings,negative_factors,min_factor,max_factor,max_absorption,native?"true":"false",(unsigned long)return_offset);
 for(int z=0;z<25;++z)fprintf(f,"%s%" PRIu64,z?",":"",phases[z]);fputs("]}\n",f);if(fclose(f))fail("metadata close");
 fprintf(stderr,"SRTM16 %s PASS calls=%" PRIu64 " full_return_bytes=%" PRIu64 " full_input_bytes=%" PRIu64 " independent=%" PRIu64 " differing_bytes=0 FPCR=0\n",native?"NATIVE":"SOURCE",calls,bytes,input_bytes,independent);
}
void srtm_taumol16_(PARAMETERS){
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("every-entry FPCR");
 if(!reference){
  void *s=dlsym(RTLD_NEXT,"srtm_taumol16_");if(!s)fail("original body");memcpy(&reference,&s,sizeof reference);
  Dl_info original={0};if(!dladdr(s,&original)||!original.dli_fbase)fail("original image");image=original.dli_fbase;
  step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");if(!step)fail("forecast phase");bind_globals();
  inputs=fopen("srtm16-inputs.bin","wb");source=fopen("srtm16-fortran.bin","wb");if(srtm_taumol16_assembly_)native=fopen("srtm16-assembly.bin","wb");
  if(!inputs||!source||(srtm_taumol16_assembly_&&!native))fail("capture open");
  if(setvbuf(inputs,NULL,_IOFBF,1<<20)||setvbuf(source,NULL,_IOFBF,1<<20)||(native&&setvbuf(native,NULL,_IOFBF,1<<20)))fail("capture buffers");provenance();
 }
 Dl_info caller={0};void *ret=__builtin_return_address(0);if(!dladdr(ret,&caller)||caller.dli_fbase!=image||!caller.dli_sname||strcmp(caller.dli_sname,"srtm_gas_optical_depth_")||*step<0||*step>24)fail("original scoped caller/phase");
 if(!return_offset)return_offset=(uintptr_t)ret-(uintptr_t)image;if(return_offset!=(uintptr_t)ret-(uintptr_t)image)fail("one frozen original caller site");
 void *all[26]={ARGUMENTS};int32_t d[4];memcpy(d,a1,4);memcpy(d+1,a2,4);memcpy(d+2,a3,4);memcpy(d+3,a0,4);size_t sizes[26];capacities(d,all,sizes);solar_scope(d,all,1);
 for(int z=22;z<25;++z){
  for(int k=0;k<26;++k)if(k!=z&&sizes[k]){uintptr_t x=(uintptr_t)all[z],y=(uintptr_t)all[k];if(x<y+sizes[k]&&y<x+sizes[z])fail("disjoint complete outputs");}
  for(int k=0;k<10;++k){uintptr_t x=(uintptr_t)all[z],y=(uintptr_t)globals[k];if(x<y+global_sizes[k]&&y<x+sizes[z])fail("outputs disjoint from globals");}
 }
 unsigned char constants[106884];size_t co=0;for(int z=0;z<10;++z){memcpy(constants+co,globals[z],global_sizes[z]);co+=global_sizes[z];}if(co!=sizeof constants)fail("complete global record");
 unsigned char *snap[26]={0};for(int z=0;z<26;++z)if(z<22||z==25){snap[z]=malloc(sizes[z]?sizes[z]:1);if(!snap[z])fail("readonly snapshots");memcpy(snap[z],all[z],sizes[z]);}
 unsigned char *before[3],*shadow[3];for(int z=0;z<3;++z){size_t sz=sizes[z+22];before[z]=malloc(sz?sz:1);shadow[z]=malloc(sz?sz:1);if(!before[z]||!shadow[z])fail("complete incoming storage");memcpy(before[z],all[z+22],sz);memcpy(shadow[z],before[z],sz);}
 int32_t hs[2]={*step,1};FILE *streams[3]={inputs,source,native};for(int z=0;z<3;++z)if(streams[z]){writeall(streams[z],&calls,8);writeall(streams[z],hs,8);writeall(streams[z],d,16);}
 writeall(inputs,a0,32);writeall(inputs,constants,sizeof constants);for(int z=4;z<22;++z)writeall(inputs,all[z],sizes[z]);writeall(inputs,a25,sizes[25]);for(int z=0;z<3;++z)writeall(inputs,before[z],sizes[z+22]);
 if(native){reference(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,shadow[0],shadow[1],shadow[2],a25);srtm_taumol16_assembly_(ARGUMENTS);}else{reference(ARGUMENTS);for(int z=0;z<3;++z)memcpy(shadow[z],all[z+22],sizes[z+22]);}
 __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved FPCR");
 for(int z=0;z<26;++z)if(snap[z]){if(memcmp(snap[z],all[z],sizes[z]))fail("complete readonly arguments unchanged");free(snap[z]);}
 co=0;for(int z=0;z<10;++z){if(memcmp(constants+co,globals[z],global_sizes[z]))fail("complete numerical globals unchanged");co+=global_sizes[z];}
 const double *out[3]={(double *)shadow[0],(double *)shadow[1],(double *)shadow[2]};physical(d,all,(const unsigned char *const *)before,out,1);
 size_t returned=32,received=32+32+sizeof constants;for(int z=4;z<22;++z)received+=sizes[z];received+=sizes[25];
 for(int z=0;z<3;++z){
  if(native&&memcmp(shadow[z],all[z+22],sizes[z+22])){size_t first=0;const unsigned char *p=all[z+22];while(shadow[z][first]==p[first])++first;fprintf(stderr,"SRTM16 mismatch call=%" PRIu64 " phase=%d field=%d byte=%zu source=%02x native=%02x\n",calls,*step,z,first,shadow[z][first],p[first]);fail("complete native bytes");}
  writeall(source,shadow[z],sizes[z+22]);if(native)writeall(native,all[z+22],sizes[z+22]);returned+=sizes[z+22];received+=sizes[z+22];free(before[z]);free(shadow[z]);
 }
 ++calls;++phases[*step];bytes+=returned;input_bytes+=received;
}

/* Record the selected continuum option while running the unchanged original
 * setup. A null pointer represents the original absent OPTIONAL argument. */
#ifndef SRTM16_OMIT_INIT_RELAY
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
 FILE *out=fopen("srtm16-continuum-option.json","wx");if(!out)fail("one immutable continuum setup record");
 fprintf(out,"{\"source_only_original_setup\":true,\"optional_argument_present\":%s,\"selected_value\":%d,\"CAVIAR_modification_active\":%s,\"FPCR\":0}\n",option?"true":"false",selected,option&&selected==1?"true":"false");
 if(fclose(out))fail("continuum option record close");
}

#endif

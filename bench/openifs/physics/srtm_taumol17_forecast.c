/* Check complete shortwave band-17 water and carbon dioxide absorption.
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
#define PARAMETERS void *a0, void *a1, void *a2, void *a3, void *a4, void *a5, void *a6, void *a7, void *a8, void *a9, void *a10, void *a11, void *a12, void *a13, void *a14, void *a15, void *a16, void *a17, void *a18, void *a19, void *a20, void *a21, void *a22, void *a23, void *a24, void *a25
#define ARGUMENTS a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25
typedef void (*kernel)(PARAMETERS);
void srtm_taumol17_assembly_(PARAMETERS) __attribute__((weak));
static double *absa,*absb,*self,*foreign,*solar,*rayleigh,*ratio_weight;
static int32_t *reference_layer,*species_a,*species_b;
static uint64_t independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,negative_factors,solar_crossings,mixture_checks[2],clamped_mixtures[2],mixture_bins[2][8];
static double min_factor=DBL_MAX,max_factor=-DBL_MAX,max_absorption,min_mixture[2]={DBL_MAX,DBL_MAX},max_mixture[2]={-DBL_MAX,-DBL_MAX};
static void fail(const char *s){fprintf(stderr,"SRTM17 failed %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static const char *global_names[10]={"yoesrta17.eq.1_","yoesrta17.eq.0_","__yoesrta17_MOD_selfrefc","__yoesrta17_MOD_forrefc","__yoesrta17_MOD_sfluxrefc","__yoesrta17_MOD_rayl","__yoesrta17_MOD_layreffr","__yoesrta17_MOD_strrat","__yoesrtwn_MOD_nspa","__yoesrtwn_MOD_nspb"};
static const size_t global_sizes[10]={74880,150400,1280,512,640,8,4,8,56,56};
static void *globals[10];
static void bind_globals(void){
 for(int k=0;k<10;++k){globals[k]=dlsym(RTLD_NEXT,global_names[k]);if(!globals[k])fail("complete declared coefficients and globals");}
 absa=globals[0];absb=globals[1];self=globals[2];foreign=globals[3];solar=globals[4];rayleigh=globals[5];reference_layer=globals[6];ratio_weight=globals[7];species_a=globals[8];species_b=globals[9];
}
static void sizes_for_shape(int n,int V,size_t *sizes){
 sizes[0]=32;for(int z=1;z<4;++z)sizes[z]=4;
 for(int z=4;z<22;++z)sizes[z]=(size_t)n*V*((z>=8&&z<=10)||z==18||z==21?4:8);
 sizes[11]=(size_t)n*8;sizes[15]=(size_t)n*4;sizes[22]=(size_t)n*16*8;sizes[23]=sizes[24]=(size_t)n*V*16*8;sizes[25]=(size_t)n*8;
}
static void capacities(const int32_t *d,void *const *a,size_t *sizes){
 int64_t count=(int64_t)d[1]-(int64_t)d[0]+1;int H=d[2],V=d[3];
 if(d[0]<1||d[1]>INT32_MAX-1||count<0||count>4096||H<0||V<H||V>512)fail("complete shape bounds before source execution");
 int n=(int)count;sizes_for_shape(n,V,sizes);
 for(int z=0;z<26;++z)if(sizes[z]&&(!a[z]||(uintptr_t)a[z]%((z<4||z>=8&&z<=10||z==15||z==18||z==21)?4:8)||(uintptr_t)a[z]>UINTPTR_MAX-sizes[z]))fail("complete capacity and alignment");
 if(species_a[1]!=9||species_b[1]!=5||*reference_layer<13||*reference_layer>59||!isfinite(*ratio_weight)||*ratio_weight<=0||*ratio_weight>0x1p16)fail("original lower-nine upper-five strides and mixture weight");
 const double *mu=a[25],*cap=a[11],*water=a[12],*co2=a[13];
 const int32_t *trop=a[15],*jp=a[8],*jt=a[9],*jt1=a[10],*is=a[18],*iff=a[21];
 for(int j=0;j<n;++j){
  if(!isfinite(mu[j])||mu[j]<-1||mu[j]>1)fail("finite solar zenith cosine");
  if(mu[j]<=0)continue;
  if(!isfinite(cap[j])||cap[j]<=0||cap[j]>=1)fail("positive mixture cap below one");
  if(trop[j]<0||trop[j]>H||(H&&trop[j]==0))fail("positive tropopause protects original previous-layer reads");
  for(int k=0;k<H;++k){
   size_t i=j+(size_t)n*k;int lower=k<trop[j];
   if(jt[i]<1||jt[i]>4||jt1[i]<1||jt1[i]>4)fail("temperature corners before original execution");
   if(lower){if(jp[i]<1||jp[i]>12||is[i]<1||is[i]>9)fail("complete lower pressure and adjacent self rows");}
   else if(k<1||jp[i]<13||jp[i]>58)fail("upper pressure corners and complete previous-pressure row");
   if(iff[i]<1||iff[i]>3)fail("complete four-row foreign continuum and next entry");
   for(int z=4;z<8;++z){double v=((const double*)a[z])[i];if(!isfinite(v)||fabs(v)>0x1p20)fail("finite bounded pressure-temperature factors");}
   for(int z=12;z<=14;++z){double v=((const double*)a[z])[i];if(!isfinite(v)||v<0||v>0x1p300)fail("finite nonnegative molecular columns");}
   for(int z=16;z<=20;++z)if(z!=18&&(lower||z>=19)){double v=((const double*)a[z])[i];if(!isfinite(v)||fabs(v)>0x1p20||((z==16||z==19)&&v<0))fail("finite continuum densities and temperature fractions");}
   double combined=water[i]+*ratio_weight*co2[i];
   if(!isfinite(combined)||combined<DBL_MIN)fail("normal positive finite active mixture denominator");
   double fraction=water[i]/combined;if(fraction>=cap[j])fraction=cap[j];
   double multiple=(lower?8.:4.)*fraction;
   if(!isfinite(multiple)||multiple<0||multiple>=(lower?8.:4.))fail("bounded original INT and MOD mixture argument");
  }
 }
 for(int g=0;g<12;++g){
  for(int b=0;b<5;++b)if(!isfinite(solar[g+16*b])||solar[g+16*b]<0||solar[g+16*b]>0x1p100)fail("finite nonnegative complete solar mixture table");
  for(int z=0;z<585;++z)if(!isfinite(absa[z+585*g])||absa[z+585*g]<0||absa[z+585*g]>0x1p100)fail("complete active lower absorption table");
  for(int z=0;z<1175;++z)if(!isfinite(absb[z+1175*g])||absb[z+1175*g]<0||absb[z+1175*g]>0x1p100)fail("complete active upper absorption table");
  for(int z=0;z<10;++z)if(!isfinite(self[z+10*g])||self[z+10*g]<0||self[z+10*g]>0x1p100)fail("complete active self continuum table");
  for(int z=0;z<4;++z)if(!isfinite(foreign[z+4*g])||foreign[z+4*g]<0||foreign[z+4*g]>0x1p100)fail("complete active foreign continuum table");
 }
 if(!isfinite(*rayleigh)||*rayleigh<0||*rayleigh>0x1p100)fail("finite nonnegative Rayleigh coefficient");
}
/* The upper solar selector is shared by all columns. Track its writes in
 * original layer-major order, including every change by another column. */
static int *solar_layers(const int32_t *d,void *const *a,int required,int count){
 int n=d[1]-d[0]+1,H=d[2],sol=H;
 const double *mu=a[25];const int32_t *jp=a[8],*trop=a[15],*is=a[18],*iff=a[21];
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
 const double *f00=a[4],*f01=a[5],*f10=a[6],*f11=a[7],*cap=a[11],*molecules=a[14],*co2=a[13],*water=a[12],*sf=a[16],*sx=a[17],*ff=a[19],*fx=a[20],*mu=a[25];
 const int32_t *jp=a[8],*jt=a[9],*jt1=a[10],*trop=a[15],*is=a[18],*iff=a[21];
 int *last=solar_layers(d,a,require_solar,1);
 for(int j=0;j<n;++j){
  int day=mu[j]>0;if(day)++day_columns;else ++night_columns;
  for(int g=0;g<16;++g){
   size_t sun=j+(size_t)n*g;
   if(day&&g<12&&last[j]>=0){
    size_t i=j+(size_t)n*last[j];long double combined=(long double)water[i]+(long double)*ratio_weight*co2[i],fraction=(long double)water[i]/combined;
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
    if(day&&g<12&&k<H){
     long double scattering=(long double)molecules[i]**rayleigh;
     if(!isfinite(out[2][ix])||out[2][ix]<0||fabsl((long double)out[2][ix]-scattering)>16*DBL_EPSILON*fabsl(scattering)+4*DBL_TRUE_MIN)fail("independent dimensionless molecular scattering");
     int lower=k<trop[j],pass=lower?0:1,stride=lower?9:5,rows=lower?585:1175;
     const double *table=lower?absa:absb;double f[4]={f00[i],f10[i],f01[i],f11[i]};long double sum=0;
     for(int z=0;z<4;++z){sum+=f[z];if(f[z]<0)++negative_factors;min_factor=fmin(min_factor,f[z]);max_factor=fmax(max_factor,f[z]);}
     if(fabsl(sum-1)>64*DBL_EPSILON)fail("pressure-temperature weights sum to one");
     long double combined=(long double)water[i]+(long double)*ratio_weight*co2[i],mixture=(long double)water[i]/combined;
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
     double b0=foreign[iff[i]-1+4*g],b1=foreign[iff[i]+4*g];
     long double foreign_value=(long double)ff[i]*((1-(long double)fx[i])*b0+(long double)fx[i]*b1);
     long double foreign_condition=(long double)ff[i]*(fabsl(1-(long double)fx[i])*b0+fabsl((long double)fx[i])*b1);
     long double self_value=0,self_condition=0;
     if(lower){
      double s0=self[is[i]-1+10*g],s1=self[is[i]+10*g];
      self_value=(long double)sf[i]*((1-(long double)sx[i])*s0+(long double)sx[i]*s1);
      self_condition=(long double)sf[i]*(fabsl(1-(long double)sx[i])*s0+fabsl((long double)sx[i])*s1);
     }
     long double expected=combined*value+(long double)water[i]*(self_value+foreign_value);
     long double condition=combined*absolute+(long double)water[i]*(self_condition+foreign_condition);
     long double tiny=256*(long double)DBL_TRUE_MIN*(1+water[i]+*ratio_weight*co2[i])*(1+ff[i]+(lower?sf[i]:0));
     if(!isfinite(out[1][ix])||out[1][ix]<0||fabsl((long double)out[1][ix]-expected)>512*DBL_EPSILON*condition+tiny)fail("independent complete water-carbon-dioxide mixture and water continua");
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
 const char *names[21]={"__yoesrta17_MOD_ka_d","__yoesrta17_MOD_kb_d","__yoesrta17_MOD_ka","__yoesrta17_MOD_kb","yoesrta17.eq.1_","yoesrta17.eq.0_","__yoesrta17_MOD_selfref","__yoesrta17_MOD_forref","__yoesrta17_MOD_sfluxref","__yoesrta17_MOD_selfrefc","__yoesrta17_MOD_forrefc","__yoesrta17_MOD_sfluxrefc","__yoesrta17_MOD_rayl","__yoesrta17_MOD_layreffr","__yoesrta17_MOD_strrat","__yoesrtwn_MOD_rwgt","__yoesrtm_MOD_ngn","__yoesrtwn_MOD_ngc","__yoesrtwn_MOD_ngs","__yoesrtwn_MOD_nspa","__yoesrtwn_MOD_nspb"};
 const size_t sizes[21]={74880,150400,74880,150400,74880,150400,1280,512,640,1280,512,640,8,4,8,1792,896,56,56,56,56};
 FILE *f=fopen("srtm17-coefficient-provenance.bin","wb");if(!f)fail("provenance open");
 for(int z=0;z<21;++z){void *p=dlsym(RTLD_NEXT,names[z]);if(!p)fail("raw coefficient provenance");writeall(f,p,sizes[z]);}
 if(fclose(f))fail("provenance close");
}
__attribute__((destructor)) static void finish(void){
 if(!source)return;
 if(fclose(inputs)||fclose(source)||(native&&fclose(native)))fail("capture close");if(!calls)fail("no original calls");
 FILE *f=fopen("srtm17-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"complete_return_bytes\":%" PRIu64 ",\"complete_input_bytes\":%" PRIu64 ",\"independent_relations\":%" PRIu64 ",\"day_columns\":%" PRIu64 ",\"night_columns\":%" PRIu64 ",\"lower_spectral_layers\":%" PRIu64 ",\"upper_spectral_layers\":%" PRIu64 ",\"solar_copies\":%" PRIu64 ",\"preserved_storage_bytes\":%" PRIu64 ",\"active_prior_pressure_reads\":%" PRIu64 ",\"solar_crossings\":%" PRIu64 ",\"negative_interpolation_factors\":%" PRIu64 ",\"factor_range\":[%.17g,%.17g],\"max_absorption\":%.17g,\"native_compared\":%s,\"differing_bytes\":0,\"FPCR_zero_every_entry\":true,\"source_return_offset\":\"0x%lx\",\"active_points\":12,\"complete_points\":16,\"step_calls\":[",calls,bytes,input_bytes,independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,solar_crossings,negative_factors,min_factor,max_factor,max_absorption,native?"true":"false",(unsigned long)return_offset);
 for(int z=0;z<25;++z)fprintf(f,"%s%" PRIu64,z?",":"",phases[z]);fputs("]}\n",f);if(fclose(f))fail("metadata close");
 fprintf(stderr,"SRTM17 %s PASS calls=%" PRIu64 " full_return_bytes=%" PRIu64 " full_input_bytes=%" PRIu64 " independent=%" PRIu64 " differing_bytes=0 FPCR=0\n",native?"NATIVE":"SOURCE",calls,bytes,input_bytes,independent);
}
void srtm_taumol17_(PARAMETERS){
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("every-entry FPCR");
 if(!reference){
  void *s=dlsym(RTLD_NEXT,"srtm_taumol17_");if(!s)fail("original body");memcpy(&reference,&s,sizeof reference);
  Dl_info original={0};if(!dladdr(s,&original)||!original.dli_fbase)fail("original image");image=original.dli_fbase;
  step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");if(!step)fail("forecast phase");bind_globals();
  inputs=fopen("srtm17-inputs.bin","wb");source=fopen("srtm17-fortran.bin","wb");if(srtm_taumol17_assembly_)native=fopen("srtm17-assembly.bin","wb");
  if(!inputs||!source||(srtm_taumol17_assembly_&&!native))fail("capture open");
  if(setvbuf(inputs,NULL,_IOFBF,1<<20)||setvbuf(source,NULL,_IOFBF,1<<20)||(native&&setvbuf(native,NULL,_IOFBF,1<<20)))fail("capture buffers");provenance();
 }
 Dl_info caller={0};void *ret=__builtin_return_address(0);if(!dladdr(ret,&caller)||caller.dli_fbase!=image||!caller.dli_sname||strcmp(caller.dli_sname,"srtm_gas_optical_depth_")||*step<0||*step>24)fail("original scoped caller/phase");
 if((uintptr_t)ret-(uintptr_t)image!=UINT64_C(0x873110))fail("frozen original source call offset");if(!return_offset)return_offset=(uintptr_t)ret-(uintptr_t)image;if(return_offset!=(uintptr_t)ret-(uintptr_t)image)fail("one frozen original caller site");
 void *all[26]={ARGUMENTS};int32_t d[4];memcpy(d,a1,4);memcpy(d+1,a2,4);memcpy(d+2,a3,4);memcpy(d+3,a0,4);size_t sizes[26];capacities(d,all,sizes);solar_scope(d,all,1);
 for(int z=22;z<25;++z)if(sizes[z]){
  for(int k=0;k<26;++k)if(k!=z&&sizes[k]){uintptr_t x=(uintptr_t)all[z],y=(uintptr_t)all[k];if(x<y+sizes[k]&&y<x+sizes[z])fail("disjoint complete outputs");}
  for(int k=0;k<10;++k){uintptr_t x=(uintptr_t)all[z],y=(uintptr_t)globals[k];if(x<y+global_sizes[k]&&y<x+sizes[z])fail("outputs disjoint from globals");}
 }
 unsigned char constants[227844];size_t co=0;for(int z=0;z<10;++z){memcpy(constants+co,globals[z],global_sizes[z]);co+=global_sizes[z];}if(co!=sizeof constants)fail("complete global record");
 unsigned char *snap[26]={0};for(int z=0;z<26;++z)if(z<22||z==25){snap[z]=malloc(sizes[z]?sizes[z]:1);if(!snap[z])fail("readonly snapshots");if(sizes[z])memcpy(snap[z],all[z],sizes[z]);}
 unsigned char *before[3],*shadow[3];for(int z=0;z<3;++z){size_t sz=sizes[z+22];before[z]=malloc(sz?sz:1);shadow[z]=malloc(sz?sz:1);if(!before[z]||!shadow[z])fail("complete incoming storage");if(sz){memcpy(before[z],all[z+22],sz);memcpy(shadow[z],before[z],sz);}}
 int32_t hs[2]={*step,1};FILE *streams[3]={inputs,source,native};for(int z=0;z<3;++z)if(streams[z]){writeall(streams[z],&calls,8);writeall(streams[z],hs,8);writeall(streams[z],d,16);}
 writeall(inputs,a0,32);writeall(inputs,constants,sizeof constants);for(int z=4;z<22;++z)writeall(inputs,all[z],sizes[z]);writeall(inputs,a25,sizes[25]);for(int z=0;z<3;++z)writeall(inputs,before[z],sizes[z+22]);
 if(native){reference(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,shadow[0],shadow[1],shadow[2],a25);srtm_taumol17_assembly_(ARGUMENTS);}else{reference(ARGUMENTS);for(int z=0;z<3;++z)if(sizes[z+22])memcpy(shadow[z],all[z+22],sizes[z+22]);}
 __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved FPCR");
 for(int z=0;z<26;++z)if(snap[z]){if(sizes[z]&&memcmp(snap[z],all[z],sizes[z]))fail("complete readonly arguments unchanged");free(snap[z]);}
 co=0;for(int z=0;z<10;++z){if(memcmp(constants+co,globals[z],global_sizes[z]))fail("complete numerical globals unchanged");co+=global_sizes[z];}
 const double *out[3]={(double *)shadow[0],(double *)shadow[1],(double *)shadow[2]};physical(d,all,(const unsigned char *const *)before,out,1);
 if(native){const double *native_out[3]={(double *)all[22],(double *)all[23],(double *)all[24]};physical(d,all,(const unsigned char *const *)before,native_out,1);}
 size_t returned=32,received=32+32+sizeof constants;for(int z=4;z<22;++z)received+=sizes[z];received+=sizes[25];
 for(int z=0;z<3;++z){
  if(native&&sizes[z+22]&&memcmp(shadow[z],all[z+22],sizes[z+22])){size_t first=0;const unsigned char *p=all[z+22];while(shadow[z][first]==p[first])++first;uint64_t xb,yb;size_t cell=first/8;memcpy(&xb,shadow[z]+8*cell,8);memcpy(&yb,p+8*cell,8);const char *field[3]={"solar","absorption","Rayleigh"};fprintf(stderr,"SRTM17 mismatch call=%" PRIu64 " phase=%d field=%s cell=%zu byte=%zu source=%016" PRIx64 " native=%016" PRIx64 "\n",calls,*step,field[z],cell,first,xb,yb);fail("complete native bytes");}
  writeall(source,shadow[z],sizes[z+22]);if(native)writeall(native,all[z+22],sizes[z+22]);returned+=sizes[z+22];received+=sizes[z+22];free(before[z]);free(shadow[z]);
 }
 ++calls;++phases[*step];bytes+=returned;input_bytes+=received;
}

/* Record the selected continuum option while running the unchanged original
 * setup. A null pointer represents the original absent OPTIONAL argument. */
/* The parent build uses the unchanged original INIT relay from band29.
 * Its present option0 and the complete coefficient provenance remain required. */
#ifndef SRTM17_OMIT_INIT_RELAY
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
 FILE *out=fopen("srtm17-continuum-option.json","wx");if(!out)fail("one immutable continuum setup record");
 fprintf(out,"{\"source_only_original_setup\":true,\"optional_argument_present\":%s,\"selected_value\":%d,\"CAVIAR_modification_active\":%s,\"FPCR\":0}\n",option?"true":"false",selected,option&&selected==1?"true":"false");
 if(fclose(out))fail("continuum option record close");
}

#endif

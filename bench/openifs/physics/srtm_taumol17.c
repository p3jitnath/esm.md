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
 for(int k=0;k<10;++k){globals[k]=dlsym(RTLD_DEFAULT,global_names[k]);if(!globals[k])fail("complete declared coefficients and globals");}
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
#include <sys/mman.h>
#include <unistd.h>
void srtm_taumol17_(PARAMETERS);
int srtm17_abi_probe(PARAMETERS) __attribute__((weak));
struct guarded {unsigned char *mapping,*value;size_t pages,page,size;};
static struct guarded guard(size_t size,int end){
 size_t page=(size_t)sysconf(_SC_PAGESIZE),pages=((size?size:1)+page-1)/page;
 unsigned char *p=mmap(NULL,(pages+2)*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(p==MAP_FAILED||mprotect(p+page,pages*page,PROT_READ|PROT_WRITE))fail("protected complete allocation");
 memset(p+page,0xa5,pages*page);struct guarded a={p,p+page+(end?pages*page-size:0),pages,page,size};return a;
}
static void release(struct guarded *b){
 size_t first=b->value-(b->mapping+b->page);
 for(size_t z=0;z<b->pages*b->page;++z)if(z<first||z>=first+b->size)if(b->mapping[b->page+z]!=0xa5)fail("complete-capacity poisoned neighbours");
 if(munmap(b->mapping,(b->pages+2)*b->page))fail("protected capacity release");
}
static void readall(FILE *f,void *p,size_t n){if(n&&fread(p,1,n,f)!=n)fail("complete frozen input read");}
#define PASS(v) v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12],v[13],v[14],v[15],v[16],v[17],v[18],v[19],v[20],v[21],v[22],v[23],v[24],v[25]
int main(int argc,char **argv){
 if(argc!=5)fail("mode input source-output native-output arguments");
 int replay=!strcmp(argv[1],"replay"),guarded=!strcmp(argv[1],"guarded");if(!replay&&!guarded)fail("guarded or replay mode");
 int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(!hook)fail("standalone profiling control");*hook=0;bind_globals();
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("FPCR exactly zero");
 FILE *f=fopen(argv[2],"rb"),*r=fopen(argv[3],"wb"),*a=srtm_taumol17_assembly_?fopen(argv[4],"wb"):NULL;
 if(!f||!r||(srtm_taumol17_assembly_&&!a))fail("complete critical streams open");
 uint64_t records=0,placed=0,total=0,abi=0,positive=0,negative=0,subnormal=0;
 for(;;){
  unsigned char header[32];size_t nr=fread(header,1,32,f);if(!nr)break;if(nr!=32)fail("complete record header");
  int32_t d[4];memcpy(d,header+16,16);int64_t count=(int64_t)d[1]-(int64_t)d[0]+1;int H=d[2],V=d[3];
  if(d[0]<1||d[1]>INT32_MAX-1||count<0||count>4096||H<0||V<H||V>512)fail("frozen shape");int n=(int)count;
  if(replay){uint64_t call;int32_t phase,site;memcpy(&call,header,8);memcpy(&phase,header+8,4);memcpy(&site,header+12,4);if(call!=records||phase<0||phase>24||site!=1)fail("actual caller chronology");}
  size_t sizes[26]={32,4,4,4};
  for(int k=4;k<22;++k)sizes[k]=(size_t)n*V*((k>=8&&k<=10)||k==18||k==21?4:8);
  sizes[11]=(size_t)n*8;sizes[15]=(size_t)n*4;sizes[22]=(size_t)n*16*8;sizes[23]=sizes[24]=(size_t)n*V*16*8;sizes[25]=(size_t)n*8;
  unsigned char *input[26];for(int k=0;k<26;++k){input[k]=malloc(sizes[k]?sizes[k]:1);if(!input[k])fail("complete input allocation");}
  readall(f,input[0],32);if(memcmp(input[0],d+3,4))fail("TDIMV used field matches header");
  for(int k=1;k<4;++k)memcpy(input[k],d+k-1,4);
  unsigned char constants[227844];readall(f,constants,sizeof constants);
  for(int k=4;k<22;++k)readall(f,input[k],sizes[k]);readall(f,input[25],sizes[25]);for(int k=22;k<25;++k)readall(f,input[k],sizes[k]);
  size_t co=0;for(int k=0;k<10;++k){memcpy(globals[k],constants+co,global_sizes[k]);co+=global_sizes[k];}
  capacities(d,(void *const *)input,sizes);solar_scope(d,(void *const *)input,replay);
  for(int placement=0;placement<(replay?1:2);++placement){
   int end=replay?1:placement;struct guarded ref[26],nat[26];void *v[26],*w[26];
   for(int k=0;k<26;++k){
    ref[k]=guard(sizes[k],end);nat[k]=guard(sizes[k],end);v[k]=ref[k].value;w[k]=nat[k].value;memcpy(v[k],input[k],sizes[k]);memcpy(w[k],input[k],sizes[k]);
    if((k<22||k==25)&&(mprotect(ref[k].mapping+ref[k].page,ref[k].pages*ref[k].page,PROT_READ)||mprotect(nat[k].mapping+nat[k].page,nat[k].pages*nat[k].page,PROT_READ)))fail("readonly complete argument pages");
   }
   srtm_taumol17_(PASS(v));
   co=0;for(int k=0;k<10;++k){if(memcmp(globals[k],constants+co,global_sizes[k]))fail("complete source globals unchanged");co+=global_sizes[k];}
   const unsigned char *before[3]={input[22],input[23],input[24]};const double *out[3]={v[22],v[23],v[24]};physical(d,v,before,out,replay);
   if(a){
    if(!srtm17_abi_probe||srtm17_abi_probe(PASS(w)))fail("immediate native saved registers, stack and FPCR");++abi;
    co=0;for(int k=0;k<10;++k){if(memcmp(globals[k],constants+co,global_sizes[k]))fail("complete native globals unchanged");co+=global_sizes[k];}
    const double *native_out[3]={w[22],w[23],w[24]};physical(d,w,before,native_out,replay);
   }
   writeall(r,header,32);if(a)writeall(a,header,32);size_t returned=32;
   for(int k=22;k<25;++k){
    if(a&&memcmp(v[k],w[k],sizes[k])){size_t first=0;unsigned char *x=v[k],*y=w[k];while(x[first]==y[first])++first;uint64_t xb,yb;size_t cell=first/8;memcpy(&xb,x+8*cell,8);memcpy(&yb,y+8*cell,8);int32_t phase;memcpy(&phase,header+8,4);const char *field[3]={"solar","absorption","Rayleigh"};fprintf(stderr,"SRTM17 mismatch record=%" PRIu64 " phase=%d placement=%d field=%s cell=%zu byte=%zu source=%016" PRIx64 " native=%016" PRIx64 "\n",records,phase,end,field[k-22],cell,first,xb,yb);fail("complete returned bytes");}
    writeall(r,v[k],sizes[k]);if(a)writeall(a,w[k],sizes[k]);returned+=sizes[k];
   }
   const double *mu=v[25];for(int j=0;j<n;++j)if(mu[j]>0)for(int g=0;g<12;++g)for(int k=0;k<H;++k)for(int field=23;field<25;++field){
    uint64_t z=bits(((double *)v[field])[j+(size_t)n*(k+V*g)]);if(z==0)++positive;if(z==UINT64_C(0x8000000000000000))++negative;if((z&UINT64_C(0x7ff0000000000000))==0&&(z&UINT64_C(0xfffffffffffff)))++subnormal;
   }
   for(int k=0;k<26;++k){release(&ref[k]);release(&nat[k]);}
   __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved complete-call FPCR");++placed;total+=returned;
  }
  for(int k=0;k<26;++k)free(input[k]);++records;
 }
 if(ferror(f)||fclose(f)||fclose(r)||(a&&fclose(a)))fail("critical streams close");
 printf("SRTM17 %s %s PASS input_records=%" PRIu64 " protected_calls=%" PRIu64 " complete_bytes=%" PRIu64 " independent=%" PRIu64 " ABI=%" PRIu64 " lower_spectral_layers=%" PRIu64 " upper_spectral_layers=%" PRIu64 " solar_copies=%" PRIu64 " preserved_bytes=%" PRIu64 " previous_reads=%" PRIu64 " solar_crossings=%" PRIu64 " negative_factor_visits=%" PRIu64 " positive_zeros=%" PRIu64 " negative_zeros=%" PRIu64 " nonzero_subnormals=%" PRIu64 " differing_bytes=0 FPCR=0\n",a?"NATIVE":"SOURCE",replay?"REPLAY":"GUARDED",records,placed,total,independent,abi,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,solar_crossings,negative_factors,positive,negative,subnormal);return 0;
}


/* Inspect saved registers after all twenty-six pointer arguments. */
#ifdef SRTM17_ABI_OBSERVER
__asm__(".text\n.p2align 2\n.global srtm17_abi_probe\n.type srtm17_abi_probe,%function\nsrtm17_abi_probe:\nsub sp,sp,#304\nstp x19,x20,[sp,#144]\nstp x21,x22,[sp,#160]\nstp x23,x24,[sp,#176]\nstp x25,x26,[sp,#192]\nstp x27,x28,[sp,#208]\nstp x29,x30,[sp,#224]\nstp d8,d9,[sp,#240]\nstp d10,d11,[sp,#256]\nstp d12,d13,[sp,#272]\nstp d14,d15,[sp,#288]\nldp x9,x10,[sp,#304]\nstp x9,x10,[sp,#0]\nldp x9,x10,[sp,#320]\nstp x9,x10,[sp,#16]\nldp x9,x10,[sp,#336]\nstp x9,x10,[sp,#32]\nldp x9,x10,[sp,#352]\nstp x9,x10,[sp,#48]\nldp x9,x10,[sp,#368]\nstp x9,x10,[sp,#64]\nldp x9,x10,[sp,#384]\nstp x9,x10,[sp,#80]\nldp x9,x10,[sp,#400]\nstp x9,x10,[sp,#96]\nldp x9,x10,[sp,#416]\nstp x9,x10,[sp,#112]\nldr x9,[sp,#432]\nstr x9,[sp,#128]\nldr x9,[sp,#440]\nstr x9,[sp,#136]\nmov x19,#4883\nmov x20,#5140\nmov x21,#5397\nmov x22,#5654\nmov x23,#5911\nmov x24,#6168\nmov x25,#6425\nmov x26,#6682\nmov x27,#6939\nmov x28,#7196\nmov x29,sp\nmov x9,#2056\nfmov d8,x9\nmov x9,#2313\nfmov d9,x9\nmov x9,#2570\nfmov d10,x9\nmov x9,#2827\nfmov d11,x9\nmov x9,#3084\nfmov d12,x9\nmov x9,#3341\nfmov d13,x9\nmov x9,#3598\nfmov d14,x9\nmov x9,#3855\nfmov d15,x9\nbl srtm_taumol17_assembly_\nmov x9,sp\ncmp x29,x9\nb.ne .Lsrtm17_abi_trap\nmov x9,#4883\ncmp x19,x9\nb.ne .Lsrtm17_abi_bad\nmov x9,#5140\ncmp x20,x9\nb.ne .Lsrtm17_abi_bad\nmov x9,#5397\ncmp x21,x9\nb.ne .Lsrtm17_abi_bad\nmov x9,#5654\ncmp x22,x9\nb.ne .Lsrtm17_abi_bad\nmov x9,#5911\ncmp x23,x9\nb.ne .Lsrtm17_abi_bad\nmov x9,#6168\ncmp x24,x9\nb.ne .Lsrtm17_abi_bad\nmov x9,#6425\ncmp x25,x9\nb.ne .Lsrtm17_abi_bad\nmov x9,#6682\ncmp x26,x9\nb.ne .Lsrtm17_abi_bad\nmov x9,#6939\ncmp x27,x9\nb.ne .Lsrtm17_abi_bad\nmov x9,#7196\ncmp x28,x9\nb.ne .Lsrtm17_abi_bad\nfmov x9,d8\nmov x10,#2056\ncmp x9,x10\nb.ne .Lsrtm17_abi_bad\nfmov x9,d9\nmov x10,#2313\ncmp x9,x10\nb.ne .Lsrtm17_abi_bad\nfmov x9,d10\nmov x10,#2570\ncmp x9,x10\nb.ne .Lsrtm17_abi_bad\nfmov x9,d11\nmov x10,#2827\ncmp x9,x10\nb.ne .Lsrtm17_abi_bad\nfmov x9,d12\nmov x10,#3084\ncmp x9,x10\nb.ne .Lsrtm17_abi_bad\nfmov x9,d13\nmov x10,#3341\ncmp x9,x10\nb.ne .Lsrtm17_abi_bad\nfmov x9,d14\nmov x10,#3598\ncmp x9,x10\nb.ne .Lsrtm17_abi_bad\nfmov x9,d15\nmov x10,#3855\ncmp x9,x10\nb.ne .Lsrtm17_abi_bad\nmrs x9,fpcr\ncbnz x9,.Lsrtm17_abi_bad\nmov w0,#0\nb .Lsrtm17_abi_restore\n.Lsrtm17_abi_bad:\nmov w0,#1\n.Lsrtm17_abi_restore:\nldp d8,d9,[sp,#240]\nldp d10,d11,[sp,#256]\nldp d12,d13,[sp,#272]\nldp d14,d15,[sp,#288]\nldp x19,x20,[sp,#144]\nldp x21,x22,[sp,#160]\nldp x23,x24,[sp,#176]\nldp x25,x26,[sp,#192]\nldp x27,x28,[sp,#208]\nldp x29,x30,[sp,#224]\nadd sp,sp,#304\nret\n.Lsrtm17_abi_trap:\nbrk #1\n.size srtm17_abi_probe,.-srtm17_abi_probe\n");
#endif

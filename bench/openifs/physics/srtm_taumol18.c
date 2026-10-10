/* Independently check complete band-18 water and methane absorption.
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
void srtm_taumol18_assembly_(PARAMETERS) __attribute__((weak));
static double *absa,*absb,*self,*foreign,*solar,*rayleigh,*ratio_weight;
static int32_t *reference_layer,*species_a,*species_b;
static uint64_t independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,next_reads,negative_factors,solar_crossings,mixture_checks,clamped_mixtures,mixture_bins[8];
static double min_factor=DBL_MAX,max_factor=-DBL_MAX,max_absorption,min_mixture=DBL_MAX,max_mixture=-DBL_MAX,min_cap=DBL_MAX,max_cap=-DBL_MAX;
static void fail(const char *s){fprintf(stderr,"SRTM18 failed %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static const char *global_names[10]={"yoesrta18.eq.1_","yoesrta18.eq.0_","__yoesrta18_MOD_selfrefc","__yoesrta18_MOD_forrefc","__yoesrta18_MOD_sfluxrefc","__yoesrta18_MOD_rayl","__yoesrta18_MOD_layreffr","__yoesrta18_MOD_strrat","__yoesrtwn_MOD_nspa","__yoesrtwn_MOD_nspb"};
static const size_t global_sizes[10]={74880,30080,1280,384,1152,8,4,8,56,56};
static void *globals[10];
static void bind_globals(void){
 for(int k=0;k<10;++k){globals[k]=dlsym(RTLD_DEFAULT,global_names[k]);if(!globals[k])fail("complete declared coefficients and globals");}
 absa=globals[0];absb=globals[1];self=globals[2];foreign=globals[3];solar=globals[4];rayleigh=globals[5];reference_layer=globals[6];ratio_weight=globals[7];species_a=globals[8];species_b=globals[9];
}
static void capacities(const int32_t *d,void *const *a,size_t *sizes){
 int64_t count=(int64_t)d[1]-(int64_t)d[0]+1;int H=d[2],V=d[3];
 if(d[0]<1||d[1]>INT32_MAX-1||count<0||count>4096||H<0||V<H||V>512)fail("complete shape bounds");int n=(int)count;
 sizes[0]=32;for(int z=1;z<4;++z)sizes[z]=4;
 for(int z=4;z<22;++z)sizes[z]=(size_t)n*V*((z>=8&&z<=10)||z==18||z==21?4:8);
 sizes[11]=(size_t)n*8;sizes[15]=(size_t)n*4;sizes[22]=(size_t)n*16*8;sizes[23]=sizes[24]=(size_t)n*V*16*8;sizes[25]=(size_t)n*8;
 for(int z=0;z<26;++z)if(sizes[z]&&(!a[z]||(uintptr_t)a[z]%((z<4||z>=8&&z<=10||z==15||z==18||z==21)?4:8)||(uintptr_t)a[z]>UINTPTR_MAX-sizes[z]))fail("complete capacity and alignment");
 if(species_a[2]!=9||species_b[2]!=1||*reference_layer<1||*reference_layer>13||!isfinite(*ratio_weight)||*ratio_weight<=0||*ratio_weight>0x1p16)fail("original table strides and finite positive mixture ratio");
 const double *mu=a[25],*cap=a[11];const int32_t *trop=a[15],*jp=a[8],*jt=a[9],*jt1=a[10],*is=a[18],*iff=a[21];
 for(int j=0;j<n;++j){
  if(!isfinite(mu[j])||mu[j]<-1||mu[j]>1)fail("finite solar zenith cosine");
  if(mu[j]<=0)continue;
  if(!isfinite(cap[j])||cap[j]<=0||cap[j]>=1)fail("strictly positive mixture cap below one");
  if(trop[j]<0||trop[j]>H||(H&&trop[j]==0))fail("positive lower layers define the source solar state");
  for(int k=0;k<H;++k){
   size_t i=j+(size_t)n*k;
   if(jt[i]<1||jt[i]>4||jt1[i]<1||jt1[i]>4)fail("temperature corners before original execution");
   if(k<trop[j]){
    if(k+1>=V)fail("every complete lower next-pressure read fits before source");
    if(jp[i]<1||jp[i]>12||is[i]<1||is[i]>9||iff[i]<1||iff[i]>2)fail("lower pressure and adjacent continuum rows before source");
    double combined=((const double*)a[12])[i]+*ratio_weight*((const double*)a[13])[i];
    if(!isfinite(combined)||combined<DBL_MIN)fail("normal positive finite lower mixture denominator before source");
    double fraction=((const double*)a[12])[i]/combined;if(fraction>=cap[j])fraction=cap[j];double multiple=8*fraction;
    if(!isfinite(multiple)||multiple<0||multiple>=8||(int)multiple<0||(int)multiple>7)fail("bounded original INT and MOD mixture indices before source");
   }else if(jp[i]<13||jp[i]>58)fail("upper pressure table capacity before source");
   for(int z=4;z<8;++z){double v=((const double*)a[z])[i];if(!isfinite(v)||fabs(v)>0x1p20)fail("finite bounded pressure-temperature factors");}
   for(int z=12;z<=14;++z){double v=((const double*)a[z])[i];if(!isfinite(v)||v<0||v>0x1p300)fail("finite nonnegative bounded molecular columns");}
   if(k<trop[j])for(int z=16;z<=20;++z)if(z!=18){double v=((const double*)a[z])[i];if(!isfinite(v)||fabs(v)>0x1p20||((z==16||z==19)&&v<0))fail("finite continuum densities and fractions");}
  }
 }
 for(int g=0;g<8;++g){
  for(int b=0;b<9;++b)if(!isfinite(solar[g+16*b])||solar[g+16*b]<0||solar[g+16*b]>0x1p100)fail("finite bounded nonnegative complete mixture solar table");
  for(int r=0;r<585;++r)if(!isfinite(absa[r+585*g])||absa[r+585*g]<0||absa[r+585*g]>0x1p100)fail("complete lower mixture-table bounds");
  for(int r=0;r<235;++r)if(!isfinite(absb[r+235*g])||absb[r+235*g]<0||absb[r+235*g]>0x1p100)fail("complete upper table bounds");
  for(int r=0;r<10;++r)if(!isfinite(self[r+10*g])||self[r+10*g]<0||self[r+10*g]>0x1p100)fail("complete active self-table bounds");
  for(int r=0;r<3;++r)if(!isfinite(foreign[r+3*g])||foreign[r+3*g]<0||foreign[r+3*g]>0x1p100)fail("complete active foreign-table bounds");
 }
 if(!isfinite(*rayleigh)||*rayleigh<0||*rayleigh>0x1p100)fail("finite bounded Rayleigh coefficient");
}
static void solar_scope(const int32_t *d,void *const *a,int required){
 int n=d[1]-d[0]+1,H=d[2],ref=*reference_layer;
 const double *mu=a[25];const int32_t *jp=a[8],*trop=a[15];
 for(int j=0;j<n;++j)if(mu[j]>0){
  int sol=trop[j],written=0;
  for(int k=0;k<H&&k<trop[j];++k){
   size_t i=j+(size_t)n*k;
   if(jp[i]<ref&&jp[i+n]>=ref)sol=k+2<trop[j]?k+2:trop[j];
   if(k+1==sol)written=1;
  }
  if(required&&H&&!written)fail("all consumed daylight solar entries defined");
 }
}
static void physical(const int32_t *d,void *const *a,const unsigned char *const *before,const double *const *out,int require_solar){
 int n=d[1]-d[0]+1,H=d[2],V=d[3],ref=*reference_layer;
 const double *f00=a[4],*f01=a[5],*f10=a[6],*f11=a[7],*cap=a[11],*water=a[12],*methane=a[13],*molecules=a[14],*sf=a[16],*sx=a[17],*ff=a[19],*fx=a[20],*mu=a[25];
 const int32_t *jp=a[8],*jt=a[9],*jt1=a[10],*trop=a[15],*is=a[18],*iff=a[21];
 for(int j=0;j<n;++j){
  int day=mu[j]>0,solar_layer=-1,sol=trop[j];if(day)++day_columns;else ++night_columns;
  /* Each column has its own lower-layer solar state. Preserve every possible
   * look-ahead even when the first part of the source condition is false. */
  if(day)for(int k=0;k<H&&k<trop[j];++k){
   size_t i=j+(size_t)n*k;++next_reads;
   if(jp[i]<ref&&jp[i+n]>=ref){sol=k+2<trop[j]?k+2:trop[j];++solar_crossings;}
   if(k+1==sol)solar_layer=k;
  }
  if(day&&require_solar&&H&&solar_layer<0)fail("consumed daylight solar storage defined");
  if(day){min_cap=fmin(min_cap,cap[j]);max_cap=fmax(max_cap,cap[j]);}
  for(int g=0;g<16;++g){
   size_t sun=j+(size_t)n*g;
   if(day&&g<8&&solar_layer>=0){
    size_t i=j+(size_t)n*solar_layer;
    long double combined=(long double)water[i]+(long double)*ratio_weight*methane[i];
    long double mixture=(long double)water[i]/combined;if(mixture>=cap[j])mixture=cap[j];
    long double grid=8*mixture;int bin=(int)grid;long double f=grid-bin;
    long double lo=solar[g+16*bin],hi=solar[g+16*(bin+1)];
    long double expected=(1-f)*lo+f*hi,scale=fabsl(lo)+fabsl(hi);
    for(int b=0;b<9;++b)scale+=fabsl(solar[g+16*b]);
    if(!isfinite(out[0][sun])||out[0][sun]<0||fabsl((long double)out[0][sun]-expected)>512*DBL_EPSILON*scale+256*DBL_TRUE_MIN)fail("independent bounded mixture-dependent solar interpolation");
    ++solar_copies;independent+=3;
   }else{
    if(memcmp((const unsigned char*)out[0]+sun*8,before[0]+sun*8,8))fail("complete preserved solar storage");
    preserved_bytes+=8;++independent;
   }
   for(int k=0;k<V;++k){
    size_t i=j+(size_t)n*k,ix=j+(size_t)n*(k+V*g);
    if(day&&g<8&&k<H){
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
      /* Expand eight independent mathematical weights, rather than repeat
       * the original pair of separately rounded four-product brackets. */
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
      if(methane[i]==0&&out[1][ix]!=0)fail("zero upper CH4-column limit");
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
}
#include <sys/mman.h>
#include <unistd.h>
void srtm_taumol18_(PARAMETERS);
int srtm18_abi_probe(PARAMETERS) __attribute__((weak));
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
 FILE *f=fopen(argv[2],"rb"),*r=fopen(argv[3],"wb"),*a=srtm_taumol18_assembly_?fopen(argv[4],"wb"):NULL;
 if(!f||!r||(srtm_taumol18_assembly_&&!a))fail("complete critical streams open");
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
  unsigned char constants[107908];readall(f,constants,sizeof constants);
  for(int k=4;k<22;++k)readall(f,input[k],sizes[k]);readall(f,input[25],sizes[25]);for(int k=22;k<25;++k)readall(f,input[k],sizes[k]);
  size_t co=0;for(int k=0;k<10;++k){memcpy(globals[k],constants+co,global_sizes[k]);co+=global_sizes[k];}
  capacities(d,(void *const *)input,sizes);solar_scope(d,(void *const *)input,replay);
  for(int placement=0;placement<(replay?1:2);++placement){
   int end=replay?1:placement;struct guarded ref[26],nat[26];void *v[26],*w[26];
   for(int k=0;k<26;++k){
    ref[k]=guard(sizes[k],end);nat[k]=guard(sizes[k],end);v[k]=ref[k].value;w[k]=nat[k].value;memcpy(v[k],input[k],sizes[k]);memcpy(w[k],input[k],sizes[k]);
    if((k<22||k==25)&&(mprotect(ref[k].mapping+ref[k].page,ref[k].pages*ref[k].page,PROT_READ)||mprotect(nat[k].mapping+nat[k].page,nat[k].pages*nat[k].page,PROT_READ)))fail("readonly complete argument pages");
   }
   srtm_taumol18_(PASS(v));
   co=0;for(int k=0;k<10;++k){if(memcmp(globals[k],constants+co,global_sizes[k]))fail("complete source globals unchanged");co+=global_sizes[k];}
   const unsigned char *before[3]={input[22],input[23],input[24]};const double *out[3]={v[22],v[23],v[24]};physical(d,v,before,out,replay);
   if(a){
    if(!srtm18_abi_probe||srtm18_abi_probe(PASS(w)))fail("immediate native saved registers, stack and FPCR");++abi;
    co=0;for(int k=0;k<10;++k){if(memcmp(globals[k],constants+co,global_sizes[k]))fail("complete native globals unchanged");co+=global_sizes[k];}
   }
   writeall(r,header,32);if(a)writeall(a,header,32);size_t returned=32;
   for(int k=22;k<25;++k){
    if(a&&memcmp(v[k],w[k],sizes[k])){size_t first=0;unsigned char *x=v[k],*y=w[k];while(x[first]==y[first])++first;fprintf(stderr,"SRTM18 mismatch record=%" PRIu64 " placement=%d field=%d byte=%zu source=%02x native=%02x\n",records,end,k-19,first,x[first],y[first]);fail("complete returned bytes");}
    writeall(r,v[k],sizes[k]);if(a)writeall(a,w[k],sizes[k]);returned+=sizes[k];
   }
   const double *mu=v[25];for(int j=0;j<n;++j)if(mu[j]>0)for(int g=0;g<8;++g)for(int k=0;k<H;++k)for(int field=23;field<25;++field){
    uint64_t z=bits(((double *)v[field])[j+(size_t)n*(k+V*g)]);if(z==0)++positive;if(z==UINT64_C(0x8000000000000000))++negative;if((z&UINT64_C(0x7ff0000000000000))==0&&(z&UINT64_C(0xfffffffffffff)))++subnormal;
   }
   for(int k=0;k<26;++k){release(&ref[k]);release(&nat[k]);}
   __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved complete-call FPCR");++placed;total+=returned;
  }
  for(int k=0;k<26;++k)free(input[k]);++records;
 }
 if(ferror(f)||fclose(f)||fclose(r)||(a&&fclose(a)))fail("critical streams close");
 printf("SRTM18 %s %s PASS input_records=%" PRIu64 " protected_calls=%" PRIu64 " complete_bytes=%" PRIu64 " independent=%" PRIu64 " ABI=%" PRIu64 " lower_spectral_layers=%" PRIu64 " upper_spectral_layers=%" PRIu64 " solar_copies=%" PRIu64 " preserved_bytes=%" PRIu64 " next_reads=%" PRIu64 " solar_crossings=%" PRIu64 " negative_factor_visits=%" PRIu64 " positive_zeros=%" PRIu64 " negative_zeros=%" PRIu64 " nonzero_subnormals=%" PRIu64 " differing_bytes=0 FPCR=0\n",a?"NATIVE":"SOURCE",replay?"REPLAY":"GUARDED",records,placed,total,independent,abi,lower_layers,upper_layers,solar_copies,preserved_bytes,next_reads,solar_crossings,negative_factors,positive,negative,subnormal);return 0;
}


/* Inspect saved registers after all twenty-six pointer arguments. */
#ifdef SRTM18_ABI_OBSERVER
__asm__(".text\n.p2align 2\n.global srtm18_abi_probe\n.type srtm18_abi_probe,%function\nsrtm18_abi_probe:\nsub sp,sp,#304\nstp x19,x20,[sp,#144]\nstp x21,x22,[sp,#160]\nstp x23,x24,[sp,#176]\nstp x25,x26,[sp,#192]\nstp x27,x28,[sp,#208]\nstp x29,x30,[sp,#224]\nstp d8,d9,[sp,#240]\nstp d10,d11,[sp,#256]\nstp d12,d13,[sp,#272]\nstp d14,d15,[sp,#288]\nldp x9,x10,[sp,#304]\nstp x9,x10,[sp,#0]\nldp x9,x10,[sp,#320]\nstp x9,x10,[sp,#16]\nldp x9,x10,[sp,#336]\nstp x9,x10,[sp,#32]\nldp x9,x10,[sp,#352]\nstp x9,x10,[sp,#48]\nldp x9,x10,[sp,#368]\nstp x9,x10,[sp,#64]\nldp x9,x10,[sp,#384]\nstp x9,x10,[sp,#80]\nldp x9,x10,[sp,#400]\nstp x9,x10,[sp,#96]\nldp x9,x10,[sp,#416]\nstp x9,x10,[sp,#112]\nldr x9,[sp,#432]\nstr x9,[sp,#128]\nldr x9,[sp,#440]\nstr x9,[sp,#136]\nmov x19,#4883\nmov x20,#5140\nmov x21,#5397\nmov x22,#5654\nmov x23,#5911\nmov x24,#6168\nmov x25,#6425\nmov x26,#6682\nmov x27,#6939\nmov x28,#7196\nmov x29,sp\nmov x9,#2056\nfmov d8,x9\nmov x9,#2313\nfmov d9,x9\nmov x9,#2570\nfmov d10,x9\nmov x9,#2827\nfmov d11,x9\nmov x9,#3084\nfmov d12,x9\nmov x9,#3341\nfmov d13,x9\nmov x9,#3598\nfmov d14,x9\nmov x9,#3855\nfmov d15,x9\nbl srtm_taumol18_assembly_\nmov x9,sp\ncmp x29,x9\nb.ne .Lsrtm18_abi_trap\nmov x9,#4883\ncmp x19,x9\nb.ne .Lsrtm18_abi_bad\nmov x9,#5140\ncmp x20,x9\nb.ne .Lsrtm18_abi_bad\nmov x9,#5397\ncmp x21,x9\nb.ne .Lsrtm18_abi_bad\nmov x9,#5654\ncmp x22,x9\nb.ne .Lsrtm18_abi_bad\nmov x9,#5911\ncmp x23,x9\nb.ne .Lsrtm18_abi_bad\nmov x9,#6168\ncmp x24,x9\nb.ne .Lsrtm18_abi_bad\nmov x9,#6425\ncmp x25,x9\nb.ne .Lsrtm18_abi_bad\nmov x9,#6682\ncmp x26,x9\nb.ne .Lsrtm18_abi_bad\nmov x9,#6939\ncmp x27,x9\nb.ne .Lsrtm18_abi_bad\nmov x9,#7196\ncmp x28,x9\nb.ne .Lsrtm18_abi_bad\nfmov x9,d8\nmov x10,#2056\ncmp x9,x10\nb.ne .Lsrtm18_abi_bad\nfmov x9,d9\nmov x10,#2313\ncmp x9,x10\nb.ne .Lsrtm18_abi_bad\nfmov x9,d10\nmov x10,#2570\ncmp x9,x10\nb.ne .Lsrtm18_abi_bad\nfmov x9,d11\nmov x10,#2827\ncmp x9,x10\nb.ne .Lsrtm18_abi_bad\nfmov x9,d12\nmov x10,#3084\ncmp x9,x10\nb.ne .Lsrtm18_abi_bad\nfmov x9,d13\nmov x10,#3341\ncmp x9,x10\nb.ne .Lsrtm18_abi_bad\nfmov x9,d14\nmov x10,#3598\ncmp x9,x10\nb.ne .Lsrtm18_abi_bad\nfmov x9,d15\nmov x10,#3855\ncmp x9,x10\nb.ne .Lsrtm18_abi_bad\nmrs x9,fpcr\ncbnz x9,.Lsrtm18_abi_bad\nmov w0,#0\nb .Lsrtm18_abi_restore\n.Lsrtm18_abi_bad:\nmov w0,#1\n.Lsrtm18_abi_restore:\nldp d8,d9,[sp,#240]\nldp d10,d11,[sp,#256]\nldp d12,d13,[sp,#272]\nldp d14,d15,[sp,#288]\nldp x19,x20,[sp,#144]\nldp x21,x22,[sp,#160]\nldp x23,x24,[sp,#176]\nldp x25,x26,[sp,#192]\nldp x27,x28,[sp,#208]\nldp x29,x30,[sp,#224]\nadd sp,sp,#304\nret\n.Lsrtm18_abi_trap:\nbrk #1\n.size srtm18_abi_probe,.-srtm18_abi_probe\n");
#endif

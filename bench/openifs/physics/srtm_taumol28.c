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
 for(int k=0;k<8;++k){globals[k]=dlsym(RTLD_DEFAULT,global_names[k]);if(!globals[k])fail("complete declared coefficients and globals");}
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

#include <sys/mman.h>
#include <unistd.h>
void srtm_taumol28_(PARAMETERS);
int srtm28_abi_probe(PARAMETERS) __attribute__((weak));
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
#define PASS(v) v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12],v[13],v[14],v[15],v[16],v[17],v[18],v[19]
int main(int argc,char **argv){
 if(argc!=5)fail("mode input source-output native-output arguments");
 int replay=!strcmp(argv[1],"replay"),guarded=!strcmp(argv[1],"guarded");if(!replay&&!guarded)fail("guarded or replay mode");
 int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(!hook)fail("standalone profiling control");*hook=0;bind_globals();
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("FPCR exactly zero");
 FILE *f=fopen(argv[2],"rb"),*r=fopen(argv[3],"wb"),*a=srtm_taumol28_assembly_?fopen(argv[4],"wb"):NULL;
 if(!f||!r||(srtm_taumol28_assembly_&&!a))fail("complete critical streams open");
 uint64_t records=0,placed=0,total=0,abi=0,positive=0,negative=0,subnormal=0;
 for(;;){
  unsigned char header[32];size_t nr=fread(header,1,32,f);if(!nr)break;if(nr!=32)fail("complete record header");
  int32_t d[4];memcpy(d,header+16,16);int64_t count=(int64_t)d[1]-(int64_t)d[0]+1;int H=d[2],V=d[3];
  if(d[0]<1||d[1]>INT32_MAX-1||count<0||count>4096||H<0||V<H||V>512)fail("frozen shape");int n=(int)count;
  if(replay){uint64_t call;int32_t phase,site;memcpy(&call,header,8);memcpy(&phase,header+8,4);memcpy(&site,header+12,4);if(call!=records||phase<0||phase>24||site!=1)fail("actual caller chronology");}
  size_t sizes[20];sizes_for_shape(n,V,sizes);
  unsigned char *input[20];for(int k=0;k<20;++k){input[k]=malloc(sizes[k]?sizes[k]:1);if(!input[k])fail("complete input allocation");}
  readall(f,input[0],32);if(memcmp(input[0],d+3,4))fail("TDIMV used field matches header");
  for(int k=1;k<4;++k)memcpy(input[k],d+k-1,4);
  unsigned char constants[226052];readall(f,constants,sizeof constants);
  for(int k=4;k<16;++k)readall(f,input[k],sizes[k]);readall(f,input[19],sizes[19]);for(int k=16;k<19;++k)readall(f,input[k],sizes[k]);
  size_t co=0;for(int k=0;k<8;++k){memcpy(globals[k],constants+co,global_sizes[k]);co+=global_sizes[k];}
  capacities(d,(void *const *)input,sizes);solar_scope(d,(void *const *)input,1);
  for(int placement=0;placement<(replay?1:2);++placement){
   int end=replay?1:placement;struct guarded ref[20],nat[20];void *v[20],*w[20];
   for(int k=0;k<20;++k){
    ref[k]=guard(sizes[k],end);nat[k]=guard(sizes[k],end);v[k]=ref[k].value;w[k]=nat[k].value;memcpy(v[k],input[k],sizes[k]);memcpy(w[k],input[k],sizes[k]);
    if((k<16||k==19)&&(mprotect(ref[k].mapping+ref[k].page,ref[k].pages*ref[k].page,PROT_READ)||mprotect(nat[k].mapping+nat[k].page,nat[k].pages*nat[k].page,PROT_READ)))fail("readonly complete argument pages");
   }
   srtm_taumol28_(PASS(v));
   co=0;for(int k=0;k<8;++k){if(memcmp(globals[k],constants+co,global_sizes[k]))fail("complete source globals unchanged");co+=global_sizes[k];}
   const unsigned char *before[3]={input[16],input[17],input[18]};const double *out[3]={v[16],v[17],v[18]};physical(d,v,before,out,1);
   if(a){
    if(!srtm28_abi_probe||srtm28_abi_probe(PASS(w)))fail("immediate native saved registers, stack and FPCR");++abi;
    co=0;for(int k=0;k<8;++k){if(memcmp(globals[k],constants+co,global_sizes[k]))fail("complete native globals unchanged");co+=global_sizes[k];}
    const double *native_out[3]={w[16],w[17],w[18]};physical(d,w,before,native_out,1);
   }
   writeall(r,header,32);if(a)writeall(a,header,32);size_t returned=32;
   for(int k=16;k<19;++k){
    if(a&&memcmp(v[k],w[k],sizes[k])){size_t first=0;unsigned char *x=v[k],*y=w[k];while(x[first]==y[first])++first;fprintf(stderr,"SRTM28 mismatch record=%" PRIu64 " placement=%d field=%d byte=%zu source=%02x native=%02x\n",records,end,k-16,first,x[first],y[first]);fail("complete returned bytes");}
    writeall(r,v[k],sizes[k]);if(a)writeall(a,w[k],sizes[k]);returned+=sizes[k];
   }
   const double *mu=v[19];for(int j=0;j<n;++j)if(mu[j]>0)for(int g=0;g<6;++g)for(int k=0;k<H;++k)for(int field=17;field<19;++field){
    uint64_t z=bits(((double *)v[field])[j+(size_t)n*(k+V*g)]);if(z==0)++positive;if(z==UINT64_C(0x8000000000000000))++negative;if((z&UINT64_C(0x7ff0000000000000))==0&&(z&UINT64_C(0xfffffffffffff)))++subnormal;
   }
   for(int k=0;k<20;++k){release(&ref[k]);release(&nat[k]);}
   __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved complete-call FPCR");++placed;total+=returned;
  }
  for(int k=0;k<20;++k)free(input[k]);++records;
 }
 if(ferror(f)||fclose(f)||fclose(r)||(a&&fclose(a)))fail("critical streams close");
 printf("SRTM28 %s %s PASS input_records=%" PRIu64 " protected_calls=%" PRIu64 " complete_bytes=%" PRIu64 " independent=%" PRIu64 " ABI=%" PRIu64 " lower_spectral_layers=%" PRIu64 " upper_spectral_layers=%" PRIu64 " solar_copies=%" PRIu64 " preserved_bytes=%" PRIu64 " previous_reads=%" PRIu64 " solar_crossings=%" PRIu64 " negative_factor_visits=%" PRIu64 " positive_zeros=%" PRIu64 " negative_zeros=%" PRIu64 " nonzero_subnormals=%" PRIu64 " differing_bytes=0 FPCR=0\n",a?"NATIVE":"SOURCE",replay?"REPLAY":"GUARDED",records,placed,total,independent,abi,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,solar_crossings,negative_factors,positive,negative,subnormal);return 0;
}



/* This optional observer checks saved registers, stack and FPCR while
 * forwarding every original pointer. It supplies no numerical work. */
#ifdef SRTM28_ABI_OBSERVER
__asm__("/* Forward all twenty pointer arguments and check the Arm ABI.\n * This observer has no numerical stage and no primary solver body. */\n.text\n.p2align 4\n.global srtm28_abi_probe\n.type srtm28_abi_probe,%function\nsrtm28_abi_probe:\n    sub sp, sp, #256\n    stp x19, x20, [sp, #96]\n    stp x21, x22, [sp, #112]\n    stp x23, x24, [sp, #128]\n    stp x25, x26, [sp, #144]\n    stp x27, x28, [sp, #160]\n    stp x29, x30, [sp, #176]\n    stp d8, d9, [sp, #192]\n    stp d10, d11, [sp, #208]\n    stp d12, d13, [sp, #224]\n    stp d14, d15, [sp, #240]\n    ldp x9, x10, [sp, #256]\n    stp x9, x10, [sp, #0]\n    ldp x9, x10, [sp, #272]\n    stp x9, x10, [sp, #16]\n    ldp x9, x10, [sp, #288]\n    stp x9, x10, [sp, #32]\n    ldp x9, x10, [sp, #304]\n    stp x9, x10, [sp, #48]\n    ldp x9, x10, [sp, #320]\n    stp x9, x10, [sp, #64]\n    ldp x9, x10, [sp, #336]\n    stp x9, x10, [sp, #80]\n    mov x19, sp\n    mov x20, #0x5a3c\n    mov x21, #0x5a3c\n    mov x22, #0x5a3c\n    mov x23, #0x5a3c\n    mov x24, #0x5a3c\n    mov x25, #0x5a3c\n    mov x26, #0x5a3c\n    mov x27, #0x5a3c\n    mov x28, #0x5a3c\n    mov x29, #0x5a3c\n    mov x9, #0x6b4d\n    fmov d8, x9\n    fmov d9, x9\n    fmov d10, x9\n    fmov d11, x9\n    fmov d12, x9\n    fmov d13, x9\n    fmov d14, x9\n    fmov d15, x9\n    bl srtm_taumol28_assembly_\n    mov w0, #1\n    mov x9, sp\n    cmp x19, x9\n    b.ne .Labi_restore\n    mov x10, #0x5a3c\n    cmp x20, x10\n    b.ne .Labi_restore\n    cmp x21, x10\n    b.ne .Labi_restore\n    cmp x22, x10\n    b.ne .Labi_restore\n    cmp x23, x10\n    b.ne .Labi_restore\n    cmp x24, x10\n    b.ne .Labi_restore\n    cmp x25, x10\n    b.ne .Labi_restore\n    cmp x26, x10\n    b.ne .Labi_restore\n    cmp x27, x10\n    b.ne .Labi_restore\n    cmp x28, x10\n    b.ne .Labi_restore\n    cmp x29, x10\n    b.ne .Labi_restore\n    mov x10, #0x6b4d\n    fmov x9, d8\n    cmp x9, x10\n    b.ne .Labi_restore\n    fmov x9, d9\n    cmp x9, x10\n    b.ne .Labi_restore\n    fmov x9, d10\n    cmp x9, x10\n    b.ne .Labi_restore\n    fmov x9, d11\n    cmp x9, x10\n    b.ne .Labi_restore\n    fmov x9, d12\n    cmp x9, x10\n    b.ne .Labi_restore\n    fmov x9, d13\n    cmp x9, x10\n    b.ne .Labi_restore\n    fmov x9, d14\n    cmp x9, x10\n    b.ne .Labi_restore\n    fmov x9, d15\n    cmp x9, x10\n    b.ne .Labi_restore\n    mrs x9, fpcr\n    cbnz x9, .Labi_restore\n    mov w0, #0\n.Labi_restore:\n    ldp d8, d9, [sp, #192]\n    ldp d10, d11, [sp, #208]\n    ldp d12, d13, [sp, #224]\n    ldp d14, d15, [sp, #240]\n    ldp x19, x20, [sp, #96]\n    ldp x21, x22, [sp, #112]\n    ldp x23, x24, [sp, #128]\n    ldp x25, x26, [sp, #144]\n    ldp x27, x28, [sp, #160]\n    ldp x29, x30, [sp, #176]\n    add sp, sp, #256\n    ret\n.size srtm28_abi_probe, .-srtm28_abi_probe\n\n.text\n");
#endif

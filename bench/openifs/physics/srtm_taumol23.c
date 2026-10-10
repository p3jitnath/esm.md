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
 for(int k=0;k<8;++k){globals[k]=dlsym(RTLD_DEFAULT,global_names[k]);if(!globals[k])fail("all declared coefficient/global bindings");}
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
#include <sys/mman.h>
#include <unistd.h>
void srtm_taumol23_(PARAMETERS);
int srtm23_abi_probe(PARAMETERS) __attribute__((weak));
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
#define PASS(v) v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12],v[13],v[14],v[15],v[16],v[17],v[18],v[19],v[20],v[21],v[22],v[23]
int main(int argc,char **argv){
 if(argc!=5)fail("mode input source-output native-output arguments");
 int replay=!strcmp(argv[1],"replay"),guarded=!strcmp(argv[1],"guarded");if(!replay&&!guarded)fail("guarded or replay mode");
 int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(!hook)fail("standalone profiling control");*hook=0;bind_globals();
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("FPCR exactly zero");
 FILE *f=fopen(argv[2],"rb"),*r=fopen(argv[3],"wb"),*a=srtm_taumol23_assembly_?fopen(argv[4],"wb"):NULL;
 if(!f||!r||(srtm_taumol23_assembly_&&!a))fail("complete critical streams open");
 uint64_t records=0,placed=0,total=0,abi=0,positive=0,negative=0,subnormal=0;
 for(;;){
  unsigned char header[32];size_t nr=fread(header,1,32,f);if(!nr)break;if(nr!=32)fail("complete record header");
  int32_t d[4];memcpy(d,header+16,16);int n=d[1]-d[0]+1,H=d[2],V=d[3];
  if(d[0]<1||n<0||n>4096||H<0||V<H||V>512)fail("frozen shape");
  if(replay){uint64_t call;int32_t phase,site;memcpy(&call,header,8);memcpy(&phase,header+8,4);memcpy(&site,header+12,4);if(call!=records||phase<0||phase>24||site!=1)fail("actual caller chronology");}
  size_t sizes[24]={32,4,4,4};
  for(int k=4;k<20;++k)sizes[k]=(size_t)n*V*((k>=8&&k<=10)||k==16||k==19?4:8);
  sizes[13]=(size_t)n*4;sizes[20]=(size_t)n*16*8;sizes[21]=sizes[22]=(size_t)n*V*16*8;sizes[23]=(size_t)n*8;
  unsigned char *input[24];for(int k=0;k<24;++k){input[k]=malloc(sizes[k]?sizes[k]:1);if(!input[k])fail("complete input allocation");}
  readall(f,input[0],32);if(memcmp(input[0],d+3,4))fail("TDIMV used field matches header");
  for(int k=1;k<4;++k)memcpy(input[k],d+k-1,4);
  unsigned char constants[10308];readall(f,constants,sizeof constants);
  for(int k=4;k<20;++k)readall(f,input[k],sizes[k]);readall(f,input[23],sizes[23]);for(int k=20;k<23;++k)readall(f,input[k],sizes[k]);
  size_t co=0;for(int k=0;k<8;++k){memcpy(globals[k],constants+co,global_sizes[k]);co+=global_sizes[k];}
  capacities(d,(void *const *)input,sizes);
  for(int placement=0;placement<(replay?1:2);++placement){
   int end=replay?1:placement;struct guarded ref[24],nat[24];void *v[24],*w[24];
   for(int k=0;k<24;++k){
    ref[k]=guard(sizes[k],end);nat[k]=guard(sizes[k],end);v[k]=ref[k].value;w[k]=nat[k].value;memcpy(v[k],input[k],sizes[k]);memcpy(w[k],input[k],sizes[k]);
    if((k<20||k==23)&&(mprotect(ref[k].mapping+ref[k].page,ref[k].pages*ref[k].page,PROT_READ)||mprotect(nat[k].mapping+nat[k].page,nat[k].pages*nat[k].page,PROT_READ)))fail("readonly complete argument pages");
   }
   srtm_taumol23_(PASS(v));
   co=0;for(int k=0;k<8;++k){if(memcmp(globals[k],constants+co,global_sizes[k]))fail("complete source globals unchanged");co+=global_sizes[k];}
   const unsigned char *before[3]={input[20],input[21],input[22]};const double *out[3]={v[20],v[21],v[22]};physical(d,v,before,out,replay);
   if(a){
    if(!srtm23_abi_probe||srtm23_abi_probe(PASS(w)))fail("immediate native saved registers, stack and FPCR");++abi;
    co=0;for(int k=0;k<8;++k){if(memcmp(globals[k],constants+co,global_sizes[k]))fail("complete native globals unchanged");co+=global_sizes[k];}
   }
   writeall(r,header,32);if(a)writeall(a,header,32);size_t returned=32;
   for(int k=20;k<23;++k){
    if(a&&memcmp(v[k],w[k],sizes[k])){size_t first=0;unsigned char *x=v[k],*y=w[k];while(x[first]==y[first])++first;fprintf(stderr,"SRTM23 mismatch record=%" PRIu64 " placement=%d field=%d byte=%zu source=%02x native=%02x\n",records,end,k-19,first,x[first],y[first]);fail("complete returned bytes");}
    writeall(r,v[k],sizes[k]);if(a)writeall(a,w[k],sizes[k]);returned+=sizes[k];
   }
   const double *mu=v[23];for(int j=0;j<n;++j)if(mu[j]>0)for(int g=0;g<10;++g)for(int k=0;k<H;++k)for(int field=21;field<23;++field){
    uint64_t z=bits(((double *)v[field])[j+(size_t)n*(k+V*g)]);if(z==0)++positive;if(z==UINT64_C(0x8000000000000000))++negative;if((z&UINT64_C(0x7ff0000000000000))==0&&(z&UINT64_C(0xfffffffffffff)))++subnormal;
   }
   for(int k=0;k<24;++k){release(&ref[k]);release(&nat[k]);}
   __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved complete-call FPCR");++placed;total+=returned;
  }
  for(int k=0;k<24;++k)free(input[k]);++records;
 }
 if(ferror(f)||fclose(f)||fclose(r)||(a&&fclose(a)))fail("critical streams close");
 printf("SRTM23 %s %s PASS input_records=%" PRIu64 " protected_calls=%" PRIu64 " complete_bytes=%" PRIu64 " independent=%" PRIu64 " ABI=%" PRIu64 " lower_spectral_layers=%" PRIu64 " upper_spectral_layers=%" PRIu64 " solar_copies=%" PRIu64 " preserved_bytes=%" PRIu64 " next_reads=%" PRIu64 " solar_crossings=%" PRIu64 " negative_factor_visits=%" PRIu64 " positive_zeros=%" PRIu64 " negative_zeros=%" PRIu64 " nonzero_subnormals=%" PRIu64 " differing_bytes=0 FPCR=0\n",a?"NATIVE":"SOURCE",replay?"REPLAY":"GUARDED",records,placed,total,independent,abi,lower_layers,upper_layers,solar_copies,preserved_bytes,previous_reads,solar_crossings,negative_factors,positive,negative,subnormal);return 0;
}


/* Inspect saved registers after all twenty-four pointer arguments. */
#ifdef SRTM23_ABI_OBSERVER
__asm__(".text\n.p2align 2\n.global srtm23_abi_probe\n.type srtm23_abi_probe,%function\nsrtm23_abi_probe:\nsub sp,sp,#288\nstp x19,x20,[sp,#128]\nstp x21,x22,[sp,#144]\nstp x23,x24,[sp,#160]\nstp x25,x26,[sp,#176]\nstp x27,x28,[sp,#192]\nstp x29,x30,[sp,#208]\nstp d8,d9,[sp,#224]\nstp d10,d11,[sp,#240]\nstp d12,d13,[sp,#256]\nstp d14,d15,[sp,#272]\nldp x9,x10,[sp,#288]\nstp x9,x10,[sp,#0]\nldp x9,x10,[sp,#304]\nstp x9,x10,[sp,#16]\nldp x9,x10,[sp,#320]\nstp x9,x10,[sp,#32]\nldp x9,x10,[sp,#336]\nstp x9,x10,[sp,#48]\nldp x9,x10,[sp,#352]\nstp x9,x10,[sp,#64]\nldp x9,x10,[sp,#368]\nstp x9,x10,[sp,#80]\nldp x9,x10,[sp,#384]\nstp x9,x10,[sp,#96]\nldp x9,x10,[sp,#400]\nstp x9,x10,[sp,#112]\nmov x19,#4883\nmov x20,#5140\nmov x21,#5397\nmov x22,#5654\nmov x23,#5911\nmov x24,#6168\nmov x25,#6425\nmov x26,#6682\nmov x27,#6939\nmov x28,#7196\nmov x29,sp\nmov x9,#2056\nfmov d8,x9\nmov x9,#2313\nfmov d9,x9\nmov x9,#2570\nfmov d10,x9\nmov x9,#2827\nfmov d11,x9\nmov x9,#3084\nfmov d12,x9\nmov x9,#3341\nfmov d13,x9\nmov x9,#3598\nfmov d14,x9\nmov x9,#3855\nfmov d15,x9\nbl srtm_taumol23_assembly_\nmov x9,sp\ncmp x29,x9\nb.ne .Lsrtm23_abi_trap\nmov x9,#4883\ncmp x19,x9\nb.ne .Lsrtm23_abi_bad\nmov x9,#5140\ncmp x20,x9\nb.ne .Lsrtm23_abi_bad\nmov x9,#5397\ncmp x21,x9\nb.ne .Lsrtm23_abi_bad\nmov x9,#5654\ncmp x22,x9\nb.ne .Lsrtm23_abi_bad\nmov x9,#5911\ncmp x23,x9\nb.ne .Lsrtm23_abi_bad\nmov x9,#6168\ncmp x24,x9\nb.ne .Lsrtm23_abi_bad\nmov x9,#6425\ncmp x25,x9\nb.ne .Lsrtm23_abi_bad\nmov x9,#6682\ncmp x26,x9\nb.ne .Lsrtm23_abi_bad\nmov x9,#6939\ncmp x27,x9\nb.ne .Lsrtm23_abi_bad\nmov x9,#7196\ncmp x28,x9\nb.ne .Lsrtm23_abi_bad\nfmov x9,d8\nmov x10,#2056\ncmp x9,x10\nb.ne .Lsrtm23_abi_bad\nfmov x9,d9\nmov x10,#2313\ncmp x9,x10\nb.ne .Lsrtm23_abi_bad\nfmov x9,d10\nmov x10,#2570\ncmp x9,x10\nb.ne .Lsrtm23_abi_bad\nfmov x9,d11\nmov x10,#2827\ncmp x9,x10\nb.ne .Lsrtm23_abi_bad\nfmov x9,d12\nmov x10,#3084\ncmp x9,x10\nb.ne .Lsrtm23_abi_bad\nfmov x9,d13\nmov x10,#3341\ncmp x9,x10\nb.ne .Lsrtm23_abi_bad\nfmov x9,d14\nmov x10,#3598\ncmp x9,x10\nb.ne .Lsrtm23_abi_bad\nfmov x9,d15\nmov x10,#3855\ncmp x9,x10\nb.ne .Lsrtm23_abi_bad\nmrs x9,fpcr\ncbnz x9,.Lsrtm23_abi_bad\nmov w0,#0\nb .Lsrtm23_abi_restore\n.Lsrtm23_abi_bad:\nmov w0,#1\n.Lsrtm23_abi_restore:\nldp d8,d9,[sp,#224]\nldp d10,d11,[sp,#240]\nldp d12,d13,[sp,#256]\nldp d14,d15,[sp,#272]\nldp x19,x20,[sp,#128]\nldp x21,x22,[sp,#144]\nldp x23,x24,[sp,#160]\nldp x25,x26,[sp,#176]\nldp x27,x28,[sp,#192]\nldp x29,x30,[sp,#208]\nadd sp,sp,#288\nret\n.Lsrtm23_abi_trap:\nbrk #1\n.size srtm23_abi_probe,.-srtm23_abi_probe\n");
#endif

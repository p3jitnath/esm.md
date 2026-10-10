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

static double *absa,*solar,*rayleigh,*ozone_a,*ozone_b;
static int32_t *reference_layer,*species;
static uint64_t independent,day_columns,night_columns,lower_layers,upper_layers,solar_copies,preserved_bytes,lookahead_reads,negative_factors;
static double min_factor=DBL_MAX,max_factor=-DBL_MAX,max_absorption;
static void fail(const char *s){fprintf(stderr,"SRTM25 failed %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static const char *global_names[7]={"yoesrta25.eq.0_","__yoesrta25_MOD_sfluxrefc","__yoesrta25_MOD_raylc","__yoesrta25_MOD_abso3ac","__yoesrta25_MOD_abso3bc","__yoesrta25_MOD_layreffr","__yoesrtwn_MOD_nspa"};
static const size_t global_sizes[7]={8320,128,128,128,128,4,56};
static void *globals[7];
static void bind_globals(void){
 for(int k=0;k<7;++k){globals[k]=dlsym(RTLD_DEFAULT,global_names[k]);if(!globals[k])fail("all declared coefficient/global input bindings");}
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

#include <sys/mman.h>
#include <unistd.h>
void srtm_taumol25_(PARAMETERS);
int srtm25_abi_probe(PARAMETERS) __attribute__((weak));
struct guarded {unsigned char *mapping,*value;size_t pages,page,size;};
static struct guarded guard(size_t size,int end){
 size_t page=(size_t)sysconf(_SC_PAGESIZE),pages=((size?size:1)+page-1)/page;
 unsigned char *p=mmap(NULL,(pages+2)*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(p==MAP_FAILED||mprotect(p+page,pages*page,PROT_READ|PROT_WRITE))fail("protected complete capacity allocation");
 memset(p+page,0xa5,pages*page);struct guarded a={p,p+page+(end?pages*page-size:0),pages,page,size};return a;
}
static void release(struct guarded *b){
 size_t first=b->value-(b->mapping+b->page);
 for(size_t z=0;z<b->pages*b->page;++z)if(z<first||z>=first+b->size)if(b->mapping[b->page+z]!=0xa5)fail("unchanged complete-capacity poisoned neighbours");
 if(munmap(b->mapping,(b->pages+2)*b->page))fail("protected capacity release");
}
static void readall(FILE *f,void *p,size_t n){if(n&&fread(p,1,n,f)!=n)fail("complete frozen input read");}
#define PASS(v) v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12],v[13],v[14],v[15],v[16],v[17],v[18]
int main(int argc,char **argv){
 if(argc!=5)fail("mode input source-output native-output arguments");
 int replay=!strcmp(argv[1],"replay"),guarded=!strcmp(argv[1],"guarded");if(!replay&&!guarded)fail("guarded or replay mode");
 int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(!hook)fail("standalone profiling control");*hook=0;bind_globals();
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("FPCR exactly zero");
 FILE *f=fopen(argv[2],"rb"),*r=fopen(argv[3],"wb"),*a=srtm_taumol25_assembly_?fopen(argv[4],"wb"):NULL;
 if(!f||!r||(srtm_taumol25_assembly_&&!a))fail("complete critical streams open");
 uint64_t records=0,placed=0,total=0,abi=0,positive=0,negative=0,subnormal=0;
 for(;;){
  unsigned char header[32];size_t nr=fread(header,1,32,f);if(!nr)break;if(nr!=32)fail("complete record header");
  int32_t d[4];memcpy(d,header+16,16);int n=d[1]-d[0]+1,H=d[2],V=d[3];
  if(d[0]<1||n<0||n>4096||H<0||V<H||V>512)fail("complete frozen shape");
  if(replay){uint64_t call;int32_t phase,site;memcpy(&call,header,8);memcpy(&phase,header+8,4);memcpy(&site,header+12,4);if(call!=records||phase<0||phase>24||site!=1)fail("ordered complete actual caller header");}
  size_t sizes[19]={32,4,4,4};for(int k=4;k<14;++k)sizes[k]=(size_t)n*V*(k>=8&&k<=10?4:8);
  sizes[14]=(size_t)n*4;sizes[15]=(size_t)n*16*8;sizes[16]=sizes[17]=(size_t)n*V*16*8;sizes[18]=(size_t)n*8;
  unsigned char *input[19];for(int k=0;k<19;++k){input[k]=malloc(sizes[k]?sizes[k]:1);if(!input[k])fail("complete input allocation");}
  readall(f,input[0],32);if(memcmp(input[0],d+3,4))fail("TDIMV used field matches header");
  for(int k=1;k<4;++k)memcpy(input[k],d+k-1,4);
  unsigned char constants[8892];readall(f,constants,sizeof constants);
  for(int k=4;k<15;++k)readall(f,input[k],sizes[k]);readall(f,input[18],sizes[18]);for(int k=15;k<18;++k)readall(f,input[k],sizes[k]);
  const double *mu0=(double *)input[18];const int32_t *trop0=(int32_t *)input[14],*jp0=(int32_t *)input[8],*jt0=(int32_t *)input[9],*jt10=(int32_t *)input[10];
  for(int j=0;j<n;++j)if(mu0[j]>0){
   if(trop0[j]<0||trop0[j]>H||(trop0[j]>0&&trop0[j]>=V))fail("frozen active next-row capacity before source execution");
   for(int k=0;k<H&&k<trop0[j];++k){size_t ix=j+(size_t)n*k;if(jp0[ix]<1||jp0[ix]>12||jt0[ix]<1||jt0[ix]>4||jt10[ix]<1||jt10[ix]>4)fail("frozen active four-point table bounds");}
  }
  for(int placement=0;placement<(replay?1:2);++placement){
   int end=replay?1:placement;struct guarded ref[19],nat[19];void *v[19],*w[19];
   for(int k=0;k<19;++k){
    ref[k]=guard(sizes[k],end);nat[k]=guard(sizes[k],end);v[k]=ref[k].value;w[k]=nat[k].value;memcpy(v[k],input[k],sizes[k]);memcpy(w[k],input[k],sizes[k]);
    if((k<15||k==18)&&(mprotect(ref[k].mapping+ref[k].page,ref[k].pages*ref[k].page,PROT_READ)||mprotect(nat[k].mapping+nat[k].page,nat[k].pages*nat[k].page,PROT_READ)))fail("readonly complete argument pages");
   }
   size_t co=0;for(int k=0;k<7;++k){memcpy(globals[k],constants+co,global_sizes[k]);co+=global_sizes[k];}
   srtm_taumol25_(PASS(v));
   co=0;for(int k=0;k<7;++k){if(memcmp(globals[k],constants+co,global_sizes[k]))fail("source complete numerical globals unchanged");co+=global_sizes[k];}
   const unsigned char *before[3]={input[15],input[16],input[17]};const double *out[3]={v[15],v[16],v[17]};
   physical(d,v,before,out,replay);
   if(a){
    if(!srtm25_abi_probe)fail("required immediate ABI observer");if(srtm25_abi_probe(PASS(w)))fail("immediate native saved registers, stack and FPCR");++abi;
    co=0;for(int k=0;k<7;++k){if(memcmp(globals[k],constants+co,global_sizes[k]))fail("native complete numerical globals unchanged");co+=global_sizes[k];}
   }
   writeall(r,header,32);if(a)writeall(a,header,32);size_t returned=32;
   for(int k=15;k<18;++k){
    if(a&&memcmp(v[k],w[k],sizes[k])){
     size_t first=0;unsigned char *x=v[k],*y=w[k];while(x[first]==y[first])++first;
     fprintf(stderr,"SRTM25 first mismatch record=%" PRIu64 " placement=%d field=%d byte=%zu source=%02x native=%02x\n",records,end,k-14,first,x[first],y[first]);fail("complete returned bytes");
    }
    writeall(r,v[k],sizes[k]);if(a)writeall(a,w[k],sizes[k]);returned+=sizes[k];
   }
   const double *mu=v[18];for(int j=0;j<n;++j)if(mu[j]>0)for(int g=0;g<6;++g)for(int k=0;k<H;++k)for(int field=16;field<18;++field){
    uint64_t z=bits(((double *)v[field])[j+(size_t)n*(k+V*g)]);if(z==0)++positive;if(z==UINT64_C(0x8000000000000000))++negative;if((z&UINT64_C(0x7ff0000000000000))==0&&(z&UINT64_C(0xfffffffffffff)))++subnormal;
   }
   for(int k=0;k<19;++k){release(&ref[k]);release(&nat[k]);}
   __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved complete-call FPCR");++placed;total+=returned;
  }
  for(int k=0;k<19;++k)free(input[k]);++records;
 }
 if(ferror(f)||fclose(f)||fclose(r)||(a&&fclose(a)))fail("complete critical streams close");
 printf("SRTM25 %s %s PASS input_records=%" PRIu64 " protected_calls=%" PRIu64 " complete_bytes=%" PRIu64 " independent=%" PRIu64 " ABI=%" PRIu64 " lower_spectral_layers=%" PRIu64 " upper_spectral_layers=%" PRIu64 " solar_copies=%" PRIu64 " preserved_bytes=%" PRIu64 " lookahead_reads=%" PRIu64 " negative_factor_visits=%" PRIu64 " positive_zeros=%" PRIu64 " negative_zeros=%" PRIu64 " nonzero_subnormals=%" PRIu64 " differing_bytes=0 FPCR=0\n",a?"NATIVE":"SOURCE",replay?"REPLAY":"GUARDED",records,placed,total,independent,abi,lower_layers,upper_layers,solar_copies,preserved_bytes,lookahead_reads,negative_factors,positive,negative,subnormal);return 0;
}

/* Forward all 19 pointers and inspect preserved registers immediately. */
#ifdef SRTM25_ABI_OBSERVER
__asm__(".text\n.p2align 2\n.global srtm25_abi_probe\n.type srtm25_abi_probe,%function\nsrtm25_abi_probe:\nsub sp,sp,#256\nstp x19,x20,[sp,#96]\nstp x21,x22,[sp,#112]\nstp x23,x24,[sp,#128]\nstp x25,x26,[sp,#144]\nstp x27,x28,[sp,#160]\nstp x29,x30,[sp,#176]\nstp d8,d9,[sp,#192]\nstp d10,d11,[sp,#208]\nstp d12,d13,[sp,#224]\nstp d14,d15,[sp,#240]\nldp x9,x10,[sp,#256]\nstp x9,x10,[sp,#0]\nldp x9,x10,[sp,#272]\nstp x9,x10,[sp,#16]\nldp x9,x10,[sp,#288]\nstp x9,x10,[sp,#32]\nldp x9,x10,[sp,#304]\nstp x9,x10,[sp,#48]\nldp x9,x10,[sp,#320]\nstp x9,x10,[sp,#64]\nldr x9,[sp,#336]\nstr x9,[sp,#80]\nmov x19,#4883\nmov x20,#5140\nmov x21,#5397\nmov x22,#5654\nmov x23,#5911\nmov x24,#6168\nmov x25,#6425\nmov x26,#6682\nmov x27,#6939\nmov x28,#7196\nmov x29,sp\nmov x9,#2056\nfmov d8,x9\nmov x9,#2313\nfmov d9,x9\nmov x9,#2570\nfmov d10,x9\nmov x9,#2827\nfmov d11,x9\nmov x9,#3084\nfmov d12,x9\nmov x9,#3341\nfmov d13,x9\nmov x9,#3598\nfmov d14,x9\nmov x9,#3855\nfmov d15,x9\nbl srtm_taumol25_assembly_\nmov x9,sp\ncmp x29,x9\nb.ne .Lsrtm25_abi_trap\nmov x9,#4883\ncmp x19,x9\nb.ne .Lsrtm25_abi_bad\nmov x9,#5140\ncmp x20,x9\nb.ne .Lsrtm25_abi_bad\nmov x9,#5397\ncmp x21,x9\nb.ne .Lsrtm25_abi_bad\nmov x9,#5654\ncmp x22,x9\nb.ne .Lsrtm25_abi_bad\nmov x9,#5911\ncmp x23,x9\nb.ne .Lsrtm25_abi_bad\nmov x9,#6168\ncmp x24,x9\nb.ne .Lsrtm25_abi_bad\nmov x9,#6425\ncmp x25,x9\nb.ne .Lsrtm25_abi_bad\nmov x9,#6682\ncmp x26,x9\nb.ne .Lsrtm25_abi_bad\nmov x9,#6939\ncmp x27,x9\nb.ne .Lsrtm25_abi_bad\nmov x9,#7196\ncmp x28,x9\nb.ne .Lsrtm25_abi_bad\nfmov x9,d8\nmov x10,#2056\ncmp x9,x10\nb.ne .Lsrtm25_abi_bad\nfmov x9,d9\nmov x10,#2313\ncmp x9,x10\nb.ne .Lsrtm25_abi_bad\nfmov x9,d10\nmov x10,#2570\ncmp x9,x10\nb.ne .Lsrtm25_abi_bad\nfmov x9,d11\nmov x10,#2827\ncmp x9,x10\nb.ne .Lsrtm25_abi_bad\nfmov x9,d12\nmov x10,#3084\ncmp x9,x10\nb.ne .Lsrtm25_abi_bad\nfmov x9,d13\nmov x10,#3341\ncmp x9,x10\nb.ne .Lsrtm25_abi_bad\nfmov x9,d14\nmov x10,#3598\ncmp x9,x10\nb.ne .Lsrtm25_abi_bad\nfmov x9,d15\nmov x10,#3855\ncmp x9,x10\nb.ne .Lsrtm25_abi_bad\nmrs x9,fpcr\ncbnz x9,.Lsrtm25_abi_bad\nmov w0,#0\nb .Lsrtm25_abi_restore\n.Lsrtm25_abi_bad:\nmov w0,#1\n.Lsrtm25_abi_restore:\nldp d8,d9,[sp,#192]\nldp d10,d11,[sp,#208]\nldp d12,d13,[sp,#224]\nldp d14,d15,[sp,#240]\nldp x19,x20,[sp,#96]\nldp x21,x22,[sp,#112]\nldp x23,x24,[sp,#128]\nldp x25,x26,[sp,#144]\nldp x27,x28,[sp,#160]\nldp x29,x30,[sp,#176]\nadd sp,sp,#256\nret\n.Lsrtm25_abi_trap:\nbrk #1\n.size srtm25_abi_probe,.-srtm25_abi_probe\n");
#endif

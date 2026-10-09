/* Capture full band-26 storage before direct assembly generation.
 * Molecular amounts use units of 10^20 molecules per square centimetre.
 * Rayleigh coefficients use the inverse scaled-column unit.
 * Solar spectrum uses W/m^2. Optical depth is dimensionless.
 * Untouched output bytes are captured as incoming storage, including night. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PARAMETERS void *a0,void *a1,void *a2,void *a3,void *a4,void *a5,void *a6,void *a7,void *a8,void *a9
#define ARGUMENTS a0,a1,a2,a3,a4,a5,a6,a7,a8,a9
typedef void (*kernel)(PARAMETERS);
void srtm_taumol26_assembly_(PARAMETERS) __attribute__((weak));
static uint64_t calls,independent,day_columns,night_columns,active_rayleigh,solar_copies,preserved_bytes;
static void fail(const char *s){fprintf(stderr,"SRTM26 failed %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static void physical(const int32_t *d,const double *column,const int32_t *trop,const double *mu,const double *coeff,const double *flux,const unsigned char *const *before,const double *const *out,int require_defined_solar){
 const int n=d[1]-d[0]+1,lev=d[2],stride=d[3];
 for(int j=0;j<n;++j){
  if(!isfinite(mu[j])||mu[j]<-1||mu[j]>1)fail("finite solar zenith cosine");
  const int day=mu[j]>0;
  if(day){++day_columns;if(require_defined_solar&&(lev<1||trop[j]<1||trop[j]>lev))fail("active solar output undefined before caller read");}
  else ++night_columns;
  for(int g=0;g<16;++g){
   const size_t solar_ix=(size_t)j+(size_t)n*g;
   const int sun=day&&g<6&&trop[j]>=1&&trop[j]<=lev;
   if(sun){
    if(!isfinite(flux[g])||flux[g]<0||bits(out[0][solar_ix])!=bits(flux[g]))fail("complete active fixed solar spectrum");
    ++solar_copies;++independent;
   }else{
    if(memcmp((const unsigned char *)out[0]+solar_ix*8,before[0]+solar_ix*8,8))fail("unchanged complete solar storage");
    preserved_bytes+=8;++independent;
   }
   for(int k=0;k<stride;++k){
    const size_t ix=(size_t)j+(size_t)n*(k+stride*g),c=(size_t)j+(size_t)n*k;
    if(day&&g<6&&k<lev){
     if(!isfinite(column[c])||column[c]<0||!isfinite(coeff[g])||coeff[g]<0)fail("nonnegative finite active molecular scattering inputs");
     if(bits(out[1][ix])!=0)fail("complete active absorption positive zero");
     const long double expected=(long double)column[c]*coeff[g];
     const long double tol=16*DBL_EPSILON*fabsl(expected)+4*DBL_TRUE_MIN;
     if(!isfinite(out[2][ix])||out[2][ix]<0||fabsl((long double)out[2][ix]-expected)>tol)fail("independent molecular Rayleigh optical depth");
     if(column[c]==0&&out[2][ix]!=0)fail("zero molecular column scattering limit");
     if(coeff[g]==0&&out[2][ix]!=0)fail("zero scattering cross section limit");
     independent+=3;++active_rayleigh;
     if(column[c]==0x1p20&&coeff[g]==0x1p-20){
      if(bits(out[2][ix])!=UINT64_C(0x3ff0000000000000))fail("known unit Rayleigh depth");++independent;
     }
     if(j>0&&mu[j-1]>0&&column[c]==2*column[c-1]&&out[2][ix-1]>=DBL_MIN&&out[2][ix-1]<=DBL_MAX/2){
      if(out[2][ix]!=2*out[2][ix-1])fail("exact doubled molecular-column scattering");++independent;
     }
    }else{
     for(int z=1;z<3;++z)if(memcmp((const unsigned char *)out[z]+ix*8,before[z]+ix*8,8))fail("unchanged complete night inactive-level or unused-point storage");
     preserved_bytes+=16;independent+=2;
    }
   }
  }
 }
}

#include <sys/mman.h>
#include <unistd.h>
void srtm_taumol26_(PARAMETERS);
int srtm26_abi_probe(PARAMETERS) __attribute__((weak));
struct guarded {unsigned char *mapping,*value;size_t pages,page,size;};
static struct guarded guard(size_t size,int end){
 const size_t page=(size_t)sysconf(_SC_PAGESIZE),pages=((size?size:1)+page-1)/page;
 unsigned char *p=mmap(NULL,(pages+2)*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(p==MAP_FAILED||mprotect(p+page,pages*page,PROT_READ|PROT_WRITE))fail("protected whole capacity allocation");
 memset(p+page,0xa5,pages*page);
 struct guarded a={p,p+page+(end?pages*page-size:0),pages,page,size};return a;
}
static void release(struct guarded *b){
 const size_t start=(size_t)(b->value-(b->mapping+b->page));
 for(size_t z=0;z<b->pages*b->page;++z)if(z<start||z>=start+b->size)if(b->mapping[b->page+z]!=0xa5)fail("unchanged whole-capacity poisoned neighbours");
 if(munmap(b->mapping,(b->pages+2)*b->page))fail("protected capacity release");
}
static void readall(FILE *f,void *p,size_t n){if(n&&fread(p,1,n,f)!=n)fail("whole frozen input read");}
#define PASS(v) v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9]
int main(int argc,char **argv){
 if(argc!=5)fail("mode input source-output native-output arguments");
 const int replay=!strcmp(argv[1],"replay"),guarded=!strcmp(argv[1],"guarded");
 if(!replay&&!guarded)fail("guarded or replay mode");
 int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
 double *rcoef=dlsym(RTLD_DEFAULT,"__yoesrta26_MOD_raylc"),*scoef=dlsym(RTLD_DEFAULT,"__yoesrta26_MOD_sfluxrefc");
 if(!hook||!rcoef||!scoef)fail("profiling control and declared coefficient inputs");
 *hook=0; /* This standalone numerical check has no MPI profiling setup. */
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("FPCR exactly zero");
 FILE *f=fopen(argv[2],"rb"),*r=fopen(argv[3],"wb"),*a=srtm_taumol26_assembly_?fopen(argv[4],"wb"):NULL;
 if(!f||!r||(srtm_taumol26_assembly_&&!a))fail("critical streams open");
 uint64_t records=0,placed=0,total=0,abi=0,negative=0,subnormal=0,positive=0;
 for(;;){
  unsigned char header[32];size_t nr=fread(header,1,32,f);if(!nr)break;if(nr!=32)fail("whole frozen record header");
  int32_t d[4];memcpy(d,header+16,16);int n=d[1]-d[0]+1,lev=d[2],stride=d[3];
  if(d[0]<1||n<0||n>4096||lev<0||stride<lev||stride>512)fail("frozen complete shape");
  if(replay){uint64_t call;int32_t phase,site;memcpy(&call,header,8);memcpy(&phase,header+8,4);memcpy(&site,header+12,4);if(call!=records||phase<0||phase>24||site!=1)fail("ordered complete actual caller header");}
  size_t sizes[10]={32,4,4,4,(size_t)n*stride*8,(size_t)n*4,(size_t)n*16*8,(size_t)n*stride*16*8,(size_t)n*stride*16*8,(size_t)n*8};
  unsigned char *input[10];for(int k=0;k<10;++k){input[k]=malloc(sizes[k]?sizes[k]:1);if(!input[k])fail("frozen input allocation");}
  readall(f,input[0],32);if(memcmp(input[0],d+3,4))fail("TDIMV used component matches header");
  double coefficients[32];readall(f,coefficients,256);
  for(int k=1;k<4;++k)memcpy(input[k],d+k-1,4);
  readall(f,input[4],sizes[4]);readall(f,input[5],sizes[5]);readall(f,input[9],sizes[9]);
  for(int k=6;k<9;++k)readall(f,input[k],sizes[k]);
  for(int placement=0;placement<(replay?1:2);++placement){
   calls=placed;int end=replay?1:placement;struct guarded ref[10],nat[10];void *v[10],*w[10];
   for(int k=0;k<10;++k){
    ref[k]=guard(sizes[k],end);nat[k]=guard(sizes[k],end);v[k]=ref[k].value;w[k]=nat[k].value;
    memcpy(v[k],input[k],sizes[k]);memcpy(w[k],input[k],sizes[k]);
    if((k<6||k==9)&&(mprotect(ref[k].mapping+ref[k].page,ref[k].pages*ref[k].page,PROT_READ)||mprotect(nat[k].mapping+nat[k].page,nat[k].pages*nat[k].page,PROT_READ)))fail("read-only complete argument pages");
   }
   memcpy(rcoef,coefficients,128);memcpy(scoef,coefficients+16,128);
   srtm_taumol26_(PASS(v));
   if(memcmp(rcoef,coefficients,128)||memcmp(scoef,coefficients+16,128))fail("original complete coefficient inputs unchanged");
   const unsigned char *before[3]={input[6],input[7],input[8]};
   const double *out[3]={v[6],v[7],v[8]};
   physical(d,v[4],v[5],v[9],coefficients,coefficients+16,before,out,replay);
   if(a){
    if(!srtm26_abi_probe)fail("required immediate direct ABI observer");
    if(srtm26_abi_probe(PASS(w)))fail("immediate native saved-register stack and FPCR preservation");++abi;
    if(memcmp(rcoef,coefficients,128)||memcmp(scoef,coefficients+16,128))fail("native complete coefficient inputs unchanged");
   }
   writeall(r,header,32);if(a)writeall(a,header,32);size_t returned=32;
   for(int k=6;k<9;++k){
    if(a&&memcmp(v[k],w[k],sizes[k])){
     size_t first=0;unsigned char *x=v[k],*y=w[k];while(x[first]==y[first])++first;
     fprintf(stderr,"SRTM26 first mismatch record=%" PRIu64 " placement=%d field=%d byte=%zu source=%02x native=%02x\n",records,end,k-5,first,x[first],y[first]);fail("all complete returned bytes");
    }
    writeall(r,v[k],sizes[k]);if(a)writeall(a,w[k],sizes[k]);returned+=sizes[k];
   }
   const double *mu=v[9];for(int j=0;j<n;++j)if(mu[j]>0)for(int g=0;g<6;++g)for(int k=0;k<lev;++k){
    uint64_t z=bits(((double *)v[8])[j+n*(k+stride*g)]);if(z==0)++positive;if(z==UINT64_C(0x8000000000000000))++negative;if((z&UINT64_C(0x7ff0000000000000))==0&&(z&UINT64_C(0xfffffffffffff)))++subnormal;
   }
   for(int k=0;k<10;++k){release(&ref[k]);release(&nat[k]);}
   __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved whole-call FPCR");++placed;total+=returned;
  }
  for(int k=0;k<10;++k)free(input[k]);++records;
 }
 if(ferror(f)||fclose(f)||fclose(r)||(a&&fclose(a)))fail("whole corpus and returned streams close");
 printf("SRTM26 %s %s PASS input_records=%" PRIu64 " protected_calls=%" PRIu64 " complete_bytes=%" PRIu64 " independent=%" PRIu64 " ABI=%" PRIu64 " active_rayleigh=%" PRIu64 " solar_copies=%" PRIu64 " preserved_bytes=%" PRIu64 " positive_zeros=%" PRIu64 " negative_zeros=%" PRIu64 " nonzero_subnormals=%" PRIu64 " differing_bytes=0 FPCR=0\n",a?"NATIVE":"SOURCE",replay?"REPLAY":"GUARDED",records,placed,total,independent,abi,active_rayleigh,solar_copies,preserved_bytes,positive,negative,subnormal);return 0;
}

/* Forward all ten pointers and inspect saved registers before C restores them. */
#ifdef SRTM26_ABI_OBSERVER
__asm__(".text\n.p2align 2\n.global srtm26_abi_probe\n.type srtm26_abi_probe,%function\nsrtm26_abi_probe:\nsub sp,sp,#192\nstp x19,x20,[sp,#16]\nstp x21,x22,[sp,#32]\nstp x23,x24,[sp,#48]\nstp x25,x26,[sp,#64]\nstp x27,x28,[sp,#80]\nstp x29,x30,[sp,#96]\nstp d8,d9,[sp,#112]\nstp d10,d11,[sp,#128]\nstp d12,d13,[sp,#144]\nstp d14,d15,[sp,#160]\nldp x9,x10,[sp,#192]\nstp x9,x10,[sp,#0]\nmov x19,#0x1313\nmov x20,#0x1414\nmov x21,#0x1515\nmov x22,#0x1616\nmov x23,#0x1717\nmov x24,#0x1818\nmov x25,#0x1919\nmov x26,#0x1a1a\nmov x27,#0x1b1b\nmov x28,#0x1c1c\nmov x29,sp\nmov x9,#0x808\nfmov d8,x9\nmov x9,#0x909\nfmov d9,x9\nmov x9,#0xa0a\nfmov d10,x9\nmov x9,#0xb0b\nfmov d11,x9\nmov x9,#0xc0c\nfmov d12,x9\nmov x9,#0xd0d\nfmov d13,x9\nmov x9,#0xe0e\nfmov d14,x9\nmov x9,#0xf0f\nfmov d15,x9\nbl srtm_taumol26_assembly_\nmov x9,sp\ncmp x29,x9\nb.ne .Lsrtm26_abi_trap\nmov x9,#0x1313\ncmp x19,x9\nb.ne .Lsrtm26_abi_bad\nmov x9,#0x1414\ncmp x20,x9\nb.ne .Lsrtm26_abi_bad\nmov x9,#0x1515\ncmp x21,x9\nb.ne .Lsrtm26_abi_bad\nmov x9,#0x1616\ncmp x22,x9\nb.ne .Lsrtm26_abi_bad\nmov x9,#0x1717\ncmp x23,x9\nb.ne .Lsrtm26_abi_bad\nmov x9,#0x1818\ncmp x24,x9\nb.ne .Lsrtm26_abi_bad\nmov x9,#0x1919\ncmp x25,x9\nb.ne .Lsrtm26_abi_bad\nmov x9,#0x1a1a\ncmp x26,x9\nb.ne .Lsrtm26_abi_bad\nmov x9,#0x1b1b\ncmp x27,x9\nb.ne .Lsrtm26_abi_bad\nmov x9,#0x1c1c\ncmp x28,x9\nb.ne .Lsrtm26_abi_bad\nfmov x9,d8\nmov x10,#0x808\ncmp x9,x10\nb.ne .Lsrtm26_abi_bad\nfmov x9,d9\nmov x10,#0x909\ncmp x9,x10\nb.ne .Lsrtm26_abi_bad\nfmov x9,d10\nmov x10,#0xa0a\ncmp x9,x10\nb.ne .Lsrtm26_abi_bad\nfmov x9,d11\nmov x10,#0xb0b\ncmp x9,x10\nb.ne .Lsrtm26_abi_bad\nfmov x9,d12\nmov x10,#0xc0c\ncmp x9,x10\nb.ne .Lsrtm26_abi_bad\nfmov x9,d13\nmov x10,#0xd0d\ncmp x9,x10\nb.ne .Lsrtm26_abi_bad\nfmov x9,d14\nmov x10,#0xe0e\ncmp x9,x10\nb.ne .Lsrtm26_abi_bad\nfmov x9,d15\nmov x10,#0xf0f\ncmp x9,x10\nb.ne .Lsrtm26_abi_bad\nmrs x9,fpcr\ncbnz x9,.Lsrtm26_abi_bad\nmov w0,#0\nb .Lsrtm26_abi_restore\n.Lsrtm26_abi_bad:\nmov w0,#1\n.Lsrtm26_abi_restore:\nldp d8,d9,[sp,#112]\nldp d10,d11,[sp,#128]\nldp d12,d13,[sp,#144]\nldp d14,d15,[sp,#160]\nldp x19,x20,[sp,#16]\nldp x21,x22,[sp,#32]\nldp x23,x24,[sp,#48]\nldp x25,x26,[sp,#64]\nldp x27,x28,[sp,#80]\nldp x29,x30,[sp,#96]\nadd sp,sp,#192\nret\n.Lsrtm26_abi_trap:\nbrk #1\n.size srtm26_abi_probe,.-srtm26_abi_probe\n");
#endif

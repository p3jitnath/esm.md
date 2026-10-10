/* Capture each whole original twelve-neighbour call in the coarse forecast.
 * All fourteen arguments are ordinary pointers. Integers have 32 bits, and
 * row-fast field values use 64-bit floating point with the caller's units.
 * Weights have no unit. The original body and complete native body receive
 * the same incoming storage, and every returned byte is compared.
 * A separate expanded reference checks twelve samples and the three clips
 * at higher precision. The driver supplies no part of the native update.
 * LAIDDI_SOURCE_ONLY observes only the original body before direct emission.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <omp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
_Static_assert(sizeof(double)==8&&sizeof(int32_t)==4,"original scalar widths");
_Static_assert(LDBL_MANT_DIG>=113,"expanded reference precision");
typedef void(*fn)(const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const double*,const int32_t*,const double*,double*);
#ifndef LAIDDI_SOURCE_ONLY
extern void laiddi_assembly_(const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const double*,const int32_t*,const double*,double*);
#endif
static fn original;static void*image;static FILE*input,*reference,*native;
static uint64_t visits,values,bytes,inputbytes,limited,bounded,flag_calls[2],partial_calls;static double worst;static int rejected;
static uint64_t fpcr(void){uint64_t x;__asm__ volatile("mrs %0,fpcr":"=r"(x));return x;}
__attribute__((noreturn))static void fail(const char*s){rejected=1;fprintf(stderr,"LAIDDI forecast FAIL visit=%"PRIu64" %s\n",visits,s);exit(2);}
static void *alloc(size_t n){if(n>PTRDIFF_MAX)fail("byte extent");void*p=malloc(n?n:1);if(!p)fail("allocate");return p;}
static void same(const void*a,const void*b,size_t n,const char*s)
{
 if(!memcmp(a,b,n))return;
 const unsigned char*x=a,*y=b;size_t k=0;while(k<n&&x[k]==y[k])k++;
 uint64_t u=0,v=0;size_t off=k/8*8,m=n-off<8?n-off:8;memcpy(&u,x+off,m);memcpy(&v,y+off,m);
 fprintf(stderr,"stage=%s first_byte=%zu physical_word=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",s,k,k/8,u,v);fail("whole bytes differ");
}
static void write_all(FILE*f,const void*p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("capture write");}
static void init(void)
{
 original=(fn)dlsym(RTLD_NEXT,"laiddi_");Dl_info bind;if(!original||!dladdr((void*)original,&bind))fail("original binding");image=bind.dli_fbase;
 input=fopen("laiddi-inputs.bin","wb");reference=fopen("laiddi-fortran.bin","wb");if(!input||!reference)fail("source files");
 setvbuf(input,NULL,_IOFBF,1048576);setvbuf(reference,NULL,_IOFBF,1048576);
#ifndef LAIDDI_SOURCE_ONLY
 native=fopen("laiddi-assembly.bin","wb");if(!native)fail("native file");setvbuf(native,NULL,_IOFBF,1048576);
#endif
}
static void physics(int32_t b,int32_t start,int32_t end,int32_t l,int32_t qm,const double*cla,const double*dlo,const double*clo,const int32_t*klo,const double*q,const double*out,size_t source)
{
 size_t cells=(size_t)b*l;
 for(int lev=0;lev<l;lev++)for(int row=start-1;row<end;row++){
  size_t pos=(size_t)lev*b+row;long double result[4],gain_row[4],magnitude=0,middle_min=LDBL_MAX,middle_max=-LDBL_MAX;
  for(int side=0;side<4;side++){
   int64_t base=(int64_t)klo[pos+side*cells]-(side==1||side==2);
   int count=(side==1||side==2)?4:2;long double corners[4];
   for(int east=0;east<count;east++){
    int64_t k=base+east;if(k<0||(uint64_t)k>=source||!isfinite(q[k]))fail("selected original source index");
    corners[east]=q[k];if(fabsl(corners[east])>magnitude)magnitude=fabsl(corners[east]);
   }
   if(count==2){
    long double x=dlo[pos+side*cells];if(!isfinite(x))fail("selected outer longitude fraction");
    result[side]=(1-x)*corners[0]+x*corners[1];gain_row[side]=1+2*fabsl(x);
   }else{
    long double w[4]={1,0,0,0},sumabs=0;
    for(int east=1;east<4;east++){
     w[east]=clo[pos+((side-1)*3+east-1)*cells];if(!isfinite(w[east]))fail("selected cubic longitude coefficient");
     w[0]-=w[east];sumabs+=fabsl(w[east]);
    }
    result[side]=0;for(int east=0;east<4;east++)result[side]+=w[east]*corners[east];
    gain_row[side]=1+2*sumabs;
    long double lo=fminl(corners[1],corners[2]),hi=fmaxl(corners[1],corners[2]);
    if(qm==1){result[side]=fmaxl(lo,fminl(hi,result[side]));limited++;}
    if(lo<middle_min)middle_min=lo;
    if(hi>middle_max)middle_max=hi;
   }
  }
  long double w[4]={1,0,0,0},sumabs=0,gain=0,exact=0;
  for(int side=1;side<4;side++){w[side]=cla[pos+(side-1)*cells];if(!isfinite(w[side]))fail("latitude coefficient");w[0]-=w[side];sumabs+=fabsl(w[side]);}
  for(int side=0;side<4;side++){exact+=w[side]*result[side];if(gain_row[side]>gain)gain=gain_row[side];}
  gain*=1+2*sumabs;
  if(qm==1){exact=fmaxl(fminl(result[1],result[2]),fminl(fmaxl(result[1],result[2]),exact));limited++;}
  long double limit=256*DBL_EPSILON*fmaxl(magnitude,DBL_MIN)*gain+128*(long double)DBL_TRUE_MIN*gain;
  long double error=fabsl((long double)out[pos]-exact);
  if(!isfinite(out[pos])||!isfinite(limit)||error>limit){fprintf(stderr,"level=%d row=%d value=%.17g error=%.9Lg limit=%.9Lg\n",lev+1,row+1,out[pos],error,limit);fail("independent expanded twelve-neighbour reference");}
  double f=(double)(error/limit);if(f>worst)worst=f;values++;
  if(qm==1){if((long double)out[pos]<middle_min||(long double)out[pos]>middle_max)fail("limited four-central-neighbour bounds");bounded++;}
 }
}
void laiddi_(const int32_t*a,const int32_t*b,const int32_t*start,const int32_t*end,const int32_t*l,const int32_t*f0,const int32_t*f1,const int32_t*qm,const double*cla,const double*dlo,const double*clo,const int32_t*klo,const double*q,double*out)
{
 if(!original)init();
 if(fpcr()||omp_get_max_threads()!=1)fail("FPCR/thread domain");
 for(int k=0;k<=omp_get_level();k++)if(omp_get_team_size(k)!=1)fail("ancestor thread team");
 Dl_info caller;void*pc=__builtin_return_address(0);
 if(!dladdr(pc,&caller)||caller.dli_fbase!=image||!caller.dli_sname||strcmp(caller.dli_sname,"larcinb_"))fail("original LARCINB caller image");
 if(*a<0||*a>1000000||*b<0||*b>1024||*l<0||*l>256||*start<1||*end>*b||*f1<*f0||(int64_t)*f1-*f0+1>256||(*qm!=0&&*qm!=1))fail("bounded source discovery domain");
 int32_t d[9]={*a,*b,*start,*end,*l,*f0,*f1,*qm,1};
 size_t cells=(size_t)*b**l,source=(size_t)*a*(size_t)((int64_t)*f1-*f0+1),sizes[6]={24*cells,32*cells,48*cells,16*cells,8*source,8*cells},off[6],total=0;
 const void*arrays[6]={cla,dlo,clo,klo,q,out};
 for(int k=0;k<6;k++){off[k]=total;total+=sizes[k];}
 for(int k=0;k<5;k++){uintptr_t p=(uintptr_t)arrays[k],o=(uintptr_t)out;if(p+sizes[k]<p||o+sizes[5]<o||(p<o+sizes[5]&&o<p+sizes[k]))fail("input/output overlap");}
 unsigned char*snapshot=alloc(total),h[192]={0};for(int k=0;k<6;k++)if(sizes[k])memcpy(snapshot+off[k],arrays[k],sizes[k]);
 memcpy(h,"LAIDFC01",8);visits++;memcpy(h+8,&visits,8);memcpy(h+16,d,36);
 uint64_t extent[5]={cells,source,sizes[5],total,(uintptr_t)pc-(uintptr_t)image};memcpy(h+64,extent,40);
 write_all(input,h,192);for(int k=0;k<6;k++)write_all(input,arrays[k],sizes[k]);inputbytes+=192+total;
 double*expected=alloc(sizes[5]);memcpy(expected,out,sizes[5]);
#ifdef LAIDDI_SOURCE_ONLY
 original(a,b,start,end,l,f0,f1,qm,cla,dlo,clo,klo,q,out);memcpy(expected,out,sizes[5]);
#else
 original(a,b,start,end,l,f0,f1,qm,cla,dlo,clo,klo,q,expected);same(snapshot+off[5],out,sizes[5],"original shadow preserves real output");
 laiddi_assembly_(a,b,start,end,l,f0,f1,qm,cla,dlo,clo,klo,q,out);same(expected,out,sizes[5],"whole returned field");
 write_all(native,h,192);write_all(native,out,sizes[5]);
#endif
 int32_t after[9]={*a,*b,*start,*end,*l,*f0,*f1,*qm,1};same(d,after,36,"all scalar arguments");
 for(int k=0;k<5;k++)same(snapshot+off[k],arrays[k],sizes[k],"whole input array");
 for(int lev=0;lev<*l;lev++)for(int row=0;row<*b;row++)if(row<*start-1||row>=*end){size_t p=(size_t)lev**b+row;same(snapshot+off[5]+p*8,out+p,8,"inactive returned cell");}
 if(fpcr())fail("return FPCR");
 physics(*b,*start,*end,*l,*qm,cla,dlo,clo,klo,q,out,source);
 write_all(reference,h,192);write_all(reference,expected,sizes[5]);bytes+=192+sizes[5];flag_calls[*qm]++;if(*end-*start+1<*b)partial_calls++;
 free(snapshot);free(expected);
}
__attribute__((destructor))static void finish(void)
{
 if(!input)return;
 fclose(input);fclose(reference);if(native)fclose(native);if(rejected)return;
 FILE*f=fopen("laiddi-summary.json","w");if(!f)fail("summary");
 fprintf(f,"{\"calls\":%"PRIu64",\"active_values\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"input_bytes\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0,\"independent_precision_bits\":%d,\"independent_limiter_operations\":%"PRIu64",\"limited_bound_values\":%"PRIu64",\"maximum_fraction_forward_limit\":%.17g,\"partial_calls\":%"PRIu64",\"flag_calls\":[%"PRIu64",%"PRIu64"]}\n",visits,values,bytes,inputbytes,LDBL_MANT_DIG,limited,bounded,worst,partial_calls,flag_calls[0],flag_calls[1]);
 fclose(f);fprintf(stderr,"LAIDDI FORECAST PASS calls=%"PRIu64" values=%"PRIu64" bytes=%"PRIu64" input_bytes=%"PRIu64" FPCR=0\n",visits,values,bytes,inputbytes);
}

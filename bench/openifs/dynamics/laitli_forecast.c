/* Capture complete interpolation arrays and check original or native physics.
 * Binary64 fields keep their caller-defined unit. Fractions have no unit,
 * indices use signed 32-bit values and rows are stored fastest. The thirteen
 * ordinary pointers and complete capacities follow the solver contract.
 * Only selected output cells change, and every inactive incoming bit remains.
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
_Static_assert(sizeof(double)==8&&sizeof(int32_t)==4,"frozen source scalar widths");
_Static_assert(LDBL_MANT_DIG>=113,"independent reference uses at least 113 bits");
typedef void(*fn)(const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const int32_t*,const double*,const double*,double*);
#ifndef LAITLI_SOURCE_ONLY
extern void laitli_assembly_(const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const int32_t*,const double*,const double*,double*);
#endif
static fn original;static void*image;static FILE*input,*reference,*native;
static uint64_t visits,values,convex,bytes,inputbytes,caller_calls[4],tail_calls;static int rejected;static double worst;
static double weight_min[4]={DBL_MAX,DBL_MAX,DBL_MAX,DBL_MAX},weight_max[4]={-DBL_MAX,-DBL_MAX,-DBL_MAX,-DBL_MAX};
static uint64_t fpcr(void){uint64_t x;__asm__ volatile("mrs %0,fpcr":"=r"(x));return x;}
__attribute__((noreturn))static void fail(const char*s){rejected=1;fprintf(stderr,"LAITLI forecast FAIL visit=%"PRIu64" %s\n",visits,s);exit(2);}
static void *alloc(size_t n){if(n>PTRDIFF_MAX)fail("byte extent");void*p=malloc(n?n:1);if(!p)fail("allocate");return p;}
static void same(const void*a,const void*b,size_t n,const char*s)
{
 if(!memcmp(a,b,n))return;
 const unsigned char*x=a,*y=b;size_t k=0;while(k<n&&x[k]==y[k])k++;size_t start=k/8*8,m=n-start<8?n-start:8;uint64_t e=0,v=0;
 memcpy(&e,x+start,m);memcpy(&v,y+start,m);
 fprintf(stderr,"stage=%s first_byte=%zu physical_word=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",s,k,k/8,e,v);fail("complete bytes differ");
}
static void write_all(FILE*f,const void*p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("capture write");}
static void init(void)
{
 original=(fn)dlsym(RTLD_NEXT,"laitli_");Dl_info bind;if(!original||!dladdr((void*)original,&bind))fail("source binding");image=bind.dli_fbase;
 input=fopen("laitli-inputs.bin","wb");reference=fopen("laitli-fortran.bin","wb");if(!input||!reference)fail("source files");
 setvbuf(input,NULL,_IOFBF,1048576);setvbuf(reference,NULL,_IOFBF,1048576);
#ifndef LAITLI_SOURCE_ONLY
 native=fopen("laitli-assembly.bin","wb");if(!native)fail("native file");setvbuf(native,NULL,_IOFBF,1048576);
#endif
}
static void physics(int32_t a,int32_t b,int32_t start,int32_t end,int32_t l,const double*lat,const double*lo,const int32_t*klo,const double*ver,const double*q,const double*out,size_t source)
{
 size_t cells=(size_t)b*l;
 for(int lev=0;lev<l;lev++)for(int row=start-1;row<end;row++){
  size_t pos=(size_t)lev*b+row;double weights[4]={lat[pos],lo[pos],lo[pos+cells],ver[pos]};
  for(int k=0;k<4;k++){if(!isfinite(weights[k]))fail("finite selected weight");if(weights[k]<weight_min[k])weight_min[k]=weights[k];if(weights[k]>weight_max[k])weight_max[k]=weights[k];}
  long double t=weights[0],x[2]={weights[1],weights[2]},z=weights[3],exact=0,magnitude=0,minimum=LDBL_MAX,maximum=-LDBL_MAX;
  for(int height=0;height<2;height++)for(int side=0;side<2;side++)for(int east=0;east<2;east++){
   int64_t index=(int64_t)klo[pos+side*cells]+(int64_t)(height+1)*a+east;
   if(index<0||(uint64_t)index>=source||!isfinite(q[index]))fail("selected source sample");
   long double v=q[index],w=(height?z:1-z)*(side?t:1-t)*(east?x[side]:1-x[side]);
   exact+=w*v;if(fabsl(v)>magnitude)magnitude=fabsl(v);if(v<minimum)minimum=v;if(v>maximum)maximum=v;
  }
  long double gain=(1+2*fabsl(t))*(1+2*fabsl(z))*(1+2*fmaxl(fabsl(x[0]),fabsl(x[1])));
  long double bound=128*DBL_EPSILON*fmaxl(magnitude,DBL_MIN)*gain+64*(long double)DBL_TRUE_MIN*gain;
  long double error=fabsl((long double)out[pos]-exact);
  if(!isfinite(out[pos])||!isfinite(bound)||error>bound){fprintf(stderr,"level=%d row=%d value=%.17g error=%.6Lg limit=%.6Lg\n",lev+1,row+1,out[pos],error,bound);fail("independent expanded eight-corner sum");}
  double fraction=(double)(error/bound);if(fraction>worst)worst=fraction;values++;
  int in_cell=1;for(int k=0;k<4;k++)if(weights[k]<0||weights[k]>1)in_cell=0;
  if(in_cell){if(out[pos]<minimum-bound||out[pos]>maximum+bound)fail("convex neighbouring-value bounds");convex++;}
 }
}
void laitli_(const int32_t*a,const int32_t*b,const int32_t*start,const int32_t*end,const int32_t*l,const int32_t*f0,const int32_t*f1,const double*lat,const double*lo,const int32_t*klo,const double*ver,const double*q,double*out)
{
 if(!original)init();
 if(fpcr()||omp_get_max_threads()!=1)fail("FPCR/thread domain");
 for(int k=0;k<=omp_get_level();k++)if(omp_get_team_size(k)!=1)fail("ancestor thread team");
 Dl_info caller;void*pc=__builtin_return_address(0);
 if(!dladdr(pc,&caller)||caller.dli_fbase!=image)fail("original source caller image");
 uintptr_t site=(uintptr_t)pc-(uintptr_t)image;int kind=0;
 if(caller.dli_sname&&!strcmp(caller.dli_sname,"larcina_"))kind=1;
 if(caller.dli_sname&&!strcmp(caller.dli_sname,"larcinb_"))kind=2;
 if(site==UINT64_C(0x275450))kind=3;
 if(!kind)fail("frozen actual caller");
 int32_t d[8]={*a,*b,*start,*end,*l,*f0,*f1,kind};
 if(*a!=3101||*b!=24||*start!=1||(*end!=24&&*end!=8)||*l!=19||*f0!=0||*f1!=20)fail("actual source shape");
 size_t cells=(size_t)*b**l,source=(size_t)*a*(size_t)(*f1-*f0+1);
 size_t sizes[6]={cells*8,2*cells*8,2*cells*4,cells*8,source*8,cells*8},total=0,off[6];
 const void*arrays[6]={lat,lo,klo,ver,q,out};
 for(int k=0;k<6;k++){off[k]=total;total+=sizes[k];}
 for(int k=0;k<5;k++){
  uintptr_t p=(uintptr_t)arrays[k],o=(uintptr_t)out;
  if(p+sizes[k]<p||o+sizes[5]<o||(p<o+sizes[5]&&o<p+sizes[k]))fail("complete input/output overlap");
 }
 unsigned char*snapshot=alloc(total),h[160]={0};for(int k=0;k<6;k++)if(sizes[k])memcpy(snapshot+off[k],arrays[k],sizes[k]);
 memcpy(h,"LAITFC01",8);visits++;memcpy(h+8,&visits,8);memcpy(h+16,d,32);
 uint64_t extent[5]={cells,source,sizes[5],total,site};memcpy(h+48,extent,40);memcpy(h+88,&kind,4);
 write_all(input,h,160);for(int k=0;k<6;k++)write_all(input,arrays[k],sizes[k]);inputbytes+=160+total;
 double*expected=alloc(sizes[5]);memcpy(expected,out,sizes[5]);
#ifdef LAITLI_SOURCE_ONLY
 original(a,b,start,end,l,f0,f1,lat,lo,klo,ver,q,out);memcpy(expected,out,sizes[5]);
#else
 original(a,b,start,end,l,f0,f1,lat,lo,klo,ver,q,expected);
 same(snapshot+off[5],out,sizes[5],"original shadow preserves real output");
 laitli_assembly_(a,b,start,end,l,f0,f1,lat,lo,klo,ver,q,out);
 same(expected,out,sizes[5],"whole returned field");write_all(native,h,160);write_all(native,out,sizes[5]);
#endif
 int32_t after[8]={*a,*b,*start,*end,*l,*f0,*f1,kind};same(d,after,32,"scalar arguments");
 for(int k=0;k<5;k++)same(snapshot+off[k],arrays[k],sizes[k],"whole input array");
 for(int lev=0;lev<*l;lev++)for(int row=*end;row<*b;row++){size_t pos=(size_t)lev**b+row;same(snapshot+off[5]+pos*8,out+pos,8,"inactive returned cell");}
 if(fpcr())fail("return FPCR");
 physics(*a,*b,*start,*end,*l,lat,lo,klo,ver,q,out,source);
 write_all(reference,h,160);write_all(reference,expected,sizes[5]);bytes+=160+sizes[5];caller_calls[kind]++;if(*end==8)tail_calls++;
 free(snapshot);free(expected);
}
__attribute__((destructor))static void finish(void)
{
 if(!input)return;
 fclose(input);fclose(reference);if(native)fclose(native);if(rejected)return;
 FILE*f=fopen("laitli-summary.json","w");if(!f)fail("summary");
 fprintf(f,"{\"calls\":%"PRIu64",\"active_values\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"input_bytes\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0,\"independent_precision_bits\":%d,\"convex_values\":%"PRIu64",\"maximum_fraction_forward_limit\":%.17g,\"partial_calls\":%"PRIu64",\"caller_calls\":[%"PRIu64",%"PRIu64",%"PRIu64"],\"weight_ranges\":[",visits,values,bytes,inputbytes,LDBL_MANT_DIG,convex,worst,tail_calls,caller_calls[1],caller_calls[2],caller_calls[3]);
 for(int k=0;k<4;k++)fprintf(f,"%s[%.17g,%.17g]",k?",":"",weight_min[k],weight_max[k]);
 fprintf(f,"]}\n");fclose(f);fprintf(stderr,"LAITLI FORECAST PASS calls=%"PRIu64" values=%"PRIu64" bytes=%"PRIu64" input_bytes=%"PRIu64" FPCR=0\n",visits,values,bytes,inputbytes);
}

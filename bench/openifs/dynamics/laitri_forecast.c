/* Capture whole original and native 32-neighbour calls in the forecast.
 * Eighteen ordinary pointers retain all declared storage and optional inputs.
 * Integers and logicals have 32 bits. Row-fast field values use 64-bit
 * floating point, with caller-defined units and dimensionless coefficients.
 * Source/native pairs receive the same complete inputs and incoming output.
 * A separate expanded higher-precision reference checks all sample weights
 * and supported clips. The driver supplies no native interpolation stage.
 * Flags zero through three are supported. Guards reject the separate minus
 * one conservation branch and other unsupported flags before either body.
 * LAITRI_SOURCE_ONLY captures only the original body before direct emission.
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
_Static_assert(LDBL_MANT_DIG>=113,"independent reference precision");
typedef void(*fn)(const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const double*,const double*,const int32_t*,const double*,const double*,double*,const double*,const int32_t*);
#ifndef LAITRI_SOURCE_ONLY
extern void laitri_assembly_(const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const double*,const double*,const int32_t*,const double*,const double*,double*,const double*,const int32_t*);
#endif
static fn original;static void*image;static int32_t*layout;static FILE*input,*reference,*native;
static uint64_t visits,values,bytes,inputbytes,limited,bounded,flags[4],callers[3],partial,optional[2],layouts[2];static double worst;static int rejected;
static uint64_t fpcr(void){uint64_t x;__asm__ volatile("mrs %0,fpcr":"=r"(x));return x;}
__attribute__((noreturn))static void fail(const char*s){rejected=1;fprintf(stderr,"LAITRI forecast FAIL visit=%"PRIu64" %s\n",visits,s);exit(2);}
static void *alloc(size_t n){if(n>PTRDIFF_MAX)fail("byte extent");void*p=malloc(n?n:1);if(!p)fail("allocate");return p;}
static void same(const void*a,const void*b,size_t n,const char*s){
 if(!memcmp(a,b,n))return;
 const unsigned char*x=a,*y=b;size_t k=0;while(k<n&&x[k]==y[k])k++;size_t off=k/8*8,m=n-off<8?n-off:8;uint64_t u=0,v=0;
 memcpy(&u,x+off,m);memcpy(&v,y+off,m);fprintf(stderr,"stage=%s first_byte=%zu physical_word=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",s,k,k/8,u,v);fail("whole bytes differ");
}
static void write_all(FILE*f,const void*p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("capture write");}
static void init(void){
 original=(fn)dlsym(RTLD_NEXT,"laitri_");Dl_info bind;
 layout=dlsym(RTLD_DEFAULT,"__yommp0_MOD_lopt_rs6k");
 if(!original||!layout||!dladdr((void*)original,&bind))fail("original entry and layout binding");
 image=bind.dli_fbase;
 input=fopen("laitri-inputs.bin","wb");reference=fopen("laitri-fortran.bin","wb");if(!input||!reference)fail("source files");
 setvbuf(input,NULL,_IOFBF,1048576);setvbuf(reference,NULL,_IOFBF,1048576);
#ifndef LAITRI_SOURCE_ONLY
 native=fopen("laitri-assembly.bin","wb");if(!native)fail("native file");setvbuf(native,NULL,_IOFBF,1048576);
#endif
}
static long double expanded(const long double*c,int count,const double*w,size_t stride,long double*g){
 long double weights[4]={1,0,0,0},v=0,sum=0;
 for(int i=1;i<count;i++){weights[i]=w[(i-1)*stride];if(!isfinite(weights[i]))fail("selected coefficient");weights[0]-=weights[i];sum+=fabsl(weights[i]);}
 for(int i=0;i<count;i++)v+=weights[i]*c[i];
 *g=1+2*sum;return v;
}
static long double clip(long double v,long double a,long double b){limited++;return fmaxl(fminl(a,b),fminl(fmaxl(a,b),v));}
static void physics(int32_t a,int32_t b,int32_t start,int32_t end,int32_t l,int32_t qm,const double*lat,const double*cla,const double*dlo,const double*clo,const int32_t*klo,const double*vint,const double*q,const double*out,size_t source){
 size_t cells=(size_t)b*l;
 for(int lev=0;lev<l;lev++)for(int row=start-1;row<end;row++){
  size_t pos=(size_t)lev*b+row;long double rows[4][4]={{0}},z[4],magnitude=0,long_gain=0,lat_gain=0,central_min=LDBL_MAX,central_max=-LDBL_MAX;
  for(int vertical=0;vertical<4;vertical++)for(int side=0;side<4;side++){
   if((vertical==0||vertical==3)&&(side==0||side==3))continue;
   int count=(vertical==1||vertical==2)&&(side==1||side==2)?4:2;
   int64_t base=(int64_t)klo[pos+side*cells]+(int64_t)vertical*a-(count==4);
   long double corners[4],g;
   for(int east=0;east<count;east++){
    int64_t k=base+east;if(k<0||(uint64_t)k>=source||!isfinite(q[k]))fail("selected 32-neighbour index");
    corners[east]=q[k];if(fabsl(corners[east])>magnitude)magnitude=fabsl(corners[east]);
   }
   if(count==4){
    rows[vertical][side]=expanded(corners,4,clo+pos+(side-1)*3*cells,cells,&g);
    if(qm==1||qm==2)rows[vertical][side]=clip(rows[vertical][side],corners[1],corners[2]);
    for(int east=1;east<3;east++){if(corners[east]<central_min)central_min=corners[east];if(corners[east]>central_max)central_max=corners[east];}
   }else rows[vertical][side]=expanded(corners,2,dlo+pos+side*cells,cells,&g);
   if(g>long_gain)long_gain=g;
  }
  for(int vertical=0;vertical<4;vertical++){
   long double g;
   if(vertical==0||vertical==3)z[vertical]=expanded(&rows[vertical][1],2,lat+pos,cells,&g);
   else{
    z[vertical]=expanded(rows[vertical],4,cla+pos,cells,&g);
    if(qm==1||qm==2)z[vertical]=clip(z[vertical],rows[vertical][1],rows[vertical][2]);
   }
   if(g>lat_gain)lat_gain=g;
  }
  long double vert_gain,exact=expanded(z,4,vint+pos,cells,&vert_gain);
  if(qm>1)exact=clip(exact,z[1],z[2]);
  long double gain=long_gain*lat_gain*vert_gain;
  if(!isfinite(gain)||magnitude*gain>DBL_MAX/32)fail("finite intermediate scale bound");
  long double limit=1024*DBL_EPSILON*fmaxl(magnitude,DBL_MIN)*gain+512*(long double)DBL_TRUE_MIN*gain,error=fabsl((long double)out[pos]-exact);
  if(!isfinite(out[pos])||!isfinite(limit)||error>limit){fprintf(stderr,"level=%d row=%d flag=%d error=%.12Lg limit=%.12Lg\n",lev+1,row+1,qm,error,limit);fail("independent expanded 32-neighbour reference");}
  double fraction=(double)(error/limit);if(fraction>worst)worst=fraction;values++;
  if(qm==2){if(out[pos]<central_min||out[pos]>central_max)fail("eight-central-neighbour bounds");bounded++;}
 }
}
void laitri_(const int32_t*a,const int32_t*b,const int32_t*start,const int32_t*end,const int32_t*l,const int32_t*f0,const int32_t*f1,const int32_t*qm,const double*lat,const double*cla,const double*dlo,const double*clo,const int32_t*klo,const double*vint,const double*q,double*out,const double*detar,const int32_t*cons){
 if(!original)init();
 if(fpcr()||omp_get_max_threads()!=1)fail("FPCR/thread domain");
 for(int k=0;k<=omp_get_level();k++)if(omp_get_team_size(k)!=1)fail("ancestor thread team");
 Dl_info caller;void*pc=__builtin_return_address(0);int kind=0;
 if(!dladdr(pc,&caller)||caller.dli_fbase!=image||!caller.dli_sname)fail("original caller image");
 if(!strcmp(caller.dli_sname,"laitre_gmv_"))kind=1;
 else if(!strcmp(caller.dli_sname,"laitre_gfl_"))kind=2;
 else if(!strcmp(caller.dli_sname,"larcina_"))kind=3;
 else fail("original caller symbol");
 if(*a<0||*a>1000000||*b<0||*b>1024||*l<0||*l>256||*start<1||*start>*b+1||*end<0||*end>*b||*f1<*f0||(int64_t)*f1-*f0+1>256||*qm<0||*qm>3||(*layout!=0&&*layout!=1))fail("bounded original discovery domain");
 int32_t d[12]={*a,*b,*start,*end,*l,*f0,*f1,*qm,kind,detar!=NULL,cons!=NULL,*layout};
 size_t cells=(size_t)*b**l,source=(size_t)*a*(size_t)((int64_t)*f1-*f0+1),sizes[10]={8*cells,24*cells,32*cells,48*cells,16*cells,24*cells,8*source,8*cells,detar?8*(size_t)*l:0,cons?4:0},off[10],total=0;
 const void*arrays[10]={lat,cla,dlo,clo,klo,vint,q,out,detar,cons};
 for(int k=0;k<10;k++){off[k]=total;total+=sizes[k];}
 for(int k=0;k<10;k++)if(k!=7&&sizes[k]){uintptr_t p=(uintptr_t)arrays[k],o=(uintptr_t)out;if(p+sizes[k]<p||o+sizes[7]<o||(p<o+sizes[7]&&o<p+sizes[k]))fail("input/output overlap");}
 unsigned char*snapshot=alloc(total),h[224]={0};for(int k=0;k<10;k++)if(sizes[k])memcpy(snapshot+off[k],arrays[k],sizes[k]);
 memcpy(h,"LAITRF01",8);visits++;memcpy(h+8,&visits,8);memcpy(h+16,d,48);uint64_t ext[7]={cells,source,sizes[7],total,(uintptr_t)pc-(uintptr_t)image,sizes[8],sizes[9]};memcpy(h+64,ext,56);
 write_all(input,h,224);for(int k=0;k<10;k++)write_all(input,arrays[k],sizes[k]);inputbytes+=224+total;
 double*expected=alloc(sizes[7]);memcpy(expected,out,sizes[7]);
#ifdef LAITRI_SOURCE_ONLY
 original(a,b,start,end,l,f0,f1,qm,lat,cla,dlo,clo,klo,vint,q,out,detar,cons);memcpy(expected,out,sizes[7]);
#else
 original(a,b,start,end,l,f0,f1,qm,lat,cla,dlo,clo,klo,vint,q,expected,detar,cons);same(snapshot+off[7],out,sizes[7],"original shadow preserves real output");
 laitri_assembly_(a,b,start,end,l,f0,f1,qm,lat,cla,dlo,clo,klo,vint,q,out,detar,cons);same(expected,out,sizes[7],"whole returned field");
 write_all(native,h,224);write_all(native,out,sizes[7]);
#endif
 int32_t after[12]={*a,*b,*start,*end,*l,*f0,*f1,*qm,kind,detar!=NULL,cons!=NULL,*layout};same(d,after,48,"all scalars, optional presence and global layout");
 for(int k=0;k<10;k++)if(k!=7&&sizes[k])same(snapshot+off[k],arrays[k],sizes[k],"whole input array");
 for(int lev=0;lev<*l;lev++)for(int row=0;row<*b;row++)if(row<*start-1||row>=*end){size_t p=(size_t)lev**b+row;same(snapshot+off[7]+p*8,out+p,8,"inactive returned cell");}
 if(fpcr())fail("return FPCR");
 physics(*a,*b,*start,*end,*l,*qm,lat,cla,dlo,clo,klo,vint,q,out,source);
 write_all(reference,h,224);write_all(reference,expected,sizes[7]);bytes+=224+sizes[7];flags[*qm]++;callers[kind-1]++;layouts[*layout]++;optional[0]+=detar!=NULL;optional[1]+=cons!=NULL;if(*end-*start+1<*b)partial++;
 free(snapshot);free(expected);
}
__attribute__((destructor))static void finish(void){
 if(!input)return;
 fclose(input);fclose(reference);if(native)fclose(native);if(rejected)return;
 FILE*f=fopen("laitri-summary.json","w");if(!f)fail("summary");
 fprintf(f,"{\"calls\":%"PRIu64",\"active_values\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"input_bytes\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0,\"independent_precision_bits\":%d,\"independent_clip_operations\":%"PRIu64",\"central_bound_values\":%"PRIu64",\"maximum_fraction_forward_limit\":%.17g,\"partial_calls\":%"PRIu64",\"flag_calls\":[%"PRIu64",%"PRIu64",%"PRIu64",%"PRIu64"],\"caller_calls\":[%"PRIu64",%"PRIu64",%"PRIu64"],\"optional_present_calls\":[%"PRIu64",%"PRIu64"],\"layout_calls\":[%"PRIu64",%"PRIu64"]}\n",visits,values,bytes,inputbytes,LDBL_MANT_DIG,limited,bounded,worst,partial,flags[0],flags[1],flags[2],flags[3],callers[0],callers[1],callers[2],optional[0],optional[1],layouts[0],layouts[1]);fclose(f);
 fprintf(stderr,"LAITRI FORECAST PASS calls=%"PRIu64" values=%"PRIu64" bytes=%"PRIu64" input_bytes=%"PRIu64" FPCR=0\n",visits,values,bytes,inputbytes);
}

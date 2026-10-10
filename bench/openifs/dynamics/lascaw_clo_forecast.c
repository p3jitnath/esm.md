/* Capture complete original longitude polynomial and smoothing weights. */
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
typedef void(*fn)(const void*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const double*,const double*,const double*,double*,double*,double*);
#ifndef LASCAW_CLO_SOURCE_ONLY
extern void lascaw_clo_assembly_(const void*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const double*,const double*,const double*,double*,double*,double*);
#endif
static fn original;static void*image;static FILE*input,*reference,*native;
static uint64_t visits,values,bytes,inputbytes,moments,maskcalls[16],partial;static double worst;static int rejected;
static uint64_t fpcr(void){uint64_t x;__asm__ volatile("mrs %0,fpcr":"=r"(x));return x;}
__attribute__((noreturn))static void fail(const char*s){rejected=1;fprintf(stderr,"LASCAW_CLO forecast FAIL visit=%"PRIu64" %s\n",visits,s);exit(2);}
static void*alloc(size_t n){if(n>PTRDIFF_MAX)fail("byte extent");void*p=malloc(n?n:1);if(!p)fail("allocate");return p;}
static void same(const void*a,const void*b,size_t n,const char*s){
 if(!n||!memcmp(a,b,n))return;
 const unsigned char*x=a,*y=b;size_t k=0;while(k<n&&x[k]==y[k])k++;size_t off=k/8*8,m=n-off<8?n-off:8;uint64_t u=0,v=0;
 memcpy(&u,x+off,m);memcpy(&v,y+off,m);fprintf(stderr,"stage=%s first_byte=%zu physical_word=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",s,k,k/8,u,v);fail("whole bytes differ");
}
static void write_all(FILE*f,const void*p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("capture write");}
static double member(const void*d,size_t off){double x;memcpy(&x,(const unsigned char*)d+off,8);return x;}
static void init(void){
 original=(fn)dlsym(RTLD_NEXT,"lascaw_clo_");Dl_info bind;
 if(!original||!dladdr((void*)original,&bind))fail("original entry binding");
 image=bind.dli_fbase;
 input=fopen("lascaw_clo-inputs.bin","wb");reference=fopen("lascaw_clo-fortran.bin","wb");if(!input||!reference)fail("source files");
 setvbuf(input,NULL,_IOFBF,1048576);setvbuf(reference,NULL,_IOFBF,1048576);
#ifndef LASCAW_CLO_SOURCE_ONLY
 native=fopen("lascaw_clo-assembly.bin","wb");if(!native)fail("native file");setvbuf(native,NULL,_IOFBF,1048576);
#endif
}
static void lagrange(long double x,long double*w){
 for(int j=0;j<4;j++){w[j]=1;for(int m=0;m<4;m++)if(m!=j)w[j]*=(x-(m-1))/(j-m);}
}
static void blend(const long double*a,const long double*b,long double x,long double*r){for(int j=0;j<4;j++)r[j]=(1-x)*a[j]+x*b[j];}
static void diffusion(const long double*a,long double e,long double*r){
 const long double m[4][4]={{1,e,0,0},{0,1-2*e,e,0},{0,e,1-2*e,0},{0,0,e,1}};
 for(int j=0;j<4;j++){r[j]=0;for(int k=0;k<4;k++)r[j]+=m[j][k]*a[k];}
}
static void closevalue(long double actual,long double expected,long double limit,const char*s){
 long double error=fabsl(actual-expected);
 if(!isfinite(actual)||!isfinite(expected)||!isfinite(limit)||error>limit){fprintf(stderr,"check=%s error=%.12Lg limit=%.12Lg actual=%.20Lg expected=%.20Lg\n",s,error,limit,actual,expected);fail("independent polynomial/smoothing reference");}
 double fraction=(double)(error/limit);if(fraction>worst)worst=fraction;
}
static void domain(const void*d,int32_t l,int32_t b,int32_t start,int32_t end,const int32_t*flags,const double*minimum,const double*x,const double*xmad,const double*kappa,const double*turb){
 long double e=member(d,136),mi=(flags[0]||flags[1])?*minimum:0,ma=flags[0]?member(d,120):0,re=flags[0]?member(d,128):0;
 if(!isfinite(e)||fabsl(e)>DBL_MAX/4||!isfinite(mi)||!isfinite(ma)||!isfinite(re))fail("pre-execution finite parameter guard");
 for(int lev=0;lev<l;lev++)for(int row=start-1;row<end;row++){
  size_t p=(size_t)lev*b+row;long double a=x[p],am=xmad[p],k=flags[0]?kappa[p]:0,t=flags[3]?turb[p]:0;
  if(!isfinite(a)||!isfinite(am)||!isfinite(k)||!isfinite(t))fail("pre-execution selected finite guard");
  long double X=1+fabsl(a)+fabsl(am),K=fmaxl(fabsl(mi),fmaxl(fabsl(ma),fabsl(re)));
  long double scale=8*X*X*X*(1+2*K)*(1+3*(flags[0]?fabsl(e):0))*(1+2*fabsl(k))*(1+3*fabsl(t));
  if(!isfinite(scale)||scale>=DBL_MAX/256)fail("pre-execution finite intermediate bound");
 }
}
static void physics(const void*d,int32_t l,int32_t b,int32_t start,int32_t end,const int32_t*flags,double minimum,const double*x,const double*xmad,const double*kappa,const double*turb,const double*clo,const double*mad,const double*sld){
 size_t cells=(size_t)b*l;long double maximum=flags[0]?member(d,120):0,ref=flags[0]?member(d,128):0,epsilon=member(d,136);
 if(!flags[0]&&!flags[1])minimum=0;
 if(!isfinite(minimum)||!isfinite(maximum)||!isfinite(ref)||!isfinite(epsilon)||fabsl(epsilon)>DBL_MAX/4)fail("finite parameter domain");
 for(int lev=0;lev<l;lev++)for(int row=start-1;row<end;row++){
  size_t p=(size_t)lev*b+row;long double a=x[p],am=xmad[p],k=flags[0]?kappa[p]:0,t=flags[3]?turb[p]:0,hi[4],hm[4],lo[4]={0},wa[4],wd[4],smooth[4],ws[4],answer[3][4];
  if(!isfinite(a)||!isfinite(am)||!isfinite(k)||!isfinite(t))fail("selected finite inputs");
  long double X=1+fabsl(a)+fabsl(am),K=fmaxl(fabsl(minimum),fmaxl(fabsl(maximum),fabsl(ref)));
  long double scale=8*X*X*X*(1+2*K)*(1+3*(flags[0]?fabsl(epsilon):0))*(1+2*fabsl(k))*(1+3*fabsl(t));
  if(!isfinite(scale)||scale>=DBL_MAX/256)fail("finite intermediate scale");
  long double limit=2048*DBL_EPSILON*scale+2048*(long double)DBL_TRUE_MIN*scale;
  lagrange(a,hi);lagrange(am,hm);
  if(flags[1]){lo[0]=a*(a-1)/4;lo[1]=1-3*a/4-a*a/4;lo[2]=5*a/4-a*a/4;lo[3]=(a*a-a)/4;}
  else if(flags[2]){lo[1]=1-a;lo[2]=a;}
  if(flags[0]){
   long double min=signbit(kappa[p])?ref:minimum;
   blend(hi,lo,min,wa);blend(hi,lo,maximum,wd);diffusion(wd,epsilon,smooth);blend(wa,smooth,fabsl(k),ws);
  }else if(flags[1]){blend(hi,lo,minimum,wa);memcpy(ws,wa,sizeof ws);}
  else{memcpy(wa,hi,sizeof wa);memcpy(ws,hi,sizeof ws);}
  if(flags[3]){diffusion(wa,t,answer[0]);diffusion(ws,t,answer[2]);}
  else{memcpy(answer[0],wa,sizeof wa);memcpy(answer[2],ws,sizeof ws);}
  memcpy(answer[1],hm,sizeof hm);
  const double*out[3]={clo,mad,sld};
  for(int set=0;set<3;set++){
   long double returned[4]={1,0,0,0};
   for(int j=1;j<4;j++){returned[j]=out[set][p+(j-1)*cells];returned[0]-=returned[j];closevalue(returned[j],answer[set][j],limit,"coefficient");values++;}
   for(int degree=1;degree<=(set==1?3:1);degree++){
    long double sum=0;for(int j=0;j<4;j++){long double node=j-1,power=1;for(int z=0;z<degree;z++)power*=node;sum+=power*returned[j];}
    long double exact=1;for(int z=0;z<degree;z++)exact*=set==1?am:a;
    closevalue(sum,exact,100*limit,"polynomial moment");moments++;
   }
  }
 }
}
void lascaw_clo_(const void*d,const int32_t*l,const int32_t*b,const int32_t*start,const int32_t*end,const int32_t*flags,const double*minimum,const double*x,const double*xmad,const double*kappa,const double*turb,double*clo,double*mad,double*sld){
 if(!original)init();
 if(fpcr()||omp_get_max_threads()!=1)fail("FPCR/thread domain");
 for(int k=0;k<=omp_get_level();k++)if(omp_get_team_size(k)!=1)fail("ancestor thread team");
 uint32_t mask=0;for(int j=0;j<4;j++){if(flags[j]!=0&&flags[j]!=1)fail("canonical logical guard");mask|=(uint32_t)flags[j]<<j;}
 if(mask==1||mask==9)fail("undefined low-order weight guard");
 if(*b<0||*b>1024||*l<0||*l>256||*start<1||*start>*b+1||*end<0||*end>*b)fail("bounded original discovery domain");
 Dl_info caller;void*pc=__builtin_return_address(0);
 if(!dladdr(pc,&caller)||caller.dli_fbase!=image||!caller.dli_sname||strcmp(caller.dli_sname,"lascaw_"))fail("original caller image/symbol");
 int32_t scalar[8]={*l,*b,*start,*end,flags[0],flags[1],flags[2],flags[3]};
 size_t cells=(size_t)*b**l,sizes[9]={456,minimum?8:0,8*cells,8*cells,kappa?8*cells:0,turb?8*cells:0,24*cells,24*cells,24*cells},off[9],total=0;
 const void*arrays[9]={d,minimum,x,xmad,kappa,turb,clo,mad,sld};
 if(!d||((flags[0]||flags[1])&&!minimum)||(flags[0]&&!kappa)||(flags[3]&&!turb)||(cells&&(!x||!xmad||!clo||!mad||!sld)))fail("required source argument presence guard");
 domain(d,*l,*b,*start,*end,flags,minimum,x,xmad,kappa,turb);
 for(int j=0;j<9;j++){off[j]=total;total+=sizes[j];}
 for(int j=6;j<9;j++)for(int k=0;k<j;k++)if(sizes[j]&&sizes[k]){
  uintptr_t a=(uintptr_t)arrays[j],z=(uintptr_t)arrays[k];if(a+sizes[j]<a||z+sizes[k]<z||(a<z+sizes[k]&&z<a+sizes[j]))fail("disjoint output extents");
 }
 unsigned char*snapshot=alloc(total),h[192]={0};for(int j=0;j<9;j++)if(sizes[j])memcpy(snapshot+off[j],arrays[j],sizes[j]);
 memcpy(h,"LASCWF01",8);visits++;memcpy(h+8,&visits,8);memcpy(h+16,scalar,32);
 uint64_t ext[6]={cells,sizes[6],total,(uintptr_t)pc-(uintptr_t)image,456,mask};memcpy(h+64,ext,48);int32_t presence[3]={minimum!=NULL,kappa!=NULL,turb!=NULL};memcpy(h+112,presence,12);
 write_all(input,h,192);for(int j=0;j<9;j++)write_all(input,arrays[j],sizes[j]);inputbytes+=192+total;
 double*expected=alloc(72*cells);if(cells)for(int j=0;j<3;j++)memcpy(expected+j*3*cells,arrays[j+6],24*cells);
#ifdef LASCAW_CLO_SOURCE_ONLY
 original(d,l,b,start,end,flags,minimum,x,xmad,kappa,turb,clo,mad,sld);
 if(cells)for(int j=0;j<3;j++)memcpy(expected+j*3*cells,arrays[j+6],24*cells);
#else
 original(d,l,b,start,end,flags,minimum,x,xmad,kappa,turb,expected,expected+3*cells,expected+6*cells);
 for(int j=6;j<9;j++)same(snapshot+off[j],arrays[j],sizes[j],"source shadow preserves real output");
 lascaw_clo_assembly_(d,l,b,start,end,flags,minimum,x,xmad,kappa,turb,clo,mad,sld);
 for(int j=0;j<3;j++)same(expected+j*3*cells,arrays[j+6],24*cells,"complete returned array");
 write_all(native,h,192);for(int j=6;j<9;j++)write_all(native,arrays[j],sizes[j]);
#endif
 int32_t after[8]={*l,*b,*start,*end,flags[0],flags[1],flags[2],flags[3]};same(scalar,after,32,"all integer/logical scalars");
 for(int j=0;j<6;j++)same(snapshot+off[j],arrays[j],sizes[j],"whole input and derived storage");
 for(int set=6;set<9;set++)for(int lev=0;lev<*l;lev++)for(int row=0;row<*b;row++)if(row<*start-1||row>=*end)
  for(int plane=0;plane<3;plane++){size_t p=(size_t)lev**b+row+plane*cells;same(snapshot+off[set]+p*8,(const double*)arrays[set]+p,8,"inactive returned cell");}
 if(fpcr())fail("return FPCR");
 physics(d,*l,*b,*start,*end,flags,(flags[0]||flags[1])?*minimum:0,x,xmad,kappa,turb,clo,mad,sld);
 write_all(reference,h,192);write_all(reference,expected,72*cells);bytes+=192+72*cells;maskcalls[mask]++;if(*end-*start+1<*b)partial++;
 free(snapshot);free(expected);
}
__attribute__((destructor))static void finish(void){
 if(!input)return;
 fclose(input);fclose(reference);if(native)fclose(native);if(rejected)return;
 FILE*f=fopen("lascaw_clo-summary.json","w");if(!f)fail("summary");
 fprintf(f,"{\"calls\":%"PRIu64",\"coefficient_values\":%"PRIu64",\"polynomial_moments\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"input_bytes\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0,\"independent_precision_bits\":%d,\"maximum_fraction_forward_limit\":%.17g,\"partial_calls\":%"PRIu64",\"logical_mask_calls\":[",visits,values,moments,bytes,inputbytes,LDBL_MANT_DIG,worst,partial);
 for(int j=0;j<16;j++)fprintf(f,"%s%"PRIu64,j?",":"",maskcalls[j]);
 fprintf(f,"]}\n");fclose(f);
 fprintf(stderr,"LASCAW_CLO FORECAST PASS calls=%"PRIu64" coefficients=%"PRIu64" moments=%"PRIu64" bytes=%"PRIu64" input_bytes=%"PRIu64" FPCR=0\n",visits,values,moments,bytes,inputbytes);
}

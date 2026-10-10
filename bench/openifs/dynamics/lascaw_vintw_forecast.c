/* Compare complete original and assembly enclosing output families.
 * Preserve every original vertical-weight input and incoming output family.
 * Scalars use the original 32-bit integer/logical and binary64 formats.
 * Coordinates, interpolation weights and smoothing parameters have no unit.
 * The independent reference uses four-node Lagrange products and full matrices.
 * It supplies acceptance checks only, with no numerical stage for the solver.
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
_Static_assert(sizeof(double)==8&&sizeof(int32_t)==4,"original widths");
_Static_assert(LDBL_MANT_DIG>=113,"independent precision");
typedef void(*fn)(void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*);
extern void lascaw_vintw_assembly_(void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*);
static fn original;static void*image;static FILE*input,*source,*assembly;
static uint64_t visits,values,moments,bytes,inputbytes,interior,boundary,partial,flagcalls[64],written[5];
static double worst;static int rejected;
static uint64_t fpcr(void){uint64_t x;__asm__ volatile("mrs %0,fpcr":"=r"(x));return x;}
__attribute__((noreturn))static void fail(const char*s){rejected=1;fprintf(stderr,"LASCAW_VINTW paired FAIL visit=%"PRIu64" %s\n",visits,s);exit(2);}
static void*alloc(size_t n){if(n>PTRDIFF_MAX)fail("byte extent");void*p=malloc(n?n:1);if(!p)fail("allocate");return p;}
static void write_all(FILE*f,const void*p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("capture write");}
static void same(const void*a,const void*b,size_t n,const char*s){
 if(!n||!memcmp(a,b,n))return;
 const unsigned char*x=a,*y=b;size_t k=0;while(k<n&&x[k]==y[k])k++;uint64_t u=0,v=0;size_t z=k/8*8,m=n-z<8?n-z:8;
 memcpy(&u,x+z,m);memcpy(&v,y+z,m);fprintf(stderr,"stage=%s first_byte=%zu word=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",s,k,k/8,u,v);fail("complete bytes differ");
}
static double member(const void*d,size_t off){double x;memcpy(&x,(const char*)d+off,8);return x;}
static void init(void){
 original=(fn)dlsym(RTLD_NEXT,"lascaw_vintw_");Dl_info bind;if(!original||!dladdr((void*)original,&bind))fail("original binding");image=bind.dli_fbase;
 input=fopen("lascaw_vintw-inputs.bin","wb");source=fopen("lascaw_vintw-fortran.bin","wb");assembly=fopen("lascaw_vintw-assembly.bin","wb");if(!input||!source||!assembly)fail("capture files");
 setvbuf(input,NULL,_IOFBF,1048576);setvbuf(source,NULL,_IOFBF,1048576);setvbuf(assembly,NULL,_IOFBF,1048576);
}
struct caller_scope{int active;int32_t b,l,kwis,kweno;void*full[5];};
static _Thread_local struct caller_scope caller_scope;

struct state{int32_t z[10];void*a[19];size_t cells;};
static long double number(const void*a,size_t p){if(!a)fail("selected absent input");double x=((const double*)a)[p];if(!isfinite(x))fail("pre-execution selected finite input");return x;}
static void lagrange(long double x,const long double*n,long double*w){
 for(int j=0;j<4;j++){w[j]=1;for(int m=0;m<4;m++)if(m!=j)w[j]*=(x-n[m])/(n[j]-n[m]);}
}
static void blend(const long double*a,const long double*b,long double k,long double*r){for(int j=0;j<4;j++)r[j]=(1-k)*a[j]+k*b[j];}
static void matrix(const long double*a,const long double*m,long double*r){
 long double full[4][4]={{1,0,0,0},{0},{0},{0}};
 for(int col=0;col<3;col++){full[0][col+1]=1;for(int row=0;row<3;row++){full[row+1][col+1]=m[row+3*col];full[0][col+1]-=m[row+3*col];}}
 for(int row=0;row<4;row++){r[row]=0;for(int col=0;col<4;col++)r[row]+=full[row][col]*a[col];}
}
static void closevalue(long double a,long double e,long double lim,const char*s){
 long double error=fabsl(a-e);if(!isfinite(a)||!isfinite(e)||!isfinite(lim)||lim<=0||error>lim){fprintf(stderr,"check=%s actual=%.20Lg expected=%.20Lg error=%.12Lg bound=%.12Lg\n",s,a,e,error,lim);fail("independent physical reference");}
 double f=(double)(error/lim);if(f>worst)worst=f;
}
static long double norm(const long double*w,size_t n){long double x=0;for(size_t i=0;i<n;i++)x+=fabsl(w[i]);return x;}
static void table_matrix(const void*a,int32_t k,const long double*n,long double*m){
 long double scale=1;for(int j=0;j<9;j++){m[j]=number(a,(size_t)k*9+j);scale+=fabsl(m[j]);}
 for(int col=0;col<3;col++){long double moment=0,bound=0;for(int row=0;row<3;row++){moment+=(n[row+1]-n[0])*m[row+3*col];bound+=fabsl(n[row+1]-n[0])*fabsl(m[row+3*col]);}
  closevalue(moment,n[col+1]-n[0],128*DBL_EPSILON*(1+bound+fabsl(n[col+1]-n[0]))*scale,"table first moment");
 }
}
/* Build a reference before execution so every used-value guard acts first.
 * Undefined unused buffers stay opaque, even when their captured bits are NaNs.
 */
static long double reference(const struct state*s,size_t p,long double ans[5][4],int change[5],long double nodes[4],long double*target){
 int32_t l=s->z[1];int32_t k=((const int32_t*)s->a[2])[p];
 if(k<0||k>=l)fail("selected original index capacity");
 int in=k>=1&&k<=l-3,slhd=s->z[5],quad=s->z[6],old=s->z[7],comad=s->z[4],vf=s->z[8],heat=s->z[9];
 change[0]=change[1]=1;change[2]=in||slhd;change[3]=slhd&&heat;change[4]=vf;
 for(int set=0;set<5;set++)if(change[set]&&!s->a[14+set])fail("required output presence");
 long double hi[4],hm[4],lo[4]={0},wa[4],ws[4],wt[4],wf[4],D[9]={0},V[9]={0},low[3]={0};
 long double x=0,am=0,d=0,dm=0,t=0,mi=0,ma=0,re=0,kappa=0,kt=0,min_gap=1,cond=1,raw=1;
 if(!in){
  d=number(s->a[4],p);dm=number(s->a[5],p);
  for(int j=0;j<4;j++)nodes[j]=j;
  hi[0]=0;hi[1]=1-d;hi[2]=d;hi[3]=0;hm[0]=0;hm[1]=1-dm;hm[2]=dm;hm[3]=0;
  memcpy(ans[0],hi,sizeof hi);memcpy(ans[1],hm,sizeof hm);memcpy(ans[2],hi,sizeof hi);memcpy(ans[3],hi,sizeof hi);memcpy(ans[4],hi,sizeof hi);*target=1+d;
  long double S=1+fabsl(d)+fabsl(dm);if(S>=DBL_MAX/65536)fail("boundary finite intermediate bound");return 8192*DBL_EPSILON*S+8192*(long double)DBL_TRUE_MIN*S;
 }
 x=number(s->a[3],p);for(int j=0;j<4;j++)nodes[j]=number(s->a[9],(size_t)k+j);
 min_gap=INFINITY;
 for(int j=0;j<4;j++)for(int m=j+1;m<4;m++){long double gap=fabsl(nodes[j]-nodes[m]);if(gap==0)fail("distinct physical nodes");if(gap<min_gap)min_gap=gap;}
 lagrange(x,nodes,hi);
 long double denmax=0;
 for(int j=1;j<4;j++){
  long double denom=1;for(int m=0;m<4;m++)if(m!=j)denom*=nodes[j]-nodes[m];
  long double actual=number(s->a[10],(size_t)k*4+j),expected=1/denom;
  closevalue(actual,expected,128*DBL_EPSILON*(fabsl(actual)+fabsl(expected))+(long double)DBL_TRUE_MIN*128,"physical cubic denominator");
  if(fabsl(actual)>denmax)denmax=fabsl(actual);
 }
 if(comad){t=number(s->a[6],p);long double middle=(nodes[1]+nodes[2])/2;am=middle+t*(x-middle);lagrange(am,nodes,hm);}else{am=x;memcpy(hm,hi,sizeof hm);}
 if(quad){
  d=number(s->a[4],p);for(int j=0;j<3;j++)low[j]=number(s->a[11],(size_t)k*3+j);
  long double a=nodes[0]-nodes[1],b=nodes[0]-nodes[2],c=nodes[1]-nodes[2],dd=nodes[1]-nodes[3],e=nodes[2]-nodes[3],den=a*b+dd*e;
  if(den==0)fail("physical quadratic geometry");
  long double correct[3]={(b-e)*c/den,(dd-a)*c/den,-c*c/den};
  for(int j=0;j<3;j++)closevalue(low[j],correct[j],256*DBL_EPSILON*(1+fabsl(low[j])+fabsl(correct[j])),"physical quadratic table");
  long double q=d*(1-d);lo[1]=(1-d)+q*low[0];lo[2]=d+q*low[1];lo[3]=q*low[2];lo[0]=1-lo[1]-lo[2]-lo[3];
 }else if(old){d=number(s->a[4],p);lo[1]=1-d;lo[2]=d;lo[0]=lo[3]=0;}
 if(slhd||quad)mi=number(s->a[1],0);
 if(slhd){
  ma=member(s->a[0],120);re=member(s->a[0],128);if(!isfinite(ma)||!isfinite(re))fail("used derived finite members");
  kappa=number(s->a[7],p);if(heat)kt=number(s->a[8],p);
  table_matrix(s->a[12],k,nodes,D);long double wd[4],smooth[4];
  blend(hi,lo,signbit(((const double*)s->a[7])[p])?re:mi,wa);blend(hi,lo,ma,wd);matrix(wd,D,smooth);blend(wa,smooth,fabsl(kappa),ws);if(heat)blend(wa,smooth,fabsl(kt),wt);
 }else if(quad){blend(hi,lo,mi,wa);memcpy(ws,wa,sizeof wa);}else{memcpy(wa,hi,sizeof wa);memcpy(ws,hi,sizeof hi);}
 if(vf){table_matrix(s->a[13],k,nodes,V);matrix(wa,V,wf);}
 memcpy(ans[0],wa,sizeof wa);memcpy(ans[1],hm,sizeof hm);memcpy(ans[2],ws,sizeof ws);if(heat&&slhd)memcpy(ans[3],wt,sizeof wt);if(vf)memcpy(ans[4],wf,sizeof wf);
 long double K=fmaxl(fabsl(mi),fmaxl(fabsl(ma),fabsl(re))),M=1+norm(D,9),F=1+norm(V,9),R=1+fabsl(x)+norm(nodes,4)+fabsl(d)+fabsl(t);
 raw=R*R*R*(1+denmax)*(1+fabsl(t))*(1+fabsl(t))*(1+fabsl(t))*(1+fabsl(d))*(1+fabsl(d))*(1+norm(low,3))*(1+2*K)*M*F*(1+2*fabsl(kappa)+2*fabsl(kt));
 if(!isfinite(raw)||raw>=DBL_MAX/65536)fail("pre-execution finite intermediate scale");
 cond=1+(fabsl(x)+norm(nodes,4))/min_gap;
 long double S=(1+norm(hi,4)+norm(hm,4)+norm(lo,4))*cond*(1+fabsl(t))*(1+fabsl(t))*(1+fabsl(t))*(1+2*K)*M*F*(1+2*fabsl(kappa)+2*fabsl(kt));
 if(!isfinite(S)||S>=DBL_MAX/65536)fail("reference forward scale");
 *target=am;return 8192*DBL_EPSILON*S+8192*(long double)DBL_TRUE_MIN*S;
}
static void science(const struct state*s,int after){
 for(int lev=0;lev<s->z[1];lev++)for(int row=s->z[2]-1;row<s->z[3];row++){
  size_t p=(size_t)lev*s->z[0]+row;long double ans[5][4],nodes[4],target;int changed[5];
  long double limit=reference(s,p,ans,changed,nodes,&target);if(!after)continue;
  int32_t k=((const int32_t*)s->a[2])[p];int in=k>=1&&k<=s->z[1]-3;if(in)interior++;else boundary++;
  for(int set=0;set<5;set++)if(changed[set]){
   long double got[4]={1,0,0,0};for(int j=1;j<4;j++){got[j]=((const double*)s->a[14+set])[p+(j-1)*s->cells];got[0]-=got[j];closevalue(got[j],ans[set][j],limit,"coefficient");values++;written[set]++;}
   int degree=set==1&&in?3:1;
   for(int n=1;n<=degree;n++){
    long double sum=0,truth=0,scale=1;for(int j=0;j<4;j++){long double pow=1;for(int m=0;m<n;m++)pow*=nodes[j];sum+=got[j]*pow;truth+=ans[set][j]*pow;scale+=fabsl(pow);}
    closevalue(sum,truth,limit*scale,"polynomial/matrix moment");moments++;
    if(set==1&&in){long double exact=1;for(int m=0;m<n;m++)exact*=target;closevalue(sum,exact,limit*scale,"cubic correction moment");}
   }
  }
 }
}
void lascaw_vintw_(void*d,void*b,void*l,void*start,void*end,void*comad,void*flags,void*filter,void*heat,void*minimum,void*index,void*p,void*distance,void*distance_mad,void*std,void*kappa,void*kappa_heat,void*eta,void*cubic,void*lower,void*diffusion,void*vertical_filter,void*w,void*mad,void*sld,void*slt,void*vf){
 if(!original)init();
 if(fpcr()||omp_get_max_threads()!=1)fail("FPCR/thread domain");
 for(int k=0;k<=omp_get_level();k++)if(omp_get_team_size(k)!=1)fail("ancestor thread team");
 if(!b||!l||!start||!end||!comad||!flags||!filter||!heat)fail("scalar presence");
 int32_t*fl=flags;struct state s={.z={*(int32_t*)b,*(int32_t*)l,*(int32_t*)start,*(int32_t*)end,*(int32_t*)comad,fl[0],fl[1],fl[2],*(int32_t*)filter,*(int32_t*)heat},.a={d,minimum,index,p,distance,distance_mad,std,kappa,kappa_heat,eta,cubic,lower,diffusion,vertical_filter,w,mad,sld,slt,vf}};
 uint32_t mask=0;for(int j=4;j<10;j++){if(s.z[j]!=0&&s.z[j]!=1)fail("pre-execution canonical logical guard");mask|=(uint32_t)s.z[j]<<(j-4);}
 if(fl[0]&&!fl[1]&&!fl[2])fail("pre-execution undefined lower weights guard");
 if(s.z[0]<0||s.z[0]>1024||s.z[1]<0||s.z[1]>256||s.z[2]<1||s.z[2]>s.z[0]+1||s.z[3]<0||s.z[3]>s.z[0])fail("bounded shape guard");
 s.cells=(size_t)s.z[0]*s.z[1];if(!d||(s.cells&&!index))fail("whole derived/index presence");
 Dl_info caller;void*pc=__builtin_return_address(0);if(!dladdr(pc,&caller)||caller.dli_fbase!=image||!caller.dli_sname||strcmp(caller.dli_sname,"lascaw_"))fail("original caller identity");
 if(!caller_scope.active||caller_scope.b!=s.z[0]||caller_scope.l!=s.z[1]||(caller_scope.kweno!=1&&caller_scope.kweno!=3))fail("complete parent scope and KWENO capacity");
 void*storage[19];memcpy(storage,s.a,sizeof storage);uint64_t windows[5]={0};
 for(int j=0;j<5;j++){
  storage[j+14]=caller_scope.full[j];
  size_t capacity=24*s.cells*((j==0||j==4)?(size_t)caller_scope.kweno:1);
  if((!storage[j+14])!=(!s.a[j+14]))fail("parent/view presence agreement");
  if(storage[j+14]&&capacity){
   uintptr_t base=(uintptr_t)storage[j+14],view=(uintptr_t)s.a[j+14];
   if(view<base||view-base>capacity||24*s.cells>capacity-(view-base)||(view-base)%(24*s.cells))fail("exact whole coefficient window");
   windows[j]=view-base;
  }
 }
 size_t ext[19]={456,8,4*s.cells,8*s.cells,8*s.cells,8*s.cells,8*s.cells,8*s.cells,8*s.cells,8*((size_t)s.z[1]+2),32*(size_t)s.z[1],24*(size_t)s.z[1],72*(size_t)s.z[1],72*(size_t)s.z[1],24*s.cells,24*s.cells,24*s.cells,24*s.cells,24*s.cells},off[19],total=0;int32_t presence[19];
 for(int j=0;j<19;j++){if(j==14||j==18)ext[j]*=(size_t)caller_scope.kweno;presence[j]=storage[j]!=NULL;if(!presence[j])ext[j]=0;off[j]=total;total+=ext[j];if(ext[j]&&((uintptr_t)storage[j]%(j==2?4:8)))fail("argument alignment");}
 for(int j=14;j<19;j++)for(int k=0;k<j;k++)if(ext[j]&&ext[k]){uintptr_t a=(uintptr_t)storage[j],b0=(uintptr_t)storage[k];if(a+ext[j]<a||b0+ext[k]<b0||(a<b0+ext[k]&&b0<a+ext[j]))fail("disjoint full output capacities");}
 science(&s,0);
 unsigned char*snap=alloc(total),h[384]={0};for(int j=0;j<19;j++)if(ext[j])memcpy(snap+off[j],storage[j],ext[j]);
 memcpy(h,"LVWF01\0\0",8);visits++;memcpy(h+8,&visits,8);memcpy(h+16,s.z,40);memcpy(h+56,&caller_scope.kwis,4);memcpy(h+60,&caller_scope.kweno,4);memcpy(h+344,windows,40);uint64_t meta[6]={s.cells,24*s.cells,total,(uintptr_t)pc-(uintptr_t)image,456,mask};memcpy(h+64,meta,48);memcpy(h+112,presence,76);for(int j=0;j<19;j++){uint64_t e=ext[j];memcpy(h+192+8*j,&e,8);}
 write_all(input,h,384);for(int j=0;j<19;j++)write_all(input,storage[j],ext[j]);inputbytes+=384+total;
 void*shadow[5];void*view[5];
 for(int j=0;j<5;j++){shadow[j]=alloc(ext[j+14]);if(ext[j+14])memcpy(shadow[j],storage[j+14],ext[j+14]);view[j]=presence[j+14]?(char*)shadow[j]+windows[j]:NULL;}
 original(d,b,l,start,end,comad,flags,filter,heat,minimum,index,p,distance,distance_mad,std,kappa,kappa_heat,eta,cubic,lower,diffusion,vertical_filter,view[0],view[1],view[2],view[3],view[4]);
 if(fpcr())fail("source returned FPCR");
 int32_t source_scalars[10]={*(int32_t*)b,*(int32_t*)l,*(int32_t*)start,*(int32_t*)end,*(int32_t*)comad,fl[0],fl[1],fl[2],*(int32_t*)filter,*(int32_t*)heat};
 same(s.z,source_scalars,40,"all source scalars before native");
 for(int j=0;j<14;j++)same(snap+off[j],storage[j],ext[j],"complete source read-only input");
 for(int j=0;j<5;j++)same(snap+off[j+14],storage[j+14],ext[j+14],"whole native incoming output survives source");
 struct state source_state=s;for(int j=0;j<5;j++)source_state.a[j+14]=view[j];science(&source_state,1);
 lascaw_vintw_assembly_(d,b,l,start,end,comad,flags,filter,heat,minimum,index,p,distance,distance_mad,std,kappa,kappa_heat,eta,cubic,lower,diffusion,vertical_filter,w,mad,sld,slt,vf);
 for(int j=0;j<5;j++)same(shadow[j],storage[j+14],ext[j+14],"whole source and native enclosing family");
 if(fpcr())fail("returned FPCR");
 int32_t after[10]={*(int32_t*)b,*(int32_t*)l,*(int32_t*)start,*(int32_t*)end,*(int32_t*)comad,fl[0],fl[1],fl[2],*(int32_t*)filter,*(int32_t*)heat};same(s.z,after,40,"all source scalars");
 for(int j=0;j<14;j++)same(snap+off[j],storage[j],ext[j],"complete read-only input/derived/table");
 for(int j=0;j<5;j++)if(ext[j+14])for(size_t absolute=0;absolute<ext[j+14]/8;absolute++){
  int writes=0;size_t view_first=(size_t)windows[j]/8;
  if(absolute>=view_first&&absolute-view_first<3*s.cells){
   size_t pos=(absolute-view_first)%s.cells,row=pos%(size_t)s.z[0];
   int selected=row>=(size_t)(s.z[2]-1)&&row<(size_t)s.z[3];
   if(selected){
    int k=((const int32_t*)index)[pos],in=k>=1&&k<=s.z[1]-3;
    int changes[5]={1,1,in||fl[0],fl[0]&&s.z[9],s.z[8]};writes=changes[j];
   }
  }
  if(!writes)same(snap+off[j+14]+absolute*8,(char*)storage[j+14]+absolute*8,8,"every untouched enclosing-family byte");
 }
 science(&s,1);write_all(source,h,384);write_all(assembly,h,384);for(int j=14;j<19;j++){write_all(source,shadow[j-14],ext[j]);write_all(assembly,storage[j],ext[j]);bytes+=ext[j];free(shadow[j-14]);}bytes+=384;
 flagcalls[mask]++;if(s.z[3]-s.z[2]+1<s.z[0])partial++;free(snap);
}
__attribute__((destructor))static void finish(void){
 if(!input)return;
 fclose(input);fclose(source);fclose(assembly);if(rejected)return;FILE*f=fopen("lascaw_vintw-summary.json","w");if(!f)fail("summary");
 fprintf(f,"{\"calls\":%"PRIu64",\"coefficient_values\":%"PRIu64",\"polynomial_moments\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"input_bytes\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0,\"independent_precision_bits\":%d,\"maximum_fraction_forward_limit\":%.17g,\"partial_calls\":%"PRIu64",\"interior_points\":%"PRIu64",\"boundary_points\":%"PRIu64",\"logical_mask_calls\":[",visits,values,moments,bytes,inputbytes,LDBL_MANT_DIG,worst,partial,interior,boundary);
 for(int j=0;j<64;j++)fprintf(f,"%s%"PRIu64,j?",":"",flagcalls[j]);
 fprintf(f,"],\"written_coefficients\":[");for(int j=0;j<5;j++)fprintf(f,"%s%"PRIu64,j?",":"",written[j]);
 fprintf(f,"]}\n");fclose(f);
 fprintf(stderr,"LASCAW_VINTW PAIRED PASS calls=%"PRIu64" coefficients=%"PRIu64" moments=%"PRIu64" bytes=%"PRIu64" inputs=%"PRIu64" FPCR=0\n",visits,values,moments,bytes,inputbytes);
}

/* The read-only parent relay freezes complete enclosing capacities and
 * forwards every original LASCAW argument without supplying mathematics.
 */
typedef void(*parent_fn)(void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*);
void lascaw_(void*p0,void*p1,void*p2,void*p3,void*p4,void*p5,void*p6,void*p7,void*p8,void*p9,void*p10,void*p11,void*p12,void*p13,void*p14,void*p15,void*p16,void*p17,void*p18,void*p19,void*p20,void*p21,void*p22,void*p23,void*p24,void*p25,void*p26,void*p27,void*p28,void*p29,void*p30,void*p31,void*p32,void*p33,void*p34,void*p35,void*p36,void*p37,void*p38,void*p39,void*p40,void*p41,void*p42,void*p43,void*p44,void*p45,void*p46,void*p47,void*p48,void*p49,void*p50,void*p51,void*p52,void*p53,void*p54,void*p55,void*p56,void*p57,void*p58,void*p59,void*p60,void*p61,void*p62,void*p63,void*p64,void*p65,void*p66,void*p67,void*p68,void*p69,void*p70,void*p71,void*p72,void*p73,void*p74,void*p75,void*p76,void*p77){
 static parent_fn parent_original;
 if(!parent_original){parent_original=(parent_fn)dlsym(RTLD_NEXT,"lascaw_");if(!parent_original)fail("original parent binding");}
 if(caller_scope.active)fail("nonrecursive caller scope");
 void*args[]={p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,p34,p35,p36,p37,p38,p39,p40,p41,p42,p43,p44,p45,p46,p47,p48,p49,p50,p51,p52,p53,p54,p55,p56,p57,p58,p59,p60,p61,p62,p63,p64,p65,p66,p67,p68,p69,p70,p71,p72,p73,p74,p75,p76,p77};
 caller_scope.active=1;caller_scope.b=*(int32_t*)args[4];caller_scope.l=*(int32_t*)args[8];
 caller_scope.kwis=*(int32_t*)args[11];caller_scope.kweno=*(int32_t*)args[13];
 if(caller_scope.kweno!=1&&caller_scope.kweno!=3)fail("supported parent KWENO before source forwarding");
 caller_scope.full[0]=args[70];caller_scope.full[1]=args[74];caller_scope.full[2]=args[71];caller_scope.full[3]=args[72];caller_scope.full[4]=args[73];
 parent_original(p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,p34,p35,p36,p37,p38,p39,p40,p41,p42,p43,p44,p45,p46,p47,p48,p49,p50,p51,p52,p53,p54,p55,p56,p57,p58,p59,p60,p61,p62,p63,p64,p65,p66,p67,p68,p69,p70,p71,p72,p73,p74,p75,p76,p77);caller_scope.active=0;
}

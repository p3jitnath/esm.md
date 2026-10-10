/* Capture the complete original latitude-weight helper.
 * All weights, coordinates and smoothing parameters are dimensionless.
 * Full four-weight products provide an independent acceptance reference.
 * The scope relay only observes storage and forwards original arguments.
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
typedef void(*fn)(void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*);
extern void lascaw_cla_assembly_(void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*);
static fn original;
static void*image;
static FILE*input,*source,*native;
static uint64_t visits,values,moments,bytes,inputbytes,geometry_values,flagcalls[16],partial,aliascalls;
static double worst;
static int rejected;
static uint64_t fpcr(void){uint64_t x;
__asm__ volatile("mrs %0,fpcr":"=r"(x));
return x;
}
__attribute__((noreturn))static void fail(const char*s){rejected=1;
fprintf(stderr,"LASCAW_CLA source FAIL visit=%"PRIu64" %s\n",visits,s);
exit(2);
}
static void*alloc(size_t n){if(n>PTRDIFF_MAX)fail("byte extent");
void*p=malloc(n?n:1);
if(!p)fail("allocate");
return p;
}
static void write_all(FILE*f,const void*p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("capture write");
}
static void same(const void*a,const void*b,size_t n,const char*s){
 if(!n||!memcmp(a,b,n))return;
 const unsigned char*x=a,*y=b;
 size_t k=0;
 while(k<n&&x[k]==y[k])k++;
 uint64_t u=0,v=0;
 size_t z=k/8*8,m=n-z<8?n-z:8;
 memcpy(&u,x+z,m);
 memcpy(&v,y+z,m);
 fprintf(stderr,"stage=%s first_byte=%zu word=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",s,k,k/8,u,v);
 fail("complete bytes differ");
}
static double member(const void*d,size_t off){double x;
memcpy(&x,(const char*)d+off,8);
return x;
}
static int32_t integer(const void*d,size_t off){int32_t x;
memcpy(&x,(const char*)d+off,4);
return x;
}
static void init(void){
 original=(fn)dlsym(RTLD_NEXT,"lascaw_cla_");
 Dl_info bind;
 if(!original||!dladdr((void*)original,&bind))fail("original binding");
 image=bind.dli_fbase;
 input=fopen("lascaw_cla-inputs.bin","wb");
 source=fopen("lascaw_cla-fortran.bin","wb");
 if(!input||!source)fail("capture files");
 setvbuf(input,NULL,_IOFBF,1048576);
 setvbuf(source,NULL,_IOFBF,1048576);
 native=fopen("lascaw_cla-assembly.bin","wb");
 if(!native)fail("native capture file");
 setvbuf(native,NULL,_IOFBF,1048576);
}
struct caller_scope{int active;
int32_t b,l,kd,kwis,comad;
void*full[4];
void*geometry[4];
};
static _Thread_local struct caller_scope caller_scope;
struct state{int32_t z[8],lower,upper,kd,comad;
void*a[20];
size_t cells;
int geometry;
};
static long double number(const void*a,size_t p){if(!a)fail("selected absent input");
double x=((const double*)a)[p];
if(!isfinite(x))fail("pre-execution selected finite input");
return x;
}
static long double norm(const long double*a,size_t n){long double v=0;
for(size_t j=0;j<n;j++)v+=fabsl(a[j]);
return v;
}
static void lagrange(long double x,const long double*n,long double*w){
 for(int j=0;j<4;j++){w[j]=1;
 for(int m=0;m<4;m++)if(m!=j){if(n[j]==n[m])fail("distinct latitude nodes");
 w[j]*=(x-n[m])/(n[j]-n[m]);
 }}
}
static void blend(const long double*a,const long double*b,long double t,long double*r){for(int j=0;j<4;j++)r[j]=(1-t)*a[j]+t*b[j];
}
static void matrix(const long double*a,const long double*m,long double*r){
 long double full[4][4]={{1,0,0,0},{0},{0},{0}};
 for(int col=0;col<3;col++){full[0][col+1]=1;
 for(int row=0;row<3;row++){full[row+1][col+1]=m[row+3*col];
 full[0][col+1]-=m[row+3*col];
 }}
 for(int row=0;row<4;row++){r[row]=0;
 for(int col=0;col<4;col++)r[row]+=full[row][col]*a[col];
 }
}
static void closevalue(long double a,long double e,long double lim,const char*s){
 long double error=fabsl(a-e);
 if(!isfinite(a)||!isfinite(e)||!isfinite(lim)||lim<=0||error>lim){fprintf(stderr,"check=%s actual=%.20Lg expected=%.20Lg error=%.12Lg bound=%.12Lg\n",s,a,e,error,lim);
 fail("independent reference");
 }
 double f=(double)(error/lim);
 if(f>worst)worst=f;
}
/* This reference checks supplied operators without assuming that an arbitrary
 * latitude smoothing matrix preserves the first spatial moment.
 */
static long double reference(const struct state*s,size_t p,long double ans[3][4]){
 int slhd=s->z[4],quad=s->z[5],old=s->z[6],turb=s->z[7],row=(int)(p%(size_t)s->z[0]),lev=(int)(p/(size_t)s->z[0]);
 int32_t ila=((const int32_t*)s->a[3])[p];
 int64_t slot=(int64_t)ila+1-s->lower;
 if((quad||slhd||turb)&&(slot<0||slot>(int64_t)s->upper-s->lower))fail("selected table slot bound");
 long double hi[4]={1,0,0,0},hm[4]={1,0,0,0},lo[4]={0},wa[4],wd[4],sm[4],ws[4],D[9]={0},T[9]={0},low[3]={0};
 for(int j=0;j<3;j++){hi[j+1]=number(s->a[4],(size_t)row+(size_t)s->z[0]*(3*lev+j));
 hm[j+1]=number(s->a[5],(size_t)row+(size_t)s->z[0]*(3*lev+j));
 hi[0]-=hi[j+1];
 hm[0]-=hm[j+1];
 }
 long double d=0,mi=0,ma=0,re=0,k=0,t=0;
 if(quad||old)d=number(s->a[6],p);
 if(quad){
  size_t n=(size_t)(s->upper-s->lower+1);
  for(int j=0;j<3;j++)low[j]=number(s->a[10],(size_t)slot+(size_t)j*n);
  long double q=d*(1-d);
  lo[1]=1-d+q*low[0];
  lo[2]=d+q*low[1];
  lo[3]=q*low[2];
  lo[0]=1-lo[1]-lo[2]-lo[3];
 }else if(old){lo[1]=1-d;
 lo[2]=d;
 }
 if(slhd||quad)mi=number(s->a[2],0);
 if(slhd){
  ma=member(s->a[1],120);
  re=member(s->a[1],128);
  if(!isfinite(ma)||!isfinite(re))fail("selected finite derived coefficients");
  k=number(s->a[8],p);
  for(int j=0;j<9;j++)D[j]=number(s->a[11],(size_t)slot*9+j);
  blend(hi,lo,signbit(((const double*)s->a[8])[p])?re:mi,wa);
  blend(hi,lo,ma,wd);
  matrix(wd,D,sm);
  blend(wa,sm,fabsl(k),ws);
 }else if(quad){blend(hi,lo,mi,wa);
 memcpy(ws,wa,sizeof wa);
 }else{memcpy(wa,hi,sizeof hi);
 memcpy(ws,hi,sizeof hi);
 }
 if(turb){t=number(s->a[9],p);
 for(int j=0;j<9;j++)T[j]=number(s->a[12],(size_t)slot*9+j);
 matrix(wa,T,sm);
 blend(wa,sm,2*t,ans[0]);
 matrix(ws,T,sm);
 blend(ws,sm,2*t,ans[2]);
 }
 else{memcpy(ans[0],wa,sizeof wa);
 memcpy(ans[2],ws,sizeof ws);
 }
 memcpy(ans[1],hm,sizeof hm);
 long double K=fmaxl(fabsl(mi),fmaxl(fabsl(ma),fabsl(re)));
 long double S=(1+norm(hi,4)+norm(hm,4))*(1+fabsl(d))*(1+fabsl(d))*(1+norm(low,3))*(1+2*K)*(1+norm(D,9))*(1+2*fabsl(k))*(1+norm(T,9))*(1+4*fabsl(t));
 if(!isfinite(S)||S>=DBL_MAX/4096)fail("pre-execution finite intermediate bound");
 return 4096*DBL_EPSILON*S+4096*(long double)DBL_TRUE_MIN*S;
}
static void geometry(const struct state*s,size_t p){
 int64_t ila=((const int32_t*)s->a[3])[p],first=ila-s->lower,slot=first+1,R=(int64_t)s->upper-s->lower+1;
 if(first<0||first+3>=R)fail("complete four-node parent geometry bound");
 int64_t global=ila+1+integer(s->a[0],1720);
 if(global<0||global>integer(s->a[0],1648))fail("original irregular table-row availability");
 long double nodes[4],h[4],hm[4],x=number(s->a[18],p),std=s->comad?number(s->a[19],p):1;
 for(int j=0;j<4;j++)nodes[j]=number(s->a[16],(size_t)first+j);
 lagrange(x,nodes,h);
 long double middle=(nodes[1]+nodes[2])/2,xm=s->comad?middle+std*(x-middle):x;
 lagrange(xm,nodes,hm);
 long double X=1+fabsl(x)+norm(nodes,4),gap=INFINITY;
 for(int j=0;j<4;j++)for(int m=j+1;m<4;m++){long double g=fabsl(nodes[j]-nodes[m]);
 if(g<gap)gap=g;
 }
 long double S=(1+norm(h,4)+norm(hm,4))*(1+X/gap)*(1+fabsl(std))*(1+fabsl(std))*(1+fabsl(std));
 if(!isfinite(S)||S>=DBL_MAX/65536)fail("parent cubic forward bound");
 long double lim=8192*DBL_EPSILON*S+8192*(long double)DBL_TRUE_MIN*S;
 int row=(int)(p%(size_t)s->z[0]),lev=(int)(p/(size_t)s->z[0]);
 for(int j=1;j<4;j++){
  long double den=1;
  for(int m=0;m<4;m++)if(m!=j)den*=nodes[j]-nodes[m];
  long double actual=number(s->a[17],(size_t)slot+(size_t)(j-1)*R),truth=1/den;
  closevalue(actual,truth,256*DBL_EPSILON*(fabsl(actual)+fabsl(truth))+256*(long double)DBL_TRUE_MIN,"parent cubic denominator");
  size_t index=(size_t)row+(size_t)s->z[0]*(3*lev+j-1);
  closevalue(number(s->a[4],index),h[j],lim,"parent latitude Lagrange weight");
  closevalue(number(s->a[5],index),hm[j],lim,"parent correction Lagrange weight");
  geometry_values+=3;
 }
}
static void science(const struct state*s,int after){
 for(int lev=0;lev<s->z[1];lev++)for(int row=s->z[2]-1;row<s->z[3];row++){
  size_t p=(size_t)lev*s->z[0]+row;
  long double ans[3][4],lim=reference(s,p,ans);
  if(s->geometry&&!after)geometry(s,p);
  if(!after)continue;
  for(int set=0;set<3;set++){
   long double got[4]={1,0,0,0};
   for(int j=1;j<4;j++){got[j]=((double*)s->a[13+set])[p+(j-1)*s->cells];
   got[0]-=got[j];
   closevalue(got[j],ans[set][j],lim,"complete coefficient");
   values++;
   }
   for(int degree=0;degree<4;degree++){long double actual=0,expected=0,scale=1;
   for(int j=0;j<4;j++){long double power=1;
   for(int n=0;n<degree;n++)power*=j-1;
   actual+=power*got[j];
   expected+=power*ans[set][j];
   scale+=fabsl(power);
   }closevalue(actual,expected,lim*scale,"four-weight operator moment");
   moments++;
   }
  }
 }
}
static int overlap(uintptr_t a,size_t n,uintptr_t b,size_t m){if(!n||!m)return 0;
if(a+n<a||b+m<b)fail("pointer extent overflow");
return a<b+m&&b<a+n;
}
static int contains(uintptr_t a,size_t n,uintptr_t b,size_t m){if(a+n<a||b+m<b)fail("pointer extent overflow");
return b>=a&&b-a<=n&&m<=n-(b-a);
}
struct layout{void*storage[20];
size_t ext[20],off[20],total;
int32_t map[3],alias[16];
uint64_t window[3],caps[4];
};
static void make_layout(const struct state*s,struct layout*t){
 memset(t,0,sizeof *t);
 memcpy(t->storage,s->a,sizeof t->storage);
 size_t R=(size_t)(s->upper-s->lower+1),view=24*s->cells;
 size_t e[20]={1800,456,8,4*s->cells,view,view,8*s->cells,8*s->cells,8*s->cells,8*s->cells,24*R,72*R,72*R,0,0,0,8*R,24*R,8*s->cells,8*s->cells};
 memcpy(t->ext,e,sizeof e);
 uintptr_t bases[3]={0};
 size_t n[3]={0};
 for(int j=0;j<4;j++){t->caps[j]=view*(j==3?1:(size_t)s->kd);
 if(t->caps[j]&&!caller_scope.full[j])fail("complete parent family presence");
 }
 for(int j=0;j<4;j++)for(int k=0;k<4;k++){
  uintptr_t a=(uintptr_t)caller_scope.full[j],b=(uintptr_t)caller_scope.full[k];
  size_t na=t->caps[j],nb=t->caps[k];
  int kind=0;
  if(a==b&&na==nb)kind=1;
  else if(contains(a,na,b,nb))kind=2;
  else if(contains(b,nb,a,na))kind=3;
  else if(overlap(a,na,b,nb))kind=4;
  t->alias[j*4+k]=kind;
 }
 for(int j=0;j<3;j++){
  uintptr_t v=(uintptr_t)s->a[13+j];
  int found=-1;
  for(int k=0;k<4;k++)if(contains((uintptr_t)caller_scope.full[k],(size_t)t->caps[k],v,view)&&(view==0||(v-(uintptr_t)caller_scope.full[k])%view==0)&&(found<0||t->caps[k]>t->caps[found]))found=k;
  if(found<0)fail("leaf view lacks complete enclosing parent capacity");
  bases[j]=(uintptr_t)caller_scope.full[found];
  n[j]=(size_t)t->caps[found];
 }
 for(int j=0;j<3;j++)for(int k=0;k<j;k++)if(overlap((uintptr_t)s->a[13+j],view,(uintptr_t)s->a[13+k],view))fail("distinct mutable leaf views");
 for(int pass=0;pass<3;pass++)for(int j=0;j<3;j++)for(int k=0;k<j;k++)if(n[j]&&n[k]&&overlap(bases[j],n[j],bases[k],n[k])){
  uintptr_t low=bases[j]<bases[k]?bases[j]:bases[k],high=bases[j]+n[j]>bases[k]+n[k]?bases[j]+n[j]:bases[k]+n[k];
  bases[k]=low;
  n[k]=high-low;
  n[j]=0;
 }
 for(int j=0;j<3;j++){t->storage[13+j]=n[j]?(void*)bases[j]:NULL;
 t->ext[13+j]=n[j];
 }
 for(int j=0;j<3;j++){t->map[j]=-1;
 for(int k=0;k<3;k++)if(n[k]&&contains(bases[k],n[k],(uintptr_t)s->a[13+j],view)){t->map[j]=k;
 t->window[j]=(uintptr_t)s->a[13+j]-bases[k];
 break;
 }if(view&&t->map[j]<0)fail("merged parent capacity");
 if(!view){t->map[j]=j;
 t->window[j]=0;
 }}
 for(int j=0;j<20;j++){if(!t->storage[j])t->ext[j]=0;
 if(t->ext[j]&&(uintptr_t)t->storage[j]%(j==3?4:8))fail("complete argument alignment");
 t->off[j]=t->total;
 t->total+=t->ext[j];
 }
 for(int j=13;j<16;j++)for(int k=0;k<20;k++)if(k<13||k>=16)if(overlap((uintptr_t)t->storage[j],t->ext[j],(uintptr_t)t->storage[k],t->ext[k]))fail("read-only input disjoint from mutable union");
}
static void header(unsigned char*h,const struct state*s,const struct layout*t,uint64_t call,uintptr_t pc,int32_t profile){
 memset(h,0,640);
 memcpy(h,"LACAF01",8);
 memcpy(h+8,&call,8);
 memcpy(h+16,s->z,32);
 memcpy(h+48,&s->lower,4);
 memcpy(h+52,&s->upper,4);
 memcpy(h+56,&s->kd,4);
 memcpy(h+60,&s->comad,4);
 uint64_t mask=0;
 for(int j=0;j<4;j++)mask|=(uint64_t)s->z[j+4]<<j;
 uint64_t meta[8]={s->cells,24*s->cells,t->total,pc,mask,1800,456,(uint64_t)(s->upper-s->lower+1)};
 memcpy(h+64,meta,64);
 for(int j=0;j<20;j++){int32_t present=t->storage[j]!=NULL;
 uint64_t extent=t->ext[j];
 memcpy(h+128+4*j,&present,4);
 memcpy(h+216+8*j,&extent,8);
 }
 memcpy(h+384,t->map,12);
 memcpy(h+400,t->window,24);
 memcpy(h+424,t->caps,32);
 memcpy(h+456,t->alias,64);
 memcpy(h+520,&profile,4);
 int32_t geo=s->geometry;
 memcpy(h+524,&geo,4);
 int32_t ndglg=integer(s->a[0],1648),first=integer(s->a[0],1720);
 memcpy(h+528,&ndglg,4);
 memcpy(h+532,&first,4);
}
static void untouched(const struct state*s,const struct layout*t,const unsigned char*snap){
 for(int j=13;j<16;j++)for(size_t pos=0;pos<t->ext[j]/8;pos++){
  int writes=0;
  for(int k=0;k<3;k++)if(t->map[k]==j-13){size_t first=t->window[k]/8;
  if(pos>=first&&pos-first<3*s->cells){size_t row=(pos-first)%s->cells%(size_t)s->z[0];
  if(row>=(size_t)(s->z[2]-1)&&row<(size_t)s->z[3])writes=1;
  }}
  if(!writes)same(snap+t->off[j]+8*pos,(char*)t->storage[j]+8*pos,8,"complete untouched containing allocation");
 }
}
void lascaw_cla_(void*sl,void*d,void*l,void*b,void*start,void*end,void*flags,void*minimum,void*index,void*wh,void*whmad,void*dlat,void*dlamad,void*kappa,void*turb,void*lower,void*diffusion,void*turbmatrix,void*w,void*mad,void*sld){
 if(!flags)fail("logical pointer presence");
 int32_t*fl=flags;
 uint32_t mask=0;
 for(int j=0;j<4;j++){if(fl[j]!=0&&fl[j]!=1)fail("first canonical logical guard");
 mask|=(uint32_t)fl[j]<<j;
 }if(mask==1||mask==9)fail("first undefined low-order guard");
 if(!original)init();
 if(fpcr()||omp_get_max_threads()!=1)fail("FPCR/thread domain");
 for(int k=0;k<=omp_get_level();k++)if(omp_get_team_size(k)!=1)fail("ancestor thread team");
 if(!sl||!d||!l||!b||!start||!end)fail("scalar/derived presence");
 struct state s={.z={*(int32_t*)b,*(int32_t*)l,*(int32_t*)start,*(int32_t*)end,fl[0],fl[1],fl[2],fl[3]},.a={sl,d,minimum,index,wh,whmad,dlat,dlamad,kappa,turb,lower,diffusion,turbmatrix,w,mad,sld,NULL,NULL,NULL,NULL},.geometry=1};
 if(s.z[0]<0||s.z[0]>1024||s.z[1]<0||s.z[1]>256||s.z[2]<1||s.z[2]>s.z[0]+1||s.z[3]<0||s.z[3]>s.z[0])fail("bounded shape guard");
 s.cells=(size_t)s.z[0]*s.z[1];
 s.lower=integer(sl,1672);
 s.upper=integer(sl,1676);
 if(s.upper<s.lower||(int64_t)s.upper-s.lower>=4096)fail("complete latitude table extent");
 if(s.cells&&(!index||!wh||!whmad||!w||!mad||!sld))fail("required leaf allocation");
 if((fl[0]||fl[1])&&!minimum)fail("required minimum");
 if(fl[0]&&(!kappa||!diffusion))fail("required diffusion");
 if(fl[1]&&!lower)fail("required quadratic");
 if((fl[1]||fl[2])&&!dlat)fail("required linear distance");
 if(fl[3]&&(!turb||!turbmatrix))fail("required turbulence");
 Dl_info caller;
 void*pc=__builtin_return_address(0);
 if(!dladdr(pc,&caller)||caller.dli_fbase!=image||!caller.dli_sname||strcmp(caller.dli_sname,"lascaw_"))fail("original caller image/symbol");
 if(!caller_scope.active||caller_scope.b!=s.z[0]||caller_scope.l!=s.z[1]||caller_scope.kd!=1)fail("complete parent capacity scope");
 s.kd=caller_scope.kd;
 s.comad=caller_scope.comad;
 for(int j=0;j<4;j++)s.a[16+j]=caller_scope.geometry[j];
 if((s.comad!=0&&s.comad!=1)||!s.a[16]||!s.a[17]||(s.cells&&!s.a[18])||(s.comad&&s.cells&&!s.a[19]))fail("parent scientific context");
 struct layout t;
 make_layout(&s,&t);
 science(&s,0);
 unsigned char*snap=alloc(t.total),h[640];
 for(int j=0;j<20;j++)if(t.ext[j])memcpy(snap+t.off[j],t.storage[j],t.ext[j]);
 visits++;
 header(h,&s,&t,visits,(uintptr_t)pc-(uintptr_t)image,-1);
 write_all(input,h,640);
 for(int j=0;j<20;j++)write_all(input,t.storage[j],t.ext[j]);
 inputbytes+=640+t.total;
 void*shadow[3];
 for(int j=0;j<3;j++){shadow[j]=alloc(t.ext[13+j]);
 if(t.ext[13+j])memcpy(shadow[j],t.storage[13+j],t.ext[13+j]);
 }
 struct state expected=s;
 for(int j=0;j<3;j++)expected.a[13+j]=s.a[13+j]?(char*)shadow[t.map[j]]+t.window[j]:NULL;
 original(sl,d,l,b,start,end,flags,minimum,index,wh,whmad,dlat,dlamad,kappa,turb,lower,diffusion,turbmatrix,expected.a[13],expected.a[14],expected.a[15]);
 int32_t source_after[8]={*(int32_t*)b,*(int32_t*)l,*(int32_t*)start,*(int32_t*)end,fl[0],fl[1],fl[2],fl[3]};
 same(s.z,source_after,32,"source integer/logical inputs");
 for(int j=0;j<20;j++)same(snap+t.off[j],t.storage[j],t.ext[j],"source shadow preserves every real input/output");
 if(fpcr())fail("source return FPCR");
 science(&expected,1);
 lascaw_cla_assembly_(sl,d,l,b,start,end,flags,minimum,index,wh,whmad,dlat,dlamad,kappa,turb,lower,diffusion,turbmatrix,w,mad,sld);
 for(int j=0;j<3;j++)same(shadow[j],t.storage[13+j],t.ext[13+j],"whole same-input source/native union");
 write_all(native,h,640);
 for(int j=13;j<16;j++)write_all(native,t.storage[j],t.ext[j]);
 if(fpcr())fail("returned FPCR");
 int32_t after[8]={*(int32_t*)b,*(int32_t*)l,*(int32_t*)start,*(int32_t*)end,fl[0],fl[1],fl[2],fl[3]};
 same(s.z,after,32,"all integer/logical inputs");
 for(int j=0;j<20;j++)if(j<13||j>=16)same(snap+t.off[j],t.storage[j],t.ext[j],"whole source input/derived/geometry");
 untouched(&s,&t,snap);
 science(&s,1);
 write_all(source,h,640);
 bytes+=640;
 for(int j=13;j<16;j++){write_all(source,shadow[j-13],t.ext[j]);
 bytes+=t.ext[j];
 free(shadow[j-13]);
 }
 flagcalls[mask]++;
 if(s.z[3]-s.z[2]+1<s.z[0])partial++;
 for(int j=0;j<4;j++)for(int k=0;k<j;k++)if(t.alias[j*4+k]){aliascalls++;
 j=4;
 break;
 }free(snap);
}
__attribute__((destructor))static void finish(void){
 if(!input)return;
 fclose(input);
 fclose(source);
 fclose(native);
 if(rejected)return;
 FILE*f=fopen("lascaw_cla-summary.json","w");
 if(!f)fail("summary");
 fprintf(f,"{\"calls\":%"PRIu64",\"coefficient_values\":%"PRIu64",\"operator_moments\":%"PRIu64",\"parent_geometry_values\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"input_bytes\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0,\"independent_precision_bits\":%d,\"maximum_fraction_forward_limit\":%.17g,\"partial_calls\":%"PRIu64",\"parent_alias_calls\":%"PRIu64",\"logical_mask_calls\":[",visits,values,moments,geometry_values,bytes,inputbytes,LDBL_MANT_DIG,worst,partial,aliascalls);
 for(int j=0;j<16;j++)fprintf(f,"%s%"PRIu64,j?",":"",flagcalls[j]);
 fprintf(f,"]}\n");
 fclose(f);
 fprintf(stderr,"LASCAW_CLA SOURCE PASS calls=%"PRIu64" coefficients=%"PRIu64" moments=%"PRIu64" bytes=%"PRIu64" inputs=%"PRIu64" FPCR=0\n",visits,values,moments,bytes,inputbytes);
}
/* The enclosing relay passes all original pointers. These hooks only read
 * scalar metadata and retain complete buffer bases for the leaf observer.
 */
void lascaw_cla_scope_enter(void *const *args,size_t count){
 if(!args||count!=78)fail("scope argument count");
 if(caller_scope.active)fail("nonrecursive parent scope");
 const int needed[]={4,5,8,11,20,21};
 for(size_t j=0;j<sizeof needed/sizeof needed[0];j++)if(!args[needed[j]])fail("scope scalar presence");
 caller_scope.active=1;
 caller_scope.b=*(int32_t*)args[4];
 caller_scope.l=*(int32_t*)args[8];
 caller_scope.kd=*(int32_t*)args[5];
 caller_scope.kwis=*(int32_t*)args[11];
 if(caller_scope.kd!=1)fail("forecast KDIMK one preserves complete local turbulence storage");
 int32_t all=*(int32_t*)args[20],horizontal=*(int32_t*)args[21];
 if((all!=0&&all!=1)||(horizontal!=0&&horizontal!=1))fail("parent canonical correction flags");
 int k=caller_scope.kwis;
 caller_scope.comad=all&&horizontal&&(k==103||k==104||k==105||k==203||k==106);
 caller_scope.full[0]=args[53];
 caller_scope.full[1]=args[56];
 caller_scope.full[2]=args[54];
 caller_scope.full[3]=args[55];
 caller_scope.geometry[0]=args[27];
 caller_scope.geometry[1]=args[28];
 caller_scope.geometry[2]=args[33];
 caller_scope.geometry[3]=args[49];
}
void lascaw_cla_scope_leave(void){
 if(!caller_scope.active)fail("balanced parent scope");
 caller_scope.active=0;
}

#ifndef LASCAW_CLA_EXTERNAL_SCOPE
/* This relay preserves the original 78-pointer argument order. */
typedef void(*parent_fn)(void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*,void*);
void lascaw_(void*p0,void*p1,void*p2,void*p3,void*p4,void*p5,void*p6,void*p7,void*p8,void*p9,void*p10,void*p11,void*p12,void*p13,void*p14,void*p15,void*p16,void*p17,void*p18,void*p19,void*p20,void*p21,void*p22,void*p23,void*p24,void*p25,void*p26,void*p27,void*p28,void*p29,void*p30,void*p31,void*p32,void*p33,void*p34,void*p35,void*p36,void*p37,void*p38,void*p39,void*p40,void*p41,void*p42,void*p43,void*p44,void*p45,void*p46,void*p47,void*p48,void*p49,void*p50,void*p51,void*p52,void*p53,void*p54,void*p55,void*p56,void*p57,void*p58,void*p59,void*p60,void*p61,void*p62,void*p63,void*p64,void*p65,void*p66,void*p67,void*p68,void*p69,void*p70,void*p71,void*p72,void*p73,void*p74,void*p75,void*p76,void*p77){
 static parent_fn parent_original;
 if(!parent_original){parent_original=(parent_fn)dlsym(RTLD_NEXT,"lascaw_");
 if(!parent_original)fail("original parent binding");
 }
 void*args[]={p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,p34,p35,p36,p37,p38,p39,p40,p41,p42,p43,p44,p45,p46,p47,p48,p49,p50,p51,p52,p53,p54,p55,p56,p57,p58,p59,p60,p61,p62,p63,p64,p65,p66,p67,p68,p69,p70,p71,p72,p73,p74,p75,p76,p77};
 lascaw_cla_scope_enter(args,78);
 parent_original(p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,p34,p35,p36,p37,p38,p39,p40,p41,p42,p43,p44,p45,p46,p47,p48,p49,p50,p51,p52,p53,p54,p55,p56,p57,p58,p59,p60,p61,p62,p63,p64,p65,p66,p67,p68,p69,p70,p71,p72,p73,p74,p75,p76,p77);
 lascaw_cla_scope_leave();
}

#endif

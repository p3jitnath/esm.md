/* Verify complete latitude-weight returns against frozen original bytes.
 * All allocations end beside inaccessible memory, and inputs are read-only.
 * Independent full-weight mathematics checks the physical interpolation.
 * The driver supplies no blend, smoothing, copy or interpolation stage.
 */
#define _GNU_SOURCE
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
static uint64_t visits,values,moments,geometry_values;
static double worst;
static uint64_t fpcr(void){uint64_t x;
__asm__ volatile("mrs %0,fpcr":"=r"(x));
return x;
}
__attribute__((noreturn))static void fail(const char*s){fprintf(stderr,"LASCAW_CLA verify FAIL visit=%"PRIu64" %s\n",visits,s);
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
struct layout{void*storage[20];
size_t ext[20],off[20],total;
int32_t map[3],alias[16];
uint64_t window[3],caps[4];
};
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
#include <sys/mman.h>
#include <unistd.h>
extern uint64_t vertical_abi_call(void(*)(void*),void*);
extern void lascaw_cla_abi_invoke(void*);
struct mapping{void*base;
size_t bytes;
};
static void*protected_alloc(size_t n){
 size_t page=(size_t)sysconf(_SC_PAGESIZE);
 if(n>PTRDIFF_MAX-page-32)fail("protected byte extent");
 size_t data=(n+16+page-1)/page*page,total=data+2*page;
 void*base=mmap(NULL,total,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(base==MAP_FAILED||mprotect((char*)base+page,data,PROT_READ|PROT_WRITE))fail("protected allocation");
 void*p=(char*)base+page+data-n;
 struct mapping m={base,total};
 memcpy((char*)p-16,&m,16);
 return p;
}
static void release(void*p){struct mapping m;
memcpy(&m,(char*)p-16,16);
if(munmap(m.base,m.bytes))fail("unmap");
}
static void read_only(void*p){struct mapping m;
memcpy(&m,(char*)p-16,16);
size_t page=(size_t)sysconf(_SC_PAGESIZE);
if(mprotect((char*)m.base+page,m.bytes-2*page,PROT_READ))fail("read-only input");
}
static void read_all(FILE*f,void*p,size_t n){if(n&&fread(p,1,n,f)!=n)fail("complete record read");
}
static void arguments(void**args,struct state*s){
 args[0]=s->a[0];
 args[1]=s->a[1];
 args[2]=s->z+1;
 args[3]=s->z;
 args[4]=s->z+2;
 args[5]=s->z+3;
 args[6]=s->z+4;
 for(int j=2;j<16;j++)args[j+5]=s->a[j];
}
static void execute(void**args){
 if(vertical_abi_call(lascaw_cla_abi_invoke,args))fail("whole ABI call");
 if(fpcr())fail("whole return FPCR");
}
int main(int argc,char**argv){
 int actual=argc>1&&!strcmp(argv[1],"--actual"),offset=actual?2:1;
 if(argc!=6)fail("usage INPUT SOURCE INDEPENDENT OUTPUT SUMMARY or --actual INPUT SOURCE OUTPUT SUMMARY");
 FILE*in=fopen(argv[offset],"rb"),*ref=fopen(argv[offset+1],"rb"),*truth=actual?NULL:fopen(argv[offset+2],"rb"),*out=fopen(argv[actual?offset+2:offset+3],"wb");
 if(!in||!ref||!out||(!actual&&!truth))fail("replay files");
 uint64_t calls=0,returned=0,parallel=0,guards=0,checked=0;
 if(!actual){unsigned char h[64],r0[64],t0[64];
 read_all(in,h,64);
 read_all(ref,r0,64);
 read_all(truth,t0,64);
 same(h,r0,64,"source global");
 same(h,t0,64,"independent global");
 if(memcmp(h,"LACACR01",8))fail("global encoding");
 write_all(out,h,64);
 returned=64;
 }
 if(fpcr())fail("entry FPCR");
 for(;;){
  visits=calls+1;
  unsigned char h[640],rh[640];
  size_t n=fread(h,1,640,in);
  if(!n)break;
  if(n!=640)fail("record length");
  read_all(ref,rh,640);
  same(h,rh,640,"reference header");
  if(truth){read_all(truth,rh,640);
  same(h,rh,640,"independent header");
  }
  uint64_t call;
  memcpy(&call,h+8,8);
  if(call!=calls+1||memcmp(h,actual?"LACAF01":"LACACS1",8))fail("record order/encoding");
  struct state*s=protected_alloc(sizeof *s);
  memset(s,0,sizeof *s);
  memcpy(s->z,h+16,32);
  memcpy(&s->lower,h+48,4);
  memcpy(&s->upper,h+52,4);
  memcpy(&s->kd,h+56,4);
  memcpy(&s->comad,h+60,4);
  memcpy(&s->geometry,h+524,4);
  uint32_t mask=0;
  for(int j=0;j<4;j++){if(s->z[j+4]!=0&&s->z[j+4]!=1)fail("first encoded logical guard");
  mask|=(uint32_t)s->z[j+4]<<j;
  }if(mask==1||mask==9)fail("first undefined encoded lower weights");
  int32_t b=s->z[0],l=s->z[1];
  if(b<0||b>1024||l<0||l>256||s->z[2]<1||s->z[2]>b+1||s->z[3]<0||s->z[3]>b||s->upper<s->lower||(int64_t)s->upper-s->lower>=4096||s->kd<1||s->kd>8)fail("frozen scalar capacities");
  s->cells=(size_t)b*l;
  uint64_t meta[8];
  memcpy(meta,h+64,64);
  if(meta[0]!=s->cells||meta[1]!=24*s->cells||meta[4]!=mask||meta[5]!=1800||meta[6]!=456||meta[7]!=(uint64_t)(s->upper-s->lower+1))fail("frozen widths");
  struct layout t={0};
  int32_t present[20];
  memcpy(present,h+128,80);
  uint64_t extent[20];
  memcpy(extent,h+216,160);
  memcpy(t.map,h+384,12);
  memcpy(t.window,h+400,24);
  memcpy(t.caps,h+424,32);
  memcpy(t.alias,h+456,64);
  size_t R=(size_t)(s->upper-s->lower+1),need[20]={1800,456,8,4*s->cells,24*s->cells,24*s->cells,8*s->cells,8*s->cells,8*s->cells,8*s->cells,24*R,72*R,72*R,0,0,0,8*R,24*R,8*s->cells,8*s->cells};
  unsigned char*incoming[20];
  void*gold[3],*physical[3]={0};
  for(int j=0;j<20;j++){
   if(present[j]!=0&&present[j]!=1)fail("canonical presence");
   if(j<13||j>=16){if(extent[j]!=(present[j]?need[j]:0))fail("complete read-only extent");
   }
   else if(extent[j]>24*s->cells*(size_t)s->kd*3+128)fail("bounded output union");
   if(!present[j]&&extent[j])fail("absent extent");
   t.ext[j]=(size_t)extent[j];
   t.off[j]=t.total;
   t.total+=t.ext[j];
   t.storage[j]=protected_alloc(t.ext[j]);
   read_all(in,t.storage[j],t.ext[j]);
   incoming[j]=alloc(t.ext[j]);
   if(t.ext[j])memcpy(incoming[j],t.storage[j],t.ext[j]);
   s->a[j]=present[j]?t.storage[j]:NULL;
  }
  if(t.total!=meta[2])fail("complete total storage");
  for(int j=0;j<3;j++){
   if(t.map[j]<0||t.map[j]>2||t.window[j]>t.ext[13+t.map[j]]||24*s->cells>t.ext[13+t.map[j]]-t.window[j])fail("whole mutable window capacity");
   s->a[13+j]=present[13+t.map[j]]?(char*)t.storage[13+t.map[j]]+t.window[j]:NULL;
   gold[j]=protected_alloc(t.ext[13+j]);
   read_all(ref,gold[j],t.ext[13+j]);
   if(truth){physical[j]=protected_alloc(t.ext[13+j]);
   read_all(truth,physical[j],t.ext[13+j]);
   }
  }
  if(s->geometry!=1||s->comad<0||s->comad>1)fail("frozen scientific context");
  science(s,0);
  void*args[21];
  arguments(args,s);
  for(int j=0;j<20;j++)if(j<13||j>=16)read_only(t.storage[j]);
  read_only(s);
  execute(args);
  for(int j=0;j<20;j++)if(j<13||j>=16)same(incoming[j],t.storage[j],t.ext[j],"whole read-only buffer");
  for(int j=0;j<3;j++){same(gold[j],t.storage[13+j],t.ext[13+j],"complete frozen returned union");
  }
  unsigned char*snapshot=alloc(t.total);
  for(int j=0;j<20;j++)if(t.ext[j])memcpy(snapshot+t.off[j],incoming[j],t.ext[j]);
  untouched(s,&t,snapshot);
  science(s,1);
  if(truth)for(int lev=0;lev<l;lev++)for(int row=s->z[2]-1;row<s->z[3];row++){
   size_t p=(size_t)lev*b+row;
   long double ans[3][4],lim=reference(s,p,ans);
   for(int set=0;set<3;set++)for(int j=0;j<3;j++){size_t region=(size_t)t.map[set],at=t.window[set]/8+p+(size_t)j*s->cells;
   closevalue(((double*)t.storage[13+region])[at],((double*)physical[region])[at],lim,"frozen 100-digit physical coefficient");
   checked++;
   }
  }
  int32_t profile;
  memcpy(&profile,h+520,4);
  if(!actual&&b==24&&l==19&&profile==11&&mask==15){
   #pragma omp parallel num_threads(3) reduction(+:parallel)
   {
    if(omp_get_num_threads()!=3)fail("genuine three-thread team");
    void*local[21];
    memcpy(local,args,sizeof local);
    void*fields[3];
    for(int j=0;j<3;j++){fields[j]=protected_alloc(t.ext[13+j]);
    if(t.ext[13+j])memcpy(fields[j],incoming[13+j],t.ext[13+j]);
    }
    for(int j=0;j<3;j++)local[18+j]=present[13+t.map[j]]?(char*)fields[t.map[j]]+t.window[j]:NULL;
    #pragma omp barrier
    execute(local);
    for(int j=0;j<3;j++){same(gold[j],fields[j],t.ext[13+j],"parallel complete union");
    release(fields[j]);
    }parallel++;
   }
  }
  write_all(out,h,640);
  returned+=640;
  for(int j=13;j<16;j++){write_all(out,t.storage[j],t.ext[j]);
  returned+=t.ext[j];
  }
  free(snapshot);
  for(int j=0;j<20;j++){free(incoming[j]);
  release(t.storage[j]);
  }for(int j=0;j<3;j++){release(gold[j]);
  if(physical[j])release(physical[j]);
  }release(s);
  calls++;
 }
 if(!actual)for(int probe=0;probe<10;probe++){int32_t fl[4]={0};
 if(probe==0)fl[0]=1;
 else if(probe==1){fl[0]=1;
 fl[3]=1;
 }else fl[(probe-2)/2]=(probe&1)?-1:2;
 void*args[21]={0};
 args[6]=fl;
 execute(args);
 guards++;
 }
 if(fgetc(ref)!=EOF||(truth&&fgetc(truth)!=EOF))fail("trailing reference");
 if((actual&&calls!=2150)||(!actual&&calls!=1512))fail("complete call count");
 fclose(in);
 fclose(ref);
 fclose(out);
 if(truth)fclose(truth);
 FILE*f=fopen(argv[5],"w");
 if(!f)fail("summary");
 fprintf(f,"{\"actual_replay\":%s,\"cases\":%"PRIu64",\"whole_calls\":%"PRIu64",\"protected_allocation_cases\":%"PRIu64",\"genuine_three_thread_calls\":%"PRIu64",\"unsupported_first_guard_calls\":%"PRIu64",\"independent_coefficients\":%"PRIu64",\"operator_coefficients\":%"PRIu64",\"operator_moments\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0}\n",actual?"true":"false",calls,calls+parallel+guards,calls,parallel,guards,checked,values,moments,returned);
 fclose(f);
 printf("LASCAW_CLA REPLAY PASS cases=%"PRIu64" whole_calls=%"PRIu64" bytes=%"PRIu64" FPCR=0\n",calls,calls+parallel+guards,returned);
 return 0;
}

/* Verify the complete matrix solve, input mutation and ordinary-pointer ABI.
 * Modal divergence fields have units s^-1; the supplied matrix has no unit.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <omp.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <unistd.h>
typedef void (*solve_fn)(const int32_t*,const int32_t*,const int32_t*,const int32_t*,
 const double*,const double*,const double*,const double*,const double*,const double*,
 const double*,double*,double*);
#define DECLARE(name) extern void name(const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const double*,const double*,const double*,const double*,const double*,double*,double*)
DECLARE(simplico_);DECLARE(simplico_assembly_);
DECLARE(simplico_stage_reference_);DECLARE(simplico_stage_assembly_);
extern uint64_t vertical_abi_call(void (*)(void*),void*);
struct invocation {solve_fn fn;const int32_t *m,*n,*l,*s;const double *a,*d,*p,*q,*v,*lap,*b2;double *y,*x;};
#define ASSERT_OFFSET(member,byte) _Static_assert(offsetof(struct invocation,member)==byte,"ordinary-argument bridge")
ASSERT_OFFSET(fn,0);ASSERT_OFFSET(m,8);ASSERT_OFFSET(n,16);ASSERT_OFFSET(l,24);ASSERT_OFFSET(s,32);
ASSERT_OFFSET(a,40);ASSERT_OFFSET(d,48);ASSERT_OFFSET(p,56);ASSERT_OFFSET(q,64);
ASSERT_OFFSET(v,72);ASSERT_OFFSET(lap,80);ASSERT_OFFSET(b2,88);ASSERT_OFFSET(y,96);ASSERT_OFFSET(x,104);
_Static_assert(sizeof(struct invocation)==112,"bridge capacity");
extern void simplico_abi_invoke(void*);
__asm__(".text\n.p2align 2\n.global simplico_abi_invoke\n.type simplico_abi_invoke,%function\n"
"simplico_abi_invoke:\nsub sp,sp,#64\nstr x30,[sp,#48]\nmov x9,x0\nldr x10,[x9]\n"
"ldp x11,x12,[x9,#72]\nstp x11,x12,[sp]\nldp x11,x12,[x9,#88]\nstp x11,x12,[sp,#16]\n"
"ldr x11,[x9,#104]\nstr x11,[sp,#32]\nldp x0,x1,[x9,#8]\nldp x2,x3,[x9,#24]\n"
"ldp x4,x5,[x9,#40]\nldp x6,x7,[x9,#56]\nblr x10\nldr x30,[sp,#48]\nadd sp,sp,#64\nret\n"
".size simplico_abi_invoke,.-simplico_abi_invoke\n");
struct region {unsigned char *map,*data;size_t total,access,bytes;};
struct problem {
 const unsigned char *header;int32_t id,n,m,l,s,profile;size_t count,waves,rotation,lap_count,matrix_words;
 double b2;const double *a,*d,*p,*q,*v,*lap,*y,*x,*y_expected,*truth,*matrix,*limits;
};
struct observer {struct problem *p;int native,next;unsigned char *saved[5];size_t bytes[5];};
static _Thread_local struct observer *current;
static uint64_t calls,protected_calls,abi_calls,parallel_calls,science_values,residual_values,inactive_values,stage_records,stage_bytes,output_bytes;
static double max_forward_fraction,max_residual_fraction;
static FILE *source_file,*native_file,*source_stages,*native_stages;
static void fail(const char *s){fprintf(stderr,"SIMPLICO FAIL %s\n",s);exit(2);}
static uint64_t fpcr(void){uint64_t r;__asm__ volatile("mrs %0,fpcr":"=r"(r));return r;}
static uint64_t u64(const void *p){uint64_t x;memcpy(&x,p,8);return x;}
static int32_t i32(const void *p){int32_t x;memcpy(&x,p,4);return x;}
static double f64(const void *p){double x;memcpy(&x,p,8);return x;}
static void count(uint64_t *p,uint64_t n){__atomic_fetch_add(p,n,__ATOMIC_RELAXED);}
static void write_bytes(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("output write");}
static void equal(const void *a,const void *b,size_t n,int id,int stage,const char *field)
{
 if(!memcmp(a,b,n))return;
 const unsigned char *x=a,*y=b;size_t k=0;while(k<n&&x[k]==y[k])k++;
 uint64_t av=0,bv=0;if(k/8*8+8<=n){av=u64(x+k/8*8);bv=u64(y+k/8*8);}
 fprintf(stderr,"case=%d stage=%d field=%s byte=%zu cell=%zu source=%016"PRIx64" native=%016"PRIx64"\n",id,stage,field,k,k/8,av,bv);
 fail("raw byte difference");
}
static struct region region_new(size_t n,const void *initial,int readonly)
{
 size_t page=(size_t)sysconf(_SC_PAGESIZE),access=((n+64+page-1)/page)*page,total=access+2*page;
 unsigned char *map=mmap(NULL,total,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);if(map==MAP_FAILED)fail("mmap");
 if(mprotect(map+page,access,PROT_READ|PROT_WRITE))fail("mprotect");
 unsigned char *data=map+page+access-n;
 for(size_t k=0;k<64;k++)data[(ptrdiff_t)k-64]=(unsigned char)(0x51+k%31);
 if(n)memcpy(data,initial,n);
 if(readonly&&mprotect(map+page,access,PROT_READ))fail("input protection");
 return (struct region){map,data,total,access,n};
}
static void region_done(struct region *r)
{
 for(size_t k=0;k<64;k++)if(r->data[(ptrdiff_t)k-64]!=(unsigned char)(0x51+k%31))fail("prefix guard");
 if(munmap(r->map,r->total))fail("munmap");
}
static void observe(const int32_t *stage,const int32_t *m,const int32_t *n,
 const int32_t *l,const int32_t *s,const double *y,const double *x,const double *work,int native)
{
 struct observer *c=current;if(!c||c->native!=native||c->next!=*stage||fpcr())fail("stage dispatch/FPCR");
 struct problem *p=c->p;
 if(*m!=p->m||*n!=p->n||*l!=p->l||*s!=p->s)fail("stage shape");
 const int parity=*stage?(*stage-1)/2:0,b=p->m+parity,e=p->n-((p->n-p->m+parity)&1);
 const size_t words=*stage?(size_t)((e-b)/2+1)*p->l*(p->m?2:1):0;
 const size_t bytes=16*p->count+8*words;
 unsigned char *copy=malloc(bytes?bytes:1);if(!copy)fail("stage allocation");
 if(p->count){memcpy(copy,y,p->count*8);memcpy(copy+p->count*8,x,p->count*8);}
 size_t k=2*p->count;
 if(*stage)for(int degree=b;degree<=e;degree+=2)for(int part=0;part<(p->m?2:1);part++)for(int level=0;level<p->l;level++){
  size_t pos=((size_t)(degree-p->m)*2+part)*p->s+level;memcpy(copy+k*8,work+pos,8);k++;
 }
 if(k!=2*p->count+words)fail("stage capacity");
 if(native){if(c->bytes[*stage]!=bytes)fail("stage size");equal(c->saved[*stage],copy,bytes,p->id,*stage,"PY/PX/work");}
 else {c->saved[*stage]=malloc(bytes?bytes:1);if(!c->saved[*stage])fail("saved stage");if(bytes)memcpy(c->saved[*stage],copy,bytes);c->bytes[*stage]=bytes;}
 int32_t header[8]={p->id,*stage,p->m,p->n,p->l,p->s,(int32_t)words,0};
 FILE *f=native?native_stages:source_stages;write_bytes(f,header,32);write_bytes(f,copy,bytes);
 if(native){stage_records++;stage_bytes+=32+bytes;}
 c->next++;free(copy);
}
void simplico_reference_stage_(const int32_t *stage,const int32_t *m,const int32_t *n,const int32_t *l,const int32_t *s,const double *y,const double *x,const double *w){observe(stage,m,n,l,s,y,x,w,0);}
void simplico_native_stage_(const int32_t *stage,const int32_t *m,const int32_t *n,const int32_t *l,const int32_t *s,const double *y,const double *x,const double *w){observe(stage,m,n,l,s,y,x,w,1);}
static void execute(struct problem *p,solve_fn fn,double **returned_y,double **returned_x)
{
 struct {int32_t m,n,l,s;double b2;} parameters={p->m,p->n,p->l,p->s,p->b2};
 struct region r[9];const void *initial[9]={p->a,p->d,p->p,p->q,p->v,p->lap,&parameters,p->y,p->x};
 size_t length[9]={p->rotation*8,p->rotation*8,p->rotation*8,p->rotation*8,(size_t)p->l*8,p->lap_count*8,sizeof(parameters),p->count*8,p->count*8};
 for(int k=0;k<9;k++)r[k]=region_new(length[k],initial[k],k<7||(k==7&&p->m>0));
 const int32_t *shape=(const int32_t*)r[6].data;
 struct invocation a={fn,shape,shape+1,shape+2,shape+3,(double*)r[0].data,(double*)r[1].data,(double*)r[2].data,(double*)r[3].data,(double*)r[4].data,(double*)r[5].data,(double*)(r[6].data+16),(double*)r[7].data,(double*)r[8].data};
 if(fpcr())fail("entry FPCR");
 uint64_t mask=vertical_abi_call(simplico_abi_invoke,&a);
 if(mask){fprintf(stderr,"case=%d canary=%016"PRIx64"\n",p->id,mask);fail("direct preserved registers/FPCR");}
 if(fpcr())fail("return FPCR");
 for(int k=0;k<7;k++)equal(initial[k],r[k].data,length[k],p->id,-1,"immutable input");
 equal(p->y_expected,r[7].data,length[7],p->id,-1,"complete PY mutation");
 *returned_y=malloc(length[7]?length[7]:1);*returned_x=malloc(length[8]?length[8]:1);
 if(!*returned_y||!*returned_x)fail("returned allocation");
 if(length[7])memcpy(*returned_y,r[7].data,length[7]);
 if(length[8])memcpy(*returned_x,r[8].data,length[8]);
 for(int k=0;k<9;k++)region_done(&r[k]);
 count(&calls,1);count(&protected_calls,1);count(&abi_calls,1);
}
static void science(struct problem *p,const double *x)
{
 for(int z=0;z<(int)p->waves;z++)for(int part=0;part<2;part++)for(int level=0;level<p->s;level++){
  size_t pos=((size_t)z*2+part)*p->s+level;
  if(level>=p->l||(p->m==0&&part==1)){equal(p->truth+pos,x+pos,8,p->id,-1,"inactive/explicit zero");inactive_values++;continue;}
  double error=fabs(x[pos]-p->truth[pos]),limit=p->limits[level];
  if(!isfinite(x[pos])||error>limit){fprintf(stderr,"case=%d n=%d level=%d part=%d error=%.17g limit=%.17g\n",p->id,p->m+z,level,part,error,limit);fail("100-digit dense solution");}
  if(limit&&error/limit>max_forward_fraction)max_forward_fraction=error/limit;
  science_values++;
 }
 for(int level=0;level<p->l;level++)for(size_t row=0;row<p->waves;row++){
  long double sr=0,si=0,scale=0;
  const double *a=p->matrix+(size_t)level*p->waves*p->waves*2;
  for(size_t col=0;col<p->waves;col++){
   long double ar=a[(row*p->waves+col)*2],ai=a[(row*p->waves+col)*2+1];
   long double xr=x[2*col*p->s+level],xi=x[(2*col+1)*p->s+level];
   sr+=ar*xr-ai*xi;si+=ai*xr+ar*xi;
   scale+=fabsl(ar*xr)+fabsl(ai*xi)+fabsl(ai*xr)+fabsl(ar*xi);
  }
  long double yr=p->y[row*2*p->s+level],yi=p->m?p->y[(row*2+1)*p->s+level]:0;
  scale+=fabsl(yr)+fabsl(yi);
  const long double limit=512.0L*DBL_EPSILON*fmaxl(scale,DBL_MIN)+16.0L*DBL_TRUE_MIN;
  long double er=fabsl(sr-yr),ei=fabsl(si-yi);
  if(er>limit||ei>limit){fprintf(stderr,"case=%d row=%zu level=%d residual=%Lg,%Lg limit=%Lg\n",p->id,row,level,er,ei,limit);fail("original matrix residual");}
  double fraction=(double)(fmaxl(er,ei)/limit);if(fraction>max_residual_fraction)max_residual_fraction=fraction;
  residual_values+=p->m?2:1;
 }
}
static unsigned char *read_file(const char *path,size_t *size)
{
 FILE *f=fopen(path,"rb");if(!f)fail("input open");if(fseek(f,0,SEEK_END))fail("input seek");long n=ftell(f);if(n<0)fail("input size");rewind(f);
 unsigned char *p=malloc((size_t)n);if(!p)fail("input allocation");if(fread(p,1,(size_t)n,f)!=(size_t)n)fail("input read");fclose(f);*size=(size_t)n;return p;
}
static FILE *output(const char *dir,const char *name){char path[4096];if(snprintf(path,sizeof(path),"%s/%s",dir,name)>=(int)sizeof(path))fail("output path");FILE *f=fopen(path,"wb");if(!f)fail("output open");return f;}
int main(int argc,char **argv)
{
 if(argc!=3)fail("usage: verify preparation_directory output_directory");
 struct rlimit lim={0,0};if(setrlimit(RLIMIT_CORE,&lim))fail("core limit");
 int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(!hook)fail("profiling hook symbol");*hook=0;
 if(fpcr())fail("driver FPCR");
 char path[4096];if(snprintf(path,sizeof(path),"%s/corpus.bin",argv[1])>=(int)sizeof(path))fail("input path");
 size_t size;unsigned char *input=read_file(path,&size),*saved=malloc(size);if(!saved)fail("input snapshot");memcpy(saved,input,size);
 if(size<64||memcmp(input,"SIMPIN01",8)||i32(input+8)!=1||u64(input+16)!=size-64)fail("input encoding");
 int cases=i32(input+12);struct problem *problems=calloc((size_t)cases,sizeof(*problems));if(!problems)fail("case table");
 source_file=output(argv[2],"reference.bin");native_file=output(argv[2],"assembly.bin");source_stages=output(argv[2],"reference-stages.bin");native_stages=output(argv[2],"assembly-stages.bin");
 size_t cursor=64;
 for(int k=0;k<cases;k++){
  if(cursor+128>size)fail("case header bounds");
  struct problem *p=problems+k;
  p->header=input+cursor;p->id=i32(p->header);p->n=i32(p->header+4);p->m=i32(p->header+8);p->l=i32(p->header+12);p->s=i32(p->header+16);p->profile=i32(p->header+20);
  p->count=u64(p->header+40);p->matrix_words=u64(p->header+48);p->b2=f64(p->header+64);p->waves=u64(p->header+96);p->rotation=u64(p->header+104);p->lap_count=u64(p->header+112);
  size_t bytes=u64(p->header+32);if(cursor+128+bytes>size)fail("case payload bounds");
  const double *v=(const double*)(p->header+128);p->a=v;v+=p->rotation;p->d=v;v+=p->rotation;p->p=v;v+=p->rotation;p->q=v;v+=p->rotation;
  p->v=v;v+=p->l;p->lap=v;v+=p->lap_count;p->y=v;v+=p->count;p->x=v;v+=p->count;p->y_expected=v;v+=p->count;p->truth=v;v+=p->count;p->matrix=v;v+=p->matrix_words;p->limits=v;v+=p->l;
  if((const unsigned char*)v!=p->header+128+bytes)fail("case payload length");
  struct observer c={.p=p};double *y[4],*x[4];
  execute(p,simplico_,y,x);execute(p,simplico_assembly_,y+1,x+1);
  equal(y[0],y[1],p->count*8,p->id,-1,"whole PY");equal(x[0],x[1],p->count*8,p->id,-1,"whole PX");
  science(p,x[0]);science(p,x[1]);
  current=&c;execute(p,simplico_stage_reference_,y+2,x+2);
  if(c.next!=(p->m==p->n?3:5))fail("source complete stage count");
  c.native=1;c.next=0;execute(p,simplico_stage_assembly_,y+3,x+3);current=NULL;
  for(int j=2;j<4;j++){equal(y[0],y[j],p->count*8,p->id,-1,"observed PY");equal(x[0],x[j],p->count*8,p->id,-1,"observed PX");}
  for(int j=0;j<4;j++){if(j<2){FILE *f=j?native_file:source_file;write_bytes(f,p->header,128);write_bytes(f,y[j],p->count*8);write_bytes(f,x[j],p->count*8);}free(y[j]);free(x[j]);}
  output_bytes+=128+16*p->count;
  for(int j=0;j<5;j++)free(c.saved[j]);
  cursor+=128+bytes;
 }
 if(cursor!=size)fail("final input bound");
 /* A real outer parallel team calls complete source/native bodies independently. */
 int observed_threads=0,actual_first=-1;
 for(int k=0;k<cases;k++)if(problems[k].profile==1){actual_first=k;break;}
 if(actual_first<0)fail("T21 parallel fixture");
#pragma omp parallel num_threads(3) reduction(+:observed_threads)
 {
  observed_threads++;int t=omp_get_thread_num();struct problem *p=problems+actual_first+(t==2?21:t);double *ys,*xs,*yn,*xn;
  execute(p,simplico_,&ys,&xs);execute(p,simplico_assembly_,&yn,&xn);
  equal(ys,yn,p->count*8,p->id,-1,"parallel PY");equal(xs,xn,p->count*8,p->id,-1,"parallel PX");
  free(ys);free(xs);free(yn);free(xn);count(&parallel_calls,2);
 }
 if(observed_threads!=3)fail("genuine three-thread team");
 equal(saved,input,size,-1,-1,"frozen complete input stream");
 fclose(source_file);fclose(native_file);fclose(source_stages);fclose(native_stages);
 FILE *report=output(argv[2],"summary.json");
 fprintf(report,"{\"cases\":%d,\"calls\":%"PRIu64",\"output_bytes\":%"PRIu64",\"stage_records\":%"PRIu64",\"stage_bytes\":%"PRIu64",\"science_values\":%"PRIu64",\"residual_values\":%"PRIu64",\"inactive_values\":%"PRIu64",\"protected_calls\":%"PRIu64",\"abi_calls\":%"PRIu64",\"parallel_calls\":%"PRIu64",\"max_forward_limit_fraction\":%.17g,\"max_residual_limit_fraction\":%.17g,\"different_bytes\":0,\"fpcr\":0}\n",cases,calls,output_bytes,stage_records,stage_bytes,science_values,residual_values,inactive_values,protected_calls,abi_calls,parallel_calls,max_forward_fraction,max_residual_fraction);fclose(report);
 printf("SIMPLICO accepted cases=%d calls=%"PRIu64" output_bytes=%"PRIu64" stage_records=%"PRIu64" science=%"PRIu64" residual=%"PRIu64" different_bytes=0 FPCR=0\n",cases,calls,output_bytes,stage_records,science_values,residual_values);
 free(problems);free(input);free(saved);return 0;
}

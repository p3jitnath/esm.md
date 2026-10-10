/* Verify physical neighbour bounds and complete original output storage.
 * Integers and real values use the original four- and eight-byte formats.
 * A field's minimum and maximum have the same units as that field.
 * The complete original and direct native bodies calculate separate returns. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <limits.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PARAMETERS void *a0,void *a1,void *a2,void *a3,void *a4,void *a5,void *a6,void *a7,void *a8,void *a9,void *a10
#define ARGUMENTS a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10
typedef void (*kernel)(PARAMETERS);
static uint64_t diagnostic_call;
static int32_t diagnostic_phase;
static const char *diagnostic_stage="preflight";
static size_t diagnostic_origin,diagnostic_width=8;
static void fail(const char *reason){fprintf(stderr,"LAMINMAXINT failed stage=%s call=%"PRIu64" phase=%d %s\n",diagnostic_stage,diagnostic_call,diagnostic_phase,reason);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete raw write");}
static uint64_t bits(double x){uint64_t u;memcpy(&u,&x,8);return u;}
static void same(const void *x,const void *y,size_t n,const char *field){
 if(!n||!memcmp(x,y,n))return;
 const unsigned char *a=x,*b=y;size_t off=0;while(off<n&&a[off]==b[off])++off;
 size_t word=off/diagnostic_width*diagnostic_width,width=n-word<diagnostic_width?n-word:diagnostic_width;
 uint64_t expected=0,actual=0;memcpy(&expected,a+word,width);memcpy(&actual,b+word,width);
 fprintf(stderr,"LAMINMAXINT first difference stage=%s call=%"PRIu64" phase=%d field=%s cell=%zu byte=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",diagnostic_stage,diagnostic_call,diagnostic_phase,field,diagnostic_origin+off/diagnostic_width,off,expected,actual);
 fail(field);
}
static uint64_t fpcr(void){uint64_t x;__asm__ volatile("mrs %0,fpcr":"=r"(x));return x;}
static int overlap(const void *x,size_t nx,const void *y,size_t ny){return nx&&ny&&(uintptr_t)x<(uintptr_t)y+ny&&(uintptr_t)y<(uintptr_t)x+nx;}
static void domain(const int32_t d[7],void *const a[11],size_t sizes[11]){
 int64_t A=d[0],B=d[1],S=d[2],E=d[3],L=d[4],N=(int64_t)d[6]-d[5]+1;
 if(A<0||A>1048576||B<0||B>4096||L<0||L>512||N<0||N>1024||S<1||S>B+1||E<0||E>B||A*N>INT32_MAX)fail("complete original32-bit shape bounds");
 for(int z=0;z<7;++z)sizes[z]=4;
 size_t C=(size_t)B*L;
 sizes[7]=4*C*4;sizes[8]=(size_t)A*N*8;sizes[9]=C*8;sizes[10]=a[10]?C*8:0;
 for(int z=0;z<11;++z)if(sizes[z]&&(!a[z]||(uintptr_t)a[z]%(z<8?4:8)||(uintptr_t)a[z]>UINTPTR_MAX-sizes[z]))fail("complete buffer alignment and capacity");
 for(int z=9;z<11;++z)for(int k=0;k<11;++k)if(z!=k&&overlap(a[z],sizes[z],a[k],sizes[k]))fail("disjoint complete outputs");
 const int32_t *idx=a[7];const double *field=a[8];
 for(int64_t l=0;l<L;++l)for(int64_t j=S-1;j<E;++j){
  size_t i=(size_t)j+(size_t)B*l;
  for(int plane=1;plane<=2;++plane)for(int level=1;level<=2;++level)for(int east=0;east<=1;++east){
   int64_t off=(int64_t)idx[i+(size_t)plane*C]+level*A+east;
   if(off<0||off>=A*N||off>=INT32_MAX)fail("all eight source index expressions fit before execution");
   if(!isfinite(field[off]))fail("finite selected physical field values before execution");
  }
 }
}
static uint64_t physical_relations,selected_cells,preserved_bytes,negative_zero_min,positive_zero_max;
static void physics(const int32_t d[7],void *const a[11],const unsigned char *before[2],const double *out[2]){
 size_t A=d[0],B=d[1],L=d[4],C=B*L;const int32_t *idx=a[7];const double *f=a[8];
 for(size_t l=0;l<L;++l)for(size_t j=0;j<B;++j){
  size_t i=j+B*l;diagnostic_origin=i;diagnostic_width=8;
  if(j<(size_t)(d[2]-1)||j>=(size_t)d[3]){
   same(out[0]+i,before[0]+8*i,8,"whole inactive minimum bytes");
   if(a[10])same(out[1]+i,before[1]+8*i,8,"whole inactive maximum bytes");
   preserved_bytes+=a[10]?16:8;continue;
  }
  double corners[8];unsigned z=0;
  for(int level=1;level<=2;++level)for(int plane=1;plane<=2;++plane)for(int east=0;east<=1;++east){
   int64_t k=(int64_t)idx[i+plane*C]+(int64_t)level*A+east;
   corners[z++]=f[k];
  }
  double lo=out[0][i],hi=a[10]?out[1][i]:0;int min_member=0,max_member=0,minus_zero=0,plus_zero=0;
  if(!isfinite(lo)||(a[10]&&!isfinite(hi)))fail("finite physical extrema");
  for(unsigned k=0;k<8;++k){
   double v=corners[k];if(!(lo<=v)||(a[10]&&!(v<=hi)))fail("each neighbour lies between returned bounds");
   min_member|=lo==v;if(a[10])max_member|=hi==v;
   if(v==0){minus_zero|=(bits(v)>>63)!=0;plus_zero|=(bits(v)>>63)==0;}
   physical_relations+=a[10]?2:1;
  }
  if(!min_member||(a[10]&&!max_member))fail("each returned extremum is a member of its neighbour set");
  physical_relations+=a[10]?2:1;
  if(lo==0){uint64_t expected=minus_zero?UINT64_C(1)<<63:0;if(bits(lo)!=expected)fail("source-probed finite minimum zero tie");negative_zero_min+=minus_zero;++physical_relations;}
  if(a[10]&&hi==0){uint64_t expected=plus_zero?0:UINT64_C(1)<<63;if(bits(hi)!=expected)fail("source-probed finite maximum zero tie");positive_zero_max+=plus_zero;++physical_relations;}
  ++selected_cells;
 }
}

#include <sys/mman.h>
#include <unistd.h>
#include <pthread.h>
extern void laminmaxint_md2asm(PARAMETERS);
extern uint64_t vertical_abi_call(void (*)(void *),void *);
typedef struct {void *a[11];} Arguments;
static void invoke_native(void *context){
 Arguments *c=context;void **a=c->a;
 laminmaxint_md2asm(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10]);
}
typedef struct {uint64_t id,site;int32_t meta[12];} Record;
_Static_assert(sizeof(Record)==64,"complete record header");
typedef struct {unsigned char *base,*data;size_t mapbytes,n,pages,offset;} Guard;
static size_t page;
static kernel original;
static uint64_t record_count,call_count,returned_count;
static Guard guarded(size_t n,int end){
 Guard g={0};g.n=n;if(!n)return g;
 g.pages=(n+page-1)/page;g.mapbytes=(g.pages+2)*page;
 g.base=mmap(NULL,g.mapbytes,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(g.base==MAP_FAILED)fail("protected full allocation");
 if(mprotect(g.base+page,g.pages*page,PROT_READ|PROT_WRITE))fail("protected allocation permissions");
 memset(g.base+page,0xa5,g.pages*page);g.offset=end?g.pages*page-n:0;g.data=g.base+page+g.offset;return g;
}
static void readonly(Guard *g){if(g->n&&mprotect(g->base+page,g->pages*page,PROT_READ))fail("complete readonly protected input");}
static void intact(const Guard *g){
 if(!g->n)return;
 const unsigned char *p=g->base+page;
 for(size_t i=0;i<g->offset;++i)if(p[i]!=0xa5)fail("leading full-allocation canary");
 for(size_t i=g->offset+g->n;i<g->pages*page;++i)if(p[i]!=0xa5)fail("trailing full-allocation canary");
}
static void release(Guard *g){if(g->n&&munmap(g->base,g->mapbytes))fail("protected allocation release");}
static void readall(FILE *f,void *p,size_t n){if(n&&fread(p,1,n,f)!=n)fail("whole frozen record read");}
static void record_sizes(const Record *h,size_t sz[4]){
 const int32_t *d=h->meta+3;int64_t A=d[0],B=d[1],L=d[4],N=(int64_t)d[6]-d[5]+1;
 if(h->meta[2]<0||h->meta[2]>1||h->meta[10]||h->meta[11])fail("canonical maximum presence and header");
 if(A<0||A>1048576||B<0||B>4096||L<0||L>512||N<0||N>1024||d[2]<1||d[2]>B+1||d[3]<0||d[3]>B||A*N>INT32_MAX)fail("frozen whole-array sizes before allocation");
 size_t C=(size_t)B*L;sz[0]=16*C;sz[1]=(size_t)A*N*8;sz[2]=8*C;sz[3]=h->meta[2]?8*C:0;
}
static uint64_t thread_calls,thread_returned_bytes,thread_groups;
typedef struct {
 Arguments args;
 Guard scalar,g[4];
 pthread_barrier_t *gate;
 pthread_t identity;
 uint64_t entry_FPCR,exit_FPCR,ABI_status;
} ThreadCall;
static void *thread_native(void *context){
 ThreadCall *t=context;t->identity=pthread_self();t->entry_FPCR=fpcr();
 int rc=pthread_barrier_wait(t->gate);
 if(rc&&rc!=PTHREAD_BARRIER_SERIAL_THREAD){t->ABI_status=UINT64_MAX;return NULL;}
 t->ABI_status=vertical_abi_call(invoke_native,&t->args);
 t->exit_FPCR=fpcr();return NULL;
}
static void parallel_primary_record(const Record *h,unsigned char *const raw[4],const size_t sz[4],const unsigned char *expected){
 ThreadCall t[3]={0};pthread_t workers[3];pthread_barrier_t gate;
 if(pthread_barrier_init(&gate,NULL,4))fail("three-thread barrier creation");
 const uint64_t empty_maximum=UINT64_C(0xcafef00d12345678);
 diagnostic_stage="three-thread preflight";diagnostic_call=h->id;diagnostic_phase=h->meta[0];
 for(int k=0;k<3;++k){
  t[k].gate=&gate;t[k].scalar=guarded(28,k&1);memcpy(t[k].scalar.data,h->meta+3,28);readonly(&t[k].scalar);
  for(int z=0;z<4;++z){size_t allocation=sz[z];if(z==3&&h->meta[2]&&!allocation)allocation=8;t[k].g[z]=guarded(allocation,k&1);if(sz[z])memcpy(t[k].g[z].data,raw[z],sz[z]);else if(allocation)memcpy(t[k].g[z].data,&empty_maximum,8);if(z<2)readonly(t[k].g+z);}
  for(int z=0;z<7;++z)t[k].args.a[z]=t[k].scalar.data+4*z;
  for(int z=7;z<11;++z)t[k].args.a[z]=t[k].g[z-7].data;
  size_t sizes[11];domain(h->meta+3,t[k].args.a,sizes);
  if((t[k].args.a[10]!=NULL)!=(h->meta[2]==1))fail("thread optional pointer presence");
  if(pthread_create(workers+k,NULL,thread_native,t+k))fail("three real worker threads");
 }
 int rc=pthread_barrier_wait(&gate);if(rc&&rc!=PTHREAD_BARRIER_SERIAL_THREAD)fail("main barrier release");
 for(int k=0;k<3;++k)if(pthread_join(workers[k],NULL))fail("three-thread completion");
 for(int k=0;k<3;++k)for(int j=0;j<k;++j)if(pthread_equal(t[k].identity,t[j].identity))fail("distinct simultaneous thread identities");
 for(int k=0;k<3;++k){
  diagnostic_stage="three-thread complete native leaf";diagnostic_origin=0;diagnostic_width=8;
  if(t[k].entry_FPCR||t[k].exit_FPCR||t[k].ABI_status)fail("thread original ABI and FPCR");
  if(t[k].g[3].n!=sz[3])same(t[k].g[3].data,&empty_maximum,8,"thread empty present maximum sentinel");
  diagnostic_width=4;same(t[k].scalar.data,h->meta+3,28,"thread seven complete input scalars");
  for(int z=0;z<2;++z){diagnostic_width=z?8:4;same(t[k].g[z].data,raw[z],sz[z],z?"thread complete field":"thread complete four index planes");}
  const unsigned char *before[2]={raw[2],raw[3]};const double *out[2]={(double*)t[k].g[2].data,(double*)t[k].g[3].data};
  physics(h->meta+3,t[k].args.a,before,out);diagnostic_origin=0;diagnostic_width=8;
  same(expected,t[k].g[2].data,sz[2],"thread whole source/native minimum");
  same(expected+sz[2],t[k].g[3].data,sz[3],"thread whole source/native maximum");
  intact(&t[k].scalar);for(int z=0;z<4;++z){intact(t[k].g+z);release(t[k].g+z);}release(&t[k].scalar);
  ++thread_calls;thread_returned_bytes+=64+sz[2]+sz[3];
 }
 if(pthread_barrier_destroy(&gate))fail("three-thread barrier release");++thread_groups;
}
static void execute(const Record *h,unsigned char *const raw[4],const size_t sz[4],FILE *frozen,FILE *output,int placements){
 diagnostic_call=h->id;diagnostic_phase=h->meta[0];diagnostic_stage="frozen record";diagnostic_origin=0;diagnostic_width=8;
 unsigned char *expected=NULL;size_t outbytes=64+sz[2]+sz[3];
 if(frozen){Record other;readall(frozen,&other,64);same(h,&other,64,"whole frozen output header");expected=malloc(outbytes-64?outbytes-64:1);if(!expected)fail("complete expected allocation");readall(frozen,expected,outbytes-64);}
 for(int placement=0;placement<placements;++placement){
  Guard scalar=guarded(28,placement),g[4];memcpy(scalar.data,h->meta+3,28);readonly(&scalar);
  const uint64_t empty_maximum=UINT64_C(0xcafef00d12345678);
  for(int z=0;z<4;++z){size_t allocation=sz[z];if(z==3&&h->meta[2]&&!allocation)allocation=8;g[z]=guarded(allocation,placement);if(sz[z])memcpy(g[z].data,raw[z],sz[z]);else if(allocation)memcpy(g[z].data,&empty_maximum,8);if(z<2)readonly(g+z);}
  int32_t d[7];memcpy(d,h->meta+3,28);
  Arguments args;void **a=args.a;for(int z=0;z<7;++z)a[z]=scalar.data+4*z;
  for(int z=7;z<11;++z)a[z]=g[z-7].data;
  if((a[10]!=NULL)!=(h->meta[2]==1))fail("exact optional pointer presence before either source branch");
  size_t sizes[11];domain(d,a,sizes);
  for(int kind=0;kind<2;++kind){
   for(int z=2;z<4;++z){if(sz[z])memcpy(g[z].data,raw[z],sz[z]);else if(g[z].n)memcpy(g[z].data,&empty_maximum,8);}
   diagnostic_stage=kind?"native complete leaf":"original complete leaf";diagnostic_origin=0;diagnostic_width=8;
   if(fpcr())fail("exact entry FPCR");
   if(kind){
    uint64_t status=vertical_abi_call(invoke_native,&args);
    if(status){fprintf(stderr,"LAMINMAXINT ABI mask=0x%016"PRIx64"\n",status);fail("preserved original Arm ABI");}
   }else original(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10]);
   if(fpcr())fail("preserved FPCR");
   if(g[3].n!=sz[3])same(g[3].data,&empty_maximum,8,"empty present maximum placeholder unchanged");
   diagnostic_width=4;same(scalar.data,h->meta+3,28,"all seven input scalar bytes");
   for(int z=0;z<2;++z){diagnostic_width=z?8:4;same(g[z].data,raw[z],sz[z],z?"whole readonly physical field":"whole readonly four-plane neighbour indices");}
   const unsigned char *before[2]={raw[2],raw[3]};const double *out[2]={(double*)g[2].data,(double*)g[3].data};
   physics(d,a,before,out);diagnostic_origin=0;diagnostic_width=8;
   if(!expected){expected=malloc(outbytes-64?outbytes-64:1);if(!expected)fail("complete first returned allocation");if(sz[2])memcpy(expected,g[2].data,sz[2]);if(sz[3])memcpy(expected+sz[2],g[3].data,sz[3]);}
   same(expected,g[2].data,sz[2],"whole minimum replay bits");
   same(expected+sz[2],g[3].data,sz[3],"whole maximum replay bits");
   intact(&scalar);for(int z=0;z<4;++z)intact(g+z);
   if(kind){
    if(!placement&&output){writeall(output,h,64);writeall(output,g[2].data,sz[2]);writeall(output,g[3].data,sz[3]);}
    ++call_count;returned_count+=outbytes;
   }
  }
  for(int z=0;z<4;++z)release(g+z);release(&scalar);
 }
 if(h->meta[0]==-1&&(h->id==0||h->id==29||h->id==113||h->id==791))parallel_primary_record(h,raw,sz,expected);
 free(expected);++record_count;
}
static uint64_t random_state=UINT64_C(0x2026101000414000);
static uint64_t random_bits(void){random_state^=random_state<<13;random_state^=random_state>>7;random_state^=random_state<<17;return random_state;}
static double sample(unsigned profile,unsigned corner,uint64_t zero_pattern){
 uint64_t u;double v;
 switch(profile){
 case 0:return 2;
 case 1:return (double)(int)(corner*13+3)-41;
 case 2:u=(zero_pattern>>corner&1)<<63;break;
 case 3:u=((uint64_t)(corner&1)<<63)|(corner+1);break;
 case 4:u=((uint64_t)(corner&1)<<63)|UINT64_C(0x0010000000000000)|corner;break;
 case 5:return corner&1?-DBL_MAX:DBL_MAX;
 case 6:return ldexp((double)(corner+1),-32);
 case 7:return corner==0?0:(double)(corner+1);
 case 8:return corner==7?0:-(double)(corner+1);
 case 9:u=(random_bits()&UINT64_C(0x800fffffffffffff))|UINT64_C(0x3fd0000000000000);break;
 case 10:u=UINT64_C(0x7fefffffffffffff)-corner;break;
 case 11:return -(double)(corner+1);
 case 12:return corner==0?-DBL_TRUE_MIN:0;
 default:return corner==7?DBL_TRUE_MIN:0;
 }
 memcpy(&v,&u,8);return v;
}
static void create_case(const int32_t d[7],int maximum,unsigned profile,uint64_t zero_pattern,FILE *inputs,FILE *outputs){
 Record h={0};h.id=record_count;h.meta[0]=-1;h.meta[1]=(int32_t)profile;h.meta[2]=maximum;memcpy(h.meta+3,d,28);
 size_t sz[4];record_sizes(&h,sz);unsigned char *raw[4];
 for(int z=0;z<4;++z){raw[z]=malloc(sz[z]?sz[z]:1);if(!raw[z])fail("whole critical allocation");}
 size_t C=(size_t)d[1]*d[4],F=sz[1]/8;int64_t A=d[0],N=(int64_t)d[6]-d[5]+1;
 int32_t *idx=(int32_t*)raw[0];double *field=(double*)raw[1];
 for(size_t z=0;z<4*C;++z)idx[z]=(z&1)?INT32_MAX:INT32_MIN;
 for(size_t z=0;z<F;++z){uint64_t u=UINT64_C(0x7ff8000000000000)|(random_bits()&UINT64_C(0x0007ffffffffffff));memcpy(field+z,&u,8);}
 for(int z=2;z<4;++z)for(size_t k=0;k<sz[z]/8;++k){uint64_t u=random_bits();memcpy(raw[z]+8*k,&u,8);}
 for(int l=0;l<d[4];++l)for(int j=d[2]-1;j<d[3];++j){
  size_t i=j+(size_t)d[1]*l;int64_t first;
  if(A==1){first=-1;idx[i+C]=idx[i+2*C]=(int32_t)first;}
  else{first=(i&1)?A*(N-2)-4:-A;idx[i+C]=(int32_t)first;idx[i+2*C]=(int32_t)(first+2);}
  unsigned corner=0;
  for(int level=1;level<=2;++level)for(int plane=1;plane<=2;++plane)for(int east=0;east<=1;++east){
   int64_t k=(int64_t)idx[i+plane*C]+level*A+east;if(k<0||k>=(int64_t)F)fail("critical neighbour capacity");
   field[k]=sample(profile,corner++,zero_pattern);
  }
 }
 writeall(inputs,&h,64);for(int z=0;z<4;++z)writeall(inputs,raw[z],sz[z]);
 execute(&h,raw,sz,NULL,outputs,2);for(int z=0;z<4;++z)free(raw[z]);
}
int main(int argc,char **argv){
 page=(size_t)sysconf(_SC_PAGESIZE);if(!page)fail("page size");
 void *lib=dlopen(".runtime/openifs/strict-build/lib/libarpifs.DP.so",RTLD_NOW);if(!lib)fail(dlerror());
 void *p=dlsym(lib,"laminmaxint_");memcpy(&original,&p,sizeof original);int32_t *hook=dlsym(lib,"__yomhook_MOD_lhook");if(!original||!hook)fail("original source and profile flag");*hook=0;
 if(argc==4&&strcmp(argv[1],"--create")==0){
  FILE *in=fopen(argv[2],"wx"),*out=fopen(argv[3],"wx");if(!in||!out)fail("unique critical corpus");
  const int32_t shapes[][7]={
   {8,1,1,1,1,0,3},{17,3,2,2,2,-2,1},{31,7,1,6,5,1,5},
   {64,24,1,24,19,0,20},{8,8,1,8,0,1,4},{0,0,1,0,0,1,0},
   {8,5,4,2,3,1,3},{5,9,9,9,1,1,3},{5,6,2,5,4,INT32_MIN,INT32_MIN+2},
   {1,2,1,2,2,INT32_MAX-2,INT32_MAX}
  };
  for(unsigned sh=0;sh<sizeof shapes/sizeof shapes[0];++sh)for(unsigned profile=0;profile<14;++profile)for(int maximum=0;maximum<=1;++maximum)create_case(shapes[sh],maximum,profile,UINT64_C(0xa5),in,out);
  for(uint64_t mask=0;mask<256;++mask)for(int maximum=0;maximum<=1;++maximum)create_case(shapes[0],maximum,2,mask,in,out);
  if(fclose(in)||fclose(out))fail("critical corpus close");
 }else if(argc==4&&strcmp(argv[1],"--replay")==0){
  FILE *in=fopen(argv[2],"rb"),*out=fopen(argv[3],"rb");if(!in||!out)fail("original replay files");
  Record h;
  for(;;){
   size_t header_bytes=fread(&h,1,64,in);if(!header_bytes){if(ferror(in))fail("original input read error");break;}if(header_bytes!=64)fail("complete frozen64-byte header");
   diagnostic_call=h.id;diagnostic_phase=h.meta[0];diagnostic_stage="frozen preflight";diagnostic_origin=0;
   size_t sz[4];record_sizes(&h,sz);unsigned char *raw[4];for(int z=0;z<4;++z){raw[z]=malloc(sz[z]?sz[z]:1);if(!raw[z])fail("whole replay allocation");readall(in,raw[z],sz[z]);}
   execute(&h,raw,sz,out,NULL,2);for(int z=0;z<4;++z)free(raw[z]);
  }
  if(!feof(in)||fgetc(out)!=EOF||!feof(out)||fclose(in)||fclose(out))fail("whole frozen stream end");
 }else fail("create or replay arguments");
 printf("{\"source_only\":false,\"records\":%"PRIu64",\"native_protected_ABI_calls\":%"PRIu64",\"thread_groups\":%"PRIu64",\"thread_native_ABI_calls\":%"PRIu64",\"thread_returned_bytes\":%"PRIu64",\"whole_returned_bytes\":%"PRIu64",\"independent_relations\":%"PRIu64",\"selected_cells\":%"PRIu64",\"preserved_inactive_bytes\":%"PRIu64",\"negative_zero_minima\":%"PRIu64",\"positive_zero_maxima\":%"PRIu64",\"differing_bytes\":0,\"FPCR\":0,\"profiling_only_disabled\":true}\n",record_count,call_count,thread_groups,thread_calls,thread_returned_bytes,returned_count,physical_relations,selected_cells,preserved_bytes,negative_zero_min,positive_zero_max);
 return 0;
}

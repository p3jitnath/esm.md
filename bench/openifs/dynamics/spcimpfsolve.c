/* Verify complete original and direct single-rank calls.
 * Geometry and descriptor setup supplies inputs, never numerical outputs.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <omp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
struct dim {int64_t stride,lower,upper;};
struct d1 {void*base;int64_t offset;uint64_t bytes,type;int64_t span;struct dim d;};
struct d2 {void*base;int64_t offset;uint64_t bytes,type;int64_t span;struct dim d[2];};
_Static_assert(sizeof(int32_t)==4&&sizeof(double)==8,"frozen scalar widths");
_Static_assert(sizeof(struct dim)==24&&sizeof(struct d1)==64&&sizeof(struct d2)==88,"frozen GNU descriptor sizes");
typedef void(*fn)(const void*,const void*,const void*,const int32_t*,const int32_t*,const int32_t*,const struct d2*,struct d2*);
typedef void(*leaf_fn)(const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const double*,const double*,const double*,const double*,const double*,double*,double*);
static FILE *stages,*source_stages,*native_stages,*native_outputs,*physics;
static uint64_t science_values,zero_values,parallel_calls;
static int native_dependency_mode;
extern uint64_t vertical_abi_call(void(*)(void*),void*);
extern void spcimpfsolve_abi_invoke(void*);
extern void spcimpfsolve_observed_assembly_(const void*,const void*,const void*,const int32_t*,const int32_t*,const int32_t*,const struct d2*,struct d2*);
extern void simplico_assembly_(const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const double*,const double*,const double*,const double*,const double*,double*,double*);
static uint64_t current_case,stage_calls;
static uint64_t fpcr(void){uint64_t v;__asm__ volatile("mrs %0,fpcr":"=r"(v));return v;}
static void fail(const char*s){fprintf(stderr,"SPCIMPFSOLVE critical FAIL %s\n",s);exit(2);}
/* Each declared allocation ends immediately before an inaccessible page. */
struct mapping {void *base;size_t total;};
static void *alloc(size_t n)
{
 size_t page=(size_t)sysconf(_SC_PAGESIZE),data=(n+16+page-1)/page*page,total=data+2*page;
 void *base=mmap(NULL,total,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(base==MAP_FAILED||mprotect((char*)base+page,data,PROT_READ|PROT_WRITE))fail("protected allocation");
 void*p=(char*)base+page+data-n;struct mapping m={base,total};memcpy((char*)p-16,&m,16);return p;
}
static void release(void*p)
{
 struct mapping m;memcpy(&m,(char*)p-16,16);if(munmap(m.base,m.total))fail("unmap");
}
static void read_only(void*p)
{
 struct mapping m;memcpy(&m,(char*)p-16,16);size_t page=(size_t)sysconf(_SC_PAGESIZE);
 if(mprotect((char*)m.base+page,m.total-2*page,PROT_READ))fail("read-only input");
}

static void set32(void*p,size_t k,int32_t v){memcpy((char*)p+k,&v,4);}
static void set64(void*p,size_t k,double v){memcpy((char*)p+k,&v,8);}
static void descriptor(void*p,size_t off,void*a,int lower,int upper,int bytes)
{
 struct d1 d={a,-lower,(uint64_t)bytes,bytes==4?UINT64_C(0x10100000000):UINT64_C(0x30100000000),bytes,{1,lower,upper}};
 memcpy((char*)p+off,&d,sizeof(d));
}
static size_t index_of(int row,int col,int rows,int cols,int style)
{
 size_t r=(size_t)row,c=(size_t)col;
 if(style&1)r=(size_t)(rows-1-row);
 if(style&2)c=(size_t)(cols-1-col);
 return c*rows+r;
}
static struct d2 view(double *a,int rows,int cols,int style)
{
 int64_t s0=(style&1)?-1:1,s1=((style&2)?-1:1)*(int64_t)rows;
 double*base=a+index_of(0,0,rows,cols,style);
 struct d2 d={base,-s0-s1,8,UINT64_C(0x30200000000),8,{{s0,1,rows},{s1,1,cols}}};
 return d;
}
static void same(const void*a,const void*b,size_t n,const char*s)
{
 if(!memcmp(a,b,n))return;
 const unsigned char*x=a,*y=b;size_t k=0;while(k<n&&x[k]==y[k])k++;
 size_t begin=k/8*8,word_bytes=n-begin<8?n-begin:8;uint64_t expected=0,actual=0;
 memcpy(&expected,x+begin,word_bytes);memcpy(&actual,y+begin,word_bytes);
 fprintf(stderr,"case=%"PRIu64" stage=%s first_byte=%zu physical_word=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",current_case,s,k,k/8,expected,actual);
 fail("complete raw bytes differ");
}
static void write_all(FILE*f,const void*p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("write");}
void simplico_(const int32_t*m,const int32_t*n,const int32_t*l,const int32_t*s,const double*a,const double*d,const double*p,const double*q,const double*v,const double*lap,const double*b2,double*y,double*x)
{
 static leaf_fn original;
 if(!original)original=(leaf_fn)dlsym(RTLD_NEXT,"simplico_");
 if(!original||!stages||fpcr())fail("source stage entry");
 size_t coefs=(size_t)(*n-*m+2),fields=(size_t)*s*2*(size_t)(*n-*m+1);
 unsigned char h[128]={0};memcpy(h,"SPCSST01",8);memcpy(h+8,&current_case,8);
 memcpy(h+16,m,4);memcpy(h+20,n,4);memcpy(h+24,l,4);memcpy(h+28,s,4);
 memcpy(h+40,&coefs,8);memcpy(h+48,&fields,8);memcpy(h+56,b2,8);
 write_all(stages,h,128);write_all(stages,a,coefs*8);write_all(stages,d,coefs*8);
 write_all(stages,p,coefs*8);write_all(stages,q,coefs*8);write_all(stages,v,(size_t)*l*8);
 write_all(stages,lap,(size_t)(*n+1)*8);write_all(stages,y,fields*8);
 if(native_dependency_mode)simplico_assembly_(m,n,l,s,a,d,p,q,v,lap,b2,y,x);
 else original(m,n,l,s,a,d,p,q,v,lap,b2,y,x);
 if(fpcr())fail("source stage return");
 int32_t after=1;memcpy(h+32,&after,4);
 write_all(stages,h,128);write_all(stages,y,fields*8);write_all(stages,x,fields*8);stage_calls++;
}
/* Observation-only trampoline forwards the complete accepted dependency. */
void spcimpfsolve_native_simplico_(const int32_t*m,const int32_t*n,const int32_t*l,const int32_t*s,const double*a,const double*d,const double*p,const double*q,const double*v,const double*lap,const double*b2,double*y,double*x)
{
 if(!native_dependency_mode)fail("native observer mode");
 simplico_(m,n,l,s,a,d,p,q,v,lap,b2,y,x);
}
int main(int argc,char**argv)
{
 if(argc!=8)fail("usage verifier INPUT SOURCE SOURCE_STAGES NATIVE NATIVE_STAGES SUMMARY INDEPENDENT");
 physics=fopen(argv[7],"rb");if(!physics)fail("independent corpus");
 unsigned char ph[64];if(fread(ph,1,64,physics)!=64||memcmp(ph,"SPCSIND1",8))fail("independent header");
 source_stages=fopen(argv[3],"wb");native_stages=fopen(argv[5],"wb");native_outputs=fopen(argv[4],"wb");
 stages=source_stages;
 if(!source_stages||!native_stages||!native_outputs)fail("stage files");
 fn source=(fn)dlsym(RTLD_DEFAULT,"spcimpfsolve_");if(!source)fail("source symbol");
 const char*inames[]={"__yommp0_MOD_nprtrn","__yommp0_MOD_nprtrv","__yomhook_MOD_lhook","__yomgstats_MOD_lstats"};
 for(int k=0;k<4;k++){int32_t*p=dlsym(RTLD_DEFAULT,inames[k]);if(!p)fail(inames[k]);*p=k<2?1:0;}
 double*omega=dlsym(RTLD_DEFAULT,"__yomcst_MOD_romega");if(!omega)fail("rotation symbol");
 FILE*inputs=fopen(argv[1],"wb"),*outputs=fopen(argv[2],"wb");if(!inputs||!outputs)fail("files");
 unsigned char h[64]={0};memcpy(h,"SPCSCR01",8);write_all(inputs,h,64);write_all(outputs,h,64);write_all(native_outputs,h,64);
 uint64_t calls=0,bytes=64,cells=0;
 int ns[]={1,2,3,7,21,255};
 for(int ni=0;ni<6;ni++)for(int profile=0;profile<(ni==5?1:13);profile++){
  int n=ns[ni],l=profile==0?0:profile==1?1:profile==11?19:3,cols=(n+1)*(n+2),nump=n+1;
  int pad=profile>=8?3:0,rows=l+pad,style=profile>=8?profile-8:0;
  size_t count=(size_t)rows*cols,full=count+16;
  unsigned char *g=alloc(17096),*rip=alloc(175976),*dyn=alloc(4720);
  memset(g,0,17096);memset(rip,0,175976);memset(dyn,0,4720);
  int32_t *myms=alloc((nump+1)*4),*nasm=alloc((n+1)*4),*levels=alloc(l*4);
  double*lap=alloc((n+4)*8),*siv=alloc(l*8),*raw=alloc(full*8),*out=alloc(full*8);
  if(!g||!rip||!dyn)fail("object allocation");
  set32(g,5172,n);set32(g,5200,cols);set32(g,5212,nump);set32(g,5224,l);set32(g,5228,l);set32(g,5236,l);
  for(int j=0;j<=nump;j++)myms[j]=j?j-1:0;
  if(profile==7)for(int j=1;j<=nump;j++)myms[j]=nump-j;
  for(int j=0;j<=n;j++)nasm[j]=1+j*(2*n+3-j);
  for(int j=0;j<l;j++)levels[j]=profile==6?l-j:j+1;
  for(int j=-1;j<=n+2;j++)lap[j+1]=-(double)(j*(j+1))/(6371229.0*6371229.0);
  for(int j=0;j<l;j++)siv[j]=profile==5?0.0:10000.0+(1000000.0-10000.0)*(j+1)/(l+1);
  double dt=profile==2?0.0:profile==4?-1800.0:3600.0,beta=profile==3?0.0:0.5,stretch=profile==6?1.125:1.0;
  *omega=7.292115083046062e-5;
  set64(rip,208,dt);set64(dyn,2488,beta);set64(g,7512,stretch);
  int ms_lower=profile==12?1:0;
  descriptor(g,3912,myms+ms_lower,ms_lower,nump,4);descriptor(g,3720,nasm,0,n,4);descriptor(g,5960,levels,1,l,4);
  descriptor(g,4104,lap,-1,n+2,8);descriptor(dyn,3312,siv,1,l,8);
  for(size_t i=0;i<full;i++){raw[i]=-777.125;out[i]=888.25;}
  for(int col=0;col<cols;col++)for(int row=0;row<rows;row++){
   size_t pos=index_of(row,col,rows,cols,style)+8;
   raw[pos]=row>=l?nan("0x7654"):(double)(((col*7+row*13+profile*19)%31)-15)/65536.0;
   out[pos]=(double)(-100-col*2-row)/8192.0;
   if(profile==10&&row<l)raw[pos]*=0x1p-1022;
  }
  struct d2 rhs=view(raw+8,rows,cols,style),result=view(out+8,rows,cols,style);
  int32_t flags[3]={profile&1,(profile>>1)&1,(profile>>2)&1};
  unsigned char scalars[160]={0};memcpy(scalars,"SPCSCASE",8);
  uint64_t cid=++calls;current_case=cid;memcpy(scalars+8,&cid,8);
  int32_t shape[8]={n,l,rows,cols,style,profile,nump,pad};memcpy(scalars+16,shape,32);
  memcpy(scalars+48,&dt,8);memcpy(scalars+56,&beta,8);memcpy(scalars+64,&stretch,8);memcpy(scalars+72,omega,8);
  memcpy(scalars+80,flags,12);memcpy(scalars+96,&count,8);memcpy(scalars+104,&ms_lower,4);
  write_all(inputs,scalars,160);write_all(inputs,myms,(nump+1)*4);write_all(inputs,nasm,(n+1)*4);
  write_all(inputs,levels,l*4);write_all(inputs,lap,(n+4)*8);write_all(inputs,siv,l*8);
  write_all(inputs,raw,full*8);write_all(inputs,out,full*8);
  unsigned char *gs=alloc(17096),*rs=alloc(175976),*ds=alloc(4720);memcpy(gs,g,17096);memcpy(rs,rip,175976);memcpy(ds,dyn,4720);
  double*is=alloc(full*8);memcpy(is,raw,full*8);struct d2 rhs_before=rhs,result_before=result;
  double *native_out=alloc(full*8),*observed_out=alloc(full*8),*incoming_out=alloc(full*8);
  memcpy(native_out,out,full*8);memcpy(observed_out,out,full*8);memcpy(incoming_out,out,full*8);
  void *immutable[5]={myms,nasm,levels,lap,siv},*immutable_before[5];
  size_t immutable_bytes[5]={(size_t)(nump+1)*4,(size_t)(n+1)*4,(size_t)l*4,(size_t)(n+4)*8,(size_t)l*8};
  for(int k=0;k<5;k++){immutable_before[k]=alloc(immutable_bytes[k]);memcpy(immutable_before[k],immutable[k],immutable_bytes[k]);}
  unsigned char truth_header[160];double *truth=alloc(full*8),*limits=alloc(full*8);
  if(fread(truth_header,1,160,physics)!=160||memcmp(truth_header,scalars,160)||
     fread(truth,8,full,physics)!=full||fread(limits,8,full,physics)!=full)fail("frozen independent record");
  int32_t saved_flags[3]={flags[0],flags[1],flags[2]};double saved_omega=*omega;
  read_only(g);read_only(rip);read_only(dyn);read_only(raw);
  for(int k=0;k<5;k++)read_only(immutable[k]);
  if(fpcr())fail("entry FPCR");
  stages=source_stages;native_dependency_mode=0;
  source(g,rip,dyn,flags,flags+1,flags+2,&rhs,&result);
  struct d2 native_view=view(native_out+8,rows,cols,style),observed_view=view(observed_out+8,rows,cols,style);
  void *args[8]={g,rip,dyn,flags,flags+1,flags+2,&rhs,&native_view};
  if(vertical_abi_call(spcimpfsolve_abi_invoke,args))fail("direct primary ABI/FPCR");
  same(native_out,out,full*8,"complete primary output");
  stages=native_stages;native_dependency_mode=1;
  spcimpfsolve_observed_assembly_(g,rip,dyn,flags,flags+1,flags+2,&rhs,&observed_view);
  same(observed_out,out,full*8,"complete observed output");
  for(int col=0;col<cols;col++)for(int row=0;row<l;row++){
   size_t pos=index_of(row,col,rows,cols,style)+8;
   if(!isfinite(native_out[pos])||fabs(native_out[pos]-truth[pos])>limits[pos])fail("independent dense solution");
   if(col<2*(n+1)&&(col&1)){
    uint64_t bits;memcpy(&bits,native_out+pos,8);if(bits)fail("positive-zero imaginary mode");zero_values++;
   }else science_values++;
  }
  if(n==21&&profile==11){
   int threads_seen=0;
   #pragma omp parallel num_threads(3) shared(threads_seen)
   {
    if(omp_get_thread_num()==0)threads_seen=omp_get_num_threads();
    double *concurrent=alloc(full*8);memcpy(concurrent,incoming_out,full*8);
    struct d2 concurrent_view=view(concurrent+8,rows,cols,style);
    void *thread_args[8]={g,rip,dyn,flags,flags+1,flags+2,&rhs,&concurrent_view};
    if(vertical_abi_call(spcimpfsolve_abi_invoke,thread_args))fail("concurrent direct ABI/FPCR");
    same(concurrent,out,full*8,"genuine concurrent full output");release(concurrent);
   }
   if(threads_seen!=3)fail("genuine thread team");
   parallel_calls+=3;
  }
  same(saved_flags,flags,12,"logical flags mutation");same(&saved_omega,omega,8,"rotation constant mutation");
  if(fpcr())fail("return FPCR");
  same(gs,g,17096,"geometry mutation");same(rs,rip,175976,"rip mutation");same(ds,dyn,4720,"dyn mutation");
  same(is,raw,full*8,"rhs mutation");
  for(int k=0;k<5;k++)same(immutable_before[k],immutable[k],immutable_bytes[k],"derived allocation mutation");
  same(&rhs,&rhs_before,88,"rhs descriptor mutation");same(&result,&result_before,88,"output descriptor mutation");
  for(int j=0;j<8;j++)if(out[j]!=888.25||out[full-1-j]!=888.25)fail("output guard");
  for(int col=0;col<cols;col++)for(int row=l;row<rows;row++){
   size_t pos=index_of(row,col,rows,cols,style)+8;
   if(out[pos]!=(double)(-100-col*2-row)/8192.0)fail("inactive output mutation");
  }
  write_all(outputs,scalars,160);write_all(outputs,out,full*8);
  write_all(native_outputs,scalars,160);write_all(native_outputs,native_out,full*8);
  bytes+=160+full*8;cells+=(uint64_t)l*cols;
  for(int k=0;k<5;k++)release(immutable_before[k]);
  release(native_out);release(observed_out);release(incoming_out);release(truth);release(limits);
  release(gs);release(rs);release(ds);release(is);release(g);release(rip);release(dyn);release(myms);release(nasm);release(levels);release(lap);release(siv);release(raw);release(out);
 }
 if(fgetc(physics)!=EOF)fail("independent trailing records");
 fclose(physics);fclose(inputs);fclose(outputs);fclose(source_stages);fclose(native_stages);fclose(native_outputs);
 FILE*summary=fopen(argv[6],"w");if(!summary)fail("summary file");
 fprintf(summary,"{\"cases\":%"PRIu64",\"direct_abi_cases\":%"PRIu64",\"protected_tail_cases\":%"PRIu64",\"genuine_three_thread_calls\":%"PRIu64",\"independent_values\":%"PRIu64",\"positive_zero_values\":%"PRIu64",\"stage_calls_each\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"active_cells\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0}\n",calls,calls+parallel_calls,calls,parallel_calls,science_values,zero_values,stage_calls/2,bytes,cells);
 fclose(summary);
 printf("SOURCE/NATIVE STAGES PASS calls=%"PRIu64"\n",stage_calls);
 printf("NATIVE PASS cases=%"PRIu64" output_bytes=%"PRIu64" active_cells=%"PRIu64" FPCR=0\n",calls,bytes,cells);
 return 0;
}

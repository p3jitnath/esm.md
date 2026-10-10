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

static kernel original;
static const int32_t *phase;
static const void *source_image;
extern void laminmaxint_md2asm(PARAMETERS);
static FILE *inputs,*source,*assembly;
static uint64_t calls,returned_bytes,input_bytes,maximum_calls,minimum_only_calls,phase_calls[25];
static uintptr_t sites[8];static char site_names[8][32];static unsigned site_count;
__attribute__((destructor)) static void finish(void){
 if(!source)return;
 if(fclose(inputs)||fclose(source)||fclose(assembly)||!calls)fail("complete source capture close");
 FILE *m=fopen("laminmaxint-metadata.json","wx");if(!m)fail("metadata record");
 fprintf(m,"{\"calls\":%"PRIu64",\"complete_returned_bytes\":%"PRIu64",\"complete_input_bytes\":%"PRIu64",\"maximum_present_calls\":%"PRIu64",\"minimum_only_calls\":%"PRIu64",\"selected_cells\":%"PRIu64",\"independent_relations\":%"PRIu64",\"preserved_inactive_bytes\":%"PRIu64",\"negative_zero_minima\":%"PRIu64",\"positive_zero_maxima\":%"PRIu64",\"FPCR\":0,\"all_inputs_readonly\":true,\"primary_emitted\":true,\"same_input_complete_source_native_bytes_equal\":true,\"original_sites\":[",calls,returned_bytes,input_bytes,maximum_calls,minimum_only_calls,selected_cells,physical_relations,preserved_bytes,negative_zero_min,positive_zero_max);
 for(unsigned z=0;z<site_count;++z)fprintf(m,"%s{\"caller\":\"%s\",\"return_offset\":\"0x%lx\"}",z?",":"",site_names[z],(unsigned long)sites[z]);
 fputs("],\"phase_calls\":[",m);for(int z=0;z<25;++z)fprintf(m,"%s%"PRIu64,z?",":"",phase_calls[z]);fputs("]}\n",m);
 if(fclose(m))fail("metadata close");
 fprintf(stderr,"LAMINMAXINT full paired PASS calls=%"PRIu64" returned_bytes=%"PRIu64" independent=%"PRIu64"\n",calls,returned_bytes,physical_relations);
}
void laminmaxint_(PARAMETERS){
 if(fpcr())fail("entry FPCR");
 if(!original){
  void *p=dlsym(RTLD_NEXT,"laminmaxint_");if(!p)fail("unchanged original leaf");memcpy(&original,&p,sizeof original);
  Dl_info info={0};if(!dladdr(p,&info)||!info.dli_fbase)fail("original image");source_image=info.dli_fbase;
  phase=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");if(!phase)fail("original phase");
  inputs=fopen("laminmaxint-inputs.bin","wx");source=fopen("laminmaxint-fortran.bin","wx");assembly=fopen("laminmaxint-assembly.bin","wx");if(!inputs||!source||!assembly)fail("unique complete streams");
  if(setvbuf(inputs,NULL,_IOFBF,1<<20)||setvbuf(source,NULL,_IOFBF,1<<20)||setvbuf(assembly,NULL,_IOFBF,1<<20))fail("capture buffers");
 }
 Dl_info caller={0};void *ret=__builtin_return_address(0);
 int found=dladdr(ret,&caller);
 uintptr_t off=(uintptr_t)ret-(uintptr_t)source_image;
 /* The original caller is a local OpenMP function absent from the dynamic
  * symbol table. Its exact return site is independently resolved from the
  * immutable full symbol table and original source line396. */
 if(!found||caller.dli_fbase!=source_image||off!=UINT64_C(0x275dcc)||*phase<0||*phase>24)fail("frozen original QMFIXER local-call site and phase");
 const char *name="qmfixer_._omp_fn.6";
 unsigned site=0;
 if(!site_count){sites[0]=off;strcpy(site_names[0],name);site_count=1;}
 diagnostic_call=calls;diagnostic_phase=*phase;diagnostic_stage="forecast source-domain guard";diagnostic_origin=0;diagnostic_width=8;
 void *a[11]={ARGUMENTS};int32_t d[7];for(int z=0;z<7;++z){if(!a[z]||(uintptr_t)a[z]%4)fail("scalar alignment");memcpy(d+z,a[z],4);}
 size_t sizes[11];
 if(!calls)fprintf(stderr,"LAMINMAXINT original first shape A=%d B=%d start=%d end=%d levels=%d first_field=%d last_field=%d maximum=%d\n",d[0],d[1],d[2],d[3],d[4],d[5],d[6],a10?1:0);
 domain(d,a,sizes);
 unsigned char *snap[11]={0};for(int z=0;z<11;++z)if(sizes[z]){snap[z]=malloc(sizes[z]);if(!snap[z])fail("whole original snapshots");memcpy(snap[z],a[z],sizes[z]);}
 /* Header is64 bytes. Presence is a canonical integer0 or1, not an extra
  * source argument. Keep the original full shape and caller identity. */
 uint64_t header[2]={calls,off};int32_t meta[12]={*phase,(int32_t)site,a10?1:0,d[0],d[1],d[2],d[3],d[4],d[5],d[6],0,0};
 for(int z=0;z<3;++z){FILE *f=z==0?inputs:z==1?source:assembly;writeall(f,header,16);writeall(f,meta,48);}
 for(int z=7;z<11;++z)writeall(inputs,snap[z],sizes[z]);
 diagnostic_stage="forecast original complete leaf";
 original(ARGUMENTS);
 if(fpcr())fail("original preserved FPCR");
 for(int z=0;z<9;++z){diagnostic_width=z<8?4:8;same(snap[z],a[z],sizes[z],"complete readonly original input");}
 const unsigned char *before[2]={snap[9],snap[10]};const double *out[2]={a9,a10};physics(d,a,before,out);
 writeall(source,a9,sizes[9]);writeall(source,a10,sizes[10]);
 unsigned char *reference[2]={0};
 for(int z=0;z<2;++z)if(sizes[z+9]){reference[z]=malloc(sizes[z+9]);if(!reference[z])fail("whole original returned snapshots");memcpy(reference[z],a[z+9],sizes[z+9]);memcpy(a[z+9],snap[z+9],sizes[z+9]);}
 diagnostic_stage="forecast native complete leaf";diagnostic_origin=0;diagnostic_width=8;
 laminmaxint_md2asm(ARGUMENTS);
 if(fpcr())fail("native preserved FPCR");
 for(int z=0;z<9;++z){diagnostic_width=z<8?4:8;same(snap[z],a[z],sizes[z],"complete readonly native input");}
 physics(d,a,before,out);diagnostic_origin=0;diagnostic_width=8;
 same(reference[0],a9,sizes[9],"whole source/native minimum");same(reference[1],a10,sizes[10],"whole source/native maximum");
 writeall(assembly,a9,sizes[9]);writeall(assembly,a10,sizes[10]);
 for(int z=0;z<2;++z)free(reference[z]);
 input_bytes+=64+sizes[7]+sizes[8]+sizes[9]+sizes[10];returned_bytes+=64+sizes[9]+sizes[10];
 if(a10)++maximum_calls;else ++minimum_only_calls;
 ++phase_calls[*phase];++calls;
 for(int z=0;z<11;++z)free(snap[z]);
}

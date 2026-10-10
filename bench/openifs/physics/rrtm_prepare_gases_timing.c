/* Compare complete gas calls on the same frozen physical arrays.
 * Pressures are Pa, temperatures K, gas ratios kg/kg and returned columns
 * molecules/cm2. Scalar and paired-zero probes describe zero-stage costs.
 * All allocation, poison restoration, input checks and physics are untimed. */
#define main frozen_critical_main
#include "rrtm_prepare_gases.c"
#undef main
#include <time.h>
#include <sys/resource.h>
#include <sched.h>
extern void rrtm_prepare_gases_paired_zero_(PARAMETERS);
extern void rrtm_prepare_gases_paired_columns_(PARAMETERS);
struct sample {
 unsigned char *input,*expected;
 void *arg[27];
 size_t bytes[27];
 double global[2];
 int32_t dims[4];
 uint64_t sequence;
 int32_t phase;
};
static struct sample samples[4];
static kernel variants[]={rrtm_prepare_gases_,rrtm_prepare_gases_paired_zero_,rrtm_prepare_gases_paired_columns_};
static const char *names[]={"source","paired-zero-assembly","paired-column-assembly"};
static uint64_t time_ns(void){struct timespec t;if(clock_gettime(CLOCK_MONOTONIC_RAW,&t))fail("clock");return (uint64_t)t.tv_sec*1000000000ULL+t.tv_nsec;}
static uint64_t control(void){uint64_t r;__asm__ volatile("mrs %0,fpcr":"=r"(r));return r;}
static void *aligned(size_t n){void *p=NULL;if(posix_memalign(&p,64,n?n:64))fail("aligned complete allocation");return p;}
static void reset(struct sample *s){
 __yomcst_MOD_rg=s->global[0];__yomdyncore_MOD_rplrg=s->global[1];
 for(int k=18;k<27;++k)memset(s->arg[k],0xa5,s->bytes[k]);
}
static void invoke(kernel fn,struct sample *s){fn(PASS(s->arg));}
static void verify(struct sample *s){
 if(control())fail("FPCR zero");
 if(memcmp(&__yomcst_MOD_rg,s->global,8)||memcmp(&__yomdyncore_MOD_rplrg,s->global+1,8))fail("timed immutable gravity");
 for(int k=0;k<4;++k)if(memcmp(s->arg[k],s->dims+k,4))fail("timed immutable dimensions");
 const unsigned char *p=s->input+48;
 for(int k=4;k<18;++k){if(memcmp(p,s->arg[k],s->bytes[k]))fail("timed whole immutable input");p+=s->bytes[k];}
 p=s->expected+48;
 for(int k=18;k<27;++k){
  if(memcmp(p,s->arg[k],s->bytes[k])){
   const unsigned char *v=s->arg[k];size_t first=0;while(p[first]==v[first])++first;
   fprintf(stderr,"sequence=%" PRIu64 " field=%d byte=%zu source=%02x native=%02x\n",s->sequence,k-17,first,p[first],v[first]);fail("complete timed final bytes");
  }p+=s->bytes[k];
 }
 const double *in[14],*out[8];for(int k=0;k<14;++k)in[k]=s->arg[k+4];for(int k=0;k<8;++k)out[k]=s->arg[k+18];
 calls=s->sequence;science(s->dims,in,out,s->arg[26],s->global[0],s->global[1]);
}
static void load(const char *path){
 FILE *f=fopen(path,"rb");if(!f)fail("timing corpus");
 char tag[8];uint32_t n,size;readall(f,tag,8);readall(f,&n,4);readall(f,&size,4);
 if(memcmp(tag,"GASTIME1",8)||n!=4||size!=72128)fail("timing frozen header");
 for(int z=0;z<4;++z){
  struct sample *s=samples+z;s->input=aligned(17200);s->expected=aligned(54928);
  readall(f,s->input,17200);readall(f,s->expected,54928);
  if(memcmp(s->input,s->expected,48))fail("whole record identity");
  memcpy(&s->sequence,s->input,8);memcpy(&s->phase,s->input+8,4);memcpy(s->dims,s->input+16,16);memcpy(s->global,s->input+32,16);
  if(s->dims[0]!=1||s->dims[1]!=8||s->dims[2]!=8||s->dims[3]!=19)fail("declared full forecast shape");
  const size_t outputs[9]={152,152,5320,608,152,152,160,160,8};
  for(int k=0;k<4;++k)s->bytes[k]=4;
  for(int k=4;k<18;++k)s->bytes[k]=(size_t)8*(19+(k==4||k==6))*8;
  for(int k=18;k<27;++k)s->bytes[k]=outputs[k-18]*(k==26?4:8);
  for(int k=0;k<27;++k)s->arg[k]=aligned(s->bytes[k]);
  for(int k=0;k<4;++k)memcpy(s->arg[k],s->dims+k,4);
  const unsigned char *p=s->input+48;for(int k=4;k<18;++k){memcpy(s->arg[k],p,s->bytes[k]);p+=s->bytes[k];}
  for(int k=0;k<3;++k){reset(s);invoke(variants[k],s);verify(s);}
  printf("{\"kind\":\"placement\",\"workload\":%d,\"phase\":%d,\"sequence\":%" PRIu64 ",\"input_address\":\"%p\",\"output_address\":\"%p\",\"alignment\":64,\"input_payload_bytes\":17152,\"output_payload_bytes\":54880}\n",z,s->phase,s->sequence,s->arg[4],s->arg[20]);
 }
 if(fgetc(f)!=EOF||fclose(f))fail("complete timing corpus");
}
static void zero_scalar(void *ptr,size_t count){
 __asm__ volatile("cbz %[n],2f\n1:str xzr,[%[p]],#8\nsubs %[n],%[n],#1\nb.ne 1b\n2:"
  :[p]"+r"(ptr),[n]"+r"(count)::"memory","cc");
}
static void zero_pair(void *ptr,size_t count){
 __asm__ volatile("movi v0.2d,#0\ncmp %[n],#4\nb.lo 2f\n1:stp q0,q0,[%[p]],#32\nsub %[n],%[n],#4\ncmp %[n],#4\nb.hs 1b\n2:cbz %[n],4f\n3:str xzr,[%[p]],#8\nsubs %[n],%[n],#1\nb.ne 3b\n4:"
  :[p]"+r"(ptr),[n]"+r"(count)::"v0","memory","cc");
}
static void probe(struct sample *s,int variant){
 void (*zero)(void*,size_t)=variant?zero_pair:zero_scalar;
 zero(s->arg[20],s->bytes[20]/8);zero(s->arg[21],s->bytes[21]/8);
}
static void verify_probe(struct sample *s){
 for(int k=20;k<=21;++k){unsigned char *p=s->arg[k];for(size_t i=0;i<s->bytes[k];++i)if(p[i])fail("whole positive-zero component");}
 if(control())fail("component FPCR");
}
int main(int argc,char **argv){
 if(argc!=2)fail("arguments complete frozen corpus");
 if(sched_getcpu()!=8||control())fail("CPU8 and FPCR0 required");
 __yomhook_MOD_lhook=0;load(argv[1]);
 for(int w=0;w<4;++w)for(int component=0;component<2;++component){
  struct sample *s=samples+w;int accepted=0,attempt=0,n=component?2:3;
  while(accepted<12){
   if(attempt==120)fail("too many disturbed rotations");
   double elapsed[3]={0};long switches[3]={0};int order[3]={0},bad=0;
   for(int pos=0;pos<n;++pos){
    const int v=(attempt+pos)%n;order[pos]=v;reset(s);
    for(int warm=0;warm<32;++warm){if(component)probe(s,v);else invoke(variants[v],s);}
    if(component)verify_probe(s);else verify(s);
    struct rusage before,after;if(getrusage(RUSAGE_THREAD,&before))fail("context before");
    uint64_t total=0;
    for(int call=0;call<256;++call){
     const uint64_t start=time_ns();if(component)probe(s,v);else invoke(variants[v],s);total+=time_ns()-start;
    }
    if(getrusage(RUSAGE_THREAD,&after))fail("context after");
    switches[v]=(after.ru_nvcsw-before.ru_nvcsw)+(after.ru_nivcsw-before.ru_nivcsw);if(switches[v])bad=1;
    elapsed[v]=(double)total/256;
    if(component)verify_probe(s);else verify(s);
   }
   for(int pos=0;pos<n;++pos){
    const int v=order[pos];
    printf("{\"kind\":\"%s\",\"workload\":%d,\"sequence\":%" PRIu64 ",\"phase\":%d,\"selected_columns\":8,\"levels\":19,\"repeat\":%d,\"attempt\":%d,\"order\":%d,\"variant\":\"%s\",\"ns_per_call\":%.9f,\"calls\":256,\"context_switches\":%ld,\"rotation_rejected\":%s,\"fpcr\":0}\n",component?"zero-component":"timing",w,s->sequence,s->phase,accepted,attempt,pos,component?(v?"paired-zero-stores":"scalar-zero-stores"):names[v],elapsed[v],switches[v],bad?"true":"false");
   }
   ++attempt;if(!bad)++accepted;
  }
 }
 puts("{\"kind\":\"completed\",\"all_timed_final_states_verified\":true,\"all_complete_rotations_retained\":true,\"fpcr\":0}");
 return 0;
}

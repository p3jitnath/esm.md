/* Compare complete CPQTUV outputs from its declared EC_PHYS_DRV caller.
 * Earlier tracers use NDIM; new tracers and dynamics rates use NDIM1.
 * All captured arrays retain their full incoming and returned bytes. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CPQTUV_ARGS const void *e,const void *g,const int32_t *np,const int32_t *ks, \
 const int32_t *ke,const int32_t *nl,const double *dt,const int32_t *dry, \
 const double *u9,const double *v9,const double *t9,double *old,const double *dyn, \
 const double *conv,double *u,double *v,double *t,double *q
typedef void (*kernel)(CPQTUV_ARGS);
void cpqtuv_assembly_(CPQTUV_ARGS);
static kernel reference;
static const int32_t *step;
static const void *caller_image;
static const double *lv,*ls;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,mass_calls,continuity_calls,partial_calls;
static uint64_t masks[64],steps[25];
static int32_t first_ndim,first_ndim1,first_num;
static const size_t slots[7]={799840,799856,799848,799920,799912,799984,801104};
static void fail(const char *s) {fprintf(stderr,"CPQTUV forecast check failed %s\n",s);_Exit(2);}
static int32_t integer(const void *p,size_t o) {int32_t v;memcpy(&v,(const char *)p+o,4);return v;}
static double value(const void *p,size_t o) {double v;memcpy(&v,(const char *)p+o,8);return v;}
static uint64_t bits(double v) {uint64_t b;memcpy(&b,&v,8);return b;}
static void writeall(FILE *f,const void *p,size_t n) {if(n && fwrite(p,1,n,f)!=n)fail("capture write");}
static int overlap(const void *a,size_t na,const void *b,size_t nb) {
 uintptr_t pa=(uintptr_t)a,pb=(uintptr_t)b;
 if(pa>UINTPTR_MAX-na||pb>UINTPTR_MAX-nb)fail("address overflow");
 return na && nb && pa<pb+nb && pb<pa+na;
}
static void valid_compact(int32_t f,int32_t nd) {if(f<1||f>nd)fail("named compact index");}
__attribute__((destructor)) static void finish(void) {
 if(!ao)return;
 if(fclose(ao)||fclose(ro)||fclose(io))fail("capture close");
 fprintf(stderr,"CPQTUV FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 continuity_calls=%" PRIu64 " water_mass_calls=%" PRIu64 " partial_calls=%" PRIu64 " NDIM=%d NDIM1=%d NUMFLDS=%d FPCR=%016" PRIx64 "\n",calls,bytes,continuity_calls,mass_calls,partial_calls,first_ndim,first_ndim1,first_num,last_fpcr);
 FILE *f=fopen("cpqtuv-call-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"NDIM\":%d,\"NDIM1\":%d,\"NUMFLDS\":%d,\"continuity_calls\":%" PRIu64 ",\"water_mass_calls\":%" PRIu64 ",\"partial_calls\":%" PRIu64 ",\"step_calls\":[",calls,first_ndim,first_ndim1,first_num,continuity_calls,mass_calls,partial_calls);
 for(int i=0;i<25;++i)fprintf(f,"%s%" PRIu64,i?",":"",steps[i]);
 fputs("],\"special_LT1_mask_calls\":[",f);for(int i=0;i<64;++i)fprintf(f,"%s%" PRIu64,i?",":"",masks[i]);
 fputs("],\"supported_caller\":\"EC_PHYS_DRV\",\"differing_bytes\":0}\n",f);if(fclose(f))fail("metadata close");
}
void cpqtuv_(CPQTUV_ARGS) {
 __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
 if(last_fpcr)fail("FPCR must be zero");
 Dl_info caller={0};
 if(!caller_image) {
  Dl_info source={0};void *symbol=dlsym(RTLD_NEXT,"ec_phys_drv_");
  if(!symbol||!dladdr(symbol,&source)||!source.dli_fbase)fail("source caller image");
  caller_image=source.dli_fbase;
 }
 if(!dladdr(__builtin_return_address(0),&caller)||!caller.dli_fbase||caller.dli_fbase!=caller_image)fail("undeclared caller library");
 /* These symbol ranges are storage metadata from the frozen strict ELF.
  * Source EC_PHYS_DRV supplies the same declared arrays inside its workers. */
 const uintptr_t begin[5]={0x7370c4,0x736da0,0x732f60,0x7332e8,0x736a20};
 const uintptr_t length[5]={0x214c,0x324,0x388,0x3738,0x378};
 uintptr_t address=(uintptr_t)__builtin_return_address(0)-(uintptr_t)caller.dli_fbase;
 int caller_body=-1;
 for(int f=0;f<5;++f)if(address>=begin[f]&&address<begin[f]+length[f])caller_body=f;
 if(caller_body<0) {fprintf(stderr,"CPQTUV undeclared caller offset=%" PRIxPTR " name=%s\n",address,caller.dli_sname?caller.dli_sname:"unknown");fail("undeclared caller capacity");}
 if(!calls)fprintf(stderr,"CPQTUV declared caller EC_PHYS_DRV symbol_range=%d return_offset=%" PRIxPTR "\n",caller_body,address);
 if(!e||!g||!np||!ks||!ke||!nl||!dt||!dry)fail("configuration pointers");
 int32_t ndim=integer(g,48),ndim1=integer(g,64),num=integer(g,0);
 if(*np<=0||*nl<0||*ks<1||*ks>*np||*ke<*ks-1||*ke>*np||ndim<0||ndim1<0||num<0||num>2163||!isfinite(*dt)||*dt<=0)fail("shape or interval");
 if((size_t)*np>(size_t)INT64_MAX/8/(*nl?(size_t)*nl:1))fail("cell extent");
 size_t cells=(size_t)*np*(size_t)*nl,size=cells*8;
 if((ndim&&cells>(size_t)INT64_MAX/8/(size_t)ndim)||(ndim1&&cells>(size_t)INT64_MAX/8/(size_t)ndim1))fail("field extent");
 if(!reference) {
  void *sym=dlsym(RTLD_NEXT,"cpqtuv_");if(!sym)fail("source routine");memcpy(&reference,&sym,sizeof reference);
  step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");lv=dlsym(RTLD_NEXT,"__yoethf_MOD_ralvdcp");ls=dlsym(RTLD_NEXT,"__yoethf_MOD_ralsdcp");
  if(!step||!lv||!ls)fail("module inputs");
  ao=fopen("cpqtuv-assembly.bin","wb");ro=fopen("cpqtuv-fortran.bin","wb");io=fopen("cpqtuv-inputs.bin","wb");
  if(!ao||!ro||!io)fail("capture open");
  first_ndim=ndim;first_ndim1=ndim1;first_num=num;
 }
 if(ndim!=first_ndim||ndim1!=first_ndim1||num!=first_num)fail("undeclared varying field capacity");
 if(*step<0||*step>24)fail("undeclared forecast step");
 int32_t *maps=malloc((size_t)(num?num:1)*20),named[7][5];
 const void *objects[7];unsigned char saved_objects[7][368];
 if(!maps)fail("descriptor copy");
 for(int32_t d=0;d<num;++d) {
  const char *p=(const char *)g+3848+(size_t)d*368;
  maps[5*d]=integer(p,64);maps[5*d+1]=integer(p,92);maps[5*d+2]=integer(p,168);maps[5*d+3]=integer(p,188);maps[5*d+4]=integer(p,184);
  if(maps[5*d+1]&&(maps[5*d+3]<1||maps[5*d+3]>ndim1||maps[5*d+4]<1||maps[5*d+4]>ndim))fail("selected tracer bounds");
 }
 int mask=0;
 for(int f=0;f<7;++f) {
  memcpy(&objects[f],(const char *)g+slots[f],8);if(!objects[f]||((uintptr_t)objects[f]&7))fail("named component pointer");
  const void *p=objects[f];named[f][0]=integer(p,64);named[f][1]=integer(p,92);named[f][2]=integer(p,168);named[f][3]=integer(p,188);named[f][4]=integer(p,184);
  memcpy(saved_objects[f],p,368);if(f<6 && named[f][1])mask|=1<<f;
  if(f<6 && named[f][1])valid_compact(named[f][3],ndim1);
 }
 int mass=*dry && named[6][0];for(int f=0;f<5;++f)mass=mass && named[f][0];
 if(mask&30)valid_compact(named[0][3],ndim1);
 if(named[6][0]&&(named[6][2]<1||named[6][2]>ndim))fail("continuity full-buffer index");
 if(mass)for(int f=0;f<5;++f) {
  valid_compact(named[f][3],ndim1);
  if(named[f][4]<1||named[f][4]>ndim)fail("water earlier index");
  if(named[f][4]==named[6][2])fail("continuity aliases earlier water");
 }
 double *out[5]={u,v,t,q,old},*shadow[5];
 const double *in[5]={u9,v9,t9,dyn,conv};void *copies[5];
 size_t sizes[5]={size,size,size,size*(size_t)ndim1,size*(size_t)ndim};
 size_t insizes[5]={size,size,size,size*(size_t)ndim1,size};
 void *g_before=malloc(1359136);unsigned char e_before[2776];
 if(!g_before)fail("configuration copy");
 memcpy(g_before,g,1359136);memcpy(e_before,e,2776);
 for(int f=0;f<5;++f) {
  if(sizes[f]&&(!out[f]||((uintptr_t)out[f]&7)))fail("output storage");
  if(overlap(out[f],sizes[f],e,2776)||overlap(out[f],sizes[f],g,1359136))fail("output overlaps configuration");
  for(int d=0;d<f;++d)if(overlap(out[f],sizes[f],out[d],sizes[d]))fail("outputs overlap");
  shadow[f]=malloc(sizes[f]?sizes[f]:8);if(!shadow[f])fail("output copy");if(sizes[f])memcpy(shadow[f],out[f],sizes[f]);
  if(insizes[f]&&(!in[f]||((uintptr_t)in[f]&7)))fail("input storage");
  for(int d=0;d<5;++d)if(overlap(in[f],insizes[f],out[d],sizes[d]))fail("output overlaps read-only input");
  copies[f]=malloc(insizes[f]?insizes[f]:8);if(!copies[f])fail("input copy");if(insizes[f])memcpy(copies[f],in[f],insizes[f]);
 }
 int32_t h[12]={0,0,*np,*ks,*ke,*nl,ndim,ndim1,num,*dry,0,-1};
 double constants[5]={*dt,value(e,112),value(e,120),*lv,*ls};
 for(int f=0;f<5;++f)if(!isfinite(constants[f]))fail("nonfinite constant");
 if(constants[1]<0||constants[2]<0)fail("negative threshold");
 ++calls;steps[*step]++;masks[mask]++;if(mass)mass_calls++;if(named[6][0])continuity_calls++;if(*ks!=1||*ke!=*np)partial_calls++;
 for(int f=0;f<3;++f) {
  FILE *file=f==0?ao:f==1?ro:io;
  writeall(file,&calls,8);writeall(file,step,4);writeall(file,h,48);writeall(file,constants,40);
  writeall(file,maps,(size_t)num*20);writeall(file,named,140);
 }
 for(int f=0;f<5;++f)writeall(io,out[f],sizes[f]);
 for(int f=0;f<5;++f)writeall(io,in[f],insizes[f]);
 reference(e,g,np,ks,ke,nl,dt,dry,u9,v9,t9,shadow[4],dyn,conv,shadow[0],shadow[1],shadow[2],shadow[3]);
 cpqtuv_assembly_(e,g,np,ks,ke,nl,dt,dry,u9,v9,t9,old,dyn,conv,u,v,t,q);
 for(int f=0;f<5;++f) {
  for(size_t k=0;k<sizes[f]/8;++k)if(bits(out[f][k])!=bits(shadow[f][k])) {
   size_t cell=cells?k%cells:0;
   fprintf(stderr,"Mismatch stage=CPQTUV step=%d call=%" PRIu64 " field=%d tracer=%zu level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",*step,calls,f,cells?k/cells+1:0,cell/(size_t)*np+1,cell%(size_t)*np+1,bits(out[f][k]),bits(shadow[f][k]));_Exit(1);
  }
  writeall(ao,out[f],sizes[f]);writeall(ro,shadow[f],sizes[f]);bytes+=sizes[f];free(shadow[f]);
  if(insizes[f]&&memcmp(in[f],copies[f],insizes[f]))fail("changed read-only input");
  free(copies[f]);
 }
 if(memcmp(g_before,g,1359136)||memcmp(e_before,e,2776))fail("changed configuration");
 for(int f=0;f<7;++f)if(memcmp(saved_objects[f],objects[f],368))fail("changed named component");
 int32_t now[8]={*np,*ks,*ke,*nl,ndim,ndim1,num,*dry};int32_t then[8]={h[2],h[3],h[4],h[5],h[6],h[7],h[8],h[9]};
 if(memcmp(now,then,sizeof now)||bits(*dt)!=bits(constants[0])||bits(*lv)!=bits(constants[3])||bits(*ls)!=bits(constants[4]))fail("changed scalar input");
 uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));if(after!=last_fpcr)fail("changed FPCR");
 bytes+=240+(uint64_t)num*20;free(g_before);free(maps);
}

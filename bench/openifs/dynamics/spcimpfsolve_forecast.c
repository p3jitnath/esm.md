/* Observe the original complete single-rank caller.
 * Snapshots and descriptor rebasing supply no numerical stage.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <omp.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct dim {int64_t stride,lower,upper;};
struct d1 {void *base;int64_t offset;uint64_t bytes,type;int64_t span;struct dim d;};
struct d2 {void *base;int64_t offset;uint64_t bytes,type;int64_t span;struct dim d[2];};
_Static_assert(sizeof(int32_t)==4&&sizeof(double)==8,"frozen scalar widths");
_Static_assert(sizeof(struct dim)==24&&sizeof(struct d1)==64&&sizeof(struct d2)==88,"frozen GNU descriptor sizes");
typedef void(*caller_fn)(const void*,const void*,const void*,const int32_t*,const int32_t*,const int32_t*,const struct d2*,struct d2*);
typedef void(*leaf_fn)(const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const double*,const double*,const double*,const double*,const double*,double*,double*);
typedef int(*scope_fn)(const void*,const double**,size_t*);
#ifndef SPCIMPFSOLVE_SOURCE_ONLY
extern void spcimpfsolve_observed_assembly_(const void*,const void*,const void*,const int32_t*,const int32_t*,const int32_t*,const struct d2*,struct d2*);
extern void simplico_assembly_(const int32_t*,const int32_t*,const int32_t*,const int32_t*,const double*,const double*,const double*,const double*,const double*,const double*,const double*,double*,double*);
#endif
static caller_fn original;static leaf_fn leaf;static scope_fn query;
static double *omega;static int32_t *nprn,*nprv;
static FILE *input,*reference,*native,*source_stages,*native_stages;
static uint64_t visits,stage_calls,bytes,input_bytes,stage_bytes,mode_calls[256],native_stage_calls;
static int rejected;
static _Thread_local int active;static _Thread_local uint64_t visit;static _Thread_local int stage_mode;
static pthread_once_t once=PTHREAD_ONCE_INIT;
static void fail(const char*s){rejected=1;fprintf(stderr,"SPCIMPFSOLVE forecast FAIL %s\n",s);fflush(stderr);exit(2);}
static uint64_t fpcr(void){uint64_t v;__asm__ volatile("mrs %0,fpcr":"=r"(v));return v;}
static int32_t get32(const void*p,size_t off){int32_t v;memcpy(&v,(const char*)p+off,4);return v;}
static double get64(const void*p,size_t off){double v;memcpy(&v,(const char*)p+off,8);return v;}
static void put64(void*p,size_t off,uint64_t v){memcpy((char*)p+off,&v,8);}
static void put32(void*p,size_t off,int32_t v){memcpy((char*)p+off,&v,4);}
static void write_all(FILE*f,const void*p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("capture write");}
static void *copy(const void*p,size_t n){void*q=malloc(n?n:1);if(!q)fail("snapshot allocation");if(n)memcpy(q,p,n);return q;}
static size_t extent(struct dim d){if(d.upper<d.lower)return 0;return (size_t)(d.upper-d.lower+1);}
static void same(const void*a,const void*b,size_t n,const char*s)
{
 if(!memcmp(a,b,n))return;
 const unsigned char*x=a,*y=b;size_t k=0;while(k<n&&x[k]==y[k])k++;
 size_t begin=k/8*8,word_bytes=n-begin<8?n-begin:8;uint64_t expected=0,actual=0;
 memcpy(&expected,x+begin,word_bytes);memcpy(&actual,y+begin,word_bytes);
 fprintf(stderr,"visit=%"PRIu64" stage=%s first_byte=%zu physical_word=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",visit,s,k,k/8,expected,actual);fail("raw bytes differ");
}
static void init(void)
{
 original=(caller_fn)dlsym(RTLD_NEXT,"spcimpfsolve_");leaf=(leaf_fn)dlsym(RTLD_NEXT,"simplico_");
 query=(scope_fn)dlsym(RTLD_DEFAULT,"spcm_forecast_scope");
 omega=dlsym(RTLD_DEFAULT,"__yomcst_MOD_romega");nprn=dlsym(RTLD_DEFAULT,"__yommp0_MOD_nprtrn");nprv=dlsym(RTLD_DEFAULT,"__yommp0_MOD_nprtrv");
 if(!original||!leaf||!omega||!nprn||!nprv)fail("original entries and constants");
 input=fopen("spcimpfsolve-inputs.bin","wb");reference=fopen("spcimpfsolve-fortran.bin","wb");source_stages=fopen("spcimpfsolve-fortran-stages.bin","wb");
#ifndef SPCIMPFSOLVE_SOURCE_ONLY
 native=fopen("spcimpfsolve-assembly.bin","wb");native_stages=fopen("spcimpfsolve-assembly-stages.bin","wb");
 if(!native||!native_stages)fail("native files");
#endif
 if(!input||!reference||!source_stages)fail("source files");
}
#if defined(SPCIMPFSOLVE_SOURCE_ONLY) || defined(SPCIMPFSOLVE_MINIMAL_SCOPE)
/* Minimal read-only scope forwards every original SPCM pointer and hidden length.
 * It reads the complete shared spectral parent and supplies no field value.
 */
struct d3 {void *base;int64_t offset;uint64_t bytes,type;int64_t span;struct dim d[3];};
struct parent_scope {const void*g,*spectral;struct d3 descriptor;int active;};
static _Thread_local struct parent_scope whole_scope;
typedef void(*spcm_fn)(const void*,void*,const char*,void*,void*,size_t);
int spcm_forecast_scope(const void*g,const double**parent,size_t*elements)
{
 if(!whole_scope.active||whole_scope.g!=g)return 0;
 struct d3 d;memcpy(&d,(const char*)whole_scope.spectral+88,sizeof(d));
 if(memcmp(&d,&whole_scope.descriptor,sizeof(d)))return 0;
 size_t rows=extent(d.d[0]),cols=extent(d.d[1]),fields=extent(d.d[2]);
 if(parent)*parent=d.base;
 if(elements)*elements=rows*cols*fields;
 return 1;
}
void spcm_(const void*g,void*model,const char*config,void*spectral,void*gmv,size_t config_length)
{
 static spcm_fn original_spcm;
 if(!original_spcm)original_spcm=(spcm_fn)dlsym(RTLD_NEXT,"spcm_");
 if(!original_spcm||!g||!spectral)fail("original SPCM scope");
 struct parent_scope prior=whole_scope,next={g,spectral,{0},1};
 memcpy(&next.descriptor,(const char*)spectral+88,sizeof(next.descriptor));
 struct d3*d=&next.descriptor;
 size_t rows=extent(d->d[0]),cols=extent(d->d[1]),fields=extent(d->d[2]);
 if(d->bytes!=8||d->span!=8||d->type!=UINT64_C(0x30300000000)||d->d[0].stride!=1||
    d->d[1].stride!=(int64_t)rows||d->d[2].stride!=(int64_t)(rows*cols)||!d->base||
    rows!=(size_t)get32(g,5224)||cols!=(size_t)get32(g,5200)||fields!=3||
    rows>SIZE_MAX/(cols?cols:1)/(fields?fields:1)/8)fail("complete SPCM spectral parent");
 whole_scope=next;original_spcm(g,model,config,spectral,gmv,config_length);whole_scope=prior;
}
#endif
static void rank1(struct d1 d,int element,int lower,int minupper,const char*name)
{
 if(d.bytes!=(uint64_t)element||d.span!=element||d.type!=(element==4?UINT64_C(0x10100000000):UINT64_C(0x30100000000))||d.d.stride!=1||d.d.lower!=lower||d.d.upper<minupper||(minupper>=lower&&!d.base))fail(name);
}
static void stage_record(FILE*f,const int32_t*m,const int32_t*n,const int32_t*l,const int32_t*s,const double*a,const double*d,const double*p,const double*q,const double*v,const double*lap,const double*b2,double*y,double*x,int after)
{
 unsigned char h[128]={0};memcpy(h,"SPCSST01",8);put64(h,8,visit);put32(h,16,*m);put32(h,20,*n);put32(h,24,*l);put32(h,28,*s);put32(h,32,after);
 size_t waves=(size_t)(*n-*m+1),coefs=waves+1,fields=(size_t)*s*2*waves;
 put64(h,40,coefs);put64(h,48,fields);memcpy(h+56,b2,8);put64(h,64,fpcr());
 write_all(f,h,128);
 if(!after){
  write_all(f,a,coefs*8);write_all(f,d,coefs*8);write_all(f,p,coefs*8);write_all(f,q,coefs*8);
  write_all(f,v,(size_t)*l*8);write_all(f,lap,(size_t)(*n+1)*8);
  write_all(f,y,fields*8);
 }else{write_all(f,y,fields*8);write_all(f,x,fields*8);}
 if(f==source_stages)stage_bytes+=128+(after?2*fields*8:(4*coefs+(size_t)*l+(size_t)(*n+1)+fields)*8);
}
void simplico_(const int32_t*m,const int32_t*n,const int32_t*l,const int32_t*s,const double*a,const double*d,const double*p,const double*q,const double*v,const double*lap,const double*b2,double*y,double*x)
{
 if(pthread_once(&once,init))fail("initialization");
 if(!active){leaf(m,n,l,s,a,d,p,q,v,lap,b2,y,x);return;}
 if(fpcr()||*m<0||*m>*n||*n>255||*l!=*s)fail("source leaf domain/FPCR");
 stage_record(source_stages,m,n,l,s,a,d,p,q,v,lap,b2,y,x,0);
 leaf(m,n,l,s,a,d,p,q,v,lap,b2,y,x);
 if(fpcr())fail("source leaf return FPCR");
 stage_record(source_stages,m,n,l,s,a,d,p,q,v,lap,b2,y,x,1);
 stage_calls++;mode_calls[*m]++;
}
#ifndef SPCIMPFSOLVE_SOURCE_ONLY
/* Observation-only build target. The uninstrumented body calls assembly directly. */
void spcimpfsolve_native_simplico_(const int32_t*m,const int32_t*n,const int32_t*l,const int32_t*s,const double*a,const double*d,const double*p,const double*q,const double*v,const double*lap,const double*b2,double*y,double*x)
{
 if(!active||stage_mode!=1||fpcr())fail("native leaf scope/FPCR");
 stage_record(native_stages,m,n,l,s,a,d,p,q,v,lap,b2,y,x,0);
 simplico_assembly_(m,n,l,s,a,d,p,q,v,lap,b2,y,x);
 if(fpcr())fail("native leaf return FPCR");
 stage_record(native_stages,m,n,l,s,a,d,p,q,v,lap,b2,y,x,1);native_stage_calls++;
}
#endif
void spcimpfsolve_(const void*g,const void*rip,const void*dyn,const int32_t*nh,const int32_t*nhx,const int32_t*onem,const struct d2*rhs,struct d2*out)
{
 if(pthread_once(&once,init))fail("initialization");
 if(active)fail("nested complete caller");
 if(omp_get_max_threads()!=1)fail("capture requires one caller thread");
 for(int k=0;k<=omp_get_level();k++)if(omp_get_team_size(k)!=1)fail("ancestor thread team");
 if(!g||!rip||!dyn||!nh||!nhx||!onem||!rhs||!out||fpcr()||*nprn!=1||*nprv!=1)fail("entry one-rank domain");
 int32_t n=get32(g,5172),cols=get32(g,5200),num=get32(g,5212),lg=get32(g,5224),l=get32(g,5228),s=get32(g,5236);
 if(n<1||n>255||cols!=(n+1)*(n+2)||num!=n+1||lg!=l||s!=l||l<0)fail("geometry shape");
 struct d1 desc[5];memcpy(desc,(const char*)g+3912,64);memcpy(desc+1,(const char*)g+3720,64);
 memcpy(desc+2,(const char*)g+5960,64);memcpy(desc+3,(const char*)g+4104,64);memcpy(desc+4,(const char*)dyn+3312,64);
 if(desc[0].d.lower!=0&&desc[0].d.lower!=1)fail("MYMS lower bound");
 rank1(desc[0],4,(int)desc[0].d.lower,num,"MYMS");rank1(desc[1],4,0,n,"NASM0");rank1(desc[2],4,1,l,"MYLEVS");rank1(desc[3],8,-1,n+2,"RLAPDI");rank1(desc[4],8,1,l,"SIVP");
 unsigned char seen[256]={0};int32_t*ms=(int32_t*)desc[0].base+(1-desc[0].d.lower),*nas=desc[1].base,*levels=desc[2].base;
 for(int k=0;k<num;k++){if(ms[k]<0||ms[k]>n||seen[ms[k]])fail("complete wave permutation");seen[ms[k]]=1;}
 for(int m=0;m<=n;m++)if(nas[m]!=1+m*(2*n+3-m))fail("spectral column partition");
 for(int k=0;k<l;k++)if(levels[k]<1||levels[k]>(int32_t)extent(desc[4].d))fail("vertical selection");
 if(rhs->bytes!=8||out->bytes!=8||rhs->span!=8||out->span!=8||rhs->type!=UINT64_C(0x30200000000)||out->type!=UINT64_C(0x30200000000)||rhs->d[0].stride!=1||out->d[0].stride!=1||rhs->d[1].stride!=(int64_t)extent(rhs->d[0])||out->d[1].stride!=(int64_t)extent(out->d[0])||extent(rhs->d[0])!=(size_t)l||extent(out->d[0])!=(size_t)l||extent(rhs->d[1])!=(size_t)cols||extent(out->d[1])!=(size_t)cols)fail("actual dense descriptor shape");
 /* SPCSI lines182-183 allocate both complete dense temporaries.
  * Its sole SPCIMPFSOLVE call passes them without slicing.
  */
 Dl_info binding,callee;
 if(!dladdr(__builtin_return_address(0),&binding)||!binding.dli_sname||
    strcmp(binding.dli_sname,"spcsi_")||!dladdr((void*)original,&callee)||
    binding.dli_fbase!=callee.dli_fbase)fail("original complete SPCSI allocation caller");
 if(get32(g,7212)!=cols||get32(g,7216)!=cols)fail("SPCSI complete temporary capacity");
 const double*ancestor=NULL;size_t ancestor_elements=0;
 if(query&&!query(g,&ancestor,&ancestor_elements))fail("existing read-only SPCM scope");
 size_t ancestor_bytes=ancestor_elements*8;void*ancestor_before=copy(ancestor,ancestor_bytes);
 const double*parent=out->base;size_t elements=(size_t)l*cols;
 size_t pbytes=elements*8,rbytes=(size_t)l*cols*8;
 uintptr_t p=(uintptr_t)parent;
 size_t offset=0;
 if((uintptr_t)rhs->base<p+pbytes&&(uintptr_t)rhs->base+rbytes>p)fail("rhs/output overlap");
 void*gs=copy(g,17096),*rs=copy(rip,175976),*ds=copy(dyn,4720),*in=copy(rhs->base,rbytes),*before=copy(parent,pbytes),*expected=copy(parent,pbytes);
 void*arr[5];size_t arrbytes[5];
 for(int k=0;k<5;k++){arrbytes[k]=extent(desc[k].d)*(k<3?4:8);arr[k]=copy(desc[k].base,arrbytes[k]);}
 struct d2 saved_rhs=*rhs,saved_out=*out,shadow_out=*out;shadow_out.base=(char*)expected+offset;
#ifdef SPCIMPFSOLVE_SOURCE_ONLY
 (void)shadow_out;
#endif
 int32_t f[3]={*nh,*nhx,*onem};double constants[4]={get64(rip,208),get64(dyn,2488),get64(g,7512),*omega};
 for(int k=0;k<4;k++)if(!isfinite(constants[k]))fail("finite physical scalars");
 unsigned char h[256]={0};memcpy(h,"SPCSFC01",8);visit=++visits;put64(h,8,visit);
 int32_t shape[8]={n,l,s,cols,num,lg,*nprn,*nprv};memcpy(h+16,shape,32);memcpy(h+48,f,12);
 memcpy(h+64,constants,32);put64(h,96,elements);put64(h,104,offset);put64(h,112,rbytes);put64(h,120,pbytes);put64(h,128,fpcr());
 for(int k=0;k<5;k++)put64(h,144+k*8,arrbytes[k]);
 write_all(input,h,256);write_all(input,g,17096);write_all(input,rip,175976);write_all(input,dyn,4720);
 for(int k=0;k<5;k++){struct d1 norm=desc[k];norm.base=NULL;write_all(input,&norm,64);write_all(input,desc[k].base,arrbytes[k]);}
 struct d2 nr=*rhs,no=*out;nr.base=NULL;no.base=NULL;write_all(input,&nr,88);write_all(input,&no,88);
 write_all(input,rhs->base,rbytes);write_all(input,parent,pbytes);
 input_bytes+=256+17096+175976+4720+320+176+rbytes+pbytes;
 for(int k=0;k<5;k++)input_bytes+=arrbytes[k];
 active=1;stage_mode=0;
#ifdef SPCIMPFSOLVE_SOURCE_ONLY
 original(g,rip,dyn,nh,nhx,onem,rhs,out);memcpy(expected,parent,pbytes);
#else
 original(g,rip,dyn,nh,nhx,onem,rhs,&shadow_out);
 same(before,parent,pbytes,"original real parent unchanged by shadow");
 stage_mode=1;spcimpfsolve_observed_assembly_(g,rip,dyn,nh,nhx,onem,rhs,out);
 same(expected,parent,pbytes,"complete returned output parent");
 write_all(native,h,256);write_all(native,parent,pbytes);
#endif
 active=0;
 if(fpcr())fail("return FPCR");
 same(ancestor_before,ancestor,ancestor_bytes,"unchanged shared SPCM ancestor");
 same(gs,g,17096,"geometry");same(rs,rip,175976,"rip");same(ds,dyn,4720,"dynamics");same(in,rhs->base,rbytes,"complete rhs");
 same(&saved_rhs,rhs,88,"rhs descriptor");same(&saved_out,out,88,"output descriptor");
 for(int k=0;k<5;k++)same(arr[k],desc[k].base,arrbytes[k],"complete derived allocation");
 int32_t rf[3]={*nh,*nhx,*onem};same(f,rf,12,"flags");
 double returned[4]={get64(rip,208),get64(dyn,2488),get64(g,7512),*omega};same(constants,returned,32,"constants");
 write_all(reference,h,256);write_all(reference,expected,pbytes);bytes+=256+pbytes;
 free(gs);free(rs);free(ds);free(in);free(before);free(expected);free(ancestor_before);for(int k=0;k<5;k++)free(arr[k]);
}
__attribute__((destructor))static void finish(void)
{
 if(!input)return;
 if(rejected){fprintf(stderr,"SPCIMPFSOLVE forecast rejected before acceptance visits=%"PRIu64"\n",visits);return;}
 if(active)fail("unfinished source caller");
 fclose(input);fclose(reference);fclose(source_stages);if(native)fclose(native);if(native_stages)fclose(native_stages);
 FILE*f=fopen("spcimpfsolve-summary.json","w");if(!f)fail("summary");
 fprintf(f,"{\"visits\":%"PRIu64",\"source_stage_calls\":%"PRIu64",\"native_stage_calls\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"input_bytes\":%"PRIu64",\"stage_bytes\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0,\"nprtrn\":1,\"nprtrv\":1,\"mode_calls\":[",visits,stage_calls,native_stage_calls,bytes,input_bytes,stage_bytes);
 for(int k=0;k<256;k++)fprintf(f,"%s%"PRIu64,k?",":"",mode_calls[k]);
 fprintf(f,"]}\n");fclose(f);
 fprintf(stderr,"SPCIMPFSOLVE FORECAST PASS visits=%"PRIu64" source_stages=%"PRIu64" native_stages=%"PRIu64" bytes=%"PRIu64" stage_bytes=%"PRIu64" FPCR=0\n",visits,stage_calls,native_stage_calls,bytes,stage_bytes);
}

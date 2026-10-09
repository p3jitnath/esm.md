/* Verify every configured longwave ice-cloud optical call and preserve full tables.
 * The source-only build gathers input domains before direct emission. Adding
 * the native object enables complete source/native comparison with no C stage. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct dim {int64_t stride,lower,upper;};
struct descriptor {double *data;int64_t offset,element_length;uint64_t type;int64_t span;struct dim dim[2];};
_Static_assert(sizeof(struct descriptor)==88,"GNU rank2 descriptor");
#define ARGS const int32_t *nb,const struct descriptor *c,const double *iwp,const double *re,double *od,double *so,double *g
typedef void (*kernel)(ARGS);
void calc_ice_optics_fu_lw_assembly_(ARGS) __attribute__((weak));
static kernel reference;
static const int32_t *step;
static const void *image;
static FILE *input,*source,*native;
static uint64_t calls,bands,bytes,steps[25],tables[2],return_counts[2],last_fpcr;
static uintptr_t return_addresses[2];
static double *saved_tables[2];static int32_t table_nb[2];
static double min_iwp=DBL_MAX,max_iwp,min_re=DBL_MAX,max_re,min_od=DBL_MAX,max_od,min_so=DBL_MAX,max_so,min_g=DBL_MAX,max_g=-DBL_MAX;
static void fail(const char *s){fprintf(stderr,"ICE FU LW forecast failed: %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static int overlaps(const void *a,size_t na,const void *b,size_t nb){uintptr_t x=(uintptr_t)a,y=(uintptr_t)b;if(x>UINTPTR_MAX-na||y>UINTPTR_MAX-nb)fail("pointer extent");return na&&nb&&x<y+nb&&y<x+na;}
__attribute__((destructor)) static void finish(void){
 if(!source)return;
 if(fclose(source)||fclose(input)||(native&&fclose(native)))fail("capture close");
 if(calls==0||tables[0]!=calls||tables[1]!=0)fail("complete accepted T21 call count");
 fprintf(stderr,"ICE FU LW %s PASS calls=%" PRIu64 " bands=%" PRIu64 " complete_record_bytes=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",native?"NATIVE":"SOURCE",calls,bands,bytes,last_fpcr);
 FILE *f=fopen("ice-fu-lw-call-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"bands\":%" PRIu64 ",\"complete_result_bytes\":%" PRIu64 ",\"native_compared\":%s,\"FPCR_zero_every_entry\":true,\"differing_bytes\":0,\"table_band_counts\":[%d,%d],\"table_calls\":[%" PRIu64 ",%" PRIu64 "],\"return_offsets\":[\"0x%" PRIxPTR "\",\"0x%" PRIxPTR "\"],\"input_domain\":{\"iwp_kg_m2\":[%.17g,%.17g],\"radius_m\":[%.17g,%.17g]},\"output_domain\":{\"optical_depth\":[%.17g,%.17g],\"scattering_depth\":[%.17g,%.17g],\"asymmetry\":[%.17g,%.17g]},\"step_calls\":[",calls,bands,bytes,native?"true":"false",table_nb[0],table_nb[1],tables[0],tables[1],return_addresses[0],return_addresses[1],min_iwp,max_iwp,min_re,max_re,min_od,max_od,min_so,max_so,min_g,max_g);
 for(int q=0;q<25;++q)fprintf(f,"%s%" PRIu64,q?",":"",steps[q]);fputs("]}\n",f);if(fclose(f))fail("metadata close");
}
void __radiation_ice_optics_fu_MOD_calc_ice_optics_fu_lw(ARGS){
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));last_fpcr=fp;if(fp!=0)fail("strict every-entry FPCR");
 if(!reference){void *s=dlsym(RTLD_NEXT,"__radiation_ice_optics_fu_MOD_calc_ice_optics_fu_lw");if(!s)fail("unchanged source routine");memcpy(&reference,&s,sizeof reference);Dl_info original={0};if(!dladdr(s,&original)||!original.dli_fbase)fail("source image");image=original.dli_fbase;step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");if(!step)fail("forecast step");input=fopen("ice-fu-lw-inputs.bin","wb");source=fopen("ice-fu-lw-fortran.bin","wb");if(calc_ice_optics_fu_lw_assembly_)native=fopen("ice-fu-lw-assembly.bin","wb");if(!input||!source||(calc_ice_optics_fu_lw_assembly_&&!native))fail("capture open");}
 Dl_info caller={0};void *ret=__builtin_return_address(0);if(!dladdr(ret,&caller)||caller.dli_fbase!=image)fail("undeclared caller image");uintptr_t offset=(uintptr_t)ret-(uintptr_t)image;
 /* Symbol-only metadata from the immutable original CLOUD_OPTICS body.
  * Both original sites pass full configured coefficient and result capacities. */
 if(offset<0xb06088||offset>=0xb06088+0x17a4)fail("undeclared CLOUD_OPTICS caller capacity");
 if(!nb||!c||!iwp||!re||!od||!so||!g||*nb<=0||*nb>256||*step<0||*step>24)fail("arguments/bands/phase");
 if(c->element_length!=8||c->span!=8||c->type!=UINT64_C(0x0000030200000000)||c->dim[0].stride!=1||c->dim[0].upper-c->dim[0].lower+1!=*nb||c->dim[1].stride!=*nb||c->dim[1].upper-c->dim[1].lower+1!=11)fail("configured complete coefficient-table descriptor");
 if(!c->data||!isfinite(*iwp)||!isfinite(*re)||*iwp<=0||*re<=0)fail("positive physical caller inputs");
 size_t matrix=(size_t)*nb*11*8,size=(size_t)*nb*8;
 double *out[3]={od,so,g},*shadow[3];unsigned char desc_before[88];memcpy(desc_before,c,88);int32_t nb_before=*nb;double scalars[2]={*iwp,*re};
 for(int q=0;q<3;++q){if((uintptr_t)out[q]%8||overlaps(out[q],size,c->data,matrix)||overlaps(out[q],size,c,88)||overlaps(out[q],size,nb,4)||overlaps(out[q],size,iwp,8)||overlaps(out[q],size,re,8))fail("output alignment or input alias");for(int z=0;z<q;++z)if(overlaps(out[q],size,out[z],size))fail("overlapping outputs");shadow[q]=malloc(size);if(!shadow[q])fail("independent output allocation");}
 int table=-1;
 for(int q=0;q<2;++q)if(saved_tables[q]&&table_nb[q]==*nb&&memcmp(saved_tables[q],c->data,matrix)==0)table=q;
 if(table<0){for(int q=0;q<2;++q)if(!saved_tables[q]){table=q;break;}if(table<0)fail("undeclared changing coefficient table");saved_tables[table]=malloc(matrix);if(!saved_tables[table])fail("complete table snapshot");memcpy(saved_tables[table],c->data,matrix);table_nb[table]=*nb;char name[64];snprintf(name,sizeof name,"ice-fu-lw-coefficients-%d.bin",table+1);FILE *f=fopen(name,"wb");if(!f)fail("table archive");writeall(f,c->data,matrix);if(fclose(f))fail("table close");}
 if(!return_addresses[table])return_addresses[table]=offset;if(return_addresses[table]!=offset)fail("changing source-site/table association");
 for(size_t q=0;q<matrix/8;++q)if(!isfinite(c->data[q]))fail("finite configured coefficients");
 int32_t h[4]={*step,*nb,table+1,table+1};FILE *streams[3]={input,source,native};
 for(int q=0;q<3;++q)if(streams[q]){writeall(streams[q],&calls,8);writeall(streams[q],h,16);writeall(streams[q],scalars,16);}
 writeall(input,c->data,matrix);for(int q=0;q<3;++q)writeall(input,out[q],size);
 if(native){reference(nb,c,iwp,re,shadow[0],shadow[1],shadow[2]);calc_ice_optics_fu_lw_assembly_(nb,c,iwp,re,od,so,g);}
 else {reference(nb,c,iwp,re,od,so,g);for(int q=0;q<3;++q)memcpy(shadow[q],out[q],size);}
 if(memcmp(desc_before,c,88)||memcmp(saved_tables[table],c->data,matrix)||*nb!=nb_before||memcmp(iwp,&scalars[0],8)||memcmp(re,&scalars[1],8))fail("changed complete read-only inputs");
 uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));if(after!=0)fail("changed FPCR");
 for(int q=0;q<3;++q){if(native&&memcmp(shadow[q],out[q],size)){size_t k=0;while(k<(size_t)*nb&&bits(shadow[q][k])==bits(out[q][k]))++k;fprintf(stderr,"ICE FU LW first mismatch call=%" PRIu64 " step=%d table=%d field=%d band=%zu source=%016" PRIx64 " assembly=%016" PRIx64 "\n",calls,*step,table+1,q+1,k+1,bits(shadow[q][k]),bits(out[q][k]));fail("complete output bytes");}writeall(source,shadow[q],size);if(native)writeall(native,out[q],size);}
 for(int k=0;k<*nb;++k){double tau=od[k],scatter=so[k],asym=g[k];double limit=256*DBL_EPSILON*fmax(1,fabs(tau)+fabs(scatter));if(!isfinite(tau)||!isfinite(scatter)||!isfinite(asym)||tau < -limit||scatter < -limit||scatter>tau+limit||asym < -1-256*DBL_EPSILON||asym>1+256*DBL_EPSILON)fail("configured source optical admissibility");min_od=fmin(min_od,tau);max_od=fmax(max_od,tau);min_so=fmin(min_so,scatter);max_so=fmax(max_so,scatter);min_g=fmin(min_g,asym);max_g=fmax(max_g,asym);}
 min_iwp=fmin(min_iwp,*iwp);max_iwp=fmax(max_iwp,*iwp);min_re=fmin(min_re,*re);max_re=fmax(max_re,*re);
 ++tables[table];++return_counts[table];++steps[*step];++calls;bands+=(uint64_t)*nb;bytes+=40+3*size;for(int q=0;q<3;++q)free(shadow[q]);
}

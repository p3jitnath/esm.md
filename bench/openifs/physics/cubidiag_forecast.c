/* Capture full (KLON,KLEV) arrays from the two declared convection callers.
 * Compare complete source/native outputs and independently check the supplied
 * triangular equations. Capture unused object bytes without interpreting them. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define ARGS const int32_t *ks,const int32_t *ke,const int32_t *np,const int32_t *nl, \
 const int32_t *top,const int32_t *mask,const double *a,const double *b,const double *r,double *u
typedef void (*kernel)(ARGS);
void cubidiag_assembly_(ARGS);
static kernel reference;
static const int32_t *step;
static const void *source_image;
static FILE *af,*rf,*inputs;
static uint64_t calls,bytes,first_rows,recurrent_rows,zero_rows,masked_rows,pretop_rows,partial_calls,no_equation_calls,last_fpcr;
static uint64_t site_calls[4],return_calls[8],step_calls[25];
/* These return addresses follow call instructions in the immutable strict ELF.
 * Two compiled paths implement each original source site with identical shapes.
 * They were read only after first primary emission; no source arithmetic was used. */
static const uintptr_t returns[8]={0x70ddc4,0x70ddf4,0x70dffc,0x70e02c,0x70b52c,0x70b558,0x70b80c,0x70b840};
static const int sites[8]={0,1,0,1,2,3,2,3};
static void fail(const char *s) {fprintf(stderr,"CUBIDIAG forecast check failed: %s\n",s);_Exit(2);}
static uint64_t bits(double v) {uint64_t q;memcpy(&q,&v,8);return q;}
static void writeall(FILE *f,const void *p,size_t n) {if(n&&fwrite(p,1,n,f)!=n)fail("capture write");}
static int overlap(const void *a,size_t na,const void *b,size_t nb) {
 uintptr_t x=(uintptr_t)a,y=(uintptr_t)b;if(x>UINTPTR_MAX-na||y>UINTPTR_MAX-nb)fail("address overflow");
 return na&&nb&&x<y+nb&&y<x+na;
}
__attribute__((destructor)) static void finish(void) {
 if(!af)return;
 if(fclose(af)||fclose(rf)||fclose(inputs))fail("capture close");
 if(calls!=8600)fail("expected complete T21 call count");
 for(int q=0;q<4;++q)if(site_calls[q]!=2150)fail("expected complete source-site count");
 fprintf(stderr,"CUBIDIAG FORECAST PASS calls=%" PRIu64 " complete_record_bytes=%" PRIu64 " differing_bytes=0 first_rows=%" PRIu64 " recurrent_rows=%" PRIu64 " positive_zero_rows=%" PRIu64 " FPCR=%016" PRIx64 "\n",calls,bytes,first_rows,recurrent_rows,zero_rows,last_fpcr);
 FILE *f=fopen("cubidiag-call-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"KLON\":24,\"KLEV\":19,\"complete_record_bytes\":%" PRIu64 ",\"differing_bytes\":0,\"first_cloud_rows\":%" PRIu64 ",\"recurrent_rows\":%" PRIu64 ",\"positive_zero_rows\":%" PRIu64 ",\"masked_rows\":%" PRIu64 ",\"pretop_rows\":%" PRIu64 ",\"no_equation_calls\":%" PRIu64 ",\"partial_calls\":%" PRIu64 ",\"site_calls\":[",calls,bytes,first_rows,recurrent_rows,zero_rows,masked_rows,pretop_rows,no_equation_calls,partial_calls);
 for(int q=0;q<4;++q)fprintf(f,"%s%" PRIu64,q?",":"",site_calls[q]);fputs("],\"compiled_return_calls\":[",f);
 for(int q=0;q<8;++q)fprintf(f,"%s%" PRIu64,q?",":"",return_calls[q]);fputs("],\"step_calls\":[",f);
 for(int q=0;q<25;++q)fprintf(f,"%s%" PRIu64,q?",":"",step_calls[q]);fputs("]}\n",f);if(fclose(f))fail("metadata close");
}
void cubidiag_(ARGS) {
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));last_fpcr=fp;
 if(fp!=0)fail("strict every-entry FPCR");
 if(!reference) {
  void *s=dlsym(RTLD_NEXT,"cubidiag_");if(!s)fail("source routine");memcpy(&reference,&s,sizeof reference);
  Dl_info origin={0};if(!dladdr(s,&origin)||!origin.dli_fbase)fail("source image");source_image=origin.dli_fbase;
  step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");if(!step)fail("step module");
  af=fopen("cubidiag-assembly.bin","wb");rf=fopen("cubidiag-fortran.bin","wb");inputs=fopen("cubidiag-inputs.bin","wb");
  if(!af||!rf||!inputs)fail("capture open");
 }
 Dl_info caller={0};void *ret=__builtin_return_address(0);
 if(!dladdr(ret,&caller)||caller.dli_fbase!=source_image)fail("undeclared caller image");
 uintptr_t offset=(uintptr_t)ret-(uintptr_t)source_image;int entry=-1;
 for(int q=0;q<8;++q)if(offset==returns[q])entry=q;
 if(entry<0){fprintf(stderr,"CUBIDIAG undeclared caller return=%" PRIxPTR "\n",offset);fail("undeclared source site/capacity");}
 int site=sites[entry];
 if(!ks||!ke||!np||!nl||!top||!mask||!a||!b||!r||!u)fail("argument pointer");
 /* Whole capacities follow original static declarations and allocations,
  * rather than the selected interval or number of cloudy cells. */
 if(*np!=24||*nl!=19||*ks<1||*ks>*np||*ke<*ks-1||*ke>*np||*step<0||*step>24)fail("undeclared T21 shape, interval or phase");
 size_t n=(size_t)*np*(size_t)*nl,size=n*8,sizes[5]={(size_t)*np*4,n*4,size,size,size};
 const void *in[5]={top,mask,a,b,r};void *copies[5];
 for(int q=0;q<5;++q) {
  if((uintptr_t)in[q]%(q<2?4:8)||overlap(in[q],sizes[q],u,size))fail("input alignment or output alias");
  copies[q]=malloc(sizes[q]);if(!copies[q])fail("input snapshot");memcpy(copies[q],in[q],sizes[q]);
 }
 if((uintptr_t)u%8)fail("output alignment");
 int32_t h[6]={*step,site+1,*np,*nl,*ks,*ke};double eps=1e-35;
 const int32_t *scalar[4]={ks,ke,np,nl};int32_t scalar_before[4]={*ks,*ke,*np,*nl};
 for(int q=0;q<4;++q)if(overlap(scalar[q],4,u,size))fail("output aliases scalar");
 FILE *streams[3]={inputs,af,rf};
 for(int q=0;q<3;++q){writeall(streams[q],&calls,8);writeall(streams[q],h,24);writeall(streams[q],&eps,8);writeall(streams[q],top,sizes[0]);writeall(streams[q],mask,sizes[1]);}
 writeall(inputs,a,size);writeall(inputs,b,size);writeall(inputs,r,size);writeall(inputs,u,size);
 double *shadow=malloc(size);if(!shadow)fail("independent source output");memcpy(shadow,u,size);
 reference(ks,ke,np,nl,top,mask,a,b,r,shadow);
 for(int q=0;q<5;++q)if(memcmp(in[q],copies[q],sizes[q]))fail("source changed input bytes");
 for(int q=0;q<4;++q)if(*scalar[q]!=scalar_before[q])fail("source changed scalar");
 cubidiag_assembly_(ks,ke,np,nl,top,mask,a,b,r,u);
 for(int q=0;q<5;++q)if(memcmp(in[q],copies[q],sizes[q]))fail("native changed input bytes");
 for(int q=0;q<4;++q)if(*scalar[q]!=scalar_before[q])fail("native changed scalar");
 uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));if(after!=fp)fail("changed FPCR");
 if(memcmp(shadow,u,size)) {
  const unsigned char *x=(const unsigned char *)shadow,*y=(const unsigned char *)u;size_t z=0;while(z<size&&x[z]==y[z])++z;size_t i=z/8;
  fprintf(stderr,"CUBIDIAG first mismatch call=%" PRIu64 " step=%d site=%d level=%zu column=%zu byte=%zu source=%016" PRIx64 " assembly=%016" PRIx64 "\n",calls,*step,site+1,i/(size_t)*np+1,i%(size_t)*np+1,z,bits(shadow[i]),bits(u[i]));fail("complete output bytes");
 }
 uint64_t equations=0;
 for(int k=0;k<*nl;++k)for(int j=0;j<*np;++j) {
  size_t i=(size_t)k*(size_t)*np+(size_t)j;
  if(mask[i]!=0&&mask[i]!=1)fail("logical representation");
  int selected=k>=1&&j>=*ks-1&&j<*ke&&mask[i];
  if(selected && (top[j]<1||top[j]>*nl+2))fail("used cloud top");
  if(!selected||k+1<top[j]-1) {
   if(bits(u[i])!=0)fail("complete positive-zero stage");++zero_rows;
   if(k>=1&&j>=*ks-1&&j<*ke){if(!mask[i])++masked_rows;else ++pretop_rows;}
   continue;
  }
  if(!isfinite(b[i])||!isfinite(r[i])||!isfinite(u[i]))fail("finite used equation");
  double diagonal=b[i]+eps;if(!isfinite(diagonal)||diagonal==0||!isfinite(1.0/diagonal))fail("finite regularised inverse");
  long double left=(long double)diagonal*u[i],previous=0;
  if(k+1>top[j]-1){if(!isfinite(a[i]))fail("finite used lower diagonal");previous=(long double)a[i]*u[i-*np];++recurrent_rows;}else ++first_rows;
  long double scale=fabsl(left)+fabsl(previous)+fabsl((long double)r[i]);
  long double limit=128.0L*DBL_EPSILON*fmaxl(1.0L,scale)+8.0L*DBL_TRUE_MIN;
  if(fabsl(left+previous-r[i])>limit)fail("independent live triangular residual");++equations;
 }
 if(!equations)++no_equation_calls;if(*ke-*ks+1<*np)++partial_calls;
 writeall(af,u,size);writeall(rf,shadow,size);bytes+=40+sizes[0]+sizes[1]+size;
 if(!return_calls[entry])fprintf(stderr,"CUBIDIAG declared source site=%d return=%" PRIxPTR " KLON=%d KLEV=%d all arrays full\n",site+1,offset,*np,*nl);
 ++return_calls[entry];++site_calls[site];++step_calls[*step];++calls;
 for(int q=0;q<5;++q)free(copies[q]);free(shadow);
}

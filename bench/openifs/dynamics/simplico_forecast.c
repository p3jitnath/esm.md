/* Compare each complete SIMPLICO call inside its original source caller.
 * The SPCIMPFSOLVE relay supplies capacity; it supplies no numerical result.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <omp.h>
#include <pthread.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct dim {int64_t stride,lower,upper;};
struct descriptor1 {void *base;int64_t offset;uint64_t bytes,type;int64_t span;struct dim d;};
struct descriptor2 {void *base;int64_t offset;uint64_t bytes,type;int64_t span;struct dim d[2];};
_Static_assert(sizeof(struct descriptor1)==64,"GNU rank-one descriptor");
_Static_assert(sizeof(struct descriptor2)==88,"GNU rank-two descriptor");
typedef void (*solve_fn)(const int32_t*,const int32_t*,const int32_t*,const int32_t*,
 const double*,const double*,const double*,const double*,const double*,const double*,const double*,double*,double*);
typedef void (*caller_fn)(const void*,const void*,const void*,const int32_t*,const int32_t*,const int32_t*,const struct descriptor2*,const struct descriptor2*);
typedef int (*spcm_query_fn)(const void*,const double**,size_t*);
extern void simplico_assembly_(const int32_t*,const int32_t*,const int32_t*,const int32_t*,
 const double*,const double*,const double*,const double*,const double*,const double*,const double*,double*,double*);
struct scope {
 const void *g,*rip,*dyn;int32_t n,l,s,cols,flags[3];uint64_t visit;
 struct descriptor1 nasm,lap;int active;
};
static _Thread_local struct scope current;
static _Thread_local unsigned reference_depth;
static pthread_once_t once=PTHREAD_ONCE_INIT;
static pthread_mutex_t lock=PTHREAD_MUTEX_INITIALIZER;
static solve_fn original_leaf;
static caller_fn original_caller;
static spcm_query_fn spcm_query;
static FILE *source_file,*native_file,*input_file;
static uint64_t calls,source_calls,solve_visits,shadow_calls,shadow_solve_visits,output_bytes,input_bytes,zero_calls,one_degree_calls;
static uint64_t mode_calls[256];
static const char *reference_image;
static void fail(const char *s){fprintf(stderr,"SIMPLICO forecast FAIL %s\n",s);fflush(stderr);exit(2);}
static uint64_t fpcr(void){uint64_t r;__asm__ volatile("mrs %0,fpcr":"=r"(r));return r;}
static int32_t load32(const void *p){int32_t x;memcpy(&x,p,4);return x;}
static uint64_t word64(const void *p){uint64_t x;memcpy(&x,p,8);return x;}
static void put32(unsigned char *p,int32_t x){memcpy(p,&x,4);}
static void put64(unsigned char *p,uint64_t x){memcpy(p,&x,8);}
static size_t extent(struct dim d){if(d.upper<d.lower)return 0;return (size_t)(d.upper-d.lower+1);}
static void *copy(const void *p,size_t bytes)
{
 void *q=malloc(bytes?bytes:1);
 if(!q)fail("snapshot allocation");
 if(bytes)memcpy(q,p,bytes);
 return q;
}
static void same(const void *a,const void *b,size_t bytes,const char *stage,uint64_t call,int mode)
{
 if(!memcmp(a,b,bytes))return;
 const unsigned char *x=a,*y=b;size_t k=0;
 while(k<bytes&&x[k]==y[k])k++;
 uint64_t av=0,bv=0;
 if(k/8*8+8<=bytes){av=word64(x+k/8*8);bv=word64(y+k/8*8);}
 fprintf(stderr,"call=%"PRIu64" m=%d stage=%s byte=%zu cell=%zu source=%016"PRIx64" native=%016"PRIx64"\n",call,mode,stage,k,k/8,av,bv);
 fail("raw byte difference");
}
static void write_bytes(FILE *f,const void *p,size_t bytes){if(bytes&&fwrite(p,1,bytes,f)!=bytes)fail("capture write");}
static void initialize(void)
{
 original_leaf=(solve_fn)dlsym(RTLD_NEXT,"simplico_");
 original_caller=(caller_fn)dlsym(RTLD_NEXT,"spcimpfsolve_");
 spcm_query=(spcm_query_fn)dlsym(RTLD_DEFAULT,"spcm_forecast_scope");
 if(!original_leaf||!original_caller)fail("original source entries");
 Dl_info info;
 if(!dladdr((void*)original_leaf,&info)||!info.dli_fname)fail("source image identity");
 reference_image=info.dli_fname;
 source_file=fopen("simplico-fortran.bin","wb");
 native_file=fopen("simplico-assembly.bin","wb");
 input_file=fopen("simplico-inputs.bin","wb");
 if(!source_file||!native_file||!input_file)fail("capture files");
}
static void single_thread(void)
{
 if(omp_get_max_threads()!=1)fail("capture requires one source-caller thread");
 const int levels=omp_get_level();
 for(int level=0;level<=levels;level++)if(omp_get_team_size(level)!=1)fail("active ancestor team has multiple threads");
}
void simplico_forecast_reference_begin(void){reference_depth++;}
void simplico_forecast_reference_end(void){if(!reference_depth)fail("reference marker balance");reference_depth--;}
/* Forward the original eight pointers without replacing the transpose or solve. */
void spcimpfsolve_(const void *g,const void *rip,const void *dyn,const int32_t *nh,
 const int32_t *nhx,const int32_t *onem,const struct descriptor2 *rhs,const struct descriptor2 *out)
{
 if(pthread_once(&once,initialize))fail("initialization");
 if(reference_depth){shadow_solve_visits++;original_caller(g,rip,dyn,nh,nhx,onem,rhs,out);return;}
 single_thread();
 if(fpcr())fail("source-caller entry FPCR");
 if(!g||!rip||!dyn||!nh||!nhx||!onem||!rhs||!out)fail("source-caller arguments");
 struct scope prior=current,next={0};
 next.g=g;next.rip=rip;next.dyn=dyn;
 const unsigned char *base=g;
 next.n=load32(base+5172);next.cols=load32(base+5200);next.l=load32(base+5228);next.s=load32(base+5236);
 memcpy(&next.nasm,base+3720,64);memcpy(&next.lap,base+4104,64);
 next.flags[0]=*nh;next.flags[1]=*nhx;next.flags[2]=*onem;
 if(next.n<1||next.n>=256||next.l<1||next.s<next.l||next.cols<1)fail("configured dimensions");
 if(next.nasm.bytes!=4||next.nasm.span!=4||next.nasm.type!=UINT64_C(0x0000010100000000)||
    next.nasm.d.stride!=1||next.nasm.d.lower!=0||next.nasm.d.upper!=next.n||!next.nasm.base)fail("NASM0 allocation");
 if(next.lap.bytes!=8||next.lap.span!=8||next.lap.type!=UINT64_C(0x0000030100000000)||
    next.lap.d.stride!=1||next.lap.d.lower!=-1||next.lap.d.upper!=next.n+2||!next.lap.base)fail("RLAPDI allocation");
 if(spcm_query&&!spcm_query(g,NULL,NULL))fail("existing SPCM scope mismatch");
 next.visit=++solve_visits;next.active=1;
 void *gc=copy(g,17096),*rc=copy(rip,175976),*dc=copy(dyn,4720);
 struct descriptor2 rhsc=*rhs,outc=*out;
 int32_t fc[3]={*nh,*nhx,*onem};
 const size_t nasm_bytes=extent(next.nasm.d)*4,lap_bytes=extent(next.lap.d)*8;
 void *nc=copy(next.nasm.base,nasm_bytes),*lc=copy(next.lap.base,lap_bytes);
 current=next;
 original_caller(g,rip,dyn,nh,nhx,onem,rhs,out);
 same(gc,g,17096,"caller geometry",next.visit,-1);same(rc,rip,175976,"caller rip",next.visit,-1);
 same(dc,dyn,4720,"caller dynamics",next.visit,-1);
 same(&rhsc,rhs,88,"caller rhs descriptor",next.visit,-1);same(&outc,out,88,"caller output descriptor",next.visit,-1);
 int32_t returned_flags[3]={*nh,*nhx,*onem};same(fc,returned_flags,12,"caller flags",next.visit,-1);
 same(nc,next.nasm.base,nasm_bytes,"caller NASM0",next.visit,-1);same(lc,next.lap.base,lap_bytes,"caller Laplacian",next.visit,-1);
 if(fpcr())fail("source-caller return FPCR");
 current=prior;free(gc);free(rc);free(dc);free(nc);free(lc);
}
void simplico_(const int32_t *m,const int32_t *n,const int32_t *l,const int32_t *s,
 const double *alpha,const double *denim,const double *plus,const double *minus,
 const double *v,const double *lap,const double *b2,double *y,double *x)
{
 if(pthread_once(&once,initialize))fail("initialization");
 if(reference_depth){shadow_calls++;original_leaf(m,n,l,s,alpha,denim,plus,minus,v,lap,b2,y,x);return;}
 if(!current.active)fail("leaf has no original SPCIMPFSOLVE capacity scope");
 single_thread();
 if(fpcr())fail("leaf entry FPCR");
 struct scope *c=&current;
 if(*m<0||*m>*n||*n!=c->n||*l!=c->l||*s!=c->s)fail("leaf/caller shape");
 const int32_t mode=*m;const size_t waves=(size_t)(*n-*m+1);
 const int32_t column=load32((const unsigned char*)c->nasm.base+(size_t)mode*4);
 if(column<1||(size_t)(column-1)+2*waves>(size_t)c->cols)fail("selected wave bound");
 if((size_t)c->s>SIZE_MAX/(size_t)c->cols/8)fail("parent size");
 const size_t elements=(size_t)c->s*c->cols,bytes=elements*8;
 const size_t offset=(size_t)(column-1)*c->s*8;
 if((uintptr_t)y<offset||(uintptr_t)x<offset)fail("parent pointer underflow");
 double *parent_y=(double*)((uintptr_t)y-offset),*parent_x=(double*)((uintptr_t)x-offset);
 uintptr_t py=(uintptr_t)parent_y,px=(uintptr_t)parent_x;
 if(py>UINTPTR_MAX-bytes||px>UINTPTR_MAX-bytes||!(py+bytes<=px||px+bytes<=py))fail("source parents overlap");
 const size_t coef_count=(size_t)c->n+2,coef_bytes=coef_count*8,v_bytes=(size_t)c->l*8;
 const size_t lap_count=extent(c->lap.d),lap_bytes=lap_count*8,nasm_bytes=extent(c->nasm.d)*4;
 if(lap!=(const double*)c->lap.base+1)fail("source Laplacian selected element");
 const double *arrays[6]={alpha-mode,denim-mode,plus-mode,minus-mode,v,c->lap.base};
 const size_t lengths[6]={coef_bytes,coef_bytes,coef_bytes,coef_bytes,v_bytes,lap_bytes};
 void *snapshots[6];
 for(int i=0;i<6;i++)snapshots[i]=copy(arrays[i],lengths[i]);
 unsigned char scalar[24];memcpy(scalar,m,4);memcpy(scalar+4,n,4);memcpy(scalar+8,l,4);memcpy(scalar+12,s,4);memcpy(scalar+16,b2,8);
 void *gcopy=copy(c->g,17096),*ripcopy=copy(c->rip,175976),*dyncopy=copy(c->dyn,4720),*nasmcopy=copy(c->nasm.base,nasm_bytes);
 double *ys=copy(parent_y,bytes),*xs=copy(parent_x,bytes);
 unsigned char header[160]={0};memcpy(header,"SIMPFC01",8);
 if(pthread_mutex_lock(&lock))fail("capture lock");
 const uint64_t sequence=++calls;
 put64(header+8,sequence);put64(header+16,c->visit);
 put32(header+24,*m);put32(header+28,*n);put32(header+32,*l);put32(header+36,*s);put32(header+40,c->cols);put32(header+44,(int32_t)waves);
 put64(header+48,(uint64_t)(column-1));put64(header+56,elements);put64(header+64,bytes);
 put64(header+72,4*coef_count+(size_t)c->l+lap_count);put64(header+80,fpcr());put64(header+88,word64(b2));
 put64(header+96,coef_count);put64(header+104,lap_count);put64(header+112,(uint64_t)c->lap.d.lower);
 put64(header+120,(uint64_t)c->s);put64(header+128,(uint64_t)c->cols);put64(header+136,16*(size_t)c->s*waves);
 for(int i=0;i<3;i++)put32(header+144+i*4,c->flags[i]);
 write_bytes(input_file,header,160);write_bytes(input_file,parent_y,bytes);write_bytes(input_file,parent_x,bytes);
 for(int i=0;i<6;i++)write_bytes(input_file,arrays[i],lengths[i]);
 write_bytes(input_file,c->nasm.base,nasm_bytes);
 struct descriptor1 normalized_nasm=c->nasm,normalized_lap=c->lap;normalized_nasm.base=NULL;normalized_lap.base=NULL;
 write_bytes(input_file,&normalized_nasm,64);write_bytes(input_file,&normalized_lap,64);
 input_bytes+=160+2*bytes+4*coef_bytes+v_bytes+lap_bytes+nasm_bytes+128;
 original_leaf(m,n,l,s,alpha,denim,plus,minus,v,lap,b2,(double*)((unsigned char*)ys+offset),(double*)((unsigned char*)xs+offset));
 source_calls++;
 if(fpcr())fail("reference leaf FPCR");
 simplico_assembly_(m,n,l,s,alpha,denim,plus,minus,v,lap,b2,y,x);
 if(fpcr())fail("native leaf FPCR");
 same(ys,parent_y,bytes,"complete PY parent",sequence,mode);same(xs,parent_x,bytes,"complete PX parent",sequence,mode);
 for(int i=0;i<6;i++)same(snapshots[i],arrays[i],lengths[i],"complete coefficient allocation",sequence,mode);
 unsigned char returned_scalar[24];memcpy(returned_scalar,m,4);memcpy(returned_scalar+4,n,4);memcpy(returned_scalar+8,l,4);memcpy(returned_scalar+12,s,4);memcpy(returned_scalar+16,b2,8);
 same(scalar,returned_scalar,24,"scalar inputs",sequence,mode);
 same(gcopy,c->g,17096,"leaf geometry",sequence,mode);same(ripcopy,c->rip,175976,"leaf rip",sequence,mode);
 same(dyncopy,c->dyn,4720,"leaf dynamics",sequence,mode);same(nasmcopy,c->nasm.base,nasm_bytes,"leaf NASM0",sequence,mode);
 write_bytes(source_file,header,160);write_bytes(source_file,ys,bytes);write_bytes(source_file,xs,bytes);
 write_bytes(native_file,header,160);write_bytes(native_file,parent_y,bytes);write_bytes(native_file,parent_x,bytes);
 output_bytes+=160+2*bytes;mode_calls[mode]++;if(!mode)zero_calls++;if(mode==*n)one_degree_calls++;
 if(pthread_mutex_unlock(&lock))fail("capture unlock");
 for(int i=0;i<6;i++)free(snapshots[i]);
 free(ys);free(xs);free(gcopy);free(ripcopy);free(dyncopy);free(nasmcopy);
}
__attribute__((destructor)) static void summary(void)
{
 if(!source_file)return;
 if(reference_depth)fail("unbalanced final reference marker");
 fclose(source_file);fclose(native_file);fclose(input_file);
 FILE *f=fopen("simplico-summary.json","w");if(!f)return;
 fprintf(f,"{\"calls\":%"PRIu64",\"source_calls\":%"PRIu64",\"solve_visits\":%"PRIu64",\"shadow_calls\":%"PRIu64",\"shadow_solve_visits\":%"PRIu64",\"output_bytes\":%"PRIu64",\"input_bytes\":%"PRIu64",\"zero_wave_calls\":%"PRIu64",\"one_degree_calls\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0,\"original_image\":\"%s\",\"mode_calls\":[",calls,source_calls,solve_visits,shadow_calls,shadow_solve_visits,output_bytes,input_bytes,zero_calls,one_degree_calls,reference_image);
 for(int i=0;i<256;i++)fprintf(f,"%s%"PRIu64,i?",":"",mode_calls[i]);
 fprintf(f,"]}\n");fclose(f);
 fprintf(stderr,"SIMPLICO forecast accepted calls=%"PRIu64" source=%"PRIu64" solve_visits=%"PRIu64" output_bytes=%"PRIu64" different_bytes=0 FPCR=0\n",calls,source_calls,solve_visits,output_bytes);
}

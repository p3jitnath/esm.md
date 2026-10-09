/* Compare the complete spectral parent allocation at each real POST call.
 * The SPCM relay supplies storage context and forwards every argument unchanged.
 * The driver supplies no coefficient or vorticity calculation.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <omp.h>
#include <pthread.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct dim {int64_t stride,lower,upper;};
struct descriptor2 {double *base;int64_t offset;uint64_t bytes,type_word;int64_t span;struct dim d[2];};
struct descriptor3 {double *base;int64_t offset;uint64_t bytes,type_word;int64_t span;struct dim d[3];};
_Static_assert(sizeof(struct descriptor2)==88,"rank-two GNU ABI");
_Static_assert(sizeof(struct descriptor3)==112,"rank-three GNU ABI");
typedef void (*post_fn)(const void*,const void*,const void*,const int32_t*,const int32_t*,
                       const int32_t*,const struct descriptor2*,struct descriptor2*);
typedef void (*spcm_fn)(const void*,void*,const char*,void*,void*,size_t);
extern void spcimpfpost_assembly_(const void*,const void*,const void*,const int32_t*,const int32_t*,
 const int32_t*,const struct descriptor2*,struct descriptor2*);
struct scope {
    const void *geometry;
    void *spectral_field;
    struct descriptor3 descriptor;
    double *parent;
    size_t elements;
    uint64_t visit;
    char configuration;
    size_t configuration_length;
    int valid;
};
static _Thread_local struct scope current_scope;
static pthread_once_t once=PTHREAD_ONCE_INIT;
static pthread_mutex_t lock=PTHREAD_MUTEX_INITIALIZER;
static post_fn original_post;
static spcm_fn original_spcm;
static double *omega_address;
static FILE *source_file,*native_file,*input_file;
static uint64_t calls,scope_calls,output_bytes,input_bytes,zero_wave_calls,empty_neighbor_calls;
static uint64_t mode_calls[64];
static void fail(const char *message)
{
    fprintf(stderr,"SPCIMPFPOST forecast FAIL %s\n",message);
    fflush(stderr);
    exit(2);
}
static uint64_t fpcr(void)
{
    uint64_t v;__asm__ volatile("mrs %0,fpcr":"=r"(v));return v;
}
static int32_t load32(const void *p){int32_t x;memcpy(&x,p,4);return x;}
static double load64(const void *p){double x;memcpy(&x,p,8);return x;}
static uint64_t word64(const void *p){uint64_t x;memcpy(&x,p,8);return x;}
static void put32(unsigned char *p,int32_t x){memcpy(p,&x,4);}
static void put64(unsigned char *p,uint64_t x){memcpy(p,&x,8);}
static size_t extent(struct dim d)
{
    if(d.upper<d.lower)return 0;
    const uint64_t x=(uint64_t)d.upper-(uint64_t)d.lower+1;
    if(x>SIZE_MAX)return 0;
    return (size_t)x;
}
static int parent_descriptor(struct scope *s,const void *spectral_field)
{
    struct descriptor3 d;
    memcpy(&d,(const unsigned char*)spectral_field+88,sizeof(d));
    if(d.bytes!=8||d.span!=8||d.type_word!=UINT64_C(0x0000030300000000)||!d.base)return 0;
    const size_t a=extent(d.d[0]),b=extent(d.d[1]),c=extent(d.d[2]);
    if(!a||!b||!c||a>SIZE_MAX/b||a*b>SIZE_MAX/c||a*b*c>SIZE_MAX/8)return 0;
    if(d.d[0].stride!=1||d.d[1].stride!=(int64_t)a||d.d[2].stride!=(int64_t)(a*b))return 0;
    for(int i=0;i<3;i++)if(d.d[i].lower!=1)return 0;
    s->descriptor=d;s->parent=d.base;s->elements=a*b*c;return 1;
}
static void initialize(void)
{
    original_post=(post_fn)dlsym(RTLD_NEXT,"spcimpfpost_");
    original_spcm=(spcm_fn)dlsym(RTLD_NEXT,"spcm_");
    omega_address=dlsym(RTLD_DEFAULT,"__yomcst_MOD_romega");
    if(!original_post||!original_spcm||!omega_address)fail("original entries/constants");
    source_file=fopen("spcimpfpost-fortran.bin","wb");
    native_file=fopen("spcimpfpost-assembly.bin","wb");
    input_file=fopen("spcimpfpost-inputs.bin","wb");
    if(!source_file||!native_file||!input_file)fail("capture files");
}
/* Public read-only query; every output pointer can be null. */
int spcm_forecast_scope(const void *geometry,const double **sp3d,size_t *elements)
{
    if(!current_scope.valid||current_scope.geometry!=geometry)return 0;
    struct descriptor3 d;
    memcpy(&d,(const unsigned char*)current_scope.spectral_field+88,sizeof(d));
    if(memcmp(&d,&current_scope.descriptor,sizeof(d)))return 0;
    if(sp3d)*sp3d=current_scope.parent;
    if(elements)*elements=current_scope.elements;
    return 1;
}
/* Five original pointers and the GNU hidden character length are forwarded. */
void spcm_(const void *geometry,void *model,const char *configuration,
           void *spectral_field,void *gmv,size_t configuration_length)
{
    if(pthread_once(&once,initialize))fail("initialization");
    struct scope prior=current_scope;
    struct scope next={0};
    next.geometry=geometry;next.spectral_field=spectral_field;
    next.configuration_length=configuration_length;
    next.configuration=configuration&&configuration_length?configuration[0]:'?';
    if(geometry&&spectral_field)next.valid=parent_descriptor(&next,spectral_field);
    next.visit=__atomic_add_fetch(&scope_calls,1,__ATOMIC_RELAXED);
    current_scope=next;
    original_spcm(geometry,model,configuration,spectral_field,gmv,configuration_length);
    current_scope=prior;
}
static void write_bytes(FILE *f,const void *p,size_t n)
{
    if(n&&fwrite(p,1,n,f)!=n)fail("capture write");
}
static void same_bytes(const void *source,const void *native,size_t bytes,const char *stage,
                       uint64_t sequence,int32_t mode)
{
    if(!memcmp(source,native,bytes))return;
    const unsigned char *a=source,*b=native;size_t i=0;
    while(i<bytes&&a[i]==b[i])i++;
    uint64_t av=0,bv=0;
    if(i/8*8+8<=bytes){memcpy(&av,a+i/8*8,8);memcpy(&bv,b+i/8*8,8);}
    fprintf(stderr,"call=%"PRIu64" m=%d stage=%s byte=%zu parent_cell=%zu source=%016"PRIx64
        " native=%016"PRIx64"\n",sequence,mode,stage,i,i/8,av,bv);
    fail("raw byte difference");
}
static void *copy_bytes(const void *p,size_t n)
{
    void *q=malloc(n?n:1);if(!q)fail("capture allocation");
    if(n)memcpy(q,p,n);
    return q;
}
static int field_shape(const struct descriptor2 *d,const struct descriptor2 *original,
                       const struct scope *s,size_t *offset)
{
    if(d->base!=original->base||d->bytes!=8||d->span!=8||
       d->type_word!=UINT64_C(0x0000030200000000))return 0;
    const size_t rows=extent(d->d[0]),cols=extent(d->d[1]);
    if(rows!=extent(s->descriptor.d[0])||cols!=extent(s->descriptor.d[1])||
       rows!=extent(original->d[0])||cols!=extent(original->d[1])||
       d->d[0].stride!=1||d->d[1].stride!=(int64_t)rows||
       original->d[0].stride!=1||original->d[1].stride!=(int64_t)rows)return 0;
    uintptr_t start=(uintptr_t)s->parent,base=(uintptr_t)d->base;
    const size_t bytes=s->elements*8,field_bytes=rows*cols*8;
    if(base<start||base-start>bytes||field_bytes>bytes-(base-start)||(base-start)%field_bytes)return 0;
    *offset=(size_t)(base-start);return 1;
}
static void immutable(const unsigned char *g,const unsigned char *rip,const unsigned char *dyn,
 const void *spectral,const int32_t *m,const int32_t *ks,const int32_t *ke,
 const struct descriptor2 *div,const struct descriptor2 *vor,const unsigned char *saved,
 uint64_t sequence,int32_t mode,uint64_t omega)
{
    size_t k=0;
#define CHECK_IMMUTABLE(pointer,bytes,label) do{same_bytes(saved+k,pointer,bytes,label,sequence,mode);k+=bytes;}while(0)
    CHECK_IMMUTABLE(g,17096,"geometry");CHECK_IMMUTABLE(rip,175976,"integration");
    CHECK_IMMUTABLE(dyn,4720,"dynamics");CHECK_IMMUTABLE(spectral,2992,"spectral descriptor object");
    CHECK_IMMUTABLE(m,4,"m");CHECK_IMMUTABLE(ks,4,"KSTA");CHECK_IMMUTABLE(ke,4,"KEND");
    CHECK_IMMUTABLE(div,88,"DIV descriptor");CHECK_IMMUTABLE(vor,88,"VOR descriptor");
#undef CHECK_IMMUTABLE
    if(word64(omega_address)!=omega||fpcr()!=0)fail("global ROMEGA/FPCR changed");
}
static unsigned char *configuration_snapshot(const unsigned char *g,const unsigned char *rip,
 const unsigned char *dyn,const void *spectral,const int32_t *m,const int32_t *ks,
 const int32_t *ke,const struct descriptor2 *div,const struct descriptor2 *vor)
{
    const size_t bytes=17096+175976+4720+2992+12+176;
    unsigned char *copy=malloc(bytes);if(!copy)fail("configuration snapshot");
    size_t k=0;
#define SAVE(pointer,count) do{memcpy(copy+k,pointer,count);k+=count;}while(0)
    SAVE(g,17096);SAVE(rip,175976);SAVE(dyn,4720);SAVE(spectral,2992);
    SAVE(m,4);SAVE(ks,4);SAVE(ke,4);SAVE(div,88);SAVE(vor,88);
#undef SAVE
    return copy;
}
static void permitted_bytes(const double *before,const double *after,const unsigned char *mask,
 size_t cells,uint64_t sequence,int32_t mode,const char *stage)
{
    for(size_t i=0;i<cells;i++){
        if(!mask[i])same_bytes(before+i,after+i,8,stage,sequence,mode);
        else if(!isfinite(after[i]))fail("non-finite returned active vorticity");
    }
}
void spcimpfpost_(const void *geometry,const void *integration,const void *dynamics,
 const int32_t *m,const int32_t *ks,const int32_t *ke,const struct descriptor2 *div,
 struct descriptor2 *vor)
{
    if(pthread_once(&once,initialize))fail("initialization");
    if(pthread_mutex_lock(&lock))fail("capture lock");
    const unsigned char *g=geometry,*rip=integration,*dyn=dynamics;
    const double *parent=NULL;size_t elements=0;
    if(!spcm_forecast_scope(geometry,&parent,&elements))fail("missing/changed real SPCM allocation scope");
    if(omp_in_parallel()&&omp_get_num_threads()!=1)fail("whole-parent observer requires one caller thread");
    const int32_t n=load32(g+5172),l=load32(g+5228),mode=*m,start=*ks,last=*ke;
    if(n<1||mode<0||mode>n||l<0||start<1||
       (int64_t)start+2*((int64_t)n-mode)+1>INT32_MAX)fail("source index domain");
    struct descriptor2 original_div,original_vor;
    memcpy(&original_div,(unsigned char*)current_scope.spectral_field+1608,88);
    memcpy(&original_vor,(unsigned char*)current_scope.spectral_field+1520,88);
    size_t div_offset=0,vor_offset=0;
    if(!field_shape(div,&original_div,&current_scope,&div_offset)||
       !field_shape(vor,&original_vor,&current_scope,&vor_offset)||div_offset==vor_offset)
        fail("full original DIV/VOR field views");
    const size_t rows=extent(current_scope.descriptor.d[0]),cols=extent(current_scope.descriptor.d[1]);
    if((uint64_t)l>rows||(uint64_t)((int64_t)start+2*((int64_t)n-mode)+1)>cols)fail("field bounds");
    const double beta=load64(dyn+2496),dt=load64(rip+208),omega=*omega_address;
    if(!isfinite(beta)||!isfinite(dt)||!isfinite(omega)||fpcr()!=0)fail("scalar/FPCR precondition");
    const uint64_t omega_bits=word64(omega_address),sequence=calls+1;
    const size_t bytes=elements*8;
    double *before=copy_bytes(parent,bytes),*shadow=copy_bytes(parent,bytes);
    unsigned char *mask=calloc(elements,1);if(!mask)fail("allowed mutation mask");
    for(int32_t degree=mode;degree<=n;degree++){
        const int lower=mode?degree>=mode+1:degree>=2;
        const int upper=mode?degree<n:(degree>=1&&degree<n);
        if(!lower&&!upper)continue;
        const size_t j=(size_t)(start+2*(degree-mode)-1);
        for(int32_t level=0;level<l;level++){
            size_t k=vor_offset/8+(size_t)level+j*rows;
            mask[k]=1;if(mode)mask[k+rows]=1;
            if(!isfinite(before[k])||(mode&&!isfinite(before[k+rows])))fail("finite initial vorticity");
            if(lower){
                size_t q=div_offset/8+(size_t)level+(j-2)*rows;
                if(!isfinite(before[q])||(mode&&!isfinite(before[q+rows])))fail("finite lower divergence");
            }
            if(upper){
                size_t q=div_offset/8+(size_t)level+(j+2)*rows;
                if(!isfinite(before[q])||(mode&&!isfinite(before[q+rows])))fail("finite upper divergence");
            }
        }
    }
    unsigned char *saved=configuration_snapshot(g,rip,dyn,current_scope.spectral_field,m,ks,ke,div,vor);
    struct descriptor2 source_div=*div,source_vor=*vor;
    source_div.base=(double*)((unsigned char*)shadow+div_offset);
    source_vor.base=(double*)((unsigned char*)shadow+vor_offset);
    const struct descriptor2 div_before=source_div,vor_before=source_vor;
    original_post(geometry,integration,dynamics,m,ks,ke,&source_div,&source_vor);
    immutable(g,rip,dyn,current_scope.spectral_field,m,ks,ke,div,vor,saved,sequence,mode,omega_bits);
    same_bytes(&div_before,&source_div,88,"shadow DIV descriptor",sequence,mode);
    same_bytes(&vor_before,&source_vor,88,"shadow VOR descriptor",sequence,mode);
    permitted_bytes(before,shadow,mask,elements,sequence,mode,"source inactive parent");
    spcimpfpost_assembly_(geometry,integration,dynamics,m,ks,ke,div,vor);
    immutable(g,rip,dyn,current_scope.spectral_field,m,ks,ke,div,vor,saved,sequence,mode,omega_bits);
    permitted_bytes(before,parent,mask,elements,sequence,mode,"native inactive parent");
    same_bytes(shadow,parent,bytes,"complete shared SP3D parent",sequence,mode);

    unsigned char header[256]={0};
    memcpy(header,"POSTFC01",8);
    put64(header+8,sequence);put64(header+16,current_scope.visit);
    put32(header+24,mode);put32(header+28,start);put32(header+32,last);
    put32(header+36,n);put32(header+40,l);
    put32(header+44,(int32_t)extent(current_scope.descriptor.d[2]));
    put64(header+48,rows);put64(header+56,cols);put64(header+64,bytes);
    put64(header+72,div_offset);put64(header+80,vor_offset);
    memcpy(header+88,&dt,8);memcpy(header+96,&beta,8);memcpy(header+104,&omega,8);
    put64(header+112,fpcr());
    put64(header+120,extent(div->d[0]));put64(header+128,extent(div->d[1]));
    put64(header+136,extent(vor->d[0]));put64(header+144,extent(vor->d[1]));
    put64(header+152,(uint64_t)div->d[0].stride);put64(header+160,(uint64_t)div->d[1].stride);
    put64(header+168,(uint64_t)vor->d[0].stride);put64(header+176,(uint64_t)vor->d[1].stride);
    put64(header+184,288);header[192]=(unsigned char)current_scope.configuration;
    put64(header+200,current_scope.configuration_length);
    write_bytes(source_file,header,256);write_bytes(source_file,shadow,bytes);
    write_bytes(native_file,header,256);write_bytes(native_file,parent,bytes);
    struct descriptor3 normalized_parent=current_scope.descriptor;
    struct descriptor2 normalized_div=*div,normalized_vor=*vor;
    normalized_parent.base=NULL;normalized_div.base=NULL;normalized_vor.base=NULL;
    write_bytes(input_file,header,256);write_bytes(input_file,before,bytes);
    write_bytes(input_file,&normalized_parent,112);
    write_bytes(input_file,&normalized_div,88);write_bytes(input_file,&normalized_vor,88);
    calls++;output_bytes+=256+bytes;input_bytes+=256+bytes+288;
    if(mode==0)zero_wave_calls++;
    if(mode==n)empty_neighbor_calls++;
    if(mode<64)mode_calls[mode]++;
    free(before);free(shadow);free(mask);free(saved);
    if(pthread_mutex_unlock(&lock))fail("capture unlock");
}
__attribute__((destructor)) static void report(void)
{
    if(!source_file)return;
    if(fclose(source_file)||fclose(native_file)||fclose(input_file))fail("capture close");
    FILE *f=fopen("spcimpfpost-summary.json","wb");if(!f)fail("summary");
    fprintf(f,"{\n \"passed\":true,\n \"calls\":%"PRIu64",\n \"spcm_visits\":%"PRIu64
      ",\n \"canonical_bytes\":%"PRIu64",\n \"input_bytes\":%"PRIu64
      ",\n \"zero_wave_calls\":%"PRIu64",\n \"empty_neighbor_calls\":%"PRIu64
      ",\n \"differing_bytes\":0,\n \"fpcr\":0,\n \"mode_calls\":[",
      calls,scope_calls,output_bytes,input_bytes,zero_wave_calls,empty_neighbor_calls);
    for(size_t i=0;i<64;i++)fprintf(f,"%s%"PRIu64,i?",":"",mode_calls[i]);
    fprintf(f,"]\n}\n");fclose(f);
    fprintf(stderr,"SPCIMPFPOST forecast calls%"PRIu64" bytes%"PRIu64
      " whole shared SP3D parent differing_bytes0 FPCR0\n",calls,output_bytes);
}

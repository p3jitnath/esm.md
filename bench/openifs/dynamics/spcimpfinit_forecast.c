/* Compare complete SPCIMPFINIT calls inside the original SPCM caller.
 * POST owns the only SPCM relay. Its query supplies the complete SP3D parent;
 * the incoming AUX descriptor supplies its separate full allocation.
 * The source shadow and native call preserve every physical view offset.
 */
#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <inttypes.h>
#include <dlfcn.h>
#include <pthread.h>
#include <stddef.h>

typedef struct {
    double *data;
    int64_t offset;
    uint64_t elem;
    int32_t version;
    int8_t rank,type;
    int16_t attribute;
    int64_t span;
    struct {int64_t stride,lower,upper;} dim[2];
} Desc;
typedef void (*Entry)(const void *,const void *,const void *,
                     const int32_t *,const int32_t *,const int32_t *,
                     const Desc *,const Desc *);
typedef int (*Scope)(const void *,const double **,size_t *);
extern void spcimpfinit_assembly_(const void *,const void *,const void *,
                                const int32_t *,const int32_t *,const int32_t *,
                                const Desc *,const Desc *);
static Entry source;
static Scope scope;
static double *rotation;
static int32_t *step;
static FILE *native_file,*source_file,*input_file;
static pthread_mutex_t lock=PTHREAD_MUTEX_INITIALIZER;
static pthread_once_t once=PTHREAD_ONCE_INIT;
static uint64_t calls,m0_calls,positive_calls,allocation_bytes,active_vorticity,active_auxiliary;
static uint64_t admissibility_values,science_values,source_shadow_calls;
static unsigned long long last_fpcr;
static uint64_t fpcr(void) {uint64_t u;__asm__ volatile("mrs %0,fpcr":"=r"(u));return u;}
static uint64_t bits(double x) {uint64_t u;memcpy(&u,&x,8);return u;}
static int32_t i32(const void *p,size_t off) {int32_t x;memcpy(&x,(const char *)p+off,4);return x;}
static double f64(const void *p,size_t off) {double x;memcpy(&x,(const char *)p+off,8);return x;}
static void fail(const char *s) {fprintf(stderr,"SPCIMPFINIT FORECAST FAIL call=%" PRIu64 " %s\n",calls,s);abort();}
static void *allocate(size_t n) {void *p=malloc(n?n:1);if(!p)fail("allocation");return p;}
static void write_bytes(FILE *f,const void *p,size_t n) {
    if(n && fwrite(p,1,n,f)!=n)fail("stream write");
}
static void unchanged(const void *p,const void *q,size_t n,const char *name) {
    if(memcmp(p,q,n))fail(name);
}
static void initialize(void) {
    _Static_assert(sizeof(Desc)==88,"GNU rank-two descriptor");
    source=(Entry)dlsym(RTLD_NEXT,"spcimpfinit_");
    scope=(Scope)dlsym(RTLD_DEFAULT,"spcm_forecast_scope");
    rotation=dlsym(RTLD_DEFAULT,"__yomcst_MOD_romega");
    step=dlsym(RTLD_DEFAULT,"__yomct3_MOD_nstep");
    if(!source || !scope || !rotation)fail("missing unchanged source or POST-owned SPCM query");
    Dl_info binding={0},original={0};
    void *original_caller=dlsym(RTLD_NEXT,"ec_phys_drv_");
    if(!original_caller || !dladdr(original_caller,&original)
       || !dladdr((const void *)source,&binding) || !binding.dli_fname
       || binding.dli_fbase!=original.dli_fbase)
        fail("source and original caller do not share the frozen forecast image");
    fprintf(stderr,"SPCIMPFINIT SOURCE image=%s\n",binding.dli_fname);
    native_file=fopen("spcimpfinit-assembly.bin","wb");
    source_file=fopen("spcimpfinit-fortran.bin","wb");
    input_file=fopen("spcimpfinit-input.bin","wb");
    if(!native_file || !source_file || !input_file)fail("open canonical streams");
}
static int64_t extent(const Desc *d,int j) {
    if(d->dim[j].upper<d->dim[j].lower)return 0;
    return d->dim[j].upper-d->dim[j].lower+1;
}
static size_t plane(const Desc *d) {
    int64_t r=extent(d,0),c=extent(d,1);
    if(r<0 || c<0 || (uint64_t)r>SIZE_MAX/8
       || (c && (uint64_t)r>SIZE_MAX/(8*(uint64_t)c)))fail("descriptor capacity overflow");
    return (size_t)r*(size_t)c;
}
static void valid_descriptor(const Desc *d) {
    if(d->elem!=8 || d->span!=8 || d->rank!=2 || d->type!=3)
        fail("FP64 real rank-two descriptor required");
}
static double at(const unsigned char *base,size_t offset,const Desc *d,int j,int col) {
    int64_t k=((int64_t)j-1)*d->dim[0].stride+((int64_t)col-1)*d->dim[1].stride;
    double x;memcpy(&x,base+offset+(size_t)(8*k),8);return x;
}
static void finite_input(double x) {
    admissibility_values++;
    if(!isfinite(x))fail("active vorticity or returned auxiliary is not finite");
}
static long double alpha(int m,int n,long double c) {
    return (m && n)?c*(long double)m/((long double)n*((long double)n+1)):0;
}
static void prime(const unsigned char *before,size_t voff,const Desc *v,
                  int m,int sta,int n,int j,long double c,long double *r,long double *i) {
    int col=sta+2*(n-m);
    long double u=at(before,voff,v,j,col),z=at(before,voff,v,j,col+1);
    long double a=alpha(m,n,c),d=1/(1+a*a);
    if(!m) {*r=u;*i=z;return;}
    *r=d*(u-a*z);*i=d*(z+a*u);
}
static void close_physics(const char *name,long double actual,long double expected,
                          long double scale,long double floor,int n,int j) {
    science_values++;
    long double tolerance=4096.0L*DBL_EPSILON*fmaxl(scale,LDBL_MIN)+floor;
    if(!isfinite(actual) || fabsl(actual-expected)>tolerance) {
        fprintf(stderr,"SPCIMPFINIT FORECAST SCIENCE FAIL call=%" PRIu64
                       " check=%s degree=%d level=%d actual=%.21Lg expected=%.21Lg error=%.6Lg tolerance=%.6Lg\n",
                calls,name,n,j,actual,expected,fabsl(actual-expected),tolerance);
        abort();
    }
}
static void physics(int nmax,int l,int m,int sta,const unsigned char *before,
                    const unsigned char *after,size_t voff,const Desc *v,
                    const unsigned char *aux,const Desc *a,double b,double t,double w) {
    long double c=2*(long double)b*(long double)t*(long double)w;
    for(int n=m;n<=nmax;n++) {
        long double al=alpha(m,n,c),fm=0,fp=0;
        if(n>m)fm=c*((long double)n+1)/(long double)n
                    *sqrtl(((long double)n*n-(long double)m*m)/(4*(long double)n*n-1));
        if(n<nmax && n)fp=c*(long double)n/((long double)n+1)
                    *sqrtl((((long double)n+1)*((long double)n+1)-(long double)m*m)
                           /(4*((long double)n+1)*((long double)n+1)-1));
        for(int j=1;j<=l;j++) {
            int col=sta+2*(n-m);
            long double u=at(before,voff,v,j,col),z=at(before,voff,v,j,col+1);
            long double r=at(after,voff,v,j,col),i=at(after,voff,v,j,col+1);
            long double floor=64.0L*DBL_TRUE_MIN*(1+fabsl(al));
            finite_input((double)r);finite_input((double)i);
            close_physics("inverse real",r+al*i,u,fabsl(r)+fabsl(al*i)+fabsl(u),floor,n,j);
            close_physics("inverse imag",i-al*r,z,fabsl(i)+fabsl(al*r)+fabsl(z),floor,n,j);
            if(m) {
                long double e=(u*u+z*z)/(1+al*al);
                close_physics("inverse amplitude",r*r+i*i,e,r*r+i*i+e,
                              128.0L*DBL_TRUE_MIN*(1+fabsl(r)+fabsl(i)),n,j);
            } else if(bits((double)r)!=bits((double)u) || bits((double)i)!=bits((double)z))
                fail("zero-mode vorticity changed bits");
            long double lowr=0,lowi=0,highr=0,highi=0;
            if(n>m)prime(before,voff,v,m,sta,n-1,j,c,&lowr,&lowi);
            if(n<nmax && n)prime(before,voff,v,m,sta,n+1,j,c,&highr,&highi);
            long double er=fm*lowr+fp*highr,ei=fm*lowi+fp*highi;
            long double weight=fabsl(fm)*(fabsl(lowr)+fabsl(lowi))
                              +fabsl(fp)*(fabsl(highr)+fabsl(highi));
            long double afloor=128.0L*DBL_TRUE_MIN*(1+fabsl(fm)+fabsl(fp))*(1+fabsl(al));
            double ar=at(aux,0,a,j,col),ai=at(aux,0,a,j,col+1);
            finite_input(ar);finite_input(ai);
            close_physics("neighbor real",ar,er,fabsl(er)+weight,afloor,n,j);
            close_physics("neighbor imag",ai,ei,fabsl(ei)+weight,afloor,n,j);
            if((m==0 && n==0) || m==nmax) {
                if(bits(ar) || bits(ai))fail("zero endpoint auxiliary changed bits");
            }
        }
    }
}
static void compare_parent(const unsigned char *a,const unsigned char *b,
                           size_t elements,size_t rows,size_t cols,const char *name) {
    if(!memcmp(a,b,elements*8))return;
    for(size_t k=0;k<elements;k++)if(memcmp(a+8*k,b+8*k,8)) {
        uint64_t u,w;memcpy(&u,a+8*k,8);memcpy(&w,b+8*k,8);
        size_t p=rows*cols;
        fprintf(stderr,"SPCIMPFINIT FORECAST BITS call=%" PRIu64
                       " allocation=%s field=%zu level=%zu column=%zu bits=%016" PRIx64 "/%016" PRIx64 "\n",
                calls,name,p?k/p:0,rows?k%rows+1:0,rows?(k/rows)%cols+1:0,u,w);
        abort();
    }
}
static void allowed_mutation(const unsigned char *before,const unsigned char *after,
                             size_t elements,const unsigned char *allowed,const char *name) {
    for(size_t k=0;k<elements;k++)if(!allowed[k] && memcmp(before+8*k,after+8*k,8)) {
        uint64_t a,b;memcpy(&a,before+8*k,8);memcpy(&b,after+8*k,8);
        fprintf(stderr,"SPCIMPFINIT FORECAST MUTATION call=%" PRIu64
                       " allocation=%s element=%zu bits=%016" PRIx64 "/%016" PRIx64 "\n",
                calls,name,k,a,b);
        abort();
    }
}
void spcimpfinit_(const void *g,const void *rip,const void *dyn,
                 const int32_t *mp,const int32_t *sp,const int32_t *ep,
                 const Desc *vor,const Desc *aux) {
    void *caller=__builtin_return_address(0);
    pthread_once(&once,initialize);
    pthread_mutex_lock(&lock);
    calls++;
    uint64_t control=fpcr();
    if(control)fail("entry FPCR");
    int n=i32(g,5172),l=i32(g,5228),m=*mp,sta=*sp,end=*ep;
    int rows_capacity=i32(g,5236),cols_capacity=i32(g,5200);
    if(n<1 || n==INT32_MAX || m<0 || m>n || l<0 || sta<1
       || (int64_t)sta+2*((int64_t)n-m)+1>INT32_MAX)fail("source integer domain");
    int last=sta+2*(n-m)+1;
    valid_descriptor(vor);valid_descriptor(aux);
    int64_t vr=extent(vor,0),vc=extent(vor,1),ar=extent(aux,0),ac=extent(aux,1);
    if(vr<l || ar<l || vc<last || ac<last)fail("selected descriptor bounds");
    if(vor->dim[0].stride!=1 || vor->dim[1].stride!=vr
       || aux->dim[0].stride!=1 || aux->dim[1].stride!=ar
       || ar!=rows_capacity || ac!=cols_capacity || vc!=cols_capacity)
        fail("full original SPCM allocation provenance");
    size_t parent_elements=0;
    const double *parent=NULL;
    if(!scope(g,&parent,&parent_elements))fail("no matching original SPCM scope");
    if(parent_elements>SIZE_MAX/8)fail("parent byte overflow");
    size_t parent_bytes=parent_elements*8,aux_elements=plane(aux),aux_bytes=aux_elements*8;
    size_t view_elements=plane(vor),view_bytes=view_elements*8;
    uintptr_t parent_address=(uintptr_t)parent,vor_address=(uintptr_t)vor->data;
    if(vor_address<parent_address || vor_address-parent_address>parent_bytes
       || view_bytes>parent_bytes-(vor_address-parent_address)
       || ((vor_address-parent_address)&7))fail("VOR view outside complete SP3D parent");
    size_t voff=(size_t)(vor_address-parent_address);
    if(view_bytes && voff%view_bytes)fail("VOR is not a complete SP3D field plane");
    uintptr_t aux_address=(uintptr_t)aux->data;
    if(parent_bytes && aux_bytes && aux_address<parent_address+parent_bytes
       && parent_address<aux_address+aux_bytes)fail("AUX overlaps shared SP3D");
    double b=f64(dyn,2496),t=f64(rip,208),w=*rotation;
    if(!isfinite(b) || !isfinite(t) || !isfinite(w))fail("finite scalar input");
    unsigned char *input_objects=allocate(17096+4720+175976);
    memcpy(input_objects,g,17096);memcpy(input_objects+17096,dyn,4720);
    memcpy(input_objects+21816,rip,175976);
    int32_t ints[3]={m,sta,end};
    Desc before_v=*vor,before_a=*aux;
    unsigned char *before_parent=allocate(parent_bytes),*shadow_parent=allocate(parent_bytes);
    unsigned char *before_aux=allocate(aux_bytes),*shadow_aux=allocate(aux_bytes);
    memcpy(before_parent,parent,parent_bytes);memcpy(shadow_parent,parent,parent_bytes);
    memcpy(before_aux,aux->data,aux_bytes);memcpy(shadow_aux,aux->data,aux_bytes);
    unsigned char *allowed_parent=calloc(parent_elements?parent_elements:1,1);
    unsigned char *allowed_aux=calloc(aux_elements?aux_elements:1,1);
    if(!allowed_parent || !allowed_aux)fail("write mask allocation");
    for(int degree=m;degree<=n;degree++)for(int j=1;j<=l;j++) {
        int col=sta+2*(degree-m);
        for(int q=0;q<2;q++) {
            size_t vp=voff/8+(size_t)(j-1)+(size_t)(col+q-1)*(size_t)vr;
            size_t ap=(size_t)(j-1)+(size_t)(col+q-1)*(size_t)ar;
            if(vp>=parent_elements || ap>=aux_elements)fail("allowed view index");
            if(m)allowed_parent[vp]=1;
            allowed_aux[ap]=1;
            finite_input(f64(before_parent,8*vp));
        }
    }
    uint64_t head[64]={0};memcpy(head,"SPFI0001",8);
    head[1]=calls;head[2]=control;head[3]=(uint64_t)(int64_t)(step?*step:-1);
    head[4]=n;head[5]=l;head[6]=m;head[7]=sta;head[8]=(uint64_t)(int64_t)end;
    head[9]=vr;head[10]=vc;head[11]=ar;head[12]=ac;head[13]=parent_elements;
    head[14]=voff;head[15]=parent_bytes;head[16]=aux_bytes;
    head[17]=bits(b);head[18]=bits(t);head[19]=bits(w);
    head[20]=(uint64_t)vor->dim[0].stride;head[21]=(uint64_t)vor->dim[1].stride;
    head[22]=(uint64_t)aux->dim[0].stride;head[23]=(uint64_t)aux->dim[1].stride;
    head[24]=m?2*(uint64_t)l*(uint64_t)(n-m+1):0;
    head[25]=2*(uint64_t)l*(uint64_t)(n-m+1);
    head[26]=rows_capacity;head[27]=cols_capacity;head[28]=1;head[29]=4096;
    Desc canonical_v=*vor,canonical_a=*aux;canonical_v.data=NULL;canonical_a.data=NULL;
    memcpy((unsigned char *)head+256,&canonical_v,88);
    memcpy((unsigned char *)head+344,&canonical_a,88);
    Dl_info info={0};
    if(dladdr(caller,&info) && info.dli_sname)
        snprintf((char *)head+448,64,"%s",info.dli_sname);
    else snprintf((char *)head+448,64,"original SPCM scope");
    write_bytes(input_file,head,512);
    write_bytes(input_file,before_parent,parent_bytes);write_bytes(input_file,before_aux,aux_bytes);
    Desc shadow_v=*vor,shadow_a=*aux;
    shadow_v.data=(double *)(shadow_parent+voff);shadow_a.data=(double *)shadow_aux;
    source(g,rip,dyn,mp,sp,ep,&shadow_v,&shadow_a);
    source_shadow_calls++;
    if(fpcr())fail("source FPCR");
    unchanged(g,input_objects,17096,"source changed geometry");
    unchanged(dyn,input_objects+17096,4720,"source changed dynamics");
    unchanged(rip,input_objects+21816,175976,"source changed time object");
    if(*mp!=ints[0] || *sp!=ints[1] || *ep!=ints[2] || bits(*rotation)!=bits(w))
        fail("source changed scalar input");
    unchanged(vor,&before_v,88,"source changed original VOR descriptor");
    unchanged(aux,&before_a,88,"source changed original AUX descriptor");
    if(shadow_v.data!=(double *)(shadow_parent+voff) || shadow_a.data!=(double *)shadow_aux)
        fail("source changed shadow descriptor data");
    Desc after_shadow_v=shadow_v,after_shadow_a=shadow_a;
    after_shadow_v.data=NULL;after_shadow_a.data=NULL;
    unchanged(&after_shadow_v,&canonical_v,88,"source changed VOR descriptor metadata");
    unchanged(&after_shadow_a,&canonical_a,88,"source changed AUX descriptor metadata");
    allowed_mutation(before_parent,shadow_parent,parent_elements,allowed_parent,"source SP3D");
    allowed_mutation(before_aux,shadow_aux,aux_elements,allowed_aux,"source AUX");
    physics(n,l,m,sta,before_parent,shadow_parent,voff,vor,shadow_aux,aux,b,t,w);
    spcimpfinit_assembly_(g,rip,dyn,mp,sp,ep,vor,aux);
    if(fpcr())fail("native FPCR");
    unchanged(g,input_objects,17096,"native changed geometry");
    unchanged(dyn,input_objects+17096,4720,"native changed dynamics");
    unchanged(rip,input_objects+21816,175976,"native changed time object");
    if(*mp!=ints[0] || *sp!=ints[1] || *ep!=ints[2] || bits(*rotation)!=bits(w))
        fail("native changed scalar input");
    unchanged(vor,&before_v,88,"native changed VOR descriptor");
    unchanged(aux,&before_a,88,"native changed AUX descriptor");
    allowed_mutation(before_parent,(const unsigned char *)parent,parent_elements,allowed_parent,"native SP3D");
    allowed_mutation(before_aux,(const unsigned char *)aux->data,aux_elements,allowed_aux,"native AUX");
    compare_parent((const unsigned char *)parent,shadow_parent,parent_elements,(size_t)vr,(size_t)vc,"SP3D");
    compare_parent((const unsigned char *)aux->data,shadow_aux,aux_elements,(size_t)ar,(size_t)ac,"AUX");
    write_bytes(native_file,head,512);write_bytes(source_file,head,512);
    write_bytes(native_file,parent,parent_bytes);write_bytes(source_file,shadow_parent,parent_bytes);
    write_bytes(native_file,aux->data,aux_bytes);write_bytes(source_file,shadow_aux,aux_bytes);
    allocation_bytes+=parent_bytes+aux_bytes;
    active_vorticity+=head[24];active_auxiliary+=head[25];
    m0_calls+=m==0;positive_calls+=m>0;last_fpcr=fpcr();
    free(input_objects);free(before_parent);free(shadow_parent);free(before_aux);free(shadow_aux);
    free(allowed_parent);free(allowed_aux);
    pthread_mutex_unlock(&lock);
}
__attribute__((destructor)) static void finish(void) {
    if(!calls)return;
    fclose(native_file);fclose(source_file);fclose(input_file);
    fprintf(stderr,"SPCIMPFINIT FORECAST PASS genuine_calls=%" PRIu64 " m0=%" PRIu64
                   " mpositive=%" PRIu64 " allocation_bytes=%" PRIu64
                   " active_vorticity_values=%" PRIu64 " active_auxiliary_values=%" PRIu64
                   " admissibility_values=%" PRIu64 " science_values=%" PRIu64
                   " source_shadow_calls=%" PRIu64 " numerical_dependency_calls=0"
                   " differing_bytes=0 FPCR=%016llx\n",
            calls,m0_calls,positive_calls,allocation_bytes,active_vorticity,active_auxiliary,
            admissibility_values,science_values,source_shadow_calls,last_fpcr);
}

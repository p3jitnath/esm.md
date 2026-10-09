/* Compare the complete SIGAM operator while preserving source-proven parent
 * capacities and view aliases. A single LASSIE relay supplies read-only scope
 * metadata to this driver and SITNU; it forwards every original argument.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>
#include <pthread.h>

#define SIGAM_ARGS const void *geometry,const void *dyn,const int32_t *a, \
 const int32_t *b,double *pd,const double *pt,const double *ps, \
 const int32_t *c,const int32_t *l
typedef void (*sigam_fn)(SIGAM_ARGS);
void sigam_assembly_(SIGAM_ARGS);
#define LASSIE_ARGS const void *geometry,void *gmv_config,const void *gfl_config, \
 const void *dyn,const void *dyna,const int32_t *ks,const int32_t *ke, \
 const double *coriolis,const double *gmv,const double *gmvs,const double *gfl, \
 double *ps0,double *ps9,double *t0,double *t9, \
 double *grad0l,double *grad0m,double *grad9l,double *grad9m
#define LASSIE_PASS geometry,gmv_config,gfl_config,dyn,dyna,ks,ke,coriolis, \
 gmv,gmvs,gfl,ps0,ps9,t0,t9,grad0l,grad0m,grad9l,grad9m
typedef void (*lassie_fn)(LASSIE_ARGS);
struct scope {
    const void *geometry,*dyn;
    int32_t ks,ke,p,l;
    const double *gmv,*gmvs;
    size_t gmv_elements,gmvs_elements;
    const double *gradients[4];
};
static _Thread_local const struct scope *current_scope;
static lassie_fn source_lassie;
static sigam_fn source_sigam;
static void (*reference_begin)(void),(*reference_end)(void);
static const int32_t *step;
static double *rd;
static FILE *assembly_stream,*reference_stream,*input_stream;
static pthread_once_t lassie_once=PTHREAD_ONCE_INIT,sigam_once=PTHREAD_ONCE_INIT;
static pthread_mutex_t capture_lock=PTHREAD_MUTEX_INITIALIZER;
static uint64_t calls,bytes,input_bytes,mode_calls[2],caller_calls[4],lassie_calls;

static _Noreturn void fail(const char *format,...)
{
    va_list ap;va_start(ap,format);fprintf(stderr,"SIGAM forecast check failed: ");
    vfprintf(stderr,format,ap);va_end(ap);fputc('\n',stderr);_Exit(2);
}
static int32_t integer(const void *p,size_t offset)
{
    int32_t result;memcpy(&result,(const char *)p+offset,4);return result;
}
static int64_t word(const void *p,size_t offset)
{
    int64_t result;memcpy(&result,(const char *)p+offset,8);return result;
}
static const void *pointer(const void *p,size_t offset)
{
    const void *result;memcpy(&result,(const char *)p+offset,8);return result;
}
static double real(const void *p,size_t offset)
{
    double result;memcpy(&result,(const char *)p+offset,8);return result;
}
static uint64_t bits(const void *p)
{
    uint64_t result;memcpy(&result,p,8);return result;
}
static uint64_t fpcr(void)
{
    uint64_t result;__asm__ volatile("mrs %0,fpcr":"=r"(result));return result;
}
static void store_word(void *p,size_t offset,uint64_t value)
{
    memcpy((char *)p+offset,&value,8);
}
static void store_integer(void *p,size_t offset,int32_t value)
{
    memcpy((char *)p+offset,&value,4);
}
static size_t product(size_t a,size_t b)
{
    if(a && b>(size_t)INT64_MAX/8/a)fail("allocation extent overflow");
    return a*b;
}
static size_t extent(int64_t lower,int64_t upper)
{
    if(upper<lower)return 0;
    uint64_t count=(uint64_t)upper-(uint64_t)lower+1;
    if(!count||count>(uint64_t)INT64_MAX/8)fail("descriptor extent overflow");
    return (size_t)count;
}
static uintptr_t end_address(const void *p,size_t count)
{
    uintptr_t start=(uintptr_t)p;
    if(!p||(start&7)||start>UINTPTR_MAX-count)fail("buffer address or alignment");
    return start+count;
}
static int contains(const void *p,size_t n,const void *q,size_t m)
{
    return (uintptr_t)q>=(uintptr_t)p && end_address(q,m)<=end_address(p,n);
}
static int overlap(const void *p,size_t n,const void *q,size_t m)
{
    uintptr_t pe=end_address(p,n),qe=end_address(q,m);
    return n && m && (uintptr_t)p<qe && (uintptr_t)q<pe;
}
static void *copy(const void *p,size_t n)
{
    void *result=malloc(n?n:8);if(!result)fail("state copy allocation");
    if(n)memcpy(result,p,n);
    return result;
}
static void write_bytes(FILE *f,const void *p,size_t n)
{
    if(n&&fwrite(p,1,n,f)!=n)fail("capture write");
}
static void equal(const void *a,const void *b,size_t n,const char *name)
{
    if(!memcmp(a,b,n))return;
    const unsigned char *x=a,*y=b;size_t i=0;
    while(i<n && x[i]==y[i])++i;
    uint64_t wx=0,wy=0;size_t cell=i/8,k=n-cell*8;k=k>8?8:k;
    memcpy(&wx,x+cell*8,k);memcpy(&wy,y+cell*8,k);
    fail("stage=SIGAM step=%d call=%" PRIu64 " field=%s cell=%zu byte=%zu"
         " source=%016" PRIx64 " native=%016" PRIx64,
         step?*step:-1,calls,name,cell,i,wx,wy);
}
static void initialize_lassie(void)
{
    void *symbol=dlsym(RTLD_NEXT,"lassie_");if(!symbol)fail("original LASSIE entry");
    memcpy(&source_lassie,&symbol,sizeof source_lassie);
}
/* Nullable outputs make this query usable by either owned comparator. */
int lassie_forecast_scope(const void *geometry,int32_t *ks,int32_t *ke,
    const double **gmv,size_t *gmv_elements,const double **gmvs,size_t *gmvs_elements)
{
    const struct scope *s=current_scope;
    if(!s||s->geometry!=geometry)return 0;
    if(ks)*ks=s->ks;
    if(ke)*ke=s->ke;
    if(gmv)*gmv=s->gmv;
    if(gmv_elements)*gmv_elements=s->gmv_elements;
    if(gmvs)*gmvs=s->gmvs;
    if(gmvs_elements)*gmvs_elements=s->gmvs_elements;
    return 1;
}
void lassie_(LASSIE_ARGS)
{
    pthread_once(&lassie_once,initialize_lassie);
    if(!geometry||!gmv_config||!ks||!ke)fail("LASSIE scope addresses");
    int32_t p=integer(geometry,5144),l=integer(geometry,5224);
    int32_t fields=integer(gmv_config,992),surface_fields=integer(gmv_config,996);
    if(p<1||l<1||fields<1||surface_fields<1||*ks<1||*ke<*ks||*ke>p)
        fail("LASSIE scope dimensions");
    struct scope s={geometry,dyn,*ks,*ke,p,l,gmv,gmvs,
        product(product((size_t)p,(size_t)l),(size_t)fields),
        product((size_t)p,(size_t)surface_fields),{grad0l,grad0m,grad9l,grad9m}};
    end_address(gmv,s.gmv_elements*8);end_address(gmvs,s.gmvs_elements*8);
    const struct scope *prior=current_scope;current_scope=&s;
    __atomic_add_fetch(&lassie_calls,1,__ATOMIC_RELAXED);
    source_lassie(LASSIE_PASS);
    current_scope=prior;
}
static void initialize_sigam(void)
{
    void *symbol=dlsym(RTLD_NEXT,"sigam_");if(!symbol)fail("original SIGAM entry");
    memcpy(&source_sigam,&symbol,sizeof source_sigam);
    step=dlsym(RTLD_DEFAULT,"__yomct3_MOD_nstep");
    rd=dlsym(RTLD_DEFAULT,"__yomcst_MOD_rd");
    void *begin=dlsym(RTLD_DEFAULT,"vertical_forecast_reference_begin");
    void *end=dlsym(RTLD_DEFAULT,"vertical_forecast_reference_end");
    if(!step||!rd||!begin||!end)fail("strict vertical comparison dependencies");
    memcpy(&reference_begin,&begin,sizeof reference_begin);
    memcpy(&reference_end,&end,sizeof reference_end);
    assembly_stream=fopen("sigam-assembly.bin","wb");
    reference_stream=fopen("sigam-fortran.bin","wb");
    input_stream=fopen("sigam-inputs.bin","wb");
    if(!assembly_stream||!reference_stream||!input_stream)fail("capture open");
}
struct range {
    const unsigned char *base;
    size_t bytes;
    uint32_t roles;
    unsigned char *before,*shadow,*writable;
};
struct parents {struct range r[5];size_t count;};
static void add_range(struct parents *p,const void *base,size_t bytes,uint32_t roles)
{
    if(p->count==5)fail("parent range count");
    end_address(base,bytes);
    p->r[p->count++]=(struct range){base,bytes,roles,NULL,NULL,NULL};
}
static void coalesce(struct parents *p)
{
    int changed;
    do {
        changed=0;
        for(size_t i=0;i<p->count;++i)for(size_t j=i+1;j<p->count;){
            if(!overlap(p->r[i].base,p->r[i].bytes,p->r[j].base,p->r[j].bytes)){
                ++j;continue;
            }
            uintptr_t lo=(uintptr_t)p->r[i].base,other=(uintptr_t)p->r[j].base;
            uintptr_t hi=end_address(p->r[i].base,p->r[i].bytes);
            uintptr_t end=end_address(p->r[j].base,p->r[j].bytes);
            if(other<lo)lo=other;
            if(end>hi)hi=end;
            p->r[i].base=(const unsigned char *)lo;p->r[i].bytes=hi-lo;
            p->r[i].roles|=p->r[j].roles;
            memmove(p->r+j,p->r+j+1,(p->count-j-1)*sizeof p->r[0]);
            --p->count;changed=1;
        }
    }while(changed);
    for(size_t i=0;i<p->count;++i){
        struct range *r=p->r+i;
        r->before=copy(r->base,r->bytes);r->shadow=copy(r->base,r->bytes);
        r->writable=calloc(r->bytes/8?r->bytes/8:1,1);
        if(!r->writable)fail("write mask allocation");
    }
}
static size_t range_index(const struct parents *p,const void *view,size_t bytes)
{
    for(size_t i=0;i<p->count;++i)
        if(contains(p->r[i].base,p->r[i].bytes,view,bytes))return i;
    fail("view exceeds source-proven allocation");
}
static size_t view_offset(const struct parents *p,size_t index,const void *view)
{
    return (uintptr_t)view-(uintptr_t)p->r[index].base;
}
static void *shadow_view(const struct parents *p,const void *view,size_t bytes)
{
    size_t i=range_index(p,view,bytes);
    return p->r[i].shadow+view_offset(p,i,view);
}
struct coefficient {const unsigned char *data;size_t bytes;unsigned char *before;};
static struct coefficient vector_coefficient(const void *descriptor,int32_t levels)
{
    const unsigned char *data=pointer(descriptor,0);
    int64_t lower=word(descriptor,48),upper=word(descriptor,56);
    if(!data||word(descriptor,16)!=8||word(descriptor,32)!=8||
       word(descriptor,40)!=1||lower>1||upper<levels||word(descriptor,8)!=-lower)
        fail("allocated coefficient descriptor");
    size_t bytes=extent(lower,upper)*8;end_address(data,bytes);
    return (struct coefficient){data,bytes,copy(data,bytes)};
}
static struct coefficient matrix_coefficient(const void *descriptor,int32_t levels,int32_t ibc)
{
    const unsigned char *data=pointer(descriptor,0);
    int64_t lo1=word(descriptor,48),hi1=word(descriptor,56);
    int64_t lo2=word(descriptor,72),hi2=word(descriptor,80);
    size_t rows=extent(lo1,hi1),columns=extent(lo2,hi2);
    if(!data||word(descriptor,16)!=8||word(descriptor,32)!=8||
       word(descriptor,40)!=1||word(descriptor,64)!=(int64_t)rows||
       rows!=(size_t)levels+1||columns!=(size_t)levels+((ibc==1||ibc==3)?2:0))
        fail("selected vertical matrix descriptor");
    size_t bytes=product(rows,columns)*8;end_address(data,bytes);
    for(size_t i=0;i<bytes/8;++i)if(!isfinite(real(data,i*8)))fail("nonfinite matrix");
    return (struct coefficient){data,bytes,copy(data,bytes)};
}
static void finite_vector(const struct coefficient *coef,const void *descriptor,int32_t levels)
{
    int64_t offset=word(descriptor,8);
    for(int32_t j=1;j<=levels;++j){
        int64_t index=offset+j;
        if(index<0||(uint64_t)index>=coef->bytes/8||!isfinite(real(coef->data,(size_t)index*8)))
            fail("nonfinite active coefficient or offset");
    }
}
static void parent_checks(const struct parents *p)
{
    for(size_t i=0;i<p->count;++i){
        const struct range *r=p->r+i;
        equal(r->shadow,r->base,r->bytes,"complete-parent-allocation");
        for(size_t j=0;j<r->bytes/8;++j)
            if(!r->writable[j]){
                equal(r->before+j*8,r->shadow+j*8,8,"source-immutable-cell");
                equal(r->before+j*8,r->base+j*8,8,"native-immutable-cell");
            }else if(!isfinite(real(r->base,j*8)))fail("nonfinite active PD");
    }
}
static void release_parents(struct parents *p)
{
    for(size_t i=0;i<p->count;++i){
        free(p->r[i].before);free(p->r[i].shadow);free(p->r[i].writable);
    }
}
void sigam_(SIGAM_ARGS)
{
    if(fpcr()!=0)fail("FPCR must be zero");
    if(!geometry||!dyn||!a||!b||!c||!l||*a<1||*b<1||*c<1||*l<1)
        fail("argument addresses or forecast dimensions");
    pthread_once(&sigam_once,initialize_sigam);
    if(pthread_mutex_lock(&capture_lock))fail("capture lock");
    const int32_t scalars[4]={*a,*b,*c,*l};
    int64_t formal=1+(int64_t)(*l-1)* *a+(int64_t)(*c-1)* *b;
    if(formal<1||formal>INT32_MAX)fail("source integer index overflow");
    size_t h=(size_t)formal;
    const void *cv=pointer(geometry,3264),*eta=pointer(geometry,3248),*vfe=pointer(geometry,3256);
    if(!cv)fail("vertical configuration");
    int32_t mode=integer(cv,52)!=0,ibc=integer(cv,36);
    if(mode&&(!eta||!vfe||ibc<0||ibc>3||integer(geometry,5144)<1))
        fail("finite-element configuration");
    int32_t np=integer(geometry,5144),ks=1,ke=*c,caller=0;
    struct parents parents={0};
    size_t out_field=h,temp_field=h,surface_field=(size_t)*c,shift=0;
    const struct scope *s=current_scope;
    if(s&&s->geometry==geometry){
        if(s->dyn!=dyn||*a!=s->p||*b!=1||*l!=s->l||*c!=s->ke-s->ks+1)
            fail("LASSIE active view does not match original call");
        ks=s->ks;ke=s->ke;np=s->p;shift=(size_t)(ks-1);
        out_field=temp_field=product((size_t)np,(size_t)*l);
        surface_field=(size_t)np;caller=1;
        uintptr_t po=(uintptr_t)pd,ptp=(uintptr_t)pt,psp=(uintptr_t)ps;
        if(po<shift*8||ptp<shift*8||psp<shift*8)fail("active view base underflow");
        const void *out_base=(const void *)(po-shift*8);
        int matched=0;
        for(int i=0;i<4;++i)if(out_base==s->gradients[i])matched=1;
        if(!matched||!contains(s->gmv,s->gmv_elements*8,(const void *)(ptp-shift*8),temp_field*8)||
           !contains(s->gmvs,s->gmvs_elements*8,(const void *)(psp-shift*8),surface_field*8))
            fail("LASSIE field exceeds original parent allocation");
        add_range(&parents,s->gmv,s->gmv_elements*8,1);
        add_range(&parents,s->gmvs,s->gmvs_elements*8,2);
    }else{
        Dl_info info;
        if(*a!=1||*b!=*l||!dladdr(__builtin_return_address(0),&info)||!info.dli_sname)
            fail("unreviewed caller allocation");
        if(!strcmp(info.dli_sname,"spcsi_"))caller=2;
        else if(!strcmp(info.dli_sname,"submat_")&&*c==*l)caller=3;
        else fail("unreviewed caller %s",info.dli_sname);
    }
    const void *out_base=(const void *)((uintptr_t)pd-shift*8);
    const void *temp_base=(const void *)((uintptr_t)pt-shift*8);
    const void *surface_base=(const void *)((uintptr_t)ps-shift*8);
    if(overlap(pd,h*8,pt,h*8)||overlap(pd,h*8,ps,(size_t)*c*8))
        fail("writable output overlaps used input view");
    add_range(&parents,out_base,out_field*8,4);
    add_range(&parents,temp_base,temp_field*8,8);
    add_range(&parents,surface_base,surface_field*8,16);
    coalesce(&parents);
    size_t view_ids[3]={range_index(&parents,pd,h*8),range_index(&parents,pt,h*8),
                       range_index(&parents,ps,(size_t)*c*8)};
    size_t view_offsets[3]={view_offset(&parents,view_ids[0],pd),
        view_offset(&parents,view_ids[1],pt),view_offset(&parents,view_ids[2],ps)};
    struct range *output_parent=parents.r+view_ids[0];
    for(int32_t j=0;j<*l;++j)for(int32_t i=0;i<*c;++i){
        size_t index=(size_t)j*(size_t)*a+(size_t)i*(size_t)*b;
        if(index>=h)fail("active index");
        size_t k=view_offsets[0]/8+index;
        if(output_parent->writable[k])fail("overlapping active output cells");
        output_parent->writable[k]=1;
        if(!isfinite(pt[index]))fail("nonfinite active temperature");
    }
    for(int32_t i=0;i<*c;++i)if(!isfinite(ps[i]))fail("nonfinite active surface input");
    const void *config[5]={geometry,dyn,cv,eta,vfe};
    size_t config_sizes[5]={17096,4720,216,mode?320:0,mode?2176:0};
    void *config_before[5]={0};
    for(int i=0;i<5;++i)if(config_sizes[i])config_before[i]=copy(config[i],config_sizes[i]);
    const unsigned char *alpha_desc=(const unsigned char *)dyn+2600;
    const unsigned char *lambda_desc=(const unsigned char *)dyn+2664;
    const unsigned char *rdet_desc=mode?(const unsigned char *)eta+256:NULL;
    struct coefficient coefficients[4]={{0}};
    if(!mode)coefficients[0]=vector_coefficient(alpha_desc,*l);
    coefficients[1]=vector_coefficient(lambda_desc,*l);
    if(mode){
        coefficients[2]=vector_coefficient(rdet_desc,*l);
        coefficients[3]=matrix_coefficient((const unsigned char *)vfe+
            (ibc==0?64:ibc==2?1296:240),*l,ibc);
    }
    if(!mode)finite_vector(coefficients,alpha_desc,*l);
    finite_vector(coefficients+1,lambda_desc,*l);
    if(mode)finite_vector(coefficients+2,rdet_desc,*l);
    uint64_t rd_before=bits(rd),mu_before=bits((const char *)dyn+2560);
    if(!isfinite(*rd)||!isfinite(real(dyn,2560)))fail("nonfinite gas/reference coefficient");
    unsigned char capture_config[2608]={0};
    memcpy(capture_config,(const char *)dyn+2560,8);
    if(!mode){memcpy(capture_config+8,alpha_desc,64);memset(capture_config+8,0,8);}
    memcpy(capture_config+72,lambda_desc,64);memset(capture_config+72,0,8);
    if(mode){
        memcpy(capture_config+136,rdet_desc,64);memset(capture_config+136,0,8);
        memcpy(capture_config+200,vfe,2176);memset(capture_config+200,0,8);
        for(size_t j=0;j<24;++j)memset(capture_config+264+j*88,0,8);
    }
    memcpy(capture_config+2376,cv,216);
    store_integer(capture_config,2592,integer(geometry,5144));
    store_integer(capture_config,2596,integer(geometry,5224));
    unsigned char header[256]={0};memcpy(header,"SGMF0001",8);
    ++calls;++mode_calls[mode];++caller_calls[caller];
    store_word(header,8,calls);store_integer(header,16,*step);
    store_integer(header,20,mode);store_integer(header,24,ibc);store_integer(header,28,caller);
    store_integer(header,32,*a);store_integer(header,36,*b);
    store_integer(header,40,*c);store_integer(header,44,*l);
    store_integer(header,48,np);store_integer(header,52,ks);store_integer(header,56,ke);
    store_integer(header,60,(int32_t)parents.count);
    size_t parent_bytes=0,coefficient_bytes=0;
    for(size_t i=0;i<parents.count;++i){
        store_word(header,64+8*i,parents.r[i].bytes);
        store_integer(header,104+4*i,(int32_t)parents.r[i].roles);
        parent_bytes+=parents.r[i].bytes;
    }
    for(size_t i=0;i<3;++i){
        store_integer(header,128+4*i,(int32_t)view_ids[i]);
        store_word(header,144+8*i,view_offsets[i]);
    }
    for(size_t i=0;i<4;++i){
        store_word(header,168+8*i,coefficients[i].bytes);
        coefficient_bytes+=coefficients[i].bytes;
    }
    store_word(header,200,rd_before);store_word(header,208,mu_before);
    store_word(header,216,fpcr());store_word(header,224,sizeof capture_config);
    write_bytes(input_stream,header,sizeof header);
    for(size_t i=0;i<parents.count;++i)write_bytes(input_stream,parents.r[i].before,parents.r[i].bytes);
    for(size_t i=0;i<4;++i)write_bytes(input_stream,coefficients[i].before,coefficients[i].bytes);
    write_bytes(input_stream,capture_config,sizeof capture_config);

    reference_begin();
    source_sigam(geometry,dyn,a,b,shadow_view(&parents,pd,h*8),
        shadow_view(&parents,pt,h*8),shadow_view(&parents,ps,(size_t)*c*8),c,l);
    reference_end();
    for(int i=0;i<5;++i)if(config_sizes[i])
        equal(config_before[i],config[i],config_sizes[i],"source-immutable-configuration");
    for(int i=0;i<4;++i)if(coefficients[i].bytes)
        equal(coefficients[i].before,coefficients[i].data,coefficients[i].bytes,"source-immutable-coefficient");
    if(fpcr()!=0||bits(rd)!=rd_before||*a!=scalars[0]||*b!=scalars[1]||
       *c!=scalars[2]||*l!=scalars[3])fail("source changed FPCR,RD or scalar input");
    sigam_assembly_(geometry,dyn,a,b,pd,pt,ps,c,l);
    parent_checks(&parents);
    for(int i=0;i<5;++i)if(config_sizes[i]){
        equal(config_before[i],config[i],config_sizes[i],"native-immutable-configuration");
        free(config_before[i]);
    }
    for(int i=0;i<4;++i)if(coefficients[i].bytes){
        equal(coefficients[i].before,coefficients[i].data,coefficients[i].bytes,"native-immutable-coefficient");
        free(coefficients[i].before);
    }
    if(fpcr()!=0||bits(rd)!=rd_before||*a!=scalars[0]||*b!=scalars[1]||
       *c!=scalars[2]||*l!=scalars[3])fail("native changed FPCR,RD or scalar input");
    write_bytes(reference_stream,header,sizeof header);write_bytes(assembly_stream,header,sizeof header);
    for(size_t i=0;i<parents.count;++i){
        write_bytes(reference_stream,parents.r[i].shadow,parents.r[i].bytes);
        write_bytes(assembly_stream,parents.r[i].base,parents.r[i].bytes);
    }
    bytes+=sizeof header+parent_bytes;
    input_bytes+=sizeof header+parent_bytes+coefficient_bytes+sizeof capture_config;
    release_parents(&parents);
    if(pthread_mutex_unlock(&capture_lock))fail("capture unlock");
}
__attribute__((destructor)) static void finish(void)
{
    if(!assembly_stream)return;
    if(fclose(assembly_stream)||fclose(reference_stream)||fclose(input_stream))fail("capture close");
    FILE *summary=fopen("sigam-summary.json","w");if(!summary)fail("summary open");
    fprintf(summary,"{\"passed\":true,\"calls\":%" PRIu64 ",\"canonical_bytes\":%" PRIu64
        ",\"input_bytes\":%" PRIu64 ",\"conventional\":%" PRIu64
        ",\"finite_element\":%" PRIu64 ",\"lassie_calls\":%" PRIu64
        ",\"caller_lassie\":%" PRIu64 ",\"caller_spcsi\":%" PRIu64
        ",\"caller_submat\":%" PRIu64 ",\"differing_bytes\":0,\"fpcr\":0}\n",
        calls,bytes,input_bytes,mode_calls[0],mode_calls[1],lassie_calls,
        caller_calls[1],caller_calls[2],caller_calls[3]);
    if(fclose(summary))fail("summary close");
    fprintf(stderr,"SIGAM FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64
        " differing_bytes=0 conventional=%" PRIu64 " finite_element=%" PRIu64
        " LASSIE=%" PRIu64 " SPCSI=%" PRIu64 " SUBMAT=%" PRIu64 " FPCR=0\n",
        calls,bytes,mode_calls[0],mode_calls[1],caller_calls[1],caller_calls[2],caller_calls[3]);
}

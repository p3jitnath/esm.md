/* Verify complete spectral Coriolis stages, physical identities and storage.
 * Input and output fields have units s^-1. Coefficients have no unit.
 * Source and native calls receive the same frozen binary64 input bits.
 */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <omp.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <unistd.h>

struct descriptor {
    void *base;
    int64_t offset;
    uint64_t element_bytes,type_word;
    int64_t span,s1,lo1,hi1,s2,lo2,hi2;
};
_Static_assert(sizeof(struct descriptor)==88,"GNU rank-two ABI");
typedef void (*post_fn)(const void*,const void*,const void*,const int32_t*,
                       const int32_t*,const int32_t*,const struct descriptor*,
                       struct descriptor*);
extern void spcimpfpost_(const void*,const void*,const void*,const int32_t*,
 const int32_t*,const int32_t*,const struct descriptor*,struct descriptor*);
extern void spcimpfpost_assembly_(const void*,const void*,const void*,const int32_t*,
 const int32_t*,const int32_t*,const struct descriptor*,struct descriptor*);
extern void spcimpfpost_stage_assembly_(const void*,const void*,const void*,const int32_t*,
 const int32_t*,const int32_t*,const struct descriptor*,struct descriptor*);
extern void spcimpfpost_stage_reference_(const void*,const void*,const void*,const int32_t*,
 const int32_t*,const int32_t*,const struct descriptor*,struct descriptor*);
extern uint64_t vertical_abi_call(void (*function)(void *),void *argument);

struct invocation {
    post_fn fn;
    const void *g,*rip,*dyn;
    const int32_t *m,*ks,*ke;
    const struct descriptor *div;
    struct descriptor *vor;
};
#define OFFSET(member,position) _Static_assert(offsetof(struct invocation,member)==position,"entry bridge storage")
OFFSET(fn,0);OFFSET(g,8);OFFSET(rip,16);OFFSET(dyn,24);
OFFSET(m,32);OFFSET(ks,40);OFFSET(ke,48);OFFSET(div,56);OFFSET(vor,64);
_Static_assert(sizeof(struct invocation)==72,"entry bridge size");
extern void post_abi_invoke(void*);
__asm__(".text\n.p2align 2\n.global post_abi_invoke\n.type post_abi_invoke,%function\n"
"post_abi_invoke:\n"
"mov x9,x0\nldr x16,[x9]\nldp x0,x1,[x9,#8]\nldp x2,x3,[x9,#24]\n"
"ldp x4,x5,[x9,#40]\nldp x6,x7,[x9,#56]\nbr x16\n"
".size post_abi_invoke,.-post_abi_invoke\n");

struct region {unsigned char *map,*data;size_t map_bytes,access_bytes,bytes;};
struct problem {
    const unsigned char *header;
    int32_t id,n,m,l,ks,ke,dr,dc,vr,vc,profile,parallel;
    int64_t ds1,ds2,vs1,vs2;
    uint64_t dcap,vcap,dbase,vbase;
    double beta,dt,omega;
    const double *div,*vor,*truth,*scale,*coeff;
};
struct context {
    struct problem *p;
    struct region *vor;
    int native,phase;
    FILE *stage_file;
    unsigned char *saved[3];
    size_t saved_bytes[3];
};
static _Thread_local struct context *active_context;
static uint64_t calls,guarded_calls,abi_calls,parallel_calls,science_values,inactive_values;
static uint64_t stage_records,stage_bytes,canonical_bytes;
static double max_science_ratio,max_coefficient_ratio;
static double *omega_address;
static unsigned char *input_bytes;
static size_t input_size;
static FILE *reference_file,*assembly_file,*reference_stages,*assembly_stages;

static void fail(const char *message)
{
    fprintf(stderr,"SPCIMPFPOST FAIL %s\n",message);
    exit(2);
}
static uint64_t fpcr(void)
{
    uint64_t value;
    __asm__ volatile("mrs %0,fpcr":"=r"(value));
    return value;
}
static uint64_t bits(double x)
{
    uint64_t b;memcpy(&b,&x,8);return b;
}
static int32_t i32(const unsigned char *p)
{
    int32_t x;memcpy(&x,p,4);return x;
}
static int64_t i64(const unsigned char *p)
{
    int64_t x;memcpy(&x,p,8);return x;
}
static double f64(const unsigned char *p)
{
    double x;memcpy(&x,p,8);return x;
}
static void put64(unsigned char *p,uint64_t x){memcpy(p,&x,8);}
static struct region region_new(size_t bytes,const void *initial,int readonly)
{
    const size_t page=(size_t)sysconf(_SC_PAGESIZE);
    const size_t access=((bytes+64+page-1)/page)*page;
    const size_t total=access+2*page;
    unsigned char *map=mmap(NULL,total,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(map==MAP_FAILED)fail("mmap");
    if(mprotect(map+page,access,PROT_READ|PROT_WRITE))fail("mprotect writable");
    unsigned char *data=map+page+access-bytes;
    for(size_t i=0;i<64;i++)data[(ptrdiff_t)i-64]=(unsigned char)(0x61+(i%23));
    if(bytes){if(initial)memcpy(data,initial,bytes);else memset(data,0,bytes);}
    if(readonly&&mprotect(map+page,access,PROT_READ))fail("mprotect input");
    return (struct region){map,data,total,access,bytes};
}
static void region_readonly(struct region *r)
{
    const size_t page=(size_t)sysconf(_SC_PAGESIZE);
    if(mprotect(r->map+page,r->access_bytes,PROT_READ))fail("readonly region");
}
static void region_guard(const struct region *r)
{
    for(size_t i=0;i<64;i++)
        if(r->data[(ptrdiff_t)i-64]!=(unsigned char)(0x61+(i%23)))fail("prefix guard");
}
static void region_release(struct region *r)
{
    if(munmap(r->map,r->map_bytes))fail("munmap");
    memset(r,0,sizeof(*r));
}
static void raw_equal(const void *a,const void *b,size_t n,int32_t cid,int phase,const char *field)
{
    if(!memcmp(a,b,n))return;
    const unsigned char *x=a,*y=b;size_t i=0;
    while(i<n&&x[i]==y[i])i++;
    size_t cell=i/8;uint64_t xb=0,yb=0;
    if(cell*8+8<=n){memcpy(&xb,x+cell*8,8);memcpy(&yb,y+cell*8,8);}
    fprintf(stderr,"case=%d phase=%d field=%s byte=%zu cell=%zu source=%016"PRIx64" native=%016"PRIx64"\n",
            cid,phase,field,i,cell,xb,yb);
    fail("raw bytes");
}
static void write_bytes(FILE *f,const void *p,size_t n)
{
    if(n&&fwrite(p,1,n,f)!=n)fail("output write");
}
static void science(double value,double truth,double scale,int32_t cid,int phase,size_t cell,int coefficient)
{
    const double limit=64.0*DBL_EPSILON*fmax(scale,DBL_MIN)+4.0*DBL_TRUE_MIN;
    const double error=fabs(value-truth);
    if(!isfinite(value)||error>limit){
        fprintf(stderr,"case=%d phase=%d cell=%zu native=%.17g analytic=%.17g error=%.17g limit=%.17g\n",
                cid,phase,cell,value,truth,error,limit);
        fail("independent physical identity");
    }
    const double ratio=error/limit;
    if(coefficient){if(ratio>max_coefficient_ratio)max_coefficient_ratio=ratio;}
    else if(ratio>max_science_ratio)max_science_ratio=ratio;
    science_values++;
}
static void observe_stage(const int32_t *stage,const double *alpha,const double *denim,
 const double *epsi,const double *plus,const double *minus,int native)
{
    struct context *c=active_context;
    if(!c||c->native!=native||*stage!=c->phase)fail("stage observation order");
    struct problem *p=c->p;
    const size_t defined=(size_t)(p->n-p->m+1);
    const size_t payload=*stage?c->vor->bytes:(5*defined+4)*8;
    unsigned char *copy=malloc(payload?payload:1);
    if(!copy)fail("stage allocation");
    if(*stage==0){
        size_t k=0;
        for(int32_t n=p->m;n<=p->n;n++){
            const double values[5]={alpha[n],denim[n],epsi[n],plus[n],minus[n]};
            memcpy(copy+k*8,values,40);
            if(native)for(size_t j=0;j<5;j++)science(values[j],p->coeff[k+j],fabs(p->coeff[k+j]),p->id,0,k+j,1);
            k+=5;
        }
        const double tail[4]={alpha[p->n+1],denim[p->n+1],plus[p->n+1],minus[p->n+1]};
        memcpy(copy+k*8,tail,32);
        for(size_t j=0;j<4;j++)if(bits(tail[j])!=0)fail("explicit coefficient zero bits");
        raw_equal(c->vor->data,p->vor,c->vor->bytes,p->id,0,"untouched setup field");
    }else if(payload)memcpy(copy,c->vor->data,payload);
    if(native){
        if(c->saved_bytes[*stage]!=payload)fail("stage size");
        raw_equal(c->saved[*stage],copy,payload,p->id,*stage,"coefficient/output stage");
    }else{
        c->saved[*stage]=malloc(payload?payload:1);
        if(!c->saved[*stage])fail("saved stage");
        if(payload)memcpy(c->saved[*stage],copy,payload);
        c->saved_bytes[*stage]=payload;
    }
    unsigned char header[64]={0};
    memcpy(header,"POSTST01",8);
    memcpy(header+8,&p->id,4);memcpy(header+12,stage,4);
    memcpy(header+16,&p->n,4);memcpy(header+20,&p->m,4);
    put64(header+24,payload);put64(header+32,0);
    write_bytes(c->stage_file,header,64);write_bytes(c->stage_file,copy,payload);
    if(native){stage_records++;stage_bytes+=64+payload;}
    region_guard(c->vor);
    free(copy);c->phase++;
}
void post_reference_stage_(const int32_t *s,const double *a,const double *d,
 const double *e,const double *p,const double *q){observe_stage(s,a,d,e,p,q,0);}
void post_native_stage_(const int32_t *s,const double *a,const double *d,
 const double *e,const double *p,const double *q){observe_stage(s,a,d,e,p,q,1);}

static struct descriptor descriptor(const struct problem *p,const struct region *r,int vor)
{
    const int64_t s1=vor?p->vs1:p->ds1,s2=vor?p->vs2:p->ds2;
    const uint64_t base=vor?p->vbase:p->dbase;
    const int32_t rows=vor?p->vr:p->dr,cols=vor?p->vc:p->dc;
    return (struct descriptor){r->data+base*8,-s1-s2,8,UINT64_C(0x0000030200000000),8,s1,1,rows,s2,1,cols};
}
static void invoke(post_fn fn,struct problem *p,struct region *g,struct region *rip,
 struct region *dyn,struct region *args,struct region *div_desc,struct region *vor_desc)
{
    struct invocation a={fn,g->data,rip->data,dyn->data,
        (const int32_t*)(args->data+8),(const int32_t*)(args->data+16),
        (const int32_t*)(args->data+20),(const struct descriptor*)div_desc->data,
        (struct descriptor*)vor_desc->data};
    if(fpcr()!=0)fail("FPCR before call");
    if(vertical_abi_call(post_abi_invoke,&a))fail("AAPCS64 preserved-register canary");
    if(fpcr()!=0||bits(*omega_address)!=bits(p->omega))fail("FPCR/global input after call");
    __atomic_add_fetch(&calls,1,__ATOMIC_RELAXED);
    __atomic_add_fetch(&guarded_calls,1,__ATOMIC_RELAXED);
    __atomic_add_fetch(&abi_calls,1,__ATOMIC_RELAXED);
    region_guard(g);region_guard(rip);region_guard(dyn);region_guard(args);
    region_guard(div_desc);region_guard(vor_desc);
}
static void canonical(FILE *f,const struct problem *p,const struct region *v)
{
    unsigned char header[256]={0};
    memcpy(header,"POSTOUT1",8);memcpy(header+8,p->header,192);
    put64(header+200,v->bytes+64);put64(header+208,fpcr());
    write_bytes(f,header,256);write_bytes(f,v->data-64,64);write_bytes(f,v->data,v->bytes);
}
static size_t at(const struct problem *p,int32_t l,int32_t j)
{
    int64_t k=(int64_t)p->vbase+(int64_t)(l-1)*p->vs1+(int64_t)(j-1)*p->vs2;
    if(k<0||(uint64_t)k>=p->vcap)fail("frozen output address");
    return (size_t)k;
}
static void independent_return(const struct problem *p,const struct region *v)
{
    unsigned char *mask=calloc(p->vcap?p->vcap:1,1);
    if(!mask)fail("physical output mask");
    const double *x=(const double*)v->data;
    for(int32_t n=p->m;n<=p->n;n++){
        int lower=p->m?n>=p->m+1:n>=2;
        int upper=p->m?n<p->n:(n>=1&&n<p->n);
        if(!lower&&!upper)continue;
        int32_t j=p->ks+2*(n-p->m);
        for(int32_t l=1;l<=p->l;l++){
            size_t k=at(p,l,j);
            mask[k]=1;science(x[k],p->truth[k],p->scale[k],p->id,2,k,0);
            if(p->m){k=at(p,l,j+1);mask[k]=1;science(x[k],p->truth[k],p->scale[k],p->id,2,k,0);}
        }
    }
    for(size_t i=0;i<p->vcap;i++)if(!mask[i]){
        if(bits(x[i])!=bits(p->vor[i]))fail("inactive source bytes");
        inactive_values++;
    }
    free(mask);
}
static void parallel_fixture(struct problem *p,struct region *g,struct region *rip,
 struct region *dyn,struct region *args,struct region *div_desc)
{
    int team=0;
    #pragma omp parallel num_threads(3) shared(team)
    {
        if(omp_get_num_threads()!=3||!omp_in_parallel())fail("genuine outer OpenMP team");
        #pragma omp atomic
        team++;
        struct region source=region_new(p->vcap*8,p->vor,0);
        struct region native=region_new(p->vcap*8,p->vor,0);
        struct descriptor sd=descriptor(p,&source,1),nd=descriptor(p,&native,1);
        struct region sr=region_new(88,&sd,1),nr=region_new(88,&nd,1);
        invoke(spcimpfpost_,p,g,rip,dyn,args,div_desc,&sr);
        invoke(spcimpfpost_assembly_,p,g,rip,dyn,args,div_desc,&nr);
        raw_equal(source.data,native.data,source.bytes,p->id,2,"parallel complete field");
        region_guard(&source);region_guard(&native);
        region_release(&sr);region_release(&nr);region_release(&source);region_release(&native);
        __atomic_add_fetch(&parallel_calls,2,__ATOMIC_RELAXED);
    }
    if(team!=3)fail("parallel fixture count");
}
static void run_problem(struct problem *p)
{
    *omega_address=p->omega;
    struct region g=region_new(17096,NULL,0),rip=region_new(175976,NULL,0),dyn=region_new(4720,NULL,0);
    memcpy(g.data+5172,&p->n,4);memcpy(g.data+5228,&p->l,4);
    memcpy(rip.data+208,&p->dt,8);memcpy(dyn.data+2496,&p->beta,8);
    region_readonly(&g);region_readonly(&rip);region_readonly(&dyn);
    struct region args=region_new(192,p->header,1);
    struct region div=region_new(p->dcap*8,p->div,1);
    struct descriptor dd=descriptor(p,&div,0);
    struct region ddr=region_new(88,&dd,1);
    struct region source=region_new(p->vcap*8,p->vor,0),native=region_new(p->vcap*8,p->vor,0);
    struct region stage_source=region_new(p->vcap*8,p->vor,0),stage_native=region_new(p->vcap*8,p->vor,0);
    struct descriptor ds=descriptor(p,&source,1),dn=descriptor(p,&native,1);
    struct descriptor dss=descriptor(p,&stage_source,1),dsn=descriptor(p,&stage_native,1);
    struct region sr=region_new(88,&ds,1),nr=region_new(88,&dn,1);
    struct region ssr=region_new(88,&dss,1),snr=region_new(88,&dsn,1);
    invoke(spcimpfpost_,p,&g,&rip,&dyn,&args,&ddr,&sr);
    invoke(spcimpfpost_assembly_,p,&g,&rip,&dyn,&args,&ddr,&nr);
    raw_equal(source.data,native.data,source.bytes,p->id,2,"complete returned allocation");
    struct context c={p,&stage_source,0,0,reference_stages,{NULL,NULL,NULL},{0,0,0}};
    active_context=&c;
    invoke(spcimpfpost_stage_reference_,p,&g,&rip,&dyn,&args,&ddr,&ssr);
    if(c.phase!=3)fail("source stage count");
    c.vor=&stage_native;c.native=1;c.phase=0;c.stage_file=assembly_stages;
    invoke(spcimpfpost_stage_assembly_,p,&g,&rip,&dyn,&args,&ddr,&snr);
    if(c.phase!=3)fail("native stage count");
    active_context=NULL;
    raw_equal(source.data,stage_source.data,source.bytes,p->id,2,"source observer equivalence");
    raw_equal(native.data,stage_native.data,native.bytes,p->id,2,"native observer equivalence");
    raw_equal(div.data,p->div,div.bytes,p->id,2,"input divergence");
    raw_equal(args.data,p->header,192,p->id,2,"input scalar bits");
    independent_return(p,&native);
    if(p->parallel)parallel_fixture(p,&g,&rip,&dyn,&args,&ddr);
    region_guard(&div);region_guard(&source);region_guard(&native);
    region_guard(&stage_source);region_guard(&stage_native);
    canonical(reference_file,p,&source);canonical(assembly_file,p,&native);
    canonical_bytes+=256+64+native.bytes;
    for(int i=0;i<3;i++)free(c.saved[i]);
    struct region *regions[]={&g,&rip,&dyn,&args,&div,&ddr,&source,&native,
                             &stage_source,&stage_native,&sr,&nr,&ssr,&snr};
    for(size_t i=0;i<sizeof(regions)/sizeof(regions[0]);i++)region_release(regions[i]);
}
static struct problem parse_problem(const unsigned char *h)
{
    struct problem p={0};p.header=h;
    p.id=i32(h);p.n=i32(h+4);p.m=i32(h+8);p.l=i32(h+12);p.ks=i32(h+16);p.ke=i32(h+20);
    p.dr=i32(h+24);p.dc=i32(h+28);p.vr=i32(h+32);p.vc=i32(h+36);
    p.ds1=i64(h+40);p.ds2=i64(h+48);p.vs1=i64(h+56);p.vs2=i64(h+64);
    p.dcap=(uint64_t)i64(h+72);p.vcap=(uint64_t)i64(h+80);
    p.dbase=(uint64_t)i64(h+88);p.vbase=(uint64_t)i64(h+96);
    p.beta=f64(h+104);p.dt=f64(h+112);p.omega=f64(h+120);
    p.profile=i32(h+128);p.parallel=i32(h+132);
    p.div=(const double*)(h+192);p.vor=p.div+p.dcap;p.truth=p.vor+p.vcap;
    p.scale=p.truth+p.vcap;p.coeff=p.scale+p.vcap;
    return p;
}
static FILE *open_output(const char *directory,const char *name)
{
    char path[2048];
    if(snprintf(path,sizeof(path),"%s/%s",directory,name)>=(int)sizeof(path))fail("path");
    FILE *f=fopen(path,"wb");if(!f)fail("open output");return f;
}
int main(int argc,char **argv)
{
    if(argc!=3)fail("usage: spcimpfpost CORPUS_DIRECTORY OUTPUT_DIRECTORY");
    struct rlimit limit={0,0};if(setrlimit(RLIMIT_CORE,&limit))fail("core limit");
    if(fpcr()!=0)fail("initial FPCR");
    omega_address=dlsym(RTLD_DEFAULT,"__yomcst_MOD_romega");
    int32_t *lhook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    if(!omega_address||!lhook)fail("source globals");
    *lhook=0;
    char path[2048];
    if(snprintf(path,sizeof(path),"%s/corpus.bin",argv[1])>=(int)sizeof(path))fail("corpus path");
    FILE *f=fopen(path,"rb");if(!f)fail("corpus file");
    if(fseek(f,0,SEEK_END))fail("corpus seek");
    long end=ftell(f);if(end<64)fail("corpus length");input_size=(size_t)end;
    rewind(f);input_bytes=malloc(input_size);if(!input_bytes)fail("corpus allocation");
    if(fread(input_bytes,1,input_size,f)!=input_size)fail("corpus read");
    fclose(f);
    if(memcmp(input_bytes,"POSTIN01",8)||i32(input_bytes+8)!=1||
       i64(input_bytes+16)!=17096||i64(input_bytes+24)!=4720||
       i64(input_bytes+32)!=175976)fail("frozen header");
    const int32_t count=i32(input_bytes+12);
    reference_file=open_output(argv[2],"reference.bin");assembly_file=open_output(argv[2],"assembly.bin");
    reference_stages=open_output(argv[2],"reference-stages.bin");assembly_stages=open_output(argv[2],"assembly-stages.bin");
    const unsigned char *cursor=input_bytes+64,*stop=input_bytes+input_size;
    for(int32_t id=0;id<count;id++){
        if((size_t)(stop-cursor)<192)fail("short case");
        struct problem p=parse_problem(cursor);
        size_t length=192+(p.dcap+3*p.vcap+5*(uint64_t)(p.n-p.m+1))*8;
        if(p.id!=id||p.n<1||p.m<0||p.m>p.n||p.l<0||p.ks<1||
           p.l>p.dr||p.l>p.vr||length>(size_t)(stop-cursor))fail("frozen case bounds");
        run_problem(&p);cursor+=length;
    }
    if(cursor!=stop)fail("corpus trailing bytes");
    if(fclose(reference_file)||fclose(assembly_file)||fclose(reference_stages)||fclose(assembly_stages))fail("close output");
    f=open_output(argv[2],"summary.json");
    fprintf(f,"{\n  \"cases\": %d,\n  \"calls\": %"PRIu64",\n  \"output_bytes\": %"PRIu64",\n"
      "  \"stage_records\": %"PRIu64",\n  \"stage_bytes\": %"PRIu64",\n"
      "  \"science_values\": %"PRIu64",\n  \"inactive_values\": %"PRIu64",\n"
      "  \"guarded_calls\": %"PRIu64",\n  \"abi_calls\": %"PRIu64",\n"
      "  \"parallel_calls\": %"PRIu64",\n  \"science_error_limit_fraction\": %.17g,\n"
      "  \"coefficient_error_limit_fraction\": %.17g,\n  \"differing_bytes\": 0,\n  \"fpcr\": 0\n}\n",
      count,calls,canonical_bytes,stage_records,stage_bytes,science_values,inactive_values,
      guarded_calls,abi_calls,parallel_calls,max_science_ratio,max_coefficient_ratio);
    fclose(f);
    printf("SPCIMPFPOST PASS cases%d calls%"PRIu64" output_bytes%"PRIu64" stage_records%"PRIu64
      " stage_bytes%"PRIu64" science%"PRIu64" guarded%"PRIu64" parallel%"PRIu64" differing_bytes0 FPCR0\n",
      count,calls,canonical_bytes,stage_records,stage_bytes,science_values,guarded_calls,parallel_calls);
    free(input_bytes);return 0;
}

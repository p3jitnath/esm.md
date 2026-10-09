/* Critical verification for the complete vertical dependency set.
 * Binary fixtures are frozen before emission and come from independent rational
 * polynomials and physical budgets. No driver supplies a numerical stage.
 */
#define _GNU_SOURCE
#include <stdint.h>
#include <inttypes.h>
#include <stddef.h>
#include <stdalign.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>
#include <errno.h>
#include <omp.h>
#include <dlfcn.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <sys/resource.h>
#include <signal.h>

struct fixture_case {
    int32_t entry,p,start,end,l,n,m,ibc,chunk,descriptor;
    uint32_t flags;
    char operation[5],boundary[3];
    uint64_t matrix,input,initial,target;
    double tolerance;
    const char *name;
};
#include "corpus.h"

typedef void (*wrapper_fn)(const void *,const void *,const char *,const char *,
    const int32_t *,const int32_t *,const int32_t *,const int32_t *,
    const double *,double *,const int32_t *,const int32_t *,size_t,size_t);
typedef void (*integral_fn)(const int32_t *,const int32_t *,const int32_t *,
    const int32_t *,const int32_t *,const double *,const double *,double *,
    const int32_t *,const int32_t *);
typedef void (*derivative_fn)(const int32_t *,const int32_t *,const int32_t *,
    const int32_t *,const int32_t *,const double *,const double *,double *);
extern void verdisint_assembly_(const void *,const void *,const char *,const char *,
    const int32_t *,const int32_t *,const int32_t *,const int32_t *,
    const double *,double *,const int32_t *,const int32_t *,size_t,size_t);
extern void verdisint_reference_(const void *,const void *,const char *,const char *,
    const int32_t *,const int32_t *,const int32_t *,const int32_t *,
    const double *,double *,const int32_t *,const int32_t *,size_t,size_t);
extern void verint_assembly_(const int32_t *,const int32_t *,const int32_t *,
    const int32_t *,const int32_t *,const double *,const double *,double *,
    const int32_t *,const int32_t *);
extern void verint_reference_(const int32_t *,const int32_t *,const int32_t *,
    const int32_t *,const int32_t *,const double *,const double *,double *,
    const int32_t *,const int32_t *);
extern void verder_assembly_(const int32_t *,const int32_t *,const int32_t *,
    const int32_t *,const int32_t *,const double *,const double *,double *);
extern void verder_reference_(const int32_t *,const int32_t *,const int32_t *,
    const int32_t *,const int32_t *,const double *,const double *,double *);
extern void verdisint_strict_nt_fp64_(const char *,const char *,const int32_t *,
    const int32_t *,const int32_t *,const double *,const double *,const int32_t *,
    const double *,const int32_t *,const double *,double *,const int32_t *,
    size_t,size_t);
extern const unsigned char verdisint_dispatch_metadata_[112*8];
extern int32_t __oml_mod_MOD_oml_in_parallel(void);
extern void __oml_mod_MOD_oml_init(void);
extern uint64_t vertical_abi_call(void (*function)(void *),void *argument);
static wrapper_fn public_wrapper;
static integral_fn public_integral;
static derivative_fn public_derivative;
union vfe_storage {max_align_t alignment; unsigned char bytes[2176];};
union cver_storage {max_align_t alignment; unsigned char bytes[216];};

static const uint64_t guards[4]={UINT64_C(0x7f123456789abcde),
    UINT64_C(0xff23456789abcdef),UINT64_C(0x7f3456789abcdef0),
    UINT64_C(0xff456789abcdef01)};
static unsigned char *corpus;
static size_t corpus_bytes;
static FILE *reference_stream,*assembly_stream;
static uint64_t call_count,appended_bytes;
static size_t science_values,guarded_calls,protected_calls,parallel_calls,public_calls;
static long double maximum_small_error,maximum_constant_error,maximum_quartic_error;

static _Noreturn void failure(const char *format,...)
{
    va_list ap;va_start(ap,format);vfprintf(stderr,format,ap);va_end(ap);
    fputc('\n',stderr);exit(2);
}
static uint64_t bits(double value)
{
    uint64_t result;memcpy(&result,&value,8);return result;
}
static uint64_t fpcr(void)
{
    uint64_t result;__asm__ volatile("mrs %0, fpcr":"=r"(result));return result;
}
static const double *slice(uint64_t offset,size_t count)
{
    if (offset>corpus_bytes || count>(corpus_bytes-offset)/8)
        failure("fixture buffer exceeds frozen corpus");
    return (const double *)(corpus+offset);
}
static void put_word(unsigned char *object,size_t offset,uint64_t value)
{
    memcpy(object+offset,&value,8);
}
static void put_integer(unsigned char *object,size_t offset,int32_t value)
{
    memcpy(object+offset,&value,4);
}
/* GNU 12.3 allocated rank-two descriptor, with contiguous lower bounds one. */
static void descriptor(unsigned char *object,size_t offset,double *data,int rows,int columns)
{
    unsigned char *d=object+offset;
    put_word(d,0,(uintptr_t)data);
    put_word(d,8,(uint64_t)(-1-(int64_t)rows));
    put_word(d,16,8);
    put_word(d,24,UINT64_C(0x0000030200000000));
    put_word(d,32,8);
    put_word(d,40,1);put_word(d,48,1);put_word(d,56,rows);
    put_word(d,64,rows);put_word(d,72,1);put_word(d,80,columns);
}
struct buffer {
    double *values;
    size_t count;
    void *allocation;
    size_t allocation_bytes;
    int protected;
};
static struct buffer make_buffer(size_t count,const double *values,int protected)
{
    struct buffer b={0};b.count=count;b.protected=protected;
    if (protected) {
        size_t page=(size_t)sysconf(_SC_PAGESIZE);
        size_t payload=(count*8+page-1)/page*page;
        if (!payload) payload=page;
        b.allocation_bytes=payload+page;
        b.allocation=mmap(NULL,b.allocation_bytes,PROT_READ|PROT_WRITE,
            MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
        if (b.allocation==MAP_FAILED)failure("mmap: %s",strerror(errno));
        char *end=(char *)b.allocation+payload;
        if (mprotect(end,page,PROT_NONE))failure("mprotect: %s",strerror(errno));
        b.values=(double *)(end-count*8);
    } else {
        b.allocation_bytes=(count+4)*8;
        b.allocation=malloc(b.allocation_bytes);
        if (!b.allocation)failure("malloc");
        b.values=(double *)b.allocation+2;
        memcpy(b.values-2,guards,16);
        memcpy(b.values+count,guards+2,16);
    }
    if (count)memcpy(b.values,values,count*8);
    return b;
}
static void read_only(struct buffer *b)
{
    if (b->protected) {
        size_t page=(size_t)sysconf(_SC_PAGESIZE);
        if (mprotect(b->allocation,b->allocation_bytes-page,PROT_READ))
            failure("readonly mprotect");
    }
}
static void check_guards(const struct buffer *b,const char *case_name,const char *field)
{
    if (!b->protected && (memcmp(b->values-2,guards,16) ||
        memcmp(b->values+b->count,guards+2,16)))
        failure("case=%s stage=buffer-guard field=%s",case_name,field);
}
static void release_buffer(struct buffer *b)
{
    if (b->protected)munmap(b->allocation,b->allocation_bytes);
    else free(b->allocation);
}
struct invocation {
    const struct fixture_case *fixture;
    const double *matrix,*input;
    double *output;
    const void *vfe,*cver;
    int reference;
};
static void invoke(void *argument)
{
    struct invocation *a=argument;
    const struct fixture_case *f=a->fixture;
    if (f->entry==1) {
        const int32_t active=f->end-f->start+1;
        const double one=1.0,zero=0.0;
        verdisint_strict_nt_fp64_("N","T",&active,&f->m,&f->n,&one,
            a->input+(f->start-1),&f->p,a->matrix,&f->m,&zero,
            a->output+(f->start-1),&f->p,1,1);
    } else if (f->entry==2) {
        integral_fn function=a->reference==2 ? public_integral:a->reference ? verint_reference_:verint_assembly_;
        function(&f->p,&f->start,&f->end,&f->n,&f->m,a->matrix,a->input,
            a->output,&f->ibc,&f->chunk);
    } else if (f->entry==3) {
        derivative_fn function=a->reference==2 ? public_derivative:a->reference ? verder_reference_:verder_assembly_;
        function(&f->p,&f->start,&f->end,&f->n,&f->m,a->matrix,a->input,a->output);
    } else if (f->entry==4) {
        wrapper_fn function=a->reference==2 ? public_wrapper:a->reference ? verdisint_reference_:verdisint_assembly_;
        function(a->vfe,a->cver,f->operation,f->boundary,&f->p,&f->start,&f->end,
            &f->l,a->input,a->output,(f->flags&8) ? &f->ibc:NULL,
            (f->flags&16) ? &f->chunk:NULL,4,2);
    } else failure("unknown fixture entry");
}
/* The header fields have no omitted padding and the host is little endian. */
struct call_record {
    uint64_t call;
    uint32_t entry,flags;
    int32_t p,start,end,l,n,m,ibc,chunk;
    char operation[4],boundary[2];
    uint16_t reserved;
    uint64_t values;
};
_Static_assert(sizeof(struct call_record)==64,"canonical record size");
_Static_assert(offsetof(struct call_record,values)==56,"canonical value offset");
static void record(FILE *stream,const struct fixture_case *f,const struct buffer *out)
{
    struct call_record h={0};
    h.call=call_count;h.entry=f->entry;h.flags=f->flags;
    h.p=f->p;h.start=f->start;h.end=f->end;h.l=f->l;h.n=f->n;h.m=f->m;
    h.ibc=f->ibc;h.chunk=f->chunk;memcpy(h.operation,f->operation,4);
    memcpy(h.boundary,f->boundary,2);h.values=out->count+((f->flags&1)?4:0);
    if (fwrite(&h,sizeof(h),1,stream)!=1 ||
        fwrite(out->values,8,out->count,stream)!=out->count)failure("output write");
    if (f->flags&1) {
        if (out->protected)failure("protected fixture must not declare heap guards");
        if (fwrite(out->values-2,8,2,stream)!=2 ||
            fwrite(out->values+out->count,8,2,stream)!=2)failure("guard write");
    }
}
static void run_fixture(const struct fixture_case *f)
{
    size_t input_count=(size_t)f->p*(f->entry==4 ? f->l+2:f->n);
    size_t matrix_count=(size_t)f->m*f->n,output_count=(size_t)f->p*f->m;
    int protected=(f->flags&2)!=0;
    struct buffer input=make_buffer(input_count,slice(f->input,input_count),protected);
    struct buffer matrix=make_buffer(matrix_count,slice(f->matrix,matrix_count),protected);
    struct buffer reference=make_buffer(output_count,slice(f->initial,output_count),protected);
    struct buffer assembly=make_buffer(output_count,slice(f->initial,output_count),protected);
    struct buffer baseline=make_buffer(output_count,slice(f->initial,output_count),protected);
    read_only(&input);read_only(&matrix);
    union vfe_storage vfe={0};union cver_storage cver={0};
    double unused_half[20]={0};
    if (f->entry==4) {
        descriptor(vfe.bytes,f->descriptor,matrix.values,f->m,f->n);
        if (!memcmp(f->operation,"HDER",4) && f->descriptor!=856)
            descriptor(vfe.bytes,856,unused_half,f->l+1,f->l+2);
        int integral=!memcmp(f->operation,"ITOP",4)||!memcmp(f->operation,"IBOT",4);
        put_integer(cver.bytes,36,integral?f->ibc:(f->ibc+1)%4);
        put_integer(cver.bytes,40,integral?(f->ibc+1)%4:f->ibc);
        if(protected) {
            unsigned char *d=vfe.bytes+f->descriptor;
            put_word(d,8,(uint64_t)(2-(int64_t)7*f->m));
            put_word(d,48,(uint64_t)-2);put_word(d,56,(uint64_t)(f->m-3));
            put_word(d,72,7);put_word(d,80,f->n+6);
        }
        put_integer(cver.bytes,52,1);
    }
    unsigned char vfe_before[2176],cver_before[216];
    memcpy(vfe_before,vfe.bytes,2176);memcpy(cver_before,cver.bytes,216);
    struct invocation a={f,matrix.values,input.values,reference.values,&vfe,&cver,1};
    if (fpcr()!=0)failure("case=%s FPCR entry is not zero",f->name);
    uint64_t abi=vertical_abi_call(invoke,&a);
    if (abi)failure("case=%s reference ABI mask=%" PRIx64,f->name,abi);
    if(f->entry!=1) {
        a.output=baseline.values;a.reference=2;
        abi=vertical_abi_call(invoke,&a);
        if(abi)failure("case=%s public Fortran ABI mask=%" PRIx64,f->name,abi);
        ++public_calls;
    }
    a.output=assembly.values;a.reference=0;
    abi=vertical_abi_call(invoke,&a);
    if (abi)failure("case=%s assembly ABI mask=%" PRIx64,f->name,abi);
    if (fpcr()!=0)failure("case=%s FPCR changed",f->name);
    if (memcmp(vfe.bytes,vfe_before,2176) || memcmp(cver.bytes,cver_before,216))
        failure("case=%s immutable configuration changed",f->name);
    if (memcmp(input.values,slice(f->input,input_count),input_count*8) ||
        memcmp(matrix.values,slice(f->matrix,matrix_count),matrix_count*8))
        failure("case=%s immutable field or matrix changed",f->name);
    check_guards(&input,f->name,"input");check_guards(&matrix,f->name,"matrix");
    check_guards(&reference,f->name,"reference-output");check_guards(&assembly,f->name,"assembly-output");
    check_guards(&baseline,f->name,"public-baseline-output");
    const double *target=slice(f->target,output_count);
    for (size_t index=0; index<output_count; ++index) {
        int point=(int)(index%f->p)+1,row=(int)(index/f->p)+1;
        if(f->entry!=1 && bits(reference.values[index])!=bits(baseline.values[index]))
            failure("case=%s public original-source baseline mismatch point=%d row=%d renamed=%016" PRIx64 " public=%016" PRIx64,
                f->name,point,row,bits(reference.values[index]),bits(baseline.values[index]));
        if (bits(reference.values[index])!=bits(assembly.values[index]))
            failure("case=%s op=%.4s ibc=%d bc=%.2s stage=complete-call point=%d row=%d reference=%016" PRIx64 " assembly=%016" PRIx64,
                f->name,f->operation,f->ibc,f->boundary,point,row,
                bits(reference.values[index]),bits(assembly.values[index]));
        if (point<f->start || point>f->end) {
            if (bits(assembly.values[index])!=bits(target[index]))
                failure("case=%s inactive point=%d row=%d changed",f->name,point,row);
            continue;
        }
        double actual=assembly.values[index],expected=target[index];
        if (!isfinite(actual))failure("case=%s nonfinite point=%d row=%d",f->name,point,row);
        long double error=fabsl((long double)actual-(long double)expected);
        long double limit=f->tolerance;
        if (f->flags&32)limit*=fmaxl(1.0L,fabsl((long double)expected));
        if (!f->tolerance) {
            if (bits(actual)!=bits(expected))
                failure("case=%s ordered arithmetic witness point=%d row=%d actual=%016" PRIx64 " expected=%016" PRIx64,
                    f->name,point,row,bits(actual),bits(expected));
        } else if (error>limit) {
            failure("case=%s analytical science point=%d row=%d actual=%.17g expected=%.17g error=%.6Le limit=%.6Le",
                f->name,point,row,actual,expected,error,limit);
        }
        if (f->l==19) {
            if (strstr(f->name,"quartic")) {
                if (error>maximum_quartic_error)maximum_quartic_error=error;
            } else {
                long double scaled=error/fmaxl(1.0L,fabs((double)slice(f->input,input_count)[f->p]));
                if (scaled>maximum_constant_error)maximum_constant_error=scaled;
            }
        } else if (error>maximum_small_error)maximum_small_error=error;
        if (f->entry==4 && !memcmp(f->operation,"IBOT",4) && row==f->m &&
            bits(actual)!=0)failure("case=%s bottom surface must be positive zero",f->name);
        ++science_values;
    }
    ++call_count;
    record(reference_stream,f,&reference);record(assembly_stream,f,&assembly);
    appended_bytes+=64+(output_count+((f->flags&1)?4:0))*8;
    guarded_calls+=(f->flags&1)!=0;protected_calls+=protected;parallel_calls+=(f->flags&4)!=0;
    release_buffer(&input);release_buffer(&matrix);
    release_buffer(&reference);release_buffer(&assembly);release_buffer(&baseline);
}
static int selection_status(int op,int ibc,int bc)
{
    if (op<2)return bc==0 ? 1:0;
    if (op==2)return 1;
    if (op==3)return bc==0 || ibc==1 || ibc==3 ? 1:0;
    if (op==4)return bc>=2 || (bc==1 && ibc<2) ? 2:0;
    if (op==5)return ibc==2 && bc==0 ? 2:ibc==0 && bc==0 ? 1:0;
    if (ibc==0)return bc==0 ? 1:0;
    if (ibc==1)return bc==0 ? 1:bc==1 ? 0:2;
    if (ibc==2)return bc==3 ? 0:2;
    return bc==1 || bc==3 ? 0:2;
}
/* Disable only symbol-resolution diagnostics in this verifier executable. */
void LinuxTraceBack(const char *prefix,const char *timestamp,void *context)
{
    (void)prefix;(void)timestamp;(void)context;
    fputs("Intentional rejection: detailed traceback disabled; real ABOR1 retained.\n",stderr);
}
static void dispatch_metadata_checks(void)
{
    size_t defined=0,undefined=0,source_abort=0;
    for(int op=0;op<7;++op)for(int ibc=0;ibc<4;++ibc)for(int bc=0;bc<4;++bc) {
        const unsigned char *r=verdisint_dispatch_metadata_+8*(16*op+4*ibc+bc);
        int status=selection_status(op,ibc,bc);
        if(r[6]!=status || r[7])failure("emitted dispatch classification op=%d ibc=%d bc=%d",op,ibc,bc);
        defined+=status==0;undefined+=status==1;source_abort+=status==2;
    }
    if(defined!=57||undefined!=37||source_abort!=18)failure("complete dispatch count");
    for(size_t i=0;i<57;++i) {
        const struct fixture_case *f=&fixtures[i];
        int op=!memcmp(f->operation,"ITOP",4)?0:!memcmp(f->operation,"IBOT",4)?1:
            !memcmp(f->operation,"DEGW",4)?3:!memcmp(f->operation,"HDER",4)?4:
            !memcmp(f->operation,"FDER",4)?5:6;
        int bc=(f->boundary[0]-'0')*2+f->boundary[1]-'0';
        const unsigned char *r=verdisint_dispatch_metadata_+8*(16*op+4*f->ibc+bc);
        unsigned offset=(unsigned)r[0]+256*(unsigned)r[1];
        if(offset!=(unsigned)f->descriptor || r[2]!=(f->n==f->l) ||
            r[3]!=f->n-f->l || r[4]!=f->m-f->l || r[5]!=(op==1) || r[6])
            failure("defined matrix/shape metadata differs from frozen source case=%s",f->name);
    }
}
/* One real common abort is enough after the complete dispatch metadata check. */
static size_t rejection_checks(void)
{
    const char *filename="rejection-0.log";
    pid_t child=fork();if(child<0)failure("fork");
    if(child==0) {
        struct rlimit core_limit={0,0};setrlimit(RLIMIT_CORE,&core_limit);
        struct rlimit log_limit={1048576,1048576};setrlimit(RLIMIT_FSIZE,&log_limit);
        alarm(10);
        if(!freopen(filename,"w",stdout)||!freopen(filename,"a",stderr))_exit(3);
        double matrix[20]={0},input[25]={0},output[20]={0};
        int32_t p=5,start=1,end=4,levels=3,bc=3,chunk=1;
        union vfe_storage vfe={0};union cver_storage cver={0};
        for(int field=0;field<24;++field)descriptor(vfe.bytes,64+field*88,matrix,4,5);
        put_integer(cver.bytes,36,3);put_integer(cver.bytes,40,3);put_integer(cver.bytes,52,1);
        verdisint_assembly_(&vfe,&cver,"INGW","11",&p,&start,&end,&levels,
            input,output,&bc,&chunk,4,2);
        _exit(0);
    }
    int result;if(waitpid(child,&result,0)!=child)failure("waitpid");
    if(!((WIFSIGNALED(result)&&WTERMSIG(result)==SIGABRT)||
         (WIFEXITED(result)&&WEXITSTATUS(result)==128+SIGABRT)))
        failure("real common ABOR1 status failed raw-status=%d",result);
    FILE *stream=fopen(filename,"rb");if(!stream)failure("rejection log open");
    char text[4096];size_t count=fread(text,1,sizeof(text)-1,stream);fclose(stream);text[count]=0;
    if(!strstr(text,"UNDEFINED UPSTREAM")||strstr(text,"[LinuxTraceBack]"))
        failure("real common ABOR1 compact diagnostic");
    return 1;
}
int main(int argc,char **argv)
{
    if(argc!=3)failure("usage: verdisint CORPUS_DIRECTORY OUTPUT_DIRECTORY");
    if(fpcr()!=0)failure("FPCR must be zero");
    uint64_t endian=1;if(*(unsigned char *)&endian!=1)failure("host must be little endian");
    /* Source profiling is excluded from this numerical comparison. */
    int32_t *hook=(int32_t *)dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    if(!hook)failure("missing profiling flag");
    *hook=0;
    omp_set_dynamic(0);omp_set_num_threads(2);
    __oml_mod_MOD_oml_init();
    if(__oml_mod_MOD_oml_in_parallel())failure("OML must initialize outside a parallel region");
    omp_set_num_threads(1);
    char path[4096];
    if(snprintf(path,sizeof(path),"%s/corpus.bin",argv[1])>=(int)sizeof(path))failure("path");
    FILE *stream=fopen(path,"rb");if(!stream)failure("corpus open");
    if(fseek(stream,0,SEEK_END))failure("corpus seek");
    long length=ftell(stream);if(length<0)failure("corpus length");
    corpus_bytes=(size_t)length;rewind(stream);
    corpus=malloc(corpus_bytes);if(!corpus)failure("corpus allocation");
    if(fread(corpus,1,corpus_bytes,stream)!=corpus_bytes||fclose(stream))failure("corpus read");
    if(snprintf(path,sizeof(path),"%s/reference.bin",argv[2])>=(int)sizeof(path))failure("path");
    reference_stream=fopen(path,"wb");if(!reference_stream)failure("reference output open");
    if(snprintf(path,sizeof(path),"%s/assembly.bin",argv[2])>=(int)sizeof(path))failure("path");
    assembly_stream=fopen(path,"wb");if(!assembly_stream)failure("assembly output open");
    if(snprintf(path,sizeof(path),"%s/../build/libstrict-vertical-reference.so",argv[1])>=(int)sizeof(path))failure("path");
    void *baseline_library=dlopen(path,RTLD_NOW|RTLD_LOCAL);
    if(!baseline_library)failure("public baseline load: %s",dlerror());
    public_wrapper=(wrapper_fn)dlsym(baseline_library,"verdisint_");
    public_integral=(integral_fn)dlsym(baseline_library,"verint_");
    public_derivative=(derivative_fn)dlsym(baseline_library,"verder_");
    if(!public_wrapper||!public_integral||!public_derivative)failure("public baseline exports");
    dispatch_metadata_checks();
    size_t rejected=rejection_checks();
    for(size_t i=0;i<fixture_count;++i) {
        if(fixtures[i].flags&4) {
            #pragma omp parallel num_threads(2)
            {
                #pragma omp single
                {
                    if(!omp_in_parallel() || !__oml_mod_MOD_oml_in_parallel())
                        failure("genuine OML parallel state was not entered");
                    run_fixture(&fixtures[i]);
                }
            }
        } else run_fixture(&fixtures[i]);
    }
    if(fclose(reference_stream)||fclose(assembly_stream))failure("output close");
    if(snprintf(path,sizeof(path),"%s/summary.json",argv[2])>=(int)sizeof(path))failure("summary path");
    FILE *summary=fopen(path,"w");if(!summary)failure("summary open");
    fprintf(summary,"{\"passed\":true,\"dispatch_records\":112,\"critical_calls\":%" PRIu64 ",\"canonical_bytes\":%" PRIu64
        ",\"science_values\":%zu,\"guarded_calls\":%zu,\"protected_calls\":%zu,"
        "\"genuine_parallel_calls\":%zu,\"real_abor1_rejections\":%zu,\"public_original_source_calls\":%zu,"
        "\"max_small_absolute_error\":%.18Le,\"max_actual_constant_scaled_error\":%.18Le,"
        "\"max_actual_quartic_absolute_error\":%.18Le,\"FPCR\":%" PRIu64 "}\n",
        call_count,appended_bytes,science_values,guarded_calls,protected_calls,parallel_calls,
        rejected,public_calls,maximum_small_error,maximum_constant_error,maximum_quartic_error,fpcr());
    if(fclose(summary))failure("summary close");
    printf("PASS: %" PRIu64 " complete numerical calls and 112 dispatch records.\n",call_count);
    free(corpus);return 0;
}

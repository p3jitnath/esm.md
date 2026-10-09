/* Critical SIGAM verification: independent identities, complete source bytes,
 * immutable inputs, inactive cells, guarded bounds, ABI and real parallel use.
 * The optional stage observer forwards to the complete accepted dependency.
 */
#define _GNU_SOURCE
#include <stdint.h>
#include <inttypes.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>
#include <dlfcn.h>
#include <unistd.h>
#include <sys/mman.h>
#include <omp.h>

typedef void (*sigam_fn)(const void *,const void *,const int32_t *,const int32_t *,
    double *,const double *,const double *,const int32_t *,const int32_t *);
extern void sigam_assembly_(const void *,const void *,const int32_t *,const int32_t *,
    double *,const double *,const double *,const int32_t *,const int32_t *);
extern void sigam_stage_assembly_(const void *,const void *,const int32_t *,const int32_t *,
    double *,const double *,const double *,const int32_t *,const int32_t *);
extern void sigam_reference_(const void *,const void *,const int32_t *,const int32_t *,
    double *,const double *,const double *,const int32_t *,const int32_t *);
typedef void (*vertical_fn)(const void *,const void *,const char *,const char *,
    const int32_t *,const int32_t *,const int32_t *,const int32_t *,
    const double *,double *,const int32_t *,const int32_t *,size_t,size_t);
extern void verdisint_assembly_(const void *,const void *,const char *,const char *,
    const int32_t *,const int32_t *,const int32_t *,const int32_t *,
    const double *,double *,const int32_t *,const int32_t *,size_t,size_t);
extern void verdisint_reference_(const void *,const void *,const char *,const char *,
    const int32_t *,const int32_t *,const int32_t *,const int32_t *,
    const double *,double *,const int32_t *,const int32_t *,size_t,size_t);
extern void __oml_mod_MOD_oml_init(void);
extern int32_t __oml_mod_MOD_oml_in_parallel(void);
extern uint64_t vertical_abi_call(void (*function)(void *),void *argument);
static FILE *reference_stream,*assembly_stream,*reference_stages,*assembly_stages;
static uint64_t cases,output_bytes,stage_records,stage_bytes,science_values,inactive_values;
static uint64_t guarded_calls,parallel_calls;
static double maximum_closed_error,maximum_constant_error,maximum_quartic_error;
static unsigned char *stage_input,*stage_output;
static size_t stage_input_bytes,stage_output_bytes;
static uint32_t current_case;
static const uint64_t guards[4]={
    UINT64_C(0x7f123456789abcde),UINT64_C(0xff23456789abcdef),
    UINT64_C(0x7f3456789abcdef0),UINT64_C(0xff456789abcdef01)};
static _Noreturn void failure(const char *format,...)
{
    va_list ap;va_start(ap,format);vfprintf(stderr,format,ap);va_end(ap);
    fputc('\n',stderr);exit(2);
}
static uint64_t fpcr(void)
{
    uint64_t value;__asm__ volatile("mrs %0,fpcr":"=r"(value));return value;
}
static uint64_t word(const void *p)
{
    uint64_t value;memcpy(&value,p,8);return value;
}
static int32_t integer(const void *p)
{
    int32_t value;memcpy(&value,p,4);return value;
}
static double real(const void *p)
{
    double value;memcpy(&value,p,8);return value;
}
static void put_word(void *p,uint64_t value){memcpy(p,&value,8);}
static void put_integer(void *p,int32_t value){memcpy(p,&value,4);}
static void put_real(void *p,double value){memcpy(p,&value,8);}
static void write_bytes(FILE *f,const void *p,size_t n)
{
    if(n && fwrite(p,1,n,f)!=n)failure("stream write");
}
static void equal_bytes(const void *a,const void *b,size_t n,const char *field)
{
    if(!memcmp(a,b,n))return;
    const unsigned char *x=a,*y=b;size_t i=0;
    while(i<n && x[i]==y[i])++i;
    size_t cell=i/8;
    uint64_t wx=0,wy=0;
    size_t k=(cell+1)*8<=n?8:n-cell*8;
    memcpy(&wx,x+cell*8,k);memcpy(&wy,y+cell*8,k);
    failure("case=%u field=%s cell=%zu byte=%zu source=%016" PRIx64
            " native=%016" PRIx64,current_case,field,cell,i,wx,wy);
}
struct buffer {unsigned char *data,*map;size_t bytes,map_bytes,usable;};
static struct buffer make_buffer(size_t bytes,const void *initial)
{
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    size_t live=bytes?bytes:8;
    size_t usable=(live+32+page-1)/page*page;
    unsigned char *map=mmap(NULL,usable+page,PROT_READ|PROT_WRITE,
        MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(map==MAP_FAILED)failure("mmap");
    if(mprotect(map+usable,page,PROT_NONE))failure("trailing guard page");
    struct buffer b={map+usable-live,map,bytes,usable+page,usable};
    memcpy(b.data-32,guards,32);
    if(initial && bytes)memcpy(b.data,initial,bytes);
    else memset(b.data,0,live);
    return b;
}
static void protect(struct buffer *b)
{
    if(mprotect(b->map,b->usable,PROT_READ))failure("input protection");
}
static void check_buffer(const struct buffer *b,const void *initial,const char *name)
{
    equal_bytes(b->data-32,guards,32,name);
    if(initial)equal_bytes(b->data,initial,b->bytes,name);
}
static void release(struct buffer *b)
{
    if(munmap(b->map,b->map_bytes))failure("munmap");
}
static void vector(unsigned char *d,const struct buffer *b,int32_t lower,int32_t upper)
{
    put_word(d,(uintptr_t)b->data);
    put_word(d+8,(uint64_t)-(int64_t)lower);
    put_word(d+16,8);put_word(d+24,UINT64_C(0x0000030100000000));
    put_word(d+32,8);put_word(d+40,1);
    put_word(d+48,(uint64_t)(int64_t)lower);
    put_word(d+56,(uint64_t)(int64_t)upper);
}
static void matrix_descriptor(unsigned char *d,const struct buffer *b,
    int32_t rows,int32_t columns,int32_t lo1,int32_t lo2)
{
    put_word(d,(uintptr_t)b->data);
    put_word(d+8,(uint64_t)(-(int64_t)lo1-(int64_t)rows*lo2));
    put_word(d+16,8);put_word(d+24,UINT64_C(0x0000030200000000));
    put_word(d+32,8);put_word(d+40,1);
    put_word(d+48,(uint64_t)(int64_t)lo1);
    put_word(d+56,(uint64_t)(int64_t)(lo1+rows-1));
    put_word(d+64,(uint64_t)rows);put_word(d+72,(uint64_t)(int64_t)lo2);
    put_word(d+80,(uint64_t)(int64_t)(lo2+columns-1));
}
struct invocation {
    sigam_fn function;
    const void *geometry,*dyn;
    int32_t a,b,columns,levels;
    double *output;
    const double *temperature,*pressure;
};
_Static_assert(sizeof(struct invocation)==64,"frozen argument storage");
_Static_assert(offsetof(struct invocation,function)==0,"function pointer offset");
_Static_assert(offsetof(struct invocation,geometry)==8,"geometry pointer offset");
_Static_assert(offsetof(struct invocation,dyn)==16,"dynamics pointer offset");
_Static_assert(offsetof(struct invocation,a)==24,"vertical stride offset");
_Static_assert(offsetof(struct invocation,b)==28,"column stride offset");
_Static_assert(offsetof(struct invocation,columns)==32,"column count offset");
_Static_assert(offsetof(struct invocation,levels)==36,"level count offset");
_Static_assert(offsetof(struct invocation,output)==40,"output pointer offset");
_Static_assert(offsetof(struct invocation,temperature)==48,"temperature pointer offset");
_Static_assert(offsetof(struct invocation,pressure)==56,"surface pointer offset");
/* This non-numerical bridge leaves every canary register untouched. */
extern void sigam_abi_invoke(void *);
__asm__(
".text\n"
".p2align 4\n"
".global sigam_abi_invoke\n"
".type sigam_abi_invoke,%function\n"
"sigam_abi_invoke:\n"
"sub sp,sp,#32\n"
"str x30,[sp,#16]\n"
"mov x9,x0\n"
"ldr x16,[x9]\n"
"add x10,x9,#36\n"
"str x10,[sp]\n"
"ldp x0,x1,[x9,#8]\n"
"add x2,x9,#24\n"
"add x3,x9,#28\n"
"ldp x4,x5,[x9,#40]\n"
"ldr x6,[x9,#56]\n"
"add x7,x9,#32\n"
"blr x16\n"
"ldr x30,[sp,#16]\n"
"add sp,sp,#32\n"
"ret\n"
".size sigam_abi_invoke,.-sigam_abi_invoke\n");
static uint64_t guarded_invoke(struct invocation *a,int parallel)
{
    uint64_t mask=0;
    if(parallel){
#pragma omp parallel num_threads(2) shared(mask,a)
        {
#pragma omp master
            {
                if(!__oml_mod_MOD_oml_in_parallel())failure("parallel fixture not genuine");
                mask=vertical_abi_call(sigam_abi_invoke,a);
            }
        }
        ++parallel_calls;
    }else mask=vertical_abi_call(sigam_abi_invoke,a);
    ++guarded_calls;
    return mask;
}
static void stage_call(vertical_fn function,int reference,
    const void *vfe,const void *cver,const char *operation,const char *boundary,
    const int32_t *p,const int32_t *start,const int32_t *end,const int32_t *l,
    const double *input,double *output,const int32_t *bc,const int32_t *chunk,
    size_t operation_length,size_t boundary_length)
{
    size_t ni=(size_t)*p*(size_t)(*l+2)*8;
    size_t no=(size_t)*p*(size_t)(*l+1)*8;
    if(memcmp(operation,"IBOT",4)||memcmp(boundary,"11",2)||*start!=1||
       *end!=*p||bc||!chunk||*chunk<1||operation_length!=4||boundary_length!=2)
        failure("case=%u dependency ABI",current_case);
    unsigned char header[64]={0};memcpy(header,"SIGS0001",8);
    put_integer(header+8,(int32_t)current_case);put_integer(header+12,*p);
    put_integer(header+16,*l);put_integer(header+20,integer((const unsigned char *)cver+36));
    put_word(header+24,ni);put_word(header+32,no);
    put_integer(header+40,*chunk);
    if(reference){
        free(stage_input);free(stage_output);
        stage_input=malloc(ni);stage_output=malloc(no);
        if(!stage_input||!stage_output)failure("stage snapshot allocation");
        stage_input_bytes=ni;stage_output_bytes=no;
        memcpy(stage_input,input,ni);
        write_bytes(reference_stages,header,64);write_bytes(reference_stages,input,ni);
    }else{
        if(stage_input_bytes!=ni||stage_output_bytes!=no)failure("stage shape mismatch");
        equal_bytes(stage_input,input,ni,"finite-element-integrand");
        write_bytes(assembly_stages,header,64);write_bytes(assembly_stages,input,ni);
    }
    function(vfe,cver,operation,boundary,p,start,end,l,input,output,bc,chunk,
             operation_length,boundary_length);
    if(reference){
        memcpy(stage_output,output,no);write_bytes(reference_stages,output,no);
    }else{
        equal_bytes(stage_output,output,no,"finite-element-integral");
        write_bytes(assembly_stages,output,no);++stage_records;stage_bytes+=64+ni+no;
    }
}
#define DEPENDENCY_ARGS const void *vfe,const void *cver,const char *op,const char *bd, \
    const int32_t *p,const int32_t *s,const int32_t *e,const int32_t *l, \
    const double *in,double *out,const int32_t *bc,const int32_t *chunk,size_t ol,size_t bl
void sigam_reference_dependency_(DEPENDENCY_ARGS)
{
    stage_call(verdisint_reference_,1,vfe,cver,op,bd,p,s,e,l,in,out,bc,chunk,ol,bl);
}
void sigam_direct_dependency_(DEPENDENCY_ARGS)
{
    stage_call(verdisint_assembly_,0,vfe,cver,op,bd,p,s,e,l,in,out,bc,chunk,ol,bl);
}
static void run_case(const unsigned char *header,const unsigned char *payload,
    size_t payload_bytes,double *rd)
{
    int32_t mode=integer(header+12),ibc=integer(header+16),l=integer(header+20);
    int32_t c=integer(header+24),a=integer(header+28),b=integer(header+32);
    int32_t chunk=integer(header+36),pattern=integer(header+40),flags=integer(header+44);
    int32_t lower=integer(header+48),lo1=integer(header+52),lo2=integer(header+56);
    int32_t stride=integer(header+60),rlower=integer(header+64);
    size_t h=(size_t)word(header+96),rows=(size_t)integer(header+104);
    size_t columns=(size_t)integer(header+108);
    size_t vc=l-lower+1>0?(size_t)(l-lower+1):0;
    size_t rc=l-rlower+1>0?(size_t)(l-rlower+1):0;
    size_t counts[7]={h,(size_t)c,vc,vc,rc,rows*columns,h};
    if(stride!=1||c<0||l<0||a<1||b<1)failure("frozen layout invalid");
    const unsigned char *slices[7];size_t used=0;
    for(int i=0;i<7;++i){
        if(counts[i]>(payload_bytes-used)/8)failure("corpus payload bounds");
        slices[i]=payload+used;used+=counts[i]*8;
    }
    if(used!=payload_bytes)failure("corpus record size");
    struct buffer inputs[6];
    for(int i=0;i<6;++i)inputs[i]=make_buffer(counts[i]*8,slices[i]);
    struct buffer outputs[3];
    for(int i=0;i<3;++i){
        outputs[i]=make_buffer(h*8,NULL);
        for(size_t j=0;j<h;++j)put_real(outputs[i].data+j*8,-777.75);
    }
    struct buffer g=make_buffer(17096,NULL),d=make_buffer(4720,NULL);
    struct buffer eta=make_buffer(320,NULL),vfe=make_buffer(2176,NULL),cv=make_buffer(216,NULL);
    put_word(g.data+3248,(uintptr_t)eta.data);put_word(g.data+3256,(uintptr_t)vfe.data);
    put_word(g.data+3264,(uintptr_t)cv.data);put_integer(g.data+5144,chunk);
    put_integer(g.data+5224,l);put_real(d.data+2560,real(header+88));
    vector(d.data+2600,&inputs[2],lower,l);vector(d.data+2664,&inputs[3],lower,l);
    vector(eta.data+256,&inputs[4],rlower,l);
    put_integer(cv.data+36,ibc);put_integer(cv.data+52,mode);
    if(mode)matrix_descriptor(vfe.data+(ibc==0?64:ibc==2?1296:240),
         &inputs[5],(int32_t)rows,(int32_t)columns,lo1,lo2);
    struct buffer *config[5]={&g,&d,&eta,&vfe,&cv};
    unsigned char *snapshots[5];
    for(int i=0;i<5;++i){
        snapshots[i]=malloc(config[i]->bytes);if(!snapshots[i])failure("configuration snapshot");
        memcpy(snapshots[i],config[i]->data,config[i]->bytes);protect(config[i]);
    }
    for(int i=0;i<6;++i)protect(&inputs[i]);
    put_real(rd,real(header+80));uint64_t rd_before=word(rd);
    struct invocation invocation={sigam_reference_,g.data,d.data,a,b,c,l,
        (double *)outputs[0].data,(const double *)inputs[0].data,(const double *)inputs[1].data};
    if(fpcr()!=0)failure("case=%u FPCR entry",current_case);
    uint64_t mask=guarded_invoke(&invocation,flags!=0);
    if(mask)failure("case=%u reference ABI=%" PRIx64,current_case,mask);
    invocation.function=sigam_assembly_;invocation.output=(double *)outputs[1].data;
    mask=guarded_invoke(&invocation,flags!=0);
    if(mask)failure("case=%u native ABI=%" PRIx64,current_case,mask);
    equal_bytes(outputs[0].data,outputs[1].data,h*8,"PD");
    if(mode){
        invocation.function=sigam_stage_assembly_;invocation.output=(double *)outputs[2].data;
        mask=guarded_invoke(&invocation,flags!=0);
        if(mask)failure("case=%u stage-native ABI=%" PRIx64,current_case,mask);
        equal_bytes(outputs[0].data,outputs[2].data,h*8,"stage-observed-PD");
    }
    if(fpcr()!=0||word(rd)!=rd_before)failure("FPCR or RD changed");
    unsigned char *active=calloc(h?h:1,1);if(!active)failure("active mask");
    double tolerance=real(header+112);
    for(int column=0;column<c;++column)for(int level=0;level<l;++level){
        size_t index=(size_t)level*a+(size_t)column*b;
        if(index>=h||active[index])failure("active index invalid");
        active[index]=1;
        double value=real(outputs[1].data+index*8);
        if(!isfinite(value))failure("case=%u nonfinite returned value",current_case);
        if(pattern!=3){
            double target=real(slices[6]+index*8);
            double amplitude=pattern>=4?fabs(ldexp(1.0,column%4)):0.0;
            double denominator=pattern>=4?amplitude:fmax(1.0,fabs(target));
            double relative=denominator?fabs(value-target)/denominator:fabs(value-target);
            if(pattern>=4 && !amplitude && value!=target)
                failure("zero-amplitude profile must return the exact analytical zero");
            if(relative>tolerance)failure("case=%u independent identity level=%d column=%d"
                " value=%.17g target=%.17g error=%.17g limit=%.17g",
                current_case,level+1,column+1,value,target,relative,tolerance);
            if(pattern==4){if(relative>maximum_constant_error)maximum_constant_error=relative;}
            else if(pattern==5){if(relative>maximum_quartic_error)maximum_quartic_error=relative;}
            else if(relative>maximum_closed_error)maximum_closed_error=relative;
            ++science_values;
        }
    }
    for(size_t i=0;i<h;++i)if(!active[i]){
        if(word(outputs[1].data+8*i)!=word(slices[6]+8*i))failure("inactive PD changed");
        ++inactive_values;
    }
    free(active);
    for(int i=0;i<6;++i){check_buffer(&inputs[i],slices[i],"immutable-input");release(&inputs[i]);}
    for(int i=0;i<5;++i){
        check_buffer(config[i],snapshots[i],"immutable-configuration");
        free(snapshots[i]);release(config[i]);
    }
    write_bytes(reference_stream,header,128);write_bytes(reference_stream,outputs[0].data,h*8);
    write_bytes(assembly_stream,header,128);write_bytes(assembly_stream,outputs[1].data,h*8);
    for(int i=0;i<3;++i){check_buffer(&outputs[i],NULL,"output-guard");release(&outputs[i]);}
    output_bytes+=128+h*8;++cases;
}
int main(int argc,char **argv)
{
    if(argc!=3)failure("usage: sigam CORPUS_DIRECTORY OUTPUT_DIRECTORY");
    if(fpcr()!=0)failure("FPCR must be zero");
    uint64_t endian=1;if(*(unsigned char *)&endian!=1)failure("little endian required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    double *rd=dlsym(RTLD_DEFAULT,"__yomcst_MOD_rd");
    if(!hook||!rd)failure("reference module symbols missing");
    *hook=0;omp_set_dynamic(0);omp_set_num_threads(2);
    __oml_mod_MOD_oml_init();omp_set_num_threads(1);
    if(__oml_mod_MOD_oml_in_parallel())failure("OML initialization must be serial");
    char path[4096];
    if(snprintf(path,sizeof(path),"%s/corpus.bin",argv[1])>=(int)sizeof(path))failure("path");
    FILE *f=fopen(path,"rb");if(!f)failure("corpus open");
    if(fseek(f,0,SEEK_END))failure("corpus seek");
    long length=ftell(f);if(length<0)failure("corpus length");rewind(f);
    size_t bytes=(size_t)length;unsigned char *corpus=malloc(bytes);
    if(!corpus)failure("corpus allocation");
    if(fread(corpus,1,bytes,f)!=bytes||fclose(f))failure("corpus read");
#define OPEN_STREAM(member,name) \
    do {if(snprintf(path,sizeof(path),"%s/" name,argv[2])>=(int)sizeof(path))failure("path"); \
    member=fopen(path,"wb");if(!member)failure("output open");}while(0)
    OPEN_STREAM(reference_stream,"reference.bin");OPEN_STREAM(assembly_stream,"assembly.bin");
    OPEN_STREAM(reference_stages,"reference-stages.bin");OPEN_STREAM(assembly_stages,"assembly-stages.bin");
    size_t offset=0;
    while(offset<bytes){
        if(bytes-offset<128||memcmp(corpus+offset,"SIGF0001",8))failure("corpus header");
        const unsigned char *header=corpus+offset;
        current_case=(uint32_t)integer(header+8);
        if(current_case!=cases)failure("case ordering");
        int32_t l=integer(header+20),c=integer(header+24),lo=integer(header+48),rlo=integer(header+64);
        size_t h=(size_t)word(header+96);
        size_t vc=l-lo+1>0?(size_t)(l-lo+1):0,rc=l-rlo+1>0?(size_t)(l-rlo+1):0;
        size_t payload=(2*h+(size_t)c+2*vc+rc+
            (size_t)integer(header+104)*(size_t)integer(header+108))*8;
        if(payload>bytes-offset-128)failure("corpus extent");
        run_case(header,header+128,payload,rd);offset+=128+payload;
    }
    if(fclose(reference_stream)||fclose(assembly_stream)||fclose(reference_stages)||fclose(assembly_stages))
        failure("stream close");
    free(corpus);free(stage_input);free(stage_output);
    if(snprintf(path,sizeof(path),"%s/summary.json",argv[2])>=(int)sizeof(path))failure("path");
    f=fopen(path,"w");if(!f)failure("summary open");
    fprintf(f,"{\"cases\":%" PRIu64 ",\"output_bytes\":%" PRIu64
        ",\"stage_records\":%" PRIu64 ",\"stage_bytes\":%" PRIu64
        ",\"science_values\":%" PRIu64 ",\"inactive_values\":%" PRIu64
        ",\"guarded_calls\":%" PRIu64 ",\"parallel_calls\":%" PRIu64
        ",\"closed_error\":%.17g,\"actual_constant_error\":%.17g"
        ",\"actual_quartic_error\":%.17g,\"differing_bytes\":0,\"fpcr\":0}\n",
        cases,output_bytes,stage_records,stage_bytes,science_values,inactive_values,
        guarded_calls,parallel_calls,maximum_closed_error,maximum_constant_error,maximum_quartic_error);
    if(fclose(f))failure("summary close");
    printf("SIGAM PASS cases=%" PRIu64 " bytes=%" PRIu64 " stages=%" PRIu64
        " science=%" PRIu64 " differing_bytes=0 FPCR=0\n",cases,output_bytes,stage_records,science_values);
    return 0;
}

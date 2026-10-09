/* Compare complete vertical calls; eta is dimensionless and field units belong
 * to the caller. This driver copies storage and supplies no numerical stage. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <limits.h>
#include <math.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define WRAP_ARGS const void *fe,const void *cv,const char *op,const char *bc, \
 const int32_t *p,const int32_t *start,const int32_t *end,const int32_t *levels, \
 const double *input,double *output,const int32_t *ibc,const int32_t *chunk, \
 size_t op_length,size_t bc_length
#define WRAP_PASS fe,cv,op,bc,p,start,end,levels,input,output,ibc,chunk,op_length,bc_length
#define HELP_ARGS const int32_t *p,const int32_t *start,const int32_t *end, \
 const int32_t *n,const int32_t *m,const double *matrix,const double *input,double *output
#define HELP_PASS p,start,end,n,m,matrix,input,output
typedef void (*wrapper_fn)(WRAP_ARGS);
typedef void (*integral_fn)(HELP_ARGS,const int32_t *,const int32_t *);
typedef void (*derivative_fn)(HELP_ARGS);
void verdisint_complete_assembly_(WRAP_ARGS);
void verint_complete_assembly_(HELP_ARGS,const int32_t *,const int32_t *);
void verder_complete_assembly_(HELP_ARGS);
void verint_reference_(HELP_ARGS,const int32_t *,const int32_t *);
void verder_reference_(HELP_ARGS);
extern const unsigned char verdisint_dispatch_metadata_[896];
extern int32_t __oml_mod_MOD_oml_in_parallel(void);

struct frame {
    struct frame *parent;
    uint64_t record,genuine;
    uint32_t stage,flags;
    int32_t dims[12];
    char op[4],bc[2],caller[64];
    const double *input,*matrix;
    double *output,*shadow;
    unsigned char *input_before,*matrix_before,*output_before,*config_before,*config_capture;
    const void *fe,*cv;
    const int32_t *scalar[8];
    int32_t scalar_before[8];
    size_t scalar_count,input_bytes,output_bytes,matrix_bytes,config_bytes;
    int64_t bounds[4],strides[2];
    const char *operation_address,*boundary_address;
    unsigned children;
};
static pthread_mutex_t mutex=PTHREAD_MUTEX_INITIALIZER;
static _Thread_local unsigned lock_depth,reference_depth;
static _Thread_local struct frame *current;
static wrapper_fn source_wrapper;
static integral_fn source_integral;
static derivative_fn source_derivative;
static const int32_t *step;
static FILE *assembly_stream,*reference_stream,*input_stream;
static uint64_t records,genuine_visits,canonical_bytes;
static uint64_t genuine[3],private_calls[3],comparison_calls[3];

static void fail(const char *message)
{
    fprintf(stderr,"VERTICAL forecast check failed: %s\n",message);_Exit(2);
}
static uint64_t fpcr(void)
{
    uint64_t value;__asm__ volatile("mrs %0,fpcr":"=r"(value));return value;
}
static uint64_t bits(const double *value)
{
    uint64_t result;memcpy(&result,value,8);return result;
}
static int32_t integer(const void *object,size_t offset)
{
    int32_t result;memcpy(&result,(const char *)object+offset,4);return result;
}
static int64_t word(const void *object,size_t offset)
{
    int64_t result;memcpy(&result,(const char *)object+offset,8);return result;
}
static size_t extent(int32_t p,int32_t columns)
{
    if(p<1 || columns<0 || (uint64_t)(uint32_t)p*(uint32_t)columns>(uint64_t)INT64_MAX/8)
        fail("buffer extent");
    return (size_t)p*(size_t)columns*8;
}
static int overlap(const void *a,size_t na,const void *b,size_t nb)
{
    uintptr_t x=(uintptr_t)a,y=(uintptr_t)b;
    if(x>UINTPTR_MAX-na || y>UINTPTR_MAX-nb)fail("buffer address overflow");
    return na && nb && x<y+nb && y<x+na;
}
static unsigned char *copy_bytes(const void *data,size_t bytes)
{
    if(bytes && (!data || ((uintptr_t)data&7)))fail("missing or unaligned array");
    unsigned char *copy=malloc(bytes?bytes:1);if(!copy)fail("copy allocation");
    if(bytes)memcpy(copy,data,bytes);
    return copy;
}
static void write_bytes(FILE *stream,const void *data,size_t bytes)
{
    if(bytes && fwrite(data,1,bytes,stream)!=bytes)fail("capture write");
}
/* Other complete-routine comparators mark only their source-shadow phase. */
void vertical_forecast_reference_begin(void)
{
    if(reference_depth==UINT_MAX)fail("reference nesting overflow");
    ++reference_depth;
}
void vertical_forecast_reference_end(void)
{
    if(!reference_depth)fail("reference nesting underflow");
    --reference_depth;
}
static void *source_symbol(const char *name)
{
    void *symbol=dlsym(RTLD_NEXT,name);Dl_info info;
    if(!symbol || !dladdr(symbol,&info) || !info.dli_fname ||
       !strstr(info.dli_fname,"libstrict-vertical-reference.so"))
        fail("required original-source ordered vertical library");
    return symbol;
}
static void initialize(void)
{
    if(source_wrapper)return;
    uint64_t endian=1;if(*(unsigned char *)&endian!=1)fail("little-endian encoding");
    void *symbol=source_symbol("verdisint_");memcpy(&source_wrapper,&symbol,sizeof source_wrapper);
    symbol=source_symbol("verint_");memcpy(&source_integral,&symbol,sizeof source_integral);
    symbol=source_symbol("verder_");memcpy(&source_derivative,&symbol,sizeof source_derivative);
    step=dlsym(RTLD_DEFAULT,"__yomct3_MOD_nstep");if(!step)fail("forecast step");
    assembly_stream=fopen("vertical-assembly.bin","wb");
    reference_stream=fopen("vertical-fortran.bin","wb");
    input_stream=fopen("vertical-inputs.bin","wb");
    if(!assembly_stream || !reference_stream || !input_stream)fail("capture open");
}
static void enter(struct frame *f,uint32_t stage,void *caller)
{
    if(lock_depth++==0 && pthread_mutex_lock(&mutex))fail("mutex lock");
    initialize();if(fpcr()!=0)fail("entry FPCR must be zero");
    memset(f,0,sizeof *f);f->parent=current;f->stage=stage;f->record=++records;
    int is_comparison=reference_depth || (current && (current->flags&16));
    f->flags=(uint32_t)(__oml_mod_MOD_oml_in_parallel()!=0)<<1;
    if(is_comparison)f->flags|=16;
    if(!current && !is_comparison) {
        f->flags|=1;f->genuine=++genuine_visits;++genuine[stage-1];
    } else {
        f->genuine=current?current->genuine:0;
        if(is_comparison)++comparison_calls[stage-1];else ++private_calls[stage-1];
    }
    Dl_info info;memset(&info,0,sizeof info);
    if(current)strncpy(f->caller,"VERDISINT/native-helper",sizeof f->caller-1);
    else if(dladdr(caller,&info) && info.dli_sname)
        strncpy(f->caller,info.dli_sname,sizeof f->caller-1);
    else fail("caller symbol");
    f->dims[6]=-1;f->dims[7]=-1;f->dims[9]=-1;
    current=f;
}
static void scalar(struct frame *f,const int32_t *value)
{
    if(!value || f->scalar_count>=8)fail("scalar argument");
    size_t index=f->scalar_count++;f->scalar[index]=value;f->scalar_before[index]=*value;
}
static void storage(struct frame *f)
{
    if(overlap(f->output,f->output_bytes,f->input,f->input_bytes) ||
       overlap(f->output,f->output_bytes,f->matrix,f->matrix_bytes) ||
       overlap(f->output,f->output_bytes,f->fe,f->fe?2176:0) ||
       overlap(f->output,f->output_bytes,f->cv,f->cv?216:0))fail("output alias");
    f->input_before=copy_bytes(f->input,f->input_bytes);
    f->matrix_before=copy_bytes(f->matrix,f->matrix_bytes);
    f->output_before=copy_bytes(f->output,f->output_bytes);
    f->shadow=(double *)copy_bytes(f->output,f->output_bytes);
}
static void immutable(const struct frame *f)
{
    if(fpcr()!=0)fail("changed FPCR");
    if(memcmp(f->input_before,f->input,f->input_bytes) ||
       memcmp(f->matrix_before,f->matrix,f->matrix_bytes))fail("changed input or coefficients");
    for(size_t i=0;i<f->scalar_count;++i)
        if(memcmp(&f->scalar_before[i],f->scalar[i],4))fail("changed scalar argument");
    if(f->fe && (memcmp(f->config_before,f->fe,2176) ||
                 memcmp(f->config_before+2176,f->cv,216)))fail("changed TVFE or TCVER");
    if(f->operation_address && (memcmp(f->op,f->operation_address,4) ||
                               memcmp(f->bc,f->boundary_address,2)))fail("changed selector bytes");
}
static void encode(unsigned char header[256],const struct frame *f)
{
    memset(header,0,256);memcpy(header,"VRTF0001",8);
    memcpy(header+8,&f->record,8);memcpy(header+16,&f->genuine,8);
    uint64_t parent=f->parent?f->parent->record:0;memcpy(header+24,&parent,8);
    memcpy(header+32,&f->stage,4);memcpy(header+36,&f->flags,4);
    memcpy(header+40,step,4);memcpy(header+44,f->dims,48);
    memcpy(header+92,f->op,4);memcpy(header+96,f->bc,2);memcpy(header+100,f->caller,64);
    uint64_t lengths[4]={f->output_bytes,f->input_bytes,f->matrix_bytes,f->config_bytes};
    memcpy(header+168,lengths,32);memcpy(header+200,f->bounds,32);
    memcpy(header+232,f->strides,16);uint64_t control=fpcr();memcpy(header+248,&control,8);
}
static void finish(struct frame *f)
{
    immutable(f);
    size_t cells=f->output_bytes/8;
    for(size_t k=0;k<cells;++k) {
        uint64_t native=bits(f->output+k),reference=bits(f->shadow+k);
        if(native!=reference) {
            fprintf(stderr,"Mismatch stage=%u step=%d record=%" PRIu64
                " genuine=%" PRIu64 " parent=%" PRIu64 " caller=%s operation=%.4s"
                " IBC=%d BC=%.2s point=%zu row=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                f->stage,*step,f->record,f->genuine,f->parent?f->parent->record:0,
                f->caller,f->op,f->dims[6],f->bc,k%(size_t)f->dims[0]+1,
                k/(size_t)f->dims[0]+1,native,reference);_Exit(1);
        }
        int32_t point=(int32_t)(k%(size_t)f->dims[0])+1;
        int active=point>=f->dims[1] && point<=f->dims[2];
        if(active && !isfinite(f->output[k]))fail("nonfinite active output");
        if(!active && native!=bits((const double *)f->output_before+k))
            fail("changed inactive output");
    }
    unsigned char header[256];encode(header,f);
    write_bytes(assembly_stream,header,256);write_bytes(reference_stream,header,256);
    write_bytes(input_stream,header,256);
    write_bytes(assembly_stream,f->output,f->output_bytes);
    write_bytes(reference_stream,f->shadow,f->output_bytes);
    write_bytes(input_stream,f->input_before,f->input_bytes);
    write_bytes(input_stream,f->output_before,f->output_bytes);
    write_bytes(input_stream,f->matrix_before,f->matrix_bytes);
    write_bytes(input_stream,f->config_capture,f->config_bytes);
    canonical_bytes+=256+f->output_bytes;
    free(f->input_before);free(f->matrix_before);free(f->output_before);free(f->shadow);
    free(f->config_before);free(f->config_capture);
    current=f->parent;
    if(!lock_depth)fail("lock nesting underflow");
    if(--lock_depth==0 && pthread_mutex_unlock(&mutex))fail("mutex unlock");
}
static void matrix_descriptor(struct frame *f,const void *descriptor)
{
    memcpy(&f->matrix,descriptor,8);
    f->bounds[0]=word(descriptor,48);f->bounds[1]=word(descriptor,56);
    f->bounds[2]=word(descriptor,72);f->bounds[3]=word(descriptor,80);
    f->strides[0]=word(descriptor,40);f->strides[1]=word(descriptor,64);
    if(!f->matrix || word(descriptor,16)!=8 || word(descriptor,32)!=8 ||
       f->strides[0]!=1 || f->strides[1]!=f->dims[5] ||
       f->bounds[1]<f->bounds[0] || f->bounds[3]<f->bounds[2] ||
       (uint64_t)f->bounds[1]-(uint64_t)f->bounds[0]!=(uint64_t)f->dims[5]-1 ||
       (uint64_t)f->bounds[3]-(uint64_t)f->bounds[2]!=(uint64_t)f->dims[4]-1)
        fail("selected matrix allocation");
}
static void wrapper(int direct,void *caller,WRAP_ARGS)
{
    struct frame f;enter(&f,1,caller);(void)direct;
    if(!fe || !cv || !op || !bc || op_length!=4 || bc_length!=2)fail("wrapper ABI");
    scalar(&f,p);scalar(&f,start);scalar(&f,end);scalar(&f,levels);
    if(ibc){scalar(&f,ibc);f.flags|=4;}
    if(chunk){scalar(&f,chunk);f.flags|=8;}
    if(*p<1 || *levels<1 || *levels>INT_MAX-2 || *start<1 || *start>*p ||
       *end<*start-1 || *end>*p || !integer(cv,52))fail("wrapper shape");
    const char operations[]="ITOPIBOTINGWDEGWHDERFDERDDER";
    int operation=0;while(operation<7 && memcmp(op,operations+operation*4,4))++operation;
    if(operation==7 || (bc[0]!='0' && bc[0]!='1') ||
       (bc[1]!='0' && bc[1]!='1'))fail("wrapper selector");
    int mode=ibc?*ibc:integer(cv,operation<3?36:40);
    if(mode<0 || mode>3)fail("IBC");
    int boundary=2*(bc[0]-'0')+bc[1]-'0';
    const unsigned char *selection=verdisint_dispatch_metadata_+8*(16*operation+4*mode+boundary);
    if(selection[6])fail("undefined or source-abort selector outside accepted domain");
    int32_t count_n=*levels+selection[3],count_m=*levels+selection[4];
    int offset=selection[0]+256*selection[1],first=selection[2];
    int32_t chunk_value=chunk?*chunk:1;
    if((operation<3 && (chunk_value<1 || ((f.flags&2) && *start!=1))) ||
       (operation>=3 && *start!=1))fail("helper row or chunk restriction");
    f.dims[0]=*p;f.dims[1]=*start;f.dims[2]=*end;f.dims[3]=*levels;
    f.dims[4]=count_n;f.dims[5]=count_m;f.dims[6]=mode;
    f.dims[7]=operation<3?selection[5]:-1;f.dims[8]=chunk_value;
    f.dims[9]=offset;f.dims[10]=first;memcpy(f.op,op,4);memcpy(f.bc,bc,2);
    f.operation_address=op;f.boundary_address=bc;f.fe=fe;f.cv=cv;
    f.config_bytes=2392;f.config_before=malloc(2392);f.config_capture=malloc(2392);
    if(!f.config_before || !f.config_capture)fail("configuration copy");
    memcpy(f.config_before,fe,2176);memcpy(f.config_before+2176,cv,216);
    memcpy(f.config_capture,f.config_before,2392);
    memset(f.config_capture,0,8);
    for(size_t j=0;j<24;++j)memset(f.config_capture+64+j*88,0,8);
    if(operation==4 && !word((const char *)fe+856,0))fail("HDER prerequisite matrix");
    matrix_descriptor(&f,(const char *)fe+offset);
    f.input=input;f.output=output;f.input_bytes=extent(*p,*levels+2);
    f.output_bytes=extent(*p,count_m);f.matrix_bytes=extent(count_m,count_n);
    storage(&f);
    vertical_forecast_reference_begin();
    source_wrapper(fe,cv,op,bc,p,start,end,levels,input,f.shadow,ibc,chunk,op_length,bc_length);
    vertical_forecast_reference_end();immutable(&f);
    verdisint_complete_assembly_(WRAP_PASS);
    if(f.children!=(unsigned)(*end>=*start))fail("complete direct helper stage count");
    finish(&f);
}
void verdisint_(WRAP_ARGS)
{
    wrapper(0,__builtin_return_address(0),WRAP_PASS);
}
void verdisint_assembly_(WRAP_ARGS)
{
    wrapper(1,__builtin_return_address(0),WRAP_PASS);
}
static void helper(int integral,int direct,void *caller,HELP_ARGS,
                   const int32_t *type,const int32_t *chunk)
{
    struct frame f;enter(&f,integral?2:3,caller);
    scalar(&f,p);scalar(&f,start);scalar(&f,end);scalar(&f,n);scalar(&f,m);
    if(integral){scalar(&f,type);scalar(&f,chunk);}
    if(*p<1 || *n<1 || *m<1 || *start<1 || *start>*p || *end<*start-1 || *end>*p ||
       (integral?(*type<0 || *type>1 || *chunk<1 || ((f.flags&2)&&*start!=1)):*start!=1))
        fail("helper shape or row restriction");
    f.dims[0]=*p;f.dims[1]=*start;f.dims[2]=*end;f.dims[4]=*n;f.dims[5]=*m;
    f.dims[7]=integral?*type:-1;f.dims[8]=integral?*chunk:0;
    f.input=input;f.matrix=matrix;f.output=output;f.input_bytes=extent(*p,*n);
    f.output_bytes=extent(*p,*m);f.matrix_bytes=extent(*m,*n);
    f.bounds[0]=f.bounds[2]=1;f.bounds[1]=*m;f.bounds[3]=*n;
    f.strides[0]=1;f.strides[1]=*m;
    if(f.parent) {
        struct frame *parent=f.parent;
        if(!direct || parent->stage!=1 || *p!=parent->dims[0] || *start!=parent->dims[1] ||
           *end!=parent->dims[2] || *n!=parent->dims[4] || *m!=parent->dims[5] ||
           matrix!=parent->matrix || output!=parent->output ||
           integral!=(parent->dims[7]>=0) || (integral && *type!=parent->dims[7]))
            fail("wrapper complete helper ABI");
        if(integral) {
            for(int32_t column=0;column<*n;++column)for(int32_t point=*start-1;point<*end;++point) {
                int physical=parent->dims[10]+column;
                size_t k=(size_t)column*(size_t)*p+(size_t)point;
                uint64_t expected=physical>=1 && physical<=parent->dims[3]?
                    bits(parent->input+(size_t)physical*(size_t)*p+(size_t)point):0;
                if(bits(input+k)!=expected)fail("local integral copy or boundary bytes");
            }
        } else if(input!=parent->input+(size_t)parent->dims[10]*(size_t)*p)
            fail("derivative input base");
        ++parent->children;f.dims[3]=parent->dims[3];f.dims[6]=parent->dims[6];
        f.dims[9]=parent->dims[9];f.dims[10]=parent->dims[10];
        memcpy(f.op,parent->op,4);memcpy(f.bc,parent->bc,2);
        memcpy(f.bounds,parent->bounds,32);memcpy(f.strides,parent->strides,16);
    }
    storage(&f);vertical_forecast_reference_begin();
    if(integral) {
        if(direct)verint_reference_(p,start,end,n,m,matrix,input,f.shadow,type,chunk);
        else source_integral(p,start,end,n,m,matrix,input,f.shadow,type,chunk);
    } else {
        if(direct)verder_reference_(p,start,end,n,m,matrix,input,f.shadow);
        else source_derivative(p,start,end,n,m,matrix,input,f.shadow);
    }
    vertical_forecast_reference_end();immutable(&f);
    if(integral)verint_complete_assembly_(HELP_PASS,type,chunk);
    else verder_complete_assembly_(HELP_PASS);
    finish(&f);
}
void verint_(HELP_ARGS,const int32_t *type,const int32_t *chunk)
{
    helper(1,0,__builtin_return_address(0),HELP_PASS,type,chunk);
}
void verint_assembly_(HELP_ARGS,const int32_t *type,const int32_t *chunk)
{
    helper(1,1,__builtin_return_address(0),HELP_PASS,type,chunk);
}
void verder_(HELP_ARGS)
{
    helper(0,0,__builtin_return_address(0),HELP_PASS,NULL,NULL);
}
void verder_assembly_(HELP_ARGS)
{
    helper(0,1,__builtin_return_address(0),HELP_PASS,NULL,NULL);
}
__attribute__((destructor)) static void finish_forecast(void)
{
    if(!assembly_stream)return;
    if(current || lock_depth || reference_depth)fail("unfinished comparison nesting");
    if(fclose(assembly_stream) || fclose(reference_stream) || fclose(input_stream))
        fail("capture close");
    FILE *summary=fopen("vertical-summary.json","w");if(!summary)fail("summary open");
    fprintf(summary,"{\"passed\":true,\"records\":%" PRIu64 ",\"canonical_bytes\":%" PRIu64
        ",\"differing_bytes\":0,\"genuine_dispatcher_calls\":%" PRIu64
        ",\"genuine_integral_calls\":%" PRIu64 ",\"genuine_derivative_calls\":%" PRIu64
        ",\"private_integral_checks\":%" PRIu64 ",\"private_derivative_checks\":%" PRIu64
        ",\"comparison_dispatcher_checks\":%" PRIu64 ",\"comparison_integral_checks\":%" PRIu64
        ",\"comparison_derivative_checks\":%" PRIu64 ",\"FPCR\":%" PRIu64 "}\n",
        records,canonical_bytes,genuine[0],genuine[1],genuine[2],private_calls[1],
        private_calls[2],comparison_calls[0],comparison_calls[1],comparison_calls[2],fpcr());
    if(fclose(summary))fail("summary close");
    fprintf(stderr,"VERTICAL FORECAST PASS genuine_dispatch=%" PRIu64
        " private_integral=%" PRIu64 " comparison_dispatch=%" PRIu64
        " records=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",
        genuine[0],private_calls[1],comparison_calls[0],records,canonical_bytes,fpcr());
}

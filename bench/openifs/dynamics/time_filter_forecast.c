/* Compare complete time-filter states inside the frozen T21 forecast.
 * The two accepted callers supply complete air, surface and tracer arrays.
 * Each snapshot keeps inactive values and all original FP64 output bits. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define TF1_ARGS const void *g,const void *v,const void *m,const void *d, \
 const void *a,const int32_t *filter,const int32_t *ks,const int32_t *ke, \
 const int32_t *last,double *air,double *surface,double *tracer
#define TF2_ARGS const void *g,const void *v,const void *m,const void *d, \
 const void *a,const int32_t *ks,const int32_t *ke,const int32_t *first, \
 double *air,double *surface,double *tracer
typedef void (*first_kernel)(TF1_ARGS);
typedef void (*second_kernel)(TF2_ARGS);
void gptf1_assembly_(TF1_ARGS);
void gptf2_assembly_(TF2_ARGS);
typedef struct {FILE *assembly,*reference,*inputs;uint64_t calls,bytes,fpcr;uint64_t weighted,copy,clear,empty;} record;
static first_kernel first_reference;
static second_kernel second_reference;
static record records[2];
static const int32_t *step;
static const int offsets[2][15]={
 {12,16,32,20,24,28,48,60,52,64,56,68,88,92,72},
 {8,12,80,16,20,24,96,108,100,112,104,116,208,212,120}};
static void fail(const char *message) {
    fprintf(stderr,"Time-filter forecast check failed %s\n",message);_Exit(2);
}
static int32_t integer(const void *obj,size_t offset) {
    int32_t n;memcpy(&n,(const char *)obj+offset,4);return n;
}
static uint64_t bits(double x) {uint64_t n;memcpy(&n,&x,8);return n;}
static uint64_t control(void) {uint64_t n;__asm__ volatile("mrs %0,fpcr":"=r"(n));return n;}
static void write_bytes(FILE *f,const void *p,size_t n) {
    if(n && fwrite(p,1,n,f)!=n) fail("capture write");
}
static int overlap(const void *p,size_t n,const void *q,size_t m) {
    uintptr_t a=(uintptr_t)p,b=(uintptr_t)q;
    if(a>UINTPTR_MAX-n || b>UINTPTR_MAX-m) fail("address overflow");
    return n && m && a<b+m && b<a+n;
}
static size_t extent(int32_t p,int32_t l,int32_t n) {
    if(p<1 || l<0 || n<0) fail("buffer dimensions");
    uint64_t cells=(uint64_t)p*(uint64_t)l;
    if(n && cells>(uint64_t)INT64_MAX/8/(uint64_t)n) fail("buffer byte extent");
    return (size_t)(cells*(uint64_t)n*8);
}
static void check_pair(const void *t0,const void *t9,int o0,int o9,
                       int capacity,unsigned char *seen) {
    int source=integer(t0,(size_t)o0),target=integer(t9,(size_t)o9);
    if(source<1 || target<1 || source>capacity || target>capacity ||
       source==target || seen[source-1] || seen[target-1]) fail("field-pair capacity or alias");
    seen[source-1]=seen[target-1]=1;
}
static void initialize(int which) {
    record *r=&records[which-1];if(r->assembly)return;
    void *s=dlsym(RTLD_NEXT,which==1?"gptf1_":"gptf2_");
    if(!s) fail("strict reference routine");
    if(which==1) memcpy(&first_reference,&s,sizeof s);else memcpy(&second_reference,&s,sizeof s);
    step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");if(!step)fail("forecast step");
    char path[64];
    snprintf(path,sizeof path,"gptf%d-assembly.bin",which);r->assembly=fopen(path,"wb");
    snprintf(path,sizeof path,"gptf%d-fortran.bin",which);r->reference=fopen(path,"wb");
    snprintf(path,sizeof path,"gptf%d-inputs.bin",which);r->inputs=fopen(path,"wb");
    if(!r->assembly || !r->reference || !r->inputs) fail("capture files");
}
__attribute__((destructor)) static void finish(void) {
    for(int j=0;j<2;++j) {
        record *r=&records[j];if(!r->assembly)continue;
        if(fclose(r->assembly)||fclose(r->reference)||fclose(r->inputs))fail("capture close");
        fprintf(stderr,"GPTF%d FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64
            " differing_bytes=0 weighted_calls=%" PRIu64 " copy_calls=%" PRIu64
            " clear_calls=%" PRIu64 " empty_calls=%" PRIu64 " FPCR=%016" PRIx64 "\n",
            j+1,r->calls,r->bytes,r->weighted,r->copy,r->clear,r->empty,r->fpcr);
    }
}
static void run(int which,const void *caller,const void *g,const void *v,const void *m,
                const void *d,const void *a,const int32_t *filter,const int32_t *ks,
                const int32_t *ke,const int32_t *flag,double *air,double *surface,double *tracer) {
    Dl_info location;
    if(!dladdr(caller,&location)||!location.dli_sname||
       strcmp(location.dli_sname,which==1?"cpglag_":"cpg_gp_"))fail("caller outside frozen full-buffer scope");
    if(!g||!v||!m||!d||!a||!ks||!ke||!flag||(which==1&&!filter))fail("configuration arguments");
    initialize(which);record *r=&records[which-1];
    r->fpcr=control();if(r->fpcr!=0)fail("FPCR must be zero");
    int32_t np=integer(g,5144),nf=integer(g,5224),na=integer(v,992),ns=integer(v,996);
    int32_t ng=integer(m,232),nc=integer(m,184),therm=integer(m,8);
    int32_t two=integer(a,20),grad=integer(a,200),full=integer(a,336),nh=integer(a,8),nv=integer(a,32);
    int32_t enabled=which==1?*filter:0,kst=*ks,ken=*ke,edge=*flag;
    if(np<1||nf<0||kst<1||kst>np||ken<kst-1||ken>np||nc<0||nc>2163)fail("shape or component bounds");
    if((two&~1)||(grad&~1)||(full&~1)||(nh&~1)||(enabled&~1)||(edge&~1))fail("logical representation");
    size_t sizes[3]={extent(np,nf,na),extent(np,1,ns),extent(np,nf,ng)};
    double *out[3]={air,surface,tracer},*shadow[3];
    const void *obj[5]={g,v,m,d,a};size_t object_bytes[5]={17096,1560,1556112,4720,456};void *obj_copy[5];
    for(int b=0;b<3;++b) {
        if(sizes[b] && (!out[b]||((uintptr_t)out[b]&7)))fail("output storage");
        for(int c=0;c<b;++c)if(overlap(out[b],sizes[b],out[c],sizes[c]))fail("overlapping outputs");
        shadow[b]=malloc(sizes[b]?sizes[b]:8);if(!shadow[b])fail("shadow state");
        if(sizes[b])memcpy(shadow[b],out[b],sizes[b]);
    }
    for(int j=0;j<5;++j) {
        obj_copy[j]=malloc(object_bytes[j]);if(!obj_copy[j])fail("configuration snapshot");
        memcpy(obj_copy[j],obj[j],object_bytes[j]);
        for(int b=0;b<3;++b)if(overlap(obj[j],object_bytes[j],out[b],sizes[b]))fail("configuration overlap");
    }
    const void *t0=(const char *)v+1000,*t9=(const char *)v+1108;
    unsigned char *seen=calloc((size_t)(na>ns?na:ns)+1,1);if(!seen)fail("field map");
    int active=ken>=kst,selected[15]={0},surface_selected=0,tracer_selected=0;
    int bulk=which==1 && enabled && !two && edge;
    int weighted=which==1?enabled&&!two&&!edge:!two&&!edge;
    if(which==1) {
        if(enabled && !two && !edge) {
            selected[0]=selected[1]=selected[2]=1;
            for(int j=3;j<6;++j)selected[j]=therm>=1;
            for(int j=6;j<12;++j)selected[j]=nh;
            surface_selected=tracer_selected=1;
        } else if(enabled && two) {
            selected[0]=selected[1]=1;selected[12]=selected[13]=grad;
            for(int j=3;j<6;++j)selected[j]=full;
            for(int j=6;j<12;++j)selected[j]=full&&nh;
            surface_selected=tracer_selected=full;
        } else if(!enabled)selected[12]=selected[13]=grad;
        if(bulk)tracer_selected=1;
    } else if(!two || edge) {
        selected[0]=selected[1]=1;
        if(!two) {
            selected[2]=1;
            for(int j=3;j<6;++j)selected[j]=therm>=1;
            for(int j=6;j<12;++j)selected[j]=nh;
            selected[14]=edge&&nh&&nv==4;
            surface_selected=tracer_selected=1;
        }
    }
    if(active && nf)for(int j=0;j<15;++j)if(selected[j])
        check_pair(t0,t9,offsets[0][j],offsets[1][j],na,seen);
    memset(seen,0,(size_t)(na>ns?na:ns)+1);
    if(active && surface_selected)for(int j=0;j<3;++j)check_pair(t0,t9,96+4*j,216+4*j,ns,seen);
    free(seen);
    if(bulk && (integer(t0,0)<0||integer(t0,0)>na||integer(t0,4)<0||integer(t0,4)>ns))fail("clear suffix capacity");
    seen=calloc((size_t)ng+1,1);if(!seen)fail("tracer map");
    for(int c=0;c<nc;++c) {
        const void *component=(const char *)m+4032+(size_t)c*368;
        int on=integer(component,88);if(on&~1)fail("tracer logical");
        if(active && nf && tracer_selected && on) {
            int source=integer(component,168),target=integer(component,180);
            if(target<1||target>ng||seen[target-1])fail("tracer target");
            seen[target-1]=1;
            if(!bulk) {
                if(source<1||source>ng||source==target||seen[source-1])fail("tracer source or alias");
                seen[source-1]=1;
            }
        }
    }
    free(seen);
    double eps[4];memcpy(eps,d,32);
    if(weighted)for(int j=0;j<4;++j)if(!isfinite(eps[j]))fail("finite filter coefficient");
    ++r->calls;r->weighted+=(uint64_t)weighted;r->clear+=(uint64_t)bulk;
    int any=surface_selected||tracer_selected;
    for(int j=0;j<15;++j)any|=selected[j];
    r->copy+=(uint64_t)(any&&!weighted&&!bulk);r->empty+=(uint64_t)!active;
    int32_t header[32]={np,nf,na,ns,ng,nc,therm,kst,ken,enabled,two,grad,full,nh,edge,nv,which};
    FILE *files[3]={r->assembly,r->reference,r->inputs};
    for(int b=0;b<3;++b) {
        write_bytes(files[b],&r->calls,8);write_bytes(files[b],step,4);write_bytes(files[b],&which,4);
        write_bytes(files[b],header,sizeof header);write_bytes(files[b],t0,360);write_bytes(files[b],eps,32);
        for(int c=0;c<nc;++c) {
            const void *component=(const char *)m+4032+(size_t)c*368;
            int32_t entry[3]={integer(component,88),integer(component,168),integer(component,180)};
            write_bytes(files[b],entry,sizeof entry);
        }
    }
    r->bytes+=16+128+360+32+(uint64_t)nc*12;
    for(int b=0;b<3;++b)write_bytes(r->inputs,out[b],sizes[b]);
    if(which==1) {
        first_reference(g,v,m,d,a,filter,ks,ke,flag,shadow[0],shadow[1],shadow[2]);
        if(control()!=r->fpcr)fail("reference changed FPCR");
        gptf1_assembly_(g,v,m,d,a,filter,ks,ke,flag,air,surface,tracer);
    } else {
        second_reference(g,v,m,d,a,ks,ke,flag,shadow[0],shadow[1],shadow[2]);
        if(control()!=r->fpcr)fail("reference changed FPCR");
        gptf2_assembly_(g,v,m,d,a,ks,ke,flag,air,surface,tracer);
    }
    if(control()!=r->fpcr)fail("assembly changed FPCR");
    if(*ks!=kst||*ke!=ken||*flag!=edge||(which==1&&*filter!=enabled))fail("changed scalar argument");
    for(int b=0;b<3;++b) {
        for(size_t j=0;j<sizes[b]/8;++j)if(bits(out[b][j])!=bits(shadow[b][j])) {
            size_t cells=b==1?(size_t)np:(size_t)np*(size_t)nf;
            fprintf(stderr,"Mismatch stage=GPTF%d step=%d call=%" PRIu64
                " buffer=%d field=%zu level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                which,*step,r->calls,b,j/cells+1,b==1?0:j%(cells)/(size_t)np+1,
                j%(size_t)np+1,bits(out[b][j]),bits(shadow[b][j]));_Exit(1);
        }
        write_bytes(r->assembly,out[b],sizes[b]);write_bytes(r->reference,shadow[b],sizes[b]);
        r->bytes+=sizes[b];free(shadow[b]);
    }
    for(int j=0;j<5;++j) {
        if(memcmp(obj_copy[j],obj[j],object_bytes[j]))fail("changed configuration");
        free(obj_copy[j]);
    }
}
void gptf1_(TF1_ARGS) {run(1,__builtin_return_address(0),g,v,m,d,a,filter,ks,ke,last,air,surface,tracer);}
void gptf2_(TF2_ARGS) {run(2,__builtin_return_address(0),g,v,m,d,a,NULL,ks,ke,first,air,surface,tracer);}

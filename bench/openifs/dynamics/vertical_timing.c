#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <inttypes.h>
#include <sched.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <time.h>
#include <unistd.h>

/* Each call completes the private ordered matrix operation. Input preparation,
 * validation, warm-up and file output remain outside the timer. */
typedef void (*matrix_fn)(const char*,const char*,const int*,const int*,const int*,
    const double*,const double*,const int*,const double*,const int*,const double*,
    double*,const int*,size_t,size_t);
struct workload { const char *name; int m,ld; };
static const struct workload work[]={
    {"single_point",1,1},{"boundary_block",8,24},
    {"forecast_block",24,24},{"larger_block",506,506}};
static const char *names[]={"scalar","v8",NULL,NULL};
static unsigned variant_count=2;
extern void __oml_mod_MOD_oml_init(void);
void LinuxTraceBack(void);
static uint64_t fpcr(void) {
    uint64_t v;__asm__ volatile("mrs %0, fpcr":"=r"(v));return v;
}
static void fail(const char *message) {
    fprintf(stderr,"MATRIX TIMING FAIL %s errno=%d\n",message,errno);exit(1);
}
void LinuxTraceBack(void) {fail("unexpected Fortran runtime failure");}
void abor1_(const char *message,size_t length) {
    fprintf(stderr,"MATRIX CONTRACT REJECTION %.*s\n",(int)length,message);exit(1);
}
static uint64_t ns(void) {
    struct timespec t;if(clock_gettime(CLOCK_MONOTONIC_RAW,&t))fail("clock");
    return (uint64_t)t.tv_sec*UINT64_C(1000000000)+(uint64_t)t.tv_nsec;
}
static double *buffer(size_t words) {
    void *p=NULL;if(posix_memalign(&p,64,words*sizeof(double)))fail("allocation");
    return p;
}
static void path(char *out,size_t capacity,const char *dir,const char *name) {
    int n=snprintf(out,capacity,"%s/%s",dir,name);
    if(n<0||(size_t)n>=capacity)fail("path");
}
static void write_file(const char *dir,const char *name,const void *p,size_t bytes) {
    char dest[4096];path(dest,sizeof dest,dir,name);
    FILE *f=fopen(dest,"wb");if(!f)fail("open write");
    if(fwrite(p,1,bytes,f)!=bytes||fclose(f))fail("write");
}
static void read_file(const char *dir,const char *name,void *p,size_t bytes) {
    char src[4096];path(src,sizeof src,dir,name);
    FILE *f=fopen(src,"rb");if(!f)fail("open read");
    if(fread(p,1,bytes,f)!=bytes||fgetc(f)!=EOF||fclose(f))fail("read size");
}
static void call(matrix_fn fn,const struct workload *w,const double *a,
                 const double *b,double *c) {
    const char ta='N',tb='T';const int n=20,k=21,ldb=20;
    const double alpha=1.0,beta=0.0;
    fn(&ta,&tb,&w->m,&n,&k,&alpha,a,&w->ld,b,&ldb,&beta,c,&w->ld,1,1);
}
static void unchanged(const double *a,const double *saved,size_t words) {
    if(memcmp(a,saved,words*sizeof(double)))fail("input mutation");
}
static void exact(const double *a,const double *saved,size_t words) {
    if(!memcmp(a,saved,words*sizeof(double)))return;
    for(size_t i=0;i<words;i++) {
        uint64_t x,y;memcpy(&x,a+i,8);memcpy(&y,saved+i,8);
        if(x!=y){fprintf(stderr,"word=%zu expected=%016" PRIx64 " actual=%016"
            PRIx64 "\n",i,y,x);break;}
    }
    fail("output bytes");
}
static void initialize(const struct workload *w,double *a,double *c) {
    for(size_t i=0;i<(size_t)w->ld*21;i++)
        a[i]=(double)((int)((i*17+(i/(size_t)w->ld)*29)%257)-128)*0.0078125;
    const uint64_t sentinel=UINT64_C(0x7ff80000000062a1);
    for(size_t i=0;i<(size_t)w->ld*20;i++)memcpy(c+i,&sentinel,8);
}
static matrix_fn load(const char *dir,const char *name) {
    char so[4096],file[64],symbol[64];
    snprintf(file,sizeof file,"lib%s.so",name);path(so,sizeof so,dir,file);
    void *h=dlopen(so,RTLD_NOW|RTLD_LOCAL);if(!h)fail(dlerror());
    snprintf(symbol,sizeof symbol,"matrix_%s_",name);
    void *p=dlsym(h,symbol);if(!p)fail("symbol");
    matrix_fn fn;memcpy(&fn,&p,sizeof fn);return fn;
}

/* These probes measure this CPU's nonfused arithmetic and cache traffic.
 * They set no solver result and supply no omitted numerical stage. */
extern void matrix_compute_probe(uint64_t loops,double *output);
extern void matrix_copy_probe(uint64_t passes,const void *source,void *target,
                              uint64_t bytes);
static void bounds(void) {
    double *output=buffer(16);
    const uint64_t trial=1000000;
    uint64_t begin=ns();matrix_compute_probe(trial,output);
    uint64_t elapsed=ns()-begin;
    uint64_t count=UINT64_C(2000000)*trial/(elapsed?elapsed:1);
    if(count<1000000)count=1000000;
    if(count>100000000)count=100000000;
    for(unsigned repeat=0,attempt=0;repeat<12;attempt++) {
        if(attempt>=96)fail("too many interrupted blocks");
        struct rusage before,after;getrusage(RUSAGE_SELF,&before);
        begin=ns();matrix_compute_probe(count,output);
        elapsed=ns()-begin;getrusage(RUSAGE_SELF,&after);
        if(after.ru_nvcsw!=before.ru_nvcsw||after.ru_nivcsw!=before.ru_nivcsw)continue;
        for(size_t i=0;i<16;i++)
            if(output[i]!=(double)count*0.25)fail("compute bound final value");
        if(fpcr())fail("compute bound FPCR");
        printf("{\"probe\":\"nonfused_fp64\",\"repeat\":%u,\"loops\":%" PRIu64
          ",\"operations\":%" PRIu64 ",\"ns\":%" PRIu64
          ",\"voluntary_switches\":%ld,\"involuntary_switches\":%ld,\"FPCR\":0}\n",
          repeat,count,32*count,elapsed,after.ru_nvcsw-before.ru_nvcsw,
          after.ru_nivcsw-before.ru_nivcsw);
        repeat++;
    }
    const size_t payloads[]={8192,131072};
    for(size_t wi=0;wi<2;wi++) {
        size_t bytes=payloads[wi];
        unsigned char *source=(unsigned char*)buffer(bytes/8);
        unsigned char *saved=(unsigned char*)buffer(bytes/8);
        unsigned char *target=(unsigned char*)buffer(bytes/8);
        for(size_t i=0;i<bytes;i++)source[i]=(unsigned char)((i*29+i/257)%251);
        memcpy(saved,source,bytes);memset(target,0,bytes);
        begin=ns();matrix_copy_probe(1000,source,target,bytes);
        elapsed=ns()-begin;
        count=UINT64_C(2000000000)/(elapsed?elapsed:1);
        if(count<1000)count=1000;
        if(count>10000000)count=10000000;
        for(unsigned repeat=0,attempt=0;repeat<12;attempt++) {
        if(attempt>=96)fail("too many interrupted blocks");
            matrix_copy_probe(32,source,target,bytes);
            struct rusage before,after;getrusage(RUSAGE_SELF,&before);
            begin=ns();matrix_copy_probe(count,source,target,bytes);
            elapsed=ns()-begin;getrusage(RUSAGE_SELF,&after);
            if(after.ru_nvcsw!=before.ru_nvcsw||after.ru_nivcsw!=before.ru_nivcsw)continue;
            if(memcmp(target,saved,bytes)||memcmp(source,saved,bytes))
                fail("cache bound bytes");
            if(fpcr())fail("cache bound FPCR");
            printf("{\"probe\":\"cache_copy\",\"payload_bytes\":%zu,\"repeat\":%u,"
              "\"passes\":%" PRIu64 ",\"read_write_bytes\":%" PRIu64
              ",\"ns\":%" PRIu64 ",\"voluntary_switches\":%ld,"
              "\"involuntary_switches\":%ld,\"differing_bytes\":0,\"FPCR\":0}\n",
              bytes,repeat,count,2*count*bytes,elapsed,
              after.ru_nvcsw-before.ru_nvcsw,after.ru_nivcsw-before.ru_nivcsw);
            repeat++;
        }
        free(target);free(saved);free(source);
    }
    free(output);
}


/* Keep the selected eight-point schedule's loads, stores and branches,
 * with its arithmetic removed, to calibrate the same read/write ratio. */
static void traffic(const char *dir) {
    matrix_fn fn=load(dir,"traffic");
    double *b=buffer(20*21);read_file(dir,"matrix.bin",b,20*21*8);
    double *bs=buffer(20*21);memcpy(bs,b,20*21*8);
    for(size_t wi=0;wi<sizeof work/sizeof *work;wi++) {
        const struct workload *w=work+wi;
        size_t aw=(size_t)w->ld*21,cw=(size_t)w->ld*20;
        double *a=buffer(aw),*as=buffer(aw),*c=buffer(cw),*expected=buffer(cw);
        char file[128];
        snprintf(file,sizeof file,"%s-A.bin",w->name);read_file(dir,file,a,aw*8);
        snprintf(file,sizeof file,"%s-C-initial.bin",w->name);read_file(dir,file,expected,cw*8);
        memcpy(as,a,aw*8);
        for(int row=0;row<20;row++)for(int i=0;i<w->m;i++)expected[i+w->ld*row]=0.0;
        memcpy(c,expected,cw*8);
        uint64_t begin=ns();for(unsigned i=0;i<100;i++)call(fn,w,a,b,c);
        uint64_t elapsed=ns()-begin;
        uint64_t iterations=UINT64_C(200000000)/(elapsed?elapsed:1);
        if(iterations<8)iterations=8;
        if(iterations>1000000)iterations=1000000;
        for(unsigned repeat=0,attempt=0;repeat<12;attempt++) {
        if(attempt>=96)fail("too many interrupted blocks");
            for(unsigned warm=0;warm<32;warm++)call(fn,w,a,b,c);
            struct rusage before,after;getrusage(RUSAGE_SELF,&before);
            begin=ns();for(uint64_t i=0;i<iterations;i++)call(fn,w,a,b,c);
            elapsed=ns()-begin;getrusage(RUSAGE_SELF,&after);
            exact(c,expected,cw);unchanged(a,as,aw);unchanged(b,bs,20*21);
            if(after.ru_nvcsw!=before.ru_nvcsw||after.ru_nivcsw!=before.ru_nivcsw)continue;
            if(fpcr())fail("traffic FPCR");
            printf("{\"probe\":\"matched_memory_schedule\",\"workload\":\"%s\","
             "\"repeat\":%u,\"iterations\":%" PRIu64 ",\"ns\":%" PRIu64
             ",\"voluntary_switches\":%ld,\"involuntary_switches\":%ld,"
             "\"differing_bytes\":0,\"FPCR\":0}\n",w->name,repeat,iterations,elapsed,
             after.ru_nvcsw-before.ru_nvcsw,after.ru_nivcsw-before.ru_nivcsw);
            repeat++;
        }
        free(expected);free(c);free(as);free(a);
    }
    free(bs);free(b);
}

int main(int argc,char **argv) {
    if(argc<3||argc>7)fail("usage OPERATION DIRECTORY [VARIANT ...]");
    if(argc>3) {
        variant_count=(unsigned)argc-3;
        for(unsigned v=0;v<variant_count;v++)names[v]=argv[v+3];
    }
    if(strcmp(names[0],"scalar"))fail("first control must be scalar");
    if(argc<3||argc>7||(strcmp(argv[1],"--freeze")&&strcmp(argv[1],"--measure")&&strcmp(argv[1],"--bounds")&&strcmp(argv[1],"--traffic")&&strcmp(argv[1],"--integral")))
        fail("usage --freeze|--measure|--bounds|--traffic|--integral DIRECTORY");
    if(fpcr())fail("FPCR must be zero");
    if(!strcmp(argv[1],"--bounds")){bounds();return 0;}
    if(!strcmp(argv[1],"--traffic")){traffic(argv[2]);return 0;}
    const char *dir=argv[2];int freeze=!strcmp(argv[1],"--freeze");
    if(!strcmp(argv[1],"--integral")) {
        static char integral_names[4][32];
        for(unsigned v=0;v<variant_count;v++) {
            int n=snprintf(integral_names[v],sizeof integral_names[v],"integral_%s",names[v]);
            if(n<0||(size_t)n>=sizeof integral_names[v])fail("integral variant");
            names[v]=integral_names[v];
        }
        __oml_mod_MOD_oml_init();
    }
    matrix_fn fn[4]={load(dir,names[0]),NULL,NULL,NULL};
    if(!freeze)for(unsigned v=1;v<variant_count;v++)fn[v]=load(dir,names[v]);
    double *b=buffer(20*21);read_file(dir,"matrix.bin",b,20*21*8);
    double *bs=buffer(20*21);memcpy(bs,b,20*21*8);
    for(size_t wi=0;wi<sizeof work/sizeof *work;wi++) {
        const struct workload *w=work+wi;
        size_t aw=(size_t)w->ld*21,cw=(size_t)w->ld*20;
        double *a=buffer(aw),*as=buffer(aw),*c=buffer(cw),*initial=buffer(cw),*expected=buffer(cw);
        char file[128];
        if(freeze) {
            initialize(w,a,c);memcpy(initial,c,cw*8);call(fn[0],w,a,b,c);
            snprintf(file,sizeof file,"%s-A.bin",w->name);write_file(dir,file,a,aw*8);
            snprintf(file,sizeof file,"%s-C-initial.bin",w->name);write_file(dir,file,initial,cw*8);
            snprintf(file,sizeof file,"%s-C-reference.bin",w->name);write_file(dir,file,c,cw*8);
            printf("FROZEN %s active=%d leading=%d A_bytes=%zu C_bytes=%zu\n",w->name,w->m,w->ld,aw*8,cw*8);
        } else {
            snprintf(file,sizeof file,"%s-A.bin",w->name);read_file(dir,file,a,aw*8);
            snprintf(file,sizeof file,"%s-C-initial.bin",w->name);read_file(dir,file,initial,cw*8);
            snprintf(file,sizeof file,"%s-C-reference.bin",w->name);read_file(dir,file,expected,cw*8);
            memcpy(as,a,aw*8);
            /* Calibrate a shared iteration count before measured rotations. */
            memcpy(c,initial,cw*8);
            uint64_t begin=ns();for(unsigned i=0;i<100;i++)call(fn[0],w,a,b,c);
            uint64_t elapsed=ns()-begin;
            uint64_t iterations=UINT64_C(200000000)/(elapsed?elapsed:1);
            if(iterations<8)iterations=8;
            if(iterations>1000000)iterations=1000000;
            exact(c,expected,cw);unchanged(a,as,aw);unchanged(b,bs,20*21);
            printf("{\"workload\":\"%s\",\"phase\":\"setup\",\"m\":%d,\"n\":20,\"k\":21,"
                "\"lda\":%d,\"iterations\":%" PRIu64 ",\"A_address\":\"%p\","
                "\"B_address\":\"%p\",\"C_address\":\"%p\",\"FPCR\":%" PRIu64 "}\n",
                w->name,w->m,w->ld,iterations,(void*)a,(void*)b,(void*)c,fpcr());
            for(unsigned repeat=0,attempt=0;repeat<12;attempt++) {
                if(attempt>=96)fail("too many interrupted rotations");
                struct sample {unsigned v;uint64_t elapsed;long voluntary,involuntary;} samples[4];
                int interrupted=0;
                for(unsigned position=0;position<variant_count;position++) {
                    unsigned v=(attempt+position)%variant_count;
                    memcpy(a,as,aw*8);memcpy(c,initial,cw*8);
                    for(unsigned warm=0;warm<32;warm++)call(fn[v],w,a,b,c);
                    exact(c,expected,cw);
                    struct rusage before,after;getrusage(RUSAGE_SELF,&before);
                    begin=ns();
                    for(uint64_t i=0;i<iterations;i++)call(fn[v],w,a,b,c);
                    elapsed=ns()-begin;getrusage(RUSAGE_SELF,&after);
                    exact(c,expected,cw);unchanged(a,as,aw);unchanged(b,bs,20*21);
                    if(fpcr())fail("FPCR after timing");
                    samples[position]=(struct sample){v,elapsed,after.ru_nvcsw-before.ru_nvcsw,
                        after.ru_nivcsw-before.ru_nivcsw};
                    if(samples[position].voluntary||samples[position].involuntary)interrupted=1;
                }
                for(unsigned position=0;position<variant_count;position++) {
                    struct sample *a_sample=samples+position;
                    printf("{\"workload\":\"%s\",\"variant\":\"%s\",\"repeat\":%u,"
                        "\"attempt\":%u,\"accepted\":%s,\"position\":%u,"
                        "\"iterations\":%" PRIu64 ",\"ns\":%" PRIu64
                        ",\"voluntary_switches\":%ld,\"involuntary_switches\":%ld,"
                        "\"differing_bytes\":0,\"FPCR\":0}\n",w->name,names[a_sample->v],
                        repeat,attempt,interrupted?"false":"true",position,iterations,
                        a_sample->elapsed,a_sample->voluntary,a_sample->involuntary);
                }
                if(!interrupted)repeat++;
            }
        }
        free(expected);free(initial);free(c);free(as);free(a);
    }
    free(bs);free(b);return 0;
}

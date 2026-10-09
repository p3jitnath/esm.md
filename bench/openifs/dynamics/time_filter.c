/* Verify both complete OpenIFS time-filter stages.
 * A time filter combines neighbouring time levels to reduce alternating noise.
 * Field units stay unchanged, including m/s for wind and K for temperature.
 * Independent long-double identities check the filter, while raw bytes check
 * every output, inactive cell, copy, signed zero and array guard. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#define TF1_ARGS const void *geometry,const void *gmv,const void *model, \
 const void *dyn,const void *dyna,const int32_t *filter,const int32_t *ks, \
 const int32_t *ke,const int32_t *last,double *air,double *surface,double *tracer
#define TF2_ARGS const void *geometry,const void *gmv,const void *model, \
 const void *dyn,const void *dyna,const int32_t *ks,const int32_t *ke, \
 const int32_t *first,double *air,double *surface,double *tracer
typedef void (*first_kernel)(TF1_ARGS);
typedef void (*second_kernel)(TF2_ARGS);
typedef struct {void *map;size_t mapped,usable,count;double *data;int tail;} buffer;
typedef struct {int source,action,moist;} selection;
static uint64_t calls,bytes,science_values,witnesses;
static first_kernel first_reference,first_assembly;
static second_kernel second_reference,second_assembly;
static int routine,freeze_only;
static FILE *inputs,*ao,*ro;
static const int32_t offsets[2][15]={
 {12,16,32,20,24,28,48,60,52,64,56,68,88,92,72},
 {8,12,80,16,20,24,96,108,100,112,104,116,208,212,120}};
static const int32_t surface_offsets[2][3]={{96,100,104},{216,220,224}};
static void fail(const char *message) {
    fprintf(stderr,"GPTF%d check failed %s\n",routine,message);exit(2);
}
static uint64_t bits(double value) {uint64_t n;memcpy(&n,&value,8);return n;}
static uint64_t fpcr(void) {uint64_t n;__asm__ volatile("mrs %0,fpcr":"=r"(n));return n;}
static void put_i(void *p,size_t off,int32_t n) {memcpy((char *)p+off,&n,4);}
static void put_d(void *p,size_t off,double n) {memcpy((char *)p+off,&n,8);}
static void write_bytes(FILE *f,const void *p,size_t n) {
    if(n && fwrite(p,1,n,f)!=n) fail("canonical stream write");
}
static buffer make_buffer(size_t count,int tail) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE),n=count+2-(size_t)tail;
    size_t usable=(n*8+page-1)/page*page;
    void *p=mmap(NULL,usable+2*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(p==MAP_FAILED || mprotect((char *)p+page,usable,PROT_READ|PROT_WRITE)) fail("guard pages");
    double *data=(double *)((char *)p+page+usable-n*8)+1;
    for(size_t i=0;i<n;++i) data[(ptrdiff_t)i-1]=-777.75;
    return (buffer){p,usable+2*page,usable,count,data,tail};
}
static void readonly(buffer *b) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    if(mprotect((char *)b->map+page,b->usable,PROT_READ)) fail("read-only configuration");
}
static void release(buffer *b) {if(munmap(b->map,b->mapped)) fail("release pages");}
static double value(int pattern,int field,size_t cell,int previous,int code) {
    if(pattern==1) return field&1?-0.0:0.0;
    if(pattern==2) return (field&1?-1.0:1.0)*(double)(1+cell%23)*DBL_TRUE_MIN;
    if(pattern==3) {
        if(code==1) return previous?-3.0:1.0;
        return previous?-0.30000000000000004:3.0;
    }
    if(pattern==4) {
        uint64_t n=field&1?UINT64_C(0x7ff8000000001234):UINT64_C(0x8000000000000000);
        double d;memcpy(&d,&n,8);return d;
    }
    return (field&1?-1.0:1.0)*(17.0+(double)field/8.0+(double)(cell%31)/64.0);
}
static void mark(selection *s,int count,const int *current,const int *previous,
                 const int *groups,int ng,int action,int moist) {
    for(int j=0;j<ng;++j) {
        int g=groups[j],dest=previous[g]-1;
        if(dest<0 || dest>=count) fail("fixture destination");
        s[dest]=(selection){current[g]-1,action,moist};
    }
}
static void check_case(int number,int flags,int therm,int nv,int np,int nf,
                       int ks,int ke,int pattern,int variant,int tail,int ncomp) {
    enum {NA=38,NS=8,NG=8};
    int32_t filter=flags&1,two=(flags>>1)&1,grad=(flags>>2)&1;
    int32_t full=(flags>>3)&1,nh=(flags>>4)&1,last=(flags>>5)&1;
    int current[15],previous[15],sc[3]={1,2,3},sp[3]={5,6,7};
    selection selected[3][NA];memset(selected,0,sizeof selected);
    const int wind[2]={0,1},div[1]={2},temp[3]={3,4,5};
    const int nonhydro[6]={6,7,8,9,10,11},gradient[2]={12,13},extra[1]={14};
    const int surf[3]={0,1,2};
    for(int j=0;j<15;++j) {
        current[j]=variant?1+(j*5+7)%17:j+1;
        previous[j]=variant?19+(j*7+3)%17:j+19;
    }
    if(variant) {sc[0]=3;sc[1]=1;sc[2]=2;sp[0]=7;sp[1]=5;sp[2]=6;}
    int action=0,bulk=0,tracers=0;
    if(routine==1) {
        if(filter && !two && last) {bulk=1;tracers=3;}
        else if(filter && !two) {
            action=2;tracers=2;
            mark(selected[0],NA,current,previous,wind,2,action,0);
            mark(selected[0],NA,current,previous,div,1,action,0);
            if(therm>=1) mark(selected[0],NA,current,previous,temp,3,action,0);
            if(nh) mark(selected[0],NA,current,previous,nonhydro,6,action,0);
            mark(selected[1],NS,sc,sp,surf,3,action,0);
        } else if(filter && two) {
            mark(selected[0],NA,current,previous,wind,2,1,0);
            if(grad) mark(selected[0],NA,current,previous,gradient,2,1,0);
            if(full) {
                mark(selected[0],NA,current,previous,temp,3,1,0);tracers=1;
                if(nh) mark(selected[0],NA,current,previous,nonhydro,6,1,0);
                mark(selected[1],NS,sc,sp,surf,3,1,0);
            }
        } else if(grad) mark(selected[0],NA,current,previous,gradient,2,1,0);
    } else if(!two || last) {
        action=last?1:4;
        mark(selected[0],NA,current,previous,wind,2,action,0);
        if(!two) {
            tracers=action;
            mark(selected[0],NA,current,previous,div,1,action,0);
            if(therm>=1) mark(selected[0],NA,current,previous,temp,3,action,0);
            if(nh) {
                mark(selected[0],NA,current,previous,nonhydro,6,action,0);
                if(last && nv==4) mark(selected[0],NA,current,previous,extra,1,action,0);
            }
            mark(selected[1],NS,sc,sp,surf,3,action,0);
        }
    }
    int32_t components[4][3]={{1,1,5},{0,-19,-21},{1,3,7},{1,4,8}};
    if(variant) {components[0][1]=4;components[0][2]=8;components[2][1]=2;components[2][2]=6;
                 components[3][1]=1;components[3][2]=5;}
    for(int j=0;j<ncomp;++j) if(components[j][0] && tracers)
        selected[2][components[j][2]-1]=(selection){components[j][1]-1,tracers,1};
    if(bulk) {
        for(int f=18;f<NA;++f) selected[0][f]=(selection){0,3,0};
        for(int f=4;f<NS;++f) selected[1][f]=(selection){0,3,0};
    }
    buffer object[5]={make_buffer(17096/8,0),make_buffer(1560/8,0),
        make_buffer(1556112/8,0),make_buffer(4720/8,0),make_buffer(456/8,0)};
    const size_t sizes[5]={17096,1560,1556112,4720,456};
    for(int j=0;j<5;++j) memset(object[j].data,0,sizes[j]);
    put_i(object[0].data,5144,np);put_i(object[0].data,5224,nf);
    put_i(object[1].data,992,NA);put_i(object[1].data,996,NS);
    put_i(object[1].data,1000,18);put_i(object[1].data,1004,4);
    for(int j=0;j<15;++j) {
        put_i(object[1].data,1000+(size_t)offsets[0][j],variant && !selected[0][previous[j]-1].action?-99:current[j]);
        put_i(object[1].data,1108+(size_t)offsets[1][j],
            variant && !selected[0][previous[j]-1].action?-123:previous[j]);
    }
    for(int j=0;j<3;++j) {
        put_i(object[1].data,1000+(size_t)surface_offsets[0][j],sc[j]);
        put_i(object[1].data,1108+(size_t)surface_offsets[1][j],sp[j]);
    }
    put_i(object[2].data,8,therm);put_i(object[2].data,184,ncomp);put_i(object[2].data,232,NG);
    for(int j=0;j<ncomp;++j) for(int k=0;k<3;++k)
        put_i(object[2].data,4032+(size_t)j*368+(size_t[]){88,168,180}[k],components[j][k]);
    double eps[4]={0.125,0.0625,0.25,0.125};
    if(pattern==1 || pattern==2) {eps[0]=0.0;eps[1]=0.5;eps[2]=-0.0;eps[3]=0.5;}
    if(pattern==3) {eps[0]=0.1;eps[1]=routine==1?0.6:0.1;eps[2]=0.1;eps[3]=eps[1];}
    for(int j=0;j<4;++j) put_d(object[3].data,(size_t)j*8,eps[j]);
    put_i(object[4].data,8,nh);put_i(object[4].data,20,two);
    put_i(object[4].data,32,nv);put_i(object[4].data,200,grad);put_i(object[4].data,336,full);
    size_t cells[3]={(size_t)np*(size_t)nf,(size_t)np,(size_t)np*(size_t)nf};
    int fields[3]={NA,NS,NG};buffer a[3],r[3];double *before[3];
    for(int b=0;b<3;++b) {
        size_t n=cells[b]*(size_t)fields[b];
        a[b]=make_buffer(n,tail);r[b]=make_buffer(n,tail);
        before[b]=malloc((n+2-(size_t)tail)*8);if(!before[b]) fail("initial state");
        for(int f=0;f<fields[b];++f) for(size_t c=0;c<cells[b];++c) {
            double v=value(pattern,f,c,b==1?f>=4:b==0?f>=18:f>=4,routine);
            a[b].data[(size_t)f*cells[b]+c]=r[b].data[(size_t)f*cells[b]+c]=v;
        }
        memcpy(before[b],a[b].data-1,(n+2-(size_t)tail)*8);
    }
    int32_t header[32]={routine,number,np,nf,ks,ke,NA,NS,NG,ncomp,therm,
        filter,two,grad,full,nh,last,nv,pattern,variant,tail};
    write_bytes(inputs,header,sizeof header);
    write_bytes(inputs,(char *)object[1].data+1000,108+252);
    write_bytes(inputs,eps,sizeof eps);write_bytes(inputs,components,(size_t)ncomp*12);
    for(int b=0;b<3;++b) write_bytes(inputs,a[b].data,a[b].count*8);
    if(pattern==3 && (action==2 || action==4)) {
        double old=value(pattern,0,0,1,routine),cur=value(pattern,0,0,0,routine);
        double weight=routine==1?1.0-(eps[0]+eps[1]):eps[1];
        double ordinary=routine==1?eps[0]*old+weight*cur:old+weight*cur;
        double fused=routine==1?fma(eps[0],old,weight*cur):fma(weight,cur,old);
        if(bits(ordinary)==bits(fused)) fail("separate-rounding witness");
        ++witnesses;
    }
    ++calls;
    if(!freeze_only) {
        for(int j=0;j<5;++j) readonly(&object[j]);
        uint64_t control=fpcr();if(control!=0) fail("FPCR must be zero");
        if(routine==1) {
            first_reference(object[0].data,object[1].data,object[2].data,object[3].data,
                object[4].data,&filter,&ks,&ke,&last,r[0].data,r[1].data,r[2].data);
            if(fpcr()!=control) fail("reference changed FPCR");
            first_assembly(object[0].data,object[1].data,object[2].data,object[3].data,
                object[4].data,&filter,&ks,&ke,&last,a[0].data,a[1].data,a[2].data);
        } else {
            second_reference(object[0].data,object[1].data,object[2].data,object[3].data,
                object[4].data,&ks,&ke,&last,r[0].data,r[1].data,r[2].data);
            if(fpcr()!=control) fail("reference changed FPCR");
            second_assembly(object[0].data,object[1].data,object[2].data,object[3].data,
                object[4].data,&ks,&ke,&last,a[0].data,a[1].data,a[2].data);
        }
        if(fpcr()!=control) fail("assembly changed FPCR");
        write_bytes(ao,header,sizeof header);write_bytes(ro,header,sizeof header);bytes+=sizeof header;
        for(int b=0;b<3;++b) {
            size_t n=a[b].count+2-(size_t)tail;
            for(size_t j=0;j<n;++j) if(bits(a[b].data[(ptrdiff_t)j-1])!=bits(r[b].data[(ptrdiff_t)j-1])) {
                fprintf(stderr,"Mismatch stage=GPTF%d case=%d buffer=%d cell=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                    routine,number,b,j,bits(a[b].data[(ptrdiff_t)j-1]),bits(r[b].data[(ptrdiff_t)j-1]));exit(1);
            }
            for(int f=0;f<fields[b];++f) for(size_t c=0;c<cells[b];++c) {
                size_t j=(size_t)f*cells[b]+c;
                selection s=selected[b][f];
                int column=(int)(c%(size_t)np)+1;
                int active=(column>=ks && column<=ke) || (bulk && b<2 && s.action==3);
                double old=before[b][j+1],got=a[b].data[j];
                if(!active || !s.action) {if(bits(old)!=bits(got)) fail("inactive value");}
                else if(s.action==3) {if(bits(got)!=0) fail("positive zero");}
                else {
                    double cur=before[b][(size_t)s.source*cells[b]+c+1];
                    if(s.action==1) {if(bits(cur)!=bits(got)) fail("copy changed bits");}
                    else {
                        int e=s.moist?2:0;
                        long double expected=s.action==2?(long double)eps[e]*old+
                            (1.0L-((long double)eps[e]+eps[e+1]))*cur:
                            (long double)old+(long double)eps[e+1]*cur;
                        long double scale=fabsl(old)+fabsl(cur);
                        if(!isfinite(got) || fabsl((long double)got-expected)>8.0L*DBL_EPSILON*scale+4.0L*DBL_TRUE_MIN)
                            fail("independent weighted time levels");
                        ++science_values;
                    }
                }
            }
            if(bits(a[b].data[-1])!=bits(before[b][0])) fail("leading guard");
            if(!tail && bits(a[b].data[a[b].count])!=bits(before[b][a[b].count+1])) fail("trailing guard");
            write_bytes(ao,a[b].data,a[b].count*8);write_bytes(ro,r[b].data,r[b].count*8);
            bytes+=(uint64_t)a[b].count*8;
        }
    }
    for(int b=0;b<3;++b) {free(before[b]);release(&a[b]);release(&r[b]);}
    for(int j=0;j<5;++j) release(&object[j]);
}
/* Check the complete three-time-level OpenIFS filter on a small grid.
 * Each field keeps its own units: wind m/s, temperature K, surface and tracer
 * values in their caller units. Filter coefficients have no units.
 * Equal inputs stay constant. A linear history shifts by (e2-e1)*step.
 * Alternating noise has gain 1-2*(e1+e2). These identities use all three levels.
 * Both stages call the accepted assembly and unchanged strict Fortran bodies. */

#define PAIR_TF1_ARGS const void *geometry,const void *gmv,const void *model, \
 const void *dyn,const void *dyna,const int32_t *filter,const int32_t *ks, \
 const int32_t *ke,const int32_t *last,double *air,double *surface,double *tracer
#define PAIR_TF2_ARGS const void *geometry,const void *gmv,const void *model, \
 const void *dyn,const void *dyna,const int32_t *ks,const int32_t *ke, \
 const int32_t *first,double *air,double *surface,double *tracer
void gptf1_(PAIR_TF1_ARGS);
void gptf1_assembly_(PAIR_TF1_ARGS);
void gptf2_(PAIR_TF2_ARGS);
void gptf2_assembly_(PAIR_TF2_ARGS);

enum {PAIR_NP=3,PAIR_NF=2,PAIR_NAIR=38,PAIR_NSURFACE=8,PAIR_NTRACER=8};
typedef struct {int array,current,previous;double base;} pair_field;
static const pair_field pair_fields[]={
    {0,1,19,8.0},{0,2,20,4.0},{0,3,21,0.125},
    {0,4,22,256.0},{0,5,23,0.25},{0,6,24,0.125},
    {1,1,5,8.0},{1,2,6,0.125},{1,3,7,0.25},{2,1,5,0.25}
};
static const int32_t pair_offsets[2][15]={
    {12,16,32,20,24,28,48,60,52,64,56,68,88,92,72},
    {8,12,80,16,20,24,96,108,100,112,104,116,208,212,120}
};
static const int32_t pair_surface_offsets[2][3]={{96,100,104},{216,220,224}};
static const size_t pair_counts[3]={
    PAIR_NP*PAIR_NF*PAIR_NAIR,PAIR_NP*PAIR_NSURFACE,PAIR_NP*PAIR_NF*PAIR_NTRACER
};
static void pair_fail(const char *message) {
    fprintf(stderr,"Paired time-filter check failed: %s\n",message);exit(2);
}
static uint64_t pair_bits(double value) {
    uint64_t n;memcpy(&n,&value,sizeof n);return n;
}
static uint64_t pair_fpcr(void) {
    uint64_t n;__asm__ volatile("mrs %0,fpcr":"=r"(n));return n;
}
static void pair_put_i(void *p,size_t offset,int32_t value) {
    memcpy((char *)p+offset,&value,sizeof value);
}
static void pair_put_d(void *p,size_t offset,double value) {
    memcpy((char *)p+offset,&value,sizeof value);
}
static size_t pair_plane(int array) {
    return array==1?PAIR_NP:PAIR_NP*PAIR_NF;
}
static double pair_history(double base,size_t cell,int history,int time) {
    double centre=base+base*(double)cell/128.0,step=base/16.0;
    if(history==0) return centre;
    if(history==1) return centre+(double)time*step;
    return centre+(time==0?step:-step);
}
static long double pair_moment(double base,size_t cell,int history,double e1,double e2) {
    long double centre=(long double)base+(long double)base*(long double)cell/128.0L;
    long double step=(long double)base/16.0L;
    if(history==0) return centre;
    if(history==1) return centre+((long double)e2-e1)*step;
    return centre+(1.0L-2.0L*((long double)e1+e2))*step;
}
static void pair_expect(double actual,long double expected,int number,int stage,
                        int array,int field,size_t cell) {
    double rounded=(double)expected;
    if(pair_bits(actual)!=pair_bits(rounded)) {
        fprintf(stderr,"Paired moment trajectory=%d stage=%d array=%d field=%d"
            " cell=%zu actual=%016" PRIx64 " expected=%016" PRIx64 "\n",
            number,stage,array,field,cell,pair_bits(actual),pair_bits(rounded));
        pair_fail("independent complete-history identity");
    }
}
static void pair_compare(double *a[3],double *r[3],int number,int stage) {
    for(int array=0;array<3;++array)
        for(size_t k=0;k<pair_counts[array];++k)
            if(pair_bits(a[array][k])!=pair_bits(r[array][k])) {
                size_t plane=pair_plane(array);
                fprintf(stderr,"Paired bytes trajectory=%d stage=%d array=%d"
                    " field=%zu cell=%zu assembly=%016" PRIx64 " reference=%016" PRIx64 "\n",
                    number,stage,array,k/plane+1,k%plane,
                    pair_bits(a[array][k]),pair_bits(r[array][k]));
                pair_fail("strict source byte mismatch");
            }
}
static void pair_write(FILE *f,const void *data,size_t bytes) {
    if(f && bytes && fwrite(data,1,bytes,f)!=bytes) pair_fail("checkpoint write");
}
static void pair_checkpoint(FILE *f,double *state[3],int number,int stage,
                            int coefficient_set,int history) {
    int32_t header[8]={number,stage,coefficient_set,history,PAIR_NP,PAIR_NF,2,3};
    pair_write(f,header,sizeof header);
    for(int array=0;array<3;++array)
        pair_write(f,state[array],pair_counts[array]*sizeof(double));
}

/* Run six trajectories: constant, linear and alternating histories for each
 * of an asymmetric and a symmetric coefficient set. The dyadic inputs make
 * the independent moment exactly representable in FP64. Only future current
 * fields are replaced between solver stages; the solver supplies every term.
 * Output streams, when requested, contain each 32-byte little-endian header
 * followed by all air, surface and tracer doubles in Fortran storage order.
 * No inactive field is omitted from the byte comparison. */
int time_filter_paired_checks(const char *assembly_path,const char *reference_path) {
    const size_t object_sizes[5]={17096,1560,1556112,4720,456};
    void *object[5];
    for(int j=0;j<5;++j) {
        object[j]=calloc(1,object_sizes[j]);
        if(!object[j]) pair_fail("configuration allocation");
    }
    pair_put_i(object[0],5144,PAIR_NP);pair_put_i(object[0],5224,PAIR_NF);
    pair_put_i(object[1],992,PAIR_NAIR);pair_put_i(object[1],996,PAIR_NSURFACE);
    pair_put_i(object[1],1000,18);pair_put_i(object[1],1004,4);
    for(int j=0;j<15;++j) {
        pair_put_i(object[1],1000+(size_t)pair_offsets[0][j],j+1);
        pair_put_i(object[1],1108+(size_t)pair_offsets[1][j],j+19);
    }
    for(int j=0;j<3;++j) {
        pair_put_i(object[1],1000+(size_t)pair_surface_offsets[0][j],j+1);
        pair_put_i(object[1],1108+(size_t)pair_surface_offsets[1][j],j+5);
    }
    pair_put_i(object[2],8,1);pair_put_i(object[2],184,1);
    pair_put_i(object[2],232,PAIR_NTRACER);
    pair_put_i(object[2],4032+88,1);pair_put_i(object[2],4032+168,1);
    pair_put_i(object[2],4032+180,5);
    pair_put_i(object[4],32,3);
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    if(hook) *hook=0;
    uint64_t control=pair_fpcr();
    if(control&UINT64_C(0x03c80000)) pair_fail("floating-point control");
    FILE *af=assembly_path?fopen(assembly_path,"wb"):NULL;
    FILE *rf=reference_path?fopen(reference_path,"wb"):NULL;
    if((assembly_path && !af) || (reference_path && !rf)) pair_fail("checkpoint open");
    const double coefficients[2][4]={{0.125,0.0625,0.25,0.125},
                                   {0.125,0.125,0.25,0.25}};
    int32_t filter=1,ks=2,ke=3,last=0,first=0;
    int number=0;
    uint64_t moments=0,witnesses=0;
    for(int set=0;set<2;++set) for(int history=0;history<3;++history) {
        ++number;
        for(int j=0;j<4;++j) pair_put_d(object[3],(size_t)j*8,coefficients[set][j]);
        double *a[3],*r[3];
        for(int array=0;array<3;++array) {
            a[array]=malloc(pair_counts[array]*sizeof(double));
            r[array]=malloc(pair_counts[array]*sizeof(double));
            if(!a[array] || !r[array]) pair_fail("state allocation");
            for(size_t k=0;k<pair_counts[array];++k) a[array][k]=-777.75;
        }
        for(size_t f=0;f<sizeof pair_fields/sizeof pair_fields[0];++f) {
            const pair_field *p=&pair_fields[f];
            size_t plane=pair_plane(p->array);
            for(size_t cell=0;cell<plane;++cell) {
                a[p->array][(size_t)(p->current-1)*plane+cell]=
                    pair_history(p->base,cell,history,0);
                a[p->array][(size_t)(p->previous-1)*plane+cell]=
                    pair_history(p->base,cell,history,-1);
            }
        }
        for(int array=0;array<3;++array)
            memcpy(r[array],a[array],pair_counts[array]*sizeof(double));
        gptf1_(object[0],object[1],object[2],object[3],object[4],
            &filter,&ks,&ke,&last,r[0],r[1],r[2]);
        gptf1_assembly_(object[0],object[1],object[2],object[3],object[4],
            &filter,&ks,&ke,&last,a[0],a[1],a[2]);
        if(pair_fpcr()!=control) pair_fail("stage 1 changed FPCR");
        pair_compare(a,r,number,1);
        pair_checkpoint(af,a,number,1,set,history);
        pair_checkpoint(rf,r,number,1,set,history);
        for(size_t f=0;f<sizeof pair_fields/sizeof pair_fields[0];++f) {
            const pair_field *p=&pair_fields[f];
            size_t plane=pair_plane(p->array);
            int moist=p->array==2;
            double e1=coefficients[set][moist?2:0],e2=coefficients[set][moist?3:1];
            for(size_t cell=0;cell<plane;++cell) {
                double future=pair_history(p->base,cell,history,1);
                if(cell%PAIR_NP>=1) {
                    long double full=pair_moment(p->base,cell,history,e1,e2);
                    double partial=a[p->array][(size_t)(p->previous-1)*plane+cell];
                    pair_expect(partial,full-(long double)e2*future,
                                number,1,p->array,p->previous,cell);
                    if(pair_bits(partial)==pair_bits((double)full))
                        pair_fail("missing final-term witness lost");
                    ++witnesses;
                }
                size_t current=(size_t)(p->current-1)*plane+cell;
                a[p->array][current]=future;r[p->array][current]=future;
            }
        }
        gptf2_(object[0],object[1],object[2],object[3],object[4],
            &ks,&ke,&first,r[0],r[1],r[2]);
        gptf2_assembly_(object[0],object[1],object[2],object[3],object[4],
            &ks,&ke,&first,a[0],a[1],a[2]);
        if(pair_fpcr()!=control) pair_fail("stage 2 changed FPCR");
        pair_compare(a,r,number,2);
        pair_checkpoint(af,a,number,2,set,history);
        pair_checkpoint(rf,r,number,2,set,history);
        for(size_t f=0;f<sizeof pair_fields/sizeof pair_fields[0];++f) {
            const pair_field *p=&pair_fields[f];
            size_t plane=pair_plane(p->array);
            int moist=p->array==2;
            double e1=coefficients[set][moist?2:0],e2=coefficients[set][moist?3:1];
            for(size_t cell=0;cell<plane;++cell) if(cell%PAIR_NP>=1) {
                pair_expect(a[p->array][(size_t)(p->previous-1)*plane+cell],
                    pair_moment(p->base,cell,history,e1,e2),
                    number,2,p->array,p->previous,cell);
                ++moments;
            }
        }
        for(int array=0;array<3;++array) {free(a[array]);free(r[array]);}
    }
    if((af && fclose(af)) || (rf && fclose(rf))) pair_fail("checkpoint close");
    for(int j=0;j<5;++j) free(object[j]);
    printf("PAIRED FILTER PASS trajectories=%d stage_checks=%d bytes=29184"
        " differing_bytes=0 moments=%" PRIu64 " missing_final_witnesses=%" PRIu64
        " FPCR=%016" PRIx64 "\n",number,number*2,moments,witnesses,control);
    return 0;
}

int main(int argc,char **argv) {
    if(argc==3 && !strcmp(argv[1],"--paired")) {
        char assembly_path[4096],reference_path[4096];
        snprintf(assembly_path,sizeof assembly_path,"%s/paired-assembly.bin",argv[2]);
        snprintf(reference_path,sizeof reference_path,"%s/paired-fortran.bin",argv[2]);
        return time_filter_paired_checks(assembly_path,reference_path);
    }
    if(argc<3) {fprintf(stderr,"Usage time_filter ROUTINE OUTPUT_DIRECTORY [--freeze]\n");return 2;}
    routine=atoi(argv[1]);if(routine!=1 && routine!=2) fail("routine selection");
    freeze_only=argc>3 && !strcmp(argv[3],"--freeze");
    char path[4096];snprintf(path,sizeof path,"%s/gptf%d-inputs.bin",argv[2],routine);
    inputs=fopen(path,"wb");if(!inputs) fail("input stream");
    if(!freeze_only) {
        void *s=dlsym(RTLD_DEFAULT,routine==1?"gptf1_":"gptf2_");
        if(!s) fail("strict reference symbol");
        if(routine==1) memcpy(&first_reference,&s,sizeof s);else memcpy(&second_reference,&s,sizeof s);
        s=dlsym(RTLD_DEFAULT,routine==1?"gptf1_assembly_":"gptf2_assembly_");
        if(!s) fail("direct assembly symbol");
        if(routine==1) memcpy(&first_assembly,&s,sizeof s);else memcpy(&second_assembly,&s,sizeof s);
        int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
        if(!hook) fail("profiling control");
        *hook=0;
        snprintf(path,sizeof path,"%s/gptf%d-assembly.bin",argv[2],routine);ao=fopen(path,"wb");
        snprintf(path,sizeof path,"%s/gptf%d-fortran.bin",argv[2],routine);ro=fopen(path,"wb");
        if(!ao || !ro) fail("output streams");
    }
    int id=0;
    if(routine==1) for(int flags=0;flags<64;++flags) for(int therm=0;therm<2;++therm) {
        ++id;
        check_case(id,flags,therm,3,5,3,2,4,0,id&1,id&1,4);
    }
    if(routine==2) for(int two=0;two<2;++two) for(int nh=0;nh<2;++nh)
        for(int first=0;first<2;++first) for(int therm=0;therm<2;++therm) for(int nv=3;nv<=4;++nv) {
            ++id;
            check_case(id,2*two+16*nh+32*first,therm,nv,5,3,2,4,0,id&1,id&1,4);
        }
    const int flags1[8]={0,4,3,31,1,17,33,49};
    const int flags2[8]={2,34,0,16,32,48,48,0};
    for(int branch=0;branch<8;++branch) for(int shape=0;shape<6;++shape) {
        int np=shape==0?1:shape==1?3:shape==2?7:13;
        int nf=shape==0?0:shape==1?1:4;
        int ks=shape==3?np:shape==4?3:1,ke=shape==3?np-1:shape==4?9:np;
        ++id;
        check_case(id,routine==1?flags1[branch]:flags2[branch],branch&1,branch==6?4:3,
            np,nf,ks,ke,0,id&1,1,shape==5?0:4);
    }
    for(int pattern=1;pattern<=3;++pattern) for(int branch=0;branch<8;++branch) {
        ++id;
        check_case(id,routine==1?flags1[branch]:flags2[branch],1,4,7,3,1,7,pattern,id&1,1,4);
    }
    ++id;check_case(id,routine==1?31:34,1,4,7,3,2,6,4,1,1,4);
    ++id;check_case(id,routine==1?0:2,0,3,3,1,1,3,4,0,1,0);
    if(fclose(inputs) || (!freeze_only && (fclose(ao) || fclose(ro)))) fail("close streams");
    printf("{\"routine\":\"GPTF%d\",\"frozen_only\":%s,\"calls\":%" PRIu64 ",\"bytes\":%" PRIu64
           ",\"science_values\":%" PRIu64 ",\"rounding_witnesses\":%" PRIu64 ",\"differing_bytes\":0,\"FPCR\":%" PRIu64 "}\n",
        routine,freeze_only?"true":"false",calls,bytes,science_values,witnesses,fpcr());
    return 0;
}

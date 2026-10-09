/* Verify complete virtual-temperature conversion.
 * Temperature uses K, gas constants use J/(kg K), and fractions use kg/kg.
 * The physical mixture equation is evaluated in long double independently
 * of the strict source reduction. Full returned bytes protect its rounding. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#define CTV_ARGS const void *geometry,const void *gfl_config,const int32_t *ks, \
 const int32_t *ke,double *temperature,const double *gfl
void ctvtot_(CTV_ARGS);
#ifndef CTVTOT_FREEZE_ONLY
void ctvtot_assembly_(CTV_ARGS);
#endif
typedef struct {void *map;size_t mapped,usable,count;double *data;int tail;} buffer;
static unsigned char **global_config;
static double *constants[6];
static uint64_t calls,bytes,science_values,rounding_witnesses,active_calls;
static void fail(const char *message) {
    fprintf(stderr,"CTVTOT check failed: %s\n",message);exit(2);
}
static uint64_t bits(double x) {uint64_t u;memcpy(&u,&x,8);return u;}
static uint64_t fpcr(void) {uint64_t u;__asm__ volatile("mrs %0,fpcr":"=r"(u));return u;}
static void put_i(void *p,size_t off,int32_t x) {memcpy((char *)p+off,&x,4);}
static void put_d(void *p,size_t off,double x) {memcpy((char *)p+off,&x,8);}
static int32_t get_i(const void *p,size_t off) {int32_t x;memcpy(&x,(const char *)p+off,4);return x;}
static double get_d(const void *p,size_t off) {double x;memcpy(&x,(const char *)p+off,8);return x;}
static void write_bytes(FILE *f,const void *p,size_t n) {
    if(n && fwrite(p,1,n,f)!=n) fail("canonical write");
}
static buffer make_buffer(size_t count,int tail) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE),n=count+2-(size_t)tail;
    size_t usable=(n*8+page-1)/page*page;
    void *p=mmap(NULL,usable+2*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(p==MAP_FAILED || mprotect((char *)p+page,usable,PROT_READ|PROT_WRITE))
        fail("guard allocation");
    double *data=(double *)((char *)p+page+usable-n*8)+1;
    for(size_t i=0;i<n;++i) data[(ptrdiff_t)i-1]=-777.75;
    return (buffer){p,usable+2*page,usable,count,data,tail};
}
static void readonly(buffer *b) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    if(mprotect((char *)b->map+page,b->usable,PROT_READ)) fail("read-only input");
}
static size_t raw_size(const buffer *b) {return (b->count+2-(size_t)b->tail)*8;}
static void release(buffer *b) {if(munmap(b->map,b->mapped)) fail("guard release");}
static long double mixture(const unsigned char *cfg,const double *gfl,
                           size_t n,size_t cell,long double *condition,int *selected) {
    int32_t nf=get_i(cfg,0);long double mass=0.0L,gas=0.0L,scale=0.0L;
    double rd=*constants[0];*selected=0;
    for(int32_t f=0;f<nf;++f) {
        const unsigned char *p=cfg+3848+(size_t)f*368;
        if(!get_i(p,68)) continue;
        int32_t field=get_i(p,168);
        double q=gfl[(size_t)(field-1)*n+cell],r=get_d(p,72);
        if(!isfinite(q) || q<0.0 || !isfinite(r) || r<0.0) fail("invalid mass fixture");
        mass+=(long double)q;gas+=(long double)q*r;
        scale+=fabsl(((long double)r-rd)*q);++*selected;
    }
    if(mass>1.0L) fail("selected mass sum");
    long double result=(1.0L-mass)*rd+gas;
    if(!(result>0.0L)) fail("positive mixture constant");
    *condition=1.0L+scale/result;
    return result;
}
static void physics(double actual,long double expected,long double condition,int selected) {
    long double tolerance=(64.0L+8.0L*selected)*DBL_EPSILON*
        fmaxl(1.0L,fabsl(expected))*condition+16.0L*DBL_TRUE_MIN;
    if(!isfinite(actual) || fabsl((long double)actual-expected)>tolerance)
        fail("independent temperature identity");
    ++science_values;
}
static double initial_temperature(int pattern,size_t cell,long double rm,double rd) {
    if(pattern==1) return cell&1?-0.0:0.0;
    if(pattern==2) return (cell&1?-1.0:1.0)*(double)(1+cell%23)*DBL_TRUE_MIN;
    if(pattern==3) return (cell&1?-1.0:1.0)*DBL_MAX/2048.0;
    if(pattern==4) {
        long double known=252.0L+(long double)cell/64.0L;
        return (double)(known*rm/(long double)rd);
    }
    if(pattern==5) return nextafter(256.0+(double)(cell%13)/32.0,INFINITY);
    return 270.0+(double)(cell%17)/4.0;
}
static void configure(unsigned char *cfg,int variant,int capacity,int numflds) {
    memset(cfg,0,1359136);
    put_i(cfg,0,numflds);put_i(cfg,48,capacity);
    for(int f=0;f<numflds;++f) {
        unsigned char *p=cfg+3848+(size_t)f*368;
        int flag=0,field=f%capacity+1;
        if(variant>=2 && variant<=7) flag=f==variant-2;
        if(variant==8 || variant==10 || variant==11) flag=1;
        if(variant==9) {flag=(f%2)==0;field=capacity-f;}
        if(variant==10) field=f%2?3:1;
        if(variant==11) field=(f*5+3)%capacity+1;
        if(variant==12) flag=f==0 || f==1081 || f==2162;
        double gas=f==0?*constants[1]:0.0;
        double heat=f==0?*constants[3]:(f==2||f==3?*constants[4]:*constants[5]);
        if(variant==11) gas=f%3==0?*constants[1]:(f%3==1?0.0:192.0+f);
        if(variant==12) {gas=f==0?*constants[1]:(f==2162?100.0:0.0);heat=1000.0+f/8.0;}
        put_i(p,68,flag);put_i(p,168,field);put_d(p,72,gas);put_d(p,80,heat);
    }
}
static void check_case(int number,int variant,int np,int ks,int ke,int nl,
                       int pattern,int tail,FILE *input,FILE *af,FILE *rf) {
    int capacity=variant==0?0:(variant==11?12:8);
    int numflds=variant==0?0:(variant==11?8:(variant==12?2163:6));
    size_t n=(size_t)np*(size_t)nl;
    buffer geometry=make_buffer(17096/8,0),cfg=make_buffer(1359136/8,0);
    buffer gfl=make_buffer(n*(size_t)capacity,tail);
    buffer a=make_buffer(n,tail),r=make_buffer(n,tail);
    memset(geometry.data,0,17096);
    put_i(geometry.data,5144,np);put_i(geometry.data,5224,nl);
    configure((unsigned char *)cfg.data,variant,capacity,numflds);
    for(int f=0;f<capacity;++f) for(size_t k=0;k<n;++k)
        gfl.data[(size_t)f*n+k]=(double)((f+(int)(k%3))%13+1)/4096.0;
    for(size_t k=0;k<n;++k) {
        long double condition;int selected;
        long double rm=mixture((unsigned char *)cfg.data,gfl.data,n,k,&condition,&selected);
        a.data[k]=initial_temperature(pattern,k,rm,*constants[0]);r.data[k]=a.data[k];
    }
    size_t output_size=raw_size(&a);
    double *incoming=malloc(output_size);
    if(!incoming) fail("incoming copy");
    memcpy(incoming,a.data-1,output_size);
    int32_t header[12]={number,np,ks,ke,nl,capacity,numflds,variant,pattern,tail,1,0};
    write_bytes(input,header,sizeof header);
    for(int f=0;f<6;++f) write_bytes(input,constants[f],8);
    for(int f=0;f<numflds;++f) {
        const unsigned char *p=(const unsigned char *)cfg.data+3848+(size_t)f*368;
        write_bytes(input,p+68,4);write_bytes(input,p+168,4);
        write_bytes(input,p+72,8);write_bytes(input,p+80,8);
    }
    write_bytes(input,gfl.data-1,raw_size(&gfl));
    write_bytes(input,incoming,output_size);
    readonly(&geometry);readonly(&cfg);readonly(&gfl);
    unsigned char *old=*global_config;
    *global_config=(unsigned char *)cfg.data;
    uint64_t control=fpcr(),constant_bits[6];
    for(int f=0;f<6;++f) constant_bits[f]=bits(*constants[f]);
    ctvtot_(geometry.data,cfg.data,&ks,&ke,r.data,gfl.data);
    if(fpcr()!=control) fail("reference changed FPCR");
#ifndef CTVTOT_FREEZE_ONLY
    ctvtot_assembly_(geometry.data,cfg.data,&ks,&ke,a.data,gfl.data);
#else
    memcpy(a.data-1,r.data-1,output_size);
#endif
    if(fpcr()!=control) fail("assembly changed FPCR");
    if(*global_config!=(unsigned char *)cfg.data) fail("changed global configuration pointer");
    for(int f=0;f<6;++f) if(bits(*constants[f])!=constant_bits[f]) fail("changed module constant");
    for(size_t k=0;k<output_size/8;++k) {
        double av=a.data[(ptrdiff_t)k-1],rv=r.data[(ptrdiff_t)k-1];
        if(bits(av)!=bits(rv)) {
            ptrdiff_t cell=(ptrdiff_t)k-1;
            fprintf(stderr,"CTVTOT case=%d field=PT level=%td column=%td"
                " assembly=%016" PRIx64 " reference=%016" PRIx64 "\n",
                number,cell>=0?cell/np+1:0,cell>=0?cell%np+1:0,bits(av),bits(rv));
            fail("different output bytes");
        }
        int active=k>0 && k<=n && (int)((k-1)%(size_t)np)+1>=ks &&
                   (int)((k-1)%(size_t)np)+1<=ke;
        if(!active && bits(av)!=bits(incoming[k])) fail("inactive cell or guard changed");
        if(active) {
            size_t cell=k-1;long double condition;int selected;
            long double rm=mixture((unsigned char *)cfg.data,gfl.data,n,cell,&condition,&selected);
            long double expected=(long double)*constants[0]*incoming[k]/rm;
            physics(av,expected,condition,selected);
            if(!selected) physics(av,incoming[k],1.0L,0);
            if(pattern==4) physics(av,252.0L+(long double)cell/64.0L,condition,selected);
            if(variant==2 && pattern==0) {
                double q=gfl.data[cell],coef=*constants[1]-*constants[0];
                double product=coef*q,rounded_rm=*constants[0]+product;
                double ratio=*constants[0]/rounded_rm,alternative=incoming[k]*ratio;
                if(bits(alternative)!=bits(av)) ++rounding_witnesses;
            }
        }
    }
    write_bytes(af,header,sizeof header);write_bytes(rf,header,sizeof header);
    for(int f=0;f<6;++f) {write_bytes(af,constants[f],8);write_bytes(rf,constants[f],8);}
    write_bytes(af,a.data-1,output_size);write_bytes(rf,r.data-1,output_size);
    bytes+=sizeof header+48+output_size;++calls;
    if(nl>0 && ke>=ks) ++active_calls;
    *global_config=old;
    free(incoming);release(&a);release(&r);release(&gfl);release(&cfg);release(&geometry);
}
int main(int argc,char **argv) {
    if(argc!=4) fail("input and two output paths required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    if(hook) *hook=0;
    global_config=dlsym(RTLD_DEFAULT,"__yom_ygfl_MOD_ygfl");
    if(!global_config) fail("global configuration symbol");
    const char *names[6]={"__yomcst_MOD_rd","__yomcst_MOD_rv","__yomcst_MOD_rcpd",
                         "__yomcst_MOD_rcpv","__yomcst_MOD_rcw","__yomcst_MOD_rcs"};
    const uint64_t defaults[6]={UINT64_C(0x4071f0f46c5fe708),UINT64_C(0x407cd8665f622251),
        UINT64_C(0x408f65abbda7d44e),UINT64_C(0x409cd8665f622251),
        UINT64_C(0x40b07a0000000000),UINT64_C(0x40a0740000000000)};
    double old[6];
    for(int f=0;f<6;++f) {
        constants[f]=dlsym(RTLD_DEFAULT,names[f]);if(!constants[f]) fail(names[f]);
        old[f]=*constants[f];memcpy(constants[f],&defaults[f],8);
    }
    uint64_t control=fpcr();
    if(control&UINT64_C(0x03c80000)) fail("rounding or gradual underflow");
    FILE *input=fopen(argv[1],"wb"),*af=fopen(argv[2],"wb"),*rf=fopen(argv[3],"wb");
    if(!input || !af || !rf) fail("stream open");
    const int shapes[][4]={{1,1,1,0},{1,1,1,1},{2,1,2,2},{3,1,3,3},
        {7,2,6,5},{9,1,9,19},{13,13,13,20},{3,2,1,7},{8,1,8,32}};
    int number=0;
    for(size_t s=0;s<sizeof shapes/sizeof shapes[0];++s)
        for(int variant=0;variant<=12;++variant)
            check_case(++number,variant,shapes[s][0],shapes[s][1],shapes[s][2],shapes[s][3],
                       0,0,input,af,rf);
    const int edge_variants[4]={0,2,8,10};
    for(int pattern=1;pattern<=5;++pattern) for(int c=0;c<4;++c)
        for(int width=1;width<=7;width+=3)
            check_case(++number,edge_variants[c],width,1,width,3,pattern,0,input,af,rf);
    const int tails[][4]={{1,1,1,1},{3,1,3,19},{4,2,4,3},{7,1,7,5}};
    const int tail_variants[3]={2,8,12};
    for(size_t s=0;s<sizeof tails/sizeof tails[0];++s) for(int c=0;c<3;++c)
        check_case(++number,tail_variants[c],tails[s][0],tails[s][1],tails[s][2],tails[s][3],
                   0,1,input,af,rf);
    if(!rounding_witnesses) fail("multiply-before-divide witness absent");
    if(fpcr()!=control) fail("final FPCR");
    if(fclose(input) || fclose(af) || fclose(rf)) fail("stream close");
    for(int f=0;f<6;++f) *constants[f]=old[f];
#ifdef CTVTOT_FREEZE_ONLY
    const char *label="CTVTOT SOURCE CORPUS";
#else
    const char *label="CTVTOT PASS";
#endif
    printf("%s cases=%d calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0"
        " independent_values=%" PRIu64 " product_division_witnesses=%" PRIu64
        " direct_dependency_calls=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        label,number,calls,bytes,science_values,rounding_witnesses,active_calls,control);
    return 0;
}

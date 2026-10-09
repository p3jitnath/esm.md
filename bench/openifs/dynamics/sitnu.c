/* Check positive continuity and adiabatic-temperature operator products.
 * PD uses s^-1, PT uses K/s, and PSP uses s^-1. Caller padding is returned
 * unchanged. The ordered vertical dependency remains part of the solver. */
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
#define SIT_ARGS const void *geometry,const void *dyn,const int32_t *a, \
 const int32_t *b,const double *input,double *temperature,double *surface,const int32_t *columns
void sitnu_(SIT_ARGS);
#ifndef SITNU_FREEZE_ONLY
uint64_t sitnu_call_checked(SIT_ARGS);
#endif
typedef struct { void *map; size_t bytes,usable,count; double *data; int tail; } buffer;
static const double guard=-777.75;
static uint64_t calls,total_bytes,science_values,mode_calls[2],protected_calls;
static double *kappa;
static int parallel_case;
static const double reference_temperature=256.125,reference_pressure=1024.0;
static const double matrix_1_0[]={0x1.0000000000000p-1,0x1.0000000000000p+0};
static const double matrix_1_1[]={-0x1.5555555555555p-4,-0x1.5555555555555p-5,0x1.0000000000000p-1,0x1.0000000000000p+0,-0x1.5555555555555p-5,0x1.5555555555555p-5};
static const double matrix_1_2[]={0x1.0000000000000p-1,0x1.0000000000000p+0};
static const double matrix_2_0[]={0x1.4000000000000p-2,0x1.2000000000000p-1,0x1.0000000000000p-1,-0x1.0000000000000p-4,0x1.8000000000000p-3,0x1.0000000000000p-1};
static const double matrix_2_1[]={-0x1.1364d9364d936p-6,-0x1.a2e8ba2e8ba2fp-8,-0x1.5555555555555p-7,0x1.25d1745d1745dp-2,0x1.12e8ba2e8ba2fp-1,0x1.0000000000000p-1,-0x1.2e8ba2e8ba2e9p-5,0x1.b45d1745d1746p-3,0x1.0000000000000p-1,0x1.07c1f07c1f07cp-8,-0x1.a2e8ba2e8ba2fp-8,0x1.5555555555555p-7};
static const double matrix_2_2[]={0x1.25d1745d1745dp-2,0x1.12e8ba2e8ba2fp-1,0x1.0000000000000p-1,-0x1.2e8ba2e8ba2e9p-5,0x1.b45d1745d1746p-3,0x1.0000000000000p-1};
static const double matrix_3_0[]={0x1.eaaaaaaaaaaabp-2,0x1.2aaaaaaaaaaabp-1,0x1.2000000000000p-1,0x1.5555555555555p-1,-0x1.5555555555555p-2,-0x1.5555555555555p-3,0x0.0p+0,-0x1.5555555555555p-2,0x1.aaaaaaaaaaaabp-4,0x1.5555555555555p-4,0x1.8000000000000p-3,0x1.5555555555555p-1};
static const double matrix_3_1[]={-0x1.5edd33a4aea80p-7,-0x1.42b7142b7142bp-7,-0x1.551c979aee0c0p-7,-0x1.1111111111111p-7,0x1.89c7b3c10d853p-2,0x1.f9cb3f9cb3f9dp-2,0x1.e3fd571b43289p-2,0x1.1111111111111p-1,-0x1.8fd8fd8fd8fd9p-3,-0x1.1111111111111p-5,0x1.0750750750750p-3,-0x1.1111111111111p-4,0x1.f1265836f7cc9p-5,0x1.42b7142b7142bp-5,0x1.30b4dcc22939ep-3,0x1.1111111111111p-1,-0x1.102e1a2773ebap-9,-0x1.8d3018d3018d3p-10,-0x1.37308a4e765bcp-9,0x1.1111111111111p-7};
static const double matrix_3_2[]={0x1.89c7b3c10d853p-2,0x1.f9cb3f9cb3f9dp-2,0x1.e3fd571b43289p-2,0x1.1111111111111p-1,-0x1.8fd8fd8fd8fd9p-3,-0x1.1111111111111p-5,0x1.0750750750750p-3,-0x1.1111111111111p-4,0x1.f1265836f7cc9p-5,0x1.42b7142b7142bp-5,0x1.30b4dcc22939ep-3,0x1.1111111111111p-1};
static const double *fixture_matrix(int n,int ibc) {
    if(ibc==3) ibc=1;
    if(n==1) return ibc==0?matrix_1_0:ibc==1?matrix_1_1:matrix_1_2;
    if(n==2) return ibc==0?matrix_2_0:ibc==1?matrix_2_1:matrix_2_2;
    return ibc==0?matrix_3_0:ibc==1?matrix_3_1:matrix_3_2;
}
static void fail(const char *s) {fprintf(stderr,"SITNU check failed %s\n",s);exit(2);}
static uint64_t bits(double x) {uint64_t u;memcpy(&u,&x,8);return u;}
static uint64_t fpcr(void) {uint64_t u;__asm__ volatile("mrs %0,fpcr":"=r"(u));return u;}
static buffer allocate(size_t n,int tail) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE),entries=n+2-(size_t)tail;
    size_t usable=(entries*8+page-1)/page*page;
    void *m=mmap(NULL,usable+2*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(m==MAP_FAILED || mprotect((char *)m+page,usable,PROT_READ|PROT_WRITE)) fail("allocation pages");
    double *p=(double *)((char *)m+page+usable-entries*8)+1;
    for(size_t k=0;k<entries;++k) p[(ptrdiff_t)k-1]=guard;
    return (buffer){m,usable+2*page,usable,n,p,tail};
}
static void release(buffer *p) {if(munmap(p->map,p->bytes)) fail("unmap");}
static void readonly(buffer *p) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    if(mprotect((char *)p->map+page,p->usable,PROT_READ)) fail("read-only input");
}
static void integer(void *p,size_t off,int32_t n) {memcpy((char *)p+off,&n,4);}
static void real(void *p,size_t off,double x) {memcpy((char *)p+off,&x,8);}
static void pointer(void *p,size_t off,const void *q) {memcpy((char *)p+off,&q,8);}
static void rank1(void *p,size_t off,buffer *x,int64_t lower,int64_t upper) {
    uint64_t w[8]={(uintptr_t)x->data,(uint64_t)-lower,8,UINT64_C(0x0000030100000000),
        8,1,(uint64_t)lower,(uint64_t)upper};memcpy((char *)p+off,w,64);
}
static void rank2(void *p,size_t off,buffer *x,int64_t rows,int64_t cols,int64_t low) {
    uint64_t w[11]={(uintptr_t)x->data,(uint64_t)(-low-(low+3)*rows),8,
        UINT64_C(0x0000030200000000),8,1,(uint64_t)low,(uint64_t)(low+rows-1),
        (uint64_t)rows,(uint64_t)(low+3),(uint64_t)(low+3+cols-1)};
    memcpy((char *)p+off,w,88);
}
static void write_bytes(FILE *f,const void *p,size_t n) {
    if(n && fwrite(p,1,n,f)!=n) fail("output write");
}
static void scientific(double got,long double expected,long double condition,long double discretization,const char *what) {
    long double tolerance=8192.0L*DBL_EPSILON*fmaxl(1.0L,fabsl(expected))*fmaxl(1.0L,condition)+32.0L*DBL_TRUE_MIN+discretization;
    if(!isfinite(got) || fabsl((long double)got-expected)>tolerance) {
        fprintf(stderr,"science %s got=%.17g expected=%.21Lg tolerance=%.9Lg\n",what,got,expected,tolerance);
        fail("independent identity");
    }
    ++science_values;
}
static void read_capture(const char *name,double *out,size_t n) {
    char path[1024];snprintf(path,sizeof path,"%s/%s",SITNU_GRID_ROOT,name);
    FILE *f=fopen(path,"rb");if(!f) fail(path);
    if(fread(out,8,n,f)!=n || fgetc(f)!=EOF || fclose(f)) fail("captured fixture size");
}
static double divergence(int pattern,int32_t j,int32_t c,int32_t n,int ibc,double eta) {
    double scale=(double)(c+1)*0x1p-10;
    if(pattern==0) return scale;
    if(pattern==1) {
        if(ibc<0) return scale*(1.0+(double)j*0.25);
        if(n==1) return scale;
        return ibc==0?scale*(1.0+eta):scale*(1.0+3.0*eta*eta-2.0*eta*eta*eta);
    }
    if(pattern==2) return j==c%n?scale:0.0;
    if(pattern==3) return (j+c)%2?-0.0:0.0;
    if(pattern==4) return (j+c)%2?-DBL_TRUE_MIN:DBL_TRUE_MIN;
    if(pattern==5) return (j+c)%2?-0x1.fffffffffffffp-1:0x1.0000000000001p0;
    return (j+c)%2?-0x1p500:0x1p-500;
}
static void compare(int mode,const char *field,buffer *a,buffer *r,const double *before,
                    const unsigned char *active,FILE *af,FILE *rf) {
    size_t entries=a->count+2-(size_t)a->tail;
    for(size_t k=0;k<entries;++k) {
        ptrdiff_t index=(ptrdiff_t)k-1;
        if(bits(a->data[index])!=bits(r->data[index])) {
            fprintf(stderr,"Mismatch stage=SITNU call=%" PRIu64 " mode=%d field=%s storage_cell=%td assembly=%016" PRIx64 " source=%016" PRIx64 "\n",
                calls,mode,field,index+1,bits(a->data[index]),bits(r->data[index]));exit(1);
        }
        int selected=k>0 && k<=a->count && active[k-1];
        double old=k>0 && k<=a->count?before[k-1]:guard;
        if(!selected && bits(a->data[index])!=bits(old)) fail("inactive byte or guard changed");
        if(selected && !isfinite(a->data[index])) fail("nonfinite output");
    }
    write_bytes(af,a->data-1,entries*8);write_bytes(rf,r->data-1,entries*8);
    total_bytes+=(uint64_t)entries*8;
}
static void check(int mode,int ibc,int32_t n,int32_t c,int32_t a,int32_t b,
                  int32_t shift,size_t capacity,size_t ps_capacity,int pattern,
                  int tail,int lower,int32_t chunk,FILE *af,FILE *rf,FILE *inf) {
    if(c<0 || n<0 || a<1 || b<1 || (mode && n<1 && c>0)) fail("corpus shape");
    buffer geo=allocate(2137,0),dyn=allocate(590,0),veta=allocate(40,0),
        vfe=allocate(272,0),cver=allocate(27,0);
    memset(geo.data,0,17096);memset(dyn.data,0,4720);memset(veta.data,0,320);
    memset(vfe.data,0,2176);memset(cver.data,0,216);
    integer(geo.data,5144,chunk);integer(geo.data,5224,n);
    pointer(geo.data,3248,veta.data);pointer(geo.data,3256,vfe.data);pointer(geo.data,3264,cver.data);
    integer(cver.data,52,mode);integer(cver.data,36,ibc);
    real(dyn.data,2520,reference_temperature);real(dyn.data,2568,1.0/reference_pressure);
    size_t coeff_count=n>0?(size_t)(n-lower+1):0;
    buffer coeff[6];const size_t offsets[5]={2600,2664,2728,2792,2920};
    for(int f=0;f<6;++f) {
        coeff[f]=allocate(coeff_count,tail);
        if(f<5) rank1(dyn.data,offsets[f],&coeff[f],lower,n);
        else rank1(veta.data,256,&coeff[f],lower,n);
    }
    double eta[21]={0},half[20]={0},rd[19]={0};
    if(mode && n==19) {
        read_capture("eta-full.bin",eta,21);read_capture("eta-half.bin",half,20);
        read_capture("reciprocal-layer.bin",rd,19);
    } else if(mode && n>0) {
        const double e[3][3]={{0.5,0,0},{0.25,0.75,0},{0.25,0.5,0.75}};
        if(n>3) fail("rational level count");
        for(int32_t j=0;j<n;++j) eta[j+1]=e[n-1][j];
        eta[n+1]=1.0;half[0]=0.0;half[n]=1.0;
        for(int32_t j=1;j<n;++j) half[j]=(eta[j]+eta[j+1])*0.5;
        for(int32_t j=0;j<n;++j) rd[j]=1.0/(half[j+1]-half[j]);
    }
    long double boundaries[129]={128.0L};
    for(int32_t j=0;j<n;++j) {
        size_t k=(size_t)(j+1-lower);
        double depth=mode?reference_pressure*(half[j+1]-half[j]):32.0+16.0*j;
        if(!mode) boundaries[j+1]=boundaries[j]+(long double)depth;
        long double lg=mode?0.0L:logl(boundaries[j+1]/boundaries[j]);
        coeff[0].data[k]=mode?0.0:(double)(1.0L-boundaries[j]*lg/(long double)depth);
        coeff[1].data[k]=(double)lg;
        coeff[2].data[k]=depth;coeff[3].data[k]=1.0/depth;
        coeff[4].data[k]=mode?reference_pressure*eta[j+1]:depth/(double)lg;
        coeff[5].data[k]=mode?rd[j]:1.0;
    }
    buffer matrix={0};
    if(mode && n>0) {
        int32_t rows=n+1,cols=n+((ibc==1 || ibc==3)?2:0);
        matrix=allocate((size_t)rows*(size_t)cols,tail);
        if(n==19) {
            if(ibc!=3) fail("captured selector");
            read_capture("matrix-001.bin",matrix.data,420);
        } else {
            const double *m=fixture_matrix(n,ibc);
            memcpy(matrix.data,m,matrix.count*8);
        }
        rank2(vfe.data,ibc==0?64:ibc==2?1296:240,&matrix,rows,cols,lower);
        readonly(&matrix);
    }
    buffer input=allocate(capacity,tail),at=allocate(capacity,tail),rt=allocate(capacity,tail),
        ap=allocate(ps_capacity,tail),rp=allocate(ps_capacity,tail);
    unsigned char *active_t=calloc(capacity?capacity:1,1),*active_p=calloc(ps_capacity?ps_capacity:1,1);
    double *before_t=malloc((capacity?capacity:1)*8),*before_p=malloc((ps_capacity?ps_capacity:1)*8);
    if(!active_t || !active_p || !before_t || !before_p) fail("state copies");
    for(size_t k=0;k<capacity;++k) input.data[k]=-321.25+(double)(k%8)*0.125;
    for(int32_t i=0;i<c;++i) {
        if((size_t)(shift+i)>=ps_capacity) fail("surface capacity");
        active_p[shift+i]=1;
        for(int32_t j=0;j<n;++j) {
            size_t k=(size_t)shift+(size_t)j*(size_t)a+(size_t)i*(size_t)b;
            if(k>=capacity || active_t[k]) fail("noninjective extent");
            active_t[k]=1;input.data[k]=divergence(pattern,j,i,n,mode?ibc:-1,eta[j+1]);
        }
    }
    memcpy(before_t,at.data,capacity*8);memcpy(before_p,ap.data,ps_capacity*8);
    memcpy(rt.data,at.data,capacity*8);memcpy(rp.data,ap.data,ps_capacity*8);
    readonly(&input);for(int f=0;f<6;++f) readonly(&coeff[f]);
    readonly(&geo);readonly(&dyn);readonly(&veta);readonly(&vfe);readonly(&cver);
    ++calls;++mode_calls[mode];if(tail) ++protected_calls;
    const int32_t header[14]={mode,ibc,n,c,a,b,shift,(int32_t)capacity,(int32_t)ps_capacity,pattern,tail,lower,chunk,parallel_case};
    for(int f=0;f<3;++f) {
        FILE *o=f==0?af:f==1?rf:inf;
        write_bytes(o,&calls,8);write_bytes(o,header,sizeof header);write_bytes(o,kappa,8);
    }
    write_bytes(inf,input.data,capacity*8);
    for(int f=0;f<6;++f) write_bytes(inf,coeff[f].data,coeff_count*8);
    if(mode && n>0) write_bytes(inf,matrix.data,matrix.count*8);
    write_bytes(inf,before_t,capacity*8);write_bytes(inf,before_p,ps_capacity*8);
    uint64_t control=fpcr(),constant=bits(*kappa);
    sitnu_(geo.data,dyn.data,&a,&b,input.data+shift,rt.data+shift,rp.data+shift,&c);
    if(fpcr()!=control || bits(*kappa)!=constant) fail("source FPCR or constant");
#ifdef SITNU_FREEZE_ONLY
    memcpy(at.data,rt.data,capacity*8);memcpy(ap.data,rp.data,ps_capacity*8);
#else
    if(sitnu_call_checked(geo.data,dyn.data,&a,&b,input.data+shift,at.data+shift,ap.data+shift,&c))
        fail("AAPCS64 callee-saved registers");
#endif
    if(fpcr()!=control || bits(*kappa)!=constant) fail("native FPCR or constant");
    compare(mode,"PT",&at,&rt,before_t,active_t,af,rf);
    compare(mode,"PSP",&ap,&rp,before_p,active_p,af,rf);
    if(pattern<=2 && c>0) {
        for(int32_t i=0;i<c;++i) {
            long double total=0.0L,condition=1.0L;
            for(int32_t j=0;j<n;++j) {
                size_t k=(size_t)shift+(size_t)j*(size_t)a+(size_t)i*(size_t)b;
                long double d=input.data[k],expected;
                if(!mode) {
                    long double top=boundaries[j],bottom=boundaries[j+1],width=bottom-top;
                    long double integral=(total-d*top)*logl(bottom/top)+d*width;
                    expected=(long double)*kappa*reference_temperature*integral/width;
                    total+=d*width;
                    scientific(at.data[k],expected,condition,0.0L,"layer integral of omega/p");
                } else if(pattern<=1) {
                    long double e=eta[j+1],scale=(long double)(i+1)*0x1p-10L,q;
                    if(pattern==0 || n==1) q=scale*e;
                    else if(ibc==0) q=scale*(e+e*e*0.5L);
                    else q=scale*(e+e*e*e-0.5L*e*e*e*e);
                    expected=(long double)*kappa*reference_temperature*q/e;
                    scientific(at.data[k],expected,condition,(n==19 && pattern==1)?2.0e-6L*fabsl((long double)*kappa*reference_temperature*scale):0.0L,"top integral and full pressure");
                }
            }
            if(!mode) scientific(ap.data[shift+i],total/reference_pressure,condition,0.0L,"column mass balance");
            else if(pattern<=1) {
                long double scale=(long double)(i+1)*0x1p-10L;
                long double expected=scale*((pattern==0 || n==1)?1.0L:1.5L);
                scientific(ap.data[shift+i],expected,condition,(n==19 && pattern==1)?1.0e-8L*fabsl(scale):0.0L,"finite-element column mass");
            }
        }
    }
    for(int f=0;f<6;++f) release(&coeff[f]);
    if(mode && n>0) release(&matrix);
    release(&input);release(&at);release(&rt);release(&ap);release(&rp);
    release(&geo);release(&dyn);release(&veta);release(&vfe);release(&cver);
    free(active_t);free(active_p);free(before_t);free(before_p);
}
int main(int argc,char **argv) {
    if(argc!=4) fail("assembly, source and input paths required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(hook) *hook=0;
    void (*initialize)(void);void *p=dlsym(RTLD_DEFAULT,"__oml_mod_MOD_oml_init");
    if(!p) fail("OML_INIT");
    memcpy(&initialize,&p,sizeof initialize);initialize();
    kappa=dlsym(RTLD_DEFAULT,"__yomcst_MOD_rkappa");if(!kappa) fail("RKAPPA");
    *kappa=0x1.2492492492492p-2;
    if(fpcr()!=0) fail("requires FPCR zero");
    FILE *af=fopen(argv[1],"wb"),*rf=fopen(argv[2],"wb"),*inf=fopen(argv[3],"wb");
    if(!af || !rf || !inf) fail("canonical output paths");
    const int32_t shapes[][7]={
        {0,3,5,1,0,0,3},{0,0,1,1,0,0,0},{7,0,9,1,0,54,0},
        {1,1,1,1,0,1,1},{2,3,3,1,0,6,3},{3,3,1,3,0,9,3},
        {19,5,8,1,2,152,8},{4,3,9,2,0,35,3},{32,7,1,32,0,224,7}};
    for(size_t s=0;s<sizeof shapes/sizeof shapes[0];++s)
        for(int pattern=0;pattern<=6;++pattern) {
            const int32_t *v=shapes[s];
            check(0,0,v[0],v[1],v[2],v[3],v[4],(size_t)v[5],(size_t)v[6],pattern,0,1,8,af,rf,inf);
        }
    for(int pattern=0;pattern<=6;++pattern) {
        check(0,0,1,1,1,1,0,1,1,pattern,1,-2,1,af,rf,inf);
        check(0,0,3,3,3,1,0,9,3,pattern,1,-2,3,af,rf,inf);
        check(0,0,19,3,1,19,0,57,3,pattern,1,-2,3,af,rf,inf);
    }
    for(int lower=-2;lower<=1;lower+=3)
        for(int32_t n=1;n<=3;++n) for(int ibc=0;ibc<4;++ibc)
            for(int pattern=0;pattern<=6;++pattern)
                check(1,ibc,n,3,1,n,0,(size_t)n*3,3,pattern,1,lower,2,af,rf,inf);
    for(int pattern=0;pattern<=6;++pattern)
        check(1,3,19,5,8,1,2,152,8,pattern,1,-2,3,af,rf,inf);
    check(1,3,19,0,24,1,0,432,0,0,1,1,24,af,rf,inf);
    check(1,3,19,1,1,19,0,19,1,0,1,1,1,af,rf,inf);
    check(1,3,19,19,1,19,0,361,19,2,1,1,19,af,rf,inf);
    check(1,3,19,506,506,1,0,9614,506,0,1,1,24,af,rf,inf);
    check(1,3,0,0,1,1,0,0,0,0,1,1,1,af,rf,inf);
    parallel_case=1;
#pragma omp parallel num_threads(2)
    {
#pragma omp single
        check(1,3,3,3,3,1,0,9,3,0,1,-2,2,af,rf,inf);
    }
    parallel_case=0;
    if(fclose(af)||fclose(rf)||fclose(inf)) fail("close");
#ifdef SITNU_FREEZE_ONLY
    const char *status="REFERENCE PREPARATION";
#else
    const char *status="PASS";
#endif
    printf("SITNU %s calls=%" PRIu64 " conventional=%" PRIu64 " finite_element=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 science_values=%" PRIu64 " protected_calls=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        status,calls,mode_calls[0],mode_calls[1],total_bytes,science_values,protected_calls,fpcr());
    return 0;
}

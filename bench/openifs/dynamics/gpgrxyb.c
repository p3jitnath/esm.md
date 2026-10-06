/* Verify pressure-gradient weights in inverse pascals and their horizontal gradients.
 * Independent derivatives test hybrid pressure and the thin-layer approximation. */
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
#define GPGRXYB_ARGS const int32_t *np,const int32_t *ks,const int32_t *ke, \
 const int32_t *nl,const int32_t *save,const void *vab,const void *cver, \
 const double *pl,const double *pm,const double *xyb,double *der
typedef void (*kernel)(GPGRXYB_ARGS);
void gpgrxyb_(GPGRXYB_ARGS);
void gpgrxyb_assembly_(GPGRXYB_ARGS);
typedef struct {void *map;size_t map_bytes,usable_bytes,count;double *data;int tail;} buffer;
static const double guard=-777.75;
static uint64_t total_bytes,total_calls;
static int32_t *xi,*di;
static void fail(const char *message) {
    fprintf(stderr,"GPGRXYB check failed %s\n",message);exit(2);
}
static uint64_t bits(double value) {
    uint64_t result;memcpy(&result,&value,8);return result;
}
static uint64_t fpcr(void) {
    uint64_t value;__asm__ volatile("mrs %0,fpcr":"=r"(value));return value;
}
static buffer make_buffer(size_t count,int tail) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE),entries=count+2-(size_t)tail;
    size_t usable=(entries*8+page-1)/page*page;
    void *map=mmap(NULL,usable+2*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(map==MAP_FAILED || mprotect((char *)map+page,usable,PROT_READ|PROT_WRITE)) fail("buffer pages");
    double *data=(double *)((char *)map+page+usable-entries*8)+1;
    for(size_t i=0;i<entries;++i) data[(ptrdiff_t)i-1]=guard;
    return (buffer){map,usable+2*page,usable,count,data,tail};
}
static void readonly(buffer *value) {
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    if(mprotect((char *)value->map+page,value->usable_bytes,PROT_READ)) fail("read-only input");
}
static void release(buffer *value) {
    if(munmap(value->map,value->map_bytes)) fail("release pages");
}
static void set_integer(void *object,size_t offset,int32_t value) {
    memcpy((char *)object+offset,&value,4);
}
static void descriptor(void *object,size_t offset,const buffer *coef,int64_t lower,int64_t upper) {
    int64_t words[8]={(int64_t)(intptr_t)coef->data,-lower,8,INT64_C(3302829850624),8,1,lower,upper};
    memcpy((char *)object+offset,words,sizeof words);
}
static void pressure(int32_t level,int32_t column,int thin,long double *pu,long double *pl,
                     long double *bu,long double *bl,long double *au,long double *al) {
    long double ps=65536.0L+128.0L*column;
    *au=4096.0L+256.0L*level;*al=*au+(thin?8.0L:4096.0L);
    *bu=1.0L/16.0L;*bl=*bu+(thin?1.0L/1048576.0L:1.0L/32.0L);
    *pu=*au+*bu*ps;*pl=*al+*bl*ps;
}
static void check_case(int number,int mode,int save,int alternate,int32_t np,int32_t ks,
                       int32_t ke,int32_t nl,int pattern,int tail,FILE *af,FILE *rf) {
    int32_t xm[8],dm[10];
    for(int f=0;f<7;++f) xm[f]=alternate?7-f:f+1;
    xm[7]=7;
    for(int f=0;f<9;++f) dm[f]=alternate?9-f:f+1;
    dm[9]=9;
    memcpy(xi,xm,sizeof xm);memcpy(di,dm,sizeof dm);
    size_t cells=(size_t)np*(size_t)nl;
    int64_t lower=alternate?-1:1,upper=nl;
    if(pattern==5) lower=0;
    size_t nc=(size_t)(upper-lower+1);
    buffer vab=make_buffer(64,0),cver=make_buffer(27,0),coef[3];
    memset(vab.data,0,512);memset(cver.data,0,216);
    set_integer(cver.data,52,mode==0);set_integer(cver.data,4,mode==0?99:mode-1);
    for(int f=0;f<3;++f) {
        coef[f]=make_buffer(nc,tail);
        for(size_t k=0;k<nc;++k) coef[f].data[k]=0.0;
    }
    if(mode==0) descriptor(vab.data,448,&coef[0],lower,upper);
    else descriptor(vab.data,192,&coef[1],lower,upper);
    if(mode==1) descriptor(vab.data,64,&coef[2],lower,upper);
    buffer pl=make_buffer((size_t)np,tail),pm=make_buffer((size_t)np,tail);
    int capacity=pattern==6?6:9;
    buffer in=make_buffer(cells*7,tail),a=make_buffer(cells*(size_t)capacity,tail),r=make_buffer(cells*(size_t)capacity,tail);
    for(size_t k=0;k<cells*7;++k) in.data[k]=0.0;
    for(int32_t i=0;i<np;++i) {
        pl.data[i]=8.0;pm.data[i]=-16.0;
        if(pattern==1) pl.data[i]=pm.data[i]=0.0;
        if(pattern==2) {pl.data[i]=-0.0;pm.data[i]=0.0;}
        if(pattern==3) {pl.data[i]=0x0.0000000000001p-1022;pm.data[i]=-0x0.0000000000001p-1022;}
        if(pattern==4) {pl.data[i]=1.0;pm.data[i]=-1.0;}
    }
    for(int32_t j=1;j<=nl;++j) {
        long double pu,lp,bu,bl,au,al;
        pressure(j,0,pattern==5,&pu,&lp,&bu,&bl,&au,&al);
        coef[0].data[(size_t)((int64_t)j-lower)]=(double)(bl-bu);
        coef[1].data[(size_t)((int64_t)j-lower)]=(double)(al*bu-au*bl);
        coef[2].data[(size_t)((int64_t)j-lower)]=(double)bl;
        if(pattern==4 && mode==0) coef[0].data[(size_t)((int64_t)j-lower)]=1.0+0x1p-27;
        if(pattern==4 && mode==1) coef[2].data[(size_t)((int64_t)j-lower)]=1.0+0x1p-27;
        for(int32_t i=0;i<np;++i) {
            pressure(j,i,pattern==5,&pu,&lp,&bu,&bl,&au,&al);
            long double dp=lp-pu,pf=(pu+lp)/2.0L,c=al*bu-au*bl;
            long double d=mode==0?dp/pf:mode==1?logl(lp/pu):dp/sqrtl(lp*pu);
            long double alpha=mode==0?(lp-pf)/pf:mode==1?1.0L-pu*d/dp:1.0L-sqrtl(pu/lp);
            long double t=mode==0?(bu+bl)/2.0L/pf:(bl-bu)/dp+c*d/(dp*dp);
            double values[7]={(double)dp,(double)(1.0L/dp),(double)d,(double)alpha,
                             (double)t,(double)(1.0L/lp),(double)(1.0L/(lp*pu))};
            if(pattern==4 && mode==0) {values[1]=1.0-0x1p-27;values[2]=1.0;values[4]=1.0;}
            if(pattern==4 && mode==1) {values[5]=1.0-0x1p-27;values[4]=1.0;}
            size_t k=(size_t)(j-1)*(size_t)np+(size_t)i;
            for(int f=0;f<7;++f) in.data[((size_t)xm[f]-1)*cells+k]=values[f];
        }
    }
    xi[0]=-99;
    if(mode==0) {xi[3]=xi[5]=xi[6]=-99;di[2]=di[3]=di[4]=di[5]=di[7]=di[8]=-99;}
    else if(mode==1) xi[1]=xi[2]=xi[3]=-99;
    else xi[1]=xi[5]=-99;
    if(!save) di[6]=di[7]=di[8]=-99;
    int32_t xi_before[8],di_before[10];memcpy(xi_before,xi,32);memcpy(di_before,di,40);
    readonly(&vab);readonly(&cver);readonly(&pl);readonly(&pm);readonly(&in);
    for(int f=0;f<3;++f) readonly(&coef[f]);
    int empty=nl==0 || ke<ks;int32_t flag=save;
    gpgrxyb_(&np,&ks,&ke,&nl,&flag,vab.data,cver.data,empty?NULL:pl.data,empty?NULL:pm.data,empty?NULL:in.data,r.data);
    gpgrxyb_assembly_(&np,&ks,&ke,&nl,&flag,vab.data,cver.data,empty?NULL:pl.data,empty?NULL:pm.data,empty?NULL:in.data,a.data);
    ++total_calls;
    int selected[9]={0};
    for(int f=0;f<6;++f) if(f<2 || mode!=0) selected[dm[f]-1]=1;
    if(save) {selected[dm[6]-1]=1;if(mode!=0) selected[dm[7]-1]=selected[dm[8]-1]=1;}
    size_t entries=cells*(size_t)capacity+2-(size_t)tail;
    for(size_t k=0;k<entries;++k) {
        double av=a.data[(ptrdiff_t)k-1],rv=r.data[(ptrdiff_t)k-1];
        if(bits(av)!=bits(rv)) {
            size_t p=k?k-1:0;
            fprintf(stderr,"Mismatch stage=GPGRXYB case=%d mode=%d field=%zu level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                number,mode,cells?p/cells+1:0,np?(p%(cells?cells:1))/(size_t)np+1:0,p%(size_t)np+1,bits(av),bits(rv));exit(1);
        }
        if(k==0 || k>cells*(size_t)capacity || (cells && (!selected[(k-1)/cells] ||
           (int32_t)((k-1)%(size_t)np+1)<ks || (int32_t)((k-1)%(size_t)np+1)>ke)))
            if(bits(av)!=bits(guard)) fail("inactive field or guard");
    }
    if(fwrite(a.data-1,8,entries,af)!=entries || fwrite(r.data-1,8,entries,rf)!=entries) fail("trajectory write");
    total_bytes+=(uint64_t)entries*8;
    if(pattern==0 || pattern==1 || pattern==5 || pattern==6) for(int32_t j=1;j<=nl;++j) for(int32_t i=ks-1;i<ke;++i) {
        long double pu,lp,bu,bl,au,al;pressure(j,i,pattern==5,&pu,&lp,&bu,&bl,&au,&al);
        long double dp=lp-pu,pf=(pu+lp)/2.0L,ds=bl/lp-bu/pu,D,A=0.0L,P=0.0L;
        if(mode==0) D=((bl-bu)*pf-dp*(bu+bl)/2.0L)/(pf*pf);
        else {
            D=ds;
            if(mode==1) {P=bl/lp;A=(al*bu-au*bl)/(dp*dp)*(dp/lp-logl(lp/pu));}
            else {
                long double z=sqrtl(pu/lp),E=(1.0L-z)/(1.0L+z);
                long double derivative=0.5L*(z+1.0L/z)*ds;
                long double depth_error=-0.5L*(1.0L-z)*(1.0L-z)/z*ds;
                long double delta=1.0L/32.0L,pu_hi=pu+bu*delta,pl_hi=lp+bl*delta;
                long double pu_lo=pu-bu*delta,pl_lo=lp-bl*delta;
                long double high=(pl_hi-pu_hi)/sqrtl(pl_hi*pu_hi);
                long double low=(pl_lo-pu_lo)/sqrtl(pl_lo*pu_lo);
                long double measured=(high-low)/(2.0L*delta);
                if(fabsl(measured-derivative)>1.0e-18L+1.0e-10L*fabsl(derivative)) fail("independent approximate-depth derivative");
                D=derivative+depth_error;
                if(pattern==5 && fabsl(depth_error)>1.0e-6L*fabsl(ds)) fail("thin-layer depth derivative limit");
                A=0.5L*z*ds+0.5L*z*E*ds;
                P=0.5L*z*ds+0.5L*(bl/lp+bu/pu)+0.5L*(1.0L-z)*ds;
                if(pattern==5 && (fabsl(0.5L*z*E*ds)>fabsl(ds)*0.001L ||
                                 fabsl(0.5L*(1.0L-z)*ds)>fabsl(ds)*0.001L)) fail("thin-layer derivative limit");
            }
        }
        long double expected[9]={D*pl.data[i],D*pm.data[i],A*pl.data[i],A*pm.data[i],
            P*pl.data[i],P*pm.data[i],D,A,P};
        size_t cell=(size_t)(j-1)*(size_t)np+(size_t)i;
        for(int f=0;f<9;++f) if((f<2 || (f<6 && mode!=0)) || (save && (f==6 || (f>6 && mode!=0)))) {
            double actual=a.data[((size_t)dm[f]-1)*cells+cell];
            long double tolerance=1.0e-16L+1.0e-12L*fabsl(expected[f]);
            if(!isfinite(actual) || fabsl((long double)actual-expected[f])>tolerance) fail("independent hybrid-pressure derivative");
        }
    }
    if(pattern==4) for(int32_t j=1;j<=nl;++j) for(int32_t i=ks-1;i<ke;++i) {
        size_t cell=(size_t)(j-1)*(size_t)np+(size_t)i;
        if(mode==0 && bits(a.data[((size_t)dm[0]-1)*cells+cell])!=0) fail("finite-element rounding witness");
        if(mode==1 && bits(a.data[((size_t)dm[2]-1)*cells+cell])!=0) fail("alpha rounding witness");
    }
    if(memcmp(xi_before,xi,32) || memcmp(di_before,di,40)) fail("changed index objects");
    release(&vab);release(&cver);release(&pl);release(&pm);release(&in);release(&a);release(&r);
    for(int f=0;f<3;++f) release(&coef[f]);
}
int main(int argc,char **argv) {
    if(argc!=3) fail("two output paths required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(hook) *hook=0;
    xi=dlsym(RTLD_DEFAULT,"__intdyn_mod_MOD_yytxyb");di=dlsym(RTLD_DEFAULT,"__intdyn_mod_MOD_yytxybder");
    if(!xi || !di) fail("module indices");
    uint64_t control=fpcr();if(control & UINT64_C(0x03c80000)) fail("FPCR rounding or underflow");
    FILE *af=fopen(argv[1],"wb"),*rf=fopen(argv[2],"wb");if(!af || !rf) fail("output open");
    const int32_t shapes[][4]={{1,1,1,0},{1,1,1,1},{1,1,1,19},{7,2,6,5},
        {9,1,9,19},{13,13,13,20},{3,2,1,7},{2,1,2,1},{5,1,5,3}};
    int number=0;
    for(size_t c=0;c<sizeof shapes/sizeof shapes[0];++c) for(int mode=0;mode<4;++mode) for(int save=0;save<2;++save) for(int map=0;map<2;++map)
        check_case(++number,mode,save,map,shapes[c][0],shapes[c][1],shapes[c][2],shapes[c][3],c==1?1:0,0,af,rf);
    for(int pattern=2;pattern<=5;++pattern) for(int mode=0;mode<4;++mode) for(int save=0;save<2;++save)
        check_case(++number,mode,save,1,3,1,3,4,pattern,0,af,rf);
    for(int mode=0;mode<4;++mode) for(int save=0;save<2;++save) check_case(++number,mode,save,0,3,1,3,2,0,1,af,rf);
    for(int mode=0;mode<4;++mode) for(int tail=0;tail<2;++tail) check_case(++number,mode,0,0,3,1,3,2,6,tail,af,rf);
    if(fpcr()!=control) fail("changed FPCR");
    if(fclose(af) || fclose(rf)) fail("output close");
    printf("GPGRXYB PASS cases=%d calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",number,total_calls,total_bytes,control);
    return 0;
}

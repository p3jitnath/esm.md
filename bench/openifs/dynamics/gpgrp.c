/* Check GPGRP against independent pressure-force balances and Fortran bytes.
 * Gradients use one shared horizontal coordinate. Outputs use m²/s² per unit
 * of that coordinate. The supplied thermal product uses m²/s². */
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
#define GPGRP_ARGS const void *geometry,const int32_t *ks,const int32_t *ke, \
 const double *h,const double *gl,const double *gm,const double *pl,const double *pm, \
 const double *xyb,const double *der,const double *bhl,const double *bhm, \
 const double *bfl,const double *bfm,double *sl,double *sm
typedef void (*kernel)(GPGRP_ARGS);
void gpgrp_(GPGRP_ARGS);
void gpgrp_assembly_(GPGRP_ARGS);
enum {H,GL,GM,PL,PM,XYB,DER,BHL,BHM,BFL,BFM,NFIELDS};
typedef struct {void *map;size_t map_bytes,usable_bytes,count;double *data;int tail;} buffer;
static const double guard=-777.75;
static uint64_t total_bytes,total_calls;
static int32_t *xyb_indices,*der_indices;
static void fail(const char *message) {
    fprintf(stderr,"GPGRP check failed %s\n",message);
    exit(2);
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
static void call(kernel fn,const void *geometry,int32_t ks,int32_t ke,int mode,
                 buffer f[NFIELDS],buffer outputs[2]) {
    fn(geometry,&ks,&ke,f[H].data,mode?NULL:f[GL].data,mode?NULL:f[GM].data,
       mode?f[PL].data:NULL,mode?f[PM].data:NULL,f[XYB].data,mode?NULL:f[DER].data,
       mode?NULL:f[BHL].data,mode?NULL:f[BHM].data,mode?f[BFL].data:NULL,mode?f[BFM].data:NULL,
       outputs[0].data,outputs[1].data);
}
static void check_case(int number,int mode,int alternate,int32_t np,int32_t ks,
                       int32_t ke,int32_t nl,int pattern,int tail,FILE *af,FILE *rf) {
    size_t count=(size_t)np*(size_t)nl;
    int32_t ia=alternate?7:4,ic=alternate?2:5,il=alternate?9:5,im=alternate?1:6;
    xyb_indices[3]=ia;xyb_indices[4]=ic;xyb_indices[7]=7;
    der_indices[4]=il;der_indices[5]=im;der_indices[9]=9;
    buffer geometry=make_buffer(17096/8,0),cver=make_buffer(216/8,0);
    memset(geometry.data,0,17096);memset(cver.data,0,216);
    set_integer(geometry.data,5144,np);set_integer(geometry.data,5224,nl);
    memcpy((char *)geometry.data+3264,&cver.data,sizeof cver.data);
    set_integer(cver.data,52,mode);
    size_t sizes[NFIELDS]={count,count,count,(size_t)np,(size_t)np,count*7,count*9,
        (size_t)np*((size_t)nl+1),(size_t)np*((size_t)nl+1),count,count};
    buffer f[NFIELDS],a[2],r[2];
    for(int field=0;field<NFIELDS;++field) f[field]=make_buffer(sizes[field],tail);
    for(int field=0;field<2;++field) {a[field]=make_buffer(count,tail);r[field]=make_buffer(count,tail);}
    for(int field=0;field<NFIELDS;++field)
        for(size_t k=0;k<sizes[field];++k) f[field].data[k]=0.0;
    for(int32_t i=0;i<np;++i) {f[PL].data[i]=8.0;f[PM].data[i]=-16.0;}
    for(int32_t j=0;j<nl;++j) for(int32_t i=0;i<np;++i) {
        size_t k=(size_t)j*(size_t)np+(size_t)i,b=k+(size_t)np;
        double h=65536.0+128.0*j+2.0*i,gl=2.0,gm=-4.0;
        double alpha=0.5+(double)i/1024.0,al=1.0/1024.0,am=-1.0/2048.0;
        double bl=16.0,bm=-8.0,dl=al+1.0/8192.0,dm=am-1.0/4096.0,coefficient=1.0/65536.0;
        double fl=bl+alpha*gl+h*al,fm=bm+alpha*gm+h*am;
        if(pattern==1) {
            gl=gm=dl=dm=bl=bm=fl=fm=0.0;
            f[PL].data[i]=f[PM].data[i]=0.0;
        }
        if(pattern==2) {
            h=-0.0;gl=-0.0;gm=0.0;bl=-0.0;bm=0.0;fl=-0.0;fm=0.0;
            f[PL].data[i]=-0.0;f[PM].data[i]=0.0;
        }
        if(pattern==3) {
            h=0x1p-1022;gl=-0x0.0000000000001p-1022;gm=0x0.0000000000001p-1022;
            bl=bm=fl=fm=0.0;
        }
        if(pattern==4) {
            h=1.0;alpha=1.0+0x1p-27;gl=1.0-0x1p-27;gm=-gl;
            dl=-1.0;dm=1.0;bl=bm=0.0;
            coefficient=1.0+0x1p-27;
            f[PL].data[i]=1.0-0x1p-27;f[PM].data[i]=-f[PL].data[i];
            fl=-1.0;fm=1.0;
        }
        f[H].data[k]=h;f[GL].data[k]=gl;f[GM].data[k]=gm;
        f[XYB].data[((size_t)ia-1)*count+k]=alpha;
        f[XYB].data[((size_t)ic-1)*count+k]=coefficient;
        f[DER].data[((size_t)il-1)*count+k]=dl;
        f[DER].data[((size_t)im-1)*count+k]=dm;
        f[BHL].data[b]=bl;f[BHM].data[b]=bm;f[BFL].data[k]=fl;f[BFM].data[k]=fm;
    }
    readonly(&geometry);readonly(&cver);
    for(int field=0;field<NFIELDS;++field) readonly(&f[field]);
    call(gpgrp_,geometry.data,ks,ke,mode,f,r);
    call(gpgrp_assembly_,geometry.data,ks,ke,mode,f,a);
    ++total_calls;
    for(int field=0;field<2;++field) {
        size_t entries=count+2-(size_t)tail;
        for(size_t k=0;k<entries;++k) {
            double av=a[field].data[(ptrdiff_t)k-1],rv=r[field].data[(ptrdiff_t)k-1];
            if(bits(av)!=bits(rv)) {
                fprintf(stderr,"Mismatch stage=GPGRP case=%d mode=%d field=%d level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                    number,mode,field,k?((k-1)/(size_t)np):0,k?((k-1)%(size_t)np+1):0,bits(av),bits(rv));
                exit(1);
            }
            if(k==0 || k>count || (int32_t)((k-1)%(size_t)np+1)<ks || (int32_t)((k-1)%(size_t)np+1)>ke)
                if(bits(av)!=bits(guard)) fail("inactive output or guard");
        }
        if(fwrite(a[field].data-1,8,entries,af)!=entries || fwrite(r[field].data-1,8,entries,rf)!=entries) fail("trajectory write");
        total_bytes+=(uint64_t)entries*8;
    }
    for(int32_t j=0;j<nl;++j) for(int32_t i=ks-1;i<ke;++i) {
        size_t k=(size_t)j*(size_t)np+(size_t)i;
        long double expected[2];
        if(pattern==0) {
            long double h=65536.0L+128.0L*j+2.0L*i,alpha=0.5L+(long double)i/1024.0L;
            expected[0]=16.0L+alpha*2.0L+h*(1.0L/1024.0L+1.0L/8192.0L);
            expected[1]=-8.0L-alpha*4.0L+h*(-1.0L/2048.0L-1.0L/4096.0L);
        } else if(pattern==1 || pattern==2 || pattern==4) expected[0]=expected[1]=0.0L;
        else {
            long double h=0x1p-1022L;
            if(mode) {
                expected[0]=h*(1.0L/65536.0L)*8.0L;
                expected[1]=h*(1.0L/65536.0L)*-16.0L;
            } else {
                long double alpha=0.5L+(long double)i/1024.0L;
                expected[0]=alpha*(-0x0.0000000000001p-1022L)+h*(1.0L/1024.0L+1.0L/8192.0L);
                expected[1]=alpha*0x0.0000000000001p-1022L+h*(-1.0L/2048.0L-1.0L/4096.0L);
            }
        }
        for(int field=0;field<2;++field) {
            long double error=fabsl((long double)a[field].data[k]-expected[field]);
            long double tolerance=64.0L*DBL_EPSILON*fmaxl(1.0L,fabsl(expected[field]));
            if(!isfinite(a[field].data[k]) || error>tolerance) fail("independent pressure force");
            if(pattern==4 && bits(a[field].data[k])!=0) fail("separate-rounding witness");
        }
    }
    release(&geometry);release(&cver);
    for(int field=0;field<NFIELDS;++field) release(&f[field]);
    for(int field=0;field<2;++field) {release(&a[field]);release(&r[field]);}
}
int main(int argc,char **argv) {
    if(argc!=3) fail("two output paths required");
    int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    if(hook) *hook=0;
    xyb_indices=dlsym(RTLD_DEFAULT,"__intdyn_mod_MOD_yytxyb");
    der_indices=dlsym(RTLD_DEFAULT,"__intdyn_mod_MOD_yytxybder");
    if(!xyb_indices || !der_indices) fail("upstream field-index objects");
    uint64_t control=fpcr();
    if(control & UINT64_C(0x03c80000)) fail("FPCR rounding or underflow");
    FILE *af=fopen(argv[1],"wb"),*rf=fopen(argv[2],"wb");
    if(!af || !rf) fail("output open");
    const int32_t shapes[][4]={{1,1,1,0},{1,1,1,1},{1,1,1,19},{7,2,6,5},
        {9,1,9,19},{13,13,13,20},{3,2,1,7},{2,1,2,1},{5,1,5,3}};
    int number=0;
    for(size_t c=0;c<sizeof shapes/sizeof shapes[0];++c)
        for(int mode=0;mode<2;++mode) for(int alternate=0;alternate<2;++alternate)
            check_case(++number,mode,alternate,shapes[c][0],shapes[c][1],shapes[c][2],shapes[c][3],c==1?1:0,0,af,rf);
    for(int pattern=2;pattern<=4;++pattern) for(int mode=0;mode<2;++mode)
        check_case(++number,mode,1,3,1,3,4,pattern,0,af,rf);
    for(int mode=0;mode<2;++mode) for(int alternate=0;alternate<2;++alternate)
        check_case(++number,mode,alternate,3,1,3,2,0,1,af,rf);
    if(fpcr()!=control) fail("changed FPCR");
    if(fclose(af) || fclose(rf)) fail("output close");
    printf("GPGRP PASS cases=%d calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",
        number,total_calls,total_bytes,control);
    return 0;
}

/* Verify the complete implicit Coriolis preparation in spectral space.
 * Vorticity and its auxiliary correction have units s^-1. The input time is s.
 * The independent checks solve the two-real-number inverse and neighbour map
 * in long double; exact source/native acceptance remains zero differing bytes.
 */
#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <inttypes.h>
#include <dlfcn.h>
#include <sys/mman.h>
#include <unistd.h>
#include <omp.h>

typedef struct {
    double *data;
    int64_t offset;
    uint64_t elem;
    int32_t version;
    int8_t rank, type;
    int16_t attribute;
    int64_t span;
    struct { int64_t stride, lower, upper; } dim[2];
} Desc;
typedef struct {
    int n,l,m,sta,end,layout,pattern,parameter,full,steps,basis,component;
} Case;
typedef struct {
    unsigned char *map,*base;
    size_t mapping,bytes;
    int64_t minimum,s1,s2;
    int rows,cols;
    Desc desc;
} Array;
typedef struct {
    unsigned char geometry[17096],dyn[4720],rip[175976];
    Desc av,bv,aa,ba;
    int32_t m,sta,end;
} Inputs;
extern void spcimpfinit_(const void *,const void *,const void *,
                        const int32_t *,const int32_t *,const int32_t *,
                        const Desc *,const Desc *);
#ifndef SPCIMPFINIT_FREEZE_ONLY
extern uint64_t spcimpfinit_abi_(const void *,const void *,const void *,
                               const int32_t *,const int32_t *,const int32_t *,
                               const Desc *,const Desc *);
#endif
static FILE *native_file,*reference_file,*input_file;
static double *omega;
static int32_t *hook;
static uint64_t calls,returned_bytes,science_values,protected_calls,abi_calls;
static uint64_t zero_mode_calls,positive_mode_calls,empty_calls,rounding_witnesses;
static size_t page;
static int parallel_case;
static uint64_t parallel_native_calls;
static uint64_t fpcr(void) { uint64_t x; __asm__ volatile("mrs %0,fpcr":"=r"(x)); return x; }
static uint64_t bits(double x) { uint64_t u; memcpy(&u,&x,8); return u; }
static void fail(const char *what,uint64_t id,int level,int degree,uint64_t a,uint64_t b) {
    fprintf(stderr,"SPCIMPFINIT FAIL %s call=%" PRIu64 " level=%d degree=%d bits=%016" PRIx64 "/%016" PRIx64 "\n",what,id,level,degree,a,b);
    exit(1);
}
static void write_bytes(FILE *f,const void *p,size_t n) {
    if(n && fwrite(p,1,n,f)!=n) { perror("fwrite"); exit(1); }
}
static size_t ceiling(size_t n) { return (n+page-1)/page*page; }
static void protect(void *p,size_t n,int mode) {
    if(mprotect(p,n,mode)) { perror("mprotect"); exit(1); }
}
static void put_i32(void *p,size_t off,int32_t x) { memcpy((char *)p+off,&x,4); }
static void put_f64(void *p,size_t off,double x) { memcpy((char *)p+off,&x,8); }
static Array array(int rows,int cols,int kind) {
    Array a={0};
    a.rows=rows; a.cols=cols;
    switch(kind%6) {
    case 0: a.s1=1; a.s2=rows?rows:1; break;
    case 1: a.s1=2; a.s2=2*(rows?rows:1)+3; break;
    case 2: a.s1=-1; a.s2=(rows?rows:1)+2; break;
    case 3: a.s1=1; a.s2=-((rows?rows:1)+1); break;
    case 4: a.s1=-2; a.s2=-(2*(rows?rows:1)+3); break;
    default: a.s1=(cols?cols:1)+2; a.s2=1; break;
    }
    int64_t r=rows?((int64_t)rows-1)*a.s1:0;
    int64_t c=cols?((int64_t)cols-1)*a.s2:0;
    a.minimum=(r<0?r:0)+(c<0?c:0);
    int64_t maximum=(r>0?r:0)+(c>0?c:0);
    a.bytes=(rows && cols)?(size_t)(maximum-a.minimum+1)*8:0;
    size_t accessible=ceiling(a.bytes+32);
    a.mapping=accessible+page;
    a.map=mmap(NULL,a.mapping,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(a.map==MAP_FAILED) { perror("mmap"); exit(1); }
    protect(a.map+accessible,page,PROT_NONE);
    a.base=a.map+accessible-a.bytes;
    memset(a.base-32,0xA5,32);
    for(size_t i=0;i<a.bytes/8;i++) {
        uint64_t u=UINT64_C(0x7ff80000ac010000)+(uint64_t)(i%65536);
        memcpy(a.base+8*i,&u,8);
    }
    a.desc.data=(double *)(a.base-a.minimum*8);
    int64_t low1=(kind%3==2)?-2:1,low2=(kind%3==1)?4:1;
    a.desc.offset=-(low1*a.s1+low2*a.s2);
    a.desc.elem=8; a.desc.version=0; a.desc.rank=2; a.desc.type=3;
    a.desc.attribute=0; a.desc.span=8;
    a.desc.dim[0].stride=a.s1; a.desc.dim[0].lower=low1; a.desc.dim[0].upper=low1+rows-1;
    a.desc.dim[1].stride=a.s2; a.desc.dim[1].lower=low2; a.desc.dim[1].upper=low2+cols-1;
    return a;
}
static void release(Array *a) { if(munmap(a->map,a->mapping)) { perror("munmap"); exit(1); } }
static size_t cell(const Array *a,int level,int column) {
    return (size_t)(((int64_t)level-1)*a->s1+((int64_t)column-1)*a->s2-a->minimum);
}
static double get(const Array *a,const unsigned char *data,int level,int column) {
    double x; memcpy(&x,data+8*cell(a,level,column),8); return x;
}
static void set(Array *a,int level,int column,double x) {
    memcpy(a->base+8*cell(a,level,column),&x,8);
}
static void parameters(int p,double *b,double *t,double *w) {
    /* Default Earth input from the original YOMCST statement order, plus algebraic edge inputs. */
    *b=0.6; *t=3600.0; *w=0x1.31da7d4fedf5fp-14;
    switch(p) {
    case 1: *t=0.0; break;
    case 2: *t=-3600.0; break;
    case 3: *w=0.0; break;
    case 4: *b=-0.0; break;
    case 5: *b=0.5; *t=1.0; *w=0x1p+498; break;
    case 6: *b=0.5; *t=1.0; *w=DBL_TRUE_MIN; break;
    case 7: *b=0.5; *t=-0.0; *w=0x1p+20; break;
    case 8: *b=0.5; *t=1.0; *w=0.75; break;
    default: break;
    }
}
static double initial(Case c,int j,int n,int imag,double b,double t,double w) {
    uint64_t q=UINT64_C(0x9e3779b97f4a7c15)*(uint64_t)(1+j+29*n+307*imag+997*c.pattern);
    q^=q>>30; q*=UINT64_C(0xbf58476d1ce4e5b9); q^=q>>27;
    int sign=(q>>63)?-1:1;
    switch(c.pattern) {
    case 0: return ((j+n+imag)&1)?-0.0:0.0;
    case 1: return imag?-0.000003*(j+1):0.00001*(j+1);
    case 2: return (n==c.basis && imag==c.component)?0.00001*(j+1):0.0;
    case 5: return sign*DBL_TRUE_MIN*(1+(int)(q%7));
    case 6: return sign*0x1p-498*(1.0+(double)(q%17)/32.0);
    case 7: return sign*DBL_MAX;
    case 9: {
        double v=(double)(1+(q%97))/64.0*0.00001;
        if(imag) return v;
        double f=((2.0*(b*t))*w)*(double)c.m;
        double a=f/((double)n*((double)n+1.0));
        return n?nextafter(a*v,INFINITY):0.0;
    }
    default: return sign*(double)(1+(q%100001))*0x1p-33;
    }
}
static long double alpha(Case c,int n,long double f) {
    return (n && c.m)?f*(long double)c.m/((long double)n*((long double)n+1)):0;
}
static void prime(Case c,const Array *a,const unsigned char *before,
                  int j,int n,long double f,long double *r,long double *i) {
    int col=c.sta+2*(n-c.m);
    long double u=get(a,before,j,col),v=get(a,before,j,col+1);
    if(!c.m) { *r=u; *i=v; return; }
    long double al=alpha(c,n,f),d=1/(1+al*al);
    *r=d*(u-al*v); *i=d*(v+al*u);
}
static void close_science(const char *what,long double got,long double expected,
                          long double scale,long double floor,int j,int n) {
    long double tolerance=4096.0L*DBL_EPSILON*fmaxl(scale,LDBL_MIN)+floor;
    science_values++;
    if(!isfinite(got) || fabsl(got-expected)>tolerance) {
        fprintf(stderr,"SPCIMPFINIT SCIENCE FAIL %s call=%" PRIu64 " level=%d degree=%d got=%.21Lg expected=%.21Lg error=%.5Lg tolerance=%.5Lg\n",what,calls,j,n,got,expected,fabsl(got-expected),tolerance);
        exit(1);
    }
}
static void physics(Case c,const Array *v,const Array *a,const unsigned char *before,
                    double b,double t,double w) {
    long double f=2*(long double)b*(long double)t*(long double)w;
    for(int n=c.m;n<=c.n;n++) {
        long double al=alpha(c,n,f);
        long double fm=0,fp=0;
        if(n>c.m) fm=f*((long double)n+1)/(long double)n
                         *sqrtl(((long double)n*n-(long double)c.m*c.m)
                                /(4*(long double)n*n-1));
        if(n<c.n && n) fp=f*(long double)n/((long double)n+1)
                            *sqrtl((((long double)n+1)*((long double)n+1)
                                     -(long double)c.m*c.m)
                                    /(4*((long double)n+1)*((long double)n+1)-1));
        for(int j=1;j<=c.l;j++) {
            int col=c.sta+2*(n-c.m);
            long double u=get(v,before,j,col),z=get(v,before,j,col+1);
            long double r=get(v,v->base,j,col),i=get(v,v->base,j,col+1);
            long double er,ei; prime(c,v,before,j,n,f,&er,&ei);
            long double floor=64.0L*DBL_TRUE_MIN*(1+fabsl(al));
            close_science("inverse real",r+al*i,u,fabsl(r)+fabsl(al*i)+fabsl(u),floor,j,n);
            close_science("inverse imag",i-al*r,z,fabsl(i)+fabsl(al*r)+fabsl(z),floor,j,n);
            close_science("prime real",r,er,fabsl(er)+fabsl(u)+fabsl(al*z),floor,j,n);
            close_science("prime imag",i,ei,fabsl(ei)+fabsl(z)+fabsl(al*u),floor,j,n);
            if(c.m) {
                long double energy=(u*u+z*z)/(1+al*al);
                close_science("inverse amplitude",r*r+i*i,energy,
                              r*r+i*i+energy,128.0L*DBL_TRUE_MIN*(1+fabsl(r)+fabsl(i)),j,n);
            } else if(bits((double)r)!=bits((double)u) || bits((double)i)!=bits((double)z)) {
                fail("zero-mode vorticity mutation",calls,j,n,bits((double)r),bits((double)u));
            }
            long double lowr=0,lowi=0,highr=0,highi=0;
            if(n>c.m) prime(c,v,before,j,n-1,f,&lowr,&lowi);
            if(n<c.n && n) prime(c,v,before,j,n+1,f,&highr,&highi);
            long double ar=fm*lowr+fp*highr,ai=fm*lowi+fp*highi;
            long double neighbour_scale=fabsl(fm)*(fabsl(lowr)+fabsl(lowi))
                                      +fabsl(fp)*(fabsl(highr)+fabsl(highi));
            long double afloor=128.0L*DBL_TRUE_MIN
                              *(1+fabsl(fm)+fabsl(fp))*(1+fabsl(al));
            close_science("lower/upper real",get(a,a->base,j,col),ar,
                          fabsl(ar)+neighbour_scale,afloor,j,n);
            close_science("lower/upper imag",get(a,a->base,j,col+1),ai,
                          fabsl(ai)+neighbour_scale,afloor,j,n);
            if((c.m==0 && n==0) || c.n==c.m) {
                if(bits(get(a,a->base,j,col)) || bits(get(a,a->base,j,col+1)))
                    fail("zero endpoint auxiliary",calls,j,n,bits(get(a,a->base,j,col)),0);
            }
            if(c.m && c.parameter==0) {
                double bd=b*t,force=(2.0*bd)*w;
                double ad=(force*(double)c.m)/((double)n*((double)n+1.0));
                double separate=(double)u-ad*(double)z;
                double fused=fma(-ad,(double)z,(double)u);
                if(bits(separate)!=bits(fused)) rounding_witnesses++;
            }
        }
    }
}
static void unchanged(const Array *a,const unsigned char *before,
                      Case c,int permit,const char *name) {
    unsigned char *allowed=calloc(a->bytes/8?a->bytes/8:1,1);
    if(!allowed) { perror("calloc"); exit(1); }
    if(permit) for(int n=c.m;n<=c.n;n++) for(int j=1;j<=c.l;j++) {
        int col=c.sta+2*(n-c.m);
        allowed[cell(a,j,col)]=1; allowed[cell(a,j,col+1)]=1;
    }
    for(size_t k=0;k<a->bytes/8;k++) if(!allowed[k] && memcmp(a->base+8*k,before+8*k,8)) {
        uint64_t x,y; memcpy(&x,a->base+8*k,8); memcpy(&y,before+8*k,8);
        fail(name,calls,0,(int)k,x,y);
    }
    for(int k=0;k<32;k++) if(a->base[-32+k]!=0xA5)
        fail("leading protected-allocation guard",calls,0,k,a->base[-32+k],0xA5);
    free(allowed);
}
static void record(FILE *f,const uint64_t *head,const Array *v,const Array *a) {
    write_bytes(f,head,256);
    write_bytes(f,v->base-32,v->bytes+32);
    write_bytes(f,a->base-32,a->bytes+32);
}
static void compare_array(const Array *x,const Array *y,const char *name) {
    if(memcmp(x->base-32,y->base-32,x->bytes+32)) {
        for(size_t k=0;k<x->bytes/8;k++) if(memcmp(x->base+8*k,y->base+8*k,8)) {
            uint64_t a,b; memcpy(&a,x->base+8*k,8); memcpy(&b,y->base+8*k,8);
            fail(name,calls,0,(int)k,a,b);
        }
        fail(name,calls,0,-1,0,1);
    }
}
static void run(Case c) {
    double b,t,w; parameters(c.parameter,&b,&t,&w);
    int last=c.sta+2*(c.n-c.m)+1;
    int cols=c.full?(c.n+1)*(c.n+2):last+2;
    int rows=c.l?c.l+(c.layout%3):0;
    Array vr=array(rows,cols,c.layout);
    Array vn=array(rows,cols,c.layout);
    Array ar=array(c.l?c.l+((c.layout+1)%3):0,cols+1,(c.layout+2)%6);
    Array an=array(ar.rows,ar.cols,(c.layout+2)%6);
    for(int n=c.m;n<=c.n;n++) for(int j=1;j<=c.l;j++) {
        int col=c.sta+2*(n-c.m);
        double u=initial(c,j,n,0,b,t,w),z=initial(c,j,n,1,b,t,w);
        set(&vr,j,col,u); set(&vr,j,col+1,z);
    }
    memcpy(vn.base,vr.base,vr.bytes);
    memcpy(an.base,ar.base,ar.bytes);
    size_t in_bytes=ceiling(sizeof(Inputs));
    Inputs *in=mmap(NULL,in_bytes,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(in==MAP_FAILED) { perror("mmap"); exit(1); }
    memset(in,0,sizeof(*in));
    put_i32(in->geometry,5172,c.n); put_i32(in->geometry,5228,c.l);
    put_i32(in->geometry,5236,rows); put_i32(in->geometry,5200,cols);
    put_f64(in->dyn,2496,b); put_f64(in->rip,208,t);
    in->m=c.m; in->sta=c.sta; in->end=c.end;
    in->av=vr.desc; in->aa=ar.desc; in->bv=vn.desc; in->ba=an.desc;
    protect(in,in_bytes,PROT_READ);
    unsigned char *vbefore=malloc(vr.bytes?vr.bytes:1);
    unsigned char *abefore=malloc(ar.bytes?ar.bytes:1);
    if(!vbefore || !abefore) { perror("malloc"); exit(1); }
    *omega=w;
    for(int step=1;step<=c.steps;step++) {
        calls++;
        zero_mode_calls+=c.m==0; positive_mode_calls+=c.m>0;
        empty_calls+=c.l==0; protected_calls++;
        memcpy(vbefore,vr.base,vr.bytes); memcpy(abefore,ar.base,ar.bytes);
        uint64_t h[32]={0}; memcpy(h,"SPCF0001",8);
        h[1]=calls; h[2]=step; h[3]=c.steps;
        h[4]=c.n; h[5]=c.l; h[6]=c.m; h[7]=c.sta; h[8]=(uint64_t)(int64_t)c.end;
        h[9]=c.pattern; h[10]=c.layout; h[11]=vr.rows; h[12]=vr.cols;
        h[13]=(uint64_t)vr.s1; h[14]=(uint64_t)vr.s2;
        h[15]=ar.rows; h[16]=ar.cols; h[17]=(uint64_t)ar.s1; h[18]=(uint64_t)ar.s2;
        h[19]=vr.bytes; h[20]=ar.bytes; h[21]=bits(b); h[22]=bits(t); h[23]=bits(w);
        h[24]=c.basis; h[25]=c.component; h[26]=4096; h[27]=parallel_case;
        Desc dv=vr.desc,da=ar.desc; dv.data=NULL; da.data=NULL;
        write_bytes(input_file,h,256); write_bytes(input_file,&dv,88); write_bytes(input_file,&da,88);
        write_bytes(input_file,vr.base-32,vr.bytes+32); write_bytes(input_file,ar.base-32,ar.bytes+32);
        if(fpcr()) fail("entry FPCR",calls,0,0,fpcr(),0);
        spcimpfinit_(in->geometry,in->rip,in->dyn,&in->m,&in->sta,&in->end,&in->av,&in->aa);
        if(fpcr()) fail("source FPCR",calls,0,0,fpcr(),0);
        if(bits(*omega)!=bits(w) || *hook) fail("module input mutation",calls,0,0,bits(*omega),bits(w));
        unchanged(&vr,vbefore,c,c.m>0,"source inactive vorticity");
        unchanged(&ar,abefore,c,1,"source inactive auxiliary");
        physics(c,&vr,&ar,vbefore,b,t,w);
#ifdef SPCIMPFINIT_FREEZE_ONLY
        memcpy(vn.base,vr.base,vr.bytes); memcpy(an.base,ar.base,ar.bytes);
#else
        uint64_t mask=0;
        if(parallel_case) {
            unsigned char *expected_v=malloc(vr.bytes+32),*expected_a=malloc(ar.bytes+32);
            if(!expected_v || !expected_a) { perror("malloc"); exit(1); }
            memcpy(expected_v,vr.base-32,vr.bytes+32);
            memcpy(expected_a,ar.base-32,ar.bytes+32);
            memcpy(vr.base,vbefore,vr.bytes); memcpy(ar.base,abefore,ar.bytes);
            uint64_t masks[2]={0,0};
            int team=0;
            #pragma omp parallel num_threads(2) shared(team,masks)
            {
                int tid=omp_get_thread_num();
                #pragma omp single
                team=omp_get_num_threads();
                if(tid<2) masks[tid]=spcimpfinit_abi_(in->geometry,in->rip,in->dyn,
                    &in->m,&in->sta,&in->end,tid?&in->av:&in->bv,tid?&in->aa:&in->ba);
            }
            if(team!=2) fail("genuine two-thread native team",calls,0,0,(uint64_t)team,2);
            mask=masks[0]|masks[1]; abi_calls+=2; parallel_native_calls+=2;
            if(memcmp(vr.base-32,expected_v,vr.bytes+32) || memcmp(ar.base-32,expected_a,ar.bytes+32))
                fail("second parallel native output",calls,0,0,0,1);
            memcpy(vr.base-32,expected_v,vr.bytes+32);
            memcpy(ar.base-32,expected_a,ar.bytes+32);
            free(expected_v); free(expected_a);
        } else {
            mask=spcimpfinit_abi_(in->geometry,in->rip,in->dyn,&in->m,&in->sta,&in->end,&in->bv,&in->ba);
            abi_calls++;
        }
        if(mask) fail("direct numerical-entry AAPCS canary",calls,0,0,mask,0);
        if(fpcr()) fail("native FPCR",calls,0,0,fpcr(),0);
        if(bits(*omega)!=bits(w) || *hook) fail("native module input mutation",calls,0,0,bits(*omega),bits(w));
        unchanged(&vn,vbefore,c,c.m>0,"native inactive vorticity");
        unchanged(&an,abefore,c,1,"native inactive auxiliary");
#endif
        compare_array(&vn,&vr,"vorticity"); compare_array(&an,&ar,"auxiliary");
        record(native_file,h,&vn,&an); record(reference_file,h,&vr,&ar);
        returned_bytes+=vr.bytes+ar.bytes+64;
    }
    free(vbefore); free(abefore); munmap(in,in_bytes);
    release(&vr); release(&vn); release(&ar); release(&an);
}
int main(int argc,char **argv) {
    if(argc!=4) { fprintf(stderr,"usage: %s native.bin source.bin input.bin\n",argv[0]); return 2; }
    page=(size_t)sysconf(_SC_PAGESIZE);
    _Static_assert(sizeof(Desc)==88,"GNU rank-two descriptor");
    __asm__ volatile("msr fpcr,xzr");
    omega=dlsym(RTLD_DEFAULT,"__yomcst_MOD_romega");
    hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");
    if(!omega || !hook) { fprintf(stderr,"missing source module input\n"); return 2; }
    *hook=0;
    native_file=fopen(argv[1],"wb"); reference_file=fopen(argv[2],"wb"); input_file=fopen(argv[3],"wb");
    if(!native_file || !reference_file || !input_file) { perror("fopen"); return 2; }
    int ns[]={1,2,3,5,8},ls[]={0,1,3,5};
    int serial=0;
    for(int z=0;z<5;z++) for(int m=0;m<=ns[z];m++) for(int k=0;k<4;k++) {
        Case c={ns[z],ls[k],m,1+(serial%3),-19,serial%6,serial%5,serial%5,0,1,0,0};
        run(c); serial++;
    }
    for(int m=0;m<=21;m++) {
        Case c={21,19,m,1+m*(45-m),0,0,3,0,1,1,0,0};
        c.end=c.sta+2*(21-m)+1; run(c);
    }
    int large_n[]={127,127,127,127,32767,32767,65535};
    int large_m[]={0,1,37,127,32767,32766,65534};
    for(int k=0;k<7;k++) {
        Case c={large_n[k],(k<4)?3:1,large_m[k],3,INT32_MIN,k%6,3,0,0,1,0,0};
        run(c);
    }
    int ms[]={0,1,3};
    for(int k=0;k<3;k++) for(int p=0;p<=8;p++) {
        int pat=(p==5)?6:(p==6)?5:(p==7)?0:(p==1 || p==3)?7:3;
        Case c={3,3,ms[k],2,INT32_MAX,(k+p)%6,pat,p,0,1,0,0}; run(c);
    }
    for(int m=0;m<=2;m+=2) for(int n=m;n<=5;n++) for(int imag=0;imag<2;imag++) {
        Case c={5,3,m,3,1,(n+imag)%6,2,0,0,1,n,imag}; run(c);
    }
    for(int m=1;m<=8;m++) {
        Case c={8,2,m,2,0,m%6,9,0,0,1,0,0}; run(c);
    }
    for(int m=0;m<=3;m++) {
        Case c={5,5,m,2,-7,m%6,3,(m==2)?2:0,0,4,0,0}; run(c);
    }
    parallel_case=1;
    Case pc={5,3,2,2,0,4,3,0,0,1,0,0}; run(pc);
    parallel_case=0;
    fclose(native_file); fclose(reference_file); fclose(input_file);
#ifdef SPCIMPFINIT_FREEZE_ONLY
    const char *role="REFERENCE PREPARATION";
#else
    const char *role="CRITICAL PASS";
#endif
    printf("SPCIMPFINIT %s calls=%" PRIu64 " m0=%" PRIu64 " mpositive=%" PRIu64
           " empty=%" PRIu64 " returned_guard_bytes=%" PRIu64 " science_values=%" PRIu64
           " protected_calls=%" PRIu64 " AAPCS=%" PRIu64 " rounding_witnesses=%" PRIu64
           " parallel_native_calls=%" PRIu64 " differing_bytes=0 FPCR=%016" PRIx64 "\n",
           role,calls,zero_mode_calls,positive_mode_calls,empty_calls,returned_bytes,
           science_values,protected_calls,abi_calls,rounding_witnesses,parallel_native_calls,fpcr());
    return 0;
}

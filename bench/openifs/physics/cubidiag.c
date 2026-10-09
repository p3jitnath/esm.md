/* Verify the complete supplied lower-bidiagonal convection solve.
 * Known solutions, long-double residuals and protected capacities complement
 * exact unchanged-source agreement. No driver computes a missing stage. */
#define _GNU_SOURCE
#include <errno.h>
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#define ARGS const int32_t *ks,const int32_t *ke,const int32_t *np,const int32_t *nl, \
 const int32_t *top,const int32_t *mask,const double *a,const double *b,const double *r,double *u
extern void cubidiag_(ARGS);
extern void cubidiag_assembly_(ARGS) __attribute__((weak));
extern void cubidiag_checked(ARGS);
static const uint64_t guard=UINT64_C(0x316279436879abcd);
static uint64_t checked_rows,known_rows,zero_rows,abi_calls,output_bytes;
static int reciprocal_witness;
static void fail(const char *s) {fprintf(stderr,"CUBIDIAG check failed: %s\n",s);exit(2);}
static void transfer(FILE *f,void *p,size_t n,int write) {
 if(n && (write?fwrite(p,1,n,f):fread(p,1,n,f))!=n)fail("corpus or result I/O");
}
static uint64_t bits(double v) {uint64_t b;memcpy(&b,&v,8);return b;}
static uint64_t control(void) {uint64_t b;__asm__ volatile("mrs %0,fpcr":"=r"(b));return b;}
struct buffer {void *base,*rw,*data;size_t mapped,rw_size,bytes;};
static struct buffer buffer(size_t n) {
 size_t page=(size_t)sysconf(_SC_PAGESIZE),rw=(n+8+page-1)/page*page;
 void *p=mmap(NULL,rw+2*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(p==MAP_FAILED)fail("protected allocation");
 void *q=(char *)p+page;if(mprotect(q,rw,PROT_READ|PROT_WRITE))fail("allocation protection");
 void *d=(char *)q+rw-n;memcpy((char *)d-8,&guard,8);
 return (struct buffer){p,q,d,rw+2*page,rw,n};
}
static void readonly(struct buffer b) {if(mprotect(b.rw,b.rw_size,PROT_READ))fail("input protection");}
static void release(struct buffer b) {if(munmap(b.base,b.mapped))fail("unmap");}
static int selected(const int32_t h[8],const int32_t *top,const int32_t *mask,int j,int k) {
 size_t i=(size_t)k*h[1]+j;
 return k>=1 && j>=h[3]-1 && j<h[4] && mask[i] && k+1>=top[j]-1;
}
static double target_value(int pattern,int j,int k) {
 if(pattern==0)return 8.0;
 if(pattern==1)return 250.0+(double)k/4+(double)j/8;
 if(pattern==2)return 1.0/64+(double)k/1024+(double)j/2048;
 if(pattern==3)return (j+k)&1?-0.0:0.0;
 if(pattern==4)return (j+k)&1?-DBL_TRUE_MIN:DBL_TRUE_MIN;
 if(pattern==6)return 0.25;
 return -4.0+(double)k/8-(double)j/16;
}
static void generate(FILE *f,int number,int np,int nl,int ks,int ke,int pattern,int mm,int tm) {
 int32_t h[8]={number,np,nl,ks,ke,pattern,mm,tm};double eps=1e-35;
 size_t n=(size_t)np*nl;int32_t *top=malloc((size_t)np*4),*mask=malloc(n*4+4);
 double *a=malloc(n*8+8),*b=malloc(n*8+8),*r=malloc(n*8+8),*u=malloc(n*8+8),*target=calloc(n+1,8);
 if(!top||!mask||!a||!b||!r||!u||!target)fail("generation allocation");
 for(int j=0;j<np;++j)top[j]=tm==1?2+j%4:tm==2?1:tm==3?nl+2:tm==4?nl+1:3;
 if(pattern==7)for(int j=0;j<np;++j)top[j]=-99;
 for(int k=0;k<nl;++k)for(int j=0;j<np;++j) {
  size_t i=(size_t)k*np+j;
  mask[i]=mm==1?0:mm==2?((j+k)%3!=0):mm==3?(k!=6 && k!=11):1;
  if(pattern==7)mask[i]=0;
  if(pattern==8)top[j]=nl+2;
  a[i]=-(0.125+(double)(j%3)/8);b[i]=1.0-a[i];u[i]=(i&1)?-17.25:23.5;r[i]=0;
  if(pattern>=3 && pattern<=6){a[i]=(pattern==3 && (i&1))?-0.0:0.0;b[i]=pattern==5?10.0:pattern==6?0.0:1.0;}
  if(selected(h,top,mask,j,k))target[i]=target_value(pattern,j,k);
 }
 for(int k=0;k<nl;++k)for(int j=0;j<np;++j) {
  size_t i=(size_t)k*np+j;int active=selected(h,top,mask,j,k);
  if(active) {
   double diagonal=b[i]+eps;
   r[i]=diagonal*target[i];
   if(k+1>top[j]-1)r[i]=r[i]+a[i]*target[i-np];
   if(pattern==3 || pattern==4)r[i]=target[i];
   if(pattern==5)r[i]=3.0;
  } else {
   uint64_t nan=UINT64_C(0x7ff8123456789000)+(uint64_t)i;
   memcpy(&a[i],&nan,8);memcpy(&b[i],&nan,8);memcpy(&r[i],&nan,8);
  }
 }
 transfer(f,h,sizeof h,1);transfer(f,&eps,8,1);transfer(f,top,(size_t)np*4,1);transfer(f,mask,n*4,1);
 transfer(f,a,n*8,1);transfer(f,b,n*8,1);transfer(f,r,n*8,1);transfer(f,u,n*8,1);transfer(f,target,n*8,1);
 free(top);free(mask);free(a);free(b);free(r);free(u);free(target);
}
static void create(const char *path) {
 FILE *f=fopen(path,"wb");if(!f)fail("create corpus");char magic[8]="CUBI0001";uint32_t count=0;
 transfer(f,magic,8,1);transfer(f,&count,4,1);
 const int widths[4]={1,3,5,24};
 for(int p=0;p<10;++p)for(int w=0;w<4;++w)for(int l=0;l<2;++l)
  generate(f,++count,widths[w],l?19:3,1,widths[w],p,0,0);
 for(int mm=0;mm<4;++mm)for(int tm=0;tm<5;++tm)
  generate(f,++count,5,19,2,4,(mm+tm)%3,mm,tm);
 generate(f,++count,3,0,1,3,0,0,0);generate(f,++count,3,1,1,3,1,0,0);
 generate(f,++count,5,19,3,2,2,0,0);generate(f,++count,1,2,1,1,9,0,2);
 generate(f,++count,24,19,24,24,2,3,1);generate(f,++count,5,19,1,1,0,2,4);
 if(fseek(f,8,SEEK_SET))fail("corpus count seek");transfer(f,&count,4,1);if(fclose(f))fail("corpus close");
 printf("CUBIDIAG CORPUS cases=%u\n",count);
}
static void scientific(const int32_t h[8],const int32_t *top,const int32_t *mask,const double *a,const double *b,const double *r,const double *u,const double *target) {
 for(int k=0;k<h[2];++k)for(int j=0;j<h[1];++j) {
  size_t i=(size_t)k*h[1]+j;
  if(!selected(h,top,mask,j,k)){if(bits(u[i])!=0)fail("complete positive-zero stage");++zero_rows;continue;}
  if(!isfinite(u[i]))fail("finite solution");
  double diagonal=b[i]+1e-35;
  long double left=(long double)diagonal*u[i],previous=0;
  if(k+1>top[j]-1)previous=(long double)a[i]*u[i-h[1]];
  long double scale=fabsl(left)+fabsl(previous)+fabsl((long double)r[i]);
  long double limit=128.0L*DBL_EPSILON*fmaxl(1.0L,scale)+8.0L*DBL_TRUE_MIN;
  if(fabsl(left+previous-(long double)r[i])>limit)fail("regularised triangular residual");++checked_rows;
  if(h[5]!=5) {
   long double known_limit=256.0L*DBL_EPSILON*fmaxl(1,h[2])*fmaxl(1,fabsl((long double)target[i]))+8.0L*DBL_TRUE_MIN;
   if(fabsl((long double)u[i]-target[i])>known_limit)fail("independent manufactured solution");++known_rows;
  }
  if(h[5]==1 && u[i]<=0)fail("positive manufactured temperature");
  if(h[5]==2 && (u[i]<0 || u[i]>1))fail("manufactured moisture bounds");
  if(h[5]==5 && k+1==top[j]-1) {
   volatile double three=3.0,ten=10.0;
   double reciprocal=three*(1.0/ten),division=three/ten;
   if(bits(u[i])!=bits(reciprocal)||bits(reciprocal)==bits(division))fail("reciprocal then multiply witness");reciprocal_witness=1;
  }
 }
}
static void execute(const char *path,const char *prefix,int native) {
 if(native && !cubidiag_assembly_)fail("native body absent");
 uint64_t fp=control();if(fp&UINT64_C(0x03c80000))fail("FPCR rounding or underflow");
 FILE *f=fopen(path,"rb");if(!f)fail("open corpus");char magic[8];uint32_t count;
 transfer(f,magic,8,0);transfer(f,&count,4,0);if(memcmp(magic,"CUBI0001",8))fail("corpus magic");
 char name[1024];snprintf(name,sizeof name,"%s-fortran.bin",prefix);FILE *rf=fopen(name,"wb");
 FILE *af=NULL;if(native){snprintf(name,sizeof name,"%s-assembly.bin",prefix);af=fopen(name,"wb");}
 if(!rf||(native&&!af))fail("result open");
 for(uint32_t q=0;q<count;++q) {
  int32_t h[8],before[8];double eps;transfer(f,h,sizeof h,0);memcpy(before,h,sizeof h);transfer(f,&eps,8,0);
  if(h[0]!=(int32_t)q+1||h[1]<=0||h[2]<0||bits(eps)!=bits(1e-35))fail("corpus record");
  size_t n=(size_t)h[1]*h[2],sizes[6]={(size_t)h[1]*4,n*4,n*8,n*8,n*8,n*8};struct buffer b[6];
  for(int d=0;d<6;++d){b[d]=buffer(sizes[d]);transfer(f,b[d].data,sizes[d],0);if(d<5)readonly(b[d]);}
  double *target=malloc(n*8+8);if(!target)fail("target allocation");transfer(f,target,n*8,0);
  struct buffer shadow=buffer(n*8);memcpy(shadow.data,b[5].data,n*8);
  cubidiag_(&h[3],&h[4],&h[1],&h[2],b[0].data,b[1].data,b[2].data,b[3].data,b[4].data,shadow.data);
  if(memcmp(h,before,sizeof h)||control()!=fp)fail("source changed scalar input or FPCR");
  if(memcmp((char *)shadow.data-8,&guard,8))fail("source leading output guard");
  scientific(h,b[0].data,b[1].data,b[2].data,b[3].data,b[4].data,shadow.data,target);
  transfer(rf,(char *)shadow.data-8,n*8+8,1);output_bytes+=n*8+8;
  if(native) {
   cubidiag_checked(&h[3],&h[4],&h[1],&h[2],b[0].data,b[1].data,b[2].data,b[3].data,b[4].data,b[5].data);++abi_calls;
   if(memcmp(h,before,sizeof h)||control()!=fp)fail("native changed scalar input or FPCR");
   if(memcmp((char *)shadow.data-8,(char *)b[5].data-8,n*8+8)) {
    const unsigned char *a=(const unsigned char *)shadow.data-8,*v=(const unsigned char *)b[5].data-8;size_t z=0;while(z<n*8+8&&a[z]==v[z])++z;
    size_t cell=z>=8?(z-8)/8:0;uint64_t source=0,asmv=0;
    memcpy(&source,(char *)shadow.data+cell*8,8);memcpy(&asmv,(char *)b[5].data+cell*8,8);
    fprintf(stderr,"CUBIDIAG mismatch case=%d level=%zu column=%zu byte=%zu source=%016" PRIx64 " assembly=%016" PRIx64 "\n",h[0],cell/h[1]+1,cell%h[1]+1,z,source,asmv);fail("exact output bytes");
   }
   transfer(af,(char *)b[5].data-8,n*8+8,1);
  }
  for(int d=0;d<6;++d)release(b[d]);release(shadow);free(target);
 }
 if(fgetc(f)!=EOF)fail("corpus trailing bytes");if(fclose(f)||fclose(rf)||(af&&fclose(af)))fail("result close");
 if(!reciprocal_witness)fail("missing arithmetic-order witness");
 printf("CUBIDIAG %s PASS cases=%u output_guard_bytes=%" PRIu64 " differing_bytes=0 residual_rows=%" PRIu64 " known_rows=%" PRIu64 " positive_zero_rows=%" PRIu64 " direct_abi_calls=%" PRIu64 " FPCR=%016" PRIx64 "\n",native?"NATIVE":"REFERENCE",count,output_bytes,checked_rows,known_rows,zero_rows,abi_calls,fp);
}
int main(int argc,char **argv) {
 if(argc!=4 || (strcmp(argv[1],"--freeze")&&strcmp(argv[1],"--verify")))fail("use --freeze|--verify corpus result-prefix");
 int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(!hook)fail("profiling flag");*hook=0;
 int native=!strcmp(argv[1],"--verify");if(!native)create(argv[2]);execute(argv[2],argv[3],native);return 0;
}

/* Direct saved-register observer. Stack slots carry PR and PU unchanged. */
__asm__(
 ".text\n"
 ".p2align 4\n"
 ".global cubidiag_checked\n"
 ".type cubidiag_checked,%function\n"
 "cubidiag_checked:\n"
 "sub sp,sp,#192\n"
 "stp x19,x20,[sp,#16]\n"
 "stp x21,x22,[sp,#32]\n"
 "stp x23,x24,[sp,#48]\n"
 "stp x25,x26,[sp,#64]\n"
 "stp x27,x28,[sp,#80]\n"
 "stp x29,x30,[sp,#96]\n"
 "stp d8,d9,[sp,#112]\n"
 "stp d10,d11,[sp,#128]\n"
 "stp d12,d13,[sp,#144]\n"
 "stp d14,d15,[sp,#160]\n"
 "mov x9,sp\n"
 "str x9,[sp,#176]\n"
 "ldp x9,x10,[sp,#192]\n"
 "stp x9,x10,[sp]\n"
 "mov x19,#0x313\n"
 "mov x20,#0x314\n"
 "mov x21,#0x315\n"
 "mov x22,#0x316\n"
 "mov x23,#0x317\n"
 "mov x24,#0x318\n"
 "mov x25,#0x319\n"
 "mov x26,#0x31a\n"
 "mov x27,#0x31b\n"
 "mov x28,#0x31c\n"
 "mov x29,#0x31d\n"
 "fmov d8,#1.0\n"
 "fmov d9,#2.0\n"
 "fmov d10,#3.0\n"
 "fmov d11,#4.0\n"
 "fmov d12,#5.0\n"
 "fmov d13,#6.0\n"
 "fmov d14,#7.0\n"
 "fmov d15,#8.0\n"
 "bl cubidiag_assembly_\n"
 "cmp x19,#0x313\n"
 "b.ne .Lcub_abi_failure\n"
 "cmp x20,#0x314\n"
 "b.ne .Lcub_abi_failure\n"
 "cmp x21,#0x315\n"
 "b.ne .Lcub_abi_failure\n"
 "cmp x22,#0x316\n"
 "b.ne .Lcub_abi_failure\n"
 "cmp x23,#0x317\n"
 "b.ne .Lcub_abi_failure\n"
 "cmp x24,#0x318\n"
 "b.ne .Lcub_abi_failure\n"
 "cmp x25,#0x319\n"
 "b.ne .Lcub_abi_failure\n"
 "cmp x26,#0x31a\n"
 "b.ne .Lcub_abi_failure\n"
 "cmp x27,#0x31b\n"
 "b.ne .Lcub_abi_failure\n"
 "cmp x28,#0x31c\n"
 "b.ne .Lcub_abi_failure\n"
 "cmp x29,#0x31d\n"
 "b.ne .Lcub_abi_failure\n"
 "fmov d16,#1.0\n"
 "fcmp d8,d16\n"
 "b.ne .Lcub_abi_failure\n"
 "fmov d16,#2.0\n"
 "fcmp d9,d16\n"
 "b.ne .Lcub_abi_failure\n"
 "fmov d16,#3.0\n"
 "fcmp d10,d16\n"
 "b.ne .Lcub_abi_failure\n"
 "fmov d16,#4.0\n"
 "fcmp d11,d16\n"
 "b.ne .Lcub_abi_failure\n"
 "fmov d16,#5.0\n"
 "fcmp d12,d16\n"
 "b.ne .Lcub_abi_failure\n"
 "fmov d16,#6.0\n"
 "fcmp d13,d16\n"
 "b.ne .Lcub_abi_failure\n"
 "fmov d16,#7.0\n"
 "fcmp d14,d16\n"
 "b.ne .Lcub_abi_failure\n"
 "fmov d16,#8.0\n"
 "fcmp d15,d16\n"
 "b.ne .Lcub_abi_failure\n"
 "mov x9,sp\n"
 "ldr x10,[sp,#176]\n"
 "cmp x9,x10\n"
 "b.ne .Lcub_abi_failure\n"
 "tst x9,#15\n"
 "b.ne .Lcub_abi_failure\n"
 "ldp d8,d9,[sp,#112]\n"
 "ldp d10,d11,[sp,#128]\n"
 "ldp d12,d13,[sp,#144]\n"
 "ldp d14,d15,[sp,#160]\n"
 "ldp x19,x20,[sp,#16]\n"
 "ldp x21,x22,[sp,#32]\n"
 "ldp x23,x24,[sp,#48]\n"
 "ldp x25,x26,[sp,#64]\n"
 "ldp x27,x28,[sp,#80]\n"
 "ldp x29,x30,[sp,#96]\n"
 "add sp,sp,#192\n"
 "ret\n"
 ".Lcub_abi_failure:\n"
 "adrp x0,.Lcub_abi_message\n"
 "add x0,x0,:lo12:.Lcub_abi_message\n"
 "bl puts\n"
 "mov w0,#3\n"
 "bl _Exit\n"
 ".size cubidiag_checked,.-cubidiag_checked\n"
 ".section .rodata\n"
 ".Lcub_abi_message:\n"
 ".asciz \"CUBIDIAG direct ABI failure\"\n"
 ".text\n"
);

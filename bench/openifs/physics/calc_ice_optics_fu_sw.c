/* Independent optical limits and powers-based evaluation complement exact
 * source agreement, complete protected arrays and the direct ABI observer. */
#define _GNU_SOURCE
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
struct dim {int64_t stride,lower,upper;};
struct descriptor {double *data;int64_t offset,element_length;uint64_t type;int64_t span;struct dim dim[2];};
_Static_assert(sizeof(struct descriptor)==88,"GNU rank2 descriptor");
#define ARGS const int32_t *nb,const struct descriptor *c,const double *iwp,const double *re,double *od,double *so,double *g
extern void __radiation_ice_optics_fu_MOD_calc_ice_optics_fu_sw(ARGS);
extern void calc_ice_optics_fu_sw_assembly_(ARGS) __attribute__((weak));
extern void ice_fu_sw_checked(ARGS);
static const uint64_t guard=UINT64_C(0x701c76429185abcd);
static uint64_t physical_bands,independent_bands,negative_zeros,subnormal_values,output_bytes,abi_calls;
static int order_witness;
static void fail(const char *s){fprintf(stderr,"ICE FU SW critical failed: %s\n",s);exit(2);}
static void transfer(FILE *f,void *p,size_t n,int write){if(n&&(write?fwrite(p,1,n,f):fread(p,1,n,f))!=n)fail("binary corpus/result I/O");}
static uint64_t bits(double v){uint64_t b;memcpy(&b,&v,8);return b;}
static uint64_t control(void){uint64_t b;__asm__ volatile("mrs %0,fpcr":"=r"(b));return b;}
struct buffer {void *base,*rw,*data;size_t mapped,rw_size,bytes;};
static struct buffer buffer(size_t n){size_t page=(size_t)sysconf(_SC_PAGESIZE),rw=(n+8+page-1)/page*page;void *p=mmap(NULL,rw+2*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);if(p==MAP_FAILED)fail("protected allocation");void *q=(char *)p+page;if(mprotect(q,rw,PROT_READ|PROT_WRITE))fail("page protection");void *d=(char *)q+rw-n;memcpy((char *)d-8,&guard,8);return (struct buffer){p,q,d,rw+2*page,rw,n};}
static void readonly(struct buffer b){if(mprotect(b.rw,b.rw_size,PROT_READ))fail("read-only protection");}
static void release(struct buffer b){if(munmap(b.base,b.mapped))fail("unmap");}
static double coefficient(const struct descriptor *d,int band,int col){return d->data[(int64_t)band*d->dim[0].stride+(int64_t)col*d->dim[1].stride];}
static void generate(FILE *f,int number,int nb,int layout,int pattern,int radius_index,int water_index,const double *actual){
 int rows=nb>0?nb:3;if(pattern==1)rows+=2;
 int64_t s0=layout==1?2:layout==2?-1:1,s1=layout==1?2*rows+1:layout==3?2*rows:layout==4?-rows:rows;
 uint64_t base=layout==2?(uint64_t)rows-1:layout==4?(uint64_t)9*rows:0;
 int64_t low=(s0<0?(rows-1)*s0:0)+(s1<0?9*s1:0),high=(s0>0?(rows-1)*s0:0)+(s1>0?9*s1:0);
 uint64_t cells=(uint64_t)(high-low+1);int32_t h[8]={number,nb,rows,layout,pattern,radius_index,water_index,0};
 struct descriptor desc={NULL,-(int64_t)(-2*s0+3*s1),8,UINT64_C(0x0000030200000000),8,{{s0,-2,rows-3},{s1,3,12}}};
 double params[2]={water_index==0?0:water_index==1?0.0625:water_index==2?0.125:1.0,radius_index==0?2e-5:radius_index==1?4e-5:radius_index==2?8e-5:1.2e-4};
 if(pattern==6){params[1]=radius_index==0?1.4911010295275469e-5:radius_index==3?0.0001006756:params[1];if(water_index==3)params[0]=4096.0398913412737;}
 if(pattern==3)params[0]=-0.0;if(pattern==4)params[0]=DBL_TRUE_MIN;if(pattern==5){params[0]=0.1;params[1]=0.1;}
 double *matrix=malloc(cells*8);if(!matrix)fail("matrix generation");
 for(uint64_t i=0;i<cells;++i){uint64_t v=UINT64_C(0x7ff8ac3500000000)+i;memcpy(&matrix[i],&v,8);}
 desc.data=matrix+base;
 for(int band=0;band<nb;++band){double c[10]={0};c[0]=1.0+(double)band/8;c[2]=0.25;c[6]=0.5;
  if(pattern==1){double d0=256,alpha=c[0];c[1]=alpha*16;c[2]=0.125;c[3]=0.0625/d0;c[4]=0.03125/(d0*d0);c[5]=0.015625/(d0*d0*d0);c[6]=0.25;c[7]=0.125/d0;c[8]=0.0625/(d0*d0);c[9]=0.03125/(d0*d0*d0);}
  if(pattern==3){c[6]=-0.0;c[7]=-0.0;c[8]=-0.0;c[9]=-0.0;}
  if(pattern==4){c[0]=0.001;c[2]=0;c[6]=DBL_TRUE_MIN;}
  if(pattern==5){c[0]=0;c[1]=1;c[2]=0;c[6]=0.5;}
  if(pattern==7)c[6]=1.5;if(pattern==8)c[6]=1.0;if(pattern==9)c[6]=0x1.fffffffffffffp-1;
  if(pattern==6)for(int col=0;col<10;++col)c[col]=actual[(size_t)col*nb+band];
  for(int col=0;col<10;++col)desc.data[(int64_t)band*s0+(int64_t)col*s1]=c[col];
 }
 transfer(f,h,sizeof h,1);transfer(f,params,16,1);transfer(f,&cells,8,1);transfer(f,&base,8,1);
 unsigned char raw[88];memcpy(raw,&desc,88);memset(raw,0,8);transfer(f,raw,88,1);transfer(f,matrix,cells*8,1);
 for(int out=0;out<3;++out)for(int band=0;band<nb;++band){double incoming=(band&1)?-13.25:17.5;transfer(f,&incoming,8,1);}
 free(matrix);
}
static void create(const char *path,const char *table_directory){
 FILE *f=fopen(path,"wb");if(!f)fail("create corpus");char magic[8]="ICESW001";uint32_t count=0;transfer(f,magic,8,1);transfer(f,&count,4,1);
 const int bands[7]={0,1,3,14,16,17,24};
 for(int p=0;p<10;++p){if(p==6)continue;for(int layout=0;layout<5;++layout)for(int width=0;width<7;++width)generate(f,++count,bands[width],layout,p,width%4,p==2?0:1,NULL);}
 int nb=14;char name[1024];snprintf(name,sizeof name,"%s/ice-fu-sw-coefficients-1.bin",table_directory);FILE *a=fopen(name,"rb");if(!a)fail("configured table archive");double *values=malloc((size_t)nb*10*8);if(!values)fail("table allocation");transfer(a,values,(size_t)nb*10*8,0);if(fgetc(a)!=EOF||fclose(a))fail("complete table length");for(int re=0;re<4;++re)for(int w=0;w<4;++w)generate(f,++count,nb,(re+w)%5,6,re,w,values);free(values);
 if(fseek(f,8,SEEK_SET))fail("case count seek");transfer(f,&count,4,1);if(fclose(f))fail("corpus close");printf("ICE FU SW CORPUS cases=%u\n",count);
}
static void independent(int pattern,int nb,const struct descriptor *d,double iwp,double re,double *u[3]){
 long double diameter=(long double)re*(1000000.0L/0.64952L),d2=diameter*diameter,d3=d2*diameter,mass=(long double)iwp*1000;
 for(int band=0;band<nb;++band){long double c[10];for(int k=0;k<10;++k)c[k]=coefficient(d,band,k);
  long double absorb=c[2]+diameter*c[3]+d2*c[4]+d3*c[5],asym=c[6]+diameter*c[7]+d2*c[8]+d3*c[9];
  long double known[3]={mass*(c[0]+c[1]/diameter),0,fminl(asym,1)};known[1]=known[0]*(1-absorb);
  for(int q=0;q<3;++q){if(!isfinite(u[q][band])||!isfinite(known[q]))fail("finite optical result");long double limit=8192.0L*DBL_EPSILON*fmaxl(1,fabsl(known[q]))+8.0L*DBL_TRUE_MIN;if(fabsl((long double)u[q][band]-known[q])>limit)fail("independent powers-based ice optics");uint64_t v=bits(u[q][band]);negative_zeros+=v==UINT64_C(0x8000000000000000);subnormal_values+=!(v&UINT64_C(0x7ff0000000000000))&&(v&UINT64_C(0x000fffffffffffff));}++independent_bands;
  if(pattern==0||pattern==1||pattern==2||pattern==6||pattern>=7){double limit=256*DBL_EPSILON*fmax(1,fabs(u[0][band])+fabs(u[1][band]));if(u[0][band]<-limit||u[1][band]<-limit||u[1][band]>u[0][band]+limit||u[2][band]<-1-256*DBL_EPSILON||u[2][band]>1+256*DBL_EPSILON)fail("physical absorption/scattering/asymmetry bounds");++physical_bands;}
  if(pattern==0||pattern==2||pattern>=7){double alpha=1+(double)band/8,expected_g=pattern==7||pattern==8?1.0:pattern==9?0x1.fffffffffffffp-1:0.5;if(bits(u[0][band])!=bits((iwp*1000)*alpha)||bits(u[1][band])!=bits(((iwp*1000)*alpha)*0.75)||bits(u[2][band])!=bits(expected_g))fail("known optics, cap and water-path scaling");}
  if(pattern==5){volatile double radius=0.1,numerator=1000000.0,denominator=0.64952,mass64=iwp*1000;double ordered_d=radius*(numerator/denominator),regrouped_d=(radius*numerator)/denominator,expected=mass64*(1.0/ordered_d),wrong=mass64*(1.0/regrouped_d);if(bits(ordered_d)==bits(regrouped_d)||bits(expected)==bits(wrong)||bits(u[0][band])!=bits(expected))fail("ordered diameter conversion witness");order_witness=1;}
 }
}
static void execute(const char *path,const char *prefix,int native){
 if(native&&!calc_ice_optics_fu_sw_assembly_)fail("native body absent");if(control()!=0)fail("strict starting FPCR");
 FILE *f=fopen(path,"rb");if(!f)fail("open frozen corpus");char magic[8];uint32_t count;transfer(f,magic,8,0);transfer(f,&count,4,0);if(memcmp(magic,"ICESW001",8))fail("corpus magic");char name[1024];snprintf(name,sizeof name,"%s-fortran.bin",prefix);FILE *rf=fopen(name,"wb");FILE *af=NULL;if(native){snprintf(name,sizeof name,"%s-assembly.bin",prefix);af=fopen(name,"wb");}if(!rf||(native&&!af))fail("open result");
 for(uint32_t q=0;q<count;++q){int32_t h[8],before[8];double params[2];uint64_t cells,base;struct descriptor d;transfer(f,h,sizeof h,0);memcpy(before,h,sizeof h);transfer(f,params,16,0);transfer(f,&cells,8,0);transfer(f,&base,8,0);transfer(f,&d,88,0);if(h[0]!=(int32_t)q+1||h[1]<0||base>=cells)fail("corpus header");
  struct buffer matrix=buffer(cells*8),desc=buffer(88),scalars=buffer(16),outputs[3],shadow[3];transfer(f,matrix.data,cells*8,0);d.data=(double *)matrix.data+base;memcpy(desc.data,&d,88);memcpy(scalars.data,params,16);readonly(matrix);readonly(desc);readonly(scalars);
  for(int z=0;z<3;++z){outputs[z]=buffer((size_t)h[1]*8);shadow[z]=buffer((size_t)h[1]*8);transfer(f,outputs[z].data,(size_t)h[1]*8,0);}
  const double *v=scalars.data;__radiation_ice_optics_fu_MOD_calc_ice_optics_fu_sw(&h[1],desc.data,&v[0],&v[1],shadow[0].data,shadow[1].data,shadow[2].data);
  if(memcmp(h,before,sizeof h)||control()!=0)fail("source changed scalar/FPCR");double *reference[3]={shadow[0].data,shadow[1].data,shadow[2].data};independent(h[4],h[1],desc.data,v[0],v[1],reference);
  for(int z=0;z<3;++z){if(memcmp((char *)shadow[z].data-8,&guard,8))fail("source output guard");transfer(rf,(char *)shadow[z].data-8,(size_t)h[1]*8+8,1);output_bytes+=(size_t)h[1]*8+8;}
  if(native){ice_fu_sw_checked(&h[1],desc.data,&v[0],&v[1],outputs[0].data,outputs[1].data,outputs[2].data);++abi_calls;if(memcmp(h,before,sizeof h)||control()!=0)fail("native changed scalar/FPCR");for(int z=0;z<3;++z){if(memcmp((char *)shadow[z].data-8,(char *)outputs[z].data-8,(size_t)h[1]*8+8)){int k=0;double *x=shadow[z].data,*y=outputs[z].data;while(k<h[1]&&bits(x[k])==bits(y[k]))++k;fprintf(stderr,"ICE FU SW mismatch case=%d field=%d band=%d source=%016" PRIx64 " assembly=%016" PRIx64 "\n",h[0],z+1,k+1,k<h[1]?bits(x[k]):0,k<h[1]?bits(y[k]):0);fail("complete output/guard bytes");}transfer(af,(char *)outputs[z].data-8,(size_t)h[1]*8+8,1);}}
  for(int z=0;z<3;++z){release(outputs[z]);release(shadow[z]);}release(matrix);release(desc);release(scalars);
 }
 if(fgetc(f)!=EOF||fclose(f)||fclose(rf)||(af&&fclose(af)))fail("complete corpus/result close");if(!order_witness||!negative_zeros||!subnormal_values)fail("missing critical arithmetic edge");
 printf("ICE FU SW %s PASS cases=%u complete_output_guard_bytes=%" PRIu64 " differing_bytes=0 independent_band_points=%" PRIu64 " physical_band_points=%" PRIu64 " negative_zero_values=%" PRIu64 " subnormal_values=%" PRIu64 " direct_ABI_calls=%" PRIu64 " FPCR=0000000000000000\n",native?"NATIVE":"SOURCE",count,output_bytes,independent_bands,physical_bands,negative_zeros,subnormal_values,abi_calls);
}
int main(int argc,char **argv){if(argc<4||argc>5||(strcmp(argv[1],"--freeze")&&strcmp(argv[1],"--verify")))fail("use --freeze corpus prefix table-directory or --verify corpus prefix");int native=!strcmp(argv[1],"--verify");if(!native){if(argc!=5)fail("configured table directory");create(argv[2],argv[4]);}execute(argv[2],argv[3],native);return 0;}

/* Direct saved-register observer. All seven register arguments remain unchanged. */
__asm__(
 ".text\n"
 ".p2align 4\n"
 ".global ice_fu_sw_checked\n"
 ".type ice_fu_sw_checked,%function\n"
 "ice_fu_sw_checked:\n"
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
 "bl calc_ice_optics_fu_sw_assembly_\n"
 "cmp x19,#0x313\n"
 "b.ne .Lice_abi_failure\n"
 "cmp x20,#0x314\n"
 "b.ne .Lice_abi_failure\n"
 "cmp x21,#0x315\n"
 "b.ne .Lice_abi_failure\n"
 "cmp x22,#0x316\n"
 "b.ne .Lice_abi_failure\n"
 "cmp x23,#0x317\n"
 "b.ne .Lice_abi_failure\n"
 "cmp x24,#0x318\n"
 "b.ne .Lice_abi_failure\n"
 "cmp x25,#0x319\n"
 "b.ne .Lice_abi_failure\n"
 "cmp x26,#0x31a\n"
 "b.ne .Lice_abi_failure\n"
 "cmp x27,#0x31b\n"
 "b.ne .Lice_abi_failure\n"
 "cmp x28,#0x31c\n"
 "b.ne .Lice_abi_failure\n"
 "cmp x29,#0x31d\n"
 "b.ne .Lice_abi_failure\n"
 "fmov d16,#1.0\n"
 "fcmp d8,d16\n"
 "b.ne .Lice_abi_failure\n"
 "fmov d16,#2.0\n"
 "fcmp d9,d16\n"
 "b.ne .Lice_abi_failure\n"
 "fmov d16,#3.0\n"
 "fcmp d10,d16\n"
 "b.ne .Lice_abi_failure\n"
 "fmov d16,#4.0\n"
 "fcmp d11,d16\n"
 "b.ne .Lice_abi_failure\n"
 "fmov d16,#5.0\n"
 "fcmp d12,d16\n"
 "b.ne .Lice_abi_failure\n"
 "fmov d16,#6.0\n"
 "fcmp d13,d16\n"
 "b.ne .Lice_abi_failure\n"
 "fmov d16,#7.0\n"
 "fcmp d14,d16\n"
 "b.ne .Lice_abi_failure\n"
 "fmov d16,#8.0\n"
 "fcmp d15,d16\n"
 "b.ne .Lice_abi_failure\n"
 "mov x9,sp\n"
 "ldr x10,[sp,#176]\n"
 "cmp x9,x10\n"
 "b.ne .Lice_abi_failure\n"
 "tst x9,#15\n"
 "b.ne .Lice_abi_failure\n"
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
 ".Lice_abi_failure:\n"
 "adrp x0,.Lice_abi_message\n"
 "add x0,x0,:lo12:.Lice_abi_message\n"
 "bl puts\n"
 "mov w0,#3\n"
 "bl _Exit\n"
 ".size ice_fu_sw_checked,.-ice_fu_sw_checked\n"
 ".section .rodata\n"
 ".Lice_abi_message:\n"
 ".asciz \"ICE FU SW direct ABI failure\"\n"
 ".text\n"
);

/* Verify complete scalar delta scaling and independently check optical limits.
 * All three values are dimensionless. Each eight-byte argument is mutable.
 * Guard pages and poisoned neighbour bytes check the exact scalar capacity. */
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
void __radiation_cloud_optics_MOD_delta_eddington_scat_od(double *,double *,double *);
void delta_eddington_scat_od_assembly_(double *,double *,double *) __attribute__((weak));
typedef int (*abi_kernel)(double *,double *,double *);
int delta_abi_probe(double *,double *,double *) __attribute__((weak));
static uint64_t cases,independent,physical_points,bytes,abi_calls,positive_zero,signed_zero,subnormal;
static void fail(const char *s){fprintf(stderr,"DELTA critical failed %s\n",s);exit(2);}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
struct guard {unsigned char *mapping;double *value;size_t page;int at_end;};
static struct guard allocate(int at_end){
 size_t page=(size_t)sysconf(_SC_PAGESIZE);
 unsigned char *p=mmap(NULL,3*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(p==MAP_FAILED||mprotect(p+page,page,PROT_READ|PROT_WRITE))fail("protected scalar allocation");
 memset(p+page,0xa5,page);
 struct guard b={p,(double *)(p+page+(at_end?page-8:0)),page,at_end};return b;
}
static void release(struct guard *b){
 const unsigned char *p=b->mapping+b->page;
 for(size_t q=0;q<b->page;++q)if(q<(b->at_end?b->page-8:0)||q>=(b->at_end?b->page:8))if(p[q]!=0xa5)fail("unchanged poisoned scalar neighbours");
 if(munmap(b->mapping,3*b->page))fail("release scalar pages");
}
static void independent_check(const double before[3],const double after[3],uint32_t physical){
 const long double t=before[0],s=before[1],g=before[2];
 const long double absorption=t-s,retained=s*(1-g)*(1+g);
 const long double expected[2]={absorption+retained,retained};
 const long double tol=8192*DBL_EPSILON*fmaxl(1,fabsl(t)+fabsl(s))+16*DBL_TRUE_MIN;
 for(int k=0;k<3;++k)if(!isfinite(after[k]))fail("finite frozen arithmetic domain");
 for(int k=0;k<2;++k)if(fabsl((long double)after[k]-expected[k])>tol)fail("independent forward-lobe removal");
 if(fabsl(((long double)after[0]-after[1])-absorption)>tol)fail("absorption invariant");
 if(fabsl((long double)after[2]*(1+g)-g)>8192*DBL_EPSILON*fmaxl(1,fabsl(g))+16*DBL_TRUE_MIN)fail("independent asymmetry identity");
 const long double old_transport=t-s*g;
 const long double new_transport=(long double)after[0]-(long double)after[1]*after[2];
 if(fabsl(new_transport-old_transport)>tol)fail("transport optical-depth invariant");
 independent+=5;
 if(physical){
  if(t< -tol||s< -tol||s>t+tol||g<0||g>1)fail("declared physical input");
  if(after[0]<-tol||after[1]<-tol||after[1]>after[0]+tol||after[2]<0||after[2]>.5+8192*DBL_EPSILON)fail("physical output");
  ++physical_points;
 }
 if(bits(before[2])==0||bits(before[2])==UINT64_C(0x8000000000000000)){
  if(before[0]!=after[0]||memcmp(&before[1],&after[1],8)||memcmp(&before[2],&after[2],8))fail("zero forward-lobe identity and retained signed zeros");
 }
 if(before[2]==0.&&before[0]==0.&&before[1]==0.){
  uint64_t expected_tau=(bits(before[0])==UINT64_C(0x8000000000000000)&&bits(before[1])==0)?UINT64_C(0x8000000000000000):0;
  if(bits(after[0])!=expected_tau)fail("independent subtraction signed-zero rule");
 }
 if(bits(before[0])==1&&bits(before[1])==1&&before[2]==.5){
  if(bits(after[0])!=1||bits(after[1])!=1)fail("known gradual-underflow limit");
 }
 if(before[2]==1.&&before[0]==before[1]&&before[0]>0){
  if(bits(after[0])||bits(after[1])||after[2]!=.5)fail("pure forward-scattering limit");
 }
 if(before[0]==2.&&before[1]==1.&&before[2]==.5){
  if(after[0]!=1.75||after[1]!=.75||fabsl((long double)after[2]-1.L/3.L)>DBL_EPSILON)fail("known partial-scattering solution");
 }
 for(int k=0;k<3;++k){uint64_t z=bits(after[k]);if(z==0)++positive_zero;if(z==UINT64_C(0x8000000000000000))++signed_zero;if((z&UINT64_C(0x7ff0000000000000))==0&&(z&UINT64_C(0xfffffffffffff)))++subnormal;}
}
static void writeall(FILE *f,const void *p,size_t n){if(fwrite(p,1,n,f)!=n)fail("canonical write");}
int main(int argc,char **argv){
 if(argc!=4)fail("arguments corpus source-output native-output");
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("FPCR exactly zero");
 FILE *input=fopen(argv[1],"rb"),*source=fopen(argv[2],"wb");
 FILE *native=delta_eddington_scat_od_assembly_?fopen(argv[3],"wb"):NULL;
 if(!input||!source||(delta_eddington_scat_od_assembly_&&!native))fail("corpus/output open");
 char tag[8];uint64_t count;
 if(fread(tag,1,8,input)!=8||memcmp(tag,"DELTA001",8)||fread(&count,8,1,input)!=1)fail("corpus header");
 for(uint64_t q=0;q<count;++q){
  double before[3];uint32_t physical,reserved;
  if(fread(before,8,3,input)!=3||fread(&physical,4,1,input)!=1||fread(&reserved,4,1,input)!=1||physical>1||reserved)fail("whole corpus record");
  for(int placement=0;placement<2;++placement){
   struct guard ref[3],nat[3];double expected[3],actual[3];
   for(int k=0;k<3;++k){ref[k]=allocate(placement);nat[k]=allocate(placement);memcpy(ref[k].value,&before[k],8);memcpy(nat[k].value,&before[k],8);}
   __radiation_cloud_optics_MOD_delta_eddington_scat_od(ref[0].value,ref[1].value,ref[2].value);
   for(int k=0;k<3;++k)memcpy(&expected[k],ref[k].value,8);
   independent_check(before,expected,physical);
   if(native){
    if(!delta_abi_probe)fail("required immediate ABI observer");
    if(delta_abi_probe(nat[0].value,nat[1].value,nat[2].value))fail("immediate native ABI register preservation");++abi_calls;
    for(int k=0;k<3;++k){memcpy(&actual[k],nat[k].value,8);if(memcmp(&expected[k],&actual[k],8)){fprintf(stderr,"DELTA first mismatch case=%" PRIu64 " placement=%d field=%d source=%016" PRIx64 " native=%016" PRIx64 "\n",q,placement,k+1,bits(expected[k]),bits(actual[k]));fail("complete output bits");}}
   }else memcpy(actual,expected,24);
   int32_t header[2]={placement,(int32_t)physical};
   writeall(source,&q,8);writeall(source,header,8);writeall(source,expected,24);
   if(native){writeall(native,&q,8);writeall(native,header,8);writeall(native,actual,24);}
   for(int k=0;k<3;++k){release(&ref[k]);release(&nat[k]);}
   __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("unchanged FPCR");
   ++cases;bytes+=40;
  }
 }
 if(fgetc(input)!=EOF||fclose(input)||fclose(source)||(native&&fclose(native)))fail("complete corpus and output close");
 printf("DELTA %s PASS cases=%" PRIu64 " complete_bytes=%" PRIu64 " independent=%" PRIu64 " physical=%" PRIu64 " ABI=%" PRIu64 " positive_zeros=%" PRIu64 " signed_zeros=%" PRIu64 " subnormals=%" PRIu64 " differing_bytes=0 FPCR=0\n",native?"NATIVE":"SOURCE",cases,bytes,independent,physical_points,abi_calls,positive_zero,signed_zero,subnormal);
 return 0;
}

/* This observer checks the native ABI immediately, before C can restore it. */
#ifdef DELTA_ABI_OBSERVER
__asm__(".text\n.p2align 2\n.global delta_abi_probe\n.type delta_abi_probe,%function\ndelta_abi_probe:\nsub sp,sp,#176\nstp x19,x20,[sp,#0]\nstp x21,x22,[sp,#16]\nstp x23,x24,[sp,#32]\nstp x25,x26,[sp,#48]\nstp x27,x28,[sp,#64]\nstp x29,x30,[sp,#80]\nstp d8,d9,[sp,#96]\nstp d10,d11,[sp,#112]\nstp d12,d13,[sp,#128]\nstp d14,d15,[sp,#144]\nmov x19,#0x1313\nmov x20,#0x1414\nmov x21,#0x1515\nmov x22,#0x1616\nmov x23,#0x1717\nmov x24,#0x1818\nmov x25,#0x1919\nmov x26,#0x1a1a\nmov x27,#0x1b1b\nmov x28,#0x1c1c\nmov x29,sp\nmov x9,#0x808\nfmov d8,x9\nmov x9,#0x909\nfmov d9,x9\nmov x9,#0xa0a\nfmov d10,x9\nmov x9,#0xb0b\nfmov d11,x9\nmov x9,#0xc0c\nfmov d12,x9\nmov x9,#0xd0d\nfmov d13,x9\nmov x9,#0xe0e\nfmov d14,x9\nmov x9,#0xf0f\nfmov d15,x9\nbl delta_eddington_scat_od_assembly_\nmov x9,sp\ncmp x29,x9\nb.ne .Ldelta_abi_trap\nmov x9,#0x1313\ncmp x19,x9\nb.ne .Ldelta_abi_bad\nmov x9,#0x1414\ncmp x20,x9\nb.ne .Ldelta_abi_bad\nmov x9,#0x1515\ncmp x21,x9\nb.ne .Ldelta_abi_bad\nmov x9,#0x1616\ncmp x22,x9\nb.ne .Ldelta_abi_bad\nmov x9,#0x1717\ncmp x23,x9\nb.ne .Ldelta_abi_bad\nmov x9,#0x1818\ncmp x24,x9\nb.ne .Ldelta_abi_bad\nmov x9,#0x1919\ncmp x25,x9\nb.ne .Ldelta_abi_bad\nmov x9,#0x1a1a\ncmp x26,x9\nb.ne .Ldelta_abi_bad\nmov x9,#0x1b1b\ncmp x27,x9\nb.ne .Ldelta_abi_bad\nmov x9,#0x1c1c\ncmp x28,x9\nb.ne .Ldelta_abi_bad\nfmov x9,d8\nmov x10,#0x808\ncmp x9,x10\nb.ne .Ldelta_abi_bad\nfmov x9,d9\nmov x10,#0x909\ncmp x9,x10\nb.ne .Ldelta_abi_bad\nfmov x9,d10\nmov x10,#0xa0a\ncmp x9,x10\nb.ne .Ldelta_abi_bad\nfmov x9,d11\nmov x10,#0xb0b\ncmp x9,x10\nb.ne .Ldelta_abi_bad\nfmov x9,d12\nmov x10,#0xc0c\ncmp x9,x10\nb.ne .Ldelta_abi_bad\nfmov x9,d13\nmov x10,#0xd0d\ncmp x9,x10\nb.ne .Ldelta_abi_bad\nfmov x9,d14\nmov x10,#0xe0e\ncmp x9,x10\nb.ne .Ldelta_abi_bad\nfmov x9,d15\nmov x10,#0xf0f\ncmp x9,x10\nb.ne .Ldelta_abi_bad\nmrs x9,fpcr\ncbnz x9,.Ldelta_abi_bad\nmov w0,#0\nb .Ldelta_abi_restore\n.Ldelta_abi_bad:\nmov w0,#1\n.Ldelta_abi_restore:\nldp d8,d9,[sp,#96]\nldp d10,d11,[sp,#112]\nldp d12,d13,[sp,#128]\nldp d14,d15,[sp,#144]\nldp x19,x20,[sp,#0]\nldp x21,x22,[sp,#16]\nldp x23,x24,[sp,#32]\nldp x25,x26,[sp,#48]\nldp x27,x28,[sp,#64]\nldp x29,x30,[sp,#80]\nadd sp,sp,#176\nret\n.Ldelta_abi_trap:\nbrk #1\n.size delta_abi_probe,.-delta_abi_probe\n");
#endif

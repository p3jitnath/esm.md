/* Capture the complete gas conversion before direct numerical emission.
 * Input pressure is Pa, temperature is K, and gas mass ratios are kg/kg.
 * Outputs reverse the levels and use hPa and molecules per square centimetre.
 * The source water correction is a legacy approximation whose bias is recorded. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PARAMETERS void *a0,void *a1,void *a2,void *a3,void *a4,void *a5,void *a6,void *a7,void *a8,void *a9,void *a10,void *a11,void *a12,void *a13,void *a14,void *a15,void *a16,void *a17,void *a18,void *a19,void *a20,void *a21,void *a22,void *a23,void *a24,void *a25,void *a26
#define ARGUMENTS a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26
typedef void (*kernel)(PARAMETERS);
void rrtm_prepare_gases_assembly_(PARAMETERS) __attribute__((weak));
static uint64_t calls,independent,cells;
static long double max_total_bias,max_dry_bias,max_water_bias,max_observed_total,max_observed_dry,max_observed_water;
static void fail(const char *s){fprintf(stderr,"RRTM PREPARE GASES failed %s\n",s);_Exit(2);}
static void writeall(FILE *f,const void *p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("capture write");}
static uint64_t bits(double v){uint64_t x;memcpy(&x,&v,8);return x;}
static void close_enough(long double value,long double expected,long double scale,const char *what){
 const long double tolerance=4096*DBL_EPSILON*fmaxl(fabsl(expected),scale)+16*DBL_TRUE_MIN;
 if(!isfinite(value)||fabsl(value-expected)>tolerance){
  fprintf(stderr,"RRTM science call=%" PRIu64 " value=%.21Lg expected=%.21Lg tolerance=%.21Lg %s\n",calls,value,expected,tolerance,what);fail("independent physical relation");
 }
 ++independent;
}
static void science(const int32_t *d,const double *const *in,const double *const *out,const int32_t *reflect,double rg,double pl){
 const int ni=d[0],nf=d[1],lon=d[2],lev=d[3],n=nf-ni+1;
 const long double md=28.970,mw=18.0154,na=6.02214e23;
 const long double g=(long double)rg/pl;
 const long double C=(md-mw)*md/(mw*mw);
 const int fields[7]={4,5,13,7,-1,6,-1};
 const long double molar[7]={18.0154,44.011,47.9982,44.013,1,16.043,1};
 const int cross_fields[4]={12,9,10,11};
 const long double cross_molar[4]={153.8230,137.3686,120.9140,86.4690};
 for(int j=0;j<n;++j){
  if(reflect[j]!=0)fail("complete reflection zeros");++independent;
  const size_t surf=(size_t)(ni-1+j)+(size_t)lon*lev;
  close_enough(out[6][j],(long double)in[0][surf]/100,fabsl(in[0][surf])/100,"surface hPa");
  if(bits(out[7][j])!=bits(in[2][surf]))fail("complete surface temperature copy");++independent;
 }
 for(int k=0;k<lev;++k)for(int j=0;j<n;++j){
  const size_t t=(size_t)(ni-1+j)+(size_t)lon*(lev-1-k),b=t+lon;
  const size_t o=(size_t)j+(size_t)n*k,z=o+n;
  const long double q=in[4][t],dp=(long double)in[0][b]-in[0][t];
  if(!isfinite(q)||q<0||q>.5||dp<0||in[0][t]<0||in[1][t]<in[0][t]||in[1][t]>in[0][b]||in[2][t]<=0||in[3][t]<=0)fail("source-only physical input domain");
  const long double w=q*md/mw,M=(1-w)*md+w*mw;
  const long double Nd=.1L*dp*na/(g*M*(1+w));
  const long double pressure_scale=.1L*(fabsl(in[0][b])+fabsl(in[0][t]))*na/(g*M*(1+w));
  close_enough(out[0][o],Nd,pressure_scale,"legacy hydrostatic dry column");
  close_enough(out[4][o],(long double)in[1][t]/100,fabsl(in[1][t])/100,"full hPa");
  close_enough(out[6][z],(long double)in[0][t]/100,fabsl(in[0][t])/100,"reverse interface hPa");
  if(bits(out[5][o])!=bits(in[3][t])||bits(out[7][z])!=bits(in[2][t]))fail("complete reversed temperature copies");independent+=2;
  long double sum=0;
  for(int f=0;f<7;++f){
   const size_t ix=(size_t)j+(size_t)n*(f+35*k);
   long double vol=f==6?.209488L:f==4?0:(long double)in[fields[f]][t]*md/molar[f];
   if(f!=4&&f!=6&&(!isfinite(in[fields[f]][t])||in[fields[f]][t]<0))fail("nonnegative active gas input");
   if(f>=1)sum+=vol;
   const long double tiny_scale=f!=4&&f!=6&&in[fields[f]][t]!=0&&fabsl(in[fields[f]][t])<DBL_MIN?fabsl(out[0][o])*16*DBL_TRUE_MIN/(4096*DBL_EPSILON):0;
   close_enough(out[2][ix],(long double)out[0][o]*vol,fmaxl(fabsl(out[0][o]*vol),tiny_scale),"gas molecular column");
   if(f==4&&bits(out[2][ix])!=0)fail("unused channel positive zero");
  }
  if(sum>=1)fail("positive broadening composition");
  close_enough(out[1][o],(long double)out[0][o]*(1-sum),fabsl(out[0][o]),"broadening molecular column");
  for(int f=7;f<35;++f){const size_t ix=(size_t)j+(size_t)n*(f+35*k);if(bits(out[2][ix])!=0)fail("complete omitted gas positive zeros");++independent;}
  for(int f=0;f<4;++f){
   const size_t ix=(size_t)j+(size_t)n*(f+4*k);
   if(!isfinite(in[cross_fields[f]][t])||in[cross_fields[f]][t]<0)fail("nonnegative active cross section input");
   const long double v=(long double)out[0][o]*in[cross_fields[f]][t]*md/cross_molar[f]*1e-20L;
   const long double trace_scale=in[cross_fields[f]][t]!=0&&fabsl(in[cross_fields[f]][t])<DBL_MIN?fabsl(out[0][o])*16*DBL_TRUE_MIN*1e-20L/(4096*DBL_EPSILON):0;
   close_enough(out[3][ix],v,fmaxl(fabsl(v),trace_scale),"scaled trace molecular column");
  }
  const long double D=1+q-C*q*q,total=C*q*q/D,dry=1/((1-q)*D)-1,water=q?1/D-1:0;
  max_total_bias=fmaxl(max_total_bias,fabsl(total));max_dry_bias=fmaxl(max_dry_bias,fabsl(dry));max_water_bias=fmaxl(max_water_bias,fabsl(water));
  if(dp>0){
   const long double measured=((long double)out[0][o]*md+(long double)out[2][(size_t)j+(size_t)n*35*k]*mw)*10/na;
   const long double m=dp/g,expected=m*(1+total);
   close_enough(measured,expected,(fabsl(in[0][b])+fabsl(in[0][t]))/g,"quantified legacy moist mass approximation");
   max_observed_total=fmaxl(max_observed_total,fabsl(measured/m-1));
   const long double actual_dry=(long double)out[0][o]*md*10/na;
   const long double actual_water=(long double)out[2][(size_t)j+(size_t)n*35*k]*mw*10/na;
   max_observed_dry=fmaxl(max_observed_dry,fabsl(actual_dry/((1-q)*m)-1));
   if(q>0)max_observed_water=fmaxl(max_observed_water,fabsl(actual_water/(q*m)-1));
  }
  ++cells;
 }
}

#include <sys/mman.h>
#include <unistd.h>
extern double __yomcst_MOD_rg,__yomdyncore_MOD_rplrg;
extern int32_t __yomhook_MOD_lhook;
void rrtm_prepare_gases_(PARAMETERS);
int gases_abi_probe(PARAMETERS) __attribute__((weak));
struct guarded {unsigned char *mapping,*value;size_t pages,page,size;};
static struct guarded guard(size_t size,int end){
 const size_t page=(size_t)sysconf(_SC_PAGESIZE),pages=((size?size:1)+page-1)/page;
 unsigned char *p=mmap(NULL,(pages+2)*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(p==MAP_FAILED||mprotect(p+page,pages*page,PROT_READ|PROT_WRITE))fail("protected whole capacity allocation");
 memset(p+page,0xa5,pages*page);
 struct guarded a={p,p+page+(end?pages*page-size:0),pages,page,size};return a;
}
static void release(struct guarded *b){
 const size_t start=(size_t)(b->value-(b->mapping+b->page));
 for(size_t z=0;z<b->pages*b->page;++z)if(z<start||z>=start+b->size)if(b->mapping[b->page+z]!=0xa5)fail("unchanged whole-capacity poison neighbours");
 if(munmap(b->mapping,(b->pages+2)*b->page))fail("protected capacity release");
}
static void readall(FILE *f,void *p,size_t n){if(n&&fread(p,1,n,f)!=n)fail("complete frozen corpus read");}
#define PASS(v) v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12],v[13],v[14],v[15],v[16],v[17],v[18],v[19],v[20],v[21],v[22],v[23],v[24],v[25],v[26]
int main(int argc,char **argv){
 if(argc!=4)fail("arguments corpus source-output native-output");
 __yomhook_MOD_lhook=0; /* Disable only profiling in this standalone numerical check. */
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("FPCR exactly zero");
 FILE *f=fopen(argv[1],"rb"),*r=fopen(argv[2],"wb"),*a=rrtm_prepare_gases_assembly_?fopen(argv[3],"wb"):NULL;
 if(!f||!r||(rrtm_prepare_gases_assembly_&&!a))fail("critical streams open");
 char tag[8];uint64_t count;readall(f,tag,8);readall(f,&count,8);if(memcmp(tag,"GASES001",8))fail("frozen gas corpus tag");
 uint64_t placed=0,total=0,abi=0,positive=0,negative=0,subnormal=0;
 for(uint64_t rec=0;rec<count;++rec){
  int32_t d[4];double global[2];readall(f,d,16);readall(f,global,16);
  const int n=d[1]-d[0]+1,lon=d[2],lev=d[3];if(n<0||lon<1||lev<0)fail("critical shape");
  size_t sizes[27];
  for(int k=0;k<4;++k)sizes[k]=4;
  for(int k=4;k<18;++k)sizes[k]=(size_t)lon*(lev+(k==4||k==6))*8;
  const size_t count_out[9]={(size_t)n*lev,(size_t)n*lev,(size_t)n*lev*35,(size_t)n*lev*4,(size_t)n*lev,(size_t)n*lev,(size_t)n*(lev+1),(size_t)n*(lev+1),(size_t)n};
  for(int k=18;k<27;++k)sizes[k]=count_out[k-18]*(k==26?4:8);
  unsigned char *input[14];
  for(int k=0;k<14;++k){input[k]=malloc(sizes[k+4]?sizes[k+4]:1);if(!input[k])fail("corpus input allocation");readall(f,input[k],sizes[k+4]);}
  for(int end=0;end<2;++end){
   calls=rec*2+end;
   struct guarded ref[27],nat[27];void *v[27],*w[27];
   for(int k=0;k<27;++k){
    ref[k]=guard(sizes[k],end);nat[k]=guard(sizes[k],end);v[k]=ref[k].value;w[k]=nat[k].value;
    if(k<4){memcpy(v[k],&d[k],4);memcpy(w[k],&d[k],4);}
    else if(k<18){memcpy(v[k],input[k-4],sizes[k]);memcpy(w[k],input[k-4],sizes[k]);}
    if(k<18&&(mprotect(ref[k].mapping+ref[k].page,ref[k].pages*ref[k].page,PROT_READ)||mprotect(nat[k].mapping+nat[k].page,nat[k].pages*nat[k].page,PROT_READ)))fail("read-only input pages");
   }
   __yomcst_MOD_rg=global[0];__yomdyncore_MOD_rplrg=global[1];
   rrtm_prepare_gases_(PASS(v));
   if(memcmp(&__yomcst_MOD_rg,global,8)||memcmp(&__yomdyncore_MOD_rplrg,global+1,8))fail("original read-only globals");
   const double *in[14],*out[8];
   for(int k=0;k<14;++k)in[k]=v[k+4];for(int k=0;k<8;++k)out[k]=v[k+18];
   science(d,in,out,v[26],global[0],global[1]);
   if(a){
    if(!gases_abi_probe)fail("required direct ABI observer");
    if(gases_abi_probe(PASS(w)))fail("immediate native ABI preservation");++abi;
    if(memcmp(&__yomcst_MOD_rg,global,8)||memcmp(&__yomdyncore_MOD_rplrg,global+1,8))fail("native read-only globals");
   }
   int32_t h[2]={end,1};FILE *streams[2]={r,a};
   for(int z=0;z<2;++z)if(streams[z]){writeall(streams[z],&rec,8);writeall(streams[z],h,8);writeall(streams[z],d,16);writeall(streams[z],global,16);}
   size_t record_bytes=48;
   for(int k=18;k<27;++k){
    if(a&&memcmp(v[k],w[k],sizes[k])){
     size_t first=0;const unsigned char *x=v[k],*y=w[k];while(x[first]==y[first])++first;
     fprintf(stderr,"RRTM critical first mismatch record=%" PRIu64 " placement=%d field=%d byte=%zu source=%02x native=%02x\n",rec,end,k-17,first,x[first],y[first]);fail("complete native output bits");
    }
    writeall(r,v[k],sizes[k]);if(a)writeall(a,w[k],sizes[k]);record_bytes+=sizes[k];
    if(k<26)for(size_t z=0;z<sizes[k]/8;++z){uint64_t b=bits(((double *)v[k])[z]);if(b==0)++positive;if(b==UINT64_C(0x8000000000000000))++negative;if((b&UINT64_C(0x7ff0000000000000))==0&&(b&UINT64_C(0xfffffffffffff)))++subnormal;}
   }
   for(int k=0;k<27;++k){release(&ref[k]);release(&nat[k]);}
   __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved critical FPCR");
   ++placed;total+=record_bytes;
  }
  for(int k=0;k<14;++k)free(input[k]);
 }
 if(fgetc(f)!=EOF||fclose(f)||fclose(r)||(a&&fclose(a)))fail("whole critical corpus and streams close");
 printf("RRTM GASES %s PASS input_records=%" PRIu64 " placed_calls=%" PRIu64 " complete_bytes=%" PRIu64 " independent=%" PRIu64 " ABI=%" PRIu64 " positive_zeros=%" PRIu64 " negative_zeros=%" PRIu64 " subnormals=%" PRIu64 " legacy_total_bias=%.17Lg legacy_dry_bias=%.17Lg legacy_water_bias=%.17Lg observed_total_bias=%.17Lg observed_dry_bias=%.17Lg observed_water_bias=%.17Lg differing_bytes=0 FPCR=0\n",a?"NATIVE":"SOURCE",count,placed,total,independent,abi,positive,negative,subnormal,max_total_bias,max_dry_bias,max_water_bias,max_observed_total,max_observed_dry,max_observed_water);
 return 0;
}

/* Forward the interface and check saved registers before C can restore them. */
#ifdef GASES_ABI_OBSERVER
__asm__(".text\n.p2align 2\n.global gases_abi_probe\n.type gases_abi_probe,%function\ngases_abi_probe:\nsub sp,sp,#336\nstp x19,x20,[sp,#160]\nstp x21,x22,[sp,#176]\nstp x23,x24,[sp,#192]\nstp x25,x26,[sp,#208]\nstp x27,x28,[sp,#224]\nstp x29,x30,[sp,#240]\nstp d8,d9,[sp,#256]\nstp d10,d11,[sp,#272]\nstp d12,d13,[sp,#288]\nstp d14,d15,[sp,#304]\nldp x9,x10,[sp,#336]\nstp x9,x10,[sp,#0]\nldp x9,x10,[sp,#352]\nstp x9,x10,[sp,#16]\nldp x9,x10,[sp,#368]\nstp x9,x10,[sp,#32]\nldp x9,x10,[sp,#384]\nstp x9,x10,[sp,#48]\nldp x9,x10,[sp,#400]\nstp x9,x10,[sp,#64]\nldp x9,x10,[sp,#416]\nstp x9,x10,[sp,#80]\nldp x9,x10,[sp,#432]\nstp x9,x10,[sp,#96]\nldp x9,x10,[sp,#448]\nstp x9,x10,[sp,#112]\nldp x9,x10,[sp,#464]\nstp x9,x10,[sp,#128]\nldr x9,[sp,#480]\nstr x9,[sp,#144]\nmov x19,#0x1313\nmov x20,#0x1414\nmov x21,#0x1515\nmov x22,#0x1616\nmov x23,#0x1717\nmov x24,#0x1818\nmov x25,#0x1919\nmov x26,#0x1a1a\nmov x27,#0x1b1b\nmov x28,#0x1c1c\nmov x29,sp\nmov x9,#0x808\nfmov d8,x9\nmov x9,#0x909\nfmov d9,x9\nmov x9,#0xa0a\nfmov d10,x9\nmov x9,#0xb0b\nfmov d11,x9\nmov x9,#0xc0c\nfmov d12,x9\nmov x9,#0xd0d\nfmov d13,x9\nmov x9,#0xe0e\nfmov d14,x9\nmov x9,#0xf0f\nfmov d15,x9\nbl rrtm_prepare_gases_assembly_\nmov x9,sp\ncmp x29,x9\nb.ne .Lgases_abi_trap\nmov x9,#0x1313\ncmp x19,x9\nb.ne .Lgases_abi_bad\nmov x9,#0x1414\ncmp x20,x9\nb.ne .Lgases_abi_bad\nmov x9,#0x1515\ncmp x21,x9\nb.ne .Lgases_abi_bad\nmov x9,#0x1616\ncmp x22,x9\nb.ne .Lgases_abi_bad\nmov x9,#0x1717\ncmp x23,x9\nb.ne .Lgases_abi_bad\nmov x9,#0x1818\ncmp x24,x9\nb.ne .Lgases_abi_bad\nmov x9,#0x1919\ncmp x25,x9\nb.ne .Lgases_abi_bad\nmov x9,#0x1a1a\ncmp x26,x9\nb.ne .Lgases_abi_bad\nmov x9,#0x1b1b\ncmp x27,x9\nb.ne .Lgases_abi_bad\nmov x9,#0x1c1c\ncmp x28,x9\nb.ne .Lgases_abi_bad\nfmov x9,d8\nmov x10,#0x808\ncmp x9,x10\nb.ne .Lgases_abi_bad\nfmov x9,d9\nmov x10,#0x909\ncmp x9,x10\nb.ne .Lgases_abi_bad\nfmov x9,d10\nmov x10,#0xa0a\ncmp x9,x10\nb.ne .Lgases_abi_bad\nfmov x9,d11\nmov x10,#0xb0b\ncmp x9,x10\nb.ne .Lgases_abi_bad\nfmov x9,d12\nmov x10,#0xc0c\ncmp x9,x10\nb.ne .Lgases_abi_bad\nfmov x9,d13\nmov x10,#0xd0d\ncmp x9,x10\nb.ne .Lgases_abi_bad\nfmov x9,d14\nmov x10,#0xe0e\ncmp x9,x10\nb.ne .Lgases_abi_bad\nfmov x9,d15\nmov x10,#0xf0f\ncmp x9,x10\nb.ne .Lgases_abi_bad\nmrs x9,fpcr\ncbnz x9,.Lgases_abi_bad\nmov w0,#0\nb .Lgases_abi_restore\n.Lgases_abi_bad:\nmov w0,#1\n.Lgases_abi_restore:\nldp d8,d9,[sp,#256]\nldp d10,d11,[sp,#272]\nldp d12,d13,[sp,#288]\nldp d14,d15,[sp,#304]\nldp x19,x20,[sp,#160]\nldp x21,x22,[sp,#176]\nldp x23,x24,[sp,#192]\nldp x25,x26,[sp,#208]\nldp x27,x28,[sp,#224]\nldp x29,x30,[sp,#240]\nadd sp,sp,#336\nret\n.Lgases_abi_trap:\nbrk #1\n.size gases_abi_probe,.-gases_abi_probe\n");
#endif

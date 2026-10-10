/* Replay every complete native output against frozen original source bytes.
 * The driver supplies only arguments, storage and scientific acceptance checks.
 * Integers/logicals have 32 bits. Real coordinates and weights are dimensionless
 * binary64 values. Protected inputs are read-only, and output tails end at
 * inaccessible memory. All three full arrays and inactive cells are compared.
 */
#define _GNU_SOURCE
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <omp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
_Static_assert(sizeof(int32_t)==4&&sizeof(double)==8,"frozen widths");
extern uint64_t vertical_abi_call(void(*)(void*),void*);
extern void lascaw_clo_abi_invoke(void*);
static uint64_t case_number,calls,bytes,science,parallel_calls,guard_calls,actual;
static uint64_t fpcr(void){uint64_t x;__asm__ volatile("mrs %0,fpcr":"=r"(x));return x;}
__attribute__((noreturn))static void fail(const char*s){fprintf(stderr,"LASCAW_CLO verify FAIL case=%"PRIu64" %s\n",case_number,s);exit(2);}
struct mapping{void*base;size_t bytes;};
static void*alloc(size_t n){
 size_t page=(size_t)sysconf(_SC_PAGESIZE);if(n>PTRDIFF_MAX-page-32)fail("byte extent");
 size_t data=(n+16+page-1)/page*page,total=data+2*page;void*base=mmap(NULL,total,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(base==MAP_FAILED||mprotect((char*)base+page,data,PROT_READ|PROT_WRITE))fail("protected allocation");
 void*p=(char*)base+page+data-n;struct mapping m={base,total};memcpy((char*)p-16,&m,16);return p;
}
static void release(void*p){struct mapping m;memcpy(&m,(char*)p-16,16);if(munmap(m.base,m.bytes))fail("unmap");}
static void read_only(void*p){struct mapping m;memcpy(&m,(char*)p-16,16);size_t page=(size_t)sysconf(_SC_PAGESIZE);if(mprotect((char*)m.base+page,m.bytes-2*page,PROT_READ))fail("read-only input");}
static void read_all(FILE*f,void*p,size_t n){if(n&&fread(p,1,n,f)!=n)fail("complete input record");}
static void write_all(FILE*f,const void*p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete output record");}
static void same(const void*a,const void*b,size_t n,const char*s){
 if(!n||!memcmp(a,b,n))return;
 const unsigned char*x=a,*y=b;size_t k=0;while(k<n&&x[k]==y[k])k++;size_t off=k/8*8,m=n-off<8?n-off:8;uint64_t u=0,v=0;
 memcpy(&u,x+off,m);memcpy(&v,y+off,m);fprintf(stderr,"stage=%s first_byte=%zu physical_word=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",s,k,k/8,u,v);fail("whole raw bytes differ");
}
static double member(const void*d,size_t off){double x;memcpy(&x,(const unsigned char*)d+off,8);return x;}
static void domain(const void*d,int32_t l,int32_t b,int32_t start,int32_t end,const int32_t*flags,const double*minimum,const double*x,const double*xmad,const double*kappa,const double*turb){
 long double e=member(d,136),mi=(flags[0]||flags[1])?*minimum:0,ma=flags[0]?member(d,120):0,re=flags[0]?member(d,128):0;
 if(!isfinite(e)||fabsl(e)>DBL_MAX/4||!isfinite(mi)||!isfinite(ma)||!isfinite(re))fail("pre-execution finite parameter guard");
 for(int lev=0;lev<l;lev++)for(int row=start-1;row<end;row++){
  size_t p=(size_t)lev*b+row;long double a=x[p],am=xmad[p],k=flags[0]?kappa[p]:0,t=flags[3]?turb[p]:0;
  if(!isfinite(a)||!isfinite(am)||!isfinite(k)||!isfinite(t))fail("pre-execution selected finite guard");
  long double X=1+fabsl(a)+fabsl(am),K=fmaxl(fabsl(mi),fmaxl(fabsl(ma),fabsl(re)));
  long double scale=8*X*X*X*(1+2*K)*(1+3*(flags[0]?fabsl(e):0))*(1+2*fabsl(k))*(1+3*fabsl(t));
  if(!isfinite(scale)||scale>=DBL_MAX/256)fail("pre-execution finite intermediate bound");
 }
}

int main(int argc,char**argv){
 int offset=1;if(argc>1&&!strcmp(argv[1],"--actual")){actual=1;offset=2;}
 if(argc!=6)fail("usage INPUT SOURCE INDEPENDENT NATIVE SUMMARY or --actual INPUT SOURCE NATIVE SUMMARY");
 FILE*input=fopen(argv[offset],"rb"),*source=fopen(argv[offset+1],"rb"),*truth=NULL,*native=fopen(argv[actual?offset+2:offset+3],"wb");if(!input||!source||!native)fail("files");
 if(!actual){truth=fopen(argv[offset+2],"rb");if(!truth)fail("independent corpus");unsigned char gh[64],sh[64],ih[64];read_all(input,gh,64);read_all(source,sh,64);read_all(truth,ih,64);same(gh,sh,64,"global source header");if(memcmp(gh,"LSCWCR01",8)||memcmp(ih,"LSCWPH01",8))fail("global encoding");write_all(native,gh,64);bytes=64;}
 if(fpcr())fail("entry FPCR");
 for(;;){
  unsigned char h[192],sh[192];size_t n=fread(h,1,192,input);if(!n)break;if(n!=192)fail("header length");
  memcpy(&case_number,h+8,8);if(case_number!=calls+1||memcmp(h,actual?"LASCWF01":"LSCWCS01",8))fail("record order");
  read_all(source,sh,192);same(h,sh,192,"source record header");
  int32_t*d=alloc(32);memcpy(d,h+16,32);int32_t l=d[0],b=d[1],start=d[2],end=d[3];
  uint32_t mask=0;for(int j=0;j<4;j++){if(d[j+4]!=0&&d[j+4]!=1)fail("canonical logical guard before native");mask|=(uint32_t)d[j+4]<<j;}
  if(mask==1||mask==9)fail("undefined low-order guard before native");
  if(l<0||l>256||b<0||b>1024||start<1||start>b+1||end<0||end>b)fail("frozen shape guard");
  uint64_t cells,outsize,total,derived,encoded_mask,prefix=0;memcpy(&cells,h+64,8);memcpy(&outsize,h+72,8);memcpy(&total,h+80,8);memcpy(&derived,h+96,8);memcpy(&encoded_mask,h+104,8);
  if(!actual)memcpy(&prefix,h+128,8);
  int32_t presence[3];memcpy(presence,h+112,12);
  for(int j=0;j<3;j++)if(presence[j]!=0&&presence[j]!=1)fail("canonical presence");
  if((d[4]||d[5])&&!presence[0])fail("minimum presence");
  if(d[4]&&!presence[1])fail("kappa presence");
  if(d[7]&&!presence[2])fail("turbulence presence");
  if(cells!=(uint64_t)b*l||outsize!=24*cells+(actual?0:128)||derived!=456||encoded_mask!=mask||prefix!=(actual?0:8))fail("complete source extents");
  size_t sizes[9]={456,presence[0]?8:0,8*cells,8*cells,presence[1]?8*cells:0,presence[2]?8*cells:0,outsize,outsize,outsize},sum=0;void*arr[9];
  for(int j=0;j<9;j++){sum+=sizes[j];arr[j]=alloc(sizes[j]);read_all(input,arr[j],sizes[j]);}
  if(sum!=total)fail("whole input bytes");
  void*incoming[3],*gold[3],*expected[3]={NULL},*limit[3]={NULL};
  for(int j=0;j<3;j++){incoming[j]=alloc(outsize);gold[j]=alloc(outsize);if(outsize)memcpy(incoming[j],arr[j+6],outsize);read_all(source,gold[j],outsize);}
  if(truth){read_all(truth,sh,192);same(h,sh,192,"independent record");for(int j=0;j<3;j++){expected[j]=alloc(outsize);read_all(truth,expected[j],outsize);}for(int j=0;j<3;j++){limit[j]=alloc(outsize);read_all(truth,limit[j],outsize);}}
  const double*mi=presence[0]?arr[1]:NULL,*k=presence[1]?arr[4]:NULL,*t=presence[2]?arr[5]:NULL;
  domain(arr[0],l,b,start,end,d+4,mi,arr[2],arr[3],k,t);
  read_only(d);for(int j=0;j<6;j++)read_only(arr[j]);
  void*args[14]={arr[0],d,d+1,d+2,d+3,d+4,(void*)mi,arr[2],arr[3],(void*)k,(void*)t,(double*)arr[6]+prefix,(double*)arr[7]+prefix,(double*)arr[8]+prefix};
  if(vertical_abi_call(lascaw_clo_abi_invoke,args)||fpcr())fail("direct ABI or FPCR");
  for(int group=0;group<3;group++){
   if(outsize&&memcmp(gold[group],arr[group+6],outsize))fprintf(stderr,"output_set=%d\n",group);
   same(gold[group],arr[group+6],outsize,"complete returned array");
   for(int lev=0;lev<l;lev++)for(int row=0;row<b;row++)for(int plane=0;plane<3;plane++){
    size_t p=prefix+(size_t)lev*b+row+plane*cells;
    if(row<start-1||row>=end)same((double*)incoming[group]+p,(double*)arr[group+6]+p,8,"inactive output cell");
    else if(truth){double v=((double*)arr[group+6])[p],e=((double*)expected[group])[p],bound=((double*)limit[group])[p];if(!isfinite(v)||!isfinite(e)||!isfinite(bound)||bound<=0||fabs(v-e)>bound)fail("independent hundred-digit coefficient");science++;}
   }
   if(!actual){same(incoming[group],arr[group+6],64,"prefix guard");same((char*)incoming[group]+outsize-64,(char*)arr[group+6]+outsize-64,64,"suffix guard");}
  }
  int32_t profile;memcpy(&profile,h+48,4);
  if(!actual&&b==24&&l==19&&mask==15&&profile==11){
   int seen=0;
   #pragma omp parallel num_threads(3) shared(seen)
   {
    if(omp_get_num_threads()!=3)fail("genuine three-thread team");
    #pragma omp atomic update
    seen+=1;
    void*local[14];memcpy(local,args,sizeof local);void*field[3];
    for(int j=0;j<3;j++){field[j]=alloc(outsize);memcpy(field[j],incoming[j],outsize);local[j+11]=(double*)field[j]+prefix;}
    #pragma omp barrier
    if(vertical_abi_call(lascaw_clo_abi_invoke,local)||fpcr())fail("parallel ABI/FPCR");
    for(int j=0;j<3;j++){same(gold[j],field[j],outsize,"three-thread complete return");release(field[j]);}
   }
   if(seen!=3)fail("parallel count");
   parallel_calls+=3;
  }
  write_all(native,h,192);for(int j=6;j<9;j++)write_all(native,arr[j],outsize);bytes+=192+3*outsize;calls++;
  for(int j=0;j<9;j++)release(arr[j]);
  for(int j=0;j<3;j++){release(incoming[j]);release(gold[j]);if(expected[j])release(expected[j]);if(limit[j])release(limit[j]);}
  release(d);
 }
 if(!actual)for(int probe=0;probe<10;probe++){
  int32_t flags[4]={0,0,0,0};if(probe<8)flags[probe/2]=probe&1?2:-1;else{flags[0]=1;flags[3]=probe==9;}
  void*args[14]={NULL};args[5]=flags;
  if(vertical_abi_call(lascaw_clo_abi_invoke,args)||fpcr())fail("unsupported primary guard ABI");
  guard_calls++;
 }
 if(fgetc(source)!=EOF||(truth&&fgetc(truth)!=EOF))fail("trailing reference");
 if((actual&&calls!=4300)||(!actual&&(calls!=1512||science!=1891386||parallel_calls!=3||guard_calls!=10)))fail("complete corpus counts");
 fclose(input);fclose(source);fclose(native);if(truth)fclose(truth);
 FILE*f=fopen(argv[5],"w");if(!f)fail("summary");
 fprintf(f,"{\"actual_replay\":%s,\"cases\":%"PRIu64",\"direct_abi_calls\":%"PRIu64",\"protected_tail_cases\":%"PRIu64",\"genuine_three_thread_calls\":%"PRIu64",\"unsupported_guard_calls\":%"PRIu64",\"independent_coefficients\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0}\n",actual?"true":"false",calls,calls+parallel_calls+guard_calls,calls,parallel_calls,guard_calls,science,bytes);fclose(f);
 printf("LASCAW_CLO NATIVE PASS cases=%"PRIu64" ABI=%"PRIu64" bytes=%"PRIu64" science=%"PRIu64" FPCR=0\n",calls,calls+parallel_calls+guard_calls,bytes,science);
 return 0;
}

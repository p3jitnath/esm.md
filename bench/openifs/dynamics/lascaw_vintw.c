/* Replay complete enclosing output families against frozen source bytes.
 * Inputs are read-only, and every allocation ends at inaccessible memory.
 * The driver supplies storage, argument forwarding and independent checks,
 * with no cubic, correction, blend, filter or boundary solver stage.
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
extern uint64_t vertical_abi_call(void(*)(void*),void*);
extern void lascaw_vintw_abi_invoke(void*);
static uint64_t case_number,calls,bytes,science,parallel_calls,guard_calls,actual;
static uint64_t fpcr(void){uint64_t x;__asm__ volatile("mrs %0,fpcr":"=r"(x));return x;}
__attribute__((noreturn))static void fail(const char*s){fprintf(stderr,"LASCAW_VINTW verify FAIL case=%"PRIu64" %s\n",case_number,s);exit(2);}
struct mapping{void*base;size_t bytes;};
static void*alloc(size_t n){
 size_t page=(size_t)sysconf(_SC_PAGESIZE);if(n>PTRDIFF_MAX-page-32)fail("byte extent");
 size_t data=(n+16+page-1)/page*page,total=data+2*page;void*base=mmap(NULL,total,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(base==MAP_FAILED||mprotect((char*)base+page,data,PROT_READ|PROT_WRITE))fail("protected allocation");
 void*p=(char*)base+page+data-n;struct mapping m={base,total};memcpy((char*)p-16,&m,16);return p;
}
static void release(void*p){struct mapping m;memcpy(&m,(char*)p-16,16);if(munmap(m.base,m.bytes))fail("unmap");}
static void read_only(void*p){struct mapping m;memcpy(&m,(char*)p-16,16);size_t page=(size_t)sysconf(_SC_PAGESIZE);if(mprotect((char*)m.base+page,m.bytes-2*page,PROT_READ))fail("read-only input");}
static void read_all(FILE*f,void*p,size_t n){if(n&&fread(p,1,n,f)!=n)fail("complete record");}
static void write_all(FILE*f,const void*p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete write");}
static void same(const void*a,const void*b,size_t n,const char*s){
 if(!n||!memcmp(a,b,n))return;
 const unsigned char*x=a,*y=b;size_t k=0;while(k<n&&x[k]==y[k])k++;size_t off=k/8*8,m=n-off<8?n-off:8;uint64_t u=0,v=0;
 memcpy(&u,x+off,m);memcpy(&v,y+off,m);fprintf(stderr,"stage=%s first_byte=%zu physical_word=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",s,k,k/8,u,v);fail("whole raw bytes differ");
}
static double number(const void*a,size_t p){if(!a)fail("selected presence");double x=((const double*)a)[p];if(!isfinite(x))fail("selected finite input");return x;}
static void domain(const int32_t*z,void*const*a,size_t cells){
 for(int lev=0;lev<z[1];lev++)for(int row=z[2]-1;row<z[3];row++){
  size_t p=(size_t)lev*z[0]+row;int k=((const int32_t*)a[2])[p],in=k>=1&&k<=z[1]-3;
  if(k<0||k>=z[1])fail("selected index capacity before native");
  if(!in){number(a[4],p);number(a[5],p);continue;}
  long double x=number(a[3],p),nodes[4],R=1+fabsl(x),P=0,d=0,s=0,low=0,M=0,V=0,K=0,kappa=0,kt=0;
  for(int j=0;j<4;j++){nodes[j]=number(a[9],(size_t)k+j);R+=fabsl(nodes[j]);}
  for(int j=0;j<4;j++)for(int m=j+1;m<4;m++)if(nodes[j]==nodes[m])fail("distinct used nodes before native");
  for(int j=1;j<4;j++){long double c=fabsl(number(a[10],(size_t)k*4+j));if(c>P)P=c;}
  if(z[4])s=number(a[6],p);
  if(z[6]||z[7])d=number(a[4],p);
  if(z[6])for(int j=0;j<3;j++)low+=fabsl(number(a[11],(size_t)k*3+j));
  if(z[5]||z[6])K=fabsl(number(a[1],0));
  if(z[5]){
   long double ma=fabsl(number(a[0],15)),re=fabsl(number(a[0],16));if(ma>K)K=ma;if(re>K)K=re;
   kappa=number(a[7],p);if(z[9])kt=number(a[8],p);
   for(int j=0;j<9;j++)M+=fabsl(number(a[12],(size_t)k*9+j));
  }
  if(z[8])for(int j=0;j<9;j++)V+=fabsl(number(a[13],(size_t)k*9+j));
  R+=fabsl(d)+fabsl(s);long double scale=R*R*R*(1+P)*(1+fabsl(s))*(1+fabsl(s))*(1+fabsl(s))*(1+fabsl(d))*(1+fabsl(d))*(1+low)*(1+2*K)*(1+M)*(1+V)*(1+2*fabsl(kappa)+2*fabsl(kt));
  if(!isfinite(scale)||scale>=DBL_MAX/65536)fail("finite intermediate scale before native");
 }
 (void)cells;
}
static void arguments(void**args,int32_t*z,void*const*a,const int32_t*presence,const uint64_t*window){
 args[0]=a[0];args[1]=z;args[2]=z+1;args[3]=z+2;args[4]=z+3;args[5]=z+4;args[6]=z+5;args[7]=z+8;args[8]=z+9;
 for(int j=1;j<14;j++)args[j+8]=presence[j]?a[j]:NULL;
 for(int j=0;j<5;j++)args[j+22]=presence[j+14]?(char*)a[j+14]+window[j]:NULL;
}
int main(int argc,char**argv){
 int offset=1;if(argc>1&&!strcmp(argv[1],"--actual")){actual=1;offset=2;}
 if(argc!=6)fail("usage INPUT SOURCE INDEPENDENT NATIVE SUMMARY or --actual INPUT SOURCE NATIVE SUMMARY");
 FILE*input=fopen(argv[offset],"rb"),*source=fopen(argv[offset+1],"rb"),*truth=NULL,*native=fopen(argv[actual?offset+2:offset+3],"wb");if(!input||!source||!native)fail("files");
 if(!actual){truth=fopen(argv[offset+2],"rb");if(!truth)fail("independent file");unsigned char h[64],s[64],t[64];read_all(input,h,64);read_all(source,s,64);read_all(truth,t,64);same(h,s,64,"global source header");if(memcmp(h,"LVWCR01\0",8)||memcmp(t,"LVWPH01\0",8))fail("global encoding");write_all(native,h,64);bytes=64;}
 if(fpcr())fail("entry FPCR");
 for(;;){
  unsigned char h[384],sh[384];size_t n=fread(h,1,384,input);if(!n)break;if(n!=384)fail("header length");
  memcpy(&case_number,h+8,8);if(case_number!=calls+1||memcmp(h,actual?"LVWF01\0\0":"LVWCS01\0",8))fail("record order");
  read_all(source,sh,384);same(h,sh,384,"source header");
  int32_t*z=alloc(40);memcpy(z,h+16,40);
  uint32_t mask=0;for(int j=4;j<10;j++){if(z[j]!=0&&z[j]!=1)fail("canonical logical guard before native");mask|=(uint32_t)z[j]<<(j-4);}
  if(z[5]&&!z[6]&&!z[7])fail("undefined lower weight guard before native");
  int32_t b=z[0],l=z[1],start=z[2],end=z[3];if(b<0||b>1024||l<0||l>256||start<1||start>b+1||end<0||end>b)fail("shape guard before payload");
  uint64_t C,V,T,td,encoded;memcpy(&C,h+64,8);memcpy(&V,h+72,8);memcpy(&T,h+80,8);memcpy(&td,h+96,8);memcpy(&encoded,h+104,8);
  int32_t kweno;memcpy(&kweno,h+60,4);if(kweno!=1&&kweno!=3)fail("parent family slot capacity");
  if(C!=(uint64_t)b*l||V!=24*C||td!=456||encoded!=mask)fail("frozen extents");
  int32_t presence[19];uint64_t ext[19],window[5];memcpy(presence,h+112,76);memcpy(ext,h+192,152);memcpy(window,h+344,40);
  uint64_t need[19]={456,8,4*C,8*C,8*C,8*C,8*C,8*C,8*C,8*((uint64_t)l+2),32*(uint64_t)l,24*(uint64_t)l,72*(uint64_t)l,72*(uint64_t)l,24*C*(uint64_t)kweno+(actual?0:128),24*C+(actual?0:128),24*C+(actual?0:128),24*C+(actual?0:128),24*C*(uint64_t)kweno+(actual?0:128)};
  uint64_t sum=0;for(int j=0;j<19;j++){if(presence[j]!=0&&presence[j]!=1)fail("canonical presence");if(ext[j]!=(presence[j]?need[j]:0))fail("whole stored extent");sum+=ext[j];}
  if(sum!=T||!presence[0]||(C&&!presence[2]))fail("full stored input capacity");
  for(int j=0;j<5;j++)if(presence[j+14]){
   uint64_t prefix=actual?0:64,suffix=actual?0:64;
   if(window[j]<prefix||window[j]>ext[j+14]||V>ext[j+14]-window[j]||window[j]+V>ext[j+14]-suffix||(V&&(window[j]-prefix)%V))fail("exact source window before native");
  }
  void*a[19];for(int j=0;j<19;j++){a[j]=alloc(ext[j]);read_all(input,a[j],ext[j]);}
  void*incoming[5],*gold[5],*expected[5]={0},*limit[5]={0};
  for(int j=0;j<5;j++){incoming[j]=alloc(ext[j+14]);gold[j]=alloc(ext[j+14]);if(ext[j+14])memcpy(incoming[j],a[j+14],ext[j+14]);read_all(source,gold[j],ext[j+14]);}
  if(truth){read_all(truth,sh,384);same(h,sh,384,"independent header");for(int j=0;j<5;j++){expected[j]=alloc(ext[j+14]);read_all(truth,expected[j],ext[j+14]);}for(int j=0;j<5;j++){limit[j]=alloc(ext[j+14]);read_all(truth,limit[j],ext[j+14]);}}
  void*used[19];for(int j=0;j<19;j++)used[j]=presence[j]?a[j]:NULL;
  domain(z,used,C);read_only(z);for(int j=0;j<14;j++)read_only(a[j]);
  void*args[27];arguments(args,z,a,presence,window);
  if(vertical_abi_call(lascaw_vintw_abi_invoke,args)||fpcr())fail("complete ABI/FPCR");
  for(int j=0;j<5;j++){
   if(ext[j+14]&&memcmp(gold[j],a[j+14],ext[j+14]))fprintf(stderr,"output_family=%d\n",j);
   same(gold[j],a[j+14],ext[j+14],"complete enclosing returned family");
   if(ext[j+14])for(size_t absolute=0;absolute<ext[j+14]/8;absolute++){
    int writes=0;size_t view=(size_t)window[j]/8;
    if(absolute>=view&&absolute-view<3*C){
     size_t p=(absolute-view)%C,row=p%(size_t)b;
     if(row>=(size_t)(start-1)&&row<(size_t)end){int k=((const int32_t*)a[2])[p],inter=k>=1&&k<=l-3;int change[5]={1,1,inter||z[5],z[5]&&z[9],z[8]};writes=change[j];}
    }
    if(!writes)same((char*)incoming[j]+8*absolute,(char*)a[j+14]+8*absolute,8,"every untouched output byte");
    else if(truth){double value=((double*)a[j+14])[absolute],target=((double*)expected[j])[absolute],bound=((double*)limit[j])[absolute];if(!isfinite(value)||!isfinite(target)||!isfinite(bound)||bound<=0||fabs(value-target)>bound)fail("hundred-digit coefficient");science++;}
   }
  }
  int32_t profile;memcpy(&profile,h+88,4);
  if(!actual&&b==24&&l==19&&mask==63&&profile==11){
   int seen=0;
   #pragma omp parallel num_threads(3) shared(seen)
   {
    if(omp_get_num_threads()!=3)fail("genuine three-thread team");
    #pragma omp atomic update
    seen+=1;
    void*local[27];memcpy(local,args,sizeof local);void*field[5];
    for(int j=0;j<5;j++){field[j]=alloc(ext[j+14]);if(ext[j+14])memcpy(field[j],incoming[j],ext[j+14]);local[22+j]=presence[j+14]?(char*)field[j]+window[j]:NULL;}
    #pragma omp barrier
    if(vertical_abi_call(lascaw_vintw_abi_invoke,local)||fpcr())fail("parallel ABI/FPCR");
    for(int j=0;j<5;j++){same(gold[j],field[j],ext[j+14],"three-thread whole family");release(field[j]);}
   }
   if(seen!=3)fail("parallel count");
   parallel_calls+=3;
  }
  write_all(native,h,384);bytes+=384;for(int j=14;j<19;j++){write_all(native,a[j],ext[j]);bytes+=ext[j];}calls++;
  for(int j=0;j<19;j++)release(a[j]);
  for(int j=0;j<5;j++){release(incoming[j]);release(gold[j]);if(expected[j])release(expected[j]);if(limit[j])release(limit[j]);}
  release(z);
 }
 if(!actual)for(int probe=0;probe<20;probe++){
  int32_t z[10]={0};if(probe<12)z[4+probe/2]=probe&1?2:-1;else{int bits=probe-12;z[5]=1;z[4]=bits&1;z[8]=(bits>>1)&1;z[9]=(bits>>2)&1;}
  void*args[27]={0};args[5]=z+4;args[6]=z+5;args[7]=z+8;args[8]=z+9;
  if(vertical_abi_call(lascaw_vintw_abi_invoke,args)||fpcr())fail("unsupported primary ABI guard");
  guard_calls++;
 }
 if(fgetc(source)!=EOF||(truth&&fgetc(truth)!=EOF))fail("trailing reference");
 if((actual&&calls!=6450)||(!actual&&(calls!=6048||science!=8815488||parallel_calls!=3||guard_calls!=20)))fail("complete corpus counts");
 fclose(input);fclose(source);fclose(native);if(truth)fclose(truth);
 FILE*f=fopen(argv[5],"w");if(!f)fail("summary");
 fprintf(f,"{\"actual_replay\":%s,\"cases\":%"PRIu64",\"direct_abi_calls\":%"PRIu64",\"protected_tail_cases\":%"PRIu64",\"genuine_three_thread_calls\":%"PRIu64",\"unsupported_guard_calls\":%"PRIu64",\"independent_coefficients\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0}\n",actual?"true":"false",calls,calls+parallel_calls+guard_calls,calls,parallel_calls,guard_calls,science,bytes);fclose(f);
 printf("LASCAW_VINTW NATIVE PASS cases=%"PRIu64" ABI=%"PRIu64" bytes=%"PRIu64" science=%"PRIu64" FPCR=0\n",calls,calls+parallel_calls+guard_calls,bytes,science);
 return 0;
}

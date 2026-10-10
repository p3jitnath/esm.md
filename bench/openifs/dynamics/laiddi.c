/* Check whole native returns against frozen original-source records.
 * Integers have 32 bits, and field values use 64-bit floating point.
 * Rows vary fastest. Coefficients have no unit, and fields retain caller units.
 * The driver supplies arguments and storage, with no interpolation or clip.
 * Inputs are read-only, output tails have protected memory, and every returned
 * byte is compared, including unused rows and the two eight-cell guards.
 */
#define _GNU_SOURCE
#include <inttypes.h>
#include <math.h>
#include <omp.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
_Static_assert(sizeof(int32_t)==4&&sizeof(double)==8,"frozen source scalar widths");
extern uint64_t vertical_abi_call(void(*)(void*),void*);
extern void laiddi_abi_invoke(void*);
static uint64_t case_number,calls,bytes,science,parallel_calls,actual;
static uint64_t fpcr(void){uint64_t x;__asm__ volatile("mrs %0,fpcr":"=r"(x));return x;}
__attribute__((noreturn))static void fail(const char*s){fprintf(stderr,"LAIDDI verify FAIL case=%"PRIu64" %s\n",case_number,s);exit(2);}
struct mapping {void*base;size_t bytes;};
static void *alloc(size_t n)
{
 size_t page=(size_t)sysconf(_SC_PAGESIZE);
 if(n>PTRDIFF_MAX-page-32)fail("byte extent");
 size_t data=(n+16+page-1)/page*page,total=data+2*page;
 void*base=mmap(NULL,total,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(base==MAP_FAILED||mprotect((char*)base+page,data,PROT_READ|PROT_WRITE))fail("protected allocation");
 void*p=(char*)base+page+data-n;struct mapping m={base,total};memcpy((char*)p-16,&m,16);return p;
}
static void release(void*p){struct mapping m;memcpy(&m,(char*)p-16,16);if(munmap(m.base,m.bytes))fail("unmap");}
static void read_only(void*p)
{
 struct mapping m;memcpy(&m,(char*)p-16,16);size_t page=(size_t)sysconf(_SC_PAGESIZE);
 if(mprotect((char*)m.base+page,m.bytes-2*page,PROT_READ))fail("read-only input");
}
static void read_all(FILE*f,void*p,size_t n){if(n&&fread(p,1,n,f)!=n)fail("complete input record");}
static void write_all(FILE*f,const void*p,size_t n){if(n&&fwrite(p,1,n,f)!=n)fail("complete output record");}
static void same(const void*a,const void*b,size_t n,const char*s)
{
 if(!memcmp(a,b,n))return;
 const unsigned char*x=a,*y=b;size_t k=0;while(k<n&&x[k]==y[k])k++;size_t start=k/8*8,m=n-start<8?n-start:8;uint64_t e=0,v=0;
 memcpy(&e,x+start,m);memcpy(&v,y+start,m);
 fprintf(stderr,"stage=%s first_byte=%zu physical_word=%zu expected=0x%016"PRIx64" actual=0x%016"PRIx64"\n",s,k,k/8,e,v);fail("complete raw bytes differ");
}
int main(int argc,char**argv)
{
 int offset=1;
 if(argc>1&&!strcmp(argv[1],"--actual")){actual=1;offset=2;}
 if((!actual&&argc!=6)||(actual&&argc!=6))fail("usage INPUT SOURCE INDEPENDENT NATIVE SUMMARY or --actual INPUT SOURCE NATIVE SUMMARY");
 FILE*input=fopen(argv[offset],"rb"),*source=fopen(argv[offset+1],"rb"),*truth=NULL;
 FILE*native=fopen(argv[actual?offset+2:offset+3],"wb");if(!input||!source||!native)fail("files");
 if(!actual){truth=fopen(argv[offset+2],"rb");if(!truth)fail("independent corpus");unsigned char gh[64],sh[64],ih[64];read_all(input,gh,64);read_all(source,sh,64);read_all(truth,ih,64);same(gh,sh,64,"global header");if(memcmp(gh,"LAIDCR01",8)||memcmp(ih,"LAIDIN01",8))fail("global encoding");write_all(native,gh,64);bytes=64;}
 if(fpcr())fail("entry FPCR");
 for(;;){
  unsigned char h[192],sh[192];size_t n=fread(h,1,192,input);if(!n)break;if(n!=192)fail("header length");
  memcpy(&case_number,h+8,8);if(case_number!=calls+1||memcmp(h,actual?"LAIDFC01":"LAIDCS01",8))fail("record order");
  read_all(source,sh,192);same(h,sh,192,"source record header");
  int32_t*d=alloc(36);memcpy(d,h+16,36);
  int32_t a=d[0],b=d[1],start=d[2],end=d[3],l=d[4];uint64_t cells,capacity,full;
  memcpy(&cells,h+64,8);memcpy(&capacity,h+72,8);
  if(actual)full=cells;else memcpy(&full,h+80,8);
  if(a<0||b<0||l<0||cells!=(uint64_t)b*l||capacity!=(uint64_t)a*(uint64_t)((int64_t)d[6]-d[5]+1)||full!=cells+(actual?0:16))fail("frozen extents");
  size_t sizes[6]={24*cells,32*cells,48*cells,16*cells,capacity*8,full*8};
  void*arr[6];for(int k=0;k<6;k++){arr[k]=alloc(sizes[k]);read_all(input,arr[k],sizes[k]);}
  void*incoming=alloc(sizes[5]),*gold=alloc(sizes[5]);memcpy(incoming,arr[5],sizes[5]);read_all(source,gold,sizes[5]);
  double*expected=NULL,*limits=NULL;
  if(truth){read_all(truth,sh,192);same(h,sh,192,"independent record");expected=alloc(sizes[5]);limits=alloc(sizes[5]);read_all(truth,expected,sizes[5]);read_all(truth,limits,sizes[5]);}
  read_only(d);for(int k=0;k<5;k++)read_only(arr[k]);
  void*args[14]={d,d+1,d+2,d+3,d+4,d+5,d+6,d+7,arr[0],arr[1],arr[2],arr[3],arr[4],(double*)arr[5]+(actual?0:8)};
  if(vertical_abi_call(laiddi_abi_invoke,args)||fpcr())fail("direct ABI or FPCR");
  same(gold,arr[5],sizes[5],"whole returned allocation");
  for(int lev=0;lev<l;lev++)for(int row=0;row<b;row++){
   size_t pos=(size_t)lev*b+row+(actual?0:8);
   if(row<start-1||row>=end)same((char*)incoming+pos*8,(double*)arr[5]+pos,8,"inactive output cell");
   else if(truth){double v=((double*)arr[5])[pos];if(!isfinite(v)||fabs(v-expected[pos])>limits[pos])fail("independent hundred-digit value");science++;}
  }
  if(!actual){same(incoming,arr[5],64,"prefix guard");same((char*)incoming+sizes[5]-64,(char*)arr[5]+sizes[5]-64,64,"suffix guard");}
  if(!actual&&a==3101&&d[7]==1&&d[8]==13){
   int seen=0;
   #pragma omp parallel num_threads(3) shared(seen)
   {
    if(omp_get_num_threads()!=3)fail("three-thread team");
    #pragma omp atomic update
    seen+=1;
    void*field=alloc(sizes[5]);memcpy(field,incoming,sizes[5]);void*local[14];memcpy(local,args,sizeof(local));local[13]=(double*)field+8;
    #pragma omp barrier
    if(vertical_abi_call(laiddi_abi_invoke,local)||fpcr())fail("parallel ABI or FPCR");
    same(gold,field,sizes[5],"three-thread whole return");release(field);
   }
   if(seen!=3)fail("parallel call count");
   parallel_calls+=3;
  }
  write_all(native,h,192);write_all(native,arr[5],sizes[5]);bytes+=192+sizes[5];calls++;
  for(int k=0;k<6;k++)release(arr[k]);
  release(d);release(incoming);release(gold);if(expected)release(expected);if(limits)release(limits);
 }
 if(fgetc(source)!=EOF||(truth&&fgetc(truth)!=EOF))fail("trailing reference records");
 if((actual&&calls!=2150)||(!actual&&(calls!=288||science!=52836||parallel_calls!=3)))fail("complete corpus count");
 fclose(input);fclose(source);fclose(native);if(truth)fclose(truth);
 FILE*f=fopen(argv[5],"w");if(!f)fail("summary");
 fprintf(f,"{\"actual_replay\":%s,\"cases\":%"PRIu64",\"direct_abi_calls\":%"PRIu64",\"protected_tail_cases\":%"PRIu64",\"genuine_three_thread_calls\":%"PRIu64",\"independent_values\":%"PRIu64",\"canonical_bytes\":%"PRIu64",\"different_bytes\":0,\"fpcr\":0}\n",actual?"true":"false",calls,calls+parallel_calls,calls,parallel_calls,science,bytes);fclose(f);
 printf("LAIDDI NATIVE PASS cases=%"PRIu64" ABI=%"PRIu64" bytes=%"PRIu64" physics=%"PRIu64" FPCR=0\n",calls,calls+parallel_calls,bytes,science);return 0;
}

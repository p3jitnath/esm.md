/* Verify complete physics state updates, water and latent-heat balances.
 * Wind uses m/s, temperature K, time s and water fractions kg/kg.
 * The corpus is frozen before assembly emission; protected pages check bounds. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#define CPQTUV_ARGS const void *e,const void *g,const int32_t *np,const int32_t *ks, \
 const int32_t *ke,const int32_t *nl,const double *dt,const int32_t *dry, \
 const double *u9,const double *v9,const double *t9,double *old,const double *dyn, \
 const double *conv,double *u,double *v,double *t,double *q
void cpqtuv_(CPQTUV_ARGS);
void cpqtuv_assembly_(CPQTUV_ARGS) __attribute__((weak));
typedef void (*kernel)(CPQTUV_ARGS);
typedef struct {void *map;size_t mapbytes,usable,count;double *p;} buffer;
typedef struct {int32_t h[12],maps[8][5],alias[7];double d[5];} record;
static const size_t slots[7]={799840,799856,799848,799920,799912,799984,801104};
static const double guard=-777.75;
static uint64_t calls,bytes,physical_points,mass_points,initial_fpcr;
static void fail(const char *s) {fprintf(stderr,"CPQTUV check failed %s\n",s);exit(2);}
static uint64_t bits(double x) {uint64_t u;memcpy(&u,&x,8);return u;}
static uint64_t fpcr(void) {uint64_t u;__asm__ volatile("mrs %0,fpcr":"=r"(u));return u;}
static void puti(void *p,size_t o,int32_t x) {memcpy((char *)p+o,&x,4);}
static void putd(void *p,size_t o,double x) {memcpy((char *)p+o,&x,8);}
static buffer allocbuf(size_t n) {
 size_t page=(size_t)sysconf(_SC_PAGESIZE),usable=((n+1)*8+page-1)/page*page;
 void *m=mmap(NULL,usable+2*page,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
 if(m==MAP_FAILED || mprotect((char *)m+page,usable,PROT_READ|PROT_WRITE)) fail("allocate pages");
 double *p=(double *)((char *)m+page+usable-n*8);p[-1]=guard;
 return (buffer){m,usable+2*page,usable,n,p};
}
static void readonly(buffer *b) {if(mprotect((char *)b->map+sysconf(_SC_PAGESIZE),b->usable,PROT_READ)) fail("protect input");}
static void release(buffer *b) {if(munmap(b->map,b->mapbytes)) fail("release pages");}
static void writeall(FILE *f,const void *p,size_t n) {if(n && fwrite(p,1,n,f)!=n) fail("write bytes");}
static void readall(FILE *f,void *p,size_t n) {if(n && fread(p,1,n,f)!=n) fail("read bytes");}
static int selected(const record *c,int field,int tracer) {
 if(field<3) return 1;
 if(field==4) return c->maps[6][0] && tracer==c->maps[6][2];
 for(int d=0;d<c->h[8];++d) if(c->maps[d][1] && c->maps[d][3]==tracer) return 1;
 for(int d=1;d<6;++d) if(c->maps[d][1] && (tracer==c->maps[d][3] || (d<5 && tracer==c->maps[0][3]))) return 1;
 return 0;
}
static void invoke(kernel fn,const record *c,buffer *e,buffer *g,buffer in[5],buffer out[5]) {
 int mass=c->h[9] && c->maps[6][0];
 for(int f=0;f<5;++f) mass=mass && c->maps[f][0];
 fn(e->p,g->p,&c->h[2],&c->h[3],&c->h[4],&c->h[5],&c->d[0],&c->h[9],
 in[0].p,in[1].p,in[2].p,out[4].p,mass?in[3].p:NULL,c->maps[6][0]?in[4].p:NULL,
 out[0].p,out[1].p,out[2].p,out[3].p);
}
static void close_enough(long double a,long double b,const char *what,int number) {
 if(fabsl(a-b)>128.0L*DBL_EPSILON*fmaxl(1.0L,fmaxl(fabsl(a),fabsl(b)))) {
  fprintf(stderr,"CPQTUV physical case=%d %s actual=%.21Lg expected=%.21Lg\n",number,what,a,b);exit(2);
 }
}
static void physics(const record *c,buffer in[5],buffer out[5],double *before[5]) {
 size_t cells=(size_t)c->h[2]*(size_t)c->h[5];
 int mass=c->h[9] && c->maps[6][0];
 for(int f=0;f<5;++f) mass=mass && c->maps[f][0];
 for(int32_t j=0;j<c->h[5];++j) for(int32_t i=c->h[3]-1;i<c->h[4];++i) {
  size_t k=(size_t)j*(size_t)c->h[2]+(size_t)i;
  for(int f=0;f<2;++f) close_enough(out[f].p[k],(long double)in[f].p[k]+(long double)c->d[0]*before[f][k+1],"wind update",c->h[0]);
  if(c->h[10]==11) {
   size_t q=(size_t)(c->maps[0][3]-1)*cells+k;
   close_enough(out[3].p[q],3.0L/32.0L,"ordered repeated target",c->h[0]);continue;
  }
  long double pre[6],post[6],oldwater=0.0L,dynwater=0.0L;
  for(int f=0;f<6;++f) {
   size_t dest=(size_t)(c->maps[f][3]-1)*cells+k;
   size_t source=(size_t)(c->maps[f][4]-1)*cells+k;
   pre[f]=before[3][dest+1];
   if(c->maps[f][1]) pre[f]=(long double)before[4][source+1]+(long double)c->d[0]*pre[f];
   post[f]=out[3].p[dest];
   if(f<5) {oldwater+=before[4][source+1];dynwater+=in[3].p[dest];}
  }
  long double water0=0.0L,water1=0.0L;
  for(int f=0;f<5;++f) {water0+=pre[f];water1+=post[f];}
  long double change=water0-oldwater-(long double)c->d[0]*dynwater;
  long double factor=mass?1.0L-change:1.0L;
  close_enough(water1,water0*factor,"total water balance",c->h[0]);
  long double heat0=(long double)in[2].p[k]+(long double)c->d[0]*before[2][k+1]-
    (long double)c->d[3]*(pre[1]+pre[3])-(long double)c->d[4]*(pre[2]+pre[4]);
  long double heat1=(long double)out[2].p[k]-(long double)c->d[3]*(post[1]+post[3])/factor-
    (long double)c->d[4]*(post[2]+post[4])/factor;
  close_enough(heat1,heat0,"latent-heat balance",c->h[0]);
  if(c->maps[5][1] && post[5]>1.0L+128.0L*DBL_EPSILON) fail("cloud upper bound");
  if(c->maps[6][0]) {
   size_t dest=(size_t)(c->maps[6][2]-1)*cells+k;
   if(mass) {
    close_enough(((long double)out[4].p[dest]-in[4].p[k])*(1.0L-water1)*(long double)c->d[0],change,"continuity water-mass balance",c->h[0]);
    for(int f=0;f<5;++f) close_enough(post[f],pre[f]*factor,"water-mass rescaling",c->h[0]);
    ++mass_points;
   } else if(bits(out[4].p[dest])!=bits(in[4].p[k])) fail("continuity copy");
  }
  if(c->h[10]==10) for(int f=1;f<5;++f) if(c->maps[f][1] && bits((double)post[f])!=bits(c->d[2])) fail("strict threshold equality");
  ++physical_points;
 }
}
static void check(const record *c,buffer input[10],FILE *af,FILE *rf,int assembly) {
 int32_t np=c->h[2],nl=c->h[5];size_t cells=(size_t)np*(size_t)nl;
 buffer e=allocbuf(2776/8),g=allocbuf(1359136/8),a[5],r[5];double *before[5];
 memset(e.p,0,2776);memset(g.p,0,1359136);
 putd(e.p,112,c->d[1]);putd(e.p,120,c->d[2]);puti(g.p,0,c->h[8]);puti(g.p,48,c->h[6]);puti(g.p,64,c->h[7]);
 for(int f=0;f<8;++f) {
  size_t o=3848+(size_t)f*368;
  puti(g.p,o+64,c->maps[f][0]);puti(g.p,o+92,c->maps[f][1]);puti(g.p,o+168,c->maps[f][2]);
  puti(g.p,o+188,c->maps[f][3]);puti(g.p,o+184,c->maps[f][4]);
 }
 for(int f=0;f<7;++f) {void *p=(char *)g.p+3848+(size_t)(c->alias[f]-1)*368;memcpy((char *)g.p+slots[f],&p,8);}
 double *lv=dlsym(RTLD_DEFAULT,"__yoethf_MOD_ralvdcp"),*ls=dlsym(RTLD_DEFAULT,"__yoethf_MOD_ralsdcp");
 if(!lv || !ls) fail("latent-heat constants");
 *lv=c->d[3];*ls=c->d[4];
 readonly(&e);readonly(&g);
 for(int f=0;f<5;++f) {
  a[f]=allocbuf(input[f].count);r[f]=allocbuf(input[f].count);
  before[f]=malloc((input[f].count+1)*8);if(!before[f]) fail("incoming copy");
  memcpy(before[f],input[f].p-1,(input[f].count+1)*8);
  memcpy(a[f].p,input[f].p,input[f].count*8);memcpy(r[f].p,input[f].p,input[f].count*8);
  readonly(&input[f+5]);
 }
 invoke(cpqtuv_,c,&e,&g,input+5,r);
 if(assembly) {if(!cpqtuv_assembly_) fail("assembly missing");invoke(cpqtuv_assembly_,c,&e,&g,input+5,a);}
 buffer *result=assembly?a:r;
 if(c->h[7]>0 && c->h[6]>0) physics(c,input+5,result,before);
 for(int f=0;f<5;++f) {
  for(size_t z=0;z<=r[f].count;++z) {
   double rv=r[f].p[(ptrdiff_t)z-1],av=result[f].p[(ptrdiff_t)z-1];
   if(bits(av)!=bits(rv)) {
    size_t k=z && cells?(z-1)%cells:0;
    fprintf(stderr,"Mismatch stage=CPQTUV case=%d mode=%d field=%d tracer=%zu level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",c->h[0],c->h[1],f,z&&cells?(z-1)/cells+1:0,k/(size_t)np+1,k%(size_t)np+1,bits(av),bits(rv));exit(1);
   }
   int change=0;
   if(z && cells) {int col=(int)((z-1)%(size_t)np)+1;int tracer=(int)((z-1)/cells)+1;change=col>=c->h[3] && col<=c->h[4] && selected(c,f,tracer);}
   if(!change && bits(av)!=bits(before[f][z])) fail("inactive output or guard");
  }
  writeall(rf,r[f].p-1,(r[f].count+1)*8);if(assembly) writeall(af,a[f].p-1,(a[f].count+1)*8);
  bytes+=(r[f].count+1)*8;free(before[f]);release(&a[f]);release(&r[f]);
 }
 if(fpcr()!=initial_fpcr) fail("changed FPCR");
 release(&e);release(&g);++calls;
}
static void sizes(const record *c,size_t n[10]) {
 size_t cells=(size_t)c->h[2]*(size_t)c->h[5];
 for(int f=0;f<10;++f) n[f]=cells;
 n[3]=n[8]=cells*(size_t)c->h[7];n[4]=cells*(size_t)c->h[6];
}
static record prepare(int number,int mode,int pattern,int np,int ks,int ke,int nl,int iteration,int alt) {
 record c={0};int32_t h[12]={number,mode,np,ks,ke,nl,8,6,8,pattern==6||pattern==13,pattern,iteration};memcpy(c.h,h,sizeof h);
 c.d[0]=pattern==8||pattern==9?1.0:pattern==11?2.0:iteration>=0?32.0:8.0;
 c.d[1]=0x1p-8;c.d[2]=0x1p-20;c.d[3]=2560.0;c.d[4]=2816.0;
 if(pattern==8||pattern==9) c.d[1]=c.d[2]=0.0;
 const int32_t target[6]={6,4,2,5,1,3},old[6]={3,1,5,2,8,4};
 for(int f=0;f<8;++f) {c.maps[f][0]=f<7;c.maps[f][1]=f<6 && (mode&(1<<f));c.maps[f][2]=f+1;c.maps[f][3]=f<6?(alt?target[f]:f+1):-99;c.maps[f][4]=f<6?(alt?old[f]:f+1):-97;}
 c.maps[6][2]=alt?6:8;c.maps[6][0]=pattern!=7;
 if(pattern==13) c.maps[2][0]=0;
 if(pattern==11) {c.maps[7][1]=1;c.maps[7][3]=c.maps[0][3];c.maps[7][4]=7;}
 if(pattern==12) {c.h[6]=c.h[7]=c.h[8]=0;for(int f=0;f<8;++f) {c.maps[f][0]=c.maps[f][1]=0;c.maps[f][3]=c.maps[f][4]=-99;}}
 for(int f=0;f<7;++f)c.alias[f]=f+1;
 return c;
}
static void generate(const record *c,buffer b[10]) {
 size_t n[10];sizes(c,n);size_t cells=(size_t)c->h[2]*(size_t)c->h[5];
 for(int f=0;f<10;++f) {b[f]=allocbuf(n[f]);for(size_t k=0;k<n[f];++k)b[f].p[k]=0.0625+(double)f/1024.0+(double)(k%7)/4096.0;}
 int p=c->h[10],iteration=c->h[11]<0?0:c->h[11];
 for(size_t k=0;k<cells;++k) {
  const double rate[3]={0.125,-0.0625,0.03125},base[3]={-16.0,24.0,280.0};
  for(int f=0;f<3;++f) {
   b[f+5].p[k]=base[f]+(double)(k%13)/128.0+rate[f]*c->d[0]*iteration;b[f].p[k]=rate[f];
   if(p==8) {b[f+5].p[k]=f==1?-0.0:0.0;b[f].p[k]=f==0?-0.0:0.0;}
   if(p==9) {b[f+5].p[k]=0.0;b[f].p[k]=f==1?-0x0.0000000000001p-1022:0x0.0000000000001p-1022;}
  }
  b[9].p[k]=0x1p-14+(double)(k%3)*0x1p-18;
  if(c->h[7]==0)continue;
  double water[6]={0.015625,0.001953125,0.0009765625,0.00048828125,0.000244140625,0.5};
  if(p==1)for(int f=1;f<5;++f)water[f]=-((double)f+(double)(k%4))*0x1p-22;
  if(p==2)for(int f=1;f<5;++f)water[f]=(double)f*0x1p-24;
  if(p==3)water[5]=0.5*c->d[1];
  if(p==4)water[1]=water[2]=0.0;
  if(p==5)water[5]=1.25;
  if(p==8)for(int f=0;f<5;++f)water[f]=f&1?-0.0:0.0;
  if(p==9)for(int f=0;f<5;++f)water[f]=0x0.0000000000001p-1022;
  if(p==10) {for(int f=1;f<5;++f)water[f]=c->d[2];water[5]=c->d[1];}
  for(int f=0;f<6;++f) {
   size_t dest=(size_t)(c->maps[f][3]-1)*cells+k,source=(size_t)(c->maps[f][4]-1)*cells+k;
   double qrate=f==0&&(p==6||p==13)?0x1p-12:f==0&&c->h[11]>=0?0x1p-16:0.0;
   b[4].p[source]=water[f]+qrate*c->d[0]*iteration;b[3].p[dest]=qrate;b[8].p[dest]=0.0;
  }
  if(p==11) {b[4].p[k]=1.0/64.0;b[4].p[6*cells+k]=1.0/32.0;b[3].p[k]=1.0/128.0;}
 }
}
static void savecase(FILE *f,const record *c,buffer b[10]) {
 writeall(f,c->h,48);writeall(f,c->d,40);writeall(f,c->maps,(size_t)c->h[8]*20);writeall(f,c->alias,28);
 for(int j=0;j<10;++j)writeall(f,b[j].p,b[j].count*8);
}
int main(int argc,char **argv) {
 if(argc!=4)fail("arguments --freeze|--verify corpus output-prefix");
 int freeze=!strcmp(argv[1],"--freeze");if(!freeze && strcmp(argv[1],"--verify"))fail("mode");
 uint32_t endian=1;if(*(unsigned char *)&endian!=1)fail("endianness");
 initial_fpcr=fpcr();if(initial_fpcr&UINT64_C(0x03c80000))fail("floating-point control");
 int32_t *hook=dlsym(RTLD_DEFAULT,"__yomhook_MOD_lhook");if(!hook)fail("hook flag");*hook=0;
 char path[4096];snprintf(path,sizeof path,"%s.fortran.bin",argv[3]);FILE *rf=fopen(path,"wb"),*af=NULL;
 if(!rf)fail("reference output");
 if(!freeze) {snprintf(path,sizeof path,"%s.assembly.bin",argv[3]);af=fopen(path,"wb");if(!af)fail("assembly output");}
 FILE *f=fopen(argv[2],freeze?"wb":"rb");if(!f)fail("corpus open");
 uint32_t count=64+14*4+12+3;char magic[8]={'C','P','Q','T','U','V','0','1'};
 if(freeze) {
  writeall(f,magic,8);writeall(f,&count,4);int number=0;
  for(int mask=0;mask<64;++mask) {record c=prepare(number++,mask,2,3,1,3,2,-1,mask&1);buffer b[10];generate(&c,b);savecase(f,&c,b);check(&c,b,NULL,rf,0);for(int j=0;j<10;++j)release(&b[j]);}
  const int width[4]={1,3,5,24};
  for(int p=0;p<14;++p)for(int j=0;j<4;++j) {int np=width[j];record c=prepare(number++,63,p,np,np>3?2:1,np==24?8:np,3,-1,p!=11 && j&1);buffer b[10];generate(&c,b);savecase(f,&c,b);check(&c,b,NULL,rf,0);for(int z=0;z<10;++z)release(&b[z]);}
  for(int it=0;it<12;++it) {record c=prepare(number++,63,0,5,1,5,2,it,0);buffer b[10];generate(&c,b);savecase(f,&c,b);check(&c,b,NULL,rf,0);for(int j=0;j<10;++j)release(&b[j]);}
  for(int z=0;z<3;++z) {record c=prepare(number++,63,0,5,z==0?5:1,z==0?4:5,z==1?0:1,-1,0);if(z==2)c=prepare(c.h[0],0,12,5,1,5,1,-1,0);buffer b[10];generate(&c,b);savecase(f,&c,b);check(&c,b,NULL,rf,0);for(int j=0;j<10;++j)release(&b[j]);}
  if((uint32_t)number!=count)fail("case count");
 } else {
  char got[8];readall(f,got,8);readall(f,&count,4);if(memcmp(got,magic,8)||count!=135)fail("corpus header");
  for(uint32_t j=0;j<count;++j) {
   record c={0};readall(f,c.h,48);readall(f,c.d,40);
   if(c.h[0]!=(int32_t)j||c.h[8]<0||c.h[8]>8||c.h[6]<0||c.h[7]<0||c.h[2]<=0||c.h[5]<0)fail("case metadata");
   readall(f,c.maps,(size_t)c.h[8]*20);readall(f,c.alias,28);
   /* Zero-descriptor cases retain valid, inactive named objects. */
   if(c.h[8]==0)for(int z=0;z<8;++z) {c.maps[z][2]=z+1;c.maps[z][3]=c.maps[z][4]=-99;}
   size_t n[10];sizes(&c,n);buffer b[10];for(int z=0;z<10;++z) {b[z]=allocbuf(n[z]);readall(f,b[z].p,n[z]*8);}
   check(&c,b,af,rf,1);for(int z=0;z<10;++z)release(&b[z]);
  }
  if(fgetc(f)!=EOF)fail("extra corpus bytes");
 }
 if(fclose(f)||fclose(rf)||(af&&fclose(af)))fail("file close");
 printf("{\"stage\":\"CPQTUV\",\"mode\":\"%s\",\"cases\":%" PRIu64 ",\"compared_bytes\":%" PRIu64 ",\"differing_bytes\":0,\"physical_points\":%" PRIu64 ",\"water_mass_points\":%" PRIu64 ",\"fpcr\":\"%016" PRIx64 "\"}\n",freeze?"reference-physics-freeze":"assembly-verification",calls,bytes,physical_points,mass_points,initial_fpcr);
 return 0;
}

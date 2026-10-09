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
static kernel reference;
static const int32_t *step;
static const double *gravity,*planet;
static const void *image;
static FILE *inputs,*source,*native;
static uint64_t calls,bytes,input_bytes,independent,phases[25],cells;
static int32_t min_dims[4]={INT32_MAX,INT32_MAX,INT32_MAX,INT32_MAX};
static int32_t max_dims[4]={0,0,0,0};
static double minima[14],maxima[14],global_min[2]={DBL_MAX,DBL_MAX},global_max[2];
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
__attribute__((destructor)) static void finish(void){
 if(!source)return;
 if(fclose(inputs)||fclose(source)||(native&&fclose(native)))fail("capture close");
 if(!calls)fail("no original forecast calls");
 FILE *f=fopen("rrtm-prepare-gases-metadata.json","wb");if(!f)fail("metadata open");
 fprintf(f,"{\"calls\":%" PRIu64 ",\"active_layer_cells\":%" PRIu64 ",\"complete_record_bytes\":%" PRIu64 ",\"complete_input_bytes\":%" PRIu64 ",\"independent_relations\":%" PRIu64 ",\"native_compared\":%s,\"differing_bytes\":0,\"FPCR_zero_every_entry\":true,\"source_return_offset\":\"0xb1e9a4\",\"gravity_range\":[%.17g,%.17g],\"planet_scale_range\":[%.17g,%.17g],\"dimensions\":[",calls,cells,bytes,input_bytes,independent,native?"true":"false",global_min[0],global_max[0],global_min[1],global_max[1]);
 for(int k=0;k<4;++k)fprintf(f,"%s[%d,%d]",k?",":"",min_dims[k],max_dims[k]);
 fputs("],\"input_ranges\":[",f);
 for(int k=0;k<14;++k)fprintf(f,"%s[%.17g,%.17g]",k?",":"",minima[k],maxima[k]);
 fprintf(f,"],\"legacy_wet_max_relative_bias\":{\"total_mass\":%.17Lg,\"dry_mass\":%.17Lg,\"water_mass\":%.17Lg,\"observed_total_mass\":%.17Lg,\"observed_dry_mass\":%.17Lg,\"observed_water_mass\":%.17Lg},\"step_calls\":[",max_total_bias,max_dry_bias,max_water_bias,max_observed_total,max_observed_dry,max_observed_water);
 for(int k=0;k<25;++k)fprintf(f,"%s%" PRIu64,k?",":"",phases[k]);
 fputs("]}\n",f);if(fclose(f))fail("metadata close");
 fprintf(stderr,"RRTM PREPARE GASES %s PASS calls=%" PRIu64 " cells=%" PRIu64 " complete_record_bytes=%" PRIu64 " independent=%" PRIu64 " differing_bytes=0 FPCR=0\n",native?"NATIVE":"SOURCE",calls,cells,bytes,independent);
}
void rrtm_prepare_gases_(PARAMETERS){
 uint64_t fp;__asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("every-entry FPCR");
 if(!reference){
  void *s=dlsym(RTLD_NEXT,"rrtm_prepare_gases_");if(!s)fail("original source binding");memcpy(&reference,&s,sizeof reference);
  Dl_info original={0};if(!dladdr(s,&original)||!original.dli_fbase)fail("original source image");image=original.dli_fbase;
  step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");gravity=dlsym(RTLD_NEXT,"__yomcst_MOD_rg");planet=dlsym(RTLD_NEXT,"__yomdyncore_MOD_rplrg");
  if(!step||!gravity||!planet)fail("declared read-only global inputs");
  inputs=fopen("rrtm-prepare-gases-inputs.bin","wb");source=fopen("rrtm-prepare-gases-fortran.bin","wb");
  if(rrtm_prepare_gases_assembly_)native=fopen("rrtm-prepare-gases-assembly.bin","wb");
  if(!inputs||!source||(rrtm_prepare_gases_assembly_&&!native))fail("capture open");
  if(setvbuf(inputs,NULL,_IOFBF,1<<20)||setvbuf(source,NULL,_IOFBF,1<<20)||(native&&setvbuf(native,NULL,_IOFBF,1<<20)))fail("capture buffers");
  for(int k=0;k<14;++k){minima[k]=DBL_MAX;maxima[k]=-DBL_MAX;}
 }
 Dl_info caller={0};void *ret=__builtin_return_address(0);
 if(!dladdr(ret,&caller)||caller.dli_fbase!=image||(uintptr_t)ret-(uintptr_t)image!=0xb1e9a4||*step<0||*step>24)fail("original source-scoped caller and phase");
 void *all[27]={ARGUMENTS};int32_t d[4];
 for(int k=0;k<4;++k){if(!all[k]||(uintptr_t)all[k]%4)fail("integer argument alignment");memcpy(&d[k],all[k],4);min_dims[k]=d[k]<min_dims[k]?d[k]:min_dims[k];max_dims[k]=d[k]>max_dims[k]?d[k]:max_dims[k];}
 const int ni=d[0],nf=d[1],lon=d[2],lev=d[3],n=nf-ni+1;
 if(lon<1||lon>4096||lev<0||lev>512||ni<1||nf<ni-1||nf>lon)fail("complete source-only capacities");
 const size_t full=(size_t)lon*lev,half=(size_t)lon*(lev+1),selected=(size_t)n*lev,selected_half=(size_t)n*(lev+1);
 const double *in[14];size_t in_sizes[14];unsigned char *snap[14];
 size_t out_sizes[9]={selected*8,selected*8,selected*35*8,selected*4*8,selected*8,selected*8,selected_half*8,selected_half*8,(size_t)n*4};
 double globals[2]={*gravity,*planet};
 if(!isfinite(globals[0])||globals[0]<=0||!isfinite(globals[1])||globals[1]<=0)fail("positive declared gravity");
 int32_t h[2]={*step,1};
 FILE *streams[3]={inputs,source,native};
 for(int z=0;z<3;++z)if(streams[z]){writeall(streams[z],&calls,8);writeall(streams[z],h,8);writeall(streams[z],d,16);writeall(streams[z],globals,16);}
 size_t ib=48,ob=48;
 for(int k=0;k<14;++k){
  in[k]=all[k+4];in_sizes[k]=(k==0||k==2?half:full)*8;ib+=in_sizes[k];
  if(in_sizes[k]&&(!in[k]||(uintptr_t)in[k]%8||(uintptr_t)in[k]>UINTPTR_MAX-in_sizes[k]))fail("complete aligned input capacity");
  snap[k]=malloc(in_sizes[k]?in_sizes[k]:1);if(!snap[k])fail("input snapshot allocation");memcpy(snap[k],in[k],in_sizes[k]);writeall(inputs,in[k],in_sizes[k]);
  for(size_t z=0;z<in_sizes[k]/8;++z){if(!isfinite(in[k][z]))fail("finite captured input");minima[k]=fmin(minima[k],in[k][z]);maxima[k]=fmax(maxima[k],in[k][z]);}
 }
 void *shadow[9];
 for(int k=0;k<9;++k){
  void *p=all[k+18];size_t size=out_sizes[k];ob+=size;
  if(size&&(!p||(uintptr_t)p%(k==8?4:8)||(uintptr_t)p>UINTPTR_MAX-size))fail("complete aligned output capacity");
  if(size)for(int z=0;z<2;++z){const uintptr_t a=(uintptr_t)p,b=(uintptr_t)(z?planet:gravity);if(a<b+8&&b<a+size)fail("output alias with read-only gravity");}
  if(size)for(int z=0;z<18+k;++z){
   const uintptr_t a=(uintptr_t)p,b=(uintptr_t)all[z];const size_t other=z<4?4:z<18?in_sizes[z-4]:out_sizes[z-18];
   if(other&&a<b+other&&b<a+size)fail("disjoint output mutation rule");
  }
  shadow[k]=malloc(size?size:1);if(!shadow[k])fail("source output shadow allocation");
 }
 if(native){
  reference(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,shadow[0],shadow[1],shadow[2],shadow[3],shadow[4],shadow[5],shadow[6],shadow[7],shadow[8]);
  rrtm_prepare_gases_assembly_(ARGUMENTS);
 }else{
  reference(ARGUMENTS);for(int k=0;k<9;++k)memcpy(shadow[k],all[k+18],out_sizes[k]);
 }
 __asm__ volatile("mrs %0,fpcr":"=r"(fp));if(fp)fail("preserved FPCR");
 for(int k=0;k<4;++k)if(memcmp(all[k],&d[k],4))fail("read-only dimension mutation");
 if(memcmp(gravity,globals,8)||memcmp(planet,globals+1,8))fail("read-only global mutation");
 for(int k=0;k<14;++k){if(memcmp(in[k],snap[k],in_sizes[k]))fail("complete read-only input mutation");free(snap[k]);}
 const double *out[8];for(int k=0;k<8;++k)out[k]=shadow[k];
 science(d,in,out,shadow[8],globals[0],globals[1]);
 for(int k=0;k<9;++k){
  if(native&&memcmp(shadow[k],all[k+18],out_sizes[k])){
   size_t first=0;const unsigned char *a=shadow[k],*b=all[k+18];while(a[first]==b[first])++first;
   fprintf(stderr,"RRTM first mismatch call=%" PRIu64 " step=%d field=%d byte=%zu source=%02x native=%02x\n",calls,*step,k+1,first,a[first],b[first]);fail("complete output bytes");
  }
  writeall(source,shadow[k],out_sizes[k]);if(native)writeall(native,all[k+18],out_sizes[k]);free(shadow[k]);
 }
 for(int k=0;k<2;++k){global_min[k]=fmin(global_min[k],globals[k]);global_max[k]=fmax(global_max[k],globals[k]);}
 ++calls;++phases[*step];bytes+=ob;input_bytes+=ib;
}

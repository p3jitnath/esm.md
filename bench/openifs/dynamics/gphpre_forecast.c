/* Compare complete GPHPRE calls and archive every output bit.
 * Inputs use Pa. The driver copies storage and supplies no pressure calculation. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define HP_ARGS const int32_t *np,const int32_t *nf,const int32_t *ks, \
 const int32_t *ke,const void *vab,const void *cver,double *ph,double *xy,double *pf
typedef void (*kernel)(HP_ARGS);
void gphpre_assembly_(HP_ARGS);
static kernel reference;
static const int32_t *step,*indices;
static const double *top_pressure,*gas_constant,*heat_capacity;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,mode_calls[4],option_calls[4],closed_calls;
static void fail(const char *message) {
    fprintf(stderr,"GPHPRE forecast check failed %s\n",message);_Exit(2);
}
static uint64_t bits(double value) {uint64_t n;memcpy(&n,&value,8);return n;}
static void write_bytes(FILE *file,const void *data,size_t count) {
    if(count && fwrite(data,1,count,file)!=count) fail("capture write");
}
static int overlap(const void *a,size_t na,const void *b,size_t nb) {
    uintptr_t x=(uintptr_t)a,y=(uintptr_t)b;
    if(x>UINTPTR_MAX-na || y>UINTPTR_MAX-nb) fail("buffer address overflow");
    return na && nb && x<y+nb && y<x+na;
}
__attribute__((destructor)) static void finish(void) {
    if(!ao) return;
    if(fclose(ao) || fclose(ro) || fclose(io)) fail("capture close");
    fprintf(stderr,"GPHPRE FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64 " differing_bytes=0 finite_element=%" PRIu64 " logarithmic=%" PRIu64 " approximate_1=%" PRIu64 " approximate_2=%" PRIu64 " pressure_only=%" PRIu64 " coefficients_only=%" PRIu64 " full_only=%" PRIu64 " both=%" PRIu64 " closed_top=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        calls,bytes,mode_calls[0],mode_calls[1],mode_calls[2],mode_calls[3],
        option_calls[0],option_calls[1],option_calls[2],option_calls[3],
        closed_calls,last_fpcr);
}
void gphpre_(HP_ARGS) {
    __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
    if(last_fpcr&UINT64_C(0x03c80000)) fail("floating-point control");
    if(!np || !nf || !ks || !ke || !vab || !cver) fail("scalar or configuration address");
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gphpre_");
        if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);
        step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");
        indices=dlsym(RTLD_NEXT,"__intdyn_mod_MOD_yytxyb");
        top_pressure=dlsym(RTLD_NEXT,"__yomvert_MOD_toppres");
        gas_constant=dlsym(RTLD_NEXT,"__yomcst_MOD_rd");
        heat_capacity=dlsym(RTLD_NEXT,"__yomcst_MOD_rcvd");
        if(!step || !indices || !top_pressure || !gas_constant || !heat_capacity) fail("module configuration");
        ao=fopen("gphpre-assembly.bin","wb");ro=fopen("gphpre-fortran.bin","wb");io=fopen("gphpre-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    int32_t fe,nd,lap;double rhydr;
    memcpy(&fe,(const char *)cver+52,4);memcpy(&nd,(const char *)cver+4,4);
    memcpy(&lap,cver,4);memcpy(&rhydr,(const char *)cver+8,8);fe=fe!=0;lap=lap!=0;
    int opts=(xy?1:0)|(pf?2:0),active=*nf>0 && *ke>=*ks,mode=fe?0:nd+1;
    if(*np<=0 || *nf<0 || *ks<1 || *ks>*np || *ke<*ks-1 || *ke>*np ||
       (opts && !active) || (!fe && (nd<0 || nd>2))) fail("shape or mode");
    size_t cells=(size_t)*np*(size_t)*nf;
    if(cells>(size_t)INT64_MAX/8 || (size_t)*np>(size_t)INT64_MAX/8-cells) fail("pressure extent");
    size_t sizes[3]={(cells+(size_t)*np)*8,0,pf?cells*8:0};
    if(opts) {
        if(indices[7]<=0 || cells>(size_t)INT64_MAX/8/(size_t)indices[7]) fail("coefficient extent");
        if(xy) sizes[1]=cells*(size_t)indices[7]*8;
        for(int f=0;f<(fe?5:7);++f) {
            if(indices[f]<1 || indices[f]>indices[7]) fail("field index");
            for(int g=0;g<f;++g) if(indices[g]==indices[f]) fail("duplicate used field");
        }
    }
    double *outputs[3]={ph,xy,pf},*shadow[3]={NULL,NULL,NULL};
    unsigned char vb[512],cv[216];int32_t fields[8];
    memcpy(vb,vab,512);memcpy(cv,cver,216);memcpy(fields,indices,32);
    double constants[4]={*top_pressure,*gas_constant,*heat_capacity,rhydr};
    for(int f=0;f<3;++f) if(sizes[f]) {
        if(!outputs[f] || ((uintptr_t)outputs[f]&7) ||
           overlap(outputs[f],sizes[f],vab,512) || overlap(outputs[f],sizes[f],cver,216)) fail("output storage");
        for(int g=0;g<f;++g) if(overlap(outputs[f],sizes[f],outputs[g],sizes[g])) fail("output overlap");
        shadow[f]=malloc(sizes[f]);if(!shadow[f]) fail("output copy allocation");
        memcpy(shadow[f],outputs[f],sizes[f]);
    }
    int first=1;
    const size_t offsets[7]={128,64,256,320,384,448,192};
    const double *coeff[7]={NULL,NULL,NULL,NULL,NULL,NULL,NULL};
    double *copies[7]={NULL,NULL,NULL,NULL,NULL,NULL,NULL};
    size_t lengths[7]={0};int64_t bounds[14]={0};
    int used[7]={active,active,active && opts && fe,active && opts && fe,
                active && opts && fe,active && opts,active && opts && !fe};
    for(int f=0;f<7;++f) {
        if(f==2 && active) for(int32_t i=*ks-1;i<*ke;++i) {
            double ps=ph[(size_t)*nf*(size_t)*np+(size_t)i];
            if(!isfinite(ps) || ps<=0) fail("surface pressure");
            if(opts) {
                double product=coeff[1][-bounds[2]]*ps;
                double top=coeff[0][-bounds[0]]+product;
                if(top<0 || !isfinite(top)) fail("top pressure");
                if(top<=constants[0]) first=2;
            }
        }
        if(!used[f] || (f==6 && first>*nf)) {used[f]=0;continue;}
        const char *descriptor=(const char *)vab+offsets[f];
        int64_t element,stride;
        memcpy(&coeff[f],descriptor,8);memcpy(&element,descriptor+16,8);memcpy(&stride,descriptor+40,8);
        memcpy(&bounds[2*f],descriptor+48,8);memcpy(&bounds[2*f+1],descriptor+56,8);
        int64_t lo=bounds[2*f],hi=bounds[2*f+1],lower=f<2?0:1,upper=f<2?*nf-1:*nf;
        if(!coeff[f] || ((uintptr_t)coeff[f]&7) || element!=8 || stride!=1 ||
           lo>lower || hi<upper || lo==INT64_MIN || hi-lo<0 ||
           (uint64_t)(hi-lo)>(uint64_t)INT64_MAX/8-1) fail("coefficient allocation");
        lengths[f]=(size_t)(hi-lo+1)*8;
        for(int g=0;g<3;++g) if(overlap(outputs[g],sizes[g],coeff[f],lengths[f])) fail("output overlaps coefficients");
        copies[f]=malloc(lengths[f]);if(!copies[f]) fail("coefficient copy allocation");
        memcpy(copies[f],coeff[f],lengths[f]);
        for(int64_t j=lower;j<=upper;++j) if(!isfinite(coeff[f][j-lo])) fail("nonfinite coefficient");
    }
    if(opts && (!isfinite(constants[0]) || constants[0]<=0 ||
       !isfinite(rhydr) || rhydr<0 || (nd==1 && !fe &&
       (!isfinite(constants[1]) || constants[1]<=0 || !isfinite(constants[2]) || constants[2]<=0)))) fail("closure constants");
    if(opts && !fe && nd==2 && first==2 && *nf<2) fail("top closure next layer");
    ++calls;++mode_calls[mode];++option_calls[opts];if(opts && first==2) ++closed_calls;
    int32_t dims[9]={*np,*nf,*ks,*ke,opts,fe,nd,lap,indices[7]};
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);write_bytes(file,step,4);write_bytes(file,dims,36);
        write_bytes(file,fields,32);write_bytes(file,bounds,112);write_bytes(file,constants,32);
    }
    for(int f=0;f<3;++f) write_bytes(io,outputs[f],sizes[f]);
    for(int f=0;f<7;++f) if(used[f]) write_bytes(io,coeff[f],lengths[f]);
    reference(np,nf,ks,ke,vab,cver,shadow[0],shadow[1],shadow[2]);
    uint64_t middle;__asm__ volatile("mrs %0,fpcr":"=r"(middle));
    if(middle!=last_fpcr) fail("reference changed FPCR");
    gphpre_assembly_(np,nf,ks,ke,vab,cver,ph,xy,pf);
    for(int f=0;f<3;++f) {
        for(size_t k=0;k<sizes[f]/8;++k) if(bits(outputs[f][k])!=bits(shadow[f][k])) {
            fprintf(stderr,"Mismatch stage=GPHPRE step=%d call=%" PRIu64 " output=%d field=%zu level=%zu column=%zu asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                *step,calls,f,cells?k/cells+1:0,k/(size_t)*np,k%(size_t)*np+1,bits(outputs[f][k]),bits(shadow[f][k]));_Exit(1);
        }
        write_bytes(ao,outputs[f],sizes[f]);write_bytes(ro,shadow[f],sizes[f]);free(shadow[f]);
    }
    if(active) for(int32_t i=*ks-1;i<*ke;++i) {
        double previous=ph[i];
        if(previous<0 || !isfinite(previous)) fail("top output");
        for(int32_t j=1;j<=*nf;++j) {
            double lower=ph[(size_t)j*(size_t)*np+(size_t)i],depth=lower-previous;
            if(!isfinite(lower) || depth<=0) fail("ordered boundary outputs");
            if(opts && !fe && j>=first) {
                double ratio=depth/previous;
                if(ratio<0.001) fail("unresolved logarithmic pressure layer");
            }
            if(pf) {
                double full=pf[(size_t)(j-1)*(size_t)*np+(size_t)i];
                if(!isfinite(full) || full<=0) fail("full-pressure output");
            }
            previous=lower;
        }
    }
    for(int f=0;f<7;++f) {
        if(copies[f] && memcmp(copies[f],coeff[f],lengths[f])) fail("changed coefficient bytes");
        free(copies[f]);
    }
    uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));
    if(memcmp(vb,vab,512) || memcmp(cv,cver,216) || memcmp(fields,indices,32) ||
       bits(constants[0])!=bits(*top_pressure) || bits(constants[1])!=bits(*gas_constant) ||
       bits(constants[2])!=bits(*heat_capacity) || after!=last_fpcr) fail("changed configuration or FPCR");
    bytes+=224+sizes[0]+sizes[1]+sizes[2];
}

/* Compare complete GPGRGEO calls on separate forecast output arrays.
 * Gradients retain the caller's horizontal coordinate units.
 * This capture is scoped to the six-field CPG_GP_HYD caller allocation.
 * It supplies no numerical stage; FE needs verified direct VERDISINT. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define GRGEO_ARGS const void *geometry,const int32_t *np,const int32_t *ks, \
 const int32_t *ke,const int32_t *nl,const double *h,const double *gl, \
 const double *gm,const double *depth,const double *alpha,const double *xy, \
 const double *ol,const double *om,double *fl,double *fm,double *hl,double *hm, \
 const int32_t *nh,const double *ratio,const double *ql,const double *qm, \
 double *nlout,double *nmout
typedef void (*kernel)(GRGEO_ARGS);
void gpgrgeo_assembly_(GRGEO_ARGS);
static kernel reference;
/* Optional diagnostic hooks exclude this private source comparison from
 * genuine forecast integration counts. They supply no numerical work. */
static void (*reference_begin)(void),(*reference_end)(void);
static const int32_t *step,*fieldmap,*caller_map;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,mode_calls[2],flag_calls[2],optional_calls[4];
static void fail(const char *message) {
    fprintf(stderr,"GPGRGEO forecast check failed %s\n",message);_Exit(2);
}
static uint64_t bits(double x) {uint64_t n;memcpy(&n,&x,8);return n;}
static void write_bytes(FILE *file,const void *data,size_t count) {
    if(count && fwrite(data,1,count,file)!=count) fail("capture write");
}
static int overlap(const void *a,size_t na,const void *b,size_t nb) {
    uintptr_t pa=(uintptr_t)a,pb=(uintptr_t)b;
    if(pa>UINTPTR_MAX-na || pb>UINTPTR_MAX-nb) fail("buffer address overflow");
    return na && nb && pa<pb+nb && pb<pa+na;
}
static int32_t integer32(const void *p,size_t off) {
    int32_t n;memcpy(&n,(const char *)p+off,4);return n;
}
static int64_t integer64(const void *p,size_t off) {
    int64_t n;memcpy(&n,(const char *)p+off,8);return n;
}
static void *object_pointer(const void *p,size_t off) {
    void *data;memcpy(&data,(const char *)p+off,sizeof data);return data;
}
static void *copy_bytes(const void *data,size_t count) {
    void *copy=malloc(count?count:8);
    if(!copy) fail("state copy allocation");
    if(count) memcpy(copy,data,count);
    return copy;
}
static size_t allocation_extent(int64_t lower,int64_t upper) {
    if(upper<lower) return 0;
    uint64_t extent=(uint64_t)upper-(uint64_t)lower+1;
    if(!extent || extent>(uint64_t)SIZE_MAX/8) fail("coefficient extent overflow");
    return (size_t)extent;
}
__attribute__((destructor)) static void finish(void) {
    if(!ao) return;
    if(fclose(ao) || fclose(ro) || fclose(io)) fail("capture close");
    fprintf(stderr,"GPGRGEO FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64
        " differing_bytes=0 conventional=%" PRIu64 " finite_element=%" PRIu64
        " hydrostatic=%" PRIu64 " pressure_corrected=%" PRIu64
        " optional_none=%" PRIu64 " optional_L=%" PRIu64 " optional_M=%" PRIu64
        " optional_both=%" PRIu64 " FPCR=%016" PRIx64 "\n",
        calls,bytes,mode_calls[0],mode_calls[1],flag_calls[0],flag_calls[1],
        optional_calls[0],optional_calls[1],optional_calls[2],optional_calls[3],last_fpcr);
}
void gpgrgeo_(GRGEO_ARGS) {
    __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
    if(last_fpcr&UINT64_C(0x03c80000)) fail("floating-point control");
    if(!np || !ks || !ke || !nl || !geometry) fail("argument addresses");
    if(*np<=0 || *nl<0 || *ks<1 || *ks>*np || *ke<*ks-1 || *ke>*np)
        fail("shape or interval");
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gpgrgeo_");
        if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);
        step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");
        void *begin=dlsym(RTLD_DEFAULT,"vertical_forecast_reference_begin");
        void *end=dlsym(RTLD_DEFAULT,"vertical_forecast_reference_end");
        if(begin && end) {
            memcpy(&reference_begin,&begin,sizeof reference_begin);
            memcpy(&reference_end,&end,sizeof reference_end);
        }
        fieldmap=dlsym(RTLD_NEXT,"__intdyn_mod_MOD_yytxybder");
        caller_map=dlsym(RTLD_NEXT,"__intdyn_mod_MOD_yytxybder0");
        if(!step || !fieldmap || !caller_map) fail("forecast metadata");
        ao=fopen("gpgrgeo-assembly.bin","wb");ro=fopen("gpgrgeo-fortran.bin","wb");
        io=fopen("gpgrgeo-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    int32_t flag=nh?*nh:0;
    if(flag!=0 && flag!=1) fail("logical flag");
    if(flag && (!ratio || !ql || !qm)) fail("missing pressure correction");
    const void *cv=object_pointer(geometry,3264);
    if(!cv) fail("vertical configuration");
    int32_t mode=integer32(cv,52)!=0,ibc=integer32(cv,36);
    int active=*nl>0 && *ke>=*ks,surface=*ke>=*ks;
    if(mode && active && (ibc<0 || ibc>3)) fail("finite-element boundary option");
    int32_t declared=fieldmap[9],capacity=caller_map[9];
    if(declared<=0 || capacity<=0) fail("derivative field capacity");
    for(int f=0;f<(mode?2:4);++f)
        if(fieldmap[f]<1 || fieldmap[f]>declared || fieldmap[f]>capacity ||
           fieldmap[f]!=caller_map[f]) fail("unsupported caller derivative map");
    size_t count=(size_t)*np*(size_t)*nl,half=(size_t)*np*((size_t)*nl+1);
    if(count>(size_t)INT64_MAX/8 || half>(size_t)INT64_MAX/8 ||
       count>(size_t)INT64_MAX/8/(size_t)capacity) fail("buffer extent");
    size_t fullbytes=count*8,halfbytes=half*8;
    double *out[6]={hl,hm,fl,fm,nlout,nmout},*shadow[6],*incoming[6];
    int present[6]={1,1,1,1,nlout!=NULL,nmout!=NULL};
    size_t sizes[6]={halfbytes,halfbytes,fullbytes,fullbytes,
        nlout?fullbytes:0,nmout?fullbytes:0};
    const double *inputs[11]={h,gl,gm,depth,alpha,xy,ol,om,ratio,ql,qm};
    size_t input_sizes[11]={active?fullbytes:0,active?fullbytes:0,active?fullbytes:0,
        active?fullbytes:0,active && !mode?fullbytes:0,
        active?fullbytes*(size_t)capacity:0,surface?(size_t)*np*8:0,
        surface?(size_t)*np*8:0,active && flag?fullbytes:0,
        active && flag?fullbytes:0,active && flag?fullbytes:0};
    void *input_copy[11]={0};
    unsigned char geometry_before[17096],cv_before[216],vt_before[320],vf_before[2176];
    int32_t map_before[10],caller_before[10],dimensions_before[4]={*np,*ks,*ke,*nl};
    memcpy(geometry_before,geometry,sizeof geometry_before);
    memcpy(cv_before,cv,sizeof cv_before);
    memcpy(map_before,fieldmap,sizeof map_before);memcpy(caller_before,caller_map,sizeof caller_before);
    const void *vt=NULL,*vf=NULL;
    double *coordinate_data=NULL,*coordinate_level1=NULL,*matrix_data=NULL;
    void *coordinate_copy=NULL,*matrix_copy=NULL;
    size_t coordinate_bytes=0,matrix_bytes=0;
    int64_t bounds[6]={0};
    for(int f=0;f<6;++f) {
        if(sizes[f] && (!out[f] || ((uintptr_t)out[f]&7))) fail("output storage");
        for(int k=0;k<f;++k)
            if(overlap(out[f],sizes[f],out[k],sizes[k])) fail("overlapping outputs");
        if(overlap(out[f],sizes[f],geometry,17096) || overlap(out[f],sizes[f],cv,216) ||
           overlap(out[f],sizes[f],fieldmap,40) || overlap(out[f],sizes[f],caller_map,40))
            fail("output overlaps metadata");
        incoming[f]=copy_bytes(out[f],sizes[f]);shadow[f]=copy_bytes(out[f],sizes[f]);
    }
    for(int f=0;f<11;++f) if(input_sizes[f]) {
        if(!inputs[f] || ((uintptr_t)inputs[f]&7)) fail("active input storage");
        for(int k=0;k<6;++k)
            if(overlap(out[k],sizes[k],inputs[f],input_sizes[f])) fail("output overlaps input");
        input_copy[f]=copy_bytes(inputs[f],input_sizes[f]);
    }
    if(mode && active) {
        vt=object_pointer(geometry,3248);vf=object_pointer(geometry,3256);
        if(!vt || !vf) fail("finite-element geometry targets");
        memcpy(vt_before,vt,sizeof vt_before);memcpy(vf_before,vf,sizeof vf_before);
        const void *descriptor=(const char *)vt+256;
        coordinate_data=object_pointer(descriptor,0);
        bounds[0]=integer64(descriptor,48);bounds[1]=integer64(descriptor,56);
        size_t extent=allocation_extent(bounds[0],bounds[1]);
        if(!coordinate_data || ((uintptr_t)coordinate_data&7) ||
           integer64(descriptor,16)!=8 || integer64(descriptor,32)!=8 ||
           integer64(descriptor,40)!=1 || bounds[0]>1 || bounds[1]<*nl)
            fail("coordinate descriptor");
        uint64_t shift=UINT64_C(1)-(uint64_t)bounds[0];
        if(shift>(uint64_t)INT64_MAX/8) fail("coordinate address offset");
        coordinate_level1=coordinate_data+(size_t)shift;
        coordinate_bytes=extent*8;coordinate_copy=copy_bytes(coordinate_data,coordinate_bytes);
        descriptor=(const char *)vf+(ibc==0?64:ibc==2?1296:240);
        matrix_data=object_pointer(descriptor,0);
        bounds[2]=integer64(descriptor,48);bounds[3]=integer64(descriptor,56);
        bounds[4]=integer64(descriptor,72);bounds[5]=integer64(descriptor,80);
        size_t rows=allocation_extent(bounds[2],bounds[3]),columns=allocation_extent(bounds[4],bounds[5]);
        size_t expected_columns=(size_t)*nl+((ibc==1 || ibc==3)?2:0);
        if(!matrix_data || ((uintptr_t)matrix_data&7) || integer64(descriptor,16)!=8 ||
           integer64(descriptor,32)!=8 || integer64(descriptor,40)!=1 ||
           integer64(descriptor,64)!=(int64_t)rows || rows!=(size_t)*nl+1 ||
           columns!=expected_columns || (rows && columns>(size_t)INT64_MAX/8/rows))
            fail("integration matrix descriptor");
        matrix_bytes=rows*columns*8;matrix_copy=copy_bytes(matrix_data,matrix_bytes);
        for(int f=0;f<6;++f)
            if(overlap(out[f],sizes[f],vt,320) || overlap(out[f],sizes[f],vf,2176) ||
               overlap(out[f],sizes[f],coordinate_data,coordinate_bytes) ||
               overlap(out[f],sizes[f],matrix_data,matrix_bytes)) fail("output overlaps coefficients");
        for(int32_t j=0;j<*nl;++j)
            if(!isfinite(coordinate_level1[j])) fail("nonfinite coordinate width");
        for(size_t k=0;k<matrix_bytes/8;++k)
            if(!isfinite(matrix_data[k])) fail("nonfinite integration matrix");
    }
    for(int32_t j=0;j<*nl;++j) for(int32_t i=*ks-1;i<*ke;++i) {
        size_t k=(size_t)j*(size_t)*np+(size_t)i;
        for(int f=0;f<5;++f) if(f<4 || !mode)
            if(!isfinite(inputs[f][k])) fail("nonfinite active thermal or weight input");
        for(int f=0;f<(mode?2:4);++f)
            if(!isfinite(xy[(size_t)(fieldmap[f]-1)*count+k])) fail("nonfinite active derivative");
        if(flag && (!isfinite(ratio[k]) || !isfinite(ql[k]) || !isfinite(qm[k])))
            fail("nonfinite active pressure correction");
    }
    for(int32_t i=*ks-1;i<*ke;++i)
        if(!isfinite(ol[i]) || !isfinite(om[i])) fail("nonfinite surface gradient");
    ++calls;++mode_calls[mode];++flag_calls[flag];
    int optional=(nlout!=NULL)+2*(nmout!=NULL);++optional_calls[optional];
    int mask=(nh!=NULL)+2*(ratio!=NULL)+4*(ql!=NULL)+8*(qm!=NULL)+
        16*(nlout!=NULL)+32*(nmout!=NULL);
    int32_t dims[10]={*np,*ks,*ke,*nl,mode,ibc,flag,mask,declared,capacity};
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);write_bytes(file,step,4);write_bytes(file,dims,40);
        write_bytes(file,fieldmap,16);write_bytes(file,bounds,48);
    }
    for(int f=0;f<6;++f) if(present[f]) write_bytes(io,incoming[f],sizes[f]);
    for(int f=0;f<11;++f) if(input_sizes[f]) write_bytes(io,inputs[f],input_sizes[f]);
    if(mode && active) {
        write_bytes(io,coordinate_level1,(size_t)*nl*8);write_bytes(io,matrix_data,matrix_bytes);
    }
    if(reference_begin) reference_begin();
    reference(geometry,np,ks,ke,nl,h,gl,gm,depth,alpha,xy,ol,om,
        shadow[2],shadow[3],shadow[0],shadow[1],nh,ratio,ql,qm,
        nlout?shadow[4]:NULL,nmout?shadow[5]:NULL);
    if(reference_end) reference_end();
    gpgrgeo_assembly_(geometry,np,ks,ke,nl,h,gl,gm,depth,alpha,xy,ol,om,
        fl,fm,hl,hm,nh,ratio,ql,qm,nlout,nmout);
    const char *names[6]={"PHIHL","PHIHM","PHIFL","PHIFM","PNH1L","PNH1M"};
    for(int f=0;f<6;++f) {
        for(size_t k=0;k<sizes[f]/8;++k) {
            if(bits(out[f][k])!=bits(shadow[f][k])) {
                fprintf(stderr,"Mismatch stage=GPGRGEO step=%d call=%" PRIu64
                    " mode=%d pressure_corrected=%d field=%s level=%zu column=%zu"
                    " asm=%016" PRIx64 " ref=%016" PRIx64 "\n",
                    *step,calls,mode,flag,names[f],k/(size_t)*np+(f<2?0:1),
                    k%(size_t)*np+1,bits(out[f][k]),bits(shadow[f][k]));
                _Exit(1);
            }
            int32_t column=(int32_t)(k%(size_t)*np)+1;
            int used=column>=*ks && column<=*ke && (f<2 || *nl>0);
            if(used && !isfinite(out[f][k])) fail("nonfinite active output");
            if(!used && bits(out[f][k])!=bits(incoming[f][k])) fail("changed inactive output");
        }
        if(present[f]) {
            write_bytes(ao,out[f],sizes[f]);write_bytes(ro,shadow[f],sizes[f]);
            bytes+=sizes[f];
        }
        free(shadow[f]);free(incoming[f]);
    }
    for(int32_t i=*ks-1;i<*ke;++i) {
        size_t k=(size_t)*nl*(size_t)*np+(size_t)i;
        if(bits(hl[k])!=bits(ol[i]) || bits(hm[k])!=bits(om[i])) fail("surface anchor");
    }
    for(int f=0;f<11;++f) {
        if(input_copy[f] && memcmp(inputs[f],input_copy[f],input_sizes[f])) fail("changed input bytes");
        free(input_copy[f]);
    }
    if(coordinate_copy && memcmp(coordinate_data,coordinate_copy,coordinate_bytes))
        fail("changed coordinate bytes");
    if(matrix_copy && memcmp(matrix_data,matrix_copy,matrix_bytes)) fail("changed matrix bytes");
    free(coordinate_copy);free(matrix_copy);
    if(memcmp(geometry,geometry_before,sizeof geometry_before) ||
       memcmp(cv,cv_before,sizeof cv_before) || memcmp(fieldmap,map_before,sizeof map_before) ||
       memcmp(caller_map,caller_before,sizeof caller_before)) fail("changed metadata bytes");
    if(mode && active && (memcmp(vt,vt_before,sizeof vt_before) || memcmp(vf,vf_before,sizeof vf_before)))
        fail("changed finite-element descriptors");
    if(*np!=dimensions_before[0] || *ks!=dimensions_before[1] ||
       *ke!=dimensions_before[2] || *nl!=dimensions_before[3] || (nh && *nh!=flag))
        fail("changed scalar argument");
    uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));
    if(after!=last_fpcr) fail("changed FPCR");
    bytes+=116;
}

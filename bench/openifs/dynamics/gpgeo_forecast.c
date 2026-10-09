/* Compare complete GPGEO calls on separate output arrays in the forecast.
 * Gravitational potential uses m²/s² and temperature uses kelvin.
 * The driver records state and coefficients; it supplies no numerical stage.
 * Complete FE acceptance requires the verified direct VERDISINT dependency. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <inttypes.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define GEO_ARGS const int32_t *np,const int32_t *ks,const int32_t *ke, \
 const int32_t *nl,double *phi,double *phif,const double *t,const double *r, \
 const double *depth,const double *alpha,const void *geometry
typedef void (*kernel)(GEO_ARGS);
void gpgeo_assembly_(GEO_ARGS);
static kernel reference;
/* Optional diagnostic hooks exclude this private source comparison from
 * genuine forecast integration counts. They supply no numerical work. */
static void (*reference_begin)(void),(*reference_end)(void);
static const int32_t *step;
static FILE *ao,*ro,*io;
static uint64_t calls,bytes,last_fpcr,mode_calls[2];
static void fail(const char *message) {
    fprintf(stderr,"GPGEO forecast check failed %s\n",message);_Exit(2);
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
static int64_t integer64(const void *p,size_t off) {
    int64_t n;memcpy(&n,(const char *)p+off,8);return n;
}
static double *data_pointer(const void *p) {
    double *data;memcpy(&data,p,sizeof data);return data;
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
    fprintf(stderr,"GPGEO FORECAST PASS calls=%" PRIu64 " bytes=%" PRIu64
        " differing_bytes=0 conventional=%" PRIu64 " finite_element=%" PRIu64
        " FPCR=%016" PRIx64 "\n",calls,bytes,mode_calls[0],mode_calls[1],last_fpcr);
}
void gpgeo_(GEO_ARGS) {
    __asm__ volatile("mrs %0,fpcr":"=r"(last_fpcr));
    if(last_fpcr&UINT64_C(0x03c80000)) fail("floating-point control");
    if(!np || !ks || !ke || !nl || !geometry) fail("argument addresses");
    if(*np<=0 || *nl<0 || *ks<1 || *ks>*np || *ke<*ks-1 || *ke>*np)
        fail("shape or interval");
    int32_t mode,ibc;
    memcpy(&mode,(const char *)geometry+3068,4);mode=mode!=0;
    memcpy(&ibc,(const char *)geometry+3052,4);
    int active=*nl>0 && *ke>=*ks;
    if(mode && active && (ibc<0 || ibc>3)) fail("finite-element boundary option");
    size_t count=(size_t)*np*(size_t)*nl;
    size_t half=(size_t)*np*((size_t)*nl+1);
    if(count>(size_t)INT64_MAX/8 || half>(size_t)INT64_MAX/8) fail("buffer extent");
    size_t sizes[2]={half*8,count*8},size=count*8;
    double *out[2]={phi,phif},*shadow[2];
    const double *inputs[4]={t,r,depth,alpha};
    unsigned char geometry_before[3232];
    memcpy(geometry_before,geometry,sizeof geometry_before);
    void *copies[4]={0},*coordinate_copy=NULL,*matrix_copy=NULL;
    double *coordinate_data=NULL,*coordinate_level1=NULL,*matrix_data=NULL;
    size_t coordinate_bytes=0,matrix_bytes=0;
    int64_t bounds[6]={0};
    if(!phi || ((uintptr_t)phi&7) || (size && (!phif || ((uintptr_t)phif&7))) ||
       overlap(phi,sizes[0],phif,sizes[1])) fail("output storage");
    for(int f=0;f<2;++f) {
        if(overlap(out[f],sizes[f],geometry,3232)) fail("output overlaps geometry");
        shadow[f]=copy_bytes(out[f],sizes[f]);
    }
    for(int f=0;f<4;++f) if(active && (f<3 || !mode)) {
        if(!inputs[f] || ((uintptr_t)inputs[f]&7)) fail("active input storage");
        for(int d=0;d<2;++d)
            if(overlap(out[d],sizes[d],inputs[f],size)) fail("output overlaps input");
        copies[f]=copy_bytes(inputs[f],size);
    }
    if(mode && active) {
        const void *descriptor=(const char *)geometry+776;
        coordinate_data=data_pointer(descriptor);
        bounds[0]=integer64(descriptor,48);bounds[1]=integer64(descriptor,56);
        size_t extent=allocation_extent(bounds[0],bounds[1]);
        if(!coordinate_data || ((uintptr_t)coordinate_data&7) ||
           integer64(descriptor,16)!=8 || integer64(descriptor,32)!=8 ||
           integer64(descriptor,40)!=1 || bounds[0]>1 || bounds[1]<*nl)
            fail("coordinate descriptor");
        uint64_t shift=UINT64_C(1)-(uint64_t)bounds[0];
        if(shift>(uint64_t)INT64_MAX/8) fail("coordinate address offset");
        coordinate_level1=coordinate_data+(size_t)shift;
        coordinate_bytes=extent*8;
        coordinate_copy=copy_bytes(coordinate_data,coordinate_bytes);
        size_t matrix_offset=840+(ibc==0?64:ibc==2?1296:240);
        descriptor=(const char *)geometry+matrix_offset;
        matrix_data=data_pointer(descriptor);
        bounds[2]=integer64(descriptor,48);bounds[3]=integer64(descriptor,56);
        bounds[4]=integer64(descriptor,72);bounds[5]=integer64(descriptor,80);
        size_t rows=allocation_extent(bounds[2],bounds[3]);
        size_t columns=allocation_extent(bounds[4],bounds[5]);
        size_t expected_columns=(size_t)*nl+((ibc==1 || ibc==3)?2:0);
        if(!matrix_data || ((uintptr_t)matrix_data&7) ||
           integer64(descriptor,16)!=8 || integer64(descriptor,32)!=8 ||
           integer64(descriptor,40)!=1 || integer64(descriptor,64)!=(int64_t)rows ||
           rows!=(size_t)*nl+1 || columns!=expected_columns ||
           (rows && columns>(size_t)INT64_MAX/8/rows))
            fail("integration matrix descriptor");
        matrix_bytes=rows*columns*8;
        matrix_copy=copy_bytes(matrix_data,matrix_bytes);
        for(int d=0;d<2;++d)
            if(overlap(out[d],sizes[d],coordinate_data,coordinate_bytes) ||
               overlap(out[d],sizes[d],matrix_data,matrix_bytes))
                fail("output overlaps coefficients");
        for(int32_t j=0;j<*nl;++j)
            if(!isfinite(coordinate_level1[j])) fail("nonfinite coordinate width");
        for(size_t k=0;k<matrix_bytes/8;++k)
            if(!isfinite(matrix_data[k])) fail("nonfinite integration matrix");
    }
    for(int32_t j=0;j<*nl;++j) for(int32_t i=*ks-1;i<*ke;++i) {
        size_t k=(size_t)j*(size_t)*np+(size_t)i;
        for(int f=0;f<(mode?3:4);++f)
            if(!isfinite(inputs[f][k])) fail("nonfinite active input");
    }
    for(int32_t i=*ks-1;i<*ke;++i)
        if(!isfinite(phi[(size_t)*nl*(size_t)*np+(size_t)i]))
            fail("nonfinite surface potential");
    if(!reference) {
        void *symbol=dlsym(RTLD_NEXT,"gpgeo_");
        if(!symbol) fail("strict Fortran routine");
        memcpy(&reference,&symbol,sizeof reference);
        step=dlsym(RTLD_NEXT,"__yomct3_MOD_nstep");
        void *begin=dlsym(RTLD_DEFAULT,"vertical_forecast_reference_begin");
        void *end=dlsym(RTLD_DEFAULT,"vertical_forecast_reference_end");
        if(begin && end) {
            memcpy(&reference_begin,&begin,sizeof reference_begin);
            memcpy(&reference_end,&end,sizeof reference_end);
        }
        if(!step) fail("forecast step");
        ao=fopen("gpgeo-assembly.bin","wb");ro=fopen("gpgeo-fortran.bin","wb");
        io=fopen("gpgeo-inputs.bin","wb");
        if(!ao || !ro || !io) fail("capture open");
    }
    ++calls;++mode_calls[mode];
    int32_t dims[6]={*np,*ks,*ke,*nl,mode,ibc};
    for(int f=0;f<3;++f) {
        FILE *file=f==0?ao:f==1?ro:io;
        write_bytes(file,&calls,8);write_bytes(file,step,4);
        write_bytes(file,dims,24);write_bytes(file,bounds,48);
    }
    write_bytes(io,phi,sizes[0]);write_bytes(io,phif,sizes[1]);
    if(active) {
        for(int f=0;f<(mode?3:4);++f) write_bytes(io,inputs[f],size);
        if(mode) {
            write_bytes(io,coordinate_level1,(size_t)*nl*8);
            write_bytes(io,matrix_data,matrix_bytes);
        }
    }
    if(reference_begin) reference_begin();
    reference(np,ks,ke,nl,shadow[0],shadow[1],t,r,depth,alpha,geometry);
    if(reference_end) reference_end();
    gpgeo_assembly_(np,ks,ke,nl,phi,phif,t,r,depth,alpha,geometry);
    for(int f=0;f<2;++f) {
        size_t entries=sizes[f]/8;
        for(size_t k=0;k<entries;++k) {
            if(bits(out[f][k])!=bits(shadow[f][k])) {
                fprintf(stderr,"Mismatch stage=GPGEO step=%d call=%" PRIu64
                    " mode=%d field=%s level=%zu column=%zu asm=%016" PRIx64
                    " ref=%016" PRIx64 "\n",*step,calls,mode,f?"PHIF":"PHI",
                    k/(size_t)*np+(f?1:0),k%(size_t)*np+1,bits(out[f][k]),bits(shadow[f][k]));
                _Exit(1);
            }
            int32_t column=(int32_t)(k%(size_t)*np)+1;
            if(active && column>=*ks && column<=*ke &&
               (f || k/(size_t)*np<(size_t)*nl) && !isfinite(out[f][k]))
                fail("nonfinite active output");
        }
        write_bytes(ao,out[f],sizes[f]);write_bytes(ro,shadow[f],sizes[f]);
        free(shadow[f]);
    }
    for(int f=0;f<4;++f) {
        if(copies[f] && size && memcmp(inputs[f],copies[f],size)) fail("changed input bytes");
        free(copies[f]);
    }
    if(coordinate_copy && memcmp(coordinate_data,coordinate_copy,coordinate_bytes))
        fail("changed coordinate bytes");
    if(matrix_copy && memcmp(matrix_data,matrix_copy,matrix_bytes))
        fail("changed matrix bytes");
    free(coordinate_copy);free(matrix_copy);
    if(memcmp(geometry,geometry_before,sizeof geometry_before)) fail("changed geometry bytes");
    uint64_t after;__asm__ volatile("mrs %0,fpcr":"=r"(after));
    if(after!=last_fpcr) fail("changed FPCR");
    bytes+=84+sizes[0]+sizes[1];
}

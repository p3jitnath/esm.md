/* Compare complete SITNU allocations from reviewed LASSIE/SPCSI/SUBMAT calls.
 * The one LASSIE relay belongs to SIGAM. Its scope gives full parent arrays,
 * so shifted fields and writable views retain their original byte aliases.
 * All operators are evaluated by the unchanged source and native solvers. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <float.h>
#include <inttypes.h>
#include <limits.h>
#include <math.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SIT_ARGS const void *geometry,const void *dyn,const int32_t *a, \
 const int32_t *b,const double *input,double *temperature,double *surface,const int32_t *columns
typedef void (*kernel)(SIT_ARGS);
void sitnu_assembly_(SIT_ARGS);
typedef int (*scope_query)(const void *,int32_t *,int32_t *,const double **,size_t *,const double **,size_t *);
typedef struct {uintptr_t first,last;unsigned char *before,*shadow,*active;} allocation;
typedef struct {const void *address;size_t bytes;unsigned char *before;} snapshot;
static kernel reference;
static scope_query lassie_scope;
static void (*reference_begin)(void),(*reference_end)(void);
static const double *kappa;
static const int32_t *step;
static FILE *ao,*ro,*io;
static pthread_mutex_t lock=PTHREAD_MUTEX_INITIALIZER;
static uint64_t calls,allocation_bytes,returned_view_bytes,science_values,mode_calls[2],
    caller_calls[3],mass_balance_values,native_dependencies,shadow_dependencies,last_fpcr;
static void fail(const char *s) {fprintf(stderr,"SITNU forecast check failed %s\n",s);_Exit(2);}
static uint64_t fpcr(void) {uint64_t u;__asm__ volatile("mrs %0,fpcr":"=r"(u));return u;}
static uint64_t bits(double x) {uint64_t u;memcpy(&u,&x,8);return u;}
static int32_t integer(const void *p,size_t off) {int32_t u;memcpy(&u,(const char *)p+off,4);return u;}
static int64_t wide(const void *p,size_t off) {int64_t u;memcpy(&u,(const char *)p+off,8);return u;}
static double real(const void *p,size_t off) {double u;memcpy(&u,(const char *)p+off,8);return u;}
static void *pointer(const void *p,size_t off) {void *u;memcpy(&u,(const char *)p+off,8);return u;}
static void *symbol(const char *s) {void *p=dlsym(RTLD_NEXT,s);if(!p) fail(s);return p;}
static unsigned char *copy(const void *p,size_t n) {
    unsigned char *q=malloc(n?n:8);if(!q) fail("capture allocation");
    if(n) memcpy(q,p,n);
    return q;
}
static void write_bytes(FILE *f,const void *p,size_t n) {
    if(n && fwrite(p,1,n,f)!=n) fail("capture write");
}
static size_t product(size_t a,size_t b) {
    if(b && a>(size_t)INT64_MAX/8/b) fail("allocation extent");
    return a*b;
}
static int contains(uintptr_t first,uintptr_t last,const void *p,size_t n) {
    uintptr_t s=(uintptr_t)p;
    if(s>UINTPTR_MAX-n) fail("view address overflow");
    return s>=first && s+n<=last;
}
/* These five reviewed views are merged only to preserve shared storage. */
static int add_allocation(allocation x[5],int count,const void *p,size_t n) {
    if(!n) return count;
    uintptr_t first=(uintptr_t)p,last;
    if((first&7) || first>UINTPTR_MAX-n || !p) fail("physical allocation address");
    last=first+n;
    int selected=-1;
    for(int j=0;j<count;++j) {
        if(first<x[j].last && x[j].first<last) {
            if(x[j].first<first) first=x[j].first;
            if(x[j].last>last) last=x[j].last;
            if(selected<0) selected=j;
        }
    }
    if(selected<0) {
        if(count==5) fail("caller allocation count");
        x[count]=(allocation){first,last,NULL,NULL,NULL};return count+1;
    }
    x[selected].first=first;x[selected].last=last;
    for(int j=selected+1;j<count;) {
        if(first<x[j].last && x[j].first<last) {
            if(x[j].first<first) first=x[j].first;
            if(x[j].last>last) last=x[j].last;
            x[selected].first=first;x[selected].last=last;
            memmove(x+j,x+j+1,(size_t)(count-j-1)*sizeof *x);--count;
        } else ++j;
    }
    return count;
}
static int group(allocation x[5],int count,const void *p,size_t n) {
    if(!n) return -1;
    for(int j=0;j<count;++j) if(contains(x[j].first,x[j].last,p,n)) return j;
    fail("view outside reviewed allocation");return -1;
}
static double *shadow_view(allocation x[5],int count,const void *p,size_t n) {
    int g=group(x,count,p,n);return g<0?NULL:(double *)(x[g].shadow+((uintptr_t)p-x[g].first));
}
static void mark(allocation x[5],int count,double *p) {
    int g=group(x,count,p,8);size_t k=((uintptr_t)p-x[g].first)/8;
    if(x[g].active[k]) fail("overlapping selected output cells");
    x[g].active[k]=1;
}
static snapshot capture(const void *p,size_t n) {return (snapshot){p,n,copy(p,n)};}
static void unchanged(snapshot *x,size_t n,uint64_t control,uint64_t constant) {
    if(fpcr()!=control || bits(*kappa)!=constant) fail("FPCR or RKAPPA changed");
    for(size_t j=0;j<n;++j)
        if(x[j].bytes && memcmp(x[j].address,x[j].before,x[j].bytes))
            fail("source object, coefficient or input bytes changed");
}
static int64_t gcd(int64_t a,int64_t b) {while(b) {int64_t r=a%b;a=b;b=r;}return a;}
static void coefficient(snapshot *s,const void *object,size_t off,int32_t n) {
    const unsigned char *d=(const unsigned char *)object+off;
    int64_t lower=wide(d,48),upper=wide(d,56);
    if(wide(d,16)!=8 || wide(d,32)!=8 || wide(d,40)!=1 || lower>1 || upper<n)
        fail("coefficient descriptor");
    int64_t count=upper-lower+1;
    if(count<0 || (uint64_t)count>(uint64_t)INT64_MAX/8) fail("coefficient extent");
    *s=capture(pointer(d,0),(size_t)count*8);
}
static double at_level(const void *object,size_t off,int32_t j) {
    const unsigned char *d=(const unsigned char *)object+off;
    return ((const double *)pointer(d,0))[(int64_t)j-wide(d,48)];
}
__attribute__((destructor)) static void finish(void) {
    if(!ao) return;
    if(fclose(ao)||fclose(ro)||fclose(io)) fail("capture close");
    fprintf(stderr,"SITNU FORECAST PASS calls=%" PRIu64 " conventional=%" PRIu64
        " finite_element=%" PRIu64 " allocation_bytes=%" PRIu64
        " returned_view_bytes=%" PRIu64 " differing_bytes=0 science_values=%" PRIu64
        " LASSIE=%" PRIu64 " SPCSI=%" PRIu64 " SUBMAT=%" PRIu64
        " native_vertical_dependencies=%" PRIu64 " source_shadow_vertical=%" PRIu64
        " mass_balance_values=%" PRIu64 " paired_accounting_hooks=%d FPCR=%016" PRIx64 "\n",
        calls,mode_calls[0],mode_calls[1],allocation_bytes,returned_view_bytes,science_values,
        caller_calls[0],caller_calls[1],caller_calls[2],native_dependencies,shadow_dependencies,
        mass_balance_values,reference_begin!=NULL,last_fpcr);
}
void sitnu_(SIT_ARGS) {
    if(pthread_mutex_lock(&lock)) fail("comparison lock");
    last_fpcr=fpcr();if(last_fpcr!=0) fail("requires FPCR zero");
    if(!geometry || !dyn || !a || !b || !columns) fail("argument addresses");
    if(!reference) {
        void *p=symbol("sitnu_");memcpy(&reference,&p,sizeof reference);
        kappa=dlsym(RTLD_DEFAULT,"__yomcst_MOD_rkappa");
        step=dlsym(RTLD_DEFAULT,"__yomct3_MOD_nstep");
        if(!kappa || !step) fail("module input binding");
        p=dlsym(RTLD_DEFAULT,"lassie_forecast_scope");if(p) memcpy(&lassie_scope,&p,sizeof lassie_scope);
        void *begin=dlsym(RTLD_DEFAULT,"vertical_forecast_reference_begin"),
             *end=dlsym(RTLD_DEFAULT,"vertical_forecast_reference_end");
        if(begin && end) {
            memcpy(&reference_begin,&begin,sizeof reference_begin);memcpy(&reference_end,&end,sizeof reference_end);
        }
        ao=fopen("sitnu-assembly.bin","wb");ro=fopen("sitnu-fortran.bin","wb");
        io=fopen("sitnu-inputs.bin","wb");if(!ao || !ro || !io) fail("capture paths");
    }
    int32_t n=integer(geometry,5224),np=integer(geometry,5144),c=*columns,ks=1,ke=c;
    const void *veta=pointer(geometry,3248),*vfe=pointer(geometry,3256),*cver=pointer(geometry,3264);
    if(!veta || !vfe || !cver) fail("vertical object aliases");
    int mode=integer(cver,52)!=0,ibc=integer(cver,36),kind=0,shift=0;
    if(n<0 || c<0 || *a<1 || *b<1 || np<1 || (mode && c && n<1)) fail("shape");
    int64_t extent=1+((int64_t)n-1)* *a+((int64_t)c-1)* *b;
    if(extent<INT32_MIN || extent>INT32_MAX) fail("source index range");
    if(n && c) {
        int64_t g=gcd(*a,*b);
        if((int64_t)n-1>=*b/g && (int64_t)c-1>=*a/g) fail("noninjective strides");
    }
    Dl_info info={0};dladdr(__builtin_return_address(0),&info);
    const char *caller=info.dli_sname?info.dli_sname:"unknown";
    const double *gmv=NULL,*gmvs=NULL;size_t gmv_count=0,gmvs_count=0;
    size_t field_count,ps_count;
    if(lassie_scope && lassie_scope(geometry,&ks,&ke,&gmv,&gmv_count,&gmvs,&gmvs_count)) {
        kind=1;shift=ks-1;
        if(ks<1 || ks>np || ke<ks-1 || ke>np || c!=ke-ks+1 || *a!=np || *b!=1)
            fail("LASSIE scope and strides");
        field_count=product((size_t)np,(size_t)n);ps_count=(size_t)np;
        caller="lassie_";
    } else if(!strcmp(caller,"spcsi_")) {
        kind=2;
        if(*a!=1 || *b!=n) fail("SPCSI compact layout");
        field_count=product((size_t)n,(size_t)c);ps_count=(size_t)c;
    } else if(!strcmp(caller,"submat_")) {
        kind=3;
        if(*a!=1 || *b!=n || c!=n) fail("SUBMAT basis layout");
        field_count=product((size_t)n,(size_t)n);ps_count=(size_t)n;
    } else fail("unreviewed caller or missing shared LASSIE scope");
    if(gmv_count>(size_t)INT64_MAX/8 || gmvs_count>(size_t)INT64_MAX/8) fail("parent allocation extent");
    size_t field_bytes=field_count*8,ps_bytes=ps_count*8,gmv_bytes=gmv_count*8,gmvs_bytes=gmvs_count*8;
    const double *field=field_bytes?input-shift:input;
    double *tbase=field_bytes?temperature-shift:temperature,*pbase=ps_bytes?surface-shift:surface;
    if(kind==1 && field_bytes && !contains((uintptr_t)gmv,(uintptr_t)gmv+gmv_bytes,field,field_bytes))
        fail("divergence field outside full PGMV");
    allocation memory[5]={{0}};int ng=0;
    const void *views[5]={gmv,gmvs,field,tbase,pbase};
    const size_t view_bytes[5]={gmv_bytes,gmvs_bytes,field_bytes,field_bytes,ps_bytes};
    for(int v=0;v<5;++v) ng=add_allocation(memory,ng,views[v],view_bytes[v]);
    for(int g=0;g<ng;++g) {
        size_t bytes=memory[g].last-memory[g].first;
        memory[g].before=copy((const void *)memory[g].first,bytes);
        memory[g].shadow=copy((const void *)memory[g].first,bytes);
        memory[g].active=calloc(bytes/8,1);if(!memory[g].active) fail("selected-cell allocation");
    }
    for(int32_t col=0;col<c;++col) {
        mark(memory,ng,surface+col);
        for(int32_t j=0;j<n;++j) mark(memory,ng,temperature+(size_t)j*(size_t)*a+(size_t)col*(size_t)*b);
    }
    snapshot imm[13];size_t ni=0;
    imm[ni++]=capture(geometry,17096);imm[ni++]=capture(dyn,4720);
    imm[ni++]=capture(veta,320);imm[ni++]=capture(vfe,2176);imm[ni++]=capture(cver,216);
    imm[ni++]=capture(field,field_bytes);
    imm[ni++]=capture(a,4);imm[ni++]=capture(b,4);imm[ni++]=capture(columns,4);
    const void *coef_obj[6]={dyn,dyn,dyn,dyn,dyn,veta};
    const size_t coef_off[6]={2728,2792,2664,2600,2920,256};
    snapshot coefficients[6]={{0}};int used=0;
    if(n>0 && c>0) {
        used=mode?49:15;
        for(int f=0;f<6;++f) if(used&(1<<f)) {
            coefficient(&coefficients[f],coef_obj[f],coef_off[f],n);
            imm[ni++]=coefficients[f];
        }
    }
    snapshot matrix={0};unsigned char matrix_descriptor[88]={0};size_t matrix_offset=0;
    if(mode && c>0) {
        if(ibc<0 || ibc>3) fail("default integral boundary selector");
        matrix_offset=ibc==0?64:ibc==2?1296:240;
        const unsigned char *d=(const unsigned char *)vfe+matrix_offset;
        int64_t rows=wide(d,56)-wide(d,48)+1,cols=wide(d,80)-wide(d,72)+1;
        if(rows!=(int64_t)n+1 || cols!=(int64_t)n+((ibc==1 || ibc==3)?2:0) ||
           wide(d,16)!=8 || wide(d,32)!=8 || wide(d,40)!=1 || wide(d,64)!=rows)
            fail("accepted vertical matrix layout");
        matrix=capture(pointer(d,0),product((size_t)rows,(size_t)cols)*8);imm[ni++]=matrix;
        memcpy(matrix_descriptor,d,88);memset(matrix_descriptor,0,8);
    }
    if(ni>13) fail("snapshot count");
    uint64_t constant=bits(*kappa);
    double tref=real(dyn,2520),inverse_pressure=real(dyn,2568);
    if(!isfinite(*kappa) || *kappa<=0.0 || !isfinite(tref) || tref<=0.0 ||
       !isfinite(inverse_pressure) || inverse_pressure<=0.0) fail("reference atmosphere");
    for(int32_t j=1;j<=n && c>0;++j) {
        double w=at_level(dyn,2728,j);
        if(!isfinite(w) || w<=0.0) fail("positive pressure weight");
        if(mode) {
            double p=at_level(dyn,2920,j),h=at_level(veta,256,j);
            if(!isfinite(p) || p<=0.0 || !isfinite(h) || h<=0.0) fail("full pressure or eta width");
        } else {
            double u=at_level(dyn,2792,j),l=at_level(dyn,2664,j),alpha=at_level(dyn,2600,j);
            if(!isfinite(u) || u<=0.0 || !isfinite(l) || l<0.0 || !isfinite(alpha))
                fail("conventional reference coefficients");
        }
        for(int32_t col=0;col<c;++col)
            if(!isfinite(input[(size_t)(j-1)*(size_t)*a+(size_t)col*(size_t)*b])) fail("divergence input");
    }
    ++calls;++mode_calls[mode];++caller_calls[kind-1];
    if(mode && c>0) {++native_dependencies;++shadow_dependencies;}
    unsigned char header[512]={0};memcpy(header,"STNF0001",8);
    memcpy(header+8,&calls,8);memcpy(header+16,&last_fpcr,8);memcpy(header+24,step,4);
    memcpy(header+28,&ng,4);
    const int32_t dims[16]={mode,ibc,n,c,*a,*b,shift,np,kind,ks,ke,used,0,0,0,0};
    memcpy(header+32,dims,64);snprintf((char *)header+96,64,"%s",caller);
    for(int v=0;v<5;++v) {
        int g=group(memory,ng,views[v],view_bytes[v]);
        const uint64_t map[3]={g<0?UINT64_MAX:(uint64_t)g,
            g<0?0:(uint64_t)((uintptr_t)views[v]-memory[g].first),(uint64_t)view_bytes[v]};
        memcpy(header+160+24*v,map,24);
    }
    for(int g=0;g<ng;++g) {
        uint64_t bytes=memory[g].last-memory[g].first;memcpy(header+280+8*g,&bytes,8);
    }
    memcpy(header+320,kappa,8);memcpy(header+328,&tref,8);memcpy(header+336,&inverse_pressure,8);
    memcpy(header+344,matrix_descriptor,88);
    uint64_t coefficient_bytes=0,matrix_bytes=matrix.bytes,config_bytes=216+(uint64_t)__builtin_popcount((unsigned)used)*64;
    for(int f=0;f<6;++f) coefficient_bytes+=coefficients[f].bytes;
    memcpy(header+432,&coefficient_bytes,8);memcpy(header+440,&matrix_bytes,8);memcpy(header+448,&config_bytes,8);
    write_bytes(ao,header,512);write_bytes(ro,header,512);write_bytes(io,header,512);
    for(int g=0;g<ng;++g) write_bytes(io,memory[g].before,memory[g].last-memory[g].first);
    write_bytes(io,cver,216);
    for(int f=0;f<6;++f) if(used&(1<<f)) {
        unsigned char d[64];memcpy(d,(const char *)coef_obj[f]+coef_off[f],64);memset(d,0,8);
        write_bytes(io,d,64);write_bytes(io,coefficients[f].before,coefficients[f].bytes);
    }
    write_bytes(io,matrix.before,matrix.bytes);
    double *shadow_input=shadow_view(memory,ng,input,field_bytes?(size_t)(field_count-shift)*8:0);
    double *shadow_t=shadow_view(memory,ng,temperature,field_bytes?(size_t)(field_count-shift)*8:0);
    double *shadow_p=shadow_view(memory,ng,surface,ps_bytes?(size_t)(ps_count-shift)*8:0);
    if(reference_begin) reference_begin();
    reference(geometry,dyn,a,b,shadow_input,shadow_t,shadow_p,columns);
    if(reference_end) reference_end();
    unchanged(imm,ni,last_fpcr,constant);
    for(int g=0;g<ng;++g)
        if(memcmp((const void *)memory[g].first,memory[g].before,memory[g].last-memory[g].first))
            fail("source shadow altered original caller allocation");
    sitnu_assembly_(geometry,dyn,a,b,input,temperature,surface,columns);
    unchanged(imm,ni,last_fpcr,constant);
    for(int g=0;g<ng;++g) {
        size_t bytes=memory[g].last-memory[g].first;
        const double *native=(const double *)memory[g].first,*ref=(const double *)memory[g].shadow;
        const double *before=(const double *)memory[g].before;
        for(size_t k=0;k<bytes/8;++k) {
            if(bits(native[k])!=bits(ref[k])) {
                fprintf(stderr,"Mismatch stage=SITNU step=%d call=%" PRIu64 " caller=%s allocation=%d cell=%zu assembly=%016" PRIx64 " source=%016" PRIx64 "\n",
                    *step,calls,caller,g,k+1,bits(native[k]),bits(ref[k]));_Exit(1);
            }
            if(!memory[g].active[k] && bits(native[k])!=bits(before[k])) fail("inactive caller cell changed");
            if(memory[g].active[k]) {
                if(!isfinite(native[k])) fail("nonfinite active operator result");
                ++science_values;
            }
        }
        write_bytes(ao,(const void *)memory[g].first,bytes);write_bytes(ro,memory[g].shadow,bytes);
        allocation_bytes+=bytes;
    }
    /* An independently accumulated ground integral checks column mass. */
    for(int32_t col=0;col<c;++col) {
        long double sum=0.0L,absolute=0.0L;
        for(int32_t j=1;j<=n;++j) {
            long double term=(long double)input[(size_t)(j-1)*(size_t)*a+(size_t)col*(size_t)*b]*
                at_level(dyn,2728,j);
            if(mode) {
                size_t matrix_col=(size_t)(j-1)+((ibc==1 || ibc==3)?1:0);
                double weight=((const double *)matrix.before)[matrix_col*((size_t)n+1)+(size_t)n];
                term*=at_level(veta,256,j);term*=weight;
            }
            sum+=term;absolute+=fabsl(term);
        }
        long double expected=sum*inverse_pressure;
        long double tolerance=(32.0L+4.0L*n)*DBL_EPSILON*absolute*inverse_pressure+
            (32.0L+8.0L*n)*DBL_TRUE_MIN;
        if(!isfinite(surface[col]) || fabsl((long double)surface[col]-expected)>tolerance)
            fail("ground pressure-weighted mass integral");
        ++mass_balance_values;
    }
    returned_view_bytes+=(uint64_t)field_bytes+ps_bytes;
    for(size_t j=0;j<ni;++j) free(imm[j].before);
    for(int g=0;g<ng;++g) {free(memory[g].before);free(memory[g].shadow);free(memory[g].active);}
    if(pthread_mutex_unlock(&lock)) fail("comparison unlock");
}

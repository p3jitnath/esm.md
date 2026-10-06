/*
 * One critical numerical verifier for the full CPSPE interface.
 * Checks separate rounding, all field shapes, partial columns, empty
 * dimensions, read-only tendencies, guards and constant-rate trajectories.
 * Both kernels receive the same finite FP64 bytes. No stage is supplied here.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include <float.h>
#include <sys/mman.h>
#include <unistd.h>
typedef void (*kernel)(const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *);
extern void cpspe_(const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *);
extern void cpspe_reference_(const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const int32_t *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, const double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *, double *);
extern int __yomhook_MOD_lhook;

static void call(kernel f, const int32_t *dims, double dt,
                 double **t, double **state) {
    f(&dims[0], &dims[1], &dims[2], &dims[3], &dims[4], &dims[5], &dims[6], &dims[7], &dims[8], &dt, t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12], t[13], t[14], t[15], t[16], t[17], t[18], t[19], t[20], t[21], t[22], state[0], state[1], state[2], state[3], state[4], state[5], state[6], state[7], state[8], state[9], state[10], state[11], state[12], state[13], state[14], state[15], state[16], state[17], state[18], state[19], state[20], state[21], state[22]);
}
static uint64_t bits(double x) {
    uint64_t value;
    memcpy(&value, &x, sizeof value);
    return value;
}
static int check(int case_id, int step, int field, const char *stage,
                 const double *got, const double *expected, size_t n) {
    if (memcmp(got, expected, n * sizeof(double)) == 0) return 0;
    for (size_t i=0; i<n; ++i)
        if (bits(got[i]) != bits(expected[i])) {
            fprintf(stderr,
              "Mismatch case=%d stage=%s step=%d field=%d cell=%zu asm=%016"
              PRIx64 " ref=%016" PRIx64 "\n",
              case_id,stage,step,field,i,bits(got[i]),bits(expected[i]));
            return 1;
        }
    return 1;
}

/* A protected page catches a tail read or write even when its value would
 * remain unchanged. Zero-sized fields use no storage in this fixture. */
static int protected_tail(kernel solver, FILE *out) {
    const int32_t dims[9]={1,1,1,1,0,0,0,0,0};
    long page_size=sysconf(_SC_PAGESIZE);
    if(page_size<=0) return 2;
    size_t page=(size_t)page_size;
    double *t[23]={0},*s[23]={0};
    void *tm[23]={0},*sm[23]={0};
    for(int f=0;f<23;++f) {
        if(!(f<=4 || (f>=10 && f<=16))) continue;
        tm[f]=mmap(NULL,2*page,PROT_READ|PROT_WRITE,
                   MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
        sm[f]=mmap(NULL,2*page,PROT_READ|PROT_WRITE,
                   MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
        if(tm[f]==MAP_FAILED || sm[f]==MAP_FAILED) {
            perror("mmap"); return 2;
        }
        if(mprotect((char *)tm[f]+page,page,PROT_NONE) ||
           mprotect((char *)sm[f]+page,page,PROT_NONE)) {
            perror("mprotect"); return 2;
        }
        t[f]=(double *)((char *)tm[f]+page)-1;
        s[f]=(double *)((char *)sm[f]+page)-1;
        t[f][-1]=s[f][-1]=1.0;
        t[f][0]=0.0625;
        s[f][0]=64.0+f;
    }
    call(solver,dims,2.0,t,s);
    for(int f=0;f<23;++f) {
        if(!tm[f]) continue;
        double expected=64.125+f,rate=0.0625,guard=1.0;
        if(check(14,1,f,"protected-tail",s[f],&expected,1) ||
           check(14,1,f,"protected-read-only",t[f],&rate,1) ||
           check(14,1,f,"protected-left-guard",s[f]-1,&guard,1) ||
           check(14,1,f,"protected-input-guard",t[f]-1,&guard,1)) return 1;
        if(fwrite(s[f],8,1,out)!=1) return 2;
        if(munmap(tm[f],2*page) || munmap(sm[f],2*page)) return 2;
    }
    return 0;
}


int main(int argc, char **argv) {
    if (argc != 3) return 2;
    uint64_t fpcr;
    __asm__ volatile("mrs %0, fpcr" : "=r"(fpcr));
    if (fpcr & ((UINT64_C(3)<<22) | (UINT64_C(1)<<24) |
                (UINT64_C(1)<<19) | (UINT64_C(1)<<25))) {
        fprintf(stderr,"Unsupported FPCR %016" PRIx64 "\n",fpcr);
        return 2;
    }
    __yomhook_MOD_lhook=0;
    FILE *out_a=fopen(argv[1],"wb"), *out_r=fopen(argv[2],"wb");
    if (!out_a || !out_r) return 2;
    /* Soil, snow and ocean counts include realistic and absent fields.
     * Every pair tail and both inactive ends have a dedicated case. */
    const int32_t cases[][9]={
       {1,1,1,4,2,1,5,2,2},{2,1,2,4,2,1,5,2,2},
       {3,1,3,4,2,1,5,2,2},{24,1,24,4,2,1,5,2,2},
       {24,2,23,4,2,1,5,2,2},{25,3,25,4,2,1,5,2,2},
       {24,1,0,4,2,1,5,2,2},{24,12,11,4,2,1,5,2,2},
       {3,1,3,0,0,0,0,0,0},{3,2,2,1,0,0,1,3,0},
       {3,1,3,1,1,1,1,1,1},{5,1,5,1,1,1,1,1,1},
       {5,2,4,1,1,1,1,1,1},{3,1,3,1,1,1,1,1,1}
    };
    const unsigned char kind[]={1,0,1,1,0,2,2,2,2,2,0,0,0,0,0,0,0,3,4,5,5,5,5};
    size_t calls=0, bytes_written=0;
    for (int c=0;c<(int)(sizeof cases/sizeof cases[0]);++c) {
        const int32_t *dims=cases[c];
        double *a[23],*r[23],*t[23],*snap[23],*initial[23];
        size_t n[23], planes[23];
        for (int f=0;f<23;++f) {
            planes[f]=kind[f]==1 ? (size_t)dims[3] : kind[f]==2 ? (size_t)dims[6] :
                kind[f]==3 ? (size_t)dims[4]*dims[7] :
                kind[f]==4 ? (size_t)dims[8] : kind[f]==5 ? (size_t)dims[5] : 1;
            n[f]=planes[f]*dims[0];
            a[f]=malloc((n[f]+2)*8); r[f]=malloc((n[f]+2)*8);
            t[f]=malloc((n[f]+2)*8); snap[f]=malloc((n[f]+2)*8);
            initial[f]=malloc((n[f]+2)*8);
            if(!a[f]||!r[f]||!t[f]||!snap[f]||!initial[f]) return 2;
            uint64_t guard=UINT64_C(0x7ff812340000abcd);
            memcpy(a[f],&guard,8); memcpy(a[f]+n[f]+1,&guard,8);
            memcpy(t[f],&guard,8); memcpy(t[f]+n[f]+1,&guard,8);
            ++a[f]; ++r[f]; ++t[f]; ++snap[f]; ++initial[f];
            for(size_t i=0;i<n[f];++i) {
                a[f][i]=64.0+f+(double)i/8.0;
                t[f][i]=0.0625;
                if(c==10) {
                    a[f][i]=-1.0;
                    t[f][i]=0x1.ffffffffffffep-1;
                }
                if(c==11 || c==12) {
                    const double small[]={0.0,-0.0,0x1p-1074,-0x1p-1074,
                                          0x1p-1022,-0x1p-1022};
                    a[f][i]=small[i%6]; t[f][i]=small[(i+2)%6];
                }
                if(c==13) t[f][i]=0.0;
            }
            memcpy(r[f]-1,a[f]-1,(n[f]+2)*8);
            memcpy(snap[f]-1,t[f]-1,(n[f]+2)*8);
            memcpy(initial[f]-1,a[f]-1,(n[f]+2)*8);
        }
        double dt=c==10 ? 0x1.0000000000001p0 : c==12 ? -0.0 : 2.0;
        for(int step=1;step<=32;++step) {
            call(cpspe_reference_,dims,dt,t,r);
            for(int f=0;f<23;++f) {
                if(check(c,step,f,"reference-left-guard",r[f]-1,initial[f]-1,1) ||
                   check(c,step,f,"reference-right-guard",r[f]+n[f],initial[f]+n[f],1) ||
                   check(c,step,f,"reference-read-only",t[f]-1,snap[f]-1,n[f]+2)) return 1;
            }
            call(cpspe_,dims,dt,t,a);
            for(int f=0;f<23;++f) {
                if(check(c,step,f,"assembly-left-guard",a[f]-1,initial[f]-1,1) ||
                   check(c,step,f,"assembly-right-guard",a[f]+n[f],initial[f]+n[f],1) ||
                   check(c,step,f,"surface",a[f]-1,r[f]-1,n[f]+2) ||
                   check(c,step,f,"read-only",t[f]-1,snap[f]-1,n[f]+2)) return 1;
                for(size_t i=0;i<n[f];++i) {
                    int col=(int)(i%dims[0])+1;
                    int active=col>=dims[1]&&col<=dims[2];
                    if(c<10) {
                        double expected=initial[f][i]+(active ? step*0.125 : 0.0);
                        if(check(c,step,f,"constant-rate",a[f]+i,&expected,1)) return 1;
                    }
                    if(!active && check(c,step,f,"inactive",a[f]+i,initial[f]+i,1)) return 1;
                    if(c==10 && active && step==1 && bits(a[f][i])!=bits(0.0)) {
                        fprintf(stderr,"Separate-rounding witness failed\n"); return 1;
                    }
                    if(c==13 && check(c,step,f,"zero-rate",a[f]+i,initial[f]+i,1)) return 1;
                }
                if(fwrite(a[f],8,n[f],out_a)!=n[f] ||
                   fwrite(r[f],8,n[f],out_r)!=n[f]) return 2;
                bytes_written+=n[f]*8;
            }
            ++calls;
        }
        for(int f=0;f<23;++f) {
            free(a[f]-1);free(r[f]-1);free(t[f]-1);
            free(snap[f]-1);free(initial[f]-1);
        }
    }
    if(protected_tail(cpspe_reference_,out_r) ||
       protected_tail(cpspe_,out_a)) return 1;
    ++calls;
    bytes_written+=12*8;
    if(fclose(out_a)||fclose(out_r)) return 2;
    printf("CPSPE PASS cases=15 calls=%zu bytes=%zu FPCR=%016" PRIx64 "\n",
           calls,bytes_written,fpcr);
    return 0;
}

/* Check a final single column beside an inaccessible memory page.
 * All three buffers end exactly at their allowed boundary.
 * Return the two complete water-boundary values in kg/m². */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#define ARGS const int32_t *,const int32_t *,const int32_t *,const int32_t *,double *,const double *,const double *
void gppwc_(ARGS);
void gppwc_assembly_(ARGS);
static double *end_buffer(size_t bytes,size_t page) {
    void *base=mmap(NULL,2*page,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
    if(base==MAP_FAILED || mprotect((char *)base+page,page,PROT_NONE)) {
        perror("GPPWC protected buffer");exit(2);
    }
    return (double *)((char *)base+page-bytes);
}
void gppwc_guard(double *assembly,double *reference) {
    const int32_t np=1,ks=1,kp=1,nl=1;
    size_t page=(size_t)sysconf(_SC_PAGESIZE);
    double *q=end_buffer(8,page),*p=end_buffer(16,page),*w=end_buffer(16,page);
    double shadow[2]={-777.75,-777.75},q_before=0.5,p_before[2]={0,8192};
    *q=q_before;p[0]=p_before[0];p[1]=p_before[1];
    w[0]=w[1]=-777.75;
    gppwc_(&np,&ks,&kp,&nl,shadow,q,p);
    gppwc_assembly_(&np,&ks,&kp,&nl,w,q,p);
    if(memcmp(w,shadow,16)||memcmp(q,&q_before,8)||memcmp(p,p_before,16)) {
        fputs("GPPWC protected-tail byte mismatch\n",stderr);exit(1);
    }
    memcpy(assembly,w,16);memcpy(reference,shadow,16);
    if(munmap((char *)q-(page-8),2*page) ||
       munmap((char *)p-(page-16),2*page) ||
       munmap((char *)w-(page-16),2*page)) {
        perror("GPPWC protected buffer close");exit(2);
    }
}

/* GNU Fortran CPSPE interface. Integers are signed 32-bit values.
 * Arrays contain FP64 values in Fortran order. The dt value is in seconds.
 * d0 through d8 follow the dimension order in the CPSPE contract.
 * t0 through t22 are read-only tendencies and s0 through s22 are states.
 * Their units and trailing shapes are defined in the contract's field table. */
#ifndef OPENIFS_CPSPE_H
#define OPENIFS_CPSPE_H
#include <stdint.h>
#define CPSPE_PARAMS const int32_t * d0, const int32_t * d1, const int32_t * d2, const int32_t * d3,\
    const int32_t * d4, const int32_t * d5, const int32_t * d6, const int32_t * d7,\
    const int32_t * d8, const double * dt, const double * t0, const double * t1,\
    const double * t2, const double * t3, const double * t4, const double * t5,\
    const double * t6, const double * t7, const double * t8, const double * t9,\
    const double * t10, const double * t11, const double * t12, const double * t13,\
    const double * t14, const double * t15, const double * t16, const double * t17,\
    const double * t18, const double * t19, const double * t20, const double * t21,\
    const double * t22, double * s0, double * s1, double * s2,\
    double * s3, double * s4, double * s5, double * s6,\
    double * s7, double * s8, double * s9, double * s10,\
    double * s11, double * s12, double * s13, double * s14,\
    double * s15, double * s16, double * s17, double * s18,\
    double * s19, double * s20, double * s21, double * s22
typedef void (*cpspe_kernel)(CPSPE_PARAMS);
void cpspe_(CPSPE_PARAMS);
void cpspe_reference_(CPSPE_PARAMS);
void cpspe_assembly_(CPSPE_PARAMS);
#endif

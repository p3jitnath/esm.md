#define _GNU_SOURCE
#include <sched.h>
#include <stdint.h>
uint64_t cpu_fpcr(void) { uint64_t x; __asm__ volatile("mrs %0, fpcr" : "=r"(x)); return x; }
uint64_t cpu_fpsr(void) { uint64_t x; __asm__ volatile("mrs %0, fpsr" : "=r"(x)); return x; }
void cpu_set_fpcr(uint64_t x) { __asm__ volatile("msr fpcr, %0" :: "r"(x)); }
void cpu_set_fpsr(uint64_t x) { __asm__ volatile("msr fpsr, %0" :: "r"(x)); }
int cpu_getcpu(void) { return sched_getcpu(); }
int cpu_value_probe(void) {
    volatile double normal = 0x1p-1022;
    volatile double half = 0.5;
    volatile double subnormal = normal * half;
    union { double d; uint64_t u; } bits;
    bits.d = subnormal;
    int result = bits.u == UINT64_C(0x0008000000000000) ? 0 : 1;
    volatile double one = 1.0;
    volatile double tie = 0x1p-53;
    volatile double rounded = one + tie;
    bits.d = rounded;
    if (bits.u != UINT64_C(0x3ff0000000000000)) result |= 2;
    volatile double minus_zero = -0.0;
    bits.d = minus_zero;
    if (bits.u != UINT64_C(0x8000000000000000)) result |= 4;
    return result;
}

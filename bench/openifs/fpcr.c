/* Return the AArch64 floating-point control register for numerical checks. */
#include <stdint.h>
uint64_t openifs_fpcr(void) {
    uint64_t value;
    __asm__ volatile("mrs %0, fpcr" : "=r"(value));
    return value;
}

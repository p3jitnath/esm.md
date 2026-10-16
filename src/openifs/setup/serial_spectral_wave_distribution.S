/* Contract: skills/md2asm/references/openifs/setup/spectral_field_storage.md. */
/* Serial source wave distribution from SUWAVEDI/INI_SPEC_DIST.
 * x0 int32 ASM0[N+1],x1 ALLMS[N+1],x2 PTRMS[1],x3 NUMPP[1],w4=N.
 * Arrays are mapped,4-byte aligned,disjoint;0<=N<=63;w0=0 or2 before stores.
 * Source KPRTRW=KMYSETW=1. No floating point, stack or external call.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_serial_spectral_wave_distribution
.type md2asm_serial_spectral_wave_distribution,%function
md2asm_serial_spectral_wave_distribution:
 cbz x0,.Lserial_wave_reject
 cbz x1,.Lserial_wave_reject
 cbz x2,.Lserial_wave_reject
 cbz x3,.Lserial_wave_reject
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x3
 tst x9,#3
 b.ne .Lserial_wave_reject
 cmp w4,#63
 b.hi .Lserial_wave_reject
 mov w5,#0
 mov w6,#1
.Lserial_wave_loop:
 str w6,[x0,w5,uxtw#2]
 str w5,[x1,w5,uxtw#2]
 sub w7,w4,w5
 add w7,w7,#1
 add w6,w6,w7,lsl#1
 add w5,w5,#1
 cmp w5,w4
 b.ls .Lserial_wave_loop
 mov w6,#1
 str w6,[x2]
 str w5,[x3]
 mov w0,#0
 ret
.Lserial_wave_reject:
 mov w0,#2
 ret
.size md2asm_serial_spectral_wave_distribution,.-md2asm_serial_spectral_wave_distribution
.section .note.GNU-stack,"",%progbits

/* Complete PDF and cloud-generator sample interpolation bodies.
 * Physics: formulations/openifs/physics/cloud_water_samples.md.
 * Contract: skills/md2asm/references/openifs/physics/pdf_sampler.md.
 * Both entries take sampler, FP64 spread, FP64 fraction and output in
 * x0 through x3. The PDF entry unwraps a 16-byte GNU class, while the
 * cloud entry receives the 112-byte object directly. All buffers are
 * disjoint. The common body preserves each FP64 rounding point and
 * uses only caller-saved registers, with no stack frame or helper. */
#ifndef PDF_SYMBOL
#define PDF_SYMBOL __radiation_pdf_sampler_MOD_sample_from_pdf
#endif
#ifndef PDF_SIMD_SYMBOL
#define PDF_SIMD_SYMBOL __radiation_cloud_generator_MOD_sample_from_pdf_simd
#endif
.text
.p2align 2
.global PDF_SYMBOL
.type PDF_SYMBOL,%function
PDF_SYMBOL:
    ldr x4,[x0]                /* Polymorphic class data address. */
    b .Lpdf_body
.size PDF_SYMBOL,.-PDF_SYMBOL
.global PDF_SIMD_SYMBOL
.type PDF_SIMD_SYMBOL,%function
PDF_SIMD_SYMBOL:
    mov x4,x0                  /* Ordinary sampler object address. */
.Lpdf_body:
    ldp w5,w6,[x4]
    sub w5,w5,#1
    sub w6,w6,#1
    fmov d20,#1.0
    fmov d21,xzr
    ldr d0,[x2]
    scvtf d3,w5
    fmul d0,d0,d3
    fadd d0,d0,d20
    fcvtzs w7,d0               /* Truncate the source coordinate. */
    cmp w7,w5
    csel w7,w7,w5,le
    mov w9,#1
    cmp w7,w9
    csel w7,w7,w9,ge
    scvtf d3,w7
    fsub d0,d0,d3
    fminnm d0,d0,d20
    fmaxnm d0,d0,d21          /* Bounded fraction weight. */

    ldr d1,[x1]
    ldp d3,d4,[x4,#8]
    fsub d1,d1,d3
    fmul d1,d1,d4
    fadd d1,d1,d20
    fcvtzs w8,d1
    cmp w8,w6
    csel w8,w8,w6,le
    cmp w8,w9
    csel w8,w8,w9,ge
    scvtf d3,w8
    fsub d1,d1,d3
    fminnm d1,d1,d20
    fmaxnm d1,d1,d21          /* Bounded spread weight. */

    uxtw x10,w7
    uxtw x11,w8
    ldp x5,x6,[x4,#24]        /* Table base and element offset. */
    ldr x7,[x4,#64]
    ldr x8,[x4,#88]
    madd x6,x10,x7,x6
    madd x6,x11,x8,x6
    add x5,x5,x6,lsl #3
    add x9,x5,x7,lsl #3
    add x10,x5,x8,lsl #3
    ldr d4,[x5]               /* Lower fraction and spread corner. */
    ldr d5,[x10]
    ldr d6,[x9]
    ldr d7,[x9,x8,lsl #3]

    fsub d2,d20,d0
    fsub d3,d20,d1
    fmul d16,d2,d3
    fmul d4,d16,d4
    fmul d16,d2,d1
    fmul d5,d16,d5
    fadd d4,d4,d5
    fmul d16,d0,d3
    fmul d6,d16,d6
    fadd d4,d4,d6
    fmul d16,d0,d1
    fmul d7,d16,d7
    fadd d4,d4,d7             /* Preserve the original four-term order. */
    str d4,[x3]
    ret
.size PDF_SIMD_SYMBOL,.-PDF_SIMD_SYMBOL
.section .note.GNU-stack,"",%progbits

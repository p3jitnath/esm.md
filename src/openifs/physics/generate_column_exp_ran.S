/* Complete radiation_cloud_generator::generate_column_exp_ran body.
 * Physics: formulations/openifs/physics/cloud_columns.md.
 * Contract: skills/md2asm/references/openifs/physics/cloud_columns.md.
 * Fourteen address arguments follow the original Arm ABI. Six are on
 * the incoming stack. The body saves all used callee-saved registers
 * and owns three nlev-sized FP64 arrays plus its descriptor and counts.
 * Only selected cloudy output cells and the complete stream can change. */
#ifndef COLUMN_SYMBOL
#define COLUMN_SYMBOL __radiation_cloud_generator_MOD_generate_column_exp_ran
#endif
#ifndef COLUMN_UNIFORM_SYMBOL
#define COLUMN_UNIFORM_SYMBOL __random_numbers_mix_MOD_uniform_distribution
#endif
#ifndef COLUMN_PDF_SYMBOL
#define COLUMN_PDF_SYMBOL __radiation_cloud_generator_MOD_sample_from_pdf_simd
#endif
.text
.p2align 2
.global COLUMN_SYMBOL
.type COLUMN_SYMBOL,%function
.hidden COLUMN_UNIFORM_SYMBOL
.hidden COLUMN_PDF_SYMBOL
COLUMN_SYMBOL:
    mov x17,sp
    sub sp,sp,#224
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x29,sp
    mov x19,x3
    mov x20,x4
    mov x21,x5
    mov x22,x6
    mov x23,x7
    ldp x24,x25,[x17]
    ldr x26,[x17,#16]
    ldr x27,[x17,#40]
    ldr w28,[x0]
    lsl x28,x28,#3           /* Complete level pitch in bytes. */
    ldr w8,[x2]
    sub w8,w8,#1
    str w8,[x29,#128]        /* Zero-based selected column. */
    ldr x8,[x17,#24]
    ldr w8,[x8]
    str w8,[x29,#136]        /* Selected cloud top. */
    ldr x8,[x17,#32]
    ldr w8,[x8]
    str w8,[x29,#140]        /* Last cloudy model level. */
    ldr w9,[x1]
    str w9,[x29,#120]
    uxtw x9,w9
    lsl x10,x9,#3
    add x11,x10,x10,lsl #1
    add x11,x11,#15
    and x11,x11,#-16
    sub sp,sp,x11
    mov x8,sp
    str x8,[x29,#96]
    add x9,x8,x10
    str x9,[x29,#104]
    add x9,x9,x10
    str x9,[x29,#112]

    add x0,x29,#160          /* Complete GNU rank-one descriptor. */
    str x8,[x0]
    mov x9,#-1
    str x9,[x0,#8]
    mov x9,#8
    str x9,[x0,#16]
    str x9,[x0,#32]
    movz x9,#0x0301,lsl #32
    str x9,[x0,#24]
    mov x9,#1
    str x9,[x0,#40]
    str x9,[x0,#48]
    ldr w8,[x29,#140]
    ldr w9,[x29,#136]
    sub w8,w8,w9
    add w8,w8,#1
    str x8,[x0,#56]
    mov x1,x19
    bl COLUMN_UNIFORM_SYMBOL

    mov w8,#1
    str w8,[x29,#148]        /* One cloudy layer at the selected top. */
    str wzr,[x29,#152]       /* Cloud-location sample counter. */
    ldr w8,[x29,#136]
    add w8,w8,#1
    str w8,[x29,#144]
.Lcolumn_level:
    ldr w8,[x29,#144]
    ldr w9,[x29,#140]
    cmp w8,w9
    b.gt .Lcolumn_fill
    ldr w10,[x29,#152]
    ldr x11,[x29,#96]
    ldr d0,[x11,w10,uxtw #3]
    add w10,w10,#1
    str w10,[x29,#152]
    sub w9,w8,#2
    ldr d1,[x21,w9,uxtw #3] /* Upper cloud fraction. */
    ldr d2,[x22,w9,uxtw #3] /* Adjacent pair cover. */
    ldr w10,[x29,#148]
    cbz w10,.Lcolumn_clear_above
    sub w9,w8,#1
    ldr d3,[x21,w9,uxtw #3]
    fadd d3,d3,d1
    fsub d3,d3,d2
    fmul d0,d0,d1
    fcmp d0,d3
    b.ge .Lcolumn_fill
    add w10,w10,#1
    str w10,[x29,#148]
    b .Lcolumn_next
.Lcolumn_clear_above:
    ldr d3,[x23,w9,uxtw #3]
    fsub d3,d3,d1
    fmul d0,d0,d3
    ldr d3,[x24,w9,uxtw #3]
    fsub d2,d2,d3
    fsub d2,d2,d1
    fcmp d0,d2
    b.ge .Lcolumn_next
    mov w10,#1
    str w10,[x29,#148]
    b .Lcolumn_next

.Lcolumn_fill:
    add x0,x29,#160
    ldr x8,[x29,#104]
    str x8,[x0]
    ldr w8,[x29,#148]
    str x8,[x0,#56]
    mov x1,x19
    bl COLUMN_UNIFORM_SYMBOL
    add x0,x29,#160
    ldr x8,[x29,#112]
    str x8,[x0]
    mov x1,x19
    bl COLUMN_UNIFORM_SYMBOL
    ldr w8,[x29,#148]
    cbz w8,.Lcolumn_filled
    mov w9,#1               /* Zero-based group position, starting at two. */
.Lcolumn_share:
    ldr w8,[x29,#148]
    cmp w9,w8
    b.ge .Lcolumn_samples
    ldr x10,[x29,#112]
    ldr d0,[x10,w9,uxtw #3]
    ldr w10,[x29,#144]
    sub w10,w10,w8
    add w10,w10,w9
    sub w10,w10,#2
    ldr d1,[x26,w10,uxtw #3]
    fcmp d0,d1
    b.ge .Lcolumn_share_next
    ldr x10,[x29,#104]
    sub w11,w9,#1
    ldr d0,[x10,w11,uxtw #3]
    str d0,[x10,w9,uxtw #3]
.Lcolumn_share_next:
    add w9,w9,#1
    b .Lcolumn_share
.Lcolumn_samples:
    str wzr,[x29,#156]
.Lcolumn_sample:
    ldr w8,[x29,#156]
    ldr w9,[x29,#148]
    cmp w8,w9
    b.ge .Lcolumn_filled
    ldr w10,[x29,#144]
    sub w10,w10,w9
    sub w10,w10,#1
    add w10,w10,w8
    mov x0,x20
    add x1,x25,w10,uxtw #3
    ldr x2,[x29,#104]
    add x2,x2,w8,uxtw #3
    uxtw x10,w10
    mul x10,x10,x28
    ldr w11,[x29,#128]
    add x10,x10,w11,uxtw #3
    add x3,x27,x10
    bl COLUMN_PDF_SYMBOL
    ldr w8,[x29,#156]
    add w8,w8,#1
    str w8,[x29,#156]
    b .Lcolumn_sample
.Lcolumn_filled:
    str wzr,[x29,#148]
.Lcolumn_next:
    ldr w8,[x29,#144]
    ldr w9,[x29,#140]
    add w9,w9,#1
    cmp w8,w9
    b.eq .Lcolumn_done
    add w8,w8,#1
    str w8,[x29,#144]
    b .Lcolumn_level
.Lcolumn_done:
    mov sp,x29
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    add sp,sp,#224
    ret
.size COLUMN_SYMBOL,.-COLUMN_SYMBOL
.section .note.GNU-stack,"",%progbits

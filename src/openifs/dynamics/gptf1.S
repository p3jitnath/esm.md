/* Complete GPTF1 from the frozen two-part time-filter contract.
 * Arguments are addresses in the GNU Fortran AArch64 ABI.
 * The 288-byte frame preserves x19-x30. Field values keep their units.
 * Private helpers copy bits, clear positive zeros or evaluate the ordered
 * FP64 partial filter. Independent field pairs do not share storage. */
#ifndef GPTF1_NAME
#define GPTF1_NAME gptf1_
#endif
.text
.p2align 4
.global GPTF1_NAME
.type GPTF1_NAME,%function

/* Walk a fixed set of field-map offsets. The table and counter live in
 * the private frame because the field helper owns caller registers. */
.macro TF1_GROUP table, count, base, rows, span, mode
    adrp x13,\table
    add x13,x13,:lo12:\table
    str x13,[x29,#144]
    mov w14,#\count
    str w14,[x29,#152]
.Ltf1_group_\@:
    ldr x13,[x29,#144]
    ldp w1,w2,[x13],#8
    str x13,[x29,#144]
    ldr w1,[x22,w1,uxtw]
    ldr w2,[x23,w2,uxtw]
    mov x0,\base
    mov x3,\rows
    mov x4,\span
    mov x5,x24
    mov x6,x26
    mov x7,x27
    mov w12,#\mode
    bl .Ltf1_field
    ldr w14,[x29,#152]
    subs w14,w14,#1
    str w14,[x29,#152]
    b.ne .Ltf1_group_\@
.endm

GPTF1_NAME:
    stp x29,x30,[sp,#-288]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x1,[sp,#96]
    str x2,[sp,#104]
    str x3,[sp,#112]
    str x4,[sp,#120]
    ldr w9,[x5]
    str w9,[sp,#128]
    ldr x9,[sp,#288]
    ldr w9,[x9]
    str w9,[sp,#132]
    ldr x19,[sp,#296]
    ldr x20,[sp,#304]
    ldr x21,[sp,#312]
    add x22,x1,#1000
    add x23,x1,#1108
    ldr w9,[x0,#5144]
    ldr w28,[x0,#5224]
    sxtw x24,w9
    sxtw x28,w28
    lsl x24,x24,#3
    mul x25,x24,x28
    ldr w9,[x6]
    ldr w10,[x7]
    sub w11,w9,#1
    sxtw x26,w11
    lsl x26,x26,#3
    sub w11,w10,w9
    add w11,w11,#1
    sxtw x27,w11
    ldr w9,[sp,#128]
    cbz w9,.Ltf1_disabled
    ldr x9,[sp,#120]
    ldr w10,[x9,#20]
    cbz w10,.Ltf1_leapfrog

    TF1_GROUP .Ltf1_motion,2,x19,x28,x25,0
    ldr x9,[sp,#120]
    ldr w10,[x9,#200]
    cbz w10,.Ltf1_copy_full
    TF1_GROUP .Ltf1_gradients,2,x19,x28,x25,0
.Ltf1_copy_full:
    ldr x9,[sp,#120]
    ldr w10,[x9,#336]
    cbz w10,.Ltf1_return
    TF1_GROUP .Ltf1_temperature,3,x19,x28,x25,0
    mov w12,#0
    bl .Ltf1_tracers
    ldr x9,[sp,#120]
    ldr w10,[x9,#8]
    cbz w10,.Ltf1_copy_surface
    TF1_GROUP .Ltf1_nonhydro,6,x19,x28,x25,0
.Ltf1_copy_surface:
    TF1_GROUP .Ltf1_surface,3,x20,#1,x24,0
    b .Ltf1_return

.Ltf1_disabled:
    ldr x9,[sp,#120]
    ldr w10,[x9,#200]
    cbz w10,.Ltf1_return
    TF1_GROUP .Ltf1_gradients,2,x19,x28,x25,0
    b .Ltf1_return

.Ltf1_leapfrog:
    ldr x9,[sp,#112]
    ldp d0,d2,[x9]
    fadd d1,d0,d2
    fmov d3,#1.0
    fsub d1,d3,d1
    stp d0,d1,[sp,#176]
    ldp d5,d6,[x9,#16]
    fadd d6,d5,d6
    fsub d6,d3,d6
    stp d5,d6,[sp,#192]
    ldr w9,[sp,#132]
    cbnz w9,.Ltf1_last
    TF1_GROUP .Ltf1_motion,3,x19,x28,x25,1
    ldr x9,[sp,#104]
    ldr w10,[x9,#8]
    cmp w10,#1
    b.lt .Ltf1_weight_nonhydro
    TF1_GROUP .Ltf1_temperature,3,x19,x28,x25,1
.Ltf1_weight_nonhydro:
    ldr x9,[sp,#120]
    ldr w10,[x9,#8]
    cbz w10,.Ltf1_weight_tracers
    TF1_GROUP .Ltf1_nonhydro,6,x19,x28,x25,1
.Ltf1_weight_tracers:
    ldp d0,d1,[sp,#192]
    mov w12,#1
    bl .Ltf1_tracers
    ldp d0,d1,[sp,#176]
    TF1_GROUP .Ltf1_surface,3,x20,#1,x24,1
    b .Ltf1_return

/* The last-step air and surface clears cover all columns, including
 * inactive columns. The tracer clear still uses the active interval. */
.Ltf1_last:
    ldr x9,[sp,#96]
    ldr w10,[x9,#992]
    ldr w11,[x22]
    sxtw x10,w10
    sxtw x11,w11
    sub x1,x10,x11
    mul x1,x1,x25
    mul x11,x11,x25
    add x0,x19,x11
    bl .Ltf1_zero_bytes
    ldr x9,[sp,#96]
    ldr w10,[x9,#996]
    ldr w11,[x22,#4]
    sxtw x10,w10
    sxtw x11,w11
    sub x1,x10,x11
    mul x1,x1,x24
    mul x11,x11,x24
    add x0,x20,x11
    bl .Ltf1_zero_bytes
    mov w12,#3
    bl .Ltf1_tracers

.Ltf1_return:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#288
    ret
.size GPTF1_NAME,.-GPTF1_NAME

/* Read only enabled tracer descriptors and retain the main frame pointer.
 * Field-helper modes are zero for copying, one for weighting and three
 * for clearing. The helper leaves d0 and d1 unchanged. */
.Ltf1_tracers:
    stp x29,x30,[sp,#-16]!
    str w12,[x29,#136]
    ldr x13,[x29,#104]
    ldr w14,[x13,#184]
    cmp w14,#0
    b.le .Ltf1_tracers_done
    add x13,x13,#4032
    str x13,[x29,#160]
    str w14,[x29,#168]
.Ltf1_tracer_loop:
    ldr x13,[x29,#160]
    ldr w14,[x13,#88]
    cbz w14,.Ltf1_tracer_next
    ldr w1,[x13,#168]
    ldr w2,[x13,#180]
    mov x0,x21
    mov x3,x28
    mov x4,x25
    mov x5,x24
    mov x6,x26
    mov x7,x27
    ldr w12,[x29,#136]
    bl .Ltf1_field
.Ltf1_tracer_next:
    ldr x13,[x29,#160]
    add x13,x13,#368
    str x13,[x29,#160]
    ldr w14,[x29,#168]
    subs w14,w14,#1
    str w14,[x29,#168]
    b.ne .Ltf1_tracer_loop
.Ltf1_tracers_done:
    ldp x29,x30,[sp],#16
    ret

/* x0 is the array, w1/w2 the one-based source/destination fields,
 * x3 the row count, x4 a field span, x5 a row span, x6 the first active
 * byte and x7 the active count. Empty selections access no field. */
.Ltf1_field:
    cmp x3,#0
    b.le .Ltf1_field_done
    cmp x7,#0
    b.le .Ltf1_field_done
    sub w2,w2,#1
    sxtw x2,w2
    madd x9,x2,x4,x0
    add x9,x9,x6
    cmp w12,#3
    b.eq .Ltf1_zero_rows
    sub w1,w1,#1
    sxtw x1,w1
    madd x8,x1,x4,x0
    add x8,x8,x6
    mov x11,x3
.Ltf1_field_row:
    mov x13,x8
    mov x14,x9
    mov x10,x7
.Ltf1_field_cell:
    cbnz w12,.Ltf1_weight_cell
    ldr x15,[x13],#8
    str x15,[x14],#8
    b .Ltf1_field_next
.Ltf1_weight_cell:
    ldr d2,[x13],#8
    ldr d3,[x14]
    fmul d3,d0,d3
    fmul d4,d1,d2
    fadd d3,d3,d4
    str d3,[x14],#8
.Ltf1_field_next:
    subs x10,x10,#1
    b.ne .Ltf1_field_cell
    add x8,x8,x5
    add x9,x9,x5
    subs x11,x11,#1
    b.ne .Ltf1_field_row
.Ltf1_field_done:
    ret
.Ltf1_zero_rows:
    mov x11,x3
.Ltf1_zero_row:
    mov x14,x9
    mov x10,x7
.Ltf1_zero_cell:
    str xzr,[x14],#8
    subs x10,x10,#1
    b.ne .Ltf1_zero_cell
    add x9,x9,x5
    subs x11,x11,#1
    b.ne .Ltf1_zero_row
    ret

.Ltf1_zero_bytes:
    cmp x1,#0
    b.le .Ltf1_zero_done
.Ltf1_zero_byte_loop:
    str xzr,[x0],#8
    subs x1,x1,#8
    b.ne .Ltf1_zero_byte_loop
.Ltf1_zero_done:
    ret

.section .rodata
.p2align 3
.Ltf1_motion: .word 12,8,16,12,32,80
.Ltf1_temperature: .word 20,16,24,20,28,24
.Ltf1_nonhydro: .word 48,96,60,108,52,100,64,112,56,104,68,116
.Ltf1_gradients: .word 88,208,92,212
.Ltf1_surface: .word 96,216,100,220,104,224
.section .note.GNU-stack,"",%progbits

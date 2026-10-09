/* Complete GPTF2 from the frozen two-part time-filter contract.
 * Arguments are addresses in the GNU Fortran AArch64 ABI.
 * The 288-byte frame preserves x19-x30. Field values keep their units.
 * Private helpers copy bits or evaluate the ordered
 * FP64 final contribution. Independent field pairs do not share storage. */
#ifndef GPTF2_NAME
#define GPTF2_NAME gptf2_
#endif
.text
.p2align 4
.global GPTF2_NAME
.type GPTF2_NAME,%function

/* Walk a fixed set of field-map offsets. The table and counter live in
 * the private frame because the field helper owns caller registers. */
.macro TF2_GROUP table, count, base, rows, span
    adrp x13,\table
    add x13,x13,:lo12:\table
    str x13,[x29,#144]
    mov w14,#\count
    str w14,[x29,#152]
.Ltf2_group_\@:
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
    ldr w12,[x29,#128]
    bl .Ltf2_field
    ldr w14,[x29,#152]
    subs w14,w14,#1
    str w14,[x29,#152]
    b.ne .Ltf2_group_\@
.endm

GPTF2_NAME:
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
    ldr w9,[x7]
    str w9,[sp,#132]
    ldr x19,[sp,#288]
    ldr x20,[sp,#296]
    ldr x21,[sp,#304]
    add x22,x1,#1000
    add x23,x1,#1108
    ldr w9,[x0,#5144]
    ldr w28,[x0,#5224]
    sxtw x24,w9
    sxtw x28,w28
    lsl x24,x24,#3
    mul x25,x24,x28
    ldr w9,[x5]
    ldr w10,[x6]
    sub w11,w9,#1
    sxtw x26,w11
    lsl x26,x26,#3
    sub w11,w10,w9
    add w11,w11,#1
    sxtw x27,w11
    ldr x9,[sp,#120]
    ldr w10,[x9,#20]
    cbz w10,.Ltf2_three_levels
    ldr w9,[sp,#132]
    cbz w9,.Ltf2_return
    str wzr,[sp,#128]
    TF2_GROUP .Ltf2_motion,2,x19,x28,x25
    b .Ltf2_return

.Ltf2_three_levels:
    mov w10,#0
    ldr w9,[sp,#132]
    cbnz w9,.Ltf2_selected
    mov w10,#2
.Ltf2_selected:
    str w10,[sp,#128]
    ldr x9,[sp,#112]
    ldr d1,[x9,#8]
    TF2_GROUP .Ltf2_motion,3,x19,x28,x25
    ldr x9,[sp,#104]
    ldr w10,[x9,#8]
    cmp w10,#1
    b.lt .Ltf2_nonhydro
    TF2_GROUP .Ltf2_temperature,3,x19,x28,x25
.Ltf2_nonhydro:
    ldr x9,[sp,#120]
    ldr w10,[x9,#8]
    cbz w10,.Ltf2_tracers_selected
    TF2_GROUP .Ltf2_nonhydro_fields,6,x19,x28,x25
    ldr w9,[sp,#132]
    cbz w9,.Ltf2_tracers_selected
    ldr x9,[sp,#120]
    ldr w10,[x9,#32]
    cmp w10,#4
    b.ne .Ltf2_tracers_selected
    TF2_GROUP .Ltf2_extra,1,x19,x28,x25
.Ltf2_tracers_selected:
    str d1,[sp,#184]
    ldr x9,[sp,#112]
    ldr d1,[x9,#24]
    ldr w12,[sp,#128]
    bl .Ltf2_tracers
    ldr d1,[sp,#184]
    TF2_GROUP .Ltf2_surface,3,x20,#1,x24
.Ltf2_return:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#288
    ret
.size GPTF2_NAME,.-GPTF2_NAME

/* The private tracer helper owns sixteen stack bytes and preserves the
 * public frame pointer. Its field helper keeps the selected coefficient. */
.Ltf2_tracers:
    stp x29,x30,[sp,#-16]!
    str w12,[x29,#136]
    ldr x13,[x29,#104]
    ldr w14,[x13,#184]
    cmp w14,#0
    b.le .Ltf2_tracers_done
    add x13,x13,#4032
    str x13,[x29,#160]
    str w14,[x29,#168]
.Ltf2_tracer_loop:
    ldr x13,[x29,#160]
    ldr w14,[x13,#88]
    cbz w14,.Ltf2_tracer_next
    ldr w1,[x13,#168]
    ldr w2,[x13,#180]
    mov x0,x21
    mov x3,x28
    mov x4,x25
    mov x5,x24
    mov x6,x26
    mov x7,x27
    ldr w12,[x29,#136]
    bl .Ltf2_field
.Ltf2_tracer_next:
    ldr x13,[x29,#160]
    add x13,x13,#368
    str x13,[x29,#160]
    ldr w14,[x29,#168]
    subs w14,w14,#1
    str w14,[x29,#168]
    b.ne .Ltf2_tracer_loop
.Ltf2_tracers_done:
    ldp x29,x30,[sp],#16
    ret

/* x0 is the array, w1/w2 the one-based source/destination fields,
 * x3 the row count, x4 a field span, x5 a row span, x6 the first active
 * byte and x7 the active count. Empty selections access no field. */
.Ltf2_field:
    cmp x3,#0
    b.le .Ltf2_field_done
    cmp x7,#0
    b.le .Ltf2_field_done
    sub w2,w2,#1
    sxtw x2,w2
    madd x9,x2,x4,x0
    add x9,x9,x6
    sub w1,w1,#1
    sxtw x1,w1
    madd x8,x1,x4,x0
    add x8,x8,x6
    mov x11,x3
.Ltf2_field_row:
    mov x13,x8
    mov x14,x9
    mov x10,x7
.Ltf2_field_cell:
    cbnz w12,.Ltf2_add_cell
    ldr x15,[x13],#8
    str x15,[x14],#8
    b .Ltf2_field_next
.Ltf2_add_cell:
    ldr d2,[x13],#8
    ldr d3,[x14]
    fmul d4,d1,d2
    fadd d3,d3,d4
    str d3,[x14],#8
.Ltf2_field_next:
    subs x10,x10,#1
    b.ne .Ltf2_field_cell
    add x8,x8,x5
    add x9,x9,x5
    subs x11,x11,#1
    b.ne .Ltf2_field_row
.Ltf2_field_done:
    ret
.section .rodata
.p2align 3
.Ltf2_motion: .word 12,8,16,12,32,80
.Ltf2_temperature: .word 20,16,24,20,28,24
.Ltf2_nonhydro_fields: .word 48,96,60,108,52,100,64,112,56,104,68,116
.Ltf2_surface: .word 96,216,100,220,104,224
.Ltf2_extra: .word 72,120
.section .note.GNU-stack,"",%progbits

// Physics input formulations/openifs/transport/spherical_halo.md.
// Complete contract skills/md2asm/references/openifs/transport/spherical_halo.md.
// Direct AArch64 boundary copies and exact parity multiplication.
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL slextpol_
#endif
.text
.p2align 4
.global md2asm_spherical_halo
.global ORIGINAL_SYMBOL
.type md2asm_spherical_halo,%function
.type ORIGINAL_SYMBOL,%function
ORIGINAL_SYMBOL:
md2asm_spherical_halo:
    sub sp,sp,#256
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    mov x19,sp
    mov x20,x1
    mov x21,x6
    mov x22,x5
    mov x23,x7
    ldr w24,[x20,#1016]
    ldr w25,[x2]
    ldr w26,[x4]
    ldr w8,[x0,#72]
    str w8,[x19,#120]
    ldp w8,w9,[x3]
    stp w8,w9,[x19,#124]
    ldr w8,[x20,#1648]
    str w8,[x19,#112]
    ldr w8,[x20,#1720]
    str w8,[x19,#116]
    ldr w9,[x20,#1724]
    ldr w10,[x20,#1348]
    sub w9,w9,w10
    ldr w10,[x20,#1656]
    cmp w9,w10
    csel w9,w9,w10,ge
    sub w9,w9,w8
    str w9,[x19,#104]
    ldr w9,[x20,#1728]
    ldr w10,[x20,#1352]
    add w9,w9,w10
    ldr w10,[x20,#1660]
    cmp w9,w10
    csel w9,w9,w10,le
    sub w9,w9,w8
    str w9,[x19,#108]
    lsl x8,x24,#3
    add x8,x8,#15
    and x8,x8,#-16
    sub sp,sp,x8
    mov x9,sp
    str x9,[x19,#176]
    cbz x23,.Lmask_zero_done
    mov x8,#0
.Lmask_zero:
    cmp x8,x24
    b.ge .Lmask_zero_done
    str wzr,[x23,x8,lsl #2]
    add x8,x8,#1
    b .Lmask_zero
.Lmask_zero_done:
    ldrsw x27,[x19,#104]
.Lpolar_row:
    ldrsw x8,[x19,#108]
    cmp x27,x8
    b.gt .Lperiodic_begin
    bl .Lrow_metadata
    ldr w8,[x19,#200]
    cmp w8,#0
    b.le .Lnorth
    ldr w9,[x19,#112]
    cmp w8,w9
    b.le .Lpolar_next
    add w9,w9,w9
    add w9,w9,#1
    sub w9,w9,w8
    b .Lsource_row
.Lnorth:
    mov w9,#1
    sub w9,w9,w8
.Lsource_row:
    str w9,[x19,#148]
    ldr w8,[x19,#116]
    sub w9,w9,w8
    str w9,[x19,#152]
    add x0,x20,#72
    sxtw x1,w9
    bl .Lcomponent
    str w0,[x19,#156]
    add x0,x20,#8
    ldrsw x1,[x19,#152]
    bl .Lcomponent
    str w0,[x19,#160]
    add x0,x20,#136
    ldrsw x1,[x19,#152]
    bl .Lcomponent
    str w0,[x19,#164]
    add x0,x20,#1736
    ldrsw x1,[x19,#148]
    bl .Lcomponent
    str w0,[x19,#168]
    mov x28,#0
.Lpolar_point:
    ldrsw x8,[x19,#136]
    cmp x28,x8
    b.ge .Lpolar_fields
    ldr w0,[x19,#132]
    add w0,w0,w28
    bl .Lpoint_map
    cmp w26,#1
    b.ne .Lsave_pair
    str w0,[x19,#204]
    str w1,[x19,#208]
    cmp w0,w1
    b.eq .Lpoint_parity
    add x9,x21,x0,lsl #3
    add x10,x21,x1,lsl #3
    mov x8,#0
    lsl x11,x24,#3
.Lpoint_copy:
    ldr d0,[x10]
    str d0,[x9]
    add x9,x9,x11
    add x10,x10,x11
    add x8,x8,#1
    cmp x8,x25
    b.lt .Lpoint_copy
.Lpoint_parity:
    ldr w0,[x19,#204]
    add x9,x21,x0,lsl #3
    mov x8,#0
    lsl x11,x24,#3
.Lpoint_multiply:
    ldr d0,[x9]
    ldr d1,[x22,x8,lsl #3]
    fmul d0,d1,d0
    str d0,[x9]
    add x9,x9,x11
    add x8,x8,#1
    cmp x8,x25
    b.lt .Lpoint_multiply
    b .Lpoint_next
.Lsave_pair:
    ldr x8,[x19,#176]
    add x8,x8,x28,lsl #3
    stp w0,w1,[x8]
.Lpoint_next:
    add x28,x28,#1
    b .Lpolar_point
.Lpolar_fields:
    cmp w26,#1
    b.eq .Lpolar_next
    mov x28,#0
.Lpolar_field:
    cmp x28,x25
    b.ge .Lpolar_mask
    mov w0,w28
    bl .Lfield_selected
    cbz w0,.Lpolar_field_next
    mul x8,x28,x24
    add x8,x21,x8,lsl #3
    ldr d1,[x22,x28,lsl #3]
    ldr x9,[x19,#176]
    ldr w10,[x19,#136]
    mov w11,#0
.Lpolar_apply:
    cmp w11,w10
    b.ge .Lpolar_field_next
    ldp w12,w13,[x9],#8
    ldr d0,[x8,x13,lsl #3]
    fmul d0,d1,d0
    str d0,[x8,x12,lsl #3]
    add w11,w11,#1
    b .Lpolar_apply
.Lpolar_field_next:
    add x28,x28,#1
    b .Lpolar_field
.Lpolar_mask:
    cmp w26,#3
    b.ne .Lpolar_next
    cbz x23,.Lpolar_next
    ldr x9,[x19,#176]
    ldr w10,[x19,#136]
    mov w11,#0
    mov w12,#1
.Lpolar_mask_loop:
    cmp w11,w10
    b.ge .Lpolar_next
    ldr w13,[x9,#4]
    str w12,[x23,x13,lsl #2]
    add x9,x9,#8
    add w11,w11,#1
    b .Lpolar_mask_loop
.Lpolar_next:
    add x27,x27,#1
    b .Lpolar_row
.Lperiodic_begin:
    cmp w26,#1
    b.ne .Lperiod_field_begin
    ldrsw x27,[x19,#104]
.Lperiod_row:
    ldrsw x8,[x19,#108]
    cmp x27,x8
    b.gt .Lreturn
    bl .Lrow_metadata
    ldr w8,[x19,#136]
    ldr w10,[x19,#144]
    cmp w8,w10
    b.ne .Lperiod_row_next
    mov x28,#0
.Lperiod_row_field:
    cmp x28,x25
    b.ge .Lperiod_row_next
    bl .Lstar
    add x28,x28,#1
    b .Lperiod_row_field
.Lperiod_row_next:
    add x27,x27,#1
    b .Lperiod_row
.Lperiod_field_begin:
    mov x28,#0
.Lperiod_field:
    cmp x28,x25
    b.ge .Lperiod_mask_begin
    mov w0,w28
    bl .Lfield_selected
    cbz w0,.Lperiod_field_next
    ldrsw x27,[x19,#104]
.Lperiod_field_row:
    ldrsw x8,[x19,#108]
    cmp x27,x8
    b.gt .Lperiod_field_next
    bl .Lrow_metadata
    ldr w8,[x19,#136]
    ldr w9,[x19,#144]
    cmp w8,w9
    b.ne .Lperiod_field_row_next
    bl .Lstar
.Lperiod_field_row_next:
    add x27,x27,#1
    b .Lperiod_field_row
.Lperiod_field_next:
    add x28,x28,#1
    b .Lperiod_field
.Lperiod_mask_begin:
    cmp w26,#3
    b.ne .Lreturn
    cbz x23,.Lreturn
    ldrsw x27,[x19,#104]
.Lperiod_mask_row:
    ldrsw x8,[x19,#108]
    cmp x27,x8
    b.gt .Lreturn
    bl .Lrow_metadata
    ldr w8,[x19,#136]
    ldr w9,[x19,#144]
    cmp w8,w9
    b.ne .Lperiod_mask_next
    ldr w8,[x19,#140]
    ldr w10,[x19,#120]
    add w9,w9,w8
    mov w11,#1
    sub w9,w9,#1
    str w11,[x23,x9,lsl #2]
    cmp w10,#3
    b.ne .Lperiod_mask_left_done
    sub w9,w9,#1
    str w11,[x23,x9,lsl #2]
.Lperiod_mask_left_done:
    str w11,[x23,x8,lsl #2]
    add w8,w8,#1
    str w11,[x23,x8,lsl #2]
    cmp w10,#3
    b.ne .Lperiod_mask_next
    add w8,w8,#1
    str w11,[x23,x8,lsl #2]
.Lperiod_mask_next:
    add x27,x27,#1
    b .Lperiod_mask_row
.Lreturn:
    mov sp,x19
    ldp x29,x30,[sp,#80]
    ldp x27,x28,[sp,#64]
    ldp x25,x26,[sp,#48]
    ldp x23,x24,[sp,#32]
    ldp x21,x22,[sp,#16]
    ldp x19,x20,[sp,#0]
    add sp,sp,#256
    ret
// A contiguous allocatable integer component uses its stored index offset.
.Lcomponent:
    ldp x2,x3,[x0]
    add x1,x1,x3
    ldr w0,[x2,x1,lsl #2]
    ret
.Lrow_metadata:
    stp x29,x30,[x19,#232]
    add x0,x20,#8
    mov x1,x27
    bl .Lcomponent
    str w0,[x19,#132]
    add x0,x20,#72
    mov x1,x27
    bl .Lcomponent
    str w0,[x19,#136]
    add x0,x20,#136
    mov x1,x27
    bl .Lcomponent
    str w0,[x19,#140]
    ldr w8,[x19,#116]
    add w8,w8,w27
    str w8,[x19,#200]
    add x0,x20,#1736
    sxtw x1,w8
    bl .Lcomponent
    str w0,[x19,#144]
    ldp x29,x30,[x19,#232]
    ret
// Preserve integer MOD with truncation toward zero.
.Lpoint_map:
    ldr w2,[x19,#144]
    sub w3,w0,#1
    add w3,w3,w2
    sdiv w4,w3,w2
    msub w3,w4,w2,w3
    add w3,w3,#1
    ldr w4,[x19,#132]
    sub w5,w3,w4
    add w5,w5,w2
    sdiv w6,w5,w2
    msub w5,w6,w2,w5
    ldr w6,[x19,#140]
    add w0,w6,w5
    ldr w2,[x19,#168]
    ldr w4,[x19,#160]
    sub w5,w3,w4
    add w5,w5,w2
    sdiv w6,w5,w2
    msub w5,w6,w2,w5
    ldr w6,[x19,#164]
    add w1,w6,w5
    ldr w7,[x19,#156]
    add w7,w7,w6
    sub w7,w7,#1
    cmp w1,w6
    b.lt .Lself_source
    cmp w1,w7
    b.le .Lmapped_source
.Lself_source:
    mov w1,w0
.Lmapped_source:
    ret
// Select a field interval or its two ordered outer intervals.
.Lfield_selected:
    cmp w26,#1
    b.eq .Lfield_yes
    add w0,w0,#1
    ldp w1,w2,[x19,#124]
    cmp w0,w1
    b.lt .Loutside
    cmp w0,w2
    b.gt .Loutside
    cmp w26,#3
    cset w0,eq
    ret
.Loutside:
    cmp w26,#2
    cset w0,eq
    ret
.Lfield_yes:
    mov w0,#1
    ret
// Copy row ghosts in the original left-to-right store order.
.Lstar:
    mul x0,x28,x24
    ldrsw x1,[x19,#140]
    add x0,x0,x1
    add x0,x21,x0,lsl #3
    ldrsw x1,[x19,#144]
    add x1,x0,x1,lsl #3
    ldr w2,[x19,#120]
    cmp w2,#3
    b.eq .Lstar_three
    ldr d0,[x1,#-8]
    str d0,[x0,#-8]
    ldr d0,[x0]
    str d0,[x1]
    ldr d0,[x0,#8]
    str d0,[x1,#8]
    ret
.Lstar_three:
    ldr d0,[x1,#-16]
    str d0,[x0,#-16]
    ldr d0,[x1,#-8]
    str d0,[x0,#-8]
    ldr d0,[x0]
    str d0,[x1]
    ldr d0,[x0,#8]
    str d0,[x1,#8]
    ldr d0,[x0,#16]
    str d0,[x1,#16]
    ret
.size md2asm_spherical_halo,.-md2asm_spherical_halo
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .note.GNU-stack,"",%progbits

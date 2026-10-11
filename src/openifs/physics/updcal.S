/* Direct Gregorian calendar update from the frozen ordered contract.
 * Physics formulations/openifs/physics/calendar_days.md
 * Contract skills/md2asm/references/openifs/physics/updcal.md
 * Complete UPDCAL date arithmetic. Nine ordinary addresses, JPIM int32.
 * Only admitted dates and non-writing console modes reach public stores.
 */
.text
.p2align 4
.macro CAL_LEAP out,year
    mov \out,#28
    mov w9,#4
    sdiv w10,\year,w9
    msub w10,w10,w9,\year
    cbnz w10,.Lcal_leap_done\@
    mov w9,#400
    sdiv w10,\year,w9
    msub w10,w10,w9,\year
    cmp w10,#100
    b.eq .Lcal_leap_done\@
    cmp w10,#200
    b.eq .Lcal_leap_done\@
    cmp w10,#300
    b.eq .Lcal_leap_done\@
    mov \out,#29
.Lcal_leap_done\@:
.endm
.global md2asm_updcal
.type md2asm_updcal,%function
md2asm_updcal:
    stp x29,x30,[sp,#-256]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    stp x0,x1,[sp,#96]
    stp x2,x3,[sp,#112]
    stp x4,x5,[sp,#128]
    stp x6,x7,[sp,#144]
    ldr x8,[sp,#256]
    str x8,[sp,#160]
    mrs x9,fpcr
    cbnz x9,.Lcal_bad
    add x28,sp,#96
    mov w11,#0
.Lcal_ptr:
    ldr x9,[x28,x11,lsl #3]
    cbz x9,.Lcal_bad
    tst x9,#3
    b.ne .Lcal_bad
    add w11,w11,#1
    cmp w11,#9
    b.lo .Lcal_ptr
    mov w11,#4
.Lcal_overlap_out:
    ldr x12,[x28,x11,lsl #3]
    cmp w11,#7
    mov x13,#4
    mov x9,#48
    csel x13,x9,x13,eq
    adds x13,x12,x13
    b.cs .Lcal_bad
    mov w14,#0
.Lcal_overlap_any:
    cmp w11,w14
    b.eq .Lcal_overlap_next
    ldr x15,[x28,x14,lsl #3]
    cmp w14,#7
    mov x16,#4
    mov x9,#48
    csel x16,x9,x16,eq
    adds x16,x15,x16
    b.cs .Lcal_bad
    cmp x12,x16
    b.hs .Lcal_overlap_next
    cmp x15,x13
    b.lo .Lcal_bad
.Lcal_overlap_next:
    add w14,w14,#1
    cmp w14,#9
    b.lo .Lcal_overlap_any
    add w11,w11,#1
    cmp w11,#8
    b.lo .Lcal_overlap_out
    ldr w19,[x0]
    ldr w20,[x1]
    ldr w21,[x2]
    ldr w22,[x3]
    ldr w9,[x8]
    cmp w9,#0
    b.ge .Lcal_bad
    cmp w21,#1600
    b.lt .Lcal_bad
    mov w9,#3000
    cmp w21,w9
    b.gt .Lcal_bad
    cmp w20,#1
    b.lt .Lcal_bad
    cmp w20,#12
    b.gt .Lcal_bad
    cmp w19,#1
    b.lt .Lcal_bad
    mov w9,#36600
    cmp w22,w9
    b.gt .Lcal_bad
    cmn w22,#366
    b.lt .Lcal_bad
    add x27,sp,#176
    adrp x9,.Lcal_months
    add x9,x9,:lo12:.Lcal_months
    ldp q0,q1,[x9]
    ldr q2,[x9,#32]
    stp q0,q1,[x27]
    str q2,[x27,#32]
    CAL_LEAP w12,w21
    str w12,[x27,#4]
    sub w9,w20,#1
    ldr w10,[x27,w9,uxtw #2]
    cmp w19,w10
    b.gt .Lcal_bad
    cmp w22,#0
    b.ge .Lcal_admitted
    sub w12,w19,#1
    mov w11,#1
.Lcal_ordinal:
    cmp w11,w20
    b.ge .Lcal_ordinal_done
    sub w9,w11,#1
    ldr w10,[x27,w9,uxtw #2]
    add w12,w12,w10
    add w11,w11,#1
    b .Lcal_ordinal
.Lcal_ordinal_done:
    neg w9,w22
    cmp w9,w12
    b.gt .Lcal_bad
.Lcal_admitted:
    ldp x23,x24,[sp,#128]
    ldp x25,x26,[sp,#144]
    str w19,[x23]
    str w20,[x24]
    str w21,[x25]
    ldp q0,q1,[x27]
    ldr q2,[x27,#32]
    stp q0,q1,[x26]
    str q2,[x26,#32]
    cmp w22,#0
    b.lt .Lcal_backward
    cbz w22,.Lcal_return
.Lcal_forward:
    add w19,w19,#1
    str w19,[x23]
    sub w9,w20,#1
    ldr w10,[x26,w9,uxtw #2]
    cmp w19,w10
    b.le .Lcal_forward_next
    mov w19,#1
    str w19,[x23]
    add w20,w20,#1
    str w20,[x24]
    cmp w20,#12
    b.le .Lcal_forward_next
    mov w20,#1
    str w20,[x24]
    add w21,w21,#1
    str w21,[x25]
    CAL_LEAP w12,w21
    str w12,[x26,#4]
.Lcal_forward_next:
    subs w22,w22,#1
    b.ne .Lcal_forward
    b .Lcal_return
.Lcal_backward:
    neg w22,w22
.Lcal_backward_day:
    sub w19,w19,#1
    str w19,[x23]
    cmp w19,#0
    b.gt .Lcal_backward_next
    add w9,w20,#10
    mov w10,#12
    sdiv w11,w9,w10
    msub w9,w11,w10,w9
    add w20,w9,#1
    str w20,[x24]
    CAL_LEAP w12,w21
    str w12,[x26,#4]
    sub w9,w20,#1
    ldr w19,[x26,w9,uxtw #2]
    str w19,[x23]
    cmp w20,#12
    b.ne .Lcal_backward_next
    sub w21,w21,#1
    str w21,[x25]
.Lcal_backward_next:
    subs w22,w22,#1
    b.ne .Lcal_backward_day
.Lcal_return:
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#256
    ret
.Lcal_bad:
    bl abort
    brk #0
.size md2asm_updcal,.-md2asm_updcal
.section .rodata
.p2align 4
.Lcal_months:
    .word 31,28,31,30,31,30,31,31,30,31,30,31
.section .note.GNU-stack,"",%progbits

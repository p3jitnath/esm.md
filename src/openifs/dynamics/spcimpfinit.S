/* Complete SPCIMPFINIT from the frozen spectral Coriolis contract, revision 1.0.
 * x0 geometry, x1 time object, x2 dynamics object, x3 m*, x4 KSTA*,
 * x5 unused KEND*, x6 vorticity descriptor, x7 auxiliary descriptor.
 * All arithmetic is separately rounded FP64. The fixed frame is 224 bytes.
 * Five private factor arrays share one heap allocation; no driver supplies them.
 */
#ifndef SPCIMPFINIT_ENTRY
#define SPCIMPFINIT_ENTRY spcimpfinit_assembly_
#endif
.text
.p2align 4
.global SPCIMPFINIT_ENTRY
.type SPCIMPFINIT_ENTRY,%function
SPCIMPFINIT_ENTRY:
    stp x29,x30,[sp,#-224]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    ldr w28,[x3]
    ldr w9,[x4]
    str w9,[sp,#96]
    str x6,[sp,#104]
    str x7,[sp,#112]
    ldr w26,[x19,#5172]
    ldr w27,[x19,#5228]
    uxtw x0,w26
    add x0,x0,#2
    mov x9,#40
    mul x0,x0,x9
    bl malloc
    cbz x0,.Lallocation_failure
    mov x19,x0
    /* C01: prepare the common rounded force and m-dependent numerator. */
    ldr d0,[x21,#2496]
    ldr d1,[x20,#208]
    fmul d0,d0,d1
    fmov d1,#2.0
    fmul d0,d1,d0
    adrp x9,:got:__yomcst_MOD_romega
    ldr x9,[x9,:got_lo12:__yomcst_MOD_romega]
    ldr d1,[x9]
    fmul d16,d0,d1
    scvtf d17,w28
    fmul d18,d16,d17
    fmul d19,d17,d17
    fmov d20,#1.0
    fmov d21,#4.0
    uxtw x9,w26
    add x9,x9,#2
    lsl x9,x9,#3
    mov x20,x19
    add x21,x20,x9
    add x22,x21,x9
    add x23,x22,x9
    add x24,x23,x9
    mov w25,w28
    cbnz w28,.Lfactors
    str xzr,[x20]
    str xzr,[x21]
    str xzr,[x22]
    mov w25,#1
.Lfactors:
    scvtf d0,w25
    fadd d1,d0,d20
    fmul d2,d0,d1
    fdiv d2,d18,d2
    str d2,[x20,w25,uxtw #3]
    fmul d3,d2,d2
    fadd d3,d20,d3
    fdiv d3,d20,d3
    str d3,[x21,w25,uxtw #3]
    fmul d4,d0,d0
    fsub d4,d4,d19
    fmul d5,d21,d0
    fmul d5,d5,d0
    fsub d5,d5,d20
    fdiv d4,d4,d5
    fsqrt d4,d4
    str d4,[x22,w25,uxtw #3]
    add w25,w25,#1
    cmp w25,w26
    b.le .Lfactors
    add w9,w26,#1
    str xzr,[x20,w9,uxtw #3]
    str xzr,[x21,w9,uxtw #3]
    mov w25,w28
    cbnz w28,.Lneighbor_factor_test
    str xzr,[x23]
    str xzr,[x24]
    mov w25,#1
.Lneighbor_factor_test:
    cmp w25,w26
    b.ge .Llast_neighbor_factors
.Lneighbor_factors:
    scvtf d0,w25
    fadd d1,d0,d20
    fmul d2,d16,d0
    add w9,w25,#1
    ldr d3,[x22,w9,uxtw #3]
    fmul d2,d2,d3
    fdiv d2,d2,d1
    str d2,[x23,w25,uxtw #3]
    fmul d2,d16,d1
    ldr d3,[x22,w25,uxtw #3]
    fmul d2,d2,d3
    fdiv d2,d2,d0
    str d2,[x24,w25,uxtw #3]
    add w25,w25,#1
    cmp w25,w26
    b.lt .Lneighbor_factors
.Llast_neighbor_factors:
    scvtf d0,w26
    fadd d1,d0,d20
    str xzr,[x23,w26,uxtw #3]
    fmul d2,d16,d1
    ldr d3,[x22,w26,uxtw #3]
    fmul d2,d2,d3
    fdiv d2,d2,d0
    str d2,[x24,w26,uxtw #3]
    add w9,w26,#1
    str xzr,[x23,w9,uxtw #3]
    str xzr,[x24,w9,uxtw #3]
    cbz w27,.Lfree_factors
    /* The incoming descriptor data already names the first actual element. */
    ldr x9,[sp,#104]
    ldr x10,[x9]
    str x10,[sp,#120]
    ldr x10,[x9,#40]
    lsl x10,x10,#3
    str x10,[sp,#128]
    ldr x10,[x9,#64]
    lsl x10,x10,#3
    str x10,[sp,#136]
    ldr x9,[sp,#112]
    ldr x10,[x9]
    str x10,[sp,#144]
    ldr x10,[x9,#40]
    lsl x10,x10,#3
    str x10,[sp,#152]
    ldr x10,[x9,#64]
    lsl x10,x10,#3
    str x10,[sp,#160]
    ldr w9,[sp,#96]
    sub w9,w9,#1
    str x9,[sp,#168]
    cbz w28,.Lclear_begin
    /* C02: keep both old components while calculating the imaginary result. */
    mov w25,w28
.Linverse_degree:
    sub w9,w25,w28
    uxtw x9,w9
    lsl x9,x9,#1
    ldr x10,[sp,#168]
    add x9,x9,x10
    ldr x12,[sp,#120]
    ldr x13,[sp,#136]
    madd x10,x9,x13,x12
    add x11,x10,x13
    ldr x14,[sp,#128]
    mov w15,w27
    ldr d16,[x20,w25,uxtw #3]
    ldr d17,[x21,w25,uxtw #3]
.Linverse_level:
    ldr d0,[x10]
    ldr d1,[x11]
    fmul d2,d16,d0
    fadd d2,d1,d2
    fmul d2,d17,d2
    fmul d3,d16,d1
    fsub d3,d0,d3
    fmul d3,d17,d3
    str d3,[x10]
    str d2,[x11]
    add x10,x10,x14
    add x11,x11,x14
    subs w15,w15,#1
    b.ne .Linverse_level
    add w25,w25,#1
    cmp w25,w26
    b.le .Linverse_degree
.Lclear_begin:
    mov w25,w28
.Lclear_degree:
    sub w9,w25,w28
    uxtw x9,w9
    lsl x9,x9,#1
    ldr x10,[sp,#168]
    add x9,x9,x10
    ldr x12,[sp,#144]
    ldr x13,[sp,#160]
    madd x10,x9,x13,x12
    add x11,x10,x13
    ldr x14,[sp,#152]
    mov w15,w27
.Lclear_level:
    str xzr,[x10]
    str xzr,[x11]
    add x10,x10,x14
    add x11,x11,x14
    subs w15,w15,#1
    b.ne .Lclear_level
    add w25,w25,#1
    cmp w25,w26
    b.le .Lclear_degree
    /* C03: the complete lower-neighbor pass precedes the upper pass. */
    add w25,w28,#1
    cmp w25,w26
    b.gt .Lupper_begin
.Llower_degree:
    sub w9,w25,w28
    uxtw x9,w9
    lsl x9,x9,#1
    ldr x10,[sp,#168]
    add x9,x9,x10
    ldr x12,[sp,#144]
    ldr x13,[sp,#160]
    madd x10,x9,x13,x12
    add x11,x10,x13
    sub x9,x9,#2
    ldr x12,[sp,#120]
    ldr x13,[sp,#136]
    madd x12,x9,x13,x12
    add x13,x12,x13
    ldr x14,[sp,#128]
    ldr x15,[sp,#152]
    mov w16,w27
    ldr d16,[x24,w25,uxtw #3]
.Llower_level:
    ldr d0,[x10]
    ldr d1,[x12]
    fmul d1,d16,d1
    fadd d0,d0,d1
    str d0,[x10]
    ldr d0,[x11]
    ldr d1,[x13]
    fmul d1,d16,d1
    fadd d0,d0,d1
    str d0,[x11]
    add x10,x10,x15
    add x11,x11,x15
    add x12,x12,x14
    add x13,x13,x14
    subs w16,w16,#1
    b.ne .Llower_level
    add w25,w25,#1
    cmp w25,w26
    b.le .Llower_degree
.Lupper_begin:
    mov w25,w28
    cmp w25,w26
    b.ge .Lfree_factors
.Lupper_degree:
    sub w9,w25,w28
    uxtw x9,w9
    lsl x9,x9,#1
    ldr x10,[sp,#168]
    add x9,x9,x10
    ldr x12,[sp,#144]
    ldr x13,[sp,#160]
    madd x10,x9,x13,x12
    add x11,x10,x13
    add x9,x9,#2
    ldr x12,[sp,#120]
    ldr x13,[sp,#136]
    madd x12,x9,x13,x12
    add x13,x12,x13
    ldr x14,[sp,#128]
    ldr x15,[sp,#152]
    mov w16,w27
    ldr d16,[x23,w25,uxtw #3]
.Lupper_level:
    ldr d0,[x10]
    ldr d1,[x12]
    fmul d1,d16,d1
    fadd d0,d0,d1
    str d0,[x10]
    ldr d0,[x11]
    ldr d1,[x13]
    fmul d1,d16,d1
    fadd d0,d0,d1
    str d0,[x11]
    add x10,x10,x15
    add x11,x11,x15
    add x12,x12,x14
    add x13,x13,x14
    subs w16,w16,#1
    b.ne .Lupper_level
    add w25,w25,#1
    cmp w25,w26
    b.lt .Lupper_degree
.Lfree_factors:
    mov x0,x19
    bl free
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#224
    ret
.Lallocation_failure:
    bl abort
.size SPCIMPFINIT_ENTRY,.-SPCIMPFINIT_ENTRY
.section .note.GNU-stack,"",%progbits

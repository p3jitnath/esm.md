/* Direct surface band and canopy flux calculations in W m^-2.
 * Physics formulations/openifs/physics/surface_spectral_flux.md.
 * Contract skills/md2asm/references/openifs/physics/calc_surface_spectral.md.
 * x0 flux class wrapper, x1 config object, x2/x3 INTEGER4 column bounds.
 * The complete direct indexed-sum child supplies ordered band additions.
 * Private helpers perform bit copies and complete ordered weighted sums. */
#ifndef SURFACE_SYMBOL
#define SURFACE_SYMBOL __radiation_flux_MOD_calc_surface_spectral
#endif
.text
.p2align 4
/* Prepare a rank-one array section from a rank-two field. */
.macro SECTION member,slot
    add x0,x19,#\member
    mov x1,x23
    add x2,x29,#\slot
    bl .Lsurface_column_descriptor
.endm
.macro SUM_FIELD source,destination,map
    SECTION \source,128
    SECTION \destination,192
    add x0,x29,#128
    mov x9,#\map
    add x1,x20,x9
    add x2,x29,#192
    bl md2asm_openifs_indexed_sum
.endm
.macro SUM_GATHERED source,destination
    SECTION \source,128
    SECTION \destination,192
    add x0,x29,#128
    add x1,x29,#256
    add x2,x29,#192
    bl md2asm_openifs_indexed_sum
.endm
.macro COPY_FIELD source,destination
    SECTION \source,128
    SECTION \destination,192
    add x0,x29,#128
    add x1,x29,#192
    bl .Lsurface_copy
.endm
.macro COMBINE_FIELD total,direct,subtract
    SECTION \total,128
    SECTION \direct,192
    add x0,x29,#128
    add x1,x29,#192
    mov w2,#\subtract
    bl .Lsurface_combine
.endm
.macro WEIGHT_FIELD source,destination,weights
    SECTION \source,128
    SECTION \destination,192
    mov x9,#\weights
    add x0,x20,x9
    add x1,x29,#128
    add x2,x29,#192
    bl .Lsurface_weighted
.endm
.global SURFACE_SYMBOL
.type SURFACE_SYMBOL,%function
SURFACE_SYMBOL:
    stp x29,x30,[sp,#-352]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    ldr x19,[x0]
    mov x20,x1
    ldrsw x21,[x2]
    ldrsw x22,[x3]
    cmp x21,x22
    b.gt .Lsurface_return
    mov x24,#0
    mov x25,#0
    mov x9,#6852
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_lw_scratch
    mov x9,#7976
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_lw_scratch
    mov x9,#7984
    ldr w9,[x20,x9]
    cbnz w9,.Lsurface_lw_scratch
    mov x9,#708
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_lw_scratch
    mov x9,#10928
    add x9,x20,x9
    ldp x10,x11,[x9,#48]
    sub x25,x11,x10
    add x25,x25,#1
.Lsurface_lw_scratch:
    mov x9,#6848
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_allocate_scratch
    mov x9,#7980
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_allocate_scratch
    mov x9,#7988
    ldr w9,[x20,x9]
    cbnz w9,.Lsurface_allocate_scratch
    mov x9,#712
    ldr w9,[x20,x9]
    cbnz w9,.Lsurface_lw_map_size
    mov x9,#20008
    ldrsw x24,[x20,x9]
    lsl x24,x24,#3
    add x24,x24,#15
    and x24,x24,#-16
    b .Lsurface_allocate_scratch
.Lsurface_lw_map_size:
    mov x9,#10864
    add x9,x20,x9
    ldp x10,x11,[x9,#48]
    sub x10,x11,x10
    add x10,x10,#1
    cmp x10,x25
    csel x25,x10,x25,gt
.Lsurface_allocate_scratch:
    lsl x10,x25,#2
    add x10,x10,#15
    and x10,x10,#-16
    add x10,x10,x24
    sub sp,sp,x10
    mov x9,sp
    str x9,[x29,#96]
    add x9,x9,x24
    str x9,[x29,#104]
    mov x9,#6852
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_longwave
    mov x9,#7948
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_sw_canopy
    mov x23,x21
.Lsurface_sw_bands:
    SUM_FIELD 2264,2616,10928
    SUM_FIELD 2176,2528,10928
    COMBINE_FIELD 2528,2616,0
    add x23,x23,#1
    cmp x23,x22
    b.le .Lsurface_sw_bands
    mov x9,#6856
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_sw_canopy
    mov x23,x21
.Lsurface_sw_clear:
    SUM_FIELD 2440,2792,10928
    SUM_FIELD 2352,2704,10928
    COMBINE_FIELD 2704,2792,0
    add x23,x23,#1
    cmp x23,x22
    b.le .Lsurface_sw_clear
.Lsurface_sw_canopy:
    mov x9,#7976
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_longwave
    mov x9,#7984
    ldr w9,[x20,x9]
    cbnz w9,.Lsurface_sw_full_start
    mov x9,#708
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_sw_weight_start
    mov x9,#10928
    add x0,x20,x9
    mov x9,#10304
    add x1,x20,x9
    ldr x2,[x29,#104]
    add x3,x29,#256
    bl .Lsurface_gather_map
    mov x23,x21
.Lsurface_sw_nearest:
    SUM_GATHERED 2264,3056
    SUM_GATHERED 2176,2968
    add x23,x23,#1
    cmp x23,x22
    b.le .Lsurface_sw_nearest
    b .Lsurface_longwave
.Lsurface_sw_full_start:
    mov x23,x21
.Lsurface_sw_full:
    COPY_FIELD 2176,2968
    COPY_FIELD 2264,3056
    add x23,x23,#1
    cmp x23,x22
    b.le .Lsurface_sw_full
    b .Lsurface_longwave
.Lsurface_sw_weight_start:
    mov x23,x21
.Lsurface_sw_weight:
    WEIGHT_FIELD 2528,2968,10432
    WEIGHT_FIELD 2616,3056,10432
    COMBINE_FIELD 2968,3056,1
    add x23,x23,#1
    cmp x23,x22
    b.le .Lsurface_sw_weight
.Lsurface_longwave:
    mov x9,#6848
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_return
    mov x9,#7980
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_return
    mov x9,#7988
    ldr w9,[x20,x9]
    cbnz w9,.Lsurface_lw_full_start
    mov x9,#712
    ldr w9,[x20,x9]
    cbz w9,.Lsurface_lw_weight_start
    mov x9,#10864
    add x0,x20,x9
    mov x9,#10368
    add x1,x20,x9
    ldr x2,[x29,#104]
    add x3,x29,#256
    bl .Lsurface_gather_map
    mov x23,x21
.Lsurface_lw_nearest:
    SUM_GATHERED 2000,2880
    add x23,x23,#1
    cmp x23,x22
    b.le .Lsurface_lw_nearest
    b .Lsurface_return
.Lsurface_lw_full_start:
    mov x23,x21
.Lsurface_lw_full:
    COPY_FIELD 2000,2880
    add x23,x23,#1
    cmp x23,x22
    b.le .Lsurface_lw_full
    b .Lsurface_return
.Lsurface_lw_weight_start:
    mov x23,x21
.Lsurface_lw_weight:
    SECTION 2000,128
    ldr x0,[x29,#96]
    mov x9,#20008
    ldrsw x1,[x20,x9]
    add x2,x29,#192
    bl .Lsurface_contiguous_descriptor
    add x0,x29,#128
    mov x9,#10864
    add x1,x20,x9
    add x2,x29,#192
    bl md2asm_openifs_indexed_sum
    SECTION 2880,256
    mov x9,#10520
    add x0,x20,x9
    add x1,x29,#192
    add x2,x29,#256
    bl .Lsurface_weighted
    add x23,x23,#1
    cmp x23,x22
    b.le .Lsurface_lw_weight
.Lsurface_return:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#352
    ret
.size SURFACE_SYMBOL,.-SURFACE_SYMBOL

/* x0 rank-two owner, x1 column, x2 rank-one descriptor. */
.Lsurface_column_descriptor:
    ldp x3,x4,[x0]
    ldr x5,[x0,#40]
    ldp x6,x7,[x0,#48]
    ldr x8,[x0,#64]
    madd x4,x1,x8,x4
    madd x4,x6,x5,x4
    add x3,x3,x4,lsl #3
    sub x7,x7,x6
    add x7,x7,#1
    stp x3,xzr,[x2]
    mov x3,#8
    str x3,[x2,#16]
    str x3,[x2,#32]
    mov x3,#0x301
    lsl x3,x3,#32
    str x3,[x2,#24]
    str x5,[x2,#40]
    mov x3,#1
    stp x3,x7,[x2,#48]
    ret

/* x0 base, x1 count, x2 rank-one FP64 descriptor. */
.Lsurface_contiguous_descriptor:
    stp x0,xzr,[x2]
    mov x3,#8
    str x3,[x2,#16]
    str x3,[x2,#32]
    mov x3,#0x301
    lsl x3,x3,#32
    str x3,[x2,#24]
    mov x3,#1
    stp x3,x3,[x2,#40]
    str x1,[x2,#56]
    ret

/* x0 source and x1 destination rank-one descriptors. Copy every bit. */
.Lsurface_copy:
    ldr x3,[x0]
    ldr x4,[x1]
    ldr x5,[x0,#40]
    ldr x6,[x1,#40]
    ldp x7,x8,[x0,#48]
    sub x8,x8,x7
    add x8,x8,#1
    cmp x8,#0
    b.le .Lsurface_copy_return
.Lsurface_copy_cell:
    ldr x9,[x3]
    str x9,[x4]
    add x3,x3,x5,lsl #3
    add x4,x4,x6,lsl #3
    subs x8,x8,#1
    b.ne .Lsurface_copy_cell
.Lsurface_copy_return:
    ret

/* x0 total descriptor, x1 direct descriptor, w2 selects subtraction. */
.Lsurface_combine:
    ldr x3,[x0]
    ldr x4,[x1]
    ldr x5,[x0,#40]
    ldr x6,[x1,#40]
    ldp x7,x8,[x0,#48]
    sub x8,x8,x7
    add x8,x8,#1
    cmp x8,#0
    b.le .Lsurface_combine_return
.Lsurface_combine_cell:
    ldr d0,[x3]
    ldr d1,[x4]
    cbnz w2,.Lsurface_subtract
    fadd d0,d0,d1
    b .Lsurface_combined
.Lsurface_subtract:
    fsub d0,d0,d1
.Lsurface_combined:
    str d0,[x3]
    add x3,x3,x5,lsl #3
    add x4,x4,x6,lsl #3
    subs x8,x8,#1
    b.ne .Lsurface_combine_cell
.Lsurface_combine_return:
    ret

/* x0 sample-to-band map, x1 band-to-canopy map, x2 raw scratch, x3 descriptor. */
.Lsurface_gather_map:
    ldr x4,[x0]
    ldr x5,[x1]
    ldr x6,[x0,#40]
    ldr x7,[x1,#40]
    ldp x8,x9,[x0,#48]
    sub x9,x9,x8
    add x9,x9,#1
    stp x2,xzr,[x3]
    mov x8,#4
    str x8,[x3,#16]
    str x8,[x3,#32]
    mov x8,#0x101
    lsl x8,x8,#32
    str x8,[x3,#24]
    mov x8,#1
    stp x8,x8,[x3,#40]
    str x9,[x3,#56]
    cmp x9,#0
    b.le .Lsurface_gather_return
.Lsurface_gather_cell:
    ldrsw x10,[x4]
    sub x10,x10,#1
    mul x10,x10,x7
    ldr w11,[x5,x10,lsl #2]
    str w11,[x2],#4
    add x4,x4,x6,lsl #2
    subs x9,x9,#1
    b.ne .Lsurface_gather_cell
.Lsurface_gather_return:
    ret

/* x0 weight owner, x1 source column, x2 output column. */
.Lsurface_weighted:
    ldp x3,x4,[x0]
    ldr x5,[x0,#40]
    ldr x6,[x0,#64]
    ldr x7,[x1]
    ldr x8,[x1,#40]
    ldr x9,[x2]
    ldr x10,[x2,#40]
    ldp x11,x12,[x2,#48]
    sub x12,x12,x11
    add x12,x12,#1
    ldp x13,x14,[x1,#48]
    sub x14,x14,x13
    add x14,x14,#1
    cmp x12,#0
    b.le .Lsurface_weight_return
    mov x11,x9
    mov x13,x12
.Lsurface_weight_clear:
    str xzr,[x11]
    add x11,x11,x10,lsl #3
    subs x13,x13,#1
    b.ne .Lsurface_weight_clear
    cmp x14,#0
    b.le .Lsurface_weight_return
    add x4,x4,x5
    add x4,x4,x6
    add x3,x3,x4,lsl #3
    mov x15,#0
.Lsurface_weight_band:
    ldr d1,[x7]
    mov x11,x9
    mov x13,x3
    mov x16,x12
.Lsurface_weight_row:
    ldr d0,[x13]
    fcmp d0,#0.0
    b.eq .Lsurface_weight_skip
    fmul d0,d0,d1
    ldr d2,[x11]
    fadd d0,d2,d0
    str d0,[x11]
.Lsurface_weight_skip:
    add x11,x11,x10,lsl #3
    add x13,x13,x5,lsl #3
    subs x16,x16,#1
    b.ne .Lsurface_weight_row
    add x7,x7,x8,lsl #3
    add x3,x3,x6,lsl #3
    add x15,x15,#1
    cmp x15,x14
    b.lt .Lsurface_weight_band
.Lsurface_weight_return:
    ret
.section .note.GNU-stack,"",%progbits

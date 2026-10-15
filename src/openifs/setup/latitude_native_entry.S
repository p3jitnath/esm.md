// Original SULEGA ABI: x0 owns TCSGLEG640, x1 reads TDIM352.
// Contract: skills/md2asm/references/openifs/setup/native_latitude_geometry.md and skills/md2asm/references/openifs/setup/latitude_geometry_setup.md.
// Selected dimension words are32,2,-1,34. Initialized RA and RPI scalar
// addresses are explicit compatibility inputs; full autonomy owns their values.
// No original transform handle, callable, type descriptor or vtable is used.
// All nine numerical owners transfer to TCSGLEG. Failure stops continuation;
// child failure frees prior owners and clears pointers, retaining partial bounds.
// Frame32, alignment16; preserve x18 and required AAPCS64 saved registers.
.text
.p2align 4
.global sulega_
.type sulega_,%function
sulega_:
    mrs x9, fpcr
    cbnz x9, .Llatitude_native_failed
    cbz x1, .Llatitude_native_failed
    tst x1, #7
    b.ne .Llatitude_native_failed
    adds x9, x1, #352
    b.cs .Llatitude_native_failed
    ldr w9, [x1]
    cmp w9, #32
    b.ne .Llatitude_native_failed
    ldr w9, [x1, #12]
    cmp w9, #2
    b.ne .Llatitude_native_failed
    ldr w9, [x1, #16]
    cmn w9, #1
    b.ne .Llatitude_native_failed
    ldr w9, [x1, #32]
    cmp w9, #34
    b.ne .Llatitude_native_failed
    adrp x2, :got:__yomcst_MOD_ra
    ldr x2, [x2, :got_lo12:__yomcst_MOD_ra]
    ldr x3, [x2]
    adrp x9, .Llatitude_native_radius
    ldr x9, [x9, :lo12:.Llatitude_native_radius]
    cmp x3, x9
    b.ne .Llatitude_native_failed
    fmov d0, x3
    adrp x2, :got:__yomcst_MOD_rpi
    ldr x2, [x2, :got_lo12:__yomcst_MOD_rpi]
    ldr x3, [x2]
    adrp x9, .Llatitude_native_pi
    ldr x9, [x9, :lo12:.Llatitude_native_pi]
    cmp x3, x9
    b.ne .Llatitude_native_failed
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x18, [sp, #16]
    bl md2asm_initialize_latitude_geometry
    cbnz w0, .Llatitude_native_failed
    adrp x2, .Llatitude_native_calls
    ldr x3, [x2, :lo12:.Llatitude_native_calls]
    add x3, x3, #1
    str x3, [x2, :lo12:.Llatitude_native_calls]
    ldr x18, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
.Llatitude_native_failed:
    b abort
.size sulega_,.-sulega_
.global md2asm_latitude_native_count_get
.type md2asm_latitude_native_count_get,%function
md2asm_latitude_native_count_get:
    adrp x0, .Llatitude_native_calls
    ldr x0, [x0, :lo12:.Llatitude_native_calls]
    ret
.size md2asm_latitude_native_count_get,.-md2asm_latitude_native_count_get
.section .rodata
.balign 8
.Llatitude_native_radius:
    .double 6371229.0
.Llatitude_native_pi:
    .quad 0x400921fb54442d18
.bss
.balign 8
.Llatitude_native_calls:
    .zero 8
.section .note.GNU-stack,"",%progbits

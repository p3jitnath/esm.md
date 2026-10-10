/* Gas-unit transformations from physics P01/P02 and the frozen contract.
 * Physics is formulations/openifs/physics/gas_concentration_units.md.
 * Contract is skills/md2asm/references/openifs/physics/gas_unit_conversion.md.
 * GNU base gas class uses data at byte 0 and an unchanged vtable at byte 8.
 * The 416-byte object owns contiguous FP64 (ncol,nlev,12) concentrations.
 * Read outputs use signed rank-two strides. Optional pointers may be null.
 * Positive finite scales and valid gas, shape and unit metadata are required.
 * Caller-saved registers only, no external calls and no stack allocation. */
#ifndef GET_SYMBOL
#define GET_SYMBOL __radiation_gas_MOD_get_gas
#endif
#ifndef SET_SYMBOL
#define SET_SYMBOL __radiation_gas_MOD_set_units_gas
#endif
.text
.p2align 2
/* x7..x9, w6 and d1/d2 are temporary. d0 is the rounded conversion factor. */
.macro gas_factor object,gas,unit
    ldr w6,[\object,\gas,lsl #2]
    cmp \unit,#0
    b.ne .Lgas_to_volume_\@
    cmp w6,#1
    b.ne .Lgas_stored_scale_\@
    adrp x8,:got:__radiation_gas_MOD_igasmolarmass
    ldr x8,[x8,:got_lo12:__radiation_gas_MOD_igasmolarmass]
    add x9,\gas,#1
    ldr d1,[x8,x9,lsl #3]
    adrp x8,.Lgas_air_mass
    ldr d2,[x8,:lo12:.Lgas_air_mass]
    fmul d0,d0,d1
    fdiv d0,d0,d2
    b .Lgas_stored_scale_\@
.Lgas_to_volume_\@:
    cmp \unit,#1
    b.ne .Lgas_stored_scale_\@
    cbnz w6,.Lgas_stored_scale_\@
    adrp x8,:got:__radiation_gas_MOD_igasmolarmass
    ldr x8,[x8,:got_lo12:__radiation_gas_MOD_igasmolarmass]
    add x9,\gas,#1
    ldr d2,[x8,x9,lsl #3]
    adrp x8,.Lgas_air_mass
    ldr d1,[x8,:lo12:.Lgas_air_mass]
    fmul d0,d0,d1
    fdiv d0,d0,d2
.Lgas_stored_scale_\@:
    add x7,\object,#48
    ldr d1,[x7,\gas,lsl #3]
    fmul d0,d0,d1
.endm
.global GET_SYMBOL
.type GET_SYMBOL,%function
GET_SYMBOL:
    ldr x0,[x0]
    ldrsw x1,[x1]
    sub x1,x1,#1
    ldr w2,[x2]
    fmov d0,#1.0
    cbz x4,.Lgas_read_scale_ready
    ldr d0,[x4]
.Lgas_read_scale_ready:
    add x6,x0,#256
    ldr w6,[x6,x1,lsl #2]
    cbz w6,.Lgas_read_absent
    gas_factor x0,x1,w2
    ldr x16,[x0,#144]
    ldrsw x17,[x0,#356]
    ldrsw x7,[x0,#360]
    mul x7,x7,x17
    mul x7,x7,x1
    mov x15,#0
    cbz x5,.Lgas_read_start_ready
    ldrsw x15,[x5]
    sub x15,x15,#1
.Lgas_read_start_ready:
    add x7,x7,x15
    add x16,x16,x7,lsl #3
    lsl x17,x17,#3
    fmov d1,#1.0
    fcmp d0,d1
    mov w0,#1
    mov w6,#2
    csel w0,w0,w6,eq
    b .Lgas_read_output
.Lgas_read_absent:
    mov w0,#0
    mov x16,#0
    mov x17,#0
.Lgas_read_output:
    ldr x10,[x3]
    ldr x11,[x3,#40]
    mov x6,#1
    cmp x11,#0
    csel x11,x11,x6,ne
    ldr x12,[x3,#64]
    lsl x11,x11,#3
    lsl x12,x12,#3
    ldp x6,x13,[x3,#48]
    sub x13,x13,x6
    add x13,x13,#1
    ldp x6,x14,[x3,#72]
    sub x14,x14,x6
    add x14,x14,#1
    cmp x13,#0
    b.le .Lgas_read_done
    cmp x14,#0
    b.le .Lgas_read_done
.Lgas_read_level:
    mov x6,x10
    mov x7,x16
    mov x8,x13
.Lgas_read_cell:
    cbz w0,.Lgas_read_zero
    ldr x9,[x7],#8
    cmp w0,#1
    b.eq .Lgas_read_copy
    fmov d1,x9
    fmul d1,d1,d0
    str d1,[x6]
    b .Lgas_read_cell_done
.Lgas_read_copy:
    str x9,[x6]
    b .Lgas_read_cell_done
.Lgas_read_zero:
    str xzr,[x6]
.Lgas_read_cell_done:
    add x6,x6,x11
    subs x8,x8,#1
    b.ne .Lgas_read_cell
    add x10,x10,x12
    add x16,x16,x17
    subs x14,x14,#1
    b.ne .Lgas_read_level
.Lgas_read_done:
    ret
.size GET_SYMBOL,.-GET_SYMBOL
.p2align 2
.global SET_SYMBOL
.type SET_SYMBOL,%function
SET_SYMBOL:
    ldr x0,[x0]
    ldr w1,[x1]
    fmov d3,#1.0
    fmov d4,#1.0
    cbz x3,.Lgas_set_scale_ready
    ldr d3,[x3]
    fdiv d4,d4,d3
.Lgas_set_scale_ready:
    cbz x2,.Lgas_set_all
    ldrsw x2,[x2]
    sub x2,x2,#1
    mov x12,#1
    mov x11,#0
    b .Lgas_set_one
.Lgas_set_all:
    ldrsw x12,[x0,#352]
    cmp x12,#0
    b.le .Lgas_set_done
    add x11,x0,#364
.Lgas_set_next_code:
    ldrsw x2,[x11],#4
    sub x2,x2,#1
.Lgas_set_one:
    add x6,x0,#256
    ldr w6,[x6,x2,lsl #2]
    cbz w6,.Lgas_set_next
    fmov d0,d4
    gas_factor x0,x2,w1
    fmov d1,#1.0
    fcmp d0,d1
    b.eq .Lgas_set_metadata
    ldrsw x7,[x0,#356]
    ldrsw x8,[x0,#360]
    mul x10,x7,x8
    cbz x10,.Lgas_set_metadata
    ldr x9,[x0,#144]
    mul x8,x2,x10
    add x9,x9,x8,lsl #3
.Lgas_set_cell:
    ldr d1,[x9]
    fmul d1,d1,d0
    str d1,[x9],#8
    subs x10,x10,#1
    b.ne .Lgas_set_cell
.Lgas_set_metadata:
    str w1,[x0,x2,lsl #2]
    add x7,x0,#48
    str d3,[x7,x2,lsl #3]
.Lgas_set_next:
    subs x12,x12,#1
    b.eq .Lgas_set_done
    b .Lgas_set_next_code
.Lgas_set_done:
    ret
.size SET_SYMBOL,.-SET_SYMBOL
.section .rodata
.p2align 3
.Lgas_air_mass:
    .quad 0x403cf851e0000000
.section .note.GNU-stack,"",%progbits

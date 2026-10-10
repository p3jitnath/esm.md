// Complete greenhouse-gas mapping from formulations/openifs/physics/greenhouse_gas_profiles.md.
// Contract skills/md2asm/references/openifs/physics/radghg.md.
// x0..x7 hold eight pointers. Latitude and nine gas owners follow on the stack.
// Latitude uses its sine, pressure is Pa, gas output is kg kg^-1.
// Native interpolation supplies every pressure stage. No control supplies physics.
// A 256-byte frame and bounded latitude scratch preserve x19..x30 and FPCR.
// x18 and preserved FP registers remain untouched.
.text
.p2align 4
.global md2asm_openifs_radghg
.type md2asm_openifs_radghg,%function
.hidden md2asm_openifs_interp_gas
md2asm_openifs_radghg:
    mov x17,sp
    stp x29,x30,[sp,#-256]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    mov x20,x2
    mov x21,x3
    mov x22,x4
    mov x23,x5
    mov x24,x7
    ldr w27,[x0,#156]
    ldrsw x8,[x4]
    ldrsw x9,[x5]
    cmp x9,#0
    b.le .Lghg_restore
    ldrsw x0,[x2]
    ldrsw x1,[x3]
    cmp x0,x1
    b.gt .Lghg_restore
    sub x0,x0,#1
    sub x1,x1,#1
    ldr x9,[x17]
    str x9,[x29,#96]
    ldp x9,x10,[x17,#8]
    stp x9,x10,[x29,#128]
    ldp x9,x10,[x17,#24]
    stp x9,x10,[x29,#144]
    ldp x9,x10,[x17,#40]
    stp x9,x10,[x29,#160]
    ldp x9,x10,[x17,#56]
    stp x9,x10,[x29,#176]
    ldr x9,[x17,#72]
    str x9,[x29,#192]
    adrp x9,:got:__yoeradghg_MOD_yradghg
    ldr x9,[x9,:got_lo12:__yoeradghg_MOD_yradghg]
    ldr x19,[x9]
    lsl x9,x8,#2
    add x9,x9,#15
    and x9,x9,#-16
    lsl x10,x8,#3
    add x10,x10,#15
    and x10,x10,#-16
    add x10,x10,x9
    add x10,x10,#32
    sub sp,sp,x10
    add x25,sp,#32
    add x26,x25,x9
    ldr x5,[x19]
    ldrsw x8,[x19,#920]
    sub x8,x8,#1
    ldr x10,[x29,#96]
.Lghg_latitude:
    ldr d0,[x10,x0,lsl #3]
    ldr d1,[x5]
    ldr d2,[x5,x8,lsl #3]
    fcmp d0,d2
    b.gt .Lghg_north
    fcmp d0,d1
    b.lt .Lghg_south
    sub x6,x8,#1
.Lghg_latitude_search:
    ldr d1,[x5,x6,lsl #3]
    add x7,x6,#1
    ldr d2,[x5,x7,lsl #3]
    fcmp d0,d2
    b.gt .Lghg_previous_pair
    fcmp d0,d1
    b.ge .Lghg_pair_found
.Lghg_previous_pair:
    sub x6,x6,#1
    b .Lghg_latitude_search
.Lghg_pair_found:
    add x6,x6,#1
    fsub d3,d0,d1
    fsub d4,d2,d1
    fdiv d3,d3,d4
    b .Lghg_store_latitude
.Lghg_north:
    mov x6,x8
    fmov d3,#1.0
    b .Lghg_store_latitude
.Lghg_south:
    mov x6,#1
    fmov d3,xzr
.Lghg_store_latitude:
    str w6,[x25,x0,lsl #2]
    str d3,[x26,x0,lsl #3]
    add x0,x0,#1
    cmp x0,x1
    b.le .Lghg_latitude
    adrp x28,.Lghg_species
    add x28,x28,:lo12:.Lghg_species
.Lghg_species_loop:
    ldp w8,w9,[x28]
    cmp w27,w8
    b.eq .Lghg_call_child
    cmp w27,w9
    b.ge .Lghg_call_child
    cmp w8,#7
    b.ne .Lghg_next_species
    cmp w27,#17
    b.ne .Lghg_next_species
.Lghg_call_child:
    ldp w8,w9,[x28,#8]
    add x8,x19,x8
    add x9,x29,x9
    ldr x9,[x9]
    stp x8,x24,[sp]
    str x9,[sp,#16]
    mov x0,x20
    mov x1,x21
    mov x2,x22
    mov x3,x25
    mov x4,x26
    add x5,x19,#924
    mov x6,x23
    add x7,x19,#64
    bl md2asm_openifs_interp_gas
.Lghg_next_species:
    add x28,x28,#16
    adrp x8,.Lghg_species_end
    add x8,x8,:lo12:.Lghg_species_end
    cmp x28,x8
    b.lo .Lghg_species_loop
.Lghg_restore:
    mov sp,x29
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#256
    ret
.size md2asm_openifs_radghg,.-md2asm_openifs_radghg
.section .rodata
.balign 16
.Lghg_species:
// Single-species code, multiple-species threshold, amount offset, saved output.
.word 1,10,216,128
.word 2,11,128,136
.word 3,12,304,144
.word 4,20,392,152
.word 5,15,480,160
.word 6,16,568,168
.word 7,21,832,176
.word 8,18,744,184
.word 9,19,656,192
.Lghg_species_end:
.section .note.GNU-stack,"",%progbits

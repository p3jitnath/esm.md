// Physics formulations/openifs/physics/nonorographic_gravity_wave_drag.md.
// Contract skills/md2asm/references/openifs/physics/gwdragwms_layer.md.
// Complete launch accumulation, with the accepted full direct wave child.
#ifndef GW_LAYER_SYMBOL
#define GW_LAYER_SYMBOL gwdragwms_layer_
#endif
#ifndef GW_LAYER_CHILD
#define GW_LAYER_CHILD md2asm_gwdrag_wms
#endif
.text
.p2align 4
.equ FR,768
.equ LA0,208
.equ LA1,216
.equ LA2,224
.equ LA3,232
.equ LA4,240
.equ LA5,248
.equ LA6,256
.equ LA7,264
.equ LA8,272
.equ LT,320
.equ LU,328
.equ LV,336
.equ LPFULL,344
.equ LPHALF,352
.equ LGEO,360
.equ LLAT,368
.equ LAREA,376
.equ LRAIN0,384
.equ LRAIN1,392
.equ LRAIN2,400
.equ LRAIN3,408
.equ LNU,416
.equ LNV,424
.equ LSU,432
.equ LSV,440
.equ LRAINT,472
.equ LDU,480
.equ LDV,488
.equ LFU,496
.equ LFV,504
.equ LWHO,600
.macro ORIGIN out,base,off
    add x9,\base,#\off
    ldr x10,[x9]
    ldr x11,[x9,#8]
    ldr x12,[x9,#40]
    ldr x13,[x9,#48]
    madd x11,x12,x13,x11
    ldr x12,[x9,#64]
    ldr x13,[x9,#72]
    madd x11,x12,x13,x11
    add x10,x10,x11,lsl #3
    str x10,[sp,#\out]
.endm
.macro VECTOR out,base,off
    add x9,\base,#\off
    ldr x10,[x9]
    ldr x11,[x9,#8]
    ldr x12,[x9,#40]
    ldr x13,[x9,#48]
    madd x11,x12,x13,x11
    add x10,x10,x11,lsl #3
    str x10,[sp,#\out]
.endm
.macro BOTTOM out,base,off
    add x9,\base,#\off
    ldr x10,[x9]
    ldr x11,[x9,#8]
    ldr x12,[x9,#40]
    add x11,x11,x12
    ldr x12,[x9,#64]
    madd x11,x12,x21,x11
    add x10,x10,x11,lsl #3
    str x10,[sp,#\out]
.endm
.macro LOAD r,slot
    ldr x9,[sp,#\slot]
    madd x10,x28,x20,x27
    ldr d\r,[x9,x10,lsl #3]
.endm
.macro SAVE r,slot
    ldr x9,[sp,#\slot]
    madd x10,x28,x20,x27
    str d\r,[x9,x10,lsl #3]
.endm
.global GW_LAYER_SYMBOL
.type GW_LAYER_SYMBOL,%function
GW_LAYER_SYMBOL:
    sub sp,sp,#FR
    stp x19,x20,[sp,#112]
    stp x21,x22,[sp,#128]
    stp x23,x24,[sp,#144]
    stp x25,x26,[sp,#160]
    stp x27,x28,[sp,#176]
    stp x29,x30,[sp,#192]
    stp x0,x1,[sp,#LA0]
    stp x2,x3,[sp,#LA2]
    stp x4,x5,[sp,#LA4]
    stp x6,x7,[sp,#LA6]
    ldr x9,[sp,#FR]
    str x9,[sp,#LA8]
    mrs x9,fpcr
    cbnz x9,.Llayer_domain
    mov x24,x2
    ldr w20,[x4,#12]
    ldr w21,[x4,#48]
    ldr w22,[x4]
    ldr w23,[x4,#4]
    ldr w25,[x24,#28]
    cmp w20,#1
    b.lt .Llayer_domain
    cmp w20,#2048
    b.gt .Llayer_domain
    cmp w21,#2
    b.lt .Llayer_domain
    cmp w21,#512
    b.gt .Llayer_domain
    cmp w22,#1
    b.lt .Llayer_domain
    cmp w23,w20
    b.gt .Llayer_domain
    cmp w25,#0
    b.lt .Llayer_domain
    cmp w25,#3
    b.gt .Llayer_domain
    sub w22,w22,#1
    sub w23,w23,#1
    ORIGIN LT,x5,208
    ORIGIN LU,x5,32
    ORIGIN LV,x5,120
    ORIGIN LPFULL,x6,448
    ORIGIN LPHALF,x6,360
    ORIGIN LGEO,x6,96
    VECTOR LLAT,x6,1040
    VECTOR LAREA,x6,1104
    BOTTOM LRAIN0,x7,1144
    BOTTOM LRAIN1,x7,1232
    BOTTOM LRAIN2,x7,1320
    BOTTOM LRAIN3,x7,1408
    ORIGIN LSU,x7,2200
    ORIGIN LSV,x7,2288
    // NOGW is a GNU derived-type vector. Each VARIABLE_3D has 728 bytes.
    ldr x9,[sp,#LA8]
    ldr x10,[x9]
    // The assumed-shape dummy remaps its first actual element to NOGW(1).
    mov x13,x10
    mov x14,#728
    add x15,x13,#64
    ldr x9,[x15]
    ldr x11,[x15,#8]
    ldr x12,[x15,#40]
    add x11,x11,x12
    ldr x12,[x15,#64]
    add x11,x11,x12
    add x9,x9,x11,lsl #3
    str x9,[sp,#LNU]
    add x13,x13,x14
    add x15,x13,#64
    ldr x9,[x15]
    ldr x11,[x15,#8]
    ldr x12,[x15,#40]
    add x11,x11,x12
    ldr x12,[x15,#64]
    add x11,x11,x12
    add x9,x9,x11,lsl #3
    str x9,[sp,#LNV]
    cbz x25,.Llayer_guard_done
    ldr w9,[x24,#36]
    cmp w9,#-1
    b.lt .Llayer_domain
    cmp w9,#2
    b.gt .Llayer_domain
    ldr d0,[x24,#112]
    fmov d1,#2.0
    fcmp d0,d1
    b.eq .Llayer_power_ok
    fmov d1,#3.0
    fcmp d0,d1
    b.ne .Llayer_domain
.Llayer_power_ok:
    mov x26,#0
.Llayer_launch_guard:
    add x9,x24,#16
    ldr w9,[x9,x26,lsl #2]
    cmp w9,#2
    b.lt .Llayer_domain
    cmp w9,w21
    b.gt .Llayer_domain
    add x26,x26,#1
    cmp x26,x25
    b.lt .Llayer_launch_guard
    adrp x9,:got:__yomcst_MOD_rpi
    ldr x9,[x9,:got_lo12:__yomcst_MOD_rpi]
    ldr d2,[x9]
    fmov x9,d2
    ldr x10,.Llayer_pi
    cmp x9,x10
    b.ne .Llayer_domain
    adrp x9,:got:__yomcst_MOD_ra
    ldr x9,[x9,:got_lo12:__yomcst_MOD_ra]
    ldr d3,[x9]
    fmov d0,#2.0
    fmul d3,d0,d3
    mov x27,x22
    cmp x27,x23
    b.gt .Llayer_guard_done
.Llayer_grid:
    ldr x9,[sp,#LAREA]
    ldr d0,[x9,x27,lsl #3]
    fcmp d0,#0.0
    b.le .Llayer_domain
    b.vs .Llayer_domain
    fmul d0,d2,d0
    fsqrt d0,d0
    fmul d0,d3,d0
    ldr d1,.Llayer_hundred
    fmaxnm d0,d0,d1
    ldr d1,.Llayer_grid_min
    fcmp d0,d1
    b.lt .Llayer_domain
    b.vs .Llayer_domain
    add x27,x27,#1
    cmp x27,x23
    b.le .Llayer_grid
.Llayer_guard_done:
    mul x9,x20,x21
    lsl x0,x9,#2
    mov x10,#3
    madd x0,x20,x10,x0
    mov x1,#8
    bl calloc
    cbz x0,.Llayer_domain
    mov x19,x0
    mov x9,x0
    str x9,[sp,#LRAINT]
    add x9,x9,x20,lsl #3
    mul x10,x20,x21
    str x9,[sp,#LDU]
    add x9,x9,x10,lsl #3
    str x9,[sp,#LDV]
    add x9,x9,x10,lsl #3
    add x10,x10,x20
    str x9,[sp,#LFU]
    add x9,x9,x10,lsl #3
    str x9,[sp,#LFV]
    mov x27,x22
    cmp x27,x23
    b.gt .Llayer_clear
.Llayer_precip:
    ldr x9,[sp,#LRAIN0]
    ldr d0,[x9,x27,lsl #3]
    ldr x9,[sp,#LRAIN1]
    ldr d1,[x9,x27,lsl #3]
    fadd d0,d0,d1
    ldr x9,[sp,#LRAIN2]
    ldr d1,[x9,x27,lsl #3]
    fadd d0,d0,d1
    ldr x9,[sp,#LRAIN3]
    ldr d1,[x9,x27,lsl #3]
    fadd d0,d0,d1
    fmov d1,xzr
    fmaxnm d0,d1,d0
    ldr x9,[sp,#LRAINT]
    str d0,[x9,x27,lsl #3]
    add x27,x27,#1
    cmp x27,x23
    b.le .Llayer_precip
.Llayer_clear:
    mov x28,#0
    fmov d0,xzr
.Llayer_clear_level:
    mov x27,x22
    cmp x27,x23
    b.gt .Llayer_clear_next
.Llayer_clear_col:
    SAVE 0,LNU
    SAVE 0,LNV
    add x27,x27,#1
    cmp x27,x23
    b.le .Llayer_clear_col
.Llayer_clear_next:
    add x28,x28,#1
    cmp x28,x21
    b.lt .Llayer_clear_level
    cbz x25,.Llayer_finish
    mov x26,#1
.Llayer_launch:
    str w26,[sp,#LWHO]
    ldr x0,[sp,#LA0]
    ldr x1,[sp,#LA1]
    ldr x2,[sp,#LA2]
    ldr x9,[sp,#LA4]
    mov x3,x9
    add x4,x9,#4
    add x5,x9,#12
    add x6,x9,#48
    add x7,sp,#LWHO
    add x9,x24,#120
    str x9,[sp]
    ldr x9,[sp,#LT]
    str x9,[sp,#8]
    ldr x9,[sp,#LU]
    str x9,[sp,#16]
    ldr x9,[sp,#LV]
    str x9,[sp,#24]
    ldr x9,[sp,#LPFULL]
    str x9,[sp,#32]
    ldr x9,[sp,#LPHALF]
    str x9,[sp,#40]
    ldr x9,[sp,#LGEO]
    str x9,[sp,#48]
    ldr x9,[sp,#LLAT]
    str x9,[sp,#56]
    ldr x9,[sp,#LAREA]
    str x9,[sp,#64]
    ldr x9,[sp,#LRAINT]
    str x9,[sp,#72]
    ldr x9,[sp,#LDU]
    str x9,[sp,#80]
    ldr x9,[sp,#LDV]
    str x9,[sp,#88]
    ldr x9,[sp,#LFU]
    str x9,[sp,#96]
    ldr x9,[sp,#LFV]
    str x9,[sp,#104]
    bl GW_LAYER_CHILD
    mov x28,#0
.Llayer_add_level:
    mov x27,x22
    cmp x27,x23
    b.gt .Llayer_add_next
.Llayer_add_col:
    LOAD 0,LNU
    LOAD 1,LDU
    fadd d0,d0,d1
    SAVE 0,LNU
    LOAD 0,LNV
    LOAD 1,LDV
    fadd d0,d0,d1
    SAVE 0,LNV
    add x27,x27,#1
    cmp x27,x23
    b.le .Llayer_add_col
.Llayer_add_next:
    add x28,x28,#1
    cmp x28,x21
    b.lt .Llayer_add_level
    mov x28,#0
.Llayer_stress_level:
    mov x27,x22
    cmp x27,x23
    b.gt .Llayer_stress_next
.Llayer_stress_col:
    LOAD 0,LSU
    LOAD 1,LFU
    fsub d0,d0,d1
    SAVE 0,LSU
    LOAD 0,LSV
    LOAD 1,LFV
    fsub d0,d0,d1
    SAVE 0,LSV
    add x27,x27,#1
    cmp x27,x23
    b.le .Llayer_stress_col
.Llayer_stress_next:
    add x28,x28,#1
    cmp x28,x21
    b.le .Llayer_stress_level
    add x26,x26,#1
    cmp x26,x25
    b.le .Llayer_launch
.Llayer_finish:
    mov x0,x19
    bl free
    ldp x19,x20,[sp,#112]
    ldp x21,x22,[sp,#128]
    ldp x23,x24,[sp,#144]
    ldp x25,x26,[sp,#160]
    ldp x27,x28,[sp,#176]
    ldp x29,x30,[sp,#192]
    add sp,sp,#FR
    ret
.Llayer_domain:
    bl abort
    brk #0
.size GW_LAYER_SYMBOL,.-GW_LAYER_SYMBOL
.section .rodata
.p2align 3
.Llayer_pi: .quad 0x400921fb54442d18
.Llayer_hundred: .double 100.0
.Llayer_grid_min: .double 29000.0
.section .note.GNU-stack,"",%progbits

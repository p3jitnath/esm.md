/* Complete private CANALB parent; skills/md2fort-gpu/references/openifs/surface/private_canopy_light.md. */
#include "../../support/gpu/preserved_weather_calls.inc.S"
.text
.align 2
.global md2asm_canalb_wrapper_body
.type md2asm_canalb_wrapper_body,%function
md2asm_canalb_wrapper_body:
    mrs x9,fpcr
    cbnz x9,.Lreject
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    cbz x3,.Lreject
    cbz x4,.Lreject
    orr x9,x0,x1
    tst x9,#3
    b.ne .Lreject
    orr x9,x2,x3
    orr x9,x9,x4
    tst x9,#7
    b.ne .Lreject
    sub sp,sp,#1024
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x0,[sp,#128]
    str x1,[sp,#136]
    str x2,[sp,#144]
    str x3,[sp,#152]
    str x4,[sp,#160]
    ldrsw x19,[x0]
    ldrsw x28,[x1]
    cmp x19,#1
    b.lt .Lbad
    cmp x28,#0
    b.lt .Lbad
    cmp x28,#4096
    b.gt .Lbad
    sub x19,x19,#1
    ldr x24,[x3]
    cbz x24,.Lbad
    tst x24,#7
    b.ne .Lbad
    ldr x9,[x3,#16]
    cmp x9,#8
    b.ne .Lbad
    ldr x9,[x3,#32]
    cmp x9,#8
    b.ne .Lbad
    ldrh w9,[x3,#28]
    cmp w9,#769
    b.ne .Lbad
    ldr x26,[x3,#40]
    cmp x26,#0
    b.le .Lbad
    lsr x9,x26,#60
    cbnz x9,.Lbad
    ldp x9,x10,[x3,#48]
    subs x10,x10,x9
    b.vs .Lbad
    adds x10,x10,#1
    b.vs .Lbad
    cmp x10,#1
    b.lt .Lbad
    cmp x10,#4096
    b.gt .Lbad
    cmp x19,x10
    b.gt .Lbad
    cmp x28,x10
    b.gt .Lbad
    sub x10,x10,#1
    umulh x9,x10,x26
    cbnz x9,.Lbad
    mul x10,x10,x26
    mov x9,#0x1ffffff
    cmp x10,x9
    b.hi .Lbad
    add x10,x10,#1
    lsl x10,x10,#3
    adds x10,x24,x10
    b.cs .Lbad
    str x10,[sp,#168]
    lsl x26,x26,#3
    cbz x26,.Lbad
    ldr x25,[x4]
    cbz x25,.Lbad
    tst x25,#7
    b.ne .Lbad
    ldr x9,[x4,#16]
    cmp x9,#8
    b.ne .Lbad
    ldr x9,[x4,#32]
    cmp x9,#8
    b.ne .Lbad
    ldrh w9,[x4,#28]
    cmp w9,#769
    b.ne .Lbad
    ldr x27,[x4,#40]
    cmp x27,#0
    b.le .Lbad
    lsr x9,x27,#60
    cbnz x9,.Lbad
    ldp x9,x10,[x4,#48]
    subs x10,x10,x9
    b.vs .Lbad
    adds x10,x10,#1
    b.vs .Lbad
    cmp x10,#1
    b.lt .Lbad
    cmp x10,#4096
    b.gt .Lbad
    cmp x19,x10
    b.gt .Lbad
    cmp x28,x10
    b.gt .Lbad
    sub x10,x10,#1
    umulh x9,x10,x27
    cbnz x9,.Lbad
    mul x10,x10,x27
    mov x9,#0x1ffffff
    cmp x10,x9
    b.hi .Lbad
    add x10,x10,#1
    lsl x10,x10,#3
    adds x10,x25,x10
    b.cs .Lbad
    str x10,[sp,#176]
    lsl x27,x27,#3
    cbz x27,.Lbad
    ldr x11,[sp,#176]
    ldr x9,[sp,#128]
    adds x10,x9,#4
    b.cs .Lbad
    cmp x25,x10
    b.hs 1f
    cmp x9,x11
    b.lo .Lbad
1:
    ldr x9,[sp,#136]
    adds x10,x9,#4
    b.cs .Lbad
    cmp x25,x10
    b.hs 1f
    cmp x9,x11
    b.lo .Lbad
1:
    ldr x9,[sp,#144]
    adds x10,x9,#472
    b.cs .Lbad
    cmp x25,x10
    b.hs 1f
    cmp x9,x11
    b.lo .Lbad
1:
    ldr x9,[sp,#152]
    adds x10,x9,#64
    b.cs .Lbad
    cmp x25,x10
    b.hs 1f
    cmp x9,x11
    b.lo .Lbad
1:
    ldr x9,[sp,#160]
    adds x10,x9,#64
    b.cs .Lbad
    cmp x25,x10
    b.hs 1f
    cmp x9,x11
    b.lo .Lbad
1:
    mov x9,x24
    ldr x10,[sp,#168]
    cmp x25,x10
    b.hs 1f
    cmp x9,x11
    b.lo .Lbad
1:
    cmp x19,x28
    b.ge .Lcount_empty
    ldr x20,[sp,#144]
    ldr d0,[x20,#256]
    fmov x9,d0
    and x10,x9,#0x7fffffffffffffff
    mov x9,#0x7ff0000000000000
    cmp x10,x9
    b.hs .Lbad
    adrp x9,.Lc_aspect_min
    ldr d1,[x9,:lo12:.Lc_aspect_min]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison,128 // fcmp d0,d1
    b.lt .Lbad
    adrp x9,.Lc_aspect_max
    ldr d1,[x9,:lo12:.Lc_aspect_max]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison,128 // fcmp d0,d1
    b.gt .Lbad
    str d0,[sp,#184]
    ldr d0,[x20,#48]
    fmov x9,d0
    and x10,x9,#0x7fffffffffffffff
    mov x9,#0x7ff0000000000000
    cmp x10,x9
    b.hs .Lbad
    adrp x9,.Lc_zero
    ldr d1,[x9,:lo12:.Lc_zero]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison,128 // fcmp d0,d1
    b.lt .Lbad
    adrp x9,.Lc_one
    ldr d1,[x9,:lo12:.Lc_one]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison,128 // fcmp d0,d1
    b.gt .Lbad
    str d0,[sp,#192]
    ldr d0,[x20,#32]
    fmov x9,d0
    and x10,x9,#0x7fffffffffffffff
    mov x9,#0x7ff0000000000000
    cmp x10,x9
    b.hs .Lbad
    adrp x9,.Lc_zero
    ldr d1,[x9,:lo12:.Lc_zero]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison,128 // fcmp d0,d1
    b.lt .Lbad
    adrp x9,.Lc_one
    ldr d1,[x9,:lo12:.Lc_one]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison,128 // fcmp d0,d1
    b.gt .Lbad
    str d0,[sp,#200]
    mov x20,x19
.Lcheck_mu:
    madd x9,x20,x26,x24
    ldr d0,[x9]
    fmov x9,d0
    and x10,x9,#0x7fffffffffffffff
    mov x9,#0x7ff0000000000000
    cmp x10,x9
    b.hs .Lbad
    adrp x9,.Lc_zero
    ldr d1,[x9,:lo12:.Lc_zero]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison,128 // fcmp d0,d1
    b.lt .Lbad
    adrp x9,.Lc_one
    ldr d1,[x9,:lo12:.Lc_one]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison,128 // fcmp d0,d1
    b.gt .Lbad
    add x20,x20,#1
    cmp x20,x28
    b.lt .Lcheck_mu
.Lcount_empty:
    adrp x9,md2asm_canalb_native_calls
    add x9,x9,:lo12:md2asm_canalb_native_calls
    ldr x10,[x9]
    add x10,x10,#1
    str x10,[x9]
    cmp x19,x28
    b.ge .Ldone
    bl md2asm_private_canalb_complete_gpu_phase
.Ldone:
    ldp x27,x28,[sp,#80]
    ldp x25,x26,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp]
    add sp,sp,#1024
    ret
.Lbad:
    bl abort
.Lreject:
    b abort
.size md2asm_canalb_wrapper_body,.-md2asm_canalb_wrapper_body
.section .rodata
.align 3
.Lc_zero:
    .quad 0x0000000000000000
.Lc_one:
    .quad 0x3ff0000000000000
.Lc_two:
    .quad 0x4000000000000000
.Lc_half:
    .quad 0x3fe0000000000000
.Lc_sky:
    .quad 0x3fd3333333333333
.Lc_pi:
    .quad 0x400921fb54442d18
.Lc_aspect_min:
    .quad 0x3fa999999999999a
.Lc_aspect_max:
    .quad 0x3ff8000000000000
.Lc_tangent_floor:
    .quad 0x3f1a36e2eb1c432d
.data
.align 3
.global md2asm_canalb_native_calls
.hidden md2asm_canalb_native_calls
md2asm_canalb_native_calls:
    .quad 0
.section .note.GNU-stack,"",%progbits
.local md2asm_canalb_native_calls

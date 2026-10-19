#include "../../support/gpu/preserved_weather_calls.inc.S"
/*
 * Surface field unit scaling, revision 1.
 * Physics: formulations/openifs/input/surface_field_unit_scaling.md
 * Contract: skills/md2asm/references/openifs/input/surface_field_unit_scaling.md
 * x0..x7: field2d, bytes2d, field3d, bytes3d, parameters, parameter_bytes,
 * constants and constant_bytes. Fixed spans 770048/409600/208/16 bytes.
 * Two fields are in/out and disjoint from each other and both inputs.
 * FP64 means 64-bit floating point. Retain one FMUL per value, including
 * coefficients equal to one. Constants are original gravity/water density.
 * Return 0 success, 1 invalid buffers, 2 nonzero FPCR. Check before writes.
 * FPCR controls floating point and remains unchanged. FPSR records the
 * required multiplication flags. errno and x18..x30 remain unchanged.
 * x0..x17, d0,d1 and integer flags are scratch. No stack or child call.
 */
.arch armv8.2-a
.text
.p2align 4
.macro DISJOINT first, first_end, second, second_end
    cmp \first, \second_end
    b.hs .Ldisjoint_\@
    cmp \second, \first_end
    b.lo .Lbad
.Ldisjoint_\@:
.endm
.global md2asm_scale_initial_surface_fields
.type md2asm_scale_initial_surface_fields,%function
md2asm_scale_initial_surface_fields:
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x4,.Lbad
 cbz x6,.Lbad
 orr x8,x0,x2
 orr x8,x8,x6
 tst x8,#7
 b.ne .Lbad
 tst x4,#3
 b.ne .Lbad
 movz x8,#0xc000
 movk x8,#11,lsl#16
 cmp x1,x8
 b.lo .Lbad
 adds x9,x0,x8
 b.cs .Lbad
 movz x8,#0x4000
 movk x8,#6,lsl#16
 cmp x3,x8
 b.lo .Lbad
 adds x10,x2,x8
 b.cs .Lbad
 cmp x5,#208
 b.lo .Lbad
 adds x11,x4,#208
 b.cs .Lbad
 cmp x7,#16
 b.lo .Lbad
 adds x12,x6,#16
 b.cs .Lbad
 DISJOINT x0,x9,x2,x10
 DISJOINT x0,x9,x4,x11
 DISJOINT x0,x9,x6,x12
 DISJOINT x2,x10,x4,x11
 DISJOINT x2,x10,x6,x12
 mrs x8,fpcr
 cbnz x8,.Lbad_mode
 mov x7,#0
.Lfield2:
 ldr w8,[x4,x7,lsl#2]
 fmov d1,#1.0
 cmp w8,#173
 b.eq .Lgravity2
 cmp w8,#244
 b.eq .Lgravity2
 cmp w8,#160
 b.eq .Lgravity2
 cmp w8,#198
 b.eq .Lwater2
 b .Lfactor2_ready
.Lgravity2:
 ldr d1,[x6]
 b .Lfactor2_ready
.Lwater2:
 ldr d1,[x6,#8]
.Lfactor2_ready:
 mov x8,#2048
.Lpoint2:
 ldr d0,[x0]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d1,d0 // fmul d0,d1,d0
 str d0,[x0],#8
 subs x8,x8,#1
 b.ne .Lpoint2
 add x7,x7,#1
 cmp x7,#47
 b.ne .Lfield2
 add x4,x4,#188
 mov x7,#0
.Lfield3:
 ldr w8,[x4,x7,lsl#2]
 fmov d1,#1.0
 cmp w8,#173
 b.eq .Lgravity3
 cmp w8,#244
 b.eq .Lgravity3
 cmp w8,#160
 b.eq .Lgravity3
 cmp w8,#141
 b.eq .Lwater3
 cmp w8,#198
 b.eq .Lwater3
 b .Lfactor3_ready
.Lgravity3:
 ldr d1,[x6]
 b .Lfactor3_ready
.Lwater3:
 ldr d1,[x6,#8]
.Lfactor3_ready:
 mov x8,#10240
.Lpoint3:
 ldr d0,[x2]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,2,d0,d1,d0 // fmul d0,d1,d0
 str d0,[x2],#8
 subs x8,x8,#1
 b.ne .Lpoint3
 add x7,x7,#1
 cmp x7,#5
 b.ne .Lfield3
 mov w0,#0
 ret
.Lbad:
 mov w0,#1
 ret
.Lbad_mode:
 mov w0,#2
 ret
.size md2asm_scale_initial_surface_fields,.-md2asm_scale_initial_surface_fields
.section .note.GNU-stack,"",%progbits

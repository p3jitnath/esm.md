/* Complete SUGRIB soil labels from the genuine owned surface parameters.
 * Contract skills/md2asm/references/openifs/output/runtime_grib_soil_levels.md.
 * The original ice branch deliberately uses the water-layer thickness. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_runtime_grib_soil_levels
.type md2asm_initialize_runtime_grib_soil_levels,%function
md2asm_initialize_runtime_grib_soil_levels:
 sub sp,sp,#384
 stp x19,x20,[sp]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 stp x29,x30,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x1
 cbz x0,.Lgs_bad
 cbz x1,.Lgs_bad
 tst x0,#7
 b.ne .Lgs_bad
 tst x1,#3
 b.ne .Lgs_bad
 cmp x2,#144
 b.lo .Lgs_bad
 mov x9,#11584
 adds x9,x0,x9
 b.cs .Lgs_bad
 adds x10,x1,#144
 b.cs .Lgs_bad
 cmp x1,x9
 b.hs .Lgs_disjoint
 cmp x0,x10
 b.lo .Lgs_bad
.Lgs_disjoint:
 mrs x9,fpcr
 cbnz x9,.Lgs_bad
 mov x9,#3944
 ldr w9,[x19,x9]
 cmp w9,#4
 b.ne .Lgs_bad
 mov x9,#9264
 add x0,x19,x9
 bl .Lgs_descriptor
 cbnz w0,.Lgs_bad
 mov x21,x1
 mov x9,#9328
 add x0,x19,x9
 bl .Lgs_descriptor
 cbnz w0,.Lgs_bad
 mov x22,x1
 /* All consumed thicknesses are admitted before the first sum. */
 adr x9,.Lgs_constants
 ldr d1,[x9,#24]
 mov x23,#0
.Lgs_values:
 ldr x9,[x21,x23,lsl#3]
 and x10,x9,#0x7fffffffffffffff
 cbz x10,.Lgs_water_value
 tbnz x9,#63,.Lgs_bad
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lgs_bad
 fmov d0,x9
 fcmp d0,d1
 b.gt .Lgs_bad
.Lgs_water_value:
 ldr x9,[x22,x23,lsl#3]
 and x10,x9,#0x7fffffffffffffff
 cbz x10,.Lgs_next_value
 tbnz x9,#63,.Lgs_bad
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lgs_bad
 fmov d0,x9
 fcmp d0,d1
 b.gt .Lgs_bad
.Lgs_next_value:
 add x23,x23,#1
 cmp x23,#4
 b.lo .Lgs_values
 adr x9,.Lgs_constants
 ldr d3,[x9]
 ldr d4,[x9,#8]
 ldr d5,[x9,#16]
 adr x27,.Lgs_codes
 add x28,sp,#160
 mov x23,#0
.Lgs_group:
 cmp x23,#0
 csel x26,x21,x22,eq
 mov x24,#0
.Lgs_layer:
 fmov d0,xzr
 mov x9,#0
.Lgs_sum:
 ldr d1,[x26,x9,lsl#3]
 fadd d0,d0,d1
 add x9,x9,#1
 cmp x9,x24
 b.ls .Lgs_sum
 ldr d1,[x26,x24,lsl#3]
 fsub d2,d0,d1
 fmul d2,d2,d3
 fadd d2,d2,d4
 fmin d2,d2,d5
 fcvtzs w9,d2
 mov x10,#4
 madd x25,x23,x10,x24
 add x10,x28,#96
 str w9,[x10,x25,lsl#2]
 fmul d0,d0,d3
 fadd d0,d0,d4
 fmin d0,d0,d5
 fcvtzs w9,d0
 add x10,x28,#48
 str w9,[x10,x25,lsl#2]
 ldr w9,[x27,x25,lsl#2]
 str w9,[x28,x25,lsl#2]
 add x24,x24,#1
 cmp x24,#4
 b.lo .Lgs_layer
 add x23,x23,#1
 cmp x23,#3
 b.lo .Lgs_group
 mov x9,#0
.Lgs_publish:
 ldr x10,[x28,x9]
 str x10,[x20,x9]
 add x9,x9,#8
 cmp x9,#144
 b.lo .Lgs_publish
 mov w0,#0
 b .Lgs_return
.Lgs_bad:
 mov w0,#2
.Lgs_return:
 ldr x18,[sp,#96]
 ldp x29,x30,[sp,#80]
 ldp x27,x28,[sp,#64]
 ldp x25,x26,[sp,#48]
 ldp x23,x24,[sp,#32]
 ldp x21,x22,[sp,#16]
 ldp x19,x20,[sp]
 add sp,sp,#384
 ret
.size md2asm_initialize_runtime_grib_soil_levels,.-md2asm_initialize_runtime_grib_soil_levels
/* This private leaf keeps x19 through x28 and performs no FP operation. */
.Lgs_descriptor:
 ldr x9,[x0,#8]
 cmn x9,#1
 b.ne .Lgs_desc_bad
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lgs_desc_bad
 ldr x9,[x0,#24]
 mov x10,#0x301
 lsl x10,x10,#32
 cmp x9,x10
 b.ne .Lgs_desc_bad
 ldr x9,[x0,#32]
 cmp x9,#8
 b.ne .Lgs_desc_bad
 ldp x9,x10,[x0,#40]
 cmp x9,#1
 b.ne .Lgs_desc_bad
 cmp x10,#1
 b.ne .Lgs_desc_bad
 ldr x9,[x0,#56]
 cmp x9,#4
 b.ne .Lgs_desc_bad
 ldr x1,[x0]
 cbz x1,.Lgs_desc_bad
 tst x1,#7
 b.ne .Lgs_desc_bad
 adds x9,x1,#32
 b.cs .Lgs_desc_bad
 mov w0,#0
 ret
.Lgs_desc_bad:
 mov w0,#2
 ret
.section .rodata
.p2align 3
.Lgs_constants: .double 100.0,0.1,255.0,1000000.0
.p2align 2
.Lgs_codes: .word 139,170,183,236,39,40,41,42,35,36,37,38
.section .note.GNU-stack,"",%progbits

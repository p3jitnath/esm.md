/* Direct WVRG2XF wrapper for formulations/openifs/waves/ocean_waves.md.
 * Contract: skills/md2asm/references/openifs/waves/runtime_wave_surface_return.md.
 * x0 surface, x1 fields, x2/x3/x4 int32 field/point/block counts,
 * x5 readonly context24 with surface bytes, field bytes, false-hook address.
 * The caller admits the complete bit-copy leaf contract before this entry. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_runtime_return_wave_surface_fields
.type md2asm_runtime_return_wave_surface_fields,%function
md2asm_runtime_return_wave_surface_fields:
 cbz x0,.Lwave_return_bad
 cbz x1,.Lwave_return_bad
 cbz x2,.Lwave_return_bad
 cbz x3,.Lwave_return_bad
 cbz x4,.Lwave_return_bad
 cbz x5,.Lwave_return_bad
 orr x9,x0,x1
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lwave_return_bad
 orr x9,x2,x3
 orr x9,x9,x4
 tst x9,#3
 b.ne .Lwave_return_bad
 adds x9,x2,#4
 b.cs .Lwave_return_bad
 adds x9,x3,#4
 b.cs .Lwave_return_bad
 adds x9,x4,#4
 b.cs .Lwave_return_bad
 adds x9,x5,#24
 b.cs .Lwave_return_bad
 ldr x9,[x5,#16]
 cbz x9,.Lwave_return_bad
 tst x9,#7
 b.ne .Lwave_return_bad
 adds x10,x9,#4
 b.cs .Lwave_return_bad
 ldr w9,[x9]
 cbnz w9,.Lwave_return_bad
 mrs x9,fpcr
 cbnz x9,.Lwave_return_bad
 stp x18,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 adrp x0,.Lwave_stats
 add x0,x0,:lo12:.Lwave_stats
 add x1,x0,#4
 bl gstats_
 mov x0,x19
 ldr x1,[x24]
 mov x2,x20
 ldr x3,[x24,#8]
 ldr w4,[x21]
 ldr w5,[x22]
 ldr w6,[x23]
 bl md2asm_store_operational_wave_surface_fields
 mov w25,w0
 adrp x0,.Lwave_stats
 add x0,x0,:lo12:.Lwave_stats
 add x1,x0,#8
 bl gstats_
 mov w0,w25
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x18,x30,[sp],#96
 ret
.Lwave_return_bad:
 mov w0,#2
 ret
.size md2asm_runtime_return_wave_surface_fields,.-md2asm_runtime_return_wave_surface_fields
.section .rodata
.p2align 3
.Lwave_stats:
.word 1426,0,1,0
.section .note.GNU-stack,"",%progbits

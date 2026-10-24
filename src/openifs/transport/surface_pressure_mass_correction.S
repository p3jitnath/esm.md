/* Direct proportional PFIXER. Seven source addresses plus dependency32 in x7, Pa pressures and log(Pa) surface field.
 * Contract skills/md2asm/references/openifs/transport/surface_pressure_mass_correction.md. Selected NGPMASCOR=0, no diagnostics.
 * Owns pressure packing, two ordered weighted means, the ratio, all active products and LOG stores.
 * The 384-byte frame preserves x18, x19-x29 and x30. Local mean storage does not overlap arguments.
 */
.arch armv8.2-a
.text
.p2align 4
.macro PRESSURE_CALL target
 str x18,[sp,#368]
 bl \target
 ldr x18,[sp,#368]
.endm
.global md2asm_runtime_surface_pressure_mass_correction
.type md2asm_runtime_surface_pressure_mass_correction,%function
md2asm_runtime_surface_pressure_mass_correction:
 sub sp,sp,#384
 stp x18,x30,[sp,#16]
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 stp x27,x28,[sp,#96]
 str x29,[sp,#112]
 stp x0,x1,[sp,#128]
 stp x2,x3,[sp,#144]
 stp x4,x5,[sp,#160]
 str x6,[sp,#176]
 str x7,[sp,#184]
 mov x26,xzr
 str wzr,[sp,#328]
 mov x19,x0
 mov x20,x1
 cbz x19,.Lpressure_bad
 cbz x20,.Lpressure_bad
 cbz x2,.Lpressure_bad
 cbz x3,.Lpressure_bad
 cbz x4,.Lpressure_bad
 cbz x5,.Lpressure_bad
 cbz x6,.Lpressure_bad
 cbz x7,.Lpressure_bad
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x3
 orr x9,x9,x4
 orr x9,x9,x5
 orr x9,x9,x6
 orr x9,x9,x7
 tst x9,#7
 b.ne .Lpressure_bad
 ldr x9,[x7,#24]
 cbnz x9,.Lpressure_bad
 ldp x9,x10,[x7]
 cbz x9,.Lpressure_bad
 cbz x10,.Lpressure_bad
 orr x11,x9,x10
 tst x11,#7
 b.ne .Lpressure_bad
 ldr w11,[x9,#24]
 cmp w11,#4
 b.ne .Lpressure_bad
 ldr w11,[x9,#28]
 sub w11,w11,#1
 cmp w11,#3
 b.hi .Lpressure_bad
 movz x11,#(67600&65535)
 movk x11,#(67600>>16),lsl#16
 ldr w11,[x10,x11]
 cbnz w11,.Lpressure_bad

 mrs x9,fpcr
 cbnz x9,.Lpressure_bad
 ldr w9,[x2,#280]
 cbnz w9,.Lpressure_bad
 ldr w9,[x2,#320]
 cbnz w9,.Lpressure_bad
 ldr w9,[x3,#4584]
 cbnz w9,.Lpressure_bad
 ldr w9,[x20,#1364]
 cmp w9,#1
 b.ne .Lpressure_bad
 ldr w9,[x20,#1400]
 cmp w9,#1
 b.ne .Lpressure_bad
 ldr w27,[x19,#5144]
 sub w9,w27,#1
 cmp w9,#4095
 b.hi .Lpressure_bad
 ldr w10,[x19,#5160]
 cmp w10,#1
 b.lt .Lpressure_bad
 ldr w28,[x19,#7376]
 cmp w28,#1
 b.lt .Lpressure_bad
 mul x12,x27,x10
 cmp x28,x12
 b.hi .Lpressure_bad
 sub x9,x12,x27
 cmp x28,x9
 b.ls .Lpressure_bad
 lsl x12,x12,#3
 str x12,[sp,#192]
 /* Runtime owner extents include final padding. */
 adds x9,x4,x12
 b.cs .Lpressure_bad
 adds x10,x5,x12
 b.cs .Lpressure_bad
 adds x11,x6,x12
 b.cs .Lpressure_bad
 cmp x4,x10
 b.hs .Lpressure_p0_p1_clear
 cmp x5,x9
 b.lo .Lpressure_bad
.Lpressure_p0_p1_clear:
 cmp x4,x11
 b.hs .Lpressure_p0_log_clear
 cmp x6,x9
 b.lo .Lpressure_bad
.Lpressure_p0_log_clear:
 cmp x5,x11
 b.hs .Lpressure_ranges_clear
 cmp x6,x10
 b.lo .Lpressure_bad
.Lpressure_ranges_clear:
 ldr x0,[sp,#192]
 lsl x0,x0,#1
 PRESSURE_CALL malloc
 mov x26,x0
 cmp x0,#0
 cset w0,eq
 PRESSURE_CALL .Lpressure_agree
 str w0,[sp,#328]
 cbnz w0,.Lpressure_release
 ldr x24,[sp,#160]
 ldr x23,[sp,#168]
 ldr x25,[sp,#176]
 mov x22,#0
.Lpressure_pack:
 cmp x22,x28
 b.ge .Lpressure_norm
 udiv x9,x22,x27
 msub x10,x9,x27,x22
 lsl x11,x27,#1
 madd x9,x9,x11,x10
 ldr d0,[x24,x22,lsl #3]
 ldr d1,[x23,x22,lsl #3]
 str d0,[x26,x9,lsl #3]
 add x9,x9,x27
 str d1,[x26,x9,lsl #3]
 add x22,x22,#1
 b .Lpressure_pack
.Lpressure_norm:
 mov x0,x19
 mov x1,x26
 adr x2,.Lpressure_two
 adr x3,.Lpressure_false
 mov x4,#0
 add x5,sp,#256
 mov x6,#0
 ldr x7,[sp,#184]
 PRESSURE_CALL md2asm_runtime_grid_point_norm
 PRESSURE_CALL .Lpressure_agree
 str w0,[sp,#328]
 cbnz w0,.Lpressure_release
 ldr d0,[sp,#256]
 ldr d1,[sp,#280]
 fdiv d0,d0,d1
 str d0,[sp,#320]
 mov x22,#0
.Lpressure_update:
 cmp x22,x28
 b.ge .Lpressure_done
 ldr d0,[x23,x22,lsl #3]
 ldr d1,[sp,#320]
 fmul d0,d1,d0
 str d0,[x23,x22,lsl #3]
 PRESSURE_CALL log
 str d0,[x25,x22,lsl #3]
 add x22,x22,#1
 b .Lpressure_update
 .Lpressure_done:
 str wzr,[sp,#328]
.Lpressure_release:
 cbz x26,.Lpressure_return
 mov x0,x26
 PRESSURE_CALL free
.Lpressure_return:
 ldr w0,[sp,#328]
 ldp x18,x30,[sp,#16]
 ldp x19,x20,[sp,#32]
 ldp x21,x22,[sp,#48]
 ldp x23,x24,[sp,#64]
 ldp x25,x26,[sp,#80]
 ldp x27,x28,[sp,#96]
 ldr x29,[sp,#112]
 add sp,sp,#384
 ret
.size md2asm_runtime_surface_pressure_mass_correction,.-md2asm_runtime_surface_pressure_mass_correction
.Lpressure_bad:
 mov w0,#2
 str w0,[sp,#328]
 b .Lpressure_release
/* Auxiliary coordination alone restores incoming numerical status and errno. */
.Lpressure_agree:
 stp x29,x30,[sp,#-80]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 str w0,[sp,#48]
 mrs x19,fpsr
 mrs x20,fpcr
 bl __errno_location
 mov x21,x0
 ldr w9,[x21]
 str w9,[sp,#52]
 ldr w0,[sp,#48]
 bl md2asm_agree_owned_distributed_partition_status
 str w0,[sp,#56]
 ldr w9,[sp,#52]
 str w9,[x21]
 msr fpcr,x20
 msr fpsr,x19
 ldr w0,[sp,#56]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.section .rodata
.p2align 2
.Lpressure_two: .word 2
.Lpressure_false: .word 0
.Lpressure_name: .ascii "PFIXER"
.section .note.GNU-stack,"",%progbits

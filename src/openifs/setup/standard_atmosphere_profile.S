// Solver contract skills/md2asm/references/openifs/setup/standard_atmosphere_profile.md.
/* Standard atmosphere at model pressures, local revision 1.
 * Contract: skills/md2asm/references/openifs/setup/standard_atmosphere_profile.md in this directory.
 * x0 temperature, x1 geopotential, x2 pressure, x3 288-byte layer table,
 * x4 32-byte physical constants, x5 level count. w0 is zero or two.
 * Inputs and outputs are disjoint, mapped and eight-byte aligned.
 * Ordered equations: SUSTA LOG prefix and PPSTA ICAO single-column path.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_standard_atmosphere_profile
.type md2asm_standard_atmosphere_profile,%function
md2asm_standard_atmosphere_profile:
 mrs x9,fpcr
 cbnz x9,.Lprofile_reject
 sub x9,x5,#1
 cmp x9,#255
 b.hi .Lprofile_reject
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x3
 orr x9,x9,x4
 tst x9,#7
 b.ne .Lprofile_reject
 cbz x0,.Lprofile_reject
 cbz x1,.Lprofile_reject
 cbz x2,.Lprofile_reject
 cbz x3,.Lprofile_reject
 cbz x4,.Lprofile_reject
 lsl x10,x5,#3
 adds x11,x0,x10
 b.cs .Lprofile_reject
 adds x12,x1,x10
 b.cs .Lprofile_reject
 adds x13,x2,x10
 b.cs .Lprofile_reject
 adds x14,x3,#288
 b.cs .Lprofile_reject
 adds x15,x4,#32
 b.cs .Lprofile_reject
 /* Disjoint output spans, and outputs disjoint from every input span. */
 cmp x0,x12
 b.hs .Lprofile_pair1
 cmp x1,x11
 b.lo .Lprofile_reject
.Lprofile_pair1:
 cmp x0,x13
 b.hs .Lprofile_pair2
 cmp x2,x11
 b.lo .Lprofile_reject
.Lprofile_pair2:
 cmp x0,x14
 b.hs .Lprofile_pair3
 cmp x3,x11
 b.lo .Lprofile_reject
.Lprofile_pair3:
 cmp x0,x15
 b.hs .Lprofile_pair4
 cmp x4,x11
 b.lo .Lprofile_reject
.Lprofile_pair4:
 cmp x1,x13
 b.hs .Lprofile_pair5
 cmp x2,x12
 b.lo .Lprofile_reject
.Lprofile_pair5:
 cmp x1,x14
 b.hs .Lprofile_pair6
 cmp x3,x12
 b.lo .Lprofile_reject
.Lprofile_pair6:
 cmp x1,x15
 b.hs .Lprofile_pressure_guard
 cmp x4,x12
 b.lo .Lprofile_reject
.Lprofile_pressure_guard:
 mov x9,#0
 movz x10,#0x3cb0,lsl#48
 movz x11,#0x7ff0,lsl#48
.Lprofile_guard_loop:
 ldr x12,[x2,x9,lsl#3]
 cmp x12,x10
 b.lo .Lprofile_reject
 cmp x12,x11
 b.hs .Lprofile_reject
 add x9,x9,#1
 cmp x9,x5
 b.lo .Lprofile_guard_loop
 sub sp,sp,#2464
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 stp d8,d9,[sp,#80]
 stp d10,d11,[sp,#96]
 stp d12,d13,[sp,#112]
 stp d14,d15,[sp,#128]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,#0
.Lprofile_input_log:
 ldr d0,[x21,x25,lsl#3]
 bl md2asm_log_positive_normal
 add x9,sp,#416
 str d0,[x9,x25,lsl#3]
 add x25,x25,#1
 cmp x25,x24
 b.lo .Lprofile_input_log
 mov x25,#0
.Lprofile_coefficients:
 add x9,x22,#216
 ldr d0,[x9,x25,lsl#3]
 bl md2asm_log_positive_normal
 add x9,sp,#144
 str d0,[x9,x25,lsl#3]
 add x9,x22,#216
 ldr d1,[x9,x25,lsl#3]
 fmov d0,#1.0
 fdiv d0,d0,d1
 add x9,sp,#216
 str d0,[x9,x25,lsl#3]
 add x9,x22,#72
 ldr d1,[x9,x25,lsl#3]
 fmov d0,xzr
 fcmp d1,#0.0
 b.eq .Lprofile_inverse_zero
 fmov d0,#1.0
 fdiv d0,d0,d1
.Lprofile_inverse_zero:
 add x9,sp,#288
 str d0,[x9,x25,lsl#3]
 add x25,x25,#1
 cmp x25,#9
 b.lo .Lprofile_coefficients
 ldp d0,d1,[x23]
 fdiv d8,d1,d0
 mov x25,#0
.Lprofile_level:
 ldr d9,[x21,x25,lsl#3]
 mov x10,#0
 add x9,x22,#216
.Lprofile_layer:
 add x11,x10,#1
 ldr d0,[x9,x11,lsl#3]
 fcmp d9,d0
 b.ge .Lprofile_evaluate
 add x10,x10,#1
 cmp x10,#8
 b.lo .Lprofile_layer
.Lprofile_evaluate:
 str x10,[sp,#360]
 add x9,x22,#72
 ldr d11,[x9,x10,lsl#3]
 add x9,x22,#144
 ldr d12,[x9,x10,lsl#3]
 ldr d13,[x22,x10,lsl#3]
 fcmp d11,#0.0
 b.eq .Lprofile_isothermal
 add x9,sp,#216
 ldr d0,[x9,x10,lsl#3]
 fmul d0,d9,d0
 fneg d1,d11
 fmul d1,d1,d8
 bl md2asm_pow_original_rounding_candidate
 fmov d1,#1.0
 fsub d0,d0,d1
 ldr x10,[sp,#360]
 add x9,sp,#288
 ldr d1,[x9,x10,lsl#3]
 fmul d1,d12,d1
 fmul d1,d1,d0
 fadd d10,d13,d1
 fsub d0,d10,d13
 fmul d0,d11,d0
 fadd d0,d12,d0
 b .Lprofile_store
.Lprofile_isothermal:
 add x9,sp,#416
 ldr d0,[x9,x25,lsl#3]
 add x9,sp,#144
 ldr d1,[x9,x10,lsl#3]
 fsub d0,d0,d1
 fmul d1,d12,d8
 fmul d1,d1,d0
 fsub d10,d13,d1
 fmov d0,d12
.Lprofile_store:
 str d0,[x19,x25,lsl#3]
 ldr d0,[x23]
 fmul d0,d10,d0
 str d0,[x20,x25,lsl#3]
 add x25,x25,#1
 cmp x25,x24
 b.lo .Lprofile_level
 mov w0,#0
 ldp d14,d15,[sp,#128]
 ldp d12,d13,[sp,#112]
 ldp d10,d11,[sp,#96]
 ldp d8,d9,[sp,#80]
 ldp x25,x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#2464
 ret
.Lprofile_reject:
 mov w0,#2
 ret
.size md2asm_standard_atmosphere_profile,.-md2asm_standard_atmosphere_profile
.section .note.GNU-stack,"",%progbits

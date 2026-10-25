/* Contract: skills/md2asm/references/openifs/radiation/runtime_radiation_frequencies.md. */
/* Runtime source-order radiation schedules. All counts are int32.
 * x0 TERAD2040,x1capacity,x2 TEUVRAD229312,x3capacity,x4constants520,
 * x5live TSTEP8,x6bounded text,x7bytes. Return0/2 before public stores. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_runtime_radiation_frequencies
.type md2asm_initialize_runtime_radiation_frequencies,%function
md2asm_initialize_runtime_radiation_frequencies:
 cbz x0,.Lrf_bad_leaf
 cbz x2,.Lrf_bad_leaf
 cbz x4,.Lrf_bad_leaf
 cbz x5,.Lrf_bad_leaf
 cbz x6,.Lrf_bad_leaf
 orr x9,x0,x2
 orr x9,x9,x4
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lrf_bad_leaf
 cmp x1,#2040
 b.lo .Lrf_bad_leaf
 movz x9,#(229312&65535)
 movk x9,#(229312>>16),lsl#16
 cmp x3,x9
 b.lo .Lrf_bad_leaf
 cbz x7,.Lrf_bad_leaf
 cmp x7,#64,lsl#12
 b.hi .Lrf_bad_leaf
 mrs x9,fpcr
 cbnz x9,.Lrf_bad_leaf
 sub sp,sp,#1536
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 str x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov x21,x4
 mov x22,x5
 mov x23,x6
 mov x24,x7
 add x9,sp,#128
 adds x10,x0,#2040
 b.cs .Lrf_bad_frame
 stp x0,x10,[x9]
 movz x10,#(229312&65535)
 movk x10,#(229312>>16),lsl#16
 adds x10,x2,x10
 b.cs .Lrf_bad_frame
 stp x2,x10,[x9,#16]
 adds x10,x4,#520
 b.cs .Lrf_bad_frame
 stp x4,x10,[x9,#32]
 adds x10,x5,#8
 b.cs .Lrf_bad_frame
 stp x5,x10,[x9,#48]
 adds x10,x6,x7
 b.cs .Lrf_bad_frame
 stp x6,x10,[x9,#64]
 mov x10,#0
.Lrf_outer:
 add x11,x9,x10,lsl#4
 ldp x12,x13,[x11]
 add x14,x10,#1
.Lrf_inner:
 cmp x14,#5
 b.hs .Lrf_next
 add x11,x9,x14,lsl#4
 ldp x15,x16,[x11]
 cmp x12,x16
 b.hs .Lrf_apart
 cmp x15,x13
 b.lo .Lrf_bad_frame
.Lrf_apart:
 add x14,x14,#1
 b .Lrf_inner
.Lrf_next:
 add x10,x10,#1
 cmp x10,#4
 b.lo .Lrf_outer
 // Integer bit guards admit only positive finite TSTEP in [1,3600].
 ldr x9,[x22]
 adr x10,.Lrf_limits
 ldp x11,x12,[x10]
 cmp x9,x11
 b.lo .Lrf_bad_frame
 cmp x9,x12
 b.hi .Lrf_bad_frame
 ldr x9,[x21,#56]
 cmp x9,x12
 b.ne .Lrf_bad_frame
 add x9,sp,#256
 mov x10,#0
.Lrf_clear:
 add x11,x9,x10
 stp xzr,xzr,[x11]
 add x10,x10,#16
 cmp x10,#1104
 b.lo .Lrf_clear
 mov w10,#1
 str w10,[x9,#36]
 str w10,[x9,#44]
 mov w10,#-1
 str w10,[x9,#1072]
 str w10,[x9,#1084]
 mov w10,#15
 str w10,[x9,#1080]
 mov w10,#12
 str w10,[x9,#1088]
 mov x0,x23
 mov x1,x24
 add x2,sp,#256
 bl md2asm_apply_radiation_frequency_namelist
 cbnz w0,.Lrf_bad_frame
 mov x0,x23
 mov x1,x24
 add x2,sp,#256
 bl md2asm_apply_radiation_frequency_namelist
 cbnz w0,.Lrf_bad_frame
 ldr w9,[sp,#300]
 cmp w9,#1
 b.ne .Lrf_bad_frame
 ldr w9,[sp,#1328]
 cbz w9,.Lrf_bad_frame
 ldr w9,[sp,#1332]
 cmp w9,#8
 b.hi .Lrf_bad_frame
 ldr w9,[sp,#1336]
 tst w9,#0x80000000
 b.ne .Lrf_bad_frame
 ldr w9,[sp,#1344]
 sub w9,w9,#1
 cmp w9,#63
 b.hi .Lrf_bad_frame
 mov x0,x19
 mov x1,x20
 mov x2,x21
 mov x3,x22
 add x4,sp,#1328
 bl md2asm_calculate_runtime_radiation_frequencies
 b .Lrf_return
.Lrf_bad_frame:
 mov w0,#2
.Lrf_return:
 ldr x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#1536
 ret
.Lrf_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_runtime_radiation_frequencies,.-md2asm_initialize_runtime_radiation_frequencies

/* Raw calculation takes TERAD,TEUVRAD,constants,TSTEP,choices20.
 * All spans and choice bounds are admitted by the enclosing entry.
 * choices are NRADFR,NRADPFR,NRADPLA,NRADUV,NLNGR1H. */
.p2align 4
.global md2asm_calculate_runtime_radiation_frequencies
.type md2asm_calculate_runtime_radiation_frequencies,%function
md2asm_calculate_runtime_radiation_frequencies:
 sub sp,sp,#128
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x29,sp
 mov x26,x0
 str x1,[sp,#88]
 ldp w19,w20,[x4]
 ldp w21,w22,[x4,#8]
 ldr w23,[x4,#16]
 ldr d0,[x3]
 fmov d1,#1.0
 fmax d0,d0,d1
 str d0,[sp,#96]
 ldr d1,[x2,#56]
 fdiv d2,d1,d0
 str d2,[sp,#104]
 tbz w19,#31,.Lrf_fr_ready
 neg w9,w19
 scvtf d3,w9
 fmul d3,d3,d2
 fmov d4,#0.5
 fadd d3,d3,d4
 fcvtzs w19,d3
.Lrf_fr_ready:
 mul w20,w20,w19
 cbz w21,.Lrf_planet_ready
 tbnz w21,#0,.Lrf_planet_ready
 add w21,w21,#1
.Lrf_planet_ready:
 tbz w22,#31,.Lrf_uv_ready
 neg w9,w22
 scvtf d3,w9
 fmul d3,d3,d2
 fmov d4,#0.5
 fadd d3,d3,d4
 fcvtzs w22,d3
.Lrf_uv_ready:
 adr x9,.Lrf_epsilon
 ldr d4,[x9]
 fadd d3,d2,d4
 fcvtzs w24,d3
 scvtf d3,w23
 fmul d3,d3,d2
 fadd d3,d3,d4
 fcvtzs w25,d3
 ldr d0,[x2,#56]
 ldr d1,[sp,#96]
 bl fmod
 adr x9,.Lrf_remainder_limit
 ldr d1,[x9]
 fcmp d0,d1
 b.le .Lrf_hour_ready
 cmp w25,w24
 b.le .Lrf_schedule_refusal
.Lrf_hour_search:
 add w24,w24,#1
 sdiv w9,w25,w24
 msub w9,w9,w24,w25
 cbnz w9,.Lrf_hour_search
.Lrf_hour_ready:
 cmp w19,#1
 csel w9,w19,w24,eq
 add w10,w24,w24,lsl#1
 stp w19,w20,[x26,#12]
 str w21,[x26,#20]
 stp w19,w9,[x26,#32]
 stp w24,w10,[x26,#40]
 str w23,[x26,#132]
 ldr x9,[sp,#88]
 str w22,[x9]
 mov w0,#0
 b .Lrf_raw_return
.Lrf_schedule_refusal:
 mov w0,#2
.Lrf_raw_return:
 ldr x18,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#128
 ret
.size md2asm_calculate_runtime_radiation_frequencies,.-md2asm_calculate_runtime_radiation_frequencies
.section .rodata
.p2align 3
.Lrf_limits: .double 1.0,3600.0
.Lrf_epsilon: .double 0.05
.Lrf_remainder_limit: .double 0.1
.section .note.GNU-stack,"",%progbits

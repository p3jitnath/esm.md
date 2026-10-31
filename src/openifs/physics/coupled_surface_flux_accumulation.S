/* Accumulate the surface fluxes of the original OpenIFS CUMCOE routine.
 * x0 names the genuine 2176-byte coupled-field owner; x1 names an FP64
 * time step in seconds; x2 names int32 [P, first, last, global_start];
 * x3 names fourteen FP64 input-array addresses in source argument order.
 * The application binary interface uses a 96-byte aligned stack frame.
 * It preserves x18, x19 through x30, and the low words of v8 through v15.
 * Each admitted update retains the original sum, multiply and add order.
 * Return 0 means success; return 2 refuses the input before a public write.
 * Full bounds, units, storage and checks are in
 * skills/md2asm/references/openifs/physics/coupled_surface_flux_accumulation.md.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_accumulate_runtime_coupled_surface_fluxes
.type md2asm_accumulate_runtime_coupled_surface_fluxes,%function
md2asm_accumulate_runtime_coupled_surface_fluxes:
 cbz x0,.Lcum_bad_entry
 tst x0,#7
 b.ne .Lcum_bad_entry
 adds x4,x0,#2176
 b.cs .Lcum_bad_entry
 cbz x1,.Lcum_bad_entry
 tst x1,#7
 b.ne .Lcum_bad_entry
 adds x4,x1,#8
 b.cs .Lcum_bad_entry
 cbz x2,.Lcum_bad_entry
 tst x2,#3
 b.ne .Lcum_bad_entry
 adds x4,x2,#16
 b.cs .Lcum_bad_entry
 cbz x3,.Lcum_bad_entry
 tst x3,#7
 b.ne .Lcum_bad_entry
 adds x4,x3,#112
 b.cs .Lcum_bad_entry
 mrs x4,fpcr
 cbnz x4,.Lcum_bad_entry
 sub sp,sp,#96
 stp x19,x20,[sp]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 stp x29,x30,[sp,#80]
 mov x19,x0
 mov x20,x3
 mov x21,x2
 ldr x4,[x19,#16]
 cmp x4,#1
 b.ne .Lcum_bad
 ldr x4,[x19,#24]
 cbz x4,.Lcum_bad
 lsr x6,x4,#31
 cbnz x6,.Lcum_bad
 lsl x28,x4,#3
 ldr x5,[x19,#32]
 cbz x5,.Lcum_bad
 lsr x6,x5,#31
 cbnz x6,.Lcum_bad
 mov x6,#6
 mul x7,x5,x6
 add x7,x7,#19
 umulh x8,x7,x4
 cbnz x8,.Lcum_bad
 mul x7,x7,x4
 lsr x8,x7,#61
 cbnz x8,.Lcum_bad
 lsl x7,x7,#3
 ldr x8,[x19,#8]
 cmp x7,x8
 b.ne .Lcum_bad
 ldr x26,[x19]
 cbz x26,.Lcum_bad
 tst x26,#7
 b.ne .Lcum_bad
 adds x27,x26,x7
 b.cs .Lcum_bad
 /* The immutable owner record must be separate from its payload. */
 add x9,x19,#2176
 cmp x19,x27
 b.hs .Lcum_owner_separate
 cmp x9,x26
 b.hi .Lcum_bad
.Lcum_owner_separate:
 /* Metadata and the time-step word must not alias an output. */
 add x9,x1,#8
 cmp x1,x27
 b.hs .Lcum_time_separate
 cmp x9,x26
 b.hi .Lcum_bad
.Lcum_time_separate:
 add x9,x21,#16
 cmp x21,x27
 b.hs .Lcum_bounds_separate
 cmp x9,x26
 b.hi .Lcum_bad
.Lcum_bounds_separate:
 add x9,x20,#112
 cmp x20,x27
 b.hs .Lcum_bank_separate
 cmp x9,x26
 b.hi .Lcum_bad
.Lcum_bank_separate:
 ldrsw x4,[x21]
 cmp x4,#1
 b.lt .Lcum_bad
 cmp x4,#128
 b.gt .Lcum_bad
 lsl x22,x4,#3
 ldrsw x5,[x21,#4]
 cmp x5,#1
 b.lt .Lcum_bad
 add x8,x4,#1
 cmp x5,x8
 b.gt .Lcum_bad
 ldrsw x6,[x21,#8]
 tbnz x6,#63,.Lcum_bad
 cmp x6,x4
 b.gt .Lcum_bad
 ldrsw x7,[x21,#12]
 cmp x7,#1
 b.lt .Lcum_bad
 sub x23,x5,#1
 lsl x23,x23,#3
 sub x8,x7,#1
 add x8,x8,x5
 sub x8,x8,#1
 lsl x25,x8,#3
 sub x29,x6,x5
 add x29,x29,#1
 cmp x5,x6
 csel x29,x29,xzr,le
 cbz x29,.Lcum_global_ready
 add x8,x7,x6
 sub x8,x8,#1
 ldr x9,[x19,#24]
 cmp x8,x9
 b.hi .Lcum_bad
.Lcum_global_ready:
 /* Classify the time step as integer bits so refusals preserve FPSR. */
 ldr x4,[x1]
 tbz x4,#63,.Lcum_dt_nonnegative
 and x5,x4,#0x7fffffffffffffff
 cbnz x5,.Lcum_bad
.Lcum_dt_nonnegative:
 and x4,x4,#0x7fffffffffffffff
 movz x5,#0x1800,lsl#32
 movk x5,#0x40d5,lsl#48
 cmp x4,x5
 b.hi .Lcum_bad
 /* Admit all fourteen complete input spans before the first output write. */
 mov x4,#0
.Lcum_input_guard:
 ldr x9,[x20,x4,lsl#3]
 cbz x9,.Lcum_bad
 tst x9,#7
 b.ne .Lcum_bad
 adds x10,x9,x22
 b.cs .Lcum_bad
 cmp x9,x27
 b.hs .Lcum_input_separate
 cmp x10,x26
 b.hi .Lcum_bad
.Lcum_input_separate:
 add x4,x4,#1
 cmp x4,#14
 b.lo .Lcum_input_guard
 adrp x4,.Lcum_destination_offsets
 add x4,x4,:lo12:.Lcum_destination_offsets
 mov x5,#0
.Lcum_output_guard:
 ldrh w6,[x4,x5,lsl#1]
 ldr x9,[x19,x6]
 cbz x9,.Lcum_bad
 tst x9,#7
 b.ne .Lcum_bad
 cmp x9,x26
 b.lo .Lcum_bad
 adds x10,x9,x28
 b.cs .Lcum_bad
 cmp x10,x27
 b.hi .Lcum_bad
 add x5,x5,#1
 cmp x5,#11
 b.lo .Lcum_output_guard
 cbz x29,.Lcum_ok
 ldr d31,[x1]
.Lcum_loop:
 /* STRSU retains each original intermediate rounding. */
 ldr x9,[x19,#128]
 ldr d0,[x9,x25]
 ldr x10,[x20,#0]
 ldr d1,[x10,x23]
 fmul d1,d1,d31
 fadd d0,d0,d1
 str d0,[x9,x25]
 /* STRSV retains each original intermediate rounding. */
 ldr x9,[x19,#216]
 ldr d0,[x9,x25]
 ldr x10,[x20,#8]
 ldr d1,[x10,x23]
 fmul d1,d1,d31
 fadd d0,d0,d1
 str d0,[x9,x25]
 /* RUIST retains each original intermediate rounding. */
 ldr x9,[x19,#568]
 ldr d0,[x9,x25]
 ldr x10,[x20,#96]
 ldr d1,[x10,x23]
 ldr x10,[x20,#104]
 ldr d2,[x10,x23]
 fadd d1,d1,d2
 fmul d1,d1,d31
 fadd d0,d0,d1
 str d0,[x9,x25]
 /* FHUML retains each original intermediate rounding. */
 ldr x9,[x19,#920]
 ldr d0,[x9,x25]
 ldr x10,[x20,#64]
 ldr d1,[x10,x23]
 ldr x10,[x20,#80]
 ldr d2,[x10,x23]
 fadd d1,d1,d2
 fmul d1,d1,d31
 fadd d0,d0,d1
 str d0,[x9,x25]
 /* FHUMN retains each original intermediate rounding. */
 ldr x9,[x19,#1008]
 ldr d0,[x9,x25]
 ldr x10,[x20,#72]
 ldr d1,[x10,x23]
 ldr x10,[x20,#88]
 ldr d2,[x10,x23]
 fadd d1,d1,d2
 fmul d1,d1,d31
 fadd d0,d0,d1
 str d0,[x9,x25]
 /* FRSOS retains each original intermediate rounding. */
 ldr x9,[x19,#392]
 ldr d0,[x9,x25]
 ldr x10,[x20,#24]
 ldr d1,[x10,x23]
 fmul d1,d1,d31
 fadd d0,d0,d1
 str d0,[x9,x25]
 /* FCHLL retains each original intermediate rounding. */
 ldr x9,[x19,#656]
 ldr d0,[x9,x25]
 ldr x10,[x20,#32]
 ldr d1,[x10,x23]
 fmul d1,d1,d31
 fadd d0,d0,d1
 str d0,[x9,x25]
 /* FCHLN retains each original intermediate rounding. */
 ldr x9,[x19,#744]
 ldr d0,[x9,x25]
 ldr x10,[x20,#40]
 ldr d1,[x10,x23]
 fmul d1,d1,d31
 fadd d0,d0,d1
 str d0,[x9,x25]
 /* FCHSS retains each original intermediate rounding. */
 ldr x9,[x19,#832]
 ldr d0,[x9,x25]
 ldr x10,[x20,#48]
 ldr d1,[x10,x23]
 fmul d1,d1,d31
 fadd d0,d0,d1
 str d0,[x9,x25]
 /* FCHAS retains each original intermediate rounding. */
 ldr x9,[x19,#304]
 ldr d0,[x9,x25]
 ldr x10,[x20,#16]
 ldr d1,[x10,x23]
 ldr x10,[x20,#32]
 ldr d2,[x10,x23]
 fadd d1,d1,d2
 ldr x10,[x20,#40]
 ldr d2,[x10,x23]
 fadd d1,d1,d2
 ldr x10,[x20,#48]
 ldr d2,[x10,x23]
 fadd d1,d1,d2
 fmul d1,d1,d31
 fadd d0,d0,d1
 str d0,[x9,x25]
 /* FHUMS retains each original intermediate rounding. */
 ldr x9,[x19,#480]
 ldr d0,[x9,x25]
 ldr x10,[x20,#64]
 ldr d1,[x10,x23]
 ldr x10,[x20,#72]
 ldr d2,[x10,x23]
 fadd d1,d1,d2
 ldr x10,[x20,#80]
 ldr d2,[x10,x23]
 fadd d1,d1,d2
 ldr x10,[x20,#88]
 ldr d2,[x10,x23]
 fadd d1,d1,d2
 ldr x10,[x20,#56]
 ldr d2,[x10,x23]
 fadd d1,d1,d2
 fmul d1,d1,d31
 fadd d0,d0,d1
 str d0,[x9,x25]
 add x23,x23,#8
 add x25,x25,#8
 subs x29,x29,#1
 b.ne .Lcum_loop
.Lcum_ok:
 mov w0,#0
 b .Lcum_return
.Lcum_bad:
 mov w0,#2
.Lcum_return:
 ldp x19,x20,[sp]
 ldp x21,x22,[sp,#16]
 ldp x23,x24,[sp,#32]
 ldp x25,x26,[sp,#48]
 ldp x27,x28,[sp,#64]
 ldp x29,x30,[sp,#80]
 add sp,sp,#96
 ret
.Lcum_bad_entry:
 mov w0,#2
 ret
.size md2asm_accumulate_runtime_coupled_surface_fluxes,.-md2asm_accumulate_runtime_coupled_surface_fluxes
.section .rodata
.p2align 1
.Lcum_destination_offsets:
 .hword 128,216,568,920,1008,392,656,744,832,304,480
.section .note.GNU-stack,"",%progbits

/* SPCMASCOR ordered pressure correction with explicit source data.
 * Physics formulations/openifs/dynamics/spectral_pressure_mass_correction.md.
 * Contract skills/md2asm/references/openifs/dynamics/spectral_pressure_mass_correction.md.
 * Original TLAP, TDYN and pressure descriptor argument positions. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_runtime_spectral_pressure_mass_correction
.type md2asm_runtime_spectral_pressure_mass_correction,%function
md2asm_runtime_spectral_pressure_mass_correction:
 cbz x0,.Lsm_bad
 cbz x1,.Lsm_bad
 cbz x2,.Lsm_bad
 orr x3,x0,x1
 orr x3,x3,x2
 tst x3,#7
 b.ne .Lsm_bad
 mrs x3,fpcr
 cbnz x3,.Lsm_bad
 adds x3,x0,#576
 b.cs .Lsm_bad
 mov x4,#4624
 adds x4,x1,x4
 b.cs .Lsm_bad
 adds x5,x2,#64
 b.cs .Lsm_bad
 /* Read-only records and the descriptor remain separate. */
 cmp x0,x4
 b.hs .Lsm_r01
 cmp x1,x3
 b.lo .Lsm_bad
.Lsm_r01:
 cmp x0,x5
 b.hs .Lsm_r02
 cmp x2,x3
 b.lo .Lsm_bad
.Lsm_r02:
 cmp x1,x5
 b.hs .Lsm_r12
 cmp x2,x4
 b.lo .Lsm_bad
.Lsm_r12:
 add x6,x0,#64
 ldr x7,[x6]
 cbz x7,.Lsm_bad
 tst x7,#3
 b.ne .Lsm_bad
 ldr x8,[x6,#8]
 cbnz x8,.Lsm_bad
 ldr x8,[x6,#16]
 cmp x8,#4
 b.ne .Lsm_bad
 ldr x8,[x6,#24]
 movz x9,#0x0101,lsl#32
 cmp x8,x9
 b.ne .Lsm_bad
 ldr x8,[x6,#32]
 cmp x8,#4
 b.ne .Lsm_bad
 ldr x8,[x6,#40]
 cmp x8,#1
 b.ne .Lsm_bad
 ldr x8,[x6,#48]
 cbnz x8,.Lsm_bad
 ldr x8,[x6,#56]
 mov x17,#8191
 cmp x8,x17
 b.hi .Lsm_bad
 add x8,x8,#1
 adds x8,x7,x8,lsl#2
 b.cs .Lsm_bad
 ldr x9,[x2]
 cbz x9,.Lsm_bad
 tst x9,#7
 b.ne .Lsm_bad
 ldr x10,[x2,#8]
 cmn x10,#1
 b.ne .Lsm_bad
 ldr x10,[x2,#16]
 cmp x10,#8
 b.ne .Lsm_bad
 ldr x10,[x2,#24]
 movz x11,#0x0301,lsl#32
 cmp x10,x11
 b.ne .Lsm_bad
 ldr x10,[x2,#32]
 cmp x10,#8
 b.ne .Lsm_bad
 ldr x10,[x2,#40]
 cmp x10,#1
 b.ne .Lsm_bad
 ldr x10,[x2,#48]
 cmp x10,#1
 b.ne .Lsm_bad
 ldr x10,[x2,#56]
 sub x11,x10,#1
 mov x12,#0x8000000
 cmp x11,x12
 b.hs .Lsm_bad
 adds x11,x9,x10,lsl#3
 b.cs .Lsm_bad
 /* Numerical payload is separate from metadata and map. */
 cmp x9,x3
 b.hs .Lsm_p0
 cmp x0,x11
 b.lo .Lsm_bad
.Lsm_p0:
 cmp x9,x4
 b.hs .Lsm_p1
 cmp x1,x11
 b.lo .Lsm_bad
.Lsm_p1:
 cmp x9,x5
 b.hs .Lsm_p2
 cmp x2,x11
 b.lo .Lsm_bad
.Lsm_p2:
 cmp x9,x8
 b.hs .Lsm_pm
 cmp x7,x11
 b.lo .Lsm_bad
.Lsm_pm:
 ldrsw x12,[x7]
 cmp x12,#1
 b.lt .Lsm_bad
 cmp x12,x10
 b.gt .Lsm_bad
 sub x12,x12,#1
 add x9,x9,x12,lsl#3
 mov x10,#4616
 ldr d0,[x9]
 ldr d1,[x1,x10]
 fsub d0,d0,d1
 str d0,[x9]
 mov w0,#0
 ret
.Lsm_bad:
 mov w0,#2
 ret
.size md2asm_runtime_spectral_pressure_mass_correction,.-md2asm_runtime_spectral_pressure_mass_correction
.section .note.GNU-stack,"",%progbits

/* Publish the source CNT4 current step into two actual owned clocks.
 * x0 cfg67616, x1 capacity, x2 caller KSTEP4; return0/2.
 * The global alias names owned_clock+36, not the distinct cfg+51772.
 * Contract: skills/md2asm/references/openifs/setup/operational_step_clock_publication.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_publish_operational_convection_step
.type md2asm_publish_operational_convection_step,%function
md2asm_publish_operational_convection_step:
 cbz x0,.Lstep_bad
 cbz x2,.Lstep_bad
 tst x0,#7
 b.ne .Lstep_bad
 tst x2,#3
 b.ne .Lstep_bad
 mov x9,#(67616&65535)
 movk x9,#(67616>>16),lsl#16
 cmp x1,x9
 b.lo .Lstep_bad
 adds x4,x0,x9
 b.cs .Lstep_bad
 adds x5,x2,#4
 b.cs .Lstep_bad
 cmp x2,x4
 b.hs .Lstep_cfg_separate
 cmp x0,x5
 b.lo .Lstep_bad
.Lstep_cfg_separate:
 adrp x3,:got:md2asm_owned_runtime_convection_clock
 ldr x3,[x3,:got_lo12:md2asm_owned_runtime_convection_clock]
 add x6,x3,#360
 cmp x0,x6
 b.hs .Lstep_clock_cfg_separate
 cmp x3,x4
 b.lo .Lstep_bad
.Lstep_clock_cfg_separate:
 cmp x2,x6
 b.hs .Lstep_clock_input_separate
 cmp x3,x5
 b.lo .Lstep_bad
.Lstep_clock_input_separate:
 mrs x9,fpcr
 cbnz x9,.Lstep_bad
 ldr x9,[x0,#24]
 mov w10,#0x4346
 movk w10,#0x4731,lsl#16
 cmp x9,x10
 b.ne .Lstep_bad
 ldr x9,[x0]
 ldr x10,[x0,#16]
 cbz x9,.Lstep_bad
 cbz x10,.Lstep_bad
 tst x9,#7
 b.ne .Lstep_bad
 tst x10,#7
 b.ne .Lstep_bad
 ldr x11,[x9,#8]
 cmp x11,x10
 b.ne .Lstep_bad
 mov x10,#35688
 ldr w11,[x0,x10]
 cmp w11,#1
 b.ne .Lstep_bad
 mov x10,#51760
 ldr w11,[x0,x10]
 cmp w11,#8
 b.ne .Lstep_bad
 movz x12,#0x407c,lsl#48
 movk x12,#0x2000,lsl#32
 mov x10,#51704
 ldr x11,[x0,x10]
 cmp x11,x12
 b.ne .Lstep_bad
 mov x10,#(1359528&65535)
 movk x10,#(1359528>>16),lsl#16
 ldr x11,[x9,x10]
 cmp x11,x12
 b.ne .Lstep_bad
 ldr x11,[x3,#40]
 cmp x11,x12
 b.ne .Lstep_bad
 ldr w7,[x2]
 cmp w7,#8
 b.hi .Lstep_bad
 mov x10,#51736
 add x8,x0,x10
 mov x9,#0
.Lstep_compare_first:
 ldr x10,[x8,x9]
 ldr x11,[x3,x9]
 cmp x10,x11
 b.ne .Lstep_bad
 add x9,x9,#8
 cmp x9,#32
 b.lo .Lstep_compare_first
 ldr w10,[x8,#32]
 ldr w11,[x3,#32]
 cmp w10,w11
 b.ne .Lstep_bad
 mov x9,#40
.Lstep_compare_tail:
 ldr x10,[x8,x9]
 ldr x11,[x3,x9]
 cmp x10,x11
 b.ne .Lstep_bad
 add x9,x9,#8
 cmp x9,#360
 b.lo .Lstep_compare_tail
 str w7,[x8,#36]
 str w7,[x3,#36]
 mov w0,#0
 ret
.Lstep_bad:
 mov w0,#2
 ret
.size md2asm_publish_operational_convection_step,.-md2asm_publish_operational_convection_step
.bss
.p2align 4
.global md2asm_owned_runtime_convection_clock
.type md2asm_owned_runtime_convection_clock,%object
md2asm_owned_runtime_convection_clock:.zero 360
.size md2asm_owned_runtime_convection_clock,360
.global __yomct3_MOD_nstep
.type __yomct3_MOD_nstep,%object
.set __yomct3_MOD_nstep,md2asm_owned_runtime_convection_clock+36
.size __yomct3_MOD_nstep,4
#ifdef MD2ASM_CANONICAL_INITIAL_CLOCK_ALIASES
/* The selected namespace keeps date, seconds and step in this same owner. */
.global __yomrip0_MOD_nindat
.type __yomrip0_MOD_nindat,%object
.set __yomrip0_MOD_nindat,md2asm_owned_runtime_convection_clock
.size __yomrip0_MOD_nindat,4
.global __yomrip0_MOD_nsssss
.type __yomrip0_MOD_nsssss,%object
.set __yomrip0_MOD_nsssss,md2asm_owned_runtime_convection_clock+4
.size __yomrip0_MOD_nsssss,4
#endif
.section .note.GNU-stack,"",%progbits

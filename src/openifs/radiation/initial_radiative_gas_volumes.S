/* Contract: skills/md2asm/references/openifs/surface/runtime_surface_turbulence.md.
 * The entry publishes only the selected source words and returns 0 or 2.
 * No stack, allocation or floating-point operation is used. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_initial_radiative_gas_volumes
.type md2asm_initialize_initial_radiative_gas_volumes,%function
md2asm_initialize_initial_radiative_gas_volumes:
 cbz x0,.Lgas_bad
 tst x0,#7
 b.ne .Lgas_bad
 movz x9,#(4275088&65535)
 movk x9,#(4275088>>16),lsl#16
 cmp x1,x9
 b.lo .Lgas_bad
 adds x9,x0,x9
 b.cs .Lgas_bad
 cbnz w2,.Lgas_bad
 movz x9,#(1856504&65535)
 movk x9,#(1856504>>16),lsl#16
 add x9,x0,x9
 mov x10,#0
.Lgas_check:
 ldr x11,[x9,x10]
 cbnz x11,.Lgas_bad
 add x10,x10,#8
 cmp x10,#64
 b.lo .Lgas_check
 adrp x10,.Lgas_literals
 add x10,x10,:lo12:.Lgas_literals
 ldp x11,x12,[x10]
 stp x11,x12,[x9]
 ldp x11,x12,[x10,#16]
 stp x11,x12,[x9,#16]
 ldp x11,x12,[x10,#32]
 stp x11,x12,[x9,#32]
 ldp x11,x12,[x10,#48]
 stp x11,x12,[x9,#48]
 mov w0,#0
 ret
.Lgas_bad:
 mov w0,#2
 ret
.size md2asm_initialize_initial_radiative_gas_volumes,.-md2asm_initialize_initial_radiative_gas_volumes
.section .rodata
.p2align 3
.Lgas_literals:
 .xword 0x3f37225b749adc90,0x3ebcdb57fff13c6e
 .xword 0x3e94cdc26b1f07d8,0x3dcb7cdfd9d7bdbb
 .xword 0x3df33dcfe54a3803,0x3e00a14f1c1d6744
 .xword 0,0
.section .note.GNU-stack,"",%progbits

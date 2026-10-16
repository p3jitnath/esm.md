/* Contract: skills/md2asm/references/openifs/runtime/initial_input_data_bindings.md.
 * x0: four read-only address/capacity pairs; return0 complete or2 before mutation.
 * Bind actual owned header/vertical/atmosphere values; no original module input.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_bind_initial_input_data
.type md2asm_bind_initial_input_data,%function
md2asm_bind_initial_input_data:
 cbz x0,.Linitial_input_bad
 tst x0,#7
 b.ne .Linitial_input_bad
 adds x9,x0,#64
 b.cs .Linitial_input_bad
 adrp x8,md2asm_owned_initial_input_data
 add x8,x8,:lo12:md2asm_owned_initial_input_data
 add x10,x8,#24
 cmp x0,x10
 b.hs 1f
 cmp x8,x9
 b.lo .Linitial_input_bad
1:
 adrp x11,.Linitial_input_extents
 add x11,x11,:lo12:.Linitial_input_extents
 mov x12,#0
.Linitial_input_ranges:
 ldp x13,x14,[x0]
 cbz x13,.Linitial_input_bad
 tst x13,#7
 b.ne .Linitial_input_bad
 ldr x15,[x11,x12]
 cmp x14,x15
 b.lo .Linitial_input_bad
 adds x16,x13,x15
 b.cs .Linitial_input_bad
 cmp x13,x10
 b.hs 2f
 cmp x8,x16
 b.lo .Linitial_input_bad
2:
 add x0,x0,#16
 add x12,x12,#8
 cmp x12,#32
 b.lo .Linitial_input_ranges
 sub x0,x0,#64
 ldr x1,[x0]
 ldr x2,[x0,#16]
 ldr x3,[x0,#32]
 ldr x4,[x0,#48]
 ldr x9,[x3]
 cmp x9,x2
 b.ne .Linitial_input_bad
 ldr w9,[x2,#5224]
 cmp w9,#19
 b.ne .Linitial_input_bad
 mov x9,#35104
 ldr w9,[x4,x9]
 cmp w9,#1
 b.ne .Linitial_input_bad
 mov x9,#39520
 ldr w9,[x4,x9]
 cmp w9,#1
 b.ne .Linitial_input_bad
 ldp w5,w6,[x1,#28]
 cmp w5,#1
 b.ne .Linitial_input_bad
 cmp w6,#0
 b.le .Linitial_input_bad
 ldr w7,[x3,#1856]
 sub w9,w7,#1
 cmp w9,#18
 b.hi .Linitial_input_bad
 mov x9,#20328
 ldr x9,[x2,x9]
 tbnz x9,#63,.Linitial_input_bad
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Linitial_input_bad
 stp w5,w6,[x8]
 stp wzr,w7,[x8,#8]
 str x9,[x8,#16]
 mov w0,#0
 ret
.Linitial_input_bad:
 mov w0,#2
 ret
.size md2asm_bind_initial_input_data,.-md2asm_bind_initial_input_data
.section .rodata
.p2align 3
.Linitial_input_extents: .quad 5232,20400,1872,51512
.section .bss
.p2align 3
.global md2asm_owned_initial_input_data
.type md2asm_owned_initial_input_data,%object
md2asm_owned_initial_input_data: .skip 24
.size md2asm_owned_initial_input_data,24
.macro INITIAL_ALIAS name,off,bytes
.global \name
.type \name,%object
.set \name,md2asm_owned_initial_input_data+\off
.size \name,\bytes
.endm
INITIAL_ALIAS __yomarg_MOD_ngribfile,0,4
INITIAL_ALIAS __yomarg_MOD_nudate,4,4
INITIAL_ALIAS __yomct0_MOD_nstepini,8,4
INITIAL_ALIAS __yomsta_MOD_nlextrap,12,4
INITIAL_ALIAS __yomvert_MOD_toppres,16,8
.section .note.GNU-stack,"",%progbits

/* Complete selected GPCTY from the frozen vertical-continuity contract.
 * Physics: formulations/openifs/dynamics/vertical_continuity.md.
 * Contract: skills/md2asm/references/openifs/dynamics/vertical_continuity.md.
 * Nineteen ordinary pointers retain full explicit array owners and null PEVT.
 * Every pressure and velocity stage is native; the direct child is unchanged.
 */
.arch armv8.2-a+simd
.text
.p2align 4
.macro arg reg,index
 ldr \reg,[sp,#(64+8*\index)]
.endm
.macro bounded address,mode=0
 ldr x10,[\address]
 ubfx x11,x10,#52,#11
 cmp x11,#1151
 b.hs .Lunsupported
.if \mode == 1
 tbnz x10,#63,.Lunsupported
 cbz x10,.Lunsupported
.elseif \mode == 2
 tbz x10,#63,91f
 and x11,x10,#0x7fffffffffffffff
 cbnz x11,.Lunsupported
91:
.endif
.endm
.macro descriptor_one slot
 ldr x9,[x0,#8]
 cmn x9,#1
 b.ne .Lunsupported
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lunsupported
 ldrb w9,[x0,#28]
 cmp w9,#1
 b.ne .Lunsupported
 ldrb w9,[x0,#29]
 cmp w9,#3
 b.ne .Lunsupported
 ldr x9,[x0,#32]
 cmp x9,#8
 b.ne .Lunsupported
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Lunsupported
 ldr x9,[x0,#48]
 cmp x9,#1
 b.ne .Lunsupported
 ldr x9,[x0,#56]
 cmp x9,#19
 b.ne .Lunsupported
 ldr x13,[x0]
 cbz x13,.Lunsupported
 tst x13,#7
 b.ne .Lunsupported
 str x13,[sp,#\slot]
.endm
/* x0 and x1 name an input interval; x26 and x27 bound the complete output. */
.macro disjoint
 cbz x0,.Lunsupported
 add x9,x0,x1
 cmp x26,x9
 b.hs 92f
 cmp x0,x27
 b.lo .Lunsupported
92:
.endm
.global md2asm_gpcty_7259755
.type md2asm_gpcty_7259755,%function
md2asm_gpcty_7259755:
 mov x16,sp
 sub sp,sp,#640
 stp x0,x1,[sp,#64]
 stp x2,x3,[sp,#80]
 stp x4,x5,[sp,#96]
 stp x6,x7,[sp,#112]
 add x9,sp,#128
 mov x10,#11
.Larguments:
 ldr x11,[x16],#8
 str x11,[x9],#8
 subs x10,x10,#1
 b.ne .Larguments
 add x9,sp,#320
 stp x19,x20,[x9,#0]
 stp x21,x22,[x9,#16]
 stp x23,x24,[x9,#32]
 stp x25,x26,[x9,#48]
 stp x27,x28,[x9,#64]
 stp x29,x30,[x9,#80]
 stp d8,d9,[x9,#96]
 stp d10,d11,[x9,#112]
 stp d12,d13,[x9,#128]
 stp d14,d15,[x9,#144]
 str x18,[sp,#480]
 mrs x9,fpcr
 cbnz x9,.Lunsupported
 arg x9,0
 cbz x9,.Lunsupported
 arg x9,1
 cbz x9,.Lunsupported
 arg x9,2
 cbz x9,.Lunsupported
 arg x9,3
 cbz x9,.Lunsupported
 arg x9,4
 cbz x9,.Lunsupported
 arg x9,5
 cbz x9,.Lunsupported
 arg x9,6
 cbz x9,.Lunsupported
 arg x9,7
 cbz x9,.Lunsupported
 arg x9,8
 cbz x9,.Lunsupported
 arg x9,9
 cbz x9,.Lunsupported
 arg x9,10
 cbz x9,.Lunsupported
 arg x9,11
 cbz x9,.Lunsupported
 arg x9,13
 cbz x9,.Lunsupported
 arg x9,14
 cbz x9,.Lunsupported
 arg x9,15
 cbz x9,.Lunsupported
 arg x9,16
 cbz x9,.Lunsupported
 arg x9,17
 cbz x9,.Lunsupported
 arg x19,0
 arg x20,1
 arg x9,2
 ldr w21,[x9]
 cmp w21,#1
 b.lt .Lunsupported
 cmp w21,#256
 b.gt .Lunsupported
 arg x9,5
 ldr w10,[x9]
 cmp w10,#19
 b.ne .Lunsupported
 arg x9,3
 ldr w22,[x9]
 cmp w22,#1
 b.lt .Lunsupported
 cmp w22,w21
 b.gt .Lunsupported
 sub w22,w22,#1
 arg x9,4
 ldr w23,[x9]
 cmp w23,w22
 b.lt .Lunsupported
 cmp w23,w21
 b.gt .Lunsupported
 arg x9,6
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 ldr w10,[x20,#52]
 cmp w10,#1
 b.ne .Lunsupported
 ldr w10,[x20,#36]
 cmp w10,#3
 b.ne .Lunsupported
 lsl x24,x21,#3
 mov x10,#20
 mul x10,x10,x24
 str x10,[sp,#304]
 arg x26,17
 mov x11,#5
 mul x11,x10,x11
 add x27,x26,x11
 tst x26,#7
 b.ne .Lunsupported
 adrp x0,:got:__intdyn_mod_MOD_yytxyb
 ldr x0,[x0,:got_lo12:__intdyn_mod_MOD_yytxyb]
 mov x1,#32
 disjoint
 ldr w9,[x0,#0]
 cmp w9,#1
 b.ne .Lunsupported
 ldr w9,[x0,#4]
 cmp w9,#2
 b.ne .Lunsupported
 ldr w9,[x0,#8]
 cmp w9,#3
 b.ne .Lunsupported
 ldr w9,[x0,#12]
 cmp w9,#4
 b.ne .Lunsupported
 ldr w9,[x0,#16]
 cmp w9,#5
 b.ne .Lunsupported
 ldr w9,[x0,#20]
 cmp w9,#6
 b.ne .Lunsupported
 ldr w9,[x0,#24]
 cmp w9,#7
 b.ne .Lunsupported
 ldr w9,[x0,#28]
 cmp w9,#7
 b.ne .Lunsupported
 adrp x0,:got:__intdyn_mod_MOD_yytcty
 ldr x0,[x0,:got_lo12:__intdyn_mod_MOD_yytcty]
 mov x1,#24
 disjoint
 ldr w9,[x0,#0]
 cmp w9,#1
 b.ne .Lunsupported
 ldr w9,[x0,#4]
 cmp w9,#2
 b.ne .Lunsupported
 ldr w9,[x0,#8]
 cmp w9,#3
 b.ne .Lunsupported
 ldr w9,[x0,#12]
 cmp w9,#4
 b.ne .Lunsupported
 ldr w9,[x0,#16]
 cmp w9,#5
 b.ne .Lunsupported
 ldr w9,[x0,#20]
 cmp w9,#5
 b.ne .Lunsupported
 arg x0,7
 add x0,x0,#320
 descriptor_one 504
 arg x0,7
 add x0,x0,#448
 descriptor_one 512
 arg x0,8
 add x0,x0,#256
 descriptor_one 520
 add x0,x19,#240
 ldr x9,[x0,#8]
 cmn x9,#21
 b.ne .Lunsupported
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lunsupported
 ldrb w9,[x0,#28]
 cmp w9,#2
 b.ne .Lunsupported
 ldrb w9,[x0,#29]
 cmp w9,#3
 b.ne .Lunsupported
 ldr x9,[x0,#32]
 cmp x9,#8
 b.ne .Lunsupported
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Lunsupported
 ldr x9,[x0,#48]
 cmp x9,#1
 b.ne .Lunsupported
 ldr x9,[x0,#56]
 cmp x9,#20
 b.ne .Lunsupported
 ldr x9,[x0,#64]
 cmp x9,#20
 b.ne .Lunsupported
 ldr x9,[x0,#72]
 cmp x9,#1
 b.ne .Lunsupported
 ldr x9,[x0,#80]
 cmp x9,#21
 b.ne .Lunsupported
 ldr x13,[x0]
 cbz x13,.Lunsupported
 tst x13,#7
 b.ne .Lunsupported
 str x13,[sp,#528]
 arg x0,0
 mov x1,#2176
 disjoint
 arg x0,1
 mov x1,#216
 disjoint
 arg x0,2
 mov x1,#4
 disjoint
 arg x0,3
 mov x1,#4
 disjoint
 arg x0,4
 mov x1,#4
 disjoint
 arg x0,5
 mov x1,#4
 disjoint
 arg x0,6
 mov x1,#4
 disjoint
 arg x0,7
 mov x1,#512
 disjoint
 arg x0,8
 mov x1,#320
 disjoint
 arg x0,9
 mov x1,#19
 mul x1,x1,x24
 tst x0,#7
 b.ne .Lunsupported
 disjoint
 arg x0,10
 mov x1,#19
 mul x1,x1,x24
 tst x0,#7
 b.ne .Lunsupported
 disjoint
 arg x0,11
 mov x1,#19
 mul x1,x1,x24
 tst x0,#7
 b.ne .Lunsupported
 disjoint
 arg x0,13
 mov x1,#133
 mul x1,x1,x24
 tst x0,#7
 b.ne .Lunsupported
 disjoint
 arg x0,14
 mov x1,x24
 tst x0,#7
 b.ne .Lunsupported
 disjoint
 arg x0,15
 mov x1,x24
 tst x0,#7
 b.ne .Lunsupported
 disjoint
 arg x0,16
 mov x1,#19
 mul x1,x1,x24
 tst x0,#7
 b.ne .Lunsupported
 disjoint
 arg x0,18
 cbz x0,.Loptional_disjoint_done
 mov x1,#19
 mul x1,x1,x24
 tst x0,#7
 b.ne .Lunsupported
 disjoint
.Loptional_disjoint_done:
 ldr x0,[sp,#504]
 mov x1,#152
 disjoint
 ldr x0,[sp,#512]
 mov x1,#152
 disjoint
 ldr x0,[sp,#520]
 mov x1,#152
 disjoint
 ldr x0,[sp,#528]
 mov x1,#3360
 disjoint
 /* Validate all supplied table entries before public output can change. */
 ldr x12,[sp,#528]
 mov x14,#420
.Lmatrix_inputs:
 bounded x12
 add x12,x12,#8
 subs x14,x14,#1
 b.ne .Lmatrix_inputs
 mov x27,#0
.Lpreflight_level:
 ldr x9,[sp,#504]
 add x9,x9,x27,lsl #3
 bounded x9
 ldr x9,[sp,#512]
 add x9,x9,x27,lsl #3
 bounded x9,2
 ldr x9,[sp,#520]
 add x9,x9,x27,lsl #3
 bounded x9,1
 mul x29,x27,x24
 mov x28,x22
.Lpreflight_column:
 cmp x28,x23
 b.ge .Lpreflight_next
 add x12,x29,x28,lsl #3
 arg x9,9
 add x9,x9,x12
 bounded x9,0
 arg x9,10
 add x9,x9,x12
 bounded x9,0
 arg x9,11
 add x9,x9,x12
 bounded x9,0
 arg x9,13
 add x9,x9,x12
 bounded x9,1
 arg x9,16
 add x9,x9,x12
 bounded x9,1
 arg x9,14
 add x9,x9,x28,lsl #3
 bounded x9
 arg x9,15
 add x9,x9,x28,lsl #3
 bounded x9
 arg x9,18
 cbz x9,.Lpreflight_optional_done
 add x9,x9,x12
 bounded x9
.Lpreflight_optional_done:
 add x28,x28,#1
 b .Lpreflight_column
.Lpreflight_next:
 add x27,x27,#1
 cmp x27,#19
 b.lt .Lpreflight_level
 bl __errno_location
 str x0,[sp,#488]
 ldr w9,[x0]
 str w9,[sp,#496]
 mov x9,#79
 mul x0,x9,x24
 bl malloc
 cbz x0,.Lunsupported
 mov x25,x0
 str x25,[sp,#224]
 str x25,[sp,#232]
 mov x9,#19
 mul x9,x9,x24
 add x10,x25,x9
 str x10,[sp,#240]
 add x10,x10,x9
 str x10,[sp,#248]
 mov x9,#21
 mul x9,x9,x24
 add x10,x10,x9
 str x10,[sp,#256]
 /* Complete wind transport, with both products rounded separately. */
 mov x27,#0
.Lwind_level:
 mul x29,x27,x24
 mov x28,x22
.Lwind_column:
 cmp x28,x23
 b.ge .Lwind_next
 add x12,x29,x28,lsl #3
 arg x9,9
 ldr d0,[x9,x12]
 arg x9,14
 ldr d1,[x9,x28,lsl #3]
 fmul d0,d0,d1
 arg x9,10
 ldr d2,[x9,x12]
 arg x9,15
 ldr d3,[x9,x28,lsl #3]
 fmul d2,d2,d3
 fadd d0,d0,d2
 str d0,[x25,x12]
 add x28,x28,#1
 b .Lwind_column
.Lwind_next:
 add x27,x27,#1
 cmp x27,#19
 b.lt .Lwind_level
 /* Complete layer pressure-divergence rate and its optional mass source. */
 mov x27,#0
.Ldivergence_level:
 mul x29,x27,x24
 ldr x9,[sp,#512]
 ldr d4,[x9,x27,lsl #3]
 mov x28,x22
.Ldivergence_column:
 cmp x28,x23
 b.ge .Ldivergence_next
 add x12,x29,x28,lsl #3
 arg x9,11
 ldr d0,[x9,x12]
 arg x9,13
 ldr d1,[x9,x12]
 fmul d0,d0,d1
 ldr d2,[x25,x12]
 fmul d2,d4,d2
 fadd d0,d0,d2
 arg x9,18
 cbz x9,.Ldivergence_source_done
 ldr d3,[x9,x12]
 fmul d3,d3,d1
 fsub d0,d0,d3
.Ldivergence_source_done:
 ldr x9,[sp,#240]
 str d0,[x9,x12]
 add x28,x28,#1
 b .Ldivergence_column
.Ldivergence_next:
 add x27,x27,#1
 cmp x27,#19
 b.lt .Ldivergence_level
 /* Scale every layer, then set both complete active integration boundaries. */
 mov x27,#0
.Lscale_level:
 mul x29,x27,x24
 ldr x9,[sp,#520]
 ldr d1,[x9,x27,lsl #3]
 mov x28,x22
.Lscale_column:
 cmp x28,x23
 b.ge .Lscale_next
 add x12,x29,x28,lsl #3
 ldr x9,[sp,#240]
 ldr d0,[x9,x12]
 fmul d0,d0,d1
 add x12,x12,x24
 ldr x9,[sp,#248]
 str d0,[x9,x12]
 add x28,x28,#1
 b .Lscale_column
.Lscale_next:
 add x27,x27,#1
 cmp x27,#19
 b.lt .Lscale_level
 ldr x9,[sp,#248]
 mov x10,#20
 mul x10,x10,x24
 add x10,x9,x10
 mov x28,x22
.Lboundary_input:
 cmp x28,x23
 b.ge .Lchild_arguments
 str xzr,[x9,x28,lsl #3]
 str xzr,[x10,x28,lsl #3]
 add x28,x28,#1
 b .Lboundary_input
.Lchild_arguments:
 mov x0,x19
 mov x1,x20
 adrp x2,.Litop
 add x2,x2,:lo12:.Litop
 adrp x3,.Lboth_boundaries
 add x3,x3,:lo12:.Lboth_boundaries
 arg x4,2
 arg x5,3
 arg x6,4
 arg x7,5
 ldr x9,[sp,#248]
 str x9,[sp,#0]
 ldr x9,[sp,#256]
 str x9,[sp,#8]
 stp xzr,xzr,[sp,#16]
 mov x9,#4
 str x9,[sp,#32]
 mov x9,#2
 str x9,[sp,#40]
 bl md2asm_gpcty_private_verdisint
 /* I and q are complete before any public output transfer. */
 mov x27,#0
.Loutput_level:
 mul x29,x27,x24
 ldr x9,[sp,#504]
 ldr d1,[x9,x27,lsl #3]
 mov x28,x22
.Loutput_column:
 cmp x28,x23
 b.ge .Loutput_next
 add x12,x29,x28,lsl #3
 ldr x9,[sp,#256]
 ldr d0,[x9,x12]
 mov x10,#19
 mul x10,x10,x24
 add x10,x10,x28,lsl #3
 ldr d2,[x9,x10]
 fmul d5,d1,d2
 fsub d5,d5,d0
 ldr d3,[x25,x12]
 fmul d6,d1,d3
 fneg d7,d0
 fadd d6,d7,d6
 arg x9,16
 ldr d4,[x9,x12]
 fmul d6,d6,d4
 add x13,x12,x24
 add x13,x26,x13
 str d5,[x13]
 ldr x14,[sp,#304]
 add x13,x13,x14
 str d6,[x13]
 add x13,x13,x14
 str d0,[x13]
 add x13,x13,x14
 sub x13,x13,x24
 str xzr,[x13]
 add x13,x13,x24
 add x13,x13,x14
 ldr x9,[sp,#240]
 ldr x10,[x9,x12]
 str x10,[x13]
 add x28,x28,#1
 b .Loutput_column
.Loutput_next:
 add x27,x27,#1
 cmp x27,#19
 b.lt .Loutput_level
 mov x28,x22
.Lfinal_boundary:
 cmp x28,x23
 b.ge .Lrelease
 str xzr,[x26,x28,lsl #3]
 ldr x14,[sp,#304]
 add x9,x26,x14,lsl #1
 str xzr,[x9,x28,lsl #3]
 mov x10,#19
 mul x10,x10,x24
 add x10,x10,x28,lsl #3
 ldr x9,[sp,#256]
 ldr x11,[x9,x10]
 add x9,x26,x14
 add x9,x9,x14,lsl #1
 str x11,[x9,x10]
 add x28,x28,#1
 b .Lfinal_boundary
.Lrelease:
 mov x0,x25
 bl free
 ldr x9,[sp,#488]
 ldr w10,[sp,#496]
 str w10,[x9]
 adrp x9,.Lparent_calls
 add x9,x9,:lo12:.Lparent_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 add x9,sp,#320
 ldp x19,x20,[x9,#0]
 ldp x21,x22,[x9,#16]
 ldp x23,x24,[x9,#32]
 ldp x25,x26,[x9,#48]
 ldp x27,x28,[x9,#64]
 ldp x29,x30,[x9,#80]
 ldp d8,d9,[x9,#96]
 ldp d10,d11,[x9,#112]
 ldp d12,d13,[x9,#128]
 ldp d14,d15,[x9,#144]
 ldr x18,[sp,#480]
 add sp,sp,#640
 ret
.Lunsupported:
 bl abort
 brk #0
.size md2asm_gpcty_7259755,.-md2asm_gpcty_7259755

/* A completed-return counter surrounds the unchanged complete private child. */
.p2align 4
.global md2asm_gpcty_private_verdisint
.hidden md2asm_gpcty_private_verdisint
.type md2asm_gpcty_private_verdisint,%function
md2asm_gpcty_private_verdisint:
 mov x16,sp
 sub sp,sp,#64
 stp x18,x30,[sp,#48]
 ldp x9,x10,[x16]
 stp x9,x10,[sp]
 ldp x9,x10,[x16,#16]
 stp x9,x10,[sp,#16]
 ldp x9,x10,[x16,#32]
 stp x9,x10,[sp,#32]
 bl md2asm_gpcty_private_verdisint_body
 adrp x9,.Lchild_calls
 add x9,x9,:lo12:.Lchild_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldp x18,x30,[sp,#48]
 add sp,sp,#64
 ret
.size md2asm_gpcty_private_verdisint,.-md2asm_gpcty_private_verdisint

.global md2asm_gpcty_calls_get
.type md2asm_gpcty_calls_get,%function
md2asm_gpcty_calls_get:
 adrp x9,.Lparent_calls
 add x9,x9,:lo12:.Lparent_calls
 ldr x0,[x9]
 ret
.size md2asm_gpcty_calls_get,.-md2asm_gpcty_calls_get
.global md2asm_gpcty_child_calls_get
.type md2asm_gpcty_child_calls_get,%function
md2asm_gpcty_child_calls_get:
 adrp x9,.Lchild_calls
 add x9,x9,:lo12:.Lchild_calls
 ldr x0,[x9]
 ret
.size md2asm_gpcty_child_calls_get,.-md2asm_gpcty_child_calls_get
.section .rodata
.Litop: .ascii "ITOP"
.Lboth_boundaries: .ascii "11"
.bss
.p2align 3
.Lparent_calls: .zero 8
.Lchild_calls: .zero 8
.section .note.GNU-stack,"",%progbits

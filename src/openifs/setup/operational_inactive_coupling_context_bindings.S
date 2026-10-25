/* Contract: skills/md2asm/references/openifs/setup/operational_inactive_coupling_context_bindings.md. Two context pointers and one declared false word.
 * x0 cfg,x1 cfg_bytes,x2 MODEL,x3 MODEL_bytes,x4 partition,x5 partition_bytes,
 * x6 output16,x7 output_bytes. Return0 success,2 before public mutation.
 * Eight full mapped/disjoint spans; actual cfg/partition4 after accepted producers.
 * Integer leaf,160B scratch frame; preserve x18..x30,all SIMD,FPCR,FPSR,errno. */
.arch armv8.2-a
.text
.p2align 4
.macro CONST reg,value
 movz \reg,#(\value&65535)
 movk \reg,#(\value>>16),lsl#16
.endm
.macro SPAN ptr,cap,bytes,offset
 cbz \ptr,.Lbinding_bad
 tst \ptr,#7
 b.ne .Lbinding_bad
 CONST x9,\bytes
 cmp \cap,x9
 b.lo .Lbinding_bad
 adds x10,\ptr,x9
 b.cs .Lbinding_bad
 stp \ptr,x10,[sp,#\offset]
.endm
.macro CONTROL offset,value
 CONST x9,\offset
 ldr w10,[x0,x9]
 cmp w10,#\value
 b.ne .Lbinding_bad
.endm
.global md2asm_bind_operational_inactive_coupling_context
.type md2asm_bind_operational_inactive_coupling_context,%function
md2asm_bind_operational_inactive_coupling_context:
 mrs x9,fpcr
 cbnz x9,.Lbinding_bad_leaf
 sub sp,sp,#160
 SPAN x0,x1,67616,0
 SPAN x2,x3,4275088,16
 SPAN x4,x5,4096,32
 SPAN x6,x7,16,48
 adrp x8,:got:md2asm_owned_forecast_scalar_data
 ldr x8,[x8,:got_lo12:md2asm_owned_forecast_scalar_data]
 adds x9,x8,#112
 b.cs .Lbinding_bad
 stp x8,x9,[sp,#64]
 adrp x8,:got:md2asm_owned_physics_runtime_data
 ldr x8,[x8,:got_lo12:md2asm_owned_physics_runtime_data]
 adds x9,x8,#608
 b.cs .Lbinding_bad
 stp x8,x9,[sp,#80]
 /* The complete validated configuration supplies these two borrowed owners. */
 ldr x8,[x0,#16]
 mov x11,#20400
 SPAN x8,x11,20400,96
 ldr x8,[x0,#8]
 CONST x11,529288
 SPAN x8,x11,529288,112
 /* Check every one of28 unordered complete-range pairs before public stores. */
 mov x8,#0
.Lbinding_outer:
 add x14,sp,x8,lsl#4
 ldp x10,x11,[x14]
 add x9,x8,#1
.Lbinding_inner:
 cmp x9,#8
 b.hs .Lbinding_next
 add x14,sp,x9,lsl#4
 ldp x12,x13,[x14]
 cmp x10,x13
 b.hs .Lbinding_clear
 cmp x12,x11
 b.lo .Lbinding_bad
.Lbinding_clear:
 add x9,x9,#1
 b .Lbinding_inner
.Lbinding_next:
 add x8,x8,#1
 cmp x8,#7
 b.lo .Lbinding_outer
 ldr x0,[sp]
 ldr x1,[sp,#16]
 ldr x2,[sp,#32]
 ldr x3,[sp,#48]
 ldr x4,[sp,#96]
 ldr x5,[sp,#112]
 ldr x9,[x0]
 cmp x9,x1
 b.ne .Lbinding_bad
 ldr x9,[x0,#48]
 cmp x9,x2
 b.ne .Lbinding_bad
 ldr x9,[x1,#8]
 cmp x9,x4
 b.ne .Lbinding_bad
 ldr x9,[x2]
 cmp x9,x4
 b.ne .Lbinding_bad
 ldr x9,[x5,#1840]
 cmp x9,x1
 b.ne .Lbinding_bad
 ldr x9,[x0,#24]
 CONST x10,0x47314346
 cmp x9,x10
 b.ne .Lbinding_bad
 ldr x9,[x2,#8]
 movz x10,#0x574e
 movk x10,#0x5f4f,lsl#16
 movk x10,#0x5458,lsl#32
 movk x10,#0x4450,lsl#48
 cmp x9,x10
 b.ne .Lbinding_bad
 ldr w9,[x2,#16]
 cmp w9,#3
 b.ne .Lbinding_bad
 ldr w9,[x2,#24]
 cmp w9,#4
 b.ne .Lbinding_bad
 ldp w9,w10,[x2,#32]
 cmp w9,#2
 b.ne .Lbinding_bad
 cmp w10,#2
 b.ne .Lbinding_bad
 ldr w11,[x2,#28]
 sub w11,w11,#1
 cmp w11,#3
 b.hi .Lbinding_bad
 and w11,w11,#1
 add w11,w11,#1
 ldr w12,[x2,#68]
 cmp w12,w11
 b.ne .Lbinding_bad
 ldr w12,[x2,#116]
 cmp w12,w10
 b.ne .Lbinding_bad
 ldr w12,[x2,#124]
 cmp w12,w11
 b.ne .Lbinding_bad
 /* Source CPL_CONFIG returns before NAMCPLCFG for actual inactive TMCC. */
 CONST x9,1563544
 ldr w10,[x1,x9]
 cbnz w10,.Lbinding_bad
 CONST x9,1562916
 ldr w10,[x1,x9]
 cbnz w10,.Lbinding_bad
 /* Selected forecast guards reuse the admitted physics-data boundary. */
 CONTROL 35688,1
 CONTROL 35768,0
 CONTROL 35872,0
 CONTROL 36172,0
 CONTROL 36176,0
 CONTROL 36204,0
 CONTROL 40104,1
 ldr x9,[sp,#80]
 ldr w10,[x9,#24]
 cbnz w10,.Lbinding_bad
 /* LUSEKF_REF remains its admitted original ELF-policy word. */
 add x9,x9,#24
 ldr x10,[sp,#64]
 str wzr,[x10]
 stp x9,x10,[x3]
 mov w0,#0
 add sp,sp,#160
 ret
.Lbinding_bad:
 add sp,sp,#160
.Lbinding_bad_leaf:
 mov w0,#2
 ret
.size md2asm_bind_operational_inactive_coupling_context,.-md2asm_bind_operational_inactive_coupling_context
.section .note.GNU-stack,"",%progbits

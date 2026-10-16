/* Selected serial norm ABI bindings.
 * Contract: skills/md2asm/references/openifs/dynamics/norm_loop_bindings.md.
 * Attach x0 controls, x1 results, x2 capacity; detach x0 same results.
 * Original aliases borrow their records and attached buffers; no owners copied. */
.text
.p2align 2
/* Check a bounded unsigned interval. This leaf trusts mapping. */
.macro INTERVAL base,bytes,end
 adds \end,\base,\bytes
 b.cs .Lattach_reject
.endm
.macro DISJOINT a,ae,b,be
 cmp \a,\be
 b.hs 991f
 cmp \b,\ae
 b.lo .Lattach_reject
991:
.endm
.global md2asm_attach_spectral_norm_context
.type md2asm_attach_spectral_norm_context,%function
md2asm_attach_spectral_norm_context:
 mov x3,#0
 mov x4,#24
 mov x5,#20928
 b .Lattach
.size md2asm_attach_spectral_norm_context,.-md2asm_attach_spectral_norm_context
.global md2asm_attach_gridpoint_norm_context
.type md2asm_attach_gridpoint_norm_context,%function
md2asm_attach_gridpoint_norm_context:
 mov x3,#16
 mov x4,#12
 mov x5,#264
.Lattach:
 cbz x0,.Lattach_reject
 cbz x1,.Lattach_reject
 tst x0,#3
 b.ne .Lattach_reject
 tst x1,#7
 b.ne .Lattach_reject
 cmp x2,x5
 b.lo .Lattach_reject
 INTERVAL x0,x4,x6
 INTERVAL x1,x5,x7
 DISJOINT x0,x6,x1,x7
 ldr w8,[x0]
 ldr w9,[x0,#4]
 orr w8,w8,w9
 cbnz w8,.Lattach_reject
 cbnz x3,.Lattach_grid_controls
 ldr w8,[x0,#8]
 ldr w9,[x0,#12]
 orr w8,w8,w9
 ldr w10,[x0,#20]
 orr w8,w8,w10
 cbnz w8,.Lattach_reject
 ldr w8,[x0,#16]
 b .Lattach_serial
.Lattach_grid_controls:
 ldr w8,[x0,#8]
.Lattach_serial:
 cmp w8,#1
 b.ne .Lattach_reject
 adrp x8,:got:md2asm_owned_spectral_norm_state
 ldr x8,[x8,:got_lo12:md2asm_owned_spectral_norm_state]
 add x9,x8,#24
 DISJOINT x0,x6,x8,x9
 DISJOINT x1,x7,x8,x9
 adrp x8,.Lnorm_contexts
 add x8,x8,:lo12:.Lnorm_contexts
 add x9,x8,x3
 ldp x10,x11,[x9]
 cbz x10,.Lattach_other
 cmp x0,x10
 b.ne .Lattach_reject
 cmp x1,x11
 b.ne .Lattach_reject
.Lattach_other:
 eor x10,x3,#16
 add x10,x8,x10
 ldp x11,x12,[x10]
 cbz x11,.Lattach_publish
 cbnz x3,.Lother_spectral
 mov x13,#12
 mov x14,#264
 b .Lother_ranges
.Lother_spectral:
 mov x13,#24
 mov x14,#20928
.Lother_ranges:
 add x13,x11,x13
 add x14,x12,x14
 DISJOINT x0,x6,x11,x13
 DISJOINT x0,x6,x12,x14
 DISJOINT x1,x7,x11,x13
 DISJOINT x1,x7,x12,x14
.Lattach_publish:
 stp x0,x1,[x9]
 mov w0,#0
 ret
.Lattach_reject:
 mov w0,#2
 ret
.size md2asm_attach_gridpoint_norm_context,.-md2asm_attach_gridpoint_norm_context
.global md2asm_detach_spectral_norm_context
.type md2asm_detach_spectral_norm_context,%function
md2asm_detach_spectral_norm_context:
 mov x1,#0
 b .Ldetach
.size md2asm_detach_spectral_norm_context,.-md2asm_detach_spectral_norm_context
.global md2asm_detach_gridpoint_norm_context
.type md2asm_detach_gridpoint_norm_context,%function
md2asm_detach_gridpoint_norm_context:
 mov x1,#16
.Ldetach:
 adrp x2,.Lnorm_contexts
 add x2,x2,:lo12:.Lnorm_contexts
 add x2,x2,x1
 ldp x3,x4,[x2]
 cbz x3,.Ldetach_ok
 cmp x0,x4
 b.ne .Lattach_reject
 stp xzr,xzr,[x2]
.Ldetach_ok:
 mov w0,#0
 ret
.size md2asm_detach_gridpoint_norm_context,.-md2asm_detach_gridpoint_norm_context
.global spnorm_
.global md2asm_spnorm_7358525
.global md2asm_spnorm_optional_false_r2_7358525
.type spnorm_,%function
.type md2asm_spnorm_7358525,%function
.type md2asm_spnorm_optional_false_r2_7358525,%function
spnorm_:
md2asm_spnorm_7358525:
md2asm_spnorm_optional_false_r2_7358525:
 cbz x4,.Lspectral_option_ok
 tst x4,#3
 b.ne .Lnorm_fail
 ldr w9,[x4]
 cbnz w9,.Lnorm_fail
.Lspectral_option_ok:
 adrp x9,.Lnorm_contexts
 add x9,x9,:lo12:.Lnorm_contexts
 ldp x4,x6,[x9]
 cbz x4,.Lnorm_fail
 adrp x5,:got:md2asm_owned_spectral_norm_state
 ldr x5,[x5,:got_lo12:md2asm_owned_spectral_norm_state]
 stp x29,x30,[sp,#-16]!
 mov x29,sp
 bl md2asm_compute_selected_spectral_norms
 cbnz w0,.Lnorm_fail
 adrp x9,.Lnorm_call_counts
 add x9,x9,:lo12:.Lnorm_call_counts
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldp x29,x30,[sp],#16
 ret
.size spnorm_,.-spnorm_
.size md2asm_spnorm_7358525,.-md2asm_spnorm_7358525
.size md2asm_spnorm_optional_false_r2_7358525,.-md2asm_spnorm_optional_false_r2_7358525
.global gpnorm_gfl_
.global md2asm_gpnorm_gfl_7358525
.type gpnorm_gfl_,%function
.type md2asm_gpnorm_gfl_7358525,%function
gpnorm_gfl_:
md2asm_gpnorm_gfl_7358525:
 /* GPNORM selects a different field list whenever the option is present. */
 cbnz x2,.Lnorm_fail
 adrp x9,.Lnorm_contexts
 add x9,x9,:lo12:.Lnorm_contexts
 ldp x2,x3,[x9,#16]
 cbz x2,.Lnorm_fail
 mov x4,#264
 stp x29,x30,[sp,#-16]!
 mov x29,sp
 bl md2asm_compute_selected_gridpoint_norms
 cbnz w0,.Lnorm_fail
 adrp x9,.Lnorm_call_counts
 add x9,x9,:lo12:.Lnorm_call_counts
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]
 ldp x29,x30,[sp],#16
 ret
.size gpnorm_gfl_,.-gpnorm_gfl_
.size md2asm_gpnorm_gfl_7358525,.-md2asm_gpnorm_gfl_7358525
.Lnorm_fail:
 mov w0,#127
 bl _exit
 brk #0
.global md2asm_norm_loop_call_count_get
.type md2asm_norm_loop_call_count_get,%function
md2asm_norm_loop_call_count_get:
 cmp x0,#2
 b.hs .Lcount_outside
 adrp x1,.Lnorm_call_counts
 add x1,x1,:lo12:.Lnorm_call_counts
 ldr x0,[x1,x0,lsl #3]
 ret
.Lcount_outside:
 mov x0,#0
 ret
.size md2asm_norm_loop_call_count_get,.-md2asm_norm_loop_call_count_get
.bss
.p2align 3
.Lnorm_contexts:.zero 32
.Lnorm_call_counts:.zero 16
.section .note.GNU-stack,"",%progbits

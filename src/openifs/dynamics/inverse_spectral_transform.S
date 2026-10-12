/* Complete selected inverse spectral transform, emitted directly in AArch64.
 * Physics formulations/openifs/dynamics/inverse_spectral_transform.md, revision 2.
 * Contract skills/md2asm/references/openifs/dynamics/inverse_spectral_transform.md.
 * Frozen physics and arithmetic are inherited from LTINV source revision 1.
 * Seventeen GNU Fortran argument addresses. All storage stages are owned here.
 * Native children retain accepted unfused FP64 equations and rounding points.
 */
#ifndef LTINV_ENTRY
#define LTINV_ENTRY __ltinv_mod_MOD_ltinv
#endif
#ifndef LTINV_VDTUV
#define LTINV_VDTUV __vdtuv_mod_MOD_vdtuv
#endif
#ifndef LTINV_SPNSDE
#define LTINV_SPNSDE __spnsde_mod_MOD_spnsde
#endif
#ifndef LTINV_LEINV
#define LTINV_LEINV __leinv_mod_MOD_leinv
#endif
#ifndef LTINV_ASRE1B
#define LTINV_ASRE1B __asre1b_mod_MOD_asre1b
#endif
.text
.p2align 4
.macro GLOBAL dst,name
 adrp \dst,:got:\name
 ldr \dst,[\dst,:got_lo12:\name]
.endm
.macro COUNT index
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#8*\index]
 add x10,x10,#1
 str x10,[x9,#8*\index]
.endm
.global LTINV_ENTRY
.type LTINV_ENTRY,%function
LTINV_ENTRY:
 mov x17,sp
 sub sp,sp,#1664
 stp x18,x30,[sp,#32]
 stp x19,x20,[sp,#48]
 stp x21,x22,[sp,#64]
 stp x23,x24,[sp,#80]
 stp x25,x26,[sp,#96]
 stp x27,x28,[sp,#112]
 str x29,[sp,#128]
 stp x0,x1,[sp,#192]
 stp x2,x3,[sp,#208]
 stp x4,x5,[sp,#224]
 stp x6,x7,[sp,#240]
 ldp x9,x10,[x17]
 stp x9,x10,[sp,#256]
 ldp x9,x10,[x17,#16]
 stp x9,x10,[sp,#272]
 ldp x9,x10,[x17,#32]
 stp x9,x10,[sp,#288]
 ldp x9,x10,[x17,#48]
 stp x9,x10,[sp,#304]
 ldr x9,[x17,#64]
 str x9,[sp,#320]
 /* Reject unsupported control before output or child calls. */
 mrs x9,fpcr
 cbnz x9,.Lbad
 mov x10,#0
.Lscalar_pointers:
 add x11,sp,#192
 ldr x12,[x11,x10,lsl #3]
 cbz x12,.Lbad
 ldr w12,[x12]
 add x11,sp,#352
 str w12,[x11,x10,lsl #2]
 add x10,x10,#1
 cmp x10,#8
 b.lt .Lscalar_pointers
 ldr w19,[sp,#352]
 cmp w19,#21
 b.hi .Lbad
 ldr w9,[sp,#356]
 add w10,w19,#1
 cmp w9,w10
 b.ne .Lbad
 ldr w20,[sp,#364]
 ldr w21,[sp,#368]
 ldr w22,[sp,#376]
 ldr w23,[sp,#380]
 /* Only genuine absent maps, third carrier and callback are supported. */
 ldr x9,[sp,#288]
 cbnz x9,.Lbad
 ldp x9,x10,[sp,#304]
 orr x9,x9,x10
 ldr x10,[sp,#320]
 orr x9,x9,x10
 cbnz x9,.Lbad
 GLOBAL x9,__tpm_trans_MOD_latlon
 ldr w9,[x9]
 cbnz w9,.Lbad
 GLOBAL x25,__tpm_fields_MOD_f
 ldr x25,[x25]
 cbz x25,.Lbad
 GLOBAL x26,__tpm_distr_MOD_d
 ldr x26,[x26]
 cbz x26,.Lbad
 GLOBAL x27,__tpm_dim_MOD_r
 ldr x27,[x27]
 cbz x27,.Lbad
 GLOBAL x28,__tpm_flt_MOD_s
 ldr x28,[x28]
 cbz x28,.Lbad
 ldr w9,[x28,#64]
 ldr w10,[x28,#72]
 orr w9,w9,w10
 cbnz w9,.Lbad
 ldp w9,w10,[x27]
 cmp w9,#21
 b.ne .Lbad
 cmp w10,#21
 b.ne .Lbad
 ldr w9,[x27,#20]
 cmp w9,#32
 b.ne .Lbad
 ldr w9,[x27,#28]
 cmp w9,#16
 b.ne .Lbad
 ldp w9,w10,[x27,#32]
 cmp w9,#25
 b.ne .Lbad
 cmp w10,#16
 b.ne .Lbad
 GLOBAL x9,__tpm_geometry_MOD_g
 ldr x9,[x9]
 cbz x9,.Lbad
 add x0,x9,#128
 mov x1,x19
 bl .Linteger_component
 ldr w9,[x0]
 cmp w9,#16
 b.ne .Lbad
 /* Keep the six frozen field configurations and matching presence rules. */
 ldr w9,[sp,#360]
 ldr w10,[sp,#372]
 cmp w20,#0
 b.ne .Lwind_shapes
 cbnz w10,.Lbad
 cmp w21,#1
 b.eq .Lscalar_one
 cmp w21,#19
 b.ne .Lbad
 cmp w9,#19
 b.ne .Lbad
 cmp w22,#38
 b.ne .Lbad
 cmp w23,#38
 b.ne .Lbad
 b .Lscalar_presence
.Lscalar_one:
 cmp w9,#1
 b.ne .Lbad
 cmp w22,#2
 b.ne .Lbad
 cmp w23,#2
 b.ne .Lbad
.Lscalar_presence:
 ldp x9,x10,[sp,#256]
 orr x9,x9,x10
 cbnz x9,.Lbad
 ldr x9,[sp,#272]
 cbz x9,.Lbad
 ldr x9,[sp,#280]
 cbnz x9,.Lbad
 ldr x9,[sp,#296]
 cbnz x9,.Lbad
 b .Lflags
.Lwind_shapes:
 cmp w20,#1
 b.eq .Lwind_one
 cmp w20,#19
 b.ne .Lbad
 cmp w21,#0
 b.ne .Lmixed
 cbnz w10,.Lbad
 cmp w9,#38
 b.ne .Lbad
 cmp w22,#152
 b.ne .Lbad
 cmp w23,#76
 b.ne .Lbad
 b .Lwind_presence
.Lwind_one:
 cbnz w21,.Lbad
 cbnz w10,.Lbad
 cmp w9,#2
 b.ne .Lbad
 cmp w22,#8
 b.ne .Lbad
 cmp w23,#4
 b.ne .Lbad
.Lwind_presence:
 ldp x9,x10,[sp,#256]
 cbz x9,.Lbad
 cbz x10,.Lbad
 ldr x9,[sp,#272]
 cbnz x9,.Lbad
 ldr x9,[sp,#280]
 cbnz x9,.Lbad
 ldr x9,[sp,#296]
 cbnz x9,.Lbad
 b .Lflags
.Lmixed:
 cmp w21,#20
 b.ne .Lbad
 cmp w10,#20
 b.ne .Lbad
 cmp w22,#232
 b.ne .Lbad
 ldr w9,[sp,#360]
 cmp w9,#116
 b.eq .Lmixed_both
 cmp w9,#97
 b.ne .Lbad
 cmp w23,#194
 b.ne .Lbad
 b .Lmixed_presence
.Lmixed_both:
 cmp w23,#232
 b.ne .Lbad
.Lmixed_presence:
 ldp x9,x10,[sp,#256]
 cbz x9,.Lbad
 cbz x10,.Lbad
 ldr x9,[sp,#272]
 cbnz x9,.Lbad
 ldr x9,[sp,#280]
 cbz x9,.Lbad
 ldr x9,[sp,#296]
 cbz x9,.Lbad
 GLOBAL x9,__tpm_trans_MOD_nf_sc2
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lbad
 GLOBAL x9,__tpm_trans_MOD_nf_sc3a
 ldr w9,[x9]
 cmp w9,#19
 b.ne .Lbad
 GLOBAL x9,__tpm_trans_MOD_nf_sc3b
 ldr w9,[x9]
 cbnz w9,.Lbad
.Lflags:
 GLOBAL x9,__tpm_trans_MOD_lvorgp
 ldr w11,[x9]
 GLOBAL x9,__tpm_trans_MOD_ldivgp
 ldr w12,[x9]
 cmp w11,#1
 b.hi .Lbad
 cmp w12,#1
 b.hi .Lbad
 ldr w9,[sp,#360]
 cmp w9,#116
 b.ne .Lnot_both
 cmp w11,#1
 b.ne .Lbad
 cmp w12,#1
 b.ne .Lbad
 b .Lflags_done
.Lnot_both:
 cbnz w11,.Lbad
 cmp w9,#97
 cset w10,eq
 cmp w12,w10
 b.ne .Lbad
.Lflags_done:
 /* Ordinary contiguous carriers. The first data address is dummy origin. */
 cbz w20,.Lskip_uv_check
 ldr x0,[sp,#256]
 mov w1,w20
 mov w2,#2
 bl .Lcheck_spectral
 ldr x0,[sp,#264]
 mov w1,w20
 mov w2,#2
 bl .Lcheck_spectral
.Lskip_uv_check:
 cbz w21,.Lskip_sc_check
 ldr x0,[sp,#272]
 cbz x0,.Lcheck_mixed
 mov w1,w21
 mov w2,#2
 bl .Lcheck_spectral
 b .Lskip_sc_check
.Lcheck_mixed:
 ldr x0,[sp,#296]
 mov w1,#1
 mov w2,#2
 bl .Lcheck_spectral
 ldr x0,[sp,#280]
 mov w1,#19
 mov w2,#3
 bl .Lcheck_spectral
.Lskip_sc_check:
 /* Source-qualified table indexes and bounds precede internal work. */
 add x0,x26,#368
 mov x1,x19
 bl .Linteger_component
 ldrsw x29,[x0]
 cmp x29,#1
 b.lt .Lbad
 mov w9,#22
 sub w9,w9,w19
 lsl w9,w9,#1
 add x9,x29,x9
 sub x9,x9,#1
 cmp x9,#506
 b.gt .Lbad
 add x0,x26,#800
 mov x1,x19
 bl .Linteger_component
 ldrsw x9,[x0]
 add x9,x9,#1
 str x9,[sp,#408]
 add x0,x25,#344
 mov x1,x9
 bl .Lreal_component
 ldr x9,[sp,#408]
 add x1,x9,#23
 add x0,x25,#344
 bl .Lreal_component
 /* Build local ZEPSNM using bit copies, including diagonal padding. */
 add x10,sp,#512
 mov x11,#0
.Leps_zero:
 cmp x11,x19
 b.ge .Leps_values
 str xzr,[x10,x11,lsl #3]
 add x11,x11,#1
 b .Leps_zero
.Leps_values:
 add x0,x25,#344
 ldr x1,[sp,#408]
 add x1,x1,x19
 bl .Lreal_component
 add x10,sp,#512
 add x10,x10,x19,lsl #3
 mov w11,#24
 sub w11,w11,w19
.Leps_copy:
 ldr x12,[x0],#8
 str x12,[x10],#8
 subs w11,w11,#1
 b.ne .Leps_copy
 COUNT 5
 /* Complete private allocation. Zero only new unconsumed scratch cells. */
 mov x0,x22
 mov x1,#25
 mul x0,x0,x1
 mov x1,#8
 bl calloc
 cbz x0,.Lbad
 mov x24,x0
 str x0,[sp,#456]
 mov x0,x23
 lsl x0,x0,#4
 mov x1,#8
 bl calloc
 cbz x0,.Lbad
 str x0,[sp,#464]
 mov x0,x23
 lsl x0,x0,#4
 mov x1,#8
 bl calloc
 cbz x0,.Lbad
 str x0,[sp,#472]
 /* Preserve the actual source profiling entry and exit. */
 GLOBAL x9,__yomhook_MOD_lhook
 ldr w9,[x9]
 str w9,[sp,#1624]
 cbz w9,.Lhook_entry_done
 adr x0,.Lhook_name
 add x1,sp,#1608
 str wzr,[x1]
 add x2,sp,#1600
 mov x3,#9
 bl __yomhook_MOD_dr_hook_default8
.Lhook_entry_done:
 cbz w20,.Lpack_scalars
 /* Vorticity, divergence and wind views all retain 25-row pitch. */
 add x0,sp,#704
 mov x1,x24
 mov w2,#25
 lsl w3,w20,#1
 bl .Ldescriptor
 add x0,sp,#800
 mov w9,#400
 mul w9,w9,w20
 add x1,x24,w9,uxtw
 mov w2,#25
 lsl w3,w20,#1
 bl .Ldescriptor
 add x0,sp,#896
 mov w9,#800
 mul w9,w9,w20
 add x1,x24,w9,uxtw
 mov w2,#25
 lsl w3,w20,#1
 bl .Ldescriptor
 add x0,sp,#992
 mov w9,#1200
 mul w9,w9,w20
 add x1,x24,w9,uxtw
 mov w2,#25
 lsl w3,w20,#1
 bl .Ldescriptor
 ldr x0,[sp,#256]
 mov x1,x24
 mov w2,w20
 bl .Lpack
 ldr x0,[sp,#264]
 mov w9,#400
 mul w9,w9,w20
 add x1,x24,w9,uxtw
 mov w2,w20
 bl .Lpack
 ldr x0,[sp,#192]
 ldr x1,[sp,#216]
 add x2,sp,#512
 add x3,sp,#704
 add x4,sp,#800
 add x5,sp,#896
 add x6,sp,#992
 bl LTINV_VDTUV
 COUNT 1
.Lpack_scalars:
 cbz w21,.Lderivative
 mov w9,#1600
 mul w9,w9,w20
 add x29,x24,w9,uxtw
 ldr x0,[sp,#272]
 cbz x0,.Lpack_mixed
 mov x1,x29
 mov w2,w21
 bl .Lpack
 b .Lderivative
.Lpack_mixed:
 ldr x0,[sp,#296]
 mov x1,x29
 mov w2,#1
 bl .Lpack
 ldr x0,[sp,#280]
 add x1,x29,#400
 mov w2,#19
 bl .Lpack
.Lderivative:
 ldr w9,[sp,#372]
 cbz w9,.Ltransform
 add x0,sp,#1088
 mov w9,#1600
 mul w9,w9,w20
 add x1,x24,w9,uxtw
 mov w2,#25
 lsl w3,w21,#1
 bl .Ldescriptor
 add x0,sp,#1184
 mov w9,#1600
 mul w9,w9,w20
 mov w10,#400
 madd w9,w10,w21,w9
 add x1,x24,w9,uxtw
 mov w2,#25
 lsl w3,w21,#1
 bl .Ldescriptor
 ldr x0,[sp,#192]
 ldr x1,[sp,#224]
 add x2,sp,#512
 add x3,sp,#1088
 add x4,sp,#1184
 bl LTINV_SPNSDE
 COUNT 2
.Ltransform:
 ldr w9,[sp,#360]
 lsl w9,w9,#1
 str w9,[sp,#384]
 cbnz w19,.Liifc
 lsr w9,w9,#1
.Liifc:
 str w9,[sp,#388]
 mov w9,#1
 str w9,[sp,#392]
 mov w9,#16
 str w9,[sp,#396]
 mov w11,#0
 GLOBAL x9,__tpm_trans_MOD_lvorgp
 ldr w9,[x9]
 cbnz w9,.Lkeep_vor
 add w11,w11,w20,lsl #1
.Lkeep_vor:
 GLOBAL x9,__tpm_trans_MOD_ldivgp
 ldr w9,[x9]
 cbnz w9,.Lkeep_div
 add w11,w11,w20,lsl #1
.Lkeep_div:
 mov w9,#200
 mul w11,w11,w9
 add x1,x24,w11,uxtw
 add x0,sp,#1280
 mov w2,#25
 ldr w3,[sp,#384]
 bl .Ldescriptor
 add x0,sp,#1376
 ldr x1,[sp,#464]
 mov w2,w23
 mov w3,#16
 bl .Ldescriptor
 add x0,sp,#1472
 ldr x1,[sp,#472]
 mov w2,w23
 mov w3,#16
 bl .Ldescriptor
 ldr x0,[sp,#192]
 ldr x1,[sp,#200]
 add x2,sp,#384
 add x3,sp,#388
 ldr x4,[sp,#208]
 add x5,sp,#392
 add x6,sp,#396
 add x7,sp,#1280
 add x9,sp,#1376
 add x10,sp,#1472
 stp x9,x10,[sp]
 bl LTINV_LEINV
 COUNT 3
 ldr x0,[sp,#208]
 ldr x1,[sp,#192]
 ldr x2,[sp,#200]
 add x3,sp,#1376
 add x4,sp,#1472
 bl LTINV_ASRE1B
 COUNT 4
 ldr x0,[sp,#456]
 bl free
 ldr x0,[sp,#464]
 bl free
 ldr x0,[sp,#472]
 bl free
 ldr w9,[sp,#1624]
 cbz w9,.Lhook_exit_done
 adr x0,.Lhook_name
 add x1,sp,#1612
 mov w9,#1
 str w9,[x1]
 add x2,sp,#1600
 mov x3,#9
 bl __yomhook_MOD_dr_hook_default8
.Lhook_exit_done:
 COUNT 0
 ldp x18,x30,[sp,#32]
 ldp x19,x20,[sp,#48]
 ldp x21,x22,[sp,#64]
 ldp x23,x24,[sp,#80]
 ldp x25,x26,[sp,#96]
 ldp x27,x28,[sp,#112]
 ldr x29,[sp,#128]
 add sp,sp,#1664
 ret
.size LTINV_ENTRY,.-LTINV_ENTRY
/* Qualified contiguous ordinary rank-two or rank-three coefficient carrier. */
.Lcheck_spectral:
 cbz x0,.Lbad
 ldr x9,[x0]
 cbz x9,.Lbad
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lbad
 ldrb w9,[x0,#28]
 cmp w9,w2
 b.ne .Lbad
 ldrb w9,[x0,#29]
 cmp w9,#3
 b.ne .Lbad
 ldr x9,[x0,#32]
 cmp x9,#8
 b.ne .Lbad
 ldp x9,x10,[x0,#40]
 cmp x9,#1
 b.ne .Lbad
 cmp x10,#1
 b.ne .Lbad
 ldr x9,[x0,#56]
 cmp w9,w1
 b.ne .Lbad
 ldp x9,x10,[x0,#64]
 cmp w9,w1
 b.ne .Lbad
 cmp x10,#1
 b.ne .Lbad
 ldr x9,[x0,#80]
 cmp x9,#506
 b.ne .Lbad
 cmp w2,#3
 b.ne .Lspec_ok
 ldr x9,[x0,#88]
 mov x10,#506
 mul x10,x10,x1
 cmp x9,x10
 b.ne .Lbad
 ldp x9,x10,[x0,#96]
 cmp x9,#1
 b.ne .Lbad
 cmp x10,#1
 b.ne .Lbad
.Lspec_ok:
 ret
/* A source-qualified integer component uses its stored bias and bounds. */
.Linteger_component:
 ldr x9,[x0,#16]
 cmp x9,#4
 b.ne .Lbad
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Lbad
 ldp x9,x10,[x0,#48]
 cmp x1,x9
 b.lt .Lbad
 cmp x1,x10
 b.gt .Lbad
 ldp x9,x10,[x0]
 cbz x9,.Lbad
 add x10,x10,x1
 add x0,x9,x10,lsl #2
 ret
.Lreal_component:
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lbad
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Lbad
 ldp x9,x10,[x0,#48]
 cmp x1,x9
 b.lt .Lbad
 cmp x1,x10
 b.gt .Lbad
 ldp x9,x10,[x0]
 cbz x9,.Lbad
 add x10,x10,x1
 add x0,x9,x10,lsl #3
 ret
/* x0 descriptor, x1 first actual cell, w2 pitch, w3 column count. */
.Ldescriptor:
 neg x9,x2
 sub x9,x9,#1
 stp x1,x9,[x0]
 mov x9,#8
 str x9,[x0,#16]
 str wzr,[x0,#24]
 mov w9,#0x302
 strh w9,[x0,#28]
 strh wzr,[x0,#30]
 mov x9,#8
 str x9,[x0,#32]
 mov x9,#1
 stp x9,x9,[x0,#40]
 str x2,[x0,#56]
 stp x2,x9,[x0,#64]
 str x3,[x0,#80]
 ret
/* Raw PREPSNM-compatible degree pair packing. x0 source, x1 target, w2 fields. */
.Lpack:
 GLOBAL x3,__tpm_distr_MOD_d
 ldr x3,[x3]
 ldp x4,x5,[x3,#368]
 add x5,x5,x19
 ldrsw x6,[x4,x5,lsl #2]
 ldr x3,[x0]
 ldr x4,[x0,#64]
 mov w5,#22
 sub w5,w5,w19
 sub w6,w6,#3
 add w6,w6,w5,lsl #1
 mov w7,#0
.Lpack_field:
 cmp w7,w2
 b.ge .Lpack_done
 lsl w8,w7,#1
 mov w9,#200
 mul w8,w8,w9
 add x8,x1,w8,uxtw
 str xzr,[x8]
 str xzr,[x8,#8]
 str xzr,[x8,#200]
 str xzr,[x8,#208]
 add w9,w5,#2
 str xzr,[x8,w9,uxtw #3]
 add x10,x8,#200
 str xzr,[x10,w9,uxtw #3]
 mov w9,#0
.Lpack_degree:
 cmp w9,w5
 b.ge .Lpack_next
 sub w10,w6,w9,lsl #1
 mul x10,x10,x4
 add x10,x10,x7
 ldr x11,[x3,x10,lsl #3]
 add w12,w9,#2
 str x11,[x8,w12,uxtw #3]
 add x10,x10,x4
 ldr x11,[x3,x10,lsl #3]
 add x13,x8,#200
 str x11,[x13,w12,uxtw #3]
 add w9,w9,#1
 b .Lpack_degree
.Lpack_next:
 add w7,w7,#1
 b .Lpack_field
.Lpack_done:
 COUNT 6
 ret
.Lbad:
 mov w0,#132
 bl exit
 brk #0
.global md2asm_ltinv_counts_get
.type md2asm_ltinv_counts_get,%function
md2asm_ltinv_counts_get:
 cmp w0,#6
 b.hi .Lcount_bad
 adrp x1,.Lparent_counts
 add x1,x1,:lo12:.Lparent_counts
 ldr x0,[x1,w0,uxtw #3]
 ret
.Lcount_bad:
 mov x0,#0
 ret
.size md2asm_ltinv_counts_get,.-md2asm_ltinv_counts_get
.section .rodata
.Lhook_name: .ascii "LTINV_MOD"
.bss
.p2align 3
.Lparent_counts: .zero 56
.section .note.GNU-stack,"",%progbits

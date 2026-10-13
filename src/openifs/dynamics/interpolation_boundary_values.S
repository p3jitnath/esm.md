/* Direct selected boundary stores for original LAVABO.
 * Physics formulations/openifs/dynamics/interpolation_boundary_values.md.
 * Contract skills/md2asm/references/openifs/dynamics/interpolation_boundary_values.md.
 * Six original addresses. Each selected FP64 boundary value becomes positive zero.
 * Units and field ordering follow the accepted interpolation work fields.
 */
#ifndef BOUNDARY_ENTRY
#define BOUNDARY_ENTRY lavabo_
#endif
/* Original typed positions from the sealed source contract. */
.equ MODEL_YRPTRSLB1_NFLDSLB1,1573016
.equ MODEL_YRPTRSLB1_MSLB1UR0,1573128
.equ MODEL_YRPTRSLB1_MSLB1VR0,1573132
.equ MODEL_YRPTRSLB1_MSLB1ZR0,1573136
.equ MODEL_YRPTRSLB1_MSLB1WR0,1573140
.equ MODEL_YRPTRSLB1_MSLB1U9,1573092
.equ MODEL_YRPTRSLB1_MSLB1V9,1573096
.equ MODEL_YRPTRSLB1_MSLB1Z9,1573100
.equ MODEL_YRPTRSLB1_MSLB1T9,1573104
.equ MODEL_YRPTRSLB1_MSLB1GFL9,1573108
.equ MODEL_YRPTRSLB1_MSLB1GFLP9,1573244
.equ MODEL_YRPTRSLB1_MSLB1UP9,1573228
.equ MODEL_YRPTRSLB1_MSLB1VP9,1573232
.equ MODEL_YRPTRSLB1_MSLB1ZP9,1573236
.equ MODEL_YRPTRSLB1_MSLB1TP9,1573240
.equ MODEL_YRPTRSLB1_MSLB1U0,1573188
.equ MODEL_YRPTRSLB1_MSLB1V0,1573192
.equ MODEL_YRPTRSLB1_MSLB1Z0,1573196
.equ MODEL_YRPTRSLB1_MSLB1T0,1573200
.equ MODEL_YRPTRSLB1_MSLB1C9,1573212
.equ MODEL_YRDYN_LSLDP_CURV,1568892
.equ MODEL_YRDYN_LRHS_CURV,1568896
.equ MODEL_YRDYN_LSLDP_RK,1568888
.equ MODEL_YRDYN_NSPLTHOI,1568796
.equ MODEL_YRDYN_LSPLTHOIGFL,1568800
.equ MODEL_YRDYN_NWLAG,1568780
.equ MODEL_YRDYN_NTLAG,1568784
.equ MODEL_YRDYN_NVLAG,1568776
.equ MODEL_YRDYNA_LNHEE,1564136
.equ MODEL_YRDYNA_LNHDYN,1564144
.equ MODEL_YRDYNA_LSLINL,1564440
.equ MODEL_YRDYNA_LSLINLC2,1564436
.equ MODEL_GFL_NUMFLDS,192
.equ MODEL_GFL_YCOMP,4040
.equ MODEL_EPHY_LSLPHY,1578148
.equ GEOMETRY_DIM_NPROMA,5144
.equ GEOMETRY_DIMV_NFLEVG,5224
.equ GEOMETRY_DIMV_NFLEN,5248
.equ GEOMETRY_DIMV_NFLSA,5244
.equ YCOMP_LADV,20
.equ YCOMP_CSLINT,156
.equ YCOMP_MP_SL1,216
.equ YCOMP_LPHY,100
.equ YCOMP_MPSLP,204
.equ YCOMP_element_bytes,368
.equ YCOMP_declared_elements,2163
.equ YCOMP_CSLINT_bytes,12
.text
.p2align 4
.macro MLOAD dst,offset
 movz x9,#(\offset)&65535
 movk x9,#((\offset)>>16),lsl #16
 ldr \dst,[x20,x9]
.endm
.macro EXPECT offset,value
 MLOAD w10,\offset
 cmp w10,#\value
 b.ne .Lboundary_bad
.endm
.macro BASE offset
 MLOAD w0,\offset
 bl .Lboundary_base
.endm
.macro COUNT index,value
 adrp x9,.Lboundary_counts
 add x9,x9,:lo12:.Lboundary_counts
 ldr x10,[x9,#8*\index]
 add x10,x10,\value
 str x10,[x9,#8*\index]
.endm
.global BOUNDARY_ENTRY
.type BOUNDARY_ENTRY,%function
BOUNDARY_ENTRY:
 sub sp,sp,#448
 stp x18,x30,[sp,#32]
 stp x19,x20,[sp,#48]
 stp x21,x22,[sp,#64]
 stp x23,x24,[sp,#80]
 stp x25,x26,[sp,#96]
 stp x27,x28,[sp,#112]
 str x29,[sp,#128]
 stp x0,x1,[sp,#160]
 stp x2,x3,[sp,#176]
 stp x4,x5,[sp,#192]
 mov x19,x0
 mov x20,x1
 mov x21,x5
 cbz x19,.Lboundary_bad
 cbz x20,.Lboundary_bad
 cbz x2,.Lboundary_bad
 cbz x3,.Lboundary_bad
 cbz x4,.Lboundary_bad
 cbz x21,.Lboundary_bad
 tst x21,#7
 b.ne .Lboundary_bad
 mrs x9,fpcr
 cbnz x9,.Lboundary_bad
 ldr w9,[x4]
 cbnz w9,.Lboundary_bad
 ldrsw x22,[x2]
 sub x22,x22,#1
 cmp x22,#23
 b.hi .Lboundary_bad
 ldrsw x23,[x3]
 cmp x23,#24
 b.hi .Lboundary_bad
 ldr w9,[x19,#GEOMETRY_DIM_NPROMA]
 cmp w9,#24
 b.ne .Lboundary_bad
 ldr w9,[x19,#GEOMETRY_DIMV_NFLEVG]
 cmp w9,#19
 b.ne .Lboundary_bad
 ldr w9,[x19,#GEOMETRY_DIMV_NFLEN]
 cmp w9,#20
 b.ne .Lboundary_bad
 ldr w9,[x19,#GEOMETRY_DIMV_NFLSA]
 cbnz w9,.Lboundary_bad
 EXPECT MODEL_YRPTRSLB1_NFLDSLB1,463
 EXPECT MODEL_GFL_NUMFLDS,8
 EXPECT MODEL_YRDYN_LSLDP_CURV,1
 EXPECT MODEL_YRDYN_LRHS_CURV,0
 EXPECT MODEL_YRDYN_LSLDP_RK,0
 EXPECT MODEL_YRDYN_NSPLTHOI,0
 EXPECT MODEL_YRDYN_LSPLTHOIGFL,0
 EXPECT MODEL_YRDYN_NWLAG,3
 EXPECT MODEL_YRDYN_NTLAG,3
 EXPECT MODEL_YRDYN_NVLAG,3
 EXPECT MODEL_YRDYNA_LNHEE,0
 EXPECT MODEL_YRDYNA_LNHDYN,0
 EXPECT MODEL_YRDYNA_LSLINL,0
 EXPECT MODEL_YRDYNA_LSLINLC2,0
 EXPECT MODEL_EPHY_LSLPHY,1
 add x27,sp,#256
 mov x28,#0
 /* Validate every selected column before the first store. */
 BASE MODEL_YRPTRSLB1_MSLB1UR0
 BASE MODEL_YRPTRSLB1_MSLB1VR0
 BASE MODEL_YRPTRSLB1_MSLB1ZR0
 BASE MODEL_YRPTRSLB1_MSLB1WR0
 BASE MODEL_YRPTRSLB1_MSLB1U9
 BASE MODEL_YRPTRSLB1_MSLB1V9
 BASE MODEL_YRPTRSLB1_MSLB1T9
 add x25,x20,#MODEL_GFL_YCOMP
 mov x26,#8
.Lboundary_advected:
 ldr w9,[x25,#YCOMP_LADV]
 cbz w9,.Lboundary_advected_next
 cmp w9,#1
 b.ne .Lboundary_bad
 /* Compare all twelve method bytes, preserving fixed trailing spaces. */
 add x0,x25,#YCOMP_CSLINT
 ldr x9,[x0]
 adr x11,.Lexcluded_method
 ldr x10,[x11]
 cmp x9,x10
 b.ne .Lboundary_advected_add
 ldr w9,[x0,#8]
 ldr w10,[x11,#8]
 cmp w9,w10
 b.eq .Lboundary_advected_next
.Lboundary_advected_add:
 ldr w11,[x25,#YCOMP_MP_SL1]
 cmp w11,#1
 b.lt .Lboundary_bad
 sub w11,w11,#1
 cmp w11,#2163
 b.hi .Lboundary_bad
 mov w12,#21
 mul w11,w11,w12
 MLOAD w0,MODEL_YRPTRSLB1_MSLB1GFL9
 add w0,w0,w11
 bl .Lboundary_base
.Lboundary_advected_next:
 add x25,x25,#YCOMP_element_bytes
 subs x26,x26,#1
 b.ne .Lboundary_advected
 BASE MODEL_YRPTRSLB1_MSLB1U0
 BASE MODEL_YRPTRSLB1_MSLB1V0
 BASE MODEL_YRPTRSLB1_MSLB1T0
 BASE MODEL_YRPTRSLB1_MSLB1C9
 BASE MODEL_YRPTRSLB1_MSLB1UP9
 BASE MODEL_YRPTRSLB1_MSLB1VP9
 BASE MODEL_YRPTRSLB1_MSLB1TP9
 add x25,x20,#MODEL_GFL_YCOMP
 mov x26,#8
.Lboundary_physics:
 ldr w9,[x25,#YCOMP_LPHY]
 cbz w9,.Lboundary_physics_next
 cmp w9,#1
 b.ne .Lboundary_bad
 ldr w11,[x25,#YCOMP_MPSLP]
 cmp w11,#1
 b.lt .Lboundary_bad
 sub w11,w11,#1
 cmp w11,#2163
 b.hi .Lboundary_bad
 mov w12,#21
 mul w11,w11,w12
 MLOAD w0,MODEL_YRPTRSLB1_MSLB1GFLP9
 add w0,w0,w11
 bl .Lboundary_base
.Lboundary_physics_next:
 add x25,x25,#YCOMP_element_bytes
 subs x26,x26,#1
 b.ne .Lboundary_physics
 /* Original profiling is a utility, with no omitted numerical stage. */
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[sp,#208]
 cbz w9,.Lboundary_hook_entry_done
 adr x0,.Lboundary_name
 add x1,sp,#212
 str wzr,[x1]
 add x2,sp,#216
 mov x3,#6
 bl __yomhook_MOD_dr_hook_default8
 COUNT 2,#1
.Lboundary_hook_entry_done:
 mov x24,#0
 mov x26,#0
.Lboundary_column:
 cmp x24,x28
 b.ge .Lboundary_stores_done
 ldr w9,[x27,x24,lsl #2]
 mov x10,#192
 mul x9,x9,x10
 add x11,x21,x9
 add x12,x11,#3840
 mov x13,x22
.Lboundary_row:
 cmp x13,x23
 b.ge .Lboundary_next_column
 str xzr,[x11,x13,lsl #3]
 str xzr,[x12,x13,lsl #3]
 add x26,x26,#2
 add x13,x13,#1
 b .Lboundary_row
.Lboundary_next_column:
 add x24,x24,#1
 b .Lboundary_column
.Lboundary_stores_done:
 ldr w9,[sp,#208]
 cbz w9,.Lboundary_hook_exit_done
 adr x0,.Lboundary_name
 add x1,sp,#212
 mov w9,#1
 str w9,[x1]
 add x2,sp,#216
 mov x3,#6
 bl __yomhook_MOD_dr_hook_default8
 COUNT 2,#1
.Lboundary_hook_exit_done:
 COUNT 1,x26
 COUNT 0,#1
 ldp x18,x30,[sp,#32]
 ldp x19,x20,[sp,#48]
 ldp x21,x22,[sp,#64]
 ldp x23,x24,[sp,#80]
 ldp x25,x26,[sp,#96]
 ldp x27,x28,[sp,#112]
 ldr x29,[sp,#128]
 add sp,sp,#448
 ret
.size BOUNDARY_ENTRY,.-BOUNDARY_ENTRY
/* Append one zero-based top column. Its paired bottom is twenty columns later. */
.Lboundary_base:
 cmp w0,#1
 b.lt .Lboundary_bad
 cmp w0,#443
 b.gt .Lboundary_bad
 cmp x28,#32
 b.hs .Lboundary_bad
 sub w0,w0,#1
 str w0,[x27,x28,lsl #2]
 add x28,x28,#1
 ret
.Lboundary_bad:
 mov w0,#132
 bl exit
 brk #0
.global boundary_native_count_get
.type boundary_native_count_get,%function
boundary_native_count_get:
 cmp w0,#3
 b.hs .Lboundary_empty_count
 adrp x1,.Lboundary_counts
 add x1,x1,:lo12:.Lboundary_counts
 ldr x0,[x1,w0,uxtw #3]
 ret
.Lboundary_empty_count:
 mov x0,#0
 ret
.size boundary_native_count_get,.-boundary_native_count_get
.section .rodata
.Lboundary_name: .ascii "LAVABO"
.Lexcluded_method: .ascii "LAITVSPCQM  "
.bss
.p2align 3
.Lboundary_counts: .zero 24
.section .note.GNU-stack,"",%progbits

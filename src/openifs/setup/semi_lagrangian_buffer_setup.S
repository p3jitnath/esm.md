/* Source-derived selected SUDYN controls and SUSLB maps/parities.
 * Contract: skills/md2asm/references/openifs/dynamics/semi_lagrangian_buffer_setup.md. Complete borrowed MODEL, ordinary malloc. */
#include "semi_lagrangian_buffer_layout.inc.S"
.text
.p2align 4
.macro AT reg,base,offset
 mov x17,#(\offset & 65535)
 movk x17,#((\offset >> 16)&65535),lsl#16
 add \reg,\base,x17
.endm
.macro CHECK name,val,bad=.Lcontrols_bad_frame,base=x19
 AT x9,\base,\name
 ldr w10,[x9]
 cmp w10,#\val
 b.ne \bad
.endm
.macro STORE name,reg
 AT x9,x19,\name
 str \reg,[x9]
.endm
.global md2asm_initialize_selected_interpolation_controls
.type md2asm_initialize_selected_interpolation_controls,%function
md2asm_initialize_selected_interpolation_controls:
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x4,.Lbad
 tst x0,#7
 b.ne .Lbad
 tst x4,#3
 b.ne .Lbad
 mov x9,#(4275088&65535)
 movk x9,#65,lsl#16
 cmp x1,x9
 b.lo .Lbad
 adds x9,x0,x9
 b.cs .Lbad
 ldp w9,w10,[x4]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldp w9,w10,[x4,#8]
 cbnz w9,.Lbad
 cmp w10,#1
 b.ne .Lbad
 stp x18,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 mov x19,x0
 mov x20,x2
 mov x21,x3
 CHECK LSLAG,1
 CHECK LTWOTL,1
 CHECK LNHDYN,0
 CHECK LNHEE,0
 CHECK L3DTURB,0
 CHECK LSLHD,0
 CHECK LRDBBC,0
 CHECK LCOMAD,0
 CHECK LSLINL,0
 CHECK LSLINLC2,0
 CHECK LPC_CHEAP,0
 CHECK LRHSVWENO,1
 mov x0,x20
 mov x1,x21
 adr x2,.Lnamdyn
 mov x3,#6
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lcontrols_done
 mov x0,x20
 mov x1,x21
 adr x2,.Lnamdyna
 mov x3,#7
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lcontrols_done
 mov w11,#3
 STORE NVLAG,w11
 STORE NWLAG,w11
 STORE NTLAG,w11
 STORE NSPDLAG,w11
 STORE NSVDLAG,w11
 mov w11,#0
 STORE NSPLTHOI,w11
 STORE LSVTSM,w11
 STORE LSLDP_RK,w11
 STORE LRHS_CURV,w11
 STORE LADVF,w11
 STORE L2TLFF,w11
 mov w11,#1
 STORE LSLDP_CURV,w11
 STORE LSLDP_XYZ,w11
 STORE LSLDP_SAVE,w11
 STORE LSLHDHEAT,w11
 AT x9,x19,LRHSVWENO
 ldr w11,[x9]
 STORE LVWENO_T,w11
 /* Source one set, plus2 for L3DTURB and1 for split interpolation. */
 AT x9,x19,L3DTURB
 ldr w11,[x9]
 lsl w11,w11,#1
 add w11,w11,#1
 STORE NSLDIMK,w11
 mov w0,#0
 b .Lcontrols_done
.Lcontrols_bad_frame:
 mov w0,#2
.Lcontrols_done:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x18,x30,[sp],#64
 ret
.size md2asm_initialize_selected_interpolation_controls,.-md2asm_initialize_selected_interpolation_controls
.Lbad:
 mov w0,#2
 ret
.p2align 4
.global md2asm_initialize_selected_sl_buffer_maps
.type md2asm_initialize_selected_sl_buffer_maps,%function
md2asm_initialize_selected_sl_buffer_maps:
 cbz x0,.Lbad
 cbz x2,.Lbad
 tst x0,#7
 b.ne .Lbad
 tst x2,#3
 b.ne .Lbad
 mov x9,#(4275088&65535)
 movk x9,#65,lsl#16
 cmp x1,x9
 b.lo .Lbad
 cmp x3,#4
 b.lo .Lbad
 adds x9,x0,x9
 b.cs .Lbad
 ldr w9,[x2]
 sub w10,w9,#1
 cmp w10,#254
 b.hi .Lbad
 sub sp,sp,#1024
 stp x18,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x29,[sp,#96]
 mov x19,x0
 mov w22,w9
 CHECK LSLAG,1,.Lmaps_bad
 CHECK LNHDYN,0,.Lmaps_bad
 CHECK LNHEE,0,.Lmaps_bad
 CHECK NSPLTHOI,0,.Lmaps_bad
 CHECK LSPLTHOIGFL,0,.Lmaps_bad
 CHECK LSVTSM,0,.Lmaps_bad
 CHECK LSLDP_RK,0,.Lmaps_bad
 CHECK LRHS_CURV,0,.Lmaps_bad
 CHECK LSLDP_CURV,1,.Lmaps_bad
 CHECK LSLDP_XYZ,1,.Lmaps_bad
 CHECK NVLAG,3,.Lmaps_bad
 CHECK NWLAG,3,.Lmaps_bad
 CHECK NTLAG,3,.Lmaps_bad
 CHECK LSLHD,0,.Lmaps_bad
 CHECK LRDBBC,0,.Lmaps_bad
 CHECK L3DTURB,0,.Lmaps_bad
 CHECK LCOMAD,0,.Lmaps_bad
 CHECK LSLINL,0,.Lmaps_bad
 CHECK LSLINLC2,0,.Lmaps_bad
 CHECK LPC_CHEAP,0,.Lmaps_bad
 CHECK LAGPHY,1,.Lmaps_bad
 CHECK LEPHYS,1,.Lmaps_bad
 CHECK LSLPHY,1,.Lmaps_bad
 CHECK LRSIDDH,0,.Lmaps_bad
 AT x9,x19,NUMFLDS_SL1
 ldr w23,[x9]
 cmp w23,#64
 b.hi .Lmaps_bad
 AT x9,x19,NUMFLDS
 ldr w10,[x9]
 cmp w23,w10
 b.hi .Lmaps_bad
 AT x9,x19,NDIMSLP
 ldr w20,[x9]
 cmp w20,#64
 b.hi .Lmaps_bad
 AT x9,x19,NUMFLDS_SPL
 ldr w10,[x9]
 cbnz w10,.Lmaps_bad
 AT x9,x19,RPARSL1
 ldr x10,[x9]
 cbnz x10,.Lmaps_bad
 AT x9,x19,RPARSL15
 ldr x10,[x9]
 cbnz x10,.Lmaps_bad
 add x24,sp,#128
 add x25,sp,#432
 add x26,sp,#592
 AT x9,x19,YDPTRSLB1
 mov x10,x24
 mov x11,#304
 bl .Lcopy
 AT x9,x19,YDPTRSLB2
 mov x10,x25
 mov x11,#160
 bl .Lcopy
 AT x9,x19,YDPTRSLB15
 mov x10,x26
 mov x11,#192
 bl .Lcopy
 mov w10,#(-99999&65535)
 movk w10,#65534,lsl#16
#include "semi_lagrangian_unused_pointer_stores.inc.S"
 mov w12,#1
 str w12,[x25,#(MSLBUF2-YDPTRSLB2)]
#define MAP2(name) str w12,[x25,#(name-YDPTRSLB2)]; add w12,w12,w22
 MAP2(MSLB2USI)
 MAP2(MSLB2VSI)
 MAP2(MSLB2TSI)
 str w12,[x25,#(MSLB2SPSI-YDPTRSLB2)]
 add w12,w12,#1
 MAP2(MSLB2VVEL)
 MAP2(MSLB2URL)
 MAP2(MSLB2VRL)
 MAP2(MSLB2WRL)
 MAP2(MSLB2ZRL)
 sub w10,w12,#1
 str w10,[x25]
 add w21,w22,#2
 mov w12,#1
 str w12,[x24,#(MSLBUF1-YDPTRSLB1)]
#define MAP1(name) str w12,[x24,#(name-YDPTRSLB1)]; add w12,w12,w21
 MAP1(MSLB1U9)
 MAP1(MSLB1V9)
 MAP1(MSLB1T9)
 cbz w23,.Lgfl9_done
 str w12,[x24,#(MSLB1GFL9-YDPTRSLB1)]
 madd w12,w23,w21,w12
.Lgfl9_done:
 str w12,[x24,#(MSLB1SP9-YDPTRSLB1)]
 add w12,w12,#1
 MAP1(MSLB1UR0)
 MAP1(MSLB1VR0)
 MAP1(MSLB1ZR0)
 MAP1(MSLB1WR0)
 MAP1(MSLB1U0)
 MAP1(MSLB1V0)
 MAP1(MSLB1T0)
 MAP1(MSLB1C9)
 MAP1(MSLB1UP9)
 MAP1(MSLB1VP9)
 MAP1(MSLB1TP9)
 str w12,[x24,#(MSLB1GFLP9-YDPTRSLB1)]
 madd w12,w20,w21,w12
 sub w12,w12,#1
 str w12,[x24]
 mov w10,#1
 str w10,[x26]
 str w12,[sp,#800]
 uxtw x0,w12
 lsl x0,x0,#3
 bl malloc
 cbz x0,.Lmaps_allocfail
 mov x27,x0
 mov x0,#8
 bl malloc
 cbz x0,.Lmaps_secondfail
 mov x28,x0
 mov x9,x27
 ldr w10,[sp,#800]
 mov x11,#0x3ff0000000000000
.Lpositive:
 str x11,[x9],#8
 subs w10,w10,#1
 b.ne .Lpositive
 mov x11,#0xbff0000000000000
#define NEGATIVE(name) ldr w9,[x24,#(name-YDPTRSLB1)]; sub w9,w9,#1; add x9,x27,x9,lsl#3; mov w10,w21; bl .Lnegative
 NEGATIVE(MSLB1U9)
 NEGATIVE(MSLB1V9)
 NEGATIVE(MSLB1U0)
 NEGATIVE(MSLB1V0)
 NEGATIVE(MSLB1UP9)
 NEGATIVE(MSLB1VP9)
 add x9,x24,#8
 mov x10,x27
 ldr w11,[sp,#800]
 bl .Ldescriptor
 add x9,x26,#8
 mov x10,x28
 mov w11,#1
 bl .Ldescriptor
 mov x9,x24
 AT x10,x19,YDPTRSLB1
 mov x11,#304
 bl .Lcopy
 mov x9,x25
 AT x10,x19,YDPTRSLB2
 mov x11,#160
 bl .Lcopy
 mov x9,x26
 AT x10,x19,YDPTRSLB15
 mov x11,#192
 bl .Lcopy
 mov w0,#0
 b .Lmaps_done
.Lmaps_secondfail:
 mov x0,x27
 bl free
.Lmaps_allocfail:
 mov w0,#1
 b .Lmaps_done
.Lmaps_bad:
 mov w0,#2
.Lmaps_done:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldr x29,[sp,#96]
 ldp x18,x30,[sp]
 add sp,sp,#1024
 ret
.size md2asm_initialize_selected_sl_buffer_maps,.-md2asm_initialize_selected_sl_buffer_maps
.Lcopy:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#8
 b.ne .Lcopy
 ret
.Lnegative:
 str x11,[x9],#8
 subs w10,w10,#1
 b.ne .Lnegative
 ret
.Ldescriptor:
 stp x10,xzr,[x9]
 mov x12,#-1
 str x12,[x9,#8]
 mov x12,#8
 str x12,[x9,#16]
 str wzr,[x9,#24]
 mov w12,#0x301
 strh w12,[x9,#28]
 strh wzr,[x9,#30]
 mov x12,#8
 str x12,[x9,#32]
 mov x12,#1
 stp x12,x12,[x9,#40]
 str x11,[x9,#56]
 ret
.p2align 4
.global md2asm_release_selected_sl_buffer_maps
.type md2asm_release_selected_sl_buffer_maps,%function
md2asm_release_selected_sl_buffer_maps:
 cbz x0,.Lbad
 tst x0,#7
 b.ne .Lbad
 mov x9,#(4275088&65535)
 movk x9,#65,lsl#16
 cmp x1,x9
 b.lo .Lbad
 stp x18,x30,[sp,#-32]!
 str x19,[sp,#16]
 mov x19,x0
 AT x9,x19,RPARSL15
 ldr x0,[x9]
 cbz x0,.Lrelease_first
 str xzr,[x9]
 bl free
.Lrelease_first:
 AT x9,x19,RPARSL1
 ldr x0,[x9]
 cbz x0,.Lrelease_done
 str xzr,[x9]
 bl free
.Lrelease_done:
 mov w0,#0
 ldr x19,[sp,#16]
 ldp x18,x30,[sp],#32
 ret
.size md2asm_release_selected_sl_buffer_maps,.-md2asm_release_selected_sl_buffer_maps
.section .rodata
.Lnamdyn:.ascii "NAMDYN"
.Lnamdyna:.ascii "NAMDYNA"
.section .note.GNU-stack,"",%progbits

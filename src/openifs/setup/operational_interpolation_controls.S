/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md. */
/* Operational NAMDYN intake and accepted consumed SUDYN controls.
 * Contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md. */
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
.global md2asm_initialize_operational_interpolation_controls
.type md2asm_initialize_operational_interpolation_controls,%function
md2asm_initialize_operational_interpolation_controls:
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x4,.Lbad
 cbz x3,.Lbad
 cmp x3,#64,lsl#12
 b.hi .Lbad
 mrs x9,fpcr
 cbnz x9,.Lbad
 tst x0,#7
 b.ne .Lbad
 tst x4,#3
 b.ne .Lbad
 mov x9,#(4275088&65535)
 movk x9,#65,lsl#16
 cmp x1,x9
 b.lo .Lbad
 adds x10,x0,x9
 b.cs .Lbad
 adds x11,x2,x3
 b.cs .Lbad
 adds x12,x4,#16
 b.cs .Lbad
 cmp x10,x2
 b.ls .Lop_text_clear
 cmp x0,x11
 b.lo .Lbad
.Lop_text_clear:
 cmp x10,x4
 b.ls .Lop_platform_clear
 cmp x0,x12
 b.lo .Lbad
.Lop_platform_clear:
 ldp w9,w10,[x4]
 cmp w9,#1
 b.ne .Lbad
 cmp w10,#1
 b.ne .Lbad
 ldp w9,w10,[x4,#8]
 cbnz w9,.Lbad
 cmp w10,#1
 b.ne .Lbad
 stp x18,x30,[sp,#-96]!
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
 str wzr,[sp,#64]
 mov w9,#3
 str w9,[sp,#68]
 mov x0,x20
 add x1,x20,x21
 adr x2,.Lop_namdyn
 mov x3,#6
 adr x4,.Lop_namdyn_keys
 add x5,sp,#64
 bl md2asm_parse_bounded_scalar_group
 cbnz w0,.Lcontrols_done
 ldp w11,w12,[sp,#64]
 AT x9,x19,1569164
 str w11,[x9]
 AT x9,x19,1568808
 str w12,[x9]
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
 ldp x18,x30,[sp],#96
 ret
.size md2asm_initialize_operational_interpolation_controls,.-md2asm_initialize_operational_interpolation_controls
.Lbad:
 mov w0,#2
 ret
.p2align 3
.Lop_namdyn: .ascii "NAMDYN"
.p2align 3
.Lop_namdyn_keys:
 .word 7,2,0,0,1,0
 .ascii "LMASCOR"
 .zero 9
 .word 5,1,4,3,3,0
 .ascii "NITMP"
 .zero 11
 .zero 40
.section .note.GNU-stack,"",%progbits

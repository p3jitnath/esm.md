
/* Complete selected SPCHOR; source physics and ordered contract froze before emission.
 * Physics: formulations/openifs/dynamics/spectral_horizontal_diffusion.md.
 * Contract: skills/md2asm/references/openifs/dynamics/spectral_horizontal_diffusion.md.
 * Nineteen ordinary pointers retain all source array descriptors.
 * This body owns every selected division and temperature correction.
 */
.arch armv8.2-a+simd
.equ G_NS_MAX,5172
.equ G_NUMP,5212
.equ G_NFLEVL,5228
.equ M_GCONF,8
.equ M_DYN,1564136
.equ M_LSTRHD,1565680
.equ M_LM0DAMP,1565704
.equ M_LNHDYN,1564144
.equ M_LNHX,1564176
.equ M_LSLHD_W,1564216
.equ M_LSLHD_SVD,1564228
.equ M_LSLHD_STATIC,1564240
.equ M_LRHD_DDH,4233024
.equ M_LSPT,188
.equ M_TDT,1359536
.equ M_LNSPONGE,1570400
.equ M_LSTOPH_SPBS,4127816
.equ M_LSTOPH_CASBS,4127860
.equ M_LSPBSDISS,4127900
.equ M_LVORTCON,4127864
.equ M_GFL,192
.equ G_NPTRLL,5896
.equ G_NVALUE,3848
.equ G_MYMS,3912
.equ G_NASM0,3720
.equ M_RCORDIT,1566736
.equ M_RDIVOR,1564952
.equ M_RDIDIV,1565040
.equ M_RDITG,1565128
.equ M_RDISP,1565504
.equ M_RDIGFL,1565216
.equ M_RDSVOR,1566216
.equ M_RDSDIV,1566304
.equ M_RSPONGF,1570408
.equ GFL_YA_POINTER,799984
.equ GFL_YI_POINTER,799848
.equ GFL_YL_POINTER,799856
.equ GFL_YO3_POINTER,799992
.equ GFL_YQ_POINTER,799840
.text
.p2align 4
.macro arg reg,index
 ldr \reg,[sp,#(128+8*\index)]
.endm
.macro record reg,base,offset
 movz \reg,#(\offset & 65535)
 movk \reg,#((\offset >> 16) & 65535),lsl #16
 add \reg,\base,\reg
.endm
/* x0 is a descriptor. x1 is the required row upper bound, x2 the column bound. */
.macro check_real2 lower
 ldr x10,[x0,#16]
 cmp x10,#8
 b.ne .Lunsupported
 ldr x10,[x0,#24]
 ubfx x11,x10,#32,#8
 cmp x11,#2
 b.ne .Lunsupported
 lsr x11,x10,#40
 cmp x11,#3
 b.ne .Lunsupported
 ldr x10,[x0,#32]
 cmp x10,#8
 b.ne .Lunsupported
 ldr x10,[x0,#40]
 cmp x10,#1
 b.ne .Lunsupported
 ldr x10,[x0,#48]
 cmp x10,#1
 b.ne .Lunsupported
 ldr x12,[x0,#56]
 cmp x12,x1
 b.lt .Lunsupported
 cmp x12,#256
 b.hi .Lunsupported
 ldr x14,[x0,#64]
 cmp x14,x12
 b.ne .Lunsupported
 ldr x10,[x0,#72]
 cmp x10,#\lower
 b.ne .Lunsupported
 ldr x10,[x0,#80]
 cmp x10,x2
 b.lt .Lunsupported
 ldr x13,[x0]
 cbz x13,.Lunsupported
 lsl x14,x14,#3
.endm
/* x0 is a dense rank-one descriptor, x1 its required last subscript. */
.macro check_one type,element,lower
 ldr x10,[x0,#16]
 cmp x10,#\element
 b.ne .Lunsupported
 ldr x10,[x0,#24]
 ubfx x11,x10,#32,#8
 cmp x11,#1
 b.ne .Lunsupported
 lsr x11,x10,#40
 cmp x11,#\type
 b.ne .Lunsupported
 ldr x10,[x0,#32]
 cmp x10,#\element
 b.ne .Lunsupported
 ldr x10,[x0,#40]
 cmp x10,#1
 b.ne .Lunsupported
 ldr x10,[x0,#48]
 cmp x10,#\lower
 b.ne .Lunsupported
 ldr x10,[x0,#56]
 cmp x10,x1
 b.lt .Lunsupported
 ldr x13,[x0]
 cbz x13,.Lunsupported
.endm
/* The magnitude bound keeps every four-factor source product finite. */
.macro bounded address,rate=0
 ldr x10,[\address]
 ubfx x11,x10,#52,#11
 cmp x11,#1151
 b.hs .Lunsupported
.if \rate
 tbz x10,#63,92f
 and x11,x10,#0x7fffffffffffffff
 cbnz x11,.Lunsupported
92:
.endif
.endm
.global md2asm_spchor_7259755
.type md2asm_spchor_7259755,%function
md2asm_spchor_7259755:
 mov x16,sp
 sub sp,sp,#1024
 stp x0,x1,[sp,#128]
 stp x2,x3,[sp,#144]
 stp x4,x5,[sp,#160]
 stp x6,x7,[sp,#176]
 add x9,sp,#192
 mov x10,#11
.Lsave_arguments:
 ldr x11,[x16],#8
 str x11,[x9],#8
 subs x10,x10,#1
 b.ne .Lsave_arguments
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
 mov x19,x0
 mov x20,x1
 mrs x9,fpcr
 cbnz x9,.Lunsupported
 record x9,x19,G_NFLEVL
 ldr w21,[x9]
 cmp w21,#1
 b.lt .Lunsupported
 cmp w21,#256
 b.gt .Lunsupported
 record x9,x19,G_NS_MAX
 ldr w22,[x9]
 cmp w22,#256
 b.hi .Lunsupported
 record x9,x19,G_NUMP
 ldr w23,[x9]
 add w9,w22,#1
 cmp w23,w9
 b.ne .Lunsupported
 arg x9,2
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lunsupported
 arg x9,3
 ldr w26,[x9]
 add w9,w22,#1
 add w10,w22,#2
 mul w9,w9,w10
 cmp w26,w9
 b.ne .Lunsupported
 record x9,x20,M_LSTRHD
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,M_LM0DAMP
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,M_LNHDYN
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,M_LNHX
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,M_LSLHD_W
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,M_LSLHD_SVD
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,M_LRHD_DDH
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,M_LNSPONGE
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,M_LSTOPH_SPBS
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,M_LSTOPH_CASBS
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,M_LVORTCON
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 record x9,x20,M_LSPT
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lunsupported
 adrp x9,:got:__yomnud_MOD_lnudg
 ldr x9,[x9,:got_lo12:__yomnud_MOD_lnudg]
 ldr w10,[x9]
 cbnz w10,.Lunsupported
 adrp x9,:got:__yommp0_MOD_mysetv
 ldr x9,[x9,:got_lo12:__yommp0_MOD_mysetv]
 ldr w24,[x9]
 cmp w24,#1
 b.lt .Lunsupported
 record x0,x19,G_NPTRLL
 mov x1,x24
 check_one 1,4,1
 sub x9,x24,#1
 ldr w25,[x13,x9,lsl #2]
 subs w25,w25,#1
 b.mi .Lunsupported
 add x24,x25,x21
 cmp x24,#256
 b.gt .Lunsupported
 record x0,x19,G_MYMS
 mov x1,x23
 check_one 1,4,1
 str x13,[sp,#560]
 record x0,x19,G_NASM0
 mov x1,x22
 check_one 1,4,0
 str x13,[sp,#568]
 arg x0,4
 mov x1,x21
 mov x2,x26
 check_real2 1
 str x13,[sp,#504]
 str x14,[sp,#536]
 arg x0,5
 mov x1,x21
 mov x2,x26
 check_real2 1
 str x13,[sp,#512]
 str x14,[sp,#544]
 arg x0,6
 mov x1,x21
 mov x2,x26
 check_real2 1
 str x13,[sp,#520]
 str x14,[sp,#552]
 arg x0,11
 mov x1,x26
 check_one 3,8,1
 str x13,[sp,#528]
 record x0,x20,M_RDIVOR
 mov x1,x21
 mov x2,x22
 check_real2 0
 str x13,[sp,#584]
 str x14,[sp,#592]
 record x0,x20,M_RDIDIV
 mov x1,x21
 mov x2,x22
 check_real2 0
 str x13,[sp,#600]
 str x14,[sp,#608]
 record x0,x20,M_RDITG
 mov x1,x24
 mov x2,x22
 check_real2 0
 str x13,[sp,#616]
 str x14,[sp,#624]
 record x0,x20,M_RCORDIT
 mov x1,x24
 check_one 3,8,1
 str x13,[sp,#576]
 record x9,x20,M_TDT
 bounded x9
 ldr d16,[x9]
 fabs d16,d16
 str d16,[sp,#496]
 fmov d17,#1.0
 /* Validate the complete unique order set, intervals and finite active inputs. */
 mov x27,#0
.Lpreflight_block:
 ldr x9,[sp,#560]
 ldr w28,[x9,x27,lsl #2]
 cmp w28,w22
 b.hi .Lunsupported
 ldr x9,[sp,#568]
 ldr w5,[x9,x28,lsl #2]
 cmp w5,#1
 b.lt .Lunsupported
 sub w6,w22,w28
 add w6,w5,w6,lsl #1
 add w6,w6,#1
 cmp w6,w26
 b.hi .Lunsupported
 mov x7,#0
.Lpreflight_previous:
 cmp x7,x27
 b.ge .Lpreflight_order_done
 ldr x9,[sp,#560]
 ldr w8,[x9,x7,lsl #2]
 cmp w8,w28
 b.eq .Lunsupported
 ldr x9,[sp,#568]
 ldr w9,[x9,x8,lsl #2]
 sub w10,w22,w8
 add w10,w9,w10,lsl #1
 add w10,w10,#1
 cmp w6,w9
 b.lt .Lpreflight_previous_next
 cmp w10,w5
 b.ge .Lunsupported
.Lpreflight_previous_next:
 add x7,x7,#1
 b .Lpreflight_previous
.Lpreflight_order_done:
 cbz x28,.Lpreflight_next_block
 mov x29,x28
.Lpreflight_degree:
 ldr x9,[sp,#568]
 ldr w5,[x9,x28,lsl #2]
 sub x5,x5,#1
 sub x9,x29,x28
 add x5,x5,x9,lsl #1
 str x5,[sp,#632]
 mov x4,#0
.Lpreflight_level:
 ldr x9,[sp,#504]
 ldr x12,[sp,#536]
 madd x9,x5,x12,x9
 add x9,x9,x4,lsl #3
 bounded x9
 add x9,x9,x12
 bounded x9
 ldr x9,[sp,#512]
 ldr x12,[sp,#544]
 madd x9,x5,x12,x9
 add x9,x9,x4,lsl #3
 bounded x9
 add x9,x9,x12
 bounded x9
 ldr x9,[sp,#520]
 ldr x12,[sp,#552]
 madd x9,x5,x12,x9
 add x9,x9,x4,lsl #3
 bounded x9
 add x9,x9,x12
 bounded x9
 ldr x9,[sp,#528]
 add x9,x9,x5,lsl #3
 bounded x9
 add x9,x9,#8
 bounded x9
 ldr x9,[sp,#584]
 ldr x12,[sp,#592]
 madd x9,x29,x12,x9
 mov x11,x4
 add x9,x9,x11,lsl #3
 bounded x9,1
 ldr x9,[sp,#600]
 ldr x12,[sp,#608]
 madd x9,x29,x12,x9
 mov x11,x4
 add x9,x9,x11,lsl #3
 bounded x9,1
 ldr x9,[sp,#616]
 ldr x12,[sp,#624]
 madd x9,x29,x12,x9
 add x11,x4,x25
 add x9,x9,x11,lsl #3
 bounded x9,1
 ldr x9,[sp,#576]
 add x11,x4,x25
 add x9,x9,x11,lsl #3
 bounded x9
 add x4,x4,#1
 cmp x4,x21
 b.lt .Lpreflight_level
 add x29,x29,#1
 cmp x29,x22
 b.le .Lpreflight_degree
.Lpreflight_next_block:
 add x27,x27,#1
 cmp x27,x23
 b.lt .Lpreflight_block
 /* Each source order is complete before the next one begins. */
 mov x27,#0
.Lupdate_block:
 ldr x9,[sp,#560]
 ldr w28,[x9,x27,lsl #2]
 cbz x28,.Lupdate_next_block
 mov x29,x28
.Lupdate_degree:
 ldr x9,[sp,#568]
 ldr w5,[x9,x28,lsl #2]
 sub x5,x5,#1
 sub x9,x29,x28
 add x5,x5,x9,lsl #1
 str x5,[sp,#632]
 mov x4,#0
.Lwind_level:
 ldr x9,[sp,#584]
 ldr x10,[sp,#592]
 madd x9,x29,x10,x9
 ldr d0,[x9,x4,lsl #3]
 fmul d1,d16,d0
 fadd d1,d17,d1
 ldr x9,[sp,#504]
 ldr x12,[sp,#536]
 ldr x5,[sp,#632]
 madd x9,x5,x12,x9
 add x9,x9,x4,lsl #3
 ldr d2,[x9]
 fdiv d2,d2,d1
 str d2,[x9]
 add x9,x9,x12
 ldr d2,[x9]
 fdiv d2,d2,d1
 str d2,[x9]
 ldr x9,[sp,#600]
 ldr x10,[sp,#608]
 madd x9,x29,x10,x9
 ldr d0,[x9,x4,lsl #3]
 fmul d1,d16,d0
 fadd d1,d17,d1
 ldr x9,[sp,#512]
 ldr x12,[sp,#544]
 ldr x5,[sp,#632]
 madd x9,x5,x12,x9
 add x9,x9,x4,lsl #3
 ldr d2,[x9]
 fdiv d2,d2,d1
 str d2,[x9]
 add x9,x9,x12
 ldr d2,[x9]
 fdiv d2,d2,d1
 str d2,[x9]
 add x4,x4,#1
 cmp x4,x21
 b.lt .Lwind_level
 mov x4,#0
.Ltemperature_level:
 ldr x9,[sp,#616]
 ldr x10,[sp,#624]
 madd x9,x29,x10,x9
 add x11,x4,x25
 ldr d1,[x9,x11,lsl #3]
 ldr x9,[sp,#576]
 ldr d0,[x9,x11,lsl #3]
 ldr x9,[sp,#528]
 ldr x5,[sp,#632]
 add x9,x9,x5,lsl #3
 ldr d2,[x9]
 fmul d2,d0,d2
 fmul d2,d2,d16
 fmul d2,d2,d1
 ldr x11,[sp,#520]
 ldr x12,[sp,#552]
 madd x11,x5,x12,x11
 add x11,x11,x4,lsl #3
 ldr d3,[x11]
 fadd d3,d3,d2
 fmul d4,d16,d1
 fadd d4,d17,d4
 fdiv d3,d3,d4
 str d3,[x11]
 ldr d2,[x9,#8]
 fmul d2,d0,d2
 fmul d2,d2,d16
 fmul d2,d2,d1
 add x11,x11,x12
 ldr d3,[x11]
 fadd d3,d3,d2
 fdiv d3,d3,d4
 str d3,[x11]
 add x4,x4,#1
 cmp x4,x21
 b.lt .Ltemperature_level
 add x29,x29,#1
 cmp x29,x22
 b.le .Lupdate_degree
.Lupdate_next_block:
 add x27,x27,#1
 cmp x27,x23
 b.lt .Lupdate_block
 adrp x9,.Lcalls
 add x9,x9,:lo12:.Lcalls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x18,[sp,#480]
 add x9,sp,#320
 ldp d8,d9,[x9,#96]
 ldp d10,d11,[x9,#112]
 ldp d12,d13,[x9,#128]
 ldp d14,d15,[x9,#144]
 ldp x19,x20,[x9,#0]
 ldp x21,x22,[x9,#16]
 ldp x23,x24,[x9,#32]
 ldp x25,x26,[x9,#48]
 ldp x27,x28,[x9,#64]
 ldp x29,x30,[x9,#80]
 add sp,sp,#1024
 ret
.Lunsupported:
 bl abort
 brk #0
.size md2asm_spchor_7259755,.-md2asm_spchor_7259755
.global md2asm_spchor_calls_get
.type md2asm_spchor_calls_get,%function
md2asm_spchor_calls_get:
 adrp x9,.Lcalls
 ldr x0,[x9,:lo12:.Lcalls]
 ret
.bss
.p2align 3
.Lcalls:.zero 8
.section .note.GNU-stack,"",%progbits

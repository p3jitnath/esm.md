/* Atmospheric emission from formulations/openifs/physics/atmospheric_thermal_emission.md.
 * Frozen arithmetic and ABI are in skills/md2asm/references/openifs/physics/planck_function_atmos.md.
 */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __radiation_ifs_rrtm_MOD_planck_function_atmos
#endif
.text
.p2align 4
.global md2asm_planck_function_atmos
.global ORIGINAL_SYMBOL
.type md2asm_planck_function_atmos,%function
.type ORIGINAL_SYMBOL,%function
md2asm_planck_function_atmos:
ORIGINAL_SYMBOL:
 sub sp,sp,#224
 stp x19,x20,[sp,#0]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 stp x29,x30,[sp,#80]
 stp d8,d9,[sp,#96]
 stp d10,d11,[sp,#112]
 stp d12,d13,[sp,#128]
 stp d14,d15,[sp,#144]
 ldr w19,[x0]
 ldr w20,[x1]
 ldr w21,[x2]
 sub w21,w21,w20
 add w21,w21,#1
 cbz x21,.Lreturn
 mov x22,x3
 mov x23,x5
 mov x24,x6
 mov x8,#20000
 add x8,x22,x8
 ldr w26,[x8]
 cbz x26,.Lreturn
 add x8,x4,#88
 ldr x25,[x8,#0]
 ldr x9,[x8,#8]
 ldr x10,[x8,#80]
 sub x10,x10,x19
 ldr x11,[x8,#64]
 madd x9,x10,x11,x9
 ldr x12,[x8,#40]
 madd x9,x20,x12,x9
 add x25,x25,x9,lsl #3
 lsl x11,x11,#3
 str x11,[sp,#160]
 add x8,x19,#1
 str x8,[sp,#176]
 ldr w8,[x22,#624]
 cmp w8,#3
 b.eq .Lreordered
 ldr x8,[x22,#10608]
 str x8,[sp,#184]
 str xzr,[sp,#192]
 b .Lmaps_ready
.Lreordered:
 ldr x8,[x22,#10864]
 str x8,[sp,#184]
 ldr x8,[x22,#10736]
 str x8,[sp,#192]
.Lmaps_ready:
 adrp x22,:got:__yoerrtwn_MOD_totplnk
 ldr x22,[x22,:got_lo12:__yoerrtwn_MOD_totplnk]
 adrp x20,:got:__yoerrtwn_MOD_delwave
 ldr x20,[x20,:got_lo12:__yoerrtwn_MOD_delwave]
 adrp x8,.Lconstants
 add x8,x8,:lo12:.Lconstants
 ldr d10,[x8,#32]
 fmov d0,#2.0
 fmul d10,d10,d0
 ldr d0,[x8,#24]
 fmul d10,d10,d0
 mov x28,#0
.Llevel:
 sub x15,x19,x28
 cbnz x28,.Lfraction_level
 sub x15,x19,#1
.Lfraction_level:
 mov x10,#0
.Lcolumn:
 ldr d8,[x25,x10,lsl #3]
 adrp x8,.Lconstants
 add x8,x8,:lo12:.Lconstants
 ldp d0,d1,[x8,#0]
 fcmp d8,d1
 b.ge .Lhot
 fcmp d8,d0
 b.lt .Lcold
 ldr d0,[x8,#16]
 fsub d0,d8,d0
 fcvtzs w12,d0
 sub w12,w12,#1
 fcvtzs w8,d8
 scvtf d0,w8
 fsub d9,d8,d0
 b .Ltemperature_ready
.Lhot:
 mov w12,#179
 fsub d9,d8,d1
 b .Ltemperature_ready
.Lcold:
 mov w12,wzr
 fmov d9,xzr
.Ltemperature_ready:
 mov x11,#0
.Lsample:
 ldr x8,[sp,#184]
 ldr w13,[x8,x11,lsl #2]
 sub w13,w13,#1
 ldr x8,[sp,#192]
 cbz x8,.Lordinary_sample
 ldr w14,[x8,x11,lsl #2]
 sub w14,w14,#1
 b .Lsample_ready
.Lordinary_sample:
 mov x14,x11
.Lsample_ready:
 mov x16,#181
 madd x16,x13,x16,x12
 add x16,x22,x16,lsl #3
 ldp d1,d2,[x16]
 ldr d0,[x20,x13,lsl #3]
 fmul d0,d10,d0
 fsub d2,d2,d1
 fmul d2,d9,d2
 fadd d1,d1,d2
 fmul d0,d0,d1
 mov x8,#140
 madd x8,x15,x8,x14
 madd x8,x8,x21,x10
 ldr d1,[x23,x8,lsl #3]
 fmul d0,d0,d1
 ldr x8,[sp,#176]
 madd x8,x10,x8,x28
 madd x8,x8,x26,x11
 str d0,[x24,x8,lsl #3]
 add x11,x11,#1
 cmp x11,x26
 b.lo .Lsample
 add x10,x10,#1
 cmp x10,x21
 b.lo .Lcolumn
 ldr x8,[sp,#160]
 add x25,x25,x8
 add x28,x28,#1
 cmp x28,x19
 b.ls .Llevel
.Lreturn:
 ldp d14,d15,[sp,#144]
 ldp d12,d13,[sp,#128]
 ldp d10,d11,[sp,#112]
 ldp d8,d9,[sp,#96]
 ldp x29,x30,[sp,#80]
 ldp x27,x28,[sp,#64]
 ldp x25,x26,[sp,#48]
 ldp x23,x24,[sp,#32]
 ldp x21,x22,[sp,#16]
 ldp x19,x20,[sp,#0]
 add sp,sp,#224
 ret
.size md2asm_planck_function_atmos,.-md2asm_planck_function_atmos
.size ORIGINAL_SYMBOL,.-ORIGINAL_SYMBOL
.section .rodata
.p2align 3
.Lconstants:
 .double 160.0,339.0,159.0,10000.0
 .xword 0x3ff921fb54442d18
.section .note.GNU-stack,"",%progbits

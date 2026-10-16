/* Contract: skills/md2asm/references/openifs/radiation/spectral_planck_setup.md.
 * Raw selected INIT calculation: x0 valid owned record240, x1 constants520.
 * Output LUT is zeroed, bounds/map are source-defined and live. Frame192B. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_fill_selected_spectral_planck_table
.type md2asm_fill_selected_spectral_planck_table,%function
md2asm_fill_selected_spectral_planck_table:
 stp x29,x30,[sp,#-192]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 ldr x21,[x19,#24]
 ldr x22,[x19,#112]
 ldr x23,[x19,#176]
 fmov d0,#2.0
 ldr d1,[x20]
 fmul d0,d0,d1
 ldr d1,[x20,#16]
 fmul d0,d0,d1
 ldr d1,[x20,#8]
 fmul d0,d0,d1
 fmul d0,d0,d1
 str d0,[sp,#96]
 ldr d0,[x20,#16]
 fmul d0,d0,d1
 ldr d1,[x20,#24]
 fdiv d0,d0,d1
 str d0,[sp,#104]
 mov x24,#0
.Lspt_temperature:
 scvtf d0,x24
 ldr d1,[x19,#16]
 fmul d0,d0,d1
 ldr d1,[x19,#8]
 fadd d0,d1,d0
 str d0,[sp,#112]
 mov x25,#0
.Lspt_range:
 cbz x25,.Lspt_first
 cmp x25,#2
 b.eq .Lspt_last
 ldp d0,d1,[x22]
 b .Lspt_bounds
.Lspt_first:
 ldr d1,[x22]
 adr x9,.Lspt_range_constants
 ldr d0,[x9,#8]
 fmul d0,d0,d1
 ldr d2,[x9]
 fmin d0,d2,d0
 b .Lspt_bounds
.Lspt_last:
 ldr d0,[x22,#8]
 adr x9,.Lspt_range_constants
 ldp d1,d2,[x9,#16]
 fadd d2,d0,d2
 fmax d1,d1,d2
.Lspt_bounds:
 str d0,[sp,#120]
 fsub d0,d1,d0
 adr x9,.Lspt_range_constants
 ldr d1,[x9,#32]
 fdiv d0,d0,d1
 str d0,[sp,#128]
 str xzr,[sp,#136]
 mov x26,#0
.Lspt_wavelength:
 mov w9,#1
 cbz x26,.Lspt_weight
 cmp x26,#100
 b.eq .Lspt_weight
 and w9,w26,#1
 lsl w9,w9,#1
 add w9,w9,#2
.Lspt_weight:
 scvtf d0,w9
 str d0,[sp,#160]
 scvtf d0,x26
 ldr d1,[sp,#128]
 fmul d0,d1,d0
 ldr d1,[sp,#120]
 fadd d0,d1,d0
 str d0,[sp,#144]
 fmul d1,d0,d0
 str d1,[sp,#152]
 ldr d1,[sp,#112]
 fmul d0,d0,d1
 ldr d1,[sp,#104]
 fdiv d0,d1,d0
 bl md2asm_exp_original_rounding
 ldr x18,[sp,#80]
 fmov d1,#1.0
 fsub d0,d0,d1
 ldr d1,[sp,#152]
 fmul d1,d1,d1
 ldr d2,[sp,#144]
 fmul d1,d1,d2
 fmul d0,d1,d0
 ldr d1,[sp,#160]
 fdiv d0,d1,d0
 ldr d1,[sp,#136]
 fadd d0,d1,d0
 str d0,[sp,#136]
 add x26,x26,#1
 cmp x26,#100
 b.ls .Lspt_wavelength
 ldr d0,[sp,#96]
 ldr d1,[sp,#136]
 fmul d0,d0,d1
 ldr d1,[sp,#128]
 fmul d0,d0,d1
 fmov d1,#3.0
 fdiv d0,d0,d1
 ldr w9,[x23,x25,lsl#2]
 sub w9,w9,#1
 add x9,x9,x24,lsl#1
 ldr d1,[x21,x9,lsl#3]
 fadd d0,d1,d0
 str d0,[x21,x9,lsl#3]
 add x25,x25,#1
 cmp x25,#3
 b.lo .Lspt_range
 add x24,x24,#1
 cmp x24,#201
 b.lo .Lspt_temperature
 ldr x18,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#192
 ret
.size md2asm_fill_selected_spectral_planck_table,.-md2asm_fill_selected_spectral_planck_table
.section .rodata
.p2align 3
.Lspt_range_constants: .double 1.0e-6,0.8,200.0e-6,20.0e-6,100.0
.section .note.GNU-stack,"",%progbits

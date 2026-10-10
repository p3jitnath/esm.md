/* Compute band-20 water, methane, Rayleigh and solar outputs.
 * Columns count approximately 10^20 molecules/cm^2. Coefficients have
 * the inverse unit, optical depths have no unit, and solar is W/m^2.
 * The frozen 25-pointer interface uses complete 16-point storage.
 * Preserve original rounded operations, inactive bytes and saved registers. */
.text
.p2align 2
.global srtm_taumol20_assembly_
.type srtm_taumol20_assembly_,%function
srtm_taumol20_assembly_:
 ldr w9,[x2]
 ldr w10,[x1]
 sub w9,w9,w10
 add w9,w9,#1
 cbz w9,.Lempty
 ldr w10,[x3]
 cbz w10,.Lempty
 sub sp,sp,#320
 stp x19,x20,[sp,#0]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 stp x29,x30,[sp,#80]
 stp x0,x1,[sp,#96]
 stp x2,x3,[sp,#112]
 stp x4,x5,[sp,#128]
 stp x6,x7,[sp,#144]
 ldp x11,x12,[sp,#320]
 stp x11,x12,[sp,#160]
 ldp x11,x12,[sp,#336]
 stp x11,x12,[sp,#176]
 ldp x11,x12,[sp,#352]
 stp x11,x12,[sp,#192]
 ldp x11,x12,[sp,#368]
 stp x11,x12,[sp,#208]
 ldp x11,x12,[sp,#384]
 stp x11,x12,[sp,#224]
 ldp x11,x12,[sp,#400]
 stp x11,x12,[sp,#240]
 ldp x11,x12,[sp,#416]
 stp x11,x12,[sp,#256]
 ldp x11,x12,[sp,#432]
 stp x11,x12,[sp,#272]
 ldr x11,[sp,#448]
 str x11,[sp,#288]
 uxtw x19,w9
 uxtw x20,w10
 ldr w21,[x0]
 mul x22,x19,x21
 lsl x22,x22,#3
 mov x23,#0
/* Independent columns own their solar selection. */
.Lcolumn:
 ldr x15,[sp,#288]
 ldr d24,[x15,x23,lsl #3]
 fcmp d24,#0.0
 b.le .Lnext_column
 ldr x15,[sp,#208]
 ldr w29,[x15,x23,lsl #2]
 mov x30,x29
 mov x24,#0
.Llayer:
 mul x25,x24,x19
 add x25,x25,x23
 lsl x26,x25,#3
 lsl x28,x25,#2
 ldr x15,[sp,#128]
 ldr d0,[x15,x26]
 ldr x15,[sp,#136]
 ldr d1,[x15,x26]
 ldr x15,[sp,#144]
 ldr d2,[x15,x26]
 ldr x15,[sp,#152]
 ldr d3,[x15,x26]
 ldr x15,[sp,#184]
 ldr d4,[x15,x26]
 ldr x15,[sp,#192]
 ldr d5,[x15,x26]
 ldr x15,[sp,#200]
 ldr d6,[x15,x26]
 adrp x15,:got:__yoesrta20_MOD_rayl
 ldr x15,[x15,:got_lo12:__yoesrta20_MOD_rayl]
 ldr d7,[x15]
 fmul d7,d6,d7
 ldr x15,[sp,#240]
 ldr d18,[x15,x26]
 ldr x15,[sp,#248]
 ldr d19,[x15,x26]
 ldr x15,[sp,#256]
 ldr w11,[x15,x28]
 sub w11,w11,#1
 uxtw x11,w11
 lsl x11,x11,#3
 adrp x15,:got:__yoesrta20_MOD_forrefc
 ldr x15,[x15,:got_lo12:__yoesrta20_MOD_forrefc]
 add x11,x15,x11
 adrp x12,:got:__yoesrta20_MOD_absch4c
 ldr x12,[x12,:got_lo12:__yoesrta20_MOD_absch4c]
 ldr x16,[sp,#272]
 add x16,x16,x26
 ldr x17,[sp,#280]
 add x17,x17,x26
 mov x27,#0
 cmp x24,x29
 b.hs .Lupper_setup
/* Lower layers include self and foreign continua. */
 ldr x15,[sp,#216]
 ldr d16,[x15,x26]
 ldr x15,[sp,#224]
 ldr d17,[x15,x26]
 ldr x15,[sp,#232]
 ldr w10,[x15,x28]
 sub w10,w10,#1
 uxtw x10,w10
 lsl x10,x10,#3
 adrp x15,:got:__yoesrta20_MOD_selfrefc
 ldr x15,[x15,:got_lo12:__yoesrta20_MOD_selfrefc]
 add x10,x15,x10
 ldr x15,[sp,#160]
 ldr w0,[x15,x28]
 add x1,x25,x19
 ldr w1,[x15,x1,lsl #2]
 adrp x15,:got:__yoesrta20_MOD_layreffr
 ldr x15,[x15,:got_lo12:__yoesrta20_MOD_layreffr]
 ldr w2,[x15]
 cmp w0,w2
 b.ge .Lsolar_layer_kept
 cmp w1,w2
 b.lt .Lsolar_layer_kept
 add x30,x24,#2
 cmp x30,x29
 csel x30,x30,x29,lo
.Lsolar_layer_kept:
 add x1,x24,#1
 cmp x1,x30
 cset w15,eq
 str w15,[sp,#296]
 ldr x15,[sp,#168]
 ldr w1,[x15,x28]
 ldr x15,[sp,#176]
 ldr w2,[x15,x28]
 adrp x15,:got:__yoesrtwn_MOD_nspa
 ldr x15,[x15,:got_lo12:__yoesrtwn_MOD_nspa]
 ldr w15,[x15,#16]
 sub w3,w0,#1
 add w3,w3,w3,lsl #2
 sub w1,w1,#1
 add w3,w3,w1
 mul w3,w3,w15
 add w0,w0,w0,lsl #2
 sub w2,w2,#1
 add w0,w0,w2
 mul w0,w0,w15
 uxtw x1,w0
 lsl x1,x1,#3
 uxtw x0,w3
 lsl x0,x0,#3
 adrp x8,:got:yoesrta20.eq.1_
 ldr x8,[x8,:got_lo12:yoesrta20.eq.1_]
 add x9,x8,x1
 add x8,x8,x0
 adrp x13,:got:__yoesrta20_MOD_sfluxrefc
 ldr x13,[x13,:got_lo12:__yoesrta20_MOD_sfluxrefc]
 ldr x14,[sp,#264]
 add x14,x14,x23,lsl #3
.Llower_point:
 ldr d24,[x8]
 fmul d24,d0,d24
 ldr d25,[x8,#8]
 fmul d25,d2,d25
 fadd d24,d24,d25
 ldr d25,[x9]
 fmul d25,d1,d25
 fadd d24,d24,d25
 ldr d25,[x9,#8]
 fmul d25,d3,d25
 fadd d24,d24,d25
 ldr d25,[x10]
 ldr d26,[x10,#8]
 fsub d26,d26,d25
 fmul d26,d17,d26
 fadd d25,d25,d26
 fmul d25,d16,d25
 fadd d24,d24,d25
 ldr d25,[x11]
 ldr d26,[x11,#8]
 fsub d26,d26,d25
 fmul d26,d19,d26
 fadd d25,d25,d26
 fmul d25,d18,d25
 fadd d24,d24,d25
 fmul d24,d4,d24
 ldr d25,[x12]
 fmul d25,d5,d25
 fadd d24,d24,d25
 str d24,[x16]
 str d7,[x17]
 ldr w15,[sp,#296]
 cbz w15,.Lsolar_copy_done
 ldr d25,[x13]
 str d25,[x14]
.Lsolar_copy_done:
 add x8,x8,#520
 add x9,x9,#520
 add x10,x10,#80
 add x11,x11,#32
 add x12,x12,#8
 add x13,x13,#8
 add x14,x14,x19,lsl #3
 add x16,x16,x22
 add x17,x17,x22
 add x27,x27,#1
 cmp x27,#10
 b.lo .Llower_point
 b .Lnext_layer
/* Upper layers retain the foreign water continuum and methane term. */
.Lupper_setup:
 ldr x15,[sp,#160]
 ldr w0,[x15,x28]
 ldr x15,[sp,#168]
 ldr w1,[x15,x28]
 ldr x15,[sp,#176]
 ldr w2,[x15,x28]
 adrp x15,:got:__yoesrtwn_MOD_nspb
 ldr x15,[x15,:got_lo12:__yoesrtwn_MOD_nspb]
 ldr w15,[x15,#16]
 sub w3,w0,#13
 add w3,w3,w3,lsl #2
 sub w1,w1,#1
 add w3,w3,w1
 mul w3,w3,w15
 sub w0,w0,#12
 add w0,w0,w0,lsl #2
 sub w2,w2,#1
 add w0,w0,w2
 mul w0,w0,w15
 uxtw x1,w0
 lsl x1,x1,#3
 uxtw x0,w3
 lsl x0,x0,#3
 adrp x8,:got:yoesrta20.eq.0_
 ldr x8,[x8,:got_lo12:yoesrta20.eq.0_]
 add x9,x8,x1
 add x8,x8,x0
.Lupper_point:
 ldr d24,[x8]
 fmul d24,d0,d24
 ldr d25,[x8,#8]
 fmul d25,d2,d25
 fadd d24,d24,d25
 ldr d25,[x9]
 fmul d25,d1,d25
 fadd d24,d24,d25
 ldr d25,[x9,#8]
 fmul d25,d3,d25
 fadd d24,d24,d25
 ldr d25,[x11]
 ldr d26,[x11,#8]
 fsub d26,d26,d25
 fmul d26,d19,d26
 fadd d25,d25,d26
 fmul d25,d18,d25
 fadd d24,d24,d25
 fmul d24,d4,d24
 ldr d25,[x12]
 fmul d25,d5,d25
 fadd d24,d24,d25
 str d24,[x16]
 str d7,[x17]
 add x8,x8,#1880
 add x9,x9,#1880
 add x11,x11,#32
 add x12,x12,#8
 add x16,x16,x22
 add x17,x17,x22
 add x27,x27,#1
 cmp x27,#10
 b.lo .Lupper_point
.Lnext_layer:
 add x24,x24,#1
 cmp x24,x20
 b.lo .Llayer
.Lnext_column:
 add x23,x23,#1
 cmp x23,x19
 b.lo .Lcolumn
 ldp x19,x20,[sp,#0]
 ldp x21,x22,[sp,#16]
 ldp x23,x24,[sp,#32]
 ldp x25,x26,[sp,#48]
 ldp x27,x28,[sp,#64]
 ldp x29,x30,[sp,#80]
 add sp,sp,#320
.Lempty:
 ret
.size srtm_taumol20_assembly_,.-srtm_taumol20_assembly_
.section .note.GNU-stack,"",%progbits

/* Complete band-23 line absorption, both water continua and Rayleigh depth.
 * Direct emission follows the frozen Markdown/source contract.
 * Twenty-four pointer arguments use the Arm ABI and complete caller capacities.
 * A 320-byte aligned frame saves x19..x30, all pointers and the species count.
 * d8..d15 and x18 remain untouched. No helper supplies any numerical stage. */
.text
.p2align 4
.global srtm_taumol23_assembly_
.type srtm_taumol23_assembly_,%function
srtm_taumol23_assembly_:
 stp x29,x30,[sp,#-320]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 stp x0,x1,[sp,#96]
 stp x2,x3,[sp,#112]
 stp x4,x5,[sp,#128]
 stp x6,x7,[sp,#144]
 ldp x9,x10,[sp,#320]
 stp x9,x10,[sp,#160]
 ldp x9,x10,[sp,#336]
 stp x9,x10,[sp,#176]
 ldp x9,x10,[sp,#352]
 stp x9,x10,[sp,#192]
 ldp x9,x10,[sp,#368]
 stp x9,x10,[sp,#208]
 ldp x9,x10,[sp,#384]
 stp x9,x10,[sp,#224]
 ldp x9,x10,[sp,#400]
 stp x9,x10,[sp,#240]
 ldp x9,x10,[sp,#416]
 stp x9,x10,[sp,#256]
 ldp x9,x10,[sp,#432]
 stp x9,x10,[sp,#272]
 ldrsw x19,[x2]
 ldrsw x11,[x1]
 sub x19,x19,x11
 add x19,x19,#1
 ldrsw x20,[x3]
 ldrsw x21,[x0]
 cbz x19,.Lsrtm23_restore
 cbz x20,.Lsrtm23_restore
 ldr x22,[sp,#160]
 ldr x23,[sp,#200]
 ldr x24,[sp,#280]
 ldr x25,[sp,#264]
 ldr x26,[sp,#272]
 ldr x27,[sp,#256]
 adrp x28,:got:yoesrta23.eq.0_
 ldr x28,[x28,:got_lo12:yoesrta23.eq.0_]
 adrp x7,:got:__yoesrta23_MOD_raylc
 ldr x7,[x7,:got_lo12:__yoesrta23_MOD_raylc]
 adrp x8,:got:__yoesrta23_MOD_sfluxrefc
 ldr x8,[x8,:got_lo12:__yoesrta23_MOD_sfluxrefc]
 adrp x9,:got:__yoesrta23_MOD_selfrefc
 ldr x9,[x9,:got_lo12:__yoesrta23_MOD_selfrefc]
 adrp x10,:got:__yoesrta23_MOD_forrefc
 ldr x10,[x10,:got_lo12:__yoesrta23_MOD_forrefc]
 adrp x11,:got:__yoesrta23_MOD_givfac
 ldr x11,[x11,:got_lo12:__yoesrta23_MOD_givfac]
 ldr d25,[x11]
 adrp x11,:got:__yoesrta23_MOD_layreffr
 ldr x11,[x11,:got_lo12:__yoesrta23_MOD_layreffr]
 ldr w6,[x11]
 adrp x11,:got:__yoesrtwn_MOD_nspa
 ldr x11,[x11,:got_lo12:__yoesrtwn_MOD_nspa]
 ldr w11,[x11,#28]
 str w11,[sp,#288]
 mov x0,#0
.Lsrtm23_column:
 ldr d18,[x24,x0,lsl #3]
 fcmp d18,#0.0
 b.le .Lsrtm23_next_column
 ldr w4,[x23,x0,lsl #2]
 mov w5,w4
 mov x1,#0
.Lsrtm23_layer:
 madd x3,x1,x19,x0
 ldr x11,[sp,#192]
 ldr d5,[x11,x3,lsl #3]
 cmp x1,x4
 b.hs .Lsrtm23_upper
 ldr w11,[x22,x3,lsl #2]
 cmp w11,w6
 b.ge .Lsrtm23_no_crossing
 add x12,x3,x19
 ldr w12,[x22,x12,lsl #2]
 cmp w12,w6
 b.lt .Lsrtm23_no_crossing
 add w5,w1,#2
 cmp w5,w4
 csel w5,w5,w4,lo
.Lsrtm23_no_crossing:
 ldr x12,[sp,#168]
 ldr w12,[x12,x3,lsl #2]
 sub w15,w11,#1
 mov w13,#5
 mul w15,w15,w13
 sub w12,w12,#1
 add w15,w15,w12
 ldr w14,[sp,#288]
 mul w15,w15,w14
 ldr x12,[sp,#176]
 ldr w12,[x12,x3,lsl #2]
 mul w16,w11,w13
 sub w12,w12,#1
 add w16,w16,w12
 mul w16,w16,w14
 ldr x11,[sp,#224]
 ldr w14,[x11,x3,lsl #2]
 sub w14,w14,#1
 ldr x11,[sp,#248]
 ldr w17,[x11,x3,lsl #2]
 sub w17,w17,#1
 ldr x11,[sp,#128]
 ldr d0,[x11,x3,lsl #3]
 ldr x11,[sp,#144]
 ldr d1,[x11,x3,lsl #3]
 ldr x11,[sp,#136]
 ldr d2,[x11,x3,lsl #3]
 ldr x11,[sp,#152]
 ldr d3,[x11,x3,lsl #3]
 ldr x11,[sp,#184]
 ldr d4,[x11,x3,lsl #3]
 ldr x11,[sp,#208]
 ldr d6,[x11,x3,lsl #3]
 ldr x11,[sp,#216]
 ldr d7,[x11,x3,lsl #3]
 ldr x11,[sp,#232]
 ldr d16,[x11,x3,lsl #3]
 ldr x11,[sp,#240]
 ldr d17,[x11,x3,lsl #3]
 mov x2,#0
.Lsrtm23_lower_point:
 ldr d18,[x7,x2,lsl #3]
 fmul d24,d5,d18
 mov x11,#65
 madd x11,x2,x11,x15
 ldr d18,[x28,x11,lsl #3]
 fmul d18,d0,d18
 add x12,x11,#1
 ldr d19,[x28,x12,lsl #3]
 fmul d19,d1,d19
 fadd d22,d18,d19
 mov x11,#65
 madd x11,x2,x11,x16
 ldr d20,[x28,x11,lsl #3]
 fmul d20,d2,d20
 fadd d22,d22,d20
 add x12,x11,#1
 ldr d21,[x28,x12,lsl #3]
 fmul d21,d3,d21
 fadd d22,d22,d21
 fmul d22,d25,d22
 /* Self continuum retains subtraction, product, sum and density product. */
 mov x11,#10
 madd x11,x2,x11,x14
 ldr d18,[x9,x11,lsl #3]
 add x12,x11,#1
 ldr d19,[x9,x12,lsl #3]
 fsub d19,d19,d18
 fmul d19,d7,d19
 fadd d19,d18,d19
 fmul d19,d6,d19
 fadd d22,d22,d19
 /* Foreign continuum retains the same independently rounded four stages. */
 mov x11,#3
 madd x11,x2,x11,x17
 ldr d18,[x10,x11,lsl #3]
 add x12,x11,#1
 ldr d19,[x10,x12,lsl #3]
 fsub d19,d19,d18
 fmul d19,d17,d19
 fadd d19,d18,d19
 fmul d19,d16,d19
 fadd d22,d22,d19
 fmul d22,d4,d22
 madd x11,x2,x21,x1
 madd x11,x11,x19,x0
 str d22,[x25,x11,lsl #3]
 add w12,w1,#1
 cmp w12,w5
 b.ne .Lsrtm23_rayleigh_store
 madd x12,x2,x19,x0
 ldr x13,[x8,x2,lsl #3]
 str x13,[x27,x12,lsl #3]
.Lsrtm23_rayleigh_store:
 str d24,[x26,x11,lsl #3]
 add x2,x2,#1
 cmp x2,#10
 b.lo .Lsrtm23_lower_point
 b .Lsrtm23_next_layer
.Lsrtm23_upper:
 mov x2,#0
.Lsrtm23_upper_point:
 ldr d18,[x7,x2,lsl #3]
 fmul d24,d5,d18
 madd x11,x2,x21,x1
 madd x11,x11,x19,x0
 str xzr,[x25,x11,lsl #3]
 str d24,[x26,x11,lsl #3]
 add x2,x2,#1
 cmp x2,#10
 b.lo .Lsrtm23_upper_point
.Lsrtm23_next_layer:
 add x1,x1,#1
 cmp x1,x20
 b.lo .Lsrtm23_layer
.Lsrtm23_next_column:
 add x0,x0,#1
 cmp x0,x19
 b.lo .Lsrtm23_column
.Lsrtm23_restore:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#320
 ret
.size srtm_taumol23_assembly_,.-srtm_taumol23_assembly_
.section .note.GNU-stack,"",%progbits

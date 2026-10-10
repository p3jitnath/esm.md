/* Complete band-27 ozone, Rayleigh and corrected solar calculation.
 * Emit directly from the frozen Markdown/source contract.
 * The upper solar-layer scalar is shared in layer-major column order.
 * All 18 ordinary pointers use the Arm ABI. Preserve full inactive storage. */
.text
.p2align 4
.global srtm_taumol27_assembly_
.type srtm_taumol27_assembly_,%function
.macro srtm27_address reg,symbol
 adrp \reg,:got:\symbol
 ldr \reg,[\reg,:got_lo12:\symbol]
.endm
srtm_taumol27_assembly_:
 sub sp,sp,#256
 stp x19,x20,[sp,#0]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 stp x29,x30,[sp,#80]
 ldr w9,[x2]
 ldr w10,[x1]
 sub w19,w9,w10
 add w19,w19,#1
 ldr w20,[x3]
 cbz x19,.Lsrtm27_restore
 cbz x20,.Lsrtm27_restore
 ldr w21,[x0]
 mul x21,x21,x19
 mov x22,x4
 mov x23,x5
 mov x24,x6
 mov x25,x7
 ldp x26,x27,[sp,#256]
 ldp x28,x29,[sp,#272]
 ldp x30,x9,[sp,#288]
 str x9,[sp,#96]
 ldp x9,x10,[sp,#304]
 stp x9,x10,[sp,#104]
 ldp x9,x10,[sp,#320]
 stp x9,x10,[sp,#120]
 srtm27_address x9,yoesrta27.eq.1_
 str x9,[sp,#136]
 srtm27_address x9,yoesrta27.eq.0_
 str x9,[sp,#144]
 srtm27_address x9,__yoesrta27_MOD_sfluxrefc
 str x9,[sp,#152]
 srtm27_address x9,__yoesrta27_MOD_raylc
 str x9,[sp,#160]
 srtm27_address x9,__yoesrta27_MOD_scalekur
 ldr d19,[x9]
 srtm27_address x9,__yoesrta27_MOD_layreffr
 ldr w9,[x9]
 str w9,[sp,#176]
 srtm27_address x9,__yoesrtwn_MOD_nspa
 ldr w9,[x9,#44]
 str w9,[sp,#180]
 srtm27_address x9,__yoesrtwn_MOD_nspb
 ldr w9,[x9,#44]
 str w9,[sp,#184]
 mov x3,#0
 mov x0,#0
.Lsrtm27_layer:
 mov x1,#0
.Lsrtm27_column:
 ldr x9,[sp,#128]
 ldr d0,[x9,x1,lsl #3]
 fcmp d0,#0.0
 b.le .Lsrtm27_next_column
 ldr x9,[sp,#96]
 ldr w4,[x9,x1,lsl #2]
 madd x2,x0,x19,x1
 cbnz x3,.Lsrtm27_upper_selection
 cmp x0,x4
 b.ge .Lsrtm27_next_column
 ldr x7,[sp,#136]
 mov x17,#520
 ldr w12,[sp,#180]
 b .Lsrtm27_indices
.Lsrtm27_upper_selection:
 cmp x0,x4
 b.lt .Lsrtm27_next_column
 /* The prior pressure row is proved valid before entry. */
 sub x9,x2,x19
 ldr w10,[x26,x9,lsl #2]
 ldr w11,[x26,x2,lsl #2]
 ldr w9,[sp,#176]
 cmp w10,w9
 b.ge .Lsrtm27_no_crossing
 cmp w11,w9
 b.lt .Lsrtm27_no_crossing
 add w9,w0,#1
 str w9,[sp,#192]
.Lsrtm27_no_crossing:
 ldr x7,[sp,#144]
 mov x17,#1880
 ldr w12,[sp,#184]
.Lsrtm27_indices:
 ldr w5,[x26,x2,lsl #2]
 mov w6,w5
 ldr w9,[x27,x2,lsl #2]
 ldr w10,[x28,x2,lsl #2]
 sub w9,w9,#1
 sub w10,w10,#1
 cbnz x3,.Lsrtm27_upper_indices
 sub w5,w5,#1
 b .Lsrtm27_temperature_indices
.Lsrtm27_upper_indices:
 sub w5,w5,#13
 sub w6,w6,#12
.Lsrtm27_temperature_indices:
 mov w11,#5
 madd w5,w5,w11,w9
 madd w6,w6,w11,w10
 mul w5,w5,w12
 mul w6,w6,w12
 lsl x5,x5,#3
 lsl x6,x6,#3
 ldr d1,[x22,x2,lsl #3]
 ldr d2,[x23,x2,lsl #3]
 ldr d3,[x24,x2,lsl #3]
 ldr d4,[x25,x2,lsl #3]
 ldr d17,[x30,x2,lsl #3]
 ldr d18,[x29,x2,lsl #3]
 mov x8,#0
.Lsrtm27_group:
 ldr x9,[sp,#160]
 ldr d0,[x9,x8,lsl #3]
 fmul d20,d18,d0
 add x9,x7,x5
 add x10,x7,x6
 ldp d5,d6,[x9]
 ldp d7,d16,[x10]
 /* Retain the four separate products and three ordered additions. */
 fmul d5,d1,d5
 fmul d6,d3,d6
 fadd d5,d5,d6
 fmul d7,d2,d7
 fadd d5,d5,d7
 fmul d16,d4,d16
 fadd d5,d5,d16
 fmul d5,d17,d5
 madd x10,x8,x21,x2
 ldr x11,[sp,#112]
 str d5,[x11,x10,lsl #3]
 cbz x3,.Lsrtm27_scattering_store
 add w12,w0,#1
 ldr w13,[sp,#192]
 cmp w12,w13
 b.ne .Lsrtm27_scattering_store
 ldr x9,[sp,#152]
 ldr d0,[x9,x8,lsl #3]
 fmul d7,d19,d0
 madd x12,x8,x19,x1
 ldr x11,[sp,#104]
 str d7,[x11,x12,lsl #3]
.Lsrtm27_scattering_store:
 ldr x11,[sp,#120]
 str d20,[x11,x10,lsl #3]
 add x7,x7,x17
 add x8,x8,#1
 cmp x8,#8
 b.lt .Lsrtm27_group
.Lsrtm27_next_column:
 add x1,x1,#1
 cmp x1,x19
 b.lt .Lsrtm27_column
 add x0,x0,#1
 cmp x0,x20
 b.lt .Lsrtm27_layer
 cbnz x3,.Lsrtm27_restore
 mov x3,#1
 str w20,[sp,#192]
 mov x0,#0
 b .Lsrtm27_layer
.Lsrtm27_restore:
 ldp x19,x20,[sp,#0]
 ldp x21,x22,[sp,#16]
 ldp x23,x24,[sp,#32]
 ldp x25,x26,[sp,#48]
 ldp x27,x28,[sp,#64]
 ldp x29,x30,[sp,#80]
 add sp,sp,#256
 ret
.size srtm_taumol27_assembly_,.-srtm_taumol27_assembly_
.section .note.GNU-stack,"",%progbits

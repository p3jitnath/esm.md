/* Source-ordered YOMCLIM means and YOERADGHG initial coordinates.
 * Contract: skills/md2asm/references/openifs/radiation/radiation_climate_inputs.md.
 * Raw complete selected records have already acquired their array owners.
 * x0 TGHGCLIM1208,x1 owned RPI address. No allocation in this child. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_radiation_climatology_means
.type md2asm_initialize_radiation_climatology_means,%function
md2asm_initialize_radiation_climatology_means:
 sub sp,sp,#672
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 str x18,[sp,#64]
 stp d8,d9,[sp,#80]
 mov x29,sp
 mov x19,x0
 ldr d8,[x1]
 adr x9,.Lclimate_fp
 ldr d0,[x9]
 fdiv d8,d8,d0
 ldr x20,[x19,#64]
 add x21,sp,#144
 mov x22,#0
.Lcm_cosine:
 ldr d0,[x20,x22,lsl#3]
 fmul d0,d0,d8
 bl cos
 str d0,[x21,x22,lsl#3]
 add x22,x22,#1
 cmp x22,#64
 b.lo .Lcm_cosine
 fmov d0,xzr
 mov x22,#0
.Lcm_weight_sum:
 ldr d1,[x21,x22,lsl#3]
 fadd d0,d0,d1
 add x22,x22,#1
 cmp x22,#64
 b.lo .Lcm_weight_sum
 adr x9,.Lclimate_fp
 ldr d1,[x9,#8]
 fmul d0,d1,d0
 mov x22,#0
.Lcm_normalize:
 ldr d1,[x21,x22,lsl#3]
 fdiv d1,d1,d0
 str d1,[x21,x22,lsl#3]
 add x22,x22,#1
 cmp x22,#64
 b.lo .Lcm_normalize
 adr x20,.Lclimate_mean_descriptors
 mov x22,#0
.Lcm_gas:
 ldr w9,[x20,x22,lsl#2]
 ldr x23,[x19,x9]
 /* Last pressure plane begins after 90*64 doubles. */
 mov x9,#46080
 add x23,x23,x9
 fmov d0,xzr
 mov x24,#0
.Lcm_latitude:
 add x10,x23,x24,lsl#3
 mov x11,#12
 fmov d1,xzr
.Lcm_month:
 ldr d2,[x10]
 fadd d1,d1,d2
 mov x9,#46592
 add x10,x10,x9
 subs x11,x11,#1
 b.ne .Lcm_month
 ldr d2,[x21,x24,lsl#3]
 fmul d1,d1,d2
 fadd d0,d0,d1
 add x24,x24,#1
 cmp x24,#64
 b.lo .Lcm_latitude
 add x9,x19,#1136
 str d0,[x9,x22,lsl#3]
 add x22,x22,#1
 cmp x22,#8
 b.lo .Lcm_gas
 mov w0,#0
 ldp d8,d9,[sp,#80]
 ldr x18,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#672
 ret
.size md2asm_initialize_radiation_climatology_means,.-md2asm_initialize_radiation_climatology_means

/* x0 TRADGHG928,x1 TGHGCLIM1208,x2 owned RPI address.
 * All eleven destination payloads have already been allocated. */
.p2align 4
.global md2asm_initialize_radiation_gas_coordinates
.type md2asm_initialize_radiation_gas_coordinates,%function
md2asm_initialize_radiation_gas_coordinates:
 sub sp,sp,#112
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 stp d8,d9,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 ldr x9,[x20]
 str x9,[sp,#96]
 ldr d8,[x2]
 adr x9,.Lclimate_fp
 ldr d0,[x9]
 fdiv d8,d8,d0
 ldr x21,[x20,#64]
 ldr x22,[x19]
 mov x20,#0
.Lcg_sine:
 ldr d0,[x21,x20,lsl#3]
 fmul d0,d0,d8
 bl sin
 str d0,[x22,x20,lsl#3]
 add x20,x20,#1
 cmp x20,#64
 b.lo .Lcg_sine
 /* Recover the input pressure pointer saved before sine calls. */
 ldr x9,[sp,#96]
 /* The caller-facing input descriptor is retained in the private slot. */
 ldr x10,[x19,#64]
 str xzr,[x10]
 adr x11,.Lclimate_fp
 ldr d3,[x11,#16]
 mov x12,#0
.Lcg_half_levels:
 ldr d0,[x9,x12,lsl#3]
 add x13,x12,#1
 ldr d1,[x9,x13,lsl#3]
 fadd d0,d0,d1
 fmul d0,d3,d0
 str d0,[x10,x13,lsl#3]
 add x12,x12,#1
 cmp x12,#90
 b.lo .Lcg_half_levels
 ldr d0,[x9,#720]
 ldr d1,[x9,#712]
 ldr d2,[x11,#24]
 fmul d0,d2,d0
 fmul d1,d3,d1
 fsub d0,d0,d1
 ldr d1,[x11,#32]
 fmax d0,d1,d0
 str d0,[x10,#728]
 mov w0,#0
 ldp d8,d9,[sp,#64]
 ldr x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.size md2asm_initialize_radiation_gas_coordinates,.-md2asm_initialize_radiation_gas_coordinates
.section .rodata
.p2align 3
.Lclimate_fp: .double 180.0,12.0,0.5,1.5,110000.0
.Lclimate_mean_descriptors: .word 128,240,352,464,576,688,912,1024
.section .note.GNU-stack,"",%progbits

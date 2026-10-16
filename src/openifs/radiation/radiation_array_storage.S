/* Contract: skills/md2asm/references/openifs/radiation/radiation_climate_inputs.md.
 * Raw array owner: x0 descriptor, w1 rank1..3, x2 uint32 extents[3],
 * w3 first lower bound0/1, w4 zero-payload flag. All spans are prevalidated.
 * Return0 or1. Only malloc and memset are external services. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_allocate_radiation_array
.type md2asm_allocate_radiation_array,%function
md2asm_allocate_radiation_array:
 sub sp,sp,#112
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov w20,w1
 mov x21,x2
 mov w22,w3
 mov w23,w4
 mov x24,#8
 mov x9,#0
.Lra_count:
 ldr w10,[x21,x9,lsl#2]
 mul x24,x24,x10
 add x9,x9,#1
 cmp x9,x20
 b.lo .Lra_count
 mov x0,x24
 bl malloc
 cbz x0,.Lra_failed
 mov x25,x0
 str x0,[x19]
 mov x9,#8
 str x9,[x19,#16]
 str xzr,[x19,#24]
 strb w20,[x19,#28]
 mov w10,#3
 strb w10,[x19,#29]
 str x9,[x19,#32]
 mov x26,#1
 mov x12,#0
 mov x13,#0
 add x14,x19,#40
.Lra_dimension:
 ldr w10,[x21,x12,lsl#2]
 mov x11,#1
 cbnz x12,.Lra_lower_set
 mov w11,w22
.Lra_lower_set:
 add x15,x10,x11
 sub x15,x15,#1
 stp x26,x11,[x14]
 str x15,[x14,#16]
 madd x13,x26,x11,x13
 mul x26,x26,x10
 add x14,x14,#24
 add x12,x12,#1
 cmp x12,x20
 b.lo .Lra_dimension
 neg x13,x13
 str x13,[x19,#8]
 cbz w23,.Lra_success
 mov x0,x25
 mov w1,#0
 mov x2,x24
 bl memset
.Lra_success:
 mov w0,#0
 b .Lra_return
.Lra_failed:
 mov w0,#1
.Lra_return:
 ldr x18,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.size md2asm_allocate_radiation_array,.-md2asm_allocate_radiation_array

/* Read one exact-shape variable. w0 ncid,x1 name,x2 descriptor,
 * w3 rank,x4 uint32 Fortran extents[3],w5 optional-zero flag.
 * A missing optional variable allocates a complete zero owner. */
.p2align 4
.global md2asm_read_radiation_netcdf_array
.type md2asm_read_radiation_netcdf_array,%function
md2asm_read_radiation_netcdf_array:
 sub sp,sp,#176
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x29,sp
 mov w19,w0
 mov x20,x1
 mov x21,x2
 mov w22,w3
 mov x23,x4
 mov w24,w5
 add x2,sp,#112
 bl nc_inq_varid
 cbz w0,.Lrn_found
 cmn w0,#49
 b.ne .Lrn_bad
 cbz w24,.Lrn_bad
 mov x0,x21
 mov w1,w22
 mov x2,x23
 mov w3,#1
 mov w4,#1
 bl md2asm_allocate_radiation_array
 b .Lrn_return
.Lrn_found:
 mov w0,w19
 ldr w1,[sp,#112]
 add x2,sp,#116
 bl nc_inq_varndims
 cbnz w0,.Lrn_bad
 ldr w9,[sp,#116]
 cmp w9,w22
 b.ne .Lrn_bad
 mov w0,w19
 ldr w1,[sp,#112]
 add x2,sp,#128
 bl nc_inq_vardimid
 cbnz w0,.Lrn_bad
 mov x25,#0
.Lrn_dimension:
 mov w0,w19
 add x9,sp,#128
 ldr w1,[x9,x25,lsl#2]
 add x2,sp,#152
 bl nc_inq_dimlen
 cbnz w0,.Lrn_bad
 sub x9,x22,x25
 sub x9,x9,#1
 ldr w10,[x23,x9,lsl#2]
 ldr x11,[sp,#152]
 cmp x10,x11
 b.ne .Lrn_bad
 add x25,x25,#1
 cmp x25,x22
 b.lo .Lrn_dimension
 mov x0,x21
 mov w1,w22
 mov x2,x23
 mov w3,#1
 mov w4,#0
 bl md2asm_allocate_radiation_array
 cbnz w0,.Lrn_return
 mov w0,w19
 ldr w1,[sp,#112]
 ldr x2,[x21]
 bl nc_get_var_double
 cbnz w0,.Lrn_bad
 mov w0,#0
 b .Lrn_return
.Lrn_bad:
 mov w0,#3
.Lrn_return:
 ldr x18,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#176
 ret
.size md2asm_read_radiation_netcdf_array,.-md2asm_read_radiation_netcdf_array
.section .note.GNU-stack,"",%progbits

/* Selected output list construction from SUVFPOSL, NFPCONF0, one domain.
 * F,Q,SP,GP,SCAN*,NLEV*,LEV are the original x0..x6 arguments.
 * All field codes, names, flags, levels and owner contents come from live inputs.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_output_request_metadata_
.global md2asm_output_request_metadata_direct
.type md2asm_output_request_metadata_direct,%function
md2asm_output_request_metadata_:
md2asm_output_request_metadata_direct:
 ldr w9,[x0]
 cbnz w9,.Lrequest_metadata_reject
 sub sp,sp,#144
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x6
 ldrsw x24,[x5]
 cmp x24,#64
 b.hi .Lrequest_metadata_reject
 ldr w9,[x4]
 cmp w9,#5
 mov w9,#'P'
 mov w10,#'S'
 csel w9,w10,w9,eq
 str w9,[sp,#108]
 ldr w9,[x20,#1124]
 ldr w10,[x20,#1100]
 sub w11,w9,w10
 cmp w9,#4096
 b.hi .Lrequest_metadata_reject
 cmp w10,w9
 b.hi .Lrequest_metadata_reject
 str w11,[x21]
 str w10,[x22]
 ldr w9,[x20,#1116]
 str w9,[x21,#608]
 mov x0,x21
 mov x1,x22
 bl md2asm_allocate_output_io_owners
 mov x25,#0
 mov x27,#0
 mov x28,#0
.Lrequest_field:
 ldr w9,[x20]
 cmp w9,#686
 b.hi .Lrequest_metadata_reject
 cmp x25,x9
 b.hs .Lrequest_fields_done
 ldr x9,[x20,#8]
 ldr w10,[x9,x25,lsl #2]
 sub w9,w10,#1
 cmp w9,#685
 b.hi .Lrequest_metadata_reject
 str w9,[sp,#96]
 ldr x11,[x20,#328]
 ldr w11,[x11,x9,lsl #2]
 cmp w11,#64
 b.hi .Lrequest_metadata_reject
 str w11,[sp,#100]
 ldr x11,[x20,#136]
 ldr w11,[x11,x9,lsl #2]
 cmp w11,#1
 cset w11,ge
 str w11,[sp,#104]
 mov x11,#112
 madd x9,x9,x11,x19
 add x9,x9,#1,lsl #12
 add x9,x9,#1976
 str x9,[sp,#112]
 mov x26,#0
.Lrequest_level:
 ldr w9,[sp,#100]
 cmp x26,x9
 b.hs .Lrequest_next_field
 ldr w9,[sp,#104]
 cmp w9,#0
 csel x8,x22,x21,eq
 csel x7,x28,x27,eq
 ldr w10,[sp,#96]
 add w10,w10,#1
 ldr x9,[x8,#8]
 str w10,[x9,x7,lsl #2]
 ldr x6,[sp,#112]
 ldr w10,[x6,#36]
 ldr x9,[x8,#136]
 str w10,[x9,x7,lsl #2]
 ldr w11,[x6]
 ldr x9,[x8,#72]
 str w11,[x9,x7,lsl #2]
 ldr x9,[x8,#392]
 add x9,x9,x7,lsl #3
 mov x11,#0x2020
 movk x11,#0x2020,lsl #16
 movk x11,#0x2020,lsl #32
 movk x11,#0x2020,lsl #48
 str x11,[x9]
 ldr w11,[sp,#96]
 ldr x12,[x20,#456]
 madd x12,x11,x12,x26
 cbz w10,.Lrequest_upper_air
 ldr w10,[x6,#60]
 str w10,[x9]
 ldr x9,[x8,#264]
 str xzr,[x9,x7,lsl #3]
 add x6,x6,#64
 b .Lrequest_name
.Lrequest_upper_air:
 ldr w10,[sp,#108]
 strb w10,[x9]
 ldr x9,[x20,#392]
 ldr w10,[x9,x12,lsl #2]
 sub w10,w10,#1
 cmp w10,w24
 b.hs .Lrequest_metadata_reject
 ldr x10,[x23,x10,lsl #3]
 ldr x9,[x8,#264]
 str x10,[x9,x7,lsl #3]
 add x6,x6,#60
.Lrequest_name:
 ldr x9,[x8,#328]
 mov x10,#12
 madd x9,x7,x10,x9
 ldr x10,[x6]
 ldr w11,[x6,#8]
 str x10,[x9]
 str w11,[x9,#8]
 ldr w9,[sp,#104]
 cbz w9,.Lrequest_grid_mapping
 ldr x9,[x20,#832]
 ldr w10,[x9,x12,lsl #2]
 ldr x9,[x21,#616]
 str w10,[x9,x27,lsl #2]
 ldr x9,[x20,#920]
 ldr w10,[x9,x12,lsl #2]
 ldr x9,[x21,#680]
 str w10,[x9,x27,lsl #2]
 add x27,x27,#1
 b .Lrequest_level_done
.Lrequest_grid_mapping:
 ldr x9,[x20,#480]
 ldr w10,[x9,x12,lsl #2]
 cmp w10,#1
 b.hi .Lrequest_metadata_reject
 ldr x9,[x22,#456]
 str w10,[x9,x28,lsl #2]
 cbz w10,.Lrequest_empty_domain
 ldr x9,[x20,#568]
 ldr w10,[x9,x12,lsl #2]
 b .Lrequest_domain_ready
.Lrequest_empty_domain:
 mov w10,#0
.Lrequest_domain_ready:
 ldr x9,[x22,#520]
 str w10,[x9,x28,lsl #2]
 add x28,x28,#1
.Lrequest_level_done:
 add x26,x26,#1
 b .Lrequest_level
.Lrequest_next_field:
 add x25,x25,#1
 b .Lrequest_field
.Lrequest_fields_done:
 ldr w9,[x21]
 cmp x27,x9
 b.ne .Lrequest_metadata_reject
 ldr w9,[x22]
 cmp x28,x9
 b.ne .Lrequest_metadata_reject
 adrp x9,md2asm_output_io_request_counters
 add x9,x9,:lo12:md2asm_output_io_request_counters
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#144
 ret
.size md2asm_output_request_metadata_direct,.-md2asm_output_request_metadata_direct
.global md2asm_output_io_request_count_get
.type md2asm_output_io_request_count_get,%function
md2asm_output_io_request_count_get:
 cmp x0,#2
 b.hs .Lio_request_zero_count
 adrp x9,md2asm_output_io_request_counters
 add x9,x9,:lo12:md2asm_output_io_request_counters
 ldr x0,[x9,x0,lsl #3]
 ret
.Lio_request_zero_count:
 mov x0,#0
 ret
.size md2asm_output_io_request_count_get,.-md2asm_output_io_request_count_get
.Lrequest_metadata_reject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.bss
.p2align 3
.hidden md2asm_output_io_request_counters
.global md2asm_output_io_request_counters
md2asm_output_io_request_counters: .zero 16
.section .note.GNU-stack,"",%progbits

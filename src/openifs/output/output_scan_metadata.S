/* Selected output scan: seven source choices, direct request children.
 * Ten original pointer arguments: x0..x7, then LEV descriptor and ENDSCAN*.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_output_scan_metadata_
.global md2asm_output_scan_metadata_direct
.type md2asm_output_scan_metadata_direct,%function
md2asm_output_scan_metadata_:
md2asm_output_scan_metadata_direct:
 ldr w9,[x0]
 cbnz w9,.Lscan_reject
 ldr w11,[x5]
 sub w12,w11,#1
 cmp w12,#6
 b.hi .Lscan_stop109
 ldp x9,x10,[sp]
 sub sp,sp,#144
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x7
 mov x25,x9
 mov x26,x10
 mov x28,x6
 adrp x9,.Lscan_offsets
 add x9,x9,:lo12:.Lscan_offsets
 ldr w9,[x9,x12,lsl #2]
 add x27,x20,x9
 adrp x9,.Lscan_characters
 add x9,x9,:lo12:.Lscan_characters
 ldrb w9,[x9,x12]
 str w9,[sp,#104]
 ldr w9,[x27,#4]
 str w9,[x24]
 add x9,x27,#16
 ldp x10,x11,[x9]
 stp x10,x11,[x25]
 ldp x10,x11,[x9,#16]
 stp x10,x11,[x25,#16]
 ldp x10,x11,[x9,#32]
 stp x10,x11,[x25,#32]
 ldp x10,x11,[x9,#48]
 stp x10,x11,[x25,#48]
 ldr w9,[x26]
 cbz w9,.Lscan_begin
 ldr w9,[x21,#1124]
 cmp w9,#0
 b.le .Lscan_free_dynamic
 mov x0,x22
 mov x1,x23
 bl md2asm_release_output_io_requests
.Lscan_free_dynamic:
 mov x0,x21
 bl md2asm_deallocate_output_request
 mov x12,#1
 b .Lscan_count
.Lscan_begin:
 adrp x9,:got:__yommp0_MOD_nprtrv
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nprtrv]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lscan_reject
 adrp x9,:got:__yommp0_MOD_mysetv
 ldr x9,[x9,:got_lo12:__yommp0_MOD_mysetv]
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lscan_reject
 mov w9,#1
 str w9,[sp,#108]
 mov x0,x21
 add x1,sp,#108
 mov x2,x24
 bl md2asm_allocate_output_request
 mov x0,x21
 mov x1,x27
 add x2,x20,#3472
 mov x3,x19
 mov x4,x28
 ldr w5,[sp,#104]
 bl md2asm_select_scalar_output_request
 /* ANY of the genuine logical filter descriptor, in element order. */
 add x9,x19,#3240
 ldr x10,[x9]
 ldr x11,[x9,#8]
 ldr x12,[x9,#40]
 ldr x13,[x9,#48]
 ldr x14,[x9,#56]
 madd x11,x13,x12,x11
 add x10,x10,x11,lsl #2
 sub x14,x14,x13
 add x14,x14,#1
 cmp x14,#0
 b.le .Lscan_filter_done
.Lscan_filter:
 ldr w11,[x10]
 cbnz w11,.Lscan_stop109
 add x10,x10,x12,lsl #2
 subs x14,x14,#1
 b.ne .Lscan_filter
.Lscan_filter_done:
 mov x12,#0
.Lscan_count:
 adrp x9,.Lscan_counts
 add x9,x9,:lo12:.Lscan_counts
 ldr x10,[x9,x12,lsl #3]
 add x10,x10,#1
 str x10,[x9,x12,lsl #3]
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#144
 ret
.size md2asm_output_scan_metadata_direct,.-md2asm_output_scan_metadata_direct
.global md2asm_output_scan_count_get
.type md2asm_output_scan_count_get,%function
md2asm_output_scan_count_get:
 cmp x0,#2
 b.hs .Lscan_zero_count
 adrp x9,.Lscan_counts
 add x9,x9,:lo12:.Lscan_counts
 ldr x0,[x9,x0,lsl #3]
 ret
.Lscan_zero_count:
 mov x0,#0
 ret
.size md2asm_output_scan_count_get,.-md2asm_output_scan_count_get
.Lscan_stop109:
 mov x0,#109
 mov x8,#94
 svc #0
 brk #0
.Lscan_reject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.section .rodata
.p2align 2
.Lscan_offsets: .word 0,992,496,1488,1984,2976,2480
.Lscan_characters: .ascii "BVTHSKF"
.bss
.p2align 3
.Lscan_counts: .zero 16
.section .note.GNU-stack,"",%progbits

// Contract: skills/md2asm/references/openifs/fullpos/fullpos_configuration_setup.md.
// Selected MODEL SUFPC, live first NAMFPC, owned declarations and outputs.
// ABI and finite read domain are frozen in integration_contract.md.
// x0 text,x1 bytes,x2 upstream32,x3 outputs80,x4 workspace71360,x5 cap.
// Return0 success,2 reject. Workspace may change; other outputs are atomic.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_fullpos_configuration
.type md2asm_initialize_selected_fullpos_configuration,%function
md2asm_initialize_selected_fullpos_configuration:
 cbz x0,.Lconfig_early_bad
 cbz x1,.Lconfig_early_bad
 cmp x1,#64,lsl#12
 b.hi .Lconfig_early_bad
 adds x9,x0,x1
 b.cs .Lconfig_early_bad
 sub sp,sp,#320
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov x20,x9
 mov x21,x2
 mov x22,x3
 mov x23,x4
 add x27,sp,#96
 stp x0,x9,[x27],#16
 mov x28,#1
 mov x0,x21
 mov x1,#32
 mov x2,#32
 bl .Lconfig_append_view
 cbnz w0,.Lconfig_bad
 mov x0,x22
 mov x1,#80
 mov x2,#80
 bl .Lconfig_append_view
 cbnz w0,.Lconfig_bad
 mov x0,x23
 mov x1,x5
 movz x2,#5824
 movk x2,#1,lsl#16
 bl .Lconfig_append_view
 cbnz w0,.Lconfig_bad
 ldp x24,x1,[x21]
 mov x0,x24
 mov x2,#51112
 bl .Lconfig_append_view
 cbnz w0,.Lconfig_bad
 ldr w25,[x21,#28]
 cmp w25,#1
 b.hi .Lconfig_bad
 ldr w9,[x21,#24]
 cmp w9,#2
 b.ne .Lconfig_bad
 ldr w9,[x21,#20]
 tbnz w9,#31,.Lconfig_bad
 ldr w9,[x21,#16]
 cmn w9,#1
 b.lt .Lconfig_bad
 cmp w9,#3
 b.le .Lconfig_grib_ok
 sub w9,w9,#100
 cmp w9,#100
 b.hi .Lconfig_bad
.Lconfig_grib_ok:
 mov x10,#39520
 ldr w9,[x24,x10]
 cmp w9,#1
 b.ne .Lconfig_bad
 mov x10,#35288
 ldr w9,[x24,x10]
 cbnz w9,.Lconfig_bad
 mov x10,#35184
 ldr w9,[x24,x10]
 cbnz w9,.Lconfig_bad
 mov x10,#35252
 ldr w9,[x24,x10]
 cmp w9,#2
 b.ne .Lconfig_bad
 mov x26,#0
.Lconfig_output_view:
 add x9,x22,x26,lsl#4
 ldp x0,x1,[x9]
 cmp x26,#3
 b.ne .Lconfig_output_present
 cbnz w25,.Lconfig_output_present
 orr x9,x0,x1
 cbnz x9,.Lconfig_bad
 b .Lconfig_output_next
.Lconfig_output_present:
 adr x9,.Lsufpc_record_layout
 add x9,x9,x26,lsl#4
 ldr x2,[x9]
 bl .Lconfig_append_view
 cbnz w0,.Lconfig_bad
.Lconfig_output_next:
 add x26,x26,#1
 cmp x26,#5
 b.lo .Lconfig_output_view
 mov x9,#0
.Lconfig_range_outer:
 add x10,sp,#96
 add x10,x10,x9,lsl#4
 ldp x11,x12,[x10]
 add x13,x9,#1
.Lconfig_range_inner:
 cmp x13,x28
 b.hs .Lconfig_range_next
 add x10,sp,#96
 add x10,x10,x13,lsl#4
 ldp x14,x15,[x10]
 cmp x11,x15
 b.hs .Lconfig_range_disjoint
 cmp x14,x12
 b.lo .Lconfig_bad
.Lconfig_range_disjoint:
 add x13,x13,#1
 b .Lconfig_range_inner
.Lconfig_range_next:
 add x9,x9,#1
 add x10,x9,#1
 cmp x10,x28
 b.lo .Lconfig_range_outer
 // The original local constructors write their representation padding.
 mov x9,x23
 mov x10,#8920
.Lconfig_zero_private:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lconfig_zero_private
 // Our scalar namespace has separate caller-owned padding.
 ldr x9,[x22,#64]
 ldr w10,[x9,#36]
 movz x9,#5812
 movk x9,#1,lsl#16
 str w10,[x23,x9]
 adr x26,.Lsufpc_default_rows
.Lconfig_default_row:
 ldp w9,w10,[x26]
 cmp w9,#-1
 b.eq .Lconfig_live_defaults
 ldr w11,[x26,#8]
 ldr x12,[x26,#16]
 add x9,x23,x9
.Lconfig_default_element:
 cmp w10,#1
 b.eq .Lconfig_default_byte
 cmp w10,#4
 b.eq .Lconfig_default_word
 str x12,[x9],#8
 b .Lconfig_default_done
.Lconfig_default_byte:
 strb w12,[x9],#1
 b .Lconfig_default_done
.Lconfig_default_word:
 str w12,[x9],#4
.Lconfig_default_done:
 subs w11,w11,#1
 b.ne .Lconfig_default_element
 add x26,x26,#24
 b .Lconfig_default_row
.Lconfig_live_defaults:
 ldr w9,[x21,#16]
 str w9,[x23,#848]
 mov x9,#35124
 ldr w10,[x24,x9]
 mov x9,#8540
 str w10,[x23,x9]
 add x9,x23,#852
 mov x10,x24
 mov x11,#961
.Lconfig_posts:
 ldr w12,[x10],#4
 str w12,[x9],#4
 subs x11,x11,#1
 b.ne .Lconfig_posts
 mov x9,#4696
 add x9,x23,x9
 mov x10,#47228
 add x10,x24,x10
 mov x11,#961
.Lconfig_posts_minutes:
 ldr w12,[x10],#4
 str w12,[x9],#4
 subs x11,x11,#1
 b.ne .Lconfig_posts_minutes
 ldr w9,[x21,#20]
 cmp w9,#0
 cset w9,eq
 movz x10,#5792
 movk x10,#1,lsl#16
 str w9,[x23,x10]
 mov x0,x19
 mov x1,x20
 mov x2,x23
 bl .Lsufpc_parse
 cbnz w0,.Lconfig_bad
 ldr w9,[x23]
 mov w10,#0x4f4d
 movk w10,#0x4544,lsl#16
 cmp w9,w10
 b.ne .Lconfig_bad
 ldrb w9,[x23,#4]
 cmp w9,#'L'
 b.ne .Lconfig_bad
 // Source dimensions are checked before exposing request metadata.
 mov x9,#58976
 ldr w10,[x23,x9]
 cmp w10,#454
 b.hi .Lconfig_bad
 mov x9,#58980
 ldr w10,[x23,x9]
 cmp w10,#454
 b.hi .Lconfig_bad
 mov x9,#59004
 ldr w10,[x23,x9]
 cmp w10,#212
 b.hi .Lconfig_bad
 movz x9,#28
 movk x9,#1,lsl#16
 ldr w10,[x23,x9]
 cmp w10,#1639
 b.hi .Lconfig_bad
 cbz w25,.Lconfig_commit_start
 // Original checks only the requested physical prefix when YDNAMFPL is present.
 mov x9,#59008
 add x9,x23,x9
 cbz w10,.Lconfig_commit_start
.Lconfig_physical_valid:
 ldr w11,[x9],#4
 cmp w11,#1
 b.lt .Lconfig_bad
 subs w10,w10,#1
 b.ne .Lconfig_physical_valid
.Lconfig_commit_start:
 mov x26,#0
.Lconfig_commit_record:
 cmp x26,#3
 b.ne .Lconfig_commit_present
 cbz w25,.Lconfig_commit_next
.Lconfig_commit_present:
 adr x9,.Lsufpc_record_layout
 add x9,x9,x26,lsl#4
 ldp x10,x11,[x9]
 add x11,x23,x11
 add x9,x22,x26,lsl#4
 ldr x12,[x9]
.Lconfig_commit_word:
 ldr x13,[x11],#8
 str x13,[x12],#8
 subs x10,x10,#8
 b.ne .Lconfig_commit_word
.Lconfig_commit_next:
 add x26,x26,#1
 cmp x26,#5
 b.lo .Lconfig_commit_record
 mov w0,#0
 b .Lconfig_return
.Lconfig_bad:
 mov w0,#2
.Lconfig_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#320
 ret
.Lconfig_early_bad:
 mov w0,#2
 ret
.Lconfig_append_view:
 cbz x0,.Lconfig_view_bad
 tst x0,#7
 b.ne .Lconfig_view_bad
 cmp x1,x2
 b.lo .Lconfig_view_bad
 adds x9,x0,x2
 b.cs .Lconfig_view_bad
 stp x0,x9,[x27],#16
 add x28,x28,#1
 mov w0,#0
 ret
.Lconfig_view_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_fullpos_configuration,.-md2asm_initialize_selected_fullpos_configuration

// The first-group selection and decimal leaf retain the accepted parser route.
.Lsufpc_parse:
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
.Lsufpc_line:
 mov w15,#0
.Lsufpc_find:
 cmp x19,x20
 b.hs .Lsufpc_bad
 ldrb w9,[x19],#1
 cmp w9,#10
 b.eq .Lsufpc_line
 add w15,w15,#1
 cmp w9,#32
 b.eq .Lsufpc_find
 cmp w9,#9
 b.eq .Lsufpc_find
 cmp w9,#13
 b.eq .Lsufpc_find
 cmp w9,#38
 b.ne .Lsufpc_skip_line
 cmp w15,#10
 b.hi .Lsufpc_skip_line
 add x9,x19,#6
 cmp x9,x20
 b.hs .Lsufpc_bad
 mov x9,#0
 adr x10,.Lsufpc_group
.Lsufpc_match_group:
 ldrb w11,[x19,x9]
 ldrb w12,[x10,x9]
 cmp w11,w12
 b.ne .Lsufpc_skip_line
 add x9,x9,#1
 cmp x9,#6
 b.lo .Lsufpc_match_group
 add x19,x19,#6
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lsufpc_key
 cmp w9,#9
 b.eq .Lsufpc_key
 cmp w9,#13
 b.eq .Lsufpc_key
 cmp w9,#10
 b.eq .Lsufpc_key
 cmp w9,#47
 b.eq .Lsufpc_key
.Lsufpc_skip_line:
 cmp x19,x20
 b.hs .Lsufpc_bad
 ldrb w9,[x19],#1
 cmp w9,#10
 b.ne .Lsufpc_skip_line
 b .Lsufpc_line
.Lsufpc_key:
 mov x0,x19
 mov x1,x20
 bl .Lsufpc_space
 mov x19,x0
 cmp x19,x20
 b.hs .Lsufpc_bad
 ldrb w9,[x19]
 cmp w9,#44
 b.ne .Lsufpc_key_start
 add x19,x19,#1
 b .Lsufpc_key
.Lsufpc_key_start:
 cmp w9,#47
 b.eq .Lsufpc_ok
 mov x26,x19
.Lsufpc_key_scan:
 cmp x19,x20
 b.hs .Lsufpc_bad
 ldrb w9,[x19]
 sub w10,w9,#65
 cmp w10,#25
 b.ls .Lsufpc_key_char
 sub w10,w9,#97
 cmp w10,#25
 b.ls .Lsufpc_key_char
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Lsufpc_key_char
 cmp w9,#95
 b.ne .Lsufpc_key_lookup
.Lsufpc_key_char:
 add x19,x19,#1
 b .Lsufpc_key_scan
.Lsufpc_key_lookup:
 sub x15,x19,x26
 adr x22,.Lsufpc_keys
.Lsufpc_lookup_row:
 ldr w9,[x22]
 cbz w9,.Lsufpc_bad
 cmp x15,x9
 b.ne .Lsufpc_lookup_next
 add x10,x22,#16
 mov x11,#0
.Lsufpc_lookup_char:
 ldrb w12,[x26,x11]
 sub w13,w12,#97
 cmp w13,#25
 b.hi .Lsufpc_upper
 sub w12,w12,#32
.Lsufpc_upper:
 ldrb w13,[x10,x11]
 cmp w12,w13
 b.ne .Lsufpc_lookup_next
 add x11,x11,#1
 cmp x11,x15
 b.lo .Lsufpc_lookup_char
 ldr w25,[x22,#4]
 ldr w9,[x22,#8]
 add x24,x21,x9
 ldr w23,[x22,#12]
 b .Lsufpc_equal
.Lsufpc_lookup_next:
 add x22,x22,#32
 b .Lsufpc_lookup_row
.Lsufpc_equal:
 mov x0,x19
 mov x1,x20
 bl .Lsufpc_space
 cmp x0,x20
 b.hs .Lsufpc_bad
 ldrb w9,[x0],#1
 cmp w9,#61
 b.ne .Lsufpc_bad
 mov x1,x20
 bl .Lsufpc_space
 mov x19,x0
 cmp x19,x20
 b.hs .Lsufpc_bad
 cmp w25,#2
 b.eq .Lsufpc_string
.Lsufpc_number:
 cbz w23,.Lsufpc_bad
 mov x27,x19
.Lsufpc_value_scan:
 cmp x19,x20
 b.hs .Lsufpc_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lsufpc_value_found
 cmp w9,#9
 b.eq .Lsufpc_value_found
 cmp w9,#13
 b.eq .Lsufpc_value_found
 cmp w9,#10
 b.eq .Lsufpc_value_found
 cmp w9,#44
 b.eq .Lsufpc_value_found
 cmp w9,#33
 b.eq .Lsufpc_value_found
 cmp w9,#47
 b.eq .Lsufpc_value_found
 add x19,x19,#1
 b .Lsufpc_value_scan
.Lsufpc_value_found:
 mov x0,x27
 mov x1,x19
 cbz w25,.Lsufpc_integer_call
 mov x9,x27
.Lsufpc_real_point:
 cmp x9,x19
 b.hs .Lsufpc_integer_call
 ldrb w10,[x9],#1
 cmp w10,#46
 b.ne .Lsufpc_real_point
 sub x1,x9,#1
.Lsufpc_real_fraction:
 cmp x9,x19
 b.hs .Lsufpc_integer_call
 ldrb w10,[x9],#1
 cmp w10,#48
 b.ne .Lsufpc_bad
 b .Lsufpc_real_fraction
.Lsufpc_integer_call:
 bl .Lsufpc_integer
 cbnz w3,.Lsufpc_bad
 cbnz w25,.Lsufpc_store_real
 str w2,[x24],#4
 b .Lsufpc_stored
.Lsufpc_store_real:
 scvtf d0,w2
 cbnz w2,.Lsufpc_real_sign_done
 ldrb w9,[x27]
 cmp w9,#45
 b.ne .Lsufpc_real_sign_done
 fneg d0,d0
.Lsufpc_real_sign_done:
 str d0,[x24],#8
.Lsufpc_stored:
 sub w23,w23,#1
 mov x0,x19
 mov x1,x20
 bl .Lsufpc_space
 mov x19,x0
 cmp x19,x20
 b.hs .Lsufpc_bad
 ldrb w9,[x19]
 cmp w9,#44
 b.ne .Lsufpc_after_list
 add x0,x19,#1
 mov x1,x20
 bl .Lsufpc_space
 mov x19,x0
 cmp x19,x20
 b.hs .Lsufpc_bad
 ldrb w9,[x19]
 cmp w9,#43
 b.eq .Lsufpc_number
 cmp w9,#45
 b.eq .Lsufpc_number
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Lsufpc_number
.Lsufpc_after_list:
 cmp w9,#47
 b.eq .Lsufpc_ok
 sub w10,w9,#65
 cmp w10,#25
 b.ls .Lsufpc_key
 sub w10,w9,#97
 cmp w10,#25
 b.ls .Lsufpc_key
 b .Lsufpc_bad
.Lsufpc_string:
 ldrb w9,[x19],#1
 cmp w9,#39
 b.eq .Lsufpc_quote
 cmp w9,#34
 b.ne .Lsufpc_bad
.Lsufpc_quote:
 mov w28,w9
 mov x27,x19
 mov x23,#0
.Lsufpc_string_scan:
 cmp x19,x20
 b.hs .Lsufpc_bad
 ldrb w9,[x19],#1
 cmp w9,w28
 b.eq .Lsufpc_string_copy
 cmp w9,#13
 b.eq .Lsufpc_bad
 cmp w9,#10
 b.eq .Lsufpc_bad
 add x23,x23,#1
 cmp x23,#5
 b.hi .Lsufpc_bad
 b .Lsufpc_string_scan
.Lsufpc_string_copy:
 mov x9,#0
.Lsufpc_string_byte:
 mov w10,#32
 cmp x9,x23
 b.hs .Lsufpc_string_pad
 ldrb w10,[x27,x9]
.Lsufpc_string_pad:
 strb w10,[x24,x9]
 add x9,x9,#1
 cmp x9,#5
 b.lo .Lsufpc_string_byte
 cmp x19,x20
 b.hs .Lsufpc_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lsufpc_key
 cmp w9,#9
 b.eq .Lsufpc_key
 cmp w9,#13
 b.eq .Lsufpc_key
 cmp w9,#10
 b.eq .Lsufpc_key
 cmp w9,#44
 b.eq .Lsufpc_key
 cmp w9,#47
 b.eq .Lsufpc_ok
 b .Lsufpc_bad
.Lsufpc_ok:
 mov w0,#0
 b .Lsufpc_return
.Lsufpc_bad:
 mov w0,#2
.Lsufpc_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.Lsufpc_space:
 cmp x0,x1
 b.hs .Lsufpc_space_return
 ldrb w9,[x0]
 cmp w9,#32
 b.eq .Lsufpc_space_next
 cmp w9,#9
 b.eq .Lsufpc_space_next
 cmp w9,#13
 b.eq .Lsufpc_space_next
 cmp w9,#10
 b.eq .Lsufpc_space_next
 cmp w9,#33
 b.ne .Lsufpc_space_return
.Lsufpc_comment:
 add x0,x0,#1
 cmp x0,x1
 b.hs .Lsufpc_space_return
 ldrb w9,[x0]
 cmp w9,#10
 b.ne .Lsufpc_comment
.Lsufpc_space_next:
 add x0,x0,#1
 b .Lsufpc_space
.Lsufpc_space_return:
 ret
// Same bounded exact signed decimal route as the accepted scalar parser.
.Lsufpc_integer:
 mov w2,#0
 mov w3,#2
 mov w9,#0
 cmp x0,x1
 b.hs .Lsufpc_int_return
 ldrb w10,[x0]
 cmp w10,#45
 b.ne .Lsufpc_int_plus
 mov w9,#1
 add x0,x0,#1
 b .Lsufpc_int_first
.Lsufpc_int_plus:
 cmp w10,#43
 b.ne .Lsufpc_int_first
 add x0,x0,#1
.Lsufpc_int_first:
 cmp x0,x1
 b.hs .Lsufpc_int_return
 mov w12,#10
 mov w13,#0xe100
 movk w13,#0x5f5,lsl#16
.Lsufpc_int_digit:
 ldrb w10,[x0],#1
 sub w10,w10,#48
 cmp w10,#9
 b.hi .Lsufpc_int_return
 madd w2,w2,w12,w10
 cmp w2,w13
 b.hi .Lsufpc_int_return
 cmp x0,x1
 b.lo .Lsufpc_int_digit
 cmp w9,#0
 cneg w2,w2,ne
 mov w3,#0
.Lsufpc_int_return:
 ret
.section .rodata
.Lsufpc_group: .ascii "NAMFPC"
#include "fullpos_configuration_tables.inc.S"
.section .note.GNU-stack,"",%progbits

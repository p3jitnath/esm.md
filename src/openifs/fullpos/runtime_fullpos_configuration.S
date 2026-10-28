// Contract: skills/md2asm/references/openifs/fullpos/runtime_fullpos_configuration.md.
// SUFPC reads the first live NAMFPC group and commits five caller-owned records.
// x0 text, x1 bytes, x2 upstream32, x3 outputs80, x4 workspace71360, x5 capacity.
// Return w0=0 on success or 2 on rejection; external outputs are unchanged on rejection.
// A separate 22608-byte stack record receives the shared full namelist parser output.
// Live LARPEGEF=false selects the source pre-read LTRACEFP=false assignment.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_runtime_fullpos_configuration
.type md2asm_initialize_runtime_fullpos_configuration,%function
md2asm_initialize_runtime_fullpos_configuration:
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
 // Read the complete selected runtime group into a separate private carrier.
 mov x0,x19
 sub x1,x20,x19
 sub sp,sp,#5,lsl#12
 sub sp,sp,#2128
 mov x2,sp
 bl md2asm_parse_runtime_sufpc_namfpc
 cbnz w0,.Lruntime_config_parse_finish
 // CFPFMT has five source characters; the next object byte starts CFPDOM.
 mov x9,#0
 add x10,sp,#40
.Lruntime_config_format:
 ldrb w11,[x10,x9]
 strb w11,[x23,x9]
 add x9,x9,#1
 cmp x9,#5
 b.lo .Lruntime_config_format
 adr x14,.Lruntime_config_scatter
.Lruntime_config_row:
 ldp w9,w10,[x14]
 ldr w11,[x14,#8]
 cbz w11,.Lruntime_config_parse_finish
 add x12,sp,x9
 add x13,x23,x10
.Lruntime_config_word:
 ldr w15,[x12],#4
 str w15,[x13],#4
 subs w11,w11,#4
 b.ne .Lruntime_config_word
 add x14,x14,#16
 b .Lruntime_config_row
.Lruntime_config_parse_finish:
 add sp,sp,#2128
 add sp,sp,#5,lsl#12
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
.size md2asm_initialize_runtime_fullpos_configuration,.-md2asm_initialize_runtime_fullpos_configuration


.section .rodata
#include "fullpos_configuration_tables.inc.S"
.p2align 3
.Lruntime_config_scatter:
// eight dynamic counts in original order.
.word 0,58976,32,0
// NFPPHY.
.word 32,65564,4,0
// NFPCLI.
.word 48,8596,4,0
// LFPQ.
.word 52,8664,4,0
// LTRACEFP.
.word 56,71312,4,0
// RFPCORR.
.word 64,8752,8,0
// MFP3DFS.
.word 80,40600,1024,0
// MFP3DFP.
.word 1104,42416,1024,0
// MFP3DFH.
.word 2128,44232,1024,0
// MFP3DFT.
.word 3152,46048,1024,0
// MFP3DFV.
.word 4176,47864,1024,0
// MFP3DFI.
.word 5200,49680,1024,0
// MFP3DFF.
.word 6224,51496,1024,0
// MFP2DF.
.word 7248,53312,848,0
// MFPPHY.
.word 8272,59008,1024,0
// NRFP3S.
.word 9296,58176,800,0
// RFP3P.
.word 10320,54160,600,0
// RFP3H.
.word 12368,54760,1016,0
// RFP3TH.
.word 14416,55776,600,0
// RFP3PV.
.word 16464,56376,600,0
// RFP3I.
.word 18512,56976,600,0
// RFP3F.
.word 20560,57576,600,0
.word 0,0,0,0
.section .note.GNU-stack,"",%progbits

// Share the accepted parser body, retaining the SUFPC pre-read trace assignment.
#define MD2ASM_OUTPUT_NAMELIST_ENTRY md2asm_parse_runtime_sufpc_namfpc
#define MD2ASM_OUTPUT_TRACE_DEFAULT 0
#include "../output/runtime_output_namelist.S"
#undef MD2ASM_OUTPUT_NAMELIST_ENTRY
#undef MD2ASM_OUTPUT_TRACE_DEFAULT

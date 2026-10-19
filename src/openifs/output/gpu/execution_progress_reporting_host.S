#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_logdis_selected
.type md2asm_logdis_selected,%function
md2asm_logdis_selected:
 cbz x0,.Llog_bad_leaf
 cbz x1,.Llog_bad_leaf
 orr x9,x0,x1
 tst x9,#7
 b.ne .Llog_bad_leaf
 adds x9,x0,#152
 b.cs .Llog_bad_leaf
 adds x10,x1,#40
 b.cs .Llog_bad_leaf
 cmp x0,x10
 b.hs 1f
 cmp x1,x9
 b.lo .Llog_bad_leaf
1:
 ldr w9,[x0]
 cmp w9,#1
 b.lt .Llog_bad_leaf
 ldr w9,[x0,#4]
 tbnz w9,#31,.Llog_bad_leaf
 ldr w9,[x0,#8]
 tbnz w9,#31,.Llog_bad_leaf
 ldr w9,[x0,#12]
 tbnz w9,#31,.Llog_bad_leaf
 ldr w9,[x0,#16]
 cmp w9,#1
 b.hi .Llog_bad_leaf
 mrs x9,fpcr
 cbnz x9,.Llog_bad_leaf
 ldr w9,[x1]
 cmp w9,#25
 b.hi .Llog_bad_leaf
 ldr w9,[x1,#4]
 cmp w9,#1
 b.hi .Llog_bad_leaf
 ldr w9,[x1,#8]
 cmp w9,#1
 b.hi .Llog_bad_leaf
 ldr x9,[x1,#16]
 and x10,x9,#0x7fffffffffffffff
 tbz x9,#63,1f
 cbnz x10,.Llog_bad_leaf
1:
 ldr x11,.Lmaximum_model_seconds
 cmp x10,x11
 b.hi .Llog_bad_leaf
 ldp x9,x10,[x1,#24]
 and x9,x9,#0x7fffffffffffffff
 and x10,x10,#0x7fffffffffffffff
 ldr x11,.Lmaximum_cpu_seconds
 cmp x9,x11
 b.hi .Llog_bad_leaf
 cmp x10,x11
 b.hi .Llog_bad_leaf
.global .Llog_body
.type .Llog_body,%function
.Llog_body:
 stp x29,x30,[sp,#-112]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 sub sp,sp,#512
 mov x21,sp
 mov x19,x0
 mov x20,x1
 add x0,x21,#64
 add x1,x21,#48
 add x2,x21,#80
 add x3,x21,#128
 add x9,x21,#96
 mov x10,#-1
 stp x9,x10,[x3]
 mov x9,#4
 str x9,[x3,#16]
 str x9,[x3,#32]
 mov x9,#0x101
 lsl x9,x9,#32
 str x9,[x3,#24]
 mov x9,#1
 stp x9,x9,[x3,#40]
 mov x9,#8
 str x9,[x3,#56]
 mov w4,#10
 mov w5,#10
 mov w6,#10
 bl _gfortran_date_and_time
 ldr x18,[x29,#96]
 ldr d0,[x20,#16]
 ldr d1,.Lseconds_hour
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d2,d0,d1 // fdiv d2,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w9,d2 // fcvtzs w9,d2
 str w9,[x21,#192]
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d2,w9 // scvtf d2,w9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d2,d2,d1 // fmul d2,d2,d1
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d0,d2 // fsub d0,d0,d2
 ldr d1,.Lseconds_minute
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d0,d0,d1 // fdiv d0,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w9,d0 // fcvtzs w9,d0
 str w9,[x21,#196]
 ldp d0,d1,[x20,#24]
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d1,d0 // fsub d0,d1,d0
 str d0,[x21,#200]
 mov x9,#1
 add x10,x21,#48
 mov x11,#2
 add x12,x21,#256
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 add x10,x21,#50
 mov x11,#2
 add x12,x21,#280
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 add x10,x21,#52
 mov x11,#2
 add x12,x21,#304
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 adr x10,.Lstep_text
 mov x11,#4
 add x12,x21,#328
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#2
 mov x10,x20
 mov x11,#4
 add x12,x21,#352
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#2
 add x10,x21,#192
 mov x11,#4
 add x12,x21,#376
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#2
 add x10,x21,#196
 mov x11,#4
 add x12,x21,#400
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#4
 add x10,x21,#200
 mov x11,#8
 add x12,x21,#424
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x0,x21
 mov x1,#46
 adr x2,.Lfmt_log
 mov x3,#.Lfmt_log_len
 add x4,x21,#256
 mov x5,#8
 bl .Lreport_write
 cbnz w0,.Llog_io_error
 ldr w9,[x19]
 cmp w9,#1
 b.ne .Llog_listing
 mov x9,#1
 add x10,x21,#0
 mov x11,#46
 add x12,x21,#256
 stp x9,x10,[x12]
 str x11,[x12,#16]
 add x0,x19,#8
 mov x1,#0
 mov x2,#0
 mov x3,#0
 add x4,x21,#256
 mov x5,#1
 bl .Lreport_write
 cbnz w0,.Llog_io_error
 add x0,x19,#8
 mov x1,x20
 bl md2asm_write_memory_information
 cbnz w0,.Llog_io_error
.Llog_listing:
 ldr w9,[x20,#4]
 cbnz w9,.Llog_timer_kept
 str xzr,[x21,#200]
.Llog_timer_kept:
 ldr w9,[x20,#8]
 cbnz w9,.Llog_date_kept
 mov x9,#0x3030303030303030
 str x9,[x21,#48]
 strh w9,[x21,#56]
.Llog_date_kept:
 mov x9,#1
 add x10,x21,#48
 mov x11,#2
 add x12,x21,#256
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 add x10,x21,#50
 mov x11,#2
 add x12,x21,#280
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 add x10,x21,#52
 mov x11,#2
 add x12,x21,#304
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 adr x10,.Lstep_text
 mov x11,#4
 add x12,x21,#328
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#2
 mov x10,x20
 mov x11,#4
 add x12,x21,#352
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#2
 add x10,x21,#192
 mov x11,#4
 add x12,x21,#376
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#2
 add x10,x21,#196
 mov x11,#4
 add x12,x21,#400
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#4
 add x10,x21,#200
 mov x11,#8
 add x12,x21,#424
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x0,x21
 mov x1,#46
 adr x2,.Lfmt_log
 mov x3,#.Lfmt_log_len
 add x4,x21,#256
 mov x5,#8
 bl .Lreport_write
 cbnz w0,.Llog_io_error
 mov x9,#1
 add x10,x21,#0
 mov x11,#46
 add x12,x21,#256
 stp x9,x10,[x12]
 str x11,[x12,#16]
 add x0,x19,#4
 mov x1,#0
 adr x2,.Lfmt_listing
 mov x3,#.Lfmt_listing_len
 add x4,x21,#256
 mov x5,#1
 bl .Lreport_write
 cbnz w0,.Llog_io_error
 mov w0,#0
 b .Llog_return
.Llog_io_error:
 mov w0,#1
.Llog_return:
 add sp,sp,#512
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#112
 ret
.size .Llog_body,.-.Llog_body
.Llog_bad_leaf:
 mov w0,#2
 ret
.size md2asm_logdis_selected,.-md2asm_logdis_selected
.global md2asm_write_memory_information
.type md2asm_write_memory_information,%function
md2asm_write_memory_information:
 stp x29,x30,[sp,#-112]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 sub sp,sp,#128
 mov x21,sp
 mov x19,x0
 mov x20,x1
 mov x9,#2
 mov x10,x20
 mov x11,#4
 add x12,x21,#64
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x0,x21
 mov x1,#32
 adr x2,.Lfmt_memory
 mov x3,#.Lfmt_memory_len
 add x4,x21,#64
 mov x5,#1
 bl .Lreport_write
 cbnz w0,.Lmemory_return
 mov w9,#-2
 ldr w10,[x20]
 cmp w10,#0
 cinc w9,w9,eq
 str w9,[x21,#32]
 mov x0,x21
 mov x1,#32
 bl .Lreport_trim_length
 mov x6,x0
 mov x0,x19
 mov x1,x21
 add x2,x21,#32
 adr x3,.Lint_zero
 adr x4,.Lint_minus_one
 mov x5,x4
 bl ec_meminfo_
 ldr x18,[x29,#96]
 mov x0,x19
 bl ec_flush_
 ldr x18,[x29,#96]
 mov w0,#0
.Lmemory_return:
 add sp,sp,#128
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#112
 ret
.size md2asm_write_memory_information,.-md2asm_write_memory_information
.global .Lreport_write
.type .Lreport_write,%function
.Lreport_write:
 stp x29,x30,[sp,#-112]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 sub sp,sp,#544
 mov x21,sp
 mov x19,x0
 mov x20,x1
 mov x22,x2
 mov x23,x3
 mov x24,x4
 mov x25,x5
 mov x9,#0
.Lstatement_zero:
 add x10,x21,x9
 stp xzr,xzr,[x10]
 add x9,x9,#16
 cmp x9,#544
 b.lo .Lstatement_zero
 mov w9,#32
 cbz x22,.Lstatement_list
 orr w9,w9,#4096
 stp x22,x23,[x21,#80]
 b .Lstatement_format_set
.Lstatement_list:
 orr w9,w9,#128
.Lstatement_format_set:
 cbz x20,.Lstatement_external
 orr w9,w9,#16384
 stp x19,x20,[x21,#112]
 mov w10,#-1
 str w10,[x21,#4]
 b .Lstatement_unit_set
.Lstatement_external:
 ldr w10,[x19]
 str w10,[x21,#4]
.Lstatement_unit_set:
 str w9,[x21]
 add x9,x21,#528
 str x9,[x21,#40]
 mov x0,x21
 bl _gfortran_st_write
 ldr x18,[x29,#96]
.Lstatement_item:
 cbz x25,.Lstatement_done
 ldp x9,x1,[x24]
 ldr x2,[x24,#16]
 mov x0,x21
 cmp x9,#1
 b.eq .Lstatement_character
 cmp x9,#4
 b.eq .Lstatement_real
 bl _gfortran_transfer_integer_write
 ldr x18,[x29,#96]
 b .Lstatement_item_next
.Lstatement_character:
 bl _gfortran_transfer_character_write
 ldr x18,[x29,#96]
 b .Lstatement_item_next
.Lstatement_real:
 bl _gfortran_transfer_real_write
 ldr x18,[x29,#96]
.Lstatement_item_next:
 add x24,x24,#24
 sub x25,x25,#1
 b .Lstatement_item
.Lstatement_done:
 mov x0,x21
 bl _gfortran_st_write_done
 ldr x18,[x29,#96]
 ldr w0,[x21,#528]
 cmp w0,#0
 cset w0,ne
 add sp,sp,#544
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#112
 ret
.size .Lreport_write,.-.Lreport_write
.Lreport_trim_length:
 cbz x1,.Ltrim_done
 sub x1,x1,#1
 ldrb w9,[x0,x1]
 cmp w9,#32
 b.eq .Lreport_trim_length
 add x1,x1,#1
.Ltrim_done:
 mov x0,x1
 ret
.global md2asm_opdis_selected
.type md2asm_opdis_selected,%function
md2asm_opdis_selected:
 cbz x0,.Lop_bad_leaf
 cbz x1,.Lop_bad_leaf
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lop_bad_leaf
 adds x9,x0,#152
 b.cs .Lop_bad_leaf
 adds x10,x1,#80
 b.cs .Lop_bad_leaf
 cmp x0,x10
 b.hs 1f
 cmp x1,x9
 b.lo .Lop_bad_leaf
1:
 ldr w9,[x0]
 cmp w9,#1
 b.lt .Lop_bad_leaf
 ldr w9,[x0,#4]
 tbnz w9,#31,.Lop_bad_leaf
 ldr w9,[x0,#8]
 tbnz w9,#31,.Lop_bad_leaf
 ldr w9,[x0,#12]
 tbnz w9,#31,.Lop_bad_leaf
 ldr w9,[x0,#16]
 cmp w9,#1
 b.hi .Lop_bad_leaf
 mrs x9,fpcr
 cbnz x9,.Lop_bad_leaf
 ldr w9,[x1,#72]
 cmp w9,#25
 b.hi .Lop_bad_leaf
 ldr w9,[x1,#76]
 cbnz w9,.Lop_bad_leaf
 ldr x9,[x1,#16]
 cbz x9,.Lop_bad_leaf
 ldr x10,[x1,#24]
 sub x11,x10,#1
 cmp x11,#17
 b.hi .Lop_bad_leaf
 adds x11,x9,x10
 b.cs .Lop_bad_leaf
 add x12,x0,#152
 cmp x9,x12
 b.hs 1f
 cmp x0,x11
 b.lo .Lop_bad_leaf
1:
 mov x12,#0
.Lop_caller_validate:
 ldrb w13,[x9,x12]
 sub w13,w13,#32
 cmp w13,#94
 b.hi .Lop_bad_leaf
 add x12,x12,#1
 cmp x12,x10
 b.lo .Lop_caller_validate
 ldr x9,[x0,#144]
 cbz x9,.Lop_bad_leaf
 tst x9,#7
 b.ne .Lop_bad_leaf
 adds x10,x9,#8
 b.cs .Lop_bad_leaf
 add x11,x0,#152
 cmp x9,x11
 b.hs 1f
 cmp x0,x10
 b.lo .Lop_bad_leaf
1:
 ldr x9,[x9]
 and x9,x9,#0x7fffffffffffffff
 mov x10,#0x7fefffffffffffff
 cmp x9,x10
 b.hi .Lop_bad_leaf
 ldr x11,.Lmaximum_cpu_seconds
 mov x12,#32
.Lop_clock_validate:
 ldr x9,[x1,x12]
 and x9,x9,#0x7fffffffffffffff
 cmp x9,x11
 b.hi .Lop_bad_leaf
 add x12,x12,#8
 cmp x12,#56
 b.lo .Lop_clock_validate
 ldr x11,.Lmaximum_model_seconds
.Lop_accum_validate:
 ldr x9,[x1,x12]
 and x10,x9,#0x7fffffffffffffff
 tbz x9,#63,1f
 cbnz x10,.Lop_bad_leaf
1:
 cmp x10,x11
 b.hi .Lop_bad_leaf
 add x12,x12,#8
 cmp x12,#72
 b.lo .Lop_accum_validate
 ldr w9,[x0]
 cmp w9,#1
 b.eq .Lop_body
 mov w0,#0
 ret
.global .Lop_body
.type .Lop_body,%function
.Lop_body:
 stp x29,x30,[sp,#-112]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 sub sp,sp,#1280
 mov x21,sp
 mov x19,x0
 mov x20,x1
 adr x0,.Levent_opdis
 adr x1,.Lint_zero
 bl gstats_
 ldr x18,[x29,#96]
 ldr w9,[x19,#16]
 cbnz w9,.Lop_file_open
 mov w9,#1
 str w9,[x19,#16]
 add x22,x19,#24
 mov x23,#0
.Lop_prefix_find:
 cmp x23,#120
 b.hs .Lop_no_prefix
 ldrb w9,[x22,x23]
 cmp w9,#32
 b.eq .Lop_prefix_found
 add x23,x23,#1
 b .Lop_prefix_find
.Lop_no_prefix:
 mov x23,#0
.Lop_prefix_found:
 add x24,x21,#496
 mov x9,#0
.Lop_prefix_copy:
 cmp x9,x23
 b.hs .Lop_name_copy_start
 ldrb w10,[x22,x9]
 strb w10,[x24,x9]
 add x9,x9,#1
 b .Lop_prefix_copy
.Lop_name_copy_start:
 adr x10,.Lstatus_name
 mov x11,#0
.Lop_name_copy:
 ldrb w12,[x10,x11]
 add x13,x23,x11
 strb w12,[x24,x13]
 add x11,x11,#1
 cmp x11,#8
 b.lo .Lop_name_copy
 add x23,x23,#8
 add x22,x21,#640
 mov x9,#0
.Lopen_zero:
 add x10,x22,x9
 stp xzr,xzr,[x10]
 add x9,x9,#16
 cmp x9,#352
 b.lo .Lopen_zero
 mov w9,#17184
 str w9,[x22]
 ldr w9,[x19,#12]
 str w9,[x22,#4]
 add x9,x21,#984
 str x9,[x22,#40]
 str x23,[x22,#56]
 str x24,[x22,#64]
 adr x9,.Lreplace_text
 str x9,[x22,#72]
 mov x9,#7
 str x9,[x22,#80]
 mov x9,#5
 str x9,[x22,#152]
 adr x9,.Lwrite_text
 str x9,[x22,#160]
 mov x0,x22
 bl _gfortran_st_open
 ldr x18,[x29,#96]
 ldr w9,[x21,#984]
 cbnz w9,.Lop_io_error
.Lop_file_open:
 ldr w9,[x20,#72]
 str w9,[x21,#472]
 mov w9,#32
 mov x10,#0
.Lop_message_blank:
 strb w9,[x21,x10]
 add x10,x10,#1
 cmp x10,#200
 b.lo .Lop_message_blank
 add x11,x21,#208
 mov x10,#0
.Lop_caller_blank:
 strb w9,[x11,x10]
 add x10,x10,#1
 cmp x10,#18
 b.lo .Lop_caller_blank
 ldp x22,x23,[x20,#16]
 mov x9,#0
.Lop_adjust_left:
 cmp x9,x23
 b.hs .Lop_caller_copied
 ldrb w10,[x22,x9]
 cmp w10,#32
 b.ne .Lop_caller_copy_start
 add x9,x9,#1
 b .Lop_adjust_left
.Lop_caller_copy_start:
 mov x10,#0
 add x11,x21,#208
.Lop_caller_copy:
 cmp x9,x23
 b.hs .Lop_caller_copied
 ldrb w12,[x22,x9]
 strb w12,[x11,x10]
 add x9,x9,#1
 add x10,x10,#1
 cmp x10,#18
 b.lo .Lop_caller_copy
.Lop_caller_copied:
 add x0,x21,#264
 add x1,x21,#280
 add x2,x21,#296
 add x3,x21,#344
 add x9,x21,#312
 mov x10,#-1
 stp x9,x10,[x3]
 mov x9,#4
 str x9,[x3,#16]
 str x9,[x3,#32]
 mov x9,#0x101
 lsl x9,x9,#32
 str x9,[x3,#24]
 mov x9,#1
 stp x9,x9,[x3,#40]
 mov x9,#8
 str x9,[x3,#56]
 mov w4,#10
 mov w5,#10
 mov w6,#10
 bl _gfortran_date_and_time
 ldr x18,[x29,#96]
 mov x9,#1
 add x10,x21,#280
 mov x11,#2
 add x12,x21,#1008
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 add x10,x21,#282
 mov x11,#2
 add x12,x21,#1032
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 add x10,x21,#284
 mov x11,#2
 add x12,x21,#1056
 stp x9,x10,[x12]
 str x11,[x12,#16]
 add x0,x21,#1
 mov x1,#8
 adr x2,.Lfmt_clock
 mov x3,#.Lfmt_clock_len
 add x4,x21,#1008
 mov x5,#3
 bl .Lreport_write
 cbnz w0,.Lop_io_error
 mov x9,#0
.Lop_config_copy:
 ldrb w10,[x20,x9]
 add x11,x21,#10
 strb w10,[x11,x9]
 add x9,x9,#1
 cmp x9,#9
 b.lo .Lop_config_copy
 mov x9,#1
 add x10,x21,#208
 mov x11,#18
 add x12,x21,#1008
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#2
 add x10,x21,#472
 mov x11,#4
 add x12,x21,#1032
 stp x9,x10,[x12]
 str x11,[x12,#16]
 add x0,x21,#20
 mov x1,#180
 adr x2,.Lfmt_caller
 mov x3,#.Lfmt_caller_len
 add x4,x21,#1008
 mov x5,#2
 bl .Lreport_write
 cbnz w0,.Lop_io_error
 ldr d0,[x20,#64]
 ldr d1,.Lseconds_minute
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d2,d0,d1 // fdiv d2,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w9,d2 // fcvtzs w9,d2
 str w9,[x21,#408]
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d2,w9 // scvtf d2,w9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d2,d1,d2 // fmul d2,d1,d2
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d0,d2 // fsub d0,d0,d2
 md2asm_gpu_full_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w9,d0 // fcvtzs w9,d0
 str w9,[x21,#412]
 ldr d0,[x20,#56]
 ldr d1,.Lseconds_minute
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,3,d2,d0,d1 // fdiv d2,d0,d1
 md2asm_gpu_full_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w9,d2 // fcvtzs w9,d2
 str w9,[x21,#416]
 md2asm_gpu_full_scalar md2asm_gpu_startup_integer_cell_host,18,d2,w9 // scvtf d2,w9
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d2,d1,d2 // fmul d2,d1,d2
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,1,d0,d0,d2 // fsub d0,d0,d2
 md2asm_gpu_full_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w9,d0 // fcvtzs w9,d0
 str w9,[x21,#420]
 mov x9,#2
 add x10,x21,#408
 mov x11,#4
 add x12,x21,#1008
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#2
 add x10,x21,#412
 mov x11,#4
 add x12,x21,#1032
 stp x9,x10,[x12]
 str x11,[x12,#16]
 add x0,x21,#248
 mov x1,#10
 adr x2,.Lfmt_accum
 mov x3,#.Lfmt_accum_len
 add x4,x21,#1008
 mov x5,#2
 bl .Lreport_write
 cbnz w0,.Lop_io_error
 mov x9,#2
 add x10,x21,#416
 mov x11,#4
 add x12,x21,#1008
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#2
 add x10,x21,#420
 mov x11,#4
 add x12,x21,#1032
 stp x9,x10,[x12]
 str x11,[x12,#16]
 add x0,x21,#232
 mov x1,#10
 adr x2,.Lfmt_accum
 mov x3,#.Lfmt_accum_len
 add x4,x21,#1008
 mov x5,#2
 bl .Lreport_write
 cbnz w0,.Lop_io_error
 bl getmaxhwm_
 ldr x18,[x29,#96]
 mov x9,#10
 lsl x9,x9,#20
 cmp x0,x9
 b.ge .Lgetmaxhwm_large
 mov x9,#1024
 sdiv x0,x0,x9
 mov w9,#16971
 b .Lgetmaxhwm_store
.Lgetmaxhwm_large:
 mov x9,#1
 lsl x9,x9,#20
 sdiv x0,x0,x9
 mov w9,#16973
.Lgetmaxhwm_store:
 str x0,[x21,#424]
 strh w9,[x21,#464]
 bl getmaxstk_
 ldr x18,[x29,#96]
 mov x9,#10
 lsl x9,x9,#20
 cmp x0,x9
 b.ge .Lgetmaxstk_large
 mov x9,#1024
 sdiv x0,x0,x9
 mov w9,#16971
 b .Lgetmaxstk_store
.Lgetmaxstk_large:
 mov x9,#1
 lsl x9,x9,#20
 sdiv x0,x0,x9
 mov w9,#16973
.Lgetmaxstk_store:
 str x0,[x21,#432]
 strh w9,[x21,#466]
 bl getvmpeak_
 ldr x18,[x29,#96]
 mov x9,#10
 lsl x9,x9,#30
 cmp x0,x9
 b.ge .Lgetvmpeak_large
 mov x9,#1048576
 sdiv x0,x0,x9
 mov w9,#16973
 b .Lgetvmpeak_store
.Lgetvmpeak_large:
 mov x9,#1
 lsl x9,x9,#30
 sdiv x0,x0,x9
 mov w9,#16967
.Lgetvmpeak_store:
 str x0,[x21,#440]
 strh w9,[x21,#468]
 add x0,x21,#448
 add x1,x21,#456
 bl ec_pmon_
 ldr x18,[x29,#96]
 ldr x9,[x21,#448]
 mov x10,#1000
 sdiv x9,x9,x10
 str x9,[x21,#448]
 mov x0,x21
 mov x1,#200
 bl .Lreport_trim_length
 mov x22,x0
 mov x9,#4
 add x10,x20,#40
 mov x11,#8
 add x12,x21,#1008
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#4
 add x10,x20,#32
 mov x11,#8
 add x12,x21,#1032
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#4
 add x10,x20,#48
 mov x11,#8
 add x12,x21,#1056
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 add x10,x21,#232
 mov x11,#10
 add x12,x21,#1080
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 add x10,x21,#248
 mov x11,#10
 add x12,x21,#1104
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#4
 ldr x10,[x19,#144]
 mov x11,#8
 add x12,x21,#1128
 stp x9,x10,[x12]
 str x11,[x12,#16]
 add x0,x21,x22
 mov x1,#200
 sub x1,x1,x22
 adr x2,.Lfmt_norm
 mov x3,#.Lfmt_norm_len
 add x4,x21,#1008
 mov x5,#6
 bl .Lreport_write
 cbnz w0,.Lop_io_error
 mov x0,x21
 mov x1,#200
 bl .Lreport_trim_length
 mov x22,x0
 mov x9,#3
 add x10,x21,#424
 mov x11,#8
 add x12,x21,#1008
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 add x10,x21,#464
 mov x11,#2
 add x12,x21,#1032
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#3
 add x10,x21,#432
 mov x11,#8
 add x12,x21,#1056
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 add x10,x21,#466
 mov x11,#2
 add x12,x21,#1080
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#3
 add x10,x21,#440
 mov x11,#8
 add x12,x21,#1104
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#1
 add x10,x21,#468
 mov x11,#2
 add x12,x21,#1128
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#3
 add x10,x21,#448
 mov x11,#8
 add x12,x21,#1152
 stp x9,x10,[x12]
 str x11,[x12,#16]
 mov x9,#3
 add x10,x21,#456
 mov x11,#8
 add x12,x21,#1176
 stp x9,x10,[x12]
 str x11,[x12,#16]
 add x22,x22,#1
 add x0,x21,x22
 mov x1,#200
 sub x1,x1,x22
 adr x2,.Lfmt_monitor
 mov x3,#.Lfmt_monitor_len
 add x4,x21,#1008
 mov x5,#8
 bl .Lreport_write
 cbnz w0,.Lop_io_error
 mov x0,x21
 mov x1,#200
 bl .Lreport_trim_length
 mov x22,x0
 mov x9,#1
 add x10,x21,#0
 mov x11,#0
 add x12,x21,#1008
 stp x9,x10,[x12]
 str x11,[x12,#16]
 str x22,[x21,#1024]
 add x0,x19,#12
 mov x1,#0
 adr x2,.Lfmt_line
 mov x3,#.Lfmt_line_len
 add x4,x21,#1008
 mov x5,#1
 bl .Lreport_write
 cbnz w0,.Lop_io_error
 add x0,x19,#12
 bl _gfortran_flush_i4
 ldr x18,[x29,#96]
 mov w22,#0
 b .Lop_stop_profile
.Lop_io_error:
 mov w22,#1
.Lop_stop_profile:
 adr x0,.Levent_opdis
 adr x1,.Lint_one
 bl gstats_
 ldr x18,[x29,#96]
 mov w0,w22
 add sp,sp,#1280
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#112
 ret
.size .Lop_body,.-.Lop_body
.Lop_bad_leaf:
 mov w0,#2
 ret
.size md2asm_opdis_selected,.-md2asm_opdis_selected
.global md2asm_close_reporting_status
.type md2asm_close_reporting_status,%function
md2asm_close_reporting_status:
 cbz x0,.Lclose_bad_leaf
 tst x0,#7
 b.ne .Lclose_bad_leaf
 adds x9,x0,#152
 b.cs .Lclose_bad_leaf
 ldr w9,[x0,#16]
 cmp w9,#1
 b.hi .Lclose_bad_leaf
 cbnz w9,.Lclose_body
 mov w0,#0
 ret
.global .Lclose_body
.type .Lclose_body,%function
.Lclose_body:
 stp x29,x30,[sp,#-112]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 sub sp,sp,#80
 mov x21,sp
 mov x19,x0
 mov x9,#0
.Lclose_zero:
 add x10,x21,x9
 stp xzr,xzr,[x10]
 add x9,x9,#16
 cmp x9,#80
 b.lo .Lclose_zero
 mov w9,#32
 str w9,[x21]
 ldr w9,[x19,#12]
 str w9,[x21,#4]
 add x9,x21,#64
 str x9,[x21,#40]
 mov x0,x21
 bl _gfortran_st_close
 ldr x18,[x29,#96]
 ldr w0,[x21,#64]
 cbnz w0,.Lclose_error
 str wzr,[x19,#16]
 mov w0,#0
 b .Lclose_return
.Lclose_error:
 mov w0,#1
.Lclose_return:
 add sp,sp,#80
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#112
 ret
.size .Lclose_body,.-.Lclose_body
.Lclose_bad_leaf:
 mov w0,#2
 ret
.size md2asm_close_reporting_status,.-md2asm_close_reporting_status
.section .rodata
.p2align 3
.Lmaximum_model_seconds: .double 1.0e9
.Lmaximum_cpu_seconds: .double 1.0e12
.Lseconds_hour: .double 3600.0
.Lseconds_minute: .double 60.0
.Lstep_text: .ascii "STEP"
.Lint_zero: .word 0
.Lint_minus_one: .word -1
.Levent_opdis: .word 1930
.Lint_one: .word 1
.Lfmt_log: .ascii "(1X,A,':',A,':',A,' ',A,I5,' H=',I4,':',I2.2,' +CPU=',F7.3)"
.equ .Lfmt_log_len,.-.Lfmt_log
.Lfmt_listing: .ascii "(A42)"
.equ .Lfmt_listing_len,.-.Lfmt_listing
.Lfmt_memory: .ascii "(11X,\"STEP\",I5,\" :\")"
.equ .Lfmt_memory_len,.-.Lfmt_memory
.Lfmt_clock: .ascii "(A,':',A,':',A)"
.equ .Lfmt_clock_len,.-.Lfmt_clock
.Lfmt_caller: .ascii "(A,I6)"
.equ .Lfmt_caller_len,.-.Lfmt_caller
.Lfmt_accum: .ascii "(I7,\":\",I2.2)"
.equ .Lfmt_accum_len,.-.Lfmt_accum
.Lfmt_norm: .ascii "(3F9.3,2A10,E21.14,43X)"
.equ .Lfmt_norm_len,.-.Lfmt_norm
.Lfmt_monitor: .ascii "(I7,A2,1X,I7,A2,1X,I7,A2,1X,I6,\"kJ\",1X,I4,\"W\")"
.equ .Lfmt_monitor_len,.-.Lfmt_monitor
.Lfmt_line: .ascii "(A)"
.equ .Lfmt_line_len,.-.Lfmt_line
 .p2align 3
.Lreplace_text: .ascii "REPLACE"
.Lwrite_text: .ascii "WRITE"
.Lstatus_name: .ascii "ifs.stat"
.section .note.GNU-stack,"",%progbits

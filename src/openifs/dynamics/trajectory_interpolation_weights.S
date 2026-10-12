/* Complete source-ordered LAPINEA Cartesian full-level route.
 * Physics formulations/openifs/dynamics/trajectory_interpolation_weights.md.
 * Contract skills/md2asm/references/openifs/dynamics/trajectory_interpolation_weights.md.
 * Every preparation, child, diagnostic and output stage is owned here. */
.text
.p2align 4
.global md2asm_lapinea_7259755
.type md2asm_lapinea_7259755,%function
.macro LP_ARG reg,index
 ldr \reg,[x21,#8*\index]
.endm
.macro LP_FIELD reg,base,offset
 ldr x17,=\offset
 add \reg,\base,x17
.endm
.macro LP_MODEL reg,offset
 LP_FIELD \reg,x20,\offset
.endm
.macro LP_CHILD index
 str x9,[sp,#352+8*\index]
.endm
.macro LP_MAP index,parent
 LP_ARG x9,\parent
 LP_CHILD \index
.endm
.macro LP_SCRATCH index,slot
 ldr x9,[sp,#\slot]
 LP_CHILD \index
.endm
.macro LP_ZERO_CHECK offset
 LP_MODEL x9,\offset
 ldr w9,[x9]
 cbnz w9,.Llp_bad
.endm
.macro LP_PB2 field,slot
 LP_MODEL x9,\field
 ldrsw x10,[x9]
 mov x11,#0
 cmp x10,#1
 b.lt .Llp_view_done\@
 LP_MODEL x9,9184
 ldrsw x12,[x9]
 cmp x10,x12
 b.gt .Llp_view_done\@
 sub x10,x10,#1
 mul x10,x10,x22
 LP_ARG x11,8
 add x11,x11,x10,lsl #3
.Llp_view_done\@:
 str x11,[sp,#\slot]
.endm
md2asm_lapinea_7259755:
 mov x16,sp
 sub sp,sp,#2048
 add x17,sp,#1856
 stp x19,x20,[x17]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x25,x26,[x17,#48]
 stp x27,x28,[x17,#64]
 stp x29,x30,[x17,#80]
 stp d8,d9,[x17,#96]
 stp d10,d11,[x17,#112]
 stp d12,d13,[x17,#128]
 stp d14,d15,[x17,#144]
 add x21,sp,#704
 stp x0,x1,[x21]
 stp x2,x3,[x21,#16]
 stp x4,x5,[x21,#32]
 stp x6,x7,[x21,#48]
 add x10,x21,#64
 mov x9,#18
.Llp_arguments:
 ldr x11,[x16],#8
 str x11,[x10],#8
 subs x9,x9,#1
 b.ne .Llp_arguments
 mrs x9,fpcr
 cbnz x9,.Llp_bad
 mov x9,#0
.Llp_pointers:
 /* Unused hydrostatic half-level arrays may have zero extent. */
 cmp x9,#20
 b.eq .Llp_pointer_next
 cmp x9,#21
 b.eq .Llp_pointer_next
 cmp x9,#22
 b.eq .Llp_pointer_next
 ldr x10,[x21,x9,lsl #3]
 cbz x10,.Llp_bad
 tst x10,#3
 b.ne .Llp_bad
.Llp_pointer_next:
 add x9,x9,#1
 cmp x9,#26
 b.lo .Llp_pointers
 LP_ARG x19,0
 LP_ARG x20,2
 LP_ARG x25,5
 LP_FIELD x9,x19,5144
 ldrsw x22,[x9]
 cmp x22,#1
 b.lt .Llp_bad
 cmp x22,#1024
 b.gt .Llp_bad
 LP_FIELD x9,x19,5224
 ldrsw x23,[x9]
 cmp x23,#4
 b.lt .Llp_bad
 cmp x23,#256
 b.gt .Llp_bad
 mul x24,x22,x23
 lsl x24,x24,#3
 adrp x9,:got:__yomct0_MOD_lrplane
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lrplane]
 ldr w9,[x9]
 cbnz w9,.Llp_bad
 LP_ZERO_CHECK 4752
 LP_ZERO_CHECK 8
 LP_MODEL x9,4764
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Llp_bad
 LP_MODEL x9,4760
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Llp_bad
 LP_ARG x9,3
 ldrsw x10,[x9]
 cmp x10,#1
 b.lt .Llp_bad
 add x11,x22,#1
 cmp x10,x11
 b.gt .Llp_bad
 sub x10,x10,#1
 str w10,[sp,#936]
 LP_ARG x9,4
 ldrsw x11,[x9]
 cmp x11,x22
 b.gt .Llp_bad
 cmp x11,x10
 b.lt .Llp_bad
 str w11,[sp,#940]
 ldrsw x10,[x25,#1672]
 ldrsw x11,[x25,#1676]
 cmp x11,x10
 b.lt .Llp_bad
 sub x12,x11,x10
 cmp x12,#4095
 b.gt .Llp_bad
 add x12,x12,#1
 str w10,[sp,#944]
 str w11,[sp,#948]
 str w12,[sp,#952]
 /* Original one-dimensional integer descriptors, checked before any write. */
 add x0,x25,#136
 bl .Llp_integer_descriptor
 add x0,x25,#1736
 bl .Llp_integer_descriptor
 LP_ARG x9,1
 ldr w10,[x9,#184]
 cmp w10,#0
 b.lt .Llp_bad
 cmp w10,#1024
 b.gt .Llp_bad
 str w10,[sp,#968]
 ldr w10,[x9,#248]
 cmp w10,#0
 b.lt .Llp_bad
 str w10,[sp,#972]
 mov w10,#0
 LP_MODEL x11,216
 ldr w11,[x11]
 cbz w11,.Llp_no_diagnostic_setting
 LP_MODEL x11,340
 ldr w11,[x11]
 cbnz w11,.Llp_diagnostic_setting
 LP_MODEL x11,3036
 ldr w11,[x11]
 LP_MODEL x12,3032
 ldr w12,[x12]
 cmp w11,w12
 b.ne .Llp_no_diagnostic_setting
.Llp_diagnostic_setting:
 mov w10,#1
.Llp_no_diagnostic_setting:
 str w10,[sp,#960]
 cbz w10,.Llp_diagnostic_valid
 /* The pointer component is a contiguous array of 368-byte field records. */
 LP_FIELD x10,x9,800840
 ldr x11,[x10]
 cbz x11,.Llp_bad
 str x11,[sp,#1080]
 ldr x11,[x10,#16]
 cmp x11,#368
 b.ne .Llp_bad
 ldr x11,[x10,#32]
 cmp x11,#368
 b.ne .Llp_bad
 ldr w11,[x10,#28]
 ldr w12,=1281
 cmp w11,w12
 b.ne .Llp_bad
 ldr x11,[x10,#40]
 cmp x11,#1
 b.ne .Llp_bad
 ldr x11,[x10,#48]
 ldr x12,[x10,#8]
 neg x13,x11
 cmp x12,x13
 b.ne .Llp_bad
 str x11,[sp,#1112]
 ldrsw x26,[x9,#332]
 add x26,x26,#1
 ldrsw x27,[x9,#328]
 str w26,[sp,#956]
 str w27,[sp,#976]
 cmp x27,#1024
 b.gt .Llp_bad
 cmp x26,x27
 b.gt .Llp_diagnostic_valid
 cmp x26,x11
 b.lt .Llp_bad
 ldr x11,[x10,#56]
 cmp x27,x11
 b.gt .Llp_bad
.Llp_diagnostic_precheck:
 ldr x9,[sp,#1080]
 ldr x10,[sp,#1112]
 sub x10,x26,x10
 mov x11,#368
 madd x0,x10,x11,x9
 str x0,[sp,#1104]
 bl .Llp_diagnostic_name
 cmp w0,#6
 b.ge .Llp_diagnostic_precheck_next
 ldr x9,[sp,#1104]
 ldrsw x10,[x9,#188]
 cmp x10,#1
 b.lt .Llp_bad
 ldrsw x11,[sp,#972]
 cmp x10,x11
 b.gt .Llp_bad
.Llp_diagnostic_precheck_next:
 add x26,x26,#1
 cmp x26,x27
 b.le .Llp_diagnostic_precheck
.Llp_diagnostic_valid:
 /* Capture pointer-only field views with the original absent-field semantics. */
 LP_PB2 9284,1152
 LP_PB2 9288,1160
 LP_PB2 9292,1168
 LP_PB2 9296,1176
 LP_PB2 9320,1184
 LP_PB2 9324,1192
 LP_PB2 9328,1200
 bl __errno_location
 str x0,[sp,#1120]
 ldr w9,[x0]
 str w9,[sp,#984]
 ldrsw x0,[sp,#952]
 lsl x0,x0,#4
 mov x9,#3
 madd x0,x24,x9,x0
 str x0,[sp,#1128]
 bl malloc
 cbz x0,.Llp_bad
 str x0,[sp,#1024]
 mov x1,#0
 ldr x2,[sp,#1128]
 bl memset
 ldr x9,[sp,#1024]
 str x9,[sp,#1032]
 ldrsw x10,[sp,#952]
 add x9,x9,x10,lsl #3
 str x9,[sp,#1040]
 add x9,x9,x10,lsl #3
 str x9,[sp,#1048]
 add x9,x9,x24
 str x9,[sp,#1056]
 add x9,x9,x24
 str x9,[sp,#1064]
 add x9,x9,x24,lsr #1
 str x9,[sp,#1072]
 str wzr,[sp,#912]
 mov w9,#2
 str w9,[sp,#916]
 LP_MODEL x9,4760
 ldr w9,[x9]
 eor w9,w9,#1
 str w9,[sp,#920]
 str wzr,[sp,#924]
 str xzr,[sp,#928]
 /* Original separately rounded 2*pi and point-count divisions. */
 adrp x9,:got:__yomcst_MOD_rpi
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rpi]
 ldr d0,[x9]
 fmov d1,#2.0
 fmul d8,d1,d0
 ldrsw x10,[x25,#1664]
 ldrsw x11,[x25,#1720]
 ldrsw x12,[x25,#1364]
 add x10,x10,x11
 sub x10,x10,x12
 ldrsw x13,[x25,#1656]
 cmp x10,x13
 csel x26,x10,x13,ge
 sub x26,x26,x11
 ldrsw x10,[x25,#1668]
 add x10,x10,x11
 add x10,x10,x12
 ldrsw x13,[x25,#1660]
 cmp x10,x13
 csel x27,x10,x13,le
 sub x27,x27,x11
 ldrsw x10,[sp,#944]
 cmp x26,x10
 b.lt .Llp_bad
 ldrsw x10,[sp,#948]
 cmp x27,x10
 b.gt .Llp_bad
.Llp_scale_loop:
 cmp x26,x27
 b.gt .Llp_scale_done
 ldrsw x10,[x25,#1720]
 add x10,x26,x10
 ldr x11,[x25,#1736+48]
 cmp x10,x11
 b.lt .Llp_bad
 ldr x12,[x25,#1736+56]
 cmp x10,x12
 b.gt .Llp_bad
 sub x10,x10,x11
 ldr x9,[x25,#1736]
 ldrsw x9,[x9,x10,lsl #2]
 cmp x9,#1
 b.lt .Llp_bad
 scvtf d0,x9
 fdiv d0,d0,d8
 ldrsw x10,[sp,#944]
 sub x10,x26,x10
 ldr x9,[sp,#1032]
 str d0,[x9,x10,lsl #3]
 add x26,x26,#1
 b .Llp_scale_loop
.Llp_scale_done:
 /* Copy exactly the original latitude address intersection. */
 ldrsw x10,[sp,#944]
 ldr x11,[x25,#136+48]
 cmp x10,x11
 csel x26,x10,x11,ge
 ldrsw x10,[sp,#948]
 ldr x11,[x25,#136+56]
 cmp x10,x11
 csel x27,x10,x11,le
.Llp_latitude_addresses:
 cmp x26,x27
 b.gt .Llp_latitude_done
 ldr x10,[x25,#136+48]
 sub x10,x26,x10
 ldr x9,[x25,#136]
 ldr w9,[x9,x10,lsl #2]
 ldrsw x10,[sp,#944]
 sub x10,x26,x10
 ldr x11,[sp,#1040]
 str w9,[x11,x10,lsl #2]
 add x26,x26,#1
 b .Llp_latitude_addresses
.Llp_latitude_done:
 LP_ARG x29,1
 LP_FIELD x29,x29,4032+156
 mov x26,#0
.Llp_fields:
 ldrsw x9,[sp,#968]
 cmp x26,x9
 b.ge .Llp_fields_done
 mov x0,x29
 adr x1,.Llp_label1
 bl .Llp_compare12
 cbnz w0,.Llp_high_vertical
 mov x0,x29
 adr x1,.Llp_label2
 bl .Llp_compare12
 cbnz w0,.Llp_high_vertical
 mov x0,x29
 adr x1,.Llp_label3
 bl .Llp_compare12
 cbz w0,.Llp_field_next
.Llp_high_vertical:
 mov w9,#1
 str w9,[sp,#912]
.Llp_field_next:
 add x29,x29,#368
 add x26,x26,#1
 b .Llp_fields
.Llp_fields_done:
 /* All trajectory state and work owners belong to this native caller. */
 LP_MAP 0,0
 LP_ARG x9,1
 LP_FIELD x9,x9,1359320
 LP_CHILD 1
 LP_MAP 2,2
 LP_MAP 3,3
 LP_MAP 4,4
 LP_MAP 5,5
 LP_SCRATCH 6,1040
 LP_MAP 7,7
 LP_MAP 8,8
 LP_MAP 9,9
 LP_SCRATCH 10,1032
 LP_MAP 11,6
 LP_MAP 12,10
 LP_MAP 13,11
 LP_MAP 14,12
 LP_MAP 15,23
 LP_SCRATCH 16,1048
 LP_MAP 17,13
 LP_MAP 18,14
 LP_MAP 19,15
 LP_SCRATCH 20,1056
 LP_MAP 21,16
 LP_MAP 22,17
 LP_SCRATCH 23,1064
 mov x9,#8
 add x10,sp,#352
.Llp_trajectory_stack:
 ldr x11,[x10,x9,lsl #3]
 sub x12,x9,#8
 str x11,[sp,x12,lsl #3]
 add x9,x9,#1
 cmp x9,#24
 b.lo .Llp_trajectory_stack
 ldp x0,x1,[x10]
 ldp x2,x3,[x10,#16]
 ldp x4,x5,[x10,#32]
 ldp x6,x7,[x10,#48]
 bl md2asm_larmes_xyz_7259755
 ldr w9,[sp,#960]
 cbz w9,.Llp_full_weights
 ldrsw x26,[sp,#956]
.Llp_diagnostics:
 ldrsw x9,[sp,#976]
 cmp x26,x9
 b.gt .Llp_full_weights
 ldr x9,[sp,#1080]
 ldr x10,[sp,#1112]
 sub x10,x26,x10
 mov x11,#368
 madd x0,x10,x11,x9
 str x0,[sp,#1104]
 bl .Llp_diagnostic_name
 cmp w0,#6
 b.ge .Llp_next_diagnostic
 str w0,[sp,#964]
 ldr x9,[sp,#1104]
 ldrsw x9,[x9,#188]
 sub x9,x9,#1
 LP_ARG x10,24
 madd x9,x9,x24,x10
 str x9,[sp,#1096]
 cmp w0,#0
 b.ne .Llp_diag_v
 LP_ARG x9,14
 b .Llp_diag_pointer
.Llp_diag_v:
 cmp w0,#1
 b.ne .Llp_diag_w
 LP_ARG x9,15
 b .Llp_diag_pointer
.Llp_diag_w:
 cmp w0,#2
 b.ne .Llp_diag_lon
 ldr x9,[sp,#1056]
 b .Llp_diag_pointer
.Llp_diag_lon:
 cmp w0,#3
 b.ne .Llp_diag_lat
 LP_ARG x9,13
 LP_MODEL x10,6812
 ldrsw x10,[x10]
 sub x10,x10,#1
 madd x9,x10,x24,x9
 b .Llp_diag_pointer
.Llp_diag_lat:
 cmp w0,#4
 b.ne .Llp_diag_eta
 LP_ARG x9,13
 LP_MODEL x10,6816
 ldrsw x10,[x10]
 sub x10,x10,#1
 madd x9,x10,x24,x9
 b .Llp_diag_pointer
.Llp_diag_eta:
 ldr x9,[sp,#1048]
.Llp_diag_pointer:
 str x9,[sp,#1088]
 mov x27,#0
.Llp_diag_level:
 ldrsw x28,[sp,#936]
.Llp_diag_column:
 ldrsw x9,[sp,#940]
 cmp x28,x9
 b.ge .Llp_diag_next_level
 madd x29,x27,x22,x28
 ldr x9,[sp,#1088]
 ldr d0,[x9,x29,lsl #3]
 ldr w9,[sp,#964]
 cmp w9,#3
 b.lt .Llp_diag_store
 cmp w9,#4
 b.gt .Llp_diag_store
 bl md2asm_sin_original_rounding
.Llp_diag_store:
 ldr x9,[sp,#1096]
 str d0,[x9,x29,lsl #3]
 add x28,x28,#1
 b .Llp_diag_column
.Llp_diag_next_level:
 add x27,x27,#1
 cmp x27,x23
 b.lt .Llp_diag_level
.Llp_next_diagnostic:
 add x26,x26,#1
 b .Llp_diagnostics
.Llp_full_weights:
 LP_MAP 0,0
 LP_MAP 1,2
 LP_MAP 2,3
 LP_MAP 3,4
 LP_MAP 4,5
 add x9,sp,#912
 LP_CHILD 5
 LP_SCRATCH 6,1040
 LP_MODEL x9,5024
 LP_CHILD 7
 LP_MODEL x9,76
 LP_CHILD 8
 LP_MODEL x9,108
 LP_CHILD 9
 add x9,sp,#924
 LP_CHILD 10
 add x9,sp,#916
 LP_CHILD 11
 add x9,sp,#920
 LP_CHILD 12
 add x9,sp,#924
 LP_CHILD 13
 LP_SCRATCH 14,1032
 LP_MAP 15,6
 LP_MAP 16,23
 LP_SCRATCH 17,1048
 LP_SCRATCH 18,1152
 LP_SCRATCH 19,1160
 LP_SCRATCH 20,1168
 LP_SCRATCH 21,1176
 LP_SCRATCH 22,1184
 LP_SCRATCH 23,1192
 LP_SCRATCH 24,1200
 add x9,sp,#928
 LP_CHILD 25
 LP_CHILD 26
 LP_CHILD 27
 LP_CHILD 28
 LP_MAP 29,10
 LP_MAP 30,11
 LP_MAP 31,13
 add x9,sp,#928
 LP_CHILD 32
 LP_CHILD 33
 LP_CHILD 34
 LP_CHILD 35
 LP_CHILD 36
 LP_MAP 37,16
 LP_MAP 38,17
 LP_SCRATCH 39,1064
 LP_MAP 40,18
 LP_MAP 41,19
 LP_SCRATCH 42,1072
 LP_MAP 43,25
 mov x9,#8
 add x10,sp,#352
.Llp_weights_stack:
 ldr x11,[x10,x9,lsl #3]
 sub x12,x9,#8
 str x11,[sp,x12,lsl #3]
 add x9,x9,#1
 cmp x9,#44
 b.lo .Llp_weights_stack
 ldp x0,x1,[x10]
 ldp x2,x3,[x10,#16]
 ldp x4,x5,[x10,#32]
 ldp x6,x7,[x10,#48]
 bl md2asm_larcina_7240564
 ldr x0,[sp,#1024]
 bl free
 ldr x9,[sp,#1120]
 ldr w10,[sp,#984]
 str w10,[x9]
 adr x9,.Llp_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 add x17,sp,#1856
 ldp x19,x20,[x17]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x25,x26,[x17,#48]
 ldp x27,x28,[x17,#64]
 ldp x29,x30,[x17,#80]
 ldp d8,d9,[x17,#96]
 ldp d10,d11,[x17,#112]
 ldp d12,d13,[x17,#128]
 ldp d14,d15,[x17,#144]
 add sp,sp,#2048
 ret
.Llp_bad:
 bl abort
 brk #0
.size md2asm_lapinea_7259755,.-md2asm_lapinea_7259755
/* Record helpers use integer loads only and do not alter numerical status. */
.Llp_integer_descriptor:
 ldr x9,[x0]
 cbz x9,.Llp_bad
 tst x9,#3
 b.ne .Llp_bad
 ldr x9,[x0,#16]
 cmp x9,#4
 b.ne .Llp_bad
 ldr x9,[x0,#32]
 cmp x9,#4
 b.ne .Llp_bad
 ldr w9,[x0,#28]
 cmp w9,#257
 b.ne .Llp_bad
 ldr x9,[x0,#40]
 cmp x9,#1
 b.ne .Llp_bad
 ldp x9,x10,[x0,#48]
 cmp x10,x9
 b.lt .Llp_bad
 neg x9,x9
 ldr x10,[x0,#8]
 cmp x10,x9
 b.ne .Llp_bad
 ret
.Llp_compare12:
 ldr x9,[x0]
 ldr x10,[x1]
 cmp x9,x10
 b.ne .Llp_unequal
 ldr w9,[x0,#8]
 ldr w10,[x1,#8]
 cmp w9,w10
 cset w0,eq
 ret
.Llp_unequal:
 mov w0,#0
 ret
/* Return 0 through 5 for one recognised diagnostic, otherwise 6. */
.Llp_diagnostic_name:
 adr x1,.Llp_diagnostic_labels
 ldp x9,x10,[x0]
 mov w0,#0
.Llp_name_loop:
 ldp x11,x12,[x1],#16
 cmp x9,x11
 b.ne .Llp_name_next
 cmp x10,x12
 b.eq .Llp_name_return
.Llp_name_next:
 add w0,w0,#1
 cmp w0,#6
 b.lt .Llp_name_loop
.Llp_name_return:
 ret
.global lapinea_
.set lapinea_,md2asm_lapinea_7259755
.global md2asm_lapinea_calls_get
.type md2asm_lapinea_calls_get,%function
md2asm_lapinea_calls_get:
 adr x9,.Llp_calls
 ldr x0,[x9]
 ret
.size md2asm_lapinea_calls_get,.-md2asm_lapinea_calls_get
.section .rodata
.Llp_label1: .ascii "LAIHVT      "
.Llp_label2: .ascii "LAIHVTQM    "
.Llp_label3: .ascii "LAIHVTQMH   "
.Llp_diagnostic_labels:
 .ascii "UTRAJ           "
 .ascii "VTRAJ           "
 .ascii "WTRAJ           "
 .ascii "LAMBDA0         "
 .ascii "THETA0          "
 .ascii "ETA0            "
.data
.p2align 3
.Llp_calls:.quad 0
.section .note.GNU-stack,"",%progbits

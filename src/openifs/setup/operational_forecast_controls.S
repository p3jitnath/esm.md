/* Qualified live-provider contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md. */
/* Contract: skills/md2asm/references/openifs/setup/operational_model_configuration.md. */
/* Own the operational SUARG input edge, complete SUCT0 controls and
 * live NAMRIP clock input. x0 text,x1 bytes,x2 upstream16,x3 output51512,
 * x4 capacity>=51512. Return 0/2; failure leaves output unchanged.
 * The owned layout and source order are frozen in the component contract.
 * No original OpenIFS data, callables or constructed-state input is used. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_forecast_controls
.type md2asm_initialize_operational_forecast_controls,%function
md2asm_initialize_operational_forecast_controls:
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 sub sp,sp,#640
 mov x19,x0
 mov x21,x3
 mov x22,x2
 mov x23,sp
 cbz x0,.Lcontrols_bad
 cbz x2,.Lcontrols_bad
 cbz x3,.Lcontrols_bad
 cbz x1,.Lcontrols_bad
 cmp x1,#64,lsl#12
 b.hi .Lcontrols_bad
 mov x9,#51512
 cmp x4,x9
 b.lo .Lcontrols_bad
 orr x10,x2,x3
 tst x10,#7
 b.ne .Lcontrols_bad
 adds x20,x0,x1
 b.cs .Lcontrols_bad
 adds x24,x2,#16
 b.cs .Lcontrols_bad
 adds x25,x3,x9
 b.cs .Lcontrols_bad
 cmp x24,x19
 b.ls .Lcontrols_range2
 cmp x22,x20
 b.lo .Lcontrols_bad
.Lcontrols_range2:
 cmp x25,x19
 b.ls .Lcontrols_range3
 cmp x21,x20
 b.lo .Lcontrols_bad
.Lcontrols_range3:
 cmp x25,x22
 b.ls .Lcontrols_ranges_ok
 cmp x21,x24
 b.lo .Lcontrols_bad
.Lcontrols_ranges_ok:
 ldr w9,[x22,#8]
 tbnz w9,#31,.Lcontrols_bad
 ldr w9,[x22,#12]
 cmp w9,#1
 b.hi .Lcontrols_bad
 mrs x9,fpcr
 cbnz x9,.Lcontrols_bad
 /* Temporary values follow source defaults before the live reads. */
 adr x9,.Lselected_value_defaults
 ldp x10,x11,[x9]
 stp x10,x11,[x23]
 ldp x10,x11,[x9,#16]
 stp x10,x11,[x23,#16]
 ldp x10,x11,[x9,#32]
 stp x10,x11,[x23,#32]
 ldp x10,x11,[x9,#48]
 stp x10,x11,[x23,#48]
 /* Source defaults for the additional live NAMCT0 values. */
 adr x9,.Lop_additional_defaults
 add x10,x23,#464
 mov w11,#9
.Lop_init_extra:
 ldr w12,[x9],#4
 str w12,[x10],#4
 subs w11,w11,#1
 b.ne .Lop_init_extra
 adr x9,.Lchar_CMETER
 add x10,x23,#512
 mov w11,#25
.Lop_init_meter:
 ldrb w12,[x9],#1
 strb w12,[x10],#1
 subs w11,w11,#1
 b.ne .Lop_init_meter
 adr x9,.Lchar_CEVENT
 add x10,x23,#544
 mov w11,#25
.Lop_init_event:
 ldrb w12,[x9],#1
 strb w12,[x10],#1
 subs w11,w11,#1
 b.ne .Lop_init_event
 mov x0,x19
 mov x1,x20
 adr x2,.Lgroup_arg
 mov x3,#6
 adr x4,.Lkeys_arg
 mov x5,x23
 bl .Lparse_control_group
 cbnz w0,.Lcontrols_bad
 mov x0,x19
 mov x1,x20
 adr x2,.Lgroup_ct0
 mov x3,#6
 adr x4,.Lkeys_ct0
 mov x5,x23
 bl .Lparse_control_group
 cbnz w0,.Lcontrols_bad
 mov x0,x19
 mov x1,x20
 adr x2,.Lgroup_rip
 mov x3,#6
 adr x4,.Lkeys_rip
 mov x5,x23
 bl .Lparse_control_group
 cbnz w0,.Lcontrols_bad
 ldr w9,[x23,#56]
 cmp w9,#3
 b.ne .Lcontrols_bad
 /* Preserve every incoming clock byte that the accepted child retains. */
 mov x9,#51112
 add x24,x21,x9
 mov x9,#0
.Lcopy_clock_in:
 ldr x10,[x24,x9]
 add x11,x23,#64
 str x10,[x11,x9]
 add x9,x9,#8
 cmp x9,#400
 b.lo .Lcopy_clock_in
 ldr x9,[x22]
 str x9,[x23,#64]
 movz x9,#0x2000,lsl#32
 movk x9,#0x407c,lsl#48
 str x9,[x23,#72]
 ldr x9,[x23,#48]
 str x9,[x23,#80]
 str wzr,[x23,#88]
 mov x9,#0xbff0000000000000
 str x9,[x23,#96]
 add x0,x23,#64
 add x1,x23,#104
 mov x2,#360
 bl md2asm_initialize_operational_model_clock
 cbnz w0,.Lcontrols_bad
 /* All validation has completed. Assign source-defined namespace bytes. */
 adr x26,.Lcontrol_default_rows
.Lcontrol_default_next:
 ldp w9,w10,[x26],#8
 cmp w9,#-1
 b.eq .Lcontrol_arrays
 str w10,[x21,x9]
 b .Lcontrol_default_next
.Lcontrol_arrays:
 mov x9,#0
 add x9,x21,x9
 mov x10,#961
.Lzero_NPOSTS:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NPOSTS
 mov x9,#3844
 add x9,x21,x9
 mov x10,#961
.Lzero_NHISTS:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NHISTS
 mov x9,#7688
 add x9,x21,x9
 mov x10,#961
.Lzero_NGDITS:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NGDITS
 mov x9,#11532
 add x9,x21,x9
 mov x10,#961
.Lzero_NSDITS:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NSDITS
 mov x9,#15376
 add x9,x21,x9
 mov x10,#961
.Lzero_NDHFGTS:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NDHFGTS
 mov x9,#19220
 add x9,x21,x9
 mov x10,#961
.Lzero_NDHFZTS:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NDHFZTS
 mov x9,#23064
 add x9,x21,x9
 mov x10,#961
.Lzero_NDHFDTS:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NDHFDTS
 mov x9,#26908
 add x9,x21,x9
 mov x10,#961
.Lzero_NDHPTS:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NDHPTS
 mov x9,#30752
 add x9,x21,x9
 mov x10,#961
.Lzero_NMASSCONS:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NMASSCONS
 mov x9,#34596
 add x9,x21,x9
 adr x10,.Lchar_CNMEXP
 mov x11,#16
.Lchar_copy_CNMEXP:
 ldrb w12,[x10],#1
 strb w12,[x9],#1
 subs x11,x11,#1
 b.ne .Lchar_copy_CNMEXP
 mov x9,#34612
 add x9,x21,x9
 adr x10,.Lchar_CFPNCF
 mov x11,#128
.Lchar_copy_CFPNCF:
 ldrb w12,[x10],#1
 strb w12,[x9],#1
 subs x11,x11,#1
 b.ne .Lchar_copy_CFPNCF
 mov x9,#34744
 add x9,x21,x9
 adr x10,.Lchar_CNPPATH
 mov x11,#120
.Lchar_copy_CNPPATH:
 ldrb w12,[x10],#1
 strb w12,[x9],#1
 subs x11,x11,#1
 b.ne .Lchar_copy_CNPPATH
 mov x9,#34864
 add x9,x21,x9
 adr x10,.Lchar_CFDIRLST
 mov x11,#120
.Lchar_copy_CFDIRLST:
 ldrb w12,[x10],#1
 strb w12,[x9],#1
 subs x11,x11,#1
 b.ne .Lchar_copy_CFDIRLST
 mov x9,#34984
 add x9,x21,x9
 adr x10,.Lchar_CNDISPP
 mov x11,#120
.Lchar_copy_CNDISPP:
 ldrb w12,[x10],#1
 strb w12,[x9],#1
 subs x11,x11,#1
 b.ne .Lchar_copy_CNDISPP
 mov x9,#35192
 add x9,x21,x9
 adr x10,.Lchar_CMETER
 mov x11,#25
.Lchar_copy_CMETER:
 ldrb w12,[x10],#1
 strb w12,[x9],#1
 subs x11,x11,#1
 b.ne .Lchar_copy_CMETER
 mov x9,#35217
 add x9,x21,x9
 adr x10,.Lchar_CEVENT
 mov x11,#25
.Lchar_copy_CEVENT:
 ldrb w12,[x10],#1
 strb w12,[x9],#1
 subs x11,x11,#1
 b.ne .Lchar_copy_CEVENT
 mov x9,#35320
 add x9,x21,x9
 adr x10,.Lchar_CSCRIPT_PPSERVER
 mov x11,#120
.Lchar_copy_CSCRIPT_PPSERVER:
 ldrb w12,[x10],#1
 strb w12,[x9],#1
 subs x11,x11,#1
 b.ne .Lchar_copy_CSCRIPT_PPSERVER
 mov x9,#35440
 add x9,x21,x9
 adr x10,.Lchar_CSCRIPT_LAMRTC
 mov x11,#120
.Lchar_copy_CSCRIPT_LAMRTC:
 ldrb w12,[x10],#1
 strb w12,[x9],#1
 subs x11,x11,#1
 b.ne .Lchar_copy_CSCRIPT_LAMRTC
 mov x9,#35632
 add x9,x21,x9
 mov x10,#961
.Lzero_NSFXHISTS:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NSFXHISTS
 mov x9,#39540
 add x9,x21,x9
 mov x10,#961
.Lzero_NHISTSMIN:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NHISTSMIN
 mov x9,#43384
 add x9,x21,x9
 mov x10,#961
.Lzero_NSFXHISTSMIN:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NSFXHISTSMIN
 mov x9,#47228
 add x9,x21,x9
 mov x10,#961
.Lzero_NPOSTSMIN:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lzero_NPOSTSMIN
 ldr w10,[x23,#0]
 mov x9,#35140
 str w10,[x21,x9]
 ldr w10,[x23,#4]
 mov x9,#35132
 str w10,[x21,x9]
 ldr w10,[x23,#8]
 mov x9,#35312
 str w10,[x21,x9]
 ldr w10,[x23,#12]
 mov x9,#35180
 str w10,[x21,x9]
 ldr w10,[x23,#16]
 mov x9,#35128
 str w10,[x21,x9]
 ldr w10,[x23,#20]
 mov x9,#35124
 str w10,[x21,x9]
 ldr w10,[x23,#24]
 mov x9,#35252
 str w10,[x21,x9]
 ldr w10,[x23,#28]
 mov x9,#35160
 str w10,[x21,x9]
 ldr w10,[x23,#32]
 mov x9,#35156
 str w10,[x21,x9]
 ldr w10,[x23,#36]
 mov x9,#51076
 str w10,[x21,x9]
 ldr w10,[x23,#60]
 mov x9,#35188
 str w10,[x21,x9]
 /* Source live LARPEGEF. */
 ldr w10,[x23,#464]
 mov x9,#35184
 str w10,[x21,x9]
 /* Source live NFRMASSCON. */
 ldr w10,[x23,#468]
 mov x9,#35168
 str w10,[x21,x9]
 /* Source live NPOSTS(0). */
 ldr w10,[x23,#472]
 mov x9,#0
 str w10,[x21,x9]
 /* Source live NHISTS(0). */
 ldr w10,[x23,#476]
 mov x9,#3844
 str w10,[x21,x9]
 /* Source live NMASSCONS(0). */
 ldr w10,[x23,#480]
 mov x9,#30752
 str w10,[x21,x9]
 /* Source live NFRCO. */
 ldr w10,[x23,#484]
 mov x9,#35164
 str w10,[x21,x9]
 /* Source live NFRDHFZ. */
 ldr w10,[x23,#488]
 mov x9,#35152
 str w10,[x21,x9]
 /* Source live NDHFZTS(0). */
 ldr w10,[x23,#492]
 mov x9,#19220
 str w10,[x21,x9]
 /* Source live NDHFDTS(0). */
 ldr w10,[x23,#496]
 mov x9,#23064
 str w10,[x21,x9]
 add x9,x23,#512
 mov x10,#35192
 add x10,x21,x10
 mov w11,#25
.Lop_publish_meter:
 ldrb w12,[x9],#1
 strb w12,[x10],#1
 subs w11,w11,#1
 b.ne .Lop_publish_meter
 add x9,x23,#544
 mov x10,#35217
 add x10,x21,x10
 mov w11,#25
.Lop_publish_event:
 ldrb w12,[x9],#1
 strb w12,[x10],#1
 subs w11,w11,#1
 b.ne .Lop_publish_event
 ldr w10,[x23,#24]
 cmp w10,#0
 cset w10,ne
 mov x9,#35600
 str w10,[x21,x9]
 ldr w10,[x23,#40]
 mov x9,#34596
 str w10,[x21,x9]
 mov x9,#0
.Lcopy_clock_out:
 add x11,x23,#64
 ldr x10,[x11,x9]
 str x10,[x24,x9]
 add x9,x9,#8
 cmp x9,#400
 b.lo .Lcopy_clock_out
 mov w0,#0
 b .Lcontrols_return
.Lcontrols_bad:
 mov w0,#2
.Lcontrols_return:
 add sp,sp,#640
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_initialize_operational_forecast_controls,.-md2asm_initialize_operational_forecast_controls

/* Bounded first-group parser, adapted from the accepted namelist children.
 * The table gives a key, its source value kind, bounds and temporary slot. */
.global md2asm_parse_operational_forecast_group
.type md2asm_parse_operational_forecast_group,%function
md2asm_parse_operational_forecast_group:
.Lparse_control_group:
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x5
 mov x22,x4
 mov x23,x2
 mov x24,x3
.Lgroup_start_line:
 mov w15,#0
.Lgroup_find:
 cmp x19,x20
 b.hs .Lparse_bad
 ldrb w9,[x19],#1
 cmp w9,#10
 b.eq .Lgroup_start_line
 add w15,w15,#1
 cmp w9,#32
 b.eq .Lgroup_find
 cmp w9,#9
 b.eq .Lgroup_find
 cmp w9,#13
 b.eq .Lgroup_find
 cmp w9,#38
 b.ne .Lgroup_skip_line
 cmp w15,#10
 b.hi .Lgroup_skip_line
 add x9,x19,x24
 cmp x9,x20
 b.hs .Lparse_bad
 mov x10,#0
.Lgroup_match:
 ldrb w11,[x19,x10]
 ldrb w12,[x23,x10]
 cmp w11,w12
 b.ne .Lgroup_skip_line
 add x10,x10,#1
 cmp x10,x24
 b.lo .Lgroup_match
 add x9,x19,x24
 ldrb w10,[x9]
 cmp w10,#32
 b.eq .Lgroup_found
 cmp w10,#9
 b.eq .Lgroup_found
 cmp w10,#13
 b.eq .Lgroup_found
 cmp w10,#10
 b.eq .Lgroup_found
 cmp w10,#47
 b.eq .Lgroup_found
 b .Lgroup_skip_line
.Lgroup_found:
 mov x19,x9
 b .Lparse_key
.Lgroup_skip_line:
 cmp x19,x20
 b.hs .Lparse_bad
 ldrb w9,[x19],#1
 cmp w9,#10
 b.ne .Lgroup_skip_line
 b .Lgroup_start_line
.Lparse_key:
 mov x0,x19
 mov x1,x20
 bl .Lskip_control_space
 mov x19,x0
 cmp x19,x20
 b.hs .Lparse_bad
 ldrb w9,[x19]
 cmp w9,#44
 b.ne .Lparse_key_start
 add x19,x19,#1
 b .Lparse_key
.Lparse_key_start:
 cmp w9,#47
 b.eq .Lparse_ok
 mov x25,x19
.Lparse_key_scan:
 cmp x19,x20
 b.hs .Lparse_bad
 ldrb w9,[x19]
 sub w10,w9,#65
 cmp w10,#25
 b.ls .Lparse_key_next
 sub w10,w9,#97
 cmp w10,#25
 b.ls .Lparse_key_next
 sub w10,w9,#48
 cmp w10,#9
 b.ls .Lparse_key_next
 cmp w9,#95
 b.eq .Lparse_key_next
 cmp w9,#37
 b.eq .Lparse_key_next
 cmp w9,#40
 b.eq .Lparse_key_next
 cmp w9,#41
 b.ne .Lparse_key_lookup
.Lparse_key_next:
 add x19,x19,#1
 b .Lparse_key_scan
.Lparse_key_lookup:
 sub x15,x19,x25
 mov x16,x22
.Lkey_table_next:
 ldr w9,[x16]
 cbz w9,.Lparse_bad
 cmp x9,x15
 b.ne .Lkey_table_advance
 mov x10,#0
 add x17,x16,#24
.Lkey_name_compare:
 ldrb w11,[x25,x10]
 sub w12,w11,#97
 cmp w12,#25
 b.hi .Lkey_upper_done
 sub w11,w11,#32
.Lkey_upper_done:
 ldrb w12,[x17,x10]
 cmp w11,w12
 b.ne .Lkey_table_advance
 add x10,x10,#1
 cmp x10,x15
 b.lo .Lkey_name_compare
 ldr w26,[x16,#4]
 ldr w27,[x16,#8]
 ldr w23,[x16,#12]
 ldr w24,[x16,#16]
 b .Lparse_equal
.Lkey_table_advance:
 add x16,x16,#40
 b .Lkey_table_next
.Lparse_equal:
 mov x0,x19
 mov x1,x20
 bl .Lskip_control_space
 mov x19,x0
 cmp x19,x20
 b.hs .Lparse_bad
 ldrb w9,[x19],#1
 cmp w9,#61
 b.ne .Lparse_bad
 mov x0,x19
 mov x1,x20
 bl .Lskip_control_space
 mov x19,x0
 cmp x19,x20
 b.hs .Lparse_bad
 cmp w26,#3
 b.eq .Lparse_string
 cmp w26,#5
 b.eq .Lparse_string
 cmp w26,#6
 b.eq .Lparse_string
 mov x28,x19
.Lvalue_scan:
 cmp x19,x20
 b.hs .Lparse_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lvalue_found
 cmp w9,#9
 b.eq .Lvalue_found
 cmp w9,#13
 b.eq .Lvalue_found
 cmp w9,#10
 b.eq .Lvalue_found
 cmp w9,#44
 b.eq .Lvalue_found
 cmp w9,#33
 b.eq .Lvalue_found
 cmp w9,#47
 b.eq .Lvalue_found
 add x19,x19,#1
 b .Lvalue_scan
.Lvalue_found:
 sub x25,x19,x28
 cbz x25,.Lparse_bad
 cmp w26,#4
 b.eq .Lparse_timestep
 cmp w26,#2
 b.eq .Lparse_logical
 mov x0,x28
 mov x1,x19
 bl .Lparse_control_integer
 cbnz w3,.Lparse_bad
 b .Lcheck_value_bounds
.Lparse_logical:
 mov x0,x28
 mov x1,x25
 bl .Lparse_control_logical
 cbnz w3,.Lparse_bad
.Lcheck_value_bounds:
 cmp w2,w23
 b.lt .Lparse_bad
 cmp w2,w24
 b.gt .Lparse_bad
 str w2,[x21,x27]
 b .Lcheck_value_end
.Lparse_timestep:
 cmp x25,#3
 b.lo .Lparse_bad
 ldrh w9,[x28]
 mov w10,#0x3534
 cmp w9,w10
 b.ne .Lparse_bad
 ldrb w9,[x28,#2]
 cmp w9,#48
 b.ne .Lparse_bad
 cmp x25,#3
 b.eq .Ltimestep_valid
 ldrb w9,[x28,#3]
 cmp w9,#46
 b.ne .Lparse_bad
 mov x10,#4
.Ltimestep_zero:
 cmp x10,x25
 b.hs .Ltimestep_valid
 ldrb w9,[x28,x10]
 cmp w9,#48
 b.ne .Lparse_bad
 add x10,x10,#1
 b .Ltimestep_zero
.Ltimestep_valid:
 ldr w9,[x21,#56]
 orr w9,w9,#1
 str w9,[x21,#56]
 b .Lcheck_value_end
.Lparse_string:
 ldrb w9,[x19],#1
 cmp w9,#39
 b.eq .Lstring_quote_ok
 cmp w9,#34
 b.ne .Lparse_bad
.Lstring_quote_ok:
 mov w10,w9
 mov x25,x19
 mov x11,#0
 mov x12,#4
 cmp w26,#6
 b.eq .Lop_string_width25
 cmp w26,#5
 b.ne .Lstring_scan
 mov x12,#8
 b .Lstring_scan
.Lop_string_width25:
 mov x12,#25
.Lstring_scan:
 cmp x19,x20
 b.hs .Lparse_bad
 ldrb w9,[x19],#1
 cmp w9,w10
 b.eq .Lstring_found
 cmp w9,#10
 b.eq .Lparse_bad
 cmp w9,#13
 b.eq .Lparse_bad
 add x11,x11,#1
 cmp x11,x12
 b.hi .Lparse_bad
 b .Lstring_scan
.Lstring_found:
 add x13,x21,x27
 mov x14,#0
 mov w15,#32
.Lstring_copy:
 cmp x14,x11
 b.hs .Lstring_pad
 ldrb w15,[x25,x14]
 b .Lstring_store
.Lstring_pad:
 mov w15,#32
.Lstring_store:
 strb w15,[x13,x14]
 add x14,x14,#1
 cmp x14,x12
 b.lo .Lstring_copy
 cmp w26,#5
 b.ne .Lcheck_value_end
 ldr w9,[x21,#56]
 orr w9,w9,#2
 str w9,[x21,#56]
.Lcheck_value_end:
 cmp x19,x20
 b.hs .Lparse_bad
 ldrb w9,[x19]
 cmp w9,#32
 b.eq .Lparse_key
 cmp w9,#9
 b.eq .Lparse_key
 cmp w9,#13
 b.eq .Lparse_key
 cmp w9,#10
 b.eq .Lparse_key
 cmp w9,#44
 b.eq .Lparse_key
 cmp w9,#33
 b.eq .Lparse_key
 cmp w9,#47
 b.eq .Lparse_key
 b .Lparse_bad
.Lparse_ok:
 mov w0,#0
 b .Lparse_return
.Lparse_bad:
 mov w0,#2
.Lparse_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_parse_operational_forecast_group,.-md2asm_parse_operational_forecast_group
/* Skip bounded spaces and complete line comments. */
.Lskip_control_space:
 cmp x0,x1
 b.hs .Lspace_return
 ldrb w9,[x0]
 cmp w9,#32
 b.eq .Lspace_next
 cmp w9,#9
 b.eq .Lspace_next
 cmp w9,#13
 b.eq .Lspace_next
 cmp w9,#10
 b.eq .Lspace_next
 cmp w9,#33
 b.ne .Lspace_return
.Lspace_comment:
 add x0,x0,#1
 cmp x0,x1
 b.hs .Lspace_return
 ldrb w9,[x0]
 cmp w9,#10
 b.ne .Lspace_comment
.Lspace_next:
 add x0,x0,#1
 b .Lskip_control_space
.Lspace_return:
 ret
/* Parse a bounded signed decimal integer without floating-point state. */
.Lparse_control_integer:
 mov w2,#0
 mov w3,#2
 mov w9,#0
 cmp x0,x1
 b.hs .Lint_return
 ldrb w10,[x0]
 cmp w10,#45
 b.ne .Lint_plus
 mov w9,#1
 add x0,x0,#1
 b .Lint_first
.Lint_plus:
 cmp w10,#43
 b.ne .Lint_first
 add x0,x0,#1
.Lint_first:
 cmp x0,x1
 b.hs .Lint_return
 mov w12,#10
 mov w13,#0xe0ff
 movk w13,#0x5f5,lsl#16
.Lint_digit:
 ldrb w10,[x0],#1
 sub w10,w10,#48
 cmp w10,#9
 b.hi .Lint_return
 madd w2,w2,w12,w10
 cmp w2,w13
 b.hi .Lint_return
 cmp x0,x1
 b.lo .Lint_digit
 cmp w9,#0
 cneg w2,w2,ne
 mov w3,#0
.Lint_return:
 ret
/* Read the ordinary Fortran logical tokens used by selected live input. */
.Lparse_control_logical:
 mov w3,#2
 cmp x1,#3
 b.lo .Llogical_return
 ldrb w9,[x0]
 cmp w9,#46
 b.ne .Llogical_names
 sub x1,x1,#2
 add x0,x0,#1
 ldrb w9,[x0,x1]
 cmp w9,#46
 b.ne .Llogical_return
.Llogical_names:
 cmp x1,#4
 b.ne .Llogical_false
 adr x10,.Ltrue_name
 mov w2,#1
 b .Llogical_compare_start
.Llogical_false:
 cmp x1,#5
 b.ne .Llogical_return
 adr x10,.Lfalse_name
 mov w2,#0
.Llogical_compare_start:
 mov x11,#0
.Llogical_compare:
 ldrb w9,[x0,x11]
 sub w12,w9,#97
 cmp w12,#25
 b.hi .Llogical_upper_done
 sub w9,w9,#32
.Llogical_upper_done:
 ldrb w12,[x10,x11]
 cmp w9,w12
 b.ne .Llogical_return
 add x11,x11,#1
 cmp x11,x1
 b.lo .Llogical_compare
 mov w3,#0
.Llogical_return:
 ret
.section .rodata
.p2align 3
.Lselected_value_defaults:
 .word 24,0,0,1,1,-1,0,48,4,-99999999
 .ascii "0123"
 .word 0
 .ascii "-9      "
 .word 0,0
.Lgroup_arg: .ascii "NAMARG"
.Lgroup_ct0: .ascii "NAMCT0"
.Lgroup_rip: .ascii "NAMRIP"
.Ltrue_name: .ascii "TRUE"
.Lfalse_name: .ascii "FALSE"
.p2align 3
.Lkeys_arg:
 .word 5,1,44,1,1,0
 .ascii "NCONF"
 .zero 11
 .word 6,2,44,1,1,0
 .ascii "LECMWF"
 .zero 10
 .word 6,3,40,0,0,0
 .ascii "CNMEXP"
 .zero 10
 .zero 40
.Lkeys_ct0:
 .word 6,1,0,1,999999,0
 .ascii "NFRSDI"
 .zero 10
 .word 6,1,4,0,0,0
 .ascii "N3DINI"
 .zero 10
 .word 7,2,8,0,0,0
 .ascii "LREFOUT"
 .zero 9
 .word 6,2,12,0,1,0
 .ascii "LFDBOP"
 .zero 10
 .word 6,1,16,1,999999,0
 .ascii "NFRHIS"
 .zero 10
 .word 6,1,20,1,999999,0
 .ascii "NFRPOS"
 .zero 10
 .word 5,1,24,0,2,0
 .ascii "NFPOS"
 .zero 11
 .word 6,1,28,1,999999,0
 .ascii "NFRDHP"
 .zero 10
 .word 7,1,32,1,999999,0
 .ascii "NFRDHFD"
 .zero 9
 .word 8,1,36,-99999999,-1,0
 .ascii "NUNDEFLD"
 .zero 8
 .word 7,2,60,0,0,0
 .ascii "LSMSSIG"
 .zero 9
 .word 8,2,464,0,0,0
 .ascii "LARPEGEF"
 .zero 8
 .word 10,1,468,1,999999,0
 .ascii "NFRMASSCON"
 .zero 6
 .word 6,1,472,0,0,0
 .ascii "NPOSTS"
 .zero 10
 .word 6,1,476,0,0,0
 .ascii "NHISTS"
 .zero 10
 .word 9,1,480,0,0,0
 .ascii "NMASSCONS"
 .zero 7
 .word 5,1,484,0,999999,0
 .ascii "NFRCO"
 .zero 11
 .word 7,1,488,1,999999,0
 .ascii "NFRDHFZ"
 .zero 9
 .word 7,1,492,0,0,0
 .ascii "NDHFZTS"
 .zero 9
 .word 7,1,496,0,0,0
 .ascii "NDHFDTS"
 .zero 9
 .word 6,6,512,0,0,0
 .ascii "CMETER"
 .zero 10
 .word 6,6,544,0,0,0
 .ascii "CEVENT"
 .zero 10
 .zero 40
.Lkeys_rip:
 .word 5,4,44,0,0,0
 .ascii "TSTEP"
 .zero 11
 .word 5,5,48,0,0,0
 .ascii "CSTOP"
 .zero 11
 .zero 40
.p2align 3
.Lop_additional_defaults: .word 0,999999,0,0,0,0,4,0,0
.p2align 3
.Lcontrol_default_rows:
 .word 34740,2 /* NOPT_MEMORY */
 .word 35104,1 /* NCONF */
 .word 35108,1 /* NTASKS_CANARI */
 .word 35112,1 /* NQUAD */
 .word 35116,1 /* N2DINI */
 .word 35120,0 /* NSPPR */
 .word 35124,-1 /* NFRPOS */
 .word 35128,1 /* NFRHIS */
 .word 35132,0 /* N3DINI */
 .word 35136,1 /* NFRGDI */
 .word 35140,24 /* NFRSDI */
 .word 35144,1 /* NCNTVAR */
 .word 35148,4 /* NFRDHFG */
 .word 35152,4 /* NFRDHFZ */
 .word 35156,4 /* NFRDHFD */
 .word 35160,48 /* NFRDHP */
 .word 35164,0 /* NFRCO */
 .word 35168,999999 /* NFRMASSCON */
 .word 35172,6 /* N6BINS */
 .word 35176,1 /* LNF */
 .word 35180,1 /* LFDBOP */
 .word 35184,0 /* LARPEGEF */
 .word 35188,0 /* LSMSSIG */
 .word 35244,0 /* LARPEGEF_TRAJHR */
 .word 35248,0 /* LARPEGEF_TRAJBG */
 .word 35252,0 /* NFPOS */
 .word 35256,1 /* LOPDIS */
 .word 35260,0 /* LCANARI */
 .word 35264,1 /* LOLDPP */
 .word 35268,0 /* LGUESS */
 .word 35272,0 /* LOBS */
 .word 35276,0 /* LOBSC1 */
 .word 35280,0 /* LOBSREF */
 .word 35284,1 /* LSIMOB */
 .word 35288,0 /* LELAM */
 .word 35292,0 /* LRPLANE */
 .word 35296,0 /* LFBDAP */
 .word 35300,0 /* LBACKG */
 .word 35304,0 /* LMINIM */
 .word 35308,0 /* LSCREEN */
 .word 35312,0 /* LREFOUT */
 .word 35316,0 /* LMONITORING */
 .word 35560,1 /* L_SCREEN_CALL */
 .word 35564,0 /* L_SPLIT_SCREEN */
 .word 35568,0 /* LINFLAT */
 .word 35572,0 /* LINFLP9 */
 .word 35576,0 /* LINFLF1 */
 .word 35580,0 /* LALLOPR */
 .word 35584,0 /* LREFGEN */
 .word 35588,0 /* LIFSTRAJ */
 .word 35592,0 /* LIFSMIN */
 .word 35596,0 /* LAROME */
 .word 35600,0 /* LECFPOS */
 .word 35604,1 /* NINTERPTRAJ */
 .word 35608,1 /* NINTERPINCR */
 .word 35612,1 /* LSCREEN_OPENMP */
 .word 35616,0 /* NFRCORM */
 .word 35620,0 /* LSFORC */
 .word 35624,0 /* LSFORCS */
 .word 35628,0 /* LSPBSBAL */
 .word 39476,1 /* NFRSFXHIS */
 .word 39480,0 /* LARPEGEF_RDGP_INIT */
 .word 39484,0 /* LARPEGEF_RDGP_TRAJHR */
 .word 39488,0 /* LARPEGEF_RDGP_TRAJBG */
 .word 39492,1 /* LCALLSFX */
 .word 39496,0 /* LSFXLSM */
 .word 39500,1 /* LR3D */
 .word 39504,0 /* LR2D */
 .word 39508,0 /* LRSHW */
 .word 39512,0 /* LRVEQ */
 .word 39516,1 /* LIOLEVG */
 .word 39520,1 /* LECMWF */
 .word 39524,0 /* LWRSPECA_GP */
 .word 39528,0 /* LSUSPECA_GP */
 .word 39532,0 /* LWRSPECA_GP_UV */
 .word 39536,0 /* LSUSPECA_GP_UV */
 .word 51072,1 /* LGRIB_API */
 .word 51076,-99999999 /* NUNDEFLD */
 .word 51080,0 /* LCOUPLO4 */
 .word 51084,0 /* L4DVAR */
 .word 51088,0 /* L_OOPS */
 .word 51092,1 /* NITER_ADTEST */
 .word 51096,0 /* LCONSERV */
 .word 51100,0 /* LCORWAT */
 .word 51104,0 /* LTRAJNH */
 .word 51108,0 /* L_OBS_IN_FC_CONFIG */
 .word -1,0
.Lchar_CNMEXP: .ascii "0123            "
.Lchar_CFPNCF: .ascii "ncf927                                                                                                                          "
.Lchar_CNPPATH: .ascii "                                                                                                                        "
.Lchar_CFDIRLST: .ascii "                                                                                                                        "
.Lchar_CNDISPP: .ascii "                                                                                                                        "
.Lchar_CMETER: .ascii "smsmeter                 "
.Lchar_CEVENT: .ascii "smsevent                 "
.Lchar_CSCRIPT_PPSERVER: .ascii "cnt3_wait                                                                                                               "
.Lchar_CSCRIPT_LAMRTC: .ascii "atcp                                                                                                                    "
.section .note.GNU-stack,"",%progbits

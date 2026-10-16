/* Contract: skills/md2asm/references/openifs/radiation/owned_radiation_forcing.md.
 * x0 TERDI176,x1 capacity,x2 seven address/capacity pairs.
 * Inputs: TDYNA456,TERAD2040,TRIP175976,constants520,climate2792,
 * runtime16{NINDAT,NSTAR2,LNF,reserved},optional solar0/8.
 * Complete records and owned table payloads are mapped and read-only.
 * Return0/2. Private class wrappers contain only an owned data address. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_update_owned_radiation_forcing
.type md2asm_update_owned_radiation_forcing,%function
md2asm_update_owned_radiation_forcing:
 cbz x0,.Lrf_bad_leaf
 cbz x2,.Lrf_bad_leaf
 cmp x1,#176
 b.lo .Lrf_bad_leaf
 orr x3,x0,x2
 tst x3,#7
 b.ne .Lrf_bad_leaf
 adds x3,x0,#176
 b.cs .Lrf_bad_leaf
 adds x4,x2,#112
 b.cs .Lrf_bad_leaf
 cmp x0,x4
 b.hs .Lrf_table_clear
 cmp x2,x3
 b.lo .Lrf_bad_leaf
.Lrf_table_clear:
 mrs x4,fpcr
 cbnz x4,.Lrf_bad_leaf
 adr x4,.Lrf_record_sizes
 mov x5,#0
.Lrf_records:
 add x6,x2,x5,lsl#4
 ldp x7,x8,[x6]
 cbz x7,.Lrf_bad_leaf
 tst x7,#7
 b.ne .Lrf_bad_leaf
 ldr x9,[x4,x5,lsl#3]
 cmp x8,x9
 b.lo .Lrf_bad_leaf
 adds x10,x7,x9
 b.cs .Lrf_bad_leaf
 cmp x0,x10
 b.hs .Lrf_record_clear
 cmp x7,x3
 b.lo .Lrf_bad_leaf
.Lrf_record_clear:
 add x5,x5,#1
 cmp x5,#6
 b.lo .Lrf_records
 ldp x7,x8,[x2,#96]
 cbnz x7,.Lrf_optional_present
 cbnz x8,.Lrf_bad_leaf
 b .Lrf_optional_done
.Lrf_optional_present:
 cmp x8,#8
 b.lo .Lrf_bad_leaf
 tst x7,#7
 b.ne .Lrf_bad_leaf
 adds x9,x7,#8
 b.cs .Lrf_bad_leaf
 cmp x0,x9
 b.hs .Lrf_optional_clear
 cmp x7,x3
 b.lo .Lrf_bad_leaf
.Lrf_optional_clear:
 ldr x9,[x7]
 adr x10,.Lrf_infinity
 ldr x10,[x10]
 cbz x9,.Lrf_bad_leaf
 cmp x9,x10
 b.hs .Lrf_bad_leaf
.Lrf_optional_done:
 ldr x7,[x2,#80]
 ldr w8,[x7,#8]
 cmp w8,#1
 b.hi .Lrf_bad_leaf
 ldr x7,[x2]
 ldr w8,[x7,#20]
 cmp w8,#1
 b.hi .Lrf_bad_leaf
 ldr x7,[x2,#64]
 ldr w8,[x7,#128]
 cmp w8,#450
 b.ne .Lrf_bad_leaf
 ldr w8,[x7,#648]
 mov w9,#2501
 cmp w8,w9
 b.ne .Lrf_bad_leaf
 adr x4,.Lrf_table_offsets
 mov x5,#0
.Lrf_lookup_owner:
 ldr w6,[x4,x5,lsl#2]
 add x6,x7,x6
 ldr x8,[x6]
 cbz x8,.Lrf_bad_leaf
 tst x8,#7
 b.ne .Lrf_bad_leaf
 ldr x9,[x6,#8]
 cmn x9,#1
 b.ne .Lrf_bad_leaf
 ldr x9,[x6,#16]
 cmp x9,#8
 b.ne .Lrf_bad_leaf
 ldr x9,[x6,#24]
 mov x10,#0x301
 lsl x10,x10,#32
 cmp x9,x10
 b.ne .Lrf_bad_leaf
 ldr x9,[x6,#32]
 cmp x9,#8
 b.ne .Lrf_bad_leaf
 ldp x9,x10,[x6,#40]
 cmp x9,#1
 b.ne .Lrf_bad_leaf
 cmp x10,#1
 b.ne .Lrf_bad_leaf
 mov x9,#450
 cmp x5,#2
 mov x10,#2501
 csel x9,x9,x10,lo
 ldr x10,[x6,#56]
 cmp x9,x10
 b.ne .Lrf_bad_leaf
 adds x10,x8,x9,lsl#3
 b.cs .Lrf_bad_leaf
 cmp x0,x10
 b.hs .Lrf_lookup_clear
 cmp x8,x3
 b.lo .Lrf_bad_leaf
.Lrf_lookup_clear:
 add x5,x5,#1
 cmp x5,#10
 b.lo .Lrf_lookup_owner
 /* Owned molar masses must be positive finite binary64 values. */
 ldr x7,[x2,#48]
 adr x4,.Lrf_mass_offsets
 adr x5,.Lrf_infinity
 ldr x5,[x5]
 mov x6,#0
.Lrf_mass_check:
 ldr w8,[x4,x6,lsl#2]
 ldr x9,[x7,x8]
 cbz x9,.Lrf_bad_leaf
 cmp x9,x5
 b.hs .Lrf_bad_leaf
 add x6,x6,#1
 cmp x6,#9
 b.lo .Lrf_mass_check
 sub sp,sp,#336
 stp x29,x30,[sp,#16]
 stp x19,x20,[sp,#32]
 stp x21,x22,[sp,#48]
 stp x23,x24,[sp,#64]
 stp x25,x26,[sp,#80]
 str x18,[sp,#96]
 add x29,sp,#16
 mov x19,x0
 mov x20,x2
 ldr x21,[x20,#48]
 ldr x22,[x20,#64]
 ldr x23,[x20,#96]
 ldr x1,[x20,#32]
 add x9,x1,#8,lsl#12
 ldr w9,[x9,#564]
 cmp w9,#0
 b.le .Lrf_current_year
 scvtf d0,w9
 fmov d1,#0.5
 fadd d0,d0,d1
 b .Lrf_year_ready
.Lrf_current_year:
 ldr x0,[x20]
 ldr x2,[x20,#80]
 mov x3,x21
 bl md2asm_owned_radiation_decimal_year
.Lrf_year_ready:
 str d0,[sp,#128]
 /* Reject the source's undefined clamp domain before any output store. */
 ldr x9,[x22,#136]
 ldr d1,[x9]
 ldr d2,[x9,#20000]
 fcmp d0,d1
 b.vs .Lrf_bad_frame
 b.le .Lrf_bad_frame
 fcmp d0,d2
 b.ge .Lrf_bad_frame
 cbnz x23,.Lrf_date_checked
 ldr x9,[x20,#16]
 ldr w9,[x9,#148]
 cbz w9,.Lrf_date_checked
 ldr x9,[x22]
 ldr d1,[x9]
 ldr d2,[x9,#3592]
 fcmp d0,d1
 b.le .Lrf_bad_frame
 fcmp d0,d2
 b.ge .Lrf_bad_frame
.Lrf_date_checked:
 ldr d1,[x21,#160]
 adr x24,.Lrf_ratio_offsets
 mov x25,#0
.Lrf_mass_ratio:
 ldr w9,[x24,x25,lsl#2]
 ldr d0,[x21,x9]
 fdiv d0,d0,d1
 add x9,sp,#192
 str d0,[x9,x25,lsl#3]
 add x25,x25,#1
 cmp x25,#8
 b.lo .Lrf_mass_ratio
 add x9,x22,#136
 stp x9,xzr,[sp,#112]
 add x0,sp,#112
 add x1,sp,#128
 add x2,sp,#136
 add x3,sp,#144
 add x4,sp,#152
 add x5,sp,#160
 add x6,sp,#168
 add x7,sp,#176
 add x9,sp,#184
 str x9,[sp]
 bl md2asm_owned_greenhouse_lookup
 ldr d0,[sp,#136]
 ldr d1,[sp,#192]
 fmul d0,d0,d1
 str d0,[x19,#16]
 ldr d0,[sp,#144]
 ldr d1,[sp,#200]
 fmul d0,d0,d1
 str d0,[x19,#24]
 ldr d0,[sp,#152]
 ldr d1,[sp,#208]
 fmul d0,d0,d1
 str d0,[x19,#32]
 ldr d0,[sp,#160]
 ldr d1,[sp,#224]
 fmul d0,d0,d1
 str d0,[x19,#64]
 ldr d0,[sp,#168]
 ldr d1,[sp,#232]
 fmul d0,d0,d1
 str d0,[x19,#72]
 ldr d0,[sp,#176]
 ldr d1,[sp,#240]
 fmul d0,d0,d1
 str d0,[x19,#80]
 ldr d0,[sp,#184]
 ldr d1,[sp,#248]
 fmul d0,d0,d1
 str d0,[x19,#56]
 adr x9,.Lrf_no2
 ldr d0,[x9]
 ldr d1,[sp,#216]
 fmul d0,d0,d1
 str d0,[x19,#40]
 cbz x23,.Lrf_solar_mode
 ldr d0,[x23]
 str d0,[x19,#168]
 b .Lrf_success
.Lrf_solar_mode:
 ldr x9,[x20,#16]
 ldr w9,[x9,#148]
 cbnz w9,.Lrf_solar_lookup
 ldr d0,[x21,#144]
 str d0,[x19,#168]
 b .Lrf_success
.Lrf_solar_lookup:
 stp x22,xzr,[sp,#112]
 add x0,sp,#112
 add x1,sp,#128
 add x2,x19,#168
 bl md2asm_owned_solar_lookup
.Lrf_success:
 mov w0,#0
 b .Lrf_return
.Lrf_bad_frame:
 mov w0,#2
.Lrf_return:
 ldr x18,[sp,#96]
 ldp x25,x26,[sp,#80]
 ldp x23,x24,[sp,#64]
 ldp x21,x22,[sp,#48]
 ldp x19,x20,[sp,#32]
 ldp x29,x30,[sp,#16]
 add sp,sp,#336
 ret
.Lrf_bad_leaf:
 mov w0,#2
 ret
.size md2asm_update_owned_radiation_forcing,.-md2asm_update_owned_radiation_forcing

/* Same accepted GET_YEAR arithmetic with explicit runtime/constants.
 * x0 TDYNA456,x1 TRIP175976,x2 runtime16,x3 constants520; returns d0.
 * Upstream clock supplies valid date and bounded restart arithmetic. */
.p2align 4
.global md2asm_owned_radiation_decimal_year
.type md2asm_owned_radiation_decimal_year,%function
md2asm_owned_radiation_decimal_year:
 mov x14,x2
 mov x15,x3
 ldr w2,[x1,#16]
 ldr w3,[x14,#8]
 cbnz w3,.Lry_days_ready
 cbnz w2,.Lry_days_ready
 ldr d1,[x1,#200]
 frinta d2,d1
 fcvtzs w2,d2
 ldr w3,[x14,#4]
 ldr w4,[x0,#20]
 cbz w4,.Lry_integer_restart
 scvtf d2,w3
 fmov d3,#0.5
 fadd d2,d2,d3
 fmul d1,d1,d2
 frinta d1,d1
 fcvtzs w2,d1
 b .Lry_seconds_ready
.Lry_integer_restart:
 mul w2,w2,w3
.Lry_seconds_ready:
 ldr d1,[x15,#40]
 frinta d1,d1
 fcvtzs w3,d1
 sdiv w2,w2,w3
.Lry_days_ready:
 ldr w3,[x14]
 mov w4,#100
 sdiv w5,w3,w4
 msub w6,w5,w4,w3
 sdiv w7,w5,w4
 msub w5,w7,w4,w5
 sub w5,w5,#1
 adr x8,.Lrf_month_days
 ldr d1,[x8,w5,uxtw#3]
 scvtf d0,w6
 fmov d2,#1.0
 fsub d0,d0,d2
 fadd d0,d0,d1
 scvtf d1,w2
 fadd d0,d0,d1
 adr x8,.Lrf_year_days
 ldr d1,[x8]
 fdiv d0,d0,d1
 scvtf d1,w7
 fadd d0,d1,d0
 ret
.size md2asm_owned_radiation_decimal_year,.-md2asm_owned_radiation_decimal_year
.section .rodata
.p2align 3
.Lrf_record_sizes: .quad 456,2040,175976,520,2792,16
.Lrf_infinity: .quad 0x7ff0000000000000
.Lrf_no2: .double 5.0e-11
.Lrf_year_days: .double 365.25
.Lrf_month_days: .double 0,31,59.25,90.25,120.25,151.25,181.25,212.25,243.25,273.25,304.25,334.25
.Lrf_table_offsets: .word 0,64,136,200,264,328,392,456,520,584
.Lrf_mass_offsets: .word 160,248,256,264,288,312,320,328,336
.Lrf_ratio_offsets: .word 248,256,264,288,312,320,328,336
.section .note.GNU-stack,"",%progbits

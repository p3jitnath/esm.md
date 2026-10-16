/* Contract: skills/md2asm/references/openifs/radiation/radiation_climate_files.md.
 * x0 text,x1 bytes,x2 output2640,x3 capacity,x4 upstream24:
 * int32 LEPHYS,LARPEGEF,LRAYFM,YO3.LGP,LOPT_SCALAR,reserved.
 * Own source climate-file defaults, selected NAERAD and DATA path resolution.
 * Complete bounded input ranges are mapped; output is disjoint and aligned8.
 * Return0/2, output unchanged on error. Only libc string/process services. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_select_radiation_climate_files
.type md2asm_select_radiation_climate_files,%function
md2asm_select_radiation_climate_files:
 cbz x0,.Lrs_bad_leaf
 cbz x1,.Lrs_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Lrs_bad_leaf
 cbz x2,.Lrs_bad_leaf
 cbz x4,.Lrs_bad_leaf
 cmp x3,#2640
 b.lo .Lrs_bad_leaf
 orr x5,x2,x4
 tst x5,#7
 b.ne .Lrs_bad_leaf
 adds x5,x0,x1
 b.cs .Lrs_bad_leaf
 adds x6,x2,#2640
 b.cs .Lrs_bad_leaf
 adds x7,x4,#24
 b.cs .Lrs_bad_leaf
 cmp x2,x5
 b.hs .Lrs_text_clear
 cmp x0,x6
 b.lo .Lrs_bad_leaf
.Lrs_text_clear:
 cmp x2,x7
 b.hs .Lrs_upstream_clear
 cmp x4,x6
 b.lo .Lrs_bad_leaf
.Lrs_upstream_clear:
 mrs x5,fpcr
 cbnz x5,.Lrs_bad_leaf
 mov x5,#0
.Lrs_logicals:
 ldr w6,[x4,x5]
 cmp w6,#1
 b.hi .Lrs_bad_leaf
 add x5,x5,#4
 cmp x5,#20
 b.lo .Lrs_logicals
 sub sp,sp,#2800
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x2
 mov x20,x0
 mov x21,x1
 mov x22,x4
 add x23,sp,#128
 mov x0,x23
 mov w1,#0
 mov x2,#2640
 bl memset
 add x0,x23,#48
 mov w1,#32
 mov x2,#1024
 bl memset
 ldr w9,[x22]
 ldr w10,[x22,#4]
 eor w10,w10,#1
 and w9,w9,w10
 str w9,[x23,#8]
 mov w10,#4
 mul w10,w9,w10
 str w10,[x23]
 mov w10,#6
 mul w10,w9,w10
 str w10,[x23,#12]
 mov w9,#-1
 str w9,[x23,#4]
 mov w9,#3
 str w9,[x23,#16]
 mov w9,#1
 str w9,[x23,#20]
 str w9,[x23,#28]
 ldr w9,[x22,#12]
 str w9,[x23,#32]
 ldr w9,[x22,#16]
 mov w10,#-8
 mov w11,#511
 cmp w9,#0
 csel w9,w10,w11,ne
 str w9,[sp,#112]
 str w9,[x23,#24]
 mov w9,#46
 strb w9,[x23,#816]
 mov w9,#47
 strb w9,[x23,#817]
 mov x0,x20
 mov x1,x21
 mov x2,x23
 bl md2asm_apply_selected_radiation_namelist
 cbnz w0,.Lrs_bad_frame
 ldr w9,[x23,#4]
 cmp w9,#0
 b.ge .Lrs_greenhouse_ready
 ldr w9,[x22]
 ldr w10,[x22,#4]
 eor w10,w10,#1
 and w9,w9,w10
 ldr w10,[x22,#8]
 orr w9,w9,w10
 cbz w9,.Lrs_no_greenhouse
 ldr w9,[x23,#32]
 mov w10,#20
 mov w11,#21
 cmp w9,#0
 csel w9,w10,w11,ne
 b .Lrs_store_greenhouse
.Lrs_no_greenhouse:
 mov w9,#0
.Lrs_store_greenhouse:
 str w9,[x23,#4]
.Lrs_greenhouse_ready:
 ldr w9,[x23,#24]
 cbnz w9,.Lrs_restore_nrproma_done
 ldr w9,[sp,#112]
.Lrs_restore_nrproma_done:
 neg w10,w9
 cmp w9,#0
 csel w9,w10,w9,lt
 str w9,[x23,#24]
 /* Source file defaults apply only to all-blank 256-byte fields. */
 add x0,x23,#48
 bl .Lrs_blank_field
 cbz w0,.Lrs_solar_name_ready
 add x0,x23,#48
 adr x1,.Lrs_solar_name
 mov x2,#(.Lrs_solar_end-.Lrs_solar_name)
 bl memcpy
.Lrs_solar_name_ready:
 add x0,x23,#304
 bl .Lrs_blank_field
 cbz w0,.Lrs_climate_name_ready
 add x0,x23,#304
 adr x1,.Lrs_climate_name
 mov x2,#(.Lrs_climate_end-.Lrs_climate_name)
 bl memcpy
.Lrs_climate_name_ready:
 add x0,x23,#560
 bl .Lrs_blank_field
 cbz w0,.Lrs_series_name_ready
 ldr w9,[x23,#12]
 cbz w9,.Lrs_cmip3
 cmp w9,#5
 b.eq .Lrs_cmip5
 cmp w9,#6
 b.ne .Lrs_bad_frame
 mov w11,#7
 b .Lrs_rcp_index
.Lrs_cmip5:
 mov w11,#3
.Lrs_rcp_index:
 ldr w10,[x23,#16]
 sub w10,w10,#1
 cmp w10,#3
 b.hi .Lrs_bad_frame
 add w10,w10,w11
 b .Lrs_series_index_ready
.Lrs_cmip3:
 ldr w10,[x23,#20]
 sub w10,w10,#1
 cmp w10,#2
 b.hi .Lrs_bad_frame
.Lrs_series_index_ready:
 adr x9,.Lrs_series_offsets
 ldr w10,[x9,x10,lsl#2]
 adr x1,.Lrs_series_names
 add x1,x1,x10
 mov x0,x1
 bl strlen
 mov x2,x0
 /* Source pointer is recovered from the selected relative table. */
 ldr w9,[x23,#12]
 cbz w9,.Lrs_copy_cmip3
 mov w10,#3
 cmp w9,#5
 mov w11,#7
 csel w10,w10,w11,eq
 ldr w9,[x23,#16]
 add w10,w10,w9
 sub w10,w10,#1
 b .Lrs_copy_series
.Lrs_copy_cmip3:
 ldr w10,[x23,#20]
 sub w10,w10,#1
.Lrs_copy_series:
 adr x9,.Lrs_series_offsets
 ldr w10,[x9,x10,lsl#2]
 adr x1,.Lrs_series_names
 add x1,x1,x10
 add x0,x23,#560
 bl memcpy
.Lrs_series_name_ready:
 adr x0,.Lrs_data_environment
 bl getenv
 mov x24,x0
 mov x25,#0
 cbz x24,.Lrs_data_ready
 mov x1,#513
 bl strnlen
 cmp x0,#512
 b.hi .Lrs_bad_frame
 mov x25,x0
.Lrs_data_trim:
 cbz x25,.Lrs_data_ready
 sub x9,x25,#1
 ldrb w10,[x24,x9]
 cmp w10,#32
 b.ne .Lrs_data_ready
 sub x25,x25,#1
 b .Lrs_data_trim
.Lrs_data_ready:
 mov x26,#0
.Lrs_resolve_path:
 add x9,x23,#48
 add x9,x9,x26,lsl#8
 mov x27,#256
.Lrs_name_trim:
 sub x10,x27,#1
 ldrb w11,[x9,x10]
 cmp w11,#32
 b.ne .Lrs_name_length_ready
 subs x27,x27,#1
 b.ne .Lrs_name_trim
 b .Lrs_bad_frame
.Lrs_name_length_ready:
 add x28,x23,#1072
 add x28,x28,x26,lsl#9
 ldrb w10,[x9]
 cmp w10,#46
 b.eq .Lrs_direct_path
 cmp w10,#47
 b.eq .Lrs_direct_path
 cbz x25,.Lrs_direct_path
 add x10,x25,#9
 add x10,x10,x27
 cmp x10,#511
 b.hi .Lrs_bad_frame
 str x10,[sp,#120]
 mov x0,x28
 mov x1,x24
 mov x2,x25
 bl memcpy
 add x0,x28,x25
 adr x1,.Lrs_ifsdata
 mov x2,#9
 bl memcpy
 add x0,x28,x25
 add x0,x0,#9
 b .Lrs_copy_name_path
.Lrs_direct_path:
 str x27,[sp,#120]
 mov x0,x28
.Lrs_copy_name_path:
 add x1,x23,#48
 add x1,x1,x26,lsl#8
 mov x2,x27
 bl memcpy
 add x9,x23,#2608
 ldr x10,[sp,#120]
 str x10,[x9,x26,lsl#3]
 add x26,x26,#1
 cmp x26,#3
 b.lo .Lrs_resolve_path
 mov x0,x19
 mov x1,x23
 mov x2,#2640
 bl memcpy
 mov w0,#0
 b .Lrs_return
.Lrs_bad_frame:
 mov w0,#2
.Lrs_return:
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#2800
 ret
.Lrs_bad_leaf:
 mov w0,#2
 ret
.size md2asm_select_radiation_climate_files,.-md2asm_select_radiation_climate_files
/* Return1 for an all-space 256-byte Fortran field. */
.Lrs_blank_field:
 mov x9,#0
.Lrs_blank_byte:
 ldrb w10,[x0,x9]
 cmp w10,#32
 b.ne .Lrs_field_nonblank
 add x9,x9,#1
 cmp x9,#256
 b.lo .Lrs_blank_byte
 mov w0,#1
 ret
.Lrs_field_nonblank:
 mov w0,#0
 ret
.section .rodata
.Lrs_data_environment: .asciz "DATA"
.Lrs_ifsdata: .ascii "/ifsdata/"
.Lrs_solar_name: .ascii "total_solar_irradiance_CMIP6_47r1.nc"
.Lrs_solar_end:
.Lrs_climate_name: .ascii "greenhouse_gas_climatology_48r1.nc"
.Lrs_climate_end:
.p2align 2
.Lrs_series_offsets:
 .word .Lrs_cmip3_1-.Lrs_series_names,.Lrs_cmip3_2-.Lrs_series_names,.Lrs_cmip3_3-.Lrs_series_names
 .word .Lrs_cmip5_1-.Lrs_series_names,.Lrs_cmip5_2-.Lrs_series_names,.Lrs_cmip5_3-.Lrs_series_names,.Lrs_cmip5_4-.Lrs_series_names
 .word .Lrs_cmip6_1-.Lrs_series_names,.Lrs_cmip6_2-.Lrs_series_names,.Lrs_cmip6_3-.Lrs_series_names,.Lrs_cmip6_4-.Lrs_series_names
.Lrs_series_names:
.Lrs_cmip3_1: .asciz "greenhouse_gas_timeseries_CMIP3_A1B_46r1.nc"
.Lrs_cmip3_2: .asciz "greenhouse_gas_timeseries_CMIP3_A2_46r1.nc"
.Lrs_cmip3_3: .asciz "greenhouse_gas_timeseries_CMIP3_B1_46r1.nc"
.Lrs_cmip5_1: .asciz "greenhouse_gas_timeseries_CMIP5_RCP3PD_46r1.nc"
.Lrs_cmip5_2: .asciz "greenhouse_gas_timeseries_CMIP5_RCP45_46r1.nc"
.Lrs_cmip5_3: .asciz "greenhouse_gas_timeseries_CMIP5_RCP6_46r1.nc"
.Lrs_cmip5_4: .asciz "greenhouse_gas_timeseries_CMIP5_RCP85_46r1.nc"
.Lrs_cmip6_1: .asciz "greenhouse_gas_timeseries_CMIP6_SSP126_CFC11equiv_47r1.nc"
.Lrs_cmip6_2: .asciz "greenhouse_gas_timeseries_CMIP6_SSP245_CFC11equiv_47r1.nc"
.Lrs_cmip6_3: .asciz "greenhouse_gas_timeseries_CMIP6_SSP370_CFC11equiv_47r1.nc"
.Lrs_cmip6_4: .asciz "greenhouse_gas_timeseries_CMIP6_SSP585_CFC11equiv_47r1.nc"
.section .note.GNU-stack,"",%progbits

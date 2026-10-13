/* Direct field preparation and complete outer radiation calculation.
 * Physics is formulations/openifs/radiation/radiation_field_preparation.md.
 * The frozen contract is skills/md2asm/references/openifs/radiation/radiation_field_preparation.md.
 * All 59 addresses, complete caller bounds and original rounding points apply.
 * This body owns storage and calls eight complete accepted assembly stages. */
#include "radiation_field_layout.inc.S"
#ifndef OUTER_SYMBOL
#define OUTER_SYMBOL radiation_scheme_
#endif
.text
.p2align 2
.macro outer_immediate reg,value
 movz \reg,#((\value)&65535)
 .if ((\value)>>16)
 movk \reg,#(((\value)>>16)&65535),lsl #16
 .endif
.endm
.macro outer_pointer reg,value
 outer_immediate \reg,\value
 add \reg,x21,\reg
.endm
.macro outer_model reg,value
 outer_immediate \reg,\value
 add \reg,x19,\reg
.endm
.macro outer_argument reg,index
 ldr \reg,[x20,#8*(\index)]
.endm
.macro outer_call name
 bl \name
 ldr x18,[x29,#392]
.endm
.macro outer_completed index
 adrp x8,.Louter_counts
 add x8,x8,:lo12:.Louter_counts
 ldr x9,[x8,#8*(\index)]
 add x9,x9,#1
 str x9,[x8,#8*(\index)]
.endm
.macro outer_observe stage
 adrp x16,:got:md2asm_outer_observe_stage
 ldr x16,[x16,:got_lo12:md2asm_outer_observe_stage]
 cbz x16,.Louter_no_observer_\@
 mov w0,#\stage
 mov x1,x20
 add x2,x29,#1536
 blr x16
 ldr x18,[x29,#392]
.Louter_no_observer_\@:
.endm
.weak md2asm_outer_observe_stage
.global OUTER_SYMBOL
.global md2asm_radiation_field_preparation
.type md2asm_radiation_field_preparation,%function
OUTER_SYMBOL:
md2asm_radiation_field_preparation:
 mov x17,sp
 sub sp,sp,#1,lsl #12
 stp x19,x20,[sp,#192]
 stp x21,x22,[sp,#208]
 stp x23,x24,[sp,#224]
 stp x25,x26,[sp,#240]
 stp x27,x28,[sp,#256]
 stp x29,x30,[sp,#272]
 stp d8,d9,[sp,#320]
 stp d10,d11,[sp,#336]
 stp d12,d13,[sp,#352]
 stp d14,d15,[sp,#368]
 str x18,[sp,#392]
 mov x29,sp
 add x20,x29,#512
 stp x0,x1,[x20]
 stp x2,x3,[x20,#16]
 stp x4,x5,[x20,#32]
 stp x6,x7,[x20,#48]
 mov x8,#0
.Louter_stack_arguments:
 ldr x9,[x17,x8,lsl #3]
 add x10,x20,#64
 str x9,[x10,x8,lsl #3]
 add x8,x8,#1
 cmp x8,#51
 b.ne .Louter_stack_arguments
 mov x19,x0
 mrs x8,fpcr
 cbnz x8,.Louter_reject
 adrp x8,:got:__yomhook_MOD_lhook
 ldr x8,[x8,:got_lo12:__yomhook_MOD_lhook]
 ldr w8,[x8]
 cmp w8,#1
 b.hi .Louter_reject
 str w8,[x29,#1952]
 mov x8,#0
.Louter_addresses:
 ldr x9,[x20,x8,lsl #3]
 cbz x9,.Louter_reject
 cmp x8,#6
 b.lo .Louter_scalar_address
 tst x9,#7
 b.ne .Louter_reject
 b .Louter_address_next
.Louter_scalar_address:
 tst x9,#3
 b.ne .Louter_reject
.Louter_address_next:
 add x8,x8,#1
 cmp x8,#59
 b.ne .Louter_addresses
 outer_argument x8,1
 ldr w8,[x8]
 cmp w8,#1
 b.ne .Louter_reject
 outer_argument x8,2
 ldr w23,[x8]
 cmp w23,#1
 b.lt .Louter_reject
 cmp w23,#8
 b.gt .Louter_reject
 outer_argument x8,3
 ldr w8,[x8]
 cmp w8,#8
 b.ne .Louter_reject
 outer_argument x8,4
 ldr w8,[x8]
 cmp w8,#19
 b.ne .Louter_reject
 outer_argument x8,5
 ldr w8,[x8]
 cmp w8,#12
 b.ne .Louter_reject
 adrp x26,.Louter_integer_controls
 add x26,x26,:lo12:.Louter_integer_controls
.Louter_integer_guard:
 ldp w8,w9,[x26],#8
 cmp w8,#-1
 b.eq .Louter_real_guard_start
 ldr w10,[x19,x8]
 cmp w10,w9
 b.ne .Louter_reject
 b .Louter_integer_guard
.Louter_real_guard_start:
 adrp x26,.Louter_real_controls
 add x26,x26,:lo12:.Louter_real_controls
.Louter_real_guard:
 ldp x8,x9,[x26],#16
 cmp x8,#-1
 b.eq .Louter_time_guard
 ldr x10,[x19,x8]
 cmp x10,x9
 b.ne .Louter_reject
 b .Louter_real_guard
.Louter_time_guard:
 adrp x8,:got:__yomrip0_MOD_nindat
 ldr x8,[x8,:got_lo12:__yomrip0_MOD_nindat]
 ldr w8,[x8]
 outer_immediate w9,20041015
 cmp w8,w9
 b.ne .Louter_reject
 adrp x8,:got:__yomct3_MOD_nstep
 ldr x8,[x8,:got_lo12:__yomct3_MOD_nstep]
 ldr w8,[x8]
 cmp w8,#24
 b.hi .Louter_reject
 str w8,[x29,#1144]
/* Returned arrays have complete declared extents and no active overlap. */
 adrp x26,.Louter_argument_bytes
 add x26,x26,:lo12:.Louter_argument_bytes
 mov x25,#38
.Louter_output_guard:
 ldr x8,[x20,x25,lsl #3]
 ldr x9,[x26,x25,lsl #3]
 adds x10,x8,x9
 b.cs .Louter_reject
 mov x27,#0
.Louter_other_owner:
 cmp x27,x25
 b.eq .Louter_other_next
 ldr x11,[x20,x27,lsl #3]
 ldr x12,[x26,x27,lsl #3]
 cbz x12,.Louter_other_next
 adds x13,x11,x12
 b.cs .Louter_reject
 cmp x8,x13
 b.hs .Louter_other_next
 cmp x11,x10
 b.lo .Louter_reject
.Louter_other_next:
 add x27,x27,#1
 cmp x27,#59
 b.ne .Louter_other_owner
 add x25,x25,#1
 cmp x25,#57
 b.ne .Louter_output_guard
/* Longitude and sine latitude bound the defined geographic seed conversion. */
 outer_argument x26,14
 outer_argument x27,15
 mov x25,#0
.Louter_geometry_guard:
 ldr d0,[x26,x25,lsl #3]
 ldr d1,[x27,x25,lsl #3]
 fmov x8,d0
 and x8,x8,#0x7fffffffffffffff
 outer_immediate x9,0
 mov x9,#0x7ff0000000000000
 cmp x8,x9
 b.hs .Louter_reject
 fmov x8,d1
 and x8,x8,#0x7fffffffffffffff
 mov x9,#0x3ff0000000000000
 cmp x8,x9
 b.hi .Louter_reject
 adrp x8,.Louter_constants
 add x8,x8,:lo12:.Louter_constants
 ldr d2,[x8,#56]
 fabs d0,d0
 fcmp d0,d2
 b.gt .Louter_reject
 add x25,x25,#1
 cmp x25,x23
 b.ne .Louter_geometry_guard
/* Reuse the source diagnostic hook, with its actual control unchanged. */
 ldr w8,[x29,#1952]
 cbz w8,.Louter_hook_entry_done
 adr x0,.Louter_hook_name
 add x1,x29,#1944
 str wzr,[x1]
 add x2,x29,#1936
 mov x3,#16
 outer_call __yomhook_MOD_dr_hook_default8
.Louter_hook_entry_done:
/* One bounded private allocation owns all records and arrays. */
 outer_immediate x0,OUTER_HEAP_BYTES
 outer_call malloc
 cbz x0,.Louter_reject
 mov x21,x0
 mov x1,#0
 outer_immediate x2,OUTER_HEAP_BYTES
 outer_call memset
 outer_pointer x24,OUTER_C
 mov x0,x24
 outer_model x1,4100096
 outer_immediate x2,20040
 outer_call memcpy
 outer_pointer x0,OUTER_S
 adrp x1,.Louter_record_template
 add x1,x1,:lo12:.Louter_record_template
 outer_immediate x2,OUTER_F+3360-OUTER_S
 outer_call memcpy
 adrp x26,.Louter_pointer_table
 add x26,x26,:lo12:.Louter_pointer_table
.Louter_record_pointers:
 ldp x8,x9,[x26],#16
 cmp x8,#-1
 b.eq .Louter_private_boxes
 add x8,x21,x8
 add x9,x21,x9
 str x9,[x8]
 b .Louter_record_pointers
.Louter_private_boxes:
 outer_pointer x8,OUTER_S
 add x17,x29,#1200
 stp x8,xzr,[x17]
 outer_pointer x8,OUTER_T
 add x17,x29,#1216
 stp x8,xzr,[x17]
 outer_pointer x8,OUTER_G
 add x17,x29,#1232
 stp x8,xzr,[x17]
 outer_pointer x8,OUTER_L
 add x17,x29,#1248
 stp x8,xzr,[x17]
 outer_pointer x8,OUTER_A
 add x17,x29,#1264
 stp x8,xzr,[x17]
 outer_pointer x8,OUTER_F
 add x17,x29,#1280
 stp x8,xzr,[x17]
 outer_argument x8,3
 outer_argument x9,4
 add x17,x29,#1536
 stp x8,x9,[x17]
 outer_argument x8,1
 outer_argument x9,2
 add x17,x29,#1552
 stp x8,x9,[x17]
 outer_pointer x8,OUTER_S
 add x17,x29,#1568
 stp x24,x8,[x17]
 outer_pointer x8,OUTER_T
 outer_pointer x9,OUTER_G
 add x17,x29,#1584
 stp x8,x9,[x17]
 outer_pointer x8,OUTER_L
 outer_pointer x9,OUTER_A
 add x17,x29,#1600
 stp x8,x9,[x17]
 outer_pointer x8,OUTER_F
 str x8,[x29,#1616]
/* Copy the two half-level profiles and prepare the bottom temperature. */
 outer_pointer x0,OUTER_T_pressure_hl
 outer_argument x1,19
 mov w2,#20
 mov w3,w23
 bl .Louter_copy_active
 outer_pointer x0,OUTER_T_temperature_hl
 outer_argument x1,20
 mov w2,#20
 mov w3,w23
 bl .Louter_copy_active
 outer_pointer x26,OUTER_T_temperature_hl
 outer_argument x27,20
 outer_argument x28,18
 mov x25,#0
 fmov d2,#0.5
.Louter_bottom_temperature:
 add x8,x25,#152
 ldr d0,[x27,x8,lsl #3]
 sub x9,x8,#8
 ldr d1,[x27,x9,lsl #3]
 fsub d0,d0,d1
 fmul d0,d2,d0
 sub x9,x8,#8
 ldr d1,[x28,x9,lsl #3]
 fadd d0,d1,d0
 str d0,[x26,x8,lsl #3]
 add x25,x25,#1
 cmp x25,x23
 b.ne .Louter_bottom_temperature
/* Saturation is the first complete numerical child. */
 outer_argument x0,1
 outer_argument x1,2
 outer_argument x2,3
 adrp x3,.Louter_integer_one
 add x3,x3,:lo12:.Louter_integer_one
 outer_argument x4,4
 outer_model x5,1588300
 outer_argument x6,17
 outer_argument x7,18
 outer_pointer x8,OUTER_T_h2o_sat_liq
 adrp x9,.Louter_integer_two
 add x9,x9,:lo12:.Louter_integer_two
 stp x8,x9,[x29]
 outer_call md2asm_outer_satur
 outer_completed 0
/* Surface fields retain their column-major array order. */
 outer_argument x8,6
 ldr x9,[x8]
 outer_pointer x8,OUTER_S+480
 str x9,[x8]
 outer_pointer x0,OUTER_S_cos_sza
 outer_argument x1,7
 mov w2,#1
 mov w3,w23
 bl .Louter_copy_active
 outer_pointer x0,OUTER_S_skin_temperature
 outer_argument x1,8
 mov w2,#1
 mov w3,w23
 bl .Louter_copy_active
 outer_pointer x0,OUTER_S_sw_albedo
 outer_argument x1,9
 mov w2,#6
 mov w3,w23
 bl .Louter_copy_active
 outer_pointer x0,OUTER_S_sw_albedo_direct
 outer_argument x1,10
 mov w2,#6
 mov w3,w23
 bl .Louter_copy_active
 outer_pointer x0,OUTER_S_lw_emissivity
 outer_argument x1,11
 mov w2,#2
 mov w3,w23
 bl .Louter_copy_active
/* NINT uses nearest integer with half ties away from zero. */
 ldr w8,[x29,#1144]
 scvtf d0,w8
 outer_model x8,1359528
 ldr d1,[x8]
 fmul d0,d0,d1
 adrp x8,.Louter_constants
 add x8,x8,:lo12:.Louter_constants
 ldr d1,[x8,#24]
 fdiv d0,d0,d1
 fcvtas w8,d0
 add w8,w8,#15
 str w8,[x29,#1176]
 outer_argument x26,14
 outer_argument x27,15
 outer_pointer x28,OUTER_S_iseed
 mov x25,#0
.Louter_seed:
 ldr d0,[x27,x25,lsl #3]
 outer_call md2asm_asin_original_rounding
 adrp x8,.Louter_constants
 add x8,x8,:lo12:.Louter_constants
 ldr d1,[x8,#40]
 fmul d0,d0,d1
 ldr d1,[x26,x25,lsl #3]
 ldr d2,[x8,#32]
 fmul d1,d1,d2
 fadd d0,d1,d0
 fcvtas w8,d0
 ldr w9,[x29,#1176]
 add w8,w8,w9
 str w8,[x28,x25,lsl #2]
 add x25,x25,#1
 cmp x25,x23
 b.ne .Louter_seed
/* Ice mass includes snow before optical preparation. */
 outer_pointer x0,OUTER_L_q_liq
 outer_argument x1,32
 mov w2,#19
 mov w3,w23
 bl .Louter_copy_active
 outer_pointer x0,OUTER_L_fraction
 outer_argument x1,31
 mov w2,#19
 mov w3,w23
 bl .Louter_copy_active
 outer_pointer x0,OUTER_L_q_ice
 outer_argument x1,33
 outer_argument x2,35
 mov w3,w23
 bl .Louter_sum_cloud_ice
/* Liquid radius uses the exact eighteen-address child interface. */
 outer_model x0,1608728
 outer_model x1,1578600
 outer_model x2,1552928
 outer_model x3,192
 outer_argument x4,1
 outer_argument x5,2
 outer_argument x6,3
 outer_argument x7,4
 outer_argument x8,17
 outer_argument x9,18
 stp x8,x9,[x29]
 outer_argument x8,31
 outer_argument x9,32
 stp x8,x9,[x29,#16]
 outer_argument x8,34
 outer_argument x9,16
 stp x8,x9,[x29,#32]
 outer_argument x8,12
 outer_argument x9,13
 stp x8,x9,[x29,#48]
 outer_pointer x8,OUTER_radius_liquid
 outer_argument x9,57
 stp x8,x9,[x29,#64]
 outer_call md2asm_outer_liquid_radius
 outer_completed 1
 outer_pointer x0,OUTER_L_re_liq
 outer_pointer x1,OUTER_radius_liquid
 mov w2,#19
 mov w3,w23
 adrp x8,.Louter_constants
 ldr d0,[x8,:lo12:.Louter_constants]
 bl .Louter_scale_active
 outer_model x0,1608728
 outer_model x1,1552928
 outer_argument x2,1
 outer_argument x3,2
 outer_argument x4,3
 outer_argument x5,4
 outer_argument x6,17
 outer_argument x7,18
 outer_argument x8,31
 outer_argument x9,33
 stp x8,x9,[x29]
 outer_argument x8,35
 outer_argument x9,15
 stp x8,x9,[x29,#16]
 outer_pointer x8,OUTER_radius_ice
 outer_argument x9,57
 stp x8,x9,[x29,#32]
 outer_call md2asm_outer_ice_radius
 outer_completed 2
 outer_pointer x0,OUTER_L_re_ice
 outer_pointer x1,OUTER_radius_ice
 mov w2,#19
 mov w3,w23
 adrp x8,.Louter_constants
 ldr d0,[x8,:lo12:.Louter_constants]
 bl .Louter_scale_active
/* Decorrelating clouds use kilometres in the child and metres in overlap. */
 outer_model x0,1578336
 outer_argument x1,1
 outer_argument x2,2
 outer_argument x3,3
 outer_argument x4,15
 outer_model x5,1608888
 outer_pointer x6,OUTER_decorrelation_length
 mov x7,xzr
 add x8,x29,#1160
 str x8,[x29]
 outer_call md2asm_outer_decorrelation
 outer_completed 3
 ldr x8,[x29,#1160]
 str x8,[x24,#552]
 mov x25,#0
 outer_pointer x26,OUTER_decorrelation_length
.Louter_overlap:
 add w8,w25,#1
 str w8,[x29,#1152]
 ldr d0,[x26,x25,lsl #3]
 adrp x8,.Louter_constants
 add x8,x8,:lo12:.Louter_constants
 ldr d1,[x8,#80]
 fmul d0,d0,d1
 str d0,[x29,#1168]
 add x0,x29,#1248
 outer_pointer x1,OUTER_T
 add x2,x29,#1168
 add x3,x29,#1152
 mov x4,x3
 outer_call md2asm_outer_overlap
 outer_completed 4
 add x25,x25,#1
 cmp x25,x23
 b.ne .Louter_overlap
 outer_model x8,1609088
 ldr x8,[x8]
 outer_pointer x9,OUTER_L_fractional_std
 mov x10,#152
.Louter_fractional_std:
 str x8,[x9],#8
 subs x10,x10,#1
 b.ne .Louter_fractional_std
/* Layer-mass output has the original compact active-column pitch. */
 add x0,x29,#1728
 adrp x1,.Louter_mass_descriptor_template
 add x1,x1,:lo12:.Louter_mass_descriptor_template
 mov x2,#88
 outer_call memcpy
 outer_pointer x8,OUTER_layer_mass
 str x8,[x29,#1728]
 add x8,x23,#1
 neg x8,x8
 str x8,[x29,#1736]
 str x23,[x29,#1784]
 str x23,[x29,#1792]
 add x0,x29,#1216
 outer_argument x1,1
 outer_argument x2,2
 add x3,x29,#1728
 outer_call md2asm_outer_layer_mass
 outer_completed 5
/* Clamp MACC mass inputs to positive zero, then add the two backgrounds. */
 outer_pointer x26,OUTER_A_mixing_ratio
 outer_argument x27,37
 mov x28,#0
 fmov d2,xzr
.Louter_aerosol_plane:
 mov x25,#0
.Louter_aerosol_level:
 mov x10,#0
.Louter_aerosol_column:
 mov x8,#152
 mul x8,x28,x8
 add x8,x8,x25,lsl #3
 add x8,x8,x10
 ldr d0,[x27,x8,lsl #3]
 fcmp d0,#0.0
 fcsel d0,d0,d2,gt
 str d0,[x26,x8,lsl #3]
 add x10,x10,#1
 cmp x10,x23
 b.ne .Louter_aerosol_column
 add x25,x25,#1
 cmp x25,#19
 b.ne .Louter_aerosol_level
 add x28,x28,#1
 cmp x28,#12
 b.ne .Louter_aerosol_plane
 outer_argument x27,36
 outer_pointer x28,OUTER_layer_mass
 mov x25,#0
.Louter_background_level:
 mov x10,#0
.Louter_background_column:
 mul x8,x25,x23
 add x8,x8,x10
 ldr d0,[x28,x8,lsl #3]
 outer_model x8,4122552
 ldr d1,[x8]
 fmul d1,d0,d1
 mov x8,#48
 mul x8,x25,x8
 add x8,x8,x10
 ldr d2,[x27,x8,lsl #3]
 fdiv d2,d2,d1
 add x9,x10,x25,lsl #3
 add x8,x9,#1064
 ldr d1,[x26,x8,lsl #3]
 fadd d1,d1,d2
 str d1,[x26,x8,lsl #3]
 outer_model x8,4122560
 ldr d1,[x8]
 fmul d1,d0,d1
 mov x8,#48
 mul x8,x25,x8
 add x8,x8,x10
 add x8,x8,#40
 ldr d2,[x27,x8,lsl #3]
 fdiv d2,d2,d1
 add x8,x9,#1672
 ldr d1,[x26,x8,lsl #3]
 fadd d1,d1,d2
 str d1,[x26,x8,lsl #3]
 add x10,x10,#1
 cmp x10,x23
 b.ne .Louter_background_column
 add x25,x25,#1
 cmp x25,#19
 b.ne .Louter_background_level
/* Pressure-weighted ozone becomes a mass mixing ratio. */
 outer_pointer x26,OUTER_ozone
 outer_argument x27,30
 outer_argument x28,19
 mov x25,#0
.Louter_ozone_level:
 mov x10,#0
.Louter_ozone_column:
 add x8,x10,x25,lsl #3
 add x9,x8,#8
 ldr d0,[x28,x9,lsl #3]
 ldr d1,[x28,x8,lsl #3]
 fsub d0,d0,d1
 ldr d1,[x27,x8,lsl #3]
 fdiv d0,d1,d0
 str d0,[x26,x8,lsl #3]
 add x10,x10,#1
 cmp x10,x23
 b.ne .Louter_ozone_column
 add x25,x25,#1
 cmp x25,#19
 b.ne .Louter_ozone_level
/* Insert all supplied gas planes in the source's declared order. */
 adrp x26,.Louter_gas_table
 add x26,x26,:lo12:.Louter_gas_table
 mov x25,#0
 outer_pointer x28,OUTER_G
.Louter_gas_insert:
 ldp w8,w9,[x26],#8
 str w8,[x29,#1136]
 str w9,[x29,#1140]
 add x0,x8,#0
 mov x10,#1216
 mul x0,x0,x10
 outer_pointer x10,OUTER_G_mixing_ratio
 add x0,x10,x0
 cmp w9,#-1
 b.eq .Louter_gas_ozone
 cmp w9,#-2
 b.eq .Louter_gas_oxygen
 ldr x1,[x20,x9,lsl #3]
 b .Louter_gas_copy
.Louter_gas_ozone:
 outer_pointer x1,OUTER_ozone
.Louter_gas_copy:
 mov x2,#1216
 outer_call memcpy
 b .Louter_gas_attributes
.Louter_gas_oxygen:
 adrp x10,.Louter_constants
 add x10,x10,:lo12:.Louter_constants
 ldr x10,[x10,#48]
 mov x11,#152
.Louter_oxygen_values:
 str x10,[x0],#8
 subs x11,x11,#1
 b.ne .Louter_oxygen_values
.Louter_gas_attributes:
 ldr w8,[x29,#1136]
 add x9,x28,#256
 mov w10,#1
 str w10,[x9,x8,lsl #2]
 add x9,x28,#48
 fmov d0,#1.0
 str d0,[x9,x8,lsl #3]
 add w9,w8,#1
 add x10,x28,#364
 str w9,[x10,x25,lsl #2]
 ldr w9,[x29,#1140]
 cmp w9,#-2
 b.ne .Louter_gas_next
 mov w9,#1
 str w9,[x28,x8,lsl #2]
 add x10,x28,#304
 str w9,[x10,x8,lsl #2]
.Louter_gas_next:
 add x25,x25,#1
 cmp x25,#10
 b.ne .Louter_gas_insert
 str w25,[x28,#352]
 add x0,x29,#1232
 adrp x1,.Louter_integer_zero
 add x1,x1,:lo12:.Louter_integer_zero
 mov x2,#0
 mov x3,#0
 outer_call md2asm_outer_gas_set
 outer_completed 6
/* Source-created cloud-cover sentinels are part of the private flux state. */
 outer_pointer x8,OUTER_F_cloud_cover_lw
 outer_pointer x9,OUTER_F_cloud_cover_sw
 mov x10,#8
 fmov d0,#-1.0
.Louter_cloud_cover_initial:
 str d0,[x8],#8
 str d0,[x9],#8
 subs x10,x10,#1
 b.ne .Louter_cloud_cover_initial
 outer_observe 0
 mov w25,#0
.Louter_inner_counts_before:
 mov w0,w25
 outer_call md2asm_outer_inner_child_count_get
 add x8,x29,#1856
 str x0,[x8,x25,lsl #3]
 add w25,w25,#1
 cmp w25,#8
 b.ne .Louter_inner_counts_before
 add x17,x29,#1536
 ldp x0,x1,[x17]
 add x17,x29,#1552
 ldp x2,x3,[x17]
 add x17,x29,#1568
 ldp x4,x5,[x17]
 add x17,x29,#1584
 ldp x6,x7,[x17]
 add x17,x29,#1600
 ldp x8,x9,[x17]
 stp x8,x9,[x29]
 ldr x8,[x29,#1616]
 str x8,[x29,#16]
 outer_call md2asm_outer_inner_radiation
 outer_completed 7
 mov w25,#0
.Louter_inner_counts_after:
 mov w0,w25
 outer_call md2asm_outer_inner_child_count_get
 add x8,x29,#1856
 ldr x9,[x8,x25,lsl #3]
 sub x9,x0,x9
 cmp x9,#1
 b.ne .Louter_reject
 adrp x8,.Louter_counts
 add x8,x8,:lo12:.Louter_counts
 add x8,x8,#64
 ldr x10,[x8,x25,lsl #3]
 add x10,x10,x9
 str x10,[x8,x25,lsl #3]
 add w25,w25,#1
 cmp w25,#8
 b.ne .Louter_inner_counts_after
 outer_observe 1
/* Commit net fluxes only after the complete private transport return. */
 outer_argument x0,38
 outer_pointer x1,OUTER_F_sw_dn
 outer_pointer x2,OUTER_F_sw_up
 mov w3,w23
 bl .Louter_net_flux
 outer_argument x0,39
 outer_pointer x1,OUTER_F_lw_dn
 outer_pointer x2,OUTER_F_lw_up
 mov w3,w23
 bl .Louter_net_flux
 outer_argument x0,40
 outer_pointer x1,OUTER_F_sw_dn_clear
 outer_pointer x2,OUTER_F_sw_up_clear
 mov w3,w23
 bl .Louter_net_flux
 outer_argument x0,41
 outer_pointer x1,OUTER_F_lw_dn_clear
 outer_pointer x2,OUTER_F_lw_up_clear
 mov w3,w23
 bl .Louter_net_flux
 adrp x26,.Louter_surface_copy_table
 add x26,x26,:lo12:.Louter_surface_copy_table
 mov w25,#0
.Louter_surface_copy:
 ldp w8,w9,[x26],#8
 ldr x0,[x20,x8,lsl #3]
 add x1,x21,x9
 add x1,x1,#1216
 mov w2,#1
 mov w3,w23
 bl .Louter_copy_active
 add w25,w25,#1
 cmp w25,#6
 b.ne .Louter_surface_copy
 outer_argument x0,52
 outer_pointer x1,OUTER_F_sw_dn
 mov w2,#1
 mov w3,w23
 bl .Louter_copy_active
 outer_argument x26,48
 outer_argument x27,46
 outer_argument x28,7
 mov x25,#0
.Louter_direct_normal:
 ldr d0,[x28,x25,lsl #3]
 adrp x8,.Louter_constants
 add x8,x8,:lo12:.Louter_constants
 ldr d1,[x8,#16]
 fcmp d0,d1
 b.le .Louter_direct_zero
 ldr d1,[x27,x25,lsl #3]
 fdiv d0,d1,d0
 b .Louter_direct_store
.Louter_direct_zero:
 fmov d0,xzr
.Louter_direct_store:
 str d0,[x26,x25,lsl #3]
 add x25,x25,#1
 cmp x25,x23
 b.ne .Louter_direct_normal
/* Weighted spectral sums retain source band order and separate rounding. */
 outer_argument x26,49
 outer_argument x27,50
 outer_argument x28,51
 mov x25,#0
.Louter_spectral_column:
 fmov d0,xzr
 fmov d1,xzr
 fmov d2,xzr
 mov x10,#0
.Louter_uv_band:
 outer_model x8,4120140
 ldr w9,[x8,x10,lsl #2]
 sub w9,w9,#1
 mov x11,#14
 mul x11,x25,x11
 add x11,x11,x9
 outer_pointer x8,OUTER_F_sw_dn_surf_band
 ldr d3,[x8,x11,lsl #3]
 outer_model x8,4120544
 ldr d4,[x8,x10,lsl #3]
 fmul d3,d4,d3
 fadd d0,d0,d3
 add x10,x10,#1
 cmp x10,#3
 b.ne .Louter_uv_band
 mov x10,#0
.Louter_par_band:
 outer_model x8,4121348
 ldr w9,[x8,x10,lsl #2]
 sub w9,w9,#1
 mov x11,#14
 mul x11,x25,x11
 add x11,x11,x9
 outer_pointer x8,OUTER_F_sw_dn_surf_band
 ldr d3,[x8,x11,lsl #3]
 outer_model x8,4121752
 ldr d4,[x8,x10,lsl #3]
 fmul d3,d4,d3
 fadd d1,d1,d3
 outer_pointer x8,OUTER_F_sw_dn_surf_clear_band
 ldr d3,[x8,x11,lsl #3]
 fmul d3,d4,d3
 fadd d2,d2,d3
 add x10,x10,#1
 cmp x10,#3
 b.ne .Louter_par_band
 str d0,[x26,x25,lsl #3]
 str d1,[x27,x25,lsl #3]
 str d2,[x28,x25,lsl #3]
 add x25,x25,#1
 cmp x25,x23
 b.ne .Louter_spectral_column
/* The fourth power is a rounded square followed by its rounded square. */
 outer_argument x26,53
 outer_argument x27,8
 mov x25,#0
.Louter_emissivity:
 ldr d0,[x27,x25,lsl #3]
 fmul d0,d0,d0
 fmul d0,d0,d0
 adrp x8,:got:__yomcst_MOD_rsigma
 ldr x8,[x8,:got_lo12:__yomcst_MOD_rsigma]
 ldr d1,[x8]
 fmul d0,d1,d0
 outer_argument x8,43
 ldr d1,[x8,x25,lsl #3]
 fsub d0,d1,d0
 adrp x8,.Louter_constants
 add x8,x8,:lo12:.Louter_constants
 ldr d1,[x8,#8]
 fabs d2,d0
 fcmp d2,d1
 b.le .Louter_emissivity_default
 outer_argument x9,39
 add x10,x25,#152
 ldr d1,[x9,x10,lsl #3]
 fdiv d0,d1,d0
 ldr d1,[x8,#64]
 ldr d2,[x8,#72]
 fmin d0,d0,d2
 fmax d0,d0,d1
 b .Louter_emissivity_store
.Louter_emissivity_default:
 outer_argument x8,11
 ldr d0,[x8,x25,lsl #3]
.Louter_emissivity_store:
 str d0,[x26,x25,lsl #3]
 add x25,x25,#1
 cmp x25,x23
 b.ne .Louter_emissivity
 outer_argument x0,54
 outer_pointer x1,OUTER_F_lw_derivatives
 mov w2,#20
 mov w3,w23
 bl .Louter_copy_active
 outer_argument x0,55
 outer_pointer x1,OUTER_F_sw_dn_diffuse_surf_canopy
 mov w2,w23
 bl .Louter_canopy_transpose
 outer_argument x0,56
 outer_pointer x1,OUTER_F_sw_dn_direct_surf_canopy
 mov w2,w23
 bl .Louter_canopy_transpose
 ldr x8,[x24,#552]
 outer_model x9,4100648
 str x8,[x9]
 outer_observe 2
 mov x0,x21
 outer_call free
 ldr w8,[x29,#1952]
 cbz w8,.Louter_hook_exit_done
 adr x0,.Louter_hook_name
 add x1,x29,#1944
 mov w8,#1
 str w8,[x1]
 add x2,x29,#1936
 mov x3,#16
 outer_call __yomhook_MOD_dr_hook_default8
.Louter_hook_exit_done:
 ldr x18,[x29,#392]
 ldp d8,d9,[x29,#320]
 ldp d10,d11,[x29,#336]
 ldp d12,d13,[x29,#352]
 ldp d14,d15,[x29,#368]
 ldp x19,x20,[x29,#192]
 ldp x21,x22,[x29,#208]
 ldp x23,x24,[x29,#224]
 ldp x25,x26,[x29,#240]
 ldp x27,x28,[x29,#256]
 ldp x29,x30,[sp,#272]
 add sp,sp,#1,lsl #12
 ret
.Louter_reject:
 bl abort
 brk #0
.size md2asm_radiation_field_preparation,.-md2asm_radiation_field_preparation

/* Copy only active columns, keeping the complete eight-column row pitch. */
.Louter_copy_active:
 mov x8,#0
.Louter_copy_row:
 mov x9,#0
.Louter_copy_column:
 ldr x10,[x1,x9,lsl #3]
 str x10,[x0,x9,lsl #3]
 add x9,x9,#1
 cmp x9,x3
 b.ne .Louter_copy_column
 add x0,x0,#64
 add x1,x1,#64
 add x8,x8,#1
 cmp x8,x2
 b.ne .Louter_copy_row
 ret
.Louter_scale_active:
 mov x8,#0
.Louter_scale_row:
 mov x9,#0
.Louter_scale_column:
 ldr d1,[x1,x9,lsl #3]
 fmul d1,d1,d0
 str d1,[x0,x9,lsl #3]
 add x9,x9,#1
 cmp x9,x3
 b.ne .Louter_scale_column
 add x0,x0,#64
 add x1,x1,#64
 add x8,x8,#1
 cmp x8,x2
 b.ne .Louter_scale_row
 ret
.Louter_sum_cloud_ice:
 mov x8,#0
.Louter_ice_row:
 mov x9,#0
.Louter_ice_column:
 ldr d0,[x1,x9,lsl #3]
 ldr d1,[x2,x9,lsl #3]
 fadd d0,d0,d1
 str d0,[x0,x9,lsl #3]
 add x9,x9,#1
 cmp x9,x3
 b.ne .Louter_ice_column
 add x0,x0,#64
 add x1,x1,#64
 add x2,x2,#64
 add x8,x8,#1
 cmp x8,#19
 b.ne .Louter_ice_row
 ret
.Louter_net_flux:
 mov x8,#0
.Louter_net_row:
 mov x9,#0
.Louter_net_column:
 ldr d0,[x1,x9,lsl #3]
 ldr d1,[x2,x9,lsl #3]
 fsub d0,d0,d1
 str d0,[x0,x9,lsl #3]
 add x9,x9,#1
 cmp x9,x3
 b.ne .Louter_net_column
 add x0,x0,#64
 add x1,x1,#64
 add x2,x2,#64
 add x8,x8,#1
 cmp x8,#20
 b.ne .Louter_net_row
 ret
.Louter_canopy_transpose:
 mov x8,#0
.Louter_transpose_column:
 mov x9,#0
.Louter_transpose_band:
 mov x10,#6
 mul x10,x8,x10
 add x10,x10,x9
 ldr x11,[x1,x10,lsl #3]
 add x10,x8,x9,lsl #3
 str x11,[x0,x10,lsl #3]
 add x9,x9,#1
 cmp x9,#6
 b.ne .Louter_transpose_band
 add x8,x8,#1
 cmp x8,x2
 b.ne .Louter_transpose_column
 ret
.global md2asm_radiation_field_child_count_get
.type md2asm_radiation_field_child_count_get,%function
md2asm_radiation_field_child_count_get:
 cmp w0,#16
 b.hs .Louter_count_zero
 adrp x1,.Louter_counts
 add x1,x1,:lo12:.Louter_counts
 ldr x0,[x1,x0,lsl #3]
 ret
.Louter_count_zero:
 mov x0,#0
 ret
.size md2asm_radiation_field_child_count_get,.-md2asm_radiation_field_child_count_get
.section .bss
.p2align 3
.Louter_counts:
 .zero 128
.section .rodata
.p2align 3
.Louter_hook_name: .ascii "RADIATION_SCHEME"
.p2align 3
.Louter_integer_zero: .word 0
.Louter_integer_one: .word 1
.Louter_integer_two: .word 2
.p2align 3
.Louter_constants:
 .double 1.0e-6
 .quad 0x3ee4f8b580000000
 .quad 0x3cb0000000000000
 .double 60.0
 .double 108000000.0
 .double 6000.0
 .double 0.20944
 .double 6.283185307179587
 .double 0.8
 .double 0.99
 .double 1000.0
.p2align 3
.Louter_gas_table:
 .word 0,21
 .word 1,22
 .word 5,23
 .word 3,24
 .word 7,26
 .word 8,27
 .word 9,28
 .word 10,29
 .word 2,-1
 .word 6,-2
.Louter_surface_copy_table:
 .word 42,OUTER_F_sw_dn
 .word 43,OUTER_F_lw_dn
 .word 44,OUTER_F_sw_dn_clear
 .word 45,OUTER_F_lw_dn_clear
 .word 46,OUTER_F_sw_dn_direct
 .word 47,OUTER_F_sw_dn_direct_clear
.section .note.GNU-stack,"",%progbits

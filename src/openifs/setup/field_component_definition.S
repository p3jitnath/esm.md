/* Define the next field in the selected eight-field grid-point sequence.
 * Contract: skills/md2asm/references/openifs/setup/field_component_definition.md in the repository.
 * x0 TYPE_GFLD[1359136],x1 next embedded component[368],x2 plan[112],w3 family.
 * Return w0=0 on success or 2 before mutation. Only integer registers x0..x17.
 * Original source: gfl_subs_mod.F90 DEFINE_GFL_COMP, selected SUGFL2 calls.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_define_grid_field_component
.type md2asm_define_grid_field_component,%function
md2asm_define_grid_field_component:
 cbz x0,.Ldefine_reject
 cbz x1,.Ldefine_reject
 cbz x2,.Ldefine_reject
 orr x9,x0,x1
 orr x9,x9,x2
 tst x9,#7
 b.ne .Ldefine_reject
 cmp w3,#2
 b.hi .Ldefine_reject
 mrs x9,fpcr
 cbnz x9,.Ldefine_reject
 adr x9,.Lconfiguration_bytes
 ldr x9,[x9]
 adds x10,x0,x9
 b.cs .Ldefine_reject
 adds x11,x2,#112
 b.cs .Ldefine_reject
 cmp x11,x0
 b.ls .Ldefine_plan_separate
 cmp x2,x10
 b.lo .Ldefine_reject
.Ldefine_plan_separate:
 ldr w4,[x0]
 cmp w4,#7
 b.hi .Ldefine_reject
 cmp w4,#5
 b.lo .Ldefine_water_family
 b.eq .Ldefine_cloud_family
 cmp w3,#2
 b.ne .Ldefine_reject
 b .Ldefine_family_valid
.Ldefine_water_family:
 cbnz w3,.Ldefine_reject
 b .Ldefine_family_valid
.Ldefine_cloud_family:
 cmp w3,#1
 b.ne .Ldefine_reject
.Ldefine_family_valid:
 mov w9,#368
 umull x10,w4,w9
 add x10,x10,#3848
 add x10,x0,x10
 cmp x1,x10
 b.ne .Ldefine_reject
 cmp w4,#6
 mov w9,#6
 csel w5,w4,w9,lo
 ldr w9,[x0,#12]
 cmp w9,w4
 b.ne .Ldefine_reject
 ldr w9,[x0,#48]
 cmp w9,w4
 b.ne .Ldefine_reject
 ldr w9,[x0,#56]
 cmp w9,w4
 b.ne .Ldefine_reject
 ldr w9,[x0,#20]
 cmp w9,w5
 b.ne .Ldefine_reject
 ldr w9,[x0,#64]
 cmp w9,w5
 b.ne .Ldefine_reject
 adr x8,.Lzero_counter_offsets
 mov w6,#16
.Ldefine_zero_counter_loop:
 ldrb w9,[x8],#1
 ldr w10,[x0,x9]
 cbnz w10,.Ldefine_reject
 subs w6,w6,#1
 b.ne .Ldefine_zero_counter_loop
 /* Check the source's selected backward chain before any store. */
 adr x16,.Lhead_offset
 ldr x16,[x16]
 add x16,x0,x16
 ldr x7,[x16]
 mov x11,xzr
 add x8,x0,#3848
 mov w6,#0
.Ldefine_chain_loop:
 cmp w6,w4
 b.eq .Ldefine_chain_done
 ldr w9,[x8,#52]
 cmp w9,#1
 b.ne .Ldefine_reject
 ldr w9,[x8,#60]
 cbnz w9,.Ldefine_reject
 ldr w9,[x8,#96]
 cbnz w9,.Ldefine_reject
 add w9,w6,#1
 ldr w10,[x8,#168]
 cmp w9,w10
 b.ne .Ldefine_reject
 ldr x10,[x8,#360]
 cmp x10,x11
 b.ne .Ldefine_reject
 mov x11,x8
 add x8,x8,#368
 add w6,w6,#1
 b .Ldefine_chain_loop
.Ldefine_chain_done:
 cmp x7,x11
 b.ne .Ldefine_reject
 /* All consumed logical values must use the source's canonical 0/1 form. */
 ldr w9,[x2,#28]
 cmp w9,#1
 b.hi .Ldefine_reject
 ldr w9,[x2,#24]
 add w9,w9,#1
 cmp w9,#2
 b.hi .Ldefine_reject
 ldr w9,[x1,#112]
 cbnz w9,.Ldefine_reject
 cmp w3,#2
 b.eq .Ldefine_nogw_inputs
 mov x8,x2
 add x8,x8,#32
 mov w6,#3
.Ldefine_common_flags:
 ldr w9,[x8],#4
 cmp w9,#1
 b.hi .Ldefine_reject
 subs w6,w6,#1
 b.ne .Ldefine_common_flags
 add x8,x2,#52
 mov w6,#3
.Ldefine_interpolation_flags:
 ldr w9,[x8],#4
 cmp w9,#1
 b.hi .Ldefine_reject
 subs w6,w6,#1
 b.ne .Ldefine_interpolation_flags
 cbnz w3,.Ldefine_nonwater_inputs
 ldr w9,[x2,#44]
 cmp w9,#1
 b.hi .Ldefine_reject
 ldr w9,[x2,#48]
 cmp w9,#1
 b.hi .Ldefine_reject
 b .Ldefine_store
.Ldefine_nogw_inputs:
 ldr w9,[x2,#24]
 cbnz w9,.Ldefine_reject
.Ldefine_nonwater_inputs:
 ldr w9,[x1,#68]
 cbnz w9,.Ldefine_reject
 ldr w9,[x1,#232]
 cbnz w9,.Ldefine_reject
.Ldefine_store:
 mov w9,#1
 str w9,[x1,#64]
 ldp x10,x11,[x2]
 stp x10,x11,[x1]
 ldr w10,[x2,#16]
 str w10,[x1,#16]
 ldr w10,[x2,#24]
 str w10,[x1,#36]
 ldr x10,[x2,#64]
 str x10,[x1,#120]
 cmp w3,#2
 b.eq .Ldefine_no_identifier
 ldr w10,[x2,#20]
 str w10,[x1,#352]
.Ldefine_no_identifier:
 ldr w10,[x2,#28]
 str w10,[x1,#40]
 str w9,[x1,#52]
 str wzr,[x1,#56]
 str wzr,[x1,#96]
 cmp w3,#2
 cset w10,ne
 str w10,[x1,#92]
 str wzr,[x1,#60]
 cmp w3,#2
 b.eq .Ldefine_nogw_common
 ldr w10,[x2,#32]
 str w10,[x1,#44]
 ldr w10,[x2,#36]
 str w10,[x1,#48]
 ldr w10,[x2,#40]
 str w10,[x1,#108]
 b .Ldefine_common_stored
.Ldefine_nogw_common:
 str w9,[x1,#44]
 str wzr,[x1,#48]
 str wzr,[x1,#108]
.Ldefine_common_stored:
 cbnz w3,.Ldefine_thermodynamic_done
 ldr w10,[x2,#44]
 str w10,[x1,#68]
 cbz w10,.Ldefine_thermodynamic_done
 ldp x10,x11,[x2,#72]
 stp x10,x11,[x1,#72]
.Ldefine_thermodynamic_done:
 mov w10,#-1
 str w10,[x1,#248]
 str wzr,[x1,#252]
 str w9,[x1,#276]
 str w9,[x1,#280]
 mov w10,#-9999
 str w10,[x1,#260]
 str w10,[x1,#264]
 str w10,[x1,#268]
 str w10,[x1,#272]
 str w10,[x1,#256]
 adr x8,.Lextension_real_default
 ldr x10,[x8]
 stp x10,x10,[x1,#288]
 stp x10,x10,[x1,#304]
 str wzr,[x1,#324]
 str wzr,[x1,#336]
 str xzr,[x1,#328]
 str wzr,[x1,#320]
 mov x10,#0x3ff0000000000000
 str x10,[x1,#344]
 cmp w3,#2
 b.eq .Ldefine_extensions_done
 ldr x10,[x2,#104]
 str x10,[x1,#344]
 ldr w10,[x2,#52]
 str w10,[x1,#336]
 ldr x10,[x2,#96]
 str x10,[x1,#328]
 ldr w10,[x2,#56]
 str w10,[x1,#324]
 ldr w10,[x2,#60]
 str w10,[x1,#320]
.Ldefine_extensions_done:
 cbnz w3,.Ldefine_water_done
 str w9,[x1,#232]
 ldr w10,[x2,#48]
 str w10,[x1,#236]
 ldr x10,[x2,#88]
 str x10,[x1,#240]
 ldr x10,[x2,#80]
 str x10,[x1,#80]
.Ldefine_water_done:
 add w4,w4,#1
 str w4,[x0]
 str w4,[x0,#48]
 str w4,[x0,#56]
 str w4,[x0,#12]
 cmp w3,#2
 b.eq .Ldefine_time_count_done
 add w5,w5,#1
 str w5,[x0,#20]
 str w5,[x0,#64]
.Ldefine_time_count_done:
 adr x8,.Lundefined
 ldr w10,[x8]
 str w10,[x1,#192]
 str w4,[x1,#168]
 str w10,[x1,#172]
 str w10,[x1,#176]
 str w10,[x1,#196]
 str w10,[x1,#200]
 str w10,[x1,#208]
 cmp w3,#2
 csel w11,w5,w10,ne
 str w11,[x1,#188]
 /* The validated existing chain has no derivative/trajectory reassignment. */
 str x7,[x1,#360]
 str x1,[x16]
 mov w0,#0
 ret
.Ldefine_reject:
 mov w0,#2
 ret
.size md2asm_define_grid_field_component,.-md2asm_define_grid_field_component
.section .rodata
.p2align 3
.Lconfiguration_bytes: .xword 1359136
.Lhead_offset: .xword 799832
.Lextension_real_default: .double -99999.9
.Lundefined: .word -99999
.Lzero_counter_offsets: .byte 4,8,16,24,28,32,36,40,44,52,60,68,72,76,80,84
.section .note.GNU-stack,"",%progbits

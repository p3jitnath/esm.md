/* Contract: skills/md2asm/references/openifs/setup/operational_physics_controls.md. */
/* Own the operational TEPHY and wave setup without MODEL or original module state.
 * x0 text,x1 text bytes1..262144,x2 record[448],x3 record capacity,
 * x4 controls[8]={LSLAG,LUVPOUT},x5 GFL counts[20],x6 waves[32].
 * Record/control alignment8, count alignment4. Output ranges are disjoint
 * from every input and each other. Source-unwritten record bytes remain.
 * Return0/2. No output changes on unsupported input. Frame608 bytes.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_operational_physics_controls
.type md2asm_initialize_operational_physics_controls,%function
md2asm_initialize_operational_physics_controls:
 stp x29,x30,[sp,#-96]!
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 sub sp,sp,#512
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x5
 mov x23,x4
 mov x28,x6
 cbz x0,.Lsetup_bad
 cbz x2,.Lsetup_bad
 cbz x4,.Lsetup_bad
 cbz x5,.Lsetup_bad
 cbz x1,.Lsetup_bad
 cmp x1,#64,lsl#12
 b.hi .Lsetup_bad
 cmp x3,#448
 b.lo .Lsetup_bad
 tst x2,#7
 b.ne .Lsetup_bad
 tst x4,#7
 b.ne .Lsetup_bad
 tst x5,#3
 b.ne .Lsetup_bad
 adds x24,x0,x1
 b.cs .Lsetup_bad
 adds x25,x2,#448
 b.cs .Lsetup_bad
 adds x26,x4,#8
 b.cs .Lsetup_bad
 adds x27,x5,#20
 b.cs .Lsetup_bad
 tst x6,#7
 b.ne .Lsetup_bad
 cbz x6,.Lsetup_bad
 adds x14,x6,#32
 b.cs .Lsetup_bad
 cmp x14,x19
 b.ls .Lwave_text_ok
 cmp x28,x24
 b.lo .Lsetup_bad
.Lwave_text_ok:
 cmp x14,x21
 b.ls .Lwave_record_ok
 cmp x28,x25
 b.lo .Lsetup_bad
.Lwave_record_ok:
 cmp x14,x23
 b.ls .Lwave_control_ok
 cmp x28,x26
 b.lo .Lsetup_bad
.Lwave_control_ok:
 cmp x14,x22
 b.ls .Lwave_count_ok
 cmp x28,x27
 b.lo .Lsetup_bad
.Lwave_count_ok:
 /* Reject record/input and count/input intersections before reading controls. */
 cmp x25,x19
 b.ls .Lrecord_text_ok
 cmp x21,x24
 b.lo .Lsetup_bad
.Lrecord_text_ok:
 cmp x25,x23
 b.ls .Lrecord_control_ok
 cmp x21,x26
 b.lo .Lsetup_bad
.Lrecord_control_ok:
 cmp x25,x22
 b.ls .Lrecord_count_ok
 cmp x21,x27
 b.lo .Lsetup_bad
.Lrecord_count_ok:
 cmp x27,x19
 b.ls .Lcount_text_ok
 cmp x22,x24
 b.lo .Lsetup_bad
.Lcount_text_ok:
 cmp x27,x23
 b.ls .Lcount_control_ok
 cmp x22,x26
 b.lo .Lsetup_bad
.Lcount_control_ok:
 ldp w9,w10,[x23]
 cmp w9,#1
 b.hi .Lsetup_bad
 cmp w10,#1
 b.hi .Lsetup_bad
 mrs x11,fpcr
 cbnz x11,.Lsetup_bad
 mov x9,#0
.Lcopy_preimage:
 add x12,x21,x9
 ldp x10,x11,[x12]
 add x12,sp,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#448
 b.lo .Lcopy_preimage
 mov x0,sp
 ldr w1,[x23]
 bl md2asm_default_selected_physics_controls
 cbnz w0,.Lsetup_bad
 stp xzr,xzr,[sp,#448]
 stp xzr,xzr,[sp,#464]
 mov w9,#2
 str w9,[sp,#476]

 mov x0,x19
 mov x1,x20
 mov x2,sp
 bl md2asm_apply_operational_physics_namelist
 cbnz w0,.Lsetup_bad
 ldr w9,[sp]
 cmp w9,#1
 b.ne .Lsetup_bad
 ldr w9,[sp,#68]
 cmp w9,#1
 b.ne .Lsetup_bad
 ldr w9,[sp,#476]
 cmp w9,#1
 b.lo .Lsetup_bad
 cmp w9,#2
 b.hi .Lsetup_bad

 /* SU0PHY1748..1772, for LMPHYS=LHELDSUAREZ=false. */
 ldr w9,[sp,#0]
 cbnz w9,.Lphysics_enabled
 str wzr,[sp,#64]
 str wzr,[sp,#260]
 str wzr,[sp,#68]
.Lphysics_enabled:
 ldr w9,[x23]
 cbnz w9,.Llslag_enabled
 str wzr,[sp,#260]
.Llslag_enabled:
 ldr w9,[sp,#64]
 cbnz w9,.Llagphy_enabled
 str wzr,[sp,#40]
.Llagphy_enabled:
 /* LEPCLD resets the separate condensation switch in source order. */
 str wzr,[sp,#4]
 /* Source wave defaults leave LOCMLTKE false in this input domain. */
 ldr w9,[sp,#448]
 ldr w10,[sp,#452]
 and w9,w9,w10
 cbz w9,.Loperational_wave_uncoupled
 ldr w10,[sp,#172]
 ldr w11,[sp,#184]
 and w10,w10,w11
 cbz w10,.Loperational_wave_warm_done
 mov w10,#1
 str w10,[sp,#468]
 b .Loperational_wave_warm_done
.Loperational_wave_uncoupled:
 str wzr,[sp,#464]
.Loperational_wave_warm_done:
 ldr w10,[sp,#468]
 cbnz w10,.Loperational_wave_stokes_done
 str wzr,[sp,#184]
.Loperational_wave_stokes_done:

 /* Source1732..1740 counts are derived from their actual logical fields. */
 ldr w9,[sp,#24]
 lsl w9,w9,#1
 ldr w10,[sp,#252]
 lsl w10,w10,#1
 ldr w11,[sp,#436]
 ldr w12,[x23,#4]
 add x13,sp,#480
 stp w9,w10,[x13]
 stp w11,w12,[x13,#8]
 str wzr,[sp,#496]
 mov x9,#0
.Lcopy_record:
 add x12,sp,x9
 ldp x10,x11,[x12]
 add x12,x21,x9
 stp x10,x11,[x12]
 add x9,x9,#16
 cmp x9,#448
 b.lo .Lcopy_record
 ldp x9,x10,[sp,#448]
 stp x9,x10,[x28]
 ldp x9,x10,[sp,#464]
 stp x9,x10,[x28,#16]
 ldp x9,x10,[sp,#480]
 stp x9,x10,[x22]
 ldr w9,[sp,#496]
 str w9,[x22,#16]
 mov w0,#0
 b .Lsetup_return
.Lsetup_bad:
 mov w0,#2
.Lsetup_return:
 add sp,sp,#512
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#96
 ret
.size md2asm_initialize_operational_physics_controls,.-md2asm_initialize_operational_physics_controls
.section .note.GNU-stack,"",%progbits

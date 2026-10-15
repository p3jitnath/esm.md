/*
 * Surface initial-state conversion, revision 1.
 * Physics: formulations/openifs/input/surface_initial_state_conversion.md
 * Contract: skills/md2asm/references/openifs/input/surface_initial_state_conversion.md
 * x0..x7: field2d, bytes2d, field3d, bytes3d, parameters, parameter_bytes,
 * configuration and configuration_bytes. Required spans 770048/409600/208/2304.
 * FP64 is 64-bit floating point. FPCR controls its arithmetic and must be zero.
 * FPSR records arithmetic flags. Preserve FPCR, errno, x18 and ABI saved state.
 * Fields change in place. Immutable configuration and parameters may overlap.
 * Fields must be disjoint from each other and immutable input spans, aligned
 * to eight bytes. Parameter identifiers are aligned to four bytes.
 * Return 0 success, 1 bad spans, 2 bad FPCR, 3 bad configuration,
 * 4 absent required field, 5 out-of-table vegetation type. Reject before writes.
 * Finite field values and valid physical constants/tables are caller inputs.
 */
.arch armv8.2-a
.text
.p2align 4
.macro DISJOINT first, first_end, second, second_end
 cmp \first,\second_end
 b.hs .Ldisjoint_\@
 cmp \second,\first_end
 b.lo .Lbad
.Ldisjoint_\@:
.endm
.macro LOAD_FIELD reg,slot
 ldr x8,[x26,#(\slot*8)]
 ldr \reg,[x8,x23,lsl#3]
.endm
.macro STORE_FIELD reg,slot
 ldr x8,[x26,#(\slot*8)]
 str \reg,[x8,x23,lsl#3]
.endm
.global md2asm_convert_initial_surface_state
.type md2asm_convert_initial_surface_state,%function
md2asm_convert_initial_surface_state:
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x4,.Lbad
 cbz x6,.Lbad
 orr x8,x0,x2
 orr x8,x8,x6
 tst x8,#7
 b.ne .Lbad
 tst x4,#3
 b.ne .Lbad
 movz x8,#0xc000
 movk x8,#11,lsl#16
 cmp x1,x8
 b.lo .Lbad
 adds x9,x0,x8
 b.cs .Lbad
 movz x8,#0x4000
 movk x8,#6,lsl#16
 cmp x3,x8
 b.lo .Lbad
 adds x10,x2,x8
 b.cs .Lbad
 cmp x5,#208
 b.lo .Lbad
 adds x11,x4,#208
 b.cs .Lbad
 cmp x7,#2304
 b.lo .Lbad
 adds x12,x6,#2304
 b.cs .Lbad
 DISJOINT x0,x9,x2,x10
 DISJOINT x0,x9,x4,x11
 DISJOINT x0,x9,x6,x12
 DISJOINT x2,x10,x4,x11
 DISJOINT x2,x10,x6,x12
 mrs x8,fpcr
 cbnz x8,.Lmode
 // Freeze this selected ECMWF, five-layer input route before any mutation.
 ldr x8,[x6]
 cbnz x8,.Lconfig
 ldr x8,[x6,#8]
 cmp x8,#2048
 b.ne .Lconfig
 ldr x8,[x6,#16]
 cmp x8,#127
 b.hi .Lconfig
 ldr x8,[x6,#24]
 cbz x8,.Lconfig
 ldr x8,[x6,#136]
 cmp x8,#1
 b.ne .Lconfig
 ldr x8,[x6,#104]
 cmp x8,#0
 b.gt .Lconfig
 ldr x8,[x6,#120]
 cmp x8,#0
 b.gt .Lconfig
 ldr x8,[x6,#112]
 ldr x9,[x6,#16]
 cmp x8,x9
 b.lt .Lconfig
 ldr x8,[x6,#128]
 cmp x8,x9
 b.lt .Lconfig
 stp x29,x30,[sp,#-384]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mrs x8,fpsr
 str x8,[sp,#352]
 mov x19,x0
 mov x20,x2
 mov x21,x4
 mov x22,x6
 ldr x24,[x22,#16]
 add x26,sp,#128
 mov x25,#0
 ldr x8,[x22,#32]
 cbz x8,.Lcurrent_ready
 ldr x8,[x22,#56]
 cbnz x8,.Lcurrent_ready
 mov x25,#1
.Lcurrent_ready:
 adrp x14,.Lrequired2d
 add x14,x14,:lo12:.Lrequired2d
 mov x13,#0
.Lfind2d_field:
 cmp x13,#21
 b.lo .Lfind2d_required
 cbnz x25,.Lfind2d_required
 str xzr,[x26,x13,lsl#3]
 b .Lfind2d_next
.Lfind2d_required:
 ldr w15,[x14,x13,lsl#2]
 mov x9,#0
.Lfind2d_search:
 ldr w8,[x21,x9,lsl#2]
 cmp w8,w15
 b.eq .Lfind2d_found
 add x9,x9,#1
 cmp x9,#47
 b.ne .Lfind2d_search
 mov w0,#4
 b .Lrestore_reject
.Lfind2d_found:
 add x8,x19,x9,lsl#14
 str x8,[x26,x13,lsl#3]
.Lfind2d_next:
 add x13,x13,#1
 cmp x13,#23
 b.ne .Lfind2d_field
 adrp x14,.Lrequired3d
 add x14,x14,:lo12:.Lrequired3d
 add x12,x21,#188
 mov x13,#0
.Lfind3d_field:
 ldr w15,[x14,x13,lsl#2]
 mov x9,#0
.Lfind3d_search:
 ldr w8,[x12,x9,lsl#2]
 cmp w8,w15
 b.eq .Lfind3d_found
 add x9,x9,#1
 cmp x9,#5
 b.ne .Lfind3d_search
 mov w0,#4
 b .Lrestore_reject
.Lfind3d_found:
 movz x8,#0x4000
 movk x8,#1,lsl#16
 madd x8,x9,x8,x20
 add x10,sp,#312
 str x8,[x10,x13,lsl#3]
 add x13,x13,#1
 cmp x13,#3
 b.ne .Lfind3d_field
 // Source NINT rounds a half away from zero. Require each table index in 0..N.
 scvtf d1,x24
 fmov d2,#0.5
 fadd d1,d1,d2
 fneg d2,d2
 mov x23,#0
.Lpreflight_vegetation:
 LOAD_FIELD d0,15
 fcmp d0,d2
 b.vs .Lvegetation_bad
 b.le .Lvegetation_bad
 fcmp d0,d1
 b.ge .Lvegetation_bad
 LOAD_FIELD d0,16
 fcmp d0,d2
 b.vs .Lvegetation_bad
 b.le .Lvegetation_bad
 fcmp d0,d1
 b.ge .Lvegetation_bad
 add x23,x23,#1
 cmp x23,#2048
 b.ne .Lpreflight_vegetation
 ldr x8,[sp,#352]
 msr fpsr,x8
 ldr x8,[x22,#64]
 str x8,[sp,#336]
 ldr x8,[x22,#80]
 str x8,[sp,#344]
 mov x0,x19
 movz x1,#0xc000
 movk x1,#11,lsl#16
 mov x2,x20
 movz x3,#0x4000
 movk x3,#6,lsl#16
 mov x4,x21
 mov x5,#208
 add x6,sp,#336
 mov x7,#16
 bl md2asm_scale_initial_surface_fields
 // The validated child has no remaining reject route for these arguments.
 cbnz w0,.Lreturn
 fmov d31,xzr
 fmov d30,#0.5
 ldr d29,[x22,#72]
 ldr d28,[x22,#96]
 ldr d27,[x22,#88]
 fmov d26,#2.0
 adrp x8,.Lfreeze_temperature
 ldr d25,[x8,:lo12:.Lfreeze_temperature]
 adrp x8,.Lmissing
 ldr d24,[x8,:lo12:.Lmissing]
 add x27,x22,#256
 add x28,x22,#1280
 mov x23,#0
.Lpoint:
 LOAD_FIELD d0,14
 fcmp d0,d24
 b.ne .Lsst_ready
 STORE_FIELD d29,14
.Lsst_ready:
 LOAD_FIELD d0,20
 fcmp d0,d24
 b.ne .Lice_missing_ready
 STORE_FIELD d31,20
.Lice_missing_ready:
 LOAD_FIELD d0,0
 fcmp d0,d30
 b.gt .Lland_adjusted
 LOAD_FIELD d1,2
 ldr x8,[x22,#40]
 cbnz x8,.Locean_skin_ready
 ldr x8,[x22,#48]
 cbnz x8,.Locean_skin_ready
 STORE_FIELD d1,1
.Locean_skin_ready:
 STORE_FIELD d1,4
 STORE_FIELD d1,5
 STORE_FIELD d31,6
 STORE_FIELD d31,9
 STORE_FIELD d31,10
 ldr x8,[sp,#312]
 add x8,x8,x23,lsl#3
 mov x9,#5
.Lsea_snow_zero:
 str d31,[x8]
 add x8,x8,#16384
 subs x9,x9,#1
 b.ne .Lsea_snow_zero
 STORE_FIELD d1,3
 STORE_FIELD d31,7
 STORE_FIELD d31,8
.Lland_adjusted:
 ldr x8,[sp,#312]
 add x8,x8,x23,lsl#3
 mov x9,#5
 fmov d16,xzr
.Lsnow_depth:
 ldr d0,[x8]
 fmaxnm d0,d31,d0
 str d0,[x8]
 fadd d16,d16,d0
 add x8,x8,#16384
 subs x9,x9,#1
 b.ne .Lsnow_depth
 ldr x8,[sp,#328]
 add x8,x8,x23,lsl#3
 mov x9,#5
 fmov d17,xzr
.Lsnow_water:
 ldr d0,[x8]
 fmaxnm d0,d31,d0
 str d0,[x8]
 fadd d17,d17,d0
 add x8,x8,#16384
 subs x9,x9,#1
 b.ne .Lsnow_water
 fsub d0,d16,d17
 fcmpe d0,d31
 b.hi .Lsnow_kept
 ldr x8,[sp,#312]
 ldr x10,[sp,#328]
 add x8,x8,x23,lsl#3
 add x10,x10,x23,lsl#3
 mov x9,#5
.Lsnow_no_ice_zero:
 str d31,[x8]
 str d31,[x10]
 add x8,x8,#16384
 add x10,x10,#16384
 subs x9,x9,#1
 b.ne .Lsnow_no_ice_zero
.Lsnow_kept:
 ldr x8,[sp,#320]
 add x8,x8,x23,lsl#3
 mov x9,#5
.Lsnow_temperature:
 ldr d0,[x8]
 fminnm d0,d0,d29
 str d0,[x8]
 add x8,x8,#16384
 subs x9,x9,#1
 b.ne .Lsnow_temperature
 LOAD_FIELD d0,15
 fcvtas w9,d0
 LOAD_FIELD d0,16
 fcvtas w10,d0
 ldr d1,[x27,w9,sxtw#3]
 LOAD_FIELD d0,17
 fmul d16,d0,d1
 ldr d1,[x27,w10,sxtw#3]
 LOAD_FIELD d0,18
 fmul d17,d0,d1
 fmov d0,#1.0
 fsub d18,d0,d16
 fsub d18,d18,d17
 ldr d1,[x28,w9,sxtw#3]
 fmul d19,d16,d1
 fadd d18,d18,d19
 ldr d1,[x28,w10,sxtw#3]
 fmul d19,d17,d1
 fadd d18,d18,d19
 fmul d18,d27,d18
 LOAD_FIELD d0,6
 fminnm d0,d18,d0
 fmaxnm d0,d31,d0
 STORE_FIELD d0,6
 LOAD_FIELD d0,20
 fcmp d0,d28
 b.gt .Lsea_ice_ready
 STORE_FIELD d31,20
.Lsea_ice_ready:
 LOAD_FIELD d0,13
 fmaxnm d0,d26,d0
 LOAD_FIELD d1,11
 fminnm d0,d0,d1
 fmaxnm d0,d31,d0
 STORE_FIELD d0,11
 LOAD_FIELD d0,12
 fmaxnm d0,d25,d0
 STORE_FIELD d0,12
 cbz x25,.Lcurrents_ready
 LOAD_FIELD d0,21
 fcmp d0,d24
 b.ne .Lcurrent_u_ready
 STORE_FIELD d31,21
.Lcurrent_u_ready:
 LOAD_FIELD d0,22
 fcmp d0,d24
 b.ne .Lcurrent_v_ready
 STORE_FIELD d31,22
.Lcurrent_v_ready:
 LOAD_FIELD d0,0
 fcmp d0,d30
 b.le .Lcurrents_ready
 STORE_FIELD d31,21
 STORE_FIELD d31,22
.Lcurrents_ready:
 add x23,x23,#1
 cmp x23,#2048
 b.ne .Lpoint
 mov w0,#0
 b .Lreturn
.Lvegetation_bad:
 mov w0,#5
.Lrestore_reject:
 ldr x8,[sp,#352]
 msr fpsr,x8
.Lreturn:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#384
 ret
.Lbad:
 mov w0,#1
 ret
.Lmode:
 mov w0,#2
 ret
.Lconfig:
 mov w0,#3
 ret
.size md2asm_convert_initial_surface_state,.-md2asm_convert_initial_surface_state
.section .rodata
.p2align 3
.Lrequired2d:
 .word 172,235,139,170,183,236,198,39,40,41,42
 .word 228009,228010,228007,34,29,30,27,28,43,31,151131,151132
.Lrequired3d:
 .word 228141,238,228038
.p2align 3
.Lfreeze_temperature:
 .double 273.15
.Lmissing:
 .double -9999.0
.section .note.GNU-stack,"",%progbits

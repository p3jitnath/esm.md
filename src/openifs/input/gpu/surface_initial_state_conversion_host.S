/* Complete GPU phase. Contract: skills/md2asm-gpu/references/openifs/input/complete_surface_initial_conversion.md */
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

 // The complete phase retains preflight, scaling and conversion in one launch.
 mov x0,x19
 movz x1,#0xc000
 movk x1,#11,lsl#16
 mov x2,x20
 movz x3,#0x4000
 movk x3,#6,lsl#16
 mov x4,x21
 mov x5,#208
 mov x6,x22
 mov x7,#2304
 mov x8,#1
 bl md2asm_initial_surface_complete_phase
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


.arch armv8.2-a
.text
.p2align 4
.global md2asm_initial_surface_complete_phase
.hidden md2asm_initial_surface_complete_phase
.type md2asm_initial_surface_complete_phase,%function
md2asm_initial_surface_complete_phase:
 sub sp,sp,#1536
 stp x0,x1,[sp,#0]
 stp x2,x3,[sp,#16]
 stp x4,x5,[sp,#32]
 stp x6,x7,[sp,#48]
 stp x8,x9,[sp,#64]
 stp x10,x11,[sp,#80]
 stp x12,x13,[sp,#96]
 stp x14,x15,[sp,#112]
 stp x16,x17,[sp,#128]
 stp x18,x19,[sp,#144]
 stp x20,x21,[sp,#160]
 stp x22,x23,[sp,#176]
 stp x24,x25,[sp,#192]
 stp x26,x27,[sp,#208]
 stp x28,x29,[sp,#224]
 str x30,[sp,#240]
 stp q0,q1,[sp,#256]
 stp q2,q3,[sp,#288]
 stp q4,q5,[sp,#320]
 stp q6,q7,[sp,#352]
 stp q8,q9,[sp,#384]
 stp q10,q11,[sp,#416]
 stp q12,q13,[sp,#448]
 stp q14,q15,[sp,#480]
 stp q16,q17,[sp,#512]
 stp q18,q19,[sp,#544]
 stp q20,q21,[sp,#576]
 stp q22,q23,[sp,#608]
 stp q24,q25,[sp,#640]
 stp q26,q27,[sp,#672]
 stp q28,q29,[sp,#704]
 stp q30,q31,[sp,#736]
 mrs x9,fpcr
 mrs x10,fpsr
 mrs x11,nzcv
 str x9,[sp,#768]
 str x10,[sp,#776]
 str x11,[sp,#784]
 cbnz x9,.Lsurface_phase_fatal
 bl __errno_location
 ldr x18,[sp,#144]
 str x0,[sp,#792]
 ldr w9,[x0]
 str w9,[sp,#800]
 bl omp_in_parallel
 ldr x18,[sp,#144]
 cbnz w0,.Lsurface_phase_fatal
 bl md2asm_openifs_gpu_prepare
 ldr x18,[sp,#144]
 cbnz w0,.Lsurface_phase_fatal
 add x19,sp,#832
 add x20,sp,#896
 add x21,sp,#960
 mov x9,#0
.Lsurface_zero_private:
 str xzr,[x19,x9,lsl #3]
 add x9,x9,#1
 cmp x9,#24
 b.lo .Lsurface_zero_private
 ldr x9,[sp]
 ldr x10,[sp,#16]
 stp x9,x10,[x19]
 ldr x9,[sp,#32]
 ldr x10,[sp,#48]
 stp x9,x10,[x19,#16]
 ldr x9,[sp,#64]
 str x9,[x19,#32]
 mov x9,#64
 stp x9,x9,[x21]
 movz x9,#0xc000
 movk x9,#11,lsl#16
 str x9,[x21,#16]
 movz x9,#0x4000
 movk x9,#6,lsl#16
 str x9,[x21,#24]
 mov x9,#208
 str x9,[x21,#32]
 mov x9,#16
 ldr x10,[sp,#64]
 cbz x10,.Lsurface_cfg_capacity_ready
 mov x9,#2304
.Lsurface_cfg_capacity_ready:
 str x9,[x21,#40]
 mov w9,#1
 str w9,[x20,#4]
 str x21,[x20,#48]
 mov x9,#64
 str x9,[x20,#56]
 ldr x9,[sp,#768]
 ldr x10,[sp,#776]
 msr fpcr,x9
 msr fpsr,x10
 ldr x9,[sp,#792]
 ldr w10,[sp,#800]
 str w10,[x9]
 adrp x0,.Lsurface_complete_entry_name
 add x0,x0,:lo12:.Lsurface_complete_entry_name
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#128
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#144]
 cbnz w0,.Lsurface_phase_fatal
 ldr w9,[x20]
 cbnz w9,.Lsurface_phase_fatal
 ldr x9,[x20,#16]
 cbnz x9,.Lsurface_phase_fatal
 ldr w9,[x20,#32]
 cmp w9,#5
 b.hi .Lsurface_phase_fatal
 str w9,[sp,#808]
 ldr x9,[sp,#768]
 msr fpcr,x9
 ldr x9,[sp,#776]
 ldr w10,[x20,#8]
 orr x9,x9,x10
 msr fpsr,x9
 ldr x9,[sp,#792]
 ldr w10,[sp,#800]
 str w10,[x9]
 ldr x9,[sp,#784]
 msr nzcv,x9
 ldp q0,q1,[sp,#256]
 ldp q2,q3,[sp,#288]
 ldp q4,q5,[sp,#320]
 ldp q6,q7,[sp,#352]
 ldp q8,q9,[sp,#384]
 ldp q10,q11,[sp,#416]
 ldp q12,q13,[sp,#448]
 ldp q14,q15,[sp,#480]
 ldp q16,q17,[sp,#512]
 ldp q18,q19,[sp,#544]
 ldp q20,q21,[sp,#576]
 ldp q22,q23,[sp,#608]
 ldp q24,q25,[sp,#640]
 ldp q26,q27,[sp,#672]
 ldp q28,q29,[sp,#704]
 ldp q30,q31,[sp,#736]
 ldp x0,x1,[sp,#0]
 ldp x2,x3,[sp,#16]
 ldp x4,x5,[sp,#32]
 ldp x6,x7,[sp,#48]
 ldp x8,x9,[sp,#64]
 ldp x10,x11,[sp,#80]
 ldp x12,x13,[sp,#96]
 ldp x14,x15,[sp,#112]
 ldp x16,x17,[sp,#128]
 ldp x18,x19,[sp,#144]
 ldp x20,x21,[sp,#160]
 ldp x22,x23,[sp,#176]
 ldp x24,x25,[sp,#192]
 ldp x26,x27,[sp,#208]
 ldp x28,x29,[sp,#224]
 ldr x30,[sp,#240]
 ldr w0,[sp,#808]
 add sp,sp,#1536
 ret
.Lsurface_phase_fatal:
 bl abort
 brk #0
.size md2asm_initial_surface_complete_phase,.-md2asm_initial_surface_complete_phase
.section .rodata
.Lsurface_complete_entry_name:.asciz "md2asm_gpu_initial_surface_complete"
.section .note.GNU-stack,"",%progbits

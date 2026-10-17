// Complete selected shortwave columns with private storage and exact counters.
// Physics formulations/openifs/physics/shortwave_cloud_transport.md.
// Contract skills/md2asm/references/openifs/physics/solver_mcica_sw.md.
// The public entry retains sixteen address arguments. x18 and saved registers
// are preserved. The hidden payload receives the same addresses with a private
// flux clone in argument15, and its worker record in preserved register x28.
// Validation and initial arena allocation precede launch. Workers use private owners.
// After join, the controller merges global column slots and commits once.
#include "shortwave_team_layout.inc.S"
#ifndef MD2ASM_SW_TEAM_REQUESTED
#define MD2ASM_SW_TEAM_REQUESTED 8
#endif
#if MD2ASM_SW_TEAM_REQUESTED != 1 && MD2ASM_SW_TEAM_REQUESTED != 8
#error Shortwave team request must be one or eight.
#endif
.arch armv8.2-a
.text
.macro SW_CALL name,save=160
 bl \name
 ldr x18,[sp,#\save]
.endm
.macro SW_CONSTANT reg,value
 movz \reg,#((\value)&65535)
.if ((\value)>>16)
 movk \reg,#(((\value)>>16)&65535),lsl #16
.endif
.endm
.p2align 4
.global md2asm_solver_mcica_sw
.global __radiation_mcica_sw_MOD_solver_mcica_sw
.type md2asm_solver_mcica_sw,%function
__radiation_mcica_sw_MOD_solver_mcica_sw:
md2asm_solver_mcica_sw:
 mov x17,sp
 sub sp,sp,#2560
 stp x19,x20,[sp,#64]
 stp x21,x22,[sp,#80]
 stp x23,x24,[sp,#96]
 stp x25,x26,[sp,#112]
 stp x27,x28,[sp,#128]
 stp x29,x30,[sp,#144]
 str x18,[sp,#160]
 mov x29,sp
 add x19,sp,#319
 and x19,x19,#-64
 mov x9,x19
 mov x10,#128
.Lsw_zero_context:
 stp xzr,xzr,[x9],#16
 subs x10,x10,#1
 b.ne .Lsw_zero_context
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 ldp x8,x9,[x17]
 stp x8,x9,[x19,#64]
 ldp x8,x9,[x17,#16]
 stp x8,x9,[x19,#80]
 ldp x8,x9,[x17,#32]
 stp x8,x9,[x19,#96]
 ldp x8,x9,[x17,#48]
 stp x8,x9,[x19,#112]
 mrs x9,fpcr
 mrs x10,fpsr
 str x9,[x19,#SW_CONTROLLER_ENTRY_FPCR]
 str x10,[x19,#SW_CONTROLLER_ENTRY_FPSR]
 mov x25,#0
 mov x9,#MD2ASM_SW_TEAM_REQUESTED
 str x9,[x19,#SW_CONTROLLER_REQUIRED_TEAM]
 SW_CALL __errno_location
 str x0,[x19,#SW_CONTROLLER_ERRNO_POINTER]
 ldr w9,[x0]
 str w9,[x19,#SW_CONTROLLER_ENTRY_ERRNO]
 mov x0,x19
 bl md2asm_sw_team_validate
 cbz w0,.Lsw_cleanup
 SW_CALL omp_in_parallel
 cbnz w0,.Lsw_cleanup
 // The existing numerical interval has one serial caller and no observers.
 // Retain one bounded private arena until process exit. Its contents carry no
 // model state. Rebuild record metadata and required incoming owners each call.
 adrp x9,.Lsw_cached_arena
 add x9,x9,:lo12:.Lsw_cached_arena
 ldr x26,[x9]
 cbnz x26,.Lsw_arena_ready
 SW_CONSTANT x0,(SW_PAYLOAD_BYTES*MD2ASM_SW_TEAM_REQUESTED)
 SW_CALL malloc
 cbz x0,.Lsw_cleanup
 mov x26,x0
 adrp x9,.Lsw_cached_arena
 add x9,x9,:lo12:.Lsw_cached_arena
 str x26,[x9]
.Lsw_arena_ready:
 mov x21,#0
.Lsw_allocate_worker:
 mov x9,#SW_WORK_BYTES
 madd x20,x21,x9,x19
 add x20,x20,#SW_CONTROLLER_WORKERS
 SW_CONSTANT x9,SW_PAYLOAD_BYTES
 madd x0,x21,x9,x26
 str x0,[x20,#SW_WORK_SCRATCH]
 SW_CONSTANT x9,SW_PAYLOAD_FLUX_OFFSET
 add x22,x0,x9
 str x22,[x20,#SW_WORK_FLUX]
 str x19,[x20,#SW_WORK_CONTROLLER]
 str x19,[x20,#SW_WORK_ARGUMENTS]
 add x9,x21,#1
 str x9,[x19,#SW_CONTROLLER_ALLOCATED_WORKERS]
 mov x0,x22
 ldr x1,[x19,#120]
 mov x2,#SW_PAYLOAD_FLUX_BYTES
 bl .Lsw_copy_bytes
 adrp x23,.Lsw_output_specs
 add x23,x23,:lo12:.Lsw_output_specs
 mov x27,#11
.Lsw_prepare_output:
 ldr x9,[x23]
 ldr x10,[x19,#120]
 ldr x1,[x10,x9]
 cbz x1,.Lsw_prepare_output_next
 ldr x10,[x23,#16]
 ldr x0,[x20,#SW_WORK_SCRATCH]
 add x0,x0,x10
 str x0,[x22,x9]
 cbz x21,.Lsw_prepare_copy
 cmp x9,#3208
 b.ne .Lsw_prepare_output_next
.Lsw_prepare_copy:
 ldr x2,[x23,#8]
 bl .Lsw_copy_bytes
.Lsw_prepare_output_next:
 add x23,x23,#48
 subs x27,x27,#1
 b.ne .Lsw_prepare_output
 add x21,x21,#1
 cmp x21,#MD2ASM_SW_TEAM_REQUESTED
 b.ne .Lsw_allocate_worker
 adr x0,.Lsw_callback
 mov x1,x19
 mov w2,#MD2ASM_SW_TEAM_REQUESTED
 mov w3,#0
 SW_CALL GOMP_parallel
 ldr x9,[x19,#SW_CONTROLLER_BAD_TEAM]
 cbnz x9,.Lsw_cleanup
 ldr x27,[x19,#SW_CONTROLLER_ACTUAL_TEAM]
 cmp x27,#1
 b.lo .Lsw_cleanup
 cmp x27,#MD2ASM_SW_TEAM_REQUESTED
 b.hi .Lsw_cleanup
 // Collect complete numerical flags and the last changed error indicator.
 ldr x24,[x19,#SW_CONTROLLER_ENTRY_FPSR]
 ldr w26,[x19,#SW_CONTROLLER_ENTRY_ERRNO]
 mov x21,#0
 mov x10,#0
 mov x11,#0
 mov x12,#0
.Lsw_collect_workers:
 mov x9,#SW_WORK_BYTES
 madd x20,x21,x9,x19
 add x20,x20,#SW_CONTROLLER_WORKERS
 ldr x9,[x20,#SW_WORK_NUMERICAL_FPSR]
 orr x24,x24,x9
 ldr w9,[x20,#SW_WORK_FINAL_ERRNO]
 ldr w13,[x19,#SW_CONTROLLER_ENTRY_ERRNO]
 cmp w9,w13
 csel w26,w9,w26,ne
 ldp x14,x15,[x20,#SW_COUNTER_FAST]
 add x10,x10,x14
 add x11,x11,x15
 ldr x14,[x20,#SW_COUNTER_EXP]
 add x12,x12,x14
 add x21,x21,#1
 cmp x21,x27
 b.lo .Lsw_collect_workers
 str x10,[x19,#SW_CONTROLLER_FAST_TOTAL]
 str x11,[x19,#SW_CONTROLLER_WIDE_TOTAL]
 str x12,[x19,#SW_CONTROLLER_EXP_TOTAL]
 // Worker zero already owns a complete initialised private output set.
 add x20,x19,#SW_CONTROLLER_WORKERS
 ldr x22,[x20,#SW_WORK_FLUX]
 mov x21,#1
.Lsw_merge_worker:
 cmp x21,x27
 b.hs .Lsw_merge_done
 mov x9,#SW_WORK_BYTES
 madd x20,x21,x9,x19
 add x20,x20,#SW_CONTROLLER_WORKERS
 ldr x9,[x20,#SW_WORK_BEGIN]
 ldr x10,[x20,#SW_WORK_END]
 cmp x9,x10
 b.hs .Lsw_merge_next_worker
 adrp x23,.Lsw_output_specs
 add x23,x23,:lo12:.Lsw_output_specs
 mov x28,#11
.Lsw_merge_output:
 ldr x9,[x23]
 ldr x1,[x20,#SW_WORK_FLUX]
 ldr x1,[x1,x9]
 cbz x1,.Lsw_merge_next_output
 ldr x0,[x22,x9]
 ldr x9,[x23,#24]
 cbz x9,.Lsw_merge_profile
 cmp x9,#1
 b.eq .Lsw_merge_spectrum
 // One cover word per global physical column.
 ldr x9,[x20,#SW_WORK_BEGIN]
 ldr x10,[x20,#SW_WORK_END]
.Lsw_merge_cover_word:
 ldr x11,[x1,x9,lsl #3]
 str x11,[x0,x9,lsl #3]
 add x9,x9,#1
 cmp x9,x10
 b.lo .Lsw_merge_cover_word
 b .Lsw_merge_next_output
.Lsw_merge_profile:
 mov x11,#0
.Lsw_merge_profile_boundary:
 ldr x9,[x20,#SW_WORK_BEGIN]
 ldr x10,[x20,#SW_WORK_END]
 lsl x12,x11,#3
.Lsw_merge_profile_column:
 add x13,x12,x9
 ldr x14,[x1,x13,lsl #3]
 str x14,[x0,x13,lsl #3]
 add x9,x9,#1
 cmp x9,x10
 b.lo .Lsw_merge_profile_column
 add x11,x11,#1
 cmp x11,#20
 b.lo .Lsw_merge_profile_boundary
 b .Lsw_merge_next_output
.Lsw_merge_spectrum:
 ldr x9,[x20,#SW_WORK_BEGIN]
 ldr x10,[x20,#SW_WORK_END]
 mov x11,#112
 mul x9,x9,x11
 mul x10,x10,x11
.Lsw_merge_spectrum_word:
 ldr x11,[x1,x9,lsl #3]
 str x11,[x0,x9,lsl #3]
 add x9,x9,#1
 cmp x9,x10
 b.lo .Lsw_merge_spectrum_word
.Lsw_merge_next_output:
 add x23,x23,#48
 subs x28,x28,#1
 b.ne .Lsw_merge_output
.Lsw_merge_next_worker:
 add x21,x21,#1
 b .Lsw_merge_worker
.Lsw_merge_done:
 // No counter observer or outside writer runs during this private interval.
 adrp x9,:got:md2asm_product_sum_fast_calls
 ldr x9,[x9,:got_lo12:md2asm_product_sum_fast_calls]
 ldr x10,[x9]
 ldr x11,[x19,#SW_CONTROLLER_FAST_TOTAL]
 add x10,x10,x11
 str x10,[x9]
 adrp x9,:got:md2asm_product_sum_wide_calls
 ldr x9,[x9,:got_lo12:md2asm_product_sum_wide_calls]
 ldr x10,[x9]
 ldr x11,[x19,#SW_CONTROLLER_WIDE_TOTAL]
 add x10,x10,x11
 str x10,[x9]
 adrp x9,:got:md2asm_exponential_native_calls_storage
 ldr x9,[x9,:got_lo12:md2asm_exponential_native_calls_storage]
 ldr x10,[x9]
 ldr x11,[x19,#SW_CONTROLLER_EXP_TOTAL]
 add x10,x10,x11
 str x10,[x9]
 adrp x23,.Lsw_output_specs
 add x23,x23,:lo12:.Lsw_output_specs
 mov x21,#11
.Lsw_commit_output:
 ldr x9,[x23]
 ldr x0,[x19,#120]
 ldr x0,[x0,x9]
 cbz x0,.Lsw_commit_next
 ldr x1,[x22,x9]
 ldr x2,[x23,#8]
 bl .Lsw_copy_bytes
.Lsw_commit_next:
 add x23,x23,#48
 subs x21,x21,#1
 b.ne .Lsw_commit_output
 mov x25,#1
.Lsw_cleanup:
#ifdef MD2ASM_SW_TEAM_RECORD
 adrp x9,.Lsw_last_context
 add x9,x9,:lo12:.Lsw_last_context
 mov x10,x19
 mov x11,#128
.Lsw_record_context:
 ldp x12,x13,[x10],#16
 stp x12,x13,[x9],#16
 subs x11,x11,#1
 b.ne .Lsw_record_context
#endif
 // The bounded arena remains owned by this module until process exit.
 ldr x9,[x19,#SW_CONTROLLER_ENTRY_FPCR]
 msr fpcr,x9
 cbnz x25,.Lsw_restore_numerical_state
 ldr x24,[x19,#SW_CONTROLLER_ENTRY_FPSR]
 ldr w26,[x19,#SW_CONTROLLER_ENTRY_ERRNO]
.Lsw_restore_numerical_state:
 msr fpsr,x24
 ldr x9,[x19,#SW_CONTROLLER_ERRNO_POINTER]
 str w26,[x9]
 cbnz x25,.Lsw_return
 // No numerical worker or public commit preceded the serial fallback.
 ldp x8,x9,[x19,#64]
 stp x8,x9,[sp]
 ldp x8,x9,[x19,#80]
 stp x8,x9,[sp,#16]
 ldp x8,x9,[x19,#96]
 stp x8,x9,[sp,#32]
 ldp x8,x9,[x19,#112]
 stp x8,x9,[sp,#48]
 ldp x0,x1,[x19]
 ldp x2,x3,[x19,#16]
 ldp x4,x5,[x19,#32]
 ldp x6,x7,[x19,#48]
 SW_CALL md2asm_sw_team_serial
.Lsw_return:
 ldr x18,[sp,#160]
 ldp x19,x20,[sp,#64]
 ldp x21,x22,[sp,#80]
 ldp x23,x24,[sp,#96]
 ldp x25,x26,[sp,#112]
 ldp x27,x28,[sp,#128]
 ldp x29,x30,[sp,#144]
 add sp,sp,#2560
 ret
.size md2asm_solver_mcica_sw,.-md2asm_solver_mcica_sw

// Admission changes only private metadata and restores its complete entry FPSR.
// x0 is the controller record. w0 is one to admit or zero for serial fallback.
.global md2asm_sw_team_validate
.hidden md2asm_sw_team_validate
.type md2asm_sw_team_validate,%function
md2asm_sw_team_validate:
 sub sp,sp,#64
 stp x19,x20,[sp]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x29,x30,[sp,#48]
 mov x19,x0
 mrs x20,fpsr
 mrs x9,fpcr
 cbnz x9,.Lsw_validate_refuse
 mov x9,#0
.Lsw_validate_arguments:
 ldr x10,[x19,x9,lsl #3]
 cbz x10,.Lsw_validate_refuse
 add x9,x9,#1
 cmp x9,#16
 b.lo .Lsw_validate_arguments
 ldr x9,[x19]
 ldr w9,[x9]
 cmp w9,#19
 b.ne .Lsw_validate_refuse
 str x9,[x19,#SW_CONTROLLER_LAYERS]
 ldr x9,[x19,#8]
 ldrsw x9,[x9]
 cmp x9,#1
 b.lt .Lsw_validate_refuse
 str x9,[x19,#SW_CONTROLLER_FIRST]
 ldr x10,[x19,#16]
 ldrsw x10,[x10]
 cmp x10,#8
 b.gt .Lsw_validate_refuse
 sub x11,x10,x9
 cmp x11,#1
 b.lt .Lsw_validate_refuse
 str x10,[x19,#SW_CONTROLLER_LAST]
 mov x9,#8
 str x9,[x19,#SW_CONTROLLER_FULL_COLUMNS]
 ldr x21,[x19,#24]
 SW_CONSTANT x9,19996
 ldr w10,[x21,x9]
 cmp w10,#112
 b.ne .Lsw_validate_refuse
 str x10,[x19,#SW_CONTROLLER_SAMPLES]
 SW_CONSTANT x9,20004
 ldr w10,[x21,x9]
 cmp w10,#14
 b.ne .Lsw_validate_refuse
 ldr x22,[x19,#120]
 ldr x9,[x22,#352]
 ldr x10,[x22,#792]
 cbnz x9,.Lsw_validate_direct_present
 cbnz x10,.Lsw_validate_refuse
 b .Lsw_validate_output_start
.Lsw_validate_direct_present:
 cbz x10,.Lsw_validate_refuse
.Lsw_validate_output_start:
 adrp x23,.Lsw_output_specs
 add x23,x23,:lo12:.Lsw_output_specs
 mov x24,#11
.Lsw_validate_output:
 ldr x9,[x23]
 add x0,x22,x9
 ldr x10,[x0]
 cbnz x10,.Lsw_validate_output_present
 cmp x9,#352
 b.eq .Lsw_validate_output_next
 cmp x9,#792
 b.eq .Lsw_validate_output_next
 b .Lsw_validate_refuse
.Lsw_validate_output_present:
 ldp x1,x2,[x23,#32]
 ldr x9,[x23,#24]
 cmp x9,#2
 mov x3,#1
 mov x10,#2
 csel x3,x3,x10,eq
 mov x4,#8
 bl .Lsw_descriptor
 cbz w0,.Lsw_validate_refuse
.Lsw_validate_output_next:
 add x23,x23,#48
 subs x24,x24,#1
 b.ne .Lsw_validate_output
 // Only the branch-selecting cosine and integer seed descriptors are consumed.
 ldr x0,[x19,#32]
 mov x1,#8
 mov x2,#0
 mov x3,#1
 mov x4,#8
 bl .Lsw_descriptor
 cbz w0,.Lsw_validate_refuse
 ldr x0,[x19,#32]
 add x0,x0,#552
 mov x1,#8
 mov x2,#0
 mov x3,#1
 mov x4,#4
 bl .Lsw_descriptor
 cbz w0,.Lsw_validate_refuse
 ldr x9,[x19,#32]
 ldr x9,[x9]
 ldr x10,[x19,#SW_CONTROLLER_FIRST]
 sub x10,x10,#1
 ldr x11,[x19,#SW_CONTROLLER_LAST]
 mov x12,#0
.Lsw_validate_daylight:
 ldr x13,[x9,x10,lsl #3]
 ubfx x14,x13,#52,#11
 cmp x14,#2047
 b.eq .Lsw_validate_refuse
 tbnz x13,#63,.Lsw_validate_next_daylight
 cbz x13,.Lsw_validate_next_daylight
 add x12,x12,#1
.Lsw_validate_next_daylight:
 add x10,x10,#1
 cmp x10,x11
 b.lo .Lsw_validate_daylight
 cmp x12,#4
 b.lo .Lsw_validate_refuse
 ldr w9,[x21,#536]
 cmp w9,#1
 b.ne .Lsw_validate_refuse
 ldr x9,[x21,#520]
 cbz x9,.Lsw_validate_refuse
 tbnz x9,#63,.Lsw_validate_refuse
 mov x10,#0x3ff0000000000000
 cmp x9,x10
 b.hi .Lsw_validate_refuse
 ldr x9,[x21,#552]
 cbz x9,.Lsw_validate_refuse
 tbnz x9,#63,.Lsw_validate_refuse
 ubfx x10,x9,#52,#11
 cmp x10,#2047
 b.eq .Lsw_validate_refuse
 fmov d0,x9
 fmov d1,#1.0
 fdiv d0,d1,d0
 fmov x9,d0
 ubfx x9,x9,#52,#11
 cmp x9,#2047
 b.eq .Lsw_validate_refuse
 SW_CONSTANT x9,10928
 ldr x9,[x21,x9]
 cbz x9,.Lsw_validate_refuse
 tst x9,#3
 b.ne .Lsw_validate_refuse
 mov x10,#0
.Lsw_validate_band_map:
 ldr w11,[x9,x10,lsl #2]
 sub w11,w11,#1
 cmp w11,#13
 b.hi .Lsw_validate_refuse
 add x10,x10,#1
 cmp x10,#112
 b.lo .Lsw_validate_band_map
 mov w0,#1
 b .Lsw_validate_return
.Lsw_validate_refuse:
 mov w0,#0
.Lsw_validate_return:
 msr fpsr,x20
 ldp x19,x20,[sp]
 ldp x21,x22,[sp,#16]
 ldp x23,x24,[sp,#32]
 ldp x29,x30,[sp,#48]
 add sp,sp,#64
 ret
.size md2asm_sw_team_validate,.-md2asm_sw_team_validate

// Strict contiguous GNU descriptor guard for the selected geometry.
// x0 descriptor, x1 first extent, x2 second extent, x3 rank, x4 element bytes.
.Lsw_descriptor:
 ldr x8,[x0]
 cbz x8,.Lsw_descriptor_refuse
 sub x9,x4,#1
 tst x8,x9
 b.ne .Lsw_descriptor_refuse
 ldr x8,[x0,#16]
 cmp x8,x4
 b.ne .Lsw_descriptor_refuse
 ldr w8,[x0,#24]
 cbnz w8,.Lsw_descriptor_refuse
 ldrb w8,[x0,#28]
 cmp w8,w3
 b.ne .Lsw_descriptor_refuse
 ldrb w8,[x0,#29]
 cmp x4,#4
 mov w9,#1
 mov w10,#3
 csel w9,w9,w10,eq
 cmp w8,w9
 b.ne .Lsw_descriptor_refuse
 ldr x8,[x0,#32]
 cmp x8,x4
 b.ne .Lsw_descriptor_refuse
 ldr x8,[x0,#40]
 cmp x8,#1
 b.ne .Lsw_descriptor_refuse
 ldr x8,[x0,#48]
 cmp x8,#1
 b.ne .Lsw_descriptor_refuse
 ldr x8,[x0,#56]
 cmp x8,x1
 b.ne .Lsw_descriptor_refuse
 cmp x3,#1
 b.eq .Lsw_descriptor_rank_one
 ldr x8,[x0,#64]
 cmp x8,x1
 b.ne .Lsw_descriptor_refuse
 ldr x8,[x0,#72]
 cmp x8,#1
 b.ne .Lsw_descriptor_refuse
 ldr x8,[x0,#80]
 cmp x8,x2
 b.ne .Lsw_descriptor_refuse
 add x8,x1,#1
 neg x8,x8
 b .Lsw_descriptor_offset
.Lsw_descriptor_rank_one:
 mov x8,#-1
.Lsw_descriptor_offset:
 ldr x9,[x0,#8]
 cmp x8,x9
 b.ne .Lsw_descriptor_refuse
 mov w0,#1
 ret
.Lsw_descriptor_refuse:
 mov w0,#0
 ret

// Same active-column payload with original argument and array origins.
.global SW_PRIVATE_BRIDGE
.hidden SW_PRIVATE_BRIDGE
.type SW_PRIVATE_BRIDGE,%function
SW_PRIVATE_BRIDGE:
 sub sp,sp,#96
 stp x28,x30,[sp,#64]
 mov x28,x0
 ldr x16,[x28,#SW_WORK_ARGUMENTS]
 ldp x8,x9,[x16,#64]
 stp x8,x9,[sp]
 ldp x8,x9,[x16,#80]
 stp x8,x9,[sp,#16]
 ldp x8,x9,[x16,#96]
 stp x8,x9,[sp,#32]
 ldr x8,[x16,#112]
 ldr x9,[x28,#SW_WORK_FLUX]
 stp x8,x9,[sp,#48]
 ldp x0,x1,[x16]
 ldp x2,x3,[x16,#16]
 ldp x4,x5,[x16,#32]
 ldp x6,x7,[x16,#48]
 bl SW_PRIVATE_PARENT
 ldp x28,x30,[sp,#64]
 add sp,sp,#96
 ret
.size SW_PRIVATE_BRIDGE,.-SW_PRIVATE_BRIDGE

.type .Lsw_callback,%function
.Lsw_callback:
 sub sp,sp,#128
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mrs x21,fpcr
 mrs x22,fpsr
 SW_CALL __errno_location,96
 mov x23,x0
 ldr w24,[x23]
 SW_CALL omp_get_thread_num,96
 mov w25,w0
 SW_CALL omp_get_num_threads,96
 mov w26,w0
 cmp x26,#1
 b.lo .Lsw_bad_team
 cmp x26,#MD2ASM_SW_TEAM_REQUESTED
 b.hi .Lsw_bad_team
 cbnz x25,.Lsw_team_size_recorded
 str x26,[x19,#SW_CONTROLLER_ACTUAL_TEAM]
.Lsw_team_size_recorded:
 mov x9,#SW_WORK_BYTES
 madd x20,x25,x9,x19
 add x20,x20,#SW_CONTROLLER_WORKERS
 str x21,[x20,#SW_WORK_ENTRY_FPCR]
 str x22,[x20,#SW_WORK_ENTRY_FPSR]
 str w24,[x20,#SW_WORK_ENTRY_ERRNO]
 str x23,[x20,#SW_WORK_ERRNO_POINTER]
 mov x9,#1
 str x9,[x20,#SW_WORK_SEEN]
 str x26,[x20,#SW_WORK_ACTUAL_TEAM]
 str x25,[x20,#SW_WORK_THREAD_INDEX]
 ldr x9,[x19,#SW_CONTROLLER_FIRST]
 ldr x10,[x19,#SW_CONTROLLER_LAST]
 sub x10,x10,x9
 add x10,x10,#1
 sub x9,x9,#1
 mul x11,x10,x25
 udiv x27,x11,x26
 add x27,x27,x9
 add x11,x25,#1
 mul x11,x10,x11
 udiv x28,x11,x26
 add x28,x28,x9
 str x27,[x20,#SW_WORK_BEGIN]
 str x28,[x20,#SW_WORK_END]
 // No cross-worker numerical dependency precedes this payload.
 msr fpcr,xzr
 msr fpsr,xzr
 ldr w9,[x19,#SW_CONTROLLER_ENTRY_ERRNO]
 str w9,[x23]
 mov x0,x20
 bl SW_PRIVATE_BRIDGE
 mrs x9,fpsr
 str x9,[x20,#SW_WORK_NUMERICAL_FPSR]
 ldr w9,[x23]
 str w9,[x20,#SW_WORK_FINAL_ERRNO]
 b .Lsw_callback_restore
.Lsw_bad_team:
 cbnz x25,.Lsw_callback_restore
 str x26,[x19,#SW_CONTROLLER_ACTUAL_TEAM]
 mov x9,#1
 str x9,[x19,#SW_CONTROLLER_BAD_TEAM]
.Lsw_callback_restore:
 str w24,[x23]
 msr fpcr,x21
 msr fpsr,x22
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#128
 ret
.size .Lsw_callback,.-.Lsw_callback

// Copy raw words, preserving NaN payloads and signed zeros without FP work.
.Lsw_copy_bytes:
 cmp x2,#16
 b.lo .Lsw_copy_tail
.Lsw_copy_pair:
 ldp x3,x4,[x1],#16
 stp x3,x4,[x0],#16
 sub x2,x2,#16
 cmp x2,#16
 b.hs .Lsw_copy_pair
.Lsw_copy_tail:
 cbz x2,.Lsw_copy_return
 ldr x3,[x1]
 str x3,[x0]
.Lsw_copy_return:
 ret

#ifdef MD2ASM_SW_TEAM_RECORD
.global md2asm_test_sw_team_context
.type md2asm_test_sw_team_context,%function
md2asm_test_sw_team_context:
 adrp x0,.Lsw_last_context
 add x0,x0,:lo12:.Lsw_last_context
 ret
.size md2asm_test_sw_team_context,.-md2asm_test_sw_team_context
.bss
.balign 64
.Lsw_last_context: .zero SW_CONTROLLER_BYTES
#endif
.section .rodata
.p2align 3
// Flux member byte offset, owner bytes, payload offset, kind, first/second extents.
// Kind0 profiles,1 surface spectra,2 cloud cover. Both direct profiles may be absent.
.Lsw_output_specs:
 .quad 176,1280,252016,0,8,20
 .quad 264,1280,253296,0,8,20
 .quad 352,1280,254576,0,8,20
 .quad 616,1280,255856,0,8,20
 .quad 704,1280,257136,0,8,20
 .quad 792,1280,258416,0,8,20
 .quad 2176,7168,259696,1,112,8
 .quad 2264,7168,266864,1,112,8
 .quad 2352,7168,274032,1,112,8
 .quad 2440,7168,281200,1,112,8
 .quad 3208,64,288368,2,8,0
.bss
.balign 8
.Lsw_cached_arena: .zero 8
.section .note.GNU-stack,"",%progbits

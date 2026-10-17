// Complete cloud-column controller with the original 76-pointer public ABI.
// Physics: formulations/openifs/physics/cloud_water_and_rain.md.
// Contract: skills/md2asm/references/openifs/cloud_microphysics_contract.md.
// G is the full column count; N is the level count.
// The default four-worker context has 1024 bytes, aligned to 64 bytes.
// Its arguments occupy bytes 0..607 and worker records start at byte 768.
// The eight-worker selection uses 1344 bytes and worker records from byte 832;
// argument and public-state offsets stay fixed, as defined below.
// Each worker owns a heap with a 64-byte counter prefix. FAST, WIDE and EXP
// counts occupy offsets 0, 8 and 16; the numerical scratch starts at byte 64.
// x28 holds that prefix through the private mathematical call graph.
// Preserve x18 and all standard saved registers. The complete G-column stride,
// original guards and serial fallback remain unchanged. Two startup barriers
// separate thread creation, the once-only whole-owner clear and column work.
// The controller joins flags and counts after all workers return, preserving
// the caller's FPCR and errno and excluding status from runtime services.
.arch armv8.2-a
// Capacity changes controller storage only; the numerical range is unchanged.
#ifndef MD2ASM_CLOUD_TEAM_CAPACITY
#define MD2ASM_CLOUD_TEAM_CAPACITY 4
#endif
#if MD2ASM_CLOUD_TEAM_CAPACITY == 4
#define CLOUD_TEAM_FRAME_BYTES 2048
#define CLOUD_TEAM_CONTEXT_BYTES 1024
#define CLOUD_TEAM_CLEAR_PAIRS 26
#define CLOUD_TEAM_RECORD_PAIRS 64
#define CLOUD_TEAM_WORKER_BASE 768
#define CLOUD_TEAM_TOTAL_FAST 720
#define CLOUD_TEAM_TOTAL_WIDE 728
#define CLOUD_TEAM_TOTAL_EXP 736
#elif MD2ASM_CLOUD_TEAM_CAPACITY == 8
#define CLOUD_TEAM_FRAME_BYTES 2560
#define CLOUD_TEAM_CONTEXT_BYTES 1344
#define CLOUD_TEAM_CLEAR_PAIRS 46
#define CLOUD_TEAM_RECORD_PAIRS 84
#define CLOUD_TEAM_WORKER_BASE 832
#define CLOUD_TEAM_TOTAL_FAST 752
#define CLOUD_TEAM_TOTAL_WIDE 760
#define CLOUD_TEAM_TOTAL_EXP 768
#else
#error Cloud team capacity must be four or eight.
#endif
#ifndef MD2ASM_CLOUD_TEAM_REQUESTED
#define MD2ASM_CLOUD_TEAM_REQUESTED MD2ASM_CLOUD_TEAM_CAPACITY
#endif
.text
.macro CLOUD_TEAM_CALL name, save=640
 bl \name
 ldr x18,[sp,#\save]
.endm
.equ P_LAERICEAUTO, 1128
.equ P_LAERICESED, 1124
.equ P_LAERLIQAUTOLSP, 1108
.equ P_LAERLIQCOLL, 1120
.equ P_LCLDBUDC, 1048
.equ P_LCLDBUDGET, 1044
.equ P_LCLDBUDI, 1056
.equ P_LCLDBUDL, 1052
.equ P_LCLDBUDT, 1060
.equ P_LCLDBUD_VERTINT, 1068
.equ P_LCLOUD_INHOMOG, 400
.equ P_NCLDTOP, 1076
.equ P_NSSOPT, 1072
.p2align 4
.global md2asm_cloudsc_complete
.type md2asm_cloudsc_complete,%function
md2asm_cloudsc_complete:
 mov x17,sp
 sub sp,sp,#CLOUD_TEAM_FRAME_BYTES
 add x16,sp,#544
 stp x19,x20,[x16]
 stp x21,x22,[x16,#16]
 stp x23,x24,[x16,#32]
 stp x25,x26,[x16,#48]
 stp x27,x28,[x16,#64]
 stp x29,x30,[x16,#80]
 str x18,[sp,#640]
 mov x29,sp
 add x19,sp,#831
 and x19,x19,#0xffffffffffffffc0
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 mov x9,x17
 add x10,x19,#64
 mov x11,#68
.Lcloud_team_save_arguments:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Lcloud_team_save_arguments
 add x9,x19,#608
 mov x10,#CLOUD_TEAM_CLEAR_PAIRS
.Lcloud_team_zero_context:
 stp xzr,xzr,[x9],#16
 subs x10,x10,#1
 b.ne .Lcloud_team_zero_context
 mrs x9,fpcr
 mrs x10,fpsr
 str x9,[x19,#632]
 str x10,[x19,#640]
 mov x25,#0
 ldr x28, [x19]
 mrs x9, fpcr
 cbnz x9, .Lcloud_team_cleanup
 ldr x9, [x19, #72]
 ldr w23, [x9]
 cmp w23, #1
 b.lt .Lcloud_team_cleanup
 cmp w23, #4096
 b.gt .Lcloud_team_cleanup
 ldr x9, [x19, #80]
 ldr w22, [x9]
 cmp w22, #2
 b.lt .Lcloud_team_cleanup
 cmp w22, #256
 b.gt .Lcloud_team_cleanup
 ldr x9, [x19, #56]
 ldr w10, [x9]
 cmp w10, #1
 b.ne .Lcloud_team_cleanup
 cmp w10, w23
 b.gt .Lcloud_team_cleanup
 ldr x9, [x19, #64]
 ldr w11, [x9]
 cmp w11, #0
 b.lt .Lcloud_team_cleanup
 cmp w11, w23
 b.gt .Lcloud_team_cleanup
 str x11,[x19,#624]
 ldr w9, [x28, #P_NCLDTOP]
 cmp w9, #2
 b.lt .Lcloud_team_cleanup
 cmp w9, w22
 b.gt .Lcloud_team_cleanup
 ldr w9, [x28, #P_NSSOPT]
 cmp w9, #1
 b.ne .Lcloud_team_cleanup
 // Qualify the immutable actual route before any returned storage changes.
 ldr w9, [x28, #P_LAERICEAUTO]
 ldr w10, [x28, #P_LAERICESED]
 orr w9, w9, w10
 ldr w10, [x28, #P_LAERLIQAUTOLSP]
 orr w9, w9, w10
 ldr w10, [x28, #P_LAERLIQCOLL]
 orr w9, w9, w10
 ldr w10, [x28, #P_LCLOUD_INHOMOG]
 orr w9, w9, w10
 ldr w10, [x28, #P_LCLDBUDGET]
 orr w9, w9, w10
 ldr w10, [x28, #P_LCLDBUDC]
 orr w9, w9, w10
 ldr w10, [x28, #P_LCLDBUDL]
 orr w9, w9, w10
 ldr w10, [x28, #P_LCLDBUDI]
 orr w9, w9, w10
 ldr w10, [x28, #P_LCLDBUDT]
 orr w9, w9, w10
 ldr w10, [x28, #P_LCLDBUD_VERTINT]
 orr w9, w9, w10
 cbnz w9, .Lcloud_team_cleanup
 ldr x9, [x19, #32]
 ldr w10, [x9, #104]
 ldr w11, [x9, #436]
 orr w10, w10, w11
 cbnz w10, .Lcloud_team_cleanup
 ldr x9, [x19, #48]
 ldr w10, [x9]
 cbnz w10, .Lcloud_team_cleanup
 ldr w10, [x9, #216]
 cbnz w10, .Lcloud_team_cleanup
 ldr x9, [x19, #600]
 ldr w10, [x9]
 cbnz w10, .Lcloud_team_cleanup
 adrp x9, :got:__yommp0_MOD_lscmec
 ldr x9, [x9, :got_lo12:__yommp0_MOD_lscmec]
 ldr w10, [x9]
 cbnz w10, .Lcloud_team_cleanup
 ldr x9, [x19, #88]
 ldr d0, [x9]
 fcmp d0, #0.0
 b.le .Lcloud_team_cleanup
 str x23,[x19,#608]
 str x22,[x19,#616]
 ldr x24,[x19,#624]
 cmp x24,#MD2ASM_CLOUD_TEAM_CAPACITY
 b.lt .Lcloud_team_cleanup
 CLOUD_TEAM_CALL __errno_location
 str x0,[x19,#648]
 ldr w9,[x0]
 str x9,[x19,#656]
 CLOUD_TEAM_CALL omp_in_parallel
 cbnz w0,.Lcloud_team_cleanup
 mov x21,#0
.Lcloud_team_allocate:
 add x0,x22,#1
 mov x1,#320
 mul x0,x0,x1
 add x0,x0,#64
 mov x1,#1
 CLOUD_TEAM_CALL calloc
 cbz x0,.Lcloud_team_cleanup
 add x9,x19,#688
 str x0,[x9,x21,lsl #3]
 add x21,x21,#1
 cmp x21,#MD2ASM_CLOUD_TEAM_CAPACITY
 b.ne .Lcloud_team_allocate
 adr x0,.Lcloud_team_callback
 mov x1,x19
 mov w2,#MD2ASM_CLOUD_TEAM_REQUESTED
 mov w3,#0
 CLOUD_TEAM_CALL GOMP_parallel
 ldr x9,[x19,#672]
 cbnz x9,.Lcloud_team_cleanup
 ldr x26,[x19,#664]
 cmp x26,#1
 b.lt .Lcloud_team_cleanup
 cmp x26,#MD2ASM_CLOUD_TEAM_CAPACITY
 b.gt .Lcloud_team_cleanup
 ldr x24,[x19,#640]
 add x20,x19,#CLOUD_TEAM_WORKER_BASE
 mov x21,#0
.Lcloud_team_union:
 ldr x9,[x20,#24]
 orr x24,x24,x9
 add x20,x20,#64
 add x21,x21,#1
 cmp x21,x26
 b.lo .Lcloud_team_union
 // Joined workers own disjoint counters. Merge each global owner once.
 mov x10,#0
 mov x11,#0
 mov x12,#0
 add x13,x19,#688
 mov x14,#MD2ASM_CLOUD_TEAM_CAPACITY
.Lcloud_private_counter_union:
 ldr x9,[x13],#8
 ldp x15,x16,[x9]
 add x10,x10,x15
 add x11,x11,x16
 ldr x15,[x9,#16]
 add x12,x12,x15
 subs x14,x14,#1
 b.ne .Lcloud_private_counter_union
 str x10,[x19,#CLOUD_TEAM_TOTAL_FAST]
 str x11,[x19,#CLOUD_TEAM_TOTAL_WIDE]
 str x12,[x19,#CLOUD_TEAM_TOTAL_EXP]
 adrp x9,:got:md2asm_product_sum_fast_calls
 ldr x9,[x9,:got_lo12:md2asm_product_sum_fast_calls]
 ldr x15,[x9]
 add x15,x15,x10
 str x15,[x9]
 adrp x9,:got:md2asm_product_sum_wide_calls
 ldr x9,[x9,:got_lo12:md2asm_product_sum_wide_calls]
 ldr x15,[x9]
 add x15,x15,x11
 str x15,[x9]
 adrp x9,:got:md2asm_exponential_native_calls_storage
 ldr x9,[x9,:got_lo12:md2asm_exponential_native_calls_storage]
 ldr x15,[x9]
 add x15,x15,x12
 str x15,[x9]
 mov x25,#1
.Lcloud_team_cleanup:
#ifdef MD2ASM_CLOUD_TEAM_RECORD
 adrp x9,.Lcloud_team_last_context
 add x9,x9,:lo12:.Lcloud_team_last_context
 mov x10,x19
 mov x11,#CLOUD_TEAM_RECORD_PAIRS
.Lcloud_team_record_context:
 ldp x12,x13,[x10],#16
 stp x12,x13,[x9],#16
 subs x11,x11,#1
 b.ne .Lcloud_team_record_context
#endif
 mov x21,#0
.Lcloud_team_free:
 add x9,x19,#688
 ldr x0,[x9,x21,lsl #3]
 cbz x0,.Lcloud_team_next_free
 CLOUD_TEAM_CALL free
.Lcloud_team_next_free:
 add x21,x21,#1
 cmp x21,#MD2ASM_CLOUD_TEAM_CAPACITY
 b.ne .Lcloud_team_free
 ldr x9,[x19,#632]
 msr fpcr,x9
 cbnz x25,.Lcloud_team_commit_numeric_flags
 ldr x24,[x19,#640]
.Lcloud_team_commit_numeric_flags:
 msr fpsr,x24
 ldr x9,[x19,#648]
 cbz x9,.Lcloud_team_errno_done
 ldr w10,[x19,#656]
 str w10,[x9]
.Lcloud_team_errno_done:
 cbnz x25,.Lcloud_team_return
 // No worker payload ran. Replay the complete original public entry.
 add x10,x19,#64
 mov x9,#0
.Lcloud_team_serial_arguments:
 ldr x11,[x10,x9]
 str x11,[sp,x9]
 add x9,x9,#8
 cmp x9,#544
 b.ne .Lcloud_team_serial_arguments
 ldp x0,x1,[x19]
 ldp x2,x3,[x19,#16]
 ldp x4,x5,[x19,#32]
 ldp x6,x7,[x19,#48]
 CLOUD_TEAM_CALL md2asm_cloudsc_serial_body
.Lcloud_team_return:
 ldr x18,[sp,#640]
 add x16,sp,#544
 ldp x19,x20,[x16]
 ldp x21,x22,[x16,#16]
 ldp x23,x24,[x16,#32]
 ldp x25,x26,[x16,#48]
 ldp x27,x28,[x16,#64]
 ldp x29,x30,[x16,#80]
 add sp,sp,#CLOUD_TEAM_FRAME_BYTES
 ret
.size md2asm_cloudsc_complete,.-md2asm_cloudsc_complete

// The runtime supplies one uniform team size T and unique indices 0..T-1.
// Only supported teams
// enter the startup barrier. No numerical or returned output precedes it.
.type .Lcloud_team_callback,%function
.Lcloud_team_callback:
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
 CLOUD_TEAM_CALL __errno_location,96
 mov x23,x0
 ldr w24,[x23]
 CLOUD_TEAM_CALL omp_get_thread_num,96
 mov w25,w0
 CLOUD_TEAM_CALL omp_get_num_threads,96
 mov w26,w0
 cmp x26,#1
 b.lo .Lcloud_team_bad_T
 cmp x26,#MD2ASM_CLOUD_TEAM_CAPACITY
 b.hi .Lcloud_team_bad_T
 cbnz x25,.Lcloud_team_T_recorded
 str x26,[x19,#664]
.Lcloud_team_T_recorded:
 add x20,x19,#CLOUD_TEAM_WORKER_BASE
 add x20,x20,x25,lsl #6
 mov x9,#1
 str x9,[x20]
 str x26,[x20,#8]
 str x25,[x20,#16]
 str x23,[x20,#48]
 ldr x9,[x19,#624]
 mul x10,x9,x25
 udiv x27,x10,x26
 add x10,x25,#1
 mul x10,x9,x10
 udiv x28,x10,x26
 str x27,[x20,#32]
 str x28,[x20,#40]
 CLOUD_TEAM_CALL GOMP_barrier,96
 // The controller thread clears once only after every worker has started.
 cbnz x25,.Lcloud_team_clear_done
 ldr x9,[x19,#472]
 ldr x10,[x19,#608]
.Lcloud_team_rain_clear:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lcloud_team_rain_clear
.Lcloud_team_clear_done:
 CLOUD_TEAM_CALL GOMP_barrier,96
 msr fpcr,xzr
 msr fpsr,xzr
 mov x0,x19
 mov x1,x27
 mov x2,x28
 add x9,x19,#688
 ldr x28,[x9,x25,lsl #3]
 add x3,x28,#64
 mov x4,x23
 bl md2asm_cloudsc_private_counter_range
 mrs x9,fpsr
 str x9,[x20,#24]
 mrs x9,fpcr
 str x9,[x20,#56]
 b .Lcloud_team_worker_restore
.Lcloud_team_bad_T:
 cbnz x25,.Lcloud_team_worker_restore
 str x26,[x19,#664]
 mov x9,#1
 str x9,[x19,#672]
.Lcloud_team_worker_restore:
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
.size .Lcloud_team_callback,.-.Lcloud_team_callback
#ifdef MD2ASM_CLOUD_TEAM_RECORD
.global md2asm_test_cloud_team_context
.type md2asm_test_cloud_team_context,%function
md2asm_test_cloud_team_context:
 adrp x0,.Lcloud_team_last_context
 add x0,x0,:lo12:.Lcloud_team_last_context
 ret
.size md2asm_test_cloud_team_context,.-md2asm_test_cloud_team_context
.bss
.balign 64
.Lcloud_team_last_context: .zero CLOUD_TEAM_CONTEXT_BYTES
#endif
.section .note.GNU-stack,"",%progbits

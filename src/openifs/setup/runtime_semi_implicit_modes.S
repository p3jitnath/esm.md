/* Runtime SUSI mode ownership from the semi_implicit_mode_setup contract.
 * The caller keeps seven pressure arrays and the live vertical records.
 * x0 Geometry, x1 mapped bytes, x2 MODEL, x3 mapped bytes, x4 new heap cap.
 * Allocation and calculation tail-call unchanged selected mode bodies.
 * Release takes MODEL and its mapped bytes. Status returns in w0.
 * Use levels one through 255 and the declared public matrix providers. */
.arch armv8.2-a
.text
.macro SUSI_MODE_ADMISSION
 cbz x0,.Lsusi_bad
 cbz x2,.Lsusi_bad
 orr x9,x0,x2
 tst x9,#7
 b.ne .Lsusi_bad
 mov x9,#20400
 cmp x1,x9
 b.lo .Lsusi_bad
 adds x10,x0,x9
 b.cs .Lsusi_bad
 movz x9,#(4275088 & 65535)
 movk x9,#(4275088 >> 16),lsl#16
 cmp x3,x9
 b.lo .Lsusi_bad
 adds x11,x2,x9
 b.cs .Lsusi_bad
 cmp x10,x2
 b.ls .Lsusi_disjoint\@
 cmp x11,x0
 b.hi .Lsusi_bad
.Lsusi_disjoint\@:
 mov x9,#1
 lsl x9,x9,#36
 cmp x4,x9
 b.hi .Lsusi_bad
 mov x9,#5224
 ldr w9,[x0,x9]
 sub w10,w9,#1
 cmp w10,#254
 b.hi .Lsusi_bad
.endm
.p2align 4
.global md2asm_allocate_runtime_susi_mode_storage
.type md2asm_allocate_runtime_susi_mode_storage,%function
md2asm_allocate_runtime_susi_mode_storage:
 SUSI_MODE_ADMISSION
 mul x10,x9,x9
 lsl x10,x10,#5
 add x10,x10,x9,lsl#3
 cmp x10,x4
 b.hi .Lsusi_bad
 b md2asm_allocate_semi_implicit_mode_storage
.size md2asm_allocate_runtime_susi_mode_storage,.-md2asm_allocate_runtime_susi_mode_storage
.p2align 4
.global md2asm_initialize_runtime_susi_modes
.type md2asm_initialize_runtime_susi_modes,%function
md2asm_initialize_runtime_susi_modes:
 SUSI_MODE_ADMISSION
 mul x10,x9,x9
 lsl x10,x10,#6
 mov x11,#136
 madd x10,x9,x11,x10
 add x10,x10,#128
 cmp x10,x4
 b.hi .Lsusi_bad
 b md2asm_initialize_semi_implicit_modes
.size md2asm_initialize_runtime_susi_modes,.-md2asm_initialize_runtime_susi_modes
.p2align 4
.global md2asm_release_runtime_susi_mode_storage
.type md2asm_release_runtime_susi_mode_storage,%function
md2asm_release_runtime_susi_mode_storage:
 b md2asm_release_semi_implicit_mode_storage
.size md2asm_release_runtime_susi_mode_storage,.-md2asm_release_runtime_susi_mode_storage
.Lsusi_bad:
 mov w0,#2
 ret
.section .note.GNU-stack,"",%progbits

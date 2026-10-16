/* Contract: skills/md2asm/references/openifs/setup/loop_process_bindings.md.
 * int init(x0 live owned int32 process count, x1 capacity>=4). */
.text
.p2align 2
.global md2asm_initialize_owned_process_count
.type md2asm_initialize_owned_process_count,%function
md2asm_initialize_owned_process_count:
 cbz x0,.Lcount_bad
 tst x0,#3
 b.ne .Lcount_bad
 cmp x1,#4
 b.lo .Lcount_bad
 adds x2,x0,#4
 b.cs .Lcount_bad
 ldr w2,[x0]
 cmp w2,#1
 b.ne .Lcount_bad
 adrp x3,.Lowned_process_count
 str w2,[x3,:lo12:.Lowned_process_count]
 mov w0,#0
 ret
.Lcount_bad:
 mov w0,#2
 ret
.size md2asm_initialize_owned_process_count,.-md2asm_initialize_owned_process_count
.bss
.p2align 2
.Lowned_process_count:
.global md2asm_owned_process_count
.type md2asm_owned_process_count,%object
md2asm_owned_process_count:.zero 4
.size md2asm_owned_process_count,4
.global __yommp0_MOD_nproc
.type __yommp0_MOD_nproc,%object
.set __yommp0_MOD_nproc,md2asm_owned_process_count
.size __yommp0_MOD_nproc,4
.section .note.GNU-stack,"",%progbits

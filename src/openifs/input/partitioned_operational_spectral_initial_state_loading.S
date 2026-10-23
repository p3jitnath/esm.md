/* Contract: skills/md2asm/references/openifs/input/partitioned_operational_spectral_loading.md. Complete selected file-loading utility.
 * x0 path,x1 live spectral2992,x2 recordcap,x3 writable orographyflag4.
 * Selected field/configuration obligations belong to the owned caller. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_load_partitioned_operational_spectral_initial_state
.type md2asm_load_partitioned_operational_spectral_initial_state,%function
md2asm_load_partitioned_operational_spectral_initial_state:
 sub sp,sp,#160
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mrs x9,fpcr
 str x9,[sp,#88]
 mrs x10,fpsr
 str x10,[sp,#96]
 mov x19,x0
 mov x20,x1
 mov x25,x2
 mov x21,x3
 mov x22,#0
 mov x23,#0
 mov w26,#1
 cbnz x9,.Lpsload_return
 cbz x19,.Lpsload_return
 cbz x20,.Lpsload_return
 cbz x21,.Lpsload_return
 tst x20,#7
 b.ne .Lpsload_return
 tst x21,#3
 b.ne .Lpsload_return
 cmp x25,#2992
 b.lo .Lpsload_return
 adds x9,x20,#2992
 b.cs .Lpsload_return
 adds x10,x21,#4
 b.cs .Lpsload_return
 cmp x21,x9
 b.hs .Lpsload_flag_separate
 cmp x20,x10
 b.lo .Lpsload_return
.Lpsload_flag_separate:
 mov x9,#0
.Lpsload_path:
 ldrb w10,[x19,x9]
 add x9,x9,#1
 cbz w10,.Lpsload_path_end
 cmp x9,#4096
 b.lo .Lpsload_path
 b .Lpsload_return
.Lpsload_path_end:
 cmp x9,#1
 b.eq .Lpsload_return
 adds x10,x19,x9
 b.cs .Lpsload_return
 adds x11,x21,#4
 b.cs .Lpsload_return
 cmp x21,x10
 b.hs .Lpsload_path_flag_separate
 cmp x19,x11
 b.lo .Lpsload_return
.Lpsload_path_flag_separate:
 bl __errno_location
 mov x23,x0
 ldr w24,[x23]
 ldr x0,.Lpsload_scratch_bytes
 bl malloc
 mov x22,x0
 mov w26,#3
 cbz x22,.Lpsload_return
 mov x0,x19
 mov x1,x22
 ldr x2,.Lpsload_values_bytes
 add x3,x22,x2
 mov w4,#9912
 add x5,sp,#112
 bl md2asm_read_operational_initial_spectral_fields
 add w26,w0,#10
 cbnz w0,.Lpsload_cleanup
 mov x0,x22
 ldr x1,.Lpsload_values_bytes
 add x2,x22,x1
 mov w3,#9912
 mov x4,x20
 mov x5,x25
 bl md2asm_place_partitioned_operational_spectral_fields
 add w26,w0,#20
 cbnz w0,.Lpsload_cleanup
 mov w9,#1
 str w9,[x21]
 mov w26,#0
.Lpsload_cleanup:
 mov x0,x22
 bl free
.Lpsload_return:
 cbz x23,.Lpsload_restore_fp
 str w24,[x23]
.Lpsload_restore_fp:
 ldr x9,[sp,#88]
 msr fpcr,x9
 ldr x9,[sp,#96]
 msr fpsr,x9
 mov w0,w26
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldr x18,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.size md2asm_load_partitioned_operational_spectral_initial_state,.-md2asm_load_partitioned_operational_spectral_initial_state
.section .rodata
.p2align 3
.Lpsload_values_bytes: .quad 5417502720
.Lpsload_scratch_bytes: .quad 5417512632
.section .note.GNU-stack,"",%progbits

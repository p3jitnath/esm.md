/* Writer control state from SUGRIB and the source I/O-server default.
 * The caller retains all 64 bytes of this owner through all output steps.
 * Contract skills/md2asm/references/openifs/output/runtime_fullpos_file_writers.md.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_runtime_grib_writer_state
.type md2asm_initialize_runtime_grib_writer_state,%function
md2asm_initialize_runtime_grib_writer_state:
 cbz x0,.Lstate_bad
 cbz x1,.Lstate_bad
 cmp x2,#64
 b.ne .Lstate_bad
 tst x1,#7
 b.ne .Lstate_bad
 ldr w9,[x0,#544]
 cmp w9,#15
 b.ne .Lstate_bad
 ldr w10,[x0,#16]
 cmp w10,#1
 b.ne .Lstate_bad
 mov x11,#0
.Lstate_fresh:
 ldr x12,[x1,x11]
 cbnz x12,.Lstate_bad
 add x11,x11,#8
 cmp x11,#64
 b.ne .Lstate_fresh
 adrp x9,.Lprevious_codes
 add x9,x9,:lo12:.Lprevious_codes
 ldp x11,x12,[x9]
 stp x11,x12,[x1,#16]
 ldr w11,[x9,#16]
 str w11,[x1,#32]
 stp xzr,xzr,[x1,#40]
 str wzr,[x1,#36]
 str wzr,[x1,#56]
 str w10,[x1,#60]
 mov x9,#1
 str x9,[x1,#8]
 movz x9,#0x4752
 movk x9,#0x4257,lsl#16
 movk x9,#0x5354,lsl#32
 movk x9,#1,lsl#48
 str x9,[x1]
 mov w0,#0
 ret
.size md2asm_initialize_runtime_grib_writer_state,.-md2asm_initialize_runtime_grib_writer_state
.p2align 4
.global md2asm_update_runtime_last_physics_output_steps
.type md2asm_update_runtime_last_physics_output_steps,%function
md2asm_update_runtime_last_physics_output_steps:
 cbz x0,.Lstate_bad
 cbz x1,.Lstate_bad
 cmp x3,#1639
 b.hi .Lstate_bad
 cbz x3,.Lupdate_valid_payload
 cbz x2,.Lstate_bad
.Lupdate_valid_payload:
 movz x9,#0x4752
 movk x9,#0x4257,lsl#16
 movk x9,#0x5354,lsl#32
 movk x9,#1,lsl#48
 ldr x10,[x0]
 cmp x10,x9
 b.ne .Lstate_bad
 ldr x9,[x0,#8]
 cmp x9,#1
 b.ne .Lstate_bad
 ldr w10,[x1]
 cmp w10,#576
 b.hi .Lstate_bad
 mov x11,#0
.Lupdate_code:
 cmp x11,x3
 b.eq .Lstate_ok
 ldr w12,[x2,x11,lsl#2]
 mov x13,#0
 add x14,x0,#16
.Lupdate_match:
 ldr w15,[x14,x13,lsl#2]
 cmp w15,w12
 b.ne .Lupdate_next
 add x16,x0,#36
 str w10,[x16,x13,lsl#2]
.Lupdate_next:
 add x13,x13,#1
 cmp x13,#5
 b.ne .Lupdate_match
 add x11,x11,#1
 b .Lupdate_code
.Lstate_ok:
 mov w0,#0
 ret
.size md2asm_update_runtime_last_physics_output_steps,.-md2asm_update_runtime_last_physics_output_steps
.p2align 4
.global md2asm_release_runtime_grib_writer_state
.type md2asm_release_runtime_grib_writer_state,%function
md2asm_release_runtime_grib_writer_state:
 cbz x0,.Lstate_bad
 stp xzr,xzr,[x0]
 stp xzr,xzr,[x0,#16]
 stp xzr,xzr,[x0,#32]
 stp xzr,xzr,[x0,#48]
 mov w0,#0
 ret
.Lstate_bad:
 mov w0,#2
 ret
.size md2asm_release_runtime_grib_writer_state,.-md2asm_release_runtime_grib_writer_state
.section .rodata
.p2align 3
.Lprevious_codes:
 .word 201,202,49,228226,228227
.bss
.p2align 4
.global md2asm_owned_runtime_grib_writer_state64
.type md2asm_owned_runtime_grib_writer_state64,%object
md2asm_owned_runtime_grib_writer_state64: .zero 64
.size md2asm_owned_runtime_grib_writer_state64,64
.section .note.GNU-stack,"",%progbits

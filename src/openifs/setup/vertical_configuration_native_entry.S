/* Original two-pointer SUCVER_GEOM entry for an empty NAMCVER group.
 * Contract: skills/md2asm/references/openifs/setup/vertical_coordinate_configuration.md.
 * x0 writable TCVER, x1 input logical LDNHDYN_GEOM.
 * Live LECMWF/LR2D data words are explicit compatibility inputs.
 * No original callable, constructor, type descriptor or vtable is used.
 */
.arch armv8.2-a
.text
.p2align 4
.global __yomcver_MOD_sucver_geom
.type __yomcver_MOD_sucver_geom,%function
__yomcver_MOD_sucver_geom:
 sub sp,sp,#112
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,#0
 mov w21,#-1
 mrs x9,fpcr
 str x9,[sp,#80]
 mrs x9,fpsr
 str x9,[sp,#88]
 cbz x19,.Lvertical_native_fail
 tst x19,#7
 b.ne .Lvertical_native_fail
 cbz x1,.Lvertical_native_fail
 tst x1,#3
 b.ne .Lvertical_native_fail
 ldr w9,[x1]
 cmp w9,#1
 b.hi .Lvertical_native_fail
 str w9,[sp,#100]
 adrp x9,:got:__yomct0_MOD_lecmwf
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lecmwf]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lvertical_native_fail
 str w9,[sp,#104]
 adrp x9,:got:__yomct0_MOD_lr2d
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lr2d]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lvertical_native_fail
 str w9,[sp,#108]
 bl __errno_location
 mov x24,x0
 ldr w9,[x24]
 str w9,[sp,#96]
 movz x0,#1
 movk x0,#4,lsl#16
 bl malloc
 cbz x0,.Lvertical_native_fail
 mov x20,x0
 adr x0,.Lvertical_native_file
 mov w1,#0
 mov w2,#0
 bl open
 tbnz w0,#31,.Lvertical_native_fail
 mov w21,w0
 mov x22,#0
.Lvertical_native_read:
 mov w0,w21
 add x1,x20,x22
 movz x2,#1
 movk x2,#4,lsl#16
 sub x2,x2,x22
 bl read
 tbnz x0,#63,.Lvertical_native_read_error
 cbz x0,.Lvertical_native_read_done
 add x22,x22,x0
 movz x9,#1
 movk x9,#4,lsl#16
 cmp x22,x9
 b.hs .Lvertical_native_fail
 b .Lvertical_native_read
.Lvertical_native_read_error:
 ldr w9,[x24]
 cmp w9,#4
 b.eq .Lvertical_native_read
 b .Lvertical_native_fail
.Lvertical_native_read_done:
 mov w0,w21
 bl close
 cbnz w0,.Lvertical_native_fail
 mov w21,#-1
 mov x0,x20
 mov x1,x22
 bl md2asm_empty_vertical_configuration_group
 cbnz w0,.Lvertical_native_fail
 mov x0,x20
 bl free
 mov x20,#0
 /* Successful original NAMCVER input clears errno; preserve that boundary. */
 mov w9,#0
 str w9,[x24]
 ldr x9,[sp,#80]
 msr fpcr,x9
 ldr x9,[sp,#88]
 msr fpsr,x9
 ldr x18,[sp,#72]
 mov x0,x19
 ldr w1,[sp,#104]
 ldr w2,[sp,#100]
 ldr w3,[sp,#108]
 bl md2asm_initialize_vertical_configuration
 cbnz w0,.Lvertical_native_fail
 adrp x9,.Lvertical_native_count
 add x9,x9,:lo12:.Lvertical_native_count
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.Lvertical_native_fail:
 tbnz w21,#31,.Lvertical_native_free
 mov w0,w21
 bl close
.Lvertical_native_free:
 cbz x20,.Lvertical_native_exit
 mov x0,x20
 bl free
.Lvertical_native_exit:
 mov w0,#121
 bl _exit
 brk #0
.size __yomcver_MOD_sucver_geom,.-__yomcver_MOD_sucver_geom
.p2align 4
.global md2asm_vertical_configuration_native_count_get
.type md2asm_vertical_configuration_native_count_get,%function
md2asm_vertical_configuration_native_count_get:
 adrp x9,.Lvertical_native_count
 ldr x0,[x9,:lo12:.Lvertical_native_count]
 ret
.size md2asm_vertical_configuration_native_count_get,.-md2asm_vertical_configuration_native_count_get
.Lvertical_native_file: .asciz "fort.4"
.bss
.p2align 3
.Lvertical_native_count: .zero 8
.section .note.GNU-stack,"",%progbits

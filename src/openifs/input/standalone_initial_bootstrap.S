/* Contract: skills/md2asm/references/openifs/input/standalone_initial_bootstrap.md. */
/* Standalone selected T21 spectral and upper-air input, revision 2.
 * Own entry, configuration, contexts, loading, output and release are assembly.
 * External services are libc process/heap/I/O and ecCodes file decoding.
 * This input checkpoint does not run a forecast. */
.arch armv8.2-a
.text
.p2align 2
.global _start
.type _start,%function
_start:
 mov x29,xzr
 mov x30,xzr
 mov x5,x0
 ldr x1,[sp]
 add x2,sp,#8
 mov x6,sp
 adrp x0,main
 add x0,x0,:lo12:main
 mov x3,xzr
 mov x4,xzr
 bl __libc_start_main
 bl abort
.size _start,.-_start

.p2align 2
.global main
.type main,%function
main:
 sub sp,sp,#112
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
 mov x19,x1
 mov x20,xzr
 mov x21,xzr
 mov x26,xzr
 mov w23,#64
 cmp w0,#7
 b.ne .Lmain_cleanup
 mov w23,#65
 mrs x9,fpcr
 cbnz x9,.Lmain_cleanup
 adrp x24,.Lheaders
 add x24,x24,:lo12:.Lheaders
 ldp x0,x1,[x19,#8]
 mov x2,x24
 mov x3,#5232
 bl md2asm_read_initial_model_headers
 add w23,w0,#80
 cbnz w0,.Lmain_cleanup
 ldr w9,[x24]
 ldr w10,[x24,#16]
 mov w23,#66
 cmp w9,#21
 b.ne .Lmain_cleanup
 cmp w10,#19
 b.ne .Lmain_cleanup
 ldr w9,[x24,#8]
 cmp w9,#32
 b.ne .Lmain_cleanup
 ldr w9,[x24,#12]
 cmp w9,#64
 b.ne .Lmain_cleanup
 ldr w9,[x24,#32]
 ldr w10,[x24,#44]
 cmp w9,w10
 b.ne .Lmain_cleanup
 ldr w9,[x24,#36]
 ldr w10,[x24,#48]
 cmp w9,w10
 b.ne .Lmain_cleanup
 ldr w9,[x24,#40]
 ldr w10,[x24,#52]
 cmp w9,w10
 b.ne .Lmain_cleanup
 add x0,x24,#96
 add x1,x24,#2152
 adrp x2,.Lvertical_owner
 add x2,x2,:lo12:.Lvertical_owner
 adrp x3,.Lvertical_configuration
 add x3,x3,:lo12:.Lvertical_configuration
 bl md2asm_create_vertical_startup_context
 add w23,w0,#96
 cbnz w0,.Lmain_cleanup
 adrp x9,.Lvertical_owner
 ldr x20,[x9,:lo12:.Lvertical_owner]
 /* Define only the geometry controls consumed by this input stage. */
 mov w9,#1
 str w9,[x20,#5168]
 str w9,[x20,#7208]
 mov w9,#506
 str w9,[x20,#5200]
 mov w9,#19
 str w9,[x20,#5228]
 /* Construct the complete selected spectral allocation graph. */
 mov w0,#19
 mov w1,#21
 adrp x2,.Lfield_codes
 add x2,x2,:lo12:.Lfield_codes
 adrp x3,.Lspectral_owner
 add x3,x3,:lo12:.Lspectral_owner
 bl md2asm_create_serial_spectral_field
 add w23,w0,#112
 cbnz w0,.Lmain_cleanup
 adrp x9,.Lspectral_owner
 ldr x21,[x9,:lo12:.Lspectral_owner]
 /* Own selected configuration, including the GNU integer descriptor. */
 adrp x22,.Lconfiguration
 add x22,x22,:lo12:.Lconfiguration
 mov w9,#1
 str w9,[x22,#8]
 mov w9,#3
 str w9,[x22,#24]
 mov w9,#2
 str w9,[x22,#28]
 adrp x9,.Lfield_codes
 add x9,x9,:lo12:.Lfield_codes
 str x9,[x22,#40]
 mov x9,#-1
 str x9,[x22,#48]
 mov x9,#4
 str x9,[x22,#56]
 str x9,[x22,#72]
 mov w9,#0x101
 str w9,[x22,#68]
 mov x9,#1
 str x9,[x22,#80]
 str x9,[x22,#88]
 mov x9,#3
 str x9,[x22,#96]
 mov w9,#8
 str w9,[x22,#184]
 adrp x10,.Ltracer_requests
 add x10,x10,:lo12:.Ltracer_requests
 add x11,x22,#4032
 mov w12,#8
 mov w13,#1
.Ltracer_controls:
 ldr w9,[x10],#4
 str w9,[x11,#36]
 str w13,[x11,#44]
 str w13,[x11,#52]
 add x11,x11,#368
 subs w12,w12,#1
 b.ne .Ltracer_controls
 ldr x0,[x19,#8]
 mov x1,x20
 mov x2,x22
 mov x3,x21
 adrp x4,.Lloaded_orography
 add x4,x4,:lo12:.Lloaded_orography
 bl md2asm_load_spectral_initial_state
 add w23,w0,#128
 cbnz w0,.Lmain_cleanup
 /* The owned field namespace is associated now; later producers finish maps. */
 ldr x0,[x19,#24]
 add x1,x22,#184
 adrp x2,.Lupper_air_owner
 add x2,x2,:lo12:.Lupper_air_owner
 bl md2asm_create_loaded_upper_air_state
 add w23,w0,#144
 cbnz w0,.Lmain_cleanup
 adrp x9,.Lupper_air_owner
 ldr x26,[x9,:lo12:.Lupper_air_owner]
 ldr x0,[x19,#32]
 ldr x1,[x21,#88]
 mov x2,#0x8550
 movk x2,#3,lsl #16
 bl .Lwrite_complete_file
 add w23,w0,#160
 cbnz w0,.Lmain_cleanup
 ldr x0,[x19,#40]
 ldr x1,[x21]
 mov x2,#8096
 bl .Lwrite_complete_file
 add w23,w0,#176
 cbnz w0,.Lmain_cleanup
 ldr x0,[x19,#48]
 ldr x1,[x26]
 mov x2,#0x4c00
 movk x2,#0x26,lsl#16
 bl .Lwrite_complete_file
 add w23,w0,#192
 cbnz w0,.Lmain_cleanup
 mov w23,wzr
.Lmain_cleanup:
 cbz x26,.Lmain_release_spectral
 mov x0,x26
 bl md2asm_release_gridpoint_field_context
.Lmain_release_spectral:
 cbz x21,.Lmain_release_vertical
 mov x0,x21
 bl md2asm_release_serial_spectral_field_context
.Lmain_release_vertical:
 cbz x20,.Lmain_return
 mov x0,x20
 bl md2asm_release_vertical_startup_context
.Lmain_return:
 mov w0,w23
 ldr x28,[sp,#96]
 ldp x26,x27,[sp,#80]
 ldp x24,x25,[sp,#64]
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#112
 ret
.size main,.-main

/* Linux calls return a negative error number. Retry an interrupted call.
 * Paths and live FP64 owners are inputs. Only the output file is changed. */
.p2align 2
.type .Lwrite_complete_file,%function
.Lwrite_complete_file:
 sub sp,sp,#64
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
.Lopen_file:
 mov x0,#-100
 mov x1,x19
 mov x2,#577
 mov x3,#420
 mov x8,#56
 svc #0
 cmn x0,#4
 b.eq .Lopen_file
 tbnz x0,#63,.Lopen_failed
 mov x22,x0
.Lwrite_remaining:
 cbz x21,.Lclose_success
 mov x0,x22
 mov x1,x20
 mov x2,x21
 mov x8,#64
 svc #0
 cmn x0,#4
 b.eq .Lwrite_remaining
 cmp x0,#0
 b.le .Lclose_failed_write
 add x20,x20,x0
 sub x21,x21,x0
 b .Lwrite_remaining
.Lclose_success:
 mov x0,x22
 mov x8,#57
 svc #0
 cmp x0,#0
 cset w0,ne
 b .Lwrite_return
.Lclose_failed_write:
 mov x0,x22
 mov x8,#57
 svc #0
 mov w0,#2
 b .Lwrite_return
.Lopen_failed:
 mov w0,#3
.Lwrite_return:
 ldr x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.size .Lwrite_complete_file,.-.Lwrite_complete_file

.section .rodata
.p2align 3
.Lvertical_configuration: .word 19,1,0,0
.Lfield_codes: .word 138,155,130,152,129
.Ltracer_requests: .word 0,0,1,-1,-1,1,1,1
.bss
.p2align 3
.Lheaders: .zero 5232
.Lvertical_owner: .zero 8
.Lspectral_owner: .zero 8
.Lupper_air_owner: .zero 8
.Lloaded_orography: .zero 8
.Lconfiguration: .zero 1556112
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/input/standalone_initial_bootstrap.md. */
/* Standalone selected T21 spectral, upper-air and full field configuration, revision 3.
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
 cmp w0,#9
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
 /* Read bounded live namelist text; no retained namespace is an input. */
 ldr x0,[x19,#32]
 adrp x1,.Lnamelist_text
 add x1,x1,:lo12:.Lnamelist_text
 mov x2,#4
 lsl x2,x2,#16
 bl .Lread_live_text
 add w23,w0,#200
 cbnz w0,.Lmain_cleanup
 mov x27,x1
 adrp x0,.Lphysical_constants
 add x0,x0,:lo12:.Lphysical_constants
 mov x1,#520
 bl md2asm_initialize_physical_constants
 add w23,w0,#208
 cbnz w0,.Lmain_cleanup
 adrp x0,.Lnamelist_text
 add x0,x0,:lo12:.Lnamelist_text
 mov x1,x27
 adrp x2,.Lphysics_record
 add x2,x2,:lo12:.Lphysics_record
 mov x3,#448
 adrp x4,.Lphysics_controls
 add x4,x4,:lo12:.Lphysics_controls
 adrp x5,.Lphysics_counts
 add x5,x5,:lo12:.Lphysics_counts
 bl md2asm_initialize_selected_physics_controls
 add w23,w0,#212
 cbnz w0,.Lmain_cleanup
 /* Bind the namespace's selected count inputs to this actual producer. */
 mov w23,#215
 adrp x9,.Lphysics_counts
 add x9,x9,:lo12:.Lphysics_counts
 ldr w10,[x9]
 cmp w10,#2
 b.ne .Lmain_cleanup
 ldp w10,w11,[x9,#4]
 ldp w12,w13,[x9,#12]
 orr w10,w10,w11
 orr w12,w12,w13
 orr w10,w10,w12
 cbnz w10,.Lmain_cleanup
 adrp x9,.Lphysics_record
 add x9,x9,:lo12:.Lphysics_record
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lmain_cleanup
 ldr w10,[x9,#68]
 cmp w10,#1
 b.ne .Lmain_cleanup
 ldr w10,[x9,#260]
 cmp w10,#1
 b.ne .Lmain_cleanup
 /* The owned clock receives date/time from the real header and t25 controls. */
 adrp x0,.Lclock_inputs
 add x0,x0,:lo12:.Lclock_inputs
 ldp w9,w10,[x24,#32]
 stp w9,w10,[x0]
 adr x9,.Lclock_fixed_inputs
 ldp x10,x11,[x9]
 stp x10,x11,[x0,#8]
 ldp x10,x11,[x9,#16]
 stp x10,x11,[x0,#24]
 adrp x1,.Lclock_state
 add x1,x1,:lo12:.Lclock_state
 mov x2,#360
 bl md2asm_initialize_model_clock
 add w23,w0,#216
 cbnz w0,.Lmain_cleanup
 adrp x4,.Lfield_controls
 add x4,x4,:lo12:.Lfield_controls
 ldr w9,[x24,#16]
 str w9,[x4]
 adrp x9,.Lclock_state
 add x9,x9,:lo12:.Lclock_state
 ldr w10,[x9,#52]
 str w10,[x4,#8]
 ldr w10,[x24,#28]
 str w10,[x4,#12]
 adr x9,.Lfield_fixed_controls
 ldp x10,x11,[x9]
 stp x10,x11,[x4,#16]
 add x0,x22,#184
 adrp x1,.Lphysical_constants
 add x1,x1,:lo12:.Lphysical_constants
 adrp x2,.Lnamelist_text
 add x2,x2,:lo12:.Lnamelist_text
 mov x3,x27
 adrp x5,.Lfield_effects
 add x5,x5,:lo12:.Lfield_effects
 bl md2asm_initialize_selected_grid_field_configuration
 add w23,w0,#220
 cbnz w0,.Lmain_cleanup
 adrp x9,.Lnamespace_status
 add x9,x9,:lo12:.Lnamespace_status
 mrs x10,fpcr
 mrs x11,fpsr
 stp x10,x11,[x9]
 bl __errno_location
 ldr w10,[x0]
 adrp x9,.Lnamespace_status
 add x9,x9,:lo12:.Lnamespace_status
 str w10,[x9,#16]
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
 ldr x0,[x19,#40]
 ldr x1,[x21,#88]
 mov x2,#0x8550
 movk x2,#3,lsl #16
 bl .Lwrite_complete_file
 add w23,w0,#160
 cbnz w0,.Lmain_cleanup
 ldr x0,[x19,#48]
 ldr x1,[x21]
 mov x2,#8096
 bl .Lwrite_complete_file
 add w23,w0,#176
 cbnz w0,.Lmain_cleanup
 ldr x0,[x19,#56]
 ldr x1,[x26]
 mov x2,#0x4c00
 movk x2,#0x26,lsl#16
 bl .Lwrite_complete_file
 add w23,w0,#192
 cbnz w0,.Lmain_cleanup
 ldr x0,[x19,#64]
 mov x1,x22
 mov x2,#0xc440
 movk x2,#0x17,lsl#16
 bl .Lwrite_complete_file
 add w23,w0,#224
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

/* Read at most capacity bytes and require EOF, with one extra-byte check. */
.p2align 2
.type .Lread_live_text,%function
.Lread_live_text:
 sub sp,sp,#64
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x23,[sp,#48]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 add x21,x2,#1
 mov x22,xzr
.Ltext_open:
 mov x0,#-100
 mov x1,x19
 mov x2,#0
 mov x3,#0
 mov x8,#56
 svc #0
 cmn x0,#4
 b.eq .Ltext_open
 tbnz x0,#63,.Ltext_open_bad
 mov x23,x0
.Ltext_read:
 mov x0,x23
 add x1,x20,x22
 sub x2,x21,x22
 mov x8,#63
 svc #0
 cmn x0,#4
 b.eq .Ltext_read
 tbnz x0,#63,.Ltext_read_bad
 cbz x0,.Ltext_eof
 add x22,x22,x0
 cmp x22,x21
 b.hs .Ltext_read_bad
 b .Ltext_read
.Ltext_eof:
 cbz x22,.Ltext_read_bad
 mov x0,x23
 mov x8,#57
 svc #0
 cbnz x0,.Ltext_closed_bad
 mov x1,x22
 mov w0,#0
 b .Ltext_return
.Ltext_read_bad:
 mov x0,x23
 mov x8,#57
 svc #0
.Ltext_closed_bad:
 mov w0,#2
 b .Ltext_return
.Ltext_open_bad:
 mov w0,#1
.Ltext_return:
 ldr x23,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.size .Lread_live_text,.-.Lread_live_text

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
.global md2asm_owned_initial_field_codes
md2asm_owned_initial_field_codes:
.Lfield_codes: .word 138,155,130,152,129
.p2align 3
.Lphysics_controls: .word 1,0
.Lfield_fixed_controls: .word 1,0,1,1
.p2align 3
.Lclock_fixed_inputs:
 .xword 0x40ac200000000000
 .ascii "t25     "
 .xword 0
 .xword 0xbff0000000000000
.bss
.p2align 3
.Lheaders: .zero 5232
.Lvertical_owner: .zero 8
.Lspectral_owner: .zero 8
.Lupper_air_owner: .zero 8
.Lloaded_orography: .zero 8
.global md2asm_owned_initial_configuration
md2asm_owned_initial_configuration:
.Lconfiguration: .zero 1556112
.Lphysics_record: .zero 448
.Lphysics_counts: .zero 24
.Lphysical_constants: .zero 520
.Lfield_effects: .zero 8
.Lnamespace_status: .zero 24
.Lclock_state: .zero 360
.Lclock_inputs: .zero 40
.Lfield_controls: .zero 32
.Lmetadata_end:
.if (.Lmetadata_end-.Lconfiguration)!=1557568
.error "metadata envelope size differs"
.endif
.Lnamelist_text: .zero 262145
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/input/standalone_initial_bootstrap.md. */
/* Standalone selected T21 complete initial-state composition, revision 4.
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
 mov x28,xzr
 mov w23,#64
 cmp w0,#11
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
 /* Full vertical mathematics consumes the newly owned constants. */
 adrp x9,.Lphysical_constants
 add x9,x9,:lo12:.Lphysical_constants
 ldr x10,[x20,#20320]
 ldr x11,[x9]
 adrp x1,.Lvertical_scalars
 add x1,x1,:lo12:.Lvertical_scalars
 stp x10,x11,[x1]
 adrp x9,.Lvertical_bounds
 add x9,x9,:lo12:.Lvertical_bounds
 add x10,x9,#8
 adrp x2,.Lvertical_bound_pointers
 add x2,x2,:lo12:.Lvertical_bound_pointers
 stp x9,x10,[x2]
 mov x0,x20
 bl md2asm_initialize_owned_vertical_system
 add w23,w0,#232
 cbnz w0,.Lmain_cleanup
 /* Bind dynamics controls to actual header and vertical producers. */
 adrp x4,.Ldynamics_inputs
 add x4,x4,:lo12:.Ldynamics_inputs
 ldr w9,[x24,#12]
 ldr w10,[x24,#8]
 stp w9,w10,[x4]
 ldr w9,[x24]
 stp w9,w9,[x4,#8]
 ldr w9,[x20,#3076]
 ldr w10,[x20,#3028]
 stp w9,w10,[x4,#16]
 adrp x9,.Lvertical_configuration
 add x9,x9,:lo12:.Lvertical_configuration
 ldr w10,[x9,#8]
 str w10,[x4,#24]
 mov w10,#1
 str w10,[x4,#28]
 adrp x0,.Lnamelist_text
 add x0,x0,:lo12:.Lnamelist_text
 mov x1,x27
 adrp x2,.Ldynamics_record
 add x2,x2,:lo12:.Ldynamics_record
 mov x3,#456
 bl md2asm_initialize_selected_dynamics_controls
 add w23,w0,#236
 cbnz w0,.Lmain_cleanup
 adrp x9,.Ldynamics_record
 add x9,x9,:lo12:.Ldynamics_record
 ldr w10,[x9,#24]
 adrp x9,.Lphysics_controls
 add x9,x9,:lo12:.Lphysics_controls
 stp w10,wzr,[x9]
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
 adrp x9,.Ldynamics_record
 add x9,x9,:lo12:.Ldynamics_record
 ldr w10,[x9,#16]
 str w10,[x4,#16]
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
 /* Own the complete surface graph before opening any output. */
 ldr x0,[x19,#16]
 adrp x1,.Lphysical_constants
 add x1,x1,:lo12:.Lphysical_constants
 adrp x2,.Lphysics_record
 add x2,x2,:lo12:.Lphysics_record
 adrp x3,.Lsurface_record
 add x3,x3,:lo12:.Lsurface_record
 adrp x4,.Lsurface_trajectory
 add x4,x4,:lo12:.Lsurface_trajectory
 adrp x5,.Lsurface_descriptions
 add x5,x5,:lo12:.Lsurface_descriptions
 bl md2asm_initialize_selected_surface_state
 add w23,w0,#240
 cbnz w0,.Lmain_cleanup
 mov w28,#1
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
 mov x2,#0xc660
 movk x2,#0x17,lsl#16
 bl .Lwrite_complete_file
 add w23,w0,#224
 cbnz w0,.Lmain_cleanup
 ldr x0,[x19,#72]
 mov w1,#1
 bl .Lwrite_initial_state_stream
 add w23,w0,#248
 cbnz w0,.Lmain_cleanup
 ldr x0,[x19,#80]
 mov w1,#0
 bl .Lwrite_initial_state_stream
 add w23,w0,#244
 cbnz w0,.Lmain_cleanup
 mov w23,wzr
.Lmain_cleanup:
 cbz x28,.Lmain_release_upper_air
 adrp x0,.Lsurface_record
 add x0,x0,:lo12:.Lsurface_record
 bl md2asm_release_selected_surface_state
.Lmain_release_upper_air:
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
 bl md2asm_release_owned_vertical_system
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

/* x0 output path,w1 stream kind0vertical/1surface. All owners remain live. */
.Lwrite_initial_state_stream:
 stp x29,x30,[sp,#-48]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 mov x29,sp
 mov x20,x0
 mov w21,w1
.Lstate_open:
 mov x0,#-100
 mov x1,x20
 mov x2,#577
 mov x3,#420
 mov x8,#56
 svc #0
 cmn x0,#4
 b.eq .Lstate_open
 tbnz x0,#63,.Lstate_open_failed
 mov x19,x0
 cbz w21,.Lstate_vertical
 adrp x1,.Lsurface_record
 add x1,x1,:lo12:.Lsurface_record
 adrp x2,.Lsurface_trajectory
 add x2,x2,:lo12:.Lsurface_trajectory
 adrp x3,.Lsurface_descriptions
 add x3,x3,:lo12:.Lsurface_descriptions
 bl md2asm_write_selected_surface_state
 b .Lstate_close
.Lstate_vertical:
 adrp x1,.Lvertical_owner
 ldr x1,[x1,:lo12:.Lvertical_owner]
 bl .Lemit_vertical_state
.Lstate_close:
 mov w20,w0
 mov x0,x19
 mov x8,#57
 svc #0
 cmp x0,#0
 cset w0,ne
 orr w0,w0,w20
 b .Lstate_return
.Lstate_open_failed:
 mov w0,#1
.Lstate_return:
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#48
 ret
/* w0 descriptor,x1 live20400-byte vertical context; emit every owner. */
.Lemit_vertical_state:
 stp x29,x30,[sp,#-80]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov w19,w0
 mov x20,x1
 adrp x1,.Lvertical_stream_magic
 add x1,x1,:lo12:.Lvertical_stream_magic
 mov x2,#8
 bl .Lstate_write_bytes
 cbnz w0,.Lvertical_stream_return
 mov x1,x20
 mov x2,#20400
 bl .Lstate_write_bytes
 cbnz w0,.Lvertical_stream_return
 adrp x21,.Lvertical_stream_owners
 add x21,x21,:lo12:.Lvertical_stream_owners
 mov w22,#28
.Lvertical_stream_owner:
 ldp w9,w10,[x21],#8
 ldr x9,[x20,w9,uxtw]
 stp x9,x10,[sp,#64]
 add x1,sp,#64
 mov x2,#16
 bl .Lstate_write_bytes
 cbnz w0,.Lvertical_stream_return
 ldp x1,x2,[sp,#64]
 bl .Lstate_write_bytes
 cbnz w0,.Lvertical_stream_return
 subs w22,w22,#1
 b.ne .Lvertical_stream_owner
 mov w0,#0
.Lvertical_stream_return:
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
/* x19 descriptor,x1 bytes,x2 extent. Direct Linux writes preserve C errno. */
.Lstate_write_bytes:
 cbz x2,.Lstate_written
.Lstate_write_more:
 mov x0,x19
 mov x8,#64
 svc #0
 cmn x0,#4
 b.eq .Lstate_write_more
 cmp x0,#0
 b.le .Lstate_write_failed
 add x1,x1,x0
 subs x2,x2,x0
 b.ne .Lstate_write_more
.Lstate_written:
 mov w0,#0
 ret
.Lstate_write_failed:
 mov w0,#1
 ret

.section .rodata
.p2align 3
.Lvertical_configuration: .word 19,1,0,0
.global md2asm_owned_initial_field_codes
md2asm_owned_initial_field_codes:
.Lfield_codes: .word 138,155,130,152,129
.p2align 3
.Lfield_fixed_controls: .word 1,0,1,1
.p2align 3
.Lclock_fixed_inputs:
 .xword 0x40ac200000000000
 .ascii "t25     "
 .xword 0
 .xword 0xbff0000000000000
.p2align 3
.Lvertical_stream_magic: .ascii "VS28OWN1"
.Lvertical_stream_owners:
 .word 16,160
 .word 144,160
 .word 80,160
 .word 208,152
 .word 464,152
 .word 528,160
 .word 656,168
 .word 592,160
 .word 720,168
 .word 272,152
 .word 336,152
 .word 400,152
 .word 784,152
 .word 848,136
 .word 1352,3192
 .word 1440,3192
 .word 1528,3192
 .word 1616,3192
 .word 1088,3360
 .word 14952,160
 .word 14888,160
 .word 14824,160
 .word 15016,152
 .word 15208,152
 .word 15272,152
 .word 15080,160
 .word 15144,160
 .word 1264,3192
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
.Ldynamics_record: .zero 456
.Ldynamics_inputs: .zero 32
.Lvertical_scalars: .zero 16
.Lvertical_bounds: .zero 16
.Lvertical_bound_pointers: .zero 16
.Lphysics_controls: .zero 8
.Lmetadata_end:
.if (.Lmetadata_end-.Lconfiguration)!=1558112
.error "metadata envelope size differs"
.endif
.Lsurface_record: .zero 18224
.Lsurface_trajectory: .zero 408
.Lsurface_descriptions: .zero 46080
.Lnamelist_text: .zero 262145
.section .note.GNU-stack,"",%progbits

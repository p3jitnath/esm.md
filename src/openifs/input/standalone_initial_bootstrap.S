/* Contract: skills/md2asm/references/openifs/input/owned_model_initial_state.md. */
/* Standalone selected T21 complete initial-state composition, revision 7.
 * Own entry, configuration, contexts, loading, output and release are assembly.
 * External services are libc, ecCodes and the qualified FIAT/ectrans interfaces.
 * This input checkpoint does not run a forecast. */
.arch armv8.2-a
.text

.macro owned_model_address dst,offset
 adrp \dst,.Lmodel_owner
 ldr \dst,[\dst,:lo12:.Lmodel_owner]
 movz x17,#(\offset & 65535)
 movk x17,#(\offset >> 16),lsl#16
 add \dst,\dst,x17
.endm

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
 mov x25,xzr
 mov w23,#64
 cmp w0,#13
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
 mov x0,x20
 adr x1,.Lowned_alias_destinations
 adrp x2,.Lmodel_owner
 add x2,x2,:lo12:.Lmodel_owner
 bl md2asm_create_selected_model_storage
 add w23,w0,#100
 cbnz w0,.Lmain_cleanup
 bl .Lbind_final_record_tables
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
 owned_model_address x22,8
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
 /* Own the live forecast controls and connected source clock. */
 adrp x2,.Lforecast_upstream
 add x2,x2,:lo12:.Lforecast_upstream
 ldp w9,w10,[x24,#32]
 stp w9,w10,[x2]
 str wzr,[x2,#8]
 mov w9,#1
 str w9,[x2,#12]
 adrp x0,.Lnamelist_text
 add x0,x0,:lo12:.Lnamelist_text
 mov x1,x27
 adrp x3,.Lforecast_controls
 add x3,x3,:lo12:.Lforecast_controls
 mov x4,#51512
 bl md2asm_initialize_selected_forecast_controls
 add w23,w0,#58
 cbnz w0,.Lmain_cleanup
 adrp x9,.Lforecast_controls
 add x9,x9,:lo12:.Lforecast_controls
 mov x10,#35104
 ldr w10,[x9,x10]
 str w10,[x22,#8]
 mov x10,#51112
 add x9,x9,x10
 adrp x10,.Lclock_inputs
 add x10,x10,:lo12:.Lclock_inputs
 mov x11,#40
.Lcopy_live_clock_inputs:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#8
 b.ne .Lcopy_live_clock_inputs
 adrp x10,.Lclock_state
 add x10,x10,:lo12:.Lclock_state
 mov x11,#360
.Lcopy_live_clock_state:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#8
 b.ne .Lcopy_live_clock_state
 adrp x0,.Lclock_inputs
 add x0,x0,:lo12:.Lclock_inputs
 adrp x1,.Lclock_state
 add x1,x1,:lo12:.Lclock_state
 adr x2,.Ltime_integration_controls
 movz x3,#48600
 movk x3,#20,lsl#16
 add x3,x22,x3
 movz x4,#0xaf68
 movk x4,#2,lsl#16
 mov x5,#0
 bl md2asm_initialize_time_integration_configuration
 add w23,w0,#60
 cbnz w0,.Lmain_cleanup
 adrp x0,.Lnamelist_text
 add x0,x0,:lo12:.Lnamelist_text
 mov x1,x27
 adrp x2,md2asm_owned_dynamical_namespace
 add x2,x2,:lo12:md2asm_owned_dynamical_namespace
 mov x3,#320
 bl md2asm_initialize_dynamical_configuration
 add w23,w0,#57
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
 /* Complete horizontal and standard-atmosphere state at the live address. */
 mov x0,x20
 mov x1,x24
 adrp x2,.Lphysical_constants
 add x2,x2,:lo12:.Lphysical_constants
 adrp x3,.Lnamelist_text
 add x3,x3,:lo12:.Lnamelist_text
 mov x4,x27
 adrp x5,.Lgeometry_owner
 add x5,x5,:lo12:.Lgeometry_owner
 bl md2asm_complete_owned_geometry
 add w23,w0,#62
 cbnz w0,.Lmain_cleanup
 adrp x9,.Lgeometry_owner
 ldr x25,[x9,:lo12:.Lgeometry_owner]
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
 owned_model_address x2,1564136
 mov x3,#456
 bl md2asm_initialize_selected_dynamics_controls
 add w23,w0,#236
 cbnz w0,.Lmain_cleanup
 owned_model_address x9,1564136
 ldr w10,[x9,#24]
 adrp x9,.Lphysics_controls
 add x9,x9,:lo12:.Lphysics_controls
 owned_model_address x11,8
 /* Source SUGFL1 default LUVPOUT; the complete namespace remains fresh zero. */
 str wzr,[x11,#372]
 ldr w11,[x11,#372]
 stp w10,w11,[x9]
 adrp x0,.Lnamelist_text
 add x0,x0,:lo12:.Lnamelist_text
 mov x1,x27
 adrp x2,.Lcomplete_physics_records
 add x2,x2,:lo12:.Lcomplete_physics_records
 adrp x3,.Lphysics_controls
 add x3,x3,:lo12:.Lphysics_controls
 adrp x4,.Lphysics_counts
 add x4,x4,:lo12:.Lphysics_counts
 bl md2asm_initialize_selected_physics_configuration
 add w23,w0,#212
 cbnz w0,.Lmain_cleanup
 adrp x0,.Lphysics_status_su0phy
 add x0,x0,:lo12:.Lphysics_status_su0phy
 bl .Lcapture_physics_status
 /* Source SUDIMF1 consumes the final live records before SUGFL. */
 adrp x0,.Lnamelist_text
 add x0,x0,:lo12:.Lnamelist_text
 mov x1,x27
 adr x2,.Lfield_dimension_pairs
 adr x3,.Lfield_dimension_controls
 bl md2asm_initialize_physics_field_dimensions
 add w23,w0,#216
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
 owned_model_address x9,1577888
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lmain_cleanup
 ldr w10,[x9,#68]
 cmp w10,#1
 b.ne .Lmain_cleanup
 ldr w10,[x9,#260]
 cmp w10,#1
 b.ne .Lmain_cleanup
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
 owned_model_address x9,1564136
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
 owned_model_address x0,16
 owned_model_address x1,1564136
 owned_model_address x2,200
 adr x3,.Lfield_dimension_controls
 bl md2asm_initialize_spectral_field_dimensions
 add w23,w0,#218
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
 /* Available SUPHY families retain their source-relative call order. */
 adrp x0,.Lnamelist_text
 add x0,x0,:lo12:.Lnamelist_text
 mov x1,x27
 adrp x2,.Lphysical_constants
 add x2,x2,:lo12:.Lphysical_constants
 owned_model_address x3,4148312
 owned_model_address x4,4202320
 mov x5,#1696
 mov x6,#15864
 bl md2asm_initialize_surface_exchange_parameters
 add w23,w0,#50
 cbnz w0,.Lmain_cleanup
 owned_model_address x0,1581376
 mov x1,#16
 bl md2asm_initialize_condensation_parameters
 add w23,w0,#52
 cbnz w0,.Lmain_cleanup
 adrp x0,.Lnamelist_text
 add x0,x0,:lo12:.Lnamelist_text
 mov x1,x27
 owned_model_address x2,1577816
 mov x3,#72
 bl md2asm_initialize_selected_diffusion_parameters
 add w23,w0,#54
 cbnz w0,.Lmain_cleanup
 adrp x0,.Lthermal_stability_namespace
 add x0,x0,:lo12:.Lthermal_stability_namespace
 mov x1,#1920
 adrp x2,.Lphysical_constants
 add x2,x2,:lo12:.Lphysical_constants
 mov x3,#520
 bl md2asm_initialize_thermal_diffusion_parameters
 add w23,w0,#55
 cbnz w0,.Lmain_cleanup
 /* Compute live SUPHEC pressure and eta inputs before the cloud children. */
 mov x0,x20
 adrp x1,.Lphysical_constants
 add x1,x1,:lo12:.Lphysical_constants
 adrp x2,.Lcloud_pressure
 add x2,x2,:lo12:.Lcloud_pressure
 bl md2asm_initialize_cloud_pressure_inputs
 add w23,w0,#68
 cbnz w0,.Lmain_cleanup
 adrp x9,.Lcloud_inputs
 add x9,x9,:lo12:.Lcloud_inputs
 adrp x10,.Lcloud_pressure
 add x10,x10,:lo12:.Lcloud_pressure
 add x10,x10,#472
 str x10,[x9]
 mov x10,#3336
 ldr x10,[x20,x10]
 str x10,[x9,#16]
 ldr x10,[x20,#144]
 str x10,[x9,#32]
 ldr x10,[x20,#80]
 str x10,[x9,#48]
 adrp x10,.Lphysical_constants
 add x10,x10,:lo12:.Lphysical_constants
 str x10,[x9,#64]
 adrp x10,.Lclock_inputs
 add x10,x10,:lo12:.Lclock_inputs
 add x10,x10,#8
 str x10,[x9,#80]
 adrp x4,.Lcloud_controls
 add x4,x4,:lo12:.Lcloud_controls
 owned_model_address x10,1577888
 ldr w10,[x10]
 str w10,[x4,#4]
 adrp x0,.Lnamelist_text
 add x0,x0,:lo12:.Lnamelist_text
 mov x1,x27
 adrp x2,.Lcloud_records
 add x2,x2,:lo12:.Lcloud_records
 mov x3,x9
 bl md2asm_initialize_cloud_gravity_wave_parameters
 add w23,w0,#72
 cbnz w0,.Lmain_cleanup
 adr x9,.Lconvection_inputs
 owned_model_address x10,1359528
 str x10,[x9,#48]
 mov x10,#3336
 ldr x10,[x20,x10]
 str x10,[x9]
 adrp x0,.Lnamelist_text
 add x0,x0,:lo12:.Lnamelist_text
 mov x1,x27
 adr x2,.Lconvection_records
 mov x3,x9
 adr x4,.Lconvection_controls
 bl md2asm_initialize_convection_parameters
 add w23,w0,#74
 cbnz w0,.Lmain_cleanup
 adrp x9,.Lconvection_thermal
 add x9,x9,:lo12:.Lconvection_thermal
 adrp x10,.Lthermal_stability_namespace
 add x10,x10,:lo12:.Lthermal_stability_namespace
 ldr x11,[x9,#8]
 str x11,[x10,#144]
 ldr x11,[x9,#16]
 str x11,[x10,#160]
 adrp x0,.Lphysics_status_final
 add x0,x0,:lo12:.Lphysics_status_final
 bl .Lcapture_physics_status
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
 owned_model_address x2,1577888
 adrp x3,.Lsurface_record
 add x3,x3,:lo12:.Lsurface_record
 adrp x4,.Lsurface_trajectory
 add x4,x4,:lo12:.Lsurface_trajectory
 owned_model_address x5,4155544
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
 adr x1,.Lmetadata_gather
 mov x2,#5
 bl .Lwrite_record_payloads
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
 ldr x0,[x19,#88]
 bl .Lwrite_physics_stream
 add w23,w0,#56
 cbnz w0,.Lmain_cleanup
 ldr x0,[x19,#96]
 bl .Lwrite_setup_stream
 add w23,w0,#76
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
 adrp x9,.Lmodel_owner
 ldr x9,[x9,:lo12:.Lmodel_owner]
 cbz x9,.Lmain_release_geometry
 owned_model_address x0,1578336
 mov x1,#264
 bl md2asm_release_cloud_parameter_eta
 .Lmain_release_geometry:
 cbz x25,.Lmain_release_old_vertical
 mov x0,x25
 bl md2asm_release_owned_geometry
 mov x25,xzr
.Lmain_release_old_vertical:
 adrp x0,.Lmodel_owner
 add x0,x0,:lo12:.Lmodel_owner
 adr x1,.Lowned_alias_destinations
 bl md2asm_release_selected_model_storage
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
 owned_model_address x3,4155544
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

/* x0 writable24-byte status record; observe before later stage services. */
.Lcapture_physics_status:
 stp x29,x30,[sp,#-32]!
 stp x18,x19,[sp,#16]
 mov x29,sp
 mov x19,x0
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[x19]
 bl __errno_location
 ldr w9,[x0]
 str w9,[x19,#16]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
/* x0 path; emit every complete live physics record and its producer inputs. */
.Lwrite_physics_stream:
 stp x29,x30,[sp,#-80]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov x20,x0
.Lphysics_open:
 mov x0,#-100
 mov x1,x20
 mov x2,#577
 mov x3,#420
 mov x8,#56
 svc #0
 cmn x0,#4
 b.eq .Lphysics_open
 tbnz x0,#63,.Lphysics_open_failed
 mov x19,x0
 adrp x1,.Lphysics_stream_magic
 add x1,x1,:lo12:.Lphysics_stream_magic
 mov x2,#8
 bl .Lstate_write_bytes
 cbnz w0,.Lphysics_close
 adrp x21,.Lcomplete_physics_records
 add x21,x21,:lo12:.Lcomplete_physics_records
 mov w22,#21
.Lphysics_stream_record:
 ldp x9,x10,[x21],#16
 stp x9,x10,[sp,#64]
 add x1,sp,#64
 mov x2,#16
 bl .Lstate_write_bytes
 cbnz w0,.Lphysics_close
 ldp x1,x2,[sp,#64]
 bl .Lstate_write_bytes
 cbnz w0,.Lphysics_close
 subs w22,w22,#1
 b.ne .Lphysics_stream_record
 adrp x1,.Lcomplete_physics_records
 add x1,x1,:lo12:.Lcomplete_physics_records
 mov x2,#272
 bl .Lstate_write_bytes
 cbnz w0,.Lphysics_close
 adrp x1,.Lphysics_controls
 add x1,x1,:lo12:.Lphysics_controls
 mov x2,#8
 bl .Lstate_write_bytes
 cbnz w0,.Lphysics_close
 adrp x1,.Lphysics_counts
 add x1,x1,:lo12:.Lphysics_counts
 mov x2,#20
 bl .Lstate_write_bytes
 cbnz w0,.Lphysics_close
 adrp x1,.Lphysics_status_su0phy
 add x1,x1,:lo12:.Lphysics_status_su0phy
 mov x2,#48
 bl .Lstate_write_bytes
.Lphysics_close:
 mov w23,w0
 mov x0,x19
 mov x8,#57
 svc #0
 cmp x0,#0
 cset w0,ne
 orr w0,w0,w23
 b .Lphysics_stream_return
.Lphysics_open_failed:
 mov w0,#1
.Lphysics_stream_return:
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#80
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
.global md2asm_owned_initial_metadata_auxiliary
md2asm_owned_initial_metadata_auxiliary:
.Lphysics_counts: .zero 24
.Lphysical_constants: .zero 520
.Lfield_effects: .zero 8
.Lnamespace_status: .zero 24
.Lclock_state: .zero 360
.Lclock_inputs: .zero 40
.Lfield_controls: .zero 32
.Ldynamics_inputs: .zero 32
.Lvertical_scalars: .zero 16
.Lvertical_bounds: .zero 16
.Lvertical_bound_pointers: .zero 16
.Lphysics_controls: .zero 8
.p2align 3
.Lforecast_upstream: .zero 16
.Lforecast_controls: .zero 51512
.Lgeometry_owner: .zero 8
.Lcloud_pressure: .zero 624
.Lsurface_record: .zero 18224
.Lsurface_trajectory: .zero 408
.Lnamelist_text: .zero 262145

.section .rodata
.Lphysics_stream_magic: .ascii "PH21REC1"
.section .data
.p2align 3
.p2align 3
.Lcomplete_physics_records:
 .quad 0,1096
 .quad 0,40
 .quad 0,368
 .quad 0,1024
 .quad 0,88
 .quad 0,168
 .quad 0,100
 .quad 0,80
 .quad 0,32
 .quad 0,448
 .quad 0,2776
 .quad 0,8
 .quad 0,4
 .quad 0,232
 .quad 0,120
 .quad .Lraw_physics_15,1024
 .quad .Lraw_physics_16,24
 .quad 0,1696
 .quad 0,15864
 .quad 0,16
 .quad 0,72
.bss
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.Lraw_physics_15: .zero 1024
.p2align 3
.Lraw_physics_16: .zero 24
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.p2align 3
.Lphysics_status_su0phy: .zero 24
.Lphysics_status_final: .zero 24
.section .note.GNU-stack,"",%progbits

/* x0 path, complete new state and current live owners. No numerical update. */
.text
.Lwrite_setup_stream:
 sub sp,sp,#144
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 stp x28,xzr,[sp,#96]
 mov x29,sp
 mov x20,x0
.Lsetup_open:
 mov x0,#-100
 mov x1,x20
 mov x2,#577
 mov x3,#420
 mov x8,#56
 svc #0
 cmn x0,#4
 b.eq .Lsetup_open
 tbnz x0,#63,.Lsetup_open_failed
 mov x19,x0
 adrp x9,.Lvertical_owner
 ldr x20,[x9,:lo12:.Lvertical_owner]
 adrp x9,.Lgeometry_owner
 ldr x21,[x9,:lo12:.Lgeometry_owner]
 adr x1,.Lsetup_magic
 mov x2,#72
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 mov x1,x20
 mov x2,#20400
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 mov x1,x21
 mov x2,#1872
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 adrp x1,.Lforecast_controls
 add x1,x1,:lo12:.Lforecast_controls
 mov x2,#51512
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 owned_model_address x1,1578336
 mov x2,#264
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 owned_model_address x1,1588032
 mov x2,#96
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 owned_model_address x1,1588128
 mov x2,#168
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 adrp x1,.Lcloud_pressure
 add x1,x1,:lo12:.Lcloud_pressure
 mov x2,#624
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 owned_model_address x1,8
 movz x9,#48600
 movk x9,#20,lsl#16
 add x1,x1,x9
 movz x2,#0xaf68
 movk x2,#2,lsl#16
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 adr x22,.Lsetup_geometry_owners
 mov x23,#121
.Lsetup_G_owner:
 ldr w1,[x22],#4
 add x0,x20,x1
 bl .Lsetup_write_owner
 cbnz w0,.Lsetup_close
 subs x23,x23,#1
 b.ne .Lsetup_G_owner
 adr x22,.Lsetup_stream_offsets
 mov x23,#5
.Lsetup_stream_owner:
 ldr w24,[x22],#4
 add x0,x21,#8
 add x0,x0,x24
 mov x1,#0x100000
 add x1,x1,x24
 bl .Lsetup_write_owner
 cbnz w0,.Lsetup_close
 subs x23,x23,#1
 b.ne .Lsetup_stream_owner
 mov x24,#120
.Lsetup_transform_owner:
 add x0,x21,#880
 add x0,x0,x24
 mov x1,#0x200000
 add x1,x1,x24
 bl .Lsetup_write_owner
 cbnz w0,.Lsetup_close
 add x24,x24,#64
 cmp x24,#184
 b.ls .Lsetup_transform_owner
 mov x9,#14024
 add x0,x20,x9
 mov x1,#0x300000
 add x1,x1,x9
 bl .Lsetup_write_owner
 cbnz w0,.Lsetup_close
 mov x9,#14024
 ldr x24,[x20,x9]
 mov x25,#0
.Lsetup_orography_block:
 mov x26,#0
.Lsetup_orography_field:
 add x0,x24,x26,lsl#6
 mov x1,#0x400000
 mov x9,#3
 madd x9,x25,x9,x26
 add x1,x1,x9
 bl .Lsetup_write_owner
 cbnz w0,.Lsetup_close
 add x26,x26,#1
 cmp x26,#3
 b.lo .Lsetup_orography_field
 add x24,x24,#384
 add x25,x25,#1
 cmp x25,#86
 b.lo .Lsetup_orography_block
 owned_model_address x0,1578336
 mov x1,#0x500000
 bl .Lsetup_write_owner
 cbnz w0,.Lsetup_close
 adr x1,.Lmodel_extension_shape
 mov x2,#48
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 owned_model_address x1,0
 movz x2,#(4275088 & 65535)
 movk x2,#(4275088 >> 16),lsl#16
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 adr x1,.Lowned_alias_slots
 mov x2,#120
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 adrp x1,md2asm_owned_dynamical_namespace
 add x1,x1,:lo12:md2asm_owned_dynamical_namespace
 mov x2,#320
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 adrp x1,.Lthermal_stability_namespace
 add x1,x1,:lo12:.Lthermal_stability_namespace
 mov x2,#1920
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_close
 adr x1,.Lconvection_thermal
 mov x2,#24
 bl .Lstate_write_bytes
.Lsetup_close:
 mov w28,w0
 mov x0,x19
 mov x8,#57
 svc #0
 cmp x0,#0
 cset w0,ne
 orr w0,w0,w28
 b .Lsetup_return
.Lsetup_open_failed:
 mov w0,#1
.Lsetup_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#144
 ret
/* x0 true contiguous owned descriptor, x1 stable source-role tag, x19 fd. */
.Lsetup_write_owner:
 sub sp,sp,#64
 stp x29,x30,[sp]
 mov x29,sp
 str x1,[sp,#16]
 ldr x9,[x0]
 str x9,[sp,#24]
 ldr x10,[x0,#16]
 ldrb w11,[x0,#28]
 add x12,x0,#48
.Lsetup_owner_extent:
 ldp x13,x14,[x12],#24
 sub x14,x14,x13
 add x14,x14,#1
 mul x10,x10,x14
 subs w11,w11,#1
 b.ne .Lsetup_owner_extent
 str x10,[sp,#32]
 add x1,sp,#16
 mov x2,#24
 bl .Lstate_write_bytes
 cbnz w0,.Lsetup_owner_return
 ldp x1,x2,[sp,#24]
 bl .Lstate_write_bytes
.Lsetup_owner_return:
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.section .rodata
.p2align 3
.Ltime_integration_controls:
 .word 1,1,0,0
.Lsetup_magic:
 .ascii "SETUPR61"
 .xword 1,20400,1872,51512,528,624,388,175976
.Lsetup_geometry_owners:
 .word 7576,7640,7704,7768,7832,5832,6024,5256,5320,5384,7248,5448,7312,5512,5576,5640,5704,5768,5896,6088,6176,6264,6328,6392,7080,6456,6520,6584,4968,5056,7392,6992,6904,5960,7144,6648,6712,6776,6840,4232,4296,4360,4424,4488,4552,4616,4680,4744,3656,3720,3784,3848,3912,3976,4040,4104,4168,3272,3336,3400,3464,3528,3592,7896,14616,14704,8536,8600,8664,8728,8792,8856,8920,8984,9048,9112,9176,9240,9304,9368,9432,9496,9560,9624,9688,9752,9816,9880,9944,8088,8152,8216,8280,8344,8408,10008,10096,10184,10272,10360,10448,10536,10624,10712,10800,10888,10976,11064,11152,11240,11328,11416,11504,11592,11680,11768,11856,11944,8472,8024,4808
.Lsetup_stream_offsets:
 .word 64,144,208,272,336
.section .data
.p2align 3
.Lcloud_records:
 .xword 0,264,0,96,0,168
.Lcloud_inputs:
 .xword 0,152,0,152,0,160,0,160,0,520,0,8
.Lcloud_controls:
 .word 19,0

.text
.Lbind_final_record_tables:
 adr x9,.Lcomplete_physics_records
 owned_model_address x10,4143760
 str x10,[x9,#0]
 owned_model_address x10,4219344
 str x10,[x9,#16]
 owned_model_address x10,4096584
 str x10,[x9,#32]
 owned_model_address x10,4271536
 str x10,[x9,#48]
 owned_model_address x10,4218352
 str x10,[x9,#64]
 owned_model_address x10,4218184
 str x10,[x9,#80]
 owned_model_address x10,1588752
 str x10,[x9,#96]
 owned_model_address x10,1588672
 str x10,[x9,#112]
 owned_model_address x10,1622432
 str x10,[x9,#128]
 owned_model_address x10,1577888
 str x10,[x9,#144]
 owned_model_address x10,1578600
 str x10,[x9,#160]
 owned_model_address x10,1588852
 str x10,[x9,#176]
 owned_model_address x10,1588428
 str x10,[x9,#192]
 owned_model_address x10,1588864
 str x10,[x9,#208]
 owned_model_address x10,1588296
 str x10,[x9,#224]
 owned_model_address x10,4148312
 str x10,[x9,#272]
 owned_model_address x10,4202320
 str x10,[x9,#288]
 owned_model_address x10,1581376
 str x10,[x9,#304]
 owned_model_address x10,1577816
 str x10,[x9,#320]
 adr x9,.Lcloud_records
 owned_model_address x10,1578336
 str x10,[x9,#0]
 owned_model_address x10,1588032
 str x10,[x9,#16]
 owned_model_address x10,1588128
 str x10,[x9,#32]
 adr x9,.Lfield_dimension_pairs
 owned_model_address x10,16
 str x10,[x9,#0]
 owned_model_address x10,1577368
 str x10,[x9,#16]
 owned_model_address x10,1564136
 str x10,[x9,#32]
 owned_model_address x10,1577888
 str x10,[x9,#48]
 owned_model_address x10,4143760
 str x10,[x9,#64]
 owned_model_address x10,4218352
 str x10,[x9,#80]
 adr x9,.Lconvection_records
 owned_model_address x10,1581392
 str x10,[x9,#0]
 owned_model_address x10,1588432
 str x10,[x9,#16]
 owned_model_address x10,1588416
 str x10,[x9,#32]
 adr x9,.Lmetadata_gather
 owned_model_address x10,8
 str x10,[x9,#0]
 owned_model_address x10,1577888
 str x10,[x9,#16]
 owned_model_address x10,1564136
 str x10,[x9,#48]
 ret

.Lwrite_record_payloads:
 stp x29,x30,[sp,#-64]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov x20,x0
 mov x21,x1
 mov x22,x2
.Lpayload_open:
 mov x0,#-100
 mov x1,x20
 mov x2,#577
 mov x3,#420
 mov x8,#56
 svc #0
 cmn x0,#4
 b.eq .Lpayload_open
 tbnz x0,#63,.Lpayload_open_failed
 mov x19,x0
.Lpayload_write:
 ldp x1,x2,[x21],#16
 bl .Lstate_write_bytes
 cbnz w0,.Lpayload_close
 subs x22,x22,#1
 b.ne .Lpayload_write
.Lpayload_close:
 mov w23,w0
 mov x0,x19
 mov x8,#57
 svc #0
 cmp x0,#0
 cset w0,ne
 orr w0,w0,w23
 b .Lpayload_return
.Lpayload_open_failed:
 mov w0,#1
.Lpayload_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x29,x30,[sp],#64
 ret

.section .rodata
.p2align 3
.Lowned_alias_destinations:
 .quad __yomdphy_MOD_yrdphy
 .quad __yom_ygfl_MOD_ygfl
 .quad __yoerad_MOD_yrerad
 .quad __yoeaeratm_MOD_yreaeratm
 .quad __yoephli_MOD_yrephli
 .quad __yoeaerlid_MOD_yreaerlid
 .quad __yoeaersnk_MOD_yreaersnk
 .quad __yoeaersrc_MOD_yreaersrc
 .quad __yoeaervol_MOD_yreaervol
 .quad __yoephy_MOD_yrephy
 .quad __yomphy_MOD_yrphy
 .quad __yomphy0_MOD_yrphy0
 .quad __yomphy1_MOD_yrphy1
 .quad __yomphy2_MOD_yrphy2
 .quad __yomlouis_MOD_yrlouis
.Lfield_dimension_controls: .word 1,1,1,0,0,0,0,0,20,50
.Lconvection_controls: .word 19,21
.Lmodel_extension_shape: .ascii "R7MODEL1"
 .quad 4275088,120,320,1920,24
.section .data
.p2align 3
.Lmetadata_gather:
 .quad 0,1556112,0,448,.Lphysics_counts,1008,0,456,.Ldynamics_inputs,88
.Lfield_dimension_pairs:
 .quad 0,176,0,88,0,456,0,448,0,1096,0,88
.Lconvection_records:
 .quad 0,344,0,240,0,12,.Lconvection_thermal,24
.Lconvection_inputs:
 .quad 0,152,.Lphysical_constants,520,md2asm_owned_dynamical_namespace,24,0,8
.bss
.p2align 3
.global md2asm_owned_initial_model_owner
md2asm_owned_initial_model_owner:
.Lmodel_owner: .zero 8
.global md2asm_owned_thermal_stability_namespace
md2asm_owned_thermal_stability_namespace:
.Lthermal_stability_namespace: .zero 1920
.Lconvection_thermal: .zero 24
.p2align 3
.Lowned_alias_slots:
.global __yomdphy_MOD_yrdphy
.type __yomdphy_MOD_yrdphy,%object
__yomdphy_MOD_yrdphy: .zero 8
.size __yomdphy_MOD_yrdphy,8
.global __yom_ygfl_MOD_ygfl
.type __yom_ygfl_MOD_ygfl,%object
__yom_ygfl_MOD_ygfl: .zero 8
.size __yom_ygfl_MOD_ygfl,8
.global __yoerad_MOD_yrerad
.type __yoerad_MOD_yrerad,%object
__yoerad_MOD_yrerad: .zero 8
.size __yoerad_MOD_yrerad,8
.global __yoeaeratm_MOD_yreaeratm
.type __yoeaeratm_MOD_yreaeratm,%object
__yoeaeratm_MOD_yreaeratm: .zero 8
.size __yoeaeratm_MOD_yreaeratm,8
.global __yoephli_MOD_yrephli
.type __yoephli_MOD_yrephli,%object
__yoephli_MOD_yrephli: .zero 8
.size __yoephli_MOD_yrephli,8
.global __yoeaerlid_MOD_yreaerlid
.type __yoeaerlid_MOD_yreaerlid,%object
__yoeaerlid_MOD_yreaerlid: .zero 8
.size __yoeaerlid_MOD_yreaerlid,8
.global __yoeaersnk_MOD_yreaersnk
.type __yoeaersnk_MOD_yreaersnk,%object
__yoeaersnk_MOD_yreaersnk: .zero 8
.size __yoeaersnk_MOD_yreaersnk,8
.global __yoeaersrc_MOD_yreaersrc
.type __yoeaersrc_MOD_yreaersrc,%object
__yoeaersrc_MOD_yreaersrc: .zero 8
.size __yoeaersrc_MOD_yreaersrc,8
.global __yoeaervol_MOD_yreaervol
.type __yoeaervol_MOD_yreaervol,%object
__yoeaervol_MOD_yreaervol: .zero 8
.size __yoeaervol_MOD_yreaervol,8
.global __yoephy_MOD_yrephy
.type __yoephy_MOD_yrephy,%object
__yoephy_MOD_yrephy: .zero 8
.size __yoephy_MOD_yrephy,8
.global __yomphy_MOD_yrphy
.type __yomphy_MOD_yrphy,%object
__yomphy_MOD_yrphy: .zero 8
.size __yomphy_MOD_yrphy,8
.global __yomphy0_MOD_yrphy0
.type __yomphy0_MOD_yrphy0,%object
__yomphy0_MOD_yrphy0: .zero 8
.size __yomphy0_MOD_yrphy0,8
.global __yomphy1_MOD_yrphy1
.type __yomphy1_MOD_yrphy1,%object
__yomphy1_MOD_yrphy1: .zero 8
.size __yomphy1_MOD_yrphy1,8
.global __yomphy2_MOD_yrphy2
.type __yomphy2_MOD_yrphy2,%object
__yomphy2_MOD_yrphy2: .zero 8
.size __yomphy2_MOD_yrphy2,8
.global __yomlouis_MOD_yrlouis
.type __yomlouis_MOD_yrlouis,%object
__yomlouis_MOD_yrlouis: .zero 8
.size __yomlouis_MOD_yrlouis,8

.section .note.GNU-stack,"",%progbits

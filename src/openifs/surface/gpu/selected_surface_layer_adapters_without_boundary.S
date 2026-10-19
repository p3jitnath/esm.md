// Contract: skills/md2asm-gpu/references/openifs/surface/surface_boundary_adapter.md.
/* Contract: skills/md2asm/references/openifs/surface/surface_private_bindings.md. */
/* Direct AArch64 layer equations. Private candidates: no numerical execution or admission. */
#include "selected_surface_layer_helpers.inc.S"
.macro INVOKE count,symbol
 mov x10,#8
.Lsl_send_\@:
 .if \count>8
 CARG x9,0
 ADDR x11,sp,2048
 ldr x9,[x11,x10,lsl #3]
 sub x12,x10,#8
 str x9,[sp,x12,lsl #3]
 add x10,x10,#1
 cmp x10,#\count
 b.lt .Lsl_send_\@
 .endif
 CARG x0,0
 CARG x1,1
 CARG x2,2
 CARG x3,3
 CARG x4,4
 CARG x5,5
 CARG x6,6
 CARG x7,7
 CALL \symbol
.endm
.macro CHECK1 index,required
 ARG x0,\index
 ldp x9,x10,[x0,#48]
 sub x9,x10,x9
 add x9,x9,#1
 cmp x9,\required
 b.lt .Lsl_bad
.endm
.macro CHECK2 index,rows,cols
 CHECK1 \index,\rows
 ARG x0,\index
 ldp x9,x10,[x0,#72]
 sub x9,x10,x9
 add x9,x9,#1
 cmp x9,\cols
 b.lt .Lsl_bad
.endm
// Descriptor element operations use a zero-based position in each actual owner.
.Lsl_load1:
 ldr x9,[x0]
 ldr x10,[x0,#40]
 mul x10,x1,x10
 ldr d0,[x9,x10,lsl #3]
 ret
.Lsl_load2:
 ldr x9,[x0]
 ldr x10,[x0,#40]
 ldr x11,[x0,#64]
 mul x10,x1,x10
 madd x10,x2,x11,x10
 ldr d0,[x9,x10,lsl #3]
 ret
.Lsl_store1:
 ldr x9,[x0]
 ldr x10,[x0,#40]
 mul x10,x1,x10
 str d0,[x9,x10,lsl #3]
 ret
// Copy one complete row profile. x0 source, x1 destination, x2 row position, x3 levels.
.Lsl_copy_profile:
 ldr x9,[x0]
 ldr x10,[x1]
 ldr x11,[x0,#40]
 ldr x12,[x1,#40]
 mul x11,x11,x2
 mul x12,x12,x2
 add x9,x9,x11,lsl #3
 add x10,x10,x12,lsl #3
 ldr x11,[x0,#64]
 ldr x12,[x1,#64]
 lsl x11,x11,#3
 lsl x12,x12,#3
 mov x13,#0
.Lsl_profile:
 cmp x13,x3
 b.ge .Lsl_profile_done
 ldr d0,[x9]
 str d0,[x10]
 add x9,x9,x11
 add x10,x10,x12
 add x13,x13,#1
 b .Lsl_profile
.Lsl_profile_done:
 ret
// Replicate d0 through one private row profile.
.Lsl_replicate_profile:
 ldr x9,[x0]
 ldr x10,[x0,#40]
 mul x10,x10,x1
 add x9,x9,x10,lsl #3
 ldr x10,[x0,#64]
 lsl x10,x10,#3
 mov x11,#0
.Lsl_replicate:
 cmp x11,x2
 b.ge .Lsl_replicate_done
 str d0,[x9]
 add x9,x9,x10
 add x11,x11,#1
 b .Lsl_replicate
.Lsl_replicate_done:
 ret

ENTER md2asm_surface_boundary_layer_layout_r2_7358525,7,16384
 HOOK .Lsl_bc_layer_name,12,0,3608
#include "selected_surfbc_layer_argument_addresses.inc.S"
 INVOKE 42,md2asm_surface_boundary_adapter_7358525
 HOOK .Lsl_bc_layer_name,12,1,3608
 EXIT 16384
.size md2asm_surface_boundary_layer_layout_r2_7358525,.-md2asm_surface_boundary_layer_layout_r2_7358525

// Complete external SURFBC storage and physical checks, with its accepted direct tile child.

ENTER md2asm_snow_initialisation_adapter_7358525,18,16384
 ARG x9,3
 ldrsw x21,[x9]
 cmp x21,#1
 b.lt .Lsl_bad
 cmp x21,#4096
 b.gt .Lsl_bad
 ARG x9,1
 ldrsw x9,[x9]
 cmp x9,#1
 b.lt .Lsl_bad
 ARG x10,2
 ldrsw x10,[x10]
 cmp x10,x9
 b.lt .Lsl_bad
 cmp x10,x21
 b.gt .Lsl_bad
 ARG x9,4
 ldrsw x22,[x9]
 cmp x22,#1
 b.lt .Lsl_bad
 ARG x9,5
 ldrsw x23,[x9]
 cmp x23,#1
 b.lt .Lsl_bad
 ARG x9,6
 ldrsw x24,[x9]
 cmp x24,#1
 b.lt .Lsl_bad
 HOOK .Lsl_ws_name,6,0,3608
 ARG x0,0
 CALL __yos_surf_MOD_get_surf
 cbz x0,.Lsl_bad
 mov x20,x0
 CHECK1 8,x21
 CHECK2 9,x21,x24
 CHECK1 10,x21
 CHECK1 13,x21
 CHECK1 12,x21
 CHECK1 12,x21
 CHECK2 11,x21,x22
 CHECK2 14,x21,x23
 CHECK2 15,x21,x23
 CHECK2 16,x21,x23
 CHECK2 17,x21,x23
 ARG x0,1
 PUTARG x0,0
 ARG x0,2
 PUTARG x0,1
 ARG x0,3
 PUTARG x0,2
 ARG x0,5
 PUTARG x0,3
 mov x10,#7
.Lsl_ws_arguments:
 ldr x0,[x19,x10,lsl #3]
 sub x11,x10,#3
 ADDR x12,sp,2048
 str x0,[x12,x11,lsl #3]
 add x10,x10,#1
 cmp x10,#18
 b.lt .Lsl_ws_arguments
 ADDR x0,x20,3816
 PUTARG x0,15
 ADDR x0,x20,7680
 PUTARG x0,16
 INVOKE 17,md2asm_snow_warm_start
 HOOK .Lsl_ws_name,6,1,3608
 EXIT 16384
.size md2asm_snow_initialisation_adapter_7358525,.-md2asm_snow_initialisation_adapter_7358525

ENTER md2asm_snow_initialisation_layer_layout_r2_7358525,6,16384
 ARG x20,2
 ldrsw x21,[x20,#12]
 ldrsw x22,[x20]
 ldrsw x23,[x20,#4]
 ldrsw x24,[x20,#64]
 cmp x21,#1
 b.lt .Lsl_bad
 cmp x21,#4096
 b.gt .Lsl_bad
 cmp x22,#1
 b.lt .Lsl_bad
 cmp x23,x22
 b.lt .Lsl_bad
 cmp x23,x21
 b.gt .Lsl_bad
 cmp x24,#1
 b.lt .Lsl_bad
 cmp x24,#64
 b.gt .Lsl_bad
 sub x22,x22,#1
 HOOK .Lsl_ws_layer_name,12,0,3608
 mul x25,x21,x24
 lsl x0,x25,#5
 CALL malloc
 cbz x0,.Lsl_bad
 mov x28,x0
 str x28,[sp,#3600]
 // Four complete private owners. Only source-selected rows are initialised.
 SPADDR x0,4608
 mov x1,x28
 mov x2,x21
 mov x3,x24
 mov x4,#1
 mov x5,x21
 bl .Lsl_make2
 SPADDR x0,4704
 add x1,x28,x25,lsl #3
 mov x2,x21
 mov x3,x24
 mov x4,#1
 mov x5,x21
 bl .Lsl_make2
 SPADDR x0,4800
 add x1,x28,x25,lsl #4
 mov x2,x21
 mov x3,x24
 mov x4,#1
 mov x5,x21
 bl .Lsl_make2
 SPADDR x0,4896
 mov x9,#24
 madd x1,x25,x9,x28
 mov x2,x21
 mov x3,x24
 mov x4,#1
 mov x5,x21
 bl .Lsl_make2

#include "selected_snow_initial_views.inc.S"
 ARG x0,4
 ADDR x0,x0,192
 mov x1,x21
 mov x2,x24
 bl .Lsl_bounds2
 SPADDR x0,5008
 mov x1,x21
 bl .Lsl_bounds1
 SPADDR x0,5080
 mov x1,x21
 bl .Lsl_bounds1

 mov x26,x22
.Lsl_ws_prepare_rows:
 cmp x26,x23
 b.ge .Lsl_ws_call
 // Whole snow mass profile, then each source-ordered replication.
 ARG x0,4
 ADDR x0,x0,192
 SPADDR x1,4608
 mov x2,x26
 mov x3,x24
 bl .Lsl_copy_profile
 SPADDR x0,5008
 mov x1,x26
 bl .Lsl_load1
 SPADDR x0,4704
 mov x1,x26
 mov x2,x24
 bl .Lsl_replicate_profile
 SPADDR x0,5080
 mov x1,x26
 bl .Lsl_load1
 SPADDR x0,4800
 mov x1,x26
 mov x2,x24
 bl .Lsl_replicate_profile
 fmov d0,xzr
 SPADDR x0,4896
 mov x1,x26
 mov x2,x24
 bl .Lsl_replicate_profile
 add x26,x26,#1
 b .Lsl_ws_prepare_rows
.Lsl_ws_call:
#include "selected_surfws_layer_argument_addresses.inc.S"
 INVOKE 18,md2asm_snow_initialisation_adapter_7358525
 // Closing field plane views, in the original MP9 then MP1 order.
#include "selected_snow_closing_views.inc.S"
 mov x26,x22
.Lsl_ws_close_rows:
 cmp x26,x23
 b.ge .Lsl_ws_release
 SPADDR x0,4608
 ARG x1,4
 ADDR x1,x1,192
 mov x2,x26
 mov x3,x24
 bl .Lsl_copy_profile
#include "selected_snow_closing_copies.inc.S"
 add x26,x26,#1
 b .Lsl_ws_close_rows
.Lsl_ws_release:
 ldr x0,[sp,#3600]
 CALL free
 HOOK .Lsl_ws_layer_name,12,1,3608
 EXIT 16384
.size md2asm_snow_initialisation_layer_layout_r2_7358525,.-md2asm_snow_initialisation_layer_layout_r2_7358525

ENTER md2asm_surface_turbulence_layer_sea_r2_layout_r2_7358525,18,32768
 ARG x20,1
 // Selected original switches. Unknown controls fail before a numerical write.
 ADDR x9,x20,1577992
 ldr w9,[x9]
 cbnz w9,.Lsl_bad
 ADDR x9,x20,1577996
 ldr w9,[x9]
 cbnz w9,.Lsl_bad
 ADDR x9,x20,1562992
 ldr w9,[x9]
 cbnz w9,.Lsl_bad
 ADDR x9,x20,1552928
 ldr w9,[x9]
 cbnz w9,.Lsl_bad
 ADDR x9,x20,1553144
 ldr w9,[x9]
 cbnz w9,.Lsl_bad
 ARG x9,9
 ldr x9,[x9]
 cbz x9,.Lsl_bad
 ldr w9,[x9]
 cbnz w9,.Lsl_bad
 ARG x9,2
 ldrsw x21,[x9,#12]
 ldrsw x22,[x9,#48]
 ldrsw x23,[x9]
 ldrsw x24,[x9,#4]
 cmp x21,#1
 b.lt .Lsl_bad
 cmp x21,#4096
 b.gt .Lsl_bad
 cmp x22,#3
 b.lt .Lsl_bad
 cmp x22,#512
 b.gt .Lsl_bad
 cmp x23,#1
 b.lt .Lsl_bad
 cmp x24,x23
 b.lt .Lsl_bad
 cmp x24,x21
 b.gt .Lsl_bad
 sub x23,x23,#1
 HOOK .Lsl_turb_name,16,0,3608
 mov w9,#70
 strb w9,[sp,#4000]
 mov w9,#2
 str w9,[sp,#4016]
 mov w9,#12
 str w9,[sp,#4020]
 str wzr,[sp,#4024]
 mov w9,#6
 str w9,[sp,#4028]
 mov w9,#7
 str w9,[sp,#4032]
 mov w9,#1
 str w9,[sp,#4036]
 GLOBAL x0,__yomcst_MOD_rcpd
 mov x1,xzr
 SPADDR x2,4040
 mov w3,#1
 mov w4,#0
 mov w5,#1
 mov w6,#0
 CALL md2asm_gpu_turbulence_local_host
 // Five source vectors, twelve diagnostic columns and twelve carbon-work columns.
 mov x9,#232
 mul x0,x21,x9
 add x0,x0,#16
 CALL malloc
 cbz x0,.Lsl_bad
 mov x25,x0
 str x25,[sp,#3600]
 add x9,x25,x21,lsl #3
 str x9,[sp,#4056] // ZEVAPMU
 add x9,x25,x21,lsl #4
 str x9,[sp,#4064] // ZAN
 mov x9,#24
 madd x9,x21,x9,x25
 str x9,[sp,#4072] // ZRD
 add x9,x25,x21,lsl #5
 str x9,[sp,#4080] // ZRSOIL_STR
 mov x9,#40
 madd x9,x21,x9,x25
 str x9,[sp,#4088] // ZEXDIAG
 mov x9,#136
 madd x9,x21,x9,x25
 str x9,[sp,#4096] // ZDHCO2S
 mov x9,#232
 madd x9,x21,x9,x25
 str x9,[sp,#4104] // ZGP2DSPP has the genuine zero extent
 // Raw child addresses and exact source component planes.
#include "selected_turbulence_argument_addresses.inc.S"
 // Latitude and longitude are copied only into source-requested diagnostic rows.
 mov x26,x23
.Lsl_turb_latlon:
 cmp x26,x24
 b.ge .Lsl_turb_call
 CARG x9,54
 ldr d0,[x9,x26,lsl #3]
 ldr x9,[sp,#4088]
 mov x10,#10
 madd x10,x21,x10,x26
 str d0,[x9,x10,lsl #3]
 ARG x0,3
 ADDR x0,x0,976
 mov x1,x26
 bl .Lsl_load1
 ldr x9,[sp,#4088]
 mov x10,#11
 madd x10,x21,x10,x26
 str d0,[x9,x10,lsl #3]
 add x26,x26,#1
 b .Lsl_turb_latlon
.Lsl_turb_call:
 // NRFTOTAL is zero, so the source stochastic preparation loop has zero trips.
 mov x9,#1
 str x9,[sp,#1288]
 INVOKE 169,md2asm_vertical_diffusion_outer_sea_r2_7358525
 // Prepare the three closing diagnostic owners and the original land selector.
#include "selected_turbulence_closing_addresses.inc.S"
 mov x26,x23
.Lsl_turb_shallow:
 cmp x26,x24
 b.ge .Lsl_turb_gwd_start
 ldr x9,[sp,#4120]
 mov w10,#1
 str w10,[x9,x26,lsl #2]
 add x26,x26,#1
 b .Lsl_turb_shallow
.Lsl_turb_gwd_start:
 mov x26,x23
.Lsl_turb_gwd:
 cmp x26,x24
 b.ge .Lsl_turb_evap_start
 ldr x9,[sp,#4128]
 ldr x10,[sp,#4136]
 CARG x11,148
 CARG x12,149
 madd x13,x22,x21,x26
 ldr d0,[x11,x13,lsl #3]
 str d0,[x9,x26,lsl #3]
 ldr d1,[x12,x13,lsl #3]
 str d1,[x10,x26,lsl #3]
 add x26,x26,#1
 b .Lsl_turb_gwd
.Lsl_turb_evap_start:
 ldr x0,[sp,#4152]
 ldr x1,[sp,#4056]
 ldr x2,[sp,#4144]
 mov w3,w21
 mov w4,w23
 mov w5,w24
 mov w6,#1
 CALL md2asm_gpu_turbulence_local_host
.Lsl_turb_release:
 ldr x0,[sp,#3600]
 CALL free
 HOOK .Lsl_turb_name,16,1,3608
 EXIT 32768
.size md2asm_surface_turbulence_layer_sea_r2_layout_r2_7358525,.-md2asm_surface_turbulence_layer_sea_r2_layout_r2_7358525
.Lsl_bad:
 brk #0x7c1
 b .Lsl_bad
.section .rodata
.p2align 3
.Lsl_epsilon: .double 0.01
.Lsl_bc_layer_name: .ascii "SURFBC_LAYER"
.Lsl_ws_layer_name: .ascii "SURFWS_LAYER"
.Lsl_turb_name: .ascii "TURBULENCE_LAYER"
.Lsl_bc_name: .ascii "SURFBC"
.Lsl_ws_name: .ascii "SURFWS"
.section .note.GNU-stack,"",%progbits

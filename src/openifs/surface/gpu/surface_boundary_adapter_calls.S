// Contract: skills/md2fort-gpu/references/openifs/surface/surface_boundary_adapter.md.
/* Contract: skills/md2fort/references/openifs/surface/surface_private_bindings.md. */
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

ENTER md2asm_surface_boundary_adapter_7358525,42,16384
 ARG x9,3
 ldrsw x21,[x9]
 cmp x21,#1
 b.lt .Lsl_bad
 cmp x21,#4096
 b.gt .Lsl_bad
 ARG x9,1
 ldrsw x22,[x9]
 cmp x22,#1
 b.lt .Lsl_bad
 ARG x9,2
 ldrsw x23,[x9]
 cmp x23,x21
 b.gt .Lsl_bad
 cmp x22,x23
 b.gt .Lsl_bad
 sub x22,x22,#1
 ARG x9,4
 ldrsw x24,[x9]
 cmp x24,#1
 b.lt .Lsl_bad
 cmp x24,#64
 b.gt .Lsl_bad
 ARG x9,5
 ldrsw x28,[x9]
 cmp x28,#1
 b.lt .Lsl_bad
 cmp x28,#64
 b.gt .Lsl_bad
 HOOK .Lsl_bc_name,6,0,3608
 ARG x0,0
 CALL __yos_surf_MOD_get_surf
 cbz x0,.Lsl_bad
 mov x20,x0
 // Original source bounds, including the shorter PGEMU owner.
 CHECK1 6,x21
 CHECK1 7,x21
 CHECK1 8,x21
 CHECK1 9,x21
 CHECK1 10,x21
 CHECK1 11,x21
 CHECK1 12,x21
 CHECK1 13,x21
 CHECK1 14,x21
 CHECK1 15,x21
 CHECK1 16,x21
 CHECK1 17,x21
 CHECK1 18,x21
 CHECK1 19,x21
 CHECK1 20,x21
 CHECK1 21,x21
 CHECK1 28,x21
 CHECK1 22,x23
 CHECK2 23,x21,x28
 CHECK1 24,x21
 CHECK2 25,x21,x28
 CHECK1 26,x21
 CHECK1 27,x21
 CHECK1 30,x21
 CHECK1 29,x21
 CHECK1 31,x21
 CHECK1 32,x21
 CHECK1 33,x21
 CHECK1 34,x21
 CHECK1 35,x21
 CHECK1 36,x21
 CHECK1 38,x21
 CHECK1 39,x21
 CHECK1 40,x21
 CHECK2 41,x21,x24
 mov x10,#1
.Lsl_bc_arguments:
 ldr x9,[x19,x10,lsl #3]
 sub x11,x10,#1
 ADDR x12,sp,2048
 str x9,[x12,x11,lsl #3]
 add x10,x10,#1
 cmp x10,#42
 b.lt .Lsl_bc_arguments
 ADDR x0,x20,7680
 PUTARG x0,41
 ADDR x0,x20,10336
 PUTARG x0,42
 ADDR x0,x20,4104
 PUTARG x0,43
 ADDR x0,x20,5640
 PUTARG x0,44
 INVOKE 45,md2asm_surface_tile_boundary
 // ZSUM and ZSUM2 have complete KLON owners and start with positive zero.
 lsl x0,x21,#4
 CALL malloc
 cbz x0,.Lsl_bad
 mov x25,x0
 str x25,[sp,#3600]
 mov x10,#0
.Lsl_bc_zero:
 cmp x10,x21
 b.ge .Lsl_bc_zero_done
 str xzr,[x25,x10,lsl #3]
 add x11,x10,x21
 str xzr,[x25,x11,lsl #3]
 add x10,x10,#1
 b .Lsl_bc_zero
.Lsl_bc_zero_done:
 mov x26,#0
.Lsl_bc_tiles:
 cmp x26,x24
 b.ge .Lsl_bc_final_check
 mov x27,x22
.Lsl_bc_rows:
 cmp x27,x23
 b.ge .Lsl_bc_tile_sign
 ARG x0,41
 mov x1,x27
 mov x2,x26
 bl .Lsl_load2
 ldr d1,[x25,x27,lsl #3]
 // Adapter numerical region 0.
 sub sp,sp,#128
 stp x0,x1,[sp,#80]
 str d0,[sp,#96]
 str x17,[sp,#104]
 mrs x17,nzcv
 str x17,[sp,#112]
 str x30,[sp,#120]
 str xzr,[sp,#0]
 str xzr,[sp,#8]
 str xzr,[sp,#16]
 str xzr,[sp,#24]
 str xzr,[sp,#32]
 str xzr,[sp,#40]
 str xzr,[sp,#48]
 str xzr,[sp,#56]
 str xzr,[sp,#64]
 str d1,[sp,#0]
 str d0,[sp,#8]
 mov x0,sp
 mov w1,#0
 bl md2asm_gpu_soil_water_cell_host
 fmov d1,d0
 ldr d0,[sp,#96]
 ldr x17,[sp,#112]
 msr nzcv,x17
 ldr x30,[sp,#120]
 ldr x17,[sp,#104]
 ldp x0,x1,[sp,#80]
 add sp,sp,#128
 str d1,[x25,x27,lsl #3]
 ARG x0,35
 mov x1,x27
 bl .Lsl_load1
 fmov d1,#1.0
 // Adapter numerical region 1.
 sub sp,sp,#128
 stp x0,x1,[sp,#80]
 str d0,[sp,#96]
 str x17,[sp,#104]
 mrs x17,nzcv
 str x17,[sp,#112]
 str x30,[sp,#120]
 str xzr,[sp,#0]
 str xzr,[sp,#8]
 str xzr,[sp,#16]
 str xzr,[sp,#24]
 str xzr,[sp,#32]
 str xzr,[sp,#40]
 str xzr,[sp,#48]
 str xzr,[sp,#56]
 str xzr,[sp,#64]
 str d1,[sp,#0]
 str d0,[sp,#8]
 mov x0,sp
 mov w1,#1
 bl md2asm_gpu_soil_water_cell_host
 fmov d1,d0
 ldr d0,[sp,#96]
 ldr x17,[sp,#112]
 msr nzcv,x17
 ldr x30,[sp,#120]
 ldr x17,[sp,#104]
 ldp x0,x1,[sp,#80]
 add sp,sp,#128
 str d1,[sp,#3640]
 ARG x0,36
 mov x1,x27
 bl .Lsl_load1
 ldr d1,[sp,#3640]
 // Adapter numerical region 2.
 sub sp,sp,#128
 stp x0,x1,[sp,#80]
 str d0,[sp,#96]
 str x17,[sp,#104]
 mrs x17,nzcv
 str x17,[sp,#112]
 str x30,[sp,#120]
 str xzr,[sp,#0]
 str xzr,[sp,#8]
 str xzr,[sp,#16]
 str xzr,[sp,#24]
 str xzr,[sp,#32]
 str xzr,[sp,#40]
 str xzr,[sp,#48]
 str xzr,[sp,#56]
 str xzr,[sp,#64]
 str d1,[sp,#0]
 str d0,[sp,#8]
 mov x0,sp
 mov w1,#1
 bl md2asm_gpu_soil_water_cell_host
 fmov d1,d0
 ldr d0,[sp,#96]
 ldr x17,[sp,#112]
 msr nzcv,x17
 ldr x30,[sp,#120]
 ldr x17,[sp,#104]
 ldp x0,x1,[sp,#80]
 add sp,sp,#128
 add x9,x27,x21
 str d1,[x25,x9,lsl #3]
 add x27,x27,#1
 b .Lsl_bc_rows
.Lsl_bc_tile_sign:
 mov x27,x22
.Lsl_bc_sign_rows:
 cmp x27,x23
 b.ge .Lsl_bc_next_tile
 ARG x0,41
 mov x1,x27
 mov x2,x26
 bl .Lsl_load2
 // Adapter numerical region 3.
 sub sp,sp,#128
 stp x0,x1,[sp,#80]
 str d0,[sp,#96]
 str x17,[sp,#104]
 mrs x17,nzcv
 str x17,[sp,#112]
 str x30,[sp,#120]
 str xzr,[sp,#0]
 str xzr,[sp,#8]
 str xzr,[sp,#16]
 str xzr,[sp,#24]
 str xzr,[sp,#32]
 str xzr,[sp,#40]
 str xzr,[sp,#48]
 str xzr,[sp,#56]
 str xzr,[sp,#64]
 str d0,[sp,#0]
 str xzr,[sp,#8]
 mov x0,sp
 mov w1,#4
 bl md2asm_gpu_soil_water_cell_host
 msr nzcv,x0
 ldr d0,[sp,#96]
 ldr x30,[sp,#120]
 ldr x17,[sp,#104]
 ldp x0,x1,[sp,#80]
 add sp,sp,#128
 b.mi .Lsl_bad
 add x27,x27,#1
 b .Lsl_bc_sign_rows
.Lsl_bc_next_tile:
 add x26,x26,#1
 b .Lsl_bc_tiles
.Lsl_bc_final_check:
 // Freeze the source addition 1 + 0.01 as two FP64 operands.
 fmov d0,#1.0
 adr x9,.Lsl_epsilon
 ldr d1,[x9]
 // Adapter numerical region 4.
 sub sp,sp,#128
 stp x0,x1,[sp,#80]
 str d0,[sp,#96]
 str x17,[sp,#104]
 mrs x17,nzcv
 str x17,[sp,#112]
 str x30,[sp,#120]
 str xzr,[sp,#0]
 str xzr,[sp,#8]
 str xzr,[sp,#16]
 str xzr,[sp,#24]
 str xzr,[sp,#32]
 str xzr,[sp,#40]
 str xzr,[sp,#48]
 str xzr,[sp,#56]
 str xzr,[sp,#64]
 str d0,[sp,#0]
 str d1,[sp,#8]
 mov x0,sp
 mov w1,#0
 bl md2asm_gpu_soil_water_cell_host
 fmov d2,d0
 ldr d0,[sp,#96]
 ldr x17,[sp,#112]
 msr nzcv,x17
 ldr x30,[sp,#120]
 ldr x17,[sp,#104]
 ldp x0,x1,[sp,#80]
 add sp,sp,#128
 mov x27,x22
.Lsl_bc_total:
 cmp x27,x23
 b.ge .Lsl_bc_release
 ldr d0,[x25,x27,lsl #3]
 // Adapter numerical region 5.
 sub sp,sp,#128
 stp x0,x1,[sp,#80]
 str d0,[sp,#96]
 str x17,[sp,#104]
 mrs x17,nzcv
 str x17,[sp,#112]
 str x30,[sp,#120]
 str xzr,[sp,#0]
 str xzr,[sp,#8]
 str xzr,[sp,#16]
 str xzr,[sp,#24]
 str xzr,[sp,#32]
 str xzr,[sp,#40]
 str xzr,[sp,#48]
 str xzr,[sp,#56]
 str xzr,[sp,#64]
 str d0,[sp,#0]
 str d2,[sp,#8]
 mov x0,sp
 mov w1,#4
 bl md2asm_gpu_soil_water_cell_host
 msr nzcv,x0
 ldr d0,[sp,#96]
 ldr x30,[sp,#120]
 ldr x17,[sp,#104]
 ldp x0,x1,[sp,#80]
 add sp,sp,#128
 b.gt .Lsl_bad
 add x9,x27,x21
 ldr d0,[x25,x9,lsl #3]
 // Adapter numerical region 6.
 sub sp,sp,#128
 stp x0,x1,[sp,#80]
 str d0,[sp,#96]
 str x17,[sp,#104]
 mrs x17,nzcv
 str x17,[sp,#112]
 str x30,[sp,#120]
 str xzr,[sp,#0]
 str xzr,[sp,#8]
 str xzr,[sp,#16]
 str xzr,[sp,#24]
 str xzr,[sp,#32]
 str xzr,[sp,#40]
 str xzr,[sp,#48]
 str xzr,[sp,#56]
 str xzr,[sp,#64]
 str d0,[sp,#0]
 str xzr,[sp,#8]
 mov x0,sp
 mov w1,#4
 bl md2asm_gpu_soil_water_cell_host
 msr nzcv,x0
 ldr d0,[sp,#96]
 ldr x30,[sp,#120]
 ldr x17,[sp,#104]
 ldp x0,x1,[sp,#80]
 add sp,sp,#128
 b.mi .Lsl_bad
 add x27,x27,#1
 b .Lsl_bc_total
.Lsl_bc_release:
 mov x0,x25
 CALL free
 HOOK .Lsl_bc_name,6,1,3608
 EXIT 16384
.size md2asm_surface_boundary_adapter_7358525,.-md2asm_surface_boundary_adapter_7358525
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

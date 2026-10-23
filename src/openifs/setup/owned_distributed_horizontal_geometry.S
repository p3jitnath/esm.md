/* Distributed setup contract: skills/md2asm/references/openifs/setup/distributed_horizontal_geometry.md. */

.arch armv8.2-a
.text
.macro DG_CALL name
 bl \name
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Ldg_failed
.endm
.p2align 4
.global md2asm_complete_distributed_horizontal_geometry
.type md2asm_complete_distributed_horizontal_geometry,%function
md2asm_complete_distributed_horizontal_geometry:
 sub sp,sp,#224
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov w0,#2
 cbz x19,.Ldg_agree
 cbz x20,.Ldg_agree
 cbz x21,.Ldg_agree
 ldr x9,[x21]
 cmp x9,x19
 b.ne .Ldg_agree
 ldr w9,[x21,#24]
 cmp w9,#4
 b.ne .Ldg_agree
 ldr w9,[x19,#5144]
 cmp w9,#17
 b.ne .Ldg_agree
 ldr w9,[x19,#5160]
 movz w10,#31519
 movk w10,#1,lsl#16
 cmp w9,w10
 b.ne .Ldg_agree
 ldr x9,[x19,#14024]
 cbnz x9,.Ldg_agree
 adr x9,.Ldg_owners
 mov x10,#76
.Ldg_fresh:
 ldr w11,[x9],#4
 ldr x12,[x19,x11]
 cbnz x12,.Ldg_agree
 subs x10,x10,#1
 b.ne .Ldg_fresh
 mov w0,#0
.Ldg_agree:
 bl md2asm_agree_owned_distributed_partition_status
 cbnz w0,.Ldg_return
 ldr w9,[x21,#64]
 ldr w10,[x21,#936]
 stp w9,w10,[sp,#96]
 ldr x9,[x20]
 str x9,[sp,#104]
 ldr x9,[x20,#104]
 str x9,[sp,#112]
 add x0,x19,#4096
 add x0,x0,#136
 add x1,x19,#4096
 add x1,x1,#776
 add x2,sp,#112
 ldr x9,[sp,#104]
 str x9,[sp,#120]
 DG_CALL md2asm_initialize_operational_latitude_geometry
 mov x0,x19
 mov x1,x20
 mov x2,x21
 DG_CALL md2asm_initialize_distributed_laplacian
 mov x0,x19
 add x1,sp,#96
 DG_CALL md2asm_initialize_distributed_spherical_grid
 ldr w9,[x19,#5172]
 ldr w10,[x19,#5212]
 stp w9,w10,[sp,#128]
 ldr w9,[x19,#5196]
 stp w9,wzr,[sp,#136]
 mov x9,#14616
 add x0,x19,x9
 add x1,sp,#128
 ldr x2,[x19,#3912]
 ldr x3,[x19,#4040]
 mov x9,#7512
 add x4,x19,x9
 DG_CALL md2asm_initialize_distributed_spectral_geometry_maps
 ldr x9,[x19,#7512]
 str x9,[sp,#144]
 ldr x9,[x19,#7544]
 ldr x10,[x19,#7552]
 stp x9,x10,[sp,#152]
 ldr x9,[x20,#104]
 str x9,[sp,#168]
 ldr x9,[x20]
 str x9,[sp,#176]
 ldr x9,[x20,#96]
 str x9,[sp,#184]
 mov x0,x19
 add x1,sp,#144
 add x2,sp,#96
 DG_CALL md2asm_initialize_distributed_spherical_geometry
 mov x0,x19
 ldr w1,[x21,#64]
 add x2,x21,#384
 DG_CALL md2asm_initialize_distributed_local_geometry_maps
 mov x0,x19
 DG_CALL md2asm_allocate_distributed_orography_owners
 mov w0,#0
 b .Ldg_return
.Ldg_failed:
 str w0,[sp,#88]
 mov x0,x19
 bl md2asm_release_distributed_horizontal_geometry
 ldr w0,[sp,#88]
.Ldg_return:
 ldr x18,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#224
 ret
.size md2asm_complete_distributed_horizontal_geometry,.-md2asm_complete_distributed_horizontal_geometry
.global md2asm_release_distributed_horizontal_geometry
.type md2asm_release_distributed_horizontal_geometry,%function
md2asm_release_distributed_horizontal_geometry:
 stp x29,x30,[sp,#-64]!
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 bl md2asm_release_distributed_orography_owners
 adr x20,.Ldg_owners
 mov x21,#78
.Ldg_release:
 ldr w9,[x20],#4
 str w9,[sp,#48]
 ldr x0,[x19,x9]
 cbz x0,.Ldg_release_next
 bl free
 ldr w9,[sp,#48]
 str xzr,[x19,x9]
.Ldg_release_next:
 subs x21,x21,#1
 b.ne .Ldg_release
 mov w0,#0
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.size md2asm_release_distributed_horizontal_geometry,.-md2asm_release_distributed_horizontal_geometry
.section .rodata
.p2align 2
.Ldg_owners:
 .word 4232,4296,4360,4424,4488,4552,4616,4680,4744,3656,3720,3784,3848,3912,3976,4040,4104,4168,7896,14616,14704,8536,8600,8664,8728,8792,8856,8920,8984,9048,9112,9176,9240,9304,9368,9432,9496,9560,9624,9688,9752,9816,9880,9944,8088,8152,8216,8280,8344,8408,10008,10096,10184,10272,10360,10448,10536,10624,10712,10800,10888,10976,11064,11152,11240,11328,11416,11504,11592,11680,11768,11856,11944,8472,8024,4808,7576,7704
.section .note.GNU-stack,"",%progbits

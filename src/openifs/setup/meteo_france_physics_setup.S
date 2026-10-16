/* Contract: skills/md2asm/references/openifs/setup/meteo_france_physics_setup.md.
 * x0 text,x1 bytes,x2 Geometry-context20400,x3 MODEL4275088,x4 constants520,
 * x5 {CAPEptr,32,CLIptr,272},x6 {LECMWF,NUNDEFLD,LSFORCS}. Return0/2.
 * Complete mapped/disjoint/nonwrapping ranges and child domains are required.
 */
.arch armv8.2-a
.text
.p2align 4
.macro MF_ADDR dst,base,offset
 movz \dst,#(\offset & 65535)
 movk \dst,#((\offset >> 16) & 65535),lsl #16
 add \dst,\base,\dst
.endm
.global md2asm_initialize_meteo_france_physics
.type md2asm_initialize_meteo_france_physics,%function
md2asm_initialize_meteo_france_physics:
 cbz x0,.Lmf_bad_leaf
 cbz x1,.Lmf_bad_leaf
 cmp x1,#64,lsl #12
 b.hi .Lmf_bad_leaf
 cbz x2,.Lmf_bad_leaf
 cbz x3,.Lmf_bad_leaf
 cbz x4,.Lmf_bad_leaf
 cbz x5,.Lmf_bad_leaf
 cbz x6,.Lmf_bad_leaf
 orr x9,x2,x3
 orr x9,x9,x4
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lmf_bad_leaf
 tst x6,#3
 b.ne .Lmf_bad_leaf
 mrs x9,fpcr
 cbnz x9,.Lmf_bad_leaf
 ldr w9,[x6]
 cmp w9,#1
 b.ne .Lmf_bad_leaf
 ldp x9,x10,[x5]
 cbz x9,.Lmf_bad_leaf
 tst x9,#7
 b.ne .Lmf_bad_leaf
 cmp x10,#32
 b.lo .Lmf_bad_leaf
 ldp x9,x10,[x5,#16]
 cbz x9,.Lmf_bad_leaf
 tst x9,#7
 b.ne .Lmf_bad_leaf
 cmp x10,#272
 b.lo .Lmf_bad_leaf
 ldr w9,[x2,#5224]
 cmp w9,#19
 b.ne .Lmf_bad_leaf
 ldr x9,[x2,#16]
 ldr x10,[x2,#80]
 cbz x9,.Lmf_bad_leaf
 cbz x10,.Lmf_bad_leaf
 orr x9,x9,x10
 ldr x10,[x2,#3336]
 cbz x10,.Lmf_bad_leaf
 orr x9,x9,x10
 tst x9,#7
 b.ne .Lmf_bad_leaf
 MF_ADDR x9,x3,4218352
 ldp w10,w11,[x9]
 orr w10,w10,w11
 cbnz w10,.Lmf_bad_leaf
 MF_ADDR x9,x3,4218184
 ldr w9,[x9]
 cbnz w9,.Lmf_bad_leaf
 MF_ADDR x9,x3,4143760
 ldr w10,[x9,#920]
 ldr w11,[x9,#932]
 orr w10,w10,w11
 cbnz w10,.Lmf_bad_leaf
 ldr w10,[x9,#844]
 cbnz w10,.Lmf_bad_leaf
 ldr w10,[x9,#856]
 cmp w10,#1
 b.hi .Lmf_bad_leaf
 ldr w10,[x9]
 sub w10,w10,#1
 cmp w10,#99
 b.hi .Lmf_bad_leaf
 sub sp,sp,#512
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 MF_ADDR x26,x22,4143760
 bl __errno_location
 str x0,[sp,#104]
 ldr w9,[x0]
 str w9,[sp,#112]
 adrp x27,.Lmf_empty_groups
 add x27,x27,:lo12:.Lmf_empty_groups
 mov w28,#9
.Lmf_check_groups:
 mov x0,x19
 mov x1,x20
 ldp x2,x3,[x27],#16
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lmf_bad_frame
 subs w28,w28,#1
 b.ne .Lmf_check_groups
 /* Source declaration values, with all other TPHY3 bytes retained. */
 MF_ADDR x0,x22,4150168
 mov x1,#5376
 bl md2asm_declare_legacy_radiation_parameters
 cbnz w0,.Lmf_bad_frame
 /* SUPHY0. */
 stp x26,xzr,[sp,#128]
 mov x9,#1096
 str x9,[sp,#136]
 ldr x9,[x23,#96]
 ldr x10,[x21,#7480]
 stp x9,x10,[sp,#144]
 MF_ADDR x9,x22,4218184
 ldr w9,[x9]
 ldr w10,[x25]
 stp w9,w10,[sp,#160]
 stp wzr,wzr,[sp,#168]
 mov x0,x19
 mov x1,x20
 MF_ADDR x2,x22,4144856
 mov x3,#3456
 add x4,sp,#128
 bl md2asm_initialize_atmospheric_physics_parameters
 cbnz w0,.Lmf_bad_frame
 /* SUPHY1. */
 mov x0,x19
 mov x1,x20
 mov x2,x23
 MF_ADDR x3,x22,4148312
 MF_ADDR x4,x22,4202320
 mov x5,#1696
 mov x6,#15864
 bl md2asm_initialize_surface_exchange_parameters
 cbnz w0,.Lmf_bad_frame
 /* SUPHY2. */
 ldr x9,[x21,#16]
 mov x10,#160
 stp x9,x10,[sp,#176]
 ldr x9,[x21,#80]
 stp x9,x10,[sp,#192]
 mov w9,#19
 ldr w10,[x25]
 stp w9,w10,[sp,#208]
 mov x0,x19
 mov x1,x20
 MF_ADDR x2,x22,4150008
 mov x3,#160
 add x4,sp,#176
 bl md2asm_initialize_physics_time_controls
 cbnz w0,.Lmf_bad_frame
 /* SUPHY3. */
 mov x0,x19
 mov x1,x20
 MF_ADDR x2,x22,4150168
 mov x3,#5376
 mov x4,x26
 mov x5,#1096
 bl md2asm_initialize_legacy_radiation_parameters
 cbnz w0,.Lmf_bad_frame
 /* SUTOPH and SUNORGWD use the same owned full-level pressures. */
 MF_ADDR x0,x22,4201824
 ldr x1,[x21,#3336]
 mov x9,#5224
 add x2,x21,x9
 bl md2asm_initialize_top_physics_parameters_raw
 MF_ADDR x0,x22,4219496
 ldr x1,[x21,#3336]
 mov w2,#19
 bl md2asm_initialize_nonorographic_wave_parameters_raw
 /* VAL923 stays before SUCAPE in the original caller. */
 ldr x0,[x24,#16]
 ldr x1,[x24,#24]
 ldr w2,[x26,#856]
 bl md2asm_initialize_land_surface_reference_parameters
 cbnz w0,.Lmf_bad_frame
 ldr x0,[x24]
 ldr x1,[x21,#16]
 ldr x2,[x21,#80]
 mov w3,#19
 ldr w4,[x26]
 bl md2asm_initialize_convective_energy_controls_raw
 /* SUPARAR, with its live source GFL component activity. */
 MF_ADDR x9,x22,4218352
 ldp w10,w11,[x9]
 add x12,sp,#344
 stp w11,w10,[x12]
 ldr w10,[x26,#832]
 ldr w11,[x26,#840]
 stp w10,w11,[x12,#8]
 MF_ADDR x9,x22,800128 /* GFLD192 + YH pointer799936 */
 ldr x9,[x9]
 ldr w10,[x9,#64]
 ldr w11,[x25,#4]
 stp w10,w11,[x12,#16]
 ldr w10,[x25,#8]
 stp w10,wzr,[x12,#24]
 mov x0,x19
 mov x1,x20
 MF_ADDR x2,x22,4218440
 mov x3,#904
 add x4,sp,#344
 bl md2asm_initialize_alternative_physics_parameters
 cbnz w0,.Lmf_bad_frame
 mov w28,#0
 b .Lmf_return
.Lmf_bad_frame:
 mov w28,#2
.Lmf_return:
 ldr x9,[sp,#104]
 ldr w10,[sp,#112]
 str w10,[x9]
 mov w0,w28
 ldr x28,[sp,#96]
 ldp x26,x27,[sp,#80]
 ldp x24,x25,[sp,#64]
 ldp x22,x23,[sp,#48]
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#512
 ret
.Lmf_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_meteo_france_physics,.-md2asm_initialize_meteo_france_physics
.section .rodata
.p2align 3
.Lmf_empty_groups:
 .xword .Lmf_phy0,7,.Lmf_phy1,7,.Lmf_vdoz,7,.Lmf_phy2,7,.Lmf_phy3,7
 .xword .Lmf_toph,7,.Lmf_norgwd,9,.Lmf_cape,7,.Lmf_parar,8
.Lmf_phy0:.ascii "NAMPHY0"
.Lmf_phy1:.ascii "NAMPHY1"
.Lmf_vdoz:.ascii "NAMVDOZ"
.Lmf_phy2:.ascii "NAMPHY2"
.Lmf_phy3:.ascii "NAMPHY3"
.Lmf_toph:.ascii "NAMTOPH"
.Lmf_norgwd:.ascii "NAMNORGWD"
.Lmf_cape:.ascii "NAMCAPE"
.Lmf_parar:.ascii "NAMPARAR"
.section .note.GNU-stack,"",%progbits

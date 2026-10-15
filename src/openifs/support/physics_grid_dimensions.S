/* Physics grid dimension metadata, revision 1.
 * Source arpifs/module/ecphys_dimension_type_mod.F90, original INIT/UPDATE.
 * Contract skills/md2asm/references/openifs/support/physics_grid_dimensions.md.
 * Raw initialization x0 dimensions, x1 geometry, x2 model, x3 surface.
 * Raw update x0 dimensions, w1 block, w2 active rows, w3 global start,
 * x4 latitude pointer descriptor. Caller provides the complete valid spans.
 * Dimension bytes192; source bytes17096/4275088/18224; descriptor bytes64.
 * Integer-only leaves. No stack, library, Fortran constructor or vtable.
 * Preserve x18..x30, vectors, FPCR/FPSR and errno. Return w0 zero.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialise_physics_dimensions
.type md2asm_initialise_physics_dimensions,%function
md2asm_initialise_physics_dimensions:
 adrp x4,.Lsource_counts
 add x4,x4,:lo12:.Lsource_counts
 mov w5,#26
.Lcopy_count:
 ldp w6,w7,[x4],#8
 ldp w8,w9,[x4],#8
 cmp w7,#1
 csel x10,x1,x2,eq
 cmp w7,#3
 csel x10,x3,x10,eq
 ldr w11,[x10,w8,uxtw]
 add w11,w11,w9
 str w11,[x0,w6,uxtw]
 subs w5,w5,#1
 b.ne .Lcopy_count
 mov w8,#1
 str w8,[x0,#0]
 str w8,[x0,#44]
 movz x12,#28280
 movk x12,#23,lsl#16
 ldr w8,[x2,x12]
 cbz w8,.Lno_stochastic_count
 movz x12,#10984
 movk x12,#65,lsl#16
 ldr w8,[x2,x12]
 b .Lstore_stochastic_count
.Lno_stochastic_count:
 mov w8,#0
.Lstore_stochastic_count:
 str w8,[x0,#124]
 mov w0,#0
 ret
.size md2asm_initialise_physics_dimensions,.-md2asm_initialise_physics_dimensions
.p2align 4
.global md2asm_update_physics_dimensions
.type md2asm_update_physics_dimensions,%function
md2asm_update_physics_dimensions:
 ldp x8,x9,[x4]
 ldp x10,x11,[x4,#16]
 ldp x12,x13,[x4,#32]
 ldp x14,x15,[x4,#48]
 str w1,[x0,#8]
 str w2,[x0,#4]
 str w3,[x0,#28]
 stp x8,x9,[x0,#128]
 stp x10,x11,[x0,#144]
 stp x12,x13,[x0,#160]
 stp x14,x15,[x0,#176]
 mov w0,#0
 ret
.size md2asm_update_physics_dimensions,.-md2asm_update_physics_dimensions
.p2align 4
.global __ecphys_dimension_type_mod_MOD_dimension_type_init
.type __ecphys_dimension_type_mod_MOD_dimension_type_init,%function
__ecphys_dimension_type_mod_MOD_dimension_type_init:
 adrp x8,.Lcalls
 ldr x9,[x8,:lo12:.Lcalls+0]
 add x9,x9,#1
 str x9,[x8,:lo12:.Lcalls+0]
 ldr x0,[x0]
 b md2asm_initialise_physics_dimensions
.size __ecphys_dimension_type_mod_MOD_dimension_type_init,.-__ecphys_dimension_type_mod_MOD_dimension_type_init
.p2align 4
.global __ecphys_dimension_type_mod_MOD_dimension_type_update
.type __ecphys_dimension_type_mod_MOD_dimension_type_update,%function
__ecphys_dimension_type_mod_MOD_dimension_type_update:
 adrp x8,.Lcalls
 ldr x9,[x8,:lo12:.Lcalls+8]
 add x9,x9,#1
 str x9,[x8,:lo12:.Lcalls+8]
 ldr x0,[x0]
 ldr w1,[x1]
 ldr w2,[x2]
 ldr w3,[x3]
 b md2asm_update_physics_dimensions
.size __ecphys_dimension_type_mod_MOD_dimension_type_update,.-__ecphys_dimension_type_mod_MOD_dimension_type_update
.global md2asm_physics_dimension_call_count_get
.type md2asm_physics_dimension_call_count_get,%function
md2asm_physics_dimension_call_count_get:
 cmp x0,#2
 b.hs .Lbad_counter
 adrp x8,.Lcalls
 add x8,x8,:lo12:.Lcalls
 ldr x0,[x8,x0,lsl#3]
 ret
.Lbad_counter:
 mov x0,#0
 ret
.size md2asm_physics_dimension_call_count_get,.-md2asm_physics_dimension_call_count_get
.section .rodata
.p2align 2
.Lsource_counts:
 // KLON from g%yrdim%nproma.
 .word 12,1,5144,0
 // KSMAX from g%yrdim%nsmax.
 .word 16,1,5172,0
 // KLEVS from s%ysp_sbd%nlevs.
 .word 20,3,5888,0
 // KTILES from m%yrml_phy_g%yrdphy%ntiles.
 .word 24,2,1577396,0
 // KLEVX from s%ysd_xad%nlevs.
 .word 32,3,16248,0
 // KFLDX from s%ysd_xad%numflds.
 .word 36,3,16240,0
 // KFLDX2 from s%ysd_x2d%numflds.
 .word 40,3,17016,0
 // KLEV from g%yrdimv%nflevg.
 .word 48,1,5224,0
 // KVCLIS from m%yrml_phy_g%yrdphy%nvclis.
 .word 52,2,1577428,0
 // KLEVI from m%yrml_phy_g%yrdphy%ncsi.
 .word 56,2,1577384,0
 // KLEVO from m%yrml_phy_g%yrdphy%ncom.
 .word 60,2,1577388,-1
 // KLEVSN from m%yrml_phy_g%yrdphy%ncsnec.
 .word 64,2,1577392,0
 // KDHVTLS from m%yrml_diag%yrmddh%ndhvtls.
 .word 68,2,4233140,0
 // KDHFTLS from m%yrml_diag%yrmddh%ndhftls.
 .word 72,2,4233144,0
 // KDHVTSS from m%yrml_diag%yrmddh%ndhvtss.
 .word 76,2,4233148,0
 // KDHFTSS from m%yrml_diag%yrmddh%ndhftss.
 .word 80,2,4233152,0
 // KDHVTTS from m%yrml_diag%yrmddh%ndhvtts.
 .word 84,2,4233156,0
 // KDHFTTS from m%yrml_diag%yrmddh%ndhftts.
 .word 88,2,4233160,0
 // KDHVTIS from m%yrml_diag%yrmddh%ndhvtis.
 .word 92,2,4233164,0
 // KDHFTIS from m%yrml_diag%yrmddh%ndhftis.
 .word 96,2,4233168,0
 // KDHVSSS from m%yrml_diag%yrmddh%ndhvsss.
 .word 100,2,4233172,0
 // KDHFSSS from m%yrml_diag%yrmddh%ndhfsss.
 .word 104,2,4233176,0
 // KDHVIIS from m%yrml_diag%yrmddh%ndhviis.
 .word 108,2,4233180,0
 // KDHFIIS from m%yrml_diag%yrmddh%ndhfiis.
 .word 112,2,4233184,0
 // KDHVWLS from m%yrml_diag%yrmddh%ndhvwls.
 .word 116,2,4233188,0
 // KDHFWLS from m%yrml_diag%yrmddh%ndhfwls.
 .word 120,2,4233192,0
.bss
.p2align 3
.Lcalls: .zero 16
.section .note.GNU-stack,"",%progbits

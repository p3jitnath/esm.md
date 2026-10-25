// MD2ASM_REGISTRY_LAYOUT_ONLY assembles only the unchanged read-only tables.
// MD2ASM_PUBLISH_REGISTRY_CLEANUP_LAYOUTS exposes those table addresses beside the normal entries.
// Source-ordered field-variable clone, block-view and reset services.
// Contract skills/md2asm/references/openifs/support/field_variable_arrays.md. No numerical value is changed.
.arch armv8.2-a
#ifndef MD2ASM_REGISTRY_LAYOUT_ONLY
.text
.macro count_call index
    adrp x9, .Lvariable_calls
    add x9, x9, :lo12:.Lvariable_calls
    ldr x10, [x9, #(8*\index)]
    add x10, x10, #1
    str x10, [x9, #(8*\index)]
.endm
.macro heap_enter
    stp x29, x30, [sp, #-160]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    str x18, [sp, #96]
    mrs x9, fpcr
    mrs x10, fpsr
    stp x9, x10, [sp, #104]
.endm
.macro heap_save_error
    bl __errno_location
    str x0, [sp, #120]
    ldr w9, [x0]
    str w9, [sp, #128]
.endm
.macro heap_return
    ldr x9, [sp, #120]
    ldr w10, [sp, #128]
    str w10, [x9]
    ldp x9, x10, [sp, #104]
    msr fpcr, x9
    msr fpsr, x10
    ldr x18, [sp, #96]
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp], #160
    ret
.endm

.global __field_variables_mod_MOD_field_variables_clone_arrays
.type __field_variables_mod_MOD_field_variables_clone_arrays,%function
__field_variables_mod_MOD_field_variables_clone_arrays:
    ldr x0, [x0]
    b md2asm_clone_field_variable_arrays
.size __field_variables_mod_MOD_field_variables_clone_arrays,.-__field_variables_mod_MOD_field_variables_clone_arrays
.global md2asm_clone_field_variable_arrays
.type md2asm_clone_field_variable_arrays,%function
md2asm_clone_field_variable_arrays:
    heap_enter
    mov x19, x0
    count_call 0
    heap_save_error
    adrp x20, .Larray_offsets
    add x20, x20, :lo12:.Larray_offsets
    mov w21, #18
.Lclone_family:
    ldp w9, w10, [x20], #8
    add x24, x19, w9, uxtw
    add x22, x19, w10, uxtw
    str xzr, [x22]
    ldp x9, x10, [x24, #48]
    sub x23, x10, x9
    add x23, x23, #1
    cmp x23, #0
    csel x23, x23, xzr, ge
    mov x9, #728
    mul x0, x23, x9
    bl malloc
    cbz x0, .Lallocation_failure
    mov x25, x0
    ldp x9, x10, [x24, #16]
    stp x9, x10, [x22, #16]
    mov x9, #728
    str x9, [x22, #32]
    mov x9, #-1
    stp x25, x9, [x22]
    mov x9, #1
    stp x9, x9, [x22, #40]
    str x23, [x22, #56]
    ldr x24, [x24]
    mov x26, #0
.Lclone_record:
    cmp x26, x23
    b.ge .Lclone_next_family
    mov x9, #728
    madd x27, x26, x9, x25
    madd x28, x26, x9, x24
    mov x0, x27
    adrp x1, .Ldefault_variable
    add x1, x1, :lo12:.Ldefault_variable
    mov x2, #728
    bl memcpy
    add x28, x28, #680
    add x27, x27, #680
    ldp x9, x10, [x28]
    stp x9, x10, [x27]
    ldp x9, x10, [x28, #16]
    stp x9, x10, [x27, #16]
    ldp x9, x10, [x28, #32]
    stp x9, x10, [x27, #32]
    add x26, x26, #1
    b .Lclone_record
.Lclone_next_family:
    subs w21, w21, #1
    b.ne .Lclone_family
    heap_return
.Lallocation_failure:
    mov w0, #116
    bl _exit
    brk #0
.size md2asm_clone_field_variable_arrays,.-md2asm_clone_field_variable_arrays

.global __field_variables_mod_MOD_field_variables_reset_arrays
.type __field_variables_mod_MOD_field_variables_reset_arrays,%function
__field_variables_mod_MOD_field_variables_reset_arrays:
    ldr x0, [x0]
    b md2asm_reset_field_variable_arrays
.size __field_variables_mod_MOD_field_variables_reset_arrays,.-__field_variables_mod_MOD_field_variables_reset_arrays
.global md2asm_reset_field_variable_arrays
.type md2asm_reset_field_variable_arrays,%function
md2asm_reset_field_variable_arrays:
    heap_enter
    mov x19, x0
    count_call 2
    heap_save_error
    adrp x20, .Larray_offsets
    add x20, x20, :lo12:.Larray_offsets
    mov w21, #18
.Lreset_family:
    ldp w9, w10, [x20], #8
    add x23, x19, w9, uxtw
    add x22, x19, w10, uxtw
    ldr x0, [x22]
    bl free
    ldp x9, x10, [x23]
    stp x9, x10, [x22]
    ldp x9, x10, [x23, #16]
    stp x9, x10, [x22, #16]
    ldp x9, x10, [x23, #32]
    stp x9, x10, [x22, #32]
    ldp x9, x10, [x23, #48]
    stp x9, x10, [x22, #48]
    subs w21, w21, #1
    b.ne .Lreset_family
    heap_return
.size md2asm_reset_field_variable_arrays,.-md2asm_reset_field_variable_arrays

.global __field_variables_mod_MOD_field_variables_update_view
.type __field_variables_mod_MOD_field_variables_update_view,%function
__field_variables_mod_MOD_field_variables_update_view:
    ldr w1, [x1]
    ldr x0, [x0]
    b md2asm_update_field_variable_views
.size __field_variables_mod_MOD_field_variables_update_view,.-__field_variables_mod_MOD_field_variables_update_view
.global md2asm_update_field_variable_views
.type md2asm_update_field_variable_views,%function
md2asm_update_field_variable_views:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    mov x19, x0
    mov w22, w1
    count_call 1
    adrp x20, .Lupdate_offsets
    add x20, x20, :lo12:.Lupdate_offsets
    mov w21, #79
.Lupdate_entry:
    ldp w9, w10, [x20]
    ldr w11, [x20, #8]
    add x20, x20, #12
    add x23, x19, w9, uxtw
    mov w27, w10
    cbnz w11, .Lupdate_array
    mov x0, x23
    mov w1, w27
    mov w2, w22
    bl md2asm_update_variable_view
    b .Lupdate_next_entry
.Lupdate_array:
    ldp x9, x10, [x23, #48]
    sub x24, x10, x9
    add x24, x24, #1
    cmp x24, #0
    b.le .Lupdate_next_entry
    ldr x25, [x23, #40]
    mov x9, #728
    mul x25, x25, x9
    ldr x23, [x23]
.Lupdate_array_record:
    mov x0, x23
    mov w1, w27
    mov w2, w22
    bl md2asm_update_variable_view
    add x23, x23, x25
    subs x24, x24, #1
    b.ne .Lupdate_array_record
.Lupdate_next_entry:
    subs w21, w21, #1
    b.ne .Lupdate_entry
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x27, x28, [sp, #80]
    ldp x29, x30, [sp], #112
    ret
.size md2asm_update_field_variable_views,.-md2asm_update_field_variable_views

.global __variable_module_MOD_variable_2d_update_view
.type __variable_module_MOD_variable_2d_update_view,%function
__variable_module_MOD_variable_2d_update_view:
    ldr w2, [x1]
    ldr x0, [x0]
    mov w1, #2
    b md2asm_update_variable_view
.size __variable_module_MOD_variable_2d_update_view,.-__variable_module_MOD_variable_2d_update_view
.global __variable_module_MOD_variable_3d_update_view
.type __variable_module_MOD_variable_3d_update_view,%function
__variable_module_MOD_variable_3d_update_view:
    ldr w2, [x1]
    ldr x0, [x0]
    mov w1, #3
    b md2asm_update_variable_view
.size __variable_module_MOD_variable_3d_update_view,.-__variable_module_MOD_variable_3d_update_view
.global md2asm_update_variable_view
.type md2asm_update_variable_view,%function
md2asm_update_variable_view:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    mov x19, x0
    mov w22, w1
    mov w23, w2
    cmp w22, #2
    b.eq .Lvariable_rank_two
    cmp w22, #3
    b.ne .Linvalid_rank
    count_call 4
    b .Lvariable_rank_ready
.Lvariable_rank_two:
    count_call 3
.Lvariable_rank_ready:
    mov x9, #24
    umaddl x25, w22, w9, xzr
    add x25, x25, #16
    mov x9, #7
    madd x20, x25, x9, x19
    add x20, x20, #64
    add x21, x19, #64
    add x21, x21, x25
    mov w24, #6
.Lvariable_field:
    ldr x1, [x20], #8
    cbz x1, .Lvariable_next_field
    mov x0, x21
    mov w2, w23
    cmp w22, #2
    b.eq .Lvariable_two_child
    bl md2asm_physics_field_view_3d
    b .Lvariable_next_field
.Lvariable_two_child:
    bl md2asm_physics_field_view_2d
.Lvariable_next_field:
    add x21, x21, x25
    subs w24, w24, #1
    b.ne .Lvariable_field
    add x0, x19, #64
    add x1, x0, x25
    mov x2, x25
.Lalias_time_zero:
    ldr x9, [x1], #8
    str x9, [x0], #8
    subs x2, x2, #8
    b.ne .Lalias_time_zero
    ldp x19, x20, [sp, #16]
    ldp x21, x22, [sp, #32]
    ldp x23, x24, [sp, #48]
    ldp x25, x26, [sp, #64]
    ldp x29, x30, [sp], #80
    ret
.Linvalid_rank:
    mov w0, #116
    bl _exit
    brk #0
.size md2asm_update_variable_view,.-md2asm_update_variable_view

.global md2asm_field_variable_call_count_get
.type md2asm_field_variable_call_count_get,%function
md2asm_field_variable_call_count_get:
    cmp x0, #5
    b.hs .Lcounter_zero
    adrp x9, .Lvariable_calls
    add x9, x9, :lo12:.Lvariable_calls
    ldr x0, [x9, x0, lsl #3]
    ret
.Lcounter_zero:
    mov x0, #0
    ret
.size md2asm_field_variable_call_count_get,.-md2asm_field_variable_call_count_get
#endif
.section .rodata
.p2align 3
#ifndef MD2ASM_REGISTRY_LAYOUT_ONLY
.Ldefault_variable:
    .zero 16
    .ascii "                "
    .word -999
    .zero 692
#endif
.Larray_offsets:
    .word 29680, 29744 // GHG
    .word 29808, 29872 // CHEM
    .word 29936, 30000 // AERO
    .word 30792, 30856 // FORC
    .word 30920, 30984 // EZDIAG
    .word 31048, 31112 // ERA40
    .word 31176, 31240 // NOGW
    .word 31304, 31368 // EMIS3D
    .word 31432, 31496 // EDRP
    .word 31560, 31624 // SLDIA
    .word 31688, 31752 // AERAOT
    .word 31816, 31880 // AERLISI
    .word 31944, 32008 // AEROUT
    .word 32072, 32136 // AEROCLIM
    .word 32200, 32264 // UVP
    .word 32328, 32392 // PHYS
    .word 41920, 41984 // LIMA
    .word 42776, 42840 // EXT
.Lupdate_offsets:
    .word 0, 3, 0 // U
    .word 728, 3, 0 // V
    .word 1456, 3, 0 // T
    .word 2184, 3, 0 // DIV
    .word 2912, 3, 0 // VOR
    .word 3640, 3, 0 // SPD
    .word 4368, 3, 0 // SVD
    .word 5096, 3, 0 // NHX
    .word 5824, 3, 0 // EDOT
    .word 6552, 3, 0 // SGRTL
    .word 7280, 3, 0 // SGRTM
    .word 8008, 2, 0 // SP
    .word 8568, 3, 0 // Q
    .word 9296, 3, 0 // I
    .word 10024, 3, 0 // L
    .word 10752, 3, 0 // LCONV
    .word 11480, 3, 0 // ICONV
    .word 12208, 3, 0 // RCONV
    .word 12936, 3, 0 // SCONV
    .word 13664, 3, 0 // IRAD
    .word 14392, 3, 0 // LRAD
    .word 15120, 3, 0 // S
    .word 15848, 3, 0 // R
    .word 16576, 3, 0 // G
    .word 17304, 3, 0 // H
    .word 18032, 3, 0 // TKE
    .word 18760, 3, 0 // TTE
    .word 19488, 3, 0 // EFB1
    .word 20216, 3, 0 // EFB2
    .word 20944, 3, 0 // EFB3
    .word 21672, 3, 0 // A
    .word 22400, 3, 0 // O3
    .word 23128, 3, 0 // SRC
    .word 23856, 3, 0 // MXL
    .word 24584, 3, 0 // SHTUR
    .word 25312, 3, 0 // FQTUR
    .word 26040, 3, 0 // FSTUR
    .word 26768, 3, 0 // CPF
    .word 27496, 3, 0 // SPF
    .word 28224, 3, 0 // CVGQ
    .word 28952, 3, 0 // QVA
    .word 29744, 3, 1 // GHG
    .word 29872, 3, 1 // CHEM
    .word 30000, 3, 1 // AERO
    .word 30064, 3, 0 // LRCH4
    .word 30856, 3, 1 // FORC
    .word 30984, 3, 1 // EZDIAG
    .word 31112, 3, 1 // ERA40
    .word 31240, 3, 1 // NOGW
    .word 31368, 3, 1 // EMIS3D
    .word 31496, 3, 1 // EDRP
    .word 31624, 3, 1 // SLDIA
    .word 31752, 3, 1 // AERAOT
    .word 31880, 3, 1 // AERLISI
    .word 32008, 3, 1 // AEROUT
    .word 32136, 3, 1 // AEROCLIM
    .word 32264, 3, 1 // UVP
    .word 32392, 3, 1 // PHYS
    .word 32456, 3, 0 // PHYCTY
    .word 33184, 3, 0 // RSPEC
    .word 33912, 3, 0 // SDSAT
    .word 34640, 3, 0 // CVV
    .word 35368, 3, 0 // RKTH
    .word 36096, 3, 0 // RKTQV
    .word 36824, 3, 0 // RKTQC
    .word 37552, 3, 0 // UOM
    .word 38280, 3, 0 // UAL
    .word 39008, 3, 0 // DOM
    .word 39736, 3, 0 // DAL
    .word 40464, 3, 0 // UEN
    .word 41192, 3, 0 // UNEBH
    .word 41984, 3, 1 // LIMA
    .word 42048, 3, 0 // FSD
    .word 42840, 3, 1 // EXT
    .word 54664, 3, 0 // ECPHYS%USTRTI
    .word 55392, 3, 0 // ECPHYS%VSTRTI
    .word 56120, 3, 0 // ECPHYS%AHFSTI
    .word 56848, 3, 0 // ECPHYS%EVAPTI
    .word 57576, 3, 0 // ECPHYS%TSKTI
#ifndef MD2ASM_REGISTRY_LAYOUT_ONLY
.bss
.p2align 3
.Lvariable_calls:
    .zero 40
#endif
#if defined(MD2ASM_REGISTRY_LAYOUT_ONLY) || defined(MD2ASM_PUBLISH_REGISTRY_CLEANUP_LAYOUTS)
.section .rodata
.global md2asm_registry_variable_view_layout
.type md2asm_registry_variable_view_layout,%object
.set md2asm_registry_variable_view_layout,.Lupdate_offsets
.size md2asm_registry_variable_view_layout,948
.global md2asm_registry_variable_array_layout
.type md2asm_registry_variable_array_layout,%object
.set md2asm_registry_variable_array_layout,.Larray_offsets
.size md2asm_registry_variable_array_layout,144
#endif
.section .note.GNU-stack,"",%progbits

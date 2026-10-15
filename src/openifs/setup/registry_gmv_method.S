// Contract: skills/md2asm/references/openifs/setup/field_registry.md.
// Register original GMV time-level and derivative metadata.
// x0 registry; x1 FIELD_VARIABLES pointer slot; x2 TGMV source record.
.text
.p2align 4
.global md2asm_registry_register_gmv
.type md2asm_registry_register_gmv,%function
md2asm_registry_register_gmv:
    stp x29, x30, [sp, #-112]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    str x18, [sp, #64]
    mov x23, x1
    mov x20, x2
    ldr x19, [x1]
    cbnz x19, .Lgmv_method_ready
    bl md2asm_registry_allocate_variables
    cbz x0, .Lgmv_method_failed
    str x0, [x23]
    mov x19, x0
.Lgmv_method_ready:
    adrp x21, .Lgmv_fields
    add x21, x21, :lo12:.Lgmv_fields
    mov w22, #12
.Lgmv_method_field:
    mov x24, #0
.Lgmv_method_indices:
    add x4, x21, x24, lsl #2
    ldr w4, [x4, #16]
    tbnz w4, #31, .Lgmv_method_index_ready
    ldr w4, [x20, w4, uxtw]
.Lgmv_method_index_ready:
    add x5, sp, #80
    str w4, [x5, x24, lsl #2]
    add x24, x24, #1
    cmp x24, #6
    b.lo .Lgmv_method_indices
    ldp w4, w5, [x21]
    add x0, x19, w4, uxtw
    mov w5, w5
    add x1, x21, #40
    ldp w6, w7, [x21, #8]
    add x2, x20, w6, uxtw
    add x3, x20, w7, uxtw
    add x4, sp, #80
    bl md2asm_registry_create_gmv_variable
    cbnz w0, .Lgmv_method_failed
    add x21, x21, #56
    subs w22, w22, #1
    b.ne .Lgmv_method_field
    mov w0, #0
    b .Lgmv_method_return
.Lgmv_method_failed:
    mov w0, #1
.Lgmv_method_return:
    ldr x18, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #112
    ret
.size md2asm_registry_register_gmv,.-md2asm_registry_register_gmv
.section .rodata
.p2align 3
.Lgmv_fields:
    .word 0,3,0,248,1012,1368,1116,1404,1040,-1
    .ascii "U               "
    .word 728,3,0,248,1016,1372,1120,1408,1044,-1
    .ascii "V               "
    .word 1456,3,0,248,1020,1376,1124,1412,1024,1028
    .ascii "T               "
    .word 2184,3,0,248,1032,1392,1188,-1,-1,-1
    .ascii "DIV             "
    .word 2912,3,0,248,1036,1388,1192,-1,-1,-1
    .ascii "VOR             "
    .word 8008,2,136,384,1096,1400,1324,1416,1100,1104
    .ascii "SP              "
    .word 3640,3,0,248,1048,1380,1204,-1,1048,1048
    .ascii "SPD             "
    .word 4368,3,0,248,1060,1384,1216,-1,1060,1060
    .ascii "SVD             "
    .word 5096,3,0,248,1072,1396,1228,-1,1072,1072
    .ascii "NHX             "
    .word 5824,3,0,248,1084,-1,1136,-1,-1,-1
    .ascii "EDOT            "
    .word 6552,3,0,248,1088,-1,1316,-1,-1,-1
    .ascii "SGRTL           "
    .word 7280,3,0,248,1092,-1,1320,-1,-1,-1
    .ascii "SGRTM           "
.section .note.GNU-stack,"",%progbits

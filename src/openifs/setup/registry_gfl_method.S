// Contract: skills/md2asm/references/openifs/setup/field_registry.md.
// x0 registry; x1 FIELD_VARIABLES pointer slot; x2 TGFL; x3 TYPE_GFLD.
.text
.p2align 4
.global md2asm_registry_register_gfl
.type md2asm_registry_register_gfl,%function
md2asm_registry_register_gfl:
    stp x29, x30, [sp, #-96]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x18, [sp, #64]
    mov x24, x1
    mov x20, x2
    mov x21, x3
    ldr x19, [x1]
    cbnz x19, .Lgfl_method_ready
    bl md2asm_registry_allocate_variables
    cbz x0, .Lgfl_method_failed
    str x0, [x24]
    mov x19, x0
.Lgfl_method_ready:
    adrp x22, .Lgfl_registration_fields
    add x22, x22, :lo12:.Lgfl_registration_fields
    mov w23, #62
.Lgfl_method_record:
    ldp w4, w5, [x22]
    ldp w25, w6, [x22, #8]
    add x0, x19, w4, uxtw
    add x1, x22, #16
    add x2, x21, w5, uxtw
    mov x3, x20
    cbnz w25, .Lgfl_method_group
    ldr x2, [x2]
    bl md2asm_registry_create_gfl_variable
    b .Lgfl_method_stored
.Lgfl_method_group:
    mov w4, w6
    bl md2asm_registry_create_gfl_array
    cbnz w0, .Lgfl_method_return
    ldr w4, [x22]
    add x4, x19, w4, uxtw
    ldp x5, x6, [x4]
    stp x5, x6, [x4, #64]
    ldp x5, x6, [x4, #16]
    stp x5, x6, [x4, #80]
    ldp x5, x6, [x4, #32]
    stp x5, x6, [x4, #96]
    ldp x5, x6, [x4, #48]
    stp x5, x6, [x4, #112]
.Lgfl_method_stored:
    cbnz w0, .Lgfl_method_return
    add x22, x22, #32
    subs w23, w23, #1
    b.ne .Lgfl_method_record
    mov w0, #0
    b .Lgfl_method_return
.Lgfl_method_failed:
    mov w0, #1
.Lgfl_method_return:
    ldp x25, x18, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #96
    ret
.size md2asm_registry_register_gfl,.-md2asm_registry_register_gfl
.section .rodata
.p2align 3
.Lgfl_registration_fields:
    .word 8568,799840,0,1
    .ascii "Q               "
    .word 9296,799848,0,1
    .ascii "I               "
    .word 10024,799856,0,1
    .ascii "L               "
    .word 10752,799864,0,5
    .ascii "LCONV           "
    .word 11480,799872,0,5
    .ascii "ICONV           "
    .word 12208,799880,0,5
    .ascii "RCONV           "
    .word 12936,799888,0,5
    .ascii "SCONV           "
    .word 13664,799896,0,4
    .ascii "IRAD            "
    .word 14392,799904,0,4
    .ascii "LRAD            "
    .word 15120,799912,0,1
    .ascii "S               "
    .word 15848,799920,0,1
    .ascii "R               "
    .word 16576,799928,0,1
    .ascii "G               "
    .word 17304,799936,0,1
    .ascii "H               "
    .word 18032,799944,0,3
    .ascii "TKE             "
    .word 18760,799952,0,3
    .ascii "TTE             "
    .word 19488,799960,0,4
    .ascii "EFB1            "
    .word 20216,799968,0,4
    .ascii "EFB2            "
    .word 20944,799976,0,4
    .ascii "EFB3            "
    .word 21672,799984,0,1
    .ascii "A               "
    .word 22400,799992,0,2
    .ascii "O3              "
    .word 23128,800000,0,3
    .ascii "SRC             "
    .word 23856,800008,0,3
    .ascii "MXL             "
    .word 24584,800016,0,5
    .ascii "SHTUR           "
    .word 25312,800024,0,5
    .ascii "FQTUR           "
    .word 26040,800032,0,5
    .ascii "FSTUR           "
    .word 26768,800040,0,3
    .ascii "CPF             "
    .word 27496,800048,0,3
    .ascii "SPF             "
    .word 28224,800056,0,4
    .ascii "CVGQ            "
    .word 28952,800064,0,3
    .ascii "QVA             "
    .word 29680,800072,1,3
    .ascii "GHG             "
    .word 29808,800136,1,4
    .ascii "CHEM            "
    .word 29936,800200,1,4
    .ascii "AERO            "
    .word 30064,800264,0,5
    .ascii "LRCH4           "
    .word 30792,800336,1,4
    .ascii "FORC            "
    .word 30920,800400,1,6
    .ascii "EZDIAG          "
    .word 31048,800464,1,5
    .ascii "ERA40           "
    .word 31176,800528,1,4
    .ascii "NOGW            "
    .word 31304,800272,1,6
    .ascii "EMIS3D          "
    .word 31432,800592,1,4
    .ascii "EDRP            "
    .word 31560,800656,1,5
    .ascii "SLDIA           "
    .word 31688,800720,1,6
    .ascii "AERAOT          "
    .word 31816,800784,1,7
    .ascii "AERLISI         "
    .word 31944,800848,1,6
    .ascii "AEROUT          "
    .word 32072,800912,1,8
    .ascii "AEROCLIM        "
    .word 32200,800976,1,3
    .ascii "UVP             "
    .word 32328,801040,1,4
    .ascii "PHYS            "
    .word 32456,801104,0,6
    .ascii "PHYCTY          "
    .word 33184,801112,0,5
    .ascii "RSPEC           "
    .word 33912,801120,0,5
    .ascii "SDSAT           "
    .word 34640,801128,0,3
    .ascii "CVV             "
    .word 35368,801136,0,4
    .ascii "RKTH            "
    .word 36096,801144,0,5
    .ascii "RKTQV           "
    .word 36824,801152,0,5
    .ascii "RKTQC           "
    .word 37552,801160,0,3
    .ascii "UOM             "
    .word 38280,801168,0,3
    .ascii "UAL             "
    .word 39008,801176,0,3
    .ascii "DOM             "
    .word 39736,801184,0,3
    .ascii "DAL             "
    .word 40464,801192,0,3
    .ascii "UEN             "
    .word 41192,801200,0,5
    .ascii "UNEBH           "
    .word 41920,801208,1,4
    .ascii "LIMA            "
    .word 42048,801272,0,3
    .ascii "FSD             "
    .word 42776,801280,1,3
    .ascii "EXT             "
.section .note.GNU-stack,"",%progbits

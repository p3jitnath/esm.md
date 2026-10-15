// Contract: skills/md2asm/references/openifs/setup/field_registry.md.
// Register named views of existing numerical owners. Metadata only.
.text
.p2align 4
.global md2asm_registry_register_geometry
.type md2asm_registry_register_geometry,%function
md2asm_registry_register_geometry:
    mov x0, x1
    mov x1, x2
    adrp x2, .Lgeometry_fields
    add x2, x2, :lo12:.Lgeometry_fields
    mov w3, #21
    mov w4, #1
    b .Lregister_fields
.size md2asm_registry_register_geometry,.-md2asm_registry_register_geometry
.global md2asm_registry_register_ec_physics
.type md2asm_registry_register_ec_physics,%function
md2asm_registry_register_ec_physics:
    mov x0, x1
    mov x1, x2
    adrp x2, .Lec_fields
    add x2, x2, :lo12:.Lec_fields
    mov w3, #5
    mov w4, #0
    b .Lregister_fields
.size md2asm_registry_register_ec_physics,.-md2asm_registry_register_ec_physics
.global md2asm_registry_register_radiation
.type md2asm_registry_register_radiation,%function
md2asm_registry_register_radiation:
    mov x0, x1
    mov x1, x2
    adrp x2, .Lradiation_fields
    add x2, x2, :lo12:.Lradiation_fields
    mov w3, #23
    mov w4, #0
.Lregister_fields:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x18, [sp, #48]
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    cbz w4, .Lregistration_ready
    mov x23, x0
    ldr x19, [x0]
    cbnz x19, .Lregistration_ready
    bl .Lallocate_variables
    cbz x0, .Lregistration_failed
    str x0, [x23]
    mov x19, x0
.Lregistration_ready:
    ldp w4, w5, [x21]
    ldr w6, [x21, #8]
    add x0, x19, w4, uxtw
    add x2, x20, w5, uxtw
    add x1, x21, #16
    cmp w6, #2
    b.eq .Lregister_2d
    cmp w6, #3
    b.eq .Lregister_3d
    bl md2asm_registry_wrap_variable_4d
    b .Lregistered_field
.Lregister_2d:
    bl md2asm_registry_wrap_variable_2d
    b .Lregistered_field
.Lregister_3d:
    bl md2asm_registry_wrap_variable_3d
.Lregistered_field:
    cbnz w0, .Lregistration_failed
    add x21, x21, #32
    subs x22, x22, #1
    b.ne .Lregistration_ready
    mov w0, #0
    b .Lregistration_return
.Lregistration_failed:
    mov w0, #1
.Lregistration_return:
    ldp x23, x18, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #80
    ret
.size md2asm_registry_register_radiation,.-md2asm_registry_register_radiation

// Return one default FIELD_VARIABLES metadata owner, or a null address.
.global md2asm_registry_allocate_variables
.type md2asm_registry_allocate_variables,%function
md2asm_registry_allocate_variables:
.Lallocate_variables:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x18, [sp, #16]
    movz w0, #7160
    movk w0, #1, lsl #16
    bl malloc
    cbz x0, .Lvariables_return
    mov x1, x0
    movz w2, #7160
    movk w2, #1, lsl #16
    add x2, x0, x2
.Lvariables_zero:
    str xzr, [x1], #8
    cmp x1, x2
    b.lo .Lvariables_zero
    adrp x1, .Ldefault_scalar_offsets
    add x1, x1, :lo12:.Ldefault_scalar_offsets
    mov w2, #105
    mov x4, #0x2020202020202020
    mov w5, #-999
.Lvariable_defaults:
    ldr w3, [x1], #4
    add x3, x0, w3, uxtw
    stp x4, x4, [x3]
    stp x4, x4, [x3, #16]
    str w5, [x3, #32]
    subs w2, w2, #1
    b.ne .Lvariable_defaults
.Lvariables_return:
    ldr x18, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

.size md2asm_registry_allocate_variables,.-md2asm_registry_allocate_variables

.section .rodata
.p2align 3
.Lgeometry_fields:
    .word 42904,10008,2,0
    .ascii "RCORI           "
    .word 43464,10096,2,0
    .ascii "RCORIC          "
    .word 44024,10184,2,0
    .ascii "GEMU            "
    .word 44584,10272,2,0
    .ascii "GSQM2           "
    .word 45144,10360,2,0
    .ascii "GELAM           "
    .word 45704,10448,2,0
    .ascii "GELAT           "
    .word 46264,10536,2,0
    .ascii "GECLO           "
    .word 46824,10624,2,0
    .ascii "GESLO           "
    .word 47384,10976,2,0
    .ascii "GM              "
    .word 47944,11064,2,0
    .ascii "GMAPPA          "
    .word 48504,11152,2,0
    .ascii "GOMVRL          "
    .word 49064,11240,2,0
    .ascii "GOMVRM          "
    .word 49624,11328,2,0
    .ascii "GNORDL          "
    .word 50184,11416,2,0
    .ascii "GNORDM          "
    .word 50744,11504,2,0
    .ascii "GNORDLCL        "
    .word 51304,11592,2,0
    .ascii "GNORDMCL        "
    .word 51864,11680,2,0
    .ascii "GNORDMCM        "
    .word 52424,11768,2,0
    .ascii "GAW             "
    .word 52984,14088,2,0
    .ascii "OROG            "
    .word 53544,14176,2,0
    .ascii "OROGL           "
    .word 54104,14264,2,0
    .ascii "OROGM           "
.Lec_fields:
    .word 54664,0,3,0
    .ascii "USTRTI          "
    .word 55392,112,3,0
    .ascii "VSTRTI          "
    .word 56120,224,3,0
    .ascii "AHFSTI          "
    .word 56848,336,3,0
    .ascii "EVAPTI          "
    .word 57576,448,3,0
    .ascii "TSKTI           "
.Lradiation_fields:
    .word 58304,0,3,0
    .ascii "EMTD            "
    .word 59032,112,3,0
    .ascii "TRSW            "
    .word 59760,224,3,0
    .ascii "EMTC            "
    .word 60488,336,3,0
    .ascii "TRSC            "
    .word 61216,448,3,0
    .ascii "EMTU            "
    .word 61944,560,4,0
    .ascii "TAUAER          "
    .word 62840,696,2,0
    .ascii "SRSWD           "
    .word 64128,784,2,0
    .ascii "SRLWDC          "
    .word 63400,872,3,0
    .ascii "SRLWD           "
    .word 64688,984,2,0
    .ascii "SRSWDC          "
    .word 65248,1072,2,0
    .ascii "SRSWDCS         "
    .word 65808,1160,2,0
    .ascii "SRLWDCS         "
    .word 66368,1248,2,0
    .ascii "SRSWDV          "
    .word 66928,1336,2,0
    .ascii "SRSWDUV         "
    .word 67488,1424,2,0
    .ascii "EDRO            "
    .word 68048,1512,2,0
    .ascii "SRSWPAR         "
    .word 68608,1600,2,0
    .ascii "SRSWUVB         "
    .word 69168,1688,2,0
    .ascii "SRSWPARC        "
    .word 69728,1776,2,0
    .ascii "SRSWTINC        "
    .word 70848,1864,2,0
    .ascii "SRFDIR          "
    .word 71408,1952,2,0
    .ascii "SRCDIR          "
    .word 70288,2040,2,0
    .ascii "RMOON           "
    .word 71968,2128,3,0
    .ascii "DERIVATIVELW    "
.p2align 2
.Ldefault_scalar_offsets:
    .word 0 // U
    .word 728 // V
    .word 1456 // T
    .word 2184 // DIV
    .word 2912 // VOR
    .word 3640 // SPD
    .word 4368 // SVD
    .word 5096 // NHX
    .word 5824 // EDOT
    .word 6552 // SGRTL
    .word 7280 // SGRTM
    .word 8008 // SP
    .word 8568 // Q
    .word 9296 // I
    .word 10024 // L
    .word 10752 // LCONV
    .word 11480 // ICONV
    .word 12208 // RCONV
    .word 12936 // SCONV
    .word 13664 // IRAD
    .word 14392 // LRAD
    .word 15120 // S
    .word 15848 // R
    .word 16576 // G
    .word 17304 // H
    .word 18032 // TKE
    .word 18760 // TTE
    .word 19488 // EFB1
    .word 20216 // EFB2
    .word 20944 // EFB3
    .word 21672 // A
    .word 22400 // O3
    .word 23128 // SRC
    .word 23856 // MXL
    .word 24584 // SHTUR
    .word 25312 // FQTUR
    .word 26040 // FSTUR
    .word 26768 // CPF
    .word 27496 // SPF
    .word 28224 // CVGQ
    .word 28952 // QVA
    .word 30064 // LRCH4
    .word 32456 // PHYCTY
    .word 33184 // RSPEC
    .word 33912 // SDSAT
    .word 34640 // CVV
    .word 35368 // RKTH
    .word 36096 // RKTQV
    .word 36824 // RKTQC
    .word 37552 // UOM
    .word 38280 // UAL
    .word 39008 // DOM
    .word 39736 // DAL
    .word 40464 // UEN
    .word 41192 // UNEBH
    .word 42048 // FSD
    .word 42904 // GEOMETRY%RCORI
    .word 43464 // GEOMETRY%RCORIC
    .word 44024 // GEOMETRY%GEMU
    .word 44584 // GEOMETRY%GSQM2
    .word 45144 // GEOMETRY%GELAM
    .word 45704 // GEOMETRY%GELAT
    .word 46264 // GEOMETRY%GECLO
    .word 46824 // GEOMETRY%GESLO
    .word 47384 // GEOMETRY%GM
    .word 47944 // GEOMETRY%GMAPPA
    .word 48504 // GEOMETRY%GOMVRL
    .word 49064 // GEOMETRY%GOMVRM
    .word 49624 // GEOMETRY%GNORDL
    .word 50184 // GEOMETRY%GNORDM
    .word 50744 // GEOMETRY%GNORDLCL
    .word 51304 // GEOMETRY%GNORDMCL
    .word 51864 // GEOMETRY%GNORDMCM
    .word 52424 // GEOMETRY%GAW
    .word 52984 // GEOMETRY%OROG
    .word 53544 // GEOMETRY%OROGL
    .word 54104 // GEOMETRY%OROGM
    .word 54664 // ECPHYS%USTRTI
    .word 55392 // ECPHYS%VSTRTI
    .word 56120 // ECPHYS%AHFSTI
    .word 56848 // ECPHYS%EVAPTI
    .word 57576 // ECPHYS%TSKTI
    .word 58304 // RADIATION%EMTD
    .word 59032 // RADIATION%TRSW
    .word 59760 // RADIATION%EMTC
    .word 60488 // RADIATION%TRSC
    .word 61216 // RADIATION%EMTU
    .word 61944 // RADIATION%TAUAER
    .word 62840 // RADIATION%SRSWD
    .word 63400 // RADIATION%SRLWD
    .word 64128 // RADIATION%SRLWDC
    .word 64688 // RADIATION%SRSWDC
    .word 65248 // RADIATION%SRSWDCS
    .word 65808 // RADIATION%SRLWDCS
    .word 66368 // RADIATION%SRSWDV
    .word 66928 // RADIATION%SRSWDUV
    .word 67488 // RADIATION%EDRO
    .word 68048 // RADIATION%SRSWPAR
    .word 68608 // RADIATION%SRSWUVB
    .word 69168 // RADIATION%SRSWPARC
    .word 69728 // RADIATION%SRSWTINC
    .word 70288 // RADIATION%RMOON
    .word 70848 // RADIATION%SRFDIR
    .word 71408 // RADIATION%SRCDIR
    .word 71968 // RADIATION%DERIVATIVELW
.section .note.GNU-stack,"",%progbits

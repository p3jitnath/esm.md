// MD2ASM_REGISTRY_LAYOUT_ONLY assembles only the unchanged read-only tables.
// MD2ASM_PUBLISH_REGISTRY_CLEANUP_LAYOUTS exposes those table addresses beside the normal entries.
// Contract: skills/md2asm/references/openifs/setup/field_registry.md.
// x0 registry; x1 SURFVARS pointer slot; x2 TSURF source metadata and owners.
#ifndef MD2ASM_REGISTRY_LAYOUT_ONLY
.text
.p2align 4
.global md2asm_registry_register_surface
.type md2asm_registry_register_surface,%function
md2asm_registry_register_surface:
    stp x29, x30, [sp, #-160]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    stp x23, x24, [sp, #48]
    stp x25, x26, [sp, #64]
    stp x27, x28, [sp, #80]
    str x18, [sp, #96]
    mov x19, x0
    mov x20, x2
    mov x26, x1
    ldr x21, [x1]
    cbnz x21, .Lsurface_method_ready
    movz w0, #0x7420
    movk w0, #2, lsl #16
    bl malloc
    cbz x0, .Lsurface_method_failed
    mov x21, x0
    str x0, [x26]
    mov x4, x0
    movz w5, #0x7420
    movk w5, #2, lsl #16
    add x5, x0, x5
.Lsurface_owner_clear:
    str xzr, [x4], #8
    cmp x4, x5
    b.lo .Lsurface_owner_clear
.Lsurface_method_ready:
    adrp x22, .Lsurface_groups
    add x22, x22, :lo12:.Lsurface_groups
    adrp x27, .Lsurface_rows
    add x27, x27, :lo12:.Lsurface_rows
    mov w23, #19
.Lsurface_method_group:
    ldp w4, w25, [x22, #16]
    mov x5, #48
    madd x24, x4, x5, x27
    cbz w25, .Lsurface_method_group_field
.Lsurface_method_variable:
    ldp w4, w5, [x24]
    add x0, x21, w4, uxtw
    add x1, x24, #24
    add x3, x20, w5, uxtw
    ldp w6, w7, [x24, #8]
    ldp w4, w5, [x22]
    add x2, x20, w4, uxtw
    add x4, x20, w5, uxtw
    mov x5, x19
    cbnz w7, .Lsurface_method_array
    ldr x3, [x3]
    bl md2asm_registry_create_surface_variable
    b .Lsurface_method_variable_done
.Lsurface_method_array:
    ldr x8, [x3]
    cbz x8, .Lsurface_method_variable_next
    mov x8, x2
    mov x2, x3
    mov x3, x8
    add x7, x24, #12
    bl md2asm_registry_create_surface_array
.Lsurface_method_variable_done:
    cbnz w0, .Lsurface_method_return
.Lsurface_method_variable_next:
    add x24, x24, #48
    subs w25, w25, #1
    b.ne .Lsurface_method_variable
.Lsurface_method_group_field:
    ldp w4, w5, [x22]
    ldp w6, w28, [x22, #8]
    add x0, x21, w6, uxtw
    add x1, x20, w4, uxtw
    add x5, x20, w5, uxtw
    ldr w6, [x5, #4]
    cbz w6, .Lsurface_method_empty_group
    cmp w28, #3
    b.eq .Lsurface_group_wrap3
    bl md2asm_field_wrap_4d_
    b .Lsurface_method_group_done
.Lsurface_group_wrap3:
    bl md2asm_field_wrap_3d_
    b .Lsurface_method_group_done
.Lsurface_method_empty_group:
    ldr w4, [x19, #8]
    mov w6, #1
    stp w4, w6, [sp, #112]
    stp w6, w6, [sp, #120]
    cmp w28, #4
    b.ne .Lsurface_method_empty_shape_ready
    ldr w4, [x5, #8]
    cmp w4, #1
    csel w4, w4, w6, ge
    str w4, [sp, #116]
.Lsurface_method_empty_shape_ready:
    add x1, sp, #112
    mov x2, x28
    mov w3, #1
    bl md2asm_registry_allocate_field
    cbnz w0, .Lsurface_method_return
.Lsurface_method_group_done:
    add x22, x22, #32
    subs w23, w23, #1
    b.ne .Lsurface_method_group
    mov w0, #0
    b .Lsurface_method_return
.Lsurface_method_failed:
    mov w0, #1
.Lsurface_method_return:
    ldr x18, [sp, #96]
    ldp x27, x28, [sp, #80]
    ldp x25, x26, [sp, #64]
    ldp x23, x24, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #160
    ret
.size md2asm_registry_register_surface,.-md2asm_registry_register_surface
#endif
.section .rodata
.p2align 3
.Lsurface_groups:
    .word 5744,5880,2184,4,0,3,0,0
    .word 6032,6168,6224,4,3,5,0,0
    .word 6336,6448,10544,3,8,7,0,0
    .word 6632,6744,13672,3,15,5,0,0
    .word 6912,7024,17360,3,20,6,0,0
    .word 7200,7336,20600,4,26,4,0,0
    .word 7496,7632,21000,4,0,0,0,0
    .word 7760,7872,21400,3,0,0,0,0
    .word 8000,8112,21728,3,0,0,0,0
    .word 8784,8896,49320,3,30,54,0,0
    .word 10432,10544,52448,3,84,5,0,0
    .word 11840,11952,54456,3,89,3,0,0
    .word 12104,12240,65704,4,92,15,0,0
    .word 12488,12600,147712,3,107,158,0,0
    .word 14856,14992,149496,4,265,2,0,0
    .word 15136,15248,154936,3,267,9,0,0
    .word 15448,15560,159744,3,276,8,0,0
    .word 16104,16240,160072,4,0,0,0,0
    .word 16904,17016,160472,3,0,0,0,0
.Lsurface_rows:
    .word 0,5944,3,0,7,0
    .ascii "SP_SB_T         "
    .zero 8
    .word 728,5952,3,0,7,0
    .ascii "SP_SB_Q         "
    .zero 8
    .word 1456,5960,3,0,8,0
    .ascii "SP_SB_TL        "
    .zero 8
    .word 2584,6232,3,0,7,0
    .ascii "SP_SG_F         "
    .zero 8
    .word 3312,6240,3,0,7,0
    .ascii "SP_SG_A         "
    .zero 8
    .word 4040,6248,3,0,7,0
    .ascii "SP_SG_R         "
    .zero 8
    .word 4768,6256,3,0,7,0
    .ascii "SP_SG_T         "
    .zero 8
    .word 5496,6264,3,0,7,0
    .ascii "SP_SG_W         "
    .zero 8
    .word 6624,6512,2,0,10,0
    .ascii "SP_SL_LICT      "
    .zero 8
    .word 7184,6520,2,0,10,0
    .ascii "SP_SL_LMLT      "
    .zero 8
    .word 7744,6528,2,0,10,0
    .ascii "SP_SL_LTLT      "
    .zero 8
    .word 8304,6536,2,0,10,0
    .ascii "SP_SL_LBLT      "
    .zero 8
    .word 8864,6544,2,0,10,0
    .ascii "SP_SL_LSHF      "
    .zero 8
    .word 9424,6552,2,0,10,0
    .ascii "SP_SL_LICD      "
    .zero 8
    .word 9984,6560,2,0,10,0
    .ascii "SP_SL_LMLD      "
    .zero 8
    .word 10872,6808,2,0,7,0
    .ascii "SP_RR_T         "
    .zero 8
    .word 11432,6816,2,0,7,0
    .ascii "SP_RR_W         "
    .zero 8
    .word 11992,6824,2,0,8,0
    .ascii "SP_RR_FC        "
    .zero 8
    .word 12552,6832,2,0,8,0
    .ascii "SP_RR_IC        "
    .zero 8
    .word 13112,6840,2,0,9,0
    .ascii "SP_RR_FP1       "
    .zero 8
    .word 14000,7088,2,0,10,0
    .ascii "SP_CL_TCLS      "
    .zero 8
    .word 14560,7096,2,0,11,0
    .ascii "SP_CL_HUCLS     "
    .zero 8
    .word 15120,7104,2,0,10,0
    .ascii "SP_CL_UCLS      "
    .zero 8
    .word 15680,7112,2,0,10,0
    .ascii "SP_CL_VCLS      "
    .zero 8
    .word 16240,7120,2,0,11,0
    .ascii "SP_CL_NUCLS     "
    .zero 8
    .word 16800,7128,2,0,11,0
    .ascii "SP_CL_NVCLS     "
    .zero 8
    .word 17688,7400,3,0,8,0
    .ascii "SP_OM_TO        "
    .zero 8
    .word 18416,7408,3,0,8,0
    .ascii "SP_OM_SO        "
    .zero 8
    .word 19144,7416,3,0,8,0
    .ascii "SP_OM_UO        "
    .zero 8
    .word 19872,7424,3,0,8,0
    .ascii "SP_OM_VO        "
    .zero 8
    .word 22056,8960,2,0,9,0
    .ascii "SD_VF_Z0F       "
    .zero 8
    .word 22616,8968,2,0,10,0
    .ascii "SD_VF_ALBF      "
    .zero 8
    .word 23176,8976,2,0,11,0
    .ascii "SD_VF_EMISF     "
    .zero 8
    .word 23736,8984,2,0,11,0
    .ascii "SD_VF_GETRL     "
    .zero 8
    .word 24296,8992,2,0,9,0
    .ascii "SD_VF_LSM       "
    .zero 8
    .word 24856,9000,2,0,9,0
    .ascii "SD_VF_VEG       "
    .zero 8
    .word 25416,9008,2,0,11,0
    .ascii "SD_VF_VRLAN     "
    .zero 8
    .word 25976,9016,2,0,11,0
    .ascii "SD_VF_VRLDI     "
    .zero 8
    .word 26536,9024,2,0,9,0
    .ascii "SD_VF_SIG       "
    .zero 8
    .word 27096,9032,2,0,11,0
    .ascii "SD_VF_ALBSF     "
    .zero 8
    .word 27656,9040,2,0,9,0
    .ascii "SD_VF_LAN       "
    .zero 8
    .word 28216,9048,2,0,9,0
    .ascii "SD_VF_SST       "
    .zero 8
    .word 28776,9056,2,0,9,0
    .ascii "SD_VF_SSS       "
    .zero 8
    .word 29336,9064,2,0,10,0
    .ascii "SD_VF_LZ0H      "
    .zero 8
    .word 29896,9072,2,0,9,0
    .ascii "SD_VF_CVL       "
    .zero 8
    .word 30456,9080,2,0,12,0
    .ascii "SD_VF_CO2TYP    "
    .zero 8
    .word 31016,9088,2,0,9,0
    .ascii "SD_VF_CVH       "
    .zero 8
    .word 31576,9096,2,0,9,0
    .ascii "SD_VF_CUR       "
    .zero 8
    .word 32136,9104,2,0,9,0
    .ascii "SD_VF_TVL       "
    .zero 8
    .word 32696,9112,2,0,9,0
    .ascii "SD_VF_TVH       "
    .zero 8
    .word 33256,9128,2,0,10,0
    .ascii "SD_VF_LAIL      "
    .zero 8
    .word 33816,9136,2,0,10,0
    .ascii "SD_VF_LAIH      "
    .zero 8
    .word 34376,9120,2,0,10,0
    .ascii "SD_VF_FWET      "
    .zero 8
    .word 34936,9144,2,0,10,0
    .ascii "SD_VF_SOTY      "
    .zero 8
    .word 35496,9152,2,0,9,0
    .ascii "SD_VF_CLK       "
    .zero 8
    .word 36056,9160,2,0,8,0
    .ascii "SD_VF_DL        "
    .zero 8
    .word 36616,9168,2,0,8,0
    .ascii "SD_VF_CI        "
    .zero 8
    .word 37176,9176,2,0,10,0
    .ascii "SD_VF_UCUR      "
    .zero 8
    .word 37736,9184,2,0,10,0
    .ascii "SD_VF_VCUR      "
    .zero 8
    .word 38296,9192,2,0,11,0
    .ascii "SD_VF_Z0RLF     "
    .zero 8
    .word 38856,9200,2,0,10,0
    .ascii "SD_VF_CGPP      "
    .zero 8
    .word 39416,9208,2,0,10,0
    .ascii "SD_VF_CREC      "
    .zero 8
    .word 39976,9216,2,0,11,0
    .ascii "SD_VF_SDFOR     "
    .zero 8
    .word 40536,9224,2,0,11,0
    .ascii "SD_VF_ALUVP     "
    .zero 8
    .word 41096,9232,2,0,11,0
    .ascii "SD_VF_ALUVD     "
    .zero 8
    .word 41656,9240,2,0,11,0
    .ascii "SD_VF_ALNIP     "
    .zero 8
    .word 42216,9248,2,0,11,0
    .ascii "SD_VF_ALNID     "
    .zero 8
    .word 42776,9312,2,0,9,0
    .ascii "SD_VF_FP1       "
    .zero 8
    .word 43336,9320,2,0,11,0
    .ascii "SD_VF_SO2DD     "
    .zero 8
    .word 43896,9328,2,0,10,0
    .ascii "SD_VF_DMSO      "
    .zero 8
    .word 44456,9336,2,0,10,0
    .ascii "SD_VF_URBF      "
    .zero 8
    .word 45016,9344,2,0,10,0
    .ascii "SD_VF_FCA1      "
    .zero 8
    .word 45576,9352,2,0,10,0
    .ascii "SD_VF_FCA2      "
    .zero 8
    .word 46136,9360,2,0,12,0
    .ascii "SD_VF_AERDEP    "
    .zero 8
    .word 46696,9368,2,0,12,0
    .ascii "SD_VF_AERLTS    "
    .zero 8
    .word 47256,9376,2,0,12,0
    .ascii "SD_VF_AERSCC    "
    .zero 8
    .word 47816,9384,2,0,9,0
    .ascii "SD_VF_DSF       "
    .zero 8
    .word 48376,9400,2,1,14,0
    .ascii "SD_VF_CHEMFLXO  "
    .zero 8
    .word 48440,9464,2,1,15,0
    .ascii "SD_VF_CHEMWDFLX "
    .zero 8
    .word 48504,9528,2,1,15,0
    .ascii "SD_VF_CHEMDDFLX "
    .zero 8
    .word 48568,9592,2,1,12,0
    .ascii "SD_VF_CHEMDV    "
    .zero 8
    .word 48632,9784,2,0,10,0
    .ascii "SD_VF_NUDM      "
    .zero 8
    .word 49192,9656,2,1,12,0
    .ascii "SD_VF_EMIS2D    "
    .zero 8
    .word 49256,9720,2,1,15,0
    .ascii "SD_VF_EMIS2DAUX "
    .zero 8
    .word 49648,10608,2,0,9,0
    .ascii "SD_VN_TOP       "
    .zero 8
    .word 50208,10616,2,0,9,0
    .ascii "SD_VN_BAS       "
    .zero 8
    .word 50768,10624,2,0,10,0
    .ascii "SD_VN_ACPR      "
    .zero 8
    .word 51328,10632,2,0,11,0
    .ascii "SD_VN_ACCPR     "
    .zero 8
    .word 51888,10640,2,0,12,0
    .ascii "SD_VN_ACCPR5    "
    .zero 8
    .word 52776,12016,2,0,11,0
    .ascii "SD_V2_OCDEP     "
    .zero 8
    .word 53336,12024,2,0,11,0
    .ascii "SD_V2_USTRC     "
    .zero 8
    .word 53896,12032,2,0,11,0
    .ascii "SD_V2_VSTRC     "
    .zero 8
    .word 54784,12304,3,0,10,0
    .ascii "SD_V3_DIFM      "
    .zero 8
    .word 55512,12312,3,0,10,0
    .ascii "SD_V3_DIFT      "
    .zero 8
    .word 56240,12320,3,0,10,0
    .ascii "SD_V3_DIFS      "
    .zero 8
    .word 56968,12328,3,0,10,0
    .ascii "SD_V3_ADVT      "
    .zero 8
    .word 57696,12336,3,0,10,0
    .ascii "SD_V3_ADVS      "
    .zero 8
    .word 58424,12344,3,0,10,0
    .ascii "SD_V3_TRI0      "
    .zero 8
    .word 59152,12352,3,0,10,0
    .ascii "SD_V3_TRI1      "
    .zero 8
    .word 59880,12360,3,0,10,0
    .ascii "SD_V3_SWDK      "
    .zero 8
    .word 60608,12368,3,0,8,0
    .ascii "SD_V3_ZO        "
    .zero 8
    .word 61336,12376,3,0,8,0
    .ascii "SD_V3_HO        "
    .zero 8
    .word 62064,12384,3,0,8,0
    .ascii "SD_V3_DO        "
    .zero 8
    .word 62792,12392,3,0,12,0
    .ascii "SD_V3_HO_INV    "
    .zero 8
    .word 63520,12400,3,0,9,0
    .ascii "SD_V3_UOC       "
    .zero 8
    .word 64248,12408,3,0,9,0
    .ascii "SD_V3_VOC       "
    .zero 8
    .word 64976,12416,3,0,10,0
    .ascii "SD_V3_OTKE      "
    .zero 8
    .word 66104,12664,2,0,9,0
    .ascii "SD_VD_LSP       "
    .zero 8
    .word 66664,12672,2,0,8,0
    .ascii "SD_VD_CP        "
    .zero 8
    .word 67224,12680,2,0,8,0
    .ascii "SD_VD_SF        "
    .zero 8
    .word 67784,12688,2,0,10,0
    .ascii "SD_VD_FZRA      "
    .zero 8
    .word 68344,12696,2,0,9,0
    .ascii "SD_VD_BLD       "
    .zero 8
    .word 68904,12704,2,0,10,0
    .ascii "SD_VD_SSHF      "
    .zero 8
    .word 69464,12712,2,0,10,0
    .ascii "SD_VD_SLHF      "
    .zero 8
    .word 70024,12720,2,0,9,0
    .ascii "SD_VD_NEE       "
    .zero 8
    .word 70584,12728,2,0,9,0
    .ascii "SD_VD_GPP       "
    .zero 8
    .word 71144,12736,2,0,9,0
    .ascii "SD_VD_REC       "
    .zero 8
    .word 71704,12744,2,0,9,0
    .ascii "SD_VD_MSL       "
    .zero 8
    .word 72264,12752,2,0,8,0
    .ascii "SD_VD_SP        "
    .zero 8
    .word 72824,12760,2,0,9,0
    .ascii "SD_VD_TCC       "
    .zero 8
    .word 73384,12768,2,0,9,0
    .ascii "SD_VD_10U       "
    .zero 8
    .word 73944,12776,2,0,9,0
    .ascii "SD_VD_10V       "
    .zero 8
    .word 74504,12784,2,0,8,0
    .ascii "SD_VD_2T        "
    .zero 8
    .word 75064,12792,2,0,8,0
    .ascii "SD_VD_2D        "
    .zero 8
    .word 75624,12800,2,0,9,0
    .ascii "SD_VD_2SH       "
    .zero 8
    .word 76184,12808,2,0,9,0
    .ascii "SD_VD_SSR       "
    .zero 8
    .word 76744,12816,2,0,9,0
    .ascii "SD_VD_STR       "
    .zero 8
    .word 77304,12824,2,0,9,0
    .ascii "SD_VD_TSR       "
    .zero 8
    .word 77864,12832,2,0,9,0
    .ascii "SD_VD_TTR       "
    .zero 8
    .word 78424,12840,2,0,10,0
    .ascii "SD_VD_EWSS      "
    .zero 8
    .word 78984,12848,2,0,10,0
    .ascii "SD_VD_NSSS      "
    .zero 8
    .word 79544,12856,2,0,7,0
    .ascii "SD_VD_E         "
    .zero 8
    .word 80104,12864,2,0,9,0
    .ascii "SD_VD_PEV       "
    .zero 8
    .word 80664,12872,2,0,9,0
    .ascii "SD_VD_CCC       "
    .zero 8
    .word 81224,12880,2,0,9,0
    .ascii "SD_VD_LCC       "
    .zero 8
    .word 81784,12888,2,0,9,0
    .ascii "SD_VD_MCC       "
    .zero 8
    .word 82344,12896,2,0,9,0
    .ascii "SD_VD_HCC       "
    .zero 8
    .word 82904,12904,2,0,10,0
    .ascii "SD_VD_LGWS      "
    .zero 8
    .word 83464,12912,2,0,10,0
    .ascii "SD_VD_MGWS      "
    .zero 8
    .word 84024,12920,2,0,9,0
    .ascii "SD_VD_GWD       "
    .zero 8
    .word 84584,12928,2,0,10,0
    .ascii "SD_VD_MX2T      "
    .zero 8
    .word 85144,12936,2,0,10,0
    .ascii "SD_VD_MN2T      "
    .zero 8
    .word 85704,12944,2,1,11,0
    .ascii "SD_VD_MX2T6     "
    .zero 8
    .word 85768,13008,2,1,11,0
    .ascii "SD_VD_MN2T6     "
    .zero 8
    .word 85832,13072,2,0,8,0
    .ascii "SD_VD_RO        "
    .zero 8
    .word 86392,13080,2,0,9,0
    .ascii "SD_VD_SRO       "
    .zero 8
    .word 86952,13088,2,0,10,0
    .ascii "SD_VD_SSRO      "
    .zero 8
    .word 87512,13096,2,0,9,0
    .ascii "SD_VD_ALB       "
    .zero 8
    .word 88072,13104,2,0,11,0
    .ascii "SD_VD_IEWSS     "
    .zero 8
    .word 88632,13112,2,0,11,0
    .ascii "SD_VD_INSSS     "
    .zero 8
    .word 89192,13120,2,0,11,0
    .ascii "SD_VD_ISSHF     "
    .zero 8
    .word 89752,13128,2,0,8,0
    .ascii "SD_VD_IE        "
    .zero 8
    .word 90312,13136,2,0,10,0
    .ascii "SD_VD_INEE      "
    .zero 8
    .word 90872,13144,2,0,10,0
    .ascii "SD_VD_IGPP      "
    .zero 8
    .word 91432,13152,2,0,10,0
    .ascii "SD_VD_IREC      "
    .zero 8
    .word 91992,13160,2,0,10,0
    .ascii "SD_VD_ICH4      "
    .zero 8
    .word 92552,13168,2,0,9,0
    .ascii "SD_VD_CSF       "
    .zero 8
    .word 93112,13176,2,0,10,0
    .ascii "SD_VD_LSSF      "
    .zero 8
    .word 93672,13184,2,0,11,0
    .ascii "SD_VD_MXTPR     "
    .zero 8
    .word 94232,13192,2,0,11,0
    .ascii "SD_VD_MNTPR     "
    .zero 8
    .word 94792,13200,2,1,12,0
    .ascii "SD_VD_MXTPR6    "
    .zero 8
    .word 94856,13264,2,1,12,0
    .ascii "SD_VD_MNTPR6    "
    .zero 8
    .word 94920,13328,2,0,9,0
    .ascii "SD_VD_TPR       "
    .zero 8
    .word 95480,13336,2,0,10,0
    .ascii "SD_VD_LSRR      "
    .zero 8
    .word 96040,13344,2,0,9,0
    .ascii "SD_VD_CRR       "
    .zero 8
    .word 96600,13352,2,0,11,0
    .ascii "SD_VD_LSSFR     "
    .zero 8
    .word 97160,13360,2,0,10,0
    .ascii "SD_VD_CSFR      "
    .zero 8
    .word 97720,13368,2,0,11,0
    .ascii "SD_VD_PTYPE     "
    .zero 8
    .word 98280,13376,2,0,11,0
    .ascii "SD_VD_ILSPF     "
    .zero 8
    .word 98840,13384,2,0,9,0
    .ascii "SD_VD_Z0F       "
    .zero 8
    .word 99400,13392,2,0,10,0
    .ascii "SD_VD_LZ0H      "
    .zero 8
    .word 99960,13400,2,0,11,0
    .ascii "SD_VD_VIWVE     "
    .zero 8
    .word 100520,13408,2,0,11,0
    .ascii "SD_VD_VIWVN     "
    .zero 8
    .word 101080,13416,2,0,9,0
    .ascii "SD_VD_TCW       "
    .zero 8
    .word 101640,13424,2,0,10,0
    .ascii "SD_VD_TCWV      "
    .zero 8
    .word 102200,13432,2,0,10,0
    .ascii "SD_VD_TCLW      "
    .zero 8
    .word 102760,13440,2,0,10,0
    .ascii "SD_VD_TCIW      "
    .zero 8
    .word 103320,13448,2,0,10,0
    .ascii "SD_VD_TCRW      "
    .zero 8
    .word 103880,13456,2,0,10,0
    .ascii "SD_VD_TCSW      "
    .zero 8
    .word 104440,13464,2,0,11,0
    .ascii "SD_VD_TCSLW     "
    .zero 8
    .word 105000,13472,2,0,10,0
    .ascii "SD_VD_SSRD      "
    .zero 8
    .word 105560,13480,2,0,10,0
    .ascii "SD_VD_STRD      "
    .zero 8
    .word 106120,13488,2,0,11,0
    .ascii "SD_VD_SSRDC     "
    .zero 8
    .word 106680,13496,2,0,11,0
    .ascii "SD_VD_STRDC     "
    .zero 8
    .word 107240,13504,2,0,9,0
    .ascii "SD_VD_BLH       "
    .zero 8
    .word 107800,13512,2,0,10,0
    .ascii "SD_VD_SUND      "
    .zero 8
    .word 108360,13520,2,0,10,0
    .ascii "SD_VD_SPAR      "
    .zero 8
    .word 108920,13528,2,0,10,0
    .ascii "SD_VD_SUVB      "
    .zero 8
    .word 109480,13536,2,0,11,0
    .ascii "SD_VD_SFDIR     "
    .zero 8
    .word 110040,13544,2,0,11,0
    .ascii "SD_VD_SCDIR     "
    .zero 8
    .word 110600,13552,2,0,11,0
    .ascii "SD_VD_SDSRP     "
    .zero 8
    .word 111160,13560,2,0,10,0
    .ascii "SD_VD_CAPE      "
    .zero 8
    .word 111720,13568,2,0,12,0
    .ascii "SD_VD_MUCAPE    "
    .zero 8
    .word 112280,13576,2,0,14,0
    .ascii "SD_VD_MLCAPE50  "
    .zero 8
    .word 112840,13584,2,0,15,0
    .ascii "SD_VD_MLCAPE100 "
    .zero 8
    .word 113400,13592,2,0,11,0
    .ascii "SD_VD_PDEPL     "
    .zero 8
    .word 113960,13600,2,0,11,0
    .ascii "SD_VD_CAPES     "
    .zero 8
    .word 114520,13608,2,1,12,0
    .ascii "SD_VD_MXCAP6    "
    .zero 8
    .word 114584,13672,2,1,13,0
    .ascii "SD_VD_MXCAPS6   "
    .zero 8
    .word 114648,13736,2,0,13,0
    .ascii "SD_VD_TROPOTP   "
    .zero 8
    .word 115208,13744,2,0,10,0
    .ascii "SD_VD_TSRC      "
    .zero 8
    .word 115768,13752,2,0,10,0
    .ascii "SD_VD_TTRC      "
    .zero 8
    .word 116328,13760,2,0,10,0
    .ascii "SD_VD_SSRC      "
    .zero 8
    .word 116888,13768,2,0,10,0
    .ascii "SD_VD_STRC      "
    .zero 8
    .word 117448,13776,2,0,8,0
    .ascii "SD_VD_ES        "
    .zero 8
    .word 118008,13784,2,0,10,0
    .ascii "SD_VD_SMLT      "
    .zero 8
    .word 118568,13792,2,0,10,0
    .ascii "SD_VD_10FG      "
    .zero 8
    .word 119128,13800,2,1,11,0
    .ascii "SD_VD_10FG6     "
    .zero 8
    .word 119192,13864,2,0,12,0
    .ascii "SD_VD_10FGCV    "
    .zero 8
    .word 119752,13872,2,0,11,0
    .ascii "SD_VD_I10FG     "
    .zero 8
    .word 120312,13880,2,0,10,0
    .ascii "SD_VD_LSPF      "
    .zero 8
    .word 120872,13888,2,0,10,0
    .ascii "SD_VD_TCO3      "
    .zero 8
    .word 121432,13896,2,0,10,0
    .ascii "SD_VD_VIMD      "
    .zero 8
    .word 121992,13904,2,0,11,0
    .ascii "SD_VD_SPARC     "
    .zero 8
    .word 122552,13912,2,0,11,0
    .ascii "SD_VD_STINC     "
    .zero 8
    .word 123112,13920,2,0,11,0
    .ascii "SD_VD_CBASE     "
    .zero 8
    .word 123672,13928,2,0,11,0
    .ascii "SD_VD_0DEGL     "
    .zero 8
    .word 124232,13936,2,0,13,0
    .ascii "SD_VD_M10DEGL   "
    .zero 8
    .word 124792,13944,2,0,11,0
    .ascii "SD_VD_VISIH     "
    .zero 8
    .word 125352,13952,2,0,9,0
    .ascii "SD_VD_CIN       "
    .zero 8
    .word 125912,13960,2,0,13,0
    .ascii "SD_VD_MLCIN50   "
    .zero 8
    .word 126472,13968,2,0,14,0
    .ascii "SD_VD_MLCIN100  "
    .zero 8
    .word 127032,13976,2,0,12,0
    .ascii "SD_VD_KINDEX    "
    .zero 8
    .word 127592,13984,2,0,13,0
    .ascii "SD_VD_TTINDEX   "
    .zero 8
    .word 128152,13992,2,0,12,0
    .ascii "SD_VD_CBASEA    "
    .zero 8
    .word 128712,14000,2,0,11,0
    .ascii "SD_VD_CTOPC     "
    .zero 8
    .word 129272,14008,2,0,13,0
    .ascii "SD_VD_ZTWETB0   "
    .zero 8
    .word 129832,14016,2,0,13,0
    .ascii "SD_VD_ZTWETB1   "
    .zero 8
    .word 130392,14024,2,1,11,0
    .ascii "SD_VD_TCGHG     "
    .zero 8
    .word 130456,14088,2,1,12,0
    .ascii "SD_VD_TCCHEM    "
    .zero 8
    .word 130520,14152,2,2,14,0
    .ascii "SD_VD_AERODIAG  "
    .zero 8
    .word 130608,14240,2,2,19,0
    .ascii "SD_VD_AERO_WVL_D"
    .zero 8
    .word 130696,14328,2,0,10,0
    .ascii "SD_VD_100U      "
    .zero 8
    .word 131256,14336,2,0,10,0
    .ascii "SD_VD_100V      "
    .zero 8
    .word 131816,14344,2,0,10,0
    .ascii "SD_VD_200U      "
    .zero 8
    .word 132376,14352,2,0,10,0
    .ascii "SD_VD_200V      "
    .zero 8
    .word 132936,14360,2,0,10,0
    .ascii "SD_VD_ZUST      "
    .zero 8
    .word 133496,14368,2,0,10,0
    .ascii "SD_VD_10NU      "
    .zero 8
    .word 134056,14376,2,0,10,0
    .ascii "SD_VD_10NV      "
    .zero 8
    .word 134616,14384,2,0,11,0
    .ascii "SD_VD_DNDZN     "
    .zero 8
    .word 135176,14392,2,0,11,0
    .ascii "SD_VD_DNDZA     "
    .zero 8
    .word 135736,14400,2,0,10,0
    .ascii "SD_VD_DCTB      "
    .zero 8
    .word 136296,14408,2,0,10,0
    .ascii "SD_VD_TPLB      "
    .zero 8
    .word 136856,14416,2,0,10,0
    .ascii "SD_VD_TPLT      "
    .zero 8
    .word 137416,14424,2,0,10,0
    .ascii "SD_VD_ODSS      "
    .zero 8
    .word 137976,14432,2,0,10,0
    .ascii "SD_VD_ODDU      "
    .zero 8
    .word 138536,14440,2,0,10,0
    .ascii "SD_VD_ODOM      "
    .zero 8
    .word 139096,14448,2,0,10,0
    .ascii "SD_VD_ODBC      "
    .zero 8
    .word 139656,14456,2,0,10,0
    .ascii "SD_VD_ODSU      "
    .zero 8
    .word 140216,14464,2,0,10,0
    .ascii "SD_VD_ODNI      "
    .zero 8
    .word 140776,14472,2,0,10,0
    .ascii "SD_VD_ODAM      "
    .zero 8
    .word 141336,14480,2,0,11,0
    .ascii "SD_VD_ODSOA     "
    .zero 8
    .word 141896,14488,2,0,11,0
    .ascii "SD_VD_ODVFA     "
    .zero 8
    .word 142456,14496,2,0,11,0
    .ascii "SD_VD_ODVSU     "
    .zero 8
    .word 143016,14504,2,0,13,0
    .ascii "SD_VD_ODTOACC   "
    .zero 8
    .word 143576,14512,2,0,11,0
    .ascii "SD_VD_AEPM1     "
    .zero 8
    .word 144136,14520,2,0,12,0
    .ascii "SD_VD_AEPM25    "
    .zero 8
    .word 144696,14528,2,0,12,0
    .ascii "SD_VD_AEPM10    "
    .zero 8
    .word 145256,14536,2,0,11,0
    .ascii "SD_VD_UVBED     "
    .zero 8
    .word 145816,14544,2,0,13,0
    .ascii "SD_VD_UVBEDCS   "
    .zero 8
    .word 146376,14552,2,0,12,0
    .ascii "SD_VD_LITOTI    "
    .zero 8
    .word 146936,14560,2,0,11,0
    .ascii "SD_VD_LICGI     "
    .zero 8
    .word 147496,14568,2,1,13,0
    .ascii "SD_VD_LITOTA6   "
    .zero 8
    .word 147560,14632,2,1,12,0
    .ascii "SD_VD_LICGA6    "
    .zero 8
    .word 147624,14768,2,2,15,0
    .ascii "SD_VD_PTYPEOCC6 "
    .zero 8
    .word 148040,15056,3,0,10,0
    .ascii "SD_SM_CLBT      "
    .zero 8
    .word 148768,15064,3,0,10,0
    .ascii "SD_SM_CSBT      "
    .zero 8
    .word 149896,15376,2,0,10,0
    .ascii "SD_WS_CHAR      "
    .zero 8
    .word 150456,15384,2,0,12,0
    .ascii "SD_WS_CHARHQ    "
    .zero 8
    .word 151016,15392,2,0,13,0
    .ascii "SD_WS_USTOKES   "
    .zero 8
    .word 151576,15400,2,0,13,0
    .ascii "SD_WS_VSTOKES   "
    .zero 8
    .word 152136,15408,2,0,12,0
    .ascii "SD_WS_TAUOCX    "
    .zero 8
    .word 152696,15416,2,0,12,0
    .ascii "SD_WS_TAUOCY    "
    .zero 8
    .word 153256,15424,2,0,11,0
    .ascii "SD_WS_PHIOC     "
    .zero 8
    .word 153816,15432,2,0,13,0
    .ascii "SD_WS_WSEMEAN   "
    .zero 8
    .word 154376,15440,2,0,13,0
    .ascii "SD_WS_WSFMEAN   "
    .zero 8
    .word 155264,15688,2,0,10,0
    .ascii "SD_WW_U10N      "
    .zero 8
    .word 155824,15696,2,0,10,0
    .ascii "SD_WW_V10N      "
    .zero 8
    .word 156384,15704,2,0,9,0
    .ascii "SD_WW_RHO       "
    .zero 8
    .word 156944,15712,2,0,9,0
    .ascii "SD_WW_ZIL       "
    .zero 8
    .word 157504,15720,2,0,9,0
    .ascii "SD_WW_CIF       "
    .zero 8
    .word 158064,15728,2,0,9,0
    .ascii "SD_WW_CLK       "
    .zero 8
    .word 158624,15736,2,0,11,0
    .ascii "SD_WW_UCURW     "
    .zero 8
    .word 159184,15744,2,0,11,0
    .ascii "SD_WW_VCURW     "
    .zero 8
#if defined(MD2ASM_REGISTRY_LAYOUT_ONLY) || defined(MD2ASM_PUBLISH_REGISTRY_CLEANUP_LAYOUTS)
.section .rodata
.global md2asm_registry_surface_variable_layout
.type md2asm_registry_surface_variable_layout,%object
.set md2asm_registry_surface_variable_layout,.Lsurface_rows
.size md2asm_registry_surface_variable_layout,13632
.global md2asm_registry_surface_group_layout
.type md2asm_registry_surface_group_layout,%object
.set md2asm_registry_surface_group_layout,.Lsurface_groups
.size md2asm_registry_surface_group_layout,608
#endif
.section .note.GNU-stack,"",%progbits

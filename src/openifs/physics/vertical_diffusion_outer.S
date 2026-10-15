/* Direct selected VDFOUTER body from OpenIFS 48.1.1.
 * Physics formulations/openifs/physics/vertical_diffusion_rates.md.
 * Contract skills/md2asm/references/openifs/physics/vertical_diffusion_rates.md.
 * Frozen numerical body and current private interfaces are preserved. */
.text
.p2align 4
.macro ARG reg,arg
 ldr \reg,[x19,#(\arg*8)]
.endm
.macro FIELD_LOAD reg,arg
 ARG x9,\arg
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro FIELD_STORE reg,arg
 ARG x9,\arg
 str \reg,[x9,x10,lsl #3]
.endm
.macro MODEL_ADDR reg,offset
 mov x16,#(\offset & 65535)
 movk x16,#(\offset >> 16),lsl #16
 add \reg,x25,x16
.endm
.macro PLACE dest
 .if \dest<8
  mov x\dest,x9
 .else
  str x9,[sp,#((\dest-8)*8)]
 .endif
.endm
.macro PARG dest,arg
 ARG x9,\arg
 PLACE \dest
.endm
.macro CALL name
 str x18,[sp,#3056]
 bl \name
 ldr x18,[sp,#3056]
.endm
.global md2asm_vertical_diffusion_outer_sea_r2_7358525
.type md2asm_vertical_diffusion_outer_sea_r2_7358525,%function
md2asm_vertical_diffusion_outer_sea_r2_7358525:
 mov x16,sp
 sub sp,sp,#1,lsl #12
 add x17,sp,#1280
 stp x19,x20,[x17]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x25,x26,[x17,#48]
 stp x27,x28,[x17,#64]
 stp x29,x30,[x17,#80]
 stp d8,d9,[x17,#96]
 stp d10,d11,[x17,#112]
 stp d12,d13,[x17,#128]
 stp d14,d15,[x17,#144]
 str x18,[x17,#160]
 add x19,sp,#1536
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 mov x10,#8
.Lvo_arguments:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#169
 b.lt .Lvo_arguments
 ldr x9,[x16]
 str x9,[sp,#2960]
 cmp x9,#1
 b.ne .Lvo_reject
 mrs x9,fpcr
 cbnz x9,.Lvo_reject
 ARG x25,0
 ARG x9,4
 ldr w22,[x9]
 cmp w22,#1
 b.lt .Lvo_reject
 cmp w22,#4096
 b.gt .Lvo_reject
 ARG x9,5
 ldr w28,[x9]
 cmp w28,#3
 b.lt .Lvo_reject
 cmp w28,#512
 b.gt .Lvo_reject
 ARG x9,2
 ldrsw x23,[x9]
 sub x23,x23,#1
 cmp x23,#0
 b.lt .Lvo_reject
 ARG x9,3
 ldrsw x24,[x9]
 cmp x24,x22
 b.gt .Lvo_reject
 // Empty intervals still select child whole-owner work in the original.
 cmp x24,x23
 b.le .Lvo_reject
 ARG x9,6
 ldr w9,[x9]
 cmp w9,#4
 b.ne .Lvo_reject
 ARG x9,7
 ldr w9,[x9]
 cmp w9,#9
 b.ne .Lvo_reject
 MODEL_ADDR x9,1578180
 ldr w9,[x9]
 cbnz w9,.Lvo_reject
 MODEL_ADDR x9,1552928
 ldr w9,[x9]
 cbnz w9,.Lvo_reject
 MODEL_ADDR x9,1578020
 ldr w9,[x9]
 cbz w9,.Lvo_no_tracer_route
 ARG x9,10
 ldr w9,[x9]
 cbnz w9,.Lvo_reject
.Lvo_no_tracer_route:
 adrp x9,:got:__yomct3_MOD_nstep
 ldr x9,[x9,:got_lo12:__yomct3_MOD_nstep]
 ldr w9,[x9]
 cmp w9,#0
 b.lt .Lvo_reject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lvo_reject
 str w9,[sp,#2900]
 cbz w9,.Lvo_entry_hook_done
 adr x0,.Lvo_hook_name
 add x1,sp,#2904
 str wzr,[x1]
 add x2,sp,#2912
 mov x3,#8
 CALL __yomhook_MOD_dr_hook_default8
.Lvo_entry_hook_done:
 // Copy rates in complete original layer and row order.
 mov x21,#0
.Lvo_copy_momentum_temperature_layer:
 mov x20,x23
.Lvo_copy_momentum_temperature_row:
 madd x10,x21,x22,x20
 // PVOM
 FIELD_LOAD x11,120
 FIELD_STORE x11,127
 // PVOL
 FIELD_LOAD x11,121
 FIELD_STORE x11,128
 // PTE
 FIELD_LOAD x11,115
 FIELD_STORE x11,122
 add x20,x20,#1
 cmp x20,x24
 b.lt .Lvo_copy_momentum_temperature_row
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lvo_copy_momentum_temperature_layer
 // Copy rates in complete original layer and row order.
 mov x21,#0
.Lvo_copy_water_cloud_layer:
 mov x20,x23
.Lvo_copy_water_cloud_row:
 madd x10,x21,x22,x20
 // PQE
 FIELD_LOAD x11,116
 FIELD_STORE x11,123
 // PLE
 FIELD_LOAD x11,117
 FIELD_STORE x11,124
 // PIE
 FIELD_LOAD x11,118
 FIELD_STORE x11,125
 // PAE
 FIELD_LOAD x11,119
 FIELD_STORE x11,126
 add x20,x20,#1
 cmp x20,x24
 b.lt .Lvo_copy_water_cloud_row
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lvo_copy_water_cloud_layer

 // Complete named child address map; only KSTEP comes from YOMCT3.
 PARG 0,0 // YDMODEL -> YDMODEL
 PARG 1,1 // CDCONF -> CDCONF
 PARG 2,2 // KIDIA -> KIDIA
 PARG 3,3 // KFDIA -> KFDIA
 PARG 4,4 // KLON -> KLON
 PARG 5,5 // KLEV -> KLEV
 PARG 6,6 // KLEVS -> KLEVS
 adrp x9,:got:__yomct3_MOD_nstep
 ldr x9,[x9,:got_lo12:__yomct3_MOD_nstep]
 PLACE 7
 PARG 8,7 // KTILES -> KTILES
 PARG 9,8 // KVTYPES -> KVTYPES
 PARG 10,9 // KDIAG -> KDIAG
 PARG 11,10 // KTRAC -> KTRAC
 PARG 12,11 // KCHEM -> KCHEM
 PARG 13,12 // KAERO -> KAERO
 PARG 14,13 // KLEVSN -> KLEVSN
 PARG 15,14 // KLEVI -> KLEVI
 PARG 16,15 // KDHVTLS -> KDHVTLS
 PARG 17,16 // KDHFTLS -> KDHFTLS
 PARG 18,17 // KDHVTSS -> KDHVTSS
 PARG 19,18 // KDHFTSS -> KDHFTSS
 PARG 20,19 // KDHVTTS -> KDHVTTS
 PARG 21,20 // KDHFTTS -> KDHFTTS
 PARG 22,21 // KDHVTIS -> KDHVTIS
 PARG 23,22 // KDHFTIS -> KDHFTIS
 PARG 24,23 // KDHVCO2S -> KDHVCO2S
 PARG 25,24 // KDHFCO2S -> KDHFCO2S
 PARG 26,25 // KDHVVEGS -> KDHVVEGS
 PARG 27,26 // KDHFVEGS -> KDHFVEGS
 PARG 28,27 // PTSPHY -> PTSPHY
 PARG 29,28 // KTVL -> KTVL
 PARG 30,29 // KCO2TYP -> KCO2TYP
 PARG 31,30 // KTVH -> KTVH
 PARG 32,31 // PCVL -> PCVL
 PARG 33,32 // PCVH -> PCVH
 PARG 34,33 // PCUR -> PCUR
 PARG 35,36 // PFWET -> PFWET
 PARG 36,34 // PLAIL -> PLAIL
 PARG 37,35 // PLAIH -> PLAIH
 PARG 38,37 // PSNS -> PSNM
 PARG 39,38 // PRSN -> PRSN
 PARG 40,39 // PMU0 -> PMU0
 PARG 41,40 // PSIGFLT -> PSIGFLT
 PARG 42,41 // PUM1 -> PUM1
 PARG 43,42 // PVM1 -> PVM1
 PARG 44,43 // PTM1 -> PTM1
 PARG 45,44 // PQM1 -> PQM1
 PARG 46,46 // PLM1 -> PLM1
 PARG 47,47 // PIM1 -> PIM1
 PARG 48,48 // PAM1 -> PAM1
 PARG 49,49 // PCM1 -> PCM1
 PARG 50,45 // PTKE1 -> PTKE1
 PARG 51,50 // PAPHM1 -> PAPHM1
 PARG 52,51 // PAPM1 -> PAPM1
 PARG 53,52 // PGEOM1 -> PGEOM1
 PARG 54,53 // PGEOH -> PGEOH
 PARG 55,54 // PGELAT -> PGELAT
 PARG 56,55 // PTSKM1M -> PTSKM1M
 PARG 57,56 // PTSAM1M -> PTSAM1M
 PARG 58,57 // PWSAM1M -> PWSAM1M
 PARG 59,58 // PSSRFL -> PSSRFL
 PARG 60,59 // PSLRFL -> PSLRFL
 PARG 61,60 // PEMIS -> PEMIS
 PARG 62,61 // PHRLW -> PHRLW
 PARG 63,62 // PHRSW -> PHRSW
 PARG 64,63 // PTSNOW -> PTSN
 PARG 65,64 // PTICE -> PTICE
 PARG 66,65 // PHLICE -> PHLICE
 PARG 67,66 // PTLICE -> PTLICE
 PARG 68,67 // PTLWML -> PTLWML
 PARG 69,68 // PSST -> PSST
 PARG 70,69 // KSOTY -> KSOTY
 PARG 71,70 // PFRTI -> PFRTI
 PARG 72,71 // PALBTI -> PALBTI
 PARG 73,72 // PWLMX -> PWLMX
 PARG 74,73 // PCHAR -> PCHAR
 PARG 75,74 // PCHARHQ -> PCHARHQ
 PARG 76,75 // PUCURR -> PUCURR
 PARG 77,76 // PVCURR -> PVCURR
 PARG 78,77 // PUSTOKES -> PUSTOKES
 PARG 79,78 // PVSTOKES -> PVSTOKES
 PARG 80,79 // PTSKRAD -> PTSKRAD
 PARG 81,80 // PCFLX -> PCFLX
 PARG 82,81 // PDDVLC -> PDDVLC
 PARG 83,82 // PSOTEU -> PSOTEU
 PARG 84,83 // PSOTEV -> PSOTEV
 PARG 85,84 // PSOBETA -> PSOBETA
 PARG 86,85 // PTHKICE -> PTHKICE
 PARG 87,86 // PSNTICE -> PSNTICE
 PARG 88,87 // PGP2DSPP -> PGP2DSPP
 PARG 89,88 // LSICOUP -> LSICOUP
 PARG 90,89 // PZ0M -> PZ0M
 PARG 91,90 // PZ0H -> PZ0H
 PARG 92,91 // PVDIS -> PVDIS
 PARG 93,92 // PVDISG -> PVDISG
 PARG 94,93 // PDISGW3D -> PDISGW3D
 PARG 95,94 // PAHFLEV -> PAHFLEV
 PARG 96,95 // PAHFLSB -> PAHFLSB
 PARG 97,96 // PFWSB -> PFWSB
 PARG 98,97 // PU10M -> PU10M
 PARG 99,98 // PV10M -> PV10M
 PARG 100,99 // PT2M -> PT2M
 PARG 101,100 // PD2M -> PD2M
 PARG 102,101 // PQ2M -> PQ2M
 PARG 103,102 // PZINV -> PZINV
 PARG 104,103 // PBLH -> PBLH
 PARG 105,104 // PEIS -> PEIS
 PARG 106,105 // P10NU -> P10NU
 PARG 107,106 // P10NV -> P10NV
 PARG 108,107 // PUST -> PUST
 PARG 109,108 // PSSRFLTI -> PSSRFLTI
 PARG 110,109 // PEVAPSNW -> PEVAPSNW
 PARG 111,110 // PEVAPMU -> PEVAPMU
 PARG 112,111 // PEXDIAG -> PEXDIAG
 PARG 113,112 // PGUST -> PGUST
 PARG 114,113 // PI10FGCV -> PI10FGCV
 PARG 115,114 // KPBLTYPE -> KPBLTYPE
 PARG 116,122 // PTE -> PTE
 PARG 117,123 // PQE -> PQE
 PARG 118,124 // PLE -> PLE
 PARG 119,125 // PIE -> PIE
 PARG 120,126 // PAE -> PAE
 PARG 121,127 // PVOM -> PVOM
 PARG 122,128 // PVOL -> PVOL
 PARG 123,129 // PTKEE -> PTKEE
 PARG 124,130 // PTENC -> PTENC
 PARG 125,131 // PTSKE1 -> PTSKE1
 PARG 126,132 // PUSTRTI -> PUSTRTI
 PARG 127,133 // PVSTRTI -> PVSTRTI
 PARG 128,134 // PAHFSTI -> PAHFSTI
 PARG 129,135 // PEVAPTI -> PEVAPTI
 PARG 130,136 // PTSKTI -> PTSKTI
 PARG 131,137 // PAHFTRTI -> PFLTRTI
 PARG 132,138 // PANDAYVT -> PANDAYVT
 PARG 133,139 // PANFMVT -> PANFMVT
 PARG 134,140 // PDIFTS -> PDIFTS
 PARG 135,141 // PDIFTQ -> PDIFTQ
 PARG 136,142 // PDIFTL -> PDIFTL
 PARG 137,143 // PDIFTI -> PDIFTI
 PARG 138,144 // PSTRTU -> PSTRTU
 PARG 139,145 // PSTRTV -> PSTRTV
 PARG 140,146 // PTOFDU -> PTOFDU
 PARG 141,147 // PTOFDV -> PTOFDV
 PARG 142,148 // PSTRSOU -> PSTRSOU
 PARG 143,149 // PSTRSOV -> PSTRSOV
 PARG 144,150 // PKH -> PKH
 PARG 145,151 // PKM -> PKM
 PARG 146,152 // PRI -> PRI
 PARG 147,153 // PAN -> PAN
 PARG 148,154 // PAG -> PAG
 PARG 149,155 // PRD -> PRD
 PARG 150,156 // PRSOIL_STR -> PRSOIL_STR
 PARG 151,157 // PRECO -> PRECO
 PARG 152,158 // PCO2FLUX -> PCO2FLUX
 PARG 153,159 // PCH4FLUX -> PCH4FLUX
 PARG 154,160 // PCFLXO -> PCFLXO
 PARG 155,161 // PDHTLS -> PDHTLS
 PARG 156,162 // PDHTSS -> PDHTSS
 PARG 157,163 // PDHTTS -> PDHTTS
 PARG 158,164 // PDHTIS -> PDHTIS
 PARG 159,165 // PDHCO2S -> PDHCO2S
 PARG 160,166 // PDHVEGS -> PDHVEGS
 PARG 161,167 // PCGPP -> PCGPP
 PARG 162,168 // PCREC -> PCREC
 ldr x9,[sp,#2960]
 str x9,[sp,#1240]
 CALL md2asm_vertical_diffusion_main_sea_r2_7358525
 // Subtract rates in complete original layer and row order.
 mov x21,#0
.Lvo_subtract_momentum_temperature_layer:
 mov x20,x23
.Lvo_subtract_momentum_temperature_row:
 madd x10,x21,x22,x20
 // PVOM
 FIELD_LOAD d0,127
 FIELD_LOAD d1,120
 fsub d0,d0,d1
 FIELD_STORE d0,127
 // PVOL
 FIELD_LOAD d0,128
 FIELD_LOAD d1,121
 fsub d0,d0,d1
 FIELD_STORE d0,128
 // PTE
 FIELD_LOAD d0,122
 FIELD_LOAD d1,115
 fsub d0,d0,d1
 FIELD_STORE d0,122
 add x20,x20,#1
 cmp x20,x24
 b.lt .Lvo_subtract_momentum_temperature_row
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lvo_subtract_momentum_temperature_layer
 // Subtract rates in complete original layer and row order.
 mov x21,#0
.Lvo_subtract_water_cloud_layer:
 mov x20,x23
.Lvo_subtract_water_cloud_row:
 madd x10,x21,x22,x20
 // PQE
 FIELD_LOAD d0,123
 FIELD_LOAD d1,116
 fsub d0,d0,d1
 FIELD_STORE d0,123
 // PLE
 FIELD_LOAD d0,124
 FIELD_LOAD d1,117
 fsub d0,d0,d1
 FIELD_STORE d0,124
 // PIE
 FIELD_LOAD d0,125
 FIELD_LOAD d1,118
 fsub d0,d0,d1
 FIELD_STORE d0,125
 // PAE
 FIELD_LOAD d0,126
 FIELD_LOAD d1,119
 fsub d0,d0,d1
 FIELD_STORE d0,126
 add x20,x20,#1
 cmp x20,x24
 b.lt .Lvo_subtract_water_cloud_row
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lvo_subtract_water_cloud_layer

 ldr w9,[sp,#2900]
 cbz w9,.Lvo_exit_hook_done
 adr x0,.Lvo_hook_name
 add x1,sp,#2904
 mov w9,#1
 str w9,[x1]
 add x2,sp,#2912
 mov x3,#8
 CALL __yomhook_MOD_dr_hook_default8
.Lvo_exit_hook_done:
 add x17,sp,#1280
 ldp x19,x20,[x17]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x25,x26,[x17,#48]
 ldp x27,x28,[x17,#64]
 ldp x29,x30,[x17,#80]
 ldp d8,d9,[x17,#96]
 ldp d10,d11,[x17,#112]
 ldp d12,d13,[x17,#128]
 ldp d14,d15,[x17,#144]
 ldr x18,[x17,#160]
 add sp,sp,#1,lsl #12
 ret
.Lvo_reject:
 brk #0x536
.size md2asm_vertical_diffusion_outer_sea_r2_7358525,.-md2asm_vertical_diffusion_outer_sea_r2_7358525
.section .rodata
.p2align 3
.Lvo_hook_name: .ascii "VDFOUTER"
.section .note.GNU-stack,"",%progbits

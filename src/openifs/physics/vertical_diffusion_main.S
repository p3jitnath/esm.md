/* Direct selected VDFMAIN body from OpenIFS 48.1.1.
 * Physics formulations/openifs/physics/vertical_diffusion_rates.md.
 * Contract skills/md2asm/references/openifs/physics/vertical_diffusion_rates.md.
 * Frozen numerical body and current private interfaces are preserved. */
.equ VM_CPTGZ,0
.equ VM_CFM,1
.equ VM_CFH,2
.equ VM_UDIF,3
.equ VM_VDIF,4
.equ VM_DTUTOFD,5
.equ VM_DTVTOFD,6
.equ VM_DTUSO,7
.equ VM_DTVSO,8
.equ VM_DTUVDF,9
.equ VM_DTVVDF,10
.equ VM_QTDIF,11
.equ VM_SLGDIF,12
.equ VM_SLGM1,13
.equ VM_QTM1,14
.equ VM_SLGSM1,15
.equ VM_SLGE,16
.equ VM_QTE,17
.equ VM_SLGEVDF,18
.equ VM_QTEVDF,19
.equ VM_TOFDC,20
.equ VM_KHFL,21
.equ VM_KQFL,22
.equ VM_KMFL,23
.equ VM_KHVFL,24
.equ VM_LIMIN,25
.equ VM_QTEA,26
.equ VM_SLGEA,27
.equ VM_SLGEWODIS,28
.equ VM_Z0MW,29
.equ VM_Z0HW,30
.equ VM_Z0QW,31
.equ VM_BLEND,32
.equ VM_FBLEND,33
.equ VM_CPTS,34
.equ VM_QSA,35
.equ VM_BUOM,36
.equ VM_ZDL,37
.equ VM_STRTOFDU,38
.equ VM_STRTOFDV,39
.equ VM_MFLX,40
.equ VM_SLGUH,41
.equ VM_QTUH,42
.equ VM_CLDBASE,43
.equ VM_UUH,44
.equ VM_VUH,45
.equ VM_EXTSHF,46
.equ VM_EXTLHF,47
.equ VM_WETB,48
.equ VM_WETL,49
.equ VM_WETLU,50
.equ VM_WETH,51
.equ VM_WETHS,52
.equ VM_RAQ,53
.equ VM_CPTSTI,54
.equ VM_QSTI,55
.equ VM_DQSTI,56
.equ VM_CSATTI,57
.equ VM_CAIRTI,58
.equ VM_CFHTI,59
.equ VM_CFQTI,60
.equ VM_AHFLTI,61
.equ VM_TSKTIP1,62
.equ VM_CPTSTIU,63
.equ VM_CSATTIU,64
.equ VM_CAIRTIU,65
.equ VM_EVAPUTI,66
.equ VM_TSKTIH,67
.equ VM_TSKTITE,68
.equ VM_TSKTITE1,69
.equ VM_EVAPUTI1,70
.equ VM_RAQTI,71
.equ VM_TSRF,72
.equ VM_LAMSK,73
.equ VM_G0,74
.equ VM_ATMCO2,75
.equ VM_IINV,76
.equ VM_ICBASE,77
.equ VM_ICTOP,78
.equ VM_LLAND,79
.equ VM_LLTEST,80
.equ VM_LLFIRST,81
.equ VM_DIFTQT,82
.equ VM_DIFTSLG,83
.equ VM_DTUTOFD1,84
.equ VM_DTVTOFD1,85
.equ VM_DTUSO1,86
.equ VM_DTVSO1,87
.equ VM_DTUVDF1,88
.equ VM_DTVVDF1,89
.equ VM_UM1S,90
.equ VM_VM1S,91
.equ VM_SLGM1S,92
.equ VM_QTM1S,93
.equ VM_SLGEVDF1,94
.equ VM_QTEVDF1,95
.equ VM_EVAPTI1,96
.equ VM_AHFSTI1,97
.equ VM_AHFLTI1,98
.equ VM_FLTRTI1,99
.equ VM_G01,100

// Direct selected VDFMAIN from vertical_diffusion_main_contract.md.
// Raw owners for diffusion children; exact descriptors for surface adapters.
.text
.p2align 4
.macro ARG reg,arg
 ldr \reg,[x19,#(\arg*8)]
.endm
.macro IN reg,arg
 ARG x9,\arg
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro OUT reg,arg
 ARG x9,\arg
 str \reg,[x9,x20,lsl #3]
.endm
.macro IN2 reg,arg,col=x21
 ARG x9,\arg
 madd x10,\col,x22,x20
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro OUT2 reg,arg,col=x21
 ARG x9,\arg
 madd x10,\col,x22,x20
 str \reg,[x9,x10,lsl #3]
.endm
.macro L reg,id
 ldr x9,[x27,#(\id*128)]
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro LS reg,id
 ldr x9,[x27,#(\id*128)]
 str \reg,[x9,x20,lsl #3]
.endm
.macro L2 reg,id,col=x21
 ldr x9,[x27,#(\id*128)]
 madd x10,\col,x22,x20
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro LS2 reg,id,col=x21
 ldr x9,[x27,#(\id*128)]
 madd x10,\col,x22,x20
 str \reg,[x9,x10,lsl #3]
.endm
.macro LI reg,id
 ldr x9,[x27,#(\id*128)]
 ldr \reg,[x9,x20,lsl #2]
.endm
.macro LIS reg,id
 ldr x9,[x27,#(\id*128)]
 str \reg,[x9,x20,lsl #2]
.endm
.macro CONST reg,name
 adr x9,.Lvm_\name
 ldr \reg,[x9]
.endm
.macro GLOBAL reg,module,name
 adrp x9,:got:__\module\()_MOD_\name
 ldr x9,[x9,:got_lo12:__\module\()_MOD_\name]
 ldr \reg,[x9]
.endm
.macro MODEL_ADDR reg,offset
 mov x16,#(\offset & 65535)
 movk x16,#(\offset >> 16),lsl #16
 add \reg,x25,x16
.endm
.macro MODEL_F reg,offset
 MODEL_ADDR x9,\offset
 ldr \reg,[x9]
.endm
.macro CALL name
 str x18,[sp,#3056]
 bl \name
 ldr x18,[sp,#3056]
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
.macro DARG dest,arg
 mov x9,#(\arg*128)
 add x9,x26,x9
 PLACE \dest
.endm
.macro LDARG dest,id
 mov x9,#(\id*128)
 add x9,x27,x9
 PLACE \dest
.endm
.macro RARG dest,id
 ldr x9,[x27,#(\id*128)]
 PLACE \dest
.endm
.macro MARG dest,offset
 MODEL_ADDR x9,\offset
 PLACE \dest
.endm
.macro GARG dest,module,name
 adrp x9,:got:__\module\()_MOD_\name
 ldr x9,[x9,:got_lo12:__\module\()_MOD_\name]
 PLACE \dest
.endm
.macro SARG dest,offset
 add x9,sp,#\offset
 PLACE \dest
.endm
.macro VIEW_BODY dest,slot
 add x13,sp,#4096
 add x13,x13,#(\slot*64)
 str x9,[x13]
 mov x10,#-1
 str x10,[x13,#8]
 mov x10,#8
 str x10,[x13,#16]
 str x10,[x13,#32]
 movz x10,#0x0301,lsl #32
 str x10,[x13,#24]
 mov x10,#1
 str x10,[x13,#40]
 str x10,[x13,#48]
 str x22,[x13,#56]
 mov x9,x13
 PLACE \dest
.endm
.macro RAWVIEW dest,arg,slot,col
 ARG x9,\arg
 mul x10,\col,x22
 add x9,x9,x10,lsl #3
 VIEW_BODY \dest,\slot
.endm
.macro LVIEW dest,id,slot,col
 ldr x9,[x27,#(\id*128)]
 mul x10,\col,x22
 add x9,x9,x10,lsl #3
 VIEW_BODY \dest,\slot
.endm
.macro ROWS label
 mov x20,x23
\label:
.endm
.macro NEXT label
 add x20,x20,#1
 cmp x20,x24
 b.lt \label
.endm
.global md2asm_vertical_diffusion_main_sea_r2_7358525
.type md2asm_vertical_diffusion_main_sea_r2_7358525,%function
md2asm_vertical_diffusion_main_sea_r2_7358525:
 mov x16,sp
 sub sp,sp,#12,lsl #12
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
.Lvm_arguments:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#163
 b.lt .Lvm_arguments
 ldr x9,[x16]
 str x9,[sp,#2960]
 cmp x9,#1
 b.ne .Lvm_reject
 mrs x9,fpcr
 cbnz x9,.Lvm_reject
 ARG x25,0
 ARG x9,4
 ldr w22,[x9]
 cmp w22,#1
 b.lt .Lvm_reject
 cmp w22,#4096
 b.gt .Lvm_reject
 ARG x9,5
 ldr w28,[x9]
 cmp w28,#3
 b.lt .Lvm_reject
 cmp w28,#512
 b.gt .Lvm_reject
 ARG x9,2
 ldrsw x23,[x9]
 sub x23,x23,#1
 cmp x23,#0
 b.lt .Lvm_reject
 ARG x9,3
 ldrsw x24,[x9]
 cmp x24,x22
 b.gt .Lvm_reject
 cmp x24,x23
 b.le .Lvm_return
 ARG x9,6
 ldr w9,[x9]
 cmp w9,#4
 b.ne .Lvm_reject
 ARG x9,8
 ldr w9,[x9]
 cmp w9,#9
 b.ne .Lvm_reject
 // Actual caller selections remain unqualified until complete capture.
 MODEL_ADDR x9,1578180
 ldr w9,[x9]
 cbnz w9,.Lvm_reject
 MODEL_ADDR x9,1552928
 ldr w9,[x9]
 cbnz w9,.Lvm_reject
 MODEL_ADDR x9,1578020
 ldr w9,[x9]
 cbz w9,.Lvm_no_tracer_route
 ARG x9,11
 ldr w9,[x9]
 cbnz w9,.Lvm_reject
.Lvm_no_tracer_route:
 add x26,sp,#2,lsl #12
 add x27,sp,#8,lsl #12
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lvm_reject
 str w9,[sp,#2900]
 cbz w9,.Lvm_entry_hook_done
 adr x0,.Lvm_hook_name
 add x1,sp,#2904
 str wzr,[x1]
 add x2,sp,#2912
 mov x3,#7
 CALL __yomhook_MOD_dr_hook_default8
.Lvm_entry_hook_done:
 // Public raw-array descriptors are prepared by an integer metadata loop.
 mov x21,#0
.Lvm_public_descriptors:
 adr x9,.Lvm_public_specs
 mov x10,#24
 madd x9,x21,x10,x9
 ldp w10,w11,[x9]
 cbz w10,.Lvm_next_public_descriptor
 add x13,x26,x21,lsl #7
 ldr x12,[x19,x21,lsl #3]
 str x12,[x13]
 mov x12,#8
 cmp w11,#3
 mov x14,#4
 csel x12,x12,x14,eq
 str x12,[x13,#16]
 str x12,[x13,#32]
 lsl x12,x11,#8
 orr x12,x12,x10
 lsl x12,x12,#32
 str x12,[x13,#24]
 mov x12,#1
 str x12,[x13,#40]
 str x12,[x13,#48]
 str x22,[x13,#56]
 mov x12,#-1
 cmp w10,#1
 b.eq .Lvm_public_descriptor_bias
 str x22,[x13,#64]
 mov x14,#1
 str x14,[x13,#72]
 ldr w14,[x9,#8]
 ldr w15,[x9,#12]
 // Positive spec values name scalar arguments; negative values are lengths.
 cmp w14,#0
 b.lt .Lvm_public_fixed_second
 ldr x16,[x19,x14,lsl #3]
 ldrsw x14,[x16]
 cmp w15,#0
 b.lt .Lvm_public_second_ready
 ldr x16,[x19,x15,lsl #3]
 ldrsw x15,[x16]
 add x14,x14,x15
 b .Lvm_public_second_ready
.Lvm_public_fixed_second:
 neg w14,w14
.Lvm_public_second_ready:
 // A negative supplementary spec means a positive length increment.
 ldr w15,[x9,#12]
 cmp w15,#-1
 b.ge .Lvm_public_no_increment
 neg w15,w15
 sub w15,w15,#1
 add x14,x14,x15
.Lvm_public_no_increment:
 str x14,[x13,#80]
 sub x12,x12,x22
 cmp w10,#2
 b.eq .Lvm_public_descriptor_bias
 mul x16,x22,x14
 str x16,[x13,#88]
 mov x14,#1
 str x14,[x13,#96]
 ldr w14,[x9,#16]
 cmp w14,#0
 b.lt .Lvm_public_fixed_third
 ldr x15,[x19,x14,lsl #3]
 ldrsw x14,[x15]
 ldr w15,[x9,#20]
 cmp w15,#0
 b.lt .Lvm_public_third_ready
 ldr x17,[x19,x15,lsl #3]
 ldrsw x15,[x17]
 add x14,x14,x15
 b .Lvm_public_third_ready
.Lvm_public_fixed_third:
 neg w14,w14
.Lvm_public_third_ready:
 str x14,[x13,#104]
 sub x12,x12,x16
.Lvm_public_descriptor_bias:
 str x12,[x13,#8]
.Lvm_next_public_descriptor:
 add x21,x21,#1
 cmp x21,#163
 b.lt .Lvm_public_descriptors
 // Allocate the complete private array data in one memory-only operation.
 mov x0,x22
 adr x1,.Lvm_local_specs
 mov x21,#0
 mov x10,#0
.Lvm_local_size:
 add x9,x1,x21,lsl #3
 ldr w9,[x9]
 cmp w9,#0
 b.eq .Lvm_local_size_cells
 cmp w9,#-1
 b.eq .Lvm_local_size_interfaces
 b .Lvm_local_size_add
.Lvm_local_size_cells:
 mov x9,x28
 b .Lvm_local_size_add
.Lvm_local_size_interfaces:
 add x9,x28,#1
.Lvm_local_size_add:
 add x10,x10,x9
 add x21,x21,#1
 cmp x21,#101
 b.lt .Lvm_local_size
 lsl x1,x10,#3
 CALL calloc
 cbz x0,.Lvm_reject
 str x0,[sp,#3072]
 mov x20,x0
 mov x21,#0
.Lvm_local_descriptors:
 adr x9,.Lvm_local_specs
 add x9,x9,x21,lsl #3
 ldp w10,w11,[x9]
 cmp w10,#0
 b.eq .Lvm_local_cells
 cmp w10,#-1
 b.eq .Lvm_local_interfaces
 b .Lvm_local_length_ready
.Lvm_local_cells:
 mov x10,x28
 b .Lvm_local_length_ready
.Lvm_local_interfaces:
 add x10,x28,#1
.Lvm_local_length_ready:
 add x13,x27,x21,lsl #7
 str x20,[x13]
 mov x12,#8
 cmp w11,#3
 mov x14,#4
 csel x12,x12,x14,eq
 str x12,[x13,#16]
 str x12,[x13,#32]
 cmp x10,#1
 mov x14,#1
 mov x15,#2
 csel x14,x14,x15,eq
 lsl x12,x11,#8
 orr x12,x12,x14
 lsl x12,x12,#32
 str x12,[x13,#24]
 mov x12,#1
 str x12,[x13,#40]
 str x12,[x13,#48]
 str x22,[x13,#56]
 mov x12,#-1
 cmp x10,#1
 b.eq .Lvm_local_bias
 str x22,[x13,#64]
 mov x14,#1
 str x14,[x13,#72]
 str x10,[x13,#80]
 sub x12,x12,x22
.Lvm_local_bias:
 str x12,[x13,#8]
 mul x10,x10,x22
 add x20,x20,x10,lsl #3
 add x21,x21,#1
 cmp x21,#101
 b.lt .Lvm_local_descriptors
 CONST d0,one
 ARG x9,28
 ldr d1,[x9]
 fdiv d0,d0,d1
 str d0,[sp,#2920]
 CONST d0,one
 GLOBAL d1,yomcst,rg
 fdiv d0,d0,d1
 str d0,[sp,#2928]
 mov w9,#1
 str w9,[sp,#2944]
 // Carbon fields are cleared over each requested row and complete declared planes.
 mov x9,#(132*128)
 add x9,x26,x9
 bl .Lvm_zero_public_selected
 mov x9,#(133*128)
 add x9,x26,x9
 bl .Lvm_zero_public_selected
 mov x9,#(160*128)
 add x9,x26,x9
 bl .Lvm_zero_public_selected
 mov x9,#(159*128)
 add x9,x26,x9
 bl .Lvm_zero_public_selected
 ROWS .Lvm_carbon_zero_row
 fmov d0,xzr
 OUT d0,147
 OUT d0,148
 OUT d0,149
 OUT d0,150
 OUT d0,151
 OUT d0,152
 OUT d0,153
 NEXT .Lvm_carbon_zero_row
 // Preserve the single-column model's fixed-flux switch and values.
 GLOBAL w9,yommp0,lscmec
 cbz w9,.Lvm_scm_disabled
 GLOBAL w9,yomct0,lsfcflx
 str w9,[sp,#2952]
 mov x20,#0
.Lvm_scm_flux_row:
 GLOBAL d0,yomct0,rextshf
 LS d0,46
 GLOBAL d0,yomct0,rextlhf
 LS d0,47
 add x20,x20,#1
 cmp x20,x22
 b.lt .Lvm_scm_flux_row
 b .Lvm_scm_done
.Lvm_scm_disabled:
 str wzr,[sp,#2952]
 // The memory-only calloc already supplied both complete positive-zero vectors.
.Lvm_scm_done:
 mov x21,#0
.Lvm_static_energy_layer:
 ROWS .Lvm_static_energy_row
 IN2 d0,44
 GLOBAL d1,yomcst,rcpd
 fmul d0,d0,d1
 IN2 d1,45
 GLOBAL d2,yoethf,rvtmp2
 fmul d1,d2,d1
 CONST d2,one
 fadd d1,d2,d1
 fmul d0,d0,d1
 IN2 d1,53
 fadd d0,d1,d0
 LS2 d0,VM_CPTGZ
 NEXT .Lvm_static_energy_row
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lvm_static_energy_layer
 // Coupled CO2 is outside the guarded scope; constant RCARDI owns the complete vector.
 MODEL_F d0,1856416
 mov x20,#0
.Lvm_constant_co2_row:
 LS d0,VM_ATMCO2
 add x20,x20,#1
 cmp x20,x22
 b.lt .Lvm_constant_co2_row
 // The complete 131-address surface adapter. Cell and interface last columns differ.
 sub x21,x28,#1
 MARG 0,1578328
 PARG 1,1
 PARG 2,2
 PARG 3,3
 PARG 4,4
 PARG 5,6
 PARG 6,8
 PARG 7,9
 PARG 8,10
 PARG 9,7
 PARG 10,14
 PARG 11,15
 PARG 12,16
 PARG 13,17
 PARG 14,18
 PARG 15,19
 PARG 16,20
 PARG 17,21
 PARG 18,22
 PARG 19,23
 GARG 20,yomjfh,n_vmass
 PARG 21,24
 PARG 22,25
 PARG 23,26
 PARG 24,27
 PARG 25,28
 MARG 26,1359528
 DARG 27,29
 DARG 28,30
 DARG 29,31
 DARG 30,32
 DARG 31,33
 DARG 32,34
 DARG 33,36
 DARG 34,37
 DARG 35,35
 DARG 36,55
 DARG 37,38
 DARG 38,39
 DARG 39,40
 MARG 40,1856416
 RAWVIEW 41,42,0,x21
 RAWVIEW 42,43,1,x21
 RAWVIEW 43,44,2,x21
 RAWVIEW 44,45,3,x21
 LDARG 45,VM_ATMCO2
 RAWVIEW 46,51,4,x28
 RAWVIEW 47,53,5,x21
 LVIEW 48,VM_CPTGZ,6,x21
 DARG 49,69
 DARG 50,56
 DARG 51,74
 DARG 52,75
 DARG 53,59
 DARG 54,60
 DARG 55,61
 DARG 56,65
 DARG 57,64
 DARG 58,66
 DARG 59,67
 DARG 60,68
 DARG 61,86
 DARG 62,87
 DARG 63,73
 DARG 64,76
 DARG 65,77
 DARG 66,114
 DARG 67,57
 DARG 68,58
 DARG 69,70
 DARG 70,71
 DARG 71,72
 DARG 72,126
 DARG 73,127
 DARG 74,128
 DARG 75,129
 DARG 76,130
 DARG 77,132
 DARG 78,133
 DARG 79,90
 DARG 80,91
 DARG 81,109
 LDARG 82,VM_QSTI
 LDARG 83,VM_DQSTI
 LDARG 84,VM_CPTSTI
 LDARG 85,VM_CFHTI
 LDARG 86,VM_CFQTI
 LDARG 87,VM_CSATTI
 LDARG 88,VM_CAIRTI
 LDARG 89,VM_CPTSTIU
 LDARG 90,VM_CSATTIU
 LDARG 91,VM_CAIRTIU
 LDARG 92,VM_RAQTI
 LDARG 93,VM_TSRF
 LDARG 94,VM_LAMSK
 RAWVIEW 95,144,7,x21
 LDARG 96,VM_RAQ
 LVIEW 97,VM_CFM,8,x21
 LDARG 98,VM_KMFL
 LDARG 99,VM_KHFL
 LDARG 100,VM_KQFL
 DARG 101,110
 LDARG 102,VM_Z0MW
 LDARG 103,VM_Z0HW
 LDARG 104,VM_Z0QW
 LDARG 105,VM_BLEND
 LDARG 106,VM_CPTS
 LDARG 107,VM_QSA
 LDARG 108,VM_BUOM
 LDARG 109,VM_ZDL
 DARG 110,147
 DARG 111,148
 DARG 112,149
 DARG 113,150
 DARG 114,151
 DARG 115,152
 DARG 116,153
 LDARG 117,VM_WETB
 LDARG 118,VM_WETL
 LDARG 119,VM_WETLU
 LDARG 120,VM_WETH
 LDARG 121,VM_WETHS
 DARG 122,155
 DARG 123,156
 DARG 124,157
 DARG 125,158
 DARG 126,160
 DARG 127,112
 DARG 128,159
 GARG 129,yomdyncore,rplrg
 PARG 130,89
 ldr x9,[sp,#2960]
 str x9,[sp,#984]
 CALL md2asm_surface_exchange_adapter_sea_r2_7358525
 // Complete static-energy and total-water preparation from incoming rates.
 mov x21,#0
.Lvm_thermodynamic_layer:
 ROWS .Lvm_thermodynamic_row
 L2 d0,VM_CPTGZ
 IN2 d1,46
 GLOBAL d2,yomcst,rlvtt
 fmul d1,d2,d1
 fsub d0,d0,d1
 LS2 d0,VM_SLGM1
 IN2 d0,45
 GLOBAL d1,yoethf,rvtmp2
 fmul d0,d1,d0
 CONST d2,one
 fadd d0,d2,d0
 IN2 d2,116
 fmul d0,d0,d2
 IN2 d2,44
 fmul d1,d1,d2
 IN2 d2,117
 fmul d1,d1,d2
 fadd d0,d0,d1
 GLOBAL d1,yomcst,rcpd
 fmul d0,d1,d0
 IN2 d1,118
 GLOBAL d2,yomcst,rlvtt
 fmul d1,d2,d1
 fsub d0,d0,d1
 LS2 d0,VM_SLGE
 LS2 d0,VM_SLGEA
 IN2 d0,45
 IN2 d1,46
 fadd d0,d0,d1
 LS2 d0,VM_QTM1
 GLOBAL d1,yomcst,rcpd
 IN2 d2,44
 fmul d1,d1,d2
 CONST d2,virtual_water_factor
 fmul d1,d1,d2
 fmul d1,d1,d0
 L2 d0,VM_SLGM1
 fadd d0,d0,d1
 LS2 d0,VM_SLGSM1
 IN2 d0,117
 IN2 d1,118
 fadd d0,d0,d1
 LS2 d0,VM_QTE
 LS2 d0,VM_QTEA
 NEXT .Lvm_thermodynamic_row
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lvm_thermodynamic_layer
 // Optional prescribed sensible and latent surface-flux boundary.
 ldr w9,[sp,#2952]
 cbz w9,.Lvm_fixed_surface_flux_done
 sub x21,x28,#1
 ROWS .Lvm_fixed_surface_flux_row
 IN2 d0,44
 GLOBAL d1,yomcst,rd
 fmul d0,d1,d0
 IN2 d1,45
 GLOBAL d2,yomcst,retv
 fmul d1,d2,d1
 CONST d2,one
 fadd d1,d2,d1
 fmul d0,d0,d1
 IN2 d1,51,x28
 fdiv d3,d1,d0
 IN2 d0,45
 GLOBAL d1,yoethf,rvtmp2
 fmul d0,d1,d0
 CONST d1,one
 fadd d0,d1,d0
 GLOBAL d1,yomcst,rcpd
 fmul d0,d1,d0
 L d1,VM_EXTSHF
 fdiv d0,d1,d0
 fdiv d0,d0,d3
 LS d0,VM_KHFL
 L d0,VM_EXTLHF
 GLOBAL d1,yomcst,rlvtt
 fdiv d0,d0,d1
 fdiv d0,d0,d3
 LS d0,VM_KQFL
 NEXT .Lvm_fixed_surface_flux_row
.Lvm_fixed_surface_flux_done:
 MARG 0,1577888
 PARG 1,2
 PARG 2,3
 PARG 3,4
 PARG 4,5
 PARG 5,42
 PARG 6,43
 PARG 7,44
 PARG 8,45
 PARG 9,53
 RARG 10,VM_KMFL
 RARG 11,VM_KHFL
 RARG 12,VM_KQFL
 PARG 13,104
 CALL md2asm_vdfdpbl_7240564
 ROWS .Lvm_land_classification
 mov x21,#0
 IN2 d0,71
 mov x21,#1
 IN2 d1,71
 fadd d0,d0,d1
 CONST d1,half
 fcmp d0,d1
 cset w11,le
 LIS w11,VM_LLAND
 NEXT .Lvm_land_classification
 MARG 0,1588296
 MARG 1,1578600
 MARG 2,1581392
 MARG 3,1577816
 MARG 4,1552928
 PARG 5,2
 PARG 6,3
 PARG 7,4
 PARG 8,5
 PARG 9,28
 RARG 10,VM_LLAND
 PARG 11,44
 PARG 12,45
 RARG 13,VM_SLGSM1
 PARG 14,42
 PARG 15,43
 RARG 16,VM_CPTGZ
 PARG 17,51
 PARG 18,52
 PARG 19,53
 PARG 20,54
 PARG 21,104
 RARG 22,VM_KMFL
 RARG 23,VM_KHFL
 RARG 24,VM_KQFL
 PARG 25,88
 RARG 26,VM_KHVFL
 RARG 27,VM_MFLX
 RARG 28,VM_SLGUH
 RARG 29,VM_QTUH
 RARG 30,VM_UUH
 RARG 31,VM_VUH
 PARG 32,103
 RARG 33,VM_IINV
 RARG 34,VM_ICBASE
 RARG 35,VM_ICTOP
 RARG 36,VM_CLDBASE
 PARG 37,146
 PARG 38,105
 PARG 39,115
 CALL md2asm_vdfhghtn_7240564
 // Both original cloud/fog passes remain, with the source tie conditions.
 bl .Lvm_cloud_fog_correction
 bl .Lvm_cloud_fog_correction
 MARG 0,1588032
 MARG 1,1577888
 MARG 2,1552928
 PARG 3,2
 PARG 4,3
 PARG 5,4
 PARG 6,5
 RARG 7,VM_IINV
 RARG 8,VM_ICBASE
 RARG 9,VM_ICTOP
 MARG 10,1577816
 PARG 11,90
 PARG 12,62
 PARG 13,63
 PARG 14,42
 PARG 15,43
 PARG 16,44
 PARG 17,45
 PARG 18,51
 PARG 19,53
 PARG 20,54
 PARG 21,55
 RARG 22,VM_CPTGZ
 RARG 23,VM_KMFL
 RARG 24,VM_KHFL
 RARG 25,VM_KQFL
 RARG 26,VM_KHVFL
 PARG 27,88
 RARG 28,VM_CFM
 RARG 29,VM_CFH
 PARG 30,103
 PARG 31,144
 PARG 32,145
 PARG 33,146
 RARG 34,VM_CLDBASE
 PARG 35,115
 CALL md2asm_vdfexcu_7240564
 // The original whole-array turbulence-rate clear is not restricted to active rows.
 ARG x9,123
 mul x10,x22,x28
 mov x11,#0
.Lvm_turbulence_rate_clear:
 str xzr,[x9,x11,lsl #3]
 add x11,x11,#1
 cmp x11,x10
 b.lt .Lvm_turbulence_rate_clear
 ROWS .Lvm_thin_plume_row
 sub x21,x28,#2
 L2 d0,VM_MFLX
 CONST d1,epsilon100
 fcmp d0,d1
 b.ge .Lvm_thin_plume_next
 sub x21,x28,#1
 fmov d0,xzr
 LS2 d0,VM_MFLX
.Lvm_thin_plume_next:
 NEXT .Lvm_thin_plume_row
 MARG 0,1577816
 PARG 1,2
 PARG 2,3
 PARG 3,4
 PARG 4,5
 PARG 5,42
 PARG 6,43
 PARG 7,53
 PARG 8,41
 RARG 9,VM_TOFDC
 CALL md2asm_vdftofdc_7240564
 MODEL_ADDR x9,1577832
 ldr w9,[x9]
 cbz w9,.Lvm_overimplicit
 // Predictor-corrector coefficients retain their original subtraction order.
 MODEL_F d0,1577840
 MODEL_F d1,1577856
 fdiv d0,d0,d1
 str d0,[sp,#2976]
 CONST d1,one
 fsub d0,d1,d0
 str d0,[sp,#2984]
 MODEL_F d0,1577856
 ARG x9,28
 ldr d1,[x9]
 fmul d0,d1,d0
 str d0,[sp,#2936]
 PARG 0,2
 PARG 1,3
 PARG 2,4
 PARG 3,5
 SARG 4,2944
 SARG 5,2936
 PARG 6,42
 PARG 7,43
 PARG 8,51
 RARG 9,VM_CFM
 RARG 10,VM_TOFDC
 PARG 11,83
 PARG 12,84
 PARG 13,85
 PARG 14,121
 PARG 15,122
 PARG 16,76
 PARG 17,77
 RARG 18,VM_MFLX
 RARG 19,VM_UUH
 RARG 20,VM_VUH
 RARG 21,VM_UDIF
 RARG 22,VM_VDIF
 RARG 23,VM_DTUTOFD1
 RARG 24,VM_DTVTOFD1
 RARG 25,VM_DTUSO1
 RARG 26,VM_DTVSO1
 RARG 27,VM_DTUVDF1
 RARG 28,VM_DTVVDF1
 CALL md2asm_vdfdifm_7240564
 mov x21,#0
.Lvm_momentum_star_layer:
 ROWS .Lvm_momentum_star_row
 ldr d2,[sp,#2984]
 ldr d3,[sp,#2976]
 L2 d0,VM_UDIF
 fmul d0,d2,d0
 IN2 d1,42
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_UM1S
 L2 d0,VM_VDIF
 fmul d0,d2,d0
 IN2 d1,43
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_VM1S
 NEXT .Lvm_momentum_star_row
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lvm_momentum_star_layer
 PARG 0,2
 PARG 1,3
 PARG 2,4
 PARG 3,5
 SARG 4,2944
 SARG 5,2936
 RARG 6,VM_UM1S
 RARG 7,VM_VM1S
 PARG 8,51
 RARG 9,VM_CFM
 RARG 10,VM_TOFDC
 PARG 11,83
 PARG 12,84
 PARG 13,85
 PARG 14,121
 PARG 15,122
 PARG 16,76
 PARG 17,77
 RARG 18,VM_MFLX
 RARG 19,VM_UUH
 RARG 20,VM_VUH
 RARG 21,VM_UDIF
 RARG 22,VM_VDIF
 RARG 23,VM_DTUTOFD
 RARG 24,VM_DTVTOFD
 RARG 25,VM_DTUSO
 RARG 26,VM_DTVSO
 RARG 27,VM_DTUVDF
 RARG 28,VM_DTVVDF
 CALL md2asm_vdfdifm_7240564
 MODEL_F d0,1577856
 MODEL_F d1,1577840
 fsub d0,d0,d1
 str d0,[sp,#2992]
 MODEL_F d0,1577856
 MODEL_F d1,1577848
 fsub d0,d0,d1
 str d0,[sp,#3000]
 mov x21,#0
.Lvm_momentum_rate_blend_layer:
 ROWS .Lvm_momentum_rate_blend_row
 ldr d2,[sp,#2992]
 ldr d3,[sp,#3000]
 L2 d0,VM_DTUTOFD1
 fmul d0,d2,d0
 L2 d1,VM_DTUTOFD
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_DTUTOFD
 L2 d0,VM_DTVTOFD1
 fmul d0,d2,d0
 L2 d1,VM_DTVTOFD
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_DTVTOFD
 L2 d0,VM_DTUSO1
 fmul d0,d2,d0
 L2 d1,VM_DTUSO
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_DTUSO
 L2 d0,VM_DTVSO1
 fmul d0,d2,d0
 L2 d1,VM_DTVSO
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_DTVSO
 L2 d0,VM_DTUVDF1
 fmul d0,d2,d0
 L2 d1,VM_DTUVDF
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_DTUVDF
 L2 d0,VM_DTVVDF1
 fmul d0,d2,d0
 L2 d1,VM_DTVVDF
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_DTVVDF
 NEXT .Lvm_momentum_rate_blend_row
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lvm_momentum_rate_blend_layer
 MARG 0,1556120
 MARG 1,1577888
 MARG 2,1359328
 PARG 3,2
 PARG 4,3
 PARG 5,4
 PARG 6,5
 SARG 7,2944
 PARG 8,8
 PARG 9,29
 PARG 10,31
 SARG 11,2936
 RARG 12,VM_EXTSHF
 RARG 13,VM_EXTLHF
 SARG 14,2952
 PARG 15,71
 PARG 16,109
 PARG 17,60
 PARG 18,61
 PARG 19,110
 PARG 20,66
 PARG 21,67
 PARG 22,68
 RARG 23,VM_SLGM1
 RARG 24,VM_QTM1
 PARG 25,51
 RARG 26,VM_CFH
 RARG 27,VM_CFHTI
 RARG 28,VM_CFQTI
 RARG 29,VM_MFLX
 RARG 30,VM_SLGUH
 RARG 31,VM_QTUH
 RARG 32,VM_SLGDIF
 RARG 33,VM_QTDIF
 RARG 34,VM_CPTSTI
 RARG 35,VM_QSTI
 RARG 36,VM_CAIRTI
 RARG 37,VM_CSATTI
 RARG 38,VM_CPTSTIU
 RARG 39,VM_CAIRTIU
 RARG 40,VM_CSATTIU
 RARG 41,VM_TSRF
 RARG 42,VM_LAMSK
 RARG 43,VM_DQSTI
 PARG 44,130
 PARG 45,80
 PARG 46,57
 PARG 47,64
 PARG 48,38
 PARG 49,39
 PARG 50,65
 PARG 51,69
 PARG 52,86
 PARG 53,87
 RARG 54,VM_TSKTIH
 RARG 55,VM_SLGE
 RARG 56,VM_QTE
 RARG 57,VM_SLGEVDF1
 RARG 58,VM_QTEVDF1
 RARG 59,VM_TSKTITE1
 RARG 60,VM_EVAPTI1
 RARG 61,VM_AHFSTI1
 RARG 62,VM_AHFLTI1
 RARG 63,VM_FLTRTI1
 RARG 64,VM_G01
 RARG 65,VM_EVAPUTI1
 CALL md2asm_vdfdifh_7240564
 mov x21,#0
.Lvm_heat_star_layer:
 ROWS .Lvm_heat_star_row
 ldr d2,[sp,#2984]
 ldr d3,[sp,#2976]
 L2 d0,VM_SLGDIF
 fmul d0,d2,d0
 L2 d1,VM_SLGM1
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_SLGM1S
 L2 d0,VM_QTDIF
 fmul d0,d2,d0
 L2 d1,VM_QTM1
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_QTM1S
 NEXT .Lvm_heat_star_row
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lvm_heat_star_layer
 MARG 0,1556120
 MARG 1,1577888
 MARG 2,1359328
 PARG 3,2
 PARG 4,3
 PARG 5,4
 PARG 6,5
 SARG 7,2944
 PARG 8,8
 PARG 9,29
 PARG 10,31
 SARG 11,2936
 RARG 12,VM_EXTSHF
 RARG 13,VM_EXTLHF
 SARG 14,2952
 PARG 15,71
 PARG 16,109
 PARG 17,60
 PARG 18,61
 PARG 19,110
 PARG 20,66
 PARG 21,67
 PARG 22,68
 RARG 23,VM_SLGM1S
 RARG 24,VM_QTM1S
 PARG 25,51
 RARG 26,VM_CFH
 RARG 27,VM_CFHTI
 RARG 28,VM_CFQTI
 RARG 29,VM_MFLX
 RARG 30,VM_SLGUH
 RARG 31,VM_QTUH
 RARG 32,VM_SLGDIF
 RARG 33,VM_QTDIF
 RARG 34,VM_CPTSTI
 RARG 35,VM_QSTI
 RARG 36,VM_CAIRTI
 RARG 37,VM_CSATTI
 RARG 38,VM_CPTSTIU
 RARG 39,VM_CAIRTIU
 RARG 40,VM_CSATTIU
 RARG 41,VM_TSRF
 RARG 42,VM_LAMSK
 RARG 43,VM_DQSTI
 PARG 44,130
 PARG 45,80
 PARG 46,57
 PARG 47,64
 PARG 48,38
 PARG 49,39
 PARG 50,65
 PARG 51,69
 PARG 52,86
 PARG 53,87
 RARG 54,VM_TSKTIH
 RARG 55,VM_SLGE
 RARG 56,VM_QTE
 RARG 57,VM_SLGEVDF
 RARG 58,VM_QTEVDF
 RARG 59,VM_TSKTITE
 PARG 60,129
 PARG 61,128
 RARG 62,VM_AHFLTI
 PARG 63,131
 RARG 64,VM_G0
 RARG 65,VM_EVAPUTI
 CALL md2asm_vdfdifh_7240564
 MODEL_F d0,1577856
 MODEL_F d1,1577840
 fsub d0,d0,d1
 str d0,[sp,#2992]
 MODEL_F d0,1577856
 MODEL_F d1,1577848
 fsub d0,d0,d1
 str d0,[sp,#3000]
 mov x21,#0
.Lvm_heat_rate_blend_layer:
 ROWS .Lvm_heat_rate_blend_row
 ldr d2,[sp,#2992]
 ldr d3,[sp,#3000]
 L2 d0,VM_SLGEVDF1
 fmul d0,d2,d0
 L2 d1,VM_SLGEVDF
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_SLGEVDF
 L2 d0,VM_QTEVDF1
 fmul d0,d2,d0
 L2 d1,VM_QTEVDF
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_QTEVDF
 NEXT .Lvm_heat_rate_blend_row
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lvm_heat_rate_blend_layer
 mov x21,#0
.Lvm_skin_rate_blend_tile:
 ROWS .Lvm_skin_rate_blend_row
 L2 d0,VM_TSKTITE1
 ldr d2,[sp,#2992]
 fmul d0,d2,d0
 L2 d1,VM_TSKTITE
 ldr d3,[sp,#3000]
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_TSKTITE
 ARG x9,28
 ldr d1,[x9]
 fmul d0,d0,d1
 IN2 d1,130
 fadd d0,d1,d0
 LS2 d0,VM_TSKTIP1
 NEXT .Lvm_skin_rate_blend_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lvm_skin_rate_blend_tile
 mov x21,#0
.Lvm_tile_flux_blend_tile:
 ROWS .Lvm_tile_flux_blend_row
 ldr d2,[sp,#2992]
 ldr d3,[sp,#3000]
 L2 d0,VM_EVAPTI1
 fmul d0,d2,d0
 IN2 d1,129
 fmul d1,d3,d1
 fadd d0,d0,d1
 OUT2 d0,129
 L2 d0,VM_AHFSTI1
 fmul d0,d2,d0
 IN2 d1,128
 fmul d1,d3,d1
 fadd d0,d0,d1
 OUT2 d0,128
 L2 d0,VM_AHFLTI1
 fmul d0,d2,d0
 L2 d1,VM_AHFLTI
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_AHFLTI
 L2 d0,VM_FLTRTI1
 fmul d0,d2,d0
 IN2 d1,131
 fmul d1,d3,d1
 fadd d0,d0,d1
 OUT2 d0,131
 L2 d0,VM_G01
 fmul d0,d2,d0
 L2 d1,VM_G0
 fmul d1,d3,d1
 fadd d0,d0,d1
 LS2 d0,VM_G0
 NEXT .Lvm_tile_flux_blend_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lvm_tile_flux_blend_tile
 mov x21,#3
 ROWS .Lvm_potential_evaporation_blend
 L2 d0,VM_EVAPUTI1
 ldr d2,[sp,#2992]
 fmul d0,d2,d0
 L2 d1,VM_EVAPUTI
 ldr d2,[sp,#3000]
 fmul d1,d2,d1
 fadd d0,d0,d1
 OUT d0,111
 NEXT .Lvm_potential_evaporation_blend
 b .Lvm_diffusion_done
.Lvm_overimplicit:
 MODEL_F d0,1577824
 ARG x9,28
 ldr d1,[x9]
 fmul d0,d1,d0
 str d0,[sp,#2936]
 PARG 0,2
 PARG 1,3
 PARG 2,4
 PARG 3,5
 SARG 4,2944
 SARG 5,2936
 PARG 6,42
 PARG 7,43
 PARG 8,51
 RARG 9,VM_CFM
 RARG 10,VM_TOFDC
 PARG 11,83
 PARG 12,84
 PARG 13,85
 PARG 14,121
 PARG 15,122
 PARG 16,76
 PARG 17,77
 RARG 18,VM_MFLX
 RARG 19,VM_UUH
 RARG 20,VM_VUH
 RARG 21,VM_UDIF
 RARG 22,VM_VDIF
 RARG 23,VM_DTUTOFD
 RARG 24,VM_DTVTOFD
 RARG 25,VM_DTUSO
 RARG 26,VM_DTVSO
 RARG 27,VM_DTUVDF
 RARG 28,VM_DTVVDF
 CALL md2asm_vdfdifm_7240564
 MARG 0,1556120
 MARG 1,1577888
 MARG 2,1359328
 PARG 3,2
 PARG 4,3
 PARG 5,4
 PARG 6,5
 SARG 7,2944
 PARG 8,8
 PARG 9,29
 PARG 10,31
 SARG 11,2936
 RARG 12,VM_EXTSHF
 RARG 13,VM_EXTLHF
 SARG 14,2952
 PARG 15,71
 PARG 16,109
 PARG 17,60
 PARG 18,61
 PARG 19,110
 PARG 20,66
 PARG 21,67
 PARG 22,68
 RARG 23,VM_SLGM1
 RARG 24,VM_QTM1
 PARG 25,51
 RARG 26,VM_CFH
 RARG 27,VM_CFHTI
 RARG 28,VM_CFQTI
 RARG 29,VM_MFLX
 RARG 30,VM_SLGUH
 RARG 31,VM_QTUH
 RARG 32,VM_SLGDIF
 RARG 33,VM_QTDIF
 RARG 34,VM_CPTSTI
 RARG 35,VM_QSTI
 RARG 36,VM_CAIRTI
 RARG 37,VM_CSATTI
 RARG 38,VM_CPTSTIU
 RARG 39,VM_CAIRTIU
 RARG 40,VM_CSATTIU
 RARG 41,VM_TSRF
 RARG 42,VM_LAMSK
 RARG 43,VM_DQSTI
 PARG 44,130
 PARG 45,80
 PARG 46,57
 PARG 47,64
 PARG 48,38
 PARG 49,39
 PARG 50,65
 PARG 51,69
 PARG 52,86
 PARG 53,87
 RARG 54,VM_TSKTIH
 RARG 55,VM_SLGE
 RARG 56,VM_QTE
 RARG 57,VM_SLGEVDF
 RARG 58,VM_QTEVDF
 RARG 59,VM_TSKTITE
 PARG 60,129
 PARG 61,128
 RARG 62,VM_AHFLTI
 PARG 63,131
 RARG 64,VM_G0
 RARG 65,VM_EVAPUTI
 CALL md2asm_vdfdifh_7240564
 mov x21,#0
.Lvm_overimplicit_skin_tile:
 ROWS .Lvm_overimplicit_skin_row
 L2 d0,VM_TSKTITE
 ARG x9,28
 ldr d1,[x9]
 fmul d0,d0,d1
 IN2 d1,130
 fadd d0,d1,d0
 LS2 d0,VM_TSKTIP1
 NEXT .Lvm_overimplicit_skin_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lvm_overimplicit_skin_tile
 mov x21,#3
 ROWS .Lvm_overimplicit_potential_evaporation
 L2 d0,VM_EVAPUTI
 OUT d0,111
 NEXT .Lvm_overimplicit_potential_evaporation
.Lvm_diffusion_done:
 PARG 0,2
 PARG 1,3
 PARG 2,4
 PARG 3,5
 SARG 4,2944
 PARG 5,28
 PARG 6,42
 PARG 7,43
 RARG 8,VM_SLGM1
 PARG 9,44
 RARG 10,VM_QTM1
 PARG 11,51
 RARG 12,VM_DTUTOFD
 RARG 13,VM_DTVTOFD
 RARG 14,VM_DTUSO
 RARG 15,VM_DTVSO
 RARG 16,VM_DTUVDF
 RARG 17,VM_DTVVDF
 PARG 18,121
 PARG 19,122
 RARG 20,VM_SLGE
 RARG 21,VM_QTE
 RARG 22,VM_SLGEVDF
 RARG 23,VM_QTEVDF
 RARG 24,VM_SLGEWODIS
 PARG 25,92
 PARG 26,93
 PARG 27,138
 PARG 28,139
 PARG 29,142
 PARG 30,143
 RARG 31,VM_STRTOFDU
 RARG 32,VM_STRTOFDV
 PARG 33,140
 PARG 34,141
 PARG 35,94
 CALL md2asm_vdfincr_7240564
 PARG 0,2
 PARG 1,3
 PARG 2,4
 PARG 3,5
 PARG 4,42
 PARG 5,43
 PARG 6,53
 PARG 7,76
 PARG 8,77
 RARG 9,VM_BLEND
 RARG 10,VM_FBLEND
 CALL md2asm_vdffblend_7240564
 sub x21,x28,#1
 MARG 0,1578328
 PARG 1,2
 PARG 2,3
 PARG 3,4
 PARG 4,8
 PARG 5,16
 PARG 6,17
 PARG 7,28
 DARG 8,71
 LDARG 9,VM_AHFLTI
 LDARG 10,VM_G0
 RAWVIEW 11,138,0,x28
 RAWVIEW 12,139,1,x28
 DARG 13,56
 RAWVIEW 14,42,2,x21
 RAWVIEW 15,43,3,x21
 RAWVIEW 16,45,4,x21
 RAWVIEW 17,53,5,x21
 LDARG 18,VM_CPTS
 LVIEW 19,VM_CPTGZ,6,x21
 RAWVIEW 20,51,7,x28
 LDARG 21,VM_Z0MW
 LDARG 22,VM_Z0HW
 LDARG 23,VM_Z0QW
 LDARG 24,VM_ZDL
 LDARG 25,VM_QSA
 LDARG 26,VM_BLEND
 LDARG 27,VM_FBLEND
 LDARG 28,VM_BUOM
 DARG 29,90
 DARG 30,110
 DARG 31,109
 DARG 32,60
 DARG 33,69
 DARG 34,76
 DARG 35,77
 DARG 36,78
 DARG 37,79
 DARG 38,128
 DARG 39,129
 DARG 40,125
 LDARG 41,VM_TSKTIP1
 RAWVIEW 42,134,8,x28
 RAWVIEW 43,135,9,x28
 DARG 44,126
 DARG 45,127
 DARG 46,130
 DARG 47,95
 DARG 48,96
 DARG 49,97
 DARG 50,98
 DARG 51,99
 DARG 52,100
 DARG 53,101
 DARG 54,102
 DARG 55,113
 DARG 56,106
 DARG 57,107
 DARG 58,108
 DARG 59,155
 GARG 60,yomdyncore,rplrg
 CALL md2asm_surface_postprocessing_adapter_7358525
 mov x21,x28
 ROWS .Lvm_bottom_flux_initialisation
 fmov d0,xzr
 OUT2 d0,136
 OUT2 d0,137
 LS2 d0,VM_DIFTQT
 LS2 d0,VM_DIFTSLG
 IN2 d0,135
 LS2 d0,VM_DIFTQT
 IN2 d0,134
 LS2 d0,VM_DIFTSLG
 NEXT .Lvm_bottom_flux_initialisation
 mov x21,#0
 ROWS .Lvm_top_flux_initialisation
 fmov d0,xzr
 LS2 d0,VM_DIFTQT
 OUT2 d0,135
 OUT2 d0,136
 OUT2 d0,137
 OUT2 d0,134
 LS2 d0,VM_DIFTSLG
 OUT2 d0,138
 OUT2 d0,139
 NEXT .Lvm_top_flux_initialisation
 // Descending pressure-weighted static-energy and total-water fluxes.
 sub x21,x28,#1
.Lvm_flux_reconstruction_layer:
 cmp x21,#1
 b.lt .Lvm_flux_reconstruction_done
 ROWS .Lvm_flux_reconstruction_row
 IN2 d0,51
 add x15,x21,#1
 IN2 d1,51,x15
 fsub d0,d0,d1
 fneg d0,d0
 ldr d1,[sp,#2928]
 fmul d3,d0,d1
 // Interface JK uses cell JK+1, whose zero-based cell index is JK.
 L2 d0,VM_SLGEWODIS
 L2 d1,VM_SLGEA
 fsub d0,d0,d1
 fmul d0,d0,d3
 add x15,x21,#1
 L2 d1,VM_DIFTSLG,x15
 fadd d0,d0,d1
 LS2 d0,VM_DIFTSLG
 L2 d0,VM_QTE
 L2 d1,VM_QTEA
 fsub d0,d0,d1
 fmul d0,d0,d3
 add x15,x21,#1
 L2 d1,VM_DIFTQT,x15
 fadd d0,d0,d1
 LS2 d0,VM_DIFTQT
 NEXT .Lvm_flux_reconstruction_row
 sub x21,x21,#1
 b .Lvm_flux_reconstruction_layer
.Lvm_flux_reconstruction_done:
 // The selected tracer route was rejected before writes; no numerical fallback.
 mov x21,#0
.Lvm_final_rate_layer:
 ROWS .Lvm_final_rate_row
 L2 d0,VM_SLGE
 IN2 d1,118
 GLOBAL d2,yomcst,rlvtt
 fmul d1,d2,d1
 fadd d0,d0,d1
 IN2 d1,45
 GLOBAL d2,yoethf,rvtmp2
 fmul d1,d2,d1
 CONST d2,one
 fadd d1,d2,d1
 GLOBAL d2,yomcst,rcpd
 fmul d1,d2,d1
 fdiv d0,d0,d1
 OUT2 d0,116
 L2 d0,VM_QTE
 IN2 d1,118
 fsub d0,d0,d1
 OUT2 d0,117
 // Source low-vapour transfer keeps the complete trial cloud amount.
 ARG x9,28
 ldr d6,[x9]
 fmul d0,d0,d6
 IN2 d1,45
 fadd d4,d1,d0
 IN2 d0,118
 IN2 d1,119
 fadd d0,d0,d1
 fmul d0,d0,d6
 IN2 d1,46
 IN2 d2,47
 fadd d1,d1,d2
 fadd d5,d1,d0
 MODEL_F d7,1581384
 fcmp d4,d7
 b.ge .Lvm_final_rate_next
 fcmp d5,d7
 b.le .Lvm_final_rate_next
 fsub d4,d7,d4
 fmin d4,d4,d5
 fdiv d4,d4,d6
 fmax d0,d7,d5
 CONST d1,one
 fdiv d5,d1,d0
 IN2 d0,117
 fadd d0,d0,d4
 OUT2 d0,117
 IN2 d0,118
 fmul d0,d0,d6
 IN2 d1,46
 fadd d0,d1,d0
 fmov d1,xzr
 fmax d0,d1,d0
 fmul d3,d0,d5
 IN2 d0,118
 fmul d1,d3,d4
 fsub d0,d0,d1
 OUT2 d0,118
 GLOBAL d0,yomcst,rlvtt
 GLOBAL d1,yomcst,rcpd
 fdiv d0,d0,d1
 fmul d0,d0,d3
 fmul d0,d0,d4
 IN2 d1,116
 fsub d0,d1,d0
 OUT2 d0,116
 CONST d0,one
 fsub d3,d0,d3
 IN2 d0,119
 fmul d1,d3,d4
 fsub d0,d0,d1
 OUT2 d0,119
 GLOBAL d0,yomcst,rlstt
 GLOBAL d1,yomcst,rcpd
 fdiv d0,d0,d1
 fmul d0,d0,d3
 fmul d0,d0,d4
 IN2 d1,116
 fsub d0,d1,d0
 OUT2 d0,116
.Lvm_final_rate_next:
 NEXT .Lvm_final_rate_row
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lvm_final_rate_layer
 // Carry liquid and ice fluxes upward, then reconstruct vapour and heat.
 sub x21,x28,#1
.Lvm_final_flux_layer:
 cmp x21,#1
 b.lt .Lvm_final_flux_done
 ROWS .Lvm_final_flux_row
 add x15,x21,#1
 IN2 d0,136,x15
 OUT2 d0,136
 IN2 d1,137,x15
 OUT2 d1,137
 L2 d2,VM_DIFTQT
 fsub d2,d2,d0
 fsub d2,d2,d1
 OUT2 d2,135
 GLOBAL d2,yomcst,rlvtt
 fmul d0,d2,d0
 L2 d2,VM_DIFTSLG
 fadd d0,d2,d0
 GLOBAL d2,yomcst,rlstt
 fmul d1,d2,d1
 fadd d0,d0,d1
 OUT2 d0,134
 NEXT .Lvm_final_flux_row
 sub x21,x21,#1
 b .Lvm_final_flux_layer
.Lvm_final_flux_done:
 ldr x0,[sp,#3072]
 CALL free
 ldr w9,[sp,#2900]
 cbz w9,.Lvm_return
 adr x0,.Lvm_hook_name
 add x1,sp,#2904
 mov w9,#1
 str w9,[x1]
 add x2,sp,#2912
 mov x3,#7
 CALL __yomhook_MOD_dr_hook_default8
.Lvm_return:
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
 add sp,sp,#12,lsl #12
 ret
.Lvm_reject:
 brk #0x535
.size md2asm_vertical_diffusion_main_sea_r2_7358525,.-md2asm_vertical_diffusion_main_sea_r2_7358525
// Integer storage helper: clear active rows over each complete public plane.
.Lvm_zero_public_selected:
 ldrb w10,[x9,#28]
 ldr x11,[x9]
 mov x12,#1
 cmp w10,#1
 b.eq .Lvm_zero_planes_ready
 ldr x12,[x9,#80]
 cmp x12,#0
 b.le .Lvm_zero_return
 cmp w10,#2
 b.eq .Lvm_zero_planes_ready
 ldr x13,[x9,#104]
 cmp x13,#0
 b.le .Lvm_zero_return
 mul x12,x12,x13
.Lvm_zero_planes_ready:
 mov x14,#0
.Lvm_zero_plane:
 mov x15,x23
.Lvm_zero_row:
 madd x16,x14,x22,x15
 str xzr,[x11,x16,lsl #3]
 add x15,x15,#1
 cmp x15,x24
 b.lt .Lvm_zero_row
 add x14,x14,#1
 cmp x14,x12
 b.lt .Lvm_zero_plane
.Lvm_zero_return:
 ret
// Complete original cloud/fog correction pass, called twice.
.Lvm_cloud_fog_correction:
 str x30,[sp,#3080]
 ROWS .Lvm_fog_initial_row
 fmov d0,xzr
 LS d0,VM_LIMIN
 mov w11,#1
 LIS w11,VM_LLFIRST
 ARG x9,115
 ldr w12,[x9,x20,lsl #2]
 cmp w12,#1
 cset w13,eq
 IN d0,103
 CONST d1,fog_height
 fcmp d0,d1
 cset w14,lt
 and w13,w13,w14
 L d0,VM_KHVFL
 GLOBAL d1,yomcst,rcpd
 fmul d0,d0,d1
 CONST d1,fog_heat
 fcmp d0,d1
 cset w14,gt
 and w11,w13,w14
 LIS w11,VM_LLTEST
 NEXT .Lvm_fog_initial_row
 MODEL_ADDR x9,1581720
 ldr w9,[x9]
 str w9,[sp,#3032]
 sub x21,x28,#1
.Lvm_fog_scan_layer:
 add x15,x21,#1
 ldr w9,[sp,#3032]
 cmp x15,x9
 b.lt .Lvm_fog_done
 ROWS .Lvm_fog_scan_row
 LI w11,VM_LLTEST
 cbz w11,.Lvm_fog_scan_next
 add x15,x21,#1
 IN2 d0,54,x15
 ldr d1,[sp,#2928]
 fmul d0,d0,d1
 IN d1,104
 IN d2,103
 fmax d1,d1,d2
 fcmp d0,d1
 b.gt .Lvm_fog_scan_next
 IN2 d0,46
 IN2 d1,47
 fadd d3,d0,d1
 L d1,VM_LIMIN
 fcmp d3,d1
 b.le .Lvm_fog_scan_next
 IN2 d0,53
 ldr d1,[sp,#2928]
 fmul d0,d0,d1
 OUT d0,103
 LI w11,VM_LLFIRST
 cbz w11,.Lvm_fog_base_done
 add w11,w21,#1
 LIS w11,VM_ICBASE
.Lvm_fog_base_done:
 mov w11,#0
 LIS w11,VM_LLFIRST
 add w11,w21,#1
 LIS w11,VM_ICTOP
 LIS w11,VM_IINV
 ARG x9,115
 mov w11,#2
 str w11,[x9,x20,lsl #2]
 LS d3,VM_LIMIN
.Lvm_fog_scan_next:
 NEXT .Lvm_fog_scan_row
 sub x21,x21,#1
 b .Lvm_fog_scan_layer
.Lvm_fog_done:
 ldr x30,[sp,#3080]
 ret
.section .rodata
.p2align 3
.Lvm_one: .double 1.0
.Lvm_half: .double 0.5
.Lvm_virtual_water_factor: .double 5.87
.Lvm_fog_height: .double 200.0
.Lvm_fog_heat: .double -20.0
.Lvm_epsilon100: .double 2.220446049250313080847263336181640625e-14
.Lvm_hook_name: .ascii "VDFMAIN"
.p2align 2
.Lvm_local_specs:
 .word 0,3 // CPTGZ
 .word 0,3 // CFM
 .word 0,3 // CFH
 .word 0,3 // UDIF
 .word 0,3 // VDIF
 .word 0,3 // DTUTOFD
 .word 0,3 // DTVTOFD
 .word 0,3 // DTUSO
 .word 0,3 // DTVSO
 .word 0,3 // DTUVDF
 .word 0,3 // DTVVDF
 .word 0,3 // QTDIF
 .word 0,3 // SLGDIF
 .word 0,3 // SLGM1
 .word 0,3 // QTM1
 .word 0,3 // SLGSM1
 .word 0,3 // SLGE
 .word 0,3 // QTE
 .word 0,3 // SLGEVDF
 .word 0,3 // QTEVDF
 .word 0,3 // TOFDC
 .word 1,3 // KHFL
 .word 1,3 // KQFL
 .word 1,3 // KMFL
 .word 1,3 // KHVFL
 .word 1,3 // LIMIN
 .word 0,3 // QTEA
 .word 0,3 // SLGEA
 .word 0,3 // SLGEWODIS
 .word 1,3 // Z0MW
 .word 1,3 // Z0HW
 .word 1,3 // Z0QW
 .word 1,3 // BLEND
 .word 1,3 // FBLEND
 .word 1,3 // CPTS
 .word 1,3 // QSA
 .word 1,3 // BUOM
 .word 1,3 // ZDL
 .word -1,3 // STRTOFDU
 .word -1,3 // STRTOFDV
 .word -1,3 // MFLX
 .word -1,3 // SLGUH
 .word -1,3 // QTUH
 .word 1,3 // CLDBASE
 .word -1,3 // UUH
 .word -1,3 // VUH
 .word 1,3 // EXTSHF
 .word 1,3 // EXTLHF
 .word 1,3 // WETB
 .word 1,3 // WETL
 .word 1,3 // WETLU
 .word 1,3 // WETH
 .word 1,3 // WETHS
 .word 1,3 // RAQ
 .word 9,3 // CPTSTI
 .word 9,3 // QSTI
 .word 9,3 // DQSTI
 .word 9,3 // CSATTI
 .word 9,3 // CAIRTI
 .word 9,3 // CFHTI
 .word 9,3 // CFQTI
 .word 9,3 // AHFLTI
 .word 9,3 // TSKTIP1
 .word 9,3 // CPTSTIU
 .word 9,3 // CSATTIU
 .word 9,3 // CAIRTIU
 .word 9,3 // EVAPUTI
 .word 9,3 // TSKTIH
 .word 9,3 // TSKTITE
 .word 9,3 // TSKTITE1
 .word 9,3 // EVAPUTI1
 .word 9,3 // RAQTI
 .word 9,3 // TSRF
 .word 9,3 // LAMSK
 .word 9,3 // G0
 .word 1,3 // ATMCO2
 .word 1,1 // IINV
 .word 1,1 // ICBASE
 .word 1,1 // ICTOP
 .word 1,2 // LLAND
 .word 1,2 // LLTEST
 .word 1,2 // LLFIRST
 .word -1,3 // DIFTQT
 .word -1,3 // DIFTSLG
 .word 0,3 // DTUTOFD1
 .word 0,3 // DTVTOFD1
 .word 0,3 // DTUSO1
 .word 0,3 // DTVSO1
 .word 0,3 // DTUVDF1
 .word 0,3 // DTVVDF1
 .word 0,3 // UM1S
 .word 0,3 // VM1S
 .word 0,3 // SLGM1S
 .word 0,3 // QTM1S
 .word 0,3 // SLGEVDF1
 .word 0,3 // QTEVDF1
 .word 9,3 // EVAPTI1
 .word 9,3 // AHFSTI1
 .word 9,3 // AHFLTI1
 .word 9,3 // FLTRTI1
 .word 9,3 // G01
.section .rodata
.p2align 2
.Lvm_public_specs:
 .word 0,0,0,0,0,0 // YDMODEL
 .word 0,0,0,0,0,0 // CDCONF
 .word 0,0,0,0,0,0 // KIDIA
 .word 0,0,0,0,0,0 // KFDIA
 .word 0,0,0,0,0,0 // KLON
 .word 0,0,0,0,0,0 // KLEV
 .word 0,0,0,0,0,0 // KLEVS
 .word 0,0,0,0,0,0 // KSTEP
 .word 0,0,0,0,0,0 // KTILES
 .word 0,0,0,0,0,0 // KVTYPES
 .word 0,0,0,0,0,0 // KDIAG
 .word 0,0,0,0,0,0 // KTRAC
 .word 0,0,0,0,0,0 // KCHEM
 .word 0,0,0,0,0,0 // KAERO
 .word 0,0,0,0,0,0 // KLEVSN
 .word 0,0,0,0,0,0 // KLEVI
 .word 0,0,0,0,0,0 // KDHVTLS
 .word 0,0,0,0,0,0 // KDHFTLS
 .word 0,0,0,0,0,0 // KDHVTSS
 .word 0,0,0,0,0,0 // KDHFTSS
 .word 0,0,0,0,0,0 // KDHVTTS
 .word 0,0,0,0,0,0 // KDHFTTS
 .word 0,0,0,0,0,0 // KDHVTIS
 .word 0,0,0,0,0,0 // KDHFTIS
 .word 0,0,0,0,0,0 // KDHVCO2S
 .word 0,0,0,0,0,0 // KDHFCO2S
 .word 0,0,0,0,0,0 // KDHVVEGS
 .word 0,0,0,0,0,0 // KDHFVEGS
 .word 0,0,0,0,0,0 // PTSPHY
 .word 1,1,-1,-1,-1,-1 // KTVL
 .word 1,1,-1,-1,-1,-1 // KCO2TYP
 .word 1,1,-1,-1,-1,-1 // KTVH
 .word 1,3,-1,-1,-1,-1 // PCVL
 .word 1,3,-1,-1,-1,-1 // PCVH
 .word 1,3,-1,-1,-1,-1 // PCUR
 .word 1,3,-1,-1,-1,-1 // PFWET
 .word 1,3,-1,-1,-1,-1 // PLAIL
 .word 1,3,-1,-1,-1,-1 // PLAIH
 .word 2,3,14,-1,-1,-1 // PSNM
 .word 2,3,14,-1,-1,-1 // PRSN
 .word 1,3,-1,-1,-1,-1 // PMU0
 .word 1,3,-1,-1,-1,-1 // PSIGFLT
 .word 2,3,5,-1,-1,-1 // PUM1
 .word 2,3,5,-1,-1,-1 // PVM1
 .word 2,3,5,-1,-1,-1 // PTM1
 .word 2,3,5,-1,-1,-1 // PQM1
 .word 2,3,5,-1,-1,-1 // PLM1
 .word 2,3,5,-1,-1,-1 // PIM1
 .word 2,3,5,-1,-1,-1 // PAM1
 .word 3,3,5,-1,11,-1 // PCM1
 .word 2,3,5,-1,-1,-1 // PTKE1
 .word 2,3,5,-2,-1,-1 // PAPHM1
 .word 2,3,5,-1,-1,-1 // PAPM1
 .word 2,3,5,-1,-1,-1 // PGEOM1
 .word 2,3,5,-2,-1,-1 // PGEOH
 .word 1,3,-1,-1,-1,-1 // PGELAT
 .word 1,3,-1,-1,-1,-1 // PTSKM1M
 .word 2,3,6,-1,-1,-1 // PTSAM1M
 .word 2,3,6,-1,-1,-1 // PWSAM1M
 .word 1,3,-1,-1,-1,-1 // PSSRFL
 .word 1,3,-1,-1,-1,-1 // PSLRFL
 .word 1,3,-1,-1,-1,-1 // PEMIS
 .word 2,3,5,-1,-1,-1 // PHRLW
 .word 2,3,5,-1,-1,-1 // PHRSW
 .word 2,3,14,-1,-1,-1 // PTSN
 .word 1,3,-1,-1,-1,-1 // PTICE
 .word 1,3,-1,-1,-1,-1 // PHLICE
 .word 1,3,-1,-1,-1,-1 // PTLICE
 .word 1,3,-1,-1,-1,-1 // PTLWML
 .word 1,3,-1,-1,-1,-1 // PSST
 .word 1,1,-1,-1,-1,-1 // KSOTY
 .word 2,3,8,-1,-1,-1 // PFRTI
 .word 2,3,8,-1,-1,-1 // PALBTI
 .word 1,3,-1,-1,-1,-1 // PWLMX
 .word 1,3,-1,-1,-1,-1 // PCHAR
 .word 1,3,-1,-1,-1,-1 // PCHARHQ
 .word 1,3,-1,-1,-1,-1 // PUCURR
 .word 1,3,-1,-1,-1,-1 // PVCURR
 .word 1,3,-1,-1,-1,-1 // PUSTOKES
 .word 1,3,-1,-1,-1,-1 // PVSTOKES
 .word 1,3,-1,-1,-1,-1 // PTSKRAD
 .word 2,3,11,-1,-1,-1 // PCFLX
 .word 2,3,11,-1,-1,-1 // PDDVLC
 .word 2,3,5,-1,-1,-1 // PSOTEU
 .word 2,3,5,-1,-1,-1 // PSOTEV
 .word 2,3,5,-1,-1,-1 // PSOBETA
 .word 1,3,-1,-1,-1,-1 // PTHKICE
 .word 1,3,-1,-1,-1,-1 // PSNTICE
 .word 2,3,-1,-1,-1,-1 // PGP2DSPP
 .word 0,0,0,0,0,0 // LSICOUP
 .word 1,3,-1,-1,-1,-1 // PZ0M
 .word 1,3,-1,-1,-1,-1 // PZ0H
 .word 1,3,-1,-1,-1,-1 // PVDIS
 .word 1,3,-1,-1,-1,-1 // PVDISG
 .word 2,3,5,-1,-1,-1 // PDISGW3D
 .word 1,3,-1,-1,-1,-1 // PAHFLEV
 .word 1,3,-1,-1,-1,-1 // PAHFLSB
 .word 1,3,-1,-1,-1,-1 // PFWSB
 .word 1,3,-1,-1,-1,-1 // PU10M
 .word 1,3,-1,-1,-1,-1 // PV10M
 .word 1,3,-1,-1,-1,-1 // PT2M
 .word 1,3,-1,-1,-1,-1 // PD2M
 .word 1,3,-1,-1,-1,-1 // PQ2M
 .word 1,3,-1,-1,-1,-1 // PZINV
 .word 1,3,-1,-1,-1,-1 // PBLH
 .word 1,3,-1,-1,-1,-1 // PEIS
 .word 1,3,-1,-1,-1,-1 // P10NU
 .word 1,3,-1,-1,-1,-1 // P10NV
 .word 1,3,-1,-1,-1,-1 // PUST
 .word 2,3,8,-1,-1,-1 // PSSRFLTI
 .word 1,3,-1,-1,-1,-1 // PEVAPSNW
 .word 1,3,-1,-1,-1,-1 // PEVAPMU
 .word 2,3,10,-1,-1,-1 // PEXDIAG
 .word 1,3,-1,-1,-1,-1 // PGUST
 .word 1,3,-1,-1,-1,-1 // PI10FGCV
 .word 1,1,-1,-1,-1,-1 // KPBLTYPE
 .word 2,3,5,-1,-1,-1 // PTE
 .word 2,3,5,-1,-1,-1 // PQE
 .word 2,3,5,-1,-1,-1 // PLE
 .word 2,3,5,-1,-1,-1 // PIE
 .word 2,3,5,-1,-1,-1 // PAE
 .word 2,3,5,-1,-1,-1 // PVOM
 .word 2,3,5,-1,-1,-1 // PVOL
 .word 2,3,5,-1,-1,-1 // PTKEE
 .word 3,3,5,-1,11,-1 // PTENC
 .word 1,3,-1,-1,-1,-1 // PTSKE1
 .word 2,3,8,-1,-1,-1 // PUSTRTI
 .word 2,3,8,-1,-1,-1 // PVSTRTI
 .word 2,3,8,-1,-1,-1 // PAHFSTI
 .word 2,3,8,-1,-1,-1 // PEVAPTI
 .word 2,3,8,-1,-1,-1 // PTSKTI
 .word 2,3,8,-1,-1,-1 // PFLTRTI
 .word 2,3,9,-1,-1,-1 // PANDAYVT
 .word 2,3,9,-1,-1,-1 // PANFMVT
 .word 2,3,5,-2,-1,-1 // PDIFTS
 .word 2,3,5,-2,-1,-1 // PDIFTQ
 .word 2,3,5,-2,-1,-1 // PDIFTL
 .word 2,3,5,-2,-1,-1 // PDIFTI
 .word 2,3,5,-2,-1,-1 // PSTRTU
 .word 2,3,5,-2,-1,-1 // PSTRTV
 .word 1,3,-1,-1,-1,-1 // PTOFDU
 .word 1,3,-1,-1,-1,-1 // PTOFDV
 .word 2,3,5,-2,-1,-1 // PSTRSOU
 .word 2,3,5,-2,-1,-1 // PSTRSOV
 .word 2,3,5,-1,-1,-1 // PKH
 .word 2,3,5,-1,-1,-1 // PKM
 .word 2,3,5,-1,-1,-1 // PRI
 .word 1,3,-1,-1,-1,-1 // PAN
 .word 1,3,-1,-1,-1,-1 // PAG
 .word 1,3,-1,-1,-1,-1 // PRD
 .word 1,3,-1,-1,-1,-1 // PRSOIL_STR
 .word 1,3,-1,-1,-1,-1 // PRECO
 .word 1,3,-1,-1,-1,-1 // PCO2FLUX
 .word 1,3,-1,-1,-1,-1 // PCH4FLUX
 .word 2,3,11,-1,-1,-1 // PCFLXO
 .word 3,3,8,-1,16,17 // PDHTLS
 .word 3,3,14,-1,18,19 // PDHTSS
 .word 3,3,6,-1,20,21 // PDHTTS
 .word 3,3,15,-1,22,23 // PDHTIS
 .word 3,3,9,-1,24,25 // PDHCO2S
 .word 3,3,9,-1,26,27 // PDHVEGS
 .word 1,3,-1,-1,-1,-1 // PCGPP
 .word 1,3,-1,-1,-1,-1 // PCREC

.section .note.GNU-stack,"",%progbits

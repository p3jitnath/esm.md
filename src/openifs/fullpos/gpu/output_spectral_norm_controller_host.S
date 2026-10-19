#include "../../support/gpu/preserved_weather_calls.inc.S"
.text
.p2align 4
.global md2asm_fpspnorms_7358525
.type md2asm_fpspnorms_7358525,%function
md2asm_fpspnorms_7358525:
 mov x16,sp
 sub sp,sp,#640
 stp x0,x1,[sp,#128]
 stp x2,x3,[sp,#144]
 stp x4,x5,[sp,#160]
 stp x6,x7,[sp,#176]
 ldr x9,[x16,#0]
 str x9,[sp,#192]
 ldr x9,[x16,#8]
 str x9,[sp,#200]
 ldr x9,[x16,#16]
 str x9,[sp,#208]
 ldr x9,[x16,#24]
 str x9,[sp,#216]
 stp x19,x20,[sp,#384]
 stp x21,x22,[sp,#400]
 stp x23,x24,[sp,#416]
 stp x25,x26,[sp,#432]
 stp x27,x28,[sp,#448]
 stp x29,x30,[sp,#464]
 mov x20,x1
 mov x21,x2
 mrs x9,fpcr
 cbnz x9,.Lf_bad
 adrp x9,:got:__yommp0_MOD_nproc
 ldr x9,[x9,:got_lo12:__yommp0_MOD_nproc]
 ldr w10,[x9]
 cmp w10,#1
 b.ne .Lf_bad
 ldr x9,[sp,#168]
 ldr x22,[x9,#56]
 ldr x10,[x9,#48]
 sub x22,x22,x10
 add x22,x22,#1
 cmp x22,#1
 b.lt .Lf_bad
 cmp x22,#39
 b.gt .Lf_bad
 ldr x9,[sp,#128]
 ldr x10,[x9,#56]
 ldr x11,[x9,#48]
 sub x10,x10,x11
 cbnz x10,.Lf_bad
 ldr x9,[sp,#192]
 cbz x9,.Lf_bad
 ldrb w9,[x9]
 cmp w9,#80
 b.eq .Lf_cfg
 cmp w9,#83
 b.ne .Lf_bad
.Lf_cfg:
 adrp x9,:got:__tpm_distr_MOD_d
 ldr x9,[x9,:got_lo12:__tpm_distr_MOD_d]
 ldr x19,[x9]
 cbz x19,.Lf_bad
 ldr w9,[x19,#16]
 cmp w9,#22
 b.ne .Lf_bad
 adrp x9,:got:__tpm_dim_MOD_r
 ldr x9,[x9,:got_lo12:__tpm_dim_MOD_r]
 ldr x9,[x9]
 cbz x9,.Lf_bad
 ldr w9,[x9]
 cmp w9,#21
 b.ne .Lf_bad
 mov x23,#0
.Lf_vset:
 ldr x9,[x21,#8]
 ldr x10,[x21,#40]
 ldr x11,[x21,#48]
 add x11,x11,x23
 madd x9,x11,x10,x9
 ldr x10,[x21]
 ldr w9,[x10,x9,lsl #2]
 cmp w9,#1
 b.ne .Lf_bad
 add x23,x23,#1
 cmp x23,x22
 b.lt .Lf_vset
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 str w9,[sp,#520]
 cbz w9,.Lf_started
 adr x0,.Lf_name
 add x1,sp,#524
 str wzr,[x1]
 add x2,sp,#528
 mov x3,#9
 str x18,[sp,#512]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#512]
.Lf_started:
 mov x9,#176
 mul x0,x22,x9
 str x18,[sp,#512]
 bl malloc
 ldr x18,[sp,#512]
 cbz x0,.Lf_bad
 mov x21,x0
 mov x4,x21
 mov x0,x19
 mov x1,x20
 mov x2,#0
 mov x3,x22
 str x18,[sp,#512]
 bl md2asm_output_spectral_norm_matrix_7358525
 ldr x18,[sp,#512]
 adrp x24,:got:md2asm_output_spectral_norm_results_7358525
 ldr x24,[x24,:got_lo12:md2asm_output_spectral_norm_results_7358525]
 mov x23,#0
 adr x9,.Lf_epsilon
 ldr d4,[x9]
.Lf_field:
 fmov d0,xzr
 mov x25,#0
.Lf_wave:
 madd x9,x25,x22,x23
 ldr d1,[x21,x9,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,0,d0,d0,d1 // fadd d0,d0,d1
 add x25,x25,#1
 cmp x25,#22
 b.lt .Lf_wave
 md2asm_gpu_upper_operation md2asm_gpu_lake_energy_cell_host,17,d0,d0 // fsqrt d0,d0
 str d0,[x24,x23,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d4,real,late,comparison // fcmp d0,d4
 b.ge .Lf_display
 fmov d0,xzr
.Lf_display:
 add x9,x24,#312
 str d0,[x9,x23,lsl #3]
 add x23,x23,#1
 cmp x23,x22
 b.lt .Lf_field
 adrp x9,:got:md2asm_output_spectral_norm_count_7358525
 ldr x9,[x9,:got_lo12:md2asm_output_spectral_norm_count_7358525]
 str w22,[x9]
 mov x0,x21
 str x18,[sp,#512]
 bl free
 ldr x18,[sp,#512]
 ldr w9,[sp,#520]
 cbz w9,.Lf_return
 adr x0,.Lf_name
 add x1,sp,#524
 mov w9,#1
 str w9,[x1]
 add x2,sp,#528
 mov x3,#9
 str x18,[sp,#512]
 bl __yomhook_MOD_dr_hook_default8
 ldr x18,[sp,#512]
.Lf_return:
 ldp x19,x20,[sp,#384]
 ldp x21,x22,[sp,#400]
 ldp x23,x24,[sp,#416]
 ldp x25,x26,[sp,#432]
 ldp x27,x28,[sp,#448]
 ldp x29,x30,[sp,#464]
 add sp,sp,#640
 ret
.Lf_bad:
 str x18,[sp,#512]
 bl abort
 ldr x18,[sp,#512]
.size md2asm_fpspnorms_7358525,.-md2asm_fpspnorms_7358525
.section .rodata
.Lf_name: .ascii "FPSPNORMS"
.p2align 3
.Lf_epsilon: .quad 0x3cb0000000000000
.bss
.p2align 3
.global md2asm_output_spectral_norm_results_7358525
md2asm_output_spectral_norm_results_7358525: .zero 624
.global md2asm_output_spectral_norm_count_7358525
md2asm_output_spectral_norm_count_7358525: .zero 4
.section .note.GNU-stack,"",%progbits

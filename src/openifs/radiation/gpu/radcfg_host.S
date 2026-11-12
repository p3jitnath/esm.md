#include "../../support/gpu/preserved_weather_calls.inc.S"
// Complete selected RADCFG. Physics formulations/openifs/radiation/radiation_grid_preparation.md.
// Contract skills/md2fort/references/openifs/radiation/radiation_grid_preparation.md.
// Accepted direct children retain every numerical stage. Forty-six original pointer arguments.
.text
.p2align 4
.macro ARG reg, index
 ldr \reg,[x19,#(\index*8)]
.endm
.macro ADDRESS reg, base, offset
 movz \reg,#(\offset & 65535)
 movk \reg,#(\offset >> 16),lsl #16
 add \reg,\base,\reg
.endm
.macro SURFACE_FIELD target, argument, selector, index_offset, levels_offset=0
 ARG x9,\argument
 ldr x10,[x21,#\selector]
 ldrsw x10,[x10,#\index_offset]
 sub x10,x10,#1
 mul x10,x10,x27
.if \levels_offset
 ldrsw x11,[x21,#\levels_offset]
 mul x10,x10,x11
.endif
 add x9,x9,x10
 str x9,[x17,#(\target*8)]
.endm
.macro ATMOSPHERIC_FIELD target, selector
 ARG x9,10
 ADDRESS x10,x22,\selector
 ldr x10,[x10]
 ldrsw x10,[x10,#184]
 sub x10,x10,#1
 mul x10,x10,x23
 mul x10,x10,x24
 add x9,x9,x10,lsl #3
 str x9,[x17,#(\target*8)]
.endm
.macro CHECK_SURFACE selector, dimension, index_offset
 ldr x9,[x21,#\selector]
 cbz x9,.Lgrid_reject
 tst x9,#7
 b.ne .Lgrid_reject
 ldr w10,[x9,#\index_offset]
 cmp w10,#1
 b.lt .Lgrid_reject
 ldr w11,[x21,#\dimension]
 cmp w10,w11
 b.gt .Lgrid_reject
.endm
.macro COMPLETED_CHILD index
 adrp x9,md2asm_radcfg_private_child_counts
 add x9,x9,:lo12:md2asm_radcfg_private_child_counts
 ldr x10,[x9,#(8*\index)]
 add x10,x10,#1
 str x10,[x9,#(8*\index)]
.endm
.global md2asm_radcfg
.type md2asm_radcfg,%function
md2asm_radcfg:
 sub sp,sp,#1,lsl #12
 add x16,sp,#512
 stp x19,x20,[x16,#0]
 stp x21,x22,[x16,#16]
 stp x23,x24,[x16,#32]
 stp x25,x26,[x16,#48]
 stp x27,x28,[x16,#64]
 stp x29,x30,[x16,#80]
 stp d8,d9,[x16,#96]
 stp d10,d11,[x16,#112]
 stp d12,d13,[x16,#128]
 stp d14,d15,[x16,#144]
 str x18,[sp,#688]
 mov x29,sp
 add x19,sp,#1024
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 add x11,sp,#1,lsl #12
 mov x10,#8
.Lgrid_arguments:
 ldr x9,[x11],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#46
 b.lt .Lgrid_arguments
 mrs x9,fpcr
 cbnz x9,.Lgrid_reject
 mov x10,#0
.Lgrid_pointers:
 ldr x9,[x19,x10,lsl #3]
 cbz x9,.Lgrid_reject
 tst x9,#3
 b.ne .Lgrid_reject
 cmp x10,#3
 b.lt .Lgrid_double_alignment
 cmp x10,#7
 b.le .Lgrid_pointer_next
.Lgrid_double_alignment:
 tst x9,#7
 b.ne .Lgrid_reject
.Lgrid_pointer_next:
 add x10,x10,#1
 cmp x10,#45
 b.lt .Lgrid_pointers
 ARG x20,0
 ARG x21,1
 ARG x22,2
 ldr w23,[x20,#5144]
 cmp w23,#1
 b.lt .Lgrid_reject
 cmp w23,#2048
 b.gt .Lgrid_reject
 ldr w24,[x20,#5224]
 cmp w24,#3
 b.lt .Lgrid_reject
 cmp w24,#256
 b.gt .Lgrid_reject
 ARG x9,3
 ldr w25,[x9]
 sub w25,w25,#1
 cmp w25,#0
 b.lt .Lgrid_reject
 cmp w25,w23
 b.ge .Lgrid_reject
 ARG x9,4
 ldr w26,[x9]
 cmp w26,w25
 b.le .Lgrid_reject
 cmp w26,w23
 b.gt .Lgrid_reject
 ADDRESS x9,x22,1564156
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_reject
 ldr w9,[x22,#300]
 cbnz w9,.Lgrid_reject
 ldr w9,[x22,#240]
 cmp w9,#1
 b.lt .Lgrid_reject
 cmp w9,#4096
 b.gt .Lgrid_reject
 str w9,[sp,#736]
 ARG x9,6
 ldr w9,[x9]
 cmp w9,#1
 b.lt .Lgrid_reject
 ADDRESS x10,x22,1573360
 ldr w10,[x10]
 cmp w10,#1
 b.lt .Lgrid_reject
 cmp w10,w9
 b.gt .Lgrid_reject
 ldr x9,[x20,#3240]
 cbz x9,.Lgrid_reject
 str x9,[sp,#744]
 ldr x10,[x20,#3264]
 cbz x10,.Lgrid_reject
 ldr w11,[x10,#52]
 cmp w11,#1
 b.ne .Lgrid_reject
 str x10,[sp,#752]
 adrp x9,:got:__intdyn_mod_MOD_yytxyb
 ldr x9,[x9,:got_lo12:__intdyn_mod_MOD_yytxyb]
 mov x10,#0
.Lgrid_field_map:
 ldr w11,[x9,x10,lsl #2]
 cmp x10,#7
 add w12,w10,#1
 mov w13,#7
 csel w12,w13,w12,eq
 cmp w11,w12
 b.ne .Lgrid_reject
 add x10,x10,#1
 cmp x10,#8
 b.lt .Lgrid_field_map
 mov w9,#1
 str w9,[sp,#768]
 mov w9,#9
 str w9,[sp,#772]
 ldr w9,[x21,#9304]
 ldr w10,[x21,#9308]
 cmp w9,#1
 b.lt .Lgrid_reject
 cmp w10,w9
 b.lt .Lgrid_reject
 ldr w11,[x21,#8900]
 cmp w10,w11
 b.gt .Lgrid_reject
 sub w10,w10,w9
 add w10,w10,#1
 cmp w10,#4
 b.eq .Lgrid_albedo_count
 cmp w10,#6
 b.ne .Lgrid_reject
.Lgrid_albedo_count:
 str w10,[sp,#776]
 ADDRESS x9,x22,1577900
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_reject
 ADDRESS x9,x22,1577956
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_reject
 ADDRESS x9,x22,1577932
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lgrid_reject
 ADDRESS x9,x22,1588300
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Lgrid_reject
 ADDRESS x9,x22,1608744
 ldr w9,[x9]
 cmp w9,#0
 b.ne .Lgrid_reject
 ADDRESS x9,x22,1608788
 ldr w9,[x9]
 cmp w9,#6
 b.ne .Lgrid_reject
 ADDRESS x9,x22,1608808
 ldr w9,[x9]
 cmp w9,#14
 b.ne .Lgrid_reject
 ADDRESS x9,x22,1608800
 ldr w9,[x9]
 cmp w9,#2
 b.ne .Lgrid_reject
 CHECK_SURFACE 5952,5884,8
 CHECK_SURFACE 6232,6172,8
 CHECK_SURFACE 6248,6172,8
 CHECK_SURFACE 6240,6172,8
 CHECK_SURFACE 6808,6748,8
 CHECK_SURFACE 6816,6748,8
 CHECK_SURFACE 6552,6452,8
 CHECK_SURFACE 6512,6452,8
 CHECK_SURFACE 9152,8900,0
 CHECK_SURFACE 8968,8900,0
 CHECK_SURFACE 8976,8900,0
 CHECK_SURFACE 8992,8900,0
 CHECK_SURFACE 8960,8900,0
 CHECK_SURFACE 9104,8900,0
 CHECK_SURFACE 9080,8900,0
 CHECK_SURFACE 9112,8900,0
 CHECK_SURFACE 9072,8900,0
 CHECK_SURFACE 9088,8900,0
 CHECK_SURFACE 9096,8900,0
 CHECK_SURFACE 9128,8900,0
 CHECK_SURFACE 9136,8900,0
 CHECK_SURFACE 9144,8900,0
 CHECK_SURFACE 8984,8900,0
 CHECK_SURFACE 9168,8900,0
 CHECK_SURFACE 10608,10548,0
 CHECK_SURFACE 10616,10548,0
 CHECK_SURFACE 10624,10548,0
 CHECK_SURFACE 13384,12604,0
 ldr w9,[x21,#5888]
 cmp w9,#1
 b.lt .Lgrid_reject
 cmp w9,#32
 b.gt .Lgrid_reject
 ldr w9,[x21,#6176]
 cmp w9,#1
 b.lt .Lgrid_reject
 cmp w9,#32
 b.gt .Lgrid_reject
 ADDRESS x9,x22,800032
 ldr x9,[x9]
 cbz x9,.Lgrid_reject
 ldr w10,[x9,#184]
 cmp w10,#1
 b.lt .Lgrid_reject
 ldr w11,[sp,#736]
 cmp w10,w11
 b.gt .Lgrid_reject
 ADDRESS x9,x22,800048
 ldr x9,[x9]
 cbz x9,.Lgrid_reject
 ldr w10,[x9,#184]
 cmp w10,#1
 b.lt .Lgrid_reject
 ldr w11,[sp,#736]
 cmp w10,w11
 b.gt .Lgrid_reject
 ADDRESS x9,x22,800040
 ldr x9,[x9]
 cbz x9,.Lgrid_reject
 ldr w10,[x9,#184]
 cmp w10,#1
 b.lt .Lgrid_reject
 ldr w11,[sp,#736]
 cmp w10,w11
 b.gt .Lgrid_reject
 ADDRESS x9,x22,800176
 ldr x9,[x9]
 cbz x9,.Lgrid_reject
 ldr w10,[x9,#184]
 cmp w10,#1
 b.lt .Lgrid_reject
 ldr w11,[sp,#736]
 cmp w10,w11
 b.gt .Lgrid_reject

 lsl x27,x23,#3
 ARG x9,14
 mov x10,x25
 adrp x11,.Lgrid_log_min
 ldr d1,[x11,:lo12:.Lgrid_log_min]
 adrp x11,.Lgrid_log_max
 ldr d2,[x11,:lo12:.Lgrid_log_max]
.Lgrid_log_domain:
 ldr d0,[x9,x10,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d1,real,early,comparison // fcmp d0,d1
 b.lt .Lgrid_reject
 b.vs .Lgrid_reject
 md2asm_gpu_upper_operation md2asm_gpu_soil_water_cell_host,4,none,d0,d2,real,early,comparison // fcmp d0,d2
 b.gt .Lgrid_reject
 add x10,x10,#1
 cmp x10,x26
 b.lt .Lgrid_log_domain
 // Every newly consumed parent control and selector is qualified before writes.
 mul x9,x27,x24
 str x9,[sp,#720]
 mov x10,#9
 mul x1,x9,x10
 mov x0,#1
 bl calloc
 cbz x0,.Lgrid_reject
 mov x28,x0
 ldr x9,[sp,#720]
 mov x10,#7
 madd x9,x9,x10,x28
 str x9,[sp,#728]
 mov x9,x25
 str x9,[sp,#784]
.Lgrid_surface_pressure:
 ARG x9,14
 ldr x10,[sp,#784]
 ldr d0,[x9,x10,lsl #3]
 md2asm_gpu_upper_operation md2asm_gpu_lake_energy_cell_host,18,d0,d0,zero,real,early // bl exp
 ARG x9,26
 mul x10,x24,x27
 add x9,x9,x10
 ldr x10,[sp,#784]
 str d0,[x9,x10,lsl #3]
 add x10,x10,#1
 str x10,[sp,#784]
 cmp x10,x26
 b.lt .Lgrid_surface_pressure
 mov x0,x28
 ARG x1,35
 ldr x2,[sp,#720]
 bl memcpy
 ADDRESS x0,x20,5144
 ADDRESS x1,x20,5224
 ARG x2,3
 ARG x3,4
 ldr x4,[sp,#744]
 ldr x5,[sp,#752]
 ARG x6,26
 mov x7,x28
 ARG x9,27
 str x9,[sp]
 bl md2asm_radcfg_gphpre
 COMPLETED_CHILD 0
 ARG x0,35
 mov x1,x28
 ldr x2,[sp,#720]
 bl memcpy
 ADDRESS x0,x20,5144
 ARG x1,3
 ARG x2,4
 ADDRESS x3,x20,5224
 mov x4,#0
 mov x5,#0
 mov x6,#0
 mov x7,#0
 stp xzr,xzr,[sp]
 ldr x9,[sp,#728]
 str x9,[sp,#16]
 ldr x10,[sp,#720]
 add x9,x9,x10
 str x9,[sp,#24]
 str xzr,[sp,#32]
 ARG x9,10
 str x9,[sp,#40]
 add x9,sp,#772
 str x9,[sp,#48]
 str xzr,[sp,#56]
 bl md2asm_radcfg_gprcp
 COMPLETED_CHILD 1
 ADDRESS x0,x22,1608728
 ADDRESS x1,x22,4100048
 ADDRESS x2,x22,1359328
 ARG x3,3
 ARG x4,4
 ADDRESS x5,x20,5144
 ARG x6,38
 ARG x7,34
 add x9,sp,#768
 str x9,[sp]
 ARG x9,39
 str x9,[sp,#8]
 bl md2asm_cos_sza
 COMPLETED_CHILD 2
 add x17,sp,#1600
 ARG x9,2
 str x9,[x17,#0]
 ARG x9,3
 str x9,[x17,#8]
 ARG x9,4
 str x9,[x17,#16]
 ARG x9,5
 str x9,[x17,#48]
 ARG x9,26
 str x9,[x17,#88]
 ARG x9,27
 str x9,[x17,#96]
 ARG x9,13
 str x9,[x17,#104]
 ARG x9,11
 str x9,[x17,#120]
 ARG x9,12
 str x9,[x17,#128]
 ARG x9,39
 str x9,[x17,#272]
 ARG x9,38
 str x9,[x17,#280]
 ARG x9,7
 str x9,[x17,#408]
 ARG x9,22
 str x9,[x17,#416]
 ARG x9,23
 str x9,[x17,#424]
 ARG x9,24
 str x9,[x17,#432]
 ARG x9,25
 str x9,[x17,#440]
 ARG x9,28
 str x9,[x17,#448]
 ARG x9,41
 str x9,[x17,#456]
 ARG x9,42
 str x9,[x17,#464]
 ARG x9,40
 str x9,[x17,#472]
 ARG x9,29
 str x9,[x17,#480]
 ARG x9,30
 str x9,[x17,#488]
 ARG x9,31
 str x9,[x17,#496]
 ARG x9,32
 str x9,[x17,#504]
 ARG x9,33
 str x9,[x17,#512]
 ARG x9,36
 str x9,[x17,#520]
 ARG x9,37
 str x9,[x17,#528]
 ADDRESS x9,x20,5144
 str x9,[x17,#24]
 ADDRESS x9,x21,5888
 str x9,[x17,#32]
 ADDRESS x9,x21,6176
 str x9,[x17,#40]
 ADDRESS x9,x20,5224
 str x9,[x17,#64]
 ADDRESS x9,x22,1359328
 str x9,[x17,#72]
 add x9,sp,#768
 str x9,[x17,#56]
 adrp x9,:got:__yomct3_MOD_nstep
 ldr x9,[x9,:got_lo12:__yomct3_MOD_nstep]
 str x9,[x17,#80]
 ATMOSPHERIC_FIELD 14,800032
 ATMOSPHERIC_FIELD 17,800048
 ATMOSPHERIC_FIELD 18,800040
 ATMOSPHERIC_FIELD 19,800176
 SURFACE_FIELD 20,16,6232,8,6176
 SURFACE_FIELD 21,16,6248,8,6176
 SURFACE_FIELD 22,18,6808,8,0
 SURFACE_FIELD 23,18,6816,8,0
 SURFACE_FIELD 24,15,5952,8,5888
 SURFACE_FIELD 26,17,6552,8,0
 SURFACE_FIELD 27,17,6512,8,0
 SURFACE_FIELD 28,19,9152,0,0
 SURFACE_FIELD 29,19,8968,0,0
 SURFACE_FIELD 31,16,6240,8,6176
 SURFACE_FIELD 32,19,8976,0,0
 SURFACE_FIELD 33,19,8992,0,0
 SURFACE_FIELD 36,19,8960,0,0
 SURFACE_FIELD 37,19,9104,0,0
 SURFACE_FIELD 38,19,9080,0,0
 SURFACE_FIELD 39,19,9112,0,0
 SURFACE_FIELD 40,19,9072,0,0
 SURFACE_FIELD 41,19,9088,0,0
 SURFACE_FIELD 42,19,9096,0,0
 SURFACE_FIELD 43,19,9128,0,0
 SURFACE_FIELD 44,19,9136,0,0
 SURFACE_FIELD 45,19,9144,0,0
 SURFACE_FIELD 46,19,8984,0,0
 SURFACE_FIELD 47,19,9168,0,0
 SURFACE_FIELD 48,20,10608,0,0
 SURFACE_FIELD 49,20,10616,0,0
 SURFACE_FIELD 50,20,10624,0,0
 SURFACE_FIELD 67,21,13384,0,0

 ARG x9,9
 ADDRESS x10,x22,1573360
 ldrsw x10,[x10]
 sub x10,x10,#1
 madd x9,x10,x27,x9
 str x9,[x17,#200]
 // The rank-two albedo section retains the complete original horizontal pitch.
 add x12,sp,#2400
 ARG x9,19
 ldrsw x10,[x21,#9304]
 sub x10,x10,#1
 madd x9,x10,x27,x9
 str x9,[x12]
 add x9,x23,#1
 neg x9,x9
 str x9,[x12,#8]
 mov x9,#8
 str x9,[x12,#16]
 str xzr,[x12,#24]
 mov w9,#2
 strb w9,[x12,#28]
 mov w9,#3
 strb w9,[x12,#29]
 mov x9,#8
 str x9,[x12,#32]
 mov x9,#1
 str x9,[x12,#40]
 str x9,[x12,#48]
 str x23,[x12,#56]
 str x23,[x12,#64]
 str x9,[x12,#72]
 ldr w9,[sp,#776]
 str x9,[x12,#80]
 str x12,[x17,#240]
 mov x10,#8
.Lgrid_radpar_stack:
 ldr x9,[x17,x10,lsl #3]
 sub x11,x10,#8
 str x9,[sp,x11,lsl #3]
 add x10,x10,#1
 cmp x10,#68
 b.lt .Lgrid_radpar_stack
 ldp x0,x1,[x17]
 ldp x2,x3,[x17,#16]
 ldp x4,x5,[x17,#32]
 ldp x6,x7,[x17,#48]
 bl md2asm_radpar
 COMPLETED_CHILD 3
 ARG x9,43
 ARG x10,44
 mov x11,#0
.Lgrid_rain_level:
 mov x12,x25
.Lgrid_rain_column:
 madd x13,x11,x23,x12
 str xzr,[x9,x13,lsl #3]
 str xzr,[x10,x13,lsl #3]
 add x12,x12,#1
 cmp x12,x26
 b.lt .Lgrid_rain_column
 add x11,x11,#1
 cmp x11,x24
 b.lt .Lgrid_rain_level
 mov x0,x28
 bl free
 ldr x18,[sp,#688]
 add x16,sp,#512
 ldp x19,x20,[x16,#0]
 ldp x21,x22,[x16,#16]
 ldp x23,x24,[x16,#32]
 ldp x25,x26,[x16,#48]
 ldp x27,x28,[x16,#64]
 ldp x29,x30,[x16,#80]
 ldp d8,d9,[x16,#96]
 ldp d10,d11,[x16,#112]
 ldp d12,d13,[x16,#128]
 ldp d14,d15,[x16,#144]
 add sp,sp,#1,lsl #12
 ret
.Lgrid_reject:
 bl abort
 brk #0
.size md2asm_radcfg,.-md2asm_radcfg
.section .rodata
.p2align 3
.Lgrid_log_min: .double 9.2
.Lgrid_log_max: .double 11.7
.section .note.GNU-stack,"",%progbits

.bss
.p2align 3
.global md2asm_radcfg_private_child_counts
.hidden md2asm_radcfg_private_child_counts
.type md2asm_radcfg_private_child_counts,%object
.size md2asm_radcfg_private_child_counts,32
md2asm_radcfg_private_child_counts:
.zero 32

.text
.p2align 4
.global md2asm_radcfg_private_child_count_get
.type md2asm_radcfg_private_child_count_get,%function
md2asm_radcfg_private_child_count_get:
 cmp w0,#4
 b.hs .Lgrid_count_invalid
 adrp x9,md2asm_radcfg_private_child_counts
 add x9,x9,:lo12:md2asm_radcfg_private_child_counts
 ldr x0,[x9,x0,lsl #3]
 ret
.Lgrid_count_invalid:
 mov x0,#0
 ret
.size md2asm_radcfg_private_child_count_get,.-md2asm_radcfg_private_child_count_get

/* GPU physical setup route. Original interface and ordered arithmetic are preserved.
 * Contract: skills/md2asm-gpu/references/openifs/setup/physical_setup.md
 * Original source: src/openifs/setup/model_clock_initialization.S
 */
// Original contract: skills/md2asm/references/openifs/setup/model_clock_initialization.md
#include "../../support/gpu/preserved_scalar_calls.inc.S"
.arch armv8-a
.text
.p2align 4
.global md2asm_initialize_model_clock
.type md2asm_initialize_model_clock,%function
md2asm_initialize_model_clock:
 cbz x0,.Lclock_reject
 cbz x1,.Lclock_reject
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lclock_reject
 cmp x2,#360
 b.lo .Lclock_reject
 adds x9,x0,#40
 b.cs .Lclock_reject
 adds x11,x1,#360
 b.cs .Lclock_reject
 cmp x0,x11
 b.hs .Lclock_disjoint
 cmp x1,x9
 b.lo .Lclock_reject
.Lclock_disjoint:
 mrs x9,fpcr
 cbnz x9,.Lclock_reject
 ldr w9,[x1,#16]
 cbnz w9,.Lclock_reject
 ldp w3,w4,[x0]
 mov w9,#10000
 sdiv w5,w3,w9
 msub w8,w5,w9,w3
 sub w9,w5,#1901
 cmp w9,#198
 b.hi .Lclock_reject
 mov w9,#100
 udiv w6,w8,w9
 msub w7,w6,w9,w8
 sub w11,w6,#1
 cmp w11,#11
 b.hi .Lclock_reject
 adr x9,.Lclock_month_lengths
 ldrb w8,[x9,w11,uxtw]
 cmp w6,#2
 b.ne .Lclock_day_bound
 tst w5,#3
 b.ne .Lclock_day_bound
 mov w9,#100
 udiv w11,w5,w9
 msub w12,w11,w9,w5
 cbnz w12,.Lclock_leap
 tst w11,#3
 b.ne .Lclock_day_bound
.Lclock_leap:
 add w8,w8,#1
.Lclock_day_bound:
 cbz w7,.Lclock_reject
 cmp w7,w8
 b.hi .Lclock_reject
 ldr w9,.Lclock_day_seconds_i
 cmp w4,w9
 b.hs .Lclock_reject
 ldr x9,[x0,#8]
 ldr x11,.Lclock_step
 cmp x9,x11
 b.ne .Lclock_reject
 ldr x9,[x0,#32]
 cmp x9,x11
 b.eq .Lclock_trajectory_valid
 movz x12,#0xbff0,lsl #48
 cmp x9,x12
 b.ne .Lclock_reject
.Lclock_trajectory_valid:
 ldr w9,[x0,#24]
 cbnz w9,.Lclock_reject
 ldrb w9,[x0,#16]
 cmp w9,#116
 b.ne .Lclock_reject
 mov w10,#0
 mov w11,#0
 mov w12,#0
 mov w13,#17
 mov w14,#10
.Lclock_stop_parse:
 ldrb w9,[x0,w13,uxtw]
 cmp w9,#32
 b.eq .Lclock_stop_space
 cbnz w12,.Lclock_reject
 sub w9,w9,#48
 cmp w9,#9
 b.hi .Lclock_reject
 add w11,w11,#1
 cmp w11,#2
 b.hi .Lclock_reject
 madd w10,w10,w14,w9
 b .Lclock_stop_next
.Lclock_stop_space:
 mov w12,#1
.Lclock_stop_next:
 add w13,w13,#1
 cmp w13,#24
 b.lo .Lclock_stop_parse
 cbz w11,.Lclock_reject
 sub w9,w10,#1
 cmp w9,#24
 b.hi .Lclock_reject
 mov w14,w5
 mov w15,w6
 cmp w6,#3
 b.ge .Lclock_adjusted_date
 sub w14,w5,#1
 add w15,w6,#12
.Lclock_adjusted_date:
 mov w9,#100
 sdiv w16,w14,w9
 mov w9,#4
 sdiv w17,w16,w9
 sub w16,w17,w16
 add w16,w16,#2
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d0,destination,w14,general,w16,240,zero
 ldr d1,.Lclock_year_factor
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w17,destination,d0,real,x16,0,zero
 add w16,w16,w17
 add w15,w15,#1
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d0,destination,w15,general,w16,248,zero
 ldr d1,.Lclock_month_factor
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_physical_setup_numeric_cell_host,24,w17,destination,d0,real,x16,0,zero
 add w16,w16,w17
 add w16,w16,w7
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d0,destination,w16,general,w16,256,zero
 ldr d1,.Lclock_julian_offset
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d1,real,x16,0,d0
 ldr d1,.Lclock_epoch
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,1,d0,destination,d0,real,x16,0,d1
 ldr d1,.Lclock_day_seconds
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,2,d0,destination,d0,real,x16,0,d1
 md2asm_gpu_preserved_scalar md2asm_gpu_startup_integer_cell_host,18,d1,destination,w4,general,w16,160,zero
 md2asm_gpu_preserved_scalar md2asm_gpu_lake_controller_cell_host,0,d0,destination,d0,real,x16,0,d1
 stp w3,w4,[x1]
 str d0,[x1,#8]
 str wzr,[x1,#20]
 str w10,[x1,#24]
 mov w9,#1
 str w9,[x1,#28]
 mov w9,#-999
 str w9,[x1,#36]
 ldr d1,[x0,#8]
 str d1,[x1,#40]
 add x3,x1,#48
 stp wzr,w10,[x3]
 ldr x4,[x0,#16]
 str x4,[x3,#8]
 str xzr,[x3,#16]
 str wzr,[x3,#24]
 str xzr,[x3,#32]
 str d0,[x3,#40]
 add x4,x3,#48
 mov w5,#11
.Lclock_zero_initial_solar:
 str xzr,[x4],#8
 subs w5,w5,#1
 b.ne .Lclock_zero_initial_solar
 stp xzr,xzr,[x3,#168]
 stp xzr,xzr,[x3,#184]
 stp d1,d1,[x3,#200]
 stp xzr,xzr,[x3,#216]
 stp xzr,xzr,[x3,#232]
 stp xzr,xzr,[x3,#248]
 stp xzr,xzr,[x3,#264]
 stp xzr,xzr,[x3,#280]
 stp xzr,xzr,[x3,#296]
 mov w0,#0
 ret
.Lclock_reject:
 mov w0,#2
 ret
.size md2asm_initialize_model_clock,.-md2asm_initialize_model_clock
.section .rodata
.p2align 3
.Lclock_step:
 .double 3600.0
.Lclock_year_factor:
 .double 365.25
.Lclock_month_factor:
 .double 30.601
.Lclock_julian_offset:
 .double 1720994.5
.Lclock_epoch:
 .double 2451545.0
.Lclock_day_seconds:
 .double 86400.0
.Lclock_day_seconds_i:
 .word 86400
.Lclock_month_lengths:
 .byte 31,28,31,30,31,30,31,31,30,31,30,31
.section .note.GNU-stack,"",%progbits

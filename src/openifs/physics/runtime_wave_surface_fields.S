/* Contract: skills/md2asm/references/openifs/physics/wave_surface_fields.md
 * Direct EC_PHYS wave arithmetic. The typed adapter is a separate caller.
 * ABI: x0 points to the 432-byte view table; x1 is its capacity in bytes.
 * Header: int32 P,first,last,NATMFLX,LWCOURNW,LWCUR; bytes24..31 reserved zero;
 * physical520 pointer at32; RMISSW bits at40; bytes48..63 reserved zero.
 * Twenty-three rows start at 64, each with pointer and positive byte stride.
 * Each full P-column span is mapped and belongs to its caller-owned field.
 * First and last are one-based; only active output columns are changed.
 * No heap storage is used. Return 2 refuses before public stores; return 0
 * completes all selected source operations. Preserve x18, AAPCS64 saves,
 * FPCR zero and natural arithmetic FPSR/errno from log/pow. */
.arch armv8.2-a
.text
.p2align 4
.macro WLOAD reg,row
 ldp x9,x10,[x19,#(64+16*\row)]
 madd x9,x24,x10,x9
 ldr \reg,[x9]
.endm
.macro WSTORE reg,row
 ldp x9,x10,[x19,#(64+16*\row)]
 madd x9,x24,x10,x9
 str \reg,[x9]
.endm
.macro WCONST reg,label
 adrp x9,\label
 add x9,x9,:lo12:\label
 ldr \reg,[x9]
.endm
.global md2asm_calculate_runtime_wave_surface_fields
.type md2asm_calculate_runtime_wave_surface_fields,%function
md2asm_calculate_runtime_wave_surface_fields:
 sub sp,sp,#256
 stp x19,x20,[sp]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 stp x29,x30,[sp,#80]
 str x18,[sp,#96]
 stp d8,d9,[sp,#112]
 stp d10,d11,[sp,#128]
 stp d12,d13,[sp,#144]
 stp d14,d15,[sp,#160]
 cbz x0,.Lwave_reject
 tst x0,#7
 b.ne .Lwave_reject
 cmp x1,#432
 b.lo .Lwave_reject
 adds x9,x0,#432
 b.cs .Lwave_reject
 mrs x9,fpcr
 cbnz x9,.Lwave_reject
 mov x19,x0
 ldrsw x21,[x19]
 cmp x21,#1
 b.lt .Lwave_reject
 cmp x21,#128
 b.gt .Lwave_reject
 ldrsw x24,[x19,#4]
 cmp x24,#1
 b.lt .Lwave_reject
 ldrsw x23,[x19,#8]
 cmp x23,x24
 b.lt .Lwave_reject
 cmp x23,x21
 b.gt .Lwave_reject
 sub x24,x24,#1
 ldr w25,[x19,#12]
 sub w9,w25,#1
 cmp w9,#2
 b.hi .Lwave_reject
 ldr w26,[x19,#16]
 cmp w26,#1
 b.hi .Lwave_reject
 ldr w27,[x19,#20]
 cmp w27,#1
 b.hi .Lwave_reject
 ldr x9,[x19,#24]
 cbnz x9,.Lwave_reject
 ldp x9,x10,[x19,#48]
 orr x9,x9,x10
 cbnz x9,.Lwave_reject
 ldr x20,[x19,#32]
 cbz x20,.Lwave_reject
 tst x20,#7
 b.ne .Lwave_reject
 adds x9,x20,#520
 b.cs .Lwave_reject
 /* Validate every selected view before any numerical output changes. */
 mov x22,#0
.Lwave_view_loop:
 cmp x22,#23
 b.eq .Lwave_views_ready
 cmp x22,#3
 b.lt .Lwave_view_required
 cmp x22,#4
 b.gt .Lwave_other_views
 cmp w25,#3
 b.ne .Lwave_view_required
 cbnz w26,.Lwave_view_next
 b .Lwave_view_required
.Lwave_other_views:
 cmp x22,#11
 b.lt .Lwave_view_required
 cmp x22,#12
 b.gt .Lwave_view_neutral
 cbz w27,.Lwave_view_next
 b .Lwave_view_required
.Lwave_view_neutral:
 cmp x22,#14
 b.gt .Lwave_view_current
 cmp w25,#3
 b.ne .Lwave_view_next
 cbz w26,.Lwave_view_next
 b .Lwave_view_required
.Lwave_view_current:
 cmp x22,#16
 b.gt .Lwave_view_roughness
 cbnz w27,.Lwave_view_required
 cmp w25,#3
 b.ne .Lwave_view_next
 cbz w26,.Lwave_view_next
 b .Lwave_view_required
.Lwave_view_roughness:
 cmp x22,#17
 b.ne .Lwave_view_required
 cmp w25,#3
 b.ne .Lwave_view_next
 cbnz w26,.Lwave_view_next
.Lwave_view_required:
 add x9,x19,#64
 add x9,x9,x22,lsl#4
 ldp x10,x11,[x9]
 cbz x10,.Lwave_reject
 tst x10,#7
 b.ne .Lwave_reject
 cbz x11,.Lwave_reject
 tst x11,#7
 b.ne .Lwave_reject
 sub x12,x21,#1
 umulh x13,x12,x11
 cbnz x13,.Lwave_reject
 mul x12,x12,x11
 adds x12,x12,#8
 b.cs .Lwave_reject
 adds x12,x10,x12
 b.cs .Lwave_reject
.Lwave_view_next:
 add x22,x22,#1
 b .Lwave_view_loop
.Lwave_views_ready:
 /* Source loop begins only after every selected control/span passes. */
 ldr d14,[x20,#112]
 WCONST d0,.Lwave_ten
 fmul d14,d0,d14
.Lwave_column:
 cmp x24,x23
 b.ge .Lwave_success
 WLOAD d8,0
 WLOAD d0,1
 ldr d1,[x20,#184]
 fmul d1,d1,d0
 WLOAD d2,2
 ldr d3,[x20,#240]
 fmul d2,d3,d2
 fmov d3,#1.0
 fadd d2,d3,d2
 fmul d1,d1,d2
 fdiv d8,d8,d1
 fdiv d9,d3,d8
 cmp w25,#3
 b.ne .Lwave_stress
 cbnz w26,.Lwave_neutral
.Lwave_stress:
 WLOAD d10,3
 WLOAD d11,4
 cmp w25,#2
 b.eq .Lwave_stress_square
 fmul d10,d10,d9
 fmul d11,d11,d9
.Lwave_stress_square:
 cmp w25,#3
 b.ne .Lwave_form_speed
 WLOAD d1,17
 fdiv d0,d14,d1
 bl log
 ldr x18,[sp,#96]
 WCONST d1,.Lwave_kappa
 fdiv d13,d0,d1
.Lwave_form_speed:
 fmul d0,d10,d10
 fmul d1,d11,d11
 fadd d0,d0,d1
 cmp w25,#2
 b.eq .Lwave_half_power
 WCONST d1,.Lwave_quarter
 b .Lwave_power
.Lwave_half_power:
 WCONST d1,.Lwave_half
.Lwave_power:
 bl pow
 ldr x18,[sp,#96]
 WCONST d1,.Lwave_min_speed
 fmaxnm d12,d1,d0
 fdiv d10,d10,d12
 fdiv d11,d11,d12
 cmp w25,#3
 b.ne .Lwave_store_wind
 fmul d10,d10,d13
 fmul d11,d11,d13
 b .Lwave_store_wind
.Lwave_neutral:
 WLOAD d10,13
 WLOAD d0,15
 fsub d10,d10,d0
 WLOAD d11,14
 WLOAD d0,16
 fsub d11,d11,d0
.Lwave_store_wind:
 WSTORE d10,5
 WSTORE d11,6
 WLOAD d0,18
 ldr d1,[x20,#240]
 fneg d1,d1
 fmul d1,d1,d0
 WLOAD d0,19
 ldr d2,[x20,#200]
 fdiv d0,d0,d2
 WLOAD d2,1
 fdiv d0,d0,d2
 fsub d0,d1,d0
 ldr d1,[x20,#112]
 fmul d0,d1,d0
 fmul d0,d0,d9
 fcmp d0,#0.0
 b.le .Lwave_no_gust
 WCONST d1,.Lwave_thousand
 fmul d0,d1,d0
 WCONST d1,.Lwave_third
 bl pow
 ldr x18,[sp,#96]
 b .Lwave_store_gust
.Lwave_no_gust:
 fmov d0,xzr
.Lwave_store_gust:
 WSTORE d8,7
 WSTORE d0,8
 WLOAD d0,20
 WCONST d1,.Lwave_half
 fcmp d0,d1
 b.ls .Lwave_sea
 b .Lwave_land
.Lwave_sea:
 WLOAD d0,21
 b .Lwave_store_ice
.Lwave_land:
 ldr d0,[x19,#40]
.Lwave_store_ice:
 WSTORE d0,9
 WLOAD d0,22
 WSTORE d0,10
 cbz w27,.Lwave_next_column
 WLOAD d0,15
 WSTORE d0,11
 WLOAD d0,16
 WSTORE d0,12
.Lwave_next_column:
 add x24,x24,#1
 b .Lwave_column
.Lwave_success:
 mov w0,#0
 b .Lwave_return
.Lwave_reject:
 mov w0,#2
.Lwave_return:
 ldp d14,d15,[sp,#160]
 ldp d12,d13,[sp,#144]
 ldp d10,d11,[sp,#128]
 ldp d8,d9,[sp,#112]
 ldr x18,[sp,#96]
 ldp x29,x30,[sp,#80]
 ldp x27,x28,[sp,#64]
 ldp x25,x26,[sp,#48]
 ldp x23,x24,[sp,#32]
 ldp x21,x22,[sp,#16]
 ldp x19,x20,[sp]
 add sp,sp,#256
 ret
.size md2asm_calculate_runtime_wave_surface_fields,.-md2asm_calculate_runtime_wave_surface_fields
.section .rodata
.p2align 3
.Lwave_quarter: .quad 0x3fd0000000000000
.Lwave_half: .quad 0x3fe0000000000000
.Lwave_min_speed: .quad 0x3f1a36e2eb1c432d
.Lwave_ten: .quad 0x4024000000000000
.Lwave_kappa: .quad 0x3fd999999999999a
.Lwave_thousand: .quad 0x408f400000000000
.Lwave_third: .quad 0x3fd5555555555555
.section .note.GNU-stack,"",%progbits

/* Shared default and original-source selection: skills/md2asm/references/openifs/surface/runtime_surface_turbulence.md. */
#ifndef MD2ASM_SURFACE_EXCHANGE_CONTROLLER_ENTRY
#define MD2ASM_SURFACE_EXCHANGE_CONTROLLER_ENTRY md2asm_surface_exchange_controller_sea_r2_7358525
#endif
#ifndef MD2ASM_SURFACE_SATURATION_ENTRY
#define MD2ASM_SURFACE_SATURATION_ENTRY md2asm_vsurf_sea_derivative_r2_7358525
#endif
/* Direct selected SURFEXCDRIVER_CTL body from OpenIFS 48.1.1.
 * Physics formulations/openifs/surface/surface_physical_updates.md.
 * Contract skills/md2asm/references/openifs/surface/surface_physical_updates.md.
 * Frozen numerical body and current private interfaces are preserved. */
.text
.p2align 4
.macro ARG reg,arg
 ldr \reg,[x19,#(\arg*8)]
.endm
.macro IN reg,arg
 ARG x9,\arg
 ldr x9,[x9]
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro OUT reg,arg
 ARG x9,\arg
 ldr x9,[x9]
 str \reg,[x9,x20,lsl #3]
.endm
.macro IN2 reg,arg,col=x21
 ARG x9,\arg
 ldr x10,[x9,#64]
 ldr x9,[x9]
 madd x10,\col,x10,x20
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro OUT2 reg,arg,col=x21
 ARG x9,\arg
 ldr x10,[x9,#64]
 ldr x9,[x9]
 madd x10,\col,x10,x20
 str \reg,[x9,x10,lsl #3]
.endm
.macro IN3 reg,arg,second,third
 ARG x9,\arg
 ldr x10,[x9,#64]
 ldr x11,[x9,#88]
 ldr x9,[x9]
 mov x12,#(\second-1)
 madd x10,x12,x10,x20
 mov x12,#(\third-1)
 madd x10,x12,x11,x10
 ldr \reg,[x9,x10,lsl #3]
.endm
.macro OUT3 reg,arg,second,third
 ARG x9,\arg
 ldr x10,[x9,#64]
 ldr x11,[x9,#88]
 ldr x9,[x9]
 sub x12,\second,#1
 madd x10,x12,x10,x20
 mov x12,#(\third-1)
 madd x10,x12,x11,x10
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
 adr x9,.Lsc_\name
 ldr \reg,[x9]
.endm
.macro CALL name
 str x18,[sp,#2424]
 bl \name
 ldr x18,[sp,#2424]
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
.macro DARG dest,id
 mov x9,#(\id*128)
 add x9,x27,x9
 PLACE \dest
.endm
.macro SARG dest,offset
 add x9,sp,#\offset
 PLACE \dest
.endm
.macro VIEW_BODY dest,slot
 add x13,sp,#(3072+\slot*64)
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
.macro VARG dest,arg,slot,col=x21
 ARG x9,\arg
 ldr x10,[x9,#64]
 mul x10,\col,x10
 ldr x9,[x9]
 add x9,x9,x10,lsl #3
 VIEW_BODY \dest,\slot
.endm
.macro LVIEW dest,id,slot,col=x21
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
.macro CHECK arg,rank,kind,element,min2=1,min3=1
 ARG x9,\arg
 cbz x9,.Lsc_reject
 ldr x10,[x9,#16]
 cmp x10,#\element
 b.ne .Lsc_reject
 ldr x10,[x9,#32]
 cmp x10,#\element
 b.ne .Lsc_reject
 ldrb w10,[x9,#28]
 cmp w10,#\rank
 b.ne .Lsc_reject
 ldrb w10,[x9,#29]
 cmp w10,#\kind
 b.ne .Lsc_reject
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lsc_reject
 ldp x10,x11,[x9,#48]
 cmp x10,#1
 b.ne .Lsc_reject
 cmp x11,x22
 b.lt .Lsc_reject
 ldr x12,[x9,#8]
 add x12,x12,x10
 .if \rank>1
  ldr x13,[x9,#64]
  cmp x13,x11
  b.ne .Lsc_reject
  ldp x14,x15,[x9,#72]
  cmp x14,#1
  b.ne .Lsc_reject
  cmp x15,#\min2
  b.lt .Lsc_reject
  madd x12,x14,x13,x12
  .if \rank>2
   mul x13,x13,x15
   ldr x16,[x9,#88]
   cmp x13,x16
   b.ne .Lsc_reject
   ldp x14,x15,[x9,#96]
   cmp x14,#1
   b.ne .Lsc_reject
   cmp x15,#\min3
   b.lt .Lsc_reject
   madd x12,x14,x16,x12
  .endif
 .endif
 cbnz x12,.Lsc_reject
 ldr x10,[x9]
 cbz x10,.Lsc_reject
 tst x10,#(\element-1)
 b.ne .Lsc_reject
.endm
.global MD2ASM_SURFACE_EXCHANGE_CONTROLLER_ENTRY
.type MD2ASM_SURFACE_EXCHANGE_CONTROLLER_ENTRY,%function
MD2ASM_SURFACE_EXCHANGE_CONTROLLER_ENTRY:
 mov x16,sp
 sub sp,sp,#4,lsl #12
 add x17,sp,#1024
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
 add x19,sp,#1280
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 mov x10,#8
.Lsc_arguments:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#134
 b.lt .Lsc_arguments
 ldr x9,[x16]
 str x9,[sp,#2384]
 cmp x9,#1
 b.ne .Lsc_reject
 mrs x9,fpcr
 cbnz x9,.Lsc_reject
 ARG x9,3
 ldr w22,[x9]
 cmp w22,#1
 b.lt .Lsc_reject
 cmp w22,#4096
 b.gt .Lsc_reject
 ARG x9,1
 ldrsw x23,[x9]
 sub x23,x23,#1
 cmp x23,#0
 b.lt .Lsc_reject
 ARG x9,2
 ldrsw x24,[x9]
 cmp x24,x22
 b.gt .Lsc_reject
 cmp x24,x23
 b.le .Lsc_return_empty
 ARG x9,4
 ldr w9,[x9]
 cmp w9,#4
 b.ne .Lsc_reject
 ARG x9,5
 ldr w9,[x9]
 cmp w9,#9
 b.ne .Lsc_reject
 ARG x9,8
 ldr w9,[x9]
 cmp w9,#0
 b.lt .Lsc_reject
 cmp w9,#0
 cset w10,eq
 str w10,[sp,#2376]
 cmp w9,#3
 mov w10,#3
 mov w11,#1
 csel w10,w10,w11,le
 str w10,[sp,#2372]
 add x27,sp,#1,lsl #12
 CHECK 22,1,1,4
 CHECK 23,1,1,4
 CHECK 24,1,1,4
 CHECK 25,1,3,8
 CHECK 26,1,3,8
 CHECK 27,1,3,8
 CHECK 28,1,3,8
 CHECK 29,1,3,8
 CHECK 30,1,3,8
 CHECK 31,1,3,8
 CHECK 34,1,3,8
 CHECK 36,1,3,8
 CHECK 37,1,3,8
 CHECK 38,1,3,8
 CHECK 39,1,3,8
 CHECK 40,1,3,8
 CHECK 41,1,3,8
 CHECK 42,1,3,8
 CHECK 43,1,3,8
 CHECK 44,1,3,8
 CHECK 45,1,3,8
 CHECK 46,1,3,8
 CHECK 47,1,3,8
 CHECK 48,1,3,8
 CHECK 49,1,3,8
 CHECK 50,1,3,8
 CHECK 51,1,3,8
 CHECK 53,1,3,8
 CHECK 54,1,3,8
 CHECK 55,1,3,8
 CHECK 56,1,3,8
 CHECK 57,1,3,8
 CHECK 58,1,3,8
 CHECK 59,1,3,8
 CHECK 60,1,3,8
 CHECK 61,1,3,8
 CHECK 64,1,1,4
 CHECK 74,1,3,8
 CHECK 75,1,3,8
 CHECK 90,1,3,8
 CHECK 91,1,3,8
 CHECK 92,1,3,8
 CHECK 93,1,3,8
 CHECK 94,1,3,8
 CHECK 95,1,3,8
 CHECK 96,1,3,8
 CHECK 97,1,3,8
 CHECK 98,1,3,8
 CHECK 99,1,3,8
 CHECK 100,1,3,8
 CHECK 101,1,3,8
 CHECK 102,1,3,8
 CHECK 103,1,3,8
 CHECK 104,1,3,8
 CHECK 105,1,3,8
 CHECK 106,1,3,8
 CHECK 107,1,3,8
 CHECK 108,1,3,8
 CHECK 109,1,3,8
 CHECK 110,1,3,8
 CHECK 111,1,3,8
 CHECK 112,1,3,8
 CHECK 113,1,3,8
 CHECK 114,1,3,8
 CHECK 115,1,3,8
 CHECK 116,1,3,8
 CHECK 32,2,3,8,1
 CHECK 33,2,3,8,1
 CHECK 52,2,3,8,1
 CHECK 62,2,3,8,4
 CHECK 63,2,3,8,4
 CHECK 65,2,3,8,9
 CHECK 66,2,3,8,9
 CHECK 67,2,3,8,9
 CHECK 68,2,3,8,9
 CHECK 69,2,3,8,9
 CHECK 70,2,3,8,9
 CHECK 71,2,3,8,9
 CHECK 72,2,3,8,2
 CHECK 73,2,3,8,2
 CHECK 76,2,3,8,9
 CHECK 77,2,3,8,9
 CHECK 78,2,3,8,9
 CHECK 79,2,3,8,9
 CHECK 80,2,3,8,9
 CHECK 81,2,3,8,9
 CHECK 82,2,3,8,9
 CHECK 83,2,3,8,9
 CHECK 84,2,3,8,9
 CHECK 85,2,3,8,9
 CHECK 86,2,3,8,9
 CHECK 87,2,3,8,9
 CHECK 88,2,3,8,9
 CHECK 89,2,3,8,9
 CHECK 122,2,3,8,10
 // Nonempty diagnostics retain their source dimensions and bounds.
 mov x26,#117
.Lsc_diagnostic_shape:
 ldr x9,[x19,x26,lsl #3]
 ldp x10,x11,[x9,#48]
 cmp x11,x10
 b.lt .Lsc_next_diagnostic
 ldp x12,x13,[x9,#72]
 cmp x13,x12
 b.lt .Lsc_next_diagnostic
 ldp x14,x15,[x9,#96]
 cmp x15,x14
 b.lt .Lsc_next_diagnostic
 ldr x10,[x9]
 cbz x10,.Lsc_reject
.Lsc_next_diagnostic:
 add x26,x26,#1
 cmp x26,#122
 b.lt .Lsc_diagnostic_shape
 // Entry logging uses the model's actual state.
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lsc_reject
 str w9,[sp,#2380]
 cbz w9,.Lsc_entry_hook_done
 adr x0,.Lsc_hook_name
 add x1,sp,#2448
 str wzr,[x1]
 add x2,sp,#2432
 mov x3,#39
 CALL __yomhook_MOD_dr_hook_default8
.Lsc_entry_hook_done:
 mov x0,x22
 mov x1,#2352
 CALL calloc
 cbz x0,.Lsc_reject
 mov x25,x0
 str x25,[sp,#2464]
 mov x26,#0
.Lsc_local_descriptors:
 adr x9,.Lsc_local_specs
 mov x10,#20
 madd x9,x26,x10,x9
 ldp w10,w11,[x9]
 ldp w12,w14,[x9,#8]
 ldr w15,[x9,#16]
 add x13,x27,x26,lsl #7
 str x25,[x13]
 mov x16,#8
 cmp w12,#1
 mov x17,#4
 csel x16,x17,x16,eq
 str x16,[x13,#16]
 str x16,[x13,#32]
 lsl x17,x12,#8
 orr x17,x17,x11
 lsl x17,x17,#32
 str x17,[x13,#24]
 mov x17,#1
 str x17,[x13,#40]
 str x17,[x13,#48]
 cmp x26,#54
 mov x17,#9
 csel x17,x17,x22,eq
 str x17,[x13,#56]
 mov x16,#-1
 cmp w11,#1
 b.eq .Lsc_local_bias
 str x22,[x13,#64]
 mov x17,#1
 str x17,[x13,#72]
 str x14,[x13,#80]
 sub x16,x16,x22
 cmp w11,#2
 b.eq .Lsc_local_bias
 mul x17,x22,x14
 str x17,[x13,#88]
 sub x16,x16,x17
 mov x17,#1
 str x17,[x13,#96]
 str x15,[x13,#104]
.Lsc_local_bias:
 str x16,[x13,#8]
 mul x10,x10,x22
 add x25,x25,x10,lsl #3
 add x26,x26,#1
 cmp x26,#55
 b.lt .Lsc_local_descriptors
 // Scalar rounded constants and source configuration.
 ARG x9,126
 ldr d0,[x9,#104]
 CONST d1,one
 fdiv d0,d1,d0
 str d0,[sp,#2392]
 ARG x9,124
 ldr d1,[x9]
 CONST d0,ten
 fdiv d0,d0,d1
 str d0,[sp,#2400]
 CONST d0,forty
 fdiv d0,d0,d1
 str d0,[sp,#2408]
 CONST d0,station_roughness
 fdiv d0,d0,d1
 str d0,[sp,#2416]
 // Air density, vegetation mapping, leaf area and total snow depth.
 ROWS .Lsc_prepare_rows
 IN d0,41
 IN d1,38
 ARG x9,126
 ldr d2,[x9,#32]
 fmul d1,d2,d1
 IN d2,39
 ARG x9,126
 ldr d3,[x9,#48]
 fmul d2,d3,d2
 CONST d3,one
 fadd d2,d3,d2
 fmul d1,d1,d2
 fdiv d0,d0,d1
 LS d0,0
 ARG x9,22
 ldr x9,[x9]
 ldr w11,[x9,x20,lsl #2]
 ldr x9,[x27,#(4*128)]
 mov x10,#3
 madd x10,x10,x22,x20
 str w11,[x9,x10,lsl #2]
 ARG x9,24
 ldr x9,[x9]
 ldr w11,[x9,x20,lsl #2]
 mov x10,#5
 madd x10,x10,x22,x20
 ldr x9,[x27,#(4*128)]
 str w11,[x9,x10,lsl #2]
 mov x10,#6
 madd x10,x10,x22,x20
 str w11,[x9,x10,lsl #2]
 mov x21,#0
 IN d0,28
 LS2 d0,5
 IN d0,25
 LS2 d0,6
 mov x21,#1
 IN d0,29
 LS2 d0,5
 IN d0,26
 LS2 d0,6
 fmov d3,xzr
 mov x21,#0
 ARG x9,32
 ldr x28,[x9,#80]
.Lsc_snow_depth:
 IN2 d0,32
 IN2 d1,33
 fdiv d0,d0,d1
 fadd d3,d3,d0
 add x21,x21,#1
 cmp x21,x28
 b.lt .Lsc_snow_depth
 LS d3,7
 NEXT .Lsc_prepare_rows
 // Tile-to-vegetation map.
 ldr x9,[x27,#(54*128)]
 mov w10,#3
 mov x21,#0
.Lsc_vegetation_type_map:
 str w10,[x9,x21,lsl #2]
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_vegetation_type_map
 mov w10,#1
 str w10,[x9,#12]
 mov w10,#2
 str w10,[x9,#20]
 str w10,[x9,#24]
 // Original step-zero skin preparation.
 ldr w9,[sp,#2376]
 cbz w9,.Lsc_skin_initialised
 mov x21,#0
.Lsc_initial_skin_tile:
 ROWS .Lsc_initial_skin_row
 IN d0,45
 OUT2 d0,71
 NEXT .Lsc_initial_skin_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_initial_skin_tile
 ARG x9,127
 ldr w10,[x9,#8]
 ldr w11,[x9,#12]
 orr w10,w10,w11
 cbnz w10,.Lsc_skin_initialised
 mov x21,#0
 ROWS .Lsc_initial_sea_skin
 IN d0,44
 OUT2 d0,71
 NEXT .Lsc_initial_sea_skin
.Lsc_skin_initialised:
// Complete original roughness child: forty addresses and character length.
 PARG 0,1
 PARG 1,2
 PARG 2,3
 PARG 3,5
 PARG 4,8
 PARG 5,0
 // Explicit array: base + (offset + lower * stride) * 4; stride is checked as 1.
 ARG x9,22
 ldr x10,[x9,#8]
 ldr x11,[x9,#48]
 add x10,x10,x11
 ldr x9,[x9]
 add x9,x9,x10,lsl #2
 PLACE 6
 // Explicit array: base + (offset + lower * stride) * 4; stride is checked as 1.
 ARG x9,24
 ldr x10,[x9,#8]
 ldr x11,[x9,#48]
 add x10,x10,x11
 ldr x9,[x9]
 add x9,x9,x10,lsl #2
 PLACE 7
 // Explicit array: base + (offset + lower * stride) * 8; stride is checked as 1.
 ARG x9,25
 ldr x10,[x9,#8]
 ldr x11,[x9,#48]
 add x10,x10,x11
 ldr x9,[x9]
 add x9,x9,x10,lsl #3
 PLACE 8
 // Explicit array: base + (offset + lower * stride) * 8; stride is checked as 1.
 ARG x9,26
 ldr x10,[x9,#8]
 ldr x11,[x9,#48]
 add x10,x10,x11
 ldr x9,[x9]
 add x9,x9,x10,lsl #3
 PLACE 9
 // Explicit array: base + (offset + lower * stride) * 8; stride is checked as 1.
 ARG x9,27
 ldr x10,[x9,#8]
 ldr x11,[x9,#48]
 add x10,x10,x11
 ldr x9,[x9]
 add x9,x9,x10,lsl #3
 PLACE 10
 PARG 11,36
 PARG 12,37
 PARG 13,38
 PARG 14,39
 PARG 15,41
 PARG 16,42
 DARG 17,7
 PARG 18,67
 PARG 19,68
 PARG 20,69
 PARG 21,70
 PARG 22,53
 PARG 23,71
 PARG 24,46
 PARG 25,47
 PARG 26,65
 PARG 27,59
 PARG 28,60
 PARG 29,126
 PARG 30,127
 PARG 31,128
 PARG 32,132
 PARG 33,133
 DARG 34,8
 DARG 35,9
 DARG 36,10
 DARG 37,11
 DARG 38,12
 PARG 39,87
 ldr x9,[sp,#2384]
 str x9,[sp,#256]
 CALL md2asm_surface_roughness
 // Strict first-tie dominant selection.
 mov x21,#0
 ROWS .Lsc_dominant_initial
 IN2 d0,65
 LS d0,13
 LS d0,14
 mov w11,#1
 LIS w11,15
 LIS w11,16
 NEXT .Lsc_dominant_initial
 mov x21,#1
.Lsc_dominant_tile:
 ROWS .Lsc_dominant_row
 IN2 d0,65
 L d1,13
 fcmp d0,d1
 b.le .Lsc_dominant_low
 LS d0,13
 add w11,w21,#1
 LIS w11,15
.Lsc_dominant_low:
 cmp x21,#5
 b.eq .Lsc_dominant_next_row
 cmp x21,#6
 b.eq .Lsc_dominant_next_row
 L d1,14
 fcmp d0,d1
 b.le .Lsc_dominant_next_row
 LS d0,14
 add w11,w21,#1
 cmp x21,#2
 b.eq .Lsc_low_adjust
 cmp x21,#8
 b.ne .Lsc_low_store
.Lsc_low_adjust:
 mov x28,#7
 IN2 d1,65,x28
 fcmp d1,#0.0
 mov w12,#8
 csel w11,w12,w11,gt
 mov x28,#3
 IN2 d1,65,x28
 fcmp d1,#0.0
 mov w12,#4
 csel w11,w12,w11,gt
.Lsc_low_store:
 LIS w11,16
.Lsc_dominant_next_row:
 NEXT .Lsc_dominant_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_dominant_tile
 // Ordered logarithmic roughness blends.
 mov x21,#0
.Lsc_blend_tile:
 ROWS .Lsc_blend_row
 L2 d1,8
 ldr d0,[sp,#2400]
 fdiv d0,d0,d1
 CALL log
 fmul d0,d0,d0
 IN2 d1,65
 fdiv d0,d1,d0
 cbz x21,.Lsc_blend_m_store
 L d1,17
 fadd d0,d1,d0
.Lsc_blend_m_store:
 LS d0,17
 L2 d1,9
 ldr d0,[sp,#2400]
 fdiv d0,d0,d1
 CALL log
 fmul d0,d0,d0
 IN2 d1,65
 fdiv d0,d1,d0
 cbz x21,.Lsc_blend_h_store
 L d1,18
 fadd d0,d1,d0
.Lsc_blend_h_store:
 LS d0,18
 NEXT .Lsc_blend_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_blend_tile
 ROWS .Lsc_blend_recover
 L d0,17
 fsqrt d0,d0
 CONST d1,minus_one
 fdiv d0,d1,d0
 CALL exp
 ldr d1,[sp,#2400]
 fmul d0,d1,d0
 OUT d0,74
 L d0,18
 fsqrt d0,d0
 CONST d1,minus_one
 fdiv d0,d1,d0
 CALL exp
 ldr d1,[sp,#2400]
 fmul d0,d1,d0
 OUT d0,75
 NEXT .Lsc_blend_recover
 mov x21,#0
.Lsc_broadcast_roughness_tile:
 ROWS .Lsc_broadcast_roughness_row
 IN d0,74
 LS2 d0,8
 NEXT .Lsc_broadcast_roughness_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_broadcast_roughness_tile
 // Increasing-tile albedo reduction, with the original lake switch.
 ROWS .Lsc_albedo_row
 mov x21,#0
 IN2 d0,65
 IN2 d1,66
 fmul d3,d0,d1
 mov x21,#1
.Lsc_albedo_tile:
 IN2 d0,65
 IN2 d1,66
 fmul d0,d0,d1
 fadd d3,d3,d0
 add x21,x21,#1
 cmp x21,#8
 b.lt .Lsc_albedo_tile
 ARG x9,132
 ldr w9,[x9,#848]
 cbz w9,.Lsc_albedo_store
 IN2 d0,65
 IN2 d1,66
 fmul d0,d0,d1
 fadd d3,d3,d0
.Lsc_albedo_store:
 LS d3,19
 NEXT .Lsc_albedo_row
 mov x21,#0
.Lsc_solar_tile:
 ROWS .Lsc_solar_row
 CONST d0,one
 IN2 d1,66
 fsub d1,d0,d1
 L d2,19
 fsub d2,d0,d2
 fdiv d1,d1,d2
 IN d0,48
 fmul d0,d1,d0
 CONST d1,solar_cap
 fcmp d0,d1
 b.le .Lsc_solar_cap_done
 fmov d0,d1
 mov w11,#1
 LIS w11,21
.Lsc_solar_cap_done:
 OUT2 d0,76
 IN2 d1,65
 fmul d0,d1,d0
 L d1,20
 fadd d0,d1,d0
 LS d0,20
 NEXT .Lsc_solar_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_solar_tile
 // Full tile preparation. Rescaling precedes each private VSURF call.
 mov x21,#0
.Lsc_surface_tile:
 add w9,w21,#1
 str w9,[sp,#2368]
 ldr x9,[x27,#(54*128)]
 ldr w28,[x9,x21,lsl #2]
 sub x28,x28,#1
 ROWS .Lsc_solar_rescale_row
 IN2 d0,76
 LI w11,21
 cbz w11,.Lsc_solar_rescale_done
 IN d1,48
 fmul d0,d0,d1
 L d1,20
 fdiv d0,d0,d1
 OUT2 d0,76
.Lsc_solar_rescale_done:
 CONST d1,one
 IN2 d2,66
 fsub d1,d1,d2
 fdiv d0,d0,d1
 LS d0,22
 NEXT .Lsc_solar_rescale_row
 PARG 0,1
 PARG 1,2
 PARG 2,3
 PARG 3,5
 PARG 4,4
 SARG 5,2368
 PARG 6,22
 PARG 7,23
 PARG 8,24
 ldr x9,[x27,#(54*128)]
 add x9,x9,x21,lsl #2
 PLACE 9
 DARG 10,4
 LVIEW 11,5,0,x28
 PARG 12,34
 PARG 13,110
 PARG 14,65
 PARG 15,28
 PARG 16,29
 PARG 17,38
 PARG 18,39
 PARG 19,40
 PARG 20,41
 VARG 21,71,1
 PARG 22,63
 PARG 23,62
 PARG 24,64
 DARG 25,22
 VARG 26,87,2
 LVIEW 27,29,3
 VARG 28,77,4
 VARG 29,78,5
 DARG 30,24
 VARG 31,79,6
 DARG 32,25
 DARG 33,26
 DARG 34,27
 DARG 35,28
 VARG 36,70,7
 LVIEW 37,1,8
 LVIEW 38,2,9
 LVIEW 39,3,10
 ldr x9,[x27,#(23*128)]
 mul x10,x21,x22
 add x9,x9,x10,lsl #5
 PLACE 40
 PARG 41,121
 PARG 42,122
 PARG 43,126
 PARG 44,128
 PARG 45,127
 PARG 46,129
 PARG 47,130
 PARG 48,131
 PARG 49,132
 PARG 50,133
 CALL MD2ASM_SURFACE_SATURATION_ENTRY
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_surface_tile
 ROWS .Lsc_copy_resistances
 L d0,24
 OUT d0,112
 L d0,25
 OUT d0,113
 L d0,26
 OUT d0,114
 L d0,27
 OUT d0,115
 L d0,28
 OUT d0,116
 NEXT .Lsc_copy_resistances
 // Carbon initialisation and complete respiration/uptake child.
 ARG x9,128
 ldr w9,[x9,#756]
 cbz w9,.Lsc_carbon_done
 ldr w9,[sp,#2376]
 cbz w9,.Lsc_carbon_call
 ARG x9,72
 mov w10,#2
 bl .Lsc_zero_selected
 ARG x9,73
 mov w10,#2
 bl .Lsc_zero_selected
 ARG x9,121
 mov w10,#3
 bl .Lsc_zero_selected
 ARG x9,123
 mov w10,#3
 bl .Lsc_zero_selected
.Lsc_carbon_call:
 PARG 0,1
 PARG 1,2
 PARG 2,3
 PARG 3,4
 PARG 4,5
 // Explicit rank-2 array: include every descriptor lower bound and bias.
 mov x9,#4*128
 add x9,x27,x9
 ldr x10,[x9,#8]
 ldp x11,x12,[x9,#40]
 madd x10,x11,x12,x10
 ldp x11,x12,[x9,#64]
 madd x10,x11,x12,x10
 ldr x9,[x9]
 add x9,x9,x10,lsl #2
 PLACE 5
 DARG 6,54
 PARG 7,23
 PARG 8,64
 PARG 9,20
 PARG 10,38
 PARG 11,39
 PARG 12,41
 DARG 13,6
 PARG 14,65
 DARG 15,5
 // Explicit rank-3 array: include every descriptor lower bound and bias.
 mov x9,#23*128
 add x9,x27,x9
 ldr x10,[x9,#8]
 ldp x11,x12,[x9,#40]
 madd x10,x11,x12,x10
 ldp x11,x12,[x9,#64]
 madd x10,x11,x12,x10
 ldp x11,x12,[x9,#88]
 madd x10,x11,x12,x10
 ldr x9,[x9]
 add x9,x9,x10,lsl #3
 PLACE 16
 PARG 17,63
 PARG 18,62
 DARG 19,7
 PARG 20,30
 PARG 21,31
 DARG 22,1
 DARG 23,2
 DARG 24,3
 PARG 25,126
 PARG 26,128
 PARG 27,131
 PARG 28,129
 PARG 29,72
 PARG 30,73
 PARG 31,106
 PARG 32,107
 PARG 33,105
 PARG 34,108
 PARG 35,109
 PARG 36,110
 PARG 37,111
 PARG 38,123
 CALL md2asm_srfcotwo_7259755
.Lsc_carbon_done:
 ROWS .Lsc_boundary_temperature
 mov x21,#0
 ARG x9,127
 ldr w10,[x9,#8]
 ldr w11,[x9,#12]
 orr w10,w10,w11
 cbz w10,.Lsc_sea_sst
 IN2 d0,71
 b .Lsc_sea_boundary_store
.Lsc_sea_sst:
 IN d0,44
.Lsc_sea_boundary_store:
 OUT2 d0,88
 mov x21,#1
 IN d0,51
 OUT2 d0,88
 mov x28,#0
 IN2 d0,62,x28
 mov x21,#2
 OUT2 d0,88
 mov x21,#3
 OUT2 d0,88
 mov x21,#5
 OUT2 d0,88
 mov x21,#7
 OUT2 d0,88
 IN2 d0,52,x28
 mov x21,#4
 OUT2 d0,88
 mov x21,#6
 OUT2 d0,88
 IN d0,53
 ARG x9,132
 ldr d1,[x9,#192]
 fcmp d0,d1
 b.le .Lsc_lake_water_boundary
 IN d0,54
 b .Lsc_lake_boundary_store
.Lsc_lake_water_boundary:
 IN d0,55
.Lsc_lake_boundary_store:
 mov x21,#8
 OUT2 d0,88
 NEXT .Lsc_boundary_temperature
 PARG 0,1
 PARG 1,2
 PARG 2,3
 PARG 3,5
 PARG 4,22
 PARG 5,24
 PARG 6,21
 PARG 7,71
 PARG 8,88
 PARG 9,32
 PARG 10,33
 PARG 11,57
 PARG 12,63
 PARG 13,64
 PARG 14,126
 PARG 15,128
 PARG 16,131
 PARG 17,133
 PARG 18,125
 PARG 19,89
 CALL md2asm_vlamsk_7240564
 PARG 0,1
 PARG 1,2
 PARG 2,3
 PARG 3,5
 PARG 4,22
 PARG 5,24
 PARG 6,20
 PARG 7,71
 PARG 8,88
 PARG 9,32
 PARG 10,33
 PARG 11,57
 PARG 12,63
 PARG 13,64
 PARG 14,126
 PARG 15,128
 PARG 16,131
 PARG 17,133
 PARG 18,125
 DARG 19,30
 CALL md2asm_vlamsk_7240564
 ARG x9,117
 bl .Lsc_diagnostic_present
 cbz w10,.Lsc_ddh_done
 ARG x9,118
 bl .Lsc_diagnostic_present
 cbz w10,.Lsc_ddh_done
 ARG x9,119
 bl .Lsc_diagnostic_present
 cbz w10,.Lsc_ddh_done
 ARG x9,120
 bl .Lsc_diagnostic_present
 cbz w10,.Lsc_ddh_done
 ARG x9,121
 bl .Lsc_diagnostic_present
 cbz w10,.Lsc_ddh_done
 ARG x9,123
 bl .Lsc_diagnostic_present
 cbz w10,.Lsc_ddh_done
 bl .Lsc_ddh
.Lsc_ddh_done:
 // Complete exchange and evaporation child calls in tile order.
 mov x21,#0
.Lsc_exchange_tile:
 PARG 0,1
 PARG 1,2
 PARG 2,3
 SARG 3,2372
 PARG 4,19
 SARG 5,2376
 PARG 6,36
 PARG 7,37
 PARG 8,38
 PARG 9,39
 PARG 10,41
 PARG 11,42
 PARG 12,43
 VARG 13,79,0
 LVIEW 14,29,1
 LVIEW 15,8,2
 LVIEW 16,9,3
 LVIEW 17,10,4
 LVIEW 18,12,5
 LVIEW 19,11,6
 PARG 20,59
 PARG 21,60
 PARG 22,61
 PARG 23,126
 PARG 24,127
 LVIEW 25,35,7
 VARG 26,80,8
 VARG 27,81,9
 DARG 28,31
 DARG 29,32
 CALL md2asm_surface_exchange
 ROWS .Lsc_exchange_dominant_row
 LI w11,15
 add w10,w21,#1
 cmp w10,w11
 b.ne .Lsc_exchange_dominant_next
 L d0,31
 OUT d0,90
 L d0,32
 OUT d0,91
.Lsc_exchange_dominant_next:
 NEXT .Lsc_exchange_dominant_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_exchange_tile
 mov x21,#0
.Lsc_evaporation_tile:
 add w9,w21,#1
 str w9,[sp,#2368]
 ROWS .Lsc_evaporation_temperature
 cbz x21,.Lsc_evap_sea
 cmp x21,#1
 b.eq .Lsc_evap_ice
 cmp x21,#4
 b.eq .Lsc_evap_snow
 cmp x21,#6
 b.eq .Lsc_evap_snow
 cmp x21,#8
 b.eq .Lsc_evap_lake
 mov x28,#0
 IN2 d0,62,x28
 b .Lsc_evap_temperature_store
.Lsc_evap_sea:
 IN d0,44
 b .Lsc_evap_temperature_store
.Lsc_evap_ice:
 IN d0,51
 b .Lsc_evap_temperature_store
.Lsc_evap_snow:
 mov x28,#0
 IN2 d0,52,x28
 b .Lsc_evap_temperature_store
.Lsc_evap_lake:
 IN d0,53
 ARG x9,132
 ldr d1,[x9,#192]
 fcmp d0,d1
 b.le .Lsc_evap_lake_water
 IN d0,54
 b .Lsc_evap_temperature_store
.Lsc_evap_lake_water:
 IN d0,55
.Lsc_evap_temperature_store:
 LS d0,33
 NEXT .Lsc_evaporation_temperature
 PARG 0,1
 PARG 1,2
 PARG 2,3
 PARG 3,20
 SARG 4,2368
 PARG 5,58
 PARG 6,38
 PARG 7,39
 PARG 8,41
 VARG 9,71,0
 DARG 10,33
 VARG 11,77,1
 VARG 12,81,2
 DARG 13,24
 DARG 14,25
 DARG 15,26
 DARG 16,27
 DARG 17,28
 PARG 18,126
 PARG 19,128
 PARG 20,133
 VARG 21,79,3
 VARG 22,82,4
 VARG 23,83,5
 VARG 24,84,6
 VARG 25,85,7
 VARG 26,86,8
 DARG 27,34
 PARG 28,121
 CALL md2asm_surface_evaporation_private_7358525
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_evaporation_tile
 // Snow below trees uses snow temperature and the original saturation law.
 ROWS .Lsc_tree_snow_evaporation
 mov x21,#6
 IN2 d0,65
 fcmp d0,#0.0
 b.le .Lsc_tree_no_snow
 mov x28,#0
 IN2 d0,52,x28
 bl .Lsc_saturation
 IN d1,41
 fdiv d0,d0,d1
 ARG x9,126
 ldr d1,[x9,#48]
 fmul d1,d1,d0
 CONST d2,one
 fsub d1,d2,d1
 fdiv d1,d2,d1
 fmul d0,d0,d1
 IN d1,39
 fsub d0,d1,d0
 IN2 d1,81
 L d2,34
 fmul d1,d1,d2
 fmul d0,d1,d0
 b .Lsc_tree_snow_store
.Lsc_tree_no_snow:
 fmov d0,xzr
.Lsc_tree_snow_store:
 OUT d0,96
 NEXT .Lsc_tree_snow_evaporation
 mov x21,#0
.Lsc_old_flux_tile:
 ROWS .Lsc_old_flux_row
 L d1,0
 ARG x9,126
 ldr d2,[x9,#80]
 fmul d2,d1,d2
 IN2 d0,69
 fdiv d0,d0,d2
 LS2 d0,37
 IN2 d0,70
 fdiv d0,d0,d1
 LS2 d0,38
 IN d0,36
 IN d2,59
 fsub d0,d0,d2
 fmul d0,d0,d0
 IN d2,37
 IN d3,60
 fsub d2,d2,d3
 fmul d2,d2,d2
 fadd d0,d0,d2
 fsqrt d0,d0
 L2 d2,35
 fmul d0,d2,d0
 fdiv d0,d0,d1
 LS2 d0,36
 NEXT .Lsc_old_flux_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_old_flux_tile
 ldr w9,[sp,#2376]
 cbz w9,.Lsc_energy_done
 ROWS .Lsc_initial_energy_affine
 fmov d0,xzr
 LS d0,39
 LS d0,41
 IN d0,43
 LS d0,40
 IN d0,39
 LS d0,42
 NEXT .Lsc_initial_energy_affine
 mov x21,#0
 PARG 0,1
 PARG 1,2
 PARG 2,3
 PARG 3,5
 PARG 4,22
 PARG 5,24
 PARG 6,20
 PARG 7,79
 PARG 8,71
 PARG 9,77
 PARG 10,78
 PARG 11,80
 PARG 12,81
 PARG 13,83
 PARG 14,82
 PARG 15,76
 PARG 16,65
 PARG 17,88
 DARG 18,30
 VARG 19,32,0
 VARG 20,33,1
 PARG 21,53
 PARG 22,49
 PARG 23,45
 PARG 24,50
 DARG 25,39
 DARG 26,40
 DARG 27,41
 DARG 28,42
 PARG 29,56
 PARG 30,57
 PARG 31,126
 PARG 32,127
 PARG 33,128
 PARG 34,132
 PARG 35,131
 PARG 36,133
 DARG 37,43
 DARG 38,44
 DARG 39,45
 DARG 40,46
 DARG 41,47
 DARG 42,48
 DARG 43,49
 DARG 44,50
 DARG 45,51
 DARG 46,52
 PARG 47,125
 CALL md2asm_surface_energy_private_7358525
 mov x21,#0
.Lsc_initial_energy_flux_tile:
 ROWS .Lsc_initial_energy_flux_row
 L d1,0
 ARG x9,126
 ldr d2,[x9,#80]
 fmul d2,d1,d2
 L2 d0,47
 fdiv d0,d0,d2
 LS2 d0,37
 L2 d0,44
 fdiv d0,d0,d1
 LS2 d0,38
 NEXT .Lsc_initial_energy_flux_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_initial_energy_flux_tile
.Lsc_energy_done:
 ROWS .Lsc_tree_flux_transfer
 mov x28,#4
 L2 d0,38,x28
 L d1,34
 fmul d0,d1,d0
 mov x28,#6
 L2 d1,38,x28
 fadd d0,d1,d0
 LS2 d0,38,x28
 fmov d0,xzr
 OUT d0,93
 OUT d0,94
 OUT d0,95
 OUT d0,92
 NEXT .Lsc_tree_flux_transfer
 mov x21,#0
.Lsc_grid_flux_tile:
 ROWS .Lsc_grid_flux_row
 IN2 d3,65
 L2 d0,36
 fmul d0,d3,d0
 IN d1,93
 fadd d0,d1,d0
 OUT d0,93
 L2 d0,37
 fmul d0,d3,d0
 IN d1,94
 fadd d0,d1,d0
 OUT d0,94
 L2 d0,38
 fmul d0,d3,d0
 IN d1,95
 fadd d0,d1,d0
 OUT d0,95
 L2 d0,35
 fmul d0,d3,d0
 IN d1,92
 fadd d0,d1,d0
 OUT d0,92
 NEXT .Lsc_grid_flux_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_grid_flux_tile
 // Weather-station roughness and dominant low-vegetation outputs.
 ROWS .Lsc_station_roughness_rows
 IN d0,74
 ldr d1,[sp,#2416]
 fcmp d0,d1
 b.le .Lsc_station_local
 OUT d1,97
 ldr d0,[sp,#2408]
 OUT d0,100
 b .Lsc_station_next
.Lsc_station_local:
 OUT d0,97
 IN d0,42
 ldr d1,[sp,#2392]
 fmul d0,d0,d1
 OUT d0,100
.Lsc_station_next:
 NEXT .Lsc_station_roughness_rows
 mov x21,#0
.Lsc_station_humidity_tile:
 ROWS .Lsc_station_humidity_row
 CONST d0,one
 IN2 d1,83
 fsub d0,d0,d1
 IN d1,39
 fmul d0,d1,d0
 IN2 d1,82
 IN2 d2,77
 fmul d1,d1,d2
 fadd d0,d0,d1
 CONST d1,humidity_floor
 fmax d0,d1,d0
 LS2 d0,53
 NEXT .Lsc_station_humidity_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_station_humidity_tile
 ROWS .Lsc_station_dominant
 LI w21,16
 sub x21,x21,#1
 L2 d0,9
 OUT d0,98
 L2 d0,10
 OUT d0,99
 IN2 d0,79
 OUT d0,101
 L2 d0,53
 OUT d0,102
 L2 d0,11
 OUT d0,103
 L2 d0,12
 OUT d0,104
 NEXT .Lsc_station_dominant
 ldr x0,[sp,#2464]
 CALL free
 ldr w9,[sp,#2380]
 cbz w9,.Lsc_return_empty
 adr x0,.Lsc_hook_name
 add x1,sp,#2448
 mov w9,#1
 str w9,[x1]
 add x2,sp,#2432
 mov x3,#39
 CALL __yomhook_MOD_dr_hook_default8
.Lsc_return_empty:
 add x17,sp,#1024
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
 add sp,sp,#4,lsl #12
 ret
.Lsc_reject:
 brk #0x531
.size MD2ASM_SURFACE_EXCHANGE_CONTROLLER_ENTRY,.-MD2ASM_SURFACE_EXCHANGE_CONTROLLER_ENTRY
// Memory-only helper: clear each requested row over all remaining dimensions.
.Lsc_zero_selected:
 ldp x11,x12,[x9,#72]
 sub x12,x12,x11
 add x12,x12,#1
 cmp x12,#0
 b.le .Lsc_zero_return
 cmp w10,#3
 b.ne .Lsc_zero_count_ready
 ldp x11,x13,[x9,#96]
 sub x13,x13,x11
 add x13,x13,#1
 cmp x13,#0
 b.le .Lsc_zero_return
 mul x12,x12,x13
.Lsc_zero_count_ready:
 ldr x11,[x9]
 ldr x13,[x9,#64]
 mov x14,#0
.Lsc_zero_column:
 mov x15,x23
.Lsc_zero_row:
 madd x16,x14,x13,x15
 str xzr,[x11,x16,lsl #3]
 add x15,x15,#1
 cmp x15,x24
 b.lt .Lsc_zero_row
 add x14,x14,#1
 cmp x14,x12
 b.lt .Lsc_zero_column
.Lsc_zero_return:
 ret
.Lsc_diagnostic_present:
 ldp x10,x11,[x9,#48]
 cmp x11,x10
 b.lt .Lsc_diagnostic_empty
 ldp x10,x11,[x9,#72]
 cmp x11,x10
 b.lt .Lsc_diagnostic_empty
 ldp x10,x11,[x9,#96]
 cmp x11,x10
 cset w10,ge
 ret
.Lsc_diagnostic_empty:
 mov w10,#0
 ret
.macro GLOBAL reg,name
 adrp x9,:got:__yos_thf_MOD_\name
 ldr x9,[x9,:got_lo12:__yos_thf_MOD_\name]
 ldr \reg,[x9]
.endm
.Lsc_saturation:
 str x30,[sp,#2568]
 str d0,[sp,#2504]
 ARG x9,126
 ldr d1,[x9]
 fsub d2,d0,d1
 str d2,[sp,#2512]
 fcmp d2,#0.0
 CONST d3,one
 fmov d4,xzr
 fcsel d3,d3,d4,ge
 CONST d4,one
 fsub d4,d4,d3
 GLOBAL d0,r3les
 fmul d0,d0,d3
 GLOBAL d1,r3ies
 fmul d1,d1,d4
 fadd d0,d0,d1
 GLOBAL d1,r4les
 fmul d1,d1,d3
 GLOBAL d2,r4ies
 fmul d2,d2,d4
 fadd d1,d1,d2
 ldr d2,[sp,#2504]
 fsub d2,d2,d1
 ldr d1,[sp,#2512]
 fmul d0,d0,d1
 fdiv d0,d0,d2
 CALL exp
 GLOBAL d1,r2es
 fmul d0,d1,d0
 ldr x30,[sp,#2568]
 ret
// Complete contained diagnostic arithmetic, with its own original logger.
.Lsc_ddh:
 str x30,[sp,#2560]
 ldr w9,[sp,#2380]
 cbz w9,.Lsc_ddh_hook_entry_done
 adr x0,.Lsc_ddh_hook_name
 add x1,sp,#2448
 str wzr,[x1]
 add x2,sp,#2440
 mov x3,#29
 CALL __yomhook_MOD_dr_hook_default8
.Lsc_ddh_hook_entry_done:
 mov x21,#0
.Lsc_ddh_tile:
 fmov d4,xzr
 cmp x21,#2
 b.eq .Lsc_ddh_low_radiation
 cmp x21,#3
 b.eq .Lsc_ddh_low_radiation
 cmp x21,#5
 b.eq .Lsc_ddh_high_radiation
 cmp x21,#6
 b.ne .Lsc_ddh_radiation_ready
.Lsc_ddh_high_radiation:
 ARG x9,128
 ldr x9,[x9,#352]
 ldr d4,[x9,#24]
 b .Lsc_ddh_radiation_ready
.Lsc_ddh_low_radiation:
 ARG x9,128
 ldr x9,[x9,#352]
 ldr d4,[x9,#8]
.Lsc_ddh_radiation_ready:
 add x28,x21,#1
 ROWS .Lsc_ddh_tile_row
 CONST d0,one
 fsub d5,d0,d4
 IN2 d0,65
 fmul d0,d0,d5
 IN d1,48
 fmul d0,d0,d1
 L d1,19
 CONST d2,one
 fsub d1,d2,d1
 fdiv d0,d0,d1
 OUT3 d0,117,x28,4
 IN2 d1,65
 fmul d1,d1,d5
 IN2 d2,76
 fmul d1,d1,d2
 fsub d0,d1,d0
 OUT3 d0,117,x28,5
 IN2 d0,71
 fmul d0,d0,d0
 fmul d0,d0,d0
 ARG x9,126
 ldr d1,[x9,#96]
 fmul d0,d1,d0
 IN d1,49
 IN d2,50
 fdiv d1,d1,d2
 fadd d0,d1,d0
 IN2 d2,65
 fmul d0,d2,d0
 OUT3 d0,117,x28,6
 IN2 d2,65
 IN d1,49
 fmul d1,d2,d1
 IN d2,50
 fdiv d1,d1,d2
 fsub d0,d1,d0
 OUT3 d0,117,x28,7
 IN2 d0,65
 OUT3 d0,117,x28,1
 IN2 d0,71
 OUT3 d0,117,x28,2
 IN2 d0,66
 OUT3 d0,117,x28,3
 IN2 d0,89
 OUT3 d0,117,x28,12
 NEXT .Lsc_ddh_tile_row
 add x21,x21,#1
 cmp x21,#9
 b.lt .Lsc_ddh_tile
 // Snow radiation balances for tiles five and seven.
 ROWS .Lsc_ddh_snow_row
 mov x21,#4
 IN2 d0,65
 mov x21,#6
 IN2 d1,65
 fadd d6,d0,d1
 IN d1,48
 fmul d0,d6,d1
 L d1,19
 CONST d2,one
 fsub d1,d2,d1
 fdiv d7,d0,d1
 mov x28,#1
 OUT3 d7,118,x28,7
 mov x21,#4
 IN2 d0,65
 IN2 d1,76
 fmul d5,d0,d1
 mov x21,#6
 IN2 d0,65
 IN2 d1,76
 fmul d0,d0,d1
 fadd d0,d5,d0
 fsub d0,d0,d7
 OUT3 d0,118,x28,8
 IN d0,49
 fmul d7,d6,d0
 IN d0,50
 fdiv d7,d7,d0
 mov x21,#4
 IN2 d0,71
 fmul d0,d0,d0
 fmul d0,d0,d0
 IN2 d1,65
 fmul d5,d1,d0
 mov x21,#6
 IN2 d0,71
 fmul d0,d0,d0
 fmul d0,d0,d0
 IN2 d1,65
 fmul d0,d1,d0
 fadd d0,d5,d0
 ARG x9,126
 ldr d1,[x9,#96]
 fmul d0,d1,d0
 fadd d0,d7,d0
 OUT3 d0,118,x28,9
 fsub d0,d7,d0
 OUT3 d0,118,x28,10
 CONST d0,snow_fraction_threshold
 fcmp d6,d0
 b.le .Lsc_ddh_snow_default_albedo
 mov x21,#4
 IN2 d0,65
 IN2 d1,66
 fmul d5,d0,d1
 mov x21,#6
 IN2 d0,65
 IN2 d1,66
 fmul d0,d0,d1
 fadd d0,d5,d0
 fdiv d0,d0,d6
 b .Lsc_ddh_snow_albedo_store
.Lsc_ddh_snow_default_albedo:
 ARG x9,131
 ldr d0,[x9,#336]
.Lsc_ddh_snow_albedo_store:
 OUT3 d0,118,x28,6
 NEXT .Lsc_ddh_snow_row
 // Zero only the source's higher snow layers and fields.
 ARG x9,9
 ldr w26,[x9]
 mov x28,#2
.Lsc_ddh_snow_zero_layer:
 cmp x28,x26
 b.gt .Lsc_ddh_snow_zero_done
 ROWS .Lsc_ddh_snow_zero_row
 fmov d0,xzr
 OUT3 d0,118,x28,6
 OUT3 d0,118,x28,7
 OUT3 d0,118,x28,8
 OUT3 d0,118,x28,9
 OUT3 d0,118,x28,10
 NEXT .Lsc_ddh_snow_zero_row
 add x28,x28,#1
 b .Lsc_ddh_snow_zero_layer
.Lsc_ddh_snow_zero_done:
 // Soil radiation balances for tiles three, four, six and eight.
 ROWS .Lsc_ddh_soil_row
 mov x21,#2
 IN2 d0,65
 fmov d6,d0
 mov x21,#3
 IN2 d0,65
 fadd d6,d6,d0
 mov x21,#5
 IN2 d0,65
 fadd d6,d6,d0
 mov x21,#7
 IN2 d0,65
 fadd d6,d6,d0
 IN d0,48
 fmul d0,d6,d0
 L d1,19
 CONST d2,one
 fsub d1,d2,d1
 fdiv d7,d0,d1
 mov x28,#1
 OUT3 d7,119,x28,5
 mov x21,#2
 IN2 d0,65
 IN2 d1,76
 fmul d0,d0,d1
 fmov d5,d0
 mov x21,#3
 IN2 d0,65
 IN2 d1,76
 fmul d0,d0,d1
 fadd d5,d5,d0
 mov x21,#5
 IN2 d0,65
 IN2 d1,76
 fmul d0,d0,d1
 fadd d5,d5,d0
 mov x21,#7
 IN2 d0,65
 IN2 d1,76
 fmul d0,d0,d1
 fadd d5,d5,d0
 fsub d0,d5,d7
 OUT3 d0,119,x28,6
 IN d0,49
 fmul d7,d6,d0
 IN d0,50
 fdiv d7,d7,d0
 mov x21,#2
 IN2 d0,71
 fmul d0,d0,d0
 fmul d0,d0,d0
 IN2 d1,65
 fmul d0,d1,d0
 fmov d5,d0
 mov x21,#3
 IN2 d0,71
 fmul d0,d0,d0
 fmul d0,d0,d0
 IN2 d1,65
 fmul d0,d1,d0
 fadd d5,d5,d0
 mov x21,#5
 IN2 d0,71
 fmul d0,d0,d0
 fmul d0,d0,d0
 IN2 d1,65
 fmul d0,d1,d0
 fadd d5,d5,d0
 mov x21,#7
 IN2 d0,71
 fmul d0,d0,d0
 fmul d0,d0,d0
 IN2 d1,65
 fmul d0,d1,d0
 fadd d5,d5,d0
 ARG x9,126
 ldr d1,[x9,#96]
 fmul d0,d1,d5
 fadd d0,d7,d0
 OUT3 d0,119,x28,7
 fsub d0,d7,d0
 OUT3 d0,119,x28,8
 NEXT .Lsc_ddh_soil_row
 mov x28,#2
.Lsc_ddh_soil_zero_layer:
 cmp x28,#4
 b.gt .Lsc_ddh_soil_zero_done
 ROWS .Lsc_ddh_soil_zero_row
 fmov d0,xzr
 OUT3 d0,119,x28,5
 OUT3 d0,119,x28,6
 OUT3 d0,119,x28,7
 OUT3 d0,119,x28,8
 NEXT .Lsc_ddh_soil_zero_row
 add x28,x28,#1
 b .Lsc_ddh_soil_zero_layer
.Lsc_ddh_soil_zero_done:
 // Ice keeps its original coefficient multiplication order.
 mov x21,#1
 mov x28,#1
 ROWS .Lsc_ddh_ice_row
 IN2 d6,65
 IN d0,48
 fmul d0,d6,d0
 CONST d1,one
 L d2,19
 fsub d1,d1,d2
 fdiv d7,d0,d1
 OUT3 d7,120,x28,5
 IN2 d0,76
 fmul d0,d6,d0
 fsub d0,d0,d7
 OUT3 d0,120,x28,6
 IN d0,49
 fmul d7,d6,d0
 IN d0,50
 fdiv d7,d7,d0
 IN2 d0,71
 fmul d0,d0,d0
 fmul d0,d0,d0
 ARG x9,126
 ldr d1,[x9,#96]
 fmul d1,d1,d6
 fmul d0,d1,d0
 fadd d0,d7,d0
 OUT3 d0,120,x28,7
 fsub d0,d7,d0
 OUT3 d0,120,x28,8
 NEXT .Lsc_ddh_ice_row
 mov x28,#2
.Lsc_ddh_ice_zero_layer:
 cmp x28,#4
 b.gt .Lsc_ddh_ice_zero_done
 ROWS .Lsc_ddh_ice_zero_row
 fmov d0,xzr
 OUT3 d0,120,x28,5
 OUT3 d0,120,x28,6
 OUT3 d0,120,x28,7
 OUT3 d0,120,x28,8
 NEXT .Lsc_ddh_ice_zero_row
 add x28,x28,#1
 b .Lsc_ddh_ice_zero_layer
.Lsc_ddh_ice_zero_done:
 ROWS .Lsc_ddh_vegetation_row
 mov x28,#1
 IN d0,25
 OUT3 d0,121,x28,1
 mov x28,#2
 IN d0,26
 OUT3 d0,121,x28,1
 mov x21,#3
 IN2 d0,65
 fcmp d0,#0.0
 b.eq .Lsc_ddh_low_evap_zero
 IN2 d0,70
 b .Lsc_ddh_low_evap_store
.Lsc_ddh_low_evap_zero:
 fmov d0,xzr
.Lsc_ddh_low_evap_store:
 mov x28,#1
 OUT3 d0,121,x28,8
 mov x21,#5
 IN2 d0,65
 fcmp d0,#0.0
 b.eq .Lsc_ddh_high_evap_zero
 IN2 d0,70
 b .Lsc_ddh_high_evap_store
.Lsc_ddh_high_evap_zero:
 fmov d0,xzr
.Lsc_ddh_high_evap_store:
 mov x28,#2
 OUT3 d0,121,x28,8
 NEXT .Lsc_ddh_vegetation_row
 ldr w9,[sp,#2380]
 cbz w9,.Lsc_ddh_return
 adr x0,.Lsc_ddh_hook_name
 add x1,sp,#2448
 mov w9,#1
 str w9,[x1]
 add x2,sp,#2440
 mov x3,#29
 CALL __yomhook_MOD_dr_hook_default8
.Lsc_ddh_return:
 ldr x30,[sp,#2560]
 ret
.section .rodata
.p2align 3
.Lsc_one: .double 1.0
.Lsc_minus_one: .double -1.0
.Lsc_ten: .double 10.0
.Lsc_forty: .double 40.0
.Lsc_station_roughness: .double 0.03
.Lsc_humidity_floor: .double 1.0e-12
.Lsc_solar_cap: .double 700.0
.Lsc_snow_fraction_threshold: .quad 0x3f50624de0000000
.Lsc_hook_name: .ascii "SURFEXCDRIVER_CTL_MOD:SURFEXCDRIVER_CTL"
.Lsc_ddh_hook_name: .ascii "SURFEXCDRIVER_CTL:COMPUTE_DDH"
.p2align 2
.Lsc_local_specs:
 .word 1,1,3,1,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,1,9,1
 .word 3,2,3,3,1
 .word 3,2,3,3,1
 .word 1,1,3,1,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 1,1,1,1,1
 .word 1,1,1,1,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 1,1,1,1,1
 .word 1,1,3,1,1
 .word 36,3,3,4,9
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 9,2,3,9,1
 .word 1,1,3,1,1
 .word 1,1,3,1,1
 .word 9,2,3,9,1
 .word 9,1,1,1,1
.section .note.GNU-stack,"",%progbits

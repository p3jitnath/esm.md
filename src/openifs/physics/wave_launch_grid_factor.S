/* Source GWDRAG_WMS409..416. d0 area weight, d1 pi, d2 planet radius in m.
 * Returns the dimensionless source launch factor in d0. Raw caller supplies
 * positive area, canonical pi, positive radius and FPCR zero. Public atan is
 * the reference scalar math provider. x18 and the Arm ABI are preserved. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_wave_launch_grid_factor
.type md2asm_wave_launch_grid_factor,%function
md2asm_wave_launch_grid_factor:
 stp x29,x30,[sp,#-32]!
 str x18,[sp,#16]
 fmov d3,#2.0
 fmul d2,d3,d2
 fmul d0,d1,d0
 fsqrt d0,d0
 fmul d0,d2,d0
 ldr d1,.Lminimum_grid
 fmaxnm d0,d0,d1
 fmov d1,#1.0
 fdiv d0,d1,d0
 ldr d1,.Linverse_coarse
 fmaxnm d0,d0,d1
 fsub d0,d0,d1
 ldr d1,.Linverse_interval
 fdiv d0,d0,d1
 bl atan
 fmov d1,#1.0
 fminnm d0,d1,d0
 fsub d0,d1,d0
 ldr x18,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.size md2asm_wave_launch_grid_factor,.-md2asm_wave_launch_grid_factor
.section .rodata
.p2align 3
.Lminimum_grid: .double 100.0
.Linverse_coarse: .quad 0x3f021432907d6c1f
.Linverse_interval: .quad 0x3f3076f7314da70a
.section .note.GNU-stack,"",%progbits

// Complete surface thermal conductance, P01 to P04.
// Original interface: twenty pointer arguments; GNU descriptors are unchanged.
// x19..x29, low d8..d15 and FPCR are preserved; the 512-byte frame is aligned.
// All shape and descriptor checks precede writes. See the complete contract.
.text
.p2align 4
.macro ARG dst, n
 ldr \dst, [sp, #(192+8*\n)]
.endm
.macro CONST dst, name
 adrp x16, .L\name
 ldr \dst, [x16, :lo12:.L\name]
.endm
// Descriptor base is the first logical element; strides count elements.
.macro LOAD2 dst, n, j, t
 ARG x9, \n
 ldr x10, [x9]
 ldr x11, [x9, #40]
 ldr x12, [x9, #64]
 mul x13, \j, x11
 madd x13, \t, x12, x13
 ldr \dst, [x10, x13, lsl #3]
.endm
.macro INT1 dst, n, j
 ARG x9, \n
 ldr x10, [x9]
 ldr x11, [x9, #40]
 mul x13, \j, x11
 ldr \dst, [x10, x13, lsl #2]
.endm
.macro TABLE dst, object, off, index
 add x9, \object, #\off
 ldr x10, [x9]
 ldr x11, [x9, #40]
 ldr x12, [x9, #48]
 sub x13, \index, x12
 mul x13, x13, x11
 ldr \dst, [x10, x13, lsl #3]
.endm
.macro STORE2 src
 ldr x10, [x27]
 ldr x11, [x27, #40]
 ldr x12, [x27, #64]
 mul x13, x23, x11
 madd x13, x24, x12, x13
 str \src, [x10, x13, lsl #3]
.endm
.global md2asm_vlamsk_7240564
.type md2asm_vlamsk_7240564,%function
md2asm_vlamsk_7240564:
 sub sp, sp, #512
 stp x29, x30, [sp]
 mov x29, sp
 stp x19, x20, [sp, #16]
 stp x21, x22, [sp, #32]
 stp x23, x24, [sp, #48]
 stp x25, x26, [sp, #64]
 stp x27, x28, [sp, #80]
 stp d8, d9, [sp, #112]
 stp d10, d11, [sp, #128]
 stp d12, d13, [sp, #144]
 stp d14, d15, [sp, #160]
 stp x0, x1, [sp, #192]
 stp x2, x3, [sp, #208]
 stp x4, x5, [sp, #224]
 stp x6, x7, [sp, #240]
 add x17, sp, #512
 ldp x9, x10, [x17]
 stp x9, x10, [sp, #256]
 ldp x9, x10, [x17, #16]
 stp x9, x10, [sp, #272]
 ldp x9, x10, [x17, #32]
 stp x9, x10, [sp, #288]
 ldp x9, x10, [x17, #48]
 stp x9, x10, [sp, #304]
 ldp x9, x10, [x17, #64]
 stp x9, x10, [sp, #320]
 ldp x9, x10, [x17, #80]
 stp x9, x10, [sp, #336]
 mrs x9, fpcr
 cbnz x9, .Ldone
 mov x9, #0
.Lpointer_check:
 add x10, sp, #192
 ldr x11, [x10, x9, lsl #3]
 cbz x11, .Ldone
 tst x11, #3
 b.ne .Ldone
 add x9, x9, #1
 cmp x9, #20
 b.lt .Lpointer_check
 ARG x9, 0
 ldrsw x19, [x9]
 ARG x9, 1
 ldrsw x20, [x9]
 ARG x9, 2
 ldrsw x21, [x9]
 ARG x9, 3
 ldrsw x22, [x9]
 sub x9, x21, #1
 cmp x9, #4095
 b.hi .Ldone
 cmp x22, #7
 b.lt .Ldone
 cmp x22, #10
 b.gt .Ldone
 cmp x19, #1
 b.lt .Ldone
 add x9, x21, #1
 cmp x19, x9
 b.gt .Ldone
 cmp x20, #0
 b.lt .Ldone
 cmp x20, x21
 b.gt .Ldone
 sub x19, x19, #1
 ARG x25, 16
 ARG x26, 15
 ARG x27, 19
 ldr w9, [x25, #2380]
 cbz w9, .Ltiles_valid
 cmp x22, #8
 b.lt .Ldone
.Ltiles_valid:
 // Three integer maps have at least KLON elements.
 ARG x0, 4
 mov x2, x21
 bl .Lint_descriptor
 cbz w0, .Ldone
 ARG x0, 5
 mov x2, x21
 bl .Lint_descriptor
 cbz w0, .Ldone
 ARG x0, 13
 mov x2, x21
 bl .Lint_descriptor
 cbz w0, .Ldone
 // Skin, underlying temperature and output have all declared tiles.
 ARG x0, 7
 mov x2, x21
 mov x3, x22
 bl .Lmatrix_descriptor
 cbz w0, .Ldone
 ARG x0, 8
 mov x2, x21
 mov x3, x22
 bl .Lmatrix_descriptor
 cbz w0, .Ldone
 mov x0, x27
 mov x2, x21
 mov x3, x22
 bl .Lmatrix_descriptor
 cbz w0, .Ldone
 // Output columns occupy separate row spans.
 ldp x9, x10, [x27, #48]
 sub x10, x10, x9
 ldr x9, [x27, #40]
 mul x10, x10, x9
 add x10, x10, #1
 ldr x9, [x27, #64]
 cmp x9, x10
 b.lt .Ldone
 // Snow and soil owners retain complete layers; at most 64 are supported.
 ARG x0, 9
 mov x2, x21
 mov x3, #1
 bl .Lmatrix_descriptor
 cbz w0, .Ldone
 cmp x1, #64
 b.gt .Ldone
 str x1, [sp, #368]
 ARG x0, 10
 mov x2, x21
 mov x3, #1
 bl .Lmatrix_descriptor
 cbz w0, .Ldone
 cmp x1, #64
 b.gt .Ldone
 ARG x0, 12
 mov x2, x21
 mov x3, #1
 bl .Lmatrix_descriptor
 cbz w0, .Ldone
 cmp x1, #64
 b.gt .Ldone
 ARG x0, 11
 ldr x2, [x0, #48]
 sub x3, x21, #1
 adds x3, x2, x3
 b.vs .Ldone
 bl .Ltable_descriptor
 cbz w0, .Ldone
 // Lookup tables use their original declared lower bounds.
 add x0, x26, #224
 mov x2, #0
 mov x3, #20
 bl .Ltable_descriptor
 cbz w0, .Ldone
 add x0, x26, #288
 mov x2, #0
 mov x3, #20
 bl .Ltable_descriptor
 cbz w0, .Ldone
 ldr w9, [x25, #2380]
 cbz w9, .Lmap_start
 add x0, x25, #880
 mov x2, #1
 mov x3, #7
 bl .Ltable_descriptor
 cbz w0, .Ldone
 add x0, x25, #1392
 mov x2, #1
 mov x3, #7
 bl .Ltable_descriptor
 cbz w0, .Ldone
 add x0, x25, #1456
 mov x2, #1
 mov x3, #7
 bl .Ltable_descriptor
 cbz w0, .Ldone
 add x0, x25, #1648
 mov x2, #1
 mov x3, #1
 bl .Ltable_descriptor
 cbz w0, .Ldone
.Lmap_start:
 mov x23, x19
.Lmap_check:
 cmp x23, x20
 b.ge .Laccepted
 INT1 w0, 4, x23
 cmp w0, #20
 b.hi .Ldone
 INT1 w0, 5, x23
 cmp w0, #20
 b.hi .Ldone
 ldr w9, [x25, #2380]
 cbz w9, .Lnext_map
 INT1 w0, 13, x23
 cmp w0, #7
 b.gt .Ldone
.Lnext_map:
 add x23, x23, #1
 b .Lmap_check
.Laccepted:
 adrp x9, md2asm_vlamsk_native_calls
 add x9, x9, :lo12:md2asm_vlamsk_native_calls
 ldr x10, [x9]
 add x10, x10, #1
 str x10, [x9]
 ARG x9, 6
 ldr d8, [x9]
 ARG x9, 14
 ldr d9, [x9]
 CONST d0, melt_epsilon
 fsub d9, d9, d0
 cmp x19, x20
 b.ge .Ldone
 // Original default stage, increasing tile and column order.
 mov x24, #0
.Ltile_loop:
 mov x23, x19
.Lcolumn_loop:
 cmp x24, #0
 b.eq .Llarge
 cmp x24, #8
 b.eq .Llarge
 cmp x24, #2
 b.eq .Lwater
 cmp x24, #9
 b.eq .Lurban
 cmp x24, #4
 b.eq .Ldefault_snow
 LOAD2 d0, 7, x23, x24
 LOAD2 d1, 8, x23, x24
 fcmp d0, d1
 cset w28, gt
 cmp x24, #1
 b.ne .Lnot_sea_ice
 ARG x9, 18
 ldr w9, [x9]
 cbnz w9, .Llarge
 mov x14, #12
 b .Llookup
.Lnot_sea_ice:
 cmp x24, #3
 b.ne .Lnot_low_vegetation
 INT1 w14, 4, x23
 b .Llookup
.Lnot_low_vegetation:
 cmp x24, #7
 b.ne .Lhigh_vegetation
 mov x14, #8
 b .Llookup
.Lhigh_vegetation:
 cmp x24, #6
 b.ne .Lhigh_map
 cbz w28, .Lwater
.Lhigh_map:
 INT1 w14, 5, x23
.Llookup:
 cbz w28, .Lstable_lookup
 TABLE d0, x26, 288, x14
 b .Lstore_default
.Lstable_lookup:
 TABLE d0, x26, 224, x14
 b .Lstore_default
.Llarge:
 CONST d0, large_value
 b .Lstore_default
.Lwater:
 CONST d0, twenty
 b .Lstore_default
.Lurban:
 ARG x9, 17
 ldr d0, [x9, #400]
 b .Lstore_default
.Ldefault_snow:
 LOAD2 d0, 7, x23, x24
 LOAD2 d1, 8, x23, x24
 fcmp d0, d1
 b.lt .Lglacier_sum
 fcmp d0, d9
 b.le .Lglacier_sum
 CONST d0, fifty
 b .Lstore_default
.Lglacier_sum:
 fmov d2, xzr
 mov x14, #0
 ldr x15, [sp, #368]
.Lsnow_sum:
 LOAD2 d0, 9, x23, x14
 fadd d2, d2, d0
 add x14, x14, #1
 cmp x14, x15
 b.lt .Lsnow_sum
 CONST d0, glacier_threshold
 fcmp d2, d0
 b.le .Lordinary_snow
 CONST d0, eight
 b .Lstore_default
.Lordinary_snow:
 CONST d0, seven
.Lstore_default:
 STORE2 d0
 add x23, x23, #1
 cmp x23, x20
 b.lt .Lcolumn_loop
 add x24, x24, #1
 cmp x24, x22
 b.lt .Ltile_loop
 // P02: forest capacity and separately rounded stability factor.
 mov x24, #6
 mov x23, x19
.Lforest:
 mov x14, #0
 LOAD2 d10, 9, x23, x14
 LOAD2 d11, 10, x23, x14
 fdiv d0, d10, d11
 ldr d1, [x25, #184]
 fmax d0, d1, d0
 ldr d1, [x25, #312]
 fmul d0, d0, d1
 fmul d0, d0, d11
 ldr d1, [x25, #296]
 fdiv d0, d0, d1
 fdiv d0, d8, d0
 LOAD2 d12, 19, x23, x24
 fmul d0, d0, d12
 CONST d1, one
 fadd d0, d1, d0
 fdiv d0, d12, d0
 STORE2 d0
 add x23, x23, #1
 cmp x23, x20
 b.lt .Lforest
 // P03: snow density polynomial, then inverse-depth conductance.
 ldr w9, [x25, #2376]
 cbz w9, .Lsoil_start
 mov x24, #4
 mov x23, x19
.Lsnow_conductivity:
 mov x14, #0
 LOAD2 d10, 9, x23, x14
 LOAD2 d11, 10, x23, x14
 fdiv d0, d10, d11
 CONST d1, minimum_snow_depth
 fmax d0, d1, d0
 CONST d1, one
 fdiv d12, d1, d0
 CONST d0, snow_quadratic
 fmul d0, d0, d11
 fmul d0, d0, d11
 CONST d1, snow_linear
 fmul d1, d1, d11
 fsub d0, d0, d1
 CONST d1, snow_constant
 fadd d0, d0, d1
 CONST d1, two
 fmul d0, d1, d0
 fmul d0, d0, d12
 STORE2 d0
 add x23, x23, #1
 cmp x23, x20
 b.lt .Lsnow_conductivity
.Lsoil_start:
 ldr w9, [x25, #2380]
 cbz w9, .Ldone
 mov x24, #7
 mov x23, x19
.Lsoil_conductivity:
 mov x14, #1
 TABLE d0, x25, 1648, x14
 CONST d1, one
 fdiv d12, d1, d0
 LOAD2 d0, 8, x23, x24
 ldr d1, [x25, #208]
 fcmp d0, d1
 b.ge .Lunfrozen
 ldr d1, [x25, #216]
 fcmp d0, d1
 b.le .Lfrozen
 ldr d1, [x25, #224]
 fsub d0, d0, d1
 ldr d1, [x25, #232]
 fmul d0, d1, d0
 bl md2asm_sin_original_rounding
 CONST d1, one
 fsub d0, d1, d0
 CONST d1, half
 fmul d14, d1, d0
 b .Lfraction_ready
.Lfrozen:
 CONST d14, one
 b .Lfraction_ready
.Lunfrozen:
 fmov d14, xzr
.Lfraction_ready:
 INT1 w28, 13, x23
 cmp w28, #1
 mov w9, #1
 csel w28, w28, w9, ge
 TABLE d13, x25, 880, x28
 mov x14, #0
 LOAD2 d0, 12, x23, x14
 fdiv d0, d0, d13
 ldr d1, [x25, #48]
 fmax d0, d1, d0
 bl md2asm_log10_original_rounding
 ldr d1, [x25, #56]
 fmul d0, d1, d0
 ldr d1, [x25, #64]
 fadd d15, d0, d1
 ldr d0, [x25, #32]
 fmul d1, d13, d14
 bl md2asm_pow_original_rounding_candidate
 fmov d10, d0
 TABLE d0, x25, 1456, x28
 fmul d10, d0, d10
 CONST d1, one
 fsub d1, d1, d14
 fmul d1, d13, d1
 ldr d0, [x25, #40]
 bl md2asm_pow_original_rounding_candidate
 fmul d10, d10, d0
 TABLE d11, x25, 1392, x28
 fsub d0, d10, d11
 fmul d0, d15, d0
 fadd d0, d11, d0
 CONST d1, two
 fmin d0, d1, d0
 CONST d1, minimum_soil_conductivity
 fmax d0, d1, d0
 CONST d1, two
 fmul d0, d1, d0
 fmul d0, d0, d12
 STORE2 d0
 add x23, x23, #1
 cmp x23, x20
 b.lt .Lsoil_conductivity
.Ldone:
 ldp d8, d9, [sp, #112]
 ldp d10, d11, [sp, #128]
 ldp d12, d13, [sp, #144]
 ldp d14, d15, [sp, #160]
 ldp x19, x20, [sp, #16]
 ldp x21, x22, [sp, #32]
 ldp x23, x24, [sp, #48]
 ldp x25, x26, [sp, #64]
 ldp x27, x28, [sp, #80]
 ldp x29, x30, [sp]
 add sp, sp, #512
 ret
.size md2asm_vlamsk_7240564,.-md2asm_vlamsk_7240564
// Integer map: rank 1, 4-byte elements, positive stride, bounded owner.
.Lint_descriptor:
 ldr x4, [x0]
 cbz x4, .Ldescriptor_bad
 tst x4, #3
 b.ne .Ldescriptor_bad
 ldr x4, [x0, #16]
 cmp x4, #4
 b.ne .Ldescriptor_bad
 ldr x4, [x0, #32]
 cmp x4, #4
 b.ne .Ldescriptor_bad
 ldrh w4, [x0, #28]
 cmp w4, #257
 b.ne .Ldescriptor_bad
 ldp x4, x5, [x0, #48]
 subs x5, x5, x4
 b.vs .Ldescriptor_bad
 adds x5, x5, #1
 b.vs .Ldescriptor_bad
 cmp x5, x2
 b.lt .Ldescriptor_bad
 ldr x4, [x0, #40]
 cmp x4, #1
 b.lt .Ldescriptor_bad
 sub x5, x5, #1
 umulh x6, x5, x4
 cbnz x6, .Ldescriptor_bad
 mul x5, x5, x4
 mov x6, #0x4000000
 cmp x5, x6
 b.hs .Ldescriptor_bad
 mov w0, #1
 ret
// Real matrix: all actual extents contribute to the complete reachable owner.
.Lmatrix_descriptor:
 ldr x4, [x0]
 cbz x4, .Ldescriptor_bad
 tst x4, #7
 b.ne .Ldescriptor_bad
 ldr x4, [x0, #16]
 cmp x4, #8
 b.ne .Ldescriptor_bad
 ldr x4, [x0, #32]
 cmp x4, #8
 b.ne .Ldescriptor_bad
 ldrh w4, [x0, #28]
 cmp w4, #770
 b.ne .Ldescriptor_bad
 ldp x4, x5, [x0, #48]
 subs x5, x5, x4
 b.vs .Ldescriptor_bad
 adds x5, x5, #1
 b.vs .Ldescriptor_bad
 cmp x5, x2
 b.lt .Ldescriptor_bad
 ldp x4, x1, [x0, #72]
 subs x1, x1, x4
 b.vs .Ldescriptor_bad
 adds x1, x1, #1
 b.vs .Ldescriptor_bad
 cmp x1, x3
 b.lt .Ldescriptor_bad
 ldr x4, [x0, #40]
 ldr x6, [x0, #64]
 cmp x4, #1
 b.lt .Ldescriptor_bad
 cmp x6, #1
 b.lt .Ldescriptor_bad
 sub x5, x5, #1
 sub x7, x1, #1
 umulh x8, x5, x4
 cbnz x8, .Ldescriptor_bad
 umulh x8, x7, x6
 cbnz x8, .Ldescriptor_bad
 mul x5, x5, x4
 mul x7, x7, x6
 adds x5, x5, x7
 b.cs .Ldescriptor_bad
 mov x6, #0x2000000
 cmp x5, x6
 b.hs .Ldescriptor_bad
 mov w0, #1
 ret
// Real embedded table: required original indices lie inside the actual bounds.
.Ltable_descriptor:
 ldr x4, [x0]
 cbz x4, .Ldescriptor_bad
 tst x4, #7
 b.ne .Ldescriptor_bad
 ldr x4, [x0, #16]
 cmp x4, #8
 b.ne .Ldescriptor_bad
 ldr x4, [x0, #32]
 cmp x4, #8
 b.ne .Ldescriptor_bad
 ldrh w4, [x0, #28]
 cmp w4, #769
 b.ne .Ldescriptor_bad
 ldp x4, x5, [x0, #48]
 cmp x2, x4
 b.lt .Ldescriptor_bad
 cmp x3, x5
 b.gt .Ldescriptor_bad
 subs x5, x5, x4
 b.vs .Ldescriptor_bad
 ldr x4, [x0, #40]
 cmp x4, #1
 b.lt .Ldescriptor_bad
 umulh x6, x5, x4
 cbnz x6, .Ldescriptor_bad
 mul x5, x5, x4
 mov x6, #0x2000000
 cmp x5, x6
 b.hs .Ldescriptor_bad
 mov w0, #1
 ret
.Ldescriptor_bad:
 mov w0, #0
 ret
.section .rodata
.p2align 3
.Llarge_value: .double 1e10
.Ltwenty: .double 20.
.Lfifty: .double 50.
.Leight: .double 8.
.Lseven: .double 7.
.Lglacier_threshold: .double 9000.
.Lmelt_epsilon: .double .2
.Lminimum_snow_depth: .double .01
.Lsnow_quadratic: .double 2.5e-6
.Lsnow_linear: .double 1.23e-4
.Lsnow_constant: .double .024
.Lone: .double 1.
.Ltwo: .double 2.
.Lhalf: .double .5
.Lminimum_soil_conductivity: .double .19
.bss
.p2align 3
.global md2asm_vlamsk_native_calls
.hidden md2asm_vlamsk_native_calls
.type md2asm_vlamsk_native_calls,%object
md2asm_vlamsk_native_calls: .skip 8
.size md2asm_vlamsk_native_calls,8
.section .note.GNU-stack,"",%progbits

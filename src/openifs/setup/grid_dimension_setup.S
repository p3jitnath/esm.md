/* Source-ordered spherical dimension setup. Contract skills/md2asm/references/openifs/setup/grid_dimension_setup.md.
 * x0 complete Geometry, x1 eleven settings words, x2 twelve namelist words,
 * w3 field-presence mask. All inputs are integer metadata, with disjoint bounds.
 * w0 zero on success or two before mutation for an unsupported input.
 * No original callable, floating-point arithmetic or hidden allocation.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_grid_dimensions
.type md2asm_initialize_grid_dimensions,%function
md2asm_initialize_grid_dimensions:
 cbz x0,.Lgd_reject
 tst x0,#7
 b.ne .Lgd_reject
 cbz x1,.Lgd_reject
 tst x1,#3
 b.ne .Lgd_reject
 cbz x2,.Lgd_reject
 tst x2,#3
 b.ne .Lgd_reject
 lsr w4,w3,#12
 cbnz w4,.Lgd_reject
 mov x4,#0
.Lgd_flags:
 ldr w5,[x1,x4,lsl#2]
 cmp w5,#1
 b.hi .Lgd_reject
 add x4,x4,#1
 cmp x4,#5
 b.lo .Lgd_flags
 sub sp,sp,#128
 /* Source defaults precede namelist assignments. */
 mov w4,#32
 str w4,[sp]
 str w4,[sp,#8]
 mov w4,#64
 str w4,[sp,#4]
 str w4,[sp,#12]
 mov w4,#19
 str w4,[sp,#16]
 str w4,[sp,#20]
 mov w4,#21
 ldr w5,[x1,#8]
 cbz w5,.Lgd_default_spectral
 ldr w4,[x1,#24]
.Lgd_default_spectral:
 str w4,[sp,#24]
 str w4,[sp,#28]
 str w4,[sp,#32]
 mov w4,#1
 str w4,[sp,#36]
 ldr w5,[x1]
 mov w4,#2047
 mov w6,#16
 cmp w5,#0
 csel w4,w6,w4,ne
 str w4,[sp,#40]
 str w4,[sp,#112]
 mov w4,#2
 str w4,[sp,#44]
 mov x4,#0
.Lgd_namelist:
 lsr w5,w3,w4
 tbz w5,#0,.Lgd_next_namelist
 ldr w5,[x2,x4,lsl#2]
 str w5,[sp,x4,lsl#2]
.Lgd_next_namelist:
 add x4,x4,#1
 cmp x4,#12
 b.lo .Lgd_namelist
 ldr w4,[sp,#40]
 cbnz w4,.Lgd_block_sign
 ldr w4,[sp,#112]
.Lgd_block_sign:
 cmp w4,#0
 cset w5,gt
 ldr w6,[x1,#4]
 eor w6,w6,#1
 and w5,w5,w6
 str w5,[sp,#48]
 cneg w4,w4,lt
 str w4,[sp,#40]
 /* File dimensions override the selected source fields after the namelist. */
 ldr w5,[x1,#8]
 cbz w5,.Lgd_horizontal
 ldr w4,[x1,#24]
 str w4,[sp,#32]
 ldr w4,[x1,#28]
 str w4,[sp]
 ldr w4,[x1,#32]
 str w4,[sp,#4]
 ldr w4,[x1,#36]
 str w4,[sp,#36]
.Lgd_horizontal:
 ldr w4,[sp,#36]
 ldr w5,[sp,#32]
 cmp w4,w5
 csel w4,w4,w5,gt
 str w4,[sp,#36]
 /* Bound every size before storing any Geometry word. */
 ldr w4,[sp]
 cmp w4,#1
 b.lt .Lgd_stack_reject
 cmp w4,#256,lsl#12
 b.gt .Lgd_stack_reject
 ldr w4,[sp,#4]
 cmp w4,#1
 b.lt .Lgd_stack_reject
 cmp w4,#256,lsl#12
 b.gt .Lgd_stack_reject
 ldr w4,[sp,#32]
 cmp w4,#0
 b.lt .Lgd_stack_reject
 mov w5,#8191
 cmp w4,w5
 b.gt .Lgd_stack_reject
 ldr w4,[sp,#40]
 cmp w4,#1
 b.lt .Lgd_stack_reject
 cmp w4,#256,lsl#12
 b.gt .Lgd_stack_reject
 ldr w4,[sp,#44]
 cmp w4,#48
 b.hi .Lgd_stack_reject
 ldr w4,[sp]
 add w5,w4,#1
 lsr w5,w5,#1
 str w5,[sp,#52]
 ldr w5,[sp,#44]
 str w5,[sp,#76]
 mov w6,#1
 sub w6,w6,w5
 str w6,[sp,#72]
 str w6,[sp,#80]
 add w6,w4,w5
 str w6,[sp,#68]
 str w6,[sp,#8]
 mov w6,#1
 str w6,[sp,#64]
 ldr w6,[sp,#4]
 str w6,[sp,#12]
 ldr w7,[sp,#32]
 add w7,w7,#1
 mul w8,w7,w7
 str w8,[sp,#88]
 add w8,w7,#1
 mul w8,w7,w8
 lsr w8,w8,#1
 str w8,[sp,#96]
 lsl w8,w8,#1
 str w8,[sp,#92]
 /* Longitude work rows include both stencil edges. */
 ldr w7,[sp,#32]
 lsl w7,w7,#1
 add w7,w7,#1
 cmp w6,w7
 csel w6,w6,w7,gt
 lsl w5,w5,#1
 sub w5,w5,#1
 str w5,[sp,#84]
 add w6,w6,w5
 str w6,[sp,#60]
 sub w6,w6,#1
 str w6,[sp,#56]
 /* Vertical source overrides and single-level configurations. */
 ldr w4,[x1,#8]
 ldr w5,[x1,#12]
 cbz w4,.Lgd_vertical_no_file
 cbz w5,.Lgd_vertical_mode
 ldr w6,[x1,#40]
 str w6,[sp,#16]
 str w6,[sp,#20]
 b .Lgd_vertical_mode
.Lgd_vertical_no_file:
 cbz w5,.Lgd_vertical_mode
 ldr w6,[sp,#16]
 str w6,[sp,#20]
.Lgd_vertical_mode:
 ldr w4,[x1,#16]
 cbnz w4,.Lgd_one_level
 ldr w5,[x1,#20]
 cmp w5,#923
 b.eq .Lgd_one_level
 sub w5,w5,#931
 cmp w5,#2
 b.hi .Lgd_vertical_bounds
.Lgd_one_level:
 mov w5,#1
 str w5,[sp,#16]
 str w5,[sp,#20]
.Lgd_vertical_bounds:
 ldr w5,[sp,#16]
 ldr w6,[sp,#20]
 cmp w5,#1
 b.lt .Lgd_stack_reject
 cmp w5,w6
 b.gt .Lgd_stack_reject
 cmp w6,#256,lsl#12
 b.gt .Lgd_stack_reject
 eor w6,w4,#1
 str w6,[sp,#108]
 str w4,[sp,#104]
 add w5,w5,w6
 str w5,[sp,#100]
 /* Scatter only source-written words after all checks. */
 adr x4,.Lgd_offsets
 mov x5,#0
.Lgd_store:
 ldr w6,[x4,x5,lsl#2]
 ldr w7,[sp,x5,lsl#2]
 str w7,[x0,w6,uxtw]
 add x5,x5,#1
 cmp x5,#28
 b.lo .Lgd_store
 add sp,sp,#128
 mov w0,#0
 ret
.Lgd_stack_reject:
 add sp,sp,#128
.Lgd_reject:
 mov w0,#2
 ret
.size md2asm_initialize_grid_dimensions,.-md2asm_initialize_grid_dimensions
.p2align 2
.Lgd_offsets:
 .word 4872 /* NDGLG */
 .word 4936 /* NDLON */
 .word 4924 /* NDGUXG */
 .word 4960 /* NDLUXG */
 .word 5224 /* NFLEVG */
 .word 5252 /* NIOLEVG */
 .word 5180 /* NVARMAX */
 .word 5176 /* NMSMAX */
 .word 5172 /* NSMAX */
 .word 5208 /* NCMAX */
 .word 5144 /* NPROMA */
 .word 4944 /* NSTENCILWIDE */
 .word 5164 /* LOPTPROMA */
 .word 4880 /* NDGNH */
 .word 4952 /* NDLSM */
 .word 4948 /* NDLSUR */
 .word 4956 /* NDLUNG */
 .word 4904 /* NDGENG */
 .word 4888 /* NDGSAG */
 .word 4884 /* NDGSUR */
 .word 4920 /* NDGUNG */
 .word 4940 /* NDSUR1 */
 .word 5184 /* NSEFRE */
 .word 5192 /* NSPEC2G */
 .word 5188 /* NSPECG */
 .word 5248 /* NFLEN */
 .word 5244 /* NFLSA */
 .word 5240 /* NFLSUL */
.section .note.GNU-stack,"",%progbits

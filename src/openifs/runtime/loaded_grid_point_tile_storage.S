/* Contract: skills/md2asm/references/openifs/runtime/loaded_grid_point_tile_storage.md.
 * Own local carriers for the qualified initial CPG tile. No numerical stage
 * is supplied by a driver. Borrowed model owners must remain live. */
.arch armv8.2-a
.macro IMM32 reg,val
 movz \reg,#(\val&65535)
 movk \reg,#((\val>>16)&65535),lsl#16
.endm
.macro MAGIC reg
 movz \reg,#0x4e31
 movk \reg,#0x574f,lsl#16
 movk \reg,#0x4c45,lsl#32
 movk \reg,#0x5449,lsl#48
.endm
.text
.p2align 4
.global md2asm_create_loaded_grid_point_tile
.type md2asm_create_loaded_grid_point_tile,%function
md2asm_create_loaded_grid_point_tile:
 cbz x0,.Lbad_leaf
 cbz x1,.Lbad_leaf
 cbz x2,.Lbad_leaf
 cbz x3,.Lbad_leaf
 orr x9,x0,x2
 orr x9,x9,x3
 tst x9,#7
 b.ne .Lbad_leaf
 tst x1,#3
 b.ne .Lbad_leaf
 adds x9,x0,#64
 b.cs .Lbad_leaf
 adds x9,x1,#4
 b.cs .Lbad_leaf
 adds x9,x2,#88
 b.cs .Lbad_leaf
 adds x9,x3,#8
 b.cs .Lbad_leaf
 ldr x9,[x3]
 cbnz x9,.Lbad_leaf
 mrs x9,fpcr
 cbnz x9,.Lbad_leaf
 sub sp,sp,#192
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 str x28,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mrs x9,fpsr
 str x9,[sp,#104]
 bl __errno_location
 str x0,[sp,#112]
 ldr w9,[x0]
 str w9,[sp,#120]
 mov w9,#2
 str w9,[sp,#124]
 ldr x9,[x19,#8]
 cmp x9,#3
 b.ne .Lcreate_return
 ldr x9,[x19]
 cbz x9,.Lcreate_return
 tst x9,#7
 b.ne .Lcreate_return
 adds x10,x9,#800
 b.cs .Lcreate_return
 ldr x23,[x19,#16]
 cbz x23,.Lcreate_return
 tst x23,#7
 b.ne .Lcreate_return
 ldr x10,[x9,#8]
 cmp x10,x23
 b.ne .Lcreate_return
 ldr x24,[x9,#16]
 ldr x25,[x9,#24]
 ldr x10,[x9,#48]
 stp x10,x20,[sp,#128]
 cbz x24,.Lcreate_return
 cbz x25,.Lcreate_return
 cbz x10,.Lcreate_return
 orr x11,x24,x25
 orr x11,x11,x10
 tst x11,#7
 b.ne .Lcreate_return
 ldr w26,[x23,#5144]
 ldr w27,[x23,#5224]
 cmp w26,#17
 b.ne .Lcreate_return
 cmp w27,#137
 b.ne .Lcreate_return
 ldr w9,[x23,#5156]
 cmp w9,#1
 b.hi .Lcreate_return
 ldr w9,[x20]
 cmp w9,#1
 b.lt .Lcreate_return
 ldr w10,[x23,#5160]
 cmp w9,w10
 b.gt .Lcreate_return
 str w9,[sp,#148]
 sub w10,w9,#1
 umull x10,w10,w26
 add x10,x10,#1
 ldr w11,[x23,#7376]
 cmp x10,x11
 b.hi .Lcreate_return
 sub x11,x11,x10
 add x11,x11,#1
 cmp x11,x26
 csel x11,x11,x26,lo
 str w11,[sp,#152]
 str w10,[sp,#156]
 // Reject output-slot intersections with each complete direct/borrowed span.
 mov x0,x19
 mov x1,#64
 bl .Lseparate
 cbnz w0,.Lcreate_return
 mov x0,x20
 mov x1,#4
 bl .Lseparate
 cbnz w0,.Lcreate_return
 mov x0,x21
 mov x1,#88
 bl .Lseparate
 cbnz w0,.Lcreate_return
 mov x0,x23
 mov x1,#20400
 bl .Lseparate
 cbnz w0,.Lcreate_return
 mov x0,x24
 IMM32 x1,4275088
 bl .Lseparate
 cbnz w0,.Lcreate_return
 mov x0,x25
 IMM32 x1,529288
 bl .Lseparate
 cbnz w0,.Lcreate_return
 ldr x0,[sp,#128]
 IMM32 x1,67616
 bl .Lseparate
 cbnz w0,.Lcreate_return
 // Read live shape variables, then reserve one contiguous private owner.
 mov x28,#3072
 mov x20,#0
.Lmeasure:
 mov w0,w20
 bl .Lbytes
 cbnz w1,.Lmeasure_next
 add x0,x0,#7
 and x0,x0,#-8
 cmp x0,#8
 mov x9,#8
 csel x0,x0,x9,hs
 add x0,x0,#16
 adds x28,x28,x0
 b.cs .Lcreate_return
.Lmeasure_next:
 add x20,x20,#1
 cmp x20,#75
 b.lo .Lmeasure
 mul x9,x26,x27
 lsl x9,x9,#5
 add x10,x27,#1
 mul x10,x10,x26
 add x28,x28,x9
 add x28,x28,x10,lsl#3
 add x28,x28,#80
 mov x9,#0x4000000
 cmp x28,x9
 b.hi .Lcreate_return
 str x28,[sp,#160]
 mov x0,x28
 bl malloc
 cbnz x0,.Lacquired
 mov w9,#1
 str w9,[sp,#124]
 b .Lcreate_return
.Lacquired:
 mov x28,x0
 mov w1,#0x57
 ldr x2,[sp,#160]
 bl memset
 mov x0,x28
 mov w1,#0
 mov x2,#3072
 bl memset
 MAGIC x9
 str x9,[x28]
 str x19,[x28,#8]
 ldr w9,[sp,#148]
 str w9,[x28,#16]
 ldr x9,[sp,#160]
 str x9,[x28,#24]
 stp w26,w27,[x28,#32]
 stp x23,x24,[x28,#40]
 str x25,[x28,#56]
 stp x23,x24,[x28,#64]
 str x25,[x28,#80]
 mov x20,#0
.Lcopy_capacities:
 ldr x9,[x21,x20]
 add x10,x28,#672
 str x9,[x10,x20]
 add x20,x20,#8
 cmp x20,#88
 b.lo .Lcopy_capacities
 add x19,x28,#3072
 mov x20,#0
.Lassign:
 mov w0,w20
 bl .Lbytes
 add x9,x28,#760
 str x0,[x9,x20,lsl#3]
 cbnz w1,.Lassign_next
 add x9,x28,#64
 str x19,[x9,x20,lsl#3]
 add x0,x0,#7
 and x0,x0,#-8
 cmp x0,#8
 mov x9,#8
 csel x0,x0,x9,hs
 add x19,x19,x0
 add x19,x19,#16
.Lassign_next:
 add x20,x20,#1
 cmp x20,#75
 b.lo .Lassign
 IMM32 x9,4150016
 add x9,x24,x9
 str x9,[x28,#160]
 // Source-selected initial controls and the actual live timestep.
 add x21,x28,#64
 ldr x9,[x21,#24]
 str wzr,[x9]
 mov w10,#1
 ldr x9,[x21,#32]
 str w10,[x9]
 ldr x9,[x21,#48]
 str w10,[x9]
 ldr x9,[x21,#80]
 str w10,[x9]
 ldr w10,[sp,#152]
 ldr x9,[x21,#40]
 str w10,[x9]
 ldr x9,[x21,#56]
 str w10,[x9]
 ldr w10,[sp,#148]
 ldr x9,[x21,#64]
 str w10,[x9]
 ldr x9,[x21,#112]
 str w10,[x9]
 ldr w10,[sp,#156]
 ldr x9,[x21,#72]
 str w10,[x9]
 ldr x9,[x21,#88]
 str wzr,[x9]
 ldr x9,[x21,#104]
 mov x10,#0x3ff0000000000000
 str x10,[x9]
 // Five owned pressure-term matrices retain complete GNU descriptors.
 ldr x0,[x21,#120]
 mov w1,#0
 mov x2,#968
 bl memset
 mov x20,#0
.Lgradients:
 add x9,x28,#1360
 str x19,[x9,x20,lsl#3]
 adrp x9,.Lgradient_offsets
 add x9,x9,:lo12:.Lgradient_offsets
 ldrh w9,[x9,x20,lsl#1]
 ldr x0,[x21,#120]
 add x0,x0,x9
 mov x1,x19
 mov x2,x26
 mov x3,x27
 cmp x20,#4
 cset w4,eq
 bl .Ldense
 mul x9,x26,x27
 cmp x20,#4
 b.ne 1f
 add x9,x9,x26
1:
 add x19,x19,x9,lsl#3
 add x19,x19,#16
 add x20,x20,#1
 cmp x20,#5
 b.lo .Lgradients
 ldr x9,[sp,#160]
 add x9,x28,x9
 cmp x19,x9
 b.ne .Lrollback
 add x0,x28,#1496
 mov x1,#744
 bl md2asm_initialize_dynamics_field_maps
 cbnz w0,.Lrollback
 ldr x10,[sp,#128]
 add x9,x28,#1400
 add x11,x10,#64
 str x11,[x9]
 IMM32 x11,20328
 add x11,x23,x11
 str x11,[x9,#8]
 add x11,x28,#1496
 str x11,[x9,#16]
 add x11,x24,#192
 str x11,[x9,#24]
 add x11,x28,#1480
 str x11,[x9,#32]
 add x11,x11,#4
 str x11,[x9,#40]
 add x11,x11,#4
 str x11,[x9,#48]
 IMM32 x11,65796
 add x11,x10,x11
 ldr w12,[x11]
 cbnz w12,.Lrollback
 str x11,[x9,#64]
 str x9,[x28,#664]
 ldr x0,[x28,#8]
 add x1,x28,#64
 add x2,x28,#16
 add x3,x28,#672
 bl md2asm_bind_loaded_grid_point_tile
 cbnz w0,.Lrollback
 str x28,[x22]
 mov w9,#0
 str w9,[sp,#124]
 b .Lcreate_return
.Lrollback:
 mov x0,x28
 bl free
.Lcreate_return:
 ldr x9,[sp,#112]
 ldr w10,[sp,#120]
 str w10,[x9]
 ldr x9,[sp,#104]
 msr fpsr,x9
 ldr w0,[sp,#124]
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#192
 ret
.Lbad_leaf:
 mov w0,#2
 ret
.size md2asm_create_loaded_grid_point_tile,.-md2asm_create_loaded_grid_point_tile
// x0span,x1bytes: reject overlap with the eight-byte destination atx22.
.Lseparate:
 adds x9,x0,x1
 b.cs 2f
 add x10,x22,#8
 cmp x22,x9
 b.hs 1f
 cmp x0,x10
 b.lo 2f
1:mov w0,#0
 ret
2:mov w0,#2
 ret
// Size from liveP/L. Return byte count inx0 and borrowed flag inw1.
.Lbytes:
 cmp w0,#3
 b.hs 1f
 mov w1,#1
 cbnz w0,2f
 mov x0,#20400
 ret
2:cmp w0,#1
 b.ne 3f
 IMM32 x0,4275088
 ret
3:IMM32 x0,529288
 ret
1:
 adrp x9,.Lshape
 add x9,x9,:lo12:.Lshape
 add x9,x9,x0,lsl#2
 ldrb w10,[x9]
 ldrb w1,[x9,#1]
 ldrh w11,[x9,#2]
 mov x0,x11
 cbz w10,.Lsize_return
 cmp w10,#1
 b.eq .Lcolumn
 cmp w10,#2
 b.eq .Lfull
 cmp w10,#3
 b.eq .Lhalf
 cmp w10,#4
 b.eq .Lreserved_full
 cmp w10,#5
 b.eq .Lreserved_half
 // Selected spectral work uses factor*L+one column.
 madd x9,x27,x11,xzr
 add x9,x9,#1
 mul x0,x9,x26
 lsl x0,x0,#3
 ret
.Lcolumn:mul x0,x0,x26
 lsl x0,x0,#3
 ret
.Lfull:mul x0,x0,x26
 mul x0,x0,x27
 lsl x0,x0,#3
 ret
.Lhalf:add x9,x27,#1
 mul x0,x0,x26
 mul x0,x0,x9
 lsl x0,x0,#3
 ret
.Lreserved_full:mul x0,x0,x27
 lsl x0,x0,#3
 ret
.Lreserved_half:add x9,x27,#1
 mul x0,x0,x9
 lsl x0,x0,#3
.Lsize_return:ret
// Dense two-dimensional FP64 descriptor. x4 selects lowerboundzero.
.Ldense:
 str x1,[x0]
 mov x9,#1
 sub x10,x9,x4
 madd x11,x2,x10,x9
 neg x11,x11
 str x11,[x0,#8]
 mov x9,#8
 str x9,[x0,#16]
 mov x11,#0x30200000000
 str x11,[x0,#24]
 str x9,[x0,#32]
 mov x9,#1
 stp x9,x9,[x0,#40]
 stp x2,x2,[x0,#56]
 stp x10,x3,[x0,#72]
 ret
.p2align 4
.global md2asm_release_loaded_grid_point_tile
.type md2asm_release_loaded_grid_point_tile,%function
md2asm_release_loaded_grid_point_tile:
 cbz x0,.Lbad_leaf
 tst x0,#7
 b.ne .Lbad_leaf
 adds x9,x0,#8
 b.cs .Lbad_leaf
 ldr x1,[x0]
 cbnz x1,1f
 mov w0,#0
 ret
1:tst x1,#15
 b.ne .Lbad_leaf
 ldr x9,[x1]
 MAGIC x10
 cmp x9,x10
 b.ne .Lbad_leaf
 ldr x9,[x1,#24]
 cmp x9,#3072
 b.lo .Lbad_leaf
 mov x10,#0x4000000
 cmp x9,x10
 b.hi .Lbad_leaf
 adds x10,x1,x9
 b.cs .Lbad_leaf
 cmp x0,x10
 b.hs 2f
 add x9,x0,#8
 cmp x1,x9
 b.lo .Lbad_leaf
2:sub sp,sp,#64
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 mov x19,x0
 mov x20,x1
 mrs x9,fpsr
 str x9,[sp,#48]
 bl __errno_location
 mov x21,x0
 ldr w9,[x0]
 str w9,[sp,#56]
 mov x0,x20
 bl free
 str xzr,[x19]
 ldr w9,[sp,#56]
 str w9,[x21]
 ldr x9,[sp,#48]
 msr fpsr,x9
 mov w0,#0
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.size md2asm_release_loaded_grid_point_tile,.-md2asm_release_loaded_grid_point_tile
.p2align 4
.global md2asm_run_loaded_grid_point_tile
.type md2asm_run_loaded_grid_point_tile,%function
md2asm_run_loaded_grid_point_tile:
 cbz x0,.Lbad_leaf
 tst x0,#15
 b.ne .Lbad_leaf
 ldr x9,[x0]
 MAGIC x10
 cmp x9,x10
 b.ne .Lbad_leaf
 ldr x9,[x0,#8]
 ldr x10,[x9,#8]
 cmp x10,#3
 b.ne .Lbad_leaf
 sub sp,sp,#592
 add x16,sp,#544
 stp x18,x19,[x16]
 stp x20,x21,[x16,#16]
 stp x29,x30,[x16,#32]
 add x20,x0,#64
 mov x9,#8
.Larguments:
 ldr x10,[x20,x9,lsl#3]
 sub x11,x9,#8
 str x10,[sp,x11,lsl#3]
 add x9,x9,#1
 cmp x9,#76
 b.lo .Larguments
 ldp x0,x1,[x20]
 ldp x2,x3,[x20,#16]
 ldp x4,x5,[x20,#32]
 ldp x6,x7,[x20,#48]
 bl md2asm_operational_forecast_grid
 mov w0,#0
 add x16,sp,#544
 ldp x18,x19,[x16]
 ldp x20,x21,[x16,#16]
 ldp x29,x30,[x16,#32]
 add sp,sp,#592
 ret
.size md2asm_run_loaded_grid_point_tile,.-md2asm_run_loaded_grid_point_tile
.section .rodata
.p2align 2
.Lgradient_offsets:.hword 352,440,88,176,528
.p2align 2
.Lshape:
 .byte 7,1
 .hword 0 // 0 YDGEOMETRY
 .byte 7,1
 .hword 1 // 1 YDMODEL
 .byte 7,1
 .hword 2 // 2 YDFIELDS
 .byte 0,0
 .hword 4 // 3 LD_DFISTEP
 .byte 0,0
 .hword 4 // 4 KST
 .byte 0,0
 .hword 4 // 5 KEND
 .byte 0,0
 .hword 4 // 6 KSTC
 .byte 0,0
 .hword 4 // 7 KENDC
 .byte 0,0
 .hword 4 // 8 KBL
 .byte 0,0
 .hword 4 // 9 KSTGLO
 .byte 0,0
 .hword 4 // 10 LDLFSTEP
 .byte 0,0
 .hword 4 // 11 LDLDIAB
 .byte 0,1
 .hword 8 // 12 PDT
 .byte 0,0
 .hword 8 // 13 PTE
 .byte 0,0
 .hword 4 // 14 KIBL
 .byte 0,0
 .hword 968 // 15 PPGTERM
 .byte 2,1
 .hword 9 // 16 PGFL
 .byte 2,1
 .hword 14 // 17 PGMV
 .byte 1,1
 .hword 3 // 18 PGMVS
 .byte 1,1
 .hword 4 // 19 PSP_RR
 .byte 1,1
 .hword 24 // 20 PSP_SB
 .byte 1,1
 .hword 50 // 21 PSP_SG
 .byte 1,1
 .hword 38 // 22 PSD_VF
 .byte 1,1
 .hword 0 // 23 PSD_VV
 .byte 2,0
 .hword 3 // 24 PGMVTNDSL
 .byte 2,0
 .hword 9 // 25 PGFLTNDSL
 .byte 1,0
 .hword 1 // 26 POROGL
 .byte 1,0
 .hword 1 // 27 POROGM
 .byte 3,0
 .hword 1 // 28 PRE0
 .byte 1,0
 .hword 1 // 29 PRE0L
 .byte 1,0
 .hword 1 // 30 PRE0M
 .byte 2,0
 .hword 1 // 31 PRE0F
 .byte 4,0
 .hword 1 // 32 PNHPRE0F
 .byte 5,0
 .hword 1 // 33 PNHPRE0H
 .byte 2,0
 .hword 7 // 34 PXYB0
 .byte 3,0
 .hword 3 // 35 PUVH0
 .byte 2,0
 .hword 1 // 36 PHIF0
 .byte 2,0
 .hword 3 // 37 PRCP0
 .byte 3,0
 .hword 5 // 38 PCTY0
 .byte 2,0
 .hword 1 // 39 PGWFT0
 .byte 2,0
 .hword 1 // 40 PKENE0
 .byte 3,0
 .hword 1 // 41 PRE9
 .byte 2,0
 .hword 1 // 42 PRE9F
 .byte 4,0
 .hword 1 // 43 PNHPRE9F
 .byte 5,0
 .hword 1 // 44 PNHPRE9H
 .byte 2,0
 .hword 7 // 45 PXYB9
 .byte 3,0
 .hword 1 // 46 PHI9
 .byte 2,0
 .hword 1 // 47 PHIF9
 .byte 2,0
 .hword 3 // 48 PRCP9
 .byte 2,0
 .hword 1 // 49 PGWFT9
 .byte 1,0
 .hword 1 // 50 PGPAR
 .byte 6,0
 .hword 8 // 51 PB2
 .byte 2,1
 .hword 3 // 52 PGMVT1
 .byte 1,1
 .hword 1 // 53 PGMVT1S
 .byte 2,1
 .hword 7 // 54 PGFLT1
 .byte 6,0
 .hword 7 // 55 PKOZO
 .byte 1,0
 .hword 1 // 56 PQS
 .byte 2,0
 .hword 1 // 57 PQICE
 .byte 2,0
 .hword 1 // 58 PQLI
 .byte 2,0
 .hword 1 // 59 PQRAIN
 .byte 2,0
 .hword 1 // 60 PQSNOW
 .byte 2,0
 .hword 5 // 61 PATND
 .byte 0,0
 .hword 8 // 62 PDBBC
 .byte 4,0
 .hword 1 // 63 PRDPHI
 .byte 4,0
 .hword 1 // 64 PGWT0
 .byte 4,0
 .hword 1 // 65 PGWT9
 .byte 0,0
 .hword 8 // 66 PGWS
 .byte 4,0
 .hword 1 // 67 PGWFL
 .byte 4,0
 .hword 1 // 68 PGWFM
 .byte 2,0
 .hword 1 // 69 PNHXT0
 .byte 2,0
 .hword 1 // 70 PNHXT9
 .byte 4,0
 .hword 1 // 71 PQCHA0L
 .byte 4,0
 .hword 1 // 72 PQCHA0M
 .byte 0,0
 .hword 0 // 73 PEXTRA
 .byte 0,0
 .hword 704 // 74 YDDDH
.section .note.GNU-stack,"",%progbits

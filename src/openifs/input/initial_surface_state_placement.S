/*
 * Place selected initial surface fields in blocked model storage, revision 1.
 * Contract: skills/md2asm/references/openifs/input/initial_surface_state_placement.md
 * x0..x7: field2d, bytes2d, field3d, bytes3d, parameters, parameter_bytes,
 * owners, owner_table_bytes. Required immutable spans 770048/409600/208/80 bytes.
 * Owners are five {uint64 pointer,uint64 capacity} pairs in contract order.
 * Each mutable complete owner is disjoint from other owners and all inputs.
 * Keep every unselected field and the final 16 padding rows of every plane.
 * Copy raw bits with integer instructions. Any FPCR is supported and unchanged.
 * FPCR controls floating point. FPSR records floating-point status flags.
 * Preserve FPCR/FPSR, errno, x18..x30 and all vector registers. Leaf, no stack.
 * Return 0 success, 1 invalid buffers, 2 wrong fixed parameter identities.
 * Reject before every owner write. Only x0..x17 and integer flags are scratch.
 */
.arch armv8.2-a
.text
.p2align 4
.macro DISJOINT first,first_end,second,second_end
 cmp \first,\second_end
 b.hs .Lapart_\@
 cmp \second,\first_end
 b.lo .Lbad
.Lapart_\@:
.endm
.macro COPY_PLANE rows=24,fullblocks=85,rowbytes=192
 // x0 walks one source plane. x9 is destination, x10 the block byte stride.
 sub x14,x10,#\rowbytes
 .if \fullblocks > 65535
 movz x11,#(\fullblocks & 65535)
 movk x11,#(\fullblocks >> 16),lsl#16
 .else
 mov x11,#\fullblocks
 .endif
.Lblock_\@:
 mov x12,#\rows
.Lfull_row_\@:
 ldr x13,[x0],#8
 str x13,[x9],#8
 subs x12,x12,#1
 b.ne .Lfull_row_\@
 add x9,x9,x14
 subs x11,x11,#1
 b.ne .Lblock_\@
 mov x12,#8
.Llast_row_\@:
 ldr x13,[x0],#8
 str x13,[x9],#8
 subs x12,x12,#1
 b.ne .Llast_row_\@
.endm
.global md2asm_place_initial_surface_fields
.type md2asm_place_initial_surface_fields,%function
md2asm_place_initial_surface_fields:
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x4,.Lbad
 cbz x6,.Lbad
 orr x8,x0,x2
 orr x8,x8,x6
 tst x8,#7
 b.ne .Lbad
 tst x4,#3
 b.ne .Lbad
 movz x8,#0xc000
 movk x8,#11,lsl#16
 cmp x1,x8
 b.lo .Lbad
 adds x1,x0,x8
 b.cs .Lbad
 movz x8,#0x4000
 movk x8,#6,lsl#16
 cmp x3,x8
 b.lo .Lbad
 adds x3,x2,x8
 b.cs .Lbad
 cmp x5,#208
 b.lo .Lbad
 adds x5,x4,#208
 b.cs .Lbad
 cmp x7,#80
 b.lo .Lbad
 adds x7,x6,#80
 b.cs .Lbad
 adrp x16,.Lowner_bytes
 add x16,x16,:lo12:.Lowner_bytes
 mov x8,#0
.Lvalidate_owner:
 add x17,x6,x8,lsl#4
 ldp x9,x10,[x17]
 cbz x9,.Lbad
 tst x9,#7
 b.ne .Lbad
 ldr x11,[x16,x8,lsl#3]
 cmp x10,x11
 b.lo .Lbad
 adds x12,x9,x11
 b.cs .Lbad
 DISJOINT x9,x12,x0,x1
 DISJOINT x9,x12,x2,x3
 DISJOINT x9,x12,x4,x5
 DISJOINT x9,x12,x6,x7
 mov x15,#0
.Lprevious_owner:
 cmp x15,x8
 b.eq .Lowner_valid
 add x17,x6,x15,lsl#4
 ldr x13,[x17]
 ldr x14,[x16,x15,lsl#3]
 add x14,x13,x14
 DISJOINT x9,x12,x13,x14
 add x15,x15,#1
 b .Lprevious_owner
.Lowner_valid:
 add x8,x8,#1
 cmp x8,#5
 b.ne .Lvalidate_owner
 adrp x16,.Lparameters
 add x16,x16,:lo12:.Lparameters
 mov x8,#0
.Lcheck_parameter:
 ldr w9,[x4,x8,lsl#2]
 ldr w10,[x16,x8,lsl#2]
 cmp w9,w10
 b.ne .Lmetadata
 add x8,x8,#1
 cmp x8,#52
 b.ne .Lcheck_parameter
 adrp x4,.Lmapping2d
 add x4,x4,:lo12:.Lmapping2d
 adrp x5,.Lowner_planes
 add x5,x5,:lo12:.Lowner_planes
 mov x8,#0
.Lplace2d:
 add x17,x4,x8,lsl#3
 ldp w9,w10,[x17]
 ldr w17,[x5,w9,uxtw#2]
 add x9,x6,x9,lsl#4
 ldr x9,[x9]
 mov x15,#192
 madd x9,x10,x15,x9
 mul x10,x17,x15
 COPY_PLANE
 add x8,x8,#1
 cmp x8,#47
 b.ne .Lplace2d
 // Five snow fields each have five contiguous source layer planes.
 mov x0,x2
 ldr x7,[x6,#32]
 mov x8,#0
 mov x10,#9600
.Lplace3d:
 mov x15,#192
 madd x9,x8,x15,x7
 COPY_PLANE
 add x8,x8,#1
 cmp x8,#25
 b.ne .Lplace3d
 mov w0,#0
 ret
.Lbad:
 mov w0,#1
 ret
.Lmetadata:
 mov w0,#2
 ret
.size md2asm_place_initial_surface_fields,.-md2asm_place_initial_surface_fields

/* Operational raw placement. All dimensions follow the actual surface schema.
 * Contract: skills/md2asm/references/openifs/input/operational_surface_state_placement.md
 * x0..x7 have the legacy argument meanings, with 50 ordinary fields and six owners.
 * Copy 3959808000 bytes, preserving all other bytes in 7022069096 complete owner bytes.
 * The common error returns and parameterized copy macro retain legacy machine code.
 */
.p2align 4
.global md2asm_place_operational_initial_surface_fields
.type md2asm_place_operational_initial_surface_fields,%function
md2asm_place_operational_initial_surface_fields:
 cbz x0,.Lbad
 cbz x2,.Lbad
 cbz x4,.Lbad
 cbz x6,.Lbad
 orr x8,x0,x2
 orr x8,x8,x6
 tst x8,#7
 b.ne .Lbad
 tst x4,#3
 b.ne .Lbad
 ldr x8,.Loperational_two_bytes
 cmp x1,x8
 b.lo .Lbad
 adds x1,x0,x8
 b.cs .Lbad
 ldr x8,.Loperational_three_bytes
 cmp x3,x8
 b.lo .Lbad
 adds x3,x2,x8
 b.cs .Lbad
 cmp x5,#220
 b.lo .Lbad
 adds x5,x4,#220
 b.cs .Lbad
 cmp x7,#96
 b.lo .Lbad
 adds x7,x6,#96
 b.cs .Lbad
 adrp x16,.Loperational_owner_bytes
 add x16,x16,:lo12:.Loperational_owner_bytes
 mov x8,#0
.Loperational_validate_owner:
 add x17,x6,x8,lsl#4
 ldp x9,x10,[x17]
 cbz x9,.Lbad
 tst x9,#7
 b.ne .Lbad
 ldr x11,[x16,x8,lsl#3]
 cmp x10,x11
 b.lo .Lbad
 adds x12,x9,x11
 b.cs .Lbad
 DISJOINT x9,x12,x0,x1
 DISJOINT x9,x12,x2,x3
 DISJOINT x9,x12,x4,x5
 DISJOINT x9,x12,x6,x7
 mov x15,#0
.Loperational_previous_owner:
 cmp x15,x8
 b.eq .Loperational_owner_valid
 add x17,x6,x15,lsl#4
 ldr x13,[x17]
 ldr x14,[x16,x15,lsl#3]
 add x14,x13,x14
 DISJOINT x9,x12,x13,x14
 add x15,x15,#1
 b .Loperational_previous_owner
.Loperational_owner_valid:
 add x8,x8,#1
 cmp x8,#6
 b.ne .Loperational_validate_owner
 adrp x16,.Loperational_parameters
 add x16,x16,:lo12:.Loperational_parameters
 mov x8,#0
.Loperational_check_parameter:
 ldr w9,[x4,x8,lsl#2]
 ldr w10,[x16,x8,lsl#2]
 cmp w9,w10
 b.ne .Lmetadata
 add x8,x8,#1
 cmp x8,#55
 b.ne .Loperational_check_parameter
 adrp x4,.Loperational_mapping2d
 add x4,x4,:lo12:.Loperational_mapping2d
 adrp x5,.Loperational_owner_planes
 add x5,x5,:lo12:.Loperational_owner_planes
 mov x8,#0
.Loperational_place2d:
 add x17,x4,x8,lsl#3
 ldp w9,w10,[x17]
 ldr w17,[x5,w9,uxtw#2]
 add x9,x6,x9,lsl#4
 ldr x9,[x9]
 mov x15,#136
 madd x9,x10,x15,x9
 mul x10,x17,x15
 COPY_PLANE 17,388216,136
 add x8,x8,#1
 cmp x8,#50
 b.ne .Loperational_place2d
 mov x0,x2
 ldr x7,[x6,#32]
 mov x8,#0
 mov x10,#6800
.Loperational_place3d:
 mov x15,#136
 madd x9,x8,x15,x7
 COPY_PLANE 17,388216,136
 add x8,x8,#1
 cmp x8,#25
 b.ne .Loperational_place3d
 mov w0,#0
 ret
.size md2asm_place_operational_initial_surface_fields,.-md2asm_place_operational_initial_surface_fields

.section .rodata
.p2align 3
.Lowner_bytes:
 .quad 396288,231168,825600,66048,627456
.Lowner_planes:
 .word 24,14,50,4,38
.Lparameters:
 .word 139,170,183,236,39,40,41,42
 .word 35,36,37,38,228008,228009,228010,228011
 .word 228012,228013,228014,235,198,173,174,160
 .word 172,161,162,163,234,27,129172,28
 .word 200199,29,30,66,67,43,26,228007
 .word 31,34,74,15,16,17,18,228141
 .word 32,33,238,228038
.Lmapping2d:
 .word 0,0 // Parameter 139 to SP_SB, plane 0.
 .word 0,1 // Parameter 170 to SP_SB, plane 1.
 .word 0,2 // Parameter 183 to SP_SB, plane 2.
 .word 0,3 // Parameter 236 to SP_SB, plane 3.
 .word 0,4 // Parameter 39 to SP_SB, plane 4.
 .word 0,5 // Parameter 40 to SP_SB, plane 5.
 .word 0,6 // Parameter 41 to SP_SB, plane 6.
 .word 0,7 // Parameter 42 to SP_SB, plane 7.
 .word 0,8 // Parameter 35 to SP_SB, plane 8.
 .word 0,9 // Parameter 36 to SP_SB, plane 9.
 .word 0,10 // Parameter 37 to SP_SB, plane 10.
 .word 0,11 // Parameter 38 to SP_SB, plane 11.
 .word 1,0 // Parameter 228008 to SP_SL, plane 0.
 .word 1,1 // Parameter 228009 to SP_SL, plane 1.
 .word 1,2 // Parameter 228010 to SP_SL, plane 2.
 .word 1,3 // Parameter 228011 to SP_SL, plane 3.
 .word 1,4 // Parameter 228012 to SP_SL, plane 4.
 .word 1,5 // Parameter 228013 to SP_SL, plane 5.
 .word 1,6 // Parameter 228014 to SP_SL, plane 6.
 .word 3,0 // Parameter 235 to SP_RR, plane 0.
 .word 3,1 // Parameter 198 to SP_RR, plane 1.
 .word 4,0 // Parameter 173 to SD_VF, plane 0.
 .word 4,1 // Parameter 174 to SD_VF, plane 1.
 .word 4,3 // Parameter 160 to SD_VF, plane 3.
 .word 4,4 // Parameter 172 to SD_VF, plane 4.
 .word 4,5 // Parameter 161 to SD_VF, plane 5.
 .word 4,6 // Parameter 162 to SD_VF, plane 6.
 .word 4,7 // Parameter 163 to SD_VF, plane 7.
 .word 4,8 // Parameter 234 to SD_VF, plane 8.
 .word 4,9 // Parameter 27 to SD_VF, plane 9.
 .word 4,10 // Parameter 129172 to SD_VF, plane 10.
 .word 4,11 // Parameter 28 to SD_VF, plane 11.
 .word 4,12 // Parameter 200199 to SD_VF, plane 12.
 .word 4,14 // Parameter 29 to SD_VF, plane 14.
 .word 4,15 // Parameter 30 to SD_VF, plane 15.
 .word 4,16 // Parameter 66 to SD_VF, plane 16.
 .word 4,17 // Parameter 67 to SD_VF, plane 17.
 .word 4,18 // Parameter 43 to SD_VF, plane 18.
 .word 4,19 // Parameter 26 to SD_VF, plane 19.
 .word 4,20 // Parameter 228007 to SD_VF, plane 20.
 .word 4,21 // Parameter 31 to SD_VF, plane 21.
 .word 4,22 // Parameter 34 to SD_VF, plane 22.
 .word 4,25 // Parameter 74 to SD_VF, plane 25.
 .word 4,26 // Parameter 15 to SD_VF, plane 26.
 .word 4,27 // Parameter 16 to SD_VF, plane 27.
 .word 4,28 // Parameter 17 to SD_VF, plane 28.
 .word 4,29 // Parameter 18 to SD_VF, plane 29.
.p2align 3
.Loperational_two_bytes: .quad 2639872000
.Loperational_three_bytes: .quad 1319936000
.Loperational_owner_bytes:
 .quad 1267140288,739165168,2639875600,211190048,2006305456,158392536
.Loperational_owner_planes:
 .word 24,14,50,4,38,3
.Loperational_parameters:
 .word 139,170,183,236,39,40,41,42
 .word 35,36,37,38,228008,228009,228010,228011
 .word 228012,228013,228014,235,198,173,174,160
 .word 172,161,162,163,234,27,129172,28
 .word 200199,29,30,66,67,43,26,228007
 .word 31,34,74,210186,210187,210188,210189,210190,210191,148
 .word 228141,32,33,238,228038
.Loperational_mapping2d:
.word 0,0 // Parameter 139 to SP_SB, plane 0.
 .word 0,1 // Parameter 170 to SP_SB, plane 1.
 .word 0,2 // Parameter 183 to SP_SB, plane 2.
 .word 0,3 // Parameter 236 to SP_SB, plane 3.
 .word 0,4 // Parameter 39 to SP_SB, plane 4.
 .word 0,5 // Parameter 40 to SP_SB, plane 5.
 .word 0,6 // Parameter 41 to SP_SB, plane 6.
 .word 0,7 // Parameter 42 to SP_SB, plane 7.
 .word 0,8 // Parameter 35 to SP_SB, plane 8.
 .word 0,9 // Parameter 36 to SP_SB, plane 9.
 .word 0,10 // Parameter 37 to SP_SB, plane 10.
 .word 0,11 // Parameter 38 to SP_SB, plane 11.
 .word 1,0 // Parameter 228008 to SP_SL, plane 0.
 .word 1,1 // Parameter 228009 to SP_SL, plane 1.
 .word 1,2 // Parameter 228010 to SP_SL, plane 2.
 .word 1,3 // Parameter 228011 to SP_SL, plane 3.
 .word 1,4 // Parameter 228012 to SP_SL, plane 4.
 .word 1,5 // Parameter 228013 to SP_SL, plane 5.
 .word 1,6 // Parameter 228014 to SP_SL, plane 6.
 .word 3,0 // Parameter 235 to SP_RR, plane 0.
 .word 3,1 // Parameter 198 to SP_RR, plane 1.
 .word 4,0 // Parameter 173 to SD_VF, plane 0.
 .word 4,1 // Parameter 174 to SD_VF, plane 1.
 .word 4,3 // Parameter 160 to SD_VF, plane 3.
 .word 4,4 // Parameter 172 to SD_VF, plane 4.
 .word 4,5 // Parameter 161 to SD_VF, plane 5.
 .word 4,6 // Parameter 162 to SD_VF, plane 6.
 .word 4,7 // Parameter 163 to SD_VF, plane 7.
 .word 4,8 // Parameter 234 to SD_VF, plane 8.
 .word 4,9 // Parameter 27 to SD_VF, plane 9.
 .word 4,10 // Parameter 129172 to SD_VF, plane 10.
 .word 4,11 // Parameter 28 to SD_VF, plane 11.
 .word 4,12 // Parameter 200199 to SD_VF, plane 12.
 .word 4,14 // Parameter 29 to SD_VF, plane 14.
 .word 4,15 // Parameter 30 to SD_VF, plane 15.
 .word 4,16 // Parameter 66 to SD_VF, plane 16.
 .word 4,17 // Parameter 67 to SD_VF, plane 17.
 .word 4,18 // Parameter 43 to SD_VF, plane 18.
 .word 4,19 // Parameter 26 to SD_VF, plane 19.
 .word 4,20 // Parameter 228007 to SD_VF, plane 20.
 .word 4,21 // Parameter 31 to SD_VF, plane 21.
 .word 4,22 // Parameter 34 to SD_VF, plane 22.
 .word 4,25 // Parameter 74 to SD_VF, plane 25.
 .word 4,30 // Parameter 210186 to SD_VF, plane 30.
 .word 4,31 // Parameter 210187 to SD_VF, plane 31.
 .word 4,32 // Parameter 210188 to SD_VF, plane 32.
 .word 4,33 // Parameter 210189 to SD_VF, plane 33.
 .word 4,34 // Parameter 210190 to SD_VF, plane 34.
 .word 4,35 // Parameter 210191 to SD_VF, plane 35.
 .word 5,0  // Parameter 148 to SD_WS, plane 0.
.section .note.GNU-stack,"",%progbits

/* Runtime local surface contract
 * skills/md2asm/references/openifs/input/runtime_partitioned_surface_startup.md
 * Select MD2ASM_RUNTIME_SURFACE_DIMENSIONS for live local block dimensions.
 * The accepted 81-record global input schema remains unchanged. */
#ifdef MD2ASM_RUNTIME_SURFACE_DIMENSIONS
#define md2asm_place_partitioned_operational_surface_fields md2asm_place_runtime_partitioned_operational_surface_fields
#endif
/* Contract: skills/md2asm/references/openifs/input/partitioned_operational_surface_loading.md. Integer local-point placement and complete prewrite admission.
 * x0..x7 are field2d/capacity,field3d/capacity,IDs/capacity,table128/capacity.
 * The read-only partition is table+96. Required saved registers and status survive.
 */
.arch armv8.2-a
.macro PS_DISJOINT left,end,right,right_end
 cmp \left,\right_end
 b.hs 991f
 cmp \right,\end
 b.lo .Lps_bad
991:
.endm
.text
.p2align 4
.global md2asm_place_partitioned_operational_surface_fields
.type md2asm_place_partitioned_operational_surface_fields,%function
md2asm_place_partitioned_operational_surface_fields:
 cbz x0,.Lps_bad_leaf
 cbz x2,.Lps_bad_leaf
 cbz x4,.Lps_bad_leaf
 cbz x6,.Lps_bad_leaf
 orr x8,x0,x2
 orr x8,x8,x6
 tst x8,#7
 b.ne .Lps_bad_leaf
 tst x4,#3
 b.ne .Lps_bad_leaf
 ldr x8,.Lps_two_bytes
 cmp x1,x8
 b.lo .Lps_bad_leaf
 adds x1,x0,x8
 b.cs .Lps_bad_leaf
 ldr x8,.Lps_three_bytes
 cmp x3,x8
 b.lo .Lps_bad_leaf
 adds x3,x2,x8
 b.cs .Lps_bad_leaf
 cmp x5,#220
 b.lo .Lps_bad_leaf
 adds x5,x4,#220
 b.cs .Lps_bad_leaf
#ifdef MD2ASM_RUNTIME_SURFACE_DIMENSIONS
 cmp x7,#144
 b.lo .Lps_bad_leaf
 adds x7,x6,#144
#else
 cmp x7,#128
 b.lo .Lps_bad_leaf
 adds x7,x6,#128
#endif
 b.cs .Lps_bad_leaf
#ifdef MD2ASM_RUNTIME_SURFACE_DIMENSIONS
 stp x29,x30,[sp,#-128]!
#else
 stp x29,x30,[sp,#-112]!
#endif
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 mov x26,x7
#ifdef MD2ASM_RUNTIME_SURFACE_DIMENSIONS
 ldp x9,x10,[x25,#128]
 sub x11,x9,#1
 cmp x11,#1023
 b.hi .Lps_bad
 ldr x11,.Lps_global_points
 cmp x10,x11
 b.ne .Lps_bad
 stp x9,x10,[sp,#112]
#endif
 ldp x9,x27,[x25,#96]
 ldp x10,x11,[x25,#112]
 cbz x9,.Lps_bad
 ldr x12,.Lps_global_points
 cmp x9,x12
 b.hi .Lps_bad
 cbz x27,.Lps_bad
 tst x27,#3
 b.ne .Lps_bad
 lsl x12,x9,#2
 cmp x10,x12
 b.lo .Lps_bad
 adds x28,x27,x12
 b.cs .Lps_bad
#ifdef MD2ASM_RUNTIME_SURFACE_DIMENSIONS
 ldr x13,[sp,#112]
 sub x12,x13,#1
 add x12,x9,x12
#else
 add x12,x9,#16
 mov x13,#17
#endif
 udiv x12,x12,x13
 cmp x11,x12
 b.ne .Lps_bad
 stp x9,x11,[sp,#96]
 mov x8,#0
 ldr x12,.Lps_global_points
.Lps_map_check:
 ldrsw x10,[x27,x8,lsl#2]
 cmp x10,#1
 b.lt .Lps_map_bad
 cmp x10,x12
 b.gt .Lps_map_bad
 add x8,x8,#1
 cmp x8,x9
 b.ne .Lps_map_check
 adrp x16,.Loperational_owner_planes
 add x16,x16,:lo12:.Loperational_owner_planes
 mov x8,#0
.Lps_owner_check:
 add x17,x25,x8,lsl#4
 ldp x9,x10,[x17]
 cbz x9,.Lps_bad
 tst x9,#7
 b.ne .Lps_bad
 ldr w11,[x16,x8,lsl#2]
 ldr x12,[sp,#104]
#ifdef MD2ASM_RUNTIME_SURFACE_DIMENSIONS
 ldr x13,[sp,#112]
 lsl x13,x13,#3
#else
 mov x13,#136
#endif
 mul x12,x12,x13
 mul x12,x12,x11
 cmp x10,x12
 b.lo .Lps_bad
 adds x13,x9,x12
 b.cs .Lps_bad
 PS_DISJOINT x9,x13,x19,x20
 PS_DISJOINT x9,x13,x21,x22
 PS_DISJOINT x9,x13,x23,x24
 PS_DISJOINT x9,x13,x25,x26
 PS_DISJOINT x9,x13,x27,x28
 mov x15,#0
.Lps_previous_owner:
 cmp x15,x8
 b.eq .Lps_owner_ready
 add x17,x25,x15,lsl#4
 ldr x14,[x17]
 ldr w17,[x16,x15,lsl#2]
 ldr x0,[sp,#104]
#ifdef MD2ASM_RUNTIME_SURFACE_DIMENSIONS
 ldr x1,[sp,#112]
 lsl x1,x1,#3
#else
 mov x1,#136
#endif
 mul x0,x0,x1
 mul x0,x0,x17
 add x17,x14,x0
 PS_DISJOINT x9,x13,x14,x17
 add x15,x15,#1
 b .Lps_previous_owner
.Lps_owner_ready:
 add x8,x8,#1
 cmp x8,#6
 b.ne .Lps_owner_check
 adrp x16,.Loperational_parameters
 add x16,x16,:lo12:.Loperational_parameters
 mov x8,#0
.Lps_parameter_check:
 ldr w9,[x23,x8,lsl#2]
 ldr w10,[x16,x8,lsl#2]
 cmp w9,w10
 b.ne .Lps_metadata_bad
 add x8,x8,#1
 cmp x8,#55
 b.ne .Lps_parameter_check
 adrp x16,.Loperational_mapping2d
 add x16,x16,:lo12:.Loperational_mapping2d
 adrp x7,.Loperational_owner_planes
 add x7,x7,:lo12:.Loperational_owner_planes
 ldr x6,.Lps_plane_bytes
#ifdef MD2ASM_RUNTIME_SURFACE_DIMENSIONS
 ldr x5,[sp,#112]
#else
 mov x5,#17
#endif
 ldr x14,[sp,#96]
 mov x8,#0
.Lps_two_field:
 add x9,x16,x8,lsl#3
 ldp w9,w10,[x9]
 ldr w11,[x7,x9,lsl#2]
 add x9,x25,x9,lsl#4
 ldr x9,[x9]
#ifdef MD2ASM_RUNTIME_SURFACE_DIMENSIONS
 lsl x0,x5,#3
#else
 mov x0,#136
#endif
 madd x10,x10,x0,x9
 mul x11,x11,x0
 madd x12,x8,x6,x19
 bl .Lps_copy_plane
 add x8,x8,#1
 cmp x8,#50
 b.ne .Lps_two_field
 mov x8,#0
.Lps_snow_field:
 ldr x9,[x25,#32]
#ifdef MD2ASM_RUNTIME_SURFACE_DIMENSIONS
 lsl x0,x5,#3
 madd x10,x8,x0,x9
 mov x11,#50
 mul x11,x11,x0
#else
 mov x0,#136
 madd x10,x8,x0,x9
 mov x11,#6800
#endif
 madd x12,x8,x6,x21
 bl .Lps_copy_plane
 add x8,x8,#1
 cmp x8,#25
 b.ne .Lps_snow_field
 mov w0,#0
 b .Lps_return
/* Copy one plane. x10 destination, x11 block stride, x12 global source,
 * x14 count, x27 map. Scratch x0..x3,x13,x15,x17 and condition flags. */
.Lps_copy_plane:
 mov x13,#0
.Lps_point:
 ldrsw x15,[x27,x13,lsl#2]
 sub x15,x15,#1
 ldr x17,[x12,x15,lsl#3]
 udiv x0,x13,x5
 msub x1,x0,x5,x13
 madd x2,x0,x11,x10
 add x2,x2,x1,lsl#3
 str x17,[x2]
 add x13,x13,#1
 cmp x13,x14
 b.ne .Lps_point
 ret
.Lps_bad:
 mov w0,#1
 b .Lps_return
.Lps_metadata_bad:
 mov w0,#2
 b .Lps_return
.Lps_map_bad:
 mov w0,#3
.Lps_return:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
#ifdef MD2ASM_RUNTIME_SURFACE_DIMENSIONS
 ldp x29,x30,[sp],#128
#else
 ldp x29,x30,[sp],#112
#endif
 ret
.Lps_bad_leaf:
 mov w0,#1
 ret
.size md2asm_place_partitioned_operational_surface_fields,.-md2asm_place_partitioned_operational_surface_fields
.section .rodata
.p2align 3
.Lps_two_bytes: .quad 2639872000
.Lps_three_bytes: .quad 1319936000
.Lps_global_points: .quad 6599680
.Lps_plane_bytes: .quad 52797440
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

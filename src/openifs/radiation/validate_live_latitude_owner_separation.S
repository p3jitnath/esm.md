.arch armv8.2-a
.text
.p2align 4
.global md2asm_validate_live_latitude_owner_separation
.type md2asm_validate_live_latitude_owner_separation,%function
md2asm_validate_live_latitude_owner_separation:
 ldr x3,[x0,#1160]
 ldr x4,[x0,#1288]
 cbz x3,.Lsep_bad
 cbz x4,.Lsep_bad
 ldrsw x7,[x0,#44]
 ldrsw x8,[x0,#48]
 sub x8,x8,x7
 add x8,x8,#1
 lsl x8,x8,#3
 adds x5,x3,x8
 b.cs .Lsep_bad
 add x8,x8,x8,lsl#1
 adds x6,x4,x8
 b.cs .Lsep_bad
 adr x10,.Lsep_offsets
 mov x9,#0
.Lsep_loop:
 ldr x11,[x10,x9,lsl#3]
 add x11,x0,x11
 ldr x7,[x11]
 cbz x7,.Lsep_bad
 ldr x12,[x11,#16]
 cmp x12,#4
 b.eq 1f
 cmp x12,#8
 b.ne .Lsep_bad
1:
 ldp x13,x14,[x11,#48]
 subs x14,x14,x13
 b.lt .Lsep_bad
 add x14,x14,#1
 mul x12,x12,x14
 ldr x15,[x11,#24]
 ubfx x15,x15,#32,#8
 cmp x15,#1
 b.eq 2f
 cmp x15,#2
 b.ne .Lsep_bad
 ldp x13,x14,[x11,#72]
 subs x14,x14,x13
 b.lt .Lsep_bad
 add x14,x14,#1
 mul x12,x12,x14
2:
 adds x8,x7,x12
 b.cs .Lsep_bad
 cmp x3,x8
 b.hs 3f
 cmp x7,x5
 b.lo .Lsep_bad
3:
 cmp x4,x8
 b.hs 4f
 cmp x7,x6
 b.lo .Lsep_bad
4:
 add x9,x9,#1
 cmp x9,#15
 b.lo .Lsep_loop
 /* The sidecar and physical owner also stay live during both frees. */
 mov x7,x1
 add x8,x1,#160
 cmp x3,x8
 b.hs 5f
 cmp x7,x5
 b.lo .Lsep_bad
5:
 cmp x4,x8
 b.hs 6f
 cmp x7,x6
 b.lo .Lsep_bad
6:
 ldr x7,[x1,#32]
 add x8,x7,#520
 cmp x3,x8
 b.hs 7f
 cmp x7,x5
 b.lo .Lsep_bad
7:
 cmp x4,x8
 b.hs 8f
 cmp x7,x6
 b.lo .Lsep_bad
8:
 mov w0,#0
 ret
.Lsep_bad:
 mov w0,#2
 ret
.size md2asm_validate_live_latitude_owner_separation,.-md2asm_validate_live_latitude_owner_separation
.p2align 3
.Lsep_offsets: .quad 536,624,216,280,344,968,1032,1096,712,776,904,840,1224,88,152
.section .note.GNU-stack,"",%progbits

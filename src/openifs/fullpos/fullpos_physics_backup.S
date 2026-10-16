// FULLPOS_DRV selected ECMWF backup block, source lines155--158.
// x0 TFPFIELDS1424, x1 capacity, x2 owned backup6568, x3 capacity.
// Return0 success or2 before mutation. No stack/calls/FP instructions.
.text
.p2align 2
.global md2asm_backup_fullpos_physics_requests
.type md2asm_backup_fullpos_physics_requests,%function
md2asm_backup_fullpos_physics_requests:
 cbz x0,.Lbad
 cbz x2,.Lbad
 orr x4,x0,x2
 tst x4,#7
 b.ne .Lbad
 cmp x1,#1424
 b.lo .Lbad
 mov x4,#6568
 cmp x3,x4
 b.lo .Lbad
 adds x5,x0,#1424
 b.cs .Lbad
 adds x6,x2,x4
 b.cs .Lbad
 cmp x0,x6
 b.hs .Lrecords_disjoint
 cmp x2,x5
 b.lo .Lbad
.Lrecords_disjoint:
 ldr w7,[x0,#1408]
 cmp w7,#1639
 b.hi .Lbad
 cbz w7,.Lcommit
 add x8,x0,#832
 ldr x9,[x8]
 cbz x9,.Lbad
 tst x9,#3
 b.ne .Lbad
 lsl x10,x7,#2
 adds x11,x9,x10
 b.cs .Lbad
 cmp x9,x5
 b.hs .Lowner_source_disjoint
 cmp x0,x11
 b.lo .Lbad
.Lowner_source_disjoint:
 cmp x9,x6
 b.hs .Lowner_output_disjoint
 cmp x2,x11
 b.lo .Lbad
.Lowner_output_disjoint:
 ldr x12,[x8,#8]
 cmn x12,#1
 b.ne .Lbad
 ldr x12,[x8,#16]
 cmp x12,#4
 b.ne .Lbad
 ldr x12,[x8,#24]
 movz x13,#0x0101,lsl#32
 cmp x12,x13
 b.ne .Lbad
 ldr x12,[x8,#32]
 cmp x12,#4
 b.ne .Lbad
 ldp x12,x13,[x8,#40]
 cmp x12,#1
 b.ne .Lbad
 cmp x13,#1
 b.ne .Lbad
 ldr x12,[x8,#56]
 cmp x12,x7
 b.ne .Lbad
.Lcommit:
 str w7,[x2]
 cbz w7,.Lgood
 add x2,x2,#8
.Lcopy:
 ldr w12,[x9],#4
 str w12,[x2],#4
 subs w7,w7,#1
 b.ne .Lcopy
.Lgood:
 mov w0,#0
 ret
.Lbad:
 mov w0,#2
 ret
.size md2asm_backup_fullpos_physics_requests,.-md2asm_backup_fullpos_physics_requests
.global md2asm_backup_owned_fullpos_physics_requests
.type md2asm_backup_owned_fullpos_physics_requests,%function
md2asm_backup_owned_fullpos_physics_requests:
 adrp x2,md2asm_owned_fullpos_physics_backup
 add x2,x2,:lo12:md2asm_owned_fullpos_physics_backup
 mov x3,#6568
 b md2asm_backup_fullpos_physics_requests
.size md2asm_backup_owned_fullpos_physics_requests,.-md2asm_backup_owned_fullpos_physics_requests
.section .note.GNU-stack,"",%progbits

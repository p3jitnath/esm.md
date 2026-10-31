// Physics formulations/openifs/radiation/radiation_grid_driver.md.
// Contract skills/md2asm/references/openifs/radiation/radiation_grid_driver.md.
// This private leaf restores target-grid coordinates and the modified solar cosine after grid transfer.
// The caller supplies live target bounds, packed-field offsets and its complete block capacity.
.arch armv8.2-a
.text
.p2align 4
/* Restore the original posttransport target coordinates and modified solar cosine.
 * x0 packed block, x1 first target point, x2 readonly RADGRID1376,
 * x3 active columns1..8, x4 readonly RF offsets112, x5 readonly RRAE8,
 * x6 packed capacity. Return w0=0 or2. Preserve all nonvolatile state.
 */
.type .Lgrid_posttransport_coordinates_and_airmass,%function
.Lgrid_posttransport_coordinates_and_airmass:
 cbz x0,.Lposttransport_bad
 cbz x2,.Lposttransport_bad
 cbz x4,.Lposttransport_bad
 cbz x5,.Lposttransport_bad
 orr x9,x0,x2
 orr x9,x9,x4
 orr x9,x9,x5
 tst x9,#7
 b.ne .Lposttransport_bad
 mrs x9,fpcr
 cbnz x9,.Lposttransport_bad
 sub x9,x3,#1
 cmp x9,#7
 b.hi .Lposttransport_bad
 ldrsw x7,[x2,#4]
 cmp x7,#1
 b.lt .Lposttransport_bad
 cmp x1,x7
 b.hs .Lposttransport_bad
 adds x9,x1,x3
 b.cs .Lposttransport_bad
 cmp x9,x7
 b.hi .Lposttransport_bad
 cbz x6,.Lposttransport_bad
 adds x8,x0,x6
 b.cs .Lposttransport_bad
 adds x9,x2,#1376
 b.cs .Lposttransport_bad
 cmp x2,x8
 b.hs .Lposttransport_record_apart
 cmp x0,x9
 b.lo .Lposttransport_bad
.Lposttransport_record_apart:
 adds x9,x4,#112
 b.cs .Lposttransport_bad
 cmp x4,x8
 b.hs .Lposttransport_offsets_apart
 cmp x0,x9
 b.lo .Lposttransport_bad
.Lposttransport_offsets_apart:
 adds x9,x5,#8
 b.cs .Lposttransport_bad
 cmp x5,x8
 b.hs .Lposttransport_constant_apart
 cmp x0,x9
 b.lo .Lposttransport_bad
.Lposttransport_constant_apart:
 adr x16,.Lposttransport_packed_ids
 mov x14,#0
.Lposttransport_packed_bounds:
 ldr w9,[x16,x14,lsl#2]
 ldr x10,[x4,x9,lsl#3]
 tst x10,#7
 b.ne .Lposttransport_bad
 adds x11,x10,x3,lsl#3
 b.cs .Lposttransport_bad
 cmp x11,x6
 b.hi .Lposttransport_bad
 mov x15,#0
.Lposttransport_packed_prior:
 cmp x15,x14
 b.hs .Lposttransport_packed_next
 ldr w9,[x16,x15,lsl#2]
 ldr x12,[x4,x9,lsl#3]
 add x13,x12,x3,lsl#3
 cmp x10,x13
 b.hs .Lposttransport_packed_pair_apart
 cmp x12,x11
 b.lo .Lposttransport_bad
.Lposttransport_packed_pair_apart:
 add x15,x15,#1
 b .Lposttransport_packed_prior
.Lposttransport_packed_next:
 add x14,x14,#1
 cmp x14,#6
 b.lo .Lposttransport_packed_bounds
 adr x16,.Lposttransport_coordinate_pairs
 mov x14,#0
.Lposttransport_descriptor:
 add x17,x16,x14,lsl#3
 ldr w9,[x17]
 add x9,x2,x9
 ldr x10,[x9]
 cbz x10,.Lposttransport_bad
 tst x10,#7
 b.ne .Lposttransport_bad
 ldr x11,[x9,#8]
 cmn x11,#1
 b.ne .Lposttransport_bad
 ldr x11,[x9,#16]
 cmp x11,#8
 b.ne .Lposttransport_bad
 ldr x11,[x9,#24]
 movz x12,#0x301,lsl#32
 cmp x11,x12
 b.ne .Lposttransport_bad
 ldr x11,[x9,#32]
 cmp x11,#8
 b.ne .Lposttransport_bad
 ldr x11,[x9,#40]
 cmp x11,#1
 b.ne .Lposttransport_bad
 ldr x11,[x9,#48]
 cmp x11,#1
 b.ne .Lposttransport_bad
 ldr x11,[x9,#56]
 cmp x11,x7
 b.ne .Lposttransport_bad
 adds x11,x10,x7,lsl#3
 b.cs .Lposttransport_bad
 cmp x10,x8
 b.hs .Lposttransport_descriptor_next
 cmp x0,x11
 b.lo .Lposttransport_bad
.Lposttransport_descriptor_next:
 add x14,x14,#1
 cmp x14,#4
 b.lo .Lposttransport_descriptor
 mov x14,#0
.Lposttransport_coordinate_field:
 add x17,x16,x14,lsl#3
 ldr w9,[x17]
 ldr x9,[x2,x9]
 add x9,x9,x1,lsl#3
 ldr w10,[x17,#4]
 ldr x10,[x4,x10,lsl#3]
 add x10,x0,x10
 mov x11,#0
.Lposttransport_coordinate_cell:
 ldr x12,[x9,x11,lsl#3]
 str x12,[x10,x11,lsl#3]
 add x11,x11,#1
 cmp x11,x3
 b.lo .Lposttransport_coordinate_cell
 add x14,x14,#1
 cmp x14,#4
 b.lo .Lposttransport_coordinate_field
 ldr d4,[x5]
 fmov d5,#2.0
 fadd d5,d4,d5
 fmul d5,d4,d5
 adr x9,.Lposttransport_angle_threshold
 ldr d6,[x9]
 ldr x9,[x4,#8]
 add x9,x0,x9
 ldr x10,[x4,#16]
 add x10,x0,x10
 mov x11,#0
.Lposttransport_airmass_cell:
 ldr d0,[x9,x11,lsl#3]
 fcmp d0,d6
 b.le .Lposttransport_airmass_floor
 fmul d1,d0,d0
 fadd d1,d1,d5
 fsqrt d1,d1
 fsub d1,d1,d0
 fdiv d1,d4,d1
 b .Lposttransport_airmass_store
.Lposttransport_airmass_floor:
 fsqrt d1,d5
 fdiv d1,d4,d1
.Lposttransport_airmass_store:
 str d1,[x10,x11,lsl#3]
 add x11,x11,#1
 cmp x11,x3
 b.lo .Lposttransport_airmass_cell
 mov w0,#0
 ret
.Lposttransport_bad:
 mov w0,#2
 ret
.size .Lgrid_posttransport_coordinates_and_airmass,.-.Lgrid_posttransport_coordinates_and_airmass
.section .rodata
.p2align 3
.Lposttransport_coordinate_pairs:
 .word 712,10,840,12,904,13,1224,11
.Lposttransport_packed_ids:
 .word 10,12,13,11,1,2
.p2align 3
.Lposttransport_angle_threshold:
 .double 1.0e-10

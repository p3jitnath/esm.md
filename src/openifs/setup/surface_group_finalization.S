/* Owned surface group finalization, revision 2.
 * Contract: skills/md2asm/references/openifs/setup/surface_group_finalization.md.
 * x0 group60, x1 fields, x2 byte capacity, x3 totals24, x4 controls8.
 * Only the returned metadata calculations are included; diagnostics are separate. */
.arch armv8.2-a
.macro FINAL_DISJOINT first,first_end,second,second_end
 cmp \first,\second_end
 b.hs .Lfinal_separate\@
 cmp \second,\first_end
 b.lo .Lfinal_reject
.Lfinal_separate\@:
.endm
.macro FINAL_CHECK offset,increment
 ldr w13,[x3,#\offset]
 tbnz w13,#31,.Lfinal_reject
 adds w14,w13,\increment
 b.vs .Lfinal_reject
.endm
.macro FINAL_ADD offset,increment
 ldr w13,[x3,#\offset]
 add w13,w13,\increment
 str w13,[x3,#\offset]
.endm
.text
.p2align 4
.global md2asm_finalize_surface_group
.type md2asm_finalize_surface_group,%function
md2asm_finalize_surface_group:
 cbz x0,.Lfinal_reject
 cbz x3,.Lfinal_reject
 cbz x4,.Lfinal_reject
 orr x5,x0,x3
 orr x5,x5,x4
 tst x5,#3
 b.ne .Lfinal_reject
 tst x1,#7
 b.ne .Lfinal_reject
 adds x5,x0,#60
 b.cs .Lfinal_reject
 adds x6,x1,x2
 b.cs .Lfinal_reject
 adds x7,x3,#24
 b.cs .Lfinal_reject
 adds x8,x4,#8
 b.cs .Lfinal_reject
 FINAL_DISJOINT x0,x5,x1,x6
 FINAL_DISJOINT x0,x5,x3,x7
 FINAL_DISJOINT x0,x5,x4,x8
 FINAL_DISJOINT x1,x6,x3,x7
 FINAL_DISJOINT x1,x6,x4,x8
 FINAL_DISJOINT x3,x7,x4,x8
 ldr w10,[x0,#12]
 sub w10,w10,#1
 cmp w10,#693
 b.hi .Lfinal_reject
 cbz w10,.Lfinal_field_address_ok
 cbz x1,.Lfinal_reject
.Lfinal_field_address_ok:
 ldr w14,[x0,#56]
 cbnz w14,.Lfinal_reject
 ldr w11,[x0,#8]
 ldr w14,[x0,#48]
 cmn w11,#1
 b.ne .Lfinal_layered
 cbnz w14,.Lfinal_reject
 mov x9,#64
 mov w11,#1
 b .Lfinal_shape_ok
.Lfinal_layered:
 cmp w11,#137
 b.eq .Lfinal_operational_layers
 cmp w11,#64
 b.hi .Lfinal_reject
.Lfinal_operational_layers:
 cmp w14,#1
 b.ne .Lfinal_reject
 mov x9,#288
.Lfinal_shape_ok:
 mul x15,x10,x9
 cmp x2,x15
 b.lo .Lfinal_reject
 ldr w12,[x0,#52]
 cmp w12,#1
 b.hi .Lfinal_reject
 ldr w13,[x4]
 cmp w13,#1
 b.hi .Lfinal_reject
 ldr w14,[x4,#4]
 mov w15,#0x7961
 movk w15,#0xfffe,lsl #16
 cmp w14,w15
 b.eq .Lfinal_undefined_ok
 mov w15,#48577
 movk w15,#65520,lsl#16
 cmp w14,w15
 b.ne .Lfinal_reject
.Lfinal_undefined_ok:
 cbz w10,.Lfinal_fields_valid
 mov w14,#1
 mov x15,x1
.Lfinal_validate_field:
 ldr w16,[x15,#20]
 cmp w16,w14
 b.ne .Lfinal_reject
 ldr w16,[x15,#24]
 cmp w16,#1
 b.ne .Lfinal_reject
 add x15,x15,x9
 add w14,w14,#1
 cmp w14,w10
 b.ls .Lfinal_validate_field
.Lfinal_fields_valid:
 mov w5,w10
 mul w6,w5,w11
 cmp w12,#0
 csel w7,w5,wzr,ne
 mul w8,w7,w11
 mov w14,#3
 sub w14,w14,w13
 mov w15,#1
 csel w14,w14,w15,ne
 mul w16,w5,w14
 mul w10,w16,w11
 mov x11,x9
 mov w9,w16
 FINAL_CHECK 0,w5
 FINAL_CHECK 4,w6
 FINAL_CHECK 8,w9
 FINAL_CHECK 12,w10
 FINAL_CHECK 16,w7
 FINAL_CHECK 20,w8
 /* All validation is complete before the first caller store. */
 str w5,[x0]
 str w9,[x0,#4]
 mov w14,#1
 str w14,[x0,#56]
 FINAL_ADD 0,w5
 FINAL_ADD 4,w6
 FINAL_ADD 8,w9
 FINAL_ADD 12,w10
 FINAL_ADD 16,w7
 FINAL_ADD 20,w8
 cbz w5,.Lfinal_success
 mov w13,#1
.Lfinal_map_field:
 cbnz w12,.Lfinal_multiple
 ldr w14,[x4,#4]
 mov w15,w14
 mov w16,w14
 b .Lfinal_store_field
.Lfinal_multiple:
 mov w14,w13
 ldr w17,[x4]
 cbz w17,.Lfinal_three_times
 mov w15,w13
 add w16,w13,w5
 b .Lfinal_store_field
.Lfinal_three_times:
 add w15,w13,w5
 add w16,w15,w5
.Lfinal_store_field:
 stp w13,w14,[x1]
 stp w15,w16,[x1,#8]
 add x1,x1,x11
 add w13,w13,#1
 cmp w13,w5
 b.ls .Lfinal_map_field
.Lfinal_success:
 mov w0,#0
 ret
.Lfinal_reject:
 mov w0,#2
 ret
.size md2asm_finalize_surface_group,.-md2asm_finalize_surface_group
.section .note.GNU-stack,"",%progbits

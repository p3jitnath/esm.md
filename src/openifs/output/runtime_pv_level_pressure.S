/* The interface, bounds, units and component limits are in
 * skills/md2asm/references/openifs/output/fullpos_vertical_physics.md.
 */
/* Source PPLTP maps a potential-vorticity surface to pressure in pascals. */
.arch armv8.2-a
.symver md2asm_pv_public_log,log@GLIBC_2.29
.text
.p2align 4
.global md2asm_runtime_pv_level_pressure
.type md2asm_runtime_pv_level_pressure,%function
md2asm_runtime_pv_level_pressure:
 mov x17,sp
 sub sp,sp,#384
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp x0,x1,[sp,#128]
 stp x2,x3,[sp,#144]
 stp x4,x5,[sp,#160]
 stp x6,x7,[sp,#176]
 ldp x9,x10,[x17]
 stp x9,x10,[sp,#192]
 ldp x9,x10,[x17,#16]
 stp x9,x10,[sp,#208]
 ldp x9,x10,[x17,#32]
 stp x9,x10,[sp,#224]
 ldp x9,x10,[x17,#48]
 stp x9,x10,[sp,#240]
 add x9,sp,#128
 mov x10,#16
.Lpointer_check:
 ldr x11,[x9],#8
 cbz x11,.Lbad
 subs x10,x10,#1
 b.ne .Lpointer_check
 ldr x9,[sp,#248]
 ldr x10,[x9]
 cbz x10,.Lbad
 ldr w10,[x10]
 cbnz w10,.Lbad
 mrs x10,fpcr
 cbnz x10,.Lbad
 ldr x10,[sp,#152]
 ldr w19,[x10]
 ldr x10,[sp,#176]
 ldr w20,[x10]
 ldr x10,[sp,#160]
 ldr w21,[x10]
 ldr x10,[sp,#168]
 ldr w22,[x10]
 sub w10,w19,#1
 mov w11,#32768
 cmp w10,w11
 b.hi .Lbad
 sub w10,w20,#2
 cmp w10,#510
 b.hi .Lbad
 sub w10,w21,#1
 cmp w10,w19
 b.hs .Lbad
 cmp w22,w21
 b.lt .Lbad
 cmp w22,w19
 b.gt .Lbad
 sub w21,w21,#1
 ldr x10,[sp,#136]
 ldr w10,[x10]
 sub w11,w10,#1
 cmp w11,#2
 b.hi .Lbad
 str w10,[sp,#264]
 ldr x10,[sp,#144]
 ldr w10,[x10]
 cmp w10,#1
 b.hi .Lbad
 str w10,[sp,#260]
 ldr x10,[sp,#208]
 ldr w28,[x10]
 cmp w28,#1
 b.hi .Lbad
 ldr x10,[sp,#128]
 ldr x10,[x10]
 str x10,[sp,#288]
 ldr x10,[sp,#200]
 ldr x10,[x10]
 str x10,[sp,#296]
 mul x24,x19,x20
 lsl x24,x24,#3
 ldr x10,[x9,#8]
 mov x11,#1
 lsl x11,x11,#28
 cmp x10,x11
 b.hi .Lbad
 cmp x24,x10
 b.hi .Lbad
 mov x0,x24
 bl malloc
 ldr x18,[sp,#96]
 cbz x0,.Lallocation_bad
 mov x23,x0
 /* Preserve the source level-major sign correction, including negative zero. */
 mov x9,#0
 ldr x13,[sp,#192]
 ldr x14,[sp,#216]
 mov x15,#1
 lsl x15,x15,#63
 mov x16,#0x3ff0
 lsl x16,x16,#48
.Lsign_level:
 mov x10,x21
.Lsign_row:
 madd x11,x9,x19,x10
 ldr x12,[x14,x10,lsl#3]
 and x12,x12,x15
 orr x12,x12,x16
 fmov d0,x12
 ldr d1,[x13,x11,lsl#3]
 fmul d0,d0,d1
 str d0,[x23,x11,lsl#3]
 add x10,x10,#1
 cmp x10,x22
 b.lo .Lsign_row
 add x9,x9,#1
 cmp x9,x20
 b.lo .Lsign_level
 mov x25,x21
.Lcolumn:
 /* The cap uses the first model pressure greater than or equal to PVCAP. */
 mov x26,#1
 ldr x13,[sp,#184]
 ldr d1,[sp,#288]
.Lcap_search:
 sub x9,x26,#1
 madd x9,x9,x19,x25
 ldr d0,[x13,x9,lsl#3]
 fcmp d0,d1
 b.ge .Lcap_found
 add x26,x26,#1
 cmp x26,x20
 b.ls .Lcap_search
 b .Linvalid_profile
.Lcap_found:
 cbz x28,.Lordinary_search
 mov x0,#2
 sub x1,x20,#1
 b .Lsearch_mode
.Lordinary_search:
 mov x0,x26
 sub x1,x20,x26
 add x1,x1,#1
.Lsearch_mode:
 mov x2,#0
 ldr w9,[sp,#260]
 cbz w9,.Lsearch_ready
 ldr w2,[sp,#264]
 cmp x1,x2
 b.lo .Linvalid_profile
.Lsearch_ready:
 bl .Lfind_below
 cbz x28,.Lordinary_index
 add x27,x0,#1
 /* This declared source domain has a defined subsequent folding search. */
 cmp x27,x20
 b.hs .Linvalid_profile
 cmp x27,x26
 csel x9,x27,x26,ge
 str x9,[sp,#272]
 cmp x9,#1
 b.eq .Lcopy_selected
 add x10,x20,#1
 cmp x9,x10
 b.hs .Lcopy_last
 b .Linterpolate
.Lordinary_index:
 add x27,x0,x26
 sub x27,x27,#1
 cmp x27,x26
 csel x27,x27,x26,ge
 str x27,[sp,#272]
 cmp x27,x26
 b.eq .Lcopy_selected
 add x10,x20,#1
 cmp x27,x10
 b.hs .Lcopy_last
.Linterpolate:
 ldr x9,[sp,#272]
 sub x12,x9,#1
 madd x12,x12,x19,x25
 sub x13,x12,x19
 ldr d0,[x23,x13,lsl#3]
 ldr d1,[x23,x12,lsl#3]
 fsub d0,d0,d1
 adr x10,.Lsecurity
 ldr d2,[x10]
 cbz x28,.Lpositive_security
 ldr w10,[sp,#260]
 cbz w10,.Lpositive_security
 fcmp d0,#0.0
 b.ge .Lpositive_security
 fneg d2,d2
 fmin d0,d0,d2
 b .Ldenominator_ready
.Lpositive_security:
 fmax d0,d0,d2
.Ldenominator_ready:
 /* LDCP deliberately uses ILEV for the pressure difference and ILEVI for PV. */
 sub x9,x27,#1
 madd x9,x9,x19,x25
 sub x10,x9,x19
 ldr x14,[sp,#184]
 ldr d2,[x14,x10,lsl#3]
 ldr d3,[x14,x9,lsl#3]
 fsub d2,d2,d3
 ldr d4,[sp,#296]
 fsub d4,d4,d1
 fmul d2,d2,d4
 fdiv d2,d2,d0
 ldr d3,[x14,x12,lsl#3]
 fadd d0,d2,d3
 sub x9,x26,#1
 madd x9,x9,x19,x25
 ldr d1,[x14,x9,lsl#3]
 fmax d0,d0,d1
 b .Lpublish
.Lcopy_last:
 mov x9,x20
 b .Lcopy_level
.Lcopy_selected:
 ldr x9,[sp,#272]
.Lcopy_level:
 sub x9,x9,#1
 madd x9,x9,x19,x25
 ldr x10,[sp,#184]
 ldr d0,[x10,x9,lsl#3]
.Lpublish:
 ldr x9,[sp,#224]
 str d0,[x9,x25,lsl#3]
 bl md2asm_pv_public_log
 ldr x18,[sp,#96]
 ldr x9,[sp,#232]
 str d0,[x9,x25,lsl#3]
 cbz x28,.Lnext_column
 sub x10,x20,x27
 mov x11,#1
 cmp x10,x11
 csel x10,x10,x11,ge
 mov x11,#0
 ldr d1,[sp,#296]
.Lfold_search:
 add x9,x27,x11
 sub x9,x9,#1
 madd x9,x9,x19,x25
 ldr d0,[x23,x9,lsl#3]
 fcmp d0,d1
 b.ge .Lfold_present
 add x11,x11,#1
 cmp x11,x10
 b.lo .Lfold_search
 fmov d0,xzr
 b .Lfold_publish
.Lfold_present:
 fmov d0,#1.0
.Lfold_publish:
 ldr x9,[sp,#240]
 str d0,[x9,x25,lsl#3]
.Lnext_column:
 add x25,x25,#1
 cmp x25,x22
 b.lo .Lcolumn
 mov w9,#0
 b .Lfree
.Linvalid_profile:
 mov w9,#2
.Lfree:
 str w9,[sp,#256]
 mov x0,x23
 bl free
 ldr x18,[sp,#96]
 ldr w0,[sp,#256]
 b .Lreturn
.Lallocation_bad:
 mov w0,#1
 b .Lreturn
.Lbad:
 mov w0,#2
.Lreturn:
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#384
 ret
.size md2asm_runtime_pv_level_pressure,.-md2asm_runtime_pv_level_pressure

/* x0 gives the first level, x1 the count and x2 the source iteration count. */
.type .Lfind_below,%function
.Lfind_below:
 cbz x1,.Lbelow_empty
 ldr d4,[sp,#296]
 mov x3,#1
 cbz x2,.Lbelow_single
 sub x4,x1,x2
.Lbelow_candidate:
 cmp x3,x4
 b.hi .Lbelow_fallback
 mov x5,#0
.Lbelow_consecutive:
 add x6,x0,x3
 sub x6,x6,#2
 add x6,x6,x5
 madd x6,x6,x19,x25
 ldr d0,[x23,x6,lsl#3]
 fcmp d0,d4
 b.ge .Lbelow_next
 add x5,x5,#1
 cmp x5,x2
 b.ls .Lbelow_consecutive
 mov x0,x3
 ret
.Lbelow_next:
 add x3,x3,#1
 b .Lbelow_candidate
.Lbelow_fallback:
 sub x3,x1,x2
 add x3,x3,#1
.Lbelow_single:
 cmp x3,x1
 b.hi .Lbelow_absent
 add x6,x0,x3
 sub x6,x6,#2
 madd x6,x6,x19,x25
 ldr d0,[x23,x6,lsl#3]
 fcmp d0,d4
 b.lt .Lbelow_found
 add x3,x3,#1
 b .Lbelow_single
.Lbelow_found:
 mov x0,x3
 ret
.Lbelow_absent:
 add x0,x1,#1
 ret
.Lbelow_empty:
 mov x0,#0
 ret
.size .Lfind_below,.-.Lfind_below
.section .rodata
.p2align 3
.Lsecurity:.quad 0x3ddb7cdfd9d7bdbb
.section .note.GNU-stack,"",%progbits

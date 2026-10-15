/* Selected header/name construction and empty auxiliary output ownership.
 * Original ABI F,PHY,Model,KSTEP*,TSTEP*,OFN1536,AUX856,DYN in x0..x7.
 * The source omits PTSTEP in its name calls; this wrapper does so as well.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_output_header_metadata_
.global md2asm_output_header_metadata_direct
.type md2asm_output_header_metadata_direct,%function
md2asm_output_header_metadata_:
md2asm_output_header_metadata_direct:
 sub sp,sp,#160
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x5
 mov x24,x6
 mov x25,x7
 mrs x9,fpcr
 str x9,[sp,#104]
 mrs x9,fpsr
 str x9,[sp,#112]
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 /* Source INTENT(OUT) cleanup precedes its first executable statement. */
 mov x0,x24
 bl md2asm_output_header_release_direct
 adrp x9,:got:__yomoph0_MOD_linc
 ldr x9,[x9,:got_lo12:__yomoph0_MOD_linc]
 ldr w9,[x9]
 cbnz w9,.Lheader_stop109
 ldr w9,[x20]
 cbnz w9,.Lheader_reject
 mov w9,#44740
 movk w9,#7,lsl #16
 ldr w10,[x19,x9]
 cbnz w10,.Lheader_reject
 mov w9,#44716
 movk w9,#7,lsl #16
 ldr w10,[x19,x9]
 cbnz w10,.Lheader_reject
 mov w9,#44756
 movk w9,#7,lsl #16
 ldr w10,[x19,x9]
 cbnz w10,.Lheader_reject
 mov w9,#44820
 movk w9,#7,lsl #16
 ldr w10,[x19,x9]
 cbnz w10,.Lheader_reject
 ldr w9,[x25,#3472]
 cmp w9,#1
 b.hi .Lheader_reject
 cbz w9,.Lheader_dynamic_valid
 ldr x9,[x25,#3480]
 ldr w9,[x9]
 cmp w9,#454
 b.ne .Lheader_reject
.Lheader_dynamic_valid:
 mov w9,#6008
 add x9,x19,x9
 ldr x26,[x9]
 cbz x26,.Lheader_reject
 ldr x10,[x9,#16]
 cmp x10,#1536
 b.ne .Lheader_reject
 ldrb w10,[x9,#28]
 cmp w10,#1
 b.ne .Lheader_reject
 ldr x10,[x9,#48]
 ldr x11,[x9,#56]
 sub x11,x11,x10
 cbnz x11,.Lheader_reject
 ldr x11,[x9,#40]
 ldr x12,[x9,#8]
 madd x12,x10,x11,x12
 mov x10,#1536
 madd x26,x12,x10,x26
 mov w9,#5932
 ldr w27,[x19,x9]
 mov x28,#0
.Lheader_name:
 adrp x9,.Lheader_name_offsets
 add x9,x9,:lo12:.Lheader_name_offsets
 ldr w9,[x9,x28,lsl #2]
 add x0,x26,x9
 add x1,x23,x9
 ldr w2,[x22]
 mov w3,w27
 adrp x9,:got:__yomoph0_MOD_ntimefmt
 ldr x9,[x9,:got_lo12:__yomoph0_MOD_ntimefmt]
 ldr w4,[x9]
 bl md2asm_make_output_name
 add x28,x28,#1
 cmp x28,#3
 b.ne .Lheader_name
 /* The selected SUFPTR2 request has no auxiliary field. */
 ldr w9,[x19,#580]
 cmp w9,#24
 b.ne .Lheader_reject
 ldr w9,[x19,#584]
 cmp w9,#86
 b.ne .Lheader_reject
 mov x0,#1
 bl malloc
 cbz x0,.Lheader_reject
 add x9,x24,#744
 str x0,[x9]
 mov x10,#-25
 str x10,[x9,#8]
 mov x10,#8
 str x10,[x9,#16]
 str x10,[x9,#32]
 mov x10,#3
 lsl x10,x10,#32
 mov x11,#3
 orr x10,x10,x11,lsl #40
 str x10,[x9,#24]
 mov x10,#1
 stp x10,x10,[x9,#40]
 mov x11,#24
 str x11,[x9,#56]
 stp x11,x10,[x9,#64]
 str xzr,[x9,#80]
 stp xzr,x10,[x9,#88]
 mov x10,#86
 str x10,[x9,#104]
 adrp x9,md2asm_output_header_counters
 add x9,x9,:lo12:md2asm_output_header_counters
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x9,[sp,#104]
 msr fpcr,x9
 ldr x9,[sp,#112]
 msr fpsr,x9
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#160
 ret
.size md2asm_output_header_metadata_direct,.-md2asm_output_header_metadata_direct
.Lheader_stop109:
 mov x0,#109
 mov x8,#94
 svc #0
 brk #0
.Lheader_reject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.section .rodata
.p2align 2
.Lheader_name_offsets: .word 0,256,768
.section .note.GNU-stack,"",%progbits

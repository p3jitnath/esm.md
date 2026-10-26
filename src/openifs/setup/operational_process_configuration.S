/* Contract: skills/md2asm/references/openifs/setup/operational_distributed_partition.md.
 * x0 text, x1 bytes, w2 world4. Return0 accepts the source process group,2 refuses.
 * Integer-only leaf. Preserve saved registers and numerical status.
 * Runtime mode adds x3 out8/x4 capacity and uses the runtime process contract. */
.arch armv8.2-a
.text
.p2align 4
#ifdef MD2ASM_RUNTIME_PROCESS_CONFIGURATION
#define MD2ASM_PROCESS_GROUP_ENTRY md2asm_runtime_process_configuration_group
#else
#define MD2ASM_PROCESS_GROUP_ENTRY md2asm_operational_process_configuration_group
#endif
.global MD2ASM_PROCESS_GROUP_ENTRY
.type MD2ASM_PROCESS_GROUP_ENTRY,%function
MD2ASM_PROCESS_GROUP_ENTRY:
#ifdef MD2ASM_RUNTIME_PROCESS_CONFIGURATION
 sub sp,sp,#16
 str x3,[sp]
 mov w16,w2
 mov w17,#0
 cmp w16,#1
 b.lt .Lprocess_group_reject
 cmp w16,#16,lsl#12
 b.gt .Lprocess_group_reject
 cbz x3,.Lprocess_group_reject
 tst x3,#7
 b.ne .Lprocess_group_reject
 cmp x4,#8
 b.lo .Lprocess_group_reject
 adds x10,x3,#8
 b.cs .Lprocess_group_reject
#else
 mov x16,x2
 cmp w16,#4
 b.ne .Lprocess_group_reject
#endif
 adr x6,.Lprocess_group_name1
 mov x12,#7
 cbz x0,.Lprocess_group_reject
 cbz x1,.Lprocess_group_reject
 adds x9,x0,x1
 b.cs .Lprocess_group_reject
#ifdef MD2ASM_RUNTIME_PROCESS_CONFIGURATION
 cmp x3,x9
 b.hs .Lruntime_text_output_separate
 cmp x0,x10
 b.lo .Lprocess_group_reject
.Lruntime_text_output_separate:
#endif
 mov x2,#0
 mov x13,#0
.Lprocess_group_line:
 cmp x2,x1
 b.hs .Lprocess_group_reject
 cmp x13,#10
 b.hs .Lprocess_group_skip_line
 ldrb w3,[x0,x2]
 cmp w3,#32
 b.eq .Lprocess_group_leading
 cmp w3,#9
 b.eq .Lprocess_group_leading
 cmp w3,#10
 b.eq .Lprocess_group_leading
 cmp w3,#13
 b.eq .Lprocess_group_leading
 cmp w3,#38
 b.ne .Lprocess_group_skip_line
 add x4,x2,#1
 mov x5,#0
.Lprocess_group_match:
 cmp x4,x1
 b.hs .Lprocess_group_reject
 ldrb w7,[x0,x4]
 ldrb w8,[x6,x5]
 cmp w7,w8
 b.ne .Lprocess_group_skip_line
 add x4,x4,#1
 add x5,x5,#1
 cmp x5,x12
 b.lo .Lprocess_group_match
 cmp x4,x1
 b.hs .Lprocess_group_reject
 ldrb w3,[x0,x4]
 cmp w3,#32
 b.eq .Lprocess_group_found
 cmp w3,#9
 b.eq .Lprocess_group_found
 cmp w3,#10
 b.eq .Lprocess_group_found
 cmp w3,#13
 b.eq .Lprocess_group_found
 cmp w3,#47
 b.eq .Lprocess_group_found
 cmp w3,#33
 b.ne .Lprocess_group_skip_line
.Lprocess_group_found:
 mov x2,x4
 mov x15,#0
.Lprocess_group_empty:
 cmp x2,x1
 b.hs .Lprocess_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#47
 b.eq .Lprocess_group_accept
 cmp w3,#33
 b.eq .Lprocess_group_comment
 cmp w3,#32
 b.eq .Lprocess_group_empty_next
 cmp w3,#9
 b.eq .Lprocess_group_empty_next
 cmp w3,#10
 b.eq .Lprocess_group_empty_next
 cmp w3,#13
 b.eq .Lprocess_group_empty_next
 b .Lassignment_start
.Lprocess_group_empty_next:
 add x2,x2,#1
 b .Lprocess_group_empty
.Lprocess_group_comment:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Lprocess_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Lprocess_group_comment
 b .Lprocess_group_empty_next
.Lprocess_group_leading:
 add x2,x2,#1
 add x13,x13,#1
 cmp w3,#10
 csel x13,xzr,x13,eq
 b .Lprocess_group_line
.Lprocess_group_skip_line:
 cmp x2,x1
 b.hs .Lprocess_group_reject
 ldrb w3,[x0,x2]
 add x2,x2,#1
 cmp w3,#10
 b.ne .Lprocess_group_skip_line
 mov x13,#0
 b .Lprocess_group_line
/* Check all consumed values before accepting this populated group. */
.Lassignment_start:
 mov x14,#0
.Lassignment_try:
 adr x6,.Lprocess_members
 add x6,x6,x14,lsl#4
 ldr w7,[x6]
 ldr w12,[x6,#4]
 adr x6,.Lprocess_strings
 add x6,x6,x7
 mov x4,x2
 mov x5,#0
.Lassignment_name:
 cmp x4,x1
 b.hs .Lprocess_group_reject
 ldrb w7,[x0,x4]
 cmp w7,#97
 b.lo .Lname_upper_ready
 cmp w7,#122
 b.hi .Lname_upper_ready
 sub w7,w7,#32
.Lname_upper_ready:
 ldrb w8,[x6,x5]
 cmp w7,w8
 b.ne .Lassignment_next_member
 add x4,x4,#1
 add x5,x5,#1
 cmp x5,x12
 b.lo .Lassignment_name
 cmp x4,x1
 b.hs .Lprocess_group_reject
 ldrb w7,[x0,x4]
 cmp w7,#61
 b.eq .Lmember_boundary_ready
 cmp w7,#32
 b.eq .Lmember_boundary_ready
 cmp w7,#9
 b.eq .Lmember_boundary_ready
 cmp w7,#10
 b.eq .Lmember_boundary_ready
 cmp w7,#13
 b.eq .Lmember_boundary_ready
 cmp w7,#33
 b.ne .Lassignment_next_member
.Lmember_boundary_ready:
 mov x9,#1
 lsl x9,x9,x14
 tst x15,x9
 b.ne .Lprocess_group_reject
 orr x15,x15,x9
 mov x2,x4
 mov x13,#0
 b .Lassignment_space
.Lassignment_next_member:
 add x14,x14,#1
 cmp x14,#13
 b.lo .Lassignment_try
 b .Lprocess_group_reject
.Lassignment_space:
 cmp x2,x1
 b.hs .Lprocess_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#32
 b.eq .Lassignment_space_next
 cmp w3,#9
 b.eq .Lassignment_space_next
 cmp w3,#10
 b.eq .Lassignment_space_next
 cmp w3,#13
 b.eq .Lassignment_space_next
 cmp w3,#33
 b.eq .Lassignment_comment
 cbnz x13,.Lassignment_value
 cmp w3,#61
 b.ne .Lprocess_group_reject
 mov x13,#1
.Lassignment_space_next:
 add x2,x2,#1
 b .Lassignment_space
.Lassignment_comment:
 add x2,x2,#1
 cmp x2,x1
 b.hs .Lprocess_group_reject
 ldrb w3,[x0,x2]
 cmp w3,#10
 b.ne .Lassignment_comment
 b .Lassignment_space_next
.Lassignment_value:
 adr x6,.Lprocess_members
 add x6,x6,x14,lsl#4
 ldr w10,[x6,#8]
 ldr w11,[x6,#12]
 cmn w10,#1
 csel w10,w16,w10,eq
 cbnz w11,.Lassignment_logical
 mov x4,x2
 mov w9,#0
 mov x5,#0
.Lassignment_integer:
 cmp x4,x1
 b.hs .Lprocess_group_reject
 ldrb w7,[x0,x4]
 sub w8,w7,#48
 cmp w8,#9
 b.hi .Lassignment_integer_done
 movz w7,#34464
 movk w7,#1,lsl#16
 cmp w9,w7
 b.hi .Lprocess_group_reject
 mov w7,#10
 madd w9,w9,w7,w8
 add x4,x4,#1
 add x5,x5,#1
 b .Lassignment_integer
.Lassignment_integer_done:
 cbz x5,.Lprocess_group_reject
#ifdef MD2ASM_RUNTIME_PROCESS_CONFIGURATION
 cmp x14,#9
 b.ne .Lruntime_other_integer
 mov w7,#0x4240
 movk w7,#0xf,lsl#16
 cmp w9,w7
 b.hi .Lprocess_group_reject
 mov w17,w9
 b .Lassignment_value_end
.Lruntime_other_integer:
 cmp x14,#8
 b.ne .Lruntime_integer_compare
 cbnz w9,.Lruntime_integer_compare
 mov w9,#1
.Lruntime_integer_compare:
#endif
 cmp w9,w10
 b.ne .Lprocess_group_reject
 b .Lassignment_value_end
.Lassignment_logical:
 mov x13,#0
 cmp w3,#46
 b.ne .Lassignment_logical_word
 mov x13,#1
 add x2,x2,#1
.Lassignment_logical_word:
 adr x6,.Lfalse_word
 mov x12,#5
 cbz w10,.Lassignment_word_ready
 adr x6,.Ltrue_word
 mov x12,#4
.Lassignment_word_ready:
 mov x4,x2
 mov x5,#0
.Lassignment_logical_letter:
 cmp x4,x1
 b.hs .Lprocess_group_reject
 ldrb w7,[x0,x4]
 bic w7,w7,#32
 ldrb w8,[x6,x5]
 cmp w7,w8
 b.ne .Lprocess_group_reject
 add x4,x4,#1
 add x5,x5,#1
 cmp x5,x12
 b.lo .Lassignment_logical_letter
 cbz x13,.Lassignment_value_end
 cmp x4,x1
 b.hs .Lprocess_group_reject
 ldrb w3,[x0,x4]
 cmp w3,#46
 b.ne .Lprocess_group_reject
 add x4,x4,#1
.Lassignment_value_end:
 cmp x4,x1
 b.hs .Lprocess_group_reject
 ldrb w3,[x0,x4]
 mov x2,x4
 cmp w3,#47
 b.eq .Lprocess_group_accept
 cmp w3,#33
 b.eq .Lprocess_group_comment
 cmp w3,#44
 b.eq .Lprocess_group_empty_next
 cmp w3,#32
 b.eq .Lprocess_group_empty_next
 cmp w3,#9
 b.eq .Lprocess_group_empty_next
 cmp w3,#10
 b.eq .Lprocess_group_empty_next
 cmp w3,#13
 b.eq .Lprocess_group_empty_next
 b .Lprocess_group_reject
.Lprocess_group_accept:
 mov x9,#8191
 cmp x15,x9
 b.ne .Lprocess_group_reject
#ifdef MD2ASM_RUNTIME_PROCESS_CONFIGURATION
 ldr x9,[sp]
 stp w16,w17,[x9]
 add sp,sp,#16
#endif
 mov w0,#0
 ret
.Lprocess_group_reject:
#ifdef MD2ASM_RUNTIME_PROCESS_CONFIGURATION
 add sp,sp,#16
#endif
 mov w0,#2
 ret
.size MD2ASM_PROCESS_GROUP_ENTRY,.-MD2ASM_PROCESS_GROUP_ENTRY
.section .rodata
.p2align 2
.Lprocess_group_name1: .ascii "NAMPAR0"
.Lfalse_word: .ascii "FALSE"
.Ltrue_word: .ascii "TRUE"
.p2align 2
.Lprocess_members:
 .word 0,10,0,1
 .word 10,6,1,1
 .word 16,15,0,1
 .word 31,10,0,1
 .word 41,9,0,1
 .word 50,11,496,0
 .word 61,14,0,1
 .word 75,15,0,1
 .word 90,5,-1,0
 .word 95,11,1280,0
 .word 106,7,1,0
 .word 113,7,1,0
 .word 120,8,0,0
.Lprocess_strings:
 .ascii "LXML_STATS"
 .ascii "LSTATS"
 .ascii "LDETAILED_STATS"
 .ascii "LSYNCSTATS"
 .ascii "LSTATSCPU"
 .ascii "NPRNT_STATS"
 .ascii "LBARRIER_STATS"
 .ascii "LBARRIER_STATS2"
 .ascii "NPROC"
 .ascii "NSPECRESMIN"
 .ascii "NOUTPUT"
 .ascii "MP_TYPE"
 .ascii "MBX_SIZE"
.section .note.GNU-stack,"",%progbits

/* Source-declared TYPE_GFL_COMP defaults for fresh owned records.
 * Contract: skills/md2asm/references/openifs/setup/field_component_defaults.md in the repository.
 * x0 points to count*368 zero bytes; w1 is count1..64. Return w0=0 or2.
 * Integer-only leaf; no original metadata, data, callable or external service.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_field_component_defaults
.type md2asm_initialize_field_component_defaults,%function
md2asm_initialize_field_component_defaults:
 cbz x0,.Lcomponent_defaults_reject
 tst x0,#7
 b.ne .Lcomponent_defaults_reject
 sub w9,w1,#1
 cmp w9,#63
 b.hi .Lcomponent_defaults_reject
 mrs x9,fpcr
 cbnz x9,.Lcomponent_defaults_reject
 mov w9,#368
 umull x2,w1,w9
 adds x3,x0,x2
 b.cs .Lcomponent_defaults_reject
 mov x4,#0
.Lcomponent_defaults_check_fresh:
 ldr x9,[x0,x4]
 cbnz x9,.Lcomponent_defaults_reject
 add x4,x4,#8
 cmp x4,x2
 b.lo .Lcomponent_defaults_check_fresh
 mov x5,x0
 mov w6,w1
 adr x7,.Lcomponent_mp_sentinel
 ldr w8,[x7]
 mov x9,#0x2020202020202020
 mov w10,#0x20202020
 mov w11,#-999
 mov w12,#1
 mov w13,#-1
.Lcomponent_defaults_one:
 stp x9,x9,[x5]                    /* CNAME: sixteen spaces. */
 str w11,[x5,#16]                  /* IGRBCODE. */
 stp wzr,wzr,[x5,#20]
 stp wzr,wzr,[x5,#28]
 stp wzr,wzr,[x5,#36]
 str w12,[x5,#44]                  /* LGPINGP. */
 stp xzr,xzr,[x5,#48]
 str xzr,[x5,#64]
 stp xzr,xzr,[x5,#72]              /* R and RCP. */
 stp xzr,xzr,[x5,#88]
 stp xzr,xzr,[x5,#104]
 str xzr,[x5,#120]                 /* REFVALI. */
 str xzr,[x5,#128]
 str wzr,[x5,#136]
 str xzr,[x5,#144]                 /* REFVALC. */
 str wzr,[x5,#152]
 str w10,[x5,#156]                 /* CSLINT: twelve spaces. */
 str w10,[x5,#160]
 str w10,[x5,#164]
 stp w8,w8,[x5,#168]
 stp w8,w8,[x5,#176]
 stp w8,w8,[x5,#184]
 stp w8,w8,[x5,#192]
 stp w8,w8,[x5,#200]
 stp w8,w8,[x5,#208]
 stp w8,w8,[x5,#216]
 stp w8,w8,[x5,#224]
 str w13,[x5,#352]                 /* IFID. */
 str xzr,[x5,#360]                 /* PREVIOUS. */
 add x5,x5,#368
 subs w6,w6,#1
 b.ne .Lcomponent_defaults_one
 mov w0,#0
 ret
.Lcomponent_defaults_reject:
 mov w0,#2
 ret
.size md2asm_initialize_field_component_defaults,.-md2asm_initialize_field_component_defaults
.section .rodata
.p2align 2
.Lcomponent_mp_sentinel: .word -99999999
.section .note.GNU-stack,"",%progbits

/* Bind fifteen source model-component aliases without reading model values.
 * Contract: skills/md2asm/references/openifs/setup/model_module_aliases.md.
 * x0=readonly MODEL4275088B,x1=readonly table15 writable pointer-word addresses.
 * Return w0=0 or2 before any store. Buffers and output words are disjoint.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_set_model_component_aliases
.type md2asm_set_model_component_aliases,%function
md2asm_set_model_component_aliases:
 cbz x0,.Lmodel_alias_reject
 cbz x1,.Lmodel_alias_reject
 orr x9,x0,x1
 tst x9,#7
 b.ne .Lmodel_alias_reject
 adr x9,.Lmodel_record_bytes
 ldr x9,[x9]
 adds x2,x0,x9
 b.cs .Lmodel_alias_reject
 adds x3,x1,#120
 b.cs .Lmodel_alias_reject
 cmp x0,x3
 b.hs .Lmodel_alias_destinations
 cmp x1,x2
 b.lo .Lmodel_alias_reject
.Lmodel_alias_destinations:
 mov x4,#0
.Lmodel_alias_validate:
 ldr x5,[x1,x4,lsl#3]
 cbz x5,.Lmodel_alias_reject
 tst x5,#7
 b.ne .Lmodel_alias_reject
 adds x6,x5,#8
 b.cs .Lmodel_alias_reject
 cmp x5,x2
 b.hs .Lmodel_alias_check_table
 cmp x0,x6
 b.lo .Lmodel_alias_reject
.Lmodel_alias_check_table:
 cmp x5,x3
 b.hs .Lmodel_alias_distinct
 cmp x1,x6
 b.lo .Lmodel_alias_reject
.Lmodel_alias_distinct:
 mov x7,#0
.Lmodel_alias_previous:
 cmp x7,x4
 b.hs .Lmodel_alias_validated
 ldr x8,[x1,x7,lsl#3]
 cmp x8,x5
 b.eq .Lmodel_alias_reject
 add x7,x7,#1
 b .Lmodel_alias_previous
.Lmodel_alias_validated:
 add x4,x4,#1
 cmp x4,#15
 b.lo .Lmodel_alias_validate
 adr x9,.Lmodel_component_offsets
 mov x4,#0
.Lmodel_alias_store:
 ldr w10,[x9,x4,lsl#2]
 add x10,x0,w10,uxtw
 ldr x5,[x1,x4,lsl#3]
 str x10,[x5]
 add x4,x4,#1
 cmp x4,#15
 b.lo .Lmodel_alias_store
 mov w0,#0
 ret
.Lmodel_alias_reject:
 mov w0,#2
 ret
.size md2asm_set_model_component_aliases,.-md2asm_set_model_component_aliases
/* Original hook-disabled MODEL_UNSET does not change aliases. */
.p2align 4
.global md2asm_unset_model_component_aliases
.type md2asm_unset_model_component_aliases,%function
md2asm_unset_model_component_aliases:
 ret
.size md2asm_unset_model_component_aliases,.-md2asm_unset_model_component_aliases
.section .rodata
.p2align 3
.Lmodel_record_bytes: .quad 4275088
.Lmodel_component_offsets:
 .word 1577368 /* YRDPHY */
 .word 192 /* YGFL */
 .word 1608728 /* YRERAD */
 .word 1626696 /* YREAERATM */
 .word 1588296 /* YREPHLI */
 .word 1589160 /* YREAERLID */
 .word 1590360 /* YREAERSNK */
 .word 1591240 /* YREAERSRC */
 .word 1591584 /* YREAERVOL */
 .word 1577888 /* YREPHY */
 .word 4143760 /* YRPHY */
 .word 4144856 /* YRPHY0 */
 .word 4148312 /* YRPHY1 */
 .word 4150008 /* YRPHY2 */
 .word 4219384 /* YRLOUIS */
.section .note.GNU-stack,"",%progbits

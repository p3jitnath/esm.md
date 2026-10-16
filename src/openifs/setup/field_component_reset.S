/* Complete source-defined FALSIFY_GFL_COMP stores across owned records.
 * Contract: skills/md2asm/references/openifs/setup/field_component_reset.md in the repository.
 * x0 records[count*368],w1 count1..2163,w2 owned sentinel=-99999.
 * Return w0=0/2. No original data, callable, type or external service.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_reset_grid_field_components
.type md2asm_reset_grid_field_components,%function
md2asm_reset_grid_field_components:
 cbz x0,.Lcomponent_reset_reject
 tst x0,#7
 b.ne .Lcomponent_reset_reject
 sub w9,w1,#1
 cmp w9,#2162
 b.hi .Lcomponent_reset_reject
 adr x9,.Lcomponent_undefined
 ldr w9,[x9]
 cmp w2,w9
 b.ne .Lcomponent_reset_reject
 mrs x9,fpcr
 cbnz x9,.Lcomponent_reset_reject
 mov w9,#368
 umull x3,w1,w9
 adds x4,x0,x3
 b.cs .Lcomponent_reset_reject
 mov x5,x0
 mov w6,w1
 mov x9,#0x2020202020202020
 mov w10,#-999
 mov w11,#1
 mov w12,#0x20202020
 mov w13,#-99
.Lcomponent_reset_one:
 stp x9,x9,[x5]
 str w10,[x5,#16]
 str wzr,[x5,#20]
 str wzr,[x5,#24]
 str wzr,[x5,#28]
 str wzr,[x5,#32]
 str wzr,[x5,#36]
 str xzr,[x5,#120]
 str wzr,[x5,#40]
 str w11,[x5,#44]
 str wzr,[x5,#108]
 str wzr,[x5,#112]
 str wzr,[x5,#52]
 str wzr,[x5,#56]
 str wzr,[x5,#60]
 str wzr,[x5,#64]
 str wzr,[x5,#68]
 str wzr,[x5,#88]
 str wzr,[x5,#92]
 str wzr,[x5,#96]
 str wzr,[x5,#100]
 str wzr,[x5,#104]
 str wzr,[x5,#116]
 str wzr,[x5,#128]
 str wzr,[x5,#132]
 str wzr,[x5,#136]
 str xzr,[x5,#144]
 str wzr,[x5,#152]
 str w12,[x5,#156]
 str w12,[x5,#160]
 str w12,[x5,#164]
 str xzr,[x5,#72]
 str xzr,[x5,#80]
 str wzr,[x5,#232]
 str wzr,[x5,#236]
 str xzr,[x5,#240]
 str w2,[x5,#168]
 str w2,[x5,#172]
 str w2,[x5,#176]
 str w2,[x5,#180]
 str w2,[x5,#184]
 str w2,[x5,#188]
 str w2,[x5,#192]
 str w2,[x5,#196]
 str w2,[x5,#200]
 str w13,[x5,#204]
 str w2,[x5,#208]
 str w2,[x5,#212]
 str w2,[x5,#216]
 str w2,[x5,#220]
 str w2,[x5,#224]
 str w2,[x5,#228]
 str xzr,[x5,#360]
 add x5,x5,#368
 subs w6,w6,#1
 b.ne .Lcomponent_reset_one
 mov w0,#0
 ret
.Lcomponent_reset_reject:
 mov w0,#2
 ret
.size md2asm_reset_grid_field_components,.-md2asm_reset_grid_field_components
.section .rodata
.p2align 2
.Lcomponent_undefined: .word -99999
.section .note.GNU-stack,"",%progbits

/* Vertical default/reset controls for an empty NAMCVER group.
 * Contract: skills/md2asm/references/openifs/setup/vertical_coordinate_configuration.md.
 * ABI x0=aligned216-byteTCVER, w1=LECMWF,w2=LDNHDYN_GEOM,w3=LR2D.
 * Return w0=0 or2. Source-unwritten members and padding retain input bytes.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_vertical_configuration
.type md2asm_initialize_vertical_configuration,%function
md2asm_initialize_vertical_configuration:
 cbz x0,.Lvertical_config_reject
 tst x0,#7
 b.ne .Lvertical_config_reject
 orr w9,w1,w2
 orr w9,w9,w3
 cmp w9,#1
 b.hi .Lvertical_config_reject
 /* The default finite-element path requires all three named conditions. */
 orr w10,w2,w3
 eor w10,w10,#1
 and w10,w10,w1
 str w1,[x0]
 str wzr,[x0,#4]
 adr x9,.Lvertical_config_rhydr
 ldr x11,[x9,w1,uxtw#3]
 str x11,[x0,#8]
 str wzr,[x0,#16]
 str wzr,[x0,#20]
 str wzr,[x0,#24]
 mov w11,#3
 mul w11,w10,w11
 str w11,[x0,#28]
 add w12,w11,#1
 str w12,[x0,#32]
 str w11,[x0,#36]
 str w11,[x0,#40]
 str wzr,[x0,#44]
 str wzr,[x0,#48]
 str w10,[x0,#52]
 str wzr,[x0,#56]
 str wzr,[x0,#60]
 str wzr,[x0,#64]
 str wzr,[x0,#68]
 str wzr,[x0,#72]
 /* RLAPL2PI at80 and padding76..79 remain untouched. */
 str wzr,[x0,#88]
 str wzr,[x0,#92]
 str wzr,[x0,#96]
 str wzr,[x0,#100]
 str wzr,[x0,#104]
 str w10,[x0,#108]
 str wzr,[x0,#112]
 /* RVFE_CENTRI at120 and padding116..119 remain untouched. */
 str xzr,[x0,#128]
 movz x11,#0x3fe0,lsl#48
 str x11,[x0,#136]
 movz x11,#0x3ff0,lsl#48
 str x11,[x0,#144]
 str wzr,[x0,#152]
 str wzr,[x0,#156]
 str wzr,[x0,#160]
 str w10,[x0,#164]
 str wzr,[x0,#168]
 str wzr,[x0,#172]
 str wzr,[x0,#176]
 str wzr,[x0,#180]
 str wzr,[x0,#184]
 /* Padding188..191 remains untouched. */
 str xzr,[x0,#192]
 str xzr,[x0,#200]
 str xzr,[x0,#208]
 mov w0,#0
 ret
.Lvertical_config_reject:
 mov w0,#2
 ret
.size md2asm_initialize_vertical_configuration,.-md2asm_initialize_vertical_configuration
.p2align 3
.Lvertical_config_rhydr:
 .quad 0x3ff0000000000000,0x3fe62e42fefa39ef
.section .note.GNU-stack,"",%progbits

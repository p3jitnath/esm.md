// Contract: skills/md2asm/references/openifs/fullpos/field_descriptors.md.
/* Source declaration defaults for fresh TAFN storage. Borrowed owner bases are absent. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_fullpos_field_descriptor_defaults
.type md2asm_initialize_fullpos_field_descriptor_defaults,%function
md2asm_initialize_fullpos_field_descriptor_defaults:
 cbz x0,.Ldefaults_bad
 tst x0,#7
 b.ne .Ldefaults_bad
 movz x9,#38616
 movk x9,#7,lsl#16
 cmp x1,x9
 b.lo .Ldefaults_bad
 adds x10,x0,x9
 b.cs .Ldefaults_bad
 mov x2,x0
 mov x3,#1253
 movz x4,#31073
 movk x4,#65534,lsl#16
 movk x4,#99,lsl#32
 movz x5,#65527
 movk x5,#65535,lsl#16
 mov w6,#1
 mov x7,#-1
 movz x8,#8224
 movk x8,#8224,lsl#16
 movk x8,#8224,lsl#32
 movk x8,#8224,lsl#48
 mov w9,#10
 mov w10,#-1
.Ldefaults_dynamic:
 str x4,[x2]
 str x5,[x2,#8]
 stp xzr,xzr,[x2,#16]
 str w6,[x2,#32]
 str wzr,[x2,#40]
 stur x8,[x2,#44]
 stur x8,[x2,#52]
 stur x8,[x2,#60]
 stur x8,[x2,#68]
 stur x8,[x2,#76]
 stur x7,[x2,#84]
 stur x7,[x2,#92]
 str w9,[x2,#100]
 str w10,[x2,#104]
 add x2,x2,#112
 subs x3,x3,#1
 b.ne .Ldefaults_dynamic
 adrp x11,.Lphysical_defaults
 add x11,x11,:lo12:.Lphysical_defaults
 ldp x4,x5,[x11]
 ldp x6,x7,[x11,#16]
 ldp x8,x9,[x11,#32]
 ldp x10,x11,[x11,#48]
 mov x3,#5577
.Ldefaults_physical:
 stp x4,x5,[x2]
 stp x6,x7,[x2,#16]
 stp x8,x9,[x2,#32]
 stp x10,x11,[x2,#48]
 add x2,x2,#64
 subs x3,x3,#1
 b.ne .Ldefaults_physical
 movz x9,#38544
 movk x9,#7,lsl#16
 str xzr,[x0,x9]
 mov w0,#0
 ret
.Ldefaults_bad:
 mov w0,#2
 ret
.section .rodata
.p2align 3
.Lphysical_defaults:
 .word -9999,99,-9,0,0,0,1,0,0,1
 .ascii "                        "
.section .note.GNU-stack,"",%progbits

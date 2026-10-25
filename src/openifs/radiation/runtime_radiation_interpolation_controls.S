/* Publish the source-selected early RI/RO controls into their actual MODEL owner.
 * Contract: skills/md2asm/references/openifs/radiation/runtime_radiation_grid_from_prefix.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_publish_runtime_radiation_interpolation_controls
.type md2asm_publish_runtime_radiation_interpolation_controls,%function
md2asm_publish_runtime_radiation_interpolation_controls:
 cbz x0,.Lbad
 cbz x2,.Lbad
 orr x8,x0,x2
 tst x8,#7
 b.ne .Lbad
 ldr x8,=4275088
 cmp x1,x8
 b.lo .Lbad
 adds x9,x0,x8
 b.cs .Lbad
 cmp x3,#744
 b.lo .Lbad
 adds x10,x2,#744
 b.cs .Lbad
 cmp x0,x10
 b.hs .Laparte
 cmp x2,x9
 b.lo .Lbad
.Laparte:
 ldr x8,=1577924
 ldr w9,[x0,x8]
 cmp w9,#1
 b.ne .Lbad
 ldr x8,=1608752
 ldr w9,[x0,x8]
 sub w9,w9,#2
 cmp w9,#1
 b.hi .Lbad
 ldr x8,=1609236
 ldr w9,[x0,x8]
 cmp w9,#1
 b.ne .Lbad
 ldr w8,[x2,#688]
 cmp w8,#0
 b.ne .Lbad
 ldr w8,[x2,#692]
 cmp w8,#0
 b.ne .Lbad
 ldr w8,[x2,#696]
 cmp w8,#0
 b.ne .Lbad
 ldr w8,[x2,#700]
 cmp w8,#0
 b.ne .Lbad
 ldr w8,[x2,#712]
 cmp w8,#0
 b.ne .Lbad
 ldr w8,[x2,#716]
 cmp w8,#0
 b.ne .Lbad
 ldr w8,[x2,#720]
 cmp w8,#0
 b.ne .Lbad
 ldr w8,[x2,#724]
 cmp w8,#0
 b.ne .Lbad
 ldr w8,[x2,#704]
 cmp w8,#1
 b.ne .Lbad
 ldr w8,[x2,#728]
 cmp w8,#1
 b.ne .Lbad
 // RI_NSLWIDEN: namespace688 -> MODEL4123916.
 ldr w8,[x2,#688]
 ldr x9,=4123916
 str w8,[x0,x9]
 // RI_NSLWIDES: namespace692 -> MODEL4123920.
 ldr w8,[x2,#692]
 ldr x9,=4123920
 str w8,[x0,x9]
 // RI_NSLWIDEW: namespace696 -> MODEL4123928.
 ldr w8,[x2,#696]
 ldr x9,=4123928
 str w8,[x0,x9]
 // RI_NSLWIDEE: namespace700 -> MODEL4123924.
 ldr w8,[x2,#700]
 ldr x9,=4123924
 str w8,[x0,x9]
 // RO_NSLWIDEN: namespace712 -> MODEL4125716.
 ldr w8,[x2,#712]
 ldr x9,=4125716
 str w8,[x0,x9]
 // RO_NSLWIDES: namespace716 -> MODEL4125720.
 ldr w8,[x2,#716]
 ldr x9,=4125720
 str w8,[x0,x9]
 // RO_NSLWIDEW: namespace720 -> MODEL4125728.
 ldr w8,[x2,#720]
 ldr x9,=4125728
 str w8,[x0,x9]
 // RO_NSLWIDEE: namespace724 -> MODEL4125724.
 ldr w8,[x2,#724]
 ldr x9,=4125724
 str w8,[x0,x9]
 // RI_LSLONDEM: namespace704 -> MODEL4123600.
 ldr w8,[x2,#704]
 ldr x9,=4123600
 str w8,[x0,x9]
 // RO_LSLONDEM: namespace728 -> MODEL4125400.
 ldr w8,[x2,#728]
 ldr x9,=4125400
 str w8,[x0,x9]
 ldr x9,=4123584
 str wzr,[x0,x9]
 ldr x9,=4125384
 str wzr,[x0,x9]
 str wzr,[x2,#708]
 str wzr,[x2,#732]
 mov w0,#0
 ret
.Lbad:
 mov w0,#2
 ret
.size md2asm_publish_runtime_radiation_interpolation_controls,.-md2asm_publish_runtime_radiation_interpolation_controls
.section .note.GNU-stack,"",%progbits

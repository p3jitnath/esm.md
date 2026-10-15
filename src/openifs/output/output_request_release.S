// Solver contract skills/md2asm/references/openifs/output/output_request_release.md.
/* Source output-request and auxiliary-header release children.
 * INTENT(OUT) cleanup/default initialization precedes explicit request release.
 * Only libc free/memset/error-slot services are used. No numerical stage.
 */
.arch armv8.2-a
.text
.p2align 4
.macro release_enter
 sub sp,sp,#128
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
 mrs x25,fpcr
 mrs x26,fpsr
 bl __errno_location
 mov x27,x0
 ldr w28,[x0]
.endm
.macro release_return
 str w28,[x27]
 msr fpcr,x25
 msr fpsr,x26
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#128
 ret
.endm
.macro release_count index
 adrp x9,.Lrelease_counts
 add x9,x9,:lo12:.Lrelease_counts
 ldr x10,[x9,#(8*\index)]
 add x10,x10,#1
 str x10,[x9,#(8*\index)]
.endm
/* x0 owner, x1 u32 descriptor-offset table, x2 entry count. */
.type .Lrelease_descriptor_table,%function
.Lrelease_descriptor_table:
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x19,x0
 mov x20,x1
 mov x21,x2
.Lrelease_next:
 cbz x21,.Lrelease_done
 ldr w9,[x20],#4
 add x22,x19,w9,uxtw
 ldr x0,[x22]
 cbz x0,.Lrelease_skip
 bl free
 str xzr,[x22]
.Lrelease_skip:
 sub x21,x21,#1
 b .Lrelease_next
.Lrelease_done:
 ldr x18,[sp,#48]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x29,x30,[sp],#64
 ret
.size .Lrelease_descriptor_table,.-.Lrelease_descriptor_table
/* x0 TFPFIELDS1424, x1 TRQFP744, x2 TRQFPDYN3696; disjoint owners. */
.global md2asm_fullpos_request_release_direct
.type md2asm_fullpos_request_release_direct,%function
md2asm_fullpos_request_release_direct:
 release_enter
 release_count 0
 mov x0,x20
 adrp x1,.Lphysical_request_descriptors
 add x1,x1,:lo12:.Lphysical_request_descriptors
 mov x2,#11
 bl .Lrelease_descriptor_table
 mov x0,x20
 mov x1,#0
 mov x2,#744
 bl memset
 mov x0,x21
 adrp x1,.Ldynamical_request_descriptors
 add x1,x1,:lo12:.Ldynamical_request_descriptors
 mov x2,#45
 bl .Lrelease_descriptor_table
 mov x0,x21
 mov x1,#0
 mov x2,#3696
 bl memset
 mov w9,#1
 str w9,[x21,#12]
 str w9,[x21,#508]
 str w9,[x21,#1004]
 str w9,[x21,#1500]
 str w9,[x21,#1996]
 str w9,[x21,#2492]
 str w9,[x21,#2988]
 mov x0,x19
 adrp x1,.Lfield_request_descriptors
 add x1,x1,:lo12:.Lfield_request_descriptors
 mov x2,#21
 bl .Lrelease_descriptor_table
 release_return
.size md2asm_fullpos_request_release_direct,.-md2asm_fullpos_request_release_direct
.global md2asm_fullpos_request_release_
.set md2asm_fullpos_request_release_,md2asm_fullpos_request_release_direct
/* x0 FPOSBUF856: implicit release/default initialization, no explicit body. */
.p2align 4
.global md2asm_output_header_release_direct
.type md2asm_output_header_release_direct,%function
md2asm_output_header_release_direct:
 release_enter
 release_count 1
 mov x0,x19
 adrp x1,.Lheader_descriptors
 add x1,x1,:lo12:.Lheader_descriptors
 mov x2,#12
 bl .Lrelease_descriptor_table
 mov x0,x19
 mov x1,#0
 mov x2,#856
 bl memset
 release_return
.size md2asm_output_header_release_direct,.-md2asm_output_header_release_direct
.global md2asm_output_header_release_
.set md2asm_output_header_release_,md2asm_output_header_release_direct
.p2align 4
.global md2asm_output_release_count_get
.type md2asm_output_release_count_get,%function
md2asm_output_release_count_get:
 cmp x0,#2
 b.hs .Lrelease_no_count
 adrp x1,.Lrelease_counts
 add x1,x1,:lo12:.Lrelease_counts
 ldr x0,[x1,x0,lsl #3]
 ret
.Lrelease_no_count:
 mov x0,#0
 ret
.size md2asm_output_release_count_get,.-md2asm_output_release_count_get
.section .rodata
.p2align 3
.Lphysical_request_descriptors:
 .word 8,72,136,200,264,328,392,456,520,616,680
.Ldynamical_request_descriptors:
 .word 16,80,144,208,296,384,512,576,640,704,792,880,1008,1072,1136,1200,1288,1376,1504,1568,1632,1696,1784,1872,2000,2064,2128,2192,2280,2368,2496,2560,2624,2688,2776,2864,2992,3056,3120,3184,3272,3360,3480,3544,3608
.Lfield_request_descriptors:
 .word 0,64,128,192,256,320,384,448,512,576,640,704,768,832,896,960,1024,1088,1152,1216,1280
.Lheader_descriptors:
 .word 8,72,136,200,264,328,392,456,520,616,680,744
.bss
.p2align 3
.Lrelease_counts: .zero 16
.section .note.GNU-stack,"",%progbits

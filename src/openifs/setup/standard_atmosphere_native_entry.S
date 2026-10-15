// Solver contract skills/md2asm/references/openifs/setup/standard_atmosphere_native_entry.md.
/* Native SUSTA entry, selected empty NAMSTA route, local revision1.
 * Contract: skills/md2asm/references/openifs/setup/standard_atmosphere_native_entry.md in this directory.
 * Original GNU ABI x0 Geometry. No original callable/constructor/vtable.
 * Live scalar/reference module-data addresses are explicit compatibility.
 */
.arch armv8.2-a
.text
.p2align 4
.global susta_
.type susta_,%function
susta_:
 sub sp,sp,#896
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,#0
 mov w21,#-1
 mrs x9,fpcr
 str x9,[sp,#80]
 mrs x9,fpsr
 str x9,[sp,#88]
 bl __errno_location
 mov x24,x0
 ldr w9,[x24]
 str w9,[sp,#96]
 movz x0,#1
 movk x0,#4,lsl#16
 bl malloc
 cbz x0,.Latmosphere_native_fail
 mov x20,x0
 adr x0,.Latmosphere_namelist
 mov w1,#0
 mov w2,#0
 bl open
 tbnz w0,#31,.Latmosphere_native_fail
 mov w21,w0
 mov x22,#0
.Latmosphere_read:
 mov w0,w21
 add x1,x20,x22
 movz x2,#1
 movk x2,#4,lsl#16
 sub x2,x2,x22
 bl read
 tbnz x0,#63,.Latmosphere_read_error
 cbz x0,.Latmosphere_read_done
 add x22,x22,x0
 movz x9,#1
 movk x9,#4,lsl#16
 cmp x22,x9
 b.hs .Latmosphere_native_fail
 b .Latmosphere_read
.Latmosphere_read_error:
 ldr w9,[x24]
 cmp w9,#4
 b.eq .Latmosphere_read
 b .Latmosphere_native_fail
.Latmosphere_read_done:
 mov w0,w21
 bl close
 cbnz w0,.Latmosphere_native_fail
 mov w21,#-1
 mov x0,x20
 mov x1,x22
 bl md2asm_empty_atmosphere_group
 cbnz w0,.Latmosphere_native_fail
 mov x0,x20
 bl free
 mov x20,#0
 /* Load the original live physical inputs, without calling their provider. */
 adrp x9,:got:__yomcst_MOD_rg
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rg]
 ldr d0,[x9]
 str d0,[sp,#208]
 adrp x9,:got:__yomcst_MOD_rd
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rd]
 ldr d0,[x9]
 str d0,[sp,#216]
 adrp x9,:got:__yomdyncore_MOD_rplrg
 ldr x9,[x9,:got_lo12:__yomdyncore_MOD_rplrg]
 ldr d0,[x9]
 str d0,[sp,#224]
 adrp x9,:got:__yomvert_MOD_vp00
 ldr x9,[x9,:got_lo12:__yomvert_MOD_vp00]
 ldr d0,[x9]
 str d0,[sp,#232]
 adrp x9,:got:__yomvert_MOD_toppres
 ldr x9,[x9,:got_lo12:__yomvert_MOD_toppres]
 ldr d0,[x9]
 str d0,[sp,#248]
 adrp x9,:got:__yomcst_MOD_rcvd
 ldr x9,[x9,:got_lo12:__yomcst_MOD_rcvd]
 ldr d0,[x9]
 str d0,[sp,#256]
 adrp x9,:got:__yomct0_MOD_lecmwf
 ldr x9,[x9,:got_lo12:__yomct0_MOD_lecmwf]
 ldr w2,[x9]
 cmp w2,#1
 b.hi .Latmosphere_native_fail
 str w2,[sp,#100]
 adr x9,.Latmosphere_height
 ldr d0,[x9,w2,uxtw#3]
 str d0,[sp,#240]
 /* File services do not enter the numerical status of the construction. */
 ldr w9,[sp,#96]
 str w9,[x24]
 ldr x9,[sp,#80]
 msr fpcr,x9
 ldr x9,[sp,#88]
 msr fpsr,x9
 ldr x18,[sp,#72]
 mov x0,x19
 add x1,sp,#208
 add x3,sp,#288
 add x4,sp,#272
 bl md2asm_initialize_standard_atmosphere
 cbnz w0,.Latmosphere_native_fail
 adrp x25,.Latmosphere_reference_addresses
 add x25,x25,:lo12:.Latmosphere_reference_addresses
 add x22,sp,#288
 mov x23,#68
.Latmosphere_publish:
 ldp x9,x10,[x25],#16
 ldr x11,[x22,x10]
 str x11,[x9]
 subs x23,x23,#1
 b.ne .Latmosphere_publish
 adrp x9,:got:__yomsta_MOD_nlextrap
 ldr x9,[x9,:got_lo12:__yomsta_MOD_nlextrap]
 ldr w10,[sp,#272]
 str w10,[x9]
 adrp x9,:got:__yomsta_MOD_hextrap
 ldr x9,[x9,:got_lo12:__yomsta_MOD_hextrap]
 ldr x10,[sp,#240]
 str x10,[x9]
 adrp x9,md2asm_standard_atmosphere_native_calls
 add x9,x9,:lo12:md2asm_standard_atmosphere_native_calls
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x18,[sp,#72]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldr x25,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#896
 ret
.Latmosphere_native_fail:
 cmp w21,#0
 b.lt .Latmosphere_no_open
 mov w0,w21
 bl close
.Latmosphere_no_open:
 cbz x20,.Latmosphere_no_buffer
 mov x0,x20
 bl free
.Latmosphere_no_buffer:
 mov w0,#121
 bl _exit
.size susta_,.-susta_
.p2align 4
.global md2asm_standard_atmosphere_native_count_get
.type md2asm_standard_atmosphere_native_count_get,%function
md2asm_standard_atmosphere_native_count_get:
 adrp x9,md2asm_standard_atmosphere_native_calls
 ldr x0,[x9,:lo12:md2asm_standard_atmosphere_native_calls]
 ret
.size md2asm_standard_atmosphere_native_count_get,.-md2asm_standard_atmosphere_native_count_get
.section .rodata
.p2align 3
.Latmosphere_height: .double 100.0,150.0
.Latmosphere_namelist: .asciz "fort.4"
.bss
.p2align 3
md2asm_standard_atmosphere_native_calls: .zero 8
.section .note.GNU-stack,"",%progbits

.section .data.rel.ro,"aw",%progbits
.p2align 3
.Latmosphere_reference_addresses:
 .xword __yomsta_MOD_rdtdz1,72
 .xword __yomsta_MOD_rtsur,144
 .xword __yomsta_MOD_rztrop,8
 .xword __yomsta_MOD_rdtdz2,80
 .xword __yomsta_MOD_rttrop,152
 .xword __yomsta_MOD_rptrop,224
 .xword __yomsta_MOD_rzstra,16
 .xword __yomsta_MOD_rdtdz3,88
 .xword __yomsta_MOD_rtstra,160
 .xword __yomsta_MOD_rpstra,232
 .xword __yomsta_MOD_rzstr2,24
 .xword __yomsta_MOD_rdtdz4,96
 .xword __yomsta_MOD_rtstr2,168
 .xword __yomsta_MOD_rpstr2,240
 .xword __yomsta_MOD_rzstpo,32
 .xword __yomsta_MOD_rdtdz5,104
 .xword __yomsta_MOD_rtstpo,176
 .xword __yomsta_MOD_rpstpo,248
 .xword __yomsta_MOD_rzmeso,40
 .xword __yomsta_MOD_rdtdz6,112
 .xword __yomsta_MOD_rtmeso,184
 .xword __yomsta_MOD_rpmeso,256
 .xword __yomsta_MOD_rzmes2,48
 .xword __yomsta_MOD_rdtdz7,120
 .xword __yomsta_MOD_rtmes2,192
 .xword __yomsta_MOD_rpmes2,264
 .xword __yomsta_MOD_rzmepo,56
 .xword __yomsta_MOD_rdtdz8,128
 .xword __yomsta_MOD_rtmepo,200
 .xword __yomsta_MOD_rpmepo,272
 .xword __yomsta_MOD_rzabov,64
 .xword __yomsta_MOD_rdtdz9,136
 .xword __yomsta_MOD_rtabov,208
 .xword __yomsta_MOD_rpabov,280
 .xword __yomsta_MOD_vdtdz1,360
 .xword __yomsta_MOD_vtsur,432
 .xword __yomsta_MOD_vztrop,296
 .xword __yomsta_MOD_vdtdz2,368
 .xword __yomsta_MOD_vttrop,440
 .xword __yomsta_MOD_vptrop,512
 .xword __yomsta_MOD_vzstra,304
 .xword __yomsta_MOD_vdtdz3,376
 .xword __yomsta_MOD_vtstra,448
 .xword __yomsta_MOD_vpstra,520
 .xword __yomsta_MOD_vzstr2,312
 .xword __yomsta_MOD_vdtdz4,384
 .xword __yomsta_MOD_vtstr2,456
 .xword __yomsta_MOD_vpstr2,528
 .xword __yomsta_MOD_vzstpo,320
 .xword __yomsta_MOD_vdtdz5,392
 .xword __yomsta_MOD_vtstpo,464
 .xword __yomsta_MOD_vpstpo,536
 .xword __yomsta_MOD_vzmeso,328
 .xword __yomsta_MOD_vdtdz6,400
 .xword __yomsta_MOD_vtmeso,472
 .xword __yomsta_MOD_vpmeso,544
 .xword __yomsta_MOD_vzmes2,336
 .xword __yomsta_MOD_vdtdz7,408
 .xword __yomsta_MOD_vtmes2,480
 .xword __yomsta_MOD_vpmes2,552
 .xword __yomsta_MOD_vzmepo,344
 .xword __yomsta_MOD_vdtdz8,416
 .xword __yomsta_MOD_vtmepo,488
 .xword __yomsta_MOD_vpmepo,560
 .xword __yomsta_MOD_vzabov,352
 .xword __yomsta_MOD_vdtdz9,424
 .xword __yomsta_MOD_vtabov,496
 .xword __yomsta_MOD_vpabov,568

/* Contract: skills/md2asm/references/openifs/radiation/band_radiation_setup.md. */
.arch armv8.2-a
.text
.p2align 4
.macro BCALL name
 bl \name
 ldr x18,[sp,#96]
.endm
.macro BRANGE ptr,bytes,slot
 cbz \ptr,.Lband_bad
 tst \ptr,#7
 b.ne .Lband_bad
 mov x9,#\bytes
 adds x9,\ptr,x9
 b.cs .Lband_bad
 stp \ptr,x9,[sp,#128+16*\slot]
.endm
.global md2asm_initialize_selected_spectral_radiation_tables
.type md2asm_initialize_selected_spectral_radiation_tables,%function
md2asm_initialize_selected_spectral_radiation_tables:
 sub sp,sp,#3,lsl#12
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 BRANGE x19,32,0
 BRANGE x20,2040,1
 BRANGE x21,520,2
 BRANGE x22,320,3
 ldp x23,x9,[x19]
 mov x10,#9440
 cmp x9,x10
 b.lo .Lband_bad
 BRANGE x23,9440,4
 ldp x24,x9,[x19,#16]
 mov x10,#10744
 cmp x9,x10
 b.lo .Lband_bad
 BRANGE x24,10744,5
 add x10,sp,#128
 mov x11,#0
.Lband_outer:
 ldp x12,x13,[x10]
 add x14,x10,#16
 add x15,x11,#1
.Lband_inner:
 cmp x15,#6
 b.hs .Lband_next
 ldp x16,x17,[x14]
 cmp x12,x17
 b.hs .Lband_clear
 cmp x16,x13
 b.lo .Lband_bad
.Lband_clear:
 add x14,x14,#16
 add x15,x15,#1
 b .Lband_inner
.Lband_next:
 add x10,x10,#16
 add x11,x11,#1
 cmp x11,#5
 b.lo .Lband_outer
 mrs x9,fpcr
 cbnz x9,.Lband_bad
 ldr w9,[x20,#80]
 cmp w9,#14
 b.ne .Lband_bad
 ldr w9,[x20,#60]
 cmp w9,#6
 b.ne .Lband_bad
 ldr w9,[x20,#400]
 cmp w9,#1
 b.ne .Lband_bad
 ldr w9,[x20,#432]
 cmp w9,#1
 b.ne .Lband_bad
 ldr x9,[x24,#2304]
 cbnz x9,.Lband_bad
 ldr x9,[x24,#2368]
 cbnz x9,.Lband_bad
 mov x10,#0x7ff0
 lsl x10,x10,#48
 ldr x9,[x21,#112]
 cbz x9,.Lband_bad
 cmp x9,x10
 b.hs .Lband_bad
 ldr x9,[x22]
 cbz x9,.Lband_bad
 cmp x9,x10
 b.hs .Lband_bad
 add x25,sp,#512
 mov x9,#0
.Lprivate_copy:
 ldr x10,[x24,x9]
 str x10,[x25,x9]
 add x9,x9,#8
 mov x10,#10744
 cmp x9,x10
 b.lo .Lprivate_copy
 add x0,x25,#2304
 mov w1,#1
 adr x2,.Lsolar_extent
 mov w3,#1
 mov w4,#1
 BCALL md2asm_allocate_radiation_flux_array
 cbnz w0,.Lband_failed
 add x0,x25,#2368
 mov w1,#1
 adr x2,.Lsolar_extent
 mov w3,#1
 mov w4,#1
 BCALL md2asm_allocate_radiation_flux_array
 cbnz w0,.Lband_failed
 mov x0,x25
 mov x1,x21
 mov x2,x22
 BCALL md2asm_selected_shortwave_parameter_fields
 mov x0,x23
 BCALL md2asm_longwave_band_parameter_fields
 mov x9,#0
.Lpublic_copy:
 ldr x10,[x25,x9]
 str x10,[x24,x9]
 add x9,x9,#8
 mov x10,#10744
 cmp x9,x10
 b.lo .Lpublic_copy
 mov w0,#0
 b .Lband_return
.Lband_failed:
 BCALL __errno_location
 mov x26,x0
 ldr w9,[x0]
 str w9,[sp,#112]
 ldr x0,[x25,#2304]
 cbz x0,.Lband_failed_second
 BCALL free
.Lband_failed_second:
 ldr x0,[x25,#2368]
 cbz x0,.Lband_failed_done
 BCALL free
.Lband_failed_done:
 ldr w9,[sp,#112]
 str w9,[x26]
 mov w0,#1
 b .Lband_return
.Lband_bad:
 mov w0,#2
.Lband_return:
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#3,lsl#12
 ret
.size md2asm_initialize_selected_spectral_radiation_tables,.-md2asm_initialize_selected_spectral_radiation_tables
.p2align 4
.global md2asm_release_selected_spectral_radiation_tables
.type md2asm_release_selected_spectral_radiation_tables,%function
md2asm_release_selected_spectral_radiation_tables:
 cbz x0,.Lrelease_bad
 tst x0,#7
 b.ne .Lrelease_bad
 mov x9,#10744
 cmp x1,x9
 b.lo .Lrelease_bad
 adds x9,x0,x9
 b.cs .Lrelease_bad
 sub sp,sp,#48
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 str x18,[sp,#32]
 mov x19,x0
 ldr x0,[x19,#2304]
 cbz x0,.Lrelease_second
 bl free
 str xzr,[x19,#2304]
.Lrelease_second:
 ldr x0,[x19,#2368]
 cbz x0,.Lrelease_done
 bl free
 str xzr,[x19,#2368]
.Lrelease_done:
 ldr x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#48
 mov w0,#0
 ret
.Lrelease_bad:
 mov w0,#2
 ret
.size md2asm_release_selected_spectral_radiation_tables,.-md2asm_release_selected_spectral_radiation_tables
.section .rodata
.p2align 2
.Lsolar_extent: .word 14,0,0,0
.section .note.GNU-stack,"",%progbits

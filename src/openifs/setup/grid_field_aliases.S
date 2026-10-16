/* Bind all selected SUGFL2 component aliases to the owned embedded array.
 * x0 is an aligned owned TYPE_GFLD record of 1359136 bytes.
 * Contract: skills/md2asm/references/openifs/setup/grid_field_aliases.md. Return 0 or 2 before mutation.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_bind_selected_grid_field_aliases
.type md2asm_bind_selected_grid_field_aliases,%function
md2asm_bind_selected_grid_field_aliases:
 cbz x0,.Laliases_reject
 tst x0,#7
 b.ne .Laliases_reject
 mrs x9,fpcr
 cbnz x9,.Laliases_reject
 adr x9,.Laliases_record_bytes
 ldr x9,[x9]
 adds x9,x0,x9
 b.cs .Laliases_reject
 ldr w9,[x0]
 cmp w9,#8
 b.ne .Laliases_reject
 ldr w9,[x0,#12]
 cmp w9,#8
 b.ne .Laliases_reject
 ldr w9,[x0,#124]
 cmp w9,#2
 b.ne .Laliases_reject
 adr x2,.Laliases_zero_controls
 mov w13,#15
.Laliases_zero_control_loop:
 ldrb w9,[x2],#1
 ldr w9,[x0,x9]
 cbnz w9,.Laliases_reject
 subs w13,w13,#1
 b.ne .Laliases_zero_control_loop
 adr x2,.Laliases_table
 mov w13,#61
 adr x10,.Laliases_undefined
 ldr w10,[x10]
 /* Check every borrowed target before changing any association. */
.Laliases_validate_row:
 ldp w3,w4,[x2]
 ldr w5,[x2,#8]
 sub w9,w4,#1
 mov w8,#368
 umull x7,w9,w8
 add x7,x7,#3848
 add x7,x0,x7
.Laliases_validate_target:
 cmp w4,#8
 cset w9,ls
 ldr w8,[x7,#64]
 cmp w8,w9
 b.ne .Laliases_reject
 cmp w4,#8
 csel w9,w4,w10,ls
 ldr w8,[x7,#168]
 cmp w8,w9
 b.ne .Laliases_reject
 add x7,x7,#368
 add w4,w4,#1
 subs w5,w5,#1
 b.ne .Laliases_validate_target
 add x2,x2,#16
 subs w13,w13,#1
 b.ne .Laliases_validate_row
 adr x2,.Laliases_table
 mov w13,#61
 mov x11,#-1
 mov x12,#368
 adr x9,.Laliases_dtype
 ldr x14,[x9]
 mov x15,#1
.Laliases_store_row:
 ldp w3,w4,[x2]
 ldp w5,w6,[x2,#8]
 sub w9,w4,#1
 umull x7,w9,w12
 add x7,x7,#3848
 add x7,x0,x7
 add x16,x0,x3
 cbnz w6,.Laliases_store_descriptor
 str x7,[x16]
 b .Laliases_store_next
.Laliases_store_descriptor:
 stp x7,x11,[x16]
 stp x12,x14,[x16,#16]
 stp x12,x15,[x16,#32]
 stp x15,x5,[x16,#48]
.Laliases_store_next:
 add x2,x2,#16
 subs w13,w13,#1
 b.ne .Laliases_store_row
 mov w0,#0
 ret
.Laliases_reject:
 mov w0,#2
 ret
.size md2asm_bind_selected_grid_field_aliases,.-md2asm_bind_selected_grid_field_aliases
.section .rodata
.p2align 3
.Laliases_record_bytes: .xword 1359136
.Laliases_dtype: .xword 0x0000050100000000
.Laliases_undefined: .word -99999
.p2align 4
.Laliases_zero_controls: .byte 88,92,96,100,200,108,120,240,128,132,136,140,144,244,176
.p2align 4
.Laliases_table:
 .word 799840,1,1,0 // YQ
 .word 799856,2,1,0 // YL
 .word 799848,3,1,0 // YI
 .word 799912,4,1,0 // YS
 .word 799920,5,1,0 // YR
 .word 799928,2158,1,0 // YG
 .word 799936,2157,1,0 // YH
 .word 799944,2156,1,0 // YTKE
 .word 799960,2155,1,0 // YEFB1
 .word 799968,2154,1,0 // YEFB2
 .word 799976,2153,1,0 // YEFB3
 .word 799984,6,1,0 // YA
 .word 799992,2151,1,0 // YO3
 .word 800040,2150,1,0 // YCPF
 .word 800048,2149,1,0 // YSPF
 .word 800000,2148,1,0 // YSRC
 .word 800056,2147,1,0 // YCVGQ
 .word 799864,2146,1,0 // YLCONV
 .word 799872,2145,1,0 // YICONV
 .word 799880,2144,1,0 // YRCONV
 .word 799888,2143,1,0 // YSCONV
 .word 799904,2142,1,0 // YLRAD
 .word 799896,2141,1,0 // YIRAD
 .word 801120,2140,1,0 // YSDSAT
 .word 801128,2139,1,0 // YCVV
 .word 800064,2138,1,0 // YQVA
 .word 801160,2137,1,0 // YUOM
 .word 801168,2136,1,0 // YUAL
 .word 801176,2135,1,0 // YDOM
 .word 801184,2134,1,0 // YDAL
 .word 801192,2133,1,0 // YUEN
 .word 801200,2132,1,0 // YUNEBH
 .word 799952,2131,1,0 // YTTE
 .word 800008,2130,1,0 // YMXL
 .word 800016,2129,1,0 // YSHTUR
 .word 800024,2128,1,0 // YFQTUR
 .word 800032,2127,1,0 // YFSTUR
 .word 801136,2126,1,0 // YRKTH
 .word 801112,2125,1,0 // YRSPEC
 .word 801144,2124,1,0 // YRKTQV
 .word 801152,2123,1,0 // YRKTQC
 .word 800264,2122,1,0 // YLRCH4
 .word 801104,2121,1,0 // YPHYCTY
 .word 801272,2120,1,0 // YFSD
 .word 801280,2119,1,1 // YEXT
 .word 800336,2118,1,1 // YFORC
 .word 800400,2117,1,1 // YEZDIAG
 .word 800072,2116,1,1 // YGHG
 .word 800136,2115,1,1 // YCHEM
 .word 800200,2114,1,1 // YAERO
 .word 800464,2113,1,1 // YERA40
 .word 800528,7,2,1 // YNOGW
 .word 800272,2112,1,1 // YEMIS3D
 .word 800592,2111,1,1 // YEDRP
 .word 800720,2110,1,1 // YAERAOT
 .word 800784,2109,1,1 // YAERLISI
 .word 800848,2108,1,1 // YAEROUT
 .word 800912,2107,1,1 // YAEROCLIM
 .word 800976,2106,1,1 // YUVP
 .word 800656,2105,1,1 // YSLDIA
 .word 801208,2104,1,1 // YLIMA
 .section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/radiation/tegen_aerosol_literal_readers.md.
 * Source SUECAEBC/OR/SD/SS/SU; raw int reader(x0 output317952,x1 capacity).
 * Source longitude half rotation and latitude reversal remain runtime operations. */
.text
.p2align 2
.macro TEGEN_READER name,table
.global md2asm_read_tegen_\name
.type md2asm_read_tegen_\name,%function
md2asm_read_tegen_\name:
 adrp x2,\table
 add x2,x2,:lo12:\table
 b .Ltegen_permute
.size md2asm_read_tegen_\name,.-md2asm_read_tegen_\name
.endm
TEGEN_READER black_carbon,.Lblack_carbon
TEGEN_READER organic_aerosol,.Lorganic_aerosol
TEGEN_READER soil_dust,.Lsoil_dust
TEGEN_READER sea_salt,.Lsea_salt
TEGEN_READER sulfate,.Lsulfate
.Ltegen_permute:
 cbz x0,.Ltegen_reader_bad
 tst x0,#7
 b.ne .Ltegen_reader_bad
 movz x9,#0xda00
 movk x9,#4,lsl #16
 cmp x1,x9
 b.lo .Ltegen_reader_bad
 adds x9,x0,x9
 b.cs .Ltegen_reader_bad
 mov x3,#0
 mov x5,#0
.Ltegen_month:
 mov x4,#0
.Ltegen_latitude:
 mov x6,#45
 sub x6,x6,x4
 mov x7,#576
 madd x8,x6,x7,x0
 add x8,x8,x5
 add x9,x2,#288
 mov x10,x8
 mov x11,#36
.Ltegen_east:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Ltegen_east
 mov x9,x2
 mov x11,#36
.Ltegen_west:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Ltegen_west
 add x2,x2,#576
 add x4,x4,#1
 cmp x4,#46
 b.lo .Ltegen_latitude
 mov x9,#26496
 add x5,x5,x9
 add x3,x3,#1
 cmp x3,#12
 b.lo .Ltegen_month
 mov w0,#0
 ret
.Ltegen_reader_bad:
 mov w0,#2
 ret
.section .rodata
.p2align 3
.Lblack_carbon:
#include "tegen_black_carbon_literals.inc.S"
.Lorganic_aerosol:
#include "tegen_organic_aerosol_literals.inc.S"
.Lsoil_dust:
#include "tegen_soil_dust_literals.inc.S"
.Lsea_salt:
#include "tegen_sea_salt_literals.inc.S"
.Lsulfate:
#include "tegen_sulfate_literals.inc.S"
.section .note.GNU-stack,"",%progbits

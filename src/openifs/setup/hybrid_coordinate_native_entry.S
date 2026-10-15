/* Original ALLOC_INIT_TVAB four-pointer entry.
 * Contract: skills/md2asm/references/openifs/setup/hybrid_coordinate_storage.md.
 * x0=&KLEV,x1=A[0:KLEV],x2=B[0:KLEV],x3=fresh TVAB512B.
 * Original VP00 is one explicit read-only scalar-data input.
 * Raw construction owns all calculation/allocation; no original callable.
 */
.arch armv8.2-a
.text
.p2align 4
.global __yomvert_MOD_alloc_init_tvab
.type __yomvert_MOD_alloc_init_tvab,%function
__yomvert_MOD_alloc_init_tvab:
 sub sp,sp,#32
 stp x29,x30,[sp]
 stp x19,x18,[sp,#16]
 mov x29,sp
 cbz x0,.Lhybrid_native_fail
 tst x0,#3
 b.ne .Lhybrid_native_fail
 mov x9,x0
 mov x10,x1
 mov x11,x2
 mov x0,x3
 ldr w1,[x9]
 mov x2,x10
 mov x3,x11
 adrp x9,:got:__yomvert_MOD_vp00
 ldr x9,[x9,:got_lo12:__yomvert_MOD_vp00]
 ldr d0,[x9]
 bl md2asm_initialize_hybrid_coordinate_owners
 cbnz w0,.Lhybrid_native_fail
 adrp x9,.Lhybrid_native_count
 add x9,x9,:lo12:.Lhybrid_native_count
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldp x19,x18,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#32
 ret
.Lhybrid_native_fail:
 mov w0,#121
 bl _exit
 brk #0
.size __yomvert_MOD_alloc_init_tvab,.-__yomvert_MOD_alloc_init_tvab
.p2align 4
.global md2asm_hybrid_coordinate_native_count_get
.type md2asm_hybrid_coordinate_native_count_get,%function
md2asm_hybrid_coordinate_native_count_get:
 adrp x9,.Lhybrid_native_count
 ldr x0,[x9,:lo12:.Lhybrid_native_count]
 ret
.size md2asm_hybrid_coordinate_native_count_get,.-md2asm_hybrid_coordinate_native_count_get
.bss
.p2align 3
.Lhybrid_native_count: .zero 8
.section .note.GNU-stack,"",%progbits

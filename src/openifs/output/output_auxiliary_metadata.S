// Solver contract skills/md2asm/references/openifs/output/output_auxiliary_metadata.md.
/* Selected auxiliary output route, NFPCLI0 and no horizontal interpolation.
 * Original six by-reference arguments F, Geometry, Surface, Model, TFPDATA, KLAG.
 * Only source date metadata and allocation services are needed on this route.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_output_auxiliary_metadata_
.global md2asm_output_auxiliary_metadata_direct
.type md2asm_output_auxiliary_metadata_direct,%function
md2asm_output_auxiliary_metadata_:
md2asm_output_auxiliary_metadata_direct:
 mov w9,#0xaec4
 movk w9,#7,lsl #16
 ldr w10,[x0,x9]
 cbnz w10,.Laux_stop109
 ldr w9,[x0,#2724]
 cbnz w9,.Laux_stop109
 ldr w9,[x5]
 cmp w9,#2
 b.lt .Laux_prepare
 str x0,[x4,#2120]
 b .Laux_leaf_count
.Laux_prepare:
 ldr w9,[x0,#2720]
 mov w10,#5168
 ldr w10,[x1,x10]
 cmp w9,w10
 b.ne .Laux_reject
 sub sp,sp,#144
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x4
 mrs x25,fpcr
 mrs x26,fpsr
 bl __errno_location
 mov x27,x0
 ldr w28,[x0]
 ldr w9,[x20,#1256]
 cbz w9,.Laux_no_climatology
 adrp x9,:got:__yomfpc_MOD_lfpmois
 ldr x9,[x9,:got_lo12:__yomfpc_MOD_lfpmois]
 ldr w9,[x9]
 cbz w9,.Laux_initial_date
 adrp x9,:got:__yomarg_MOD_nudate
 ldr x9,[x9,:got_lo12:__yomarg_MOD_nudate]
 b .Laux_month
.Laux_initial_date:
 adrp x9,:got:__yomrip0_MOD_nindat
 ldr x9,[x9,:got_lo12:__yomrip0_MOD_nindat]
.Laux_month:
 ldr w9,[x9]
 mov w10,#100
 sdiv w9,w9,w10
 sdiv w11,w9,w10
 msub w9,w11,w10,w9
 sub w10,w9,#1
 cmp w10,#11
 b.hi .Laux_no_climatology
 mov w9,#1
 str w9,[x20,#1256]
 ldr w9,[x19,#580]
 cmp w9,#24
 b.ne .Laux_reject
 ldr w9,[x19,#584]
 cmp w9,#86
 b.ne .Laux_reject
 ldr x9,[x19,#560]
 ldr x10,[x19,#552]
 sub x22,x9,x10
 add x22,x22,#1
 cmp x22,#1
 b.lt .Laux_reject
 cmp x22,#8
 b.gt .Laux_reject
 add x21,x20,#1264
 mov x0,x21
 bl md2asm_output_header_release_direct
 mov x0,x21
 mov w1,w22
 bl md2asm_allocate_empty_physical_request
 mov x0,#16512
 bl malloc
 cbz x0,.Laux_reject
 add x23,x21,#744
 str x0,[x23]
 mov x9,#-25
 str x9,[x23,#8]
 mov x9,#8
 str x9,[x23,#16]
 str x9,[x23,#32]
 mov x9,#3
 lsl x9,x9,#32
 mov x10,#3
 orr x9,x9,x10,lsl #40
 str x9,[x23,#24]
 mov x9,#1
 mov x10,#24
 stp x9,x9,[x23,#40]
 str x10,[x23,#56]
 stp x10,xzr,[x23,#64]
 str xzr,[x23,#80]
 stp x10,x9,[x23,#88]
 mov x9,#86
 str x9,[x23,#104]
 b .Laux_done
.Laux_no_climatology:
 str wzr,[x20,#1256]
.Laux_done:
 str x19,[x20,#2120]
 adrp x9,.Laux_count
 ldr x10,[x9,:lo12:.Laux_count]
 add x10,x10,#1
 str x10,[x9,:lo12:.Laux_count]
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
 add sp,sp,#144
 ret
.Laux_leaf_count:
 adrp x9,.Laux_count
 ldr x10,[x9,:lo12:.Laux_count]
 add x10,x10,#1
 str x10,[x9,:lo12:.Laux_count]
 ret
.size md2asm_output_auxiliary_metadata_direct,.-md2asm_output_auxiliary_metadata_direct
.global md2asm_output_auxiliary_metadata_count_get
.type md2asm_output_auxiliary_metadata_count_get,%function
md2asm_output_auxiliary_metadata_count_get:
 adrp x9,.Laux_count
 ldr x0,[x9,:lo12:.Laux_count]
 ret
.size md2asm_output_auxiliary_metadata_count_get,.-md2asm_output_auxiliary_metadata_count_get
.Laux_stop109:
 mov x0,#109
 mov x8,#94
 svc #0
 brk #0
.Laux_reject:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.bss
.p2align 3
.Laux_count: .zero 8
.section .note.GNU-stack,"",%progbits

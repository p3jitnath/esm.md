/* Source-ordered integer maps over live owned records.
 * Contract: skills/md2asm/references/openifs/setup/live_field_maps.md
 * ABI: x0 maps168000, x1 capacity, x2 TGMV1560, x3 GFLD1359136,
 * x4 TSURF18224, x5 undefined-field word. Return w0=0 or2.
 * Consumed pointer targets and canonical descriptors are caller obligations.
 */
.text
.p2align 4
.global md2asm_initialize_live_field_maps
.type md2asm_initialize_live_field_maps,%function
md2asm_initialize_live_field_maps:
 cbz x0,.Lmap_reject
 cbz x2,.Lmap_reject
 cbz x3,.Lmap_reject
 cbz x4,.Lmap_reject
 cbz x5,.Lmap_reject
 orr x6,x0,x2
 orr x6,x6,x3
 orr x6,x6,x4
 tst x6,#7
 b.ne .Lmap_reject
 tst x5,#3
 b.ne .Lmap_reject
 movz x6,#0x9040
 movk x6,#2,lsl #16
 cmp x1,x6
 b.lo .Lmap_reject
 ldr w6,[x3,#map_NGHG]
 cbnz w6,.Lmap_reject
 ldr w6,[x3,#map_NCHEM]
 cbnz w6,.Lmap_reject
 ldr w6,[x3,#map_NAERO]
 cbnz w6,.Lmap_reject
 ldr w1,[x4,#map_NSURF]
 ldr w5,[x5]
 mov x6,x0
 mov w7,#21000
.Lmap_clear:
 str xzr,[x6],#8
 subs w7,w7,#1
 b.ne .Lmap_clear
 adrp x6,.Lmap_recipes
 add x6,x6,:lo12:.Lmap_recipes
 mov w7,#map_recipe_count
.Lmap_next:
 ldp w9,w10,[x6]
 ldp w11,w12,[x6,#8]
 ldp w13,w14,[x6,#16]
 ldr w15,[x6,#24]
 add x6,x6,#28
 cbz w15,.Lmap_gate_passed
 cmp w1,#0
 b.le .Lmap_advance
.Lmap_gate_passed:
 cbz w10,.Lmap_gmv
 cmp w10,#1
 b.eq .Lmap_gfl
 cmp w10,#3
 b.eq .Lmap_gfl
 ldr x8,[x4,x11]
 b .Lmap_pointer
.Lmap_gfl:
 ldr x8,[x3,x11]
.Lmap_pointer:
 ldr w16,[x8,x13]
 cbz w16,.Lmap_inactive
 ldr w16,[x8,x12]
 cbz w14,.Lmap_store
 add x15,x4,x11
 ldr x17,[x15,#56]
 ldr x15,[x15,#48]
 sub x17,x17,x15
 add x17,x17,#1
 cmp x17,#0
 csel x17,x17,xzr,gt
 str w17,[x0,x14]
 b .Lmap_store
.Lmap_gmv:
 ldr w16,[x2,x11]
 cmp w16,w5
 b.ne .Lmap_store
 cmp w5,#1
 b.eq .Lmap_store
.Lmap_inactive:
 mov w16,#-1
.Lmap_store:
 str w16,[x0,x9]
.Lmap_advance:
 subs w7,w7,#1
 b.ne .Lmap_next
 mov w0,#0
 ret
.Lmap_reject:
 mov w0,#2
 ret
.size md2asm_initialize_live_field_maps,.-md2asm_initialize_live_field_maps
#include "field_map_recipes.inc.S"
.section .note.GNU-stack,"",%progbits

/* Source-selected IFS gas-map adapter with owned inputs and owners.
   Contract: skills/md2asm/references/openifs/radiation/ecrad_configuration.md. */
.text
.p2align 4
.global md2asm_setup_ecrad_gas_band_maps
.type md2asm_setup_ecrad_gas_band_maps,%function
md2asm_setup_ecrad_gas_band_maps:
 cbz x0,.Lgas_bad
 cbz x2,.Lgas_bad
 cbz x4,.Lgas_bad
 orr x6,x0,x2
 orr x6,x6,x4
 tst x6,#7
 b.ne .Lgas_bad
 mov x6,#22472
 cmp x1,x6
 b.lo .Lgas_bad
 adds x7,x0,x6
 b.cs .Lgas_bad
 movz x6,#(1229352 & 65535)
 movk x6,#(1229352 >> 16),lsl #16
 cmp x3,x6
 b.lo .Lgas_bad
 adds x8,x2,x6
 b.cs .Lgas_bad
 movz x6,#(4059736 & 65535)
 movk x6,#(4059736 >> 16),lsl #16
 cmp x5,x6
 b.lo .Lgas_bad
 adds x9,x4,x6
 b.cs .Lgas_bad
 cmp x0,x8
 b.hs .Lgas_lw_clear
 cmp x2,x7
 b.lo .Lgas_bad
.Lgas_lw_clear:
 cmp x0,x9
 b.hs .Lgas_sw_clear
 cmp x4,x7
 b.lo .Lgas_bad
.Lgas_sw_clear:
 cmp x2,x9
 b.hs .Lgas_inputs_clear
 cmp x4,x8
 b.lo .Lgas_bad
.Lgas_inputs_clear:
 ldr w6,[x0,#620]
 cmp w6,#2
 b.ne .Lgas_bad
 ldr w6,[x0,#624]
 cmp w6,#2
 b.ne .Lgas_bad
 ldr w6,[x0,#7960]
 cbnz w6,.Lgas_bad
 ldr w6,[x0,#7944]
 cbnz w6,.Lgas_bad
 adrp x6,.Lgas_vector_plan
 add x6,x6,:lo12:.Lgas_vector_plan
 mov x7,#10
.Lgas_fresh:
 ldr x8,[x6],#40
 ldr x9,[x0,x8]
 cbnz x9,.Lgas_bad
 subs x7,x7,#1
 b.ne .Lgas_fresh
 sub sp,sp,#768
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 add x26,x2,#1152
 movz x6,#(4058840 & 65535)
 movk x6,#(4058840 >> 16),lsl #16
 add x27,x4,x6
 add x24,sp,#128
 adrp x22,.Lgas_vector_plan
 add x22,x22,:lo12:.Lgas_vector_plan
 mov x23,#0
.Lgas_allocate:
 add x0,x24,x23,lsl #6
 ldr w1,[x22,#8]
 ldr w2,[x22,#16]
 bl md2asm_allocate_ecrad_vector
 cbnz w0,.Lgas_failed
 add x6,x24,x23,lsl #6
 ldr x7,[x6]
 ldr x8,[x22,#8]
 ldr x9,[x22,#24]
 cmp x9,#1
 b.eq .Lgas_wavelength
 cmp x9,#2
 b.eq .Lgas_sw_band
 cmp x9,#3
 b.eq .Lgas_lw_band
 mov w10,#1
.Lgas_identity:
 str w10,[x7],#4
 add w10,w10,#1
 subs x8,x8,#1
 b.ne .Lgas_identity
 b .Lgas_owner_done
.Lgas_wavelength:
 ldr x10,[x22,#32]
 add x10,x22,x10
.Lgas_wavelength_word:
 ldr x11,[x10],#8
 str x11,[x7],#8
 subs x8,x8,#1
 b.ne .Lgas_wavelength_word
 b .Lgas_owner_done
.Lgas_sw_band:
 mov x10,x27
 ldr w12,[x10]
.Lgas_sw_word:
 ldr w11,[x10],#4
 sub w11,w11,w12
 add w11,w11,#1
 str w11,[x7],#4
 subs x8,x8,#1
 b.ne .Lgas_sw_word
 b .Lgas_owner_done
.Lgas_lw_band:
 mov x10,x26
.Lgas_lw_word:
 ldr w11,[x10],#4
 str w11,[x7],#4
 subs x8,x8,#1
 b.ne .Lgas_lw_word
.Lgas_owner_done:
 add x22,x22,#40
 add x23,x23,#1
 cmp x23,#10
 b.lo .Lgas_allocate
 adrp x22,.Lgas_vector_plan
 add x22,x22,:lo12:.Lgas_vector_plan
 mov x23,#0
.Lgas_commit:
 ldr x6,[x22],#40
 add x6,x19,x6
 add x7,x24,x23,lsl #6
 ldp x8,x9,[x7]
 stp x8,x9,[x6]
 ldp x8,x9,[x7,#16]
 stp x8,x9,[x6,#16]
 ldp x8,x9,[x7,#32]
 stp x8,x9,[x6,#32]
 ldp x8,x9,[x7,#48]
 stp x8,x9,[x6,#48]
 add x23,x23,#1
 cmp x23,#10
 b.lo .Lgas_commit
 mov x6,#19996
 add x6,x19,x6
 mov w7,#112
 mov w8,#140
 stp w7,w8,[x6]
 mov w7,#14
 mov w8,#16
 stp w7,w8,[x6,#8]
 str wzr,[x6,#16]
 str wzr,[x6,#20]
 str xzr,[x19,#10992]
 str xzr,[x19,#11056]
 mov w0,#0
 b .Lgas_return
.Lgas_failed:
 mov x25,#0
 cbz x23,.Lgas_no_owners
.Lgas_cleanup:
 add x6,x24,x25,lsl #6
 ldr x0,[x6]
 bl free
 add x25,x25,#1
 cmp x25,x23
 b.lo .Lgas_cleanup
.Lgas_no_owners:
 mov w0,#1
.Lgas_return:
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#768
 ret
.Lgas_bad:
 mov w0,#2
 ret
.size md2asm_setup_ecrad_gas_band_maps,.-md2asm_setup_ecrad_gas_band_maps
.p2align 4
.global md2asm_release_ecrad_gas_band_maps
.type md2asm_release_ecrad_gas_band_maps,%function
md2asm_release_ecrad_gas_band_maps:
 cbz x0,.Lgas_release_bad
 tst x0,#7
 b.ne .Lgas_release_bad
 mov x2,#22472
 cmp x1,x2
 b.lo .Lgas_release_bad
 adds x2,x0,x2
 b.cs .Lgas_release_bad
 stp x29,x30,[sp,#-64]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x18,[sp,#32]
 mov x19,x0
 adrp x20,.Lgas_vector_plan
 add x20,x20,:lo12:.Lgas_vector_plan
 mov x21,#10
.Lgas_release_loop:
 ldr x6,[x20]
 ldr x0,[x19,x6]
 cbz x0,.Lgas_release_next
 bl free
 ldr x6,[x20]
 str xzr,[x19,x6]
.Lgas_release_next:
 add x20,x20,#40
 subs x21,x21,#1
 b.ne .Lgas_release_loop
 mov w0,#0
 ldp x21,x18,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#64
 ret
.Lgas_release_bad:
 mov w0,#2
 ret
.size md2asm_release_ecrad_gas_band_maps,.-md2asm_release_ecrad_gas_band_maps
.section .rodata
.p2align 3
#include "ecrad_gas_band_plan.inc.S"
.section .note.GNU-stack,"",%progbits

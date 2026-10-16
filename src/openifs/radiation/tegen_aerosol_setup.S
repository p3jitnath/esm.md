/* Contract: skills/md2asm/references/openifs/radiation/tegen_aerosol_setup.md.
 * Owned TEGEN declaration/setup/shared-reference/finalizer state.
 * Setup x0record133608,x1cap,x2shared744,x3cap,x4filename260,x5len,x6true4.
 * Original CLASS/vtable/module state exists only in the separate source control. */
.text
.p2align 2
.macro RECORD_BYTES reg
 movz \reg,#(133608 & 65535)
 movk \reg,#(133608 >> 16),lsl #16
.endm
.macro RECORD_TAIL reg,base
 movz \reg,#(133592 & 65535)
 movk \reg,#(133592 >> 16),lsl #16
 add \reg,\base,\reg
.endm
.global md2asm_initialize_tegen_record_defaults
.type md2asm_initialize_tegen_record_defaults,%function
md2asm_initialize_tegen_record_defaults:
 cbz x0,.Ltegen_bad
 tst x0,#7
 b.ne .Ltegen_bad
 RECORD_BYTES x2
 cmp x1,x2
 b.lo .Ltegen_bad
 adds x2,x0,x2
 b.cs .Ltegen_bad
 adrp x2,.Ltegen_negative_huge
 ldr x2,[x2,:lo12:.Ltegen_negative_huge]
 str x2,[x0]
 add x2,x0,#8
 mov x3,#0
.Ltegen_default_pointer:
 str xzr,[x2]
 add x2,x2,#112
 add x3,x3,#1
 cmp x3,#7
 b.lo .Ltegen_default_pointer
 RECORD_TAIL x2,x0
 mov w3,#2100
 mov w4,#1850
 stp w3,w4,[x2]
 str wzr,[x2,#8]
 mov w0,#0
 ret
.size md2asm_initialize_tegen_record_defaults,.-md2asm_initialize_tegen_record_defaults
.global md2asm_initialize_tegen_aerosol_climatology
.type md2asm_initialize_tegen_aerosol_climatology,%function
md2asm_initialize_tegen_aerosol_climatology:
 cbz x0,.Ltegen_bad
 cbz x2,.Ltegen_bad
 cbz x4,.Ltegen_bad
 cbz x6,.Ltegen_bad
 orr x7,x0,x2
 tst x7,#7
 b.ne .Ltegen_bad
 tst x6,#3
 b.ne .Ltegen_bad
 RECORD_BYTES x7
 cmp x1,x7
 b.lo .Ltegen_bad
 cmp x3,#744
 b.lo .Ltegen_bad
 cmp x5,#260
 b.ne .Ltegen_bad
 adds x8,x0,x7
 b.cs .Ltegen_bad
 adds x9,x2,#744
 b.cs .Ltegen_bad
 adds x10,x4,#260
 b.cs .Ltegen_bad
 adds x11,x6,#4
 b.cs .Ltegen_bad
 cmp x0,x9
 b.hs .Ltegen_span_record_filename
 cmp x2,x8
 b.lo .Ltegen_bad
.Ltegen_span_record_filename:
 cmp x0,x10
 b.hs .Ltegen_span_record_call
 cmp x4,x8
 b.lo .Ltegen_bad
.Ltegen_span_record_call:
 cmp x0,x11
 b.hs .Ltegen_span_shared_filename
 cmp x6,x8
 b.lo .Ltegen_bad
.Ltegen_span_shared_filename:
 cmp x2,x10
 b.hs .Ltegen_span_shared_call
 cmp x4,x9
 b.lo .Ltegen_bad
.Ltegen_span_shared_call:
 cmp x2,x11
 b.hs .Ltegen_selected_inputs
 cmp x6,x9
 b.lo .Ltegen_bad
.Ltegen_selected_inputs:
 ldr w7,[x6]
 cmp w7,#1
 b.ne .Ltegen_bad
 mrs x7,fpcr
 cbnz x7,.Ltegen_bad
 mov x7,#0
.Ltegen_blank_filename:
 ldrb w8,[x4,x7]
 cmp w8,#32
 b.ne .Ltegen_bad
 add x7,x7,#1
 cmp x7,#260
 b.lo .Ltegen_blank_filename
 RECORD_TAIL x7,x0
 ldr w8,[x7,#8]
 cbnz w8,.Ltegen_bad
 ldr w7,[x2,#736]
 tbnz w7,#31,.Ltegen_bad
 movz w8,#0xffff
 movk w8,#0x7fff,lsl #16
 cmp w7,w8
 b.eq .Ltegen_bad
 mov x8,#0
 mov x9,x0
 add x9,x9,#8
 mov x10,x2
.Ltegen_pointer_preflight:
 ldr x11,[x9]
 cbnz x11,.Ltegen_bad
 ldr x11,[x10]
 cbnz w7,.Ltegen_require_shared
 cbnz x11,.Ltegen_bad
 b .Ltegen_pointer_next
.Ltegen_require_shared:
 cbz x11,.Ltegen_bad
.Ltegen_pointer_next:
 add x9,x9,#112
 add x10,x10,#112
 add x8,x8,#1
 cmp x8,#7
 b.lo .Ltegen_pointer_preflight
 sub sp,sp,#896
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 stp x26,x27,[sp,#80]
 stp x28,xzr,[sp,#96]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 mov w27,w7
 bl __errno_location
 mov x23,x0
 ldr w24,[x23]
 cbnz w27,.Ltegen_shared_association
 add x26,sp,#128
 mov x9,#0
.Ltegen_private_preimage:
 ldr x10,[x20,x9]
 str x10,[x26,x9]
 add x9,x9,#8
 cmp x9,#736
 b.lo .Ltegen_private_preimage
 mov x25,#0
.Ltegen_allocate_owner:
 mov x9,#112
 madd x0,x25,x9,x26
 mov w1,#3
 adrp x2,.Ltegen_monthly_shape
 add x2,x2,:lo12:.Ltegen_monthly_shape
 cmp x25,#5
 b.ne .Ltegen_check_latitude_owner
 adrp x2,.Ltegen_volcanic_shape
 add x2,x2,:lo12:.Ltegen_volcanic_shape
.Ltegen_check_latitude_owner:
 cmp x25,#6
 b.ne .Ltegen_allocate_call
 mov w1,#1
 adrp x2,.Ltegen_latitude_shape
 add x2,x2,:lo12:.Ltegen_latitude_shape
.Ltegen_allocate_call:
 mov w3,#1
 mov w4,#0
 bl md2asm_allocate_radiation_flux_array
 cbnz w0,.Ltegen_allocation_failed
 cmp x25,#5
 b.ne .Ltegen_allocated_next
 mov x9,#112
 madd x9,x25,x9,x26
 mov x10,#-50425
 str x10,[x9,#8]
 mov x10,#1850
 str x10,[x9,#72]
 mov x10,#2100
 str x10,[x9,#80]
.Ltegen_allocated_next:
 add x25,x25,#1
 cmp x25,#7
 b.lo .Ltegen_allocate_owner
 ldr x0,[x26]
 movz x1,#0xda00
 movk x1,#4,lsl #16
 bl md2asm_read_tegen_black_carbon
 ldr x0,[x26,#112]
 movz x1,#0xda00
 movk x1,#4,lsl #16
 bl md2asm_read_tegen_organic_aerosol
 ldr x0,[x26,#224]
 movz x1,#0xda00
 movk x1,#4,lsl #16
 bl md2asm_read_tegen_soil_dust
 ldr x0,[x26,#336]
 movz x1,#0xda00
 movk x1,#4,lsl #16
 bl md2asm_read_tegen_sea_salt
 ldr x0,[x26,#448]
 movz x1,#0xda00
 movk x1,#4,lsl #16
 bl md2asm_read_tegen_sulfate
 ldr x0,[x26,#560]
 movz x1,#0xd300
 movk x1,#8,lsl #16
 ldr x2,[x26,#672]
 mov x3,#192
 add x4,sp,#864
 mov x5,#8
 bl md2asm_initialize_tegen_volcanic_values
 /* Qualified children cannot reject these owned, checked argument shapes. */
 mov x9,#0
.Ltegen_publish_owners:
 ldr x10,[x26,x9]
 str x10,[x20,x9]
 add x9,x9,#8
 cmp x9,#736
 b.lo .Ltegen_publish_owners
 ldr x9,[sp,#864]
 str x9,[x19]
 mov w27,#1
 str w27,[x20,#736]
 str wzr,[x20,#740]
 b .Ltegen_associate
.Ltegen_shared_association:
 add w27,w27,#1
 str w27,[x20,#736]
.Ltegen_associate:
 add x9,x19,#8
 mov x10,#0
.Ltegen_copy_shared_views:
 ldr x11,[x20,x10]
 str x11,[x9,x10]
 add x10,x10,#8
 cmp x10,#736
 b.lo .Ltegen_copy_shared_views
 RECORD_TAIL x9,x19
 mov w10,#1
 str w10,[x9,#8]
 str w24,[x23]
 mov w0,#0
 b .Ltegen_setup_return
.Ltegen_allocation_failed:
 mov w27,w0
 ldr w28,[x23]
 mov x25,#0
.Ltegen_free_private:
 mov x9,#112
 madd x21,x25,x9,x26
 ldr x0,[x21]
 cbz x0,.Ltegen_free_private_next
 bl free
 str xzr,[x21]
.Ltegen_free_private_next:
 add x25,x25,#1
 cmp x25,#7
 b.lo .Ltegen_free_private
 str w28,[x23]
 mov w0,w27
.Ltegen_setup_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x26,x27,[sp,#80]
 ldr x28,[sp,#96]
 ldp x29,x30,[sp]
 add sp,sp,#896
 ret
.size md2asm_initialize_tegen_aerosol_climatology,.-md2asm_initialize_tegen_aerosol_climatology
.global md2asm_release_tegen_aerosol_climatology
.type md2asm_release_tegen_aerosol_climatology,%function
md2asm_release_tegen_aerosol_climatology:
 cbz x0,.Ltegen_bad
 cbz x2,.Ltegen_bad
 orr x4,x0,x2
 tst x4,#7
 b.ne .Ltegen_bad
 RECORD_BYTES x4
 cmp x1,x4
 b.lo .Ltegen_bad
 cmp x3,#744
 b.lo .Ltegen_bad
 adds x4,x0,x4
 b.cs .Ltegen_bad
 adds x5,x2,#744
 b.cs .Ltegen_bad
 cmp x0,x5
 b.hs .Ltegen_release_disjoint
 cmp x2,x4
 b.lo .Ltegen_bad
.Ltegen_release_disjoint:
 RECORD_TAIL x4,x0
 ldr w5,[x4,#8]
 cbz w5,.Ltegen_empty_release
 cmp w5,#1
 b.ne .Ltegen_bad
 ldr w5,[x2,#736]
 cmp w5,#1
 b.lt .Ltegen_bad
 add x4,x0,#8
 mov x5,x2
 mov x6,#0
.Ltegen_release_views:
 ldr x7,[x4]
 ldr x8,[x5]
 cbz x7,.Ltegen_bad
 cmp x7,x8
 b.ne .Ltegen_bad
 add x4,x4,#112
 add x5,x5,#112
 add x6,x6,#1
 cmp x6,#7
 b.lo .Ltegen_release_views
 stp x29,x30,[sp,#-96]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 stp x24,x25,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 bl __errno_location
 mov x21,x0
 ldr w22,[x21]
 ldr w23,[x20,#736]
 cmp w23,#1
 b.gt .Ltegen_release_count
 mov x24,#0
.Ltegen_release_owner:
 mov x9,#112
 madd x25,x24,x9,x20
 ldr x0,[x25]
 bl free
 str xzr,[x25]
 add x24,x24,#1
 cmp x24,#7
 b.lo .Ltegen_release_owner
.Ltegen_release_count:
 sub w23,w23,#1
 str w23,[x20,#736]
 add x9,x19,#8
 mov x10,#0
.Ltegen_clear_record_views:
 str xzr,[x9]
 add x9,x9,#112
 add x10,x10,#1
 cmp x10,#7
 b.lo .Ltegen_clear_record_views
 RECORD_TAIL x9,x19
 str wzr,[x9,#8]
 str w22,[x21]
 mov w0,#0
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x24,x25,[sp,#64]
 ldp x29,x30,[sp],#96
 ret
.Ltegen_empty_release:
 mov w0,#0
 ret
.size md2asm_release_tegen_aerosol_climatology,.-md2asm_release_tegen_aerosol_climatology
.Ltegen_bad:
 mov w0,#2
 ret
.section .rodata
.p2align 3
.Ltegen_negative_huge:.quad 0xffefffffffffffff
.Ltegen_monthly_shape:.word 72,46,12,0
.Ltegen_volcanic_shape:.word 24,251,12,0
.Ltegen_latitude_shape:.word 24,0,0,0
.section .note.GNU-stack,"",%progbits

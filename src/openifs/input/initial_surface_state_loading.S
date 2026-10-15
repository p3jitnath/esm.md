/* Compose frozen surface input stages directly, revision 1.
 * Contract: skills/md2asm/references/openifs/input/initial_surface_state_loading.md
 * Physics: formulations/openifs/input/surface_initial_state_conversion.md
 * x0 path, x1 configuration, x2 capacity, x3 owners, x4 capacity,
 * x5 parameter identifiers, x6 capacity. Return w0; 176-byte aligned frame.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_load_initial_surface_state
.type md2asm_load_initial_surface_state,%function
md2asm_load_initial_surface_state:
 cbz x0,.Lbad
 cbz x1,.Lbad
 cbz x3,.Lbad
 cbz x5,.Lbad
 orr x8,x1,x3
 tst x8,#7
 b.ne .Lbad
 tst x5,#3
 b.ne .Lbad
 cmp x2,#2304
 b.lo .Lbad
 cmp x4,#80
 b.lo .Lbad
 cmp x6,#208
 b.lo .Lbad
 mrs x8,fpcr
 cbnz x8,.Lbad
 stp x29,x30,[sp,#-176]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 str x8,[sp,#104]
 mrs x8,fpsr
 str x8,[sp,#112]
 mov x19,x0
 mov x20,x1
 mov x21,x3
 mov x22,x5
 bl __errno_location
 mov x24,x0
 ldr w25,[x24]
 movz x0,#5600
 movk x0,#53,lsl#16
 bl malloc
 mov x23,x0
 ldr x8,[sp,#104]
 msr fpcr,x8
 ldr x8,[sp,#112]
 msr fpsr,x8
 str w25,[x24]
 cbz x23,.Lallocation_failed
 movz x8,#0
 movk x8,#35,lsl#16
 add x26,x23,x8
 movz x8,#5600
 movk x8,#35,lsl#16
 add x27,x23,x8
 movz x8,#54752
 movk x8,#46,lsl#16
 add x28,x23,x8
 mov x0,x19
 mov x1,x23
 movz x2,#0
 movk x2,#35,lsl#16
 mov x3,x26
 mov x4,#5600
 add x5,sp,#136
 bl md2asm_read_initial_surface_fields
 cbnz w0,.Lreader_failed
 mov x0,x23
 movz x1,#0
 movk x1,#35,lsl#16
 mov x2,x26
 mov x3,#5600
 mov x4,x27
 movz x5,#49152
 movk x5,#11,lsl#16
 mov x6,x28
 movz x7,#16384
 movk x7,#6,lsl#16
 bl md2asm_select_initial_surface_fields
 cbnz w0,.Lselection_failed
 mov x0,x27
 movz x1,#49152
 movk x1,#11,lsl#16
 mov x2,x28
 movz x3,#16384
 movk x3,#6,lsl#16
 mov x4,x22
 mov x5,#208
 mov x6,x20
 mov x7,#2304
 bl md2asm_convert_initial_surface_state
 cbnz w0,.Lconversion_failed
 mov x0,x27
 movz x1,#49152
 movk x1,#11,lsl#16
 mov x2,x28
 movz x3,#16384
 movk x3,#6,lsl#16
 mov x4,x22
 mov x5,#208
 mov x6,x21
 mov x7,#80
 bl md2asm_place_initial_surface_fields
 cbz w0,.Lcleanup
 add w0,w0,#400
 b .Lcleanup
.Lreader_failed:
 add w0,w0,#100
 b .Lcleanup
.Lselection_failed:
 add w0,w0,#200
 b .Lcleanup
.Lconversion_failed:
 add w0,w0,#300
.Lcleanup:
 str w0,[sp,#152]
 mrs x8,fpsr
 str x8,[sp,#144]
 mov x0,x23
 bl free
 ldr x8,[sp,#144]
 msr fpsr,x8
 ldr w0,[sp,#152]
 b .Lreturn
.Lallocation_failed:
 mov w0,#2
.Lreturn:
 str w25,[x24]
 ldr x8,[sp,#104]
 msr fpcr,x8
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp],#176
 ret
.Lbad:
 mov w0,#1
 ret
.size md2asm_load_initial_surface_state,.-md2asm_load_initial_surface_state
.section .note.GNU-stack,"",%progbits

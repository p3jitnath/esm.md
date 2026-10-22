/* Complete operational surface file loading, revision 1.
 * Contract: skills/md2asm/references/openifs/input/operational_initial_surface_state_loading.md.
 * x0 path, x1 read-only 2,304-byte owned configuration, x2 capacity,
 * x3 read-only six-owner table, x4 table capacity (at least 96 bytes),
 * x5 read-only 55 parameter IDs, x6 ID capacity (at least 220 bytes).
 * Each owner pair gives a writable complete base and its byte capacity.
 * Direct children own decode, selection, physical conversion and placement.
 * Allocate/free one 8,236,403,880-byte private workspace; all offsets are 64-bit.
 * Preserve the old aligned 176-byte frame and status/cleanup order.
 * Return 0 success, 1 basic refusal, 2 allocation failure or child domain
 * 100/200/300/400 plus its error. Model owners change only at placement.
 * Preserve FPCR, errno, x18 and saved registers. FPSR keeps genuine flags.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_load_operational_initial_surface_state
.type md2asm_load_operational_initial_surface_state,%function
md2asm_load_operational_initial_surface_state:
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
 cmp x4,#96
 b.lo .Lbad
 cmp x6,#220
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
 movz x0,#36008
 movk x0,#60141,lsl#16
 movk x0,#1,lsl#32
 bl malloc
 mov x23,x0
 ldr x8,[sp,#104]
 msr fpcr,x8
 ldr x8,[sp,#112]
 msr fpsr,x8
 str w25,[x24]
 cbz x23,.Lallocation_failed
 movz x8,#40960
 movk x8,#65255,lsl#16
 add x26,x23,x8
 movz x8,#44200
 movk x8,#65255,lsl#16
 add x27,x23,x8
 movz x8,#60584
 movk x8,#40000,lsl#16
 movk x8,#1,lsl#32
 add x28,x23,x8
 mov x0,x19
 mov x1,x23
 movz x2,#40960
 movk x2,#65255,lsl#16
 mov x3,x26
 mov x4,#3240
 add x5,sp,#136
 bl md2asm_read_operational_initial_surface_fields
 cbnz w0,.Lreader_failed
 mov x0,x23
 movz x1,#40960
 movk x1,#65255,lsl#16
 mov x2,x26
 mov x3,#3240
 mov x4,x27
 movz x5,#16384
 movk x5,#40281,lsl#16
 mov x6,x28
 movz x7,#40960
 movk x7,#20140,lsl#16
 bl md2asm_select_operational_initial_surface_fields
 cbnz w0,.Lselection_failed
 mov x0,x27
 movz x1,#16384
 movk x1,#40281,lsl#16
 mov x2,x28
 movz x3,#40960
 movk x3,#20140,lsl#16
 mov x4,x22
 mov x5,#220
 mov x6,x20
 mov x7,#2304
 bl md2asm_convert_operational_initial_surface_state
 cbnz w0,.Lconversion_failed
 mov x0,x27
 movz x1,#16384
 movk x1,#40281,lsl#16
 mov x2,x28
 movz x3,#40960
 movk x3,#20140,lsl#16
 mov x4,x22
 mov x5,#220
 mov x6,x21
 mov x7,#96
 bl md2asm_place_operational_initial_surface_fields
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
.size md2asm_load_operational_initial_surface_state,.-md2asm_load_operational_initial_surface_state
.section .note.GNU-stack,"",%progbits

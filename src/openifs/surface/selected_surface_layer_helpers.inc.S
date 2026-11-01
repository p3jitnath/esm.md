// Common AArch64 address and GNU descriptor operations for the three layer contracts.
.text
.p2align 4
.macro ADDR reg,base,offset
 movz x16,#(\offset&65535)
 movk x16,#((\offset>>16)&65535),lsl #16
 add \reg,\base,x16
.endm
.macro SPADDR reg,offset
 ADDR \reg,sp,\offset
.endm
.macro GLOBAL reg,name
 adrp \reg,:got:\name
 ldr \reg,[\reg,:got_lo12:\name]
.endm
.macro ARG reg,index
 ldr \reg,[x19,#(8*\index)]
.endm
.macro CARG reg,index
 ldr \reg,[sp,#(2048+8*\index)]
.endm
.macro PUTARG reg,index
 str \reg,[sp,#(2048+8*\index)]
.endm
.macro CALL name
 str x18,[sp,#3840]
 bl \name
 ldr x18,[sp,#3840]
.endm
.macro ENTER name,count,frame
 .global \name
 .type \name,%function
\name:
 mov x16,sp
 sub sp,sp,#\frame
 add x17,sp,#1360
 stp x19,x20,[x17]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x25,x26,[x17,#48]
 stp x27,x28,[x17,#64]
 stp x29,x30,[x17,#80]
 str x18,[x17,#96]
 add x17,sp,#1472
 stp d8,d9,[x17]
 stp d10,d11,[x17,#16]
 stp d12,d13,[x17,#32]
 stp d14,d15,[x17,#48]
 add x19,sp,#1536
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 .if \count>=8
 stp x6,x7,[x19,#48]
 .elseif \count==7
 str x6,[x19,#48]
 .endif
 .if \count>8
 mov x10,#8
.Lsl_args_\@:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#\count
 b.lt .Lsl_args_\@
 .endif
 mrs x9,fpcr
 cbnz x9,.Lsl_bad
.endm
.macro EXIT frame
 add x17,sp,#1472
 ldp d8,d9,[x17]
 ldp d10,d11,[x17,#16]
 ldp d12,d13,[x17,#32]
 ldp d14,d15,[x17,#48]
 add x17,sp,#1360
 ldp x19,x20,[x17]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x25,x26,[x17,#48]
 ldp x27,x28,[x17,#64]
 ldp x29,x30,[x17,#80]
 ldr x18,[x17,#96]
 add sp,sp,#\frame
 ret
.endm
// x0 target rank-one descriptor; x1 data; x2 extent; x3 element stride; w4 kind bytes.
.Lsl_make1:
 neg x9,x3
 stp x1,x9,[x0]
 str x4,[x0,#16]
 str wzr,[x0,#24]
 mov w9,#1
 strb w9,[x0,#28]
 cmp w4,#8
 mov w9,#3
 mov w10,#1
 csel w9,w9,w10,eq
 strb w9,[x0,#29]
 strh wzr,[x0,#30]
 str x4,[x0,#32]
 mov x9,#1
 stp x3,x9,[x0,#40]
 str x2,[x0,#56]
 ret
// x0 target rank-two descriptor; x1 data; x2 rows; x3 columns; x4/x5 strides.
.Lsl_make2:
 neg x9,x4
 sub x9,x9,x5
 stp x1,x9,[x0]
 mov x9,#8
 str x9,[x0,#16]
 str wzr,[x0,#24]
 mov w9,#0x302
 strh w9,[x0,#28]
 strh wzr,[x0,#30]
 mov x9,#8
 str x9,[x0,#32]
 mov x9,#1
 stp x4,x9,[x0,#40]
 str x2,[x0,#56]
 stp x5,x9,[x0,#64]
 str x3,[x0,#80]
 ret
// x0 target vector descriptor; x1 source rank-two pointer; x2 actual column index.
.Lsl_column2:
 ldr x9,[x1,#48]
 cmp x9,#1
 b.ne .Lsl_bad
 mov x13,x1
 mov x14,x2
 ldp x9,x10,[x13,#72]
 cmp x14,x9
 b.lt .Lsl_bad
 cmp x14,x10
 b.gt .Lsl_bad
 sub x14,x14,x9
 ldr x9,[x13,#64]
 mul x14,x14,x9
 ldr x1,[x13]
 add x1,x1,x14,lsl #3
 ldp x2,x9,[x13,#48]
 sub x2,x9,x2
 add x2,x2,#1
 ldr x3,[x13,#40]
 mov x4,#8
 b .Lsl_make1
// Retain source addresses of declared inactive heat/moisture and Stokes fields.
// Retain the selected and operational inactive codes; payload consumption is zero.
.Lsl_inactive_surface_column2:
 sxtw x2,w2
 movn x9,#0x869e
 movk x9,#0xfffe,lsl #16
 mov x15,#1
 cmp x2,x9
 b.eq .Lsl_inactive_surface_owner
 movn x9,#0x423e
 movk x9,#0xfff0,lsl #16
 cmp x2,x9
 b.ne .Lsl_column2
 mov x15,#3
.Lsl_inactive_surface_owner:
 ldr x9,[x1,#16]
 cmp x9,#8
 b.ne .Lsl_bad
 ldr x9,[x1,#40]
 cmp x9,#1
 b.ne .Lsl_bad
 ldr x9,[x1,#48]
 cmp x9,#1
 b.ne .Lsl_bad
 ldr x9,[x1,#72]
 cmp x9,#1
 b.ne .Lsl_bad
 ldr x9,[x1,#80]
 cmp x9,x15
 b.ne .Lsl_bad
 mov x13,x1
 sub x14,x2,#1
 ldr x9,[x13,#64]
 mul x14,x14,x9
 ldr x1,[x13]
 cbz x1,.Lsl_bad
 add x1,x1,x14,lsl #3
 ldp x2,x9,[x13,#48]
 sub x2,x9,x2
 add x2,x2,#1
 ldr x3,[x13,#40]
 mov x4,#8
 b .Lsl_make1

// x0 target plane descriptor; x1 rank-three pointer; x2 actual third index.
.Lsl_plane3:
 ldr x9,[x1,#48]
 cmp x9,#1
 b.ne .Lsl_bad
 mov x13,x1
 mov x14,x2
 ldp x9,x10,[x13,#96]
 cmp x14,x9
 b.lt .Lsl_bad
 cmp x14,x10
 b.gt .Lsl_bad
 sub x14,x14,x9
 ldr x9,[x13,#88]
 mul x14,x14,x9
 ldr x1,[x13]
 add x1,x1,x14,lsl #3
 ldp x2,x9,[x13,#48]
 sub x2,x9,x2
 add x2,x2,#1
 ldp x3,x9,[x13,#72]
 sub x3,x9,x3
 add x3,x3,#1
 ldr x4,[x13,#40]
 ldr x5,[x13,#64]
 b .Lsl_make2
// x0 target vector; x1 rank-three source; x2 second index; x3 third index.
.Lsl_column3:
 ldr x9,[x1,#48]
 cmp x9,#1
 b.ne .Lsl_bad
 mov x13,x1
 mov x14,x2
 mov x15,x3
 ldp x9,x10,[x13,#72]
 cmp x14,x9
 b.lt .Lsl_bad
 cmp x14,x10
 b.gt .Lsl_bad
 sub x14,x14,x9
 ldr x9,[x13,#64]
 mul x14,x14,x9
 ldp x9,x10,[x13,#96]
 cmp x15,x9
 b.lt .Lsl_bad
 cmp x15,x10
 b.gt .Lsl_bad
 sub x15,x15,x9
 ldr x9,[x13,#88]
 madd x14,x15,x9,x14
 ldr x1,[x13]
 add x1,x1,x14,lsl #3
 ldp x2,x9,[x13,#48]
 sub x2,x9,x2
 add x2,x2,#1
 ldr x3,[x13,#40]
 mov x4,#8
 b .Lsl_make1
// x0 descriptor; x1 required rows; x2 required columns (zero denotes vector); x3 kind bytes.
.Lsl_raw:
 cbz x0,.Lsl_bad
 mov x13,x0
 ldr x9,[x13,#16]
 cmp x9,x3
 b.ne .Lsl_bad
 ldr x9,[x13,#40]
 cmp x9,#1
 b.ne .Lsl_bad
 ldp x9,x10,[x13,#48]
 cmp x9,#1
 b.ne .Lsl_bad
 sub x9,x10,x9
 add x9,x9,#1
 cmp x9,x1
 b.lt .Lsl_bad
 cbz x2,.Lsl_raw_pointer
 cmp x9,x1
 b.ne .Lsl_bad
 ldr x9,[x13,#64]
 cmp x9,x1
 b.ne .Lsl_bad
 ldp x9,x10,[x13,#72]
 sub x9,x10,x9
 add x9,x9,#1
 cmp x9,x2
 b.lt .Lsl_bad
.Lsl_raw_pointer:
 ldr x0,[x13]
 cbz x1,.Lsl_raw_done
 cbz x0,.Lsl_bad
.Lsl_raw_done:
 ret

// Read an int32 MP selector through the original allocated field handle.
.macro FIELD result,carrier,pointer_offset,scalar_offset
 ADDR x9,\carrier,\pointer_offset
 ldr x9,[x9]
 cbz x9,.Lsl_bad
 ldr \result,[x9,#\scalar_offset]
.endm
.macro HOOK label,length,selector,handle
 GLOBAL x9,__yomhook_MOD_lhook
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lsl_bad
 cbz w9,.Lsl_no_hook_\@
 adr x0,\label
 add x1,sp,#3592
 mov w9,#\selector
 str w9,[x1]
 SPADDR x2,\handle
 mov x3,#\length
 CALL __yomhook_MOD_dr_hook_default8
.Lsl_no_hook_\@:
.endm

// Contiguous rank-three raw owner; any zero expected extent is unconsumed.
.Lsl_raw3:
 cbz x0,.Lsl_bad
 mov x13,x0
 cbz x1,.Lsl_raw3_zero
 cbz x2,.Lsl_raw3_zero
 cbz x3,.Lsl_raw3_zero
 ldr x9,[x13,#16]
 cmp x9,x4
 b.ne .Lsl_bad
 ldr x9,[x13,#40]
 cmp x9,#1
 b.ne .Lsl_bad
 ldp x9,x10,[x13,#48]
 cmp x9,#1
 b.ne .Lsl_bad
 sub x9,x10,x9
 add x9,x9,#1
 cmp x9,x1
 b.ne .Lsl_bad
 ldr x9,[x13,#64]
 cmp x9,x1
 b.ne .Lsl_bad
 ldp x9,x10,[x13,#72]
 sub x9,x10,x9
 add x9,x9,#1
 cmp x9,x2
 b.ne .Lsl_bad
 mul x9,x1,x2
 ldr x10,[x13,#88]
 cmp x9,x10
 b.ne .Lsl_bad
 ldp x9,x10,[x13,#96]
 sub x9,x10,x9
 add x9,x9,#1
 cmp x9,x3
 b.lt .Lsl_bad
 ldr x0,[x13]
 cbz x0,.Lsl_bad
 ret
.Lsl_raw3_zero:
 ldr x0,[x13]
 ret

// x0 profile descriptor, x1 required rows, x2 required levels. Signed strides are retained.
.Lsl_bounds2:
 cbz x0,.Lsl_bad
 ldr x9,[x0]
 cbz x9,.Lsl_bad
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lsl_bad
 ldp x9,x10,[x0,#48]
 cmp x9,#1
 b.ne .Lsl_bad
 sub x10,x10,x9
 add x10,x10,#1
 cmp x10,x1
 b.lt .Lsl_bad
 ldp x9,x10,[x0,#72]
 cmp x9,#1
 b.ne .Lsl_bad
 sub x10,x10,x9
 add x10,x10,#1
 cmp x10,x2
 b.lt .Lsl_bad
 ret
.Lsl_bounds1:
 cbz x0,.Lsl_bad
 ldr x9,[x0]
 cbz x9,.Lsl_bad
 ldr x9,[x0,#16]
 cmp x9,#8
 b.ne .Lsl_bad
 ldp x9,x10,[x0,#48]
 cmp x9,#1
 b.ne .Lsl_bad
 sub x10,x10,x9
 add x10,x10,#1
 cmp x10,x1
 b.lt .Lsl_bad
 ret

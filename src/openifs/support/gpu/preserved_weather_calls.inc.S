/* Reuse accepted GPU call transport without changing any instruction.
 * "Upper" calls retain the 16 upper FP64 words in a 256-byte frame.
 * "Full" calls retain all 31 general registers and all 32 complete vector
 * registers in a 1024-byte frame. The source operation selects its result.
 * An assembler repetition expands the listed registers in their given order.
 */
#ifndef MD2ASM_PRESERVED_WEATHER_CALLS
#define MD2ASM_PRESERVED_WEATHER_CALLS
.macro md2asm_gpu_upper_save
 .irp number,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
 str d\number,[sp,#(128+8*(\number-16))]
 .endr
.endm
.macro md2asm_gpu_upper_restore
 .irp number,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
 ldr d\number,[sp,#(128+8*(\number-16))]
 .endr
.endm
/* Arguments are the existing host, mode, destination and source registers.
 * Missing operands are zero. Integer32 input uses the original sign extension.
 * Flag timing retains the original save position; comparison installs NZCV.
 */
.macro md2asm_gpu_upper_operation host,mode,destination,first,second=zero,first_kind=real,flag_timing=late,result_kind=real,frame=256,integer_transport=general
 sub sp,sp,#\frame
 stp x0,x1,[sp,#80]
 str d0,[sp,#96]
 str x17,[sp,#104]
 .ifc \flag_timing,early
 mrs x17,nzcv
 str x17,[sp,#112]
 .endif
 str x30,[sp,#120]
 .if \frame==256
 md2asm_gpu_upper_save
 .endif
 .irp offset,0,8,16,24,32,40,48,56,64
 str xzr,[sp,#\offset]
 .endr
 .ifc \first_kind,integer32
 sxtw x17,\first
 str x17,[sp,#0]
 .else
 .ifnc \first,zero
 str \first,[sp,#0]
 .endif
 .endif
 .ifnc \second,zero
 str \second,[sp,#8]
 .endif
 .ifc \flag_timing,late
 mrs x17,nzcv
 str x17,[sp,#112]
 .endif
 mov x0,sp
 mov w1,#\mode
 bl \host
 .ifc \result_kind,integer
 .ifc \integer_transport,general
 fmov x17,d0
 str x17,[sp,#72]
 .endif
 .endif
 .if \frame==256
 md2asm_gpu_upper_restore
 .endif
 .ifc \result_kind,integer
 .ifc \integer_transport,direct_after_upper
 str d0,[sp,#72]
 .endif
 .ifc \integer_transport,register_after_upper
 fmov x17,d0
 mov \destination,x17
 .endif
 .endif
 .ifc \result_kind,comparison
 msr nzcv,x0
 ldr d0,[sp,#96]
 .else
 .ifc \result_kind,integer
 ldr d0,[sp,#96]
 .else
 .ifnc \destination,d0
 fmov \destination,d0
 ldr d0,[sp,#96]
 .endif
 .endif
 ldr x17,[sp,#112]
 msr nzcv,x17
 .endif
 ldr x30,[sp,#120]
 ldr x17,[sp,#104]
 ldp x0,x1,[sp,#80]
 .ifc \result_kind,integer
 .ifnc \integer_transport,register_after_upper
 ldr \destination,[sp,#72]
 .endif
 .endif
 add sp,sp,#\frame
.endm
.macro md2asm_gpu_full_save
 sub sp,sp,#1024
 .irp number,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
 str x\number,[sp,#(128+8*\number)]
 .endr
 .irp number,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
 str q\number,[sp,#(384+16*\number)]
 .endr
 mrs x16,nzcv
 str x16,[sp,#96]
.endm
.macro md2asm_gpu_full_restore flags_offset=96
 .irp number,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
 ldr q\number,[sp,#(384+16*\number)]
 .endr
 ldr x16,[sp,#\flags_offset]
 msr nzcv,x16
 .irp number,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
 ldr x\number,[sp,#(128+8*\number)]
 .endr
.endm
.macro md2asm_gpu_zero_operands
 .irp offset,0,8,16,24,32,40,48,56,64
 str xzr,[sp,#\offset]
 .endr
.endm
/* A general input is read from its saved original register. */
.macro md2asm_gpu_full_operand operand,offset
 .ifnc \operand,zero
 .irp number,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
 .ifc \operand,x\number
 ldr x16,[sp,#(128+8*\number)]
 str x16,[sp,#\offset]
 .endif
 .ifc \operand,w\number
 ldr w16,[sp,#(128+8*\number)]
 sxtw x16,w16
 str x16,[sp,#\offset]
 .endif
 .endr
 .irp number,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
 .ifc \operand,d\number
 str \operand,[sp,#\offset]
 .endif
 .endr
 .endif
.endm
.macro md2asm_gpu_full_scalar host,mode,destination,first,second=zero,result_kind=real
 md2asm_gpu_full_save
 md2asm_gpu_zero_operands
 md2asm_gpu_full_operand \first,0
 md2asm_gpu_full_operand \second,8
 mov x0,sp
 mov w1,#\mode
 bl \host
 str d0,[sp,#104]
 .ifc \result_kind,comparison
 str x0,[sp,#112]
 md2asm_gpu_full_restore 112
 .else
 md2asm_gpu_full_restore
 ldr \destination,[sp,#104]
 .endif
 add sp,sp,#1024
.endm
/* Read one original lane from a saved complete vector register. */
.macro md2asm_gpu_vector_operand operand,offset,lane
 .irp number,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
 .ifc \operand,q\number
 ldr x16,[sp,#(384+16*\number+8*\lane)]
 str x16,[sp,#\offset]
 .endif
 .endr
.endm
.macro md2asm_gpu_full_vector_pair host,mode,destination,first,second
 md2asm_gpu_full_save
 .irp lane,0,1
 md2asm_gpu_zero_operands
 md2asm_gpu_vector_operand \first,0,\lane
 md2asm_gpu_vector_operand \second,8,\lane
 mov x0,sp
 mov w1,#\mode
 bl \host
 str d0,[sp,#(896+8*\lane)]
 .endr
 md2asm_gpu_full_restore
 ldr \destination,[sp,#896]
 add sp,sp,#1024
.endm
#endif

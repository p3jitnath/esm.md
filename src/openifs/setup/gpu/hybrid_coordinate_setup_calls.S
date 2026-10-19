/* GPU contract: skills/md2asm-gpu/references/openifs/setup/hybrid_coordinate_setup.md */
// Internal Arm phase after the unchanged successful eight-owner allocation.
// x0 record, w1 levels, x2 A, x3 B, d0 reference pressure in pascals.
// One synchronous device call retains the complete input records and owner lifetime.
.arch armv8.2-a
.text
.p2align 4
.global md2asm_hybrid_coordinate_setup_gpu_phase
.type md2asm_hybrid_coordinate_setup_gpu_phase,%function
md2asm_hybrid_coordinate_setup_gpu_phase:
 sub sp,sp,#256
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 str x18,[sp,#64]
 mrs x8,nzcv
 str x8,[sp,#80]
 mov x29,sp
 mrs x21,fpsr
 mrs x22,fpcr
 stp x0,x1,[sp,#128]
 stp x2,x3,[sp,#144]
 fmov x8,d0
 str x8,[sp,#160]
 mov x8,#0x100000000
 str x8,[sp,#176]
 stp xzr,xzr,[sp,#184]
 stp xzr,xzr,[sp,#200]
 stp xzr,xzr,[sp,#216]
 str xzr,[sp,#232]
 add x19,sp,#128
 add x20,sp,#176
 bl __errno_location
 mov x23,x0
 ldr w24,[x23]
 bl md2asm_openifs_gpu_prepare
 cbnz w0,.Lhybrid_phase_transport_failure
 adrp x0,.Lhybrid_phase_name
 add x0,x0,:lo12:.Lhybrid_phase_name
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#1
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 cbnz w0,.Lhybrid_phase_transport_failure
 ldr w8,[x20]
 cbnz w8,.Lhybrid_phase_transport_failure
 ldr x8,[x20,#24]
 cmp x8,#1
 b.ne .Lhybrid_phase_transport_failure
 str w24,[x23]
 ldr w8,[x20,#8]
 orr x8,x8,x21
 msr fpsr,x8
 msr fpcr,x22
 ldr x8,[sp,#80]
 msr nzcv,x8
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldr x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#256
 mov w0,#0
 ret
.Lhybrid_phase_transport_failure:
 bl abort
 brk #0
.size md2asm_hybrid_coordinate_setup_gpu_phase,.-md2asm_hybrid_coordinate_setup_gpu_phase
.section .rodata
.Lhybrid_phase_name:
.asciz "md2asm_gpu_hybrid_coordinate_setup"
.section .note.GNU-stack,"",%progbits

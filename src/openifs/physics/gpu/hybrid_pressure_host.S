/* Original nine-address EC pressure binding. Numerical equations execute on GPU. GPU implementation contract skills/md2asm-gpu/references/openifs/dynamics/private_hybrid_pressure.md.
 * Shared256B GPHPRE prefix and storage setup are reused literally. Record272
 * adds optional pointer/capacity for the actual source-owned EXP counter.
 * Context24 retains its accepted readonly trace meaning.
 */
.text
.p2align 4
.macro BEGIN name,count
.global \name
.type \name,%function
\name:
 sub sp,sp,#2048
 stp x29,x30,[sp,#128]
 stp x19,x20,[sp,#144]
 stp x21,x22,[sp,#160]
 stp x23,x24,[sp,#176]
 stp x25,x26,[sp,#192]
 stp x27,x28,[sp,#208]
 str x18,[sp,#224]
 add x29,sp,#128
 stp x0,x1,[sp,#256]
 stp x2,x3,[sp,#272]
 stp x4,x5,[sp,#288]
 stp x6,x7,[sp,#304]
 .if \count > 8
 add x9,sp,#2048
 add x10,sp,#320
 mov w11,#(\count-8)
.Lcopy\@:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs w11,w11,#1
 b.ne .Lcopy\@
 .endif
 add x19,sp,#256
 add x20,sp,#1056
 add x21,sp,#1120
 stp xzr,xzr,[x20]
 stp xzr,xzr,[x20,#16]
 stp xzr,xzr,[x20,#32]
 stp xzr,xzr,[x20,#48]
 mov w9,#1
 str w9,[x20,#4]
 mov x9,x21
 mov w10,#32
.Lrecord_zero\@:
 stp xzr,xzr,[x9],#16
 subs w10,w10,#1
 b.ne .Lrecord_zero\@
.endm
.macro RECORD bytes
 str x21,[x20,#48]
 mov x9,#\bytes
 str x9,[x20,#56]
.endm
.macro BYTES destination,left,right
 umulh x17,\left,\right
 cbnz x17,.Lbulk_failure
 mul \destination,\left,\right
 lsr x17,\destination,#60
 cbnz x17,.Lbulk_failure
 lsl \destination,\destination,#3
.endm
.macro SERVICE target
 str x0,[sp,#1696]
 mrs x9,fpcr
 str x9,[sp,#1664]
 mrs x9,fpsr
 str x9,[sp,#1672]
 bl __errno_location
 ldr x18,[sp,#224]
 str x0,[sp,#1680]
 ldr w9,[x0]
 str w9,[sp,#1688]
 ldr x0,[sp,#1696]
 bl \target
 ldr x18,[sp,#224]
 str x0,[sp,#1704]
 ldr x9,[sp,#1680]
 ldr w10,[sp,#1688]
 str w10,[x9]
 ldr x9,[sp,#1664]
 msr fpcr,x9
 ldr x9,[sp,#1672]
 msr fpsr,x9
 ldr x0,[sp,#1704]
.endm
.macro PARALLEL_STATE
 SERVICE __oml_mod_MOD_oml_in_parallel
 cmp w0,#0
 cset w9,ne
 str w9,[x20,#12]
.endm
.macro FINISH name,entry,threads,counter,release=0
 bl md2asm_openifs_gpu_prepare
 ldr x18,[sp,#224]
 cbnz w0,.Lbulk_failure
 adrp x0,.Lentry\@
 add x0,x0,:lo12:.Lentry\@
 mov x1,x19
 mov x2,x20
 mov w3,#1
 mov w4,#\threads
 mov w5,#0
 bl md2asm_openifs_gpu_launch
 ldr x18,[sp,#224]
 cbnz w0,.Lbulk_failure
 ldr w9,[x20]
 cbnz w9,.Lbulk_failure
 .if \release
 ldr x0,[x20,#32]
 cbz x0,.Lno_release\@
 SERVICE free
.Lno_release\@:
 .endif
 adrp x9,:got:\counter
 ldr x9,[x9,:got_lo12:\counter]
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x18,[sp,#224]
 ldp x19,x20,[sp,#144]
 ldp x21,x22,[sp,#160]
 ldp x23,x24,[sp,#176]
 ldp x25,x26,[sp,#192]
 ldp x27,x28,[sp,#208]
 ldp x29,x30,[sp,#128]
 add sp,sp,#2048
 ret
.size \name,.-\name
.section .rodata
.Lentry\@: .asciz "\entry"
.bss
.balign 8
.global \counter
.hidden \counter
\counter: .zero 8
.text
.endm
.macro ALIAS name,target
.global \name
.set \name,\target
.endm
.macro VERTICAL_RECORD argv_bytes
 ldr x9,[x19]
 ldrsw x22,[x9]
 ldr x9,[x19,#24]
 ldrsw x23,[x9]
 ldr x9,[x19,#32]
 ldrsw x24,[x9]
 cmp x22,#1
 b.lt .Lbulk_failure
 cmp x23,#1
 b.lt .Lbulk_failure
 cmp x24,#1
 b.lt .Lbulk_failure
 BYTES x9,x22,x23
 str x9,[x21]
 BYTES x9,x22,x24
 str x9,[x21,#8]
 BYTES x9,x23,x24
 str x9,[x21,#16]
 mov x9,#\argv_bytes
 str x9,[x21,#40]
 RECORD 64
.endm
.macro GLOBAL_ADDRESS destination,symbol
 adrp \destination,:got:\symbol
 ldr \destination,[\destination,:got_lo12:\symbol]
.endm
.macro DESCRIPTOR_BYTES destination,descriptor
 ldr x14,[\descriptor,#48]
 ldr x15,[\descriptor,#56]
 cmp x15,x14
 b.lt .Lbulk_failure
 subs x15,x15,x14
 b.vs .Lbulk_failure
 adds x15,x15,#1
 b.vs .Lbulk_failure
 lsr x14,x15,#60
 cbnz x14,.Lbulk_failure
 lsl \destination,x15,#3
.endm
.macro ALLOCATE_SCRATCH
 // x0 contains an integer byte count. No numerical state is initialized here.
 str x0,[x20,#40]
 SERVICE malloc
 cbz x0,.Lbulk_failure
 str x0,[x20,#32]
.endm
.macro OPTIONAL_CAPACITY slot,bytes
 ldr x16,[x19,#(8*\slot)]
 cmp x16,#0
 csel x16,\bytes,xzr,ne
 str x16,[x21,#(8*\slot)]
.endm
.macro COEFFICIENT_CAPACITY descriptor_offset,record_offset
 add x10,x26,#\descriptor_offset
 ldr x9,[x10]
 cbz x9,.Lcoefficient_absent\@
 ldr x14,[x10,#48]
 ldr x15,[x10,#56]
 cmp x15,x14
 b.lt .Lcoefficient_absent\@
 subs x15,x15,x14
 b.vs .Lcoefficient_absent\@
 adds x15,x15,#1
 b.vs .Lcoefficient_absent\@
 lsr x14,x15,#60
 cbnz x14,.Lcoefficient_absent\@
 lsl x9,x15,#3
 str x9,[x21,#\record_offset]
.Lcoefficient_absent\@:
.endm
BEGIN md2asm_ec_pressure_7358525,9
 SERVICE omp_in_parallel
 cbnz w0,.Lbulk_failure
 RECORD 272
 GLOBAL_ADDRESS x9,md2asm_exponential_native_calls_storage
 str x9,[x21,#256]
 mov x10,#0
 cbz x9,.Lec_pressure_counter_absent
 mov x10,#8
.Lec_pressure_counter_absent:
 str x10,[x21,#264]
 mov x9,#4
 str x9,[x21]
 str x9,[x21,#8]
 str x9,[x21,#16]
 str x9,[x21,#24]
 mov x9,#72
 str x9,[x21,#168]
 ldr x9,[x19]
 ldrsw x22,[x9]
 ldr x9,[x19,#8]
 ldrsw x23,[x9]
 cmp x22,#1
 b.lt .Lbulk_failure
 cmp x23,#0
 b.lt .Lbulk_failure
 cbz x23,.Lgphpre_ready
 ldr x9,[x19,#16]
 ldr w10,[x9]
 ldr x9,[x19,#24]
 ldr w11,[x9]
 cmp w11,w10
 b.lt .Lgphpre_ready
 add x9,x23,#1
 BYTES x25,x22,x9
 str x25,[x21,#48]
 BYTES x24,x22,x23
 mov x9,#512
 str x9,[x21,#32]
 ldr x26,[x19,#32]
 COEFFICIENT_CAPACITY 128,72
 COEFFICIENT_CAPACITY 64,80
 ldr x9,[x19,#56]
 ldr x10,[x19,#64]
 orr x9,x9,x10
 cbz x9,.Lgphpre_ready
 mov x9,#216
 str x9,[x21,#40]
 COEFFICIENT_CAPACITY 256,88
 COEFFICIENT_CAPACITY 320,96
 COEFFICIENT_CAPACITY 384,104
 COEFFICIENT_CAPACITY 448,112
 COEFFICIENT_CAPACITY 192,120
 GLOBAL_ADDRESS x27,__intdyn_mod_MOD_yytxyb
 str x27,[x21,#128]
 mov x9,#32
 str x9,[x21,#136]
 GLOBAL_ADDRESS x9,__yomvert_MOD_toppres
 str x9,[x21,#144]
 GLOBAL_ADDRESS x9,__yomcst_MOD_rd
 str x9,[x21,#152]
 GLOBAL_ADDRESS x9,__yomcst_MOD_rcvd
 str x9,[x21,#160]
 // The owning hydrostatic caller allocates exactly seven pressure fields.
 ldr w9,[x27,#28]
 cmp w9,#7
 b.ne .Lbulk_failure
 str w9,[x21,#176]
 mov x9,#7
 mul x9,x24,x9
 OPTIONAL_CAPACITY 7,x9
 OPTIONAL_CAPACITY 8,x24
 mov x9,#7
 mul x9,x23,x9
 add x9,x9,#1
 BYTES x0,x22,x9
 ALLOCATE_SCRATCH
.Lgphpre_ready:
FINISH md2asm_ec_pressure_7358525,md2asm_gpu_ec_pressure_columns_entry,32,ec_pressure_gpu_calls,1
.Lbulk_failure:bl abort
.weak md2asm_exponential_native_calls_storage
#ifdef MD2ASM_GPU_VERIFY_ONLY
.bss
.balign 8
.global md2asm_exponential_native_calls_storage
md2asm_exponential_native_calls_storage:.zero 8
#endif
.section .note.GNU-stack,"",%progbits

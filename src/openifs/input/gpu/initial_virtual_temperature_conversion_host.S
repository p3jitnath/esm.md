/* Selected initial SPECRT, KDIR zero, no spectral water or increments.
 * Physics: formulations/openifs/dynamics/virtual_temperature_conversion.md, revision1.0.
 * CPU parent: skills/md2asm/references/openifs/input/initial_virtual_temperature_conversion.md.
 * GPU cells: skills/md2asm-gpu/references/openifs/input/initial_virtual_temperature_cells_complete_contract.md.
 * x0 Geometry20400, x1 TGFL1096, x2 TYPE_GFLD1359136,
 * x3 SPECTRAL_FIELD2992, x4 constants520. Return0/1 allocation/2 scope.
 * Complete mapped aligned disjoint views and qualified metadata are caller obligations.
 * Public ECTRANS owns the declared transforms. All OpenIFS calculation is direct assembly. */
.arch armv8.2-a
.text
.p2align 4
.macro VT_CALL target
 bl \target
 ldr x18,[sp,#144]
.endm
.macro VT_GLOBAL reg,name
 adrp \reg,:got:\name
 ldr \reg,[\reg,:got_lo12:\name]
.endm
.global md2asm_initialize_spectral_virtual_temperature
.type md2asm_initialize_spectral_virtual_temperature,%function
md2asm_initialize_spectral_virtual_temperature:
 cbz x0,.Lvt_bad_leaf
 cbz x1,.Lvt_bad_leaf
 cbz x2,.Lvt_bad_leaf
 cbz x3,.Lvt_bad_leaf
 cbz x4,.Lvt_bad_leaf
 orr x9,x0,x1
 orr x9,x9,x2
 orr x9,x9,x3
 orr x9,x9,x4
 tst x9,#7
 b.ne .Lvt_bad_leaf
 mrs x9,fpcr
 cbnz x9,.Lvt_bad_leaf
 ldr w9,[x0,#5144]
 cmp w9,#24
 b.ne .Lvt_bad_leaf
 ldr w9,[x0,#5160]
 cmp w9,#86
 b.ne .Lvt_bad_leaf
 ldr w9,[x0,#5168]
 cmp w9,#1
 b.ne .Lvt_bad_leaf
 ldr w9,[x0,#5200]
 cmp w9,#506
 b.ne .Lvt_bad_leaf
 ldr w9,[x0,#5224]
 cmp w9,#19
 b.ne .Lvt_bad_leaf
 ldr w9,[x0,#5228]
 cmp w9,#19
 b.ne .Lvt_bad_leaf
 ldr w9,[x0,#7376]
 cmp w9,#2048
 b.ne .Lvt_bad_leaf
 ldr x9,[x1,#1088]
 cmp x9,x2
 b.ne .Lvt_bad_leaf
 ldr w9,[x2,#8]
 cbnz w9,.Lvt_bad_leaf
 VT_GLOBAL x9,__yom_ygfl_MOD_ygfl
 ldr x9,[x9]
 cmp x9,x2
 b.ne .Lvt_bad_leaf
 VT_GLOBAL x9,__yomcst_MOD_rd
 add x10,x4,#184
 cmp x9,x10
 b.ne .Lvt_bad_leaf
 /* Existing source-compatible component pointers are valid complete inputs. */
 movz x9,#(799840 & 65535)
 movk x9,#(799840 >> 16),lsl #16
 ldr x10,[x2,x9]
 cbz x10,.Lvt_bad_leaf
 ldr w10,[x10,#56]
 cbnz w10,.Lvt_bad_leaf
 movz x9,#(799848 & 65535)
 movk x9,#(799848 >> 16),lsl #16
 ldr x10,[x2,x9]
 cbz x10,.Lvt_bad_leaf
 ldr w10,[x10,#56]
 cbnz w10,.Lvt_bad_leaf
 movz x9,#(799856 & 65535)
 movk x9,#(799856 >> 16),lsl #16
 ldr x10,[x2,x9]
 cbz x10,.Lvt_bad_leaf
 ldr w10,[x10,#56]
 cbnz w10,.Lvt_bad_leaf
 ldr x9,[x1]
 cbz x9,.Lvt_bad_leaf
 ldr x9,[x3,#1696]
 cbz x9,.Lvt_bad_leaf
 sub sp,sp,#512
 stp x29,x30,[sp,#128]
 stp x18,x19,[sp,#144]
 stp x20,x21,[sp,#160]
 stp x22,x23,[sp,#176]
 stp x24,x25,[sp,#192]
 stp x26,x27,[sp,#208]
 str x28,[sp,#224]
 mov x29,sp
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,#0
 mov x25,#0
 VT_CALL __errno_location
 mov x26,x0
 ldr w27,[x26]
 mov x0,#0xc980
 movk x0,#4,lsl#16
 VT_CALL malloc
 cbz x0,.Lvt_allocation_failure
 mov x24,x0
 mov x0,#3648
 VT_CALL malloc
 cbz x0,.Lvt_allocation_failure
 mov x25,x0
 str w27,[x26]
 /* GNU12 real rank-three descriptor for ZT(24,19,86). */
 str x24,[sp,#240]
 mov x9,#-481
 str x9,[sp,#248]
 mov x9,#8
 str x9,[sp,#256]
 mov x10,#0x303
 lsl x10,x10,#32
 str x10,[sp,#264]
 str x9,[sp,#272]
 mov x9,#1
 stp x9,x9,[sp,#280]
 mov x10,#24
 stp x10,x10,[sp,#296]
 str x9,[sp,#312]
 mov x10,#19
 str x10,[sp,#320]
 mov x10,#456
 str x10,[sp,#328]
 str x9,[sp,#336]
 mov x10,#86
 str x10,[sp,#344]
 mov w9,#24
 mov w10,#1
 str w9,[sp,#352]
 str w10,[sp,#356]
 mov w9,#19
 str w9,[sp,#364]
 /* INV_TRANS optional arguments, with only T and PGP present. */
 stp xzr,xzr,[sp]
 stp xzr,xzr,[sp,#16]
 add x9,x19,#1,lsl#12
 add x9,x9,#1048
 stp x9,xzr,[sp,#32]
 mov x9,#6584
 add x9,x19,x9
 add x10,x19,#1,lsl#12
 add x10,x10,#1072
 stp x9,x10,[sp,#48]
 stp xzr,xzr,[sp,#64]
 add x9,sp,#240
 stp xzr,x9,[sp,#80]
 stp xzr,xzr,[sp,#96]
 stp xzr,xzr,[sp,#112]
 mov x0,#0
 mov x1,#0
 add x2,x22,#1696
 mov x3,#0
 mov x4,#0
 mov x5,#0
 mov x6,#0
 mov x7,#0
 VT_CALL inv_trans_
 mov x28,#0
.Lvt_blocks:
 cmp x28,#85
 mov w9,#24
 mov w10,#8
 csel w9,w10,w9,eq
 str w9,[sp,#360]
 /* Unchanged complete generic mixture child, requesting only PR. */
 stp xzr,xzr,[sp]
 stp xzr,x25,[sp,#16]
 mov x9,#29184
 mul x9,x28,x9
 ldr x10,[x20]
 add x9,x10,x9
 stp xzr,x9,[sp,#32]
 stp xzr,xzr,[sp,#48]
 add x0,sp,#352
 add x1,sp,#356
 add x2,sp,#360
 add x3,sp,#364
 mov x4,#0
 mov x5,#0
 mov x6,#0
 mov x7,#0
 VT_CALL md2asm_initial_virtual_temperature_gas
 mov x9,#3648
 madd x0,x28,x9,x24
 mov x1,x25
 ldr w2,[sp,#360]
 mov x3,x23
 bl md2asm_initial_virtual_temperature_cells
 add x28,x28,#1
 cmp x28,#86
 b.lo .Lvt_blocks
 /* DIR_TRANS uses the same live field-set, resolution and temperature view. */
 mov x9,#6584
 add x9,x19,x9
 stp xzr,x9,[sp]
 add x9,x19,#1,lsl#12
 add x9,x9,#1072
 stp x9,xzr,[sp,#16]
 stp xzr,xzr,[sp,#32]
 add x9,sp,#240
 stp x9,xzr,[sp,#48]
 stp xzr,xzr,[sp,#64]
 stp xzr,xzr,[sp,#80]
 mov x0,#0
 mov x1,#0
 add x2,x22,#1696
 mov x3,#0
 mov x4,#0
 mov x5,#0
 mov x6,#0
 add x7,x19,#1,lsl#12
 add x7,x7,#1048
 VT_CALL dir_trans_
 ldr w27,[x26]
 mov w28,#0
 b .Lvt_cleanup
.Lvt_allocation_failure:
 ldr w27,[x26]
 mov w28,#1
.Lvt_cleanup:
 cbz x25,.Lvt_free_temperature
 mov x0,x25
 VT_CALL free
.Lvt_free_temperature:
 cbz x24,.Lvt_return
 mov x0,x24
 VT_CALL free
.Lvt_return:
 str w27,[x26]
 mov w0,w28
 ldr x28,[sp,#224]
 ldp x26,x27,[sp,#208]
 ldp x24,x25,[sp,#192]
 ldp x22,x23,[sp,#176]
 ldp x20,x21,[sp,#160]
 ldp x18,x19,[sp,#144]
 ldp x29,x30,[sp,#128]
 add sp,sp,#512
 ret
.Lvt_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_spectral_virtual_temperature,.-md2asm_initialize_spectral_virtual_temperature

/* x0 mutable T(24,19), x1 mixture gas constant(24,19), w2 active1..24,
 * x3 constants520. Only active T cells change. All complete spans are disjoint.
 * T is in kelvin and gas constants are in joules per kilogram per kelvin. */
.p2align 4
.global md2asm_initial_virtual_temperature_cells
.type md2asm_initial_virtual_temperature_cells,%function
md2asm_initial_virtual_temperature_cells:
 b md2asm_gpu_initial_virtual_temperature_cells_phase_host
.size md2asm_initial_virtual_temperature_cells,.-md2asm_initial_virtual_temperature_cells
.section .note.GNU-stack,"",%progbits

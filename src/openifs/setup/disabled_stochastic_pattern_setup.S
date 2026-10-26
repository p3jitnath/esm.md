/* Complete source-defined disabled SUSPSDT and GET_SPP_CONF setup.
 * Contract: skills/md2asm/references/openifs/setup/disabled_stochastic_pattern_setup.md.
 * Keep the two source stages separate around INI_CUCONVCA/SURAND1.
 * Undefined source bytes retain each incoming owner's preimage.
 * Empty arrays have real one-byte reservations; their payload is never read.
 * Public entries use live Geometry and owned MODEL records, never original globals.
 */
.arch armv8.2-a
.text
.macro DS_CONST reg,val
 movz \reg,#((\val)&65535)
 movk \reg,#(((\val)>>16)&65535),lsl#16
.endm
.macro DS_APART a,enda,b,endb,bad
 cmp \a,\endb
 b.hs .Lds_apart\@
 cmp \b,\enda
 b.lo \bad
.Lds_apart\@:
.endm
.macro DS_WORD offset,value
 DS_CONST x9,\offset
 mov w10,#\value
 str w10,[x0,x9]
.endm
.macro DS_NULL offset
 DS_CONST x9,\offset
 str xzr,[x0,x9]
.endm
.macro DS_FILL offset,count,value
 DS_CONST x9,\offset
 add x9,x0,x9
 mov x10,#\count
 mov w11,#\value
.Lds_fill\@:
 str w11,[x9],#4
 subs x10,x10,#1
 b.ne .Lds_fill\@
.endm
.macro DS_COPY offset,label,bytes
 DS_CONST x9,\offset
 add x9,x0,x9
 adrp x10,\label
 add x10,x10,:lo12:\label
 mov x11,#((\bytes)/8)
.Lds_copy\@:
 ldr x12,[x10],#8
 str x12,[x9],#8
 subs x11,x11,#1
 b.ne .Lds_copy\@
.endm
.macro DS_DOUBLE offset,label
 DS_CONST x9,\offset
 adrp x10,\label
 ldr x10,[x10,:lo12:\label]
 str x10,[x0,x9]
.endm
/* Leaf descriptor: x0 header64, x1 owner, x2 element bytes,
 * x3 packed GNU dtype, x4 upper bound (zero or one).
 */
.p2align 4
.type .Lds_descriptor_one,%function
.Lds_descriptor_one:
 str x1,[x0]
 mov x9,#-1
 str x9,[x0,#8]
 stp x2,x3,[x0,#16]
 str x2,[x0,#32]
 mov x9,#1
 stp x9,x9,[x0,#40]
 str x4,[x0,#56]
 ret
.size .Lds_descriptor_one,.-.Lds_descriptor_one
/* Integer byte copy; the byte count is a positive multiple of eight. */
.p2align 4
.type .Lds_copy_bytes,%function
.Lds_copy_bytes:
 ldr x9,[x1],#8
 str x9,[x0],#8
 subs x2,x2,#8
 b.ne .Lds_copy_bytes
 ret
.size .Lds_copy_bytes,.-.Lds_copy_bytes
/* Four zero-extent payloads for one already owned GRIDPOINT_FIELD1808.
 * x0 record, x1 validated live Geometry. Parent preserves machine status.
 * The 80-byte private frame is aligned to16; return0 or1 after a prefix.
 */
.p2align 4
.type .Lds_initialize_empty_grid,%function
.Lds_initialize_empty_grid:
 stp x29,x30,[sp,#-80]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 mov x19,x0
 mov x20,x1
 DS_CONST x9,5144
 ldr w21,[x20,x9]
 DS_CONST x9,5224
 ldr w22,[x20,x9]
 DS_CONST x9,5160
 ldr w23,[x20,x9]
 DS_CONST x9,7376
 ldr w24,[x20,x9]
 DS_CONST x9,7388
 ldr w25,[x20,x9]
 stp wzr,wzr,[x19,#248]
 str w21,[x19,#256]
 str w23,[x19,#260]
 str w22,[x19,#264]
 str w24,[x19,#268]
 str w25,[x19,#272]
 mov x0,#1
 bl malloc
 cbz x0,.Lds_grid_failed
 mov x1,x0
 add x0,x19,#280
 mov x2,#4
 movz x3,#0x101,lsl#32
 mov x4,#0
 bl .Lds_descriptor_one
 mov x0,#1
 bl malloc
 cbz x0,.Lds_grid_failed
 mov x1,x0
 add x0,x19,#472
 mov x2,#4
 movz x3,#0x101,lsl#32
 mov x4,#0
 bl .Lds_descriptor_one
 add x0,x19,#408
 add x1,x19,#280
 mov x2,#64
 bl .Lds_copy_bytes
 add x0,x19,#344
 add x1,x19,#280
 mov x2,#64
 bl .Lds_copy_bytes
 add x0,x19,#600
 add x1,x19,#472
 mov x2,#64
 bl .Lds_copy_bytes
 add x0,x19,#536
 add x1,x19,#472
 mov x2,#64
 bl .Lds_copy_bytes
 mov x0,#1
 bl malloc
 cbz x0,.Lds_grid_failed
 str x0,[x19]
 mul x9,x21,x22
 add x10,x9,x21
 add x10,x10,#1
 neg x10,x10
 str x10,[x19,#8]
 mov x10,#8
 str x10,[x19,#16]
 movz x11,#0x304,lsl#32
 str x11,[x19,#24]
 str x10,[x19,#32]
 mov x10,#1
 stp x10,x10,[x19,#40]
 str x21,[x19,#56]
 stp x21,x10,[x19,#64]
 str x22,[x19,#80]
 stp x9,x10,[x19,#88]
 str xzr,[x19,#104]
 stp xzr,x10,[x19,#112]
 str x23,[x19,#128]
 mov x0,#1
 bl malloc
 cbz x0,.Lds_grid_failed
 str x0,[x19,#136]
 add x9,x21,#1
 neg x9,x9
 str x9,[x19,#144]
 mov x9,#8
 str x9,[x19,#152]
 movz x10,#0x303,lsl#32
 str x10,[x19,#160]
 str x9,[x19,#168]
 mov x9,#1
 stp x9,x9,[x19,#176]
 str x21,[x19,#192]
 stp x21,x9,[x19,#200]
 str xzr,[x19,#216]
 stp xzr,x9,[x19,#224]
 str x23,[x19,#240]
 /* NULLIFY of the nine unused source views changes only base words. */
 str xzr,[x19,#664]
 str xzr,[x19,#776]
 str xzr,[x19,#888]
 str xzr,[x19,#1000]
 str xzr,[x19,#1112]
 str xzr,[x19,#1224]
 str xzr,[x19,#1336]
 str xzr,[x19,#1448]
 str xzr,[x19,#1536]
 add x0,x19,#1672
 mov x1,x19
 mov x2,#136
 bl .Lds_copy_bytes
 /* NG3D=NG2D=0 makes both HUGIFY_ENDGRID field loops empty. */
 mov w0,#0
 b .Lds_grid_return
.Lds_grid_failed:
 mov w0,#1
.Lds_grid_return:
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.size .Lds_initialize_empty_grid,.-.Lds_initialize_empty_grid
/* Release only reached owned bases in source DEALLOCATE_GRID order,
 * then the outer record. x0 is a genuine complete record or null.
 */
.p2align 4
.type .Lds_release_grid,%function
.Lds_release_grid:
 cbz x0,.Lds_release_grid_leaf
 stp x29,x30,[sp,#-32]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 mov x19,x0
 mov x20,#0
.Lds_grid_free_next:
 adrp x9,.Lds_owned_offsets
 add x9,x9,:lo12:.Lds_owned_offsets
 ldr w9,[x9,x20,lsl#2]
 ldr x0,[x19,x9]
 cbz x0,.Lds_grid_free_skip
 bl free
 adrp x9,.Lds_owned_offsets
 add x9,x9,:lo12:.Lds_owned_offsets
 ldr w9,[x9,x20,lsl#2]
 str xzr,[x19,x9]
.Lds_grid_free_skip:
 add x20,x20,#1
 cmp x20,#4
 b.lo .Lds_grid_free_next
 mov x0,x19
 bl free
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#32
.Lds_release_grid_leaf:
 ret
.size .Lds_release_grid,.-.Lds_release_grid
/* Complete source-defined scalar/configuration publications.
 * x0 TSPPT_CONFIG, x1 TSPPT_DATA; no call or floating-point instruction.
 */
.p2align 4
.type .Lds_sppt_defined_stores,%function
.Lds_sppt_defined_stores:
 DS_NULL 112
 DS_NULL 120
 DS_WORD 0,0
 DS_WORD 12,0
 DS_WORD 4,0
 DS_WORD 8,0
 DS_WORD 16,0
 DS_COPY 16320,.Lds_sdev,240
 DS_COPY 16560,.Lds_tau,40
 DS_COPY 16600,.Lds_xlcor,40
 DS_WORD 128,1
 DS_COPY 16936,.Lds_spectrum_shape,128
 DS_WORD 20,1
 DS_WORD 24,1
 DS_WORD 304,1
 DS_COPY 16728,.Lds_clip_ratio,48
 DS_COPY 16680,.Lds_clip_max,48
 DS_WORD 28,1
 DS_WORD 308,3
 DS_DOUBLE 16776,.Lds_20000
 DS_WORD 32,1
 DS_FILL 36,6,1
 DS_DOUBLE 16832,.Lds_095
 DS_DOUBLE 16840,.Lds_1
 DS_WORD 60,0
 DS_FILL 64,6,1
 DS_DOUBLE 16848,.Lds_5000
 DS_DOUBLE 16856,.Lds_10000
 DS_WORD 88,1
 DS_WORD 92,0
 DS_WORD 136,1
 DS_WORD 96,0
 DS_WORD 132,1
 DS_WORD 100,0
 DS_WORD 104,0
 DS_WORD 108,0
 DS_FILL 144,20,-1000
 DS_FILL 224,20,-1000
 DS_WORD 140,1
 DS_WORD 16312,1
 DS_FILL 312,4000,20
 DS_DOUBLE 16928,.Lds_08
 mov w9,#1
 stp w9,w9,[x1]
 stp w9,w9,[x1,#8]
 stp w9,w9,[x1,#16]
 /* The disabled source branch overrides its earlier humidity limiter. */
 DS_WORD 28,0
 str xzr,[x1,#96]
 str xzr,[x1,#32]
 DS_NULL 17064
 DS_NULL 17128
 DS_NULL 17192
 DS_NULL 17256
 ret
.size .Lds_sppt_defined_stores,.-.Lds_sppt_defined_stores
/* Source-defined disabled GET_SPP_CONF stores, including declared defaults.
 * x0 TSPP_CONFIG. Preserve the undefined32B model-name and other unwritten bytes.
 */
.p2align 4
.type .Lds_spp_defined_stores,%function
.Lds_spp_defined_stores:
 DS_NULL 80
 DS_NULL 144
 DS_WORD 208,0
 DS_WORD 216,0
 DS_WORD 220,0
 DS_NULL 224
 DS_NULL 288
 DS_NULL 352
 DS_FILL 448,34,-1
 DS_WORD 0,0
 DS_WORD 584,0
 DS_WORD 588,1
 DS_WORD 592,0
 DS_WORD 3176,10000
 DS_WORD 3180,1
 DS_WORD 2660,0
 DS_WORD 596,0
 DS_WORD 600,0
 DS_WORD 2648,0
 DS_WORD 2652,0
 DS_WORD 608,-1000
 DS_WORD 1628,-1000
 DS_WORD 604,1
 DS_WORD 2656,1
 DS_COPY 2664,.Lds_spp_read_name,256
 DS_COPY 2920,.Lds_spp_write_name,256
 DS_DOUBLE 3184,.Lds_10000
 ret
.size .Lds_spp_defined_stores,.-.Lds_spp_defined_stores
/* Public source SUSPSDT boundary: G/cap, MODEL/cap, text/bytes.
 * Fresh actual owners only. Own frame256, maximum private frame336.
 */
.p2align 4
.global md2asm_initialize_disabled_sppt_setup
.type md2asm_initialize_disabled_sppt_setup,%function
md2asm_initialize_disabled_sppt_setup:
 mrs x6,fpcr
 cbnz x6,.Lds_sppt_bad_leaf
 cbz x0,.Lds_sppt_bad_leaf
 cbz x2,.Lds_sppt_bad_leaf
 cbz x4,.Lds_sppt_bad_leaf
 orr x6,x0,x2
 tst x6,#7
 b.ne .Lds_sppt_bad_leaf
 mov x6,#20400
 cmp x1,x6
 b.lo .Lds_sppt_bad_leaf
 adds x7,x0,x6
 b.cs .Lds_sppt_bad_leaf
 DS_CONST x6,4275088
 cmp x3,x6
 b.lo .Lds_sppt_bad_leaf
 adds x8,x2,x6
 b.cs .Lds_sppt_bad_leaf
 cbz x5,.Lds_sppt_bad_leaf
 cmp x5,#64,lsl#12
 b.hi .Lds_sppt_bad_leaf
 adds x9,x4,x5
 b.cs .Lds_sppt_bad_leaf
 DS_APART x0,x7,x2,x8,.Lds_sppt_bad_leaf
 DS_APART x0,x7,x4,x9,.Lds_sppt_bad_leaf
 DS_APART x2,x8,x4,x9,.Lds_sppt_bad_leaf
 ldr x10,[x2,#8]
 cmp x10,x0
 b.ne .Lds_sppt_bad_leaf
 DS_CONST x9,5144
 ldr w10,[x0,x9]
 cmp w10,#0
 b.le .Lds_sppt_bad_leaf
 cmp w10,#1024
 b.hi .Lds_sppt_bad_leaf
 DS_CONST x9,5224
 ldr w11,[x0,x9]
 cmp w11,#0
 b.le .Lds_sppt_bad_leaf
 cmp w11,#256
 b.hi .Lds_sppt_bad_leaf
 DS_CONST x9,5160
 ldr w12,[x0,x9]
 cmp w12,#0
 b.le .Lds_sppt_bad_leaf
 DS_CONST x9,7376
 ldr w13,[x0,x9]
 cmp w13,#0
 b.le .Lds_sppt_bad_leaf
 DS_CONST x9,7388
 ldr w14,[x0,x9]
 cmp w14,#0
 b.le .Lds_sppt_bad_leaf
 cmp w13,w14
 b.hi .Lds_sppt_bad_leaf
 sub w15,w13,#1
 udiv w15,w15,w10
 add w15,w15,#1
 cmp w15,w12
 b.ne .Lds_sppt_bad_leaf
 DS_CONST x9,4270832
 add x9,x2,x9
 mov x10,#5
.Lds_sppt_fresh_data:
 ldr x11,[x9],#64
 cbnz x11,.Lds_sppt_bad_leaf
 subs x10,x10,#1
 b.ne .Lds_sppt_fresh_data
 DS_CONST x9,1535720
 add x9,x2,x9
 ldp x10,x11,[x9]
 orr x10,x10,x11
 cbnz x10,.Lds_sppt_bad_leaf
 DS_CONST x9,1552672
 add x9,x2,x9
 mov x10,#4
.Lds_sppt_fresh_names:
 ldr x11,[x9],#64
 cbnz x11,.Lds_sppt_bad_leaf
 subs x10,x10,#1
 b.ne .Lds_sppt_fresh_names
 stp x29,x30,[sp,#-256]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 mrs x9,fpcr
 mrs x10,fpsr
 str x9,[sp,#104]
 str x10,[sp,#112]
 str xzr,[sp,#136]
 mov x19,x2
 mov x20,x0
 mov x21,x4
 mov x22,x5
 bl __errno_location
 str x0,[sp,#120]
 ldr w9,[x0]
 str w9,[sp,#128]
 mov x0,x21
 mov x1,x22
 adrp x2,.Lds_namspsdt
 add x2,x2,:lo12:.Lds_namspsdt
 mov x3,#8
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lds_sppt_bad_frame
 DS_CONST x23,1535608
 add x23,x19,x23
 DS_CONST x24,4270800
 add x24,x19,x24
 mov x0,x23
 mov x1,x24
 bl .Lds_sppt_defined_stores
 mov x0,#1
 bl malloc
 cbz x0,.Lds_sppt_allocation_failed
 str x0,[sp,#136]
 mov x25,#0
.Lds_sppt_record_next:
 mov x0,#1808
 bl malloc
 cbz x0,.Lds_sppt_allocation_failed
 mov x27,x0
 /* Source default initialisation defines18 null pointer bases only. */
 adrp x9,.Lds_grid_pointer_offsets
 add x9,x9,:lo12:.Lds_grid_pointer_offsets
 mov x10,#18
.Lds_sppt_null_pointer:
 ldr w11,[x9],#4
 str xzr,[x27,x11]
 subs x10,x10,#1
 b.ne .Lds_sppt_null_pointer
 add x26,x24,#160
 add x26,x26,x25,lsl#6
 mov x0,x26
 mov x1,x27
 mov x2,#1808
 movz x3,#0x501,lsl#32
 mov x4,#1
 bl .Lds_descriptor_one
 add x25,x25,#1
 cmp x25,#3
 b.lo .Lds_sppt_record_next
 mov x25,#0
.Lds_sppt_grid_next:
 add x9,x24,#160
 add x9,x9,x25,lsl#6
 ldr x0,[x9]
 mov x1,x20
 bl .Lds_initialize_empty_grid
 cbnz w0,.Lds_sppt_allocation_failed
 add x25,x25,#1
 cmp x25,#3
 b.lo .Lds_sppt_grid_next
 ldr x0,[sp,#136]
 bl free
 str xzr,[sp,#136]
 mov w28,#0
 b .Lds_sppt_return
.Lds_sppt_allocation_failed:
 mov x25,#0
.Lds_sppt_cleanup_next:
 DS_CONST x24,4270800
 add x24,x19,x24
 add x9,x24,#160
 add x9,x9,x25,lsl#6
 ldr x0,[x9]
 bl .Lds_release_grid
 add x9,x24,#160
 add x9,x9,x25,lsl#6
 str xzr,[x9]
 add x25,x25,#1
 cmp x25,#3
 b.lo .Lds_sppt_cleanup_next
 ldr x0,[sp,#136]
 cbz x0,.Lds_sppt_no_temporary
 bl free
 str xzr,[sp,#136]
.Lds_sppt_no_temporary:
 mov w28,#1
 b .Lds_sppt_return
.Lds_sppt_bad_frame:
 mov w28,#2
.Lds_sppt_return:
 ldr x9,[sp,#120]
 ldr w10,[sp,#128]
 str w10,[x9]
 ldr x9,[sp,#104]
 ldr x10,[sp,#112]
 msr fpcr,x9
 msr fpsr,x10
 mov w0,w28
 ldr x18,[sp,#96]
 ldp x27,x28,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#256
 ret
.Lds_sppt_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_disabled_sppt_setup,.-md2asm_initialize_disabled_sppt_setup
/* Public GET_SPP_CONF boundary: MODEL/cap,text/bytes; frame96. */
.p2align 4
.global md2asm_initialize_disabled_spp_configuration
.type md2asm_initialize_disabled_spp_configuration,%function
md2asm_initialize_disabled_spp_configuration:
 mrs x4,fpcr
 cbnz x4,.Lds_spp_bad_leaf
 cbz x0,.Lds_spp_bad_leaf
 cbz x2,.Lds_spp_bad_leaf
 tst x0,#7
 b.ne .Lds_spp_bad_leaf
 DS_CONST x4,4275088
 cmp x1,x4
 b.lo .Lds_spp_bad_leaf
 adds x5,x0,x4
 b.cs .Lds_spp_bad_leaf
 cbz x3,.Lds_spp_bad_leaf
 cmp x3,#64,lsl#12
 b.hi .Lds_spp_bad_leaf
 adds x6,x2,x3
 b.cs .Lds_spp_bad_leaf
 DS_APART x0,x5,x2,x6,.Lds_spp_bad_leaf
 DS_CONST x7,1552928
 add x7,x0,x7
 ldr x8,[x7,#80]
 ldr x9,[x7,#144]
 orr x8,x8,x9
 ldr x9,[x7,#224]
 orr x8,x8,x9
 ldr x9,[x7,#288]
 orr x8,x8,x9
 ldr x9,[x7,#352]
 orr x8,x8,x9
 cbnz x8,.Lds_spp_bad_leaf
 stp x29,x30,[sp,#-96]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mov x19,x0
 mov x20,x2
 mov x21,x3
 mov x0,x20
 mov x1,x21
 adrp x2,.Lds_namspp
 add x2,x2,:lo12:.Lds_namspp
 mov x3,#6
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lds_spp_return
 DS_CONST x0,1552928
 add x0,x19,x0
 bl .Lds_spp_defined_stores
 mov w0,#0
.Lds_spp_return:
 ldp x23,x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#96
 ret
.Lds_spp_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_disabled_spp_configuration,.-md2asm_initialize_disabled_spp_configuration
/* Caller retirement of the actual three owned grids; no payload read.
 * Own frame128, private grid release32, maximum160 bytes.
 */
.p2align 4
.global md2asm_release_disabled_sppt_setup
.type md2asm_release_disabled_sppt_setup,%function
md2asm_release_disabled_sppt_setup:
 mrs x2,fpcr
 cbnz x2,.Lds_retire_bad
 cbz x0,.Lds_retire_bad
 tst x0,#7
 b.ne .Lds_retire_bad
 DS_CONST x2,4275088
 cmp x1,x2
 b.lo .Lds_retire_bad
 adds x3,x0,x2
 b.cs .Lds_retire_bad
 DS_CONST x2,1535608
 ldr w3,[x0,x2]
 cbnz w3,.Lds_retire_bad
 stp x29,x30,[sp,#-128]!
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x18,[sp,#48]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#64]
 mov x19,x0
 bl __errno_location
 mov x20,x0
 ldr w21,[x20]
 mov x22,#0
.Lds_retire_next:
 DS_CONST x9,4270960
 add x9,x19,x9
 add x9,x9,x22,lsl#6
 ldr x0,[x9]
 bl .Lds_release_grid
 DS_CONST x9,4270960
 add x9,x19,x9
 add x9,x9,x22,lsl#6
 str xzr,[x9]
 add x22,x22,#1
 cmp x22,#3
 b.lo .Lds_retire_next
 str w21,[x20]
 ldp x9,x10,[sp,#64]
 msr fpcr,x9
 msr fpsr,x10
 ldp x23,x18,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#128
 mov w0,#0
 ret
.Lds_retire_bad:
 mov w0,#2
 ret
.size md2asm_release_disabled_sppt_setup,.-md2asm_release_disabled_sppt_setup
.section .rodata
.p2align 3
.Lds_owned_offsets: .word 280,472,0,136
.Lds_grid_pointer_offsets: .word 0,136,280,344,408,472,536,600,664,776,888,1000,1112,1224,1336,1448,1536,1672
.Lds_namspsdt: .ascii "NAMSPSDT"
.Lds_namspp: .ascii "NAMSPP"
.p2align 3
.Lds_sdev:
.rept 6
 .quad 0x3fdae147ae147ae1,0x3fc1eb851eb851ec,0x3fa89374bc6a7efa,0x3fa999999999999a,0x3f9999999999999a
.endr
.Lds_tau: .double 21600.0,259200.0,2592000.0,7776000.0,31536000.0
.Lds_xlcor: .double 500000.0,1000000.0,2000000.0,2000000.0,2000000.0
.Lds_clip_ratio:
.rept 6
 .quad 0x3ffccccccccccccd
.endr
.Lds_clip_max:
.rept 6
 .quad 0x3ff0000000000000
.endr
.Lds_20000: .quad 0x40d3880000000000
.Lds_095: .quad 0x3fee666666666666
.Lds_1: .quad 0x3ff0000000000000
.Lds_5000: .quad 0x40b3880000000000
.Lds_10000: .quad 0x40c3880000000000
.Lds_08: .quad 0x3fe999999999999a
.Lds_spectrum_shape:
 .ascii "WeaverCourtier"
 .fill 114,1,32
.Lds_spp_read_name:
 .ascii "spp_pattern_0"
 .fill 243,1,32
.Lds_spp_write_name:
 .ascii "spp_pattern_out"
 .fill 241,1,32
.section .note.GNU-stack,"",%progbits

/* Fixed original surface request and destination metadata in direct assembly.
 * Seven pointers: geometry, surface, physics, coupling, config2304, owners80, params208.
 * Original GNU12 objects and true contiguous descriptors are caller inputs.
 * Every constant and table is read from its live source object. No field arithmetic.
 * 800-byte aligned frame preserves x18, saved integers and all vector registers.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_surface_initial_context_direct_
.type md2asm_surface_initial_context_direct_,%function
md2asm_surface_initial_context_direct_:
 sub sp,sp,#800
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x23,x4
 mov x24,x5
 mov x25,x6
 mov x8,#7376
 add x0,x19,x8
 mov x1,x22
 mov x2,x21
 mov x3,x23
 bl md2asm_surface_config_words_direct_
 ldr x8,[x23]
 cbnz x8,.Lreturn
 mov x8,#2
 str x8,[x23]
 stp xzr,xzr,[x24]
 stp xzr,xzr,[x24,#16]
 stp xzr,xzr,[x24,#32]
 stp xzr,xzr,[x24,#48]
 stp xzr,xzr,[x24,#64]
 mov x8,x25
 mov x9,#13
.Lclear_params:
 stp xzr,xzr,[x8],#16
 subs x9,x9,#1
 b.ne .Lclear_params
 mov x0,x19
 mov x1,x20
 add x2,sp,#112
 bl md2asm_surface_owner_words_direct_
 ldr x8,[sp,#112]
 cbnz x8,.Lreturn
 ldr x8,[sp,#152]
 cbnz x8,.Lreturn
 ldr x8,[sp,#160]
 cbz x8,.Ltrajectory_ok
 ldr x8,[sp,#144]
 cmp x8,#131
 b.eq .Lreturn
.Ltrajectory_ok:
 add x8,sp,#240
 mov x9,x24
 mov x10,#5
.Lcopy_owners:
 ldp x11,x12,[x8],#16
 stp x11,x12,[x9],#16
 subs x10,x10,#1
 b.ne .Lcopy_owners
 str xzr,[sp,#624]
 str xzr,[sp,#632]
 str xzr,[sp,#640]
 str xzr,[sp,#648]
 adrp x26,.Lrequest_groups
 add x26,x26,:lo12:.Lrequest_groups
 mov x27,#33
.Lrequest_group:
 ldr w8,[x26]
 add x8,x20,x8
 ldr w9,[x8,#4]
 cmp w9,#0
 b.le .Lnext_request_group
 ldrsw x9,[x8]
 cmp x9,#0
 b.lt .Lreturn
 str x9,[sp,#656]
 ldrsw x10,[x8,#8]
 str x10,[sp,#664]
 ldr w11,[x26,#8]
 str x11,[sp,#672]
 ldrsw x12,[x26,#12]
 str x12,[sp,#688]
 cmp x11,#2
 b.eq .Lrequest_level_shape_ready
 cmp x11,#4
 b.ne .Lordinary_layered_shape
 cmp x10,#5
 b.ne .Lreturn
 b .Lrequest_level_shape_ready
.Lordinary_layered_shape:
 cmp x10,#0
 b.lt .Lreturn
 cmp x10,#4096
 b.hi .Lreturn
 cmp x12,#0
 b.ne .Lrequest_level_shape_ready
 cmp x10,#4
 b.ne .Lreturn
.Lrequest_level_shape_ready:
 ldr w8,[x26,#4]
 add x8,x20,x8
 ldr x28,[x8]
 cbz x28,.Lreturn
 ldr x10,[x8,#40]
 cmp x10,#1
 b.ne .Lreturn
 ldp x10,x11,[x8,#48]
 sub x11,x11,x10
 add x11,x11,#1
 cmp x9,x11
 b.gt .Lreturn
 ldrb w10,[x8,#28]
 cmp w10,#1
 b.ne .Lreturn
 ldr x10,[sp,#672]
 mov x11,#64
 cmp x10,#2
 b.eq .Lrequest_meta_size
 mov x11,#288
.Lrequest_meta_size:
 ldr x10,[x8,#16]
 cmp x10,x11
 b.ne .Lreturn
 str x11,[sp,#696]
 str xzr,[sp,#680]
 cbz x9,.Lnext_request_group
.Lrequest_field:
 ldr x8,[sp,#672]
 cmp x8,#2
 b.ne .Lrequest_layered
 // Source 2D destination checks include unrequested known codes.
 ldr x1,[sp,#688]
 cmn x1,#2
 b.eq .Lrequest_2d_flag
 ldr w0,[x28,#28]
 ldr x2,[sp,#680]
 add x3,sp,#624
 adrp x4,.Lposition_2d
 add x4,x4,:lo12:.Lposition_2d
 mov x5,#47
 bl .Lcheck_position
 cbnz w0,.Lreturn
.Lrequest_2d_flag:
 ldr w8,[x28,#56]
 cmp w8,#1
 b.ne .Lnext_request_field
 ldr w0,[x28,#28]
 bl .Lappend_parameter_2d
 cbnz w0,.Lreturn
 b .Lnext_request_field
.Lrequest_layered:
 // A snow request consumes only the first stored layer identifier and flag.
 ldr x8,[sp,#672]
 ldr x12,[sp,#664]
 cmp x8,#4
 b.ne .Lrequest_count_ready
 mov x12,#1
.Lrequest_count_ready:
 str x12,[sp,#728]
 add x8,x28,#224
 ldr x9,[x8]
 cbz x9,.Lreturn
 ldr x10,[x8,#16]
 cmp x10,#4
 b.ne .Lreturn
 ldr x10,[x8,#40]
 cmp x10,#1
 b.ne .Lreturn
 ldp x10,x11,[x8,#48]
 cmp x10,#1
 b.gt .Lreturn
 cmp x11,x12
 b.lt .Lreturn
 sub x10,x10,#1
 sub x9,x9,x10,lsl#2
 str x9,[sp,#712]
 add x8,x28,#32
 ldr x9,[x8]
 cbz x9,.Lreturn
 ldr x10,[x8,#16]
 cmp x10,#4
 b.ne .Lreturn
 ldr x10,[x8,#40]
 cmp x10,#1
 b.ne .Lreturn
 ldp x10,x11,[x8,#48]
 cmp x10,#1
 b.gt .Lreturn
 cmp x11,x12
 b.lt .Lreturn
 sub x10,x10,#1
 sub x9,x9,x10,lsl#2
 str x9,[sp,#720]
 str xzr,[sp,#704]
 cbz x12,.Lnext_request_field
.Lrequest_level:
 ldr x8,[sp,#672]
 cmp x8,#4
 b.eq .Lrequest_snow
 ldr x1,[sp,#688]
 cmn x1,#2
 b.eq .Lrequest_layered_flag
 ldr x8,[sp,#720]
 ldr x9,[sp,#704]
 ldr w0,[x8,x9,lsl#2]
 ldr x2,[sp,#680]
 ldr x10,[sp,#664]
 madd x2,x2,x10,x9
 add x3,sp,#624
 adrp x4,.Lposition_2d
 add x4,x4,:lo12:.Lposition_2d
 mov x5,#47
 bl .Lcheck_position
 cbnz w0,.Lreturn
.Lrequest_layered_flag:
 ldr x8,[sp,#712]
 ldr x9,[sp,#704]
 ldr w10,[x8,x9,lsl#2]
 cmp w10,#1
 b.ne .Lnext_request_level
 ldr x8,[sp,#720]
 ldr w0,[x8,x9,lsl#2]
 bl .Lappend_parameter_2d
 cbnz w0,.Lreturn
 b .Lnext_request_level
.Lrequest_snow:
 ldr x8,[sp,#720]
 ldr w0,[x8]
 mov x1,#2
 ldr x2,[sp,#680]
 add x3,sp,#632
 adrp x4,.Lposition_snow
 add x4,x4,:lo12:.Lposition_snow
 mov x5,#5
 bl .Lcheck_position
 cbnz w0,.Lreturn
 ldr x8,[sp,#712]
 ldr w8,[x8]
 cmp w8,#1
 b.ne .Lnext_request_level
 ldr x8,[sp,#648]
 cmp x8,#5
 b.hs .Lreturn
 add x9,x25,#188
 ldr x10,[sp,#720]
 ldr w10,[x10]
 str w10,[x9,x8,lsl#2]
 add x8,x8,#1
 str x8,[sp,#648]
.Lnext_request_level:
 ldr x8,[sp,#704]
 add x8,x8,#1
 str x8,[sp,#704]
 ldr x9,[sp,#728]
 cmp x8,x9
 b.ne .Lrequest_level
.Lnext_request_field:
 ldr x8,[sp,#696]
 add x28,x28,x8
 ldr x8,[sp,#680]
 add x8,x8,#1
 str x8,[sp,#680]
 ldr x9,[sp,#656]
 cmp x8,x9
 b.ne .Lrequest_field
.Lnext_request_group:
 add x26,x26,#16
 subs x27,x27,#1
 b.ne .Lrequest_group
 ldr x8,[sp,#640]
 ldr x9,[sp,#648]
 cmp x8,#47
 b.ne .Lreturn
 cmp x9,#5
 b.ne .Lreturn
 adrp x8,.Lexpected_parameters
 add x8,x8,:lo12:.Lexpected_parameters
 mov x9,#0
.Lexpected_parameter:
 ldr w10,[x25,x9,lsl#2]
 ldr w11,[x8,x9,lsl#2]
 cmp w10,w11
 b.ne .Lreturn
 add x9,x9,#1
 cmp x9,#52
 b.ne .Lexpected_parameter
 ldr x8,[sp,#624]
 ldr x9,[sp,#632]
 mov x10,#0x7fffffffffff
 cmp x8,x10
 b.ne .Lreturn
 cmp x9,#31
 b.ne .Lreturn
 str xzr,[x23]
.Lreturn:
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#800
 ret
// These private integer helpers share the current frame and return 0 or 1.
.Lappend_parameter_2d:
 ldr x8,[sp,#640]
 cmp x8,#47
 b.hs .Lhelper_bad
 str w0,[x25,x8,lsl#2]
 add x8,x8,#1
 str x8,[sp,#640]
 mov w0,#0
 ret
.Lcheck_position:
 mov x6,#0
.Lposition_search:
 add x7,x6,x6,lsl#1
 add x7,x4,x7,lsl#2
 ldr w8,[x7]
 cmp w0,w8
 b.eq .Lposition_found
 add x6,x6,#1
 cmp x6,x5
 b.ne .Lposition_search
 mov w0,#0
 ret
.Lposition_found:
 ldrsw x8,[x7,#4]
 cmp x1,x8
 b.ne .Lhelper_bad
 ldr w8,[x7,#8]
 cmp x2,x8
 b.ne .Lhelper_bad
 mov x8,#1
 lsl x8,x8,x6
 ldr x9,[x3]
 tst x9,x8
 b.ne .Lhelper_bad
 orr x9,x9,x8
 str x9,[x3]
 mov w0,#0
 ret
.Lhelper_bad:
 mov w0,#1
 ret
.size md2asm_surface_initial_context_direct_,.-md2asm_surface_initial_context_direct_
.section .rodata
.p2align 3
.Lexpected_parameters:
 .word 139,170,183,236,39,40,41,42,35,36,37,38,228008,228009,228010,228011,228012,228013,228014,235,198,173,174,160,172,161,162,163,234,27,129172,28,200199,29,30,66,67,43,26,228007,31,34,74,15,16,17,18,228141,32,33,238,228038
.Lposition_2d:
 .word 139,0,0
 .word 170,0,1
 .word 183,0,2
 .word 236,0,3
 .word 39,0,4
 .word 40,0,5
 .word 41,0,6
 .word 42,0,7
 .word 35,0,8
 .word 36,0,9
 .word 37,0,10
 .word 38,0,11
 .word 228008,1,0
 .word 228009,1,1
 .word 228010,1,2
 .word 228011,1,3
 .word 228012,1,4
 .word 228013,1,5
 .word 228014,1,6
 .word 235,3,0
 .word 198,3,1
 .word 173,4,0
 .word 174,4,1
 .word 160,4,3
 .word 172,4,4
 .word 161,4,5
 .word 162,4,6
 .word 163,4,7
 .word 234,4,8
 .word 27,4,9
 .word 129172,4,10
 .word 28,4,11
 .word 200199,4,12
 .word 29,4,14
 .word 30,4,15
 .word 66,4,16
 .word 67,4,17
 .word 43,4,18
 .word 26,4,19
 .word 228007,4,20
 .word 31,4,21
 .word 34,4,22
 .word 74,4,25
 .word 15,4,26
 .word 16,4,27
 .word 17,4,28
 .word 18,4,29
.Lposition_snow:
 .word 228141,2,0
 .word 32,2,1
 .word 33,2,2
 .word 238,2,3
 .word 228038,2,4
.Lrequest_groups:
 .word 5880,5968,3,0 // SP_SB
 .word 6168,6272,4,2 // SP_SG
 .word 6448,6568,2,1 // SP_SL
 .word 6744,6848,2,3 // SP_RR
 .word 7024,7136,2,-2 // SP_CL
 .word 7336,7432,3,-2 // SP_OM
 .word 7632,7696,3,-2 // SP_EP
 .word 7872,7936,2,-2 // SP_X2
 .word 8896,9792,2,4 // SD_VF
 .word 9968,10048,2,-1 // SD_VP
 .word 10224,10368,2,-2 // SD_VV
 .word 10544,10648,2,-2 // SD_VN
 .word 10824,10936,2,-2 // SD_VH
 .word 11152,11224,2,-2 // SD_VK
 .word 11400,11512,2,-2 // SD_VA
 .word 11688,11776,2,-2 // SD_VC
 .word 11952,12040,2,-2 // SD_V2
 .word 12240,12424,3,-2 // SD_V3
 .word 18000,18152,2,-2 // SD_OC
 .word 12600,14704,2,-2 // SD_VD
 .word 14992,15072,3,-2 // SD_SM
 .word 15248,15312,2,-1 // SD_WS
 .word 15560,15624,2,-1 // SD_WW
 .word 15864,16040,2,-2 // SD_VX
 .word 16240,16304,3,-2 // SD_XA
 .word 16776,16840,3,-2 // SD_XR
 .word 16504,16568,3,-2 // SD_DI
 .word 17016,17080,2,-2 // SD_X2
 .word 17256,17320,2,-2 // SD_SFL
 .word 17496,17560,2,-2 // SD_SFO
 .word 17760,17824,3,-2 // SD_PF
 .word 8376,8448,3,-2 // SD_XP
 .word 8648,8720,3,-2 // SD_XP2
.section .note.GNU-stack,"",%progbits

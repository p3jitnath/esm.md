/* Original ten-pointer output request preparation, selected ECMWF route.
 * Contract: skills/md2asm/references/openifs/output/output_request_preparation.md.
 * x0 F,x1 Geometry,x2 Model,x3 KTIME*,x4 KLAG*,x5 delay*,x6 ocean*,x7 P.
 * Entry stack+0 PHY,stack+8 DYN. All requests are built from live fort.4.
 */
.arch armv8.2-a
.text
.macro prep_data reg,symbol
 adrp \reg,:got:\symbol
 ldr \reg,[\reg,:got_lo12:\symbol]
.endm
.p2align 4
.global md2asm_fullpos_request_prepare_direct
.global md2asm_fullpos_request_prepare_
.type md2asm_fullpos_request_prepare_direct,%function
md2asm_fullpos_request_prepare_direct:
md2asm_fullpos_request_prepare_:
 sub sp,sp,#256
 stp x29,x30,[sp]
 mov x29,sp
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 stp x0,x1,[sp,#104]
 stp x2,x3,[sp,#120]
 stp x4,x5,[sp,#136]
 stp x6,x7,[sp,#152]
 mrs x9,fpcr
 mrs x10,fpsr
 stp x9,x10,[sp,#168]
 ldp x9,x10,[sp,#256]
 stp x9,x10,[sp,#200]
 bl __errno_location
 str x0,[sp,#184]
 ldr w9,[x0]
 str w9,[sp,#192]
 ldp x19,x20,[sp,#104]
 ldr x21,[sp,#160]
 ldp x22,x23,[sp,#200]
 sub sp,sp,#1,lsl#12
 sub sp,sp,#1600
 /* Source INTENT(OUT) cleanup precedes construction and selected-path guards. */
 mov x0,x21
 adrp x1,.Lprep_field_descriptors
 add x1,x1,:lo12:.Lprep_field_descriptors
 mov x2,#21
 bl .Lprep_release_descriptors
 mov x0,x22
 adrp x1,.Lprep_physical_descriptors
 add x1,x1,:lo12:.Lprep_physical_descriptors
 mov x2,#11
 bl .Lprep_release_descriptors
 mov x0,x23
 adrp x1,.Lprep_dynamic_descriptors
 add x1,x1,:lo12:.Lprep_dynamic_descriptors
 mov x2,#45
 bl .Lprep_release_descriptors
 mov x0,x21
 mov x1,#1424
 bl .Lprep_zero_record
 mov x0,x22
 mov x1,#744
 bl .Lprep_zero_record
 mov x0,x23
 mov x1,#3696
 bl .Lprep_zero_record
 /* The chosen source branch reads NAMFPC directly, with no control file. */
 ldr w9,[x19]
 cbnz w9,.Lprep_native_fail
 ldr w9,[x19,#4]
 cbnz w9,.Lprep_native_fail
 mov x9,#192
.Lprep_blank_control_name:
 ldrb w10,[x19,x9]
 cmp w10,#32
 b.ne .Lprep_native_fail
 add x9,x9,#1
 cmp x9,#372
 b.lo .Lprep_blank_control_name
 prep_data x9,__yomct0_MOD_lecmwf
 ldr w9,[x9]
 cmp w9,#1
 b.ne .Lprep_native_fail
 prep_data x9,__yomct0_MOD_larpegef
 ldr w9,[x9]
 cbnz w9,.Lprep_native_fail
 prep_data x9,__yomct0_MOD_lelam
 ldr w9,[x9]
 cbnz w9,.Lprep_native_fail
 mov x9,#5224
 ldr w24,[x20,x9]
 cmp w24,#1
 b.lo .Lprep_native_fail
 cmp w24,#64
 b.hi .Lprep_native_fail
 /* One genuine contiguous output domain; no domain-name value is constructed. */
 add x9,x19,#504
 ldr x10,[x9]
 cbz x10,.Lprep_native_fail
 ldr x10,[x9,#16]
 cmp x10,#472
 b.ne .Lprep_native_fail
 ldrb w10,[x9,#28]
 cmp w10,#1
 b.ne .Lprep_native_fail
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Lprep_native_fail
 ldp x10,x11,[x9,#48]
 sub x11,x11,x10
 cbnz x11,.Lprep_native_fail
 /* SUFPFIELDS checks only the live VBH upper bound on this selected route. */
 add x9,x19,#2792
 ldr x10,[x9]
 cbz x10,.Lprep_native_fail
 ldr x10,[x9,#16]
 cmp x10,#8
 b.ne .Lprep_native_fail
 ldrb w10,[x9,#28]
 cmp w10,#1
 b.ne .Lprep_native_fail
 ldr x10,[x9,#56]
 cmp x10,x24
 b.lt .Lprep_native_fail
 /* The four common SUFPC metadata assignments remain live source writes. */
 prep_data x9,__yomfpc_MOD_ltracefp
 str wzr,[x9]
 prep_data x9,__yomct0_MOD_nfpos
 ldr w10,[x9]
 prep_data x9,__yomarg_MOD_ngribfile
 ldr w11,[x9]
 cmp w10,#0
 cset w10,ne
 cmp w11,#0
 cset w11,eq
 and w10,w10,w11
 prep_data x9,__yomfpc_MOD_lfppacking
 str w10,[x9]
 prep_data x9,__yomfpc_MOD_locedelay
 mov w10,#1
 str w10,[x9]
 prep_data x9,__yomfpc_MOD_rwidom
 mov x10,#0x7fefffffffffffff
 str x10,[x9]
 /* Read a fresh file descriptor so no Fortran unit or I/O service is called. */
 mov x0,#262144
 add x0,x0,#1
 bl malloc
 cbz x0,.Lprep_native_fail
 mov x25,x0
 mov x0,#-100
 adr x1,.Lprep_fort4
 mov x2,#0
 mov x3,#0
 mov x8,#56
 svc #0
 cmp x0,#0
 b.lt .Lprep_native_fail
 mov x27,x0
 mov x26,#0
.Lprep_read:
 mov x0,x27
 add x1,x25,x26
 mov x2,#262144
 add x2,x2,#1
 sub x2,x2,x26
 mov x8,#63
 svc #0
 cmn x0,#4
 b.eq .Lprep_read
 cmp x0,#0
 b.lt .Lprep_native_fail
 cbz x0,.Lprep_read_done
 add x26,x26,x0
 cmp x26,#64,lsl#12
 b.hi .Lprep_native_fail
 b .Lprep_read
.Lprep_read_done:
 mov x0,x27
 mov x8,#57
 svc #0
 cmp x0,#0
 b.lt .Lprep_native_fail
 mov x0,x25
 mov x1,x26
 mov x2,sp
 bl md2asm_parse_output_namfpc
 mov w28,w0
 mov x0,x25
 bl free
 cbnz w28,.Lprep_native_fail
 /* Source writes all model levels for-99, so a zero-sized field owner is invalid. */
 ldr w9,[sp]
 cbnz w9,.Lprep_model_marker_valid
 ldr w9,[sp,#2368]
 cmn w9,#99
 b.eq .Lprep_native_fail
.Lprep_model_marker_valid:
 /* This caller admits model/pressure/surface requests; other families remain raw-child scope. */
 ldp x9,x10,[sp,#8]
 orr x9,x9,x10
 cbnz x9,.Lprep_native_fail
 ldr w9,[sp,#24]
 cbnz w9,.Lprep_native_fail
 mov x0,sp
 mov w1,w24
 mov x2,x21
 bl md2asm_initialize_output_field_requests
 /* Selected physical pressure output is from zero through100000Pa. */
 ldr w9,[x21,#1344]
 ldr x10,[x21,#896]
 movz x11,#34464
 movk x11,#1,lsl#16
 scvtf d1,x11
 mov x12,#0
.Lprep_pressure_bound:
 cmp x12,x9
 b.hs .Lprep_pressure_ready
 ldr d0,[x10,x12,lsl#3]
 fcmp d0,d1
 b.gt .Lprep_native_fail
 add x12,x12,#1
 b .Lprep_pressure_bound
.Lprep_pressure_ready:
 /* Empty NFPPHY/CFU/XFU selects the declared unallocated physical request. */
 mov x0,x19
 mov x1,x21
 mov x2,x23
 bl md2asm_initialize_output_dynamic_requests
 adrp x9,.Lprep_completed_count
 add x9,x9,:lo12:.Lprep_completed_count
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldr x9,[x29,#184]
 /* Original successful external NAMFPC reading returns errno zero. */
 str wzr,[x9]
 ldp x9,x10,[x29,#168]
 msr fpcr,x9
 msr fpsr,x10
 mov sp,x29
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#256
 ret
.size md2asm_fullpos_request_prepare_direct,.-md2asm_fullpos_request_prepare_direct
/* Private table cleanup, retaining complete allocated descriptor words. */
.Lprep_release_descriptors:
 sub sp,sp,#64
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 str x18,[sp,#48]
 mov x19,x0
 mov x20,x1
 mov x21,x2
.Lprep_release_next:
 ldr w9,[x20],#4
 add x22,x19,w9,uxtw
 ldr x0,[x22]
 cbz x0,.Lprep_release_skip
 bl free
 str xzr,[x22]
.Lprep_release_skip:
 subs x21,x21,#1
 b.ne .Lprep_release_next
 ldr x18,[sp,#48]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.Lprep_zero_record:
 mov x9,#0
.Lprep_zero_loop:
 str xzr,[x0,x9]
 add x9,x9,#8
 cmp x9,x1
 b.lo .Lprep_zero_loop
 ret
.p2align 4
.global md2asm_output_request_preparation_count_get
.type md2asm_output_request_preparation_count_get,%function
md2asm_output_request_preparation_count_get:
 adrp x9,.Lprep_completed_count
 ldr x0,[x9,:lo12:.Lprep_completed_count]
 ret
.size md2asm_output_request_preparation_count_get,.-md2asm_output_request_preparation_count_get
.Lprep_native_fail:
 mov x0,#116
 mov x8,#94
 svc #0
 brk #0
.section .rodata
.p2align 3
.Lprep_field_descriptors:
 .word 0,64,128,192,256,320,384,448,512,576,640,704,768,832,896,960,1024,1088,1152,1216,1280
.Lprep_physical_descriptors:
 .word 8,72,136,200,264,328,392,456,520,616,680
.Lprep_dynamic_descriptors:
 .word 16,80,144,208,296,384,512,576,640,704,792,880,1008,1072,1136,1200,1288,1376,1504,1568,1632,1696,1784,1872,2000,2064,2128,2192,2280,2368,2496,2560,2624,2688,2776,2864,2992,3056,3120,3184,3272,3360,3480,3544,3608
.Lprep_fort4: .asciz "fort.4"
.bss
.p2align 3
.Lprep_completed_count: .zero 8
.section .note.GNU-stack,"",%progbits

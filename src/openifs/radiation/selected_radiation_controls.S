// Selected source control stage before SUECRAD SURDI.
// Contract: skills/md2asm/references/openifs/radiation/radiation_control_setup.md.
// x0 records112,x1 text,x2 bytes,x3 constants520,x4 upstream112.
// Each output address/capacity pair describes a complete disjoint buffer.
// Return0 success,1 allocation failure,2 atomic input rejection. FPCR0.
.text
.p2align 4
.global md2asm_initialize_selected_radiation_controls
.type md2asm_initialize_selected_radiation_controls,%function
md2asm_initialize_selected_radiation_controls:
    cbz x0,.Lrad_bad_leaf
    cbz x1,.Lrad_bad_leaf
    cbz x2,.Lrad_bad_leaf
    cbz x3,.Lrad_bad_leaf
    cbz x4,.Lrad_bad_leaf
    cmp x2,#64,lsl #12
    b.hi .Lrad_bad_leaf
    orr x9,x0,x3
    orr x9,x9,x4
    tst x9,#7
    b.ne .Lrad_bad_leaf
    adds x9,x0,#112
    b.cs .Lrad_bad_leaf
    mrs x9,fpcr
    cbnz x9,.Lrad_bad_leaf
    sub sp,sp,#1,lsl #12
    sub sp,sp,#2048
    stp x29,x30,[sp]
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x18,[sp,#96]
    mov x29,sp
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,x3
    mov x23,x4
    add x24,sp,#512
    add x25,sp,#2560
    add x26,sp,#1,lsl #12
    add x26,x26,#1152
// Build eleven start/end pairs: seven outputs and four input ranges.
    adrp x9,.Lrad_output_sizes
    add x9,x9,:lo12:.Lrad_output_sizes
    add x10,sp,#256
    mov x11,#0
.Lrad_output_ranges:
    add x12,x19,x11,lsl #4
    ldp x13,x14,[x12]
    cbz x13,.Lrad_bad_frame
    tst x13,#7
    b.ne .Lrad_bad_frame
    ldr x15,[x9,x11,lsl #3]
    cmp x14,x15
    b.lo .Lrad_bad_frame
    adds x14,x13,x15
    b.cs .Lrad_bad_frame
    stp x13,x14,[x10],#16
    str x13,[x26]
    add x26,x26,#16
    add x11,x11,#1
    cmp x11,#7
    b.lo .Lrad_output_ranges
    sub x26,x26,#112
    add x13,x19,#112
    stp x19,x13,[x10],#16
    adds x13,x20,x21
    b.cs .Lrad_bad_frame
    stp x20,x13,[x10],#16
    adds x13,x22,#520
    b.cs .Lrad_bad_frame
    stp x22,x13,[x10],#16
    adds x13,x23,#112
    b.cs .Lrad_bad_frame
    stp x23,x13,[x10]
    add x9,sp,#256
    mov x10,#0
.Lrad_overlap_output:
    ldp x11,x12,[x9]
    add x13,sp,#256
    mov x14,#0
.Lrad_overlap_other:
    cmp x10,x14
    b.eq .Lrad_overlap_next
    ldp x15,x16,[x13]
    cmp x11,x16
    b.hs .Lrad_overlap_next
    cmp x15,x12
    b.lo .Lrad_bad_frame
.Lrad_overlap_next:
    add x13,x13,#16
    add x14,x14,#1
    cmp x14,#11
    b.lo .Lrad_overlap_other
    add x9,x9,#16
    add x10,x10,#1
    cmp x10,#7
    b.lo .Lrad_overlap_output
// Validate the exact selected upstream branch and bounded live timestep.
    adrp x9,.Lrad_upstream_words
    add x9,x9,:lo12:.Lrad_upstream_words
    mov x10,#0
.Lrad_upstream_check:
    cmp x10,#4
    b.eq .Lrad_ozone_check
    ldr w11,[x23,x10,lsl #2]
    ldr w12,[x9,x10,lsl #2]
    cmp w11,w12
    b.ne .Lrad_bad_frame
    b .Lrad_upstream_next
.Lrad_ozone_check:
    ldr w11,[x23,#16]
    cmp w11,#1
    b.hi .Lrad_bad_frame
.Lrad_upstream_next:
    add x10,x10,#1
    cmp x10,#22
    b.lo .Lrad_upstream_check
    ldr x10,[x23,#88]
    adrp x9,.Lrad_timesteps
    add x9,x9,:lo12:.Lrad_timesteps
    mov x11,#0
.Lrad_timestep_check:
    ldr x12,[x9,x11,lsl #3]
    cmp x10,x12
    b.eq .Lrad_timestep_ok
    add x11,x11,#1
    cmp x11,#4
    b.lo .Lrad_timestep_check
    b .Lrad_bad_frame
.Lrad_timestep_ok:
    ldp x9,x10,[x23,#96]
    orr x9,x9,x10
    cbnz x9,.Lrad_bad_frame
// Earlier SUALLO aerosol owners remain live and unchanged; only Planck bases are fresh.
    ldr x9,[x19]
    ldr x12,[x9,#1824]
    cbnz x12,.Lrad_bad_frame
    ldr x12,[x9,#1912]
    cbnz x12,.Lrad_bad_frame
    ldr x12,[x9,#1976]
    cbnz x12,.Lrad_bad_frame
// Validate positive finite inputs consumed by Planck and visibility.
    adrp x9,.Lrad_constant_offsets
    add x9,x9,:lo12:.Lrad_constant_offsets
    mov x10,#0
.Lrad_constant_check:
    ldr w11,[x9,x10,lsl #2]
    ldr x12,[x22,x11]
    cbz x12,.Lrad_bad_frame
    tbnz x12,#63,.Lrad_bad_frame
    lsr x13,x12,#52
    cmp x13,#2047
    b.eq .Lrad_bad_frame
    add x10,x10,#1
    cmp x10,#6
    b.lo .Lrad_constant_check
    bl __errno_location
    str x0,[sp,#104]
    ldr w9,[x0]
    str w9,[sp,#112]
// Climate selection and the second source read share the accepted parser.
    ldr w9,[x23,#8]
    str w9,[sp,#5200]
    ldr w9,[x23,#4]
    str w9,[sp,#5204]
    ldr w9,[x23,#12]
    str w9,[sp,#5208]
    ldr w9,[x23,#16]
    str w9,[sp,#5212]
    ldr w9,[x23,#20]
    str w9,[sp,#5216]
    str wzr,[sp,#5220]
    mov x0,x20
    mov x1,x21
    mov x2,x25
    mov x3,#2640
    add x4,sp,#1,lsl #12
    add x4,x4,#1104
    bl md2asm_select_radiation_climate_files
    cbnz w0,.Lrad_bad_restore
    mov w9,#-8
    str w9,[x25,#24]
    mov x0,x20
    mov x1,x21
    mov x2,x25
    bl md2asm_apply_selected_radiation_namelist
    cbnz w0,.Lrad_bad_restore
    ldr w9,[x25,#24]
    cbz w9,.Lrad_nrproma_ok
    cmn w9,#8
    b.ne .Lrad_bad_restore
.Lrad_nrproma_ok:
    mov w9,#8
    str w9,[x25,#24]
// Private source records allow allocation failure without output mutation.
    mov x0,x24
    ldr x1,[x19]
    mov x2,#2040
    bl memcpy
    add x27,sp,#1,lsl #12
    add x27,x27,#1280
    mov x0,x27
    ldr x1,[x19,#16]
    mov x2,#176
    bl memcpy
    str x24,[x26]
    str x27,[x26,#16]
    mov x0,x26
    mov w1,#2
    bl .Lrad_apply_literals
    mov x0,x24
    mov x1,x27
    mov x2,x22
    bl md2asm_prepare_radiation_visibility_constants
    ldr x9,[sp,#104]
    ldr w10,[sp,#112]
    str w10,[x9]
    add x0,x24,#1800
    mov x1,#240
    mov x2,x22
    mov x3,#520
    bl md2asm_create_selected_spectral_planck
    cbnz w0,.Lrad_child_failed
// All subsequent writes are total over validated mapped output buffers.
    mov x0,x26
    mov w1,#6
    bl .Lrad_apply_literals
    ldr d0,[x24,#704]
    str d0,[x24,#616]
    str d0,[x24,#624]
    str d0,[x24,#632]
    adrp x1,.Lrad_lw_map
    add x1,x1,:lo12:.Lrad_lw_map
    add x0,x24,#200
    mov x2,#64
    bl memcpy
    adrp x1,.Lrad_sw_map
    add x1,x1,:lo12:.Lrad_sw_map
    add x0,x24,#264
    mov x2,#56
    bl memcpy
// Selected first and second NAERAD values replace only their named fields.
    ldr w9,[x25]
    str w9,[x24,#148]
    ldr w9,[x25,#4]
    str w9,[x24,#156]
    ldr w9,[x25,#8]
    str w9,[x24,#444]
    ldr w9,[x25,#20]
    str w9,[x24,#144]
    ldr w9,[x25,#24]
    str w9,[x24,#56]
    ldr w9,[x25,#28]
    str w9,[x24,#464]
    ldr w9,[x25,#32]
    str w9,[x24,#396]
    mov w9,#2
    str w9,[x24,#72]
    mov w9,#1
    str w9,[x24,#76]
    str wzr,[x24,#436]
    str wzr,[x24,#24]
    mov w9,#21
    str w9,[x24,#28]
    ldr d0,[x22,#144]
    str d0,[x27,#168]
    add x0,x24,#1224
    add x1,x25,#48
    mov x2,#256
    bl memcpy
    add x0,x24,#712
    add x1,x25,#304
    mov x2,#256
    bl memcpy
    add x0,x24,#968
    add x1,x25,#560
    mov x2,#256
    bl memcpy
    ldr x28,[x19,#64]
    ldr w9,[x25,#16]
    str w9,[x28]
    ldr w9,[x25,#12]
    str w9,[x28,#8]
    add x0,x28,#20
    mov w1,#32
    mov x2,#860
    bl memset
    mov w9,#0x2f2e
    strh w9,[x28,#20]
    strh w9,[x28,#540]
    adrp x9,.Lrad_not_set
    ldr x9,[x9,:lo12:.Lrad_not_set]
    str x9,[x28,#800]
    ldr x28,[x19,#80]
    add x0,x28,#168
    mov w1,#32
    mov x2,#520
    bl memset
    add x11,x28,#688
    stp xzr,xzr,[x11]
    mov x9,#1
    str x9,[x28,#704]
    add x11,x28,#712
    stp xzr,xzr,[x11]
    str x9,[x28,#728]
    ldp w9,w10,[x23,#64]
    add x11,x28,#736
    stp w9,w10,[x11]
    ldr x9,[x19,#48]
    ldr w10,[x23,#52]
    str w10,[x9,#16]
    str wzr,[x9,#12]
    str wzr,[x9,#20]
    ldr x9,[x19,#32]
    movz x10,#(205296 & 65535)
    movk x10,#(205296 >> 16),lsl #16
    add x9,x9,x10
    fmov d1,#5.0
    adrp x10,.Lrad_uv_start
    ldr d2,[x10,:lo12:.Lrad_uv_start]
    mov x10,#0
.Lrad_uv_wavelengths:
    scvtf d0,x10
    fmul d0,d0,d1
    fadd d0,d2,d0
    str d0,[x9,x10,lsl #3]
    add x10,x10,#1
    cmp x10,#72
    b.lo .Lrad_uv_wavelengths
    ldr x0,[x19]
    mov x1,x24
    mov x2,#2040
    bl memcpy
    ldr x0,[x19,#16]
    mov x1,x27
    mov x2,#176
    bl memcpy
    ldr x0,[x19,#96]
    mov x1,x25
    mov x2,#2640
    bl memcpy
    mov w28,#0
    b .Lrad_restore_return
.Lrad_bad_restore:
    mov w28,#2
    b .Lrad_restore_return
.Lrad_child_failed:
    mov w28,w0
    b .Lrad_return
.Lrad_bad_frame:
    mov w28,#2
    b .Lrad_return
.Lrad_restore_return:
    ldr x9,[sp,#104]
    ldr w10,[sp,#112]
    str w10,[x9]
.Lrad_return:
    mov w0,w28
    ldr x18,[sp,#96]
    ldp x27,x28,[sp,#80]
    ldp x25,x26,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp]
    add sp,sp,#2048
    add sp,sp,#1,lsl #12
    ret
.Lrad_bad_leaf:
    mov w0,#2
    ret
.size md2asm_initialize_selected_radiation_controls,.-md2asm_initialize_selected_radiation_controls
// x0 source-record pointer table, w1 count of permitted destination records.
.Lrad_apply_literals:
    adrp x9,.Lrad_literal_plan
    add x9,x9,:lo12:.Lrad_literal_plan
    adrp x10,.Lrad_literal_plan_end
    add x10,x10,:lo12:.Lrad_literal_plan_end
.Lrad_literal_next:
    ldp w11,w12,[x9]
    cmp w11,w1
    b.hs .Lrad_literal_skip
    add x13,x0,x11,lsl #4
    ldr x13,[x13]
    add x13,x13,x12
    ldr w14,[x9,#8]
    ldr x15,[x9,#16]
    cmp w14,#4
    b.ne .Lrad_literal_real
    str w15,[x13]
    b .Lrad_literal_skip
.Lrad_literal_real:
    str x15,[x13]
.Lrad_literal_skip:
    add x9,x9,#24
    cmp x9,x10
    b.lo .Lrad_literal_next
    ret
.section .rodata
.p2align 3
.Lrad_output_sizes: .xword 2040,176,229312,32,1384,744,2640
.Lrad_upstream_words: .word 1,0,1,0,0,1,0,0,0,0,1,0,0,24,21,32,2048,2048,19,86,64,0
.Lrad_timesteps: .double 600.0,900.0,1800.0,3600.0
.Lrad_constant_offsets: .word 0,8,16,24,32,144
.p2align 3
.Lrad_not_set: .ascii "not set "
.Lrad_uv_start: .double 280.0
#include "radiation_control_literals.inc.S"
.section .note.GNU-stack,"",%progbits

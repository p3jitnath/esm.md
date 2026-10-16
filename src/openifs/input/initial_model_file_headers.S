/* Contract: skills/md2asm/references/openifs/input/initial_model_file_headers.md. */
// Read selected real spectral/grid initial-file headers through ecCodes C.
// ABI: x0 spectral path, x1 grid path, x2 output, x3 output bytes>=5232.
// The output is eight-byte aligned. Only supported active prefixes change.
// Return 0 success,1 arguments/FPCR,2 open,3 codec,4 metadata,5 close.
// Every error leaves all 5232 output bytes unchanged. All resources close once.
// The 10352-byte frame preserves x18..x30 and caller FPCR/FPSR/errno.
// Only file-format calls can use floating point; no OpenIFS code is called.
.arch armv8.2-a
.text
.macro ADDRESS reg,label
    adrp \reg,\label
    add \reg,\reg,:lo12:\label
.endm
.macro GET_LONG key,offset
    mov x0,x24
    ADDRESS x1,\key
    add x2,x28,#\offset
    bl codes_get_long
    cbnz w0,.Lcodec_failure
.endm
.p2align 4
.global md2asm_read_initial_model_headers
.type md2asm_read_initial_model_headers,%function
md2asm_read_initial_model_headers:
    stp x29,x30,[sp,#-112]!
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x18,[sp,#96]
    mov x29,sp
    sub sp,sp,#2,lsl #12
    sub sp,sp,#2048
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,sp
    add x27,sp,#1,lsl #12
    add x27,x27,#1184
    add x28,sp,#2,lsl #12
    add x28,x28,#1280
    mov x23,#0
    mov x24,#0
    mov w25,#0
    mov w26,#1
    str xzr,[x28,#208]
    mrs x9,fpcr
    str x9,[x28,#192]
    mrs x10,fpsr
    str x10,[x28,#200]
    cbnz x9,.Lreturn
    cbz x19,.Lreturn
    cbz x20,.Lreturn
    cbz x21,.Lreturn
    tst x21,#7
    b.ne .Lreturn
    mov x9,#5232
    cmp x3,x9
    b.lo .Lreturn
    adds x10,x21,x9
    b.cs .Lreturn
    mov x10,#0
.Lcopy_incoming:
    ldr x11,[x21,x10]
    str x11,[x22,x10]
    add x10,x10,#8
    cmp x10,x9
    b.lo .Lcopy_incoming
    bl __errno_location
    str x0,[x28,#208]
    ldr w9,[x0]
    str w9,[x28,#216]
    mov w26,#0
.Lopen_file:
    cmp w25,#0
    csel x0,x19,x20,eq
    ADDRESS x1,.Lmode
    bl fopen
    mov x23,x0
    cbz x23,.Lopen_failure
    str wzr,[x28,#144]
    mov x0,#0
    mov x1,x23
    add x2,x28,#144
    bl codes_grib_handle_new_from_file
    mov x24,x0
    ldr w9,[x28,#144]
    cbnz w9,.Lcodec_failure
    cbz x24,.Lcodec_failure
    GET_LONG .Ldate,0
    GET_LONG .Ltime,8
    GET_LONG .Lstep,16
    // Date labels are copied, while source integer clock arithmetic uses seconds.
    ldr x9,[x28,#0]
    mov x10,#0xbebf
    movk x10,#0x5f5,lsl #16
    cbz x9,.Lscope_failure
    cmp x9,x10
    b.hi .Lscope_failure
    ldr x9,[x28,#8]
    mov x10,#100
    udiv x11,x9,x10
    msub x12,x11,x10,x9
    cmp x11,#23
    b.hi .Lscope_failure
    cmp x12,#59
    b.hi .Lscope_failure
    mov x10,#3600
    mul x11,x11,x10
    mov x10,#60
    madd x11,x12,x10,x11
    str x11,[x28,#8]
    ldr x9,[x28,#16]
    mov x10,#0x1a2b
    movk x10,#9,lsl #16
    cmp x9,x10
    b.hi .Lscope_failure
    mov x10,#3600
    mul x9,x9,x10
    str x9,[x28,#16]
    cbnz w25,.Lgrid_header
    GET_LONG .Ltemplate,48
    ldr x9,[x28,#48]
    cmp x9,#50
    b.ne .Lscope_failure
    GET_LONG .Ltruncation,24
    ldr x9,[x28,#24]
    cmp x9,#1,lsl #12
    b.hi .Lscope_failure
    GET_LONG .Lnv,32
    ldr x9,[x28,#32]
    cmp x9,#4
    b.lo .Lscope_failure
    cmp x9,#514
    b.hi .Lscope_failure
    tbnz x9,#0,.Lscope_failure
    mov x0,x24
    ADDRESS x1,.Lpv
    add x2,x28,#40
    bl codes_get_size
    cbnz w0,.Lcodec_failure
    ldr x9,[x28,#40]
    ldr x10,[x28,#32]
    cmp x9,x10
    b.ne .Lscope_failure
    mov x0,x24
    ADDRESS x1,.Lpv
    mov x2,x27
    add x3,x28,#40
    bl codes_get_double_array
    cbnz w0,.Lcodec_failure
    ldr x9,[x28,#40]
    ldr x10,[x28,#32]
    cmp x9,x10
    b.ne .Lscope_failure
    // Split the exact decoded A prefix and B prefix, preserving unused tails.
    lsr x9,x9,#1
    add x10,x22,#96
    add x11,x22,#2152
    add x12,x27,x9,lsl #3
    mov x13,#0
.Lcopy_coefficients:
    ldr x14,[x27,x13,lsl #3]
    ldr x15,[x12,x13,lsl #3]
    ubfx x16,x14,#52,#11
    cmp x16,#2047
    b.eq .Lscope_failure
    ubfx x16,x15,#52,#11
    cmp x16,#2047
    b.eq .Lscope_failure
    str x14,[x10,x13,lsl #3]
    str x15,[x11,x13,lsl #3]
    add x13,x13,#1
    cmp x13,x9
    b.lo .Lcopy_coefficients
    sub w9,w9,#1
    str w9,[x22,#16]
    ldr w9,[x28,#24]
    stp w9,w9,[x22,#0]
    mov w9,#1
    str w9,[x22,#24]
    str w9,[x22,#28]
    str w9,[x22,#88]
    mov x9,#0x3ff0000000000000
    stp x9,x9,[x22,#64]
    str xzr,[x22,#80]
    ldr w9,[x28,#0]
    ldr w10,[x28,#8]
    ldr w11,[x28,#16]
    stp w9,w10,[x22,#32]
    str w11,[x22,#40]
    b .Lcleanup
.Lgrid_header:
    GET_LONG .Ltemplate,56
    ldr x9,[x28,#56]
    cmp x9,#40
    b.ne .Lscope_failure
    GET_LONG .Llatitudes,24
    GET_LONG .Llongitudes,32
    GET_LONG .Lgaussian_order,40
    GET_LONG .Lpl_present,48
    ldr x9,[x28,#48]
    cbnz x9,.Lscope_failure
    ldr x9,[x28,#24]
    cmp x9,#2
    b.lo .Lscope_failure
    cmp x9,#512
    b.hi .Lscope_failure
    tbnz x9,#0,.Lscope_failure
    ldr x10,[x28,#40]
    cmp x10,#1
    b.lo .Lscope_failure
    cmp x10,#256
    b.hi .Lscope_failure
    lsl x10,x10,#1
    cmp x10,x9
    b.ne .Lscope_failure
    ldr x10,[x28,#32]
    cbz x10,.Lscope_failure
    tbnz x10,#63,.Lscope_failure
    mov x11,#0x7fffffff
    cmp x10,x11
    b.hi .Lscope_failure
    stp w9,w10,[x22,#8]
    str wzr,[x22,#20]
    lsr w9,w9,#1
    str w9,[x22,#56]
    add x11,x22,#1,lsl #12
    add x11,x11,#112
    mov w12,#0
.Lcopy_longitudes:
    str w10,[x11,x12,lsl #2]
    add w12,w12,#1
    cmp w12,w9
    b.lo .Lcopy_longitudes
    ldr w9,[x28,#0]
    ldr w10,[x28,#8]
    ldr w11,[x28,#16]
    stp w9,w10,[x22,#44]
    str w11,[x22,#52]
    b .Lcleanup
.Lopen_failure:
    mov w26,#2
    b .Lcleanup
.Lcodec_failure:
    mov w26,#3
    b .Lcleanup
.Lscope_failure:
    mov w26,#4
.Lcleanup:
    cbz x24,.Lclose_file
    mov x0,x24
    bl codes_handle_delete
    mov x24,#0
    cbz w0,.Lclose_file
    cbnz w26,.Lclose_file
    mov w26,#3
.Lclose_file:
    cbz x23,.Lafter_close
    mov x0,x23
    bl fclose
    mov x23,#0
    cbz w0,.Lafter_close
    cbnz w26,.Lafter_close
    mov w26,#5
.Lafter_close:
    cbnz w26,.Lreturn
    cbnz w25,.Lcommit
    mov w25,#1
    b .Lopen_file
.Lcommit:
    mov x9,#0
    mov x10,#5232
.Lcommit_record:
    ldr x11,[x22,x9]
    str x11,[x21,x9]
    add x9,x9,#8
    cmp x9,x10
    b.lo .Lcommit_record
    ADDRESS x9,.Lcompleted
    ldr x10,[x9]
    add x10,x10,#1
    str x10,[x9]
.Lreturn:
    ldr x9,[x28,#208]
    cbz x9,.Lrestore_status
    ldr w10,[x28,#216]
    str w10,[x9]
.Lrestore_status:
    ldr x9,[x28,#192]
    msr fpcr,x9
    ldr x9,[x28,#200]
    msr fpsr,x9
    mov w0,w26
    mov sp,x29
    ldr x18,[sp,#96]
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x27,x28,[sp,#80]
    ldp x29,x30,[sp],#112
    ret
.size md2asm_read_initial_model_headers,.-md2asm_read_initial_model_headers
.p2align 4
.global md2asm_initial_model_header_count_get
.type md2asm_initial_model_header_count_get,%function
md2asm_initial_model_header_count_get:
    ADDRESS x9,.Lcompleted
    ldr x0,[x9]
    ret
.size md2asm_initial_model_header_count_get,.-md2asm_initial_model_header_count_get
.section .rodata
.Lmode: .asciz "rb"
.Ldate: .asciz "dataDate"
.Ltime: .asciz "dataTime"
.Lstep: .asciz "step"
.Ltemplate: .asciz "gridDefinitionTemplateNumber"
.Ltruncation: .asciz "pentagonalResolutionParameterJ"
.Lnv: .asciz "numberOfVerticalCoordinateValues"
.Lpv: .asciz "pv"
.Llatitudes: .asciz "Nj"
.Llongitudes: .asciz "Ni"
.Lgaussian_order: .asciz "N"
.Lpl_present: .asciz "PLPresent"
.bss
.p2align 3
.Lcompleted: .zero 8
.section .note.GNU-stack,"",%progbits

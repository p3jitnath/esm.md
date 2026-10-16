/* Explicit-buffer selected VERDISINT ITOP/11 one-column profile integration.
 * Contract: skills/md2asm/references/openifs/setup/spline_profile_integral_contract.md. x0=matrix[20,21],
 * x1=interior[19],x2=output[20]. Return0 complete,2 preflight rejection.
 * Own320B aligned frame. Accepted strict matrix leaf supplies all reduction.
 */
.arch armv8-a
.text
.p2align 4
.global md2asm_integrate_spline_profile
.type md2asm_integrate_spline_profile,%function
md2asm_integrate_spline_profile:
    cbz x0,.Lreject
    cbz x1,.Lreject
    cbz x2,.Lreject
    orr x9,x0,x1
    orr x9,x9,x2
    tst x9,#7
    b.ne .Lreject
    mrs x9,fpcr
    cbnz x9,.Lreject
    sub sp,sp,#320
    stp x29,x30,[sp,#64]
    mov x29,sp
    stp x19,x20,[sp,#80]
    stp x21,x18,[sp,#96]
    mov x19,x0
    mov x20,x1
    mov x21,x2
    str xzr,[sp,#152]
    str xzr,[sp,#312]
    mov x9,#0
    add x10,sp,#160
.Lcopy:
    ldr x11,[x20,x9,lsl #3]
    str x11,[x10,x9,lsl #3]
    add x9,x9,#1
    cmp x9,#19
    b.lt .Lcopy
    mov w9,#1
    str w9,[sp,#112]
    str w9,[sp,#124]
    mov w9,#20
    str w9,[sp,#116]
    str w9,[sp,#128]
    mov w9,#21
    str w9,[sp,#120]
    mov w9,#'N'
    strb w9,[sp,#132]
    mov w9,#'T'
    strb w9,[sp,#133]
    mov x9,#0x3ff0000000000000
    str x9,[sp,#136]
    str xzr,[sp,#144]
    str x19,[sp]
    add x9,sp,#128
    str x9,[sp,#8]
    add x9,sp,#144
    str x9,[sp,#16]
    str x21,[sp,#24]
    add x9,sp,#124
    str x9,[sp,#32]
    mov x9,#1
    str x9,[sp,#40]
    str x9,[sp,#48]
    add x0,sp,#132
    add x1,sp,#133
    add x2,sp,#112
    add x3,sp,#116
    add x4,sp,#120
    add x5,sp,#136
    add x6,sp,#152
    add x7,sp,#124
    bl verdisint_strict_nt_fp64_
    ldp x19,x20,[sp,#80]
    ldp x21,x18,[sp,#96]
    ldp x29,x30,[sp,#64]
    add sp,sp,#320
    mov w0,#0
    ret
.Lreject:
    mov w0,#2
    ret
.size md2asm_integrate_spline_profile,.-md2asm_integrate_spline_profile
.p2align 4
.global md2asm_spline_matrix_domain_abort
.hidden md2asm_spline_matrix_domain_abort
.type md2asm_spline_matrix_domain_abort,%function
md2asm_spline_matrix_domain_abort:
    mov w0,#116
    b _exit
.size md2asm_spline_matrix_domain_abort,.-md2asm_spline_matrix_domain_abort
.section .note.GNU-stack,"",%progbits

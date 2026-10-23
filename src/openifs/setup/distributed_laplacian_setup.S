/* Distributed setup contract: skills/md2asm/references/openifs/setup/distributed_spherical_laplacian.md. */
// Direct source correspondence: setup/sulap.F90, spherical NCMAX=NSMAX branch.
// ABI and owned buffer bounds: skills/md2asm/references/openifs/setup/distributed_spherical_laplacian.md..
.text
.p2align 4
.global md2asm_initialize_distributed_laplacian
.type md2asm_initialize_distributed_laplacian,%function
md2asm_initialize_distributed_laplacian:
    sub sp,sp,#640
    stp x29,x30,[sp]
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    stp x27,x28,[sp,#80]
    str x18,[sp,#96]
    mov x19,x0
    mov x21,x1
    mov x22,x2
    mov w25,#2
    cbz x19,.Ldl_preflight_done
    cbz x21,.Ldl_preflight_done
    cbz x22,.Ldl_preflight_done
    orr x3,x19,x21
    orr x3,x3,x22
    tst x3,#7
    b.ne .Ldl_preflight_done
    ldr x3,[x22]
    cmp x3,x19
    b.ne .Ldl_preflight_done
    ldr x3,[x22,#8]
    movz x4,#0x574e
    movk x4,#0x5f4f,lsl#16
    movk x4,#0x5458,lsl#32
    movk x4,#0x4450,lsl#48
    cmp x3,x4
    b.ne .Ldl_preflight_done
    ldr w3,[x22,#16]
    and w3,w3,#3
    cmp w3,#3
    b.ne .Ldl_preflight_done
    ldr w3,[x22,#24]
    cmp w3,#4
    b.ne .Ldl_preflight_done
    add x20,x19,#3656
    add x5,x19,#4096
    ldr w3,[x5,#1072]
    cmp w3,#0
    b.le .Ldl_preflight_done
    ldr w3,[x5,#1076]
    cmp w3,#1279
    b.ne .Ldl_preflight_done
    ldr w3,[x5,#1112]
    cmp w3,#1279
    b.ne .Ldl_preflight_done
    ldr w3,[x5,#1116]
    cmp w3,#640
    b.ne .Ldl_preflight_done
    ldr w3,[x5,#1120]
    cmp w3,#640
    b.ne .Ldl_preflight_done
    ldr w3,[x5,#1100]
    movz w4,#0x4140
    movk w4,#6,lsl#16
    cmp w3,w4
    b.ne .Ldl_preflight_done
    ldr w3,[x5,#1104]
    movz w4,#0x8280
    movk w4,#12,lsl#16
    cmp w3,w4
    b.ne .Ldl_preflight_done
    ldr x3,[x21,#104]
    adrp x4,.Ldl_radius
    ldr x4,[x4,:lo12:.Ldl_radius]
    cmp x3,x4
    b.ne .Ldl_preflight_done
    mov x3,#0
.Ldl_fresh:
    ldr x4,[x20,x3]
    cbnz x4,.Ldl_preflight_done
    add x3,x3,#8
    cmp x3,#576
    b.lo .Ldl_fresh
    mov w25,#0
.Ldl_preflight_done:
    mov w0,w25
    bl md2asm_agree_owned_distributed_partition_status
    cbnz w0,.Ldl_return
    add x20,x19,#3656
    adrp x24,.Ldl_arrays
    add x24,x24,:lo12:.Ldl_arrays
    mov x23,#0
    mov w25,#0
.Ldl_allocate_eight:
    bl .Ldl_allocate
    cbnz w0,.Ldl_eight_failed
    add x24,x24,#24
    add x23,x23,#1
    cmp x23,#8
    b.lo .Ldl_allocate_eight
    b .Ldl_eight_agree
.Ldl_eight_failed:
    mov w25,#1
.Ldl_eight_agree:
    mov w0,w25
    bl md2asm_agree_owned_distributed_partition_status
    cbnz w0,.Ldl_allocation_failed
    // Exact 47-argument optional-address packer: KRESOL, then KASM0.
    add x3,sp,#128
    add x4,x3,#376
.Ldl_clear_args:
    str xzr,[x3],#8
    cmp x3,x4
    b.lo .Ldl_clear_args
    add x3,x19,#4096
    add x3,x3,#1072
    str x3,[sp,#128]
    add x3,x20,#64
    str x3,[sp,#216]
    add x0,sp,#128
    bl md2asm_call_public_transform_inquiry
    str xzr,[sp,#216]
    add x3,x20,#256
    str x3,[sp,#208]
    add x0,sp,#128
    bl md2asm_call_public_transform_inquiry
    ldr x3,[x20]
    mov w4,#0
.Ldl_nasn0:
    madd w5,w4,w4,w4
    add w5,w5,#1
    str w5,[x3,x4,lsl#2]
    add w4,w4,#1
    cmp w4,#1280
    b.lo .Ldl_nasn0
    // NSE0L is allocated after both inquiries and NASN0, as in the source.
    adrp x24,.Ldl_arrays
    add x24,x24,:lo12:.Ldl_arrays
    add x24,x24,#192
    bl .Ldl_allocate
    bl md2asm_agree_owned_distributed_partition_status
    cbnz w0,.Ldl_allocation_failed
    ldr x3,[x20,#256]
    ldr x4,[x20,#384]
    mov w5,#0
    mov w6,#0
.Ldl_local_prefix:
    ldr w7,[x3,x5,lsl#2]
    cmp w7,#1279
    b.hi .Ldl_fatal
    str w6,[x4,x5,lsl#2]
    mov w8,#1280
    sub w8,w8,w7
    add w6,w6,w8
    add w5,w5,#1
    cmp w5,#640
    b.lo .Ldl_local_prefix
    movz w7,#0x4140
    movk w7,#6,lsl#16
    cmp w6,w7
    b.ne .Ldl_fatal
    // Unchanged accepted separate FP64 operations from serial SULAP.
    ldr d0,[x21,#104]
    ldr x3,[x20,#448]
    ldr x4,[x20,#512]
    add x3,x3,#16
    add x4,x4,#16
    mov w5,#1
    mov w6,#1281
.Ldl_eigenvalues:
    add w7,w5,#1
    mul w7,w5,w7
    scvtf d1,w7
    fneg d2,d1
    fmul d3,d0,d0
    fdiv d4,d2,d3
    str d4,[x3],#8
    fmul d3,d0,d0
    fneg d3,d3
    fdiv d4,d3,d1
    str d4,[x4],#8
    add w5,w5,#1
    cmp w5,w6
    b.ls .Ldl_eigenvalues
    ldr x3,[x20,#448]
    ldr x4,[x20,#512]
    stp xzr,xzr,[x3]
    stp xzr,xzr,[x4]
    ldr x3,[x20,#192]
    ldr x4,[x20,#256]
    mov w5,#0
.Ldl_wave:
    ldr w6,[x4,x5,lsl#2]
.Ldl_degrees:
    stp w6,w6,[x3],#8
    add w6,w6,#1
    cmp w6,#1279
    b.ls .Ldl_degrees
    add w5,w5,#1
    cmp w5,#640
    b.lo .Ldl_wave
    ldr x3,[x20,#128]
    mov w4,#0
    mov w5,#1
.Ldl_nasm0g:
    str w5,[x3,x4,lsl#2]
    mov w6,#1280
    sub w6,w6,w4
    add w5,w5,w6,lsl#1
    add w4,w4,#1
    cmp w4,#1280
    b.lo .Ldl_nasm0g
    ldr x3,[x20,#320]
    mov w4,#0
.Ldl_zero:
    lsl w5,w4,#1
    add w5,w5,#2
    str w5,[x3,x4,lsl#2]
    add w4,w4,#1
    cmp w4,#1280
    b.lo .Ldl_zero
    mov w0,#0
    b .Ldl_return
.Ldl_allocation_failed:
    mov x0,x19
    bl md2asm_release_distributed_laplacian
    mov w0,#1
    b .Ldl_return
.Ldl_fatal:
    mov w0,#3
    bl abort
.Ldl_return:
    ldr x18,[sp,#96]
    ldp x27,x28,[sp,#80]
    ldp x25,x26,[sp,#64]
    ldp x23,x24,[sp,#48]
    ldp x21,x22,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp]
    add sp,sp,#640
    ret
// Allocate one descriptor from the source-order table. Only x0-x17 clobbered.
.Ldl_allocate:
    str x30,[sp,#512]
    ldr w0,[x24,#4]
    ldr w3,[x24,#8]
    mul x0,x0,x3
    bl malloc
    cbz x0,.Ldl_alloc_no
    ldr w3,[x24]
    add x3,x20,x3
    str x0,[x3]
    ldrsw x4,[x24,#12]
    neg x5,x4
    str x5,[x3,#8]
    ldr w5,[x24,#8]
    str x5,[x3,#16]
    mov x6,#1
    ldr w7,[x24,#16]
    orr x6,x6,x7,lsl#8
    lsl x6,x6,#32
    str x6,[x3,#24]
    str x5,[x3,#32]
    mov x5,#1
    stp x5,x4,[x3,#40]
    ldr w5,[x24,#4]
    add x4,x4,x5
    sub x4,x4,#1
    str x4,[x3,#56]
    mov w0,#0
    ldr x30,[sp,#512]
    ret
.Ldl_alloc_no:
    mov w0,#1
    ldr x30,[sp,#512]
    ret
.size md2asm_initialize_distributed_laplacian,.-md2asm_initialize_distributed_laplacian
.p2align 4
.global md2asm_release_distributed_laplacian
.type md2asm_release_distributed_laplacian,%function
md2asm_release_distributed_laplacian:
    stp x29,x30,[sp,#-48]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    str x18,[sp,#32]
    add x19,x0,#3656
    mov x20,#0
.Ldl_release:
    ldr x0,[x19,x20]
    cbz x0,.Ldl_release_next
    bl free
    str xzr,[x19,x20]
.Ldl_release_next:
    add x20,x20,#64
    cmp x20,#576
    b.lo .Ldl_release
    mov w0,#0
    ldr x18,[sp,#32]
    ldp x19,x20,[sp,#16]
    ldp x29,x30,[sp],#48
    ret
.size md2asm_release_distributed_laplacian,.-md2asm_release_distributed_laplacian
.section .rodata
.p2align 3
.Ldl_arrays:
    // Descriptor byte offset, element count, bytes, lower bound, type, reserved.
    .word 256,640,4,1,1,0
    .word 448,1283,8,-1,3,0
    .word 512,1283,8,-1,3,0
    .word 0,1280,4,0,1,0
    .word 64,1280,4,0,1,0
    .word 128,1280,4,0,1,0
    .word 320,1280,4,0,1,0
    .word 192,819840,4,1,1,0
    .word 384,640,4,1,1,0
.Ldl_radius:
    .double 6371229.0
.section .note.GNU-stack,"",%progbits

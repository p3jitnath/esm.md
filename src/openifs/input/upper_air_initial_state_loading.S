/*
 * Upper-air initial-state loading, revision 1.
 * Contract: skills/md2asm/references/openifs/input/upper_air_initial_state_loading.md
 * x0 path, x1 in/out GFL, x2 GFL byte capacity; return integer status in w0.
 * The complete GFL shape is (24,19,8,86), requiring 2509824 bytes.
 * Decode all records before placement, preserving the incoming array on error.
 * Allocate private decoded values and labels through ordinary C malloc/free.
 * No new floating-point arithmetic and no OpenIFS numerical child.
 * FPCR must be zero. Preserve FPCR/FPSR, errno, x18 and all ABI saved state.
 * Frame 112 bytes, aligned to 16 bytes. Child contracts define field units.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_load_initial_upper_air_state
.type md2asm_load_initial_upper_air_state,%function
md2asm_load_initial_upper_air_state:
    stp x29,x30,[sp,#-112]!
    mov x29,sp
    stp x19,x20,[sp,#16]
    stp x21,x22,[sp,#32]
    stp x23,x24,[sp,#48]
    stp x25,x26,[sp,#64]
    str x18,[sp,#80]
    mrs x25,fpsr
    mrs x26,fpcr
    mov x19,x0
    mov x20,x1
    mov x21,x2
    mov x22,xzr
    mov x24,xzr
    mov w23,#1
    cbz x19,.Lrestore
    cbz x20,.Lrestore
    tst x20,#7
    b.ne .Lrestore
    movz x8,#0x4c00
    movk x8,#38,lsl#16
    cmp x21,x8
    b.lo .Lrestore
    adds x9,x20,x8
    b.cs .Lrestore
    cbnz x26,.Lrestore
    bl __errno_location
    mov x24,x0
    ldr w8,[x24]
    str w8,[sp,#88]
    movz x0,#0x0720
    movk x0,#19,lsl#16
    bl malloc
    mov x22,x0
    mov w23,#2
    cbz x22,.Lrestore_errno
    mov x0,x19
    mov x1,x22
    movz x2,#0
    movk x2,#19,lsl#16
    add x3,x22,x2
    mov x4,#1824
    add x5,sp,#96
    ldr x18,[sp,#80]
    bl md2asm_read_initial_upper_air_fields
    add w23,w0,#16
    cbnz w0,.Lcleanup
    mov x0,x22
    movz x1,#0
    movk x1,#19,lsl#16
    add x2,x22,x1
    mov x3,#1824
    mov x4,x20
    mov x5,x21
    ldr x18,[sp,#80]
    bl md2asm_place_initial_upper_air_fields
    add w23,w0,#32
    cbnz w0,.Lcleanup
    mov w23,#0
.Lcleanup:
    mov x0,x22
    bl free
.Lrestore_errno:
    ldr w8,[sp,#88]
    str w8,[x24]
.Lrestore:
    msr fpcr,x26
    msr fpsr,x25
    ldr x18,[sp,#80]
    mov w0,w23
    ldp x19,x20,[sp,#16]
    ldp x21,x22,[sp,#32]
    ldp x23,x24,[sp,#48]
    ldp x25,x26,[sp,#64]
    ldp x29,x30,[sp],#112
    ret
.size md2asm_load_initial_upper_air_state,.-md2asm_load_initial_upper_air_state
.section .note.GNU-stack,"",%progbits

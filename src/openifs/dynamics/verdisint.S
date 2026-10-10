/* Direct vertical interface from skills/md2asm/references/openifs/dynamics/verdisint.md revision 1.1.
 * Select the complete source-defined operator and prepare local integral data.
 * Table status 0: defined, 1: undefined upstream, 2: upstream abort.
 */
#ifndef VERDISINT_ENTRY
#define VERDISINT_ENTRY verdisint_
#endif
#ifndef VERINT_ENTRY
#define VERINT_ENTRY verint_
#endif
#ifndef VERDER_ENTRY
#define VERDER_ENTRY verder_
#endif
.text
.p2align 4
.global VERDISINT_ENTRY
.type VERDISINT_ENTRY, %function
VERDISINT_ENTRY:
    mov x9, sp
    sub sp, sp, #256
    stp x19, x20, [sp, #160]
    stp x21, x22, [sp, #176]
    stp x23, x24, [sp, #192]
    stp x25, x26, [sp, #208]
    stp x27, x28, [sp, #224]
    stp x29, x30, [sp, #240]
    mov x19, x0
    mov x20, x1
    ldr x21, [x9]
    ldr x22, [x9, #8]
    ldr x10, [x9, #32]
    cmp x10, #4
    b.ne .Lvertical_bad
    ldr x10, [x9, #40]
    cmp x10, #2
    b.ne .Lvertical_bad
    ldr w10, [x20, #52]
    cbz w10, .Lvertical_bad
    ldr w10, [x4]
    ldr w11, [x5]
    ldr w12, [x6]
    ldr w27, [x7]
    str w10, [sp, #64]
    str w11, [sp, #68]
    str w12, [sp, #72]
    str w27, [sp, #76]
    cmp w10, #1
    b.lt .Lvertical_bad
    cmp w27, #1
    b.lt .Lvertical_bad
    cmp w11, #1
    b.lt .Lvertical_bad
    cmp w11, w10
    b.gt .Lvertical_bad
    sub w13, w11, #1
    cmp w12, w13
    b.lt .Lvertical_bad
    cmp w12, w10
    b.gt .Lvertical_bad
    lsl x25, x10, #3
    sub w28, w12, w11
    add w28, w28, #1
    ldr w13, [x2]
    adrp x14, .Lvertical_operations
    add x14, x14, :lo12:.Lvertical_operations
    mov w15, #0
.Lvertical_find:
    ldr w16, [x14, x15, lsl #2]
    cmp w13, w16
    b.eq .Lvertical_found
    add w15, w15, #1
    cmp w15, #7
    b.lt .Lvertical_find
    b .Lvertical_bad
.Lvertical_found:
    str w15, [sp, #100]
    ldrb w13, [x3]
    ldrb w14, [x3, #1]
    sub w13, w13, #'0'
    sub w14, w14, #'0'
    cmp w13, #1
    b.hi .Lvertical_bad
    cmp w14, #1
    b.hi .Lvertical_bad
    add w26, w14, w13, lsl #1
    ldr x13, [x9, #16]
    cbz x13, .Lvertical_default
    ldr w13, [x13]
    b .Lvertical_ibc
.Lvertical_default:
    cmp w15, #2
    b.gt .Lvertical_default_derivative
    ldr w13, [x20, #36]
    b .Lvertical_ibc
.Lvertical_default_derivative:
    ldr w13, [x20, #40]
.Lvertical_ibc:
    cmp w13, #3
    b.hi .Lvertical_bad
    str w13, [sp, #96]
    ldr x14, [x9, #24]
    mov w16, #1
    cbz x14, .Lvertical_chunk
    ldr w16, [x14]
.Lvertical_chunk:
    str w16, [sp, #92]
    cmp w15, #2
    b.gt .Lvertical_derivative_start
    cmp w16, #1
    b.lt .Lvertical_bad
    b .Lvertical_select
.Lvertical_derivative_start:
    ldr w14, [sp, #68]
    cmp w14, #1
    b.ne .Lvertical_bad
.Lvertical_select:
    adrp x14, .Lvertical_dispatch
    add x14, x14, :lo12:.Lvertical_dispatch
    add x14, x14, x15, lsl #7
    add x14, x14, x13, lsl #5
    add x14, x14, x26, lsl #3
    cmp w15, #4
    b.ne .Lvertical_status
    ldr x16, [x19, #856]
    cbz x16, .Lvertical_bad
.Lvertical_status:
    ldrb w16, [x14, #6]
    cmp w16, #1
    b.eq .Lvertical_undefined
    cbnz w16, .Lvertical_bad
    ldrh w16, [x14]
    add x23, x19, x16
    ldrb w16, [x14, #2]
    str w16, [sp, #104]
    ldrb w16, [x14, #3]
    add w16, w27, w16
    str w16, [sp, #80]
    ldrb w17, [x14, #4]
    add w17, w27, w17
    str w17, [sp, #84]
    ldrb w14, [x14, #5]
    str w14, [sp, #88]
    ldr x10, [x23, #16]
    cmp x10, #8
    b.ne .Lvertical_bad
    ldr x10, [x23, #32]
    cmp x10, #8
    b.ne .Lvertical_bad
    ldr x10, [x23, #40]
    cmp x10, #1
    b.ne .Lvertical_bad
    ldr x10, [x23, #64]
    cmp x10, x17
    b.ne .Lvertical_bad
    ldr x10, [x23, #48]
    ldr x11, [x23, #56]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x17
    b.ne .Lvertical_bad
    ldr x10, [x23, #72]
    ldr x11, [x23, #80]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x16
    b.ne .Lvertical_bad
    ldr x23, [x23]
    cbz x23, .Lvertical_bad
    tst x23, #7
    b.ne .Lvertical_bad
    ldr w15, [sp, #100]
    cmp w15, #2
    b.gt .Lvertical_apply_derivative
    cbz w28, .Lvertical_done
    add x0, x27, #2
    mul x0, x0, x25
    bl malloc
    mov x24, x0
    cbz x24, .Lvertical_bad
    ldr w9, [sp, #68]
    sub w9, w9, #1
    lsl x9, x9, #3
    add x10, x21, x25
    add x10, x10, x9
    add x11, x24, x25
    add x11, x11, x9
    mov w12, w27
.Lvertical_copy_level:
    mov x13, x10
    mov x14, x11
    mov w15, w28
.Lvertical_copy_point:
    ldr x16, [x13], #8
    str x16, [x14], #8
    subs w15, w15, #1
    b.ne .Lvertical_copy_point
    add x10, x10, x25
    add x11, x11, x25
    subs w12, w12, #1
    b.ne .Lvertical_copy_level
    ldr w10, [sp, #80]
    cmp w10, w27
    b.eq .Lvertical_integral_arguments
    add x10, x24, x9
    add x11, x27, #1
    mul x11, x11, x25
    add x11, x10, x11
    mov w12, w28
.Lvertical_zero_boundary:
    str xzr, [x10], #8
    str xzr, [x11], #8
    subs w12, w12, #1
    b.ne .Lvertical_zero_boundary
.Lvertical_integral_arguments:
    ldr w9, [sp, #104]
    mul x9, x9, x25
    add x6, x24, x9
    add x0, sp, #64
    add x1, sp, #68
    add x2, sp, #72
    add x3, sp, #80
    add x4, sp, #84
    mov x5, x23
    mov x7, x22
    add x9, sp, #88
    str x9, [sp]
    add x9, sp, #92
    str x9, [sp, #8]
    bl VERINT_ENTRY
    mov x0, x24
    bl free
    b .Lvertical_done
.Lvertical_apply_derivative:
    ldr w9, [sp, #104]
    mul x9, x9, x25
    add x6, x21, x9
    add x0, sp, #64
    add x1, sp, #68
    add x2, sp, #72
    add x3, sp, #80
    add x4, sp, #84
    mov x5, x23
    mov x7, x22
    bl VERDER_ENTRY
.Lvertical_done:
    ldp x19, x20, [sp, #160]
    ldp x21, x22, [sp, #176]
    ldp x23, x24, [sp, #192]
    ldp x25, x26, [sp, #208]
    ldp x27, x28, [sp, #224]
    ldp x29, x30, [sp, #240]
    add sp, sp, #256
    ret
.Lvertical_bad:
    adrp x0, .Lvertical_message
    add x0, x0, :lo12:.Lvertical_message
    mov x1, .Lvertical_message_end-.Lvertical_message
    bl abor1_
    brk #0
.Lvertical_undefined:
    adrp x0, .Lvertical_undefined_message
    add x0, x0, :lo12:.Lvertical_undefined_message
    mov x1, .Lvertical_undefined_message_end-.Lvertical_undefined_message
    bl abor1_
    brk #0
.size VERDISINT_ENTRY, .-VERDISINT_ENTRY
.section .rodata
.p2align 2
.Lvertical_operations: .ascii "ITOPIBOTINGWDEGWHDERFDERDDER"
.p2align 3
/* descriptor, IND, N-L, M-L, integral type, status, reserved */
.macro record descriptor, first, extra, rows, integral, status
    .short \descriptor
    .byte \first,\extra,\rows,\integral,\status,0
.endm
 .global verdisint_dispatch_metadata_
 .hidden verdisint_dispatch_metadata_
 .type verdisint_dispatch_metadata_,%object
verdisint_dispatch_metadata_:
.Lvertical_dispatch:
/* ITOP: IBC0,1,2,3; CDBC00,01,10,11 within each group. */
record 64,0,2,1,0,1
record 64,1,0,1,0,0
record 64,1,0,1,0,0
record 64,1,0,1,0,0
record 152,0,2,1,0,1
record 240,0,2,1,0,0
record 240,0,2,1,0,0
record 240,0,2,1,0,0
record 152,0,2,1,0,1
record 1296,1,0,1,0,0
record 1296,1,0,1,0,0
record 1296,1,0,1,0,0
record 152,0,2,1,0,1
record 240,0,2,1,0,0
record 240,0,2,1,0,0
record 240,0,2,1,0,0
/* IBOT. */
record 64,0,2,1,1,1
record 64,1,0,1,1,0
record 64,1,0,1,1,0
record 64,1,0,1,1,0
record 152,0,2,1,1,1
record 240,0,2,1,1,0
record 240,0,2,1,1,0
record 240,0,2,1,1,0
record 152,0,2,1,1,1
record 1296,1,0,1,1,0
record 1296,1,0,1,1,0
record 1296,1,0,1,1,0
record 152,0,2,1,1,1
record 240,0,2,1,1,0
record 240,0,2,1,1,0
record 240,0,2,1,1,0
/* INGW: every source branch consumes an undefined local boundary. */
record 64,0,2,1,1,1
record 64,0,1,1,1,1
record 64,0,1,1,1,1
record 64,0,1,1,1,1
record 2000,0,2,1,0,1
record 2000,0,2,1,0,1
record 2000,0,2,1,0,1
record 2000,0,2,1,0,1
record 2000,0,2,1,0,1
record 2000,0,1,1,0,1
record 2000,0,1,1,0,1
record 2000,0,1,1,0,1
record 2000,0,2,1,0,1
record 2000,0,2,1,0,1
record 2000,0,2,1,0,1
record 2000,0,2,1,0,1
/* DEGW. */
record 2088,0,2,1,0,1
record 2088,0,1,1,0,0
record 2088,0,1,1,0,0
record 2088,0,1,1,0,0
record 2088,0,2,1,0,1
record 2088,0,2,1,0,1
record 2088,0,2,1,0,1
record 2088,0,2,1,0,1
record 2088,0,2,1,0,1
record 2088,0,1,1,0,0
record 2088,0,1,1,0,0
record 2088,0,1,1,0,0
record 2088,0,2,1,0,1
record 2088,0,2,1,0,1
record 2088,0,2,1,0,1
record 2088,0,2,1,0,1
/* HDER always requires RDERBH00 first. */
record 856,0,2,1,0,0
record 856,1,0,1,0,2
record 856,1,0,1,0,2
record 856,1,0,1,0,2
record 856,0,2,1,0,0
record 856,0,2,1,0,2
record 856,0,2,1,0,2
record 856,0,2,1,0,2
record 856,0,2,1,0,0
record 1648,1,0,1,0,0
record 856,1,0,1,0,2
record 856,1,0,1,0,2
record 856,0,2,1,0,0
record 944,0,2,1,0,0
record 856,0,2,1,0,2
record 856,0,2,1,0,2
/* FDER. */
record 328,0,2,0,0,1
record 328,1,0,0,0,0
record 328,1,0,0,0,0
record 328,1,0,0,0,0
record 504,0,2,0,0,0
record 592,0,2,0,0,0
record 680,0,2,0,0,0
record 768,0,2,0,0,0
record 0,0,2,0,0,2
record 1384,1,0,0,0,0
record 1472,1,0,0,0,0
record 1560,1,0,0,0,0
record 504,0,2,0,0,0
record 592,0,2,0,0,0
record 680,0,2,0,0,0
record 768,0,2,0,0,0
/* DDER. */
record 1032,0,2,0,0,1
record 1032,1,0,0,0,0
record 1032,1,0,0,0,0
record 1032,1,0,0,0,0
record 1032,0,2,0,0,1
record 1120,0,2,0,0,0
record 0,0,2,0,0,2
record 0,0,2,0,0,2
record 0,0,2,0,0,2
record 0,1,0,0,0,2
record 0,1,0,0,0,2
record 1912,1,0,0,0,0
record 0,0,2,0,0,2
record 1120,0,2,0,0,0
record 0,0,2,0,0,2
record 1208,0,2,0,0,0
.size verdisint_dispatch_metadata_,.-verdisint_dispatch_metadata_
.purgem record
.Lvertical_message: .ascii "VERDISINT: UNSUPPORTED DOMAIN OR OPERATOR ALLOCATION"
.Lvertical_message_end:
.Lvertical_undefined_message: .ascii "VERDISINT: UNDEFINED UPSTREAM BRANCH REQUIRES SCIENTIFIC FIX"
.Lvertical_undefined_message_end:
.section .note.GNU-stack,"",%progbits

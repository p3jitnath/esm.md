/* Direct scalar surface exchange from the physical input and contract.
 * Physics formulations/openifs/surface/surface_exchange.md
 * Contract skills/md2asm/references/openifs/surface/vexcs.md
 * All original scalar stages are present with separately rounded FP64.
 */
#ifndef ORIGINAL_SYMBOL
#define ORIGINAL_SYMBOL __vexcs_mod_MOD_vexcs
#endif
.text
.p2align 4
.global md2asm_surface_exchange
.global ORIGINAL_SYMBOL
.type md2asm_surface_exchange,%function
md2asm_surface_exchange:
ORIGINAL_SYMBOL:
    mrs x9, fpcr
    cbnz x9, .Lsurface_bad
    mov x16, sp
    sub sp, sp, #960
    stp x19, x20, [sp, #0]
    stp x21, x22, [sp, #16]
    stp x23, x24, [sp, #32]
    stp x25, x26, [sp, #48]
    stp x27, x28, [sp, #64]
    stp x29, x30, [sp, #80]
    stp d8, d9, [sp, #96]
    stp d10, d11, [sp, #112]
    stp d12, d13, [sp, #128]
    stp d14, d15, [sp, #144]
    str x0, [sp, #160]
    str x1, [sp, #168]
    str x2, [sp, #176]
    str x3, [sp, #184]
    str x4, [sp, #192]
    str x5, [sp, #200]
    str x6, [sp, #208]
    str x7, [sp, #216]
    ldr x9, [x16, #0]
    str x9, [sp, #224]
    ldr x9, [x16, #8]
    str x9, [sp, #232]
    ldr x9, [x16, #16]
    str x9, [sp, #240]
    ldr x9, [x16, #24]
    str x9, [sp, #248]
    ldr x9, [x16, #32]
    str x9, [sp, #256]
    ldr x9, [x16, #40]
    str x9, [sp, #264]
    ldr x9, [x16, #48]
    str x9, [sp, #272]
    ldr x9, [x16, #56]
    str x9, [sp, #280]
    ldr x9, [x16, #64]
    str x9, [sp, #288]
    ldr x9, [x16, #72]
    str x9, [sp, #296]
    ldr x9, [x16, #80]
    str x9, [sp, #304]
    ldr x9, [x16, #88]
    str x9, [sp, #312]
    ldr x9, [x16, #96]
    str x9, [sp, #320]
    ldr x9, [x16, #104]
    str x9, [sp, #328]
    ldr x9, [x16, #112]
    str x9, [sp, #336]
    ldr x9, [x16, #120]
    str x9, [sp, #344]
    ldr x9, [x16, #128]
    str x9, [sp, #352]
    ldr x9, [x16, #136]
    str x9, [sp, #360]
    ldr x9, [x16, #144]
    str x9, [sp, #368]
    ldr x9, [x16, #152]
    str x9, [sp, #376]
    ldr x9, [x16, #160]
    str x9, [sp, #384]
    ldr x9, [x16, #168]
    str x9, [sp, #392]
    ldr x9, [sp, #192]
    ldr w9, [x9]
    cmp w9, #0
    b.gt .Lsurface_bad
    ldr x9, [sp, #184]
    ldr w9, [x9]
    cmp w9, #32
    b.hi .Lsurface_bad
    ldr x9, [sp, #200]
    ldr w9, [x9]
    cmp w9, #1
    b.hi .Lsurface_bad
    ldr x9, [sp, #176]
    ldr w21, [x9]
    cmp w21, #1
    b.lt .Lsurface_bad
    ldr x9, [sp, #160]
    ldr w19, [x9]
    cmp w19, #1
    b.lt .Lsurface_bad
    add w10, w21, #1
    cmp w19, w10
    b.gt .Lsurface_bad
    ldr x9, [sp, #168]
    ldr w20, [x9]
    cmp w20, #0
    b.lt .Lsurface_bad
    cmp w20, w21
    b.gt .Lsurface_bad
    cmp w19, w20
    b.gt .Lsurface_return
    ldr x9, [sp, #208]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #216]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #224]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #232]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #240]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #248]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #256]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #264]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #272]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #280]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #288]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #296]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #304]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #312]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #320]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #328]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #360]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #368]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #376]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #384]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    ldr x9, [sp, #392]
    cbz x9, .Lsurface_bad
    ldr x10, [x9]
    cbz x10, .Lsurface_bad
    ldr x10, [x9, #16]
    cmp x10, #8
    b.ne .Lsurface_bad
    ldrb w10, [x9, #28]
    cmp w10, #1
    b.ne .Lsurface_bad
    ldr x10, [x9, #40]
    cbz x10, .Lsurface_bad
    ldp x10, x11, [x9, #48]
    sub x11, x11, x10
    add x11, x11, #1
    cmp x11, x21
    b.lt .Lsurface_bad
    adrp x9, :got:__yos_thf_MOD_rvtmp2
    ldr x9, [x9, :got_lo12:__yos_thf_MOD_rvtmp2]
    ldr d0, [x9]
    ldr x9, [sp, #344]
    ldr d1, [x9, #48]
    fsub d0, d0, d1
    str d0, [sp, #400]
    ldr x9, [sp, #352]
    ldr d0, [x9, #64]
    ldr x9, [sp, #352]
    ldr d1, [x9, #64]
    fmul d0, d0, d1
    str d0, [sp, #408]
    ldr x9, [sp, #352]
    ldr d0, [x9, #80]
    str d0, [sp, #416]
.Lsurface_column:
    ldr x9, [sp, #208]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #424]
    ldr x9, [sp, #216]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #432]
    ldr x9, [sp, #224]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #440]
    ldr x9, [sp, #232]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #448]
    ldr x9, [sp, #240]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #456]
    ldr x9, [sp, #248]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #464]
    ldr x9, [sp, #256]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #472]
    ldr x9, [sp, #264]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #480]
    ldr x9, [sp, #272]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #488]
    ldr x9, [sp, #280]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #496]
    ldr x9, [sp, #288]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #504]
    ldr x9, [sp, #296]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #512]
    ldr x9, [sp, #304]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #520]
    ldr x9, [sp, #312]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #528]
    ldr x9, [sp, #320]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #536]
    ldr x9, [sp, #328]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    ldr d0, [x10, x12, lsl #3]
    str d0, [sp, #544]
    adrp x9, .Lsurface_value0
    ldr d0, [x9, :lo12:.Lsurface_value0]
    str d0, [sp, #552]
    ldr d0, [sp, #528]
    fcmp d0, #0.0
    b.le .Lsurface_no_convection
    ldr d0, [sp, #528]
    ldr d1, [sp, #416]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    adrp x9, .Lsurface_value1
    ldr d1, [x9, :lo12:.Lsurface_value1]
    bl md2asm_pow_original_rounding_candidate
    str d0, [sp, #552]
.Lsurface_no_convection:
    ldr d0, [sp, #424]
    ldr d1, [sp, #536]
    fsub d0, d0, d1
    str d0, [sp, #568]
    ldr d0, [sp, #568]
    ldr d1, [sp, #568]
    fmul d0, d0, d1
    str d0, [sp, #568]
    ldr d0, [sp, #432]
    ldr d1, [sp, #544]
    fsub d0, d0, d1
    str d0, [sp, #576]
    ldr d0, [sp, #576]
    ldr d1, [sp, #576]
    fmul d0, d0, d1
    str d0, [sp, #576]
    ldr d0, [sp, #568]
    ldr d1, [sp, #576]
    fadd d0, d0, d1
    str d0, [sp, #584]
    ldr d0, [sp, #584]
    ldr d1, [sp, #552]
    fadd d0, d0, d1
    str d0, [sp, #584]
    ldr x9, [sp, #352]
    ldr d0, [x9, #72]
    ldr d1, [sp, #584]
    fmax d0, d0, d1
    str d0, [sp, #584]
    ldr d0, [sp, #472]
    ldr d1, [sp, #480]
    fsub d0, d0, d1
    str d0, [sp, #560]
    adrp x9, .Lsurface_value2
    ldr d0, [x9, :lo12:.Lsurface_value2]
    ldr d1, [sp, #560]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #472]
    ldr d1, [sp, #480]
    fadd d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #592]
    ldr d1, [sp, #464]
    fsub d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #560]
    ldr d1, [sp, #592]
    fdiv d0, d0, d1
    str d0, [sp, #600]
    ldr d0, [sp, #488]
    adrp x9, .Lsurface_value3
    ldr d1, [x9, :lo12:.Lsurface_value3]
    fmin d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #448]
    ldr d1, [sp, #560]
    fsub d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #400]
    ldr d1, [sp, #560]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #600]
    ldr d1, [sp, #560]
    fsub d0, d0, d1
    str d0, [sp, #600]
    ldr d0, [sp, #464]
    ldr d1, [sp, #600]
    fmul d0, d0, d1
    str d0, [sp, #608]
    ldr d0, [sp, #608]
    ldr d1, [sp, #584]
    fdiv d0, d0, d1
    str d0, [sp, #608]
    ldr d0, [sp, #464]
    ldr x9, [sp, #344]
    ldr d1, [x9, #104]
    fdiv d0, d0, d1
    str d0, [sp, #616]
    ldr d0, [sp, #616]
    ldr d1, [sp, #496]
    fadd d0, d0, d1
    str d0, [sp, #616]
    ldr d0, [sp, #616]
    ldr d1, [sp, #496]
    fdiv d0, d0, d1
    str d0, [sp, #624]
    ldr d0, [sp, #624]
    bl log
    str d0, [sp, #632]
    ldr d0, [sp, #616]
    ldr d1, [sp, #504]
    fdiv d0, d0, d1
    str d0, [sp, #640]
    ldr d0, [sp, #640]
    bl log
    str d0, [sp, #648]
    ldr d0, [sp, #616]
    ldr d1, [sp, #512]
    fdiv d0, d0, d1
    str d0, [sp, #656]
    ldr d0, [sp, #656]
    bl log
    str d0, [sp, #664]
    ldr d0, [sp, #624]
    adrp x9, .Lsurface_value4
    ldr d1, [x9, :lo12:.Lsurface_value4]
    fsub d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #624]
    ldr d1, [sp, #592]
    fdiv d0, d0, d1
    str d0, [sp, #672]
    adrp x9, .Lsurface_value4
    ldr d0, [x9, :lo12:.Lsurface_value4]
    ldr d1, [sp, #624]
    fdiv d0, d0, d1
    str d0, [sp, #680]
    adrp x9, .Lsurface_value4
    ldr d0, [x9, :lo12:.Lsurface_value4]
    ldr d1, [sp, #640]
    fdiv d0, d0, d1
    str d0, [sp, #688]
    ldr x9, [sp, #200]
    ldr w9, [x9]
    cbz w9, .Lsurface_continuing
    ldr d0, [sp, #608]
    ldr d1, [sp, #632]
    fmul d0, d0, d1
    str d0, [sp, #696]
    ldr d0, [sp, #696]
    ldr d1, [sp, #648]
    fdiv d0, d0, d1
    str d0, [sp, #696]
    ldr d0, [sp, #608]
    fcmp d0, #0.0
    b.le .Lsurface_unstable_guess
    ldr d0, [sp, #696]
    adrp x9, :got:__yos_excs_MOD_dritbl
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_dritbl]
    ldr d1, [x9]
    fdiv d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    fcvtzs w9, d0
    add w9, w9, #1
    cmp w9, #101
    b.ge .Lsurface_guess_tail
    scvtf d0, w9
    str d0, [sp, #704]
    adrp x10, :got:__yos_excs_MOD_ritbl
    ldr x10, [x10, :got_lo12:__yos_excs_MOD_ritbl]
    sub w9, w9, #1
    ldr d0, [x10, x9, lsl #3]
    str d0, [sp, #712]
    add w9, w9, #1
    ldr d0, [x10, x9, lsl #3]
    str d0, [sp, #720]
    ldr d0, [sp, #704]
    adrp x9, :got:__yos_excs_MOD_dritbl
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_dritbl]
    ldr d1, [x9]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    ldr d1, [sp, #696]
    fsub d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    adrp x9, :got:__yos_excs_MOD_dritbl
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_dritbl]
    ldr d1, [x9]
    fdiv d0, d0, d1
    str d0, [sp, #728]
    adrp x9, .Lsurface_value4
    ldr d0, [x9, :lo12:.Lsurface_value4]
    ldr d1, [sp, #728]
    fsub d0, d0, d1
    str d0, [sp, #736]
    ldr d0, [sp, #728]
    ldr d1, [sp, #712]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #736]
    ldr d1, [sp, #720]
    fmul d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #560]
    ldr d1, [sp, #592]
    fadd d0, d0, d1
    str d0, [sp, #744]
    b .Lsurface_guess_ready
.Lsurface_guess_tail:
    adrp x9, :got:__yos_excs_MOD_ritbl
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_ritbl]
    ldr d0, [x9, #800]
    str d0, [sp, #744]
    b .Lsurface_guess_ready
.Lsurface_unstable_guess:
    ldr d0, [sp, #696]
    str d0, [sp, #744]
.Lsurface_guess_ready:
    ldr d0, [sp, #744]
    ldr d1, [sp, #632]
    fmul d0, d0, d1
    str d0, [sp, #752]
    ldr d0, [sp, #752]
    ldr d1, [sp, #672]
    fmul d0, d0, d1
    str d0, [sp, #752]
    b .Lsurface_first_ready
.Lsurface_continuing:
    ldr d0, [sp, #520]
    str d0, [sp, #752]
.Lsurface_first_ready:
    ldr d0, [sp, #752]
    ldr d1, [sp, #752]
    fcmp d1, #0.0
    b.gt .Lsurface_psi1stable
    bl .Lsurface_psihu
    b .Lsurface_psi1done
.Lsurface_psi1stable:
    bl .Lsurface_psihs
.Lsurface_psi1done:
    str d0, [sp, #760]
    ldr d0, [sp, #752]
    ldr d1, [sp, #688]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    ldr d1, [sp, #752]
    fcmp d1, #0.0
    b.gt .Lsurface_psi2stable
    bl .Lsurface_psihu
    b .Lsurface_psi2done
.Lsurface_psi2stable:
    bl .Lsurface_psihs
.Lsurface_psi2done:
    str d0, [sp, #768]
    ldr d0, [sp, #752]
    ldr d1, [sp, #752]
    fcmp d1, #0.0
    b.gt .Lsurface_psi3stable
    bl .Lsurface_psimu
    b .Lsurface_psi3done
.Lsurface_psi3stable:
    bl .Lsurface_psims
.Lsurface_psi3done:
    str d0, [sp, #776]
    ldr d0, [sp, #752]
    ldr d1, [sp, #680]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    ldr d1, [sp, #752]
    fcmp d1, #0.0
    b.gt .Lsurface_psi4stable
    bl .Lsurface_psimu
    b .Lsurface_psi4done
.Lsurface_psi4stable:
    bl .Lsurface_psims
.Lsurface_psi4done:
    str d0, [sp, #784]
    ldr d0, [sp, #648]
    ldr d1, [sp, #760]
    fsub d0, d0, d1
    str d0, [sp, #792]
    ldr d0, [sp, #792]
    ldr d1, [sp, #768]
    fadd d0, d0, d1
    str d0, [sp, #792]
    ldr d0, [sp, #632]
    ldr d1, [sp, #776]
    fsub d0, d0, d1
    str d0, [sp, #800]
    ldr d0, [sp, #800]
    ldr d1, [sp, #784]
    fadd d0, d0, d1
    str d0, [sp, #800]
    ldr d0, [sp, #800]
    ldr d1, [sp, #800]
    fmul d0, d0, d1
    str d0, [sp, #808]
    ldr d0, [sp, #808]
    ldr d1, [sp, #672]
    fmul d0, d0, d1
    str d0, [sp, #808]
    ldr d0, [sp, #808]
    ldr d1, [sp, #792]
    fdiv d0, d0, d1
    str d0, [sp, #808]
    ldr d0, [sp, #608]
    ldr d1, [sp, #808]
    fmul d0, d0, d1
    str d0, [sp, #816]
    ldr d0, [sp, #752]
    ldr d1, [sp, #808]
    fdiv d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #608]
    ldr d1, [sp, #560]
    fsub d0, d0, d1
    str d0, [sp, #824]
    ldr x9, [sp, #184]
    ldr w22, [x9]
    cbz w22, .Lsurface_iterations_done
.Lsurface_iteration:
    ldr d0, [sp, #816]
    ldr d1, [sp, #816]
    fcmp d1, #0.0
    b.gt .Lsurface_psi5stable
    bl .Lsurface_psihu
    b .Lsurface_psi5done
.Lsurface_psi5stable:
    bl .Lsurface_psihs
.Lsurface_psi5done:
    str d0, [sp, #760]
    ldr d0, [sp, #816]
    ldr d1, [sp, #688]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    ldr d1, [sp, #816]
    fcmp d1, #0.0
    b.gt .Lsurface_psi6stable
    bl .Lsurface_psihu
    b .Lsurface_psi6done
.Lsurface_psi6stable:
    bl .Lsurface_psihs
.Lsurface_psi6done:
    str d0, [sp, #768]
    ldr d0, [sp, #816]
    ldr d1, [sp, #816]
    fcmp d1, #0.0
    b.gt .Lsurface_psi7stable
    bl .Lsurface_psimu
    b .Lsurface_psi7done
.Lsurface_psi7stable:
    bl .Lsurface_psims
.Lsurface_psi7done:
    str d0, [sp, #776]
    ldr d0, [sp, #816]
    ldr d1, [sp, #680]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    ldr d1, [sp, #816]
    fcmp d1, #0.0
    b.gt .Lsurface_psi8stable
    bl .Lsurface_psimu
    b .Lsurface_psi8done
.Lsurface_psi8stable:
    bl .Lsurface_psims
.Lsurface_psi8done:
    str d0, [sp, #784]
    ldr d0, [sp, #648]
    ldr d1, [sp, #760]
    fsub d0, d0, d1
    str d0, [sp, #792]
    ldr d0, [sp, #792]
    ldr d1, [sp, #768]
    fadd d0, d0, d1
    str d0, [sp, #792]
    ldr d0, [sp, #632]
    ldr d1, [sp, #776]
    fsub d0, d0, d1
    str d0, [sp, #800]
    ldr d0, [sp, #800]
    ldr d1, [sp, #784]
    fadd d0, d0, d1
    str d0, [sp, #800]
    ldr d0, [sp, #816]
    ldr d1, [sp, #792]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #800]
    ldr d1, [sp, #800]
    fmul d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #672]
    ldr d1, [sp, #592]
    fmul d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #560]
    ldr d1, [sp, #592]
    fdiv d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #608]
    ldr d1, [sp, #560]
    fsub d0, d0, d1
    str d0, [sp, #832]
    ldr d0, [sp, #832]
    ldr d1, [sp, #824]
    fsub d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #592]
    fabs d0, d0
    adrp x9, .Lsurface_value5
    ldr d1, [x9, :lo12:.Lsurface_value5]
    fcmp d0, d1
    b.le .Lsurface_flat_secant
    ldr d0, [sp, #816]
    ldr d1, [sp, #752]
    fsub d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #824]
    ldr d1, [sp, #560]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    ldr d1, [sp, #592]
    fdiv d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #752]
    ldr d1, [sp, #560]
    fsub d0, d0, d1
    str d0, [sp, #840]
    b .Lsurface_secant_ready
.Lsurface_flat_secant:
    ldr d0, [sp, #816]
    str d0, [sp, #840]
.Lsurface_secant_ready:
    ldr d0, [sp, #840]
    ldr d1, [sp, #816]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    fcmp d0, #0.0
    b.ge .Lsurface_sign_ready
    ldr d0, [sp, #816]
    adrp x9, .Lsurface_value6
    ldr d1, [x9, :lo12:.Lsurface_value6]
    fmul d0, d0, d1
    str d0, [sp, #840]
.Lsurface_sign_ready:
    ldr d0, [sp, #816]
    str d0, [sp, #752]
    ldr d0, [sp, #832]
    str d0, [sp, #824]
    ldr d0, [sp, #840]
    str d0, [sp, #816]
    subs w22, w22, #1
    b.ne .Lsurface_iteration
.Lsurface_iterations_done:
    ldr d0, [sp, #816]
    ldr x9, [sp, #304]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    str d0, [x10, x12, lsl #3]
    ldr d0, [sp, #816]
    adrp x9, :got:__yos_excs_MOD_rchbhdl
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchbhdl]
    ldr d1, [x9]
    fcmp d0, d1
    b.le .Lsurface_height_ready
    ldr d0, [sp, #616]
    ldr d1, [sp, #816]
    fdiv d0, d0, d1
    str d0, [sp, #848]
    adrp x9, :got:__yos_excs_MOD_rchbhdl
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchbhdl]
    ldr d0, [x9]
    ldr d1, [sp, #848]
    fmul d0, d0, d1
    str d0, [sp, #616]
    ldr d0, [sp, #496]
    ldr d1, [sp, #512]
    fmax d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #616]
    ldr d1, [sp, #560]
    fadd d0, d0, d1
    str d0, [sp, #616]
    ldr d0, [sp, #616]
    ldr d1, [sp, #848]
    fdiv d0, d0, d1
    str d0, [sp, #816]
    ldr d0, [sp, #616]
    ldr d1, [sp, #496]
    fdiv d0, d0, d1
    str d0, [sp, #624]
    ldr d0, [sp, #624]
    bl log
    str d0, [sp, #632]
    ldr d0, [sp, #616]
    ldr d1, [sp, #504]
    fdiv d0, d0, d1
    str d0, [sp, #640]
    ldr d0, [sp, #640]
    bl log
    str d0, [sp, #648]
    ldr d0, [sp, #616]
    ldr d1, [sp, #512]
    fdiv d0, d0, d1
    str d0, [sp, #656]
    ldr d0, [sp, #656]
    bl log
    str d0, [sp, #664]
.Lsurface_height_ready:
    adrp x9, .Lsurface_value4
    ldr d0, [x9, :lo12:.Lsurface_value4]
    ldr d1, [sp, #624]
    fdiv d0, d0, d1
    str d0, [sp, #680]
    adrp x9, .Lsurface_value4
    ldr d0, [x9, :lo12:.Lsurface_value4]
    ldr d1, [sp, #640]
    fdiv d0, d0, d1
    str d0, [sp, #688]
    adrp x9, .Lsurface_value4
    ldr d0, [x9, :lo12:.Lsurface_value4]
    ldr d1, [sp, #656]
    fdiv d0, d0, d1
    str d0, [sp, #856]
    ldr d0, [sp, #816]
    ldr d1, [sp, #816]
    fcmp d1, #0.0
    b.gt .Lsurface_psi9stable
    bl .Lsurface_psihu
    b .Lsurface_psi9done
.Lsurface_psi9stable:
    bl .Lsurface_psihs
.Lsurface_psi9done:
    str d0, [sp, #760]
    ldr d0, [sp, #816]
    ldr d1, [sp, #688]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    ldr d1, [sp, #816]
    fcmp d1, #0.0
    b.gt .Lsurface_psi10stable
    bl .Lsurface_psihu
    b .Lsurface_psi10done
.Lsurface_psi10stable:
    bl .Lsurface_psihs
.Lsurface_psi10done:
    str d0, [sp, #768]
    ldr d0, [sp, #816]
    ldr d1, [sp, #816]
    fcmp d1, #0.0
    b.gt .Lsurface_psi11stable
    bl .Lsurface_psimu
    b .Lsurface_psi11done
.Lsurface_psi11stable:
    bl .Lsurface_psims
.Lsurface_psi11done:
    str d0, [sp, #776]
    ldr d0, [sp, #816]
    ldr d1, [sp, #680]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    ldr d1, [sp, #816]
    fcmp d1, #0.0
    b.gt .Lsurface_psi12stable
    bl .Lsurface_psimu
    b .Lsurface_psi12done
.Lsurface_psi12stable:
    bl .Lsurface_psims
.Lsurface_psi12done:
    str d0, [sp, #784]
    ldr d0, [sp, #648]
    ldr d1, [sp, #760]
    fsub d0, d0, d1
    str d0, [sp, #792]
    ldr d0, [sp, #792]
    ldr d1, [sp, #768]
    fadd d0, d0, d1
    str d0, [sp, #792]
    ldr d0, [sp, #632]
    ldr d1, [sp, #776]
    fsub d0, d0, d1
    str d0, [sp, #800]
    ldr d0, [sp, #800]
    ldr d1, [sp, #784]
    fadd d0, d0, d1
    str d0, [sp, #800]
    ldr d0, [sp, #816]
    ldr d1, [sp, #856]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    ldr d1, [sp, #816]
    fcmp d1, #0.0
    b.gt .Lsurface_psi13stable
    bl .Lsurface_psihu
    b .Lsurface_psi13done
.Lsurface_psi13stable:
    bl .Lsurface_psihs
.Lsurface_psi13done:
    str d0, [sp, #864]
    ldr d0, [sp, #816]
    ldr d1, [sp, #680]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #560]
    ldr d1, [sp, #816]
    fcmp d1, #0.0
    b.gt .Lsurface_psi14stable
    bl .Lsurface_psihu
    b .Lsurface_psi14done
.Lsurface_psi14stable:
    bl .Lsurface_psihs
.Lsurface_psi14done:
    str d0, [sp, #872]
    ldr d0, [sp, #664]
    ldr d1, [sp, #760]
    fsub d0, d0, d1
    str d0, [sp, #880]
    ldr d0, [sp, #880]
    ldr d1, [sp, #864]
    fadd d0, d0, d1
    str d0, [sp, #880]
    ldr d0, [sp, #632]
    ldr d1, [sp, #760]
    fsub d0, d0, d1
    str d0, [sp, #888]
    ldr d0, [sp, #888]
    ldr d1, [sp, #872]
    fadd d0, d0, d1
    str d0, [sp, #888]
    ldr x9, [sp, #344]
    ldr d0, [x9, #32]
    ldr d1, [sp, #440]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr x9, [sp, #344]
    ldr d0, [x9, #48]
    ldr d1, [sp, #448]
    fmul d0, d0, d1
    str d0, [sp, #592]
    adrp x9, .Lsurface_value4
    ldr d0, [x9, :lo12:.Lsurface_value4]
    ldr d1, [sp, #592]
    fadd d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #560]
    ldr d1, [sp, #592]
    fmul d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #456]
    ldr d1, [sp, #592]
    fdiv d0, d0, d1
    str d0, [sp, #896]
    ldr d0, [sp, #584]
    fsqrt d0, d0
    str d0, [sp, #904]
    ldr d0, [sp, #904]
    ldr d1, [sp, #896]
    fmul d0, d0, d1
    str d0, [sp, #912]
    ldr d0, [sp, #912]
    ldr d1, [sp, #408]
    fmul d0, d0, d1
    str d0, [sp, #912]
    ldr d0, [sp, #800]
    ldr d1, [sp, #800]
    fmul d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #912]
    ldr d1, [sp, #592]
    fdiv d0, d0, d1
    str d0, [sp, #920]
    ldr d0, [sp, #800]
    ldr d1, [sp, #792]
    fmul d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #912]
    ldr d1, [sp, #592]
    fdiv d0, d0, d1
    str d0, [sp, #928]
    ldr d0, [sp, #800]
    ldr d1, [sp, #880]
    fmul d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #912]
    ldr d1, [sp, #592]
    fdiv d0, d0, d1
    str d0, [sp, #936]
    ldr d0, [sp, #928]
    ldr d1, [sp, #896]
    fdiv d0, d0, d1
    str d0, [sp, #944]
    ldr d0, [sp, #904]
    ldr d1, [sp, #408]
    fmul d0, d0, d1
    str d0, [sp, #560]
    ldr d0, [sp, #800]
    ldr d1, [sp, #888]
    fmul d0, d0, d1
    str d0, [sp, #592]
    ldr d0, [sp, #560]
    ldr d1, [sp, #592]
    fdiv d0, d0, d1
    str d0, [sp, #952]
    ldr d0, [sp, #920]
    ldr x9, [sp, #360]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    str d0, [x10, x12, lsl #3]
    ldr d0, [sp, #928]
    ldr x9, [sp, #368]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    str d0, [x10, x12, lsl #3]
    ldr d0, [sp, #936]
    ldr x9, [sp, #376]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    str d0, [x10, x12, lsl #3]
    ldr d0, [sp, #944]
    ldr x9, [sp, #384]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    str d0, [x10, x12, lsl #3]
    ldr d0, [sp, #952]
    ldr x9, [sp, #392]
    ldr x10, [x9]
    ldr x11, [x9, #40]
    sub x12, x19, #1
    mul x12, x12, x11
    str d0, [x10, x12, lsl #3]
    add w19, w19, #1
    cmp w19, w20
    b.le .Lsurface_column
.Lsurface_return:
    ldp d8, d9, [sp, #96]
    ldp d10, d11, [sp, #112]
    ldp d12, d13, [sp, #128]
    ldp d14, d15, [sp, #144]
    ldp x19, x20, [sp, #0]
    ldp x21, x22, [sp, #16]
    ldp x23, x24, [sp, #32]
    ldp x25, x26, [sp, #48]
    ldp x27, x28, [sp, #64]
    ldp x29, x30, [sp, #80]
    add sp, sp, #960
    ret
.Lsurface_bad:
    b abort
.size md2asm_surface_exchange,.-md2asm_surface_exchange
.Lsurface_psihu:
    stp x19, x30, [sp, #-64]!
    stp d8, d9, [sp, #16]
    stp d10, d11, [sp, #32]
    fmov d8, d0
    adrp x9, :got:__yos_excs_MOD_rcdhalf
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rcdhalf]
    ldr d16, [x9]
    fmul d16, d16, d8
    fmov d17, #1.0
    fsub d16, d17, d16
    fsqrt d9, d16
    fadd d0, d17, d9
    fmov d16, #0.5
    fmul d0, d0, d16
    bl log
    fadd d0, d0, d0
    ldp d10, d11, [sp, #32]
    ldp d8, d9, [sp, #16]
    ldp x19, x30, [sp], #64
    ret
.Lsurface_psimu:
    stp x19, x30, [sp, #-64]!
    stp d8, d9, [sp, #16]
    stp d10, d11, [sp, #32]
    fmov d8, d0
    adrp x9, :got:__yos_excs_MOD_rcdhalf
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rcdhalf]
    ldr d16, [x9]
    fmul d16, d16, d8
    fmov d17, #1.0
    fsub d16, d17, d16
    fsqrt d9, d16
    fsqrt d10, d9
    fadd d11, d17, d10
    fmul d11, d11, d11
    fadd d9, d17, d9
    fmul d0, d11, d9
    fmov d16, #0.125
    fmul d0, d0, d16
    bl log
    fmov d11, d0
    fmov d0, d10
    bl md2asm_atan_original_rounding
    fadd d0, d0, d0
    fsub d0, d11, d0
    adrp x9, :got:__yos_excs_MOD_rcdhpi2
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rcdhpi2]
    ldr d16, [x9]
    fadd d0, d0, d16
    ldp d10, d11, [sp, #32]
    ldp d8, d9, [sp, #16]
    ldp x19, x30, [sp], #64
    ret
.Lsurface_psihs:
    stp x19, x30, [sp, #-64]!
    stp d8, d9, [sp, #16]
    stp d10, d11, [sp, #32]
    fmov d8, d0
    adrp x9, :got:__yos_excs_MOD_rchbd
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchbd]
    ldr d16, [x9]
    fneg d16, d16
    fmul d0, d16, d8
    bl exp
    fmov d10, d0
    adrp x9, :got:__yos_excs_MOD_rchbb
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchbb]
    ldr d16, [x9]
    fneg d16, d16
    adrp x9, :got:__yos_excs_MOD_rchbcd
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchbcd]
    ldr d17, [x9]
    fsub d9, d8, d17
    fmul d9, d16, d9
    fmul d9, d9, d10
    adrp x9, :got:__yos_excs_MOD_rchb23a
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchb23a]
    ldr d16, [x9]
    fmul d10, d16, d8
    fmov d17, #1.0
    fadd d10, d17, d10
    fsqrt d11, d10
    fmul d10, d10, d11
    fsub d0, d9, d10
    adrp x9, :got:__yos_excs_MOD_rchbbcd
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchbbcd]
    ldr d16, [x9]
    fsub d0, d0, d16
    fmov d16, #1.0
    fadd d0, d0, d16
    ldp d10, d11, [sp, #32]
    ldp d8, d9, [sp, #16]
    ldp x19, x30, [sp], #64
    ret
.Lsurface_psims:
    stp x19, x30, [sp, #-64]!
    stp d8, d9, [sp, #16]
    stp d10, d11, [sp, #32]
    fmov d8, d0
    adrp x9, :got:__yos_excs_MOD_rchbd
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchbd]
    ldr d16, [x9]
    fneg d16, d16
    fmul d0, d16, d8
    bl exp
    fmov d10, d0
    adrp x9, :got:__yos_excs_MOD_rchbb
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchbb]
    ldr d16, [x9]
    fneg d16, d16
    adrp x9, :got:__yos_excs_MOD_rchbcd
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchbcd]
    ldr d17, [x9]
    fsub d9, d8, d17
    fmul d9, d16, d9
    fmul d9, d9, d10
    adrp x9, :got:__yos_excs_MOD_rchba
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchba]
    ldr d16, [x9]
    fmul d10, d16, d8
    fsub d0, d9, d10
    adrp x9, :got:__yos_excs_MOD_rchbbcd
    ldr x9, [x9, :got_lo12:__yos_excs_MOD_rchbbcd]
    ldr d16, [x9]
    fsub d0, d0, d16
    ldp d10, d11, [sp, #32]
    ldp d8, d9, [sp, #16]
    ldp x19, x30, [sp], #64
    ret
.section .rodata
.p2align 3
.Lsurface_value0:
    .quad 0x0000000000000000
.Lsurface_value1:
    .quad 0x3fe5555555555555
.Lsurface_value2:
    .quad 0x4000000000000000
.Lsurface_value3:
    .quad 0x3fb999999999999a
.Lsurface_value4:
    .quad 0x3ff0000000000000
.Lsurface_value5:
    .quad 0x3abef2d0f5da7dd9
.Lsurface_value6:
    .quad 0x3fe0000000000000
.section .note.GNU-stack,"",%progbits

/* Complete CLOUD_SATADJ, emitted directly from the ordered physics contract.
 * Physics formulations/openifs/physics/cloud_saturation_adjustment.md
 * ABI and order skills/md2asm/references/openifs/physics/cloud_satadj.md
 * Thirty-nine addresses retain the original Fortran argument order.
 * Each cell includes forcing, both adjustments, cleanup and diagnostics.
 */
.text
.p2align 4
.macro SA_PTR reg,index
    ldr \reg,[x19,#(8*\index)]
.endm
.macro SA_IN reg,index
    SA_PTR x9,\index
    ldr \reg,[x9,x26,lsl #3]
.endm
.macro SA_LOC reg,index
    ldr \reg,[sp,#(912+8*\index)]
.endm
.macro SA_SET reg,index
    str \reg,[sp,#(912+8*\index)]
.endm
.macro SA_GLOBAL offset,name
    adrp x16,:got:\name
    ldr x16,[x16,:got_lo12:\name]
    ldr d0,[x16]
    str d0,[sp,#\offset]
.endm
.macro SA_OUT index,local
    SA_LOC d0,\local
    SA_PTR x9,\index
    str d0,[x9,x26,lsl #3]
.endm
.macro SA_VERT local,level,subtract=0
    SA_LOC d0,\local
    ldr d1,[sp,#752]
    fmul d0,d0,d1
    SA_LOC d1,37
    fmul d0,d0,d1
    mov x10,#\level
    mul x10,x10,x20
    add x10,x10,x23
    ldr d1,[x9,x10,lsl #3]
    .if \subtract
    fsub d1,d1,d0
    .else
    fadd d1,d1,d0
    .endif
    str d1,[x9,x10,lsl #3]
.endm
.macro SA_DIAG local,column,subtract=0
    SA_LOC d0,\local
    ldr d1,[sp,#752]
    fmul d0,d0,d1
    add x10,x11,#\column
    mul x10,x10,x20
    mul x10,x10,x21
    add x10,x10,x26
    ldr d1,[x9,x10,lsl #3]
    .if \subtract
    fsub d1,d1,d0
    .else
    fadd d1,d1,d0
    .endif
    str d1,[x9,x10,lsl #3]
.endm
.global md2asm_cloud_satadj
.type md2asm_cloud_satadj,%function
md2asm_cloud_satadj:
    mrs x9,fpcr
    cbnz x9,.Lsa_bad
    sub sp,sp,#2048
    stp x29,x30,[sp,#128]
    stp x19,x20,[sp,#144]
    stp x21,x22,[sp,#160]
    stp x23,x24,[sp,#176]
    stp x25,x26,[sp,#192]
    stp x27,x28,[sp,#208]
    stp d8,d9,[sp,#224]
    stp d10,d11,[sp,#240]
    stp d12,d13,[sp,#256]
    stp d14,d15,[sp,#272]
    mov x29,sp
    add x19,sp,#288
    stp x0,x1,[x19,#0]
    stp x2,x3,[x19,#16]
    stp x4,x5,[x19,#32]
    stp x6,x7,[x19,#48]
    add x10,sp,#2048
    mov x11,#8
.Lsa_copy:
    ldr x9,[x10],#8
    str x9,[x19,x11,lsl #3]
    add x11,x11,#1
    cmp x11,#39
    b.lo .Lsa_copy
    SA_PTR x9,7
    ldrsw x20,[x9]
    tbnz x20,#63,.Lsa_bad_frame
    SA_PTR x9,8
    ldrsw x21,[x9]
    tbnz x21,#63,.Lsa_bad_frame
    SA_PTR x9,5
    ldrsw x24,[x9]
    sub x24,x24,#1
    tbnz x24,#63,.Lsa_bad_frame
    SA_PTR x9,6
    ldrsw x25,[x9]
    cmp x25,x20
    b.hi .Lsa_bad_frame
    cmp x24,x25
    b.hi .Lsa_bad_frame
    mov x27,x0
    mov x28,x4
    ldrsw x9,[x27,#1076]
    cmp x9,#1
    b.lt .Lsa_bad_frame
    add x10,x21,#1
    cmp x9,x10
    b.gt .Lsa_bad_frame
    sub x9,x9,#1
    str x9,[sp,#640]
    SA_PTR x9,38
    ldrsw x10,[x9]
    tbnz x10,#63,.Lsa_bad_frame
    str x10,[sp,#648]
    ldr w9,[x27,#1068]
    str x9,[sp,#864]
    ldr w9,[x27,#1048]
    str x9,[sp,#872]
    ldr w9,[x27,#1052]
    str x9,[sp,#880]
    ldr w9,[x27,#1056]
    str x9,[sp,#888]
    SA_PTR x9,3
    ldr w9,[x9,#104]
    str x9,[sp,#896]
    mov x11,#0
    cbz w9,.Lsa_diag_base
    mov x11,#26
.Lsa_diag_base:
    mov x12,#0
    ldr x9,[sp,#864]
    cbz x9,.Lsa_diag_c
    cmp x21,#43
    b.lt .Lsa_bad_frame
    mov x12,#1
    add x11,x11,#1
.Lsa_diag_c:
    ldr x9,[sp,#872]
    cbz x9,.Lsa_diag_l
    add x12,x11,#3
    add x11,x11,#12
.Lsa_diag_l:
    ldr x9,[sp,#880]
    cbz x9,.Lsa_diag_i
    add x12,x11,#4
    add x11,x11,#22
.Lsa_diag_i:
    ldr x9,[sp,#888]
    cbz x9,.Lsa_diag_end
    add x12,x11,#4
.Lsa_diag_end:
    cmp x10,x12
    b.lt .Lsa_bad_frame
    ldrsw x9,[x28,#216]
    tbnz x9,#63,.Lsa_bad_frame
    str x9,[sp,#656]
    str xzr,[sp,#728]
    str xzr,[sp,#736]
    ldr w9,[x28,#584]
    str x9,[sp,#720]
    ldr w9,[x28]
    cbz w9,.Lsa_spp_done
    ldrsw x9,[x28,#552]
    cmp x9,#0
    b.le .Lsa_spp_ram
    mov x10,#672
    bl .Lsa_parameter
    mov x9,#1
    str x9,[sp,#728]
.Lsa_spp_ram:
    ldrsw x9,[x28,#524]
    cmp x9,#0
    b.le .Lsa_spp_done
    mov x10,#696
    bl .Lsa_parameter
    mov x9,#1
    str x9,[sp,#736]
.Lsa_spp_done:
    SA_PTR x9,10
    ldr d0,[x9]
    str d0,[sp,#744]
    fmov d1,#1.0
    fdiv d0,d1,d0
    str d0,[sp,#752]
    str d1,[sp,#768]
    fmov d0,#0.5
    str d0,[sp,#776]
    ldr x9,.Lsa_eps
    str x9,[sp,#784]
    ldr d0,[x27,#120]
    str d0,[sp,#792]
    ldr d0,[x27,#112]
    str d0,[sp,#800]
    ldr d0,[x27,#224]
    str d0,[sp,#808]
    ldr d0,[x27]
    str d0,[sp,#816]
    SA_GLOBAL 824,__yomcst_MOD_rg
    SA_GLOBAL 832,__yomcst_MOD_rd
    SA_GLOBAL 840,__yomcst_MOD_rcpd
    SA_GLOBAL 848,__yoethf_MOD_ralvdcp
    SA_GLOBAL 856,__yoethf_MOD_ralsdcp
    ldr d0,[sp,#832]
    ldr d1,[sp,#840]
    fdiv d0,d0,d1
    str d0,[sp,#760]
    mov w9,#1
    str w9,[sp,#1488]
    mov w9,#2
    str w9,[sp,#1496]
    mov x22,#0
.Lsa_level:
    cmp x22,x21
    b.hs .Lsa_done
    mov x23,x24
.Lsa_cell:
    cmp x23,x25
    b.hs .Lsa_next_level
    madd x26,x22,x20,x23
    ldr x9,[sp,#640]
    cmp x22,x9
    b.hs .Lsa_active
    fmov d0,xzr
    SA_PTR x9,32
    str d0,[x9,x26,lsl #3]
    SA_PTR x9,33
    str d0,[x9,x26,lsl #3]
    SA_PTR x9,34
    str d0,[x9,x26,lsl #3]
    SA_PTR x9,35
    str d0,[x9,x26,lsl #3]
    SA_PTR x9,36
    str d0,[x9,x26,lsl #3]
    b .Lsa_next_cell
.Lsa_active:
    // Update all five material fields with cumulative tendencies.
    ldr d1,[sp,#744]
    SA_IN d0,18
    fmul d0,d1,d0
    SA_IN d2,13
    fadd d0,d2,d0
    SA_SET d0,0
    SA_IN d0,19
    fmul d0,d1,d0
    SA_IN d2,14
    fadd d0,d2,d0
    SA_SET d0,1
    SA_IN d0,20
    fmul d0,d1,d0
    SA_IN d2,15
    fadd d0,d2,d0
    ldr d2,[sp,#768]
    fmin d0,d2,d0
    fmov d2,xzr
    fmax d0,d2,d0
    SA_SET d0,2
    SA_IN d0,21
    fmul d0,d1,d0
    SA_IN d2,16
    fadd d0,d2,d0
    SA_SET d0,3
    SA_IN d0,22
    fmul d0,d1,d0
    SA_IN d2,17
    fadd d0,d2,d0
    SA_SET d0,4
    // The optional lognormal velocity multiplier is complete here.
    ldr x9,[sp,#728]
    cbz x9,.Lsa_unperturbed
    ldr x10,[sp,#688]
    madd x10,x10,x20,x23
    SA_PTR x9,31
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[sp,#680]
    fmul d0,d1,d0
    ldr d1,[sp,#672]
    fadd d0,d1,d0
    bl exp
    SA_IN d1,30
    fmul d0,d1,d0
    b .Lsa_velocity
.Lsa_unperturbed:
    SA_IN d0,30
.Lsa_velocity:
    SA_SET d0,38
    SA_PTR x9,12
    ldr d0,[x9,x26,lsl #3]
    add x10,x26,x20
    ldr d1,[x9,x10,lsl #3]
    fsub d0,d1,d0
    SA_SET d0,8
    ldr d1,[sp,#824]
    fdiv d1,d1,d0
    ldr d2,[sp,#744]
    fmul d1,d2,d1
    SA_SET d1,9
    ldr d1,[sp,#752]
    fmul d3,d0,d1
    SA_IN d0,13
    ldr d1,[sp,#760]
    fmul d0,d1,d0
    SA_IN d1,11
    fdiv d4,d0,d1
    SA_LOC d0,38
    fneg d1,d3
    fmax d0,d1,d0
    fmin d0,d3,d0
    SA_IN d1,23
    SA_IN d2,24
    fadd d1,d1,d2
    // Source negates the pressure limit before its multiplication.
    fneg d2,d3
    fmul d2,d2,d4
    fmax d1,d2,d1
    fmul d2,d3,d4
    fmin d1,d2,d1
    ldr d2,[sp,#744]
    fmul d1,d1,d2
    fmul d0,d4,d0
    fmul d0,d0,d2
    fadd d0,d0,d1
    mul x10,x20,x21
    add x11,x10,x10,lsl #1
    add x11,x11,x26
    SA_PTR x9,29
    ldr d1,[x9,x11,lsl #3]
    SA_LOC d3,9
    fmul d1,d1,d3
    fadd d0,d0,d1
    SA_IN d1,25
    fmul d1,d1,d2
    fadd d0,d0,d1
    SA_SET d0,10
    add x10,x26,x10,lsl #1
    SA_PTR x9,29
    ldr d0,[x9,x10,lsl #3]
    fmul d0,d0,d3
    SA_IN d1,26
    fmul d1,d1,d2
    fadd d0,d0,d1
    SA_SET d0,11
    // Air density, layer depth and the separately rounded reciprocal.
    SA_IN d0,13
    ldr d1,[sp,#832]
    fmul d0,d1,d0
    SA_IN d1,11
    fdiv d0,d1,d0
    ldr d2,[sp,#824]
    fmul d0,d0,d2
    SA_LOC d2,8
    fdiv d0,d2,d0
    SA_SET d0,37
    ldr d0,[sp,#768]
    fdiv d0,d0,d1
    SA_SET d0,7
    SA_LOC d0,3
    SA_LOC d1,4
    fadd d1,d0,d1
    ldr d2,[sp,#792]
    fcmp d1,d2
    b.le .Lsa_zero_fractions
    fdiv d0,d0,d1
    SA_SET d0,5
    ldr d1,[sp,#768]
    fsub d0,d1,d0
    SA_SET d0,6
    b .Lsa_fractions
.Lsa_zero_fractions:
    fmov d0,xzr
    SA_SET d0,5
    SA_SET d0,6
.Lsa_fractions:
    ldr x9,[sp,#736]
    cbz x9,.Lsa_rh_plain
    ldr x10,[sp,#712]
    madd x10,x10,x20,x23
    SA_PTR x9,31
    ldr d0,[x9,x10,lsl #3]
    ldr d1,[sp,#704]
    fmul d0,d1,d0
    ldr d1,[sp,#696]
    fadd d0,d1,d0
    bl exp
    ldr d1,[sp,#816]
    fmul d0,d1,d0
    ldr x9,[sp,#720]
    cbz x9,.Lsa_rh_sigma
    ldr d1,[sp,#768]
    fmin d0,d1,d0
    b .Lsa_rh_sigma
.Lsa_rh_plain:
    ldr d0,[sp,#816]
.Lsa_rh_sigma:
    SA_IN d1,11
    mul x10,x20,x21
    add x10,x10,x23
    SA_PTR x9,12
    ldr d2,[x9,x10,lsl #3]
    fdiv d1,d1,d2
    ldr d2,.Lsa_point8
    fcmp d1,d2
    b.le .Lsa_rh_ready
    fsub d1,d1,d2
    ldr d2,.Lsa_point2
    fdiv d1,d1,d2
    fmul d1,d1,d1
    ldr d2,[sp,#768]
    fsub d2,d2,d0
    fmul d1,d2,d1
    fadd d0,d0,d1
.Lsa_rh_ready:
    SA_SET d0,17
    SA_IN d0,13
    SA_LOC d1,7
    bl .Lsa_thermo
    SA_SET d0,12
    SA_SET d1,13
    SA_SET d2,14
    SA_LOC d0,0
    SA_LOC d1,7
    bl .Lsa_thermo
    SA_SET d0,15
    SA_SET d2,16
    SA_IN d0,13
    SA_LOC d1,10
    fadd d0,d0,d1
    ldr d1,.Lsa_160
    fmax d0,d0,d1
    SA_SET d0,40
    SA_LOC d0,12
    SA_LOC d1,11
    fadd d0,d0,d1
    SA_SET d0,41
    add x0,sp,#(912+8*40)
    add x1,sp,#(912+8*41)
    SA_PTR x2,11
    add x2,x2,x26,lsl #3
    mov x3,#0
    bl md2asm_qsatmixadj
    SA_LOC d1,41
    fsub d0,d0,d1
    SA_SET d0,18
    // Clear-air condensation and its cloud-area limit.
    fmov d0,xzr
    SA_SET d0,19
    SA_SET d0,20
    SA_SET d0,21
    SA_SET d0,23
    SA_SET d0,22
    SA_SET d0,24
    SA_SET d0,25
    SA_SET d0,47
    SA_LOC d0,18
    ldr d1,[sp,#792]
    fneg d1,d1
    fcmp d0,d1
    b.gt .Lsa_existing
    SA_IN d1,15
    ldr d2,[sp,#768]
    ldr d3,[sp,#784]
    fsub d4,d2,d3
    fcmp d1,d4
    b.ge .Lsa_existing
    SA_LOC d4,12
    fmul d4,d1,d4
    SA_IN d5,14
    fsub d4,d5,d4
    fsub d6,d2,d1
    fmax d7,d3,d6
    fdiv d4,d4,d7
    fmov d5,xzr
    fmax d4,d5,d4
    SA_LOC d5,13
    SA_LOC d7,17
    fmul d7,d7,d5
    fcmp d4,d7
    b.lt .Lsa_existing
    fcmp d4,d5
    b.ge .Lsa_existing
    fneg d7,d6
    fmul d7,d7,d0
    fsub d4,d5,d4
    fadd d4,d4,d4
    fmax d2,d4,d3
    fdiv d7,d7,d2
    fmin d7,d7,d6
    SA_SET d7,19
    fneg d2,d0
    ldr d5,[sp,#776]
    fmul d2,d2,d5
    fmul d2,d2,d7
    fmax d5,d3,d6
    fdiv d4,d4,d5
    fneg d4,d4
    fcmp d0,d4
    b.ge .Lsa_env_nonnegative
    ldr d4,[sp,#768]
    fsub d4,d1,d4
    fmul d4,d4,d0
    SA_LOC d5,13
    fsub d4,d4,d5
    SA_IN d5,14
    fadd d4,d4,d5
    fmin d2,d2,d4
.Lsa_env_nonnegative:
    fmov d5,xzr
    fmax d2,d2,d5
    ldr d4,[sp,#792]
    fcmp d2,d4
    b.lt .Lsa_env_zero
    fcmp d6,d3
    b.lt .Lsa_env_zero
    fcmp d2,#0.0
    b.ne .Lsa_env_phase
.Lsa_env_zero:
    fmov d2,xzr
    SA_SET d2,19
.Lsa_env_phase:
    SA_IN d0,13
    ldr d1,[sp,#808]
    fcmp d0,d1
    b.le .Lsa_env_ice
    SA_SET d2,20
    b .Lsa_existing
.Lsa_env_ice:
    SA_SET d2,21
.Lsa_existing:
    SA_IN d0,15
    ldr d1,[sp,#784]
    fcmp d0,d1
    b.le .Lsa_evaporation
    SA_LOC d1,18
    ldr d2,[sp,#792]
    fneg d2,d2
    fcmp d1,d2
    b.gt .Lsa_evaporation
    fneg d1,d1
    fmov d2,xzr
    fmax d1,d1,d2
    SA_LOC d3,1
    SA_LOC d4,15
    fsub d3,d3,d4
    SA_LOC d4,16
    fdiv d3,d3,d4
    fmax d3,d3,d2
    fmin d1,d1,d3
    fmul d1,d0,d1
    ldr d3,[sp,#792]
    fcmp d1,d3
    b.ge .Lsa_cld_phase
    fmov d1,xzr
.Lsa_cld_phase:
    SA_IN d0,13
    ldr d2,[sp,#808]
    fcmp d0,d2
    b.le .Lsa_cld_ice
    SA_SET d1,22
    b .Lsa_evaporation
.Lsa_cld_ice:
    SA_SET d1,23
.Lsa_evaporation:
    SA_LOC d0,18
    fcmp d0,#0.0
    b.le .Lsa_presup
    SA_LOC d1,3
    SA_LOC d2,4
    fadd d1,d1,d2
    fcmp d1,#0.0
    b.le .Lsa_presup
    SA_IN d2,15
    fmul d0,d2,d0
    fmin d0,d0,d1
    SA_LOC d1,5
    fmul d1,d1,d0
    SA_SET d1,24
    SA_LOC d1,6
    fmul d1,d1,d0
    SA_SET d1,25
.Lsa_presup:
    SA_LOC d0,22
    SA_LOC d1,20
    fadd d0,d0,d1
    SA_LOC d1,24
    fsub d0,d0,d1
    ldr d2,[sp,#848]
    fmul d0,d2,d0
    SA_LOC d2,0
    fadd d0,d2,d0
    SA_LOC d2,23
    SA_LOC d3,21
    fadd d2,d2,d3
    SA_LOC d3,25
    fsub d2,d2,d3
    ldr d4,[sp,#856]
    fmul d2,d4,d2
    fadd d0,d0,d2
    SA_SET d0,26
    SA_LOC d0,24
    SA_LOC d1,22
    fsub d0,d0,d1
    SA_LOC d1,20
    fsub d0,d0,d1
    SA_LOC d1,1
    fadd d0,d1,d0
    SA_LOC d1,25
    SA_LOC d2,23
    fsub d1,d1,d2
    SA_LOC d2,21
    fsub d1,d1,d2
    fadd d0,d0,d1
    SA_SET d0,27
    SA_LOC d0,2
    SA_LOC d1,19
    fadd d0,d0,d1
    SA_LOC d1,47
    fsub d0,d0,d1
    ldr d1,[sp,#768]
    fmin d0,d0,d1
    ldr d1,[sp,#800]
    fcmp d0,d1
    b.ge .Lsa_presup_cloud
    fmov d0,xzr
.Lsa_presup_cloud:
    SA_SET d0,28
    // Complete mode-two child returns all five diagnostic owners.
    mov x0,x27
    add x1,sp,#1488
    mov x2,x1
    mov x3,x1
    SA_PTR x4,8
    add x5,sp,#1496
    add x6,sp,#(912+8*26)
    add x7,sp,#(912+8*27)
    add x9,sp,#(912+8*28)
    str x9,[sp,#0]
    SA_PTR x9,11
    add x9,x9,x26,lsl #3
    str x9,[sp,#8]
    SA_PTR x9,12
    mul x10,x20,x21
    add x10,x10,x23
    add x9,x9,x10,lsl #3
    str x9,[sp,#16]
    add x9,sp,#(912+8*40)
    str x9,[sp,#24]
    add x9,sp,#(912+8*41)
    str x9,[sp,#32]
    add x9,sp,#(912+8*42)
    str x9,[sp,#40]
    add x9,sp,#(912+8*43)
    str x9,[sp,#48]
    add x9,sp,#(912+8*44)
    str x9,[sp,#56]
    bl md2asm_cloud_supersatcheck
    SA_LOC d0,43
    SA_LOC d1,44
    fadd d0,d0,d1
    SA_LOC d1,26
    ldr d2,[sp,#808]
    fcmp d1,d2
    b.le .Lsa_sup_ice
    SA_SET d0,29
    fmov d0,xzr
    SA_SET d0,30
    b .Lsa_sup_cover
.Lsa_sup_ice:
    SA_SET d0,30
    fmov d0,xzr
    SA_SET d0,29
.Lsa_sup_cover:
    SA_LOC d0,42
    SA_SET d0,31
    // Form each tendency with its original left-to-right dependencies.
    SA_LOC d0,22
    SA_LOC d1,20
    fadd d0,d0,d1
    SA_LOC d1,29
    fadd d0,d0,d1
    SA_LOC d1,24
    fsub d0,d0,d1
    SA_SET d0,45
    ldr d2,[sp,#752]
    fmul d1,d0,d2
    SA_SET d1,32
    ldr d1,[sp,#848]
    fmul d0,d1,d0
    fmul d0,d0,d2
    SA_LOC d1,23
    SA_LOC d3,21
    fadd d1,d1,d3
    SA_LOC d3,30
    fadd d1,d1,d3
    SA_LOC d3,25
    fsub d1,d1,d3
    SA_SET d1,46
    fmul d3,d1,d2
    SA_SET d3,33
    ldr d3,[sp,#856]
    fmul d1,d3,d1
    fmul d1,d1,d2
    fadd d0,d0,d1
    SA_SET d0,35
    SA_LOC d0,24
    SA_LOC d1,22
    fsub d0,d0,d1
    SA_LOC d1,20
    fsub d0,d0,d1
    SA_LOC d1,29
    fsub d0,d0,d1
    SA_LOC d1,25
    fadd d0,d0,d1
    SA_LOC d1,23
    fsub d0,d0,d1
    SA_LOC d1,21
    fsub d0,d0,d1
    SA_LOC d1,30
    fsub d0,d0,d1
    fmul d0,d0,d2
    SA_SET d0,34
    SA_LOC d0,2
    SA_LOC d1,19
    fadd d0,d0,d1
    SA_LOC d1,47
    fsub d0,d0,d1
    SA_LOC d1,31
    fadd d0,d0,d1
    ldr d1,[sp,#768]
    fmin d0,d0,d1
    ldr d1,[sp,#800]
    fcmp d0,d1
    b.ge .Lsa_final_cover
    fmov d0,xzr
.Lsa_final_cover:
    SA_LOC d1,2
    fsub d0,d0,d1
    fmul d0,d0,d2
    SA_SET d0,36
    // Preserve the source's small-negative cleanup and reject warning states.
    SA_LOC d0,32
    ldr d1,[sp,#744]
    fmul d0,d0,d1
    SA_LOC d1,3
    fadd d0,d1,d0
    ldr d1,[sp,#792]
    fneg d1,d1
    fcmp d0,d1
    b.lt .Lsa_bad_frame
    fcmp d0,#0.0
    b.ge .Lsa_clean_ice
    SA_LOC d1,32
    fsub d1,d1,d0
    SA_SET d1,32
    SA_LOC d1,34
    fadd d1,d1,d0
    SA_SET d1,34
    ldr d1,[sp,#848]
    fmul d0,d1,d0
    SA_LOC d1,35
    fsub d1,d1,d0
    SA_SET d1,35
.Lsa_clean_ice:
    SA_LOC d0,33
    ldr d1,[sp,#744]
    fmul d0,d0,d1
    SA_LOC d1,4
    fadd d0,d1,d0
    ldr d1,[sp,#792]
    fneg d1,d1
    fcmp d0,d1
    b.lt .Lsa_bad_frame
    fcmp d0,#0.0
    b.ge .Lsa_store
    SA_LOC d1,33
    fsub d1,d1,d0
    SA_SET d1,33
    SA_LOC d1,34
    fadd d1,d1,d0
    SA_SET d1,34
    ldr d1,[sp,#856]
    fmul d0,d1,d0
    SA_LOC d1,35
    fsub d1,d1,d0
    SA_SET d1,35
.Lsa_store:
    SA_OUT 32,35
    SA_OUT 33,34
    SA_OUT 34,36
    SA_OUT 35,32
    SA_OUT 36,33
    // Budget accumulation retains level order and signed zero operations.
    SA_PTR x9,37
    ldr x11,[sp,#896]
    cmp x11,#0
    mov x11,#0
    b.eq .Lsa_bud_vert
    mov x11,#26
.Lsa_bud_vert:
    ldr x10,[sp,#864]
    cbz x10,.Lsa_bud_c
    SA_VERT 19,0
    SA_VERT 47,1
    SA_VERT 31,2
    SA_VERT 20,14
    SA_VERT 22,15
    SA_VERT 24,16,1
    SA_VERT 29,17
    SA_VERT 21,39
    SA_VERT 23,40
    SA_VERT 25,41,1
    SA_VERT 30,42
    add x11,x11,#1
.Lsa_bud_c:
    ldr x10,[sp,#872]
    cbz x10,.Lsa_bud_l
    SA_DIAG 19,0
    SA_DIAG 47,1
    SA_DIAG 31,2
    add x11,x11,#12
.Lsa_bud_l:
    ldr x10,[sp,#880]
    cbz x10,.Lsa_bud_i
    SA_DIAG 20,0
    SA_DIAG 22,1
    SA_DIAG 24,2,1
    SA_DIAG 29,3
    add x11,x11,#22
.Lsa_bud_i:
    ldr x10,[sp,#888]
    cbz x10,.Lsa_next_cell
    SA_DIAG 21,0
    SA_DIAG 23,1
    SA_DIAG 25,2,1
    SA_DIAG 30,3
.Lsa_next_cell:
    add x23,x23,#1
    b .Lsa_cell
.Lsa_next_level:
    add x22,x22,#1
    b .Lsa_level
.Lsa_done:
    ldp d8,d9,[sp,#224]
    ldp d10,d11,[sp,#240]
    ldp d12,d13,[sp,#256]
    ldp d14,d15,[sp,#272]
    ldp x27,x28,[sp,#208]
    ldp x25,x26,[sp,#192]
    ldp x23,x24,[sp,#176]
    ldp x21,x22,[sp,#160]
    ldp x19,x20,[sp,#144]
    ldp x29,x30,[sp,#128]
    add sp,sp,#2048
    ret
.Lsa_bad_frame:
    bl abort
    brk #0
.Lsa_bad:
    b abort
// Copy just the three fields actually consumed from one complete PN owner.
// x9 is the one-based parameter index and x10 is its frame destination.
.Lsa_parameter:
    ldr x11,[x28,#400]
    cmp x9,x11
    b.lt .Lsa_bad_frame
    ldr x11,[x28,#408]
    cmp x9,x11
    b.gt .Lsa_bad_frame
    ldr x11,[x28,#368]
    cmp x11,#184
    b.ne .Lsa_bad_frame
    ldr x11,[x28,#392]
    mul x11,x9,x11
    ldr x12,[x28,#360]
    add x11,x11,x12
    ldr x12,[x28,#384]
    mul x11,x11,x12
    ldr x12,[x28,#352]
    add x11,x12,x11
    ldrsw x12,[x11,#136]
    cmp x12,#1
    b.lt .Lsa_bad_frame
    ldr x13,[sp,#656]
    cmp x12,x13
    b.gt .Lsa_bad_frame
    sub x12,x12,#1
    ldr d0,[x11,#56]
    ldr d1,[x11,#24]
    add x11,sp,x10
    stp d0,d1,[x11]
    str x12,[x11,#16]
    ret
.size md2asm_cloud_satadj,.-md2asm_cloud_satadj
.p2align 4
// Parent thermodynamics use multiplication by the rounded pressure reciprocal.
// d0 is temperature, d1 is reciprocal pressure, outputs are qmix, qclear and h.
.macro ST_GLOBAL offset,name
    adrp x16,:got:\name
    ldr x16,[x16,:got_lo12:\name]
    ldr d0,[x16]
    str d0,[sp,#\offset]
.endm
.Lsa_thermo:
    sub sp,sp,#224
    stp x29,x30,[sp,#0]
    stp d8,d9,[sp,#16]
    stp d10,d11,[sp,#32]
    stp d12,d13,[sp,#48]
    stp d14,d15,[sp,#64]
    fmov d8,d0
    fmov d12,d1
    fmov d13,#1.0
    fmov d14,#0.5
    ST_GLOBAL 80,__yomcst_MOD_rtt
    ST_GLOBAL 88,__yoethf_MOD_r3les
    ST_GLOBAL 96,__yoethf_MOD_r4les
    ST_GLOBAL 104,__yoethf_MOD_r3ies
    ST_GLOBAL 112,__yoethf_MOD_r4ies
    ST_GLOBAL 120,__yoethf_MOD_rtwat
    ST_GLOBAL 128,__yoethf_MOD_rtice
    ST_GLOBAL 136,__yoethf_MOD_rtwat_rtice_r
    ST_GLOBAL 144,__yomcst_MOD_retv
    ST_GLOBAL 152,__yoethf_MOD_rkoop1
    ST_GLOBAL 160,__yoethf_MOD_rkoop2
    ST_GLOBAL 168,__yoethf_MOD_r5alvcp
    ST_GLOBAL 176,__yoethf_MOD_r5alscp
    adrp x16,:got:__yoethf_MOD_r2es
    ldr x16,[x16,:got_lo12:__yoethf_MOD_r2es]
    ldr d15,[x16]
    ldr d0,[sp,#120]
    fmin d9,d0,d8
    ldr d0,[sp,#128]
    fmax d9,d0,d9
    fsub d9,d9,d0
    ldr d0,[sp,#136]
    fmul d9,d9,d0
    fmul d9,d9,d9
    fmin d9,d13,d9
    ldr d1,[sp,#80]
    fsub d0,d8,d1
    ldp d1,d2,[sp,#88]
    fmul d0,d1,d0
    fsub d2,d8,d2
    fdiv d0,d0,d2
    bl exp
    fmov d10,d0
    ldr d1,[sp,#80]
    fsub d0,d8,d1
    ldp d1,d2,[sp,#104]
    fmul d0,d1,d0
    fsub d2,d8,d2
    fdiv d0,d0,d2
    bl exp
    fmov d11,d0
    fmul d0,d15,d10
    fmul d0,d0,d12
    fmin d0,d14,d0
    str d0,[sp,#184]
    ldr d1,[sp,#80]
    fcmp d8,d1
    fcsel d1,d10,d11,ge
    fmul d1,d15,d1
    fmul d1,d1,d12
    fmin d1,d14,d1
    ldr d2,[sp,#160]
    fmul d2,d2,d8
    ldr d3,[sp,#152]
    fsub d2,d3,d2
    fmul d1,d1,d2
    fmin d1,d1,d0
    ldr d2,[sp,#144]
    fmul d2,d2,d1
    fsub d2,d13,d2
    fdiv d1,d1,d2
    str d1,[sp,#200]
    fmul d0,d9,d10
    fsub d1,d13,d9
    fmul d1,d1,d11
    fadd d0,d0,d1
    fmul d0,d15,d0
    fmul d0,d0,d12
    fmin d0,d14,d0
    ldr d1,[sp,#144]
    fmul d1,d1,d0
    fsub d1,d13,d1
    fdiv d1,d13,d1
    fmul d2,d0,d1
    str d2,[sp,#208]
    ldr d0,[sp,#200]
    fadd d0,d0,d2
    fmul d0,d14,d0
    str d0,[sp,#192]
    ldr d3,[sp,#96]
    fsub d3,d8,d3
    fmul d3,d3,d3
    fdiv d3,d13,d3
    ldr d4,[sp,#168]
    fmul d4,d9,d4
    fmul d3,d4,d3
    ldr d4,[sp,#112]
    fsub d4,d8,d4
    fmul d4,d4,d4
    fdiv d4,d13,d4
    fsub d5,d13,d9
    ldr d6,[sp,#176]
    fmul d5,d5,d6
    fmul d4,d5,d4
    fadd d3,d3,d4
    fmul d1,d2,d1
    fmul d1,d1,d3
    fadd d2,d13,d1
    ldr d0,[sp,#208]
    ldr d1,[sp,#192]
    ldp d14,d15,[sp,#64]
    ldp d12,d13,[sp,#48]
    ldp d10,d11,[sp,#32]
    ldp d8,d9,[sp,#16]
    ldp x29,x30,[sp,#0]
    add sp,sp,#224
    ret
.p2align 3
.Lsa_eps: .quad 0x3d06849b86a12b9b
.Lsa_point8: .double 0.8
.Lsa_point2: .double 0.2
.Lsa_160: .double 160.0
.section .note.GNU-stack,"",%progbits

/* Complete direct slow-physics averaging.
 * Physics formulations/openifs/physics/physics_increment.md and cloud_supersaturation.md
 * Contract skills/md2asm/references/openifs/physics/sltend.md
 * Fifty original addresses and one read-only scalar-context address.
 * One-level scratch retains every original rounded operation and owner sum.
 */
.text
.p2align 4
.macro SL_PTR reg,index
    ldr \reg,[x19,#(64+8*\index)]
.endm
.macro SL_MODEL reg,offset
    ldr x9,=\offset
    ldr \reg,[x20,x9]
.endm
.macro SL_LOAD dest,index,plane=0
    SL_PTR x9,\index
.if \plane
    mov x10,#\plane
    madd x9,x10,x24,x9
.endif
    ldr \dest,[x9,x15,lsl #3]
.endm
.macro SL_STORE value,index,plane=0
    SL_PTR x9,\index
.if \plane
    mov x10,#\plane
    madd x9,x10,x24,x9
.endif
    str \value,[x9,x15,lsl #3]
.endm
.global md2asm_sltend
.type md2asm_sltend,%function
md2asm_sltend:
    mrs x9,fpcr
    cbnz x9,.Lsl_bad
    mov x17,sp
    sub sp,sp,#1024
    add x16,sp,#480
    stp x19,x20,[x16,#0]
    stp x21,x22,[x16,#16]
    stp x23,x24,[x16,#32]
    stp x25,x26,[x16,#48]
    stp x27,x28,[x16,#64]
    stp x29,x30,[x16,#80]
    stp d8,d9,[x16,#96]
    stp d10,d11,[x16,#112]
    stp d12,d13,[x16,#128]
    stp d14,d15,[x16,#144]
    str x18,[sp,#640]
    stp x0,x1,[sp,#64]
    stp x2,x3,[sp,#80]
    stp x4,x5,[sp,#96]
    stp x6,x7,[sp,#112]
    ldr x9,[x17,#0]
    str x9,[sp,#128]
    ldr x9,[x17,#8]
    str x9,[sp,#136]
    ldr x9,[x17,#16]
    str x9,[sp,#144]
    ldr x9,[x17,#24]
    str x9,[sp,#152]
    ldr x9,[x17,#32]
    str x9,[sp,#160]
    ldr x9,[x17,#40]
    str x9,[sp,#168]
    ldr x9,[x17,#48]
    str x9,[sp,#176]
    ldr x9,[x17,#56]
    str x9,[sp,#184]
    ldr x9,[x17,#64]
    str x9,[sp,#192]
    ldr x9,[x17,#72]
    str x9,[sp,#200]
    ldr x9,[x17,#80]
    str x9,[sp,#208]
    ldr x9,[x17,#88]
    str x9,[sp,#216]
    ldr x9,[x17,#96]
    str x9,[sp,#224]
    ldr x9,[x17,#104]
    str x9,[sp,#232]
    ldr x9,[x17,#112]
    str x9,[sp,#240]
    ldr x9,[x17,#120]
    str x9,[sp,#248]
    ldr x9,[x17,#128]
    str x9,[sp,#256]
    ldr x9,[x17,#136]
    str x9,[sp,#264]
    ldr x9,[x17,#144]
    str x9,[sp,#272]
    ldr x9,[x17,#152]
    str x9,[sp,#280]
    ldr x9,[x17,#160]
    str x9,[sp,#288]
    ldr x9,[x17,#168]
    str x9,[sp,#296]
    ldr x9,[x17,#176]
    str x9,[sp,#304]
    ldr x9,[x17,#184]
    str x9,[sp,#312]
    ldr x9,[x17,#192]
    str x9,[sp,#320]
    ldr x9,[x17,#200]
    str x9,[sp,#328]
    ldr x9,[x17,#208]
    str x9,[sp,#336]
    ldr x9,[x17,#216]
    str x9,[sp,#344]
    ldr x9,[x17,#224]
    str x9,[sp,#352]
    ldr x9,[x17,#232]
    str x9,[sp,#360]
    ldr x9,[x17,#240]
    str x9,[sp,#368]
    ldr x9,[x17,#248]
    str x9,[sp,#376]
    ldr x9,[x17,#256]
    str x9,[sp,#384]
    ldr x9,[x17,#264]
    str x9,[sp,#392]
    ldr x9,[x17,#272]
    str x9,[sp,#400]
    ldr x9,[x17,#280]
    str x9,[sp,#408]
    ldr x9,[x17,#288]
    str x9,[sp,#416]
    ldr x9,[x17,#296]
    str x9,[sp,#424]
    ldr x9,[x17,#304]
    str x9,[sp,#432]
    ldr x9,[x17,#312]
    str x9,[sp,#440]
    ldr x9,[x17,#320]
    str x9,[sp,#448]
    ldr x9,[x17,#328]
    str x9,[sp,#456]
    ldr x9,[x17,#336]
    str x9,[sp,#464]
    mov x19,sp
    mov x29,sp
    mov x20,x0
    cbz x20,.Lsl_bad
    tst x20,#7
    b.ne .Lsl_bad
    SL_PTR x9,1
    ldr w9,[x9]
    cmp w9,#1
    b.ne .Lsl_bad
    SL_PTR x9,3
    ldrsw x21,[x9]
    cmp x21,#4096
    b.hi .Lsl_bad
    SL_PTR x9,4
    ldrsw x22,[x9]
    cmp x22,#512
    b.hi .Lsl_bad
    SL_PTR x9,2
    ldrsw x25,[x9]
    cmp x25,x21
    b.hi .Lsl_bad
    SL_PTR x9,5
    ldrsw x10,[x9]
    cmp x10,#3
    b.lt .Lsl_bad
    cmp x10,#64
    b.gt .Lsl_bad
    str x10,[x19,#664]
    SL_PTR x9,49
    ldrsw x10,[x9]
    cmp x10,#128
    b.hi .Lsl_bad
    str x10,[x19,#672]
    mul x23,x21,x22
    lsl x24,x23,#3
    SL_MODEL w10,264
    cmp w10,#64
    b.hi .Lsl_bad
    uxtw x10,w10
    str x10,[x19,#656]
    SL_PTR x11,50
    cbz x11,.Lsl_bad
    tst x11,#7
    b.ne .Lsl_bad
    ldr w9,[x11,#4]
    cmp w9,#5
    b.ne .Lsl_bad
    ldr w9,[x11,#8]
    cmp w9,#1
    b.ne .Lsl_bad
    ldr w9,[x11,#12]
    cmp w9,#2
    b.ne .Lsl_bad
    ldr w9,[x11,#16]
    cmp w9,#3
    b.ne .Lsl_bad
    ldr w9,[x11,#20]
    cmp w9,#4
    b.ne .Lsl_bad
    ldr d13,[x11,#24]
    ldr d14,[x11,#32]
    fcmp d13,#0.0
    b.vs .Lsl_bad
    b.le .Lsl_bad
    fcmp d14,#0.0
    b.vs .Lsl_bad
    b.le .Lsl_bad
    ldr w12,[x11]
    SL_MODEL w10,1359328
    fmov d10,#1.0
    cmp w10,w12
    b.ne .Lsl_have_step
    fmov d10,xzr
.Lsl_have_step:
    fneg d10,d10
    SL_MODEL d9,4150016
    fcmp d9,#0.0
    b.vs .Lsl_bad
    b.le .Lsl_bad
    fmov d0,#1.0
    fdiv d8,d0,d9
    SL_MODEL w10,1579676
    cmp w10,#1
    b.lt .Lsl_bad
    add w11,w22,#1
    cmp w10,w11
    b.gt .Lsl_bad
    sub w10,w10,#1
    uxtw x10,w10
    str x10,[x19,#680]
    cbz x21,.Lsl_return
    cbz x22,.Lsl_return
    cbz x25,.Lsl_return
    SL_PTR x10,6
    mov x11,x24
    cbz x11,.Lsl_extent_ok6
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok6:
    SL_PTR x10,7
    mov x11,x24
    cbz x11,.Lsl_extent_ok7
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok7:
    SL_PTR x10,8
    mov x11,x24
    cbz x11,.Lsl_extent_ok8
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok8:
    SL_PTR x10,9
    mov x11,#5
    mul x11,x11,x24
    cbz x11,.Lsl_extent_ok9
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok9:
    SL_PTR x10,10
    mov x11,x24
    cbz x11,.Lsl_extent_ok10
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok10:
    SL_PTR x10,11
    add x11,x22,#1
    mul x11,x11,x21
    lsl x11,x11,#3
    cbz x11,.Lsl_extent_ok11
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok11:
    SL_PTR x10,12
    mov x11,x24
    cbz x11,.Lsl_extent_ok12
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok12:
    SL_PTR x10,13
    mov x11,x24
    cbz x11,.Lsl_extent_ok13
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok13:
    SL_PTR x10,14
    mov x11,x24
    cbz x11,.Lsl_extent_ok14
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok14:
    SL_PTR x10,15
    mov x11,x24
    cbz x11,.Lsl_extent_ok15
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok15:
    SL_PTR x10,16
    mov x11,x24
    cbz x11,.Lsl_extent_ok16
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok16:
    SL_PTR x10,17
    mov x11,x24
    cbz x11,.Lsl_extent_ok17
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok17:
    SL_PTR x10,18
    mov x11,#5
    mul x11,x11,x24
    cbz x11,.Lsl_extent_ok18
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok18:
    SL_PTR x10,19
    mov x11,x24
    cbz x11,.Lsl_extent_ok19
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok19:
    SL_PTR x10,20
    mov x11,x24
    cbz x11,.Lsl_extent_ok20
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok20:
    SL_PTR x10,21
    mov x11,x24
    cbz x11,.Lsl_extent_ok21
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok21:
    SL_PTR x10,22
    mov x11,x24
    cbz x11,.Lsl_extent_ok22
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok22:
    SL_PTR x10,23
    mov x11,x24
    cbz x11,.Lsl_extent_ok23
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok23:
    SL_PTR x10,24
    mov x11,x24
    cbz x11,.Lsl_extent_ok24
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok24:
    SL_PTR x10,25
    mov x11,#5
    mul x11,x11,x24
    cbz x11,.Lsl_extent_ok25
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok25:
    SL_PTR x10,26
    mov x11,x24
    cbz x11,.Lsl_extent_ok26
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok26:
    SL_PTR x10,27
    mov x11,x24
    cbz x11,.Lsl_extent_ok27
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok27:
    SL_PTR x10,28
    mov x11,x24
    cbz x11,.Lsl_extent_ok28
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok28:
    SL_PTR x10,29
    mov x11,x24
    cbz x11,.Lsl_extent_ok29
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok29:
    SL_PTR x10,30
    mov x11,x24
    cbz x11,.Lsl_extent_ok30
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok30:
    SL_PTR x10,31
    mov x11,x24
    cbz x11,.Lsl_extent_ok31
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok31:
    SL_PTR x10,32
    mov x11,#5
    mul x11,x11,x24
    cbz x11,.Lsl_extent_ok32
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok32:
    SL_PTR x10,33
    mov x11,x24
    cbz x11,.Lsl_extent_ok33
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok33:
    SL_PTR x10,34
    mov x11,x24
    cbz x11,.Lsl_extent_ok34
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok34:
    SL_PTR x10,35
    mov x11,x24
    cbz x11,.Lsl_extent_ok35
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok35:
    SL_PTR x10,36
    ldr x11,[x19,#656]
    mul x11,x11,x24
    cbz x11,.Lsl_extent_ok36
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok36:
    SL_PTR x10,37
    mov x11,x24
    cbz x11,.Lsl_extent_ok37
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok37:
    SL_PTR x10,38
    mov x11,x24
    cbz x11,.Lsl_extent_ok38
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok38:
    SL_PTR x10,39
    mov x11,x24
    cbz x11,.Lsl_extent_ok39
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok39:
    SL_PTR x10,40
    mov x11,x24
    cbz x11,.Lsl_extent_ok40
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok40:
    SL_PTR x10,41
    mov x11,x24
    cbz x11,.Lsl_extent_ok41
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok41:
    SL_PTR x10,42
    mov x11,x24
    cbz x11,.Lsl_extent_ok42
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok42:
    SL_PTR x10,43
    mov x11,x24
    cbz x11,.Lsl_extent_ok43
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok43:
    SL_PTR x10,44
    mov x11,x24
    cbz x11,.Lsl_extent_ok44
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok44:
    SL_PTR x10,45
    mov x11,#5
    mul x11,x11,x24
    cbz x11,.Lsl_extent_ok45
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok45:
    SL_PTR x10,46
    ldr x11,[x19,#664]
    mul x11,x11,x24
    cbz x11,.Lsl_extent_ok46
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok46:
    SL_PTR x10,47
    ldr x11,[x19,#656]
    mul x11,x11,x24
    cbz x11,.Lsl_extent_ok47
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok47:
    SL_PTR x10,48
    ldr x11,[x19,#672]
    mul x11,x11,x24
    cbz x11,.Lsl_extent_ok48
    cbz x10,.Lsl_bad
    tst x10,#7
    b.ne .Lsl_bad
    adds x11,x10,x11
    b.cs .Lsl_bad
.Lsl_extent_ok48:
    ldr x9,=1577456
    add x11,x20,x9
    ldr x12,[x11]
    cbz x12,.Lsl_bad
    tst x12,#7
    b.ne .Lsl_bad
    str x12,[x19,#688]
    ldr x9,[x11,#8]
    cmn x9,#1
    b.ne .Lsl_bad
    ldr x9,[x11,#16]
    cmp x9,#8
    b.ne .Lsl_bad
    ldr x9,[x11,#40]
    cmp x9,#1
    b.ne .Lsl_bad
    ldr x9,[x11,#48]
    cmp x9,#1
    b.ne .Lsl_bad
    ldr x9,[x11,#56]
    cmp x9,x22
    b.lt .Lsl_bad
    mov x9,#0
    fmov d1,#1.0
.Lsl_check_weight:
    ldr d0,[x12,x9,lsl #3]
    fcmp d0,#0.0
    b.vs .Lsl_bad
    b.lt .Lsl_bad
    fcmp d0,d1
    b.gt .Lsl_bad
    add x9,x9,#1
    cmp x9,x22
    b.lt .Lsl_check_weight
    SL_MODEL x11,800032
    cbz x11,.Lsl_bad
    tst x11,#7
    b.ne .Lsl_bad
    ldr w9,[x11,#100]
    cbz w9,.Lsl_inactive0
    cmp w9,#1
    b.ne .Lsl_bad
    ldrsw x10,[x11,#204]
    cmp x10,#1
    b.lt .Lsl_bad
    ldr x9,[x19,#656]
    cmp x10,x9
    b.gt .Lsl_bad
    sub x10,x10,#1
    mul x10,x10,x24
    SL_PTR x11,36
    add x11,x11,x10
    SL_PTR x12,47
    add x12,x12,x10
    str x11,[x19,#800]
    str x12,[x19,#808]
    b .Lsl_slot_ready0
.Lsl_inactive0:
    str xzr,[x19,#800]
    str xzr,[x19,#808]
.Lsl_slot_ready0:
    SL_MODEL x11,800176
    cbz x11,.Lsl_bad
    tst x11,#7
    b.ne .Lsl_bad
    ldr w9,[x11,#100]
    cbz w9,.Lsl_inactive1
    cmp w9,#1
    b.ne .Lsl_bad
    ldrsw x10,[x11,#204]
    cmp x10,#1
    b.lt .Lsl_bad
    ldr x9,[x19,#656]
    cmp x10,x9
    b.gt .Lsl_bad
    sub x10,x10,#1
    mul x10,x10,x24
    SL_PTR x11,36
    add x11,x11,x10
    SL_PTR x12,47
    add x12,x12,x10
    str x11,[x19,#816]
    str x12,[x19,#824]
    b .Lsl_slot_ready1
.Lsl_inactive1:
    str xzr,[x19,#816]
    str xzr,[x19,#824]
.Lsl_slot_ready1:
    SL_MODEL x11,800048
    cbz x11,.Lsl_bad
    tst x11,#7
    b.ne .Lsl_bad
    ldr w9,[x11,#100]
    cbz w9,.Lsl_inactive2
    cmp w9,#1
    b.ne .Lsl_bad
    ldrsw x10,[x11,#204]
    cmp x10,#1
    b.lt .Lsl_bad
    ldr x9,[x19,#656]
    cmp x10,x9
    b.gt .Lsl_bad
    sub x10,x10,#1
    mul x10,x10,x24
    SL_PTR x11,36
    add x11,x11,x10
    SL_PTR x12,47
    add x12,x12,x10
    str x11,[x19,#832]
    str x12,[x19,#840]
    b .Lsl_slot_ready2
.Lsl_inactive2:
    str xzr,[x19,#832]
    str xzr,[x19,#840]
.Lsl_slot_ready2:
    SL_MODEL x11,800040
    cbz x11,.Lsl_bad
    tst x11,#7
    b.ne .Lsl_bad
    ldr w9,[x11,#100]
    cbz w9,.Lsl_inactive3
    cmp w9,#1
    b.ne .Lsl_bad
    ldrsw x10,[x11,#204]
    cmp x10,#1
    b.lt .Lsl_bad
    ldr x9,[x19,#656]
    cmp x10,x9
    b.gt .Lsl_bad
    sub x10,x10,#1
    mul x10,x10,x24
    SL_PTR x11,36
    add x11,x11,x10
    SL_PTR x12,47
    add x12,x12,x10
    str x11,[x19,#848]
    str x12,[x19,#856]
    b .Lsl_slot_ready3
.Lsl_inactive3:
    str xzr,[x19,#848]
    str xzr,[x19,#856]
.Lsl_slot_ready3:
    SL_MODEL x11,800112
    cbz x11,.Lsl_bad
    tst x11,#7
    b.ne .Lsl_bad
    ldr w9,[x11,#100]
    cbz w9,.Lsl_inactive4
    cmp w9,#1
    b.ne .Lsl_bad
    ldrsw x10,[x11,#204]
    cmp x10,#1
    b.lt .Lsl_bad
    ldr x9,[x19,#656]
    cmp x10,x9
    b.gt .Lsl_bad
    sub x10,x10,#1
    mul x10,x10,x24
    SL_PTR x11,36
    add x11,x11,x10
    SL_PTR x12,47
    add x12,x12,x10
    str x11,[x19,#864]
    str x12,[x19,#872]
    b .Lsl_slot_ready4
.Lsl_inactive4:
    str xzr,[x19,#864]
    str xzr,[x19,#872]
.Lsl_slot_ready4:
    SL_MODEL x11,800104
    cbz x11,.Lsl_bad
    tst x11,#7
    b.ne .Lsl_bad
    ldr w9,[x11,#100]
    cbz w9,.Lsl_inactive5
    cmp w9,#1
    b.ne .Lsl_bad
    ldrsw x10,[x11,#204]
    cmp x10,#1
    b.lt .Lsl_bad
    ldr x9,[x19,#656]
    cmp x10,x9
    b.gt .Lsl_bad
    sub x10,x10,#1
    mul x10,x10,x24
    SL_PTR x11,36
    add x11,x11,x10
    SL_PTR x12,47
    add x12,x12,x10
    str x11,[x19,#880]
    str x12,[x19,#888]
    b .Lsl_slot_ready5
.Lsl_inactive5:
    str xzr,[x19,#880]
    str xzr,[x19,#888]
.Lsl_slot_ready5:
    SL_MODEL x11,800184
    cbz x11,.Lsl_bad
    tst x11,#7
    b.ne .Lsl_bad
    ldr w9,[x11,#100]
    cbz w9,.Lsl_inactive6
    cmp w9,#1
    b.ne .Lsl_bad
    ldrsw x10,[x11,#204]
    cmp x10,#1
    b.lt .Lsl_bad
    ldr x9,[x19,#656]
    cmp x10,x9
    b.gt .Lsl_bad
    sub x10,x10,#1
    mul x10,x10,x24
    SL_PTR x11,36
    add x11,x11,x10
    SL_PTR x12,47
    add x12,x12,x10
    str x11,[x19,#896]
    str x12,[x19,#904]
    b .Lsl_slot_ready6
.Lsl_inactive6:
    str xzr,[x19,#896]
    str xzr,[x19,#904]
.Lsl_slot_ready6:
    SL_MODEL w10,1577992
    cmp w10,#1
    b.hi .Lsl_bad
    mov x11,#26
    cmp w10,#0
    csel x12,x11,xzr,ne
    str xzr,[x19,#768]
    str xzr,[x19,#776]
    str xzr,[x19,#784]
    SL_MODEL w10,1579668
    cmp w10,#1
    b.hi .Lsl_bad
    str x10,[x19,#760]
    cbz w10,.Lsl_vertical_ready
    cmp x22,#45
    b.lt .Lsl_bad
    ldr x9,[x19,#672]
    cmp x9,#1
    b.lt .Lsl_bad
    add x12,x12,#1
.Lsl_vertical_ready:
    SL_MODEL w10,1579648
    cmp w10,#1
    b.hi .Lsl_bad
    cbz w10,.Lsl_diag_ready0
    add x11,x12,#5
    ldr x9,[x19,#672]
    cmp x11,x9
    b.gt .Lsl_bad
    sub x11,x11,#1
    SL_PTR x10,48
    madd x11,x11,x24,x10
    str x11,[x19,#768]
    add x12,x12,#12
.Lsl_diag_ready0:
    SL_MODEL w10,1579652
    cmp w10,#1
    b.hi .Lsl_bad
    cbz w10,.Lsl_diag_ready1
    add x11,x12,#6
    ldr x9,[x19,#672]
    cmp x11,x9
    b.gt .Lsl_bad
    sub x11,x11,#1
    SL_PTR x10,48
    madd x11,x11,x24,x10
    str x11,[x19,#776]
    add x12,x12,#22
.Lsl_diag_ready1:
    SL_MODEL w10,1579656
    cmp w10,#1
    b.hi .Lsl_bad
    cbz w10,.Lsl_diag_ready2
    add x11,x12,#6
    ldr x9,[x19,#672]
    cmp x11,x9
    b.gt .Lsl_bad
    sub x11,x11,#1
    SL_PTR x10,48
    madd x11,x11,x24,x10
    str x11,[x19,#784]
    add x12,x12,#18
.Lsl_diag_ready2:
    mov w9,#1
    str w9,[x19,#976]
    lsl x9,x21,#6
    sub sp,sp,x9
    sub sp,sp,#64
    add x28,sp,#64
    mov x26,#0
.Lsl_save_level:
    ldr x9,[x19,#688]
    ldr d0,[x9,x26,lsl #3]
    fmov d11,#1.0
    fsub d11,d11,d0
    mov x27,#0
.Lsl_save_cell:
    madd x15,x26,x21,x27
    SL_LOAD d0,19
    SL_LOAD d1,37
    fsub d0,d0,d1
    SL_LOAD d1,12
    fsub d0,d0,d1
    SL_STORE d0,46,0
    SL_LOAD d0,20
    SL_LOAD d1,38
    fsub d0,d0,d1
    SL_LOAD d1,13
    fsub d0,d0,d1
    SL_STORE d0,46,1
    SL_LOAD d0,21
    SL_LOAD d1,39
    fsub d0,d0,d1
    SL_LOAD d1,14
    fsub d0,d0,d1
    SL_LOAD d1,42
    fsub d0,d0,d1
    SL_STORE d0,46,2
    ldr x11,[x19,#808]
    cbz x11,.Lsl_no_save0
    SL_LOAD d0,22,0
    SL_LOAD d1,40,0
    fsub d0,d0,d1
    SL_LOAD d1,15,0
    fsub d0,d0,d1
    SL_LOAD d1,43,0
    fsub d0,d0,d1
    str d0,[x11,x15,lsl #3]
.Lsl_no_save0:
    ldr x11,[x19,#824]
    cbz x11,.Lsl_no_save1
    SL_LOAD d0,24,0
    SL_LOAD d1,41,0
    fsub d0,d0,d1
    SL_LOAD d1,17,0
    fsub d0,d0,d1
    SL_LOAD d1,44,0
    fsub d0,d0,d1
    str d0,[x11,x15,lsl #3]
.Lsl_no_save1:
    ldr x11,[x19,#840]
    cbz x11,.Lsl_no_save2
    SL_LOAD d0,25,0
    SL_LOAD d1,18,0
    fsub d0,d0,d1
    SL_LOAD d1,45,0
    fsub d0,d0,d1
    str d0,[x11,x15,lsl #3]
.Lsl_no_save2:
    ldr x11,[x19,#856]
    cbz x11,.Lsl_no_save3
    SL_LOAD d0,25,1
    SL_LOAD d1,18,1
    fsub d0,d0,d1
    SL_LOAD d1,45,1
    fsub d0,d0,d1
    str d0,[x11,x15,lsl #3]
.Lsl_no_save3:
    ldr x11,[x19,#872]
    cbz x11,.Lsl_no_save4
    SL_LOAD d0,25,2
    SL_LOAD d1,18,2
    fsub d0,d0,d1
    str d0,[x11,x15,lsl #3]
.Lsl_no_save4:
    ldr x11,[x19,#888]
    cbz x11,.Lsl_no_save5
    SL_LOAD d0,25,3
    SL_LOAD d1,18,3
    fsub d0,d0,d1
    str d0,[x11,x15,lsl #3]
.Lsl_no_save5:
    ldr x11,[x19,#904]
    cbz x11,.Lsl_no_save6
    SL_LOAD d0,23,0
    SL_LOAD d1,16,0
    fsub d0,d0,d1
    str d0,[x11,x15,lsl #3]
.Lsl_no_save6:
    SL_LOAD d0,46,0
    fmul d0,d10,d0
    SL_LOAD d1,33
    fmul d1,d8,d1
    fadd d0,d0,d1
    fmul d0,d11,d0
    SL_STORE d0,26
    SL_LOAD d0,46,1
    fmul d0,d10,d0
    SL_LOAD d1,34
    fmul d1,d8,d1
    fadd d0,d0,d1
    fmul d0,d11,d0
    SL_STORE d0,27
    SL_LOAD d0,46,2
    fmul d0,d10,d0
    SL_LOAD d1,35
    fmul d1,d8,d1
    fadd d0,d0,d1
    fmul d0,d11,d0
    SL_STORE d0,28
    ldr x11,[x19,#800]
    ldr x12,[x19,#808]
    cbz x12,.Lsl_zero_tend0
    ldr d0,[x12,x15,lsl #3]
    fmul d0,d10,d0
    ldr d1,[x11,x15,lsl #3]
    fmul d1,d8,d1
    fadd d0,d0,d1
    fmul d0,d11,d0
    b .Lsl_tend_ready0
.Lsl_zero_tend0:
    fmov d0,xzr
.Lsl_tend_ready0:
    SL_STORE d0,29,0
    ldr x11,[x19,#816]
    ldr x12,[x19,#824]
    cbz x12,.Lsl_zero_tend1
    ldr d0,[x12,x15,lsl #3]
    fmul d0,d10,d0
    ldr d1,[x11,x15,lsl #3]
    fmul d1,d8,d1
    fadd d0,d0,d1
    fmul d0,d11,d0
    b .Lsl_tend_ready1
.Lsl_zero_tend1:
    fmov d0,xzr
.Lsl_tend_ready1:
    SL_STORE d0,31,0
    ldr x11,[x19,#832]
    ldr x12,[x19,#840]
    cbz x12,.Lsl_zero_tend2
    ldr d0,[x12,x15,lsl #3]
    fmul d0,d10,d0
    ldr d1,[x11,x15,lsl #3]
    fmul d1,d8,d1
    fadd d0,d0,d1
    fmul d0,d11,d0
    b .Lsl_tend_ready2
.Lsl_zero_tend2:
    fmov d0,xzr
.Lsl_tend_ready2:
    SL_STORE d0,32,0
    ldr x11,[x19,#848]
    ldr x12,[x19,#856]
    cbz x12,.Lsl_zero_tend3
    ldr d0,[x12,x15,lsl #3]
    fmul d0,d10,d0
    ldr d1,[x11,x15,lsl #3]
    fmul d1,d8,d1
    fadd d0,d0,d1
    fmul d0,d11,d0
    b .Lsl_tend_ready3
.Lsl_zero_tend3:
    fmov d0,xzr
.Lsl_tend_ready3:
    SL_STORE d0,32,1
    ldr x11,[x19,#864]
    ldr x12,[x19,#872]
    cbz x12,.Lsl_zero_tend4
    ldr d0,[x12,x15,lsl #3]
    fmul d0,d10,d0
    ldr d1,[x11,x15,lsl #3]
    fmul d1,d8,d1
    fadd d0,d0,d1
    fmul d0,d11,d0
    b .Lsl_tend_ready4
.Lsl_zero_tend4:
    fmov d0,xzr
.Lsl_tend_ready4:
    SL_STORE d0,32,2
    ldr x11,[x19,#880]
    ldr x12,[x19,#888]
    cbz x12,.Lsl_zero_tend5
    ldr d0,[x12,x15,lsl #3]
    fmul d0,d10,d0
    ldr d1,[x11,x15,lsl #3]
    fmul d1,d8,d1
    fadd d0,d0,d1
    fmul d0,d11,d0
    b .Lsl_tend_ready5
.Lsl_zero_tend5:
    fmov d0,xzr
.Lsl_tend_ready5:
    SL_STORE d0,32,3
    ldr x11,[x19,#896]
    ldr x12,[x19,#904]
    cbz x12,.Lsl_zero_tend6
    ldr d0,[x12,x15,lsl #3]
    fmul d0,d10,d0
    ldr d1,[x11,x15,lsl #3]
    fmul d1,d8,d1
    fadd d0,d0,d1
    fmul d0,d11,d0
    b .Lsl_tend_ready6
.Lsl_zero_tend6:
    fmov d0,xzr
.Lsl_tend_ready6:
    SL_STORE d0,30,0
    add x27,x27,#1
    cmp x27,x25
    b.lt .Lsl_save_cell
    add x26,x26,#1
    cmp x26,x22
    b.lt .Lsl_save_level
    ldr x26,[x19,#680]
    cmp x26,x22
    b.ge .Lsl_return
.Lsl_adjust_level:
    mov x27,#0
.Lsl_trial_cell:
    madd x15,x26,x21,x27
    SL_LOAD d0,21
    SL_LOAD d1,28
    fadd d0,d0,d1
    fmul d0,d9,d0
    SL_LOAD d1,6
    fadd d0,d1,d0
    mov x9,#0
    mul x9,x9,x21
    add x9,x9,x27
    str d0,[x28,x9,lsl #3]
    SL_LOAD d0,22
    SL_LOAD d1,29
    fadd d0,d0,d1
    fmul d0,d9,d0
    SL_LOAD d1,7
    fadd d0,d1,d0
    mov x9,#1
    mul x9,x9,x21
    add x9,x9,x27
    str d0,[x28,x9,lsl #3]
    SL_LOAD d0,24
    SL_LOAD d1,31
    fadd d0,d0,d1
    fmul d0,d9,d0
    SL_LOAD d1,8
    fadd d0,d1,d0
    mov x9,#2
    mul x9,x9,x21
    add x9,x9,x27
    str d0,[x28,x9,lsl #3]
    add x27,x27,#1
    cmp x27,x25
    b.lt .Lsl_trial_cell
    mov x9,#2
    mul x9,x9,x21
    add x9,x28,x9,lsl #3
    str x9,[sp,#0]
    mov x9,#3
    mul x9,x9,x21
    add x9,x28,x9,lsl #3
    str x9,[sp,#24]
    mov x9,#4
    mul x9,x9,x21
    add x9,x28,x9,lsl #3
    str x9,[sp,#32]
    mov x9,#5
    mul x9,x9,x21
    add x9,x28,x9,lsl #3
    str x9,[sp,#40]
    mov x9,#6
    mul x9,x9,x21
    add x9,x28,x9,lsl #3
    str x9,[sp,#48]
    mov x9,#7
    mul x9,x9,x21
    add x9,x28,x9,lsl #3
    str x9,[sp,#56]
    SL_PTR x9,10
    mul x10,x26,x21
    add x9,x9,x10,lsl #3
    str x9,[sp,#8]
    SL_PTR x9,11
    add x9,x9,x23,lsl #3
    str x9,[sp,#16]
    ldr x9,=1578600
    add x0,x20,x9
    SL_PTR x1,1
    SL_PTR x2,2
    SL_PTR x3,3
    SL_PTR x4,4
    add x5,x19,#976
    mov x6,x28
    add x7,x28,x21,lsl #3
    bl md2asm_sltend_private_supersatcheck
    mov x27,#0
.Lsl_adjust_cell:
    madd x15,x26,x21,x27
    mov x11,#3
    mul x11,x11,x21
    add x11,x11,x27
    ldr d1,[x28,x11,lsl #3]
    fmul d1,d1,d8
    SL_LOAD d0,28,0
    fadd d0,d0,d1
    SL_STORE d0,28,0
    mov x11,#4
    mul x11,x11,x21
    add x11,x11,x27
    ldr d1,[x28,x11,lsl #3]
    fmul d1,d1,d8
    SL_LOAD d0,29,0
    fadd d0,d0,d1
    SL_STORE d0,29,0
    mov x11,#5
    mul x11,x11,x21
    add x11,x11,x27
    ldr d1,[x28,x11,lsl #3]
    fmul d1,d1,d8
    SL_LOAD d0,31,0
    fadd d0,d0,d1
    SL_STORE d0,31,0
    str d1,[x28,x11,lsl #3]
    mov x11,#6
    mul x11,x11,x21
    add x11,x11,x27
    ldr d1,[x28,x11,lsl #3]
    fmul d1,d1,d8
    SL_LOAD d0,32,0
    fadd d0,d0,d1
    SL_STORE d0,32,0
    str d1,[x28,x11,lsl #3]
    mov x11,#7
    mul x11,x11,x21
    add x11,x11,x27
    ldr d1,[x28,x11,lsl #3]
    fmul d1,d1,d8
    SL_LOAD d0,32,1
    fadd d0,d0,d1
    SL_STORE d0,32,1
    str d1,[x28,x11,lsl #3]
    ldr x9,[x19,#760]
    cbz x9,.Lsl_no_vertical
    SL_PTR x11,11
    ldr d0,[x11,x15,lsl #3]
    add x12,x15,x21
    ldr d1,[x11,x12,lsl #3]
    fsub d0,d1,d0
    SL_LOAD d1,6
    fmul d1,d13,d1
    SL_LOAD d2,10
    fdiv d1,d2,d1
    fmul d1,d1,d14
    fdiv d2,d0,d1
    mov x11,#5
    mul x11,x11,x21
    add x11,x11,x27
    ldr d1,[x28,x11,lsl #3]
    fmul d1,d1,d2
    mov x11,#4
    madd x11,x11,x21,x27
    SL_PTR x12,48
    ldr d0,[x12,x11,lsl #3]
    fadd d0,d0,d1
    str d0,[x12,x11,lsl #3]
    mov x11,#6
    mul x11,x11,x21
    add x11,x11,x27
    ldr d1,[x28,x11,lsl #3]
    fmul d1,d1,d2
    mov x11,#19
    madd x11,x11,x21,x27
    SL_PTR x12,48
    ldr d0,[x12,x11,lsl #3]
    fadd d0,d0,d1
    str d0,[x12,x11,lsl #3]
    mov x11,#7
    mul x11,x11,x21
    add x11,x11,x27
    ldr d1,[x28,x11,lsl #3]
    fmul d1,d1,d2
    mov x11,#44
    madd x11,x11,x21,x27
    SL_PTR x12,48
    ldr d0,[x12,x11,lsl #3]
    fadd d0,d0,d1
    str d0,[x12,x11,lsl #3]
.Lsl_no_vertical:
    ldr x12,[x19,#768]
    cbz x12,.Lsl_no_budget0
    mov x11,#5
    mul x11,x11,x21
    add x11,x11,x27
    ldr d1,[x28,x11,lsl #3]
    ldr d0,[x12,x15,lsl #3]
    fadd d0,d0,d1
    str d0,[x12,x15,lsl #3]
.Lsl_no_budget0:
    ldr x12,[x19,#776]
    cbz x12,.Lsl_no_budget1
    mov x11,#6
    mul x11,x11,x21
    add x11,x11,x27
    ldr d1,[x28,x11,lsl #3]
    ldr d0,[x12,x15,lsl #3]
    fadd d0,d0,d1
    str d0,[x12,x15,lsl #3]
.Lsl_no_budget1:
    ldr x12,[x19,#784]
    cbz x12,.Lsl_no_budget2
    mov x11,#7
    mul x11,x11,x21
    add x11,x11,x27
    ldr d1,[x28,x11,lsl #3]
    ldr d0,[x12,x15,lsl #3]
    fadd d0,d0,d1
    str d0,[x12,x15,lsl #3]
.Lsl_no_budget2:
    add x27,x27,#1
    cmp x27,x25
    b.lt .Lsl_adjust_cell
    add x26,x26,#1
    cmp x26,x22
    b.lt .Lsl_adjust_level
.Lsl_return:
    mov sp,x19
    add x16,sp,#480
    ldp x19,x20,[x16,#0]
    ldp x21,x22,[x16,#16]
    ldp x23,x24,[x16,#32]
    ldp x25,x26,[x16,#48]
    ldp x27,x28,[x16,#64]
    ldp x29,x30,[x16,#80]
    ldp d8,d9,[x16,#96]
    ldp d10,d11,[x16,#112]
    ldp d12,d13,[x16,#128]
    ldp d14,d15,[x16,#144]
    ldr x18,[sp,#640]
    add sp,sp,#1024
    ret
.Lsl_bad:
    brk #0x2ae
.size md2asm_sltend,.-md2asm_sltend
.ltorg
.section .rodata
.p2align 3
.global md2asm_sltend_constant_retv
.hidden md2asm_sltend_constant_retv
md2asm_sltend_constant_retv:
    .quad 0x3fe372d3377bc708
.global md2asm_sltend_constant_rtt
.hidden md2asm_sltend_constant_rtt
md2asm_sltend_constant_rtt:
    .quad 0x4071128f5c28f5c3
.global md2asm_sltend_constant_r2es
.hidden md2asm_sltend_constant_r2es
md2asm_sltend_constant_r2es:
    .quad 0x4077c292ecc83996
.global md2asm_sltend_constant_r3les
.hidden md2asm_sltend_constant_r3les
md2asm_sltend_constant_r3les:
    .quad 0x40318083126e978d
.global md2asm_sltend_constant_r3ies
.hidden md2asm_sltend_constant_r3ies
md2asm_sltend_constant_r3ies:
    .quad 0x40369645a1cac083
.global md2asm_sltend_constant_r4les
.hidden md2asm_sltend_constant_r4les
md2asm_sltend_constant_r4les:
    .quad 0x40401851eb851eb8
.global md2asm_sltend_constant_r4ies
.hidden md2asm_sltend_constant_r4ies
md2asm_sltend_constant_r4ies:
    .quad 0xbfe6666666666666
.global md2asm_sltend_constant_rtwat
.hidden md2asm_sltend_constant_rtwat
md2asm_sltend_constant_rtwat:
    .quad 0x4071128f5c28f5c3
.global md2asm_sltend_constant_rtice
.hidden md2asm_sltend_constant_rtice
md2asm_sltend_constant_rtice:
    .quad 0x406f451eb851eb86
.global md2asm_sltend_constant_rtwat_rtice_r
.hidden md2asm_sltend_constant_rtwat_rtice_r
md2asm_sltend_constant_rtwat_rtice_r:
    .quad 0x3fa642c8590b2164
.global md2asm_sltend_constant_rkoop1
.hidden md2asm_sltend_constant_rkoop1
md2asm_sltend_constant_rkoop1:
    .quad 0x4004a9fbe76c8b44
.global md2asm_sltend_constant_rkoop2
.hidden md2asm_sltend_constant_rkoop2
md2asm_sltend_constant_rkoop2:
    .quad 0x3f73b5540a434fe1
.global md2asm_sltend_constant_r5alvcp
.hidden md2asm_sltend_constant_r5alvcp
md2asm_sltend_constant_r5alvcp:
    .quad 0x416405c615d072af
.global md2asm_sltend_constant_r5alscp
.hidden md2asm_sltend_constant_r5alscp
md2asm_sltend_constant_r5alscp:
    .quad 0x4170a487340dc5eb
.global md2asm_sltend_constant_ralvdcp
.hidden md2asm_sltend_constant_ralvdcp
md2asm_sltend_constant_ralvdcp:
    .quad 0x40a372289753d8f6
.global md2asm_sltend_constant_ralsdcp
.hidden md2asm_sltend_constant_ralsdcp
md2asm_sltend_constant_ralsdcp:
    .quad 0x40a60a6e3b924a89
.section .note.GNU-stack,"",%progbits

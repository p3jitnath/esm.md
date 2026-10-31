/* Runtime UPDTIM clock and conditional forcing entry.
 * Contract skills/md2asm/references/openifs/physics/runtime_model_time_and_forcing.md.
 * Nine original addresses are followed by a borrowed 80-byte context.
 * The stack frame owns 512 bytes and keeps 16-byte alignment. */
.text
.p2align 4
.macro time_address dst,base,offset
    movz \dst,#(\offset & 65535)
    movk \dst,#((\offset >> 16) & 65535),lsl #16
    add \dst,\base,\dst
.endm
.macro time_pointer reg,alignment,bytes,r1,r2,r3
    cbz \reg,.Ltime_reason_\r1
    tst \reg,#\alignment
    b.ne .Ltime_reason_\r2
    ldr x9,=\bytes
    adds x9,\reg,x9
    b.cs .Ltime_reason_\r3
.endm
.macro time_field base,offset,value,reason
    time_address x9,\base,\offset
    ldr w10,[x9]
    ldr w11,=\value
    cmp w10,w11
    b.ne .Ltime_reason_\reason
.endm
.macro time_live_load reg,slot,offset
    ldr x16,[sp,#320]
    ldr x16,[x16,#\slot]
    time_address x9,x16,\offset
    ldr \reg,[x9]
.endm
.macro time_live_address reg,slot,offset
    ldr x16,[sp,#320]
    ldr x16,[x16,#\slot]
    time_address \reg,x16,\offset
.endm
.global md2asm_runtime_model_time_and_forcing_with_failure_reason
.type md2asm_runtime_model_time_and_forcing_with_failure_reason,%function
md2asm_runtime_model_time_and_forcing_with_failure_reason:
    mrs x9,fpcr
    cbnz x9,.Ltime_reason_65001
    ldr x17,[sp,#8]
    time_pointer x17,7,80,65002,65003,65004
    ldr x11,[x17]
    time_pointer x11,7,520,65005,65006,65007
    ldr x12,[x17,#8]
    time_pointer x12,7,67616,65008,65009,65010
    ldr x13,[x17,#16]
    time_pointer x13,7,2792,65011,65012,65013
    ldr x13,[x17,#24]
    time_pointer x13,7,64,65014,65015,65016
    ldr x14,[x13]
    cmp x14,x11
    b.ne .Ltime_reason_65017
    ldr x13,[x17,#32]
    cbz x13,.Ltime_reason_65018
    ldr x14,[x17,#40]
    sub x14,x14,#1
    cmp x14,#479
    b.hi .Ltime_reason_65019
    ldr x13,[x17,#48]
    time_pointer x13,7,64,65020,65021,65022
    ldr x13,[x17,#56]
    time_pointer x13,3,4,65023,65024,65025
    ldr w13,[x13]
    cbnz w13,.Ltime_reason_65026
    ldr x13,[x17,#64]
    time_pointer x13,3,4,65027,65028,65029
    ldr w13,[x13]
    cbnz w13,.Ltime_reason_65030
    ldr x13,[x17,#72]
    cbnz x13,.Ltime_reason_65031
    ldr x13,[x17]
    adr x14,.Ltime_required_constants
    ldr x15,[x13]
    ldr x9,[x14]
    cmp x15,x9
    b.ne .Ltime_reason_65032
    ldr x15,[x13,#40]
    ldr x9,[x14,#8]
    cmp x15,x9
    b.ne .Ltime_reason_65033
    ldr x15,[x13,#64]
    ldr x9,[x14,#16]
    cmp x15,x9
    b.ne .Ltime_reason_65034
    ldr x15,[x13,#72]
    ldr x9,[x14,#24]
    cmp x15,x9
    b.ne .Ltime_reason_65035
    time_address x13,x12,51744
    ldr x13,[x13]
    ldr x9,[x14,#32]
    cmp x13,x9
    b.ne .Ltime_reason_65036
    time_field x12,51752,0,65037
    time_field x12,65684,0,65038
    time_field x12,65796,0,65039
    time_field x12,51672,0,65040
    time_field x12,35760,1,65041
    time_field x12,51736,20260621,65042
    time_field x12,51740,0,65043
    time_field x12,51756,0,65044
    time_pointer x0,7,20400,65045,65046,65047
    time_pointer x1,7,18224,65048,65049,65050
    time_pointer x2,7,4275088,65051,65052,65053
    time_pointer x3,3,4,65054,65055,65056
    time_pointer x4,7,8,65057,65058,65059
    time_pointer x5,7,8,65060,65061,65062
    time_pointer x6,3,4,65063,65064,65065
    cbz x7,.Ltime_optional_ok
    time_pointer x7,3,4,65066,65067,65068
    ldr w9,[x7]
    cmp w9,#1
    b.hi .Ltime_reason_65069
.Ltime_optional_ok:
    ldr x9,[sp]
    cbnz x9,.Ltime_reason_65070
    time_address x13,x2,1359332
    ldr w14,[x13]
    cmp w14,#575
    b.hi .Ltime_reason_65071
    add w14,w14,#1
    ldr w9,[x3]
    cmp w9,w14
    b.hi .Ltime_reason_65072
    ldr w9,[x6]
    cmp w9,#1
    b.hi .Ltime_reason_65073
    time_field x0,5172,1279,65074
    time_field x0,5224,137,65075
    ldr w9,[x0,#7376]
    cmp w9,#1
    b.lt .Ltime_reason_65076
    ldr w10,[x0,#7388]
    cmp w10,#1
    b.lt .Ltime_reason_65077
    cmp w9,w10
    b.hi .Ltime_reason_65078
    ldr w11,[x0,#5144]
    sub w12,w11,#1
    cmp w12,#1023
    b.hi .Ltime_reason_65079
    add x9,x9,x11
    sub x9,x9,#1
    udiv x9,x9,x11
    ldr w10,[x0,#5160]
    cmp x9,x10
    b.ne .Ltime_reason_65080
    time_field x2,300,0,65081
    time_field x2,1564156,1,65082
    time_field x2,1577888,1,65083
    time_field x2,1577984,1,65084
    time_field x2,1609224,1,65085
    time_field x2,1609228,1,65086
    time_field x2,1609168,1,65087
    time_field x2,1609172,1,65088
    time_field x2,1609152,1,65089
    time_field x2,1608908,1,65090
    time_field x2,1608884,20,65091
    time_field x2,1608876,4,65092
    time_field x2,1608736,1,65093
    time_field x2,1608740,8,65094
    time_field x2,1608760,8,65095
    time_field x2,1608764,8,65096
    time_field x2,1609120,0,65097
    time_field x2,1609176,0,65098
    time_field x2,1609148,0,65099
    time_field x2,1609256,0,65100
    time_field x2,1608776,0,65101
    time_field x2,1609192,1,65102
    time_field x2,1663096,0,65103
    time_field x2,1588300,0,65104
    time_field x2,1577960,1,65105
    time_field x2,1578088,0,65106
    time_field x2,1578124,0,65107
    time_field x2,1562872,0,65108
    time_field x2,1562868,0,65109
    time_field x2,1562880,0,65110
    time_field x2,1562884,0,65111
    time_field x2,1562888,0,65112
    time_address x9,x2,1562896
    ldr w10,[x9]
    cmp w10,#1
    b.hi .Ltime_reason_65113
    time_field x2,1562960,0,65114
    time_field x2,4143772,0,65115
    time_field x2,4218184,0,65116
    time_address x9,x2,4144592
    ldr w10,[x9]
    cmp w10,#1
    b.hi .Ltime_reason_65117
    time_field x2,4144600,0,65118
    time_field x2,4143872,0,65119
    time_field x2,4144596,0,65120
    time_field x2,4218356,0,65121
    time_field x2,1392652,0,65122
    ldr d0,[x4]
    fcmp d0,#0.0
    b.le .Ltime_reason_65123
    b.vs .Ltime_reason_65124
    fmov x9,d0
    and x9,x9,#0x7ff0000000000000
    mov x10,#0x7ff0000000000000
    cmp x9,x10
    b.eq .Ltime_reason_65125
    ldr d0,[x5]
    adr x9,.Ltime_constants
    ldr d1,[x9,#0]
    fcmp d0,d1
    b.ne .Ltime_reason_65126
    time_address x9,x2,1359528
    ldr d0,[x9]
    fcmp d0,d1
    b.ne .Ltime_reason_65127
    sub sp,sp,#512
    stp x19,x20,[sp,#0]
    stp x21,x22,[sp,#16]
    stp x23,x24,[sp,#32]
    stp x25,x26,[sp,#48]
    stp x27,x28,[sp,#64]
    stp x29,x30,[sp,#80]
    str x18,[sp,#96]
    stp d8,d9,[sp,#112]
    stp d10,d11,[sp,#128]
    stp d12,d13,[sp,#144]
    stp d14,d15,[sp,#160]
    stp x3,x4,[sp,#176]
    stp x5,x6,[sp,#192]
    str x7,[sp,#208]
    str x17,[sp,#320]
    mov x29,sp
    mov x19,x2
    mov x20,x0
    mov x21,x1
    ldr w27,[x3]
    time_address x22,x19,1359328
    time_address x23,x19,1608728
    time_address x24,x19,1856400
    time_address x25,x19,1564136
    time_address x26,x19,4100048
/* Build borrowed numerical contexts from the live owned configuration. */
    ldr x17,[sp,#320]
    ldr x16,[x17,#8]
    time_address x9,x16,51736
    ldr w9,[x9]
    str w9,[sp,#448]
    time_address x9,x16,51756
    ldr w9,[x9]
    str w9,[sp,#452]
    time_address x9,x16,35760
    ldr w9,[x9]
    str w9,[sp,#456]
    str wzr,[sp,#460]
    ldr x9,[x17,#16]
    ldr x10,[x17]
    stp x9,x10,[sp,#464]
    mov x9,#456
    stp x25,x9,[sp,#336]
    mov x9,#2040
    stp x23,x9,[sp,#352]
    ldr x9,=175976
    stp x22,x9,[sp,#368]
    ldr x9,[x17]
    mov x10,#520
    stp x9,x10,[sp,#384]
    ldr x9,[x17,#16]
    mov x10,#2792
    stp x9,x10,[sp,#400]
    add x9,sp,#448
    mov x10,#16
    stp x9,x10,[sp,#416]
    stp xzr,xzr,[sp,#432]
    time_live_load d8,0,40
    ldr d9,[x22,#200]
    time_live_load d10,0,0
    time_live_load d11,0,104
    time_live_load d12,0,64
/* The first clock uses the caller's PTSTEP, including its rounding point. */
    ldr x9,[sp,#192]
    ldr d0,[x9]
    fcvtas w28,d0
    str w28,[sp,#264]
    scvtf d1,w27
    fmov d2,#0.5
    fadd d1,d1,d2
    fmul d0,d0,d1
    fcvtas w11,d0
    scvtf d0,w11
    str d0,[x22,#32]
    fcvtas w12,d8
    sdiv w13,w11,w12
    msub w14,w13,w12,w11
    str w13,[x22,#16]
    str w14,[x22,#20]
    asr w13,w12,#1
    add w13,w11,w13
    time_live_load w14,8,51740
    sub w13,w13,w14
    sdiv w15,w13,w12
    msub w13,w15,w12,w13
    str w13,[sp,#268]
    time_live_load d1,8,51744
    fadd d0,d1,d0
    str d0,[x22,#40]
    add w11,w11,w14
    sdiv w13,w11,w12
    msub w11,w13,w12,w11
    scvtf d14,w11
    str d14,[x22,#48]
/* Preserve the first theta for the later ozone phase. */
    adr x9,.Ltime_constants
    ldr d1,[x9,#8]
    fmul d1,d8,d1
    fdiv d1,d0,d1
    str d1,[sp,#280]
    add x0,sp,#240
    bl md2asm_runtime_orbital_illumination
    ldp d0,d1,[sp,#240]
    ldr d2,[sp,#256]
    str d0,[x22,#72]
    str d1,[x22,#80]
    str d2,[x22,#56]
    fadd d2,d2,d14
    str d2,[x22,#64]
    fmov d3,#2.0
    fmul d2,d2,d3
    fmul d2,d2,d10
    fdiv d2,d2,d8
    str d2,[x22,#88]
    fmul d13,d12,d12
    fmul d0,d0,d0
    fdiv d13,d13,d0
    ldr d0,[x24,#168]
    fmul d0,d0,d13
    str d0,[x22,#96]
    time_address x9,x19,4150784
    str d0,[x9]
    ldr d0,[x22,#80]
    bl md2asm_time_update_cosine
    str d0,[x22,#104]
    ldr d0,[x22,#80]
    bl md2asm_time_update_sine
    str d0,[x22,#112]
    ldr d0,[x22,#88]
    bl md2asm_time_update_cosine
    str d0,[x22,#120]
    ldr d0,[x22,#88]
    bl md2asm_time_update_sine
    str d0,[x22,#128]
/* The separately accepted coefficient child owns all six source writes. */
    mov x0,x19
    ldr x1,=4275088
    ldr x2,[sp,#184]
    ldr x9,[sp,#320]
    ldr x3,[x9]
    bl md2asm_update_operational_time_coefficients
    cbnz w0,.Ltime_reason_65201
/* The radiation clock repeats the stored-step expression before monthly work. */
    fcvtas w28,d9
    str w28,[sp,#264]
    scvtf d0,w27
    fmov d1,#0.5
    fadd d0,d0,d1
    fmul d0,d9,d0
    fcvtas w11,d0
    scvtf d14,w11
    ldr w12,[x23,#12]
    sub w12,w12,#1
    scvtf d0,w12
    fmul d0,d1,d0
    scvtf d1,w28
    fmul d0,d0,d1
    fadd d14,d14,d0
    fcvtas w12,d8
    sdiv w13,w11,w12
    msub w13,w13,w12,w11
    str w13,[sp,#268]
    time_live_load d15,8,51744
    fadd d15,d15,d14
    fcvtas w11,d14
    time_live_load w13,8,51740
    add w11,w11,w13
    sdiv w13,w11,w12
    msub w11,w13,w12,w11
    scvtf d0,w11
    str d0,[sp,#288]
    mov x0,x24
    mov x1,#176
    add x2,sp,#336
    bl md2asm_update_owned_radiation_forcing
    cbnz w0,.Ltime_reason_65202
    ldr d0,[x24,#168]
    fmul d0,d0,d13
    str d0,[x22,#96]
    time_address x9,x19,4150784
    str d0,[x9]
    mov w9,#1
    str w9,[sp,#272]
    fmov d0,d15
    add x0,sp,#240
    bl md2asm_runtime_orbital_illumination
    mov w9,#8
    sdiv w10,w27,w9
    msub w10,w10,w9,w27
    cbnz w10,.Ltime_after_radiation_angles
    ldr d0,[sp,#256]
    ldr d1,[sp,#288]
    fadd d0,d0,d1
    str d0,[x26,#32]
    fmov d1,#2.0
    fmul d0,d0,d1
    fmul d0,d0,d10
    fdiv d0,d0,d8
    str d0,[x26,#40]
    ldr d0,[sp,#248]
    bl md2asm_time_update_cosine
    str d0,[x26,#0]
    ldr d0,[sp,#248]
    bl md2asm_time_update_sine
    str d0,[x26,#8]
    ldr d0,[x26,#40]
    bl md2asm_time_update_cosine
    str d0,[x26,#16]
    ldr d0,[x26,#40]
    bl md2asm_time_update_sine
    str d0,[x26,#24]
.Ltime_after_radiation_angles:
/* The cancellation in the source ozone angle retains both rounded operations. */
    ldr d0,[sp,#280]
    adr x9,.Ltime_constants
    ldp d1,d2,[x9,#16]
    fmul d0,d2,d0
    fadd d0,d1,d0
    fsub d0,d0,d1
    str d0,[sp,#296]
    add x0,sp,#296
    add x1,x22,#312
    bl md2asm_operational_yearly_ozone_cycle
    mov w9,#8
    sdiv w10,w27,w9
    msub w10,w10,w9,w27
    cbnz w10,.Ltime_after_monthly
    time_live_load w9,8,51740
    scvtf d0,w9
    fadd d0,d14,d0
    adr x9,.Ltime_constants
    ldr d1,[x9,#32]
    fdiv d0,d0,d1
    fcvtas w9,d0
    str w9,[sp,#276]
    mov x0,x23
    mov x1,x24
    add x2,x22,#312
    time_live_address x3,8,51736
    add x4,sp,#276
    ldr x9,[sp,#320]
    ldr x5,[x9]
    bl md2asm_update_operational_monthly_ozone
    cbnz w0,.Ltime_reason_65203
    mov x0,x23
    mov x1,x24
    time_live_address x2,8,51736
    add x3,sp,#276
    ldr x4,[sp,#176]
    add x5,sp,#272
    add x6,sp,#464
    bl md2asm_update_runtime_monthly_greenhouse
    cbnz w0,.Ltime_reason_65204
    mov x0,x20
    mov x1,x23
    mov x2,x22
    time_live_address x3,8,51736
    add x4,sp,#276
    ldr x9,[sp,#320]
    ldr x5,[x9,#24]
    bl md2asm_update_runtime_monthly_aerosol
    cbnz w0,.Ltime_reason_65205
.Ltime_after_monthly:
    mov w0,#0
    b .Ltime_prefix_agree
.Ltime_prefix_failure:
.Ltime_prefix_agree:
    bl .Ltime_collective_status
    cbnz w0,.Ltime_restore
/* Preserve the original daily climate, ozone chemistry and gas order. */
    ldr w9,[sp,#268]
    cmp w9,w28
    b.ge .Ltime_return
    time_address x9,x19,1562896
    ldr w9,[x9]
    cbz w9,.Ltime_after_climate
    ldr x9,[sp,#200]
    ldr w9,[x9]
    cbz w9,.Ltime_after_climate
    mov x0,x20
    mov x1,x19
    mov x2,x21
    ldr x3,[sp,#192]
    ldr x9,[sp,#320]
    ldr x4,[x9,#48]
    ldr x9,[x4,#40]
    str x9,[sp,#480]
    ldr x9,[sp,#176]
    str x9,[x4,#40]
    bl md2asm_update_runtime_operational_climate
    ldr x9,[sp,#320]
    ldr x9,[x9,#48]
    ldr x10,[sp,#480]
    str x10,[x9,#40]
    cbnz w0,.Ltime_reason_65206
.Ltime_after_climate:
    mov x0,x20
    mov x1,x19
    add x2,sp,#448
    ldr x9,[sp,#320]
    ldr x3,[x9]
    ldr x4,[x9,#32]
    ldr x5,[x9,#40]
    bl md2asm_update_runtime_ozone_chemistry
    cbnz w0,.Ltime_reason_65207
    mov x0,x24
    mov x1,#176
    add x2,sp,#336
    bl md2asm_update_owned_radiation_forcing
    cbnz w0,.Ltime_reason_65208
.Ltime_return:
    mov w0,#0
.Ltime_exit:
    bl .Ltime_collective_status
.Ltime_restore:
    ldp x19,x20,[sp,#0]
    ldp x21,x22,[sp,#16]
    ldp x23,x24,[sp,#32]
    ldp x25,x26,[sp,#48]
    ldp x27,x28,[sp,#64]
    ldp x29,x30,[sp,#80]
    ldr x18,[sp,#96]
    ldp d8,d9,[sp,#112]
    ldp d10,d11,[sp,#128]
    ldp d12,d13,[sp,#144]
    ldp d14,d15,[sp,#160]
    add sp,sp,#512
    ret
.size md2asm_runtime_model_time_and_forcing_with_failure_reason,.-md2asm_runtime_model_time_and_forcing_with_failure_reason
.Ltime_reject:
    mov w0,#2
    b .Ltime_collective_status
.p2align 2
.type .Ltime_collective_status,%function
.Ltime_collective_status:
 stp x29,x30,[sp,#-80]!
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 str w0,[sp,#48]
 cbz w0,.Ltime_status_without_incoming_reason
 str x1,[sp,#64]
.Ltime_status_without_incoming_reason:
 mrs x19,fpsr
 mrs x20,fpcr
 bl __errno_location
 mov x21,x0
 ldr w9,[x21]
 str w9,[sp,#52]
 add x0,sp,#48
 add x1,sp,#56
 mov w2,#1
 mov w3,#0x0405
 movk w3,#0x4c00,lsl#16
 mov w4,#1
 movk w4,#0x5800,lsl#16
 mov w5,#0x44000000
 bl MPI_Allreduce
 cbnz w0,.Ltime_mpi_abort
 ldr w9,[sp,#52]
 str w9,[x21]
 msr fpcr,x20
 msr fpsr,x19
 ldr w0,[sp,#56]
 cbz w0,.Ltime_status_return_without_reason
 ldr w9,[sp,#48]
 cbz w9,.Ltime_status_remote_reason
 ldr x1,[sp,#64]
 b .Ltime_status_return_without_reason
.Ltime_status_remote_reason:
 mov x1,#65300
.Ltime_status_return_without_reason:
 ldp x20,x21,[sp,#32]
 ldp x18,x19,[sp,#16]
 ldp x29,x30,[sp],#80
 ret
.Ltime_mpi_abort:
 mov w0,#0x44000000
 mov w1,#3
 bl MPI_Abort
 brk #0
.size .Ltime_collective_status,.-.Ltime_collective_status
.Ltime_reason_65001:
    mov x1,#65001
    b .Ltime_reject
.Ltime_reason_65002:
    mov x1,#65002
    b .Ltime_reject
.Ltime_reason_65003:
    mov x1,#65003
    b .Ltime_reject
.Ltime_reason_65004:
    mov x1,#65004
    b .Ltime_reject
.Ltime_reason_65005:
    mov x1,#65005
    b .Ltime_reject
.Ltime_reason_65006:
    mov x1,#65006
    b .Ltime_reject
.Ltime_reason_65007:
    mov x1,#65007
    b .Ltime_reject
.Ltime_reason_65008:
    mov x1,#65008
    b .Ltime_reject
.Ltime_reason_65009:
    mov x1,#65009
    b .Ltime_reject
.Ltime_reason_65010:
    mov x1,#65010
    b .Ltime_reject
.Ltime_reason_65011:
    mov x1,#65011
    b .Ltime_reject
.Ltime_reason_65012:
    mov x1,#65012
    b .Ltime_reject
.Ltime_reason_65013:
    mov x1,#65013
    b .Ltime_reject
.Ltime_reason_65014:
    mov x1,#65014
    b .Ltime_reject
.Ltime_reason_65015:
    mov x1,#65015
    b .Ltime_reject
.Ltime_reason_65016:
    mov x1,#65016
    b .Ltime_reject
.Ltime_reason_65017:
    mov x1,#65017
    b .Ltime_reject
.Ltime_reason_65018:
    mov x1,#65018
    b .Ltime_reject
.Ltime_reason_65019:
    mov x1,#65019
    b .Ltime_reject
.Ltime_reason_65020:
    mov x1,#65020
    b .Ltime_reject
.Ltime_reason_65021:
    mov x1,#65021
    b .Ltime_reject
.Ltime_reason_65022:
    mov x1,#65022
    b .Ltime_reject
.Ltime_reason_65023:
    mov x1,#65023
    b .Ltime_reject
.Ltime_reason_65024:
    mov x1,#65024
    b .Ltime_reject
.Ltime_reason_65025:
    mov x1,#65025
    b .Ltime_reject
.Ltime_reason_65026:
    mov x1,#65026
    b .Ltime_reject
.Ltime_reason_65027:
    mov x1,#65027
    b .Ltime_reject
.Ltime_reason_65028:
    mov x1,#65028
    b .Ltime_reject
.Ltime_reason_65029:
    mov x1,#65029
    b .Ltime_reject
.Ltime_reason_65030:
    mov x1,#65030
    b .Ltime_reject
.Ltime_reason_65031:
    mov x1,#65031
    b .Ltime_reject
.Ltime_reason_65032:
    mov x1,#65032
    b .Ltime_reject
.Ltime_reason_65033:
    mov x1,#65033
    b .Ltime_reject
.Ltime_reason_65034:
    mov x1,#65034
    b .Ltime_reject
.Ltime_reason_65035:
    mov x1,#65035
    b .Ltime_reject
.Ltime_reason_65036:
    mov x1,#65036
    b .Ltime_reject
.Ltime_reason_65037:
    mov x1,#65037
    b .Ltime_reject
.Ltime_reason_65038:
    mov x1,#65038
    b .Ltime_reject
.Ltime_reason_65039:
    mov x1,#65039
    b .Ltime_reject
.Ltime_reason_65040:
    mov x1,#65040
    b .Ltime_reject
.Ltime_reason_65041:
    mov x1,#65041
    b .Ltime_reject
.Ltime_reason_65042:
    mov x1,#65042
    b .Ltime_reject
.Ltime_reason_65043:
    mov x1,#65043
    b .Ltime_reject
.Ltime_reason_65044:
    mov x1,#65044
    b .Ltime_reject
.Ltime_reason_65045:
    mov x1,#65045
    b .Ltime_reject
.Ltime_reason_65046:
    mov x1,#65046
    b .Ltime_reject
.Ltime_reason_65047:
    mov x1,#65047
    b .Ltime_reject
.Ltime_reason_65048:
    mov x1,#65048
    b .Ltime_reject
.Ltime_reason_65049:
    mov x1,#65049
    b .Ltime_reject
.Ltime_reason_65050:
    mov x1,#65050
    b .Ltime_reject
.Ltime_reason_65051:
    mov x1,#65051
    b .Ltime_reject
.Ltime_reason_65052:
    mov x1,#65052
    b .Ltime_reject
.Ltime_reason_65053:
    mov x1,#65053
    b .Ltime_reject
.Ltime_reason_65054:
    mov x1,#65054
    b .Ltime_reject
.Ltime_reason_65055:
    mov x1,#65055
    b .Ltime_reject
.Ltime_reason_65056:
    mov x1,#65056
    b .Ltime_reject
.Ltime_reason_65057:
    mov x1,#65057
    b .Ltime_reject
.Ltime_reason_65058:
    mov x1,#65058
    b .Ltime_reject
.Ltime_reason_65059:
    mov x1,#65059
    b .Ltime_reject
.Ltime_reason_65060:
    mov x1,#65060
    b .Ltime_reject
.Ltime_reason_65061:
    mov x1,#65061
    b .Ltime_reject
.Ltime_reason_65062:
    mov x1,#65062
    b .Ltime_reject
.Ltime_reason_65063:
    mov x1,#65063
    b .Ltime_reject
.Ltime_reason_65064:
    mov x1,#65064
    b .Ltime_reject
.Ltime_reason_65065:
    mov x1,#65065
    b .Ltime_reject
.Ltime_reason_65066:
    mov x1,#65066
    b .Ltime_reject
.Ltime_reason_65067:
    mov x1,#65067
    b .Ltime_reject
.Ltime_reason_65068:
    mov x1,#65068
    b .Ltime_reject
.Ltime_reason_65069:
    mov x1,#65069
    b .Ltime_reject
.Ltime_reason_65070:
    mov x1,#65070
    b .Ltime_reject
.Ltime_reason_65071:
    mov x1,#65071
    b .Ltime_reject
.Ltime_reason_65072:
    mov x1,#65072
    b .Ltime_reject
.Ltime_reason_65073:
    mov x1,#65073
    b .Ltime_reject
.Ltime_reason_65074:
    mov x1,#65074
    b .Ltime_reject
.Ltime_reason_65075:
    mov x1,#65075
    b .Ltime_reject
.Ltime_reason_65076:
    mov x1,#65076
    b .Ltime_reject
.Ltime_reason_65077:
    mov x1,#65077
    b .Ltime_reject
.Ltime_reason_65078:
    mov x1,#65078
    b .Ltime_reject
.Ltime_reason_65079:
    mov x1,#65079
    b .Ltime_reject
.Ltime_reason_65080:
    mov x1,#65080
    b .Ltime_reject
.Ltime_reason_65081:
    mov x1,#65081
    b .Ltime_reject
.Ltime_reason_65082:
    mov x1,#65082
    b .Ltime_reject
.Ltime_reason_65083:
    mov x1,#65083
    b .Ltime_reject
.Ltime_reason_65084:
    mov x1,#65084
    b .Ltime_reject
.Ltime_reason_65085:
    mov x1,#65085
    b .Ltime_reject
.Ltime_reason_65086:
    mov x1,#65086
    b .Ltime_reject
.Ltime_reason_65087:
    mov x1,#65087
    b .Ltime_reject
.Ltime_reason_65088:
    mov x1,#65088
    b .Ltime_reject
.Ltime_reason_65089:
    mov x1,#65089
    b .Ltime_reject
.Ltime_reason_65090:
    mov x1,#65090
    b .Ltime_reject
.Ltime_reason_65091:
    mov x1,#65091
    b .Ltime_reject
.Ltime_reason_65092:
    mov x1,#65092
    b .Ltime_reject
.Ltime_reason_65093:
    mov x1,#65093
    b .Ltime_reject
.Ltime_reason_65094:
    mov x1,#65094
    b .Ltime_reject
.Ltime_reason_65095:
    mov x1,#65095
    b .Ltime_reject
.Ltime_reason_65096:
    mov x1,#65096
    b .Ltime_reject
.Ltime_reason_65097:
    mov x1,#65097
    b .Ltime_reject
.Ltime_reason_65098:
    mov x1,#65098
    b .Ltime_reject
.Ltime_reason_65099:
    mov x1,#65099
    b .Ltime_reject
.Ltime_reason_65100:
    mov x1,#65100
    b .Ltime_reject
.Ltime_reason_65101:
    mov x1,#65101
    b .Ltime_reject
.Ltime_reason_65102:
    mov x1,#65102
    b .Ltime_reject
.Ltime_reason_65103:
    mov x1,#65103
    b .Ltime_reject
.Ltime_reason_65104:
    mov x1,#65104
    b .Ltime_reject
.Ltime_reason_65105:
    mov x1,#65105
    b .Ltime_reject
.Ltime_reason_65106:
    mov x1,#65106
    b .Ltime_reject
.Ltime_reason_65107:
    mov x1,#65107
    b .Ltime_reject
.Ltime_reason_65108:
    mov x1,#65108
    b .Ltime_reject
.Ltime_reason_65109:
    mov x1,#65109
    b .Ltime_reject
.Ltime_reason_65110:
    mov x1,#65110
    b .Ltime_reject
.Ltime_reason_65111:
    mov x1,#65111
    b .Ltime_reject
.Ltime_reason_65112:
    mov x1,#65112
    b .Ltime_reject
.Ltime_reason_65113:
    mov x1,#65113
    b .Ltime_reject
.Ltime_reason_65114:
    mov x1,#65114
    b .Ltime_reject
.Ltime_reason_65115:
    mov x1,#65115
    b .Ltime_reject
.Ltime_reason_65116:
    mov x1,#65116
    b .Ltime_reject
.Ltime_reason_65117:
    mov x1,#65117
    b .Ltime_reject
.Ltime_reason_65118:
    mov x1,#65118
    b .Ltime_reject
.Ltime_reason_65119:
    mov x1,#65119
    b .Ltime_reject
.Ltime_reason_65120:
    mov x1,#65120
    b .Ltime_reject
.Ltime_reason_65121:
    mov x1,#65121
    b .Ltime_reject
.Ltime_reason_65122:
    mov x1,#65122
    b .Ltime_reject
.Ltime_reason_65123:
    mov x1,#65123
    b .Ltime_reject
.Ltime_reason_65124:
    mov x1,#65124
    b .Ltime_reject
.Ltime_reason_65125:
    mov x1,#65125
    b .Ltime_reject
.Ltime_reason_65126:
    mov x1,#65126
    b .Ltime_reject
.Ltime_reason_65127:
    mov x1,#65127
    b .Ltime_reject
.Ltime_reason_65201:
    mov x1,#65201
    b .Ltime_prefix_failure
.Ltime_reason_65202:
    mov x1,#65202
    b .Ltime_prefix_failure
.Ltime_reason_65203:
    mov x1,#65203
    b .Ltime_prefix_failure
.Ltime_reason_65204:
    mov x1,#65204
    b .Ltime_prefix_failure
.Ltime_reason_65205:
    mov x1,#65205
    b .Ltime_prefix_failure
.Ltime_reason_65206:
    mov x1,#65206
    b .Ltime_exit
.Ltime_reason_65207:
    mov x1,#65207
    b .Ltime_exit
.Ltime_reason_65208:
    mov x1,#65208
    b .Ltime_exit
.section .rodata
.p2align 3
.Ltime_constants:
    .double 450.0,365.25,1.7535,6.283076,60.0
.p2align 3
.Ltime_required_constants:
    .double 3.141592653589793,86400.0,149597870000.0,0.409093,835272000.0
.section .note.GNU-stack,"",%progbits

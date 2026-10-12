/* Complete trajectory-wind preparation, contract revision 3.
 * Physics input formulations/openifs/trajectories/wind_for_parcel_trajectories.md, revision 1.
 * Contract skills/md2asm/references/openifs/trajectories/trajectory_wind_preparation.md, revision 3.
 * Original lavent_ interface has 19 addresses and preserves the full Arm ABI.
 * The embedded helper uses ordered pairs of FP64 values. */
.text
.p2align 4
.global lavent_
.set lavent_,md2asm_trajectory_wind_r3
.global md2asm_trajectory_wind_r3
.type md2asm_trajectory_wind_r3,%function
md2asm_trajectory_wind_r3:
mov x9,sp
sub sp,sp,#640
stp x18,x19,[sp,#0]
stp x20,x21,[sp,#16]
stp x22,x23,[sp,#32]
stp x24,x25,[sp,#48]
stp x26,x27,[sp,#64]
stp x28,x29,[sp,#80]
str x30,[sp,#96]
stp d8,d9,[sp,#112]
stp d10,d11,[sp,#128]
stp d12,d13,[sp,#144]
stp d14,d15,[sp,#160]
stp x0,x1,[sp,#176]
stp x2,x3,[sp,#192]
stp x4,x5,[sp,#208]
stp x6,x7,[sp,#224]
ldp x10,x11,[x9,#0]
stp x10,x11,[sp,#240]
ldp x10,x11,[x9,#16]
stp x10,x11,[sp,#256]
ldp x10,x11,[x9,#32]
stp x10,x11,[sp,#272]
ldp x10,x11,[x9,#48]
stp x10,x11,[sp,#288]
ldp x10,x11,[x9,#64]
stp x10,x11,[sp,#304]
ldr x10,[x9,#80]
str x10,[sp,#320]
mrs x9,fpcr
cbnz x9,.Lreject
/* Selected carrier dimensions and flags, checked before outputs. */
ldr w9,[x0,#5144]
cmp w9,#24
b.ne .Lreject
ldr w9,[x0,#5160]
cmp w9,#86
b.ne .Lreject
ldr w9,[x0,#5224]
cmp w9,#19
b.ne .Lreject
ldr w9,[x0,#5244]
cbnz w9,.Lreject
ldr w9,[x0,#3076]
cmp w9,#1
b.ne .Lreject
ldr w9,[x1,#992]
cmp w9,#18
b.ne .Lreject
ldr w9,[x3,#3036]
cbnz w9,.Lreject
ldr w9,[x3,#4944]
cmp w9,#2
b.ne .Lreject
ldr w9,[x3,#4660]
cbnz w9,.Lreject
ldr w9,[x3,#4644]
cmp w9,#3
b.ne .Lreject
/* Frozen source field maps. */
ldr w9,[x1,#1012]
cmp w9,#3
b.ne .Lreject
ldr w9,[x1,#1016]
cmp w9,#4
b.ne .Lreject
ldr w9,[x1,#1116]
cmp w9,#10
b.ne .Lreject
ldr w9,[x1,#1120]
cmp w9,#11
b.ne .Lreject
ldr w9,[x1,#1136]
cmp w9,#12
b.ne .Lreject
mov x10,#8880
ldr w9,[x3,x10]
cmp w9,#463
b.ne .Lreject
mov x10,#8992
ldr w9,[x3,x10]
cmp w9,#191
b.ne .Lreject
mov x10,#8996
ldr w9,[x3,x10]
cmp w9,#212
b.ne .Lreject
mov x10,#9000
ldr w9,[x3,x10]
cmp w9,#233
b.ne .Lreject
mov x10,#9004
ldr w9,[x3,x10]
cmp w9,#254
b.ne .Lreject
mov x10,#9184
ldr w9,[x3,x10]
cmp w9,#153
b.ne .Lreject
mov x10,#9228
ldr w9,[x3,x10]
cmp w9,#78
b.ne .Lreject
mov x10,#9232
ldr w9,[x3,x10]
cmp w9,#97
b.ne .Lreject
mov x10,#9236
ldr w9,[x3,x10]
cmp w9,#116
b.ne .Lreject
mov x10,#9240
ldr w9,[x3,x10]
cmp w9,#135
b.ne .Lreject
/* All selected true and false dynamics flags. */
ldr w9,[x3,#20]
cmp w9,#1
b.ne .Lreject
ldr w9,[x3,#284]
cmp w9,#1
b.ne .Lreject
ldr w9,[x3,#288]
cmp w9,#1
b.ne .Lreject
ldr w9,[x3,#4696]
cmp w9,#1
b.ne .Lreject
ldr w9,[x3,#4756]
cmp w9,#1
b.ne .Lreject
ldr w9,[x3,#4764]
cmp w9,#1
b.ne .Lreject
ldr w9,[x3,#4768]
cmp w9,#1
b.ne .Lreject
ldr w9,[x3,#296]
cbnz w9,.Lreject
ldr w9,[x3,#272]
cbnz w9,.Lreject
ldr w9,[x3,#276]
cbnz w9,.Lreject
ldr w9,[x3,#336]
cbnz w9,.Lreject
ldr w9,[x3,#340]
cbnz w9,.Lreject
ldr w9,[x3,#4700]
cbnz w9,.Lreject
ldr w9,[x3,#4704]
cbnz w9,.Lreject
ldr w9,[x3,#4924]
cbnz w9,.Lreject
ldr w9,[x3,#4752]
cbnz w9,.Lreject
ldr w9,[x3,#4760]
cbnz w9,.Lreject
ldr x9,[sp,#248]
ldr w9,[x9]
cbnz w9,.Lreject
ldr w9,[x2,#24]
cbnz w9,.Lreject
ldr w9,[x4,#452]
cbnz w9,.Lreject
ldr w9,[x5]
cmp w9,#1
b.lt .Lreject
cmp w9,#24
b.gt .Lreject
sub w21,w9,#1
ldr w22,[x6]
cmp w22,#24
b.gt .Lreject
cmp w22,#0
b.lt .Lreject
ldr w9,[x7]
cmp w9,#1
b.lt .Lreject
cmp w9,#86
b.gt .Lreject
str w9,[sp,#340]
cmp w9,#86
b.ne .Lblock_bound_done
cmp w22,#8
b.gt .Lreject
.Lblock_bound_done:
ldr w9,[x0,#7376]
cmp w9,#2048
b.ne .Lreject
/* Current forecast step is a consumed global. */
adrp x9,:got:__yomct3_MOD_nstep
ldr x9,[x9,:got_lo12:__yomct3_MOD_nstep]
ldr w9,[x9]
cmp w9,#0
b.lt .Lreject
str w9,[sp,#328]
/* Profile entry does not supply a numerical stage. */
adrp x9,:got:__yomhook_MOD_lhook
ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
ldr w9,[x9]
str w9,[sp,#536]
cbz w9,.Lafter_hook_entry
adrp x0,.Lwind_name
add x0,x0,:lo12:.Lwind_name
str wzr,[sp,#540]
add x1,sp,#540
add x2,sp,#544
mov x3,#6
bl __yomhook_MOD_dr_hook_default8
.Lafter_hook_entry:
ldr x0,[sp,#176]
ldr x3,[sp,#200]
ldr x9,[x0,#3248]
ldr x9,[x9,#0]
str x9,[sp,#376]
ldr d9,[x3,#4952]
ldr d8,[x3,#4960]
ldr w10,[sp,#340]
sub w10,w10,#1
mov x11,#1472
mul x10,x10,x11
ldr x9,[x0,#8472]
add x9,x9,x10
ldr x10,[x9,#128]
str x10,[sp,#344]
ldr x10,[x9,#192]
str x10,[sp,#352]
ldr x10,[x9,#384]
str x10,[sp,#360]
ldr x10,[x9,#448]
str x10,[sp,#368]
ldr x23,[sp,#288]
ldr x24,[sp,#296]
ldr x25,[sp,#304]
ldr x26,[sp,#264]
ldr x27,[sp,#272]
ldr x28,[sp,#312]
/* Field starts follow the frozen named maps. */
mov x9,#7296
add x10,x23,x9
str x10,[sp,#416]
mov x9,#10944
add x10,x23,x9
str x10,[sp,#424]
mov x9,#32832
add x10,x23,x9
str x10,[sp,#432]
mov x9,#36480
add x10,x23,x9
str x10,[sp,#440]
mov x9,#40128
add x10,x23,x9
str x10,[sp,#448]
mov x9,#36672
add x10,x24,x9
str x10,[sp,#464]
mov x9,#40704
add x10,x24,x9
str x10,[sp,#472]
mov x9,#44736
add x10,x24,x9
str x10,[sp,#480]
mov x9,#48768
add x10,x24,x9
str x10,[sp,#488]
mov x9,#14784
add x10,x25,x9
str x10,[sp,#496]
mov x9,#18432
add x10,x25,x9
str x10,[sp,#504]
mov x9,#25728
add x10,x25,x9
str x10,[sp,#512]
mov x9,#22080
add x10,x25,x9
str x10,[sp,#520]
/* Consumed values are checked as integer encodings before any output write. */
fmov x10,d8
bl .Lpositive_finite
fmov x10,d9
bl .Lpositive_finite
ldr x12,[sp,#376]
mov x13,#0
.Lcheck_eta:
ldr x10,[x12,x13,lsl#3]
bl .Lfinite
add x13,x13,#1
cmp x13,#20
b.lo .Lcheck_eta
mov x13,x21
.Lcheck_coords:
cmp x13,x22
b.hs .Lcheck_cells_start
ldr x12,[sp,#344]
ldr x10,[x12,x13,lsl#3]
bl .Lfinite
ldr x12,[sp,#352]
ldr x10,[x12,x13,lsl#3]
bl .Lfinite
ldr x12,[sp,#360]
ldr x10,[x12,x13,lsl#3]
bl .Lfinite
ldr x12,[sp,#368]
ldr x10,[x12,x13,lsl#3]
bl .Lfinite
add x13,x13,#1
b .Lcheck_coords
.Lcheck_cells_start:
mov x13,#0
.Lcheck_cell_level:
mov x14,x21
.Lcheck_cell_row:
cmp x14,x22
b.hs .Lcheck_next_level
mov x9,#24
madd x9,x13,x9,x14
add x15,x9,#24
ldr x10,[x27,x15,lsl#3]
bl .Lfinite
ldr x10,[x26,x9,lsl#3]
bl .Lpositive_finite
ldr x12,[sp,#416]
ldr x10,[x12,x9,lsl#3]
bl .Lfinite
ldr x12,[sp,#424]
ldr x10,[x12,x9,lsl#3]
bl .Lfinite
ldr w12,[sp,#328]
cbz w12,.Lcheck_old_done
ldr x12,[sp,#432]
ldr x10,[x12,x9,lsl#3]
bl .Lfinite
ldr x12,[sp,#440]
ldr x10,[x12,x9,lsl#3]
bl .Lfinite
ldr x12,[sp,#448]
ldr x10,[x12,x9,lsl#3]
bl .Lfinite
.Lcheck_old_done:
add x14,x14,#1
b .Lcheck_cell_row
.Lcheck_next_level:
add x13,x13,#1
cmp x13,#19
b.lo .Lcheck_cell_level
/* The cell dependency graph is independent under the frozen non-overlap guard. */
mov x19,#0
.Llevel:
ldr x9,[sp,#376]
ldr d0,[x9,x19,lsl#3]
add x10,x19,#1
ldr d1,[x9,x10,lsl#3]
fsub d10,d1,d0
ldr w9,[sp,#328]
cbz w9,.Lcounter_done
cmp x19,#2
b.hs .Lcounter_done
ldr x9,[sp,#240]
str wzr,[x9,x19,lsl#2]
.Lcounter_done:
mov x20,x21
.Lrow:
cmp x20,x22
b.hs .Lnext_level
mov x9,#24
madd x9,x19,x9,x20
add x10,x9,#24
ldr d11,[x27,x10,lsl#3]
fmul d11,d11,d10
ldr d0,[x26,x9,lsl#3]
fmul d11,d11,d0
ldr x10,[sp,#416]
ldr d13,[x10,x9,lsl#3]
ldr x10,[sp,#424]
ldr d14,[x10,x9,lsl#3]
ldr w10,[sp,#328]
cbz w10,.Linitial
ldr x10,[sp,#432]
ldr d0,[x10,x9,lsl#3]
fmov d1,#2.0
fmul d2,d1,d13
fsub d2,d2,d0
ldr x10,[sp,#440]
ldr d0,[x10,x9,lsl#3]
fmul d3,d1,d14
fsub d3,d3,d0
str d2,[sp,#560]
str d3,[sp,#568]
ldr x10,[sp,#448]
ldr d12,[x10,x9,lsl#3]
cmp x19,#2
b.hs .Lunfiltered
fmul d0,d11,d12
fadd d0,d0,d8
fneg d1,d9
fmul d0,d1,d0
bl .Lcounted_tanh
fmov d1,#1.0
fsub d0,d1,d0
fmov d1,#0.5
fmul d0,d1,d0
fsub d1,d11,d12
fmul d0,d0,d1
fadd d0,d11,d0
b .Lvertical_done
.Lunfiltered:
fmov d0,#2.0
fmul d0,d0,d11
fsub d0,d0,d12
.Lvertical_done:
str d0,[sp,#576]
b .Lwrite
.Linitial:
str d13,[sp,#560]
str d14,[sp,#568]
str d11,[sp,#576]
fmov d12,xzr
.Lwrite:
mov x9,#24
madd x9,x19,x9,x20
ldr x10,[sp,#488]
ldr d0,[sp,#576]
str d0,[x10,x9,lsl#3]
ldr x10,[sp,#520]
str d11,[x10,x9,lsl#3]
str d12,[x28,x9,lsl#3]
ldr x10,[sp,#448]
str d11,[x10,x9,lsl#3]
ldr x10,[sp,#320]
str xzr,[x10,x9,lsl#3]
/* Coordinates are the actual selected block's original rounded factors. */
ldr x10,[sp,#344]
ldr d0,[x10,x20,lsl#3]
ldr x10,[sp,#352]
ldr d1,[x10,x20,lsl#3]
ldr x10,[sp,#360]
ldr d2,[x10,x20,lsl#3]
ldr x10,[sp,#368]
ldr d3,[x10,x20,lsl#3]
ldr d4,[sp,#560]
ldr d5,[sp,#568]
fmul d6,d5,d1
ldr x10,[sp,#480]
str d6,[x10,x9,lsl#3]
fneg d6,d4
fmul d6,d6,d3
fmul d7,d5,d2
fmul d7,d7,d0
fsub d6,d6,d7
ldr x10,[sp,#464]
str d6,[x10,x9,lsl#3]
fmul d6,d4,d2
fmul d7,d5,d3
fmul d7,d7,d0
fsub d6,d6,d7
ldr x10,[sp,#472]
str d6,[x10,x9,lsl#3]
/* Current wind receives the same independently verified projection. */
fmul d6,d14,d1
ldr x10,[sp,#512]
str d6,[x10,x9,lsl#3]
fneg d6,d13
fmul d6,d6,d3
fmul d7,d14,d2
fmul d7,d7,d0
fsub d6,d6,d7
ldr x10,[sp,#496]
str d6,[x10,x9,lsl#3]
fmul d6,d13,d2
fmul d7,d14,d3
fmul d7,d7,d0
fsub d6,d6,d7
ldr x10,[sp,#504]
str d6,[x10,x9,lsl#3]
add x20,x20,#1
b .Lrow
.Lnext_level:
add x19,x19,#1
cmp x19,#19
b.lo .Llevel
ldr w9,[sp,#536]
cbz w9,.Lreturn
adrp x0,.Lwind_name
add x0,x0,:lo12:.Lwind_name
mov w9,#1
str w9,[sp,#540]
add x1,sp,#540
add x2,sp,#544
mov x3,#6
bl __yomhook_MOD_dr_hook_default8
.Lreturn:
adrp x9,.Lparent_count
add x9,x9,:lo12:.Lparent_count
ldr x10,[x9]
add x10,x10,#1
str x10,[x9]
ldp d8,d9,[sp,#112]
ldp d10,d11,[sp,#128]
ldp d12,d13,[sp,#144]
ldp d14,d15,[sp,#160]
ldp x18,x19,[sp,#0]
ldp x20,x21,[sp,#16]
ldp x22,x23,[sp,#32]
ldp x24,x25,[sp,#48]
ldp x26,x27,[sp,#64]
ldp x28,x29,[sp,#80]
ldr x30,[sp,#96]
add sp,sp,#640
ret
.Lreject:
bl abort
brk #0
.size md2asm_trajectory_wind_r3,.-md2asm_trajectory_wind_r3
/* Helpers change only caller-saved integer scratch and the stated counter. */
.Lfinite:
ubfx x11,x10,#52,#11
cmp x11,#2047
b.eq .Lreject
ret
.Lpositive_finite:
tbnz x10,#63,.Lreject
cbz x10,.Lreject
b .Lfinite
.Lcounted_tanh:
adrp x9,.Ltanh_count
add x9,x9,:lo12:.Ltanh_count
ldr x10,[x9]
add x10,x10,#1
str x10,[x9]
b md2asm_tanh_accuracy_r3
.global md2asm_trajectory_wind_count_get
md2asm_trajectory_wind_count_get:
adrp x9,.Lparent_count
ldr x0,[x9,:lo12:.Lparent_count]
ret
.global md2asm_trajectory_tanh_count_get
md2asm_trajectory_tanh_count_get:
adrp x9,.Ltanh_count
ldr x0,[x9,:lo12:.Ltanh_count]
ret
.section .bss
.p2align 3
.Lparent_count:
.skip 8
.Ltanh_count:
.skip 8
.section .rodata
.Lwind_name:
.ascii "LAVENT"
.section .note.GNU-stack,"",%progbits

/* Private directly emitted elementary revision3. */
.hidden md2asm_tanh_accuracy_r3
// Private direct TANH accuracy route. Frozen source: private_tanh_control_r1.c.
// Each FP64 arithmetic instruction follows one written source operation.
// ABI: d0 is the finite input and result. x18 is untouched; low d8..d15
// and x19..x29 are preserved. SP stays aligned to 16 bytes.
// Only abort is external, and only rejected nonfinite inputs reach it.
.text
.p2align 2
.global md2asm_tanh_accuracy_r3
.type md2asm_tanh_accuracy_r3,%function
md2asm_tanh_accuracy_r3:
 fmov x9,d0
 and x10,x9,#0x7fffffffffffffff
 movz x11,#0x7ff0,lsl #48
 cmp x10,x11
 b.hs .Ltanh_reject
 movz x11,#0x3e40,lsl #48
 cmp x10,x11
 b.ls .Ltanh_return_input
 movz x11,#0x4034,lsl #48
 cmp x10,x11
 b.hs .Ltanh_saturated
 stp x29,x30,[sp,#-96]!
 mov x29,sp
 stp d8,d9,[sp,#16]
 stp d10,d11,[sp,#32]
 stp d12,d13,[sp,#48]
 stp d14,d15,[sp,#64]
 str x9,[sp,#80]
 fmov d8,x10
 adr x12,.Ltanh_constants
 ldr d16,[x12,#8]
 fmul d8,d8,d16
 fmov d9,xzr
 fmov d10,#1.0
 fmov d11,xzr
 fmov d12,#1.0
 fmov d13,xzr
 mov w9,#1
.Ltanh_series:
 fmov d0,d10
 fmov d1,d11
 fmov d2,d8
 fmov d3,d9
 bl .Ltanh_mul
 ucvtf d2,w9
 bl .Ltanh_div_integer
 fmov d10,d0
 fmov d11,d1
 fmov d0,d12
 fmov d1,d13
 fmov d2,d10
 fmov d3,d11
 bl .Ltanh_add
 fmov d12,d0
 fmov d13,d1
 add w9,w9,#1
 cmp w9,#25
 b.ne .Ltanh_series
 mov w9,#7
.Ltanh_squaring:
 fmov d0,d12
 fmov d1,d13
 fmov d2,d12
 fmov d3,d13
 bl .Ltanh_mul
 fmov d12,d0
 fmov d13,d1
 subs w9,w9,#1
 b.ne .Ltanh_squaring
 fmov d0,d12
 fmov d1,d13
 fmov d2,#-1.0
 fmov d3,xzr
 bl .Ltanh_add
 fmov d10,d0
 fmov d11,d1
 fmov d0,d12
 fmov d1,d13
 fmov d2,#1.0
 fmov d3,xzr
 bl .Ltanh_add
 fmov d2,d0
 fmov d3,d1
 fmov d0,d10
 fmov d1,d11
 bl .Ltanh_divide
 fadd d0,d0,d1
 ldr x9,[sp,#80]
 and x9,x9,#0x8000000000000000
 fmov x10,d0
 orr x10,x10,x9
 fmov d0,x10
 ldp d8,d9,[sp,#16]
 ldp d10,d11,[sp,#32]
 ldp d12,d13,[sp,#48]
 ldp d14,d15,[sp,#64]
 ldp x29,x30,[sp],#96
 ret
.Ltanh_saturated:
 fmov d0,#1.0
 fmov x10,d0
 and x9,x9,#0x8000000000000000
 orr x10,x10,x9
 fmov d0,x10
.Ltanh_return_input:
 ret
.Ltanh_reject:
 b abort
.size md2asm_tanh_accuracy_r3,.-md2asm_tanh_accuracy_r3

// Internal DD helpers use d0,d1 for A and d2,d3 for B. They return
// d0,d1. They preserve w9, every integer register except x12 and x30,
// and d8..d15. Stack slots hold original operands across helper calls.
.Ltanh_sum2:
 fadd d4,d0,d2
 fsub d16,d4,d0
 fsub d17,d4,d16
 fsub d18,d0,d17
 fsub d19,d2,d16
 fadd d1,d18,d19
 fmov d0,d4
 ret

.Ltanh_add:
 stp x29,x30,[sp,#-48]!
 stp d1,d3,[sp,#16]
 bl .Ltanh_sum2
 ldp d2,d3,[sp,#16]
 fadd d2,d2,d3
 fadd d2,d2,d1
 bl .Ltanh_sum2
 ldp x29,x30,[sp],#48
 ret

.Ltanh_product2:
 fmov d16,d0
 fmov d17,d2
 fmul d4,d0,d2
 adr x12,.Ltanh_constants
 ldr d5,[x12]
 fmul d6,d5,d16
 fsub d22,d6,d16
 fsub d18,d6,d22
 fsub d19,d16,d18
 fmul d6,d5,d17
 fsub d22,d6,d17
 fsub d20,d6,d22
 fsub d21,d17,d20
 fmul d23,d18,d20
 fsub d23,d23,d4
 fmul d24,d18,d21
 fadd d23,d23,d24
 fmul d24,d19,d20
 fadd d23,d23,d24
 fmul d24,d19,d21
 fadd d1,d23,d24
 fmov d0,d4
 ret

.Ltanh_mul:
 stp x29,x30,[sp,#-64]!
 stp d0,d1,[sp,#16]
 stp d2,d3,[sp,#32]
 bl .Ltanh_product2
 ldp d16,d17,[sp,#16]
 ldp d18,d19,[sp,#32]
 fmul d2,d16,d19
 fmul d3,d17,d18
 fadd d2,d2,d3
 fadd d2,d2,d1
 bl .Ltanh_sum2
 ldp x29,x30,[sp],#64
 ret

.Ltanh_div_integer:
 stp x29,x30,[sp,#-64]!
 stp d0,d1,[sp,#16]
 str d2,[sp,#32]
 fdiv d0,d0,d2
 str d0,[sp,#40]
 bl .Ltanh_product2
 fneg d2,d0
 fneg d3,d1
 ldp d0,d1,[sp,#16]
 bl .Ltanh_add
 ldr d2,[sp,#32]
 fdiv d2,d0,d2
 ldr d0,[sp,#40]
 bl .Ltanh_sum2
 ldp x29,x30,[sp],#64
 ret

.Ltanh_divide:
 stp x29,x30,[sp,#-80]!
 stp d0,d1,[sp,#16]
 stp d2,d3,[sp,#32]
 fdiv d0,d0,d2
 str d0,[sp,#48]
 fmov d1,xzr
 bl .Ltanh_mul
 fneg d2,d0
 fneg d3,d1
 ldp d0,d1,[sp,#16]
 bl .Ltanh_add
 ldr d2,[sp,#32]
 fdiv d2,d0,d2
 ldr d0,[sp,#48]
 bl .Ltanh_sum2
 ldp x29,x30,[sp],#80
 ret

.section .rodata
.p2align 3
.Ltanh_constants:
.xword 0x41a0000002000000 // 2^27+1 for the split product.
.xword 0x3f90000000000000 // 1/64 for the exponential argument.
.section .note.GNU-stack,"",%progbits

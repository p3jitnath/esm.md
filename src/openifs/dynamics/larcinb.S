/* Hydrostatic departure-field transport, numerical revision 1.
 * Physics input is formulations/openifs/dynamics/departure_field_transport.md.
 * The complete 39-pointer interface is retained within the frozen closure.
 * Every numerical child is direct assembly, with no Fortran fallback.
 * Copies retain raw words and each contribution uses one FP64 addition.
 */
.text
.p2align 4
.global md2asm_larcinb_7259755
.type md2asm_larcinb_7259755,%function
md2asm_larcinb_7259755:
 mrs x9,fpcr
 cbnz x9,.Lparent_bad
 mov x16,sp
 sub sp,sp,#2048
 add x17,sp,#1952
 stp x19,x20,[x17]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x25,x26,[x17,#48]
 stp x27,x28,[x17,#64]
 stp x29,x30,[x17,#80]
 mov x29,sp
 stp x0,x1,[sp,#256]
 stp x2,x3,[sp,#272]
 stp x4,x5,[sp,#288]
 stp x6,x7,[sp,#304]

 ldp x9,x10,[x16,#0]
 stp x9,x10,[sp,#320]

 ldp x9,x10,[x16,#16]
 stp x9,x10,[sp,#336]

 ldp x9,x10,[x16,#32]
 stp x9,x10,[sp,#352]

 ldp x9,x10,[x16,#48]
 stp x9,x10,[sp,#368]

 ldp x9,x10,[x16,#64]
 stp x9,x10,[sp,#384]

 ldp x9,x10,[x16,#80]
 stp x9,x10,[sp,#400]

 ldp x9,x10,[x16,#96]
 stp x9,x10,[sp,#416]

 ldp x9,x10,[x16,#112]
 stp x9,x10,[sp,#432]

 ldp x9,x10,[x16,#128]
 stp x9,x10,[sp,#448]

 ldp x9,x10,[x16,#144]
 stp x9,x10,[sp,#464]

 ldp x9,x10,[x16,#160]
 stp x9,x10,[sp,#480]

 ldp x9,x10,[x16,#176]
 stp x9,x10,[sp,#496]

 ldp x9,x10,[x16,#192]
 str x9,[sp,#512]
 str x10,[sp,#520]

 ldp x9,x10,[x16,#208]
 str x9,[sp,#528]
 str x10,[sp,#536]

 ldp x9,x10,[x16,#224]
 str x9,[sp,#544]
 str x10,[sp,#552]

 ldr x9,[x16,#240]
 str x9,[sp,#560]

 ldr x19,[sp,#296]

 ldr x21,[sp,#368]

 ldr x22,[sp,#376]

 ldr x23,[sp,#384]

 ldr x24,[sp,#288]

 add x24,x24,#184

 ldr x25,[sp,#432]

 ldr w9,[x19,#8]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#0]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#336]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#340]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#344]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#304]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#300]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#212]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#4760]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#4660]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#4664]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#4832]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#4840]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#4792]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#4800]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#4812]
 cbnz w9,.Lparent_bad

 ldr w9,[x19,#4836]
 cmp w9,#1
 b.ne .Lparent_bad

 ldr w9,[x19,#4796]
 cmp w9,#1
 b.ne .Lparent_bad

 ldr w9,[x19,#4804]
 cmp w9,#1
 b.ne .Lparent_bad

 ldr w9,[x19,#4808]
 cmp w9,#1
 b.ne .Lparent_bad

 ldr w9,[x19,#4644]
 cmp w9,#3
 b.ne .Lparent_bad

 ldr w9,[x19,#4648]
 cmp w9,#3
 b.ne .Lparent_bad

 ldr w9,[x19,#4640]
 cmp w9,#3
 b.ne .Lparent_bad

 ldr x9,[x19,#4976]
 mov x10,#0x3ff0000000000000
 cmp x9,x10
 b.ne .Lparent_bad

 ldr w9,[x19,#248]
 cmp w9,#1
 b.hi .Lparent_bad

 ldr w9,[x19,#252]
 cmp w9,#1
 b.hi .Lparent_bad

 ldr w9,[x19,#264]
 cmp w9,#1
 b.hi .Lparent_bad

 ldr w9,[x19,#80]
 cmp w9,#1
 b.hi .Lparent_bad

 ldr w9,[x19,#84]
 cmp w9,#1
 b.hi .Lparent_bad

 ldr w9,[x19,#1952]
 cmp w9,#1
 b.hi .Lparent_bad

 ldr w9,[x19,#152]
 cmp w9,#1
 b.hi .Lparent_bad

 ldr x9,[sp,#336]

 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lparent_bad

 ldr x9,[sp,#344]

 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lparent_bad

 ldr x9,[sp,#272]

 ldr w10,[x9,#108]
 cmp w10,#1
 b.hi .Lparent_bad

 ldr w10,[x9,#104]
 cmp w10,#1
 b.hi .Lparent_bad

 ldr x9,[sp,#256]

 ldrsw x10,[x9,#5144]
 cmp x10,#1
 b.lt .Lparent_bad
 cmp x10,#1024
 b.gt .Lparent_bad
 str w10,[sp,#624]
 ldrsw x11,[x9,#5224]
 cmp x11,#4
 b.lt .Lparent_bad
 cmp x11,#256
 b.gt .Lparent_bad
 str w11,[sp,#628]
 mul x20,x10,x11
 lsl x20,x20,#3
 ldrsw x12,[x9,#5248]
 ldrsw x13,[x9,#5244]
 sub x12,x12,x13
 add x12,x12,#1
 cmp x12,#1
 b.lt .Lparent_bad
 str x12,[sp,#640]

 ldr x9,[sp,#320]

 ldrsw x13,[x9]
 cmp x13,#1
 b.lt .Lparent_bad
 str x13,[sp,#648]

 ldrsw x14,[x19,#8880]
 cmp x14,#1
 b.lt .Lparent_bad
 mul x15,x13,x14
 mov x9,#0x7fffffff
 cmp x15,x9
 b.gt .Lparent_bad
 str x14,[sp,#656]

 ldr x9,[sp,#304]

 ldrsw x12,[x9]
 cmp x12,#1
 b.lt .Lparent_bad
 add x13,x10,#1
 cmp x12,x13
 b.gt .Lparent_bad
 sub x12,x12,#1
 str w12,[sp,#632]

 ldr x9,[sp,#312]

 ldrsw x12,[x9]
 cmp x12,#0
 b.lt .Lparent_bad
 cmp x12,x10
 b.gt .Lparent_bad
 str w12,[sp,#636]

 ldr x9,[sp,#264]

 ldrsw x12,[x9,#1420]
 cmp x12,#1
 b.lt .Lparent_bad
 str x12,[sp,#664]

 ldrsw x13,[x9,#1424]
 cmp x13,#1
 b.lt .Lparent_bad
 cmp x13,x12
 b.gt .Lparent_bad

 ldrsw x13,[x9,#1428]
 cmp x13,#1
 b.lt .Lparent_bad
 cmp x13,x12
 b.gt .Lparent_bad

 ldrsw x13,[x9,#1432]
 cmp x13,#1
 b.lt .Lparent_bad
 cmp x13,x12
 b.gt .Lparent_bad

 mov w9,#1
 str w9,[sp,#576]
 str wzr,[sp,#580]
 str w9,[sp,#584]
 str w9,[sp,#592]

 ldr w10,[x19,#1952]
 sub w9,w9,w10
 str w9,[sp,#588]

 ldrsw x9,[x19,#8956]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#8960]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#8968]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#9052]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#9056]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#9064]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#9076]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#9080]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldr x9,[sp,#344]

 ldr w9,[x9]
 cbz w9,.Lparent_guard_no_ff

 ldrsw x9,[x19,#9028]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#9032]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

.Lparent_guard_no_ff:

 ldr x9,[sp,#336]

 ldr w9,[x9]
 cbz w9,.Lparent_guard_no_split

 ldrsw x9,[x19,#9092]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#9096]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#9104]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

.Lparent_guard_no_split:

 ldr x9,[sp,#272]

 ldr w9,[x9,#108]
 cbz w9,.Lparent_guard_no_si

 ldr x9,[sp,#280]

 mov x17,#34676
 add x17,x9,x17
 ldrsw x12,[x17]

 mov x17,#34700
 add x17,x9,x17
 ldrsw x13,[x17]
 cmp x13,#1
 b.lt .Lparent_bad
 cmp x13,x12
 b.gt .Lparent_bad

 mov x17,#34704
 add x17,x9,x17
 ldrsw x13,[x17]
 cmp x13,#1
 b.lt .Lparent_bad
 cmp x13,x12
 b.gt .Lparent_bad

 mov x17,#34708
 add x17,x9,x17
 ldrsw x13,[x17]
 cmp x13,#1
 b.lt .Lparent_bad
 cmp x13,x12
 b.gt .Lparent_bad

 ldrsw x9,[x19,#9112]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#9116]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

 ldrsw x9,[x19,#9120]
 cmp x9,#1
 b.lt .Lparent_bad
 ldr x10,[sp,#640]
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

.Lparent_guard_no_si:

 ldr x9,[sp,#272]

 ldr w9,[x9,#104]
 cbz w9,.Lparent_guard_no_sl

 ldr x9,[sp,#288]

 ldrsw x12,[x9,#8]
 add x12,x12,#2

 ldr x9,[sp,#280]

 mov x17,#34768
 add x17,x9,x17
 ldrsw x13,[x17]
 cmp x13,#1
 b.lt .Lparent_bad
 cmp x13,x12
 b.gt .Lparent_bad

 mov x17,#34772
 add x17,x9,x17
 ldrsw x13,[x17]
 cmp x13,#1
 b.lt .Lparent_bad
 cmp x13,x12
 b.gt .Lparent_bad

 mov x17,#34776
 add x17,x9,x17
 ldrsw x13,[x17]
 cmp x13,#1
 b.lt .Lparent_bad
 cmp x13,x12
 b.gt .Lparent_bad

.Lparent_guard_no_sl:

 ldrsw x9,[x24,#0]
 cmp x9,#0
 b.lt .Lparent_bad
 mov x10,#2163
 cmp x9,x10
 b.gt .Lparent_bad
 str x9,[sp,#672]
 mov x27,#0

.Lparent_descriptor_guard_loop:
 ldr x9,[sp,#672]
 cmp x27,x9
 b.ge .Lparent_descriptor_guard_done
 mov x9,#368
 madd x28,x27,x9,x24
 add x28,x28,#3848

 ldr w9,[x28,#20]
 cmp w9,#1
 b.hi .Lparent_bad
 cbz w9,.Lparent_descriptor_guard_next
 ldr w9,[x28,#48]
 cmp w9,#1
 b.hi .Lparent_bad
 cbnz w9,.Lparent_descriptor_guard_physics
 ldr w9,[x28,#28]
 cbnz w9,.Lparent_bad

 add x16,x28,#156

 ldr x12,[x16]
 ldr w13,[x16,#8]

 movz x14,#18764

 movk x14,#8270,lsl #16

 movk x14,#8224,lsl #32

 movk x14,#8224,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_0

 movz w14,#8224
 movk w14,#8224,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_0:

 movz x14,#18764

 movk x14,#10318,lsl #16

 movk x14,#16717,lsl #32

 movk x14,#10564,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_1

 movz w14,#8224
 movk w14,#8224,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_1:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#21288,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_2

 movz w14,#17484
 movk w14,#8233,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_2:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#10312,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_3

 movz w14,#19539
 movk w14,#10564,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_3:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#18770,lsl #32

 movk x14,#21288,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_4

 movz w14,#17484
 movk w14,#8233,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_4:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#19752,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_5

 movz w14,#17473
 movk w14,#8233,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_5:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#10291,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_6

 movz w14,#16717
 movk w14,#10564,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_6:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#10316,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_7

 movz w14,#16717
 movk w14,#10564,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_7:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#10312,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_8

 movz w14,#16717
 movk w14,#10564,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_8:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#18770,lsl #32

 movk x14,#19752,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_9

 movz w14,#17473
 movk w14,#8233,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_9:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#17459,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_10

 movz w14,#8224
 movk w14,#8224,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_10:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#13132,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_11

 movz w14,#8260
 movk w14,#8224,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_11:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#8224,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_12

 movz w14,#8224
 movk w14,#8224,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_12:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#8264,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_13

 movz w14,#8224
 movk w14,#8224,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_13:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#18770,lsl #32

 movk x14,#8224,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_14

 movz w14,#8224
 movk w14,#8224,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_14:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#22354,lsl #32

 movk x14,#20037,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_15

 movz w14,#20815
 movk w14,#8269,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_15:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#22354,lsl #32

 movk x14,#20037,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_16

 movz w14,#20815
 movk w14,#18509,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_16:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#22354,lsl #32

 movk x14,#20037,lsl #48

 cmp x12,x14
 b.ne .Lparent_guard_name_17

 movz w14,#8271
 movk w14,#8224,lsl #16
 cmp w13,w14
 b.eq .Lparent_descriptor_guard_source
.Lparent_guard_name_17:

 b .Lparent_bad

.Lparent_descriptor_guard_source:

 ldrsw x9,[x28,#216]
 cmp x9,#1
 b.lt .Lparent_bad
 sub x9,x9,#1
 ldr x10,[sp,#640]
 mul x9,x9,x10
 ldrsw x11,[x19,#8972]
 cmp x11,#1
 b.lt .Lparent_bad
 add x9,x9,x11
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad

.Lparent_descriptor_guard_physics:

 ldr x9,[sp,#336]

 ldr w9,[x9]
 cbz w9,.Lparent_descriptor_guard_next

 ldr w9,[x28,#100]
 cmp w9,#1
 b.hi .Lparent_bad
 cbz w9,.Lparent_descriptor_guard_next
 ldrsw x9,[x28,#204]
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x24,#72]
 cmp x9,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 ldr x10,[sp,#640]
 mul x9,x9,x10
 ldrsw x11,[x19,#9108]
 cmp x11,#1
 b.lt .Lparent_bad
 add x9,x9,x11
 add x9,x9,x10
 sub x9,x9,#1
 ldr x10,[sp,#656]
 cmp x9,x10
 b.gt .Lparent_bad
.Lparent_descriptor_guard_next:
 add x27,x27,#1
 b .Lparent_descriptor_guard_loop
.Lparent_descriptor_guard_done:
 mov x0,x20
 bl malloc
 cbz x0,.Lparent_bad
 mov x26,x0

 mov x9,x19

 mov x0,x9

 ldr x9,[sp,#320]

 mov x1,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x2,x9

 ldr x9,[sp,#304]

 mov x3,x9

 ldr x9,[sp,#312]

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x7,x9

 add x9,sp,#576

 str x9,[sp,#0]

 add x9,sp,#580

 str x9,[sp,#8]

 add x9,x19,#248

 str x9,[sp,#16]

 add x9,x19,#80

 str x9,[sp,#24]

 mov x17,#4832
 add x9,x19,x17

 str x9,[sp,#32]

 mov x17,#4856
 add x9,x19,x17

 str x9,[sp,#40]

 add x9,sp,#584

 str x9,[sp,#48]

 mov x17,#4792
 add x9,x19,x17

 str x9,[sp,#56]

 mov x17,#4796
 add x9,x19,x17

 str x9,[sp,#64]

 ldr x9,[sp,#400]

 str x9,[sp,#72]

 ldr x9,[sp,#352]

 str x9,[sp,#80]

 ldr x9,[sp,#368]

 str x9,[sp,#88]

 ldr x9,[sp,#376]

 str x9,[sp,#96]

 ldrsw x9,[x19,#8956]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#104]

 ldr x9,[sp,#432]

 ldr x17,[sp,#264]

 ldrsw x17,[x17,#1424]
 sub x17,x17,#1
 madd x9,x17,x20,x9

 str x9,[sp,#112]

 bl md2asm_laitre_gmv_7259755
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]

 ldr x9,[sp,#272]

 ldr w9,[x9,#104]
 cbz w9,.Lparent_U_no_sl

 ldr x0,[sp,#408]

 ldr x17,[sp,#280]

 mov x16,#34768
 add x16,x17,x16
 ldrsw x17,[x16]
 sub x17,x17,#1
 madd x0,x17,x20,x0

 ldr x1,[sp,#432]

 ldr x17,[sp,#264]

 ldrsw x17,[x17,#1424]
 sub x17,x17,#1
 madd x1,x17,x20,x1

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp1_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp1_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp1_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr d0,[x0,x16]
 ldr d1,[x1,x16]
 fadd d0,d0,d1
 str d0,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp1_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp1_level
.Lp1_done:

.Lparent_U_no_sl:

 ldr x9,[sp,#344]

 ldr w9,[x9]
 cbz w9,.Lparent_U_copy_saved

 mov x9,x19

 mov x0,x9

 ldr x9,[sp,#320]

 mov x1,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x2,x9

 ldr x9,[sp,#304]

 mov x3,x9

 ldr x9,[sp,#312]

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x7,x9

 add x9,sp,#576

 str x9,[sp,#0]

 add x9,sp,#580

 str x9,[sp,#8]

 add x9,x19,#248

 str x9,[sp,#16]

 add x9,x19,#80

 str x9,[sp,#24]

 mov x17,#4832
 add x9,x19,x17

 str x9,[sp,#32]

 mov x17,#4856
 add x9,x19,x17

 str x9,[sp,#40]

 add x9,sp,#584

 str x9,[sp,#48]

 mov x17,#4792
 add x9,x19,x17

 str x9,[sp,#56]

 mov x17,#4796
 add x9,x19,x17

 str x9,[sp,#64]

 ldr x9,[sp,#400]

 str x9,[sp,#72]

 ldr x9,[sp,#352]

 str x9,[sp,#80]

 ldr x9,[sp,#368]

 str x9,[sp,#88]

 ldr x9,[sp,#376]

 str x9,[sp,#96]

 ldrsw x9,[x19,#9028]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#104]

 ldr x9,[sp,#496]

 str x9,[sp,#112]

 bl md2asm_laitre_gmv_7259755
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]

 b .Lparent_U_saved_done
.Lparent_U_copy_saved:

 ldr x0,[sp,#496]

 ldr x1,[sp,#432]

 ldr x17,[sp,#264]

 ldrsw x17,[x17,#1424]
 sub x17,x17,#1
 madd x1,x17,x20,x1

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp2_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp2_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp2_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr x9,[x1,x16]
 str x9,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp2_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp2_level
.Lp2_done:

.Lparent_U_saved_done:

 add x9,x19,#248

 ldr w9,[x9]
 cbnz w9,.Llinear3_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear3_planes
.Llinear3_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear3_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x19,#9052]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 mov x9,x26

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

 ldr x0,[sp,#432]

 ldr x17,[sp,#264]

 ldrsw x17,[x17,#1424]
 sub x17,x17,#1
 madd x0,x17,x20,x0

 mov x1,x26

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp4_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp4_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp4_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr d0,[x0,x16]
 ldr d1,[x1,x16]
 fadd d0,d0,d1
 str d0,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp4_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp4_level
.Lp4_done:

 ldr x9,[sp,#272]

 ldr w9,[x9,#108]
 cbz w9,.Lparent_U_no_si

 add x9,x19,#248

 ldr w9,[x9]
 cbnz w9,.Llinear5_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear5_planes
.Llinear5_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear5_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x19,#9112]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 mov x9,x26

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

 ldr x0,[sp,#424]

 ldr x17,[sp,#280]

 mov x16,#34700
 add x16,x17,x16
 ldrsw x17,[x16]
 sub x17,x17,#1
 madd x0,x17,x20,x0

 mov x1,x26

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp6_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp6_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp6_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr d0,[x0,x16]
 ldr d1,[x1,x16]
 fadd d0,d0,d1
 str d0,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp6_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp6_level
.Lp6_done:

.Lparent_U_no_si:

 ldr x9,[sp,#336]

 ldr w9,[x9]
 cbz w9,.Lparent_U_no_split

 add x9,x19,#248

 ldr w9,[x9]
 cbnz w9,.Llinear7_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear7_planes
.Llinear7_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear7_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x19,#9092]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 ldr x9,[sp,#512]

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

.Lparent_U_no_split:

 mov x9,x19

 mov x0,x9

 ldr x9,[sp,#320]

 mov x1,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x2,x9

 ldr x9,[sp,#304]

 mov x3,x9

 ldr x9,[sp,#312]

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x7,x9

 add x9,sp,#576

 str x9,[sp,#0]

 add x9,sp,#580

 str x9,[sp,#8]

 add x9,x19,#248

 str x9,[sp,#16]

 add x9,x19,#80

 str x9,[sp,#24]

 mov x17,#4832
 add x9,x19,x17

 str x9,[sp,#32]

 mov x17,#4856
 add x9,x19,x17

 str x9,[sp,#40]

 add x9,sp,#584

 str x9,[sp,#48]

 mov x17,#4792
 add x9,x19,x17

 str x9,[sp,#56]

 mov x17,#4796
 add x9,x19,x17

 str x9,[sp,#64]

 ldr x9,[sp,#400]

 str x9,[sp,#72]

 ldr x9,[sp,#352]

 str x9,[sp,#80]

 ldr x9,[sp,#368]

 str x9,[sp,#88]

 ldr x9,[sp,#376]

 str x9,[sp,#96]

 ldrsw x9,[x19,#8960]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#104]

 ldr x9,[sp,#432]

 ldr x17,[sp,#264]

 ldrsw x17,[x17,#1428]
 sub x17,x17,#1
 madd x9,x17,x20,x9

 str x9,[sp,#112]

 bl md2asm_laitre_gmv_7259755
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]

 ldr x9,[sp,#272]

 ldr w9,[x9,#104]
 cbz w9,.Lparent_V_no_sl

 ldr x0,[sp,#408]

 ldr x17,[sp,#280]

 mov x16,#34772
 add x16,x17,x16
 ldrsw x17,[x16]
 sub x17,x17,#1
 madd x0,x17,x20,x0

 ldr x1,[sp,#432]

 ldr x17,[sp,#264]

 ldrsw x17,[x17,#1428]
 sub x17,x17,#1
 madd x1,x17,x20,x1

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp8_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp8_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp8_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr d0,[x0,x16]
 ldr d1,[x1,x16]
 fadd d0,d0,d1
 str d0,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp8_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp8_level
.Lp8_done:

.Lparent_V_no_sl:

 ldr x9,[sp,#344]

 ldr w9,[x9]
 cbz w9,.Lparent_V_copy_saved

 mov x9,x19

 mov x0,x9

 ldr x9,[sp,#320]

 mov x1,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x2,x9

 ldr x9,[sp,#304]

 mov x3,x9

 ldr x9,[sp,#312]

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x7,x9

 add x9,sp,#576

 str x9,[sp,#0]

 add x9,sp,#580

 str x9,[sp,#8]

 add x9,x19,#248

 str x9,[sp,#16]

 add x9,x19,#80

 str x9,[sp,#24]

 mov x17,#4832
 add x9,x19,x17

 str x9,[sp,#32]

 mov x17,#4856
 add x9,x19,x17

 str x9,[sp,#40]

 add x9,sp,#584

 str x9,[sp,#48]

 mov x17,#4792
 add x9,x19,x17

 str x9,[sp,#56]

 mov x17,#4796
 add x9,x19,x17

 str x9,[sp,#64]

 ldr x9,[sp,#400]

 str x9,[sp,#72]

 ldr x9,[sp,#352]

 str x9,[sp,#80]

 ldr x9,[sp,#368]

 str x9,[sp,#88]

 ldr x9,[sp,#376]

 str x9,[sp,#96]

 ldrsw x9,[x19,#9032]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#104]

 ldr x9,[sp,#504]

 str x9,[sp,#112]

 bl md2asm_laitre_gmv_7259755
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]

 b .Lparent_V_saved_done
.Lparent_V_copy_saved:

 ldr x0,[sp,#504]

 ldr x1,[sp,#432]

 ldr x17,[sp,#264]

 ldrsw x17,[x17,#1428]
 sub x17,x17,#1
 madd x1,x17,x20,x1

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp9_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp9_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp9_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr x9,[x1,x16]
 str x9,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp9_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp9_level
.Lp9_done:

.Lparent_V_saved_done:

 add x9,x19,#248

 ldr w9,[x9]
 cbnz w9,.Llinear10_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear10_planes
.Llinear10_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear10_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x19,#9056]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 mov x9,x26

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

 ldr x0,[sp,#432]

 ldr x17,[sp,#264]

 ldrsw x17,[x17,#1428]
 sub x17,x17,#1
 madd x0,x17,x20,x0

 mov x1,x26

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp11_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp11_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp11_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr d0,[x0,x16]
 ldr d1,[x1,x16]
 fadd d0,d0,d1
 str d0,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp11_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp11_level
.Lp11_done:

 ldr x9,[sp,#272]

 ldr w9,[x9,#108]
 cbz w9,.Lparent_V_no_si

 add x9,x19,#248

 ldr w9,[x9]
 cbnz w9,.Llinear12_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear12_planes
.Llinear12_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear12_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x19,#9116]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 mov x9,x26

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

 ldr x0,[sp,#424]

 ldr x17,[sp,#280]

 mov x16,#34704
 add x16,x17,x16
 ldrsw x17,[x16]
 sub x17,x17,#1
 madd x0,x17,x20,x0

 mov x1,x26

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp13_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp13_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp13_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr d0,[x0,x16]
 ldr d1,[x1,x16]
 fadd d0,d0,d1
 str d0,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp13_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp13_level
.Lp13_done:

.Lparent_V_no_si:

 ldr x9,[sp,#336]

 ldr w9,[x9]
 cbz w9,.Lparent_V_no_split

 add x9,x19,#248

 ldr w9,[x9]
 cbnz w9,.Llinear14_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear14_planes
.Llinear14_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear14_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x19,#9096]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 ldr x9,[sp,#520]

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

.Lparent_V_no_split:

 mov x9,x19

 mov x0,x9

 ldr x9,[sp,#320]

 mov x1,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x2,x9

 ldr x9,[sp,#304]

 mov x3,x9

 ldr x9,[sp,#312]

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x7,x9

 add x9,sp,#576

 str x9,[sp,#0]

 add x9,sp,#580

 str x9,[sp,#8]

 add x9,x19,#252

 str x9,[sp,#16]

 add x9,x19,#84

 str x9,[sp,#24]

 mov x17,#4836
 add x9,x19,x17

 str x9,[sp,#32]

 mov x17,#4864
 add x9,x19,x17

 str x9,[sp,#40]

 add x9,sp,#588

 str x9,[sp,#48]

 mov x17,#4800
 add x9,x19,x17

 str x9,[sp,#56]

 mov x17,#4804
 add x9,x19,x17

 str x9,[sp,#64]

 ldr x9,[sp,#400]

 str x9,[sp,#72]

 ldr x9,[sp,#352]

 str x9,[sp,#80]

 ldr x9,[sp,#368]

 str x9,[sp,#88]

 ldr x9,[sp,#376]

 str x9,[sp,#96]

 ldrsw x9,[x19,#8968]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#104]

 ldr x9,[sp,#432]

 ldr x17,[sp,#264]

 ldrsw x17,[x17,#1432]
 sub x17,x17,#1
 madd x9,x17,x20,x9

 str x9,[sp,#112]

 bl md2asm_laitre_gmv_7259755
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#8]
 add x10,x10,#1
 str x10,[x9,#8]

 ldr x9,[sp,#272]

 ldr w9,[x9,#104]
 cbz w9,.Lparent_T_no_sl

 ldr x0,[sp,#408]

 ldr x17,[sp,#280]

 mov x16,#34776
 add x16,x17,x16
 ldrsw x17,[x16]
 sub x17,x17,#1
 madd x0,x17,x20,x0

 ldr x1,[sp,#432]

 ldr x17,[sp,#264]

 ldrsw x17,[x17,#1432]
 sub x17,x17,#1
 madd x1,x17,x20,x1

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp15_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp15_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp15_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr d0,[x0,x16]
 ldr d1,[x1,x16]
 fadd d0,d0,d1
 str d0,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp15_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp15_level
.Lp15_done:

.Lparent_T_no_sl:

 add x9,x19,#252

 ldr w9,[x9]
 cbnz w9,.Llinear16_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear16_planes
.Llinear16_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear16_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x19,#9064]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 mov x9,x26

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

 ldr x0,[sp,#432]

 ldr x17,[sp,#264]

 ldrsw x17,[x17,#1432]
 sub x17,x17,#1
 madd x0,x17,x20,x0

 mov x1,x26

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp17_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp17_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp17_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr d0,[x0,x16]
 ldr d1,[x1,x16]
 fadd d0,d0,d1
 str d0,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp17_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp17_level
.Lp17_done:

 ldr x9,[sp,#272]

 ldr w9,[x9,#108]
 cbz w9,.Lparent_T_no_si

 add x9,x19,#252

 ldr w9,[x9]
 cbnz w9,.Llinear18_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear18_planes
.Llinear18_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear18_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x19,#9120]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 mov x9,x26

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

 ldr x0,[sp,#424]

 ldr x17,[sp,#280]

 mov x16,#34708
 add x16,x17,x16
 ldrsw x17,[x16]
 sub x17,x17,#1
 madd x0,x17,x20,x0

 mov x1,x26

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp19_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp19_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp19_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr d0,[x0,x16]
 ldr d1,[x1,x16]
 fadd d0,d0,d1
 str d0,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp19_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp19_level
.Lp19_done:

.Lparent_T_no_si:

 ldr x9,[sp,#336]

 ldr w9,[x9]
 cbz w9,.Lparent_T_no_split

 add x9,x19,#252

 ldr w9,[x9]
 cbnz w9,.Llinear20_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear20_planes
.Llinear20_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear20_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x19,#9104]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 ldr x9,[sp,#528]

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

.Lparent_T_no_split:

 mov x27,#1
.Lparent_gfl_loop:
 ldr x9,[sp,#672]
 cmp x27,x9
 b.gt .Lparent_gfl_done
 sub x9,x27,#1
 mov x10,#368
 madd x28,x9,x10,x24
 add x28,x28,#3848
 str w27,[sp,#600]

 ldr w9,[x28,#20]
 cbz w9,.Lparent_gfl_next
 ldr w9,[x28,#48]
 cbnz w9,.Lparent_gfl_physics

 add x16,x28,#156

 ldr x12,[x16]
 ldr w13,[x16,#8]

 movz x14,#18764

 movk x14,#8270,lsl #16

 movk x14,#8224,lsl #32

 movk x14,#8224,lsl #48

 cmp x12,x14
 b.ne .Lparent_gfl_linear_name_0

 movz w14,#8224
 movk w14,#8224,lsl #16
 cmp w13,w14
 b.eq .Lparent_gfl_linear
.Lparent_gfl_linear_name_0:

 movz x14,#18764

 movk x14,#10318,lsl #16

 movk x14,#16717,lsl #32

 movk x14,#10564,lsl #48

 cmp x12,x14
 b.ne .Lparent_gfl_linear_name_1

 movz w14,#8224
 movk w14,#8224,lsl #16
 cmp w13,w14
 b.eq .Lparent_gfl_linear_mad
.Lparent_gfl_linear_name_1:

 b .Lparent_gfl_high

.Lparent_gfl_linear:

 add x9,sp,#580

 ldr w9,[x9]
 cbnz w9,.Llinear21_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear21_planes
.Llinear21_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear21_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x28,#216]
 sub x9,x9,#1
 ldr x17,[sp,#640]
 mul x9,x9,x17
 ldrsw x17,[x19,#8972]
 add x9,x9,x17
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 ldr x9,[sp,#464]

 sub x17,x27,#1
 madd x9,x17,x20,x9

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

 b .Lparent_gfl_high_done
.Lparent_gfl_linear_mad:

 add x9,sp,#584

 ldr w9,[x9]
 cbnz w9,.Llinear22_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear22_planes
.Llinear22_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear22_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x28,#216]
 sub x9,x9,#1
 ldr x17,[sp,#640]
 mul x9,x9,x17
 ldrsw x17,[x19,#8972]
 add x9,x9,x17
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 ldr x9,[sp,#464]

 sub x17,x27,#1
 madd x9,x17,x20,x9

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

 b .Lparent_gfl_high_done
.Lparent_gfl_high:

 ldr x9,[x28]
 ldr x10,[x28,#8]
 movz x11,#19284
 movk x11,#8261,lsl #16
 movk x11,#8224,lsl #32
 movk x11,#8224,lsl #48
 cmp x9,x11
 b.ne .Lparent_gfl_heat
 mov x11,#0x2020202020202020
 cmp x10,x11
 b.ne .Lparent_gfl_heat
 mov w9,#1
 b .Lparent_gfl_momentum_done
.Lparent_gfl_heat:
 ldr w9,[sp,#588]
.Lparent_gfl_momentum_done:
 str w9,[sp,#596]

 ldr x9,[sp,#256]

 mov x0,x9

 mov x9,x24

 mov x1,x9

 mov x9,x19

 mov x2,x9

 add x9,sp,#600

 mov x3,x9

 ldr x9,[sp,#320]

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#304]

 mov x6,x9

 ldr x9,[sp,#312]

 mov x7,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 str x9,[sp,#0]

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 str x9,[sp,#8]

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 str x9,[sp,#16]

 ldr x9,[sp,#328]

 str x9,[sp,#24]

 add x9,sp,#576

 str x9,[sp,#32]

 add x9,x28,#156

 str x9,[sp,#40]

 add x9,x28,#328

 str x9,[sp,#48]

 add x9,sp,#596

 str x9,[sp,#56]

 ldr x9,[sp,#400]

 str x9,[sp,#64]

 ldr x9,[sp,#352]

 str x9,[sp,#72]

 ldr x9,[sp,#368]

 str x9,[sp,#80]

 ldr x9,[sp,#376]

 str x9,[sp,#88]

 ldrsw x9,[x28,#216]
 sub x9,x9,#1
 ldr x17,[sp,#640]
 mul x9,x9,x17
 ldrsw x17,[x19,#8972]
 add x9,x9,x17
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#96]

 ldr x9,[sp,#464]

 sub x17,x27,#1
 madd x9,x17,x20,x9

 str x9,[sp,#104]

 mov x9,xzr

 str x9,[sp,#112]

 mov x9,#12

 str x9,[sp,#120]

 bl md2asm_laitre_gfl_7259755
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#16]
 add x10,x10,#1
 str x10,[x9,#16]

.Lparent_gfl_high_done:

 ldr x9,[sp,#272]

 ldr w9,[x9,#104]
 cbz w9,.Lparent_gfl_physics

 ldr x9,[sp,#416]

 sub x10,x27,#1
 madd x9,x10,x20,x9
 str x9,[sp,#760]

 ldr x0,[sp,#760]

 ldr x1,[sp,#464]

 sub x17,x27,#1
 madd x1,x17,x20,x1

 ldrsw x10,[sp,#632]
 ldrsw x11,[sp,#636]
 cmp x10,x11
 b.ge .Lp23_done
 mov x12,#0
 ldrsw x13,[sp,#624]
 ldrsw x14,[sp,#628]
.Lp23_level:
 ldrsw x10,[sp,#632]
 mul x15,x12,x13
.Lp23_row:
 add x16,x15,x10
 lsl x16,x16,#3

 ldr d0,[x0,x16]
 ldr d1,[x1,x16]
 fadd d0,d0,d1
 str d0,[x0,x16]

 add x10,x10,#1
 cmp x10,x11
 b.lt .Lp23_row
 add x12,x12,#1
 cmp x12,x14
 b.lt .Lp23_level
.Lp23_done:

.Lparent_gfl_physics:

 ldr x9,[sp,#336]

 ldr w9,[x9]
 cbz w9,.Lparent_gfl_next

 ldr w9,[x28,#100]
 cbz w9,.Lparent_gfl_next

 add x16,x28,#156

 ldr x12,[x16]
 ldr w13,[x16,#8]

 movz x14,#18764

 movk x14,#10318,lsl #16

 movk x14,#16717,lsl #32

 movk x14,#10564,lsl #48

 cmp x12,x14
 b.ne .Lparent_split_mad_0

 movz w14,#8224
 movk w14,#8224,lsl #16
 cmp w13,w14
 b.eq .Lparent_gfl_split_mad
.Lparent_split_mad_0:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#19752,lsl #48

 cmp x12,x14
 b.ne .Lparent_split_mad_1

 movz w14,#17473
 movk w14,#8233,lsl #16
 cmp w13,w14
 b.eq .Lparent_gfl_split_mad
.Lparent_split_mad_1:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#19793,lsl #32

 movk x14,#10312,lsl #48

 cmp x12,x14
 b.ne .Lparent_split_mad_2

 movz w14,#16717
 movk w14,#10564,lsl #16
 cmp w13,w14
 b.eq .Lparent_gfl_split_mad
.Lparent_split_mad_2:

 movz x14,#16716

 movk x14,#21577,lsl #16

 movk x14,#18770,lsl #32

 movk x14,#19752,lsl #48

 cmp x12,x14
 b.ne .Lparent_split_mad_3

 movz w14,#17473
 movk w14,#8233,lsl #16
 cmp w13,w14
 b.eq .Lparent_gfl_split_mad
.Lparent_split_mad_3:

 b .Lparent_gfl_split_normal

.Lparent_gfl_split_normal:

 add x9,sp,#580

 ldr w9,[x9]
 cbnz w9,.Llinear24_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear24_planes
.Llinear24_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear24_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x28,#204]
 sub x9,x9,#1
 ldr x17,[sp,#640]
 mul x9,x9,x17
 ldrsw x17,[x19,#9108]
 add x9,x9,x17
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 ldr x9,[sp,#536]

 ldrsw x17,[x28,#204]
 sub x17,x17,#1
 madd x9,x17,x20,x9

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

 b .Lparent_gfl_next
.Lparent_gfl_split_mad:

 add x9,sp,#584

 ldr w9,[x9]
 cbnz w9,.Llinear25_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear25_planes
.Llinear25_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear25_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x28,#204]
 sub x9,x9,#1
 ldr x17,[sp,#640]
 mul x9,x9,x17
 ldrsw x17,[x19,#9108]
 add x9,x9,x17
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 ldr x9,[sp,#536]

 ldrsw x17,[x28,#204]
 sub x17,x17,#1
 madd x9,x17,x20,x9

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

.Lparent_gfl_next:
 add x27,x27,#1
 b .Lparent_gfl_loop
.Lparent_gfl_done:

 add x9,x19,#264

 ldr w9,[x9]
 cbnz w9,.Llinear26_mad

 mov w9,#6452
 str w9,[sp,#700]
 mov w9,#6448
 str w9,[sp,#704]
 mov w9,#6456
 str w9,[sp,#708]
 b .Llinear26_planes
.Llinear26_mad:

 mov w9,#6464
 str w9,[sp,#700]
 mov w9,#6460
 str w9,[sp,#704]
 mov w9,#6468
 str w9,[sp,#708]
.Llinear26_planes:

 ldr w9,[sp,#700]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#720]

 ldr w9,[sp,#704]
 ldrsw x9,[x19,x9]
 add x9,x9,#1
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#1
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#728]

 ldr w9,[sp,#708]
 ldrsw x9,[x19,x9]
 add x9,x9,#0
 cmp x9,#1
 b.lt .Lparent_bad
 ldrsw x10,[x19,#6472]
 add x11,x9,#0
 cmp x11,x10
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#736]

 ldr x9,[sp,#352]

 add x9,x9,x20,lsr #1
 str x9,[sp,#744]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 ldr x9,[sp,#720]

 mov x7,x9

 ldr x9,[sp,#728]

 str x9,[sp,#0]

 ldr x9,[sp,#744]

 str x9,[sp,#8]

 ldr x9,[sp,#736]

 str x9,[sp,#16]

 ldrsw x9,[x19,#9076]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#24]

 ldr x9,[sp,#472]

 str x9,[sp,#32]

 bl laitli_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#24]
 add x10,x10,#1
 str x10,[x9,#24]

 ldr w9,[x19,#264]
 cbnz w9,.Lparent_horizontal_mad

 mov w9,#6520
 str w9,[sp,#800]

 mov w9,#6448
 str w9,[sp,#804]

 mov w9,#6504
 str w9,[sp,#808]

 b .Lparent_horizontal_planes
.Lparent_horizontal_mad:

 mov w9,#6608
 str w9,[sp,#800]

 mov w9,#6460
 str w9,[sp,#804]

 mov w9,#6592
 str w9,[sp,#808]

.Lparent_horizontal_planes:

 ldr w9,[sp,#800]
 ldrsw x9,[x19,x9]
 cmp x9,#1
 b.lt .Lparent_bad
 add x10,x9,#2
 ldrsw x11,[x19,#6644]
 cmp x10,x11
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x22
 str x9,[sp,#816]

 ldr w9,[sp,#804]
 ldrsw x9,[x19,x9]
 cmp x9,#1
 b.lt .Lparent_bad
 add x10,x9,#3
 ldrsw x11,[x19,#6472]
 cmp x10,x11
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x21
 str x9,[sp,#824]

 ldr w9,[sp,#808]
 ldrsw x9,[x19,x9]
 cmp x9,#1
 b.lt .Lparent_bad
 add x10,x9,#5
 ldrsw x11,[x19,#6644]
 cmp x10,x11
 b.gt .Lparent_bad
 sub x9,x9,#1
 madd x9,x9,x20,x22
 str x9,[sp,#832]

 ldr x9,[sp,#320]

 mov x0,x9

 ldr x9,[sp,#256]

 mov x17,#5144
 add x9,x9,x17

 mov x1,x9

 ldr x9,[sp,#304]

 mov x2,x9

 ldr x9,[sp,#312]

 mov x3,x9

 ldr x9,[sp,#256]

 mov x17,#5224
 add x9,x9,x17

 mov x4,x9

 ldr x9,[sp,#256]

 mov x17,#5244
 add x9,x9,x17

 mov x5,x9

 ldr x9,[sp,#256]

 mov x17,#5248
 add x9,x9,x17

 mov x6,x9

 add x9,sp,#592

 mov x7,x9

 ldr x9,[sp,#816]

 str x9,[sp,#0]

 ldr x9,[sp,#824]

 str x9,[sp,#8]

 ldr x9,[sp,#832]

 str x9,[sp,#16]

 ldr x9,[sp,#360]

 str x9,[sp,#24]

 ldrsw x9,[x19,#9080]
 sub x9,x9,#1
 ldr x17,[sp,#648]
 mul x9,x9,x17
 add x9,x23,x9,lsl #3

 str x9,[sp,#32]

 ldr x9,[sp,#456]

 str x9,[sp,#40]

 bl laiddi_assembly_
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9,#32]
 add x10,x10,#1
 str x10,[x9,#32]

 mov x0,x26
 bl free
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 add x17,sp,#1952
 ldp x19,x20,[x17]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x25,x26,[x17,#48]
 ldp x27,x28,[x17,#64]
 ldp x29,x30,[x17,#80]
 add sp,sp,#2048
 ret
.size md2asm_larcinb_7259755,.-md2asm_larcinb_7259755
.Lparent_bad:
 brk #0x32c
 b .Lparent_bad
.global larcinb_
.type larcinb_,%function
.set larcinb_,md2asm_larcinb_7259755

.global md2asm_larcinb_calls_get
.type md2asm_larcinb_calls_get,%function
md2asm_larcinb_calls_get:
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x0,[x9,#0]
 ret
.size md2asm_larcinb_calls_get,.-md2asm_larcinb_calls_get

.global md2asm_larcinb_gmv_calls_get
.type md2asm_larcinb_gmv_calls_get,%function
md2asm_larcinb_gmv_calls_get:
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x0,[x9,#8]
 ret
.size md2asm_larcinb_gmv_calls_get,.-md2asm_larcinb_gmv_calls_get

.global md2asm_larcinb_gfl_calls_get
.type md2asm_larcinb_gfl_calls_get,%function
md2asm_larcinb_gfl_calls_get:
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x0,[x9,#16]
 ret
.size md2asm_larcinb_gfl_calls_get,.-md2asm_larcinb_gfl_calls_get

.global md2asm_larcinb_linear_calls_get
.type md2asm_larcinb_linear_calls_get,%function
md2asm_larcinb_linear_calls_get:
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x0,[x9,#24]
 ret
.size md2asm_larcinb_linear_calls_get,.-md2asm_larcinb_linear_calls_get

.global md2asm_larcinb_horizontal_calls_get
.type md2asm_larcinb_horizontal_calls_get,%function
md2asm_larcinb_horizontal_calls_get:
 adrp x9,.Lparent_counts
 add x9,x9,:lo12:.Lparent_counts
 ldr x0,[x9,#32]
 ret
.size md2asm_larcinb_horizontal_calls_get,.-md2asm_larcinb_horizontal_calls_get

.bss
.p2align 3
.Lparent_counts: .zero 40
.section .note.GNU-stack,"",%progbits

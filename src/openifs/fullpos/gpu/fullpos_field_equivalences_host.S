#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_fullpos_field_equivalences
.type md2asm_initialize_selected_fullpos_field_equivalences,%function
md2asm_initialize_selected_fullpos_field_equivalences:
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 bl .Ladmit
 cbnz w0,.Lreturn
 adrp x21,.Ldynamic_order
 add x21,x21,:lo12:.Ldynamic_order
 mov x22,#0
 mov x23,x19
 movz x24,#564
.Ldynamic_loop:
 ldr w9,[x21]
 add x0,x19,x9
 mov x1,x23
 add w2,w22,#1
 add x3,x21,#4
 bl .Lcontrol_dynamic
 add x23,x23,#112
 add x21,x21,#20
 add x22,x22,#1
 cmp x22,x24
 b.lo .Ldynamic_loop
 adrp x3,.Lblank16
 add x3,x3,:lo12:.Lblank16
.Ldynamic_fill:
 cmp x22,#686
 b.hs .Lphysical_begin
 mov x0,x23
 mov x1,x23
 add w2,w22,#1
 bl .Lcontrol_dynamic
 add x23,x23,#112
 add x22,x22,#1
 b .Ldynamic_fill
.Lphysical_begin:
 adrp x21,.Lphysical_order
 add x21,x21,:lo12:.Lphysical_order
 mov x22,#0
 movz x23,#9264
 movk x23,#2,lsl#16
 add x23,x19,x23
 movz x24,#1791
.Lphysical_loop:
 ldr w9,[x21],#4
 add x0,x19,x9
 mov x1,x23
 add w2,w22,#1
 bl .Lcontrol_physical
 add x23,x23,#64
 add x22,x22,#1
 cmp x22,x24
 b.lo .Lphysical_loop
.Lphysical_fill:
 cmp x22,#2786
 b.hs .Lwrite_group_bounds
 mov x0,x23
 mov x1,x23
 add w2,w22,#1
 bl .Lcontrol_physical
 add x23,x23,#64
 add x22,x22,#1
 b .Lphysical_fill
.Lwrite_group_bounds:
 movz x9,#38512
 movk x9,#7,lsl#16
 add x9,x19,x9
 movz w10,#1
 str w10,[x9]
 movz x9,#38524
 movk x9,#7,lsl#16
 add x9,x19,x9
 movz w10,#1660
 str w10,[x9]
 movz x9,#38516
 movk x9,#7,lsl#16
 add x9,x19,x9
 movz w10,#1661
 str w10,[x9]
 movz x9,#38528
 movk x9,#7,lsl#16
 add x9,x19,x9
 movz w10,#1727
 str w10,[x9]
 movz x9,#38520
 movk x9,#7,lsl#16
 add x9,x19,x9
 movz w10,#1728
 str w10,[x9]
 movz x9,#38532
 movk x9,#7,lsl#16
 add x9,x19,x9
 movz w10,#1791
 str w10,[x9]
 mov w0,#0
 b .Lreturn
.p2align 4
.global md2asm_check_selected_fullpos_field_descriptors
.type md2asm_check_selected_fullpos_field_descriptors,%function
md2asm_check_selected_fullpos_field_descriptors:
 sub sp,sp,#96
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 str x18,[sp,#80]
 mov x29,sp
 mov x19,x0
 mov x20,x2
 bl .Ladmit
 cbnz w0,.Lreturn
 mov x0,x19
 mov x1,#686
 mov x2,#112
 bl .Lcheck_unique
 cbnz w0,.Lreturn
 movz x0,#9264
 movk x0,#2,lsl#16
 add x0,x19,x0
 mov x1,#2786
 mov x2,#64
 bl .Lcheck_unique
 b .Lreturn
.Ladmit:
 cbz x19,.Lbad
 cbz x20,.Lbad
 orr x9,x19,x20
 tst x9,#7
 b.ne .Lbad
 movz x9,#38616
 movk x9,#7,lsl#16
 cmp x1,x9
 b.lo .Lbad
 adds x10,x19,x9
 b.cs .Lbad
 adds x11,x20,#16
 b.cs .Lbad
 cmp x19,x11
 b.hs .Ladmit_disjoint
 cmp x20,x10
 b.lo .Lbad
.Ladmit_disjoint:
 ldp x9,x10,[x20]
 orr x9,x9,x10
 cbnz x9,.Lbad
 movz x9,#38608
 movk x9,#7,lsl#16
 add x9,x19,x9
 ldr w9,[x9]
 cbnz w9,.Lbad
 movz x9,#38544
 movk x9,#7,lsl#16
 add x9,x19,x9
 ldr x9,[x9]
 cbnz x9,.Lbad
 mov w0,#0
 ret
.Lbad:
 mov w0,#2
 ret
.Lcontrol_dynamic:
 ldr w4,[x0,#32]
 cbz w4,.Lspectral
 str wzr,[x0,#16]
 str xzr,[x0,#24]
 b .Ldynamic_label
.Lspectral:
 ldr w4,[x0,#16]
 mov w5,#3
 cmp w4,w5
 csel w4,w4,w5,le
 mov w5,#1
 cmp w4,w5
 csel w4,w4,w5,ge
 str w4,[x0,#16]
 ldr d0,[x0,#24]
 fmov d1,xzr
 md2asm_gpu_full_scalar md2asm_gpu_output_numeric_cell_host,17,d0,d1,d0 // fmaxnm d0,d1,d0
 str d0,[x0,#24]
.Ldynamic_label:
 ldp x4,x5,[x3]
 stur x4,[x0,#44]
 stur x5,[x0,#52]
 str w2,[x0,#20]
 ldp x4,x5,[x0,#0]
 stp x4,x5,[x1,#0]
 ldp x4,x5,[x0,#16]
 stp x4,x5,[x1,#16]
 ldp x4,x5,[x0,#32]
 stp x4,x5,[x1,#32]
 ldp x4,x5,[x0,#48]
 stp x4,x5,[x1,#48]
 ldp x4,x5,[x0,#64]
 stp x4,x5,[x1,#64]
 ldp x4,x5,[x0,#80]
 stp x4,x5,[x1,#80]
 ldp x4,x5,[x0,#96]
 stp x4,x5,[x1,#96]
 ret
.Lcontrol_physical:
 str w2,[x0,#20]
 ldp x4,x5,[x0,#0]
 stp x4,x5,[x1,#0]
 ldp x4,x5,[x0,#16]
 stp x4,x5,[x1,#16]
 ldp x4,x5,[x0,#32]
 stp x4,x5,[x1,#32]
 ldp x4,x5,[x0,#48]
 stp x4,x5,[x1,#48]
 ret
.Lcheck_unique:
 mov x3,#0
.Lunique_outer:
 cmp x3,x1
 b.hs .Lunique_success
 ldr w4,[x0]
 cmp w4,#0
 b.le .Lunique_next
 ldr w5,[x0,#36]
 add x6,x0,x2
 add x7,x3,#1
.Lunique_inner:
 cmp x7,x1
 b.hs .Lunique_next
 ldr w8,[x6]
 cmp w4,w8
 b.ne .Lunique_inner_next
 ldr w9,[x6,#36]
 cmp w5,w9
 b.eq .Lduplicate
.Lunique_inner_next:
 add x6,x6,x2
 add x7,x7,#1
 b .Lunique_inner
.Lunique_next:
 add x0,x0,x2
 add x3,x3,#1
 b .Lunique_outer
.Lduplicate:
 mov w0,#3
 ret
.Lunique_success:
 mov w0,#0
 ret
.Lreturn:
 ldr x18,[sp,#80]
 ldp x25,x26,[sp,#64]
 ldp x23,x24,[sp,#48]
 ldp x21,x22,[sp,#32]
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp]
 add sp,sp,#96
 ret
.section .rodata
.p2align 3
.Lblank16:
 .ascii "                "
.Ldynamic_order:
 .word 77056
 .ascii "                "
 .word 77168
 .ascii "                "
 .word 77952
 .ascii "                "
 .word 77840
 .ascii "                "
 .word 76944
 .ascii "K               "
 .word 77280
 .ascii "                "
 .word 79856
 .ascii "                "
 .word 79968
 .ascii "                "
 .word 80080
 .ascii "                "
 .word 78064
 .ascii "                "
 .word 78176
 .ascii "                "
 .word 78288
 .ascii "                "
 .word 78400
 .ascii "                "
 .word 79744
 .ascii "                "
 .word 78512
 .ascii "                "
 .word 78624
 .ascii "                "
 .word 78736
 .ascii "                "
 .word 78848
 .ascii "                "
 .word 78960
 .ascii "                "
 .word 82208
 .ascii "                "
 .word 79072
 .ascii "                "
 .word 79184
 .ascii "                "
 .word 79296
 .ascii "                "
 .word 76832
 .ascii "HF              "
 .word 80192
 .ascii "                "
 .word 77392
 .ascii "                "
 .word 79408
 .ascii "T               "
 .word 79520
 .ascii "                "
 .word 79632
 .ascii "                "
 .word 80304
 .ascii "                "
 .word 123648
 .ascii "                "
 .word 81424
 .ascii "                "
 .word 81536
 .ascii "                "
 .word 81648
 .ascii "                "
 .word 80864
 .ascii "B               "
 .word 81088
 .ascii "                "
 .word 81200
 .ascii "BVTHKF          "
 .word 80976
 .ascii "BVSHKF          "
 .word 117936
 .ascii "                "
 .word 118048
 .ascii "BVTHSF          "
 .word 118160
 .ascii "                "
 .word 119280
 .ascii "                "
 .word 82320
 .ascii "                "
 .word 82432
 .ascii "                "
 .word 82544
 .ascii "                "
 .word 82656
 .ascii "                "
 .word 82768
 .ascii "                "
 .word 82880
 .ascii "                "
 .word 83440
 .ascii "                "
 .word 83552
 .ascii "                "
 .word 82992
 .ascii "                "
 .word 83104
 .ascii "                "
 .word 83216
 .ascii "                "
 .word 83328
 .ascii "                "
 .word 83664
 .ascii "                "
 .word 83776
 .ascii "                "
 .word 83888
 .ascii "                "
 .word 81872
 .ascii "                "
 .word 81984
 .ascii "                "
 .word 82096
 .ascii "                "
 .word 116816
 .ascii "                "
 .word 116928
 .ascii "                "
 .word 117040
 .ascii "                "
 .word 117152
 .ascii "                "
 .word 117264
 .ascii "                "
 .word 117376
 .ascii "                "
 .word 117488
 .ascii "                "
 .word 117600
 .ascii "                "
 .word 117712
 .ascii "                "
 .word 117824
 .ascii "                "
 .word 94864
 .ascii "                "
 .word 94976
 .ascii "                "
 .word 95088
 .ascii "                "
 .word 92624
 .ascii "                "
 .word 92736
 .ascii "                "
 .word 92848
 .ascii "                "
 .word 92960
 .ascii "                "
 .word 93072
 .ascii "                "
 .word 93184
 .ascii "                "
 .word 93296
 .ascii "                "
 .word 93408
 .ascii "                "
 .word 93520
 .ascii "                "
 .word 93632
 .ascii "                "
 .word 93744
 .ascii "                "
 .word 93856
 .ascii "                "
 .word 93968
 .ascii "                "
 .word 94080
 .ascii "                "
 .word 94192
 .ascii "                "
 .word 94304
 .ascii "                "
 .word 94416
 .ascii "                "
 .word 94528
 .ascii "                "
 .word 94640
 .ascii "                "
 .word 94752
 .ascii "                "
 .word 95200
 .ascii "                "
 .word 95312
 .ascii "                "
 .word 95424
 .ascii "                "
 .word 95536
 .ascii "                "
 .word 95648
 .ascii "                "
 .word 95760
 .ascii "                "
 .word 95872
 .ascii "                "
 .word 95984
 .ascii "                "
 .word 96096
 .ascii "                "
 .word 96208
 .ascii "                "
 .word 96320
 .ascii "                "
 .word 96432
 .ascii "                "
 .word 96544
 .ascii "                "
 .word 96656
 .ascii "                "
 .word 96768
 .ascii "                "
 .word 96880
 .ascii "                "
 .word 96992
 .ascii "                "
 .word 97104
 .ascii "                "
 .word 97216
 .ascii "                "
 .word 97328
 .ascii "                "
 .word 97440
 .ascii "                "
 .word 97552
 .ascii "                "
 .word 97664
 .ascii "                "
 .word 97776
 .ascii "                "
 .word 97888
 .ascii "                "
 .word 98000
 .ascii "                "
 .word 98112
 .ascii "                "
 .word 98224
 .ascii "                "
 .word 98336
 .ascii "                "
 .word 98448
 .ascii "                "
 .word 98560
 .ascii "                "
 .word 98672
 .ascii "                "
 .word 98784
 .ascii "                "
 .word 98896
 .ascii "                "
 .word 99008
 .ascii "                "
 .word 99120
 .ascii "                "
 .word 99232
 .ascii "                "
 .word 99344
 .ascii "                "
 .word 99456
 .ascii "                "
 .word 99568
 .ascii "                "
 .word 99680
 .ascii "                "
 .word 99792
 .ascii "                "
 .word 99904
 .ascii "                "
 .word 100016
 .ascii "                "
 .word 100128
 .ascii "                "
 .word 100240
 .ascii "                "
 .word 100352
 .ascii "                "
 .word 100464
 .ascii "                "
 .word 100576
 .ascii "                "
 .word 100688
 .ascii "                "
 .word 100800
 .ascii "                "
 .word 100912
 .ascii "                "
 .word 101024
 .ascii "                "
 .word 101136
 .ascii "                "
 .word 101248
 .ascii "                "
 .word 101360
 .ascii "                "
 .word 101472
 .ascii "                "
 .word 101584
 .ascii "                "
 .word 101696
 .ascii "                "
 .word 101808
 .ascii "                "
 .word 101920
 .ascii "                "
 .word 102032
 .ascii "                "
 .word 102144
 .ascii "                "
 .word 102256
 .ascii "                "
 .word 102368
 .ascii "                "
 .word 102480
 .ascii "                "
 .word 102592
 .ascii "                "
 .word 102704
 .ascii "                "
 .word 102816
 .ascii "                "
 .word 102928
 .ascii "                "
 .word 103040
 .ascii "                "
 .word 103152
 .ascii "                "
 .word 103264
 .ascii "                "
 .word 103376
 .ascii "                "
 .word 103488
 .ascii "                "
 .word 103600
 .ascii "                "
 .word 103712
 .ascii "                "
 .word 103824
 .ascii "                "
 .word 103936
 .ascii "                "
 .word 104048
 .ascii "                "
 .word 104160
 .ascii "                "
 .word 104272
 .ascii "                "
 .word 104384
 .ascii "                "
 .word 104496
 .ascii "                "
 .word 104608
 .ascii "                "
 .word 104720
 .ascii "                "
 .word 104832
 .ascii "                "
 .word 104944
 .ascii "                "
 .word 105056
 .ascii "                "
 .word 105168
 .ascii "                "
 .word 105280
 .ascii "                "
 .word 105392
 .ascii "                "
 .word 105504
 .ascii "                "
 .word 105616
 .ascii "                "
 .word 105728
 .ascii "                "
 .word 105840
 .ascii "                "
 .word 105952
 .ascii "                "
 .word 106064
 .ascii "                "
 .word 106176
 .ascii "                "
 .word 106288
 .ascii "                "
 .word 106400
 .ascii "                "
 .word 106512
 .ascii "                "
 .word 106624
 .ascii "                "
 .word 106736
 .ascii "                "
 .word 106848
 .ascii "                "
 .word 106960
 .ascii "                "
 .word 107072
 .ascii "                "
 .word 107184
 .ascii "                "
 .word 107296
 .ascii "                "
 .word 107408
 .ascii "                "
 .word 107520
 .ascii "                "
 .word 107632
 .ascii "                "
 .word 107744
 .ascii "                "
 .word 107856
 .ascii "                "
 .word 107968
 .ascii "                "
 .word 108080
 .ascii "                "
 .word 108192
 .ascii "                "
 .word 108304
 .ascii "                "
 .word 108416
 .ascii "                "
 .word 108528
 .ascii "                "
 .word 108640
 .ascii "                "
 .word 108752
 .ascii "                "
 .word 108864
 .ascii "                "
 .word 108976
 .ascii "                "
 .word 109088
 .ascii "                "
 .word 109200
 .ascii "                "
 .word 109312
 .ascii "                "
 .word 109424
 .ascii "                "
 .word 109536
 .ascii "                "
 .word 109648
 .ascii "                "
 .word 109760
 .ascii "                "
 .word 109872
 .ascii "                "
 .word 109984
 .ascii "                "
 .word 110096
 .ascii "                "
 .word 110208
 .ascii "                "
 .word 110320
 .ascii "                "
 .word 110432
 .ascii "                "
 .word 110544
 .ascii "                "
 .word 110656
 .ascii "                "
 .word 110768
 .ascii "                "
 .word 110880
 .ascii "                "
 .word 110992
 .ascii "                "
 .word 111104
 .ascii "                "
 .word 111216
 .ascii "                "
 .word 111328
 .ascii "                "
 .word 111440
 .ascii "                "
 .word 111552
 .ascii "                "
 .word 111664
 .ascii "                "
 .word 111776
 .ascii "                "
 .word 111888
 .ascii "                "
 .word 112000
 .ascii "                "
 .word 112112
 .ascii "                "
 .word 112224
 .ascii "                "
 .word 112336
 .ascii "                "
 .word 112448
 .ascii "                "
 .word 112560
 .ascii "                "
 .word 112672
 .ascii "                "
 .word 112784
 .ascii "                "
 .word 112896
 .ascii "                "
 .word 113008
 .ascii "                "
 .word 113120
 .ascii "                "
 .word 113232
 .ascii "                "
 .word 113344
 .ascii "                "
 .word 113456
 .ascii "                "
 .word 113568
 .ascii "                "
 .word 113680
 .ascii "                "
 .word 113792
 .ascii "                "
 .word 113904
 .ascii "                "
 .word 114016
 .ascii "                "
 .word 114128
 .ascii "                "
 .word 114240
 .ascii "                "
 .word 114352
 .ascii "                "
 .word 114464
 .ascii "                "
 .word 114576
 .ascii "                "
 .word 114688
 .ascii "                "
 .word 114800
 .ascii "                "
 .word 114912
 .ascii "                "
 .word 115024
 .ascii "                "
 .word 115136
 .ascii "                "
 .word 115248
 .ascii "                "
 .word 115360
 .ascii "                "
 .word 115472
 .ascii "                "
 .word 115584
 .ascii "                "
 .word 115696
 .ascii "                "
 .word 115808
 .ascii "                "
 .word 115920
 .ascii "                "
 .word 116032
 .ascii "                "
 .word 116144
 .ascii "                "
 .word 116256
 .ascii "                "
 .word 116368
 .ascii "                "
 .word 116480
 .ascii "                "
 .word 116592
 .ascii "                "
 .word 116704
 .ascii "                "
 .word 131600
 .ascii "                "
 .word 131712
 .ascii "                "
 .word 131824
 .ascii "                "
 .word 131936
 .ascii "                "
 .word 132048
 .ascii "                "
 .word 132160
 .ascii "                "
 .word 132272
 .ascii "                "
 .word 132384
 .ascii "                "
 .word 132496
 .ascii "                "
 .word 132608
 .ascii "                "
 .word 132720
 .ascii "                "
 .word 132832
 .ascii "                "
 .word 132944
 .ascii "                "
 .word 133056
 .ascii "                "
 .word 131040
 .ascii "                "
 .word 131152
 .ascii "                "
 .word 133168
 .ascii "                "
 .word 133280
 .ascii "                "
 .word 137984
 .ascii "                "
 .word 138096
 .ascii "                "
 .word 138208
 .ascii "                "
 .word 138320
 .ascii "                "
 .word 138432
 .ascii "                "
 .word 138544
 .ascii "                "
 .word 138656
 .ascii "                "
 .word 138768
 .ascii "                "
 .word 138880
 .ascii "                "
 .word 138992
 .ascii "                "
 .word 139104
 .ascii "                "
 .word 139216
 .ascii "                "
 .word 139328
 .ascii "                "
 .word 139440
 .ascii "                "
 .word 139552
 .ascii "                "
 .word 139664
 .ascii "                "
 .word 139776
 .ascii "                "
 .word 139888
 .ascii "                "
 .word 140000
 .ascii "                "
 .word 140112
 .ascii "                "
 .word 140224
 .ascii "                "
 .word 133392
 .ascii "                "
 .word 133504
 .ascii "                "
 .word 133616
 .ascii "                "
 .word 133728
 .ascii "                "
 .word 133840
 .ascii "                "
 .word 133952
 .ascii "                "
 .word 134064
 .ascii "                "
 .word 134176
 .ascii "                "
 .word 134288
 .ascii "                "
 .word 134400
 .ascii "                "
 .word 134512
 .ascii "                "
 .word 134624
 .ascii "                "
 .word 134736
 .ascii "                "
 .word 134848
 .ascii "                "
 .word 134960
 .ascii "                "
 .word 135072
 .ascii "                "
 .word 135184
 .ascii "                "
 .word 135296
 .ascii "                "
 .word 135408
 .ascii "                "
 .word 135520
 .ascii "                "
 .word 135632
 .ascii "                "
 .word 135744
 .ascii "                "
 .word 135856
 .ascii "                "
 .word 135968
 .ascii "                "
 .word 136080
 .ascii "                "
 .word 136192
 .ascii "                "
 .word 136304
 .ascii "                "
 .word 136416
 .ascii "                "
 .word 136528
 .ascii "                "
 .word 136640
 .ascii "                "
 .word 136752
 .ascii "                "
 .word 136864
 .ascii "                "
 .word 136976
 .ascii "                "
 .word 137088
 .ascii "                "
 .word 137200
 .ascii "                "
 .word 137312
 .ascii "                "
 .word 137424
 .ascii "                "
 .word 137536
 .ascii "                "
 .word 131264
 .ascii "                "
 .word 131376
 .ascii "                "
 .word 91952
 .ascii "                "
 .word 92064
 .ascii "                "
 .word 92176
 .ascii "                "
 .word 92288
 .ascii "                "
 .word 92400
 .ascii "                "
 .word 92512
 .ascii "                "
 .word 84112
 .ascii "                "
 .word 84224
 .ascii "                "
 .word 84336
 .ascii "                "
 .word 84448
 .ascii "                "
 .word 84560
 .ascii "                "
 .word 84672
 .ascii "                "
 .word 84784
 .ascii "                "
 .word 84896
 .ascii "                "
 .word 85008
 .ascii "                "
 .word 85120
 .ascii "                "
 .word 85232
 .ascii "                "
 .word 85344
 .ascii "                "
 .word 85456
 .ascii "                "
 .word 85568
 .ascii "                "
 .word 85680
 .ascii "                "
 .word 85792
 .ascii "                "
 .word 85904
 .ascii "                "
 .word 86016
 .ascii "                "
 .word 86128
 .ascii "                "
 .word 86240
 .ascii "                "
 .word 86352
 .ascii "                "
 .word 86464
 .ascii "                "
 .word 86576
 .ascii "                "
 .word 86688
 .ascii "                "
 .word 86800
 .ascii "                "
 .word 86912
 .ascii "                "
 .word 87024
 .ascii "                "
 .word 87136
 .ascii "                "
 .word 87248
 .ascii "                "
 .word 87360
 .ascii "                "
 .word 87472
 .ascii "                "
 .word 87584
 .ascii "                "
 .word 87696
 .ascii "                "
 .word 87808
 .ascii "                "
 .word 87920
 .ascii "                "
 .word 88032
 .ascii "                "
 .word 88144
 .ascii "                "
 .word 88256
 .ascii "                "
 .word 88368
 .ascii "                "
 .word 88480
 .ascii "                "
 .word 88592
 .ascii "                "
 .word 88704
 .ascii "                "
 .word 88816
 .ascii "                "
 .word 88928
 .ascii "                "
 .word 89040
 .ascii "                "
 .word 89152
 .ascii "                "
 .word 89264
 .ascii "                "
 .word 89376
 .ascii "                "
 .word 89488
 .ascii "                "
 .word 89600
 .ascii "                "
 .word 89712
 .ascii "                "
 .word 89824
 .ascii "                "
 .word 89936
 .ascii "                "
 .word 90048
 .ascii "                "
 .word 90160
 .ascii "                "
 .word 90272
 .ascii "                "
 .word 90384
 .ascii "                "
 .word 90496
 .ascii "                "
 .word 90608
 .ascii "                "
 .word 90720
 .ascii "                "
 .word 90832
 .ascii "                "
 .word 90944
 .ascii "                "
 .word 91056
 .ascii "                "
 .word 91168
 .ascii "                "
 .word 91280
 .ascii "                "
 .word 91392
 .ascii "                "
 .word 91504
 .ascii "                "
 .word 91616
 .ascii "                "
 .word 91728
 .ascii "                "
 .word 91840
 .ascii "                "
 .word 84000
 .ascii "                "
 .word 81312
 .ascii "                "
 .word 119728
 .ascii "BVTHSKF         "
 .word 80640
 .ascii "VHKF            "
 .word 77504
 .ascii "                "
 .word 81760
 .ascii "                "
 .word 80528
 .ascii "                "
 .word 80752
 .ascii "                "
 .word 80416
 .ascii "                "
 .word 77616
 .ascii "                "
 .word 77728
 .ascii "                "
 .word 118272
 .ascii "                "
 .word 119840
 .ascii "                "
 .word 118384
 .ascii "                "
 .word 118496
 .ascii "                "
 .word 118608
 .ascii "                "
 .word 118720
 .ascii "                "
 .word 118832
 .ascii "                "
 .word 118944
 .ascii "                "
 .word 119056
 .ascii "                "
 .word 119168
 .ascii "                "
 .word 119392
 .ascii "                "
 .word 122416
 .ascii "                "
 .word 122528
 .ascii "                "
 .word 122640
 .ascii "                "
 .word 122752
 .ascii "                "
 .word 122864
 .ascii "                "
 .word 122976
 .ascii "                "
 .word 119504
 .ascii "                "
 .word 119616
 .ascii "                "
 .word 119952
 .ascii "                "
 .word 120064
 .ascii "                "
 .word 120176
 .ascii "                "
 .word 120288
 .ascii "                "
 .word 120400
 .ascii "                "
 .word 120512
 .ascii "                "
 .word 131488
 .ascii "                "
 .word 120624
 .ascii "                "
 .word 120736
 .ascii "                "
 .word 123088
 .ascii "                "
 .word 123200
 .ascii "                "
 .word 123312
 .ascii "                "
 .word 123424
 .ascii "                "
 .word 123536
 .ascii "                "
 .word 120848
 .ascii "                "
 .word 121296
 .ascii "                "
 .word 121072
 .ascii "                "
 .word 121184
 .ascii "                "
 .word 120960
 .ascii "                "
 .word 130928
 .ascii "                "
 .word 121408
 .ascii "                "
 .word 121520
 .ascii "                "
 .word 121632
 .ascii "                "
 .word 121744
 .ascii "                "
 .word 121856
 .ascii "                "
 .word 121968
 .ascii "                "
 .word 122080
 .ascii "                "
 .word 123760
 .ascii "                "
 .word 123872
 .ascii "                "
 .word 123984
 .ascii "                "
 .word 127232
 .ascii "                "
 .word 127344
 .ascii "                "
 .word 127456
 .ascii "                "
 .word 127568
 .ascii "                "
 .word 127680
 .ascii "                "
 .word 127792
 .ascii "                "
 .word 127904
 .ascii "                "
 .word 128016
 .ascii "                "
 .word 128128
 .ascii "                "
 .word 128240
 .ascii "                "
 .word 128352
 .ascii "                "
 .word 128464
 .ascii "                "
 .word 128576
 .ascii "                "
 .word 128688
 .ascii "                "
 .word 128800
 .ascii "                "
 .word 128912
 .ascii "                "
 .word 129024
 .ascii "                "
 .word 129136
 .ascii "                "
 .word 129248
 .ascii "                "
 .word 129360
 .ascii "                "
 .word 129472
 .ascii "                "
 .word 129584
 .ascii "                "
 .word 129696
 .ascii "                "
 .word 129808
 .ascii "                "
 .word 129920
 .ascii "                "
 .word 130032
 .ascii "                "
 .word 130144
 .ascii "                "
 .word 130256
 .ascii "                "
 .word 130368
 .ascii "                "
 .word 130480
 .ascii "                "
 .word 130592
 .ascii "                "
 .word 130704
 .ascii "                "
 .word 130816
 .ascii "                "
 .word 124096
 .ascii "                "
 .word 124208
 .ascii "                "
 .word 124320
 .ascii "                "
 .word 124432
 .ascii "                "
 .word 124544
 .ascii "                "
 .word 124656
 .ascii "                "
 .word 124768
 .ascii "                "
 .word 124880
 .ascii "                "
 .word 124992
 .ascii "                "
 .word 125104
 .ascii "                "
 .word 125216
 .ascii "                "
 .word 125328
 .ascii "                "
 .word 125440
 .ascii "                "
 .word 125552
 .ascii "                "
 .word 125664
 .ascii "                "
 .word 125776
 .ascii "                "
 .word 125888
 .ascii "                "
 .word 126000
 .ascii "                "
 .word 126112
 .ascii "                "
 .word 126224
 .ascii "                "
 .word 126336
 .ascii "                "
 .word 126448
 .ascii "                "
 .word 126560
 .ascii "                "
 .word 126672
 .ascii "                "
 .word 126784
 .ascii "                "
 .word 126896
 .ascii "                "
 .word 127008
 .ascii "                "
 .word 127120
 .ascii "                "
 .word 122192
 .ascii "                "
 .word 122304
 .ascii "                "
.p2align 2
.Lphysical_order:
 .word 319280
 .word 319344
 .word 319408
 .word 356976
 .word 357040
 .word 357104
 .word 357168
 .word 325168
 .word 325232
 .word 325296
 .word 422128
 .word 422192
 .word 422256
 .word 422320
 .word 422384
 .word 422448
 .word 422512
 .word 422576
 .word 422640
 .word 325424
 .word 325488
 .word 325360
 .word 321520
 .word 320560
 .word 327856
 .word 322480
 .word 322224
 .word 318640
 .word 318704
 .word 318768
 .word 318832
 .word 318896
 .word 318960
 .word 319024
 .word 319088
 .word 319152
 .word 319216
 .word 421680
 .word 421744
 .word 421808
 .word 421872
 .word 421936
 .word 420336
 .word 421616
 .word 420528
 .word 424048
 .word 424112
 .word 420592
 .word 420656
 .word 420720
 .word 420784
 .word 420848
 .word 420912
 .word 420976
 .word 421040
 .word 421104
 .word 421168
 .word 421232
 .word 421296
 .word 421360
 .word 421424
 .word 421488
 .word 421552
 .word 322544
 .word 323952
 .word 321776
 .word 356016
 .word 322352
 .word 322416
 .word 324592
 .word 348656
 .word 320496
 .word 348720
 .word 358896
 .word 326064
 .word 320240
 .word 348592
 .word 355952
 .word 324336
 .word 327344
 .word 327472
 .word 328432
 .word 320176
 .word 355504
 .word 355376
 .word 355632
 .word 355440
 .word 355568
 .word 355824
 .word 355888
 .word 321904
 .word 323248
 .word 321584
 .word 319728
 .word 319920
 .word 325936
 .word 320624
 .word 356784
 .word 325808
 .word 320048
 .word 319984
 .word 324528
 .word 319536
 .word 326448
 .word 326256
 .word 322032
 .word 322160
 .word 322928
 .word 328112
 .word 327920
 .word 432112
 .word 432048
 .word 431984
 .word 431920
 .word 327984
 .word 323888
 .word 328048
 .word 356272
 .word 356336
 .word 356400
 .word 356464
 .word 322992
 .word 321648
 .word 321968
 .word 320880
 .word 326128
 .word 326320
 .word 327280
 .word 359728
 .word 327408
 .word 328496
 .word 319472
 .word 324272
 .word 356912
 .word 327600
 .word 324080
 .word 328624
 .word 326192
 .word 326384
 .word 326576
 .word 326704
 .word 326832
 .word 326960
 .word 327088
 .word 327216
 .word 324976
 .word 325040
 .word 326512
 .word 326640
 .word 326768
 .word 326896
 .word 327024
 .word 327152
 .word 325872
 .word 322672
 .word 322736
 .word 322800
 .word 322864
 .word 326000
 .word 322608
 .word 327536
 .word 323184
 .word 323056
 .word 319792
 .word 320112
 .word 327664
 .word 327728
 .word 327792
 .word 324784
 .word 324848
 .word 324912
 .word 328176
 .word 328240
 .word 328304
 .word 328368
 .word 321712
 .word 321840
 .word 320688
 .word 324464
 .word 319600
 .word 324208
 .word 324720
 .word 324016
 .word 356848
 .word 322288
 .word 320816
 .word 320944
 .word 321008
 .word 321072
 .word 321136
 .word 321200
 .word 321264
 .word 321328
 .word 321392
 .word 321456
 .word 320432
 .word 324144
 .word 324656
 .word 325552
 .word 356656
 .word 328816
 .word 328944
 .word 356208
 .word 319856
 .word 319664
 .word 422000
 .word 422064
 .word 323312
 .word 323376
 .word 323440
 .word 323504
 .word 325616
 .word 356720
 .word 328880
 .word 329008
 .word 348528
 .word 323568
 .word 323632
 .word 323696
 .word 323760
 .word 325104
 .word 329072
 .word 320304
 .word 320368
 .word 323824
 .word 356080
 .word 356144
 .word 329136
 .word 329200
 .word 329264
 .word 329328
 .word 329392
 .word 329456
 .word 329520
 .word 329584
 .word 329648
 .word 329712
 .word 329776
 .word 329840
 .word 329904
 .word 329968
 .word 330032
 .word 330096
 .word 330160
 .word 330224
 .word 330288
 .word 330352
 .word 330416
 .word 330480
 .word 330544
 .word 330608
 .word 330672
 .word 330736
 .word 330800
 .word 330864
 .word 330928
 .word 330992
 .word 331056
 .word 331120
 .word 331184
 .word 331248
 .word 331312
 .word 331376
 .word 331440
 .word 331504
 .word 331568
 .word 331632
 .word 331696
 .word 331760
 .word 331824
 .word 331888
 .word 331952
 .word 332016
 .word 332080
 .word 332144
 .word 332208
 .word 332272
 .word 332336
 .word 332400
 .word 332464
 .word 332528
 .word 332592
 .word 332656
 .word 332720
 .word 332784
 .word 332848
 .word 332912
 .word 332976
 .word 333040
 .word 333104
 .word 333168
 .word 333232
 .word 333296
 .word 333360
 .word 333424
 .word 333488
 .word 333552
 .word 333616
 .word 333680
 .word 333744
 .word 333808
 .word 333872
 .word 333936
 .word 334000
 .word 334064
 .word 334128
 .word 334192
 .word 334256
 .word 334320
 .word 334384
 .word 334448
 .word 334512
 .word 334576
 .word 334640
 .word 334704
 .word 334768
 .word 334832
 .word 334896
 .word 334960
 .word 335024
 .word 335088
 .word 335152
 .word 335216
 .word 335280
 .word 335344
 .word 335408
 .word 335472
 .word 335536
 .word 335600
 .word 335664
 .word 335728
 .word 335792
 .word 335856
 .word 335920
 .word 335984
 .word 336048
 .word 336112
 .word 336176
 .word 336240
 .word 336304
 .word 336368
 .word 336432
 .word 336496
 .word 336560
 .word 336624
 .word 336688
 .word 336752
 .word 336816
 .word 336880
 .word 336944
 .word 337008
 .word 337072
 .word 337136
 .word 337200
 .word 337264
 .word 337328
 .word 337392
 .word 337456
 .word 337520
 .word 337584
 .word 337648
 .word 337712
 .word 337776
 .word 337840
 .word 337904
 .word 337968
 .word 338032
 .word 338096
 .word 338160
 .word 338224
 .word 338288
 .word 338352
 .word 338416
 .word 338480
 .word 338544
 .word 338608
 .word 338672
 .word 338736
 .word 338800
 .word 338864
 .word 338928
 .word 338992
 .word 339056
 .word 339120
 .word 339184
 .word 339248
 .word 339312
 .word 339376
 .word 339440
 .word 339504
 .word 339568
 .word 339632
 .word 339696
 .word 339760
 .word 339824
 .word 339888
 .word 339952
 .word 340016
 .word 340080
 .word 340144
 .word 340208
 .word 340272
 .word 340336
 .word 340400
 .word 340464
 .word 340528
 .word 340592
 .word 340656
 .word 340720
 .word 340784
 .word 340848
 .word 340912
 .word 340976
 .word 341040
 .word 341104
 .word 341168
 .word 341232
 .word 341296
 .word 341360
 .word 341424
 .word 341488
 .word 341552
 .word 341616
 .word 341680
 .word 341744
 .word 341808
 .word 341872
 .word 341936
 .word 342000
 .word 342064
 .word 342128
 .word 342192
 .word 342256
 .word 342320
 .word 342384
 .word 342448
 .word 342512
 .word 342576
 .word 342640
 .word 342704
 .word 342768
 .word 342832
 .word 342896
 .word 342960
 .word 343024
 .word 343088
 .word 343152
 .word 343216
 .word 343280
 .word 343344
 .word 343408
 .word 343472
 .word 343536
 .word 343600
 .word 343664
 .word 343728
 .word 343792
 .word 343856
 .word 343920
 .word 343984
 .word 344048
 .word 344112
 .word 344176
 .word 344240
 .word 344304
 .word 344368
 .word 344432
 .word 344496
 .word 344560
 .word 344624
 .word 344688
 .word 344752
 .word 344816
 .word 344880
 .word 344944
 .word 345008
 .word 345072
 .word 345136
 .word 345200
 .word 345264
 .word 345328
 .word 345392
 .word 345456
 .word 345520
 .word 345584
 .word 345648
 .word 345712
 .word 345776
 .word 345840
 .word 345904
 .word 345968
 .word 346032
 .word 346096
 .word 346160
 .word 346224
 .word 346288
 .word 346352
 .word 346416
 .word 346480
 .word 346544
 .word 346608
 .word 346672
 .word 346736
 .word 346800
 .word 346864
 .word 346928
 .word 346992
 .word 347056
 .word 347120
 .word 347184
 .word 347248
 .word 347312
 .word 347376
 .word 347440
 .word 347504
 .word 347568
 .word 347632
 .word 347696
 .word 347760
 .word 347824
 .word 347888
 .word 347952
 .word 348016
 .word 348080
 .word 348144
 .word 348208
 .word 348272
 .word 348336
 .word 348400
 .word 348464
 .word 359792
 .word 359856
 .word 359920
 .word 359984
 .word 360048
 .word 360112
 .word 360176
 .word 360240
 .word 360304
 .word 360368
 .word 360432
 .word 360496
 .word 360560
 .word 360624
 .word 360688
 .word 360752
 .word 360816
 .word 360880
 .word 360944
 .word 361008
 .word 361072
 .word 361136
 .word 361200
 .word 361264
 .word 361328
 .word 361392
 .word 361456
 .word 361520
 .word 361584
 .word 361648
 .word 361712
 .word 361776
 .word 361840
 .word 361904
 .word 361968
 .word 362032
 .word 362096
 .word 362160
 .word 362224
 .word 362288
 .word 362352
 .word 362416
 .word 362480
 .word 362544
 .word 362608
 .word 362672
 .word 362736
 .word 362800
 .word 362864
 .word 362928
 .word 362992
 .word 363056
 .word 363120
 .word 363184
 .word 363248
 .word 363312
 .word 363376
 .word 363440
 .word 363504
 .word 363568
 .word 363632
 .word 363696
 .word 363760
 .word 363824
 .word 363888
 .word 363952
 .word 364016
 .word 364080
 .word 364144
 .word 364208
 .word 364272
 .word 364336
 .word 364400
 .word 364464
 .word 364528
 .word 364592
 .word 364656
 .word 364720
 .word 364784
 .word 364848
 .word 364912
 .word 364976
 .word 365040
 .word 365104
 .word 365168
 .word 365232
 .word 365296
 .word 365360
 .word 365424
 .word 365488
 .word 365552
 .word 365616
 .word 365680
 .word 365744
 .word 365808
 .word 365872
 .word 365936
 .word 366000
 .word 366064
 .word 366128
 .word 366192
 .word 366256
 .word 366320
 .word 366384
 .word 366448
 .word 366512
 .word 366576
 .word 366640
 .word 366704
 .word 366768
 .word 366832
 .word 366896
 .word 366960
 .word 367024
 .word 367088
 .word 367152
 .word 367216
 .word 367280
 .word 367344
 .word 367408
 .word 367472
 .word 367536
 .word 367600
 .word 367664
 .word 367728
 .word 367792
 .word 367856
 .word 367920
 .word 367984
 .word 368048
 .word 368112
 .word 368176
 .word 368240
 .word 368304
 .word 368368
 .word 368432
 .word 368496
 .word 368560
 .word 368624
 .word 368688
 .word 368752
 .word 368816
 .word 368880
 .word 368944
 .word 369008
 .word 369072
 .word 369136
 .word 369200
 .word 369264
 .word 369328
 .word 369392
 .word 369456
 .word 369520
 .word 369584
 .word 369648
 .word 369712
 .word 369776
 .word 369840
 .word 369904
 .word 369968
 .word 370032
 .word 370096
 .word 370160
 .word 370224
 .word 370288
 .word 370352
 .word 370416
 .word 370480
 .word 370544
 .word 370608
 .word 370672
 .word 370736
 .word 370800
 .word 370864
 .word 370928
 .word 370992
 .word 371056
 .word 371120
 .word 371184
 .word 371248
 .word 371312
 .word 371376
 .word 371440
 .word 371504
 .word 371568
 .word 371632
 .word 371696
 .word 371760
 .word 371824
 .word 371888
 .word 371952
 .word 372016
 .word 372080
 .word 372144
 .word 372208
 .word 372272
 .word 372336
 .word 372400
 .word 372464
 .word 372528
 .word 372592
 .word 372656
 .word 372720
 .word 372784
 .word 372848
 .word 372912
 .word 372976
 .word 373040
 .word 373104
 .word 373168
 .word 373232
 .word 373296
 .word 373360
 .word 373424
 .word 373488
 .word 373552
 .word 373616
 .word 373680
 .word 373744
 .word 373808
 .word 373872
 .word 373936
 .word 374000
 .word 374064
 .word 374128
 .word 374192
 .word 374256
 .word 374320
 .word 374384
 .word 374448
 .word 374512
 .word 374576
 .word 374640
 .word 374704
 .word 374768
 .word 374832
 .word 374896
 .word 374960
 .word 375024
 .word 375088
 .word 375152
 .word 375216
 .word 375280
 .word 375344
 .word 375408
 .word 375472
 .word 375536
 .word 375600
 .word 375664
 .word 375728
 .word 375792
 .word 375856
 .word 375920
 .word 375984
 .word 376048
 .word 376112
 .word 376176
 .word 376240
 .word 376304
 .word 376368
 .word 376432
 .word 376496
 .word 376560
 .word 376624
 .word 376688
 .word 376752
 .word 376816
 .word 376880
 .word 376944
 .word 377008
 .word 377072
 .word 377136
 .word 377200
 .word 377264
 .word 377328
 .word 377392
 .word 377456
 .word 377520
 .word 377584
 .word 377648
 .word 377712
 .word 377776
 .word 377840
 .word 377904
 .word 377968
 .word 378032
 .word 378096
 .word 378160
 .word 378224
 .word 378288
 .word 378352
 .word 378416
 .word 378480
 .word 378544
 .word 378608
 .word 378672
 .word 378736
 .word 378800
 .word 378864
 .word 378928
 .word 378992
 .word 379056
 .word 379120
 .word 379184
 .word 379248
 .word 379312
 .word 379376
 .word 379440
 .word 379504
 .word 379568
 .word 379632
 .word 379696
 .word 379760
 .word 379824
 .word 379888
 .word 379952
 .word 380016
 .word 380080
 .word 380144
 .word 380208
 .word 380272
 .word 380336
 .word 380400
 .word 380464
 .word 380528
 .word 380592
 .word 380656
 .word 380720
 .word 380784
 .word 380848
 .word 380912
 .word 380976
 .word 381040
 .word 381104
 .word 381168
 .word 381232
 .word 381296
 .word 381360
 .word 381424
 .word 381488
 .word 381552
 .word 381616
 .word 381680
 .word 381744
 .word 381808
 .word 381872
 .word 381936
 .word 382000
 .word 382064
 .word 382128
 .word 382192
 .word 382256
 .word 382320
 .word 382384
 .word 382448
 .word 382512
 .word 382576
 .word 382640
 .word 382704
 .word 382768
 .word 382832
 .word 382896
 .word 382960
 .word 383024
 .word 383088
 .word 383152
 .word 383216
 .word 383280
 .word 383344
 .word 383408
 .word 383472
 .word 383536
 .word 383600
 .word 383664
 .word 383728
 .word 383792
 .word 383856
 .word 383920
 .word 383984
 .word 384048
 .word 384112
 .word 384176
 .word 384240
 .word 384304
 .word 384368
 .word 384432
 .word 384496
 .word 384560
 .word 384624
 .word 384688
 .word 384752
 .word 384816
 .word 384880
 .word 384944
 .word 385008
 .word 385072
 .word 385136
 .word 385200
 .word 385264
 .word 385328
 .word 385392
 .word 385456
 .word 385520
 .word 385584
 .word 385648
 .word 385712
 .word 385776
 .word 385840
 .word 385904
 .word 385968
 .word 386032
 .word 386096
 .word 386160
 .word 386224
 .word 386288
 .word 386352
 .word 386416
 .word 386480
 .word 386544
 .word 386608
 .word 386672
 .word 386736
 .word 386800
 .word 386864
 .word 386928
 .word 386992
 .word 387056
 .word 387120
 .word 387184
 .word 387248
 .word 387312
 .word 387376
 .word 387440
 .word 387504
 .word 387568
 .word 387632
 .word 387696
 .word 387760
 .word 387824
 .word 387888
 .word 387952
 .word 388016
 .word 388080
 .word 388144
 .word 388208
 .word 388272
 .word 388336
 .word 388400
 .word 388464
 .word 388528
 .word 388592
 .word 388656
 .word 388720
 .word 388784
 .word 388848
 .word 388912
 .word 388976
 .word 389040
 .word 389104
 .word 389168
 .word 389232
 .word 389296
 .word 389360
 .word 389424
 .word 389488
 .word 389552
 .word 389616
 .word 389680
 .word 389744
 .word 389808
 .word 389872
 .word 389936
 .word 390000
 .word 390064
 .word 390128
 .word 390192
 .word 390256
 .word 390320
 .word 390384
 .word 390448
 .word 390512
 .word 390576
 .word 390640
 .word 390704
 .word 390768
 .word 390832
 .word 390896
 .word 390960
 .word 391024
 .word 391088
 .word 391152
 .word 391216
 .word 391280
 .word 391344
 .word 391408
 .word 391472
 .word 391536
 .word 391600
 .word 391664
 .word 391728
 .word 391792
 .word 391856
 .word 391920
 .word 391984
 .word 392048
 .word 392112
 .word 392176
 .word 392240
 .word 392304
 .word 392368
 .word 392432
 .word 392496
 .word 392560
 .word 392624
 .word 392688
 .word 392752
 .word 392816
 .word 392880
 .word 392944
 .word 393008
 .word 393072
 .word 393136
 .word 393200
 .word 393264
 .word 393328
 .word 393392
 .word 393456
 .word 393520
 .word 393584
 .word 393648
 .word 393712
 .word 393776
 .word 393840
 .word 393904
 .word 393968
 .word 394032
 .word 394096
 .word 394160
 .word 394224
 .word 394288
 .word 394352
 .word 394416
 .word 394480
 .word 394544
 .word 394608
 .word 394672
 .word 394736
 .word 394800
 .word 394864
 .word 394928
 .word 394992
 .word 395056
 .word 395120
 .word 395184
 .word 395248
 .word 395312
 .word 395376
 .word 395440
 .word 395504
 .word 395568
 .word 395632
 .word 395696
 .word 395760
 .word 395824
 .word 395888
 .word 395952
 .word 396016
 .word 396080
 .word 396144
 .word 396208
 .word 396272
 .word 396336
 .word 396400
 .word 396464
 .word 396528
 .word 396592
 .word 396656
 .word 396720
 .word 396784
 .word 396848
 .word 396912
 .word 396976
 .word 397040
 .word 397104
 .word 397168
 .word 397232
 .word 397296
 .word 397360
 .word 397424
 .word 397488
 .word 397552
 .word 397616
 .word 397680
 .word 397744
 .word 397808
 .word 397872
 .word 397936
 .word 398000
 .word 398064
 .word 398128
 .word 398192
 .word 398256
 .word 398320
 .word 398384
 .word 398448
 .word 398512
 .word 398576
 .word 398640
 .word 398704
 .word 398768
 .word 398832
 .word 398896
 .word 398960
 .word 399024
 .word 399088
 .word 399152
 .word 399216
 .word 399280
 .word 399344
 .word 399408
 .word 399472
 .word 399536
 .word 399600
 .word 399664
 .word 399728
 .word 399792
 .word 399856
 .word 399920
 .word 399984
 .word 400048
 .word 400112
 .word 400176
 .word 400240
 .word 400304
 .word 400368
 .word 400432
 .word 400496
 .word 400560
 .word 400624
 .word 400688
 .word 400752
 .word 400816
 .word 400880
 .word 400944
 .word 401008
 .word 401072
 .word 401136
 .word 401200
 .word 401264
 .word 401328
 .word 401392
 .word 401456
 .word 401520
 .word 401584
 .word 401648
 .word 401712
 .word 401776
 .word 401840
 .word 401904
 .word 401968
 .word 402032
 .word 402096
 .word 402160
 .word 402224
 .word 402288
 .word 402352
 .word 402416
 .word 402480
 .word 402544
 .word 402608
 .word 402672
 .word 402736
 .word 402800
 .word 402864
 .word 402928
 .word 402992
 .word 403056
 .word 403120
 .word 403184
 .word 403248
 .word 403312
 .word 403376
 .word 403440
 .word 403504
 .word 403568
 .word 403632
 .word 403696
 .word 403760
 .word 403824
 .word 403888
 .word 403952
 .word 404016
 .word 404080
 .word 404144
 .word 404208
 .word 404272
 .word 404336
 .word 404400
 .word 404464
 .word 404528
 .word 404592
 .word 404656
 .word 404720
 .word 404784
 .word 404848
 .word 404912
 .word 404976
 .word 405040
 .word 405104
 .word 405168
 .word 405232
 .word 405296
 .word 405360
 .word 405424
 .word 405488
 .word 405552
 .word 405616
 .word 405680
 .word 405744
 .word 405808
 .word 405872
 .word 405936
 .word 406000
 .word 406064
 .word 406128
 .word 406192
 .word 406256
 .word 406320
 .word 406384
 .word 406448
 .word 406512
 .word 406576
 .word 406640
 .word 406704
 .word 406768
 .word 406832
 .word 406896
 .word 406960
 .word 407024
 .word 407088
 .word 407152
 .word 407216
 .word 407280
 .word 407344
 .word 407408
 .word 407472
 .word 407536
 .word 407600
 .word 407664
 .word 407728
 .word 407792
 .word 407856
 .word 407920
 .word 407984
 .word 408048
 .word 408112
 .word 408176
 .word 408240
 .word 408304
 .word 408368
 .word 408432
 .word 408496
 .word 408560
 .word 408624
 .word 408688
 .word 408752
 .word 408816
 .word 408880
 .word 408944
 .word 409008
 .word 409072
 .word 409136
 .word 409200
 .word 409264
 .word 409328
 .word 409392
 .word 409456
 .word 409520
 .word 409584
 .word 409648
 .word 409712
 .word 409776
 .word 409840
 .word 409904
 .word 409968
 .word 410032
 .word 410096
 .word 410160
 .word 410224
 .word 410288
 .word 410352
 .word 410416
 .word 410480
 .word 410544
 .word 410608
 .word 410672
 .word 410736
 .word 410800
 .word 410864
 .word 410928
 .word 410992
 .word 411056
 .word 411120
 .word 411184
 .word 411248
 .word 411312
 .word 411376
 .word 411440
 .word 411504
 .word 411568
 .word 411632
 .word 411696
 .word 411760
 .word 411824
 .word 411888
 .word 411952
 .word 412016
 .word 412080
 .word 412144
 .word 412208
 .word 412272
 .word 412336
 .word 412400
 .word 412464
 .word 412528
 .word 412592
 .word 412656
 .word 412720
 .word 412784
 .word 412848
 .word 412912
 .word 412976
 .word 413040
 .word 413104
 .word 413168
 .word 413232
 .word 413296
 .word 413360
 .word 413424
 .word 413488
 .word 413552
 .word 413616
 .word 413680
 .word 413744
 .word 413808
 .word 413872
 .word 413936
 .word 414000
 .word 414064
 .word 414128
 .word 414192
 .word 414256
 .word 414320
 .word 414384
 .word 414448
 .word 414512
 .word 414576
 .word 414640
 .word 414704
 .word 414768
 .word 414832
 .word 414896
 .word 414960
 .word 415024
 .word 415088
 .word 415152
 .word 415216
 .word 415280
 .word 415344
 .word 415408
 .word 415472
 .word 415536
 .word 415600
 .word 415664
 .word 415728
 .word 415792
 .word 415856
 .word 415920
 .word 415984
 .word 416048
 .word 416112
 .word 416176
 .word 416240
 .word 416304
 .word 416368
 .word 416432
 .word 416496
 .word 416560
 .word 416624
 .word 416688
 .word 416752
 .word 416816
 .word 416880
 .word 416944
 .word 417008
 .word 417072
 .word 417136
 .word 417200
 .word 417264
 .word 417328
 .word 417392
 .word 417456
 .word 417520
 .word 417584
 .word 417648
 .word 417712
 .word 417776
 .word 417840
 .word 417904
 .word 417968
 .word 418032
 .word 418096
 .word 418160
 .word 418224
 .word 418288
 .word 418352
 .word 418416
 .word 418480
 .word 418544
 .word 418608
 .word 418672
 .word 418736
 .word 418800
 .word 418864
 .word 418928
 .word 418992
 .word 419056
 .word 419120
 .word 419184
 .word 419248
 .word 419312
 .word 419376
 .word 419440
 .word 419504
 .word 419568
 .word 419632
 .word 419696
 .word 419760
 .word 419824
 .word 419888
 .word 419952
 .word 420016
 .word 420080
 .word 420144
 .word 420208
 .word 420272
 .word 328688
 .word 328752
 .word 348784
 .word 348848
 .word 348912
 .word 348976
 .word 349040
 .word 324400
 .word 420400
 .word 420464
 .word 325680
 .word 356528
 .word 325744
 .word 356592
 .word 355760
 .word 355696
 .word 320752
 .word 358832
 .word 359088
 .word 328560
 .word 322096
 .word 323120
 .word 358960
 .word 359024
 .word 359152
 .word 359216
 .word 359280
 .word 359344
 .word 359408
 .word 359472
 .word 359536
 .word 359600
 .word 359664
 .word 357232
 .word 357296
 .word 357360
 .word 357424
 .word 357488
 .word 357552
 .word 357616
 .word 357680
 .word 357744
 .word 357808
 .word 357872
 .word 357936
 .word 358000
 .word 358064
 .word 358128
 .word 358192
 .word 358256
 .word 358512
 .word 358576
 .word 358320
 .word 358384
 .word 358448
 .word 358640
 .word 358704
 .word 422704
 .word 422768
 .word 422832
 .word 422896
 .word 422960
 .word 423024
 .word 423088
 .word 423152
 .word 423216
 .word 423280
 .word 423344
 .word 423408
 .word 423472
 .word 423536
 .word 423600
 .word 423664
 .word 423728
 .word 423792
 .word 423856
 .word 358768
 .word 423920
 .word 423984
 .word 424176
 .word 424304
 .word 424240
 .word 424368
 .word 424432
 .word 424496
 .word 424560
 .word 349104
 .word 349168
 .word 349232
 .word 349296
 .word 349360
 .word 349424
 .word 349488
 .word 349552
 .word 349616
 .word 349680
 .word 349744
 .word 349808
 .word 349872
 .word 349936
 .word 350000
 .word 350064
 .word 350128
 .word 350192
 .word 350256
 .word 350320
 .word 350384
 .word 350448
 .word 350512
 .word 350576
 .word 350640
 .word 350704
 .word 350768
 .word 350832
 .word 350896
 .word 350960
 .word 351024
 .word 351088
 .word 351152
 .word 351216
 .word 351280
 .word 351344
 .word 351408
 .word 351472
 .word 351536
 .word 351600
 .word 351664
 .word 351728
 .word 351792
 .word 351856
 .word 351920
 .word 351984
 .word 352048
 .word 352112
 .word 352176
 .word 352240
 .word 352304
 .word 352368
 .word 352432
 .word 352496
 .word 352560
 .word 352624
 .word 352688
 .word 352752
 .word 352816
 .word 352880
 .word 352944
 .word 353008
 .word 353072
 .word 353136
 .word 353200
 .word 353264
 .word 353328
 .word 353392
 .word 353456
 .word 353520
 .word 353584
 .word 353648
 .word 353712
 .word 353776
 .word 353840
 .word 353904
 .word 353968
 .word 354032
 .word 354096
 .word 354160
 .word 354224
 .word 354288
 .word 354352
 .word 354416
 .word 354480
 .word 354544
 .word 354608
 .word 354672
 .word 354736
 .word 354800
 .word 354864
 .word 354928
 .word 354992
 .word 355056
 .word 355120
 .word 355184
 .word 355248
 .word 355312
 .word 424624
 .word 424688
 .word 424752
 .word 424880
 .word 425008
 .word 424816
 .word 424944
 .word 425072
 .word 425136
 .word 425200
 .word 425264
 .word 425328
 .word 425392
 .word 425456
 .word 425520
 .word 425648
 .word 425712
 .word 425776
 .word 425840
 .word 425904
 .word 425968
 .word 426032
 .word 426096
 .word 426160
 .word 426224
 .word 426288
 .word 426352
 .word 426416
 .word 426480
 .word 426544
 .word 426608
 .word 426672
 .word 426736
 .word 426800
 .word 426864
 .word 426928
 .word 426992
 .word 427056
 .word 427120
 .word 427184
 .word 427248
 .word 427312
 .word 427376
 .word 427440
 .word 427504
 .word 427568
 .word 427632
 .word 427760
 .word 427888
 .word 428144
 .word 428208
 .word 427952
 .word 428016
 .word 428080
 .word 428272
 .word 428336
 .word 428400
 .word 428464
 .word 428528
 .word 428592
 .word 428656
 .word 428720
 .word 425584
 .word 427696
 .word 427824
 .word 428784
 .word 428848
 .word 428912
 .word 428976
 .word 429040
 .word 432368
 .word 432432
 .word 429168
 .word 429232
 .word 429360
 .word 429424
 .word 429488
 .word 429552
 .word 429616
 .word 429680
 .word 429744
 .word 429808
 .word 429872
 .word 429936
 .word 430000
 .word 430064
 .word 430128
 .word 430192
 .word 430256
 .word 430320
 .word 430384
 .word 430448
 .word 430512
 .word 430576
 .word 430640
 .word 430768
 .word 430896
 .word 430704
 .word 430832
 .word 430960
 .word 431024
 .word 431088
 .word 431152
 .word 431216
 .word 429104
 .word 431280
 .word 431344
 .word 431408
 .word 431472
 .word 431536
 .word 431600
 .word 431664
 .word 431728
 .word 431792
 .word 431856
 .word 432496
 .word 432560
 .word 432176
 .word 432240
 .word 432304
 .word 429296
 .word 432624
 .word 432688
 .word 432752
 .word 432816
 .word 432880
 .word 432944
 .word 433008
 .word 433072
 .word 433136
 .word 433200
.section .note.GNU-stack,"",%progbits

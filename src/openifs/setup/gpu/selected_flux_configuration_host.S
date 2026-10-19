#include "../../support/gpu/preserved_weather_calls.inc.S"
.arch armv8.2-a
.text
.p2align 2
.global md2asm_initialize_selected_flux_configuration
.type md2asm_initialize_selected_flux_configuration,%function
md2asm_initialize_selected_flux_configuration:
 sub sp,sp,#1,lsl#12
 sub sp,sp,#1856
 stp x19,x20,[sp]
 stp x21,x22,[sp,#16]
 stp x23,x24,[sp,#32]
 stp x25,x26,[sp,#48]
 stp x27,x28,[sp,#64]
 stp x29,x30,[sp,#80]
 str x18,[sp,#96]
 mov x19,x0
 mov x20,x1
 mov x21,x2
 mov x22,x3
 mov x26,xzr
 str xzr,[sp,#208]
 str xzr,[sp,#216]
 str x18,[sp,#96]
 bl __errno_location
 ldr x18,[sp,#96]
 mov x27,x0
 ldr w28,[x27]
 mov w0,#2
 cbz x19,.Lflux_return
 cbz x20,.Lflux_return
 cmp x20,#64,lsl#12
 b.hi .Lflux_return
 adds x9,x19,x20
 b.cs .Lflux_return
 cbz x21,.Lflux_return
 cbz x22,.Lflux_return
 tst x21,#7
 b.ne .Lflux_return
 tst x22,#3
 b.ne .Lflux_return
 ldp w9,w10,[x22]
 cmp w9,#24
 b.ne .Lflux_return
 cmp w10,#86
 b.ne .Lflux_return
 ldp w9,w10,[x22,#8]
 cmp w9,#1
 b.ne .Lflux_return
 cmp w10,#2
 b.ne .Lflux_return
 ldp w9,w10,[x22,#16]
 orr w9,w9,w10
 ldr w10,[x22,#24]
 orr w9,w9,w10
 cbnz w9,.Lflux_return
 ldr w9,[x22,#28]
 cmp w9,#1
 b.ne .Lflux_return
 ldp x23,x10,[x21]
 cbz x23,.Lflux_return
 tst x23,#7
 b.ne .Lflux_return
 movz x11,#(162272 & 65535)
 movk x11,#(162272 >> 16),lsl#16
 cmp x10,x11
 b.lo .Lflux_return
 adds x9,x23,x11
 b.cs .Lflux_return
 ldp x24,x10,[x21,#16]
 cbz x24,.Lflux_return
 tst x24,#7
 b.ne .Lflux_return
 movz x11,#(330728 & 65535)
 movk x11,#(330728 >> 16),lsl#16
 cmp x10,x11
 b.lo .Lflux_return
 adds x9,x24,x11
 b.cs .Lflux_return
 ldp x25,x10,[x21,#32]
 cbz x25,.Lflux_return
 tst x25,#7
 b.ne .Lflux_return
 cmp x10,#936
 b.lo .Lflux_return
 adds x9,x25,#936
 b.cs .Lflux_return
 movz x9,#31088
 movk x9,#2,lsl#16
 ldr x10,[x23,x9]
 cbnz x10,.Lflux_return
 movz x9,#352
 movk x9,#5,lsl#16
 ldr x10,[x24,x9]
 cbnz x10,.Lflux_return
 movz x9,#416
 movk x9,#5,lsl#16
 ldr x10,[x24,x9]
 cbnz x10,.Lflux_return
 movz x9,#2936
 movk x9,#5,lsl#16
 ldr x10,[x24,x9]
 cbnz x10,.Lflux_return
 movz x9,#0
 movk x9,#0,lsl#16
 ldr x10,[x25,x9]
 cbnz x10,.Lflux_return
 movz x9,#88
 movk x9,#0,lsl#16
 ldr x10,[x25,x9]
 cbnz x10,.Lflux_return
 mov x0,x19
 mov x1,x20
 add x2,sp,#256
 str x18,[sp,#96]
 bl md2asm_parse_physics_output_requests
 ldr x18,[sp,#96]
 cbnz w0,.Lflux_return
 mov x0,x19
 mov x1,x20
 adr x2,.LNAMCFU
 mov x3,#6
 str x18,[sp,#96]
 bl md2asm_require_empty_physics_group
 ldr x18,[sp,#96]
 cbnz w0,.Lflux_return
 mov x0,x19
 mov x1,x20
 adr x2,.LNAMXFU
 mov x3,#6
 str x18,[sp,#96]
 bl md2asm_require_empty_physics_group
 ldr x18,[sp,#96]
 cbnz w0,.Lflux_return
 mov x0,x19
 mov x1,x20
 adr x2,.LNAMMCUF
 mov x3,#7
 str x18,[sp,#96]
 bl md2asm_require_empty_physics_group
 ldr x18,[sp,#96]
 cbnz w0,.Lflux_return
 mov x0,#1
 str x18,[sp,#96]
 bl malloc
 ldr x18,[sp,#96]
 cbz x0,.Lflux_alloc_bad
 mov x26,x0
 mov x0,#1
 str x18,[sp,#96]
 bl malloc
 ldr x18,[sp,#96]
 cbz x0,.Lflux_alloc_bad
 str x0,[sp,#208]
 movz x9,#(161768 & 65535)
 movk x9,#(161768 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161772 & 65535)
 movk x9,#(161772 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161776 & 65535)
 movk x9,#(161776 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161844 & 65535)
 movk x9,#(161844 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161780 & 65535)
 movk x9,#(161780 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161848 & 65535)
 movk x9,#(161848 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161784 & 65535)
 movk x9,#(161784 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161852 & 65535)
 movk x9,#(161852 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161788 & 65535)
 movk x9,#(161788 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161792 & 65535)
 movk x9,#(161792 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161796 & 65535)
 movk x9,#(161796 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161856 & 65535)
 movk x9,#(161856 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161800 & 65535)
 movk x9,#(161800 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161804 & 65535)
 movk x9,#(161804 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161808 & 65535)
 movk x9,#(161808 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161860 & 65535)
 movk x9,#(161860 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161812 & 65535)
 movk x9,#(161812 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161864 & 65535)
 movk x9,#(161864 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161868 & 65535)
 movk x9,#(161868 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161828 & 65535)
 movk x9,#(161828 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161840 & 65535)
 movk x9,#(161840 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161832 & 65535)
 movk x9,#(161832 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161816 & 65535)
 movk x9,#(161816 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161820 & 65535)
 movk x9,#(161820 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161824 & 65535)
 movk x9,#(161824 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161876 & 65535)
 movk x9,#(161876 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161836 & 65535)
 movk x9,#(161836 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161872 & 65535)
 movk x9,#(161872 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161880 & 65535)
 movk x9,#(161880 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161884 & 65535)
 movk x9,#(161884 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161888 & 65535)
 movk x9,#(161888 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161892 & 65535)
 movk x9,#(161892 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161896 & 65535)
 movk x9,#(161896 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161900 & 65535)
 movk x9,#(161900 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161904 & 65535)
 movk x9,#(161904 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161908 & 65535)
 movk x9,#(161908 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161912 & 65535)
 movk x9,#(161912 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161916 & 65535)
 movk x9,#(161916 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161920 & 65535)
 movk x9,#(161920 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161924 & 65535)
 movk x9,#(161924 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161928 & 65535)
 movk x9,#(161928 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161936 & 65535)
 movk x9,#(161936 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161960 & 65535)
 movk x9,#(161960 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161964 & 65535)
 movk x9,#(161964 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161944 & 65535)
 movk x9,#(161944 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161952 & 65535)
 movk x9,#(161952 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161932 & 65535)
 movk x9,#(161932 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161940 & 65535)
 movk x9,#(161940 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161968 & 65535)
 movk x9,#(161968 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161972 & 65535)
 movk x9,#(161972 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161948 & 65535)
 movk x9,#(161948 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161956 & 65535)
 movk x9,#(161956 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161976 & 65535)
 movk x9,#(161976 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161980 & 65535)
 movk x9,#(161980 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161984 & 65535)
 movk x9,#(161984 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162000 & 65535)
 movk x9,#(162000 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162080 & 65535)
 movk x9,#(162080 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162084 & 65535)
 movk x9,#(162084 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162088 & 65535)
 movk x9,#(162088 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162092 & 65535)
 movk x9,#(162092 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162096 & 65535)
 movk x9,#(162096 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162100 & 65535)
 movk x9,#(162100 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162108 & 65535)
 movk x9,#(162108 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162124 & 65535)
 movk x9,#(162124 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162120 & 65535)
 movk x9,#(162120 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162104 & 65535)
 movk x9,#(162104 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162112 & 65535)
 movk x9,#(162112 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162116 & 65535)
 movk x9,#(162116 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162144 & 65535)
 movk x9,#(162144 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162148 & 65535)
 movk x9,#(162148 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162016 & 65535)
 movk x9,#(162016 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161988 & 65535)
 movk x9,#(161988 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161992 & 65535)
 movk x9,#(161992 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(161996 & 65535)
 movk x9,#(161996 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162008 & 65535)
 movk x9,#(162008 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162012 & 65535)
 movk x9,#(162012 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162020 & 65535)
 movk x9,#(162020 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162024 & 65535)
 movk x9,#(162024 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162028 & 65535)
 movk x9,#(162028 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162032 & 65535)
 movk x9,#(162032 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162004 & 65535)
 movk x9,#(162004 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162036 & 65535)
 movk x9,#(162036 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162040 & 65535)
 movk x9,#(162040 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162044 & 65535)
 movk x9,#(162044 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162048 & 65535)
 movk x9,#(162048 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162052 & 65535)
 movk x9,#(162052 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162056 & 65535)
 movk x9,#(162056 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162060 & 65535)
 movk x9,#(162060 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162064 & 65535)
 movk x9,#(162064 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162072 & 65535)
 movk x9,#(162072 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162076 & 65535)
 movk x9,#(162076 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162068 & 65535)
 movk x9,#(162068 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162128 & 65535)
 movk x9,#(162128 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162132 & 65535)
 movk x9,#(162132 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162136 & 65535)
 movk x9,#(162136 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162140 & 65535)
 movk x9,#(162140 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162152 & 65535)
 movk x9,#(162152 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(162156 & 65535)
 movk x9,#(162156 >> 16),lsl#16
 str wzr,[x23,x9]
 mov x9,#0
.Lcfu_schedule_zero:
 str wzr,[x23,x9]
 add x9,x9,#4
 cmp x9,#164
 b.lo .Lcfu_schedule_zero
 movz x9,#(164 & 65535)
 movk x9,#(164 >> 16),lsl#16
 str wzr,[x23,x9]
 movz w10,#20
 movz x9,#(168 & 65535)
 movk x9,#(168 >> 16),lsl#16
 str w10,[x23,x9]
 movz x9,#(172 & 65535)
 movk x9,#(172 >> 16),lsl#16
 str wzr,[x23,x9]
 movz x9,#(176 & 65535)
 movk x9,#(176 >> 16),lsl#16
 str wzr,[x23,x9]
 movz w10,#1
 movz x9,#(180 & 65535)
 movk x9,#(180 >> 16),lsl#16
 str w10,[x23,x9]
 movz x10,#0
 movk x10,#16368,lsl#48
 movz x9,#(184 & 65535)
 movk x9,#(184 >> 16),lsl#16
 str x10,[x23,x9]
 movz x10,#0
 movk x10,#16368,lsl#48
 movz x9,#(192 & 65535)
 movk x9,#(192 >> 16),lsl#16
 str x10,[x23,x9]
 movz x9,#(330136 & 65535)
 movk x9,#(330136 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330168 & 65535)
 movk x9,#(330168 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330172 & 65535)
 movk x9,#(330172 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330248 & 65535)
 movk x9,#(330248 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330176 & 65535)
 movk x9,#(330176 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330252 & 65535)
 movk x9,#(330252 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330180 & 65535)
 movk x9,#(330180 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330256 & 65535)
 movk x9,#(330256 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330184 & 65535)
 movk x9,#(330184 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330192 & 65535)
 movk x9,#(330192 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330188 & 65535)
 movk x9,#(330188 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330196 & 65535)
 movk x9,#(330196 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330204 & 65535)
 movk x9,#(330204 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330200 & 65535)
 movk x9,#(330200 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330208 & 65535)
 movk x9,#(330208 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330260 & 65535)
 movk x9,#(330260 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330264 & 65535)
 movk x9,#(330264 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330268 & 65535)
 movk x9,#(330268 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330272 & 65535)
 movk x9,#(330272 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330212 & 65535)
 movk x9,#(330212 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330216 & 65535)
 movk x9,#(330216 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330244 & 65535)
 movk x9,#(330244 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330276 & 65535)
 movk x9,#(330276 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330280 & 65535)
 movk x9,#(330280 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330220 & 65535)
 movk x9,#(330220 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330228 & 65535)
 movk x9,#(330228 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330224 & 65535)
 movk x9,#(330224 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330304 & 65535)
 movk x9,#(330304 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330232 & 65535)
 movk x9,#(330232 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330236 & 65535)
 movk x9,#(330236 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330240 & 65535)
 movk x9,#(330240 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330284 & 65535)
 movk x9,#(330284 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330288 & 65535)
 movk x9,#(330288 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330316 & 65535)
 movk x9,#(330316 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330292 & 65535)
 movk x9,#(330292 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330296 & 65535)
 movk x9,#(330296 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330300 & 65535)
 movk x9,#(330300 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330308 & 65535)
 movk x9,#(330308 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330312 & 65535)
 movk x9,#(330312 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330320 & 65535)
 movk x9,#(330320 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330324 & 65535)
 movk x9,#(330324 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330328 & 65535)
 movk x9,#(330328 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330332 & 65535)
 movk x9,#(330332 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330336 & 65535)
 movk x9,#(330336 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330340 & 65535)
 movk x9,#(330340 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330344 & 65535)
 movk x9,#(330344 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330348 & 65535)
 movk x9,#(330348 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330352 & 65535)
 movk x9,#(330352 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330356 & 65535)
 movk x9,#(330356 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330360 & 65535)
 movk x9,#(330360 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330364 & 65535)
 movk x9,#(330364 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330368 & 65535)
 movk x9,#(330368 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330376 & 65535)
 movk x9,#(330376 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330384 & 65535)
 movk x9,#(330384 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330392 & 65535)
 movk x9,#(330392 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330372 & 65535)
 movk x9,#(330372 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330380 & 65535)
 movk x9,#(330380 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330388 & 65535)
 movk x9,#(330388 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330396 & 65535)
 movk x9,#(330396 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330400 & 65535)
 movk x9,#(330400 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330404 & 65535)
 movk x9,#(330404 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330416 & 65535)
 movk x9,#(330416 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330408 & 65535)
 movk x9,#(330408 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330412 & 65535)
 movk x9,#(330412 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330420 & 65535)
 movk x9,#(330420 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330492 & 65535)
 movk x9,#(330492 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330496 & 65535)
 movk x9,#(330496 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330500 & 65535)
 movk x9,#(330500 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330504 & 65535)
 movk x9,#(330504 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330512 & 65535)
 movk x9,#(330512 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330508 & 65535)
 movk x9,#(330508 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330516 & 65535)
 movk x9,#(330516 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330520 & 65535)
 movk x9,#(330520 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330524 & 65535)
 movk x9,#(330524 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330476 & 65535)
 movk x9,#(330476 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330480 & 65535)
 movk x9,#(330480 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330484 & 65535)
 movk x9,#(330484 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330488 & 65535)
 movk x9,#(330488 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330528 & 65535)
 movk x9,#(330528 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330532 & 65535)
 movk x9,#(330532 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330536 & 65535)
 movk x9,#(330536 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330424 & 65535)
 movk x9,#(330424 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330428 & 65535)
 movk x9,#(330428 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330432 & 65535)
 movk x9,#(330432 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330436 & 65535)
 movk x9,#(330436 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330440 & 65535)
 movk x9,#(330440 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330452 & 65535)
 movk x9,#(330452 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330444 & 65535)
 movk x9,#(330444 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330448 & 65535)
 movk x9,#(330448 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330456 & 65535)
 movk x9,#(330456 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330460 & 65535)
 movk x9,#(330460 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330472 & 65535)
 movk x9,#(330472 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330468 & 65535)
 movk x9,#(330468 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330540 & 65535)
 movk x9,#(330540 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330544 & 65535)
 movk x9,#(330544 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330464 & 65535)
 movk x9,#(330464 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330548 & 65535)
 movk x9,#(330548 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330552 & 65535)
 movk x9,#(330552 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330556 & 65535)
 movk x9,#(330556 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330560 & 65535)
 movk x9,#(330560 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330564 & 65535)
 movk x9,#(330564 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330568 & 65535)
 movk x9,#(330568 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330572 & 65535)
 movk x9,#(330572 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330576 & 65535)
 movk x9,#(330576 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330580 & 65535)
 movk x9,#(330580 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330592 & 65535)
 movk x9,#(330592 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330596 & 65535)
 movk x9,#(330596 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330600 & 65535)
 movk x9,#(330600 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330584 & 65535)
 movk x9,#(330584 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330588 & 65535)
 movk x9,#(330588 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330604 & 65535)
 movk x9,#(330604 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330608 & 65535)
 movk x9,#(330608 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#512
 movk x9,#5,lsl#16
 add x9,x24,x9
 mov x10,#241
.Lxfu_NXFUTS_zero:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lxfu_NXFUTS_zero
 movz x9,#1480
 movk x9,#5,lsl#16
 add x9,x24,x9
 mov x10,#241
.Lxfu_NRAZTS_zero:
 str wzr,[x9],#4
 subs x10,x10,#1
 b.ne .Lxfu_NRAZTS_zero
 movz w10,#20
 movz x9,#(329156 & 65535)
 movk x9,#(329156 >> 16),lsl#16
 str w10,[x24,x9]
 movz w10,#20
 movz x9,#(330124 & 65535)
 movk x9,#(330124 >> 16),lsl#16
 str w10,[x24,x9]
 movz w10,#1
 movz x9,#(330128 & 65535)
 movk x9,#(330128 >> 16),lsl#16
 str w10,[x24,x9]
 movz w10,#1
 movz x9,#(328164 & 65535)
 movk x9,#(328164 >> 16),lsl#16
 str w10,[x24,x9]
 movz w10,#600
 movz x9,#(328160 & 65535)
 movk x9,#(328160 >> 16),lsl#16
 str w10,[x24,x9]
 movz w10,#3600
 movz x9,#(328168 & 65535)
 movk x9,#(328168 >> 16),lsl#16
 str w10,[x24,x9]
 movz w10,#900
 movz x9,#(328172 & 65535)
 movk x9,#(328172 >> 16),lsl#16
 str w10,[x24,x9]
 movz w10,#3600
 movz x9,#(328176 & 65535)
 movk x9,#(328176 >> 16),lsl#16
 str w10,[x24,x9]
 movz w10,#900
 movz x9,#(328180 & 65535)
 movk x9,#(328180 >> 16),lsl#16
 str w10,[x24,x9]
 movz x9,#(328188 & 65535)
 movk x9,#(328188 >> 16),lsl#16
 str wzr,[x24,x9]
 movz x9,#(330132 & 65535)
 movk x9,#(330132 >> 16),lsl#16
 str wzr,[x24,x9]
 add x9,x25,#200
 mov x10,#85
.Lmcuf_coeff_zero:
 str xzr,[x9],#8
 subs x10,x10,#1
 b.ne .Lmcuf_coeff_zero
 adr x9,.Lmax_filter
 ldr d1,[x9]
 fmov d2,#2.0
 add x9,x25,#200
 mov x10,#5
.Lmcuf_a0:
 md2asm_gpu_full_scalar md2asm_gpu_soil_water_cell_host,2,d0,d2,d1 // fmul d0,d2,d1
 str d0,[x9],#72
 subs x10,x10,#1
 b.ne .Lmcuf_a0
 adr x9,.Lfilter_period
 ldr x10,[x9]
 add x9,x25,#880
 mov x11,#5
.Lmcuf_period:
 str x10,[x9],#8
 subs x11,x11,#1
 b.ne .Lmcuf_period
 movz w10,#2
 movz x9,#(920 & 65535)
 movk x9,#(920 >> 16),lsl#16
 str w10,[x25,x9]
 movz x9,#(924 & 65535)
 movk x9,#(924 >> 16),lsl#16
 str wzr,[x25,x9]
 movz x9,#(928 & 65535)
 movk x9,#(928 >> 16),lsl#16
 str wzr,[x25,x9]
 movz x9,#(932 & 65535)
 movk x9,#(932 >> 16),lsl#16
 str wzr,[x25,x9]
 movz x9,#(162160 & 65535)
 movk x9,#(162160 >> 16),lsl#16
 add x12,x23,x9
 mov x13,x26
 bl .Lflux_descriptor
 movz x9,#(330616 & 65535)
 movk x9,#(330616 >> 16),lsl#16
 add x12,x24,x9
 ldr x13,[sp,#208]
 bl .Lflux_descriptor
 mov w0,#0
 b .Lflux_return
.Lflux_alloc_bad:
 cbz x26,.Lflux_alloc_end
 mov x0,x26
 str x18,[sp,#96]
 bl free
 ldr x18,[sp,#96]
.Lflux_alloc_end:
 mov w0,#1
.Lflux_return:
 str w28,[x27]
 ldr x18,[sp,#96]
 ldp x19,x20,[sp]
 ldp x21,x22,[sp,#16]
 ldp x23,x24,[sp,#32]
 ldp x25,x26,[sp,#48]
 ldp x27,x28,[sp,#64]
 ldp x29,x30,[sp,#80]
 add sp,sp,#1856
 add sp,sp,#1,lsl#12
 ret
.size md2asm_initialize_selected_flux_configuration,.-md2asm_initialize_selected_flux_configuration
.Lflux_descriptor:
 adr x9,.Lzero_extent_descriptor
 mov x10,#8
 str x13,[x12]
.Lflux_descriptor_copy:
 ldr x11,[x9,x10]
 str x11,[x12,x10]
 add x10,x10,#8
 cmp x10,#112
 b.lo .Lflux_descriptor_copy
 ret
.p2align 2
.global md2asm_release_selected_flux_configuration
.type md2asm_release_selected_flux_configuration,%function
md2asm_release_selected_flux_configuration:
 sub sp,sp,#80
 stp x19,x20,[sp]
 stp x21,x22,[sp,#16]
 stp x23,x30,[sp,#32]
 str x18,[sp,#48]
 mov x19,x0
 bl __errno_location
 ldr x18,[sp,#48]
 mov x20,x0
 ldr w21,[x20]
 mov w0,#2
 cbz x19,.Lrelease_return
 tst x19,#7
 b.ne .Lrelease_return
 ldr x22,[x19]
 ldr x23,[x19,#16]
 cbz x22,.Lrelease_return
 cbz x23,.Lrelease_return
 movz x9,#(162160 & 65535)
 movk x9,#(162160 >> 16),lsl#16
 add x22,x22,x9
 ldr x0,[x22]
 cbz x0,.Lrelease_second
 bl free
 ldr x18,[sp,#48]
 str xzr,[x22]
.Lrelease_second:
 movz x9,#(330616 & 65535)
 movk x9,#(330616 >> 16),lsl#16
 add x23,x23,x9
 ldr x0,[x23]
 cbz x0,.Lrelease_done
 bl free
 ldr x18,[sp,#48]
 str xzr,[x23]
.Lrelease_done:
 mov w0,#0
.Lrelease_return:
 str w21,[x20]
 ldr x18,[sp,#48]
 ldp x19,x20,[sp]
 ldp x21,x22,[sp,#16]
 ldp x23,x30,[sp,#32]
 add sp,sp,#80
 ret
.size md2asm_release_selected_flux_configuration,.-md2asm_release_selected_flux_configuration
.section .rodata
.LNAMCFU: .ascii "NAMCFU"
.LNAMXFU: .ascii "NAMXFU"
.LNAMMCUF: .ascii "NAMMCUF"
.p2align 3
.Lmax_filter: .double 99999.0
.Lfilter_period: .double 10800.0
.Lzero_extent_descriptor:
 .quad 0,-25,8
 .word 0
 .byte 3,3
 .hword 0
 .quad 8,1,1,24,24,1,0,0,1,86
.section .note.GNU-stack,"",%progbits

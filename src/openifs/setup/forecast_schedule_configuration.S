/* Contract: skills/md2asm/references/openifs/setup/forecast_schedule_configuration.md.
 * init(text,bytes,output60,capacity,upstream2i32)->w0 status. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_forecast_schedule_switches
.type md2asm_initialize_forecast_schedule_switches,%function
md2asm_initialize_forecast_schedule_switches:
 cbz x0,.Lschedule_bad
 cbz x1,.Lschedule_bad
 cbz x2,.Lschedule_bad
 cbz x4,.Lschedule_bad
 cmp x1,#64,lsl#12
 b.hi .Lschedule_bad
 cmp x3,#60
 b.lo .Lschedule_bad
 tst x2,#3
 b.ne .Lschedule_bad
 tst x4,#3
 b.ne .Lschedule_bad
 adds x9,x0,x1
 b.cs .Lschedule_bad
 adds x10,x2,#60
 b.cs .Lschedule_bad
 adds x11,x4,#8
 b.cs .Lschedule_bad
 cmp x2,x9
 b.hs .Lschedule_upstream_overlap
 cmp x0,x10
 b.lo .Lschedule_bad
.Lschedule_upstream_overlap:
 cmp x2,x11
 b.hs .Lschedule_values
 cmp x4,x10
 b.lo .Lschedule_bad
.Lschedule_values:
 ldp w9,w10,[x4]
 cmp w9,#2
 b.hi .Lschedule_bad
 cmp w10,#1
 b.hi .Lschedule_bad
 sub sp,sp,#64
 stp x29,x30,[sp]
 stp x18,x19,[sp,#16]
 stp x20,x21,[sp,#32]
 stp x22,x23,[sp,#48]
 mov x29,sp
 mov x19,x2
 mov x20,x4
 adr x2,.LNAMCT1
 mov x3,#6
 bl md2asm_require_empty_physics_group
 cbnz w0,.Lschedule_return
 adr x9,.Lschedule_defaults
 mov x10,x19
 mov x11,#15
.Lschedule_copy:
 ldr w12,[x9],#4
 str w12,[x10],#4
 subs x11,x11,#1
 b.ne .Lschedule_copy
 ldp w9,w10,[x20]
 cmp w9,#0
 cset w9,eq
 and w9,w9,w10
 str w9,[x19,#52]
 mov w0,#0
.Lschedule_return:
 ldp x18,x19,[sp,#16]
 ldp x20,x21,[sp,#32]
 ldp x22,x23,[sp,#48]
 ldp x29,x30,[sp]
 add sp,sp,#64
 ret
.Lschedule_bad:
 mov w0,#2
 ret
.size md2asm_initialize_forecast_schedule_switches,.-md2asm_initialize_forecast_schedule_switches
.section .rodata
.LNAMCT1:.ascii "NAMCT1"
.p2align 2
.Lschedule_defaults:.word 1,1,1,1,1,1,1,1,1,1,1,0,1,0,1
.section .note.GNU-stack,"",%progbits

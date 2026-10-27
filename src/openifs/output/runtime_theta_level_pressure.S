/* The interface, bounds, units and component limits are in
 * skills/md2asm/references/openifs/output/fullpos_vertical_physics.md.
 */
/* Source PPLTETA pressure on an isentropic surface, with explicit policy. */
.arch armv8.2-a
.symver md2asm_theta_public_log,log@GLIBC_2.29
.text
.p2align 4
.global md2asm_runtime_theta_level_pressure
.type md2asm_runtime_theta_level_pressure,%function
md2asm_runtime_theta_level_pressure:
 mov x17,sp
 sub sp,sp,#128
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x26,[sp,#64]
 stp x27,x28,[sp,#80]
 str x18,[sp,#96]
 cbz x0,.Lbad
 cbz x1,.Lbad
 cbz x2,.Lbad
 cbz x3,.Lbad
 cbz x4,.Lbad
 cbz x5,.Lbad
 cbz x6,.Lbad
 cbz x7,.Lbad
 ldr x27,[x17]
 ldr x9,[x17,#8]
 cbz x27,.Lbad
 cbz x9,.Lbad
 ldr w9,[x9]
 cbnz w9,.Lbad
 mrs x9,fpcr
 cbnz x9,.Lbad
 ldr w19,[x0]
 ldr w20,[x3]
 ldr w21,[x1]
 ldr w22,[x2]
 sub w9,w19,#1
 mov w10,#32768
 cmp w9,w10
 b.hi .Lbad
 sub w9,w20,#2
 cmp w9,#510
 b.hi .Lbad
 sub w9,w21,#1
 cmp w9,w19
 b.hs .Lbad
 cmp w22,w21
 b.lt .Lbad
 cmp w22,w19
 b.gt .Lbad
 sub w21,w21,#1
 mov x23,x4
 mov x24,x5
 mov x25,x6
 mov x26,x7
 mov x28,x21
.Lrow:
 mov x9,x20
 mov x10,x20
 ldr d1,[x25]
.Lsearch:
 sub x11,x9,#1
 madd x11,x11,x19,x28
 ldr d0,[x24,x11,lsl#3]
 fcmp d0,d1
 csel x10,x9,x10,lt
 subs x9,x9,#1
 b.ne .Lsearch
 cmp x10,x20
 b.eq .Lcopy_level
 cmp x10,#1
 b.eq .Lcopy_level
 sub x9,x10,#1
 madd x9,x9,x19,x28
 sub x10,x9,x19
 ldr d0,[x24,x10,lsl#3]
 ldr d1,[x24,x9,lsl#3]
 fsub d0,d0,d1
 fabs d2,d0
 adr x11,.Lsecurity
 ldr d3,[x11]
 fcmp d2,d3
 b.le .Lcopy_current
 ldr d2,[x23,x10,lsl#3]
 ldr d3,[x23,x9,lsl#3]
 fsub d2,d2,d3
 ldr d4,[x25]
 fsub d4,d4,d1
 fmul d2,d2,d4
 fdiv d2,d2,d0
 fadd d0,d2,d3
 b .Lpublish
.Lcopy_level:
 sub x9,x10,#1
 madd x9,x9,x19,x28
.Lcopy_current:
 ldr d0,[x23,x9,lsl#3]
.Lpublish:
 str d0,[x26,x28,lsl#3]
 bl md2asm_theta_public_log
 ldr x18,[sp,#96]
 str d0,[x27,x28,lsl#3]
 add x28,x28,#1
 cmp x28,x22
 b.lo .Lrow
 mov w0,#0
 b .Lreturn
.Lbad:
 mov w0,#2
.Lreturn:
 ldr x18,[sp,#96]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x26,[sp,#64]
 ldp x27,x28,[sp,#80]
 ldp x29,x30,[sp]
 add sp,sp,#128
 ret
.size md2asm_runtime_theta_level_pressure,.-md2asm_runtime_theta_level_pressure
.section .rodata
.p2align 3
.Lsecurity:.quad 0x3ddb7cdfd9d7bdbb
.section .note.GNU-stack,"",%progbits

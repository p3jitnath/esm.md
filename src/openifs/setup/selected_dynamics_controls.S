/* Complete selected owned TDYNA setup, accepting only live empty NAMDYNA.
 * x0 text,x1 bytes,x2 record[456],x3 capacity,x4 controls[32].
 * Controls: NDLON,NDGLG,NSMAX,NMSMAX,LVERTFE,NDLNPR,LNONHYD,NCONF.
 * Return0/2 before mutation. Record and controls align8 and do not overlap.
 * Contract: skills/md2asm/references/openifs/setup/selected_dynamics_controls.md. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_initialize_selected_dynamics_controls
.type md2asm_initialize_selected_dynamics_controls,%function
md2asm_initialize_selected_dynamics_controls:
 cbz x0,.Ldynamics_setup_bad_leaf
 cbz x2,.Ldynamics_setup_bad_leaf
 cbz x4,.Ldynamics_setup_bad_leaf
 cbz x1,.Ldynamics_setup_bad_leaf
 cmp x1,#64,lsl#12
 b.hi .Ldynamics_setup_bad_leaf
 cmp x3,#456
 b.lo .Ldynamics_setup_bad_leaf
 orr x9,x2,x4
 tst x9,#7
 b.ne .Ldynamics_setup_bad_leaf
 adds x9,x0,x1
 b.cs .Ldynamics_setup_bad_leaf
 adds x10,x2,#456
 b.cs .Ldynamics_setup_bad_leaf
 adds x11,x4,#32
 b.cs .Ldynamics_setup_bad_leaf
 cmp x10,x0
 b.ls .Ldynamics_record_text_ok
 cmp x2,x9
 b.lo .Ldynamics_setup_bad_leaf
.Ldynamics_record_text_ok:
 cmp x10,x4
 b.ls .Ldynamics_record_control_ok
 cmp x2,x11
 b.lo .Ldynamics_setup_bad_leaf
.Ldynamics_record_control_ok:
 mrs x9,fpcr
 cbnz x9,.Ldynamics_setup_bad_leaf
 adr x9,.Ldynamics_selected_controls
 mov x10,x4
 mov w11,#8
.Ldynamics_control_compare:
 ldr w12,[x9],#4
 ldr w13,[x10],#4
 cmp w12,w13
 b.ne .Ldynamics_setup_bad_leaf
 subs w11,w11,#1
 b.ne .Ldynamics_control_compare
 stp x29,x30,[sp,#-32]!
 stp x19,x20,[sp,#16]
 mov x29,sp
 mov x19,x2
 bl md2asm_require_empty_dynamics_namelist
 cbnz w0,.Ldynamics_setup_return
 mov x0,x19
 bl md2asm_default_selected_dynamics_controls
.Ldynamics_setup_return:
 ldp x19,x20,[sp,#16]
 ldp x29,x30,[sp],#32
 ret
.Ldynamics_setup_bad_leaf:
 mov w0,#2
 ret
.size md2asm_initialize_selected_dynamics_controls,.-md2asm_initialize_selected_dynamics_controls
.p2align 2
.Ldynamics_selected_controls: .word 64,32,21,21,1,0,0,1
.section .note.GNU-stack,"",%progbits

/* Original SUDIM_TRAJ entry with an empty NAMDIM_TRAJ group.
 * Contract: skills/md2asm/references/openifs/setup/trajectory_dimension_setup.md.
 * x0 read-only TDIM352.
 * Live scalar setup words are explicit compatibility inputs.
 * No original callable, constructor, type descriptor or vtable is used.
 */
.arch armv8.2-a
.text
.p2align 4
.global sudim_traj_
.type sudim_traj_,%function
sudim_traj_:
 sub sp,sp,#208
 stp x29,x30,[sp]
 stp x19,x20,[sp,#16]
 stp x21,x22,[sp,#32]
 stp x23,x24,[sp,#48]
 stp x25,x18,[sp,#64]
 mov x29,sp
 mov x19,x0
 mov x20,#0
 mov w21,#-1
 mrs x9,fpcr
 str x9,[sp,#80]
 mrs x9,fpsr
 str x9,[sp,#88]
 cbz x19,.Ltrajectory_native_fail
 tst x19,#3
 b.ne .Ltrajectory_native_fail
 bl __errno_location
 mov x24,x0
 movz x0,#1
 movk x0,#4,lsl#16
 bl malloc
 cbz x0,.Ltrajectory_native_fail
 mov x20,x0
 adr x0,.Ltrajectory_native_file
 mov w1,#0
 mov w2,#0
 bl open
 tbnz w0,#31,.Ltrajectory_native_fail
 mov w21,w0
 mov x22,#0
.Ltrajectory_native_read:
 mov w0,w21
 add x1,x20,x22
 movz x2,#1
 movk x2,#4,lsl#16
 sub x2,x2,x22
 bl read
 tbnz x0,#63,.Ltrajectory_native_read_error
 cbz x0,.Ltrajectory_native_read_done
 add x22,x22,x0
 movz x9,#1
 movk x9,#4,lsl#16
 cmp x22,x9
 b.hs .Ltrajectory_native_fail
 b .Ltrajectory_native_read
.Ltrajectory_native_read_error:
 ldr w9,[x24]
 cmp w9,#4
 b.eq .Ltrajectory_native_read
 b .Ltrajectory_native_fail
.Ltrajectory_native_read_done:
 mov w0,w21
 bl close
 cbnz w0,.Ltrajectory_native_fail
 mov w21,#-1
 mov x0,x20
 mov x1,x22
 bl md2asm_empty_trajectory_dimension_group
 cbnz w0,.Ltrajectory_native_fail
 mov x0,x20
 bl free
 mov x20,#0
 /* Input services do not add flags to the source setup calculation. */
 /* Genuine successful source namelist reading returns errno zero. */
 str wzr,[x24]
 ldr x9,[sp,#80]
 msr fpcr,x9
 ldr x9,[sp,#88]
 msr fpsr,x9
 ldr x18,[sp,#72]
 adrp x9,:got:__yomtraj_MOD_nsmax_traj
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_traj]
 str x9,[sp,#104]
 adrp x9,:got:__yomtraj_MOD_nsmax_backgr00
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_backgr00]
 str x9,[sp,#112]
 adrp x9,:got:__yomtraj_MOD_nsmax_backgr01
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_backgr01]
 str x9,[sp,#120]
 adrp x9,:got:__yomtraj_MOD_nsmax_backgr02
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_backgr02]
 str x9,[sp,#128]
 adrp x9,:got:__yomtraj_MOD_nsmax_backgr03
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_backgr03]
 str x9,[sp,#136]
 adrp x9,:got:__yomtraj_MOD_nsmax_backgr04
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_backgr04]
 str x9,[sp,#144]
 adrp x9,:got:__yomtraj_MOD_nsmax_backgr05
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_backgr05]
 str x9,[sp,#152]
 adrp x9,:got:__yomtraj_MOD_nsmax_backgr06
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_backgr06]
 str x9,[sp,#160]
 adrp x9,:got:__yomtraj_MOD_nsmax_backgr07
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_backgr07]
 str x9,[sp,#168]
 adrp x9,:got:__yomtraj_MOD_nsmax_backgr08
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_backgr08]
 str x9,[sp,#176]
 adrp x9,:got:__yomtraj_MOD_nsmax_backgr09
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_backgr09]
 str x9,[sp,#184]
 adrp x9,:got:__yomtraj_MOD_nsmax_backgr10
 ldr x9,[x9,:got_lo12:__yomtraj_MOD_nsmax_backgr10]
 str x9,[sp,#192]
 ldr w0,[x19,#300]
 add x1,sp,#104
 bl md2asm_initialize_trajectory_dimensions
 cbnz w0,.Ltrajectory_native_fail
 adrp x9,.Ltrajectory_native_count
 add x9,x9,:lo12:.Ltrajectory_native_count
 ldr x10,[x9]
 add x10,x10,#1
 str x10,[x9]
 ldp x19,x20,[sp,#16]
 ldp x21,x22,[sp,#32]
 ldp x23,x24,[sp,#48]
 ldp x25,x18,[sp,#64]
 ldp x29,x30,[sp]
 add sp,sp,#208
 ret
.Ltrajectory_native_fail:
 tbnz w21,#31,.Ltrajectory_native_free
 mov w0,w21
 bl close
.Ltrajectory_native_free:
 cbz x20,.Ltrajectory_native_exit
 mov x0,x20
 bl free
.Ltrajectory_native_exit:
 mov w0,#124
 bl _exit
 brk #0
.size sudim_traj_,.-sudim_traj_
.p2align 4
.global md2asm_trajectory_dimension_native_count_get
.type md2asm_trajectory_dimension_native_count_get,%function
md2asm_trajectory_dimension_native_count_get:
 adrp x9,.Ltrajectory_native_count
 ldr x0,[x9,:lo12:.Ltrajectory_native_count]
 ret
.size md2asm_trajectory_dimension_native_count_get,.-md2asm_trajectory_dimension_native_count_get
.Ltrajectory_native_file: .asciz "fort.4"
.bss
.p2align 3
.Ltrajectory_native_count: .zero 8
.section .note.GNU-stack,"",%progbits

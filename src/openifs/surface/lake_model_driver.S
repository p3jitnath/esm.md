/* Direct selected FLAKE_DRIVER body from OpenIFS 48.1.1.
 * Physics formulations/openifs/surface/lake_temperature_profile.md.
 * Contract skills/md2asm/references/openifs/surface/lake_temperature_profile.md.
 * Frozen numerical body and current private interfaces are preserved. */
.text
.p2align 4
.macro ARG reg,argument
 ldr \reg,[x19,#(\argument*8)]
.endm
.macro LOAD reg,argument
 ARG x9,\argument
 ldr x9,[x9]
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro POOL reg,index
 ldr x9,[x25,#(\index*8)]
 ldr \reg,[x9,x20,lsl #3]
.endm
.macro STORE reg,index
 ldr x9,[x25,#(\index*8)]
 str \reg,[x9,x20,lsl #3]
.endm
.macro CALL name
 str x18,[sp,#3008]
 bl \name
 ldr x18,[sp,#3008]
.endm
.macro PARG destination,argument
 ARG x9,\argument
 .if \destination<8
  mov x\destination,x9
 .else
  str x9,[sp,#((\destination-8)*8)]
 .endif
.endm
.macro DARG destination,index
 add x9,x24,#(\index*64)
 .if \destination<8
  mov x\destination,x9
 .else
  str x9,[sp,#((\destination-8)*8)]
 .endif
.endm
.macro SARG destination,offset
 add x9,sp,#\offset
 .if \destination<8
  mov x\destination,x9
 .else
  str x9,[sp,#((\destination-8)*8)]
 .endif
.endm
.macro CHECK argument,element,kind,exact=0
 ARG x9,\argument
 ldr x10,[x9]
 cbz x10,.Llake_driver_reject
 tst x10,#(\element-1)
 b.ne .Llake_driver_reject
 ldr x10,[x9,#16]
 cmp x10,#\element
 b.ne .Llake_driver_reject
 ldr x10,[x9,#32]
 cmp x10,#\element
 b.ne .Llake_driver_reject
 ldrb w10,[x9,#28]
 cmp w10,#1
 b.ne .Llake_driver_reject
 ldrb w10,[x9,#29]
 cmp w10,#\kind
 b.ne .Llake_driver_reject
 ldr x10,[x9,#40]
 cmp x10,#1
 b.ne .Llake_driver_reject
 ldp x10,x11,[x9,#48]
 sub x11,x11,x10
 add x11,x11,#1
 .if \exact
  cmp x11,x21
  b.ne .Llake_driver_reject
 .else
  cmp x11,x21
  b.lt .Llake_driver_reject
 .endif
 ldr x11,[x9,#8]
 add x11,x11,x10
 cbnz x11,.Llake_driver_reject
.endm
.global md2asm_flake_driver_partial_profile_r3_7358525
.type md2asm_flake_driver_partial_profile_r3_7358525,%function
md2asm_flake_driver_partial_profile_r3_7358525:
 sub sp,sp,#4096
 stp x19,x20,[sp,#224]
 stp x21,x22,[sp,#240]
 stp x23,x24,[sp,#256]
 stp x25,x26,[sp,#272]
 stp x27,x28,[sp,#288]
 stp x29,x30,[sp,#304]
 str x18,[sp,#320]
 add x19,sp,#352
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 add x11,sp,#4096
 mov x10,#8
.Llake_driver_arguments:
 ldr x9,[x11],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#30
 b.lt .Llake_driver_arguments
 mrs x9,fpcr
 cbnz x9,.Llake_driver_reject
 mov x10,#0
.Llake_driver_pointers:
 ldr x9,[x19,x10,lsl #3]
 cbz x9,.Llake_driver_reject
 tst x9,#3
 b.ne .Llake_driver_reject
 add x10,x10,#1
 cmp x10,#30
 b.lt .Llake_driver_pointers
 ARG x9,2
 ldr w21,[x9]
 cmp w21,#1
 b.lt .Llake_driver_reject
 cmp w21,#4096
 b.gt .Llake_driver_reject
 ARG x9,0
 ldr w10,[x9]
 cmp w10,#1
 b.lt .Llake_driver_reject
 sub w10,w10,#1
 str w10,[sp,#3040]
 ARG x9,1
 ldr w11,[x9]
 cmp w11,w21
 b.gt .Llake_driver_reject
 cmp w11,w10
 b.le .Llake_driver_reject
 str w11,[sp,#3044]
 CHECK 3,4,2
 CHECK 4,8,3
 CHECK 5,8,3
 CHECK 6,8,3
 CHECK 7,8,3
 CHECK 8,8,3
 CHECK 9,8,3
 CHECK 11,8,3
 CHECK 12,8,3
 CHECK 16,8,3
 CHECK 17,8,3
 CHECK 18,8,3
 CHECK 19,8,3
 CHECK 20,8,3
 CHECK 21,8,3
 CHECK 22,8,3
 CHECK 23,8,3,1
 CHECK 24,8,3,1
 CHECK 25,8,3,1
 CHECK 26,8,3,1
 CHECK 27,8,3,1
 CHECK 28,8,3,1
 CHECK 29,8,3,1
 ARG x23,15
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Llake_driver_reject
 str w9,[sp,#2944]
 cbz w9,.Llake_driver_hook_entry_done
 adr x0,.Llake_driver_hook_name
 add x1,sp,#2948
 str wzr,[x1]
 add x2,sp,#2952
 mov x3,#29
 CALL __yomhook_MOD_dr_hook_default8
.Llake_driver_hook_entry_done:
 mov x0,x21
 mov x1,#224
 CALL calloc
 cbz x0,.Llake_driver_reject
 mov x22,x0
 add x24,sp,#896
 add x25,sp,#2704
 mov x27,#0
 lsl x26,x21,#3
.Llake_driver_descriptors:
 madd x9,x27,x26,x22
 str x9,[x25,x27,lsl #3]
 lsl x10,x27,#6
 add x10,x24,x10
 str x9,[x10]
 mov x9,#-1
 str x9,[x10,#8]
 mov x9,#8
 str x9,[x10,#16]
 movz x9,#0x0301,lsl #32
 str x9,[x10,#24]
 mov x9,#8
 str x9,[x10,#32]
 mov x9,#1
 str x9,[x10,#40]
 str x9,[x10,#48]
 str x21,[x10,#56]
 add x27,x27,#1
 cmp x27,#28
 b.lt .Llake_driver_descriptors
 // Copy opaque optical bytes; no calculation is supplied by this view.
 add x9,x23,#328
 add x10,sp,#640
 mov x11,#13
.Llake_driver_water_optics:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Llake_driver_water_optics
 add x9,x23,#744
 add x10,sp,#752
 mov x11,#13
.Llake_driver_ice_optics:
 ldr x12,[x9],#8
 str x12,[x10],#8
 subs x11,x11,#1
 b.ne .Llake_driver_ice_optics
 ARG x9,13
 ldr d0,[x9]
 str d0,[sp,#608]
 mov x20,#0
.Llake_driver_prepare:
 LOAD d0,11
 STORE d0,0
 LOAD d0,16
 STORE d0,3
 LOAD d0,17
 STORE d0,5
 LOAD d0,18
 STORE d0,4
 LOAD d0,19
 STORE d0,6
 LOAD d0,20
 STORE d0,9
 LOAD d0,21
 STORE d0,7
 LOAD d0,22
 STORE d0,8
 // Whole previous-state views are defined; fluxes use only active rows.
 ldr w9,[sp,#3040]
 cmp w20,w9
 b.lt .Llake_driver_prepare_next
 ldr w9,[sp,#3044]
 cmp w20,w9
 b.ge .Llake_driver_prepare_next
 ARG x9,3
 ldr x9,[x9]
 ldr w9,[x9,x20,lsl #2]
 cmp w9,#1
 b.hi .Llake_driver_reject
 cbz w9,.Llake_driver_prepare_next
 LOAD d0,4
 STORE d0,13
 LOAD d0,8
 LOAD d1,9
 fmul d0,d0,d0
 fmul d1,d1,d1
 fadd d0,d0,d1
 fsqrt d0,d0
 ldr d1,[x23,#264]
 fdiv d0,d0,d1
 fsqrt d0,d0
 STORE d0,12
 adr x9,.Llake_driver_coriolis
 ldr d0,[x9]
 STORE d0,1
 LOAD d0,5
 LOAD d1,6
 fadd d0,d0,d1
 LOAD d2,7
 ldr d1,[x23,#320]
 fmul d1,d1,d2
 fadd d0,d0,d1
 POOL d1,7
 ldr d3,[x23,#192]
 fcmp d1,d3
 b.lt .Llake_driver_open_water
 ldr d1,[x23,#280]
 fmul d1,d1,d2
 fadd d1,d0,d1
 STORE d1,11
 fmov d0,xzr
 STORE d0,10
 POOL d0,3
 STORE d0,2
 b .Llake_driver_prepare_next
.Llake_driver_open_water:
 STORE d0,10
 fmov d0,xzr
 STORE d0,11
 POOL d0,4
 STORE d0,2
.Llake_driver_prepare_next:
 add x20,x20,#1
 cmp x20,x21
 b.lt .Llake_driver_prepare
 PARG 0,0
 PARG 1,1
 PARG 2,3
 DARG 3,0
 SARG 4,640
 SARG 5,752
 PARG 6,15
 DARG 7,13
 DARG 8,7
 DARG 9,8
 DARG 10,14
 DARG 11,15
 DARG 12,16
 DARG 13,17
 DARG 14,18
 DARG 15,19
 CALL md2asm_lake_radiation
 ldr d0,[sp,#696]
 str d0,[sp,#624]
 PARG 0,0
 PARG 1,1
 PARG 2,2
 DARG 3,0
 DARG 4,1
 PARG 5,3
 SARG 6,624
 PARG 7,15
 SARG 8,608
 DARG 9,2
 DARG 10,3
 DARG 11,4
 DARG 12,5
 DARG 13,6
 DARG 14,7
 DARG 15,8
 DARG 16,9
 DARG 17,10
 DARG 18,11
 DARG 19,12
 DARG 20,14
 DARG 21,15
 DARG 22,16
 DARG 23,17
 DARG 24,18
 DARG 25,19
 DARG 26,20
 DARG 27,21
 DARG 28,22
 DARG 29,23
 DARG 30,24
 DARG 31,25
 DARG 32,26
 DARG 33,27
 CALL md2asm_flakeene_profile_r3
 ldr w20,[sp,#3040]
.Llake_driver_returns:
 POOL d0,20
 ARG x9,23
 ldr x9,[x9]
 str d0,[x9,x20,lsl #3]
 POOL d0,22
 ARG x9,24
 ldr x9,[x9]
 str d0,[x9,x20,lsl #3]
 POOL d0,21
 ARG x9,25
 ldr x9,[x9]
 str d0,[x9,x20,lsl #3]
 POOL d0,23
 ARG x9,26
 ldr x9,[x9]
 str d0,[x9,x20,lsl #3]
 POOL d0,26
 ARG x9,27
 ldr x9,[x9]
 str d0,[x9,x20,lsl #3]
 POOL d0,24
 ARG x9,28
 ldr x9,[x9]
 str d0,[x9,x20,lsl #3]
 POOL d0,25
 ARG x9,29
 ldr x9,[x9]
 str d0,[x9,x20,lsl #3]
 add x20,x20,#1
 ldr w9,[sp,#3044]
 cmp w20,w9
 b.lt .Llake_driver_returns
 mov x0,x22
 CALL free
 ldr w9,[sp,#2944]
 cbz w9,.Llake_driver_hook_exit_done
 adr x0,.Llake_driver_hook_name
 add x1,sp,#2948
 mov w9,#1
 str w9,[x1]
 add x2,sp,#2952
 mov x3,#29
 CALL __yomhook_MOD_dr_hook_default8
.Llake_driver_hook_exit_done:
 ldr x18,[sp,#320]
 ldp x19,x20,[sp,#224]
 ldp x21,x22,[sp,#240]
 ldp x23,x24,[sp,#256]
 ldp x25,x26,[sp,#272]
 ldp x27,x28,[sp,#288]
 ldp x29,x30,[sp,#304]
 add sp,sp,#4096
 ret
.Llake_driver_reject:
 bl abort
 brk #0
.size md2asm_flake_driver_partial_profile_r3_7358525,.-md2asm_flake_driver_partial_profile_r3_7358525
.section .rodata
.p2align 3
.Llake_driver_coriolis: .double 1.0e-4
.Llake_driver_hook_name: .ascii "FLAKE_DRIVER_MOD:FLAKE_DRIVER"
.section .note.GNU-stack,"",%progbits

/* Contract: skills/md2asm/references/openifs/surface/surface_private_bindings.md. */
// Direct SURFPP ABI adapter; all numerical stages belong to its accepted direct child.
// GET_SURF resolves through the owned registry metadata interface.
.text
.p2align 4
.macro ARG reg,arg
 ldr \reg,[x19,#(\arg*8)]
.endm
.macro CALL name
 str x18,[sp,#2376]
 bl \name
 ldr x18,[sp,#2376]
.endm
.macro PLACE dest
 .if \dest<8
  mov x\dest,x9
 .else
  str x9,[sp,#((\dest-8)*8)]
 .endif
.endm
.global md2asm_surface_postprocessing_adapter_7358525
.type md2asm_surface_postprocessing_adapter_7358525,%function
md2asm_surface_postprocessing_adapter_7358525:
 mov x16,sp
 sub sp,sp,#4096
 add x17,sp,#1024
 stp x19,x20,[x17]
 stp x21,x22,[x17,#16]
 stp x23,x24,[x17,#32]
 stp x25,x26,[x17,#48]
 stp x27,x28,[x17,#64]
 stp x29,x30,[x17,#80]
 str x18,[x17,#96]
 add x19,sp,#1280
 stp x0,x1,[x19]
 stp x2,x3,[x19,#16]
 stp x4,x5,[x19,#32]
 stp x6,x7,[x19,#48]
 mov x10,#8
.Lpa_arguments:
 ldr x9,[x16],#8
 str x9,[x19,x10,lsl #3]
 add x10,x10,#1
 cmp x10,#61
 b.lt .Lpa_arguments
 mrs x9,fpcr
 cbnz x9,.Lpa_reject
 adrp x9,:got:__yomhook_MOD_lhook
 ldr x9,[x9,:got_lo12:__yomhook_MOD_lhook]
 ldr w9,[x9]
 cmp w9,#1
 b.hi .Lpa_reject
 str w9,[sp,#2360]
 cbz w9,.Lpa_entry_hook_done
 adr x0,.Lpa_hook_name
 add x1,sp,#2364
 str wzr,[x1]
 add x2,sp,#2368
 mov x3,#6
 CALL __yomhook_MOD_dr_hook_default8
.Lpa_entry_hook_done:
 ARG x0,0
 CALL __yos_surf_MOD_get_surf
 mov x20,x0
 cbz x20,.Lpa_reject
 // PFRTI dimension 1 >= KLON
 ARG x9,8
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PFRTI dimension 2 >= KTILES
 ARG x9,8
 ldr x10,[x9,#80]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PAHFLTI dimension 1 >= KLON
 ARG x9,9
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PAHFLTI dimension 2 >= KTILES
 ARG x9,9
 ldr x10,[x9,#80]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PG0TI dimension 1 >= KLON
 ARG x9,10
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PG0TI dimension 2 >= KTILES
 ARG x9,10
 ldr x10,[x9,#80]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PSTRTULEV dimension 1 >= KLON
 ARG x9,11
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PSTRTVLEV dimension 1 >= KLON
 ARG x9,12
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PTSKM1M dimension 1 >= KLON
 ARG x9,13
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PUMLEV dimension 1 >= KLON
 ARG x9,14
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PVMLEV dimension 1 >= KLON
 ARG x9,15
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PQMLEV dimension 1 >= KLON
 ARG x9,16
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PGEOMLEV dimension 1 >= KLON
 ARG x9,17
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PCPTSPP dimension 1 >= KLON
 ARG x9,18
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PCPTGZLEV dimension 1 >= KLON
 ARG x9,19
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PAPHMS dimension 1 >= KLON
 ARG x9,20
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PZ0MW dimension 1 >= KLON
 ARG x9,21
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PZ0HW dimension 1 >= KLON
 ARG x9,22
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PZ0QW dimension 1 >= KLON
 ARG x9,23
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PZDL dimension 1 >= KLON
 ARG x9,24
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PQSAPP dimension 1 >= KLON
 ARG x9,25
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PBLEND dimension 1 >= KLON
 ARG x9,26
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PFBLEND dimension 1 >= KLON
 ARG x9,27
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PBUOM dimension 1 >= KLON
 ARG x9,28
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PZ0M dimension 1 >= KLON
 ARG x9,29
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PEVAPSNW dimension 1 >= KLON
 ARG x9,30
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PSSRFLTI dimension 1 >= KLON
 ARG x9,31
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PSSRFLTI dimension 2 >= KTILES
 ARG x9,31
 ldr x10,[x9,#80]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PSLRFL dimension 1 >= KLON
 ARG x9,32
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PSST dimension 1 >= KLON
 ARG x9,33
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PUCURR dimension 1 >= KLON
 ARG x9,34
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PVCURR dimension 1 >= KLON
 ARG x9,35
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PUSTOKES dimension 1 >= KLON
 ARG x9,36
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PVSTOKES dimension 1 >= KLON
 ARG x9,37
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PAHFSTI dimension 1 >= KLON
 ARG x9,38
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PAHFSTI dimension 2 >= KTILES
 ARG x9,38
 ldr x10,[x9,#80]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PEVAPTI dimension 1 >= KLON
 ARG x9,39
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PEVAPTI dimension 2 >= KTILES
 ARG x9,39
 ldr x10,[x9,#80]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PTSKE1 dimension 1 >= KLON
 ARG x9,40
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PTSKTIP1 dimension 1 >= KLON
 ARG x9,41
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PTSKTIP1 dimension 2 >= KTILES
 ARG x9,41
 ldr x10,[x9,#80]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PDIFTSLEV dimension 1 >= KLON
 ARG x9,42
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PDIFTQLEV dimension 1 >= KLON
 ARG x9,43
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PUSTRTI dimension 1 >= KLON
 ARG x9,44
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PUSTRTI dimension 2 >= KTILES
 ARG x9,44
 ldr x10,[x9,#80]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PVSTRTI dimension 1 >= KLON
 ARG x9,45
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PVSTRTI dimension 2 >= KTILES
 ARG x9,45
 ldr x10,[x9,#80]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PTSKTI dimension 1 >= KLON
 ARG x9,46
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PTSKTI dimension 2 >= KTILES
 ARG x9,46
 ldr x10,[x9,#80]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PAHFLEV dimension 1 >= KLON
 ARG x9,47
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PAHFLSB dimension 1 >= KLON
 ARG x9,48
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PFWSB dimension 1 >= KLON
 ARG x9,49
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PU10M dimension 1 >= KLON
 ARG x9,50
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PV10M dimension 1 >= KLON
 ARG x9,51
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PT2M dimension 1 >= KLON
 ARG x9,52
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PD2M dimension 1 >= KLON
 ARG x9,53
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PQ2M dimension 1 >= KLON
 ARG x9,54
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PGUST dimension 1 >= KLON
 ARG x9,55
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // P10NU dimension 1 >= KLON
 ARG x9,56
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // P10NV dimension 1 >= KLON
 ARG x9,57
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PUST dimension 1 >= KLON
 ARG x9,58
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PDHTLS dimension 1 >= KLON
 ARG x9,59
 ldr x10,[x9,#56]
 ARG x12,3
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PDHTLS dimension 2 >= KTILES
 ARG x9,59
 ldr x10,[x9,#80]
 ARG x12,4
 ldrsw x12,[x12]
 mov x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 // PDHTLS dimension 3 >= KDHVTLS+KDHFTLS
 ARG x9,59
 ldr x10,[x9,#104]
 ARG x12,5
 ldrsw x12,[x12]
 mov x11,x12
 ARG x12,6
 ldrsw x12,[x12]
 add x11,x11,x12
 cmp x10,x11
 b.lt .Lpa_reject
 ARG x9,1
 PLACE 0
 ARG x9,2
 PLACE 1
 ARG x9,3
 PLACE 2
 ARG x9,4
 PLACE 3
 ARG x9,5
 PLACE 4
 ARG x9,6
 PLACE 5
 ARG x9,7
 PLACE 6
 ARG x9,8
 PLACE 7
 ARG x9,9
 PLACE 8
 ARG x9,10
 PLACE 9
 ARG x9,11
 PLACE 10
 ARG x9,12
 PLACE 11
 ARG x9,13
 PLACE 12
 ARG x9,14
 PLACE 13
 ARG x9,15
 PLACE 14
 ARG x9,16
 PLACE 15
 ARG x9,17
 PLACE 16
 ARG x9,18
 PLACE 17
 ARG x9,19
 PLACE 18
 ARG x9,20
 PLACE 19
 ARG x9,21
 PLACE 20
 ARG x9,22
 PLACE 21
 ARG x9,23
 PLACE 22
 ARG x9,24
 PLACE 23
 ARG x9,25
 PLACE 24
 ARG x9,26
 PLACE 25
 ARG x9,27
 PLACE 26
 ARG x9,28
 PLACE 27
 ARG x9,29
 PLACE 28
 ARG x9,30
 PLACE 29
 ARG x9,31
 PLACE 30
 ARG x9,32
 PLACE 31
 ARG x9,33
 PLACE 32
 ARG x9,34
 PLACE 33
 ARG x9,35
 PLACE 34
 ARG x9,36
 PLACE 35
 ARG x9,37
 PLACE 36
 mov x9,#3816
 add x9,x20,x9
 PLACE 37
 mov x9,#3960
 add x9,x20,x9
 PLACE 38
 mov x9,#4104
 add x9,x20,x9
 PLACE 39
 ARG x9,38
 PLACE 40
 ARG x9,39
 PLACE 41
 ARG x9,40
 PLACE 42
 ARG x9,41
 PLACE 43
 ARG x9,42
 PLACE 44
 ARG x9,43
 PLACE 45
 ARG x9,44
 PLACE 46
 ARG x9,45
 PLACE 47
 ARG x9,46
 PLACE 48
 ARG x9,47
 PLACE 49
 ARG x9,48
 PLACE 50
 ARG x9,49
 PLACE 51
 ARG x9,50
 PLACE 52
 ARG x9,51
 PLACE 53
 ARG x9,52
 PLACE 54
 ARG x9,53
 PLACE 55
 ARG x9,54
 PLACE 56
 ARG x9,55
 PLACE 57
 ARG x9,56
 PLACE 58
 ARG x9,57
 PLACE 59
 ARG x9,58
 PLACE 60
 ARG x9,59
 PLACE 61
 ARG x9,60
 PLACE 62
 CALL md2asm_surfpp_ctl_7240564

 ldr w9,[sp,#2360]
 cbz w9,.Lpa_return
 adr x0,.Lpa_hook_name
 add x1,sp,#2364
 mov w9,#1
 str w9,[x1]
 add x2,sp,#2368
 mov x3,#6
 CALL __yomhook_MOD_dr_hook_default8
.Lpa_return:
 add x17,sp,#1024
 ldp x19,x20,[x17]
 ldp x21,x22,[x17,#16]
 ldp x23,x24,[x17,#32]
 ldp x25,x26,[x17,#48]
 ldp x27,x28,[x17,#64]
 ldp x29,x30,[x17,#80]
 ldr x18,[x17,#96]
 add sp,sp,#4096
 ret
.Lpa_reject:
 brk #0x532
.size md2asm_surface_postprocessing_adapter_7358525,.-md2asm_surface_postprocessing_adapter_7358525
.section .rodata
.Lpa_hook_name: .ascii "SURFPP"
.section .note.GNU-stack,"",%progbits

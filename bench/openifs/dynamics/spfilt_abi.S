/* Forward all five ordinary pointers directly into the seeded assembly ABI. */
.text
.p2align 4
.global spfilt_abi_bridge
.type spfilt_abi_bridge,%function
spfilt_abi_bridge:
    stp x29,x30,[sp,#-16]!
    mov x9,x0
    ldp x0,x1,[x9]
    ldp x2,x3,[x9,#16]
    ldr x4,[x9,#32]
    bl spfilt_assembly_
    ldp x29,x30,[sp],#16
    ret
.size spfilt_abi_bridge,.-spfilt_abi_bridge
.section .note.GNU-stack,"",%progbits

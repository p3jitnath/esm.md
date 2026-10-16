/* Ordered interval coordinate t=(x-lower)/(upper-lower).
 * Contract: skills/md2asm/references/openifs/setup/vertical_eta_coordinate_contract.md in this directory.
 * Raw d0=lower,d1=upper,d2=x; d0=result. Finite inputs, distinct endpoints.
 * Native original entry x0=&lower,x1=&upper,x2=&x; three read-only FP64 words.
 * No allocation or external call; x18, saved registers and FPCR are preserved.
 */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_vertical_interval_coordinate
.type md2asm_vertical_interval_coordinate,%function
md2asm_vertical_interval_coordinate:
 fsub d2,d2,d0
 fsub d1,d1,d0
 fdiv d0,d2,d1
 ret
.size md2asm_vertical_interval_coordinate,.-md2asm_vertical_interval_coordinate
.p2align 4
.global __suvfe_hlp_MOD_fx2t
.type __suvfe_hlp_MOD_fx2t,%function
__suvfe_hlp_MOD_fx2t:
 ldr d0,[x0]
 ldr d1,[x1]
 ldr d2,[x2]
 b md2asm_vertical_interval_coordinate
.size __suvfe_hlp_MOD_fx2t,.-__suvfe_hlp_MOD_fx2t
.section .note.GNU-stack,"",%progbits

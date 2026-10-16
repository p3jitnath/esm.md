// Raw complete selected aerosol fields; all spans are checked by the parent.
// x0 controls24, x1 table128. No external API or numerical operation.
.text
.p2align 4
.global md2asm_selected_aerosol_parameter_fields
.type md2asm_selected_aerosol_parameter_fields,%function
md2asm_selected_aerosol_parameter_fields:
    stp x19,x20,[sp,#-32]!
    str x30,[sp,#16]
    mov x19,x0
    mov x20,x1
    mov x0,x20
    adrp x1,.Laerosol_prefix_plan
    add x1,x1,:lo12:.Laerosol_prefix_plan
    adrp x2,.Laerosol_prefix_end
    add x2,x2,:lo12:.Laerosol_prefix_end
    bl .Laerosol_apply_literal_plan
    mov x0,x20
    bl md2asm_aerosol_physical_parameter_fields
    mov x0,x20
    bl md2asm_aerosol_optical_parameter_fields
    mov x0,x20
    adrp x1,.Laerosol_suffix_plan
    add x1,x1,:lo12:.Laerosol_suffix_plan
    adrp x2,.Laerosol_suffix_end
    add x2,x2,:lo12:.Laerosol_suffix_end
    bl .Laerosol_apply_literal_plan
// NINIDAY is an incoming source-unwritten scalar, not an invented default.
    ldr x9,[x20]
    ldr w10,[x9,#4]
    ldr w11,[x19,#16]
    cmp w10,w11
    b.ne .Laerosol_fields_return
    ldr w10,[x19,#20]
    cbnz w10,.Laerosol_fields_return
    mov w10,#1
    str w10,[x9,#120]
.Laerosol_fields_return:
    ldr x30,[sp,#16]
    ldp x19,x20,[sp],#32
    ret
.size md2asm_selected_aerosol_parameter_fields,.-md2asm_selected_aerosol_parameter_fields
.p2align 4
.global md2asm_aerosol_physical_parameter_fields
.type md2asm_aerosol_physical_parameter_fields,%function
md2asm_aerosol_physical_parameter_fields:
    adrp x1,.Laerosol_physical_plan
    add x1,x1,:lo12:.Laerosol_physical_plan
    adrp x2,.Laerosol_physical_end
    add x2,x2,:lo12:.Laerosol_physical_end
    b .Laerosol_apply_literal_plan
.size md2asm_aerosol_physical_parameter_fields,.-md2asm_aerosol_physical_parameter_fields
.p2align 4
.global md2asm_aerosol_optical_parameter_fields
.type md2asm_aerosol_optical_parameter_fields,%function
md2asm_aerosol_optical_parameter_fields:
    adrp x1,.Laerosol_optical_plan
    add x1,x1,:lo12:.Laerosol_optical_plan
    adrp x2,.Laerosol_optical_end
    add x2,x2,:lo12:.Laerosol_optical_end
    b .Laerosol_apply_literal_plan
.size md2asm_aerosol_optical_parameter_fields,.-md2asm_aerosol_optical_parameter_fields
// Each row is {record uint32,byte offset uint32,width uint32,padding,value64}.
.Laerosol_apply_literal_plan:
    ldp w9,w10,[x1]
    add x11,x0,x9,lsl #4
    ldr x11,[x11]
    add x11,x11,x10
    ldr w12,[x1,#8]
    ldr x13,[x1,#16]
    cmp w12,#4
    b.ne .Laerosol_store_double
    str w13,[x11]
    b .Laerosol_store_next
.Laerosol_store_double:
    str x13,[x11]
.Laerosol_store_next:
    add x1,x1,#24
    cmp x1,x2
    b.lo .Laerosol_apply_literal_plan
    ret
#include "aerosol_source_literals.inc.S"
.section .note.GNU-stack,"",%progbits

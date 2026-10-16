/* Contract: skills/md2asm/references/openifs/setup/ecmwf_physics_setup.md.
 * Source minimum-ice selection and SUGFL1 composition switches.
 * Integer-only entries preserve FPCR/FPSR, errno, x18 and saved registers. */
.arch armv8.2-a
.text
.p2align 4
.global md2asm_minimum_surface_ice_fraction_fields
.type md2asm_minimum_surface_ice_fraction_fields,%function
/* x0 one writable FP64, w1 dynamic-sea-ice, w2 one-way coupling.
 * Finite input in [-1,1], booleans0/1. int0/2; no write on rejection. */
md2asm_minimum_surface_ice_fraction_fields:
 cbz x0,.Lice_bad
 tst x0,#7
 b.ne .Lice_bad
 adds x3,x0,#8
 b.cs .Lice_bad
 cmp w1,#1
 b.hi .Lice_bad
 cmp w2,#1
 b.hi .Lice_bad
 ldr x3,[x0]
 and x4,x3,#0x7fffffffffffffff
 mov x5,#0x3ff0000000000000
 cmp x4,x5
 b.hi .Lice_bad
 cbz x4,.Lice_ready
 tbz x3,#63,.Lice_ready
 cbz w1,.Lice_default
 cbnz w2,.Lice_default
 adrp x4,.Lice_dynamic_value
 add x4,x4,:lo12:.Lice_dynamic_value
 b .Lice_store
.Lice_default:
 adrp x4,.Lice_default_value
 add x4,x4,:lo12:.Lice_default_value
.Lice_store:
 ldr x3,[x4]
 str x3,[x0]
.Lice_ready:
 mov w0,#0
 ret
.Lice_bad:
 mov w0,#2
 ret
.size md2asm_minimum_surface_ice_fraction_fields,.-md2asm_minimum_surface_ice_fraction_fields
.p2align 4
.global md2asm_initialize_selected_composition_aerosol_flags
.type md2asm_initialize_selected_composition_aerosol_flags,%function
/* x0 writable pair8,x1 capacity,x2 three live counts12,x3 capacity.
 * Exact source SUGFL1 false assignments for NCHEM=NGHG=NAERO=0. */
md2asm_initialize_selected_composition_aerosol_flags:
 cbz x0,.Lcomposition_bad
 cbz x2,.Lcomposition_bad
 tst x0,#7
 b.ne .Lcomposition_bad
 tst x2,#3
 b.ne .Lcomposition_bad
 cmp x1,#8
 b.lo .Lcomposition_bad
 cmp x3,#12
 b.lo .Lcomposition_bad
 adds x4,x0,#8
 b.cs .Lcomposition_bad
 adds x5,x2,#12
 b.cs .Lcomposition_bad
 cmp x0,x5
 b.hs .Lcomposition_disjoint
 cmp x2,x4
 b.lo .Lcomposition_bad
.Lcomposition_disjoint:
 ldp w4,w5,[x2]
 ldr w6,[x2,#8]
 orr w4,w4,w5
 orr w4,w4,w6
 cbnz w4,.Lcomposition_bad
 str xzr,[x0]
 mov w0,#0
 ret
.Lcomposition_bad:
 mov w0,#2
 ret
.size md2asm_initialize_selected_composition_aerosol_flags,.-md2asm_initialize_selected_composition_aerosol_flags
.section .rodata
.p2align 3
.Lice_dynamic_value: .double 0.005
.Lice_default_value: .double 0.02
.section .note.GNU-stack,"",%progbits
.text
.p2align 4
.global md2asm_initialize_ecmwf_physics_runtime_inputs
.type md2asm_initialize_ecmwf_physics_runtime_inputs,%function
/* x0 owned32-byte runtime record,x1 capacity. int0/2.
 * SUMPINI:169 and IFS_INIT:157 set the first two logical words false.
 * The three roughness fields use the documented fresh zero-fill policy.
 * Preserve the four declared padding bytes at12. */
md2asm_initialize_ecmwf_physics_runtime_inputs:
 cbz x0,.Lruntime_bad
 tst x0,#7
 b.ne .Lruntime_bad
 cmp x1,#32
 b.lo .Lruntime_bad
 adds x2,x0,#32
 b.cs .Lruntime_bad
 stp wzr,wzr,[x0]
 str wzr,[x0,#8]
 stp xzr,xzr,[x0,#16]
 mov w0,#0
 ret
.Lruntime_bad:
 mov w0,#2
 ret
.size md2asm_initialize_ecmwf_physics_runtime_inputs,.-md2asm_initialize_ecmwf_physics_runtime_inputs
.section .note.GNU-stack,"",%progbits

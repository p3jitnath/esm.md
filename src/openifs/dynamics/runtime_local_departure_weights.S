/* Direct runtime LASCAW for the caller-produced local-halo route.
 * Physics formulations/openifs/dynamics/departure_point_weights.md.
 * Contract skills/md2asm/references/openifs/dynamics/runtime_local_departure_weights.md.
 * The shared source preserves every qualified numerical expression. */
#define MD2ASM_LASCAW_SYMBOL md2asm_runtime_local_departure_weights
#define LASCAW_LOCAL_HALO_ONLY
#define LASCAW_CLA_CHILD md2asm_lascaw_cla
#define LASCAW_CLO_CHILD md2asm_lascaw_clo
#define LASCAW_VINTW_CHILD md2asm_lascaw_vintw
#include "lascaw.S"

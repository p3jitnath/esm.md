/* Source interfaces, bounds and source-order scope: skills/md2asm/references/openifs/radiation/live_radiation_second_interpolation.md. */
/* Source-order RO SLCSET on the actual bounded radiation-grid view. */
#define MD2ASM_RI 1
#define MD2ASM_RO 1
#define MD2ASM_INTERPOLATION_RECORD_OFFSET 4124368
#define MD2ASM_INTERPOLATION_ENTRY md2asm_initialize_runtime_radiation_output_interpolation_buffer
#define MD2ASM_INTERPOLATION_RELEASE md2asm_release_runtime_radiation_output_interpolation_buffer
#include "shared_distributed_interpolation_buffer.inc.S"

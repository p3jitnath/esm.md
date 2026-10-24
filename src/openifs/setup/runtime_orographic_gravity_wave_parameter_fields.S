/* Contract: skills/md2asm/references/openifs/setup/runtime_orographic_gravity_wave_parameters.md.
 * Raw source-order SUGWD fields.
 * x0 output96,x1 STPRE[8L],x2 VAH[8(L+1)],x3 VBH[8(L+1)],
 * x4 RHOUR8,w5 LEPHYS0/1,w6 L2..512. Caller admits all complete spans.
 * Dynamic8L-byte scratch is rounded up to16 bytes. No external call. */
#define MD2ASM_RUNTIME_OROGRAPHIC_PARAMETERS 1
#define MD2ASM_OROGRAPHIC_ONLY 1
#include "shared_cloud_gravity_wave_parameter_fields.inc.S"

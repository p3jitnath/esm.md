/* Preserve the original OpenIFS single-period solar calculation.
 * Contract: skills/md2asm/references/openifs/physics/solar_zenith_source_compatibility.md.
 * This entry retains the documented neighbouring-daylight limitation.
 * It uses the strict entry's ten-address ABI and buffer checks.
 * The added scientific-domain test is omitted from this separate entry.
 * Original output agreement and independent physical validity are separate.
 */
#define ORIGINAL_SYMBOL md2asm_cos_sza_openifs_source_compatibility
#define MD2ASM_OPENIFS_SOURCE_PERIOD 1
#include "solar_zenith_angle.S"

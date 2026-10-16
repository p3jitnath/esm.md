/* Reuse the accepted complete GPRCP equations with a private entry name.
 * Contract: skills/md2asm/references/openifs/input/initial_virtual_temperature_conversion.md.
 * Original gas constants and field pointers name live owned producer bytes. */
#define gprcp_ md2asm_initial_virtual_temperature_gas
#include "../dynamics/gprcp.S"
#undef gprcp_

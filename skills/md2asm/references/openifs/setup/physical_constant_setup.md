# Owned Physical Constants

Revision 1 constructs the selected model constants from the equations and declared literals in YOMCST SETUP_CONSTANTS. The actual NAMDYNCORE and NAMSCEN groups are empty. SUDYNCORE therefore gives RCORIOI, RPLRADI and RPLRG the value one and leaves LAPE false. These controls retain the original Earth radius, rotation and solar input. This utility constructs caller-owned storage and uses no OpenIFS module data, constructor, type information or callable. It implements the complete selected numerical constant stage, not the original logging, namelist input or abort services. It adds no whole-original-body credit.

## Interface And Layout

The interface is int md2asm_initialize_physical_constants(output, capacity). Registers x0 and x1 contain a writable eight-byte-aligned record and its byte capacity. The complete 520-byte range must be mapped and must not wrap around the address space. The Arm floating-point control register, FPCR, must be zero. Return zero on success or two for an invalid pointer, capacity, alignment or mode before mutation. The caller owns and retains the record. No allocation or release is needed.

The first 512 bytes hold 64 FP64 values in their source declaration order. FP64 is a 64-bit floating-point number. The source setup logical occupies bytes 512 through 515 and receives one on success. Bytes 516 through 519 remain incoming reserved storage and are included unchanged in the complete comparison. The following table gives every value's byte offset, source name and units. Names preserve original interfaces and are not new abbreviations.

| Byte offset | Source name | Units |
| ---: | --- | --- |
| 0 | RPI | dimensionless |
| 8 | RCLUM | m s−1 |
| 16 | RHPLA | J s |
| 24 | RKBOL | J K−1 |
| 32 | RNAVO | mol−1 |
| 40 | RDAY | s |
| 48 | RDAYI | s |
| 56 | RHOUR | s |
| 64 | REA | m |
| 72 | REPSM | rad |
| 80 | RSIYEA | s |
| 88 | RSIDAY | s |
| 96 | ROMEGA | rad s−1 |
| 104 | RA | m |
| 112 | RG | m s−2 |
| 120 | R1SA | m−1 |
| 128 | DEG2RAD | rad degree−1 |
| 136 | RSIGMA | W m−2 K−4 |
| 144 | RI0 | W m−2 |
| 152 | R | J mol−1 K−1 |
| 160 | RMD | g mol−1 |
| 168 | RMV | g mol−1 |
| 176 | RMO3 | g mol−1 |
| 184 | RD | J kg−1 K−1 |
| 192 | RV | J kg−1 K−1 |
| 200 | RCPD | J kg−1 K−1 |
| 208 | RCPV | J kg−1 K−1 |
| 216 | RCVD | J kg−1 K−1 |
| 224 | RCVV | J kg−1 K−1 |
| 232 | RKAPPA | dimensionless |
| 240 | RETV | dimensionless |
| 248 | RMCO2 | g mol−1 |
| 256 | RMCH4 | g mol−1 |
| 264 | RMN2O | g mol−1 |
| 272 | RMCO | g mol−1 |
| 280 | RMHCHO | g mol−1 |
| 288 | RMNO2 | g mol−1 |
| 296 | RMSO2 | g mol−1 |
| 304 | RMSO4 | g mol−1 |
| 312 | RMCFC11 | g mol−1 |
| 320 | RMCFC12 | g mol−1 |
| 328 | RMHCFC22 | g mol−1 |
| 336 | RMCCL4 | g mol−1 |
| 344 | RCW | J kg−1 K−1 |
| 352 | RCS | J kg−1 K−1 |
| 360 | RATM | Pa |
| 368 | RTT | K |
| 376 | RLVTT | J kg−1 |
| 384 | RLSTT | J kg−1 |
| 392 | RLVZER | J kg−1 |
| 400 | RLSZER | J kg−1 |
| 408 | RLMLT | J kg−1 |
| 416 | RDT | K |
| 424 | RESTT | Pa |
| 432 | RGAMW | dimensionless |
| 440 | RBETW | K |
| 448 | RALPW | dimensionless with the source Pa and K convention |
| 456 | RGAMS | dimensionless |
| 464 | RBETS | K |
| 472 | RALPS | dimensionless with the source Pa and K convention |
| 480 | RALPD | dimensionless |
| 488 | RBETD | K |
| 496 | RGAMD | dimensionless |
| 504 | RSNAN | signalling non-number sentinel |

## Frozen Calculations

Apply the original assignments in source order, with one FP64 rounding after each multiplication, division, addition and subtraction. Keep the integer-power evaluation order explicit. For the radiation constant, form the square and fourth power of pi before its fifth power. Form the cube of the Boltzmann-to-Planck ratio as its square times itself. The pi assignment uses the already-rounded value of two times arcsine of one. It is a mathematical constant, not captured model state. All remaining derived values are computed by assembly at runtime. The two distinct positive natural-logarithm operands use the separately qualified [direct assembly child](../support/positive_natural_logarithm.md), with four calls in source order. The source signalling non-number has the exact word 0x7ff4000000000000 and is moved as integer bytes without arithmetic.

The moist-air gas constant is 1000 times the universal gas constant divided by water molar mass. The water-vapour heat capacity is four times that gas constant. Liquid and ice heat capacities, the freezing temperature and latent heats use the original declared values. These constants define how energy and water change together, and their source values are retained rather than replaced by newer measurements. The saturation coefficients follow the source logarithmic pressure equations with the same intermediate rounding.

Preserve x18, x19 through x29, the required halves of v8 through v15, FPCR and errno. FPSR, the arithmetic-status register, retains incoming flags and adds only genuine arithmetic events. The parent uses a 32-byte, sixteen-byte-aligned stack. It calls only the direct positive-logarithm child and has no file-format or Fortran dependency. The logarithm child retains its direct Linux exit_group rejection service with status 116, although these fixed internal operands do not reach that branch.

## Acceptance

Compare all 520 returned bytes with a genuine source-assignment control under distinct incoming storage patterns and fresh and inherited arithmetic flags. Record any whole-original I/O status separately. Check complete output guards, before-mutation rejects and the Arm ABI. Use independent high-precision physical identities for gas constants, heat capacities, rotation, latent heats and saturation. Verify the original literal rounding and the two newly consumed logarithm operands. Qualify the final pure assembly executable and external-library boundary, then obtain independent source and ABI review. Reuse accepted numerical-child evidence and run no forecast for this setup-only change.

## Completed Checkpoint

All 64 numerical values agree with the complete genuine SETUP_CONSTANTS call across 512 bytes. Its separate original SUDYNCORE call confirms the selected controls. Two typed numerical-stage cases also match all 1,040 returned record bytes under distinct incoming patterns and status flags. Four immediate calls preserve the Arm ABI with zero failure masks. Five invalid inputs reject before mutation, while twenty independent high-precision physical relations, the sentinel and field-order checks pass. Both logarithm operands match the source math library and their independent rounding checks. A pure assembly process writes all 520 bytes exactly and has no shared-library dependency. The whole original input procedure returns errno zero after namelist I/O, while this numerical utility preserves incoming errno. That service difference is explicit and receives no whole-body credit. Independent source and ABI review passes.

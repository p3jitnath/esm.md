# OpenIFS GP_SPV contract

Contract revision 1.0 freezes the complete GP_SPV body in OpenIFS 48.1.1. Its physical input is [surface pressure](../../../../../formulations/openifs/dynamics/surface_pressure.md), revision 1.0. This conversion supplies the bottom pressure boundary used by the hybrid-coordinate stages.

## Method and arithmetic

Preserve the upstream grid, time levels and horizontal coordinate scaling. No new time update is introduced. Recover current surface pressure from its stored logarithm and apply the chain rule to both horizontal derivatives. FP64 is the 64-bit floating-point format, and RN64 rounds to nearest FP64 with ties to an even last bit.

```math
P_0=\operatorname{exp}_{\mathrm{frozen}}(s_0),\qquad
P_{0l}=\operatorname{RN}_{64}(s_{0l}P_0),\qquad
P_{0m}=\operatorname{RN}_{64}(s_{0m}P_0).
```

The pressure reference is 1 Pa, so the numerical exponential result is pressure in pascals. The derivatives have Pa per unit of the supplied horizontal coordinate. Use the [frozen scalar math library](../pressure_math.md) for exp in both implementations. Each multiplication has its own rounding point, with no contraction, reassociation or fast-math.

Update the previous time level only if (!LDTL or LSIMPH or LNHDYN) and (!LTWOTL or (NCURRENT_ITER > 0 and LPC_FULL)). LDTL selects a linearised-model call, LSIMPH selects simplified physics, LNHDYN selects nonhydrostatic motion, and LTWOTL selects a two-time-level scheme. LPC_FULL selects repeated trajectory correction, while NCURRENT_ITER is that correction's iteration number. This Boolean rule is the complete upstream decision for previous-pressure work.

Apply the same three operations to s9 and its derivatives when the rule is true. Finish every current-column update before starting the previous columns, preserving each stored exponential and derivative result. Profiling hooks are outside the numerical body.

## Storage and input rules

Require positive NPROMA, nonnegative NFLEVG, 1 <= KST <= NPROMA and KST - 1 <= KEND <= NPROMA. An empty interval changes no output and reads no numerical arrays. Zero vertical levels still update the surface row, which then has index zero. Dimensions and buffer addresses must fit signed 64-bit arithmetic.

All arrays are 8-byte-aligned FP64 in Fortran order. PSPT0, PSPT0L, PSPT0M and their PSPT9 partners have NPROMA entries. PRE0 and PRE9 have shape (NPROMA,0:NFLEVG). Their only modified row is NFLEVG. PRE0L, PRE0M, PRE9L and PRE9M have NPROMA entries. Every other row and inactive column retains its incoming bits.

Used logarithms are finite and lie in [-745,709], with positive finite exp results. Used gradients and their pressure products are finite and may have either sign, signed zero or subnormal magnitude. All derived objects are valid, and logical values use the GNU Fortran representations zero and one. Inputs and objects remain read-only. Output buffers are separate from each other and all inputs. Input arrays may share storage. Unused previous-time-level arrays may be absent and must not be read. Empty intervals may omit all numerical arrays.

## GNU Fortran interface

Export gp_spv_ for GNU Fortran 12.3 on AArch64. All arguments are addresses, with 32-bit integers and logical values. Registers x0 to x7 hold geometry, TDYN, TDYNA, TSIMPHL, LDTL, KST, KEND and PSPT0. Incoming stack offsets 0, 8, 16, 24, 32, 40, 48, 56, 64, 72 and 80 hold PSPT0L, PSPT0M, PSPT9, PSPT9L, PSPT9M, PRE0, PRE0L, PRE0M, PRE9, PRE9L and PRE9M.

The independent storage probe measures geometry at 17,096 bytes, with NPROMA at 5,144 and NFLEVG at 5,224. TDYN is 4,720 bytes, with NCURRENT_ITER at 2,580. TDYNA is 456 bytes, with LNHDYN at 8, LTWOTL at 20 and LPC_FULL at 336. TSIMPHL is 168 bytes, with LSIMPH at zero. Freeze these offsets only for the recorded build.

Preserve x19 to x29, the link register and the required low halves of v8 to v15. Keep the stack aligned to 16 bytes and leave x18 unused. exp accepts its input and returns its output in d0, and it may overwrite the caller-saved registers. Keep live column pointers and counters in preserved registers or private stack storage.

## Verification and output

Use one small verifier to check the pressure conversion and chain rule against independent long-double values. Require an absolute pressure or gradient error below 1e-300 in its output units plus 32 times FP64 epsilon times the expected magnitude. The pressure-math verifier separately checks subnormal exponential results against decimal arithmetic.

Verify every Boolean decision, nonpositive and positive iteration numbers, current and previous time levels, unused absent inputs, all inactive rows and columns, zero levels, partial and empty intervals, odd widths, final-column protected-page tails, signed zeros, subnormals and large finite products. Inputs and configuration objects are protected against writes. Require zero differing bytes for all six complete output buffers and their guards against unchanged strict-source Fortran using the same math library. Report the first case, time level, field, row, column and bit patterns, and check unchanged FPCR after return.

Canonical small-check files concatenate the six complete output buffers and their guards in argument order and case order as little-endian FP64. Protected-tail cases omit the trailing guard. Forecast records use a 44-byte header containing an 8-byte call number, a 4-byte step, NPROMA, NFLEVG, KST and KEND as four 4-byte integers, and LDTL, the previous-level decision, NCURRENT_ITER and a reserved zero as four 4-byte integers. Output records append all six complete output arrays. Input records append the complete incoming outputs and then the three current arrays, followed by the three previous arrays when used. Pointer addresses, clocks and timing do not enter the canonical records.

The comparison driver calls the complete assembly and Fortran bodies on separate output arrays. It supplies no exponential, derivative or omitted stage. Check every real forecast call and directly compare each saved forecast output with the fresh math-frozen Fortran baseline before accepting integration.

## Provenance

Emit assembly directly from this frozen contract and the physical formulation, then build it with an assembler and linker. The layout probe contains no pressure calculation. Inspect unchanged Fortran solver instructions only after emission. Archive contract, formulation, layout, source, assembly, math-library, verifier and forecast hashes, preserving rejected trials. Accept performance lessons only after repeated quiet-node measurements.

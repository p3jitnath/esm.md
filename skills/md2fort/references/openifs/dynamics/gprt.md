# OpenIFS GPRT contract

Contract revision 1.1 freezes the complete GPRT numerical body in OpenIFS 48.1.1. The physical input is [thermal pressure](../../../../../formulations/openifs/dynamics/thermal_pressure.md), revision 1.0. This routine supplies RT and its horizontal derivatives to CPG_GP_HYD, which forms the hydrostatic pressure force.

## Method and ordered arithmetic

The forecast has already calculated the mixture gas constant and spatial derivatives. GPRT applies the product rule at each supplied point and level, without a time step or a spatial approximation of its own. FP64 means 64-bit floating-point arithmetic, and RN64 denotes rounding to the nearest FP64 value with ties to an even final bit.

Set $`H=\operatorname{RN}_{64}(RT)`$ at every active cell. Select one of the following three gradient calculations. The same calculation applies separately to the L and M horizontal directions.

| Input mode | Complete ordered calculation for direction L |
| --- | --- |
| LDSPRT is true | $`H_L=\operatorname{RN}_{64}(R_dT_L)`$ |
| LDSPRT is false and PRL is present | $`a=\operatorname{RN}_{64}(R_LT)`$, $`b=\operatorname{RN}_{64}(RT_L)`$, $`H_L=\operatorname{RN}_{64}(a+b)`$ |
| LDSPRT is false and PRL is absent | $`d=\operatorname{RN}_{64}(R_v-R_d)`$, $`a=\operatorname{RN}_{64}(dT)`$, $`b=\operatorname{RN}_{64}(aq_L)`$, $`c=\operatorname{RN}_{64}(RT_L)`$, $`H_L=\operatorname{RN}_{64}(b+c)`$ |

The virtual-temperature mode takes priority over the optional gas-constant derivatives. PRM may be present alone and is then ignored. If PRL is present in the explicit-gradient mode, PRM must also be present. Preserve separate multiplication and addition, intermediate rounding, signed zero and gradual underflow. Forbid contraction, reassociation, fast-math and approximate arithmetic.

R uses J/(kg K), T uses K and H uses m²/s². The L and M derivatives retain the input coordinate scaling, which may use the forecast's angular coordinates. Their output units are H per unit of that same coordinate. GPRT does not convert coordinate scales.

## Buffers and interface

KPROMA is positive and KLEV is nonnegative. Require 1 <= KSTART <= KPROMA and KSTART - 1 <= KEND <= KPROMA. An empty interval or zero levels changes no output. The nine array arguments have shape (KPROMA,KLEV), stored in Fortran order as 8-byte-aligned FP64 values. Optional PRL and PRM have the same shape. Their storage and address calculations must fit signed 64-bit arithmetic. Every used input and required intermediate is finite. Physical temperatures and gas constants are positive, while derivatives can have either sign. The numerical interface also supports finite signed or zero values for verification.

Inputs are read-only. The three outputs do not overlap each other or any input. Inactive output entries retain their incoming bits. Unused optional inputs and unused moisture derivatives must not be read. PQL and PQM may have null addresses in the virtual-temperature or explicit-gas-gradient modes, as occurs in the upstream forecast. Two-lane NEON vectors may operate on independent columns, with an in-bounds scalar tail.

Export gprt_ with the GNU Fortran 12.3 interface. All arguments arrive by address. Registers x0 to x7 hold LDSPRT, KPROMA, KSTART, KEND, KLEV, PRD, PRV and PR. Incoming stack offsets 0, 8, 16, 24, 32, 40, 48, 56, 64 and 72 hold PT, PTL, PTM, PQL, PQM, PRT, PRTL, PRTM, PRL and PRM. Absent optional arrays have null addresses. Integers and logical values occupy 32 bits. Preserve x19 to x29, the link register, 16-byte stack alignment and the required parts of v8 to v15. Do not use x18. Profiling hooks are excluded from the numerical body.

## Verification and canonical output

Use the unchanged strict-source Fortran routine as the discrete comparison. Independently check the product rule, uniform air, virtual-temperature equivalence and mixtures whose gas-constant gradient is (Rv - Rd) times the moisture gradient. Use constant, exactly representable fields where an independent expected result is exact. Include both optional derivatives, neither derivative, PRM alone, virtual-temperature priority, zero levels, empty and partial intervals, odd widths, signed zero, subnormal arithmetic, separate-rounding witnesses and a protected page directly after the last scalar tail.

Compare every output byte, inactive entry and guard, then confirm that all input bytes are unchanged. Report the first case, direction, level, column and both bit patterns on a mismatch. Check FPCR before execution and after return. Canonical small-check files concatenate all three full output buffers, including guards, in case order as little-endian FP64. A protected-tail buffer has only its leading guard because its trailing address is an inaccessible page.

In the forecast, copy the three incoming outputs, run the strict Fortran routine on the copies and run the complete assembly body on the actual outputs. Compare all entries and preserve each input. Each output record has an 8-byte call number, 4-byte forecast step, four 4-byte dimensions, a 4-byte presence bit mask and the complete PRT, PRTL and PRTM arrays. Input records also include the constants, incoming outputs and each present input array in interface order. The mask bits are 1 for virtual temperature, 2 for PRL, 4 for PRM, 8 for PQL and 16 for PQM. Only present inputs are written. Keep clocks and pointer addresses outside these bytes. Require zero differing bytes before any timing.

## Provenance

Emit assembly directly from this contract, with no compiler-generated assembly or intermediate representation used for generation. Build it with an assembler and linker. Compiler instructions may be inspected only for interface and arithmetic verification. Archive source, contract, assembly, verifier and output hashes. Accept optimisation lessons only after repeated quiet-node measurements.

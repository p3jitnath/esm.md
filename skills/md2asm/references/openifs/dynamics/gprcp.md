# OpenIFS GPRCP contract

Contract revision 1.1 keeps the frozen revision 1.0 numerical body and clarifies the caller's actual input capacity for GPRCP in local OpenIFS 48.1.1. The physical input is [moist-air properties](../../../../../formulations/openifs/dynamics/thermodynamics.md), revision 1.0. This routine calculates mixture properties and does not advance a forecast.

## Method and arithmetic

A constituent is a material in the mixture. At each active cell, use its mass fraction to adjust the dry-air gas constant and heat capacity. FP64 is the 64-bit floating-point format. Write RN64 for rounding to the nearest FP64 value, with ties rounded to an even final bit. Each subtraction, multiplication, addition and division below has its own rounding point. Keep signed zeros and subnormal values, and disable fusion, reassociation, approximate division and fast-math.

For separate water arrays, start with R = RD and CP = RCPD. Visit vapour, liquid, ice, rain, snow and graupel in that order. Include an array only when it is present and its thermal flag is true. The optional LDTHERMACT overrides all six flags. Otherwise use the matching YGFL component flag. For each selected constituent, form its rounded differences from the dry constants, multiply each difference by its mass fraction, then add the rounded product to the corresponding running value.

```math
a_j=\operatorname{RN}_{64}(R_j-R_d),\qquad
b_j=\operatorname{RN}_{64}(c_{p,j}-c_{p,d}),
```

```math
R\leftarrow\operatorname{RN}_{64}\bigl(R+\operatorname{RN}_{64}(a_jq_j)\bigr),\qquad
C\leftarrow\operatorname{RN}_{64}\bigl(C+\operatorname{RN}_{64}(b_jq_j)\bigr).
```

Vapour uses RV and RCPV. All condensed water uses a zero gas constant. Liquid and rain use RCW, while ice, snow and graupel use RCS. The condensed-water gas coefficient is the sign change of RD.

When PGFL is present, ignore the separate water arrays and LDTHERMACT. Select thermally active descriptors in increasing YCOMP order. KGFLTYP selects each descriptor's field index. Its supported values are 0, 1, 5, 9 and 101, with 0 used when the argument is absent. They select MP, MP1, MP5, MP9_PH and MP_SL1 respectively. For this route, initialise each sum with its first rounded product, add the remaining rounded products in order, and add the dry constant last. With no active descriptor, use the dry constants directly. Moving the dry constant to the start would change the prescribed rounding.

Copy R to PR and C to PCP when those outputs are present. When PKAP is present, write RN64(R/C). No driver supplies a missing part of this calculation. Independent gas and heat-capacity calculations may be interleaved, while each output keeps its stated dependencies and rounding points.

## Inputs and storage

KPROMA is positive. Require 1 <= KSTART <= KPROMA and KSTART - 1 <= KPROF <= KPROMA. KPROF = KSTART - 1 selects an empty interval. KFLEV is nonnegative. Arrays use Fortran column order and FP64 entries, with at least 8-byte alignment. Their byte counts and address calculations must fit signed 64-bit arithmetic. A zero extent is not accessed. Different outputs must not overlap, and an output must not overlap an input. Only active columns in a requested output may change.

Mass fractions and constants are finite. Fractions are nonnegative, their selected sum does not exceed one, and heat capacities are positive. Every required intermediate is finite. A valid generic field index lies between one and both the caller's actual field capacity and YGFL%NDIM. NUMFLDS lies between zero and 2163. Generic descriptors supply finite nonnegative gas constants and positive heat capacities. Configuration and constants stay fixed throughout a call.

The actual input capacity is the number of fields stored by the caller. CPGLAG supplies PGFLT1 with YGFL%NDIM1 fields and selects MP1 with KGFLTYP equal to one. Its T21 array stores six fields, while the main NDIM is eight. The source uses only selected fields within those six. The other observed generic callers supply the full main array for modes zero or nine. Capture the whole actual array, preserving every stored bit, and do not read past it.

The exact constant bits from upstream SETUP_CONSTANTS are shown below. Their units are joules per kilogram per kelvin. The solver reads the upstream module variables so that a reviewed forecast configuration remains authoritative.

| Constant | Default FP64 bits |
| --- | --- |
| RD | 4071F0F46C5FE708 |
| RV | 407CD8665F622251 |
| RCPD | 408F65ABBDA7D44E |
| RCPV | 409CD8665F622251 |
| RCW | 40B07A0000000000 |
| RCS | 40A0740000000000 |

## AArch64 interface

Export gprcp_ with the GNU Fortran 12.3 explicit-shape interface. All 16 arguments are addresses, with a null address meaning that an optional argument is absent. Arguments 1 to 4 are signed 32-bit KPROMA, KSTART, KPROF and KFLEV. Arguments 5 to 10 are PQ, PQI, PQL, PQR, PQS and PQG. Arguments 11 to 16 are PCP, PR, PKAP, PGFL, KGFLTYP and LDTHERMACT. Integer and logical arguments occupy 4 bytes. Logical false is zero and true is one.

The first eight addresses arrive in x0 to x7. At the entry stack pointer, PQS is at byte offset 0, PQG at 8, PCP at 16, PR at 24, PKAP at 32, PGFL at 40, KGFLTYP at 48 and LDTHERMACT at 56. Keep the stack 16-byte aligned. Preserve x19 to x29, the link register and the required portions of v8 to v15. Do not use x18. Scalar FP64 instructions are sufficient for the initial complete implementation.

The module symbol __yom_ygfl_MOD_ygfl stores a pointer to TYPE_GFLD. A compiled layout probe, which contains no solver update, established the following offsets for this frozen build. TYPE_GFLD occupies 1,359,136 bytes. Its NUMFLDS is at byte 0, NDIM at 48, NDIM1 at 64 and fixed YCOMP array at 3848. Each component occupies 368 bytes, with LTHERMACT at 68, R at 72 and RCP at 80. MP, MP1, MP5, MP9_PH and MP_SL1 are at 168, 188, 192, 184 and 216. Pointer slots for YQ, YI, YL, YR, YS and YG are at 799840, 799848, 799856, 799920, 799912 and 799928. These are pointer-slot offsets, rather than the addresses of their targets.

Keep the YGFL configuration object initialised for this GNU Fortran reference interface. Separate arrays also require its six water pointers when LDTHERMACT is absent. A present LDTHERMACT permits those water pointers to be absent. Profiling hooks are excluded from the numerical output.

## Verification and output

Compare every requested output byte with the unchanged strict-source Fortran routine after each call. Check inactive columns, guard entries and unchanged inputs. Cover dry air, each water phase, mixtures, all field-index modes, absent arguments, thermal overrides, partial and empty intervals, odd widths and zero levels. Independently check dry-air values and mass-weighted mixture bounds and balances.

The acceptance limit is zero differing bytes. Report the first case, output field, cell and both FP64 bit patterns on a mismatch. Check FPCR for round-to-nearest with gradual underflow before execution.

Canonical small-check output contains PCP, PR and PKAP in that order for every case, each in Fortran cell order as little-endian FP64. Include inactive cells and the two guard entries, including the unchanged sentinel array for an absent output. Keep timing and pointer addresses outside these bytes.

## Forecast capture

The forecast verifier calls the original strict-source routine on copies of the requested outputs and the complete assembly routine on the forecast outputs. It checks each declared input immediately after each implementation, non-overlapping output buffers, active mixture fractions and finite active properties. The supported forecast capture modes are zero, one and nine, with actual capacities established from all eight observed source callers. Other modes retain their complete numerical small checks and need a caller-capacity review before forecast capture. It adds no numerical stage.

Each recorded call begins with a 96-byte little-endian header. In order, this contains the 8-byte call number, 4-byte forecast step, four 4-byte dimensions, a 4-byte presence mask, the 4-byte field-index mode, 4-byte thermal override, 4-byte NDIM, 4-byte NUMFLDS and six FP64 constants in the table order. The override is -1 when absent. Presence bits 0 to 6 identify the six water arrays and PGFL, bits 7 to 9 identify PCP, PR and PKAP, and bits 10 and 11 identify KGFLTYP and LDTHERMACT.

Output records append each present output array in PCP, PR and PKAP order, including inactive cells. Input records instead append a four-byte actual PGFL capacity and a four-byte call-role value, then the configuration and present input arrays. The capacity is zero when PGFL is absent. A role of zero identifies a genuine model call, while one identifies a source call made only to check another assembly routine. Generic configuration records contain each descriptor's 4-byte thermal flag, 4-byte selected field index, FP64 gas constant and FP64 heat capacity. Separate-water records contain six 4-byte flags in argument order. Inputs then follow in argument order, with the complete PGFL array last when present. Finally append each present incoming output array in PCP, PR and PKAP order, preserving its inactive bytes for exact replay. Pointer addresses, clock times and profiling data are excluded.

The optional --capture-capacity check extends the existing verifier for this observed buffer defect. It places exactly six PGFL fields beside an unreadable page while the main NDIM is eight, then checks the map-one mixture, complete output bits, unchanged inputs and FPCR. An eight-field capture would cross the page. The original 3,976-case corpus keeps its output bytes. Accounting markers for dependent routines change only call classification and never supply numerical work.

The contained [ACCUMULATE stage](gprcp_accumulate.md) is written inside the water macro. Its supporting contract maps all six phase inputs and both property updates to the original host arguments and records their actual accepted forecast executions.

## Provenance

Emit the complete assembly directly from this contract and build it with an assembler and linker. Inspect compiler output only to verify arithmetic and the interface. Keep source, contract, assembly, reference and verifier hashes with actual checks. Do not claim timing or an optimisation lesson before repeated quiet-node measurements establish a gain.

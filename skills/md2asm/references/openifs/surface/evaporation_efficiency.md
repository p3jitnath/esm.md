# Surface Evaporation Efficiency Contract

Revision 1.1. The physics input is [evaporation_efficiency.md](../../../../../formulations/openifs/surface/evaporation_efficiency.md). The original queued routine is `vevap_mod::vevap` in `surf/module/vevap_mod.F90`. The complete calculation has no numerical child or external math function.

## Interface and Owners

The GNU Fortran interface has 29 argument addresses. The first eight are in `x0` through `x7`. The remaining 21 are on the stack at offsets 0 through 160.

| Positions from zero | Arguments |
| --- | --- |
| 0–4 | KIDIA, KFDIA, KLON, PTMST, KTILE |
| 5–12 | PWLMX, PTMLEV, PQMLEV, PAPHMS, PTSKM1M, PTSAM1M, PQS, PCFQ |
| 13–17 | PWETB, PWETL, PWETLU, PWETH, PWETHS |
| 18–20 | YDCST, YDVEG, YDURB |
| 21–27 | PCPTS, PCSAT, PCAIR, PCPTSU, PCSATU, PCAIRU, PCSNW |
| 28 | PDHVEGS |

INTEGER4 scalars are four-byte aligned. FP64 data are eight-byte aligned. All rank-one arrays use GNU 64-byte descriptors. The data pointer addresses the first logical element of the assumed-shape array. The stride at byte 40 counts elements, so column `j` is at `data+8*(j-1)*stride`. Nonzero positive and negative strides are supported. The output diagnostic has a 112-byte rank-three descriptor, with strides at 40, 64 and 88. Its shape includes KLON columns, two vegetation groups and four diagnostic slots.

TCST has 128 bytes, with RD at 32, RETV at 48 and RCPD at 80. TVEG has 776 bytes, with RLHAERO at 696 and RLHAEROS at 704. TURB has 472 bytes, and none of its members are consumed by this routine. The global `__yos_thf_MOD_rvtmp2` contains the heat-capacity factor. Surface setup assigns it positive zero.

Only columns KIDIA through KFDIA are changed. All seven rank-one outputs and the complete diagnostic owner are canonical mutable state, including source-unwritten words and inactive columns. Array owners, descriptors, objects and scalar arguments are disjoint. Original pointer offsets and strides are retained. Inputs and descriptors are read-only. Empty active ranges leave every output byte unchanged.

## Complete Ordered Calculation

For each active column, initialise PCSAT, PCAIR, PCSATU and PCAIRU to 1. Tiles other than 3, 4, 6, 7, 8 and 10 keep these coefficients. Supersaturated air also keeps them at 1 in vegetation, soil and urban branches.

Tile 3 computes `ZEP=C*(qa-qs)` and `ZEMAX=(-W)/dt`, in that order. When both are negative and ZEP is less than ZEMAX, use `min(1,ZEMAX/ZEP)` for all four coefficients.

For tiles 4, 6, 7, 8 and 10, the resistance branch runs when `qa<=qs`. Density is `p/((Rd*Ta)*(1+RETV*qa))`, with each product rounded separately. Divide the selected resistance by the rounded density. Tiles 4, 6, 8 and 10 use `1/(1+C*(r/rho))`. Tile 4 separately uses the unstressed resistance for its two unstressed coefficients. Other branches copy the same coefficient into all four outputs.

Tile 4 stores low-vegetation resistance at PDHVEGS(j,1,3) and `rho/C` at PDHVEGS(j,1,4). Tile 6 stores the high-vegetation equivalents in group 2. These are the only diagnostic writes.

Tile 7 first sets PCSNW to positive zero. Select `h=RLHAEROS` when skin temperature is greater than surface temperature, and otherwise select RLHAERO. Form `ra=1200/h`, `wet=r/rho` and `wets=ra/rho`. Its canopy coefficient is `1/((1+wet*C)+wet/wets)`. When resistance exceeds 1, the snow coefficient is `1/((1+wets*C)+wets/wet)`. The other tile-7 coefficients copy the canopy result.

Finally compute both surface heat terms in the source order `((Ts*cp)*(1+RVTMP2*((b*qs)+((1-b)*qa))))`, using the normal and unstressed coefficients respectively. Preserve the intermediate products and sums even when RVTMP2 is zero.

## Arithmetic and Domain

Use FP64 round-to-nearest with ties to even, gradual underflow, signed zeros and FPCR zero. Every multiply, add, subtraction and division rounds separately. There is no fused multiply-add, reassociation, approximate division or reduced precision. Identical repeated coefficient calculations may reuse the same rounded result because input owners are disjoint and read-only.

Consumed temperatures and pressure are finite and positive, and humidity values are finite and between zero and one. Consumed resistances, water capacity and exchange coefficient are finite and nonnegative. Tile-3 time step is positive. The independent water-capacity bound requires positive capacity and a normal, positive rounded capacity divided by time step. The source leaves coefficients at 1 for zero capacity, and that diagnostic branch is compared exactly without claiming its unweighted water-capacity bound. Canopy heat conductances are positive when selected. Density and used arithmetic remain finite with positive denominators. Exchange coefficient is positive when a diagnostic writes `rho/C`. Heat-capacity factor and RETV are finite and nonnegative, and cp and Rd are positive when consumed. Unused inputs and source-unwritten output words retain arbitrary bits. The source uses every integer tile value, with unspecified values taking the default branch.

## Acceptance

Independently check the water-capacity limit, resistance attenuation, condensation defaults, canopy and snow coefficient bounds and the heat term's humidity-mixture bounds. Use higher-precision real arithmetic for these physical relations, separate from the ordered source calculations. Compare the complete mutable owners against original Fortran with zero differing bytes. Cover every tile branch, threshold ties, cropped and empty ranges, descriptor strides, source-unwritten NaN payloads and protected buffers. Check read-only owners, immediate saved registers and FPCR. Reuse the accepted Arm interface patterns and stop after the focused checks pass.

The direct source is [vevap.S](../../../../../src/openifs/surface/vevap.S). The first focused check passed 67 protected calls, 52 688 complete mutable-owner bytes and 10 088 independent physical relations with zero differing bytes. Its paired smoke passed eight genuine calls and 4 800 output bytes with zero differences. Two additional source-unused NaN input cases passed 1 200 native and paired output bytes with zero differences. A focused rejection check confirms that positive subnormal capacity divided by time step is rejected before either numerical call. Actual forecast calls and saved-file agreement will be recorded separately.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| vevap_mod::vevap | 19,350 | 85,449,600 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

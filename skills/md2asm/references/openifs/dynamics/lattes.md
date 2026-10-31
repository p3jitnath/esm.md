# LATTES Surface-Pressure Transport Contract

The input is [surface-pressure transport](../../../../../formulations/openifs/dynamics/surface_pressure_transport.md). The original entry is `LATTES` in `arpifs/adiab/lattes.F90`. The direct entry is `md2asm_lattes_7240564` in [lattes.S](../../../../../src/openifs/dynamics/lattes.S). It prepares the continuity terms before interpolation.

## Accepted Domain

The complete two-time-level scheme and the three-time-level finite-volume scheme are supported. Two time levels use the current and previous states. Finite volume combines the stored layer weights directly. Finite elements use the already verified [VERDISINT](verdisint.md) integral and its complete direct numerical closure.

The original three-time-level finite-element configuration fails the constant-column mass balance. For three eta layers of widths 0.375, 0.25 and 0.375, it returns a log-pressure increment of 4.791666666666668e-7 when the physical value is 1.25e-6. The rounding limit is 5.68e-19. That source branch omits the inverse eta thickness. The direct entry rejects this configuration before it writes any output. No repair or acceptance of that branch is claimed.

Supported blocks have 1 to 4096 columns and 1 to 512 levels, with an empty or valid selected column interval. The source field maps must fit their declared owners. The accessed pressure is positive and the active physical inputs are finite. Layer weights are nonnegative and have the supplied column normalisation. Finite-element data must satisfy the accepted vertical-integrator contract. Unused cells retain their original bits.

## Arithmetic and Physics

Let $`\tau`$ be half the source time interval, in seconds. Let $`D_b`$ be the supplied pressure-weighted column divergence in pascals per second. Let $`p_b`$ be the bottom pressure. The dry-air gas constant $`R_d`$ is in joules per kilogram per kelvin, the reference temperature $`T_r`$ is in kelvin, and the terrain-correction coefficient $`g_c`$ is in metres per second squared.

```math
c=\frac{g_c}{R_dT_r},\qquad B=bD_0,\qquad
A_\ell=\tau\left[u_\ell(L+cH_L)+v_\ell(M+cH_M)-\frac{D_b}{p_b}\right].
```

The supplied gradients $`L`$ and $`M`$ act on log pressure. The terrain gradients $`H_L`$ and $`H_M`$ are dimensionless. The coefficient $`c`$ has units of inverse metres. The source linear term $`B`$ and each prepared term $`A_\ell`$ are dimensionless.

Set $`z=1+x`$, where $`x`$ is the source time bias. The two-time-level residual is $`R_\ell=A_\ell+zB`$. The predictor stores $`A_\ell`$ for a full corrector and stores $`R_\ell`$ when the source enables its residual history. Its early, stable, centred and cheap predictor branches retain their separate buffer updates. The full corrector consumes the stored term and preserves the cheap-corrector exclusions. The three-time-level finite-volume branch uses $`A_\ell+B`$ and the previous linear term.

The pressure update combines the layer terms with the original positive and negative time weights. A finite-element input includes the inverse eta thickness in every accepted two-time-level branch. Its endpoint entries are positive zero. The source then adds or removes the mapped surface state and terrain correction, scales the linear buffer, and subtracts that same scaled term from the pressure output. The solver preserves every multiplication, addition, subtraction, division, intermediate rounding and branch-dependent grouping in the original source.

Let $`P`$ and $`M`$ be the positive and negative source time weights. Let $`W_\ell`$ be the layer weight, $`E_\ell`$ the inverse eta thickness and $`R_{\ell,\mathrm{old}}`$ the stored residual. Let $`\mu_\ell`$ be the mixing factor. The outgoing level buffer starts at $`C_\ell`$.

| Branch | New outgoing level term |
| --- | --- |
| Early predictor | $`C_\ell+MA_\ell`$ |
| Stable predictor | $`(C_\ell+MA_\ell)+\mu_\ell(R_\ell-R_{\ell,\mathrm{old}})`$ |
| Cheap stable predictor | $`C_\ell+MA_\ell`$, with $`\mu_\ell(R_\ell-R_{\ell,\mathrm{old}})`$ in its separate buffer |
| Centred predictor | $`(C_\ell+MA_\ell)+(0.5M)(R_\ell-R_{\ell,\mathrm{old}})`$ |
| Full corrector | $`C_\ell+MA_{\ell,\mathrm{saved}}`$, unless the cheap corrector excludes it |
| Three time levels | $`(C_\ell+M(A_\ell+B))-(Mb)D_9`$ |

The continuity options `NVLAG=2` and `NVLAG=3` enable these predictor and three-time-level buffer terms. Other options still retain the source two-time-level history and final linear-term updates. The full two-time-level corrector updates its pressure term independently of `NVLAG`.

Finite volume adds $`(PW_\ell)R_\ell`$ in early and stable predictors, $`(PW_\ell)(1.5R_\ell-0.5R_{\ell,\mathrm{old}})`$ in the centred predictor, $`(W_\ell R_\ell)P`$ in the corrector and $`(PW_\ell)(A_\ell+B)`$ for three time levels. The accepted finite-element input uses $`((R_\ell W_\ell)E_\ell)P`$ in early predictors and correctors, $`((R_\ell P)W_\ell)E_\ell`$ in stable predictors and $`(((1.5R_\ell-0.5R_{\ell,\mathrm{old}})W_\ell)E_\ell)P`$ in centred predictors. Each pair of parentheses preserves a source rounding point. The integral returns the bottom-column term.

All arithmetic is FP64 with FPCR 0. Fused multiply-add, expression contraction, reassociation, approximate division, reduced precision and fast math are excluded. Signed zeros and gradual underflow are preserved. The global gas constant, reference temperature and step counter are read without mutation.

## Interface and Storage

The Arm application binary interface, or ABI, passes the first eight argument addresses in `x0` through `x7` and the remaining fifteen on the caller stack. There are 23 ordinary argument addresses.

| Arguments | Meaning |
| --- | --- |
| 1 to 4 | Geometry, field maps, first-step rules and model dynamics |
| 5 and 6 | First and last selected columns |
| 7 to 10 | Half interval, linear coefficient and the two time weights |
| 11 to 15 | Terrain block, terrain gradients and current and previous divergence |
| 16 and 17 | Column divergence and bottom-pressure arrays |
| 18 and 19 | Surface state and predictor mixing field |
| 20 to 23 | Upper-air state, new surface state and the two work-buffer owners |

Storage follows the original Fortran column order. Columns are contiguous, levels follow columns, and fields follow their complete level planes. The divergence and pressure arrays include levels 0 through $`N`$. The output owners are the complete `PGMV`, `PGMVT1S`, `PB1` and `PB2` extents declared by their maps. These owners are separate. Inputs and metadata remain unchanged.

The verified GNU layout uses 17096 bytes for geometry, 1560 for the field maps, 175976 for the step rules and 13232 for model dynamics. Model dynamics contains its 456-byte dynamic options at offset 0, 4720-byte dynamic state at offset 456, 304-byte first work-buffer map at offset 8880 and 160-byte second map at offset 9184. Pointer descriptors give the terrain and vertical geometry. The focused metadata record retains each consumed offset.

The assembly uses a 736-byte aligned frame and preserves `x19` through `x29`, the link register and the ABI-required low halves of `v8` through `v15`. A private temporary owner holds the nonlinear plane and the finite-element input and result. Allocation and release supply storage only. The nonlinear plane is complete before any saved upper-air field is replaced. No language driver supplies a missing numerical stage.

## Verification and Limits

The original constant-column checks accept both two-time-level vertical methods and three-time-level finite volume. The unchanged vertical-integrator proofs remain authoritative. New focused cases check predictor and corrector flags, both lagrangian continuity options, other no-update options, both level origins, partial and empty column intervals, odd column counts, the declared largest block and depth, signed zeros and subnormal values. Complete owner bytes must agree with the strict source corpus with zero differing bytes.

Native checks add both protected buffer placements, unchanged inputs and inactive cells, the immediate ABI and rejection of the unsupported configuration before output writes. A same-input forecast relay will run the original on cloned complete output owners and return the native output only after a complete raw-byte comparison. This contract records no comparative timing or SIMD speedup.
The supported-domain source verifier accepts 85 cases and 1,038,288 complete returned bytes, with 51,920 independent relations. Native verification accepts 170 protected calls and 2,076,576 returned bytes, with 103,840 relations and zero differing bytes. The live relay also accepts all 85 cases against the frozen source corpus. The separate shared-buffer rejection case confirms that all 256 returned owner bytes remain unchanged when the unsupported configuration exits with code 116. These checks ran in allocation 7240564 on nid010555, CPU 64, with local memory placement and FPCR 0. Forecast acceptance is a later batch gate.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| lattes | 2,150 | 395,875,200 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

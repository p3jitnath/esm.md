# OpenIFS CTVTOT contract

Contract revision 1.0 freezes the complete CTVTOT body in OpenIFS 48.1.1 before direct emission. The physical input is [moist-air properties](../../../../../formulations/openifs/dynamics/thermodynamics.md), revision 1.0, equations P01 to P03. Their equations, identifiers and revision remain unchanged. This routine converts one supplied virtual-temperature state and does not advance time.

## Physical meaning

Virtual temperature Tv is the temperature dry air would need to give the same pressure at the same density. T and Tv use kelvin. The dry and mixture gas constants Rd and Rm use joules per kilogram per kelvin. Equation P03 gives

```math
p=\rho R_mT=\rho R_dT_v,\qquad T=\frac{R_dT_v}{R_m}.
```

Obtain Rm from the complete accepted direct GPRCP dependency. CTVTOT always supplies PGFL, requests only PR and leaves KGFLTYP and LDTHERMACT absent. Thus its source uses the generic descriptor route with the default MP field index. Other GPRCP index modes and the separate-water route are not CTVTOT branches.

Include thermally active descriptors in increasing YCOMP order. Inactive descriptors contribute nothing, and no active descriptor gives Rm=Rd. Selected fractions use kg/kg, are nonnegative and sum to at most one. Constituent gas constants are finite and nonnegative, heat capacities are positive, and the real and rounded mixture gas constants are positive and resolved.

## Ordered arithmetic

FP64 is the 64-bit floating-point format. RN rounds to nearest FP64 with ties to an even final bit. Preserve gradual underflow and both zero signs. Forbid fusion, contraction, reassociation, approximate division, reduced precision and fast-math. FPCR, the Arm floating-point control register, stays unchanged.

Stage 1 calls gprcp_assembly_ for all active Rm values in private storage. Its frozen generic calculation rounds each coefficient $`a_j=R_j-R_d`$ and product $`a_jq_j`$ separately, starts with the first product, adds remaining products in descriptor order, and adds Rd last. With no active descriptor it copies Rd. The driver supplies none of this calculation.

Stage 2 visits increasing levels and active columns. For each incoming Tv calculate $`u=\mathrm{RN}(R_dT_v)`$, then store $`T=\mathrm{RN}(u/R_m)`$. Multiplying Tv by a predivided ratio changes the rounding points and is forbidden. Constants and configuration stay fixed during a call.

## Storage and supported domain

NPROMA is positive and NFLEVG is nonnegative. Require 1 <= KSTART <= NPROMA and KSTART-1 <= KPROF <= NPROMA. KPROF=KSTART-1 selects an empty interval. Arrays use Fortran order, with column varying first, FP64 entries and at least eight-byte alignment. Their sizes and addresses fit signed 64-bit arithmetic.

PT has shape (NPROMA,NFLEVG) and is the only mutable caller array. PGFL has shape (NPROMA,NFLEVG,C), with C taken from the supplied YGFL object's NDIM and the actual allocation. The global __yom_ygfl_MOD_ygfl pointer identifies an initialised configuration with the same NDIM. A separate equivalent object is permitted. Its NUMFLDS lies in 0:2163, and every selected MP lies in 1:C. Do not infer capacity from the number or largest index of selected constituents.

Objects and PGFL have nonnull addresses, including zero-level and empty calls. A zero-size PGFL uses a nonnull dummy address and is not read. Empty intervals and zero levels preserve every PT byte; the direct body can return before allocation because no output is active. Inputs and used intermediates are finite, with positive Rm. Physical inputs use positive temperature; finite signed values, signed zeros and subnormals test numerical boundaries. PT and PGFL do not overlap.

A storage-only GNU Fortran 12.3 probe gives GEOMETRY size 17096 bytes, NPROMA at 5144 and NFLEVG at 5224. TYPE_GFLD has size 1359136 bytes, NUMFLDS at 0, NDIM at 48 and YCOMP at 3848. Each descriptor occupies 368 bytes, with LTHERMACT at 68, R at 72, RCP at 80 and MP at 168. Rd comes from __yomcst_MOD_rd. Profiling hooks are excluded.

The forecast comparator is scoped to SCAN2M. Lines 232–248 associate YGFL with YDMODEL%YRML_GCONF%YGFL and GFL with YDFIELDS%YRGFL%GFL. Lines 376–380 pass one contiguous GFL(1,1,1,IBL) block and a separate GMV temperature field. Record the explicit argument's C and allocation provenance before copying all C fields. Require agreement with global NDIM. Other GPRCP callers need their own allocation evidence.

## AArch64 ABI and dependencies

An application binary interface, or ABI, states where arguments reside and which registers a function preserves. Export ctvtot_ for GNU Fortran 12.3 on AArch64. x0 to x5 hold GEOMETRY, supplied YGFL, addresses of KSTART and KPROF, PT and PGFL. Integers occupy 32 bits. Preserve x19 to x29, the link register, the required portions of v8 to v15 and 16-byte stack alignment. Do not use x18. Floating-point work uses only v0 to v2.

The 176-byte frame has 64 outgoing argument bytes, saved registers at 64:159 and private 32-bit NPROMA/NFLEVG at 160/164. malloc allocates 8*NPROMA*NFLEVG bytes for private Rm and free releases it. Allocation supplies no numerical work. Allocation failure is outside the supported domain and terminates.

Call GPRCP_ENTRY, default gprcp_assembly_. Its x0 to x3 receive addresses for NPROMA,KSTART,KPROF,NFLEVG in that order. x4 to x7 are null PQ,PQI,PQL,PQR. Stack offsets 0,8,16,24,32,40,48,56 hold null PQS, null PQG, null PCP, private PR, null PKAP, PGFL, null KGFLTYP and null LDTHERMACT. The complete accepted direct dependency calculates the mixture. A high-level redirect is preparation only.

## Frozen verification

Freeze the input corpus before emission. Shapes (NPROMA,KSTART,KPROF,NFLEVG) are (1,1,1,0), (1,1,1,1), (2,1,2,2), (3,1,3,3), (7,2,6,5), (9,1,9,19), (13,13,13,20), (3,2,1,7), (8,1,8,32). Cover no descriptors, all inactive, each water phase, all selected phases, sparse selection, reordered/repeated MP indices, general constituent properties and NUMFLDS=2163. Add signed-zero, subnormal, finite-extreme and inverse-conversion inputs, with protected tails at widths 1,3,4,7.

Independently calculate $`q_d=1-\sum q_j`$ and $`R_*=q_dR_d+\sum q_jR_j`$ in long double from the physical mixture equation. Compare temperature with $`R_dT_v/R_*`$. Check dry-air identity and recovery of a known T from Tv. The physical tolerance is (64+8*nactive)*DBL_EPSILON*max(1,abs(expected)) times 1+sum(abs((Rj-Rd)*qj))/R*, plus 16*DBL_TRUE_MIN. This tolerance never relaxes exact-byte acceptance.

Compare all PT bytes with unchanged strict-source CTVTOT after each complete call. Check inactive cells, guards, protected tails, read-only geometry/configuration/PGFL, immutable module values and FPCR after each solver. At least one frozen cell must distinguish a separately rounded product followed by division from a predivided ratio.

Input records begin with twelve little-endian int32 values: case,NPROMA,KSTART,KPROF,NFLEVG,C,NUMFLDS,configuration,temperature pattern,protected-tail flag,revision=1,reserved=0. Append six FP64 upstream constants in GPRCP's contract order. Each descriptor contributes int32 thermal flag, int32 MP, FP64 R and FP64 RCP. Append complete PGFL and incoming PT, with a leading sentinel and a trailing sentinel when the final page is not protected. Output records use the same 96-byte dimension/constant header, followed by complete returned PT and its sentinels. Exclude pointer addresses and timing data. Acceptance requires zero differing bytes, with the first case, field, level, column and FP64 bits reported on failure.

## Forecast and acceptance

The comparator calls unchanged-source CTVTOT on a full PT copy, bracketed by optional paired gprcp_forecast_reference_begin/end hooks, then calls the complete direct body on forecast PT. Use neither hook unless both exist. They serve diagnostic accounting and supply no arithmetic. Declare one direct GPRCP call per nonempty positive-level native CTVTOT call, and keep source-shadow dependency visits separate from genuine forecast work.

Forecast records begin with uint64 call, int32 step, nine int32 values NPROMA,KSTART,KPROF,NFLEVG,C,global NDIM,NUMFLDS,active descriptor count,allocation provenance=1, then six FP64 constants. This header has 96 bytes. Provenance 1 identifies the source-confirmed SCAN2M contiguous GFL block. Output streams append complete PT. Inputs append descriptor records, complete PGFL and incoming PT, retaining inactive bytes.

Standalone acceptance needs the complete direct dependency, independent science, strict bytes, bounds, FPCR and a post-emission instruction audit. Complete acceptance also needs saved forecast comparisons and independent whole-forecast checks. Preserve the original numerical freeze and source, formulation, contract, corpus, toolchain and dependency hashes. These checks imply no timing or performance claim.

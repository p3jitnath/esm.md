# Runtime Cloud Microphysics Layer

Revision 1 joins the original 26-address `CLOUD_LAYER` interface to the accepted serial `CLOUDSC` calculation. A column is one vertical stack of atmospheric cells. Let $`P`$ be the complete column count, $`L`$ the level count, and $`F`$ the number of supplied surface fields. The same assembled entry supports $`1\le P\le4096`$, $`2\le L\le256`$, and an active interval from column 1 through a final column from 0 through $`P`$. Final column 0 means an empty interval. The numerical child retains these bounds.

The [new entry](../../../../../src/openifs/physics/runtime_cloud_microphysics_layer.S) prepares the child's arguments in the original source order, then calls its complete calculation once. The [shared argument body](../../../../../src/openifs/physics/shared_cloud_layer_arguments.inc.S) also serves the original entry in [physical_parameter_layer_views.S](../../../../../src/openifs/physics/physical_parameter_layer_views.S). That complete default object remains byte-for-byte identical, including its original 24-column, 19-level checks. The accepted [cloud calculation](../cloud_microphysics_contract.md) and [supersaturation child](cloud_supersatcheck.md) retain their complete numerical objects and arithmetic.

## State And Physical Preconditions

Temperature is in kelvin, pressure is in pascals, water amounts are in kilograms of water per kilogram of air, and the supplied physical interval `TPHY2.TSPHY` is in seconds. Every pressure-layer difference is positive. The caller supplies finite physical states and the exact accepted physical and ordinary thermodynamic constants. Each actual supersaturation call must satisfy its child's stated temperature, pressure, humidity, cloud-fraction and activity limits. The excluded warm trigger-gap states remain excluded. A later humidity correction is a separate calculation.

The caller prepares `TECLDP` with the accepted runtime `SUCLDP` service and `TECUMF` with the accepted live convection setup. The ordinary thermal producer runs before convection publishes its three thermal words. The measured 137-level setup uses the actual retained standard-atmosphere pressure owner and returns `NCLDTOP=15`; the seven-level verification grid returns 2. The cloud calculation starts at that supplied level. Another top from 2 through $`L`$ is supported when its parameter and state inputs satisfy the unchanged child contract.

The selected route has `NSSOPT=1`, no stochastic parameter perturbations, no aerosol options, no cloud inhomogeneity, and no active cloud-budget diagnostics. `KFLDX` and `NRFTOTAL` are zero. The unused budget time-integration flag can remain true because its enclosing routes are disabled. Profiling and single-column-model budget policies are false. The [single-column policy owner](../../../../../src/openifs/physics/cloud_microphysics_policy.S) supplies four read-only bytes. Physical and thermal aliases reach initialized assembly-owned 520-byte and 1920-byte namespaces; the profiling policy reaches its accepted assembly owner. Original OpenIFS global storage supplies no native stage.

This entry consumes caller-owned records. Checked field associations do not establish complete upstream construction of every weather record. The verification inputs use actual assembly parameter producers, retained standard-atmosphere pressure and temperature profiles, and explicit constructed cloud states. The supplied one-second setup interval is an input prerequisite, not a replacement for a forecast time-step service. Complete loaded-weather forwarding and whole-forecast acceptance remain separate requirements.

## Application Binary Interface

The AArch64 application binary interface, or ABI, passes the first eight addresses in `x0` through `x7`. The incoming stack holds the remaining 18 addresses in eight-byte slots, in this order:

```text
YDSURF, YDECLDP, YDECUMF, YDEPHLI, YDPHY2, YDERAD, YDEPHY, YDVDF,
YDSPP_CONFIG, YGFL, KDIM, LDSLPHY, PAUX, PPERT, STATE,
TENDENCY_CML, TENDENCY_DYN, TENDENCY_VDF, PRAD, PSURF, LLKEYS,
AUXL, FLUX, PDIAG, FSD, TENDENCY_LOC
```

Every complete outer record is live, mapped and aligned to eight bytes, except the four-byte logical scalar, which is aligned to four bytes. Each declared address span must fit without wrapping the 64-bit address range. These record sizes follow the original type layout.

| Argument | Complete record bytes |
| --- | ---: |
| `YDSURF` | 18,224 |
| `YDECLDP` | 2,776 |
| `YDECUMF` | 344 |
| `YDEPHLI` | 120 |
| `YDPHY2` | 160 |
| `YDERAD` | 2,040 |
| `YDEPHY` | 448 |
| `YDVDF` | 72 |
| `YDSPP_CONFIG` | 3,192 |
| `YGFL` | 1,359,136 |
| `KDIM` | 192 |
| `LDSLPHY` | 4 |
| `PAUX` | 1,992 |
| `PPERT` | 1,584 |
| `STATE` | 1,240 |
| `TENDENCY_CML` | 1,240 |
| `TENDENCY_DYN` | 1,240 |
| `TENDENCY_VDF` | 1,240 |
| `PRAD` | 2,664 |
| `PSURF` | 13,680 |
| `LLKEYS` | 664 |
| `AUXL` | 2,336 |
| `FLUX` | 5,064 |
| `PDIAG` | 4,104 |
| `FSD` | 728 |
| `TENDENCY_LOC` | 1,240 |

A GNU Fortran array descriptor stores the data address, element size, rank, type, and each dimension's bounds and stride. These descriptors have version zero, element span equal to element size, lower bounds one, and dense column-major storage: columns are adjacent, then levels, then field planes. The descriptor offset is minus the sum of its dimension strides, so its first declared element is the data address. Numeric arrays use aligned eight-byte FP64 values; integer and logical arrays use aligned four-byte words. Every complete backing owner is admitted, including unused field planes and inactive columns.

`YDSURF+8992` holds a pointer to a separate live mapped `int32` surface-field index. An `int32` is a signed four-byte integer. Its complete four-byte span is aligned, nonwrapping and disjoint from every mutable array. Its value is from 1 through $`F`$, where $`1\le F\le1024`$. `PSDVF` contains $`P\times F`$ values. The zero-width `PSDXA` descriptor has shape $`P\times0`$ and can have a null data address because `KFLDX=0`.

The table identifies every complete backing owner used by the shared source-order map. Offsets are bytes from the named record. A mutable owner can change; every other owner must remain unchanged.

| Record | Descriptor offset | Field | Shape | Element bytes | Mutable |
| --- | ---: | --- | --- | ---: | --- |
| `STATE` | 208 | `T` | P × L | 8 | No |
| `STATE` | 384 | `Q` | P × L | 8 | No |
| `STATE` | 472 | `A` | P × L | 8 | No |
| `STATE` | 1000 | `CLD` | P × L × 5 | 8 | No |
| `TENDENCY_CML` | 208 | `CMLT` | P × L | 8 | No |
| `TENDENCY_CML` | 384 | `CMLQ` | P × L | 8 | No |
| `TENDENCY_CML` | 472 | `CMLA` | P × L | 8 | No |
| `TENDENCY_CML` | 1000 | `CMLCLD` | P × L × 5 | 8 | No |
| `TENDENCY_LOC` | 208 | `LOCT` | P × L | 8 | Yes |
| `TENDENCY_LOC` | 384 | `LOCQ` | P × L | 8 | Yes |
| `TENDENCY_LOC` | 472 | `LOCA` | P × L | 8 | Yes |
| `TENDENCY_LOC` | 1000 | `LOCCLD` | P × L × 5 | 8 | Yes |
| `TENDENCY_DYN` | 472 | `DYNA` | P × L | 8 | No |
| `TENDENCY_DYN` | 1000 | `DYNCLD` | P × L × 5 | 8 | No |
| `TENDENCY_VDF` | 472 | `VDFA` | P × L | 8 | No |
| `TENDENCY_VDF` | 1000 | `VDFCLD` | P × L × 5 | 8 | No |
| `PRAD` | 1968 | `SW` | P × L | 8 | No |
| `PRAD` | 2056 | `LW` | P × L | 8 | No |
| `PAUX` | 888 | `W` | P × L | 8 | No |
| `PAUX` | 712 | `PFULL` | P × L | 8 | No |
| `PAUX` | 624 | `PHALF` | P × (L+1) | 8 | No |
| `PAUX` | 1104 | `PGAW` | P | 8 | No |
| `PSURF` | 8728 | `PSDVF` | P × F | 8 | No |
| `PSURF` | 9816 | `PSDXA` | P × 0 | 8 | No |
| `LLKEYS` | 192 | `LLCUM` | P | 4 | No |
| `PDIAG` | 2488 | `ICTOP` | P | 4 | No |
| `PDIAG` | 2360 | `ITYPE` | P | 4 | No |
| `PDIAG` | 2552 | `IPBLTYPE` | P | 4 | No |
| `PDIAG` | 2144 | `ZEIS` | P | 8 | No |
| `PDIAG` | 3120 | `ZLU` | P × L | 8 | No |
| `PDIAG` | 2920 | `ZLUDE` | P × L | 8 | Yes |
| `PDIAG` | 3008 | `ZLUDELI` | P × L × 4 | 8 | No |
| `PDIAG` | 3296 | `ZSNDE` | P × L × 2 | 8 | No |
| `PDIAG` | 2744 | `PMFU` | P × L | 8 | No |
| `PDIAG` | 2832 | `PMFD` | P × L | 8 | No |
| `PDIAG` | 2272 | `COV` | P × L | 8 | Yes |
| `AUXL` | 1240 | `LCRIT` | P × L | 8 | No |
| `AUXL` | 1328 | `ICRIT` | P × L | 8 | No |
| `AUXL` | 1504 | `REICE` | P × L | 8 | No |
| `AUXL` | 1592 | `CCN` | P × L | 8 | No |
| `AUXL` | 1680 | `NICE` | P × L | 8 | No |
| `AUXL` | 200 | `RAINFRAC` | P | 8 | Yes |
| `FLUX` | 2728 | `CSQL` | P × (L+1) | 8 | Yes |
| `FLUX` | 2816 | `CSQN` | P × (L+1) | 8 | Yes |
| `FLUX` | 880 | `CQNNG` | P × (L+1) | 8 | Yes |
| `FLUX` | 792 | `CQLNG` | P × (L+1) | 8 | Yes |
| `FLUX` | 2904 | `SQRF` | P × (L+1) | 8 | Yes |
| `FLUX` | 2992 | `SQSF` | P × (L+1) | 8 | Yes |
| `FLUX` | 968 | `CQRNG` | P × (L+1) | 8 | Yes |
| `FLUX` | 1056 | `CQSNG` | P × (L+1) | 8 | Yes |
| `FLUX` | 3080 | `SQLTUR` | P × (L+1) | 8 | Yes |
| `FLUX` | 3168 | `SQITUR` | P × (L+1) | 8 | Yes |
| `FLUX` | 1320 | `PLSL` | P × (L+1) | 8 | Yes |
| `FLUX` | 1408 | `PLSN` | P × (L+1) | 8 | Yes |
| `FLUX` | 1672 | `HPSL` | P × (L+1) | 8 | Yes |
| `FLUX` | 1760 | `HPSN` | P × (L+1) | 8 | Yes |

Each mutable owner is disjoint from every other array owner, all 26 complete outer records and the surface-index scalar. Read-only owners can share storage when their logical views agree. The caller must keep every span mapped and give mutable arrays write permission; arithmetic span checks do not prove operating-system mapping or permissions. Outer records and input owners can be read-only.

The 76 child addresses retain the original order: seven configuration records; four dimension scalars; the physical interval; state temperature and humidity; cumulative tendencies; local output tendencies; turbulence and dynamics tendencies; radiative rates; vertical velocity and full/half pressure; surface mask and grid weight; convection and boundary-layer metadata; detrainment and mass fluxes; the empty perturbation workspace and scalar logical; cloud fraction and five cloud-water planes; aerosol inputs; precipitation cover and private heterogeneity workspace; whole rain-freezing fraction; fourteen complete flux arrays; the empty extra diagnostic view; and `KFLDX`. The shared assembly gives the exact offsets and repeated field-plane addresses. The downward mass-flux descriptor `PMFD` is at `PDIAG+2832`.

## Storage, Status And Returned State

The parent owns $`8PL`$ bytes of private heterogeneity workspace through the public `mmap` and `munmap` interfaces. A new anonymous mapping supplies the same positive-zero words as the source's complete `ZFSD(:,:)=0` assignment. Allocation follows admission, and release follows the child. The child retains its separate accepted level scratch. No driver supplies an omitted calculation or numerical workspace.

The runtime entry returns 0 after calculation and release, −1 for a refused shape, record, descriptor, alias or selected control, −2 when its workspace allocation fails, and −3 if release fails after calculation. Admission and allocation failures precede returned-array writes. A release failure follows numerical writes and does not promise rollback. The child's existing fatal resource policy remains separate. The allocation-failure check limits the real process address space so that the public mapping request fails naturally.

The parent preserves `x18`, `x19` through `x29`, the low 64 bits of `d8` through `d15`, and 16-byte stack alignment. Its private stack frame contains 8192 bytes. FPCR, the floating-point control register, must be zero for nearest-even FP64 arithmetic with gradual underflow. FPSR records numerical events. The parent preserves the child's natural FPSR and errno results across storage calls; refused calls preserve incoming status. The child keeps its accepted separate operations, mathematical functions, signed zeros and rounding points. There is no fused multiply-add, reassociation or reduced-precision arithmetic.

Each active column's local temperature, humidity and cloud-fraction tendencies and first four cloud tendency planes follow the source. The fifth tendency plane is unchanged. Inactive columns retain their bytes. The whole rain-freezing-fraction owner is cleared even for an empty interval. Each returned flux owner includes all $`L+1`$ interfaces. Complete owners are compared, including source-unwritten regions.

## Physical And Exact-Byte Checks

Let $`\Delta t`$ be the physical interval, $`g`$ gravity and $`\Delta p_k`$ a layer's pressure thickness. The layer mass per unit area is $`m_k=\Delta p_k/g`$. The independent column check uses the returned water rates:

```math
\Delta t\sum_k m_k
 \left(\dot q_k+\dot q_{\ell,k}+\dot q_{i,k}+\dot q_{r,k}+\dot q_{s,k}\right)
 = I_{\ell}+I_i-\Delta t(F_r+F_s).
```

Here $`q`$ is water vapour; subscripts $`\ell,i,r,s`$ denote cloud liquid, cloud ice, rain and snow. The terms $`I_\ell,I_i`$ are admitted convective water imports, and $`F_r,F_s`$ are ground precipitation fluxes in kilograms per square metre per second. The phase-enthalpy check replaces the rate sum with $`c_p\dot T-L_v(\dot q_\ell+\dot q_r)-L_s(\dot q_i+\dot q_s)`$ and uses the matching latent-energy imports and precipitation terms. Here $`c_p`$ is air's heat capacity and $`L_v,L_s`$ are latent heats. These independent sums use 120 decimal digits. Their unchanged rounding limit is 128 times $`L`$ times FP64 machine epsilon times the sum of the magnitudes of the separate physical terms.

Eight genuine source calls and eight final native calls pass at 17 columns/137 levels and 8 columns/7 levels, including empty and partial intervals and both protected buffer placements. Each route checks 61,740 physical and preservation relations, including 120 water and phase-enthalpy balances. The original reference returns ABI mask 2 because it uses x18 as scratch; the checker records this limitation. Native ABI masks and runtime returns are zero, including preservation of x18. Complete returned-owner and raw-status comparisons cover 1,843,840 bytes with zero differences: 1,843,680 data bytes and 160 status bytes. Each route also checks 15,027,040 immutable-owner bytes.

Seventeen focused admission and real allocation-failure cases leave 24,809,392 complete owner bytes unchanged and preserve FPCR, FPSR and errno. The loaded production image proves 26 consumed physical/thermal words and two policy words against their actual owner addresses and global-offset-table slots. This table stores addresses used by linked code. All 47 inspected numerical branch sites reach the accepted local cloud, supersaturation, EXP or POWER body. The native loaded image and dependency closure contain no original `libarpifs`.

The first source attempts exposed a verification-fixture descriptor offset error. Capturing the actual reference parent's child arguments isolated the downward mass-flux association, and the corrected fixture uses its exact source offset. Failed states and exact water residuals remain archived. Source physics, outputs, arithmetic and tolerance were preserved. A direct unchanged source-child call and its existing stage observer agreed; they supplied diagnosis, not an extra accepted provider. No unchanged accepted numerical bank was replayed, and the original main executable was not rebuilt. Detailed measurements, raw banks and local receipts remain outside the public tree.

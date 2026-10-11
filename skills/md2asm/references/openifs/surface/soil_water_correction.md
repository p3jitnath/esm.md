# Soil Water Correction Contract

Revision 1 freezes complete SRFWNG from [Soil Water Corrections](../../../../../formulations/openifs/surface/soil_water_correction.md), SC-1 to SC-3. The routine corrects a supplied water state. It includes canopy overflow, downward deficit transfer, saturation runoff, surface water exchange and the optional diagnostic update.

## Interface

The AArch64 entry is $`md2asm_soil_water_correction`$, with the GNU alias $`__srfwng_mod_MOD_srfwng`$. Fourteen addresses follow the original order.

| Position | Argument | Shape and change |
|---|---|---|
| 1–4 | first column, last column, layer count, time | INT32, INT32, INT32 and FP64 scalars, read only |
| 5 | soil type | INT32 column array, read only |
| 6–8 | canopy water, canopy capacity, soil water | FP64 column array, read-only column array and updated column-by-layer array |
| 9 | soil settings | Read-only GNU TSOIL object |
| 10–12 | surface runoff, deep runoff, surface exchange | Updated FP64 column arrays |
| 13 | land mask | Read-only INT32 logical column array |
| 14 | soil water diagnostics | Updated FP64 column-by-layer-by-channel array, optional through zero size |

The first eight addresses use x0 to x7. The final six use successive eight-byte stack slots. Preserve x19 to x29, the lower halves of v8 to v15, the stack alignment and FPCR. Do not use x18. The stack stays aligned to 16 bytes.

GNU descriptors have 40 bytes of common data and 24 bytes per dimension. The data address is at byte 0, first stride at byte 40 and bounds at bytes 48 and 56. A zero first stride means one element for these assumed-shape arguments. Each owner has its own signed strides. The data address represents its first logical cell, so the descriptor offset is not applied again. INT32 cells use four bytes and FP64 cells use eight bytes.

Support 1 to 4096 layers and up to 4096 active columns. An empty interval is valid. Each supplied array contains the complete active extent. Diagnostic channel 6 exists when the diagnostic size is positive, and a zero-size diagnostic has no readable owner requirement. Input and output buffers do not overlap. All scalar and FP64 addresses meet their natural alignment.

TSOIL has 2416 bytes. RWSAT is at 120, LEVGEN at 440, the RWSATM allocation descriptor at 880 and the RDAW allocation descriptor at 1648. RDAW and, when enabled, RWSATM are genuine contiguous GNU allocatable arrays. Their array offsets and lower bounds apply to the original integer indices. Every active thickness is positive. Soil type indices belong to the saturation allocation when LEVGEN is enabled. The routine reads the accepted module symbol $`__yos_thf_MOD_rhoh2o`$ for water density.

## Ordered Update

Round each arithmetic operation separately in FP64 with FPCR 0. First form $`1/\Delta t`$, $`1/\rho_w`$ and each $`1/h_j`$. Visit columns in increasing order and layers from top to bottom.

For land, select saturation and set deep runoff to positive zero. On the first layer, form canopy overflow as $`\max(0,L-L_{\max})`$, subtract it from canopy water, and add $`(q/\rho_w)/h_1`$ through two ordered products with the saved reciprocals. Then form $`d_j=\min(\theta_j,0)`$ and subtract it. Before the next layer is visited, add $`(d_jh_j)/h_{j+1}`$ through two ordered products.

Form $`r_j=\max(0,\theta_j-\theta_{\mathrm{sat}})`$. The top layer adds $`(h_j\rho_w)r_j`$ to surface runoff and adds $`((d_j\rho_w)h_j)/\Delta t`$ through the saved time reciprocal to surface exchange. Every deeper layer adds $`(h_j\rho_w)r_j`$ to deep runoff. Subtract runoff from soil water.

When diagnostics exist, subtract $`((\rho_w/\Delta t)h_j)(d_j+r_j)`$ from channel 6. For a lower neighbour, add $`((\rho_w/\Delta t)h_j)d_j`$ to its channel 6. Keep these two writes in their source order. Sea columns set only deep runoff and surface exchange to positive zero. The minimum of two zeros preserves negative zero, and their maximum preserves positive zero. Keep the subtraction after each selected value, since this determines the returned zero bits.

## Acceptance

An independent water-mass sum uses extended precision and verifies canopy bounds, layer saturation bounds, total runoff, the top-layer deficit exchange and the diagnostic column balance. The bottom deficit is a recorded water gain. Use a rounding budget of $`8192\epsilon(N+1)`$ times the absolute water-mass scale plus $`128`$ times the least positive FP64 value, where $`\epsilon`$ is FP64 machine precision and $`N`$ is the layer count. This budget tests the physical balances and never changes returned bits.

Compare all six returned owners with the strict original, including unused cells, gaps and diagnostic channels. The exact acceptance limit is zero differing bytes. Protect immutable inputs and descriptors and check both guard-page ends, independent positive and negative strides, signed zeros, subnormals, empty intervals, sea columns, one layer and both saturation routes. Reuse accepted module and GNU ABI evidence. A paired forecast adapter must call the complete direct body and compare original outputs before the entry is accepted in the weather count.

## Completed Checks

| Check | Calls | Complete output bytes | Independent relations | Differing bytes |
|---|---:|---:|---:|---:|
| Strict original physical balances | 580 | 28,876,976 | 212,106 | — |
| Protected direct assembly and ABI | 580 | 28,876,976 | 212,106 | 0 |
| 4096-column signed-stride edge | 2 | 9,179,888 | 55,708 | 0 |
| Paired actual entry smoke | 72 | 201,648 | 2,082 | 0 |

The direct body saves each layer thickness and its separately rounded reciprocal in a 16-byte-per-layer workspace. It reuses them across columns while preserving the original water transfers and diagnostic write order. The fixed frame is 384 bytes, and no external numerical child is required. These records establish agreement and physical balances. They do not establish a timing improvement.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| srfwng_mod::srfwng | 2,150 | 19,814,400 | Complete routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

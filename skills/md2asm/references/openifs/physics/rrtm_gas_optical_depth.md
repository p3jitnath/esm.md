# Complete Longwave Gas Optical Depth Contract

The [physics input](../../../../../formulations/openifs/physics/longwave_gas_absorption.md) joins the sixteen independently checked absorption bands. RRTM_GAS_OPTICAL_DEPTH calls every complete band in increasing order, then transfers optical depth to the radiation solver's array order. It changes no physical model, arithmetic or table. This extra closure is outside the remaining weather-routine count.

## Complete Children

Reuse each unchanged direct body and its original physical, table, numerical and ABI proof. The unique native entry for band $`b`$ is md2asm_rrtm_taumol followed by its band number. Use private original aliases when linking children into the parent.

| Band | Complete child contract | Address arguments |
| ---: | --- | ---: |
| 1 | [RRTM_TAUMOL1](rrtm_taumol1.md) | 27 |
| 2 | [RRTM_TAUMOL2](rrtm_taumol2.md) | 24 |
| 3 | [RRTM_TAUMOL3](rrtm_taumol3.md) | 30 |
| 4 | [RRTM_TAUMOL4](rrtm_taumol4.md) | 29 |
| 5 | [RRTM_TAUMOL5](rrtm_taumol5.md) | 32 |
| 6 | [RRTM_TAUMOL6](rrtm_taumol6.md) | 27 |
| 7 | [RRTM_TAUMOL7](rrtm_taumol7.md) | 30 |
| 8 | [RRTM_TAUMOL8](rrtm_taumol8.md) | 29 |
| 9 | [RRTM_TAUMOL9](rrtm_taumol9.md) | 32 |
| 10 | [RRTM_TAUMOL10](rrtm_taumol10.md) | 22 |
| 11 | [RRTM_TAUMOL11](rrtm_taumol11.md) | 26 |
| 12 | [RRTM_TAUMOL12](rrtm_taumol12.md) | 26 |
| 13 | [RRTM_TAUMOL13](rrtm_taumol13.md) | 31 |
| 14 | [RRTM_TAUMOL14](rrtm_taumol14.md) | 22 |
| 15 | [RRTM_TAUMOL15](rrtm_taumol15.md) | 31 |
| 16 | [RRTM_TAUMOL16](rrtm_taumol16.md) | 26 |

All bands receive the same TDIMV, selected column labels and active level count. Their temporary optical-depth output stores columns, then 140 spectral points, then supplied levels. Their Planck output is the original parent's Planck owner. Match each original named argument, including branch-unused switches, gases and ratios. No driver or original numerical helper supplies an omitted band.

## Inputs And Lossless Transfer

Let $`n`$ be last column minus first column plus one, $`H`$ active levels and $`V`$ supplied levels. Support 0 to 4096 columns and 0 to 512 active and supplied levels, with $`V\geq H`$ and positive first-column labels. Input pointers already address the first selected column. Ordinary fields store columns then supplied levels. Aerosols have sixteen band slabs. Trace gases have four species within each level. Child contracts define the complete consumed scientific domain. Layer pressure is in hectopascals, as returned by RRTM_PREPARE_GASES, despite the older parent's Pa comment.

The parent has no new floating-point calculation. For zero-based column $`c`$, spectral point $`g`$ and level $`l`$, transfer the exact eight-byte word from source position $`c+n(g+140l)`$ to destination position $`g+140(l+Vc)`$. Visit active levels, points and columns in original order. Copy only $`l<H`$. Preserve inactive level tails of both complete output owners. Every active spectral word comes from a complete child. The outputs are optical depth and Planck fractions, with native-endian FP64 encoding and no normalisation.

## Fifty-One-Address Interface

The application binary interface (ABI) defines argument addresses and preserved state. The [assembly](../../../../../src/openifs/physics/rrtm_gas_optical_depth.S) exports md2asm_rrtm_gas_optical_depth and rrtm_gas_optical_depth_. The first eight addresses use x0 through x7, and the remaining forty-three use incoming stack bytes zero through 336. Explicit-shape arrays have raw pointers without descriptors. Integer arrays use four-byte words and alignment. FP64 arrays use eight-byte words and alignment.

The original address order is TDIMV, first column, last column, active levels, optical depth, pressure, dry-air column, broadening column, four trace columns, aerosols, four main weights, foreign factor, foreign fraction, foreign index, pressure index, two temperature indices, mixture cap, water, carbon dioxide, ozone, nitrous oxide, methane, oxygen, unused carbon dioxide correction, tropopause, unused layer switch, unused low-layer switch, self factor, self fraction, self index, Planck fraction, minor index, minor scale, nitrogen minor scale, minor fraction, paired ratios for water/carbon dioxide, water/ozone, water/nitrous oxide, water/methane, nitrous oxide/carbon dioxide and ozone/carbon dioxide.

Require complete disjoint input and output capacities. Each output owner holds $`140nV`$ words. Allocate a private $`1120nV`$-byte temporary owner inside the assembly and free it after transfer. Allocate one byte for empty work, so all sixteen original child calls remain present. Use a fixed 768-byte aligned frame with child outgoing addresses at its beginning. Preserve x19 through x29, the return address, x18 and low halves of v8 through v15. The parent uses integer loads and stores for transfer. Each unchanged child requires FPCR zero, separately rounded FP64, gradual underflow and preserved signed zeros, with no fused or approximate floating-point operations.

## Focused Acceptance

Before emission, 42 protected original calls pass 6,384,000 complete returned bytes and 624,960 independent lossless coordinate relations. The reference uses the already physically checked original children, then checks every active source word at its independent destination coordinate. All 1,384,320 supplied-level tail bytes remain unchanged. Cases cover empty work, positive shifted labels, odd column counts, lower and upper regions, multiple columns and levels, signed-zero tails and both protected owner placements. Input owners are read-only. No child arithmetic or table qualification is repeated.

Require zero different full output bytes, the same coordinate and tail checks, immediate parent ABI observation and a paired original/native adapter before combined forecast acceptance. Local records are under .runtime/openifs/weather24h-longwave-optical-depth/. This work introduces no timing or forecast acceptance claim.

The native parent passes the same 42 calls, 6,384,000 complete bytes and 624,960 exact transfer relations with zero differences. Six focused calls each pass the immediate fifty-one-address ABI and paired adapter gates over 80,640 bytes. The focused verifier checks 7,840 coordinate relations and 17,920 untouched tail bytes. Actual paired calls reuse that transfer proof and the unchanged child science, then compare both complete output owners. The direct parent contains no floating-point arithmetic. Combined forecast acceptance remains pending.

Continuum interpolation retains the original bounded extrapolation beyond zero to one, with finite fractions of magnitude at most $`2^{20}`$ and valid adjacent indices. Minor interpolation remains within zero to one in the present parent domain. One new protected source, native and paired case checks the genuine Band 13 continuum range through all sixteen children. It preserves 2,240 complete output bytes and passes 280 exact coordinate relations with zero differences. The unchanged child and parent proofs are reused.

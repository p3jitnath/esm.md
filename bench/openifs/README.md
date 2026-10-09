# OpenIFS verification

Thirty-six complete public direct assembly routines are verified in OpenIFS 48.1.1. Their small checks include independent physical balances, exact output bytes, optional inputs, boundaries and buffer guards. The latest coarse forecast used own exclusive job 7207705 on nid011311, with one process, one thread, CPU 0 and local memory binding. Each routine's compact record preserves its earlier checks.

| Routine | Critical cases | Critical bytes | Forecast calls checked | Forecast bytes | Differing bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| CPSPE | 449 | 1,934,944 | 2,150 | 19,109,200 | 0 |
| GPRCP | 3,976 | 899,712 | 13,846 | 81,643,584 | 0 |
| GPPWC | 13 | 5,616 | 36,120 | 140,145,600 | 0 |
| GPRT | 73 | 82,848 | 2,150 | 23,598,400 | 0 |
| GPGRP | 46 | 36,480 | 2,150 | 15,910,000 | 0 |
| GPMKTEND | 69 | 228,888 | 2,150 | 117,957,600 | 0 |
| GPADDSLPHY | 117 | 343,216 | 2,150 | 43,636,400 | 0 |
| GP_TNDLAGADIAB_UV | 137 | 219,776 | 2,150 | 31,536,200 | 0 |
| GPGRXYB | 192 | 640,032 | 2,150 | 47,420,400 | 0 |
| GPTCO3 | 66 | 3,384 | 2,150 | 490,200 | 0 |
| GP_SPV | 122 | 58,496 | 2,150 | 18,257,800 | 0 |
| GPHPRE | 228 | 631,392 | 14,649 | 338,650,208 | 0 |
| VERDISINT, VERINT, VERDER | 163 | 1,454,464 | 21,559 | 314,924,992 | 0 |
| GPGEO | 72 | 73,336 | 4,300 | 32,559,600 | 0 |
| GPGRGEO | 201 | 608,832 | 2,150 | 32,447,800 | 0 |
| GPTF1 | 202 | 1,555,200 | 2,150 | 206,520,400 | 0 |
| GPTF2 | 106 | 982,272 | 2,150 | 206,520,400 | 0 |
| CTVTOT | 189 | 108,080 | 2,150 | 8,049,600 | 0 |
| SIGAM | 51 | 381,992 | 4,326 | 305,578,584 | 0 |
| SITNU | 265 | 146,664 | 2,176 | 155,738,840 | 0 |
| SPFILT | 264 | 4,955,320 | 25 | 3,902,600 | 0 |
| SPCIMPFPOST | 168 | 2,183,104 | 550 | 127,045,600 | 0 |
| SPCIMPFINIT | 197 | 3,973,408 | 550 | 169,488,000 | 0 |
| CPQTUV | 135 | 252,152 | 2,150 | 134,194,400 | 0 |
| CUBIDIAG | 120 | 80,344 | 8,600 | 48,228,800 | 0 |
| SIMPLICO | 151 | 275,552 | 550 | 84,691,200 | 0 |
| CALC_LIQ_OPTICS_SOCRATES | 242 | 71,328 | 317,920 | 127,168,000 | 0 |
| CALC_ICE_OPTICS_FU_SW | 331 | 94,320 | 223,175 | 83,913,800 | 0 |
| CALC_ICE_OPTICS_FU_LW | 366 | 104,928 | 223,175 | 94,626,200 | 0 |
| DELTA_EDDINGTON_SCAT_OD | 588 | 23,520 | 8,920,690 | 356,827,600 | 0 |
| SPCIMPFSOLVE | 66 | 339,392 | 25 | 1,929,200 | 0 |
| RRTM_PREPARE_GASES | 124 | 1,664,592 | 6,400 | 351,539,200 | 0 |
| LAITLI | 126 | 237,728 | 47,300 | 180,118,400 | 0 |
| SRTM_TAUMOL26 | 124 | 1,153,920 | 6,400 | 255,795,200 | 0 |

The strict-source Fortran build uses the original sources with separate multiplication and addition. The global T21 forecast has 2,048 grid points and 19 atmospheric levels. The archived test starts at 12 UTC on 15 October 2004 and saves a 24-hour forecast at 12 UTC on 16 October. Its 25 time-step visits include the initial step, with one process and one thread. All ten upstream output files at hours 0, 6, 12, 18 and 24 match a fresh strict-source Fortran run with the same pressure math and ordered vertical matrix sum byte for byte. Every captured call of the used assembly routines also matches its strict Fortran counterpart, including inactive cells. The verification drivers record and compare states but supply no missing numerical update. GPRCP and GPPWC captures preserve untouched caller bytes, so hashes identify an archived run. The input capture also records incoming output bytes for exact replay.

The vertical row groups three public bodies and their private matrix helper. Its 21,559 forecast calls count genuine VERDISINT visits; each also calls the native integral dependency. The complete capture contains 73,322 dispatcher and helper records, including separately marked reference comparisons. SIGAM and SITNU add 4,326 and 2,176 marked source-shadow vertical calls without changing the genuine count. SITNU also passes 63,869 independent ground mass-integral checks. VERDER has no genuine visit in this forecast and is accepted by the small checks only. Constant and fourth-degree polynomial profiles independently verify the actual forecast grid within 1e-11 and 1e-6, respectively.

GPRCP's 13,846 captured calls comprise 11,696 model visits and 2,150 marked reference comparisons inside CTVTOT. CTVTOT also uses the same accepted native GPRCP body for 2,150 private dependency calls. The small GPRCP verifier retains all 3,976 original cases and adds a separate read-only, protected six-field input check. The two filter stages also pass six complete histories, with twelve stage comparisons and 204 independent final identities. This forecast uses their two-time-level copy and skip branches, while the small checks cover the weighted and clearing branches.

Both current builds use unchanged-source vertical routines with a private ordered matrix sum. Each product and addition rounds separately in a fixed order. Their fresh baseline is separate from the earlier external-BLAS baseline, whose files remain archived. Other external matrix calls retain their original libraries.

Other forecast stages remain in Fortran. Their complete raw states and independent whole-forecast physical balances have not been verified. The [build record](build.json) shows that all seven locally rebuilt scientific libraries have zero audited fused or approximate arithmetic instructions, but external numerical libraries remain outside that accepted audit. The [pressure math record](pressure_math.json) now accepts separately rounded scalar exp and log, with 20,849 independent high-precision checks and no forbidden instructions. Both pressure implementations use this same frozen library. Its fresh baseline is separate from the older system-math archive. Other external functions still require an audit before accepting the whole forecast's arithmetic. The [ordered vertical matrix](../../skills/md2asm/references/openifs/dynamics/strict_matrix.md) now has matched scalar/vector timings. Complete VERINT calls improve by 3.02× for the 24-point forecast block, with every output byte preserved. Whole-forecast comparative timing remains unfinished.

GPPWC integrates both physical water fractions and signed diagnostic quantities. CPEDIA uses it for column water and moisture transport, while correction routines also integrate negative changes. The small check verifies both uses without imposing water-positivity rules on a correction field.

Each routine's compact JSON record sits beside its verifier in dynamics/, physics/ or surface/. Common records preserve [source identity](source.json), [the reference build](build.json), [pressure math](pressure_math.json) and [the mixed forecast](forecast.json). Large inputs, logs, downloaded sources and raw captures remain in ignored .runtime/openifs/.

The [routine work list](ROUTINES.md) records the exact-count task and the one-at-a-time implementation sequence.

The SIMPLICO table row retains its earlier complete-parent record. The current SPCIMPFSOLVE observer checks all 550 wave calls through their complete defined arguments and mutable fields, before and after each wave. These paired stage records contain 6,309,600 bytes, while the complete returned temporary records add 1,929,200 bytes. Both streams directly match the independently checked source-only archive.

## Reproduce the checks

Run every build and simulation through srun in your own quiet exclusive allocation. Use the existing strict-source build and preserve its original sources. The model contracts contain the complete small-check commands, frozen input locations, output encoding and physical acceptance limits. The matching compact JSON records identify source versions, actual commands and archived evidence.

For transport and cloud checks, use the [transport contract](../../skills/md2asm/references/openifs/physics/cubidiag.md) and [cloud delta-scaling contract](../../skills/md2asm/references/openifs/physics/delta_eddington_scat_od.md). Both commands compare the complete native and Fortran outputs directly, then compare Fortran with its frozen source-only stream. The [implicit solve](../../skills/md2asm/references/openifs/dynamics/spcimpfsolve.md) and [longwave gas preparation](../../skills/md2asm/references/openifs/physics/rrtm_prepare_gases.md) give their complete checks in the same form.

The [forecast record](forecast.json) identifies all accepted bodies, the exact verification libraries and the archived launch and comparison commands. Use a fresh copy of the historical T21 case, one process, one thread and local memory binding. Launch its OpenIFS executable with srun and the cray_shasta MPI option. Retain all thirty-four paired routine streams, compare each pair with cmp, and compare all ten saved files with the listed canonical baseline. Check that FPCR is zero at each numerical entry. A mismatch stops acceptance before any comparative timing. Interpolation and spectral buffers can contain unused incoming storage. Retain those complete bytes, compare fresh complete source/native pairs with the same inputs, and replay every original complete frozen input. Their active physical fields also match the earlier source run directly.

Large source inputs, shared libraries, commands and captures stay in ignored .runtime/openifs/. These local paths identify reproducible evidence for this checkout. Downloaded OpenIFS files retain their upstream licence and are not copied into Git.

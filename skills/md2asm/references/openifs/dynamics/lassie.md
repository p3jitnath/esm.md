# LASSIE Linear-Term Contract

Revision 1 implements the complete OpenIFS 48.1.1 LASSIE body from [Linear Forecast Terms](../../../../../formulations/openifs/dynamics/linear_forecast_terms.md), revision 1.0 and LF-1. [Direct assembly](../../../../../src/openifs/dynamics/lassie.S) performs every parent calculation and binds complete accepted [SITNU](sitnu.md), [SIGAM](sigam.md) and [GPRCP](gprcp.md) children. Their unchanged scientific and arithmetic proofs are reused.

## Ordered Method

FP64 stores a real value in sixty-four bits. RN means one separate operation rounded to the nearest FP64 value, with an even result at an exact halfway point. Require FPCR, the Arm floating-point control register, to equal zero. Preserve gradual underflow and signed zeros. Forbid fused arithmetic, reassociation, approximate operations, reduced precision and fast-math.

Let B be NPROMA, H be NFLEVG, a be KST and b be KPROF. Columns change fastest. A GMV field occupies B×H values, and a surface field occupies B values. One-based field index m selects offset (m−1)B×H or (m−1)B. Shift every child field address by a−1 values. The work width is b−a+1.

At time zero, call SITNU on MDIV, returning PTOD0 and PSDIV0. Call SIGAM on MTL and MSPL, returning PGAGT0L, then on MTM and MSPM, returning PGAGT0M. Use level stride B, column stride one and width b−a+1. SIGAM's ninth address points to H. If LTWOTL is false, repeat these three calls on YT9, returning all corresponding time-nine fields. Otherwise every time-nine output byte stays unchanged.

If LSPRT is true, call GPRCP with only PGFL and PR present. KGFLTYP is absent for LTWOTL true, selecting mode zero, and present with value nine otherwise. Retain its B×H gas-constant owner. Replace PTOD0 with RN(RN(Rd×PTOD0)/R) at each selected cell. If LTWOTL is false, replace PTOD9 with the same ordered operations and stored R.

If LIMPF is true, update PGAGT0L = RN(PGAGT0L−RN(f×v0)) and PGAGT0M = RN(PGAGT0M+RN(f×u0)). Apply the corresponding two time-nine updates when LTWOTL is false. Visit layers and columns in increasing order, preserving every inactive cell.

## ABI And Storage

The application binary interface, or ABI, defines addresses and preserved registers. x0 through x7 hold the first eight addresses. Incoming stack bytes zero through eighty hold the remaining eleven addresses. Integer and logical values occupy four bytes, with true equal to one. FP64 arrays align to eight bytes.

| Positions | Arguments | Complete owner |
| ---: | --- | --- |
| 1–5 | GEOMETRY, TGMV, TYPE_GFLD, TDYN, TDYNA | Read-only configuration |
| 6–7 | KST, KPROF | Read-only integers |
| 8 | PRCORI | B FP64 values |
| 9 | PGMV | B×H×NDIMGMV FP64 values |
| 10 | PGMVS | B×NDIMGMVS FP64 values |
| 11 | PGFL | B×H×NDIM FP64 values |
| 12–13 | PSDIV0, PSDIV9 | B changed FP64 values each |
| 14–15 | PTOD0, PTOD9 | B×H changed FP64 values each |
| 16–19 | PGAGT0L, PGAGT0M, PGAGT9L, PGAGT9M | B×H changed FP64 values each |

GEOMETRY reuses its accepted 17,096-byte layout, with B at 5,144 and H at 5,224. TGMV has 1,560 bytes, NDIMGMV at 992 and NDIMGMVS at 996. TDYN has 4,720 bytes, TDYNA has 456 bytes and LTWOTL is at TDYNA twenty. The new storage-only probe gives LIMPF at TDYN 4,444 and LSPRT at TDYNA sixteen.

| Field index | YT0 offset | YT9 offset |
| --- | ---: | ---: |
| MU | 1,012 | 1,116 |
| MV | 1,016 | 1,120 |
| MDIV | 1,032 | 1,188 |
| MTL | 1,024 | 1,128 |
| MTM | 1,028 | 1,132 |
| MSPL | 1,100 | 1,328 |
| MSPM | 1,104 | 1,332 |

Each offset holds an INTEGER4 field index. Child descriptors and module layouts retain their accepted contracts. For LSPRT, the supplied TYPE_GFLD matches the upstream GPRCP module configuration. Input and output owners are disjoint, and separate output owners do not overlap. The native entry is md2asm_lassie. LASSIE_SYMBOL may select its public name, and three child-name macros bind private complete children. Preserve x18, x19 through x30, the low halves of v8 through v15, FPCR and sixteen-byte stack alignment.

## Domain And Acceptance

Support 1 ≤ B ≤ 4096, 0 ≤ H ≤ 512 and 1 ≤ a ≤ B, with a−1 ≤ b ≤ B. Every consumed field index lies within its supplied complete owner. Unused previous and generic fields may hold arbitrary bits. Active values and all intermediates are finite. Require every used child allocation and domain, including positive mixture gas constants.

Canonical returned bytes contain PSDIV0, PSDIV9, PTOD0, PTOD9, PGAGT0L, PGAGT0M, PGAGT9L and PGAGT9M in that order, each as its complete little-endian FP64 owner. Preserve every unused output byte. Timing and pointer addresses are outside these bytes.

Before emission, check the unchanged parent source with accepted ordered reference children. Independently check hydrostatic gradients, pressure-weighted expansion, temperature compression, moist-air scaling and rotation balance. Cover both time schemes, spectral-temperature and Coriolis flags, conventional and finite-element vertical paths, cropped and empty columns, zero layers, signed zeros, subnormal values, odd and capacity shapes. Compare complete parent output owners with zero differences, protected bounds, read-only inputs, the immediate nineteen-address ABI and FPCR. Reuse unchanged child proofs. Actual model calls and ten saved files remain required.

The frozen original parent passed forty-six protected placements and 391,766 independent linear balances before direct emission. The complete assembly then passed the same forty-six placements, 1,104,288 returned-owner bytes and 783,532 source/native balance relations, with zero differences. Twenty-four paired smoke calls returned 20,352 identical bytes. These checks cover all three parent flags, both vertical methods, cropped and empty work, zero layers, capacity shapes, subnormal values, signed zeros, protected bounds, read-only inputs, FPCR and the nineteen-address interface. No speed improvement is claimed.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| lassie | 2,150 | 47,884,800 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

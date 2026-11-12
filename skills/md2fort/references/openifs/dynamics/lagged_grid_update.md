# Lagged Hydrostatic Grid Update Contract

Revision 1.0 implements the complete CPGLAG hydrostatic domain from [the physical input](../../../../../formulations/openifs/dynamics/lagged_grid_update.md). The frozen original is OpenIFS 48.1.1. This routine finishes a grid-point forecast update and advances no separate time step.

## Supported Settings

Require LNHDYN, LNHEE and LNHQE to be false. These switches select non-hydrostatic equations, which are outside this declared coarse hydrostatic model. Diagnostic accumulation and trajectory saving must be inactive. Specifically, LSLAG and LRSLDDH and the negation of LDCONFX must not all be true. With LSPRT true, the selected trajectory's save and lag flags must not both be true. A present PTRAJEC selects its flags. Its absence selects the OOPS flags. Guard these settings before every numerical write.

The complete supported body includes both stress selections, both time-level methods, all predictor/corrector iterations, first and last filter conditions, virtual-temperature conversion and stretched grids. No active numerical stage is omitted. The paired adapter guards and records the actual coarse forecast switches before the first numerical call. Its report supplies configuration evidence during the next already-required forecast batch.

## Ordered Calculation

FP64 is the 64-bit floating-point format. RN means a separate rounding to nearest with ties to even. Preserve signed zeros and subnormal numbers. Keep FPCR equal to zero and forbid fused operations, reassociation and approximate arithmetic.

Let C be the column capacity and L the vertical level count. The active interval starts at one and ends at E, where E is the smaller of C and KGPCOMP minus KSTGLO plus one. KSTGLO selects the grid block. An empty interval has E equal to zero.

1. If LGPSTRESS is true and either LPC_FULL is false or NCURRENT_ITER equals NSITER, add each corresponding stress component to wind with one RN addition.
2. Call the unchanged accepted [GPTF1 stage](time_filter.md). Its filter flag is NCURRENT_ITER equal to zero. Its last-step flag is NSTEP greater than or equal to NSTOP. The numerical child completes every selected copy, weighted filter and clear.
3. Add the three PB2 level-column blocks to the future wind and temperature fields, each with one RN addition. Add the selected PB2 surface column to future log-pressure with one RN addition.
4. If LSPRT is true, call the complete accepted [GPRCP mixture stage](gprcp.md), selecting MP1 with KGFLTYP equal to one and the caller's actual NDIM1 capacity. Compute RN of one divided by RD. For every active temperature, compute RN of R times temperature, then RN of that result times the rounded reciprocal.
5. Form the source's separately rounded absolute difference between RSTRET and one. If it exceeds RN of 100 times the smallest positive normal FP64 number, divide each active wind component by its positive map factor with one RN division.

The unchanged filter and mixture physics proofs remain authoritative. Independent real-arithmetic parent relations check the new increment, gas-constant conversion and map division with a frozen error budget of 24 times FP64 machine epsilon times the sum of term magnitudes, plus 16 smallest subnormal units. Exact owner comparisons independently require zero differing bytes.

## Storage And Bounds

Require 1 to 512 columns and zero to 512 levels. Each complete owner has at most 4096 fields or buffer columns. Counts, pitches and field indices must fit signed 64-bit addressing. Use Fortran column order with eight-byte alignment. Each future air field has a complete C times L plane. The surface field has C entries. The three PB2 field blocks have L columns each, and its pressure column has one. Only active columns change outside the filter's complete source-defined clear.

All selected field indices fit their complete owners. Inputs used by arithmetic and all intermediates are finite. Constituent fractions are nonnegative with sum at most one. RD and the grid map factors are positive. Untouched and copied fields retain arbitrary input bits under the accepted child contract.

The five returned owners are PGMV, PGMVS, PGMVT1, PGMVT1S and PGFL. Compare every byte of each complete owner, including inactive and unused fields. PB2, PGFLT1, both diagnostic tendency arrays, optional stress and all configuration objects are read-only. The returned owners and read-only numerical inputs do not overlap. An unused optional owner can be absent. Diagnostic and trajectory owners are not accessed under this contract.

Reuse the accepted geometry and TGMV layouts. A narrow storage-only GNU Fortran 12.3 probe establishes the new members. Dynamics occupies 13,232 bytes. Its scalar fields LNHEE, LNHQE, LNHDYN, LSPRT, LTWOTL, LSLAG and LPC_FULL lie at offsets 0, 4, 8, 16, 20, 24 and 336. NSITER, NCURRENT_ITER and LGPSTRESS lie at 3032, 3036 and 4996. NFLDSLB2 and the U, V, T and surface buffer indices lie at 9184, 9200, 9204, 9208 and 9220.

The future field map begins at TGMV byte 1360. Its NDIM, NDIMS, MU, MV, MT and MSP offsets within TGMV are 1360, 1364, 1368, 1372, 1376 and 1400. Configuration's NSTOP is at 1359324. Diagnostic LRSLDDH is at 616. Geometry's RSTRET is at 7512 and its genuine rank-one YRGSGEOM descriptor is at 8472. Each element occupies 1472 bytes and contains its genuine GM descriptor at 704. Honor the descriptor offset, lower bounds and source integer indices. Require contiguous descriptors and valid active extents.

## AArch64 Interface

The application binary interface, or ABI, defines argument addresses and saved registers. Export md2asm_lagged_grid_update and the configurable ORIGINAL_SYMBOL, which defaults to cpglag_. All twenty-one arguments are addresses.

Registers x0 through x7 hold geometry, TGMV, diagnostics, configuration, dynamics, KGPCOMP, KSTGLO and LDCONFX. The incoming stack holds PGMV, PGMVS, PB2, PGFLT1, PGMVT1, PGMVT1S, PGFL, PGMVTNDSL, PGFLTNDSL, YDDDH, optional stress, optional trajectory and optional OOPS trajectory in that order, at consecutive eight-byte offsets. Integer and logical values occupy four bytes. A null optional address means absent.

Keep the stack aligned to sixteen bytes and preserve x19 through x29 and the link register. Do not use x18. Use caller-owned floating-point registers. The fixed frame is 512 bytes. Virtual-temperature conversion owns a private C times L FP64 mixture array and 64 outgoing-call bytes, rounded to sixteen-byte stack alignment. Its largest private allocation is 2,097,216 bytes. Accepted child frames add their already documented bounded stack use.

## Verification And Provenance

Before direct emission, the unchanged source passed 144 protected cases, 12,533,440 complete returned owner bytes and 148,168 independent parent relations. Read-only protection covered 238,994,752 input and metadata bytes. Cases cover all 128 supported branch combinations, zero levels, empty and partial column intervals, two grid blocks, map descriptors, signed zeros and subnormals. Reuse accepted child scientific and arithmetic proofs.

Build direct source with an assembler and linker and uniquely bind the unchanged accepted children. The original complete parent remains a shadow comparison control. The driver supplies no missing numerical stage. Compare complete returned owners, preserve all inputs and check immediate saved-register and FPCR obligations. Record actual model calls and saved forecast-file comparisons before accepting the replacement. The native protected gate matched all 144 calls and 12,533,440 returned bytes. Five focused paired calls matched 1,232,360 bytes and supplied 8,425 independent parent relations. Six unsupported-setting cases rejected with a trap before writes to 25,200 read-only owner bytes. The direct parent contains no fused or approximate floating-point instruction. No performance claim is made.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| cpglag | 2,150 | 229,104,000 | Complete routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

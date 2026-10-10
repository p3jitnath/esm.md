# SRTM_TAUMOL21 Solver Contract

Revision 1.0 is the pre-generation record of the original numerical expressions, complete storage and Arm interface for OpenIFS Band 21. Its frozen source has SHA256 `dd7ca6046d0c9ff7a6e6515667c053b88250e17be5019f8b395782eb2084a39c`. The original physics, direct assembly and forecast-call comparisons now pass within this contract, as recorded in the [Band 21 evidence](../../../../../bench/openifs/physics/srtm_taumol21.md). Only this status paragraph changes from the frozen record.

## Method and source

The physical input is the [simple Band 21 formulation](../../../../../formulations/openifs/physics/shortwave_band21.md). The retained numerical method interpolates the original reduced absorption tables in pressure, temperature and gas mixture. The unchanged SETCOEF routine supplies the molecular columns, interpolation factors and indices. This leaf then calculates absorption, molecular scattering and selected solar reference flux. It contains no time integrator or missing numerical stage.

Keep the original tables after KGB21, before CMB21, after CMB21 and after INIT. Later immutable owners must equal the full after-INIT bytes directly. Use the accepted original STRRAT, RAYL, LAYREFFR and caller cap bits. Complete original table and leaf science now pass. The original reduced table strides are NSPA(21) = 9 and NSPB(21) = 5.

`RN(a op b)` means one binary64 operation rounded to nearest, with a halfway result rounded to the even significand. Binary64 stores a real number in 64 bits. Require Arm FPCR = 0, gradual underflow and preserved signed zeros. Each displayed operation rounds separately. Multiplication and addition remain separate, division is exact to the required binary64 rounding, and the expressions keep their stated dependencies.

## Shape and original order

Let B = KFDIA − KIDIA + 1 be the complete declared first extent, H = KLEV the processed layer count and V = YDDIMV%NFLEVG the complete vertical extent. Columns vary fastest. Let c, l and g below be one-based column, layer and spectral-point indices. The original YOESRTM parameter NG21 is 10, while the coefficient and output allocations store 16 points.

Initialise one solar-layer selector I(c) = LAYTROP(c) for each complete column. Run the whole lower pass before the whole upper pass. Each pass visits layers 1 through H, then columns KIDIA through KFDIA, then active spectral points 1 through 10, in increasing order. A daylight column has PRMU0(c) > 0. A lower layer has l ≤ LAYTROP(c). An upper layer has l ≥ LAYTROP(c) + 1.

Before processing each daylight lower cell, if JP(c,l) < LAYREFFR and JP(c,l+1) ≥ LAYREFFR, set I(c) = MIN(l+1,LAYTROP(c)). The next JP row must be genuine declared storage even when a source compiler evaluates both sides of the condition. Each selector belongs to its own column. Later crossings and solar writes follow the original order.

## Ordered mixture and table addresses

Write w = COLH2O, d = COLCO2, m = COLMOL, r = STRRAT and pmax = ONEMINUS(c). Molecular columns use the original rounded SETCOEF scale, approximately $`10^{20}`$ molecules/cm² per source unit. The cap is dimensionless and strictly below one.

```math
v=\operatorname{RN}(r d),\quad
Q=\operatorname{RN}(w+v),\quad
p=\operatorname{RN}(w/Q),\quad
p=\begin{cases}p&p<p_{\max}\\p_{\max}&p\ge p_{\max}.\end{cases}
\tag{SW21-C1}
```

For the lower branch use mixture spacing b = 8, table stride s = 9, pressure origin a = 1 and absorption table ABSA. For the upper branch use b = 4, s = 5, a = 13 and ABSB.

```math
x=\operatorname{RN}(bp),\qquad
j=1+\operatorname{INT}(x),\qquad f=\operatorname{MOD}(x,1).
\tag{SW21-C2}
```

`INT` truncates towards zero. The accepted active domain has 0 ≤ x < b. The last supported mixture cell therefore has j = 8 below and j = 4 above. `MOD` retains the source bits. When the integer part is zero, retain x directly, including signed zero. Otherwise its subtraction from x is exact in this domain.

The supplied pressure and temperature indices are JP, JT and JT1. The following addresses count rows from one.

```math
I_0=[5(JP-a)+(JT-1)]s+j,\qquad
I_1=[5(JP-a+1)+(JT1-1)]s+j.
\tag{SW21-C3}
```

The four pressure and temperature weights use mathematical corner order FAC00, FAC10, FAC01, FAC11. This is original argument order 5, 7, 6, 8. Let T be the selected table. Preserve each four-product sum from left to right, with the coefficient as the first multiplication operand.

```math
\begin{aligned}
A_0&=\operatorname{RN}(T(I_0,g)FAC00),\\
A_1&=\operatorname{RN}(A_0+\operatorname{RN}(T(I_0+s,g)FAC10)),\\
A_2&=\operatorname{RN}(A_1+\operatorname{RN}(T(I_1,g)FAC01)),\\
L&=\operatorname{RN}(A_2+\operatorname{RN}(T(I_1+s,g)FAC11)).
\end{aligned}
\tag{SW21-C4}
```

Form U by the same four operations with one added to every table row. Then blend the two adjacent mixture results and multiply by the combined column.

```math
z=\operatorname{RN}(1-f),\quad
L'=\operatorname{RN}(zL),\quad U'=\operatorname{RN}(fU),\quad
G=\operatorname{RN}(Q\operatorname{RN}(L'+U')).
\tag{SW21-C5}
```

## Continuum, scattering and solar output

Let i_s = INDSELF and i_f = INDFOR. SELFREFC and FORREFC are the original reduced continuum tables. fs = SELFFRAC and ff = FORFRAC are their dimensionless temperature fractions.

```math
\begin{aligned}
S&=\operatorname{RN}(SELFREFC(i_s,g)+\operatorname{RN}(fs\operatorname{RN}(SELFREFC(i_s+1,g)-SELFREFC(i_s,g)))),\\
F&=\operatorname{RN}(FORREFC(i_f,g)+\operatorname{RN}(ff\operatorname{RN}(FORREFC(i_f+1,g)-FORREFC(i_f,g)))).
\end{aligned}
\tag{SW21-C6}
```

The lower branch uses self and foreign density factors. The upper branch reads only the foreign fields and multiplies water by its factor first. The optical depths have no unit.

```math
\begin{aligned}
C_{\mathrm{low}}&=\operatorname{RN}(w\operatorname{RN}(\operatorname{RN}(SELFFAC\,S)+\operatorname{RN}(FORFAC\,F))),\\
C_{\mathrm{high}}&=\operatorname{RN}(\operatorname{RN}(w\,FORFAC)F),\\
TAUG&=\operatorname{RN}(G+C),\qquad
TAUR=\operatorname{RN}(m\,RAYL).
\end{aligned}
\tag{SW21-C7}
```

Compute the Rayleigh product once per cell and copy its bits to all ten active points. During the lower pass only, when l = I(c), write the solar flux below. The original SFLUXREFC is in W/m² and has nine mixture columns.

```math
d_\odot=\operatorname{RN}(SFLUXREFC(g,j+1)-SFLUXREFC(g,j)),\quad
SFLUXZEN=\operatorname{RN}(SFLUXREFC(g,j)+\operatorname{RN}(f d_\odot)).
\tag{SW21-C8}
```

Preserve the last actual solar write in each column. An unwritten slot keeps its incoming bits. The upper branch reads no self-continuum field and writes no solar slot. Actual SETCOEF extrapolation retains its signed fractions. The separate bounded critical corpus additionally requires nonnegative active absorption and scattering, without adding that restriction to the general forecast.

## Complete storage and aliases

All real elements are binary64 and all integer elements are signed int32. The interface has 26 ordinary pointers and no hidden argument. The following positions count from one.

| Positions | Complete storage | Mutation |
| --- | --- | --- |
| 1 | Original TDIMV object, 32 bytes | Read-only, including 28 unused bytes |
| 2–4 | KIDIA, KFDIA, KLEV, four bytes each | Read-only |
| 5–8 | FAC00, FAC01, FAC10, FAC11, B × V real elements each | Read-only |
| 9–11 | JP, JT, JT1, B × V integer elements each | Read-only |
| 12 | ONEMINUS, B real elements | Read-only |
| 13–15 | COLH2O, COLCO2, COLMOL, B × V real elements each | Read-only |
| 16 | LAYTROP, B integer elements | Read-only |
| 17–18 | SELFFAC, SELFFRAC, B × V real elements each | Read-only |
| 19 | INDSELF, B × V integer elements | Read-only |
| 20–21 | FORFAC, FORFRAC, B × V real elements each | Read-only |
| 22 | INDFOR, B × V integer elements | Read-only |
| 23 | SFLUXZEN, B × 16 real elements | Source-defined active solar writes |
| 24–25 | TAUG, TAUR, B × V × 16 real elements each | Daylight, processed layers and ten active points |
| 26 | PRMU0, B real elements | Read-only, with original owner alias |

For zero-based indices q, k and h, a plane element is q + Bk and an optical element is q + B(k + Vh). Its byte offset is this index times the element width. This layout applies to the complete declared storage, including vertical tails and all sixteen spectral points. Any larger containing caller owner also remains in the accepted incoming and returned byte comparison.

| Leaf table | Complete shape | Bytes |
| --- | --- | ---: |
| ABSA, sharing reduced KAC | 585 × 16 | 74,880 |
| ABSB, sharing reduced KBC | 1175 × 16 | 150,400 |
| SELFREFC | 10 × 16 | 1,280 |
| FORREFC | 4 × 16 | 512 |
| SFLUXREFC | 16 × 9 | 1,152 |
| RAYL, STRRAT | One real each | 16 |
| LAYREFFR | One integer | 4 |

The shared COMMON owners are yoesrta21.eq.1_ for KAC/ABSA and yoesrta21.eq.0_ for KBC/ABSB. Use the original global storage and aliases. The complete capture and native corpus preserve all 31 immutable owners, fields 1001 through 1031, totalling 688,196 bytes. This includes full grouping arrays, original unreduced tables and pressure/temperature grids beyond this leaf table.

## Bounds and Arm interface

The declared shape range is 0 ≤ B ≤ 4096, 0 ≤ H ≤ V ≤ 512 and KIDIA ≥ 1. Before either numerical body, prove complete capacities in nonoverflowing address arithmetic. Empty shapes perform no numerical cell access. Every daylight lower cell requires l+1 ≤ V. The live forecast has B = 8 and H = V = 19, so its daylight TROP must leave the real next JP row available. No sentinel row or larger guessed allocation supplies this read.

Require finite nonnegative water, carbon dioxide and molecular columns, a finite positive combined absorber, and a finite cap strictly between zero and one. Qualify every selected table address and neighbour. The bounded native corpus uses lower JP 1–12, upper JP 13–58, JT/JT1 1–4, self index 1–9 and foreign index 1–3. The complete original forecast passes its separate signed-fraction checks. Preserve those signed extrapolation fractions, rather than imposing the narrower bounded critical-case conditions on every forecast input.

Every nonempty integer or real allocation has four-byte or eight-byte alignment. Freeze the genuine original aliases and containing-owner capacities. Read-only inputs may overlap, while the three output allocations are disjoint from each other, consumed inputs and immutable tables. Preserve all incoming night cells, vertical tails, six unused spectral points, unwritten solar slots, signed zeros and NaN payloads in unconsumed storage. Compare full returned arguments and containing owners directly.

The Arm application binary interface, or ABI, defines where arguments and preserved registers live. Pointers 1–8 arrive in x0–x7. Pointer j from 9 through 26 arrives at entry-SP offset 8(j−9). Keep SP aligned to 16 bytes, preserve x19–x29, x30 when making calls, and the low 64 bits of v8–v15. Leave reserved x18 unused. Restore every stack allocation before return. Preserve FPCR and do not clear the observed FPSR status. Exact FPSR agreement must be verified against the original path.

Preserve the original profiling interface even for empty shapes. On entry, read the original LOGICAL(kind=4) LHOOK. When it is true, call __yomhook_MOD_dr_hook_default8 with x0 pointing to the exact 13 bytes SRTM_TAUMOL21, x1 pointing to INTEGER(kind=4) zero, x2 pointing to one private aligned eight-byte handle and x3 holding unsigned 64-bit length 13. The entry hook can disable LHOOK, so reload its post-entry value and retain that return decision. A permitted return call uses INTEGER(kind=4) one, the same name, full-width length and unchanged handle. The critical standalone replay temporarily disables and restores this hook. The complete original linked ABI qualification passes.

## Acceptance and generation

The complete original capture passes all 51,206 events, 6,400 leaf calls, 6,400 SETCOEF calls and 17,830 independent table relations. It checks 972,800 processed layer-columns, 19,456,000 optical-depth words and 512,000 solar-source writes, with the original rounded results and every untouched bit retained. All ten saved forecast files match across 618,140 bytes.

The protected original checkpoint passes 76 input records, including 72 valid cases at both ends of guarded allocations and four pre-call rejections. Its 144 original calls and 148 returned records pass full buffers, unchanged tables, ordered arithmetic and independent physical relations. It checks 131,724 complete returned argument bytes, 3,440 optical words and 1,000 solar writes. Complete original tables occupy 688,196 bytes. Low/high placement comparisons, source-output comparisons and untouched-byte comparisons all have zero differences. These checks include every supported mixture interval, actual caps, table corners, continuum endpoints, repeated solar crossings, night columns, empty shapes, shifted column bounds and padded vertical storage.

The accepted complete-science record is 2,292 bytes, SHA256 e4eaecae5323c03f15f737d6f95b01ab978bdc02983a0f51eca1d8390def41fa. The accepted critical record is 104,087 bytes, SHA256 431e61e3f08fcaf53ffb159256bc697175a78aaed43a75fa87953c1aa403662c. The critical input and original return files are 758,820 and 833,008 bytes. Their SHA256 identifiers are 017a26be542edd42ebcf4313938099d2edfd592b34d184832471085d934261cf and b38b051379b16649b45c7e059f6f29f5fc72d9e0e2d81f7d87c59b4b12de70c7. Full evidence remains in ignored runtime.

md2asm now emits the replacement directly as AArch64 assembly from this frozen formulation and contract. Build it with an assembler and linker. Keep the original driver and scientific companion separate. Verify protected original-versus-assembly replay and the full genuine forecast before any timing. Acceptance requires zero differing bytes, with hashes used only to identify archived files. Numerical constants, supported shapes, hook ABI, implementation revision and toolchain commands must be sealed before generation.

The unchanged original scientific source is srtm_taumol21.F90, 9,330 bytes, SHA256 b9374f8f4b17bd41d76f8006828a69a04b5c33c1b41d1483333b84b502964f24. The canonical strict library is 166,739,496 bytes, SHA256 8e4966877c735976f1e9356bc551294bbfc15c565ecdf1dc7db4cf814012b07b. The original standalone driver used GNU C 12.3 with -O2 -mcpu=neoverse-v2 -fno-fast-math -ffp-contract=off -fno-tree-vectorize. Emit AArch64 for the declared Arm target using scalar FP64 or bounded supported vector instructions, with no numerical helper, compiler-generated solver assembly or intermediate representation. Keep actual assembler, linker, ABI, protected replay and forecast commands with the implementation record.

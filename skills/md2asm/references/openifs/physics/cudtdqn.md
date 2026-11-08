# CUDTDQN Numerical Contract

[CUDTDQN assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/cudtdqn.S) implements [Convective Heat and Moisture](../../../../../formulations/openifs/physics/convective_heat_moisture.md), revision 1, equations H1–H3. This entry replaces the original exported routine `cudtdqn_`. It retains every admitted calculation and output bit.

## Supported Inputs

The complete normal-physics branch requires `TEPHLI%LPHYLIN=false`. The direct and paired live entries reject a true flag. The tangent-linear branch uses TANH and remains outside this contract. The mixing parameter `theta=RMFSOLTQ` lies from zero to one. Zero selects the explicit update. A positive value selects the implicit update. Both ice-energy correction settings and all cloud-scheme and downdraft branches are included.

Columns are contiguous, with the column index changing fastest. The leading dimension `KLON` is positive and the layer count `KLEV` is at least one. The selected one-based interval may be empty. Otherwise its indices lie within the leading dimension. `KTOPM2` lies from 2 through `KLEV+1`. Updated implicit cloud columns require `KCTOP>=KTOPM2+1` and `KCTOP<=KLEV+2`. Used downdraft indices describe the supplied column. Layer pressure thickness is positive. Implicit full-level pressure differences and saturation humidity are also positive. Used physical values are finite.

## GNU Fortran Interface

The AArch64 application binary interface, or ABI, defines how addresses and registers pass between routines. This entry receives 44 addresses. Arguments 1–8 use `x0–x7`. Arguments 9–44 use consecutive eight-byte slots in the caller's stack. Integers and logical values occupy four bytes. Real values use FP64, which stores each value in eight bytes. Arrays need eight-byte alignment and disjoint owners. There are no array descriptors or hidden lengths.

| Arguments | Meaning | Storage |
| --- | --- | --- |
| 1–4 | `YDEPHLI,YDPHNC,YDECUMF,YDEPHY` | Plain objects of 120, 100, 344 and 448 bytes |
| 5–9 | `KIDIA,KFDIA,KLON,KLEV,KTOPM2` | Integer scalars |
| 10–13 | `KTYPE,KCTOP,KCBOT,KDTOP` | Integer column vectors |
| 14–16 | `LDCUM,LDDRAF,LSCVFLAG` | Logical column vectors |
| 17 | `PTSPHY` | Real scalar in seconds |
| 18–21 | `PAPH,PAP,PGEOH,PGEO` | Face pressure, layer pressure, face and layer geopotential |
| 22–26 | `PTEN,PTENH,PQEN,PQENH,PQSEN` | Layer matrices |
| 27–30 | `PLGLAC,PLUDE,PLUDELI,PSNDE` | Layer matrices, last two have two phase planes |
| 31–39 | `PMFU,PMFD,PMFUS,PMFDS,PMFUQ,PMFDQ,PMFUL,PDMFUP,PDPMEL` | Layer matrices |
| 40–41 | `PMFLXR,PMFLXS` | Face matrices |
| 42–44 | `PTENT,PTENQ,PENTH` | Layer output matrices |

A layer matrix contains `KLON*KLEV` values. A face matrix contains `KLON*(KLEV+1)` values. A phase matrix contains two complete layer planes. Plain-object offsets were measured with a metadata-only Fortran probe. TEPHLI has `LPHYLIN@4`. TPHNC has `LEPCLD2@48` and `LENCLD2@52`. TEPHY has `LEPCLD@68`. TECUMF has `RMFSOLTQ@80`, `RMFSOLRHS@96`, `RMFADVW@104`, `RMFADVWDD@112` and `LMFENTHCONS@284`. Source-defined thermodynamic scalars are read from the original module globals.

The entry preserves `x19–x29`, the low 64 bits of `v8–v15`, stack alignment and the floating-point control register. It does not use `x18`. Its fixed frame is 720 bytes. The aligned private arena requires `60*KLON*KLEV+8*KLON+16` bytes before alignment and must fit within one MiB. It contains seven real matrices, one logical matrix and one column vector. Only the complete accepted [CUBIDIAG](cubidiag.md) body is called. A private symbol binds that unchanged child.

## Complete Ordered Update

Set `ZIMP=1-theta`, `inverse_dt=1/dt` and `inverse_cp=1/cp` as separate rounded operations. Clear selected PENTH cells. Clear selected PLUDE and both PLUDELI planes when all three cloud-scheme flags are false. Normal physics leaves LDCUM unchanged. Copy all four supplied energy and humidity transport matrices for active columns and compute `g/(p_bottom-p_top)` for each layer.

When theta is positive, recompute the selected half-level environmental energy and humidity from the supplied interpolation ratios. Preserve the written order of the temperature products, geopotential additions, humidity products and divisions. Subtract updraft mass transport times that environmental value. Apply the same subtraction to a downdraft only where its flag and top permit it.

Evaluate H3 with a bounded temperature, a rounded multiplication by the supplied inverse transition interval, a rounded square, a minimum with one, and two separately rounded latent-heat products. The ice-energy correction sums layers in increasing order. Its interior term is `Lm*(glac-melt)-L*(liquid_next-liquid)+L2*precip_delta`. Its bottom term is `Lm*(glac-melt)+L*liquid+L2*precip_delta`. Here L2 retains H3 and L becomes Lv for a flagged liquid cloud when conservation is enabled. From the total I, subtract bottom rain times Lv and bottom snow times Ls to obtain I2. Set `c=I2/(I+0.001)` only when `abs(I)>0.1`. Otherwise set c to positive zero. Also set c to positive zero when its absolute value exceeds two.

Use the ordered transport differences and condensate terms in H1 and H2. The interior heat source adds latent correction times `1-c`, liquid detrainment and rain times Lv, then ice detrainment and snow times Ls. Its vapour source adds the liquid-transport difference and subtracts total detrainment, precipitation creation, rain detrainment and snow detrainment in that order. The bottom uses the complete source-specific closing expressions. Each heat source is multiplied by the rounded `(g/dp)*inverse_cp`. Each vapour source is multiplied by the rounded `g/dp`. Add these to the input tendencies for an explicit update.

For an implicit update, clear the complete lower matrix and logical mask and set the complete diagonal to one. Set masked rows from the cloud top through the bottom. Form `z=(theta*(g/dp))*dt`, `A=-z*(up+down)` and `B=1+z*(up_next+down_next)`, with B equal to one at the bottom. The subsidence factor uses the ordered gravity product, full-level pressure division, time-step product and type-dependent advection factor. Apply it to the previous-minus-current humidity or to the corresponding temperature difference plus geopotential difference times inverse_cp. Set each right-hand side to `((source+old_tendency*RMFSOLRHS)*dt+environment)-subsidence`.

Call complete CUBIDIAG separately for temperature and humidity. Its first cloud row omits the lower term and every diagonal retains the rounded 1e-35 regulariser. Set each masked tendency to `old*(1-RMFSOLRHS)+(solution-environment)*inverse_dt`. Unmasked tendencies retain their input bytes.

## Output and Diagnostic Limit

Canonical output owners are LDCUM, PLUDE, both PLUDELI planes, both PSNDE planes, PTENT, PTENQ and PENTH, in that order. Each complete owner is compared as little-endian bytes, including inactive cells and signed zeros. All other owners remain unchanged.

The original PENTH diagnostic has inconsistent units between its numerical branches. The explicit branch stores `temperature_source*cp` in J kg⁻¹ s⁻¹. The implicit branch stores `(temperature_solution-temperature_environment)*inverse_dt` in K s⁻¹. CUMASTRN labels this field as energy and forwards it unchanged. Its caller CUCALLN supplies the local ZENTHD matrix and never reads it after that call. This implementation preserves the diagnostic bytes and does not claim that the implicit value is an energy tendency. Independent acceptance applies to the heat and water budgets of PTENT and PTENQ.

## Direct Generation and Verification

The LLM emitted the complete body directly as AArch64 source from the formulation, ordered contract and original interface. An assembler and linker build it. High-level code supplies only verification, inputs and the genuine original comparison. The driver supplies no missing numerical stage. FP64 uses round-to-nearest with ties to even, gradual underflow and preserved signed zeros. The body has no fused arithmetic, reassociation, approximate reciprocal or approximate square root.

Critical verification passed 72 protected buffer placements, 15 584 independent 100-digit heat and moisture relations and 1 124 736 complete source/native output bytes with zero differing bytes. Cases cover explicit and implicit updates, both conservation flags, diagnostic cloud clearing, liquid and ice transition endpoints, downdraft flags, all three convection types, clear columns, empty and cropped intervals, and one or 137 layers. The immediate 44-argument observer checks preserved registers and FPCR. The paired smoke passed 20 genuine calls, 46 560 complete output bytes and 112 independent pressure-weighted column balances, with ten calls for each update branch.  Work ran in exclusive job 7240564 on nid010555, CPU 32, with local memory placement.

## Positive Optimisation Lesson

Reuse the four flux matrices for the lower coefficient, diagonal and two solved states only after all heat and moisture source terms are complete. Keep pressure weights and both source matrices in the same private arena. Re-evaluate the small bounded latent-heat expression from unchanged inputs where needed, preserving every rounding point while avoiding two full latent-heat matrices. Reuse the accepted CUBIDIAG body and its evidence when its instructions and contract remain unchanged.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 observed 2,150 genuine calls. The same-input comparison covers 62,952,000 complete returned owner bytes with zero differences. Independent critical physics, unchanged inputs and the declared interface checks passed. All ten saved forecast files also match across 618,140 bytes. This result covers the declared routine domain and saved files. Independent whole-forecast physics, whole-process byte identity and comparative speed remain unproved.

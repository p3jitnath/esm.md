# Plant Photosynthesis Contract, Revision 2

This contract defines the complete direct AArch64 FARQUHAR implementation, md2asm_farquhar, for the [carbon uptake formulation](../../../../../formulations/openifs/surface/carbon_uptake_by_plant_leaves.md), revision 2. The [main assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/plant_photosynthesis.S) calculates the leaf state and all four canopy returns. Its [C4 arithmetic](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/plant_photosynthesis_c4.inc.S), [physical-root helper](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/c4_physical_interval_roots.S) and [storage definitions](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/plant_photosynthesis_slots.inc.S) supply the complete changed C4 calculation. The original C3, dark-respiration and canopy arithmetic remains unchanged; the corrected C4 source control solves both physical minimum equations before selecting a root.

The supported controls enable temperature acclimation and disable monthly acclimation, CO₂ downregulation and skin-temperature selection. Leaf temperature is air temperature; growth temperature is soil temperature minus the supplied RTP_00. Twenty vegetation rows and two pathways use twenty leaf intervals and twenty-one edges. The original initialization resets the whole pathway array to C3 on each requested-column iteration, so only the final requested column can retain C4. Preserve that order. Active C4 requires positive capacities in the qualified parameter tables; exact zero capacity and arbitrary new parameter sets are outside this scope.

## Common leaf and canopy calculation

Radiation uses W/m², pressure Pa, temperatures K, humidity kg/kg and atmospheric CO₂ kgCO₂/kgAir. Leaf carbon rates use µmol CO₂/(m² leaf·s). Carbon concentrations use ppm, numerically equal to µbar in the model's near-one-bar approximation. Gas conductance uses mol/(m² leaf·s·bar). Canopy carbon rates use kg CO₂/(m² ground·s), and canopy water conductance uses m/s.

Set the four outputs to positive zero only in the requested range. Convert pressure to hPa as pressure/100, and CO₂ to ppm as ((mass_ratio*1e6)*RMAIR)/RMCO2. A zero vegetation type uses dummy table row one. Assimilation requires land, positive vegetation, leaf area greater than 0.01, radiation and soil-water availability greater than the original single-precision epsilon 2^-23, and growth temperature strictly between RTPHOTO_MIN and RTPHOTO_MAX. Land vegetation outside that active condition retains the source dark calculation.

For edge index j=0 through 20, compute L(j)=(RLAIMAX*(EXP(j*RLAI_LEVEL_DEPTH)-1))/(EXP(20*RLAI_LEVEL_DEPTH)-1). For interval j=0 through 19, compute light(j)=EXP((-REXT_COEFF)*L(j)) and width(j)=L(j+1)-L(j). Include gross uptake and pore conductance only when L(j)<=supplied_leaf_area. Sum respiration over all twenty reference intervals, as the source does; its grid therefore differs from the assimilation cutoff.

Form vapour-pressure deficit VPD=((qs*pressure_hPa)/(RTETENS_1+qs*RTETENS_2)-(qa*pressure_hPa)/(RTETENS_1+qa*RTETENS_2))/10 in kPa. Water response is MIN(1,soil_water*RHUMREL(row,path)). Nitrogen response is 1-RN_VERT_ATT*(1-light). Respiration is (((VCMAX25*nitrogen)*0.01)*temperature_response)*MAX(1-RSTRESS_VCMAX,water_response). Temperature responses use the supplied 298 K reference and the accepted [response equations](../../../../../formulations/openifs/surface/plant_temperature_response.md). A separate [private-symbol assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/surface/plant_photosynthesis_temperature_response.S) preserves x18 around EXP and checks the already qualified helper input ranges.

For each pathway, bounded_growth=MAX(11,MIN(growth,35)). Electron capacity is ((RARJV(path)+RBRJV(path)*bounded_growth)*VCMAX25)*modified_temperature_response, with entropy RASJ(path)+RBSJ(path)*bounded_growth. Carboxylation is VCMAX25*modified_temperature_response, with entropy RASV(path)+RBSV(path)*bounded_growth. Read the pathway-specific deactivation and activation values. Each leaf level retains nitrogen attenuation, absorbed photons and the original electron-transport quadratic. The humidity response retains the original default-real conversion and clipping before widening to FP64. Boundary conductance retains its supplied reference and unit conversion.

For a leaf level, carboxylation capacity is (column_carboxylation*nitrogen)*MAX(1-RSTRESS_VCMAX,water_response), and light capacity is (column_electron_capacity*nitrogen)*the same stress factor. Absorbed photons are ((((radiation*RW_TO_MOL)*RRG_TO_PAR)*REXT_COEFF)*light). Let I be absorbed photons, Jmax the level electron capacity, alpha RALPHA_LL and theta RTHETA. Compute J=(alpha*I+Jmax-SQRT((alpha*I+Jmax)**2-((((4*theta)*Jmax)*alpha)*I)))/(2*theta). Boundary water conductance is (((RGB_REF*44.6)*(RTP_00/air_temperature))*(pressure_hPa/RPB_STD)); divide it by RRATIO_H2O_TO_CO2 for Gb. Gamma=RGAMMA_STAR25*ordinary_temperature_response for C3, while C4 uses gamma=0.5/Sco.

The original humidity clipping uses a default-real single-precision epsilon. Let clipped=MIN(1-2^-23,MAX(2^-23,RA1-RB1*VPD)). Compute Phi=(1/(1/clipped-1))*MAX(1-RSTRESS_GS,water_response), retaining the source kinds before FP64 widening.

## Retained C3 calculation

C3 uses pathway one. Its internal tissue conductance is (RGM25*modified_temperature_response)*MAX(1-RSTRESS_GM,water_response). Residual pore conductance is RG0*MAX(1-RSTRESS_GS,water_response). Temperature-dependent Kmc, Kmo and Sco retain their original products. Let Gamma be the C3 compensation concentration, Ca air CO₂, Rd leaf respiration, G0 residual pore conductance, Gm internal tissue conductance, Gb boundary conductance and Phi the humidity-and-water response.

Evaluate enzyme limitation first, with X1=leaf_carboxylation_capacity and X2=Kmc*(1+((2*Gamma)*Sco)/Kmo), then light limitation with X1=J/4 and X2=2*Gamma. The following expressions retain source parentheses; every individual operation rounds separately, including repeated subexpressions.

```text
a = G0*(X2+Gamma)+(G0/Gm+Phi)*(X1-Rd)
b = Ca*(X1-Rd)-Gamma*X1-Rd*X2
c = Ca+X2+(1/Gm+1/Gb)*(X1-Rd)
d = X2+Gamma+(X1-Rd)/Gm
m = 1/Gm+(G0/Gm+Phi)*(1/Gm+1/Gb)
p = -(d+(X1-Rd)/Gm+a*(1/Gm+1/Gb)+(G0/Gm+Phi)*c)/m
q = (d*(X1-Rd)+a*c+(G0/Gm+Phi)*b)/m
r = -(a*b)/m
qq = (p**2-3*q)/9
uu = (2*p**3-(9*p)*q+27*r)/54
```

Use the qualified POWER, inverse-cosine and cosine bindings. Start the chosen net rate at 9999. If qq>=0 and ABS(uu/(qq**1.5))<=1, form psi=ACOS(uu/(qq**1.5)) and trial=((-2*SQRT(qq))*COS(psi/3))-p/3. A strictly smaller trial replaces the chosen rate. If the light trial does not replace it, restore the enzyme X1 and X2. If the final sentinel remains or the chosen rate is below -Rd, use -Rd. These existing C3 stages retain source behavior; the C4 interval-root algorithm does not replace them.

For ABS(A+Rd)<2^-23, use Gs=G0. Otherwise Cc=(Gamma*X1+(A+Rd)*X2)/MAX(2^-23,X1-(A+Rd)), Ci=Cc+A/Gm, CiStar=Gamma-Rd/Gm and Gs=G0+((A+Rd)/(Ci-CiStar))*Phi. Preserve the original C3 rounded A+Rd in the gross canopy sum. C3 and dark cases reuse their accepted physical, protected-owner and status records.

## Arithmetic and common stages

Every sum, difference, product, division and square root rounds separately in FP64, the 64-bit floating-point format. Keep left-to-right dependencies and default-real conversions. FPCR is zero: nearest rounding, ties to even, with gradual underflow. Preserve signed zeros, fresh FPSR, incoming sticky flags and errno, the library error indicator. Forbid fused operations, reassociation, approximate arithmetic and reduced precision.

C4 uses the second pathway of every consumed table. Its entropy uses second RASJ/RBSJ and RASV/RBSV entries, and deactivation uses second RD_JMAX/RD_VCMAX entries. Electron capacity is ((RARJV(2)+RBRJV(2)*bounded_growth)*VCMAX25)*temperature_response, with bounded_growth=MAX(11,MIN(growth,35)). Carboxylation is VCMAX25*temperature_response. C4 does not compute internal tissue conductance; its unused observed value remains positive zero. Residual pore conductance, carbon/oxygen response constants and humidity response use the second pathway. Common capacity, radiation, respiration and boundary-conductance stages retain their arithmetic.

## C4 light and biochemical stages

Compute cyclic fraction fc, adjusted supply J2, conversion z, pump light capacity VpJ, carbon light capacity XJ and oxygen coefficient X2J in the following order. Psi, q, pseudo and H are the supplied dimensionless light constants: 0.4, 1, 0.1 and 4. Gamma here is the C4 ratio gamma=0.5/Sco; it differs from the C3 compensation concentration.

```text
fc = 1 - (4*(1-Psi)*(1+q) + 3*H*pseudo)/(3*H - 4*(1-Psi))
Rm = Rd/2
Star = (Gbs*gamma*Oi - (1+gamma*Alpha/0.047)*Rd + Rm)/(Gbs+Kp)
J2 = J/(1-pseudo/(1-fc))
z = (2+q-fc)/(H*(1-fc))
VpJ = ((Psi*J2)*z)/2
XJ = (((1-Psi)*J2)*z)/3
X2J = (7*gamma)/3
```

Check pairs in order enzyme/enzyme, light/light, enzyme/light, light/enzyme. For enzyme Rubisco set X1=Vc, X2=Kmc/Kmo, X3=Kmc; for light Rubisco set X1=XJ, X2=X2J, X3=0. For the enzyme pump set Pa=1+Kp/Gbs, Pb=0; for the light pump set Pa=1, Pb=VpJ. The first member of a pair is Rubisco, and the second is the pump.

Compose the polynomial directly in gross fixation W to retain small uptake when net uptake is nearly minus respiration. The following dependencies freeze its rounding points; every displayed product and sum rounds separately, including repeated expressions.

```text
X0 = Ca+Rd/Gb
C0 = X0-Star
M = Phi-G0/Gb
D = G0*C0
N0 = X0*D+Rd*C0
N1 = X0*M-D/Gb-C0-Rd/Gb
N2 = (1-M)/Gb
O1 = Alpha/(0.047*Gbs)
O0 = Oi-O1*Rd
B0 = Pb+Rd-Rm
Y0 = Pa*Gbs*N0+B0*D
Y1 = Pa*Gbs*N1+B0*M-D
Y2 = Pa*Gbs*N2-M
E0 = (Gbs*X2*O0+Gbs*X3)*D
E1 = (Gbs*X2*O0+Gbs*X3)*M+(Gbs*X2*O1)*D
E2 = (Gbs*X2*O1)*M
H0 = (Gbs*gamma*O0)*D
H1 = (Gbs*gamma*O0)*M+(Gbs*gamma*O1)*D
H2 = (Gbs*gamma*O1)*M
c0 = -X1*(Y0-H0)
c1 = Y0+E0-X1*(Y1-H1)
c2 = Y1+E1-X1*(Y2-H2)
c3 = (Alpha*X2/0.047-1)*M-(Pa*Gbs*(M-1))/Gb
```

Gross bounds are zero and MIN(X1,Gb*(Ca-Star)+Rd). Evaluate P(W)=((c3*W+c2)*W+c1)*W+c0 in that Horner order. Keep the unchanged c3 expression, including its exact-zero boundary.

## Physical interval roots

The private root helper receives addresses of four coefficients, lower and upper bounds, three returned roots and a four-byte count in x0 through x4. It performs all numerical stages in assembly. Initialise all roots to positive zero and count to zero. Return if upper is less than lower. Start the partition with both endpoints.

Form da=3*c3, db=2*c2, dc=c1. If da is exactly zero and db nonzero, offer -dc/db. Otherwise form disc=db*db-((4*da)*dc). For nonnegative disc, compute its correctly rounded square root. Use qroot=-0.5*(db+sqrt(disc)) if db is nonnegative, otherwise qroot=-0.5*(db-sqrt(disc)). For zero qroot offer -db/(2*da); otherwise offer qroot/da then dc/qroot. Add only strictly interior points that differ from all existing points.

Sort at most four points in increasing order by insertion, preserving equality order. Evaluate P at every point and add exact zero endpoints. For each interval with opposite strict endpoint signs, bisect at most 2200 times. The midpoint is (0.5*lo)+(0.5*hi), with separate products. Stop if rounding places it at an endpoint. At an exact polynomial zero, set both endpoints to the midpoint and both residuals to positive zero, then stop. Otherwise replace the endpoint with the same strict sign as the midpoint.

Select the lower endpoint unless ABS(P(hi)) is strictly smaller than ABS(P(lo)). Deduplicate exact equal roots, then sort increasingly. Exact-rational certificates establish one simple root on each frozen critical and forecast pair interval. The helper nevertheless retains all declared degree and turning-point stages.

## Selection and final calculation

For candidate W, form A=W-Rd. Require W>=0, W<X1, Cs=Ca-A/Gb>Star, Gs=G0+(W/(Cs-Star))*Phi>0 and Ci=Cs-A/Gs>0. Form O=(Alpha*A)/(0.047*Gbs)+Oi and Cc=(W*(X2*O+X3)+(gamma*O)*X1)/(X1-W). Preserve every parenthesis and product order. Require Cc>0.

Recompute both Rubisco rates in C5 and the pump enzyme rate Kp*Ci. Reject an enzyme trial when its rate exceeds its competing light rate, or a light trial when its rate exceeds the competing enzyme rate. Retain only candidates meeting both conditions. Select the smallest net A with a strict comparison; ties retain the first pair and root. Save its W, Pa, Pb, X1, X2 and X3. No admissible candidate is an error; there is no fallback.

For the selected leaf, recompute O and Cc in the same order. The final internal concentration is (Cc-((Pb-A)-Rm)/Gbs)/Pa. Recompute pore conductance as G0+(W/((Ca-A/Gb)-Star))*Phi. Do not floor a positive capacity denominator or replace small W by zero. Retain W in the canopy gross sum; C3 retains its original rounded A+Rd. Canopy reductions, respiration over every reference level, leaf-area cutoffs, ground-area conversion and output order remain unchanged.

## Storage and ABI

The normal source interface has twenty-four addresses. x0 through x7 carry KIDIA, KFDIA, KLON, LDLAND, KVTYPE, KCO2TYP, TAGS and TAGF. The stack carries TCST and fifteen descriptor addresses. Scalars have four bytes, GNU rank-one descriptors sixty-four bytes, TAGS 2344 bytes, TAGF 1472 bytes and TCST 128 bytes. Ten TAGF coefficient descriptors have rank two and eighty-eight bytes. Complete-owner checks retain both additional TAGS table targets as immutable.

Retain the contiguous descriptors, table pitch, active and inactive cells, empty ranges and disjoint outputs defined below. Column count is one through 4096, with 1<=KIDIA<=KLON+1, 0<=KFDIA<=KLON and KFDIA>=KIDIA-1. Vegetation is zero through twenty; zero uses dummy row one. Longer backing owners stay unchanged outside the active range.

The main frame is 8192 bytes and aligned to sixteen. Offsets zero through 167 preserve registers, 256 through 447 retain argument addresses, and 448 through 479 hold integer controls. Accepted C3 scalars start at 512. Leaf-edge, light, capacity and respiration arrays retain offsets 2048 through 2927, and observation outgoing slots retain 3000 through 3087. New C4 scalar/root storage starts at 4096 and ends below 7168. The root helper owns a separate aligned frame and calls only its own polynomial/point/root stages. Preserve x18, x19 through x29, low sixty-four bits of d8 through d15, SP and FPCR across every call.

PGSTOT, PGPP, PRD and PAN are arguments twenty through twenty-three. Compare complete little-endian FP64 owners, including inactive bytes, with zero differences. A pure observer may copy intermediates into records and supplies no calculation. No driver supplies an omitted numerical stage. The numerical solver calls no original Fortran calculation.

## Qualified profiling boundary

The full native route reads the original LHOOK control, supporting its qualified values zero and one without changing it. It calls the existing DR_HOOK default8 logger before numerical stages and at return, with the exact name FARQUHAR_MOD:FARQUHAR, its twenty-one-byte hidden character length, a four-byte entry/exit selector and an eight-byte retained handle. These calls provide profiling only, with no omitted numerical stage. Restore x18 immediately after each external call. Reuse the established MPI and DR_HOOK initialisation for standalone LHOOK-one checks, then qualify fresh and incoming status through the complete source/native route.

## Complete argument and table layout

The application binary interface, or ABI, defines argument locations and registers that a called routine must preserve. Twenty-four ordinary addresses are ordered as KIDIA, KFDIA, KLON, LDLAND, KVTYPE, KCO2TYP, TAGS, TAGF, TCST, radiation, pressure, saturation humidity, surface humidity, air humidity, air temperature, skin temperature, soil temperature, soil water, CO₂ mass ratio, leaf area, PGSTOT, PGPP, PRD and PAN. The first eight use x0 through x7; the last sixteen are stack addresses. The three scalar indices have four bytes. GNU rank-one descriptors have sixty-four bytes and readonly backing arrays; logical and integer elements have four bytes, and real elements eight bytes. The whole records are TAGS 2344, TAGF 1472 and TCST 128 bytes.

The supported column count is 1 through 4096. Require 1<=KIDIA<=KLON+1, 0<=KFDIA<=KLON and KFDIA>=KIDIA-1. Array data are contiguous, positively unit-strided and naturally aligned to their element size. Descriptor byte fields at offsets 0, 8, 16, 28, 29, 32, 40, 48 and 56 hold the data address, element offset, element size, rank, type kind, span, stride, lower bound and upper bound. Require element offset plus lower-bound stride to identify the first physical element. Longer backing owners remain unchanged outside the requested range. Empty ranges preserve every output byte.

The ten TAGF tables are GNU rank-two descriptors of eighty-eight bytes. Each has twenty rows and two pathways, first stride one, second stride twenty, and lower bounds one. Their data offset is -21 elements; the second dimension uses descriptor fields 64, 72 and 80 for stride and bounds. The table descriptor offsets are RVCMAX25 384, RHUMREL 472, RA1 560, RB1 648, RG0 736, RGM25 824, RE_VCMAX 912, RE_JMAX 1000, RDOWNREGULATION_CO2_COEF 1088 and RSTRUCT_CONST 1176. The fixed controls leave the last two numerical options disabled, but complete owner checks retain their supplied bytes.

Two additional TAGS table targets remain immutable: RVR0VT at descriptor offset 2128 is rank two, and RVCH4QVT at 2216 is rank one. Together with all ordinary argument and backing owners, the complete leaf packet contains fifty-four owners, of which fifty are immutable. The four mutable owners are the complete output arrays; output descriptor bytes remain immutable. Disjoint output owners must not overlap an input or another output.


The following readonly inline fields use original byte offsets; every real field is FP64 and every integer field has four bytes. A rank-one inline field contains two pathway entries. The values remain supplied inputs.

| Record member | Byte offset | Shape |
| --- | ---: | --- |
| YDCST.R | 24 | scalar |
| YDCST.RPI | 8 | scalar |
| YDAGF.NLAI | 0 | scalar |
| YDAGF.NLAI1 | 4 | scalar |
| YDAGF.NPATH | 8 | scalar |
| YDAGF.RDOWNREGULATION_CO2_BASELEVEL | 16 | scalar |
| YDAGF.RDOWNREGULATION_CO2_MINIMUM | 24 | scalar |
| YDAGF.RUNDEF_SECHIBA | 32 | scalar |
| YDAGF.RUNDEF | 40 | scalar |
| YDAGF.NIUNDEF | 12 | scalar |
| YDAGF.RONE_MONTH | 48 | scalar |
| YDAGF.RARJV | 56 | two entries |
| YDAGF.RBRJV | 72 | two entries |
| YDAGF.RASJ | 88 | two entries |
| YDAGF.RBSJ | 104 | two entries |
| YDAGF.RASV | 120 | two entries |
| YDAGF.RBSV | 136 | two entries |
| YDAGF.RD_VCMAX | 152 | two entries |
| YDAGF.RD_JMAX | 168 | two entries |
| YDAGF.RE_GAMMA_STAR | 184 | scalar |
| YDAGF.RE_GM | 192 | two entries |
| YDAGF.RS_GM | 208 | two entries |
| YDAGF.RS_JMAX | 224 | two entries |
| YDAGF.RD_GM | 240 | two entries |
| YDAGF.RE_KMC | 256 | scalar |
| YDAGF.RE_KMO | 264 | scalar |
| YDAGF.RE_RD | 272 | scalar |
| YDAGF.RE_SCO | 280 | scalar |
| YDAGF.RGAMMA_STAR25 | 288 | scalar |
| YDAGF.RKMC25 | 296 | two entries |
| YDAGF.RKMO25 | 312 | two entries |
| YDAGF.RSCO25 | 328 | two entries |
| YDAGF.RSTRESS_GM | 344 | scalar |
| YDAGF.RSTRESS_GS | 352 | scalar |
| YDAGF.RSTRESS_VCMAX | 360 | scalar |
| YDAGF.RTPHOTO_MAX | 368 | scalar |
| YDAGF.RTPHOTO_MIN | 376 | scalar |
| YDAGF.RLAI_LEVEL_DEPTH | 1264 | scalar |
| YDAGF.RLAIMAX | 1272 | scalar |
| YDAGF.REXT_COEFF | 1280 | scalar |
| YDAGF.RGB_REF | 1288 | scalar |
| YDAGF.RTP_00 | 1296 | scalar |
| YDAGF.RPB_STD | 1304 | scalar |
| YDAGF.RRG_TO_PAR | 1312 | scalar |
| YDAGF.RW_TO_MOL | 1320 | scalar |
| YDAGF.RALPHA_LL | 1328 | scalar |
| YDAGF.RTHETA | 1336 | scalar |
| YDAGF.RFPSIR | 1344 | scalar |
| YDAGF.RFQ | 1352 | scalar |
| YDAGF.RFPSEUDO | 1360 | scalar |
| YDAGF.RH_PROTONS | 1368 | scalar |
| YDAGF.RGBS | 1376 | scalar |
| YDAGF.ROI | 1384 | scalar |
| YDAGF.RALPHA | 1392 | scalar |
| YDAGF.RKP | 1400 | scalar |
| YDAGF.RTETENS_1 | 1408 | scalar |
| YDAGF.RTETENS_2 | 1416 | scalar |
| YDAGF.RREF_TEMP | 1424 | scalar |
| YDAGF.RMOL_TO_M_1 | 1432 | scalar |
| YDAGF.RRATIO_H2O_TO_CO2 | 1440 | scalar |
| YDAGF.RN_VERT_ATT | 1448 | scalar |
| YDAGF.RTAU_TEMP_AIR_MONTH | 1464 | scalar |
| YDAGS.RMAIR | 8 | scalar |
| YDAGS.RMCO2 | 24 | scalar |
| YDAGS.RRDCF | 112 | scalar |

## Complete canopy returns and acceptance

In increasing leaf-level order, sum gross*width and Gs*width over included assimilation levels, and Rd*width over every reference level. C4 gross is its retained W; C3 gross is its rounded A+Rd. Let gross_total and respiration_total be the resulting leaf-area sums. PGPP=(gross_total*1e-6)*RMCO2, PAN=((gross_total-respiration_total)*1e-6)*RMCO2 and PRD=(respiration_total*1e-6)*RMCO2. Preserve the original locations of these conversions.

For assimilating columns, PGSTOT=((((RMOL_TO_M_1*(air_temperature/RTP_00))*(RPB_STD/pressure_hPa))*conductance_total)*RRATIO_H2O_TO_CO2). Retain the top-level conductance conversion, multiplication by the selected final leaf edge, its 2^-23 threshold and the source reciprocal-resistance calculation. Inactive requested columns retain the source zero-conductance return and their dark carbon result.

All complete returns use little-endian FP64 bytes in the original owner order. Zero differing bytes is the output limit; do not mask, round or normalize mismatches. Preserve all immutable owners and inactive cells. Independent leaf gas residuals use the unchanged 1e-7 ppm limit, biochemical rates the unchanged 1e-8 µmol/(m²·s) limit, and canopy carbon balance eight FP64 epsilons times the uncancelled gross/net/respiration scale.

Source qualification covers twelve critical inputs, all four C4 limitation pairs, both limitation switches, adjacent leading-coefficient signs, exact quadratic degree, positive gross with negative net uptake and the first active weak-light value. It also covers 171 genuine active-C4 calls with 2,134 leaf states and 8,536 independently certified physical root intervals at 120 decimal digits. The ordinary and observation source forecasts agree on all ten saved files across 618,140 bytes. Protected native checks cover twenty-eight critical invocations and 342 genuine-packet invocations with exact outputs, intermediates, owners, status and preserved registers. Existing C3, dark, descriptors, helpers and immutable-owner records are retained.

The source reference and assembly use the same declared exponential function. Load its canonical mathematical library at process startup so that each comparison resolves the same routine.

The normal relay compares a full corrected-source shadow with the complete native entry, preserving complete owners, fresh status, incoming sticky flags and actual LHOOK. Reference-only parent-shadow calls use the private corrected source and carry no native credit. The complete normal forecast passes 6,450 source/native and machine-status pairs, including 171 active C4 calls. All 4,953,600 returned bytes and 72,317,400 immutable bytes match, with 614,400 independent canopy relations. Profiling remains enabled on every native call. All ten saved files match across 618,140 bytes. No comparative timing or autonomous forecast claim is made.

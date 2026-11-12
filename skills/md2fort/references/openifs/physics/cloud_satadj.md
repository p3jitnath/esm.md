# CLOUD_SATADJ Contract

Revision 4 covers the complete reachable numerical body in the 1,076-line `arpifs/phys_ec/cloud_satadj.F90`, including its contained 70-line `QSATMIXADJ`. `QSATWATADJ` is defined but never called. Actual evaporation limits, phase choices, heating, numerical cleanup and all cloud-budget diagnostic writes stay inside the direct parent. Drivers supply no omitted stage.

## Inputs And Domain

Cells use column-first storage, so cell $`(j,k)`$ has zero-based offset $`j+kN`$. $`N`$ is the column count and $`K`$ is the level count. Half-level pressure has $`K+1`$ levels. Columns are $`0..4096`$, levels are $`0..512`$, the selected inclusive Fortran interval can be cropped or empty, and $`1\le N_{top}\le K+1`$. The time step $`\tau`$ is finite and positive. Every owner must cover its complete declared shape.

Temperature, humidity, liquid and ice use K and kg/kg. Their input tendencies use K/s or kg kg$`^{-1}`$ s$`^{-1}`$. Cloud fraction and its tendency use dimensionless units and s$`^{-1}`$. Pressures are finite positive Pa, and layer half-pressure must increase downward. Original physical water fields are nonnegative and cloud fraction is in $`[0,1]`$. Cumulative tendencies can make temporary states signed. Negative temporary humidity is admitted for passive zero phase changes or for conservative restoring evaporation. The latter must cool the air, increase vapour, decrease liquid or ice and preserve the existing independent water, available-condensate and actual phase heat checks. This parent supplies a partial tendency. Its temporary vapour can remain signed while the water, phase heat and available-condensate relations pass. The later `QNEGAT` humidity correction has a stated vapour floor, which is checked at the final `CALLPAR` return. Other caller fields are checked for finite values and ordered rate additions. Complete forecast-state bounds must be checked where the time step forms that state. Small temporary phase deficits require the complete source cleanup and independent returned-state checks.

Freeze the accepted thermodynamic constants plus $`g=9.80665`$ m s$`^{-2}`$. All consumed `QSATMIXADJ` arguments must meet its complete conditional domain, and all `CLOUD_SUPERSATCHECK` arguments must meet its conditional condensation domain. The old warm trigger-gap failures are excluded. Source-first child observation checks the actual supersaturation adjustments before direct parent execution. No blanket temperature or sign extension is permitted.

Structured settings use the exact GNU Fortran layouts in the local probe. `TECLDP`, `TEPHLI`, `TECUMF`, `TEPHY` and `TSPP_CONFIG` occupy 2,776, 120, 344, 448 and 3,192 bytes. A stochastic perturbation record occupies 184 bytes. Active perturbation entries and pattern columns must exist, be contiguous and stay read-only. Their EXP arguments must remain in the accepted child's domain. Critical relative humidity remains between zero and one. Every enabled diagnostic field and level must exist, including the 43 levels used by the vertical integral and the optional 26-field budget offset.

## Ordered Numerical Update

FP64 means 64-bit floating point. Every multiplication, addition, subtraction and division rounds separately to nearest with ties to even. Preserve parentheses, left-to-right source sums, signed zeros, branch thresholds and gradual underflow. FPCR, the floating-point control register, is zero. Use no fused, reassociated or approximate operation. The accepted scalar EXP route and complete private `QSATMIXADJ` and `CLOUD_SUPERSATCHECK` bodies are numerical children.

Set $`r_\tau=1/\tau`$ and $`r_c=R_d/c_p`$. Selected cells above $`N_{top}`$ receive positive-zero tendencies. For each remaining level and selected column, perform the following complete ordered stages. The column calculations are independent, and fusing their scalar stages preserves every dependency and the level order of diagnostic sums.

1. Form $`T_u=T+\tau C_T`$, $`q_u=q+\tau C_q`$, $`a_u=\max(0,\min(1,a+\tau C_a))`$, $`L_u=L+\tau C_L`$ and $`I_u=I+\tau C_I`$. Each $`C`$ is the corresponding cumulative input tendency.

2. If the vertical-velocity perturbation is active, multiply its input $`\omega`$ by $`\operatorname{EXP}(\mu_\omega+x_\omega P_\omega)`$. Here $`P`$ is the supplied stochastic pattern, and $`\mu,x`$ are the selected parameter values. Otherwise retain the original velocity.

3. Form $`\Delta p=p_{k+1/2}-p_{k-1/2}`$, $`G=g/\Delta p`$, $`\tau G=\tau G`$, $`B=\Delta p r_\tau`$ and $`D_T=r_cT/p`$. Clip velocity to $`[-B,B]`$. Add the short-wave and long-wave heating rates, clip their sum to $`[-BD_T,BD_T]`$, then multiply by $`\tau`$. Form the complete forcing $`F_T=D_T\omega\tau+F_{rad}+U_T\tau G+V_T\tau`$ in that order and $`F_q=U_q\tau G+V_q\tau`$. $`U`$ is the relevant fourth or third convective detraining field, and $`V`$ is the vertical-diffusion tendency.

4. Set the existing liquid fraction to $`L_u/(L_u+I_u)`$ and ice fraction to one minus it when their sum exceeds `RLMIN`, otherwise set both to positive zero. Compute critical relative humidity from `RAMID`, its optional EXP perturbation and optional cap at one. When $`p/p_s>0.8`$, increase it toward one using $`\mathrm{RH}_{crit}=r+(1-r)((p/p_s-0.8)/0.2)^2`$. Preserve each shown rounding.

5. At the original $`T`$ and updated $`T_u`$, evaluate the complete mixed and Koop/clear saturation limits and mixed latent-feedback denominator from the frozen thermodynamic laws. Multiply by the separately rounded reciprocal $`1/p`$, cap each vapour factor at 0.5, then apply $`q=f/(1-vf)`$. The clear limit is the separately rounded half-sum of Koop humidity and mixed humidity. The mixed humidity and feedback are the same equations as in the child contracts, with the parent's original temperature and pressure dependency.

6. Form $`T_f=\max(T+F_T,160)`$ and $`q_f=q_s(T,p)+F_q`$. Call complete `QSATMIXADJ` with these values and pressure, then set $`D_q=q_{new}-q_f`$. A negative $`D_q`$ means condensation in this source convention. The function's returned diagnostic never replaces an actual parent phase or heating stage.

7. Start new-cloud liquid, ice and cover at positive zero. When $`D_q\le-\mathrm{RLMIN}`$ and $`a<1-10^{-14}`$, compute clear-air humidity $`q_e=\max(0,(q-aq_s)/\max(10^{-14},1-a))`$. Enter formation only when $`\mathrm{RH}_{crit}q_c\le q_e<q_c`$. Set $`A_c=\min(-(1-a)D_q/\max(2(q_c-q_e),10^{-14}),1-a)`$ and $`C_e=-D_q\,0.5A_c`$. If $`D_q<-2(q_c-q_e)/\max(10^{-14},1-a)`$, cap $`C_e`$ by $`(a-1)D_q-q_c+q`$. Clip it to at least zero. Below `RLMIN`, with negligible clear area, or when this amount is zero, remove its cover change. Put new condensate into liquid when the original $`T>\mathrm{RTHOMO}`$ and into ice otherwise.

8. Start existing-cloud liquid and ice condensation at zero. When $`a>10^{-14}`$ and $`D_q\le-\mathrm{RLMIN}`$, cap $`\max(-D_q,0)`$ by $`\max((q_u-q_s(T_u,p))/h(T_u,p),0)`$, multiply by original $`a`$ and remove amounts below `RLMIN`. Choose liquid or ice from the same original-temperature threshold.

9. When $`D_q>0`$ and $`L_u+I_u>0`$, evaporate $`E=\min(aD_q,L_u+I_u)`$ and partition it with the stored existing liquid and ice fractions. Otherwise return zero evaporation. The source cover loss for this stage is zero.

10. Form $`T_v=T_u+H_w(C_{cl,L}+C_{e,L}-E_L)+H_i(C_{cl,I}+C_{e,I}-E_I)`$ in that left-to-right order. Form $`q_v=q_u+(E_L-C_{cl,L}-C_{e,L})+(E_I-C_{cl,I}-C_{e,I})`$. Form $`a_v=\min(a_u+A_c,1)`$ and set it to zero below `RAMIN`. Call complete supersaturation mode two with these values. Retain its full diagnostic outputs, use only the liquid-plus-ice sum and cover increment, then choose the actual added phase from the input $`T_v>\mathrm{RTHOMO}`$.

11. Form liquid and ice rates from their complete condensation-minus-evaporation sums multiplied by $`r_\tau`$. Form the humidity rate in the original eight-term source order and the temperature rate as separately rounded liquid and ice heating products and their sum. Compute final cover from $`a_u+A_c+S_a`$, cap at one, remove it below `RAMIN`, subtract $`a_u`$ and multiply by $`r_\tau`$.

12. Compute $`L_*=L_u+\tau\dot L`$. If it is negative, perform the exact source cleanup $`\dot L\leftarrow\dot L-L_*`$, $`\dot q\leftarrow\dot q+L_*`$ and $`\dot T\leftarrow\dot T-H_wL_*`$. Apply the corresponding complete ice cleanup next. Large warning-producing deficits remain outside the scientific domain. The source cleanup is preserved as written and is checked through actual returned water and heating relations.

13. Retain every enabled cloud-budget addition to `PEXTRA` in original level order. The vertical integral multiplies each process by $`r_\tau\Delta z`$, with $`\rho=p/(R_dT)`$ and $`\Delta z=\Delta p/(\rho g)`$. Add cover terms to indices 1..3, liquid terms to 15..18 and ice terms to 40..43 of its first field. The regular cover, liquid and ice budgets use the source offsets of 12, 22 and 18 fields, preceded by the optional vertical field and 26-field `LBUD23` shift. Preserve all untouched diagnostic bytes.

## ABI And Complete Outputs

The application binary interface, ABI, takes 39 ordinary addresses. `x0..x7` hold `YDECLDP`, `YDEPHLI`, `YDECUMF`, `YDEPHY`, `YDSPP_CONFIG`, `KIDIA`, `KFDIA` and `KLON`. The caller stack supplies `KLEV`, `KTYPE`, `PTSPHY`, `PAP`, `PAPH`, `PT`, `PQ`, `PA`, `PL`, `PI`, five cumulative tendencies, two radiation rates, two diffusion tendencies, `PMFU`, `PMFD`, `PLUDELI`, `PVERVEL`, `PGP2DSPP`, five local tendencies, `PEXTRA` and `KFLDX`, in that exact source order.

Integer owners contain four bytes. FP64 owners are eight-byte aligned. Every local tendency covers $`NK`$ words, `PEXTRA` covers $`NKK_{fld}`$ words, and all mutable owners are disjoint from inputs and one another. `PLUDELI` has four column-first fields. Complete returned bytes are the five tendency owners followed by the full diagnostic owner, including untouched cells and fields. The native must preserve `x19..x29`, the low 64 bits of `d8..d15`, SP and FPCR, and own all private scratch.

Verification relays distinguish original verification calls from actual private native children. Count only calls that enter each native child. Independent parent checks cover water, actual liquid and ice heating, available condensate and the consumed child domains. The separate caller observer checks the later humidity floor and complete ordered rates. Zero raw differing bytes remains mandatory.

## Evidence

Before direct emission, 13 complete original calls pass 103,240 returned bytes and 1,865 independent relations at 120 digits. One additional source-first case checks the active perturbed humidity cap, bringing the source corpus to 14 calls, 103,720 bytes and 1,940 relations. Cases cover formation, evaporation, accepted warm activity, phase boundaries, both stochastic perturbations, all budget branches, cropped and empty shapes, top-level zeroing and small phase-deficit cleanup.

The complete native parent passes 28 protected placements at both owner boundaries, with 207,440 returned bytes, zero differences and 3,880 independent relations. Six complete 39-address ABI calls preserve saved registers, SP, FPCR, seeded status and errno. Seven shape or control failures preserve 100,848 genuinely shared output bytes. The private parent and thermodynamic frames use 2,048 and 224 bytes. The measured stochastic humidity-cap flag is at object offset 584.

Eight composed paired calls pass 101,440 complete parent bytes and 201 genuine private calls to each saturation child. Every original supersaturation child input and all five returned diagnostic values agree bit for bit with the actual native child. The relay keeps original shadows separate from native counts. Two profiled paired calls pass 480 bytes and preserve all raw numerical and diagnostic status. Two source-physics or alias failures preserve 976 shared bytes before native execution. Inputs, nested perturbation records and frozen constants remain read-only. Accepted unchanged child proofs are reused. No timing or independent whole-forecast acceptance is claimed.

### Partial-Parent And Humidity Evidence

One genuine original case evaporates available ice into vapour and cools the air. Its complete replay agrees across 18,240 bytes, and two protected paired replays agree across 36,480 bytes. Independent 120-digit checks pass the water and actual ice-phase heating relations. A later genuine case leaves signed temporary vapour after the partial parent. The parent must preserve water and heat and respect available condensate while the remaining caller stages complete the update.

The original `QNEGAT` correction after parent call 17 raises the affected humidity to its configured floor of 1e-8 kg/kg. The frozen packet passes 456 final humidity bounds, 456 independent layer-water checks, 24 bottom-addition accounts and 456 diagnostic flux checks at 120-digit precision. The correction can add water at the bottom. Account for this addition through the returned diagnostic flux.

### Final Humidity And Caller Rates

`CALLPAR` returns cumulative rates, including the slow-physics average. The current observer checks the stated humidity guarantee after the enabled `QNEGAT` correction. It does not treat every trial cloud fraction as a completed forecast state. The complete time-step state requires its own physical checks before autonomous-forecast optimisation.

Compose vapour from its initial value and complete final tendency, preserving separate FP64 multiplication and addition. When `QNEGAT` is enabled, the result must meet its configured humidity floor within the accepted rounding allowance. Retain the absolute incoming rate and each actual later rate contribution. Use 64 machine epsilons multiplied by the initial magnitude plus the time step times this sum of absolute rates. The observer verifies every separately rounded addition, all seven finite caller rates and unchanged initial owners without changing any caller bytes or numerical stage.

A genuine caller-history capture independently verifies the separate rounding and unchanged final liquid bits at 120-digit precision. Focused cases qualify the contribution budget, reject an unobserved cumulative write and reject a humidity-floor violation. The unchanged original types also qualify the consumed flags and configured floor offsets. Normal all-call and saved-file acceptance remain pending. This humidity and rate check does not establish complete cloud-scheme physics, a full-column heat and water budget or whole-forecast material bounds.

## Actual Forecast Acceptance

The combined coarse forecast uses exclusive allocation 7259755 on nid010824. These actual assembly calls have zero differing bytes. A compared array contains the complete storage supplied by its caller. Private child counts exclude original comparison calls.

| Original routine | Actual calls | Compared bytes | Scope |
| --- | ---: | ---: | --- |
| cloud_satadj | 2,150 | 39,216,000 | Complete returned parent arrays |

A separate observer checks the configured humidity floor over 972,800 values at CALLPAR return. It also checks 6,809,600 finite rate values and their ordered additions with the unchanged 64-epsilon allowance. This observer adds zero routines.

All ten saved files match across 618,140 bytes. Accepted critical physics and interface checks are reused. Independent physics for the whole forecast, whole-process byte agreement, autonomous execution and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

## Runtime Provider Binding

The runtime binding retains the complete accepted parent and both numerical children. The parent, QSATMIXADJ and CLOUD_SUPERSATCHECK objects each match their accepted objects byte for byte. The separate private child objects used by the paired verification also remain identical. Production calls the canonical children directly, with no new wrapper, branch or numerical instruction.

The supported range remains 0 through 4,096 columns and 0 through 512 levels, including 17 columns and 137 levels. All selected-range, model-record, diagnostic, stochastic, complete-owner and conditional child-domain requirements above still apply. The parent remains a partial tendency calculation: signed temporary vapour requires its accepted water, available-condensate and actual phase-heating checks. The later caller owns the complete humidity-floor check.

Five physical constants share the initialized 520-byte physical record: `RG`, `RD`, `RCPD`, `RETV` and `RTT`, at byte offsets 112, 184, 200, 240 and 368. Fourteen thermal constants share the initialized 1,920-byte thermal record: `R2ES`, `R3LES`, `R3IES`, `R4LES`, `R4IES`, `R5ALVCP`, `R5ALSCP`, `RALVDCP`, `RALSDCP`, `RTWAT`, `RTICE`, `RTWAT_RTICE_R`, `RKOOP1` and `RKOOP2`, at byte offsets 0, 8, 16, 24, 32, 72, 80, 88, 96, 112, 136, 152, 168 and 176. Existing module names and the linker’s stored addresses reach these actual producer bytes. All nineteen consumed words equal the accepted values, and no original OpenIFS global supplies them.

Eight static EXP call sites reach private copies of the exact accepted primary mathematical objects. Two actual parent call sites reach the complete accepted saturation children. The binding check runs only the unchanged physical and thermal setup producers. Existing independent physical, complete-output, protected-buffer, status and Arm interface records are reused without a cloud calculation or numerical bank replay. Complete `CALLPAR` forwarding, later model-record setup and the loaded autonomous forecast remain pending.

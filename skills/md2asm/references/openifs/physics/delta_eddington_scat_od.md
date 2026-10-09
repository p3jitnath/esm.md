# Cloud delta scaling

Revision 1.1 preserves the numerical contract frozen at revision 1.0 for the complete original `radiation_cloud_optics::delta_eddington_scat_od` body, defined at lines 94–110 of `radiation/module/radiation_delta_eddington.h` in OpenIFS 48.1.1. It rescales the optical properties of one wavelength band by treating a narrow forward scattering contribution as light that continues without deflection. The caller applies this elemental body to each band. An elemental body accepts one scalar value from each array on each call, so its complete returned state consists of three eight-byte values.

The total optical depth $`\tau`$ describes all interaction with light, while the scattering optical depth $`s`$ describes scattering alone. Their difference $`\tau-s`$ describes absorption. The asymmetry factor $`g`$ is the mean cosine of the scattering angle. All three values are dimensionless. The physical input domain has $`0\leq s\leq\tau`$ and $`0\leq g\leq1`$. This stage preserves absorption and the first angular moment used in radiation transport; it does not validate the upstream fitted cloud coefficients against observations.

## Source and active callers

The unchanged `CLOUD_OPTICS` caller applies the body to liquid shortwave bands at line 340, ice shortwave bands at line 434 and ice longwave bands at line 437. Its arrays have 14 shortwave bands or 16 longwave bands. Source relocation and source-line metadata establish genuine callable entries without exposing numerical compiler instructions. The original linked library has a jump-slot relocation for this symbol, so the verification library can observe each complete call.

The source-only historical T21 forecast captures 8,920,690 genuine calls, comprising 2,225,440 liquid shortwave calls at return offset `0xb06fb4`, 3,124,450 ice shortwave calls at `0xb07324` and 3,570,800 ice longwave calls at `0xb07118`. These counts equal the full configured band count times the corresponding accepted optical-helper count. Every phase from 0 through 24 is captured. Both complete input and complete return streams contain 356,827,600 bytes. All ten saved files, totalling 618,140 bytes, directly match the immutable ordered-vertical strict-source baseline.

The captured inputs have $`3.4867339933213813\times10^{-11}\leq\tau\leq476180.49582501082`$, $`3.4867276735609834\times10^{-11}\leq s\leq470170.14132238145`$ and $`0.753988195422158\leq g\leq1`$. Manufactured physical cases extend this range to zero depth, no scattering, complete forward scattering and known partly scattered states. Separate arithmetic cases test signed zeros, subnormal numbers and negative values without claiming that those cases describe a physical cloud.

## Ordered arithmetic

Use IEEE binary64, called FP64, with each operation rounded separately to nearest and ties to even. The floating-point control register, FPCR, must be exactly zero on entry and remain zero. Preserve gradual underflow and signed zeros. Inputs and all intermediate results must be finite, and the rounded denominator below must be nonzero. Fused operations, contraction, reassociation, approximate division and reduced precision are forbidden.

Let RN mean one FP64 rounding. Read the old values before their declared mutations, then evaluate these operations in order.

```math
\begin{aligned}
f &= \operatorname{RN}(g\,g),\\
p &= \operatorname{RN}(s\,f),\\
\tau' &= \operatorname{RN}(\tau-p),\\
h &= \operatorname{RN}(1-f),\\
s' &= \operatorname{RN}(s\,h),\\
d &= \operatorname{RN}(1+g),\\
g' &= \operatorname{RN}(g/d).
\end{aligned}
```

The forward fraction $`f`$ is computed first. Store total depth $`\tau'`$ before scattering depth $`s'`$, then store $`g'`$. The scattering product uses the old $`s`$, and the last denominator uses the old $`g`$. Each stored field retains every declared bit. Even when a mathematical identity leaves a value unchanged, the source subtraction can change a signed zero, so the helper must not substitute an early return for the full arithmetic.

## ABI and scalar buffers

The application binary interface, ABI, defines argument registers and saved registers. This AArch64 body accepts three ordinary addresses. Register `x0` points to mutable FP64 total depth, `x1` to mutable scattering depth and `x2` to mutable asymmetry. Each complete scalar buffer has exactly eight readable and writable bytes, aligned to eight bytes. The buffers are disjoint. No descriptor, count, stack argument, optional input or hidden array capacity is part of this interface. The caller owns the outer band loop.

The helper preserves `x19`–`x29`, the low 64 bits of `v8`–`v15` and the incoming stack pointer with its 16-byte alignment, and does not use `x18`. Its complete scalar body requires only caller-saved registers, no stack frame and no numerical helper. The verifier uses an immediate assembly observer to check saved registers and FPCR before C can restore a damaged register. The ordinary Armv8-A floating-point instructions support the declared processor target.

## Independent physical checks

A long-double calculation, with more precision than FP64 on this target, derives retained scattering as $`s(1-g)(1+g)`$ and total depth as old absorption plus that retained scattering. It also checks the following absorption and transport identities independently of the ordered source expressions.

```math
\begin{aligned}
\tau'-s' &= \tau-s,\\
\tau'-s'g' &= \tau-sg,\\
g'(1+g) &= g.
\end{aligned}
```

The second identity preserves the optical depth associated with the first angular moment of radiation transport. The physical checks require finite outputs, nonnegative total and scattering depths, scattering no greater than total depth and $`0\leq g'\leq1/2`$, allowing only the stated rounding tolerance. With zero forward fraction, scattering and asymmetry keep their signed-zero bits. With $`\tau=s>0`$ and $`g=1`$, both depths become exact positive zero and $`g'=1/2`$. A known partial case gives $`\tau'=1.75`$, $`s'=0.75`$ and $`g'=1/3`$. The smallest positive subnormal inputs with $`g=1/2`$ give known nonzero subnormal depths and check gradual underflow.

The guarded corpus has 294 input records, each checked at both the beginning and the end of a protected page, for 588 complete calls. It includes 32 separate-rounding witnesses and 20 captured operand cases chosen from each source site's endpoints and field extrema. The source-only run passes 2,940 independent relations and 566 physical points, and returns 23,520 canonical bytes. All 64 placed rounding witnesses distinguish the separately rounded total depth from one combined high-precision expression. Poisoned neighbour bytes and inaccessible pages verify the exact scalar bounds.

For the critical independent checks, the depth tolerance is `8192*DBL_EPSILON*max(1,abs(tau)+abs(s))+16*DBL_TRUE_MIN`. The asymmetry identity uses `8192*DBL_EPSILON*max(1,abs(g))+16*DBL_TRUE_MIN`. The forecast uses the corresponding factor 1024. These tolerances apply only to the independent mathematical checks. Source/native and archived-output agreement always require zero differing bytes, with no rounding, masking or normalisation.

The source-only observer checks four relations on every captured call, and a separate audit checks the transport identity on all 8,920,690 retained input/return pairs before numerical emission. Together these establish 44,603,450 independent relations. The native comparison observer checks all five on every call.

## Canonical bytes and acceptance

Each critical record contains an eight-byte call index, four-byte page-placement index, four-byte physical-case flag and the three returned FP64 values in total/scattering/asymmetry order. Each forecast record contains the eight-byte call index, four-byte forecast phase, four-byte original source-site index and the same three values. The complete record is 40 bytes, encoded little-endian. Forecast input records use the same header and all three old scalar values. Timing data and machine addresses are excluded.

Accept the complete native body only after every critical output byte and guard passes against the frozen source, every immediate ABI check passes, every original forecast return directly matches its paired source and pre-emission source stream, and all ten saved files directly match the baseline. Hashes identify preserved artifacts and do not replace direct byte comparisons. Other radiation transformations and other module copies of this header remain outside this body. Whole-forecast independent physics and comparative timing remain unfinished.

## Reproduce the checks

The frozen pre-emission record is `.runtime/openifs/delta_eddington_scat_od_7207705/frozen/pre-emission-contract-corpus.json`. It preserves source identity, toolchain controls, the independent source-only results, complete forecast captures, contract, corpus, drivers and commands. The direct solver is emitted from these equations and assembled and linked without numerical compiler assembly or compiler intermediate representations. Interface, relocation and source-line metadata establish storage and callers only.

Run these commands through srun on your own quiet exclusive node and select a new ignored output directory.

```bash
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
check_dir="$PWD/.runtime/openifs/delta_eddington_scat_od_7207705/reproduce"
strict_build="$PWD/.runtime/openifs/strict-build"
mkdir -p "$check_dir"
gcc -fPIC -DORIGINAL_SYMBOL=delta_eddington_scat_od_assembly_ \
  -c src/openifs/physics/delta_eddington_scat_od.S -o "$check_dir/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math \
  -DDELTA_ABI_OBSERVER -Wall -Wextra -Werror -Wno-misleading-indentation \
  bench/openifs/physics/delta_eddington_scat_od.c "$check_dir/assembly.o" \
  -L "$strict_build/lib" -Wl,-rpath,"$strict_build/lib" -larpifs.DP -lfiat -lm \
  -o "$check_dir/critical"
"$check_dir/critical" \
  .runtime/openifs/delta_eddington_scat_od_7207705/frozen/critical-corpus.bin \
  "$check_dir/fortran.bin" "$check_dir/assembly.bin"
cmp "$check_dir/fortran.bin" "$check_dir/assembly.bin"
cmp .runtime/openifs/delta_eddington_scat_od_7207705/preparation/source-critical-final-fortran.bin \
  "$check_dir/fortran.bin"
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror -Wno-misleading-indentation \
  bench/openifs/physics/delta_eddington_scat_od_forecast.c "$check_dir/assembly.o" \
  -ldl -lm -Wl,-Bsymbolic -o "$check_dir/libverify-delta-scat-od.so"
```

Preload the complete source-scoped observer beside the immutable ordered-vertical reference and pressure math in a fresh T21 case. All work for this leaf uses own exclusive job 7207705 on nid011311, one process, one thread, CPU 16 and requested local memory binding. Source-only checks are verification work, with no comparative timing claim.

# OpenIFS CUBIDIAG contract

Revision 1.1 adds combined forecast evidence and preserves the numerical contract frozen at revision 1.0 for the complete CUBIDIAG body in OpenIFS 48.1.1. Its physical input is [convection](../../../../../formulations/openifs/physics/convection.md), revision 1.0. Plumes transport wind, heat and water between layers. The unchanged CUDUDV and CUDTDQN callers form the coefficients and forcing for an implicit transport update. CUBIDIAG then solves that supplied column system. This contract covers the complete helper body, while coefficient formation remains in the caller.

## Units and numerical method

The two observed CUDUDV sites pass wind forcing ZDUDT or ZDVDT and return ZR1 or ZR2, all in metres per second. The two CUDTDQN sites pass temperature forcing ZDTDT in kelvin or moisture forcing ZDQDT in kilograms per kilogram. Their returned solution keeps the forcing unit. In the source, the right-hand-side argument is PR. PA and PB are dimensionless: the caller multiplies gravity, plume mass flux, an inverse pressure difference and a time interval to form them. Geopotential divided by the dry-air heat capacity has units of kelvin in the temperature forcing.

Use forward substitution for the lower-bidiagonal system. A lower-bidiagonal matrix has a diagonal and one adjacent diagonal below it, so each solution entry depends only on the preceding level. Let A, B and R denote PA, PB and PR. Level indices increase down the model column. The rounded diagonal adds the source's small positive regulariser epsilon = 1e-35, which is dimensionless. A regulariser prevents division by an exactly zero unmodified diagonal; it does not prove that an arbitrary supplied system is physically sound.

```math
b_k=\operatorname{RN}_{64}(B_k+\epsilon),\qquad
A_k u_{k-1}+b_k u_k=R_k.
```

FP64 denotes a 64-bit floating-point value. RN64 rounds each operation to nearest FP64 with ties to an even final bit. First store positive zero in every PU entry, including columns outside the selected interval and the whole first level. This complete zero stage is required even for an empty column interval or a false cloud mask. With zero levels there are no array entries to change.

Visit levels JK = 2 through KLEV and columns JL = KIDIA through KFDIA in source order. If LD_LCUMASK is false, retain the positive zero. If it is true and JK = KCTOP(JL) - 1, calculate the first cloud row as follows.

```math
s_k=\operatorname{RN}_{64}(1/b_k),\qquad
u_k=\operatorname{RN}_{64}(R_k s_k).
```

If the mask is true and JK > KCTOP(JL) - 1, use the previous returned PU entry with these separate rounding points.

```math
p_k=\operatorname{RN}_{64}(A_k u_{k-1}),\qquad
r_k=\operatorname{RN}_{64}(R_k-p_k),\qquad
s_k=\operatorname{RN}_{64}(1/b_k),\qquad
u_k=\operatorname{RN}_{64}(r_k s_k).
```

Rows before the cloud top retain zero even when their mask is true. A hole in the mask also leaves zero for the following row's preceding solution. Preserve reciprocal then multiplication; replacing it with direct division changes the frozen output bits. Preserve signed zeros, gradual underflow and each stated dependency. Forbid fusion, contraction, reassociation, approximate reciprocal, reduced precision and fast-math. The helper calls no numerical routine or transcendental function. Its profiling hooks are excluded from the numerical interface. The standalone critical driver disables only the profiling flag before source calls, because it does not initialise MPI; the full forecast keeps normal model initialisation and hooks.

## Bounds and admissibility

Require positive KLON, 0 <= KLEV <= INT32_MAX - 2, 1 <= KIDIA <= KLON and KIDIA - 1 <= KFDIA <= KLON. KCTOP has KLON 32-bit integer entries. For a column with a used equation, require 1 <= KCTOP <= KLEV + 2. Unused cloud-top values can be invalid and must not cause a field access. LD_LCUMASK has shape (KLON,KLEV), with canonical 32-bit GNU logical values zero or one.

PA, PB, PR and PU have shape (KLON,KLEV), with 8-byte-aligned FP64 values in Fortran order. Products of extents and address calculations fit signed 64-bit integers. The output is separate from all inputs and scalar parameter objects. The whole PA, PB and PR capacities exist, including their unused entries, but only selected equation values must be finite. Their rounded diagonal must be nonzero, its reciprocal finite and all required intermediate and returned values finite. Inputs, masks, cloud tops and scalar parameters remain unchanged. PU is fully overwritten, so its incoming bytes can be arbitrary. With fewer than two levels, masks and equation inputs need no value access.

The independent physical corpus uses known finite solutions and dimensionless coefficients with nonnegative mixing weights. In the ordinary manufactured cases, A = -w and B = 1 + w with w >= 0. Forcing from a constant profile then gives the same profile within the declared cloud rows. Temperature examples stay positive and moisture examples stay between zero and one. Wind can have either sign. Separate numerical cases cover the regulariser, reciprocal ordering, signed zeros and underflow; they do not assert that every finite arbitrary matrix is a physical transport system. Positive zero outside cloud equations is unused helper storage, rather than a claim that atmospheric temperature is zero.

## GNU Fortran interface

Export cubidiag_ for GNU Fortran 12.3 on AArch64. Registers x0 to x7 hold addresses of KIDIA, KFDIA, KLON, KLEV, KCTOP, LD_LCUMASK, PA and PB. Incoming stack offsets zero and eight hold PR and PU. These explicit-shape arrays have ordinary data addresses and no hidden descriptor argument. Storage-only probing confirms all ten argument locations, 32-bit integers and logical values, true = 1 and 64-bit real values.

Preserve x19 to x29, the link register, required lower halves of v8 to v15 and 16-byte stack alignment. Do not use x18. Every final array element and each scalar remainder must remain within its declared capacity. A direct assembly canary caller must seed and check preserved registers immediately around the native body, without a C call that restores a broken register first.

## Frozen corpus and output bytes

Freeze inputs, independent manufactured targets and unchanged strict-source Fortran outputs before emission. The little-endian corpus begins with eight bytes CUBI0001 and a uint32 case count. Each case has eight int32 values: case number, KLON, KLEV, KIDIA, KFDIA, pattern, mask mode and top mode, followed by FP64 epsilon. Append complete KCTOP, LD_LCUMASK, PA, PB, PR and incoming PU arrays in that order. A complete FP64 manufactured target array follows for verification only; no solver receives it. Store no pointers, padding or clocks.

Canonical critical result files append a leading 8-byte guard, then the complete PU buffer for each case in corpus order. There is an inaccessible page immediately after each final tail. Protect input pages from writes. Compare every returned and guard byte against unchanged strict-source Fortran with zero differing bytes. Check full positive-zero storage for every unselected row and column. Report the first case, level, column and both bit patterns on a mismatch. Check unchanged FPCR in round-to-nearest mode with gradual underflow.

Independently check known manufactured solutions and the regularised triangular residual in long-double arithmetic. Residual roundoff is bounded by 128 * DBL_EPSILON times max(1, abs(b*u) + abs(A*u_previous) + abs(R)), plus 8 * DBL_TRUE_MIN. For a known solution, use 256 * DBL_EPSILON times max(1,KLEV) times max(1,abs(target)), plus 8 * DBL_TRUE_MIN. These checks complement exact source agreement. Include wind, positive temperature and moisture examples, constant and varying profiles, all-cloud and no-cloud masks, changing tops, holes in masks, first and last levels, partial and empty intervals, odd widths, zero levels, the small regulariser, a reciprocal-multiplication witness, signed zeros, subnormals, read-only inputs and protected final tails.

## Caller capture

The accepted entry trace contains 8,600 CUBIDIAG calls, all in the forecast phase: 2,150 at each of two CUDUDV sites and two CUDTDQN sites. The original sources declare or allocate all four floating-point arrays as complete (KLON,KLEV) arrays at those sites. Capture the whole capacity, including unused input bytes, and do not interpret or normalise unused cells. Validate the declared caller and record its site before comparison. Other source callers CUDUDV2, CUDTDQN2 and CUCTRACER were not observed and require separate caller evidence before forecast capture.

Each deterministic forecast record starts with uint64 call number and six int32 values: step, caller site, KLON, KLEV, KIDIA and KFDIA. FP64 epsilon follows, giving a 40-byte header. Append complete KCTOP and LD_LCUMASK to each stream. Input records then append complete PA, PB, PR and incoming PU arrays. Result records append the complete returned PU array. Source Fortran runs on an independent output allocation and native assembly runs on the real caller output. Both receive the same real inputs. The driver computes no omitted numerical stage. Compare both complete result streams and all ten saved T21 files against a fresh strict reference, preserving every byte.

## Provenance

Emit primary AArch64 assembly directly from the frozen mathematics, source order, capacities and independent verification. Use no compiler numerical assembly or intermediate representation before emission. Archive original source and caller hashes, storage probes, exact build commands, frozen corpus and source results, first emission, verifier, direct ABI caller and complete captures. Keep the original scientific executable, build and archives unchanged. This milestone includes no comparative timing or numerical conversion denominator.

## Combined forecast acceptance

The combined T21 historical forecast accepts all 8,600 calls with the other 26 verified replacements active. Each of the four original wind, temperature and moisture sites runs 2,150 times. There are 83,804 first cloud equations, 403,300 later equations and 3,434,496 positive-zero cells outside those equations. The independent triangular residual checks pass on every used equation. All 48,228,800 result-record bytes match the unchanged source, including complete output capacities. Each entry requires FPCR zero. The 25 paired streams and ten saved forecast files directly compare with the strict Fortran baseline. Whole-forecast physical validation and comparative timing remain unfinished.

The [compact record](../../../../../bench/openifs/physics/cubidiag.json) identifies the frozen corpus, source, exact command archive and actual caller capacities. The direct register-canary observer is embedded in the [critical driver](../../../../../bench/openifs/physics/cubidiag.c), so reproduction needs no untracked ABI source. Run these commands through srun in a quiet exclusive allocation, using a fresh ignored directory.

```bash
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
check_dir="$PWD/.runtime/openifs/cubidiag/reproduce"
build_root="$PWD/.runtime/openifs/strict-build"
mkdir -p "$check_dir"
gcc -fPIC -Dcubidiag_=cubidiag_assembly_ -c src/openifs/physics/cubidiag.S \
  -o "$check_dir/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror -Wno-misleading-indentation \
  bench/openifs/physics/cubidiag.c "$check_dir/assembly.o" \
  -L "$build_root/lib" -Wl,-rpath,"$build_root/lib" \
  -larpifs.DP -lfiat -ldl -lm -o "$check_dir/verify"
"$check_dir/verify" --verify .runtime/openifs/cubidiag/frozen/corpus.bin \
  "$check_dir/result"
cmp "$check_dir/result-fortran.bin" "$check_dir/result-assembly.bin"
cmp "$check_dir/result-fortran.bin" \
  .runtime/openifs/cubidiag/frozen/canonical-fortran.bin
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -fPIC \
  -Wall -Wextra -Werror -Wno-misleading-indentation \
  -c bench/openifs/physics/cubidiag_forecast.c -o "$check_dir/forecast.o"
gcc -shared -Wl,-Bsymbolic "$check_dir/forecast.o" "$check_dir/assembly.o" \
  -ldl -lm -o "$check_dir/libverify-cubidiag.so"
```

Preload the complete comparator alongside the accepted parent libraries, retain one forecast thread and compare every captured stream and saved file before acceptance. The observer accepts only the four source sites whose complete arrays have been reviewed.

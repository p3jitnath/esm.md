# OpenIFS liquid-droplet optical contract

Revision 1.1 adds combined forecast evidence and preserves the numerical contract frozen at revision 1.0 for the complete CALC_LIQ_OPTICS_SOCRATES body in OpenIFS 48.1.1. Its physical input is [radiation](../../../../../formulations/openifs/physics/radiation.md), revision 1.0. A cloud's liquid droplets absorb and scatter radiation. This helper evaluates the supplied band-specific rational fits, which are ratios of polynomials in droplet radius. Coefficient formation, cloud fractions, ice optics and radiation transport remain in their original callers.

## Physical values and units

Liquid water path L is liquid mass per horizontal area, in kilograms per square metre. Effective droplet radius r is in metres. Each spectral band is an interval of radiation wavelengths. The returned optical depth tau is dimensionless and measures how strongly the droplets attenuate radiation. Scattering optical depth tau_s measures its scattering part. The returned asymmetry g is the mean cosine of the scattering angle, so its physical range is minus one to one. All three outputs have NB bands.

The matrix C has sixteen coefficient columns. C1 has units of square metres per kilogram, C2 metres per kilogram and C3 inverse kilograms. C4, C5 and C6 have units of inverse metres, inverse square metres and inverse cubic metres. C7 and C12 are dimensionless; C8, C10, C13 and C15 have units of inverse metres; C9, C11, C14 and C16 have units of inverse square metres. These units make each sum and ratio below consistent.

```math
\tau=L\frac{C_1+r(C_2+r C_3)}{1+r(C_4+r(C_5+r C_6))},\qquad
\tau_s=\tau\left[1-\frac{C_7+r(C_8+r C_9)}{1+r(C_{10}+r C_{11})}\right],\qquad
g=\frac{C_{12}+r(C_{13}+r C_{14})}{1+r(C_{15}+r C_{16})}.
```

For a physically admissible fit, tau is nonnegative, scattering stays between zero and tau, and g stays between minus one and one. Absorption optical depth is tau minus tau_s. Doubling water path doubles both depths, while g depends on radius and coefficients. Zero water path gives zero depths; the source still returns its radius-dependent g rather than replacing it with zero. Arbitrary finite coefficient tables do not automatically satisfy the physical bounds.

## Complete ordered update

FP64 means a 64-bit floating-point value. RN rounds each operation to nearest FP64 with ties to an even final bit. Complete all optical-depth bands first, then all scattering-depth bands, then all asymmetry bands. Preserve the source's nested multiplication and addition, rather than replacing the polynomials with precomputed radius powers. Every listed intermediate is rounded separately.

For each optical-depth band, compute n = RN(r*C3), n = RN(C2+n), n = RN(r*n), n = RN(C1+n), then m = RN(L*n). Compute d = RN(r*C6), d = RN(C5+d), d = RN(r*d), d = RN(C4+d), d = RN(r*d), d = RN(1+d), then tau = RN(m/d). Multiplication by water path precedes division; L*(n/d) changes the declared bits.

For each scattering-depth band, compute n = RN(r*C9), n = RN(C8+n), n = RN(r*n), n = RN(C7+n). Compute d = RN(r*C11), d = RN(C10+d), d = RN(r*d), d = RN(1+d). Compute a = RN(n/d), w = RN(1-a), then tau_s = RN(tau*w), using the stored optical-depth output.

For each asymmetry band, compute n = RN(r*C14), n = RN(C13+n), n = RN(r*n), n = RN(C12+n). Compute d = RN(r*C16), d = RN(C15+d), d = RN(r*d), d = RN(1+d), then g = RN(n/d).

Forbid fused multiply-add, contraction, reassociation, approximate division, reduced precision and fast-math. Preserve signed zeros and gradual underflow. Require FPCR, the Arm floating-point control register, to be exactly zero before every call and unchanged afterwards. This selects round-to-nearest and gradual underflow. The original helper has no active profiling hooks or numerical dependencies.

## Bounds and interface

Require 0 <= NB <= INT32_MAX. All seven arguments are ordinary addresses except the rank-two GNU Fortran coefficient descriptor, which describes an array's base address, shape and strides. Registers x0 through x6 hold NB, coefficient descriptor, L, r, tau, tau_s and g. No argument is on the incoming stack. Integers have 32 bits and real values have 64 bits. Outputs are separate, contiguous, 8-byte-aligned NB-element buffers and do not overlap inputs or each other.

The measured GNU Fortran12.3 descriptor has 88 bytes. Its first word is the first logical coefficient's address, with element length at byte16, packed real/rank-two type at byte24 and an 8-byte span at byte32. The two dimension records start at bytes40 and64; each holds element stride, lower bound and upper bound. The first extent is at least NB and the second at least16. Positive, reversed and nonunit strides are supported. Byte offsets use the measured span and strides; all offsets and extents fit signed64-bit integers and every addressed coefficient lies in its declared allocation. The descriptor offset and bounds remain unchanged. The assumed-shape dummy's first logical indices are one, so the first used coefficient is the descriptor's base address even when actual lower bounds differ.

Only the first NB rows and first16 coefficient columns are used. Extra rows, columns and physical gaps exist but can contain arbitrary bits. Used coefficients, L and r are finite, every rounded denominator is nonzero, and all required intermediate/output values are finite. All inputs stay unchanged. With zero bands, no output entry exists and no coefficient value is used. Preserve x19 through x29, the link register, lower64 bits of v8 through v15 and16-byte stack alignment. Do not use x18. A direct assembly observer checks these registers immediately after the native call, before any C bridge can restore a defect.

## Independent verification and frozen bytes

The manufactured physical cases use constant known extinction, absorption and asymmetry, or finite positive rational coefficients. Independently evaluate the rational functions in long-double arithmetic using explicit radius powers and polynomial sums. Compare with a limit of8192*DBL_EPSILON*max(1,abs(independent result))+8*DBL_TRUE_MIN. The constant cases also check their analytic depth and water-path scaling exactly. Physical bounds use256*DBL_EPSILON*max(1,abs(tau)+abs(tau_s)) for depth rounding and256*DBL_EPSILON for g. These tolerances apply only to independent physical checks; source/native output acceptance permits zero differing bytes.

The 242-case corpus includes NB0,1,3,14,16,17,24; surplus descriptor rows; ordinary, doubled, reversed-row, doubled-column and reversed-column strides; zero water; signed zeros; nonzero subnormals; and a multiply-before-division witness. It also includes both complete configured coefficient tables at radii 4, 10, 20, 30 micrometres and water paths 0, 1/16, 1/8, 898 kilograms per square metre. Numerical edge cases do not assert that their arbitrary radius or coefficients describe a real cloud. Protect all input/descriptor/scalar pages from writes and place an inaccessible page after every exact output tail. Compare all outputs and leading guards against unchanged strict-source Fortran. The direct ABI observer is explicit assembly embedded in the retained local critical C source.

The little-endian input corpus begins with LIQO0001 and a uint32 case count. Each record stores eight int32 values: case number, NB, coefficient row extent, layout, pattern, radius index, water index and reserved zero. Two FP64 values give L and r. Two uint64 values give physical coefficient-storage cells and first-logical-element index. An88-byte descriptor follows with its pointer word zeroed, then complete physical coefficient storage and three incoming NB-element outputs. Reconstruct only the pointer from the separately captured base index; preserve all other descriptor bits. Canonical result files append an8-byte guard and complete output for tau, tau_s and g in that order for every case. Report the first mismatching case, output, band and two64-bit patterns.

## Current forecast scope

The original accepted compiler-entry trace recorded318,360 visits, with159,180 at each CLOUD_OPTICS longwave and shortwave source site. That historical trace remains unchanged. The current strict ordered-vertical reference makes317,920 calls, with158,960 at each site and4,768,800 band results. Its ten saved files directly match the accepted strict-vertical-fortran-7189435 baseline. Freeze these configurations separately; a routine visit count does not establish a numerical conversion denominator.

CLOUD_OPTICS lines312 and317 pass complete16-band longwave and14-band shortwave tables, each with16 coefficient columns. Its explicit result arrays have the corresponding full band capacities at source lines242–248. The caller computes liquid water path from pressure thickness, gravity, liquid mass fraction and cloud fraction, and calls this helper only for positive in-cloud water and the configured SOCRATES model. The current source-only capture observes radii4–30 micrometres and water path from9.230846461370022e-14 to897.9928696202279 kilograms per square metre. All configured returned depths and asymmetry satisfy the declared optical bounds. This proves the helper's sampled source domain, while full cloud/radiation physics requires separate verification.

Every forecast record stores uint64 call number, four int32 values for step, NB, table and source site, then FP64 L and r, giving40 bytes. Input records append the whole NB-by16 coefficient matrix and all three incoming outputs; result records append all three returned outputs. Preserve every call, band and input byte. The native comparator calls source Fortran on separate outputs and direct assembly on the real caller outputs, then checks complete bytes and input immutability. Compare all ten saved T21 files with the newly captured strict source reference. Other callers or coefficient layouts need their own capacity evidence before forecast capture.

## Provenance and limits

Freeze original source/caller hashes, storage-only probes, coefficient tables, critical corpus, independently accepted source outputs, current source-only forecast and exact build/capture commands before first direct emission. Emit AArch64 directly from this mathematics and storage contract. Inspect numerical compiler instructions only afterwards to verify the frozen arithmetic, preserving every attempt and private ELF. No driver supplies an omitted numerical stage. This milestone establishes no comparative timing, complete assembly forecast, whole-forecast physical proof or exact numerical conversion percentage.

## Combined forecast acceptance

The combined forecast accepts all 317,920 original calls at the two CLOUD_OPTICS sites. All 127,168,000 complete returned record bytes also match the source-only stream frozen before generation. The whole coefficient tables and incoming output capacities are captured on every call, with all inputs unchanged and FPCR exactly zero. All 27 paired streams directly compare across 2,835,414,408 bytes, and all ten saved files match the strict Fortran baseline. The independent optical and ABI checks remain separate from these exact comparisons.

The [compact record](../../../../../src/openifs/README.md) identifies the corpus, source tables, first emission and exact command archive. Run the following commands through srun in a quiet exclusive allocation, using a fresh ignored output directory. The direct register observer is embedded in the retained local critical driver.

```bash
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
check_dir="$PWD/.runtime/openifs/calc_liq_optics_socrates/reproduce"
build_root="$PWD/.runtime/openifs/strict-build"
mkdir -p "$check_dir"
gcc -fPIC \
  -D__radiation_liquid_optics_socrates_MOD_calc_liq_optics_socrates=calc_liq_optics_socrates_assembly_ \
  -c src/openifs/physics/calc_liq_optics_socrates.S -o "$check_dir/assembly.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror -Wno-misleading-indentation \
  .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/calc_liq_optics_socrates.c "$check_dir/assembly.o" \
  -L "$build_root/lib" -Wl,-rpath,"$build_root/lib" -larpifs.DP -lfiat -lm \
  -o "$check_dir/critical"
"$check_dir/critical" --verify \
  .runtime/openifs/calc_liq_optics_socrates/frozen/corpus.bin "$check_dir/result"
cmp "$check_dir/result-fortran.bin" "$check_dir/result-assembly.bin"
cmp .runtime/openifs/calc_liq_optics_socrates/frozen/canonical-fortran.bin \
  "$check_dir/result-fortran.bin"
gcc -O2 -mcpu=neoverse-v2 -fPIC -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror -Wno-misleading-indentation \
  -c .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/physics/calc_liq_optics_socrates_forecast.c \
  -o "$check_dir/forecast.o"
gcc -shared -Wl,-Bsymbolic "$check_dir/forecast.o" "$check_dir/assembly.o" \
  -ldl -lm -o "$check_dir/libverify-liquid-optics.so"
```

Preload the native object with this source-scoped observer into a fresh copy of the frozen T21 case. Retain the existing accepted helpers and directly compare every captured stream and saved file. The observer supplies no optical calculation stage.

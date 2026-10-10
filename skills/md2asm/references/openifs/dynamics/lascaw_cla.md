# LASCAW_CLA Latitude Weight Contract

Documentation revision 1.1 preserves the frozen numerical revision 1.0 and the unchanged first assembly body. The complete helper copies, blends and smooths supplied latitude weights. All coordinates, weights and smoothing parameters are dimensionless. Original coordinate searches and cubic-weight construction remain in LASCAW.

## Physical Calculation

A semi-Lagrangian forecast follows air back to its earlier position and interpolates the field there. Four weights multiply four nearby values. The helper stores only three weights because later interpolation uses the first value as its base. Write the complete supplied cubic vector as $`h=(h_0,h_1,h_2,h_3)`$, with $`h_0=1-h_1-h_2-h_3`$. The correction vector $`h^m`$ follows the same rule.

Let $`d`$ be the supplied latitude distance and $`v_1,v_2,v_3`$ the selected geometry coefficients. The quadratic lower-order vector is

```math
q=d(1-d),\qquad
\ell_1=1-d+qv_1,\qquad
\ell_2=d+qv_2,\qquad
\ell_3=qv_3,\qquad
\ell_0=1-\ell_1-\ell_2-\ell_3.
```

The older linear vector is $`(0,1-d,d,0)`$. Quadratic selection takes precedence when both choices are enabled. Let $`m`$, $`M`$ and $`r`$ be the minimum, maximum and reference blend values. Horizontal diffusion uses supplied coefficient $`\kappa`$ and matrix $`D`$. Choose $`m_s=m`$ for a clear kappa sign bit, including positive zero, and $`m_s=r`$ for a set sign bit, including negative zero.

```math
a=(1-m_s)h+m_s\ell,\qquad
b=(1-M)h+M\ell,\qquad
s=(1-\lvert\kappa\rvert)a+\lvert\kappa\rvert Db.
```

The source supplies three-by-three matrices. Expand each to a full four-weight operator with $`F_{00}=1`$, $`F_{j+1,k+1}=D_{jk}`$ and $`F_{0,k+1}=1-\sum_{j=0}^{2}D_{jk}`$, leaving other entries zero. This restores the implicit coefficient. An arbitrary latitude matrix is not assumed to preserve the weighted mean position.

Without diffusion, the quadratic branch gives main and filtered vectors $`(1-m)h+m\ell`$. Other branches copy $`h`$. Correction always copies $`h^m`$. A separate turbulence pass uses coefficient $`t`$ and full operator $`T`$.

```math
a_{\mathrm{new}}=(1-2t)a+2tTa,\qquad
s_{\mathrm{new}}=(1-2t)s+2tTs.
```

Signed parameters test the algebra and extrapolation. They do not establish nonnegative physical diffusion. The independent reference checks all four coefficients and degree-zero through degree-three moments, meaning weighted sums of basis powers.

## Supported Domain

Four canonical 32-bit logical words select diffusion, quadratic weights, older linear weights and turbulence. Their bit mask uses weights one, two, four and eight. Masks one and nine are excluded because original low-order locals are undefined. All other fourteen masks are supported. The observer rejects unsupported flags before source binding or any other argument read. The primary returns at its first flag guard.

Let $`B`$ be horizontal width, $`L`$ level count, $`C=BL`$ and $`R=NDGENH-NDGSAH+1`$. Support $`0\le B\le1024`$, $`0\le L\le256`$, $`1\le KST\le B+1`$, $`0\le KPROF\le B`$ and $`1\le R\le4096`$. Only rows KST through KPROF change. Empty intervals and zero dimensions preserve every byte. Used table slots lie inside the full allocation. Selected mathematical values are finite and satisfy the bound below. Present unused bytes remain opaque, including NaNs and signed zeros. Unused arrays may be absent with zero extent.

The forecast observer covers spherical irregular computational latitude and KDIMK one. This makes its C-cell turbulence input the complete caller-local allocation. Larger original KDIMK allocations require additional capacity proof and are excluded. Standalone critical cases supply complete leaf inputs while allowing larger enclosing output families.

The split-physics route that uses local ZCLA at the last KDIMK slot is excluded because its full local capacity is not supplied by these parent families. Regular-meridian setup is also outside the actual observer domain. Neither exclusion changes the supported supplied-input mathematics.

## Interface And Complete Storage

All twenty-one arguments are ordinary pointers. Integer and logical words have four bytes and real words have eight. The two derived objects are complete read-only storage. A derived object groups several original Fortran values.

| Arguments in original order | Full extent and meaning |
| --- | --- |
| YDSL | 1,800 bytes. NDGLG, NDGSAH, NDGENH and NFRSTLOFF offsets are 1,648, 1,672, 1,676 and 1,720. Embedded pointees are unused. |
| YDDYNA | 456 bytes. Maximum and reference offsets are 120 and 128. |
| KFLEV, KPROM, KST, KPROF | Four integers for levels, width and selected rows. |
| LDT | Four canonical logical words. |
| PSLHDKMIN | One real, required for diffusion or quadratic selection. |
| KILA | C integers. Selected indices are read even on the copy route. |
| PWH, PWHMAD | Each has 3C cubic input reals. |
| PDLAT, PDLAMAD | Each has C words when present. PDLAT is used by either lower-order choice. PDLAMAD is always unused. |
| PKAPPA, PKHTURB | Each has C words when present, used only by diffusion or turbulence. |
| PSLD | 3R reals in three planes, used only by quadratic selection. |
| PSLDW, P3DTW | Each has 9R reals, used only by diffusion or turbulence. |
| PCLA, PCLAMAD, PCLASLD | Three writable 3C-real views for main, correction and filtered weights. |

For zero-based row and level, cell $`p=\mathrm{row}+B\,\mathrm{level}`$. Input coefficient plane j uses $`\mathrm{row}+B(3\,\mathrm{level}+j)`$. Output plane j uses $`p+jC`$. Matrix slot is KILA plus one minus NDGSAH, with matrix offset $`r+3c+9\,\mathrm{slot}`$. Real arrays need eight-byte alignment and indices need four. Inputs stay read-only and separate from mutable storage. The three mutable leaf views are disjoint, while their larger enclosing families can overlap.

The 78-pointer LASCAW scope relay reads four complete parent families, main, correction, filtered and heat-filtered. The first three contain 3C times KDIMK reals and heat contains 3C. It selects the largest family containing each view and merges overlaps into raw union regions. Headers preserve all four capacities, pairwise alias relationships, region IDs and view windows. Compare each entire union, including inactive rows and neighbouring windows.

The relay also retains full parent coordinates, reciprocal cubic denominators, target coordinates and correction factors, with R, 3R, C and C reals. Independent pre-execution checks use the original four-node Lagrange formula and correction target. The selected irregular provider row must obey $`0\le KILA+1+NFRSTLOFF\le NDGLG`$. This follows the original setup values and is checked directly.

Optional read-only CLA scope hooks can share the existing VINTW relay. The complete original seventy-eight pointers are forwarded once, without any new mathematics. A combined CLA build omits its own LASCAW relay. Keep the previous accepted VINTW source and library preserved before preparing this composition.

## Ordered Arithmetic And Arm ABI

Use binary64 nearest rounding with ties to even, gradual underflow and signed zeros. FPCR, the Arm floating-point control register, is zero before and after the body. Forbid fused multiply-add, contraction, reassociation, approximate operations, reduced precision and fast-math.

Round every quadratic subtraction, product and addition separately in original order. Identical one-minus-d expressions may share their rounded result. The older candidate calculates one minus d, copies d and uses positive zero for its third coefficient, including when the later branch copies cubic weights.

SIGN of one half comes from kappa's sign bit. Preserve the separately rounded expression $`(0.5+\mathrm{sign})m-(\mathrm{sign}-0.5)r`$, including both zero products. Each blend subtracts original from candidate, multiplies by its coefficient and adds original. ABS clears the sign bit. Every matrix row forms three rounded products, adds the first two and then the third.

Finish the whole first pass before turbulence. In the second pass, calculate each complete main matrix triple before main writes, then each filtered triple before filtered writes. Each update separately rounds t times two, matrix minus old, their product and old plus product. Identical rounded t times two may be shared. All copies and numerical passes stay inside assembly.

The application binary interface, ABI, defines arguments and preserved registers. The first eight pointers arrive in x0 through x7. Thirteen more occupy incoming stack offsets zero through ninety-six. The unchanged primary uses a 208-byte aligned frame, preserves x19 through x29 and calls no numerical helper. It uses neither x18 nor the preserved low halves of v8 through v15. A 128-byte forwarding wrapper supplies all twenty-one pointers to the register checker without supplying mathematics.

The LLM emitted this complete body directly from the frozen contract. Only an assembler and linker construct its object. No compiler numerical assembly or intermediate representation was used to construct it.

## Scientific And Byte Acceptance

The independent full-weight reference uses 113-bit arithmetic and a separate pre-emission 100-digit Decimal calculation. Let H and Hm be complete input-weight magnitude sums, V the selected quadratic-table magnitude sum, Dn and Tn the selected matrix magnitude sums and K the largest used blend magnitude. Unused branch terms are zero only in this independent bound.

```math
S=(1+H+H_m)(1+\lvert d\rvert)^2(1+V)(1+2K)
(1+D_n)(1+2\lvert\kappa\rvert)(1+T_n)(1+4\lvert t\rvert).
```

Require finite $`S<DBL\_MAX/4096`$ before either body. The coefficient limit is $`4096(2^{-52}+2^{-1074})S`$. A moment multiplies this by one plus its basis-power magnitude sum. The independent parent cubic limit additionally accounts for node spacing. These checks never change captured bits.

Canonical files retain little-endian binary64 and integer bytes. Each 640-byte header records order, scalar flags, shape, presence, complete extents, aliases, windows and original caller offset. Input records preserve every complete incoming allocation. Returned records preserve every complete mutable union. Critical files additionally have a 64-byte global header. Compare files directly with zero differing bytes, without rounding, masking or normalisation. Hashes identify archived artifacts.

Before emission, original-source science and the independent source peer passed the complete fourteen-mask contract. The 1,512-case corpus has nine shapes and twelve profiles, including eighty-four overlapping-family cases, empty loops, partial rows, signed zeros, subnormals, extrapolation, quadratic precedence, nullable unused arguments and opaque unused NaNs. It checks 1,891,386 coefficients and 2,521,848 full-weight moments. Every protected source replay matches all 24,218,944 critical returned bytes and all 2,150 frozen calls across 71,964,800 bytes.

The unchanged first ELF function has 361 instructions and 1,444 bytes. The preserved initial disassembly count includes three following alignment NOPs, giving 364 instructions and 1,456 bytes. The primary passes 1,512 protected cases and 1,525 ABI calls, including three genuine concurrent calls and ten first-flag guards with other pointers null. All original frozen forecast calls and independent mathematics pass. There is no accepted comparative timing.

The actual source calls have B 24, L 19, latitude bounds minus one and 34, NDGLG 32, offset zero, KDIMK one and mask zero. There are 2,125 full-row calls and twenty-five eight-row calls. Each actual containing union has 10,944 bytes. This route copies supplied weights. The complete fourteen-mask mathematical verification does not claim those other branches occur in this forecast.

The isolated paired forecast and shared VINTW-relay forecast each pass all 2,150 complete CLA pairs across 71,964,800 bytes, with zero differences. All ten saved files pass across 618,140 bytes in each run. The shared route also passes all 6,450 VINTW pairs across 637,776,000 bytes. Both observer routes retain the unchanged numerical objects and all original caller arguments.

Every one of 58,608,400 selected scientific input bytes matches the original source-only capture in both forecasts, and the separate fresh returned archives match in full. Complete fresh incoming archives differ by 3,628,359 unused bytes in the isolated run and 2,006,868 in the shared run. Differences include opaque derived-object bytes and unused input storage. Both full incoming archives and their first differences remain preserved. No full fresh input identity is claimed, and no bit is masked or normalised.

The reviewed forty-seven-body combined forecast passes all forty-five complete paired streams across 6,493,203,208 bytes and ten saved files across 618,140 bytes. Its 2,150 complete latitude-weight returns also directly match the separate original source archive in full. All 58,608,400 selected scientific input bytes match. Complete fresh incoming archives differ by 2,478,191 unused bytes, which remain preserved without masking or normalisation. Root independently runs this public recipe and directly reproduces the whole primary and ABI objects and both public comparator libraries. Their earlier private-build debug metadata remains separately qualified.

## Reproduce

Run on the verified exclusive node. Use a unique ignored directory and keep full frozen inputs available. The C driver provides allocation, forwarding and independent checks only.

```sh
task_dir=.runtime/openifs/lascaw_cla-public-reproduction
mkdir -p "$task_dir"
gcc -c -march=armv8.2-a+sve src/openifs/dynamics/lascaw_cla.S \
  -o "$task_dir/lascaw_cla.o"
gcc -c -march=armv8.2-a+sve bench/openifs/dynamics/vertical_abi.S \
  -o "$task_dir/vertical_abi.o"
gcc -O2 -g -mcpu=neoverse-v2 -fopenmp -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror bench/openifs/dynamics/lascaw_cla.c \
  "$task_dir/lascaw_cla.o" "$task_dir/vertical_abi.o" -lm \
  -o "$task_dir/verify"
"$task_dir/verify" \
  .runtime/openifs/lascaw_cla-7207705/preparation/critical-inputs.bin \
  .runtime/openifs/lascaw_cla-7207705/preparation/critical-fortran.bin \
  .runtime/openifs/lascaw_cla-7207705/preparation/critical-independent.bin \
  "$task_dir/assembly.bin" "$task_dir/summary.json"
cmp "$task_dir/assembly.bin" \
  .runtime/openifs/lascaw_cla-7207705/preparation/critical-fortran.bin
"$task_dir/verify" --actual \
  .runtime/openifs/runs/strict-lascaw_cla-source-complete2-7207705/t21/test_fc/lascaw_cla-inputs.bin \
  .runtime/openifs/runs/strict-lascaw_cla-source-complete2-7207705/t21/test_fc/lascaw_cla-fortran.bin \
  "$task_dir/frozen-assembly.bin" "$task_dir/frozen-summary.json"
cmp "$task_dir/frozen-assembly.bin" \
  .runtime/openifs/runs/strict-lascaw_cla-source-complete2-7207705/t21/test_fc/lascaw_cla-fortran.bin
gcc -O2 -g -mcpu=neoverse-v2 -fPIC -shared -fopenmp \
  -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror \
  bench/openifs/dynamics/lascaw_cla_forecast.c "$task_dir/lascaw_cla.o" \
  -ldl -lm -o "$task_dir/libverify-lascaw_cla.so"
```

For combined use, add `-DLASCAW_CLA_EXTERNAL_SCOPE` to the observer build and use the reviewed VINTW relay with the pure metadata hook pair. Keep exactly one LASCAW relay. All numerical setup and other unported bodies remain original.

# LASCAW_VINTW Vertical Weight Contract

Documentation revision 1.2 records acceptance and the public reproduction commands. The immutable revision 1.0 froze the complete supported mathematical body after original-source science and full capture, before direct assembly emission. The equations, ordered arithmetic and first assembly body remain unchanged. Positions, weights and smoothing parameters have no unit.

## Physical Calculation

A semi-Lagrangian forecast follows air motion back to an earlier position and interpolates the earlier field there. Let $`B`$ be rows, $`L`$ levels, $`C=BL`$ cells, $`x`$ position and $`k`$ node index. Interior cells have $`1\le k\le L-3`$ and use four distinct nodes $`n_j=\eta_{k+j}`$. Four-node Lagrange weights reproduce a polynomial through degree three.

```math
h_j(x)=\prod_{m\ne j}\frac{x-n_m}{n_j-n_m},
\qquad h_0=1-h_1-h_2-h_3.
```

Only weights one through three are stored because later interpolation uses the first sample as its base. COMAD, the correction-coordinate flag, chooses $`x_m=(n_1+n_2)/2+s(x-(n_1+n_2)/2)`$, where $`s`$ is `PSTDDISW`. Otherwise its weights equal the cubic set.

A quadratic lower-order set uses supplied distance $`d`$, $`q=d(1-d)`$ and geometry coefficients $`v`$. The older linear set stores $`(1-d,d,0)`$. Quadratic weights take precedence.

```math
\ell_1=1-d+qv_1,\qquad \ell_2=d+qv_2,\qquad
\ell_3=qv_3,\qquad \ell_0=1-\ell_1-\ell_2-\ell_3.
```

Semi-Lagrangian horizontal diffusion, abbreviated SLHD, uses minimum $`m`$, maximum $`M`$ and diffusion matrix $`D`$. The main set receives $`a`$, the diffusion set receives $`w_D`$, and heat uses the same expression with $`\kappa_T`$. The vertical-filter set receives $`Va`$ with its own matrix. Correction stays cubic at $`x_m`$.

```math
a=h+m(\ell-h),\qquad b=h+M(\ell-h),\qquad
w_D=a+\lvert\kappa\rvert(Db-a).
```

Without SLHD, the quadratic branch blends with its minimum, while other branches keep cubic weights. Main and diffusion sets then agree. Heat stays untouched. The vertical filter still acts when enabled.

Outside the interior, main stores $`(1-d,d,0)`$ and correction stores $`(1-d_m,d_m,0)`$. Diffusion changes only with SLHD, heat only with SLHD and heat together, and vertical-filter output only with its flag. Every other byte stays unchanged.

Independent checks derive the reciprocal denominators and quadratic geometry from the original `SUVSLETA` node gaps. Each stored three-by-three matrix expands to a full four-by-four matrix with the implicit first weight. Check preservation of the four-weight sum and first coordinate moment, meaning the weighted mean position. Signed parameters preserve the checked algebra. Nonnegative averaging needs suitable nonnegative geometry and matrix entries as a separate physical condition.

## Flags And Actual Caller

The six-bit mask follows `LDCOMADV`, `LDT_SLHD(1:3)`, `LDSLVF` and `LDSLHDHEAT`. Each logical word is a canonical 32-bit zero or one. The three middle flags select SLHD, quadratic and older linear weights. Reject the eight masks with SLHD enabled but both lower-order flags clear, because their source locals are undefined. The other fifty-six masks are supported. Reject noncanonical logical words before numerical input reads.

The actual 6,450 calls have $`B=24`$, $`L=19`$, mask 48, `KWIS=106` and `KWENO=3`. WENO combines candidate interpolation stencils to avoid oscillations. There are 6,375 full-row calls and 75 eight-row calls. Main and filter families each contain nine $`C`$ planes, while other families contain three. Their three-plane window offsets descend through 21,888, 10,944 and zero bytes, each 2,150 times. The original caller return offset is `0x3ea8e0`.

WENO shifts the node index by one while keeping original `PDVER` and `PDVERMAD`. A shifted lower-order set follows its supplied distance on that shifted pair. It need not reproduce `PLEV` as a blended-output target. Preserve this source convention.

Minimum is present. Unused COMAD, kappa and heat-kappa arrays are absent. Geometry tables and all output families are present. Heat stays untouched because SLHD is disabled. The vertical filter is active.

## Typed Interface And Complete Storage

Twenty-seven ordinary pointers arrive without descriptors or hidden lengths. Integers and logicals have four bytes, and reals have eight. The matched GNU Fortran `TDYNA` has 456 bytes, with `SLHDKMAX` and `SLHDKREF` at offsets 120 and 128. Preserve the whole object.

| Ordered arguments | Complete extent |
|---|---|
| `YDDYNA` | 456 read-only bytes. |
| `KPROM, KFLEV, KST, KPROF` | Four integers for rows, levels and selected interval. |
| `LDCOMADV, LDT_SLHD, LDSLVF, LDSLHDHEAT` | One, three, one and one logicals. |
| `PSLHDKMIN` | One real when present. |
| `KLEV` | $`B\times L`$ integers. |
| `PLEV, PDVER, PDVERMAD, PSTDDISW, PKAPPA, PKAPPAT` | Each $`B\times L`$ when present. |
| `PVETA` | Reals with bounds $`0:L+1`$. |
| `PVCUICO` | $`4\times(0:L-1)`$ reals. |
| `PVSLD` | $`3\times(0:L-1)`$ reals. |
| `PVSLDW, PVSLVF` | Each $`3\times3\times(0:L-1)`$ reals. |
| `PVINTW, PVINTWMAD, PVINTWSLD, PVINTWSLT, PVINTWSLVF` | Each passed view is $`B\times L\times3`$. |

Inputs are read-only, and the last five arguments are mutable outputs. Rows vary fastest, followed by levels and coefficient planes. Zero-based cell $`p=\mathrm{row}+B\,\mathrm{level}`$ has plane offset $`p+iC`$. Table level bounds are zero. Matrix entry $`(r,c,k)`$ has real offset $`r+3c+9k`$.

Support $`0\le B\le1024`$, $`0\le L\le256`$, $`1\le KST\le B+1`$ and $`0\le KPROF\le B`$. Selected indices lie in $`0:L-1`$. Empty loops preserve all bytes. Integer data need four-byte alignment, and real data need eight. Outputs are disjoint from each other and every input. Inputs may overlap.

Unused arguments may be absent. Capture presence separately, give absent storage zero extent, and preserve every present complete buffer, including unused NaNs and padding. Check only values used by the selected branch. Used nodes are distinct, and used geometry tables pass their independent checks.

A read-only `LASCAW` scope relay forwards all seventy-eight original pointers without supplying mathematics. It freezes enclosing bases and `KWENO`, supporting one or three slots. Main and filter capacities are $`3\,KWENO\,C`$ reals, with $`3C`$ in other families. Validate every current window and preserve all neighbour windows and inactive bytes.

## Ordered Arithmetic

FPCR, the Arm floating-point control register, is zero. Use nearest rounding with ties to even, gradual underflow and signed zeros. `RN` means one binary64 rounding. Every source multiplication, addition and subtraction rounds separately. Forbid fused multiply-add, contraction, reassociation, approximate operations, reduced precision and fast-math.

First form four distances $`z_j=\mathrm{RN}(x-n_j)`$. Stored cubic expressions are `((z0*z2)*z3)*cubic[1+4*k]`, `((z0*z1)*z3)*cubic[2+4*k]` and `((z0*z1)*z2)*cubic[3+4*k]`, with every product separately rounded from the left.

For COMAD, first replace `z0` by `RN(z0-z1)` and `z3` by `RN(z3-z2)`. Then use `z1=RN(RN(z1*s)+RN(RN(0.5*RN(n2-n1))*RN(1-s)))` and `z2=RN(RN(z2*s)-RN(RN(0.5*RN(n2-n1))*RN(1-s)))`. Add `z1` to `z0` and `z2` to `z3` before computing its cubic triple. Reuse only expressions with identical ordered operands and rounded bits.

For quadratic weights, preserve `q=RN(d*RN(1-d))`, `RN(RN(q*v1)+RN(1-d))`, `RN(RN(q*v2)+d)` and `RN(q*v3)`. Older weights copy `d`, subtract it from one and store positive zero.

`SIGN(0.5,kappa)` keeps the kappa sign bit, including negative zero. Preserve the five-operation minimum expression `(0.5+s)*minimum-(s-0.5)*reference`, including zero products. `ABS(-0.0)` gives positive zero. Each blend subtracts the original weight, multiplies by its parameter and adds the original weight.

Every matrix row computes three rounded products, adds the first two and then the third. Complete each triple before replacing its inputs. Boundary constants and exact copies stay inside the solver. Independent complete points may finish all paths while their weights stay in registers.

## Arm ABI

The application binary interface, ABI, specifies arguments and preserved registers. Pointers one through eight arrive in `x0` through `x7`. Nineteen more occupy incoming stack bytes zero through 144, starting with `LDSLHDHEAT`.

Preserve the stack pointer, `x18`, all callee-saved general registers and the low 64 bits of `v8` through `v15`. Preserve FPCR. Call no numerical helper. A twenty-seven-pointer wrapper forwards all arguments through the existing ABI checker and supplies no numerical stage.

## Bytes And Acceptance

A 384-byte actual header records ten scalar/logical values, parent choices, presence, full extents, caller offset and five window offsets, followed by nineteen complete incoming extents. Returned records repeat the header and five enclosing families. Critical records add a 64-byte global header and eight-real prefix and suffix guards.

Compare complete same-input returns, frozen-input replay and all ten saved files directly, requiring zero differing bytes. Include inactive rows, unused heat, neighbour windows and signed zeros. Hashes identify artifacts. Never mask, round for comparison or normalise bits.

Guard selected finite values before either body. Let $`R=1+\lvert x\rvert+\sum_j\lvert n_j\rvert+\lvert d\rvert+\lvert s\rvert`$, $`P`$ be the largest absolute used reciprocal denominator, $`K`$ the largest absolute used blend parameter, and $`\|\,\|_1`$ the sum of absolute stored entries. Require the following intermediate scale below `DBL_MAX/65536`.

```math
R^3(1+P)(1+\lvert s\rvert)^3(1+\lvert d\rvert)^2(1+\|v\|_1)
(1+2K)(1+\|D\|_1)(1+\|V\|_1)(1+2\lvert\kappa\rvert+2\lvert\kappa_T\rvert).
```

Let $`g`$ be the smallest used node separation and $`Q=1+(\lvert x\rvert+\sum_j\lvert n_j\rvert)/g`$. The independent forward-error scale and coefficient limit are below.

```math
S=(1+\|h\|_1+\|h_m\|_1+\|\ell\|_1)Q(1+\lvert s\rvert)^3
(1+2K)(1+\|D\|_1)(1+\|V\|_1)(1+2\lvert\kappa\rvert+2\lvert\kappa_T\rvert),
\qquad \delta=8192\,2^{-52}S+8192\,2^{-1074}S.
```

Require $`S<\mathrm{DBL\_MAX}/65536`$. Every coefficient error is at most $`\delta`$. A degree-$`q`$ moment uses $`\delta(1+\sum_j\lvert n_j^q\rvert)`$. Boundaries use $`S=1+\lvert d\rvert+\lvert d_m\rvert`$. Unused parameters contribute zero only to independent calculations. Captured bytes stay intact.

## Accepted Checks

Before emission, the original source passed 6,048 critical cases, 8,815,488 independent 100-digit coefficient checks and 4,002,944 polynomial moments. The complete source-only forecast passed 6,450 calls, 34,565,397 coefficient checks and 17,054,997 moments at 113 binary bits. All ten saved files matched the canonical forecast. The independent source peer found no blocker in the original equations, caller bounds or complete enclosing storage.

The unchanged first assembly body has 410 instructions and 1,640 instruction bytes, with no numerical helper or fused arithmetic. Its 320-byte frame preserves integer registers x19 through x28. It uses neither x18 nor the preserved floating-point registers. The protected verifier passed 6,048 cases and 6,071 ABI calls, including three genuine parallel calls and twenty unsupported-flag calls with all other pointers null. Every one of 147,524,032 complete returned bytes matched the original reference, and all 8,815,488 independent coefficients passed.

The full frozen-input replay passed all 6,450 original calls and 637,776,000 returned archive bytes. The isolated native forecast passed the same complete source and assembly pairs, 69,130,794 coefficient checks and 34,109,994 moments across both implementations. All ten saved files directly matched across 618,140 bytes. Separate fresh source and native returned archives also matched in full, including every untouched neighbour window and inactive byte.

Separate fresh input archives differ by 239,562 bytes in unused index cells and unused cubic, lower-order and matrix table slots. All 49,441,352 selected numerical input bytes match. Both whole incoming archives remain preserved, so this result does not claim full fresh input identity. No input or output bit was masked or normalised. Source and native observer guards also rejected twenty unsupported logical probes before either numerical body. Public capacity guards restrict the relay to the frozen one-or-three-window domain before source forwarding, without changing the accepted three-window route.

No comparative timing is accepted for this body. The instrumented forecast wall time includes complete capture, shadow-source execution and independent scientific checks.


Root reproduction passes the complete public recipe, all original-input replays and twenty-four logical or capacity guards. Fresh primary and ABI objects, the complete public verifier and shared library directly match their accepted counterparts. The selected forty-four-body combined forecast passes forty-two complete paired streams across 5,909,648,008 bytes and ten saved files across 618,140 bytes. All selected VINTW inputs and 34,565,397 written coefficient values also match the separate original source capture. Unused incoming and returned storage can differ between fresh runs, and every such byte remains archived. Whole separate-run input and return identity is not claimed.

The current observer optionally shares its original parent relay with CLA. A complete pair of metadata hooks records the original geometry and enclosing capacities, forwards the same seventy-eight pointers once, then closes that separate scope. With both hooks absent, the standalone route retains its previous behaviour. The forty-seven-body combined forecast verifies all 6,450 complete VINTW returns across 637,776,000 bytes. Its numerical assembly, ABI and critical driver remain unchanged. The earlier observer source, library and reproduction records remain preserved.

## Reproduce The Accepted Checks

Use a unique ignored directory and run these commands on the exclusive node allocation. The existing ABI checker forwards arguments and checks register preservation. It supplies no interpolation, correction, smoothing or boundary calculation.

```sh
task_dir=.runtime/openifs/lascaw_vintw-public-reproduction
mkdir -p "$task_dir"
gcc -c -x assembler-with-cpp -mcpu=neoverse-v2 \
  src/openifs/dynamics/lascaw_vintw.S -o "$task_dir/lascaw_vintw.o"
gcc -c -x assembler-with-cpp -mcpu=neoverse-v2 \
  -DLASCAW_VINTW_ABI_CHECK src/openifs/dynamics/lascaw_vintw.S \
  -o "$task_dir/lascaw_vintw-abi.o"
gcc -fPIC -march=armv8-a+simd -c \
  bench/openifs/dynamics/vertical_abi.S -o "$task_dir/vertical-abi.o"
gcc -O2 -g -mcpu=neoverse-v2 -fopenmp -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/lascaw_vintw.c \
  "$task_dir/lascaw_vintw-abi.o" "$task_dir/vertical-abi.o" -lm \
  -o "$task_dir/verify"
"$task_dir/verify" \
  .runtime/openifs/lascaw_vintw-7207705/preparation/critical-inputs.bin \
  .runtime/openifs/lascaw_vintw-7207705/preparation/critical-fortran.bin \
  .runtime/openifs/lascaw_vintw-7207705/preparation/critical-independent.bin \
  "$task_dir/assembly.bin" "$task_dir/summary.json"
cmp "$task_dir/assembly.bin" \
  .runtime/openifs/lascaw_vintw-7207705/preparation/critical-fortran.bin
"$task_dir/verify" --actual \
  .runtime/openifs/runs/strict-lascaw_vintw-source-complete-7207705/t21/test_fc/lascaw_vintw-inputs.bin \
  .runtime/openifs/runs/strict-lascaw_vintw-source-complete-7207705/t21/test_fc/lascaw_vintw-fortran.bin \
  "$task_dir/frozen-assembly.bin" "$task_dir/frozen-summary.json"
cmp "$task_dir/frozen-assembly.bin" \
  .runtime/openifs/runs/strict-lascaw_vintw-source-complete-7207705/t21/test_fc/lascaw_vintw-fortran.bin
gcc -O2 -g -mcpu=neoverse-v2 -fPIC -shared -fopenmp \
  -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror \
  .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/lascaw_vintw_forecast.c \
  "$task_dir/lascaw_vintw.o" -ldl -lm \
  -o "$task_dir/libverify-lascaw_vintw.so"
```

For combined forecasts, keep exactly one LASCAW scope relay. This comparator forwards the original LASCAW body unchanged and captures all five complete coefficient families. Append its shared library while retaining the accepted leaf comparators. It introduces no SPCM relay, and the old SIMPLICO observer remains omitted.

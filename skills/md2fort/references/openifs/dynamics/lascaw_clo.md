# LASCAW_CLO Longitude Weight Contract

Documentation revision 1.2 records the accepted first assembly body and complete isolated forecast. The frozen numerical contract remains revision 1.0. The direct solver builds all three output sets and performs every supported interpolation and smoothing stage.

## Physical Calculation

A semi-Lagrangian forecast follows air motion back to an earlier position and interpolates the earlier field there. This routine builds the longitude weights for that interpolation. The coordinate $`x`$ is the distance from the central western grid point, divided by the grid spacing. Coordinates, weights and smoothing parameters have no unit.

For four equally spaced nodes $`n_j=j-1`$, where $`j=0,1,2,3`$, cubic Lagrange weights reproduce polynomials through degree three.

```math
h_j(x)=\prod_{m\ne j}\frac{x-n_m}{n_j-n_m},
\qquad
f(x)=\sum_{j=0}^{3}h_j(x)f(n_j).
```

Only $`h_1,h_2,h_3`$ are stored. The later interpolator uses the first sample as the base, so it needs no stored $`h_0=1-h_1-h_2-h_3`$. The correction set uses a second coordinate, `PDLOMAD`.

A quadratic lower-order set or an older linear set can reduce cubic interpolation. The quadratic set stores these three weights. The linear set stores $`(1-x,x,0)`$.

```math
\ell_1=(1-x)(1+x/4),\qquad
\ell_2=x(5/4-x/4),\qquad
\ell_3=x(x-1)/4.
```

A blend changes a weight from $`h_i`$ to $`h_i+a(\ell_i-h_i)`$. A horizontal smoother with parameter $`e`$ changes a stored triple $`c`$ to $`D_e(c)`$.

```math
D_e(c)=
\begin{pmatrix}
(1-2e)c_1+ec_2\\
ec_1+(1-2e)c_2\\
ec_2+c_3
\end{pmatrix}.
```

The smoother keeps the four-weight sum and first polynomial moment. It therefore preserves constant fields and the position of a linear field. For smoothing parameters between zero and one half, its changed second moment gives a nonnegative averaging operation. Signed parameters retain the algebraic moment checks but need no physical diffusion interpretation.

## Original Branches

Logical flags use the canonical 32-bit integer values zero and one. Their bit mask follows this table.

| Bit | Original flag | Effect |
|---|---|---|
| 0 | `LDT(1)` | Enable semi-Lagrangian horizontal diffusion, abbreviated SLHD. |
| 1 | `LDT(2)` | Choose quadratic lower-order weights. |
| 2 | `LDT(3)` | Choose old linear weights when bit 1 is clear. |
| 3 | `LDT(4)` | Apply the final turbulence smoother to both main sets. |

Masks 1 and 9 enable SLHD without defining a lower-order set. They are outside this contract and are rejected before either body. The other fourteen masks are supported. Quadratic weights take precedence when both lower-order flags are set.

Let `minimum` be `PSLHDKMIN`. The parameters `maximum`, `reference` and `epsilon` are the three selected members of `YDDYNA`. The original sign operation gives $`s=+1/2`$ for a clear sign bit and $`s=-1/2`$ for a set sign bit. Negative zero therefore selects the reference parameter.

```math
m=(1/2+s)\,\mathrm{minimum}-(s-1/2)\,\mathrm{reference},
\qquad
a=h+m(\ell-h),\qquad
d=h+\mathrm{maximum}(\ell-h).
```

The main set receives $`a`$. The diffusion set receives $`a+\lvert\kappa\rvert(D_{\mathrm{epsilon}}(d)-a)`$. Without SLHD, a quadratic branch blends with `minimum`, while the other branch keeps the cubic set. Both sets are then equal. The correction set always receives cubic weights at `PDLOMAD`.

The final turbulence flag applies $`D_t`$ separately to the main and diffusion sets. The correction set stays unchanged. Compute each whole triple before overwriting it.

## Typed Interface And Complete Storage

The original GNU Fortran module gives a 456-byte `TDYNA` object. Its selected real members `SLHDKMAX`, `SLHDKREF` and `SLHDEPSH` occur at byte offsets 120, 128 and 136. The full object, including unused members and padding, is read-only and retained as raw bytes.

Integers and logicals have 32 bits. Reals have 64 bits. Fourteen ordinary pointers have no array descriptors or hidden lengths.

| Arguments | Shape or extent | Use |
|---|---|---|
| `YDDYNA` | 456 bytes | Full read-only derived object. |
| `KFLEV`, `KPROM`, `KST`, `KPROF` | Four integers | Levels $`L`$, rows $`B`$, first and last selected row. |
| `LDT` | Four logicals | Branch flags. |
| `PSLHDKMIN` | One real when present | Used only for SLHD or the quadratic branch. |
| `PDLO`, `PDLOMAD` | Each $`B\times L`$ | Interpolation coordinates. |
| `PKAPPA`, `PKHTURB` | Each $`B\times L`$ when present | Used only for SLHD and turbulence, respectively. |
| `PCLO`, `PCLOMAD`, `PCLOSLD` | Each $`B\times L\times3`$ | Complete mutable output views. |

Rows vary fastest, followed by levels and coefficient planes. Put $`C=BL`$. A zero-based cell has $`p=\mathrm{row}+B\,\mathrm{level}`$, and plane $`i`$ occurs at $`p+iC`$. Each output view contains $`3C`$ reals. Outputs must be disjoint from each other and every input extent. Inputs can overlap each other.

Supported shapes have $`0\le B\le1024`$, $`0\le L\le256`$, $`1\le KST\le B+1`$ and $`0\le KPROF\le B`$. Empty loops preserve all output bytes. Integers and logicals require four-byte alignment. Reals and the derived object require eight-byte alignment.

Unused minimum, kappa or turbulence arguments can be absent. Record their presence, giving an absent argument zero allocated bytes. Preserve every present full buffer, including unused opaque values. Selected numerical inputs must be finite. Epsilon is finite with $`\lvert e\rvert\le\mathrm{DBL\_MAX}/4`$ because the source forms $`1-2e`$ unconditionally.

The original `LASCAW` caller declares contiguous coefficient planes and passes unsliced row and level extents. Actual calls use the two central-latitude views at original source lines 873 and 877. All 4,300 calls have $`L=19`$, $`B=24`$, mask zero, present minimum, absent kappa and present unused turbulence. There are 4,250 full-row calls and 50 eight-row calls.

## Ordered FP64 Arithmetic

`RN` means one binary64 rounding operation with nearest rounding and ties to even. The Arm floating-point control register, called FPCR, must be zero. Preserve gradual underflow and signed zeros. Use separate addition, subtraction and multiplication. Fused multiply-add, contraction, reassociation, approximate operations and reduced precision are forbidden.

The source constant `PP6_R` has bits `0x3fc5555555555555`. It is the rounded compile-time value of one sixth. Preserve every source operand order and intermediate rounding point.

| Cubic weight | Ordered source expression |
|---|---|
| 1 | `((0.5 * RN(x + 1)) * RN(x - 1)) * RN(x - 2)` |
| 2 | `((-0.5 * RN(x + 1)) * x) * RN(x - 2)` |
| 3 | `((PP6_R * RN(x + 1)) * x) * RN(x - 1)` |

Each multiplication is also rounded separately. Both coordinate triples need thirty-two rounded operations per point. The quadratic triple needs ten operations, while the linear triple needs one subtraction. SLHD needs forty operations after its lower-order triple. A non-SLHD quadratic blend needs nine operations. Turbulence needs twenty-four operations for both output sets. The unconditional epsilon coefficient needs two entry operations.

For each blend, subtract the original weight, multiply by its scalar and add the original weight. Preserve the five-operation signed minimum expression, including zero multiplications. `SIGN(0.5,-0.0)` gives negative one half, while `ABS(-0.0)` gives positive zero.

The SLHD smoother adds diagonal-then-off-diagonal products in its first row and off-diagonal-then-diagonal products in its second row. Its third row adds the off-diagonal product to the original third component. Turbulence adds diagonal products first in both first and second rows, matching the source. Every operation rounds separately.

Complete points are independent. Assembly can keep their weights in registers and finish each point's turbulence update before advancing, preserving every dependency and rounding point.

## Arm ABI

The application binary interface, abbreviated ABI, puts the first eight pointers in `x0` through `x7`. The remaining stack slots at byte offsets 0, 8, 16, 24, 32 and 40 contain `PDLOMAD`, kappa, turbulence and the three outputs.

Preserve the stack pointer, `x18`, all callee-saved general registers and the low 64 bits of `v8` through `v15`. Preserve FPCR and call no numerical helper. A separate fourteen-pointer wrapper supplies every argument and exposes preserved-register changes to the existing ABI checker. It supplies no polynomial, blend or smoothing stage.

## Canonical Bytes And Scientific Acceptance

Canonical returned bytes contain complete main, correction and diffusion arrays, in that order, including every inactive cell. No byte is masked, rounded for comparison or normalised. Frozen replay supplies identical full inputs and incoming outputs to both bodies. Acceptance requires zero differing bytes and direct comparison of all ten saved forecast files.

Independently evaluate four-node Lagrange products, expanded four-weight blends and a full conservative four-by-four smoothing matrix. Use 113 binary bits for all original forecast values and 100 decimal digits for the critical corpus. Check every coefficient, both final first moments and the correction set's first three moments. Check the higher reproduced moments when an unsmoothed cubic or quadratic branch permits them.

For each selected point, use $`X=1+\lvert x\rvert+\lvert x_{\mathrm{MAD}}\rvert`$, largest absolute used blend parameter $`K`$, used smoothing magnitude $`E`$, kappa magnitude $`k`$ and turbulence magnitude $`T`$. Unused parameters contribute zero only to the independent reference and its bound. Captured bytes remain unchanged.

```math
S=8X^3(1+2K)(1+3E)(1+2k)(1+3T),
\qquad S<\mathrm{DBL\_MAX}/256,
```

```math
\delta=2048\,2^{-52}S+2048\,2^{-1074}S.
```

Coefficient errors must be at most $`\delta`$, and weighted moment errors must be at most $`100\delta`$. This bound covers finite source operations and the rounded one-sixth constant. Exact bytes remain a separate requirement.

Before emission, the source passed 1,512 critical cases, 1,891,386 independent 100-digit coefficients and 1,230,902 moments. The actual source-only forecast passed 17,510,400 coefficients and 9,728,000 moments at 113 bits. All ten saved files matched the canonical forecast. Ten unsupported-flag probes stopped before an original-body trap, with zero numerical capture bytes. That scientific acceptance preceded primary emission. The accepted unchanged first body has 229 instructions and 916 primary bytes, with no numerical helper or stack frame. It passed 1,512 protected cases and 1,525 ABI calls, including three genuine parallel calls and ten unsupported-flag calls with every other pointer null.

The native frozen-input replay matched all 4,300 original calls and 142,003,200 complete returned archive bytes. The isolated forecast also passed all complete same-input pairs, all independent 113-bit coefficient and moment checks, and all ten saved-file comparisons. Separate fresh source-only and native return archives are wholly identical, including inactive cells.

The fresh input archives differ only in present unused turbulence storage, by 4,859,104 bytes and 637,288 words across 4,300 calls. These bytes include caller stack residue and remain fully archived. All 3,891,200 selected coordinate pairs and 4,300 used epsilon pairs are identical. Full incoming archive identity is therefore not claimed. No input or output byte was masked or normalised.

The source-only and native static peer reviews found no blocker. The native review checked all 91 frozen references, original module and caller identity, all fourteen masks, conditional argument presence, complete storage, rounding order and the Arm ABI. It did not rerun simulations. No comparative timing is accepted for this model.

## Reproduce The Accepted Checks

Use the original archived inputs and references below. Keep build products in a unique ignored directory and run these commands through the exclusive node allocation. The existing ABI checker measures register preservation and supplies no numerical stage.

```sh
task_dir=.runtime/openifs/lascaw_clo-public-reproduction
mkdir -p "$task_dir"
gcc -c -x assembler-with-cpp -mcpu=neoverse-v2 \
  src/openifs/dynamics/lascaw_clo.S -o "$task_dir/lascaw_clo.o"
gcc -c -x assembler-with-cpp -mcpu=neoverse-v2 -DLASCAW_CLO_ABI_CHECK \
  src/openifs/dynamics/lascaw_clo.S -o "$task_dir/lascaw_clo-abi.o"
gcc -fPIC -march=armv8-a+simd -c bench/openifs/dynamics/vertical_abi.S \
  -o "$task_dir/vertical-abi.o"
gcc -O2 -g -mcpu=neoverse-v2 -fopenmp -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/lascaw_clo.c \
  "$task_dir/lascaw_clo-abi.o" "$task_dir/vertical-abi.o" -lm \
  -o "$task_dir/verify"
"$task_dir/verify" \
  .runtime/openifs/lascaw_clo-7207705/preparation/critical-inputs.bin \
  .runtime/openifs/lascaw_clo-7207705/preparation/critical-fortran.bin \
  .runtime/openifs/lascaw_clo-7207705/preparation/critical-independent.bin \
  "$task_dir/assembly.bin" "$task_dir/summary.json"
cmp "$task_dir/assembly.bin" \
  .runtime/openifs/lascaw_clo-7207705/preparation/critical-fortran.bin
gcc -O2 -g -mcpu=neoverse-v2 -fPIC -shared -fopenmp \
  -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror \
  .runtime/assembly-markdown-cleanup-7207705/preserved-published-2aef826/bench/openifs/dynamics/lascaw_clo_forecast.c "$task_dir/lascaw_clo.o" \
  -ldl -lm -o "$task_dir/libverify-lascaw_clo.so"
```

The selected forty-two-body combined forecast also passes every complete source/native pair across forty streams and 5,016,076,808 returned bytes. All ten saved files directly match across 618,140 bytes. All active longitude coefficients, selected coordinates and used epsilon values also match the original source capture. Fresh unused turbulence and incoming inactive output bytes remain fully retained. Complete returned arrays match the original source, including inactive cells. No full incoming archive identity is claimed.

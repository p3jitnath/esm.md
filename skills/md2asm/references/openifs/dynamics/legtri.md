# Triangular Spherical Basis Contract

The physics input is [associated_legendre_basis.md](../../../../../formulations/openifs/dynamics/associated_legendre_basis.md), revision 1, equation LG1. The original control is OpenIFS `arpifs/transform/legtri.F90`. All values and outputs use FP64 and have no units.

## Supported Inputs

The four addresses are `PSIN`, `KCP`, `KDIM` and `PALP`. `PSIN` is a finite sine of latitude in `[-1,1]`. `KCP=N+1` is a signed 32-bit integer from 2 to 256. `KDIM` is the complete output owner length and is from `KCP*(KCP+1)/2` to 1,048,576 cells. The source writes its second cell unconditionally, so a one-cell truncation is outside the supported source domain. The assembly rejects an unsupported scalar domain before output writes.

## Method and Storage

Store the functions with order `m=0,1,...,N` as the outer index and degree `n=m,m+1,...,N` as the inner index. The first cells are 1 and `sqrt(3)*PSIN`. The triangular cell count is `KCP*(KCP+1)/2`, and any remaining cells in the `KDIM` owner keep their original bytes.

For each order, calculate `M=FP64(m)`, `C=sqrt(1-PSIN*PSIN)`, `R=sqrt((M+M)+3)` and `E=1/R`. For `m>0`, form the diagonal as `F2=(F1*C)/sqrt(M+M)`, then set `F1=F2*R`. Store `F2` for degree `m` and, when present, `F1*PSIN` for degree `m+1`.

For each remaining degree, calculate `T=FP64(n)*FP64(n)` and `A=sqrt(((4*T)-1)/(T-(M*M)))`. The next stored value is `A*((PSIN*previous)-(E*previous_previous))`. Then set `E=1/A`. Each multiplication, subtraction, division and square root rounds separately in the written order. The diagonal update also preserves this order. Integer-to-FP64 conversions are exact in the supported domain.

The complete leaf needs no numerical child, allocation or workspace. It uses exact hardware division and square root, with no fused, approximate or reduced-precision instruction.

## Interface and Output

The Arm application binary interface receives four addresses in `x0` through `x3`. FP64 owners are aligned to at least 8 bytes and integer owners to at least 4 bytes. The caller keeps a 16-byte aligned stack. The leaf does not change the stack and uses only caller-saved registers, preserving `x18`, `x19` through `x29` and the low 64 bits of `v8` through `v15`.

The floating-point control register must be zero, which selects round-to-nearest with ties to even, gradual underflow and separate FP64 rounding. The leaf rejects another register value before writes and preserves the register. It does not normalise signed zero. The canonical output is the complete `KDIM` little-endian FP64 owner, including unchanged trailing cells. Acceptance requires zero differing bytes against the original control.

## Scientific Checks

The original control first passes independent values from the 200-digit derivative of Rodrigues' polynomial with factorial normalisation. The frozen absolute value limit is `512*epsilon*(n+1)^1.5 + 512*smallest_subnormal`, where `epsilon=2^-52`. A second independent identity checks `P(n,0)^2+2*sum(P(n,m)^2,m=1..n)=2*n+1` with limit `1024*epsilon*(n+1)*(2*n+1)`. The supported poles, signed zeros and complete degree range remain in the input corpus.

Protected output owners at both memory-page edges check complete writes and trailing bytes. Source and native controls use the same frozen scalars. The immediate four-address wrapper checks Arm register and FPCR obligations. A paired relay validates each actual input domain before writes, compares the complete original and native output owners and returns the unchanged original bytes.

## Register Storage

A short arithmetic leaf can keep its recurrence in caller-saved registers, so it needs no stack frame or helper dispatch. The output and recurrence factor use caller-saved registers during each step. The ordered triangular layout gives contiguous stores while each operation preserves the original rounding.

## Actual Forecast Acceptance

The combined coarse forecast in exclusive allocation 7240564 on nid010555 passes these positive actual calls with zero differing bytes. Each byte scope describes the complete owners compared by that routine.

| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| legtri | 12,800 | 6,758,400 | Complete returned routine owners |

All ten saved files also match across 618,140 bytes. The accepted critical physics and interface checks are reused. These checks cover the declared routine domains and saved files. Whole-forecast physical verification, whole-process byte identity and comparative timing remain open in the [coverage record](../../../../../src/openifs/README.md).

# OpenIFS Spectral Latitude Contract

Contract revision 1.0 covers complete SPNSDE, UVTVD and VDTUV from local OpenIFS 48.1.1 and its ectrans transform library. It implements the [latitude and wind formulation](../../../../../formulations/openifs/dynamics/spectral_latitude_operators.md), revision 1.0. Every original arithmetic and boundary stage is inside [the direct assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/dynamics/spectral_latitude_operators.S).

## Coefficients And Packing

Let N be NSMAX, T be NTMAX and M be KM. These are nonnegative integer wave limits with no units. Require 0 <= M <= N <= T, with N and T at most 4,096. K is the nonnegative number of scalar fields or wind levels, at most 4,096. Each complex field uses two columns. Column 2k-1 is its real part and column 2k is its imaginary part. M equal to zero uses only real output columns.

The supplied coefficient EPS(n) equals the square root of (n²-M²)/(4n²-1) for n >= M. The original zero-degree coefficient can be negative zero and its bits are preserved. RN(n) stores FP64 n. L(n) stores the rounded inverse-Laplace value -a²/[n(n+1)] for positive n and positive zero for n equal to zero or minus one. NLTN(n) stores T+2-n. These fixed tables belong to the caller. The direct routines read their original rounded values.

| Routine | Row for degree n | Returned degrees |
| --- | --- | --- |
| SPNSDE | N+3-n | M through N+1 |
| VDTUV | N+3-n | M through N+1 |
| UVTVD | T+2-n | M through T |

SPNSDE and VDTUV require rows through N+4-M, including the two neighbouring input rows. UVTVD requires rows through T+3-M. Its complete first stage sets both wind inputs at row NLTN(M-1) to positive zero for every real and imaginary field. Its derivative stage then uses these prepared rows. All other input entries remain unchanged.

## Ordered Updates

FP64 is the 64-bit floating-point format. Every product, sum and subtraction below rounds separately to the nearest FP64 value, with ties to even. Keep parentheses, signed zeros and subnormal values. Do not fuse, reassociate or approximate an operation. Empty field sets write no array bytes.

For SPNSDE, degree n receives -(n-1)EPS(n)f(n-1)+(n+2)EPS(n+1)f(n+1). Each coefficient is formed in that stated order from RN, then multiplied by the input before the final addition. Visit every column when M is positive and only the real columns when M is zero.

VDTUV first uses the caller's rounded inverse-Laplace values for both potentials. The lower product is RN(n-1) times EPS(n), then L(n-1), then the selected input. The upper product is RN(n+2) times EPS(n+1), then L(n+1), then its input. When M is positive, first form M times L(n), then the matching opposite complex component. The real longitude term negates M before its products. Add the lower rotational term and subtract the upper term for U. Subtract the lower spreading term and add the upper term for V. For M equal to zero, omit the longitude terms entirely. The first V product negates RN before multiplication, preserving the original zero signs.

UVTVD uses the lower product RN(n+1) times EPS(n), then the row for n-1, and the upper product RN(n) times EPS(n+1), then the row for n+1. For positive M, vorticity starts with imV, subtracts the upper U product and adds the lower U product. Divergence starts with imU, adds the upper V product and subtracts the lower V product. The real longitude component negates M before multiplication. For zero M, omit the longitude products, negate RN(n) before the first vorticity product, and preserve the original remaining sum or subtraction.

These three bodies do not include the surrounding transforms or their metric conversions. The two wind packings in the physical formulation are different, so passing VDTUV outputs directly to UVTVD would omit a required surrounding transform stage.

## Bounds And GNU Interface

SPNSDE exports __spnsde_mod_MOD_spnsde with five address arguments, KM, KF_SCALARS, EPS, F and NSD. UVTVD exports __uvtvd_mod_MOD_uvtvd with seven addresses, KM, KFIELD, EPS, U, V, VOR and DIV. VDTUV exports __vdtuv_mod_MOD_vdtuv with seven addresses, KM, KFIELD, EPS, VOR, DIV, U and V. All arrive in x0 through x6. Scalars are signed INTEGER4. EPS is a contiguous FP64 array with original indices zero through T+2.

Every matrix is a GNU Fortran rank-two descriptor. Its base is at byte 0, row stride at 40 and column stride at 64, with strides measured in elements. Dummy row and column indices start at one. The matrix has enough rows and at least 2K columns. Signed strides and gaps are supported when the complete owner fits signed 64-bit address arithmetic. Consumed cells in different arguments must not overlap when either cell is written. Distinct array views can share unused storage. The local comparison preserves this shared storage by copying each complete owner union once. FP64 addresses have eight-byte alignment, INTEGER4 addresses have four-byte alignment, and the stack stays 16-byte aligned.

The original module R pointer identifies a 56-byte dimension object with NSMAX at 0 and NTMAX at 4. The F pointer identifies a 728-byte coefficient object. Its RN, RLAPIN and NLTN descriptors begin at 408, 472 and 536. These rank-one allocatable tables have stride one and lower bound minus one. Their original extents cover every consumed index. R, F, EPS and all scalar inputs remain unchanged.

The routines preserve x19 through x29 and the link register. They leave x18 and v8 through v15 unused. SPNSDE uses an 80-byte frame and the wind routines use 256 bytes. There is no numerical child, omitted stage, high-level solver or scratch owner. Only the stated outputs and UVTVD's prepared input row may change.

## Physics And Acceptance

The complete original source passed independent normalized-Legendre derivative identities and spherical curl, divergence and velocity-potential checks before assembly emission. The small verifier covers zero fields, zero wave order, all real-only and complex branches, odd field counts, high truncation, both unreadable-page placements, signed strides, gaps and unchanged complete module owners.

Each original body passed 528 protected calls. SPNSDE covers 1,289,728 complete owner bytes and 3,960 physical identities, UVTVD covers 5,158,912 bytes and 7,920 identities, and VDTUV covers 2,579,456 bytes and 7,920 identities. The physical fixture has radius one metre, while the assembly uses the caller's rounded metric tables for any declared positive radius. The canonical records preserve every complete mutable owner, including inactive entries and gaps. The unchanged direct bodies pass all 9,028,096 canonical bytes with zero differences. Thirty-six additional native calls pass unequal truncations, signed zeros, subnormal inputs, read-only owners and immediate register checks over 73,920 returned bytes. The paired interface passes the same small arithmetic corpus and three shared-storage cases over 4,200 carrier bytes. Three active-alias cases are rejected before those 4,200 shared bytes change.  The acceptance limit is zero differing bytes and FPCR zero. No comparative speed result is claimed.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| spnsde_mod::spnsde | 550 | 8,800,000 | Input and returned owner unions |
| uvtvd_mod::uvtvd | 1,100 | 33,440,000 | Input and returned owner unions |
| vdtuv_mod::vdtuv | 1,100 | 32,806,400 | Input and returned owner unions |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

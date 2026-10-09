# OpenIFS CPQTUV contract

Contract revision 1.1 clarifies physical acceptance limits while preserving the complete numerical body frozen in revision 1.0 for OpenIFS 48.1.1. Its physical input is [state-change rates](../../../../../formulations/openifs/dynamics/state_rates.md), revision 1.0. A rate describes the change per second. This routine applies the supplied physics rates to the earlier wind, temperature and tracer states, then corrects small cloud and precipitation amounts. The source-only caller is EC_PHYS_DRV. The accepted T21 trace contains 2,150 calls, all in the forecast phase.

## Method and ordered arithmetic

FP64 denotes a 64-bit floating-point value. RN64 rounds each operation to the nearest FP64 value, choosing an even final bit in a tie. Wind uses metres per second, temperature uses kelvin, time uses seconds and water components use kilograms per kilogram. Other tracers keep their caller units. Treat each supplied rate as constant over PDT seconds and calculate each wind, temperature and selected tracer state as follows.

```math
X_1=\operatorname{RN}_{64}\left(X_9+\operatorname{RN}_{64}(\Delta t S)\right).
```

Update PUT1, PVT1 and PTT1 at each active point. Visit YCOMP descriptors in increasing order. When LT1 is true, MP1 selects the new tracer field and MP9_PH selects its earlier field. Apply the same multiply and add to PGFLT1 at MP1. Preserve descriptor order, including repeated MP1 values, because a later descriptor then uses the preceding rounded result as its incoming rate.

The named descriptors select vapour Q, liquid L, ice I, rain R, snow S and cloud fraction A. RALVDCP and RALSDCP have units of kelvin and convert condensed water changes to temperature changes. Visit L, I, R and S in this order. If its LT1 flag is true and its value is less than RLMIN, add that value to Q, subtract the separately rounded latent-heat product from temperature, and store positive zero in that component. Use RALVDCP for L and R and RALSDCP for I and S. Signed correction values follow the same equations.

When L, I and A all have LT1 true, round L + I once. If A < RAMIN or this sum < RLMIN, add the rounded sum to Q. Subtract the rounded RALVDCP * L product from temperature, then subtract the rounded RALSDCP * I product from that result. Store positive zero in L, I and A. If A has LT1 true and A > 1, store exactly 1. All comparisons are strict. Equality with a threshold does not trigger its correction.

If YPHYCTY has LACTIVE true, copy PCONVCTY into PGFL at its MP field. PCONVCTY uses inverse seconds. If LDNODRYFLX is also true and all five water descriptors have LACTIVE true, calculate one water change at each point. For each component in Q, L, I, R, S order, separately round the new-minus-old difference, the PGFL_DYN * PDT product and their subtraction. Add those five results from left to right to obtain d. Then visit every YCOMP descriptor in order and, when LT1 is true, multiply its selected PGFLT1 value by the rounded value 1 - d. Repeated selections apply this factor repeatedly. Sum the resulting Q, L, I, R and S values from left to right to obtain q. Update the saved continuity rate with the following separate subtraction, two divisions and addition.

```math
c_1=\operatorname{RN}_{64}\left(c_0+\operatorname{RN}_{64}\left(\operatorname{RN}_{64}\left(d/\operatorname{RN}_{64}(1-q)\right)/\Delta t\right)\right).
```

Preserve every rounding point, signed zero and gradual underflow. Use round to nearest with ties to even. Forbid fused multiply-add, contraction, reassociation, approximate division, reduced precision and fast-math. This body has no exponential, logarithm or square-root dependency. Load the two latent-heat constants from the unchanged YOETHF module.

## Buffers and configuration

Require positive KPROMA, nonnegative KFLEV, 1 <= KSTART <= KPROMA and KSTART - 1 <= KPROF <= KPROMA. Zero levels and empty intervals change no array. PDT is positive and finite. Used states, constants and intermediate values are finite. For the optional water-mass correction, its two denominators are nonzero and its results are finite. RAMIN and RLMIN are finite and nonnegative.

The six wind and temperature arrays and PCONVCTY have shape (KPROMA,KFLEV). PGFL has shape (KPROMA,KFLEV,NDIM). PGFLT1 and PGFL_DYN have shape (KPROMA,KFLEV,NDIM1). All use 8-byte-aligned FP64 values in Fortran order. Extents and address calculations fit signed 64-bit integers. NDIM and NDIM1 are nonnegative and NUMFLDS lies between 0 and 2163. Each active YCOMP descriptor has 1 <= MP1 <= NDIM1 and 1 <= MP9_PH <= NDIM. Inactive descriptor indices can be invalid and must not cause a field access.

All seven named component pointers identify valid component objects. Every component index actually used by a correction is valid for its buffer. The six named new fields are distinct. An active continuity field has 1 <= MP <= NDIM and is separate from the five earlier water fields. This restriction matches the declared caller mode and avoids changing an earlier water value before the optional correction reads it. Unused fields and arrays can have empty storage. In particular, PGFL_DYN is accessed only inside the enabled five-component water-mass correction, and PCONVCTY is accessed only when the continuity field is active.

The five mutable arrays PUT1, PVT1, PTT1, PGFLT1 and PGFL are separate from each other, all read-only inputs and both configuration objects. Only active columns and fields selected by the declared operations can change. Preserve every other output bit. PGFL_DYN, PCONVCTY, PUT9, PVT9, PTT9 and both configuration objects remain unchanged. Although the source declares YDECLDP as input/output, this body does not write it.

## GNU Fortran interface

Export cpqtuv_ for GNU Fortran 12.3 on AArch64. Registers x0 to x7 hold addresses of YDECLDP, YGFL, KPROMA, KSTART, KPROF, KFLEV, PDT and LDNODRYFLX. Incoming stack offsets 0, 8, 16, 24, 32, 40, 48, 56, 64 and 72 hold PUT9, PVT9, PTT9, PGFL, PGFL_DYN, PCONVCTY, PUT1, PVT1, PTT1 and PGFLT1. Integer and logical values use 32 bits. Preserve x19 to x29, the link register, 16-byte stack alignment and the required parts of v8 to v15. Do not use x18. Profiling hooks are excluded.

Storage-only probes freeze these byte offsets. TECLDP occupies 2,776 bytes, with RAMIN at 112 and RLMIN at 120. TYPE_GFLD occupies 1,359,136 bytes, with NUMFLDS at 0, NDIM at 48 and NDIM1 at 64. YCOMP starts at 3,848 and has 2,163 components of 368 bytes. Each component has LACTIVE at 64, LT1 at 92, MP at 168, MP9_PH at 184 and MP1 at 188. The named component pointer slots are YQ 799840, YL 799856, YI 799848, YR 799920, YS 799912, YA 799984 and YPHYCTY 801104. Load the pointer in each slot before reading its component. Measure these offsets again for another compiler or configuration.

## Verification and canonical bytes

Freeze the small corpus before assembly emission. Its little-endian stream starts with the eight bytes CPQTUV01 and a uint32 case count. Each case has twelve int32 values: case number, mode, KPROMA, KSTART, KPROF, KFLEV, NDIM, NDIM1, NUMFLDS, LDNODRYFLX, pattern and trajectory index. Five FP64 values follow: PDT, RAMIN, RLMIN, RALVDCP and RALSDCP. Then append NUMFLDS groups of five int32 values in LACTIVE, LT1, MP, MP1 and MP9_PH order and seven int32 component numbers for Q, L, I, R, S, A and PHYCTY. Append the complete incoming PUT1, PVT1, PTT1, PGFLT1 and PGFL arrays, followed by complete PUT9, PVT9, PTT9, PGFL_DYN and PCONVCTY arrays. Store no addresses, padding or clocks.

Compare unchanged strict-source Fortran with complete direct assembly using zero differing bytes for all five complete mutable arrays, guards and unchanged entries. Protect inputs and configuration from writes. Put an inaccessible page after each final array tail. Cover complete and partial intervals, odd widths, zero levels, empty intervals, alternate field maps, repeated descriptor targets, all combinations of cloud and precipitation LT1 flags, optional continuity and water-mass branches, signed zero, gradual underflow, exact thresholds and eight-field earlier storage versus six-field new and dynamics storage. Report the first case, field, level, column and both bit patterns on a mismatch. Check that FPCR is unchanged.

Independently check known wind and temperature rates, repeated constant-rate states, conservation of total water during condensate evaporation and cloud clearing, the latent-heat balance H = T - RALVDCP * (L + R) - RALSDCP * (I + S), the cloud upper bound within the physical cases below, and the optional water-mass and continuity balances. Use long-double arithmetic and declared roundoff bounds for these physical checks. Exact reference agreement does not replace them. Canonical small outputs concatenate complete PUT1, PVT1, PTT1, PGFLT1 and PGFL buffers, with their leading guards, for each case in corpus order. Both output streams must compare directly.

The forecast verifier calls unchanged Fortran on independent copies of all five mutable arrays, then direct assembly on the real arrays. Capture the full NDIM earlier buffer and only NDIM1 fields for the new and dynamics buffers. Each record contains uint64 call number, int32 step, the same twelve int32 case values with case number zero, the five FP64 constants, all descriptor values and the seven named descriptor values as five-int32 groups; these named groups replace the synthetic corpus component numbers. Input records append the five incoming mutable arrays and the five read-only arrays in corpus order. Result records append the five complete mutable arrays. No padding or pointer values separate fields. The driver supplies no numerical stage and compares all ten saved forecast files against a fresh strict reference.

The 45 physical water-mass cases have d = 1/512, factor 1 - d = 511/512, total water below one and cloud fraction 0.5 before rescaling. All 1,089 decoded active cloud values in the frozen returned corpus lie between zero and one. The source caps cloud fraction before optional rescaling. Its wider finite signed-input computational domain preserves that order, but these physical checks establish cloud admissibility only for the accepted physical cases, with 0 <= d < 1 and 0 <= q < 1. No final-cloud bound is claimed for arbitrary signed mass changes.

## Provenance and limits

Emit primary assembly directly from this contract and build it with an assembler and linker. Read the original scientific source and storage/caller evidence before emission; inspect no compiler-generated numerical instructions or intermediate representation until after emission. Archive frozen corpus, source, contract, storage probe, build commands and output identifiers. This conversion does not establish a required numerical denominator. Forecast LNODRYFLX is false in the frozen T21 startup record, so the enabled water-mass branch also requires the independent small corpus. No comparative timing is part of this checkpoint.

## Combined forecast acceptance and reproduction

The fresh combined T21 forecast accepts all 2,150 CPQTUV calls, with 86 at each time visit from zero through 24. It captures the complete earlier eight-field allocation and complete new six-field allocation. There are 2,125 full 24-column blocks and 25 final eight-column blocks, all at 19 levels. Every returned buffer byte, including inactive cells, matches the original source across 134,194,400 canonical bytes. The reviewed observer requires all FPCR bits to be zero before every call. The optional continuity and dry-flux branches are inactive here and remain covered by the frozen critical physical cases. All 24 paired streams and ten saved files directly compare with the strict Fortran baseline. Own exclusive job 7189435 on nid010825 supplies CPU 0 and local memory placement.

The [compact record](../../../../../bench/openifs/dynamics/cpqtuv.json) retains the frozen source, contract, corpus, actual call metadata and full command archives. The [direct ABI bridge](../../../../../bench/openifs/dynamics/cpqtuv_abi.S) forwards all 18 original arguments and checks preserved registers before restoring its own state. Its tracked source rebuilds to the identical accepted object. Whole-forecast physical validation and comparative timing remain unfinished.

Run the following commands through srun in a quiet exclusive allocation. Use the frozen strict OpenIFS build and a new ignored output directory.

```bash
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
check_dir="$PWD/.runtime/openifs/cpqtuv/reproduce"
build_root="$PWD/.runtime/openifs/strict-build"
mkdir -p "$check_dir"
gcc -fPIC -Dcpqtuv_=cpqtuv_assembly_ -c src/openifs/dynamics/cpqtuv.S \
  -o "$check_dir/assembly.o"
gcc -c bench/openifs/dynamics/cpqtuv_abi.S -o "$check_dir/abi.o"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror bench/openifs/dynamics/cpqtuv.c \
  "$check_dir/assembly.o" "$check_dir/abi.o" -Wl,--wrap=cpqtuv_assembly_ \
  -L "$build_root/lib" -larpifs.DP -lfiat -ldl -lm \
  -Wl,-rpath,"$build_root/lib" -o "$check_dir/verify"
"$check_dir/verify" --verify .runtime/openifs/cpqtuv/frozen/corpus.bin \
  "$check_dir/result"
cmp "$check_dir/result.assembly.bin" "$check_dir/result.fortran.bin"
cmp "$check_dir/result.assembly.bin" \
  .runtime/openifs/cpqtuv/frozen/reference.fortran.bin
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -fPIC \
  -Wall -Wextra -Werror -c bench/openifs/dynamics/cpqtuv_forecast.c \
  -o "$check_dir/forecast.o"
gcc -shared -Wl,-Bsymbolic "$check_dir/forecast.o" "$check_dir/assembly.o" \
  -ldl -lm -o "$check_dir/libverify-cpqtuv.so"
```

The forecast observer binds the unchanged EC_PHYS_DRV scientific image and checks the declared original worker ranges. Its exact whole-array capacity uses NDIM for the earlier tracer state and NDIM1 for new states and dynamics rates. Preload it alongside the accepted parent comparators, retain one forecast thread and compare all emitted streams and saved files before acceptance.

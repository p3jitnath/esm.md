# OpenIFS verification

Thirty complete public direct assembly routines are verified in OpenIFS 48.1.1. Their small checks include independent physical balances, exact output bytes, optional inputs, boundaries and buffer guards. The latest coarse forecast used own exclusive job 7189435 on nid010825, with one process, one thread, CPU 0 and local memory binding. Each routine's compact record preserves its earlier checks.

| Routine | Critical cases | Critical bytes | Forecast calls checked | Forecast bytes | Differing bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| CPSPE | 449 | 1,934,944 | 2,150 | 19,109,200 | 0 |
| GPRCP | 3,976 | 899,712 | 13,846 | 81,643,584 | 0 |
| GPPWC | 13 | 5,616 | 36,120 | 140,145,600 | 0 |
| GPRT | 73 | 82,848 | 2,150 | 23,598,400 | 0 |
| GPGRP | 46 | 36,480 | 2,150 | 15,910,000 | 0 |
| GPMKTEND | 69 | 228,888 | 2,150 | 117,957,600 | 0 |
| GPADDSLPHY | 117 | 343,216 | 2,150 | 43,636,400 | 0 |
| GP_TNDLAGADIAB_UV | 137 | 219,776 | 2,150 | 31,536,200 | 0 |
| GPGRXYB | 192 | 640,032 | 2,150 | 47,420,400 | 0 |
| GPTCO3 | 66 | 3,384 | 2,150 | 490,200 | 0 |
| GP_SPV | 122 | 58,496 | 2,150 | 18,257,800 | 0 |
| GPHPRE | 228 | 631,392 | 14,649 | 338,650,208 | 0 |
| VERDISINT, VERINT, VERDER | 163 | 1,454,464 | 21,559 | 314,924,992 | 0 |
| GPGEO | 72 | 73,336 | 4,300 | 32,559,600 | 0 |
| GPGRGEO | 201 | 608,832 | 2,150 | 32,447,800 | 0 |
| GPTF1 | 202 | 1,555,200 | 2,150 | 206,520,400 | 0 |
| GPTF2 | 106 | 982,272 | 2,150 | 206,520,400 | 0 |
| CTVTOT | 189 | 108,080 | 2,150 | 8,049,600 | 0 |
| SIGAM | 51 | 381,992 | 4,326 | 305,578,584 | 0 |
| SITNU | 265 | 146,664 | 2,176 | 155,738,840 | 0 |
| SPFILT | 253 | 4,906,336 | 25 | 3,902,600 | 0 |
| SPCIMPFPOST | 168 | 2,183,104 | 550 | 127,045,600 | 0 |
| SPCIMPFINIT | 197 | 3,973,408 | 550 | 169,488,000 | 0 |
| CPQTUV | 135 | 252,152 | 2,150 | 134,194,400 | 0 |
| CUBIDIAG | 106 | 79,336 | 8,600 | 48,228,800 | 0 |
| SIMPLICO | 151 | 275,552 | 550 | 84,691,200 | 0 |
| CALC_LIQ_OPTICS_SOCRATES | 242 | 71,328 | 317,920 | 127,168,000 | 0 |
| CALC_ICE_OPTICS_FU_SW | 331 | 94,320 | 223,175 | 83,913,800 | 0 |

The strict-source Fortran build uses the original sources with separate multiplication and addition. The global T21 forecast has 2,048 grid points and 19 atmospheric levels. The archived test starts at 12 UTC on 15 October 2004 and saves a 24-hour forecast at 12 UTC on 16 October. Its 25 time-step visits include the initial step, with one process and one thread. All ten upstream output files at hours 0, 6, 12, 18 and 24 match a fresh strict-source Fortran run with the same pressure math and ordered vertical matrix sum byte for byte. Every captured call of the used assembly routines also matches its strict Fortran counterpart, including inactive cells. The verification drivers record and compare states but supply no missing numerical update. GPRCP and GPPWC captures preserve untouched caller bytes, so hashes identify an archived run. The input capture also records incoming output bytes for exact replay.

The vertical row groups three public bodies and their private matrix helper. Its 21,559 forecast calls count genuine VERDISINT visits; each also calls the native integral dependency. The complete capture contains 73,322 dispatcher and helper records, including separately marked reference comparisons. SIGAM and SITNU add 4,326 and 2,176 marked source-shadow vertical calls without changing the genuine count. SITNU also passes 63,869 independent ground mass-integral checks. VERDER has no genuine visit in this forecast and is accepted by the small checks only. Constant and fourth-degree polynomial profiles independently verify the actual forecast grid within 1e-11 and 1e-6, respectively.

GPRCP's 13,846 captured calls comprise 11,696 model visits and 2,150 marked reference comparisons inside CTVTOT. CTVTOT also uses the same accepted native GPRCP body for 2,150 private dependency calls. The small GPRCP verifier retains all 3,976 original cases and adds a separate read-only, protected six-field input check. The two filter stages also pass six complete histories, with twelve stage comparisons and 204 independent final identities. This forecast uses their two-time-level copy and skip branches, while the small checks cover the weighted and clearing branches.

Both current builds use unchanged-source vertical routines with a private ordered matrix sum. Each product and addition rounds separately in a fixed order. Their fresh baseline is separate from the earlier external-BLAS baseline, whose files remain archived. Other external matrix calls retain their original libraries.

Other forecast stages remain in Fortran. Their complete raw states and independent whole-forecast physical balances have not been verified. The [build record](build.json) shows that all seven locally rebuilt scientific libraries have zero audited fused or approximate arithmetic instructions, but external numerical libraries remain outside that accepted audit. The [pressure math record](pressure_math.json) now accepts separately rounded scalar exp and log, with 20,849 independent high-precision checks and no forbidden instructions. Both pressure implementations use this same frozen library. Its fresh baseline is separate from the older system-math archive. Other external functions still require an audit before accepting the whole forecast's arithmetic. The [ordered vertical matrix](../../skills/md2asm/references/openifs/dynamics/strict_matrix.md) now has matched scalar/vector timings. Complete VERINT calls improve by 3.02× for the 24-point forecast block, with every output byte preserved. Whole-forecast comparative timing remains unfinished.

GPPWC integrates both physical water fractions and signed diagnostic quantities. CPEDIA uses it for column water and moisture transport, while correction routines also integrate negative changes. The small check verifies both uses without imposing water-positivity rules on a correction field.

Each routine's compact JSON record sits beside its verifier in dynamics/, physics/ or surface/. Common records preserve [source identity](source.json), [the reference build](build.json), [pressure math](pressure_math.json) and [the mixed forecast](forecast.json). Large inputs, logs, downloaded sources and raw captures remain in ignored .runtime/openifs/.

The [routine work list](ROUTINES.md) records the exact-count task and the one-at-a-time implementation sequence.

## Run the critical checks

Run these commands through srun in your own quiet exclusive allocation. Set openifs_root to the existing OpenIFS directory and strict_build to the separately rebuilt strict-source directory. Preserve the original installation. The build record contains the actual configuration command, custom flags and library hashes.

```bash
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
openifs_root=/path/to/ecmwf-openifs
strict_build="$PWD/.runtime/openifs/strict-build"
mkdir -p .runtime/openifs/cpspe .runtime/openifs/gprcp
gcc -c src/openifs/surface/cpspe.S -o .runtime/openifs/cpspe/cpspe.o
gfortran -cpp -DCPSPE=CPSPE_REFERENCE -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -fPIC -I "$openifs_root/build/module/parkind_dp" -I "$openifs_root/build/module/fiat" -c "$openifs_root/ifs-source/arpifs/phys_ec/cpspe.F90" -o .runtime/openifs/cpspe/reference.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math bench/openifs/surface/cpspe.c .runtime/openifs/cpspe/cpspe.o .runtime/openifs/cpspe/reference.o -L "$openifs_root/build/lib" -lfiat -lgfortran -lm -Wl,-rpath,"$openifs_root/build/lib" -o .runtime/openifs/cpspe/verify
.runtime/openifs/cpspe/verify .runtime/openifs/cpspe/assembly.bin .runtime/openifs/cpspe/fortran.bin
cmp .runtime/openifs/cpspe/assembly.bin .runtime/openifs/cpspe/fortran.bin

gcc -fPIC -Dgprcp_=gprcp_assembly_ -c src/openifs/dynamics/gprcp.S -o .runtime/openifs/gprcp/assembly.o
gcc -c bench/openifs/fpcr.c -o .runtime/openifs/gprcp/fpcr.o
gfortran -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -ffree-line-length-none -fcheck=bounds -I "$strict_build/ifs_dp/module" -I "$strict_build/module/parkind_dp" -I "$strict_build/module/fiat" -fPIC -pie bench/openifs/dynamics/gprcp.f90 .runtime/openifs/gprcp/assembly.o .runtime/openifs/gprcp/fpcr.o -L "$strict_build/lib" -larpifs.DP -lfiat -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gprcp/verify
.runtime/openifs/gprcp/verify .runtime/openifs/gprcp/assembly.bin .runtime/openifs/gprcp/fortran.bin
cmp .runtime/openifs/gprcp/assembly.bin .runtime/openifs/gprcp/fortran.bin

mkdir -p .runtime/openifs/gppwc
gcc -fPIC -Dgppwc_=gppwc_assembly_ -c src/openifs/dynamics/gppwc.S -o .runtime/openifs/gppwc/assembly.o
gcc -c bench/openifs/dynamics/gppwc_guard.c -o .runtime/openifs/gppwc/guard.o
gfortran -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -ffree-line-length-none -fcheck=bounds -I "$strict_build/ifs_dp/module" -I "$strict_build/module/parkind_dp" -I "$strict_build/module/fiat" bench/openifs/dynamics/gppwc.f90 .runtime/openifs/gppwc/assembly.o .runtime/openifs/gppwc/guard.o .runtime/openifs/gprcp/fpcr.o -L "$strict_build/lib" -larpifs.DP -lfiat -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gppwc/verify
.runtime/openifs/gppwc/verify .runtime/openifs/gppwc/assembly.bin .runtime/openifs/gppwc/fortran.bin
cmp .runtime/openifs/gppwc/assembly.bin .runtime/openifs/gppwc/fortran.bin

mkdir -p .runtime/openifs/gprt
gcc -fPIC -Dgprt_=gprt_assembly_ -c src/openifs/dynamics/gprt.S -o .runtime/openifs/gprt/assembly.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror bench/openifs/dynamics/gprt.c .runtime/openifs/gprt/assembly.o -L "$strict_build/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gprt/verify
.runtime/openifs/gprt/verify .runtime/openifs/gprt/assembly.bin .runtime/openifs/gprt/fortran.bin
cmp .runtime/openifs/gprt/assembly.bin .runtime/openifs/gprt/fortran.bin

mkdir -p .runtime/openifs/gpgrp
gcc -fPIC -Dgpgrp_=gpgrp_assembly_ -c src/openifs/dynamics/gpgrp.S -o .runtime/openifs/gpgrp/assembly.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror bench/openifs/dynamics/gpgrp.c .runtime/openifs/gpgrp/assembly.o -L "$strict_build/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gpgrp/verify
.runtime/openifs/gpgrp/verify .runtime/openifs/gpgrp/assembly.bin .runtime/openifs/gpgrp/fortran.bin
cmp .runtime/openifs/gpgrp/assembly.bin .runtime/openifs/gpgrp/fortran.bin

mkdir -p .runtime/openifs/gpmktend
gcc -fPIC -Dgpmktend_=gpmktend_assembly_ -c src/openifs/dynamics/gpmktend.S -o .runtime/openifs/gpmktend/assembly.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror bench/openifs/dynamics/gpmktend.c .runtime/openifs/gpmktend/assembly.o -L "$strict_build/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gpmktend/verify
.runtime/openifs/gpmktend/verify .runtime/openifs/gpmktend/assembly.bin .runtime/openifs/gpmktend/fortran.bin
cmp .runtime/openifs/gpmktend/assembly.bin .runtime/openifs/gpmktend/fortran.bin

mkdir -p .runtime/openifs/gpaddslphy
gcc -fPIC -Dgpaddslphy_=gpaddslphy_assembly_ -c src/openifs/physics/gpaddslphy.S -o .runtime/openifs/gpaddslphy/assembly.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror bench/openifs/physics/gpaddslphy.c .runtime/openifs/gpaddslphy/assembly.o -L "$strict_build/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gpaddslphy/verify
.runtime/openifs/gpaddslphy/verify .runtime/openifs/gpaddslphy/assembly.bin .runtime/openifs/gpaddslphy/fortran.bin
cmp .runtime/openifs/gpaddslphy/assembly.bin .runtime/openifs/gpaddslphy/fortran.bin

mkdir -p .runtime/openifs/wind_tendency
gcc -fPIC -Dgp_tndlagadiab_uv_=wind_tendency_assembly_ -c src/openifs/dynamics/wind_tendency.S -o .runtime/openifs/wind_tendency/assembly.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror bench/openifs/dynamics/wind_tendency.c .runtime/openifs/wind_tendency/assembly.o -L "$strict_build/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/wind_tendency/verify
.runtime/openifs/wind_tendency/verify .runtime/openifs/wind_tendency/assembly.bin .runtime/openifs/wind_tendency/fortran.bin
cmp .runtime/openifs/wind_tendency/assembly.bin .runtime/openifs/wind_tendency/fortran.bin

mkdir -p .runtime/openifs/gpgrxyb
gcc -fPIC -Dgpgrxyb_=gpgrxyb_assembly_ -c src/openifs/dynamics/gpgrxyb.S -o .runtime/openifs/gpgrxyb/assembly.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror bench/openifs/dynamics/gpgrxyb.c .runtime/openifs/gpgrxyb/assembly.o -L "$strict_build/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gpgrxyb/verify
.runtime/openifs/gpgrxyb/verify .runtime/openifs/gpgrxyb/assembly.bin .runtime/openifs/gpgrxyb/fortran.bin
cmp .runtime/openifs/gpgrxyb/assembly.bin .runtime/openifs/gpgrxyb/fortran.bin

mkdir -p .runtime/openifs/gptco3
gcc -fPIC -Dgptco3_=gptco3_assembly_ -c src/openifs/physics/gptco3.S -o .runtime/openifs/gptco3/assembly.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror bench/openifs/physics/gptco3.c .runtime/openifs/gptco3/assembly.o -L "$strict_build/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gptco3/verify
.runtime/openifs/gptco3/verify .runtime/openifs/gptco3/assembly.bin .runtime/openifs/gptco3/fortran.bin
cmp .runtime/openifs/gptco3/assembly.bin .runtime/openifs/gptco3/fortran.bin
```

The [md2asm contracts](../../skills/md2asm/references/openifs/) define each routine's shapes, units, arithmetic, interfaces and output formats. GP_SPV and GPHPRE use the shared scalar exp/log library described below. Inspect all accepted objects for forbidden instructions and check the floating-point control register, FPCR. Compiler output is used for verification only.

## Freeze pressure math

Download the fixed Arm math source into the ignored runtime directory, preserving its release and hashes. Run these commands through srun on your own quiet exclusive node. The library supplies only scalar exp and log, so it does not establish the arithmetic of all external forecast functions.

```bash
git clone --depth 1 --branch v26.01 git@github.com:ARM-software/optimized-routines.git .runtime/openifs/arm-math-source
mkdir -p .runtime/openifs/strict-math .runtime/openifs/gp_spv .runtime/openifs/gphpre
math_source=.runtime/openifs/arm-math-source/math
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math \
  -DHAVE_FAST_FMA=0 -DHAVE_FAST_ROUND=0 -DWANT_ERRNO=1 \
  -I "$math_source" -I "$math_source/include" \
  "$math_source/exp.c" "$math_source/exp_data.c" \
  "$math_source/log.c" "$math_source/log_data.c" "$math_source/math_err.c" \
  -Wl,-z,defs -Wl,-Bsymbolic-functions -lm \
  -o .runtime/openifs/strict-math/libpressure-math.so
gcc -shared -fPIC -O2 bench/openifs/fpcr.c -o .runtime/openifs/strict-math/libfpcr.so
.runtime/python/bin/python bench/openifs/pressure_math.py \
  .runtime/openifs/strict-math/libpressure-math.so .runtime/openifs/strict-math/accuracy.json
gcc -fPIC -Dgp_spv_=gp_spv_assembly_ -c src/openifs/dynamics/gp_spv.S \
  -o .runtime/openifs/gp_spv/assembly.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror \
  bench/openifs/dynamics/gp_spv.c .runtime/openifs/gp_spv/assembly.o \
  -L "$strict_build/lib" -larpifs.DP -lfiat -lm -ldl \
  -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gp_spv/verify
pressure_math="$PWD/.runtime/openifs/strict-math/libpressure-math.so"
LD_PRELOAD="$pressure_math" .runtime/openifs/gp_spv/verify \
  .runtime/openifs/gp_spv/assembly.bin .runtime/openifs/gp_spv/fortran.bin
cmp .runtime/openifs/gp_spv/assembly.bin .runtime/openifs/gp_spv/fortran.bin

gcc -fPIC -Dgphpre_=gphpre_assembly_ -c src/openifs/dynamics/gphpre.S \
  -o .runtime/openifs/gphpre/assembly.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror \
  bench/openifs/dynamics/gphpre.c .runtime/openifs/gphpre/assembly.o \
  -L "$strict_build/lib" -larpifs.DP -lfiat -lm -ldl \
  -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gphpre/verify
LD_PRELOAD="$pressure_math" .runtime/openifs/gphpre/verify \
  .runtime/openifs/gphpre/assembly.bin .runtime/openifs/gphpre/fortran.bin
cmp .runtime/openifs/gphpre/assembly.bin .runtime/openifs/gphpre/fortran.bin
```

## Verify calls in the forecast

Build the comparison libraries, then use a fresh copy of the upstream T21 test directory with its input links intact. Set IFS_EXECUTABLE in its local ifs_env to the strict-source executable. Make a separate Fortran baseline with the ordered vertical reference and pressure_math preloaded. For the mixed forecast, use all comparison libraries before those two dependencies, as listed below. The original installation remains unchanged.

```bash
mkdir -p .runtime/openifs/dynamics-library
gcc -fPIC -Dcpspe_=cpspe_assembly_ -c src/openifs/surface/cpspe.S -o .runtime/openifs/cpspe/forecast.o
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math \
  bench/openifs/surface/forecast.c bench/openifs/dynamics/gprcp_forecast.c \
  bench/openifs/dynamics/gppwc_forecast.c bench/openifs/dynamics/gprt_forecast.c \
  bench/openifs/dynamics/gpgrp_forecast.c bench/openifs/dynamics/gpmktend_forecast.c \
  bench/openifs/physics/gpaddslphy_forecast.c bench/openifs/dynamics/wind_tendency_forecast.c \
  bench/openifs/dynamics/gpgrxyb_forecast.c bench/openifs/physics/gptco3_forecast.c \
  bench/openifs/dynamics/gp_spv_forecast.c \
  .runtime/openifs/cpspe/forecast.o .runtime/openifs/gprcp/assembly.o \
  .runtime/openifs/gppwc/assembly.o .runtime/openifs/gprt/assembly.o \
  .runtime/openifs/gpgrp/assembly.o .runtime/openifs/gpmktend/assembly.o \
  .runtime/openifs/gpaddslphy/assembly.o .runtime/openifs/wind_tendency/assembly.o \
  .runtime/openifs/gpgrxyb/assembly.o .runtime/openifs/gptco3/assembly.o \
  .runtime/openifs/gp_spv/assembly.o -ldl -lm -o \
  .runtime/openifs/dynamics-library/libverify-capacity.so
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror bench/openifs/dynamics/gphpre_forecast.c \
  .runtime/openifs/gphpre/assembly.o -ldl -lm \
  -o .runtime/openifs/gphpre/libverify-gphpre-reviewed.so
pressure_library="$PWD/.runtime/openifs/gphpre/libverify-gphpre-reviewed.so"
verification_library="$PWD/.runtime/openifs/dynamics-library/libverify-capacity.so"
```

Set workspace to the repository root. Build the additional accepted libraries before launching the mixed forecast. Use a fresh T21 input directory for each run because the model appends to its saved files. For the separate Fortran baseline, preload only vertical_reference and pressure_math. The grid logger used for the archived independent geometry check and its hashes are identified in [forecast.json](forecast.json).

```bash
workspace=$PWD
vertical_reference="$workspace/.runtime/openifs/verdisint/build/libstrict-vertical-reference.so"
vertical_library="$workspace/.runtime/openifs/verdisint/forecast/libverify-vertical.so"
ctvtot_library="$workspace/.runtime/openifs/ctvtot/libverify-ctvtot.so"
gpgeo_library="$workspace/.runtime/openifs/gpgeo/combined-forecast/libverify-gpgeo.so"
gpgrgeo_library="$workspace/.runtime/openifs/gpgrgeo/combined-forecast/libverify-gpgrgeo.so"
filter_library="$workspace/.runtime/openifs/timefilter/libverify-time-filter.so"
comparators="$vertical_library:$ctvtot_library:$gpgeo_library:$gpgrgeo_library"
comparators="$comparators:$filter_library:$pressure_library:$verification_library"
cd /path/to/fresh/t21/test_fc
srun --jobid="$SLURM_JOB_ID" --overlap --exact --nodes=1 --ntasks=1 --cpus-per-task=1 \
  --mpi=cray_shasta --cpu-bind=map_cpu:0 --mem-bind=local \
  ./ifs-run --nproc=1 --nthread=1 \
  --launch="env LD_PRELOAD=$comparators:$vertical_reference:$pressure_math"
for name in cpspe gprcp gppwc gprt gpgrp gpmktend gpaddslphy wind gpgrxyb \
  gptco3 gp_spv gphpre vertical gpgeo gpgrgeo gptf1 gptf2 ctvtot
do
  cmp "$name-assembly.bin" "$name-fortran.bin"
done
```

Compare all ten ICMSH and ICMUA output files at hours 0, 6, 12, 18 and 24 with the separate baseline. LD_PRELOAD selects the comparison libraries, which call each complete native update and the source update on separate outputs. The drivers compare complete returned arrays, including inactive cells, and supply no omitted numerical stage.

The [vertical contract](../../skills/md2asm/references/openifs/dynamics/verdisint.md) defines integration, differentiation and the ordered matrix helper. The [GPGEO contract](../../skills/md2asm/references/openifs/dynamics/gpgeo.md) and [GPGRGEO contract](../../skills/md2asm/references/openifs/dynamics/gpgrgeo.md) use those complete native dependencies. The [filter contract](../../skills/md2asm/references/openifs/dynamics/time_filter.md) covers both stages, and [CTVTOT](../../skills/md2asm/references/openifs/dynamics/ctvtot.md) uses the complete moist-air body.

<details>
<summary>Accepted vertical build commands</summary>

The frozen fixture generator uses the archived source dispatch, geometry and matrix inputs under .runtime/openifs/verdisint/. Its small polynomial problems have exact rational solutions. Generate those fixtures before emission, then use their accepted corpus for verification. The commands below preserve the actual GNU 12.3 build and the private ordered source dependency. Choose new output directories to preserve earlier evidence.

```bash
.runtime/python/bin/python bench/openifs/dynamics/vertical_fixtures.py
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
workspace=$PWD
build_root=$workspace/.runtime/openifs/strict-build
vertical_root=$workspace/.runtime/openifs/verdisint
out=$vertical_root/build
source_root=$vertical_root/preparation/sources/utility
gcc -fPIC -march=armv8-a+simd -c src/openifs/dynamics/strict_matrix.S -o "$out/strict_matrix.o"
gcc -fPIC -march=armv8-a+simd -DVERINT_ENTRY=verint_assembly_ -c src/openifs/dynamics/verint.S -o "$out/verint.o"
gcc -fPIC -march=armv8-a+simd -DVERDER_ENTRY=verder_assembly_ -c src/openifs/dynamics/verder.S -o "$out/verder.o"
gcc -fPIC -march=armv8-a+simd -DVERDISINT_ENTRY=verdisint_assembly_ -DVERINT_ENTRY=verint_assembly_ -DVERDER_ENTRY=verder_assembly_ -c src/openifs/dynamics/verdisint.S -o "$out/verdisint.o"
for routine in verint verder verdisint; do
 gfortran -O3 -mcpu=native -fPIC -fopenmp -ffp-contract=off -fno-fast-math -cpp -I "$build_root/ifs_dp/module" -I "$build_root/module/parkind_dp" -I "$build_root/module/fiat" -I "$build_root/ifs_dp/arpifs/interfaces/include" -I "$build_root/ifs_dp/contrib/fiat/include/fiat" -DDGEMM=VERDISINT_STRICT_NT_FP64 -c "$source_root/$routine.F90" -o "$out/reference/$routine.o"
 gfortran -O3 -mcpu=native -fPIC -fopenmp -ffp-contract=off -fno-fast-math -cpp -I "$build_root/ifs_dp/module" -I "$build_root/module/parkind_dp" -I "$build_root/module/fiat" -I "$build_root/ifs_dp/arpifs/interfaces/include" -I "$build_root/ifs_dp/contrib/fiat/include/fiat" -DVERINT=VERINT_REFERENCE -DVERDER=VERDER_REFERENCE -DVERDISINT=VERDISINT_REFERENCE -DDGEMM=VERDISINT_STRICT_NT_FP64 -c "$source_root/$routine.F90" -o "$out/compare/$routine"_reference.o
done
gfortran -fopenmp -shared -Wl,-Bsymbolic -Wl,-z,defs "$out/reference/verdisint.o" "$out/reference/verint.o" "$out/reference/verder.o" "$out/strict_matrix.o" -L "$build_root/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$build_root/lib" -o "$out/libstrict-vertical-reference.so"
gcc -O2 -mcpu=native -fopenmp -fno-fast-math -ffp-contract=off -std=c11 -Wall -Wextra -Werror -I "$vertical_root/fixtures" -c bench/openifs/dynamics/verdisint.c -o "$out/verifier.o"
gcc -fPIC -march=armv8-a+simd -c bench/openifs/dynamics/vertical_abi.S -o "$out/vertical_abi.o"
gfortran -fopenmp -Wl,--export-dynamic-symbol=LinuxTraceBack "$out/verifier.o" "$out/vertical_abi.o" "$out/strict_matrix.o" "$out/verint.o" "$out/verder.o" "$out/verdisint.o" "$out/compare/verint_reference.o" "$out/compare/verder_reference.o" "$out/compare/verdisint_reference.o" -L "$build_root/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$build_root/lib" -o "$out/verifier"
```

Run the verifier from a new directory with core dumps disabled, then compare assembly.bin and reference.bin directly. The [compact family record](dynamics/verdisint.json) preserves all actual checks, including public reference calls and the real invalid-boundary rejection.

```bash
forecast=$vertical_root/forecast
gcc -O2 -mcpu=native -fPIC -fopenmp -pthread -ffp-contract=off -fno-fast-math -std=c11 -Wall -Wextra -Werror -c bench/openifs/dynamics/vertical_forecast.c -o "$forecast/driver.o"
for routine in verdisint verint verder; do
 objcopy --redefine-sym "$routine"_assembly_="$routine"_complete_assembly_ "$out/$routine.o" "$forecast/$routine-complete.o"
 objcopy --dump-section .text="$forecast/$routine-accepted.text" "$out/$routine.o"
 objcopy --dump-section .text="$forecast/$routine-complete.text" "$forecast/$routine-complete.o"
 cmp "$forecast/$routine-accepted.text" "$forecast/$routine-complete.text"
done
gfortran -shared -fopenmp -pthread -Wl,-Bsymbolic -Wl,-z,defs "$forecast/driver.o" "$forecast/verdisint-complete.o" "$forecast/verint-complete.o" "$forecast/verder-complete.o" "$out/strict_matrix.o" "$out/compare/verint_reference.o" "$out/compare/verder_reference.o" -L "$build_root/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$build_root/lib" -o "$forecast/libverify-vertical.so"
```

</details>

<details>
<summary>Accepted geopotential, temperature and filter commands</summary>

The remaining links reuse the complete accepted native dependencies. The exact standalone and forecast commands are preserved with .runtime/openifs/gpgeo/accepted-vertical/, .runtime/openifs/gpgrgeo/accepted-vertical/, .runtime/openifs/ctvtot/ and .runtime/openifs/timefilter/paired-integration/. Their compact records preserve the source, inputs, returned bytes and instruction audits. The two-stage filter run also retains every byte of its original corpus.

```bash
set -e
module load PrgEnv-gnu gcc-native/12.3 libfabric/2.3.1
build_root="$PWD/.runtime/openifs/strict-build"
vertical_root="$PWD/.runtime/openifs/verdisint/build"
mkdir -p .runtime/openifs/gpgeo/accepted-vertical .runtime/openifs/gpgrgeo/accepted-vertical
gcc -fPIC -Dgpgeo_=gpgeo_assembly_ -c src/openifs/dynamics/gpgeo.S -o .runtime/openifs/gpgeo/assembly.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror bench/openifs/dynamics/gpgeo.c .runtime/openifs/gpgeo/assembly.o "$vertical_root/strict_matrix.o" "$vertical_root/verint.o" "$vertical_root/verder.o" "$vertical_root/verdisint.o" -L "$vertical_root" -lstrict-vertical-reference -L "$build_root/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$vertical_root" -Wl,-rpath,"$build_root/lib" -o .runtime/openifs/gpgeo/accepted-vertical/verify
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror bench/openifs/dynamics/gpgrgeo.c .runtime/openifs/gpgrgeo/assembly.o "$vertical_root/strict_matrix.o" "$vertical_root/verint.o" "$vertical_root/verder.o" "$vertical_root/verdisint.o" -L "$vertical_root" -lstrict-vertical-reference -L "$build_root/lib" -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$vertical_root" -Wl,-rpath,"$build_root/lib" -o .runtime/openifs/gpgrgeo/accepted-vertical/verify
.runtime/openifs/gpgeo/accepted-vertical/verify .runtime/openifs/gpgeo/accepted-vertical/assembly.bin .runtime/openifs/gpgeo/accepted-vertical/fortran.bin --finite-element > .runtime/openifs/gpgeo/accepted-vertical/verify.log 2>&1
cat .runtime/openifs/gpgeo/accepted-vertical/verify.log
cmp .runtime/openifs/gpgeo/accepted-vertical/assembly.bin .runtime/openifs/gpgeo/accepted-vertical/fortran.bin
.runtime/openifs/gpgrgeo/accepted-vertical/verify .runtime/openifs/gpgrgeo/accepted-vertical/assembly.bin .runtime/openifs/gpgrgeo/accepted-vertical/fortran.bin --finite-element > .runtime/openifs/gpgrgeo/accepted-vertical/verify.log 2>&1
cat .runtime/openifs/gpgrgeo/accepted-vertical/verify.log
cmp .runtime/openifs/gpgrgeo/accepted-vertical/assembly.bin .runtime/openifs/gpgrgeo/accepted-vertical/fortran.bin
```

```bash
filter_check="$PWD/.runtime/openifs/timefilter/paired-integration"
mkdir -p "$filter_check/run"
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -Wall -Wextra -Werror \
  bench/openifs/dynamics/time_filter.c .runtime/openifs/timefilter/build/gptf1.o \
  "$filter_check/gptf2.o" -Wl,--export-dynamic -L "$strict_build/lib" \
  -larpifs.DP -lfiat -lm -ldl -Wl,-rpath,"$strict_build/lib" -o "$filter_check/verify"
"$filter_check/verify" --paired "$filter_check/run"
"$filter_check/verify" 1 "$filter_check/run"
"$filter_check/verify" 2 "$filter_check/run"
```

Run the guarded GPRCP case with --capture-capacity and libverify-capacity.so preloaded. Its six-field input ends at a protected page, and its default corpus still retains all 899,712 original bytes.

</details>

The [spectral-filter record](dynamics/spfilt.json) includes twelve paired quiet-node measurements of complete calls. Rounded-factor reuse gives a median 2.394× gain over earlier assembly for the 19-level, 506-column call, with all output bytes identical. The record reports the small-workload variation and empirical component bound. These kernel timings do not measure a complete forecast.

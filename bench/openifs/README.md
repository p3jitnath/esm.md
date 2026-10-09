# OpenIFS verification

Twelve complete direct assembly routines are verified in OpenIFS 48.1.1. Their small checks include independent physical balances, exact output bytes, optional inputs, boundaries and buffer guards. The latest coarse forecast used own exclusive job 7189435 on nid010825, with one process, one thread, CPU 0 and local memory binding. Each routine's compact record preserves its earlier checks.

| Routine | Critical calls | Critical bytes | Forecast calls | Forecast bytes | Differing bytes |
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

The strict-source Fortran build uses the original sources with separate multiplication and addition. The global T21 forecast has 2,048 grid points and 19 atmospheric levels. It runs 25 nominal one-hour steps, with one process and one thread. All ten upstream output files at hours 0, 6, 12, 18 and 24 match a fresh strict-source Fortran run with the same pressure math library byte for byte. Every captured call of these twelve routines also matches its strict Fortran counterpart, including inactive cells. The verification drivers record and compare states but supply no missing numerical update. GPRCP and GPPWC captures preserve untouched caller bytes, so hashes identify an archived run. The input capture also records incoming output bytes for exact replay.

Other forecast stages remain in Fortran. Their complete raw states and independent whole-forecast physical balances have not been verified. The [build record](build.json) shows that all seven locally rebuilt scientific libraries have zero audited fused or approximate arithmetic instructions, but external numerical libraries remain outside that accepted audit. The [pressure math record](pressure_math.json) now accepts separately rounded scalar exp and log, with 20,849 independent high-precision checks and no forbidden instructions. Both pressure implementations use this same frozen library. Its fresh baseline is separate from the older system-math archive. Other external functions still require an audit before accepting the whole forecast's arithmetic. No OpenIFS comparative timing or optimisation lesson is claimed.

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
gfortran -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -ffree-line-length-none -fcheck=bounds -I "$strict_build/ifs_dp/module" -I "$strict_build/module/parkind_dp" -I "$strict_build/module/fiat" bench/openifs/dynamics/gprcp.f90 .runtime/openifs/gprcp/assembly.o .runtime/openifs/gprcp/fpcr.o -L "$strict_build/lib" -larpifs.DP -lfiat -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gprcp/verify
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

Build the comparison libraries, then use a fresh copy of the upstream T21 test directory with its input links intact. Set IFS_EXECUTABLE in its local ifs_env to the strict-source executable. Make a separate Fortran baseline with pressure_math preloaded, then preload both comparison libraries and pressure_math for the mixed forecast. The original installation remains unchanged.

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
  .runtime/openifs/dynamics-library/libverify-surface-pressure.so
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math \
  -Wall -Wextra -Werror bench/openifs/dynamics/gphpre_forecast.c \
  .runtime/openifs/gphpre/assembly.o -ldl -lm \
  -o .runtime/openifs/gphpre/libverify-gphpre-reviewed.so
pressure_library="$PWD/.runtime/openifs/gphpre/libverify-gphpre-reviewed.so"
verification_library="$PWD/.runtime/openifs/dynamics-library/libverify-surface-pressure.so"
cd /path/to/fresh/t21/test_fc
srun --jobid="$SLURM_JOB_ID" --overlap --exact --nodes=1 --ntasks=1 --cpus-per-task=1 --mpi=cray_shasta --cpu-bind=cores --mem-bind=local ./ifs-run --nproc=1 --nthread=1 --launch="env LD_PRELOAD=$pressure_library:$verification_library:$pressure_math"
cmp cpspe-assembly.bin cpspe-fortran.bin
cmp gprcp-assembly.bin gprcp-fortran.bin
cmp gppwc-assembly.bin gppwc-fortran.bin
cmp gprt-assembly.bin gprt-fortran.bin
cmp gpgrp-assembly.bin gpgrp-fortran.bin
cmp gpmktend-assembly.bin gpmktend-fortran.bin
cmp gpaddslphy-assembly.bin gpaddslphy-fortran.bin
cmp wind-assembly.bin wind-fortran.bin
cmp gpgrxyb-assembly.bin gpgrxyb-fortran.bin
cmp gptco3-assembly.bin gptco3-fortran.bin
cmp gp_spv-assembly.bin gp_spv-fortran.bin
cmp gphpre-assembly.bin gphpre-fortran.bin
```

LD_PRELOAD selects the local comparison routines when OpenIFS calls the twelve routines. Each comparison routine calls the complete assembly update and the original Fortran update on separate outputs. GPRT's comparison accepts absent moisture-gradient inputs when the selected mode does not use them. The coarse forecast uses the virtual-temperature mode, while the critical check also covers both other modes. GPGRP handles both conventional layers and the finite-element scheme, which represents vertical variation with basis functions. The coarse forecast uses the finite-element mode, while its small check covers both.

GPMKTEND preserves descriptor order and copies each tracer rate without another arithmetic operation. GPADDSLPHY preserves vertical boundary storage and skips the first step. Both modes occur in the forecast. The wind routine's forecast calls use no Rayleigh damping. Its critical check verifies all four damping modes, including tilted geometry and coefficient lower bounds 1, 0 and -1.

GPGRXYB uses the caller's actual field capacity for buffer checks and raw captures. Its forecast uses finite-element mode with coefficient outputs disabled. Its critical check covers all four pressure modes and guarded six- and nine-field arrays. GPTCO3 integrates physical ozone mass in its small checks. CPEDIA uses the same routine for signed moisture-change rates in every captured forecast call, producing kg/m²/s. The critical check also verifies this rate against a separate water-column balance. The ozone-specific forecast branch is inactive. GP_SPV updates only the current pressure in this two-time-level forecast, while the critical check covers every previous-level decision. GPHPRE's forecast calls use finite-element pressure weights and all three observed optional-output combinations. Its critical check also covers conventional pressures, mixed top selection and a single closed layer with absent unused coefficients. Compare every ICMSH and ICMUA output file directly with the separate Fortran run, then archive hashes to identify the compared files.

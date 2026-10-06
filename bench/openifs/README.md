# OpenIFS verification

The direct assembly routines implement the complete CPSPE surface update, GPRCP moist-air property calculation and GPPWC pressure-weighted column integral in OpenIFS 48.1.1. Their small checks include independent physical balances, exact output bytes, optional inputs, boundaries and buffer guards. Builds and simulations used one task on own exclusive job 7122219, node nid010373, with CPU and local memory binding.

| Check | CPSPE | GPRCP | GPPWC |
| --- | ---: | ---: | ---: |
| Critical paired calls | 449 | 3,976 | 13 |
| Critical trajectory bytes | 1,934,944 | 899,712 | 5,616 |
| Calls captured in the T21 forecast | 2,150 | 13,846 | 36,120 |
| Forecast trajectory bytes | 19,109,200 | 81,643,584 | 140,145,600 |
| Differing bytes | 0 | 0 | 0 |

The strict-source Fortran build uses the original sources with separate multiplication and addition. The global T21 forecast has 2,048 grid points and 19 atmospheric levels. It runs 25 nominal one-hour steps, with one process and one thread. All ten upstream output files at hours 0, 6, 12, 18 and 24 match the separate strict-source Fortran run byte for byte. Every captured CPSPE, GPRCP and GPPWC call also matches its strict Fortran counterpart, including inactive cells. The verification drivers record and compare states but supply no missing numerical update. GPRCP and GPPWC captures preserve untouched caller bytes, so hashes identify an archived run. The input capture also records incoming output bytes for exact replay.

Other forecast stages remain in Fortran. Their complete raw states and independent whole-forecast physical balances have not been verified. The [build record](build.json) shows that all seven locally rebuilt scientific libraries have zero audited fused or approximate arithmetic instructions, but external numerical libraries remain outside that accepted audit. The linked exp function contains fused instructions. Strict compiler flags therefore do not establish the complete reference's arithmetic contract. No OpenIFS comparative timing or optimisation lesson is claimed.

GPPWC integrates both physical water fractions and signed diagnostic quantities. CPEDIA uses it for column water and moisture transport, while correction routines also integrate negative changes. The small check verifies both uses without imposing water-positivity rules on a correction field.

The compact records preserve [source identity](source.json), [CPSPE checks](cpspe.json), [GPRCP checks](gprcp.json), [GPPWC checks](gppwc.json), [the reference build](build.json) and [the mixed forecast](forecast.json). Large inputs, logs and raw captures remain in ignored .runtime/openifs/.

## Run the critical checks

Run these commands through srun in your own quiet exclusive allocation. Set openifs_root to the existing OpenIFS directory and strict_build to the separately rebuilt strict-source directory. Preserve the original installation. The build record contains the actual configuration command, custom flags and library hashes.

```bash
module load PrgEnv-gnu gcc-native/12.3 libfabric/1.22.0
openifs_root=/path/to/ecmwf-openifs
strict_build="$PWD/.runtime/openifs/strict-build"
mkdir -p .runtime/openifs/cpspe .runtime/openifs/gprcp
gcc -c src/openifs/cpspe.S -o .runtime/openifs/cpspe/cpspe.o
gfortran -cpp -DCPSPE=CPSPE_REFERENCE -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -fPIC -I "$openifs_root/build/module/parkind_dp" -I "$openifs_root/build/module/fiat" -c "$openifs_root/ifs-source/arpifs/phys_ec/cpspe.F90" -o .runtime/openifs/cpspe/reference.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math bench/openifs/cpspe.c .runtime/openifs/cpspe/cpspe.o .runtime/openifs/cpspe/reference.o -L "$openifs_root/build/lib" -lfiat -lgfortran -lm -Wl,-rpath,"$openifs_root/build/lib" -o .runtime/openifs/cpspe/verify
.runtime/openifs/cpspe/verify .runtime/openifs/cpspe/assembly.bin .runtime/openifs/cpspe/fortran.bin
cmp .runtime/openifs/cpspe/assembly.bin .runtime/openifs/cpspe/fortran.bin

gcc -fPIC -Dgprcp_=gprcp_assembly_ -c src/openifs/gprcp.S -o .runtime/openifs/gprcp/assembly.o
gcc -c bench/openifs/fpcr.c -o .runtime/openifs/gprcp/fpcr.o
gfortran -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -ffree-line-length-none -fcheck=bounds -I "$strict_build/ifs_dp/module" -I "$strict_build/module/parkind_dp" -I "$strict_build/module/fiat" bench/openifs/gprcp.f90 .runtime/openifs/gprcp/assembly.o .runtime/openifs/gprcp/fpcr.o -L "$strict_build/lib" -larpifs.DP -lfiat -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gprcp/verify
.runtime/openifs/gprcp/verify .runtime/openifs/gprcp/assembly.bin .runtime/openifs/gprcp/fortran.bin
cmp .runtime/openifs/gprcp/assembly.bin .runtime/openifs/gprcp/fortran.bin

mkdir -p .runtime/openifs/gppwc
gcc -fPIC -Dgppwc_=gppwc_assembly_ -c src/openifs/gppwc.S -o .runtime/openifs/gppwc/assembly.o
gcc -c bench/openifs/gppwc_guard.c -o .runtime/openifs/gppwc/guard.o
gfortran -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -ffree-line-length-none -fcheck=bounds -I "$strict_build/ifs_dp/module" -I "$strict_build/module/parkind_dp" -I "$strict_build/module/fiat" bench/openifs/gppwc.f90 .runtime/openifs/gppwc/assembly.o .runtime/openifs/gppwc/guard.o .runtime/openifs/gprcp/fpcr.o -L "$strict_build/lib" -larpifs.DP -lfiat -Wl,-rpath,"$strict_build/lib" -o .runtime/openifs/gppwc/verify
.runtime/openifs/gppwc/verify .runtime/openifs/gppwc/assembly.bin .runtime/openifs/gppwc/fortran.bin
cmp .runtime/openifs/gppwc/assembly.bin .runtime/openifs/gppwc/fortran.bin
```

The [CPSPE contract](../../skills/md2asm/references/openifs/cpspe.md), [GPRCP contract](../../skills/md2asm/references/openifs/gprcp.md) and [GPPWC contract](../../skills/md2asm/references/openifs/gppwc.md) define shapes, units, arithmetic, interfaces and output formats. Inspect all accepted objects for forbidden instructions, and check the floating-point control register, FPCR. Compiler output is used for verification only.

## Verify calls in the forecast

Build the comparison library, then use a fresh copy of the upstream T21 test directory with its input links intact. Set IFS_EXECUTABLE in its local ifs_env to the strict-source executable. The original installation remains unchanged.

```bash
gcc -fPIC -Dcpspe_=cpspe_assembly_ -c src/openifs/cpspe.S -o .runtime/openifs/cpspe/forecast.o
gcc -shared -fPIC -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math bench/openifs/forecast.c bench/openifs/gprcp_forecast.c bench/openifs/gppwc_forecast.c .runtime/openifs/cpspe/forecast.o .runtime/openifs/gprcp/assembly.o .runtime/openifs/gppwc/assembly.o -ldl -o .runtime/openifs/gprcp/libverify-physics.so
verification_library="$PWD/.runtime/openifs/gprcp/libverify-physics.so"
cd /path/to/fresh/t21/test_fc
srun --jobid="$SLURM_JOB_ID" --overlap --exact --nodes=1 --ntasks=1 --cpus-per-task=1 --mpi=cray_shasta --cpu-bind=cores --mem-bind=local ./ifs-run --nproc=1 --nthread=1 --launch="env LD_PRELOAD=$verification_library"
cmp cpspe-assembly.bin cpspe-fortran.bin
cmp gprcp-assembly.bin gprcp-fortran.bin
cmp gppwc-assembly.bin gppwc-fortran.bin
```

LD_PRELOAD selects the local comparison routines when OpenIFS calls CPSPE, GPRCP and GPPWC. Each comparison routine calls the complete assembly update and the original Fortran update on separate outputs. Compare every ICMSH and ICMUA output file directly with the separate Fortran run, then archive hashes to identify the compared files.

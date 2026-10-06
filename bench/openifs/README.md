# OpenIFS verification

The first verified assembly routine is CPSPE, which advances 23 surface fields from supplied tendencies. It passes 15 critical cases and 449 calls, including constant-rate trajectories, partial columns, empty intervals, zero-sized fields, signed zeros, subnormal values and separate-rounding checks. A protected memory page also checks that the final vector tail reads and writes only its own buffer. State files contain 1,934,944 bytes and differ in zero bytes. Both instruction audits find no fused arithmetic. [The compact record](cpspe.json) preserves the source hashes and execution conditions.

| Component | Result |
| --- | --- |
| CPSPE surface update | Exact agreement with strict upstream-source Fortran |
| Installed fused-arithmetic Fortran | Different arithmetic contract |
| Complete assembly forecast | Not implemented |
| Whole-forecast raw-state comparison | Not established |
| Comparative performance | Not measured |

The reference is the unchanged local OpenIFS 48.1.1 CPSPE source, compiled with separate multiplication and addition. This check does not replace OpenIFS physics with a test driver and does not establish a complete assembly forecast. The installed upstream object uses fused multiply-add, which has a different rounding rule.

## Run the critical check

Run these commands on your own quiet exclusive compute node through srun. Set openifs_root to the existing OpenIFS build directory's parent. Keep its original source and installed libraries unchanged. The local .runtime/openifs/cpspe directory holds generated objects, raw trajectories and logs outside Git.

```bash
module load gcc-native/12.3 libfabric/1.22.0
openifs_root=/path/to/ecmwf-openifs
mkdir -p .runtime/openifs/cpspe
gcc -c src/openifs/cpspe.S -o .runtime/openifs/cpspe/cpspe.o
gfortran -cpp -DCPSPE=CPSPE_REFERENCE -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math -fPIC -I "$openifs_root/build/module/parkind_dp" -I "$openifs_root/build/module/fiat" -c "$openifs_root/ifs-source/arpifs/phys_ec/cpspe.F90" -o .runtime/openifs/cpspe/reference.o
gcc -O2 -mcpu=neoverse-v2 -ffp-contract=off -fno-fast-math bench/openifs/cpspe.c .runtime/openifs/cpspe/cpspe.o .runtime/openifs/cpspe/reference.o -L "$openifs_root/build/lib" -lfiat -lgfortran -lm -Wl,-rpath,"$openifs_root/build/lib" -o .runtime/openifs/cpspe/verify
.runtime/openifs/cpspe/verify .runtime/openifs/cpspe/assembly.bin .runtime/openifs/cpspe/fortran.bin
cmp .runtime/openifs/cpspe/assembly.bin .runtime/openifs/cpspe/fortran.bin
```

The [contract](../../skills/md2asm/references/openifs/cpspe.md) defines supported shapes, exact arithmetic, units and the assembly interface. The verifier disables profiling hooks, checks FPCR and protects every state and tendency buffer with guard values, with a protected page after single-entry arrays to detect any extra-lane access. Compiler output is inspected for forbidden instructions and is never used to construct direct assembly.

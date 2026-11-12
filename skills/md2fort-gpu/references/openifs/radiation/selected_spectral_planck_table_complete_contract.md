# Complete selected spectral Planck table on the GPU

This phase implements `md2asm_fill_selected_spectral_planck_table` using the [selected Planck equations and ordered arithmetic](../../../../md2fort/references/openifs/radiation/spectral_planck_setup.md). The production constructor selects two long-wave bands and 201 temperatures from 150 to 350 kelvin. Table values are thermal irradiance in watts per square metre. The phase reads live temperatures, wavelength bounds, band mapping, physical constants and incoming table values; archived cases supply verification only.

The Arm application binary interface (ABI) receives the source record in `x0` and the complete constant record in `x1`, with no return value. Record offsets 8 and 16 hold the first temperature and step. Pointers at 24, 112 and 176 select the table, bounds and map. The table stores two adjacent FP64 band values per temperature. Map values are one or two. All owners remain mapped until the synchronous call returns.

The [storage entry](../../../../../src/openifs/radiation/gpu/spectral_planck_table.S) branches to the [host transport](../../../../../src/openifs/radiation/gpu/selected_spectral_planck_table_phase_calls.S), which uses a private 2048-byte frame and preserves the required general and vector registers, `x18`, stack alignment and integer condition flags. The floating-point control register, FPCR, must be zero for round-to-nearest with ties to even and gradual underflow. Newly raised flags join the incoming floating-point status register, FPSR. Only the last reported EXP error changes `errno`. The enclosing constructor keeps its existing error policy. The qualified EXP interface is uncounted: actual FAST and WIDE product-sum counters remain unchanged.

The [device entry](../../../../../src/openifs/radiation/gpu/selected_spectral_planck_table_phase.ptx) launches one block of 256 threads with zero dynamic shared bytes. Through the [value functions](../../../../../src/openifs/radiation/gpu/selected_spectral_planck_table_values.ptx), threads 0 through 200 each own two cells and perform all three band updates and 101 ascending wavelength samples. Threads 201 through 255 skip arithmetic but reach all three collective barriers. Thread 0 first computes the original coefficients. Every source operand and separate FP64 rounding remains; qualified minimum, maximum and EXP behaviour includes signed zeros and NaNs. Link the qualified IEEE status and original-rounding EXP providers once each. No fused multiply-add or approximate arithmetic supplies table values.

The device ABI receives an argument-vector address and a [common-context address](../gpu_call_context.md). The vector selects the input header and completion. The 32-byte input header holds the record and constant pointers, then two zero words. Context offsets 48 and 56 select the 64-byte capacity record: seven capacities for input, completion, record, constants, table, bounds and map, then zero. Admission checks every owner before model or completion writes.

| Owner | Bytes | Alignment in bytes | Access |
| --- | ---: | ---: | --- |
| Argument vector | 16 | 8 | Read |
| Common context | 64 | 8 | Read and write |
| Capacity record | 64 | 8 | Read |
| Input header | 32 | 8 | Read |
| Completion | 16 | 8 | Write |
| Source record | 240 | 8 | Read |
| Physical constants | 520 | 8 | Read |
| Table | 3216 | 8 | Read and write |
| Wavelength bounds | 16 | 8 | Read |
| Band map | 12 | 4 | Read |

The caller supplies the mapped common context, revision one with reserved word zero. Owners must be nonnull, aligned, sufficiently large, nonwrapping and below the signed address limit. Read-only views may overlap; overlaps involving context, completion or table are rejected. Invalid shape, owner bounds and reserved/map values report context errors 35800, 35801 and 35802. The host requires the admitted original interface and provides no numerical fallback.

Completion contains four 32-bit words: return code at 0, flags at 4, final error at 8 and error position at 12. Each EXP position is `((temperature*3+range)*101+wavelength+1)`, from 1 through 60903. Each row retains its last nonzero error. After all rows finish, thread 0 joins flags and errors in ascending temperature order. A new context event replaces the full 64-bit word with `(position<<8)|errno`; no event preserves its incoming word.

Four complete tables match 12864 bytes exactly, with strict ABI, `x18`, FPCR, FPSR, `errno` and actual-counter checks. Three canonical tables reuse 1218 independent physical relations. One varied reference uses the unchanged accepted GPU provider, changing temperatures, bounds, map, physical words and nonzero incoming table values. No CPU or Fortran oracle ran. Another 44 controls compare entire 8192-byte images, including shared read-only views, malformed multidimensional blocks, map bounds and final error position 60903 with a seeded upper event word. Independent source reviews and native call, barrier and host checks pass. Every numerical process had an external 14.13-second cutoff. Complete forecast agreement and matched performance remain pending.

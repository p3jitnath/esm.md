# Initial Spectral State Placement

Revision 1 preserves the original coarse forecast's input layout. A spectral coefficient describes one wave in a field. This routine copies coefficients that the original input reader selects. It changes their storage positions and performs no physical calculation. The [initial spectral reader](initial_spectral_field_reader.md) supplies the decoded records.

The input contains 78 records with 506 consecutive 64-bit words per record. Its metadata contains three signed 64-bit integers per record, giving the GRIB parameter number, model level and value count. The checked order is (152, 1), then parameters 138, 155 and 130 for each level from 1 through 19, then (129, 0), then parameter 133 for levels 1 through 19. Each count is 506. The original selected forecast reads the first 59 records. The final 19 humidity records remain unused by this placement stage.

The output pspec3 has Fortran shape (19, 506, 3). Its fields are vorticity, divergence and temperature, in that order. Vorticity measures local turning of air, and divergence measures local outward flow. Their units are inverse seconds, inverse seconds and kelvin. Output pspec2 has shape (506, 2), with logarithm of surface pressure followed by orography geopotential. The first is dimensionless and the second has units of square metres per square second. A spectral coefficient has the units of its field under the unchanged input representation.

Let the zero-based indices $`\ell`$, $`f`$, $`c`$ and $`s`$ identify the model level, upper-air field, coefficient and surface slot. Their ranges are 0–18, 0–2, 0–505 and 0–1. The input record number and destination word numbers are

```math
r = 1 + 3\ell + f,\qquad w_3 = \ell + 19(c + 506f),\qquad w_2 = c + 506s.
```

Surface records 0 and 58 fill slots 0 and 1, which hold pressure and orography. Each assignment copies all 64 bits, including signed zero and any unusual floating-point bit pattern.

The application binary interface is int md2asm_place_initial_spectral_fields(values, values_bytes, metadata, metadata_bytes, pspec3, pspec3_bytes, pspec2, pspec2_bytes). Its eight arguments occupy registers x0 through x7 in that order. The four pointers are non-null and eight-byte aligned. The fixed extents are 315,744 bytes for values, 1,872 for metadata, 230,736 for pspec3 and 8,096 for pspec2. The caller supplies mapped readable input and writable output storage. Each output extent must be disjoint from the other output and both inputs. The two input extents may overlap.

Return code 0 means complete placement. Code 1 rejects an invalid pointer, alignment, capacity, wrapped address range or output overlap. Code 2 rejects metadata that differs from the fixed record contract. Every check finishes before the first output write, so a rejected call changes no owner bytes. Both complete input extents remain unchanged on every return.

The source uses Arm integer instructions only. It is a leaf routine, which makes no child call and uses no stack frame. It leaves registers x18 through x30, all vector registers, the floating-point control and status registers, and errno unchanged. Registers x0 through x17 and condition flags are scratch. No library or OpenIFS call is needed.

The source correspondence is SUSPECG field selection and IOSTREAM_MIX:SPEC_IN placement. The original one-processor SUWAVEDI and DIST_SPEC_CONTROL route preserves coefficient order. SPNORM computes diagnostics from read-only state and does not normalise these coefficients. Original geometry, grid-point initialisation and the forecast time loop remain separate work.

The independent metadata-driven Fortran reference and direct assembly agree across all 238,832 output bytes. Eleven focused cases passed, covering input immutability, protected bounds, capacities, metadata, output overlap, shared inputs, address overflow and unchanged floating-point controls. Three seeded ABI checks passed. A standalone assembly command also decoded the real input file and placed both model arrays with zero differing bytes, using only ecCodes and C runtime services. These checks establish this input-placement stage. They do not establish a complete autonomous forecast.

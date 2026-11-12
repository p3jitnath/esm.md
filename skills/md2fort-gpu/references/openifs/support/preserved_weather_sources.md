# Preserved GPU Call Sources

These compact Arm sources use shared assembler macros for the accepted GPU call sequences. An assembler macro expands a named source pattern into instructions. The patterns retain the ordered instructions, registers, argument words, status handling and original entry names of the expanded sources. Fifteen source files build sixteen objects because spectral latitude has separate public and private symbol names.

## Include and Build

Install [preserved_weather_calls.inc.S](../../../../../src/openifs/support/gpu/preserved_weather_calls.inc.S) first and only once across source families. Each source uses `#include "../../support/gpu/preserved_weather_calls.inc.S"`. Keep this folder layout and compile uppercase `.S` files through the C preprocessor and Arm assembler. Quoted includes resolve relative to the source file, so no additional include directory is needed.

Set `BUILD_DIR` to an existing ignored local build directory. The accepted builds use GNU Arm GCC 12 with `-c -fPIC`. For example:

```sh
gcc -c -fPIC src/openifs/dynamics/gpu/real_fourier_transform_host.S -o "$BUILD_DIR/real_fourier_transform_host.o"
gcc -c -fPIC src/openifs/dynamics/gpu/spectral_latitude_host.S -o "$BUILD_DIR/public_spectral_latitude.o"
gcc -c -fPIC -DSPNSDE_SYMBOL=md2asm_ltinv_spnsde -DUVTVD_SYMBOL=md2asm_ltinv_unused_uvtvd -DVDTUV_SYMBOL=md2asm_ltinv_vdtuv src/openifs/dynamics/gpu/spectral_latitude_host.S -o "$BUILD_DIR/private_spectral_latitude.o"
```

Compile every other source once without these symbol definitions. Preserve each original entry and getter name. Link the qualified GPU transports and device functions named by its calls, with each shared provider linked once. The [GPU call context](../gpu_call_context.md) and [CUDA runtime contract](../cuda_runtime.md) retain the records, serial host caller and storage lifetimes.

## Register Patterns

`md2asm_gpu_upper_operation` preserves the original scalar call sequence. Its 256-byte form also saves the sixteen upper FP64 register words; its 128-byte form retains the smaller accepted sequence. FP64 is the 64-bit floating-point format. The result kind and flag timing retain the original result register and integer branch flags. Integer-return options keep the original result-copy width and position.

`md2asm_gpu_full_scalar` and `md2asm_gpu_full_vector_pair` use the accepted 1024-byte temporary. They preserve all 31 general registers and all 32 complete vector registers before installing only the original destinations. A vector pair evaluates the two original lanes in order from saved inputs. Comments retain the replaced operation beside each call. Special register-write sequences remain explicit.

## Existing Contracts

These contracts retain the equations, supported values, array bounds, arithmetic order and interfaces. Source packaging leaves those requirements unchanged.

| Compact source | Existing contract |
| --- | --- |
| `fourier_hemisphere_reconstruction_host.S` | [Original contract](../../../../md2fort/references/openifs/dynamics/asre1b.md) |
| `fourier_metric_host.S` | [Original contract](../../../../md2fort/references/openifs/spectral_transforms/fourier_metric.md) |
| `fourier_wind_scaling_host.S` | [Original contract](../../../../md2fort/references/openifs/dynamics/ldfou2.md) |
| `inverse_legendre_reconstruction_host.S` | [Original contract](../../../../md2fort/references/openifs/dynamics/inverse_legendre_reconstruction.md) |
| `latitude_parity_host.S` | [Original contract](../../../../md2fort/references/openifs/dynamics/latitude_parity.md) |
| `legendre_wave_analysis_host.S` | [Original contract](../../../../md2fort/references/openifs/dynamics/legendre_wave_analysis.md) |
| `real_fourier_transform_host.S` | [Original contract](../../../../md2fort/references/openifs/dynamics/real_fourier_transform.md) |
| `spectral_latitude_host.S` | [Original contract](../../../../md2fort/references/openifs/dynamics/spectral_latitude_operators.md) |
| `radcfg_host.S` | [Original contract](../../../../md2fort/references/openifs/radiation/radiation_grid_preparation.md) |
| `radpar_host.S` | [Original contract](../../../../md2fort/references/openifs/radiation/radiation_parent_contract.md) |
| `private_canopy_light_layer_host.S` | [Original contract](../surface/private_canopy_light.md) |
| `private_canopy_light_wrapper_host.S` | [Original contract](../surface/private_canopy_light.md) |
| `private_radiation_controller_layer_host.S` | [Original contract](../surface/private_radiation_controller.md) |
| `private_radiation_controller_wrapper_host.S` | [Original contract](../surface/private_radiation_controller.md) |
| `surface_radiation_layer_host.S` | [Original contract](../surface/surface_radiation_layer.md) |

## Qualified Dependencies and Source Identity

The shared include contains transport patterns, not numerical functions. Every call still needs the exact GPU helper required by its accepted contract. Shared startup conversions, setup numeric entries, numeric minimum and maximum, logarithms and other mathematical children retain their own qualified providers when consumed. Public CPU mathematical entries do not replace a declared GPU child. The local build plan lists each source call target and unchanged provider evidence.

The retained compaction check assembled all sixteen selected objects and found the complete object bytes identical to their accepted expanded objects. Allocated sections, relocation records, alignment and ordered symbol records also match. This packet reuses that source-layout proof and the existing numerical contracts. Detailed build commands, object identities and comparison records remain local.

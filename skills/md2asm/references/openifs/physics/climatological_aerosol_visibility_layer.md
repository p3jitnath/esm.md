# Climatological aerosol visibility layer contract

The direct body implements the selected original `CLIMAER_LAYER` route. Its public entry is `md2asm_climatological_aerosol_visibility_layer`. The unique candidate entry is `md2asm_aerosol_visibility_layer_half_pressure_r3_7358525`, and the compatibility entry `md2asm_aerosol_visibility_layer_state_r2_7358525` is an instruction-free alias at the same address.

| Argument | Record | Use |
| --- | --- | --- |
| 1 | `YDSURF` | Surface metadata, including skin-temperature and aerosol diagnostic indices. |
| 2 | `YDMODEL` | Physical constants, aerosol metadata, saturation options and radiation configuration. |
| 3 | `KDIM` | Column bounds, 24-column storage extent and 19 air levels. |
| 4 | `PAUX` | Pressure and geographic input views. |
| 5 | `STATE_T0` | Initial air state retained for the unchanged interface. |
| 6 | `STATE_TMP` | Temperature, humidity, cloud fraction and four cloud-water views. |
| 7 | `PSURF` | Skin temperature and legacy aerosol optical-depth diagnostics. |
| 8 | `GEMSL` | Aerosol extinction and visibility outputs. |

The Arm application binary interface (ABI) defines where arguments and preserved registers are stored. Eight ordinary addresses enter in `x0` to `x7`. Each address refers to an existing record. The body preserves `x18`, the callee-preserved general registers and the lower 64 bits of `v8` to `v15`. The stack remains aligned to 16 bytes and uses 2048 bytes. A 79488-byte temporary buffer is obtained through `malloc` and returned through `free`; these are memory-management calls.

The selected GNU Fortran views use dense binary64 storage, where binary64 means a 64-bit floating-point value. Each view must cover its declared 24-column extent, including inactive columns in an 8-column call. Boundary pressure has 20 rows; full-level pressure and air state have 19 rows. A descriptor records each array's address, dimensions and strides. The body uses the recorded record offsets and descriptor bounds. Checked column ranges are 1 through 24 and 1 through 8. The caller supplies the recorded model options, radiation tables and metadata.

The body first calculates boundary temperatures. The boundary-pressure and air-temperature arrays have different level origins. Two corrected loads select the next pressure row for the source interior weighting and top extrapolation. All multiplication, subtraction, addition, division and intermediate rounding remain unchanged. The bottom temperature is copied from the skin field.

The unchanged child interfaces are `md2asm_aerosol_visibility_climatology_7358525` with 23 addresses, `md2asm_climate_saturation_7358525` with 10, `md2asm_shortwave_aerosol_extinction_7358525` with 8 and `md2asm_cloud_aerosol_visibility_7358525` with 13. The layer preserves their ordered calculations. The aerosol child retains its declared C power dependency in the current mixed forecast. This layer does not establish an autonomous assembly forecast or claim direct assembly for that C dependency.

The contract uses binary64, round-to-nearest with ties to even, gradual underflow and preserved signed zeros. The floating-point control register must be zero. Fused multiply-add, contraction, reassociation, approximate division or square root, reduced precision and fast-math are forbidden. Acceptance requires zero differing output bytes.

R40 retains genuine original and direct inputs. The old pressure indices reproduce all 480 retained direct boundary-temperature words exactly. Advancing the two loads by one row reproduces all 480 original words exactly.

The isolated corrected assembly loop passes full 24-column and partial 8-column comparisons against a separate original-equation Fortran control. Both compare 3840 output bytes with zero differences, preserve inactive words and guards, and match immediate floating-point controls, flags, library error state and register obligations. Constants and the ordered floating-point instruction stream are identical to the previous layer. All 20 relocation types, symbols and addends retain their order.

The first R41 live pair matches all 480 boundary-temperature words, 5472 modern aerosol mass words, 288 mass-mixing-ratio words, 24 humidity words, 24 extinction words and 24 visibility words. That R41 run stops later at a separate surface-time adapter guard. The later joint final-state and ten-file gate passes with the retained complete-parent proof. This package adds no weather routine credit by itself.

The separately verified [runtime cloud and aerosol visibility](runtime_cloud_aerosol_visibility.md) extends the CLAERVIS child to 137 levels with explicit constant owners. The [zero-aerosol visibility copy](runtime_zero_aerosol_visibility.md) also has a checked raw child and typed record interface. The [runtime shortwave aerosol calculation](../radiation/runtime_shortwave_aerosol_extinction.md) extends the column count with explicit coefficient owners and a stated unit limitation. The [runtime aerosol and ozone climatology](runtime_aerosol_visibility_climatology.md) supplies checked live-level RADACA fields. Their component contracts state the supported bounds and actual checks. Integration into this layer and the active forecast branch remains open.


The [runtime climatological visibility parent](runtime_climatological_visibility_layer.md) extends this call sequence to live column and level counts, with complete producer bounds and accepted direct numerical children. Its controlled component agreement does not establish a complete forecast or resolve the stated aerosol unit limit.

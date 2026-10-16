# Complete Selected Radiation Setup

The direct parent connects the accepted radiation children in the original `SUECRAD` order. Radiation setup prepares absorption tables, cloud and aerosol properties, and climate inputs before a forecast. The parent uses the final owned Geometry and MODEL records. Its pressure coordinate `PETAH` is the actual half-level input from the enclosing pressure calculation. The numerical children retain their accepted equations and ordered FP64 arithmetic.

## Interface And Storage

The application binary interface, or ABI, specifies the registers and memory used by a call. Arguments below occupy `x0` onwards in order. Every complete buffer must be mapped and nonwrapping. Word-bearing records require eight-byte alignment. Borrowed inputs remain alive until release. The selected grid has 19 levels and 20 half levels, so `PETAH` contains 20 FP64 values in 160 bytes.

| Entry | Arguments | Purpose |
| --- | --- | --- |
| `md2asm_initialize_radiation_setup_context` | Context, capacity, input text, text bytes, constants520, upstream112, date/seconds8 | Associate live inputs with the owned context |
| `md2asm_create_selected_radiation_storage` | Geometry17096, MODEL4275088, context | Apply named declaration defaults and create the earlier aerosol and overlap owners |
| `md2asm_initialize_selected_radiation_setup` | Geometry17096, MODEL4275088, context, PETAH160 | Complete the selected radiation setup |
| `md2asm_release_selected_radiation_setup` | MODEL4275088, context | Release acquired owners in reverse order |
| `md2asm_write_radiation_setup_stream` | Zero-terminated output path, MODEL4275088, context | Write complete raw setup records and owners after success |

Numbers attached to record names give their required byte sizes. The context capacity is at least 7168 bytes, and the context must be the static symbol `md2asm_owned_radiation_setup_context`. This single-model lifetime keeps the owned module aliases at the addresses used by their consumers. Context and borrowed input spans must not overlap. The early storage call precedes the enclosing physics setup, matching the original `SUALLO` allocation point.

| Context bytes | Contents |
| --- | --- |
| 0–127 | Signature, acquired-owner mask, live record addresses and completion state |
| 128–871 | Owned scalar module state and aliases |
| 872–3511 | Climate filename selection |
| 3512–4255 | Shared TEGEN state |
| 4256–4783 | Climate owner and original input directory |
| 4784–6831 | Four bounded original input paths |
| 6832–6959 | Climate associations, composition flags and path lengths |
| 6960–7071 | Refreshed live upstream controls |
| 7072–7167 | Reserved storage |

The upstream seed uses the [radiation control interface](radiation_control_setup.md). The parent refreshes its consumed Geometry and MODEL words before use. Platform switches come from the owned setup records and the selected GNU scalar policy. The MODEL ozone field stores an address, so its live `LGP` flag is read through that address. No prepared MODEL image is an input.

The named declaration helper `md2asm_initialize_radiation_record_defaults(MODEL, capacity)` writes 89 newly admitted source-declared fields covering 33,896 bytes. These include blank climate filenames, the original missing-value constants and declared interpolation defaults. It leaves every other byte and live descriptor unchanged. It is called once at record admission. TEGEN and ecRad retain their separate accepted declaration producers.

## Source Order And Supported Inputs

The parent calls radiation controls, longwave reference setup, cloud optical constants, original longwave loading and reduction, band tables, cloud tables, original shortwave loading and reduction, shortwave auxiliary tables, aerosol distributions and parameters, cloud overlap, flux storage, climate inputs, ecRad, ozone, TEGEN and CAMS. It retains intervening source assignments and copies the accepted interpolation controls to their named final MODEL fields.

The selected branch requires `NHINCSOL=4`, `NGHGRAD=20` or `21`, active historical greenhouse gases, two-dimensional CAMS input and inactive linearised physics. Other parent branches return two. Child contracts define their remaining supported inputs and numerical limits. The [longwave](longwave_absorption_inputs.md), [shortwave](shortwave_absorption_setup.md), [climate](radiation_climate_inputs.md), [ecRad](ecrad_configuration.md), [TEGEN](tegen_aerosol_setup.md) and [overlap](cloud_overlap_setup.md) contracts retain their independent physical and boundary evidence.

The original input directory comes from `DATA`. Its nonblank trimmed length is at most 256 bytes, matching the original ecRad character limit. Nonblank `DATA` gains `/ifsdata`, and the original coefficient basenames use that directory. With blank `DATA`, ecRad receives `.` and binary table paths retain their basenames. Each complete path has at most 511 bytes plus a zero terminator. The whole-parent source comparison covers the recorded nonblank directory. The accepted filename selector chooses climate files, whose four owned associations are published only after construction succeeds.

Success returns zero, allocation failure returns one, and unsupported input returns two. File-service errors retain their child return values. Failure releases acquired owners, clears the completion marker and leaves a partly written MODEL that the caller must discard. Release is idempotent for this owned lifetime. It clears climate associations and owned resource bits while retaining borrowed input addresses. This preserves the original aborting setup semantics without promising an atomic MODEL transaction.

The parent preserves `x18`, `x19` through `x29`, the required low halves of `v8` through `v15`, stack alignment and FPCR. Its 512-byte stack frame separates saved registers from outgoing arguments. Child arithmetic and mathematical providers remain frozen. FPSR and the library error indicator remain natural. Quiet production omits informational writes and profiling. The raw writer uses Linux file calls and records incoming unwritten storage without modification. It is a setup diagnostic, rather than the final forecast output format.

## Accepted Evidence And Limits

Separate fresh source and assembly processes match all 30,160,836 captured bytes across 187 sections, including 33 complete records, owner payloads and nine static namespaces. The comparison relates 145 typed owner addresses after checking their payloads. A verification-only allocation observer provides identical incoming storage before either call, allowing source-unwritten bytes to be checked without repairing returned data. Both immediate numerical states are FPCR zero, FPSR 24 and errno zero. The direct whole-parent ABI mask is zero.

The ordinary assembly executable has no original OpenIFS production dependency. It records the same complete raw stream and matches all 27,197,308 defined bytes. Its unrelated incoming heap contents differ in 3302 unwritten bytes, which remain unmodified in the output. All 2,748,656 previously qualified initial field bytes remain exact. Actual consumer bindings reach the frozen exponential, logarithm and power providers. The unsupported three-dimensional aerosol case returns its declared failure and creates no output. An independent source and lifetime review passes. Existing accepted child physical, bounds and allocation-failure checks are reused.

Original `SUECRAD`, original record constructors and original module state remain in a separate verification process. Public NetCDF, ecRad, mathematical, transform and required runtime services remain explicit external dependencies. This setup result does not establish a complete autonomous forecast or a speed improvement.

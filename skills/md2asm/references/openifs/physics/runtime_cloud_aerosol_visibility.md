# Runtime cloud and aerosol visibility

This contract extends the storage range of the existing CLAERVIS calculation from the [climatological aerosol layer](../../../../../formulations/openifs/physics/climatological_aerosol_visibility_layer.md). Visibility is the distance in metres at which the stated visual contrast becomes too small. The calculation uses aerosol extinction and liquid water, ice, rain and snow at the bottom model level. The direct [AArch64 source](../../../../../src/openifs/physics/runtime_cloud_aerosol_visibility.S) preserves the ordered equations and all eleven constant words.

Let $`P`$ be the allocated column count and $`L`$ the level count. The runtime entry `md2asm_runtime_cloud_aerosol_visibility` accepts $`1 \le P \le 128`$ and $`1 \le L \le 137`$. Each real value uses FP64, which is a 64-bit floating-point format. Each matrix owns $`8PL`$ bytes in column order, and each vector owns $`8P`$ bytes. For a one-based active column $`j`$, the bottom matrix value has byte offset $`8((L-1)P+j-1)`$. The earlier range of at most 24 columns and 19 levels remains behind runtime dispatch. One assembled solver and one original reference library served all three checked shapes without recompilation.

The application binary interface, or ABI, places the first eight addresses in registers and later addresses on the incoming stack. Every table entry is an address, including the four scalar inputs. The caller keeps every complete declared owner alive until return.

| Argument | Original name | Location | Storage and units |
| --- | --- | --- | --- |
| 1 | `KIDIA` | `x0` | First active column, int32. |
| 2 | `KFDIA` | `x1` | Last active column, int32. |
| 3 | `KLON` | `x2` | Allocated columns $`P`$, int32. |
| 4 | `KLEV` | `x3` | Levels $`L`$, int32. |
| 5 | `PCLAERS` | `x4` | Aerosol extinction vector, inverse kilometres. |
| 6 | `PA` | `x5` | Cloud-fraction matrix; its values remain unread. |
| 7 | `PL` | `x6` | Liquid-water matrix, kilograms per kilogram. |
| 8 | `PI` | `x7` | Ice matrix, kilograms per kilogram. |
| 9 | `PR` | Stack +0 | Rain matrix, kilograms per kilogram. |
| 10 | `PS` | Stack +8 | Snow matrix, kilograms per kilogram. |
| 11 | `PRSF1` | Stack +16 | Full-level pressure matrix, pascals. |
| 12 | `PT` | Stack +24 | Temperature matrix, kelvin. |
| 13 | `PVISICL` | Stack +32 | Visibility output vector, metres. |
| 14 | Runtime context | Stack +40 | Two read-only pointers in 16 bytes. |

The first context word points to the 520-byte physical-constant owner. Its ready word at byte 512 must be one, and the dry-air gas constant at byte 184 must be finite and positive. The second context word points to a 16-byte profiling policy. That policy contains a pointer to a zero int32 and a reserved zero word. Production obtains these values from owned records. The separate Fortran reference uses its original module values for verification.

Scalar addresses and the false-hook flag align to four bytes; real arrays, context, physical owner and profiling-policy owner align to eight bytes. First is from 1 through $`P+1`$, last is from 0 through $`P`$, and last is at least first minus one. First equal to last plus one gives an empty interval. Each declared span must be valid and must not wrap around the address range. Read-only inputs may share storage. The complete output span must be disjoint from every input, scalar, context, physical owner, profiling-policy owner and four-byte false-hook flag before a write. The routine uses a fixed 768-byte stack frame and no heap allocation.

Air density is pressure divided by the product of the dry-air gas constant and temperature. Each bottom condensate amount is multiplied by density and then by 1000 to obtain grams per cubic metre, before taking its maximum with positive zero. The calculation preserves the original coefficients, the three [accepted power calls](../support/power_original_rounding.md) per active column and the ordered ice, liquid, snow and rain sum. It then adds molecular and aerosol extinction in source order before dividing the fixed contrast coefficient by total extinction. Molecular scattering gives a clear-air limit of 100 kilometres.

The selected CLIMAER caller supplies aerosol extinction in inverse kilometres: it explicitly converts aerosol mass to grams per kilogram before its shortwave-extinction call. CLAERVIS divides this input by 1000 to obtain inverse metres. The original CLAERVIS declaration comment gives inverse metres for the incoming value; the selected caller and conversion equations resolve this comment inconsistency. This statement applies to that selected caller, while the older RADACA-only unit interpretation remains outside this component acceptance. No input word or arithmetic operation changes.

The floating-point control register must be zero, selecting nearest-even rounding and gradual underflow. Contraction, reassociation, approximate arithmetic and fused multiply-add remain forbidden. Success returns zero. Invalid metadata, owner-ready state, policy or floating-point mode returns two before an output write. The entry preserves `x18`, saved registers, stack alignment and the control register. Floating-point flags and errno retain their natural results from the unchanged arithmetic. The original Fortran subroutine has no defined integer return; its raw return and platform-register state are recorded separately.

Three complete source/runtime pairs passed: $`P=17,L=137`$ with active columns 2 through 16, $`P=9,L=5`$ with columns 3 through 9, and $`P=24,L=19`$ with columns 1 through 24. All 162,736 compared bytes agreed, including inputs, outputs, inactive columns and guards. One empty interval and fourteen refusal cases preserved their known buffers. Immediate native status, register, floating-point and errno checks passed. The actual power-call target matched the accepted assembly provider before the first visibility call.

The saved outputs passed 101 independent checks of the high-precision extinction equation, positive visibility, the clear-air limit, aerosol monotonicity and clamping of negative condensate. The largest sampled relative error was approximately $`2.691 \times 10^{-16}`$, below the declared local comparison band of $`2^{-47}/(1-2^{-47})`$ (about $`7.105 \times 10^{-15}`$). These checks cover the three component cases; they do not establish a global power-function error bound. Source, verifier and saved-result reviews passed, and the controller and both child process groups closed without signals. The local evidence retains source versions, exact bindings, raw states and failure records.

This range and interface extension adds no original-routine body to the completion count. CLIMAER_LAYER, the active parameterisation branch and the complete forecast still require integrated acceptance.

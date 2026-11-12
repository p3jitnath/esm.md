# Runtime Model Time And Forcing Contract

Revision 1 records the runtime UPDTIM interface and its optional daily boundary update. UPDTIM advances the model clock and selects solar, gas, ozone, aerosol and surface updates. The original source is `arpifs/utility/updtim.F90`. The [assembly entry](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/physics/runtime_model_time_and_forcing.S) preserves the existing ordered arithmetic. This record accepts the changed logical decisions only. It does not accept the complete runtime parent or forecast.

## Interface And Bounds

The application binary interface, or ABI, defines the argument locations and preserved registers. `md2asm_runtime_model_time_and_forcing_with_failure_reason` takes the following ten arguments. Sizes are bytes. FP64 is a 64-bit floating-point number format. Ordinary FP64 values occupy eight bytes, and integer or logical words occupy four bytes. Object and FP64 addresses require eight-byte alignment. Integer and logical addresses require four-byte alignment.

| Argument | Location | Input or owned state |
| --- | --- | --- |
| `GEOMETRY` | `x0` | Readonly record of at least 20,400 bytes |
| `TSURF` | `x1` | Existing surface owner of at least 18,224 bytes |
| `MODEL` | `x2` | Mutable complete model owner of at least 4,275,088 bytes |
| `KSTEP` | `x3` | Readonly step word |
| `PTDT` | `x4` | Readonly positive finite time interval in seconds |
| `PTSTEP` | `x5` | Readonly model step of exactly 450 seconds |
| `LDCLUPD` | `x6` | Readonly logical word with value zero or one |
| `LDUPDECAEC` | `x7` | Optional readonly logical word with value zero or one |
| `PI05` | Incoming stack byte 0 | Null in this supported route |
| Borrowed context | Incoming stack byte 8 | Aligned 80-byte record described below |

The retained children select TCo1279 geometry and 137 atmospheric layers. TCo1279 names the horizontal spectral resolution. The live blocking width `P` is from 1 through 1,024. The positive local point count `Q` must not exceed the positive global point count. The block count is the ceiling of `Q/P`, so a final partial block is allowed. `NSTOP` is from zero through 575, and `KSTEP` is from zero through `NSTOP+1`. The stored step is 450 seconds, radiation frequency is eight steps, and the selected initial date is 21 June 2026 at midnight. Other configuration and constant comparisons in the entry remain required.

Each context offset below is measured in bytes. A borrowed record stays owned by its caller and must remain live throughout the call.

| Offset | Context value |
| --- | --- |
| 0 | Canonical physical-constant owner of 520 bytes |
| 8 | Configuration owner of 67,616 bytes |
| 16 | Radiation-climate owner of 2,792 bytes |
| 24 | Existing 64-byte hydrostatic context |
| 32 | Ozone-directory character address |
| 40 | Directory length from 1 through 480 |
| 48 | Existing mutable 64-byte daily-climate context |
| 56 | Address of the false four-byte `LSCMEC` word |
| 64 | Address of the false four-byte `LRLXG` word |
| 72 | Zero reserved word |

The entry returns status in `w0` and a failure reason in `x1` when needed. Zero means success. Admission refusal returns status two. A reached child can return another nonzero status. A later failure retains completed source updates, so callers must not assume rollback. All participating ranks must enter the retained MPI status agreements in the same order. MPI is the public message-passing interface used to agree the status across ranks.

## Conditional Update And Ownership

`LMCCEC` is the model logical word at byte 1,562,896. Zero disables the daily ECMWF boundary update, and one enables it. Every other word value is refused. Inside the existing daily and uncoupled branch, the daily-climate child runs only when both `LMCCEC` and `LDCLUPD` are one, as required by UPDTIM lines 879 and 918 to 919. A false value skips that child while the existing clock, monthly, ozone and gas order remains unchanged.

The caller supplies real owners and complete child inputs. No verification driver supplies a numerical stage. The daily-context step pointer is borrowed temporarily and restored after its child returns. The entry uses a 512-byte stack frame. It preserves `x18`, `x19` through `x29`, the return address and the lower 64 bits of `v8` through `v15`. The status helper uses a separate 80-byte frame and preserves the incoming floating-point state and `errno` around its public MPI call.

The floating-point control register, FPCR, must be zero. This selects nearest-even FP64 rounding and gradual underflow. The change adds only integer control decisions. All existing FP64 instructions, constants, rounding points and child calls retain their order. Contraction, reassociation and reduced precision remain forbidden.

## Completed Check And Limits

One nine-case process checked the exact admission and daily-call branch windows against the independent logical truth table. It covered both logical values and invalid model logical words. The check preserved 38,476,080 readonly bytes, the ABI, FPCR zero, FPSR 16 and `errno` 777. FPSR records floating-point exception flags. This check did not call the complete parent or an original OpenIFS numerical entry.

The two logical changes have exact source inverses. The published source assembles with the same flags to the exact accepted object. Complete runtime-parent numerical agreement, complete raw-state agreement and exact forecast-file agreement remain pending. The separately qualified [coarse time-parent contract](model_time_and_forcing.md) keeps its existing acceptance scope. The [optional daily storage contract](../setup/optional_daily_climate_storage.md) records the matching inactive allocation rule.

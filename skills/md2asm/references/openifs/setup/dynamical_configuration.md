# Selected Dynamical Configuration

This checkpoint owns the complete selected SUDYNCORE setup and all 43 nonparameter YOMDYNCORE variables. The dynamical core calculates the atmosphere's large-scale motion. Its selected Earth settings leave the idealised test modes disabled. The original setup routine remains a separate control. Production receives only live bounded namelist text and writable owned storage, with no original module or prepared state packet.

The fixed ABI is `int md2asm_initialize_dynamical_configuration(text, bytes, namespace, capacity)`, using x0 through x3. The namespace has 320 bytes and eight-byte alignment. Its first three FP64 words are RPLRG, RPLDARE and RPLRADI, the named scale inputs for convection. The complete layout contains 34 FP64 variables, eight int32/logical variables, twelve CTEST_FAMILY characters and four retained padding bytes. Every complete range is mapped, nonwrapping and disjoint. Text has one through 262144 bytes and the first uppercase NAMDYNCORE group must be empty. Return zero means complete and two means unsupported input before mutation. FPCR must be zero.

Retain the source default-store order, the reciprocal calculations before and after the empty namelist, and REFERENCE_LEVEL=1−RSIGMAB. Use the correctly rounded source values for literal-only expressions, including RHS_KAPPA=2/7. Preserve the separate source pressure RP00_DYN of 101315 Pa, which differs from the model's hybrid reference pressure. The selected scaling values are one. All eleven source-unwritten FP64 variables and the final four alignment bytes retain their incoming values. Their later producers must run before any selected consumer reads them.

Keep a separate owned 320-byte static namespace with source-compatible scalar symbol aliases for final direct forecast consumers. The raw producer accepts explicit caller storage and does not depend on those aliases or original globals. Alias sizes and offsets follow the source declarations. Original libraries and these owned scalar exports remain separate in verification, with their actual providers checked once.

Use the accepted bounded empty-group reader. Direct instructions preserve x18, Arm saved registers, FPCR and errno. Numerical FPSR events follow the declared arithmetic. The genuine input/output services change errno; this service effect stays separate from the numerical utility. The retained source and native FPSR values agree in all checked cases. Check the natural enclosing return after accepted physical-constant setup without forcing a diagnostic flag. One small verifier compares all 320 namespace bytes, immediate ABI/status, defined reciprocal and reference-level identities, source-unwritten preservation, meaningful bounds and the no-OpenIFS static link. No unchanged numerical suite or forecast is needed. Expected work fits within 45 minutes, leaving ample publication time in the exclusive allocation.

The [direct producer](../../../../../src/openifs/setup/dynamical_configuration.S) writes the explicit namespace in x2. The separate [owned scalar storage](../../../../../src/openifs/setup/owned_dynamical_namespace.S) declares `md2asm_owned_dynamical_namespace` and 43 GNU source-compatible scalar aliases named `__yomdyncore_MOD_` followed by the lowercase source member. Each alias has the exact width and byte offset below. A caller that uses these aliases must pass that owned static namespace to the producer before any consumer runs. Initialising a different buffer does not update the static aliases. Consumers with explicit storage inputs can instead use their caller-owned namespace. No original module storage is linked into the standalone executable or used by the raw producer.

The producer has a 48-byte stack frame. The accepted empty-group child is an integer leaf with no stack frame, so total private use is 48 bytes. The parent preserves x18, x19 through x29, the stack pointer, FPCR and errno. It uses only caller-saved floating-point registers d0 through d2. The selected six divisions are one divided by one and the subtraction is exact for the rounded source operands, so FPSR retains every incoming flag. No fused operation, approximate instruction, reassociation or reduced precision is present. No heap allocation or release is needed.

The twelve-character test-family field uses spaces rather than zero bytes. The following table defines every nonparameter source variable. An unwritten field retains all incoming bits and remains undefined before a later producer sets it; a zero static preimage does not make it a source-defined zero. The last four alignment bytes at offsets 316 through 319 are also retained.

| Source member | Offset | Bytes | Selected value or lifetime |
| --- | ---: | ---: | --- |
| `RPLRG` | 0 | 8 | 1 |
| `RPLDARE` | 8 | 8 | 1 |
| `RPLRADI` | 16 | 8 | 1 |
| `RUSPLRADI` | 24 | 8 | 1 |
| `RCORIOI` | 32 | 8 | 1 |
| `RUSCORIOI` | 40 | 8 | 1 |
| `RUSPLRG` | 48 | 8 | 1 |
| `RAMP` | 56 | 8 | positive zero |
| `RT00_DYN` | 64 | 8 | 288.15 K |
| `RP00_DYN` | 72 | 8 | 101315 Pa |
| `RU00_DYN` | 80 | 8 | positive zero |
| `RST0_DYN` | 88 | 8 | positive zero |
| `RSIGMAB` | 96 | 8 | 0.7 |
| `REFERENCE_LEVEL` | 104 | 8 | FP64 subtraction 1 − RSIGMAB |
| `RDELTA_T` | 112 | 8 | 60 K |
| `RDELTA_THETA` | 120 | 8 | 10 K |
| `RPRESSURE_SCALE` | 128 | 8 | 0.00001 |
| `RHS_KF` | 136 | 8 | unwritten; retain incoming bits |
| `RHS_KA` | 144 | 8 | unwritten; retain incoming bits |
| `RHS_KS` | 152 | 8 | unwritten; retain incoming bits |
| `RHS_KS_KA` | 160 | 8 | unwritten; retain incoming bits |
| `RHS_KAPPA` | 168 | 8 | rounded literal expression 2/7 |
| `RTHSW_0` | 176 | 8 | 200 K |
| `RPHSW_D` | 184 | 8 | 10000 Pa |
| `RPHSW_EQ` | 192 | 8 | unwritten; retain incoming bits |
| `RPHSW_PL` | 200 | 8 | 10 hPa |
| `RPHSW_EQ_PL_HALF` | 208 | 8 | unwritten; retain incoming bits |
| `RPHSW_D_REV` | 216 | 8 | unwritten; retain incoming bits |
| `RJACSLDIA` | 224 | 8 | 1.5 |
| `RLIPSLDIA` | 232 | 8 | 5 |
| `RCHI` | 240 | 8 | unwritten; retain incoming bits |
| `RLAMBDA0` | 248 | 8 | unwritten; retain incoming bits |
| `RLAMBDAD` | 256 | 8 | unwritten; retain incoming bits |
| `RPHID` | 264 | 8 | unwritten; retain incoming bits |
| `LAQUA` | 272 | 4 | false |
| `LAPE` | 276 | 4 | false |
| `LHELDSUAREZ` | 280 | 4 | false |
| `LPPSTEPS` | 284 | 4 | false |
| `L_HS_WILLIAMSON` | 288 | 4 | false |
| `NTESTCASE` | 292 | 4 | −1 |
| `MSSTSCHEME` | 296 | 4 | 9 |
| `NOISEVOR` | 300 | 4 | 0 |
| `CTEST_FAMILY` | 304 | 12 | twelve spaces |

The pure empty-group check runs before the first store so invalid input leaves storage unchanged. An accepted empty group has no state or floating-point effect; the source numerical operations keep their relative order. SUDYNCORE first sets the inverse scaling inputs to one, performs the three reciprocal calculations, sets the remaining defaults and subtracts the rounded RSIGMAB from one. The selected empty NAMDYNCORE group changes no defaults, after which the three source reciprocal calculations run again. The Coriolis reciprocal retains the source zero guard. The literal-only RHS_KAPPA expression uses FP64 bits `0x3fd2492492492492`. The REFERENCE_LEVEL result is `0x3fd3333333333334`; replacing it with a rounded 0.3 literal would change one bit and is forbidden. The Held–Suarez and aquaplanet branches remain false, so the eleven associated source-unwritten FP64 members are not read or written. The selected defaults also satisfy every source validity guard.

The accepted bounded group reader checks the first uppercase exact NAMDYNCORE group. Its first nonblank marker must be in source columns one through ten. The selected body contains only whitespace and comments before a terminating slash. A later duplicate is ignored. Unsupported nonempty groups, invalid sizes, null or wrapped addresses, overlap, misalignment and a nonzero FPCR return two before any state or floating-point change.

The critical gate compares all 320 bytes in four complete genuine SUDYNCORE cases, for 1,280 bytes with zero differences. Three direct calls start with FPSR values zero, eight and twenty-four; source and native retain those exact values. One enclosing case calls the accepted physical-constant producer immediately before SUDYNCORE and observes FPSR sixteen on both paths without resetting it. Genuine formatted input/output changes errno from 777 to zero, while the numerical producer retains 777. All native ABI masks are zero; the genuine source has its known x18 mask two. Source status is captured by the direct ABI probe before any field serialization or unit cleanup.

The source cases cover zero and patterned preimages, comments, first-group selection and later duplicates. They preserve 92 unwritten bytes, including a signalling NaN payload, signed zero and infinity bits without interpreting them. Forty independent relations check scaling factors, the reference subtraction, pressure, constant ratio, inactive modes, test fields and diagnostic thresholds. A genuine typed query confirms all 43 widths. Seventeen unsupported cases leave inputs and output unchanged, and two protected ranges place the entire live text and the namespace immediately before inaccessible pages.

A separate assembly entry runs with PATH as its only environment setting, reads the live text and writes a 320-byte stream identical to the genuine source. Its link contains the owned producer, accepted empty-group reader and owned namespace only. It has no dynamic section or undefined symbols. Every one of the 43 scalar aliases resolves to the expected byte range in its own zero-initialised storage. The zero-call provider receipt independently identifies genuine SUDYNCORE and all 43 genuine source variables in the strict OpenIFS reference library. The native verification DSO contains no scalar aliases, which prevents the owned storage from replacing reference variables during comparison. Instruction inspection finds six divisions, one subtraction and no fused arithmetic.

The source definitions are `arpifs/setup/sudyncore.F90`, `arpifs/module/yomdyncore.F90` and `arpifs/namelist/namdyncore.nam.h`. The published contract covers the selected empty group and all nonparameter module state. Diagnostic listing output and disabled idealised test families are outside this producer. No forecast or performance run is part of this checkpoint. Retained local receipts identify the actual source versions, build commands and complete checks.

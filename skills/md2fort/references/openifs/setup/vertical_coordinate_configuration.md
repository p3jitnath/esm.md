# Vertical Configuration Setup

This component constructs the vertical-discretisation controls that SUGEOMETRY passes to SUVV1. A vertical discretisation divides the atmosphere into layers. Its controls choose pressure formulas and the interpolation functions between those layers. The selected T21 case has an empty NAMCVER group, ECMWF mode enabled, hydrostatic dynamics and more than two dimensions.

## Source And Scope

The source is YOMCVER::SUCVER_GEOM in arpifs/module/yomcver.F90, lines158–468. The component supports its complete default-and-reset path for an empty NAMCVER group and each combination of the three canonical logical inputs LECMWF, LDNHDYN_GEOM and LR2D. A canonical logical word is a 32-bit integer equal to zero or one. A nonempty NAMCVER group remains unsupported. Diagnostic text and DR_HOOK profiling are omitted; no calculation on the supported path is omitted.

The caller SUGEOMETRY associates its TCVER pointer with the inline vertical-geometry record before calling this setup at line147. SUDIM and SUGEM_NAML run earlier. SUVV1 consumes the resulting controls to allocate and construct vertical-coordinate owners. Those callers and owners remain separate startup dependencies.

## Interface And Storage

The raw entry md2asm_initialize_vertical_configuration receives a writable 216-byte TCVER record in x0, LECMWF in w1, LDNHDYN_GEOM in w2 and LR2D in w3. It returns zero in w0 on success or two for a null, misaligned or invalid logical input. Rejection occurs before any record byte changes. The record must be eight-byte aligned and must not overlap the assembly source. Its complete extent is writable.

The entry owns no allocation. The caller owns the record and its lifetime. Named GNU 12.3 type offsets are retained in vertical_configuration_layout.json. Only the source-assigned member bytes change. The source leaves RLAPL2PI, RVFE_CENTRI and three four-byte padding regions untouched, so this entry preserves those incoming bytes. A future full record constructor must also provide the declared type default RLAPL2PI=positive zero before calling this setup; this setup does not substitute an imported original type constructor.

The Arm 64-bit application binary interface defines argument registers and preserved registers. This leaf uses only caller-saved integer registers, has no stack frame, preserves x18, all callee-saved registers, FPCR, FPSR and errno, and calls no external service. FPCR must specify round-to-nearest, ties-to-even, with gradual underflow.

## Default Rules

Finite-element layers are enabled exactly when LECMWF is true and both LDNHDYN_GEOM and LR2D are false. Then NVFE_TYPE=3, NVFE_ORDER=4, NVFE_INTBC=NVFE_DERBC=3, LVFE_CENTRI=true and LVFE_FIX_ORDER=true. In the remaining cases finite elements are disabled, NVFE_TYPE=0, NVFE_ORDER=1 and those boundary and logical controls are zero. The remaining source logical controls are false on this empty-group path.

RHYDR0 is dimensionless. It equals the original rounded LOG(2) constant 0x3fe62e42fefa39ef in ECMWF mode and exactly one otherwise. The original compiler evaluates this constant expression before execution, so the assembly loads the same rounded word without introducing a runtime logarithm or a new arithmetic flag. RVFE_ALPHA=positive zero, RVFE_BETA=one half, RVFE_KNOT_STRETCH=one and RMINDETA=RFAC1=RFAC2=positive zero. These quantities are dimensionless. All source integer counters not described above are zero.

## Required Checks

The focused verifier compares each complete 216-byte returned record with the separate original body for the eight logical combinations, including two distinct incoming byte patterns. It checks the source-unwritten bytes and outer bounds without masking or normalising returned bytes. Immediate ABI and raw numerical-status observations are required for the selected path and a non-ECMWF edge. Invalid logical inputs must leave the complete record unchanged. The empty-group parser must accept the actual 3137-byte T21 fort.4 and reject a missing, truncated or nonempty group before construction. Native forecast admission remains separate.

## Native Input Binding

The original entry __yomcver_MOD_sucver_geom receives the writable record in x0 and a pointer to the canonical input LDNHDYN_GEOM word in x1. It reads the live LECMWF and LR2D module-data words as explicit compatibility inputs. It does not call an original procedure, constructor or virtual method. A complete autonomous bootstrap must own equivalent configuration words instead of these original module addresses.

The native adapter reads fort.4 through the C open/read/close boundary, using a private malloc buffer of 262145 bytes and accepting at most 262144 input bytes. It retries interrupted reads, checks the first line-leading NAMCVER group with the assembly parser, requires that group to be empty, then frees the buffer before construction. The marker uses the exact uppercase name NAMCVER, following original POSNAME. Supported input markers start within the first ten columns. Exclamation comments continue to the next line. Unsupported input exits with code 121 after releasing its private buffer and file descriptor, before any record byte changes.

The successful original NAMCVER read clears errno to zero. The adapter preserves that measured input boundary, restores incoming FPCR, FPSR and x18 before the raw construction, and passes errno zero to the raw child. The raw child preserves this status. A genuine source control resets errno after scratch-file preparation and captures it immediately after SUCVER_GEOM, so later fixture cleanup cannot conceal the source result. The adapter uses a 112-byte frame with 16-byte stack alignment and preserves every required register. Its integer-only getter md2asm_vertical_configuration_native_count_get returns the number of completed native calls; the selected original startup is expected to call it once. This counter does not construct model state.

The focused native status correction passes three immediate source/native cases with errno seeded to 777. Both return errno zero, FPCR zero and unchanged FPSR 16, with all 648 returned record bytes and guards exact and all six ABI/status calls passing. The raw sixteen-case evidence is reused.

The [complete forecast comparison](../../../../../src/openifs/README.md#verification) passes for this selected route, with every final owner and saved file compared. Original startup and remaining runtime services still prevent an autonomous-executable claim.

The current marker check skips a preceding lowercase group, as the original does. One fresh genuine SUCVER_GEOM call through its actual POSNAM input route matches every returned record and guard byte for that case, with native ABI and status preserved. An uppercase marker with comments is accepted, and a lone mixed-case marker is rejected. Other unchanged constructor and input checks are reused.

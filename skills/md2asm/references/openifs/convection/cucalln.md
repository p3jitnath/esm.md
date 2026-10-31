# CUCALLN solver contract

Revision 1 accompanies [the convection controller](../../../../../formulations/openifs/convection/convective_column_controller.md) and [the direct assembly](../../../../../src/openifs/convection/cucalln.S).

## Interface and complete ownership

The unique entry is `md2asm_cucalln_7240564`. It retains the complete original 76-pointer CUCALLN interface. Registers x0 through x7 hold the first eight pointers; the remaining 68 pointers occupy the aligned caller stack. Integers and logicals occupy four bytes, and FP64 values occupy eight bytes. The 1,792-byte private frame preserves the original nonvolatile registers, platform register x18 and 16-byte stack alignment. Scratch storage is allocated and released within the call. Inputs and outputs must have complete declared storage; selected real arrays have eight-byte alignment.

Let K be the number of columns and N the number of layers. Full-level arrays use K*N values and half-level arrays use K*(N+1), with the column index changing first. Vector owners use K values. `PLUDELI` has four K*N phase planes; `PSNDE` and `PRSUD` each have two. The complete state objects each have 1,240 bytes. Their consumed T, Q, U and V arrays use measured 88-byte descriptors with eight-byte elements, unit column stride and level stride K. Cumulative and dynamical state owners remain read-only. All four local tendency arrays are outputs; their descriptors remain unchanged.

| Configuration owner | Bytes |
| --- | ---: |
| YDERAD | 2,040 |
| YDML_PHY_SLIN | 864 |
| YDML_PHY_EC | 10,408 |
| YGFL | 1,359,136 |
| YDCHEM | 11,936 |
| YDSPP_CONFIG | 3,192 |

The retained `interface-names.json` lists all 76 pointers, and `frozen-contract.json` and the relay's explicit length table identify every complete array owner and output. No raw configuration object is treated as embedded in another object. Writable numerical owners cannot overlap consumed read-only owners. Output aliases are cloned as one common owner so that their original alias relationships remain intact.

## Declared model scope

The complete normal-physics route supports K from 1 to 4,096, N from 4 to 137, at most 65,536 column-level cells, and the original selected-column interval including an empty interval. Linear physics and stochastic perturbations are disabled; downdraught physics is enabled. Tracer transport is inactive: the tracer count is zero or the original tracer-transport flag is false, with declared tracer count from zero to 64. The inactive tracer scratch has zero numerical read footprint. Complete tracer owners remain unchanged in this scope.

The positive time interval is at most 86,400 s. The original complete SATUR, CUMASTRN and CUSTRAT physical domains apply to their consumed inputs. Consumed pressure thickness is positive. The model's gravity, heat capacity and latent energies are positive, and its humidity lower bound is nonnegative. The heat-capacity multiplier is `1+RVTMP2*q`; the source setup sets RVTMP2 to zero, and a positive nonzero setting is also independently exercised. There is no admission requirement on a numerical slot unused by the selected source branch.

## Complete ordered calculations

The controller copies all four cumulative tendencies into the local owners and clears its entrainment scratch. It forms provisional temperature and winds by separate multiply then add, forms provisional humidity in the same order, and applies the original lower humidity bound. It calls complete private SATUR, CUMASTRN and CUCCDIA bodies. When all three original diagnostic cloud flags are false, it calls complete CUSTRAT with its accepted condensation child.

The controller sets all eight upper flux values to positive zero. It accumulates heat, moisture and momentum fluxes downward using the original pressure weighting and rounded heat-capacity multiplier. A second ordered pass forms latent rain and snow fluxes with the original negation operation, accumulates both condensate phases, and adjusts total heat and moisture fluxes. It finally subtracts each cumulative tendency from its local owner. The complete original children produce all convection diagnostics and flux outputs.

The accepted precipitation child also writes positive zero to both `PFPLCL` and `PFPLCN` boundary rows for every column, including unselected columns. Every other unselected parent-owned output word is preserved. Canonical output is the complete little-endian configuration, array and state owners in original argument order, followed by the complete pointed local tendency arrays. No numerical value is rounded, masked or normalized during comparison.

Primary arithmetic uses separate ordered FP64 operations, round-to-nearest with ties to even, gradual underflow, signed zeros and FPCR zero. The original-compatible private math and numerical children are reused unchanged. The native body calls no Fortran numerical routine. A weak verification observer reads the completed state and checks independent flux identities; it supplies no stage or output value. Its own diagnostic status is excluded, while the native numerical status is retained and compared exactly with the source.

## Essential evidence

Before emission, six protected original cases pass 12,974,508 complete owner bytes and 166,012 independent 120-digit pressure, water, momentum and latent-energy relations. Twelve native placements match 25,949,016 bytes with zero differences, pass 332,024 relations, preserve 4,672 output words, and pass the immediate complete 76-pointer Arm interface probe. Stored source observations preserve bytes and fresh status.

Four live paired cases pass 5,599,088 complete bytes, 1,120 independent flux relations and 440 unchanged descriptor words. These include complete and partial columns, the low-cloud branch, an empty interval and two calls with profiling enabled. One additional source-first case uses the actual zero heat-capacity humidity correction and passes 1,399,772 complete bytes, 480 independent 120-digit and 480 live relations. Each successful paired call verifies a genuine private native-call counter, fresh numerical status, unchanged FPCR, caller status and errno. Loading and pairing from an alternate working directory pass.

Fourteen focused prewrite cases reject unsupported FPCR, column and layer bounds, descriptor stride, type or offset, and active tracer transport in both native and paired routes. Shared owners show zero writes before rejection. The 65,536-byte system page size is retained in the record. The live relay clones all complete owners, protects read-only copies, changes only the shadow descriptor base pointers, checks every other descriptor word, restores original base pointers before whole-object comparison and compares every numerical byte.

Local records and immutable ready identities are in `.runtime/openifs/cucalln_controller_7240564/`. Root owns the next forecast and acceptance count. These paired checks are intermediate evidence for a full autonomous assembly forecast; they make no complete-forecast or performance claim.

## Actual Forecast Acceptance


| Original routine | Actual calls | Compared bytes | Byte scope |
| --- | ---: | ---: | --- |
| cucalln | 2,150 | 3,222,437,200 | Complete returned routine owners |

Shared saved-file evidence and its limits are in the [coverage record](../../../../../src/openifs/README.md#shared-coarse-forecast-evidence).

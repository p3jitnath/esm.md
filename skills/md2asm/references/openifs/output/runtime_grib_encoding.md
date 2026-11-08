# Runtime GRIB Templates And Fields

GRIB is the binary file format for saved weather fields. These entries create a message template and encode one complete field from live grid and forecast metadata. Direct assembly owns the OpenIFS record layout, setter order and handle lifetime. Public ecCodes supplies file-format operations, and public Multio supplies its normal packing policy. Original OpenIFS routines run only in the separate comparison process.

The assembly sources are [runtime_grib_template_creation.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/output/runtime_grib_template_creation.S) and [runtime_grib_field_encoding.S](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/output/runtime_grib_field_encoding.S). They follow original `PRESET_GRIB_TEMPLATE` and `GRIB_CODE_MESSAGE`, with the level, parameter and edition rules in `GRIB_UTILS_MOD`. The qualified [packing policy](runtime_grib_packing_policy.md), [time helper](runtime_grib_time.md) and [soil labels](runtime_grib_soil_levels.md) retain their separate numerical contracts.

## Template Interface

`md2asm_create_runtime_grib_template` takes Geometry20400 in x0, the common context128 in x1, kind in w2 and an eight-byte output handle word in x3. Kind 0 creates SH, 1 creates SH_ML, 2 creates GG, 3 creates GG_ML and 4 creates GG2. SH stores spectral coefficients, which describe global wave patterns. GG stores values on a Gaussian latitude grid. ML also stores the model vertical coordinates.

The template takes its dimensions from Geometry. It admits 2 through 16,384 rows, a maximum of 1 through 65,536 longitude points, spectral degree 1 through 4,096 and 1 through 512 model levels. The positive complete point count fits a signed 32-bit integer. A regular grid uses rows times longitude points. A reduced grid uses the sum of its live row lengths. Every row length is positive and at most the maximum longitude count. Stretch is exactly one, and its selector is zero or one. Rotated or stretched grids are outside this route.

Latitude, row and vertical arrays retain their GNU descriptors, which hold each array's address, type, bounds and stride. The arrays must cover latitude and row indices 1 through the row count and vertical indices 0 through the model-level count. Lower bounds may extend to −16,384, upper bounds to 65,536 and positive strides to 65,536, with the exact canonical offset equal to minus lower bound times stride. Latitude and vertical data use FP64 values, and row lengths use signed 32-bit integers. The caller supplies physically valid latitude and vertical data in complete readable spans.

The entry keeps the source sample creation, current GRIB2 tables, sample serialization and reconstruction, then applies setters in source order. Latitude conversion, longitude increment and vertical A-then-B copying retain their original separate operations and rounding. The source-selected route is a fresh normal ECMWF forecast with local definition 1, stream 1025, type fc, zero ensemble size, leg 1, false LOBSC1 and LVAREPS, and restart character '0'. Source `SUARG` initializes NSTEPINI to zero. Class, cycle, date, experiment and grid dimensions remain live inputs.

The template owns a 512-byte frame aligned to 16 bytes and one private allocation of `8R+16(L+1)` bytes for R rows and L levels, at most 139,280 bytes. Both must fit the remaining context budget. Public ecCodes allocations remain within the enclosing process memory limit. The entry releases all private work and deletes failed handles. It publishes the handle only after success. The caller eventually calls public `codes_handle_delete`.

## Field Interface

`md2asm_encode_runtime_grib_field` takes spec128 in x0, complete FP64 values in x1 and three separate eight-byte output words in x2 through x4. These words receive message address, message byte count and owner handle. The specification uses eight-byte words except for its FP64 timestep.

| Byte offset | Meaning |
| --- | --- |
| 0 | Borrowed template handle |
| 8 and 16 | Nonnegative parameter identifier and signed level, each widened from the source 32-bit integer |
| 24 and 32 | Representation, zero for grid or one for spectral, and ASCII level kind m, p, v, t or s |
| 40 and 48 | Nonnegative current step and complete value count |
| 56 and 64 | Spectral degree and FP64 timestep in seconds |
| 72 | Borrowed 40-byte previous-step record |
| 80 | Common context128 |
| 88 | Borrowed 144-byte soil labels |
| 96 through 127 | Zero |

The complete field has 1 through 2,147,483,647 finite FP64 values. The positive largest finite value remains the source missing marker. Spectral input has exactly `(N+1)(N+2)` values for degree N. Grid input follows the complete gathered global grid order. Surface layer indices are from 0 through 512. Satellite parameters 260510 and 260511 require an absent instrument record and are refused by this selected route.

The entry clones the template and sets truncation, forecast type, time, packing, levels, parameter and values in source order. Packing receives the original ML, PL, PV, TH or SF label. Source table 128 aliases are decoded only at the final parameter setter, where decoded identifier 128 preserves the original skipped setter. Earlier decisions use the raw parameter. Soil and snow fields keep the original layer setter order. The pure integer entry `md2asm_runtime_grib_edition` takes parameter in w0 and level in w1 and returns source edition 1 or 2 in w0.

The encoder owns a 512-byte frame. Its conservative private requirement is `1024+16(N+1)` bytes, including nested packing, fit and time work. The common context budget is positive and at most 64 GiB. Public-library allocation remains within the enclosing process limit. A successful message address belongs to its returned handle. The caller writes exactly the message byte count before deleting that handle. The original word-buffer file convention rounds this count to four bytes and appends zero through three ASCII spaces. No bytes beyond the raw message may be read.

Source-invalid time fields return success with zero address and length and a valid clone owner. The writer skips those saved bytes and still deletes the handle. Failure deletes the clone and preserves all three output words. The sole 144-byte `md2asm_owned_grib_soil_levels` symbol is initialized from the actual completed surface before field encoding and remains live through the last surface field.

## Common Context And Machine State

The common context contains borrowed configuration67616 at 48, clock360 at 56, canonical loop552 at 64, output metadata112 at 72 and a false profiling switch at 80. Byte 96 holds the remaining private byte budget. Other slots belong to the enclosing Fullpos caller. Loop byte 44 is the CHARACTER1 restart selector, so its three padding bytes are not read as a logical value. Loop word 60 is the LVAREPS logical value. The initial eight-byte file record contains NGRIBFILE and NUDATE and does not supply NSTEPINI.

All record, payload and output spans are mapped, stable, correctly aligned, nonwrapping and disjoint where the interface requires separate inputs and results. The entries preserve the Arm saved registers, x18, the aligned stack and FPCR. FPCR must be zero. Ordered FP64 operations remain unfused. FPSR and errno retain their natural numerical and public-library effects. Return 0 means success, 2 means refused input, 1 means private allocation or clone failure, and other nonzero values retain the public service error.

The production graph uses one canonical owned dynamical namespace, the qualified fit and time providers, ecCodes, libc, libm and public Multio with its FDB plugin dependency. The same default Multio policy is initialized once in each isolated comparison process. No custom policy replaces its output.

## Accepted Checks And Limits

The changed component passes 15 complete template pairs, 36 complete field pairs and 16 edition pairs against explicit-argument original controls. The message and source word-buffer comparisons contain 316,182 raw bytes and 316,204 rounded bytes with zero differences. They cover regular and reduced Gaussian grids with 2, 4 and 6 rows, spectral degrees 1, 3 and 21, and 2, 3 and 137 model levels. Both GRIB editions, model, pressure, potential-vorticity, theta, soil and snow levels, table aliases, missing values, source-invalid time fields and default expression count −1 are exercised.

All 67 paired immediate FPCR, FPSR, errno and return observations match. Native ABI masks are zero. The separate GNU reference retains its previously declared x18 exception. The original checks perform 918 metadata, unit and input-preimage relations. Fourteen additional native observations cover twelve prewrite refusals, one natural ecCodes error and one allocation refusal with exact import restoration. The completion checks add 29 result-preservation and restoration relations.

The final original process closes 149 guarded regions, and the native completion closes 57 with a guard scan after each remaining call. The earlier native process completed all 51 template and field comparisons and input-preimage checks, then stopped on a verifier archive-path error before its final bulk guard scan. That missing scan is not claimed. Its exact messages and statuses were compared from saved data, and no completed encoding call was repeated. All processes were reaped with empty process groups. Failed verification records and frozen source versions remain under `.runtime/`.

These are component checks on small changed grids, including 137 vertical levels. They do not establish operational-resolution message qualification, complete forecast files or full-forecast agreement.

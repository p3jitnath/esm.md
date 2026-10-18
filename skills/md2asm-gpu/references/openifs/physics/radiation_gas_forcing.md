# Radiation Gas and Solar Forcing on the GPU

Revision 1 keeps the accepted [forcing equations](../../../../md2asm/references/openifs/physics/updrgas.md), [gas lookup](../../../../md2asm/references/openifs/physics/greenhouse_timeseries.md) and [solar lookup](../../../../md2asm/references/openifs/physics/solar_irradiance.md). A lookup finds values between neighbouring dates by joining them with a straight line. FP64 means a floating-point number stored in 64 bits. PTX is NVIDIA’s virtual assembly language. All numerical calculations run in directly emitted PTX. The Arm host supplies addresses, storage and CUDA calls.

## Inputs and Ordered Calculations

The parent first calculates a decimal year. A positive fixed year becomes that integer plus one half. Otherwise use the calendar date and elapsed whole days. On a consumed restart branch, reproduce the source rounding halfway away from zero, the selected integer or two-level restart calculation, and signed integer division towards zero. Use the original twelve mean-month values and 365.25 days per mean year. Each floating-point addition, multiplication and division rounds separately to nearest, with halfway ties going to the even result.

Each table date must be finite and strictly increasing, and the query must be strictly inside the complete table interval. Select the first interval whose lower date includes the query and whose upper date excludes it. An internal tie therefore selects the interval that starts at the query. Subtract the lower date from the query, subtract the lower date from the upper date, then divide these separately rounded differences. For each field, subtract the lower value from the upper value, multiply by the weight, then add the lower value. Preserve signed zero and subnormal values, which are very small numbers below the normal FP64 range.

A gas volume ratio gives its share by volume. A mass ratio gives kilograms of that gas per kilogram of dry air. Before the lookup, form eight separately rounded molar-mass quotients in the original order. Multiply the seven returned gas volume ratios and the original nitrogen-dioxide placeholder by their corresponding quotients. Use the supplied solar override when present. Otherwise a zero solar mode selects the owned constant, while each other supported mode selects the complete solar lookup. Solar values have units of watts per square metre.

Consumed molar masses are positive and finite. Gas table values are nonnegative and finite, and solar table values are positive and finite. Selected differences, quotients and results must remain finite. The caller supplies a valid positive calendar date. Consumed timestep and day length are positive and finite, their rounded integers fit signed 32 bits, the rounded day length is nonzero, and the selected restart integer product fits signed 32 bits. An unused NaN timestep remains unchanged.

## Original Interfaces

An application binary interface, or ABI, defines argument order, register duties and returned values. The original Arm interfaces use addresses in x0 through x7, with later addresses on the incoming stack. GET_YEAR returns its FP64 value in d0.

| Original calculation | Address order | Returned model bytes |
| --- | --- | --- |
| `UPDRGAS` | TDYNA, TERAD, TERDI, TRIP, optional solar value | Complete 176-byte TERDI |
| `UPDRGAS::GET_YEAR` | TDYNA, TRIP | One FP64 value in d0 |
| `yomghgtimeseries::get_ghg_concentrations` | Class wrapper, year, seven scalar gas outputs | Seven separate FP64 owners |
| `yomsolarirradiance::get_solar_irradiance` | Class wrapper, year, scalar solar output | One FP64 owner |

The complete TDYNA, TERAD and TRIP input records have 456, 2,040 and 175,976 bytes. The optional solar address may be zero. TERDI changes only at bytes 16, 24, 32, 40, 56, 64, 72, 80 and 168. Preserve every other byte. All complete input owners stay read-only.

A lookup class wrapper has sixteen bytes. Its first word names the plain table object, while its second word is unused data. The gas object has 520 bytes, with eight 64-byte array descriptions and a signed count at byte 512. The solar object has 136 bytes, with two array descriptions and a signed count at byte 128. The first description always gives dates.

Each array description holds the allocation address, index offset, element size, type information, span, stride and lower and upper bounds. Require eight-byte FP64 elements, type word `0x30100000000`, span eight, unit stride and at least two table entries. The lower bound may be smaller than one. The complete allocation must contain logical entries one through the table count. Its offset is the negative lower bound. Check complete allocation ranges, alignment and address arithmetic before reading the selected cells.

## Production Ownership and Private Storage

The parent receives an explicit 128-byte record containing sixteen addresses. Their order is dry-air molar mass, the eight gas molar masses in source order, constant solar input, day length, forecast-mode flag, restart step, initial date, gas plain object and solar plain object. Floating-point scalar owners have eight bytes. The three integer or logical owners have four bytes. Read payloads only when the selected source branch consumes them.

The production host builds this record from the autonomous forecast's owned radiation context. Its constants address is at byte 48 and its climate address is at byte 4256. The eleven scalar offsets are 160, 248, 256, 264, 288, 312, 320, 328, 336, 144 and 40. The gas object starts at climate byte 136 and the solar object at climate byte zero. The three live integer controls use the existing assembly-owned scalar aliases. Original OpenIFS module table pointers supply only the separate verification reference.

The parent owns 1,024 private scratch bytes for its date, child address vectors, class wrappers, contexts, seven gas values, eight molar-mass quotients and eight final mass ratios. Validate complete public owners and their separation from this workspace first. The private workspace may change when a later numerical-domain check refuses an input. Public model owners and their guards remain unchanged on refusal. Commit all nine TERDI values only after every selected calculation succeeds.

Each GPU entry uses the existing [64-byte call context](../gpu_call_context.md), revision one and serial mode zero. Use one block and one thread, with all other dimensions one and no dynamic shared memory. The host checks its actual OpenMP parallel state before launch. The context identifies the parent's scratch and live record. The standalone date entry uses a three-address device vector containing TDYNA, TRIP and a private eight-byte result owner, while its Arm host keeps the original two-address interface and d0 return.

Keep child argument stores immediately before each call and stage each complete return immediately afterwards. The numerical parent and lookup functions return 32 bytes containing new flags, an error code and zero mathematical error-write and counter totals. The date function returns sixteen bytes containing its value, new flags and an error code. Merge accepted flags with integer OR. Preserve incoming errno because these basic operations do not write a mathematical error. Unsupported launches, owners or domains return a context error without a numerical fallback.

The Arm hosts preserve x18, x19 through x29, the stack alignment and required saved FP64 registers. Their 384-byte lookup frames and 768-byte parent/date frames contain only interface data and saved machine state. Parent scratch uses malloc and free. CUDA, allocation, OpenMP and C error-slot services provide no numerical model stage. The production parent replaces the older `forcing_caller_binding.o` provider of `md2asm_updrgas` during forecast linking.

## Assembly and Evidence

The eight PTX sources are in [the physics GPU folder](../../../../../src/openifs/physics/gpu/). Their names start with `greenhouse_lookup`, `solar_lookup` or `forcing_`. Assemble each with `ptxas -c -arch=sm_90 --fmad=false`, then link it once with the accepted scalar exponential, IEEE operator-status and exact-product-sum objects. The two Arm interfaces are [lookup calls](../../../../../src/openifs/physics/gpu/forcing_lookup_calls.S) and [parent/date calls](../../../../../src/openifs/physics/gpu/radiation_gas_forcing_calls.S). The verification-only define retains isolated original scalar owners. Production selects its owned context mapping.

All FP64 model operations use the accepted complete-status helpers. Native instruction review distinguishes exact signed-integer conversions and integer-division lowering from model floating-point arithmetic. Packed zero-register instructions that construct literal words consume no model operand. The new native functions contain no fused or approximate model operation.

The component checks pass 564 complete original Fortran, selected CPU and GPU lookup calls across 9,312 returned bytes and 3,492 independent high-precision relations. The parent passes 44 complete original Fortran, selected CPU and GPU calls. Forty-two contained date executions also pass separate selected CPU and GPU calls. Together the parent and date checks cover 8,080 returned bytes and 878 independent date, gas and solar relations. Every compared byte, immediate numerical status and checked ABI obligation agrees.

Eight additional production-owned profiles pass all 1,408 returned bytes using the real assembly-loaded climate context. Focused current-host checks retain the actual serial-state query. Thirty-five new boundary checks preserve the declared public and guard bytes. An ordinary-device graph covers 347,932 allocated bytes with 32 typed pointer relocations, retaining exact public metadata and outputs and checking each owner’s guards. Private workspace is not a model output. These are component results. A complete autonomous GPU forecast and its runtime remain separate, unfinished gates.

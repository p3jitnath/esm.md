# Owned Surface Input Configuration

Revision 1 constructs the complete 2,304-byte conversion configuration used by the selected surface-input loader. It supplies the original controls, physical constants and twenty vegetation types from declared source defaults. Vegetation cover gives the fraction covered by plants, and leaf area index gives leaf area per ground area. The [conversion contract](surface_initial_state_conversion.md) defines every output word and its use in surface physics. This constructor uses no original model object or module data and adds no original-body credit.

## Source And Selected Route

The actual selected flags are LECMWF true, LECURR false, LEOCCO and LEOCWA true and LMCC04 false. SUCT0 chooses the ECMWF route, SU0PHY applies its surface defaults, and SUMCC leaves the coupling flag false. SUSVEG declares twenty vegetation types and both tables from index zero through twenty. Index zero copies the desert entry at index eight. Its selected leaf-area override is zero, so the declared table remains unchanged. SUSSOIL gives RWLMAX the value 0.2 mm. SUPHEC selects RCIMIN 0.02 without dynamic sea-ice coupling. SUSTHF defines water density as RATM divided by 100, giving 1,000 kg m−3. These values agree with the complete retained genuine MODGRINML input record. No captured record is a production input.

## Interface And Ownership

The interface is int md2asm_initialize_surface_input_configuration(constants, output, capacity). Registers x0, x1 and x2 carry an unchanged 520-byte record from the [owned physical-constant initializer](../setup/physical_constant_setup.md), a writable 2,304-byte output and its capacity. Both complete records are mapped, eight-byte aligned, nonwrapping and disjoint. The source setup flag must be one and the caller must preserve the producer's defined constant values. The constructor reads RG, RTT, RATM and the setup flag only. No pointer into original storage is accepted. The caller owns both records and retains them after return.

Check pointer ranges, overlap, capacity, setup flag and FPCR before any output write. Return zero after complete construction or two before mutation for an unsupported input. FPCR, the Arm floating-point control register, must be zero. Clear the complete output namespace, then set its counts, flags, bounds, source constants and 21 entries in each vegetation table. Unused words and table tails remain positive zero under this existing representation contract. The source-table words are rounded directly from the original decimal literals. Copy RG and RTT without arithmetic and compute water density through one FP64 division by 100. FP64 is a 64-bit floating-point number.

The function is a leaf with no stack or child call. Preserve x18, saved integer and vector registers, FPCR and errno. FPSR, the arithmetic-status register, keeps inherited flags and records genuine arithmetic. Division is exact for the selected provider. There is no operating-system, codec, OpenIFS or Fortran dependency.

## Acceptance

Compare all 2,304 produced bytes with the existing complete genuine source configuration under distinct incoming output patterns and arithmetic flags. Reuse its accepted source metadata and conversion checks. Verify all 42 vegetation values against source literals, their physical ranges, water-density units, unchanged complete constants, guards and the Arm ABI. Reject invalid ranges, capacities, overlap, mode and unfinished constant storage before mutation. Inspect the pure assembly executable and dependency closure, then obtain independent source and ABI review. No forecast is needed for this constructor.

## Completed Checkpoint

Two incoming patterns and arithmetic-flag cases match 4,608 complete bytes against the retained genuine source record, leaving 1,040 constant-record bytes unchanged. All eleven immediate ABI and status calls pass with zero native register masks. Nine invalid inputs reject before mutation. Forty-seven physical-range and representation checks pass, including both complete vegetation tables, their desert defaults, the water density and every unused output word. The standalone assembly process constructs both records and writes all 2,304 configuration bytes exactly. It has no shared-library dependency. Its unchanged logarithm child retains its direct Linux exit_group rejection service. Independent source and ABI review passes.

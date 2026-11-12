# Disabled stochastic pattern setup

The original `SUSPSDT` and `GET_SPP_CONF` routines configure random perturbations of physical tendencies and parameters. This assembly route supports the inactive settings in the present, empty `NAMSPSDT` and `NAMSPP` input groups. It publishes every defined inactive configuration value and owns the empty grid storage that the original inactive path still creates. It uses public memory allocation services and the accepted empty-group reader.

The two stages retain their source positions. `SUSPSDT` runs before `INI_CUCONVCA` and `SURAND1` in `SU0YOMB`. `GET_SPP_CONF` runs after `SURAND1` and before `INI_SPP`. Calling these two entries together does not supply the intervening stages.

## Interfaces and bounds

All addresses are byte addresses. The application binary interface (ABI) uses the usual Arm argument registers, a stack aligned to 16 bytes, and a 32-bit status in `w0`. A status of 0 means success, 2 means that an input is outside the supported scope, and 1 means an allocation failed. The entries preserve the floating-point control and status registers, the incoming `errno` value and the platform register `x18`. The floating-point control register must be zero on entry.

| Entry | Registers | Required storage |
|---|---|---|
| `md2asm_initialize_disabled_sppt_setup` | `x0` Geometry, `x1` capacity, `x2` MODEL, `x3` capacity, `x4` text, `x5` text bytes | Geometry 20,400 B, MODEL 4,275,088 B; stack 256 B, or 336 B with its private child |
| `md2asm_initialize_disabled_spp_configuration` | `x0` MODEL, `x1` capacity, `x2` text, `x3` text bytes | MODEL 4,275,088 B; stack 96 B |
| `md2asm_release_disabled_sppt_setup` | `x0` MODEL, `x1` capacity | The same live MODEL and owned grids; stack 128 B, or 160 B with its private child |

Geometry and MODEL must be aligned to 8 bytes, fully mapped and separate from each other and the input text. Their address ranges must not wrap. Text has 1 to 262,144 bytes. MODEL's Geometry pointer at byte 8 must identify the supplied Geometry. The caller supplies fresh, unallocated configuration and data pointer bases; the entries refuse existing allocations before changing any output. The release entry requires the valid graph created by this route, after its final reader, with the inactive flag still false.

Grid metadata comes from the live Geometry: block width at byte 5144, block count at 5160, global layer count at 5224, local grid-point count at 7376 and global grid-point count at 7388. The block width is 1 to 1024 and the layer count is 1 to 256. All counts are positive, the local point count does not exceed the global count, and the block count is the ceiling of local points divided by block width. The local layer partition, process count and time step do not enter these inactive grid descriptors. The main Fortran executable is unchanged.

## Storage and source values

The SPPT configuration is MODEL bytes 1,535,608 through 1,552,927. Its data record starts at byte 4,270,800 and has 352 bytes. The SPP configuration starts at byte 1,552,928 and has 3192 bytes. The assembly publishes 16,940 defined SPPT configuration bytes, 40 defined scalar or null-pointer data bytes, three complete 64-byte owned descriptors, and 768 defined SPP configuration bytes. These values include source-declared defaults and the final inactive humidity limiter value.

SPPT first acquires a temporary empty integer reservation and three separate 1808-byte `GRIDPOINT_FIELD` records. It then acquires four empty array reservations for each grid, in source order: `NGRIB`, `NPARAMID`, `GP3D` and `GP2D`. Each zero-length allocation reserves one real byte, whose value is undefined and never read. The temporary is released after construction, leaving 15 owned allocations. Integer slice descriptors borrow the two integer reservations, and `SCAL` borrows `GP3D`; release never frees those aliases.

Each grid has 868 defined metadata bytes. They describe two empty integer arrays and empty real arrays with live block width, layer count and block count, together with nine null views. Fortran column order determines every stride and offset. Zero field counts make the source grid-finalisation loops empty. The assembly changes no numerical payload.

Normal release frees each grid's four owned reservations and then its outer record. It clears the three owned MODEL base words and accepts a repeated release of the resulting null graph. If construction fails, the entry frees its reached allocation prefix and clears those same published bases. Defined scalar and descriptor metadata can remain changed. The enclosing setup must stop on this failure; it must not resume numerical work with the partial state.

The present-empty source `NAMSPP` leaves its local 32-byte `CSPP_MODEL_NAME` undefined, and the inactive source branch does not read the string. The assembly preserves the incoming owner bytes. Source-unassigned padding and unused descriptor tails also retain the assembly route's incoming bytes. These undefined source bytes have no cross-allocation equality claim. Every defined value and pointer relationship remains part of the exact comparison; no physical output byte is rounded or hidden.

## Qualification

Independent source and ABI review checked the complete loaded assembly, constants, library calls and owner rules. A bounded runtime gate passed 17 calls: the two original setup routines, one source cleanup wrapper and fourteen native calls. The reference uses captured operational metadata with block width 17, 137 global layers and 97,055 local blocks. A second native shape uses block width 5, two layers and three blocks. The stages use separate captured MODEL records at their declared source positions; the check does not claim that their intervening producers ran in this process.

The gate retained 323 raw files with 149,457,742 bytes. It compared every defined configuration byte, all 868 defined bytes in each grid and every actual owner or alias relationship, while checking every other native MODEL and grid byte against its incoming preimage. Seven input or release refusals preserved their complete mapped outputs. The final-allocation failure released its reached prefix. Native guarded allocation records contain 47 acquisitions, 47 matching releases and one failed attempt, with no empty payload inspection. The source cleanup used the actual `DEALLOCATE_GRID` routines and retired its three published bases; source heap frees were not separately traced.

All native calls passed the ABI check, preserved floating-point control and both tested status seeds, and retained incoming `errno` 777. The original `SUSPSDT` uses `x18`, so source verification permits that recorded difference; original diagnostic I/O can also change `errno`. Guard and file-descriptor checks, restoration of the two verification allocator bindings, process limits and independent process-identity cleanup passed. The production default allocation bindings were checked separately without interposition. The failed first attempt remains unaccepted: its checker wrote an argument file after seeding `errno`. A checker-only revision moved seeding immediately before the call; the assembly and reference routines did not change.

This component does not establish complete `SUPHY`, a complete physical driver, `CALLPAR`, an autonomous forecast, or support in other limited storage and numerical providers.

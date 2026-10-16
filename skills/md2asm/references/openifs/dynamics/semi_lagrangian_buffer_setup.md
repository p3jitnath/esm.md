# Selected Semi-Lagrangian Buffer Setup

A semi-Lagrangian method follows moving air to find the earlier values needed by a forecast. This setup prepares integer maps into its work buffers. A parity value is an exact plus-one or minus-one multiplier used when a field crosses a pole. The maps and parity values are dimensionless. The trajectory speed limits are in metres per second.

## Inputs And Source Order

The caller owns the complete 4,275,088-byte MODEL record. Its earlier GFL stage must supply the field counts, and its TDYNA stage must supply the selected dynamics switches. The caller also supplies the live number of vertical levels from Geometry, the original configuration text and four platform controls. The four 32-bit platform integers are NCONF, LECMWF, LR2D and LR3D at byte offsets 0, 4, 8 and 12. The supported configuration is 1, 1, 0 and 1. These controls must come from their owned SUCT0 producer.

The bounded SUDYN producer runs after those inputs exist and before SUINTDYNSL or SUSC2B reads them. It prepares the consumed interpolation controls. The separate velocity producer prepares the two trajectory speed limits before SUSC2B reads them. The source SUSC2B caller runs the complete selected SUSLB map producer after these SUDYN controls and before its halo calculation and SLCSET stage. Each producer borrows the actual live MODEL record. It does not load a captured state.

## Assembly Interfaces

All interfaces use the Arm C application binary interface, which defines argument registers and saved registers. MODEL must have 8-byte alignment and capacity at least 4,275,088 bytes. The level address and platform-control address must have 4-byte alignment. A successful call returns 0. A supported-input refusal returns 2 before mutation, and an allocation failure returns 1 with the incoming MODEL unchanged. Stack frames keep 16-byte alignment. The functions preserve x18 and every used saved register. No floating-point arithmetic is executed, and the floating-point control and status registers are unchanged.

| Entry | Arguments In Register Order | Purpose |
| --- | --- | --- |
| `md2asm_initialize_selected_interpolation_controls` | x0 MODEL, x1 MODEL capacity, x2 text address, x3 text length, x4 platform-control address | Prepare the bounded SUDYN controls consumed by interpolation. |
| `md2asm_initialize_selected_sl_velocity_controls` | x0 MODEL, x1 MODEL capacity, x2 level address, x3 level-input capacity | Set VMAX1 and VMAX2 from the live level count. |
| `md2asm_initialize_selected_sl_buffer_maps` | x0 MODEL, x1 MODEL capacity, x2 level address, x3 level-input capacity | Construct the three complete selected pointer records and allocate both parity arrays. |
| `md2asm_release_selected_sl_buffer_maps` | x0 MODEL, x1 MODEL capacity | Free the two parity arrays, clear their base addresses and permit a repeated release. |

The level input holds one 32-bit integer and has capacity at least 4 bytes. Supported level counts range from 1 through 255. The platform input contains 16 readable bytes. The text input contains at most 262,144 readable bytes and is checked by the accepted bounded empty-group reader. The selected NAMDYN and NAMDYNA groups must be empty. A nonempty override is refused before any output changes.

## Controls And Buffer Calculations

The control producer follows the selected assignments in `arpifs/setup/sudyn.F90`, including the five interpolation orders, split-physics order, Cartesian trajectory flags, LSLHDHEAT, LVWENO_T, LADVF, L2TLFF and NSLDIMK. LSPLTHOIGFL remains an input from SUGFL3. This is the consumed control segment, rather than a claim that every SUDYN stage is present. The velocity producer follows section 1.10 of the same source. Fewer than 91 levels select VMAX1 = 220 m/s and VMAX2 = 320 m/s. At least 91 levels select 250 m/s and 400 m/s. These values are stored as their exact FP64 bit patterns.

The supported SUSLB branch has third-order interpolation, no split high-order physics, no nonhydrostatic terms, no SLHD, COMAD or three-dimensional turbulence buffer, and Cartesian trajectory storage. Its live nonnegative field counts are at most 64. Active unsupported branches return 2. The producer preserves each incoming pointer-record byte except the fields assigned by the source. It gives unused relative pointers the source value of minus 99,999, then advances each buffer cursor in the original order.

Let $`L`$ be the live level count, $`G`$ the NUMFLDS_SL1 field count and $`P`$ the NDIMSLP count. The resulting first-buffer count is $`(14 + G + P)(L + 2) + 1`$. The second-buffer count is $`8L + 1`$. The first parity array has one value per first-buffer entry. Its six horizontal-velocity sections contain minus one, giving $`6(L + 2)`$ negative entries. All other entries contain plus one. These relations are checked independently of the pointer-map comparison. For the selected 19-level state, the derived counts are 463 and 153.

Both fresh parity descriptors must have null base addresses on entry. Both allocations complete before the new records are committed. The second parity array has one source-unwritten element, whose ordinary allocation bytes remain unchanged. Production uses ordinary malloc. The separate reference comparison supplies matching incoming allocation bytes only to compare storage that the source does not assign. It compares allocated owners by their declared correspondence, since separately allocated addresses differ. All other record bytes and every complete parity payload must agree exactly.

## Boundaries And Evidence

Production calls only the accepted empty-group reader and libc malloc/free. Original OpenIFS declarations and routines are confined to the separate verification reference. Controls and velocity setters have no persistent allocation. Map release must run before MODEL storage is released, after all parity consumers finish. Allocation failure frees only the newly created owners and leaves the incoming records unchanged.

Three genuine complete SUSLB profiles compare 12,825,264 MODEL bytes and 8,832 parity bytes with zero differing defined bytes. A separate check uses the actual read-only initial-entry inputs without following captured pointers. The controls and direct map entry have ABI mask zero, with matching floating-point state and errno. The compiled source SUSLB call changes x18, recorded as source ABI mask 2, while the direct assembly preserves it. Twelve critical refusals, both allocation-failure positions, repeated release and a level input ending at a protected page pass. Four velocity profiles cover levels 19, 90, 91 and 255, compare 17,100,352 complete MODEL bytes exactly and preserve the native ABI and numerical state. No complete forecast or timing result is claimed by this component gate.

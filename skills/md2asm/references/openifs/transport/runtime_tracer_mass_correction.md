# Runtime Tracer Mass Correction

Revision 1 continues the [existing direct tracer correction](../../../../../src/openifs/transport/tracer_mass_correction.S) with live grid dimensions and explicit dependencies. A tracer is a substance carried by moving air. This QMFIXER entry corrects its total mass, then keeps each new value within its surrounding source values. The physical equations and the selected source order are unchanged.

The [assembly entry](../../../../../src/openifs/transport/runtime_tracer_mass_correction.S) is `md2asm_runtime_tracer_mass_correction`. It keeps the fifteen original address arguments in their original order and appends dependency32 as argument sixteen, at incoming stack byte 56. Its four eight-byte words name the owned distributed partition, configuration, HYD64 and reserved zero. HYD64 names physical520 in its first word. These are the complete records from the qualified model, partition and hydrostatic producers. All consumed records and owners stay mapped and nonwrapping through the call. FP64 arrays and records require eight-byte alignment, while four-byte indices require four-byte alignment. No original OpenIFS state or numerical routine supplies a calculation.

The original argument order is listed below. Arguments one through eight use x0 through x7, and the remaining addresses occupy consecutive eight-byte stack slots.

| Slot | Original name | Contents |
| --- | --- | --- |
| 1 | Geometry | Grid dimensions, coefficients and maps |
| 2 | GMV | Motion-field layout |
| 3 | COMPO | Source composition record |
| 4 | DPHY | Source physics record |
| 5 | YGFL | Tracer counts, controls and field positions |
| 6 | DYN | Interpolation layout and controls |
| 7 | KL0 | Interpolation indices |
| 8 | PLSCAW | Interpolation weights |
| 9 | PB1 | Source fields and their surrounding grid points |
| 10 | SL | Source-plane width and map record |
| 11 | PGMVS | Previous motion fields |
| 12 | PGMVT1S | Predicted log surface pressure |
| 13 | PGFL | Previous tracer fields |
| 14 | PGFLT1 | Predicted tracer fields |
| 15 | PEXTRADYN | Source diagnostic interface |

Let P be columns per block, L layers, B blocks and N active grid points on one process. Geometry supplies them at bytes 5144, 5224, 5160 and 7376. Require $`P(B-1) < N \le PB`$. The last block has $`N-P(B-1)`$ active columns. Read source-plane labels from Geometry bytes 5244 and 5248, then derive their count. Read the old and new tracer counts separately from YGFL bytes 48 and 64. Each component supplies its own source and destination field positions. Changing the input grid or block size does not require recompiling the solver or main Fortran reference.

Store array elements with the first index changing fastest. PGFL has shape (P,L,old fields,B), while PGFLT1 has shape (P,L,new fields,B). KL0 has shape (P,L,4,B) of four-byte indices. PLSCAW has shape (P,L,interpolation fields,B). PB1 has shape (source-plane width,source fields). PGMVS has shape (P,motion fields,B), and PGMVT1S has shape (P,B). Numerical fields use FP64, which stores each number in 64 bits. Derive every field count, complete capacity and stride from its own live record with checked arithmetic. Caller-owned buffers include inactive fields and final-block padding, which retain their declared bytes.

The selected route retains five corrected fields, pressure correction, multiplicative option three and beta one. It keeps vertical finite elements, extra diagnostics, proportional tracer correction and the alternate advection option disabled, matching the actual configuration. Unsupported options return 2 before mutation. The parent admits positive column and layer counts up to 4096, but a complete route must also obey every linked child's limits and all source-index bounds. This component evidence does not establish arbitrary resolution or physical-option support.

The parent owns fourteen temporary arrays in one allocation. Its capacity in bytes is

```math
8P\left[(7L+19)B+7L+2\right].
```

The [runtime pressure correction](surface_pressure_mass_correction.md), [distributed norm](distributed_grid_point_norms.md), [column integral](pressure_weighted_column_integral.md), [hydrostatic pressure factors](../dynamics/hydrostatic_grid_calculations.md), [interpolation](../dynamics/laitli.md) and [local bounds](../dynamics/laminmaxint.md) execute in source order. LAITLI starts at KL0 plane one, while LAMINMAXINT starts at plane zero of that same owner. All source-plane address calculations use the live leading dimension. External elementary mathematics and public distributed-library services remain explicit.

The stack frame has 1536 aligned bytes. The entry preserves x18, saved integer registers, the stack and the incoming floating-point control register. It retains each numerical child's natural status across allocation agreement and release. Return 0 means success, 1 means allocation failure and 2 means an unsupported admission. Processes agree allocation success before entering a collective numerical child. Every returned path releases the temporary owner. The complete writable pressure and tracer owners must be separate from each other and from consumed input arrays and records.

One unchanged production library passes P17/L5 and P31/L3, then the full P17/L137 case on four processes with 1,649,920 points per process and source-plane widths 1,744,925 and 1,783,837. The full-layer comparison has zero differences across 50,686,003,296 complete tracer, log-pressure and raw-status bytes. Independent checks integrate each actual output column, check global mass and local bounds, and preserve inactive cells, input pages, guards and ownership. Native ABI checks and all releases pass. The smaller cases also cover admission refusals and a one-process allocation failure handled collectively. No main Fortran executable is rebuilt.

These checks use the actual complete grid metadata with constructed admissible numerical inputs. Joining the loaded weather state, the TRMFIXERS dispatcher, the complete time loop and the autonomous operational forecast remains separate. The component checks provide no full-forecast runtime or speedup.

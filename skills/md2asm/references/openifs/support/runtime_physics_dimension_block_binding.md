# Runtime Physics Dimensions And Latitude Binding

A dimension record stores array sizes and the current grid block for a physics calculation. This component connects the 26 source counts and the actual latitude view used by `EC_PHYS_DRV`. A latitude index is a dimensionless integer that identifies a global latitude row.

The [fourteen soil class assignments](../setup/ecmwf_soil_diagnostic_class_counts.md) precede the unchanged [dimension initialization](physics_grid_dimensions.md). Live Geometry supplies block width, spectral truncation and vertical layers. The actual SUDIMF1 setup supplies tile, ozone, sea-ice, ocean and snow counts in MODEL, while surface metadata at FIELDS byte 4,512 supplies four surface counts. The soil producer supplies the remaining fourteen. With the actual stochastic control false, initialization sets K2DSDT to zero without reading undefined N2D. The source ocean count NCOM is zero, so its signed subtraction gives `KLEVO=-1`. This stage allocates no ocean array.

The accepted assembly constructors create all input owners in source order. Geometry completes its distributed partition before MODEL, FIELDS and configuration are created. Its block optimizer reads the live local and maximum point counts, then selects width 17 from the legitimate intermediate width 16 using the original one-thread integer search. The calculation supplies every count. Keep all parent records, array descriptions, payloads and the borrowed surface trajectory alive through their last reader.

## Block Entry

The application binary interface, or ABI, is `int md2asm_update_runtime_physics_dimensions(dimensions, Geometry, block0)`. Registers x0 and x1 hold the record addresses, and w2 holds the zero-based unsigned block index. The writable dimensions record has 192 bytes, and immutable Geometry has 20,400 bytes. Both are eight-byte aligned, mapped, nonwrapping and disjoint. Dimensions must already be initialized from this Geometry. Every reachable owner must be mapped, alive and disjoint from the output.

Let $`P`$ be the live block width at Geometry byte 5,144, $`N`$ its local point count at byte 7,376 and $`B`$ its block count at byte 5,160. These are positive signed 32-bit integers. Integer division gives $`B=1+(N-1)/P`$. For a zero-based block $`b<B`$, the original loop gives its one-based block number, first local packed point and active column count:

```math
IBL=b+1,\qquad JKGLO=bP+1,\qquad ICEND=\min(P,N-bP).
```

This local packed position differs from the separate global file index. An array descriptor stores its base address, element type, bounds and stride. The GS descriptor at Geometry byte 8,472 describes $`B`$ contiguous one-based records of 1,472 bytes. Each record contains 23 descriptors of 64 bytes. Its NGPLAT descriptor at byte 1,344 selects ICEND 32-bit latitude indices, with bounds one through ICEND and unit stride. Geometry byte 9,880 describes the complete NGPLAT owner, with $`N`$ elements and bounds one through $`N`$.

The entry checks scalar bounds, descriptor types and layout. The selected latitude base must equal the complete owner base plus $`4bP`$ bytes, with the full selected range inside that owner. All products and addresses must fit the mapped 64-bit address space. The entry then tail-calls the unchanged `md2asm_update_physics_dimensions`, forwarding IBL, ICEND, JKGLO and the actual GS descriptor. Only KBL, KFDIA, KSTGLO and KGPLAT change. Numerical field payloads stay unchanged.

Return zero means success. Return two refuses an unsupported top-level record, block, shape or owner relation before any write. Mapping valid complete address ranges remains a caller requirement. The entry uses no stack frame, allocation, floating-point operation, original OpenIFS call or method table. It preserves x18 through x30, all vector registers, floating-point control and status, errno and stack alignment. Caller-saved integer registers and integer flags are scratch.

## Checks And Limits

One bounded four-process check uses genuinely constructed distributed Geometry with $`P=17`$, $`N=1649920`$, $`B=97055`$ and 137 layers. It compares two distinct count preimages, dimension initialization and the first and final blocks. The final block starts at local point 1,649,919 and has two active columns. The source and assembly agree in all 32 stage pairs, complete MODEL and dimension outputs, immediate numerical status and preserved registers. All twelve pre-write refusal cases pass on each process.

Independent checks reconstruct the fourteen assignments from saved complete MODEL images. They also recover each selected latitude row from the retained array descriptions and unique-point indices using the original integer relation $`1+(NUNIQUEGP-1)/NDLON`$. Typed shape and owner guards have independent source review, while the runtime check uses genuine valid owners. Complete borrowed records and payloads remain unchanged. Direct owners release in normal order. The public transform library retains eleven global allocations until process exit.

The main Fortran executable and accepted numerical children remain unchanged. The later work-record owners, complete EC_PHYS and CALLPAR execution, and forecast acceptance remain open. This component adds no complete weather routine to the accepted count.

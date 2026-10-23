# Operational Model Storage And Input Ownership

MODEL stores model settings, FIELDS owns the physical arrays, and Geometry describes the grid. This parent creates MODEL and FIELDS at their final addresses and loads the selected initial files. It never copies a record that contains pointers. An alias is another name for an existing address. The caller keeps Geometry, its process partition and fifteen alias destinations alive until all consumers finish.

The Arm application binary interface, or ABI, passes arguments in x0 onward and returns an integer status in w0. MODEL has 4,275,088 bytes, FIELDS has 529,288 bytes, Geometry has 20,400 bytes and the live process partition has 4,096 bytes. Every complete range is mapped, does not wrap around the address space and has the declared alignment. Record addresses and pointer slots align to eight bytes. The floating-point control register FPCR must be zero. The functions preserve x18, required saved integer registers and vector-register halves, and the declared FPCR, FPSR and errno behaviour of their children. Each temporary stack frame aligns to sixteen bytes.

| Entry | Arguments in register order | Result |
| --- | --- | --- |
| `md2asm_create_distributed_operational_model_storage` | Geometry, 120-byte alias-destination table, fresh output slot | Creates the 800-byte owner, MODEL and FIELDS |
| `md2asm_attach_distributed_operational_model_configuration` | Owner, 9,328-byte headers, text, text length, live partition | Attaches final settings and the same partition |
| `md2asm_begin_distributed_operational_model_work_storage` | Owner | Creates saved-pressure work at stage 1 |
| `md2asm_advance_distributed_operational_model_work_storage` | Owner | Advances one source-defined storage stage |
| `md2asm_allocate_distributed_operational_model_grid_motion` | Owner | Allocates wind, temperature and related motion arrays |
| `md2asm_initialize_distributed_operational_model_spectral` | Owner, five field identifiers | Creates the final spectral-field records |
| `md2asm_load_distributed_operational_model_spectral_state` | Spectral path, owner | Loads the selected spherical-wave coefficients |
| `md2asm_initialize_distributed_operational_model_surface` | Surface path, owner | Creates and loads surface state |
| `md2asm_load_distributed_operational_model_upper_air_state` | Upper-air path, owner | Creates and loads atmospheric fields |
| `md2asm_release_distributed_operational_model_storage` | Owner | Releases its arrays, records and aliases |

The fifteen table entries point to distinct aligned eight-byte slots initially containing zero. They remain valid through release. Creation receives a fresh output slot containing zero. Refusal returns 2. Allocation and child failures keep their declared codes. Pure storage calls preserve their accepted machine-status rules, while file loading and surface conversion retain their natural status effects.

| Owner offset in bytes | Stored value |
| --- | --- |
| 8, 16, 24 | Borrowed Geometry, owned MODEL, owned FIELDS |
| 32, 40, 48, 56 | Work owner, upper-air loaded flag, configuration owner, borrowed partition |
| 64 through 183 | Fifteen alias destinations |
| 224, 232, 240 | Main motion, surface and spectral allocation flags |
| 256, 664, 672 | 408-byte trajectory record, effect word, 48-byte surface view |
| 720, 728 | Main motion-array addresses |
| 736, 760, 784 | 24-byte spectral dummy, five int32 identifiers, int32 loaded-orography flag |

The selected configuration has eight time steps, nine general fields with seven active physical fields, fourteen main motion fields and three surface motion fields. Two separate advance calls establish work stages 2 and 3. Upper-air loading requires stage 3. A final advance after loading establishes stage 4. These stages allocate storage and retain source-unwritten values. Numerical initial-state completion remains a later operation.

Each process owns 1,649,920 physical points in 97,055 blocks of seventeen point slots. Only two slots are active in the final block. General-field storage uses a final 1,096-byte record, seven int32 controls `17,137,97055,9,3,0,0`, and the live field namespace at MODEL offset 192. Its four array field counts are nine, three, zero and zero. The accepted allocation, initialisation and release comparisons cover 86,799,780,488 complete bytes across two source profiles. These checks cover the selected source allocation statements and complete zeroing and deallocation stages, rather than the complete enclosing setup routine.

The six-owner work component retains distinct create, advance and release calls. It reads local block counts from live Geometry and uses the accepted general dynamic and next-time constructors. Complete source comparisons cover 28,946,460,736 array bytes and 24,021,880 metadata bytes. The enclosing caller retains the source insertion points.

The main motion allocator receives its final 1,560-byte record, capacity, five input address/capacity pairs and six int32 controls. The live `LGRADSP=false` route omits the source-defined spectral-gradient pairs from the three time views and retains their undefined sentinel. Each main array has 25,316,602,640 bytes, while its surface companion has 39,598,440 bytes. Whole original storage, zeroing and release checks compare 50,712,402,160 array bytes exactly. The fourteen-field route is derived from live controls.

The spectral record has 2,992 bytes at FIELDS offset 22,736. Its identifiers are 138, 155, 130, 152 and 129. The loader receives the spectral path, that record, capacity 2,992 and the loaded-orography flag at owner offset 784. It requires the qualified same-resolution route with three volume fields, two surface fields and no extra spectral tracer. The owner retains its dummy and identifiers through release.

The surface file is `ICMGGacflINIT`. Its final records begin at FIELDS offset 4,512 and MODEL offset 4,155,544. All 34 surface arrays retain their source defaults, bounds and release order. Their two original allocation profiles compare 14,598,716,000 complete bytes. The [surface caller](../input/partitioned_surface_state_startup.md) retains the live local-to-global map and accepted physical conversion.

The separate upper-air file is `ICMGGacflINIUA`. Its general-field record begins at FIELDS offset 3,416. The input adapter sets the declared 120 padding bytes in each of 959 copied planes, then calls the accepted partitioned loader. Its four-word partition record contains local point count, map address, map capacity and block count. Live Geometry supplies the count at offset 7,376 and the map at offset 6,648. The required capacity is 167,688 times the block count. Slots zero through six receive fields with preserved padding, while slots seven and eight receive complete positive zero.

The [loaded-model composer](../input/loaded_operational_model_composition.md) owns this call order. Release frees work, motion, surface, spectral, general fields, configuration, FIELDS, MODEL and the container, then clears all aliases. Geometry and its partition remain borrowed. Release the model first, the complete Geometry sidecar second, and the startup owner that holds the vertical system last. Separate pressure and reference-temperature owners must also be released before MODEL.

The coordinated check passes on all four actual process maps, with one large MODEL alive at a time. All 32 native ABI/status observations pass, including four null-path refusals and four failures before the first large array allocation. Every tracked direct owner is released, every guard remains intact and all aliases clear. Borrowed Geometry, partition, sidecar, headers, constants and text remain unchanged. Complete child byte comparisons and independent physical checks are reused. This check does not run a time step or establish a complete forecast memory bound or runtime.

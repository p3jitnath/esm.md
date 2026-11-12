# Forecast Dynamic Storage

This component constructs three live buffers and the consumed time-update defaults from selected SUDYN, SUALDYNB, SUSAVTEND and SUSC2B source stages. A departure point is the earlier position of the air that reaches a forecast cell. A tendency is a rate of change, such as temperature change per second. The buffers retain the original Cartesian-coordinate and physics-tendency representations. This storage stage does not change their units or calculate new physical values.

## Source Order

The caller first admits the selected namelists and constructs Geometry, MODEL, the platform controls and the original interpolation controls. The defaults entry writes BETADT as exact FP64 one, LSETFSTAT false and NCURRENT_ITER zero, following SUDYN lines 629, 792 and 850. BETADT is a dimensionless coefficient in the time update. The platform must be NCONF one, LECMWF true, LR2D false and LR3D true. The existing bounded NAMDYN and NAMDYNA admission must already have succeeded, preserving those source defaults.

After SUINTDYNSL, the source SUDYN caller invokes SUALDYNB and allocates RSAVEDP when LSLDP_XYZ and LSLDP_SAVE are true. The next new stage follows SUSAVTEND, deriving NVTEND three and the MU, MV and MT tendency positions one, two and three. It allocates RSLWX and fills each level with the exact dimensionless weight one half, following the later SUDYN assignment. The caller separately constructs the original stable-trajectory controls and its pressure-derived level count. These entries preserve that state, including LSETTLSVF and NFLEVSF.

The source SUSC2B caller later allocates SAVTEND after the SLCSET stage when LSLPHY is true. Its field count comes from the live NVTEND producer, rather than a captured shape. The complete SAVTEND allocation receives positive zero. The selected NCONF is one, so the additional SAVTEND5 branch is outside this component. Release runs after all numerical consumers finish and before MODEL release.

## Assembly Interfaces

The Arm application binary interface defines argument positions and saved registers. Each successful entry returns zero in w0. Return one means allocation failure, with the incoming MODEL unchanged. Return two refuses an invalid or unsupported input before output mutation. MODEL has at least 4,275,088 mapped bytes and 8-byte alignment. Geometry has at least 17,096 mapped readable bytes and 8-byte alignment. Declared address ranges must not wrap around the address space. Borrowed inputs are disjoint from the output bytes that the stage writes.

| Entry | Arguments In Register Order | Result |
| --- | --- | --- |
| `md2asm_initialize_forecast_dynamics_defaults` | x0 MODEL, x1 capacity, x2 platform16 address | Write the three named SUDYN defaults. |
| `md2asm_allocate_saved_departure_points` | x0 Geometry, x1 capacity, x2 MODEL, x3 capacity | Allocate RSAVEDP using the live grid shape. |
| `md2asm_initialize_lagged_tendency_configuration` | x0 Geometry, x1 capacity, x2 MODEL, x3 capacity | Derive the three tendency positions, allocate RSLWX and fill its weights. |
| `md2asm_allocate_saved_physics_tendencies` | x0 Geometry, x1 capacity, x2 MODEL, x3 capacity | Allocate and clear SAVTEND from live NVTEND. |
| `md2asm_release_forecast_dynamic_storage` | x0 MODEL, x1 capacity | Free SAVTEND, RSLWX and RSAVEDP in reverse creation order. |

The platform input contains four readable 32-bit integers with 4-byte alignment, ordered as NCONF, LECMWF, LR2D and LR3D. The caller supplies the same live platform view used by interpolation setup. Geometry supplies NPROMA at byte 5144, NFLEVG at byte 5224 and NGPBLKS at byte 5160. These are the allocated rows per block, vertical levels and block count. Supported counts are 1 through 1024, 1 through 255 and 1 through 4096, respectively. The current forecast uses 24, 19 and 86. Multiplications fit in the declared 64-bit size calculations.

RSAVEDP and SAVTEND use shape (rows, levels, 3, blocks) with 8-byte FP64 elements in Fortran order, which stores the first index contiguously. Their descriptor offsets in MODEL are 1565736 and 1577528. RSLWX has one FP64 value per level, with its descriptor at 1577456. The descriptor gives the base address, element size, bounds and strides. The rank-four strides are 1, rows, rows times levels and rows times levels times 3. Every lower bound is one. RSAVEDP preserves its ordinary allocation bytes until its qualified numerical producer writes them. Production uses ordinary malloc and never supplies a captured allocation preimage.

NVTEND is stored at MODEL byte 1577520. MU_SAVTEND, MV_SAVTEND and MT_SAVTEND are at 1577800, 1577804 and 1577808. Every other MODEL byte and every borrowed Geometry byte remain unchanged. Each allocation must have a null incoming descriptor base. A repeated create call refuses an existing owner. A failed allocation publishes no descriptor or scalar change. Release clears only the three owned bases, retains descriptor metadata and is safe to repeat.

The entries preserve x18, used saved general registers, the required saved floating-point registers and 16-byte stack alignment. The allocation entries use 256-byte and 128-byte frames, while release uses 48 bytes. The defaults entry uses no frame. The routines execute no floating-point arithmetic, leaving FPCR and FPSR unchanged. The project requires FPCR zero. The only production external calls are libc malloc and free. No original OpenIFS callable, global, constructor or verification wrapper supplies a production value.

## Verification

A separate strict Fortran reference compiles the original selected assignments and allocation segments with genuine MODEL and Geometry declarations. It omits informational text outside the numerical boundary. These comparisons qualify the listed segments and do not claim complete SUDYN, SUALDYNB or SUSC2B bodies. Only newly allocated base addresses use a declared owner correspondence. All other MODEL bytes and every complete owner payload compare directly.

Three shapes pass all four stage boundaries, comparing 51,301,056 MODEL bytes and 3,771,984 accumulated owner bytes with zero differences. The shapes include the actual initial-entry dimensions, the minimum supported shape and an odd row count. Fifteen independent storage relations check the exact source-unwritten RSAVEDP preimage, all one-half weights, every positive-zero SAVTEND word, the tendency count and its positions. Native ABI masks are zero, and immediate FPCR, FPSR and errno match the reference. Fourteen critical refusals preserve inputs and output, each of the three allocation-failure positions leaves MODEL unchanged, and reverse release and repeated release pass. A complete original-file forecast and its canonical saved files remain the enclosing acceptance gate.

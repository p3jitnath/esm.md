# Runtime Cloud Optical Parameters

Cloud optical parameters describe how cloud droplets and ice absorb, scatter and redirect radiation. This entry extends the [qualified optical setup](cloud_optical_parameter_setup.md) to a live vertical-level count from 1 through 256. It keeps the fourteen allocated shortwave bands and six consumed shortwave bands. It implements SUCLOPN and the unchanged SU_CLOP550 child without an original OpenIFS callable or module owner.

The Arm application binary interface is `int md2asm_initialize_runtime_cloud_optical_parameters(controls12,records48)`, using x0 and x1. Controls contain three signed 32-bit words: NTSW 14, NSW 6 and the actual number of vertical levels. The table holds three address/capacity pairs for writable TERAD 2,040 bytes, TESWRT 10,744 bytes and the 48-byte cloud optical namespace at 550 nanometres. One nanometre is one billionth of a metre. All five complete views must be mapped, eight-byte aligned, separate and free from address overflow. Each capacity covers its complete record. Existing output bytes may be arbitrary under the qualified six-band child contract.

Return zero means success. Return two rejects unsupported counts, bounds, overlap, alignment or floating-point control before any output write. The floating-point control register must be zero for nearest-even rounding and gradual underflow. The caller owns all records, and this entry allocates or releases no storage.

SUCLOPN chooses its overlap coefficients from the actual level count. The exact source decimal values are shown below; the assembly stores their nearest-even FP64 representations. The nineteen-level case dispatches to the unchanged qualified specialization. Other supported counts use the same complete optical tables with the source-selected pair.

| Vertical levels | RAOVLP | RBOVLP |
| ---: | ---: | ---: |
| 19 | -2.250e-5 | 0.7865 |
| 31 | -7.316e-6 | 0.8186 |
| Other positive supported counts | -1.966e-5 | 0.8900 |

The complete source writes RAOVLP and RBOVLP at TERAD bytes 536 and 544, 6,088 TESWRT bytes, then all 48 diagnostic bytes. The other 6,680 bytes retain their incoming representations, including unrelated array descriptors. The unchanged table assignments retain Fortran column order and the separate source multiplications for unit conversion. There is no fused multiply-add, reassociation, reduced precision or output normalization.

The raw new child is `void md2asm_cloud_optical_parameter_fields_runtime_layers(TERAD2040,TESWRT10744,levels)`, with addresses in x0/x1 and the count in w2. It requires the checked parent's complete conditions. The parent then calls the accepted 550-nanometre field child. The common 116-byte kernel and 11,040-byte literal tables match the earlier qualified object exactly; the added 48-byte table contains only the three overlap pairs. Existing physical curve and unit-conversion checks remain applicable.

The parent uses a 224-byte frame aligned to 16 bytes, and both field children are leaves. Every entry preserves x18, required saved integer and vector registers, the floating-point control register and errno. Ordered FP64 multiplications naturally set inexact status while retaining incoming exception flags. No flag is forced or cleared to imitate the source. The component uses no external mathematical service.

Two focused original SUCLOPN calls verify the new 31-level and 137-level paths under distinct complete preimages and incoming status. All 25,568 compared source bytes and 25,664 complete native output bytes agree without pointer normalization. The unchanged 550-nanometre result is reused from its accepted source record. Levels zero and 257 return two with every output byte unchanged. Six saved 48-byte packets retain the ABI mask and immediate 40-byte status; native masks are zero, while the original GNU calls change only x18. Guards, read-only inputs, released mappings and file-descriptor closure pass.

These small checks use typed standalone records. They qualify this runtime-level optical child, not a genuine MODEL association, complete source-ordered SUPHEC setup, another resolution of the full model or an autonomous forecast. The enclosing caller must pass the actual Geometry level count and retain the same live radiation and diagnostic owners through their final readers.

# Radiation Latitude Interpolation

This child prepares latitude values and three coefficients for the original SUECRAD radiation interpolation. A latitude is an angle measured in radians. Each coefficient describes a cubic polynomial through four nearby latitude rows. The caller first supplies the complete grid and its extra boundary rows, called a halo.

## Interface And Storage

The creation entry `md2asm_create_runtime_radiation_latitude_interpolation(grid, capacity)` receives its two arguments in x0 and x1. The mapped grid record has 1,376 bytes and eight-byte alignment. Its live even row count N is from 2 through 8,192. The borrowed RLATIG input has N+4 FP64 values with bounds -1 through N+2. Its original GNU descriptor is contiguous, with eight-byte elements, unit stride and offset one. Values are finite and strictly decrease. All complete buffers are mapped, nonwrapping, disjoint and remain alive through release.

| Grid field | Byte offset | Meaning |
| --- | ---: | --- |
| NDGLG | 52 | Ordinary latitude-row count N |
| NDGSAH, NDGENH | 44, 48 | First and last local halo rows |
| NFRSTLOFF | 68 | Local-to-global row offset, from zero through N-1 |
| RLATIG | 1096 | Borrowed complete input descriptor |
| RLATI | 1160 | New local-latitude descriptor |
| RIPI | 1288 | New three-column coefficient descriptor |

Adding NFRSTLOFF to the nonempty local interval must give global bounds inside -1 through N+2. Both output bases start null. RLATI owns one FP64 value per local row. RIPI owns three FP64 columns with the same row bounds. Its column stride is the complete local row count. The child acquires both owners before publishing either descriptor. A failed second allocation releases the first, leaving the public record unchanged.

## Ordered Calculation

Let a, b, c and d be four consecutive input latitudes. For global rows zero through N, the three stored coefficients are

```math
c_1 = -1/((a-b)(b-c)(b-d)),\qquad
c_2 = 1/((a-c)(b-c)(c-d)),\qquad
c_3 = -1/((a-d)(b-d)(c-d)).
```

Each coefficient has units radians to power minus three. Each difference, first product, second product and division keeps its original FP64 rounding point. RLATI copies each corresponding input word. Coefficient cells outside global rows zero through N retain their source-unwritten allocation bytes. No fused multiply-add or reassociation is used.

The 800-row route dispatches to the unchanged `md2asm_create_operational_radiation_latitude_interpolation` provider. Other admitted sizes use the runtime bounds and strides. The paired entry `md2asm_release_runtime_radiation_latitude_interpolation(grid, capacity)` validates complete owner bounds and separation before freeing RIPI then RLATI. It clears only their base words. Repeated empty release succeeds. The caller keeps the descriptors unchanged until release.

Return zero means success, one means allocation failure after cleanup and two means unsupported input before mutation. FPCR is zero for creation. Both entries preserve x18 and all required Arm saved registers. Creation uses a 112-byte aligned frame and release uses 96 bytes. Release preserves incoming FPCR, FPSR and errno. Public malloc, free and the C errno address service are the only external services used by the numerical bodies. Original OpenIFS routines and globals supply no production value.

## Evidence And Limits

Six 800-row profiles match 101,120 complete data bytes and 288 raw-status bytes. Two 32-row profiles match 7,648 complete data bytes and 96 raw-status bytes against the same unchanged original source binary. Independent high-precision coefficient identities, signs, complete copies, untouched cells, guards, atomic refusals, allocation rollback and complete release pass. Native ABI masks are zero. The original source retains its recorded first-call x18 use. All normal raw states are naturally FPCR zero, FPSR 24 and errno 777.

The original 800-row provider and its accepted banks remain unchanged. The new 32-row check establishes a second runtime shape. The live public-transform producer, complete radiation setup, RADDRV and full forecast require their separate parent checks. This child result establishes no forecast runtime or speedup.

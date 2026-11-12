# Runtime Coupled-Field Accumulators

CNT4 calls SUCPL0 when its positive coupling frequency is no greater than the forecast stop index. The [assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/setup/runtime_coupled_field_accumulators.S) creates the same sixteen surface-exchange arrays and sets fourteen fields to FP64 positive zero. Values retain their source units. FCCHLL and FCCHLN are allocated but remain unwritten until a later genuine producer. Their payloads must remain unread until then. This setup remains active under the current forecast controls even though external ocean coupling is inactive.

## Interface And Bounds

The initialization entry md2asm_initialize_runtime_coupled_field_accumulators receives Geometry, TDPHY, a fresh owner and an unsigned allocation budget in x0 through x3. Geometry is the grid record, TDPHY contains physical dimensions, and an owner is the record that retains its allocated storage.

| Input | Complete Size | Alignment |
| --- | ---: | ---: |
| Geometry | 20,400 bytes | 8 bytes |
| TDPHY | 88 bytes | 4 bytes |
| Owner | 1,536 bytes | 8 bytes |

All records must be mapped, separate and nonwrapping. The owner allocation pointer at byte 0 and ready word at byte 16 must initially be zero. FPCR must be zero. The 2,048-byte frame preserves x18, x19 through x30 and the Arm application binary interface, which defines argument placement and saved registers.

Let $`Q`$ be the local point count, $`X`$ the maximum longitude count and $`Y`$ the global latitude count. Read them from Geometry bytes 7376, 4936 and 4872. TDPHY byte 76 contains NTSSG, the number of surface-temperature diagnostic subdivisions. Let $`T=\mathrm{NTSSG}+1`$. Supported source bounds are one through 2,147,483,647 for $`Q`$, one through 32,768 for $`X`$ and $`Y`$, and zero through 32 for NTSSG. The required payload size $`B`$, in bytes, is

```math
B = 8(10Q+4QT+2XY).
```

The positive budget must cover this complete allocation and be no greater than 64 GiB. The declared bounds prevent integer products from wrapping.

## Source Fields And Ownership

The owner stores the allocation address at 0, its byte count at 8, ready at 16, $`Q`$ at 24, $`T`$ at 32, $`X`$ at 40 and $`Y`$ at 48. Sixteen GNU array-descriptor slots begin at 128 with 88-byte spacing. A descriptor gives an array's address, type, bounds and element spacing. All lower bounds are one and each numerical element uses eight bytes.

| Array Group | Shape | Source Initialization |
| --- | --- | --- |
| FCSTSU, FCSTSV, FCRUIS, FCHUML, FCHUMN, FCTSUR2, FCTSTS, FCTSFL, FCWIMO, FCSUBL | $`Q`$ | Positive zero |
| FCCHAS, FCRSOS, FCHUMS, FCCHSS | $`Q 	imes T`$ | Positive zero |
| FCCHLL, FCCHLN | $`X 	imes Y`$ | Unwritten |

Descriptor order follows the original allocation order. Zero fields in the original assignment order, with FCCHAS, FCRSOS, FCHUMS and FCCHSS first, then the ten rank-one fields. Integer zero bytes produce exact FP64 positive zero without changing floating status. Keep payload and metadata private until all construction succeeds, then publish the complete owner. These are owned assembly records, without original module globals.

Return zero on success, one for allocation failure or two for unsupported input. Returned failures preserve the complete caller owner. Natural FPSR and errno remain visible. The only imported services are public libc allocation and memory functions. No original OpenIFS procedure, constructor or method table supplies production work.

Retain storage until every coupling and output reader finishes. The release entry md2asm_release_runtime_coupled_field_accumulators takes the owner and its capacity. It frees the single allocation and clears its address, byte count, ready word and descriptor data addresses. Other metadata stays unchanged and unready. Repeated release succeeds. The standalone main must release this owner on normal and failed exit.

## Evidence And Limits

Two unchanged original SUCPL0 calls agree with the native setup in all 32,140,608 defined numerical bytes and 32 typed pointer relations. Cases use the actual operational dimensions and an odd tiled shape. Complete descriptor metadata, independent positive zeros, input guards, ABI, natural status, release and repeated release pass. Short-budget and invalid-surface-count refusals preserve the entire caller owner. Source-unwritten payloads are not read or compared. The finite process has exited. This accepts the setup component, without establishing a complete forecast or runtime improvement.

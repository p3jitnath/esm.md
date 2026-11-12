# OpenIFS GPU Call Context

Revision 1 defines storage and diagnostic reporting for the direct PTX forecast. It changes no physical equation or ordered calculation. The application binary interface (ABI) defines how a routine receives arguments. Each CUDA launch passes two unsigned 64-bit addresses, the original argument vector and this context. The vector holds the original interface values in their original order, including pointer arguments and hidden scalar lengths. Host assembly keeps the vector and all records live until CUDA synchronization completes.

The context has 64 bytes with eight-byte alignment. A separate record may use stricter alignment. CPU and GPU code use the same little-endian bytes. The host owns every allocation. Numerical operands remain in their complete original owners, with their original descriptors and pointer relationships.

| Byte Offset | Type | Meaning |
| ---: | --- | --- |
| 0 | u32 | Validation error, initially zero and changed only on refusal |
| 4 | u32 | Context revision, fixed at one |
| 8 | u32 | Newly raised Arm-equivalent floating-point flags, initially zero |
| 12 | u32 | Read-only control bits, with bit zero recording an original parallel region |
| 16 | u64 | Last mathematical error event, initially zero |
| 24 | u64 | Read-only call identifier for trace reports |
| 32 | u64 | Private scratch address, or zero when no scratch is needed |
| 40 | u64 | Scratch allocation size in bytes |
| 48 | u64 | Address of a routine-specific record, or zero |
| 56 | u64 | Complete routine-specific record size in bytes |

The floating-point status register records numerical events such as rounding or overflow. PTX has no Arm floating-point status register. Carry newly raised flags as explicit integers and combine independent reports with an atomic bitwise OR at byte eight. A NaN is a value that represents an undefined numerical result. Freeze the source processor’s NaN selection, signed zero, gradual underflow, rounding and before-rounding tininess rule. Do not infer flag equality from equal rounded values. A routine remains unqualified for its complete return interface until these diagnostics are proved.

An error event records an actual write of a mathematical error code, including a repeated write of the incoming code. Zero means that no error was written. Pack a nonzero event as the original operation's unsigned position number shifted left by eight bits, plus its one-byte error code. These position numbers are unique within the launch, preserve original loop and child-call order, and fit 56 bits. The largest packed event selects the final source-ordered error with one atomic maximum. A numerical primitive that does not set errno returns an event of zero. The C error slot, called `errno`, stores a mathematical error code. The host preserves its incoming errno when no event was written. Routine-specific contracts define these numbers before parallel emission.

The [assembly CUDA runtime](cuda_runtime.md) observes the context only after CUDA synchronization. Preserve read-only context fields and all bytes outside the three declared writable fields. Unsupported inputs must be refused before any numerical output write. The host converts a validation refusal to the original routine's declared failure route. A numerical calculation cannot fall back to an OpenIFS CPU routine.

The first qualified storage check on the owned GH200 reads two nested pointers from ordinary host allocations and copies 64 raw bytes. All input pages are read-only and every surrounding byte is preserved. The device reports shared host page tables and coherent pageable-memory access. This permits the original assembly-owned record graph to stay at its owned addresses, with no driver-supplied numerical stage. These target-specific requirements must be checked at process startup rather than assumed on other GPUs.

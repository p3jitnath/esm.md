# Runtime Radiation Gaussian Fields

This SUECRAD component turns each radiation-grid latitude sine into three fields. RMU holds the sine, RSQM2 holds the nonnegative cosine magnitude, and RLATIG holds the latitude angle in radians. It then extends two rows across each pole for later interpolation. The sine and cosine fields have no physical units.

The direct [assembly](../../../../../src/openifs/radiation/runtime_radiation_gaussian_fields.S) reads the live even latitude-row count N, from 2 through 8192. It uses the physical record's RPI value for pi. For each ordinary row, the ordered calculations are

```math
r=\mu,\qquad c=\sqrt{1-\mu\mu},\qquad \phi=\arcsin(\mu).
```

The multiplication, subtraction and square root each round separately in FP64. The public asin mathematical function supplies the inverse sine. Each north extension copies the sine and cosine from its reflected row and uses RPI minus its angle. Each south extension uses minus RPI minus its reflected angle. The original two north rows are written before the two south rows.

Creation uses x0 for the mapped 1376-byte radiation record and x1 for its capacity, x2 for the writable ZMU buffer and x3 for its byte capacity, x4 for the live 520-byte physical record and x5 for its capacity, and x6 for NRADINT. The supported NRADINT values 2 and 3 select this same source calculation. The caller provides disjoint mapped storage. N is at radiation-record offset 52, with surrounding-row fields NDGSAG=-1, NDGENG=N+2 and NDGSUR=2. Ordinary ZMU values must be finite, strictly decreasing and inside (-1,1). RPI is read at physical-record offset 0 and must lie in [3,4).

The entry allocates RMU, RSQM2 and RLATIG in source order. Their descriptors begin at offsets 968, 1032 and 1096. Each fresh base must be null. Each owner has N+4 FP64 words, bounds -1 through N+2, offset1 and stride1 in the declared GNU descriptor format. Creation completes all three allocations before publishing a descriptor or changing ZMU. Failure frees previous owners and leaves the public inputs unchanged. Return 0 means success, 1 means allocation failure, and 2 means unsupported input. Its 128-byte aligned frame preserves x18 and all required saved registers. FPCR, the floating-point control register, must be zero. Numerical flags and errno retain their natural values.

Release takes the radiation record and its capacity in x0,x1. It checks all three descriptor shapes, frees owners in reverse order, and clears their base words. Its 80-byte aligned frame preserves required registers. It preserves incoming numerical status and errno. ZMU, the physical record and the radiation record remain with their caller. Repeated empty release succeeds.

One unchanged original selected-source binary and one direct object agree on 32,384 complete data bytes and 96 raw-status bytes at 800 and 32 rows. The inputs contain actual public-transform Gaussian values. Independent 90-digit sine, cosine and polar checks cover 4,192 relations per route. All nominal register checks, 14 atomic input refusals, three partial-allocation cleanup paths, three release refusals and buffer guards pass. Both routes return natural FPCR 0, FPSR 24 and errno 777 for the declared incoming state. All new owners are released.

The physical-input fixture uses the frozen pi word 0x400921fb54442d18. The production parent must bind the live accepted physical-constant owner. A separate Gaussian-to-local-latitude composition also agrees on 58,528 data bytes and 96 raw-status bytes for full 800-row and shifted 32-row verification views. Its 5,710 independent relations per route cover the actual produced latitude values. The source Gaussian outputs are reused, without replay. Those views do not replace the original point-coordinate and halo-size stages between the components. The transform packet's 800-row numerical prefix completed before a later reference-only cleanup-check failure. That separate limit remains explicit. Complete SUECRAD, RADDRV and a full operational forecast remain unfinished.

# Complete Lagrangian Grid Update on the GPU

LACDYN advances the grid-point dynamical state by following air parcels and combining transport, diffusion and linear wave terms. Its complete six-child device path preserves the original operation order and positive-one mixing stage.

The application binary interface (ABI) retains all 36 original addresses. The common context has 64 bytes, the specific record has 32,768 bytes and private scratch has 128,928 bytes. Typed records describe complete buffers and their alignment. The storage-only Arm caller preserves x18, saved registers, floating-point controls and the error indicator. One serial GPU thread owns each complete call.

Sixteen selected-CPU and sixteen GPU calls match 155,206,208 complete output bytes and 136,219,520 readonly bytes. Independent checks cover 7,296 mixing relations. Seventy-two critical refusals and two complete device-memory graphs pass, including a short Coriolis buffer. The actual 2,008-byte CPU provider and both independent source reviews pass.

This is a component result for the declared 2,048-point, nineteen-layer forecast shape. Parent and child routine counts overlap. Full autonomous GPU forecast acceptance remains a separate gate.

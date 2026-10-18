# Complete Lagrangian Grid Update on the GPU

LACDYN advances the grid-point dynamical state by following air parcels and combining transport, diffusion and linear wave terms. Its complete six-child device path preserves the original operation order and positive-one mixing stage.

The application binary interface (ABI) retains all 36 original addresses. The common context has 64 bytes, the specific record has 32,768 bytes and private scratch has 128,928 bytes. Typed records describe complete buffers and their alignment. The storage-only Arm caller preserves x18, saved registers, floating-point controls and the error indicator. One serial GPU thread owns each complete call.

Sixteen selected-CPU and sixteen GPU calls match 155,206,208 complete output bytes and 136,219,520 readonly bytes. Independent checks cover 1,824 distinct mixing relations and 7,296 evaluations. Seventy applicable critical refusals and two complete device-memory graphs pass, including a short Coriolis buffer. The actual 2,008-byte CPU provider and both independent source reviews pass.

This is a component result for the declared 2,048-point, nineteen-layer forecast shape. Parent and child routine counts overlap. Full autonomous GPU forecast acceptance remains a separate gate.

Original history arguments seven and eight are captured but not read by the selected parent or any of its six children, so their consumed spans are zero. Two previous capacity-rejection assumptions are superseded. A genuine last-block witness with two readonly 64-byte buffers beside protected pages passes fresh and sticky status, matching 19,400,776 complete output bytes and all eight source counters. The numerical instructions are unchanged.

# Convective Heat and Moisture Tendencies on the GPU

CUDTDQN converts convective flux changes into temperature and moisture tendencies, which are their rates of change.

The complete ABI retains all 44 original addresses. One serial GPU thread owns the original column update, using a 64-byte common context and a 80-byte specific record. Typed complete-owner records determine scratch size and prevent writable overlap. The storage-only Arm caller preserves saved registers, x18, floating-point state and the error indicator.

80 protected GPU calls match 684,144 complete output bytes. Independent checks cover 10,332 distinct physical relations. 57 critical controls and 3 complete device-memory graphs pass. Immediate selected-CPU status, original argument order, actual mathematical counters, native instructions and both complete source reviews pass.

The public serial alias is the selected assembly interface. CPU-parallel caller aliases remain deferred until complete parent composition. This accepted component adds one original routine and does not establish a complete GPU forecast.

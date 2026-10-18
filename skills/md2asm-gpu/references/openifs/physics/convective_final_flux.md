# Final Convective Fluxes on the GPU

CUFLXN combines upward and downward cloud transport, precipitation and evaporation to form the final convective fluxes.

The complete ABI retains all 43 original addresses. One serial GPU thread owns the original column update, using a 64-byte common context and a 264-byte specific record. Typed complete-owner records determine scratch size and prevent writable overlap. The storage-only Arm caller preserves saved registers, x18, floating-point state and the error indicator.

48 protected GPU calls match 538,112 complete output bytes. Independent checks cover 13,956 distinct physical relations. 71 critical controls and 3 complete device-memory graphs pass. Immediate selected-CPU status, original argument order, actual mathematical counters, native instructions and both complete source reviews pass.

The public serial alias is the selected assembly interface. CPU-parallel caller aliases remain deferred until complete parent composition. This accepted component adds one original routine and does not establish a complete GPU forecast.

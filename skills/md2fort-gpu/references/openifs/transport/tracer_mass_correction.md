# Complete Tracer Mass Correction on the GPU

A tracer is a substance carried by the air. TRMFIXERS restores the required tracer mass after parcel transport. It calls the complete accepted QMFIXER calculation on the device and preserves the original field order.

The ABI retains all sixteen original addresses. A 64-byte common context names a 1,536-byte specific record and 2,574,192 bytes of private scratch. Complete buffer bounds, descriptor metadata and disjoint writable owners are checked before output. One serial thread performs the complete call. The Arm caller owns storage and preserves its saved registers, x18, floating-point state and error indicator.

Eight selected-CPU and eight GPU calls match 15,191,040 complete output bytes. Thirty-six critical refusals and a device-memory graph with 37 complete owners pass. The actual 384-byte CPU provider, native instruction inspection and independent numerical and boundary reviews pass.

This result applies to the declared 2,048-point, nineteen-layer grid and does not add a separate QMFIXER count or a full GPU forecast result.

The current public host also provides the accepted [parallel tracer mass correction](parallel_tracer_mass_correction.md), which uses private staged work and retains this serial GPU calculation for fallback. Its larger scratch bound, launch sequence and component checks are defined in that supplement.

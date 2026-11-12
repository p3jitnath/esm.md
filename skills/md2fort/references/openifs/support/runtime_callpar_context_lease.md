# Runtime CALLPAR Context Lease

A context is a short record of addresses used by a calculation. A lease requires each named owner to remain live until the last reader returns. This assembly publishes the 80-byte CALLPAR context and its contained 16-byte profiling policy in one 96-byte caller-owned record. It does not allocate numerical storage or call CALLPAR.

The Arm application binary interface is `int md2asm_initialize_runtime_callpar_context_lease(lease96,capacity,configuration67616,MODEL4275088,partition4096,current_step4)`, using x0 through x5. Numbers give complete mapped byte extents. The output, configuration, MODEL and partition need eight-byte alignment. Current step is one signed 32-bit integer with four-byte alignment and a value from zero through eight. Capacity covers all 96 output bytes. Every range must be nonnull and must end without address overflow. Configuration names the complete 20,400-byte Geometry owner at byte 16 and the complete 529,288-byte FIELDS owner at byte 8.

The output must be separate from those six input records and from every canonical owner in the table below, including the 32-byte surface runtime owner. These fourteen output-separation checks retain valid read-only input aliases. The accepted children retain their own association and overlap rules: the coupling child requires its eight complete ranges to be separate, and the step publisher requires the step input separate from configuration and clock. The policy at output bytes 80–95 is deliberately part of the same allocation.

| Output byte | Content | Referenced storage |
| ---: | --- | --- |
| 0 | Physical-constant address | canonical physical owner, 520 bytes |
| 8 | Current-step address | canonical clock, 360 bytes, plus 36 |
| 16 | Profiling-policy address | this lease plus 80, 16 bytes |
| 24 | LUSEKF_REF address | canonical physics runtime owner, 608 bytes, plus 24 |
| 32 | CPL_NEMO_LIM address | canonical forecast scalar owner, 112 bytes |
| 40, 48, 56 | Reserved zero words | none |
| 64 | Dynamical-parameter address | canonical dynamics owner, 320 bytes |
| 72 | Thermal-parameter address | canonical thermal owner, 1,920 bytes |
| 80 | False profiling-control address | canonical read-only four-byte weather flag |
| 88 | Reserved zero word | none |

The physical, configured dynamical, thermal and clock producers must already have written the exact assembly-owned namespaces consumed by the weather graph. In particular, the dynamical producer reads the actual nonempty NAMDYNCORE group, and the ECMWF physics prefix retains later SUCUMF thermal writes. Do not reinitialize those owners after their later source updates. Produced values and argument addresses are verified at the producer boundary; this wrapper does not repeat their calculations or infer completion from zero storage.

After checking the output and false profiling policy, the entry calls the [inactive coupling binding](../setup/operational_inactive_coupling_context_bindings.md), the [current-step publisher](../setup/operational_step_clock_publication.md), then the [canonical runtime initializer](../setup/canonical_physics_runtime_startup.md). The first returns the two live control addresses. The second publishes the step in configuration and canonical clock. The third writes the declared 32-byte runtime controls while preserving padding bytes 12–15. Only after all three children succeed are all twelve output words written. Numerical parameter owners remain unchanged.

The weather profiling flag is the unique `md2asm_owned_shared_false_hook_policy` owner from [shared hook storage](shared_hook_snow_providers.md). Its literal four bytes are zero. The context and all 36 selected weather references use that same read-only address. FIAT's public profiling flag and profiling function remain separate library services. This entry preserves them. The supported weather policy keeps profiling false and does not enable dynamic weather profiling.

Return zero means complete publication. Return two means refusal, and all 96 incoming output bytes remain unchanged. The wrapper's own bounds, output overlap, floating-point control and false-policy checks precede every child. If a later child refuses, earlier successful child assignments remain visible. There is no rollback of those earlier effects, and callers must not read an unpublished lease.

The wrapper uses an 80-byte frame aligned to 16 bytes and reaches 240 bytes with the coupling child. It preserves x18, required saved integer and vector registers, the floating-point control register, floating-point status flags and errno. The control register must be zero for nearest-even rounding and gradual underflow. This integer wrapper performs no floating-point arithmetic, allocation, original OpenIFS call or method-table dispatch. Its only callable dependencies are the three direct assembly children.

Sixteen small captured-metadata cases verify four rank input sets, both incoming status states, complete output words, source-defined updates, unchanged bytes, a capacity refusal and a later step refusal. The captured inputs are verification fixtures and do not claim a producer replay. A separate genuine four-rank owner gate publishes one step-zero context per rank between completed setup and registry-first release. The independent saved-output review of that gate is retained with its enclosing owner contract. All declared context bytes agree, and every observed native ABI mask is zero.

Keep the lease, current-step input, actual outer records and canonical namespaces live through the final consumer. This component needs no release entry because it owns no allocation. The caller retires its 96-byte record after the last reader and releases upstream owners in their accepted order. These checks qualify context publication; they do not establish complete CALLPAR argument construction, a weather step or an autonomous forecast.

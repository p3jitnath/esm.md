# Runtime Forecast Event Tables

CNT4 selects output and diagnostic times before its forecast loop. The [assembly owner](../../../../../src/openifs/dynamics/runtime_forecast_event_tables.S) constructs these tables from live controls through the accepted [periodic selector](../support/runtime_periodic_output_schedule.md). It performs no weather calculation.

## Interface And Storage

The initialization entry md2asm_initialize_runtime_forecast_events takes configuration67616, Model4275088, loop552, N1switches60, optional Fullpos503824, output1024, an allocation budget in bytes and the output capacity in x0 through x7. All complete records are mapped, eight-byte aligned, nonwrapping and separate. The output allocation pointer at byte0 and ready word at16 must initially be zero. The configuration must associate this Model. The source start index is zero and the stop index is at most576. The supported spherical NCONF1 route has inactive surface and DDH diagnostics, whose event arrays are still constructed with the original false active argument. DDH means detailed model diagnostics.

The output owns one allocation at0 with its byte count at8. Ready16 becomes one on success, start20 is zero, stop24 is live NSTOP and Fullpos-present28 records optional presence. Twelve complete GNU integer array descriptors start at64, each64bytes long. Their effective index frequencies start at832, each four bytes long. Each descriptor gives its array address, type, bounds and element spacing. All other owner bytes are zero.

| Array Order | Purpose |
| --- | --- |
| IPOSTS, IHISTS, ISFXHISTS | Output and history schedules |
| IGDITS, ISDITS | Grid and spectral diagnostics |
| IDHFGTS, IDHFZTS, IDHFDTS, IDHPTS | Detailed diagnostic schedules |
| IRESTS, IMASSCONS, IFPOSTS | Restart, mass checks and Fullpos output |

Each array runs from zero through the source stop index divided by its index frequency, with integer division. Grid and spectral diagnostics use max(1,frequency) for storage while retaining the original signed selector argument. Other used frequencies are positive and at most one million. IFPOSTS is absent when Fullpos is absent or its frequency is zero. The exact allocation is four times the sum of the nonempty extents. A positive budget of at most64GiB must cover it.

## Source Order And Lifetime

Configuration lists use their typed CT0 offsets plus584, with bounds zero through960. The restart list is loop248 with bounds zero through40 and frequency loop36. Fullpos supplies its complete NFPOSTS and NFPOSTSMIN descriptors at376and440 and NFRFPOS at372. These offsets use the accepted Fullpos constructor. TRIP is Model1359328, with its start, stop and FP64 time step at relative bytes0,4and200. The time step is in seconds. N1 values come from the source NAMCT1 producer.

Construct tables in their original source call order. Preserve requested indices, hours, minutes and the selector's FP64 rounding. The restart table starts zero. The mass-check condition is true exactly when its frequency is at most the stop index. Every table remains private until all children succeed, then one complete owner is published. The caller must agree status among processes before any table is read.

Return zero for success, one for allocation failure or two for unsupported input. Returned failures free acquired storage and preserve the complete caller output. The2048-byte frame preserves x18, x19throughx30 and the Arm application binary interface. FPCR must be zero and remains unchanged. Natural floating status and errno remain visible. The only external service is libc. No original OpenIFS routine or data owner participates.

After every reader finishes, call md2asm_release_runtime_forecast_events with the owner and its capacity. Release frees its allocation and clears the address, byte count, ready word and descriptor data addresses. Repeated release succeeds. Other metadata remains unchanged and unready.

## Evidence And Limits

Three joined profiles compare35unchanged original MONIO_T calls with three native owner constructions over19,352complete event bytes, with zero differences. They cover the actual192-step controls, changed576-step controls without Fullpos, and explicit output hours and minutes. Independent periodic selections, complete owner metadata, unchanged inputs, guards, ABI registers, raw FPCR/FPSR and natural errno pass. Release and repeated release pass. A short budget and a rejected last-child request leave the complete output unchanged. The finite process has exited. This accepts the event owner and its source selector wiring. It does not accept original CNT4, connected weather, operational output calculations or a complete saved forecast.

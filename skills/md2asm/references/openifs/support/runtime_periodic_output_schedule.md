# Runtime Periodic Output Schedule

MONIO_T selects the model steps at which fields are written or diagnosed. Each active schedule entry contains the source-selected integer, usually one. The [assembly](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/support/runtime_periodic_output_schedule.S) uses live forecast dimensions and has no original OpenIFS imports.

## Interface And Storage

The entry md2asm_runtime_periodic_output_schedule retains the nine original pointer arguments, with argument9 at the incoming stack address. Arguments3 and6 are GNU rank-one integer array descriptors. Argument7 is an optional minute-list descriptor, and arguments8 and9 are optional logical values. The descriptor data address denotes the first supplied element. The child maps the output lower bound to argument1 and the list lower bounds to zero, without shifting those supplied addresses.

TRIP bytes0 and4 hold the start and stop indices, and byte200 holds the FP64 time step in seconds. Start, stop, output extent, request count and positive strides are each at most one million. Each array element is four bytes. All strided elements must fit their mapped allocations. Input lists and output are separate. An empty output has a positive child lower bound. The320-byte frame preserves x18 and x19 through x30 and uses only caller-saved floating registers. The entry allocates no memory.

## Source Decisions

A positive list count selects explicit schedule indices. A negative count selects times in hours with optional minutes. Zero selects periodic steps when the optional condition is true. The optional active logical selects the supplied integer or zero. Frequency retains its signed source value. The source uses max(frequency,1) when dividing in the periodic and time-list paths. Positive-list products must fit signed32-bit integers. The floating time-list route admits nonnegative frequency and requested hours, with finite time steps.

Preserve the original time calculation order. Convert minutes to FP64 and divide by60 when present. Negate the hour integer, convert it to FP64 and add the minute contribution. Multiply by3600, multiply by frequency and divide by the absolute time step, using the source minimum of the smallest normal FP64 number. Apply the upper limit2147483647, then round to the nearest integer with half values away from zero. This is the source NINT conversion rule. Arithmetic otherwise requires FPCR zero, with separate multiplication and addition.

All admitted bounds and controls are checked before output changes. Return zero for success or two for unsupported input. Profiling is inactive. The caller performs any required agreement among processes.

## Evidence And Limits

Eighteen original/native pairs agree in all5588complete output bytes and all1226independently selected schedule entries. Cases cover192and576steps, explicit indices, requested hours and minutes, half-step conversion, negative and tiny time steps, signed frequencies, optional logicals, strided views and an empty output. Two invalid capacities or bounds are refused before any output change. Guard regions, complete input owners, ABI registers, FPCR, source FPSR and errno agree. The finite check processes are closed. These checks accept the schedule component. The connected weather loop and full saved forecast files remain unverified.

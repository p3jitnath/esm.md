# Parallel Forecast Grid Calculations

This component evaluates the same [forecast grid calculations](../../../../md2fort/references/openifs/dynamics/forecast_grid_calculations.md) with one block of 32 GPU threads. Independent horizontal columns run together. Each hydrostatic column keeps its original sequence from one vertical level to the next, and all children retain their original stage order and FP64 rounding points.

## Interface And Storage

The [Arm host](../../../../../src/openifs/dynamics/gpu/forecast_grid_parallel/forecast_grid_parallel_host.S) retains all 75 original address arguments and their application binary interface, or ABI. Saved registers, floating-point controls and the error indicator follow the original interface. The [parallel parent](../../../../../src/openifs/dynamics/gpu/forecast_grid_parallel/forecast_grid_parallel_parent.ptx) retains the mapped 64-byte common context and complete original buffer capacities. Required real arrays have eight-byte alignment and column-first storage.

A selector reads only address and layout metadata before choosing a route. Independent layouts use the parallel body. Supported layouts with overlapping columns use the exact original serial GPU body. This preserves the original numerical domain. Each thread uses private work records, and all required child barriers include inactive threads. The full 64-bit event value remains unchanged. Five caller counters, ten hydrostatic stage counters and the actual exponential and arithmetic helper counts are published once, with unsigned 64-bit wrap.

## Exact Agreement

Eight complete-parent cases match 58,203,952 buffer bytes with zero differences. Two genuine forecast inputs each cover 6,838,904 bytes. Ten early-refusal cases check 103,184 private bytes and 6,838,904 model bytes per case. A valid device-memory case matches its saved 6,838,904-byte result. Status, full event values and actual counters agree. Existing independent physical checks are reused.

The alias-selector control checks metadata dispatch. It does not add numerical evidence for an overlapping-column case, whose original serial body remains unchanged. These are component results. The published sources rebuild to the accepted objects exactly. Complete GPU forecast agreement and comparative performance remain separate checks, with detailed records retained locally.

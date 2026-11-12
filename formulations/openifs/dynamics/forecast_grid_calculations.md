# Forecast Grid Calculations

Revision 1.0 uses equation FGC-P01. A weather forecast stores pressure, temperature, wind and water content on a horizontal grid with atmospheric layers. Before each time update, prepare consistent pressure boundaries, wind history, height, energy, tendencies and transport work fields from the supplied state.

Let m be the positive map scale, which has no unit. Let g_l and g_m be the supplied surface-height gradients in the two model directions. The grid uses the scaled gradients G_l and G_m in the same gradient units. Equation FGC-P01 gives

```math
G_l=m g_l,\qquad G_m=m g_m.
```

Use the existing [surface-pressure physics](surface_pressure.md), [hydrostatic column physics](hydrostatic_grid_calculations.md) and [transport work-buffer physics](work_buffer_initialisation.md). The initial wind history is the initial wind. The current coarse case has 19 layers, positive pressure and temperature, a fixed surface-height boundary, and water mass fractions whose sum does not exceed one. All grid, time-step and initial-state values come from the supplied forecast. The md2fort contract chooses the complete numerical storage and ordered update.

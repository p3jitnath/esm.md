# Hydrostatic Grid Calculations

Revision 1.0 uses equations HYD-P01 and HYD-P02. A hydrostatic atmosphere balances the upward pressure force with gravity. This calculation combines supplied pressure, temperature and wind fields at one forecast time. It does not choose a new grid or time step.

Let u and v be horizontal wind components in metres per second. Let T be temperature in kelvin, R the gas constant in joules per kilogram per kelvin, c_p the heat capacity in the same units, p pressure in pascals, and omega the material pressure change in pascals per second. The word material means that the change follows moving air. K is specific kinetic energy in square metres per second squared. Equation HYD-P01 gives

```math
K=\tfrac12(u^2+v^2),\qquad \frac{DT}{Dt}=\frac{R}{c_p}T\frac{\omega}{p}.
```

Let S_L and S_M be the supplied filtered pressure forces per unit mass in the model's two horizontal directions. Their units are metres per second squared after the supplied coordinate scaling. Let f be the Coriolis parameter in inverse seconds. In the selected case there is no wind drag. Equation HYD-P02 gives

```math
\frac{Du}{Dt}=-S_L+fv,\qquad \frac{Dv}{Dt}=-S_M-fu.
```

The current input has 19 atmospheric layers, positive temperature and full-level pressure, positive layer pressure depth and finite wind and pressure gradients. The existing vertical model configuration stays fixed. The surface height is fixed by the supplied orography. Complete weather inputs, initial states and boundaries remain those of the parent forecast formulation. The md2fort contract records the selected stages, ordered arithmetic and buffers.

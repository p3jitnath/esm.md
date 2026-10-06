# OpenIFS formulations

OpenIFS is a global weather model. It combines atmospheric motion with radiation, clouds, rainfall and exchanges with the surface. The local source used here is OpenIFS 48.1.1.

The first note describes [surface-state change](surface_state.md), with its numerical contract in [md2asm](../../skills/md2asm/references/openifs/cpspe.md). It covers the complete CPSPE update. The remaining forecast physics and numerical stages still need source-grounded notes, contracts, direct assembly and independent checks.

| Forecast part | Local source group | Current coverage |
| --- | --- | --- |
| Atmospheric motion and transport | arpifs/adiab, arpifs/interpol, arpifs/transform | Pending |
| Clouds, convection and turbulent mixing | arpifs/phys_ec | Pending |
| Radiation | arpifs/phys_radi | Pending |
| Soil, snow, lakes and surface exchange | surf and arpifs/phys_ec | CPSPE state update only |
| Atmospheric composition | arpifs/chem | Pending |
| Ocean waves and coupling | wam and coupling routines | Pending |

A short formulation supplies the physical model. The md2asm references supply the numerical choices and exact implementation rules. Whole-model verification must compare raw forecast states and complete output files, rather than only printed norms.

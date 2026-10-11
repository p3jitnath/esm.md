# Nitrogen decline and biomass partition

Revision 1 describes the complete NITRO_DECLINE helper used by vegetation evolution. The model divides plant material between active leaves, above-ground structure and deep structure. Nitrogen decline means that active leaf material occupies a smaller share as total plant biomass grows.

## Symbols

| Symbol | Meaning and unit |
| --- | --- |
| $`A,S,D`$ | Active, above-ground structural and deep structural biomass, kilograms per square metre |
| $`B`$ | Active plus above-ground structural biomass, kilograms per square metre |
| $`a`$ | Nitrogen decline exponent, strictly between 0 and 1 |
| $`c`$ | Supplied allometry coefficient, with units $`(\mathrm{kg\,m^{-2}})^a`$ |
| $`\tau`$ | Effective mortality time expressed in days |
| $`A_{\min}`$ | Supplied minimum active biomass, kilograms per square metre |
| $`X`$ | Active biomass loss in the source update, kilograms per square metre |

## Equations

**P01. Growing vegetation partitions biomass.**

```math
A=cB^{1-a},\qquad S=B-A.
```

Allometry is a relation between the sizes of different plant parts. This relation gives the active and structural shares in the growing branch. The complete source update also handles declining vegetation, transfers to deep structure and its emergency return of active loss.

**P02. The source map limits active loss.**

```math
X=\max\left(0,\min\left[A-A_{\min},
A\left(1-e^{-1/\tau}\right)\right]\right).
```

The mortality time depends on vegetation type, assimilation, leaf area and latitude. The floor prevents the ordinary active-loss branch from reducing biomass below its minimum. Later storage and emergency branches follow the original model.

## Parameters, initial state, and boundaries

The vegetation tables supply the leaf mass, minimum leaf area, mortality time, assimilation scale and respiration coefficient. The caller supplies the saved compartments and accumulated respiration. Latitude is from -90 to 90 degrees, and consumed skin and soil temperatures are from 140 to 360 K. The model uses 273.16 K as its supplied freezing reference in the retained checks.

The source updates covered columns, saves the returned compartments, clears the old accumulations and adds the new temperature-dependent respiration. Uncovered columns retain their values. Columns do not exchange biomass. The [solver contract](../../../skills/md2asm/references/openifs/surface/nitro_decline.md) preserves every branch and records the independent compartment checks. These checks concern the original per-call map; they do not infer a new continuous-time plant model.

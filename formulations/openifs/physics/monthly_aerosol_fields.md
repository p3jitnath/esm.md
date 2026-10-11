# Monthly Aerosol Fields

Revision 1.

## Physical Idea

Aerosols are small solid particles or liquid droplets in the air. They change how sunlight and heat pass through the atmosphere. This input uses monthly average fields for black carbon, organic matter, dust, sea salt and sulfate. A monthly average is a typical value for each month.

## Basic Mathematics

Let $`a_1`$ and $`a_2`$ be values from neighbouring months. Let $`w`$ be the fraction assigned to the first month, with $`0\leq w\leq1`$. The value at the required time is

```math
a(t)=w a_1+(1-w)a_2. \tag{AER-MON-1}
```

This equation gives a smooth change between the monthly values and preserves their units. Optical thickness is dimensionless and describes how much a column of air weakens radiation. Column aerosol mass is measured in kilograms per square metre. A mass mixing ratio is measured in kilograms of aerosol per kilogram of air, and pressure is measured in pascals.

Volcanic aerosols use monthly values centred on the sixteenth day. The same equation gives their change with time. Linear interpolation between neighbouring latitude points then gives the required latitude.

Dust has a monthly scale height, $`H`$, in metres. Let $`p`$ and $`p_s`$ be pressure and surface pressure in pascals. The cumulative fraction between the model top and pressure $`p`$ is

```math
F(p)=\left(\frac{p}{p_s}\right)^{\max(1,8434\,\mathrm{m}/H)}. \tag{AER-MON-2}
```

The fraction is zero at a zero-pressure top and reaches one at the surface. A difference between neighbouring fractions gives the amount assigned to the layer between them.

## Inputs And Boundaries

Use nonnegative monthly aerosol values, a valid Gregorian start date and elapsed time in minutes. Retain the original monthly fields. The initial state comes from their values at the start date.

The fixed optical-thickness fields have 72 longitude points and 46 latitude points. Volcanic data have 24 latitude points from 90 degrees north to 90 degrees south. Keep their supplied year range and optional fixed forcing year. Optional mass fields keep their supplied horizontal and vertical grids.

Monthly interpolation repeats across December and January. Volcanic years outside the supplied range use the nearest available year. The pressure grid runs from the model top to the surface and has one more boundary than layers.

The [md2asm contract](../../../skills/md2asm/references/openifs/physics/updecaec.md) records the exact calendar conventions, storage and complete update.

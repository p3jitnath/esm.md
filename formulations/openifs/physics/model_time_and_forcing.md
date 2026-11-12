# Model Time And Solar Forcing

Revision 1 describes the clock and forcing used by the coarse weather forecast. Forcing means an input that changes the atmosphere, such as the Sun's radiation or the amount of a gas.

Let $`n`$ be the whole-number time step and $`\Delta t`$ be its length in seconds. This forecast uses $`\Delta t=3600`$ seconds. The solar calculation uses the middle of each step.

```math
t_n=(n+1/2)\Delta t
```

Let $`r`$ be the distance from Earth to the Sun, in metres, and let $`a=149597870000`$ metres be the mean distance. Let $`I`$ be the solar energy received per unit area and time, in watts per square metre, at distance $`a`$. The energy received at distance $`r`$ follows the inverse-square law.

```math
I_r=I(a/r)^2
```

The orbital calculation also gives the Sun's angle north or south of the equator and a correction to clock time. These quantities set the direction of the incoming solar radiation. Monthly tables supply ozone, greenhouse gases and aerosols, which are small particles in air. The original table values, constants and starting date are retained. The forecast starts on 15 October 2004 at 12 UTC, and the model updates these inputs in the original order.

This is a global clock and forcing update. It has no spatial boundary. Its input tables and atmospheric layers remain those of the verified coarse forecast. The md2fort contract defines their storage and the complete numerical update.

# Convective Cloud Base

Revision 1 describes the complete OpenIFS CUBASEN physical calculation.

Warm, moist air can rise because it is less dense than the surrounding air. This calculation follows a small rising air parcel, mixes it with the surrounding air and finds its cloud base and cloud top. It also reports the available energy for upward motion.

Temperature $`T`$ is measured in kelvin, specific humidity $`q`$ is the mass of water vapour per unit mass of moist air in kilograms per kilogram, and geopotential $`\Phi`$ is gravitational potential energy per unit mass in square metres per square second. Dry static energy $`s`$ combines heat and height.

```math
s=c_pT+\Phi \tag{C1}
```

The heat capacity $`c_p`$ has units of joules per kilogram per kelvin. Mixing moves parcel humidity and static energy towards their surrounding values. The positive rate $`\epsilon`$ has units of inverse metres, and $`z`$ is height above the ground in metres.

```math
\frac{dq}{dz}=\epsilon(q_{\mathrm{env}}-q),
\qquad
\frac{ds}{dz}=\epsilon(s_{\mathrm{env}}-s) \tag{C2}
```

Condensation moves water from vapour into cloud liquid and releases heat. Freezing releases more heat. The supplied convection scheme removes half of the parcel's liquid at each lifting stage and applies its small cloud-water floor when it identifies cloud base.

The supplied scheme also includes its prescribed freezing correction in the buoyancy temperature.

Virtual temperature $`T_v`$ includes the density effects of water vapour and cloud water. Buoyancy $`B`$, in metres per square second, drives the vertical speed $`w`$, in metres per second. Mixing also reduces upward motion.

```math
B=g\frac{T_v-T_{v,\mathrm{env}}}{T_{v,\mathrm{env}}},
\qquad
\frac{d(w^2)}{dz}=2B-\text{mixing loss} \tag{C3}
```

Convective available potential energy, or CAPE, counts positive buoyancy along the parcel path. It has units of joules per kilogram.

```math
\mathrm{CAPE}=\int \max(B,0)\,dz \tag{C4}
```

The input supplies temperature, humidity, saturation humidity, pressure and geopotential on the atmospheric levels, plus surface heat, moisture and momentum fluxes. It also supplies parcel fields, the selected departure levels, positive mixing parameters, a cloud-depth threshold and any configured random perturbations. The initial parcel follows these supplied fields. Surface fluxes start the lowest parcel, while higher parcels use the neighbouring atmospheric state. Unselected columns retain their incoming values. The complete ordered calculation and output limits are in the [solver contract](../../../skills/md2asm/references/openifs/physics/cubasen.md).

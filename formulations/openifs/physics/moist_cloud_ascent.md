# Moist Cloud Ascent

Revision 1 describes the complete normal-physics OpenIFS CUASCN calculation. A rising cloud parcel exchanges air with its surroundings. Water vapour can condense, release heat and form rain or ice. Mixing and changes in buoyancy determine how far the parcel rises.

The upward mass flux $`M`$ is in kilograms per square metre per second. Entrainment $`E`$ adds surrounding air to the parcel, while detrainment $`D`$ removes parcel air. Both use the same mass-flux units.

```math
M_{\mathrm{above}}=M_{\mathrm{below}}+E-D
\tag{CA-1}
```

Temperature $`T`$ is in kelvin, height $`z`$ is in metres and gravity $`g`$ is in metres per second squared. Heat capacity $`c_p`$ is in joules per kilogram per kelvin. Dry static energy $`s`$, in joules per kilogram, combines heat and height.

```math
s=c_pT+gz
\tag{CA-2}
```

The transported vapour and condensate fractions $`q`$ and $`l`$ are in kilograms per kilogram. Their fluxes are $`Mq`$ and $`Ml`$. Condensation transfers water from vapour to condensate, and its latent heat warms the parcel. Condensate can become precipitation. Detrained condensed water splits into liquid and ice, and the two amounts sum to its total.

The initial state supplies parcel temperature, water, mass flux and speed at cloud base, together with the surrounding atmospheric column. Pressure increases towards the ground, and height decreases. The fixed configuration supplies heat capacity, gravity, phase temperatures, mixing rates, precipitation parameters and any positive stochastic factors. Aerosol settings can change the condensate threshold for rain formation. Deep, shallow and midlevel clouds use the supplied classification.

The calculation stops parcel ascent when its speed and buoyancy no longer support upward transport. It returns parcel and flux profiles, cloud levels, rain formation, liquid and ice detrainment, and mean parcel speed. Unselected columns retain every incoming output byte. The [solver contract](../../../skills/md2asm/references/openifs/physics/cuascn.md) defines the complete ordered update and accepted input range.

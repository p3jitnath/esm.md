# Convective Downdraft Descent

Formulation revision 1 describes how a rain-cooled downdraft mixes with its surroundings as it descends. Its numerical contract is [CUDDRAFN](../../../skills/md2asm/references/openifs/physics/cuddrafn.md). [Convective Downdraft Initial State](convective_downdraft_start.md) supplies the starting plume.

## Physical Idea

The descending plume takes in environmental air through entrainment and releases plume air through detrainment. These processes change its mass, heat and water fluxes. Evaporating rain adds water vapour and removes heat. A plume stops when it becomes buoyant or has too little rain to support the required evaporation.

Let $`M`$ be downward mass flux in kilograms per square metre per second, with downward flow represented by negative values. Let $`E`$ and $`D`$ be the signed entrained and detrained fluxes in the same units. Equation P1 gives the new mass flux before a possible stop.

```math
M_{\mathrm{new}}=M_{\mathrm{old}}+E-D. \tag{P1}
```

Let $`T`$ be temperature in kelvin, $`q`$ be specific humidity in kilograms per kilogram, $`c_p`$ be heat capacity in joules per kilogram per kelvin and $`\Phi`$ be gravitational potential energy per unit mass in joules per kilogram. Equation P2 transports sensible heat and water before [Saturation Adjustment](convective_saturation_adjustment.md).

```math
F_s=M(c_pT+\Phi),\qquad F_q=Mq. \tag{P2}
```

The plume also gains or loses kinetic energy from buoyancy and mixing. Kinetic energy per unit mass has units of joules per kilogram. A source-defined drag factor limits its increase. The numerical contract records these ordered changes and the nonnegative energy limit.

## Parameters and Supplied State

The caller supplies the starting plume, environmental temperature and humidity, pressure, gravitational potential, upward mass flux and available rain. The source configuration supplies an entrainment coefficient in inverse metres, the transition level to lower-region detrainment and a positive minimum mass-flux magnitude.

Gravity is source-defined, approximately 9.81 m s⁻². Heat capacity is source-defined, approximately 1005 J kg⁻¹ K⁻¹. The unchanged saturation adjustment uses the convective liquid–ice transition from 235.16 K to 273.16 K. Before adjustment, plume temperature is limited to the source range of 100–400 K.

## Boundaries

The ordered descent starts at model level 3 and ends at the model bottom. A column progresses only while its supplied downdraft flag is true and its previous mass flux is negative. Rain changes are written at the previous level. Inactive state arrays retain their bytes, apart from the source-defined detrainment and kinetic-energy initialisation. The accepted domain uses normal physics with the tangent-linear flag false.

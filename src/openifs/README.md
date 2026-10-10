# OpenIFS assembly

Direct assembly routines are grouped into dynamics, physics and surface changes. Dynamics supplies pressure, air properties and atmospheric motion. Physics routines apply heating and other supplied rates. Surface routines update soil, snow, lake and tile states. Each routine must pass its critical physical checks and exact forecast-call comparisons before it is accepted. There are 53 accepted bodies, including [shortwave Band 21](../../bench/openifs/physics/srtm_taumol21.md). The [coverage record](../../bench/openifs/README.md) gives the verified scope.

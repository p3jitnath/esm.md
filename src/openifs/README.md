# OpenIFS assembly

Direct assembly routines are grouped into dynamics and surface changes. Dynamics supplies pressure, air properties and atmospheric motion. Surface routines update soil, snow, lake and tile states. Each routine must pass its critical physical checks and exact forecast-call comparisons before it is accepted. The [coverage record](../../bench/openifs/README.md) gives the verified scope.

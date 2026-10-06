# OpenIFS routine work list

Count the exact routines before reporting how much work remains. A routine is a subroutine or function with an implemented body. Exclude interface declarations, duplicate declarations and compiler-generated helpers. Record the source version, build configuration and counting rules.

Keep separate counts for the source inventory, routines in the configured forecast build and routines observed during the T21 forecast. The earlier scan found 5,090 subroutine declarations, which includes interfaces and is not an exact implementation count. A forecast profile also omits functions without profiling markers.

| Work item | State |
| --- | --- |
| Exact routine inventory and forecast dependencies | In progress |
| CPSPE surface-state update | Assembly and critical and forecast checks pass |
| GPRCP moist-air properties | Assembly and critical and forecast checks pass |
| GPPWC pressure-weighted column integral | Assembly and critical and forecast checks pass |
| Next complete routine | Select after the inventory review |

Work through the remaining required routines one at a time. For each routine, record its physics note and frozen md2asm contract, emit the complete assembly body, pass independent physical and exact-byte checks, then verify captured forecast calls before moving to the next routine. Update this table after completed checks and keep detailed inventories in ignored .runtime/openifs/.

The complete assembly forecast remains unfinished. Whole-forecast physical checks and the external numerical-library arithmetic audit also remain open.

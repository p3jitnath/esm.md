# Departure Point Controls

A departure point is the earlier position of air that reaches a grid point after one time step. The existing semi-Lagrangian solver traces this path backwards. This small setup gives that solver its source iteration count and vertical-limit weights, while preserving its verified numerical body.

The stage follows `arpifs/setup/sudyn.F90` lines 648–650, 763, 864–865, 889 and 963–967. The first NAMDYN and NAMDYNA groups must already have been admitted as empty. The selected route is ECMWF, three-dimensional and NCONF one. The existing dynamics owner supplies the two logical extrapolation flags LSETTLST and LSETTLSV. NITMP starts at two and becomes three when either flag is true. Each flag must be zero or one. On the current forecast both flags are true, so the derived count is three.

VETAON and VETAOX are dimensionless weights that set the permitted vertical interval near the model top and bottom. The source sets both to one and then bounds each to the interval from 0.000001 through one. The admitted empty groups preserve those defaults, so both final weights remain exactly one. LRHS_CURV and LFINDVSEP retain their named source false assignments. These five fields select the existing trajectory calculation and introduce no new physical approximation.

The C application binary interface is `int md2asm_initialize_departure_point_controls(MODEL,model_capacity,platform16)`. MODEL, its byte capacity and platform16 arrive in x0 through x2, and status returns in w0. The mapped MODEL record must be aligned to eight bytes, non-wrapping and at least 4,275,088 bytes. The mapped 16-byte platform view must be aligned to four bytes, non-wrapping and disjoint from MODEL. Its four 32-bit words are NCONF, LECMWF, LR2D and LR3D, with admitted values 1, 1, 0 and 1. The Arm floating-point control register must be zero.

| MODEL field | Byte offset | Source result |
| --- | --- | --- |
| NITMP | 1568808 | Two, or three when either live extrapolation flag is true. |
| VETAON | 1568816 | FP64 one. |
| VETAOX | 1568824 | FP64 one. |
| LRHS_CURV | 1568896 | Logical false. |
| LFINDVSEP | 1569160 | Logical false. |

Only these 28 bytes change. The borrowed flags are at MODEL offsets 1564420 and 1564424. Every validation precedes mutation. Return zero means success, and return two refuses an unsupported record, platform or flag without changing MODEL. The entry is a leaf, so it calls no other function and needs no stack frame. It preserves x18, all callee-saved registers and floating-point status. It allocates no storage and has no external production dependency.

The existing `md2asm_default_selected_dynamics_controls` entry owns the live extrapolation flags. The accepted interpolation-control producer admits the two source namelist groups. Call this entry after both producers and before trajectory consumers. Geometry, the time interval, coordinate owners and all numerical child interfaces remain unchanged.

Four genuine typed source comparisons cover all combinations of the two extrapolation flags, including the actual forecast inputs. All 17,100,352 MODEL bytes agree exactly. Twenty separate source-rule relations confirm the iteration count, two weights and two false flags. The native ABI mask is zero, and immediate FPCR, FPSR and errno match. Nine critical null, bounds, alignment, overlap, unsupported-platform and invalid-flag cases refuse atomically. Complete saved-output agreement remains a separate gate in the autonomous forecast.

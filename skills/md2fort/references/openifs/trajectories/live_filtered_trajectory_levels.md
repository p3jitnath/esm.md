# Live filtered trajectory levels

The original LAVENT loops over levels 1 to NFLEVSF for the vertical trajectory filter and over NFLEVSF + 1 to NFLEVG for ordinary extrapolation. The actual model produces NFLEVSF from its vertical setup. The native entry now accepts that count from zero through the live layer count. It does not clamp the value or replace the source-produced count with two.

This revision changes only the count admission and its explanatory comments. Every numerical loop, counter write, array access, formula and child call retains its previous text. The default remains two filtered levels. The first-order-step count remains zero, matching the existing selected route. Capacity remains 1 to 1,024 points and the layer count remains 4 to 256. Counter storage retains at least one entry for every layer; an empty filtered set changes none of its entries.

Wind is in metres per second and the eta rate is in inverse seconds. Eta is a dimensionless vertical coordinate. The unchanged filter scale has units of square seconds and its offset has units of inverse square seconds. The existing owned hyperbolic tangent remains the same reviewed Fortran arithmetic revision. Its previously stated accuracy and reference limits remain explicit: this source extension does not establish global bit identity with a vendor tangent.

The old source and artifacts remain unchanged. The exact inverse delta reconstructs the old source, and the native module interface retains the same bytes after its source-filename header. Strict compilation, complete linking and focused forbidden-instruction inspection pass without a numerical call. The larger filter domain still requires independent exact-output, natural-status, physical and buffer checks before acceptance.

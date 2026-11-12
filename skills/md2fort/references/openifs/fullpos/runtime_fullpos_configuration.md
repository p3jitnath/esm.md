# Runtime Fullpos Configuration

`SUFPC` reads the output settings in the first `NAMFPC` group, a named group of text settings. `md2asm_initialize_runtime_fullpos_configuration` builds the selected Fullpos records from those settings and live forecast controls. It owns this configuration step in assembly and calls no original OpenIFS routine.

The selected route uses `KFPCONF=2`, `CFPFMT='MODEL'`, ECMWF physics and a global grid. The earlier control record must supply `LECMWF=true`, `LELAM=false`, `LARPEGEF=false` and `NFPOS=2`. The source is `arpifs/fullpos/sufpc.F90`: declaration defaults and source assignments come before the read, followed by object, scientific, interpolation and optional field-list checks and assignments.

The application binary interface, or ABI, specifies the arguments and registers. Pass the text address in `x0`, its length in `x1`, an upstream record of 32 bytes in `x2`, an output table of 80 bytes in `x3`, a workspace of 71,360 bytes in `x4` and its capacity in `x5`. The text length is from 1 to 262,144 bytes. Return `w0` is zero on success or two on invalid or unsupported input. The workspace can change on rejection, while the external output records remain unchanged.

The upstream record retains the [selected configuration interface](fullpos_configuration_setup.md): forecast-control address and capacity, `NVGRIB`, `NGRIBFILE`, `KFPCONF` and mode. The forecast view has at least 51,112 bytes and supplies the actual schedules and output frequency. The output table contains five address and capacity pairs.

| Pair | Record | Bytes | Workspace Offset |
| --- | --- | ---: | ---: |
| 0 | `TNAMFPOBJ`, object settings | 8,544 | 0 |
| 1 | `TNAMFPSCI`, scientific settings | 312 | 8,544 |
| 2 | `TNAMFPINT`, horizontal interpolation settings | 72 | 8,856 |
| 3 | `TNAMFPL`, field and level lists | 62,384 | 8,928 |
| 4 | Owned `YOMFPC` scalar settings | 48 | 71,312 |

Mode zero leaves pair 3 null with capacity zero and keeps its field-list image private. Mode one returns all five records. Other pairs are present in both modes. Records, tables and workspace are aligned to eight bytes. Live views are separate and their address ranges must not wrap. The caller owns and releases this storage. This child allocates no heap memory and opens no file.

The child uses the [full runtime namelist parser](../output/runtime_output_namelist.md), including its 30 settings, whole-array `(:)` notation, logical values and exact integral real tokens. Dynamic and physical lists have at most 256 entries, the two-dimensional list at most 212 and the model-level list at most 200. The six real-level capacities are 75, 127, 75, 75, 75 and 75. Ordinary field identifiers are from 1 to 686, and physical identifiers are positive signed 32-bit integers. Pressure levels use pascals. `RFPCORR` uses joules per kilogram. The selected climatology setting `NFPCLI` is zero.

The shared parser source is compiled with the name `md2asm_parse_runtime_sufpc_namfpc` and a false trace default. This follows the original pre-read assignment `LTRACEFP=LARPEGEF` on the admitted false branch. An explicit text setting still overrides that default. The separate generic parser retains its original name and true declaration default, and no parser body is copied into another public source file.

All 30 parsed settings are copied into the existing declaration images. Only five bytes of `CFPFMT` are copied because the next object byte starts `CFPDOM`. Unused dynamic and physical suffixes retain their original defaults. Object padding at bytes 845 through 847 remains spaces, scientific-record padding remains zero and scalar padding at bytes 36 through 39 retains the caller's preimage. The original selected checks and complete record commit follow the read. The full parser checks active physical identifiers in both modes, a narrower admitted mode-zero domain than the original optional-field-list call.

The private parser result is separate from the 71,360-byte workspace. The outer frame, private result and nested parser frame require $`320+22608+23152=46080`$ bytes of stack, excluding the caller's frame. The stack remains aligned to 16 bytes. Saved registers, `x18`, floating-point control and status, and the C library error indicator `errno` are preserved. Parsing and record copies use integer instructions, so exact floating-point bit patterns are copied without arithmetic or changed rounding.

Both runtime reads select this child: the constructor's partial `SUFPC` read and the later filter preparation's field-list read. The smaller qualified [configuration producer](fullpos_configuration_setup.md) remains available for its declared inputs. The [assembly source](https://github.com/p3jitnath/esm.md/blob/28940eb213fb69ab2b64cc0bf154ca733f7c1c21/src/openifs/fullpos/runtime_fullpos_configuration.S) shares the existing parser and declaration tables.

Four focused original-versus-assembly cases compare 223,056 complete returned bytes with zero differences and check 8,324 independent source relations. They cover the actual full group in both modes, an omitted trace setting and an explicit true trace setting. Unknown input is rejected atomically, and guards and read-only inputs remain unchanged. Floating-point control and status agree for the incoming status values 0, 24, 16 and 0. The native ABI mask is zero. The original control's recorded `x18` difference and natural `errno` zero versus native 777 remain explicit. These checks accept this configuration child and its declared inputs. They do not accept a complete constructor, output parent or forecast.

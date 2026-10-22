# Initial Spectral Field Reader Contract

Revision 1 reads the frozen ICMSHepc8INIT initial-condition file through the ecCodes 2.28.1 C file-format interface. This is a file-decoding step, so it adds no physical equation, numerical time update or field conversion. The assembly owns opening the file, visiting messages, checking labels and bounds, placing decoded values and closing every file and message handle.

## Input And Output

The frozen input has 121,560 bytes and SHA256 `439933f865ec58b0ae1dd0b3cd501babe40c0c7819c6c47f5a0936968c77f314`. It contains 78 spectral-complex GRIB messages. A GRIB message is one encoded field with its labels. Every message decodes to 506 FP64 values, where FP64 is the 64-bit floating-point format. The reader preserves the ecCodes value order and decoded bits without performing arithmetic on them. The caller remains responsible for selecting the frozen file; the reader checks its field labels and shape rather than its whole-file hash or every GRIB key.

The output values occupy 315,744 bytes in message order. Metadata occupies 1,872 bytes as 78 rows of three signed 64-bit integers: parameter identifier, level and value count. Row zero is (152, 1, 506). Rows 1 through 57 repeat parameter identifiers 138, 155 and 130 at levels 1 through 19. Row 58 is (129, 0, 506). Rows 59 through 77 hold parameter 133 at levels 1 through 19. The third value is always 506. Metadata identifiers and level numbers have no physical unit. Field units retain their encoded meaning; this reader applies no change of units. A separate eight-byte unsigned integer receives the number of committed messages. All output words are little-endian, which means that the least significant byte is stored first.

The actual GRIB keys give the names and units below. Vorticity measures local rotation of air, while divergence measures its local spreading. Geopotential is gravitational potential energy per unit mass. Specific humidity is the mass of water vapour divided by moist-air mass. These are field units; decoding changes none of them.

| Parameter | Short name | Decoded field | Encoded units | Unit meaning |
| ---: | --- | --- | --- | --- |
| 152 | lnsp | Logarithm of surface pressure | `~` | No unit |
| 138 | vo | Vorticity (relative) | `s**-1` | Per second |
| 155 | d | Divergence | `s**-1` | Per second |
| 130 | t | Temperature | `K` | Kelvin |
| 129 | z | Geopotential | `m**2 s**-2` | Square metres per second squared |
| 133 | q | Specific humidity | `kg kg**-1` | Kilograms per kilogram |

## Arm Interface

The entry is `int md2asm_read_initial_spectral_fields(const char *path, double *values, uint64_t values_bytes, int64_t *metadata, uint64_t metadata_bytes, uint64_t *messages_read)`. The application binary interface, or ABI, passes these six arguments in x0 through x5 and returns the integer status in w0. The path must be a readable C string ending in a zero byte. Output pointers must be nonnull and eight-byte aligned. Values and metadata capacities must be at least 315,744 and 1,872 bytes. Their fixed written extents and the count word must be disjoint and must not wrap the address space. Larger output tails remain untouched. The caller supplies mapped storage with these permissions; an integer capacity cannot establish that memory is mapped.

The assembly uses a 224-byte frame aligned to 16 bytes. It preserves x18 through x29, the return address, caller FPCR, caller FPSR and caller errno. FPCR controls floating-point rounding, FPSR records arithmetic flags, and errno is the C library's error value. FPCR must be zero on entry. The reader uses no SIMD register and performs no floating-point arithmetic. A format library can use arithmetic during decoding; its temporary flags and errno are restored before return.

## Errors And Partial Outputs

| Status | Meaning | Public output |
| ---: | --- | --- |
| 0 | Exactly 78 correctly labelled messages decode, followed by clean EOF and successful close. | All records and count 78. |
| 1 | Invalid pointer, alignment, capacity, overlap, wrapping range or nonzero FPCR. | All outputs unchanged. |
| 2 | The file cannot be opened. | Count zero; values and metadata unchanged. |
| 3 | A codec, stream-read or handle-deletion operation fails. | Partial output as described below. |
| 4 | Labels, value count, message count or extra-message check fails. | Partial output as described below. |
| 5 | File close fails after otherwise successful decoding. | All records and count 78. |

After all argument checks pass, the count starts at zero. A message is committed only after its value decode and handle deletion both succeed. Its metadata row is then written and the count increases by one. A failed value decode can partly write the current value record, while its metadata row and count remain uncommitted. Rows after the committed metadata prefix remain unchanged. A later EOF or close failure can leave all 78 records committed. Cleanup releases a retained handle and file on every valid-call exit, while an earlier error code takes precedence over a later cleanup error. Outputs on error must not be used as a complete initial state.

## Dependencies And Acceptance

The only external functions are `fopen`, `fclose`, `ferror`, `feof`, `__errno_location`, `codes_grib_handle_new_from_file`, `codes_get_long`, `codes_get_size`, `codes_get_double_array` and `codes_handle_delete`. The ecCodes handle constructor receives three arguments: a null context, the file stream and an error pointer. A null handle with error zero is accepted as EOF only when the stream has no error and reports EOF. A 79th handle is rejected. The codec is a declared file-format dependency; no OpenIFS or Fortran routine participates.

The reader was written directly as AArch64 assembly and assembled with `gcc -c -fPIC -march=armv8.2-a+simd`. No compiler-generated assembly or intermediate representation supplied its body. The local records keep the assembled source version, the comment-only publication revision, exact build commands, toolchain versions and hashes separately.

The separate ecCodes C control and direct assembly return identical complete values across 315,744 bytes and identical metadata across 1,872 bytes. All 11 focused cases pass: the real input, both short output capacities, a missing file, malformed and truncated input, missing and extra messages, reordered genuine messages, nonzero FPCR and the path/count overlap. Every case preserves protected output bounds and untouched padding, together with immediate caller FPCR, FPSR, errno and x18.

The existing native register probe also passes successful decoding, early capacity rejection and truncated-message cleanup. All three checks return a zero ABI failure mask, preserving the seeded x18 through x29, required low halves of d8 through d15 and immediate status. This reuses the accepted probe and does not repeat the full case matrix.

A standalone command with its main routine and file-writing helper in direct assembly reads the same real input and writes two raw output files. Its 315,744-byte value file and 1,872-byte metadata file each have zero differing bytes from the frozen references. Its direct libraries are ecCodes and libc; its complete link map contains no OpenIFS or Fortran dependency. The command does not place coefficients into forecast objects, initialise a forecast or own forecast calculations, so this component does not establish an autonomous forecast. Performance is not measured.

Revision 2 retains this public interface, file schema and output contract. Its thin entry selects the spectral schema for a private decoder shared with the [upper-air reader](initial_upper_air_field_reader.md). The shared source introduces no model calculation. The existing spectral checker passed all eleven focused cases and three seeded ABI paths against the revised shared body. Decoded values, labels, capacities, cleanup, protected bounds and numerical status retain their accepted results.

Revision 3 shares the decoder with the [surface reader](initial_surface_field_reader.md) and uses the 224-byte frame stated above. The spectral schema, output bytes and error rules remain unchanged. Its eleven focused cases and three seeded ABI paths pass against this revision.

## Operational Spectral Decoder

The separate `md2asm_read_operational_initial_spectral_fields` entry uses the same six-argument ABI and unchanged shared decoder. It reads the retained acfl ICMSHacflINIT schema: 413 messages, each containing 1,639,680 FP64 values. The order is logarithm of surface pressure (152, level 1), then vorticity, divergence and temperature (138, 155 and 130) for levels 1 through 137, then orography geopotential (129, level 0). There is no spectral humidity tail. Values need 5,417,502,720 writable bytes, metadata needs 9,912 writable bytes and the separate count needs eight writable bytes. Metadata retains three little-endian int64 words per message: parameter identifier, level and value count. The existing alignment, disjointness, bounds, partial-output, cleanup and status rules apply with these complete extents.

The accepted input inventory identifies the actual file, including its mixed GRIB editions, final orography date of 2020-10-19 at 12:00 and skipped inter-message gaps. The codec discovers message boundaries. The decoder checks parameter identifiers, levels, uniform decoded counts, total message count and clean EOF. It does not add date, truncation, grid-type or other key checks, and does not embed an input hash. The caller remains responsible for supplying the qualified input. ecCodes 2.28.1 remains the public file-format dependency; its internal decoding mathematics is not independently reimplemented.

One complete in-memory comparison against the separate public-ecCodes C control passes all 5,417,502,720 value bytes, 9,912 metadata bytes and the count with zero differences. All 1,239 integer metadata relations pass. Six seeded ABI/status calls pass with zero masks, preserving FPCR 0, FPSR 24 and errno 777. Two short capacities and three small genuine-message controls verify rejection, truncation and committed-prefix behaviour. All 416 guard and tail bytes remain intact, and the prefix control preserves its complete 5,404,395,168-byte uncommitted suffix. Both full routes acquire and delete 413 handles, visit one final EOF and close their one file. Every focused control closes its actual resources.

The recorded source projection recovers the complete old source after removing only the new entry and schema. Two publication-only header comments describe the additional entry and extents. The accepted three reader entries, shared-loop error cases and ABI evidence are reused. Production imports only the existing ecCodes C interfaces and libc services. The complete decoder check exits zero within its declared 600/602-second component bound; it is not a forecast or a performance comparison. No multi-gigabyte decoded payload files or hashes were produced. Spectral placement, owned loading, bootstrap and operational forecast admission remain separate checkpoints.

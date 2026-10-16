# Initial File Header Contract

GRIB is a weather-data file format, and ecCodes is the C library that decodes it. FP64 means the IEEE 64-bit floating-point representation. Spectral truncation gives the largest wave index represented by the spectral fields.

The selected startup reads geometry and vertical-coordinate metadata from two real initial-condition files. `SUARG`, in `arpifs/setup/suarg.F90`, sets `NSUPERSEDE` to one before reading `NAMARG`, calls `SUOPH0` to select the experiment filenames, and reads the spectral file and then the gridpoint file. For experiment `epc8`, these files are `ICMSHepc8INIT` and `ICMGGepc8INIT`. The selected configuration is ECMWF, spherical, regular Gaussian, with both files present and GRIB encoding.

The spectral path reaches `IOSTREAM_MIX::IO_INQUIRE`, then its public child `INQUIRE_GRIB`. Source lines 4451–4500 return the date, seconds within the day, forecast seconds, vertical level count and the A/B coefficients; lines 4628–4633 return the spectral truncation. The grid path uses source lines 4531–4573 for latitude-row and longitude counts. The short `SUARG` assignments copy the selected coefficients, choose regular-grid type zero or varying-longitude type two, take the largest northern longitude count, and set `NUCMAX` equal to `NUSMAX`.

## Direct child

`int md2asm_read_initial_model_headers(const char *spectral_path, const char *grid_path, void *record, uint64_t record_bytes)` owns opening the two files, decoding their first GRIB headers, deleting each handle, closing each file, checking bounds and copying the source-defined metadata. Its four arguments use `x0` through `x3`, and `w0` returns zero for success. It requires a separate, eight-byte-aligned output record with at least 5,232 bytes and readable zero-terminated path strings. The complete output stays unchanged on failure. The caller supplies readable zero-terminated paths and a mapped, readable and writable record. Record words use the little-endian Arm representation. The selected spectral file uses GRIB edition one, while the first gridpoint message uses edition two.

The selected bounds are 1–256 vertical levels, spectral truncation from zero to 4,096, an even number of latitude rows from 2 to 512, and positive signed 32-bit longitude counts. This revision accepts regular Gaussian grids with `PLPresent=0` and `Nj=2*N`, where `N` is the Gaussian order. Reduced grids are rejected. The date must fit the positive YYYYMMDD range, the clock must be a valid HHMM value, forecast hours must convert into nonnegative signed 32-bit seconds, and the decoded coefficients must be finite. The file supplies all coefficients and active counts; no production packet or retained model object supplies them. Only active array prefixes change. The unused coefficient and longitude tails, and reserved record bytes, keep their incoming values.

| Byte offset | Source metadata | Storage and units |
| --- | --- | --- |
| 0, 4, 8, 12, 16, 20, 24, 28 | NUSMAX, NUCMAX, NUDGL, NUDLON, NUFLEV, NUHTYP, NUSTTYP, NGRIBFILE | Eight signed 32-bit integers; counts or choices have no unit |
| 32, 36, 40 | Spectral date, seconds within day, forecast seconds | Three signed 32-bit integers; date is YYYYMMDD, times use seconds |
| 44, 48, 52 | Grid date, seconds within day, forecast seconds | Three signed 32-bit integers with the same meanings |
| 56 | Number of northern latitude rows | Signed 32-bit count |
| 64, 72, 80 | USTRET, UMUCEN, ULOCEN | FP64 values one, one and positive zero |
| 88 | NSUPERSEDE | Signed 32-bit value one for this selected input route |
| 96 | UVALH, indices 0 through 256 | 257 FP64 coefficients in pascals |
| 2152 | UVBH, indices 0 through 256 | 257 FP64 coefficients with no unit |
| 4208 | NULOEN, northern rows 1 through 256 | 256 signed 32-bit longitude counts |

Pressure at a layer boundary is A plus B times surface pressure. The A coefficient therefore has units of pascals, while B has no unit. This child copies their exact decoded FP64 bits and performs no physical update. Integer arithmetic converts the file's HHMM clock and forecast hours into seconds, following the original header child.

## Interface limits and verification

Production depends only on the ecCodes C file-format interface and libc. The assembly owns both file streams and both message handles, and each live resource is released once on every exit. It uses a 10,352-byte stack frame, preserves the Arm saved registers and `x18`, and requires FPCR zero before decoding. FPCR controls floating-point rounding and exception settings, FPSR records arithmetic flags, and errno is the C library error indicator. As a file-decoding utility, this child preserves caller FPCR, FPSR and errno, following the accepted initial-field reader contract. The original header composition has a different status boundary: its Gaussian route evaluates discarded latitude arithmetic, and its library calls can change errno. The source control retains those raw effects separately; this utility does not force flags or errno to imitate them. No full `SUARG` or `IO_INQUIRE` replacement is claimed, because their namelist, calendar, stream-owner and diagnostic stages remain separate work. The output record is owned by the caller and uses no OpenIFS type, module data, virtual table or callable. `md2asm_initial_model_header_count_get()` returns the number of completed successful two-file reads and is initially zero. The selected study is serial.

Return zero for complete success, one for an invalid argument or nonzero FPCR, two for file-open failure, three for message/codec/deletion failure, four for unsupported or inconsistent metadata, and five for a close failure after otherwise successful reading. Earlier errors take precedence over cleanup errors. Every failure leaves the whole public output unchanged. Source-unused coefficient and longitude tails and reserved words are copied from the incoming record rather than normalised.

Before admission, compare the complete defined record and preserved tails with the original public `INQUIRE_GRIB` child and the short source `SUARG` assignments. Independently inspect the actual first GRIB header and its hybrid-pressure identities. Check the real two-file input, critical malformed inputs, output bounds, cleanup and the ABI. No model or performance measurement is part of this child checkpoint.

## Completed checks

The original public `INQUIRE_GRIB` control reads both actual files and applies the short `SUARG` assignments to the same owned record. Two incoming byte patterns produce 10,464 complete source bytes. Three native successful placements, including a protected page end, compare 15,696 bytes with zero differences. Reserved words, inactive A/B entries, unused longitude entries and larger caller-buffer tails remain unchanged.

Twelve semantic and bounds cases cover the real two-format input, extra output capacity, short capacity, misalignment, missing first and second files, malformed input, second-file truncation, an odd vertical-coordinate count before array decoding, odd latitude rows, swapped file types and an address-wrapping output range. Every failed call leaves the full public owner unchanged, every file descriptor count is balanced, and only completed successful reads increment the counter. Four native ABI checks cover success at a protected page end, early rejection, second-file failure and nonzero FPCR. All saved-register masks are zero, and caller FPCR, FPSR and errno are preserved exactly.

The independent check reads GRIB1 and GRIB2 sections without ecCodes. It reconstructs all forty coefficients from the GRIB1 IBM 32-bit representation and checks the GRIB2 date, template, Gaussian order and point counts. All 320 coefficient bytes and 64 northern-longitude bytes match the source record. At surface pressures of 80,000, 101,325 and 110,000 pascals, 123 exact rational relations verify the top and bottom pressures, increasing layer-boundary pressure and pressure bounds.

The reference composition has different raw effects from the declared utility interface. Its cold call returns FPCR/FPSR/errno 0/16/2 from seed 0/777 and has register mask two because x18 changes. Its subsequent call returns 0/31/777 from seed 31/777 and has mask zero. These are retained raw observations, rather than a universal status rule. The native utility always follows its preserved-status interface.

The assembler and linker build the direct source without compiler-generated assembly or intermediate representation. The production library requires only ecCodes and libc, and the pure native verification process maps no OpenIFS, FIAT, Fortran-runtime or ecCodes-Fortran library. Original Fortran and MPI initialisation occur only in the separate reference process. No model forecast or performance measurement was run. The local ready packet records the exact commands, versions, implementation hashes and all check receipts.

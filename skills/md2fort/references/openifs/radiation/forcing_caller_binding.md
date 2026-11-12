# Owned Radiation Forcing Caller

This small assembly adapter connects the forecast's existing `UPDRGAS` call to the [verified owned forcing service](owned_radiation_forcing.md). That service updates greenhouse-gas mass ratios and Sun’s radiation from original climate files. The adapter rearranges addresses and live scalar controls without adding numerical arithmetic. Original OpenIFS module pointers, constructors and type tables are not used.

The entry `md2asm_updrgas` receives five addresses in `x0` through `x4`. They name read-only TDYNA456, read-only TERAD2040, writable TERDI176, read-only TRIP175976 and an optional FP64 solar override. A number attached to a record gives its complete byte size. The optional address is zero when absent. All mapped records and numerical owners must satisfy the owned forcing service's alignment, bounds and disjointness rules. FPCR must be zero.

The completed [radiation context](selected_radiation_setup.md) remains live throughout the forecast. The adapter borrows its constants address at byte 48 and climate-owner address at byte 4256. It reads the current source-compatible `YOMRIP0.NINDAT`, `YOMCT2.NSTAR2` and `YOMCT0.LNF` aliases from assembly-owned state. These give the model date, restart step and forecast-mode flag. Its private seven-pair table then calls the accepted explicit-input service. The service retains its declared date, table and optional-input acceptance limits.

TDYNA contains dynamics settings, TERAD contains radiation settings, TERDI receives updated gas and solar values, and TRIP contains time-integration settings.

The frame has 192 bytes and sixteen-byte alignment. The adapter preserves `x18`, all callee-saved registers, FPCR and stack arguments, while the numerical child preserves the natural FPSR and errno values. Success returns normally after the child returns zero. Unsupported input reaches the declared libc abort boundary. No numerical fallback is available.

Eight retained profiles cover current and fixed dates, integer and two-level restarts, constant solar input and both optional-override branches. The adapter reproduces all 1,408 accepted output bytes, with zero differences, unchanged input records and zero ABI masks. Immediate FPCR, FPSR and errno match the retained service results. The earlier genuine source comparison and 64 independent physical relations are reused. This changed-boundary check makes no new original Fortran call and runs no forecast. The isolated verification globals are not part of production.

The five-address order follows the genuine UPDRGAS declaration and both complete UPDTIM call sites. TDYNA is the first argument and TERDI is the third. The adapter changes only address forwarding when it builds the explicit forcing table; the numerical child is unchanged. The corrected complete forecast attempt passes this call boundary before reaching the next norm-binding stage, while the eight stored profiles check its complete results.

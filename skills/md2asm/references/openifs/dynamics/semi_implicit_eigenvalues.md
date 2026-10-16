# Semi-Implicit Eigenvalue Service

The semi-implicit time update uses a matrix to describe fast pressure-wave motion. An eigenvector is a pattern that this matrix scales without changing its shape. Its eigenvalue gives that scale. This assembly entry retains the original EIGSOL interface and calls an independently downloaded Netlib EISPACK mathematical library. The remaining model setup constructs, orders and normalises these patterns in assembly.

## Source And Library Boundary

The source wrapper is OpenIFS 48.1.1 `algor/external/linalg/eigsol.F90`. Its ten argument addresses are forwarded to the real-general-matrix API RG. The authored assembly retains its two conditional EIGSOL profiling calls through the permitted FIAT service. Production uses the standalone [Netlib EISPACK](https://www.netlib.org/eispack/) implementation through a private symbol name, rather than the bundled OpenIFS RG routine. The library contains RG, BALANC, ELMHES, ELTRAN, HQR, HQR2, BALBAK and CDIV. Its Fortran source, compiler commands, original download URLs and hashes remain local under `.runtime/`.

The standalone library uses FP64, four-byte integers, ordinary column-major arrays and the original mathematical algorithm. It is built with contraction and fast math disabled. Its private symbol is `md2asm_netlib_rg_`. This is an explicit external mathematical-library boundary. No original OpenIFS library, constructor, global model storage or numerical fallback supplies the production stage. The original EIGSOL and RG remain separate verification references.

## Assembly Interface

`md2asm_semi_implicit_eigenvalues` takes the original ten addresses in this order. The first eight use x0 through x7, followed by the two eight-byte incoming stack slots at zero and eight.

| Argument | Type And Extent | Meaning |
| --- | --- | --- |
| NM | int32 scalar | Allocated rows in each matrix column |
| N | int32 scalar | Matrix order |
| A | FP64 NM by N | Input matrix, overwritten by the library reduction |
| WR | FP64 N | Real eigenvalue parts |
| WI | FP64 N | Imaginary eigenvalue parts |
| MATZ | int32 scalar | Nonzero requests eigenvectors |
| Z | FP64 NM by N | Returned eigenvector columns |
| IV1 | int32 N | Integer work array |
| FV1 | FP64 N | Floating-point work array |
| IERR | int32 scalar | Zero on success, otherwise the library error code |

The selected mode stage uses NM equal to N, N from one through 255, and MATZ one. All complete arrays and scalar cells are mapped, have nonwrapping address spans and are disjoint. FP64 arrays align to eight bytes and integers to four. The arrays hold finite values within the admitted model domain. The caller provides all storage and retains each owner through the call. For a complex pair, consecutive Z columns contain the real and imaginary vector parts, following the declared EISPACK API. The enclosing hydrostatic model requires real positive eigenvalues and checks that condition separately.

The 160-byte stack frame aligns to 16 bytes. It saves the two incoming stack arguments before making any external call, then writes them to the outgoing stack slots before RG. It preserves x18, x19 through x29 and the required saved floating-point registers. It performs no floating-point arithmetic itself. Use FPCR zero, nearest rounding with ties to even, gradual underflow and preserved signed zeros. The only external calls are the declared standalone RG API and FIAT profiling.

## Accepted Checks And Limits

Four basic real and complex matrix cases match the genuine original source over 1,024 complete bytes, including the altered matrix, work arrays, guard cells, returned values and immediate numerical status. They use the accepted isolated one-thread mathematics-fixture protocol with LHOOK false. An independent 80-digit calculation checks the defining matrix relations.

A separate 19-level matrix comparison initializes real permitted MPL and OML services, retains LHOOK true, and compares 6,436 complete bytes with zero differences. The two fresh processes consume identical frozen binary matrix inputs. Immediate FPCR, FPSR and errno agree, and the independent matrix relations pass. This fixture records its original SUBMAT provider route. The complete mode gate separately uses the frozen ordered original vertical-child route. Static independent review confirms the ten-address ABI, profiling handle placement, saved registers and stack alignment. No OpenIFS routine supplies the production eigenvalue calculation.

These checks qualify the declared matrix-service calls. They do not establish arbitrary ill-conditioned matrices or a complete autonomous forecast. The enclosing mode and forecast comparisons remain required. Assemble the source with `gcc -c -fPIC src/openifs/setup/semi_implicit_eigenvalues.S -o semi_implicit_eigenvalues.o`, then link the separately built standalone EISPACK library and the declared FIAT profiling service.

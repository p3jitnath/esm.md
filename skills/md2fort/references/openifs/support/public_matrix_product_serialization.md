# Shared public matrix product service

A matrix product combines rows of one array with columns of another. The public `dgemm_` interface performs this operation in double precision. This assembly service calls that interface with every original argument unchanged and allows one call at a time through one shared lock.

The shared service coordinates access to temporary library storage while retaining each worker's original matrix equations, array slices and public function target. Its accepted scope is the observed provider and build.

## Interface and ownership

`md2asm_public_dgemm_serialized` uses the original GNU Fortran application binary interface, or ABI. Registers `x0` through `x7` contain the addresses of `TRANSA`, `TRANSB`, `M`, `N`, `K`, `ALPHA`, `A` and `LDA`. The incoming stack contains the addresses of `B`, `LDB`, `BETA`, `C` and `LDC`, followed by two 64-bit character lengths. The service copies all 56 stack bytes unchanged. It does not inspect the matrix values or dimensions.

The caller supplies valid arrays and dimensions for the selected public interface. Matrix data use eight-byte floating-point values, dimensions and leading dimensions use four-byte integers, and each character length uses eight bytes. Every address must remain valid until the call returns. The original public routine determines which arrays change. The service adds no allocation and retains no caller pointer.

The private stack frame uses 96 bytes and keeps the stack aligned to 16 bytes. The service preserves `x18`, `x19`, `x20` and the return address. It does not change other registers that the ABI requires it to preserve. It adds no floating-point instruction and returns the floating-point status and `errno` produced by the public call.

The eight-byte `md2asm_owned_public_matrix_lock` is aligned to 64 bytes and starts at zero. An acquire operation takes its low four-byte word, and a release operation clears it after the public call. Waiting threads use the Arm event mechanism. A failed exclusive store retries acquisition directly, so it does not wait for a lock owner that might not exist. The upper four bytes remain zero.

## Required link boundary

All callers that need this protection must import the unique entry from one shared library instance. Use one shared object name, or SONAME, across the executable and all dependent libraries. Resolve its `dgemm_` relocation to the same public function body that the matched reference uses, and resolve symbols before numerical entry. The public call must return without re-entering the same service through a callback.

The accepted local build uses Armv8.2-A, one 108-byte text section, one shared service instance and serial Sci 25.03.0 from its GNU 12.3 AArch64 library directory. The exact build commands and actual loaded addresses remain in the local records. The service does not alter the public provider or select a replacement arithmetic implementation.

## Completed check and limits

The check compared complete outputs with the original `MXMAOP` control for four matrix shapes, 19 by 7, 19 by 53, 137 by 271 and 512 by 3, each with one and six threads. Sixteen original and native calls compared 636,848 output bytes with zero differences. Seventy-two separately calculated high-precision sums also passed. Input preservation, buffer guards, register obligations, floating-point control and status, `errno`, lock release and process cleanup passed.

This accepts the shared service for the recorded provider and component inputs. Parent, complete-forecast and final-reference qualification remain separate. Each caller must satisfy its own array bounds and preserve the matched public arguments.

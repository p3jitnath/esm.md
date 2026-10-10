# Shortwave Band 21 Verification

SRTM_TAUMOL21 calculates gas absorption and molecular scattering. The original physics and directly written Arm assembly pass the declared checks. Acceptance closed on 10 October 2026 at 20:10 UTC, using exclusive job 7207705 on nid011311, one process, one thread and CPU 16.

| Check | Coverage | Differing bytes |
| --- | --- | ---: |
| Protected native calls | 76 cases, with 144 calls and four pre-call rejections, 833,008 returned bytes | 0 |
| Same-input Band 21 pairs | 6,400 calls, all 26 arguments, 361,958,400 returned bytes | 0 |
| Prior complete routine streams | 50 pairs, 7,595,504,008 bytes | 0 |
| Canonical saved forecast files | 10 files, 618,140 bytes | 0 |

All 31 immutable table regions and both floating-point registers also match. The complete 16-channel outputs retain inactive and untouched bytes. The live check runs original and assembly bodies from the same incoming state, then restores the original return.

Band17's separate cross-run complete-storage check records 53,713,296 differing bytes. Whole-process identity, independent whole-forecast physics and comparative timing remain unproved.

The four archived reports below retain the actual comparisons. SHA256 identifies each file and does not replace byte comparison.

- Original physics, `.runtime/openifs/implicit_stage_reviews_7207705/band21-actual-complete-capture-physics-r2/complete-original-capture-physics-review-r1.json`, SHA256 `e4eaecae5323c03f15f737d6f95b01ab978bdc02983a0f51eca1d8390def41fa`.
- Protected native calls, `.runtime/openifs/band21_direct_source_7207705/native-critical-run-r1/complete-76-case-native-critical-review-r1.json`, SHA256 `b03fc8ffaa556185892ef6013b4fa8f3538200755c0b6d0064d1cccb48f86bdf`.
- Complete live pairs, `.runtime/openifs/runs/strict-band21-parent52-live-original-native-pair-r1-7207705/t21/complete-Band21-live-pair-and-ten-saved-review-r1.json`, SHA256 `bdaf21eab0255365e348f9abc10d7fad8495b589c984915541798a47d3aab50f`.
- Combined forecast, `.runtime/openifs/srtm_taumol21_7207705/parent52-band21-integrated-launch-source-r1/single-checker-status/complete-parent52-and-Band21-integrated-acceptance-r1.json`, SHA256 `056428d7ebceca9439be2c91de0af004711aa45165817807311c3ce581e36b22`.

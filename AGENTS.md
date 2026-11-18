# PASC27 Branch Guide

Keep each formulation and its numerical specification together under `formulations/`, with shared specifications in `formulations/general/` and active solvers in `src/`. Follow the [writing convention](standards/ASD-STE100-CONV.md) and record inputs, ordered arithmetic, units and acceptance limits.

Keep measured source snapshots fixed as listed in the [source manifest](reproduction/source_manifest.json). Store build and diagnostic output in `.scratch/`. Verify the physics and complete outputs before timing on a quiet, exclusive allocation.

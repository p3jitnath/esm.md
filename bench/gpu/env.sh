# Source this file inside the exclusive Slurm step before building or running.
export GPU_SDK=${GPU_SDK:-/opt/nvidia/hpc_sdk/Linux_aarch64/24.11}
export CUDA_HOME="$GPU_SDK/cuda/12.6"
export CUDA_PATH="$CUDA_HOME"
export PATH="$CUDA_HOME/bin:$GPU_SDK/compilers/bin:$PATH"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$CUDA_HOME/nvvm/lib64:$GPU_SDK/math_libs/12.6/lib64:$CUDA_HOME/extras/CUPTI/lib64:${LD_LIBRARY_PATH:-}"
export NUMBA_CACHE_DIR="$PWD/.runtime/numba-gpu"
export NUMBA_CUDA_LOW_OCCUPANCY_WARNINGS=0
export JULIA_DEPOT_PATH="$PWD/.runtime/julia-depot"
export JULIA_NUM_PRECOMPILE_TASKS=1
export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1

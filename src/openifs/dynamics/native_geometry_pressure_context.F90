!> Bind the existing pressure solver to live native geometry and mode owners.
!! This entry copies named maps and coefficients. It performs no weather sum.
module md2asm_native_geometry_pressure_context
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_geometry_state_types, only: native_geometry_state
  use md2asm_semi_implicit_mode_storage, only: semi_implicit_mode_state
  use md2asm_spectral_transposes, only: spectral_transpose_layout
  use md2asm_distributed_pressure_stage, only: spectral_pressure_context
  use md2asm_spectral_pressure_context, only: initialize_spectral_pressure_context
  implicit none
  private
  public :: initialize_native_geometry_pressure_context
  interface
    function pressure_errno_location() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Copy the selected uniform-column pressure layout from its real producers.
  !!
  !! geometry is the initialized canonical native geometry. Its public message
  !! and transform context must remain alive through every subsequent solve.
  !! modes%eigenvalues is the initialized SIVP owner from the complete native
  !! mode setup, with one squared wave speed in m**2/s**2 per global level.
  !! This entry reads no other mode array and creates no replacement partition.
  !!
  !! time_step is seconds, beta_time and stretch are dimensionless, and
  !! rotation_rate is1/s. The caller supplies their actual current source
  !! controls. hooks_disabled is the actual source profiling condition; it is
  !! not inferred from an input filename or a previous comparison process.
  !! All scalar and coefficient words are copied without arithmetic.
  !!
  !! temporary_bytes_budget is the solver's permitted temporary storage in
  !! bytes. The unchanged constructor checks the exact message and work bounds.
  !! On success context owns independent copies. Rebuild this snapshot when
  !! any consumed map, mode eigenvalue or scalar changes. Geometry and modes
  !! remain unchanged and must not alias the destination context.
  !!
  !! Status0 succeeds,1 refuses allocation and2 refuses metadata. Any refusal
  !! preserves the previous context. This is a local entry with no MPI call:
  !! every rank must agree its result before entering the distributed solve.
  !! IEEE status and Linux errno are preserved, including allocation cleanup.
  subroutine initialize_native_geometry_pressure_context(geometry, modes, time_step, beta_time, stretch, &
                                                         rotation_rate, temporary_bytes_budget, hooks_disabled, context, status)
    type(native_geometry_state), intent(in) :: geometry
    type(semi_implicit_mode_state), intent(in) :: modes
    real(real64), intent(in) :: time_step, beta_time, stretch, rotation_rate
    integer(int64), intent(in) :: temporary_bytes_budget
    logical, intent(in) :: hooks_disabled
    type(spectral_pressure_context), intent(inout) :: context
    integer(int32), intent(out) :: status
    type(spectral_transpose_layout) :: layout
    type(ieee_status_type) :: saved_fp
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer :: n, levels, h, v, w, rank, vertical_index, horizontal_index, code
    integer(int64) :: local_columns
    call c_f_pointer(pressure_errno_location(), error_number)
    saved_errno = error_number
    call ieee_get_status(saved_fp)
    status = 2
    if (.not. geometry%initialized .or. .not. hooks_disabled) goto900
    if (.not. geometry%transform_control%message_ready) goto900
    if (.not. geometry%transform_control%environment_ready) goto900
    if (geometry%transform_resolution%resolution < 1) goto900
    if (geometry%partition%phase /= 7) goto900
    if (geometry%partition%borrowed_resolution /= geometry%transform_resolution%resolution) goto900
    n = geometry%dimensions%nsmax
    levels = geometry%dimensions%nflevg
    if (n < 1 .or. n > 8191 .or. levels < 1 .or. levels > 255) goto900
    if (geometry%transform_resolution%truncation /= n) goto900
    h = geometry%transform_control%nprtrw
    v = geometry%transform_control%nprtrv
    w = geometry%transform_control%nproc
    rank = geometry%transform_control%myproc
    horizontal_index = geometry%transform_control%mysetw
    vertical_index = geometry%transform_control%mysetv
    if (h < 1 .or. v < 1 .or. w < 1 .or. w > 65536) goto900
    if (int(h, int64)*int(v, int64) /= int(w, int64)) goto900
    if (rank < 1 .or. rank > w) goto900
    if (horizontal_index < 1 .or. horizontal_index > h) goto900
    if (vertical_index < 1 .or. vertical_index > v) goto900
    if (int(horizontal_index - 1, int64)*v + vertical_index /= int(rank, int64)) goto900
    if (.not. allocated(geometry%partition%nptrsv)) goto900
    if (.not. allocated(geometry%partition%nptrll)) goto900
    if (.not. allocated(geometry%partition%npsurf)) goto900
    if (.not. allocated(geometry%partition%mylevs)) goto900
    if (lbound(geometry%partition%nptrsv, 1) /= 1 .or. size(geometry%partition%nptrsv) /= v + 1) goto900
    if (lbound(geometry%partition%nptrll, 1) /= 1 .or. size(geometry%partition%nptrll) /= v + 1) goto900
    if (lbound(geometry%partition%npsurf, 1) /= 1 .or. size(geometry%partition%npsurf) /= v) goto900
    if (geometry%partition%nspec2 < 0 .or. geometry%partition%nspec2v < 0) goto900
    if (int(geometry%partition%nptrsv(v + 1), int64) - 1 /= int(geometry%partition%nspec2, int64)) goto900
    local_columns = int(geometry%partition%nptrsv(vertical_index + 1), int64) - &
                    int(geometry%partition%nptrsv(vertical_index), int64)
    if (local_columns /= int(geometry%partition%nspec2v, int64)) goto900
    if (geometry%partition%nflevl < 0 .or. geometry%partition%nflevl > levels) goto900
    if (size(geometry%partition%mylevs) /= geometry%partition%nflevl) goto900
    if (geometry%partition%npsp /= geometry%partition%npsurf(vertical_index)) goto900
    if (.not. allocated(geometry%laplacian%myms)) goto900
    if (.not. allocated(geometry%laplacian%nasm0)) goto900
    if (.not. allocated(geometry%laplacian%rlapdi)) goto900
    if (size(geometry%laplacian%myms) /= geometry%partition%nump) goto900
    if (lbound(geometry%laplacian%nasm0, 1) > 0 .or. ubound(geometry%laplacian%nasm0, 1) < n) goto900
    if (lbound(geometry%laplacian%rlapdi, 1) > 0 .or. ubound(geometry%laplacian%rlapdi, 1) < n) goto900
    if (.not. allocated(modes%eigenvalues)) goto900
    if (size(modes%eigenvalues) /= levels) goto900
    allocate (layout%coefficient_start(v + 1), layout%level_start(v + 1), &
              layout%pressure_partition(v), stat=code)
    if (code /= 0) then
      status = 1
      goto900
    end if
    layout%phase = 7
    layout%world = w
    layout%rank_zero_based = rank - 1
    layout%horizontal_peers = h
    layout%vertical_peers = v
    layout%horizontal_index = horizontal_index
    layout%vertical_index = vertical_index
    layout%maximum_degree = n
    layout%global_levels = levels
    layout%local_levels = geometry%partition%nflevl
    layout%spectral_coefficients = geometry%partition%nspec2
    layout%local_columns = geometry%partition%nspec2v
    layout%geometry_matches = .true.
    layout%hooks_disabled = hooks_disabled
    ! The selected false/full-field switch uses uniform NPTRSV,not NPTRSVF.
    layout%coefficient_start = geometry%partition%nptrsv
    layout%level_start = geometry%partition%nptrll
    layout%pressure_partition = geometry%partition%npsurf
    call initialize_spectral_pressure_context(layout, geometry%partition%mylevs, &
                                              geometry%laplacian%myms, geometry%laplacian%nasm0(0:n), modes%eigenvalues, &
                                              geometry%laplacian%rlapdi(0:n), time_step, beta_time, stretch, rotation_rate, &
                                              temporary_bytes_budget, context, status)
900 continue
    ! Local temporary owners expire before the observable state is restored.
    if (allocated(layout%pressure_partition)) deallocate (layout%pressure_partition)
    if (allocated(layout%level_start)) deallocate (layout%level_start)
    if (allocated(layout%coefficient_start)) deallocate (layout%coefficient_start)
    call ieee_set_status(saved_fp)
    error_number = saved_errno
  end subroutine
end module md2asm_native_geometry_pressure_context

module forecast_owned_vertical_system
  !! Complete selected SUVERT call order over native owned vertical arrays.
  use, intrinsic :: iso_c_binding, only: c_int, c_double, c_ptr, c_f_pointer
  use forecast_vertical_coordinate_storage, only: native_vertical_state
  use forecast_vertical_coordinate_arrays, only: initialize_vertical_eta_arrays
  use forecast_vertical_hybrid_adjustment, only: adjust_vertical_hybrid_arrays
  use vertical_spline_owner_port, only: initialize_vertical_spline_owners, release_vertical_spline_copy
  implicit none
  private
  public :: initialize_owned_vertical_system, release_owned_vertical_system
  interface
    function errno_location() bind(C, name='__errno_location') result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  logical function profile_bounds(values, lower, upper) result(valid)
    !! Inspect an allocatable owner without reading unallocated payload.
    real(c_double), allocatable, intent(in) :: values(:)
    integer, intent(in) :: lower, upper
    valid = .false.
    if (.not. allocated(values)) return
    valid = lbound(values, 1) == lower .and. ubound(values, 1) == upper
  end function
  logical function matrix_bounds(values, rows, columns) result(valid)
    !! Matrix indices begin at one; dimensions count complete FP64 elements.
    real(c_double), allocatable, intent(in) :: values(:, :)
    integer, intent(in) :: rows, columns
    valid = .false.
    if (.not. allocated(values)) return
    valid = all(lbound(values) == [1, 1]) .and. all(shape(values) == [rows, columns])
  end function
  logical function state_admitted(state) result(valid)
    !! Check the source-selected controls and every consumed owner before writes.
    type(native_vertical_state), intent(in) :: state
    integer :: n
    valid = .false.
    n = state%levels
    if (n /= 19 .and. n /= 137) return
    if (state%io_levels /= n .or. .not. state%constructor_ready) return
    if (allocated(state%rderb)) return
    if (state%configuration%lregeta /= 0 .or. state%configuration%lvfe_regeta /= 0) return
    if (state%configuration%lvertfe /= 1 .or. state%configuration%lvfe_centri /= 1) return
    if (state%configuration%lvfe_cheb /= 0 .or. state%configuration%lvfe_ecmwf /= 0) return
    if (state%configuration%nvfe_order /= 4 .or. state%configuration%nvfe_internals /= n - 2) return
    if (.not. profile_bounds(state%valh, 0, n)) return
    if (.not. profile_bounds(state%vah, 0, n)) return
    if (.not. profile_bounds(state%vbh, 0, n)) return
    if (.not. profile_bounds(state%vetah, 0, n)) return
    if (.not. profile_bounds(state%vetaf, 0, n + 1)) return
    if (.not. profile_bounds(state%vfe_etah, 0, n)) return
    if (.not. profile_bounds(state%vfe_etaf, 0, n + 1)) return
    if (.not. profile_bounds(state%vfe_rdetah, 1, n)) return
    if (.not. profile_bounds(state%vfe_knot, 1, n - 2)) return
    if (.not. profile_bounds(state%vc, 1, n)) return
    if (.not. profile_bounds(state%vdelb, 1, n)) return
    if (.not. profile_bounds(state%vdela, 1, n)) return
    if (.not. profile_bounds(state%vaf, 1, n)) return
    if (.not. profile_bounds(state%vbf, 1, n)) return
    if (.not. matrix_bounds(state%rintbf11, n + 1, n + 2)) return
    if (.not. matrix_bounds(state%rderbf00, n, n + 2)) return
    if (.not. matrix_bounds(state%rderbf01, n, n + 2)) return
    if (.not. matrix_bounds(state%rderbf10, n, n + 2)) return
    if (.not. matrix_bounds(state%rderbf11, n, n + 2)) return
    valid = .true.
  end function
  integer(c_int) function initialize_owned_vertical_system(state, reference_pressure, pi) result(status)
    !! Construct eta, five spline operators and adjusted pressure coefficients.
    !! state owns nineteen main and eight I/O arrays; this entry reads/writes only
    !! the source-selected main arrays and allocates the separate derivative copy.
    !! reference_pressure uses Pa; pi and all coordinates are dimensionless.
    !! The caller supplies nearest rounding, gradual underflow, no FP traps and
    !! the initialized source physical domain. Every allocatable is contiguous.
    !! Return0 completes all stages;1 is allocation failure;2 is admission
    !! refusal;3 is a numerical child failure. Earlier source-written arrays
    !! remain valid only for their completed stage on a later failure.
    !! Only the new derivative copy is released after adjustment failure.
    type(native_vertical_state), intent(inout) :: state
    real(c_double), intent(in) :: reference_pressure, pi
    real(c_double) :: bounds(2)
    integer(c_int) :: n, saved_errno
    integer(c_int), pointer :: error_value
    type(c_ptr) :: error_address
    status = 2
    if (.not. state_admitted(state)) return
    n = state%levels
    error_address = errno_location()
    call c_f_pointer(error_address, error_value)
    saved_errno = error_value
    status = initialize_vertical_eta_arrays(n, reference_pressure, pi, &
                                            state%configuration%rvfe_alpha, state%configuration%rvfe_beta, &
                                            state%vah, state%vbh, state%valh, state%vetah, state%vetaf, &
                                            state%vfe_etah, state%vfe_etaf, state%vfe_rdetah, state%vfe_knot, bounds)
    if (status /= 0) goto 900
    state%etah0 = bounds(1)
    state%etahn = bounds(2)
    state%eta_bounds_ready = .true.
    status = initialize_vertical_spline_owners(n, state%vfe_etaf, state%rintbf11, &
                                               state%rderbf00, state%rderbf01, state%rderbf10, state%rderbf11, state%rderb)
    if (status /= 0) goto 900
    status = adjust_vertical_hybrid_arrays(n, state%vah, state%vbh, state%vfe_rdetah, &
                                       state%rintbf11, reference_pressure, state%vdelb, state%vdela, state%vbf, state%vaf, state%vc)
    if (status /= 0) call release_vertical_spline_copy(state%rderb)
900 continue
    error_value = saved_errno
  end function
  subroutine release_owned_vertical_system(state)
    !! Release only the later derivative copy. The constructor's27owners and
    !! completed coordinate bounds stay owned by the surrounding startup state.
    !! Repeated release is permitted and incoming errno remains unchanged.
    type(native_vertical_state), intent(inout) :: state
    integer(c_int), pointer :: error_value
    integer(c_int) :: saved_errno
    type(c_ptr) :: error_address
    error_address = errno_location()
    call c_f_pointer(error_address, error_value)
    saved_errno = error_value
    call release_vertical_spline_copy(state%rderb)
    error_value = saved_errno
  end subroutine
end module forecast_owned_vertical_system

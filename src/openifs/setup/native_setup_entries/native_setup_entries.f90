!> Expose native setup entries while preserving their source checks and counters.
module forecast_native_setup_entries
  use iso_c_binding, only: c_int, c_int32_t, c_int64_t, c_double, c_char, c_ptr, c_f_pointer
  use forecast_gaussian_latitude_generation, only: legendre_fourier_coefficients, initialize_selected_gaussian_latitudes
  use forecast_grid_dimensions, only: native_grid_dimensions
  use forecast_latitude_geometry, only: native_latitude_geometry, initialize_selected_latitude_geometry
  use forecast_laplacian_geometry, only: native_laplacian_geometry, initialize_serial_laplacian
  use forecast_vertical_coordinate_storage, only: native_vertical_state, initialize_hybrid_coordinate_storage
  use forecast_hybrid_coordinate_defaults, only: initialize_default_hybrid_coefficients
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use forecast_grid_dimensions, only: grid_dimension_setup_values, initialize_grid_dimensions
  use forecast_geometry_configuration_text, only: read_grid_dimension_overrides, require_grid_configuration_group
  use forecast_spherical_grid_configuration,only:native_spherical_grid_configuration,initialize_regular_spherical_grid_configuration
  use vertical_configuration_port, only: native_vertical_configuration, initialize_vertical_configuration
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  use forecast_setup_text_reader, only: read_setup_text
  use forecast_geometry_state_types, only: native_geometry_state
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_selected_spherical_context, only: initialize_sugem1b_context, initialize_sugem2_context
  implicit none
  private
  public :: sugaw, sulega, sulap, alloc_init_tvab, sudefo_vv1, sudim, sugem_naml, sucver_geom, sugem1b, sugem2
  public :: md2asm_gaussian_native_count_get
  public :: md2asm_grid_dimension_native_count_get
  public :: md2asm_hybrid_coordinate_native_count_get
  public :: md2asm_default_hybrid_native_count_get
  public :: md2asm_serial_laplacian_native_count_get
  public :: md2asm_latitude_native_count_get
  public :: md2asm_spherical_geometry_configuration_native_count_get
  public :: md2asm_spherical_geometry_native_count_get
  public :: md2asm_spherical_grid_native_count_get
  public :: md2asm_vertical_configuration_native_count_get
  integer(c_int64_t), save :: entry_count(10) = 0_c_int64_t
  interface
    function setup_errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
    subroutine setup_abort() bind(C, name="abort")
    end subroutine
    subroutine setup_exit(status) bind(C, name="_exit")
      import c_int
      integer(c_int), value :: status
    end subroutine
  end interface
contains
  !> Advance one raw 64-bit counter with the source's wraparound rule.
  subroutine count_entry(index)
    integer, intent(in) :: index
    if (entry_count(index) == huge(0_c_int64_t)) then
      entry_count(index) = -huge(0_c_int64_t) - 1_c_int64_t
    else
      entry_count(index) = entry_count(index) + 1_c_int64_t
    end if
  end subroutine

  !> Construct the selected 32-row Gaussian grid after its independent PFN check.
 !! count/order/degree are dimensionless int32 inputs 32/0/32.
 !! pfn is a read-only contiguous matrix(0:32,0:32) with dimensionless coefficients.
 !! sines and weights are disjoint caller-owned contiguous FP64 arrays with at least 32 cells.
 !! The first 32 cells change; output tails and the unused optional panm remain unchanged.
 !! Each success advances only the Gaussian entry counter. Unsupported inputs abort.
  subroutine sugaw(count, order, degree, sines, weights, panm, pfn)
    integer(c_int32_t), intent(in) :: count, order, degree
    real(c_double), contiguous, intent(inout) :: sines(:), weights(:)
    real(c_double), contiguous, optional, intent(in) :: panm(:, :)
    real(c_double), contiguous, intent(in) :: pfn(0:, 0:)
    real(c_double) :: coefficients(0:16)
    integer(c_int) :: status
    integer :: j
    if (count /= 32 .or. order /= 0 .or. degree /= 32) call setup_abort()
    if (size(pfn, 1) /= 33 .or. size(pfn, 2) < 33) call setup_abort()
    if (size(sines) < 32 .or. size(weights) < 32) call setup_abort()
    call legendre_fourier_coefficients(coefficients)
    do j = 0, 16
      if (transfer(coefficients(j), 0_c_int64_t) /= transfer(pfn(32, 2*j), 0_c_int64_t)) call setup_abort()
    end do
    status = initialize_selected_gaussian_latitudes(sines(1:32), weights(1:32))
    if (status /= 0) call setup_abort()
    call count_entry(1)
  end subroutine

  !> Construct the selected latitude owner from actual dimensions and physical inputs.
 !! dimensions is read only. radius is 6371229 metres; pi has the frozen FP64 pi bits.
 !! state owns the nine new arrays; its incoming owners must be fresh.
 !! Only the source's 32-row, two-halo-row entry is admitted here.
  subroutine sulega(state, dimensions, radius, pi)
    type(native_latitude_geometry), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: dimensions
    real(c_double), intent(in) :: radius, pi
    integer(c_int) :: status
    if (dimensions%ndglg /= 32 .or. dimensions%ndgsur /= 2) call setup_abort()
    if (dimensions%ndgsag /= -1 .or. dimensions%ndgeng /= 34) call setup_abort()
    if (transfer(radius, 0_c_int64_t) /= int(z'41584de740000000', c_int64_t)) call setup_abort()
    if (transfer(pi, 0_c_int64_t) /= int(z'400921fb54442d18', c_int64_t)) call setup_abort()
    status = initialize_selected_latitude_geometry(state, radius)
    if (status /= 0) call setup_abort()
    call count_entry(6)
  end subroutine

  !> Construct the complete serial Laplacian owner through the fixed native child.
 !! dimensions is read only and supplies the truncation. radius uses metres.
 !! state acquires nine arrays in source order; the child releases partial owners on failure.
 !! The historical entry's supported truncation is 0:21 and radius 6371229 metres.
  subroutine sulap(state, dimensions, radius)
    type(native_laplacian_geometry), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: dimensions
    real(c_double), intent(in) :: radius
    integer(c_int) :: status
    if (dimensions%nsmax < 0 .or. dimensions%nsmax > 21) call setup_abort()
    status = initialize_serial_laplacian(state, dimensions, radius)
    if (status /= 0) call setup_abort()
    call count_entry(5)
  end subroutine

  !> Allocate and fill the source hybrid-coordinate I/O arrays.
 !! n is an input int32 layer count 0:256. Input a(0:n) and pressure use Pa.
 !! Input b(0:n) is dimensionless. The arrays are contiguous and disjoint from state.
 !! state owns eight new arrays; all other native state components stay unchanged.
 !! A refusal or allocation failure exits through the original status 121 path.
  subroutine alloc_init_tvab(n, a, b, state, pressure)
    integer(c_int32_t), intent(in) :: n
    real(c_double), contiguous, intent(in) :: a(0:), b(0:)
    type(native_vertical_state), intent(inout) :: state
    real(c_double), intent(in) :: pressure
    integer(c_int32_t) :: status
    status = initialize_hybrid_coordinate_storage(state, n, a, b, pressure)
    if (status /= 0) call setup_exit(121_c_int)
    call count_entry(3)
  end subroutine

  !> Publish the exact source default coefficients and reference pressure.
 !! ecmwf is an input canonical int32 switch. n is an input layer count.
 !! Caller-owned a(0:n),b(0:n) and pressure change only at the child's declared cells.
 !! A/pressure use Pa and B is dimensionless; the 137-layer arrays retain their incoming bytes.
 !! Supported branches and failure status 121 are the existing native child's contract.
  subroutine sudefo_vv1(ecmwf, n, a, b, pressure)
    integer(c_int32_t), intent(in) :: ecmwf, n
    real(c_double), contiguous, intent(inout) :: a(0:), b(0:)
    real(c_double), intent(inout) :: pressure
    integer(c_int) :: status
    if (n < 0 .or. ubound(a, 1) < n .or. ubound(b, 1) < n) call setup_exit(121_c_int)
    status = initialize_default_hybrid_coefficients(ecmwf, n, a(0:n), b(0:n), pressure)
    if (status /= 0) call setup_exit(121_c_int)
    call count_entry(4)
  end subroutine

  !> Read NAMDIM and construct dimensions from the actual live setup values.
 !! dimensions is the mutable canonical output. settings is the read-only named
 !! record of eleven source int32 controls. ecmwf=1 and limited_area=0 select
 !! the source route. Optional supersede overrides settings%supersede; only
 !! the value one selects that flag. Values and dimensions are dimensionless.
 !! The caller supplies real live controls; this entry creates no global defaults.
 !! Reading changes only local text. On success the source errno is zero and
 !! incoming floating-point status is restored before the integer constructor.
 !! A refused input exits with source status122; only this entry's count changes.
  subroutine sudim(dimensions, settings, ecmwf, limited_area, supersede)
    type(native_grid_dimensions), intent(inout) :: dimensions
    type(grid_dimension_setup_values), intent(in) :: settings
    integer(c_int32_t), intent(in) :: ecmwf, limited_area
    integer(c_int32_t), optional, intent(in) :: supersede
    type(grid_dimension_setup_values) :: selected
    type(ieee_status_type) :: incoming
    character(kind=c_char, len=:), allocatable, target :: text
    integer(c_int32_t) :: used, status, overrides(12), presence, chosen
    integer(c_int), pointer, volatile :: error_pointer
    call ieee_get_status(incoming)
    if (ecmwf /= 1 .or. limited_area /= 0) call setup_exit(122_c_int)
    selected = settings
    chosen = settings%supersede
    if (present(supersede)) chosen = supersede
    selected%supersede = merge(1_c_int32_t, 0_c_int32_t, chosen == 1)
    call c_f_pointer(setup_errno_address(), error_pointer)
    call read_setup_text(text, used, status)
    if (status /= 0) call fail_text_input(text, 122_c_int)
    overrides = 0; presence = 0
    status = read_grid_dimension_overrides(text(:used), overrides, presence)
    if (status /= 0) call fail_text_input(text, 122_c_int)
    deallocate (text)
    error_pointer = 0
    call ieee_set_status(incoming)
    status = initialize_grid_dimensions(dimensions, selected, overrides, presence)
    if (status /= 0) call setup_exit(122_c_int)
    call count_entry(2)
  end subroutine

  !> Read the selected NAMGEM group and construct its native row-length owners.
 !! dimensions is read only. state owns new nloen/nloeng integer arrays.
 !! ecmwf=1,limited_area=0,stretch_type=1,grid_type=0 select the original route.
 !! coordinates(3) holds pole sine, pole longitude in radians, and stretch.
 !! file_supersede is the actual NSUPERSEDE input; an optional explicit value
 !! takes its place. Only exact int32 one selects the supersede branch.
 !! Text remains a local read-only input until the genuine child's check ends.
 !! Cleanup preserves that child's resulting floating-point and errno state.
  subroutine sugem_naml(state, dimensions, ecmwf, limited_area, file_supersede, stretch_type, grid_type, coordinates, supersede)
    type(native_spherical_grid_configuration), intent(inout) :: state
    type(native_grid_dimensions), intent(in) :: dimensions
    integer(c_int32_t), intent(in) :: ecmwf, limited_area, file_supersede, stretch_type, grid_type
    real(c_double), intent(in) :: coordinates(3)
    integer(c_int32_t), optional, intent(in) :: supersede
    type(ieee_status_type) :: incoming, child_status
    character(kind=c_char, len=:), allocatable, target :: text
    integer(c_int32_t) :: used, status, chosen, selected
    integer(c_int), pointer, volatile :: error_pointer
    integer(c_int) :: child_errno
    call ieee_get_status(incoming)
    if (ecmwf /= 1 .or. limited_area /= 0) call setup_exit(123_c_int)
    if (stretch_type /= 1 .or. grid_type /= 0) call setup_exit(123_c_int)
    chosen = file_supersede
    if (present(supersede)) chosen = supersede
    selected = merge(1_c_int32_t, 0_c_int32_t, chosen == 1)
    call c_f_pointer(setup_errno_address(), error_pointer)
    call read_setup_text(text, used, status)
    if (status /= 0) call fail_text_input(text, 123_c_int)
    status = require_grid_configuration_group(text(:used), 0_c_int32_t)
    if (status /= 0) call fail_text_input(text, 123_c_int)
    error_pointer = 0
    call ieee_set_status(incoming)
    status = initialize_regular_spherical_grid_configuration(state, dimensions, selected, stretch_type, coordinates, text(:used))
    call ieee_get_status(child_status)
    child_errno = error_pointer
    deallocate (text)
    error_pointer = child_errno
    call ieee_set_status(child_status)
    if (status /= 0) call setup_exit(123_c_int)
    call count_entry(7)
  end subroutine

  !> Read empty NAMCVER and construct the native vertical configuration.
 !! output is the only mutable scientific record. ecmwf, nonhydrostatic and
 !! two_dimensional are input int32 logical words, each exactly zero or one.
 !! All fields are dimensionless. The child preserves source-unwritten fields.
 !! Input services are removed from the numerical status boundary before
 !! construction; successful source reading clears errno.
  subroutine sucver_geom(output, ecmwf, nonhydrostatic, two_dimensional)
    type(native_vertical_configuration), intent(inout) :: output
    integer(c_int32_t), intent(in) :: ecmwf, nonhydrostatic, two_dimensional
    type(ieee_status_type) :: incoming
    character(kind=c_char, len=:), allocatable, target :: text
    integer(c_int32_t) :: used, status
    integer(c_int), pointer, volatile :: error_pointer
    call ieee_get_status(incoming)
    if (ecmwf < 0 .or. ecmwf > 1 .or. nonhydrostatic < 0 .or. nonhydrostatic > 1) call setup_exit(121_c_int)
    if (two_dimensional < 0 .or. two_dimensional > 1) call setup_exit(121_c_int)
    call c_f_pointer(setup_errno_address(), error_pointer)
    call read_setup_text(text, used, status)
    if (status /= 0) call fail_text_input(text, 121_c_int)
    status = require_empty_physics_group(text(:used), 'NAMCVER')
    if (status /= 0) call fail_text_input(text, 121_c_int)
    deallocate (text)
    error_pointer = 0
    call ieee_set_status(incoming)
    status = initialize_vertical_configuration(output, ecmwf, nonhydrostatic, two_dimensional)
    if (status /= 0) call setup_exit(121_c_int)
    call count_entry(10)
  end subroutine

  !> Release only local input text before the source's terminating failure path.
  subroutine fail_text_input(text, code)
    character(kind=c_char, len=:), allocatable, target, intent(inout) :: text
    integer(c_int), intent(in) :: code
    if (allocated(text)) deallocate (text)
    call setup_exit(code)
  end subroutine

  !> Construct the selected local grid on the canonical live geometry owner.
 !! geometry is a mutable TARGET and owns every allocated numerical array.
 !! constants is read only, with radius in metres and pi dimensionless.
 !! mysetw and my_region_ew are actual one-based int32 process-map indices.
 !! Native allocation bounds replace private descriptor addresses. The full
 !! selected child checks, source abort, and private success counter remain.
  subroutine sugem1b(geometry, constants, mysetw, my_region_ew)
    type(native_geometry_state), target, intent(inout) :: geometry
    type(forecast_physical_constants), intent(in) :: constants
    integer(c_int32_t), intent(in) :: mysetw, my_region_ew
    integer(c_int) :: status
    status = initialize_sugem1b_context(geometry, constants, mysetw, my_region_ew)
    if (status /= 0) call setup_abort()
    call count_entry(9)
  end subroutine

  !> Construct all selected spherical owners at their final live geometry address.
 !! geometry is a mutable TARGET and must remain at this address while its
 !! borrowed blocked views remain live. constants is read only: radius uses
 !! metres, pi is dimensionless, and angular rotation uses radians per second.
 !! The selected 32-row by64-longitude scope, block width24, degree21, exact
 !! literal words and process-map guards are retained by the canonical helper.
 !! Failure aborts. Success advances only the spherical geometry entry counter.
  subroutine sugem2(geometry, constants, mysetw, my_region_ew)
    type(native_geometry_state), target, intent(inout) :: geometry
    type(forecast_physical_constants), intent(in) :: constants
    integer(c_int32_t), intent(in) :: mysetw, my_region_ew
    integer(c_int) :: status
    status = initialize_sugem2_context(geometry, constants, mysetw, my_region_ew)
    if (status /= 0) call setup_abort()
    call count_entry(8)
  end subroutine

  !> Return this entry's current raw 64-bit success count. No state changes.
  integer(c_int64_t) function md2asm_gaussian_native_count_get() bind(C, name='md2asm_gaussian_native_count_get') result(value)
    value = entry_count(1)
  end function

  !> Return this entry's current raw 64-bit success count. No state changes.
 integer(c_int64_t) function md2asm_grid_dimension_native_count_get() bind(C,name='md2asm_grid_dimension_native_count_get') result(value)
    value = entry_count(2)
  end function

  !> Return this entry's current raw 64-bit success count. No state changes.
 integer(c_int64_t) function md2asm_hybrid_coordinate_native_count_get() bind(C,name='md2asm_hybrid_coordinate_native_count_get') result(value)
    value = entry_count(3)
  end function

  !> Return this entry's current raw 64-bit success count. No state changes.
 integer(c_int64_t) function md2asm_default_hybrid_native_count_get() bind(C,name='md2asm_default_hybrid_native_count_get') result(value)
    value = entry_count(4)
  end function

  !> Return this entry's current raw 64-bit success count. No state changes.
 integer(c_int64_t) function md2asm_serial_laplacian_native_count_get() bind(C,name='md2asm_serial_laplacian_native_count_get') result(value)
    value = entry_count(5)
  end function

  !> Return this entry's current raw 64-bit success count. No state changes.
  integer(c_int64_t) function md2asm_latitude_native_count_get() bind(C, name='md2asm_latitude_native_count_get') result(value)
    value = entry_count(6)
  end function

  !> Return this entry's current raw 64-bit success count. No state changes.
 integer(c_int64_t) function md2asm_spherical_geometry_configuration_native_count_get() bind(C,name='md2asm_spherical_geometry_configuration_native_count_get') result(value)
    value = entry_count(7)
  end function

  !> Return this entry's current raw 64-bit success count. No state changes.
 integer(c_int64_t) function md2asm_spherical_geometry_native_count_get() bind(C,name='md2asm_spherical_geometry_native_count_get') result(value)
    value = entry_count(8)
  end function

  !> Return this entry's current raw 64-bit success count. No state changes.
 integer(c_int64_t) function md2asm_spherical_grid_native_count_get() bind(C,name='md2asm_spherical_grid_native_count_get') result(value)
    value = entry_count(9)
  end function

  !> Return this entry's current raw 64-bit success count. No state changes.
 integer(c_int64_t) function md2asm_vertical_configuration_native_count_get() bind(C,name='md2asm_vertical_configuration_native_count_get') result(value)
    value = entry_count(10)
  end function
end module forecast_native_setup_entries

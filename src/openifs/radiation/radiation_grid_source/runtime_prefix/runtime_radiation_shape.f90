!> Produce runtime radiation row shape and publish actual interpolation controls.
module forecast_runtime_radiation_shape
  use iso_fortran_env, only: int32, int64
  use iso_c_binding, only: c_ptr, c_int, c_loc, c_associated, c_null_ptr, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use yoerad, only: terad
  use forecast_grid_dimensions, only: native_grid_dimensions
  use forecast_native_radiation_grid, only: native_radiation_grid
  use forecast_interpolation_state_types, only: native_interpolation_state
  use selected_radiation_control_fields_mod, only: radiation_scalar_parameter_record
  use forecast_runtime_radiation_prefix_types, only: native_runtime_radiation_shape, native_runtime_radiation_prefix_context
  implicit none
  private
  public :: create_runtime_radiation_grid_shape, release_runtime_radiation_grid_shape
  public :: publish_runtime_radiation_interpolation_controls, create_runtime_radiation_grid_from_prefix
  interface
    function errno_address() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Allocate the two row owners, fill the complete source octahedral pattern,
 !! then publish the source resolution and grid scalars. Status2 is atomic
 !! refusal;1 releases an acquired first owner;0 completes both owners.
  integer(int32) function create_runtime_radiation_grid_shape(shape, g, dimensions, radiation) result(status)
    type(native_runtime_radiation_shape), target, intent(inout) :: shape
    type(native_radiation_grid), target, intent(inout) :: g
    type(native_grid_dimensions), intent(in) :: dimensions
    type(terad), intent(inout) :: radiation
    integer(int32), parameter :: halves(24) = [16, 32, 48, 64, 80, 96, 128, 160, 200, 256, 320, 400, &
                                               512, 640, 800, 912, 1024, 1280, 1600, 2000, 2560, 4000, 8000, -1]
    integer(int32), parameter :: resolutions(24) = [21, 21, 63, 63, 63, 63, 95, 159, 159, 159, 255, 319, &
                                                    399, 511, 799, 799, 799, 799, 1023, 1023, 2047, 2047, 2047, 0]
    integer(int32) :: resolution, n, j, k, half
    integer(int32), allocatable :: ordinary(:), halo(:)
    integer :: error
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: allocation_error
    status = 2
    if (dimensions%ndglg < 2 .or. dimensions%ndglg > 32768 .or. mod(dimensions%ndglg, 2) /= 0) return
    if (.not. radiation%lecompgrid) return
    if (radiation%nradint < 2 .or. radiation%nradint > 3) return
    if (allocated(shape%nrgri) .or. allocated(shape%nloeng) .or. associated(shape%grid)) return
    if (c_associated(shape%allocation_address(1)) .or. c_associated(shape%allocation_address(2))) return
    resolution = radiation%nradres
    if (resolution == 0) then
      half = dimensions%ndglg/2
      do k = 1, 24
        if (halves(k) == half) then
          resolution = resolutions(k)
          exit
        end if
      end do
      if (k > 24) return
    end if
    if (resolution < 1 .or. resolution > 8191 .or. mod(resolution, 2) /= 1) return
    if (resolution == dimensions%nsmax) return
    n = resolution + 1
    call c_f_pointer(errno_address(), system_error)
    allocate (ordinary(n), stat=error)
    if (error /= 0) then
      status = 1
      return
    end if
    allocate (halo(-1:n + 2), stat=error)
    if (error /= 0) then
      allocation_error = system_error
      deallocate (ordinary)
      system_error = allocation_error
      status = 1
      return
    end if
    do j = 0, n - 1
      ordinary(j + 1) = 20 + 4*min(j, n - 1 - j)
    end do
    do j = 1, n
      halo(j) = ordinary(j)
    end do
    halo(-1) = ordinary(2); halo(0) = ordinary(1)
    halo(n + 1) = ordinary(n); halo(n + 2) = ordinary(n - 1)
    call move_alloc(ordinary, shape%nrgri); call move_alloc(halo, shape%nloeng)
    radiation%nradres = resolution
    g%nsmax = 0
    g%ndlon = shape%nrgri(n/2)
    g%ndglg = n
    shape%global_first = -1; shape%global_last = n + 2; shape%polar_rows = 2
    shape%grid => g
    shape%allocation_address(1) = c_loc(shape%nrgri)
    shape%allocation_address(2) = c_loc(shape%nloeng)
    status = 0
  end function

  !> Release NLOENG then NRGRI after all transform/interpolation borrowers stop.
 !! Empty repeated release succeeds. Native bounds and saved base identities
 !! are checked before either free. Other source grid scalars are retained.
  integer(int32) function release_runtime_radiation_grid_shape(shape) result(status)
    type(native_runtime_radiation_shape), target, intent(inout) :: shape
    type(ieee_status_type) :: floating
    integer(c_int), pointer, volatile :: system_error
    integer(c_int) :: saved_error
    integer :: n
    status = 2
    if (.not. allocated(shape%nrgri) .and. .not. allocated(shape%nloeng)) then
      status = 0
      return
    end if
    if (.not. allocated(shape%nrgri) .or. .not. allocated(shape%nloeng) .or. .not. associated(shape%grid)) return
    n = shape%grid%ndglg
    if (n < 2 .or. n > 8192 .or. mod(n, 2) /= 0) return
    if (lbound(shape%nrgri, 1) /= 1 .or. ubound(shape%nrgri, 1) /= n) return
    if (lbound(shape%nloeng, 1) /= -1 .or. ubound(shape%nloeng, 1) /= n + 2) return
    if (.not. c_associated(c_loc(shape%nrgri), shape%allocation_address(1))) return
    if (.not. c_associated(c_loc(shape%nloeng), shape%allocation_address(2))) return
    call c_f_pointer(errno_address(), system_error)
    saved_error = system_error; call ieee_get_status(floating)
    deallocate (shape%nloeng); deallocate (shape%nrgri)
    shape%allocation_address = c_null_ptr
    nullify (shape%grid)
    call ieee_set_status(floating); system_error = saved_error
    status = 0
  end function

  !> Publish the ten genuine early controls, then reset both NASLB1 members
 !! in source order. Other namespace words and all RI/RO owners are preserved.
  integer(int32) function publish_runtime_radiation_interpolation_controls(scalars, ri, ro, radiation, leradi) result(status)
    type(radiation_scalar_parameter_record), intent(inout) :: scalars
    type(native_interpolation_state), intent(inout) :: ri, ro
    type(terad), intent(in) :: radiation
    logical, intent(in) :: leradi
    status = 2
    if (.not. leradi .or. .not. radiation%lecompgrid) return
    if (radiation%nradint < 2 .or. radiation%nradint > 3) return
    if (scalars%input_interpolation%nslwiden /= 0 .or. scalars%input_interpolation%nslwides /= 0) return
    if (scalars%input_interpolation%nslwidew /= 0 .or. scalars%input_interpolation%nslwidee /= 0) return
    if (scalars%output_interpolation%nslwiden /= 0 .or. scalars%output_interpolation%nslwides /= 0) return
    if (scalars%output_interpolation%nslwidew /= 0 .or. scalars%output_interpolation%nslwidee /= 0) return
    if (.not. scalars%input_interpolation%lslondem .or. .not. scalars%output_interpolation%lslondem) return
    ri%nslwiden = scalars%input_interpolation%nslwiden
    ri%nslwides = scalars%input_interpolation%nslwides
    ri%nslwidew = scalars%input_interpolation%nslwidew
    ri%nslwidee = scalars%input_interpolation%nslwidee
    ro%nslwiden = scalars%output_interpolation%nslwiden
    ro%nslwides = scalars%output_interpolation%nslwides
    ro%nslwidew = scalars%output_interpolation%nslwidew
    ro%nslwidee = scalars%output_interpolation%nslwidee
    ri%lslondem = scalars%input_interpolation%lslondem
    ro%lslondem = scalars%output_interpolation%lslondem
    ri%naslb1 = 0; ro%naslb1 = 0
    scalars%input_interpolation%naslb1 = 0; scalars%output_interpolation%naslb1 = 0
    status = 0
  end function

  !> Keep early interpolation publications even when the following shape fails.
  integer(int32) function create_runtime_radiation_grid_from_prefix(context) result(status)
    type(native_runtime_radiation_prefix_context), intent(in) :: context
    status = 2
    if (.not. associated(context%setup) .or. .not. associated(context%upstream)) return
    if (.not. associated(context%ri) .or. .not. associated(context%ro)) return
    if (.not. associated(context%dimensions) .or. .not. associated(context%shape) .or. .not. associated(context%grid)) return
    status = publish_runtime_radiation_interpolation_controls(context%setup%scalars, context%ri, context%ro, &
                                                              context%setup%radiation, context%upstream%leradi)
    if (status /= 0) return
    status = create_runtime_radiation_grid_shape(context%shape, context%grid, context%dimensions, context%setup%radiation)
  end function
end module forecast_runtime_radiation_shape

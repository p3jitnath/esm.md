!> Read selected GRIB metadata without a field calculation or original global.
!! Angles are radians; hybrid A is Pa and hybrid B is dimensionless.
!! The declared arrays have logical bounds latitude(-1:34),A(0:19),B(0:19).
!! Scalar controls belong to the caller and remain unchanged.
module forecast_selected_grib_metadata
  use iso_c_binding, only: c_int64_t, c_double, c_char, c_null_char
  use iso_fortran_env, only: int32, int64, real64
  use forecast_model_clock_port, only: forecast_clock
  implicit none
  private
  public :: selected_grib_output_metadata, selected_grib_output_controls, read_grib_output_metadata
  type :: selected_grib_output_controls
    integer(int32) :: nstepini = 0, nlocgrb = 1, nstream = 1025, ncycle = 0
    logical :: lobsc1 = .false., lvareps = .false.
    character(2) :: ctype = 'fc', cfclass = 'rd'
    character(4) :: cnmexp
  end type
  type, bind(c) :: selected_grib_output_metadata
    integer(c_int64_t) :: date, time, cycle, local_definition, stream
    integer(c_int64_t) :: truncation, latitude_rows, longitudes, levels, reserved_word
    integer(c_int64_t) :: spectral_type
    real(c_double) :: stretch, first_latitude, last_latitude
    character(c_char) :: forecast_type(8), classification(8), experiment(8)
    integer(c_int64_t) :: reserved_header
    real(c_double) :: hybrid_a(0:19), hybrid_b(0:19)
    integer(c_int64_t) :: reserved_tail(6)
  end type
contains
  !> Commit the complete named512-byte metadata record only after all selected guards pass.
  integer(int32) function read_grib_output_metadata(nlat, nlon, truncation, nlev, npoints, grid_type, spectral_type, &
                                                    stretch, latitude, a, b, clock, controls, output) result(status)
    integer(int32), intent(in) :: nlat, nlon, truncation, nlev, npoints, grid_type, spectral_type
    real(real64), intent(in) :: stretch, latitude(-1:), a(0:), b(0:)
    type(forecast_clock), intent(in) :: clock
    type(selected_grib_output_controls), intent(in) :: controls
    type(selected_grib_output_metadata), intent(inout) :: output
    type(selected_grib_output_metadata) :: work
    integer :: k, hour
    status = 2
    if (nlat /= 32 .or. nlon /= 64 .or. truncation /= 21 .or. nlev /= 19 .or. npoints /= 2048) return
    if (grid_type /= 0 .or. spectral_type < 0 .or. spectral_type > 1) return
    if (transfer(stretch, 0_int64) /= int(z'3FF0000000000000', int64)) return
    if (size(latitude) /= 36 .or. size(a) /= 20 .or. size(b) /= 20) return
    if (.not. is_contiguous(latitude) .or. .not. is_contiguous(a) .or. .not. is_contiguous(b)) return
    if (controls%nstepini /= 0 .or. controls%lobsc1 .or. controls%lvareps) return
    if (controls%nlocgrb /= 1 .or. controls%nstream /= 1025) return
    if (controls%ctype /= 'fc' .or. controls%cfclass /= 'rd') return
    if (clock%initial_seconds < 0 .or. mod(clock%initial_seconds, 3600) /= 0) return
    hour = clock%initial_seconds/3600
    if (hour > 23) return
    work%date = clock%initial_date
    work%time = hour*100
    work%cycle = controls%ncycle
    work%local_definition = controls%nlocgrb
    work%stream = controls%nstream
    work%truncation = truncation
    work%latitude_rows = nlat
    work%longitudes = nlon
    work%levels = nlev
    work%reserved_word = 0
    work%spectral_type = spectral_type
    work%stretch = stretch
    work%first_latitude = latitude(1)
    work%last_latitude = latitude(32)
    work%forecast_type = c_null_char
    work%classification = c_null_char
    work%experiment = c_null_char
    do k = 1, 2
      work%forecast_type(k) = controls%ctype(k:k)
      work%classification(k) = controls%cfclass(k:k)
    end do
    do k = 1, 4
      work%experiment(k) = controls%cnmexp(k:k)
    end do
    work%reserved_header = 0
    do k = 0, 19
      work%hybrid_a(k) = a(k)
      work%hybrid_b(k) = b(k)
    end do
    work%reserved_tail = 0
    output = work
    status = 0
  end function
end module forecast_selected_grib_metadata

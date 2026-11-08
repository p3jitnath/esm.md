!> Read and own the selected radiation climate data through public NetCDF.
module native_radiation_climate_setup
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_char, c_null_char, c_int, c_size_t, c_ptr, c_loc
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, &
                             ieee_get_underflow_mode, ieee_support_underflow_control, operator(/=)
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  use native_radiation_climate_records, only: radiation_climate_context
  use native_radiation_climate_calculations, only: &
    initialize_radiation_climatology_means, initialize_radiation_gas_coordinates
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: create_radiation_climate_context, release_radiation_climate_context
  interface
    integer(c_int) function nc_open(path, mode, ncid) bind(C, name='nc_open')
      import c_int, c_char
      character(c_char), intent(in) :: path(*)
      integer(c_int), value :: mode
      integer(c_int), intent(out) :: ncid
    end function
    integer(c_int) function nc_close(ncid) bind(C, name='nc_close')
      import c_int
      integer(c_int), value :: ncid
    end function
    integer(c_int) function nc_inq_varid(ncid, name, varid) bind(C, name='nc_inq_varid')
      import c_int, c_char
      integer(c_int), value :: ncid
      character(c_char), intent(in) :: name(*)
      integer(c_int), intent(out) :: varid
    end function
    integer(c_int) function nc_inq_varndims(ncid, varid, rank) bind(C, name='nc_inq_varndims')
      import c_int
      integer(c_int), value :: ncid, varid
      integer(c_int), intent(out) :: rank
    end function
    integer(c_int) function nc_inq_vardimid(ncid, varid, dimensions) bind(C, name='nc_inq_vardimid')
      import c_int
      integer(c_int), value :: ncid, varid
      integer(c_int), intent(out) :: dimensions(*)
    end function
    integer(c_int) function nc_inq_dimlen(ncid, dimension, length) bind(C, name='nc_inq_dimlen')
      import c_int, c_size_t
      integer(c_int), value :: ncid, dimension
      integer(c_size_t), intent(out) :: length
    end function
    integer(c_int) function nc_get_var_double(ncid, varid, values) bind(C, name='nc_get_var_double')
      import c_int, c_ptr
      integer(c_int), value :: ncid, varid
      type(c_ptr), value :: values
    end function
  end interface
contains
  !> Create one private context, then publish all four native records together.
  !! OWNER is an unallocated caller-owned native context on entry. PATHS(3)
  !! names the solar file, monthly gas file and gas time series, in that order.
  !! PATH_LENGTHS(3) is int64, with each length in1:511 and no zero byte in the
  !! consumed path. Trailing path storage is not consumed. CONSTANTS supplies
  !! the accepted dimensionless pi value. Inputs are readonly and separate
  !! from OWNER. The supported source data have450 solar years,2501 gas years,
  !! and64 latitudes by91 pressures by12 months. Pressures use Pa, latitude
  !! uses degrees, solar irradiance uses W/m^2, and gas fractions are mol/mol.
  !! The compiler owns every type and array descriptor. Public NetCDF C calls
  !! read each native contiguous array after its complete shape is checked.
  !! Each file closes before its following numerical stage. Thirty-two array
  !! owners and one outer context allocate in source order; their bytes are
  !! not initialized where the source leaves them unwritten.
  !! Return0 after commit,1 for allocation failure,2 for an unsupported input,
  !! or3 for a file/schema error. Failure leaves OWNER unallocated and frees
  !! every successful private allocation. Nearest rounding and gradual
  !! underflow are required. Numerical children retain natural status.
  integer(int32) function create_radiation_climate_context(owner, paths, path_lengths, constants) result(status)
    type(radiation_climate_context), allocatable, intent(inout) :: owner
    character(len=*), intent(in) :: paths(3)
    integer(int64), intent(in) :: path_lengths(3)
    type(forecast_physical_constants), intent(in) :: constants
    type(radiation_climate_context), allocatable :: staged
    type(ieee_round_type) :: rounding
    integer(c_int) :: ncid, code
    integer :: file, position, allocation_status
    logical :: gradual
    status = 2_int32
    if (allocated(owner)) return
    if (transfer(constants%rpi, 0_int64) /= int(z'400921fb54442d18', int64)) return
    do file = 1, 3
      if (path_lengths(file) < 1 .or. path_lengths(file) > 511) return
      if (path_lengths(file) > len(paths)) return
      do position = 1, int(path_lengths(file))
        if (paths(file) (position:position) == achar(0)) return
      end do
    end do
    if (.not. supported_floating_mode()) return
    status = 1_int32
    ncid = -1_c_int
    allocate (staged, stat=allocation_status)
    if (allocation_status /= 0) return
    status = open_selected_file(paths(1), int(path_lengths(1)), ncid)
    if (status /= 0) goto900
    status = read_vector(ncid, 'time', 450, staged%solar%ryear, .false.)
    if (status /= 0) goto900
    status = read_vector(ncid, 'tsi', 450, staged%solar%rtsi, .false.)
    if (status /= 0) goto900
    code = nc_close(ncid); ncid = -1_c_int
    if (code /= 0) then
      status = 3_int32; goto900
    end if
    staged%solar%ntime = 450_int32
    status = open_selected_file(paths(2), int(path_lengths(2)), ncid)
    if (status /= 0) goto900
    status = read_vector(ncid, 'pressure', 91, staged%climatology%pressure, .false.)
    if (status /= 0) goto900
    status = read_vector(ncid, 'latitude', 64, staged%climatology%latitude, .false.)
    if (status /= 0) goto900
    status = read_monthly(ncid, 'co2_vmr', staged%climatology%vmr_co2)
    if (status /= 0) goto900
    status = read_monthly(ncid, 'ch4_vmr', staged%climatology%vmr_ch4)
    if (status /= 0) goto900
    status = read_monthly(ncid, 'n2o_vmr', staged%climatology%vmr_n2o)
    if (status /= 0) goto900
    status = read_monthly(ncid, 'cfc11_vmr', staged%climatology%vmr_cfc11)
    if (status /= 0) goto900
    status = read_monthly(ncid, 'cfc12_vmr', staged%climatology%vmr_cfc12)
    if (status /= 0) goto900
    status = read_monthly(ncid, 'o3_vmr', staged%climatology%vmr_o3)
    if (status /= 0) goto900
    status = read_monthly(ncid, 'hcfc22_vmr', staged%climatology%vmr_hcfc22)
    if (status /= 0) goto900
    status = read_monthly(ncid, 'ccl4_vmr', staged%climatology%vmr_ccl4)
    if (status /= 0) goto900
    allocate (staged%climatology%vmr_no2(64, 91, 12), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    staged%climatology%vmr_no2 = 0.0_real64
    code = nc_close(ncid); ncid = -1_c_int
    if (code /= 0) then
      status = 3_int32; goto900
    end if
    staged%climatology%npressure = 91_int32
    staged%climatology%nlatitude = 64_int32
    call initialize_radiation_climatology_means(staged%climatology, constants%rpi)
    status = open_selected_file(paths(3), int(path_lengths(3)), ncid)
    if (status /= 0) goto900
    status = read_vector(ncid, 'time', 2501, staged%timeseries%ryear, .false.)
    if (status /= 0) goto900
    status = read_vector(ncid, 'co2_vmr', 2501, staged%timeseries%vmr_co2, .false.)
    if (status /= 0) goto900
    status = read_vector(ncid, 'ch4_vmr', 2501, staged%timeseries%vmr_ch4, .false.)
    if (status /= 0) goto900
    status = read_vector(ncid, 'n2o_vmr', 2501, staged%timeseries%vmr_n2o, .false.)
    if (status /= 0) goto900
    status = read_vector(ncid, 'cfc11_vmr', 2501, staged%timeseries%vmr_cfc11, .false.)
    if (status /= 0) goto900
    status = read_vector(ncid, 'cfc12_vmr', 2501, staged%timeseries%vmr_cfc12, .false.)
    if (status /= 0) goto900
    status = read_vector(ncid, 'hcfc22_vmr', 2501, staged%timeseries%vmr_hcfc22, .true.)
    if (status /= 0) goto900
    status = read_vector(ncid, 'ccl4_vmr', 2501, staged%timeseries%vmr_ccl4, .true.)
    if (status /= 0) goto900
    code = nc_close(ncid); ncid = -1_c_int
    if (code /= 0) then
      status = 3_int32; goto900
    end if
    staged%timeseries%ntime = 2501_int32
    allocate (staged%radiation%sinlat(64), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    allocate (staged%radiation%pressure_hl(0:91), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    allocate (staged%radiation%mass_ch4(64, 91), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    allocate (staged%radiation%mass_co2(64, 91), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    allocate (staged%radiation%mass_n2o(64, 91), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    allocate (staged%radiation%mass_no2(64, 91), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    allocate (staged%radiation%mass_cfc11(64, 91), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    allocate (staged%radiation%mass_cfc12(64, 91), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    allocate (staged%radiation%mass_ccl4(64, 91), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    allocate (staged%radiation%mass_hcfc22(64, 91), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    allocate (staged%radiation%mass_o3(64, 91), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; goto900
    end if
    staged%radiation%nlatitude = 64_int32
    staged%radiation%npressure = 91_int32
    call initialize_radiation_gas_coordinates(staged%radiation, staged%climatology, constants%rpi)
    call move_alloc(staged, owner)
    status = 0_int32
    return
900 continue
    if (ncid /= -1_c_int) code = nc_close(ncid)
    call free_context_arrays(staged)
    deallocate (staged)
  end function

  !> Release only this context's32 arrays, then its outer owner.
  !! OWNER is caller-owned INOUT. An already unallocated owner returns0.
  !! No address is retained. Source allocation order is also release order.
  integer(int32) function release_radiation_climate_context(owner) result(status)
    type(radiation_climate_context), allocatable, intent(inout) :: owner
    if (allocated(owner)) then
      call free_context_arrays(owner)
      deallocate (owner)
    end if
    status = 0_int32
  end function

  integer(int32) function open_selected_file(path, length, ncid) result(status)
    character(len=*), intent(in) :: path
    integer, intent(in) :: length
    integer(c_int), intent(out) :: ncid
    character(c_char) :: cpath(512)
    integer :: position
    cpath = c_null_char
    do position = 1, length
      cpath(position) = path(position:position)
    end do
    status = 3_int32
    if (nc_open(cpath, 0_c_int, ncid) == 0_c_int) status = 0_int32
  end function

  !> Check a complete C file shape before any payload allocation or read.
  !! EXPECTED lists native Fortran extents; C dimensions have reverse order.
  !! OPTIONAL_ZERO permits only NC_ENOTVAR, not an arbitrary file failure.
  integer(int32) function inspect_variable(ncid, name, expected, varid, optional_zero, missing) result(status)
    integer(c_int), intent(in) :: ncid
    character(len=*), intent(in) :: name
    integer, intent(in) :: expected(:)
    integer(c_int), intent(out) :: varid
    logical, intent(in) :: optional_zero
    logical, intent(out) :: missing
    character(c_char) :: cname(64)
    integer(c_int) :: code, rank, dimensions(3)
    integer(c_size_t) :: length
    integer :: position
    status = 3_int32; missing = .false.
    if (len(name) > 63 .or. size(expected) < 1 .or. size(expected) > 3) return
    cname = c_null_char
    do position = 1, len(name)
      cname(position) = name(position:position)
    end do
    code = nc_inq_varid(ncid, cname, varid)
    if (code /= -49_c_int) then
      if (code /= 0_c_int) return
    else
      if (.not. optional_zero) return
      missing = .true.; status = 0_int32
      return
    end if
    if (nc_inq_varndims(ncid, varid, rank) /= 0_c_int) return
    if (rank /= size(expected)) return
    if (nc_inq_vardimid(ncid, varid, dimensions) /= 0_c_int) return
    do position = 1, rank
      if (nc_inq_dimlen(ncid, dimensions(position), length) /= 0_c_int) return
      if (length /= int(expected(rank - position + 1), c_size_t)) return
    end do
    status = 0_int32
  end function

  integer(int32) function read_vector(ncid, name, length, output, optional_zero) result(status)
    integer(c_int), intent(in) :: ncid
    character(len=*), intent(in) :: name
    integer, intent(in) :: length
    real(real64), allocatable, target, intent(inout) :: output(:)
    logical, intent(in) :: optional_zero
    integer(c_int) :: varid
    integer :: allocation_status
    logical :: missing
    status = inspect_variable(ncid, name, [length], varid, optional_zero, missing)
    if (status /= 0) return
    allocate (output(length), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; return
    end if
    if (missing) then
      output = 0.0_real64
    else
      if (nc_get_var_double(ncid, varid, c_loc(output(1))) /= 0_c_int) status = 3_int32
    end if
  end function

  integer(int32) function read_monthly(ncid, name, output) result(status)
    integer(c_int), intent(in) :: ncid
    character(len=*), intent(in) :: name
    real(real64), allocatable, target, intent(inout) :: output(:, :, :)
    integer(c_int) :: varid
    integer :: allocation_status
    logical :: missing
    status = inspect_variable(ncid, name, [64, 91, 12], varid, .false., missing)
    if (status /= 0) return
    allocate (output(64, 91, 12), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1_int32; return
    end if
    if (nc_get_var_double(ncid, varid, c_loc(output(1, 1, 1))) /= 0_c_int) status = 3_int32
  end function

  subroutine free_context_arrays(owner)
    type(radiation_climate_context), intent(inout) :: owner
    if (allocated(owner%solar%ryear)) deallocate (owner%solar%ryear)
    if (allocated(owner%solar%rtsi)) deallocate (owner%solar%rtsi)
    if (allocated(owner%climatology%pressure)) deallocate (owner%climatology%pressure)
    if (allocated(owner%climatology%latitude)) deallocate (owner%climatology%latitude)
    if (allocated(owner%climatology%vmr_co2)) deallocate (owner%climatology%vmr_co2)
    if (allocated(owner%climatology%vmr_ch4)) deallocate (owner%climatology%vmr_ch4)
    if (allocated(owner%climatology%vmr_n2o)) deallocate (owner%climatology%vmr_n2o)
    if (allocated(owner%climatology%vmr_cfc11)) deallocate (owner%climatology%vmr_cfc11)
    if (allocated(owner%climatology%vmr_cfc12)) deallocate (owner%climatology%vmr_cfc12)
    if (allocated(owner%climatology%vmr_o3)) deallocate (owner%climatology%vmr_o3)
    if (allocated(owner%climatology%vmr_hcfc22)) deallocate (owner%climatology%vmr_hcfc22)
    if (allocated(owner%climatology%vmr_ccl4)) deallocate (owner%climatology%vmr_ccl4)
    if (allocated(owner%climatology%vmr_no2)) deallocate (owner%climatology%vmr_no2)
    if (allocated(owner%timeseries%ryear)) deallocate (owner%timeseries%ryear)
    if (allocated(owner%timeseries%vmr_co2)) deallocate (owner%timeseries%vmr_co2)
    if (allocated(owner%timeseries%vmr_ch4)) deallocate (owner%timeseries%vmr_ch4)
    if (allocated(owner%timeseries%vmr_n2o)) deallocate (owner%timeseries%vmr_n2o)
    if (allocated(owner%timeseries%vmr_cfc11)) deallocate (owner%timeseries%vmr_cfc11)
    if (allocated(owner%timeseries%vmr_cfc12)) deallocate (owner%timeseries%vmr_cfc12)
    if (allocated(owner%timeseries%vmr_hcfc22)) deallocate (owner%timeseries%vmr_hcfc22)
    if (allocated(owner%timeseries%vmr_ccl4)) deallocate (owner%timeseries%vmr_ccl4)
    if (allocated(owner%radiation%sinlat)) deallocate (owner%radiation%sinlat)
    if (allocated(owner%radiation%pressure_hl)) deallocate (owner%radiation%pressure_hl)
    if (allocated(owner%radiation%mass_ch4)) deallocate (owner%radiation%mass_ch4)
    if (allocated(owner%radiation%mass_co2)) deallocate (owner%radiation%mass_co2)
    if (allocated(owner%radiation%mass_n2o)) deallocate (owner%radiation%mass_n2o)
    if (allocated(owner%radiation%mass_no2)) deallocate (owner%radiation%mass_no2)
    if (allocated(owner%radiation%mass_cfc11)) deallocate (owner%radiation%mass_cfc11)
    if (allocated(owner%radiation%mass_cfc12)) deallocate (owner%radiation%mass_cfc12)
    if (allocated(owner%radiation%mass_ccl4)) deallocate (owner%radiation%mass_ccl4)
    if (allocated(owner%radiation%mass_hcfc22)) deallocate (owner%radiation%mass_hcfc22)
    if (allocated(owner%radiation%mass_o3)) deallocate (owner%radiation%mass_o3)
  end subroutine
  !> Admit gradual underflow through the supported runtime query or exact probe.
  !! The fallback matches the qualified native guard. It preserves incoming
  !! underflow and inexact flags while checking one volatile exact product.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    logical :: gradual, incoming_underflow, incoming_inexact
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      supported = gradual
    else
      call ieee_get_flag(ieee_underflow, incoming_underflow)
      call ieee_get_flag(ieee_inexact, incoming_inexact)
      minimum_normal = tiny(0.0_real64)
      half_value = 0.5_real64
      subnormal_probe = minimum_normal*half_value
      supported = transfer(subnormal_probe, 0_int64) == ibset(0_int64, 51)
      call ieee_set_flag(ieee_underflow, incoming_underflow)
      call ieee_set_flag(ieee_inexact, incoming_inexact)
    end if
  end function supported_floating_mode
end module native_radiation_climate_setup

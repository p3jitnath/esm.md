!> Select the complete runtime-prefix climate defaults and actual DATA paths.
!! Source NAERAD parsing is integer/character work. No climate payload is read.
module forecast_runtime_radiation_climate_prefix
  use iso_fortran_env, only: int32, int64
  use radiation_climate_selection_port, only: radiation_climate_selection_record, radiation_climate_upstream_record
  use forecast_runtime_radiation_owner_namelist, only: apply_radiation_owner_namelist
  implicit none
  private
  public :: select_runtime_radiation_prefix_climate
  public :: select_prefix_climate_from_directory
contains
  !> Read the actual public DATA environment, then perform the source selection.
 !! OUTPUT changes only when parsing, environment bounds and all paths pass.
 !! Missing/empty DATA gives direct names; no fallback directory is invented.
  integer(int32) function select_runtime_radiation_prefix_climate(text, upstream, output) result(status)
    character(len=*), intent(in) :: text
    type(radiation_climate_upstream_record), intent(in) :: upstream
    type(radiation_climate_selection_record), intent(inout) :: output
    character(len=512) :: data_directory
    integer :: length, error
    status = 2_int32
    call get_environment_variable('DATA', length=length, status=error)
    if (error /= 0 .and. error /= 1) return
    if (length < 0 .or. length > 512) return
    data_directory = ''
    if (error == 0 .and. length > 0) then
      call get_environment_variable('DATA', value=data_directory, status=error)
      if (error /= 0) return
    end if
    status = select_prefix_climate_from_directory(text, data_directory, upstream, output)
  end function
  !> Consume the actual bounded DATA value when the enclosing caller owns it.
 !! This shared body is complete; it introduces no scientific default.
  integer(int32) function select_prefix_climate_from_directory(text, data_directory, upstream, output) result(status)
    character(len=*), intent(in) :: text, data_directory
    type(radiation_climate_upstream_record), intent(in) :: upstream
    type(radiation_climate_selection_record), intent(inout) :: output
    type(radiation_climate_selection_record) :: staged
    integer(int32) :: parse_status, default_nrproma
    integer :: file_index, scenario, name_length, data_length, path_length
    character(len=256) :: names(3)
    character(len=80), parameter :: series_names(11) = [character(len=80) :: &
                                                        'greenhouse_gas_timeseries_CMIP3_A1B_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP3_A2_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP3_B1_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP5_RCP3PD_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP5_RCP45_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP5_RCP6_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP5_RCP85_46r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP6_SSP126_CFC11equiv_47r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP6_SSP245_CFC11equiv_47r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP6_SSP370_CFC11equiv_47r1.nc', &
                                                        'greenhouse_gas_timeseries_CMIP6_SSP585_CFC11equiv_47r1.nc']
    status = 2_int32
    if (len(data_directory) > 512) return
    if (index(data_directory, achar(0)) /= 0) return
    staged%values%lhghg = upstream%lephys .and. .not. upstream%larpegef
    staged%values%nhincsol = merge(4_int32, 0_int32, staged%values%lhghg)
    staged%values%nghgcmip = merge(6_int32, 0_int32, staged%values%lhghg)
    staged%values%nghgrad = -1_int32
    staged%values%nrcp = 3_int32
    staged%values%nscen = 1_int32
    staged%values%laer3d = .true.
    staged%values%lepo3ra = upstream%ozone_lgp
    default_nrproma = merge(-8_int32, 511_int32, upstream%lopt_scalar)
    staged%values%nrproma = default_nrproma
    staged%values%lapproxlwupdate = .true.
    staged%values%lecompgrid = .false.
    staged%values%lsrtm = .true.
    staged%values%csolarirradiancefile = ''
    staged%values%cghgclimfile = ''
    staged%values%cghgtimeseriesfile = ''
    staged%crtabledir = './'
    staged%paths = repeat(achar(0), 512)
    staged%path_lengths = 0_int64
    parse_status = apply_radiation_owner_namelist(text, staged)
    if (parse_status /= 0_int32) return
    if (staged%values%nghgrad < 0) then
      if ((upstream%lephys .and. .not. upstream%larpegef) .or. upstream%lrayfm) then
        staged%values%nghgrad = merge(20_int32, 21_int32, staged%values%lepo3ra)
      else
        staged%values%nghgrad = 0_int32
      end if
    end if
    if (staged%values%nrproma == 0) staged%values%nrproma = default_nrproma
    staged%values%nrproma = abs(staged%values%nrproma)
    if (staged%values%csolarirradiancefile == '') &
      staged%values%csolarirradiancefile = 'total_solar_irradiance_CMIP6_47r1.nc'
    if (staged%values%cghgclimfile == '') staged%values%cghgclimfile = 'greenhouse_gas_climatology_48r1.nc'
    if (staged%values%cghgtimeseriesfile == '') then
      select case (staged%values%nghgcmip)
      case (0)
        if (staged%values%nscen < 1 .or. staged%values%nscen > 3) return
        scenario = staged%values%nscen
      case (5, 6)
        if (staged%values%nrcp < 1 .or. staged%values%nrcp > 4) return
        scenario = merge(3, 7, staged%values%nghgcmip == 5) + staged%values%nrcp
      case default
        return
      end select
      staged%values%cghgtimeseriesfile = trim(series_names(scenario))
    end if
    names = [staged%values%csolarirradiancefile, staged%values%cghgclimfile, staged%values%cghgtimeseriesfile]
    data_length = len_trim(data_directory)
    do file_index = 1, 3
      name_length = len_trim(names(file_index))
      if (name_length < 1) return
      if (names(file_index) (1:1) == '.' .or. names(file_index) (1:1) == '/' .or. data_length == 0) then
        path_length = name_length
        staged%paths(file_index) (:path_length) = names(file_index) (:name_length)
      else
        path_length = data_length + 9 + name_length
        if (path_length > 511) return
        staged%paths(file_index) (:data_length) = data_directory(:data_length)
        staged%paths(file_index) (data_length + 1:data_length + 9) = '/ifsdata/'
        staged%paths(file_index) (data_length + 10:path_length) = names(file_index) (:name_length)
      end if
      staged%path_lengths(file_index) = int(path_length, int64)
    end do
    output = staged
    status = 0_int32
  end function
end module forecast_runtime_radiation_climate_prefix

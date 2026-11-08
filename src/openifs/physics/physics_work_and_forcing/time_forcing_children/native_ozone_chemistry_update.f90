! (C) Copyright 1989- ECMWF and Meteo-France. Apache-2.0.
!> Read and interpolate the original monthly ozone chemistry coefficient files.
!! All scientific storage is the caller's actual TOZO owner. The only model
!! temporal input is the canonical forecast_clock. Public Fortran I/O and FIAT
!! broadcast supply file/message services, with no original weather method.
module forecast_native_ozone_chemistry_update
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use yomozo, only: TOZO
  use yoephy, only: TEPHY
  use yomdphy, only: TDPHY
  use forecast_model_clock_port, only: forecast_clock
  use forecast_dynamics_control_defaults, only: native_dynamics_controls
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status
  use forecast_calendar_and_monthly_fields, only: update_calendar
  use mpl_module, only: mpl_broadcast
  implicit none
  private
  public :: initialize_ozone_chemistry_global_storage, update_native_ozone_chemistry
  real(real64), parameter :: chlorine(1950:2100) = [ &
                             681.60_real64, 690.98_real64, 700.36_real64, 709.74_real64, 719.12_real64, &
                             728.50_real64, 741.92_real64, 755.34_real64, 768.76_real64, 782.18_real64, &
                             795.60_real64, 822.52_real64, 849.44_real64, 876.36_real64, 903.28_real64, &
                             930.20_real64, 988.44_real64, 1046.68_real64, 1104.92_real64, 1163.16_real64, &
                             1221.40_real64, 1327.18_real64, 1432.96_real64, 1538.74_real64, 1644.52_real64, &
                             1750.30_real64, 1867.36_real64, 1984.42_real64, 2101.48_real64, 2218.54_real64, &
                             2335.60_real64, 2431.50_real64, 2527.40_real64, 2623.30_real64, 2719.20_real64, &
                             2815.10_real64, 2925.90_real64, 3036.70_real64, 3147.50_real64, 3258.30_real64, &
                             3369.10_real64, 3405.96_real64, 3442.82_real64, 3479.68_real64, 3516.54_real64, &
                             3553.40_real64, 3522.72_real64, 3492.04_real64, 3461.36_real64, 3430.68_real64, &
                             3400.00_real64, 3390.34_real64, 3380.68_real64, 3371.02_real64, 3361.36_real64, &
                             3351.70_real64, 3338.02_real64, 3324.34_real64, 3310.66_real64, 3296.98_real64, &
                             3283.30_real64, 3256.12_real64, 3228.94_real64, 3201.76_real64, 3174.58_real64, &
                             3147.40_real64, 3109.38_real64, 3071.36_real64, 3033.34_real64, 2995.32_real64, &
                             2957.30_real64, 2916.84_real64, 2876.38_real64, 2835.92_real64, 2795.46_real64, &
                             2755.00_real64, 2718.30_real64, 2681.60_real64, 2644.90_real64, 2608.20_real64, &
                             2571.50_real64, 2539.44_real64, 2507.38_real64, 2475.32_real64, 2443.26_real64, &
                             2411.20_real64, 2383.30_real64, 2355.40_real64, 2327.50_real64, 2299.60_real64, &
                             2271.70_real64, 2245.00_real64, 2218.30_real64, 2191.60_real64, 2164.90_real64, &
                             2138.20_real64, 2112.82_real64, 2087.44_real64, 2062.06_real64, 2036.68_real64, &
                             2011.30_real64, 1989.00_real64, 1966.70_real64, 1944.40_real64, 1922.10_real64, &
                             1899.80_real64, 1880.02_real64, 1860.24_real64, 1840.46_real64, 1820.68_real64, &
                             1800.90_real64, 1783.34_real64, 1765.78_real64, 1748.22_real64, 1730.66_real64, &
                             1713.10_real64, 1697.36_real64, 1681.62_real64, 1665.88_real64, 1650.14_real64, &
                             1634.40_real64, 1620.10_real64, 1605.80_real64, 1591.50_real64, 1577.20_real64, &
                             1562.90_real64, 1549.82_real64, 1536.74_real64, 1523.66_real64, 1510.58_real64, &
                             1497.50_real64, 1485.46_real64, 1473.42_real64, 1461.38_real64, 1449.34_real64, &
                             1437.30_real64, 1426.24_real64, 1415.18_real64, 1404.12_real64, 1393.06_real64, &
                             1382.00_real64, 1371.76_real64, 1361.52_real64, 1351.28_real64, 1341.04_real64, &
                             1330.80_real64, 1321.10_real64, 1311.40_real64, 1301.70_real64, 1292.00_real64, &
                             1282.30_real64]
  interface
    function error_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
!> Allocate one source global coefficient owner, preserving its unwritten cells.
!! Coefficients are grouped by species then level in the first dimension.
!! Latitude bounds are-1:ROWS+2. The four halo columns retain allocation preimages.
!! BYTE_LIMIT bounds this payload only. No scientific value or ready bit is set.
  integer(int32) function initialize_ozone_chemistry_global_storage(ozone, levels, rows, coefficients, byte_limit) result(status)
    type(TOZO), intent(inout) :: ozone
    integer(int32), intent(in) :: levels, rows, coefficients
    integer(int64), intent(in) :: byte_limit
    integer(int64) :: bytes
    integer :: allocation_status
    status = 2
    if (levels < 1 .or. levels > 512 .or. rows < 2 .or. rows > 65536 .or. coefficients /= 7) return
    if (byte_limit < 1 .or. byte_limit > 68719476736_int64) return
    if (allocated(ozone%toz2dg) .or. allocated(ozone%toz2dl) .or. allocated(ozone%toz3dbl)) return
    bytes = 8_int64*int(levels, int64)*coefficients*int(rows + 4, int64)
    if (bytes > byte_limit) return
    allocate (ozone%toz2dg(levels*coefficients, -1:rows + 2), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    status = 0
  end function
!> Update the supported seven-coefficient two-dimensional chemistry table.
!! The exact monthly binary files are read only by actual public rank1.
!! All ranks enter together with the same admitted dimensions and file selection.
!! The public broadcast includes source-unwritten halo preimages from rank1.
!! Calendar date is YYYYMMDD; directory is the real input-data directory.
!! Source-old and BMS chemistry are refused before mutation. The HLO coefficient
!! version comes from the real TEPHY%CO3CHEM string. No surrogate table is used.
  integer(int32) function update_native_ozone_chemistry(clock, dynamics, physics, dimensions, ozone, &
           levels, truncation, rows, longitudes, longitude_counts, normal_forecast, restart_step, control, directory) result(status)
    type(forecast_clock), intent(in) :: clock
    type(native_dynamics_controls), intent(in) :: dynamics
    type(TEPHY), intent(in) :: physics
    type(TDPHY), intent(in) :: dimensions
    type(TOZO), intent(inout) :: ozone
    integer(int32), intent(in) :: levels, truncation, rows, longitudes, longitude_counts(:), restart_step
    logical, intent(in) :: normal_forecast
    type(native_transform_control), intent(in) :: control
    character(*), intent(in) :: directory
    real(real64), allocatable :: field1(:, :), field2(:, :), record1(:), record2(:)
    real(real64), volatile :: weight1, weight2, left, right, value, product, elapsed_seconds
    integer(int32) :: local_status, days, year, month, day, out_year, out_month, out_day, month_lengths(12)
    integer(int32) :: first_month, second_month, first_day, second_day, chlorine_year
    integer(int32) :: rounded_step, unit1, unit2, io1, io2, close_status, child
    integer(int32) :: month_header1, month_header2, count1, count2, header1(3), header2(3)
    integer :: allocation_status, species, level, latitude, coefficient
    logical :: open1, open2, grid
    character(5) :: prefix, version
    character(4) :: truncation_text
    character(3) :: levels_text
    character(2) :: month_text
    character(1024) :: filename1, filename2
    status = 2; local_status = 0; open1 = .false.; open2 = .false.
    if (.not. control%message_ready .or. control%nproc < 1 .or. control%nproc > 32) return
    if (control%myproc < 1 .or. control%myproc > control%nproc) return
! Use an explicit predicate result because an early EXIT must retain refusal.
local_status=chemistry_admission(clock,physics,dimensions,ozone,levels,truncation,rows,longitudes,longitude_counts,directory,restart_step)
    status = agree_update_status(control, local_status)
    if (status /= 0) return
    days = clock%integration%date_time_flags(1)
    if (.not. normal_forecast .and. days == 0) then
      rounded_step = nint(clock%integration%first_dt, kind=int32)
      if (dynamics%ltwotl) then
        value = real(restart_step, real64) + 0.5_real64
        elapsed_seconds = clock%integration%first_dt*value
        if (abs(elapsed_seconds) >= 2147483647.0_real64) then
          status = agree_update_status(control, 2_int32); return
        end if
        rounded_step = nint(elapsed_seconds, kind=int32)
      else
        if (int(rounded_step, int64)*int(restart_step, int64) > 2147483647_int64) then
          status = agree_update_status(control, 2_int32); return
        end if
        rounded_step = rounded_step*restart_step
      end if
      days = rounded_step/86400
    end if
    year = clock%initial_date/10000; month = mod(clock%initial_date/100, 100); day = mod(clock%initial_date, 100)
    call update_calendar(day, month, year, days, out_day, out_month, out_year, month_lengths, child)
    status = agree_update_status(control, child)
    if (status /= 0) return
    if (out_day >= 15) then
      first_month = out_month; second_month = 1 + mod(out_month, 12)
      first_day = 15; second_day = 15 + month_lengths(first_month)
    else
      first_month = 1 + mod(out_month + 10, 12); second_month = out_month
      first_day = 15 - month_lengths(first_month); second_day = 15
    end if
    weight1 = real(second_day - out_day, real64)/real(second_day - first_day, real64)
    weight2 = 1.0_real64 - weight1
    chlorine_year = max(1950, min(2100, out_year))
    value = chlorine(chlorine_year); ozone%teecl2 = value*value
    local_status = 0
    allocate (field1(rows, levels), stat=allocation_status)
    if (allocation_status /= 0) local_status = 1
    if (local_status == 0) then
      allocate (field2(rows, levels), stat=allocation_status)
      if (allocation_status /= 0) local_status = 1
    end if
    if (local_status == 0) then
      allocate (record1(rows), stat=allocation_status)
      if (allocation_status /= 0) local_status = 1
    end if
    if (local_status == 0) then
      allocate (record2(rows), stat=allocation_status)
      if (allocation_status /= 0) local_status = 1
    end if
    status = agree_update_status(control, local_status)
    if (status /= 0) return
    if (control%myproc == 1) then
      grid = truncation > (longitudes + 3)/3
      if (grid) then
        prefix = 'l_2'
      elseif (longitudes == longitude_counts(1)) then
        prefix = '_full'
      elseif (rows == 2*(truncation + 1)) then
        prefix = '_4'
        if (longitude_counts(rows/2) == 2*rows) prefix = '_3'
      else
        prefix = '_2'
      end if
      version = '_'//physics%co3chem
      if (truncation < 100) then
        write (truncation_text, '(I2.2)') truncation
      elseif (truncation < 1000) then
        write (truncation_text, '(I3.3)') truncation
      else
        write (truncation_text, '(I4.4)') truncation
      end if
      if (levels < 100) then
        write (levels_text, '(I2.2)') levels
      else
        write (levels_text, '(I3.3)') levels
      end if
      write (month_text, '(I2.2)') first_month
 filename1=trim(directory)//'/'//trim(truncation_text)//trim(prefix)//'/o3chem_l'//trim(levels_text)//'/O3CHEM'//month_text//trim(version)
      write (month_text, '(I2.2)') second_month
 filename2=trim(directory)//'/'//trim(truncation_text)//trim(prefix)//'/o3chem_l'//trim(levels_text)//'/O3CHEM'//month_text//trim(version)
      io1 = 0; io2 = 0
      open (newunit=unit1, file=trim(filename1), form='unformatted', convert='big_endian', status='old', action='read', iostat=io1)
      open1 = io1 == 0
      if (io1 == 0) read (unit1, iostat=io1) month_header1
      if (io1 == 0) read (unit1, iostat=io1) count1
      if (io1 == 0) then
       open (newunit=unit2, file=trim(filename2), form='unformatted', convert='big_endian', status='old', action='read', iostat=io2)
        open2 = io2 == 0
      end if
      if (io2 == 0 .and. open2) read (unit2, iostat=io2) month_header2
      if (io2 == 0 .and. open2) read (unit2, iostat=io2) count2
      if (io1 == 0 .and. io2 == 0) then
        if (count1 /= count2) io1 = -1
      end if
      if (io1 == 0 .and. io2 == 0) then
        coefficients_loop: do species = 1, 7
          read (unit1, iostat=io1) header1
          if (io1 /= 0) exit coefficients_loop
          read (unit1, iostat=io1)
          if (io1 /= 0) exit coefficients_loop
          read (unit2, iostat=io2) header2
          if (io2 /= 0) exit coefficients_loop
          read (unit2, iostat=io2)
          if (io2 /= 0) exit coefficients_loop
          if (any(header1 /= header2) .or. header1(1) /= species .or. header1(2) /= levels .or. header1(3) /= rows) then
            io1 = -1; exit coefficients_loop
          end if
          do level = 1, levels
            read (unit1, iostat=io1) record1
            if (io1 /= 0) exit coefficients_loop
            read (unit2, iostat=io2) record2
            if (io2 /= 0) exit coefficients_loop
            field1(:, level) = record1; field2(:, level) = record2
            coefficient = (species - 1)*levels + level
            do latitude = 1, rows
              left = field1(latitude, level)*weight1
              right = field2(latitude, level)*weight2
              ozone%toz2dg(coefficient, latitude) = left + right
            end do
          end do
        end do coefficients_loop
      end if
      if (open1) then
        close (unit1, iostat=close_status)
        if (io1 == 0 .and. close_status /= 0) io1 = close_status
      end if
      if (open2) then
        close (unit2, iostat=close_status)
        if (io2 == 0 .and. close_status /= 0) io2 = close_status
      end if
      if (io1 /= 0 .or. io2 /= 0) local_status = 3
    end if
    status = agree_update_status(control, local_status)
    if (status /= 0) return
    if (control%nproc > 1) call mpl_broadcast(ozone%toz2dg, kroot=1_int32, ktag=0_int32, cdstring='UPDO3CH:')
! Automatic local allocatables release all four source scratch owners.
    status = 0
  end function
  logical function levels_invalid(dimensions, physics, levels) result(invalid)
    type(TDPHY), intent(in) :: dimensions
    type(TEPHY), intent(in) :: physics
    integer(int32), intent(in) :: levels
    invalid = .true.
    if (levels < 1 .or. levels > 512) return
    if (dimensions%nvclis /= 7 .or. dimensions%ntoz2d /= 1 .or. dimensions%ntoz3d /= 0) return
    if (physics%lo3ch_oldver .or. physics%lo3ch_bms .or. .not. physics%lo3ch_hlo) return
    invalid = .false.
  end function
integer(int32)function chemistry_admission(clock,physics,dimensions,ozone,levels,truncation,rows,longitudes,longitude_counts,directory,restart_step)result(status)
  type(forecast_clock), intent(in) :: clock
  type(TEPHY), intent(in) :: physics
  type(TDPHY), intent(in) :: dimensions
  type(TOZO), intent(in) :: ozone
  integer(int32), intent(in) :: levels, truncation, rows, longitudes, longitude_counts(:), restart_step
  character(*), intent(in) :: directory
  integer(int64) :: bits
  status = 2
  if (levels_invalid(dimensions, physics, levels)) return
  if (truncation < 1 .or. truncation > 9999 .or. rows < 2 .or. rows > 65536 .or. longitudes < 1 .or. longitudes > 262144) return
  if (size(longitude_counts) < rows) return
  if (len_trim(directory) < 1 .or. len_trim(directory) > 480 .or. index(directory, achar(0)) /= 0) return
  if (.not. allocated(ozone%toz2dg)) return
  if (size(ozone%toz2dg, 1) /= 7*levels) return
  if (lbound(ozone%toz2dg, 2) /= -1 .or. ubound(ozone%toz2dg, 2) /= rows + 2) return
  if (clock%initial_date < 19010101 .or. clock%initial_date > 20991231) return
  if (clock%integration%date_time_flags(1) < 0 .or. clock%integration%date_time_flags(1) > 3660) return
  if (restart_step < 0 .or. restart_step > 1000000) return
  bits = transfer(clock%integration%first_dt, bits)
  if (bits <= 0 .or. bits > transfer(86400.0_real64, bits)) return
  if (index(physics%co3chem, '/') /= 0 .or. index(physics%co3chem, achar(0)) /= 0 .or. len_trim(physics%co3chem) == 0) return
  status = 0
  end function
!> Preserve scientific status around added control-only collective agreements.
!! Real file I/O and the source broadcast retain their natural runtime effects.
  integer(int32) function agree_update_status(control, local_status) result(status)
    type(native_transform_control), intent(in) :: control
    integer(int32), intent(in) :: local_status
    type(ieee_status_type) :: saved_status
    integer(c_int), pointer, volatile :: error_value
    integer(c_int) :: saved_error
    call c_f_pointer(error_address(), error_value)
    saved_error = error_value
    call ieee_get_status(saved_status)
    status = agree_distributed_partition_status(control, local_status)
    call ieee_set_status(saved_status)
    error_value = saved_error
  end function
end module

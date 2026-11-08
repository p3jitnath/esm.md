!> Own the actual daily climate refresh without an original MODEL or globals.
module forecast_runtime_daily_climate
  use iso_fortran_env, only: int32, int64, real64
  use forecast_selected_model_storage, only: native_selected_model_storage
  use forecast_model_time_and_forcing, only: native_time_and_forcing_context
  use forecast_calendar_and_monthly_fields, only: update_calendar
  use forecast_daily_climate_grib, only: read_daily_climate_snapshot, source_climate_julian_day
  use forecast_daily_climate_surface, only: apply_daily_climate_surface_snapshot
  implicit none
  private
  public :: update_runtime_daily_climate
contains
!> Read the selected day's exact GRIB fields and apply the source surface update.
!! STORAGE owns the only climate state and forecast clock. CONTEXT borrows the
!! real surface arrays and named catalogue. STEP is dimensionless; TSTEP is s.
!! The supported daily snapshot route has15 canonical fields and no coupling
!! or monthly interpolation. A single global decode buffer and local staging
!! replace unused original global scratch, without adding a numerical stage.
!! Input files use the actual namespace CNMEXP and the caller's directory.
!! Status0 completes,1 reports allocation failure,2 refuses unsupported input,
!! 3 reports a file/codec error and4 reports an inconsistent climate record.
  integer(int32) function update_runtime_daily_climate(storage, step, tstep, context) result(status)
    type(native_selected_model_storage), target, intent(inout) :: storage
    integer(int32), intent(in) :: step
    real(real64), intent(in) :: tstep
    type(native_time_and_forcing_context), target, intent(inout) :: context
    real(real64), allocatable :: pending(:, :)
    real(real64), volatile :: end_time, step_count
    integer(int64) :: bits
    integer(int32) :: q, g, n, rows, ndglg, increment, initial_date, current_date, final_date
    integer(int32) :: d, m, y, od, om, oy, month_lengths(12), end_increment, end_seconds, interval, next_day, today
    integer :: allocation_status, j, k
    logical :: first, read_now
    character(len=1024) :: path
    status = 2
    if (.not. associated(storage%model%initial)) return
    if (.not. allocated(storage%model%initial%geometry)) return
    if (.not. associated(context%surface_arrays) .or. .not. associated(context%surface_catalog)) return
    if (.not. associated(storage%ecmwf%surface)) return
    if (.not. storage%ecmwf%setup_complete) return
    bits = transfer(tstep, bits)
    if (btest(bits, 63) .or. bits == 0 .or. ibits(bits, 52, 11) == 2047) return
    if (tstep > 86400.0_real64) return
    associate (geometry => storage%model%initial%geometry, clock => storage%model%initial%controls%clock, &
               climate => storage%model%climate, physics => storage%model%physics%ecmwf_physics, &
               constants => storage%model%initial%constants)
      q = geometry%partition%ngptot; g = geometry%partition%ngptotg
      n = geometry%dimensions%ndgnh; ndglg = geometry%dimensions%ndglg
      rows = geometry%dimensions%nproma
      if (q < 1 .or. q > g .or. g > 6599680 .or. rows < 1 .or. rows > 1024) return
      if (n < 1 .or. n > 1280 .or. ndglg /= 2*n) return
      if (.not. allocated(geometry%partition%nglobalindex)) return
      if (size(geometry%partition%nglobalindex) /= q) return
      if (.not. allocated(geometry%configuration%nloeng)) return
      if (lbound(geometry%configuration%nloeng, 1) > 1 .or. ubound(geometry%configuration%nloeng, 1) < ndglg) return
      if (.not. climate%lmccec .or. climate%lmcc04 .or. climate%lmcciec .or. climate%lnemocoup .or. climate%lnemo1way) return
      if (climate%lmcc_compo .or. climate%lmcc05 .or. climate%lmcc01 .or. climate%lmcc01_mse .or. climate%lmcc03) return
      if (physics%nalbedoscheme /= 2 .or. physics%lecurr .or. physics%leobc .or. physics%leobcice .or. physics%leoclake) return
      if (physics%leocml .or. physics%locmltke) return
      if (storage%ecmwf%radiation%radiation%lperpet) return
      if (climate%nclimr /= 15 .or. climate%np1 /= 1 .or. climate%np2 /= 1) return
      if (.not. allocated(climate%climr)) return
      if (any(shape(climate%climr) /= [q, 1, 15])) return
     if (any(climate%ncligc(1:15) /= [31, 139, 174, 15, 16, 17, 18, 210186, 210187, 210188, 210189, 210190, 210191, 66, 67])) return
      if (constants%rday /= 86400.0_real64) return
      if (clock%integration%total_steps < 0 .or. clock%integration%total_steps > 575) return
      if (step < 0 .or. step > clock%integration%total_steps) return
      increment = clock%integration%date_time_flags(1)
      if (increment < 0 .or. increment > 575) return
      if (len_trim(context%data_directory) < 1 .or. len_trim(context%data_directory) > 480) return
      if (index(context%data_directory, achar(0)) /= 0) return
      do j = 1, 4
        k = iachar(storage%model%initial%controls%namespace%cnmexp(j:j))
        if (.not. ((k >= iachar('a') .and. k <= iachar('z')) .or. (k >= iachar('A') .and. k <= iachar('Z')) .or. &
                   (k >= iachar('0') .and. k <= iachar('9')))) return
      end do
      path = trim(context%data_directory)//'/ICMCL'//storage%model%initial%controls%namespace%cnmexp(1:4)//'INIT'
      initial_date = clock%initial_date
      d = mod(initial_date, 100); m = mod(initial_date/100, 100); y = initial_date/10000
! The source changes LFIRSTUPD before calendar and file work.
      first = climate%lfirstupd
      climate%lfirstupd = .false.
      call update_calendar(d, m, y, increment, od, om, oy, month_lengths, status)
      if (status /= 0) return
      current_date = oy*10000 + om*100 + od
      today = source_climate_julian_day(current_date)
      if (today < 1) then
        status = 2
        return
      end if
      if (first) then
        read_now = .true.
      else
        read_now = climate%njdcr == today
      end if
      if (read_now) then
        ! The exact source total-time rounding defines required climate-file coverage.
        if (storage%model%dynamics%ltwotl) then
          step_count = real(clock%integration%total_steps, real64) + 0.5_real64
          end_time = tstep*step_count
          end_seconds = nint(end_time, kind=int32)
        else
          end_seconds = nint(tstep, kind=int32)*clock%integration%total_steps
        end if
        end_increment = end_seconds/nint(constants%rday, kind=int32)
        call update_calendar(d, m, y, end_increment, od, om, oy, month_lengths, status)
        if (status /= 0) return
        final_date = oy*10000 + om*100 + od
        allocate (pending(q, 15), stat=allocation_status)
        if (allocation_status /= 0) then
          status = 1
          return
        end if
        status = read_daily_climate_snapshot(trim(path), g, n, geometry%configuration%nloeng(1:ndglg), &
                                    geometry%partition%nglobalindex, climate%ncligc(1:15), initial_date, current_date, final_date, &
                                             pending, interval, next_day)
        if (status /= 0) return
        ! Decode, schema, EOF and close all succeed before the new numerical table is published.
        do j = 1, 15
          do k = 1, q
            climate%climr(k, 1, j) = pending(k, j)
          end do
        end do
        climate%ndifc = interval
        climate%njdcr = next_day
      end if
      status = apply_daily_climate_surface_snapshot(constants, physics, storage%ecmwf%surface, climate, &
                                                    context%surface_arrays, context%surface_catalog, q, rows)
    end associate
  end function
end module forecast_runtime_daily_climate

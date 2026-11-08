!> Fill every declared spherical polar and periodic halo mode.
module forecast_spherical_halo
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_nearest, ieee_get_rounding_mode, operator(/=)
  use forecast_interpolation_state_types, only: native_interpolation_state
  implicit none
  private
  public :: fill_spherical_halo, SLEXTPOL
  interface SLEXTPOL
    module procedure fill_spherical_halo
  end interface
  interface
    function halo_errno_location() bind(C, name="__errno_location") result(p)
      import c_ptr
      type(c_ptr) :: p
    end function
  end interface
contains
  !> Reflect polar rows with parity,then copy the periodic end values.
  !!
  !! sl is the canonical source-named interpolation owner. stencil_width is2
  !! or3;field_count1:16384;mode1,2 or3. buffer has shape(0:NASLB1-1,fields).
  !! parity(field) is the source FP64 sign or multiplier,with no changed unit.
  !! Mode1 updates every field in point/field order. Mode2 updates the two
  !! ordered field intervals outside field_range(1:2). Mode3 updates the
  !! inclusive inner interval and records the source demand mask.
  !!
  !! Optional mask(0:NASLB1-1) is first cleared in every mode. In mode3 its
  !! source point indices are then marked1,including periodic end sources.
  !! A missing mask performs the same numerical work without mask stores.
  !! Array owners are disjoint except source-declared reads/writes within
  !! buffer itself. Left-to-right stores and every parity multiplication
  !! retain source order;no frozen value is normalized or approximated.
  !!
  !! All map indices and source int32 intermediate expressions are checked
  !! before any buffer/mask store. Status2 refuses controls/maps/bounds;
  !! status1 reports private pair allocation failure;status0 completes.
  !! Private pairs use native integer arrays,not an Arm stack/record layout.
  !! Incoming errno is restored after allocation/release. The caller supplies
  !! the exact default FP environment;nearest rounding and gradual underflow
  !! are also checked here without exceptional arithmetic.
  integer(int32) function fill_spherical_halo(sl, stencil_width, field_count, field_range, mode, &
                                              parity, buffer, mask, workspace_limit) result(status)
    type(native_interpolation_state), intent(in) :: sl
    integer(int32), intent(in) :: stencil_width, field_count, field_range(2), mode
    real(real64), intent(in) :: parity(:)
    real(real64), contiguous, intent(inout) :: buffer(0:, :)
    integer(int32), optional, intent(inout) :: mask(0:)
    integer(int64), optional, intent(in) :: workspace_limit
    integer(int32), allocatable :: pairs(:, :)
    integer(int64) :: first_row, last_row, row, global_row, mirror, mirror_row, ng, ns, count, source_count
    integer(int64) :: start, source_start, offset, source_offset, last_point, source_end
    integer(int64) :: point, longitude, destination, source, t, west, east, capacity, pair_bytes
    integer :: pass, field, j, code
    logical :: selected
    integer(c_int), pointer, volatile :: ep
    integer(c_int) :: saved_errno
    status = 2
    if (stencil_width < 2 .or. stencil_width > 3 .or. field_count < 1 .or. field_count > 16384) return
    if (mode < 1 .or. mode > 3 .or. sl%NASLB1 < 1) return
    capacity = int(sl%NASLB1, int64)
    if (size(buffer, 1, kind=int64) /= capacity .or. size(buffer, 2) < field_count .or. size(parity) < field_count) return
    if (present(mask)) then
      if (size(mask, kind=int64) < capacity) return
    end if
    if (sl%NDGLG < 2 .or. sl%NDGLG > 65534) return
    if (sl%NDGSAG < -1024 .or. sl%NDGSAG > 1) return
    if (sl%NDGENG < sl%NDGLG .or. int(sl%NDGENG, int64) > int(sl%NDGLG, int64) + 1024_int64) return
    if (sl%MYFRSTACTLAT < 1 .or. sl%MYFRSTACTLAT > sl%NDGLG) return
    if (sl%MYLSTACTLAT < sl%MYFRSTACTLAT .or. sl%MYLSTACTLAT > sl%NDGLG) return
    if (sl%NSLWIDEN < 0 .or. sl%NSLWIDEN > 1024 .or. sl%NSLWIDES < 0 .or. sl%NSLWIDES > 1024) return
    if (sl%NFRSTLOFF < 0 .or. sl%NFRSTLOFF >= sl%NDGLG) return
    if (.not. allocated(sl%NLOENG) .or. .not. allocated(sl%NSLSTA)) return
    if (.not. allocated(sl%NSLOFF) .or. .not. allocated(sl%NSLONL)) return
    if (.not. environment_supported()) return
    first_row = max(int(sl%NDGSAG, int64), int(sl%MYFRSTACTLAT, int64) - sl%NSLWIDEN) - sl%NFRSTLOFF
    last_row = min(int(sl%NDGENG, int64), int(sl%MYLSTACTLAT, int64) + sl%NSLWIDES) - sl%NFRSTLOFF
    if (first_row > last_row) return
    pair_bytes = 8_int64*capacity
    if (pair_bytes > 64_int64*1024_int64**3) return
    if (present(workspace_limit)) then
      if (workspace_limit < pair_bytes) return
    end if
    ! The first pass validates every source mapping without public stores.
    do pass = 0, 1
      if (pass == 1) then
        call c_f_pointer(halo_errno_location(), ep); saved_errno = ep
        allocate (pairs(2, int(capacity)), stat=code)
        ep = saved_errno
        if (code /= 0) then
          status = 1
          return
        end if
        if (present(mask)) mask(0:sl%NASLB1 - 1) = 0_int32
      end if
      do row = first_row, last_row
        global_row = row + sl%NFRSTLOFF
        if (global_row <= 0) then
          mirror = 1_int64 - global_row
        else if (global_row > sl%NDGLG) then
          mirror = 2_int64*sl%NDGLG + 1_int64 - global_row
        else
          cycle
        end if
        mirror_row = mirror - sl%NFRSTLOFF
        if (.not. fetch(sl%NLOENG, global_row, ng) .or. .not. fetch(sl%NLOENG, mirror, ns)) return
        if (.not. fetch(sl%NSLSTA, row, start) .or. .not. fetch(sl%NSLSTA, mirror_row, source_start)) return
        if (.not. fetch(sl%NSLOFF, row, offset) .or. .not. fetch(sl%NSLOFF, mirror_row, source_offset)) return
        if (.not. fetch(sl%NSLONL, row, count) .or. .not. fetch(sl%NSLONL, mirror_row, source_count)) return
        if (ng < 1 .or. ns < 1 .or. count < 0 .or. count > capacity) return
        last_point = start + count; source_end = source_offset + source_count
        if (.not. fits(last_point) .or. .not. fits(source_end)) return
        source_end = source_end - 1_int64
        if (.not. fits(source_end)) return
        j = 0
        do point = start, last_point - 1_int64
          t = point - 1_int64
          if (.not. fits(t) .or. .not. fits(t + ng)) return
          longitude = mod(t + ng, ng) + 1_int64
          t = longitude - start
          if (.not. fits(t) .or. .not. fits(t + ng)) return
          destination = offset + mod(t + ng, ng)
          t = longitude - source_start
          if (.not. fits(t) .or. .not. fits(t + ns)) return
          source = source_offset + mod(t + ns, ns)
          if (.not. fits(destination) .or. .not. fits(source)) return
          if (source < source_offset .or. source > source_end) source = destination
          if (destination < 0 .or. destination >= capacity .or. source < 0 .or. source >= capacity) return
          j = j + 1
          if (pass == 0) cycle
          if (mode == 1) then
            do field = 1, field_count
              if (destination /= source) buffer(destination, field) = buffer(source, field)
              buffer(destination, field) = parity(field)*buffer(destination, field)
            end do
          else
            pairs(1, j) = int(destination, int32); pairs(2, j) = int(source, int32)
          end if
        end do
        if (pass == 0 .or. mode == 1) cycle
        do field = 1, field_count
          selected = field >= field_range(1) .and. field <= field_range(2)
          if ((mode == 2 .and. selected) .or. (mode == 3 .and. .not. selected)) cycle
          do j = 1, int(count)
            buffer(pairs(1, j), field) = parity(field)*buffer(pairs(2, j), field)
          end do
        end do
        if (mode == 3 .and. present(mask)) then
          do j = 1, int(count)
            mask(pairs(2, j)) = 1_int32
          end do
        end if
      end do
      if (mode == 1) then
        do row = first_row, last_row
          call periodic_row(row, pass, status)
          if (status /= 0) return
        end do
      else
        ! Source field-major order is observable when halo locations overlap.
        do field = 1, field_count
          selected = field >= field_range(1) .and. field <= field_range(2)
          if ((mode == 2 .and. selected) .or. (mode == 3 .and. .not. selected)) cycle
          do row = first_row, last_row
            call periodic_row(row, pass, status, field)
            if (status /= 0) return
          end do
        end do
        ! Masks are formed even when the selected field interval is empty.
        if (mode == 3 .and. present(mask)) then
          do row = first_row, last_row
            call periodic_mask(row, pass, status)
            if (status /= 0) return
          end do
        end if
      end if
    end do
    call c_f_pointer(halo_errno_location(), ep); saved_errno = ep
    deallocate (pairs); ep = saved_errno
    status = 0
  contains
    subroutine row_metadata(r, valid)
      integer(int64), intent(in) :: r
      logical, intent(out) :: valid
      valid = .false.
      global_row = r + sl%NFRSTLOFF
      if (.not. fetch(sl%NLOENG, global_row, ng)) return
      if (.not. fetch(sl%NSLONL, r, count)) return
      if (.not. fetch(sl%NSLOFF, r, offset)) return
      if (ng < 1 .or. count < 0) return
      valid = .true.
    end subroutine
    subroutine periodic_row(r, phase, result, one_field)
      integer(int64), intent(in) :: r
      integer, intent(in) :: phase
      integer(int32), intent(out) :: result
      integer, optional, intent(in) :: one_field
      integer :: k, a, b
      logical :: valid
      result = 2
      call row_metadata(r, valid)
      if (.not. valid) return
      if (count /= ng) then
        result = 0
        return
      end if
      west = offset - stencil_width + 1_int64; east = offset + ng
      if (.not. fits(west) .or. .not. fits(east) .or. .not. fits(east + stencil_width - 1_int64)) return
      if (.not. fits(west + 4_int64) .or. .not. fits(east - stencil_width + 1_int64)) return
      if (west < 0 .or. west + 4_int64 >= capacity) return
      if (east - stencil_width + 1_int64 < 0 .or. east + stencil_width - 1_int64 >= capacity) return
      a = 1; b = field_count
      if (present(one_field)) then
        a = one_field; b = one_field
      end if
      if (phase == 1) then
        do k = a, b
          if (stencil_width == 2) then
            buffer(west, k) = buffer(east - 1_int64, k)
            buffer(east, k) = buffer(west + 1_int64, k)
            buffer(east + 1_int64, k) = buffer(west + 2_int64, k)
          else
            buffer(west, k) = buffer(east - 2_int64, k)
            buffer(west + 1_int64, k) = buffer(east - 1_int64, k)
            buffer(east, k) = buffer(west + 2_int64, k)
            buffer(east + 1_int64, k) = buffer(west + 3_int64, k)
            buffer(east + 2_int64, k) = buffer(west + 4_int64, k)
          end if
        end do
      end if
      result = 0
    end subroutine
    subroutine periodic_mask(r, phase, result)
      integer(int64), intent(in) :: r
      integer, intent(in) :: phase
      integer(int32), intent(out) :: result
      logical :: valid
      result = 2
      call row_metadata(r, valid)
      if (.not. valid) return
      if (count /= ng .or. mode /= 3) then
        result = 0
        return
      end if
      if (offset < 0 .or. offset + 2_int64 >= capacity) return
      if (offset + ng - 1_int64 >= capacity .or. offset + ng - stencil_width + 1_int64 < 0) return
      if (phase == 1 .and. present(mask)) then
        mask(offset + ng - 1_int64) = 1_int32
        if (stencil_width == 3) mask(offset + ng - 2_int64) = 1_int32
        mask(offset) = 1_int32; mask(offset + 1_int64) = 1_int32
        if (stencil_width == 3) mask(offset + 2_int64) = 1_int32
      end if
      result = 0
    end subroutine
  end function

  logical function fetch(values, index, value) result(ok)
    integer(int32), allocatable, intent(in) :: values(:)
    integer(int64), intent(in) :: index
    integer(int64), intent(out) :: value
    ok = .false.; value = 0
    if (index < int(lbound(values, 1), int64) .or. index > int(ubound(values, 1), int64)) return
    value = int(values(index), int64); ok = .true.
  end function
  pure logical function fits(value)
    integer(int64), intent(in) :: value
    fits = value >= -int(huge(0_int32), int64) - 1_int64 .and. value <= int(huge(0_int32), int64)
  end function
  logical function environment_supported() result(ok)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: normal, half, subnormal
    ok = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    normal = tiny(0.0_real64); half = 0.5_real64; subnormal = normal*half
    if (transfer(subnormal, 0_int64) /= ibset(0_int64, 51)) return
    ok = .true.
  end function
end module forecast_spherical_halo

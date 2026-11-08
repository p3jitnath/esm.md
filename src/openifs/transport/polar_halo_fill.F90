!> Fill the selected fixed polar and periodic interpolation halo.
!! A halo stores neighbouring values outside the main grid. This mode reflects
!! rows across a pole, applies each field's parity, then copies periodic ends.
module md2asm_polar_halo_fill
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_round_type, ieee_nearest, ieee_get_rounding_mode, &
                             ieee_support_underflow_control, ieee_get_underflow_mode, operator(/=)
  use forecast_interpolation_state_types, only: native_interpolation_state
  implicit none
  private
  public :: fill_polar_halo_mode_one
  interface
    subroutine gstats(tag, switch)
      import int32
      integer(int32), intent(in) :: tag, switch
    end subroutine
  end interface
contains
  !> Copy reflected rows and periodic ends in the original point order.
  !! sl borrows the live source-named maps and retains their latitude bounds.
  !! stencil_width is 2 or 3. field_count is in 1:16384. parity contains at
  !! least field_count dimensionless FP64 signs. buffer has the exact point
  !! extent 0:sl%NASLB1-1 and at least field_count field columns. Each field
  !! keeps its supplied unit. The complete buffer is writable and disjoint
  !! from parity, sl and its map owners. Read-only maps remain unchanged.
  !! Only mode one with no demand mask and no profiling hook is supported.
  !! The public GSTATS boundaries retain tag1133 and switches0/1. The caller
  !! keeps their public runtime alive. No original model stage is called.
  !! An integer pass validates every consumed map and point before stores
  !! or profiling. Status2 refuses the environment, dimensions or maps with
  !! unchanged buffer; status0 completes all stores. No heap is allocated.
  !! Source signed int32 intermediate operations must fit; the wider integer
  !! checks below enforce that rule without wrapping an unsupported value.
  !! The outer target guard requires FPCR0 and disabled traps. This portable
  !! guard additionally checks nearest rounding and gradual underflow.
  integer(int32) function fill_polar_halo_mode_one(sl, stencil_width, field_count, parity, buffer) result(status)
    type(native_interpolation_state), intent(in) :: sl
    integer(int32), intent(in) :: stencil_width, field_count
    real(real64), intent(in) :: parity(:)
    real(real64), contiguous, intent(inout) :: buffer(0:, :)
    integer(int64) :: first_row, last_row, local_row, global_row, mirror_row, mirror_global
    integer(int64) :: ng, ns, start, source_start, offset, source_offset, count, source_count
    integer(int64) :: point, last_point, longitude, destination, source, temporary
    integer(int64) :: west, east, source_end, point_count
    integer(int32) :: pass, field, tag, switch
    logical :: owned_source
    status = 2
    if (stencil_width < 2 .or. stencil_width > 3) return
    if (field_count < 1 .or. field_count > 16384) return
    if (sl%NASLB1 < 1) return
    point_count = int(sl%NASLB1, int64)
    if (size(buffer, 1, kind=int64) /= point_count) return
    if (size(buffer, 2, kind=int64) < int(field_count, int64)) return
    if (size(parity, kind=int64) < int(field_count, int64)) return
    if (sl%NDGLG < 2 .or. sl%NDGLG > 65534) return
    if (sl%NDGSAG < -1024 .or. sl%NDGSAG > 1) return
    if (sl%NDGENG < sl%NDGLG) return
    if (int(sl%NDGENG, int64) > int(sl%NDGLG, int64) + 1024_int64) return
    if (sl%MYFRSTACTLAT < 1 .or. sl%MYFRSTACTLAT > sl%NDGLG) return
    if (sl%MYLSTACTLAT < sl%MYFRSTACTLAT .or. sl%MYLSTACTLAT > sl%NDGLG) return
    if (sl%NSLWIDEN < 0 .or. sl%NSLWIDEN > 1024) return
    if (sl%NSLWIDES < 0 .or. sl%NSLWIDES > 1024) return
    if (sl%NFRSTLOFF < 0 .or. sl%NFRSTLOFF >= sl%NDGLG) return
    if (.not. valid_map_owner(sl%NLOENG)) return
    if (.not. valid_map_owner(sl%NSLSTA)) return
    if (.not. valid_map_owner(sl%NSLOFF)) return
    if (.not. valid_map_owner(sl%NSLONL)) return
    if (.not. polar_environment_ready()) return
    first_row = max(int(sl%NDGSAG, int64), int(sl%MYFRSTACTLAT, int64) - int(sl%NSLWIDEN, int64)) &
                - int(sl%NFRSTLOFF, int64)
    last_row = min(int(sl%NDGENG, int64), int(sl%MYLSTACTLAT, int64) + int(sl%NSLWIDES, int64)) &
               - int(sl%NFRSTLOFF, int64)
    if (first_row > last_row) return
    tag = 1133
    do pass = 0, 1
      if (pass == 1) then
        switch = 0
        call gstats(tag, switch)
      end if
      do local_row = first_row, last_row
        global_row = local_row + int(sl%NFRSTLOFF, int64)
        if (global_row <= 0) then
          mirror_global = 1_int64 - global_row
        else if (global_row > int(sl%NDGLG, int64)) then
          mirror_global = 2_int64*int(sl%NDGLG, int64) + 1_int64 - global_row
        else
          cycle
        end if
        mirror_row = mirror_global - int(sl%NFRSTLOFF, int64)
        if (.not. fetch_map(sl%NLOENG, global_row, ng)) return
        if (.not. fetch_map(sl%NLOENG, mirror_global, ns)) return
        if (.not. fetch_map(sl%NSLSTA, local_row, start)) return
        if (.not. fetch_map(sl%NSLSTA, mirror_row, source_start)) return
        if (.not. fetch_map(sl%NSLOFF, local_row, offset)) return
        if (.not. fetch_map(sl%NSLOFF, mirror_row, source_offset)) return
        if (.not. fetch_map(sl%NSLONL, local_row, count)) return
        if (.not. fetch_map(sl%NSLONL, mirror_row, source_count)) return
        if (ng < 1 .or. ns < 1 .or. count < 0) return
        last_point = start + count
        source_end = source_offset + source_count
        if (.not. fits_int32(source_end)) return
        source_end = source_end - 1_int64
        if (.not. fits_int32(last_point) .or. .not. fits_int32(source_end)) return
        do point = start, last_point - 1_int64
          temporary = point + ng
          if (.not. fits_int32(temporary)) return
          temporary = temporary - 1_int64
          if (.not. fits_int32(temporary)) return
          longitude = mod(temporary, ng) + 1_int64
          temporary = longitude - start
          if (.not. fits_int32(temporary)) return
          temporary = temporary + ng
          if (.not. fits_int32(temporary)) return
          destination = mod(temporary, ng) + offset
          if (.not. fits_int32(destination)) return
          temporary = longitude - source_start
          if (.not. fits_int32(temporary)) return
          temporary = temporary + ns
          if (.not. fits_int32(temporary)) return
          source = mod(temporary, ns) + source_offset
          if (.not. fits_int32(source)) return
          if (destination < 1 .or. destination >= point_count) return
          if (source < 1 .or. source >= point_count) return
          owned_source = source >= source_offset .and. source <= source_end
          if (pass == 1) then
            do field = 1, field_count
              if (owned_source) buffer(destination, field) = buffer(source, field)
              buffer(destination, field) = parity(field)*buffer(destination, field)
            end do
          end if
        end do
      end do
      do local_row = first_row, last_row
        global_row = local_row + int(sl%NFRSTLOFF, int64)
        if (.not. fetch_map(sl%NLOENG, global_row, ng)) return
        if (.not. fetch_map(sl%NSLONL, local_row, count)) return
        if (ng /= count) cycle
        if (.not. fetch_map(sl%NSLOFF, local_row, offset)) return
        west = offset - int(stencil_width, int64) + 1_int64
        east = offset + ng
        if (.not. fits_int32(west) .or. .not. fits_int32(east)) return
        if (.not. fits_int32(east + int(stencil_width, int64) - 1_int64)) return
        if (.not. fits_int32(west + 4_int64)) return
        if (.not. fits_int32(east - int(stencil_width, int64) + 1_int64)) return
        if (west < 0 .or. east + int(stencil_width, int64) - 1_int64 >= point_count) return
        if (west + 4_int64 >= point_count .or. east - int(stencil_width, int64) + 1_int64 < 0) return
        if (pass == 1) then
          do field = 1, field_count
            if (stencil_width == 2) then
              buffer(west, field) = buffer(east - 1_int64, field)
              buffer(east, field) = buffer(west + 1_int64, field)
              buffer(east + 1_int64, field) = buffer(west + 2_int64, field)
            else
              buffer(west, field) = buffer(east - 2_int64, field)
              buffer(west + 1_int64, field) = buffer(east - 1_int64, field)
              buffer(east, field) = buffer(west + 2_int64, field)
              buffer(east + 1_int64, field) = buffer(west + 3_int64, field)
              buffer(east + 2_int64, field) = buffer(west + 4_int64, field)
            end if
          end do
        end if
      end do
    end do
    switch = 1
    call gstats(tag, switch)
    status = 0
  end function

  logical function valid_map_owner(values)
    integer(int32), allocatable, intent(in) :: values(:)
    valid_map_owner = .false.
    if (.not. allocated(values)) return
    if (size(values, kind=int64) < 1 .or. size(values, kind=int64) > 131072_int64) return
    valid_map_owner = .true.
  end function

  logical function fetch_map(values, index, value)
    integer(int32), allocatable, intent(in) :: values(:)
    integer(int64), intent(in) :: index
    integer(int64), intent(out) :: value
    fetch_map = .false.
    value = 0
    if (index < int(lbound(values, 1), int64) .or. index > int(ubound(values, 1), int64)) return
    value = int(values(index), int64)
    fetch_map = .true.
  end function

  logical function fits_int32(value)
    integer(int64), intent(in) :: value
    fits_int32 = value >= -int(huge(0_int32), int64) - 1_int64 .and. value <= int(huge(0_int32), int64)
  end function

  logical function polar_environment_ready()
    type(ieee_round_type) :: rounding
    logical :: gradual
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe
    polar_environment_ready = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) return
    else
      minimum_normal = tiny(0.0_real64)
      half_value = 0.5_real64
      subnormal_probe = minimum_normal*half_value
      if (transfer(subnormal_probe, 0_int64) /= ibset(0_int64, 51)) return
    end if
    polar_environment_ready = .true.
  end function
end module md2asm_polar_halo_fill

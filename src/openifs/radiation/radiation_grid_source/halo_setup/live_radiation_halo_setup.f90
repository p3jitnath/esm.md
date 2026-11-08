!> Continue actual radiation point owners through halo and local latitude setup.
module forecast_live_radiation_halo
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_ptr, c_null_ptr, c_associated, c_intptr_t
  use ieee_exceptions, only: ieee_status_type
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_native_radiation_grid, only: native_radiation_grid, calculate_preallocated_grid_angular_extrema
  use forecast_native_radiation_transform_storage, only: native_radiation_transform_storage
  use forecast_live_radiation_setup, only: create_live_radiation_point_setup, retire_radiation_zmu, &
                                           release_live_radiation_point_setup, validate_live_radiation_storage
  use forecast_radiation_interpolation_context, only: native_radiation_main_grid_view
  use forecast_radiation_halo_widths, only: publish_runtime_radiation_halo_widths
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_lifetime_status, only: save_lifetime_status, restore_lifetime_status
  implicit none
  private
  public :: create_live_radiation_halo_setup, continue_live_radiation_halo_setup
  public :: validate_live_radiation_halo_setup, release_live_radiation_halo_setup
contains
!> Create own point fields, retire ZMU, then own the complete halo continuation.
!! G and ROW_LENGTHS must remain TARGET at their actual addresses through
!! collective release. MAIN borrows the actual model grid; RI/RO own native
!! interpolation state. EXTREMA(1:8) publishes degree limits only on success.
  integer(int32) function create_live_radiation_halo_setup(owner, g, radiation_row_lengths, main, ri, ro, &
                                                        control, partition, physical, nradint, nstencilwide, extrema) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    type(native_radiation_grid), target, intent(inout) :: g
    integer(int32), target, intent(in) :: radiation_row_lengths(-1:)
    type(native_radiation_main_grid_view), intent(in) :: main
    type(native_interpolation_state), intent(inout) :: ri, ro
    type(native_transform_control), intent(in) :: control
    type(native_distributed_partition), intent(in) :: partition
    type(forecast_physical_constants), intent(in) :: physical
    integer(int32), intent(in) :: nradint, nstencilwide
    real(real64), intent(inout) :: extrema(:)
    integer(int32) :: preimage(14), saved, ignored
    status = 2
    if (owner%state == 0 .and. .not. allocated(g%rlati) .and. .not. allocated(g%ripi)) then
      if (.not. any(c_associated_each(owner%halo_address))) then
        if (main_input_valid(main, partition) .and. size(extrema) >= 8 .and. is_contiguous(radiation_row_lengths)) status = 0
      end if
    end if
    status = halo_agree(control, status)
    if (status /= 0) return
    call save_grid_scalars(g, preimage)
    status = create_live_radiation_point_setup(owner, g, radiation_row_lengths, control, partition, physical, nradint, nstencilwide)
    if (status /= 0) return
    status = retire_radiation_zmu(owner)
if (status == 0) status = continue_live_radiation_halo_setup(owner, g, main, ri, ro, control, partition, physical, nradint, extrema)
    if (status /= 0) then
      saved = status
      ignored = release_live_radiation_point_setup(owner)
      call restore_grid_scalars(g, preimage)
      status = saved
    end if
  end function

!> Extend the actual state4 owner, preserving its prior state on a failed stage.
!! Four private degree arrays allocate in radiation-latitude/longitude then
!! main-latitude/longitude order. Normal frees retain that same source order.
!! RLATI and RIPI allocate separately with agreement after each position.
integer(int32)function continue_live_radiation_halo_setup(owner,g,main,ri,ro,control,partition,physical,nradint,extrema)result(status)
  type(native_radiation_transform_storage), target, intent(inout) :: owner
  type(native_radiation_grid), target, intent(inout) :: g
  type(native_radiation_main_grid_view), intent(in) :: main
  type(native_interpolation_state), intent(inout) :: ri, ro
  type(native_transform_control), intent(in) :: control
  type(native_distributed_partition), intent(in) :: partition
  type(forecast_physical_constants), intent(in) :: physical
  integer(int32), intent(in) :: nradint
  real(real64), intent(inout) :: extrema(:)
 real(real64), allocatable :: radiation_latitude_work(:), radiation_longitude_work(:), main_latitude_work(:), main_longitude_work(:)
  real(real64) :: pending_extrema(8)
  integer(int32) :: width_preimage(8), latitude_preimage(2), saved
  integer :: error
  status = 2
  if (owner%state == 4 .and. associated(owner%grid, g)) then
    if (.not. allocated(g%rlati) .and. .not. allocated(g%ripi) .and. .not. any(c_associated_each(owner%halo_address))) then
      if (main_input_valid(main, partition) .and. size(extrema) >= 8) then
        if (g%ngptot > 0 .and. owner%ngptotmx >= g%ngptot .and. owner%ngptotmx <= 268435456) status = 0
      end if
    end if
  end if
  status = halo_agree(control, status)
  if (status /= 0) return
  status = validate_live_radiation_storage(owner, .true.)
  if (status /= 0) return
  width_preimage = [ri%nslwiden, ri%nslwides, ri%nslwidee, ri%nslwidew, ro%nslwiden, ro%nslwides, ro%nslwidee, ro%nslwidew]
  latitude_preimage = [g%ndgsah, g%ndgenh]
  allocate (radiation_latitude_work(owner%ngptotmx), stat=error)
  status = halo_agree(control, int(merge(1, 0, error /= 0), int32))
  if (status /= 0) goto 900
  allocate (radiation_longitude_work(owner%ngptotmx), stat=error)
  status = halo_agree(control, int(merge(1, 0, error /= 0), int32))
  if (status /= 0) goto 900
  status = calculate_preallocated_grid_angular_extrema(g%gelat, g%gelam, physical, pending_extrema(1:4), &
                                                       radiation_latitude_work, radiation_longitude_work)
  status = halo_agree(control, status)
  if (status /= 0) goto 900
  deallocate (radiation_latitude_work)
  deallocate (radiation_longitude_work)
  allocate (main_latitude_work(partition%ngptotmx), stat=error)
  status = halo_agree(control, int(merge(1, 0, error /= 0), int32))
  if (status /= 0) goto 900
  allocate (main_longitude_work(partition%ngptotmx), stat=error)
  status = halo_agree(control, int(merge(1, 0, error /= 0), int32))
  if (status /= 0) goto 900
  status = calculate_preallocated_grid_angular_extrema(main%latitude, main%longitude, physical, pending_extrema(5:8), &
                                                       main_latitude_work, main_longitude_work)
  status = halo_agree(control, status)
  if (status /= 0) goto 900
  deallocate (main_latitude_work)
  deallocate (main_longitude_work)
  status = publish_runtime_radiation_halo_widths(g, main, owner%points, partition, ri, ro, nradint, pending_extrema)
  status = halo_agree(control, status)
  if (status /= 0) goto 900
! Stage the existing numerical latitude body under source collective allocation.
  allocate (g%rlati(g%ndgsah:g%ndgenh), stat=error)
  status = halo_agree(control, int(merge(1, 0, error /= 0), int32))
  if (status /= 0) goto 900
  allocate (g%ripi(g%ndgsah:g%ndgenh, 3), stat=error)
  status = halo_agree(control, int(merge(1, 0, error /= 0), int32))
  if (status /= 0) goto 900
  status = fill_existing_radiation_latitude_interpolation(g)
  status = halo_agree(control, status)
  if (status /= 0) goto 900
  owner%halo_address(1) = c_loc(g%rlati(lbound(g%rlati, 1)))
  owner%halo_address(2) = c_loc(g%ripi(lbound(g%ripi, 1), 1))
  owner%state = 5
  extrema(1:8) = pending_extrema
  status = 0
  return
900 continue
  saved = status
  if (allocated(g%ripi)) deallocate (g%ripi)
  if (allocated(g%rlati)) deallocate (g%rlati)
  if (allocated(main_longitude_work)) deallocate (main_longitude_work)
  if (allocated(main_latitude_work)) deallocate (main_latitude_work)
  if (allocated(radiation_longitude_work)) deallocate (radiation_longitude_work)
  if (allocated(radiation_latitude_work)) deallocate (radiation_latitude_work)
  owner%halo_address = c_null_ptr
  owner%state = 4
  g%ndgsah = latitude_preimage(1); g%ndgenh = latitude_preimage(2)
  ri%nslwiden = width_preimage(1); ri%nslwides = width_preimage(2); ri%nslwidee = width_preimage(3); ri%nslwidew = width_preimage(4)
  ro%nslwiden = width_preimage(5); ro%nslwides = width_preimage(6); ro%nslwidee = width_preimage(7); ro%nslwidew = width_preimage(8)
  status = saved
  end function

!> Validate the complete halo and prior point/storage owner without mutation.
!! Every process takes the same added agreement. All numerical values, flags
!! and errno remain as received around that nonnumerical agreement.
  integer(int32) function validate_live_radiation_halo_setup(owner, g, control) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    type(native_radiation_grid), target, intent(inout) :: g
    type(native_transform_control), intent(in) :: control
    status = 2
    if (halo_owners_valid(owner, g)) status = 0
    status = halo_agree(control, status)
    if (status /= 0) return
    status = validate_live_radiation_storage(owner, .true.)
  end function

!> Release the two latitude owners first, then all13 retired point/storage owners.
!! The caller retains borrowed row lengths and the actual partition through
!! the complete call. Wrong state, shape or identity refuses before any free.
  integer(int32) function release_live_radiation_halo_setup(owner, g, control) result(status)
    type(native_radiation_transform_storage), target, intent(inout) :: owner
    type(native_radiation_grid), target, intent(inout) :: g
    type(native_transform_control), intent(in) :: control
    status = validate_live_radiation_halo_setup(owner, g, control)
    if (status /= 0) return
    deallocate (g%ripi)
    deallocate (g%rlati)
    owner%halo_address = c_null_ptr
    owner%state = 4
    status = release_live_radiation_point_setup(owner)
  end function

  logical function main_input_valid(main, partition) result(valid)
    type(native_radiation_main_grid_view), intent(in) :: main
    type(native_distributed_partition), intent(in) :: partition
    integer :: n, ns
    valid = .false.; n = main%grid%ngptot
    if (n < 1 .or. n > 268435456 .or. partition%ngptotmx < n .or. partition%ngptotmx > 268435456) return
    if (.not. associated(main%latitude) .or. .not. associated(main%longitude)) return
    if (.not. is_contiguous(main%latitude) .or. .not. is_contiguous(main%longitude)) return
    if (lbound(main%latitude, 1) /= 1 .or. size(main%latitude) /= n) return
    if (lbound(main%longitude, 1) /= 1 .or. size(main%longitude) /= n) return
 if (.not. associated(main%row_lengths) .or. .not. associated(main%first_latitude) .or. .not. associated(main%last_latitude)) return
    if (main%grid%ndglg < 2 .or. main%grid%ndglg > 65536 .or. mod(main%grid%ndglg, 2) /= 0) return
    if (lbound(main%row_lengths, 1) /= -1 .or. ubound(main%row_lengths, 1) /= main%grid%ndglg + 2) return
    ns = size(main%first_latitude)
    if (ns < 1 .or. ns > 64 .or. size(main%last_latitude) /= ns) return
    if (partition%my_region_ns < 1 .or. partition%my_region_ns > ns .or. partition%phase /= 7) return
    valid = .true.
  end function

  logical function halo_owners_valid(owner, g) result(valid)
    type(native_radiation_transform_storage), target, intent(in) :: owner
    type(native_radiation_grid), target, intent(in) :: g
    integer(c_intptr_t) :: a(2), length(2), other, other_length(14)
    integer :: j, k
    valid = .false.
    if (owner%state /= 5 .or. .not. associated(owner%grid, g)) return
    if (.not. allocated(g%rlati) .or. .not. allocated(g%ripi)) return
    if (lbound(g%rlati, 1) /= g%ndgsah .or. ubound(g%rlati, 1) /= g%ndgenh) return
    if (lbound(g%ripi, 1) /= g%ndgsah .or. ubound(g%ripi, 1) /= g%ndgenh) return
    if (lbound(g%ripi, 2) /= 1 .or. ubound(g%ripi, 2) /= 3) return
    if (g%ndgsah > g%ndgenh) return
    if (.not. c_associated(owner%halo_address(1), c_loc(g%rlati(g%ndgsah)))) return
    if (.not. c_associated(owner%halo_address(2), c_loc(g%ripi(g%ndgsah, 1)))) return
    if (.not. allocated(owner%nsta) .or. .not. allocated(owner%nonl) .or. .not. allocated(owner%nptrfrstlat)) return
    if (.not. allocated(owner%nfrstlat) .or. .not. allocated(owner%nlstlat)) return
    if (.not. allocated(g%rmu) .or. .not. allocated(g%rsqm2) .or. .not. allocated(g%rlatig)) return
    if (.not. allocated(g%gelam) .or. .not. allocated(g%gelat) .or. .not. allocated(g%geslo)) return
    if (.not. allocated(g%geclo) .or. .not. allocated(g%gemu)) return
    other_length(1) = 4_c_intptr_t*size(owner%nsta, kind=c_intptr_t)
    other_length(2) = 4_c_intptr_t*size(owner%nonl, kind=c_intptr_t)
    other_length(3) = 4_c_intptr_t*size(owner%nptrfrstlat, kind=c_intptr_t)
    other_length(4) = 4_c_intptr_t*size(owner%nfrstlat, kind=c_intptr_t)
    other_length(5) = 4_c_intptr_t*size(owner%nlstlat, kind=c_intptr_t)
    other_length(6) = 8_c_intptr_t*size(g%rmu, kind=c_intptr_t)
    other_length(7) = 0_c_intptr_t
    other_length(8) = 8_c_intptr_t*size(g%rsqm2, kind=c_intptr_t)
    other_length(9) = 8_c_intptr_t*size(g%rlatig, kind=c_intptr_t)
    other_length(10) = 8_c_intptr_t*size(g%gelam, kind=c_intptr_t)
    other_length(11) = 8_c_intptr_t*size(g%gelat, kind=c_intptr_t)
    other_length(12) = 8_c_intptr_t*size(g%geslo, kind=c_intptr_t)
    other_length(13) = 8_c_intptr_t*size(g%geclo, kind=c_intptr_t)
    other_length(14) = 8_c_intptr_t*size(g%gemu, kind=c_intptr_t)
    a(1) = transfer(owner%halo_address(1), 0_c_intptr_t); a(2) = transfer(owner%halo_address(2), 0_c_intptr_t)
    length(1) = 8_c_intptr_t*size(g%rlati, kind=c_intptr_t); length(2) = 8_c_intptr_t*size(g%ripi, kind=c_intptr_t)
    do j = 1, 2
      if (a(j) <= 0 .or. length(j) < 1 .or. a(j) > huge(a(j)) - length(j)) return
      do k = 1, size(owner%allocation_address)
        if (.not. c_associated(owner%allocation_address(k))) cycle
        other = transfer(owner%allocation_address(k), 0_c_intptr_t)
        if (other_length(k) < 1 .or. other <= 0 .or. other > huge(other) - other_length(k)) return
        if (other < a(j) + length(j) .and. a(j) < other + other_length(k)) return
      end do
    end do
    if (a(1) < a(2) + length(2) .and. a(2) < a(1) + length(1)) return
    valid = .true.
  end function

!> Preserve status only around the added integer agreement, never a calculation.
  integer(int32) function halo_agree(control, local_status) result(status)
    type(native_transform_control), intent(in) :: control
    integer(int32), intent(in) :: local_status
    type(ieee_status_type) :: saved
    integer(int32) :: saved_errno
    call save_lifetime_status(saved, saved_errno)
    status = agree_distributed_partition_status(control, local_status)
    call restore_lifetime_status(saved, saved_errno)
  end function
  function c_associated_each(address) result(present)
    type(c_ptr), intent(in) :: address(:)
    logical :: present(size(address))
    integer :: j
    do j = 1, size(address)
      present(j) = c_associated(address(j))
    end do
  end function
  subroutine save_grid_scalars(g, values)
    type(native_radiation_grid), intent(in) :: g
    integer(int32), intent(out) :: values(14)
    values = [g%ndglg, g%ndlon, g%nsmax, g%ngptot, g%nfrstloff, g%ndgsl, g%ndgsah, g%ndgenh, &
              g%ndgsal, g%ndgenl, g%ndlonh, g%ndlonm, g%myfrstlat, g%mylstlat]
  end subroutine
  subroutine restore_grid_scalars(g, values)
    type(native_radiation_grid), intent(inout) :: g
    integer(int32), intent(in) :: values(14)
    g%ndglg = values(1); g%ndlon = values(2); g%nsmax = values(3); g%ngptot = values(4)
    g%nfrstloff = values(5); g%ndgsl = values(6); g%ndgsah = values(7); g%ndgenh = values(8)
    g%ndgsal = values(9); g%ndgenl = values(10); g%ndlonh = values(11); g%ndlonm = values(12)
    g%myfrstlat = values(13); g%mylstlat = values(14)
  end subroutine

!> Exact existing latitude numerical body with source-separated allocations.
  integer(int32) function fill_existing_radiation_latitude_interpolation(g) result(status)
    type(native_radiation_grid), intent(inout) :: g
    real(real64) :: a, b, c, d, ab, ac, ad, bc, bd, cd, x
    integer :: j, k, n, first, last
    status = 2; n = g%ndglg; first = g%ndgsah; last = g%ndgenh
    if (n < 2 .or. n > 8192 .or. mod(n, 2) /= 0 .or. first > last) return
    if (g%nfrstloff < 0 .or. g%nfrstloff >= n) return
    if (first + g%nfrstloff < -1 .or. last + g%nfrstloff > n + 2) return
    if (.not. allocated(g%rlati) .or. .not. allocated(g%ripi) .or. .not. allocated(g%rlatig)) return
    if (lbound(g%rlatig, 1) /= -1 .or. ubound(g%rlatig, 1) /= n + 2) return
    if (lbound(g%rlati, 1) /= first .or. ubound(g%rlati, 1) /= last) return
    if (lbound(g%ripi, 1) /= first .or. ubound(g%ripi, 1) /= last .or. size(g%ripi, 2) /= 3) return
    do j = -1, n + 2
      if (ibits(transfer(g%rlatig(j), 0_int64), 52, 11) == 2047) return
      if (j > -1) then
        if (g%rlatig(j - 1) <= g%rlatig(j)) return
      end if
    end do
    do j = first, last
      k = j + g%nfrstloff; g%rlati(j) = g%rlatig(k)
      if (k < 0 .or. k > n) cycle
      a = g%rlatig(k - 1); b = g%rlatig(k); c = g%rlatig(k + 1); d = g%rlatig(k + 2)
      ab = a - b; ac = a - c; ad = a - d; bc = b - c; bd = b - d; cd = c - d
      x = ab*bc; x = x*bd; g%ripi(j, 1) = -1._real64/x
      x = ac*bc; x = x*cd; g%ripi(j, 2) = 1._real64/x
      x = ad*bd; x = x*cd; g%ripi(j, 3) = -1._real64/x
    end do
    status = 0
  end function
end module forecast_live_radiation_halo

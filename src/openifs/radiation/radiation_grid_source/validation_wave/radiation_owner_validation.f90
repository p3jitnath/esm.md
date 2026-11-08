!> Check complete native radiation owners without changing field values.
!! All arrays keep their actual bounds, owners and TARGET lifetimes. The
!! caller establishes round-to-nearest and gradual underflow once.
module forecast_radiation_owner_validation
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_ptr, c_associated, c_intptr_t
  use ieee_exceptions, only: ieee_status_type
  use forecast_native_radiation_grid, only: native_radiation_grid
  use forecast_native_radiation_transform_storage, only: native_radiation_transform_storage
  use forecast_live_radiation_setup, only: validate_live_radiation_storage
  use forecast_live_radiation_interpolation, only: native_radiation_interpolation_lifetime
  use forecast_radiation_interpolation_context, only: native_radiation_main_grid_view
  use forecast_interpolation_state_types, only: native_interpolation_state
  use forecast_public_transform, only: native_transform_control
  use forecast_distributed_partition_types, only: native_distributed_partition
  use forecast_distributed_partition_collectives, only: agree_distributed_partition_status
  use forecast_lifetime_status, only: save_lifetime_status, restore_lifetime_status
  use physical_constant_setup_port, only: forecast_physical_constants
  implicit none
  private
  public :: validate_retired_point_setup, validate_halo_point_setup
  public :: validate_first_interpolation_point_setup, validate_second_interpolation_point_setup
  public :: validate_first_interpolation_parent, validate_second_interpolation_parent
  public :: validate_radiation_latitude_owners, validate_live_latitude_owner_separation
  public :: validate_radiation_interpolation_owners, validate_radiation_output_interpolation_owners
contains
!> Preserve incoming IEEE status and errno around added integer agreement.
  integer(int32) function agree(control, local) result(status)
    type(native_transform_control), intent(in) :: control
    integer(int32), intent(in) :: local
    type(ieee_status_type) :: incoming
    integer(int32) :: old_errno
    call save_lifetime_status(incoming, old_errno)
    status = agree_distributed_partition_status(control, local)
    call restore_lifetime_status(incoming, old_errno)
  end function
!> Require one real ownership phase before the complete shared point check.
  integer(int32) function point_stage(owner, control, phase) result(status)
    type(native_radiation_transform_storage), target, intent(in) :: owner
    type(native_transform_control), intent(in) :: control
    integer(int32), intent(in) :: phase
    integer(int32) :: local
    local = 2
    if (owner%state == phase) local = 0
    status = agree(control, local)
    if (status /= 0) return
    status = validate_live_radiation_storage(owner, .true.)
    if (status /= 0) return
    local = 2
    if (lbound(owner%grid%gelam, 1) == 1 .and. lbound(owner%grid%gelat, 1) == 1 .and. &
        lbound(owner%grid%geslo, 1) == 1 .and. lbound(owner%grid%geclo, 1) == 1 .and. lbound(owner%grid%gemu, 1) == 1) local = 0
    status = agree(control, local)
  end function
!> Admit retired ZMU with all thirteen preceding native owners still alive.
!! OWNER is readonly; its borrowed grid and row lengths remain TARGET.
  integer(int32) function validate_retired_point_setup(owner, control) result(status)
    type(native_radiation_transform_storage), target, intent(in) :: owner
    type(native_transform_control), intent(in) :: control
    status = point_stage(owner, control, 4_int32)
  end function
!> Admit the complete point lifetime after the halo stage was published.
  integer(int32) function validate_halo_point_setup(owner, control) result(status)
    type(native_radiation_transform_storage), target, intent(in) :: owner
    type(native_transform_control), intent(in) :: control
    status = point_stage(owner, control, 5_int32)
  end function
!> Check actual native stage identities before dereferencing borrowed owners.
  integer(int32) function life_stage(life, control, phase) result(status)
    type(native_radiation_interpolation_lifetime), target, intent(in) :: life
    type(native_transform_control), intent(in) :: control
    integer(int32), intent(in) :: phase
    integer(int32) :: local
    local = 2
    if (life%phase == phase) then
      if (associated(life%storage) .and. associated(life%grid) .and. associated(life%ri)) then
        if (associated(life%storage%grid, life%grid)) then
          if (associated(life%ro)) then
            if (.not. associated(life%ri, life%ro)) local = 0
          end if
        end if
      end if
    end if
    status = agree(control, local)
    if (status /= 0) return
    status = point_stage(life%storage, control, 5_int32)
  end function
!> Admit the first interpolation phase and its actual point/storage owners.
  integer(int32) function validate_first_interpolation_point_setup(life, control) result(status)
    type(native_radiation_interpolation_lifetime), target, intent(in) :: life
    type(native_transform_control), intent(in) :: control
    status = life_stage(life, control, 1_int32)
  end function
!> Admit the second interpolation phase and its actual point/storage owners.
  integer(int32) function validate_second_interpolation_point_setup(life, control) result(status)
    type(native_radiation_interpolation_lifetime), target, intent(in) :: life
    type(native_transform_control), intent(in) :: control
    status = life_stage(life, control, 2_int32)
  end function
!> Add one aligned, nonwrapping payload range, including empty allocations.
  subroutine append_span(spans, count, address, bytes, alignment, valid)
    integer(c_intptr_t), intent(inout) :: spans(2, 96)
    integer, intent(inout) :: count
    type(c_ptr), intent(in) :: address
    integer(c_intptr_t), intent(in) :: bytes, alignment
    logical, intent(inout) :: valid
    integer(c_intptr_t) :: base, length
    if (.not. valid) return
    base = transfer(address, 0_c_intptr_t); length = max(1_c_intptr_t, bytes)
    if (base <= 0 .or. bytes < 0 .or. count >= 96) then
      valid = .false.; return
    end if
    if (mod(base, alignment) /= 0 .or. base > huge(base) - length) then
      valid = .false.; return
    end if
    count = count + 1; spans(:, count) = [base, base + length]
  end subroutine
!> Check every older or new owner against all subsequent live payloads.
  logical function separate_spans(spans, owned, count) result(valid)
    integer(c_intptr_t), intent(in) :: spans(2, 96)
    integer, intent(in) :: owned, count
    integer :: i, j
    valid = .false.
    do i = 1, owned
      do j = i + 1, count
        if (spans(1, i) < spans(2, j) .and. spans(1, j) < spans(2, i)) return
      end do
    end do
    valid = .true.
  end function
  integer(int32) function validate_radiation_latitude_owners(g) result(status)
    type(native_radiation_grid), target, intent(in) :: g
    integer :: n, first, last
    integer(c_intptr_t) :: base(3), bytes(3)
    status = 2; n = g%ndglg
    if (n < 2 .or. n > 8192 .or. mod(n, 2) /= 0) return
    if (.not. allocated(g%rlati) .and. .not. allocated(g%ripi)) then
      status = 0
      return
    end if
    if (.not. allocated(g%rlati) .or. .not. allocated(g%ripi)) return
    first = g%ndgsah; last = g%ndgenh
    if (first > last .or. int(last, int64) - first + 1 > n + 4) return
    if (lbound(g%rlati, 1) /= first .or. ubound(g%rlati, 1) /= last) return
    if (lbound(g%ripi, 1) /= first .or. ubound(g%ripi, 1) /= last) return
    if (lbound(g%ripi, 2) /= 1 .or. ubound(g%ripi, 2) /= 3) return
    if (.not. allocated(g%rlatig)) return
    if (lbound(g%rlatig, 1) /= -1 .or. ubound(g%rlatig, 1) /= n + 2) return
    base(1) = transfer(c_loc(g%rlati(first)), 0_c_intptr_t)
    base(2) = transfer(c_loc(g%ripi(first, 1)), 0_c_intptr_t)
    base(3) = transfer(c_loc(g%rlatig(-1)), 0_c_intptr_t)
    bytes(1) = 8_c_intptr_t*size(g%rlati, kind=c_intptr_t)
    bytes(2) = 8_c_intptr_t*size(g%ripi, kind=c_intptr_t)
    bytes(3) = 8_c_intptr_t*size(g%rlatig, kind=c_intptr_t)
    if (any(base <= 0) .or. any(bytes <= 0) .or. any(base > huge(base) - bytes)) return
    if (base(1) < base(2) + bytes(2) .and. base(2) < base(1) + bytes(1)) return
    if (base(1) < base(3) + bytes(3) .and. base(3) < base(1) + bytes(1)) return
    if (base(2) < base(3) + bytes(3) .and. base(3) < base(2) + bytes(2)) return
    status = 0
  end function
!> Append the exact surviving storage, Gaussian and point owners.
!! The caller first uses the complete helper admission; ZMU is retired.
  subroutine append_older_owners(owner, spans, count, valid, include_latitude)
    type(native_radiation_transform_storage), target, intent(in) :: owner
    integer(c_intptr_t), intent(inout) :: spans(2, 96)
    integer, intent(inout) :: count
    logical, intent(inout) :: valid
    logical, intent(in) :: include_latitude
    call append_span(spans, count, c_loc(owner%nsta), 4_c_intptr_t*size(owner%nsta, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(owner%nonl), 4_c_intptr_t*size(owner%nonl, kind=c_intptr_t), 4_c_intptr_t, valid)
call append_span(spans, count, c_loc(owner%nptrfrstlat), 4_c_intptr_t*size(owner%nptrfrstlat, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(owner%nfrstlat), 4_c_intptr_t*size(owner%nfrstlat, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(owner%nlstlat), 4_c_intptr_t*size(owner%nlstlat, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(owner%grid%rmu), 8_c_intptr_t*size(owner%grid%rmu, kind=c_intptr_t), 8_c_intptr_t, valid)
  call append_span(spans, count, c_loc(owner%grid%rsqm2), 8_c_intptr_t*size(owner%grid%rsqm2, kind=c_intptr_t), 8_c_intptr_t, valid)
call append_span(spans, count, c_loc(owner%grid%rlatig), 8_c_intptr_t*size(owner%grid%rlatig, kind=c_intptr_t), 8_c_intptr_t, valid)
  call append_span(spans, count, c_loc(owner%grid%gelam), 8_c_intptr_t*size(owner%grid%gelam, kind=c_intptr_t), 8_c_intptr_t, valid)
  call append_span(spans, count, c_loc(owner%grid%gelat), 8_c_intptr_t*size(owner%grid%gelat, kind=c_intptr_t), 8_c_intptr_t, valid)
  call append_span(spans, count, c_loc(owner%grid%geslo), 8_c_intptr_t*size(owner%grid%geslo, kind=c_intptr_t), 8_c_intptr_t, valid)
  call append_span(spans, count, c_loc(owner%grid%geclo), 8_c_intptr_t*size(owner%grid%geclo, kind=c_intptr_t), 8_c_intptr_t, valid)
    call append_span(spans, count, c_loc(owner%grid%gemu), 8_c_intptr_t*size(owner%grid%gemu, kind=c_intptr_t), 8_c_intptr_t, valid)
    if (include_latitude) then
      if (.not. allocated(owner%grid%rlati) .or. .not. allocated(owner%grid%ripi)) then
        valid = .false.; return
      end if
  call append_span(spans, count, c_loc(owner%grid%rlati), 8_c_intptr_t*size(owner%grid%rlati, kind=c_intptr_t), 8_c_intptr_t, valid)
    call append_span(spans, count, c_loc(owner%grid%ripi), 8_c_intptr_t*size(owner%grid%ripi, kind=c_intptr_t), 8_c_intptr_t, valid)
    end if
  end subroutine
!> Refuse latitude payloads that overlap any live earlier owner or record.
!! Physical constants and OWNER are borrowed readonly native records.
  integer(int32) function validate_live_latitude_owner_separation(owner, physical) result(status)
    type(native_radiation_transform_storage), target, intent(in) :: owner
    type(forecast_physical_constants), target, intent(in) :: physical
    integer(c_intptr_t) :: spans(2, 96)
    integer :: count
    logical :: valid
    status = 2
    if (.not. associated(owner%grid)) return
    if (validate_radiation_latitude_owners(owner%grid) /= 0) return
    if (.not. allocated(owner%grid%rlati) .or. .not. allocated(owner%grid%ripi)) return
! This predicate follows complete point admission in each parent.
    if (.not. allocated(owner%nsta) .or. .not. allocated(owner%nonl)) return
    if (.not. allocated(owner%nptrfrstlat) .or. .not. allocated(owner%nfrstlat) .or. .not. allocated(owner%nlstlat)) return
    if (.not. allocated(owner%grid%rmu) .or. .not. allocated(owner%grid%rsqm2)) return
    if (.not. allocated(owner%grid%gelam) .or. .not. allocated(owner%grid%gelat)) return
    if (.not. allocated(owner%grid%geslo) .or. .not. allocated(owner%grid%geclo) .or. .not. allocated(owner%grid%gemu)) return
    if (.not. associated(owner%row_lengths)) return
    count = 0; valid = .true.
  call append_span(spans, count, c_loc(owner%grid%rlati), 8_c_intptr_t*size(owner%grid%rlati, kind=c_intptr_t), 8_c_intptr_t, valid)
    call append_span(spans, count, c_loc(owner%grid%ripi), 8_c_intptr_t*size(owner%grid%ripi, kind=c_intptr_t), 8_c_intptr_t, valid)

    call append_older_owners(owner, spans, count, valid, .false.)
call append_span(spans, count, c_loc(owner%row_lengths), 4_c_intptr_t*size(owner%row_lengths, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(owner), int(storage_size(owner)/8, c_intptr_t), 8_c_intptr_t, valid)
    call append_span(spans, count, c_loc(owner%grid), int(storage_size(owner%grid)/8, c_intptr_t), 8_c_intptr_t, valid)
    call append_span(spans, count, c_loc(physical), int(storage_size(physical)/8, c_intptr_t), 8_c_intptr_t, valid)
    if (.not. valid) return
    if (.not. separate_spans(spans, 2, count)) return
    status = 0
  end function
!> Admit the complete first point/halo/latitude lifetime before release.
  integer(int32) function validate_first_interpolation_parent(life, control, physical) result(status)
    type(native_radiation_interpolation_lifetime), target, intent(in) :: life
    type(native_transform_control), intent(in) :: control
    type(forecast_physical_constants), target, intent(in) :: physical
    integer(int32) :: local
    status = validate_first_interpolation_point_setup(life, control)
    if (status /= 0) return
    local = validate_radiation_latitude_owners(life%grid)
    if (local == 0) then
      if (.not. allocated(life%grid%rlati) .or. .not. allocated(life%grid%ripi)) local = 2
    end if
    if (local == 0) local = validate_live_latitude_owner_separation(life%storage, physical)
    status = agree(control, local)
  end function
!> Admit the complete second point/halo/latitude lifetime before release.
  integer(int32) function validate_second_interpolation_parent(life, control, physical) result(status)
    type(native_radiation_interpolation_lifetime), target, intent(in) :: life
    type(native_transform_control), intent(in) :: control
    type(forecast_physical_constants), target, intent(in) :: physical
    integer(int32) :: local
    status = validate_second_interpolation_point_setup(life, control)
    if (status /= 0) return
    local = validate_radiation_latitude_owners(life%grid)
    if (local == 0) then
      if (.not. allocated(life%grid%rlati) .or. .not. allocated(life%grid%ripi)) local = 2
    end if
    if (local == 0) local = validate_live_latitude_owner_separation(life%storage, physical)
    status = agree(control, local)
  end function
!> Append the fourteen complete integer arrays owned by one exchange.
  subroutine append_interpolation_owners(state, spans, count, valid)
    type(native_interpolation_state), target, intent(in) :: state
    integer(c_intptr_t), intent(inout) :: spans(2, 96)
    integer, intent(inout) :: count
    logical, intent(inout) :: valid
    call append_span(spans, count, c_loc(state%nloeng), 4_c_intptr_t*size(state%nloeng, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(state%nslsta), 4_c_intptr_t*size(state%nslsta, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(state%nslonl), 4_c_intptr_t*size(state%nslonl, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(state%nsloff), 4_c_intptr_t*size(state%nsloff, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(state%nslcore), 4_c_intptr_t*size(state%nslcore, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(state%nslext), 4_c_intptr_t*size(state%nslext, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(state%mask_sl1), 4_c_intptr_t*size(state%mask_sl1, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(state%mask_sl2), 4_c_intptr_t*size(state%mask_sl2, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(state%mask_sld), 4_c_intptr_t*size(state%mask_sld, kind=c_intptr_t), 4_c_intptr_t, valid)
  call append_span(spans, count, c_loc(state%nslsendpos), 4_c_intptr_t*size(state%nslsendpos, kind=c_intptr_t), 4_c_intptr_t, valid)
  call append_span(spans, count, c_loc(state%nslrecvpos), 4_c_intptr_t*size(state%nslrecvpos, kind=c_intptr_t), 4_c_intptr_t, valid)
  call append_span(spans, count, c_loc(state%nslsendptr), 4_c_intptr_t*size(state%nslsendptr, kind=c_intptr_t), 4_c_intptr_t, valid)
  call append_span(spans, count, c_loc(state%nslrecvptr), 4_c_intptr_t*size(state%nslrecvptr, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(state%nslcomm), 4_c_intptr_t*size(state%nslcomm, kind=c_intptr_t), 4_c_intptr_t, valid)
  end subroutine
!> Confirm canonical bounds, labels, padding and live communication counts.
  logical function interpolation_metadata_valid(state, label) result(valid)
    type(native_interpolation_state), intent(in) :: state
    character(len=2), intent(in) :: label
    integer(int64) :: rounded
    integer :: i
    valid = .false.
    if (.not. complete_maps(state)) return
    if (state%cver /= label .or. state%nslgroup /= 2) return
    if (state%nslwide <= 0) return
    if (state%nslwide /= max(state%nslwiden, state%nslwides, state%nslwidew, state%nslwidee)) return
    if (state%naslb1_true < 1 .or. state%naslb1_true > state%naslb1) return
    rounded = ((int(state%naslb1_true, int64) + 1023)/1024)*1024 + 29
    if (int(state%naslb1, int64) /= rounded) return
    if (state%nslrpt > state%naslb1) return
    if (int(state%nslspt, int64) > int(state%nslprocs, int64)*state%naslb1) return
    if (lbound(state%nslcore, 1) /= 1) return
    if (lbound(state%mask_sl1, 1) /= 1 .or. lbound(state%mask_sl2, 1) /= 1 .or. lbound(state%mask_sld, 1) /= 1) return
    if (lbound(state%nslsendpos, 1) /= 1 .or. lbound(state%nslrecvpos, 1) /= 1) return
    if (lbound(state%nslsendptr, 1) /= 1 .or. lbound(state%nslrecvptr, 1) /= 1) return
    if (lbound(state%nslcomm, 1) /= 1) return
    valid = .true.
  end function
!> Check complete borrowed main-grid maps and Gaussian inputs before addresses.
!! Main coordinates are radians. Gaussian arrays retain bounds -1:N+2.
  logical function main_views_valid(main, main_rmu, main_rsqm2) result(valid)
    type(native_radiation_main_grid_view), intent(in) :: main
    real(real64), target, intent(in) :: main_rmu(-1:), main_rsqm2(-1:)
    integer :: n
    valid = .false.; n = main%grid%ndglg
    if (n < 2 .or. n > 8192 .or. mod(n, 2) /= 0) return
    if (.not. associated(main%row_lengths) .or. .not. associated(main%starts) .or. .not. associated(main%counts)) return
 if (.not. associated(main%first_point) .or. .not. associated(main%first_latitude) .or. .not. associated(main%last_latitude)) return
    if (.not. associated(main%process_ids) .or. .not. associated(main%latitude) .or. .not. associated(main%longitude)) return
    if (lbound(main%row_lengths, 1) /= -1 .or. ubound(main%row_lengths, 1) /= n + 2) return
    if (lbound(main%starts, 1) /= -1 .or. lbound(main%counts, 1) /= -1) return
    if (any(shape(main%starts) /= shape(main%counts))) return
    if (size(main%starts, kind=int64) < 1) return
    if (.not. is_contiguous(main%starts) .or. .not. is_contiguous(main%counts)) return
    if (size(main%first_point) /= size(main%first_latitude) .or. size(main%first_point) /= size(main%last_latitude)) return
    if (lbound(main%first_point, 1) /= 1 .or. lbound(main%first_latitude, 1) /= 1 .or. lbound(main%last_latitude, 1) /= 1) return
    if (size(main%latitude) /= main%grid%ngptot .or. size(main%longitude) /= main%grid%ngptot) return
    if (lbound(main%latitude, 1) /= 1 .or. lbound(main%longitude, 1) /= 1) return
    if (size(main_rmu) /= n + 4 .or. size(main_rsqm2) /= n + 4) return
    if (.not. is_contiguous(main_rmu) .or. .not. is_contiguous(main_rsqm2)) return
    valid = .true.
  end function
!> Append actual borrowed maps, Gaussian arrays and radian point coordinates.
  subroutine append_main_views(main, main_rmu, main_rsqm2, spans, count, valid)
    type(native_radiation_main_grid_view), target, intent(in) :: main
    real(real64), target, intent(in) :: main_rmu(-1:), main_rsqm2(-1:)
    integer(c_intptr_t), intent(inout) :: spans(2, 96)
    integer, intent(inout) :: count
    logical, intent(inout) :: valid
  call append_span(spans, count, c_loc(main%row_lengths), 4_c_intptr_t*size(main%row_lengths, kind=c_intptr_t), 4_c_intptr_t, valid)
call append_span(spans,count,c_loc(main%starts(lbound(main%starts,1),lbound(main%starts,2))),4_c_intptr_t*size(main%starts,kind=c_intptr_t),4_c_intptr_t,valid)
call append_span(spans,count,c_loc(main%counts(lbound(main%counts,1),lbound(main%counts,2))),4_c_intptr_t*size(main%counts,kind=c_intptr_t),4_c_intptr_t,valid)
  call append_span(spans, count, c_loc(main%first_point), 4_c_intptr_t*size(main%first_point, kind=c_intptr_t), 4_c_intptr_t, valid)
  call append_span(spans,count,c_loc(main%first_latitude),4_c_intptr_t*size(main%first_latitude,kind=c_intptr_t),4_c_intptr_t,valid)
    call append_span(spans,count,c_loc(main%last_latitude),4_c_intptr_t*size(main%last_latitude,kind=c_intptr_t),4_c_intptr_t,valid)
  call append_span(spans, count, c_loc(main%process_ids), 4_c_intptr_t*size(main%process_ids, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(main_rmu), 8_c_intptr_t*size(main_rmu, kind=c_intptr_t), 8_c_intptr_t, valid)
    call append_span(spans, count, c_loc(main_rsqm2), 8_c_intptr_t*size(main_rsqm2, kind=c_intptr_t), 8_c_intptr_t, valid)
    call append_span(spans, count, c_loc(main%latitude), 8_c_intptr_t*size(main%latitude, kind=c_intptr_t), 8_c_intptr_t, valid)
    call append_span(spans, count, c_loc(main%longitude), 8_c_intptr_t*size(main%longitude, kind=c_intptr_t), 8_c_intptr_t, valid)
  end subroutine
!> Check complete output owners against live owners and borrowed inputs.
integer(int32)function validate_exchange(life,main,main_rmu,main_rsqm2,partition,physical,output_direction,radiation_nrgri)result(status)
  type(native_radiation_interpolation_lifetime), target, intent(in) :: life
  type(native_radiation_main_grid_view), target, intent(in) :: main
  real(real64), target, intent(in) :: main_rmu(-1:), main_rsqm2(-1:)
  type(native_distributed_partition), target, intent(in) :: partition
  type(forecast_physical_constants), target, intent(in) :: physical
  logical, intent(in) :: output_direction
  integer(int32), target, optional, intent(in) :: radiation_nrgri(:)
  type(native_interpolation_state), pointer :: state
  integer(c_intptr_t) :: spans(2, 96)
  integer :: count, owned
  logical :: valid
  status = 2
  if (.not. associated(life%storage) .or. .not. associated(life%grid) .or. .not. associated(life%ri)) return
  if (.not. associated(life%storage%grid, life%grid)) return
  if (life%storage%state /= 5 .or. partition%phase /= 7) return
  if (output_direction) then
    if (life%phase /= 2 .or. .not. associated(life%ro)) return
    if (.not. present(radiation_nrgri)) return
    if (size(radiation_nrgri) /= life%grid%ndglg) return
    if (.not. is_contiguous(radiation_nrgri)) return
    if (associated(life%ri, life%ro)) return
    state => life%ro
    if (.not. interpolation_metadata_valid(state, 'RO')) return
    if (.not. interpolation_metadata_valid(life%ri, 'RI')) return
    if (state%ndglg /= life%grid%ndglg .or. state%ndlon /= life%grid%ndlon) return
    if (state%ndgenl /= life%grid%ndgenl .or. state%ngptot /= life%grid%ngptot) return
  else
    if (life%phase < 1 .or. life%phase > 2) return
    state => life%ri
    if (.not. interpolation_metadata_valid(state, 'RI')) return
    if (state%ndglg /= main%grid%ndglg .or. state%ndlon /= main%grid%ndlon) return
    if (state%ndgenl /= main%grid%ndgenl .or. state%ngptot /= main%grid%ngptot) return
  end if
  if (.not. main_views_valid(main, main_rmu, main_rsqm2)) return
  if (.not. associated(life%storage%row_lengths)) return
  if (validate_radiation_latitude_owners(life%grid) /= 0) return
  if (.not. allocated(life%grid%rlati) .or. .not. allocated(life%grid%ripi)) return
! Earlier owners must be complete before their base addresses are inspected.
  if (.not. allocated(life%storage%nsta) .or. .not. allocated(life%storage%nonl)) return
 if(.not.allocated(life%storage%nptrfrstlat).or..not.allocated(life%storage%nfrstlat).or..not.allocated(life%storage%nlstlat))return
  if (.not. allocated(life%grid%rmu) .or. .not. allocated(life%grid%rsqm2) .or. .not. allocated(life%grid%rlatig)) return
  if (.not. allocated(life%grid%gelam) .or. .not. allocated(life%grid%gelat)) return
  if (.not. allocated(life%grid%geslo) .or. .not. allocated(life%grid%geclo) .or. .not. allocated(life%grid%gemu)) return
  count = 0; valid = .true.
  call append_interpolation_owners(state, spans, count, valid)
  call append_older_owners(life%storage, spans, count, valid, .true.)
  if (output_direction) call append_interpolation_owners(life%ri, spans, count, valid)
  owned = count
  call append_main_views(main, main_rmu, main_rsqm2, spans, count, valid)
  if (output_direction) then
    call append_span(spans, count, c_loc(radiation_nrgri), &
                     4_c_intptr_t*size(radiation_nrgri, kind=c_intptr_t), 4_c_intptr_t, valid)
    call append_span(spans, count, c_loc(life%storage%row_lengths), &
                     4_c_intptr_t*size(life%storage%row_lengths, kind=c_intptr_t), 4_c_intptr_t, valid)
  end if
  call append_span(spans, count, c_loc(life), int(storage_size(life)/8, c_intptr_t), 8_c_intptr_t, valid)
  call append_span(spans, count, c_loc(main), int(storage_size(main)/8, c_intptr_t), 8_c_intptr_t, valid)
  call append_span(spans, count, c_loc(life%storage), int(storage_size(life%storage)/8, c_intptr_t), 8_c_intptr_t, valid)
  call append_span(spans, count, c_loc(life%grid), int(storage_size(life%grid)/8, c_intptr_t), 8_c_intptr_t, valid)
  call append_span(spans, count, c_loc(life%ri), int(storage_size(life%ri)/8, c_intptr_t), 8_c_intptr_t, valid)
 if (output_direction) call append_span(spans, count, c_loc(life%ro), int(storage_size(life%ro)/8, c_intptr_t), 8_c_intptr_t, valid)
  call append_span(spans, count, c_loc(partition), int(storage_size(partition)/8, c_intptr_t), 8_c_intptr_t, valid)
  call append_span(spans, count, c_loc(physical), int(storage_size(physical)/8, c_intptr_t), 8_c_intptr_t, valid)
  if (.not. valid) return
  if (.not. separate_spans(spans, owned, count)) return
  status = 0
  end function
!> Validate complete input interpolation owners without modifying data.
  integer(int32)function validate_radiation_interpolation_owners(life,main,main_rmu,main_rsqm2,partition,physical)result(status)
  type(native_radiation_interpolation_lifetime), target, intent(in) :: life
  type(native_radiation_main_grid_view), target, intent(in) :: main
  real(real64), target, intent(in) :: main_rmu(-1:), main_rsqm2(-1:)
  type(native_distributed_partition), target, intent(in) :: partition
  type(forecast_physical_constants), target, intent(in) :: physical
  status = validate_exchange(life, main, main_rmu, main_rsqm2, partition, physical, .false.)
end function
!> Validate complete output interpolation owners without modifying data.
integer(int32)function validate_radiation_output_interpolation_owners(life,main,main_rmu,main_rsqm2,radiation_nrgri,partition,physical)result(status)
type(native_radiation_interpolation_lifetime), target, intent(in) :: life
type(native_radiation_main_grid_view), target, intent(in) :: main
real(real64), target, intent(in) :: main_rmu(-1:), main_rsqm2(-1:)
integer(int32), target, intent(in) :: radiation_nrgri(:)
type(native_distributed_partition), target, intent(in) :: partition
type(forecast_physical_constants), target, intent(in) :: physical
status = validate_exchange(life, main, main_rmu, main_rsqm2, partition, physical, .true., radiation_nrgri)
end function
logical function complete_maps(state) result(complete)
  type(native_interpolation_state), intent(in) :: state
  complete = .false.
  if (.not. allocated(state%nloeng)) return
  if (.not. allocated(state%nslsta)) return
  if (.not. allocated(state%nslonl)) return
  if (.not. allocated(state%nsloff)) return
  if (.not. allocated(state%nslcore)) return
  if (.not. allocated(state%nslext)) return
  if (.not. allocated(state%mask_sl1)) return
  if (.not. allocated(state%mask_sl2)) return
  if (.not. allocated(state%mask_sld)) return
  if (.not. allocated(state%nslsendpos)) return
  if (.not. allocated(state%nslrecvpos)) return
  if (.not. allocated(state%nslsendptr)) return
  if (.not. allocated(state%nslrecvptr)) return
  if (.not. allocated(state%nslcomm)) return
  if (state%ndglg < 2 .or. state%ndglg > 8192 .or. mod(state%ndglg, 2) /= 0) return
  if (state%ndlon < 1 .or. state%ndlon > 32768) return
  if (state%ndgenl < 1 .or. state%ndgenl > state%ndglg) return
  if (state%ngptot < 1 .or. state%ngptot > 268435456) return
  if (state%naslb1 < 1 .or. state%naslb1 > 268435456) return
  if (min(state%nslwiden, state%nslwides, state%nslwidew, state%nslwidee) < 0) return
  if (max(state%nslwiden, state%nslwides, state%nslwidew, state%nslwidee) > 63) return
  if (lbound(state%nloeng, 1) /= -1 .or. ubound(state%nloeng, 1) /= state%ndglg + 2) return
  if (lbound(state%nslsta, 1) /= 1 - state%nslwiden) return
  if (ubound(state%nslsta, 1) /= state%ndgenl + state%nslwides) return
  if (lbound(state%nslonl, 1) /= lbound(state%nslsta, 1)) return
  if (ubound(state%nslonl, 1) /= ubound(state%nslsta, 1)) return
  if (lbound(state%nsloff, 1) /= lbound(state%nslsta, 1)) return
  if (ubound(state%nsloff, 1) /= ubound(state%nslsta, 1)) return
  if (lbound(state%nslext, 1) /= 1 - state%ndlon .or. ubound(state%nslext, 1) /= 2*state%ndlon) return
  if (lbound(state%nslext, 2) /= lbound(state%nslsta, 1)) return
  if (ubound(state%nslext, 2) /= ubound(state%nslsta, 1)) return
  if (state%nslprocs < 0 .or. state%nslprocs > 65536) return
  if (state%nslrpt < 0 .or. state%nslspt < 0) return
  if (size(state%nslcomm) /= state%nslprocs) return
  if (size(state%nslsendptr) /= state%nslprocs + 1) return
  if (size(state%nslrecvptr) /= state%nslprocs + 1) return
  if (size(state%nslsendpos) /= state%nslspt) return
  if (size(state%nslrecvpos) /= state%nslrpt) return
  if (size(state%nslcore) /= state%ngptot) return
  if (size(state%nloeng) /= state%ndglg + 4) return
  if (size(state%nslsta) /= size(state%nslonl)) return
  if (size(state%nslsta) /= size(state%nsloff)) return
  if (size(state%mask_sl1) /= state%naslb1 + 4) return
  if (size(state%mask_sl2) /= state%naslb1 + 4) return
  if (size(state%mask_sld) /= state%naslb1 + 4) return
  complete = .true.
end function
end module forecast_radiation_owner_validation

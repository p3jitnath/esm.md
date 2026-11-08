!> Draft native predicates for the next exact radiation validation family.
!! Partial source only: complete10-file binding and linking remain pending.
module forecast_radiation_validation_draft
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_loc, c_intptr_t
  use forecast_native_radiation_grid, only: native_radiation_grid
  use forecast_interpolation_state_types, only: native_interpolation_state
  implicit none
  private
  public :: validate_radiation_latitude_owners
contains
!> Refuse damaged local latitude/three-coefficient owners without changing data.
!! Native array bounds replace private descriptors. Both absent owners are valid.
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
end module forecast_radiation_validation_draft

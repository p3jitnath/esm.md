!> Restore target-grid radiation coordinates and its modified solar cosine.
!! This is the complete private posttransport leaf. It owns no copied grid
!! or field carrier. The caller retains every actual TARGET owner.
module forecast_radiation_posttransport_fields
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_loc, c_intptr_t
  use forecast_native_radiation_grid, only: native_radiation_grid
  implicit none
  private
  public :: restore_radiation_posttransport_fields
  interface
    function public_maximum_number(a, b) bind(C, name='fmax') result(value)
      import :: c_double
      real(c_double), value :: a, b
      real(c_double) :: value
    end function
  end interface
contains
!> Implement source quiet greater-than selection through public maximum-number.
!! Quiet NaN selects the finite threshold; signaling NaN retains the service's
!! natural invalid operation before integer classification selects the floor.
  logical function quiet_above_threshold(value) result(above)
    real(real64), intent(in) :: value
    integer(int64) :: word
    real(real64), parameter :: threshold = 1.0e-10_real64
    integer(int64), parameter :: threshold_word = transfer(threshold, 0_int64)
    word = transfer(public_maximum_number(value, threshold), 0_int64)
    above = .false.
    if (iand(word, int(z'7ff0000000000000', int64)) == int(z'7ff0000000000000', int64)) then
      if (iand(word, int(z'000fffffffffffff', int64)) /= 0_int64) return
    end if
    above = word /= threshold_word
  end function
!> Add an aligned, nonwrapping span from one admitted actual array/record.
  subroutine add_span(base, finish, index, address, bytes, valid)
    integer(c_intptr_t), intent(inout) :: base(12), finish(12)
    integer, intent(in) :: index
    integer(c_intptr_t), intent(in) :: address, bytes
    logical, intent(inout) :: valid
    if (.not. valid) return
    if (address <= 0 .or. bytes <= 0) then
      valid = .false.; return
    end if
    if (mod(address, 8_c_intptr_t) /= 0 .or. address > huge(address) - bytes) then
      valid = .false.; return
    end if
    base(index) = address; finish(index) = address + bytes
  end subroutine
!> Copy four target coordinates, then update active modified solar cosines.
!! FIRST_TARGET is a zero-based target point; ACTIVE is1:8. Actual point
!! coordinates have bounds1:G%NGPTOT and radian/dimensionless units. Output
!! vectors retain all entries after ACTIVE. RRAE is dimensionless curvature.
!! All arrays are ordinary TARGET views, admitted contiguous before writing.
!! Return0 succeeds;2 refuses before mutation. FP mode belongs to the caller.
  integer(int32) function restore_radiation_posttransport_fields(g, first_target, active, rrae, solar_cosine, &
                                         longitude, sine_latitude, sine_longitude, cosine_longitude, modified_cosine) result(status)
    type(native_radiation_grid), target, intent(in) :: g
    integer(int32), intent(in) :: first_target, active
    real(real64), target, intent(in) :: rrae, solar_cosine(:)
   real(real64), target, intent(inout) :: longitude(:), sine_latitude(:), sine_longitude(:), cosine_longitude(:), modified_cosine(:)
    integer(c_intptr_t) :: base(12), finish(12), bytes, point_bytes
    integer :: i, j, k, n
    logical :: valid
    real(real64) :: stage, mu, value
    status = 2
    if (active < 1 .or. active > 8 .or. first_target < 0) return
    n = g%ngptot
    if (n < 1 .or. first_target >= n) return
    if (int(first_target, int64) + active > n) return
    if (.not. allocated(g%gelam) .or. .not. allocated(g%geslo)) return
    if (.not. allocated(g%geclo) .or. .not. allocated(g%gemu)) return
    if (lbound(g%gelam, 1) /= 1 .or. size(g%gelam) /= n) return
    if (lbound(g%geslo, 1) /= 1 .or. size(g%geslo) /= n) return
    if (lbound(g%geclo, 1) /= 1 .or. size(g%geclo) /= n) return
    if (lbound(g%gemu, 1) /= 1 .or. size(g%gemu) /= n) return
    if (size(solar_cosine) < active .or. size(longitude) < active .or. size(sine_latitude) < active) return
    if (size(sine_longitude) < active .or. size(cosine_longitude) < active .or. size(modified_cosine) < active) return
    if (.not. is_contiguous(solar_cosine) .or. .not. is_contiguous(longitude) .or. .not. is_contiguous(sine_latitude)) return
if (.not. is_contiguous(sine_longitude) .or. .not. is_contiguous(cosine_longitude) .or. .not. is_contiguous(modified_cosine)) return
    valid = .true.; bytes = 8_c_intptr_t*active; point_bytes = 8_c_intptr_t*n
   call add_span(base, finish, 1, transfer(c_loc(longitude(1)), 0_c_intptr_t), 8_c_intptr_t*size(longitude, kind=c_intptr_t), valid)
  call add_span(base,finish,2,transfer(c_loc(sine_latitude(1)),0_c_intptr_t),8_c_intptr_t*size(sine_latitude,kind=c_intptr_t),valid)
call add_span(base,finish,3,transfer(c_loc(sine_longitude(1)),0_c_intptr_t),8_c_intptr_t*size(sine_longitude,kind=c_intptr_t),valid)
call add_span(base,finish,4,transfer(c_loc(cosine_longitude(1)),0_c_intptr_t),8_c_intptr_t*size(cosine_longitude,kind=c_intptr_t),valid)
    call add_span(base,finish,5,transfer(c_loc(solar_cosine(1)),0_c_intptr_t),8_c_intptr_t*size(solar_cosine,kind=c_intptr_t),valid)
call add_span(base,finish,6,transfer(c_loc(modified_cosine(1)),0_c_intptr_t),8_c_intptr_t*size(modified_cosine,kind=c_intptr_t),valid)
    call add_span(base, finish, 7, transfer(c_loc(g%gelam(1)), 0_c_intptr_t), point_bytes, valid)
    call add_span(base, finish, 8, transfer(c_loc(g%geslo(1)), 0_c_intptr_t), point_bytes, valid)
    call add_span(base, finish, 9, transfer(c_loc(g%geclo(1)), 0_c_intptr_t), point_bytes, valid)
    call add_span(base, finish, 10, transfer(c_loc(g%gemu(1)), 0_c_intptr_t), point_bytes, valid)
    call add_span(base, finish, 11, transfer(c_loc(rrae), 0_c_intptr_t), 8_c_intptr_t, valid)
    call add_span(base, finish, 12, transfer(c_loc(g), 0_c_intptr_t), int(storage_size(g)/8, c_intptr_t), valid)
    if (.not. valid) return
    do i = 1, 6
      do j = i + 1, 12
        if (base(i) < finish(j) .and. base(j) < finish(i)) return
      end do
    end do
! The four coordinate families retain the original field-major copy order.
    do i = 1, active
      k = first_target + i; longitude(i) = g%gelam(k)
    end do
    do i = 1, active
      k = first_target + i; sine_longitude(i) = g%geslo(k)
    end do
    do i = 1, active
      k = first_target + i; cosine_longitude(i) = g%geclo(k)
    end do
    do i = 1, active
      k = first_target + i; sine_latitude(i) = g%gemu(k)
    end do
    stage = rrae + 2.0_real64
    stage = rrae*stage
    do i = 1, active
      mu = solar_cosine(i)
      if (quiet_above_threshold(mu)) then
        value = mu*mu
        value = value + stage
        value = sqrt(value)
        value = value - mu
        value = rrae/value
      else
        value = sqrt(stage)
        value = rrae/value
      end if
      modified_cosine(i) = value
    end do
    status = 0
  end function
end module

!> Own source reference-temperature corrections and acoustic temperatures.
module forecast_reference_temperature_children
  use iso_c_binding, only: c_int, c_int64_t, c_double
  implicit none
  private
  public :: native_reference_temperature_correction, initialize_temperature_correction_controls
  public :: allocate_reference_temperature_correction, initialize_reference_temperature_correction
  public :: release_reference_temperature_correction, initialize_acoustic_reference_temperature
  public :: release_acoustic_reference_temperature
  !> Temperature responses use K, with RCORDIH at0:levels and others at1:levels.
  type :: native_reference_temperature_correction
    real(c_double), allocatable :: rcordit(:), rcordih(:), rcordif(:)
  end type
  interface
    function public_power(base, exponent) bind(C, name='pow') result(output)
      import c_double
      real(c_double), value :: base, exponent
      real(c_double) :: output
    end function
  end interface
contains
  !> Set the three source controls on the ECMWF3D semi-Lagrangian route.
  integer(c_int) function initialize_temperature_correction_controls(nconf, lecmwf, lr2d, lr3d, lslag, &
                                                                     rcmslp0, rintopt, rrintopt) result(status)
    integer(c_int), intent(in) :: nconf
    logical, intent(in) :: lecmwf, lr2d, lr3d, lslag
    real(c_double), intent(inout) :: rcmslp0, rintopt, rrintopt
    real(c_double), volatile :: one, reciprocal
    status = 2
    if (nconf /= 1 .or. transfer(lecmwf, 0_c_int) /= 1 .or. transfer(lslag, 0_c_int) /= 1) return
    if (transfer(lr2d, 0_c_int) /= 0 .or. transfer(lr3d, 0_c_int) /= 1) return
    one = 1.0_c_double; reciprocal = one/one
    rintopt = one; rrintopt = reciprocal; rcmslp0 = one
    status = 0
  end function
  !> Allocate RCORDIT, RCORDIH and RCORDIF in source order, without filling.
  integer(c_int) function allocate_reference_temperature_correction(state, levels) result(status)
    type(native_reference_temperature_correction), intent(inout) :: state
    integer(c_int), intent(in) :: levels
    type(native_reference_temperature_correction) :: pending
    integer :: allocation_status
    status = 2
    if (levels < 1 .or. levels > 255) return
    if (allocated(state%rcordit) .or. allocated(state%rcordih) .or. allocated(state%rcordif)) return
    allocate (pending%rcordit(levels), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%rcordih(0:levels), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%rcordif(levels), stat=allocation_status)
    if (allocation_status /= 0) goto900
    call move_alloc(pending%rcordit, state%rcordit)
    call move_alloc(pending%rcordih, state%rcordih)
    call move_alloc(pending%rcordif, state%rcordif)
    status = 0
    return
900 continue
    call release_reference_temperature_correction(pending)
    status = 1
  end function
  !> Calculate the complete SURCORDI response in increasing source level order.
  !! RD uses J/(kg K), RG m/s**2, VP00 Pa, RDTDZ1 K/m, RTSUR/RTTROP K.
  !! HALF_A uses Pa and HALF_B is dimensionless. Both have bounds0:levels.
  !! The one-level branch reads neither optional coordinate array and writes
  !! only RCORDIT(1). Other preallocated payload values remain unchanged.
  integer(c_int) function initialize_reference_temperature_correction(state, levels, rd, rg, vp00, rdtdz1, &
                                                                      rtsur, rttrop, half_a, half_b) result(status)
    type(native_reference_temperature_correction), intent(inout) :: state
    integer(c_int), intent(in) :: levels
    real(c_double), intent(in) :: rd, rg, vp00, rdtdz1, rtsur, rttrop
    real(c_double), optional, intent(in) :: half_a(0:), half_b(0:)
    real(c_double) :: alpha, asum, bsum, work, full_pressure, half_pressure, full_temperature, half_temperature, value, base
    integer(c_int) :: j
    status = 2
    if (levels < 1 .or. levels > 255) return
    if (.not. positive_finite(rd) .or. .not. positive_finite(rg) .or. .not. positive_finite(vp00)) return
    if (.not. positive_finite(rtsur) .or. .not. positive_finite(rttrop) .or. .not. finite_value(rdtdz1)) return
    if (.not. allocated(state%rcordit) .or. .not. allocated(state%rcordih) .or. .not. allocated(state%rcordif)) return
    if (lbound(state%rcordit, 1) /= 1 .or. size(state%rcordit) /= levels) return
    if (lbound(state%rcordih, 1) /= 0 .or. size(state%rcordih) /= levels + 1) return
    if (lbound(state%rcordif, 1) /= 1 .or. size(state%rcordif) /= levels) return
    if (levels == 1) then
      state%rcordit(1) = 1.0_c_double; status = 0; return
    end if
    if (.not. present(half_a) .or. .not. present(half_b)) return
    if (size(half_a) < levels + 1 .or. size(half_b) < levels + 1) return
    do j = 0, levels
      if (.not. nonnegative_finite(half_a(j)) .or. .not. nonnegative_finite(half_b(j))) return
      if (j > 0) then
        if (transfer(half_a(j), 0_c_int64_t) == 0 .and. transfer(half_b(j), 0_c_int64_t) == 0) return
      end if
    end do
    alpha = -rdtdz1
    alpha = alpha*rd
    alpha = alpha/rg
    state%rcordih(0) = 0.0_c_double
    do j = 1, levels
      asum = half_a(j) + half_a(j - 1)
      bsum = half_b(j) + half_b(j - 1)
      work = bsum*vp00
      work = asum + work
      full_pressure = 0.5_c_double*work
      work = half_b(j)*vp00
      half_pressure = half_a(j) + work
      base = full_pressure/vp00
      work = public_power(base, alpha)
      full_temperature = rtsur*work
      base = half_pressure/vp00
      work = public_power(base, alpha)
      half_temperature = rtsur*work
      value = 0.5_c_double*bsum
      value = value*alpha
      value = value*full_temperature
      value = value*vp00
      value = value/full_pressure
      state%rcordif(j) = value
      if (full_temperature > rttrop) then
        state%rcordit(j) = value
      else
        state%rcordit(j) = 0.0_c_double
      end if
      value = half_b(j)*alpha
      value = value*half_temperature
      value = value*vp00
      state%rcordih(j) = value/half_pressure
    end do
    status = 0
  end function
  !> Reverse release detaches each named owner before its storage is freed.
  subroutine release_reference_temperature_correction(state)
    type(native_reference_temperature_correction), intent(inout) :: state
    real(c_double), allocatable :: detached(:)
    if (allocated(state%rcordif)) then
      call move_alloc(state%rcordif, detached); deallocate (detached)
    end if
    if (allocated(state%rcordih)) then
      call move_alloc(state%rcordih, detached); deallocate (detached)
    end if
    if (allocated(state%rcordit)) then
      call move_alloc(state%rcordit, detached); deallocate (detached)
    end if
  end subroutine
  !> Allocate source SITRAM and apply its constant or temperature-ratio branch.
  !! SITRA, STANDARD_TEMPERATURE and SITRAM use K. Only option1 reads the
  !! borrowed atmosphere array. Private results publish on complete success.
  integer(c_int) function initialize_acoustic_reference_temperature(sitram, levels, sitra, option, &
                                                                    standard_temperature) result(status)
    real(c_double), allocatable, intent(inout) :: sitram(:)
    integer(c_int), intent(in) :: levels, option
    real(c_double), intent(in) :: sitra
    real(c_double), optional, intent(in) :: standard_temperature(:)
    real(c_double), allocatable :: pending(:)
    real(c_double) :: value
    integer(c_int) :: j
    integer :: allocation_status
    status = 2
    if (levels < 1 .or. levels > 255 .or. allocated(sitram)) return
    if (.not. positive_finite(sitra)) return
    if (option == 1) then
      if (.not. present(standard_temperature)) return
      if (size(standard_temperature) < levels) return
      do j = 1, levels
        if (.not. positive_finite(standard_temperature(j))) return
      end do
    end if
    allocate (pending(levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    if (option == 1) then
      do j = 1, levels
        value = standard_temperature(j)/standard_temperature(levels)
        value = sitra*value
        if (.not. positive_finite(value)) then
          deallocate (pending); return
        end if
        pending(j) = value
      end do
    else
      pending = sitra
    end if
    call move_alloc(pending, sitram)
    status = 0
  end function
  !> Release only SITRAM; empty and repeated release are valid.
  subroutine release_acoustic_reference_temperature(sitram)
    real(c_double), allocatable, intent(inout) :: sitram(:)
    if (allocated(sitram)) deallocate (sitram)
  end subroutine
  pure logical function finite_value(value) result(valid)
    real(c_double), intent(in) :: value
    integer(c_int64_t) :: bits
    bits = transfer(value, bits)
    valid = ibits(bits, 52, 11) /= 2047_c_int64_t
  end function
  pure logical function positive_finite(value) result(valid)
    real(c_double), intent(in) :: value
    integer(c_int64_t) :: bits
    bits = transfer(value, bits)
    valid = .not. btest(bits, 63) .and. bits /= 0 .and. ibits(bits, 52, 11) /= 2047_c_int64_t
  end function
  pure logical function nonnegative_finite(value) result(valid)
    real(c_double), intent(in) :: value
    integer(c_int64_t) :: bits
    bits = transfer(value, bits)
    valid = .not. btest(bits, 63) .and. ibits(bits, 52, 11) /= 2047_c_int64_t
  end function
end module forecast_reference_temperature_children

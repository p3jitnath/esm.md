!> Prepare the source vertical interpolation coefficients and lookup owners.
module forecast_vertical_interpolation_coefficients
  use iso_c_binding, only: c_int, c_int64_t, c_double
  implicit none
  private
  public :: native_vertical_interpolation_controls, native_vertical_interpolation_coefficients
  public :: initialize_vertical_interpolation_coefficients, release_vertical_interpolation_coefficients
  !> Source logical switches and pressure-filter parameters, supplied explicitly.
  !! Pressure thresholds use Pa; filter strengths and ratios are dimensionless.
  type :: native_vertical_interpolation_controls
    logical :: lslhd, lslhdquad, lhoislt, lrhsvweno, lsltvweno, lslvf
    real(c_double) :: slvfeps, p_slvf_bot, slvfmin, slvftr, p_slvf_tr
  end type
  !> Own twelve arrays with source names, ranks and lower bounds.
  !! VCUICO/VSLD/VSLDW/VSLVF and their H variants start at level0.
  !! GAMMA_WENO and VRDETAR start at1; NVAUTF/NVAUTH start at0.
  !! Source-unwritten rows keep their ordinary allocation preimages.
  type :: native_vertical_interpolation_coefficients
    real(c_double), allocatable :: vcuico(:, :), vsld(:, :), vsldw(:, :, :), vslvf(:, :, :)
    real(c_double), allocatable :: vcuicoh(:, :), vsldh(:, :), vsldwh(:, :, :), vslvfh(:, :, :)
    real(c_double), allocatable :: gamma_weno(:, :), vrdetar(:)
    integer(c_int), allocatable :: nvautf(:), nvauth(:)
    integer(c_int) :: nrlevx
    real(c_double) :: vrlevx
  end type
  interface
    function public_exp(value) bind(C, name='exp') result(output)
      import c_double
      real(c_double), value :: value
      real(c_double) :: output
    end function
  end interface
contains
  !> Calculate the frozen selected SUVSLETA route at live4:255 levels.
  !! FULL_ETA(0:levels+1) and HALF_ETA(0:levels) are finite increasing
  !! dimensionless coordinates from the canonical vertical producer.
  !! LREGETA is its canonical regular-coordinate switch. Only LSLVF may
  !! vary among the admitted scheme switches. Optional pressure/filter
  !! arrays are read only when required; HALF_B is dimensionless.
  !! Status2 refuses before publication,1 releases pending allocations,
  !! and0 transfers all twelve owners and both source scalar outputs.
  integer(c_int) function initialize_vertical_interpolation_coefficients(state, controls, levels, &
                                                   full_eta, half_eta, lregeta, half_b, full_pressure, half_pressure) result(status)
    type(native_vertical_interpolation_coefficients), intent(inout) :: state
    type(native_vertical_interpolation_controls), intent(in) :: controls
    integer(c_int), intent(in) :: levels
    real(c_double), intent(in) :: full_eta(0:), half_eta(0:)
    logical, intent(in) :: lregeta
    real(c_double), optional, intent(in) :: half_b(0:), full_pressure(:), half_pressure(0:)
    type(native_vertical_interpolation_coefficients) :: pending
    real(c_double), allocatable, target :: scratch(:)
    real(c_double), pointer :: mask(:), strength(:)
    real(c_double) :: a, t, d1, d2, d3, d4, d5, spacing, coordinate_step, lookup_value
    integer(c_int) :: j, reference, bottom, nr
    integer :: allocation_status
    status = 2
    if (levels < 4 .or. levels > 255) return
    if (transfer(controls%lslhd, 0_c_int) /= 0 .or. transfer(controls%lslhdquad, 0_c_int) /= 0) return
    if (transfer(controls%lhoislt, 0_c_int) /= 0 .or. transfer(controls%lrhsvweno, 0_c_int) /= 0) return
    if (transfer(controls%lsltvweno, 0_c_int) /= 1) return
    if (.not. canonical_logical(controls%lslvf) .or. .not. canonical_logical(lregeta)) return
    if (size(full_eta) < levels + 2 .or. size(half_eta) < levels + 1) return
    if (.not. finite_values(full_eta(0:levels + 1)) .or. .not. finite_values(half_eta(0:levels))) return
    do j = 1, levels + 1
      if (full_eta(j) <= full_eta(j - 1)) return
    end do
    do j = 1, levels
      if (half_eta(j) <= half_eta(j - 1)) return
    end do
    if (allocated(state%vcuico)) return
    if (allocated(state%vsld)) return
    if (allocated(state%vsldw)) return
    if (allocated(state%vslvf)) return
    if (allocated(state%vcuicoh)) return
    if (allocated(state%vsldh)) return
    if (allocated(state%vsldwh)) return
    if (allocated(state%vslvfh)) return
    if (allocated(state%gamma_weno)) return
    if (allocated(state%nvautf)) return
    if (allocated(state%nvauth)) return
    if (allocated(state%vrdetar)) return
    if (controls%lslvf) then
      if (.not. finite_values([controls%slvfeps, controls%p_slvf_bot, controls%slvfmin, &
                               controls%slvftr, controls%p_slvf_tr])) return
      if (controls%slvfeps < 0.0_c_double .or. controls%p_slvf_bot < 0.0_c_double) return
      if (controls%slvfmin < 0.0_c_double .or. controls%slvfmin > 1.0_c_double) return
      if (controls%slvftr <= 0.0_c_double .or. controls%p_slvf_tr <= 0.0_c_double) return
      if (.not. present(full_pressure)) return
      if (size(full_pressure) < levels) return
      if (.not. finite_values(full_pressure(1:levels))) return
      if (controls%p_slvf_bot == 0.0_c_double) then
        if (.not. present(half_b)) return
        if (size(half_b) < levels + 1) return
        if (.not. finite_values(half_b(0:levels))) return
      else
        if (.not. present(half_pressure)) return
        if (size(half_pressure) < levels + 1) return
        if (.not. finite_values(half_pressure(0:levels))) return
      end if
    end if
    allocate (scratch(0:2*levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    mask(0:levels) => scratch(0:levels)
    strength(1:levels) => scratch(levels + 1:2*levels)
    if (controls%lslvf) then
      mask = 0.0_c_double
      if (controls%p_slvf_bot == 0.0_c_double) then
        do j = 0, levels
          if (half_b(j) /= 0.0_c_double) exit
          mask(j) = 1.0_c_double
        end do
      else
        bottom = 0
        do j = 1, levels
          if (half_pressure(j) <= controls%p_slvf_bot) bottom = bottom + 1
        end do
        mask(0:bottom) = 1.0_c_double
      end if
      do j = 1, levels
        a = 1.0_c_double - full_pressure(j)
        a = a/controls%p_slvf_tr
        a = public_exp(a)
        a = a/controls%slvftr
        a = 1.0_c_double + a
        t = 1.0_c_double - controls%slvfmin
        t = t*1.0_c_double
        t = t/a
        t = controls%slvfmin + t
        strength(j) = controls%slvfeps*t
      end do
    end if
    allocate (pending%vcuico(4, 0:levels - 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%vsld(3, 0:levels - 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%vsldw(3, 3, 0:levels - 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%vslvf(3, 3, 0:levels - 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    call coefficient_group(levels, full_eta, 0_c_int, controls%lslvf, mask, strength, &
                           pending%vcuico, pending%vsld, pending%vsldw, pending%vslvf)
    allocate (pending%vcuicoh(4, 0:levels - 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%vsldh(3, 0:levels - 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%vsldwh(3, 3, 0:levels - 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    allocate (pending%vslvfh(3, 3, 0:levels - 1), stat=allocation_status)
    if (allocation_status /= 0) goto900
    call coefficient_group(levels, half_eta, 1_c_int, controls%lslvf, mask, strength, &
                           pending%vcuicoh, pending%vsldh, pending%vsldwh, pending%vslvfh)
    allocate (pending%gamma_weno(levels, 3), stat=allocation_status)
    if (allocation_status /= 0) goto900
    if (.not. lregeta) then
      do j = 2, levels - 4
        d1 = full_eta(j - 1) - full_eta(j + 3)
        d2 = full_eta(j - 1) - full_eta(j + 4)
        d3 = full_eta(j) - full_eta(j + 3)
        d4 = full_eta(j) - full_eta(j + 4)
        d5 = full_eta(j) - full_eta(j - 1)
        t = d1*d2
        pending%gamma_weno(j, 3) = 1.0_c_double/t
        a = d2*d4
        pending%gamma_weno(j, 2) = 1.0_c_double/a
        a = d3*d4
        a = a/t
        a = 1.0_c_double - a
        t = d5*d4
        pending%gamma_weno(j, 1) = a/t
      end do
    end if
    spacing = 1.0_c_double
    do j = 1, levels
      t = half_eta(j) - half_eta(j - 1)
      spacing = min(spacing, t)
    end do
    t = 2.0_c_double/spacing
    t = t + 0.5_c_double
    ! Keep NINT inside its representable native domain before allocation.
    if (.not. finite_scalar(t)) goto910
    if (t >= 1999999.5_c_double) goto910
    nr = nint(t, kind=c_int) + 1
    if (nr < 1 .or. nr > 2000000) goto910
    pending%nrlevx = nr
    pending%vrlevx = real(nr, c_double)
    coordinate_step = full_eta(levels + 1) - full_eta(0)
    coordinate_step = coordinate_step/pending%vrlevx
    allocate (pending%nvautf(0:nr), stat=allocation_status)
    if (allocation_status /= 0) goto900
    reference = 1
    do j = 0, nr
      lookup_value = real(j, c_double)*coordinate_step
      if (lookup_value >= full_eta(reference + 1)) then
        if (reference < levels - 1) reference = reference + 1
      end if
      pending%nvautf(j) = reference
    end do
    allocate (pending%nvauth(0:nr), stat=allocation_status)
    if (allocation_status /= 0) goto900
    reference = 1
    do j = 0, nr
      lookup_value = real(j, c_double)*coordinate_step
      if (lookup_value >= half_eta(reference)) then
        if (reference < levels - 1) reference = reference + 1
      end if
      pending%nvauth(j) = reference
    end do
    allocate (pending%vrdetar(levels), stat=allocation_status)
    if (allocation_status /= 0) goto900
    do j = 2, levels
      d1 = half_eta(j) - half_eta(j - 1)
      d2 = half_eta(j - 1) - half_eta(j - 2)
      pending%vrdetar(j) = d1/d2
    end do
    pending%vrdetar(1) = 1.0_c_double
    call move_alloc(pending%vcuico, state%vcuico)
    call move_alloc(pending%vsld, state%vsld)
    call move_alloc(pending%vsldw, state%vsldw)
    call move_alloc(pending%vslvf, state%vslvf)
    call move_alloc(pending%vcuicoh, state%vcuicoh)
    call move_alloc(pending%vsldh, state%vsldh)
    call move_alloc(pending%vsldwh, state%vsldwh)
    call move_alloc(pending%vslvfh, state%vslvfh)
    call move_alloc(pending%gamma_weno, state%gamma_weno)
    call move_alloc(pending%nvautf, state%nvautf)
    call move_alloc(pending%nvauth, state%nvauth)
    call move_alloc(pending%vrdetar, state%vrdetar)
    state%nrlevx = pending%nrlevx; state%vrlevx = pending%vrlevx
    deallocate (scratch)
    status = 0
    return
900 continue
    status = 1
    goto920
910 continue
    status = 2
920 continue
    call release_vertical_interpolation_coefficients(pending)
    deallocate (scratch)
  end function
  !> Retain each source subtraction, product and rounded quotient.
  subroutine coefficient_group(levels, coordinates, half, filter_active, mask, strength, cubic, diffusion, identity, filter)
    integer(c_int), intent(in) :: levels, half
    real(c_double), intent(in) :: coordinates(0:), mask(0:), strength(1:)
    logical, intent(in) :: filter_active
    real(c_double), intent(inout) :: cubic(:, 0:), diffusion(:, 0:), identity(:, :, 0:), filter(:, :, 0:)
    real(c_double) :: d1, d2, d3, d4, d5, d6, t, factor
    integer(c_int) :: j, k
    do j = 1, levels - 3
      k = j - half
      d1 = coordinates(k) - coordinates(k + 1)
      d2 = coordinates(k) - coordinates(k + 2)
      d3 = coordinates(k) - coordinates(k + 3)
      d4 = coordinates(k + 1) - coordinates(k + 2)
      d5 = coordinates(k + 1) - coordinates(k + 3)
      d6 = coordinates(k + 2) - coordinates(k + 3)
      t = d1*d2; t = t*d3; cubic(1, j) = 1.0_c_double/t
      t = d1*d4; t = t*d5; cubic(2, j) = -1.0_c_double/t
      t = d2*d4; t = t*d6; cubic(3, j) = 1.0_c_double/t
      t = d3*d5; t = t*d6; cubic(4, j) = -1.0_c_double/t
      diffusion(1, j) = 0.0_c_double; diffusion(2, j) = 0.0_c_double; diffusion(3, j) = 0.0_c_double
      identity(1, 1, j) = 1.0_c_double; identity(1, 2, j) = 0.0_c_double; identity(1, 3, j) = 0.0_c_double
      identity(2, 1, j) = 0.0_c_double; identity(2, 2, j) = 1.0_c_double; identity(2, 3, j) = 0.0_c_double
      identity(3, 1, j) = 0.0_c_double; identity(3, 2, j) = 0.0_c_double; identity(3, 3, j) = 1.0_c_double
      if (filter_active) then
        if (half == 0) then
          t = mask(j - 1) + mask(j)
          factor = strength(j)*t
        else
          factor = 2.0_c_double*strength(j)
          factor = factor*mask(j)
        end if
        t = factor*d4; t = t/d1; filter(1, 1, j) = 1.0_c_double - t
        t = factor*d4; filter(1, 2, j) = t/d5
        filter(1, 3, j) = 0.0_c_double
        t = factor*d4; filter(2, 1, j) = t/d2
        t = factor*d4; t = t/d6; filter(2, 2, j) = 1.0_c_double - t
        filter(2, 3, j) = 0.0_c_double; filter(3, 1, j) = 0.0_c_double
        t = d4*d4; t = factor*t; filter(3, 2, j) = t/(d5*d6)
        filter(3, 3, j) = 1.0_c_double
      else
        filter(1, 1, j) = 1.0_c_double; filter(1, 2, j) = 0.0_c_double; filter(1, 3, j) = 0.0_c_double
        filter(2, 1, j) = 0.0_c_double; filter(2, 2, j) = 1.0_c_double; filter(2, 3, j) = 0.0_c_double
        filter(3, 1, j) = 0.0_c_double; filter(3, 2, j) = 0.0_c_double; filter(3, 3, j) = 1.0_c_double
      end if
    end do
  end subroutine
  !> Release all twelve owners in reverse source order; repetition is valid.
  subroutine release_vertical_interpolation_coefficients(state)
    type(native_vertical_interpolation_coefficients), intent(inout) :: state
    real(c_double), allocatable :: detached1(:), detached2(:, :), detached3(:, :, :)
    integer(c_int), allocatable :: detached_integer(:)
    if (allocated(state%vrdetar)) then
      call move_alloc(state%vrdetar, detached1)
      deallocate (detached1)
    end if
    if (allocated(state%nvauth)) then
      call move_alloc(state%nvauth, detached_integer)
      deallocate (detached_integer)
    end if
    if (allocated(state%nvautf)) then
      call move_alloc(state%nvautf, detached_integer)
      deallocate (detached_integer)
    end if
    if (allocated(state%gamma_weno)) then
      call move_alloc(state%gamma_weno, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%vslvfh)) then
      call move_alloc(state%vslvfh, detached3)
      deallocate (detached3)
    end if
    if (allocated(state%vsldwh)) then
      call move_alloc(state%vsldwh, detached3)
      deallocate (detached3)
    end if
    if (allocated(state%vsldh)) then
      call move_alloc(state%vsldh, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%vcuicoh)) then
      call move_alloc(state%vcuicoh, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%vslvf)) then
      call move_alloc(state%vslvf, detached3)
      deallocate (detached3)
    end if
    if (allocated(state%vsldw)) then
      call move_alloc(state%vsldw, detached3)
      deallocate (detached3)
    end if
    if (allocated(state%vsld)) then
      call move_alloc(state%vsld, detached2)
      deallocate (detached2)
    end if
    if (allocated(state%vcuico)) then
      call move_alloc(state%vcuico, detached2)
      deallocate (detached2)
    end if
  end subroutine
  pure logical function finite_scalar(value) result(finite)
    real(c_double), intent(in) :: value
    integer(c_int64_t) :: bits
    bits = transfer(value, bits)
    finite = ibits(bits, 52, 11) /= 2047_c_int64_t
  end function
  pure logical function finite_values(values) result(finite)
    real(c_double), intent(in) :: values(:)
    integer :: j
    finite = .false.
    do j = 1, size(values)
      if (.not. finite_scalar(values(j))) return
    end do
    finite = .true.
  end function
  pure logical function canonical_logical(value) result(valid)
    logical, intent(in) :: value
    integer(c_int) :: bits
    bits = transfer(value, bits)
    valid = bits == 0 .or. bits == 1
  end function
end module forecast_vertical_interpolation_coefficients

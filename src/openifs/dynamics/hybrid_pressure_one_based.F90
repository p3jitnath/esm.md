!> Compute hybrid pressure from native one-based layer coefficient arrays.
!! Pressure and A coefficients use Pa; B coefficients and alpha are dimensionless.
!! Caller-owned contiguous arrays retain their native physical element order.
module md2asm_hybrid_pressure_one_based
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_double
  use md2asm_hybrid_pressure_and_gradients, only: hybrid_pressure_controls
  implicit none
  private
  public :: hybrid_pressure_controls, compute_hybrid_pressure_one_based
  interface
    function public_log(x) bind(C, name='log') result(value)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
    function public_exp(x) bind(C, name='exp') result(value)
      import :: c_double
      real(c_double), value :: x
      real(c_double) :: value
    end function
  end interface
contains
  !> Native Fortran entry; its explicit module interface owns array descriptors.
  !! pitch, first, last and levels are int32 counts or one-based cell indices.
  !! c supplies the accepted pressure controls and physical constants.
  !! a_half and b_half retain lower bound0 and contain levels half-grid words.
  !! half_pressure has shape(pitch,0:levels); its last row supplies surface Pa.
  !! vc, full_a, full_b, delta_a and delta_b have physical levels1:levels.
  !! Their optional extent checks use SIZE and do not require a leading word.
  !! Each coefficient array is read-only and must contain its consumed levels.
  !! The half-pressure pass writes active columns at rows0:levels-1 only.
  !! coefficients has exact shape(pitch,levels,number_fields) when present.
  !! full_pressure is in Pa, with shape(pitch,at least levels).
  !! All arrays are caller-owned, contiguous and disjoint from mutable peers.
  !! status0 is success or an accepted empty range; status2 refuses admission.
  !! status1 reports workspace allocation failure after the half-pressure pass.
  !! Preserve the accepted nearest-rounding, gradual-underflow FP contract.
  subroutine compute_hybrid_pressure_one_based(c, pitch, first, last, levels, a_half, b_half, &
                                          half_pressure, status, number_fields, field_index, vc, full_a, full_b, delta_a, delta_b, &
                                               coefficients, full_pressure)
    !! Complete GPHPRE. The final half-pressure row supplies surface pressure.
    !!
    !! half_pressure has bounds(1:pitch,0:levels). Only rows0:levels-1 are
    !! written. Optional full_pressure has shape(pitch,levels). The seven
    !! coefficient indices name delta pressure, its reciprocal, pressure
    !! ratio/log term, alpha, beta, reciprocal half pressure and reciprocal
    !! adjacent-pressure product. Their source field order is supplied by
    !! initialized typed metadata, not by compiler-specific object offsets.
    type(hybrid_pressure_controls), intent(in) :: c
    integer(int32), intent(in) :: pitch, first, last, levels
    real(real64), intent(in) :: a_half(0:), b_half(0:)
    real(real64), intent(inout) :: half_pressure(:, 0:)
    integer(int32), intent(out) :: status
    integer(int32), intent(in), optional :: number_fields, field_index(:)
    real(real64), intent(in), optional :: vc(1:), full_a(1:), full_b(1:)
    real(real64), intent(in), optional :: delta_a(1:), delta_b(1:)
    real(real64), intent(inout), optional :: coefficients(:, :, :), full_pressure(:, :)
    real(real64), allocatable :: work(:, :, :)
    integer :: cell, level, first_normal, allocation_status, nfields, j, k, used_fields
    real(real64) :: surface, top, bottom, delta, inverse_delta, ratio, alpha, beta
    real(real64) :: inverse_bottom, inverse_previous, inverse_product, temporary, other, value
    logical :: need_auxiliary
    status = 2
    if (pitch < 1 .or. levels < 0 .or. first < 1 .or. last > pitch) return
    if (levels == 0 .or. first > last) then
      status = 0
      return
    end if
    if (size(half_pressure, 1) /= pitch .or. ubound(half_pressure, 2) < levels) return
    if (ubound(a_half, 1) < levels - 1 .or. ubound(b_half, 1) < levels - 1) return
    need_auxiliary = present(coefficients) .or. present(full_pressure)
    if (need_auxiliary) then
      if (.not. present(number_fields) .or. .not. present(field_index)) return
      nfields = number_fields
      used_fields = 7
      if (c%finite_elements) used_fields = 5
      if (nfields < used_fields .or. size(field_index) < used_fields) return
      if (any(field_index(:used_fields) < 1) .or. any(field_index(:used_fields) > nfields)) return
      do j = 1, used_fields
        do k = 1, j - 1
          if (field_index(j) == field_index(k)) return
        end do
      end do
      if (.not. present(delta_b)) return
      if (size(delta_b) < levels) return
      if (present(coefficients)) then
        if (any(shape(coefficients) /= [pitch, levels, nfields])) return
      end if
      if (present(full_pressure)) then
        if (size(full_pressure, 1) /= pitch .or. size(full_pressure, 2) < levels) return
      end if
      if (c%finite_elements) then
        if (.not. present(full_a) .or. .not. present(full_b) .or. .not. present(delta_a)) return
        if (size(full_a) < levels .or. size(full_b) < levels .or. size(delta_a) < levels) return
      end if
      first_normal = 1
      do cell = first, last
        temporary = b_half(0)*half_pressure(cell, levels)
        top = a_half(0) + temporary
        if (.not. (top > c%top_pressure)) first_normal = 2
      end do
      if (.not. c%finite_elements) then
        if (first_normal <= levels) then
          if (.not. present(vc)) return
          if (size(vc) < levels) return
        end if
        if (first_normal == 2 .and. c%approximate_mode /= 0 .and. c%approximate_mode /= 1) then
          if (levels < 2) return
        end if
      end if
    end if
    ! Retain complete half-level pass before allocating/producing auxiliaries.
    do level = 0, levels - 1
      do cell = first, last
        temporary = b_half(level)*half_pressure(cell, levels)
        half_pressure(cell, level) = a_half(level) + temporary
      end do
    end do
    if (.not. need_auxiliary) then
      status = 0
      return
    end if
    allocate (work(pitch, levels, nfields), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    work = 0.0_real64
    if (c%finite_elements) then
      do cell = first, last
        surface = half_pressure(cell, levels)
        do level = 1, levels
          temporary = delta_b(level)*surface
          delta = delta_a(level) + temporary
          inverse_delta = 1.0_real64/delta
          temporary = full_b(level)*surface
          value = full_a(level) + temporary
          inverse_bottom = 1.0_real64/value
          ratio = delta*inverse_bottom
          beta = full_b(level)*inverse_bottom
          temporary = half_pressure(cell, level) - value
          alpha = temporary*inverse_bottom
          call save_first_five()
        end do
      end do
    else
      do cell = first, last
        if (c%approximate_mode == 0) inverse_previous = 1.0_real64/half_pressure(cell, first_normal - 1)
        do level = first_normal, levels
          bottom = half_pressure(cell, level)
          top = half_pressure(cell, level - 1)
          delta = bottom - top
          inverse_delta = 1.0_real64/delta
          inverse_bottom = 1.0_real64/bottom
          if (c%approximate_mode == 0) then
            temporary = bottom*inverse_previous
            ratio = public_log(temporary)
            inverse_product = inverse_bottom*inverse_previous
            inverse_previous = inverse_bottom
          else
            temporary = bottom*top
            inverse_product = 1.0_real64/temporary
            temporary = sqrt(inverse_product)
            ratio = delta*temporary
          end if
          temporary = top*inverse_delta
          temporary = temporary*ratio
          alpha = 1.0_real64 - temporary
          temporary = vc(level)*ratio
          temporary = temporary*inverse_delta
          temporary = delta_b(level) + temporary
          beta = inverse_delta*temporary
          call save_first_five()
          work(cell, level, field_index(6)) = inverse_bottom
          work(cell, level, field_index(7)) = inverse_product
        end do
        if (first_normal == 2) then
          level = 1
          bottom = half_pressure(cell, 1)
          if (c%approximate_mode == 0) then
            top = half_pressure(cell, 0)
            delta = bottom - top
            inverse_delta = 1.0_real64/delta
            temporary = bottom/c%top_pressure
            ratio = public_log(temporary)
            alpha = c%top_alpha
            inverse_bottom = 1.0_real64/bottom
            temporary = bottom*c%top_pressure
            inverse_product = 1.0_real64/temporary
          else
            delta = bottom
            if (c%approximate_mode == 1) then
              temporary = c%dry_isochoric_heat_capacity/c%dry_gas_constant
              ratio = 2.0_real64 + temporary
            else
              temporary = delta/work(cell, 2, field_index(1))
              temporary = work(cell, 2, field_index(3))*temporary
              other = half_pressure(cell, 2)/bottom
              other = sqrt(other)
              temporary = temporary*other
              ratio = 1.0_real64 + temporary
            end if
            alpha = 1.0_real64
            inverse_delta = 1.0_real64/delta
            inverse_bottom = 1.0_real64/bottom
            temporary = ratio*inverse_delta
            inverse_product = temporary*temporary
          end if
          beta = inverse_delta*delta_b(1)
          call save_first_five()
          work(cell, 1, field_index(6)) = inverse_bottom
          work(cell, 1, field_index(7)) = inverse_product
        end if
      end do
    end if
    if (present(coefficients)) coefficients = work
    if (present(full_pressure)) then
      do cell = first, last
        do level = 1, levels
          bottom = half_pressure(cell, level)
          if (c%finite_elements) then
            temporary = full_b(level)*half_pressure(cell, levels)
            value = full_a(level) + temporary
          else if (c%approximate_mode == 0) then
            if (c%arithmetic_full_pressure) then
              temporary = half_pressure(cell, level - 1) + bottom
              value = temporary*0.5_real64
            else
              temporary = -work(cell, level, field_index(4))
              temporary = public_exp(temporary)
              value = temporary*bottom
            end if
          else if (level >= first_normal) then
            temporary = 1.0_real64 - work(cell, level, field_index(4))
            value = temporary*bottom
          else
            value = bottom/work(cell, level, field_index(3))
          end if
          full_pressure(cell, level) = value
        end do
      end do
    end if
    status = 0
  contains
    subroutine save_first_five()
      work(cell, level, field_index(1)) = delta
      work(cell, level, field_index(2)) = inverse_delta
      work(cell, level, field_index(3)) = ratio
      work(cell, level, field_index(4)) = alpha
      work(cell, level, field_index(5)) = beta
    end subroutine
  end subroutine

end module md2asm_hybrid_pressure_one_based

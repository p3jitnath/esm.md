module srfwng_mod
  use iso_fortran_env, only: int32, int64, real64
  use yos_soil, only: tsoil
  use yos_thf, only: rhoh2o
  implicit none
  private
  public :: srfwng
contains
  !> Return the finite maximum with the zero sign of the assembly FMAX.
  pure function positive_zero_maximum(value) result(answer)
    real(real64), intent(in) :: value
    real(real64) :: answer
    if (value > 0.0_real64) then
      answer = value
    else
      answer = 0.0_real64
    end if
  end function positive_zero_maximum

  !> Return the finite minimum with the zero sign of the assembly FMIN.
  pure function negative_zero_minimum(value) result(answer)
    real(real64), intent(in) :: value
    real(real64) :: answer
    if (value < 0.0_real64) then
      answer = value
    else if (value == 0.0_real64) then
      answer = transfer(iand(transfer(value,0_int64),not(huge(0_int64))),0.0_real64)
    else
      answer = 0.0_real64
    end if
  end function negative_zero_minimum

  !> Correct water in the order of soil_water_correction.S.
  !! Canopy and runoff water are in kg/m2, soil water is in m3/m3, time is in s.
  !! Diagnostics retain the current-layer write before the lower-layer write.
  !! The finite-input contract includes positive time, density and thickness.
  subroutine srfwng(kidia, kfdia, klevs, ptmst, ksoty, pwl, pwlmx, pwsa, ydsoil, &
      pros, prod, pwfsd, ldland, pdhwls)
    integer(int32), intent(in) :: kidia, kfdia, klevs, ksoty(:)
    real(real64), intent(in) :: ptmst, pwlmx(:)
    type(tsoil), intent(in) :: ydsoil
    real(real64), intent(inout) :: pwl(:), pwsa(:,:), pros(:), prod(:), pwfsd(:), pdhwls(:,:,:)
    logical, intent(in) :: ldland(:)
    integer(int32) :: column, layer
    real(real64) :: thickness(klevs), inverse_thickness(klevs)
    real(real64) :: inverse_time, density, inverse_density, saturation
    real(real64) :: water, initial_top, deficit, runoff, a, b, factor
    logical :: diagnostics

    inverse_time = 1.0_real64 / ptmst
    density = rhoh2o
    inverse_density = 1.0_real64 / density
    do layer = 1, klevs
      thickness(layer) = ydsoil%rdaw(layer)
      inverse_thickness(layer) = 1.0_real64 / thickness(layer)
    end do
    diagnostics = size(pdhwls) /= 0
    do column = kidia, kfdia
      prod(column) = 0.0_real64
      if (.not. ldland(column)) then
        pwfsd(column) = 0.0_real64
        cycle
      end if
      if (ydsoil%levgen) then
        saturation = ydsoil%rwsatm(ksoty(column))
      else
        saturation = ydsoil%rwsat
      end if
      do layer = 1, klevs
        water = pwsa(column,layer)
        if (layer == 1) then
          initial_top = water
          a = pwl(column)
          b = pwlmx(column)
          b = a - b
          b = positive_zero_maximum(b)
          a = a - b
          pwl(column) = a
          b = b * inverse_density
          b = b * inverse_thickness(layer)
          water = initial_top + b
          pwsa(column,layer) = water
        end if
        deficit = negative_zero_minimum(water)
        water = water - deficit
        pwsa(column,layer) = water
        if (layer < klevs) then
          a = pwsa(column,layer+1)
          b = deficit * thickness(layer)
          b = b * inverse_thickness(layer+1)
          a = a + b
          pwsa(column,layer+1) = a
        end if
        runoff = water - saturation
        runoff = positive_zero_maximum(runoff)
        if (layer == 1) then
          a = pros(column)
          b = thickness(layer) * density
          b = b * runoff
          a = a + b
          pros(column) = a
          a = pwfsd(column)
          b = deficit * density
          b = b * thickness(layer)
          b = b * inverse_time
          a = a + b
          pwfsd(column) = a
        else
          a = prod(column)
          b = thickness(layer) * density
          b = b * runoff
          a = a + b
          prod(column) = a
        end if
        water = water - runoff
        pwsa(column,layer) = water
        if (diagnostics) then
          a = pdhwls(column,layer,6)
          factor = density * inverse_time
          factor = factor * thickness(layer)
          b = deficit + runoff
          b = factor * b
          a = a - b
          pdhwls(column,layer,6) = a
          if (layer < klevs) then
            a = pdhwls(column,layer+1,6)
            b = factor * deficit
            a = a + b
            pdhwls(column,layer+1,6) = a
          end if
        end if
      end do
    end do
  end subroutine srfwng
end module srfwng_mod

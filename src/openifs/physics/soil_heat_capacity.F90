module srfrcg_mod
  use iso_fortran_env, only: real64, int32
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_is_finite, ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use yos_cst, only: tcst
  use yos_soil, only: tsoil
  use yos_urb, only: turb
  use yos_thf, only: rhoh2o
  implicit none
  private
  public :: srfrcg
  interface
    function selected_cosine(angle) bind(c, name="cos") result(value)
      import c_double
      real(c_double), value :: angle
      real(c_double) :: value
    end function selected_cosine
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Compute apparent soil heat capacity with the operation order of soil_heat_capacity.S.
  !!
  !! The active columns are KIDIA:KFDIA in arrays with at least KLON rows and KLEVS layers.
  !! Temperatures use kelvin; cover fractions are dimensionless; PCTSA uses J m^-3 K^-1.
  !! Native Fortran types supply the configuration and array interfaces. Only PCTSA changes.
 subroutine srfrcg(kidia, kfdia, klon, ktiles, klevs, ldland, ldsice, ptsam1m, ksoty, pcvl, pcvh, pcur, ydcst, ydsoil, ydurb, pctsa)
    integer(int32), intent(in) :: kidia, kfdia, klon, ktiles, klevs
    logical(int32), intent(in) :: ldland(:), ldsice(:)
    integer(int32), intent(in) :: ksoty(:)
    real(real64), intent(in) :: ptsam1m(:, :), pcvl(:), pcvh(:), pcur(:)
    type(tcst), intent(in) :: ydcst
    type(tsoil), intent(in) :: ydsoil
    type(turb), intent(in) :: ydurb
    real(real64), intent(inout) :: pctsa(:, :)
    integer(int32) :: column, layer, soil_kind
    real(real64) :: latent_density, water_capacity, soil_capacity, cover, latent_water, top_capacity
    real(real64) :: temperature, angle, derivative, temporary
    real(real64), volatile :: smallest, subnormal
    type(ieee_round_type) :: rounding
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_contract()
    smallest = tiny(1.0_real64)
    subnormal = smallest*0.5_real64
    if (subnormal == 0.0_real64) call reject_contract()
    if (klon < 1 .or. klon > 4096 .or. klevs < 1 .or. klevs > 512) call reject_contract()
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) call reject_contract()
    if (ktiles < 1 .or. ktiles > 16) call reject_contract()
    if (min(size(ldland), size(ldsice), size(ksoty), size(pcvl), size(pcvh), size(pcur)) < klon) call reject_contract()
    if (size(ptsam1m, 1) < klon .or. size(ptsam1m, 2) < klevs) call reject_contract()
    if (size(pctsa, 1) < klon .or. size(pctsa, 2) < klevs) call reject_contract()
    if (ydsoil%rtf1 /= 274.16_real64 .or. ydsoil%rtf2 /= 270.16_real64) call reject_contract()
    if (ydsoil%rtf3 /= 272.16_real64 .or. ydsoil%rtf4 /= 0.7853981633974483_real64) call reject_contract()
    if (.not. in_range(ydsoil%rrcsice, 1.0_real64, 1.0e12_real64)) call reject_contract()
    if (.not. in_range(ydcst%rlmlt, 1.0_real64, 1.0e9_real64)) call reject_contract()
    if (.not. in_range(rhoh2o, 1.0_real64, 1.0e6_real64)) call reject_contract()
    latent_density = ydcst%rlmlt*rhoh2o
    if (.not. ydsoil%levgen) then
      if (.not. in_range(ydsoil%rrcsoil, 1.0_real64, 1.0e12_real64)) call reject_contract()
      if (.not. in_range(ydsoil%rwcap, 0.0_real64, 1.0_real64)) call reject_contract()
    else
      if (.not. allocated(ydsoil%rwcapm) .or. .not. allocated(ydsoil%rrcsoilm)) call reject_contract()
    end if
    if (ktiles > 9) then
      if (.not. in_range(ydurb%rurbvhc, 1.0_real64, 1.0e12_real64)) call reject_contract()
    end if
    ! Validate every consumed land value before the first output write.
    do column = kidia, kfdia
      if (.not. ldland(column)) cycle
      if (.not. in_range(pcvl(column), 0.0_real64, 1.0_real64)) call reject_contract()
      if (.not. in_range(pcvh(column), 0.0_real64, 1.0_real64)) call reject_contract()
      if (pcvl(column) + pcvh(column) > 1.0_real64) call reject_contract()
      if (ktiles > 9) then
        if (.not. in_range(pcur(column), 0.0_real64, 1.0_real64)) call reject_contract()
      end if
      if (ydsoil%levgen) then
        soil_kind = ksoty(column)
        if (soil_kind < lbound(ydsoil%rwcapm, 1) .or. soil_kind > ubound(ydsoil%rwcapm, 1)) call reject_contract()
        if (soil_kind < lbound(ydsoil%rrcsoilm, 1) .or. soil_kind > ubound(ydsoil%rrcsoilm, 1)) call reject_contract()
        if (.not. in_range(ydsoil%rwcapm(soil_kind), 0.0_real64, 1.0_real64)) call reject_contract()
        if (.not. in_range(ydsoil%rrcsoilm(soil_kind), 1.0_real64, 1.0e12_real64)) call reject_contract()
      end if
      do layer = 1, klevs
        if (.not. in_range(ptsam1m(column, layer), 100.0_real64, 500.0_real64)) call reject_contract()
      end do
    end do
    do column = kidia, kfdia
      if (ldland(column)) then
        if (ydsoil%levgen) then
          soil_kind = ksoty(column)
          water_capacity = ydsoil%rwcapm(soil_kind)
          soil_capacity = ydsoil%rrcsoilm(soil_kind)
        else
          water_capacity = ydsoil%rwcap
          soil_capacity = ydsoil%rrcsoil
        end if
        cover = pcvl(column) + pcvh(column)
        temporary = cover*water_capacity
        latent_water = latent_density*temporary
        top_capacity = soil_capacity
        if (ktiles > 9) then
          temporary = 1.0_real64 - pcur(column)
          temporary = soil_capacity*temporary
          top_capacity = ydurb%rurbvhc*pcur(column)
          top_capacity = temporary + top_capacity
        end if
        do layer = 1, klevs
          temperature = ptsam1m(column, layer)
          if (temperature < ydsoil%rtf1 .and. temperature > ydsoil%rtf2) then
            angle = temperature - ydsoil%rtf3
            angle = ydsoil%rtf4*angle
            derivative = selected_cosine(angle)
            temporary = (-0.5_real64)*ydsoil%rtf4
            derivative = temporary*derivative
          else
            derivative = 0.0_real64
          end if
          temporary = latent_water*derivative
          if (layer == 1) then
            pctsa(column, layer) = top_capacity - temporary
          else
            pctsa(column, layer) = soil_capacity - temporary
          end if
        end do
      else
        do layer = 1, klevs
          temporary = 0.0_real64
          if (ldsice(column) .and. layer == 1) temporary = ydsoil%rrcsice
          pctsa(column, layer) = temporary
        end do
      end if
    end do
  end subroutine srfrcg
  !> Check the finite physical interval without changing its values.
  pure logical function in_range(value, low, high)
    real(real64), intent(in) :: value, low, high
    in_range = ieee_is_finite(value) .and. value >= low .and. value <= high
  end function in_range
end module srfrcg_mod

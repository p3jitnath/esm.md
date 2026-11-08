module srfene_mod
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use yos_cst, only: tcst
  use yos_soil, only: tsoil
  use yos_thf, only: rhoh2o
  implicit none
  private
  public :: srfene
  interface
    function selected_sine(angle) bind(c, name="sin") result(value)
      import c_double
      real(c_double), value :: angle
      real(c_double) :: value
    end function selected_sine
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Compute each layer's soil energy in the order of soil_energy_support.S.
  !!
  !! KIDIA:KFDIA selects active columns; the selected implementation uses four layers.
  !! PTSAM1M is temperature in kelvin. PCVL and PCVH are dimensionless cover fractions.
  !! TCST and TSOIL are the native configuration types. PENES is energy per area in J m^-2.
  !! Only active PENES cells change; land takes precedence over sea ice.
  subroutine srfene(kidia, kfdia, klon, klevs, ldland, ldsice, ptsam1m, ksoty, pcvl, pcvh, ydcst, ydsoil, penes)
    integer(int32), intent(in) :: kidia, kfdia, klon, klevs, ksoty(:)
    logical(int32), intent(in) :: ldland(:), ldsice(:)
    real(real64), intent(in) :: ptsam1m(:, :), pcvl(:), pcvh(:)
    type(tcst), intent(in) :: ydcst
    type(tsoil), intent(in) :: ydsoil
    real(real64), intent(inout) :: penes(:, :)
    real(real64), allocatable :: phase(:, :)
    real(real64) :: temperature, angle, value, water_capacity, soil_capacity, cover, latent, ordinary, temporary
    real(real64), volatile :: smallest, subnormal
    integer(int32) :: column, layer, soil_kind, allocation_status
    type(ieee_round_type) :: rounding
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_contract()
    smallest = tiny(1.0_real64)
    subnormal = smallest*0.5_real64
    if (subnormal == 0.0_real64) call reject_contract()
    if (klon < 1 .or. klon > 4096 .or. kidia < 1 .or. kfdia > klon) call reject_contract()
    if (kfdia < kidia) return
    if (klevs /= 4) call reject_contract()
    if (min(size(ldland), size(ldsice), size(ksoty), size(pcvl), size(pcvh)) < klon) call reject_contract()
    if (min(size(ptsam1m, 1), size(penes, 1)) < klon .or. min(size(ptsam1m, 2), size(penes, 2)) < 4) call reject_contract()
    if (.not. allocated(ydsoil%rdat) .or. .not. allocated(ydsoil%rdai)) call reject_contract()
    if (lbound(ydsoil%rdat, 1) > 1 .or. ubound(ydsoil%rdat, 1) < 4) call reject_contract()
    if (lbound(ydsoil%rdai, 1) > 1 .or. ubound(ydsoil%rdai, 1) < 4) call reject_contract()
    if (ydsoil%levgen) then
      if (.not. allocated(ydsoil%rwcapm) .or. .not. allocated(ydsoil%rrcsoilm)) call reject_contract()
      do column = kidia, kfdia
        if (.not. ldland(column)) cycle
        soil_kind = ksoty(column)
        if (soil_kind < lbound(ydsoil%rwcapm, 1) .or. soil_kind > ubound(ydsoil%rwcapm, 1)) call reject_contract()
        if (soil_kind < lbound(ydsoil%rrcsoilm, 1) .or. soil_kind > ubound(ydsoil%rrcsoilm, 1)) call reject_contract()
      end do
    end if
    allocate (phase(klon, 4), stat=allocation_status)
    if (allocation_status /= 0) call reject_contract()
    phase = 0.0_real64
    do layer = 1, 4
      do column = kidia, kfdia
        if (.not. ldland(column)) cycle
        temperature = ptsam1m(column, layer)
        if (temperature >= ydsoil%rtf1) then
          value = 0.0_real64
        else if (temperature <= ydsoil%rtf2) then
          value = 1.0_real64
        else
          angle = temperature - ydsoil%rtf3
          angle = ydsoil%rtf4*angle
          value = selected_sine(angle)
          value = 1.0_real64 - value
          value = 0.5_real64*value
        end if
        phase(column, layer) = value
      end do
    end do
    do layer = 1, 4
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
          cover = cover*water_capacity
          ordinary = soil_capacity*ptsam1m(column, layer)
          latent = ydcst%rlmlt*rhoh2o
          latent = latent*cover
          latent = latent*phase(column, layer)
          value = ordinary - latent
          value = value*ydsoil%rdat(layer)
        else if (ldsice(column)) then
          value = ydsoil%rrcsice*ptsam1m(column, layer)
          value = value*ydsoil%rdai(layer)
        else
          value = 0.0_real64
        end if
        penes(column, layer) = value
      end do
    end do
  end subroutine srfene
end module srfene_mod

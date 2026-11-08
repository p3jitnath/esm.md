!> Port the whole-state preparation and partial return in lake_model_driver.S.
!! Numerical children are the separately ported FLAKERAD and FLAKEENE modules.
module flake_driver_mod
  use iso_fortran_env, only: int32, real64
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use yos_cst, only: tcst
  use yos_flake, only: tflake, ropticpar_medium
  use yomhook, only: lhook, dr_hook, jphook
  use flakerad_mod, only: flakerad
  use flakeene_mod, only: flakeene
  implicit none
  private
  public :: flake_driver
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Prepare the lake forcing, call both numerical children and return seven fields.
  !! KIDIA:KFDIA is contained in 1:KLON, with 1 <= KLON <= 4096.
  !! All one-dimensional input arrays contain at least KLON elements.
  !! The seven real64 output arrays have exactly KLON elements and retain inactive words.
  !! LDLAKEPOINT selects lake columns. Fluxes PSSRFLTI, PSLRFL and PAHFSTI are in W/m2.
  !! PEVAPTI is the water mass flux in kg/(m2 s); PUSTRTI and PVSTRTI are in N/m2.
  !! Depths PLDEPT, PHLICE and PHLML are in m; temperature fields are in K.
  !! PTLSF is dimensionless, and PTSTP is the step length in s.
  !! PFRTI, PGEMU and YDCST retain their public interface but are not read by this body.
  !! Native records replace the earlier private Arm layouts; the caller owns all arguments.
  subroutine flake_driver(kidia, kfdia, klon, ldlakepoint, pssrflti, pslrfl, pahfsti, pevapti, &
                          pustrti, pvstrti, pfrti, pldept, pgemu, ptstp, ydcst, ydflake, &
                          ptlicem1m, ptlmnwm1m, ptlwmlm1m, ptlbotm1m, ptlsfm1m, phlicem1m, phlmlm1m, &
                          ptlice, ptlmnw, ptlwml, ptlbot, ptlsf, phlice, phlml)
    integer(int32), intent(in) :: kidia, kfdia, klon
    logical, intent(in) :: ldlakepoint(:)
    real(real64), intent(in) :: pssrflti(:), pslrfl(:), pahfsti(:), pevapti(:)
    real(real64), intent(in) :: pustrti(:), pvstrti(:), pfrti(:, :), pldept(:), pgemu(:), ptstp
    type(tcst), intent(in) :: ydcst
    type(tflake), intent(in) :: ydflake
    real(real64), intent(in) :: ptlicem1m(:), ptlmnwm1m(:), ptlwmlm1m(:), ptlbotm1m(:)
    real(real64), intent(in) :: ptlsfm1m(:), phlicem1m(:), phlmlm1m(:)
    real(real64), intent(inout) :: ptlice(:), ptlmnw(:), ptlwml(:), ptlbot(:), ptlsf(:), phlice(:), phlml(:)
    type(ropticpar_medium) :: water_optics, ice_optics
    real(real64), allocatable :: pool(:, :)
    integer(int32) :: column, allocation_status, flag
    type(ieee_round_type) :: rounding
    real(real64), volatile :: gradual_operand, gradual_scale
    real(real64) :: gradual_probe, step_length, extinction, a, b, c
    real(jphook) :: hook_handle

    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_contract()
    gradual_operand = tiny(1.0_real64)
    gradual_scale = 0.5_real64
    gradual_probe = gradual_operand*gradual_scale
    if (gradual_probe == 0.0_real64) call reject_contract()
    if (klon < 1_int32 .or. klon > 4096_int32) call reject_contract()
    if (kidia < 1_int32 .or. kidia > kfdia .or. kfdia > klon) call reject_contract()
    if (size(ldlakepoint) < klon .or. size(pssrflti) < klon .or. size(pslrfl) < klon) call reject_contract()
    if (size(pahfsti) < klon .or. size(pevapti) < klon .or. size(pustrti) < klon) call reject_contract()
    if (size(pvstrti) < klon .or. size(pldept) < klon) call reject_contract()
    if (size(ptlicem1m) < klon .or. size(ptlmnwm1m) < klon .or. size(ptlwmlm1m) < klon) call reject_contract()
    if (size(ptlbotm1m) < klon .or. size(ptlsfm1m) < klon) call reject_contract()
    if (size(phlicem1m) < klon .or. size(phlmlm1m) < klon) call reject_contract()
    if (size(ptlice) /= klon .or. size(ptlmnw) /= klon .or. size(ptlwml) /= klon) call reject_contract()
    if (size(ptlbot) /= klon .or. size(ptlsf) /= klon) call reject_contract()
    if (size(phlice) /= klon .or. size(phlml) /= klon) call reject_contract()
    flag = transfer(lhook, flag)
    if (flag < 0_int32 .or. flag > 1_int32) call reject_contract()
    if (lhook) call dr_hook('FLAKE_DRIVER_MOD:FLAKE_DRIVER', 0, hook_handle)

    allocate (pool(klon, 0:27), stat=allocation_status)
    if (allocation_status /= 0_int32) call reject_contract()
    ! The generated driver used calloc: every workspace word starts at positive zero.
    pool = 0.0_real64
    water_optics = ydflake%ropticpar_water_ref
    ice_optics = ydflake%ropticpar_ice_opaque
    step_length = ptstp
    do column = 1, klon
      pool(column, 0) = pldept(column)
      pool(column, 3) = ptlicem1m(column)
      pool(column, 5) = ptlmnwm1m(column)
      pool(column, 4) = ptlwmlm1m(column)
      pool(column, 6) = ptlbotm1m(column)
      pool(column, 9) = ptlsfm1m(column)
      pool(column, 7) = phlicem1m(column)
      pool(column, 8) = phlmlm1m(column)
      if (column < kidia .or. column > kfdia) cycle
      flag = transfer(ldlakepoint(column), flag)
      if (flag < 0_int32 .or. flag > 1_int32) call reject_contract()
      if (.not. ldlakepoint(column)) cycle
      pool(column, 13) = pssrflti(column)
      a = pustrti(column)*pustrti(column)
      b = pvstrti(column)*pvstrti(column)
      a = a + b
      a = sqrt(a)
      a = a/ydflake%rtpl_rho_w_r
      a = sqrt(a)
      pool(column, 12) = a
      pool(column, 1) = 1.0e-4_real64
      a = pslrfl(column) + pahfsti(column)
      c = pevapti(column)
      b = ydflake%rtpsf_l_evap*c
      a = a + b
      if (pool(column, 7) >= ydflake%rh_ice_min_flk) then
        b = ydflake%rtpl_l_f*c
        b = a + b
        pool(column, 11) = b
        pool(column, 10) = 0.0_real64
        pool(column, 2) = pool(column, 3)
      else
        pool(column, 10) = a
        pool(column, 11) = 0.0_real64
        pool(column, 2) = pool(column, 4)
      end if
    end do

    call flakerad(kidia, kfdia, ldlakepoint, pool(:, 0), water_optics, ice_optics, ydflake, &
                  pool(:, 13), pool(:, 7), pool(:, 8), pool(:, 14), pool(:, 15), pool(:, 16), &
                  pool(:, 17), pool(:, 18), pool(:, 19))
    extinction = water_optics%rextincoef_optic(1)
    call flakeene(kidia, kfdia, klon, pool(:, 0), pool(:, 1), ldlakepoint, extinction, ydflake, &
                  step_length, pool(:, 2), pool(:, 3), pool(:, 4), pool(:, 5), pool(:, 6), pool(:, 7), pool(:, 8), &
                  pool(:, 9), pool(:, 10), pool(:, 11), pool(:, 12), pool(:, 14), pool(:, 15), pool(:, 16), &
                  pool(:, 17), pool(:, 18), pool(:, 19), pool(:, 20), pool(:, 21), pool(:, 22), pool(:, 23), &
                  pool(:, 24), pool(:, 25), pool(:, 26), pool(:, 27))
    do column = kidia, kfdia
      ptlice(column) = pool(column, 20)
      ptlmnw(column) = pool(column, 22)
      ptlwml(column) = pool(column, 21)
      ptlbot(column) = pool(column, 23)
      ptlsf(column) = pool(column, 26)
      phlice(column) = pool(column, 24)
      phlml(column) = pool(column, 25)
    end do
    deallocate (pool)
    if (lhook) call dr_hook('FLAKE_DRIVER_MOD:FLAKE_DRIVER', 1, hook_handle)
  end subroutine flake_driver
end module flake_driver_mod

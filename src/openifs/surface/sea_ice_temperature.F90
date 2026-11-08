module srfi_mod
  use iso_fortran_env, only: int32, int64, real64
  use ieee_arithmetic, only: ieee_is_nan
  use yos_cst, only: tcst
  use yos_soil, only: tsoil
  use srfwdif_mod, only: srfwdif
  implicit none
  private
  public :: srfi
  interface
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Advance independent ice columns in the order of sea_ice_temperature.S.
  !!
  !! PTMST is in seconds; PTIAM1M and PTIA use kelvin; flux inputs use W m^-2.
  !! Native TCST and TSOIL supply constants and layer thicknesses in metres.
  !! KIDIA:KFDIA selects active columns; KLEVI selects diagnostic layers.
  !! Only PTIA and the declared diagnostic fields of PDHTIS change.
  subroutine srfi(kidia, kfdia, klon, klevs, klevi, ptmst, ptiam1m, pfrti, pahfsti, pevapti, pslrfl, pssrflti, ldice, ldnh, ydcst, &
                  ydsoil, ptia, pdhtis)
    integer(int32), intent(in) :: kidia, kfdia, klon, klevs, klevi
    real(real64), intent(in) :: ptmst, ptiam1m(:, :), pfrti(:, :), pahfsti(:, :), pevapti(:, :), pslrfl(:), pssrflti(:, :)
    logical(int32), intent(in) :: ldice(:), ldnh(:)
    type(tcst), intent(in) :: ydcst
    type(tsoil), intent(in) :: ydsoil
    real(real64), intent(inout) :: ptia(:, :), pdhtis(:, :, :)
    real(real64), allocatable :: thickness(:), factor(:, :), rhs(:, :), capacity(:, :), intermediate(:, :)
    real(real64) :: inverse_step, step_implicit, recovery_weight, total, depth, surface_flux, value, temporary, term
    integer(int32) :: column, layer, allocation_status
    logical :: diagnostics, one_ice(1)
    if (klon < 1 .or. klon > 4096 .or. klevs < 4 .or. klevs > 512) call reject_contract()
    if (kidia < 1 .or. kfdia > klon .or. klevi < 1 .or. klevi > klevs) call reject_contract()
    if (min(size(ldice), size(ldnh), size(pslrfl)) < klon) call reject_contract()
    if (min(size(ptiam1m, 1), size(pfrti, 1), size(pahfsti, 1), size(pevapti, 1), size(pssrflti, 1), size(ptia, 1)) < klon) call &
      reject_contract()
    if (min(size(ptiam1m, 2), size(ptia, 2)) < klevs) call reject_contract()
    if (min(size(pfrti, 2), size(pahfsti, 2), size(pevapti, 2), size(pssrflti, 2)) < 2) call reject_contract()
    diagnostics = size(pdhtis) > 0
    if (diagnostics) then
      if (size(pdhtis, 1) < klon .or. size(pdhtis, 2) < klevs .or. size(pdhtis, 3) < 13) call reject_contract()
    end if
    if (.not. allocated(ydsoil%rdai)) call reject_contract()
    if (lbound(ydsoil%rdai, 1) > 1 .or. ubound(ydsoil%rdai, 1) < klevs - 1) call reject_contract()
    inverse_step = 1.0_real64/ptmst
    step_implicit = ptmst*ydsoil%rsimp
    step_implicit = step_implicit*2.0_real64
    recovery_weight = 1.0_real64/ydsoil%rsimp
    recovery_weight = 1.0_real64 - recovery_weight
    allocate (thickness(klevs), factor(1, klevs), rhs(1, klevs), capacity(1, klevs), intermediate(1, klevs), stat=allocation_status)
    if (allocation_status /= 0) call reject_contract()
    one_ice(1) = .true.
    do column = kidia, kfdia
      if (ldice(column)) then
        do layer = 1, klevs - 1
          thickness(layer) = ydsoil%rdai(layer)
        end do
        total = thickness(1) + thickness(2)
        total = total + thickness(3)
        if (ldnh(column)) then
          depth = ydsoil%rdarsice
        else
          depth = ydsoil%rdansice
        end if
        thickness(klevs) = depth - total
        value = pssrflti(column, 2) + pslrfl(column)
        temporary = ydcst%rlstt*pevapti(column, 2)
        temporary = pahfsti(column, 2) + temporary
        surface_flux = value + temporary
        do layer = 1, klevs
          capacity(1, layer) = ydsoil%rrcsice*thickness(layer)
          value = step_implicit*ydsoil%rcondsice
          if (layer < klevs) then
            temporary = thickness(layer) + thickness(layer + 1)
            value = value/temporary
            factor(1, layer) = value
            term = 0.0_real64
            if (layer == 1) then
              term = ptmst*surface_flux
              term = term/capacity(1, layer)
            end if
          else
            temporary = 2.0_real64*thickness(layer)
            value = value/temporary
            factor(1, layer) = value
            term = ydsoil%rtfreezsice/ydsoil%rsimp
            term = term*value
            term = term/capacity(1, layer)
          end if
          rhs(1, layer) = term
        end do
        call srfwdif(1_int32, 1_int32, 1_int32, klevs, ptiam1m(column:column, 1:klevs), factor, rhs, capacity, ydsoil, &
                     intermediate, one_ice)
        if (diagnostics) then
          do layer = 1, klevi
            value = capacity(1, layer)
            pdhtis(column, layer, 1) = value
            temporary = ptiam1m(column, layer)
            pdhtis(column, layer, 2) = temporary
            value = value*temporary
            pdhtis(column, layer, 3) = value
            pdhtis(column, layer, 4) = thickness(layer)
            value = 0.0_real64
            temporary = 0.0_real64
            if (layer == 1) then
              value = pfrti(column, 2)*pahfsti(column, 2)
              temporary = ydcst%rlstt*pfrti(column, 2)
              temporary = temporary*pevapti(column, 2)
            end if
            pdhtis(column, layer, 9) = value
            pdhtis(column, layer, 10) = temporary
            if (layer < klevi) then
              value = intermediate(1, layer) - intermediate(1, layer + 1)
              value = ydsoil%rsimp*value
              value = value*factor(1, layer)
              value = value*inverse_step
              pdhtis(column, layer, 11) = value
            end if
            pdhtis(column, layer, 12) = 0.0_real64
            pdhtis(column, layer, 13) = 0.0_real64
          end do
          value = intermediate(1, klevs) - ydsoil%rtfreezsice
          value = ydsoil%rsimp*value
          value = value*factor(1, klevi)
          value = value*inverse_step
          pdhtis(column, klevs, 11) = value
        end if
        do layer = 1, klevs
          value = ptiam1m(column, layer)*recovery_weight
          value = value + intermediate(1, layer)
          ptia(column, layer) = minimum(value, ydsoil%rtmeltsice)
        end do
      else
        if (diagnostics) then
          do layer = 1, klevi
            pdhtis(column, layer, 1) = 0.0_real64
            pdhtis(column, layer, 2) = 0.0_real64
            pdhtis(column, layer, 3) = 0.0_real64
            pdhtis(column, layer, 4) = 0.0_real64
            pdhtis(column, layer, 9) = 0.0_real64
            pdhtis(column, layer, 10) = 0.0_real64
            if (layer < klevi) pdhtis(column, layer, 11) = 0.0_real64
            pdhtis(column, layer, 12) = 0.0_real64
            pdhtis(column, layer, 13) = 0.0_real64
          end do
          pdhtis(column, klevs, 11) = 0.0_real64
        end if
        value = minimum(ydsoil%rtfreezsice, ydsoil%rtmeltsice)
        do layer = 1, klevs
          ptia(column, layer) = value
        end do
      end if
    end do
  end subroutine srfi
  !> Preserve the assembly minimum, including both signs of zero.
  pure function minimum(a, b) result(value)
    real(real64), intent(in) :: a, b
    real(real64) :: value
    if (ieee_is_nan(a)) then
      value = a
    else if (ieee_is_nan(b)) then
      value = b
    else if (a == 0.0_real64 .and. b == 0.0_real64) then
      value = transfer(ior(transfer(a, 0_int64), transfer(b, 0_int64)), value)
    else if (a < b) then
      value = a
    else
      value = b
    end if
  end function minimum
end module srfi_mod

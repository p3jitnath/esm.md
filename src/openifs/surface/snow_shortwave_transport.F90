module srfsn_ssrabs_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double, c_int
  use ieee_arithmetic, only: ieee_is_nan
  use yos_soil, only: tsoil
  use yos_cst, only: tcst
  implicit none
  private
  public :: srfsn_ssrabs
  interface
    function selected_power(base, exponent) bind(c, name="pow") result(value)
      import c_double
      real(c_double), value :: base, exponent
      real(c_double) :: value
    end function selected_power
    function selected_exponential(argument) bind(c, name="exp") result(value)
      import c_double
      real(c_double), value :: argument
      real(c_double) :: value
    end function selected_exponential
    subroutine reject_contract(code) bind(c, name="_exit")
      import c_int
      integer(c_int), value :: code
    end subroutine reject_contract
  end interface
contains
  !> Transport solar radiation through snow in the order of snow_shortwave_transport.S.
  !!
  !! KIDIA:KFDIA selects columns; KLEVSN is the number of snow layers.
  !! Mass uses kg m^-2; density uses kg m^-3; radiation uses W m^-2.
  !! PSNOTRS has KLEVSN+1 channels and keeps incoming values for accumulation.
  !! The active layer index persists through tile 5 then tile 7, as in the assembly.
  subroutine srfsn_ssrabs(kidia, kfdia, klon, klevsn, llnosnow, pfrti, pssrflti, pssnm1m, prsnm1m, ydsoil, ydcst, psnotrs)
    integer(int32), intent(in) :: kidia, kfdia, klon, klevsn
    logical(int32), intent(in) :: llnosnow(:)
    real(real64), intent(in) :: pfrti(:, :), pssrflti(:, :), pssnm1m(:, :), prsnm1m(:, :)
    type(tsoil), intent(in) :: ydsoil
    type(tcst), intent(in) :: ydcst
    real(real64), intent(inout) :: psnotrs(:, :)
    real(real64) :: depth(64), extinction(64), transport(65), density, value, term, transmission, remaining, fraction, radiation
    real(real64), parameter :: threshold = 10.0_real64*epsilon(1.0_real64)
    integer(int32) :: column, layer, tile, active, channel
    if (klon < 1 .or. klon > 4096 .or. klevsn < 1 .or. klevsn > 64) call reject_contract(116_c_int)
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) call reject_contract(116_c_int)
    if (kfdia < kidia) return
    if (min(size(llnosnow), size(pfrti, 1), size(pssrflti, 1), size(pssnm1m, 1), size(prsnm1m, 1), size(psnotrs, 1)) < klon) call &
      reject_contract(116_c_int)
    if (min(size(pfrti, 2), size(pssrflti, 2)) < 7) call reject_contract(116_c_int)
    if (min(size(pssnm1m, 2), size(prsnm1m, 2)) < klevsn .or. size(psnotrs, 2) /= klevsn + 1) call reject_contract(116_c_int)
    active = 1
    do tile = 5, 7, 2
      do column = kidia, kfdia
        if (llnosnow(column)) then
          do channel = 1, klevsn + 1
            psnotrs(column, channel) = 0.0_real64
          end do
          cycle
        end if
        fraction = pfrti(column, tile)
        radiation = pssrflti(column, tile)
        do layer = 1, klevsn
          if (pssnm1m(column, layer) > threshold) active = layer
        end do
        do layer = 1, active
          density = prsnm1m(column, layer)
          value = pssnm1m(column, layer)/density
          value = minimum(value, ydsoil%rdsnmax)
          depth(layer) = maximum(value, 0.0_real64)
          value = selected_power(density, 4.0_real64)
          value = ydsoil%ssag3*value
          value = value + ydsoil%ssag1
          value = minimum(value, ydsoil%ssagsnsmax)
          value = selected_power(value, 0.5_real64)
          term = density*ydsoil%ssasnextcnst
          term = term/value
          term = minimum(term, ydsoil%ssasnextmax)
          extinction(layer) = maximum(term, ydsoil%ssasnextmin)
        end do
        value = depth(1)*extinction(1)
        value = -value
        transmission = selected_exponential(value)
        transmission = maximum(transmission, threshold)
        transport(1) = radiation*transmission
        value = 1.0_real64 - transmission
        value = value*radiation
        remaining = radiation - value
        do layer = 2, active
          value = depth(layer)*extinction(layer)
          value = -value
          transmission = selected_exponential(value)
          value = 1.0_real64 - transmission
          value = value*remaining
          transport(layer) = value
          remaining = remaining - value
        end do
        transport(active + 1) = remaining
        do channel = 1, active + 1
          value = fraction*transport(channel)
          psnotrs(column, channel) = psnotrs(column, channel) + value
        end do
      end do
    end do
  end subroutine srfsn_ssrabs
  !> Preserve minimum and maximum zero signs for finite admitted operands.
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
  !> Preserve the assembly maximum, including both signs of zero.
  pure function maximum(a, b) result(value)
    real(real64), intent(in) :: a, b
    real(real64) :: value
    if (ieee_is_nan(a)) then
      value = a
    else if (ieee_is_nan(b)) then
      value = b
    else if (a == 0.0_real64 .and. b == 0.0_real64) then
      value = transfer(iand(transfer(a, 0_int64), transfer(b, 0_int64)), value)
    else if (a > b) then
      value = a
    else
      value = b
    end if
  end function maximum
end module srfsn_ssrabs_mod

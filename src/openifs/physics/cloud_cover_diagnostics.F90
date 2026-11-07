!> Port the runtime CLDPP diagnostic, decorrelation and cumulative calculations.
!! The public C mathematics library supplies SIN, ASIN, COS, LOG and EXP.
!! Their reached arguments and status still require the retained byte gate.
module cloud_cover_diagnostics_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_double
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use radiation_setup, only: tradiation
  use yoerad, only: terad
  use yoerdi, only: terdi
  use yoecld, only: tecld
  use yomrip, only: trip
  use yomcst, only: rpi, rd, rg
  implicit none
  private
  public :: cldpp, cloud_overlap_decorr_len, cldpp_cumulative
  interface
    function selected_sin(value) bind(c, name="sin") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_sin
    function selected_asin(value) bind(c, name="asin") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_asin
    function selected_cos(value) bind(c, name="cos") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_cos
    function selected_log(value) bind(c, name="log") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_log
    function selected_exp(value) bind(c, name="exp") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_exp
    subroutine reject_contract() bind(c, name="abort")
    end subroutine reject_contract
  end interface
contains
  !> Check round-to-nearest and gradual underflow without changing accepted status.
  subroutine check_arithmetic()
    type(ieee_round_type) :: rounding
    real(real64), volatile :: operand, scale
    real(real64) :: probe
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) call reject_contract()
    operand = tiny(1.0_real64)
    scale = 0.5_real64
    probe = operand * scale
    if (probe == 0.0_real64) call reject_contract()
  end subroutine check_arithmetic

  !> Accumulate fractional cloud cover in the retained six-argument operation order.
  !! N is positive. FRACTION and CUMULATIVE have N real64 elements.
  !! OVERLAP and PAIR have N-1 elements; all values are dimensionless.
  !! USE_BETA is optional and selects the source conversion before overlap.
  !! Only CUMULATIVE and PAIR change, with every rounded operation kept separate.
  subroutine cldpp_cumulative(n, fraction, overlap, cumulative, pair, use_beta)
    integer(int32), intent(in) :: n
    real(real64), intent(in) :: fraction(n), overlap(n-1)
    real(real64), intent(out) :: cumulative(n), pair(n-1)
    logical, optional, intent(in) :: use_beta
    integer(int32) :: level
    logical :: beta
    real(real64) :: upper, lower, alpha, a, b, c, d, maximum, cover
    real(real64), volatile :: clear
    upper = fraction(1)
    cumulative(1) = upper
    clear = 1.0_real64 - upper
    if (n == 1_int32) return
    beta = .false.
    if (present(use_beta)) beta = use_beta
    do level = 1, n-1
      lower = fraction(level+1)
      alpha = overlap(level)
      if (beta) then
        if (alpha < 1.0_real64) then
          a = upper - lower
          a = abs(a)
          b = 1.0_real64 - alpha
          b = b * a
          c = 1.0_real64 / alpha
          c = a + c
          c = c - 1.0_real64
          b = b / c
          alpha = alpha + b
        else
          alpha = 1.0_real64
        end if
      end if
      maximum = max(upper,lower)
      a = alpha * maximum
      b = 1.0_real64 - alpha
      c = upper + lower
      d = upper * lower
      c = c - d
      b = b * c
      cover = a + b
      pair(level) = cover
      if (upper >= transfer(int(z'3fefffffffffffec',int64),1.0_real64)) then
        clear = 0.0_real64
      else
        a = 1.0_real64 - cover
        clear = clear * a
        a = 1.0_real64 - upper
        clear = clear / a
      end if
      a = 1.0_real64 - clear
      cumulative(level+1) = a
      upper = lower
    end do
  end subroutine cldpp_cumulative

  !> Compute overlap lengths in km with the runtime latitude route.
  !! KIDIA:KFDIA is contained in 1:KLON, with an empty interval permitted.
  !! KLON is in 1:2048. SIN_LAT has KLON real64 dimensionless values.
  !! MODE zero copies the native constant lengths without reading SIN_LAT.
  !! MODE one uses rounded ASIN; other nonzero modes use COS of rounded ASIN.
  !! Optional water lengths and their scalar ratio follow the same source branches.
  subroutine cloud_overlap_decorr_len(ydecld, kidia, kfdia, klon, sin_lat, mode, edge_km, water_km, ratio)
    type(tecld), intent(in) :: ydecld
    integer(int32), intent(in) :: kidia, kfdia, klon, mode
    real(real64), intent(in) :: sin_lat(klon)
    real(real64), intent(inout) :: edge_km(klon)
    real(real64), optional, intent(inout) :: water_km(klon), ratio
    real(real64) :: coordinates(klon), a, b
    real(real64), volatile :: factor
    integer(int32) :: column
    integer(int64) :: word
    call check_arithmetic()
    if (klon < 1_int32 .or. klon > 2048_int32) call reject_contract()
    if (kidia < 1_int32 .or. kidia > klon+1_int32) call reject_contract()
    if (kfdia < 0_int32 .or. kfdia > klon) call reject_contract()
    if (mode == 0_int32) then
      do column = kidia, kfdia
        edge_km(column) = ydecld%rdecorr_cf
      end do
      if (present(water_km)) then
        do column = kidia, kfdia
          water_km(column) = ydecld%rdecorr_cw
        end do
      end if
      if (present(ratio)) ratio = ydecld%rdecorr_cw / ydecld%rdecorr_cf
      return
    end if
    if (transfer(rpi,word) /= int(z'400921fb54442d18',int64)) call reject_contract()
    factor = 180.0_real64 / rpi
    do column = kidia, kfdia
      word = transfer(sin_lat(column),word)
      word = iand(word,int(z'7fffffffffffffff',int64))
      if (word > int(z'3ff0000000000000',int64)) call reject_contract()
      a = selected_asin(sin_lat(column))
      if (mode /= 1_int32) a = selected_cos(a)
      coordinates(column) = a
    end do
    do column = kidia, kfdia
      a = coordinates(column)
      if (mode == 1_int32) then
        a = a * factor
        a = abs(a)
        a = 0.02759_real64 * a
        a = 2.899_real64 - a
      else
        b = 2.149_real64 * a
        a = b * a
        a = 0.75_real64 + a
      end if
      edge_km(column) = a
    end do
    if (present(water_km)) then
      do column = kidia, kfdia
        a = edge_km(column)
        water_km(column) = a * 0.5_real64
      end do
    end if
    if (present(ratio)) ratio = 0.5_real64
  end subroutine cloud_overlap_decorr_len

  !> Compute high, middle, low and total covers, then filter radiation fields.
  !! The 26 native arguments retain their original CLDPP order and types.
  !! Column-first real64 arrays have KLON columns and KLEV levels, except PAPHM1 with KLEV+1.
  !! Pressure is in Pa, temperature in K, latitude and longitude in rad, and water in kg/kg.
  !! Covers and cloud fractions are dimensionless. KIDIA:KFDIA selects active columns.
  !! Diagnostics require the new radiation scheme, overlap code one and three nonempty classes.
  !! PCC and all inactive output words remain unchanged. Diagnostics-off consumes no latitude or pressure values.
  subroutine cldpp(ydradiation, yderad, yderdi, ydecld, ydrip, kidia, kfdia, klon, klev, &
      paphm1, papm1, pa, pl, pi, pt, pgelat, pgelam, ldcldcover, pcc, pch, pcl, pcm, pct, pclc, pqiwp, pqlwp)
    type(tradiation), intent(inout) :: ydradiation
    type(terad), intent(inout) :: yderad
    type(terdi), intent(inout) :: yderdi
    type(tecld), intent(inout) :: ydecld
    type(trip), intent(inout) :: ydrip
    integer(int32), intent(in) :: kidia, kfdia, klon, klev
    real(real64), intent(in) :: paphm1(klon,klev+1), papm1(klon,klev), pa(klon,klev)
    real(real64), intent(in) :: pl(klon,klev), pi(klon,klev), pt(klon,klev), pgelat(klon), pgelam(klon)
    logical, intent(in) :: ldcldcover
    real(real64), intent(inout) :: pcc(klon), pch(klon), pcl(klon), pcm(klon), pct(klon)
    real(real64), intent(inout) :: pclc(klon,klev), pqiwp(klon,klev), pqlwp(klon,klev)
    real(real64), allocatable, target :: workspace(:)
    real(real64), pointer :: sine(:), length_km(:), fractions(:), alpha(:), cumulative(:), pair(:)
    integer(int32) :: boundaries(2,klon), column, level, middle, low, status, first, count, flag
    integer(int64) :: word
    real(real64) :: cutoff, high_boundary, low_boundary, surface_pressure, a, b, c
    real(real64), volatile :: height_factor
    call check_arithmetic()
    if (klon < 1_int32 .or. klon > 2048_int32) call reject_contract()
    if (klev < 3_int32 .or. klev > 512_int32) call reject_contract()
    if (kidia < 1_int32 .or. kidia > klon) call reject_contract()
    if (kfdia < 0_int32 .or. kfdia > klon) call reject_contract()
    flag = transfer(ldcldcover,flag)
    if (flag < 0_int32 .or. flag > 1_int32) call reject_contract()
    cutoff = yderdi%repclc
    if (ldcldcover) then
      if (yderad%lusepre2017rad) call reject_contract()
      if (ydradiation%rad_config%i_overlap_scheme /= 1_int32) call reject_contract()
      high_boundary = ydecld%retahb
      low_boundary = ydecld%retamb
      height_factor = rd / rg
      allocate(workspace(2*klon+4*klev), stat=status)
      if (status /= 0_int32) call reject_contract()
      workspace = 0.0_real64
      first = 1
      sine => workspace(first:first+klon-1)
      first = first+klon
      length_km => workspace(first:first+klon-1)
      first = first+klon
      fractions => workspace(first:first+klev-1)
      first = first+klev
      alpha => workspace(first:first+klev-1)
      first = first+klev
      cumulative => workspace(first:first+klev-1)
      first = first+klev
      pair => workspace(first:first+klev-1)

      ! Admit every active latitude and cloud class before the first public output write.
      do column = kidia, kfdia
        word = transfer(pgelat(column),word)
        word = iand(word,int(z'7fffffffffffffff',int64))
        if (word > int(z'3ff921fb54442d18',int64)) call reject_contract()
        sine(column) = selected_sin(pgelat(column))
        surface_pressure = paphm1(column,klev+1)
        a = paphm1(column,1) / surface_pressure
        if (.not. (a < high_boundary)) call reject_contract()
        middle = 1_int32
        do
          a = paphm1(column,middle+1) / surface_pressure
          if (middle >= klev-1_int32) exit
          if (a >= high_boundary) exit
          middle = middle+1_int32
        end do
        if (.not. (a < low_boundary)) call reject_contract()
        boundaries(1,column) = middle
        low = middle+1_int32
        if (low >= klev) call reject_contract()
        do
          a = paphm1(column,low+1) / surface_pressure
          if (low >= klev-1_int32) exit
          if (a >= low_boundary) exit
          low = low+1_int32
        end do
        if (.not. (a >= low_boundary)) call reject_contract()
        boundaries(2,column) = low
      end do
      call cloud_overlap_decorr_len(ydecld,kidia,kfdia,klon,sine,yderad%ndecolat,length_km)
      do column = kidia, kfdia
        do level = 1, klev
          a = max(pa(column,level),0.0_real64)
          fractions(level) = min(a,1.0_real64)
          if (level == klev) cycle
          a = papm1(column,level+1) / papm1(column,level)
          b = selected_log(a)
          a = pt(column,level) + pt(column,level+1)
          c = height_factor * 0.5_real64
          a = c * a
          a = a * b
          a = a * 0.001_real64
          a = -a
          a = a / length_km(column)
          alpha(level) = selected_exp(a)
        end do
        count = klev
        call cldpp_cumulative(count,fractions,alpha,cumulative,pair)
        pct(column) = cumulative(count)
        count = boundaries(1,column)
        call cldpp_cumulative(count,fractions,alpha,cumulative,pair)
        pch(column) = cumulative(count)
        first = boundaries(1,column)+1_int32
        count = boundaries(2,column)-boundaries(1,column)
        call cldpp_cumulative(count,fractions(first:),alpha(first:),cumulative,pair)
        pcm(column) = cumulative(count)
        first = boundaries(2,column)+1_int32
        count = klev-boundaries(2,column)
        call cldpp_cumulative(count,fractions(first:),alpha(first:),cumulative,pair)
        pcl(column) = cumulative(count)
      end do
    end if

    if (kidia <= kfdia) then
      b = 1.0_real64 - cutoff
      do level = 1, klev
        do column = kidia, kfdia
          a = max(pa(column,level),cutoff)
          a = min(a,b)
          pclc(column,level) = a
          if (a > cutoff) then
            pqlwp(column,level) = pl(column,level)
            pqiwp(column,level) = pi(column,level)
          else
            pqlwp(column,level) = 0.0_real64
            pqiwp(column,level) = 0.0_real64
          end if
        end do
      end do
    end if
    if (allocated(workspace)) deallocate(workspace)
  end subroutine cldpp
end module cloud_cover_diagnostics_mod

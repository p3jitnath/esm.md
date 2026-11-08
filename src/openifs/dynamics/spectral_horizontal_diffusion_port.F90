!> Structured Fortran port of the generated runtime SPCHOR calculation.
!! Source: operational_runtime_spectral_horizontal_diffusion_r1/runtime_spectral_horizontal_diffusion.S.
!! Rates are s**(-1), timestep is s, temperature and correction are K.
!! Arrays must be dense and independent, as in the accepted source contract.
!! This module makes no call to an original OpenIFS numerical routine.
module md2asm_spectral_horizontal_diffusion
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: ieee_arithmetic
  implicit none
  private
  public :: spectral_diffusion_controls, apply_spectral_horizontal_diffusion
  public :: spectral_horizontal_diffusion_calls
  integer(int64), save :: completed_calls = 0_int64

  !> Typed values read by the generated entry before any numerical write.
  type :: spectral_diffusion_controls
    integer(int32) :: degree = -1, local_levels = 0, local_orders = 0
    integer(int32) :: spectral_words = 0, first_column = 0, last_column = 0
    integer(int32) :: partition_phase = 0, world = 0, rank = 0
    integer(int32) :: vertical_sets = 0, vertical_set = 0
    logical :: geometry_matches_partition = .false.
    logical :: lstrhd = .false., lm0damp = .false., lnhdyn = .false.
    logical :: lnhx = .false., lslhd_w = .false., lslhd_svd = .false.
    logical :: lrhd_ddh = .false., lnsponge = .false.
    logical :: lstoph_spbs = .false., lstoph_casbs = .false.
    logical :: lvortcon = .false., lnudg = .false., lspt = .true.
  end type spectral_diffusion_controls

contains

  !> Apply the selected complete local-wave diffusion update.
  !! c supplies initialized geometry, partition and branch controls.
  !! orders(:) gives local orders; nasm0(0:) gives one-based pair starts.
  !! first_level(:) gives the first global level for each vertical set.
  !! vort, div and temp have shape (stored levels, spectral real/imag words).
  !! rv, rd and rt have shape (stored levels, degree 0:); rt uses global levels.
  !! correction(:) uses global levels, and pressure(:) uses spectral words.
  !! status=2 leaves every array and the successful-call counter unchanged.
  !! status=0 means this local calculation returned, not forecast acceptance.
  subroutine apply_spectral_horizontal_diffusion(c, orders, nasm0, first_level, &
                                                 timestep, rv, rd, rt, correction, pressure, vort, div, temp, status)
    type(spectral_diffusion_controls), intent(in) :: c
    integer(int32), intent(in) :: orders(:), nasm0(0:), first_level(:)
    real(real64), intent(in) :: timestep, rv(:, 0:), rd(:, 0:), rt(:, 0:)
    real(real64), intent(in) :: correction(:), pressure(:)
    real(real64), intent(inout) :: vort(:, :), div(:, :), temp(:, :)
    integer(int32), intent(out) :: status
    integer :: ib, previous, m, n, j, first, last, old_first, old_last
    integer :: level0, global_level, pair
    real(real64) :: h, rate, product, denominator, value, source_term
    type(ieee_round_type) :: rounding
    logical :: gradual
    real(real64), volatile :: minimum_normal, half_value, subnormal_probe

    status = 2_int32
    if (storage_size(0.0_real64) /= 64 .or. storage_size(0_int32) /= 32) return
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    if (ieee_support_underflow_control(0.0_real64)) then
      call ieee_get_underflow_mode(gradual)
      if (.not. gradual) return
    else
      ! The exact subnormal product checks gradual underflow when the
      ! compiler runtime cannot inquire about its mode. Volatile operands
      ! require this multiplication at execution, without constant folding.
      minimum_normal = tiny(0.0_real64)
      half_value = 0.5_real64
      subnormal_probe = minimum_normal*half_value
      if (transfer(subnormal_probe, 0_int64) /= ibset(0_int64, 51)) return
    end if
    if (c%degree < 0 .or. c%degree > 8191) return
    if (c%local_levels < 1 .or. c%local_levels > 512) return
    if (c%local_orders < 1 .or. c%local_orders > c%degree + 1) return
    if (c%spectral_words < 1 .or. c%first_column /= 1) return
    if (c%last_column /= c%spectral_words) return
    if (c%partition_phase /= 7 .or. .not. c%geometry_matches_partition) return
    if (c%world < 1 .or. c%world > 4096) return
    if (c%rank < 1 .or. c%rank > c%world) return
    if (c%vertical_set < 1 .or. c%vertical_set > c%vertical_sets) return
    if (any([c%lstrhd, c%lm0damp, c%lnhdyn, c%lnhx, c%lslhd_w, &
             c%lslhd_svd, c%lrhd_ddh, c%lnsponge, c%lstoph_spbs, &
             c%lstoph_casbs, c%lvortcon, c%lnudg])) return
    if (.not. c%lspt) return
    if (size(first_level) < c%vertical_set) return
    if (size(orders) < c%local_orders .or. ubound(nasm0, 1) < c%degree) return
    if (first_level(c%vertical_set) < 1) return
    if (first_level(c%vertical_set) > 513 - c%local_levels) return
    level0 = first_level(c%vertical_set) - 1
    if (.not. dense_field(vort, c%local_levels, c%spectral_words)) return
    if (.not. dense_field(div, c%local_levels, c%spectral_words)) return
    if (.not. dense_field(temp, c%local_levels, c%spectral_words)) return
    if (.not. dense_field(rv, c%local_levels, c%degree + 1)) return
    if (.not. dense_field(rd, c%local_levels, c%degree + 1)) return
    if (.not. dense_field(rt, level0 + c%local_levels, c%degree + 1)) return
    if (.not. is_contiguous(orders) .or. .not. is_contiguous(nasm0)) return
    if (.not. is_contiguous(first_level)) return
    if (.not. is_contiguous(pressure) .or. .not. is_contiguous(correction)) return
    if (size(pressure) < c%spectral_words) return
    if (size(correction) < level0 + c%local_levels) return
    if (.not. bounded(timestep)) return
    h = abs(timestep)

    ! Validate all active inputs and all pair intervals before any write.
    do ib = 1, c%local_orders
      m = orders(ib)
      if (m < 0 .or. m > c%degree) return
      first = nasm0(m)
      if (first < 1) return
      if (first > c%spectral_words - 2*(c%degree - m) - 1) return
      last = first + 2*(c%degree - m) + 1
      do previous = 1, ib - 1
        if (orders(previous) == m) return
        old_first = nasm0(orders(previous))
        old_last = old_first + 2*(c%degree - orders(previous)) + 1
        if (last >= old_first .and. old_last >= first) return
      end do
      if (m == 0) cycle
      do n = m, c%degree
        pair = first + 2*(n - m)
        do j = 1, c%local_levels
          if (.not. bounded(vort(j, pair))) return
          if (.not. bounded(vort(j, pair + 1))) return
          if (.not. bounded(div(j, pair))) return
          if (.not. bounded(div(j, pair + 1))) return
          if (.not. bounded(temp(j, pair))) return
          if (.not. bounded(temp(j, pair + 1))) return
          if (.not. bounded(pressure(pair))) return
          if (.not. bounded(pressure(pair + 1))) return
          if (.not. nonnegative_rate(rv(j, n))) return
          if (.not. nonnegative_rate(rd(j, n))) return
          global_level = level0 + j
          if (.not. nonnegative_rate(rt(global_level, n))) return
          if (.not. bounded(correction(global_level))) return
        end do
      end do
    end do

    ! Source order: each order, each degree, all wind levels, all temperature levels.
    do ib = 1, c%local_orders
      m = orders(ib)
      if (m == 0) cycle
      do n = m, c%degree
        pair = nasm0(m) + 2*(n - m)
        do j = 1, c%local_levels
          rate = rv(j, n)
          product = h*rate
          denominator = 1.0_real64 + product
          value = vort(j, pair)/denominator
          vort(j, pair) = value
          value = vort(j, pair + 1)/denominator
          vort(j, pair + 1) = value
          rate = rd(j, n)
          product = h*rate
          denominator = 1.0_real64 + product
          value = div(j, pair)/denominator
          div(j, pair) = value
          value = div(j, pair + 1)/denominator
          div(j, pair + 1) = value
        end do
        do j = 1, c%local_levels
          global_level = level0 + j
          rate = rt(global_level, n)
          source_term = correction(global_level)*pressure(pair)
          source_term = source_term*h
          source_term = source_term*rate
          value = temp(j, pair) + source_term
          product = h*rate
          denominator = 1.0_real64 + product
          value = value/denominator
          temp(j, pair) = value
          source_term = correction(global_level)*pressure(pair + 1)
          source_term = source_term*h
          source_term = source_term*rate
          value = temp(j, pair + 1) + source_term
          value = value/denominator
          temp(j, pair + 1) = value
        end do
      end do
    end do
!$omp atomic update
    completed_calls = completed_calls + 1_int64
    status = 0_int32
  end subroutine apply_spectral_horizontal_diffusion

  !> Return the local successful-call counter without changing numerical data.
  function spectral_horizontal_diffusion_calls() result(value)
    integer(int64) :: value
!$omp atomic read
    value = completed_calls
  end function spectral_horizontal_diffusion_calls

  !> Check a dense rank-two owner using its full stored row capacity.
  logical function dense_field(field, rows, columns)
    real(real64), intent(in) :: field(:, :)
    integer, intent(in) :: rows, columns
    dense_field = is_contiguous(field) .and. size(field, 1) >= rows .and. &
                  size(field, 1) <= 512 .and. size(field, 2) >= columns
  end function dense_field

  !> Check exponent bits directly, preserving signed zeros and exception flags.
  elemental logical function bounded(value)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = transfer(value, word)
    bounded = ibits(word, 52, 11) < 1151_int64
  end function bounded

  !> Require a bounded nonnegative rate while admitting negative zero.
  elemental logical function nonnegative_rate(value)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = transfer(value, word)
    nonnegative_rate = bounded(value) .and. &
                       (.not. btest(word, 63) .or. ibclr(word, 63) == 0_int64)
  end function nonnegative_rate
end module md2asm_spectral_horizontal_diffusion

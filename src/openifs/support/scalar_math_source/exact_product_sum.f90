!> One-rounding finite product and sum using the accepted exact integer limbs.
!! The result and status-return variant shares the frozen 26-bit limb arithmetic.
!! The source fast/wide classification is retained before rounding.
module forecast_exact_product_sum
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use forecast_original_math_status, only: math_domain_exit
  implicit none
  private
  public :: exact_product_sum, finite_product_inputs, product_sum_preparation, prepare_product_sum
  integer, parameter :: limb_bits = 26, limb_count = 166
  integer(c_int64_t), parameter :: limb_base = 67108864_c_int64_t, limb_mask = 67108863_c_int64_t
  integer(c_int64_t), parameter :: fraction_mask = int(z'000FFFFFFFFFFFFF', c_int64_t)
  type product_sum_preparation
    integer(c_int64_t) :: words(3) = 0_c_int64_t
    integer(c_int) :: classification = 0_c_int, refusal_tag = 0_c_int
    logical :: ready = .false.
  end type
contains
  pure logical function finite_product_inputs(a, b, c) result(finite)
    real(c_double), intent(in) :: a, b, c
    finite = ibits(transfer(a, 0_c_int64_t), 52, 11) /= 2047 .and. &
             ibits(transfer(b, 0_c_int64_t), 52, 11) /= 2047 .and. &
             ibits(transfer(c, 0_c_int64_t), 52, 11) /= 2047
  end function
  subroutine prepare_product_sum(a, b, c, prepared)
    real(c_double), intent(in) :: a, b, c
    type(product_sum_preparation), intent(out) :: prepared
    integer(c_int64_t) :: ma, mb, mc, pa(0:2), pb(0:2), pd(0:5), carry, t
    integer :: ea, eb, ec, sa, sb, sc, i, j, k, length, common
    prepared%words = [transfer(a, 0_c_int64_t), transfer(b, 0_c_int64_t), transfer(c, 0_c_int64_t)]
    if (.not. finite_product_inputs(a, b, c)) return
    call decode_word(prepared%words(1), ma, ea, sa)
    call decode_word(prepared%words(2), mb, eb, sb)
    call decode_word(prepared%words(3), mc, ec, sc)
    prepared%classification = 1_c_int
    prepared%refusal_tag = 0_c_int
    prepared%ready = .true.
    if (ma == 0 .or. mb == 0 .or. mc == 0) return
    do i = 0, 2
      pa(i) = iand(shiftr(ma, 26*i), limb_mask)
      pb(i) = iand(shiftr(mb, 26*i), limb_mask)
    end do
    pd = 0_c_int64_t
    do i = 0, 2
      carry = 0_c_int64_t
      do j = 0, 2
        k = i + j
        t = pd(k) + pa(i)*pb(j) + carry
        pd(k) = iand(t, limb_mask)
        carry = shiftr(t, 26)
      end do
      pd(i + 3) = carry
    end do
    length = 0
    do i = 5, 0, -1
      if (pd(i) == 0) cycle
      length = 26*i + bit_size(pd(i)) - leadz(pd(i))
      exit
    end do
    common = min(ea + eb, ec)
    if (ea + eb > ec) then
      if (length + ea + eb - common > 127) prepared%refusal_tag = 2_c_int
    else
      if (bit_size(mc) - leadz(mc) + ec - common > 127) prepared%refusal_tag = 1_c_int
    end if
    if (prepared%refusal_tag /= 0_c_int) prepared%classification = 2_c_int
  end subroutine
  real(c_double) function exact_product_sum(a, b, c, required_mask, classification, magnitude_exponent) result(value)
    real(c_double), intent(in) :: a, b, c
    integer(c_int), intent(out) :: required_mask, classification, magnitude_exponent
    integer(c_int64_t) :: wa, wb, wc, ma, mb, mc, da(0:2), db(0:2), dp(0:5), carry, t
    integer(c_int64_t) :: product(0:limb_count - 1), addend(0:limb_count - 1), total(0:limb_count - 1)
    integer(c_int64_t) :: significand, word
    integer :: ea, eb, ec, sa, sb, sc, sp, sign_result, i, j, k, comparison, borrow, h, exponent, shift
    logical :: discarded, up, tiny_result
    required_mask = 0_c_int
    classification = 1_c_int
    magnitude_exponent = -huge(0)
    if (.not. finite_product_inputs(a, b, c)) call math_domain_exit()
    wa = transfer(a, wa)
    wb = transfer(b, wb)
    wc = transfer(c, wc)
    call decode_word(wa, ma, ea, sa)
    call decode_word(wb, mb, eb, sb)
    call decode_word(wc, mc, ec, sc)
    sp = ieor(sa, sb)
    if (ma == 0_c_int64_t .or. mb == 0_c_int64_t) then
      word = wc
      if (mc == 0_c_int64_t) word = shiftl(int(iand(sp, sc), c_int64_t), 63)
      if (mc /= 0_c_int64_t) magnitude_exponent = ec + bit_size(mc) - 1 - leadz(mc)
      value = transfer(word, value)
      return
    end if
    do i = 0, 2
      da(i) = iand(shiftr(ma, limb_bits*i), limb_mask)
      db(i) = iand(shiftr(mb, limb_bits*i), limb_mask)
    end do
    dp = 0_c_int64_t
    do i = 0, 2
      carry = 0_c_int64_t
      do j = 0, 2
        k = i + j
        t = dp(k) + da(i)*db(j) + carry
        dp(k) = iand(t, limb_mask)
        carry = shiftr(t, limb_bits)
      end do
      dp(i + 3) = carry
    end do
    if (mc /= 0_c_int64_t) then
      k = 0
      do i = 5, 0, -1
        if (dp(i) == 0_c_int64_t) cycle
        k = limb_bits*i + bit_size(dp(i)) - leadz(dp(i))
        exit
      end do
      j = min(ea + eb, ec)
      if (k + ea + eb - j > 127 .or. bit_size(mc) - leadz(mc) + ec - j > 127) classification = 2_c_int
    end if
    product = 0_c_int64_t
    addend = 0_c_int64_t
    do i = 0, 5
      call insert_digit(product, dp(i), ea + eb + 2148 + limb_bits*i)
    end do
    do i = 0, 2
      t = iand(shiftr(mc, limb_bits*i), limb_mask)
      call insert_digit(addend, t, ec + 2148 + limb_bits*i)
    end do
    sign_result = sp
    if (sp == sc) then
      carry = 0_c_int64_t
      do i = 0, limb_count - 1
        t = product(i) + addend(i) + carry
        total(i) = iand(t, limb_mask)
        carry = shiftr(t, limb_bits)
      end do
    else
      comparison = 0
      do i = limb_count - 1, 0, -1
        if (product(i) > addend(i)) then
          comparison = 1
          exit
        else if (product(i) < addend(i)) then
          comparison = -1
          exit
        end if
      end do
      if (comparison == 0) then
        word = 0_c_int64_t
        value = transfer(word, value)
        return
      end if
      borrow = 0
      if (comparison > 0) then
        do i = 0, limb_count - 1
          t = product(i) - addend(i) - int(borrow, c_int64_t)
          borrow = 0
          if (t < 0_c_int64_t) then
            t = t + limb_base
            borrow = 1
          end if
          total(i) = t
        end do
      else
        sign_result = sc
        do i = 0, limb_count - 1
          t = addend(i) - product(i) - int(borrow, c_int64_t)
          borrow = 0
          if (t < 0_c_int64_t) then
            t = t + limb_base
            borrow = 1
          end if
          total(i) = t
        end do
      end if
    end if
    h = -1
    do i = limb_count - 1, 0, -1
      if (total(i) == 0_c_int64_t) cycle
      h = limb_bits*i + (bit_size(total(i)) - 1 - leadz(total(i)))
      exit
    end do
    if (h < 0) then
      word = shiftl(int(sign_result, c_int64_t), 63)
      value = transfer(word, value)
      return
    end if
    exponent = h - 2148
    magnitude_exponent = exponent
    tiny_result = exponent < (-1022)
    shift = h - 52
    if (tiny_result) shift = 1074
    significand = 0_c_int64_t
    do i = h, shift, -1
      significand = shiftl(significand, 1)
      if (test_bit(total, i)) significand = ibset(significand, 0)
    end do
    discarded = any_below(total, shift)
    up = .false.
    if (test_bit(total, shift - 1)) up = any_below(total, shift - 1) .or. btest(significand, 0)
    if (up) significand = significand + 1_c_int64_t
    if (tiny_result) then
      word = ior(significand, shiftl(int(sign_result, c_int64_t), 63))
      if (discarded) then
        required_mask = ior(required_mask, 8_c_int)
        required_mask = ior(required_mask, 16_c_int)
      end if
    else
      if (btest(significand, 53)) then
        significand = shiftr(significand, 1)
        exponent = exponent + 1
      end if
      if (exponent > 1023) then
        word = ior(int(z'7FF0000000000000', c_int64_t), shiftl(int(sign_result, c_int64_t), 63))
        required_mask = ior(required_mask, 4_c_int)
        required_mask = ior(required_mask, 16_c_int)
      else
        word = ior(shiftl(int(exponent + 1023, c_int64_t), 52), iand(significand, fraction_mask))
        word = ior(word, shiftl(int(sign_result, c_int64_t), 63))
        if (discarded) required_mask = ior(required_mask, 16_c_int)
      end if
    end if
    value = transfer(word, value)
  end function exact_product_sum

  !> Decode a finite FP64 word as (-1)**sign * magnitude * 2**exponent.
  pure subroutine decode_word(word, magnitude, exponent, sign)
    integer(c_int64_t), intent(in) :: word
    integer(c_int64_t), intent(out) :: magnitude
    integer, intent(out) :: exponent, sign
    integer :: encoded_exponent
    encoded_exponent = int(ibits(word, 52, 11))
    magnitude = iand(word, fraction_mask)
    exponent = -1074
    if (encoded_exponent /= 0) then
      magnitude = ibset(magnitude, 52)
      exponent = encoded_exponent - 1075
    end if
    sign = int(ibits(word, 63, 1))
  end subroutine decode_word

  !> Insert one nonnegative base-2**26 digit at an exact binary bit position.
  pure subroutine insert_digit(words, digit, position)
    integer(c_int64_t), intent(inout) :: words(0:limb_count - 1)
    integer(c_int64_t), intent(in) :: digit
    integer, intent(in) :: position
    integer :: index, offset
    if (digit == 0_c_int64_t) return
    index = position/limb_bits
    offset = mod(position, limb_bits)
    words(index) = ior(words(index), iand(shiftl(digit, offset), limb_mask))
    if (offset /= 0) words(index + 1) = ior(words(index + 1), shiftr(digit, limb_bits - offset))
  end subroutine insert_digit

  !> Report whether a nonnegative exact integer has a set bit below position.
  pure logical function any_below(words, position) result(found)
    integer(c_int64_t), intent(in) :: words(0:limb_count - 1)
    integer, intent(in) :: position
    integer :: index, offset
    found = .false.
    if (position <= 0) return
    index = position/limb_bits
    offset = mod(position, limb_bits)
    if (index > 0) found = any(words(0:index - 1) /= 0_c_int64_t)
    if (offset /= 0) found = found .or. iand(words(index), shiftl(1_c_int64_t, offset) - 1_c_int64_t) /= 0_c_int64_t
  end function any_below

  !> Read one bit from the nonnegative exact integer without floating arithmetic.
  pure logical function test_bit(words, position) result(found)
    integer(c_int64_t), intent(in) :: words(0:limb_count - 1)
    integer, intent(in) :: position
    found = .false.
    if (position < 0) return
    found = btest(words(position/limb_bits), mod(position, limb_bits))
  end function test_bit
end module forecast_exact_product_sum

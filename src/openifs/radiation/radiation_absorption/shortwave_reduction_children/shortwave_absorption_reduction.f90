!> Source-ordered shortwave absorption weights and reduced coefficient fields.
!! The caller owns the native record and supplies decoded finite tables.
!! Group maps are checked before mutation. Only selected reduced prefixes,
!! WTSM prefixes and all RWGT entries are written; source tables stay unchanged.
module shortwave_absorption_reduction
  use iso_c_binding, only: c_double, c_int
  use native_absorption_records, only: shortwave_absorption_record
  use ordered_absorption_reduction, only: reduce_absorption_field
  implicit none
  private
  public :: reduce_shortwave_absorption
  integer(c_int), parameter :: selected_group_counts(14) = &
                               [6_c_int, 12_c_int, 8_c_int, 8_c_int, 10_c_int, 10_c_int, 2_c_int, 10_c_int, &
                                8_c_int, 6_c_int, 6_c_int, 8_c_int, 6_c_int, 12_c_int]
contains
  !> Calculate source weights, then the 71 reduced fields in source call order.
  !! record is a caller-owned shortwave_absorption_record, intent(inout).
  !! Its WT weights, WTSM sums and RWGT relative weights are dimensionless.
  !! Coefficient reductions retain their input units. Solar-flux tables retain
  !! their source spectral units. Native member bounds retain the source indices.
  !! Return 0 completes calculation. Return 2 rejects unsupported group maps
  !! before any mutation. The caller admits finite inputs, nearest rounding,
  !! gradual underflow and the accepted outer floating-point-control checks.
  integer(c_int) function reduce_shortwave_absorption(record) result(status)
    type(shortwave_absorption_record), target, intent(inout) :: record
    real(c_double), pointer, contiguous :: source(:, :), destination(:, :)
    integer :: band, group, sample, last, group_cursor, weight_cursor, k, first_group, last_group
    real(c_double) :: weight_sum
    status = 2_c_int
    if (any(record%ngc /= selected_group_counts)) return
    group_cursor = 1
    do band = 1, size(record%ngc)
      last_group = group_cursor + int(record%ngc(band)) - 1
      if (any(record%ngn(group_cursor:last_group) <= 0_c_int)) return
      if (any(record%ngn(group_cursor:last_group) > size(record%wt))) return
      if (sum(record%ngn(group_cursor:last_group)) /= size(record%wt)) return
      group_cursor = last_group + 1
    end do

    ! Each band restarts at WT(1), while group and relative-weight slots advance.
    group_cursor = 1
    weight_cursor = 1
    do band = 1, size(record%ngc)
      sample = 1
      do group = 1, int(record%ngc(band))
        last = sample + int(record%ngn(group_cursor)) - 1
        weight_sum = 0.0_c_double
        do k = sample, last
          weight_sum = weight_sum + record%wt(k)
        end do
        record%wtsm(group) = weight_sum
        do k = sample, last
          record%rwgt(weight_cursor) = record%wt(k)/weight_sum
          weight_cursor = weight_cursor + 1
        end do
        sample = last + 1
        group_cursor = group_cursor + 1
      end do
    end do

    ! Band 16: selected groups in their original source order.
    first_group = 1
    last_group = 6
    source(1:size(record%b16_ka)/size(record%b16_ka, 4), 1:size(record%b16_ka, 4)) => &
      record%b16_ka
    destination(1:size(record%b16_kac)/size(record%b16_kac, 4), 1:size(record%b16_kac, 4)) => &
      record%b16_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(1)), record%ngn(first_group:last_group), record%rwgt(1:16))
    source(1:size(record%b16_kb)/size(record%b16_kb, 3), 1:size(record%b16_kb, 3)) => &
      record%b16_kb
    destination(1:size(record%b16_kbc)/size(record%b16_kbc, 3), 1:size(record%b16_kbc, 3)) => &
      record%b16_kbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(1)), record%ngn(first_group:last_group), record%rwgt(1:16))
    source(1:size(record%b16_selfref)/size(record%b16_selfref, 2), 1:size(record%b16_selfref, 2)) => &
      record%b16_selfref
    destination(1:size(record%b16_selfrefc)/size(record%b16_selfrefc, 2), 1:size(record%b16_selfrefc, 2)) => &
      record%b16_selfrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(1)), record%ngn(first_group:last_group), record%rwgt(1:16))
    source(1:size(record%b16_forref)/size(record%b16_forref, 2), 1:size(record%b16_forref, 2)) => &
      record%b16_forref
    destination(1:size(record%b16_forrefc)/size(record%b16_forrefc, 2), 1:size(record%b16_forrefc, 2)) => &
      record%b16_forrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(1)), record%ngn(first_group:last_group), record%rwgt(1:16))
    source(1:1, 1:size(record%b16_sfluxref)) => record%b16_sfluxref
    destination(1:1, 1:size(record%b16_sfluxrefc)) => record%b16_sfluxrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(1)), record%ngn(first_group:last_group))

    ! Band 17: selected groups in their original source order.
    first_group = 7
    last_group = 18
    source(1:size(record%b17_ka)/size(record%b17_ka, 4), 1:size(record%b17_ka, 4)) => &
      record%b17_ka
    destination(1:size(record%b17_kac)/size(record%b17_kac, 4), 1:size(record%b17_kac, 4)) => &
      record%b17_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(2)), record%ngn(first_group:last_group), record%rwgt(17:32))
    source(1:size(record%b17_kb)/size(record%b17_kb, 4), 1:size(record%b17_kb, 4)) => &
      record%b17_kb
    destination(1:size(record%b17_kbc)/size(record%b17_kbc, 4), 1:size(record%b17_kbc, 4)) => &
      record%b17_kbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(2)), record%ngn(first_group:last_group), record%rwgt(17:32))
    source(1:size(record%b17_selfref)/size(record%b17_selfref, 2), 1:size(record%b17_selfref, 2)) => &
      record%b17_selfref
    destination(1:size(record%b17_selfrefc)/size(record%b17_selfrefc, 2), 1:size(record%b17_selfrefc, 2)) => &
      record%b17_selfrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(2)), record%ngn(first_group:last_group), record%rwgt(17:32))
    source(1:size(record%b17_forref)/size(record%b17_forref, 2), 1:size(record%b17_forref, 2)) => &
      record%b17_forref
    destination(1:size(record%b17_forrefc)/size(record%b17_forrefc, 2), 1:size(record%b17_forrefc, 2)) => &
      record%b17_forrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(2)), record%ngn(first_group:last_group), record%rwgt(17:32))
    call reduce_sample_first(record%b17_sfluxref, record%b17_sfluxrefc, record%ngn(first_group:last_group))

    ! Band 18: selected groups in their original source order.
    first_group = 19
    last_group = 26
    source(1:size(record%b18_ka)/size(record%b18_ka, 4), 1:size(record%b18_ka, 4)) => &
      record%b18_ka
    destination(1:size(record%b18_kac)/size(record%b18_kac, 4), 1:size(record%b18_kac, 4)) => &
      record%b18_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(3)), record%ngn(first_group:last_group), record%rwgt(33:48))
    source(1:size(record%b18_kb)/size(record%b18_kb, 3), 1:size(record%b18_kb, 3)) => &
      record%b18_kb
    destination(1:size(record%b18_kbc)/size(record%b18_kbc, 3), 1:size(record%b18_kbc, 3)) => &
      record%b18_kbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(3)), record%ngn(first_group:last_group), record%rwgt(33:48))
    source(1:size(record%b18_selfref)/size(record%b18_selfref, 2), 1:size(record%b18_selfref, 2)) => &
      record%b18_selfref
    destination(1:size(record%b18_selfrefc)/size(record%b18_selfrefc, 2), 1:size(record%b18_selfrefc, 2)) => &
      record%b18_selfrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(3)), record%ngn(first_group:last_group), record%rwgt(33:48))
    source(1:size(record%b18_forref)/size(record%b18_forref, 2), 1:size(record%b18_forref, 2)) => &
      record%b18_forref
    destination(1:size(record%b18_forrefc)/size(record%b18_forrefc, 2), 1:size(record%b18_forrefc, 2)) => &
      record%b18_forrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(3)), record%ngn(first_group:last_group), record%rwgt(33:48))
    call reduce_sample_first(record%b18_sfluxref, record%b18_sfluxrefc, record%ngn(first_group:last_group))

    ! Band 19: selected groups in their original source order.
    first_group = 27
    last_group = 34
    source(1:size(record%b19_ka)/size(record%b19_ka, 4), 1:size(record%b19_ka, 4)) => &
      record%b19_ka
    destination(1:size(record%b19_kac)/size(record%b19_kac, 4), 1:size(record%b19_kac, 4)) => &
      record%b19_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(4)), record%ngn(first_group:last_group), record%rwgt(49:64))
    source(1:size(record%b19_kb)/size(record%b19_kb, 3), 1:size(record%b19_kb, 3)) => &
      record%b19_kb
    destination(1:size(record%b19_kbc)/size(record%b19_kbc, 3), 1:size(record%b19_kbc, 3)) => &
      record%b19_kbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(4)), record%ngn(first_group:last_group), record%rwgt(49:64))
    source(1:size(record%b19_selfref)/size(record%b19_selfref, 2), 1:size(record%b19_selfref, 2)) => &
      record%b19_selfref
    destination(1:size(record%b19_selfrefc)/size(record%b19_selfrefc, 2), 1:size(record%b19_selfrefc, 2)) => &
      record%b19_selfrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(4)), record%ngn(first_group:last_group), record%rwgt(49:64))
    source(1:size(record%b19_forref)/size(record%b19_forref, 2), 1:size(record%b19_forref, 2)) => &
      record%b19_forref
    destination(1:size(record%b19_forrefc)/size(record%b19_forrefc, 2), 1:size(record%b19_forrefc, 2)) => &
      record%b19_forrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(4)), record%ngn(first_group:last_group), record%rwgt(49:64))
    call reduce_sample_first(record%b19_sfluxref, record%b19_sfluxrefc, record%ngn(first_group:last_group))

    ! Band 20: selected groups in their original source order.
    first_group = 35
    last_group = 44
    source(1:size(record%b20_ka)/size(record%b20_ka, 3), 1:size(record%b20_ka, 3)) => &
      record%b20_ka
    destination(1:size(record%b20_kac)/size(record%b20_kac, 3), 1:size(record%b20_kac, 3)) => &
      record%b20_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(5)), record%ngn(first_group:last_group), record%rwgt(65:80))
    source(1:size(record%b20_kb)/size(record%b20_kb, 3), 1:size(record%b20_kb, 3)) => &
      record%b20_kb
    destination(1:size(record%b20_kbc)/size(record%b20_kbc, 3), 1:size(record%b20_kbc, 3)) => &
      record%b20_kbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(5)), record%ngn(first_group:last_group), record%rwgt(65:80))
    source(1:size(record%b20_selfref)/size(record%b20_selfref, 2), 1:size(record%b20_selfref, 2)) => &
      record%b20_selfref
    destination(1:size(record%b20_selfrefc)/size(record%b20_selfrefc, 2), 1:size(record%b20_selfrefc, 2)) => &
      record%b20_selfrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(5)), record%ngn(first_group:last_group), record%rwgt(65:80))
    source(1:size(record%b20_forref)/size(record%b20_forref, 2), 1:size(record%b20_forref, 2)) => &
      record%b20_forref
    destination(1:size(record%b20_forrefc)/size(record%b20_forrefc, 2), 1:size(record%b20_forrefc, 2)) => &
      record%b20_forrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(5)), record%ngn(first_group:last_group), record%rwgt(65:80))
    source(1:1, 1:size(record%b20_sfluxref)) => record%b20_sfluxref
    destination(1:1, 1:size(record%b20_sfluxrefc)) => record%b20_sfluxrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(5)), record%ngn(first_group:last_group))
    source(1:1, 1:size(record%b20_absch4)) => record%b20_absch4
    destination(1:1, 1:size(record%b20_absch4c)) => record%b20_absch4c
    call reduce_absorption_field(source, destination(:, 1:record%ngc(5)), record%ngn(first_group:last_group), record%rwgt(65:80))

    ! Band 21: selected groups in their original source order.
    first_group = 45
    last_group = 54
    source(1:size(record%b21_ka)/size(record%b21_ka, 4), 1:size(record%b21_ka, 4)) => &
      record%b21_ka
    destination(1:size(record%b21_kac)/size(record%b21_kac, 4), 1:size(record%b21_kac, 4)) => &
      record%b21_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(6)), record%ngn(first_group:last_group), record%rwgt(81:96))
    source(1:size(record%b21_kb)/size(record%b21_kb, 4), 1:size(record%b21_kb, 4)) => &
      record%b21_kb
    destination(1:size(record%b21_kbc)/size(record%b21_kbc, 4), 1:size(record%b21_kbc, 4)) => &
      record%b21_kbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(6)), record%ngn(first_group:last_group), record%rwgt(81:96))
    source(1:size(record%b21_selfref)/size(record%b21_selfref, 2), 1:size(record%b21_selfref, 2)) => &
      record%b21_selfref
    destination(1:size(record%b21_selfrefc)/size(record%b21_selfrefc, 2), 1:size(record%b21_selfrefc, 2)) => &
      record%b21_selfrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(6)), record%ngn(first_group:last_group), record%rwgt(81:96))
    source(1:size(record%b21_forref)/size(record%b21_forref, 2), 1:size(record%b21_forref, 2)) => &
      record%b21_forref
    destination(1:size(record%b21_forrefc)/size(record%b21_forrefc, 2), 1:size(record%b21_forrefc, 2)) => &
      record%b21_forrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(6)), record%ngn(first_group:last_group), record%rwgt(81:96))
    call reduce_sample_first(record%b21_sfluxref, record%b21_sfluxrefc, record%ngn(first_group:last_group))

    ! Band 22: selected groups in their original source order.
    first_group = 55
    last_group = 56
    source(1:size(record%b22_ka)/size(record%b22_ka, 4), 1:size(record%b22_ka, 4)) => &
      record%b22_ka
    destination(1:size(record%b22_kac)/size(record%b22_kac, 4), 1:size(record%b22_kac, 4)) => &
      record%b22_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(7)), record%ngn(first_group:last_group), record%rwgt(97:112))
    source(1:size(record%b22_kb)/size(record%b22_kb, 3), 1:size(record%b22_kb, 3)) => &
      record%b22_kb
    destination(1:size(record%b22_kbc)/size(record%b22_kbc, 3), 1:size(record%b22_kbc, 3)) => &
      record%b22_kbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(7)), record%ngn(first_group:last_group), record%rwgt(97:112))
    source(1:size(record%b22_selfref)/size(record%b22_selfref, 2), 1:size(record%b22_selfref, 2)) => &
      record%b22_selfref
    destination(1:size(record%b22_selfrefc)/size(record%b22_selfrefc, 2), 1:size(record%b22_selfrefc, 2)) => &
      record%b22_selfrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(7)), record%ngn(first_group:last_group), record%rwgt(97:112))
    source(1:size(record%b22_forref)/size(record%b22_forref, 2), 1:size(record%b22_forref, 2)) => &
      record%b22_forref
    destination(1:size(record%b22_forrefc)/size(record%b22_forrefc, 2), 1:size(record%b22_forrefc, 2)) => &
      record%b22_forrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(7)), record%ngn(first_group:last_group), record%rwgt(97:112))
    call reduce_sample_first(record%b22_sfluxref, record%b22_sfluxrefc, record%ngn(first_group:last_group))

    ! Band 23: selected groups in their original source order.
    first_group = 57
    last_group = 66
    source(1:size(record%b23_ka)/size(record%b23_ka, 3), 1:size(record%b23_ka, 3)) => &
      record%b23_ka
    destination(1:size(record%b23_kac)/size(record%b23_kac, 3), 1:size(record%b23_kac, 3)) => &
      record%b23_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(8)), record%ngn(first_group:last_group), record%rwgt(113:128))
    source(1:size(record%b23_selfref)/size(record%b23_selfref, 2), 1:size(record%b23_selfref, 2)) => &
      record%b23_selfref
    destination(1:size(record%b23_selfrefc)/size(record%b23_selfrefc, 2), 1:size(record%b23_selfrefc, 2)) => &
      record%b23_selfrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(8)), record%ngn(first_group:last_group), record%rwgt(113:128))
    source(1:size(record%b23_forref)/size(record%b23_forref, 2), 1:size(record%b23_forref, 2)) => &
      record%b23_forref
    destination(1:size(record%b23_forrefc)/size(record%b23_forrefc, 2), 1:size(record%b23_forrefc, 2)) => &
      record%b23_forrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(8)), record%ngn(first_group:last_group), record%rwgt(113:128))
    source(1:1, 1:size(record%b23_sfluxref)) => record%b23_sfluxref
    destination(1:1, 1:size(record%b23_sfluxrefc)) => record%b23_sfluxrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(8)), record%ngn(first_group:last_group))
    source(1:1, 1:size(record%b23_rayl)) => record%b23_rayl
    destination(1:1, 1:size(record%b23_raylc)) => record%b23_raylc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(8)), record%ngn(first_group:last_group), record%rwgt(113:128))

    ! Band 24: selected groups in their original source order.
    first_group = 67
    last_group = 74
    source(1:size(record%b24_ka)/size(record%b24_ka, 4), 1:size(record%b24_ka, 4)) => &
      record%b24_ka
    destination(1:size(record%b24_kac)/size(record%b24_kac, 4), 1:size(record%b24_kac, 4)) => &
      record%b24_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(9)), record%ngn(first_group:last_group), record%rwgt(129:144))
    source(1:size(record%b24_kb)/size(record%b24_kb, 3), 1:size(record%b24_kb, 3)) => &
      record%b24_kb
    destination(1:size(record%b24_kbc)/size(record%b24_kbc, 3), 1:size(record%b24_kbc, 3)) => &
      record%b24_kbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(9)), record%ngn(first_group:last_group), record%rwgt(129:144))
    source(1:size(record%b24_selfref)/size(record%b24_selfref, 2), 1:size(record%b24_selfref, 2)) => &
      record%b24_selfref
    destination(1:size(record%b24_selfrefc)/size(record%b24_selfrefc, 2), 1:size(record%b24_selfrefc, 2)) => &
      record%b24_selfrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(9)), record%ngn(first_group:last_group), record%rwgt(129:144))
    source(1:size(record%b24_forref)/size(record%b24_forref, 2), 1:size(record%b24_forref, 2)) => &
      record%b24_forref
    destination(1:size(record%b24_forrefc)/size(record%b24_forrefc, 2), 1:size(record%b24_forrefc, 2)) => &
      record%b24_forrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(9)), record%ngn(first_group:last_group), record%rwgt(129:144))
    call reduce_sample_first(record%b24_sfluxref, record%b24_sfluxrefc, record%ngn(first_group:last_group))
    source(1:1, 1:size(record%b24_abso3a)) => record%b24_abso3a
    destination(1:1, 1:size(record%b24_abso3ac)) => record%b24_abso3ac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(9)), record%ngn(first_group:last_group), record%rwgt(129:144))
    source(1:1, 1:size(record%b24_abso3b)) => record%b24_abso3b
    destination(1:1, 1:size(record%b24_abso3bc)) => record%b24_abso3bc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(9)), record%ngn(first_group:last_group), record%rwgt(129:144))
    call reduce_sample_first(record%b24_rayla, record%b24_raylac, record%ngn(first_group:last_group), record%rwgt(129:144))
    source(1:1, 1:size(record%b24_raylb)) => record%b24_raylb
    destination(1:1, 1:size(record%b24_raylbc)) => record%b24_raylbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(9)), record%ngn(first_group:last_group), record%rwgt(129:144))

    ! Band 25: selected groups in their original source order.
    first_group = 75
    last_group = 80
    source(1:size(record%b25_ka)/size(record%b25_ka, 3), 1:size(record%b25_ka, 3)) => &
      record%b25_ka
    destination(1:size(record%b25_kac)/size(record%b25_kac, 3), 1:size(record%b25_kac, 3)) => &
      record%b25_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(10)), record%ngn(first_group:last_group), record%rwgt(145:160))
    source(1:1, 1:size(record%b25_sfluxref)) => record%b25_sfluxref
    destination(1:1, 1:size(record%b25_sfluxrefc)) => record%b25_sfluxrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(10)), record%ngn(first_group:last_group))
    source(1:1, 1:size(record%b25_rayl)) => record%b25_rayl
    destination(1:1, 1:size(record%b25_raylc)) => record%b25_raylc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(10)), record%ngn(first_group:last_group), record%rwgt(145:160))
    source(1:1, 1:size(record%b25_abso3a)) => record%b25_abso3a
    destination(1:1, 1:size(record%b25_abso3ac)) => record%b25_abso3ac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(10)), record%ngn(first_group:last_group), record%rwgt(145:160))
    source(1:1, 1:size(record%b25_abso3b)) => record%b25_abso3b
    destination(1:1, 1:size(record%b25_abso3bc)) => record%b25_abso3bc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(10)), record%ngn(first_group:last_group), record%rwgt(145:160))

    ! Band 26: selected groups in their original source order.
    first_group = 81
    last_group = 86
    source(1:1, 1:size(record%b26_sfluxref)) => record%b26_sfluxref
    destination(1:1, 1:size(record%b26_sfluxrefc)) => record%b26_sfluxrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(11)), record%ngn(first_group:last_group))
    source(1:1, 1:size(record%b26_rayl)) => record%b26_rayl
    destination(1:1, 1:size(record%b26_raylc)) => record%b26_raylc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(11)), record%ngn(first_group:last_group), record%rwgt(161:176))

    ! Band 27: selected groups in their original source order.
    first_group = 87
    last_group = 94
    source(1:size(record%b27_ka)/size(record%b27_ka, 3), 1:size(record%b27_ka, 3)) => &
      record%b27_ka
    destination(1:size(record%b27_kac)/size(record%b27_kac, 3), 1:size(record%b27_kac, 3)) => &
      record%b27_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(12)), record%ngn(first_group:last_group), record%rwgt(177:192))
    source(1:size(record%b27_kb)/size(record%b27_kb, 3), 1:size(record%b27_kb, 3)) => &
      record%b27_kb
    destination(1:size(record%b27_kbc)/size(record%b27_kbc, 3), 1:size(record%b27_kbc, 3)) => &
      record%b27_kbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(12)), record%ngn(first_group:last_group), record%rwgt(177:192))
    source(1:1, 1:size(record%b27_sfluxref)) => record%b27_sfluxref
    destination(1:1, 1:size(record%b27_sfluxrefc)) => record%b27_sfluxrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(12)), record%ngn(first_group:last_group))
    source(1:1, 1:size(record%b27_rayl)) => record%b27_rayl
    destination(1:1, 1:size(record%b27_raylc)) => record%b27_raylc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(12)), record%ngn(first_group:last_group), record%rwgt(177:192))

    ! Band 28: selected groups in their original source order.
    first_group = 95
    last_group = 100
    source(1:size(record%b28_ka)/size(record%b28_ka, 4), 1:size(record%b28_ka, 4)) => &
      record%b28_ka
    destination(1:size(record%b28_kac)/size(record%b28_kac, 4), 1:size(record%b28_kac, 4)) => &
      record%b28_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(13)), record%ngn(first_group:last_group), record%rwgt(193:208))
    source(1:size(record%b28_kb)/size(record%b28_kb, 4), 1:size(record%b28_kb, 4)) => &
      record%b28_kb
    destination(1:size(record%b28_kbc)/size(record%b28_kbc, 4), 1:size(record%b28_kbc, 4)) => &
      record%b28_kbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(13)), record%ngn(first_group:last_group), record%rwgt(193:208))
    call reduce_sample_first(record%b28_sfluxref, record%b28_sfluxrefc, record%ngn(first_group:last_group))

    ! Band 29: selected groups in their original source order.
    first_group = 101
    last_group = 112
    source(1:size(record%b29_ka)/size(record%b29_ka, 3), 1:size(record%b29_ka, 3)) => &
      record%b29_ka
    destination(1:size(record%b29_kac)/size(record%b29_kac, 3), 1:size(record%b29_kac, 3)) => &
      record%b29_kac
    call reduce_absorption_field(source, destination(:, 1:record%ngc(14)), record%ngn(first_group:last_group), record%rwgt(209:224))
    source(1:size(record%b29_kb)/size(record%b29_kb, 3), 1:size(record%b29_kb, 3)) => &
      record%b29_kb
    destination(1:size(record%b29_kbc)/size(record%b29_kbc, 3), 1:size(record%b29_kbc, 3)) => &
      record%b29_kbc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(14)), record%ngn(first_group:last_group), record%rwgt(209:224))
    source(1:size(record%b29_selfref)/size(record%b29_selfref, 2), 1:size(record%b29_selfref, 2)) => &
      record%b29_selfref
    destination(1:size(record%b29_selfrefc)/size(record%b29_selfrefc, 2), 1:size(record%b29_selfrefc, 2)) => &
      record%b29_selfrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(14)), record%ngn(first_group:last_group), record%rwgt(209:224))
    source(1:size(record%b29_forref)/size(record%b29_forref, 2), 1:size(record%b29_forref, 2)) => &
      record%b29_forref
    destination(1:size(record%b29_forrefc)/size(record%b29_forrefc, 2), 1:size(record%b29_forrefc, 2)) => &
      record%b29_forrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(14)), record%ngn(first_group:last_group), record%rwgt(209:224))
    source(1:1, 1:size(record%b29_sfluxref)) => record%b29_sfluxref
    destination(1:1, 1:size(record%b29_sfluxrefc)) => record%b29_sfluxrefc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(14)), record%ngn(first_group:last_group))
    source(1:1, 1:size(record%b29_absh2o)) => record%b29_absh2o
    destination(1:1, 1:size(record%b29_absh2oc)) => record%b29_absh2oc
    call reduce_absorption_field(source, destination(:, 1:record%ngc(14)), record%ngn(first_group:last_group), record%rwgt(209:224))
    source(1:1, 1:size(record%b29_absco2)) => record%b29_absco2
    destination(1:1, 1:size(record%b29_absco2c)) => record%b29_absco2c
    call reduce_absorption_field(source, destination(:, 1:record%ngc(14)), record%ngn(first_group:last_group), record%rwgt(209:224))
    status = 0_c_int
  end function reduce_shortwave_absorption

  !> Reduce arrays whose first index is the original sample and second is cell.
  !! source has shape (16,cells), intent(in). destination has the same declared
  !! shape, intent(inout); only its first size(group_counts) rows are changed.
  !! Positive int32 group_counts sum to 16. Optional weights are dimensionless.
  subroutine reduce_sample_first(source, destination, group_counts, weights)
    real(c_double), contiguous, intent(in) :: source(:, :)
    real(c_double), contiguous, intent(inout) :: destination(:, :)
    integer(c_int), contiguous, intent(in) :: group_counts(:)
    real(c_double), contiguous, optional, intent(in) :: weights(:)
    real(c_double) :: transposed_source(size(source, 2), size(source, 1))
    real(c_double) :: transposed_destination(size(destination, 2), size(group_counts))
    integer :: cell, group
    transposed_source = transpose(source)
    call reduce_absorption_field(transposed_source, transposed_destination, group_counts, weights)
    do cell = 1, size(destination, 2)
      do group = 1, size(group_counts)
        destination(group, cell) = transposed_destination(cell, group)
      end do
    end do
  end subroutine reduce_sample_first
end module shortwave_absorption_reduction

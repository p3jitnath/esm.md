!> Native selected longwave reduction from 256 to 140 absorption samples.
!! All persistent values belong to the caller's named records. No original
!! module, recorded numerical result or private byte layout supplies a stage.
module native_longwave_absorption_reduction
  use iso_c_binding, only: c_int, c_int64_t, c_intptr_t, c_size_t, c_double, c_ptr, c_f_pointer, c_associated, c_sizeof
  use native_absorption_records, only: longwave_absorption_input_record, longwave_absorption_reduced_record
  use ordered_absorption_reduction, only: reduce_absorption_field
  implicit none
  private
  public :: reduce_longwave_absorption, md2asm_reduce_longwave_absorption_fortran
  integer(c_int), parameter :: selected_ngc(16) = [ &
                10_c_int, 12_c_int, 16_c_int, 14_c_int, 16_c_int, 8_c_int, 12_c_int, 8_c_int, 12_c_int, 6_c_int, 8_c_int, 8_c_int, &
                               4_c_int, 2_c_int, 2_c_int, 2_c_int]
  integer(c_int), parameter :: selected_ngs(16) = [ &
       10_c_int, 22_c_int, 38_c_int, 52_c_int, 68_c_int, 76_c_int, 88_c_int, 96_c_int, 108_c_int, 114_c_int, 122_c_int, 130_c_int, &
                               134_c_int, 136_c_int, 138_c_int, 140_c_int]
  integer(c_int), parameter :: selected_ngn(140) = [ &
                       1_c_int, 1_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, &
                       1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 1_c_int, 1_c_int, &
                       1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, &
                       1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, &
                       1_c_int, 1_c_int, 1_c_int, 3_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, &
                       1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, &
                       2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, &
                       1_c_int, 1_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, &
                       1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, &
                       2_c_int, 2_c_int, 2_c_int, 2_c_int, 4_c_int, 4_c_int, 1_c_int, 1_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, &
                       3_c_int, 3_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 2_c_int, 2_c_int, 4_c_int, 4_c_int, 3_c_int, 3_c_int, &
                               4_c_int, 6_c_int, 8_c_int, 8_c_int, 8_c_int, 8_c_int, 4_c_int, 12_c_int]
  integer(c_int), parameter :: selected_ngb(140) = [ &
                       1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 2_c_int, 2_c_int, &
                       2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 3_c_int, 3_c_int, &
                       3_c_int, 3_c_int, 3_c_int, 3_c_int, 3_c_int, 3_c_int, 3_c_int, 3_c_int, 3_c_int, 3_c_int, 3_c_int, 3_c_int, &
                       3_c_int, 3_c_int, 4_c_int, 4_c_int, 4_c_int, 4_c_int, 4_c_int, 4_c_int, 4_c_int, 4_c_int, 4_c_int, 4_c_int, &
                       4_c_int, 4_c_int, 4_c_int, 4_c_int, 5_c_int, 5_c_int, 5_c_int, 5_c_int, 5_c_int, 5_c_int, 5_c_int, 5_c_int, &
                       5_c_int, 5_c_int, 5_c_int, 5_c_int, 5_c_int, 5_c_int, 5_c_int, 5_c_int, 6_c_int, 6_c_int, 6_c_int, 6_c_int, &
                       6_c_int, 6_c_int, 6_c_int, 6_c_int, 7_c_int, 7_c_int, 7_c_int, 7_c_int, 7_c_int, 7_c_int, 7_c_int, 7_c_int, &
                       7_c_int, 7_c_int, 7_c_int, 7_c_int, 8_c_int, 8_c_int, 8_c_int, 8_c_int, 8_c_int, 8_c_int, 8_c_int, 8_c_int, &
                       9_c_int, 9_c_int, 9_c_int, 9_c_int, 9_c_int, 9_c_int, 9_c_int, 9_c_int, 9_c_int, 9_c_int, 9_c_int, 9_c_int, &
           10_c_int, 10_c_int, 10_c_int, 10_c_int, 10_c_int, 10_c_int, 11_c_int, 11_c_int, 11_c_int, 11_c_int, 11_c_int, 11_c_int, &
           11_c_int, 11_c_int, 12_c_int, 12_c_int, 12_c_int, 12_c_int, 12_c_int, 12_c_int, 12_c_int, 12_c_int, 13_c_int, 13_c_int, &
                               13_c_int, 13_c_int, 14_c_int, 14_c_int, 15_c_int, 15_c_int, 16_c_int, 16_c_int]
  integer(c_int), parameter :: selected_ngm(256) = [ &
                       1_c_int, 2_c_int, 3_c_int, 3_c_int, 4_c_int, 4_c_int, 5_c_int, 5_c_int, 6_c_int, 6_c_int, 7_c_int, 7_c_int, &
                      8_c_int, 8_c_int, 9_c_int, 10_c_int, 1_c_int, 2_c_int, 3_c_int, 4_c_int, 5_c_int, 6_c_int, 7_c_int, 8_c_int, &
                 9_c_int, 9_c_int, 10_c_int, 10_c_int, 11_c_int, 11_c_int, 12_c_int, 12_c_int, 1_c_int, 2_c_int, 3_c_int, 4_c_int, &
                5_c_int, 6_c_int, 7_c_int, 8_c_int, 9_c_int, 10_c_int, 11_c_int, 12_c_int, 13_c_int, 14_c_int, 15_c_int, 16_c_int, &
                    1_c_int, 2_c_int, 3_c_int, 4_c_int, 5_c_int, 6_c_int, 7_c_int, 8_c_int, 9_c_int, 10_c_int, 11_c_int, 12_c_int, &
                   13_c_int, 14_c_int, 14_c_int, 14_c_int, 1_c_int, 2_c_int, 3_c_int, 4_c_int, 5_c_int, 6_c_int, 7_c_int, 8_c_int, &
                9_c_int, 10_c_int, 11_c_int, 12_c_int, 13_c_int, 14_c_int, 15_c_int, 16_c_int, 1_c_int, 1_c_int, 2_c_int, 2_c_int, &
                       3_c_int, 3_c_int, 4_c_int, 4_c_int, 5_c_int, 5_c_int, 6_c_int, 6_c_int, 7_c_int, 7_c_int, 8_c_int, 8_c_int, &
                      1_c_int, 1_c_int, 2_c_int, 2_c_int, 3_c_int, 4_c_int, 5_c_int, 6_c_int, 7_c_int, 8_c_int, 9_c_int, 10_c_int, &
                   11_c_int, 11_c_int, 12_c_int, 12_c_int, 1_c_int, 1_c_int, 2_c_int, 2_c_int, 3_c_int, 3_c_int, 4_c_int, 4_c_int, &
                       5_c_int, 5_c_int, 6_c_int, 6_c_int, 7_c_int, 7_c_int, 8_c_int, 8_c_int, 1_c_int, 2_c_int, 3_c_int, 4_c_int, &
                 5_c_int, 6_c_int, 7_c_int, 8_c_int, 9_c_int, 9_c_int, 10_c_int, 10_c_int, 11_c_int, 11_c_int, 12_c_int, 12_c_int, &
                       1_c_int, 1_c_int, 2_c_int, 2_c_int, 3_c_int, 3_c_int, 4_c_int, 4_c_int, 5_c_int, 5_c_int, 5_c_int, 5_c_int, &
                       6_c_int, 6_c_int, 6_c_int, 6_c_int, 1_c_int, 2_c_int, 3_c_int, 3_c_int, 4_c_int, 4_c_int, 5_c_int, 5_c_int, &
                       6_c_int, 6_c_int, 7_c_int, 7_c_int, 7_c_int, 8_c_int, 8_c_int, 8_c_int, 1_c_int, 2_c_int, 3_c_int, 4_c_int, &
                       5_c_int, 5_c_int, 6_c_int, 6_c_int, 7_c_int, 7_c_int, 7_c_int, 7_c_int, 8_c_int, 8_c_int, 8_c_int, 8_c_int, &
                       1_c_int, 1_c_int, 1_c_int, 2_c_int, 2_c_int, 2_c_int, 3_c_int, 3_c_int, 3_c_int, 3_c_int, 4_c_int, 4_c_int, &
                       4_c_int, 4_c_int, 4_c_int, 4_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, &
                       2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 1_c_int, 1_c_int, 1_c_int, 1_c_int, &
                       1_c_int, 1_c_int, 1_c_int, 1_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, &
                       1_c_int, 1_c_int, 1_c_int, 1_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, 2_c_int, &
                               2_c_int, 2_c_int, 2_c_int, 2_c_int]
  integer(c_int64_t), parameter :: weight_words(16) = [ &
                                   int(z'3FC38D6C9FF26B70', c_int64_t), &
                                   int(z'3FC318197FF9778A', c_int64_t), &
                                   int(z'3FC23034DFE95BBA', c_int64_t), &
                                   int(z'3FC0DB2C7FF37CD0', c_int64_t), &
                                   int(z'3FBE41FF001D28A7', c_int64_t), &
                                   int(z'3FBA181720059896', c_int64_t), &
                                   int(z'3FB5519F4032DC31', c_int64_t), &
                                   int(z'3FB00B45E0324FF6', c_int64_t), &
                                   int(z'3FA5C193B3A68B1A', c_int64_t), &
                                   int(z'3F72F3C0026E573C', c_int64_t), &
                                   int(z'3F6F5BDFFFCE64A4', c_int64_t), &
                                   int(z'3F68C9FFFF2E67D5', c_int64_t), &
                                   int(z'3F622FA000BBE7A2', c_int64_t), &
                                   int(z'3F572AC0034BF609', c_int64_t), &
                                   int(z'3F417720C8CD63CC', c_int64_t), &
                                   int(z'3F13A92A30553261', c_int64_t)]
contains
  !> Replace all source-defined members of one native reduced coefficient record.
  !! input is a complete read-only FP64 coefficient record. output is caller-owned
  !! storage with intent(inout); its source-unwritten cells retain their values.
  !! Coefficient units follow their named source fields; fractions and weights
  !! are dimensionless. Input and output must be disjoint and eight-byte aligned.
  !! The caller selects nearest rounding with gradual underflow. Return 0 completes.
  recursive integer(c_int) function reduce_longwave_absorption(input, output) result(status)
    type(longwave_absorption_input_record), intent(in) :: input
    type(longwave_absorption_reduced_record), intent(inout) :: output
    output%ngc = selected_ngc
    output%ngs = selected_ngs
    output%ngn(1:140) = selected_ngn
    output%ngb(1:140) = selected_ngb
    output%ngm = selected_ngm
    output%wt = transfer(weight_words, output%wt, 16)
    call longwave_corrections_and_weights(output)
    output%frefa(1:140, :) = 0.0_c_double
    output%frefb(1:140, :) = 0.0_c_double
    output%frefadf(1:140, :) = 0.0_c_double
    output%frefbdf(1:140, :) = 0.0_c_double
    ! Band 1: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(1, 10)
      call reduce_absorption_field(reshape(input%b1_fracrefao, [1, 16]), reduced, output%ngn(1:10))
      output%b1_fracrefa = reshape(reduced, shape(output%b1_fracrefa))
    end block
    ! Band 1: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(1, 10)
      call reduce_absorption_field(reshape(input%b1_fracrefbo, [1, 16]), reduced, output%ngn(1:10))
      output%b1_fracrefb = reshape(reduced, shape(output%b1_fracrefb))
    end block
    ! Band 1: KAO -> KA.
    block
      real(c_double) :: reduced(65, 10)
      call reduce_absorption_field(reshape(input%b1_kao, [65, 16]), reduced, output%ngn(1:10), output%rwgt(1:16))
      output%b1_ka = reshape(reduced, shape(output%b1_ka))
    end block
    ! Band 1: KBO -> KB.
    block
      real(c_double) :: reduced(235, 10)
      call reduce_absorption_field(reshape(input%b1_kbo, [235, 16]), reduced, output%ngn(1:10), output%rwgt(1:16))
      output%b1_kb = reshape(reduced, shape(output%b1_kb))
    end block
    ! Band 1: KAO_MN2 -> KA_MN2.
    block
      real(c_double) :: reduced(19, 10)
      call reduce_absorption_field(reshape(input%b1_kao_mn2, [19, 16]), reduced, output%ngn(1:10), output%rwgt(1:16))
      output%b1_ka_mn2 = reshape(reduced, shape(output%b1_ka_mn2))
    end block
    ! Band 1: KBO_MN2 -> KB_MN2.
    block
      real(c_double) :: reduced(19, 10)
      call reduce_absorption_field(reshape(input%b1_kbo_mn2, [19, 16]), reduced, output%ngn(1:10), output%rwgt(1:16))
      output%b1_kb_mn2 = reshape(reduced, shape(output%b1_kb_mn2))
    end block
    ! Band 1: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 10)
      call reduce_absorption_field(reshape(input%b1_selfrefo, [10, 16]), reduced, output%ngn(1:10), output%rwgt(1:16))
      output%b1_selfref = reshape(reduced, shape(output%b1_selfref))
    end block
    ! Band 1: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 10)
      call reduce_absorption_field(reshape(input%b1_forrefo, [4, 16]), reduced, output%ngn(1:10), output%rwgt(1:16))
      output%b1_forref = reshape(reduced, shape(output%b1_forref))
    end block
    ! Band 2: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(1, 12)
      call reduce_absorption_field(reshape(input%b2_fracrefao, [1, 16]), reduced, output%ngn(11:22))
      output%b2_fracrefa = reshape(reduced, shape(output%b2_fracrefa))
    end block
    ! Band 2: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(1, 12)
      call reduce_absorption_field(reshape(input%b2_fracrefbo, [1, 16]), reduced, output%ngn(11:22))
      output%b2_fracrefb = reshape(reduced, shape(output%b2_fracrefb))
    end block
    ! Band 2: KAO -> KA.
    block
      real(c_double) :: reduced(65, 12)
      call reduce_absorption_field(reshape(input%b2_kao, [65, 16]), reduced, output%ngn(11:22), output%rwgt(17:32))
      output%b2_ka = reshape(reduced, shape(output%b2_ka))
    end block
    ! Band 2: KBO -> KB.
    block
      real(c_double) :: reduced(235, 12)
      call reduce_absorption_field(reshape(input%b2_kbo, [235, 16]), reduced, output%ngn(11:22), output%rwgt(17:32))
      output%b2_kb = reshape(reduced, shape(output%b2_kb))
    end block
    ! Band 2: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 12)
      call reduce_absorption_field(reshape(input%b2_selfrefo, [10, 16]), reduced, output%ngn(11:22), output%rwgt(17:32))
      output%b2_selfref = reshape(reduced, shape(output%b2_selfref))
    end block
    ! Band 2: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 12)
      call reduce_absorption_field(reshape(input%b2_forrefo, [4, 16]), reduced, output%ngn(11:22), output%rwgt(17:32))
      output%b2_forref = reshape(reduced, shape(output%b2_forref))
    end block
    ! Band 3: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(9, 16)
      call reduce_absorption_field(transpose(input%b3_fracrefao), reduced, output%ngn(23:38))
      output%b3_fracrefa = reshape(transpose(reduced), shape(output%b3_fracrefa))
    end block
    ! Band 3: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(5, 16)
      call reduce_absorption_field(transpose(input%b3_fracrefbo), reduced, output%ngn(23:38))
      output%b3_fracrefb = reshape(transpose(reduced), shape(output%b3_fracrefb))
    end block
    ! Band 3: KAO_MN2O -> KA_MN2O.
    block
      real(c_double) :: reduced(171, 16)
      call reduce_absorption_field(reshape(input%b3_kao_mn2o, [171, 16]), reduced, output%ngn(23:38), output%rwgt(33:48))
      output%b3_ka_mn2o = reshape(reduced, shape(output%b3_ka_mn2o))
    end block
    ! Band 3: KBO_MN2O -> KB_MN2O.
    block
      real(c_double) :: reduced(95, 16)
      call reduce_absorption_field(reshape(input%b3_kbo_mn2o, [95, 16]), reduced, output%ngn(23:38), output%rwgt(33:48))
      output%b3_kb_mn2o = reshape(reduced, shape(output%b3_kb_mn2o))
    end block
    ! Band 3: KAO -> KA.
    block
      real(c_double) :: reduced(585, 16)
      call reduce_absorption_field(reshape(input%b3_kao, [585, 16]), reduced, output%ngn(23:38), output%rwgt(33:48))
      output%b3_ka = reshape(reduced, shape(output%b3_ka))
    end block
    ! Band 3: KBO -> KB.
    block
      real(c_double) :: reduced(1175, 16)
      call reduce_absorption_field(reshape(input%b3_kbo, [1175, 16]), reduced, output%ngn(23:38), output%rwgt(33:48))
      output%b3_kb = reshape(reduced, shape(output%b3_kb))
    end block
    ! Band 3: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 16)
      call reduce_absorption_field(reshape(input%b3_selfrefo, [10, 16]), reduced, output%ngn(23:38), output%rwgt(33:48))
      output%b3_selfref = reshape(reduced, shape(output%b3_selfref))
    end block
    ! Band 3: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 16)
      call reduce_absorption_field(reshape(input%b3_forrefo, [4, 16]), reduced, output%ngn(23:38), output%rwgt(33:48))
      output%b3_forref = reshape(reduced, shape(output%b3_forref))
    end block
    ! Band 4: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(9, 14)
      call reduce_absorption_field(transpose(input%b4_fracrefao), reduced, output%ngn(39:52))
      output%b4_fracrefa = reshape(transpose(reduced), shape(output%b4_fracrefa))
    end block
    ! Band 4: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(5, 14)
      call reduce_absorption_field(transpose(input%b4_fracrefbo), reduced, output%ngn(39:52))
      output%b4_fracrefb = reshape(transpose(reduced), shape(output%b4_fracrefb))
    end block
    ! Band 4: KAO -> KA.
    block
      real(c_double) :: reduced(585, 14)
      call reduce_absorption_field(reshape(input%b4_kao, [585, 16]), reduced, output%ngn(39:52), output%rwgt(49:64))
      output%b4_ka = reshape(reduced, shape(output%b4_ka))
    end block
    ! Band 4: KBO -> KB.
    block
      real(c_double) :: reduced(1175, 14)
      call reduce_absorption_field(reshape(input%b4_kbo, [1175, 16]), reduced, output%ngn(39:52), output%rwgt(49:64))
      output%b4_kb = reshape(reduced, shape(output%b4_kb))
    end block
    ! Band 4: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 14)
      call reduce_absorption_field(reshape(input%b4_selfrefo, [10, 16]), reduced, output%ngn(39:52), output%rwgt(49:64))
      output%b4_selfref = reshape(reduced, shape(output%b4_selfref))
    end block
    ! Band 4: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 14)
      call reduce_absorption_field(reshape(input%b4_forrefo, [4, 16]), reduced, output%ngn(39:52), output%rwgt(49:64))
      output%b4_forref = reshape(reduced, shape(output%b4_forref))
    end block
    ! Band 5: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(9, 16)
      call reduce_absorption_field(transpose(input%b5_fracrefao), reduced, output%ngn(53:68))
      output%b5_fracrefa = reshape(transpose(reduced), shape(output%b5_fracrefa))
    end block
    ! Band 5: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(5, 16)
      call reduce_absorption_field(transpose(input%b5_fracrefbo), reduced, output%ngn(53:68))
      output%b5_fracrefb = reshape(transpose(reduced), shape(output%b5_fracrefb))
    end block
    ! Band 5: CCL4O -> CCL4.
    block
      real(c_double) :: reduced(1, 16)
      call reduce_absorption_field(reshape(input%b5_ccl4o, [1, 16]), reduced, output%ngn(53:68), output%rwgt(65:80))
      output%b5_ccl4 = reshape(reduced, shape(output%b5_ccl4))
    end block
    ! Band 5: KAO -> KA.
    block
      real(c_double) :: reduced(585, 16)
      call reduce_absorption_field(reshape(input%b5_kao, [585, 16]), reduced, output%ngn(53:68), output%rwgt(65:80))
      output%b5_ka = reshape(reduced, shape(output%b5_ka))
    end block
    ! Band 5: KBO -> KB.
    block
      real(c_double) :: reduced(1175, 16)
      call reduce_absorption_field(reshape(input%b5_kbo, [1175, 16]), reduced, output%ngn(53:68), output%rwgt(65:80))
      output%b5_kb = reshape(reduced, shape(output%b5_kb))
    end block
    ! Band 5: KAO_MO3 -> KA_MO3.
    block
      real(c_double) :: reduced(171, 16)
      call reduce_absorption_field(reshape(input%b5_kao_mo3, [171, 16]), reduced, output%ngn(53:68), output%rwgt(65:80))
      output%b5_ka_mo3 = reshape(reduced, shape(output%b5_ka_mo3))
    end block
    ! Band 5: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 16)
      call reduce_absorption_field(reshape(input%b5_selfrefo, [10, 16]), reduced, output%ngn(53:68), output%rwgt(65:80))
      output%b5_selfref = reshape(reduced, shape(output%b5_selfref))
    end block
    ! Band 5: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 16)
      call reduce_absorption_field(reshape(input%b5_forrefo, [4, 16]), reduced, output%ngn(53:68), output%rwgt(65:80))
      output%b5_forref = reshape(reduced, shape(output%b5_forref))
    end block
    ! Band 6: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(1, 8)
      call reduce_absorption_field(reshape(input%b6_fracrefao, [1, 16]), reduced, output%ngn(69:76))
      output%b6_fracrefa = reshape(reduced, shape(output%b6_fracrefa))
    end block
    ! Band 6: CFC11ADJO -> CFC11ADJ.
    block
      real(c_double) :: reduced(1, 8)
      call reduce_absorption_field(reshape(input%b6_cfc11adjo, [1, 16]), reduced, output%ngn(69:76), output%rwgt(81:96))
      output%b6_cfc11adj = reshape(reduced, shape(output%b6_cfc11adj))
    end block
    ! Band 6: CFC12O -> CFC12.
    block
      real(c_double) :: reduced(1, 8)
      call reduce_absorption_field(reshape(input%b6_cfc12o, [1, 16]), reduced, output%ngn(69:76), output%rwgt(81:96))
      output%b6_cfc12 = reshape(reduced, shape(output%b6_cfc12))
    end block
    ! Band 6: KAO -> KA.
    block
      real(c_double) :: reduced(65, 8)
      call reduce_absorption_field(reshape(input%b6_kao, [65, 16]), reduced, output%ngn(69:76), output%rwgt(81:96))
      output%b6_ka = reshape(reduced, shape(output%b6_ka))
    end block
    ! Band 6: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 8)
      call reduce_absorption_field(reshape(input%b6_selfrefo, [10, 16]), reduced, output%ngn(69:76), output%rwgt(81:96))
      output%b6_selfref = reshape(reduced, shape(output%b6_selfref))
    end block
    ! Band 6: KAO_MCO2 -> KA_MCO2.
    block
      real(c_double) :: reduced(19, 8)
      call reduce_absorption_field(reshape(input%b6_kao_mco2, [19, 16]), reduced, output%ngn(69:76), output%rwgt(81:96))
      output%b6_ka_mco2 = reshape(reduced, shape(output%b6_ka_mco2))
    end block
    ! Band 6: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 8)
      call reduce_absorption_field(reshape(input%b6_forrefo, [4, 16]), reduced, output%ngn(69:76), output%rwgt(81:96))
      output%b6_forref = reshape(reduced, shape(output%b6_forref))
    end block
    ! Band 7: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(9, 12)
      call reduce_absorption_field(transpose(input%b7_fracrefao), reduced, output%ngn(77:88))
      output%b7_fracrefa = reshape(transpose(reduced), shape(output%b7_fracrefa))
    end block
    ! Band 7: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(1, 12)
      call reduce_absorption_field(reshape(input%b7_fracrefbo, [1, 16]), reduced, output%ngn(77:88))
      output%b7_fracrefb = reshape(reduced, shape(output%b7_fracrefb))
    end block
    ! Band 7: KAO -> KA.
    block
      real(c_double) :: reduced(585, 12)
      call reduce_absorption_field(reshape(input%b7_kao, [585, 16]), reduced, output%ngn(77:88), output%rwgt(97:112))
      output%b7_ka = reshape(reduced, shape(output%b7_ka))
    end block
    ! Band 7: KBO -> KB.
    block
      real(c_double) :: reduced(235, 12)
      call reduce_absorption_field(reshape(input%b7_kbo, [235, 16]), reduced, output%ngn(77:88), output%rwgt(97:112))
      output%b7_kb = reshape(reduced, shape(output%b7_kb))
    end block
    ! Band 7: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 12)
      call reduce_absorption_field(reshape(input%b7_selfrefo, [10, 16]), reduced, output%ngn(77:88), output%rwgt(97:112))
      output%b7_selfref = reshape(reduced, shape(output%b7_selfref))
    end block
    ! Band 7: KAO_MCO2 -> KA_MCO2.
    block
      real(c_double) :: reduced(171, 12)
      call reduce_absorption_field(reshape(input%b7_kao_mco2, [171, 16]), reduced, output%ngn(77:88), output%rwgt(97:112))
      output%b7_ka_mco2 = reshape(reduced, shape(output%b7_ka_mco2))
    end block
    ! Band 7: KBO_MCO2 -> KB_MCO2.
    block
      real(c_double) :: reduced(19, 12)
      call reduce_absorption_field(reshape(input%b7_kbo_mco2, [19, 16]), reduced, output%ngn(77:88), output%rwgt(97:112))
      output%b7_kb_mco2 = reshape(reduced, shape(output%b7_kb_mco2))
    end block
    ! Band 7: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 12)
      call reduce_absorption_field(reshape(input%b7_forrefo, [4, 16]), reduced, output%ngn(77:88), output%rwgt(97:112))
      output%b7_forref = reshape(reduced, shape(output%b7_forref))
    end block
    ! Band 8: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(1, 8)
      call reduce_absorption_field(reshape(input%b8_fracrefao, [1, 16]), reduced, output%ngn(89:96))
      output%b8_fracrefa = reshape(reduced, shape(output%b8_fracrefa))
    end block
    ! Band 8: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(1, 8)
      call reduce_absorption_field(reshape(input%b8_fracrefbo, [1, 16]), reduced, output%ngn(89:96))
      output%b8_fracrefb = reshape(reduced, shape(output%b8_fracrefb))
    end block
    ! Band 8: CFC12O -> CFC12.
    block
      real(c_double) :: reduced(1, 8)
      call reduce_absorption_field(reshape(input%b8_cfc12o, [1, 16]), reduced, output%ngn(89:96), output%rwgt(113:128))
      output%b8_cfc12 = reshape(reduced, shape(output%b8_cfc12))
    end block
    ! Band 8: CFC22ADJO -> CFC22ADJ.
    block
      real(c_double) :: reduced(1, 8)
      call reduce_absorption_field(reshape(input%b8_cfc22adjo, [1, 16]), reduced, output%ngn(89:96), output%rwgt(113:128))
      output%b8_cfc22adj = reshape(reduced, shape(output%b8_cfc22adj))
    end block
    ! Band 8: KAO -> KA.
    block
      real(c_double) :: reduced(65, 8)
      call reduce_absorption_field(reshape(input%b8_kao, [65, 16]), reduced, output%ngn(89:96), output%rwgt(113:128))
      output%b8_ka = reshape(reduced, shape(output%b8_ka))
    end block
    ! Band 8: KBO -> KB.
    block
      real(c_double) :: reduced(235, 8)
      call reduce_absorption_field(reshape(input%b8_kbo, [235, 16]), reduced, output%ngn(89:96), output%rwgt(113:128))
      output%b8_kb = reshape(reduced, shape(output%b8_kb))
    end block
    ! Band 8: KAO_MCO2 -> KA_MCO2.
    block
      real(c_double) :: reduced(19, 8)
      call reduce_absorption_field(reshape(input%b8_kao_mco2, [19, 16]), reduced, output%ngn(89:96), output%rwgt(113:128))
      output%b8_ka_mco2 = reshape(reduced, shape(output%b8_ka_mco2))
    end block
    ! Band 8: KAO_MN2O -> KA_MN2O.
    block
      real(c_double) :: reduced(19, 8)
      call reduce_absorption_field(reshape(input%b8_kao_mn2o, [19, 16]), reduced, output%ngn(89:96), output%rwgt(113:128))
      output%b8_ka_mn2o = reshape(reduced, shape(output%b8_ka_mn2o))
    end block
    ! Band 8: KAO_MO3 -> KA_MO3.
    block
      real(c_double) :: reduced(19, 8)
      call reduce_absorption_field(reshape(input%b8_kao_mo3, [19, 16]), reduced, output%ngn(89:96), output%rwgt(113:128))
      output%b8_ka_mo3 = reshape(reduced, shape(output%b8_ka_mo3))
    end block
    ! Band 8: KBO_MCO2 -> KB_MCO2.
    block
      real(c_double) :: reduced(19, 8)
      call reduce_absorption_field(reshape(input%b8_kbo_mco2, [19, 16]), reduced, output%ngn(89:96), output%rwgt(113:128))
      output%b8_kb_mco2 = reshape(reduced, shape(output%b8_kb_mco2))
    end block
    ! Band 8: KBO_MN2O -> KB_MN2O.
    block
      real(c_double) :: reduced(19, 8)
      call reduce_absorption_field(reshape(input%b8_kbo_mn2o, [19, 16]), reduced, output%ngn(89:96), output%rwgt(113:128))
      output%b8_kb_mn2o = reshape(reduced, shape(output%b8_kb_mn2o))
    end block
    ! Band 8: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 8)
      call reduce_absorption_field(reshape(input%b8_selfrefo, [10, 16]), reduced, output%ngn(89:96), output%rwgt(113:128))
      output%b8_selfref = reshape(reduced, shape(output%b8_selfref))
    end block
    ! Band 8: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 8)
      call reduce_absorption_field(reshape(input%b8_forrefo, [4, 16]), reduced, output%ngn(89:96), output%rwgt(113:128))
      output%b8_forref = reshape(reduced, shape(output%b8_forref))
    end block
    ! Band 9: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(9, 12)
      call reduce_absorption_field(transpose(input%b9_fracrefao), reduced, output%ngn(97:108))
      output%b9_fracrefa = reshape(transpose(reduced), shape(output%b9_fracrefa))
    end block
    ! Band 9: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(1, 12)
      call reduce_absorption_field(reshape(input%b9_fracrefbo, [1, 16]), reduced, output%ngn(97:108))
      output%b9_fracrefb = reshape(reduced, shape(output%b9_fracrefb))
    end block
    ! Band 9: KAO -> KA.
    block
      real(c_double) :: reduced(585, 12)
      call reduce_absorption_field(reshape(input%b9_kao, [585, 16]), reduced, output%ngn(97:108), output%rwgt(129:144))
      output%b9_ka = reshape(reduced, shape(output%b9_ka))
    end block
    ! Band 9: KBO -> KB.
    block
      real(c_double) :: reduced(235, 12)
      call reduce_absorption_field(reshape(input%b9_kbo, [235, 16]), reduced, output%ngn(97:108), output%rwgt(129:144))
      output%b9_kb = reshape(reduced, shape(output%b9_kb))
    end block
    ! Band 9: KAO_MN2O -> KA_MN2O.
    block
      real(c_double) :: reduced(171, 12)
      call reduce_absorption_field(reshape(input%b9_kao_mn2o, [171, 16]), reduced, output%ngn(97:108), output%rwgt(129:144))
      output%b9_ka_mn2o = reshape(reduced, shape(output%b9_ka_mn2o))
    end block
    ! Band 9: KBO_MN2O -> KB_MN2O.
    block
      real(c_double) :: reduced(19, 12)
      call reduce_absorption_field(reshape(input%b9_kbo_mn2o, [19, 16]), reduced, output%ngn(97:108), output%rwgt(129:144))
      output%b9_kb_mn2o = reshape(reduced, shape(output%b9_kb_mn2o))
    end block
    ! Band 9: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 12)
      call reduce_absorption_field(reshape(input%b9_selfrefo, [10, 16]), reduced, output%ngn(97:108), output%rwgt(129:144))
      output%b9_selfref = reshape(reduced, shape(output%b9_selfref))
    end block
    ! Band 9: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 12)
      call reduce_absorption_field(reshape(input%b9_forrefo, [4, 16]), reduced, output%ngn(97:108), output%rwgt(129:144))
      output%b9_forref = reshape(reduced, shape(output%b9_forref))
    end block
    ! Band 10: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(1, 6)
      call reduce_absorption_field(reshape(input%b10_fracrefao, [1, 16]), reduced, output%ngn(109:114))
      output%b10_fracrefa = reshape(reduced, shape(output%b10_fracrefa))
    end block
    ! Band 10: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(1, 6)
      call reduce_absorption_field(reshape(input%b10_fracrefbo, [1, 16]), reduced, output%ngn(109:114))
      output%b10_fracrefb = reshape(reduced, shape(output%b10_fracrefb))
    end block
    ! Band 10: KAO -> KA.
    block
      real(c_double) :: reduced(65, 6)
      call reduce_absorption_field(reshape(input%b10_kao, [65, 16]), reduced, output%ngn(109:114), output%rwgt(145:160))
      output%b10_ka = reshape(reduced, shape(output%b10_ka))
    end block
    ! Band 10: KBO -> KB.
    block
      real(c_double) :: reduced(235, 6)
      call reduce_absorption_field(reshape(input%b10_kbo, [235, 16]), reduced, output%ngn(109:114), output%rwgt(145:160))
      output%b10_kb = reshape(reduced, shape(output%b10_kb))
    end block
    ! Band 10: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 6)
      call reduce_absorption_field(reshape(input%b10_selfrefo, [10, 16]), reduced, output%ngn(109:114), output%rwgt(145:160))
      output%b10_selfref = reshape(reduced, shape(output%b10_selfref))
    end block
    ! Band 10: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 6)
      call reduce_absorption_field(reshape(input%b10_forrefo, [4, 16]), reduced, output%ngn(109:114), output%rwgt(145:160))
      output%b10_forref = reshape(reduced, shape(output%b10_forref))
    end block
    ! Band 11: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(1, 8)
      call reduce_absorption_field(reshape(input%b11_fracrefao, [1, 16]), reduced, output%ngn(115:122))
      output%b11_fracrefa = reshape(reduced, shape(output%b11_fracrefa))
    end block
    ! Band 11: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(1, 8)
      call reduce_absorption_field(reshape(input%b11_fracrefbo, [1, 16]), reduced, output%ngn(115:122))
      output%b11_fracrefb = reshape(reduced, shape(output%b11_fracrefb))
    end block
    ! Band 11: KAO -> KA.
    block
      real(c_double) :: reduced(65, 8)
      call reduce_absorption_field(reshape(input%b11_kao, [65, 16]), reduced, output%ngn(115:122), output%rwgt(161:176))
      output%b11_ka = reshape(reduced, shape(output%b11_ka))
    end block
    ! Band 11: KBO -> KB.
    block
      real(c_double) :: reduced(235, 8)
      call reduce_absorption_field(reshape(input%b11_kbo, [235, 16]), reduced, output%ngn(115:122), output%rwgt(161:176))
      output%b11_kb = reshape(reduced, shape(output%b11_kb))
    end block
    ! Band 11: KAO_MO2 -> KA_MO2.
    block
      real(c_double) :: reduced(19, 8)
      call reduce_absorption_field(reshape(input%b11_kao_mo2, [19, 16]), reduced, output%ngn(115:122), output%rwgt(161:176))
      output%b11_ka_mo2 = reshape(reduced, shape(output%b11_ka_mo2))
    end block
    ! Band 11: KBO_MO2 -> KB_MO2.
    block
      real(c_double) :: reduced(19, 8)
      call reduce_absorption_field(reshape(input%b11_kbo_mo2, [19, 16]), reduced, output%ngn(115:122), output%rwgt(161:176))
      output%b11_kb_mo2 = reshape(reduced, shape(output%b11_kb_mo2))
    end block
    ! Band 11: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 8)
      call reduce_absorption_field(reshape(input%b11_selfrefo, [10, 16]), reduced, output%ngn(115:122), output%rwgt(161:176))
      output%b11_selfref = reshape(reduced, shape(output%b11_selfref))
    end block
    ! Band 11: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 8)
      call reduce_absorption_field(reshape(input%b11_forrefo, [4, 16]), reduced, output%ngn(115:122), output%rwgt(161:176))
      output%b11_forref = reshape(reduced, shape(output%b11_forref))
    end block
    ! Band 12: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(9, 8)
      call reduce_absorption_field(transpose(input%b12_fracrefao), reduced, output%ngn(123:130))
      output%b12_fracrefa = reshape(transpose(reduced), shape(output%b12_fracrefa))
    end block
    ! Band 12: KAO -> KA.
    block
      real(c_double) :: reduced(585, 8)
      call reduce_absorption_field(reshape(input%b12_kao, [585, 16]), reduced, output%ngn(123:130), output%rwgt(177:192))
      output%b12_ka = reshape(reduced, shape(output%b12_ka))
    end block
    ! Band 12: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 8)
      call reduce_absorption_field(reshape(input%b12_selfrefo, [10, 16]), reduced, output%ngn(123:130), output%rwgt(177:192))
      output%b12_selfref = reshape(reduced, shape(output%b12_selfref))
    end block
    ! Band 12: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 8)
      call reduce_absorption_field(reshape(input%b12_forrefo, [4, 16]), reduced, output%ngn(123:130), output%rwgt(177:192))
      output%b12_forref = reshape(reduced, shape(output%b12_forref))
    end block
    ! Band 13: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(9, 4)
      call reduce_absorption_field(transpose(input%b13_fracrefao), reduced, output%ngn(131:134))
      output%b13_fracrefa = reshape(transpose(reduced), shape(output%b13_fracrefa))
    end block
    ! Band 13: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(1, 4)
      call reduce_absorption_field(reshape(input%b13_fracrefbo, [1, 16]), reduced, output%ngn(131:134))
      output%b13_fracrefb = reshape(reduced, shape(output%b13_fracrefb))
    end block
    ! Band 13: KAO -> KA.
    block
      real(c_double) :: reduced(585, 4)
      call reduce_absorption_field(reshape(input%b13_kao, [585, 16]), reduced, output%ngn(131:134), output%rwgt(193:208))
      output%b13_ka = reshape(reduced, shape(output%b13_ka))
    end block
    ! Band 13: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 4)
      call reduce_absorption_field(reshape(input%b13_selfrefo, [10, 16]), reduced, output%ngn(131:134), output%rwgt(193:208))
      output%b13_selfref = reshape(reduced, shape(output%b13_selfref))
    end block
    ! Band 13: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 4)
      call reduce_absorption_field(reshape(input%b13_forrefo, [4, 16]), reduced, output%ngn(131:134), output%rwgt(193:208))
      output%b13_forref = reshape(reduced, shape(output%b13_forref))
    end block
    ! Band 13: KAO_MCO2 -> KA_MCO2.
    block
      real(c_double) :: reduced(171, 4)
      call reduce_absorption_field(reshape(input%b13_kao_mco2, [171, 16]), reduced, output%ngn(131:134), output%rwgt(193:208))
      output%b13_ka_mco2 = reshape(reduced, shape(output%b13_ka_mco2))
    end block
    ! Band 13: KAO_MCO -> KA_MCO.
    block
      real(c_double) :: reduced(171, 4)
      call reduce_absorption_field(reshape(input%b13_kao_mco, [171, 16]), reduced, output%ngn(131:134), output%rwgt(193:208))
      output%b13_ka_mco = reshape(reduced, shape(output%b13_ka_mco))
    end block
    ! Band 13: KBO_MO3 -> KB_MO3.
    block
      real(c_double) :: reduced(19, 4)
      call reduce_absorption_field(reshape(input%b13_kbo_mo3, [19, 16]), reduced, output%ngn(131:134), output%rwgt(193:208))
      output%b13_kb_mo3 = reshape(reduced, shape(output%b13_kb_mo3))
    end block
    ! Band 14: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(1, 2)
      call reduce_absorption_field(reshape(input%b14_fracrefao, [1, 16]), reduced, output%ngn(135:136))
      output%b14_fracrefa = reshape(reduced, shape(output%b14_fracrefa))
    end block
    ! Band 14: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(1, 2)
      call reduce_absorption_field(reshape(input%b14_fracrefbo, [1, 16]), reduced, output%ngn(135:136))
      output%b14_fracrefb = reshape(reduced, shape(output%b14_fracrefb))
    end block
    ! Band 14: KAO -> KA.
    block
      real(c_double) :: reduced(65, 2)
      call reduce_absorption_field(reshape(input%b14_kao, [65, 16]), reduced, output%ngn(135:136), output%rwgt(209:224))
      output%b14_ka = reshape(reduced, shape(output%b14_ka))
    end block
    ! Band 14: KBO -> KB.
    block
      real(c_double) :: reduced(235, 2)
      call reduce_absorption_field(reshape(input%b14_kbo, [235, 16]), reduced, output%ngn(135:136), output%rwgt(209:224))
      output%b14_kb = reshape(reduced, shape(output%b14_kb))
    end block
    ! Band 14: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 2)
      call reduce_absorption_field(reshape(input%b14_selfrefo, [10, 16]), reduced, output%ngn(135:136), output%rwgt(209:224))
      output%b14_selfref = reshape(reduced, shape(output%b14_selfref))
    end block
    ! Band 14: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 2)
      call reduce_absorption_field(reshape(input%b14_forrefo, [4, 16]), reduced, output%ngn(135:136), output%rwgt(209:224))
      output%b14_forref = reshape(reduced, shape(output%b14_forref))
    end block
    ! Band 15: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(9, 2)
      call reduce_absorption_field(transpose(input%b15_fracrefao), reduced, output%ngn(137:138))
      output%b15_fracrefa = reshape(transpose(reduced), shape(output%b15_fracrefa))
    end block
    ! Band 15: KAO -> KA.
    block
      real(c_double) :: reduced(585, 2)
      call reduce_absorption_field(reshape(input%b15_kao, [585, 16]), reduced, output%ngn(137:138), output%rwgt(225:240))
      output%b15_ka = reshape(reduced, shape(output%b15_ka))
    end block
    ! Band 15: KAO_MN2 -> KA_MN2.
    block
      real(c_double) :: reduced(171, 2)
      call reduce_absorption_field(reshape(input%b15_kao_mn2, [171, 16]), reduced, output%ngn(137:138), output%rwgt(225:240))
      output%b15_ka_mn2 = reshape(reduced, shape(output%b15_ka_mn2))
    end block
    ! Band 15: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 2)
      call reduce_absorption_field(reshape(input%b15_selfrefo, [10, 16]), reduced, output%ngn(137:138), output%rwgt(225:240))
      output%b15_selfref = reshape(reduced, shape(output%b15_selfref))
    end block
    ! Band 15: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 2)
      call reduce_absorption_field(reshape(input%b15_forrefo, [4, 16]), reduced, output%ngn(137:138), output%rwgt(225:240))
      output%b15_forref = reshape(reduced, shape(output%b15_forref))
    end block
    ! Band 16: FRACREFAO -> FRACREFA.
    block
      real(c_double) :: reduced(9, 2)
      call reduce_absorption_field(transpose(input%b16_fracrefao), reduced, output%ngn(139:140))
      output%b16_fracrefa = reshape(transpose(reduced), shape(output%b16_fracrefa))
    end block
    ! Band 16: FRACREFBO -> FRACREFB.
    block
      real(c_double) :: reduced(1, 2)
      call reduce_absorption_field(reshape(input%b16_fracrefbo, [1, 16]), reduced, output%ngn(139:140))
      output%b16_fracrefb = reshape(reduced, shape(output%b16_fracrefb))
    end block
    ! Band 16: KAO -> KA.
    block
      real(c_double) :: reduced(585, 2)
      call reduce_absorption_field(reshape(input%b16_kao, [585, 16]), reduced, output%ngn(139:140), output%rwgt(241:256))
      output%b16_ka = reshape(reduced, shape(output%b16_ka))
    end block
    ! Band 16: KBO -> KB.
    block
      real(c_double) :: reduced(235, 2)
      call reduce_absorption_field(reshape(input%b16_kbo, [235, 16]), reduced, output%ngn(139:140), output%rwgt(241:256))
      output%b16_kb = reshape(reduced, shape(output%b16_kb))
    end block
    ! Band 16: SELFREFO -> SELFREF.
    block
      real(c_double) :: reduced(10, 2)
      call reduce_absorption_field(reshape(input%b16_selfrefo, [10, 16]), reduced, output%ngn(139:140), output%rwgt(241:256))
      output%b16_selfref = reshape(reduced, shape(output%b16_selfref))
    end block
    ! Band 16: FORREFO -> FORREF.
    block
      real(c_double) :: reduced(4, 2)
      call reduce_absorption_field(reshape(input%b16_forrefo, [4, 16]), reduced, output%ngn(139:140), output%rwgt(241:256))
      output%b16_forref = reshape(reduced, shape(output%b16_forref))
    end block
    ! The source leaves b12_strrat and all declared common tails unchanged.
    status = 0_c_int
  end function reduce_longwave_absorption

  !> Construct the correction and relative-weight tables in source order.
  !! output is mutated only in corr1(0:200), corr2(0:200), and rwgt(1:256).
  !! All three arrays and the controlling weights and maps are dimensionless.
  subroutine longwave_corrections_and_weights(output)
    type(longwave_absorption_reduced_record), intent(inout) :: output
    integer :: index, band, group, sample, first_sample, last_sample, group_index, weight_index
    real(c_double) :: scaled_index, root, one_minus_root, one_minus_index, total
    output%corr1(0) = 1.0_c_double
    output%corr2(0) = 1.0_c_double
    output%corr1(200) = 1.0_c_double
    output%corr2(200) = 1.0_c_double
    do index = 1, 199
      scaled_index = 0.005_c_double*real(index, c_double)
      root = sqrt(scaled_index)
      output%corr1(index) = root/scaled_index
      one_minus_root = 1.0_c_double - root
      one_minus_index = 1.0_c_double - scaled_index
      output%corr2(index) = one_minus_root/one_minus_index
    end do
    group_index = 1
    weight_index = 1
    do band = 1, 16
      if (output%ngc(band) == 16_c_int) then
        do sample = 1, 16
          output%rwgt(weight_index) = 1.0_c_double
          weight_index = weight_index + 1
        end do
        group_index = group_index + 16
      else
        first_sample = 1
        do group = 1, output%ngc(band)
          last_sample = first_sample + output%ngn(group_index) - 1
          total = 0.0_c_double
          do sample = first_sample, last_sample
            total = total + output%wt(sample)
          end do
          do sample = first_sample, last_sample
            output%rwgt(weight_index) = output%wt(sample)/total
            weight_index = weight_index + 1
          end do
          first_sample = last_sample + 1
          group_index = group_index + 1
        end do
      end if
    end do
  end subroutine longwave_corrections_and_weights

  !> C boundary for complete canonical records and their explicit capacities.
  !! Inputs are pointer, byte capacity, output pointer and output byte capacity.
  !! Both records are mapped, eight-byte aligned and disjoint. Return 1 refuses
  !! an invalid boundary before mutation; return 0 completes all defined fields.
  integer(c_int) function md2asm_reduce_longwave_absorption_fortran(input_pointer, input_capacity, &
                           output_pointer, output_capacity) bind(C, name="md2asm_reduce_longwave_absorption_fortran") result(status)
    type(c_ptr), value :: input_pointer, output_pointer
    integer(c_size_t), value :: input_capacity, output_capacity
    type(longwave_absorption_input_record), pointer :: input
    type(longwave_absorption_reduced_record), pointer :: output
    type(longwave_absorption_input_record) :: input_size_mold
    type(longwave_absorption_reduced_record) :: output_size_mold
    integer(c_intptr_t) :: input_first, input_last, output_first, output_last, input_bytes, output_bytes
    status = 1_c_int
    input_bytes = int(c_sizeof(input_size_mold), c_intptr_t)
    output_bytes = int(c_sizeof(output_size_mold), c_intptr_t)
    if (input_capacity < input_bytes .or. output_capacity < output_bytes) return
    if (.not. complete_record_span(input_pointer, input_bytes, input_first, input_last)) return
    if (.not. complete_record_span(output_pointer, output_bytes, output_first, output_last)) return
    if (input_first < output_last .and. output_first < input_last) return
    call c_f_pointer(input_pointer, input)
    call c_f_pointer(output_pointer, output)
    status = reduce_longwave_absorption(input, output)
  end function md2asm_reduce_longwave_absorption_fortran

  logical function complete_record_span(pointer, bytes, first, last) result(valid)
    type(c_ptr), value :: pointer
    integer(c_intptr_t), intent(in) :: bytes
    integer(c_intptr_t), intent(out) :: first, last
    valid = .false.
    first = transfer(pointer, first)
    last = first
    if (.not. c_associated(pointer)) return
    if (first < 0_c_intptr_t .or. mod(first, 8_c_intptr_t) /= 0_c_intptr_t) return
    if (first > huge(first) - bytes) return
    last = first + bytes
    valid = .true.
  end function complete_record_span
end module native_longwave_absorption_reduction

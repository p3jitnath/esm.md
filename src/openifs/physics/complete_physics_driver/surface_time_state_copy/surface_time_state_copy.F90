!> Copy complete source surface time views in their recorded field order.
!! The caller owns every target. Copies preserve raw64 words, including signed
!! zero and NaN payloads, with no floating arithmetic, scratch or allocation.
module forecast_surface_time_state_copy
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_intptr_t, c_loc
  use forecast_physics_work_types, only: SURF_AND_MORE_TYPE
  implicit none
  private
  public :: surface_time_copy_context, surface_time_state_copy, surface_time_state_copy_recorded
  public :: get_surface_time_copy_context
  !> Caller-owned diagnostic state replaces the original private saved address.
  !! OBJECT borrows the actual surface record; its target lifetime stays with
  !! the caller. SEQUENCE preserves every bit of the source modulo2**64 count.
  type :: surface_time_copy_context
    type(SURF_AND_MORE_TYPE), pointer :: object => null()
    integer(int32) :: mode = 0_int32
    integer(int64) :: sequence = 0_int64
  end type
  ! Typed local descriptors borrow views; no numerical owner is stored here.
  type :: surface_copy_pair
    integer :: rank = 0
    real(real64), pointer :: destination1(:) => null(), source1(:) => null()
    real(real64), pointer :: destination2(:, :) => null(), source2(:, :) => null()
    integer(c_intptr_t) :: destination_low = 0_c_intptr_t, destination_high = -1_c_intptr_t
    integer(c_intptr_t) :: source_low = 0_c_intptr_t, source_high = -1_c_intptr_t
    logical :: identity = .false.
  end type
contains
  !> Record the actual object/mode, increment its count, then execute the body.
  !! This is the source compatibility entry. Metadata is captured on every
  !! attempt before body admission, as in the original wrapper. Status0 means
  !! complete copy; status2 refuses native metadata before numerical stores.
  integer(int32) function surface_time_state_copy(surface, mode, context) result(status)
    type(SURF_AND_MORE_TYPE), target, intent(inout) :: surface
    integer(int32), intent(in) :: mode
    type(surface_time_copy_context), intent(inout) :: context
    context%object => surface
    context%mode = mode
    if (context%sequence == huge(context%sequence)) then
      context%sequence = -huge(context%sequence) - 1_int64
    else
      context%sequence = context%sequence + 1_int64
    end if
    status = surface_time_state_copy_recorded(surface, mode)
  end function surface_time_state_copy

  !> Run the complete recorded body over actual canonical surface views.
  !! Mode1 copies T9 to T1; mode2 copies T1 to T0; every other INT32 value
  !! copies T0 to T1. These are the exact source directions, not method names.
  !! Active flags are actual native variable metadata. Inactive views are not
  !! consumed. Live extents set every bound; native dense owners may be empty.
  !! Readonly and mutable complete spans are checked before the first store.
  integer(int32) function surface_time_state_copy_recorded(surface, mode) result(status)
    type(SURF_AND_MORE_TYPE), intent(inout) :: surface
    integer(int32), intent(in) :: mode
    type(surface_copy_pair) :: pairs(30)
    integer :: j, k
    status = 2_int32
    if (.not. associated(surface%GSP_SB%VARIABLE_GROUP)) return
    if (.not. associated(surface%GSP_SG%VARIABLE_GROUP)) return
    if (.not. associated(surface%GSP_SL%VARIABLE_GROUP)) return
    if (.not. associated(surface%GSP_RR%VARIABLE_GROUP)) return
    if (.not. associated(surface%GSP_CL%VARIABLE_GROUP)) return
    if (.not. associated(surface%GSP_OM%VARIABLE_GROUP)) return
    if (surface%GSP_SB%VARIABLE_GROUP%GSP_SB%vt%lactive) &
      call bind_pair_2(pairs(1), surface%GSP_SB%PT_T0, &
                       surface%GSP_SB%PT_T1, surface%GSP_SB%PT_T9, mode)
    if (surface%GSP_SB%VARIABLE_GROUP%GSP_SB%vq%lactive) &
      call bind_pair_2(pairs(2), surface%GSP_SB%PQ_T0, &
                       surface%GSP_SB%PQ_T1, surface%GSP_SB%PQ_T9, mode)
    if (surface%GSP_SB%VARIABLE_GROUP%GSP_SB%vtl%lactive) &
      call bind_pair_2(pairs(3), surface%GSP_SB%PTL_T0, &
                       surface%GSP_SB%PTL_T1, surface%GSP_SB%PTL_T9, mode)
    if (surface%GSP_SG%VARIABLE_GROUP%GSP_SG%vf%lactive) &
      call bind_pair_2(pairs(4), surface%GSP_SG%PF_T0, &
                       surface%GSP_SG%PF_T1, surface%GSP_SG%PF_T9, mode)
    if (surface%GSP_SG%VARIABLE_GROUP%GSP_SG%va%lactive) &
      call bind_pair_2(pairs(5), surface%GSP_SG%PA_T0, &
                       surface%GSP_SG%PA_T1, surface%GSP_SG%PA_T9, mode)
    if (surface%GSP_SG%VARIABLE_GROUP%GSP_SG%vr%lactive) &
      call bind_pair_2(pairs(6), surface%GSP_SG%PR_T0, &
                       surface%GSP_SG%PR_T1, surface%GSP_SG%PR_T9, mode)
    if (surface%GSP_SG%VARIABLE_GROUP%GSP_SG%vt%lactive) &
      call bind_pair_2(pairs(7), surface%GSP_SG%PT_T0, &
                       surface%GSP_SG%PT_T1, surface%GSP_SG%PT_T9, mode)
    if (surface%GSP_SG%VARIABLE_GROUP%GSP_SG%vw%lactive) &
      call bind_pair_2(pairs(8), surface%GSP_SG%PW_T0, &
                       surface%GSP_SG%PW_T1, surface%GSP_SG%PW_T9, mode)
    if (surface%GSP_SL%VARIABLE_GROUP%GSP_SL%vlict%lactive) &
      call bind_pair_1(pairs(9), surface%GSP_SL%PLICT_T0, &
                       surface%GSP_SL%PLICT_T1, surface%GSP_SL%PLICT_T9, mode)
    if (surface%GSP_SL%VARIABLE_GROUP%GSP_SL%vlmlt%lactive) &
      call bind_pair_1(pairs(10), surface%GSP_SL%PLMLT_T0, &
                       surface%GSP_SL%PLMLT_T1, surface%GSP_SL%PLMLT_T9, mode)
    if (surface%GSP_SL%VARIABLE_GROUP%GSP_SL%vltlt%lactive) &
      call bind_pair_1(pairs(11), surface%GSP_SL%PLTLT_T0, &
                       surface%GSP_SL%PLTLT_T1, surface%GSP_SL%PLTLT_T9, mode)
    if (surface%GSP_SL%VARIABLE_GROUP%GSP_SL%vlblt%lactive) &
      call bind_pair_1(pairs(12), surface%GSP_SL%PLBLT_T0, &
                       surface%GSP_SL%PLBLT_T1, surface%GSP_SL%PLBLT_T9, mode)
    if (surface%GSP_SL%VARIABLE_GROUP%GSP_SL%vlshf%lactive) &
      call bind_pair_1(pairs(13), surface%GSP_SL%PLSHF_T0, &
                       surface%GSP_SL%PLSHF_T1, surface%GSP_SL%PLSHF_T9, mode)
    if (surface%GSP_SL%VARIABLE_GROUP%GSP_SL%vlicd%lactive) &
      call bind_pair_1(pairs(14), surface%GSP_SL%PLICD_T0, &
                       surface%GSP_SL%PLICD_T1, surface%GSP_SL%PLICD_T9, mode)
    if (surface%GSP_SL%VARIABLE_GROUP%GSP_SL%vlmld%lactive) &
      call bind_pair_1(pairs(15), surface%GSP_SL%PLMLD_T0, &
                       surface%GSP_SL%PLMLD_T1, surface%GSP_SL%PLMLD_T9, mode)
    if (surface%GSP_RR%VARIABLE_GROUP%GSP_RR%vt%lactive) &
      call bind_pair_1(pairs(16), surface%GSP_RR%PT_T0, &
                       surface%GSP_RR%PT_T1, surface%GSP_RR%PT_T9, mode)
    if (surface%GSP_RR%VARIABLE_GROUP%GSP_RR%vw%lactive) &
      call bind_pair_1(pairs(17), surface%GSP_RR%PW_T0, &
                       surface%GSP_RR%PW_T1, surface%GSP_RR%PW_T9, mode)
    if (surface%GSP_RR%VARIABLE_GROUP%GSP_RR%vfc%lactive) &
      call bind_pair_1(pairs(18), surface%GSP_RR%PFC_T0, &
                       surface%GSP_RR%PFC_T1, surface%GSP_RR%PFC_T9, mode)
    if (surface%GSP_RR%VARIABLE_GROUP%GSP_RR%vic%lactive) &
      call bind_pair_1(pairs(19), surface%GSP_RR%PIC_T0, &
                       surface%GSP_RR%PIC_T1, surface%GSP_RR%PIC_T9, mode)
    if (surface%GSP_RR%VARIABLE_GROUP%GSP_RR%vfp1%lactive) &
      call bind_pair_1(pairs(20), surface%GSP_RR%PFP1_T0, &
                       surface%GSP_RR%PFP1_T1, surface%GSP_RR%PFP1_T9, mode)
    if (surface%GSP_CL%VARIABLE_GROUP%GSP_CL%vtcls%lactive) &
      call bind_pair_1(pairs(21), surface%GSP_CL%PTCLS_T0, &
                       surface%GSP_CL%PTCLS_T1, surface%GSP_CL%PTCLS_T9, mode)
    if (surface%GSP_CL%VARIABLE_GROUP%GSP_CL%vhucls%lactive) &
      call bind_pair_1(pairs(22), surface%GSP_CL%PHUCLS_T0, &
                       surface%GSP_CL%PHUCLS_T1, surface%GSP_CL%PHUCLS_T9, mode)
    if (surface%GSP_CL%VARIABLE_GROUP%GSP_CL%vucls%lactive) &
      call bind_pair_1(pairs(23), surface%GSP_CL%PUCLS_T0, &
                       surface%GSP_CL%PUCLS_T1, surface%GSP_CL%PUCLS_T9, mode)
    if (surface%GSP_CL%VARIABLE_GROUP%GSP_CL%vvcls%lactive) &
      call bind_pair_1(pairs(24), surface%GSP_CL%PVCLS_T0, &
                       surface%GSP_CL%PVCLS_T1, surface%GSP_CL%PVCLS_T9, mode)
    if (surface%GSP_CL%VARIABLE_GROUP%GSP_CL%vnucls%lactive) &
      call bind_pair_1(pairs(25), surface%GSP_CL%PNUCLS_T0, &
                       surface%GSP_CL%PNUCLS_T1, surface%GSP_CL%PNUCLS_T9, mode)
    if (surface%GSP_CL%VARIABLE_GROUP%GSP_CL%vnvcls%lactive) &
      call bind_pair_1(pairs(26), surface%GSP_CL%PNVCLS_T0, &
                       surface%GSP_CL%PNVCLS_T1, surface%GSP_CL%PNVCLS_T9, mode)
    if (surface%GSP_OM%VARIABLE_GROUP%GSP_OM%vto%lactive) &
      call bind_pair_2(pairs(27), surface%GSP_OM%PTO_T0, &
                       surface%GSP_OM%PTO_T1, surface%GSP_OM%PTO_T9, mode)
    if (surface%GSP_OM%VARIABLE_GROUP%GSP_OM%vso%lactive) &
      call bind_pair_2(pairs(28), surface%GSP_OM%PSO_T0, &
                       surface%GSP_OM%PSO_T1, surface%GSP_OM%PSO_T9, mode)
    if (surface%GSP_OM%VARIABLE_GROUP%GSP_OM%vuo%lactive) &
      call bind_pair_2(pairs(29), surface%GSP_OM%PUO_T0, &
                       surface%GSP_OM%PUO_T1, surface%GSP_OM%PUO_T9, mode)
    if (surface%GSP_OM%VARIABLE_GROUP%GSP_OM%vvo%lactive) &
      call bind_pair_2(pairs(30), surface%GSP_OM%PVO_T0, &
                       surface%GSP_OM%PVO_T1, surface%GSP_OM%PVO_T9, mode)
    do j = 1, size(pairs)
      select case (pairs(j)%rank)
      case (0)
        cycle
      case (1)
        if (.not. associated(pairs(j)%destination1)) return
        if (.not. associated(pairs(j)%source1)) return
        if (.not. prepare_pair_1(pairs(j))) return
      case (2)
        if (.not. associated(pairs(j)%destination2)) return
        if (.not. associated(pairs(j)%source2)) return
        if (.not. prepare_pair_2(pairs(j))) return
      end select
    end do
    ! Refuse partial/cross-field overlap. Exact self-copy has no payload work.
    ! Complete spans include all declared source padding and unused elements.
    do j = 1, size(pairs)
      if (pairs(j)%rank == 0) cycle
      if (overlaps(pairs(j)%destination_low, pairs(j)%destination_high, &
                   pairs(j)%source_low, pairs(j)%source_high)) then
        if (.not. pairs(j)%identity) return
      end if
      do k = 1, size(pairs)
        if (k == j .or. pairs(k)%rank == 0) cycle
        if (overlaps(pairs(j)%destination_low, pairs(j)%destination_high, &
                     pairs(k)%source_low, pairs(k)%source_high)) return
        if (overlaps(pairs(j)%destination_low, pairs(j)%destination_high, &
                     pairs(k)%destination_low, pairs(k)%destination_high)) return
      end do
    end do
    do j = 1, size(pairs)
      if (pairs(j)%identity) cycle
      select case (pairs(j)%rank)
      case (1)
        call copy_words_1(pairs(j)%destination1, pairs(j)%source1)
      case (2)
        call copy_words_2(pairs(j)%destination2, pairs(j)%source2)
      end select
    end do
    status = 0_int32
  end function surface_time_state_copy_recorded

  !> Observe caller-owned capture state, without dereferencing its borrowed object.
  !! Return1 when an object is associated, otherwise0. MODE and SEQUENCE retain
  !! their exact words. Availability alone makes no object-lifetime guarantee.
  integer(int32) function get_surface_time_copy_context(context, object, mode, sequence) result(available)
    type(surface_time_copy_context), intent(in) :: context
    type(SURF_AND_MORE_TYPE), pointer, intent(out) :: object
    integer(int32), intent(out) :: mode
    integer(int64), intent(out) :: sequence
    object => context%object
    mode = context%mode
    sequence = context%sequence
    available = 0_int32
    if (associated(object)) available = 1_int32
  end function get_surface_time_copy_context

  subroutine bind_pair_1(pair, time0, time1, time9, mode)
    type(surface_copy_pair), intent(inout) :: pair
    real(real64), pointer, intent(in) :: time0(:), time1(:), time9(:)
    integer(int32), intent(in) :: mode
    pair%rank = 1
    select case (mode)
    case (1)
      pair%destination1 => time1
      pair%source1 => time9
    case (2)
      pair%destination1 => time0
      pair%source1 => time1
    case default
      pair%destination1 => time1
      pair%source1 => time0
    end select
  end subroutine bind_pair_1
  subroutine bind_pair_2(pair, time0, time1, time9, mode)
    type(surface_copy_pair), intent(inout) :: pair
    real(real64), pointer, intent(in) :: time0(:, :), time1(:, :), time9(:, :)
    integer(int32), intent(in) :: mode
    pair%rank = 2
    select case (mode)
    case (1)
      pair%destination2 => time1
      pair%source2 => time9
    case (2)
      pair%destination2 => time0
      pair%source2 => time1
    case default
      pair%destination2 => time1
      pair%source2 => time0
    end select
  end subroutine bind_pair_2

  logical function prepare_pair_1(pair) result(valid)
    type(surface_copy_pair), intent(inout) :: pair
    integer(int64) :: destination_words, source_words, df, sf
    valid = .false.
    destination_words = size(pair%destination1, kind=int64)
    source_words = size(pair%source1, kind=int64)
    if (source_words < destination_words) return
    if (destination_words == 0_int64) then
      valid = .true.
      return
    end if
    if (.not. is_contiguous(pair%destination1) .or. .not. is_contiguous(pair%source1)) return
    df = lbound(pair%destination1, 1, kind=int64); sf = lbound(pair%source1, 1, kind=int64)
    pair%destination_low = transfer(c_loc(pair%destination1(df)), 0_c_intptr_t)
    pair%source_low = transfer(c_loc(pair%source1(sf)), 0_c_intptr_t)
    if (.not. finish_span(pair%destination_low, destination_words, pair%destination_high)) return
    if (.not. finish_span(pair%source_low, source_words, pair%source_high)) return
    pair%identity = pair%destination_low == pair%source_low .and. destination_words == source_words
    valid = .true.
  end function prepare_pair_1
  logical function prepare_pair_2(pair) result(valid)
    type(surface_copy_pair), intent(inout) :: pair
    integer(int64) :: destination_words, source_words, extent1, extent2, d1, d2, s1, s2
    valid = .false.
    if (size(pair%source2, 1, kind=int64) < size(pair%destination2, 1, kind=int64)) return
    if (size(pair%source2, 2, kind=int64) < size(pair%destination2, 2, kind=int64)) return
    extent1 = size(pair%destination2, 1, kind=int64); extent2 = size(pair%destination2, 2, kind=int64)
    if (extent1 == 0_int64 .or. extent2 == 0_int64) then
      valid = .true.
      return
    end if
    if (extent1 > huge(0_int64)/extent2) return
    destination_words = extent1*extent2
    extent1 = size(pair%source2, 1, kind=int64); extent2 = size(pair%source2, 2, kind=int64)
    if (extent1 > huge(0_int64)/extent2) return
    source_words = extent1*extent2
    if (.not. is_contiguous(pair%destination2) .or. .not. is_contiguous(pair%source2)) return
    d1 = lbound(pair%destination2, 1, kind=int64); d2 = lbound(pair%destination2, 2, kind=int64)
    s1 = lbound(pair%source2, 1, kind=int64); s2 = lbound(pair%source2, 2, kind=int64)
    pair%destination_low = transfer(c_loc(pair%destination2(d1, d2)), 0_c_intptr_t)
    pair%source_low = transfer(c_loc(pair%source2(s1, s2)), 0_c_intptr_t)
    if (.not. finish_span(pair%destination_low, destination_words, pair%destination_high)) return
    if (.not. finish_span(pair%source_low, source_words, pair%source_high)) return
    pair%identity = pair%destination_low == pair%source_low .and. &
                    all(shape(pair%destination2, kind=int64) == shape(pair%source2, kind=int64))
    valid = .true.
  end function prepare_pair_2
  logical function finish_span(first, words, last) result(valid)
    integer(c_intptr_t), intent(in) :: first
    integer(int64), intent(in) :: words
    integer(c_intptr_t), intent(out) :: last
    integer(c_intptr_t) :: bytes
    valid = .false.
    if (words < 1_int64 .or. first <= 0_c_intptr_t) return
    if (words > shiftr(int(huge(0_c_intptr_t), int64), 3)) return
    bytes = int(words, c_intptr_t)*8_c_intptr_t
    if (first > huge(first) - (bytes - 1_c_intptr_t)) return
    last = first + (bytes - 1_c_intptr_t)
    valid = .true.
  end function finish_span
  logical function overlaps(a_first, a_last, b_first, b_last) result(found)
    integer(c_intptr_t), intent(in) :: a_first, a_last, b_first, b_last
    found = .false.
    if (a_last < a_first .or. b_last < b_first) return
    found = a_first <= b_last .and. b_first <= a_last
  end function overlaps
  subroutine copy_words_1(destination, source)
    real(real64), intent(inout) :: destination(:)
    real(real64), intent(in) :: source(:)
    integer(int64) :: row, word
    do row = 1, size(destination, kind=int64)
      word = transfer(source(row), 0_int64)
      destination(row) = transfer(word, 0.0_real64)
    end do
  end subroutine copy_words_1
  subroutine copy_words_2(destination, source)
    real(real64), intent(inout) :: destination(:, :)
    real(real64), intent(in) :: source(:, :)
    integer(int64) :: row, plane, word
    if (size(destination, 1, kind=int64) == 0_int64 .or. size(destination, 2, kind=int64) == 0_int64) return
    do plane = 1, size(destination, 2, kind=int64)
      do row = 1, size(destination, 1, kind=int64)
        word = transfer(source(row, plane), 0_int64)
        destination(row, plane) = transfer(word, 0.0_real64)
      end do
    end do
  end subroutine copy_words_2
end module forecast_surface_time_state_copy

!> Select actual Fullpos output spectra from the real mixed direct transform.
module forecast_runtime_output_spectral_selection
  use iso_fortran_env, only: int32, real64
  use forecast_output_request_types, only: type_fprqdyn
  implicit none
  private
  public :: select_runtime_output_spectra, select_runtime_partitioned_output_spectra
contains
  !> Copy source-selected scalar, vorticity or divergence words without arithmetic.
 !! INPUT arrays are(real field,local spectral word). OUTPUT has NFPSPB rows.
 !! All arrays are separate contiguous native owners; one vertical set is
 !! required by the enclosing classified request. No field payload is supplied
 !! by an observer. Inactive output tails retain their incoming bytes.
  integer(int32) function select_runtime_output_spectra(request, scalar, vor, div, output) result(status)
    type(type_fprqdyn), intent(in) :: request
    real(real64), intent(in) :: scalar(:, :), vor(:, :), div(:, :)
    real(real64), intent(inout) :: output(:, :)
    integer :: field, code, level, row, destination, tensor, word, words
    status = 2
    if (request%nfpspb < 0 .or. request%nfpspb > 65536) return
    if (request%nfpsca < 0 .or. request%nfpvec < 0) return
    words = size(output, 2)
    if (words < 1 .or. size(output, 1) < request%nfpspb) return
    if (size(scalar, 1) /= request%nfpsca .or. size(vor, 1) /= request%nfpvec .or. size(div, 1) /= request%nfpvec) return
    if (size(scalar, 2) /= words .or. size(vor, 2) /= words .or. size(div, 2) /= words) return
    if (.not. allocated(request%nfptrdyn) .or. .not. allocated(request%isf) .or. .not. allocated(request%iled)) return
    if (.not. allocated(request%ilev) .or. .not. allocated(request%iloc) .or. .not. allocated(request%igt1)) return
    if (request%nfposdyn < 0 .or. request%nfposdyn > size(request%nfptrdyn)) return
    do field = 1, request%nfposdyn
      code = request%nfptrdyn(field)
      if (code < 1 .or. code > size(request%isf) .or. code > size(request%iled) .or. code > size(request%ilev)) return
      if (request%isf(code) < 1) cycle
      tensor = request%iled(code)
      if (tensor /= 0 .and. tensor /= 2 .and. tensor /= 3) return
      if (code > size(request%iloc, 2) .or. code > size(request%igt1, 1)) return
      if (request%ilev(code) < 0 .or. request%ilev(code) > size(request%iloc, 1)) return
      do level = 1, request%ilev(code)
        destination = request%iloc(level, code)
        if (destination < 1 .or. destination > request%nfpspb) return
        row = request%igt1(code, 1) + level - 1
        if (tensor == 0) then
          row = row - 2*request%nfpvecg
          if (row < 1 .or. row > size(scalar, 1)) return
        else
          if (row < 1 .or. row > size(vor, 1)) return
        end if
      end do
    end do
    do field = 1, request%nfposdyn
      code = request%nfptrdyn(field)
      if (request%isf(code) < 1) cycle
      tensor = request%iled(code)
      do level = 1, request%ilev(code)
        destination = request%iloc(level, code)
        row = request%igt1(code, 1) + level - 1
        if (tensor == 0) row = row - 2*request%nfpvecg
        do word = 1, words
          select case (tensor)
          case (0)
            output(destination, word) = scalar(row, word)
          case (2)
            output(destination, word) = vor(row, word)
          case (3)
            output(destination, word) = div(row, word)
          end select
        end do
      end do
    end do
    status = 0
  end function

  !> Retain the original FPTSA_DIR local selection order on this vertical group.
 !! Scalar, vorticity and divergence counters advance only for owned levels.
 !! The admitted tensor0/2/3 frontier is unchanged; no missing potential
 !! conversion is replaced by a copy. All words are copied without arithmetic.
 integer(int32) function select_runtime_partitioned_output_spectra(request, scalar, vor, div, output, nprtrv, mysetv) result(status)
    type(type_fprqdyn), intent(in) :: request
    real(real64), intent(in) :: scalar(:, :), vor(:, :), div(:, :)
    real(real64), intent(inout) :: output(:, :)
    integer(int32), intent(in) :: nprtrv, mysetv
    integer :: selected_row(max(1, min(65536, request%nfpspb))), source_kind(max(1, min(65536, request%nfpspb)))
    integer :: field, code, level, tensor, word, words, inc, repeat, isca, ivor, idiv, ispb, j
    status = 2
    if (nprtrv < 1 .or. nprtrv > 32 .or. mysetv < 1 .or. mysetv > nprtrv) return
    if (request%nfpspb < 0 .or. request%nfpspb > 65536 .or. request%nfpsca < 0 .or. request%nfpvec < 0) return
    words = size(output, 2)
    if (words < 1 .or. size(output, 1) < request%nfpspb) return
    if (size(scalar, 1) /= request%nfpsca .or. size(vor, 1) /= request%nfpvec .or. size(div, 1) /= request%nfpvec) return
    if (size(scalar, 2) /= words .or. size(vor, 2) /= words .or. size(div, 2) /= words) return
    if (.not. allocated(request%nfptrdyn) .or. .not. allocated(request%isf) .or. .not. allocated(request%iled)) return
    if (.not. allocated(request%ilev) .or. .not. allocated(request%iset) .or. .not. allocated(request%ispd)) return
    if (request%nfposdyn < 0 .or. request%nfposdyn > size(request%nfptrdyn)) return
    isca = 1; ivor = 1; idiv = 1; ispb = 1
    do field = 1, request%nfposdyn
      code = request%nfptrdyn(field)
      if (code < 1 .or. code > size(request%isf) .or. code > size(request%iled) .or. code > size(request%ilev)) return
      if (request%isf(code) < 1) cycle
      tensor = request%iled(code)
      if (tensor /= 0 .and. tensor /= 2 .and. tensor /= 3) return
      if (code > size(request%iset, 2) .or. code > size(request%ispd, 2)) return
  if (request%ilev(code) < 0 .or. request%ilev(code) > size(request%iset, 1) .or. request%ilev(code) > size(request%ispd, 1)) return
      do level = 1, request%ilev(code)
        if (request%iset(level, code) < 1 .or. request%iset(level, code) > nprtrv) return
        if (request%iset(level, code) /= mysetv) cycle
        inc = request%ispd(level, code)
        if (inc < 0 .or. inc > 1 .or. ispb + inc - 1 > request%nfpspb) return
        do repeat = 1, inc
          select case (tensor)
          case (0)
            selected_row(ispb) = isca; source_kind(ispb) = 0
          case (2)
            selected_row(ispb) = ivor; source_kind(ispb) = 1
          case (3)
            selected_row(ispb) = idiv; source_kind(ispb) = -1
          end select
          ispb = ispb + 1
        end do
        select case (tensor)
        case (0); isca = isca + 1
        case (2); ivor = ivor + 1; idiv = idiv + 1
        case (3); idiv = idiv + 1; ivor = ivor + 1
        end select
      end do
    end do
    if (isca - 1 /= size(scalar, 1) .or. idiv + ivor - 2 /= 2*size(vor, 1) .or. ispb - 1 /= request%nfpspb) return
    do j = 1, request%nfpspb
      select case (source_kind(j))
      case (0)
        if (selected_row(j) < 1 .or. selected_row(j) > size(scalar, 1)) return
      case default
        if (selected_row(j) < 1 .or. selected_row(j) > size(vor, 1)) return
      end select
    end do
    do word = 1, words
      do j = 1, request%nfpspb
        select case (source_kind(j))
        case (0); output(j, word) = scalar(selected_row(j), word)
        case (1); output(j, word) = vor(selected_row(j), word)
        case (-1); output(j, word) = div(selected_row(j), word)
        end select
      end do
    end do
    status = 0
  end function
end module

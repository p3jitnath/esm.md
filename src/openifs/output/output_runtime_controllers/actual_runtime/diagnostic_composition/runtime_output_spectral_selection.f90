!> Select actual Fullpos output spectra from the real mixed direct transform.
module forecast_runtime_output_spectral_selection
  use iso_fortran_env, only: int32, real64
  use forecast_output_request_types, only: type_fprqdyn
  implicit none
  private
  public :: select_runtime_output_spectra
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
end module

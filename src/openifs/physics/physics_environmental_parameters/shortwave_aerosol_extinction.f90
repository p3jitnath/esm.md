!> Source-ordered aerosol extinction for the original tenth shortwave band.
!! Coefficient units are m2/kg. The upstream g/kg convention is retained;
!! this component does not assert a resolved inverse-length interpretation.
module forecast_shortwave_aerosol_extinction
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: shortwave_aerosol_extinction, runtime_shortwave_aerosol_extinction
contains
  !> Retain the earlier at-most24-column entry with the common native tables.
  subroutine shortwave_aerosol_extinction(pitch,first,last,band,classes,type_indices,hydrophobic,hydrophilic,thresholds,mixing_ratio,humidity,extinction,status)
    integer(int32), intent(in) :: pitch, first, last, band, classes(:), type_indices(:)
    real(real64), intent(in) :: hydrophobic(:, :), hydrophilic(:, :, :), thresholds(:), mixing_ratio(:, :), humidity(:)
    real(real64), intent(inout) :: extinction(:)
    integer(int32), intent(out) :: status
    status = 2
    if (pitch > 24) return
    call runtime_shortwave_aerosol_extinction(pitch,first,last,band,classes,type_indices,hydrophobic,hydrophilic,thresholds,mixing_ratio,humidity,extinction,status)
  end subroutine

  !> Sum species1:12, preserving inactive output words and every input.
  !! Native table bounds are hydrophobic(14,18),hydrophilic(14,12,13).
  !! Threshold equality selects the lower bin; NaN selects bin1 and raises
  !! invalid as the source signaling comparison does. No FP-mode probe runs.
  !! The caller supplies aligned disjoint output, contiguous input owners,
  !! initialized table dimensions and the established floating-point mode.
  subroutine runtime_shortwave_aerosol_extinction(pitch,first,last,band,classes,type_indices,hydrophobic,hydrophilic,thresholds,mixing_ratio,humidity,extinction,status)
    integer(int32), intent(in) :: pitch, first, last, band, classes(:), type_indices(:)
    real(real64), intent(in) :: hydrophobic(:, :), hydrophilic(:, :, :), thresholds(:), mixing_ratio(:, :), humidity(:)
    real(real64), intent(inout) :: extinction(:)
    integer(int32), intent(out) :: status
    integer :: j, s, bin
    logical :: uses_phobic, uses_philic
    real(real64) :: total, coefficient, product
    status = 2
if (pitch < 1 .or. pitch > 128 .or. first < 1 .or. first > pitch + 1 .or. last < first - 1 .or. last > pitch .or. band /= 10) return
    if (size(classes) /= 12) return
    if (any(classes < 1) .or. any(classes > 3)) return
    if (first > last) then
      status = 0; return
    end if
    if(size(mixing_ratio,1)/=pitch.or.size(mixing_ratio,2)/=12.or.size(humidity)<pitch.or.size(extinction)<pitch) return
    uses_phobic = any(classes == 2); uses_philic = any(classes == 3)
    if (uses_phobic .or. uses_philic) then
      if (size(type_indices) /= 12) return
      do s = 1, 12
        if (classes(s) == 2) then
          if (type_indices(s) < 1 .or. type_indices(s) > 18) return
        else if (classes(s) == 3) then
          if (type_indices(s) < 1 .or. type_indices(s) > 13) return
        end if
      end do
    end if
    if (uses_phobic) then
      if (any(shape(hydrophobic) /= [14, 18])) return
    end if
    if (uses_philic) then
      if (any(shape(hydrophilic) /= [14, 12, 13])) return
    end if
    if (size(thresholds) /= 12) return
    if (transfer(thresholds(1), 0_int64) /= 0_int64) return
    do s = 2, 12
      if (.not. (thresholds(s) > thresholds(s - 1) .and. thresholds(s) <= 1.0_real64)) return
    end do
    do j = first, last
      if (humidity(j) > thresholds(12)) then
        bin = 12
      else
        bin = 1
        do
          ! Unordered input reaches the first bin, as in the source FCMPE.
          if (.not. (humidity(j) > thresholds(bin + 1))) exit
          bin = bin + 1
          if (bin == 12) exit
        end do
      end if
      total = 0.0_real64
      do s = 1, 12
        select case (classes(s))
        case (2)
          coefficient = hydrophobic(10, type_indices(s))
        case (3)
          coefficient = hydrophilic(10, bin, type_indices(s))
        case default
          cycle
        end select
        product = mixing_ratio(j, s)*coefficient
        total = total + product
      end do
      extinction(j) = total
    end do
    status = 0
  end subroutine
end module

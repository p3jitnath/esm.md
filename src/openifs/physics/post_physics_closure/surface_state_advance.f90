! (C) Copyright 1989- ECMWF. Apache Licence Version2.0.
!> Advance23 surface fields with separately rounded FP64 multiply and add.
!! The first nine integer32 arguments are dimensions and inclusive columns.
!! PDT is the effective physics interval in seconds. Tendencies are readonly;
!! only active columns of each real64 state change. Fields do not overlap.
!! Native array descriptors carry strides. The compiler owns their layout.
!! Caller establishes nearest-even rounding and gradual underflow once.
module forecast_native_surface_state_advance
  use iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: cpspe
contains
!> Return0 after all updates, or2 before writing an unsupported shape.
integer(int32) function cpspe(KPROMA,KSTART,KPROF,KLEVS,KLEVXP,KLEVO,KLEVSN,KFLDXP,KFLDXP2,PDT,PTSAE1,PTLE1,PWSAE1,PISAE1,PWLE1,PSNSE1,PWSNE1,PASNE1,PRSNE1,PTSNE1,PTLICEE1,PTLMNWE1,PTLWMLE1,PTLBOTE1,PTLSFE1,PHLICEE1,PHLMLE1,PEXTRE1,PXTR2E1,PUOE1,PVOE1,PTOE1,PSOE1,PTSA1,PTL1,PWSA1,PISA1,PWL1,PSNS1,PWSN1,PASN1,PRSN1,PTSN1,PTLIC1,PTLMN1,PTLML1,PTLBT1,PTLSF1,PHLIC1,PHLM1,PEXTRP1,PXTRP21,PUO1,PVO1,PTO1,PSO1)result(status)
    integer(int32), intent(in) :: KPROMA, KSTART, KPROF, KLEVS, KLEVXP, KLEVO, KLEVSN, KFLDXP, KFLDXP2
    real(real64), intent(in) :: PDT
    real(real64), intent(in) :: PTSAE1(:, :)
    real(real64), intent(inout) :: PTSA1(:, :)
    real(real64), intent(in) :: PTLE1(:)
    real(real64), intent(inout) :: PTL1(:)
    real(real64), intent(in) :: PWSAE1(:, :)
    real(real64), intent(inout) :: PWSA1(:, :)
    real(real64), intent(in) :: PISAE1(:, :)
    real(real64), intent(inout) :: PISA1(:, :)
    real(real64), intent(in) :: PWLE1(:)
    real(real64), intent(inout) :: PWL1(:)
    real(real64), intent(in) :: PSNSE1(:, :)
    real(real64), intent(inout) :: PSNS1(:, :)
    real(real64), intent(in) :: PWSNE1(:, :)
    real(real64), intent(inout) :: PWSN1(:, :)
    real(real64), intent(in) :: PASNE1(:, :)
    real(real64), intent(inout) :: PASN1(:, :)
    real(real64), intent(in) :: PRSNE1(:, :)
    real(real64), intent(inout) :: PRSN1(:, :)
    real(real64), intent(in) :: PTSNE1(:, :)
    real(real64), intent(inout) :: PTSN1(:, :)
    real(real64), intent(in) :: PTLICEE1(:)
    real(real64), intent(inout) :: PTLIC1(:)
    real(real64), intent(in) :: PTLMNWE1(:)
    real(real64), intent(inout) :: PTLMN1(:)
    real(real64), intent(in) :: PTLWMLE1(:)
    real(real64), intent(inout) :: PTLML1(:)
    real(real64), intent(in) :: PTLBOTE1(:)
    real(real64), intent(inout) :: PTLBT1(:)
    real(real64), intent(in) :: PTLSFE1(:)
    real(real64), intent(inout) :: PTLSF1(:)
    real(real64), intent(in) :: PHLICEE1(:)
    real(real64), intent(inout) :: PHLIC1(:)
    real(real64), intent(in) :: PHLMLE1(:)
    real(real64), intent(inout) :: PHLM1(:)
    real(real64), intent(in) :: PEXTRE1(:, :, :)
    real(real64), intent(inout) :: PEXTRP1(:, :, :)
    real(real64), intent(in) :: PXTR2E1(:, :)
    real(real64), intent(inout) :: PXTRP21(:, :)
    real(real64), intent(in) :: PUOE1(:, :)
    real(real64), intent(inout) :: PUO1(:, :)
    real(real64), intent(in) :: PVOE1(:, :)
    real(real64), intent(inout) :: PVO1(:, :)
    real(real64), intent(in) :: PTOE1(:, :)
    real(real64), intent(inout) :: PTO1(:, :)
    real(real64), intent(in) :: PSOE1(:, :)
    real(real64), intent(inout) :: PSO1(:, :)
    integer(int32) :: j, k, m
    integer(int64) :: entries
    real(real64) :: scaled_tendency
    status = 2
    if (KPROMA < 1 .or. KSTART < 1 .or. KSTART > KPROMA) return
    if (KPROF < KSTART - 1 .or. KPROF > KPROMA) return
    if (any([KLEVS, KLEVXP, KLEVO, KLEVSN, KFLDXP, KFLDXP2] < 0)) return
    if (size(PTSAE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTSAE1, kind=int64) < int([KPROMA, KLEVS], int64))) return
    if (size(PTSA1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTSA1, kind=int64) < int([KPROMA, KLEVS], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVS > 0) then
      if (entries > huge(entries)/int(KLEVS, int64)) return
      entries = entries*int(KLEVS, int64)
    else
      entries = 0_int64
    end if
    if (size(PTLE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTLE1, kind=int64) < int([KPROMA], int64))) return
    if (size(PTL1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTL1, kind=int64) < int([KPROMA], int64))) return
    entries = int(KPROMA, int64)
    if (size(PWSAE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PWSAE1, kind=int64) < int([KPROMA, KLEVS], int64))) return
    if (size(PWSA1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PWSA1, kind=int64) < int([KPROMA, KLEVS], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVS > 0) then
      if (entries > huge(entries)/int(KLEVS, int64)) return
      entries = entries*int(KLEVS, int64)
    else
      entries = 0_int64
    end if
    if (size(PISAE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PISAE1, kind=int64) < int([KPROMA, KLEVS], int64))) return
    if (size(PISA1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PISA1, kind=int64) < int([KPROMA, KLEVS], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVS > 0) then
      if (entries > huge(entries)/int(KLEVS, int64)) return
      entries = entries*int(KLEVS, int64)
    else
      entries = 0_int64
    end if
    if (size(PWLE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PWLE1, kind=int64) < int([KPROMA], int64))) return
    if (size(PWL1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PWL1, kind=int64) < int([KPROMA], int64))) return
    entries = int(KPROMA, int64)
    if (size(PSNSE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PSNSE1, kind=int64) < int([KPROMA, KLEVSN], int64))) return
    if (size(PSNS1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PSNS1, kind=int64) < int([KPROMA, KLEVSN], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVSN > 0) then
      if (entries > huge(entries)/int(KLEVSN, int64)) return
      entries = entries*int(KLEVSN, int64)
    else
      entries = 0_int64
    end if
    if (size(PWSNE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PWSNE1, kind=int64) < int([KPROMA, KLEVSN], int64))) return
    if (size(PWSN1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PWSN1, kind=int64) < int([KPROMA, KLEVSN], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVSN > 0) then
      if (entries > huge(entries)/int(KLEVSN, int64)) return
      entries = entries*int(KLEVSN, int64)
    else
      entries = 0_int64
    end if
    if (size(PASNE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PASNE1, kind=int64) < int([KPROMA, KLEVSN], int64))) return
    if (size(PASN1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PASN1, kind=int64) < int([KPROMA, KLEVSN], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVSN > 0) then
      if (entries > huge(entries)/int(KLEVSN, int64)) return
      entries = entries*int(KLEVSN, int64)
    else
      entries = 0_int64
    end if
    if (size(PRSNE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PRSNE1, kind=int64) < int([KPROMA, KLEVSN], int64))) return
    if (size(PRSN1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PRSN1, kind=int64) < int([KPROMA, KLEVSN], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVSN > 0) then
      if (entries > huge(entries)/int(KLEVSN, int64)) return
      entries = entries*int(KLEVSN, int64)
    else
      entries = 0_int64
    end if
    if (size(PTSNE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTSNE1, kind=int64) < int([KPROMA, KLEVSN], int64))) return
    if (size(PTSN1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTSN1, kind=int64) < int([KPROMA, KLEVSN], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVSN > 0) then
      if (entries > huge(entries)/int(KLEVSN, int64)) return
      entries = entries*int(KLEVSN, int64)
    else
      entries = 0_int64
    end if
    if (size(PTLICEE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTLICEE1, kind=int64) < int([KPROMA], int64))) return
    if (size(PTLIC1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTLIC1, kind=int64) < int([KPROMA], int64))) return
    entries = int(KPROMA, int64)
    if (size(PTLMNWE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTLMNWE1, kind=int64) < int([KPROMA], int64))) return
    if (size(PTLMN1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTLMN1, kind=int64) < int([KPROMA], int64))) return
    entries = int(KPROMA, int64)
    if (size(PTLWMLE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTLWMLE1, kind=int64) < int([KPROMA], int64))) return
    if (size(PTLML1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTLML1, kind=int64) < int([KPROMA], int64))) return
    entries = int(KPROMA, int64)
    if (size(PTLBOTE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTLBOTE1, kind=int64) < int([KPROMA], int64))) return
    if (size(PTLBT1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTLBT1, kind=int64) < int([KPROMA], int64))) return
    entries = int(KPROMA, int64)
    if (size(PTLSFE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTLSFE1, kind=int64) < int([KPROMA], int64))) return
    if (size(PTLSF1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTLSF1, kind=int64) < int([KPROMA], int64))) return
    entries = int(KPROMA, int64)
    if (size(PHLICEE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PHLICEE1, kind=int64) < int([KPROMA], int64))) return
    if (size(PHLIC1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PHLIC1, kind=int64) < int([KPROMA], int64))) return
    entries = int(KPROMA, int64)
    if (size(PHLMLE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PHLMLE1, kind=int64) < int([KPROMA], int64))) return
    if (size(PHLM1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PHLM1, kind=int64) < int([KPROMA], int64))) return
    entries = int(KPROMA, int64)
    if (size(PEXTRE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PEXTRE1, kind=int64) < int([KPROMA, KLEVXP, KFLDXP], int64))) return
    if (size(PEXTRP1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PEXTRP1, kind=int64) < int([KPROMA, KLEVXP, KFLDXP], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVXP > 0) then
      if (entries > huge(entries)/int(KLEVXP, int64)) return
      entries = entries*int(KLEVXP, int64)
    else
      entries = 0_int64
    end if
    if (KFLDXP > 0) then
      if (entries > huge(entries)/int(KFLDXP, int64)) return
      entries = entries*int(KFLDXP, int64)
    else
      entries = 0_int64
    end if
    if (size(PXTR2E1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PXTR2E1, kind=int64) < int([KPROMA, KFLDXP2], int64))) return
    if (size(PXTRP21, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PXTRP21, kind=int64) < int([KPROMA, KFLDXP2], int64))) return
    entries = int(KPROMA, int64)
    if (KFLDXP2 > 0) then
      if (entries > huge(entries)/int(KFLDXP2, int64)) return
      entries = entries*int(KFLDXP2, int64)
    else
      entries = 0_int64
    end if
    if (size(PUOE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PUOE1, kind=int64) < int([KPROMA, KLEVO], int64))) return
    if (size(PUO1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PUO1, kind=int64) < int([KPROMA, KLEVO], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVO > 0) then
      if (entries > huge(entries)/int(KLEVO, int64)) return
      entries = entries*int(KLEVO, int64)
    else
      entries = 0_int64
    end if
    if (size(PVOE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PVOE1, kind=int64) < int([KPROMA, KLEVO], int64))) return
    if (size(PVO1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PVO1, kind=int64) < int([KPROMA, KLEVO], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVO > 0) then
      if (entries > huge(entries)/int(KLEVO, int64)) return
      entries = entries*int(KLEVO, int64)
    else
      entries = 0_int64
    end if
    if (size(PTOE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTOE1, kind=int64) < int([KPROMA, KLEVO], int64))) return
    if (size(PTO1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PTO1, kind=int64) < int([KPROMA, KLEVO], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVO > 0) then
      if (entries > huge(entries)/int(KLEVO, int64)) return
      entries = entries*int(KLEVO, int64)
    else
      entries = 0_int64
    end if
    if (size(PSOE1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PSOE1, kind=int64) < int([KPROMA, KLEVO], int64))) return
    if (size(PSO1, 1, kind=int64) /= int(KPROMA, int64)) return
    if (any(shape(PSO1, kind=int64) < int([KPROMA, KLEVO], int64))) return
    entries = int(KPROMA, int64)
    if (KLEVO > 0) then
      if (entries > huge(entries)/int(KLEVO, int64)) return
      entries = entries*int(KLEVO, int64)
    else
      entries = 0_int64
    end if
    if (KPROF < KSTART) then
      status = 0
      return
    end if
    do k = 1, KLEVS
    do j = KSTART, KPROF
      scaled_tendency = PDT*PTSAE1(j, k)
      PTSA1(j, k) = PTSA1(j, k) + scaled_tendency
    end do
    end do
    do j = KSTART, KPROF
      scaled_tendency = PDT*PTLE1(j)
      PTL1(j) = PTL1(j) + scaled_tendency
    end do
    do k = 1, KLEVS
    do j = KSTART, KPROF
      scaled_tendency = PDT*PWSAE1(j, k)
      PWSA1(j, k) = PWSA1(j, k) + scaled_tendency
    end do
    end do
    do k = 1, KLEVS
    do j = KSTART, KPROF
      scaled_tendency = PDT*PISAE1(j, k)
      PISA1(j, k) = PISA1(j, k) + scaled_tendency
    end do
    end do
    do j = KSTART, KPROF
      scaled_tendency = PDT*PWLE1(j)
      PWL1(j) = PWL1(j) + scaled_tendency
    end do
    do k = 1, KLEVSN
    do j = KSTART, KPROF
      scaled_tendency = PDT*PSNSE1(j, k)
      PSNS1(j, k) = PSNS1(j, k) + scaled_tendency
    end do
    end do
    do k = 1, KLEVSN
    do j = KSTART, KPROF
      scaled_tendency = PDT*PWSNE1(j, k)
      PWSN1(j, k) = PWSN1(j, k) + scaled_tendency
    end do
    end do
    do k = 1, KLEVSN
    do j = KSTART, KPROF
      scaled_tendency = PDT*PASNE1(j, k)
      PASN1(j, k) = PASN1(j, k) + scaled_tendency
    end do
    end do
    do k = 1, KLEVSN
    do j = KSTART, KPROF
      scaled_tendency = PDT*PRSNE1(j, k)
      PRSN1(j, k) = PRSN1(j, k) + scaled_tendency
    end do
    end do
    do k = 1, KLEVSN
    do j = KSTART, KPROF
      scaled_tendency = PDT*PTSNE1(j, k)
      PTSN1(j, k) = PTSN1(j, k) + scaled_tendency
    end do
    end do
    do j = KSTART, KPROF
      scaled_tendency = PDT*PTLICEE1(j)
      PTLIC1(j) = PTLIC1(j) + scaled_tendency
    end do
    do j = KSTART, KPROF
      scaled_tendency = PDT*PTLMNWE1(j)
      PTLMN1(j) = PTLMN1(j) + scaled_tendency
    end do
    do j = KSTART, KPROF
      scaled_tendency = PDT*PTLWMLE1(j)
      PTLML1(j) = PTLML1(j) + scaled_tendency
    end do
    do j = KSTART, KPROF
      scaled_tendency = PDT*PTLBOTE1(j)
      PTLBT1(j) = PTLBT1(j) + scaled_tendency
    end do
    do j = KSTART, KPROF
      scaled_tendency = PDT*PTLSFE1(j)
      PTLSF1(j) = PTLSF1(j) + scaled_tendency
    end do
    do j = KSTART, KPROF
      scaled_tendency = PDT*PHLICEE1(j)
      PHLIC1(j) = PHLIC1(j) + scaled_tendency
    end do
    do j = KSTART, KPROF
      scaled_tendency = PDT*PHLMLE1(j)
      PHLM1(j) = PHLM1(j) + scaled_tendency
    end do
    do m = 1, KFLDXP
    do k = 1, KLEVXP
    do j = KSTART, KPROF
      scaled_tendency = PDT*PEXTRE1(j, k, m)
      PEXTRP1(j, k, m) = PEXTRP1(j, k, m) + scaled_tendency
    end do
    end do
    end do
    do k = 1, KFLDXP2
    do j = KSTART, KPROF
      scaled_tendency = PDT*PXTR2E1(j, k)
      PXTRP21(j, k) = PXTRP21(j, k) + scaled_tendency
    end do
    end do
    do k = 1, KLEVO
    do j = KSTART, KPROF
      scaled_tendency = PDT*PUOE1(j, k)
      PUO1(j, k) = PUO1(j, k) + scaled_tendency
    end do
    end do
    do k = 1, KLEVO
    do j = KSTART, KPROF
      scaled_tendency = PDT*PVOE1(j, k)
      PVO1(j, k) = PVO1(j, k) + scaled_tendency
    end do
    end do
    do k = 1, KLEVO
    do j = KSTART, KPROF
      scaled_tendency = PDT*PTOE1(j, k)
      PTO1(j, k) = PTO1(j, k) + scaled_tendency
    end do
    end do
    do k = 1, KLEVO
    do j = KSTART, KPROF
      scaled_tendency = PDT*PSOE1(j, k)
      PSO1(j, k) = PSO1(j, k) + scaled_tendency
    end do
    end do
    status = 0
  end function
end module

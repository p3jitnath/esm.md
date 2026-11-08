module forecast_pressure_humidity_output
  !! PPQ interpolates a model-level mixing ratio onto pressure levels.
  !! It owns its top-row and bottom-edge temporaries. Caller arrays remain
  !! borrowed; inactive output cells retain their incoming bytes.
  use iso_fortran_env, only: int32, int64, real64
  use yomhook, only: lhook, dr_hook
  use forecast_pressure_level_interpolation, only: ppintp
  implicit none
  private
  public :: ppq
contains
  !> Interpolate specific humidity, in kg/kg, with constant extrapolation.
  !! PQF has shape(P,L), PQPP(P,T), coordinates/differences(P,0:L,4).
  !! Only absent or false LDBOB is the generated source route. PBOB0HACK
  !! remains unconsumed in that route, including when it is present.
  subroutine ppq(kproma, kst, kprof, kflev, klevp, klolev, kppm, klevb, prpres, ldbelo, ldblow, &
                 prxp, prxpd, pqf, pqpp, ldbob, pbob0hack, status)
    integer(int32), intent(in) :: kproma, kst, kprof, kflev, klevp, klolev, kppm
    integer(int32), intent(in) :: klevb(:, :, :)
    real(real64), intent(in) :: prpres(:, :), prxp(:, 0:, :), prxpd(:, 0:, :), pqf(:, :)
    logical, intent(in) :: ldbelo(:, :), ldblow(:)
    real(real64), intent(inout) :: pqpp(:, :)
    logical, optional, intent(in) :: ldbob
    real(real64), optional, intent(in) :: pbob0hack
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: storage(:)
    real(real64), pointer, contiguous :: top_field(:, :), bottom(:)
    integer(int64) :: model_words, words
    integer :: allocation_status, j, k, t
    integer(int32) :: hook_word
    logical :: hook_enabled
    real(real64) :: handle
    status = 2
    if (kproma < 1 .or. kproma > 4096) return
    if (kst < 1 .or. kprof < kst .or. kprof > kproma) return
    if (kflev < 1 .or. kflev > 512) return
    if (klevp < 1 .or. klevp > 4096 .or. klolev < 1 .or. klolev > klevp) return
    if (kppm /= 4) return
    if (present(ldbob)) then
      if (transfer(ldbob, 0_int32) /= 0) return
    end if
    if (size(pqf, 1) < kproma .or. size(pqf, 2) < kflev) return
    if (size(pqpp, 1) < kproma .or. size(pqpp, 2) < klevp) return
    hook_word = transfer(lhook, 0_int32)
    if (hook_word /= 0 .and. hook_word /= 1) return
    hook_enabled = lhook
    model_words = int(kproma, int64)*(kflev + 1)
    words = model_words + kproma
    allocate (storage(words), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    top_field(1:kproma, 0:kflev) => storage(1:model_words)
    bottom(1:kproma) => storage(model_words + 1:words)
    if (hook_enabled) call dr_hook('PPQ', 0, handle)
    do k = 1, kflev
      do j = kst, kprof
        top_field(j, k) = pqf(j, k)
      end do
    end do
    do j = kst, kprof
      top_field(j, 0) = top_field(j, 1)
      bottom(j) = pqf(j, kflev)
    end do
    call ppintp(kproma, kst, kprof, kflev, klevp, klolev, kppm, klevb, 2_int32, &
                ldbelo, ldblow, prpres, prxp, prxpd, top_field, pqpp, status)
    if (status /= 0) return
    do t = klolev, klevp
      if (.not. ldblow(t)) cycle
      do j = kst, kprof
        if (ldbelo(j, t)) pqpp(j, t) = bottom(j)
      end do
    end do
    if (hook_enabled) call dr_hook('PPQ', 1, handle)
    deallocate (storage)
    status = 0
  end subroutine
end module

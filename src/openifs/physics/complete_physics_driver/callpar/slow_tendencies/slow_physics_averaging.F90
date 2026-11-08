!> Preserve the complete generated slow-physics rate averaging calculation.
!! Column-first fields use m/s,K,Pa,kg/kg and their rates per second.
!! Named native records supply the field positions, parameters and time interval.
!! The caller establishes nearest-even rounding and gradual underflow once.
module forecast_slow_physics_averaging
  use iso_fortran_env, only: int32, int64, real64
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use forecast_operational_model_types, only: native_operational_model_configuration
  use md2asm_record_cloud_supersaturation, only: cloud_supersatcheck
  implicit none
  private
  public :: sltend
contains
  !> Save slow rates, combine previous changes, then remove supersaturation.
  !! INPUT model records and RSLWX remain readonly. All numerical outputs are
  !! INOUT so inactive cells, unused cloud planes and capacity tails survive.
  !! Original array argument order follows the explicit provider arguments.
  !! KIDIA must be1; KFDIA0:KLON; KLON0:4096; KLEV0:512; KTEND3:64;
  !! constituent planes0:64 and diagnostic planes0:128 retain source bounds.
  !! Status2 refuses unsupported native metadata before numerical writes.
  !! No original method, numerical routine or global supplies a calculation.
  subroutine sltend(physical, thermal, current_step, initial_step, rslwx, model, &
                    kidia, kfdia, klon, klev, ktend, pt, pq, pa, &
                    pcld, prsf1, prs1, pdynu, pdynv, pdynt, pdynq, pdyno3, &
                    pdyna, pdyncld, pcenu, pcenv, pcent, pcenq, pceno3, pcena, &
                    pcencld, ptenu, ptenv, ptent, ptenq, pteno3, ptena, ptencld, &
                    pphtenu, pphtenv, pphtent, pphtengfl, pvfu, pvfv, pvft, pvfq, &
                    pvfa, psatt, psatq, psata, psatcld, psavtend, pgflslp, pextra, &
                    kfldx, &
                    status)
    type(forecast_physical_constants), intent(in) :: physical
    type(thermal_parameter_record), intent(in) :: thermal
    integer(int32), intent(in) :: current_step, initial_step
    real(real64), intent(in) :: rslwx(:)
    type(native_operational_model_configuration), intent(in) :: model
    integer(int32), intent(in) :: kidia, kfdia, klon, klev, ktend, kfldx
    integer(int32), intent(out) :: status
    real(real64), intent(in) :: pt(:, :)
    real(real64), intent(in) :: pq(:, :)
    real(real64), intent(in) :: pa(:, :)
    real(real64), intent(in) :: prsf1(:, :)
    real(real64), intent(in) :: pdynu(:, :)
    real(real64), intent(in) :: pdynv(:, :)
    real(real64), intent(in) :: pdynt(:, :)
    real(real64), intent(in) :: pdynq(:, :)
    real(real64), intent(in) :: pdyno3(:, :)
    real(real64), intent(in) :: pdyna(:, :)
    real(real64), intent(in) :: pcenu(:, :)
    real(real64), intent(in) :: pcenv(:, :)
    real(real64), intent(in) :: pcent(:, :)
    real(real64), intent(in) :: pcenq(:, :)
    real(real64), intent(in) :: pceno3(:, :)
    real(real64), intent(in) :: pcena(:, :)
    real(real64), intent(inout) :: ptenu(:, :)
    real(real64), intent(inout) :: ptenv(:, :)
    real(real64), intent(inout) :: ptent(:, :)
    real(real64), intent(inout) :: ptenq(:, :)
    real(real64), intent(inout) :: pteno3(:, :)
    real(real64), intent(inout) :: ptena(:, :)
    real(real64), intent(in) :: pphtenu(:, :)
    real(real64), intent(in) :: pphtenv(:, :)
    real(real64), intent(in) :: pphtent(:, :)
    real(real64), intent(in) :: pvfu(:, :)
    real(real64), intent(in) :: pvfv(:, :)
    real(real64), intent(in) :: pvft(:, :)
    real(real64), intent(in) :: pvfq(:, :)
    real(real64), intent(in) :: pvfa(:, :)
    real(real64), intent(in) :: psatt(:, :)
    real(real64), intent(in) :: psatq(:, :)
    real(real64), intent(in) :: psata(:, :)
    real(real64), intent(in) :: prs1(:, :)
    real(real64), intent(in) :: pcld(:, :, :)
    real(real64), intent(in) :: pdyncld(:, :, :)
    real(real64), intent(in) :: pcencld(:, :, :)
    real(real64), intent(inout) :: ptencld(:, :, :)
    real(real64), intent(in) :: pphtengfl(:, :, :)
    real(real64), intent(in) :: psatcld(:, :, :)
    real(real64), intent(inout) :: psavtend(:, :, :)
    real(real64), intent(inout) :: pgflslp(:, :, :)
    real(real64), intent(inout) :: pextra(:, :, :)
    integer(int32) :: ids(7), slots(7), tracer_count, extra_count, budget_planes(3)
    integer :: i, j, k, is, position, cloud_top
    real(real64), volatile :: inverse_time, negative_switch, weight, a, b, c, trial
    real(real64) :: timestep, depth, delta_pressure, density
    status = 2
    if (kidia /= 1 .or. klon < 0 .or. klon > 4096 .or. klev < 0 .or. klev > 512) return
    if (kfdia < 0 .or. kfdia > klon .or. ktend < 3 .or. ktend > 64 .or. kfldx < 0 .or. kfldx > 128) return
    tracer_count = model%fields%registration%ndimslp
    if (tracer_count < 0 .or. tracer_count > 64) return
    if (.not. positive_finite(physical%rd) .or. .not. positive_finite(physical%rg)) return
    timestep = model%physics_auxiliary%tsphy
    if (.not. positive_finite(timestep)) return
    cloud_top = model%physics%cloud%ncldtop
    if (cloud_top < 1 .or. cloud_top > klev + 1) return
    negative_switch = 1.0_real64
    if (current_step == initial_step) negative_switch = 0.0_real64
    negative_switch = -negative_switch
    inverse_time = 1.0_real64/timestep
    if (klon == 0 .or. klev == 0 .or. kfdia == 0) then
      status = 0; return
    end if
    if (.not. fits2(pt, klon, klev)) return
    if (.not. fits2(pq, klon, klev)) return
    if (.not. fits2(pa, klon, klev)) return
    if (.not. fits2(prsf1, klon, klev)) return
    if (.not. fits2(pdynu, klon, klev)) return
    if (.not. fits2(pdynv, klon, klev)) return
    if (.not. fits2(pdynt, klon, klev)) return
    if (.not. fits2(pdynq, klon, klev)) return
    if (.not. fits2(pdyno3, klon, klev)) return
    if (.not. fits2(pdyna, klon, klev)) return
    if (.not. fits2(pcenu, klon, klev)) return
    if (.not. fits2(pcenv, klon, klev)) return
    if (.not. fits2(pcent, klon, klev)) return
    if (.not. fits2(pcenq, klon, klev)) return
    if (.not. fits2(pceno3, klon, klev)) return
    if (.not. fits2(pcena, klon, klev)) return
    if (.not. fits2(ptenu, klon, klev)) return
    if (.not. fits2(ptenv, klon, klev)) return
    if (.not. fits2(ptent, klon, klev)) return
    if (.not. fits2(ptenq, klon, klev)) return
    if (.not. fits2(pteno3, klon, klev)) return
    if (.not. fits2(ptena, klon, klev)) return
    if (.not. fits2(pphtenu, klon, klev)) return
    if (.not. fits2(pphtenv, klon, klev)) return
    if (.not. fits2(pphtent, klon, klev)) return
    if (.not. fits2(pvfu, klon, klev)) return
    if (.not. fits2(pvfv, klon, klev)) return
    if (.not. fits2(pvft, klon, klev)) return
    if (.not. fits2(pvfq, klon, klev)) return
    if (.not. fits2(pvfa, klon, klev)) return
    if (.not. fits2(psatt, klon, klev)) return
    if (.not. fits2(psatq, klon, klev)) return
    if (.not. fits2(psata, klon, klev)) return
    if (.not. fits2(prs1, klon, klev + 1)) return
    if (.not. fits3(pcld, klon, klev, 5)) return
    if (.not. fits3(pdyncld, klon, klev, 5)) return
    if (.not. fits3(pcencld, klon, klev, 5)) return
    if (.not. fits3(ptencld, klon, klev, 5)) return
    if (.not. fits3(pphtengfl, klon, klev, tracer_count)) return
    if (.not. fits3(psatcld, klon, klev, 5)) return
    if (.not. fits3(psavtend, klon, klev, ktend)) return
    if (.not. fits3(pgflslp, klon, klev, tracer_count)) return
    if (.not. is_contiguous(rslwx) .or. size(rslwx) < klev) return
    do k = 1, klev
      if (.not. unit_interval(rslwx(k))) return
    end do
    ids = [model%fields%aliases%yq, model%fields%aliases%ya, model%fields%aliases%yl, &
           model%fields%aliases%yi, model%fields%aliases%yr, model%fields%aliases%ys, model%fields%aliases%yo3]
    slots = 0
    do i = 1, 7
      if (ids(i) < 1 .or. ids(i) > size(model%fields%components)) return
      if (model%fields%components(ids(i))%lphy < 0 .or. model%fields%components(ids(i))%lphy > 1) return
      if (model%fields%components(ids(i))%lphy == 1) then
        position = model%fields%components(ids(i))%mpslp
        if (position < 1 .or. position > tracer_count) return
        slots(i) = position
      end if
    end do
    is = 0
    if (model%physics%ecmwf_physics%lbud23) is = 26
    budget_planes = 0
    if (model%physics%cloud%lcldbud_vertint) then
      if (klev < 45 .or. kfldx < 1) return
      is = is + 1
    end if
    if (model%physics%cloud%lcldbudc) then
      if (is + 5 > kfldx) return
      budget_planes(1) = is + 5
      is = is + 12
    end if
    if (model%physics%cloud%lcldbudl) then
      if (is + 6 > kfldx) return
      budget_planes(2) = is + 6
      is = is + 22
    end if
    if (model%physics%cloud%lcldbudi) then
      if (is + 6 > kfldx) return
      budget_planes(3) = is + 6
    end if
    if (kfldx > 0) then
      if (.not. fits3(pextra, klon, klev, kfldx)) return
    end if
    ! Every saved constituent store precedes every returned-rate read, retaining
    ! the source result when two active constituents share one MPSLP slot.
    do k = 1, klev
      weight = 1.0_real64 - rslwx(k)
      do j = 1, kfdia
        a = pcenu(j, k) - pvfu(j, k); a = a - pdynu(j, k); psavtend(j, k, 1) = a
        a = pcenv(j, k) - pvfv(j, k); a = a - pdynv(j, k); psavtend(j, k, 2) = a
        a = pcent(j, k) - pvft(j, k); a = a - pdynt(j, k); a = a - psatt(j, k); psavtend(j, k, 3) = a
        if (slots(1) /= 0) then
          a = pcenq(j, k) - pvfq(j, k)
          a = a - pdynq(j, k)
          a = a - psatq(j, k)
          pgflslp(j, k, slots(1)) = a
        end if
        if (slots(2) /= 0) then
          a = pcena(j, k) - pvfa(j, k)
          a = a - pdyna(j, k)
          a = a - psata(j, k)
          pgflslp(j, k, slots(2)) = a
        end if
        if (slots(3) /= 0) then
          a = pcencld(j, k, 1) - pdyncld(j, k, 1)
          a = a - psatcld(j, k, 1)
          pgflslp(j, k, slots(3)) = a
        end if
        if (slots(4) /= 0) then
          a = pcencld(j, k, 2) - pdyncld(j, k, 2)
          a = a - psatcld(j, k, 2)
          pgflslp(j, k, slots(4)) = a
        end if
        if (slots(5) /= 0) then
          a = pcencld(j, k, 3) - pdyncld(j, k, 3)
          pgflslp(j, k, slots(5)) = a
        end if
        if (slots(6) /= 0) then
          a = pcencld(j, k, 4) - pdyncld(j, k, 4)
          pgflslp(j, k, slots(6)) = a
        end if
        if (slots(7) /= 0) then
          a = pceno3(j, k) - pdyno3(j, k)
          pgflslp(j, k, slots(7)) = a
        end if
        a = negative_switch*psavtend(j, k, 1); b = inverse_time*pphtenu(j, k); a = a + b
        ptenu(j, k) = weight*a
        a = negative_switch*psavtend(j, k, 2); b = inverse_time*pphtenv(j, k); a = a + b
        ptenv(j, k) = weight*a
        a = negative_switch*psavtend(j, k, 3); b = inverse_time*pphtent(j, k); a = a + b
        ptent(j, k) = weight*a
        if (slots(1) /= 0) then
          a = negative_switch*pgflslp(j, k, slots(1))
          b = inverse_time*pphtengfl(j, k, slots(1)); a = a + b
          ptenq(j, k) = weight*a
        else
          ptenq(j, k) = 0.0_real64
        end if
        if (slots(2) /= 0) then
          a = negative_switch*pgflslp(j, k, slots(2))
          b = inverse_time*pphtengfl(j, k, slots(2)); a = a + b
          ptena(j, k) = weight*a
        else
          ptena(j, k) = 0.0_real64
        end if
        if (slots(3) /= 0) then
          a = negative_switch*pgflslp(j, k, slots(3))
          b = inverse_time*pphtengfl(j, k, slots(3)); a = a + b
          ptencld(j, k, 1) = weight*a
        else
          ptencld(j, k, 1) = 0.0_real64
        end if
        if (slots(4) /= 0) then
          a = negative_switch*pgflslp(j, k, slots(4))
          b = inverse_time*pphtengfl(j, k, slots(4)); a = a + b
          ptencld(j, k, 2) = weight*a
        else
          ptencld(j, k, 2) = 0.0_real64
        end if
        if (slots(5) /= 0) then
          a = negative_switch*pgflslp(j, k, slots(5))
          b = inverse_time*pphtengfl(j, k, slots(5)); a = a + b
          ptencld(j, k, 3) = weight*a
        else
          ptencld(j, k, 3) = 0.0_real64
        end if
        if (slots(6) /= 0) then
          a = negative_switch*pgflslp(j, k, slots(6))
          b = inverse_time*pphtengfl(j, k, slots(6)); a = a + b
          ptencld(j, k, 4) = weight*a
        else
          ptencld(j, k, 4) = 0.0_real64
        end if
        if (slots(7) /= 0) then
          a = negative_switch*pgflslp(j, k, slots(7))
          b = inverse_time*pphtengfl(j, k, slots(7)); a = a + b
          pteno3(j, k) = weight*a
        else
          pteno3(j, k) = 0.0_real64
        end if
      end do
    end do
    if (cloud_top > klev) then
      status = 0; return
    end if
    ! Eight P-element rows are activated only after all shape/control checks.
    block
      real(real64) :: work(klon, 8)
      do k = cloud_top, klev
        do j = 1, kfdia
          a = pcent(j, k) + ptent(j, k); a = timestep*a
          work(j, 1) = pt(j, k) + a
          a = pcenq(j, k) + ptenq(j, k); a = timestep*a
          work(j, 2) = pq(j, k) + a
          a = pcena(j, k) + ptena(j, k); a = timestep*a
          work(j, 3) = pa(j, k) + a
        end do
        call cloud_supersatcheck(physical, thermal, model%physics%cloud, 1_int32, kfdia, klon, klev, 1_int32, &
                                 work(:, 1), work(:, 2), work(:, 3), prsf1(:, k), prs1(:, klev + 1), &
                                 work(:, 4), work(:, 5), work(:, 6), work(:, 7), work(:, 8))
        do j = 1, kfdia
          a = work(j, 4)*inverse_time; ptent(j, k) = ptent(j, k) + a
          a = work(j, 5)*inverse_time; ptenq(j, k) = ptenq(j, k) + a
          a = work(j, 6)*inverse_time; ptena(j, k) = ptena(j, k) + a; work(j, 6) = a
          a = work(j, 7)*inverse_time; ptencld(j, k, 1) = ptencld(j, k, 1) + a; work(j, 7) = a
          a = work(j, 8)*inverse_time; ptencld(j, k, 2) = ptencld(j, k, 2) + a; work(j, 8) = a
          if (model%physics%cloud%lcldbud_vertint) then
            delta_pressure = prs1(j, k + 1) - prs1(j, k)
            a = physical%rd*pt(j, k); density = prsf1(j, k)/a
            a = density*physical%rg; depth = delta_pressure/a
            a = work(j, 6)*depth; pextra(j, 5, 1) = pextra(j, 5, 1) + a
            a = work(j, 7)*depth; pextra(j, 20, 1) = pextra(j, 20, 1) + a
            a = work(j, 8)*depth; pextra(j, 45, 1) = pextra(j, 45, 1) + a
          end if
          if (budget_planes(1) /= 0) then
            position = budget_planes(1)
            pextra(j, k, position) = pextra(j, k, position) + work(j, 6)
          end if
          if (budget_planes(2) /= 0) then
            position = budget_planes(2)
            pextra(j, k, position) = pextra(j, k, position) + work(j, 7)
          end if
          if (budget_planes(3) /= 0) then
            position = budget_planes(3)
            pextra(j, k, position) = pextra(j, k, position) + work(j, 8)
          end if
        end do
      end do
    end block
    status = 0
  end subroutine
  !> Admit only actual contiguous native shapes; the compiler owns descriptors.
  logical function fits2(array, n1, n2) result(valid)
    real(real64), intent(in) :: array(:, :)
    integer, intent(in) :: n1, n2
    valid = is_contiguous(array) .and. size(array, 1) == n1 .and. size(array, 2) == n2
  end function
  logical function fits3(array, n1, n2, n3) result(valid)
    real(real64), intent(in) :: array(:, :, :)
    integer, intent(in) :: n1, n2, n3
    valid = is_contiguous(array) .and. size(array, 1) == n1 .and. size(array, 2) == n2 .and. size(array, 3) == n3
  end function
  !> Use input bits for finite-positive admission without arithmetic probes.
  logical function positive_finite(value) result(valid)
    real(real64), intent(in) :: value
    integer(int64) :: word
    word = transfer(value, word)
    valid = word > 0_int64 .and. word < int(z'7ff0000000000000', int64)
  end function
  logical function unit_interval(value) result(valid)
    real(real64), intent(in) :: value
    integer(int64) :: word, magnitude
    word = transfer(value, word); magnitude = iand(word, int(z'7fffffffffffffff', int64))
    valid = magnitude <= int(z'3ff0000000000000', int64)
    if (btest(word, 63) .and. magnitude /= 0_int64) valid = .false.
  end function
end module forecast_slow_physics_averaging

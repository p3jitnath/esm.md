!> Native convection initial state, including its owned environment child.
module convective_initial_state_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use yoephli, only: tephli
  use yoecumf, only: tecumf
  use saturation_humidity_mod, only: ordered_minimum, numeric_maximum, valid_real_matrix
  use convective_environment_mod, only: cuinin_environment
  implicit none
  private
  public :: cuinin
contains
  !> Initialise half-level and plume fields in original selected cell order.
  !! Readonly providers precede all27 original CUININ arguments. Native
  !! TEPHLI/TECUMF supply LPHYLIN/NJKT2 by name. KLON and KLEV are positive,
  !! with an empty or valid KIDIA:KFDIA interval. Layer arrays have first
  !! extent KLON and at least KLEV levels; PAPH and PGEOH have KLEV+1.
  !! PTEN is K, PQEN/PQSEN kg/kg, winds m/s, geopotential m2/s2 and PAPH Pa.
  !! All views are contiguous, and writable owners are mutually disjoint
  !! and disjoint from readonly inputs. The caller provides the admitted
  !! physical/missing domain and floating environment. No mode probe runs.
  !! All outputs are INOUT so inactive columns and untouched boundaries keep
  !! their bytes. Return0 after completion/empty interval, otherwise2
  !! before writes for metadata, linear-physics or scratch-bound refusal.
  !! Compiler stack arrays activate only after the original one-MiB bound.
  function cuinin(constants, thermal, ydephli, ydecumf, kidia, kfdia, klon, klev, &
                  pten, pqen, pqsen, puen, pven, pgeo, paph, klab, ptenh, pqenh, pqsenh, pgeoh, &
                  ptu, pqu, ptd, pqd, puu, pvu, pud, pvd, plu) result(status)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(tephli), intent(in) :: ydephli
    type(tecumf), intent(in) :: ydecumf
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev
    real(c_double), intent(in) :: pten(:, :), pqen(:, :), pqsen(:, :), puen(:, :), pven(:, :), pgeo(:, :), paph(:, :), pgeoh(:, :)
    integer(c_int), intent(inout) :: klab(:, :)
    real(c_double), intent(inout) :: ptenh(:, :), pqenh(:, :), pqsenh(:, :), ptu(:, :), pqu(:, :), ptd(:, :), pqd(:, :)
    real(c_double), intent(inout) :: puu(:, :), pvu(:, :), pud(:, :), pvd(:, :), plu(:, :)
    integer(c_int) :: status, jl, jk, ik, child_status
    integer(c_int64_t) :: scratch_bytes
    real(c_double) :: inverse_cp, w0, w1, w2
    real(c_double), volatile :: boundary_value
    status = 2_c_int
    if (ydephli%lphylin) return
    if (klon < 1 .or. klev < 1 .or. klev == huge(klev)) return
    if (kidia < 1 .or. kidia > klon + 1 .or. kfdia < 0 .or. kfdia > klon) return
    if (.not. valid_real_matrix(pten, klon, klev)) return
    if (.not. valid_real_matrix(pqen, klon, klev)) return
    if (.not. valid_real_matrix(pqsen, klon, klev)) return
    if (.not. valid_real_matrix(puen, klon, klev)) return
    if (.not. valid_real_matrix(pven, klon, klev)) return
    if (.not. valid_real_matrix(pgeo, klon, klev)) return
    if (.not. valid_real_matrix(paph, klon, klev + 1)) return
    if (.not. valid_real_matrix(pgeoh, klon, klev + 1)) return
    if (.not. is_contiguous(klab) .or. size(klab, 1) /= klon .or. size(klab, 2) < klev) return
    if (.not. valid_real_matrix(ptenh, klon, klev)) return
    if (.not. valid_real_matrix(pqenh, klon, klev)) return
    if (.not. valid_real_matrix(pqsenh, klon, klev)) return
    if (.not. valid_real_matrix(ptu, klon, klev)) return
    if (.not. valid_real_matrix(pqu, klon, klev)) return
    if (.not. valid_real_matrix(ptd, klon, klev)) return
    if (.not. valid_real_matrix(pqd, klon, klev)) return
    if (.not. valid_real_matrix(puu, klon, klev)) return
    if (.not. valid_real_matrix(pvu, klon, klev)) return
    if (.not. valid_real_matrix(pud, klon, klev)) return
    if (.not. valid_real_matrix(pvd, klon, klev)) return
    if (.not. valid_real_matrix(plu, klon, klev)) return
    status = 0_c_int
    if (kidia > kfdia) return
    scratch_bytes = iand(12_c_int64_t*int(klon, c_int64_t) + 47_c_int64_t, -16_c_int64_t)
    if (scratch_bytes > 1048576_c_int64_t) then
      status = 2_c_int
      return
    end if
    block
      real(c_double) :: zph(klon)
      logical :: llflag(klon)
      inverse_cp = 1.0_c_double/constants%rcpd
      do jk = 2, klev
        do jl = kidia, kfdia
          w0 = constants%rcpd*pten(jl, jk - 1)
          w1 = constants%rcpd*pten(jl, jk)
          w0 = w0 + pgeo(jl, jk - 1)
          w1 = w1 + pgeo(jl, jk)
          w0 = numeric_maximum(w0, w1)
          w0 = w0 - pgeoh(jl, jk)
          ptenh(jl, jk) = w0*inverse_cp
          pqenh(jl, jk) = pqen(jl, jk - 1)
          pqsenh(jl, jk) = pqsen(jl, jk - 1)
          zph(jl) = paph(jl, jk)
          llflag(jl) = .true.
        end do
        if (jk >= klev - 1 .or. jk < ydecumf%njkt2) cycle
   child_status = cuinin_environment(constants, thermal, ydephli, kidia, kfdia, klon, klev, jk, zph, ptenh, pqsenh, llflag, 3_c_int)
        if (child_status /= 0_c_int) then
          status = child_status
          return
        end if
        do jl = kidia, kfdia
          w0 = ordered_minimum(pqen(jl, jk - 1), pqsen(jl, jk - 1))
          w2 = pqsenh(jl, jk) - pqsen(jl, jk - 1)
          w0 = w0 + w2
          pqenh(jl, jk) = numeric_maximum(w0, 0.0_c_double)
        end do
      end do
      do jl = kidia, kfdia
        w0 = constants%rcpd*pten(jl, klev)
        w0 = w0 + pgeo(jl, klev)
        w0 = w0 - pgeoh(jl, klev)
        ! The one-layer upper copy follows this complete bottom calculation.
        boundary_value = w0*inverse_cp
        ptenh(jl, klev) = boundary_value
        pqenh(jl, klev) = pqen(jl, klev)
        ptenh(jl, 1) = pten(jl, 1)
        pqenh(jl, 1) = pqen(jl, 1)
      end do
      do jk = 1, klev
        ik = jk - 1
        if (jk == 1) ik = 1
        do jl = kidia, kfdia
          ptu(jl, jk) = ptenh(jl, jk)
          ptd(jl, jk) = ptenh(jl, jk)
          pqu(jl, jk) = pqenh(jl, jk)
          pqd(jl, jk) = pqenh(jl, jk)
          plu(jl, jk) = 0.0_c_double
          klab(jl, jk) = 0_c_int
          puu(jl, jk) = puen(jl, ik)
          pud(jl, jk) = puen(jl, ik)
          pvu(jl, jk) = pven(jl, ik)
          pvd(jl, jk) = pven(jl, ik)
        end do
      end do
    end block
  end function
end module convective_initial_state_mod

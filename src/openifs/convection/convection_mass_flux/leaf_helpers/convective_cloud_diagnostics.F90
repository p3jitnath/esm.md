!> Accumulate or replace convective rain and cloud-level diagnostics.
module convection_cloud_diagnostics_mod
  use iso_c_binding, only: c_double, c_int, c_int64_t
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use convection_leaf_contract_mod, only: require, real_matrix, real_vector
  use yoerad, only: terad
  use yoephli, only: tephli
  use yoephy, only: tephy
  use saturation_humidity_mod, only: numeric_maximum
  implicit none
  private
  public :: cuccdia, cuccdia_raw
  interface cuccdia_raw
    module procedure cuccdia
  end interface
contains
  !> Keep original gates, signed integer remainder and ordered water flux.
  !! Native configuration records remain readonly. After providers all18
  !! original arguments retain order. Layer humidity is kg/kg, mass/rain
  !! flux kg/(m2 s); diagnostic indices are one-based. Contiguous arrays
  !! have at least their declared KLON/KLEV capacities. Caller admits all
  !! used indices, finite physical values, disjoint outputs and FP mode.
  subroutine cuccdia(constants, thermal, yderad, ydephli, ydephy, kidia, kfdia, klon, klev, kstep, kcbot, kctop, &
                     ldcum, pqu, plu, pmfu, prain, parprc, ktopc, kbasec)
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    type(terad), intent(in) :: yderad
    type(tephli), intent(in) :: ydephli
    type(tephy), intent(in) :: ydephy
    integer(c_int), intent(in) :: kidia, kfdia, klon, klev, kstep, kcbot(:), kctop(:)
    logical, intent(in) :: ldcum(:)
    real(c_double), intent(in) :: pqu(:, :), plu(:, :), pmfu(:, :), prain(:)
    real(c_double), intent(inout) :: parprc(:)
    integer(c_int), intent(inout) :: ktopc(:), kbasec(:)
    integer(c_int) :: jl, base, top, new_top
    logical :: accumulating
    real(c_double), volatile :: weight
    real(c_double) :: qbase, w0, w1, w2
    real(c_double), parameter :: five_percent = transfer(int(z'3fa999999999999a', c_int64_t), 0.0_c_double)
    call require(klon >= 0 .and. klon <= 4096 .and. klev >= 0 .and. klev <= 512)
    call require(kidia >= 1 .and. kfdia >= kidia - 1 .and. kfdia <= klon)
    if (.not. ydephy%lecumf) return
    accumulating = .false.
    if (.not. ydephli%lphylin .and. yderad%nradfr /= 1) then
      call require(yderad%nradfr /= 0 .and. kstep >= 0 .and. kstep <= huge(kstep) - 1)
      if (.not. ydephy%leradi) return
      if (mod(kstep + 1, yderad%nradfr) == 0) return
      weight = 1.0_c_double/real(max(yderad%nradfr - 1, 1_c_int), c_double)
      accumulating = .true.
    end if
    if (kidia > kfdia) return
    call require(is_contiguous(kcbot) .and. size(kcbot) >= klon .and. is_contiguous(kctop) .and. size(kctop) >= klon)
    call require(is_contiguous(ldcum) .and. size(ldcum) >= klon)
    call require(is_contiguous(ktopc) .and. size(ktopc) >= klon .and. is_contiguous(kbasec) .and. size(kbasec) >= klon)
    call real_matrix(pqu, klon, klev); call real_matrix(plu, klon, klev); call real_matrix(pmfu, klon, klev)
    call real_vector(prain, klon); call real_vector(parprc, klon)
    do jl = kidia, kfdia
      if (.not. ldcum(jl)) cycle
      base = kcbot(jl); top = kctop(jl)
      call require(top >= 1 .and. base >= top .and. base <= klev)
      if (accumulating) then
        kbasec(jl) = max(kbasec(jl), base)
        new_top = min(ktopc(jl), top)
        if (new_top == 1) new_top = top
        ktopc(jl) = new_top
      else
        kbasec(jl) = base; ktopc(jl) = top
      end if
      qbase = pqu(jl, base)
      w2 = qbase*five_percent
      w0 = qbase + plu(jl, base)
      w0 = w0 - pqu(jl, top)
      w0 = numeric_maximum(w0, w2)
      w0 = w0*pmfu(jl, base)
      w0 = numeric_maximum(w0, prain(jl))
      if (accumulating) then
        w0 = w0*weight
        w0 = parprc(jl) + w0
      end if
      parprc(jl) = w0
    end do
  end subroutine
end module

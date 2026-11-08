!> Select complete native wave-model fields from actual registry block views.
module md2asm_typed_wave_surface_fields
  use iso_fortran_env, only: int32, real64
  use physical_constant_setup_port, only: forecast_physical_constants
  use forecast_physics_work_types, only: dimension_type, aux_type, flux_type, surf_and_more_type
  use forecast_native_field_variable_types, only: native_surface_variables
  use forecast_registry_field_types, only: native_registry_variable_3d
  use md2asm_wave_surface_fields, only: calculate_runtime_wave_surface_fields
  implicit none
  private
  public :: wave_surface_controls, prepare_runtime_wave_surface_fields
!> Borrow the actual source controls; no field storage or model copy is owned here.
  type :: wave_surface_controls
    logical :: enabled = .false., neutral_winds = .false., return_currents = .false.
    integer(int32) :: mode = 0
    real(real64) :: missing = 0.0_real64
  end type
contains
!> Select the bottom level, ocean tile1 and named native registry fields.
!! DIMENSION supplies columns1:128 and levels6:137. T%PH9 is K and Q%T9
!! is kg/kg. AUX pressure is Pa. SURFACE carries the selected native block
!! views, already bound by the field registry, without old member indices.
!! Output fields are U10N/V10N in m/s, RHO in kg/m3, gust in m/s, fractions
!! and optional currents in m/s. Only the inclusive active columns change.
!! False ENABLED returns before inspecting other fields. Metadata refusal2
!! preserves every payload; child status and natural FP flags are forwarded.
  subroutine prepare_runtime_wave_surface_fields(dim, controls, surface, aux, t, q, surfwork, flux, physical, status)
    type(dimension_type), intent(in) :: dim
    type(wave_surface_controls), intent(in) :: controls
    type(native_surface_variables), intent(inout) :: surface
    type(aux_type), intent(in) :: aux
    type(native_registry_variable_3d), intent(in) :: t, q
    type(surf_and_more_type), intent(in) :: surfwork
    type(flux_type), intent(in) :: flux
    type(forecast_physical_constants), intent(in) :: physical
    integer(int32), intent(out) :: status
    real(real64), pointer :: su(:), sv(:), nu(:), nv(:), cu(:), cv(:), z0(:), outu(:), outv(:)
    integer :: p, l
    status = 0
    if (.not. controls%enabled) return
    status = 2; p = dim%klon; l = dim%klev
    if (p < 1 .or. p > 128 .or. l < 6 .or. l > 137) return
    if (dim%kidia < 1 .or. dim%kfdia < dim%kidia .or. dim%kfdia > p) return
    if (controls%mode < 1 .or. controls%mode > 3) return
    if (.not. associated(aux%paprsf) .or. .not. associated(t%ph9) .or. .not. associated(q%t9)) return
    if (.not. matrix_has(aux%paprsf, p, l) .or. .not. matrix_has(t%ph9, p, l) .or. .not. matrix_has(q%t9, p, l)) return
    if (.not. associated(flux%pdiftq) .or. .not. associated(flux%pdifts)) return
    if (.not. matrix_has(flux%pdiftq, p, l) .or. .not. matrix_has(flux%pdifts, p, l)) return
    if (.not. associated(surface%gsd_ww%vu10n%p) .or. .not. associated(surface%gsd_ww%vv10n%p)) return
    if (.not. associated(surface%gsd_ww%vrho%p) .or. .not. associated(surface%gsd_ww%vzil%p)) return
    if (.not. associated(surface%gsd_ww%vcif%p) .or. .not. associated(surface%gsd_ww%vclk%p)) return
    if (.not. associated(surface%gsd_vf%vlsm%p) .or. .not. associated(surface%gsd_vf%vci%p)) return
    if (.not. associated(surface%gsd_vf%vclk%p)) return
    nullify (su, sv, nu, nv, cu, cv, z0, outu, outv)
    if (controls%mode /= 3 .or. .not. controls%neutral_winds) then
      if (.not. associated(surfwork%pustrti) .or. .not. associated(surfwork%pvstrti)) return
      if (.not. matrix_has(surfwork%pustrti, p, 1) .or. .not. matrix_has(surfwork%pvstrti, p, 1)) return
      su => surfwork%pustrti(:, 1); sv => surfwork%pvstrti(:, 1)
    end if
    if (controls%mode == 3 .and. controls%neutral_winds) then
      if (.not. associated(surface%gsd_vd%v10nu%p) .or. .not. associated(surface%gsd_vd%v10nv%p)) return
      nu => surface%gsd_vd%v10nu%p; nv => surface%gsd_vd%v10nv%p
    end if
    if (controls%return_currents .or. (controls%mode == 3 .and. controls%neutral_winds)) then
      if (.not. associated(surface%gsd_vf%vucur%p) .or. .not. associated(surface%gsd_vf%vvcur%p)) return
      cu => surface%gsd_vf%vucur%p; cv => surface%gsd_vf%vvcur%p
    end if
    if (controls%mode == 3 .and. .not. controls%neutral_winds) then
      if (.not. associated(surface%gsd_vd%vz0f%p)) return
      z0 => surface%gsd_vd%vz0f%p
    end if
    if (controls%return_currents) then
      if (.not. associated(surface%gsd_ww%vucurw%p) .or. .not. associated(surface%gsd_ww%vvcurw%p)) return
      outu => surface%gsd_ww%vucurw%p; outv => surface%gsd_ww%vvcurw%p
    end if
    call calculate_runtime_wave_surface_fields(physical, dim%klon, dim%kidia, dim%kfdia, controls%mode, &
                    controls%neutral_winds, controls%return_currents, controls%missing, aux%paprsf(:, l), t%ph9(:, l), q%t9(:, l), &
                                     surface%gsd_ww%vu10n%p, surface%gsd_ww%vv10n%p, surface%gsd_ww%vrho%p, surface%gsd_ww%vzil%p, &
                                               surface%gsd_ww%vcif%p, surface%gsd_ww%vclk%p, flux%pdiftq(:, l), flux%pdifts(:, l), &
                                               surface%gsd_vf%vlsm%p, surface%gsd_vf%vci%p, surface%gsd_vf%vclk%p, status, &
                                               su, sv, nu, nv, cu, cv, z0, outu, outv)
  end subroutine
!> Check selected logical rows and their source level before slicing.
  logical function matrix_has(a, p, k)
    real(real64), intent(in) :: a(:, :)
    integer, intent(in) :: p, k
    matrix_has = size(a, 1) >= p .and. size(a, 2) >= k
  end function
end module

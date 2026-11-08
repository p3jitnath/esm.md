!> Borrow named native weight views from complete retained field owners.
!! The plane-map producer supplies every field start. This module reshapes
!! native contiguous storage only;it calculates no interpolation value.
module md2asm_interpolation_weight_views
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_internal_interpolation_plane_maps, only: interpolation_plane_controls, &
                                                      linear_weight_plane_map, nonlinear_weight_plane_map
  use md2asm_departure_interpolation_weights, only: departure_weight_outputs
  implicit none
  private
  public :: bind_interpolation_weight_views
contains
  !> Bind one full-level block without moving or changing any field byte.
  !! linear and nonlinear are complete real64(pitch,levels,plane) owners.
  !! Their plane counts cover the corresponding NDIM. The caller keeps
  !! those TARGET owners alive and fixed while any returned view is used.
  !! Indices are native int32(pitch,levels,4) or(pitch,levels). They are
  !! writable borrowed owners,disjoint from real fields and consumed inputs.
  !! controls and both maps come from the same initialized native SUINTDYNSL.
  !! spline and hermite are that producer's actual full-level selections.
  !! Map starts count real planes,never bytes. Each three-coefficient group
  !! and pair of central longitude circles retain their native storage order.
  !! Optional inactive output families remain absent. Source-declared heat
  !! aliases are exposed only when the heat family is active and separate.
  !! Status2 leaves weights and all field bytes unchanged on invalid bounds
  !! or noncontiguous horizontal map sequences;status0 publishes the views.
  !! It performs no allocation or FP arithmetic. Each consuming child still
  !! enforces its own supported slot,shape,control and arithmetic domain.
  subroutine bind_interpolation_weight_views(pitch, levels, controls, spline, hermite, linear_map, nonlinear_map, &
                                     linear, nonlinear, parent_index, horizontal_index, vertical_index, weno_shift, weights, status)
    integer(int32), intent(in) :: pitch, levels
    type(interpolation_plane_controls), intent(in) :: controls
    logical, intent(in) :: spline, hermite
    type(linear_weight_plane_map), intent(in) :: linear_map
    type(nonlinear_weight_plane_map), intent(in) :: nonlinear_map
    real(real64), contiguous, target, intent(inout) :: linear(:, :, :), nonlinear(:, :, :)
    integer(int32), contiguous, target, intent(inout) :: parent_index(:, :, :), horizontal_index(:, :, :)
    integer(int32), contiguous, target, intent(inout) :: vertical_index(:, :), weno_shift(:, :)
    type(departure_weight_outputs), intent(inout) :: weights
    integer(int32), intent(out) :: status
    type(departure_weight_outputs) :: bound
    real(real64), pointer, contiguous :: flat(:)
    integer(int64) :: cells, first, last
    integer(int32) :: slots, windows, filtered_windows
    integer :: j
    logical :: weno
    status = 2
    if (pitch < 1 .or. pitch > 1024 .or. levels < 4 .or. levels > 256) return
    slots = controls%nsldimk
    if (slots < 1 .or. slots > 4) return
    if (size(linear, 1) /= pitch .or. size(linear, 2) /= levels) return
    if (size(nonlinear, 1) /= pitch .or. size(nonlinear, 2) /= levels) return
    if (linear_map%ndim /= 12 .or. linear_map%ndim > size(linear, 3)) return
    if (nonlinear_map%ndim < 1 .or. nonlinear_map%ndim > 256 .or. nonlinear_map%ndim > size(nonlinear, 3)) return
    if (size(parent_index, 1) /= pitch .or. size(parent_index, 2) /= levels .or. size(parent_index, 3) /= 4) return
    if (size(horizontal_index, 1) /= pitch .or. size(horizontal_index, 2) /= levels .or. size(horizontal_index, 3) /= 4) return
    if (size(vertical_index, 1) /= pitch .or. size(vertical_index, 2) /= levels) return
    if (size(weno_shift, 1) /= pitch .or. size(weno_shift, 2) /= levels) return
    if (.not. within(linear_map%m_wdlo, 4, linear_map%ndim)) return
    if (.not. within(linear_map%m_wdlat, 1, linear_map%ndim)) return
    if (.not. within(linear_map%m_wdver, 1, linear_map%ndim)) return
    if (.not. within(linear_map%m_wdlomad, 4, linear_map%ndim)) return
    if (.not. within(linear_map%m_wdlamad, 1, linear_map%ndim)) return
    if (.not. within(linear_map%m_wdvermad, 1, linear_map%ndim)) return
    do j = 1, slots
      if (int(nonlinear_map%m_wclo(j), int64) /= int(nonlinear_map%m_wclo(1), int64) + 6_int64*int(j - 1, int64)) return
      if (int(nonlinear_map%m_wcla(j), int64) /= int(nonlinear_map%m_wcla(1), int64) + 3_int64*int(j - 1, int64)) return
      if (int(nonlinear_map%m_wclosld(j), int64) /= int(nonlinear_map%m_wclosld(1), int64) + 6_int64*int(j - 1, int64)) return
      if (int(nonlinear_map%m_wclasld(j), int64) /= int(nonlinear_map%m_wclasld(1), int64) + 3_int64*int(j - 1, int64)) return
      if (int(nonlinear_map%m_wclomad(j), int64) /= int(nonlinear_map%m_wclomad(1), int64) + 6_int64*int(j - 1, int64)) return
      if (int(nonlinear_map%m_wclamad(j), int64) /= int(nonlinear_map%m_wclamad(1), int64) + 3_int64*int(j - 1, int64)) return
    end do
    if (.not. within(nonlinear_map%m_wclo(1), 6*slots, nonlinear_map%ndim)) return
    if (.not. within(nonlinear_map%m_wcla(1), 3*slots, nonlinear_map%ndim)) return
    if (.not. within(nonlinear_map%m_wclosld(1), 6*slots, nonlinear_map%ndim)) return
    if (.not. within(nonlinear_map%m_wclasld(1), 3*slots, nonlinear_map%ndim)) return
    if (.not. within(nonlinear_map%m_wclomad(1), 6*slots, nonlinear_map%ndim)) return
    if (.not. within(nonlinear_map%m_wclamad(1), 3*slots, nonlinear_map%ndim)) return
    weno = controls%lsltvweno .or. controls%lrhsvweno
    windows = 1
    if (weno) windows = 3
    filtered_windows = 1
    if (controls%lrhsvweno .and. controls%lvweno_t) filtered_windows = 3
    if (.not. within(nonlinear_map%m_wvintw, 3*windows, nonlinear_map%ndim)) return
    if (.not. within(nonlinear_map%m_wvintwsld, 3, nonlinear_map%ndim)) return
    if (.not. within(nonlinear_map%m_wvintwmad, 3, nonlinear_map%ndim)) return
    if (controls%lslhdheat) then
      if (.not. within(nonlinear_map%m_wcloslt, 6, nonlinear_map%ndim)) return
      if (.not. within(nonlinear_map%m_wclaslt, 3, nonlinear_map%ndim)) return
      if (.not. within(nonlinear_map%m_wvintwslt, 3, nonlinear_map%ndim)) return
    end if
    if (controls%lslvf) then
      if (.not. within(nonlinear_map%m_wvintwslvf, 3*filtered_windows, nonlinear_map%ndim)) return
    end if
    if (spline) then
      if (.not. within(nonlinear_map%m_wvintws, 4, nonlinear_map%ndim)) return
    end if
    if (hermite) then
      if (.not. within(nonlinear_map%m_whvw, 4, nonlinear_map%ndim)) return
      if (.not. within(nonlinear_map%m_wvderw, 4, nonlinear_map%ndim)) return
    end if
    if (weno) then
      if (.not. within(nonlinear_map%m_cw, 3, nonlinear_map%ndim)) return
    end if
    bound%latitude_fraction => linear(:, :, linear_map%m_wdlat)
    bound%latitude_correction_fraction => linear(:, :, linear_map%m_wdlamad)
    bound%longitude_fraction => linear(:, :, linear_map%m_wdlo:linear_map%m_wdlo + 3)
    bound%longitude_correction_fraction => linear(:, :, linear_map%m_wdlomad:linear_map%m_wdlomad + 3)
    bound%vertical_fraction => linear(:, :, linear_map%m_wdver)
    bound%vertical_correction_fraction => linear(:, :, linear_map%m_wdvermad)
    bound%parent_index => parent_index
    bound%horizontal_index => horizontal_index
    bound%vertical_index => vertical_index
    bound%weno_shift => weno_shift
    cells = int(pitch, int64)*int(levels, int64)
    flat(1:size(nonlinear, kind=int64)) => nonlinear
    first = (int(nonlinear_map%m_wcla(1), int64) - 1)*cells + 1
    last = first + cells*3_int64*int(slots, int64) - 1
    bound%latitude_main(1:pitch, 1:levels, 1:3, 1:slots) => flat(first:last)
    first = (int(nonlinear_map%m_wclasld(1), int64) - 1)*cells + 1
    last = first + cells*3_int64*int(slots, int64) - 1
    bound%latitude_filtered(1:pitch, 1:levels, 1:3, 1:slots) => flat(first:last)
    first = (int(nonlinear_map%m_wclamad(1), int64) - 1)*cells + 1
    last = first + cells*3_int64*int(slots, int64) - 1
    bound%latitude_correction(1:pitch, 1:levels, 1:3, 1:slots) => flat(first:last)
    first = (int(nonlinear_map%m_wclo(1), int64) - 1)*cells + 1
    last = first + cells*6_int64*int(slots, int64) - 1
    bound%longitude_main(1:pitch, 1:levels, 1:3, 1:2, 1:slots) => flat(first:last)
    first = (int(nonlinear_map%m_wclosld(1), int64) - 1)*cells + 1
    last = first + cells*6_int64*int(slots, int64) - 1
    bound%longitude_filtered(1:pitch, 1:levels, 1:3, 1:2, 1:slots) => flat(first:last)
    first = (int(nonlinear_map%m_wclomad(1), int64) - 1)*cells + 1
    last = first + cells*6_int64*int(slots, int64) - 1
    bound%longitude_correction(1:pitch, 1:levels, 1:3, 1:2, 1:slots) => flat(first:last)
    bound%vertical_main => nonlinear(:, :, nonlinear_map%m_wvintw:nonlinear_map%m_wvintw + 3*windows - 1)
    bound%vertical_diffusion => nonlinear(:, :, nonlinear_map%m_wvintwsld:nonlinear_map%m_wvintwsld + 2)
    bound%vertical_correction => nonlinear(:, :, nonlinear_map%m_wvintwmad:nonlinear_map%m_wvintwmad + 2)
    if (controls%lslhdheat) then
      bound%latitude_heat => nonlinear(:, :, nonlinear_map%m_wclaslt:nonlinear_map%m_wclaslt + 2)
      first = (int(nonlinear_map%m_wcloslt, int64) - 1)*cells + 1
      last = first + cells*6_int64 - 1
      bound%longitude_heat(1:pitch, 1:levels, 1:3, 1:2) => flat(first:last)
      bound%vertical_heat => nonlinear(:, :, nonlinear_map%m_wvintwslt:nonlinear_map%m_wvintwslt + 2)
    end if
    if (controls%lslvf) bound%vertical_filtered => nonlinear(:, :, &
                                                     nonlinear_map%m_wvintwslvf:nonlinear_map%m_wvintwslvf + 3*filtered_windows - 1)
    if (spline) bound%spline_weight => nonlinear(:, :, nonlinear_map%m_wvintws:nonlinear_map%m_wvintws + 3)
    if (hermite) then
      bound%hermite_value => nonlinear(:, :, nonlinear_map%m_whvw:nonlinear_map%m_whvw + 3)
      first = (int(nonlinear_map%m_wvderw, int64) - 1)*cells + 1
      last = first + cells*4_int64 - 1
      bound%hermite_derivative(1:pitch, 1:levels, 1:2, 1:2) => flat(first:last)
    end if
    if (weno) bound%weno_combination => nonlinear(:, :, nonlinear_map%m_cw:nonlinear_map%m_cw + 2)
    weights = bound
    status = 0
  end subroutine

  logical function within(first, count, extent)
    integer(int32), intent(in) :: first, count, extent
    within = first >= 1 .and. count >= 1 .and. int(first, int64) + int(count, int64) - 1_int64 <= int(extent, int64)
  end function
end module md2asm_interpolation_weight_views

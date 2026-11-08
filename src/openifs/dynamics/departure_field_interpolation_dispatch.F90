!> Select the complete interpolation stage for a transported atmospheric field.
!! The original names are LAITRE_GMV and LAITRE_GFL. Coefficients and fractions
!! have no unit. Each returned value keeps its input field's unit, such as
!! metres per second for wind or kelvin for temperature.
module md2asm_departure_field_interpolation_dispatch
  use iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
  use md2asm_departure_interpolation_weights, only: departure_weight_outputs
  use md2asm_departure_neighbour_interpolation, only: interpolate_eight_neighbours
  use md2asm_three_dimensional_cubic_departure_interpolation, only: interpolate_thirty_two_neighbours
  use md2asm_bounded_three_dimensional_transport, only: interpolate_bounded_thirty_two_neighbours
  use md2asm_weno_departure_interpolation, only: weno_interpolation_controls, interpolate_weno_departure
  implicit none
  private
  public :: general_field_interpolation_controls
  public :: interpolate_general_model_field, interpolate_constituent_field
  !> Original logical choices and the one-based horizontal weight set.
  !! The exponent controls vertical WENO, which combines nearby polynomial
  !! estimates. alternative_heat_vertical selects the supplied heat filter.
  type :: general_field_interpolation_controls
    integer(int32) :: weight_set = 1
    logical :: linear = .false., modified_advection = .false., horizontal_diffusion = .false.
    logical :: vertical_weno = .false., momentum = .true.
    logical :: limiter_three_dimensional = .false., limiter_horizontal = .false.
    logical :: alternative_heat_vertical = .false.
    real(real64) :: weno_exponent = 0.0_real64
  end type
contains
  !> Interpolate one general model field without changing its inputs.
  !! field(source_pitch,stored_planes) stores logical first_plane:last_plane.
  !! result(pitch,levels) is borrowed writable storage; inactive cells remain
  !! unchanged. weights holds all named coefficient views, with up to four
  !! horizontal sets. Only the selected views are read. The caller establishes
  !! the admitted floating-point mode and separates result from consumed inputs.
  !! Status0 succeeds,1 refuses storage and2 refuses the supported interface.
  subroutine interpolate_general_model_field(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                                             c, weights, field, result, status, weno_control)
    integer(int32), intent(in) :: source_pitch, pitch, first, last, levels, first_plane, last_plane
    type(general_field_interpolation_controls), intent(in) :: c
    type(departure_weight_outputs), intent(in) :: weights
    real(real64), contiguous, target, intent(in) :: field(:, :)
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    type(weno_interpolation_controls), intent(in), optional :: weno_control
    integer(int32) :: family, method, mode, vertical
    family = 0
    vertical = 0
    mode = 0
    if (c%limiter_three_dimensional) then
      mode = 2
    else if (c%limiter_horizontal) then
      mode = 1
    end if
    method = 1
    if (.not. c%momentum .and. c%alternative_heat_vertical) vertical = 4
    if (c%linear) then
      method = 0
      if (c%modified_advection) family = 1
      vertical = family
    else if (c%horizontal_diffusion) then
      family = 2
      if (.not. c%momentum) family = 3
      if (c%vertical_weno) then
        method = 3
        if (c%momentum) vertical = 0
      else
        vertical = family
      end if
    else if (c%modified_advection) then
      family = 1
      vertical = 1
    else if (c%vertical_weno) then
      method = 3
    end if
    call interpolate_selected_field(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
               c%weight_set, family, vertical, method, mode, .false., weights, field, result, status, weno_control, c%weno_exponent)
  end subroutine

  !> Interpolate a constituent, such as water vapour, using its exact selector.
  !! selector must contain12 characters, including spaces. The sixteen frozen
  !! selectors choose ordinary, modified or diffusive coefficients and a complete
  !! owned cubic, bounded cubic or WENO child. Unsupported selectors refuse
  !! before result changes. conserve_vertical affects only the mode2 bounded
  !! child; its genuine half_level_coordinate(0:levels) is then required.
  !! Other shapes, units, ownership and status values match the general entry.
  subroutine interpolate_constituent_field(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                                           selector, weight_set, momentum, conserve_vertical, weights, field, result, status, &
                                           weno_control, weno_exponent, half_level_coordinate)
    integer(int32), intent(in) :: source_pitch, pitch, first, last, levels, first_plane, last_plane, weight_set
    character(len=*), intent(in) :: selector
    logical, intent(in) :: momentum, conserve_vertical
    type(departure_weight_outputs), intent(in) :: weights
    real(real64), contiguous, target, intent(in) :: field(:, :)
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    type(weno_interpolation_controls), intent(in), optional :: weno_control
    real(real64), intent(in), optional :: weno_exponent, half_level_coordinate(0:)
    integer(int32) :: family, method, mode, vertical
    status = 2
    if (len(selector) /= 12) return
    family = 0
    method = 1
    select case (selector)
    case ('LAITQM(SLD) ')
      mode = 2
      family = 2
    case ('LAITQMH(SLD)')
      mode = 1
      family = 2
    case ('LAITRI(SLD) ')
      mode = 0
      family = 2
    case ('LAITQM(MAD) ')
      mode = 2
      family = 1
    case ('LAITQM3(MAD)')
      mode = 2
      method = 2
      family = 1
    case ('LAITQML(MAD)')
      mode = 1
      method = 2
      family = 1
    case ('LAITQMH(MAD)')
      mode = 1
      family = 1
    case ('LAITRI(MAD) ')
      mode = 0
      family = 1
    case ('LAITQM3D    ')
      mode = 2
      method = 2
    case ('LAITQML3D   ')
      mode = 1
      method = 2
    case ('LAITQM      ')
      mode = 2
    case ('LAITQMH     ')
      mode = 1
    case ('LAITRI      ')
      mode = 0
    case ('LAITRWENOQM ')
      mode = 2
      method = 3
    case ('LAITRWENOQMH')
      mode = 1
      method = 3
    case ('LAITRWENO   ')
      mode = 0
      method = 3
    case default
      return
    end select
    if (family == 2 .and. .not. momentum) family = 3
    vertical = family
    call interpolate_selected_field(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                                    weight_set, family, vertical, method, mode, conserve_vertical, weights, field, result, status, &
                                    weno_control, weno_exponent, half_level_coordinate)
  end subroutine

  !> Select borrowed native views, then call one complete numerical child.
  subroutine interpolate_selected_field(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                                        slot, family, vertical, method, mode, conserve_vertical, w, field, result, status, &
                                        weno_control, weno_exponent, half_level_coordinate)
    integer(int32), intent(in) :: source_pitch, pitch, first, last, levels, first_plane, last_plane
    integer(int32), intent(in) :: slot, family, vertical, method, mode
    logical, intent(in) :: conserve_vertical
    type(departure_weight_outputs), intent(in) :: w
    real(real64), contiguous, target, intent(in) :: field(:, :)
    real(real64), intent(inout) :: result(:, :)
    integer(int32), intent(out) :: status
    type(weno_interpolation_controls), intent(in), optional :: weno_control
    real(real64), intent(in), optional :: weno_exponent, half_level_coordinate(0:)
    real(real64), pointer :: latitude(:, :), longitude(:, :, :), fraction(:, :)
    real(real64), pointer :: latitude_coefficients(:, :, :), longitude_coefficients(:, :, :, :), vertical_coefficients(:, :, :)
    real(real64), pointer :: flat_field(:)
    real(real64), allocatable :: vertical_windows(:, :, :, :)
    real(real64), volatile :: layer, previous_layer, ratio
    integer(int64) :: planes, total
    integer :: allocation_status, k, j, i
    status = 2
    if (source_pitch < 1 .or. pitch < 1 .or. pitch > 1024 .or. levels < 4 .or. levels > 256) return
    if (first < 1 .or. first > pitch + 1 .or. last < 0 .or. last > pitch .or. last < first - 1) return
    if (slot < 1 .or. slot > 4) return
    if (method == 0 .and. source_pitch > (huge(0_int32) - 2)/2) return
    if (method == 1 .and. source_pitch > (huge(0_int32) - 3)/3) return
    planes = int(last_plane, int64) - int(first_plane, int64) + 1_int64
    if (planes < 1 .or. planes > huge(0_int32)) return
    total = int(source_pitch, int64)*planes
    if (total > huge(0_int32)) return
    if (size(field, 1) /= source_pitch .or. size(field, 2, kind=int64) /= planes) return
    if (size(result, 1) /= pitch .or. size(result, 2) < levels) return
    if (.not. associated(w%parent_index)) return
    if (size(w%parent_index, 1) /= pitch .or. size(w%parent_index, 2) < levels .or. size(w%parent_index, 3) /= 4) return
    if (family == 1) then
      if (.not. associated(w%latitude_correction_fraction) .or. .not. associated(w%longitude_correction_fraction)) return
      latitude => w%latitude_correction_fraction
      longitude => w%longitude_correction_fraction
    else
      if (.not. associated(w%latitude_fraction) .or. .not. associated(w%longitude_fraction)) return
      latitude => w%latitude_fraction
      longitude => w%longitude_fraction
    end if
    if (size(latitude, 1) /= pitch .or. size(latitude, 2) < levels) return
    if (size(longitude, 1) /= pitch .or. size(longitude, 2) < levels .or. size(longitude, 3) /= 4) return
    if (method == 0 .or. method == 2) then
      if (family == 1) then
        if (.not. associated(w%vertical_correction_fraction)) return
        fraction => w%vertical_correction_fraction
      else
        if (.not. associated(w%vertical_fraction)) return
        fraction => w%vertical_fraction
      end if
      if (size(fraction, 1) /= pitch .or. size(fraction, 2) < levels) return
    end if
    if (method /= 0) then
      select case (family)
      case (0)
        if (.not. associated(w%latitude_main) .or. .not. associated(w%longitude_main)) return
        if (size(w%latitude_main, 4) < slot .or. size(w%longitude_main, 5) < slot) return
        latitude_coefficients => w%latitude_main(:, :, :, slot)
        longitude_coefficients => w%longitude_main(:, :, :, :, slot)
      case (1)
        if (.not. associated(w%latitude_correction) .or. .not. associated(w%longitude_correction)) return
        if (size(w%latitude_correction, 4) < slot .or. size(w%longitude_correction, 5) < slot) return
        latitude_coefficients => w%latitude_correction(:, :, :, slot)
        longitude_coefficients => w%longitude_correction(:, :, :, :, slot)
      case (2)
        if (.not. associated(w%latitude_filtered) .or. .not. associated(w%longitude_filtered)) return
        if (size(w%latitude_filtered, 4) < slot .or. size(w%longitude_filtered, 5) < slot) return
        latitude_coefficients => w%latitude_filtered(:, :, :, slot)
        longitude_coefficients => w%longitude_filtered(:, :, :, :, slot)
      case (3)
        if (.not. associated(w%latitude_heat) .or. .not. associated(w%longitude_heat)) return
        latitude_coefficients => w%latitude_heat
        longitude_coefficients => w%longitude_heat
      end select
      if (size(latitude_coefficients, 1) /= pitch .or. size(latitude_coefficients, 2) < levels .or. &
          size(latitude_coefficients, 3) /= 3) return
      if (size(longitude_coefficients, 1) /= pitch .or. size(longitude_coefficients, 2) < levels .or. &
          size(longitude_coefficients, 3) /= 3 .or. size(longitude_coefficients, 4) /= 2) return
      select case (vertical)
      case (0)
        if (.not. associated(w%vertical_main)) return
        vertical_coefficients => w%vertical_main
      case (1)
        if (.not. associated(w%vertical_correction)) return
        vertical_coefficients => w%vertical_correction
      case (2)
        if (.not. associated(w%vertical_diffusion)) return
        vertical_coefficients => w%vertical_diffusion
      case (3)
        if (.not. associated(w%vertical_heat)) return
        vertical_coefficients => w%vertical_heat
      case (4)
        if (.not. associated(w%vertical_filtered)) return
        vertical_coefficients => w%vertical_filtered
      end select
      if (size(vertical_coefficients, 1) /= pitch .or. size(vertical_coefficients, 2) < levels) return
      if (method == 3) then
        if (size(vertical_coefficients, 3) < 9) return
        if (source_pitch < 4 .or. source_pitch > 134217728 .or. planes > 512) return
        if (.not. present(weno_control) .or. .not. present(weno_exponent)) return
        if (.not. ieee_is_finite(weno_exponent)) return
        if (weno_exponent < 0.0_real64 .or. weno_exponent > 4.0_real64) return
        if (.not. ieee_is_finite(weno_control%upper_exponent)) return
        if (weno_control%upper_exponent < 0.0_real64 .or. weno_control%upper_exponent > 4.0_real64) return
        if (weno_control%upper_level_count < 0 .or. weno_control%smoothness_choice < 1 .or. &
            weno_control%smoothness_choice > 5) return
        if (.not. associated(w%weno_combination) .or. .not. associated(w%weno_shift)) return
        if (size(w%weno_combination, 1) /= pitch .or. size(w%weno_combination, 2) < levels .or. &
            size(w%weno_combination, 3) /= 3) return
        if (size(w%weno_shift, 1) /= pitch .or. size(w%weno_shift, 2) < levels) return
      else
        if (size(vertical_coefficients, 3) < 3) return
      end if
    end if
    if (method == 2 .and. mode == 2 .and. conserve_vertical) then
      if (.not. present(half_level_coordinate)) return
      if (ubound(half_level_coordinate, 1) < levels .or. ubound(half_level_coordinate, 1) > 4096) return
      do k = 0, levels
        if (.not. ieee_is_finite(half_level_coordinate(k))) return
        if (k > 0) then
          if (half_level_coordinate(k) <= half_level_coordinate(k - 1)) return
        end if
      end do
    end if
    if (first > last) then
      ! The original conservative child prepares these ratios even when no
      ! output cell is selected. Volatile temporaries retain that status work.
      if (method == 2 .and. mode == 2 .and. conserve_vertical) then
        do k = 2, levels
          layer = half_level_coordinate(k) - half_level_coordinate(k - 1)
          previous_layer = half_level_coordinate(k - 1) - half_level_coordinate(k - 2)
          ratio = layer/previous_layer
        end do
      end if
      status = 0
      return
    end if
    flat_field(1:size(field)) => field
    select case (method)
    case (0)
      call interpolate_eight_neighbours(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                                    latitude, longitude(:, :, 2:3), w%parent_index(:, :, 2:3), fraction, flat_field, result, status)
    case (1)
      call interpolate_thirty_two_neighbours(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                                         mode, latitude, latitude_coefficients, longitude, longitude_coefficients, w%parent_index, &
                                             vertical_coefficients(:, :, 1:3), flat_field, result, status)
    case (2)
      call interpolate_bounded_thirty_two_neighbours(source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                      mode, conserve_vertical, latitude, latitude_coefficients, longitude, longitude_coefficients, w%parent_index, &
                                                     vertical_coefficients(:, :, 1:3), flat_field, result, status, &
                                                     vertical_fraction=fraction, half_level_coordinate=half_level_coordinate)
    case (3)
      allocate (vertical_windows(pitch, levels, 3, 3), stat=allocation_status)
      if (allocation_status /= 0) then
        status = 1
        return
      end if
      do j = 1, 3
        do k = 1, 3
          do i = 1, levels
            vertical_windows(:, i, k, j) = vertical_coefficients(:, i, k + 3*(j - 1))
          end do
        end do
      end do
      call interpolate_weno_departure(weno_control, source_pitch, pitch, first, last, levels, first_plane, last_plane, &
                           mode, latitude, latitude_coefficients, longitude, longitude_coefficients, w%parent_index, w%weno_shift, &
                                      w%weno_combination, vertical_windows, flat_field, result, status, exponent=weno_exponent)
    end select
  end subroutine
end module

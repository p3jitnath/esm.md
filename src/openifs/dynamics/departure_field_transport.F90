!> Move hydrostatic wind, temperature and constituent fields to departure points.
!! A departure point is the earlier parcel position used by the transport step.
!! This is the complete selected LARCINB route. Inputs use native arrays and
!! named maps; the compiler owns descriptors, registers and stack storage.
module md2asm_departure_field_transport
  use iso_fortran_env, only: int32, int64, real64
  use md2asm_departure_interpolation_weights, only: departure_weight_outputs
  use md2asm_departure_field_interpolation_dispatch, only: general_field_interpolation_controls, &
                                                           interpolate_general_model_field, interpolate_constituent_field
  use md2asm_horizontal_cubic_departure_interpolation, only: interpolate_twelve_neighbours
  use md2asm_weno_departure_interpolation, only: weno_interpolation_controls
  implicit none
  private
  public :: departure_transport_controls, general_transport_map, constituent_transport_map
  public :: transport_hydrostatic_departure_fields
  !> Frozen three-level, hydrostatic transport choices.
  !! Separate diagnostic flags select additions to supplied full-size owners.
  !! A compact diagnostic owner is permitted only when its write flag is false.
  type :: departure_transport_controls
    integer(int32) :: first_input_level = 0, last_input_level = 0
    logical :: split_physics = .false., refined_saved_winds = .false.
    logical :: diffusion_diagnostic = .false., linear_diagnostic = .false.
    logical :: separate_heat_coefficients = .false., vertical_conservation = .false.
    logical :: modified_pressure = .false., clip_pressure = .true.
    integer(int64) :: constituent_source = 0, constituent_physics_source = 0
    integer(int64) :: pressure_source = 0, pressure_departure_source = 0
    type(general_field_interpolation_controls) :: wind, thermal
  end type
  !> One initialized U, V or temperature map, in that order.
  !! Source values are one-based plane bases in the complete source owner.
  !! Result and diagnostic values are one-based field slots. saved is used
  !! only for U/V. physics is used only when split_physics is true. Pointer
  !! targets are writable borrowed arrays(pitch,levels), with caller units.
  type :: general_transport_map
    integer(int64) :: high_source = 0, linear_source = 0, refined_source = 0
    integer(int64) :: diagnostic_source = 0, physics_source = 0
    integer(int32) :: result_slot = 0, diffusion_slot = 0, linear_slot = 0
    real(real64), pointer :: saved(:, :) => null(), physics(:, :) => null()
  end type
  !> Original constituent selection and source maps.
  !! Inactive and external-grid fields keep their full result storage.
  !! Split physics still applies to an advected external-grid physics field.
  !! source_slot maps MP_SL1; physics_slot maps MPSLP. Names and selectors
  !! keep all16 name characters and12 selector characters. weno_exponent has no unit.
  type :: constituent_transport_map
    logical :: advected = .false., external_grid = .false., physics = .false.
    logical :: diabatic_linear = .false.
    integer(int32) :: source_slot = 0, physics_slot = 0
    character(len=16) :: name = ''
    character(len=12) :: selector = ''
    real(real64) :: weno_exponent = 0.0_real64
  end type
contains
  !> Calculate the complete selected hydrostatic departure-field transport.
  !! source(source_pitch,source_planes) is contiguous, borrowed and read only.
  !! It can contain more than2**31 words; each consumed field window retains
  !! the narrower accepted interpolation-child bound. Three general maps
  !! name U,V,T result slots in general_fields(pitch,levels,field). The
  !! constituent array order is the original field order. All field results,
  !! diagnostics, saved winds and split-physics targets retain caller units.
  !! pressure and pressure_departure use(pitch,levels). Only first:last cells
  !! change. Every containing owner and every consumed input must be separate.
  !! Other historical return owners are not consumed and remain caller-owned.
  !! Status0 succeeds,1 refuses workspace,2 refuses metadata or a child. A
  !! late child refusal leaves the whole parent return unaccepted.
  subroutine transport_hydrostatic_departure_fields(source_pitch, pitch, first, last, levels, c, maps, components, &
                                    weights, source, general_fields, constituent_fields, diffusion_general, diffusion_constituent, &
                       linear_general, split_constituent, pressure, pressure_departure, status, weno_control, half_level_coordinate)
    integer(int32), intent(in) :: source_pitch, pitch, first, last, levels
    type(departure_transport_controls), intent(in) :: c
    type(general_transport_map), intent(inout) :: maps(3)
    type(constituent_transport_map), intent(in) :: components(:)
    type(departure_weight_outputs), intent(in) :: weights
    real(real64), contiguous, target, intent(in) :: source(:, :)
    real(real64), intent(inout) :: general_fields(:, :, :), constituent_fields(:, :, :)
    real(real64), intent(inout) :: diffusion_general(:, :, :), diffusion_constituent(:, :, :), linear_general(:, :, :)
    real(real64), intent(inout) :: split_constituent(:, :, :), pressure(:, :), pressure_departure(:, :)
    integer(int32), intent(out) :: status
    type(weno_interpolation_controls), intent(in) :: weno_control
    real(real64), intent(in), optional :: half_level_coordinate(0:)
    type(general_field_interpolation_controls) :: field_control, linear_control
    real(real64), allocatable :: linear_value(:, :)
    real(real64), pointer :: flat_source(:)
    integer(int64) :: planes, source_planes, base, total_source
    integer :: variable, other, field, cell, level, allocation_status, slot
    logical :: local_field, momentum, modified
    status = 2
    if (source_pitch < 1 .or. pitch < 1 .or. pitch > 1024 .or. levels < 4 .or. levels > 256) return
    if (first < 1 .or. first > pitch + 1 .or. last < 0 .or. last > pitch .or. last < first - 1) return
    planes = int(c%last_input_level, int64) - int(c%first_input_level, int64) + 1_int64
    if (planes < 1 .or. planes > huge(0_int32)) return
    if (int(source_pitch, int64)*planes > huge(0_int32)) return
    if (size(source, 1) /= source_pitch) return
    source_planes = size(source, 2, kind=int64)
    if (source_planes < 1 .or. source_planes > 1152921504606846975_int64/int(source_pitch, int64)) return
    total_source = int(source_pitch, int64)*source_planes
    if (size(components) > 2163 .or. .not. c%clip_pressure) return
    if (size(general_fields, 1) /= pitch .or. size(general_fields, 2) < levels) return
    if (size(constituent_fields, 1) /= pitch .or. size(constituent_fields, 2) < levels .or. &
        size(constituent_fields, 3) < size(components)) return
    if (size(pressure, 1) /= pitch .or. size(pressure, 2) < levels) return
    if (size(pressure_departure, 1) /= pitch .or. size(pressure_departure, 2) < levels) return
    ! The selected source has wind and temperature lag3, one horizontal
    ! weight family, ordinary coordinates and no extra correction stage.
    if (c%wind%linear .or. c%wind%vertical_weno .or. c%wind%limiter_three_dimensional .or. &
        .not. c%wind%limiter_horizontal .or. c%wind%weight_set /= 1) return
    if (c%thermal%linear .or. .not. c%thermal%vertical_weno .or. c%thermal%limiter_three_dimensional .or. &
        .not. c%thermal%limiter_horizontal .or. c%thermal%weight_set /= 1) return
    do variable = 1, 3
      slot = maps(variable)%result_slot
      if (slot < 1 .or. slot > size(general_fields, 3)) return
      do other = 1, variable - 1
        if (slot == maps(other)%result_slot) return
      end do
      if (.not. valid_source(maps(variable)%high_source)) return
      if (.not. valid_source(maps(variable)%linear_source)) return
      if (variable <= 2) then
        if (.not. associated(maps(variable)%saved)) return
        if (.not. valid_plane(maps(variable)%saved)) return
        if (c%refined_saved_winds) then
          if (.not. valid_source(maps(variable)%refined_source)) return
        end if
      end if
      if (c%diffusion_diagnostic) then
        slot = maps(variable)%diffusion_slot
        if (.not. valid_diagnostic(diffusion_general, slot)) return
      end if
      if (c%linear_diagnostic) then
        slot = maps(variable)%linear_slot
        if (.not. valid_diagnostic(linear_general, slot)) return
        if (.not. valid_source(maps(variable)%diagnostic_source)) return
      end if
      if (c%split_physics) then
        if (.not. associated(maps(variable)%physics)) return
        if (.not. valid_plane(maps(variable)%physics)) return
        if (.not. valid_source(maps(variable)%physics_source)) return
      end if
    end do
    if (c%diffusion_diagnostic) then
      if (size(diffusion_constituent, 1) /= pitch .or. size(diffusion_constituent, 2) < levels .or. &
          size(diffusion_constituent, 3) < size(components)) return
    end if
    do field = 1, size(components)
      local_field = components(field)%advected .and. .not. components(field)%external_grid
      if (local_field) then
        if (components(field)%diabatic_linear) return
        if (.not. accepted_selector(components(field)%selector)) return
        if (components(field)%source_slot < 1) return
        if (c%constituent_source < 1 .or. c%constituent_source > source_planes) return
        base = c%constituent_source + int(components(field)%source_slot - 1, int64)*planes
        if (.not. valid_source(base)) return
      end if
      if (c%split_physics .and. components(field)%advected .and. components(field)%physics) then
        slot = components(field)%physics_slot
        if (slot < 1 .or. slot > size(split_constituent, 3)) return
        if (size(split_constituent, 1) /= pitch .or. size(split_constituent, 2) < levels) return
        if (c%constituent_physics_source < 1 .or. c%constituent_physics_source > source_planes) return
        base = c%constituent_physics_source + int(slot - 1, int64)*planes
        if (.not. valid_source(base)) return
      end if
    end do
    if (.not. valid_source(c%pressure_source) .or. .not. valid_source(c%pressure_departure_source)) return
    if (.not. associated(weights%horizontal_index)) return
    if (size(weights%horizontal_index, 1) /= pitch .or. size(weights%horizontal_index, 2) < levels .or. &
        size(weights%horizontal_index, 3) /= 4) return
    if (c%modified_pressure) then
      if (.not. associated(weights%latitude_correction) .or. .not. associated(weights%longitude_correction) .or. &
          .not. associated(weights%longitude_correction_fraction)) return
      if (size(weights%latitude_correction, 4) < 1 .or. size(weights%longitude_correction, 5) < 1) return
    else
      if (.not. associated(weights%latitude_main) .or. .not. associated(weights%longitude_main) .or. &
          .not. associated(weights%longitude_fraction)) return
      if (size(weights%latitude_main, 4) < 1 .or. size(weights%longitude_main, 5) < 1) return
    end if
    allocate (linear_value(pitch, levels), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    do variable = 1, 3
      if (variable <= 2) then
        field_control = c%wind
        field_control%momentum = .true.
      else
        field_control = c%thermal
        field_control%momentum = .not. c%separate_heat_coefficients
      end if
      slot = maps(variable)%result_slot
      base = maps(variable)%high_source
      call interpolate_general_model_field(source_pitch, pitch, first, last, levels, &
                               c%first_input_level, c%last_input_level, field_control, weights, source(:, base:base + planes - 1), &
                                           general_fields(:, :, slot), status, weno_control)
      if (status /= 0) return
      if (c%diffusion_diagnostic) then
        call add_plane(diffusion_general(:, :, maps(variable)%diffusion_slot), general_fields(:, :, slot))
      end if
      if (variable <= 2) then
        if (c%refined_saved_winds) then
          base = maps(variable)%refined_source
          call interpolate_general_model_field(source_pitch, pitch, first, last, levels, &
                               c%first_input_level, c%last_input_level, field_control, weights, source(:, base:base + planes - 1), &
                                               maps(variable)%saved, status, weno_control)
          if (status /= 0) return
        else
          do level = 1, levels
            do cell = first, last
              maps(variable)%saved(cell, level) = general_fields(cell, level, slot)
            end do
          end do
        end if
      end if
      linear_control = field_control
      linear_control%linear = .true.
      base = maps(variable)%linear_source
      call interpolate_general_model_field(source_pitch, pitch, first, last, levels, &
                              c%first_input_level, c%last_input_level, linear_control, weights, source(:, base:base + planes - 1), &
                                           linear_value, status, weno_control)
      if (status /= 0) return
      call add_plane(general_fields(:, :, slot), linear_value)
      if (c%linear_diagnostic) then
        base = maps(variable)%diagnostic_source
        call interpolate_general_model_field(source_pitch, pitch, first, last, levels, &
                              c%first_input_level, c%last_input_level, linear_control, weights, source(:, base:base + planes - 1), &
                                             linear_value, status, weno_control)
        if (status /= 0) return
        call add_plane(linear_general(:, :, maps(variable)%linear_slot), linear_value)
      end if
      if (c%split_physics) then
        base = maps(variable)%physics_source
        call interpolate_general_model_field(source_pitch, pitch, first, last, levels, &
                              c%first_input_level, c%last_input_level, linear_control, weights, source(:, base:base + planes - 1), &
                                             maps(variable)%physics, status, weno_control)
        if (status /= 0) return
      end if
    end do
    do field = 1, size(components)
      if (components(field)%advected .and. .not. components(field)%external_grid) then
        momentum = trim(components(field)%name) == 'TKE' .or. .not. c%separate_heat_coefficients
        base = c%constituent_source + int(components(field)%source_slot - 1, int64)*planes
        if (components(field)%selector == 'LIN         ' .or. components(field)%selector == 'LIN(MAD)    ') then
          linear_control = general_field_interpolation_controls()
          linear_control%linear = .true.
          linear_control%modified_advection = components(field)%selector == 'LIN(MAD)    '
          call interpolate_general_model_field(source_pitch, pitch, first, last, levels, &
                              c%first_input_level, c%last_input_level, linear_control, weights, source(:, base:base + planes - 1), &
                                               constituent_fields(:, :, field), status, weno_control)
        else
          call interpolate_constituent_field(source_pitch, pitch, first, last, levels, &
                                           c%first_input_level, c%last_input_level, components(field)%selector, 1_int32, momentum, &
                             c%vertical_conservation, weights, source(:, base:base + planes - 1), constituent_fields(:, :, field), &
                                             status, weno_control, components(field)%weno_exponent, half_level_coordinate)
        end if
        if (status /= 0) return
        if (c%diffusion_diagnostic) call add_plane(diffusion_constituent(:, :, field), constituent_fields(:, :, field))
      end if
      if (c%split_physics .and. components(field)%advected .and. components(field)%physics) then
        slot = components(field)%physics_slot
        modified = modified_linear_selector(components(field)%selector)
        linear_control = general_field_interpolation_controls()
        linear_control%linear = .true.
        linear_control%modified_advection = modified
        base = c%constituent_physics_source + int(slot - 1, int64)*planes
        call interpolate_general_model_field(source_pitch, pitch, first, last, levels, &
                              c%first_input_level, c%last_input_level, linear_control, weights, source(:, base:base + planes - 1), &
                                             split_constituent(:, :, slot), status, weno_control)
        if (status /= 0) return
      end if
    end do
    linear_control = general_field_interpolation_controls()
    linear_control%linear = .true.
    linear_control%modified_advection = c%modified_pressure
    base = c%pressure_source
    call interpolate_general_model_field(source_pitch, pitch, first, last, levels, &
                              c%first_input_level, c%last_input_level, linear_control, weights, source(:, base:base + planes - 1), &
                                         pressure, status, weno_control)
    if (status /= 0) return
    base = c%pressure_departure_source
    flat_source(1:int(source_pitch, int64)*planes) => source(:, base:base + planes - 1)
    if (c%modified_pressure) then
      if (.not. associated(weights%latitude_correction) .or. .not. associated(weights%longitude_correction) .or. &
          .not. associated(weights%longitude_correction_fraction)) then
        status = 2
        return
      end if
      if (size(weights%latitude_correction, 4) < 1 .or. size(weights%longitude_correction, 5) < 1) then
        status = 2
        return
      end if
      call interpolate_twelve_neighbours(source_pitch, pitch, first, last, levels, c%first_input_level, &
                                         c%last_input_level, c%clip_pressure, weights%latitude_correction(:, :, :, 1), &
                                         weights%longitude_correction_fraction, weights%longitude_correction(:, :, :, :, 1), &
                                         weights%horizontal_index, flat_source, pressure_departure, status)
    else
      if (.not. associated(weights%latitude_main) .or. .not. associated(weights%longitude_main) .or. &
          .not. associated(weights%longitude_fraction)) then
        status = 2
        return
      end if
      if (size(weights%latitude_main, 4) < 1 .or. size(weights%longitude_main, 5) < 1) then
        status = 2
        return
      end if
      call interpolate_twelve_neighbours(source_pitch, pitch, first, last, levels, c%first_input_level, &
                               c%last_input_level, c%clip_pressure, weights%latitude_main(:, :, :, 1), weights%longitude_fraction, &
                           weights%longitude_main(:, :, :, :, 1), weights%horizontal_index, flat_source, pressure_departure, status)
    end if
  contains
    logical function valid_source(start) result(valid)
      integer(int64), intent(in) :: start
      valid = .false.
      if (start < 1 .or. start > source_planes) return
      if (planes > source_planes - start + 1) return
      valid = .true.
    end function
    logical function valid_plane(array) result(valid)
      real(real64), intent(in) :: array(:, :)
      valid = size(array, 1) == pitch .and. size(array, 2) >= levels
    end function
    logical function valid_diagnostic(array, number) result(valid)
      real(real64), intent(in) :: array(:, :, :)
      integer, intent(in) :: number
      valid = size(array, 1) == pitch .and. size(array, 2) >= levels .and. number >= 1 .and. number <= size(array, 3)
    end function
    subroutine add_plane(target, value)
      real(real64), intent(inout) :: target(:, :)
      real(real64), intent(in) :: value(:, :)
      integer :: i, k
      do k = 1, levels
        do i = first, last
          target(i, k) = target(i, k) + value(i, k)
        end do
      end do
    end subroutine
  end subroutine

  logical function accepted_selector(selector) result(accepted)
    character(len=12), intent(in) :: selector
    select case (selector)
    case ('LIN         ', 'LIN(MAD)    ', 'LAITQM(SLD) ', 'LAITQMH(SLD)', 'LAITRI(SLD) ', &
          'LAITQM(MAD) ', 'LAITQM3(MAD)', 'LAITQML(MAD)', 'LAITQMH(MAD)', 'LAITRI(MAD) ', &
          'LAITQM3D    ', 'LAITQML3D   ', 'LAITQM      ', 'LAITQMH     ', 'LAITRI      ', &
          'LAITRWENOQM ', 'LAITRWENOQMH', 'LAITRWENO   ')
      accepted = .true.
    case default
      accepted = .false.
    end select
  end function

  logical function modified_linear_selector(selector) result(modified)
    character(len=12), intent(in) :: selector
    ! The source split-physics list has exactly these four entries. The
    ! bounded cubic MAD selectors deliberately retain ordinary linear weights.
    modified = selector == 'LIN(MAD)    ' .or. selector == 'LAITQM(MAD) ' .or. &
               selector == 'LAITQMH(MAD)' .or. selector == 'LAITRI(MAD) '
  end function
end module

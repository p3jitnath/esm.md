module md2asm_physics_state_rate_update
  !! Port generated CPQTUV: rates, water corrections and continuity.
  !!
  !! Time is in s; temperature in K; wind in m s**(-1); water fractions in
  !! kg kg**(-1). Tracers keep their caller's units. No physics rate is
  !! supplied by this adapter: every incoming rate is a caller input.
  use iso_fortran_env, only: int32, real64
  implicit none
  private
  public :: tracer_state_descriptor, apply_physics_state_rates
  type :: tracer_state_descriptor
    logical :: active = .false., new_state_active = .false.
    integer(int32) :: earlier_field = 0, previous_physics_field = 0, new_field = 0
  end type
contains
  subroutine apply_physics_state_rates(pitch, first, last, levels, time_step, &
                                       liquid_minimum, cloud_minimum, vapour_latent_heat, ice_latent_heat, &
                                       dry_flux_correction, components, water, cloud, continuity, previous_u, previous_v, &
                                       previous_t, earlier_fields, u, v, t, new_fields, status, dynamics_rates, &
                                       convection_continuity)
    !! Apply full/partial blocks while preserving unused fields and cells.
    !!
    !! Fields use(horizontal cell,level,field). components retains the
    !! original descriptor order, including repeated targets. water is
    !! ordered vapour,liquid,ice,rain,snow. Cloud and continuity descriptors
    !! are separate typed values; no target-specific object offsets remain.
    integer(int32), intent(in) :: pitch, first, last, levels
    real(real64), intent(in) :: time_step, liquid_minimum, cloud_minimum
    real(real64), intent(in) :: vapour_latent_heat, ice_latent_heat
    logical, intent(in) :: dry_flux_correction
    type(tracer_state_descriptor), intent(in) :: components(:), water(5), cloud, continuity
    real(real64), intent(in) :: previous_u(:, :), previous_v(:, :), previous_t(:, :)
    real(real64), intent(inout) :: earlier_fields(:, :, :), u(:, :), v(:, :), t(:, :), new_fields(:, :, :)
    integer(int32), intent(out) :: status
    real(real64), intent(in), optional :: dynamics_rates(:, :, :), convection_continuity(:, :)
    integer :: cell, level, j, field, old_field
    real(real64) :: product, value, condensate, total, change, factor, temporary, latent
    logical :: mass_correction, need_vapour
    status = 2
    if (pitch < 1 .or. levels < 0 .or. first < 1 .or. last > pitch) return
    if (levels == 0 .or. first > last) then
      status = 0
      return
    end if
    if (size(components) > 2163) return
    if (.not. valid(previous_u) .or. .not. valid(previous_v) .or. .not. valid(previous_t)) return
    if (.not. valid(u) .or. .not. valid(v) .or. .not. valid(t)) return
    if (size(earlier_fields, 1) /= pitch .or. size(earlier_fields, 2) < levels) return
    if (size(new_fields, 1) /= pitch .or. size(new_fields, 2) < levels) return
    do j = 1, size(components)
      if (.not. components(j)%new_state_active) cycle
      if (.not. valid_new(components(j)%new_field)) return
      if (.not. valid_old(components(j)%previous_physics_field)) return
    end do
    need_vapour = .false.
    do j = 2, 5
      if (.not. water(j)%new_state_active) cycle
      need_vapour = .true.
      if (.not. valid_new(water(j)%new_field)) return
    end do
    if (need_vapour .and. .not. valid_new(water(1)%new_field)) return
    if (cloud%new_state_active) then
      if (.not. valid_new(cloud%new_field)) return
    end if
    mass_correction = .false.
    if (continuity%active) then
      if (.not. valid_old(continuity%earlier_field)) return
      if (.not. present(convection_continuity)) return
      if (.not. valid(convection_continuity)) return
      mass_correction = dry_flux_correction .and. all(water%active)
      if (mass_correction) then
        if (.not. present(dynamics_rates)) return
        if (size(dynamics_rates, 1) /= pitch .or. size(dynamics_rates, 2) < levels) return
        do j = 1, 5
          if (.not. valid_new(water(j)%new_field)) return
          if (.not. valid_old(water(j)%previous_physics_field)) return
          if (water(j)%new_field > size(dynamics_rates, 3)) return
          if (continuity%earlier_field == water(j)%previous_physics_field) return
        end do
      end if
    end if

    do level = 1, levels
      do cell = first, last
        product = time_step*u(cell, level)
        u(cell, level) = previous_u(cell, level) + product
        product = time_step*v(cell, level)
        v(cell, level) = previous_v(cell, level) + product
        product = time_step*t(cell, level)
        t(cell, level) = previous_t(cell, level) + product
      end do
    end do
    do j = 1, size(components)
      if (.not. components(j)%new_state_active) cycle
      field = components(j)%new_field; old_field = components(j)%previous_physics_field
      do level = 1, levels
        do cell = first, last
          product = time_step*new_fields(cell, level, field)
          new_fields(cell, level, field) = earlier_fields(cell, level, old_field) + product
        end do
      end do
    end do

    do level = 1, levels
      do cell = first, last
        do j = 2, 5
          if (.not. water(j)%new_state_active) cycle
          field = water(j)%new_field
          condensate = new_fields(cell, level, field)
          if (condensate >= liquid_minimum) cycle
          value = new_fields(cell, level, water(1)%new_field) + condensate
          new_fields(cell, level, water(1)%new_field) = value
          if (j == 2 .or. j == 4) then
            latent = vapour_latent_heat
          else
            latent = ice_latent_heat
          end if
          product = latent*condensate
          t(cell, level) = t(cell, level) - product
          new_fields(cell, level, field) = 0.0_real64
        end do
        if (water(2)%new_state_active .and. water(3)%new_state_active .and. cloud%new_state_active) then
          condensate = new_fields(cell, level, water(2)%new_field)
          value = new_fields(cell, level, water(3)%new_field)
          total = condensate + value
          if (new_fields(cell, level, cloud%new_field) < cloud_minimum .or. total < liquid_minimum) then
            temporary = new_fields(cell, level, water(1)%new_field) + total
            new_fields(cell, level, water(1)%new_field) = temporary
            product = vapour_latent_heat*condensate
            temporary = t(cell, level) - product
            product = ice_latent_heat*value
            t(cell, level) = temporary - product
            new_fields(cell, level, water(2)%new_field) = 0.0_real64
            new_fields(cell, level, water(3)%new_field) = 0.0_real64
            new_fields(cell, level, cloud%new_field) = 0.0_real64
          end if
        end if
        if (cloud%new_state_active) then
          if (new_fields(cell, level, cloud%new_field) > 1.0_real64) &
            new_fields(cell, level, cloud%new_field) = 1.0_real64
        end if
      end do
    end do
    if (.not. continuity%active) then
      status = 0
      return
    end if
    do level = 1, levels
      do cell = first, last
        earlier_fields(cell, level, continuity%earlier_field) = convection_continuity(cell, level)
      end do
    end do
    if (.not. mass_correction) then
      status = 0
      return
    end if
    do level = 1, levels
      do cell = first, last
        do j = 1, 5
          field = water(j)%new_field; old_field = water(j)%previous_physics_field
          value = new_fields(cell, level, field) - earlier_fields(cell, level, old_field)
          product = dynamics_rates(cell, level, field)*time_step
          value = value - product
          if (j == 1) then
            change = value
          else
            change = change + value
          end if
        end do
        factor = 1.0_real64 - change
        do j = 1, size(components)
          if (.not. components(j)%new_state_active) cycle
          field = components(j)%new_field
          new_fields(cell, level, field) = new_fields(cell, level, field)*factor
        end do
        total = new_fields(cell, level, water(1)%new_field)
        do j = 2, 5
          total = total + new_fields(cell, level, water(j)%new_field)
        end do
        temporary = 1.0_real64 - total
        value = change/temporary
        value = value/time_step
        earlier_fields(cell, level, continuity%earlier_field) = &
          earlier_fields(cell, level, continuity%earlier_field) + value
      end do
    end do
    status = 0
  contains
    logical function valid(a)
      real(real64), intent(in) :: a(:, :)
      valid = size(a, 1) == pitch .and. size(a, 2) >= levels
    end function
    logical function valid_new(index)
      integer(int32), intent(in) :: index
      valid_new = index >= 1 .and. index <= size(new_fields, 3)
    end function
    logical function valid_old(index)
      integer(int32), intent(in) :: index
      valid_old = index >= 1 .and. index <= size(earlier_fields, 3)
    end function
  end subroutine
end module md2asm_physics_state_rate_update

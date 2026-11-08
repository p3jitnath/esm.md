!> Coordinates and weights for semi-Lagrangian departure points.
!! The parent owns its coordinate search and calls its own accepted weight
!! children. Angles are radians; all remaining coordinates and weights have
!! no unit. Integer addresses count real words in the supplied field buffer.
module md2asm_departure_interpolation_weights
  use iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: ieee_arithmetic, only: ieee_is_finite
  use md2asm_latitude_interpolation_weight_blending, only: &
    latitude_weight_controls, blend_latitude_interpolation_weights
  use md2asm_longitude_interpolation_weight_blending, only: &
    longitude_weight_controls, blend_longitude_interpolation_weights
  use md2asm_vertical_interpolation_weight_blending, only: &
    vertical_weight_controls, blend_vertical_interpolation_weights
  implicit none
  private
  public :: departure_weight_controls, departure_weight_geometry
  public :: departure_weight_inputs, departure_weight_outputs
  public :: prepare_departure_interpolation_weights
  !> The kind retains the original KWIS number.
  !! Kinds101/201 are linear,102/103 and202/203 are cubic,104 is Hermite,
  !! 105 uses a supplied spline and106 uses three WENO candidate windows.
  !! WENO combines neighbouring polynomials without changing their order.
  type :: departure_weight_controls
    integer(int32) :: kind = 103, slots = 1, horizontal_mode = 0, vertical_windows = 1
    integer(int32) :: hermite_width = 0, process_count = 1
    logical :: local_halo_ready = .false., on_demand_communication = .false.
    logical :: diffusion = .false., quadratic = .false., older_linear = .false.
    logical :: heat_diffusion = .false., turbulence = .false.
    logical :: coordinate_correction = .false., horizontal_correction = .false., vertical_correction = .false.
    logical :: static_physics_weights = .false., physics_diffusion = .false., physics_quadratic = .false.
    logical :: high_order_trajectories = .false., trajectory_weno = .false., vertical_filter = .false.
    logical :: regular_vertical_grid = .false.
    real(real64) :: minimum_blend = 0.0_real64, maximum_blend = 0.0_real64, reference_blend = 0.0_real64
    real(real64) :: high_order_horizontal = 0.0_real64, high_order_vertical = 0.0_real64
    real(real64) :: longitude_smoothing_epsilon = 0.0_real64
  end type
  !> Initialized grid tables. All pointer views are borrowed and read only.
  !! Latitude rows start at first_latitude. Longitude map rows start at
  !! longitude_first. Array storage itself starts at1 on every dimension.
  !! eta and vertical tables store physical node0 at array index1.
  !! Spline level storage starts at spline_first_level.
  type :: departure_weight_geometry
    integer(int32) :: first_latitude = 1, latitude_offset = 0, longitude_first = 0
    integer(int32) :: buffer_stride = 0, field_level = 1, spline_first_level = 0
    real(real64) :: latitude_multiplier = 0.0_real64, latitude_pole = 0.0_real64
    real(real64) :: lookup_scale = 0.0_real64
    integer(int32), pointer :: first_buffer(:) => null(), longitude_map(:, :) => null(), vertical_lookup(:) => null()
    real(real64), pointer :: latitude(:) => null(), longitude_scale(:) => null()
    real(real64), pointer :: latitude_reciprocals(:, :) => null(), latitude_quadratic(:, :) => null()
    real(real64), pointer :: latitude_diffusion(:, :, :) => null(), latitude_turbulence(:, :, :) => null()
    real(real64), pointer :: eta(:) => null(), vertical_cubic(:, :) => null(), vertical_quadratic(:, :) => null()
    real(real64), pointer :: vertical_diffusion(:, :, :) => null(), vertical_filter(:, :, :) => null()
    real(real64), pointer :: weno_gamma(:, :) => null(), spline(:, :, :) => null()
  end type
  !> Borrowed input fields use(column,level), with the column varying first.
  !! Only fields selected by the control flags are read.
  type :: departure_weight_inputs
    real(real64), pointer :: longitude(:, :) => null(), latitude(:, :) => null(), position(:, :) => null()
    real(real64), pointer :: kappa(:, :) => null(), heat_kappa(:, :) => null()
    real(real64), pointer :: momentum_turbulence(:, :) => null(), heat_turbulence(:, :) => null()
    real(real64), pointer :: longitude_correction_scale(:, :) => null()
    real(real64), pointer :: latitude_correction_scale(:, :) => null(), vertical_correction_scale(:, :) => null()
  end type
  !> Writable borrowed views retain their complete containing owners.
  !! Scalar fields use(column,level). Four-slot fields use(column,level,4),
  !! where array slots1:4 represent original latitude circles0:3.
  !! Latitude triples use(column,level,3,slot), and longitude triples use
  !! (column,level,3,central_circle,slot). Vertical triples use
  !! (column,level,3*window). Hermite derivatives use(column,level,2,2).
  !! Families are disjoint from each other and from all consumed inputs.
  type :: departure_weight_outputs
    real(real64), pointer :: latitude_fraction(:, :) => null(), latitude_correction_fraction(:, :) => null()
    real(real64), pointer :: longitude_fraction(:, :, :) => null(), longitude_correction_fraction(:, :, :) => null()
    integer(int32), pointer :: parent_index(:, :, :) => null(), horizontal_index(:, :, :) => null()
    integer(int32), pointer :: vertical_index(:, :) => null(), weno_shift(:, :) => null()
    real(real64), pointer :: vertical_fraction(:, :) => null(), vertical_correction_fraction(:, :) => null()
    real(real64), pointer :: latitude_main(:, :, :, :) => null(), latitude_correction(:, :, :, :) => null()
    real(real64), pointer :: latitude_filtered(:, :, :, :) => null(), latitude_heat(:, :, :) => null()
    real(real64), pointer :: longitude_main(:, :, :, :, :) => null(), longitude_correction(:, :, :, :, :) => null()
    real(real64), pointer :: longitude_filtered(:, :, :, :, :) => null(), longitude_heat(:, :, :, :) => null()
    real(real64), pointer :: vertical_main(:, :, :) => null(), vertical_correction(:, :, :) => null()
    real(real64), pointer :: vertical_diffusion(:, :, :) => null(), vertical_heat(:, :, :) => null()
    real(real64), pointer :: vertical_filtered(:, :, :) => null(), weno_combination(:, :, :) => null()
    real(real64), pointer :: spline_weight(:, :, :) => null(), hermite_value(:, :, :) => null()
    real(real64), pointer :: hermite_derivative(:, :, :, :) => null()
  end type
contains
  !> Prepare the complete selected LASCAW parent.
  !! pitch is0:1024 columns; levels is2:256. first:last selects columns.
  !! Inputs and geometry are not changed. Only selected output cells change.
  !! Status0 succeeds,1 refuses allocation and2 refuses a shape, table,
  !! source branch or child. A late child refusal leaves outputs unaccepted.
  !! Multiple processes require an already initialized local halo with every
  !! on-demand branch inactive; this entry performs no communication.
  subroutine prepare_departure_interpolation_weights(pitch, levels, first, last, c, g, p, w, status)
    integer(int32), intent(in) :: pitch, levels, first, last
    type(departure_weight_controls), intent(in) :: c
    type(departure_weight_geometry), intent(in) :: g
    type(departure_weight_inputs), intent(in) :: p
    type(departure_weight_outputs), intent(inout) :: w
    integer(int32), intent(out) :: status
    type(latitude_weight_controls) :: lc, physics_lc
    type(longitude_weight_controls) :: oc, physics_oc
    type(vertical_weight_controls) :: vc
    integer(int32), allocatable :: latitude_base(:, :), node(:, :), addresses(:, :, :), horizontal_addresses(:, :, :), &
                                   window_node(:, :)
    real(real64), allocatable, volatile :: latitude_distance(:, :)
    real(real64), allocatable :: latitude_mad(:, :), longitude_distance(:, :, :), longitude_mad(:, :, :)
    real(real64), allocatable :: vertical_distance(:, :), vertical_mad(:, :), cubic(:, :, :), mad_cubic(:, :, :)
    real(real64), allocatable :: turbulence(:, :, :), temporary_latitude(:, :, :), temporary_longitude(:, :, :, :)
    real(real64), pointer :: filtered_window(:, :, :)
    real(real64), volatile :: vertical_scale, empty_epsilon_product, empty_longitude_diagonal
    real(real64), parameter :: epsilon = 100.0_real64*tiny(1.0_real64)
    real(real64) :: latitude_nodes(4), distance(4), changed(4), denominator(3)
    real(real64) :: a, b, h, q, scaled, fraction, gap, one_minus, half_gap, numerator, den1, den2, d
    integer :: i, k, j, row, guess, base, v, lookup, lon, slot, first_slot, last_slot, table_count
    integer :: allocation_status, window, boundary_offset, start, physical_level, spline_level
    integer(int64) :: wide, offset
    integer(int32) :: child_status
    logical :: cubic_kind, three_dimensional, diffusion, quadratic, older, turbulent, correct_h, correct_v, weno
    logical :: high, need_heat, have_interior
    status = 2
    if (pitch < 0 .or. pitch > 1024 .or. levels < 2 .or. levels > 256) return
    if (first < 1 .or. first > pitch + 1 .or. last < 0 .or. last > pitch .or. last < first - 1) return
    if (c%slots < 1 .or. c%slots > 3 .or. c%horizontal_mode < 0 .or. c%horizontal_mode > 1) return
    if (c%vertical_windows /= 1 .and. c%vertical_windows /= 3) return
    if (c%hermite_width < 0 .or. c%hermite_width > 1 .or. c%process_count < 1) return
    if (c%on_demand_communication) return
    if (c%process_count /= 1 .and. .not. c%local_halo_ready) return
    select case (c%kind)
    case (101:106, 201:203)
    case default
      return
    end select
    three_dimensional = c%kind < 200
    cubic_kind = c%kind /= 101 .and. c%kind /= 201
    high = (c%kind >= 103 .and. c%kind <= 106) .or. c%kind == 203
    diffusion = c%diffusion .and. high
    quadratic = (c%quadratic .and. high) .or. &
                ((c%kind == 102 .or. c%kind == 202) .and. c%high_order_trajectories .and. &
                 (c%high_order_vertical /= 0.0_real64 .or. c%high_order_horizontal /= 0.0_real64))
    older = diffusion .and. c%older_linear
    turbulent = c%turbulence .and. c%kind >= 103 .and. c%kind <= 106
    correct_h = c%coordinate_correction .and. high .and. c%horizontal_correction
    correct_v = c%coordinate_correction .and. high .and. c%vertical_correction
    weno = c%kind == 106 .or. (c%kind == 102 .and. c%trajectory_weno)
    if (turbulent .and. c%slots /= 3) return
    if (weno .and. (c%vertical_windows /= 3 .or. levels < 4)) return
    if (c%kind == 104 .and. c%hermite_width /= 1) return
    if (c%kind == 102 .or. c%kind == 202) quadratic = c%high_order_horizontal /= 0.0_real64
    if (diffusion .and. .not. quadratic .and. .not. older) return
    if (c%static_physics_weights .and. cubic_kind .and. three_dimensional) then
      if (c%physics_diffusion .and. .not. c%physics_quadratic .and. .not. c%older_linear .and. c%kind /= 106) return
      if (c%physics_diffusion .and. c%kind == 106 .and. .not. c%older_linear) return
    end if
    if (three_dimensional) then
      if (.not. associated(g%eta)) return
      if (size(g%eta) < levels + 2) return
      gap = g%eta(levels + 2) - g%eta(1)
      vertical_scale = g%lookup_scale/gap
    end if
    status = 0
    if (pitch == 0 .or. first > last) then
      if (cubic_kind) then
        ! CLO prepares its smoothing coefficients even without active cells.
        empty_epsilon_product = 2.0_real64*c%longitude_smoothing_epsilon
        empty_longitude_diagonal = 1.0_real64 - empty_epsilon_product
      end if
      return
    end if
    status = 2
    if (.not. scalar_input(p%longitude) .or. .not. scalar_input(p%latitude)) return
    if (.not. scalar_output(w%latitude_fraction)) return
    if (.not. real3_has(w%longitude_fraction, 4) .or. .not. integer3_has(w%parent_index, 4)) return
    if (.not. associated(g%latitude) .or. .not. associated(g%longitude_scale)) return
    table_count = size(g%latitude)
    if (table_count < 4 .or. table_count > 4096 .or. size(g%longitude_scale) /= table_count) return
    if (.not. associated(g%first_buffer) .or. .not. associated(g%longitude_map)) return
    if (size(g%first_buffer) < table_count .or. size(g%longitude_map, 2) < table_count) return
    if (cubic_kind) then
      if (.not. associated(g%latitude_reciprocals)) return
      if (size(g%latitude_reciprocals, 1) /= table_count .or. size(g%latitude_reciprocals, 2) < 3) return
      if (.not. scalar_output(w%latitude_correction_fraction)) return
      if (.not. real3_has(w%longitude_correction_fraction, 4)) return
      if (.not. real4_has(w%latitude_main, 3, c%slots) .or. .not. real4_has(w%latitude_correction, 3, c%slots)) return
      if (.not. real4_has(w%latitude_filtered, 3, c%slots)) return
      if (.not. real5_has(w%longitude_main, 3, 2, c%slots) .or. .not. real5_has(w%longitude_correction, 3, 2, c%slots)) return
      if (.not. real5_has(w%longitude_filtered, 3, 2, c%slots)) return
      if (correct_h) then
        if (.not. scalar_input(p%latitude_correction_scale) .or. .not. scalar_input(p%longitude_correction_scale)) return
      end if
    end if
    if (three_dimensional) then
      if (.not. scalar_input(p%position) .or. .not. integer2_has(w%vertical_index)) return
      if (.not. scalar_output(w%vertical_fraction) .or. .not. associated(g%vertical_lookup)) return
      if (cubic_kind) then
        if (.not. integer3_has(w%horizontal_index, 4)) return
        if (.not. scalar_output(w%vertical_correction_fraction)) return
        if (.not. real3_has(w%vertical_main, 3*c%vertical_windows) .or. .not. real3_has(w%vertical_correction, 3)) return
        if (correct_v .and. .not. scalar_input(p%vertical_correction_scale)) return
        if (c%vertical_filter .and. .not. real3_has(w%vertical_filtered, 3*c%vertical_windows)) return
        if (diffusion .and. .not. real3_has(w%vertical_diffusion, 3)) return
        if (diffusion .and. c%heat_diffusion .and. .not. real3_has(w%vertical_heat, 3)) return
      end if
    end if
    need_heat = three_dimensional .and. cubic_kind .and. diffusion .and. c%heat_diffusion
    if (diffusion .and. .not. scalar_input(p%kappa)) return
    if (need_heat) then
      if (.not. scalar_input(p%heat_kappa)) return
      if (.not. real3_has(w%latitude_heat, 3) .or. .not. real4_has(w%longitude_heat, 3, 2)) return
    end if
    if (turbulent) then
      if (.not. scalar_input(p%momentum_turbulence) .or. .not. scalar_input(p%heat_turbulence)) return
    end if
    if (weno) then
      if (.not. integer2_has(w%weno_shift) .or. .not. real3_has(w%weno_combination, 3)) return
      if (.not. c%regular_vertical_grid) then
        if (.not. associated(g%weno_gamma)) return
        if (size(g%weno_gamma, 1) < levels .or. size(g%weno_gamma, 2) < 3) return
      end if
    end if
    if (c%kind == 104) then
      if (.not. real3_has(w%hermite_value, 4) .or. .not. real4_has(w%hermite_derivative, 2, 2)) return
    else if (c%kind == 105) then
      if (.not. real3_has(w%spline_weight, 4) .or. .not. associated(g%spline)) return
      if (size(g%spline, 1) < 4 .or. size(g%spline, 3) < 4) return
      if (g%spline_first_level > 0 .or. g%spline_first_level + size(g%spline, 2) - 1 < levels + 1) return
    end if
    allocate (latitude_base(pitch, levels), node(pitch, levels), addresses(pitch, levels, 4), &
              horizontal_addresses(pitch, levels, 4), window_node(pitch, levels), &
              latitude_distance(pitch, levels), latitude_mad(pitch, levels), &
              longitude_distance(pitch, levels, 4), longitude_mad(pitch, levels, 4), &
              vertical_distance(pitch, levels), vertical_mad(pitch, levels), &
              cubic(pitch, 3, levels), mad_cubic(pitch, 3, levels), turbulence(pitch, levels, c%slots), &
              temporary_latitude(pitch, levels, 3), temporary_longitude(pitch, levels, 3, 2), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      return
    end if
    turbulence = 0.0_real64
    if (turbulent) then
      do k = 1, levels
        do i = first, last
          turbulence(i, k, 2) = p%momentum_turbulence(i, k)
          turbulence(i, k, 3) = p%heat_turbulence(i, k)
        end do
      end do
    end if
    if (c%static_physics_weights) turbulence(first:last, 1:levels, c%slots) = 1.0_real64
    first_slot = 0
    last_slot = 3
    if (c%kind == 201) then
      first_slot = 1
      last_slot = 2
    end if
    do k = 1, levels
      physical_level = k
      if (c%horizontal_mode == 1) physical_level = g%field_level
      do i = first, last
        if (.not. ieee_is_finite(p%latitude(i, k)) .or. .not. ieee_is_finite(p%longitude(i, k))) return
        a = g%latitude_pole - p%latitude(i, k)
        a = g%latitude_multiplier*a
        a = a + 0.75_real64
        a = a + epsilon
        if (.not. safe_integer(a)) return
        guess = int(a, int32) - g%latitude_offset
        row = guess - g%first_latitude + 1
        if (row < 1 .or. row > table_count) return
        a = g%latitude(row) - p%latitude(i, k)
        a = a + epsilon
        base = guess - 1
        if (btest(transfer(a, 0_int64), 63)) base = guess - 2
        row = base - g%first_latitude + 1
        if (row < 1 .or. row + 3 > table_count) return
        latitude_base(i, k) = base
        latitude_nodes = g%latitude(row:row + 3)
        a = p%latitude(i, k) - latitude_nodes(2)
        b = latitude_nodes(3) - latitude_nodes(2)
        b = b + epsilon
        latitude_distance(i, k) = a/b
        if (c%kind == 202 .or. c%kind == 203) then
          a = p%latitude(i, k) - latitude_nodes(2)
          b = latitude_nodes(3) - latitude_nodes(2)
          latitude_distance(i, k) = a/b
        end if
        if (cubic_kind) then
          do j = 1, 4
            distance(j) = p%latitude(i, k) - latitude_nodes(j)
          end do
          denominator = g%latitude_reciprocals(row + 1, 1:3)
          call cubic_latitude(distance, denominator, cubic(i, :, k))
          if (correct_h) then
            h = p%latitude_correction_scale(i, k)
            one_minus = 1.0_real64 - h
            a = latitude_distance(i, k)*h
            b = 0.5_real64*one_minus
            latitude_mad(i, k) = a + b
            changed(1) = distance(1) - distance(2)
            changed(4) = distance(4) - distance(3)
            gap = latitude_nodes(3) - latitude_nodes(2)
            half_gap = 0.5_real64*gap
            half_gap = half_gap*one_minus
            a = distance(2)*h
            changed(2) = a + half_gap
            a = distance(3)*h
            changed(3) = a - half_gap
            changed(1) = changed(1) + changed(2)
            changed(4) = changed(4) + changed(3)
            call cubic_latitude(changed, denominator, mad_cubic(i, :, k))
          else
            latitude_mad(i, k) = latitude_distance(i, k)
            mad_cubic(i, :, k) = cubic(i, :, k)
          end if
        end if
        if (three_dimensional) then
          if (.not. ieee_is_finite(p%position(i, k))) return
          a = p%position(i, k)*vertical_scale
          if (.not. safe_integer(a)) return
          lookup = int(a, int32)
          if (lookup < 0 .or. lookup >= size(g%vertical_lookup)) return
          v = g%vertical_lookup(lookup + 1) - 1
          if (v < 0 .or. v > levels - 2) return
          if (v < levels - 2) then
            a = p%position(i, k) - g%eta(v + 3)
            if (a > 0.0_real64) v = v + 1
          end if
          node(i, k) = v
          a = p%position(i, k) - g%eta(v + 2)
          b = g%eta(v + 3) - g%eta(v + 2)
          vertical_distance(i, k) = a/b
          if (cubic_kind) then
            vertical_mad(i, k) = vertical_distance(i, k)
            if (correct_v) then
              h = p%vertical_correction_scale(i, k)
              a = vertical_distance(i, k)*h
              b = 1.0_real64 - h
              b = 0.5_real64*b
              vertical_mad(i, k) = a + b
            end if
          end if
        else
          v = physical_level
        end if
        do j = first_slot, last_slot
          scaled = p%longitude(i, k)*g%longitude_scale(row + j)
          if (.not. safe_integer(scaled)) return
          lon = int(scaled, int32)
          fraction = scaled - real(lon, real64)
          longitude_distance(i, k, j + 1) = fraction
          if (cubic_kind) then
            if (correct_h) then
              h = p%longitude_correction_scale(i, k)
              a = fraction*h
              b = 1.0_real64 - h
              b = 0.5_real64*b
              longitude_mad(i, k, j + 1) = a + b
            else
              longitude_mad(i, k, j + 1) = fraction
            end if
          end if
          lookup = lon - g%longitude_first + 1
          if (lookup < 1 .or. lookup > size(g%longitude_map, 1)) return
          offset = int(g%first_buffer(row + j), int64) - int(g%buffer_stride, int64)*int(g%field_level, int64)
          offset = offset + int(g%longitude_map(lookup, row + j), int64)
          wide = offset + int(g%buffer_stride, int64)*int(v, int64)
          if (.not. fits_word(wide)) return
          addresses(i, k, j + 1) = int(wide, int32)
          if (three_dimensional .and. cubic_kind) then
            wide = offset + int(g%buffer_stride, int64)*int(physical_level, int64)
            if (.not. fits_word(wide)) return
            horizontal_addresses(i, k, j + 1) = int(wide, int32)
          end if
        end do
      end do
    end do
    have_interior = .false.
    if (three_dimensional .and. cubic_kind) then
      have_interior = any(node(first:last, :) >= 1 .and. node(first:last, :) <= levels - 3)
      if (weno) then
        boundary_offset = 1
        if (c%regular_vertical_grid) boundary_offset = 0
        have_interior = have_interior .or. any(max(boundary_offset, node(first:last, :) - 1) >= 1 .and. &
                                               max(boundary_offset, node(first:last, :) - 1) <= levels - 3)
        have_interior = have_interior .or. any(min(levels - 2 - boundary_offset, node(first:last, :) + 1) >= 1 .and. &
                                               min(levels - 2 - boundary_offset, node(first:last, :) + 1) <= levels - 3)
      end if
      if (have_interior .and. .not. real3_has(w%vertical_diffusion, 3)) return
    end if
    do k = 1, levels
      do i = first, last
        w%latitude_fraction(i, k) = latitude_distance(i, k)
        do j = first_slot, last_slot
          w%longitude_fraction(i, k, j + 1) = longitude_distance(i, k, j + 1)
          w%parent_index(i, k, j + 1) = addresses(i, k, j + 1)
          if (cubic_kind) w%longitude_correction_fraction(i, k, j + 1) = longitude_mad(i, k, j + 1)
          if (cubic_kind .and. three_dimensional) w%horizontal_index(i, k, j + 1) = horizontal_addresses(i, k, j + 1)
        end do
        if (cubic_kind) w%latitude_correction_fraction(i, k) = latitude_mad(i, k)
        if (three_dimensional) then
          w%vertical_index(i, k) = node(i, k)
          w%vertical_fraction(i, k) = vertical_distance(i, k)
          if (cubic_kind) w%vertical_correction_fraction(i, k) = vertical_mad(i, k)
        end if
      end do
    end do
    status = 0
    if (.not. cubic_kind) return
    lc = latitude_weight_controls(diffusion, quadratic, older, .false., &
                                  c%minimum_blend, c%maximum_blend, c%reference_blend)
    oc = longitude_weight_controls(diffusion, quadratic, older, .false., &
                                   c%minimum_blend, c%maximum_blend, c%reference_blend, c%longitude_smoothing_epsilon)
    if (c%kind == 102 .or. c%kind == 202) then
      lc%minimum_blend = c%high_order_horizontal
      oc%minimum_blend = c%high_order_horizontal
    end if
    physics_lc = lc
    physics_lc%diffusion = c%physics_diffusion
    physics_lc%quadratic = c%physics_quadratic
    physics_lc%older_linear = c%older_linear
    if (c%kind == 106) physics_lc%quadratic = .false.
    physics_oc = oc
    physics_oc%diffusion = physics_lc%diffusion
    physics_oc%quadratic = physics_lc%quadratic
    physics_oc%older_linear = physics_lc%older_linear
    if (need_heat) then
      call horizontal_family(1, lc, oc, .false., .true., child_status, p%heat_kappa)
      if (child_status /= 0) then
        status = child_status
        return
      end if
    end if
    if (three_dimensional) then
      do slot = 1, c%slots
        if (c%static_physics_weights .and. slot == c%slots) then
          call horizontal_family(slot, physics_lc, physics_oc, .true., .false., child_status, turbulence(:, :, slot))
        else
          lc%turbulence = slot /= 1 .and. turbulent
          oc%turbulence = lc%turbulence
          call horizontal_family(slot, lc, oc, .false., .false., child_status, p%kappa)
        end if
        if (child_status /= 0) then
          status = child_status
          return
        end if
      end do
    else
      call horizontal_family(1, lc, oc, .false., .false., child_status, p%kappa)
      status = child_status
      return
    end if
    vc = vertical_weight_controls(correct_v, diffusion, quadratic, older, &
                                  c%vertical_filter, c%heat_diffusion, c%minimum_blend, c%maximum_blend, c%reference_blend)
    if (c%kind == 102) then
      vc%quadratic = c%high_order_vertical /= 0.0_real64
      vc%minimum_blend = c%high_order_vertical
    end if
    if (weno) then
      vc%minimum_blend = 0.0_real64
      w%weno_shift(first:last, 1:levels) = 0
      do window = 3, 1, -1
        do k = 1, levels
          do i = first, last
            v = node(i, k)
            select case (window)
            case (1)
              window_node(i, k) = v
            case (2)
              window_node(i, k) = min(levels - 2 - boundary_offset, v + 1)
              w%weno_shift(i, k) = w%weno_shift(i, k) + window_node(i, k) - v - 1
            case (3)
              window_node(i, k) = max(boundary_offset, v - 1)
              w%weno_shift(i, k) = w%weno_shift(i, k) + window_node(i, k) - v + 1
            end select
          end do
        end do
        call vertical_family(3*(window - 1) + 1, window_node, child_status)
        if (child_status /= 0) then
          status = child_status
          return
        end if
      end do
      if (any(w%weno_shift(first:last, 1:levels) > 1 + boundary_offset) .or. &
          any(w%weno_shift(first:last, 1:levels) < -1 - boundary_offset)) then
        status = 2
        return
      end if
      do k = 1, levels
        do i = first, last
          d = vertical_distance(i, k)
          if (c%regular_vertical_grid) then
            a = 0.10_real64*(2.0_real64 + d)
            w%weno_combination(i, k, 1) = a*(3.0_real64 - d)
            a = 0.05_real64*(2.0_real64 + d)
            w%weno_combination(i, k, 2) = a*(1.0_real64 + d)
            a = 0.05_real64*(2.0_real64 - d)
            w%weno_combination(i, k, 3) = a*(3.0_real64 - d)
          else
            v = node(i, k)
            if (v > 1 .and. v < levels - 3) then
              a = p%position(i, k) - g%eta(v)
              b = p%position(i, k) - g%eta(v + 5)
              a = g%weno_gamma(v, 1)*a
              w%weno_combination(i, k, 1) = a*b
              a = p%position(i, k) - g%eta(v)
              b = p%position(i, k) - g%eta(v + 1)
              a = g%weno_gamma(v, 2)*a
              w%weno_combination(i, k, 2) = a*b
              a = p%position(i, k) - g%eta(v + 4)
              b = p%position(i, k) - g%eta(v + 5)
              a = g%weno_gamma(v, 3)*a
              w%weno_combination(i, k, 3) = a*b
            end if
          end if
        end do
      end do
    else
      call vertical_family(1, node, child_status)
      if (child_status /= 0) then
        status = child_status
        return
      end if
    end if
    if (c%kind == 104) then
      do k = 1, levels
        do i = first, last
          d = vertical_distance(i, k)
          a = 1.0_real64 - d
          b = a*a
          q = 2.0_real64*d
          q = 1.0_real64 + q
          w%hermite_value(i, k, 1) = b*q
          a = d*d
          b = 2.0_real64*d
          b = 3.0_real64 - b
          w%hermite_value(i, k, 2) = a*b
          a = 1.0_real64 - d
          b = d*a
          w%hermite_value(i, k, 3) = b*a
          a = -d
          a = a*d
          b = 1.0_real64 - d
          w%hermite_value(i, k, 4) = a*b
          v = node(i, k)
          numerator = g%eta(v + 3) - g%eta(v + 2)
          den1 = g%eta(v + 3) - g%eta(v + 1)
          den1 = 0.5_real64*den1
          den2 = g%eta(v + 4) - g%eta(v + 2)
          den2 = 0.5_real64*den2
          a = 0.5_real64*numerator
          if (v == 0) then
            h = a/den2
            w%hermite_derivative(i, k, 1, 1) = 0.0_real64
            w%hermite_derivative(i, k, 2, 1) = numerator/den1
            w%hermite_derivative(i, k, 1, 2) = h
            w%hermite_derivative(i, k, 2, 2) = h
          else if (v == levels - 2) then
            b = a/den1
            w%hermite_derivative(i, k, 1, 1) = b
            w%hermite_derivative(i, k, 2, 1) = b
            w%hermite_derivative(i, k, 1, 2) = numerator/den2
            w%hermite_derivative(i, k, 2, 2) = 0.0_real64
          else
            b = a/den1
            h = a/den2
            w%hermite_derivative(i, k, 1, 1) = b
            w%hermite_derivative(i, k, 2, 1) = b
            w%hermite_derivative(i, k, 1, 2) = h
            w%hermite_derivative(i, k, 2, 2) = h
          end if
        end do
      end do
    else if (c%kind == 105) then
      do k = 1, levels
        do i = first, last
          v = node(i, k)
          d = p%position(i, k) - g%eta(v + 2)
          do j = 1, 4
            spline_level = v + j - 1 - g%spline_first_level + 1
            a = d*g%spline(5 - j, spline_level, 4)
            a = g%spline(5 - j, spline_level, 3) + a
            a = d*a
            a = g%spline(5 - j, spline_level, 2) + a
            a = d*a
            w%spline_weight(i, k, j) = g%spline(5 - j, spline_level, 1) + a
          end do
        end do
      end do
    end if
    status = 0
  contains
    logical function scalar_input(a)
      real(real64), pointer, intent(in) :: a(:, :)
      scalar_input = .false.
      if (.not. associated(a)) return
      scalar_input = size(a, 1) == pitch .and. size(a, 2) >= levels
    end function
    logical function scalar_output(a)
      real(real64), pointer, intent(in) :: a(:, :)
      scalar_output = scalar_input(a)
    end function
    logical function real3_has(a, n)
      real(real64), pointer, intent(in) :: a(:, :, :)
      integer, intent(in) :: n
      real3_has = .false.
      if (.not. associated(a)) return
      real3_has = size(a, 1) == pitch .and. size(a, 2) >= levels .and. size(a, 3) >= n
    end function
    logical function real4_has(a, n, m)
      real(real64), pointer, intent(in) :: a(:, :, :, :)
      integer, intent(in) :: n, m
      real4_has = .false.
      if (.not. associated(a)) return
      real4_has = size(a, 1) == pitch .and. size(a, 2) >= levels .and. size(a, 3) >= n .and. size(a, 4) >= m
    end function
    logical function real5_has(a, n, m, l)
      real(real64), pointer, intent(in) :: a(:, :, :, :, :)
      integer, intent(in) :: n, m, l
      real5_has = .false.
      if (.not. associated(a)) return
      real5_has = size(a, 1) == pitch .and. size(a, 2) >= levels .and. size(a, 3) >= n .and. size(a, 4) >= m .and. size(a, 5) >= l
    end function
    logical function integer2_has(a)
      integer(int32), pointer, intent(in) :: a(:, :)
      integer2_has = .false.
      if (.not. associated(a)) return
      integer2_has = size(a, 1) == pitch .and. size(a, 2) >= levels
    end function
    logical function integer3_has(a, n)
      integer(int32), pointer, intent(in) :: a(:, :, :)
      integer, intent(in) :: n
      integer3_has = .false.
      if (.not. associated(a)) return
      integer3_has = size(a, 1) == pitch .and. size(a, 2) >= levels .and. size(a, 3) >= n
    end function
    subroutine horizontal_family(s, latitude_control, longitude_control, physics, heat, result, kap)
      integer, intent(in) :: s
      type(latitude_weight_controls), intent(in) :: latitude_control
      type(longitude_weight_controls), intent(in) :: longitude_control
      logical, intent(in) :: physics, heat
      integer(int32), intent(out) :: result
      real(real64), intent(in), optional :: kap(:, :)
      integer :: circle
      if (physics) then
        call blend_latitude_interpolation_weights(latitude_control, pitch, first, last, levels, g%first_latitude, table_count, &
                                                  latitude_base, cubic, mad_cubic, temporary_latitude, w%latitude_correction(:, :, &
                                                                                                                             :, s), w%latitude_main(:, :, :, &
                                                                                                                                                    s), result, &
                                                  latitude_distance, kap, turbulence(:, :, s), g%latitude_quadratic, &
                                                  g%latitude_diffusion, g%latitude_turbulence)
      else if (heat) then
        call blend_latitude_interpolation_weights(latitude_control, pitch, first, last, levels, g%first_latitude, table_count, &
                                                  latitude_base, cubic, mad_cubic, w%latitude_main(:, :, :, 1), &
                                                  w%latitude_correction(:, :, :, 1), &
                                                  w%latitude_heat, result, &
                                                  latitude_distance, kap, turbulence(:, :, 1), g%latitude_quadratic, &
                                                  g%latitude_diffusion, g%latitude_turbulence)
      else
        call blend_latitude_interpolation_weights(latitude_control, pitch, first, last, levels, g%first_latitude, table_count, &
                                                  latitude_base, cubic, mad_cubic, w%latitude_main(:, :, :, s), &
                                                  w%latitude_correction(:, :, :, s), w%latitude_filtered(:, &
                                                                                                         :, :, s), result, &
                                                  latitude_distance, kap, turbulence(:, :, s), g%latitude_quadratic, &
                                                  g%latitude_diffusion, g%latitude_turbulence)
      end if
      if (result /= 0) return
      do circle = 1, 2
        if (physics) then
          call blend_longitude_interpolation_weights(longitude_control, pitch, first, last, levels, &
                                                     longitude_distance(:, :, circle + 1), longitude_mad(:, :, circle + 1), &
                                                     temporary_longitude(:, :, :, circle), &
                                                     w%longitude_correction(:, :, :, circle, s), w%longitude_main(:, :, :, circle, &
                                                                                                                  s), result, kap, &
                                                     turbulence(:, &
                                                                :, s))
        else if (heat) then
          call blend_longitude_interpolation_weights(longitude_control, pitch, first, last, levels, &
                                                     longitude_distance(:, :, circle + 1), longitude_mad(:, :, circle + 1), &
                                                     w%longitude_main(:, :, :, circle, 1), &
                                                     w%longitude_correction(:, :, :, circle, 1), w%longitude_heat(:, :, :, &
                                                                                                                  circle), result, &
                                                     kap, &
                                                     turbulence(:, &
                                                                :, 1))
        else
          call blend_longitude_interpolation_weights(longitude_control, pitch, first, last, levels, &
                                                     longitude_distance(:, :, circle + 1), longitude_mad(:, :, circle + 1), &
                                                     w%longitude_main(:, :, :, circle, s), &
                                                     w%longitude_correction(:, :, :, circle, s), w%longitude_filtered(:, :, :, &
                                                                                                                      circle, s), result, kap, turbulence(:, :, s))
        end if
        if (result /= 0) return
      end do
    end subroutine
    subroutine vertical_family(start_index, indices, result)
      integer, intent(in) :: start_index
      integer(int32), intent(in) :: indices(:, :)
      integer(int32), intent(out) :: result
      nullify (filtered_window)
      if (associated(w%vertical_filtered)) filtered_window => w%vertical_filtered(:, :, start_index:start_index + 2)
      call blend_vertical_interpolation_weights(vc, pitch, first, last, levels, indices, &
                                                w%vertical_main(:, :, start_index:start_index + 2), w%vertical_correction, result, &
                                                w%vertical_diffusion, w%vertical_heat, filtered_window, p%position, &
                                                vertical_distance, vertical_mad, &
                                                p%vertical_correction_scale, p%kappa, p%heat_kappa, g%eta, g%vertical_cubic, &
                                                g%vertical_quadratic, &
                                                g%vertical_diffusion, g%vertical_filter)
    end subroutine
  end subroutine
  subroutine cubic_latitude(distance, reciprocal, result)
    real(real64), intent(in) :: distance(4), reciprocal(3)
    real(real64), intent(out) :: result(3)
    real(real64) :: a
    a = distance(1)*distance(3)
    a = a*distance(4)
    result(1) = a*reciprocal(1)
    a = distance(1)*distance(2)
    a = a*distance(4)
    result(2) = a*reciprocal(2)
    a = distance(1)*distance(2)
    a = a*distance(3)
    result(3) = a*reciprocal(3)
  end subroutine
  logical function safe_integer(a)
    real(real64), intent(in) :: a
    safe_integer = .false.
    if (.not. ieee_is_finite(a)) return
    safe_integer = a >= real(-huge(0_int32) + 1, real64) .and. a <= real(huge(0_int32) - 1, real64)
  end function
  logical function fits_word(a)
    integer(int64), intent(in) :: a
    fits_word = a >= -int(huge(0_int32), int64) - 1_int64 .and. a <= int(huge(0_int32), int64)
  end function
end module

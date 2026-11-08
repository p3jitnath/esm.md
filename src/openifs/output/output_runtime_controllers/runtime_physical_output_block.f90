!> Calculate the selected physical output fields from the actual native surface owners.
!! Snow mass uses kg m**(-2), density kg m**(-3), temperature K and precipitation its source units.
!! The caller establishes nearest-even arithmetic and gradual underflow once.
module forecast_runtime_physical_output_block
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_loc, c_intptr_t
  use forecast_output_request_types, only: trqfp
  use surface_field_storage_port, only: surface_field_state
  use surface_field_configuration_port, only: surface_field_registry
  use surface_field_registration_port, only: surface_field_metadata
  use yomafn, only: tafn
  implicit none
  private
  public :: native_physical_output_controls, calculate_physical_output_block, physical_output_block_workspace_bytes
 public :: borrow_physical_surface_plane, physical_surface_field_is_set, physical_surface_field_flag, admit_physical_output_controls
  type :: native_physical_output_controls
    integer(int32) :: block_width = 0, local_points = 0, soil_layers = 0, snow_layers = 0
    integer(int32) :: cumulative_flux_fields = 0, instant_flux_fields = 0
    logical :: lephys = .false., lmphys = .false., lnemocoUP = .false., hook_enabled = .false.
    real(real64) :: gravity, standard_lapse
    integer(int64) :: budget_bytes = 0
  end type
  type :: native_physical_field_plan
    real(real64), pointer :: first(:) => null(), second(:) => null()
    integer(int32) :: operation = 0
  end type
  integer, parameter :: source_alias(103) = [ &
                        244, 245, 167, 168, 170, 169, 194, 5, 158, 227, 312, 56, 155, 207, 209, 178, &
                        242, 176, 157, 0, 186, 183, 198, 195, 196, 197, 3, 3, 3, 3, 181, 184, &
                        206, 208, 35, 154, 247, 211, 213, 182, 185, 188, 164, 187, 177, 179, 210, 191, &
                        192, 193, 156, 16, 160, 243, 17, 159, 172, 240, 223, 42, 57, 58, 1, 1, &
                        1, 1, 173, 241, 224, 228, 2, 2, 2, 2, 166, 248, 4, 0, 7, 6, &
                        8, 216, 217, 218, 219, 220, 221, 154, 174, 238, 175, 239, 249, 258, 212, 259, &
                        262, 263, 229, 230, 231, 251, 254]
  integer, parameter :: source_level(103) = [ &
                        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
                        1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 2, 3, 4, 1, 1, &
                        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
                        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, &
                        3, 4, 1, 1, 1, 1, 1, 2, 3, 4, 1, 1, 1, 1, 1, 1, &
                        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, &
                        1, 1, 1, 1, 1, 1, 1]
  integer, parameter :: source_policy(103) = [ &
                        0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, &
                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, &
                        0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, &
                        0, 0, 0, 3, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 1, 1, &
                        1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, &
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, &
                        0, 0, 0, 0, 0, 0, 0]
  integer, parameter :: source_operation(103) = [ &
                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, &
                        0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, &
                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, &
                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, &
                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 6, 3, 2, &
                        5, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, &
                        0, 0, 0, 0, 0, 0, 0]
  character(32), parameter :: source_alias_name(103) = [character(32) :: &
                                                        'YSD_VD%Y10FG', &
                                                        'YSD_VD%YI10FG', &
                                                        'YSD_VD%Y10U', &
                                                        'YSD_VD%Y10V', &
                                                        'YSD_VD%Y2D', &
                                                        'YSD_VD%Y2T', &
                                                        'YSD_VD%YALB', &
                                                        'YSP_SG%YA', &
                                                        'YSD_VD%YBLD', &
                                                        'YSD_VD%YBLH', &
                                                        'YSD_WS%YCHAR', &
                                                        'YSD_VF%YCI', &
                                                        'YSD_VD%YCP', &
                                                        'YSD_VD%YCRR', &
                                                        'YSD_VD%YCSFR', &
                                                        'YSD_VD%YE', &
                                                        'YSD_VD%YES', &
                                                        'YSD_VD%YEWSS', &
                                                        'YSD_VD%YFZRA', &
                                                        '', &
                                                        'YSD_VD%YGWD', &
                                                        'YSD_VD%YHCC', &
                                                        'YSD_VD%YIE', &
                                                        'YSD_VD%YIEWSS', &
                                                        'YSD_VD%YINSSS', &
                                                        'YSD_VD%YISSHF', &
                                                        'YSP_SB%YTL', &
                                                        'YSP_SB%YTL', &
                                                        'YSP_SB%YTL', &
                                                        'YSP_SB%YTL', &
                                                        'YSD_VD%YLCC', &
                                                        'YSD_VD%YLGWS', &
                                                        'YSD_VD%YLSRR', &
                                                        'YSD_VD%YLSSFR', &
                                                        'YSD_VF%YLSM', &
                                                        'YSD_VD%YLSP', &
                                                        'YSD_VD%YLSPF', &
                                                        'YSD_VD%YILSPF', &
                                                        'YSD_VD%YLZ0H', &
                                                        'YSD_VD%YMCC', &
                                                        'YSD_VD%YMGWS', &
                                                        'YSD_VD%YMN2T', &
                                                        'YSD_VD%YMSL', &
                                                        'YSD_VD%YMX2T', &
                                                        'YSD_VD%YNSSS', &
                                                        'YSD_VD%YPEV', &
                                                        'YSD_VD%YPTYPE', &
                                                        'YSD_VD%YRO', &
                                                        'YSD_VD%YSRO', &
                                                        'YSD_VD%YSSRO', &
                                                        'YSD_VD%YSF', &
                                                        'YSP_RR%YT', &
                                                        'YSD_VD%YSLHF', &
                                                        'YSD_VD%YSMLT', &
                                                        'YSP_RR%YW', &
                                                        'YSD_VD%YSSHF', &
                                                        'YSD_VD%YSSR', &
                                                        'YSD_VD%YSSRC', &
                                                        'YSD_VD%YSSRD', &
                                                        'YSD_VF%YSST', &
                                                        'YSD_VF%YUCUR', &
                                                        'YSD_VF%YVCUR', &
                                                        'YSP_SB%YT', &
                                                        'YSP_SB%YT', &
                                                        'YSP_SB%YT', &
                                                        'YSP_SB%YT', &
                                                        'YSD_VD%YSTR', &
                                                        'YSD_VD%YSTRC', &
                                                        'YSD_VD%YSTRD', &
                                                        'YSD_VD%YSUND', &
                                                        'YSP_SB%YQ', &
                                                        'YSP_SB%YQ', &
                                                        'YSP_SB%YQ', &
                                                        'YSP_SB%YQ', &
                                                        'YSD_VD%YTCC', &
                                                        'YSD_VD%YTCO3', &
                                                        'YSP_SG%YF', &
                                                        '', &
                                                        'YSP_SG%YT', &
                                                        'YSP_SG%YR', &
                                                        'YSP_SG%YW', &
                                                        'YSD_VD%YTCW', &
                                                        'YSD_VD%YTCWV', &
                                                        'YSD_VD%YTCLW', &
                                                        'YSD_VD%YTCIW', &
                                                        'YSD_VD%YTCRW', &
                                                        'YSD_VD%YTCSW', &
                                                        'YSD_VD%YLSP', &
                                                        'YSD_VD%YTSR', &
                                                        'YSD_VD%YTSRC', &
                                                        'YSD_VD%YTTR', &
                                                        'YSD_VD%YTTRC', &
                                                        'YSD_VD%YVIMD', &
                                                        'YSD_VD%YVISIH', &
                                                        'YSD_VD%YZ0F', &
                                                        'YSD_VD%YCIN', &
                                                        'YSD_VD%YKINDEX', &
                                                        'YSD_VD%YTTINDEX', &
                                                        'YSD_VD%YSPAR', &
                                                        'YSD_VD%YSUVB', &
                                                        'YSD_VD%YCAPE', &
                                                        'YSD_VD%YSTINC', &
                                                        'YSD_VD%YSDSRP']
contains
  !> Admit the source ECMWF, uncoupled, no-flux route using live dimensions.
  integer(int32) function admit_physical_output_controls(controls) result(status)
    type(native_physical_output_controls), intent(in) :: controls
    status = 2
    if (controls%block_width < 1 .or. controls%block_width > 1024 .or. controls%local_points < 1) return
    if (controls%soil_layers < 1 .or. controls%soil_layers > 256) return
    if (controls%snow_layers < 1 .or. controls%snow_layers > 6) return
    if (.not. controls%lephys .or. controls%lmphys .or. controls%lnemocoUP .or. controls%hook_enabled) return
    if (controls%cumulative_flux_fields /= 0 .or. controls%instant_flux_fields /= 0) return
    if (controls%budget_bytes <= 0 .or. controls%budget_bytes > 68719476736_int64) return
    status = 0
  end function
  !> Read canonical LSET as 0/1, or return -1 for an invalid named catalog relation.
  integer function physical_surface_field_flag(registry, alias_index, expected_name) result(flag)
    type(surface_field_registry), intent(in) :: registry
    integer, intent(in) :: alias_index
    character(*), intent(in) :: expected_name
    integer :: group, field
    flag = -1
    if (alias_index < 1 .or. alias_index > size(registry%aliases)) return
    if (registry%aliases(alias_index)%name /= expected_name) return
    group = registry%aliases(alias_index)%group
    field = registry%aliases(alias_index)%first_field
    if (group < 1 .or. group > 34) return
    if (.not. allocated(registry%groups(group)%fields)) return
    if (field < 1 .or. field > size(registry%groups(group)%fields)) return
    flag = registry%groups(group)%fields(field)%initialized
    if (flag < 0 .or. flag > 1) flag = -1
  end function
  logical function physical_surface_field_is_set(registry, alias_index, expected_name) result(is_set)
    type(surface_field_registry), intent(in) :: registry
    integer, intent(in) :: alias_index
    character(*), intent(in) :: expected_name
    is_set = physical_surface_field_flag(registry, alias_index, expected_name) == 1
  end function
  !> Borrow one exact block/layer plane with the actual source MP or MP0 index.
  !! policy bit0 selects MP0; bit1 permits absent LSET; bit2 requires LSET.
  !! A permitted absent field returns a null view. No physical value is manufactured.
  subroutine borrow_physical_surface_plane(state, registry, alias_index, expected_name, level, policy, &
                                           block, controls, values, status)
    type(surface_field_state), target, intent(in) :: state
    type(surface_field_registry), target, intent(in) :: registry
    integer, intent(in) :: alias_index, level, policy, block
    character(*), intent(in) :: expected_name
    type(native_physical_output_controls), intent(in) :: controls
    real(real64), pointer, intent(out) :: values(:)
    integer(int32), intent(out) :: status
    type(surface_field_metadata), pointer :: field
    integer :: group, position, index, width, layers
    integer(int64) :: span
    nullify (values)
    status = 2
    width = controls%block_width
    if (alias_index < 1 .or. alias_index > size(registry%aliases) .or. block < 1) return
    if (registry%aliases(alias_index)%name /= expected_name) return
    group = registry%aliases(alias_index)%group
    position = registry%aliases(alias_index)%first_field
    if (group < 1 .or. group > 34) return
    if (.not. allocated(registry%groups(group)%fields)) return
    if (position < 1 .or. position > size(registry%groups(group)%fields)) return
    field => registry%groups(group)%fields(position)
    if (btest(policy, 1) .or. btest(policy, 2)) then
      if (field%initialized < 0 .or. field%initialized > 1) return
      if (field%initialized == 0) then
        if (btest(policy, 1)) status = 0
        return
      end if
    end if
    index = field%indices(1)
    if (btest(policy, 0)) index = field%indices(2)
    if (index < 1) return
    layers = 1
    select case (group)
    case (1)
      if (.not. allocated(state%sp_sb)) return
      if (size(state%sp_sb, 1) /= width .or. block > size(state%sp_sb, 4)) return
      if (any(lbound(state%sp_sb) /= 1)) return
      if (index > size(state%sp_sb, 3) .or. size(state%sp_sb, 3) > 65536) return
      layers = controls%soil_layers
      if (size(state%sp_sb, 2) /= layers .or. level < 1 .or. level > layers) return
      span = 8_int64*width*layers*size(state%sp_sb, 3, kind=int64)
      if (span > controls%budget_bytes) return
      values => state%sp_sb(:, level, index, block)
    case (2)
      if (.not. allocated(state%sp_sg)) return
      if (size(state%sp_sg, 1) /= width .or. block > size(state%sp_sg, 4)) return
      if (any(lbound(state%sp_sg) /= 1)) return
      if (index > size(state%sp_sg, 3) .or. size(state%sp_sg, 3) > 65536) return
      layers = controls%snow_layers
      if (size(state%sp_sg, 2) /= layers .or. level < 1 .or. level > layers) return
      span = 8_int64*width*layers*size(state%sp_sg, 3, kind=int64)
      if (span > controls%budget_bytes) return
      values => state%sp_sg(:, level, index, block)
    case (4)
      if (.not. allocated(state%sp_rr)) return
      if (size(state%sp_rr, 1) /= width .or. block > size(state%sp_rr, 3)) return
      if (any(lbound(state%sp_rr) /= 1)) return
      if (index > size(state%sp_rr, 2) .or. size(state%sp_rr, 2) > 65536) return
      span = 8_int64*width*layers*size(state%sp_rr, 2, kind=int64)
      if (span > controls%budget_bytes) return
      values => state%sp_rr(:, index, block)
    case (10)
      if (.not. allocated(state%sd_vf)) return
      if (size(state%sd_vf, 1) /= width .or. block > size(state%sd_vf, 3)) return
      if (any(lbound(state%sd_vf) /= 1)) return
      if (index > size(state%sd_vf, 2) .or. size(state%sd_vf, 2) > 65536) return
      span = 8_int64*width*layers*size(state%sd_vf, 2, kind=int64)
      if (span > controls%budget_bytes) return
      values => state%sd_vf(:, index, block)
    case (12)
      if (.not. allocated(state%sd_vv)) return
      if (size(state%sd_vv, 1) /= width .or. block > size(state%sd_vv, 3)) return
      if (any(lbound(state%sd_vv) /= 1)) return
      if (index > size(state%sd_vv, 2) .or. size(state%sd_vv, 2) > 65536) return
      span = 8_int64*width*layers*size(state%sd_vv, 2, kind=int64)
      if (span > controls%budget_bytes) return
      values => state%sd_vv(:, index, block)
    case (21)
      if (.not. allocated(state%sd_vd)) return
      if (size(state%sd_vd, 1) /= width .or. block > size(state%sd_vd, 3)) return
      if (any(lbound(state%sd_vd) /= 1)) return
      if (index > size(state%sd_vd, 2) .or. size(state%sd_vd, 2) > 65536) return
      span = 8_int64*width*layers*size(state%sd_vd, 2, kind=int64)
      if (span > controls%budget_bytes) return
      values => state%sd_vd(:, index, block)
    case (23)
      if (.not. allocated(state%sd_ws)) return
      if (size(state%sd_ws, 1) /= width .or. block > size(state%sd_ws, 3)) return
      if (any(lbound(state%sd_ws) /= 1)) return
      if (index > size(state%sd_ws, 2) .or. size(state%sd_ws, 2) > 65536) return
      span = 8_int64*width*layers*size(state%sd_ws, 2, kind=int64)
      if (span > controls%budget_bytes) return
      values => state%sd_ws(:, index, block)
    case (25)
      if (.not. allocated(state%sd_vx)) return
      if (size(state%sd_vx, 1) /= width .or. block > size(state%sd_vx, 3)) return
      if (any(lbound(state%sd_vx) /= 1)) return
      if (index > size(state%sd_vx, 2) .or. size(state%sd_vx, 2) > 65536) return
      span = 8_int64*width*layers*size(state%sd_vx, 2, kind=int64)
      if (span > controls%budget_bytes) return
      values => state%sd_vx(:, index, block)
    case default
      return
    end select
    status = 0
  end subroutine
  !> Return the declared native plan and snow workspace bytes, rounded up to16.
  integer(int64) function physical_output_block_workspace_bytes(fields, width, snow_layers) result(bytes)
    integer, intent(in) :: fields, width, snow_layers
    type(native_physical_field_plan) :: example
    bytes = 0
    if (fields < 1 .or. fields > 1639 .or. width < 1 .or. width > 1024 .or. snow_layers < 1 .or. snow_layers > 6) return
    bytes = 512_int64 + int(fields + snow_layers, int64)*(storage_size(example)/8) + 24_int64*width
    bytes = 16_int64*((bytes + 15_int64)/16_int64)
  end function
  !> Build every source request plan before numerical output, then publish the complete block.
  !! output has(block_width,field_count) elements. Its padding rows become positive zero.
  !! terrain contains the actual active block extent and keeps geopotential units m**2 s**(-2).
  !! No owner is acquired. Native automatic work stays on the compiler-managed stack.
  integer(int32) function calculate_physical_output_block(request, science_cli, afn, horizontal, &
                                                     state, registry, terrain, block, active_count, controls, output) result(status)
    type(trqfp), target, intent(in) :: request
    integer(int32), intent(in) :: science_cli, block, active_count
    type(tafn), target, intent(in) :: afn
    logical, intent(in) :: horizontal
    type(surface_field_state), target, intent(in) :: state
    type(surface_field_registry), target, intent(in) :: registry
    real(real64), target, intent(in) :: terrain(:)
    type(native_physical_output_controls), target, intent(in) :: controls
    real(real64), target, intent(inout) :: output(:, :)
    type(native_physical_field_plan) :: example
    integer :: width, count, blocks, expected
    integer(int64) :: workspace, output_bytes
    status = 2
    if (admit_physical_output_controls(controls) /= 0 .or. horizontal .or. science_cli /= 0) return
    width = controls%block_width
    count = request%nfieldg
    blocks = int((int(controls%local_points, int64) + width - 1)/width)
    if (block < 1 .or. block > blocks .or. active_count < 1 .or. active_count > width) return
    expected = min(width, controls%local_points - (block - 1)*width)
    if (active_count /= expected .or. size(terrain) < active_count) return
    if (count < 1 .or. count > 1639) return
    if (.not. allocated(request%icod)) return
    if (size(request%icod) /= count .or. lbound(request%icod, 1) /= 1) return
    if (size(output, 1) /= width .or. size(output, 2) /= count .or. .not. is_contiguous(output)) return
    workspace = physical_output_block_workspace_bytes(count, width, controls%snow_layers)
    if (workspace > controls%budget_bytes .or. 8_int64*width*count > controls%budget_bytes) return
    output_bytes = 8_int64*width*count
    if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(request), int(storage_size(request), int64)/8)) return
    if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(afn), int(storage_size(afn), int64)/8)) return
    if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state), int(storage_size(state), int64)/8)) return
    if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(registry), int(storage_size(registry), int64)/8)) return
    if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(controls), int(storage_size(controls), int64)/8)) return
   if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(request%icod), 4_int64*size(request%icod, kind=int64))) return
    if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(terrain), 8_int64*size(terrain, kind=int64))) return
    if (allocated(state%sp_sb)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sp_sb), &
                                      8_int64*size(state%sp_sb, kind=int64))) return
    end if
    if (allocated(state%sp_sg)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sp_sg), &
                                      8_int64*size(state%sp_sg, kind=int64))) return
    end if
    if (allocated(state%sp_sl)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sp_sl), &
                                      8_int64*size(state%sp_sl, kind=int64))) return
    end if
    if (allocated(state%sp_rr)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sp_rr), &
                                      8_int64*size(state%sp_rr, kind=int64))) return
    end if
    if (allocated(state%sp_ci)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sp_ci), &
                                      8_int64*size(state%sp_ci, kind=int64))) return
    end if
    if (allocated(state%sd_ws)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sd_ws), &
                                      8_int64*size(state%sd_ws, kind=int64))) return
    end if
    if (allocated(state%sd_vd)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sd_vd), &
                                      8_int64*size(state%sd_vd, kind=int64))) return
    end if
    if (allocated(state%sd_vx)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sd_vx), &
                                      8_int64*size(state%sd_vx, kind=int64))) return
    end if
    if (allocated(state%sd_vf)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sd_vf), &
                                      8_int64*size(state%sd_vf, kind=int64))) return
    end if
    if (allocated(state%sd_vv)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sd_vv), &
                                      8_int64*size(state%sd_vv, kind=int64))) return
    end if
    if (allocated(state%sd_vp)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sd_vp), &
                                      8_int64*size(state%sd_vp, kind=int64))) return
    end if
    if (allocated(state%sd_va)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sd_va), &
                                      8_int64*size(state%sd_va, kind=int64))) return
    end if
    if (allocated(state%sd_vc)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sd_vc), &
                                      8_int64*size(state%sd_vc, kind=int64))) return
    end if
    if (allocated(state%sd_x2)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sd_x2), &
                                      8_int64*size(state%sd_x2, kind=int64))) return
    end if
    if (allocated(state%sd_sm)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sd_sm), &
                                      8_int64*size(state%sd_sm, kind=int64))) return
    end if
    if (allocated(state%sd_oc)) then
      if (.not. native_spans_disjoint(c_loc(output), output_bytes, c_loc(state%sd_oc), &
                                      8_int64*size(state%sd_oc, kind=int64))) return
    end if
    block
      type(native_physical_field_plan) :: plan(count), snow_sources(controls%snow_layers)
      real(real64), target :: snow_mass(width), snow_density(width), snow_temperature(width)
      real(real64), pointer :: mass(:), density(:), temperature(:), water(:), next_mass(:), next_density(:)
      real(real64), volatile :: lapse_over_gravity
      real(real64) :: sum_mass, sum_depth, mass_value, part
      integer :: field, selected, kind, level, counter(4), point, layer, operation, flag
      integer(int32) :: child
      child = 0
      call borrow_physical_surface_plane(state, registry, 4, 'YSP_SG%YF', 1, 5, block, controls, mass, child)
      if (child /= 0) return
      call borrow_physical_surface_plane(state, registry, 6, 'YSP_SG%YR', 1, 5, block, controls, density, child)
      if (child /= 0) return
      call borrow_physical_surface_plane(state, registry, 7, 'YSP_SG%YT', 1, 5, block, controls, temperature, child)
      if (child /= 0) return
      call borrow_physical_surface_plane(state, registry, 8, 'YSP_SG%YW', 1, 5, block, controls, water, child)
      if (child /= 0) return
      do layer = 1, controls%snow_layers
        call borrow_physical_surface_plane(state, registry, 4, 'YSP_SG%YF', layer, 5, block, &
                                           controls, snow_sources(layer)%first, child)
        if (child /= 0) return
        call borrow_physical_surface_plane(state, registry, 6, 'YSP_SG%YR', layer, 5, block, &
                                           controls, snow_sources(layer)%second, child)
        if (child /= 0) return
      end do
      counter = 0
      do field = 1, count
        selected = physical_request_plan(afn, request%icod(field))
        if (selected == 0) return
        kind = source_operation(selected)
        plan(field)%operation = 0
        select case (kind)
        case (2, 3, 4, 5)
          counter(kind - 1) = counter(kind - 1) + 1
          if ((kind == 2 .or. kind == 3) .and. counter(kind - 1) == 1) then
            if (kind == 2) plan(field)%first => snow_density
            if (kind == 3) plan(field)%first => snow_temperature
          else
            level = counter(kind - 1)
            if (kind == 2 .or. kind == 3) level = level - 1
            call borrow_physical_surface_plane(state, registry, source_alias(selected), &
                             source_alias_name(selected), level, source_policy(selected), block, controls, plan(field)%first, child)
            if (child /= 0) return
          end if
          if (kind >= 4) plan(field)%operation = 2
        case (6)
          plan(field)%first => snow_mass
        case (7)
          plan(field)%first => terrain
        case (8)
          flag = physical_surface_field_flag(registry, 42, 'YSD_VF%YSST')
          if (flag < 0) return
          if (flag == 1) then
            call borrow_physical_surface_plane(state, registry, 42, 'YSD_VF%YSST', 1, 0, block, &
                                               controls, plan(field)%first, child)
          else
            call borrow_physical_surface_plane(state, registry, 1, 'YSP_SB%YT', 1, 3, block, &
                                               controls, plan(field)%first, child)
          end if
          if (child /= 0) return
        case default
          call borrow_physical_surface_plane(state, registry, source_alias(selected), source_alias_name(selected), &
                                         source_level(selected), source_policy(selected), block, controls, plan(field)%first, child)
          if (child /= 0) return
          if (kind == 1) then
            call borrow_physical_surface_plane(state, registry, 155, 'YSD_VD%YCP', 1, 0, block, &
                                               controls, plan(field)%second, child)
            if (child /= 0) return
            plan(field)%operation = 1
          end if
        end select
        if (.not. associated(plan(field)%first)) plan(field)%operation = 3
      end do
      lapse_over_gravity = controls%standard_lapse/controls%gravity
      output = 0.0_real64
      if (controls%snow_layers == 1) then
        do point = 1, active_count
          snow_mass(point) = mass(point)
          snow_density(point) = density(point)
          snow_temperature(point) = temperature(point)
        end do
      else
        do point = 1, active_count
          sum_mass = 0.0_real64
          sum_depth = 0.0_real64
          do layer = 1, controls%snow_layers
            mass_value = snow_sources(layer)%first(point)
            if (mass_value > 0.0_real64) then
              sum_mass = sum_mass + mass_value
              part = mass_value/snow_sources(layer)%second(point)
              sum_depth = sum_depth + part
            end if
          end do
          part = density(point)
          if (sum_mass > 0.0_real64) then
            if (sum_depth > 0.0_real64) part = sum_mass/sum_depth
          end if
          snow_mass(point) = sum_mass
          snow_density(point) = part
          snow_temperature(point) = temperature(point)
        end do
      end if
      do field = 1, count
        operation = plan(field)%operation
        if (operation == 3) cycle
        do point = 1, active_count
          select case (operation)
          case (0)
            output(point, field) = plan(field)%first(point)
          case (1)
            output(point, field) = plan(field)%first(point) + plan(field)%second(point)
          case (2)
            output(point, field) = max(0.0_real64, plan(field)%first(point))
          end select
        end do
      end do
      status = 0
    end block
  end function
  !> Refuse overlapping native owner spans without dereferencing their payloads.
  logical function native_spans_disjoint(left, left_bytes, right, right_bytes) result(disjoint)
    type(c_ptr), intent(in) :: left, right
    integer(int64), intent(in) :: left_bytes, right_bytes
    integer(c_intptr_t) :: a, b
    disjoint = .false.
    if (left_bytes < 0 .or. right_bytes < 0) return
    if (left_bytes == 0 .or. right_bytes == 0) then
      disjoint = .true.
      return
    end if
    a = transfer(left, a)
    b = transfer(right, b)
    if (a <= 0 .or. b <= 0) return
    if (left_bytes > huge(a) - a .or. right_bytes > huge(b) - b) return
    disjoint = a >= b + right_bytes .or. b >= a + left_bytes
  end function
  !> Retain increasing source-table search and first matching physical request code.
  integer function physical_request_plan(afn, code) result(selected)
    type(tafn), intent(in) :: afn
    integer, intent(in) :: code
    selected = 0
    if (code < 1) return
    if (code == afn%gfp%ec10fg%icod) then
      selected = 1
      return
    end if
    if (code == afn%gfp%i10fg%icod) then
      selected = 2
      return
    end if
    if (code == afn%gfp%ec10u%icod) then
      selected = 3
      return
    end if
    if (code == afn%gfp%ec10v%icod) then
      selected = 4
      return
    end if
    if (code == afn%gfp%ec2d%icod) then
      selected = 5
      return
    end if
    if (code == afn%gfp%ec2t%icod) then
      selected = 6
      return
    end if
    if (code == afn%gfp%alb%icod) then
      selected = 7
      return
    end if
    if (code == afn%gfp%asn%icod) then
      selected = 8
      return
    end if
    if (code == afn%gfp%bld%icod) then
      selected = 9
      return
    end if
    if (code == afn%gfp%blh%icod) then
      selected = 10
      return
    end if
    if (code == afn%gfp%char%icod) then
      selected = 11
      return
    end if
    if (code == afn%gfp%ci%icod) then
      selected = 12
      return
    end if
    if (code == afn%gfp%cp%icod) then
      selected = 13
      return
    end if
    if (code == afn%gfp%crr%icod) then
      selected = 14
      return
    end if
    if (code == afn%gfp%csfr%icod) then
      selected = 15
      return
    end if
    if (code == afn%gfp%e%icod) then
      selected = 16
      return
    end if
    if (code == afn%gfp%es%icod) then
      selected = 17
      return
    end if
    if (code == afn%gfp%ewss%icod) then
      selected = 18
      return
    end if
    if (code == afn%gfp%fzra%icod) then
      selected = 19
      return
    end if
    if (code == afn%gfp%gfis%icod) then
      selected = 20
      return
    end if
    if (code == afn%gfp%gwd%icod) then
      selected = 21
      return
    end if
    if (code == afn%gfp%hcc%icod) then
      selected = 22
      return
    end if
    if (code == afn%gfp%ie%icod) then
      selected = 23
      return
    end if
    if (code == afn%gfp%iewss%icod) then
      selected = 24
      return
    end if
    if (code == afn%gfp%insss%icod) then
      selected = 25
      return
    end if
    if (code == afn%gfp%isshf%icod) then
      selected = 26
      return
    end if
    if (code == afn%gfp%istl1%icod) then
      selected = 27
      return
    end if
    if (code == afn%gfp%istl2%icod) then
      selected = 28
      return
    end if
    if (code == afn%gfp%istl3%icod) then
      selected = 29
      return
    end if
    if (code == afn%gfp%istl4%icod) then
      selected = 30
      return
    end if
    if (code == afn%gfp%lcc%icod) then
      selected = 31
      return
    end if
    if (code == afn%gfp%lgws%icod) then
      selected = 32
      return
    end if
    if (code == afn%gfp%lsrr%icod) then
      selected = 33
      return
    end if
    if (code == afn%gfp%lssfr%icod) then
      selected = 34
      return
    end if
    if (code == afn%gfp%lsm%icod) then
      selected = 35
      return
    end if
    if (code == afn%gfp%lsp%icod) then
      selected = 36
      return
    end if
    if (code == afn%gfp%lspf%icod) then
      selected = 37
      return
    end if
    if (code == afn%gfp%ilspf%icod) then
      selected = 38
      return
    end if
    if (code == afn%gfp%lz0h%icod) then
      selected = 39
      return
    end if
    if (code == afn%gfp%mcc%icod) then
      selected = 40
      return
    end if
    if (code == afn%gfp%mgws%icod) then
      selected = 41
      return
    end if
    if (code == afn%gfp%mn2t%icod) then
      selected = 42
      return
    end if
    if (code == afn%gfp%msld%icod) then
      selected = 43
      return
    end if
    if (code == afn%gfp%mx2t%icod) then
      selected = 44
      return
    end if
    if (code == afn%gfp%nsss%icod) then
      selected = 45
      return
    end if
    if (code == afn%gfp%pev%icod) then
      selected = 46
      return
    end if
    if (code == afn%gfp%ptype%icod) then
      selected = 47
      return
    end if
    if (code == afn%gfp%ro%icod) then
      selected = 48
      return
    end if
    if (code == afn%gfp%sro%icod) then
      selected = 49
      return
    end if
    if (code == afn%gfp%ssro%icod) then
      selected = 50
      return
    end if
    if (code == afn%gfp%sf%icod) then
      selected = 51
      return
    end if
    if (code == afn%gfp%skt%icod) then
      selected = 52
      return
    end if
    if (code == afn%gfp%slhf%icod) then
      selected = 53
      return
    end if
    if (code == afn%gfp%smlt%icod) then
      selected = 54
      return
    end if
    if (code == afn%gfp%src%icod) then
      selected = 55
      return
    end if
    if (code == afn%gfp%sshf%icod) then
      selected = 56
      return
    end if
    if (code == afn%gfp%ssr%icod) then
      selected = 57
      return
    end if
    if (code == afn%gfp%ssrc%icod) then
      selected = 58
      return
    end if
    if (code == afn%gfp%ssrd%icod) then
      selected = 59
      return
    end if
    if (code == afn%gfp%sst%icod) then
      selected = 60
      return
    end if
    if (code == afn%gfp%ucur%icod) then
      selected = 61
      return
    end if
    if (code == afn%gfp%vcur%icod) then
      selected = 62
      return
    end if
    if (code == afn%gfp%stl1%icod) then
      selected = 63
      return
    end if
    if (code == afn%gfp%stl2%icod) then
      selected = 64
      return
    end if
    if (code == afn%gfp%stl3%icod) then
      selected = 65
      return
    end if
    if (code == afn%gfp%stl4%icod) then
      selected = 66
      return
    end if
    if (code == afn%gfp%str%icod) then
      selected = 67
      return
    end if
    if (code == afn%gfp%strc%icod) then
      selected = 68
      return
    end if
    if (code == afn%gfp%strd%icod) then
      selected = 69
      return
    end if
    if (code == afn%gfp%sund%icod) then
      selected = 70
      return
    end if
    if (code == afn%gfp%swl1%icod) then
      selected = 71
      return
    end if
    if (code == afn%gfp%swl2%icod) then
      selected = 72
      return
    end if
    if (code == afn%gfp%swl3%icod) then
      selected = 73
      return
    end if
    if (code == afn%gfp%swl4%icod) then
      selected = 74
      return
    end if
    if (code == afn%gfp%tcc%icod) then
      selected = 75
      return
    end if
    if (code == afn%gfp%tco3%icod) then
      selected = 76
      return
    end if
    if (code == afn%gfp%sd%icod) then
      selected = 77
      return
    end if
    if (code == afn%gfp%sdsl%icod) then
      selected = 78
      return
    end if
    if (code == afn%gfp%tsn%icod) then
      selected = 79
      return
    end if
    if (code == afn%gfp%rsn%icod) then
      selected = 80
      return
    end if
    if (code == afn%gfp%wsn%icod) then
      selected = 81
      return
    end if
    if (code == afn%gfp%tcw%icod) then
      selected = 82
      return
    end if
    if (code == afn%gfp%tcwv%icod) then
      selected = 83
      return
    end if
    if (code == afn%gfp%tclw%icod) then
      selected = 84
      return
    end if
    if (code == afn%gfp%tciw%icod) then
      selected = 85
      return
    end if
    if (code == afn%gfp%tcrw%icod) then
      selected = 86
      return
    end if
    if (code == afn%gfp%tcsw%icod) then
      selected = 87
      return
    end if
    if (code == afn%gfp%tp%icod) then
      selected = 88
      return
    end if
    if (code == afn%gfp%tsr%icod) then
      selected = 89
      return
    end if
    if (code == afn%gfp%tsrc%icod) then
      selected = 90
      return
    end if
    if (code == afn%gfp%ttr%icod) then
      selected = 91
      return
    end if
    if (code == afn%gfp%ttrc%icod) then
      selected = 92
      return
    end if
    if (code == afn%gfp%vimd%icod) then
      selected = 93
      return
    end if
    if (code == afn%gfp%visih%icod) then
      selected = 94
      return
    end if
    if (code == afn%gfp%z0f%icod) then
      selected = 95
      return
    end if
    if (code == afn%gfp%cin%icod) then
      selected = 96
      return
    end if
    if (code == afn%gfp%kindex%icod) then
      selected = 97
      return
    end if
    if (code == afn%gfp%ttindex%icod) then
      selected = 98
      return
    end if
    if (code == afn%gfp%spar%icod) then
      selected = 99
      return
    end if
    if (code == afn%gfp%suvb%icod) then
      selected = 100
      return
    end if
    if (code == afn%gfp%cape%icod) then
      selected = 101
      return
    end if
    if (code == afn%gfp%stinc%icod) then
      selected = 102
      return
    end if
    if (code == afn%gfp%sdsrp%icod) then
      selected = 103
      return
    end if
  end function
end module forecast_runtime_physical_output_block

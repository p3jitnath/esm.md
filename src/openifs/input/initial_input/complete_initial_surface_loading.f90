module forecast_complete_initial_surface_loading
  !! Compose the existing decoder, selection and conversion with owned copies.
  !! Ports both whole-grid initial surface loading entries. The separate
  !! bounded partitioned production route and its accepted objects are unchanged.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema, read_initial_fields
  use forecast_fixed_initial_field_readers, only: read_selected_surface_fields_unused
  use surface_input_configuration_port, only: surface_input_configuration
  use partitioned_surface_field_placement_port, only: surface_input_owners
  use initial_surface_field_selection_port, only: select_initial_surface_fields
  use surface_initial_state_conversion_port, only: convert_initial_surface_state
  use forecast_whole_surface_placement, only: place_initial_surface_fields, place_operational_initial_surface_fields
  implicit none
  private
  public :: load_initial_surface_state, load_operational_initial_surface_state
  integer(int64), parameter :: surface_labels(4, 81) = reshape([integer(int64) :: &
                                                                172, 0, 20110131, 0, 32, 1, 20260621, 0, &
                                                                32, 2, 20260621, 0, 32, 3, 20260621, 0, &
                                                                32, 4, 20260621, 0, 32, 5, 20260621, 0, &
                                                                139, 0, 20260621, 0, 170, 7, 20260621, 0, &
                                                                183, 28, 20260621, 0, 236, 100, 20260621, 0, &
                                                                39, 0, 20260621, 0, 40, 7, 20260621, 0, &
                                                                41, 28, 20260621, 0, 42, 100, 20260621, 0, &
                                                                198, 0, 20260621, 0, 235, 0, 20260621, 0, &
                                                                31, 0, 20260621, 0, 228008, 0, 20260621, 0, &
                                                                228009, 0, 20260621, 0, 228010, 0, 20260621, 0, &
                                                                228011, 0, 20260621, 0, 228012, 0, 20260621, 0, &
                                                                228013, 0, 20260621, 0, 228014, 0, 20260621, 0, &
                                                                34, 0, 20260621, 0, 35, 0, 20260621, 0, &
                                                                36, 7, 20260621, 0, 37, 28, 20260621, 0, &
                                                                38, 100, 20260621, 0, 148, 0, 20260621, 0, &
                                                                228141, 1, 20260621, 0, 238, 1, 20260621, 0, &
                                                                33, 1, 20260621, 0, 228038, 1, 20260621, 0, &
                                                                228141, 2, 20260621, 0, 238, 2, 20260621, 0, &
                                                                33, 2, 20260621, 0, 228038, 2, 20260621, 0, &
                                                                228141, 3, 20260621, 0, 238, 3, 20260621, 0, &
                                                                33, 3, 20260621, 0, 228038, 3, 20260621, 0, &
                                                                228141, 4, 20260621, 0, 238, 4, 20260621, 0, &
                                                                33, 4, 20260621, 0, 228038, 4, 20260621, 0, &
                                                                228141, 5, 20260621, 0, 238, 5, 20260621, 0, &
                                                                33, 5, 20260621, 0, 228038, 5, 20260621, 0, &
                                                                172, 0, 20260621, 0, 173, 0, 20260621, 0, &
                                                                174, 0, 20260621, 0, 15, 0, 20260621, 0, &
                                                                17, 0, 20260621, 0, 16, 0, 20260621, 0, &
                                                                18, 0, 20260621, 0, 210186, 0, 20260621, 0, &
                                                                210187, 0, 20260621, 0, 210188, 0, 20260621, 0, &
                                                                210189, 0, 20260621, 0, 210190, 0, 20260621, 0, &
                                                                210191, 0, 20260621, 0, 66, 0, 20260621, 0, &
                                                                67, 0, 20260621, 0, 74, 0, 20260621, 0, &
                                                                43, 0, 20260621, 0, 160, 0, 20260621, 0, &
                                                                161, 0, 20260621, 0, 162, 0, 20260621, 0, &
                                                                163, 0, 20260621, 0, 234, 0, 20260621, 0, &
                                                                28, 0, 20260621, 0, 27, 0, 20260621, 0, &
                                                                30, 0, 20260621, 0, 29, 0, 20260621, 0, &
                                                                26, 0, 20260621, 0, 228007, 0, 20260621, 0, &
                                                                200199, 0, 99990615, 0, 129172, 0, 20110131, 0, &
                                                                200026, 0, 20260621, 0 &
                                                                ], [4, 81])

  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  integer(int32) function load_initial_surface_state(path, configuration, owners, parameters, byte_limit) result(status)
    !! Selected whole N16 grid:2048points,140decoded records,47ordinary fields
    !! and five layered fields with five snow layers. byte_limit covers every
    !! private payload and label owner. Final field units follow the converter.
    character(*), intent(in) :: path
    type(surface_input_configuration), intent(in) :: configuration
    type(surface_input_owners), intent(inout) :: owners
    integer(int32), intent(in) :: parameters(:)
    integer(int64), intent(in) :: byte_limit
    status = load_surface(path, configuration, owners, parameters, byte_limit, 2048, 140, 47, .false.)
  end function

  integer(int32) function load_operational_initial_surface_state(path, configuration, owners, parameters, byte_limit) result(status)
    !! Whole N1280 grid:6599680points,81decoded records,50ordinary fields and
    !!25layered planes. This retains the old complete-matrix route and needs
    !! separate production memory admission before any call.
    character(*), intent(in) :: path
    type(surface_input_configuration), intent(in) :: configuration
    type(surface_input_owners), intent(inout) :: owners
    integer(int32), intent(in) :: parameters(:)
    integer(int64), intent(in) :: byte_limit
    status = load_surface(path, configuration, owners, parameters, byte_limit, 6599680, 81, 50, .true.)
  end function

  integer(int32) function load_surface(path,configuration,owners,parameters,byte_limit,n,records,ordinary_fields,operational) result(status)
    !! No final field changes until all input records, selection and physical
    !! conversion pass. Placement checks every destination before its first
    !! store. A failed stage returns100/200/300/400 plus its child status.
    !! Native owner allocation or insufficient budget returns2; basic input
    !! refusal returns1. Private allocation/free preserve incoming errno and
    !! control, while successful numerical exception flags remain observable.
    character(*), intent(in) :: path
    type(surface_input_configuration), intent(in) :: configuration
    type(surface_input_owners), intent(inout) :: owners
    integer(int32), intent(in) :: parameters(:)
    integer(int64), intent(in) :: byte_limit
    integer, intent(in) :: n, records, ordinary_fields
    logical, intent(in) :: operational
    real(real64), pointer, contiguous :: workspace(:) => null()
    real(real64), pointer, contiguous :: decoded(:, :), ordinary(:, :), layered(:, :, :)
    integer(int64), allocatable :: metadata(:, :)
    type(initial_field_schema) :: schema
    type(ieee_status_type) :: incoming, observed
    integer(c_int), pointer, volatile :: error_number
    integer(c_int) :: saved_errno
    integer(int64) :: points, values_count, required, messages_read
    integer :: error
    integer(int32) :: child
    status = 1
    if (len(path) < 1 .or. len(path) > 4095 .or. index(path, achar(0)) /= 0) return
    if (size(parameters) /= ordinary_fields + 5) return
    points = int(n, int64)
    values_count = points*int(records + ordinary_fields + 25, int64)
    required = 8_int64*values_count + 72_int64*records
    status = 2
    if (byte_limit < required) return
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number); saved_errno = error_number
    allocate (workspace(values_count), stat=error)
    if (error /= 0) goto900
    decoded(1:n, 1:records) => workspace(1:points*records)
    ordinary(1:n, 1:ordinary_fields) => workspace(points*records + 1:points*(records + ordinary_fields))
    layered(1:n, 1:5, 1:5) => workspace(points*(records + ordinary_fields) + 1:values_count)
    allocate (metadata(5, records), stat=error)
    if (error /= 0) goto900
    if (operational) then
      allocate (schema%labels(4, 81), stat=error)
      if (error /= 0) goto900
      schema%value_count = points; schema%metadata_words = 5; schema%gaussian_order = 1280
      schema%labels = surface_labels
    end if
    call ieee_set_status(incoming); error_number = saved_errno
    messages_read = 0
    if (operational) then
      child = read_initial_fields(path, schema, decoded, metadata, messages_read)
    else
      child = read_selected_surface_fields_unused(path, decoded, metadata, messages_read)
    end if
    status = 100 + child
    if (child /= 0) goto910
    child = select_initial_surface_fields(decoded, metadata, ordinary, layered)
    status = 200 + child
    if (child /= 0) goto910
    child = convert_initial_surface_state(ordinary, layered, parameters, configuration)
    status = 300 + child
    if (child /= 0) goto910
    if (operational) then
      child = place_operational_initial_surface_fields(ordinary, layered, parameters, owners)
    else
      child = place_initial_surface_fields(ordinary, layered, parameters, owners)
    end if
    status = 0
    if (child /= 0) status = 400 + child
910 call ieee_get_status(observed)
    goto920
900 observed = incoming
920 if (allocated(schema%labels)) deallocate (schema%labels)
    if (allocated(metadata)) deallocate (metadata)
    if (associated(workspace)) deallocate (workspace)
    call ieee_set_status(observed); error_number = saved_errno
  end function
end module forecast_complete_initial_surface_loading

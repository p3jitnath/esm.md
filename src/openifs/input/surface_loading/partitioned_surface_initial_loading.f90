module partitioned_surface_initial_loading_port
  !! Join decoded records, field selection, physical conversion and local copies.
  use, intrinsic :: iso_c_binding, only: c_int, c_int64_t, c_ptr, c_f_pointer
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use, intrinsic :: ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use initial_grib_field_reader_port, only: initial_field_schema, read_initial_fields
  use surface_input_configuration_port, only: surface_input_configuration
  use initial_surface_field_selection_port, only: select_initial_surface_fields
  use surface_initial_state_conversion_port, only: convert_initial_surface_state
  use partitioned_surface_field_placement_port, only: surface_input_owners, &
                                                      place_runtime_partitioned_surface_fields
  implicit none
  private
  public :: load_runtime_partitioned_operational_surface_state
  integer(c_int64_t), parameter :: surface_labels(4, 81) = reshape([integer(c_int64_t) :: &
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
  integer(int32) function load_runtime_partitioned_operational_surface_state( &
    path, configuration, parameters, global_index, owners) result(status)
    !! Read the selected81-record,6599680-point operational surface file.
    !! path contains1..4095 bytes without NUL. configuration and identifiers
    !! are immutable; parameters has55 entries. The six disjoint local owners
    !! and global_index follow the placement module's live P/Q/block contract.
    !! One complete private real workspace holds decoded81,ordinary50 and
    !! layered25 planes in Fortran order. Named schema and decoded metadata
    !! have separately checked owners. All resources release on return.
    !! No public field changes until the complete read, selection and
    !! conversion pass. Placement validates its complete prewrite contract.
    !! Return1 for basic shape,2 for allocation, or100/200/300/400 plus the
    !! reader/selection/conversion/placement failure. Success returns0.
    !! errno and FP control remain unchanged; successful numerical flags
    !! accumulate only through the conversion child. No original model
    !! numerical function, data object or private byte record is required.
    character(*), intent(in) :: path
    type(surface_input_configuration), intent(in) :: configuration
    integer(int32), contiguous, intent(in) :: parameters(:), global_index(:)
    type(surface_input_owners), intent(inout) :: owners
    integer(int64), parameter :: n = 6599680_int64
    real(real64), pointer, contiguous :: workspace(:)
    real(real64), pointer, contiguous :: decoded(:, :), ordinary(:, :), layered(:, :, :)
    integer(int64), allocatable :: metadata(:, :)
    type(initial_field_schema) :: schema
    integer(c_int), pointer :: error_number
    integer(c_int) :: saved_errno
    type(ieee_status_type) :: incoming, observed
    integer :: error
    integer(int64) :: messages_read
    integer(int32) :: child_status
    status = 1
    if (len(path) < 1 .or. len(path) > 4095) return
    if (index(path, achar(0)) /= 0 .or. size(parameters) /= 55) return
    nullify (workspace)
    call ieee_get_status(incoming)
    call c_f_pointer(errno_address(), error_number)
    saved_errno = error_number
    allocate (workspace(156_int64*n), stat=error)
    call ieee_set_status(incoming)
    error_number = saved_errno
    status = 2
    if (error /= 0) return
    decoded(1:n, 1:81) => workspace(1:81*n)
    ordinary(1:n, 1:50) => workspace(81*n + 1:131*n)
    layered(1:n, 1:5, 1:5) => workspace(131*n + 1:156*n)
    allocate (schema%labels(4, 81), stat=error)
    if (error /= 0) goto900
    schema%value_count = n
    schema%metadata_words = 5
    schema%gaussian_order = 1280
    schema%labels = surface_labels
    allocate (metadata(5, 81), stat=error)
    if (error /= 0) goto900
    call ieee_set_status(incoming)
    error_number = saved_errno
    messages_read = 0
    child_status = read_initial_fields(path, schema, decoded, metadata, messages_read)
    status = 100 + child_status
    if (child_status /= 0) goto900
    child_status = select_initial_surface_fields(decoded, metadata, ordinary, layered)
    status = 200 + child_status
    if (child_status /= 0) goto900
    child_status = convert_initial_surface_state(ordinary, layered, parameters, configuration)
    status = 300 + child_status
    if (child_status /= 0) goto900
    child_status = place_runtime_partitioned_surface_fields(ordinary, layered, parameters, global_index, owners)
    status = 0
    if (child_status /= 0) status = 400 + child_status
900 call ieee_get_status(observed)
    if (allocated(metadata)) deallocate (metadata)
    if (allocated(schema%labels)) deallocate (schema%labels)
    deallocate (workspace)
    call ieee_set_status(observed)
    error_number = saved_errno
  end function
end module

!> Project source-produced controls into the one actual output driver.
!! No model, field array, clock, parser state or output namespace is duplicated.
module forecast_actual_output_policy_projection
  use iso_fortran_env, only: int32, int64
  use forecast_operational_model_types, only: native_operational_model_configuration
  use surface_field_storage_port, only: surface_field_state
  use forecast_parallel_interpolation_controls, only: parallel_interpolation_controls, first_parallel_namelist_values
  use forecast_native_flux_storage, only: native_forecast_flux_controls
  use forecast_native_io_server_namespace, only: native_io_server_namespace
  use forecast_output_request_preparation, only: native_output_common_metadata
  use forecast_output_controller, only: native_fullpos_driver_context
  use forecast_grib_field_writers, only: native_grib_writer_policy
  use forecast_runtime_physical_output_block, only: native_physical_output_controls
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: project_actual_output_policy
contains
  !> Complete metadata after the genuine model, first groups and flux setup.
 !! Inputs are readonly final owners. BUDGET is a per-rank byte capacity.
 !! DRIVER retains its final address; only its four consumed scalar controls
 !! change. WRITER and PHYSICAL are small native policy records, not weather
 !! owners. OUTPUT_DIRECTORY has at least256 characters and receives COFDIR.
 !! The caller admits only the fresh NCONF1 forecast path, before variational
 !! writers or output visits. No current-step value is read or written.
 !! Status2 preserves every output. Status0 publishes all policy fields.
  integer(int32) function project_actual_output_policy(model, surface_arrays, parallel_policy, parallel_admitted, &
           flux, io_server, hook_enabled, common, budget, driver, writer_policy, physical_controls, output_directory) result(status)
    type(native_operational_model_configuration), intent(in) :: model
    type(surface_field_state), intent(in) :: surface_arrays
    type(parallel_interpolation_controls), intent(in) :: parallel_policy
    type(first_parallel_namelist_values), intent(in) :: parallel_admitted
    type(native_forecast_flux_controls), intent(in) :: flux
    type(native_io_server_namespace), intent(in) :: io_server
    logical, intent(in) :: hook_enabled
    type(native_output_common_metadata), intent(in) :: common
    integer(int64), intent(in) :: budget
    type(native_fullpos_driver_context), intent(inout) :: driver
    type(native_grib_writer_policy), intent(inout) :: writer_policy
    type(native_physical_output_controls), intent(inout) :: physical_controls
    character(*), intent(inout) :: output_directory
    type(native_grib_writer_policy) :: writer
    type(native_physical_output_controls) :: physical
    integer(int32) :: outtype, grib_files
    integer :: n
    logical :: fdb, split
    status = 2
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. model%initial%ready) return
    if (.not. allocated(model%initial%geometry) .or. .not. allocated(model%initial%prefix)) return
    if (.not. model%initial%geometry%initialized) return
    if (model%initial%controls%namespace%nconf /= 1 .or. model%initial%controls%namespace%lecmwf /= 1) return
    if (model%initial%controls%namespace%larpegef /= 0 .or. model%initial%controls%namespace%lelam /= 0) return
    if (model%initial%controls%namespace%lminim /= 0 .or. model%initial%controls%namespace%l_oops /= 0) return
    if (.not. parallel_policy%ready .or. driver%actual_writer%ready) return
    if (io_server%lIO_server .or. io_server%nproc_io /= 0) return
    if (budget < 1_int64 .or. budget > 68719476736_int64 .or. len(output_directory) < 256) return
    if (len_trim(io_server%cofdir) < 1 .or. index(io_server%cofdir, achar(0)) /= 0) return
    if (common%lfpmois) return
    if (.not. allocated(model%motion%gmv)) return
    if (.not. allocated(surface_arrays%sp_sb) .or. .not. allocated(surface_arrays%sp_sg)) return
    if (.not. allocated(flux%cfu%gfubuf) .or. .not. allocated(flux%xfu%xfubuf)) return
    if (flux%cfu%ntypcfu < 0 .or. flux%xfu%ntypxfu < 0) return
    if (size(flux%cfu%gfubuf, 2) /= flux%cfu%ntypcfu .or. size(flux%xfu%xfubuf, 2) /= flux%xfu%ntypxfu) return
    grib_files = model%initial%prefix%headers%ngribfile
    if (grib_files < 0 .or. grib_files > 1) return
    n = model%initial%prefix%configuration_bytes
    if (n < 1 .or. n > 262144) return
    ! SUVAREPS stores false before this admitted first empty group.
    if (require_empty_physics_group(model%initial%prefix%configuration_text(1:n), 'NAMVAREPS') /= 0) return
    ! Actual initial setup has already admitted the complete first NAMVAR with
    ! only LMODERR/LJCDFI/LUSEJCDFI/LECV=false. It cannot replace INI_YOMVAR's
    ! LTWGRA/LTWINC=false stores or enter minimisation on this NCONF1 route.
    if (model%initial%initialization%lmoderr /= 0 .or. model%initial%initialization%lecv /= 0 .or. &
        model%initial%initialization%ljcdfi /= 0 .or. model%initial%initialization%lusejcdfi /= 0) return
    ! SUMP0 defaults and its final FDB resolution use the actual first-group
    ! presence flags. An absent parsed field is never used as a default value.
    outtype = -1
    split = .false.
    if (parallel_admitted%present(5)) outtype = parallel_admitted%nouttype
    if (parallel_admitted%present(11)) split = parallel_admitted%lsplitout
    fdb = model%initial%controls%namespace%lfdbop /= 0
    if (outtype > 0) fdb = outtype == 2
    if (fdb) then
      outtype = 2; split = .true.
    else
      outtype = 1
    end if
    if (outtype /= 1) return
    writer%nproc = model%initial%geometry%transform_control%nproc
    writer%nouttype = outtype
    writer%nconf = model%initial%controls%namespace%nconf
    writer%lecmwf = model%initial%controls%namespace%lecmwf
    writer%l_oops = model%initial%controls%namespace%l_oops
    writer%ltwgra = 0; writer%ltwinc = 0
    ! LTWBGV/LTWCGL are zero-born source module switches reserved for BGVECS
    ! and XFORMEV. Neither producer is entered by this fresh forecast path.
    ! Publish that explicit native preimage, without importing either global.
    writer%ltwbgv = 0; writer%ltwcgl = 0
    writer%lppsteps = model%dynamical_core%lppsteps
    writer%lvareps = 0
    physical%block_width = size(model%motion%gmv, 1)
    physical%local_points = model%initial%geometry%partition%ngptot
    physical%soil_layers = size(surface_arrays%sp_sb, 2)
    physical%snow_layers = size(surface_arrays%sp_sg, 2)
    physical%cumulative_flux_fields = flux%cfu%ntypcfu
    physical%instant_flux_fields = flux%xfu%ntypxfu
    physical%lephys = model%physics%ecmwf_physics%lephys
    physical%lmphys = model%physics%phy%lmphys
    physical%lnemocoup = model%climate%lnemocoup
    physical%hook_enabled = hook_enabled
    physical%gravity = model%initial%constants%rg
    physical%standard_lapse = model%initial%geometry%atmosphere%reference_tables(1)%gradient(1)
    physical%budget_bytes = budget
    writer_policy = writer
    physical_controls = physical
    output_directory = io_server%cofdir
    driver%hook_enabled = hook_enabled
    driver%split_output = split
    driver%cumulative_flux_active = flux%cfu%lcumfu
    driver%grib_file_count = grib_files
    ! UPDATE_DATE is source-unread because LFPMOIS=false was admitted above.
    ! The actual body reads NFPXFLD directly and never consumes the retained
    ! legacy DOMAIN_NAME/NORM_CHUNK_SIZE/IO_SERVICE wrapper fields.
    status = 0
  end function
end module

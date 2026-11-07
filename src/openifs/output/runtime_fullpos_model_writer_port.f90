!> Keep the generated WRMLFP file-call order with typed forecast state.
!! Field selection and encoding remain in the accepted native Fortran children.
module runtime_fullpos_model_writer_port
  use, intrinsic :: iso_fortran_env, only: int32,int64,real64
  use, intrinsic :: iso_c_binding, only: c_size_t
  use mpl_barrier_mod, only: MPL_BARRIER
  use runtime_grib_template_port, only: grib_geometry_metadata,grib_template_metadata
  use runtime_grib_field_encoding_port, only: grib_field_metadata
  use runtime_grib_writer_state_port, only: grib_writer_state
  use runtime_output_field_gather_port, only: output_distribution,agree_output_status
  use runtime_synchronous_grib_file_backend_port, only: output_file_plan
  use runtime_selected_output_family_port, only: output_selection_request,write_runtime_selected_output_family
  implicit none
  private
  public :: fullpos_model_output_controls,write_fullpos_model_fields
  type :: fullpos_model_output_controls
    integer(int32) :: truncation=0,block_width=0,local_coefficients=0
    integer(int32) :: requested_step=0,clock_step=0,configuration_index=1
    integer(int32) :: ocean_field_counts(3)=0
    real(real64) :: time_step=0.0_real64
    character :: configuration='I'
    logical :: initial_state=.false.,profiling_enabled=.false.,observation_only=.false.
    logical :: lagged_fields=.false.,ocean_fields=.false.,physics_enabled=.false.
    logical :: physical_exclusions(2)=.false.
  end type fullpos_model_output_controls
  interface
    subroutine gstats(identifier,position)
      import int32
      integer(int32), intent(in) :: identifier,position
    end subroutine gstats
  end interface
contains
  !> Write selected model spectral, physical and upper-grid families in order.
  !! The two physical exclusions are the owned source forecast-mode switches.
  !! The caller supplies the live clock and public FIAT/MPI partition.
  !! spectrum has (local_fields,local_coefficients); blocked has
  !! (block_width,field_capacity,block_count), in each field's physical units.
  !! Each name has 256 characters; names 1, 2 and 4 keep their source roles.
  subroutine write_fullpos_model_fields(spectral_request,grid_request,physical_request,geometry, &
      template_metadata,field_defaults,distribution,controls,filenames,output_directory,gravity, &
      water_density,cloud_cover_precision,cloud_water_precision,writer,status,spectrum,blocked)
    type(output_selection_request), intent(in) :: spectral_request,grid_request,physical_request
    type(grib_geometry_metadata), intent(in) :: geometry
    type(grib_template_metadata), intent(in) :: template_metadata
    type(grib_field_metadata), intent(in) :: field_defaults
    type(output_distribution), intent(in) :: distribution
    type(fullpos_model_output_controls), intent(in) :: controls
    character(256), intent(in) :: filenames(6)
    character(*), intent(in) :: output_directory
    real(real64), intent(in) :: gravity,water_density,cloud_cover_precision,cloud_water_precision
    type(grib_writer_state), intent(inout) :: writer
    integer(int32), intent(out) :: status
    real(real64), optional, intent(in) :: spectrum(:,:),blocked(:,:,:)
    type(grib_template_metadata) :: reduced_template
    type(grib_field_metadata) :: reduced_fields
    type(output_file_plan) :: plan
    integer(int32) :: local_status,error
    integer(int64) :: global_coefficients,budget,time_word
    integer :: spectral_count,grid_count,physical_count
    logical :: special_output,write_physical,write_model

    spectral_count=0
    grid_count=0
    physical_count=0
    if(allocated(spectral_request%parameters)) spectral_count=size(spectral_request%parameters)
    if(allocated(grid_request%parameters)) grid_count=size(grid_request%parameters)
    if(allocated(physical_request%parameters)) physical_count=size(physical_request%parameters)
    special_output=controls%lagged_fields.or.controls%ocean_fields
    write_physical=controls%physics_enabled.and..not.any(controls%physical_exclusions).and. &
      controls%configuration=='I'
    write_model=controls%configuration/='I'.and..not.special_output
    local_status=2_int32
    if(controls%truncation>=1.and.controls%truncation<=4096.and. &
       controls%block_width>=1.and.controls%block_width<=1024.and.controls%requested_step>=0.and. &
       controls%clock_step==controls%requested_step.and.controls%configuration_index==1.and. &
       .not.controls%observation_only.and..not.controls%profiling_enabled.and. &
       all(controls%ocean_field_counts==0).and.distribution%maps_ready.and. &
       distribution%world>=1.and.distribution%world<=65536.and.distribution%process_one_based>=1.and. &
       distribution%process_one_based<=distribution%world.and.distribution%resolution>=0.and. &
       distribution%local_grid_points>=1.and.distribution%global_grid_points>=1.and. &
       spectral_count<=65536.and.grid_count<=65536.and.physical_count<=1639.and. &
       writer%initialized.and..not.writer%io_server.and.writer%output_type==1) then
      global_coefficients=int(controls%truncation+1,int64)*int(controls%truncation+2,int64)
      budget=int(field_defaults%workspace_limit_bytes,int64)
      time_word=transfer(controls%time_step,time_word)
      if(controls%local_coefficients>=1.and.controls%local_coefficients<=global_coefficients.and. &
         budget>=848_int64.and.budget<=68719476736_int64.and.time_word>0_int64.and. &
         iand(time_word,int(z'7ff0000000000000',int64))/=int(z'7ff0000000000000',int64)) then
        local_status=0_int32
        if(write_model.and.spectral_count>0.and..not.present(spectrum)) local_status=2_int32
        if(((write_model.and.grid_count>0).or.(write_physical.and.physical_count>0)).and. &
           .not.present(blocked)) local_status=2_int32
        if(present(blocked)) then
          if(((write_model.and.grid_count>0).or.(write_physical.and.physical_count>0)).and. &
             size(blocked,1)/=controls%block_width) local_status=2_int32
        end if
      end if
    end if
    call agree_output_status(distribution,local_status,status)
    if(status/=0) return

    reduced_fields=field_defaults
    reduced_template=template_metadata
    reduced_fields%workspace_limit_bytes=int(budget-848_int64,c_size_t)
    reduced_template%workspace_limit_bytes=reduced_fields%workspace_limit_bytes
    plan%nstep=controls%requested_step
    plan%truncation=controls%truncation
    plan%time_step=controls%time_step
    if(write_model.and.spectral_count>0) then
      plan%spectral=.true.
      plan%append=.true.
      plan%level_kind='m'
      plan%local_value_count=controls%local_coefficients
      plan%global_value_count=int(global_coefficients,int32)
      call write_runtime_selected_output_family(0_int32,spectral_request,geometry,reduced_template, &
        reduced_fields,distribution,plan,filenames(1),output_directory,gravity,water_density, &
        cloud_cover_precision,cloud_water_precision,writer,status,spectrum=spectrum)
      if(status/=0) return
    end if
    if(write_physical.and.physical_count>0) then
      plan%spectral=.false.
      plan%append=special_output
      plan%level_kind='s'
      plan%local_value_count=distribution%local_grid_points
      plan%global_value_count=distribution%global_grid_points
      call write_runtime_selected_output_family(1_int32,physical_request,geometry,reduced_template, &
        reduced_fields,distribution,plan,filenames(2),output_directory,gravity,water_density, &
        cloud_cover_precision,cloud_water_precision,writer,status,blocked=blocked)
      if(status/=0) return
    end if
    if(write_model.and.grid_count>0) then
      plan%spectral=.false.
      plan%append=.not.controls%initial_state
      plan%level_kind='m'
      plan%local_value_count=distribution%local_grid_points
      plan%global_value_count=distribution%global_grid_points
      call write_runtime_selected_output_family(2_int32,grid_request,geometry,reduced_template, &
        reduced_fields,distribution,plan,filenames(4),output_directory,gravity,water_density, &
        cloud_cover_precision,cloud_water_precision,writer,status,blocked=blocked)
      if(status/=0) return
    end if
    if(distribution%world>1) then
      call gstats(792_int32,0_int32)
      call MPL_BARRIER(CDSTRING='WRMLFP:',KERROR=error)
      call gstats(792_int32,1_int32)
      if(error/=0) then
        status=3_int32
        return
      end if
    end if
    status=0_int32
  end subroutine write_fullpos_model_fields
end module runtime_fullpos_model_writer_port

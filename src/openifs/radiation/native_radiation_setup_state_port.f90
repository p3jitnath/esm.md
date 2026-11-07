!> Own native radiation setup records while borrowing shared forecast state.
module native_radiation_setup_state
  use iso_fortran_env,only:int32,int64,real64
  use iso_c_binding,only:c_ptr,c_null_ptr,c_loc,c_intptr_t,c_int,c_size_t
  use radiation_config,only:config_type,NMaxAerosolTypes
  use radiation_cloud_optics_data,only:cloud_optics_type
  use radiation_aerosol_optics_data,only:aerosol_optics_type
  use radiation_pdf_sampler,only:pdf_sampler_type
  use yoerad,only:terad
  use yoerdi,only:terdi
  use yoe_uvrad,only:teuvrad
  use yoesw,only:teswrt
  use yoeaerd,only:teaerd
  use yoeovlp,only:teovlp
  use yomradf,only:tradf
  use yoeozoc,only:teozoc
  use owned_aerosol_climatology_records,only:teaerc_tegen,teaerc_macc
  use yoeaeratm,only:teaeratm
  use yoeaerlid,only:teaerlid
  use yoeaermap,only:teaermap
  use yoeaersnk,only:teaersnk
  use yoeaersrc,only:teaersrc
  use yoeaervol,only:teaervol
  use yoedbug,only:tedbug
  use eint_mod,only:sl_struct
  use longwave_reference_parameter_fields_mod,only:longwave_reference_parameter_record
  use shortwave_auxiliary_parameter_fields_mod,only:shortwave_transmission_parameter_record, &
    shortwave_aerosol_parameter_record,shortwave_cloud_parameter_record
  use native_absorption_records,only:longwave_absorption_input_record, &
    longwave_absorption_reduced_record,shortwave_absorption_record
  use native_longwave_band_record,only:longwave_band_parameter_record
  use cloud_optical_parameter_fields_mod,only:cloud_optical_550_parameter_record
  use selected_aerosol_parameter_fields_mod,only:aerosol_optical_parameter_record
  use native_owned_tegen_aerosol_setup,only:tegen_shared_cache
  use native_radiation_climate_records,only:radiation_climate_context
  use selected_ecrad_configuration_port,only:selected_ecrad_configuration_record
  use selected_radiation_control_fields_mod,only:radiation_scalar_parameter_record
  use radiation_climate_selection_port,only:radiation_climate_selection_record
  implicit none
  private
  public::owned_radiation_setup_state,initialize_radiation_fresh_preimage
  interface
    function fill_native_padding(address,value,bytes)bind(C,name='memset')result(output)
      import::c_ptr,c_int,c_size_t
      type(c_ptr),value::address
      integer(c_int),value::value
      integer(c_size_t),value::bytes
      type(c_ptr)::output
    end function
    function copy_native_empty_record(destination,source,bytes)bind(C,name='memcpy')result(output)
      import::c_ptr,c_size_t
      type(c_ptr),value::destination,source
      integer(c_size_t),value::bytes
      type(c_ptr)::output
    end function
  end interface
  ! This native empty type has no scalar values or live owners.
  ! Its explicit SAVE initializer gives the compiler a zero-born template.
  type(cloud_optics_type),save,target::empty_cloud_optics=cloud_optics_type()
  !> Native owner for the SUECRAD records, tables and acquired resources.
  !! Allocate this large record through a caller-owned allocatable forecast
  !! state. Do not copy a live state: its native pointer views borrow the
  !! explicit TEGEN cache. All record types use their actual public/native
  !! declarations; the compiler owns component and array representation.
  !! TRIP including YRECMIP, the shared TEPHY and TELWRAD records, constants,
  !! native_grid_dimensions and native_distributed_partition are borrowed
  !! by the parent interfaces rather than duplicated in this owner.
  !! Resource flags belong only to the setup/release call order. Source-
  !! unwritten numerical members and padding retain their incoming state.
  type::owned_radiation_setup_state
    type(terad)::radiation
    type(terdi)::gases
    type(teuvrad)::ultraviolet
    type(teswrt)::shortwave
    type(teaerd)::aerosol_distribution
    type(teovlp)::cloud_overlap
    type(tradf)::fluxes
    type(teozoc)::ozone
    type(teaerc_tegen)::tegen
    type(teaerc_macc)::cams
    type(teaeratm)::aerosol_atmosphere
    type(teaerlid)::aerosol_lidar
    type(teaermap)::aerosol_mapping
    type(teaersnk)::aerosol_sinks
    type(teaersrc)::aerosol_sources
    type(teaervol)::aerosol_volume
    type(tedbug)::aerosol_debug
    type(sl_struct)::input_interpolation,output_interpolation
    type(longwave_reference_parameter_record)::longwave_reference
    type(shortwave_transmission_parameter_record)::shortwave_transmission
    type(shortwave_aerosol_parameter_record)::shortwave_auxiliary_aerosol
    type(shortwave_cloud_parameter_record)::shortwave_auxiliary_cloud
    type(longwave_absorption_input_record)::longwave_input
    type(longwave_absorption_reduced_record)::longwave_reduced
    type(shortwave_absorption_record)::shortwave_absorption
    type(longwave_band_parameter_record)::longwave_bands
    type(cloud_optical_550_parameter_record)::cloud_optical_550
    type(aerosol_optical_parameter_record)::aerosol_optical
    type(tegen_shared_cache)::tegen_cache
    type(radiation_climate_context),allocatable::climate
    ! The original fresh owner has zero values in source-unwritten fields.
    ! Native constructors retain public declaration defaults and absent owners.
    ! The compiler also creates the record padding and array descriptors.
    type(selected_ecrad_configuration_record)::ecrad = selected_ecrad_configuration_record( &
      config=config_type(i_aerosol_type_map=spread(0_int32,1,NMaxAerosolTypes), &
        i_spec_from_reordered_g_lw=null(),i_spec_from_reordered_g_sw=null(), &
        cloud_optics=cloud_optics_type(), &
        aerosol_optics=aerosol_optics_type(ntype=0_int32,n_type_phobic=0_int32, &
          n_type_philic=0_int32,nrh=0_int32), &
        pdf_sampler=pdf_sampler_type(ncdf=0_int32,nfsd=0_int32,fsd1=0.0_real64,inv_fsd_interval=0.0_real64), &
        ice_optics_file_name=repeat(achar(0),511),liq_optics_file_name=repeat(achar(0),511), &
        aerosol_optics_file_name=repeat(achar(0),511),cloud_pdf_file_name=repeat(achar(0),511)), &
      nweight_uv=0_int32,iband_uv=spread(0_int32,1,100),weight_uv=spread(0.0_real64,1,100), &
      nweight_par=0_int32,iband_par=spread(0_int32,1,100),weight_par=spread(0.0_real64,1,100), &
      trop_bg_aer_mass_ext=0.0_real64,strat_bg_aer_mass_ext=0.0_real64)
    type(radiation_scalar_parameter_record)::scalars
    type(radiation_climate_selection_record)::selection
    logical::context_ready=.false.,storage_ready=.false.,setup_complete=.false.
    logical::aerosol_storage_acquired=.false.,overlap_acquired=.false.
    logical::planck_acquired=.false.,bands_acquired=.false.
    logical::aerosol_parameters_acquired=.false.,flux_acquired=.false.
    logical::climate_acquired=.false.,ecrad_acquired=.false.
    logical::ozone_acquired=.false.,tegen_acquired=.false.,cams_acquired=.false.
    integer(int32)::last_stage=0_int32,last_status=0_int32
    character(len=264)::coefficient_directory
    character(len=512)::table_paths(4)
    integer(int64)::table_path_lengths(4)
  end type owned_radiation_setup_state
contains
  !> Establish the source fresh-owner values before any radiation calculation.
  !! STATE is INOUT native storage with no live resources. The four fixed
  !! UV/PAR query arrays have100dimensionless entries and are initially zero.
  !! The compiler locates two scalar padding gaps through adjacent named
  !! fields. These gaps contain no array descriptor or physical value.
  !! Their lengths must be0:15bytes before any write. The public C memset
  !! service fills only these gaps, reproducing the original calloc preimage.
  !! The complete native empty cloud-optics template is copied through the
  !! public C memcpy service. Its six allocatables must all be absent.
  !! No descriptor offsets or descriptor words are constructed by this code.
  !! The compiler owns the template's complete type and representation.
  !! Public declaration defaults and every other native descriptor are kept.
  !! Return0 on success or2 without mutation for an unsupported layout.
  integer(int32) function initialize_radiation_fresh_preimage(state)result(status)
    type(owned_radiation_setup_state),intent(inout),target::state
    integer(c_intptr_t)::first(2),last(2),gap(2)
    type(c_ptr)::unused
    integer::index
    status=2_int32
    first(1)=transfer(c_loc(state%ecrad%config%aerosol_optics%use_monochromatic),0_c_intptr_t)+ &
      int(storage_size(state%ecrad%config%aerosol_optics%use_monochromatic)/8,c_intptr_t)
    last(1)=transfer(c_loc(state%ecrad%config%pdf_sampler%ncdf),0_c_intptr_t)
    first(2)=transfer(c_loc(state%ecrad%config%do_clouds),0_c_intptr_t)+ &
      int(storage_size(state%ecrad%config%do_clouds)/8,c_intptr_t)
    last(2)=transfer(c_loc(state%ecrad%nweight_uv),0_c_intptr_t)
    gap=last-first
    if(any(gap<0_c_intptr_t).or.any(gap>15_c_intptr_t))return
    if(allocated(state%ecrad%config%cloud_optics%liq_coeff_lw))return
    if(allocated(state%ecrad%config%cloud_optics%liq_coeff_sw))return
    if(allocated(state%ecrad%config%cloud_optics%ice_coeff_lw))return
    if(allocated(state%ecrad%config%cloud_optics%ice_coeff_sw))return
    if(allocated(state%ecrad%config%cloud_optics%liq_coeff_gen))return
    if(allocated(state%ecrad%config%cloud_optics%ice_coeff_gen))return
    unused=copy_native_empty_record(c_loc(state%ecrad%config%cloud_optics), &
      c_loc(empty_cloud_optics),int(storage_size(empty_cloud_optics)/8,c_size_t))
    state%ecrad%nweight_uv=0_int32
    state%ecrad%iband_uv=0_int32
    state%ecrad%weight_uv=0.0_real64
    state%ecrad%nweight_par=0_int32
    state%ecrad%iband_par=0_int32
    state%ecrad%weight_par=0.0_real64
    state%ecrad%trop_bg_aer_mass_ext=0.0_real64
    state%ecrad%strat_bg_aer_mass_ext=0.0_real64
    do index=1,2
      if(gap(index)>0_c_intptr_t)then
        unused=fill_native_padding(transfer(first(index),c_null_ptr),0_c_int,int(gap(index),c_size_t))
      end if
    end do
    status=0_int32
  end function initialize_radiation_fresh_preimage
end module native_radiation_setup_state

!> Allocate and select the seven source-defined physics work-record families.
!! Counts are dimensionless. Physical array values retain their consumer's units.
!! Allocation leaves values undefined; only the source ZDISSGW view requests zero.
!! The caller establishes the floating-point environment once before these calls.
module forecast_additional_physics_work_records
  use iso_fortran_env, only: int32, int64, real64
  use forecast_physics_work_types, only: flux_type, aux_diag_type, ddh_surf_type, aux_diag_local_type, &
                                         surf_and_more_local_type, keys_local_type, perturb_local_type, dimension_type
  use forecast_geometry_state_types, only: native_geometry_state
  use forecast_registry_field_types, only: field_4d => native_registry_field_4d
  use forecast_registry_storage, only: allocate_registry_field_4d
  use forecast_physics_field_views, only: physics_field_view_2d, physics_field_view_3d, physics_field_view_4d
  use forecast_integer_logical_work_fields, only: field_log2d => native_logical_work_field, &
                                                 allocate_logical_work_field, integer_work_field_view_2d, logical_work_field_view_2d
  use physics_work_record_support_mod, only: work_record_status_snapshot, capture_work_record_status, &
                        restore_work_record_status, create_work_field, delete_work_field, increment_work_word, abort_storage_failure
  implicit none
  private
  public :: initialize_flux_work_record, update_flux_work_views, finalize_flux_work_record
  public :: flux_type_init, flux_type_update_view, flux_type_final
public::initialize_auxiliary_diagnostic_work_record,update_auxiliary_diagnostic_work_views,finalize_auxiliary_diagnostic_work_record
  public :: aux_diag_type_init, aux_diag_type_update_view, aux_diag_type_final
  public :: initialize_surface_diagnostic_work_record, update_surface_diagnostic_work_views, finalize_surface_diagnostic_work_record
  public :: ddh_surf_type_init, ddh_surf_type_update_view, ddh_surf_type_final
  public::initialize_auxiliary_diagnostic_local_work_record,update_auxiliary_diagnostic_local_work_views,finalize_auxiliary_diagnostic_local_work_record
  public :: aux_diag_local_type_init, aux_diag_local_type_update_view, aux_diag_local_type_final
  public :: initialize_surface_local_work_record, update_surface_local_work_views, finalize_surface_local_work_record
  public :: surf_and_more_local_type_init, surf_and_more_local_type_update_view, surf_and_more_local_type_final
  public :: initialize_keys_local_work_record, update_keys_local_work_views, finalize_keys_local_work_record
  public :: keys_local_type_init, keys_local_type_update_view, keys_local_type_final
  public :: initialize_perturbation_local_work_record, update_perturbation_local_work_views, finalize_perturbation_local_work_record
  public :: perturb_local_type_init, perturb_local_type_update_view, perturb_local_type_final
  public :: additional_work_record_call_count_get
  integer(int64), save :: native_call_counts(21) = 0_int64
  interface create_additional_work_field
    module procedure create_real_4d, create_logical_2d
  end interface
  interface delete_additional_work_field
    module procedure delete_real_4d, delete_logical_2d
  end interface
contains
  !> Check the complete byte product without integer overflow or payload reads.
  logical function valid_work_shape(shape, element_bytes) result(valid)
    integer(int32), intent(in) :: shape(:), element_bytes
    integer(int64) :: bytes
    integer :: i
    valid = .false.
    if (any(shape < 0)) return
    if (any(shape == 0)) then
      valid = .true.; return
    end if
    bytes = int(element_bytes, int64)
    do i = 1, size(shape)
      if (bytes > huge(bytes)/int(shape(i), int64)) return
      bytes = bytes*int(shape(i), int64)
    end do
    valid = .true.
  end function
  !> Acquire metadata before an uninitialized, uniquely owned payload.
  integer(int32) function create_real_4d(output, shape, thread_buffer) result(status)
    type(field_4d), pointer, intent(inout) :: output
    integer(int32), intent(in) :: shape(4)
    logical, intent(in) :: thread_buffer
    type(field_4d), pointer :: pending
    integer :: allocation_status
    nullify (pending)
    allocate (pending, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    status = allocate_registry_field_4d(pending, shape, thread_buffer)
    if (status /= 0) then
      deallocate (pending); return
    end if
    output => pending
    status = 0
  end function
  !> Free this source-owned payload and metadata while preserving public views.
  subroutine delete_real_4d(output)
    type(field_4d), pointer, intent(inout) :: output
    if (.not. associated(output)) return
    if (associated(output%data)) deallocate (output%data)
    deallocate (output)
    nullify (output)
  end subroutine
  !> Acquire metadata before an uninitialized, uniquely owned payload.
  integer(int32) function create_logical_2d(output, shape, thread_buffer) result(status)
    type(field_log2d), pointer, intent(inout) :: output
    integer(int32), intent(in) :: shape(2)
    logical, intent(in) :: thread_buffer
    type(field_log2d), pointer :: pending
    integer :: allocation_status
    nullify (pending)
    allocate (pending, stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    status = allocate_logical_work_field(pending, shape, thread_buffer)
    if (status /= 0) then
      deallocate (pending); return
    end if
    output => pending
    status = 0
  end function
  !> Free this source-owned payload and metadata while preserving public views.
  subroutine delete_logical_2d(output)
    type(field_log2d), pointer, intent(inout) :: output
    if (.not. associated(output)) return
    if (associated(output%data)) deallocate (output%data)
    deallocate (output)
    nullify (output)
  end subroutine
  !> Own 57 fields in source order. STATE must have no live owned heads.
  !! GEOMETRY and counts stay readonly. PERSISTENT defaults false; true keeps
  !! actual grid blocks. New values and incoming public views remain unchanged.
  !! Status0 succeeds,1 cleans a failed allocation prefix,2 refuses unsupported
  !! native metadata before ownership changes. No original method is called.
  integer(int32) function initialize_flux_work_record(state, geometry, settings, persistent) result(status)
    type(flux_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    integer(int32), intent(in) :: settings(:)
    logical, optional, intent(in) :: persistent
    logical :: keep
    integer(int32) :: rows, blocks, cleanup_status
    integer(int32) :: extent_a(57), extent_b(57)
    integer(int64) :: wide_extent
    type(work_record_status_snapshot) :: snapshot
    status = 2
    rows = geometry%dimensions%nproma
    blocks = geometry%partition%ngpblks
    if (rows < 1 .or. blocks < 1) return
    if (size(settings) /= 4) return
    if (.not. is_contiguous(settings)) return
    if (any(settings < 0)) return
    if (associated(state%f_pfrsod)) return
    if (associated(state%f_pfrsodc)) return
    if (associated(state%f_puvdf)) return
    if (associated(state%f_pparf)) return
    if (associated(state%f_pparcf)) return
    if (associated(state%f_pfrthd)) return
    if (associated(state%f_pfrthdc)) return
    if (associated(state%f_ptofdu)) return
    if (associated(state%f_ptofdv)) return
    if (associated(state%f_pftg12)) return
    if (associated(state%f_pfwev)) return
    if (associated(state%f_pfwsb)) return
    if (associated(state%f_pfwg12)) return
    if (associated(state%f_pfwmlt)) return
    if (associated(state%f_pfwrod)) return
    if (associated(state%f_pfwro1)) return
    if (associated(state%f_pftlhev)) return
    if (associated(state%f_pftlhsb)) return
    if (associated(state%f_pfrsoc)) return
    if (associated(state%f_pfrthc)) return
    if (associated(state%f_pdifcq)) return
    if (associated(state%f_pdifcs)) return
    if (associated(state%f_pdiftq)) return
    if (associated(state%f_pdifts)) return
    if (associated(state%f_pfcqng)) return
    if (associated(state%f_pfplcl)) return
    if (associated(state%f_pfplcn)) return
    if (associated(state%f_pfplsl)) return
    if (associated(state%f_pfplsn)) return
    if (associated(state%f_pfhpcl)) return
    if (associated(state%f_pfhpcn)) return
    if (associated(state%f_pfhpsl)) return
    if (associated(state%f_pfhpsn)) return
    if (associated(state%f_pfrso)) return
    if (associated(state%f_pfrth)) return
    if (associated(state%f_pstrcu)) return
    if (associated(state%f_pstrcv)) return
    if (associated(state%f_pstrdu)) return
    if (associated(state%f_pstrdv)) return
    if (associated(state%f_pstrtu)) return
    if (associated(state%f_pstrtv)) return
    if (associated(state%f_pdiftl)) return
    if (associated(state%f_pdifti)) return
    if (associated(state%f_pfccql)) return
    if (associated(state%f_pfccqn)) return
    if (associated(state%f_pfcsql)) return
    if (associated(state%f_pfcsqn)) return
    if (associated(state%f_pfcqlng)) return
    if (associated(state%f_pfcqnng)) return
    if (associated(state%f_pfsqrf)) return
    if (associated(state%f_pfsqsf)) return
    if (associated(state%f_pfcqrng)) return
    if (associated(state%f_pfcqsng)) return
    if (associated(state%f_pfsqltur)) return
    if (associated(state%f_pfsqitur)) return
    if (associated(state%f_penes)) return
    if (associated(state%f_paeroddf)) return
    keep = .false.
    if (present(persistent)) keep = persistent
    if (.not. keep) blocks = 1
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    wide_extent = 2_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(19) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(19), blocks], 8_int32)) return
    wide_extent = 2_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(20) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(20), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(21) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(21), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(22) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(22), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(23) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(23), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(24) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(24), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(25) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(25), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(26) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(26), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(27) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(27), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(28) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(28), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(29) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(29), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(30) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(30), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(31) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(31), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(32) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(32), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(33) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(33), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(34) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(34), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(35) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(35), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(36) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(36), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(37) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(37), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(38) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(38), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(39) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(39), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(40) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(40), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(41) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(41), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(42) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(42), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(43) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(43), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(44) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(44), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(45) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(45), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(46) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(46), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(47) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(47), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(48) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(48), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(49) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(49), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(50) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(50), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(51) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(51), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(52) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(52), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(53) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(53), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(54) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(54), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(55) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(55), blocks], 8_int32)) return
    wide_extent = int(settings(2), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(56) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(56), blocks], 8_int32)) return
    wide_extent = int(settings(3), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(57) = int(wide_extent, int32)
    wide_extent = int(settings(4), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_b(57) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(57), extent_b(57), blocks], 8_int32)) return
    call capture_work_record_status(snapshot)
    nullify (state%f_pfrsod)
    nullify (state%f_pfrsodc)
    nullify (state%f_puvdf)
    nullify (state%f_pparf)
    nullify (state%f_pparcf)
    nullify (state%f_pfrthd)
    nullify (state%f_pfrthdc)
    nullify (state%f_ptofdu)
    nullify (state%f_ptofdv)
    nullify (state%f_pftg12)
    nullify (state%f_pfwev)
    nullify (state%f_pfwsb)
    nullify (state%f_pfwg12)
    nullify (state%f_pfwmlt)
    nullify (state%f_pfwrod)
    nullify (state%f_pfwro1)
    nullify (state%f_pftlhev)
    nullify (state%f_pftlhsb)
    nullify (state%f_pfrsoc)
    nullify (state%f_pfrthc)
    nullify (state%f_pdifcq)
    nullify (state%f_pdifcs)
    nullify (state%f_pdiftq)
    nullify (state%f_pdifts)
    nullify (state%f_pfcqng)
    nullify (state%f_pfplcl)
    nullify (state%f_pfplcn)
    nullify (state%f_pfplsl)
    nullify (state%f_pfplsn)
    nullify (state%f_pfhpcl)
    nullify (state%f_pfhpcn)
    nullify (state%f_pfhpsl)
    nullify (state%f_pfhpsn)
    nullify (state%f_pfrso)
    nullify (state%f_pfrth)
    nullify (state%f_pstrcu)
    nullify (state%f_pstrcv)
    nullify (state%f_pstrdu)
    nullify (state%f_pstrdv)
    nullify (state%f_pstrtu)
    nullify (state%f_pstrtv)
    nullify (state%f_pdiftl)
    nullify (state%f_pdifti)
    nullify (state%f_pfccql)
    nullify (state%f_pfccqn)
    nullify (state%f_pfcsql)
    nullify (state%f_pfcsqn)
    nullify (state%f_pfcqlng)
    nullify (state%f_pfcqnng)
    nullify (state%f_pfsqrf)
    nullify (state%f_pfsqsf)
    nullify (state%f_pfcqrng)
    nullify (state%f_pfcqsng)
    nullify (state%f_pfsqltur)
    nullify (state%f_pfsqitur)
    nullify (state%f_penes)
    nullify (state%f_paeroddf)
    status = create_work_field(state%f_pfrsod, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfrsodc, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_puvdf, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pparf, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pparcf, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfrthd, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfrthdc, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptofdu, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptofdv, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pftg12, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfwev, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfwsb, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfwg12, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfwmlt, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfwrod, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfwro1, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pftlhev, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pftlhsb, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfrsoc, [rows, extent_a(19), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfrthc, [rows, extent_a(20), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pdifcq, [rows, extent_a(21), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pdifcs, [rows, extent_a(22), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pdiftq, [rows, extent_a(23), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pdifts, [rows, extent_a(24), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfcqng, [rows, extent_a(25), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfplcl, [rows, extent_a(26), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfplcn, [rows, extent_a(27), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfplsl, [rows, extent_a(28), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfplsn, [rows, extent_a(29), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfhpcl, [rows, extent_a(30), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfhpcn, [rows, extent_a(31), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfhpsl, [rows, extent_a(32), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfhpsn, [rows, extent_a(33), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfrso, [rows, extent_a(34), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfrth, [rows, extent_a(35), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pstrcu, [rows, extent_a(36), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pstrcv, [rows, extent_a(37), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pstrdu, [rows, extent_a(38), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pstrdv, [rows, extent_a(39), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pstrtu, [rows, extent_a(40), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pstrtv, [rows, extent_a(41), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pdiftl, [rows, extent_a(42), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pdifti, [rows, extent_a(43), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfccql, [rows, extent_a(44), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfccqn, [rows, extent_a(45), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfcsql, [rows, extent_a(46), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfcsqn, [rows, extent_a(47), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfcqlng, [rows, extent_a(48), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfcqnng, [rows, extent_a(49), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfsqrf, [rows, extent_a(50), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfsqsf, [rows, extent_a(51), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfcqrng, [rows, extent_a(52), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfcqsng, [rows, extent_a(53), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfsqltur, [rows, extent_a(54), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfsqitur, [rows, extent_a(55), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_penes, [rows, extent_a(56), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_paeroddf, [rows, extent_a(57), extent_b(57), blocks],.not. keep)
    if (status /= 0) goto 900
    call restore_work_record_status(snapshot)
    status = 0
    return
900 cleanup_status = finalize_flux_work_record(state)
    call restore_work_record_status(snapshot)
    status = 1
  end function initialize_flux_work_record
  !> Associate all block views in source order; BLOCK is one-origin.
  !! Required owned fields stay live. Forty source half-level views across
  !! this module use lower bound zero. Only ZDISSGW requests positive zero.
  integer(int32) function update_flux_work_views(state, block) result(status)
    type(flux_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    type(work_record_status_snapshot) :: snapshot
    status = 2
    if (block < 1) return
    if (.not. associated(state%f_pfrsod)) return
    if (.not. associated(state%f_pfrsodc)) return
    if (.not. associated(state%f_puvdf)) return
    if (.not. associated(state%f_pparf)) return
    if (.not. associated(state%f_pparcf)) return
    if (.not. associated(state%f_pfrthd)) return
    if (.not. associated(state%f_pfrthdc)) return
    if (.not. associated(state%f_ptofdu)) return
    if (.not. associated(state%f_ptofdv)) return
    if (.not. associated(state%f_pftg12)) return
    if (.not. associated(state%f_pfwev)) return
    if (.not. associated(state%f_pfwsb)) return
    if (.not. associated(state%f_pfwg12)) return
    if (.not. associated(state%f_pfwmlt)) return
    if (.not. associated(state%f_pfwrod)) return
    if (.not. associated(state%f_pfwro1)) return
    if (.not. associated(state%f_pftlhev)) return
    if (.not. associated(state%f_pftlhsb)) return
    if (.not. associated(state%f_pfrsoc)) return
    if (.not. associated(state%f_pfrthc)) return
    if (.not. associated(state%f_pdifcq)) return
    if (.not. associated(state%f_pdifcs)) return
    if (.not. associated(state%f_pdiftq)) return
    if (.not. associated(state%f_pdifts)) return
    if (.not. associated(state%f_pfcqng)) return
    if (.not. associated(state%f_pfplcl)) return
    if (.not. associated(state%f_pfplcn)) return
    if (.not. associated(state%f_pfplsl)) return
    if (.not. associated(state%f_pfplsn)) return
    if (.not. associated(state%f_pfhpcl)) return
    if (.not. associated(state%f_pfhpcn)) return
    if (.not. associated(state%f_pfhpsl)) return
    if (.not. associated(state%f_pfhpsn)) return
    if (.not. associated(state%f_pfrso)) return
    if (.not. associated(state%f_pfrth)) return
    if (.not. associated(state%f_pstrcu)) return
    if (.not. associated(state%f_pstrcv)) return
    if (.not. associated(state%f_pstrdu)) return
    if (.not. associated(state%f_pstrdv)) return
    if (.not. associated(state%f_pstrtu)) return
    if (.not. associated(state%f_pstrtv)) return
    if (.not. associated(state%f_pdiftl)) return
    if (.not. associated(state%f_pdifti)) return
    if (.not. associated(state%f_pfccql)) return
    if (.not. associated(state%f_pfccqn)) return
    if (.not. associated(state%f_pfcsql)) return
    if (.not. associated(state%f_pfcsqn)) return
    if (.not. associated(state%f_pfcqlng)) return
    if (.not. associated(state%f_pfcqnng)) return
    if (.not. associated(state%f_pfsqrf)) return
    if (.not. associated(state%f_pfsqsf)) return
    if (.not. associated(state%f_pfcqrng)) return
    if (.not. associated(state%f_pfcqsng)) return
    if (.not. associated(state%f_pfsqltur)) return
    if (.not. associated(state%f_pfsqitur)) return
    if (.not. associated(state%f_penes)) return
    if (.not. associated(state%f_paeroddf)) return
    call capture_work_record_status(snapshot)
    status = 0
    status = physics_field_view_2d(state%pfrsod, state%f_pfrsod, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfrsodc, state%f_pfrsodc, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%puvdf, state%f_puvdf, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pparf, state%f_pparf, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pparcf, state%f_pparcf, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfrthd, state%f_pfrthd, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfrthdc, state%f_pfrthdc, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ptofdu, state%f_ptofdu, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ptofdv, state%f_ptofdv, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pftg12, state%f_pftg12, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfwev, state%f_pfwev, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfwsb, state%f_pfwsb, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfwg12, state%f_pfwg12, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfwmlt, state%f_pfwmlt, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfwrod, state%f_pfwrod, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfwro1, state%f_pfwro1, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pftlhev, state%f_pftlhev, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pftlhsb, state%f_pftlhsb, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pfrsoc, state%f_pfrsoc, block)
    if (status /= 0) goto 900
    state%pfrsoc(1:, 0:) => state%pfrsoc
    status = physics_field_view_3d(state%pfrthc, state%f_pfrthc, block)
    if (status /= 0) goto 900
    state%pfrthc(1:, 0:) => state%pfrthc
    status = physics_field_view_3d(state%pdifcq, state%f_pdifcq, block)
    if (status /= 0) goto 900
    state%pdifcq(1:, 0:) => state%pdifcq
    status = physics_field_view_3d(state%pdifcs, state%f_pdifcs, block)
    if (status /= 0) goto 900
    state%pdifcs(1:, 0:) => state%pdifcs
    status = physics_field_view_3d(state%pdiftq, state%f_pdiftq, block)
    if (status /= 0) goto 900
    state%pdiftq(1:, 0:) => state%pdiftq
    status = physics_field_view_3d(state%pdifts, state%f_pdifts, block)
    if (status /= 0) goto 900
    state%pdifts(1:, 0:) => state%pdifts
    status = physics_field_view_3d(state%pfcqng, state%f_pfcqng, block)
    if (status /= 0) goto 900
    state%pfcqng(1:, 0:) => state%pfcqng
    status = physics_field_view_3d(state%pfplcl, state%f_pfplcl, block)
    if (status /= 0) goto 900
    state%pfplcl(1:, 0:) => state%pfplcl
    status = physics_field_view_3d(state%pfplcn, state%f_pfplcn, block)
    if (status /= 0) goto 900
    state%pfplcn(1:, 0:) => state%pfplcn
    status = physics_field_view_3d(state%pfplsl, state%f_pfplsl, block)
    if (status /= 0) goto 900
    state%pfplsl(1:, 0:) => state%pfplsl
    status = physics_field_view_3d(state%pfplsn, state%f_pfplsn, block)
    if (status /= 0) goto 900
    state%pfplsn(1:, 0:) => state%pfplsn
    status = physics_field_view_3d(state%pfhpcl, state%f_pfhpcl, block)
    if (status /= 0) goto 900
    state%pfhpcl(1:, 0:) => state%pfhpcl
    status = physics_field_view_3d(state%pfhpcn, state%f_pfhpcn, block)
    if (status /= 0) goto 900
    state%pfhpcn(1:, 0:) => state%pfhpcn
    status = physics_field_view_3d(state%pfhpsl, state%f_pfhpsl, block)
    if (status /= 0) goto 900
    state%pfhpsl(1:, 0:) => state%pfhpsl
    status = physics_field_view_3d(state%pfhpsn, state%f_pfhpsn, block)
    if (status /= 0) goto 900
    state%pfhpsn(1:, 0:) => state%pfhpsn
    status = physics_field_view_3d(state%pfrso, state%f_pfrso, block)
    if (status /= 0) goto 900
    state%pfrso(1:, 0:) => state%pfrso
    status = physics_field_view_3d(state%pfrth, state%f_pfrth, block)
    if (status /= 0) goto 900
    state%pfrth(1:, 0:) => state%pfrth
    status = physics_field_view_3d(state%pstrcu, state%f_pstrcu, block)
    if (status /= 0) goto 900
    state%pstrcu(1:, 0:) => state%pstrcu
    status = physics_field_view_3d(state%pstrcv, state%f_pstrcv, block)
    if (status /= 0) goto 900
    state%pstrcv(1:, 0:) => state%pstrcv
    status = physics_field_view_3d(state%pstrdu, state%f_pstrdu, block)
    if (status /= 0) goto 900
    state%pstrdu(1:, 0:) => state%pstrdu
    status = physics_field_view_3d(state%pstrdv, state%f_pstrdv, block)
    if (status /= 0) goto 900
    state%pstrdv(1:, 0:) => state%pstrdv
    status = physics_field_view_3d(state%pstrtu, state%f_pstrtu, block)
    if (status /= 0) goto 900
    state%pstrtu(1:, 0:) => state%pstrtu
    status = physics_field_view_3d(state%pstrtv, state%f_pstrtv, block)
    if (status /= 0) goto 900
    state%pstrtv(1:, 0:) => state%pstrtv
    status = physics_field_view_3d(state%pdiftl, state%f_pdiftl, block)
    if (status /= 0) goto 900
    state%pdiftl(1:, 0:) => state%pdiftl
    status = physics_field_view_3d(state%pdifti, state%f_pdifti, block)
    if (status /= 0) goto 900
    state%pdifti(1:, 0:) => state%pdifti
    status = physics_field_view_3d(state%pfccql, state%f_pfccql, block)
    if (status /= 0) goto 900
    state%pfccql(1:, 0:) => state%pfccql
    status = physics_field_view_3d(state%pfccqn, state%f_pfccqn, block)
    if (status /= 0) goto 900
    state%pfccqn(1:, 0:) => state%pfccqn
    status = physics_field_view_3d(state%pfcsql, state%f_pfcsql, block)
    if (status /= 0) goto 900
    state%pfcsql(1:, 0:) => state%pfcsql
    status = physics_field_view_3d(state%pfcsqn, state%f_pfcsqn, block)
    if (status /= 0) goto 900
    state%pfcsqn(1:, 0:) => state%pfcsqn
    status = physics_field_view_3d(state%pfcqlng, state%f_pfcqlng, block)
    if (status /= 0) goto 900
    state%pfcqlng(1:, 0:) => state%pfcqlng
    status = physics_field_view_3d(state%pfcqnng, state%f_pfcqnng, block)
    if (status /= 0) goto 900
    state%pfcqnng(1:, 0:) => state%pfcqnng
    status = physics_field_view_3d(state%pfsqrf, state%f_pfsqrf, block)
    if (status /= 0) goto 900
    state%pfsqrf(1:, 0:) => state%pfsqrf
    status = physics_field_view_3d(state%pfsqsf, state%f_pfsqsf, block)
    if (status /= 0) goto 900
    state%pfsqsf(1:, 0:) => state%pfsqsf
    status = physics_field_view_3d(state%pfcqrng, state%f_pfcqrng, block)
    if (status /= 0) goto 900
    state%pfcqrng(1:, 0:) => state%pfcqrng
    status = physics_field_view_3d(state%pfcqsng, state%f_pfcqsng, block)
    if (status /= 0) goto 900
    state%pfcqsng(1:, 0:) => state%pfcqsng
    status = physics_field_view_3d(state%pfsqltur, state%f_pfsqltur, block)
    if (status /= 0) goto 900
    state%pfsqltur(1:, 0:) => state%pfsqltur
    status = physics_field_view_3d(state%pfsqitur, state%f_pfsqitur, block)
    if (status /= 0) goto 900
    state%pfsqitur(1:, 0:) => state%pfsqitur
    status = physics_field_view_4d(state%paeroddf, state%f_paeroddf, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%penes, state%f_penes, block)
    if (status /= 0) goto 900
900 call restore_work_record_status(snapshot)
  end function update_flux_work_views
  !> Release only owned fields in the source finalization order.
  !! Public views and source-unwritten members stay unchanged, including after
  !! a partly completed initialization. Borrowed storage is never released.
  integer(int32) function finalize_flux_work_record(state) result(status)
    type(flux_type), intent(inout) :: state
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    call delete_work_field(state%f_pfrsod)
    call delete_work_field(state%f_pfrsodc)
    call delete_work_field(state%f_puvdf)
    call delete_work_field(state%f_pparf)
    call delete_work_field(state%f_pparcf)
    call delete_work_field(state%f_pfrthd)
    call delete_work_field(state%f_pfrthdc)
    call delete_work_field(state%f_ptofdu)
    call delete_work_field(state%f_ptofdv)
    call delete_work_field(state%f_pftg12)
    call delete_work_field(state%f_pfwev)
    call delete_work_field(state%f_pfwsb)
    call delete_work_field(state%f_pfwg12)
    call delete_work_field(state%f_pfwmlt)
    call delete_work_field(state%f_pfwrod)
    call delete_work_field(state%f_pfwro1)
    call delete_work_field(state%f_pftlhev)
    call delete_work_field(state%f_pftlhsb)
    call delete_work_field(state%f_pfrsoc)
    call delete_work_field(state%f_pfrthc)
    call delete_work_field(state%f_pdifcq)
    call delete_work_field(state%f_pdifcs)
    call delete_work_field(state%f_pdiftq)
    call delete_work_field(state%f_pdifts)
    call delete_work_field(state%f_pfcqng)
    call delete_work_field(state%f_pfplcl)
    call delete_work_field(state%f_pfplcn)
    call delete_work_field(state%f_pfplsl)
    call delete_work_field(state%f_pfplsn)
    call delete_work_field(state%f_pfhpcl)
    call delete_work_field(state%f_pfhpcn)
    call delete_work_field(state%f_pfhpsl)
    call delete_work_field(state%f_pfhpsn)
    call delete_work_field(state%f_pfrso)
    call delete_work_field(state%f_pfrth)
    call delete_work_field(state%f_pstrcu)
    call delete_work_field(state%f_pstrcv)
    call delete_work_field(state%f_pstrdu)
    call delete_work_field(state%f_pstrdv)
    call delete_work_field(state%f_pstrtu)
    call delete_work_field(state%f_pstrtv)
    call delete_work_field(state%f_pdiftl)
    call delete_work_field(state%f_pdifti)
    call delete_work_field(state%f_pfccql)
    call delete_work_field(state%f_pfccqn)
    call delete_work_field(state%f_pfcsql)
    call delete_work_field(state%f_pfcsqn)
    call delete_work_field(state%f_pfcqlng)
    call delete_work_field(state%f_pfcqnng)
    call delete_work_field(state%f_pfsqrf)
    call delete_work_field(state%f_pfsqsf)
    call delete_work_field(state%f_pfcqrng)
    call delete_work_field(state%f_pfcqsng)
    call delete_work_field(state%f_pfsqltur)
    call delete_work_field(state%f_pfsqitur)
    call delete_work_field(state%f_penes)
    call delete_additional_work_field(state%f_paeroddf)
    call restore_work_record_status(snapshot)
    status = 0
  end function finalize_flux_work_record
  !> Preserve the original method counter and constructor abort boundary.
  subroutine flux_type_init(state, geometry, nlev, nlevs, nactaero, npaerodiag, persistent)
    type(flux_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    integer(int32), intent(in) :: nlev, nlevs, nactaero, npaerodiag
    logical, optional, intent(in) :: persistent
    integer(int32) :: status
    call increment_work_word(native_call_counts(1))
    status = initialize_flux_work_record(state, geometry, [nlev, nlevs, nactaero, npaerodiag], persistent)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine flux_type_update_view(state, block)
    type(flux_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    integer(int32) :: status
    call increment_work_word(native_call_counts(2))
    status = update_flux_work_views(state, block)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine flux_type_final(state)
    type(flux_type), intent(inout) :: state
    integer(int32) :: status
    call increment_work_word(native_call_counts(3))
    status = finalize_flux_work_record(state)
  end subroutine
  !> Own 49 fields in source order. STATE must have no live owned heads.
  !! GEOMETRY and counts stay readonly. PERSISTENT defaults false; true keeps
  !! actual grid blocks. New values and incoming public views remain unchanged.
  !! Status0 succeeds,1 cleans a failed allocation prefix,2 refuses unsupported
  !! native metadata before ownership changes. No original method is called.
  integer(int32) function initialize_auxiliary_diagnostic_work_record(state, geometry, nlev, persistent) result(status)
    type(aux_diag_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    integer(int32), intent(in) :: nlev
    logical, optional, intent(in) :: persistent
    logical :: keep
    integer(int32) :: rows, blocks, cleanup_status
    integer(int32) :: extent_a(49), extent_b(49)
    integer(int64) :: wide_extent
    type(work_record_status_snapshot) :: snapshot
    status = 2
    rows = geometry%dimensions%nproma
    blocks = geometry%partition%ngpblks
    if (rows < 1 .or. blocks < 1) return
    if (nlev < 0) return
    if (associated(state%f_pcape)) return
    if (associated(state%f_ppdepl)) return
    if (associated(state%f_pcbase)) return
    if (associated(state%f_pcbasea)) return
    if (associated(state%f_pctopc)) return
    if (associated(state%f_p0degl)) return
    if (associated(state%f_pm10degl)) return
    if (associated(state%f_ptropotp)) return
    if (associated(state%f_pvisih)) return
    if (associated(state%f_pvdiscu)) return
    if (associated(state%f_pvdis)) return
    if (associated(state%f_pvdisg)) return
    if (associated(state%f_pustrg)) return
    if (associated(state%f_pvstrg)) return
    if (associated(state%f_pi10fg)) return
    if (associated(state%f_pprectype)) return
    if (associated(state%f_pfzra)) return
    if (associated(state%f_pconvind)) return
    if (associated(state%f_pztwetb)) return
    if (associated(state%f_zcape)) return
    if (associated(state%f_pcin)) return
    if (associated(state%f_pqsat)) return
    if (associated(state%f_pztent)) return
    if (associated(state%f_pztenq)) return
    if (associated(state%f_pmfude_rate)) return
    if (associated(state%f_pmfdde_rate)) return
    if (associated(state%f_pkh_vdf)) return
    if (associated(state%f_pkm_vdf)) return
    if (associated(state%f_zri)) return
    if (associated(state%f_pcovptot)) return
    if (associated(state%f_pmfu)) return
    if (associated(state%f_pmfd)) return
    if (associated(state%f_zlude)) return
    if (associated(state%f_zludeli)) return
    if (associated(state%f_zsnde)) return
    if (associated(state%f_prsud)) return
    if (associated(state%f_zlu)) return
    if (associated(state%f_zlrain)) return
    if (associated(state%f_pligh_tot)) return
    if (associated(state%f_pligh_ctg)) return
    if (associated(state%f_pcharge_lig)) return
    if (associated(state%f_zeis)) return
    if (associated(state%f_zinv)) return
    if (associated(state%f_itype)) return
    if (associated(state%f_icbot)) return
    if (associated(state%f_ictop)) return
    if (associated(state%f_ipbltype)) return
    if (associated(state%f_icbot_lig)) return
    if (associated(state%f_ictop_lig)) return
    keep = .false.
    if (present(persistent)) keep = persistent
    if (.not. keep) blocks = 1
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    wide_extent = 2_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(18) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(18), blocks], 8_int32)) return
    wide_extent = 2_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(19) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(19), blocks], 8_int32)) return
    wide_extent = 4_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(20) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(20), blocks], 8_int32)) return
    wide_extent = 3_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(21) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(21), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(22) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(22), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(23) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(23), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(24) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(24), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(25) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(25), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(26) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(26), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(27) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(27), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(28) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(28), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(29) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(29), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(30) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(30), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(31) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(31), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(32) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(32), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(33) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(33), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(34) = int(wide_extent, int32)
    wide_extent = 4_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_b(34) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(34), extent_b(34), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(35) = int(wide_extent, int32)
    wide_extent = 2_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_b(35) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(35), extent_b(35), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(36) = int(wide_extent, int32)
    wide_extent = 2_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_b(36) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(36), extent_b(36), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(37) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(37), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(38) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(38), blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    call capture_work_record_status(snapshot)
    nullify (state%f_pcape)
    nullify (state%f_ppdepl)
    nullify (state%f_pcbase)
    nullify (state%f_pcbasea)
    nullify (state%f_pctopc)
    nullify (state%f_p0degl)
    nullify (state%f_pm10degl)
    nullify (state%f_ptropotp)
    nullify (state%f_pvisih)
    nullify (state%f_pvdiscu)
    nullify (state%f_pvdis)
    nullify (state%f_pvdisg)
    nullify (state%f_pustrg)
    nullify (state%f_pvstrg)
    nullify (state%f_pi10fg)
    nullify (state%f_pprectype)
    nullify (state%f_pfzra)
    nullify (state%f_pconvind)
    nullify (state%f_pztwetb)
    nullify (state%f_zcape)
    nullify (state%f_pcin)
    nullify (state%f_pqsat)
    nullify (state%f_pztent)
    nullify (state%f_pztenq)
    nullify (state%f_pmfude_rate)
    nullify (state%f_pmfdde_rate)
    nullify (state%f_pkh_vdf)
    nullify (state%f_pkm_vdf)
    nullify (state%f_zri)
    nullify (state%f_pcovptot)
    nullify (state%f_pmfu)
    nullify (state%f_pmfd)
    nullify (state%f_zlude)
    nullify (state%f_zludeli)
    nullify (state%f_zsnde)
    nullify (state%f_prsud)
    nullify (state%f_zlu)
    nullify (state%f_zlrain)
    nullify (state%f_pligh_tot)
    nullify (state%f_pligh_ctg)
    nullify (state%f_pcharge_lig)
    nullify (state%f_zeis)
    nullify (state%f_zinv)
    nullify (state%f_itype)
    nullify (state%f_icbot)
    nullify (state%f_ictop)
    nullify (state%f_ipbltype)
    nullify (state%f_icbot_lig)
    nullify (state%f_ictop_lig)
    status = create_work_field(state%f_pcape, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ppdepl, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pcbase, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pcbasea, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pctopc, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_p0degl, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pm10degl, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ptropotp, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pvisih, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pvdiscu, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pvdis, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pvdisg, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pustrg, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pvstrg, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pi10fg, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pprectype, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pfzra, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pconvind, [rows, extent_a(18), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pztwetb, [rows, extent_a(19), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zcape, [rows, extent_a(20), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pcin, [rows, extent_a(21), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pqsat, [rows, extent_a(22), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pztent, [rows, extent_a(23), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pztenq, [rows, extent_a(24), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pmfude_rate, [rows, extent_a(25), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pmfdde_rate, [rows, extent_a(26), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pkh_vdf, [rows, extent_a(27), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pkm_vdf, [rows, extent_a(28), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zri, [rows, extent_a(29), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pcovptot, [rows, extent_a(30), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pmfu, [rows, extent_a(31), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pmfd, [rows, extent_a(32), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zlude, [rows, extent_a(33), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_zludeli, [rows, extent_a(34), extent_b(34), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_zsnde, [rows, extent_a(35), extent_b(35), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_prsud, [rows, extent_a(36), extent_b(36), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zlu, [rows, extent_a(37), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zlrain, [rows, extent_a(38), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pligh_tot, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pligh_ctg, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pcharge_lig, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zeis, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zinv, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_itype, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_icbot, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ictop, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ipbltype, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_icbot_lig, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ictop_lig, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    call restore_work_record_status(snapshot)
    status = 0
    return
900 cleanup_status = finalize_auxiliary_diagnostic_work_record(state)
    call restore_work_record_status(snapshot)
    status = 1
  end function initialize_auxiliary_diagnostic_work_record
  !> Associate all block views in source order; BLOCK is one-origin.
  !! Required owned fields stay live. Forty source half-level views across
  !! this module use lower bound zero. Only ZDISSGW requests positive zero.
  integer(int32) function update_auxiliary_diagnostic_work_views(state, block) result(status)
    type(aux_diag_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    type(work_record_status_snapshot) :: snapshot
    status = 2
    if (block < 1) return
    if (.not. associated(state%f_pcape)) return
    if (.not. associated(state%f_ppdepl)) return
    if (.not. associated(state%f_pcbase)) return
    if (.not. associated(state%f_pcbasea)) return
    if (.not. associated(state%f_pctopc)) return
    if (.not. associated(state%f_p0degl)) return
    if (.not. associated(state%f_pm10degl)) return
    if (.not. associated(state%f_ptropotp)) return
    if (.not. associated(state%f_pvisih)) return
    if (.not. associated(state%f_pvdiscu)) return
    if (.not. associated(state%f_pvdis)) return
    if (.not. associated(state%f_pvdisg)) return
    if (.not. associated(state%f_pustrg)) return
    if (.not. associated(state%f_pvstrg)) return
    if (.not. associated(state%f_pi10fg)) return
    if (.not. associated(state%f_pprectype)) return
    if (.not. associated(state%f_pfzra)) return
    if (.not. associated(state%f_pconvind)) return
    if (.not. associated(state%f_pztwetb)) return
    if (.not. associated(state%f_zcape)) return
    if (.not. associated(state%f_pcin)) return
    if (.not. associated(state%f_pqsat)) return
    if (.not. associated(state%f_pztent)) return
    if (.not. associated(state%f_pztenq)) return
    if (.not. associated(state%f_pmfude_rate)) return
    if (.not. associated(state%f_pmfdde_rate)) return
    if (.not. associated(state%f_pkh_vdf)) return
    if (.not. associated(state%f_pkm_vdf)) return
    if (.not. associated(state%f_zri)) return
    if (.not. associated(state%f_pcovptot)) return
    if (.not. associated(state%f_pmfu)) return
    if (.not. associated(state%f_pmfd)) return
    if (.not. associated(state%f_zlude)) return
    if (.not. associated(state%f_zludeli)) return
    if (.not. associated(state%f_zsnde)) return
    if (.not. associated(state%f_prsud)) return
    if (.not. associated(state%f_zlu)) return
    if (.not. associated(state%f_zlrain)) return
    if (.not. associated(state%f_pligh_tot)) return
    if (.not. associated(state%f_pligh_ctg)) return
    if (.not. associated(state%f_pcharge_lig)) return
    if (.not. associated(state%f_zeis)) return
    if (.not. associated(state%f_zinv)) return
    if (.not. associated(state%f_itype)) return
    if (.not. associated(state%f_icbot)) return
    if (.not. associated(state%f_ictop)) return
    if (.not. associated(state%f_ipbltype)) return
    if (.not. associated(state%f_icbot_lig)) return
    if (.not. associated(state%f_ictop_lig)) return
    call capture_work_record_status(snapshot)
    status = 0
    status = physics_field_view_2d(state%pcape, state%f_pcape, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zcape, state%f_zcape, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ppdepl, state%f_ppdepl, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pcbase, state%f_pcbase, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pcbasea, state%f_pcbasea, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pctopc, state%f_pctopc, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%p0degl, state%f_p0degl, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pm10degl, state%f_pm10degl, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ptropotp, state%f_ptropotp, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pvisih, state%f_pvisih, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pcin, state%f_pcin, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pvdiscu, state%f_pvdiscu, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pvdis, state%f_pvdis, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pvdisg, state%f_pvdisg, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pustrg, state%f_pustrg, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pvstrg, state%f_pvstrg, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pi10fg, state%f_pi10fg, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pprectype, state%f_pprectype, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pfzra, state%f_pfzra, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pconvind, state%f_pconvind, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pztwetb, state%f_pztwetb, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pqsat, state%f_pqsat, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pztent, state%f_pztent, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pztenq, state%f_pztenq, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pmfude_rate, state%f_pmfude_rate, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pmfdde_rate, state%f_pmfdde_rate, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pkh_vdf, state%f_pkh_vdf, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pkm_vdf, state%f_pkm_vdf, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zri, state%f_zri, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pcovptot, state%f_pcovptot, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pmfu, state%f_pmfu, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pmfd, state%f_pmfd, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zlude, state%f_zlude, block)
    if (status /= 0) goto 900
    status = physics_field_view_4d(state%zludeli, state%f_zludeli, block)
    if (status /= 0) goto 900
    status = physics_field_view_4d(state%zsnde, state%f_zsnde, block)
    if (status /= 0) goto 900
    status = physics_field_view_4d(state%prsud, state%f_prsud, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zlu, state%f_zlu, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zlrain, state%f_zlrain, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pligh_tot, state%f_pligh_tot, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pligh_ctg, state%f_pligh_ctg, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%pcharge_lig, state%f_pcharge_lig, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zeis, state%f_zeis, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zinv, state%f_zinv, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%itype, state%f_itype, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%icbot, state%f_icbot, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%ictop, state%f_ictop, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%ipbltype, state%f_ipbltype, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%icbot_lig, state%f_icbot_lig, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%ictop_lig, state%f_ictop_lig, block)
    if (status /= 0) goto 900
900 call restore_work_record_status(snapshot)
  end function update_auxiliary_diagnostic_work_views
  !> Release only owned fields in the source finalization order.
  !! Public views and source-unwritten members stay unchanged, including after
  !! a partly completed initialization. Borrowed storage is never released.
  integer(int32) function finalize_auxiliary_diagnostic_work_record(state) result(status)
    type(aux_diag_type), intent(inout) :: state
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    call delete_work_field(state%f_pcape)
    call delete_work_field(state%f_zcape)
    call delete_work_field(state%f_ppdepl)
    call delete_work_field(state%f_pcbase)
    call delete_work_field(state%f_pcbasea)
    call delete_work_field(state%f_pctopc)
    call delete_work_field(state%f_p0degl)
    call delete_work_field(state%f_pm10degl)
    call delete_work_field(state%f_ptropotp)
    call delete_work_field(state%f_pvisih)
    call delete_work_field(state%f_pcin)
    call delete_work_field(state%f_pvdiscu)
    call delete_work_field(state%f_pvdis)
    call delete_work_field(state%f_pvdisg)
    call delete_work_field(state%f_pustrg)
    call delete_work_field(state%f_pvstrg)
    call delete_work_field(state%f_pi10fg)
    call delete_work_field(state%f_pprectype)
    call delete_work_field(state%f_pfzra)
    call delete_work_field(state%f_pconvind)
    call delete_work_field(state%f_pztwetb)
    call delete_work_field(state%f_pqsat)
    call delete_work_field(state%f_pztent)
    call delete_work_field(state%f_pztenq)
    call delete_work_field(state%f_pmfude_rate)
    call delete_work_field(state%f_pmfdde_rate)
    call delete_work_field(state%f_pkh_vdf)
    call delete_work_field(state%f_pkm_vdf)
    call delete_work_field(state%f_zri)
    call delete_work_field(state%f_pcovptot)
    call delete_work_field(state%f_pmfu)
    call delete_work_field(state%f_pmfd)
    call delete_work_field(state%f_zlude)
    call delete_additional_work_field(state%f_zludeli)
    call delete_additional_work_field(state%f_zsnde)
    call delete_additional_work_field(state%f_prsud)
    call delete_work_field(state%f_zlu)
    call delete_work_field(state%f_zlrain)
    call delete_work_field(state%f_pligh_tot)
    call delete_work_field(state%f_pligh_ctg)
    call delete_work_field(state%f_pcharge_lig)
    call delete_work_field(state%f_zeis)
    call delete_work_field(state%f_zinv)
    call delete_work_field(state%f_itype)
    call delete_work_field(state%f_icbot)
    call delete_work_field(state%f_ictop)
    call delete_work_field(state%f_ipbltype)
    call delete_work_field(state%f_icbot_lig)
    call delete_work_field(state%f_ictop_lig)
    call restore_work_record_status(snapshot)
    status = 0
  end function finalize_auxiliary_diagnostic_work_record
  !> Preserve the original method counter and constructor abort boundary.
  subroutine aux_diag_type_init(state, geometry, nlev, persistent)
    type(aux_diag_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    integer(int32), intent(in) :: nlev
    logical, optional, intent(in) :: persistent
    integer(int32) :: status
    call increment_work_word(native_call_counts(4))
    status = initialize_auxiliary_diagnostic_work_record(state, geometry, nlev, persistent)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine aux_diag_type_update_view(state, block)
    type(aux_diag_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    integer(int32) :: status
    call increment_work_word(native_call_counts(5))
    status = update_auxiliary_diagnostic_work_views(state, block)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine aux_diag_type_final(state)
    type(aux_diag_type), intent(inout) :: state
    integer(int32) :: status
    call increment_work_word(native_call_counts(6))
    status = finalize_auxiliary_diagnostic_work_record(state)
  end subroutine
  !> Own 7 fields in source order. STATE must have no live owned heads.
  !! GEOMETRY and counts stay readonly. PERSISTENT defaults false; true keeps
  !! actual grid blocks. New values and incoming public views remain unchanged.
  !! Status0 succeeds,1 cleans a failed allocation prefix,2 refuses unsupported
  !! native metadata before ownership changes. No original method is called.
  integer(int32) function initialize_surface_diagnostic_work_record(state, geometry, dimensions, persistent) result(status)
    type(ddh_surf_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    type(dimension_type), intent(in) :: dimensions
    logical, optional, intent(in) :: persistent
    logical :: keep
    integer(int32) :: rows, blocks, cleanup_status
    integer(int32) :: extent_a(7), extent_b(7)
    integer(int64) :: wide_extent
    type(work_record_status_snapshot) :: snapshot
    status = 2
    rows = geometry%dimensions%nproma
    blocks = geometry%partition%ngpblks
    if (rows < 1 .or. blocks < 1) return
    if (dimensions%klevs < 0) return
    if (dimensions%ktiles < 0) return
    if (dimensions%klevi < 0) return
    if (dimensions%klevsn < 0) return
    if (dimensions%kdhvtls < 0) return
    if (dimensions%kdhftls < 0) return
    if (dimensions%kdhvtss < 0) return
    if (dimensions%kdhftss < 0) return
    if (dimensions%kdhvtts < 0) return
    if (dimensions%kdhftts < 0) return
    if (dimensions%kdhvtis < 0) return
    if (dimensions%kdhftis < 0) return
    if (dimensions%kdhvsss < 0) return
    if (dimensions%kdhfsss < 0) return
    if (dimensions%kdhviis < 0) return
    if (dimensions%kdhfiis < 0) return
    if (dimensions%kdhvwls < 0) return
    if (dimensions%kdhfwls < 0) return
    if (associated(state%f_pdhtls)) return
    if (associated(state%f_pdhtss)) return
    if (associated(state%f_pdhtts)) return
    if (associated(state%f_pdhtis)) return
    if (associated(state%f_pdhsss)) return
    if (associated(state%f_pdhiis)) return
    if (associated(state%f_pdhwls)) return
    keep = .false.
    if (present(persistent)) keep = persistent
    keep = .false. ! The original DDH constructor does not forward PERSISTENT.
    if (.not. keep) blocks = 1
    wide_extent = int(dimensions%ktiles, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(1) = int(wide_extent, int32)
    wide_extent = int(dimensions%kdhvtls, int64) + int(dimensions%kdhftls, int64)
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_b(1) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(1), extent_b(1), blocks], 8_int32)) return
    wide_extent = int(dimensions%klevsn, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(2) = int(wide_extent, int32)
    wide_extent = int(dimensions%kdhvtss, int64) + int(dimensions%kdhftss, int64)
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_b(2) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(2), extent_b(2), blocks], 8_int32)) return
    wide_extent = int(dimensions%klevs, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(3) = int(wide_extent, int32)
    wide_extent = int(dimensions%kdhvtts, int64) + int(dimensions%kdhftts, int64)
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_b(3) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(3), extent_b(3), blocks], 8_int32)) return
    wide_extent = int(dimensions%klevi, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(4) = int(wide_extent, int32)
    wide_extent = int(dimensions%kdhvtis, int64) + int(dimensions%kdhftis, int64)
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_b(4) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(4), extent_b(4), blocks], 8_int32)) return
    wide_extent = int(dimensions%klevsn, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(5) = int(wide_extent, int32)
    wide_extent = int(dimensions%kdhvsss, int64) + int(dimensions%kdhfsss, int64)
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_b(5) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(5), extent_b(5), blocks], 8_int32)) return
    wide_extent = int(dimensions%kdhviis, int64) + int(dimensions%kdhfiis, int64)
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(6) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(6), blocks], 8_int32)) return
    wide_extent = int(dimensions%klevs, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(7) = int(wide_extent, int32)
    wide_extent = int(dimensions%kdhvwls, int64) + int(dimensions%kdhfwls, int64)
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_b(7) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(7), extent_b(7), blocks], 8_int32)) return
    call capture_work_record_status(snapshot)
    nullify (state%f_pdhtls)
    nullify (state%f_pdhtss)
    nullify (state%f_pdhtts)
    nullify (state%f_pdhtis)
    nullify (state%f_pdhsss)
    nullify (state%f_pdhiis)
    nullify (state%f_pdhwls)
    status = create_additional_work_field(state%f_pdhtls, [rows, extent_a(1), extent_b(1), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_pdhtss, [rows, extent_a(2), extent_b(2), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_pdhtts, [rows, extent_a(3), extent_b(3), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_pdhtis, [rows, extent_a(4), extent_b(4), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_pdhsss, [rows, extent_a(5), extent_b(5), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_pdhiis, [rows, extent_a(6), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_pdhwls, [rows, extent_a(7), extent_b(7), blocks],.not. keep)
    if (status /= 0) goto 900
    call restore_work_record_status(snapshot)
    status = 0
    return
900 cleanup_status = finalize_surface_diagnostic_work_record(state)
    call restore_work_record_status(snapshot)
    status = 1
  end function initialize_surface_diagnostic_work_record
  !> Associate all block views in source order; BLOCK is one-origin.
  !! Required owned fields stay live. Forty source half-level views across
  !! this module use lower bound zero. Only ZDISSGW requests positive zero.
  integer(int32) function update_surface_diagnostic_work_views(state, block) result(status)
    type(ddh_surf_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    type(work_record_status_snapshot) :: snapshot
    status = 2
    if (block < 1) return
    if (.not. associated(state%f_pdhtls)) return
    if (.not. associated(state%f_pdhtss)) return
    if (.not. associated(state%f_pdhtts)) return
    if (.not. associated(state%f_pdhtis)) return
    if (.not. associated(state%f_pdhsss)) return
    if (.not. associated(state%f_pdhiis)) return
    if (.not. associated(state%f_pdhwls)) return
    call capture_work_record_status(snapshot)
    status = 0
    status = physics_field_view_4d(state%pdhtls, state%f_pdhtls, block)
    if (status /= 0) goto 900
    status = physics_field_view_4d(state%pdhtss, state%f_pdhtss, block)
    if (status /= 0) goto 900
    status = physics_field_view_4d(state%pdhtts, state%f_pdhtts, block)
    if (status /= 0) goto 900
    status = physics_field_view_4d(state%pdhtis, state%f_pdhtis, block)
    if (status /= 0) goto 900
    status = physics_field_view_4d(state%pdhsss, state%f_pdhsss, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%pdhiis, state%f_pdhiis, block)
    if (status /= 0) goto 900
    status = physics_field_view_4d(state%pdhwls, state%f_pdhwls, block)
    if (status /= 0) goto 900
900 call restore_work_record_status(snapshot)
  end function update_surface_diagnostic_work_views
  !> Release only owned fields in the source finalization order.
  !! Public views and source-unwritten members stay unchanged, including after
  !! a partly completed initialization. Borrowed storage is never released.
  integer(int32) function finalize_surface_diagnostic_work_record(state) result(status)
    type(ddh_surf_type), intent(inout) :: state
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    call delete_additional_work_field(state%f_pdhtls)
    call delete_additional_work_field(state%f_pdhtss)
    call delete_additional_work_field(state%f_pdhtts)
    call delete_additional_work_field(state%f_pdhtis)
    call delete_additional_work_field(state%f_pdhsss)
    call delete_work_field(state%f_pdhiis)
    call delete_additional_work_field(state%f_pdhwls)
    call restore_work_record_status(snapshot)
    status = 0
  end function finalize_surface_diagnostic_work_record
  !> Preserve the original method counter and constructor abort boundary.
  subroutine ddh_surf_type_init(state, geometry, dimensions, persistent)
    type(ddh_surf_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    type(dimension_type), intent(in) :: dimensions
    logical, optional, intent(in) :: persistent
    integer(int32) :: status
    call increment_work_word(native_call_counts(7))
    status = initialize_surface_diagnostic_work_record(state, geometry, dimensions, persistent)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine ddh_surf_type_update_view(state, block)
    type(ddh_surf_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    integer(int32) :: status
    call increment_work_word(native_call_counts(8))
    status = update_surface_diagnostic_work_views(state, block)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine ddh_surf_type_final(state)
    type(ddh_surf_type), intent(inout) :: state
    integer(int32) :: status
    call increment_work_word(native_call_counts(9))
    status = finalize_surface_diagnostic_work_record(state)
  end subroutine
  !> Own 27 fields in source order. STATE must have no live owned heads.
  !! GEOMETRY and counts stay readonly. PERSISTENT defaults false; true keeps
  !! actual grid blocks. New values and incoming public views remain unchanged.
  !! Status0 succeeds,1 cleans a failed allocation prefix,2 refuses unsupported
  !! native metadata before ownership changes. No original method is called.
  integer(int32) function initialize_auxiliary_diagnostic_local_work_record(state, geometry, nlev, persistent) result(status)
    type(aux_diag_local_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    integer(int32), intent(in) :: nlev
    logical, optional, intent(in) :: persistent
    logical :: keep
    integer(int32) :: rows, blocks, cleanup_status
    integer(int32) :: extent_a(27), extent_b(27)
    integer(int64) :: wide_extent
    type(work_record_status_snapshot) :: snapshot
    status = 2
    rows = geometry%dimensions%nproma
    blocks = geometry%partition%ngpblks
    if (rows < 1 .or. blocks < 1) return
    if (nlev < 0) return
    if (associated(state%f_zwnd)) return
    if (associated(state%f_zccnl)) return
    if (associated(state%f_zccno)) return
    if (associated(state%f_zemit)) return
    if (associated(state%f_ztrsod)) return
    if (associated(state%f_zsudu)) return
    if (associated(state%f_ztskrad)) return
    if (associated(state%f_zrainfrac_toprfz)) return
    if (associated(state%f_ztht)) return
    if (associated(state%f_zsoteu)) return
    if (associated(state%f_zsotev)) return
    if (associated(state%f_zsobeta)) return
    if (associated(state%f_zlcrit_aer)) return
    if (associated(state%f_zicrit_aer)) return
    if (associated(state%f_zre_liq)) return
    if (associated(state%f_zre_ice)) return
    if (associated(state%f_zccn)) return
    if (associated(state%f_znice)) return
    if (associated(state%f_zpatmp)) return
    if (associated(state%f_zpltmp)) return
    if (associated(state%f_zplsmp)) return
    if (associated(state%f_zlisum)) return
    if (associated(state%f_zctrso)) return
    if (associated(state%f_zcemtr)) return
    if (associated(state%f_itopc)) return
    if (associated(state%f_ibasc)) return
    if (associated(state%f_ibotsc)) return
    keep = .false.
    if (present(persistent)) keep = persistent
    if (.not. keep) blocks = 1
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(9) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(9), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(10) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(10), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(11) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(11), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(12) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(12), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(13) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(13), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(14) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(14), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(15) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(15), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(16) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(16), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(17) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(17), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(18) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(18), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(19) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(19), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(20) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(20), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(21) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(21), blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(22) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(22), blocks], 8_int32)) return
    wide_extent = 2_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(23) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(23), blocks], 8_int32)) return
    wide_extent = 2_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(24) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(24), blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    call capture_work_record_status(snapshot)
    nullify (state%f_zwnd)
    nullify (state%f_zccnl)
    nullify (state%f_zccno)
    nullify (state%f_zemit)
    nullify (state%f_ztrsod)
    nullify (state%f_zsudu)
    nullify (state%f_ztskrad)
    nullify (state%f_zrainfrac_toprfz)
    nullify (state%f_ztht)
    nullify (state%f_zsoteu)
    nullify (state%f_zsotev)
    nullify (state%f_zsobeta)
    nullify (state%f_zlcrit_aer)
    nullify (state%f_zicrit_aer)
    nullify (state%f_zre_liq)
    nullify (state%f_zre_ice)
    nullify (state%f_zccn)
    nullify (state%f_znice)
    nullify (state%f_zpatmp)
    nullify (state%f_zpltmp)
    nullify (state%f_zplsmp)
    nullify (state%f_zlisum)
    nullify (state%f_zctrso)
    nullify (state%f_zcemtr)
    nullify (state%f_itopc)
    nullify (state%f_ibasc)
    nullify (state%f_ibotsc)
    status = create_work_field(state%f_zwnd, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zccnl, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zccno, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zemit, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ztrsod, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zsudu, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ztskrad, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zrainfrac_toprfz, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ztht, [rows, extent_a(9), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zsoteu, [rows, extent_a(10), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zsotev, [rows, extent_a(11), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zsobeta, [rows, extent_a(12), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zlcrit_aer, [rows, extent_a(13), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zicrit_aer, [rows, extent_a(14), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zre_liq, [rows, extent_a(15), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zre_ice, [rows, extent_a(16), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zccn, [rows, extent_a(17), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_znice, [rows, extent_a(18), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zpatmp, [rows, extent_a(19), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zpltmp, [rows, extent_a(20), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zplsmp, [rows, extent_a(21), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zlisum, [rows, extent_a(22), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zctrso, [rows, extent_a(23), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zcemtr, [rows, extent_a(24), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_itopc, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ibasc, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_ibotsc, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    call restore_work_record_status(snapshot)
    status = 0
    return
900 cleanup_status = finalize_auxiliary_diagnostic_local_work_record(state)
    call restore_work_record_status(snapshot)
    status = 1
  end function initialize_auxiliary_diagnostic_local_work_record
  !> Associate all block views in source order; BLOCK is one-origin.
  !! Required owned fields stay live. Forty source half-level views across
  !! this module use lower bound zero. Only ZDISSGW requests positive zero.
  integer(int32) function update_auxiliary_diagnostic_local_work_views(state, block) result(status)
    type(aux_diag_local_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    type(work_record_status_snapshot) :: snapshot
    status = 2
    if (block < 1) return
    if (.not. associated(state%f_zwnd)) return
    if (.not. associated(state%f_zccnl)) return
    if (.not. associated(state%f_zccno)) return
    if (.not. associated(state%f_zemit)) return
    if (.not. associated(state%f_ztrsod)) return
    if (.not. associated(state%f_zsudu)) return
    if (.not. associated(state%f_ztskrad)) return
    if (.not. associated(state%f_zrainfrac_toprfz)) return
    if (.not. associated(state%f_ztht)) return
    if (.not. associated(state%f_zsoteu)) return
    if (.not. associated(state%f_zsotev)) return
    if (.not. associated(state%f_zsobeta)) return
    if (.not. associated(state%f_zlcrit_aer)) return
    if (.not. associated(state%f_zicrit_aer)) return
    if (.not. associated(state%f_zre_liq)) return
    if (.not. associated(state%f_zre_ice)) return
    if (.not. associated(state%f_zccn)) return
    if (.not. associated(state%f_znice)) return
    if (.not. associated(state%f_zpatmp)) return
    if (.not. associated(state%f_zpltmp)) return
    if (.not. associated(state%f_zplsmp)) return
    if (.not. associated(state%f_zlisum)) return
    if (.not. associated(state%f_zctrso)) return
    if (.not. associated(state%f_zcemtr)) return
    if (.not. associated(state%f_itopc)) return
    if (.not. associated(state%f_ibasc)) return
    if (.not. associated(state%f_ibotsc)) return
    call capture_work_record_status(snapshot)
    status = 0
    status = physics_field_view_2d(state%zwnd, state%f_zwnd, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zccnl, state%f_zccnl, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zccno, state%f_zccno, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zemit, state%f_zemit, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ztrsod, state%f_ztrsod, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zsudu, state%f_zsudu, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%ztskrad, state%f_ztskrad, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zrainfrac_toprfz, state%f_zrainfrac_toprfz, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%ztht, state%f_ztht, block)
    if (status /= 0) goto 900
    state%ztht(1:, 0:) => state%ztht
    status = physics_field_view_3d(state%zsoteu, state%f_zsoteu, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zsotev, state%f_zsotev, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zsobeta, state%f_zsobeta, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zlcrit_aer, state%f_zlcrit_aer, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zicrit_aer, state%f_zicrit_aer, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zre_liq, state%f_zre_liq, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zre_ice, state%f_zre_ice, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zccn, state%f_zccn, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%znice, state%f_znice, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zpatmp, state%f_zpatmp, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zpltmp, state%f_zpltmp, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zplsmp, state%f_zplsmp, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zlisum, state%f_zlisum, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zctrso, state%f_zctrso, block)
    if (status /= 0) goto 900
    state%zctrso(1:, 0:) => state%zctrso
    status = physics_field_view_3d(state%zcemtr, state%f_zcemtr, block)
    if (status /= 0) goto 900
    state%zcemtr(1:, 0:) => state%zcemtr
    status = integer_work_field_view_2d(state%itopc, state%f_itopc, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%ibasc, state%f_ibasc, block)
    if (status /= 0) goto 900
    status = integer_work_field_view_2d(state%ibotsc, state%f_ibotsc, block)
    if (status /= 0) goto 900
900 call restore_work_record_status(snapshot)
  end function update_auxiliary_diagnostic_local_work_views
  !> Release only owned fields in the source finalization order.
  !! Public views and source-unwritten members stay unchanged, including after
  !! a partly completed initialization. Borrowed storage is never released.
  integer(int32) function finalize_auxiliary_diagnostic_local_work_record(state) result(status)
    type(aux_diag_local_type), intent(inout) :: state
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    call delete_work_field(state%f_zwnd)
    call delete_work_field(state%f_zccnl)
    call delete_work_field(state%f_zccno)
    call delete_work_field(state%f_zemit)
    call delete_work_field(state%f_ztrsod)
    call delete_work_field(state%f_zsudu)
    call delete_work_field(state%f_ztskrad)
    call delete_work_field(state%f_zrainfrac_toprfz)
    call delete_work_field(state%f_ztht)
    call delete_work_field(state%f_zsoteu)
    call delete_work_field(state%f_zsotev)
    call delete_work_field(state%f_zsobeta)
    call delete_work_field(state%f_zlcrit_aer)
    call delete_work_field(state%f_zicrit_aer)
    call delete_work_field(state%f_zre_liq)
    call delete_work_field(state%f_zre_ice)
    call delete_work_field(state%f_zccn)
    call delete_work_field(state%f_znice)
    call delete_work_field(state%f_zpatmp)
    call delete_work_field(state%f_zpltmp)
    call delete_work_field(state%f_zplsmp)
    call delete_work_field(state%f_zlisum)
    call delete_work_field(state%f_zctrso)
    call delete_work_field(state%f_zcemtr)
    call delete_work_field(state%f_itopc)
    call delete_work_field(state%f_ibasc)
    call delete_work_field(state%f_ibotsc)
    call restore_work_record_status(snapshot)
    status = 0
  end function finalize_auxiliary_diagnostic_local_work_record
  !> Preserve the original method counter and constructor abort boundary.
  subroutine aux_diag_local_type_init(state, geometry, nlev, persistent)
    type(aux_diag_local_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    integer(int32), intent(in) :: nlev
    logical, optional, intent(in) :: persistent
    integer(int32) :: status
    call increment_work_word(native_call_counts(10))
    status = initialize_auxiliary_diagnostic_local_work_record(state, geometry, nlev, persistent)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine aux_diag_local_type_update_view(state, block)
    type(aux_diag_local_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    integer(int32) :: status
    call increment_work_word(native_call_counts(11))
    status = update_auxiliary_diagnostic_local_work_views(state, block)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine aux_diag_local_type_final(state)
    type(aux_diag_local_type), intent(inout) :: state
    integer(int32) :: status
    call increment_work_word(native_call_counts(12))
    status = finalize_auxiliary_diagnostic_local_work_record(state)
  end subroutine
  !> Own 20 fields in source order. STATE must have no live owned heads.
  !! GEOMETRY and counts stay readonly. PERSISTENT defaults false; true keeps
  !! actual grid blocks. New values and incoming public views remain unchanged.
  !! Status0 succeeds,1 cleans a failed allocation prefix,2 refuses unsupported
  !! native metadata before ownership changes. No original method is called.
  integer(int32) function initialize_surface_local_work_record(state, geometry, settings, persistent) result(status)
    type(surf_and_more_local_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    integer(int32), intent(in) :: settings(:)
    logical, optional, intent(in) :: persistent
    logical :: keep
    integer(int32) :: rows, blocks, cleanup_status
    integer(int32) :: extent_a(20), extent_b(20)
    integer(int64) :: wide_extent
    type(work_record_status_snapshot) :: snapshot
    status = 2
    rows = geometry%dimensions%nproma
    blocks = geometry%partition%ngpblks
    if (rows < 1 .or. blocks < 1) return
    if (size(settings) /= 4) return
    if (.not. is_contiguous(settings)) return
    if (any(settings < 0)) return
    if (associated(state%f_zlaili)) return
    if (associated(state%f_zlaihi)) return
    if (associated(state%f_zsnm1m)) return
    if (associated(state%f_zrsnm1m)) return
    if (associated(state%f_zwlm1m)) return
    if (associated(state%f_zhsdfor)) return
    if (associated(state%f_zwlmx)) return
    if (associated(state%f_zspectralemiss)) return
    if (associated(state%f_zevapsnw)) return
    if (associated(state%f_zthkice)) return
    if (associated(state%f_zsntice)) return
    if (associated(state%f_zfrti)) return
    if (associated(state%f_zalbti)) return
    if (associated(state%f_zfrsoti)) return
    if (associated(state%f_zahftrti)) return
    if (associated(state%f_zalbd)) return
    if (associated(state%f_zalbp)) return
    if (associated(state%f_zandayvt)) return
    if (associated(state%f_zanfmvt)) return
    if (associated(state%f_zdhvegs)) return
    keep = .false.
    if (present(persistent)) keep = persistent
    if (.not. keep) blocks = 1
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(3) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(3), blocks], 8_int32)) return
    wide_extent = int(settings(1), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(4) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(4), blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    wide_extent = int(settings(4), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(8) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(8), blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    wide_extent = int(settings(2), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(12) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(12), blocks], 8_int32)) return
    wide_extent = int(settings(2), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(13) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(13), blocks], 8_int32)) return
    wide_extent = int(settings(2), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(14) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(14), blocks], 8_int32)) return
    wide_extent = int(settings(2), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(15) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(15), blocks], 8_int32)) return
    wide_extent = int(settings(3), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(16) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(16), blocks], 8_int32)) return
    wide_extent = int(settings(3), int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(17) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(17), blocks], 8_int32)) return
    wide_extent = 2_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(18) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(18), blocks], 8_int32)) return
    wide_extent = 2_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(19) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(19), blocks], 8_int32)) return
    wide_extent = 2_int64 + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(20) = int(wide_extent, int32)
    wide_extent = 7_int64 + 1_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_b(20) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(20), extent_b(20), blocks], 8_int32)) return
    call capture_work_record_status(snapshot)
    nullify (state%f_zlaili)
    nullify (state%f_zlaihi)
    nullify (state%f_zsnm1m)
    nullify (state%f_zrsnm1m)
    nullify (state%f_zwlm1m)
    nullify (state%f_zhsdfor)
    nullify (state%f_zwlmx)
    nullify (state%f_zspectralemiss)
    nullify (state%f_zevapsnw)
    nullify (state%f_zthkice)
    nullify (state%f_zsntice)
    nullify (state%f_zfrti)
    nullify (state%f_zalbti)
    nullify (state%f_zfrsoti)
    nullify (state%f_zahftrti)
    nullify (state%f_zalbd)
    nullify (state%f_zalbp)
    nullify (state%f_zandayvt)
    nullify (state%f_zanfmvt)
    nullify (state%f_zdhvegs)
    status = create_work_field(state%f_zlaili, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zlaihi, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zsnm1m, [rows, extent_a(3), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zrsnm1m, [rows, extent_a(4), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zwlm1m, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zhsdfor, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zwlmx, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zspectralemiss, [rows, extent_a(8), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zevapsnw, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zthkice, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zsntice, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zfrti, [rows, extent_a(12), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zalbti, [rows, extent_a(13), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zfrsoti, [rows, extent_a(14), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zahftrti, [rows, extent_a(15), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zalbd, [rows, extent_a(16), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zalbp, [rows, extent_a(17), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zandayvt, [rows, extent_a(18), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zanfmvt, [rows, extent_a(19), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_zdhvegs, [rows, extent_a(20), extent_b(20), blocks],.not. keep)
    if (status /= 0) goto 900
    call restore_work_record_status(snapshot)
    status = 0
    return
900 cleanup_status = finalize_surface_local_work_record(state)
    call restore_work_record_status(snapshot)
    status = 1
  end function initialize_surface_local_work_record
  !> Associate all block views in source order; BLOCK is one-origin.
  !! Required owned fields stay live. Forty source half-level views across
  !! this module use lower bound zero. Only ZDISSGW requests positive zero.
  integer(int32) function update_surface_local_work_views(state, block) result(status)
    type(surf_and_more_local_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    type(work_record_status_snapshot) :: snapshot
    status = 2
    if (block < 1) return
    if (.not. associated(state%f_zlaili)) return
    if (.not. associated(state%f_zlaihi)) return
    if (.not. associated(state%f_zsnm1m)) return
    if (.not. associated(state%f_zrsnm1m)) return
    if (.not. associated(state%f_zwlm1m)) return
    if (.not. associated(state%f_zhsdfor)) return
    if (.not. associated(state%f_zwlmx)) return
    if (.not. associated(state%f_zspectralemiss)) return
    if (.not. associated(state%f_zevapsnw)) return
    if (.not. associated(state%f_zthkice)) return
    if (.not. associated(state%f_zsntice)) return
    if (.not. associated(state%f_zfrti)) return
    if (.not. associated(state%f_zalbti)) return
    if (.not. associated(state%f_zfrsoti)) return
    if (.not. associated(state%f_zahftrti)) return
    if (.not. associated(state%f_zalbd)) return
    if (.not. associated(state%f_zalbp)) return
    if (.not. associated(state%f_zandayvt)) return
    if (.not. associated(state%f_zanfmvt)) return
    if (.not. associated(state%f_zdhvegs)) return
    call capture_work_record_status(snapshot)
    status = 0
    status = physics_field_view_2d(state%zlaili, state%f_zlaili, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zlaihi, state%f_zlaihi, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zsnm1m, state%f_zsnm1m, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zrsnm1m, state%f_zrsnm1m, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zwlm1m, state%f_zwlm1m, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zhsdfor, state%f_zhsdfor, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zwlmx, state%f_zwlmx, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zspectralemiss, state%f_zspectralemiss, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zevapsnw, state%f_zevapsnw, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zthkice, state%f_zthkice, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zsntice, state%f_zsntice, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zfrti, state%f_zfrti, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zalbti, state%f_zalbti, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zfrsoti, state%f_zfrsoti, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zahftrti, state%f_zahftrti, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zalbd, state%f_zalbd, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zalbp, state%f_zalbp, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zandayvt, state%f_zandayvt, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zanfmvt, state%f_zanfmvt, block)
    if (status /= 0) goto 900
    status = physics_field_view_4d(state%zdhvegs, state%f_zdhvegs, block)
    if (status /= 0) goto 900
900 call restore_work_record_status(snapshot)
  end function update_surface_local_work_views
  !> Release only owned fields in the source finalization order.
  !! Public views and source-unwritten members stay unchanged, including after
  !! a partly completed initialization. Borrowed storage is never released.
  integer(int32) function finalize_surface_local_work_record(state) result(status)
    type(surf_and_more_local_type), intent(inout) :: state
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    call delete_work_field(state%f_zlaili)
    call delete_work_field(state%f_zlaihi)
    call delete_work_field(state%f_zsnm1m)
    call delete_work_field(state%f_zrsnm1m)
    call delete_work_field(state%f_zwlm1m)
    call delete_work_field(state%f_zhsdfor)
    call delete_work_field(state%f_zwlmx)
    call delete_work_field(state%f_zspectralemiss)
    call delete_work_field(state%f_zevapsnw)
    call delete_work_field(state%f_zthkice)
    call delete_work_field(state%f_zsntice)
    call delete_work_field(state%f_zfrti)
    call delete_work_field(state%f_zalbti)
    call delete_work_field(state%f_zfrsoti)
    call delete_work_field(state%f_zahftrti)
    call delete_work_field(state%f_zalbd)
    call delete_work_field(state%f_zalbp)
    call delete_work_field(state%f_zandayvt)
    call delete_work_field(state%f_zanfmvt)
    call delete_additional_work_field(state%f_zdhvegs)
    call restore_work_record_status(snapshot)
    status = 0
  end function finalize_surface_local_work_record
  !> Preserve the original method counter and constructor abort boundary.
  subroutine surf_and_more_local_type_init(state, geometry, nlevsn, ntiles, ntsw, nlwemiss, persistent)
    type(surf_and_more_local_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    integer(int32), intent(in) :: nlevsn, ntiles, ntsw, nlwemiss
    logical, optional, intent(in) :: persistent
    integer(int32) :: status
    call increment_work_word(native_call_counts(13))
    status = initialize_surface_local_work_record(state, geometry, [nlevsn, ntiles, ntsw, nlwemiss], persistent)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine surf_and_more_local_type_update_view(state, block)
    type(surf_and_more_local_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    integer(int32) :: status
    call increment_work_word(native_call_counts(14))
    status = update_surface_local_work_views(state, block)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine surf_and_more_local_type_final(state)
    type(surf_and_more_local_type), intent(inout) :: state
    integer(int32) :: status
    call increment_work_word(native_call_counts(15))
    status = finalize_surface_local_work_record(state)
  end subroutine
  !> Own 9 fields in source order. STATE must have no live owned heads.
  !! GEOMETRY and counts stay readonly. PERSISTENT defaults false; true keeps
  !! actual grid blocks. New values and incoming public views remain unchanged.
  !! Status0 succeeds,1 cleans a failed allocation prefix,2 refuses unsupported
  !! native metadata before ownership changes. No original method is called.
  integer(int32) function initialize_keys_local_work_record(state, geometry, persistent) result(status)
    type(keys_local_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    logical, optional, intent(in) :: persistent
    logical :: keep
    integer(int32) :: rows, blocks, cleanup_status
    integer(int32) :: extent_a(9), extent_b(9)
    integer(int64) :: wide_extent
    type(work_record_status_snapshot) :: snapshot
    status = 2
    rows = geometry%dimensions%nproma
    blocks = geometry%partition%ngpblks
    if (rows < 1 .or. blocks < 1) return
    if (associated(state%f_llland)) return
    if (associated(state%f_llsice)) return
    if (associated(state%f_llnh)) return
    if (associated(state%f_llcum)) return
    if (associated(state%f_llsc)) return
    if (associated(state%f_llshcv)) return
    if (associated(state%f_llcum_lig)) return
    if (associated(state%f_lllake)) return
    if (associated(state%f_llocn_kpp)) return
    keep = .false.
    if (present(persistent)) keep = persistent
    if (.not. keep) blocks = 1
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    if (.not. valid_work_shape([rows, blocks], 4_int32)) return
    call capture_work_record_status(snapshot)
    nullify (state%f_llland)
    nullify (state%f_llsice)
    nullify (state%f_llnh)
    nullify (state%f_llcum)
    nullify (state%f_llsc)
    nullify (state%f_llshcv)
    nullify (state%f_llcum_lig)
    nullify (state%f_lllake)
    nullify (state%f_llocn_kpp)
    status = create_additional_work_field(state%f_llland, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_llsice, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_llnh, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_llcum, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_llsc, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_llshcv, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_llcum_lig, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_lllake, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_additional_work_field(state%f_llocn_kpp, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    call restore_work_record_status(snapshot)
    status = 0
    return
900 cleanup_status = finalize_keys_local_work_record(state)
    call restore_work_record_status(snapshot)
    status = 1
  end function initialize_keys_local_work_record
  !> Associate all block views in source order; BLOCK is one-origin.
  !! Required owned fields stay live. Forty source half-level views across
  !! this module use lower bound zero. Only ZDISSGW requests positive zero.
  integer(int32) function update_keys_local_work_views(state, block) result(status)
    type(keys_local_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    type(work_record_status_snapshot) :: snapshot
    status = 2
    if (block < 1) return
    if (.not. associated(state%f_llland)) return
    if (.not. associated(state%f_llsice)) return
    if (.not. associated(state%f_llnh)) return
    if (.not. associated(state%f_llcum)) return
    if (.not. associated(state%f_llsc)) return
    if (.not. associated(state%f_llshcv)) return
    if (.not. associated(state%f_llcum_lig)) return
    if (.not. associated(state%f_lllake)) return
    if (.not. associated(state%f_llocn_kpp)) return
    call capture_work_record_status(snapshot)
    status = 0
    status = logical_work_field_view_2d(state%llland, state%f_llland, block)
    if (status /= 0) goto 900
    status = logical_work_field_view_2d(state%llsice, state%f_llsice, block)
    if (status /= 0) goto 900
    status = logical_work_field_view_2d(state%llnh, state%f_llnh, block)
    if (status /= 0) goto 900
    status = logical_work_field_view_2d(state%llcum, state%f_llcum, block)
    if (status /= 0) goto 900
    status = logical_work_field_view_2d(state%llsc, state%f_llsc, block)
    if (status /= 0) goto 900
    status = logical_work_field_view_2d(state%llshcv, state%f_llshcv, block)
    if (status /= 0) goto 900
    status = logical_work_field_view_2d(state%llcum_lig, state%f_llcum_lig, block)
    if (status /= 0) goto 900
    status = logical_work_field_view_2d(state%lllake, state%f_lllake, block)
    if (status /= 0) goto 900
    status = logical_work_field_view_2d(state%llocn_kpp, state%f_llocn_kpp, block)
    if (status /= 0) goto 900
900 call restore_work_record_status(snapshot)
  end function update_keys_local_work_views
  !> Release only owned fields in the source finalization order.
  !! Public views and source-unwritten members stay unchanged, including after
  !! a partly completed initialization. Borrowed storage is never released.
  integer(int32) function finalize_keys_local_work_record(state) result(status)
    type(keys_local_type), intent(inout) :: state
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    call delete_additional_work_field(state%f_llland)
    call delete_additional_work_field(state%f_llsice)
    call delete_additional_work_field(state%f_llnh)
    call delete_additional_work_field(state%f_llcum)
    call delete_additional_work_field(state%f_llsc)
    call delete_additional_work_field(state%f_llshcv)
    call delete_additional_work_field(state%f_llcum_lig)
    call delete_additional_work_field(state%f_lllake)
    call delete_additional_work_field(state%f_llocn_kpp)
    call restore_work_record_status(snapshot)
    status = 0
  end function finalize_keys_local_work_record
  !> Preserve the original method counter and constructor abort boundary.
  subroutine keys_local_type_init(state, geometry, persistent)
    type(keys_local_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    logical, optional, intent(in) :: persistent
    integer(int32) :: status
    call increment_work_word(native_call_counts(16))
    status = initialize_keys_local_work_record(state, geometry, persistent)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine keys_local_type_update_view(state, block)
    type(keys_local_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    integer(int32) :: status
    call increment_work_word(native_call_counts(17))
    status = update_keys_local_work_views(state, block)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine keys_local_type_final(state)
    type(keys_local_type), intent(inout) :: state
    integer(int32) :: status
    call increment_work_word(native_call_counts(18))
    status = finalize_keys_local_work_record(state)
  end subroutine
  !> Own 4 fields in source order. STATE must have no live owned heads.
  !! GEOMETRY and counts stay readonly. PERSISTENT defaults false; true keeps
  !! actual grid blocks. New values and incoming public views remain unchanged.
  !! Status0 succeeds,1 cleans a failed allocation prefix,2 refuses unsupported
  !! native metadata before ownership changes. No original method is called.
  integer(int32) function initialize_perturbation_local_work_record(state, geometry, nlev, persistent) result(status)
    type(perturb_local_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    integer(int32), intent(in) :: nlev
    logical, optional, intent(in) :: persistent
    logical :: keep
    integer(int32) :: rows, blocks, cleanup_status
    integer(int32) :: extent_a(4), extent_b(4)
    integer(int64) :: wide_extent
    type(work_record_status_snapshot) :: snapshot
    status = 2
    rows = geometry%dimensions%nproma
    blocks = geometry%partition%ngpblks
    if (rows < 1 .or. blocks < 1) return
    if (nlev < 0) return
    if (associated(state%f_zwmean)) return
    if (associated(state%f_zdisscu)) return
    if (associated(state%f_zcuconvca)) return
    if (associated(state%f_zdissgw)) return
    keep = .false.
    if (present(persistent)) keep = persistent
    if (.not. keep) blocks = 1
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(2) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(2), blocks], 8_int32)) return
    if (.not. valid_work_shape([rows, blocks], 8_int32)) return
    wide_extent = int(nlev, int64) + 0_int64
    if (wide_extent > int(huge(0_int32), int64)) return
    extent_a(4) = int(wide_extent, int32)
    if (.not. valid_work_shape([rows, extent_a(4), blocks], 8_int32)) return
    call capture_work_record_status(snapshot)
    nullify (state%f_zwmean)
    nullify (state%f_zdisscu)
    nullify (state%f_zcuconvca)
    nullify (state%f_zdissgw)
    status = create_work_field(state%f_zwmean, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zdisscu, [rows, extent_a(2), blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zcuconvca, [rows, blocks],.not. keep)
    if (status /= 0) goto 900
    status = create_work_field(state%f_zdissgw, [rows, extent_a(4), blocks],.not. keep)
    if (status /= 0) goto 900
    call restore_work_record_status(snapshot)
    status = 0
    return
900 cleanup_status = finalize_perturbation_local_work_record(state)
    call restore_work_record_status(snapshot)
    status = 1
  end function initialize_perturbation_local_work_record
  !> Associate all block views in source order; BLOCK is one-origin.
  !! Required owned fields stay live. Forty source half-level views across
  !! this module use lower bound zero. Only ZDISSGW requests positive zero.
  integer(int32) function update_perturbation_local_work_views(state, block) result(status)
    type(perturb_local_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    type(work_record_status_snapshot) :: snapshot
    status = 2
    if (block < 1) return
    if (.not. associated(state%f_zwmean)) return
    if (.not. associated(state%f_zdisscu)) return
    if (.not. associated(state%f_zcuconvca)) return
    if (.not. associated(state%f_zdissgw)) return
    call capture_work_record_status(snapshot)
    status = 0
    status = physics_field_view_2d(state%zwmean, state%f_zwmean, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zdisscu, state%f_zdisscu, block)
    if (status /= 0) goto 900
    status = physics_field_view_2d(state%zcuconvca, state%f_zcuconvca, block)
    if (status /= 0) goto 900
    status = physics_field_view_3d(state%zdissgw, state%f_zdissgw, block)
    if (status /= 0) goto 900
    state%zdissgw = 0.0_real64
900 call restore_work_record_status(snapshot)
  end function update_perturbation_local_work_views
  !> Release only owned fields in the source finalization order.
  !! Public views and source-unwritten members stay unchanged, including after
  !! a partly completed initialization. Borrowed storage is never released.
  integer(int32) function finalize_perturbation_local_work_record(state) result(status)
    type(perturb_local_type), intent(inout) :: state
    type(work_record_status_snapshot) :: snapshot
    call capture_work_record_status(snapshot)
    call delete_work_field(state%f_zwmean)
    call delete_work_field(state%f_zdisscu)
    call delete_work_field(state%f_zcuconvca)
    call delete_work_field(state%f_zdissgw)
    call restore_work_record_status(snapshot)
    status = 0
  end function finalize_perturbation_local_work_record
  !> Preserve the original method counter and constructor abort boundary.
  subroutine perturb_local_type_init(state, geometry, nlev, persistent)
    type(perturb_local_type), intent(inout) :: state
    type(native_geometry_state), intent(in) :: geometry
    integer(int32), intent(in) :: nlev
    logical, optional, intent(in) :: persistent
    integer(int32) :: status
    call increment_work_word(native_call_counts(19))
    status = initialize_perturbation_local_work_record(state, geometry, nlev, persistent)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine perturb_local_type_update_view(state, block)
    type(perturb_local_type), intent(inout) :: state
    integer(int32), intent(in) :: block
    integer(int32) :: status
    call increment_work_word(native_call_counts(20))
    status = update_perturbation_local_work_views(state, block)
    if (status /= 0) call abort_storage_failure()
  end subroutine
  subroutine perturb_local_type_final(state)
    type(perturb_local_type), intent(inout) :: state
    integer(int32) :: status
    call increment_work_word(native_call_counts(21))
    status = finalize_perturbation_local_work_record(state)
  end subroutine
  !> Return one original-method word; INDEX0:20 follows the seven type order.
  integer(int64) function additional_work_record_call_count_get(index) result(count)
    integer(int32), intent(in) :: index
    count = 0_int64
    if (index >= 0 .and. index < 21) count = native_call_counts(index + 1)
  end function
end module forecast_additional_physics_work_records

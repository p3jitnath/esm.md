! (C) Copyright 1989- ECMWF and Meteo-France.
! Licensed under the Apache Licence Version 2.0.
!> Own the source three-dimensional monthly CAMS aerosol climatology.
!! The canonical record owns thirteen monthly pointer targets and thirteen
!! interpolation arrays. The caller must not copy or alias these live owners.
!! Monthly axes are longitude120,latitude61,level60,month12.
!! Layer-integrated aerosol mass uses kg/m**2; pressure and thickness use Pa.
module native_owned_cams_actual_climatology_setup
  use iso_c_binding, only: c_int, c_double, c_char, c_size_t, c_ptr, c_loc, c_null_char
  use iso_fortran_env, only: int64
  use owned_aerosol_climatology_records, only: teaerc_macc
  use native_owned_cams_climatology_setup, only: initialize_cams_climatology, release_cams_climatology
  implicit none
  private
  public :: initialize_cams_climatology_actual, initialize_cams_climatology_3d, release_cams_climatology_actual
  integer(c_size_t), parameter :: expected_file_shape(4) = [12_c_size_t, 60_c_size_t, 61_c_size_t, 120_c_size_t]
  integer(int64), parameter :: required_3d_bytes = 13_int64*120_int64*61_int64*60_int64*13_int64*8_int64
  character(kind=c_char, len=32), parameter :: variable_names(13) = [character(kind=c_char, len=32) :: &
                                                                     'Black_Carbon_hydrophilic'//c_null_char, &
                                                                     'Black_Carbon_hydrophobic'//c_null_char, &
                                                                     'Organic_Matter_hydrophilic'//c_null_char, &
                                                                     'Organic_Matter_hydrophobic'//c_null_char, &
                                                                     'Mineral_Dust_bin1'//c_null_char, &
                                                                     'Mineral_Dust_bin2'//c_null_char, &
                                                                     'Mineral_Dust_bin3'//c_null_char, &
                                                                     'Sea_Salt_bin1'//c_null_char, &
                                                                     'Sea_Salt_bin2'//c_null_char, &
                                                                     'Sea_Salt_bin3'//c_null_char, &
                                                                     'Sulfates'//c_null_char, &
                                                                     'half_level_pressure'//c_null_char, &
                                                                     'half_level_delta_pressure'//c_null_char]
  interface
    integer(c_int) function nc_open(path, mode, file_id) bind(C, name="nc_open")
      import c_char, c_int
      character(kind=c_char), intent(in) :: path(*)
      integer(c_int), value :: mode
      integer(c_int), intent(out) :: file_id
    end function
    integer(c_int) function nc_inq_varid(file_id, name, variable_id) bind(C, name="nc_inq_varid")
      import c_char, c_int
      integer(c_int), value :: file_id
      character(kind=c_char), intent(in) :: name(*)
      integer(c_int), intent(out) :: variable_id
    end function
    integer(c_int) function nc_inq_varndims(file_id, variable_id, rank) bind(C, name="nc_inq_varndims")
      import c_int
      integer(c_int), value :: file_id, variable_id
      integer(c_int), intent(out) :: rank
    end function
    integer(c_int) function nc_inq_vardimid(file_id, variable_id, dimension_ids) bind(C, name="nc_inq_vardimid")
      import c_int
      integer(c_int), value :: file_id, variable_id
      integer(c_int), intent(out) :: dimension_ids(*)
    end function
    integer(c_int) function nc_inq_dimlen(file_id, dimension_id, extent) bind(C, name="nc_inq_dimlen")
      import c_int, c_size_t
      integer(c_int), value :: file_id, dimension_id
      integer(c_size_t), intent(out) :: extent
    end function
    integer(c_int) function nc_get_var_double(file_id, variable_id, values) bind(C, name="nc_get_var_double")
      import c_int, c_ptr
      integer(c_int), value :: file_id, variable_id
      type(c_ptr), value :: values
    end function
    integer(c_int) function nc_close(file_id) bind(C, name="nc_close")
      import c_int
      integer(c_int), value :: file_id
    end function
  end interface
contains
  !> Load the source two-dimensional file, then the optional three-dimensional file.
  !! Paths are explicit readonly file names. BYTE_QUOTA bounds new3D payload bytes.
  !! RECORD is the one fresh canonical owner. Return0 succeeds,1 reports resource
  !! failure and2 refuses unsupported metadata. Failed private3D loads are released.
  integer(c_int) function initialize_cams_climatology_actual(path2d, path3d, record, three_dimensional, byte_quota) result(status)
    character(len=*), intent(in) :: path2d, path3d
    type(teaerc_macc), intent(inout) :: record
    logical, intent(in) :: three_dimensional
    integer(int64), intent(in) :: byte_quota
    integer(c_int) :: cleanup
    status = 2_c_int
    if (.not. fresh_three_dimensional_views(record)) return
    if (three_dimensional .and. byte_quota < required_3d_bytes) return
    status = initialize_cams_climatology(path2d, record)
    if (status /= 0_c_int) return
    if (three_dimensional) then
      record%is_initialised = .false.
      status = initialize_cams_climatology_3d(path3d, record, byte_quota)
      if (status /= 0_c_int) then
        record%is_initialised = .true.
        cleanup = release_cams_climatology_actual(record)
        return
      end if
    end if
    record%is_initialised = .true.
    status = 0_c_int
  end function

  !> Read thirteen rank4 NetCDF fields, then initialise the source work arrays.
  !! File dimensions must be month12,level60,latitude61,longitude120 in C order.
  !! The equivalent native Fortran shape is (120,61,60,12). Every work shape is
  !! (120,61,60). All3D heads must be absent; existing2D arrays stay unchanged.
  integer(c_int) function initialize_cams_climatology_3d(path, record, byte_quota) result(status)
    character(len=*), intent(in) :: path
    type(teaerc_macc), intent(inout) :: record
    integer(int64), intent(in) :: byte_quota
    type(teaerc_macc) :: pending
    character(kind=c_char) :: c_path(4096)
    integer(c_int) :: file_id, ids(13), rank, dimids(4), api, closed
    integer(c_size_t) :: extent
    integer :: i, j, k, v, dim, allocation_status
    status = 2_c_int
    if (len(path) < 1 .or. len(path) > 4095 .or. byte_quota < required_3d_bytes) return
    if (.not. fresh_three_dimensional_views(record)) return
    do i = 1, len(path)
      if (iachar(path(i:i)) == 0) return
      c_path(i) = path(i:i)
    end do
    c_path(len(path) + 1) = c_null_char
    file_id = -1_c_int
    status = 1_c_int
    load: block
      api = nc_open(c_path, 0_c_int, file_id)
      if (api /= 0_c_int) exit load
      do v = 1, 13
        api = nc_inq_varid(file_id, variable_names(v), ids(v))
        if (api /= 0_c_int) exit load
        api = nc_inq_varndims(file_id, ids(v), rank)
        if (api /= 0_c_int) exit load
        if (rank /= 4_c_int) then
          status = 2_c_int
          exit load
        end if
        api = nc_inq_vardimid(file_id, ids(v), dimids)
        if (api /= 0_c_int) exit load
        do dim = 1, 4
          api = nc_inq_dimlen(file_id, dimids(dim), extent)
          if (api /= 0_c_int) exit load
          if (extent /= expected_file_shape(dim)) then
            status = 2_c_int
            exit load
          end if
        end do
      end do
      allocate (pending%rmacbc13d(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(1), c_loc(pending%rmacbc13d))
      if (api /= 0_c_int) exit load
      allocate (pending%rmacbc23d(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(2), c_loc(pending%rmacbc23d))
      if (api /= 0_c_int) exit load
      allocate (pending%rmacor13d(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(3), c_loc(pending%rmacor13d))
      if (api /= 0_c_int) exit load
      allocate (pending%rmacor23d(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(4), c_loc(pending%rmacor23d))
      if (api /= 0_c_int) exit load
      allocate (pending%rmacsd13d(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(5), c_loc(pending%rmacsd13d))
      if (api /= 0_c_int) exit load
      allocate (pending%rmacsd23d(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(6), c_loc(pending%rmacsd23d))
      if (api /= 0_c_int) exit load
      allocate (pending%rmacsd33d(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(7), c_loc(pending%rmacsd33d))
      if (api /= 0_c_int) exit load
      allocate (pending%rmacss13d(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(8), c_loc(pending%rmacss13d))
      if (api /= 0_c_int) exit load
      allocate (pending%rmacss23d(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(9), c_loc(pending%rmacss23d))
      if (api /= 0_c_int) exit load
      allocate (pending%rmacss33d(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(10), c_loc(pending%rmacss33d))
      if (api /= 0_c_int) exit load
      allocate (pending%rmacsu13d(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(11), c_loc(pending%rmacsu13d))
      if (api /= 0_c_int) exit load
      allocate (pending%ref_mon_aer_prs(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(12), c_loc(pending%ref_mon_aer_prs))
      if (api /= 0_c_int) exit load
      allocate (pending%ref_mon_aer_dprs(120, 61, 60, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api = nc_get_var_double(file_id, ids(13), c_loc(pending%ref_mon_aer_dprs))
      if (api /= 0_c_int) exit load
      api = nc_close(file_id); file_id = -1_c_int
      if (api /= 0_c_int) exit load
      allocate (pending%rmaebc13d(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%rmaebc23d(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%rmaeor13d(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%rmaeor23d(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%rmaesd13d(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%rmaesd23d(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%rmaesd33d(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%rmaess13d(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%rmaess23d(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%rmaess33d(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%rmaesu13d(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%ref_aer_prs(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending%ref_aer_dprs(120, 61, 60), stat=allocation_status)
      if (allocation_status /= 0) exit load
      do k = 1, 60
        do j = 1, 61
          do i = 1, 120
            pending%rmaebc13d(i, j, k) = 0.0_c_double
            pending%rmaebc23d(i, j, k) = 0.0_c_double
            pending%rmaeor13d(i, j, k) = 0.0_c_double
            pending%rmaeor23d(i, j, k) = 0.0_c_double
            pending%rmaesd13d(i, j, k) = 0.0_c_double
            pending%rmaesd23d(i, j, k) = 0.0_c_double
            pending%rmaesd33d(i, j, k) = 0.0_c_double
            pending%rmaess13d(i, j, k) = 0.0_c_double
            pending%rmaess23d(i, j, k) = 0.0_c_double
            pending%rmaess33d(i, j, k) = 0.0_c_double
            pending%rmaesu13d(i, j, k) = 0.0_c_double
            pending%ref_aer_prs(i, j, k) = 0.0_c_double
            pending%ref_aer_dprs(i, j, k) = 0.0_c_double
          end do
        end do
      end do
      record%rmacbc13d => pending%rmacbc13d
      nullify (pending%rmacbc13d)
      record%rmacbc23d => pending%rmacbc23d
      nullify (pending%rmacbc23d)
      record%rmacor13d => pending%rmacor13d
      nullify (pending%rmacor13d)
      record%rmacor23d => pending%rmacor23d
      nullify (pending%rmacor23d)
      record%rmacsd13d => pending%rmacsd13d
      nullify (pending%rmacsd13d)
      record%rmacsd23d => pending%rmacsd23d
      nullify (pending%rmacsd23d)
      record%rmacsd33d => pending%rmacsd33d
      nullify (pending%rmacsd33d)
      record%rmacss13d => pending%rmacss13d
      nullify (pending%rmacss13d)
      record%rmacss23d => pending%rmacss23d
      nullify (pending%rmacss23d)
      record%rmacss33d => pending%rmacss33d
      nullify (pending%rmacss33d)
      record%rmacsu13d => pending%rmacsu13d
      nullify (pending%rmacsu13d)
      record%ref_mon_aer_prs => pending%ref_mon_aer_prs
      nullify (pending%ref_mon_aer_prs)
      record%ref_mon_aer_dprs => pending%ref_mon_aer_dprs
      nullify (pending%ref_mon_aer_dprs)
      call move_alloc(pending%rmaebc13d, record%rmaebc13d)
      call move_alloc(pending%rmaebc23d, record%rmaebc23d)
      call move_alloc(pending%rmaeor13d, record%rmaeor13d)
      call move_alloc(pending%rmaeor23d, record%rmaeor23d)
      call move_alloc(pending%rmaesd13d, record%rmaesd13d)
      call move_alloc(pending%rmaesd23d, record%rmaesd23d)
      call move_alloc(pending%rmaesd33d, record%rmaesd33d)
      call move_alloc(pending%rmaess13d, record%rmaess13d)
      call move_alloc(pending%rmaess23d, record%rmaess23d)
      call move_alloc(pending%rmaess33d, record%rmaess33d)
      call move_alloc(pending%rmaesu13d, record%rmaesu13d)
      call move_alloc(pending%ref_aer_prs, record%ref_aer_prs)
      call move_alloc(pending%ref_aer_dprs, record%ref_aer_dprs)
      status = 0_c_int
    end block load
    if (file_id >= 0_c_int) closed = nc_close(file_id)
    call free_three_dimensional_payload(pending)
  end function

  logical function fresh_three_dimensional_views(record) result(fresh)
    type(teaerc_macc), intent(in) :: record
    fresh = .false.
    if (associated(record%rmacbc13d)) return
    if (associated(record%rmacbc23d)) return
    if (associated(record%rmacor13d)) return
    if (associated(record%rmacor23d)) return
    if (associated(record%rmacsd13d)) return
    if (associated(record%rmacsd23d)) return
    if (associated(record%rmacsd33d)) return
    if (associated(record%rmacss13d)) return
    if (associated(record%rmacss23d)) return
    if (associated(record%rmacss33d)) return
    if (associated(record%rmacsu13d)) return
    if (associated(record%ref_mon_aer_prs)) return
    if (associated(record%ref_mon_aer_dprs)) return
    if (allocated(record%rmaebc13d)) return
    if (allocated(record%rmaebc23d)) return
    if (allocated(record%rmaeor13d)) return
    if (allocated(record%rmaeor23d)) return
    if (allocated(record%rmaesd13d)) return
    if (allocated(record%rmaesd23d)) return
    if (allocated(record%rmaesd33d)) return
    if (allocated(record%rmaess13d)) return
    if (allocated(record%rmaess23d)) return
    if (allocated(record%rmaess33d)) return
    if (allocated(record%rmaesu13d)) return
    if (allocated(record%ref_aer_prs)) return
    if (allocated(record%ref_aer_dprs)) return
    fresh = .true.
  end function

  !> Release only payloads acquired by this single canonical CAMS owner.
  integer(c_int) function release_cams_climatology_actual(record) result(status)
    type(teaerc_macc), intent(inout) :: record
    call free_three_dimensional_payload(record)
    status = release_cams_climatology(record)
  end function

  subroutine free_three_dimensional_payload(record)
    type(teaerc_macc), intent(inout) :: record
    if (associated(record%rmacbc13d)) deallocate (record%rmacbc13d)
    nullify (record%rmacbc13d)
    if (associated(record%rmacbc23d)) deallocate (record%rmacbc23d)
    nullify (record%rmacbc23d)
    if (associated(record%rmacor13d)) deallocate (record%rmacor13d)
    nullify (record%rmacor13d)
    if (associated(record%rmacor23d)) deallocate (record%rmacor23d)
    nullify (record%rmacor23d)
    if (associated(record%rmacsd13d)) deallocate (record%rmacsd13d)
    nullify (record%rmacsd13d)
    if (associated(record%rmacsd23d)) deallocate (record%rmacsd23d)
    nullify (record%rmacsd23d)
    if (associated(record%rmacsd33d)) deallocate (record%rmacsd33d)
    nullify (record%rmacsd33d)
    if (associated(record%rmacss13d)) deallocate (record%rmacss13d)
    nullify (record%rmacss13d)
    if (associated(record%rmacss23d)) deallocate (record%rmacss23d)
    nullify (record%rmacss23d)
    if (associated(record%rmacss33d)) deallocate (record%rmacss33d)
    nullify (record%rmacss33d)
    if (associated(record%rmacsu13d)) deallocate (record%rmacsu13d)
    nullify (record%rmacsu13d)
    if (associated(record%ref_mon_aer_prs)) deallocate (record%ref_mon_aer_prs)
    nullify (record%ref_mon_aer_prs)
    if (associated(record%ref_mon_aer_dprs)) deallocate (record%ref_mon_aer_dprs)
    nullify (record%ref_mon_aer_dprs)
    if (allocated(record%rmaebc13d)) deallocate (record%rmaebc13d)
    if (allocated(record%rmaebc23d)) deallocate (record%rmaebc23d)
    if (allocated(record%rmaeor13d)) deallocate (record%rmaeor13d)
    if (allocated(record%rmaeor23d)) deallocate (record%rmaeor23d)
    if (allocated(record%rmaesd13d)) deallocate (record%rmaesd13d)
    if (allocated(record%rmaesd23d)) deallocate (record%rmaesd23d)
    if (allocated(record%rmaesd33d)) deallocate (record%rmaesd33d)
    if (allocated(record%rmaess13d)) deallocate (record%rmaess13d)
    if (allocated(record%rmaess23d)) deallocate (record%rmaess23d)
    if (allocated(record%rmaess33d)) deallocate (record%rmaess33d)
    if (allocated(record%rmaesu13d)) deallocate (record%rmaesu13d)
    if (allocated(record%ref_aer_prs)) deallocate (record%ref_aer_prs)
    if (allocated(record%ref_aer_dprs)) deallocate (record%ref_aer_dprs)
  end subroutine
end module native_owned_cams_actual_climatology_setup

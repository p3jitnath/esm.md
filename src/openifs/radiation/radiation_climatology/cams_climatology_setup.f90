!> Own the selected two-dimensional CAMS aerosol climatology through NetCDF.
!! CAMS supplies monthly aerosol column masses in kg m**(-2). Native allocatable
!! arrays own their payloads. Only selected canonical record members are changed.
module native_cams_climatology_setup
  use iso_c_binding, only: c_int, c_double, c_char, c_size_t, c_ptr, c_loc, c_null_char
  use yoeaerc, only: teaerc_macc
  implicit none
  private
  public :: initialize_cams_climatology, release_cams_climatology
  integer(c_size_t), parameter :: expected_file_shape(3) = [12_c_size_t, 61_c_size_t, 120_c_size_t]
  character(kind=c_char, len=27), parameter :: variable_names(11) = [character(kind=c_char, len=27) :: &
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
                                                                     'Sulfates'//c_null_char]
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
  !> Load eleven monthly fields and reserve eleven interpolation work arrays.
  !! path is an explicit nonempty filename of at most 4095 characters, with no
  !! embedded zero. Its complete declared length is used, including any spaces.
  !! record is the canonical TEAERC_MACC owner with intent(inout). All selected
  !! arrays must be unallocated and IS_INITIALISED false on entry. Other members
  !! remain unchanged. Monthly shapes are (120,61,12), work shapes are (120,61).
  !! Monthly values have units kg m**(-2); work payloads remain unwritten.
  !! Return 0 completes, 1 reports an allocation or NetCDF API failure, and
  !! 2 refuses an input condition, rank or ordered file shape before publication.
  integer(c_int) function initialize_cams_climatology(path, record) result(status)
    character(len=*), intent(in) :: path
    type(teaerc_macc), intent(inout) :: record
    real(c_double), allocatable, target :: pending_rmacbc1(:, :, :)
    real(c_double), allocatable, target :: pending_rmacbc2(:, :, :)
    real(c_double), allocatable, target :: pending_rmacor1(:, :, :)
    real(c_double), allocatable, target :: pending_rmacor2(:, :, :)
    real(c_double), allocatable, target :: pending_rmacsd1(:, :, :)
    real(c_double), allocatable, target :: pending_rmacsd2(:, :, :)
    real(c_double), allocatable, target :: pending_rmacsd3(:, :, :)
    real(c_double), allocatable, target :: pending_rmacss1(:, :, :)
    real(c_double), allocatable, target :: pending_rmacss2(:, :, :)
    real(c_double), allocatable, target :: pending_rmacss3(:, :, :)
    real(c_double), allocatable, target :: pending_rmacsu1(:, :, :)
    real(c_double), allocatable :: pending_rmaebc1(:, :)
    real(c_double), allocatable :: pending_rmaebc2(:, :)
    real(c_double), allocatable :: pending_rmaeor1(:, :)
    real(c_double), allocatable :: pending_rmaeor2(:, :)
    real(c_double), allocatable :: pending_rmaesd1(:, :)
    real(c_double), allocatable :: pending_rmaesd2(:, :)
    real(c_double), allocatable :: pending_rmaesd3(:, :)
    real(c_double), allocatable :: pending_rmaess1(:, :)
    real(c_double), allocatable :: pending_rmaess2(:, :)
    real(c_double), allocatable :: pending_rmaess3(:, :)
    real(c_double), allocatable :: pending_rmaesu1(:, :)
    character(kind=c_char) :: c_path(4096)
    integer(c_int) :: file_id, opened_id, variable_ids(11), rank, dimension_ids(3), api_status
    integer(c_size_t) :: extent
    integer :: index, variable, dimension, allocation_status
    status = 2_c_int
    if (len(path) < 1 .or. len(path) > 4095) return
    do index = 1, len(path)
      if (iachar(path(index:index)) == 0) return
      c_path(index) = path(index:index)
    end do
    c_path(len(path) + 1) = c_null_char
    if (record%is_initialised) return
    if (allocated(record%rmacbc1)) return
    if (allocated(record%rmacbc2)) return
    if (allocated(record%rmacor1)) return
    if (allocated(record%rmacor2)) return
    if (allocated(record%rmacsd1)) return
    if (allocated(record%rmacsd2)) return
    if (allocated(record%rmacsd3)) return
    if (allocated(record%rmacss1)) return
    if (allocated(record%rmacss2)) return
    if (allocated(record%rmacss3)) return
    if (allocated(record%rmacsu1)) return
    if (allocated(record%rmaebc1)) return
    if (allocated(record%rmaebc2)) return
    if (allocated(record%rmaeor1)) return
    if (allocated(record%rmaeor2)) return
    if (allocated(record%rmaesd1)) return
    if (allocated(record%rmaesd2)) return
    if (allocated(record%rmaesd3)) return
    if (allocated(record%rmaess1)) return
    if (allocated(record%rmaess2)) return
    if (allocated(record%rmaess3)) return
    if (allocated(record%rmaesu1)) return
    file_id = -1_c_int
    opened_id = -1_c_int
    status = 1_c_int
    load: block
      api_status = nc_open(c_path, 0_c_int, opened_id)
      if (api_status /= 0_c_int) exit load
      file_id = opened_id
      ! Qualify every variable and every ordered extent before allocation.
      do variable = 1, 11
        api_status = nc_inq_varid(file_id, variable_names(variable), variable_ids(variable))
        if (api_status /= 0_c_int) exit load
        api_status = nc_inq_varndims(file_id, variable_ids(variable), rank)
        if (api_status /= 0_c_int) exit load
        if (rank /= 3_c_int) then
          status = 2_c_int
          exit load
        end if
        api_status = nc_inq_vardimid(file_id, variable_ids(variable), dimension_ids)
        if (api_status /= 0_c_int) exit load
        do dimension = 1, 3
          api_status = nc_inq_dimlen(file_id, dimension_ids(dimension), extent)
          if (api_status /= 0_c_int) exit load
          if (extent /= expected_file_shape(dimension)) then
            status = 2_c_int
            exit load
          end if
        end do
      end do
      allocate (pending_rmacbc1(120, 61, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api_status = nc_get_var_double(file_id, variable_ids(1), c_loc(pending_rmacbc1))
      if (api_status /= 0_c_int) exit load
      allocate (pending_rmacbc2(120, 61, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api_status = nc_get_var_double(file_id, variable_ids(2), c_loc(pending_rmacbc2))
      if (api_status /= 0_c_int) exit load
      allocate (pending_rmacor1(120, 61, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api_status = nc_get_var_double(file_id, variable_ids(3), c_loc(pending_rmacor1))
      if (api_status /= 0_c_int) exit load
      allocate (pending_rmacor2(120, 61, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api_status = nc_get_var_double(file_id, variable_ids(4), c_loc(pending_rmacor2))
      if (api_status /= 0_c_int) exit load
      allocate (pending_rmacsd1(120, 61, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api_status = nc_get_var_double(file_id, variable_ids(5), c_loc(pending_rmacsd1))
      if (api_status /= 0_c_int) exit load
      allocate (pending_rmacsd2(120, 61, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api_status = nc_get_var_double(file_id, variable_ids(6), c_loc(pending_rmacsd2))
      if (api_status /= 0_c_int) exit load
      allocate (pending_rmacsd3(120, 61, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api_status = nc_get_var_double(file_id, variable_ids(7), c_loc(pending_rmacsd3))
      if (api_status /= 0_c_int) exit load
      allocate (pending_rmacss1(120, 61, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api_status = nc_get_var_double(file_id, variable_ids(8), c_loc(pending_rmacss1))
      if (api_status /= 0_c_int) exit load
      allocate (pending_rmacss2(120, 61, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api_status = nc_get_var_double(file_id, variable_ids(9), c_loc(pending_rmacss2))
      if (api_status /= 0_c_int) exit load
      allocate (pending_rmacss3(120, 61, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api_status = nc_get_var_double(file_id, variable_ids(10), c_loc(pending_rmacss3))
      if (api_status /= 0_c_int) exit load
      allocate (pending_rmacsu1(120, 61, 12), stat=allocation_status)
      if (allocation_status /= 0) exit load
      api_status = nc_get_var_double(file_id, variable_ids(11), c_loc(pending_rmacsu1))
      if (api_status /= 0_c_int) exit load
      ! The original selected data stage closes before work allocation.
      api_status = nc_close(file_id)
      file_id = -1_c_int
      if (api_status /= 0_c_int) exit load
      allocate (pending_rmaebc1(120, 61), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending_rmaebc2(120, 61), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending_rmaeor1(120, 61), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending_rmaeor2(120, 61), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending_rmaesd1(120, 61), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending_rmaesd2(120, 61), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending_rmaesd3(120, 61), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending_rmaess1(120, 61), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending_rmaess2(120, 61), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending_rmaess3(120, 61), stat=allocation_status)
      if (allocation_status /= 0) exit load
      allocate (pending_rmaesu1(120, 61), stat=allocation_status)
      if (allocation_status /= 0) exit load
      ! Transfer only selected owners after every operation has succeeded.
      call move_alloc(pending_rmacbc1, record%rmacbc1)
      call move_alloc(pending_rmacbc2, record%rmacbc2)
      call move_alloc(pending_rmacor1, record%rmacor1)
      call move_alloc(pending_rmacor2, record%rmacor2)
      call move_alloc(pending_rmacsd1, record%rmacsd1)
      call move_alloc(pending_rmacsd2, record%rmacsd2)
      call move_alloc(pending_rmacsd3, record%rmacsd3)
      call move_alloc(pending_rmacss1, record%rmacss1)
      call move_alloc(pending_rmacss2, record%rmacss2)
      call move_alloc(pending_rmacss3, record%rmacss3)
      call move_alloc(pending_rmacsu1, record%rmacsu1)
      call move_alloc(pending_rmaebc1, record%rmaebc1)
      call move_alloc(pending_rmaebc2, record%rmaebc2)
      call move_alloc(pending_rmaeor1, record%rmaeor1)
      call move_alloc(pending_rmaeor2, record%rmaeor2)
      call move_alloc(pending_rmaesd1, record%rmaesd1)
      call move_alloc(pending_rmaesd2, record%rmaesd2)
      call move_alloc(pending_rmaesd3, record%rmaesd3)
      call move_alloc(pending_rmaess1, record%rmaess1)
      call move_alloc(pending_rmaess2, record%rmaess2)
      call move_alloc(pending_rmaess3, record%rmaess3)
      call move_alloc(pending_rmaesu1, record%rmaesu1)
      record%is_initialised = .true.
      status = 0_c_int
    end block load
    if (file_id >= 0_c_int) then
      api_status = nc_close(file_id)
      file_id = -1_c_int
    end if
    ! Unpublished owners are released on every failure; moved owners are absent.
    if (allocated(pending_rmacbc1)) deallocate (pending_rmacbc1)
    if (allocated(pending_rmacbc2)) deallocate (pending_rmacbc2)
    if (allocated(pending_rmacor1)) deallocate (pending_rmacor1)
    if (allocated(pending_rmacor2)) deallocate (pending_rmacor2)
    if (allocated(pending_rmacsd1)) deallocate (pending_rmacsd1)
    if (allocated(pending_rmacsd2)) deallocate (pending_rmacsd2)
    if (allocated(pending_rmacsd3)) deallocate (pending_rmacsd3)
    if (allocated(pending_rmacss1)) deallocate (pending_rmacss1)
    if (allocated(pending_rmacss2)) deallocate (pending_rmacss2)
    if (allocated(pending_rmacss3)) deallocate (pending_rmacss3)
    if (allocated(pending_rmacsu1)) deallocate (pending_rmacsu1)
    if (allocated(pending_rmaebc1)) deallocate (pending_rmaebc1)
    if (allocated(pending_rmaebc2)) deallocate (pending_rmaebc2)
    if (allocated(pending_rmaeor1)) deallocate (pending_rmaeor1)
    if (allocated(pending_rmaeor2)) deallocate (pending_rmaeor2)
    if (allocated(pending_rmaesd1)) deallocate (pending_rmaesd1)
    if (allocated(pending_rmaesd2)) deallocate (pending_rmaesd2)
    if (allocated(pending_rmaesd3)) deallocate (pending_rmaesd3)
    if (allocated(pending_rmaess1)) deallocate (pending_rmaess1)
    if (allocated(pending_rmaess2)) deallocate (pending_rmaess2)
    if (allocated(pending_rmaess3)) deallocate (pending_rmaess3)
    if (allocated(pending_rmaesu1)) deallocate (pending_rmaesu1)
  end function initialize_cams_climatology

  !> Release only the eleven monthly owners and eleven interpolation work arrays.
  !! record has intent(inout). Other canonical members retain their live values.
  !! Repeated release succeeds. Return 0 completes; 1 reports a deallocation error.
  integer(c_int) function release_cams_climatology(record) result(status)
    type(teaerc_macc), intent(inout) :: record
    integer :: allocation_status
    status = 0_c_int
    if (allocated(record%rmacbc1)) then
      deallocate (record%rmacbc1, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmacbc2)) then
      deallocate (record%rmacbc2, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmacor1)) then
      deallocate (record%rmacor1, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmacor2)) then
      deallocate (record%rmacor2, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmacsd1)) then
      deallocate (record%rmacsd1, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmacsd2)) then
      deallocate (record%rmacsd2, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmacsd3)) then
      deallocate (record%rmacsd3, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmacss1)) then
      deallocate (record%rmacss1, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmacss2)) then
      deallocate (record%rmacss2, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmacss3)) then
      deallocate (record%rmacss3, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmacsu1)) then
      deallocate (record%rmacsu1, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmaebc1)) then
      deallocate (record%rmaebc1, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmaebc2)) then
      deallocate (record%rmaebc2, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmaeor1)) then
      deallocate (record%rmaeor1, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmaeor2)) then
      deallocate (record%rmaeor2, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmaesd1)) then
      deallocate (record%rmaesd1, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmaesd2)) then
      deallocate (record%rmaesd2, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmaesd3)) then
      deallocate (record%rmaesd3, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmaess1)) then
      deallocate (record%rmaess1, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmaess2)) then
      deallocate (record%rmaess2, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmaess3)) then
      deallocate (record%rmaess3, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    if (allocated(record%rmaesu1)) then
      deallocate (record%rmaesu1, stat=allocation_status)
      if (allocation_status /= 0) status = 1_c_int
    end if
    record%is_initialised = .false.
  end function release_cams_climatology
end module native_cams_climatology_setup

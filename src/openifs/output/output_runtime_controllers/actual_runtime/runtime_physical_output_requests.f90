!> Form physical requests from the genuine field descriptors and stage controls.
module forecast_runtime_physical_output_requests
  use iso_fortran_env, only: int32, int64
  use forecast_output_request_types, only: trqfp, tfpfields
  use forecast_output_request_status
  use grid_field_configuration_types_port, only: grid_field_configuration
  use yomafn, only: tafn
  implicit none
  private
  public :: initialize_runtime_physical_request, physical_output_parameter_is_lagged, physical_output_parameter_is_ocean
  integer(int32), parameter :: lagged_parameter_codes(81) = [ &
                               164, 165, 166, 167, 168, 174096, 185, 186, 187, 188, 159, 229, &
                               230, 231, 232, 228083, 228084, 228085, 228104, 128, 243, 151, 134, 244, &
                               245, 162071, 162072, 136, 137, 78, 79, 59, 206, 228089, 228090, 228246, &
                               228247, 228239, 228240, 260048, 228219, 228218, 228221, 228220, 260015, 228217, 228029, 228088, &
                               228003, 228023, 228024, 3020, 228020, 228001, 228044, 228035, 228036, 228235, 228237, 228231, &
                               228233, 228232, 228234, 260121, 260123, 260109, 228046, 228047, 228048, 228131, 228132, 228015, &
                               228016, 228017, 228018, 228019, 260510, 260511, 207, 228249, 228241]
  integer(int32), parameter :: ocean_parameter_codes(12) = [ &
                               34, 31, 151130, 151131, 151132, 174098, 151148, 151145, 151163, 148, 151164, 151175]

contains
  !> Classify the uncoupled current field configuration with source parameter IDs.
  !! The current route has no GHG, chemistry or aerosol diagnostic families.
  !! Original GRIB-code declaration defaults are retained for this route.
  !! A changed GRIB-code namespace needs a separate explicit binding.
  !! Their actual canonical counts are checked before reading a requested code.
  integer(int32) function physical_output_parameter_is_lagged(fields, parameter, lagged) result(status)
    type(grid_field_configuration), intent(in) :: fields
    integer(int32), intent(in) :: parameter
    logical, intent(out) :: lagged
    status = 2
    lagged = .false.
    if (fields%alias_controls%nghg /= 0 .or. fields%alias_controls%nchem /= 0) return
    if (fields%settings%nactaero /= 0 .or. fields%settings%naero_wvl_diag_types /= 0) return
    lagged = any(parameter == lagged_parameter_codes)
    status = 0
  end function

  logical function physical_output_parameter_is_ocean(parameter) result(ocean)
    integer(int32), intent(in) :: parameter
    ocean = any(parameter == ocean_parameter_codes)
  end function

  !> Retain requested order, first matching descriptor and vector-pair assignment.
  !! Source arrays and AFN/GFL metadata are readonly. request owns its eight
  !! native arrays. domains is1:8; the current source has no CFU/XFU requests.
  !! lagged and ocean select the genuine call stage; ocean_delay applies the
  !! original delayed-ocean exclusion. No numerical field is calculated here.
  !! Status0 succeeds,1 reports allocation failure and2 reports unsupported
  !! metadata. A failure retains the acquired request prefix for caller cleanup.
  integer(int32) function initialize_runtime_physical_request(afn, fields, configuration, domains, &
                                                              lagged, ocean_delay, ocean, request) result(status)
    type(tafn), intent(in) :: afn
    type(tfpfields), intent(in) :: fields
    type(grid_field_configuration), intent(in) :: configuration
    integer(int32), intent(in) :: domains
    logical, intent(in) :: lagged, ocean_delay, ocean
    type(trqfp), intent(inout) :: request
    integer(int32), allocatable :: codes(:), domain_count(:), domain_index(:, :)
    integer :: n, k, j, i, u, v, count, allocation_status
    logical :: selected_lagged
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    status = 2
    if (domains < 1 .or. domains > 8) return
    if (fields%nfpphy < 0 .or. fields%nfpphy > 256 .or. fields%nfpcfu /= 0 .or. fields%nfpxfu /= 0) return
    if (.not. allocated(fields%mfpphy)) return
    if (size(fields%mfpphy) /= fields%nfpphy) return
    if (afn%mstartgfp_phy < 1 .or. afn%mendgfp_phy > size(afn%gfp_phyds)) return
    if (afn%mendgfp_phy < afn%mstartgfp_phy - 1) return
    if (allocated(request%icod) .or. allocated(request%igrib) .or. allocated(request%llsurf)) return
    if (allocated(request%clname) .or. allocated(request%clpref) .or. allocated(request%ivec)) return
    if (allocated(request%idom) .or. allocated(request%idmp)) return
    status = physical_output_parameter_is_lagged(configuration, 0_int32, selected_lagged)
    if (status /= 0) return
    call save_output_status(saved, error_slot, error_before)
    n = fields%nfpphy
    allocate (codes(n), stat=allocation_status)
    if (allocation_status /= 0) goto 700
    allocate (domain_count(n), stat=allocation_status)
    if (allocation_status /= 0) goto 700
    allocate (domain_index(domains, n), stat=allocation_status)
    if (allocation_status /= 0) goto 700
    count = 0
    do k = 1, n
      status = physical_output_parameter_is_lagged(configuration, fields%mfpphy(k), selected_lagged)
      if (status /= 0) goto 900
      if (selected_lagged .neqv. lagged) cycle
      if (ocean_delay) then
        if (physical_output_parameter_is_ocean(fields%mfpphy(k)) .neqv. ocean) cycle
      end if
      count = count + 1
      do j = afn%mstartgfp_phy, afn%mendgfp_phy
        if (fields%mfpphy(k) == afn%gfp_phyds(j)%igrib) exit
      end do
      if (j > afn%mendgfp_phy) then
        status = 2
        goto 900
      end if
      codes(count) = j
    end do
    domain_count(:count) = domains
    do j = 1, domains
      domain_index(j, :count) = j
    end do
    request%nfieldg = count
    if (count == 0) then
      status = 0
      goto 900
    end if
    allocate (request%icod(count), stat=allocation_status)
    if (allocation_status /= 0) goto 700
    allocate (request%igrib(count), stat=allocation_status)
    if (allocation_status /= 0) goto 700
    allocate (request%llsurf(count), stat=allocation_status)
    if (allocation_status /= 0) goto 700
    allocate (request%clname(count), stat=allocation_status)
    if (allocation_status /= 0) goto 700
    allocate (request%clpref(count), stat=allocation_status)
    if (allocation_status /= 0) goto 700
    allocate (request%ivec(count), stat=allocation_status)
    if (allocation_status /= 0) goto 700
    allocate (request%idom(count), stat=allocation_status)
    if (allocation_status /= 0) goto 700
    allocate (request%idmp(domains, count), stat=allocation_status)
    if (allocation_status /= 0) goto 700
    do k = 1, count
      i = codes(k)
      request%icod(k) = i
      request%clpref(k) = afn%gfp_phyds(i)%clname(1:4)
      request%clname(k) = afn%gfp_phyds(i)%clname(5:)
      request%igrib(k) = afn%gfp_phyds(i)%igrib
      request%llsurf(k) = afn%gfp_phyds(i)%llsrf
      request%ivec(k) = 0
    end do
    do v = 1, count
      i = request%icod(v)
      if (afn%gfp_phyds(i)%iordr >= 0) cycle
      do u = 1, count
        j = request%icod(u)
        if (afn%gfp_phyds(j)%iordr <= 0) cycle
        if (afn%gfp_phyds(j)%clpair /= afn%gfp_phyds(i)%clpair) cycle
        request%ivec(u) = 1
        request%ivec(v) = -u
      end do
    end do
    do k = 1, count
      request%idom(k) = domain_count(k)
    end do
    do k = 1, count
      do j = 1, domain_count(k)
        request%idmp(j, k) = domain_index(j, k)
      end do
    end do
    status = 0
    goto 900
700 status = 1
900 continue
    if (allocated(codes)) deallocate (codes)
    if (allocated(domain_count)) deallocate (domain_count)
    if (allocated(domain_index)) deallocate (domain_index)
    call restore_output_status(saved, error_slot, error_before)
  end function
end module

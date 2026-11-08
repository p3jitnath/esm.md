!> Build selected output requests from parsed metadata and live science controls.
!! Records and arrays belong to the caller. No original procedure is called.
!! Status0is success,1is allocation failure and2is unsupported admission.
module forecast_output_request_initialization
  use iso_fortran_env, only: int32, real64
  use forecast_output_request_types
  use forecast_output_request_status
  use forecast_output_request_storage, only: allocate_dynamic_3d_request, allocate_dynamic_2d_request
  implicit none
  private
  public :: initialize_output_field_requests, initialize_output_dynamic_requests
contains
  !> Allocate and fill all21field owners in declaration order.
  integer(int32) function initialize_output_field_requests(parsed, model_levels, fields) result(status)
    type(native_output_request_input), intent(in) :: parsed
    integer(int32), intent(in) :: model_levels
    type(tfpfields), intent(inout) :: fields
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: i, ierr, level_count(7), value
    status = 2
    if (model_levels < 1 .or. model_levels > 64) return
    if (any(parsed%field_count < 0) .or. any(parsed%field_count > 64)) return
    if (parsed%field_count(9) /= 0) return
    if (allocated(fields%cfp3df)) return
    if (allocated(fields%cfp2df)) return
    if (allocated(fields%cfpphy)) return
    if (allocated(fields%cfpcfu)) return
    if (allocated(fields%cfpxfu)) return
    if (allocated(fields%mfp3dfs)) return
    if (allocated(fields%mfp3dfp)) return
    if (allocated(fields%mfp3dfh)) return
    if (allocated(fields%mfp3dft)) return
    if (allocated(fields%mfp3dfv)) return
    if (allocated(fields%mfp3dfi)) return
    if (allocated(fields%mfp3dff)) return
    if (allocated(fields%mfp2df)) return
    if (allocated(fields%mfpphy)) return
    if (allocated(fields%rfp3p)) return
    if (allocated(fields%rfp3h)) return
    if (allocated(fields%rfp3th)) return
    if (allocated(fields%rfp3pv)) return
    if (allocated(fields%rfp3i)) return
    if (allocated(fields%rfp3f)) return
    if (allocated(fields%nrfp3s)) return
    call save_output_status(saved, error_slot, error_before)
    level_count = 0
    if (parsed%field_count(2) /= 0) level_count(1) = count_real_prefix(parsed%rfp3p, 0)
    if (parsed%field_count(3) /= 0) level_count(2) = count_real_prefix(parsed%rfp3h, 0)
    if (parsed%field_count(4) /= 0) level_count(3) = count_real_prefix(parsed%rfp3th, 0)
    if (parsed%field_count(5) /= 0) level_count(4) = count_real_prefix(parsed%rfp3pv, 1)
    if (parsed%field_count(6) /= 0) level_count(5) = count_real_prefix(parsed%rfp3i, 2)
    if (parsed%field_count(7) /= 0) level_count(6) = count_real_prefix(parsed%rfp3f, 0)
    if (parsed%field_count(1) /= 0) then
      if (parsed%nrfp3s(1) == -99) then
        level_count(7) = model_levels
      else
        do i = 1, 64
          value = parsed%nrfp3s(i)
          if (value < 0) exit
          if (value < 1 .or. value > model_levels) goto 900
          level_count(7) = level_count(7) + 1
        end do
      end if
    end if
    fields%nfp3p = 0
    fields%nfp3h = 0
    fields%nfp3th = 0
    fields%nfp3pv = 0
    fields%nfp3i = 0
    fields%nfp3s = 0
    fields%nfp3f = 0
    fields%nfp3dfs = 0
    fields%nfp3dfp = 0
    fields%nfp3dfh = 0
    fields%nfp3dft = 0
    fields%nfp3dfv = 0
    fields%nfp3dfi = 0
    fields%nfp3dff = 0
    fields%nfp3df = 0
    fields%nfp2df = 0
    fields%nfpphy = 0
    fields%nfpcfu = 0
    fields%nfpxfu = 0
    fields%nfp3dfs = parsed%field_count(1)
    fields%nfp3dfp = parsed%field_count(2)
    fields%nfp3dfh = parsed%field_count(3)
    fields%nfp3dft = parsed%field_count(4)
    fields%nfp3dfv = parsed%field_count(5)
    fields%nfp3dfi = parsed%field_count(6)
    fields%nfp3dff = parsed%field_count(7)
    fields%nfp2df = parsed%field_count(8)
    fields%nfp3p = level_count(1)
    fields%nfp3h = level_count(2)
    fields%nfp3th = level_count(3)
    fields%nfp3pv = level_count(4)
    fields%nfp3i = level_count(5)
    fields%nfp3f = level_count(6)
    fields%nfp3s = level_count(7)
    allocate (fields%cfp3df(fields%nfp3df), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    fields%cfp3df = ' '
    allocate (fields%cfp2df(fields%nfp2df), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    fields%cfp2df = ' '
    allocate (fields%cfpphy(fields%nfpphy), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    fields%cfpphy = ' '
    allocate (fields%cfpcfu(fields%nfpcfu), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    fields%cfpcfu = ' '
    allocate (fields%cfpxfu(fields%nfpxfu), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    fields%cfpxfu = ' '
    allocate (fields%mfp3dfs(fields%nfp3dfs), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3dfs
      fields%mfp3dfs(i) = parsed%field_code(i, 1)
    end do
    allocate (fields%mfp3dfp(fields%nfp3dfp), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3dfp
      fields%mfp3dfp(i) = parsed%field_code(i, 2)
    end do
    allocate (fields%mfp3dfh(fields%nfp3dfh), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3dfh
      fields%mfp3dfh(i) = parsed%field_code(i, 3)
    end do
    allocate (fields%mfp3dft(fields%nfp3dft), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3dft
      fields%mfp3dft(i) = parsed%field_code(i, 4)
    end do
    allocate (fields%mfp3dfv(fields%nfp3dfv), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3dfv
      fields%mfp3dfv(i) = parsed%field_code(i, 5)
    end do
    allocate (fields%mfp3dfi(fields%nfp3dfi), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3dfi
      fields%mfp3dfi(i) = parsed%field_code(i, 6)
    end do
    allocate (fields%mfp3dff(fields%nfp3dff), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3dff
      fields%mfp3dff(i) = parsed%field_code(i, 7)
    end do
    allocate (fields%mfp2df(fields%nfp2df), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp2df
      fields%mfp2df(i) = parsed%field_code(i, 8)
    end do
    allocate (fields%mfpphy(fields%nfpphy), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfpphy
      fields%mfpphy(i) = parsed%field_code(i, 9)
    end do
    allocate (fields%rfp3p(fields%nfp3p), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3p
      fields%rfp3p(i) = parsed%rfp3p(i)
    end do
    allocate (fields%rfp3h(fields%nfp3h), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3h
      fields%rfp3h(i) = parsed%rfp3h(i)
    end do
    allocate (fields%rfp3th(fields%nfp3th), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3th
      fields%rfp3th(i) = parsed%rfp3th(i)
    end do
    allocate (fields%rfp3pv(fields%nfp3pv), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3pv
      fields%rfp3pv(i) = parsed%rfp3pv(i)
    end do
    allocate (fields%rfp3i(fields%nfp3i), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3i
      fields%rfp3i(i) = parsed%rfp3i(i)
    end do
    allocate (fields%rfp3f(fields%nfp3f), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3f
      fields%rfp3f(i) = parsed%rfp3f(i)
    end do
    allocate (fields%nrfp3s(fields%nfp3s), stat=ierr)
    if (ierr /= 0) then
      status = 1
      goto 900
    end if
    do i = 1, fields%nfp3s
      if (parsed%nrfp3s(1) == -99) then
        fields%nrfp3s(i) = i
      else
        fields%nrfp3s(i) = parsed%nrfp3s(i)
      end if
    end do
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
  integer function count_real_prefix(values, mode) result(count)
    real(real64), intent(in) :: values(64)
    integer, intent(in) :: mode
    integer :: i
    count = 0
    do i = 1, 64
      select case (mode)
      case (0)
        if (values(i) < 0.0_real64) exit
      case (1)
        if (values(i) >= 100000.0_real64) exit
      case (2)
        if (values(i) < -999.0_real64) exit
      end select
      count = count + 1
    end do
  end function
  !> Join requests to the live686field table, taking the first matching source field.
  !! science_fit/filter order is pressure,theta,PV,temperature,flight,height,model.
  !! All code/flag arrays are readonly; pressure is Pa and temperature is K.
  integer(int32) function initialize_output_dynamic_requests(external_codes, surface_flags, science_fit, &
                                                             science_filter, fields, dynamic) result(status)
    integer(int32), intent(in) :: external_codes(:), science_fit(7), science_filter(7)
    logical, intent(in) :: surface_flags(:)
    type(tfpfields), target, intent(in) :: fields
    type(trqfpdyn), target, intent(inout) :: dynamic
    type(trq3fp), pointer :: request
    integer(int32), pointer :: codes(:), model_levels(:)
    real(real64), pointer :: levels(:)
    integer, parameter :: science_index(7) = [1, 6, 2, 3, 7, 4, 5]
    type(ieee_status_type) :: saved
    integer(c_int), pointer, volatile :: error_slot
    integer(c_int) :: error_before
    integer :: family, field, k, nfields, nlevels
    status = 2
    if (size(external_codes) < 686 .or. size(surface_flags) < 686) return
    if (.not. allocated(fields%mfp3dfs)) return
    if (.not. allocated(fields%mfp3dfp)) return
    if (.not. allocated(fields%mfp3dfh)) return
    if (.not. allocated(fields%mfp3dft)) return
    if (.not. allocated(fields%mfp3dfv)) return
    if (.not. allocated(fields%mfp3dfi)) return
    if (.not. allocated(fields%mfp3dff)) return
    if (.not. allocated(fields%mfp2df)) return
    if (.not. allocated(fields%mfpphy)) return
    if (.not. allocated(fields%rfp3p)) return
    if (.not. allocated(fields%rfp3h)) return
    if (.not. allocated(fields%rfp3th)) return
    if (.not. allocated(fields%rfp3pv)) return
    if (.not. allocated(fields%rfp3i)) return
    if (.not. allocated(fields%rfp3f)) return
    if (.not. allocated(fields%nrfp3s)) return
    call save_output_status(saved, error_slot, error_before)
    do family = 1, 8
      nullify (request, codes, levels, model_levels)
      select case (family)
      case (1)
        request => dynamic%ypr
        nfields = fields%nfp3dfp
        nlevels = fields%nfp3p
        codes => fields%mfp3dfp
        levels => fields%rfp3p
      case (2)
        request => dynamic%yho
        nfields = fields%nfp3dfh
        nlevels = fields%nfp3h
        codes => fields%mfp3dfh
        levels => fields%rfp3h
      case (3)
        request => dynamic%yth
        nfields = fields%nfp3dft
        nlevels = fields%nfp3th
        codes => fields%mfp3dft
        levels => fields%rfp3th
      case (4)
        request => dynamic%ypv
        nfields = fields%nfp3dfv
        nlevels = fields%nfp3pv
        codes => fields%mfp3dfv
        levels => fields%rfp3pv
      case (5)
        request => dynamic%yes
        nfields = fields%nfp3dfs
        nlevels = fields%nfp3s
        codes => fields%mfp3dfs
        model_levels => fields%nrfp3s
      case (6)
        request => dynamic%yit
        nfields = fields%nfp3dfi
        nlevels = fields%nfp3i
        codes => fields%mfp3dfi
        levels => fields%rfp3i
      case (7)
        request => dynamic%yfl
        nfields = fields%nfp3dff
        nlevels = fields%nfp3f
        codes => fields%mfp3dff
        levels => fields%rfp3f
      case (8)
        nfields = fields%nfp2df
        nlevels = 0
        codes => fields%mfp2df
      end select
      if (nfields < 0 .or. nfields > 64 .or. nlevels < 0 .or. nlevels > 64) goto 900
      if (size(codes) < nfields) goto 900
      if (family < 8) then
        if (family == 5) then
          if (size(model_levels) < nlevels) goto 900
        else
          if (size(levels) < nlevels) goto 900
        end if
        status = allocate_dynamic_3d_request(request, nfields, nlevels)
        if (status /= 0) goto 900
        request%nfit = science_fit(science_index(family))
        request%nspfil = science_filter(science_index(family))
        do k = 1, nlevels
          if (family == 5) then
            request%zpxlev(k) = real(model_levels(k), real64)
          else
            request%zpxlev(k) = levels(k)
          end if
        end do
      else
        status = allocate_dynamic_2d_request(dynamic%y2d, nfields)
        if (status /= 0) goto 900
      end if
      do field = 1, nfields
        do k = 1, 686
          if (external_codes(k) /= codes(field)) cycle
          if (family == 8) then
            if (.not. surface_flags(k)) cycle
          end if
          exit
        end do
        if (k > 686) then
          status = 2
          goto 900
        end if
        if (family < 8) then
          request%icod(field) = k
        else
          dynamic%y2d%icod(field) = k
        end if
      end do
    end do
    status = 0
900 continue
    call restore_output_status(saved, error_slot, error_before)
  end function
end module forecast_output_request_initialization

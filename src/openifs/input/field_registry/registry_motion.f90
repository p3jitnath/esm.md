!> Register motion time levels and derivatives over their live native arrays.
module forecast_registry_motion
  use iso_fortran_env, only: int32, real64
  use forecast_registry_field_types
  use forecast_registry_storage
  use forecast_native_field_variable_types
  use forecast_registry_registration, only: allocate_field_variables
  use forecast_grid_motion_types, only: native_grid_motion_state
  implicit none
contains
  !> Remove the field index while preserving every remaining array stride.
  subroutine slice_registry_field_2d(output, input, index)
    real(real64), pointer, intent(out) :: output(:, :)
    real(real64), pointer, intent(in) :: input(:, :, :)
    integer(int32), intent(in) :: index
    output => input(:, index, :)
  end subroutine
  !> Remove the field index while preserving every remaining array stride.
  subroutine slice_registry_field_3d(output, input, index)
    real(real64), pointer, intent(out) :: output(:, :, :)
    real(real64), pointer, intent(in) :: input(:, :, :, :)
    integer(int32), intent(in) :: index
    output => input(:, :, index, :)
  end subroutine
  integer(int32) function create_registry_gmv_variable_2d(output, name, main, next, indices) result(status)
    type(native_registry_variable_2d), intent(inout) :: output
    character(*), intent(in) :: name
    real(real64), pointer, intent(in) :: main(:, :, :), next(:, :, :)
    integer(int32), intent(in) :: indices(6)
    real(real64), pointer :: section(:, :)
    status = initialize_registry_variable(output, name)
    if (status /= 0) return
    output%lactive = .true.; output%ladv = .true.
    output%lt1 = indices(2) >= 0; output%lt9 = indices(3) >= 0; output%lph9 = indices(4) >= 0
    output%ldl = indices(5) >= 0; output%ldm = indices(6) >= 0
    status = 1
    call slice_registry_field_2d(section, main, indices(1))
    allocate (output%ft0, stat=status)
    if (status /= 0) then
      status = 1; return
    end if
    status = wrap_registry_field_2d(output%ft0, section)
    if (status /= 0) return
    if (indices(2) >= 0) then
      call slice_registry_field_2d(section, next, indices(2))
      allocate (output%ft1, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      status = wrap_registry_field_2d(output%ft1, section)
      if (status /= 0) return
    end if
    if (indices(3) >= 0) then
      call slice_registry_field_2d(section, main, indices(3))
      allocate (output%ft9, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      status = wrap_registry_field_2d(output%ft9, section)
      if (status /= 0) return
    end if
    if (indices(4) >= 0) then
      call slice_registry_field_2d(section, main, indices(4))
      allocate (output%fph9, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      status = wrap_registry_field_2d(output%fph9, section)
      if (status /= 0) return
    end if
    if (indices(5) >= 0) then
      call slice_registry_field_2d(section, main, indices(5))
      allocate (output%fdl, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      status = wrap_registry_field_2d(output%fdl, section)
      if (status /= 0) return
    end if
    if (indices(6) >= 0) then
      call slice_registry_field_2d(section, main, indices(6))
      allocate (output%fdm, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      status = wrap_registry_field_2d(output%fdm, section)
      if (status /= 0) return
    end if
    status = 0
  end function
  integer(int32) function create_registry_gmv_variable_3d(output, name, main, next, indices) result(status)
    type(native_registry_variable_3d), intent(inout) :: output
    character(*), intent(in) :: name
    real(real64), pointer, intent(in) :: main(:, :, :, :), next(:, :, :, :)
    integer(int32), intent(in) :: indices(6)
    real(real64), pointer :: section(:, :, :)
    status = initialize_registry_variable(output, name)
    if (status /= 0) return
    output%lactive = .true.; output%ladv = .true.
    output%lt1 = indices(2) >= 0; output%lt9 = indices(3) >= 0; output%lph9 = indices(4) >= 0
    output%ldl = indices(5) >= 0; output%ldm = indices(6) >= 0
    status = 1
    call slice_registry_field_3d(section, main, indices(1))
    allocate (output%ft0, stat=status)
    if (status /= 0) then
      status = 1; return
    end if
    status = wrap_registry_field_3d(output%ft0, section)
    if (status /= 0) return
    if (indices(2) >= 0) then
      call slice_registry_field_3d(section, next, indices(2))
      allocate (output%ft1, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      status = wrap_registry_field_3d(output%ft1, section)
      if (status /= 0) return
    end if
    if (indices(3) >= 0) then
      call slice_registry_field_3d(section, main, indices(3))
      allocate (output%ft9, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      status = wrap_registry_field_3d(output%ft9, section)
      if (status /= 0) return
    end if
    if (indices(4) >= 0) then
      call slice_registry_field_3d(section, main, indices(4))
      allocate (output%fph9, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      status = wrap_registry_field_3d(output%fph9, section)
      if (status /= 0) return
    end if
    if (indices(5) >= 0) then
      call slice_registry_field_3d(section, main, indices(5))
      allocate (output%fdl, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      status = wrap_registry_field_3d(output%fdl, section)
      if (status /= 0) return
    end if
    if (indices(6) >= 0) then
      call slice_registry_field_3d(section, main, indices(6))
      allocate (output%fdm, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      status = wrap_registry_field_3d(output%fdm, section)
      if (status /= 0) return
    end if
    status = 0
  end function
  integer(int32) function register_registry_gmv(output, motion) result(status)
    type(native_field_variables), pointer, intent(inout) :: output
    type(native_grid_motion_state), target, intent(in) :: motion
    real(real64), pointer :: main3(:, :, :), next3(:, :, :), main4(:, :, :, :), next4(:, :, :, :)
    integer(int32) :: indices(6)
    status = allocate_field_variables(output)
    if (status /= 0) return
    main4 => motion%gmv; next4 => motion%gmvt1
    main3 => motion%gmvs; next3 => motion%gmvt1s
    indices = [motion%yt0%mu, motion%yt1%mu, motion%yt9%mu, motion%yph9%mu, motion%yt0%mul, -1_int32]
    status = create_registry_gmv_variable_3d(output%u, 'U', main4, next4, indices)
    if (status /= 0) return
    indices = [motion%yt0%mv, motion%yt1%mv, motion%yt9%mv, motion%yph9%mv, motion%yt0%mvl, -1_int32]
    status = create_registry_gmv_variable_3d(output%v, 'V', main4, next4, indices)
    if (status /= 0) return
    indices = [motion%yt0%mt, motion%yt1%mt, motion%yt9%mt, motion%yph9%mt, motion%yt0%mtl, motion%yt0%mtm]
    status = create_registry_gmv_variable_3d(output%t, 'T', main4, next4, indices)
    if (status /= 0) return
    indices = [motion%yt0%mdiv, motion%yt1%mdiv, motion%yt9%mdiv, -1_int32, -1_int32, -1_int32]
    status = create_registry_gmv_variable_3d(output%div, 'DIV', main4, next4, indices)
    if (status /= 0) return
    indices = [motion%yt0%mvor, motion%yt1%mvor, motion%yt9%mvor, -1_int32, -1_int32, -1_int32]
    status = create_registry_gmv_variable_3d(output%vor, 'VOR', main4, next4, indices)
    if (status /= 0) return
    indices = [motion%yt0%msp, motion%yt1%msp, motion%yt9%msp, motion%yph9%msp, motion%yt0%mspl, motion%yt0%mspm]
    status = create_registry_gmv_variable_2d(output%sp, 'SP', main3, next3, indices)
    if (status /= 0) return
    indices = [motion%yt0%mspd, motion%yt1%mspd, motion%yt9%mspd, -1_int32, motion%yt0%mspd, motion%yt0%mspd]
    status = create_registry_gmv_variable_3d(output%spd, 'SPD', main4, next4, indices)
    if (status /= 0) return
    indices = [motion%yt0%msvd, motion%yt1%msvd, motion%yt9%msvd, -1_int32, motion%yt0%msvd, motion%yt0%msvd]
    status = create_registry_gmv_variable_3d(output%svd, 'SVD', main4, next4, indices)
    if (status /= 0) return
    indices = [motion%yt0%mnhx, motion%yt1%mnhx, motion%yt9%mnhx, -1_int32, motion%yt0%mnhx, motion%yt0%mnhx]
    status = create_registry_gmv_variable_3d(output%nhx, 'NHX', main4, next4, indices)
    if (status /= 0) return
    indices = [motion%yt0%medot, -1_int32, motion%yt9%medot, -1_int32, -1_int32, -1_int32]
    status = create_registry_gmv_variable_3d(output%edot, 'EDOT', main4, next4, indices)
    if (status /= 0) return
    indices = [motion%yt0%msgrtl, -1_int32, motion%yt9%msgrtl, -1_int32, -1_int32, -1_int32]
    status = create_registry_gmv_variable_3d(output%sgrtl, 'SGRTL', main4, next4, indices)
    if (status /= 0) return
    indices = [motion%yt0%msgrtm, -1_int32, motion%yt9%msgrtm, -1_int32, -1_int32, -1_int32]
    status = create_registry_gmv_variable_3d(output%sgrtm, 'SGRTM', main4, next4, indices)
    if (status /= 0) return
  end function
end module forecast_registry_motion

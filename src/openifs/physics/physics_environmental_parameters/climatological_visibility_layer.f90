!> Complete selected CLIMAER_LAYER calculation with native providers.
!! The parent retains pressure-weighted boundary temperatures, RADACA,
!! SATUR, aerosol conversion, tenth-band extinction and CLAERVIS order.
module forecast_climatological_visibility_layer
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use yoeaerd, only: teaerd
  use yoerad, only: terad
  use yoeozoc, only: teozoc
  use owned_aerosol_climatology_records, only: teaerc_tegen, teaerc_macc
  use physical_constant_setup_port, only: forecast_physical_constants
  use owned_ecmwf_thermal_state_port, only: thermal_parameter_record
  use saturation_humidity_mod, only: satur
  use forecast_aerosol_visibility_climatology, only: runtime_aerosol_visibility_climatology
  use forecast_shortwave_aerosol_extinction, only: runtime_shortwave_aerosol_extinction
  use forecast_cloud_aerosol_visibility, only: runtime_cloud_aerosol_visibility
  implicit none
  private
  public :: climatological_visibility_layer, runtime_climatological_visibility_layer
  interface
    function errno_address() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function
  end interface
contains
  !> Retain the coarse at-most24-column,19-level parent entry.
  subroutine climatological_visibility_layer(aerd,rad,ozone,tegen,macc,constants,thermal,first,last,pitch,levels,implicit_pressure,linear_physics,pressure_half,pressure_full,longitude,sine_latitude,cosine_longitude,sine_longitude,temperature,humidity,cloud_fraction,cloud,skin_temperature,classes,type_indices,hydrophobic,hydrophilic,humidity_thresholds,optical_depths,aerosol_extinction,visibility,heap_budget,status)
    type(teaerd), intent(in) :: aerd
    type(terad), intent(in) :: rad
    type(teozoc), intent(in) :: ozone
    type(teaerc_tegen), intent(in) :: tegen
    type(teaerc_macc), intent(in) :: macc
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    integer(int32), intent(in) :: first, last, pitch, levels, classes(:), type_indices(:)
    logical, intent(in) :: implicit_pressure, linear_physics
    real(real64),intent(in) :: pressure_half(:,0:),pressure_full(:,:),longitude(:),sine_latitude(:),cosine_longitude(:),sine_longitude(:)
    real(real64), intent(in) :: temperature(:, :), humidity(:, :), cloud_fraction(:, :), cloud(:, :, :), skin_temperature(:)
    real(real64), intent(in) :: hydrophobic(:, :), hydrophilic(:, :, :), humidity_thresholds(:)
    real(real64), intent(inout) :: optical_depths(:, :), aerosol_extinction(:), visibility(:)
    integer(int64), intent(in) :: heap_budget
    integer(int32), intent(out) :: status
    status = 2
    if (pitch > 24 .or. levels > 19) return
    call runtime_climatological_visibility_layer(aerd,rad,ozone,tegen,macc,constants,thermal,first,last,pitch,levels,implicit_pressure,linear_physics,pressure_half,pressure_full,longitude,sine_latitude,cosine_longitude,sine_longitude,temperature,humidity,cloud_fraction,cloud,skin_temperature,classes,type_indices,hydrophobic,hydrophilic,humidity_thresholds,optical_depths,aerosol_extinction,visibility,heap_budget,status)
  end subroutine

  !> Run the selected implicit-pressure,non-ECMWF-diagnostic visibility route.
  !! Supports first1,last1:P,P1:128,L2:137 and four/five cloud planes.
  !! CLOUD planes1:4 are liquid,ice,rain,snow in kg/kg; plane5 stays unread.
  !! PRESSURE_HALF(:,0:L) and PRESSURE_FULL(:,1:L) are Pa; temperature is K.
  !! Optical-depth columns are total,sea salt,dust,organic,black carbon,sulphate.
  !! Only active diagnostic/extinction/visibility values change. Native records
  !! and all input owners stay read-only and must be disjoint from outputs.
  !! Heap demand is8*P*(21*L+15) bytes; all private storage is freed on return.
  !! Return0 on success,1 on allocation failure,2 on admission refusal and3
  !! on child refusal after earlier source-ordered public writes.
  subroutine runtime_climatological_visibility_layer(aerd,rad,ozone,tegen,macc,constants,thermal,first,last,pitch,levels,implicit_pressure,linear_physics,pressure_half,pressure_full,longitude,sine_latitude,cosine_longitude,sine_longitude,temperature,humidity,cloud_fraction,cloud,skin_temperature,classes,type_indices,hydrophobic,hydrophilic,humidity_thresholds,optical_depths,aerosol_extinction,visibility,heap_budget,status)
    type(teaerd), intent(in) :: aerd
    type(terad), intent(in) :: rad
    type(teozoc), intent(in) :: ozone
    type(teaerc_tegen), intent(in) :: tegen
    type(teaerc_macc), intent(in) :: macc
    type(forecast_physical_constants), intent(in) :: constants
    type(thermal_parameter_record), intent(in) :: thermal
    integer(int32), intent(in) :: first, last, pitch, levels, classes(:), type_indices(:)
    logical, intent(in) :: implicit_pressure, linear_physics
    real(real64),intent(in) :: pressure_half(:,0:),pressure_full(:,:),longitude(:),sine_latitude(:),cosine_longitude(:),sine_longitude(:)
    real(real64), intent(in) :: temperature(:, :), humidity(:, :), cloud_fraction(:, :), cloud(:, :, :), skin_temperature(:)
    real(real64), intent(in) :: hydrophobic(:, :), hydrophilic(:, :, :), humidity_thresholds(:)
    real(real64), intent(inout) :: optical_depths(:, :), aerosol_extinction(:), visibility(:)
    integer(int64), intent(in) :: heap_budget
    integer(int32), intent(out) :: status
    real(real64), allocatable, target :: workspace(:)
    real(real64),pointer :: th(:,:),qaer(:,:,:),mass(:,:,:),ozone_amount(:,:),qsat(:,:),rh(:),inverse_mass(:),mixing_ratio(:,:)
    integer(c_int), pointer :: error_number
    integer(c_int) :: incoming_errno
    integer :: allocation_status, child_status, j, k, s, start, count
    integer(int64) :: needed
    real(real64) :: left, right, denominator, a, b, reciprocal
    call c_f_pointer(errno_address(), error_number)
    incoming_errno = error_number
    status = 2
    if (pitch < 1 .or. pitch > 128 .or. levels < 2 .or. levels > 137) return
    if (first /= 1 .or. last < 1 .or. last > pitch) return
    if (.not. implicit_pressure) return
    if (rad%lecsrad .or. rad%lusepre2017rad) return
    if (rad%naermacc /= 1 .or. rad%nmcvar /= 12) return
    if (size(pressure_half, 1) /= pitch .or. ubound(pressure_half, 2) < levels) return
    if (size(pressure_full, 1) /= pitch .or. size(pressure_full, 2) < levels) return
    if (size(temperature, 1) /= pitch .or. size(temperature, 2) < levels) return
    if (size(humidity, 1) /= pitch .or. size(humidity, 2) < levels) return
    if (size(cloud_fraction, 1) /= pitch .or. size(cloud_fraction, 2) < levels) return
    if (size(cloud, 1) /= pitch .or. size(cloud, 2) < levels) return
    if (size(cloud, 3) /= 4 .and. size(cloud, 3) /= 5) return
    if(min(size(longitude),size(sine_latitude),size(cosine_longitude),size(sine_longitude),size(skin_temperature),size(aerosol_extinction),size(visibility))<pitch) return
    if (size(optical_depths, 1) /= pitch .or. size(optical_depths, 2) < 6) return
    if (.not. (constants%rg > 0.0_real64 .and. constants%rd > 0.0_real64)) return
    do j = first, last
      do k = 2, levels
        a = pressure_full(j, k) - pressure_full(j, k - 1)
        if (.not. (pressure_half(j, k) > 0.0_real64 .and. a /= 0.0_real64)) return
      end do
      if (pressure_full(j, 1) == pressure_half(j, 2)) return
    end do
    needed = 8_int64*int(pitch, int64)*(21_int64*levels + 15_int64)
    if (heap_budget < needed) return
    allocate (workspace(needed/8_int64), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1
      error_number = incoming_errno
      return
    end if
    start = 1; count = pitch*(levels + 1)
    th(1:pitch, 1:levels + 1) => workspace(start:start + count - 1); start = start + count
    count = 6*pitch*levels
    qaer(1:pitch, 1:6, 1:levels) => workspace(start:start + count - 1); start = start + count
    count = 12*pitch*levels
    mass(1:pitch, 1:levels, 1:12) => workspace(start:start + count - 1); start = start + count
    count = pitch*levels
    ozone_amount(1:pitch, 1:levels) => workspace(start:start + count - 1); start = start + count
    qsat(1:pitch, 1:levels) => workspace(start:start + count - 1); start = start + count
    rh(1:pitch) => workspace(start:start + pitch - 1); start = start + pitch
    inverse_mass(1:pitch) => workspace(start:start + pitch - 1); start = start + pitch
    mixing_ratio(1:pitch, 1:12) => workspace(start:start + 12*pitch - 1)
    do k = 2, levels
      do j = first, last
        left = temperature(j, k - 1)*pressure_full(j, k - 1)
        a = pressure_full(j, k) - pressure_half(j, k)
        left = left*a
        right = temperature(j, k)*pressure_full(j, k)
        a = pressure_half(j, k) - pressure_full(j, k - 1)
        right = right*a
        left = left + right
        a = pressure_full(j, k) - pressure_full(j, k - 1)
        denominator = pressure_half(j, k)*a
        reciprocal = 1.0_real64/denominator
        th(j, k) = left*reciprocal
      end do
    end do
    do j = first, last
      a = temperature(j, 1) - th(j, 2)
      a = pressure_full(j, 1)*a
      b = pressure_full(j, 1) - pressure_half(j, 2)
      a = a/b
      th(j, 1) = temperature(j, 1) - a
      th(j, levels + 1) = skin_temperature(j)
    end do
    call runtime_aerosol_visibility_climatology(aerd,rad,ozone,tegen,macc,first,last,pitch,levels,pressure_half,longitude,sine_latitude,cosine_longitude,sine_longitude,th,qaer,mass,ozone_amount,aerosol_extinction,optical_depths(:,1),optical_depths(:,2),optical_depths(:,3),optical_depths(:,4),optical_depths(:,5),optical_depths(:,6),constants%rpi,constants%rg,child_status)
    if (child_status /= 0) then
      status = 3
    else
      child_status=satur(constants,thermal,first,last,pitch,levels,levels,linear_physics,pressure_full,temperature,qsat,2_int32)
      if (child_status /= 0) then
        status = 3
      else
        do j = first, last
          rh(j) = humidity(j, levels)/qsat(j, levels)
          a = pressure_full(j, levels) - pressure_full(j, levels - 1)
          inverse_mass(j) = constants%rg/a
        end do
        do s = 1, 12
          do j = first, last
            a = 1000.0_real64*mass(j, levels, s)
            mixing_ratio(j, s) = a*inverse_mass(j)
          end do
        end do
        call runtime_shortwave_aerosol_extinction(pitch,first,last,10_int32,classes,type_indices,hydrophobic,hydrophilic,humidity_thresholds,mixing_ratio,rh,aerosol_extinction,child_status)
        if (child_status /= 0) then
          status = 3
        else
          call runtime_cloud_aerosol_visibility(first,last,pitch,levels,aerosol_extinction,cloud_fraction,cloud(:,:,1),cloud(:,:,2),cloud(:,:,3),cloud(:,:,4),pressure_full,temperature,constants%rd,visibility,child_status)
          status = 0
          if (child_status /= 0) status = 3
        end if
      end if
    end if
    deallocate (workspace)
    error_number = incoming_errno
  end subroutine
end module

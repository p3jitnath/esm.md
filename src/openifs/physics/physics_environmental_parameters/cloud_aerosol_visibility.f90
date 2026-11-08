!> Cloud and aerosol visibility from the original CLAERVIS equations.
!! Pressure is in pascals, temperature in kelvin, condensates in kg/kg, and
!! visibility in metres. The upstream aerosol unit limitation is retained.
!! The caller owns disjoint contiguous arrays and establishes the FP mode.
module forecast_cloud_aerosol_visibility
  use iso_fortran_env, only: int32, int64, real64
  use forecast_public_scalar_math, only: power_original_rounding
  use forecast_environmental_ordered_arithmetic, only: maximum_with_finite_floor
  implicit none
  private
  public :: cloud_aerosol_visibility, runtime_cloud_aerosol_visibility
  public :: copy_climatological_visibility, update_runtime_zero_aerosol_visibility
  integer(int64), parameter :: constant_bits(11) = [ &
                               int(z'400f4bd2b6f19935', int64), int(z'40f86a0000000000', int64), int(z'408f500000000000', int64), &
                               int(z'408f400000000000', int64), int(z'4049000000000000', int64), int(z'3fe4b6ae7d566cf4', int64), &
                               int(z'3fc4faacd9e83e42', int64), int(z'3fe8f5c28f5c28f6', int64), int(z'3f70624dd2f1a9fc', int64), &
                               int(z'3fe8000000000000', int64), int(z'3f747ae147ae147b', int64)]
  real(real64), parameter :: c(11) = transfer(constant_bits, [0.0_real64], 11)
contains
  !> Apply the retained coarse bounds P<=24 and L<=19.
  !! The cloud-fraction matrix is read-only and numerically unused.
  subroutine cloud_aerosol_visibility(first,last,pitch,levels,aerosol,cloud_fraction,liquid,ice,rain,snow,pressure,temperature,rd,visibility,status)
    integer(int32), intent(in) :: first, last, pitch, levels
real(real64),intent(in) :: aerosol(:),cloud_fraction(:,:),liquid(:,:),ice(:,:),rain(:,:),snow(:,:),pressure(:,:),temperature(:,:),rd
    real(real64), intent(inout) :: visibility(:)
    integer(int32), intent(out) :: status
    status = 2
    if (pitch > 24 .or. levels > 19) return
    call runtime_cloud_aerosol_visibility(first,last,pitch,levels,aerosol,cloud_fraction,liquid,ice,rain,snow,pressure,temperature,rd,visibility,status)
  end subroutine

  !> Compute visibility at the bottom full level, preserving inactive columns.
  !! Supports P1:128,L1:137 and the empty interval first=last+1.
  !! The dry-air gas constant rd is an explicit positive initialized input.
  subroutine runtime_cloud_aerosol_visibility(first,last,pitch,levels,aerosol,cloud_fraction,liquid,ice,rain,snow,pressure,temperature,rd,visibility,status)
    integer(int32), intent(in) :: first, last, pitch, levels
real(real64),intent(in) :: aerosol(:),cloud_fraction(:,:),liquid(:,:),ice(:,:),rain(:,:),snow(:,:),pressure(:,:),temperature(:,:),rd
    real(real64), intent(inout) :: visibility(:)
    integer(int32), intent(out) :: status
    real(real64), volatile :: molecular, liquid_scale, runtime_constants(3)
    real(real64) :: density, denominator, aerosol_term, lw, iw, rw, sw, v, total
    integer :: j
    status = 2
    if (pitch < 1 .or. pitch > 128 .or. levels < 1 .or. levels > 137) return
    if (first < 1 .or. first > pitch + 1 .or. last < first - 1 .or. last > pitch) return
    if (size(aerosol) < pitch .or. size(visibility) < pitch) return
    if(min(size(cloud_fraction,1),size(liquid,1),size(ice,1),size(rain,1),size(snow,1),size(pressure,1),size(temperature,1))<pitch) return
    if(min(size(cloud_fraction,2),size(liquid,2),size(ice,2),size(rain,2),size(snow,2),size(pressure,2),size(temperature,2))<levels) return
    if (.not. (rd > 0.0_real64 .and. rd <= huge(rd))) return
    runtime_constants = c(1:3)
    molecular = runtime_constants(1)/runtime_constants(2)
    liquid_scale = runtime_constants(1)/runtime_constants(3)
    do j = first, last
      denominator = rd*temperature(j, levels)
      density = pressure(j, levels)/denominator
      aerosol_term = aerosol(j)/c(4)
      v = liquid(j, levels)*density; v = v*c(4); lw = maximum_with_finite_floor(v, 0.0_real64)
      v = rain(j, levels)*density; v = v*c(4); rw = maximum_with_finite_floor(v, 0.0_real64)
      v = ice(j, levels)*density; v = v*c(4); iw = maximum_with_finite_floor(v, 0.0_real64)
      v = snow(j, levels)*density; v = v*c(4); sw = maximum_with_finite_floor(v, 0.0_real64)
      v = lw*c(5)
      lw = power_original_rounding(v, c(6)); lw = liquid_scale*lw
      iw = c(7)*iw
      sw = power_original_rounding(sw, c(8)); sw = c(9)*sw
      rw = power_original_rounding(rw, c(10)); rw = c(11)*rw
      total = iw + lw; total = total + sw; total = total + rw
      denominator = molecular + aerosol_term; denominator = denominator + total
      visibility(j) = c(1)/denominator
    end do
    status = 0
  end subroutine

  !> Copy source visibility words without floating-point arithmetic.
  !! Full owner spans are P words. Exact source/destination identity is allowed;
  !! callers must exclude partial overlap and keep all metadata separate.
  subroutine copy_climatological_visibility(pitch, first, last, source, destination, status)
    integer(int32), intent(in) :: pitch, first, last
    real(real64), intent(in) :: source(:)
    real(real64), intent(inout) :: destination(:)
    integer(int32), intent(out) :: status
    integer :: j
    status = 2
    if (pitch < 1 .or. pitch > 128 .or. first < 1 .or. first > pitch + 1 .or. last < 0 .or. last > pitch) return
    if (first > last) then
      status = 0; return
    end if
    if (size(source) < pitch .or. size(destination) < pitch) return
    do j = first, last
      destination(j) = source(j)
    end do
    status = 0
  end subroutine

  !> Dispatch the original zero-active-aerosol visibility route.
  !! Native vector views replace private GEMS and diagnostic descriptors.
  !! A nonzero aerosol count is refused without changing the destination.
  subroutine update_runtime_zero_aerosol_visibility(pitch, first, last, active_aerosols, source, destination, status)
    integer(int32), intent(in) :: pitch, first, last, active_aerosols
    real(real64), intent(in) :: source(:)
    real(real64), intent(inout) :: destination(:)
    integer(int32), intent(out) :: status
    status = 2
    if (active_aerosols /= 0) return
    call copy_climatological_visibility(pitch, first, last, source, destination, status)
  end subroutine
end module

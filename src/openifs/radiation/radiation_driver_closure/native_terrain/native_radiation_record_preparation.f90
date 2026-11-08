!> Own canonical radiation record storage and source field preparation.
!! Native allocatable arrays have column-first storage, Pa, kelvin and flux W/m2.
!! Scientific source: ECMWF ecRad allocation and preparation methods.
!! These standalone routines use only data declarations from ecRad modules.
module native_radiation_record_preparation
  use parkind1, only: jprb
  use radiation_single_level, only: single_level_type
  use radiation_thermodynamics, only: thermodynamics_type
  use radiation_gas, only: gas_type, NMaxGases, IGasNotPresent, IMassMixingRatio, IVolumeMixingRatio
  use radiation_cloud, only: cloud_type
  use radiation_aerosol, only: aerosol_type
  use radiation_flux, only: flux_type
  implicit none
  private
  real(jprb), parameter :: IAirMolarMass = 28.970
real(jprb),parameter::owned_gas_molar_mass(0:12)=[0.0_jprb,18.0152833_jprb,44.011_jprb,47.9982_jprb,44.013_jprb,28.0101_jprb,16.043_jprb,31.9988_jprb,137.3686_jprb,120.914_jprb,86.469_jprb,153.823_jprb,46.0055_jprb]
  integer, parameter :: nulerr = 0
  public :: owned_set_units_gas
public::allocate_owned,release_owned,owned_get_layer_mass,owned_put_gas,owned_put_well_mixed_gas,owned_set_overlap_param,owned_create_fractional_std
  interface allocate_owned
module procedure owned_allocate_single_level,owned_allocate_thermodynamics_arrays,owned_allocate_gas,owned_allocate_cloud_arrays,owned_allocate_aerosol_arrays,owned_allocate_flux_type
  end interface
  interface release_owned
module procedure owned_deallocate_single_level,owned_deallocate_thermodynamics_arrays,owned_deallocate_gas,owned_deallocate_cloud_arrays,owned_deallocate_aerosol_arrays,owned_deallocate_flux_type
  end interface
contains

  subroutine owned_allocate_single_level(this, ncol, nalbedobands, nemisbands, &
         &                           use_sw_albedo_direct, is_simple_surface, status)

    use yomhook, only: lhook, dr_hook, jphook
    type(single_level_type), intent(inout) :: this
    integer, intent(in) :: ncol, nalbedobands, nemisbands
    logical, optional, intent(in) :: use_sw_albedo_direct
    logical, optional, intent(in) :: is_simple_surface

    real(jphook) :: hook_handle

    integer, intent(out) :: status
    status = 0
    if (lhook) call dr_hook('radiation_single_level:allocate', 0, hook_handle)

    call release_owned(this)

    if (present(is_simple_surface)) then
      this%is_simple_surface = is_simple_surface
    else
      this%is_simple_surface = .true.
    end if

    allocate (this%cos_sza(ncol), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if

    if (this%is_simple_surface) then
      allocate (this%skin_temperature(ncol), stat=status)
      if (status /= 0) then
        status = 1
        return
      end if
    else
      allocate (this%lw_emission(ncol, nemisbands), stat=status)
      if (status /= 0) then
        status = 1
        return
      end if
    end if
    allocate (this%lw_emissivity(ncol, nemisbands), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if

    allocate (this%sw_albedo(ncol, nalbedobands), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if

    if (present(use_sw_albedo_direct)) then
      if (use_sw_albedo_direct) then
        allocate (this%sw_albedo_direct(ncol, nalbedobands), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
      end if
    end if

    allocate (this%iseed(ncol), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if

    if (lhook) call dr_hook('radiation_single_level:allocate', 1, hook_handle)

  end subroutine owned_allocate_single_level

  subroutine owned_deallocate_single_level(this)

    use yomhook, only: lhook, dr_hook, jphook
    type(single_level_type), intent(inout) :: this

    real(jphook) :: hook_handle

    if (lhook) call dr_hook('radiation_single_level:deallocate', 0, hook_handle)

    if (allocated(this%cos_sza)) then
      deallocate (this%cos_sza)
    end if
    if (allocated(this%skin_temperature)) then
      deallocate (this%skin_temperature)
    end if
    if (allocated(this%sw_albedo)) then
      deallocate (this%sw_albedo)
    end if
    if (allocated(this%sw_albedo_direct)) then
      deallocate (this%sw_albedo_direct)
    end if
    if (allocated(this%lw_emissivity)) then
      deallocate (this%lw_emissivity)
    end if
    if (allocated(this%lw_emission)) then
      deallocate (this%lw_emission)
    end if
    if (allocated(this%spectral_solar_scaling)) then
      deallocate (this%spectral_solar_scaling)
    end if
    if (allocated(this%iseed)) then
      deallocate (this%iseed)
    end if

    if (lhook) call dr_hook('radiation_single_level:deallocate', 1, hook_handle)

  end subroutine owned_deallocate_single_level

  subroutine owned_allocate_thermodynamics_arrays(this, ncol, nlev, &
         &                                    use_h2o_sat, status)

    use yomhook, only: lhook, dr_hook, jphook

    type(thermodynamics_type), intent(inout) :: this
    integer, intent(in) :: ncol  ! Number of columns
    integer, intent(in) :: nlev  ! Number of levels
    logical, intent(in), optional :: use_h2o_sat ! Allocate h2o_sat_liq?

    logical :: use_h2o_sat_local

    real(jphook) :: hook_handle

    integer, intent(out) :: status
    status = 0
    if (lhook) call dr_hook('radiation_thermodynamics:allocate', 0, hook_handle)

    allocate (this%pressure_hl(ncol, nlev + 1), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if
    allocate (this%temperature_hl(ncol, nlev + 1), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if

    use_h2o_sat_local = .false.
    if (present(use_h2o_sat)) then
      use_h2o_sat_local = use_h2o_sat
    end if

    if (use_h2o_sat_local) then
      allocate (this%h2o_sat_liq(ncol, nlev), stat=status)
      if (status /= 0) then
        status = 1
        return
      end if
    end if

    if (lhook) call dr_hook('radiation_thermodynamics:allocate', 1, hook_handle)

  end subroutine owned_allocate_thermodynamics_arrays

  subroutine owned_deallocate_thermodynamics_arrays(this)

    use yomhook, only: lhook, dr_hook, jphook

    type(thermodynamics_type), intent(inout) :: this

    real(jphook) :: hook_handle

    if (lhook) call dr_hook('radiation_thermodynamics:deallocate', 0, hook_handle)

    if (allocated(this%pressure_hl)) then
      deallocate (this%pressure_hl)
    end if
    if (allocated(this%temperature_hl)) then
      deallocate (this%temperature_hl)
    end if
    if (allocated(this%h2o_sat_liq)) then
      deallocate (this%h2o_sat_liq)
    end if

    if (lhook) call dr_hook('radiation_thermodynamics:deallocate', 1, hook_handle)

  end subroutine owned_deallocate_thermodynamics_arrays

  subroutine owned_get_layer_mass(this, istartcol, iendcol, layer_mass)

    use yomhook, only: lhook, dr_hook, jphook
    use radiation_constants, only: AccelDueToGravity

    type(thermodynamics_type), intent(in) :: this
    integer, intent(in) :: istartcol, iendcol
    real(jprb), intent(out) :: layer_mass(:, :)

    integer :: nlev
    real(jprb) :: inv_g

    real(jphook) :: hook_handle

    if (lhook) call dr_hook('radiation_thermodynamics:owned_get_layer_mass', 0, hook_handle)

    nlev = ubound(this%pressure_hl, 2) - 1
    inv_g = 1.0_jprb/AccelDueToGravity

    layer_mass(istartcol:iendcol, 1:nlev) &
         &  = (this%pressure_hl(istartcol:iendcol, 2:nlev + 1) &
         &     - this%pressure_hl(istartcol:iendcol, 1:nlev)) &
         &  *inv_g

    if (lhook) call dr_hook('radiation_thermodynamics:owned_get_layer_mass', 1, hook_handle)

  end subroutine owned_get_layer_mass

  subroutine owned_allocate_gas(this, ncol, nlev, status)

    use yomhook, only: lhook, dr_hook, jphook
    type(gas_type), intent(inout) :: this
    integer, intent(in) :: ncol, nlev

    real(jphook) :: hook_handle

    integer, intent(out) :: status
    status = 0
    if (lhook) call dr_hook('radiation_gas:allocate', 0, hook_handle)

    call release_owned(this)

    allocate (this%mixing_ratio(ncol, nlev, NMaxGases), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if
    this%mixing_ratio = 0.0_jprb

    this%ncol = ncol
    this%nlev = nlev

    if (lhook) call dr_hook('radiation_gas:allocate', 1, hook_handle)

  end subroutine owned_allocate_gas

  subroutine owned_deallocate_gas(this)

    use yomhook, only: lhook, dr_hook, jphook
    type(gas_type), intent(inout) :: this

    real(jphook) :: hook_handle

    if (lhook) call dr_hook('radiation_gas:deallocate', 0, hook_handle)

    if (allocated(this%mixing_ratio)) then
      deallocate (this%mixing_ratio)
    end if

    this%iunits = 0
    this%scale_factor = 0.0_jprb
    this%is_present = .false.
    this%is_well_mixed = .false.
    this%ntype = 0
    this%ncol = 0
    this%nlev = 0
    this%icode = 0

    if (lhook) call dr_hook('radiation_gas:deallocate', 1, hook_handle)

  end subroutine owned_deallocate_gas

  subroutine owned_put_gas(this, igas, iunits, mixing_ratio, scale_factor, &
                           istartcol)

    use yomhook, only: lhook, dr_hook, jphook

    type(gas_type), intent(inout) :: this
    integer, intent(in) :: igas
    integer, intent(in) :: iunits
    real(jprb), intent(in) :: mixing_ratio(:, :)
    real(jprb), optional, intent(in) :: scale_factor
    integer, optional, intent(in) :: istartcol

    integer :: i1, i2

    real(jphook) :: hook_handle

    if (lhook) call dr_hook('radiation_gas:put', 0, hook_handle)

    ! Check inputs
    if (igas <= IGasNotPresent .or. iunits > NMaxGases) then
      write (nulerr, '(a,i0,a,i0,a,i0)') '*** Error: provided gas ID (', &
           &   igas, ') must be in the range ', IGasNotPresent + 1, ' to ', &
           &   NMaxGases
      call radiation_abort()
    end if
    if (iunits < IMassMixingRatio .or. iunits > IVolumeMixingRatio) then
      write (nulerr, '(a,i0,a,i0,a,i0)') '*** Error: provided gas units (', &
           &   iunits, ') must be in the range ', IMassMixingRatio, ' to ', &
           &   IVolumeMixingRatio
      call radiation_abort()
    end if

    if (.not. allocated(this%mixing_ratio)) then
      write (nulerr, '(a,i0,a,i0,a,i0)') '*** Error: attempt to put data to unallocated radiation_gas object'
      call radiation_abort()
    end if

    if (present(istartcol)) then
      i1 = istartcol
    else
      i1 = 1
    end if

    i2 = i1 + size(mixing_ratio, 1) - 1

    if (i1 < 1 .or. i2 < 1 .or. i1 > this%ncol .or. i2 > this%ncol) then
      write (nulerr, '(a,i0,a,i0,a,i0)') '*** Error: attempt to put columns indexed ', &
           &   i1, ' to ', i2, ' to array indexed 1 to ', this%ncol
      call radiation_abort()
    end if

    if (size(mixing_ratio, 2) /= this%nlev) then
      write (nulerr, '(a,i0,a)') &
           &  '*** Error: gas mixing ratio expected to have ', this%nlev, &
           &  ' levels'
      call radiation_abort()
    end if

    if (.not. this%is_present(igas)) then
      ! Gas not present until now
      this%ntype = this%ntype + 1
      this%icode(this%ntype) = igas
    end if
    this%is_present(igas) = .true.
    this%iunits(igas) = iunits
    this%is_well_mixed(igas) = .false.
    this%mixing_ratio(i1:i2, :, igas) = mixing_ratio

    if (present(scale_factor)) then
      this%scale_factor(igas) = scale_factor
    else
      this%scale_factor(igas) = 1.0_jprb
    end if

    if (lhook) call dr_hook('radiation_gas:put', 1, hook_handle)

  end subroutine owned_put_gas

  subroutine owned_put_well_mixed_gas(this, igas, iunits, mixing_ratio, &
                                      scale_factor, istartcol, iendcol)

    use yomhook, only: lhook, dr_hook, jphook

    type(gas_type), intent(inout) :: this
    integer, intent(in) :: igas
    integer, intent(in) :: iunits
    real(jprb), intent(in) :: mixing_ratio
    real(jprb), optional, intent(in) :: scale_factor
    integer, optional, intent(in) :: istartcol, iendcol

    real(jphook) :: hook_handle

    integer :: i1, i2

    if (lhook) call dr_hook('radiation_gas:put_well_mixed', 0, hook_handle)

    ! Check inputs
    if (igas <= IGasNotPresent .or. igas > NMaxGases) then
      write (nulerr, '(a,i0,a,i0,a,i0)') '*** Error: provided gas ID (', &
           &   igas, ') must be in the range ', IGasNotPresent + 1, ' to ', &
           &   NMaxGases
      call radiation_abort()
    end if
    if (iunits < IMassMixingRatio .or. iunits > IVolumeMixingRatio) then
      write (nulerr, '(a,i0,a,i0,a,i0)') '*** Error: provided gas units (', &
           &   iunits, ') must be in the range ', IMassMixingRatio, ' to ', &
           &   IVolumeMixingRatio
      call radiation_abort()
    end if

    if (.not. allocated(this%mixing_ratio)) then
      write (nulerr, '(a)') '*** Error: attempt to put well-mixed gas data to unallocated radiation_gas object'
      call radiation_abort()
    end if

    if (present(istartcol)) then
      i1 = istartcol
    else
      i1 = 1
    end if

    if (present(iendcol)) then
      i2 = iendcol
    else
      i2 = this%ncol
    end if

    if (i1 < 1 .or. i2 < 1 .or. i1 > this%ncol .or. i2 > this%ncol) then
      write (nulerr, '(a,i0,a,i0,a,i0)') '*** Error: attempt to put columns indexed ', &
           &   i1, ' to ', i2, ' to array indexed 1 to ', this%ncol
      call radiation_abort()
    end if

    if (.not. this%is_present(igas)) then
      ! Gas not present until now
      this%ntype = this%ntype + 1
      this%icode(this%ntype) = igas
    end if
    ! Map uses a negative value to indicate a well-mixed value
    this%is_present(igas) = .true.
    this%iunits(igas) = iunits
    this%is_well_mixed(igas) = .true.
    this%mixing_ratio(i1:i2, :, igas) = mixing_ratio

    if (present(scale_factor)) then
      this%scale_factor(igas) = scale_factor
    else
      this%scale_factor(igas) = 1.0_jprb
    end if

    if (lhook) call dr_hook('radiation_gas:put_well_mixed', 1, hook_handle)

  end subroutine owned_put_well_mixed_gas

  subroutine owned_allocate_cloud_arrays(this, ncol, nlev, use_inhom_effective_size, status)

    use yomhook, only: lhook, dr_hook, jphook
    type(cloud_type), intent(inout) :: this
    integer, intent(in) :: ncol  ! Number of columns
    integer, intent(in) :: nlev  ! Number of levels
    logical, intent(in), optional :: use_inhom_effective_size

    real(jphook) :: hook_handle

    integer, intent(out) :: status
    status = 0
    if (lhook) call dr_hook('radiation_cloud:allocate', 0, hook_handle)

    allocate (this%q_liq(ncol, nlev), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if
    allocate (this%re_liq(ncol, nlev), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if
    allocate (this%q_ice(ncol, nlev), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if
    allocate (this%re_ice(ncol, nlev), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if
    allocate (this%fraction(ncol, nlev), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if
    allocate (this%overlap_param(ncol, nlev - 1), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if
    allocate (this%fractional_std(ncol, nlev), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if
    allocate (this%inv_cloud_effective_size(ncol, nlev), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if

    if (present(use_inhom_effective_size)) then
      if (use_inhom_effective_size) then
        allocate (this%inv_inhom_effective_size(ncol, nlev), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
      end if
    end if

    if (lhook) call dr_hook('radiation_cloud:allocate', 1, hook_handle)

  end subroutine owned_allocate_cloud_arrays

  subroutine owned_deallocate_cloud_arrays(this)

    use yomhook, only: lhook, dr_hook, jphook
    type(cloud_type), intent(inout) :: this

    real(jphook) :: hook_handle

    if (lhook) call dr_hook('radiation_cloud:deallocate', 0, hook_handle)

    if (allocated(this%q_liq)) deallocate (this%q_liq)
    if (allocated(this%re_liq)) deallocate (this%re_liq)
    if (allocated(this%q_ice)) deallocate (this%q_ice)
    if (allocated(this%re_ice)) deallocate (this%re_ice)
    if (allocated(this%fraction)) deallocate (this%fraction)
    if (allocated(this%overlap_param)) deallocate (this%overlap_param)
    if (allocated(this%fractional_std)) deallocate (this%fractional_std)
    if (allocated(this%inv_cloud_effective_size)) &
         &  deallocate (this%inv_cloud_effective_size)
    if (allocated(this%inv_inhom_effective_size)) &
         &  deallocate (this%inv_inhom_effective_size)

    if (lhook) call dr_hook('radiation_cloud:deallocate', 1, hook_handle)

  end subroutine owned_deallocate_cloud_arrays

  subroutine owned_set_overlap_param(this, thermodynamics, decorrelation_length, &
         &  istartcol, iendcol)

    use yomhook, only: lhook, dr_hook, jphook
    use radiation_thermodynamics, only: thermodynamics_type
    use radiation_constants, only: GasConstantDryAir, AccelDueToGravity

    type(cloud_type), intent(inout) :: this
    type(thermodynamics_type), intent(in) :: thermodynamics
    real(jprb), intent(in) :: decorrelation_length ! m
    integer, optional, intent(in) :: istartcol, iendcol

    ! Ratio of gas constant for dry air to acceleration due to gravity
    real(jprb), parameter :: R_over_g = GasConstantDryAir/AccelDueToGravity

    ! Process only columns i1 to i2, which will be istartcol to
    ! iendcol if they were provided
    integer :: i1, i2

    integer :: ncol, nlev

    integer :: jlev

    real(jphook) :: hook_handle

    if (lhook) call dr_hook('radiation_cloud:owned_set_overlap_param', 0, hook_handle)

    ! Pressure at half-levels, pressure_hl, is defined at nlev+1
    ! points
    ncol = size(thermodynamics%pressure_hl, dim=1)
    nlev = size(thermodynamics%pressure_hl, dim=2) - 1

    if (present(istartcol)) then
      i1 = istartcol
    else
      i1 = 1
    end if

    if (present(iendcol)) then
      i2 = iendcol
    else
      i2 = ncol
    end if

    if (.not. allocated(this%overlap_param)) then
      ! If pressure is of size (ncol,nlev+1) then overlap_param is of
      ! size (ncol,nlev-1), since overlap parameter is only defined here
      ! for interfaces between model layers, not for the interface to
      ! space or the surface
      allocate (this%overlap_param(ncol, nlev - 1))
    end if

    if (thermodynamics%pressure_hl(i1, 2) > thermodynamics%pressure_hl(i1, 1)) then
      ! Pressure is increasing with index (order of layers is
      ! top-of-atmosphere to surface). In case pressure_hl(:,1)=0, we
      ! don't take the logarithm of the first pressure in each column.
      this%overlap_param(i1:i2, 1) = exp(-(R_over_g/decorrelation_length) &
           &                            *thermodynamics%temperature_hl(i1:i2, 2) &
           &                            *log(thermodynamics%pressure_hl(i1:i2, 3) &
           &                                /thermodynamics%pressure_hl(i1:i2, 2)))

      do jlev = 2, nlev - 1
        this%overlap_param(i1:i2, jlev) = exp(-(0.5_jprb*R_over_g/decorrelation_length) &
             &                            *thermodynamics%temperature_hl(i1:i2, jlev + 1) &
             &                            *log(thermodynamics%pressure_hl(i1:i2, jlev + 2) &
             &                                /thermodynamics%pressure_hl(i1:i2, jlev)))
      end do

    else
      ! Pressure is decreasing with index (order of layers is surface
      ! to top-of-atmosphere).  In case pressure_hl(:,nlev+1)=0, we
      ! don't take the logarithm of the last pressure in each column.
      do jlev = 1, nlev - 2
        this%overlap_param(i1:i2, jlev) = exp(-(0.5_jprb*R_over_g/decorrelation_length) &
             &                            *thermodynamics%temperature_hl(i1:i2, jlev + 1) &
             &                            *log(thermodynamics%pressure_hl(i1:i2, jlev) &
             &                                /thermodynamics%pressure_hl(i1:i2, jlev + 2)))
      end do
      this%overlap_param(i1:i2, nlev - 1) = exp(-(R_over_g/decorrelation_length) &
           &                            *thermodynamics%temperature_hl(i1:i2, nlev) &
           &                            *log(thermodynamics%pressure_hl(i1:i2, nlev - 1) &
           &                                /thermodynamics%pressure_hl(i1:i2, nlev)))

    end if

    if (lhook) call dr_hook('radiation_cloud:owned_set_overlap_param', 1, hook_handle)

  end subroutine owned_set_overlap_param

  subroutine owned_create_fractional_std(this, ncol, nlev, frac_std)

    use yomhook, only: lhook, dr_hook, jphook
    type(cloud_type), intent(inout) :: this
    integer, intent(in) :: ncol, nlev
    real(jprb), intent(in) :: frac_std

    real(jphook) :: hook_handle

    if (lhook) call dr_hook('radiation_cloud:owned_create_fractional_std', 0, hook_handle)

    if (allocated(this%fractional_std)) then
      deallocate (this%fractional_std)
    end if

    allocate (this%fractional_std(ncol, nlev))

    this%fractional_std = frac_std

    if (lhook) call dr_hook('radiation_cloud:owned_create_fractional_std', 1, hook_handle)

  end subroutine owned_create_fractional_std

  subroutine owned_allocate_aerosol_arrays(this, ncol, istartlev, iendlev, ntype, status)

    use yomhook, only: lhook, dr_hook, jphook
    type(aerosol_type), intent(inout) :: this
    integer, intent(in) :: ncol  ! Number of columns
    integer, intent(in) :: istartlev, iendlev ! Level range
    integer, intent(in) :: ntype ! Number of aerosol types
    real(jphook) :: hook_handle

    integer, intent(out) :: status
    status = 0
    if (lhook) call dr_hook('radiation_aerosol:allocate', 0, hook_handle)

    allocate (this%mixing_ratio(ncol, istartlev:iendlev, ntype), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if
    this%is_direct = .false.
    this%istartlev = istartlev
    this%iendlev = iendlev

    if (lhook) call dr_hook('radiation_aerosol:allocate', 1, hook_handle)

  end subroutine owned_allocate_aerosol_arrays

  subroutine owned_deallocate_aerosol_arrays(this)

    use yomhook, only: lhook, dr_hook, jphook
    type(aerosol_type), intent(inout) :: this

    real(jphook) :: hook_handle

    if (lhook) call dr_hook('radiation_aerosol:deallocate', 0, hook_handle)

    if (allocated(this%mixing_ratio)) deallocate (this%mixing_ratio)
    if (allocated(this%od_sw)) deallocate (this%od_sw)
    if (allocated(this%ssa_sw)) deallocate (this%ssa_sw)
    if (allocated(this%g_sw)) deallocate (this%g_sw)
    if (allocated(this%od_lw)) deallocate (this%od_lw)
    if (allocated(this%ssa_lw)) deallocate (this%ssa_lw)
    if (allocated(this%g_lw)) deallocate (this%g_lw)

    if (lhook) call dr_hook('radiation_aerosol:deallocate', 1, hook_handle)

  end subroutine owned_deallocate_aerosol_arrays

  subroutine owned_allocate_flux_type(this, config, istartcol, iendcol, nlev, status)

    use yomhook, only: lhook, dr_hook, jphook

    use radiation_config, only: config_type

    integer, intent(in) :: istartcol, iendcol, nlev
    type(flux_type), intent(inout) :: this
    type(config_type), intent(in) :: config

    real(jphook) :: hook_handle

    integer, intent(out) :: status
    status = 0
    if (lhook) call dr_hook('radiation_flux:allocate', 0, hook_handle)

    ! Allocate longwave arrays
    if (config%do_lw) then
      allocate (this%lw_up(istartcol:iendcol, nlev + 1), stat=status)
      if (status /= 0) then
        status = 1
        return
      end if
      allocate (this%lw_dn(istartcol:iendcol, nlev + 1), stat=status)
      if (status /= 0) then
        status = 1
        return
      end if
      if (config%do_clear) then
        allocate (this%lw_up_clear(istartcol:iendcol, nlev + 1), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
        allocate (this%lw_dn_clear(istartcol:iendcol, nlev + 1), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
      end if

      if (config%do_save_spectral_flux) then
        if (config%n_spec_lw == 0) then
          write (nulerr, '(a)') '*** Error: number of LW spectral points to save not yet defined ' &
               & //'so cannot allocated spectral flux arrays'
          call radiation_abort()
        end if

        allocate (this%lw_up_band(config%n_spec_lw, istartcol:iendcol, nlev + 1), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
        allocate (this%lw_dn_band(config%n_spec_lw, istartcol:iendcol, nlev + 1), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
        if (config%do_clear) then
          allocate (this%lw_up_clear_band(config%n_spec_lw, &
               &                         istartcol:iendcol, nlev + 1), stat=status)
          if (status /= 0) then
            status = 1
            return
          end if
          allocate (this%lw_dn_clear_band(config%n_spec_lw, &
               &                         istartcol:iendcol, nlev + 1), stat=status)
          if (status /= 0) then
            status = 1
            return
          end if
        end if
      end if

      if (config%do_lw_derivatives) then
        allocate (this%lw_derivatives(istartcol:iendcol, nlev + 1), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
      end if

      ! Allocate g-point downwelling fluxes at surface passed from
      ! solver to surface_intermediate%partition
      allocate (this%lw_dn_surf_g(config%n_g_lw, istartcol:iendcol), stat=status)
      if (status /= 0) then
        status = 1
        return
      end if
      if (config%do_clear) then
        allocate (this%lw_dn_surf_clear_g(config%n_g_lw, istartcol:iendcol), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
      end if

      if (config%do_canopy_fluxes_lw) then
        ! Downward fluxes at top of canopy at the spectral resolution
        ! used in the canopy radiative transfer scheme
        allocate (this%lw_dn_surf_canopy(config%n_canopy_bands_lw, istartcol:iendcol), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
      end if
    end if

    ! Allocate shortwave arrays
    if (config%do_sw) then
      allocate (this%sw_up(istartcol:iendcol, nlev + 1), stat=status)
      if (status /= 0) then
        status = 1
        return
      end if
      allocate (this%sw_dn(istartcol:iendcol, nlev + 1), stat=status)
      if (status /= 0) then
        status = 1
        return
      end if
      if (config%do_sw_direct) then
        allocate (this%sw_dn_direct(istartcol:iendcol, nlev + 1), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
      end if
      if (config%do_clear) then
        allocate (this%sw_up_clear(istartcol:iendcol, nlev + 1), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
        allocate (this%sw_dn_clear(istartcol:iendcol, nlev + 1), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
        if (config%do_sw_direct) then
          allocate (this%sw_dn_direct_clear(istartcol:iendcol, nlev + 1), stat=status)
          if (status /= 0) then
            status = 1
            return
          end if
        end if
      end if

      if (config%do_save_spectral_flux) then
        if (config%n_spec_sw == 0) then
          write (nulerr, '(a)') '*** Error: number of SW spectral points to save not yet defined ' &
               & //'so cannot allocate spectral flux arrays'
          call radiation_abort()
        end if

        allocate (this%sw_up_band(config%n_spec_sw, istartcol:iendcol, nlev + 1), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
        allocate (this%sw_dn_band(config%n_spec_sw, istartcol:iendcol, nlev + 1), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if

        if (config%do_sw_direct) then
          allocate (this%sw_dn_direct_band(config%n_spec_sw, &
               &                          istartcol:iendcol, nlev + 1), stat=status)
          if (status /= 0) then
            status = 1
            return
          end if
        end if
        if (config%do_clear) then
          allocate (this%sw_up_clear_band(config%n_spec_sw, &
               &                         istartcol:iendcol, nlev + 1), stat=status)
          if (status /= 0) then
            status = 1
            return
          end if
          allocate (this%sw_dn_clear_band(config%n_spec_sw, &
               &                         istartcol:iendcol, nlev + 1), stat=status)
          if (status /= 0) then
            status = 1
            return
          end if
          if (config%do_sw_direct) then
            allocate (this%sw_dn_direct_clear_band(config%n_spec_sw, &
                 &                                istartcol:iendcol, nlev + 1), stat=status)
            if (status /= 0) then
              status = 1
              return
            end if
          end if
        end if
      end if

      if (config%do_surface_sw_spectral_flux) then
        if (config%n_bands_sw == 0) then
          write (nulerr, '(a)') '*** Error: number of SW bands not yet defined ' &
               & //'so cannot allocate surface spectral flux arrays'
          call radiation_abort()
        end if
        allocate (this%sw_dn_surf_band(config%n_bands_sw, istartcol:iendcol), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
        allocate (this%sw_dn_direct_surf_band(config%n_bands_sw, istartcol:iendcol), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
        if (config%do_clear) then
          allocate (this%sw_dn_surf_clear_band(config%n_bands_sw, &
               &                              istartcol:iendcol), stat=status)
          if (status /= 0) then
            status = 1
            return
          end if
          allocate (this%sw_dn_direct_surf_clear_band(config%n_bands_sw, &
               &                                     istartcol:iendcol), stat=status)
          if (status /= 0) then
            status = 1
            return
          end if
        end if
      end if

      ! Allocate g-point downwelling fluxes at surface passed from
      ! solver to surface_intermediate%partition
      allocate (this%sw_dn_diffuse_surf_g(config%n_g_sw, istartcol:iendcol), stat=status)
      if (status /= 0) then
        status = 1
        return
      end if
      allocate (this%sw_dn_direct_surf_g(config%n_g_sw, istartcol:iendcol), stat=status)
      if (status /= 0) then
        status = 1
        return
      end if
      if (config%do_clear) then
        allocate (this%sw_dn_diffuse_surf_clear_g(config%n_g_sw, istartcol:iendcol), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
        allocate (this%sw_dn_direct_surf_clear_g(config%n_g_sw, istartcol:iendcol), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
      end if

      if (config%do_canopy_fluxes_sw) then
        ! Downward fluxes at top of canopy at the spectral resolution
        ! used in the canopy radiative transfer scheme
        allocate (this%sw_dn_diffuse_surf_canopy(config%n_canopy_bands_sw, istartcol:iendcol), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
        allocate (this%sw_dn_direct_surf_canopy(config%n_canopy_bands_sw, istartcol:iendcol), stat=status)
        if (status /= 0) then
          status = 1
          return
        end if
      end if
    end if

    ! Allocate cloud cover arrays
    allocate (this%cloud_cover_lw(istartcol:iendcol), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if
    allocate (this%cloud_cover_sw(istartcol:iendcol), stat=status)
    if (status /= 0) then
      status = 1
      return
    end if

    ! Some solvers may not write to cloud cover, so we initialize to
    ! an unphysical value
    this%cloud_cover_lw = -1.0_jprb
    this%cloud_cover_sw = -1.0_jprb

    if (lhook) call dr_hook('radiation_flux:allocate', 1, hook_handle)

  end subroutine owned_allocate_flux_type

  subroutine owned_deallocate_flux_type(this)

    use yomhook, only: lhook, dr_hook, jphook
    type(flux_type), intent(inout) :: this
    real(jphook) :: hook_handle

    if (lhook) call dr_hook('radiation_flux:deallocate', 0, hook_handle)

    if (allocated(this%lw_up)) then
      deallocate (this%lw_up)
      if (allocated(this%lw_dn)) deallocate (this%lw_dn)
      if (allocated(this%lw_up_clear)) deallocate (this%lw_up_clear)
      if (allocated(this%lw_dn_clear)) deallocate (this%lw_dn_clear)
    end if

    if (allocated(this%sw_up)) then
      deallocate (this%sw_up)
      if (allocated(this%sw_dn)) deallocate (this%sw_dn)
      if (allocated(this%sw_up_clear)) deallocate (this%sw_up_clear)
      if (allocated(this%sw_dn_clear)) deallocate (this%sw_dn_clear)
      if (allocated(this%sw_dn_direct)) deallocate (this%sw_dn_direct)
      if (allocated(this%sw_dn_direct_clear)) &
           &   deallocate (this%sw_dn_direct_clear)
    end if

    if (allocated(this%lw_up_band)) then
      deallocate (this%lw_up_band)
      if (allocated(this%lw_dn_band)) deallocate (this%lw_dn_band)
      if (allocated(this%lw_up_clear_band)) deallocate (this%lw_up_clear_band)
      if (allocated(this%lw_dn_clear_band)) deallocate (this%lw_dn_clear_band)
    end if

    if (allocated(this%sw_up_band)) then
      deallocate (this%sw_up_band)
      if (allocated(this%sw_dn_band)) deallocate (this%sw_dn_band)
      if (allocated(this%sw_up_clear_band)) deallocate (this%sw_up_clear_band)
      if (allocated(this%sw_dn_clear_band)) deallocate (this%sw_dn_clear_band)
      if (allocated(this%sw_dn_direct_band)) deallocate (this%sw_dn_direct_band)
      if (allocated(this%sw_dn_direct_clear_band)) &
           &   deallocate (this%sw_dn_direct_clear_band)
    end if

    if (allocated(this%sw_dn_surf_band)) then
      deallocate (this%sw_dn_surf_band)
      deallocate (this%sw_dn_direct_surf_band)
    end if
    if (allocated(this%sw_dn_surf_clear_band)) then
      deallocate (this%sw_dn_surf_clear_band)
      deallocate (this%sw_dn_direct_surf_clear_band)
    end if

    if (allocated(this%lw_dn_surf_canopy)) deallocate (this%lw_dn_surf_canopy)
    if (allocated(this%sw_dn_diffuse_surf_canopy)) deallocate (this%sw_dn_diffuse_surf_canopy)
    if (allocated(this%sw_dn_direct_surf_canopy)) deallocate (this%sw_dn_direct_surf_canopy)

    if (allocated(this%cloud_cover_sw)) then
      deallocate (this%cloud_cover_sw)
    end if
    if (allocated(this%cloud_cover_lw)) then
      deallocate (this%cloud_cover_lw)
    end if

    if (allocated(this%lw_derivatives)) then
      deallocate (this%lw_derivatives)
    end if

    if (lhook) call dr_hook('radiation_flux:deallocate', 1, hook_handle)

  end subroutine owned_deallocate_flux_type

!> Stop a refused native record operation without a model callback.
  subroutine radiation_abort()
    error stop "native radiation record preparation refused its input"
  end subroutine
  recursive subroutine owned_set_units_gas(this, iunits, igas, scale_factor)
    type(gas_type), intent(inout) :: this
    integer, intent(in) :: iunits
    integer, optional, intent(in) :: igas
    real(jprb), optional, intent(in) :: scale_factor

    integer :: ig

    ! Scaling factor to convert from old to new
    real(jprb) :: sf

    ! New scaling factor to store inside the gas object
    real(jprb) :: new_sf

    if (present(scale_factor)) then
      ! "sf" is the scaling to be applied now to the numbers (and may
      ! be modified below), "new_sf" is the value to be stored along
      ! with the numbers, informing subsequent routines how much you
      ! would need to multiply the numbers by to get a dimensionless
      ! result.
      sf = 1.0_jprb/scale_factor
      new_sf = scale_factor
    else
      sf = 1.0_jprb
      new_sf = 1.0_jprb
    end if

    if (present(igas)) then
      if (this%is_present(igas)) then
        if (iunits == IMassMixingRatio &
             &   .and. this%iunits(igas) == IVolumeMixingRatio) then
          sf = sf*owned_gas_molar_mass(igas)/IAirMolarMass
        else if (iunits == IVolumeMixingRatio &
             &   .and. this%iunits(igas) == IMassMixingRatio) then
          sf = sf*IAirMolarMass/owned_gas_molar_mass(igas)
        end if
        sf = sf*this%scale_factor(igas)

        if (sf /= 1.0_jprb) then
          this%mixing_ratio(:, :, igas) = this%mixing_ratio(:, :, igas)*sf
        end if
        ! Store the new units and scale factor for this gas inside the
        ! gas object
        this%iunits(igas) = iunits
        this%scale_factor(igas) = new_sf
      end if
    else
      do ig = 1, this%ntype
        call owned_set_units_gas(this, iunits, igas=this%icode(ig), scale_factor=new_sf)
      end do
    end if

  end subroutine owned_set_units_gas
end module

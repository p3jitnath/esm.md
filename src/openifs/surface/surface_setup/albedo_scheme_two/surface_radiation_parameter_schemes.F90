!> Own the common surface-radiation setup for albedo schemes one and two.
!! Native records replace private Arm offsets. The selected route has twelve months,
!! six consumed shortwave bands, fourteen allocated bands and two emissivity intervals.
module surface_radiation_schemes_setup_mod
  use iso_fortran_env, only: int32, int64, real64
  use iso_c_binding, only: c_ptr, c_int, c_intptr_t, c_loc, c_f_pointer
  use surface_radiation_setup_mod, only: surface_radiation_inputs
  use ieee_exceptions, only: ieee_status_type, ieee_get_status, ieee_set_status
  use yos_dim, only: tdim
  use yos_rad, only: trad
  use yos_rdi, only: trdi
  use yos_lw, only: tlw
  use yos_sw, only: tsw
  implicit none
  private
  public :: surface_radiation_inputs, initialize_selected_surface_radiation_inputs
  public :: initialize_selected_surface_radiation_parameters, release_surface_radiation_parameters
  public :: prepare_surface_shortwave_storage, write_surface_shortwave_fields
  public :: radiation_contract_abort
  integer(int64), parameter :: input_words(57) = [ &
                               int(z'0000000e00000006', int64), int(z'0000000200000006', int64), &
                               int(z'0000000000000001', int64), int(z'0000000100000001', int64), &
                               int(z'406f400000000000', int64), int(z'4049000000000000', int64), &
                               int(z'408c200000000000', int64), int(z'4047371e96c3fc44', int64), &
                               int(z'4060290e410b630b', int64), int(z'4069ea72862f598a', int64), &
                               int(z'40739fbeea209aaa', int64), int(z'4066f76aa8eb4635', int64), &
                               int(z'c05c87dfb9389b52', int64), int(z'405266b49e01de27', int64), &
                               int(z'40716e10f51ac9b0', int64), int(z'4070ec4fbfc6540d', int64), &
                               int(z'c04ca93aeee95747', int64), int(z'c0502f8472c0e7bc', int64), &
                               int(z'4055cf3ffac1d29e', int64), int(z'40428682c6ef3d3a', int64), &
                               int(z'40699f9a5657fb6a', int64), int(z'40777948de2ac322', int64), &
                               int(z'4065c05feda66128', int64), int(z'c060b018bd66277c', int64), &
                               int(z'c042d36e04c05921', int64), int(z'402ddc3b70ef5665', int64), &
                               int(z'40564a5072085b18', int64), int(z'40663dc7a398201d', int64), &
                               int(z'40575bc45cbbc2b9', int64), int(z'c051a958644523f6', int64), &
                               int(z'c03a5f86c226809d', int64), int(z'4044318201cd5f9a', int64), &
                               int(z'405b235f6fd21ff3', int64), int(z'404960a42aed1394', int64), &
                               int(z'c03f7f064ece9a2c', int64), int(z'3fc05f7403dddb12', int64), &
                               int(z'3ffcd4141e9af5ba', int64), int(z'4022299213935abb', int64), &
                               int(z'4052c4bb2788db05', int64), int(z'406ed16b8f9b1316', int64), &
                               int(z'40789537c99ae925', int64), int(z'40725da51c193b3a', int64), &
                               int(z'405646e82d7b634e', int64), int(z'3f5f687b139c94f7', int64), &
                               int(z'3fc15ee136e71cda', int64), int(z'3fd49ddc1e7967cb', int64), &
                               int(z'3fd4dfc5cdd50a89', int64), int(z'3fc71e29b6b2af14', int64), &
                               int(z'3fa123810e8858ff', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64)]
  integer(int64), parameter :: radiation_words(157) = [ &
                               int(z'3fc3333333333333', int64), int(z'3fc53c1ce6c093d9', int64), &
                               int(z'3fc53c1ce6c093d9', int64), int(z'3fc53c1ce6c093d9', int64), &
                               int(z'3fd3d70a3d70a3d7', int64), int(z'3fd8f5c28f5c28f6', int64), &
                               int(z'3fd6666666666666', int64), int(z'3fdc28f5c28f5c29', int64), &
                               int(z'3fc53c1ce6c093d9', int64), int(z'3fc53c1ce6c093d9', int64), &
                               int(z'3fc53c1ce6c093d9', int64), int(z'3fc53c1ce6c093d9', int64), &
                               int(z'3fc53c1ce6c093d9', int64), int(z'3fc53c1ce6c093d9', int64), &
                               int(z'3fc53c1ce6c093d9', int64), int(z'3fc53c1ce6c093d9', int64), &
                               int(z'3fc53c1ce6c093d9', int64), int(z'3fc53c1ce6c093d9', int64), &
                               int(z'3fc53c1ce6c093d9', int64), int(z'3fd47ae147ae147b', int64), &
                               int(z'3fd47ae147ae147b', int64), int(z'3fc53c1ce6c093d9', int64), &
                               int(z'3fc177e5eaab0425', int64), int(z'3fc177e5eaab0425', int64), &
                               int(z'3fc177e5eaab0425', int64), int(z'3fceb851eb851eb8', int64), &
                               int(z'3fd147ae147ae148', int64), int(z'3fd147ae147ae148', int64), &
                               int(z'3fd51eb851eb851f', int64), int(z'3fc177e5eaab0425', int64), &
                               int(z'3fc177e5eaab0425', int64), int(z'3fc177e5eaab0425', int64), &
                               int(z'3fc177e5eaab0425', int64), int(z'3fc177e5eaab0425', int64), &
                               int(z'3fc177e5eaab0425', int64), int(z'3fc177e5eaab0425', int64), &
                               int(z'3fc177e5eaab0425', int64), int(z'3fc177e5eaab0425', int64), &
                               int(z'3fc177e5eaab0425', int64), int(z'3fc177e5eaab0425', int64), &
                               int(z'3fd0000000000000', int64), int(z'3fd0000000000000', int64), &
                               int(z'3fc177e5eaab0425', int64), int(z'3faeb851eb851eb8', int64), &
                               int(z'3d719799812dea11', int64), int(z'3fefae147ae147ae', int64), &
                               int(z'3fedc28f5c28f5c3', int64), int(z'3fedc28f5c28f5c3', int64), &
                               int(z'3fedc28f5c28f5c3', int64), int(z'3fedc28f5c28f5c3', int64), &
                               int(z'3fedc28f5c28f5c3', int64), int(z'3fedc28f5c28f5c3', int64), &
                               int(z'3fedc28f5c28f5c3', int64), int(z'3fedc28f5c28f5c3', int64), &
                               int(z'3fedc28f5c28f5c3', int64), int(z'3fedc28f5c28f5c3', int64), &
                               int(z'3fedc28f5c28f5c3', int64), int(z'3fedc28f5c28f5c3', int64), &
                               int(z'3fedc28f5c28f5c3', int64), int(z'3fedc28f5c28f5c3', int64), &
                               int(z'3fedc28f5c28f5c3', int64), int(z'3fefae147ae147ae', int64), &
                               int(z'3feeb851eb851eb8', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fefae147ae147ae', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fef5c28f5c28f5c', int64), &
                               int(z'3fef5c28f5c28f5c', int64), int(z'3fefae147ae147ae', int64), &
                               int(z'3fefae147ae147ae', int64), int(z'3fee147ae147ae14', int64), &
                               int(z'3fee147ae147ae14', int64), int(z'3fee147ae147ae14', int64), &
                               int(z'3fee147ae147ae14', int64), int(z'3fee147ae147ae14', int64), &
                               int(z'3fee147ae147ae14', int64), int(z'3fee147ae147ae14', int64), &
                               int(z'3fee147ae147ae14', int64), int(z'3fee147ae147ae14', int64), &
                               int(z'3fee147ae147ae14', int64), int(z'3fee147ae147ae14', int64), &
                               int(z'3fee147ae147ae14', int64), int(z'3fee147ae147ae14', int64), &
                               int(z'3fee147ae147ae14', int64), int(z'3fe6f41f212d7732', int64), &
                               int(z'3fd217c1bda5119d', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'3ff0000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'3ff0000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64), int(z'0000000000000000', int64), &
                               int(z'0000000000000000', int64)]
  integer(int64), parameter :: ice_words(72) = [ &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fef333333333333', int64), int(z'3fec083126e978d5', int64), &
                               int(z'3fe8e5604189374c', int64), int(z'3fe8e5604189374c', int64), &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fef333333333333', int64), int(z'3fec083126e978d5', int64), &
                               int(z'3fe8e5604189374c', int64), int(z'3fe8e5604189374c', int64), &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fef333333333333', int64), int(z'3fec083126e978d5', int64), &
                               int(z'3fe8e5604189374c', int64), int(z'3fe8e5604189374c', int64), &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fef333333333333', int64), int(z'3fef333333333333', int64), &
                               int(z'3fea9fbe76c8b439', int64), int(z'3fea9fbe76c8b439', int64), &
                               int(z'3fea9fbe76c8b439', int64), int(z'3fea9fbe76c8b439', int64), &
                               int(z'3fea9fbe76c8b439', int64), int(z'3fe46a7ef9db22d1', int64), &
                               int(z'3fdc5a1cac083127', int64), int(z'3fdc5a1cac083127', int64), &
                               int(z'3fea9fbe76c8b439', int64), int(z'3fea9fbe76c8b439', int64), &
                               int(z'3fea9fbe76c8b439', int64), int(z'3fea9fbe76c8b439', int64), &
                               int(z'3fd0000000000000', int64), int(z'3fd0000000000000', int64), &
                               int(z'3fd0000000000000', int64), int(z'3fd0000000000000', int64), &
                               int(z'3fd0000000000000', int64), int(z'3fc395810624dd2f', int64), &
                               int(z'3fac28f5c28f5c29', int64), int(z'3fac28f5c28f5c29', int64), &
                               int(z'3fd0000000000000', int64), int(z'3fd0000000000000', int64), &
                               int(z'3fd0000000000000', int64), int(z'3fd0000000000000', int64), &
                               int(z'3f9999999999999a', int64), int(z'3f9999999999999a', int64), &
                               int(z'3f9999999999999a', int64), int(z'3f9999999999999a', int64), &
                               int(z'3f9999999999999a', int64), int(z'3f9eb851eb851eb8', int64), &
                               int(z'3fa26e978d4fdf3b', int64), int(z'3fa26e978d4fdf3b', int64), &
                               int(z'3f9999999999999a', int64), int(z'3f9999999999999a', int64), &
                               int(z'3f9999999999999a', int64), int(z'3f9999999999999a', int64)]
  integer(int64), parameter :: forest_words(2) = [ &
                               int(z'3ff1b21815a07b35', int64), int(z'3fed1d29dc725c3e', int64)]
  real(real64), parameter :: input_values(57) = transfer(input_words, 0.0_real64, 57)
  real(real64), parameter :: radiation_values(157) = transfer(radiation_words, 0.0_real64, 157)
  real(real64), parameter :: ice_albedo(12, 6) = reshape(transfer(ice_words, 0.0_real64, 72), [12, 6])
  real(real64), parameter :: forest_scales(2) = transfer(forest_words, 0.0_real64, 2)
  integer(int32), parameter :: forest_indices(6) = [3, 4, 5, 6, 18, 19]
  interface
    function error_location() bind(c, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function error_location
    subroutine radiation_contract_abort() bind(c, name="abort")
    end subroutine radiation_contract_abort
  end interface
contains
  !> Set named defaults without reading or changing any numerical model state.
  !! Schemes are int32: albedo one or two and emissivity zero are supported.
  !! The caller establishes nearest-even rounding and gradual underflow once.
  !! INPUTS owns Planck coefficients, solar fractions and dimensionless switches.
  !! TSTAND is in K, and both cloud-nucleus concentrations are in 1/cm3.
  !! Return zero on success or two with INPUTS unchanged.
  integer(int32) function initialize_selected_surface_radiation_inputs(albedo_scheme, emissivity_scheme, inputs) result(status)
    integer(int32), intent(in) :: albedo_scheme, emissivity_scheme
    type(surface_radiation_inputs), intent(inout) :: inputs
    status = 2_int32
    if (albedo_scheme /= 1_int32 .and. albedo_scheme /= 2_int32) return
    if (emissivity_scheme /= 0_int32) return
    inputs%nsw = 6_int32
    inputs%ntsw = 14_int32
    inputs%nsil = 6_int32
    inputs%nlwemiss = 2_int32
    inputs%nalbedoscheme = albedo_scheme
    inputs%nemissscheme = emissivity_scheme
    inputs%lccnl = .true.
    inputs%lccno = .true.
    inputs%tstand = input_values(5)
    inputs%rccnsea = input_values(6)
    inputs%rccnlnd = input_values(7)
    inputs%xp = reshape(input_values(8:43), [6, 6])
    inputs%rsun = input_values(44:57)
    status = 0_int32
  end function initialize_selected_surface_radiation_inputs

  !> Allocate missing native shortwave owners privately in source order.
  !! Existing owners must have bounds 1:12 by 1:14, or 1:14 for RSUN.
  !! No numerical data or undefined band tail is initialized here.
  !! Return zero on success, one after allocation cleanup or two for an unsupported shape.
  integer(int32) function prepare_surface_shortwave_storage(ydsw) result(status)
    type(tsw), intent(inout) :: ydsw
    real(real64), allocatable :: new_ar(:, :), new_an(:, :), new_sun(:)
    integer(int32) :: allocation_status, saved_error
    integer(c_int), pointer :: system_error
    type(ieee_status_type) :: environment
    status = 2_int32
    if (allocated(ydsw%ralbice_ar)) then
      if (any(shape(ydsw%ralbice_ar) /= [12, 14])) return
      if (any(lbound(ydsw%ralbice_ar) /= 1)) return
    end if
    if (allocated(ydsw%ralbice_an)) then
      if (any(shape(ydsw%ralbice_an) /= [12, 14])) return
      if (any(lbound(ydsw%ralbice_an) /= 1)) return
    end if
    if (allocated(ydsw%rsun)) then
      if (size(ydsw%rsun) /= 14 .or. lbound(ydsw%rsun, 1) /= 1) return
    end if
    call c_f_pointer(error_location(), system_error)
    saved_error = system_error
    call ieee_get_status(environment)
    status = 1_int32
    allocation: block
      if (.not. allocated(ydsw%ralbice_ar)) then
        allocate (new_ar(12, 14), stat=allocation_status)
        if (allocation_status /= 0_int32) exit allocation
      end if
      if (.not. allocated(ydsw%ralbice_an)) then
        allocate (new_an(12, 14), stat=allocation_status)
        if (allocation_status /= 0_int32) exit allocation
      end if
      if (.not. allocated(ydsw%rsun)) then
        allocate (new_sun(14), stat=allocation_status)
        if (allocation_status /= 0_int32) exit allocation
      end if
      if (allocated(new_ar)) call move_alloc(new_ar, ydsw%ralbice_ar)
      if (allocated(new_an)) call move_alloc(new_an, ydsw%ralbice_an)
      if (allocated(new_sun)) call move_alloc(new_sun, ydsw%rsun)
      status = 0_int32
    end block allocation
    if (allocated(new_ar)) deallocate (new_ar)
    if (allocated(new_an)) deallocate (new_an)
    if (allocated(new_sun)) deallocate (new_sun)
    system_error = saved_error
    call ieee_set_status(environment)
  end function prepare_surface_shortwave_storage

  !> Set longwave coefficients and the consumed shortwave bands in source order.
  !! NSIL is six. TSTAND is in K, XP is the frozen real64 Planck coefficient array,
  !! and RSUN contains dimensionless solar fractions. All native owners are prepared.
  !! The eight unused bands and longwave record padding retain their incoming bytes.
  subroutine write_surface_shortwave_fields(inputs, ydlw, ydsw)
    type(surface_radiation_inputs), intent(in) :: inputs
    type(tlw), intent(inout) :: ydlw
    type(tsw), intent(inout) :: ydsw
    integer(int32) :: band, month, shifted
    ydlw%nsil = inputs%nsil
    ydlw%tstand = inputs%tstand
    do band = 1, 6
      do month = 1, 6
        ydlw%xp(month, band) = inputs%xp(month, band)
      end do
    end do
    do band = 1, 6
      ydsw%rsun(band) = inputs%rsun(band)
    end do
    do band = 1, 6
      do month = 1, 12
        shifted = modulo(month + 5_int32, 12_int32) + 1_int32
        ydsw%ralbice_ar(shifted, band) = ice_albedo(shifted, band)
        ydsw%ralbice_an(month, band) = ice_albedo(shifted, band)
      end do
    end do
  end subroutine write_surface_shortwave_fields

  !> Own the selected radiation setup with atomic allocation and publication.
  !! Native inputs and TDIM are read-only; NMONTH is twelve.
  !! TRAD stores controls, TRDI stores dimensionless albedo and emissivity,
  !! TLW stores longwave coefficients, and TSW receives three allocated owners.
  !! The caller owns all outer records and releases TSW through the matching routine.
  !! Return zero on success, one on allocation failure, or two before unsupported input changes any record.
  integer(int32) function initialize_selected_surface_radiation_parameters(inputs, yddim, ydrad, ydrdi, ydlw, ydsw) result(status)
    type(surface_radiation_inputs), target, intent(in) :: inputs
    type(tdim), target, intent(in) :: yddim
    type(trad), target, intent(inout) :: ydrad
    type(trdi), target, intent(inout) :: ydrdi
    type(tlw), target, intent(inout) :: ydlw
    type(tsw), target, intent(inout) :: ydsw
    type(tsw) :: private_sw
    type(trdi) :: private_rdi
    real(real64), volatile :: snow_albedo, uv_scale, ir_scale
    real(real64) :: uv_albedo, ir_albedo
    integer(int32) :: index, vegetation, flag, other
    integer(c_intptr_t) :: owner(2, 6)
    status = 2_int32
    if (.not. native_owner(c_loc(inputs), storage_size(inputs, kind=int64)/8_int64, owner(:, 1))) return
    if (.not. native_owner(c_loc(yddim), storage_size(yddim, kind=int64)/8_int64, owner(:, 2))) return
    if (.not. native_owner(c_loc(ydrad), storage_size(ydrad, kind=int64)/8_int64, owner(:, 3))) return
    if (.not. native_owner(c_loc(ydrdi), storage_size(ydrdi, kind=int64)/8_int64, owner(:, 4))) return
    if (.not. native_owner(c_loc(ydlw), storage_size(ydlw, kind=int64)/8_int64, owner(:, 5))) return
    if (.not. native_owner(c_loc(ydsw), storage_size(ydsw, kind=int64)/8_int64, owner(:, 6))) return
    do index = 1, 6
      do other = index + 1, 6
        if (owner(1, index) < owner(2, other) .and. owner(1, other) < owner(2, index)) return
      end do
    end do
    if (yddim%nmonth /= 12_int32) return
    if (inputs%nsw /= 6_int32 .or. inputs%ntsw /= 14_int32) return
    if (inputs%nsil /= 6_int32 .or. inputs%nlwemiss /= 2_int32) return
    if (inputs%nalbedoscheme /= 1_int32 .and. inputs%nalbedoscheme /= 2_int32) return
    if (inputs%nemissscheme /= 0_int32) return
    flag = transfer(inputs%lccnl, flag)
    if (flag /= 1_int32) return
    flag = transfer(inputs%lccno, flag)
    if (flag /= 1_int32) return
    if (allocated(ydsw%ralbice_ar) .or. allocated(ydsw%ralbice_an) .or. allocated(ydsw%rsun)) return
    status = prepare_surface_shortwave_storage(private_sw)
    if (status /= 0_int32) return

    private_rdi%ralbsfo = radiation_values(1)
    private_rdi%ralbsead = radiation_values(44)
    private_rdi%repalb = radiation_values(45)
    snow_albedo = private_rdi%ralbsfo
    uv_scale = forest_scales(1)
    ir_scale = forest_scales(2)
    uv_albedo = snow_albedo*uv_scale
    do vegetation = 0, 20
      private_rdi%ralb_snow_forest(vegetation, 1) = uv_albedo
    end do
    ir_albedo = snow_albedo*ir_scale
    do vegetation = 0, 20
      private_rdi%ralb_snow_forest(vegetation, 2) = ir_albedo
    end do
    do index = 1, 6
      vegetation = forest_indices(index)
      private_rdi%ralb_snow_forest(vegetation, 1) = radiation_values(vegetation + 2)
      private_rdi%ralb_snow_forest(vegetation, 2) = radiation_values(vegetation + 23)
    end do
    private_rdi%remiss_desert = radiation_values(46:61)
    private_rdi%remiss_land = radiation_values(62:77)
    private_rdi%remiss_snow = radiation_values(78:93)
    private_rdi%remiss_sea = radiation_values(94:109)
    private_rdi%remiss_weight = radiation_values(110:125)
    private_rdi%remiss_old_weight = reshape(radiation_values(126:157), [16, 2])

    ! Publish native fields after all three owners exist; component stores retain padding.
    ydrad%nsw = inputs%nsw
    ydrad%ntsw = inputs%ntsw
    ydrad%nuvvis = 3_int32
    ydrad%nlwemiss = inputs%nlwemiss
    ydrad%nalbedoscheme = inputs%nalbedoscheme
    ydrad%nemissscheme = inputs%nemissscheme
    ydrad%lccnl = inputs%lccnl
    ydrad%lccno = inputs%lccno
    ydrad%rccnsea = inputs%rccnsea
    ydrad%rccnlnd = inputs%rccnlnd
    ydrdi%ralbsfo = private_rdi%ralbsfo
    ydrdi%ralb_snow_forest = private_rdi%ralb_snow_forest
    ydrdi%ralbsead = private_rdi%ralbsead
    ydrdi%repalb = private_rdi%repalb
    ydrdi%remiss_desert = private_rdi%remiss_desert
    ydrdi%remiss_land = private_rdi%remiss_land
    ydrdi%remiss_snow = private_rdi%remiss_snow
    ydrdi%remiss_sea = private_rdi%remiss_sea
    ydrdi%remiss_weight = private_rdi%remiss_weight
    ydrdi%remiss_old_weight = private_rdi%remiss_old_weight
    call write_surface_shortwave_fields(inputs, ydlw, private_sw)
    call move_alloc(private_sw%ralbice_ar, ydsw%ralbice_ar)
    call move_alloc(private_sw%ralbice_an, ydsw%ralbice_an)
    call move_alloc(private_sw%rsun, ydsw%rsun)
    status = 0_int32
  end function initialize_selected_surface_radiation_parameters

  !> Bound one complete native record with the size supplied by its Fortran type.
  logical function native_owner(address, bytes, span) result(valid)
    type(c_ptr), intent(in) :: address
    integer(int64), intent(in) :: bytes
    integer(c_intptr_t), intent(out) :: span(2)
    integer(c_intptr_t) :: first
    valid = .false.
    first = transfer(address, first)
    if (first <= 0_c_intptr_t .or. bytes <= 0_int64) return
    if (first > huge(first) - bytes) return
    span = [first, first + bytes]
    valid = .true.
  end function native_owner

  !> Release the three shortwave owners in source order; repeated release is valid.
  integer(int32) function release_surface_radiation_parameters(ydsw) result(status)
    type(tsw), intent(inout) :: ydsw
    integer(c_int), pointer :: system_error
    integer(int32) :: saved_error, release_status
    type(ieee_status_type) :: environment
    call c_f_pointer(error_location(), system_error)
    saved_error = system_error
    call ieee_get_status(environment)
    status = 0_int32
    if (allocated(ydsw%ralbice_ar)) then
      deallocate (ydsw%ralbice_ar, stat=release_status)
      if (release_status /= 0_int32) status = 2_int32
    end if
    if (allocated(ydsw%ralbice_an)) then
      deallocate (ydsw%ralbice_an, stat=release_status)
      if (release_status /= 0_int32) status = 2_int32
    end if
    if (allocated(ydsw%rsun)) then
      deallocate (ydsw%rsun, stat=release_status)
      if (release_status /= 0_int32) status = 2_int32
    end if
    system_error = saved_error
    call ieee_set_status(environment)
  end function release_surface_radiation_parameters
end module surface_radiation_schemes_setup_mod

!> Retain the native eight-argument SURWN interface for both positive albedo schemes.
module surwn_schemes_mod
  use iso_fortran_env, only: int32, real64
  use yos_dim, only: tdim
  use yos_rad, only: trad
  use yos_lw, only: tlw
  use yos_sw, only: tsw
  use surface_radiation_schemes_setup_mod, only: surface_radiation_inputs, prepare_surface_shortwave_storage, &
                                                 write_surface_shortwave_fields, radiation_contract_abort
  implicit none
  private
  public :: surwn
contains
  !> Set longwave coefficients and six consumed shortwave bands in native owners.
  !! KSIL=6, NMONTH=12, NSW=6 and NTSW=14 define the selected shape.
  !! PTSTAND is in K, PXP has shape (6,6), and PRSUN has at least six solar fractions.
  !! YDLW and YDSW change; their padding and unconsumed allocated bands remain exact.
  subroutine surwn(ksil, ptstand, pxp, prsun, yddim, ydrad, ydlw, ydsw)
    integer(int32), intent(in) :: ksil
    real(real64), intent(in) :: ptstand, pxp(6, 6), prsun(:)
    type(tdim), intent(in) :: yddim
    type(trad), intent(in) :: ydrad
    type(tlw), intent(inout) :: ydlw
    type(tsw), intent(inout) :: ydsw
    type(surface_radiation_inputs) :: inputs
    integer(int32) :: status
    if (ksil /= 6_int32 .or. yddim%nmonth /= 12_int32) call radiation_contract_abort()
    if (ydrad%nsw /= 6_int32 .or. ydrad%ntsw /= 14_int32) call radiation_contract_abort()
    if (ydrad%nalbedoscheme /= 1_int32 .and. ydrad%nalbedoscheme /= 2_int32) call radiation_contract_abort()
    if (size(prsun) < 6) call radiation_contract_abort()
    inputs%nsil = ksil
    inputs%tstand = ptstand
    inputs%xp = pxp
    inputs%rsun(1:6) = prsun(1:6)
    status = prepare_surface_shortwave_storage(ydsw)
    if (status /= 0_int32) call radiation_contract_abort()
    call write_surface_shortwave_fields(inputs, ydlw, ydsw)
  end subroutine surwn
end module surwn_schemes_mod

!> Retain the native eighteen-argument SUSRAD interface for albedo schemes one and two.
module susrad_schemes_mod
  use iso_fortran_env, only: int32, real64
  use yos_dim, only: tdim
  use yos_rad, only: trad
  use yos_rdi, only: trdi
  use yos_lw, only: tlw
  use yos_sw, only: tsw
  use surface_radiation_schemes_setup_mod, only: surface_radiation_inputs, &
                                                 initialize_selected_surface_radiation_parameters, radiation_contract_abort
  implicit none
  private
  public :: susrad
contains
  !> Own the complete selected surface radiation setup through named Fortran arguments.
  !! Controls and input arrays are read-only. The four output records use native types.
  !! The atomic status-returning constructor is available to callers that need recovery.
  subroutine susrad(ksw, ksil, ktsw, klwemiss, ld_llccnl, ld_llccno, kalbedoscheme, kemissscheme, &
                    ptstand, pxp, prccnsea, prccnlnd, prsun, yddim, ydrad, ydrdi, ydlw, ydsw)
    integer(int32), intent(in) :: ksw, ksil, ktsw, klwemiss, kalbedoscheme, kemissscheme
    logical, intent(in) :: ld_llccnl, ld_llccno
    real(real64), intent(in) :: ptstand, pxp(6, 6), prccnsea, prccnlnd, prsun(:)
    type(tdim), intent(in) :: yddim
    type(trad), intent(inout) :: ydrad
    type(trdi), intent(inout) :: ydrdi
    type(tlw), intent(inout) :: ydlw
    type(tsw), intent(inout) :: ydsw
    type(surface_radiation_inputs) :: inputs
    integer(int32) :: status
    if (size(prsun) < 6) call radiation_contract_abort()
    inputs%nsw = ksw
    inputs%ntsw = ktsw
    inputs%nsil = ksil
    inputs%nlwemiss = klwemiss
    inputs%nalbedoscheme = kalbedoscheme
    inputs%nemissscheme = kemissscheme
    inputs%lccnl = ld_llccnl
    inputs%lccno = ld_llccno
    inputs%tstand = ptstand
    inputs%rccnsea = prccnsea
    inputs%rccnlnd = prccnlnd
    inputs%xp = pxp
    inputs%rsun(1:6) = prsun(1:6)
    status = initialize_selected_surface_radiation_parameters(inputs, yddim, ydrad, ydrdi, ydlw, ydsw)
    if (status /= 0_int32) call radiation_contract_abort()
  end subroutine susrad
end module susrad_schemes_mod

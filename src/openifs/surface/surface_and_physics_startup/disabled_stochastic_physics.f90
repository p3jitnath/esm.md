!> Port disabled SURAND1 arithmetic using the caller's live diffusion inputs.
module forecast_disabled_stochastic_physics
  use iso_fortran_env, only: int32, int64, real64
  use stoph_mix, only: tstoph
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: initialize_disabled_stochastic_physics
contains
  !> OUTPUT is the caller's sole STOPH record. N is spectral truncation;
  !! rows is the global latitude count. HDIRVOR and TDT use seconds and
  !! radius uses metres. LSPECVIS is the actual diffusion producer's flag.
  !! Native callers establish nearest-even and gradual underflow. All
  !! unused STOPH members and owners retain their incoming values.
integer(int32) function initialize_disabled_stochastic_physics(output, n, rows, lspecvis, hdirvor, tdt, radius, text) result(status)
    type(tstoph), intent(inout) :: output
    integer(int32), intent(in) :: n, rows
    logical, intent(in) :: lspecvis
    real(real64), intent(in) :: hdirvor, tdt, radius
    character(*), intent(in) :: text
    integer(int32) :: j, k, product
    integer(int32), volatile :: longitude_count, latitude_count
    real(real64) :: value, angle, z, scaled, radius_squared, degree, quotient, squared
    status = 2
    if (n < 1 .or. n > 4096 .or. rows < 1 .or. rows > 8192) return
    if (.not. finite(hdirvor) .or. .not. finite(tdt) .or. .not. finite(radius)) return
    if (abs(tdt) > 1000000.0_real64 .or. radius < 1.0_real64 .or. radius > 1.0e9_real64) return
    status = require_empty_physics_group(text, 'NAMSTOPH')
    if (status /= 0) return
    output%nforcestart = 0_int32
    output%nforceend = 240_int32
    output%nfrstoph_spbs = 4_int32
    output%nfrstoph_spbs_pat = 4_int32
    output%nstochopt = 2_int32
    output%nfrstoph_vc = 2_int32
    output%lforcenl = .false.
    output%lextrafields = .false.
    output%lstoph_spbs = .false.
    output%lstoph_jbcor = .false.
    output%lstoph_uncorr = .false.
    output%lstoph_uniform = .false.
    output%lstoph_rvp = .true.
    output%lstoph_rvpold = .false.
    output%lstoph_taper = .true.
    output%lstoph_ini = .true.
    output%lstoph_varalpha = .false.
    output%lstoph_spbs_fast = .true.
    output%lstoph_spbs_vort = .false.
    output%lstoph_gauss = .true.
    output%lspbs_dissnum = .true.
    output%lspbs_dissnum_ct = .false.
    output%lspbs_disscu = .true.
    output%lspbs_dissgw = .false.
    output%lspbsnorm = .true.
    output%lspbsdiss = .true.
    output%lstoph_spbs_t = .false.
    output%lstoph_casbs = .false.
    output%lvortcon = .false.
    output%rexponent = transfer(int(z'BFF451EB851EB852', int64), 0.0_real64)
    output%ratio_backscat = transfer(int(z'3FB851EB851EB852', int64), 0.0_real64)
    output%ratio_backscat_con2num = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%rflux_det_clip = transfer(int(z'3F747AE147AE147B', int64), 0.0_real64)
    output%rspbs_tau = transfer(int(z'40D86A0000000000', int64), 0.0_real64)
    output%ratio_ape2ke = transfer(int(z'3FC99999A0000000', int64), 0.0_real64)
    output%rvp_mulmin = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rvp_mulmax = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%rvp_mulexp = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%rvp_mulnsmax = transfer(int(z'406FE00000000000', int64), 0.0_real64)
    output%rvp_mul_a = transfer(int(z'3FFAF905A55B6EBC', int64), 0.0_real64)
    output%rvp_mul_b = transfer(int(z'BF0F746BB80C01E0', int64), 0.0_real64)
    output%rvp_mul_c = transfer(int(z'3E1304F160000000', int64), 0.0_real64)
    output%rvp_mul_d = transfer(int(z'BCFD4EDF40000000', int64), 0.0_real64)
    output%rvp_mul_1 = transfer(int(z'403204EA4A8C154D', int64), 0.0_real64)
    output%rvp_mul_2 = transfer(int(z'BFCBA29C779A6B51', int64), 0.0_real64)
    output%rvp_mulmin_t = transfer(int(z'0000000000000000', int64), 0.0_real64)
    output%rvp_mulmax_t = transfer(int(z'3FF0000000000000', int64), 0.0_real64)
    output%rvp_mulexp_t = transfer(int(z'3FB999999999999A', int64), 0.0_real64)
    output%rvp_mulnsmax_t = transfer(int(z'406FE00000000000', int64), 0.0_real64)
    output%rvp_mul_a_t = transfer(int(z'3FFAF905A55B6EBC', int64), 0.0_real64)
    output%rvp_mul_b_t = transfer(int(z'BF0F746BB80C01E0', int64), 0.0_real64)
    output%rvp_mul_c_t = transfer(int(z'3E1304F160000000', int64), 0.0_real64)
    output%rvp_mul_d_t = transfer(int(z'BCFD4EDF40000000', int64), 0.0_real64)
    output%rvp_mul_1_t = transfer(int(z'40251F212D773190', int64), 0.0_real64)
    output%rvp_mul_2_t = transfer(int(z'BFD2F0068DB8BAC7', int64), 0.0_real64)
    output%amagstoph_casbs = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%sldissfac = transfer(int(z'4008000000000000', int64), 0.0_real64)
    output%rsmoothscale = transfer(int(z'41155CC000000000', int64), 0.0_real64)
    output%vc_con = transfer(int(z'3FD3333333333333', int64), 0.0_real64)
    output%rexponent_t = transfer(int(z'BFF451EB851EB852', int64), 0.0_real64)
    output%rsigma2_eps = transfer(int(z'3FC5555555555555', int64), 0.0_real64)
    output%alpha_deep_conv = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%alpha_shal_conv = transfer(int(z'4000000000000000', int64), 0.0_real64)
    output%nsmaxspbs = min(159_int32, n)
    value = real(n, real64)*90.0_real64
    value = value/159.0_real64
    j = nint(value, int32)
    angle = 180.0_real64/real(j, real64)
    output%adlatstoph_ca = angle
    output%adlonstoph_ca = angle
    value = 360.0_real64/angle
    longitude_count = nint(value, int32)
    value = 180.0_real64/angle
    latitude_count = nint(value, int32)
    if (lspecvis) then
      z = 0.0_real64
      output%lspbs_dissnum = .false.
    else
      value = max(hdirvor, transfer(int(z'3EB0C6F7A0B5ED8D', int64), 0.0_real64))
      z = tdt/value
    end if
    scaled = z*3.0_real64
    radius_squared = radius*radius
    k = n
    if (rows > n + 1) k = rows - 1
    product = k*(k + 1)
    degree = real(product, real64)
    quotient = radius_squared/degree
    squared = quotient*quotient
    output%biharm = scaled*squared
    status = 0
  end function
  logical function finite(value)
    real(real64), intent(in) :: value
    finite = iand(transfer(value, 0_int64), int(z'7FF0000000000000', int64)) /= int(z'7FF0000000000000', int64)
  end function
end module

module susurb_mod
  use iso_fortran_env, only: int32, real64
  use iso_c_binding, only: c_int, c_double, c_ptr, c_f_pointer
  use yos_urb, only: turb
  implicit none
  private
  public :: susurb
  interface
    function selected_log(value) bind(c, name="log") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_log
    function selected_exp(value) bind(c, name="exp") result(answer)
      import c_double
      real(c_double), value :: value
      real(c_double) :: answer
    end function selected_exp
    function selected_pow(value, power) bind(c, name="pow") result(answer)
      import c_double
      real(c_double), value :: value, power
      real(c_double) :: answer
    end function selected_pow
    function errno_location() bind(c, name="__errno_location") result(pointer)
      import c_ptr
      type(c_ptr) :: pointer
    end function errno_location
  end interface
  real(real64), parameter :: c_one = 1.0_real64
  real(real64), parameter :: c_two = 2.0_real64
  real(real64), parameter :: c_three = 3.0_real64
  real(real64), parameter :: c_four = 4.0_real64
  real(real64), parameter :: c_half = 0.5_real64
  real(real64), parameter :: c_minus_half = -0.5_real64
  real(real64), parameter :: c_tenth = 0.1_real64
  real(real64), parameter :: c_onehalf = 1.5_real64
  real(real64), parameter :: c_onequarter = 1.25_real64
  real(real64), parameter :: c_thousandth = 0.001_real64
  real(real64), parameter :: c_tiny = 1e-07_real64
  real(real64), parameter :: c_disp = 1.4_real64
  real(real64), parameter :: c_modw = 10.0_real64
  real(real64), parameter :: c_roofheight = 1.1_real64
  real(real64), parameter :: c_heat_level = 1e-05_real64
  real(real64), parameter :: c_air_cp = 1005.0_real64
  real(real64), parameter :: c_atan_one = 0.7853981633974483_real64
contains
  !> Set the fixed-geometry urban material and exchange parameters.
  !!
  !! YDURB is a native TURB value. Height and roughness use metres, density
  !! uses kg m^-3, heat capacity per volume uses J m^-3 K^-1, and thermal
  !! conductivity uses W m^-1 K^-1. Emissivity and view factors have no units.
  !! RCANALB, LURBAN and LURBUI retain their incoming values.
  !!
  !! The source RSBCONS value is 5.67E+08 although its stated radiation units
  !! need approximately 5.67E-08. This known source defect remains explicit;
  !! it is not corrected or counted as an independently valid coefficient.
  !! Numbered scalar intermediates below retain each separate rounded
  !! calculation from the frozen source. They are not machine registers.
  subroutine susurb(ydurb)
    type(turb), intent(inout) :: ydurb
    type(turb) :: work
    real(real64) :: exchange(3, 3), inverse_exchange(3, 3), factor, first, second, third, aa, bb, cc, dd, determinant, &
                    inverse_determinant
    integer(int32) :: row, column
    integer(c_int), pointer :: incoming_errno
    integer(c_int) :: saved_errno
    real(real64) :: source_can_road, source_can_wall, source_d_h, source_exp_slope, source_fdr
    real(real64) :: source_fdw, source_fur, source_fuw, source_hrh, source_l_dow
    real(real64) :: source_l_rec, source_l_slo, source_logh, source_logmod, source_logmodsq
    real(real64) :: source_logzref, source_low, source_lrw, source_lttw, source_ltw
    real(real64) :: source_one_exp, source_pi, source_r3, source_r4, source_r5
    real(real64) :: source_r6, source_r7, source_r8, source_r_bulk, source_r_recirc
    real(real64) :: source_r_venti, source_sc_hwr, source_swi, source_temp, source_uct
    real(real64) :: source_width, source_widthhalf, source_z0x, source_zref, rounded_0001
    real(real64) :: rounded_0002, rounded_0003, rounded_0004, rounded_0005, rounded_0006
    real(real64) :: rounded_0007, rounded_0008, rounded_0009, rounded_0010, rounded_0011
    real(real64) :: rounded_0012, rounded_0013, rounded_0014, rounded_0015, rounded_0016
    real(real64) :: rounded_0017, rounded_0018, rounded_0019, rounded_0020, rounded_0021
    real(real64) :: rounded_0022, rounded_0023, rounded_0024, rounded_0025, rounded_0026
    real(real64) :: rounded_0027, rounded_0028, rounded_0029, rounded_0030, rounded_0031
    real(real64) :: rounded_0032, rounded_0033, rounded_0034, rounded_0035, rounded_0036
    real(real64) :: rounded_0037, rounded_0038, rounded_0039, rounded_0040, rounded_0041
    real(real64) :: rounded_0042, rounded_0043, rounded_0044, rounded_0045, rounded_0046
    real(real64) :: rounded_0047, rounded_0048, rounded_0049, rounded_0050, rounded_0051
    real(real64) :: rounded_0052, rounded_0053, rounded_0054, rounded_0055, rounded_0056
    real(real64) :: rounded_0057, rounded_0058, rounded_0059, rounded_0060, rounded_0061
    real(real64) :: rounded_0062, rounded_0063, rounded_0064, rounded_0065, rounded_0066
    real(real64) :: rounded_0067, rounded_0068, rounded_0069, rounded_0070, rounded_0071
    real(real64) :: rounded_0072, rounded_0073, rounded_0074, rounded_0075, rounded_0076
    real(real64) :: rounded_0077, rounded_0078, rounded_0079, rounded_0080, rounded_0081
    real(real64) :: rounded_0082, rounded_0083, rounded_0084, rounded_0085, rounded_0086
    real(real64) :: rounded_0087, rounded_0088, rounded_0089, rounded_0090, rounded_0091
    real(real64) :: rounded_0092, rounded_0093, rounded_0094, rounded_0095, rounded_0096
    real(real64) :: rounded_0097, rounded_0098, rounded_0099, rounded_0100, rounded_0101
    real(real64) :: rounded_0102, rounded_0103, rounded_0104, rounded_0105, rounded_0106
    real(real64) :: rounded_0107, rounded_0108, rounded_0109, rounded_0110, rounded_0111
    real(real64) :: rounded_0112, rounded_0113, rounded_0114, rounded_0115, rounded_0116
    real(real64) :: rounded_0117, rounded_0118, rounded_0119, rounded_0120, rounded_0121
    real(real64) :: rounded_0122, rounded_0123, rounded_0124, rounded_0125, rounded_0126
    real(real64) :: rounded_0127, rounded_0128, rounded_0129, rounded_0130, rounded_0131
    real(real64) :: rounded_0132, rounded_0133, rounded_0134, rounded_0135, rounded_0136
    real(real64) :: rounded_0137, rounded_0138, rounded_0139, rounded_0140, rounded_0141
    real(real64) :: rounded_0142, rounded_0143, rounded_0144, rounded_0145, rounded_0146
    real(real64) :: rounded_0147, rounded_0148, rounded_0149, rounded_0150, rounded_0151
    real(real64) :: rounded_0152, rounded_0153, rounded_0154, rounded_0155, rounded_0156
    real(real64) :: rounded_0157, rounded_0158, rounded_0159, rounded_0160, rounded_0161
    real(real64) :: rounded_0162, rounded_0163, rounded_0164, rounded_0165, rounded_0166
    real(real64) :: rounded_0167, rounded_0168, rounded_0169, rounded_0170, rounded_0171
    real(real64) :: rounded_0172, rounded_0173, rounded_0174, rounded_0175, rounded_0176
    real(real64) :: rounded_0177, rounded_0178, rounded_0179, rounded_0180, rounded_0181
    real(real64) :: rounded_0182, rounded_0183, rounded_0184, rounded_0185, rounded_0186
    real(real64) :: rounded_0187, rounded_0188, rounded_0189, rounded_0190, rounded_0191
    real(real64) :: rounded_0192, rounded_0193, rounded_0194, rounded_0195, rounded_0196
    real(real64) :: rounded_0197, rounded_0198, rounded_0199, rounded_0200, rounded_0201
    real(real64) :: rounded_0202, rounded_0203, rounded_0204, rounded_0205, rounded_0206
    real(real64) :: rounded_0207, rounded_0208, rounded_0209, rounded_0210, rounded_0211
    real(real64) :: rounded_0212, rounded_0213, rounded_0214, rounded_0215, rounded_0216
    real(real64) :: rounded_0217, rounded_0218, rounded_0219, rounded_0220, rounded_0221
    real(real64) :: rounded_0222, rounded_0223, rounded_0224, rounded_0225, rounded_0226
    real(real64) :: rounded_0227, rounded_0228, rounded_0229, rounded_0230, rounded_0231
    real(real64) :: rounded_0232, rounded_0233, rounded_0234, rounded_0235, rounded_0236
    real(real64) :: rounded_0237, rounded_0238, rounded_0239, rounded_0240, rounded_0241
    real(real64) :: rounded_0242, rounded_0243, rounded_0244, rounded_0245, rounded_0246
    real(real64) :: rounded_0247, rounded_0248, rounded_0249, rounded_0250, rounded_0251
    real(real64) :: rounded_0252, rounded_0253, rounded_0254, rounded_0255, rounded_0256
    real(real64) :: rounded_0257, rounded_0258, rounded_0259, rounded_0260, rounded_0261
    real(real64) :: rounded_0262, rounded_0263, rounded_0264, rounded_0265, rounded_0266
    real(real64) :: rounded_0267, rounded_0268, rounded_0269, rounded_0270, rounded_0271
    real(real64) :: rounded_0272, rounded_0273, rounded_0274, rounded_0275, rounded_0276
    real(real64) :: rounded_0277, rounded_0278, rounded_0279, rounded_0280, rounded_0281
    real(real64) :: rounded_0282, rounded_0283, rounded_0284, rounded_0285, rounded_0286
    real(real64) :: rounded_0287, rounded_0288, rounded_0289, rounded_0290, rounded_0291
    real(real64) :: rounded_0292, rounded_0293, rounded_0294, rounded_0295, rounded_0296
    real(real64) :: rounded_0297, rounded_0298, rounded_0299, rounded_0300, rounded_0301
    real(real64) :: rounded_0302, rounded_0303, rounded_0304, rounded_0305, rounded_0306
    real(real64) :: rounded_0307, rounded_0308, rounded_0309, rounded_0310, rounded_0311
    real(real64) :: rounded_0312, rounded_0313, rounded_0314, rounded_0315, rounded_0316
    real(real64) :: rounded_0317, rounded_0318, rounded_0319, rounded_0320, rounded_0321
    real(real64) :: rounded_0322, rounded_0323, rounded_0324, rounded_0325, rounded_0326
    real(real64) :: rounded_0327, rounded_0328, rounded_0329, rounded_0330, rounded_0331
    real(real64) :: rounded_0332, rounded_0333, rounded_0334, rounded_0335, rounded_0336
    call c_f_pointer(errno_location(), incoming_errno)
    saved_errno = incoming_errno
    work = ydurb
    work%rcdg = 1.2_real64
    work%rcda = 4.43_real64
    work%rchis = 0.3_real64
    work%rsbcons = 567000000.0_real64
    work%rgacc = 9.81_real64
    work%rvksq = 0.16_real64
    work%rexpdr = 0.15_real64
    work%rbuiz0m = 0.005_real64
    work%rwalthk = 0.15_real64
    work%rroothk = 0.15_real64
    work%rroathk = 0.15_real64
    work%rwalalb = 0.6_real64
    work%rrooalb = 0.16_real64
    work%rroaalb = 0.05_real64
    work%rwalemis = 0.96_real64
    work%rrooemis = 0.96_real64
    work%rroaemis = 0.99_real64
    work%rwalvhc = 3000000.0_real64
    work%rroovhc = 2000000.0_real64
    work%rroavhc = 3000000.0_real64
    work%rwaltc = 20.0_real64
    work%rrootc = 10.0_real64
    work%rroatc = 20.0_real64
    work%rhgt = 8.0_real64
    work%rhwr = 0.5_real64
    work%rwrr = 0.5_real64
    work%rsoiemis = 0.95_real64
    work%rsoitmp = 280.0_real64
    work%rsoitc = 0.22_real64
    work%rsatsh = 0.0_real64
    work%rmodz = 10.0_real64
    work%rairrho = 1.225_real64
    work%rurbalp = 0.765_real64
    work%rurbcon = 6.67e-13_real64
    work%rurblam = 35.2_real64
    work%rurbsat = 0.15_real64
    work%rurbsres = 0.001_real64
    work%rairvhc = work%rairrho*c_air_cp
    first = work%rhwr*work%rhwr
    first = c_one + first
    first = sqrt(first)
    aa = first - work%rhwr
    first = c_one/work%rhwr
    second = first*first
    second = c_one + second
    second = sqrt(second)
    bb = second - first
    cc = c_one - aa
    dd = c_one - bb
    dd = dd/c_two
    exchange(1, 1) = 0.0_real64
    exchange(3, 3) = 0.0_real64
    exchange(1, 2) = cc
    exchange(3, 2) = cc
    exchange(1, 3) = aa
    exchange(3, 1) = aa
    exchange(2, 1) = dd
    exchange(2, 3) = dd
    exchange(2, 2) = bb
    do column = 1, 3
      factor = c_one - work%rroaemis
      exchange(1, column) = exchange(1, column)*factor
      factor = c_one - work%rwalemis
      exchange(2, column) = exchange(2, column)*factor
      exchange(3, column) = 0.0_real64
    end do
    do column = 1, 3
      do row = 1, 3
        first = 0.0_real64
        if (row == column) first = c_one
        exchange(row, column) = first - exchange(row, column)
      end do
    end do
    first = exchange(1, 1)*exchange(2, 2)
    first = first*exchange(3, 3)
    determinant = first
    first = exchange(1, 1)*exchange(2, 3)
    first = first*exchange(3, 2)
    determinant = determinant - first
    first = exchange(1, 2)*exchange(2, 1)
    first = first*exchange(3, 3)
    determinant = determinant - first
    first = exchange(1, 2)*exchange(2, 3)
    first = first*exchange(3, 1)
    determinant = determinant + first
    first = exchange(1, 3)*exchange(2, 1)
    first = first*exchange(3, 2)
    determinant = determinant + first
    first = exchange(1, 3)*exchange(2, 2)
    first = first*exchange(3, 1)
    determinant = determinant - first
    inverse_determinant = c_one/determinant
    first = exchange(2, 2)*exchange(3, 3)
    second = exchange(2, 3)*exchange(3, 2)
    first = first - second
    factor = inverse_determinant
    inverse_exchange(1, 1) = factor*first
    first = exchange(2, 1)*exchange(3, 3)
    second = exchange(2, 3)*exchange(3, 1)
    first = first - second
    factor = -inverse_determinant
    inverse_exchange(2, 1) = factor*first
    first = exchange(2, 1)*exchange(3, 2)
    second = exchange(2, 2)*exchange(3, 1)
    first = first - second
    factor = inverse_determinant
    inverse_exchange(3, 1) = factor*first
    first = exchange(1, 2)*exchange(3, 3)
    second = exchange(1, 3)*exchange(3, 2)
    first = first - second
    factor = -inverse_determinant
    inverse_exchange(1, 2) = factor*first
    first = exchange(1, 1)*exchange(3, 3)
    second = exchange(1, 3)*exchange(3, 1)
    first = first - second
    factor = inverse_determinant
    inverse_exchange(2, 2) = factor*first
    first = exchange(1, 1)*exchange(3, 2)
    second = exchange(1, 2)*exchange(3, 1)
    first = first - second
    factor = -inverse_determinant
    inverse_exchange(3, 2) = factor*first
    first = exchange(1, 2)*exchange(2, 3)
    second = exchange(1, 3)*exchange(2, 2)
    first = first - second
    factor = inverse_determinant
    inverse_exchange(1, 3) = factor*first
    first = exchange(1, 1)*exchange(2, 3)
    second = exchange(1, 3)*exchange(2, 1)
    first = first - second
    factor = -inverse_determinant
    inverse_exchange(2, 3) = factor*first
    first = exchange(1, 1)*exchange(2, 2)
    second = exchange(1, 2)*exchange(2, 1)
    first = first - second
    factor = inverse_determinant
    inverse_exchange(3, 3) = factor*first
    rounded_0001 = c_one - work%rroaemis
    rounded_0002 = work%rroaemis/rounded_0001
    rounded_0003 = rounded_0002*inverse_exchange(1, 3)
    source_temp = rounded_0003
    rounded_0004 = c_two*work%rhwr
    rounded_0005 = c_one - work%rwalemis
    rounded_0006 = work%rwalemis/rounded_0005
    rounded_0007 = rounded_0004*rounded_0006
    rounded_0008 = rounded_0007*inverse_exchange(2, 3)
    rounded_0009 = source_temp + rounded_0008
    work%rcanemis = rounded_0009
    rounded_0010 = c_one + work%rwrr
    rounded_0011 = c_one/rounded_0010
    rounded_0012 = work%rrooemis*rounded_0011
    rounded_0013 = work%rwrr/rounded_0010
    rounded_0014 = work%rcanemis*rounded_0013
    rounded_0015 = rounded_0012 + rounded_0014
    work%rurbemis = rounded_0015
    ! The fixed source geometry enters the wake-interference regime.
    rounded_0016 = work%rhwr/c_two
    rounded_0017 = rounded_0016*c_atan_one
    rounded_0018 = c_half*rounded_0017
    source_sc_hwr = rounded_0018
    rounded_0019 = work%rwrr - c_one
    rounded_0020 = selected_pow(work%rcda, rounded_0019)
    rounded_0021 = work%rwrr*rounded_0020
    rounded_0022 = c_one - rounded_0021
    rounded_0023 = max(rounded_0022, 0.0_real64)
    source_d_h = rounded_0023
    rounded_0024 = work%rhgt/work%rhwr
    source_width = rounded_0024
    rounded_0025 = c_tenth*work%rbuiz0m
    source_z0x = rounded_0025
    rounded_0026 = c_one - source_d_h
    rounded_0027 = work%rcdg*rounded_0026
    rounded_0028 = rounded_0027*source_sc_hwr
    rounded_0029 = rounded_0028*work%rwrr
    rounded_0030 = rounded_0029/work%rvksq
    rounded_0031 = selected_pow(rounded_0030, c_minus_half)
    rounded_0032 = -rounded_0031
    rounded_0033 = selected_exp(rounded_0032)
    rounded_0034 = c_one - source_d_h
    rounded_0035 = rounded_0034*rounded_0033
    rounded_0036 = rounded_0035*work%rhgt
    rounded_0037 = max(rounded_0036, work%rbuiz0m)
    work%rcanztm = rounded_0037
    rounded_0038 = c_four*c_atan_one
    source_pi = rounded_0038
    rounded_0039 = c_tenth*work%rhgt
    source_zref = rounded_0039
    rounded_0040 = c_three*work%rhgt
    source_l_rec = rounded_0040
    rounded_0041 = c_two*work%rhwr
    rounded_0042 = rounded_0041/source_pi
    rounded_0043 = c_three*rounded_0042
    source_lrw = rounded_0043
    rounded_0044 = c_onehalf*rounded_0042
    source_ltw = rounded_0044
    rounded_0045 = source_lrw - c_one
    rounded_0046 = source_lrw - rounded_0044
    rounded_0047 = rounded_0045/rounded_0046
    rounded_0048 = max(rounded_0047, 0.0_real64)
    rounded_0049 = min(rounded_0048, c_one)
    source_hrh = rounded_0049
    rounded_0050 = min(source_lrw, c_one)
    source_lrw = rounded_0050
    rounded_0051 = min(source_ltw, c_one)
    source_ltw = rounded_0051
    rounded_0052 = rounded_0050 - rounded_0051
    rounded_0053 = rounded_0052*rounded_0052
    rounded_0054 = work%rhwr*work%rhwr
    rounded_0055 = rounded_0053 + rounded_0054
    rounded_0056 = sqrt(rounded_0055)
    rounded_0057 = c_one - source_hrh
    rounded_0058 = rounded_0057*rounded_0056
    rounded_0059 = source_lrw + rounded_0058
    source_lttw = rounded_0059
    rounded_0060 = work%rhgt - c_disp
    rounded_0061 = max(rounded_0060, work%rcanztm)
    source_swi = rounded_0061
    rounded_0062 = rounded_0061/work%rcanztm
    rounded_0063 = selected_log(rounded_0062)
    source_temp = rounded_0063
    rounded_0064 = c_modw/work%rcanztm
    rounded_0065 = rounded_0064 + c_one
    rounded_0066 = selected_log(rounded_0065)
    source_logmod = rounded_0066
    rounded_0067 = c_two/source_pi
    rounded_0068 = rounded_0067*source_temp
    rounded_0069 = rounded_0068/rounded_0066
    rounded_0070 = max(rounded_0069, c_tenth)
    source_uct = rounded_0070
    ! Source l_slo and l_dow for RHWR=onehalf.
    rounded_0071 = source_l_rec/c_two
    rounded_0072 = source_width - rounded_0071
    source_widthhalf = rounded_0072
    rounded_0073 = rounded_0072*rounded_0072
    rounded_0074 = c_two*work%rhgt
    rounded_0075 = rounded_0074/source_l_rec
    rounded_0076 = rounded_0075*rounded_0075
    rounded_0077 = rounded_0076 + c_one
    rounded_0078 = rounded_0073*rounded_0077
    rounded_0079 = sqrt(rounded_0078)
    rounded_0080 = c_onequarter*rounded_0079
    source_l_slo = rounded_0080
    rounded_0081 = c_two*source_widthhalf
    rounded_0082 = rounded_0081*work%rhgt
    rounded_0083 = rounded_0082/source_l_rec
    source_l_dow = rounded_0083
    ! Fixed l_dow differs from RHGT, so the source equality adjustment is inactive.
    rounded_0084 = -work%rcda
    rounded_0085 = selected_exp(rounded_0084)
    rounded_0086 = c_one - rounded_0085
    source_one_exp = rounded_0086
    rounded_0087 = work%rhgt/work%rbuiz0m
    rounded_0088 = selected_log(rounded_0087)
    source_logh = rounded_0088
    rounded_0089 = source_zref/work%rbuiz0m
    rounded_0090 = selected_log(rounded_0089)
    source_logzref = rounded_0090
    ! Upstream road flow.
    rounded_0091 = source_l_slo + work%rhgt
    rounded_0092 = rounded_0091 - source_l_dow
    rounded_0093 = -work%rcda
    rounded_0094 = rounded_0093*rounded_0092
    rounded_0095 = rounded_0094/work%rhgt
    rounded_0096 = selected_exp(rounded_0095)
    rounded_0097 = source_uct*work%rhgt
    rounded_0098 = rounded_0097*rounded_0096
    source_temp = rounded_0098
    rounded_0099 = -work%rcda
    rounded_0100 = rounded_0099*source_width
    rounded_0101 = rounded_0100/work%rhwr
    rounded_0102 = selected_exp(rounded_0101)
    rounded_0103 = c_one - rounded_0102
    rounded_0104 = source_temp*rounded_0103
    rounded_0105 = work%rcda*source_width
    rounded_0106 = rounded_0104/rounded_0105
    source_fur = rounded_0106
    ! Upstream wall flow.
    rounded_0107 = source_l_slo + work%rhgt
    rounded_0108 = rounded_0107 - source_l_dow
    rounded_0109 = rounded_0108 + source_width
    rounded_0110 = -work%rcda
    rounded_0111 = rounded_0110*rounded_0109
    rounded_0112 = rounded_0111/work%rhgt
    rounded_0113 = selected_exp(rounded_0112)
    rounded_0114 = source_uct*rounded_0113
    rounded_0115 = rounded_0114*source_one_exp
    rounded_0116 = rounded_0115/work%rcda
    source_fuw = rounded_0116
    ! Downstream wall flow and its lower bound.
    rounded_0117 = -work%rcda
    rounded_0118 = rounded_0117*source_l_slo
    rounded_0119 = rounded_0118/work%rhgt
    rounded_0120 = selected_exp(rounded_0119)
    source_exp_slope = rounded_0120
    rounded_0121 = source_uct*work%rhgt
    rounded_0122 = rounded_0121*rounded_0120
    source_temp = rounded_0122
    rounded_0123 = -work%rcda
    rounded_0124 = rounded_0123*source_l_dow
    rounded_0125 = rounded_0124/work%rhgt
    rounded_0126 = selected_exp(rounded_0125)
    rounded_0127 = c_one - rounded_0126
    rounded_0128 = source_temp*rounded_0127
    rounded_0129 = work%rcda*source_l_dow
    rounded_0130 = rounded_0128/rounded_0129
    source_fdw = rounded_0130
    rounded_0131 = work%rhgt - source_l_dow
    rounded_0132 = max(rounded_0131, work%rbuiz0m)
    source_low = rounded_0132
    rounded_0133 = rounded_0132/work%rbuiz0m
    rounded_0134 = selected_log(rounded_0133)
    source_temp = rounded_0134
    rounded_0135 = work%rhgt/source_l_dow
    rounded_0136 = c_one/source_logh
    rounded_0137 = rounded_0135 - rounded_0136
    rounded_0138 = work%rhgt - source_l_dow
    rounded_0139 = rounded_0138*source_temp
    rounded_0140 = source_l_dow*source_logh
    rounded_0141 = rounded_0139/rounded_0140
    rounded_0142 = rounded_0137 - rounded_0141
    rounded_0143 = source_uct*rounded_0142
    rounded_0144 = max(source_fdw, rounded_0143)
    source_fdw = rounded_0144
    ! The source downstream road flow is a component of final wall transport.
    rounded_0145 = work%rhgt - source_l_dow
    rounded_0146 = -work%rcda
    rounded_0147 = rounded_0146*rounded_0145
    rounded_0148 = rounded_0147/work%rhgt
    rounded_0149 = selected_exp(rounded_0148)
    rounded_0150 = c_one - rounded_0149
    rounded_0151 = work%rhgt*source_exp_slope
    rounded_0152 = rounded_0151*rounded_0150
    rounded_0153 = rounded_0152*source_uct
    rounded_0154 = work%rhgt - source_l_dow
    rounded_0155 = work%rcda*rounded_0154
    rounded_0156 = rounded_0153/rounded_0155
    source_fdr = rounded_0156
    rounded_0157 = source_l_dow*source_fdw
    rounded_0158 = work%rhgt - source_l_dow
    rounded_0159 = rounded_0158*rounded_0156
    rounded_0160 = rounded_0157 + rounded_0159
    rounded_0161 = rounded_0160/work%rhgt
    source_fdw = rounded_0161
    ! Tangential road and wall transport.
    rounded_0162 = source_uct*source_logzref
    rounded_0163 = rounded_0162/source_logh
    source_can_road = rounded_0163
    rounded_0164 = work%rbuiz0m/work%rhgt
    rounded_0165 = c_one - rounded_0164
    rounded_0166 = c_one/rounded_0165
    rounded_0167 = c_one/source_logh
    rounded_0168 = rounded_0166 - rounded_0167
    rounded_0169 = source_uct*rounded_0168
    source_can_wall = rounded_0169
    rounded_0170 = source_fur*source_fur
    rounded_0171 = source_can_road*source_can_road
    rounded_0172 = rounded_0170 + rounded_0171
    rounded_0173 = sqrt(rounded_0172)
    source_fur = rounded_0173
    rounded_0174 = source_fdr*source_fdr
    rounded_0175 = source_can_road*source_can_road
    rounded_0176 = rounded_0174 + rounded_0175
    rounded_0177 = sqrt(rounded_0176)
    source_fdr = rounded_0177
    rounded_0178 = source_fuw*source_fuw
    rounded_0179 = source_can_wall*source_can_wall
    rounded_0180 = rounded_0178 + rounded_0179
    rounded_0181 = sqrt(rounded_0180)
    source_fuw = rounded_0181
    rounded_0182 = source_fdw*source_fdw
    rounded_0183 = source_can_wall*source_can_wall
    rounded_0184 = rounded_0182 + rounded_0183
    rounded_0185 = sqrt(rounded_0184)
    source_fdw = rounded_0185
    rounded_0186 = source_zref/source_z0x
    rounded_0187 = selected_log(rounded_0186)
    rounded_0188 = source_logzref*rounded_0187
    source_low = rounded_0188
    rounded_0189 = work%rvksq*source_fuw
    rounded_0190 = source_low/rounded_0189
    source_r3 = rounded_0190
    rounded_0191 = work%rvksq*source_fur
    rounded_0192 = source_low/rounded_0191
    source_r4 = rounded_0192
    rounded_0193 = work%rvksq*source_fdr
    rounded_0194 = source_low/rounded_0193
    source_r6 = rounded_0194
    rounded_0195 = work%rvksq*source_fdw
    rounded_0196 = source_low/rounded_0195
    source_r8 = rounded_0196
    rounded_0197 = sqrt(work%rvksq)
    rounded_0198 = source_logmod/rounded_0197
    rounded_0199 = rounded_0198*rounded_0198
    source_logmodsq = rounded_0199
    rounded_0200 = c_one - source_fur
    rounded_0201 = rounded_0200*source_logmodsq
    rounded_0202 = c_one + source_lttw
    rounded_0203 = rounded_0202 - source_ltw
    rounded_0204 = rounded_0201/rounded_0203
    source_r5 = rounded_0204
    rounded_0205 = c_one - source_fdw
    rounded_0206 = rounded_0205*source_logmodsq
    source_r7 = rounded_0206
    rounded_0207 = source_r3/work%rhwr
    source_r3 = rounded_0207
    rounded_0208 = min(source_l_rec, source_width)
    rounded_0209 = rounded_0208/source_width
    rounded_0210 = source_r4/rounded_0209
    source_r4 = rounded_0210
    rounded_0211 = source_l_rec/c_two
    rounded_0212 = min(rounded_0211, source_width)
    rounded_0213 = rounded_0212/source_width
    rounded_0214 = source_r5/rounded_0213
    source_r5 = rounded_0214
    rounded_0215 = work%rhgt - source_l_dow
    rounded_0216 = rounded_0215/source_width
    rounded_0217 = max(c_thousandth, rounded_0216)
    rounded_0218 = source_r8/rounded_0217
    source_swi = rounded_0218
    rounded_0219 = min(source_l_rec, source_width)
    rounded_0220 = source_width - rounded_0219
    rounded_0221 = rounded_0220/source_width
    rounded_0222 = max(c_thousandth, rounded_0221)
    rounded_0223 = source_r6/rounded_0222
    source_r6 = rounded_0223
    rounded_0224 = source_l_rec/c_two
    rounded_0225 = min(rounded_0224, source_width)
    rounded_0226 = source_width - rounded_0225
    rounded_0227 = rounded_0226/source_width
    rounded_0228 = max(c_thousandth, rounded_0227)
    rounded_0229 = source_r7/rounded_0228
    source_r7 = rounded_0229
    rounded_0230 = source_l_dow/source_width
    rounded_0231 = max(c_thousandth, rounded_0230)
    rounded_0232 = source_r8/rounded_0231
    source_r8 = rounded_0232
    rounded_0233 = source_r3*source_r4
    rounded_0234 = rounded_0233*source_swi
    rounded_0235 = source_r3*source_swi
    rounded_0236 = rounded_0233 + rounded_0235
    rounded_0237 = source_r4*source_swi
    rounded_0238 = rounded_0236 + rounded_0237
    rounded_0239 = rounded_0234/rounded_0238
    rounded_0240 = rounded_0239 + source_r5
    source_r_recirc = rounded_0240
    rounded_0241 = source_r6*source_r8
    rounded_0242 = source_r6 + source_r8
    rounded_0243 = rounded_0241/rounded_0242
    rounded_0244 = rounded_0243 + source_r7
    source_r_venti = rounded_0244
    rounded_0245 = c_one/source_r_recirc
    rounded_0246 = c_one/rounded_0244
    rounded_0247 = rounded_0245 + rounded_0246
    rounded_0248 = c_one/rounded_0247
    source_r_bulk = rounded_0248
    work%rcanres = rounded_0248
    ! Source canyon heat roughness and transfer coefficient.
    rounded_0249 = work%rvksq*rounded_0248
    rounded_0250 = rounded_0249/source_logmod
    rounded_0251 = selected_exp(rounded_0250)
    rounded_0252 = work%rhgt*rounded_0251
    rounded_0253 = work%rmodz + work%rcanztm
    rounded_0254 = work%rhgt*rounded_0253
    rounded_0255 = rounded_0254/rounded_0252
    work%rcanzth = rounded_0255
    rounded_0256 = work%rmodz + work%rcanztm
    rounded_0257 = rounded_0256/work%rcanztm
    rounded_0258 = selected_log(rounded_0257)
    source_temp = rounded_0258
    rounded_0259 = work%rmodz + work%rcanztm
    rounded_0260 = rounded_0259/work%rcanzth
    rounded_0261 = selected_log(rounded_0260)
    rounded_0262 = c_one/work%rvksq
    rounded_0263 = rounded_0262*source_temp
    rounded_0264 = rounded_0263*rounded_0261
    rounded_0265 = c_one/rounded_0264
    work%rcanhc = rounded_0265
    ! Roof properties retain the source use of canyon heat roughness in RROOHC.
    work%rrooztm = work%rcanztm
    rounded_0266 = c_roofheight*work%rhgt
    rounded_0267 = rounded_0266 - c_disp
    rounded_0268 = max(rounded_0267, work%rrooztm)
    rounded_0269 = rounded_0268/work%rrooztm
    rounded_0270 = selected_log(rounded_0269)
    rounded_0271 = rounded_0270/source_logmod
    rounded_0272 = max(rounded_0271, c_tiny)
    source_swi = rounded_0272
    rounded_0273 = source_zref/work%rbuiz0m
    rounded_0274 = rounded_0273 + c_one
    rounded_0275 = selected_log(rounded_0274)
    source_temp = rounded_0275
    rounded_0276 = source_zref + work%rbuiz0m
    rounded_0277 = c_tenth*work%rbuiz0m
    rounded_0278 = rounded_0276/rounded_0277
    rounded_0279 = selected_log(rounded_0278)
    rounded_0280 = source_temp*rounded_0279
    rounded_0281 = work%rvksq*source_swi
    rounded_0282 = rounded_0280/rounded_0281
    source_r_recirc = rounded_0282
    rounded_0283 = c_one - source_swi
    rounded_0284 = rounded_0283*source_logmod
    rounded_0285 = rounded_0284/work%rvksq
    source_r_venti = rounded_0285
    rounded_0286 = source_r_recirc + rounded_0285
    source_r_bulk = rounded_0286
    work%rroores = rounded_0286
    rounded_0287 = work%rvksq*rounded_0286
    rounded_0288 = rounded_0287/source_logmod
    rounded_0289 = selected_exp(rounded_0288)
    rounded_0290 = work%rhgt*rounded_0289
    rounded_0291 = work%rmodz + work%rrooztm
    rounded_0292 = work%rhgt*rounded_0291
    rounded_0293 = rounded_0292/rounded_0290
    work%rroozth = rounded_0293
    ! RROOZTM equals RCANZTM, so the source two logarithms equal the prior canyon pair.
    work%rroohc = work%rcanhc
    rounded_0294 = c_one + work%rwrr
    rounded_0295 = c_one/rounded_0294
    rounded_0296 = work%rwrr/rounded_0294
    rounded_0297 = rounded_0295*work%rroores
    rounded_0298 = rounded_0296*work%rcanres
    rounded_0299 = rounded_0297 + rounded_0298
    work%rurbres = rounded_0299
    rounded_0300 = c_one + work%rwrr
    rounded_0301 = c_one/rounded_0300
    rounded_0302 = work%rwrr/rounded_0300
    rounded_0303 = rounded_0301*work%rrooztm
    rounded_0304 = rounded_0302*work%rcanztm
    rounded_0305 = rounded_0303 + rounded_0304
    work%rurbztm = rounded_0305
    rounded_0306 = c_one + work%rwrr
    rounded_0307 = c_one/rounded_0306
    rounded_0308 = work%rwrr/rounded_0306
    rounded_0309 = rounded_0307*work%rroozth
    rounded_0310 = rounded_0308*work%rcanzth
    rounded_0311 = rounded_0309 + rounded_0310
    work%rurbzth = rounded_0311
    rounded_0312 = c_one + work%rwrr
    rounded_0313 = c_one/rounded_0312
    rounded_0314 = work%rwrr/rounded_0312
    rounded_0315 = rounded_0313*work%rroohc
    rounded_0316 = rounded_0314*work%rcanhc
    rounded_0317 = rounded_0315 + rounded_0316
    work%rurbhc = rounded_0317
    rounded_0318 = c_two*work%rhwr
    rounded_0319 = rounded_0318*work%rwaltc
    rounded_0320 = rounded_0319 + work%rroatc
    work%rcantc = rounded_0320
    rounded_0321 = c_two*work%rhwr
    rounded_0322 = rounded_0321*work%rwalvhc
    rounded_0323 = rounded_0322 + work%rroavhc
    work%rcanvhc = rounded_0323
    rounded_0324 = c_one + work%rwrr
    rounded_0325 = c_one/rounded_0324
    rounded_0326 = work%rwrr/rounded_0324
    rounded_0327 = rounded_0325*work%rrootc
    rounded_0328 = rounded_0326*work%rcantc
    rounded_0329 = rounded_0328 + rounded_0327
    work%rurbtc = rounded_0329
    rounded_0330 = work%rurbtc*c_heat_level
    work%rurbtc1 = rounded_0330
    rounded_0331 = c_one + work%rwrr
    rounded_0332 = c_one/rounded_0331
    rounded_0333 = work%rwrr/rounded_0331
    rounded_0334 = rounded_0332*work%rroovhc
    rounded_0335 = rounded_0333*work%rcanvhc
    rounded_0336 = rounded_0335 + rounded_0334
    work%rurbvhc = rounded_0336
    ydurb = work
    incoming_errno = saved_errno
  end subroutine susurb
end module susurb_mod

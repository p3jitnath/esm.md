!> Selected SUOPTSURF parameter and storage producer in portable Fortran.
!! The selected controls enable Farquhar photosynthesis and disable optional
!! namelist input. The first nine arrays have vegetation index 1:20 and
!! photosynthesis pathway 1:2; the nine optional-input arrays have bounds 1:21.
!! Respiration RVR0VT is in kg CO2 m^-2 s^-1. RVCMAX25 is the source leaf
!! carboxylation capacity at 25 degrees Celsius. Other fields preserve the
!! source moisture, conductance and temperature-response parameter units.
!! Initialisation owns all allocations and commits them only after success.
!! Quiet startup omits the source's unconsumed informational table printing.
module surface_optimization_parameters_mod
  use iso_fortran_env, only: real64, int32, int64
  use iso_c_binding, only: c_int, c_ptr, c_f_pointer
  use ieee_arithmetic, only: ieee_round_type, ieee_get_rounding_mode, ieee_nearest, operator(/=)
  use yoephy, only: tephy
  use ieee_exceptions, only: ieee_get_flag, ieee_set_flag, ieee_underflow, ieee_inexact
  implicit none
  private
  public :: suoptsurf, initialize_surface_optimization_parameters, release_surface_optimization_parameters
  real(real64), allocatable, save, public :: rvr0vt(:, :)
  real(real64), allocatable, save, public :: rvcmax25(:, :)
  real(real64), allocatable, save, public :: rhumrel(:, :)
  real(real64), allocatable, save, public :: ra1(:, :)
  real(real64), allocatable, save, public :: rb1(:, :)
  real(real64), allocatable, save, public :: rg0(:, :)
  real(real64), allocatable, save, public :: rgm25(:, :)
  real(real64), allocatable, save, public :: re_vcmax(:, :)
  real(real64), allocatable, save, public :: re_jmax(:, :)
  real(real64), allocatable, save, public :: ovr0vt(:)
  real(real64), allocatable, save, public :: ovcmax25(:)
  real(real64), allocatable, save, public :: ohumrel(:)
  real(real64), allocatable, save, public :: oa1(:)
  real(real64), allocatable, save, public :: ob1(:)
  real(real64), allocatable, save, public :: og0(:)
  real(real64), allocatable, save, public :: ogm25(:)
  real(real64), allocatable, save, public :: oe_vcmax(:)
  real(real64), allocatable, save, public :: oe_jmax(:)
  ! Literal source values for RVR0VT, with first index contiguous.
  integer(int64), parameter :: bits_rvr0vt(40) = [ &
                               int(z'3e82b92efa0253dc', int64), int(z'3e81e0b7972ed0e6', int64), int(z'3e9efbf212fd3ecd', int64), &
                               int(z'3e9d15c15ba026e1', int64), int(z'3e9b3f06e22d9850', int64), int(z'3e95874d521d7819', int64), &
                               int(z'3e6036a8097e40e9', int64), int(z'3e8376297cfbff14', int64), int(z'3ea18c8929a3ac31', int64), &
                               int(z'3e6de759867d33e8', int64), int(z'3e165575e0ff4a28', int64), int(z'3e8376297cfbff14', int64), &
                               int(z'3e98c6cec59b3644', int64), int(z'3e8376297cfbff14', int64), int(z'3e8376297cfbff14', int64), &
                               int(z'3e81d2f92741e507', int64), int(z'3e665575e0ff4a28', int64), int(z'3e9f871a403c12fd', int64), &
                               int(z'3e8c4798ccbe54d2', int64), int(z'3e921e908ed8f651', int64), int(z'3e7bdd14e95230d3', int64), &
                               int(z'3e6036a8097e40e9', int64), int(z'3e9efbf212fd3ecd', int64), int(z'3e9d15c15ba026e1', int64), &
                               int(z'3e9b3f06e22d9850', int64), int(z'3e95874d521d7819', int64), int(z'3e6036a8097e40e9', int64), &
                               int(z'3e8376297cfbff14', int64), int(z'3ea18c8929a3ac31', int64), int(z'3e6de759867d33e8', int64), &
                               int(z'3e165575e0ff4a28', int64), int(z'3e8376297cfbff14', int64), int(z'3e98c6cec59b3644', int64), &
                               int(z'3e8376297cfbff14', int64), int(z'3e8376297cfbff14', int64), int(z'3e81d2f92741e507', int64), &
                               int(z'3e665575e0ff4a28', int64), int(z'3e9f871a403c12fd', int64), int(z'3e8c4798ccbe54d2', int64), &
                               int(z'3e921e908ed8f651', int64)]
  real(real64), parameter :: defaults_rvr0vt(20, 2) = reshape(transfer(bits_rvr0vt, [0.0_real64], 40), [20, 2])
  ! Literal source values for RVCMAX25, with first index contiguous.
  integer(int64), parameter :: bits_rvcmax25(40) = [ &
                               int(z'4048800000000000', int64), int(z'404859999999999a', int64), int(z'404f19999999999a', int64), &
                               int(z'4041800000000000', int64), int(z'4044f33333333333', int64), int(z'4040f33333333333', int64), &
                               int(z'4044266666666666', int64), int(z'4049000000000000', int64), int(z'4051800000000000', int64), &
                               int(z'404e000000000000', int64), int(z'4049000000000000', int64), int(z'4049000000000000', int64), &
                               int(z'40484ccccccccccd', int64), int(z'4049000000000000', int64), int(z'4049000000000000', int64), &
                               int(z'404d333333333333', int64), int(z'4046400000000000', int64), int(z'404519999999999a', int64), &
                               int(z'4049000000000000', int64), int(z'4049000000000000', int64), int(z'4051a00000000000', int64), &
                               int(z'4044266666666666', int64), int(z'404f19999999999a', int64), int(z'4041800000000000', int64), &
                               int(z'4044f33333333333', int64), int(z'4040f33333333333', int64), int(z'4044266666666666', int64), &
                               int(z'4049000000000000', int64), int(z'4051800000000000', int64), int(z'404e000000000000', int64), &
                               int(z'4049000000000000', int64), int(z'4049000000000000', int64), int(z'40484ccccccccccd', int64), &
                               int(z'4049000000000000', int64), int(z'4049000000000000', int64), int(z'404d333333333333', int64), &
                               int(z'4046400000000000', int64), int(z'404519999999999a', int64), int(z'4049000000000000', int64), &
                               int(z'4049000000000000', int64)]
  real(real64), parameter :: defaults_rvcmax25(20, 2) = reshape(transfer(bits_rvcmax25, [0.0_real64], 40), [20, 2])
  ! Literal source values for RHUMREL, with first index contiguous.
  integer(int64), parameter :: bits_rhumrel(40) = [ &
                               int(z'4010000000000000', int64), int(z'400a8f5c28f5c28f', int64), int(z'400770a3d70a3d71', int64), &
                               int(z'3ff0000000000000', int64), int(z'400a000000000000', int64), int(z'4010000000000000', int64), &
                               int(z'400c28f5c28f5c29', int64), int(z'3ff0000000000000', int64), int(z'4010000000000000', int64), &
                               int(z'3ff0000000000000', int64), int(z'3ff0000000000000', int64), int(z'3ff0000000000000', int64), &
                               int(z'4010000000000000', int64), int(z'3ff0000000000000', int64), int(z'3ff0000000000000', int64), &
                               int(z'40050a3d70a3d70a', int64), int(z'4010000000000000', int64), int(z'3ffbae147ae147ae', int64), &
                               int(z'3ff0000000000000', int64), int(z'3ff0000000000000', int64), int(z'40007ae147ae147b', int64), &
                               int(z'400c28f5c28f5c29', int64), int(z'400770a3d70a3d71', int64), int(z'3ff0000000000000', int64), &
                               int(z'400a000000000000', int64), int(z'4010000000000000', int64), int(z'400c28f5c28f5c29', int64), &
                               int(z'3ff0000000000000', int64), int(z'4010000000000000', int64), int(z'3ff0000000000000', int64), &
                               int(z'3ff0000000000000', int64), int(z'3ff0000000000000', int64), int(z'4010000000000000', int64), &
                               int(z'3ff0000000000000', int64), int(z'3ff0000000000000', int64), int(z'40050a3d70a3d70a', int64), &
                               int(z'4010000000000000', int64), int(z'3ffbae147ae147ae', int64), int(z'3ff0000000000000', int64), &
                               int(z'3ff0000000000000', int64)]
  real(real64), parameter :: defaults_rhumrel(20, 2) = reshape(transfer(bits_rhumrel, [0.0_real64], 40), [20, 2])
  ! Literal source values for RA1, with first index contiguous.
  integer(int64), parameter :: bits_ra1(40) = [ &
                               int(z'3fee45a1cac08312', int64), int(z'3fec6a7ef9db22d1', int64), int(z'3fe5c28f5c28f5c3', int64), &
                               int(z'3feb333333333333', int64), int(z'3fef47ae147ae148', int64), int(z'3fef47ae147ae148', int64), &
                               int(z'3fe5604189374bc7', int64), int(z'3feb333333333333', int64), int(z'3fef47ae147ae148', int64), &
                               int(z'3feb333333333333', int64), int(z'3fe70a3d70a3d70a', int64), int(z'3fe999999999999a', int64), &
                               int(z'3fed6872b020c49c', int64), int(z'3feb333333333333', int64), int(z'3feb333333333333', int64), &
                               int(z'3feba5e353f7ced9', int64), int(z'3fef47ae147ae148', int64), int(z'3fe71a9fbe76c8b4', int64), &
                               int(z'3feb333333333333', int64), int(z'3feb333333333333', int64), int(z'3feba5e353f7ced9', int64), &
                               int(z'3fe5604189374bc7', int64), int(z'3fe5c28f5c28f5c3', int64), int(z'3feb333333333333', int64), &
                               int(z'3fef47ae147ae148', int64), int(z'3fef47ae147ae148', int64), int(z'3fe5604189374bc7', int64), &
                               int(z'3feb333333333333', int64), int(z'3fef47ae147ae148', int64), int(z'3feb333333333333', int64), &
                               int(z'3fe70a3d70a3d70a', int64), int(z'3fe999999999999a', int64), int(z'3fed6872b020c49c', int64), &
                               int(z'3feb333333333333', int64), int(z'3feb333333333333', int64), int(z'3feba5e353f7ced9', int64), &
                               int(z'3fef47ae147ae148', int64), int(z'3fe71a9fbe76c8b4', int64), int(z'3feb333333333333', int64), &
                               int(z'3feb333333333333', int64)]
  real(real64), parameter :: defaults_ra1(20, 2) = reshape(transfer(bits_ra1, [0.0_real64], 40), [20, 2])
  ! Literal source values for RB1, with first index contiguous.
  integer(int64), parameter :: bits_rb1(40) = [ &
                               int(z'3fc0a3d70a3d70a4', int64), int(z'3fbdf3b645a1cac1', int64), int(z'3fc5810624dd2f1b', int64), &
                               int(z'3fc1eb851eb851ec', int64), int(z'3fbcac083126e979', int64), int(z'3fc1a9fbe76c8b44', int64), &
                               int(z'3fcae147ae147ae1', int64), int(z'3fc1eb851eb851ec', int64), int(z'3fbcac083126e979', int64), &
                               int(z'3fc1eb851eb851ec', int64), int(z'3fc999999999999a', int64), int(z'3fc1eb851eb851ec', int64), &
                               int(z'3fc020c49ba5e354', int64), int(z'3fc1eb851eb851ec', int64), int(z'3fc1eb851eb851ec', int64), &
                               int(z'3fca5e353f7ced91', int64), int(z'3fbcac083126e979', int64), int(z'3fc395810624dd2f', int64), &
                               int(z'3fc1eb851eb851ec', int64), int(z'3fc1eb851eb851ec', int64), int(z'3fc5810624dd2f1b', int64), &
                               int(z'3fcae147ae147ae1', int64), int(z'3fc5810624dd2f1b', int64), int(z'3fc1eb851eb851ec', int64), &
                               int(z'3fbcac083126e979', int64), int(z'3fc1a9fbe76c8b44', int64), int(z'3fcae147ae147ae1', int64), &
                               int(z'3fc1eb851eb851ec', int64), int(z'3fbcac083126e979', int64), int(z'3fc1eb851eb851ec', int64), &
                               int(z'3fc999999999999a', int64), int(z'3fc1eb851eb851ec', int64), int(z'3fc020c49ba5e354', int64), &
                               int(z'3fc1eb851eb851ec', int64), int(z'3fc1eb851eb851ec', int64), int(z'3fca5e353f7ced91', int64), &
                               int(z'3fbcac083126e979', int64), int(z'3fc395810624dd2f', int64), int(z'3fc1eb851eb851ec', int64), &
                               int(z'3fc1eb851eb851ec', int64)]
  real(real64), parameter :: defaults_rb1(20, 2) = reshape(transfer(bits_rb1, [0.0_real64], 40), [20, 2])
  ! Literal source values for RG0, with first index contiguous.
  integer(int64), parameter :: bits_rg0(40) = [ &
                               int(z'3f7ca18bd66277c4', int64), int(z'3f7b328b6d86ec18', int64), int(z'3f75d4e8fb00bcbe', int64), &
                               int(z'3f7999999999999a', int64), int(z'3f7f85d744f5d356', int64), int(z'3f800d77e0000000', int64), &
                               int(z'3f916872b020c49c', int64), int(z'3f7999999999999a', int64), int(z'3f80a3d70a3d70a4', int64), &
                               int(z'3f7999999999999a', int64), int(z'3f93333333333333', int64), int(z'3f7999999999999a', int64), &
                               int(z'3f7e44fa05143bf7', int64), int(z'3f7999999999999a', int64), int(z'3f7999999999999a', int64), &
                               int(z'3f8d14e3bcd35a86', int64), int(z'3f7fa97e132b55ef', int64), int(z'3f763dc486ad2dcb', int64), &
                               int(z'3f7999999999999a', int64), int(z'3f7999999999999a', int64), int(z'3f966cf41f212d77', int64), &
                               int(z'3f916872b020c49c', int64), int(z'3f75d4e8fb00bcbe', int64), int(z'3f7999999999999a', int64), &
                               int(z'3f7f85d744f5d356', int64), int(z'3f800d77e0000000', int64), int(z'3f916872b020c49c', int64), &
                               int(z'3f7999999999999a', int64), int(z'3f80a3d70a3d70a4', int64), int(z'3f7999999999999a', int64), &
                               int(z'3f93333333333333', int64), int(z'3f7999999999999a', int64), int(z'3f7e44fa05143bf7', int64), &
                               int(z'3f7999999999999a', int64), int(z'3f7999999999999a', int64), int(z'3f8d14e3bcd35a86', int64), &
                               int(z'3f7fa97e132b55ef', int64), int(z'3f763dc486ad2dcb', int64), int(z'3f7999999999999a', int64), &
                               int(z'3f7999999999999a', int64)]
  real(real64), parameter :: defaults_rg0(20, 2) = reshape(transfer(bits_rg0, [0.0_real64], 40), [20, 2])
  ! Literal source values for RGM25, with first index contiguous.
  integer(int64), parameter :: bits_rgm25(40) = [ &
                               int(z'3fe06a7ef9db22d1', int64), int(z'3fe50624dd2f1aa0', int64), int(z'3fb999999999999a', int64), &
                               int(z'3fd999999999999a', int64), int(z'3fe7020c49ba5e35', int64), int(z'3fd8c29032e88a98', int64), &
                               int(z'3fd999999999999a', int64), int(z'3fd999999999999a', int64), int(z'3fe999999999999a', int64), &
                               int(z'3fd999999999999a', int64), int(z'3fd999999999999a', int64), int(z'3fd999999999999a', int64), &
                               int(z'3fe2e147ae147ae1', int64), int(z'3fd999999999999a', int64), int(z'3fd999999999999a', int64), &
                               int(z'3fd999999999999a', int64), int(z'3fe72b020c49ba5e', int64), int(z'3fd9db22d0e56042', int64), &
                               int(z'3fd999999999999a', int64), int(z'3fd999999999999a', int64), int(z'3fd999999999999a', int64), &
                               int(z'3fe50624dd2f1aa0', int64), int(z'3fb999999999999a', int64), int(z'3fd999999999999a', int64), &
                               int(z'3fe7020c49ba5e35', int64), int(z'3fd8c29032e88a98', int64), int(z'3fd999999999999a', int64), &
                               int(z'3fd999999999999a', int64), int(z'3fe999999999999a', int64), int(z'3fd999999999999a', int64), &
                               int(z'3fd999999999999a', int64), int(z'3fd999999999999a', int64), int(z'3fe2e147ae147ae1', int64), &
                               int(z'3fd999999999999a', int64), int(z'3fd999999999999a', int64), int(z'3fd999999999999a', int64), &
                               int(z'3fe72b020c49ba5e', int64), int(z'3fd9db22d0e56042', int64), int(z'3fd999999999999a', int64), &
                               int(z'3fd999999999999a', int64)]
  real(real64), parameter :: defaults_rgm25(20, 2) = reshape(transfer(bits_rgm25, [0.0_real64], 40), [20, 2])
  ! Literal source values for RE_VCMAX, with first index contiguous.
  integer(int64), parameter :: bits_re_vcmax(40) = [ &
                               int(z'40f1c614cccccccd', int64), int(z'40e8716333333333', int64), int(z'40ed3d0666666666', int64), &
                               int(z'40f1759000000000', int64), int(z'40f6b26e66666666', int64), int(z'40f087a170a3d70a', int64), &
                               int(z'40e700c000000000', int64), int(z'40f1759000000000', int64), int(z'40e8716333333333', int64), &
                               int(z'40f1759000000000', int64), int(z'40f06e4000000000', int64), int(z'40f1759000000000', int64), &
                               int(z'40f1cca99999999a', int64), int(z'40f1759000000000', int64), int(z'40f1759000000000', int64), &
                               int(z'40e700c000000000', int64), int(z'40e8716333333333', int64), int(z'40f093b4cccccccd', int64), &
                               int(z'40f1759000000000', int64), int(z'40f1759000000000', int64), int(z'40f38da333333333', int64), &
                               int(z'40e700c000000000', int64), int(z'40ed3d0666666666', int64), int(z'40f1759000000000', int64), &
                               int(z'40f6b26e66666666', int64), int(z'40f087a170a3d70a', int64), int(z'40e700c000000000', int64), &
                               int(z'40f1759000000000', int64), int(z'40e8716333333333', int64), int(z'40f1759000000000', int64), &
                               int(z'40f06e4000000000', int64), int(z'40f1759000000000', int64), int(z'40f1cca99999999a', int64), &
                               int(z'40f1759000000000', int64), int(z'40f1759000000000', int64), int(z'40e700c000000000', int64), &
                               int(z'40e8716333333333', int64), int(z'40f093b4cccccccd', int64), int(z'40f1759000000000', int64), &
                               int(z'40f1759000000000', int64)]
  real(real64), parameter :: defaults_re_vcmax(20, 2) = reshape(transfer(bits_re_vcmax, [0.0_real64], 40), [20, 2])
  ! Literal source values for RE_JMAX, with first index contiguous.
  integer(int64), parameter :: bits_re_jmax(40) = [ &
                               int(z'40efaa2666666666', int64), int(z'40e43e7000000000', int64), int(z'40e11d0666666666', int64), &
                               int(z'40e85b8000000000', int64), int(z'40e10cd99999999a', int64), int(z'40e10cd99999999a', int64), &
                               int(z'40eaa04000000000', int64), int(z'40e85b8000000000', int64), int(z'40e10cd99999999a', int64), &
                               int(z'40e85b8000000000', int64), int(z'40f304c000000000', int64), int(z'40e85b8000000000', int64), &
                               int(z'40e10cd99999999a', int64), int(z'40e85b8000000000', int64), int(z'40e85b8000000000', int64), &
                               int(z'40eaa04000000000', int64), int(z'40e9c27333333333', int64), int(z'40e10cd99999999a', int64), &
                               int(z'40e85b8000000000', int64), int(z'40e85b8000000000', int64), int(z'40f8b96000000000', int64), &
                               int(z'40eaa04000000000', int64), int(z'40e11d0666666666', int64), int(z'40e85b8000000000', int64), &
                               int(z'40e10cd99999999a', int64), int(z'40e10cd99999999a', int64), int(z'40eaa04000000000', int64), &
                               int(z'40e85b8000000000', int64), int(z'40e10cd99999999a', int64), int(z'40e85b8000000000', int64), &
                               int(z'40f304c000000000', int64), int(z'40e85b8000000000', int64), int(z'40e10cd99999999a', int64), &
                               int(z'40e85b8000000000', int64), int(z'40e85b8000000000', int64), int(z'40eaa04000000000', int64), &
                               int(z'40e9c27333333333', int64), int(z'40e10cd99999999a', int64), int(z'40e85b8000000000', int64), &
                               int(z'40e85b8000000000', int64)]
  real(real64), parameter :: defaults_re_jmax(20, 2) = reshape(transfer(bits_re_jmax, [0.0_real64], 40), [20, 2])
  ! Literal source values for OVR0VT, with first index contiguous.
  integer(int64), parameter :: bits_ovr0vt(21) = [ &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64)]
  real(real64), parameter :: defaults_ovr0vt(21) = transfer(bits_ovr0vt, [0.0_real64], 21)
  ! Literal source values for OVCMAX25, with first index contiguous.
  integer(int64), parameter :: bits_ovcmax25(21) = [ &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64)]
  real(real64), parameter :: defaults_ovcmax25(21) = transfer(bits_ovcmax25, [0.0_real64], 21)
  ! Literal source values for OHUMREL, with first index contiguous.
  integer(int64), parameter :: bits_ohumrel(21) = [ &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64)]
  real(real64), parameter :: defaults_ohumrel(21) = transfer(bits_ohumrel, [0.0_real64], 21)
  ! Literal source values for OA1, with first index contiguous.
  integer(int64), parameter :: bits_oa1(21) = [ &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64)]
  real(real64), parameter :: defaults_oa1(21) = transfer(bits_oa1, [0.0_real64], 21)
  ! Literal source values for OB1, with first index contiguous.
  integer(int64), parameter :: bits_ob1(21) = [ &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64)]
  real(real64), parameter :: defaults_ob1(21) = transfer(bits_ob1, [0.0_real64], 21)
  ! Literal source values for OG0, with first index contiguous.
  integer(int64), parameter :: bits_og0(21) = [ &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64)]
  real(real64), parameter :: defaults_og0(21) = transfer(bits_og0, [0.0_real64], 21)
  ! Literal source values for OGM25, with first index contiguous.
  integer(int64), parameter :: bits_ogm25(21) = [ &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64)]
  real(real64), parameter :: defaults_ogm25(21) = transfer(bits_ogm25, [0.0_real64], 21)
  ! Literal source values for OE_VCMAX, with first index contiguous.
  integer(int64), parameter :: bits_oe_vcmax(21) = [ &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64)]
  real(real64), parameter :: defaults_oe_vcmax(21) = transfer(bits_oe_vcmax, [0.0_real64], 21)
  ! Literal source values for OE_JMAX, with first index contiguous.
  integer(int64), parameter :: bits_oe_jmax(21) = [ &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), &
                               int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64), int(z'c0c3878000000000', int64)]
  real(real64), parameter :: defaults_oe_jmax(21) = transfer(bits_oe_jmax, [0.0_real64], 21)
  interface
    function errno_location() bind(C, name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function errno_location
  end interface
contains
  !> Retain the compiled native settings and output-unit interface.
  !! YDEPHY supplies input logical controls. KULOUT is an input logical unit.
  !! This selected quiet route writes no informational message.
  subroutine suoptsurf(ydephy, kulout)
    type(tephy), intent(in) :: ydephy
    integer(int32), intent(in) :: kulout
    integer(int32) :: status
    status = initialize_surface_optimization_parameters(ydephy%lefarquhar, ydephy%leoptsurf)
    if (status /= 0_int32) call abort()
  end subroutine suoptsurf

  !> Initialise all eighteen owned arrays from the frozen selected tables.
  !! Controls are input logicals. Status0 means success,1 means allocation
  !! failure and2 means unsupported controls, floating mode or nonfresh owners.
  !! Failures retain every public array, incoming exception flag and errno.
  integer(int32) function initialize_surface_optimization_parameters(lefarquhar, leoptsurf) result(status)
    logical, intent(in) :: lefarquhar, leoptsurf
    integer :: allocation_status
    integer(c_int), pointer :: errno_value
    integer(c_int) :: saved_errno
    real(real64), allocatable :: new_rvr0vt(:, :)
    real(real64), allocatable :: new_rvcmax25(:, :)
    real(real64), allocatable :: new_rhumrel(:, :)
    real(real64), allocatable :: new_ra1(:, :)
    real(real64), allocatable :: new_rb1(:, :)
    real(real64), allocatable :: new_rg0(:, :)
    real(real64), allocatable :: new_rgm25(:, :)
    real(real64), allocatable :: new_re_vcmax(:, :)
    real(real64), allocatable :: new_re_jmax(:, :)
    real(real64), allocatable :: new_ovr0vt(:)
    real(real64), allocatable :: new_ovcmax25(:)
    real(real64), allocatable :: new_ohumrel(:)
    real(real64), allocatable :: new_oa1(:)
    real(real64), allocatable :: new_ob1(:)
    real(real64), allocatable :: new_og0(:)
    real(real64), allocatable :: new_ogm25(:)
    real(real64), allocatable :: new_oe_vcmax(:)
    real(real64), allocatable :: new_oe_jmax(:)
    status = 2_int32
    if (.not. lefarquhar .or. leoptsurf) return
    if (.not. supported_floating_mode()) return
    if (allocated(rvr0vt)) return
    if (allocated(rvcmax25)) return
    if (allocated(rhumrel)) return
    if (allocated(ra1)) return
    if (allocated(rb1)) return
    if (allocated(rg0)) return
    if (allocated(rgm25)) return
    if (allocated(re_vcmax)) return
    if (allocated(re_jmax)) return
    if (allocated(ovr0vt)) return
    if (allocated(ovcmax25)) return
    if (allocated(ohumrel)) return
    if (allocated(oa1)) return
    if (allocated(ob1)) return
    if (allocated(og0)) return
    if (allocated(ogm25)) return
    if (allocated(oe_vcmax)) return
    if (allocated(oe_jmax)) return
    call c_f_pointer(errno_location(), errno_value)
    saved_errno = errno_value
    status = 1_int32
    allocate (new_rvr0vt(20, 2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_rvr0vt = defaults_rvr0vt
    allocate (new_rvcmax25(20, 2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_rvcmax25 = defaults_rvcmax25
    allocate (new_rhumrel(20, 2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_rhumrel = defaults_rhumrel
    allocate (new_ra1(20, 2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_ra1 = defaults_ra1
    allocate (new_rb1(20, 2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_rb1 = defaults_rb1
    allocate (new_rg0(20, 2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_rg0 = defaults_rg0
    allocate (new_rgm25(20, 2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_rgm25 = defaults_rgm25
    allocate (new_re_vcmax(20, 2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_re_vcmax = defaults_re_vcmax
    allocate (new_re_jmax(20, 2), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_re_jmax = defaults_re_jmax
    allocate (new_ovr0vt(21), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_ovr0vt = defaults_ovr0vt
    allocate (new_ovcmax25(21), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_ovcmax25 = defaults_ovcmax25
    allocate (new_ohumrel(21), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_ohumrel = defaults_ohumrel
    allocate (new_oa1(21), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_oa1 = defaults_oa1
    allocate (new_ob1(21), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_ob1 = defaults_ob1
    allocate (new_og0(21), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_og0 = defaults_og0
    allocate (new_ogm25(21), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_ogm25 = defaults_ogm25
    allocate (new_oe_vcmax(21), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_oe_vcmax = defaults_oe_vcmax
    allocate (new_oe_jmax(21), stat=allocation_status)
    if (allocation_status /= 0) goto 900
    new_oe_jmax = defaults_oe_jmax
    call move_alloc(new_rvr0vt, rvr0vt)
    call move_alloc(new_rvcmax25, rvcmax25)
    call move_alloc(new_rhumrel, rhumrel)
    call move_alloc(new_ra1, ra1)
    call move_alloc(new_rb1, rb1)
    call move_alloc(new_rg0, rg0)
    call move_alloc(new_rgm25, rgm25)
    call move_alloc(new_re_vcmax, re_vcmax)
    call move_alloc(new_re_jmax, re_jmax)
    call move_alloc(new_ovr0vt, ovr0vt)
    call move_alloc(new_ovcmax25, ovcmax25)
    call move_alloc(new_ohumrel, ohumrel)
    call move_alloc(new_oa1, oa1)
    call move_alloc(new_ob1, ob1)
    call move_alloc(new_og0, og0)
    call move_alloc(new_ogm25, ogm25)
    call move_alloc(new_oe_vcmax, oe_vcmax)
    call move_alloc(new_oe_jmax, oe_jmax)
    status = 0_int32
900 continue
    if (allocated(new_rvr0vt)) deallocate (new_rvr0vt)
    if (allocated(new_rvcmax25)) deallocate (new_rvcmax25)
    if (allocated(new_rhumrel)) deallocate (new_rhumrel)
    if (allocated(new_ra1)) deallocate (new_ra1)
    if (allocated(new_rb1)) deallocate (new_rb1)
    if (allocated(new_rg0)) deallocate (new_rg0)
    if (allocated(new_rgm25)) deallocate (new_rgm25)
    if (allocated(new_re_vcmax)) deallocate (new_re_vcmax)
    if (allocated(new_re_jmax)) deallocate (new_re_jmax)
    if (allocated(new_ovr0vt)) deallocate (new_ovr0vt)
    if (allocated(new_ovcmax25)) deallocate (new_ovcmax25)
    if (allocated(new_ohumrel)) deallocate (new_ohumrel)
    if (allocated(new_oa1)) deallocate (new_oa1)
    if (allocated(new_ob1)) deallocate (new_ob1)
    if (allocated(new_og0)) deallocate (new_og0)
    if (allocated(new_ogm25)) deallocate (new_ogm25)
    if (allocated(new_oe_vcmax)) deallocate (new_oe_vcmax)
    if (allocated(new_oe_jmax)) deallocate (new_oe_jmax)
    errno_value = saved_errno
  end function initialize_surface_optimization_parameters

  !> Release all owned table arrays. Repeated release succeeds.
  !! This operation preserves incoming floating-point flags and errno.
  integer(int32) function release_surface_optimization_parameters() result(status)
    integer(c_int), pointer :: errno_value
    integer(c_int) :: saved_errno
    call c_f_pointer(errno_location(), errno_value)
    saved_errno = errno_value
    if (allocated(rvr0vt)) deallocate (rvr0vt)
    if (allocated(rvcmax25)) deallocate (rvcmax25)
    if (allocated(rhumrel)) deallocate (rhumrel)
    if (allocated(ra1)) deallocate (ra1)
    if (allocated(rb1)) deallocate (rb1)
    if (allocated(rg0)) deallocate (rg0)
    if (allocated(rgm25)) deallocate (rgm25)
    if (allocated(re_vcmax)) deallocate (re_vcmax)
    if (allocated(re_jmax)) deallocate (re_jmax)
    if (allocated(ovr0vt)) deallocate (ovr0vt)
    if (allocated(ovcmax25)) deallocate (ovcmax25)
    if (allocated(ohumrel)) deallocate (ohumrel)
    if (allocated(oa1)) deallocate (oa1)
    if (allocated(ob1)) deallocate (ob1)
    if (allocated(og0)) deallocate (og0)
    if (allocated(ogm25)) deallocate (ogm25)
    if (allocated(oe_vcmax)) deallocate (oe_vcmax)
    if (allocated(oe_jmax)) deallocate (oe_jmax)
    errno_value = saved_errno
    status = 0_int32
  end function release_surface_optimization_parameters

  !> Require nearest rounding and gradual underflow before owner mutation.
  !! The exact subnormal probe restores only its own possible exception flags
  !! so that a refused mode preserves the caller's incoming status.
  logical function supported_floating_mode() result(supported)
    type(ieee_round_type) :: rounding
    real(real64), volatile :: smallest_normal, half, subnormal
    logical :: incoming_underflow, incoming_inexact
    supported = .false.
    call ieee_get_rounding_mode(rounding)
    if (rounding /= ieee_nearest) return
    call ieee_get_flag(ieee_underflow, incoming_underflow)
    call ieee_get_flag(ieee_inexact, incoming_inexact)
    smallest_normal = tiny(0.0_real64)
    half = 0.5_real64
    subnormal = smallest_normal*half
    supported = transfer(subnormal, 0_int64) == int(z'0008000000000000', int64)
    call ieee_set_flag(ieee_underflow, incoming_underflow)
    call ieee_set_flag(ieee_inexact, incoming_inexact)
  end function supported_floating_mode
end module surface_optimization_parameters_mod

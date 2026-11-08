!> Calculate source grid dimensions through named portable integer records.
module forecast_grid_dimensions
  use iso_c_binding, only: c_int32_t, c_int64_t
  implicit none
  private
  public :: native_grid_dimensions, grid_dimension_setup_values, initialize_grid_dimensions
  !> The twenty-eight source-written dimension fields, each a dimensionless int32.
  type, bind(C) :: native_grid_dimensions
    integer(c_int32_t) :: ndglg
    integer(c_int32_t) :: ndlon
    integer(c_int32_t) :: ndguxg
    integer(c_int32_t) :: ndluxg
    integer(c_int32_t) :: nflevg
    integer(c_int32_t) :: niolevg
    integer(c_int32_t) :: nvarmax
    integer(c_int32_t) :: nmsmax
    integer(c_int32_t) :: nsmax
    integer(c_int32_t) :: ncmax
    integer(c_int32_t) :: nproma
    integer(c_int32_t) :: nstencilwide
    integer(c_int32_t) :: loptproma
    integer(c_int32_t) :: ndgnh
    integer(c_int32_t) :: ndlsm
    integer(c_int32_t) :: ndlsur
    integer(c_int32_t) :: ndlung
    integer(c_int32_t) :: ndgeng
    integer(c_int32_t) :: ndgsag
    integer(c_int32_t) :: ndgsur
    integer(c_int32_t) :: ndgung
    integer(c_int32_t) :: ndsur1
    integer(c_int32_t) :: nsefre
    integer(c_int32_t) :: nspec2g
    integer(c_int32_t) :: nspecg
    integer(c_int32_t) :: nflen
    integer(c_int32_t) :: nflsa
    integer(c_int32_t) :: nflsul
  end type
  !> Named source settings and initial-file dimensions, in the historical order.
  !! The first five fields are canonical zero/one controls. spectral_truncation
  !! and horizontal_cutoff must come from the actual initial header producer.
  type, bind(C) :: grid_dimension_setup_values
    integer(c_int32_t) :: lopt_scalar, lrepro4dvar, supersede, liolevg, lr2d, nconf
    integer(c_int32_t) :: nusmax, nudgl, nudlon, nucmax, nuflev
  end type
contains
  !> Preserve the SUDIM default, override and derived-count order.
  !! overrides has twelve int32 values in the first twelve output-field order.
  !! presence uses bits0:11. All validation precedes complete output publication.
  !! Return2 preserves output; return0 writes every named dimension.
  integer(c_int32_t) function initialize_grid_dimensions(output, settings, overrides, presence) &
    bind(C, name="md2asm_initialize_grid_dimensions_fortran") result(status)
    type(native_grid_dimensions), intent(inout) :: output
    type(grid_dimension_setup_values), intent(in) :: settings
    integer(c_int32_t), intent(in) :: overrides(12)
    integer(c_int32_t), value, intent(in) :: presence
    integer(c_int32_t) :: value(28), default_block, block, j, temporary, stencil
    status = 2
    if (presence < 0 .or. shiftr(presence, 12) /= 0) return
    if (settings%lopt_scalar < 0 .or. settings%lopt_scalar > 1) return
    if (settings%lrepro4dvar < 0 .or. settings%lrepro4dvar > 1) return
    if (settings%supersede < 0 .or. settings%supersede > 1) return
    if (settings%liolevg < 0 .or. settings%liolevg > 1) return
    if (settings%lr2d < 0 .or. settings%lr2d > 1) return
    value = 0
    value(1) = 32
    value(2) = 64
    value(3) = 32
    value(4) = 64
    value(5) = 19
    value(6) = 19
    temporary = 21
    if (settings%supersede == 1) temporary = settings%nusmax
    value(7) = temporary
    value(8) = temporary
    value(9) = temporary
    value(10) = 1
    default_block = 2047
    if (settings%lopt_scalar == 1) default_block = 16
    value(11) = default_block
    value(12) = 2
    do j = 1, 12
      if (btest(presence, j - 1)) value(j) = overrides(j)
    end do
    block = value(11)
    if (block == 0) block = default_block
    value(13) = 0
    if (block > 0 .and. settings%lrepro4dvar == 0) value(13) = 1
    if (block == -huge(block) - 1) return
    value(11) = abs(block)
    if (settings%supersede == 1) then
      value(9) = settings%nusmax
      value(1) = settings%nudgl
      value(2) = settings%nudlon
      value(10) = settings%nucmax
    end if
    value(10) = max(value(10), value(9))
    if (value(1) < 1 .or. value(1) > 1048576) return
    if (value(2) < 1 .or. value(2) > 1048576) return
    if (value(9) < 0 .or. value(9) > 8191) return
    if (value(11) < 1 .or. value(11) > 1048576) return
    stencil = value(12)
    if (stencil < 0 .or. stencil > 48) return
    value(14) = (value(1) + 1)/2
    value(20) = stencil
    value(19) = 1 - stencil
    value(21) = 1 - stencil
    value(18) = value(1) + stencil
    value(3) = value(18)
    value(17) = 1
    value(4) = value(2)
    temporary = value(9) + 1
    value(23) = temporary*temporary
    value(25) = temporary*(temporary + 1)/2
    value(24) = 2*value(25)
    temporary = max(value(2), 2*value(9) + 1)
    value(22) = 2*stencil - 1
    value(16) = temporary + value(22)
    value(15) = value(16) - 1
    if (settings%supersede == 1) then
      if (settings%liolevg == 1) then
        value(5) = settings%nuflev
        value(6) = settings%nuflev
      end if
    else if (settings%liolevg == 1) then
      value(6) = value(5)
    end if
    if (settings%lr2d == 1 .or. settings%nconf == 923 .or. &
        (settings%nconf >= 931 .and. settings%nconf <= 933)) then
      value(5) = 1
      value(6) = 1
    end if
    if (value(5) < 1 .or. value(5) > value(6) .or. value(6) > 1048576) return
    value(28) = 1 - settings%lr2d
    value(27) = settings%lr2d
    value(26) = value(5) + value(28)
    output%ndglg = value(1)
    output%ndlon = value(2)
    output%ndguxg = value(3)
    output%ndluxg = value(4)
    output%nflevg = value(5)
    output%niolevg = value(6)
    output%nvarmax = value(7)
    output%nmsmax = value(8)
    output%nsmax = value(9)
    output%ncmax = value(10)
    output%nproma = value(11)
    output%nstencilwide = value(12)
    output%loptproma = value(13)
    output%ndgnh = value(14)
    output%ndlsm = value(15)
    output%ndlsur = value(16)
    output%ndlung = value(17)
    output%ndgeng = value(18)
    output%ndgsag = value(19)
    output%ndgsur = value(20)
    output%ndgung = value(21)
    output%ndsur1 = value(22)
    output%nsefre = value(23)
    output%nspec2g = value(24)
    output%nspecg = value(25)
    output%nflen = value(26)
    output%nflsa = value(27)
    output%nflsul = value(28)
    status = 0
  end function
end module forecast_grid_dimensions

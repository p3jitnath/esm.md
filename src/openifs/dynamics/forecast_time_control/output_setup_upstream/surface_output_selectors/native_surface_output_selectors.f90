!> Own the surface-output parameter lists from the admitted setup route.
!! Parameter selectors are dimensionless GRIB identifiers. No weather
!! calculation runs here, and no original model state is imported.
module forecast_surface_output_selectors
  use iso_fortran_env, only: int32
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: native_surface_output_selectors, initialize_surface_output_selectors
  integer, parameter :: selector_capacity = 187
  integer(int32), parameter :: source_default_codes(selector_capacity) = [ &
                               128_int32, 139_int32, 39_int32, 228141_int32, 142_int32, 143_int32, 144_int32, 145_int32, &
                               146_int32, 147_int32, 151_int32, 164_int32, 165_int32, 166_int32, 167_int32, 168_int32, &
                               170_int32, 40_int32, 173_int32, 174_int32, 176_int32, 177_int32, 178_int32, 179_int32, &
                               180_int32, 181_int32, 182_int32, 183_int32, 41_int32, 185_int32, 186_int32, 187_int32, &
                               188_int32, 195_int32, 196_int32, 197_int32, 198_int32, 201_int32, 202_int32, 205_int32, &
                               235_int32, 236_int32, 42_int32, 169_int32, 175_int32, 159_int32, 189_int32, 27_int32, &
                               28_int32, 29_int32, 30_int32, 31_int32, 34_int32, 32_int32, 33_int32, 238_int32, &
                               35_int32, 36_int32, 37_int32, 38_int32, 208_int32, 209_int32, 210_int32, 211_int32, &
                               44_int32, 45_int32, 49_int32, 50_int32, 151131_int32, 151132_int32, 228246_int32, 228247_int32, &
                     228015_int32, 228016_int32, 228017_int32, 228018_int32, 228019_int32, 228023_int32, 228024_int32, 3020_int32, &
                         228131_int32, 228132_int32, 228003_int32, 228021_int32, 228022_int32, 228_int32, 134_int32, 228026_int32, &
                               228027_int32, 228028_int32, 121_int32, 122_int32, 123_int32, 59_int32, 228129_int32, 228130_int32, &
                   228001_int32, 260121_int32, 260123_int32, 210207_int32, 210208_int32, 210209_int32, 210210_int32, 210211_int32, &
                   210212_int32, 210250_int32, 210251_int32, 215226_int32, 210244_int32, 210243_int32, 210072_int32, 228008_int32, &
                   228009_int32, 228010_int32, 228011_int32, 228012_int32, 228013_int32, 228014_int32, 228226_int32, 228227_int32, &
                   228222_int32, 228223_int32, 228224_int32, 228225_int32, 228219_int32, 228218_int32, 228221_int32, 228220_int32, &
                   260015_int32, 228217_int32, 228088_int32, 228029_int32, 228251_int32, 210073_int32, 210074_int32, 228216_int32, &
                   228050_int32, 228051_int32, 228052_int32, 228053_int32, 260109_int32, 228046_int32, 228047_int32, 228048_int32, &
                          47_int32, 260510_int32, 260511_int32, 228044_int32, 207_int32, 228249_int32, 214002_int32, 214003_int32, &
                   174098_int32, 151148_int32, 151145_int32, 151163_int32, 151130_int32, 260048_int32, 228035_int32, 228036_int32, &
                   162071_int32, 162072_int32, 228057_int32, 228058_int32, 228059_int32, 228060_int32, 228239_int32, 228247_int32, &
                   228249_int32, 174096_int32, 228020_int32, 228235_int32, 228231_int32, 228233_int32, 228232_int32, 228234_int32, &
                      228237_int32, 228045_int32, 141_int32, 228038_int32, 228104_int32, 260320_int32, 260321_int32, 260339_int32, &
                               260318_int32, 260319_int32, 260338_int32]
  integer(int32), parameter :: source_late_codes(101) = [ &
                               164_int32, 165_int32, 166_int32, 167_int32, 168_int32, 174096_int32, 185_int32, 186_int32, &
                               187_int32, 188_int32, 159_int32, 229_int32, 230_int32, 231_int32, 232_int32, 128_int32, &
                               243_int32, 151_int32, 134_int32, 244_int32, 245_int32, 162071_int32, 162072_int32, 136_int32, &
                               137_int32, 78_int32, 79_int32, 59_int32, 206_int32, 228089_int32, 228090_int32, 228246_int32, &
                     228247_int32, 228003_int32, 228023_int32, 228024_int32, 3020_int32, 228020_int32, 228001_int32, 228044_int32, &
                   228035_int32, 228036_int32, 228235_int32, 228237_int32, 228231_int32, 228233_int32, 228232_int32, 228234_int32, &
                   260121_int32, 260123_int32, 260109_int32, 228046_int32, 228045_int32, 228047_int32, 228048_int32, 228131_int32, &
                   228132_int32, 228015_int32, 228016_int32, 228017_int32, 228008_int32, 228009_int32, 228010_int32, 228011_int32, &
                   228012_int32, 228013_int32, 228014_int32, 228018_int32, 228019_int32, 260048_int32, 228219_int32, 228218_int32, &
                   228221_int32, 228220_int32, 260015_int32, 228217_int32, 228088_int32, 228029_int32, 260510_int32, 260511_int32, &
                      207_int32, 228249_int32, 228050_int32, 228052_int32, 210049_int32, 210050_int32, 210051_int32, 210208_int32, &
                   215226_int32, 210209_int32, 210210_int32, 210211_int32, 210212_int32, 210244_int32, 210243_int32, 210072_int32, &
                               210073_int32, 210074_int32, 214002_int32, 214003_int32, 228104_int32]
  !> Retain one final-address owner until its last output consumer finishes.
  !! Counts and parameter codes have no units. The early list has187 slots,
  !! and its prefix1:no2dgg is active. The late list also has187 slots, and
  !! only1:no2dggl is written by this setup. Its remaining slots retain their
  !! incoming values and must not be read by a consumer. The caller owns
  !! this record and supplies TARGET when publishing retained pointers.
  type :: native_surface_output_selectors
    logical :: ready = .false.
    integer(int32) :: no2dgg, no2dggl
    integer(int32) :: m2dggp(selector_capacity), m2dggpl(selector_capacity)
  end type
contains
  !> Initialise one fresh selector owner for the supported ECMWF route.
  !! text is a readonly first namelist file of1:262144 characters.
  !! lecmwf is the actual produced setup flag. A true value and an empty
  !! first NAMPPC group admit this route. output is caller-owned INOUT
  !! storage; failure changes no member. Success returns0, writes every
  !! early-list slot and the active late prefix, and publishes ready last.
  !! Refusal returns2. This source-only port has no numerical acceptance.
  integer(int32) function initialize_surface_output_selectors(text, lecmwf, output) result(status)
    character(len=*), intent(in) :: text
    logical, intent(in) :: lecmwf
    type(native_surface_output_selectors), intent(inout) :: output
    integer :: j, k, early_count, late_count
    integer(int32) :: parameter_code
    logical :: late
    status = 2_int32
    if (output%ready) return
    if (.not. lecmwf) return
    status = require_empty_physics_group(text, 'NAMPPC')
    if (status /= 0_int32) return
    output%m2dggp = 0_int32
    output%no2dgg = 187_int32
    do j = 1, selector_capacity
      output%m2dggp(j) = source_default_codes(j)
    end do
    early_count = 0
    late_count = 0
    do j = 1, selector_capacity
      parameter_code = output%m2dggp(j)
      late = .false.
      do k = 1, size(source_late_codes)
        if (parameter_code == source_late_codes(k)) then
          late = .true.
          exit
        end if
      end do
      if (late) then
        late_count = late_count + 1
        output%m2dggpl(late_count) = parameter_code
      else
        early_count = early_count + 1
        output%m2dggp(early_count) = parameter_code
      end if
    end do
    output%no2dgg = int(early_count, int32)
    output%no2dggl = int(late_count, int32)
    output%ready = .true.
    status = 0_int32
  end function
end module forecast_surface_output_selectors

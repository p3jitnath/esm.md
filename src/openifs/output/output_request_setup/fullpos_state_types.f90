!> Own the post-processing records through canonical named declarations.
!! Data-only OpenIFS types provide fixed parameters and native allocatable arrays.
!! The halo state has the same single native identity as the model interpolation owner.
module forecast_fullpos_state_types
  use yomfpcnt, only: tfpcnt
  use yomfpgeometry, only: tfpgeometry
  use yomvert, only: tvab
  use yomfpfilters, only: tfpfilters
  use forecast_interpolation_state_types, only: native_interpolation_state
  use yomwfpb, only: tfpwstd, tfpsuw
  use yomafn, only: tafn
  use yomfpop, only: tfpioh
  use yomfpc, only: tnamfpsci, tnamfpint
  use type_fposbuf, only: fposbuf
  implicit none
  private
  public :: native_fullpos_state, native_fullpos_data
  type :: native_fullpos_state
    type(tfpcnt) :: yfpcnt
    type(tfpgeometry) :: yfpgeometry
    type(tvab) :: yfpvab
    type(tfpfilters) :: yfpfilters
    type(native_interpolation_state) :: yfpstruct
    type(tfpwstd) :: yfpwstd
    type(tfpioh) :: yfpioh
    type(tafn) :: yafn
    type(tnamfpsci) :: ynamfpsci
    type(tnamfpint) :: ynamfpint
  end type
  type :: native_fullpos_data
    logical :: lfpupdsuw = .true.
    type(tfpsuw) :: yfpsuw
    logical :: lfpupdcli = .true.
    type(fposbuf) :: yfpclimo
    type(native_fullpos_state), pointer :: yfpos => null()
  end type
end module forecast_fullpos_state_types

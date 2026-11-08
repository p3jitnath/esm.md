!> Own the four native records used by the selected radiation climate input.
module native_radiation_climate_records
  use yomsolarirradiance, only: tsolarirradiance
  use yomghgtimeseries, only: tghgtimeseries
  use yomclim, only: tghgclim
  use yoeradghg, only: tradghg
  implicit none
  private
  public :: radiation_climate_context
  !> Caller owns one allocatable context and its thirty-two array owners.
  !! These are canonical data-only type identities. The native reader and
  !! numerical children supply all values, without calling original methods.
  type :: radiation_climate_context
    type(tsolarirradiance) :: solar
    type(tghgtimeseries) :: timeseries
    type(tghgclim) :: climatology
    type(tradghg) :: radiation
  end type
end module native_radiation_climate_records

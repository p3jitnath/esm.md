!> Public native interfaces for the five selected source aerosol tables.
module native_tegen_literal_readers
  use native_tegen_black_carbon_reader, only: read_tegen_black_carbon
  use native_tegen_organic_aerosol_reader, only: read_tegen_organic_aerosol
  use native_tegen_soil_dust_reader, only: read_tegen_soil_dust
  use native_tegen_sea_salt_reader, only: read_tegen_sea_salt
  use native_tegen_sulfate_reader, only: read_tegen_sulfate
  implicit none
  private
  public :: read_tegen_black_carbon
  public :: read_tegen_organic_aerosol
  public :: read_tegen_soil_dust
  public :: read_tegen_sea_salt
  public :: read_tegen_sulfate
end module native_tegen_literal_readers

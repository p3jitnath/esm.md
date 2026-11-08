!> Read actual produced model controls without creating another output owner.
module forecast_fullpos_upstream_controls
  use iso_fortran_env, only: int32
  use forecast_operational_model_types, only: native_operational_model_configuration
  use forecast_fullpos_file_metadata, only: fullpos_field_metadata_controls
  implicit none
  private
  public :: native_fullpos_upstream_values, make_fullpos_upstream_controls
  !> Borrowed-source string values and dimensionless counts for the next setup.
 !! These values own no numerical payload or persistent Fullpos record.
  type :: native_fullpos_upstream_values
    character(len=16) :: experiment
    character(len=256) :: climate_output
    character(len=8) :: surfex_extension
    integer(int32) :: snow_levels, satellite_count
  end type
contains
  !> Project canonical model fields and four explicit earlier source values.
 !! NPRINTLEV is the retained initial-constructor argument. SATELLITE_COUNT
 !! comes from the actual satellite setup. Climate names come from YOMOPH0's
 !! native replacement producer; this helper does not supply their defaults.
 !! Every input stays read-only and both outputs change only on success.
 integer(int32) function make_fullpos_upstream_controls(model,nprintlev,satellite_count,climate_output,surfex_extension,metadata_controls,values)result(status)
    type(native_operational_model_configuration), target, intent(in) :: model
    integer(int32), intent(in) :: nprintlev, satellite_count
    character(*), intent(in) :: climate_output, surfex_extension
    type(fullpos_field_metadata_controls), intent(inout) :: metadata_controls
    type(native_fullpos_upstream_values), intent(inout) :: values
    type(fullpos_field_metadata_controls) :: pending
    type(native_fullpos_upstream_values) :: pv
    integer :: yl, yi, ya, n
    logical :: lgpl, lgpi, lgpa
    status = 2
    if (.not. model%ready .or. .not. associated(model%initial)) return
    if (.not. model%initial%ready) return
    if (.not. allocated(model%initial%geometry) .or. .not. allocated(model%initial%prefix)) return
    n = size(model%fields%components)
    yl = model%fields%aliases%yl; yi = model%fields%aliases%yi; ya = model%fields%aliases%ya
    if (min(yl, yi, ya) < 1 .or. max(yl, yi, ya) > n) return
    if (any([model%fields%components(yl)%lgp, model%fields%components(yi)%lgp, model%fields%components(ya)%lgp] < 0)) return
    if (any([model%fields%components(yl)%lgp, model%fields%components(yi)%lgp, model%fields%components(ya)%lgp] > 1)) return
    if (nprintlev < 0 .or. satellite_count < 0) return
    if (len(climate_output) /= 256 .or. len(surfex_extension) /= 8) return
    if (model%physics_dimensions%ncsnec < 0) return
    if (model%initial%geometry%stream%nrealen /= 8) return
    lgpl = model%fields%components(yl)%lgp /= 0
    lgpi = model%fields%components(yi)%lgp /= 0
    lgpa = model%fields%components(ya)%lgp /= 0
    pending%kfpconf = 0
    pending%nprintlev = nprintlev
    pending%nconf = model%initial%controls%namespace%nconf
    pending%ngribfile = model%initial%prefix%headers%ngribfile
    pending%nrealen = model%initial%geometry%stream%nrealen
    pending%ldnhdyn = model%dynamics%lnhdyn
    pending%larpegef = model%initial%controls%namespace%larpegef /= 0
    pending%lelam = model%initial%controls%namespace%lelam /= 0
    pending%lecmwf = model%initial%controls%namespace%lecmwf /= 0
    pending%larome = model%initial%controls%namespace%larome /= 0
 pending%ldnewcl(1)=.not.lgpl.and..not.lgpi.and..not.lgpa.and..not.model%physics%nonlinear_physics%lepcld2.and.model%physics%nonlinear_physics%lencld2
    pending%ldnewcl(2) = .not. lgpa .and. model%physics%nonlinear_physics%lepcld2
    pv%experiment = model%initial%controls%namespace%cnmexp
    pv%climate_output = climate_output
    pv%surfex_extension = surfex_extension
    pv%snow_levels = model%physics_dimensions%ncsnec
    pv%satellite_count = satellite_count
    metadata_controls = pending
    values = pv
    status = 0
  end function
end module

!> Own the selected one-domain output names and filter-control values.
module forecast_fullpos_io_scheme
  use iso_fortran_env, only: int32, int64, real64
  use yomfpios, only: tnamfpios
  use yomfpf, only: tnamfpf
  use forecast_empty_physics_configuration, only: require_empty_physics_group
  implicit none
  private
  public :: native_fullpos_output_names, initialize_fullpos_io_scheme, initialize_fullpos_filter_controls
  !> Three180-character names and the canonical six I/O controls.
  type :: native_fullpos_output_names
    type(tnamfpios) :: controls
    character(len=180) :: filename(1), climate_filename(1), surfex_filename(1)
  end type
contains
  !> Construct source filenames from live upstream strings without formatting I/O.
 !! Text is read-only. OUTPUT is caller-owned and changes only on success.
 !! One ECMWF domain and the inactive Surfex branch are supported.
 integer(int32) function initialize_fullpos_io_scheme(text,kfpgrib,kfpsurfex,larpegef,cnmexp,cfnclimout,cfpextsfx,directory,domain,output)result(status)
    character(*), intent(in) :: text, cnmexp, cfnclimout, cfpextsfx, directory, domain
    integer(int32), intent(in) :: kfpgrib, kfpsurfex
    logical, intent(in) :: larpegef
    type(native_fullpos_output_names), intent(inout) :: output
    integer :: last
    status = 2_int32
    if (len(text) < 1 .or. len(text) > 262144 .or. kfpsurfex /= 0 .or. larpegef) return
    if (len(cnmexp) /= 16 .or. len(cfnclimout) /= 256 .or. len(cfpextsfx) /= 8) return
    if (len(directory) /= 180 .or. len(domain) /= 20) return
    last = len_trim(cfnclimout)
    if (last < 1) return
    status = require_empty_physics_group(text, 'NAMFPIOS')
    if (status /= 0_int32) return
    output%controls%nfpgrib = kfpgrib
    output%controls%nfpwrite = 1_int32
    output%controls%nfpxfld = -999_int32
    output%controls%nfpdigits = 6_int32
    output%controls%lfppgdfwr = .false.
    output%controls%lfphisfwr = .false.
    output%filename(1) = trim(directory)//cnmexp(1:4)//trim(domain)
    output%climate_filename(1) = trim(cfnclimout)//trim(domain)
    output%surfex_filename(1) = cfnclimout(1:last - 1)//trim(cfpextsfx)//cfnclimout(last:last)//trim(domain)
    status = 0_int32
  end function
  !> Publish the selected SUFPF defaults after the first empty NAMFPF group.
 !! The three real constants retain their original compiled FP64 words.
 !! This setup selects configuration0 on an unstretched global grid.
  integer(int32) function initialize_fullpos_filter_controls(text, kfpconf, lelam, output) result(status)
    character(*), intent(in) :: text
    integer(int32), intent(in) :: kfpconf
    logical, intent(in) :: lelam
    type(tnamfpf), intent(inout) :: output
    status = 2_int32
    if (kfpconf /= 0 .or. lelam .or. len(text) < 1 .or. len(text) > 262144) return
    status = require_empty_physics_group(text, 'NAMFPF')
    if (status /= 0_int32) return
    output%lfpbed = .true.
    output%lfpwrfil = .false.
    output%lfprdfil = .false.
    output%nfpreadall = 1_int32
    output%nfpglfi = 12_int32
    output%nfpcmax = 0_int32
    output%nfmax(:) = 0_int32
    output%rfpmaxdev = transfer(int(z'3ddb7cdfd9d7bdbb', int64), 0.0_real64)
    output%rfpltf = transfer(int(z'4010000000000000', int64), 0.0_real64)
    output%rfpbed = transfer(int(z'4008ac0b56d32fe7', int64), 0.0_real64)
    output%rfpsel(:) = 1.0_real64
    output%cfpdila = 'MATDILA'
    output%cfpcont = 'MATCONT'
    output%cfpmatrd(:) = ' '
    output%cfpmatwr(:) = ' '
    status = 0_int32
  end function
end module

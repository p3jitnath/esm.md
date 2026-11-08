!> Register constituent fields using the existing native GFL namespace.
module forecast_registry_constituents
  use iso_fortran_env, only: int32, real64
  use forecast_registry_field_types
  use forecast_registry_motion, only: slice_registry_field_2d, slice_registry_field_3d
  use forecast_registry_storage
  use forecast_native_field_variable_types
  use forecast_registry_registration, only: allocate_field_variables
  use grid_field_component_types_port, only: field_component_metadata
  use grid_field_configuration_types_port, only: grid_field_configuration
  implicit none
contains
  integer(int32) function create_registry_gfl_variable(output, name, component, gfl, gflt1) result(status)
    type(native_registry_variable_3d), intent(inout) :: output
    character(*), intent(in) :: name
    type(field_component_metadata), intent(in) :: component
    real(real64), pointer, intent(in) :: gfl(:, :, :, :), gflt1(:, :, :, :)
    real(real64), pointer :: section(:, :, :)
    integer(int32) :: indices(6)
    status = initialize_registry_variable(output, name)
    if (status /= 0) return
    output%cname = component%cname; output%igrbcode = component%igrbcode
    output%lactive = component%lactive /= 0; output%ladv = component%ladv /= 0
    output%lt1 = component%lt1 /= 0; output%lt9 = component%lt9 /= 0; output%lph9 = component%lphy /= 0
    indices = [component%mp, component%mp1, component%mp9, component%mp9_ph, component%mpl, component%mpm]
    status = 0
    if (component%lactive == 0) return
    if (indices(1) > 0) then
      allocate (output%ft0, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      call slice_registry_field_3d(section, gfl, indices(1))
      status = wrap_registry_field_3d(output%ft0, section)
      if (status /= 0) return
    end if
    if (indices(2) > 0) then
      allocate (output%ft1, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      call slice_registry_field_3d(section, gflt1, indices(2))
      status = wrap_registry_field_3d(output%ft1, section)
      if (status /= 0) return
    end if
    if (indices(3) > 0) then
      allocate (output%ft9, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      call slice_registry_field_3d(section, gfl, indices(3))
      status = wrap_registry_field_3d(output%ft9, section)
      if (status /= 0) return
    end if
    if (indices(4) > 0) then
      allocate (output%fph9, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      call slice_registry_field_3d(section, gfl, indices(4))
      status = wrap_registry_field_3d(output%fph9, section)
      if (status /= 0) return
    end if
    if (indices(5) > 0) then
      allocate (output%fdl, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      call slice_registry_field_3d(section, gfl, indices(5))
      status = wrap_registry_field_3d(output%fdl, section)
      if (status /= 0) return
    end if
    if (indices(6) > 0) then
      allocate (output%fdm, stat=status)
      if (status /= 0) then
        status = 1; return
      end if
      call slice_registry_field_3d(section, gfl, indices(6))
      status = wrap_registry_field_3d(output%fdm, section)
      if (status /= 0) return
    end if
    status = 0
  end function
  integer(int32) function create_registry_gfl_array(output, name, components, gfl, gflt1) result(status)
    type(native_registry_variable_3d), pointer, intent(inout) :: output(:)
    character(*), intent(in) :: name
    type(field_component_metadata), intent(in) :: components(:)
    real(real64), pointer, intent(in) :: gfl(:, :, :, :), gflt1(:, :, :, :)
    integer :: index, allocation_status
    character(16) :: field_name
    status = 2
    if (size(components) > 255) return
    allocate (output(size(components)), stat=allocation_status)
    if (allocation_status /= 0) then
      status = 1; return
    end if
    do index = 1, size(components)
      field_name = name
      if (len(name) < 16) field_name(len(name) + 1:len(name) + 1) = "_"
      if (len(name) + 1 < 16) field_name(len(name) + 2:len(name) + 2) = achar(index)
      status = create_registry_gfl_variable(output(index), field_name, components(index), gfl, gflt1)
      if (status /= 0) return
    end do
    status = 0
  end function
  integer(int32) function register_registry_gfl(output, configuration, gfl, gflt1, extra_aliases) result(status)
    type(native_field_variables), pointer, intent(inout) :: output
    type(grid_field_configuration), intent(in) :: configuration
    real(real64), pointer, intent(in) :: gfl(:, :, :, :), gflt1(:, :, :, :)
    type(native_registry_extra_aliases), intent(in) :: extra_aliases
    integer :: first, count
    status = allocate_field_variables(output)
    if (status /= 0) return
    first = configuration%aliases%yq
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%q, 'Q', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yi
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%i, 'I', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yl
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%l, 'L', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ylconv
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%lconv, 'LCONV', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yiconv
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%iconv, 'ICONV', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yrconv
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%rconv, 'RCONV', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ysconv
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%sconv, 'SCONV', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yirad
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%irad, 'IRAD', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ylrad
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%lrad, 'LRAD', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ys
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%s, 'S', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yr
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%r, 'R', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yg
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%g, 'G', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yh
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%h, 'H', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ytke
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%tke, 'TKE', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ytte
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%tte, 'TTE', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yefb1
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%efb1, 'EFB1', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yefb2
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%efb2, 'EFB2', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yefb3
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%efb3, 'EFB3', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ya
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%a, 'A', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yo3
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%o3, 'O3', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ysrc
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%src, 'SRC', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ymxl
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%mxl, 'MXL', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yshtur
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%shtur, 'SHTUR', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yfqtur
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%fqtur, 'FQTUR', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yfstur
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%fstur, 'FSTUR', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ycpf
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%cpf, 'CPF', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yspf
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%spf, 'SPF', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ycvgq
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%cvgq, 'CVGQ', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yqva
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%qva, 'QVA', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yghg%first_index; count = configuration%aliases%yghg%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%ghg_g, 'GHG', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%ghg => output%ghg_g
    first = configuration%aliases%ychem%first_index; count = configuration%aliases%ychem%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%chem_g, 'CHEM', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%chem => output%chem_g
    first = configuration%aliases%yaero%first_index; count = configuration%aliases%yaero%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%aero_g, 'AERO', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%aero => output%aero_g
    first = configuration%aliases%ylrch4
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%lrch4, 'LRCH4', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yforc%first_index; count = configuration%aliases%yforc%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%forc_g, 'FORC', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%forc => output%forc_g
    first = configuration%aliases%yezdiag%first_index; count = configuration%aliases%yezdiag%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%ezdiag_g, 'EZDIAG', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%ezdiag => output%ezdiag_g
    first = configuration%aliases%yera40%first_index; count = configuration%aliases%yera40%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%era40_g, 'ERA40', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%era40 => output%era40_g
    first = configuration%aliases%ynogw%first_index; count = configuration%aliases%ynogw%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%nogw_g, 'NOGW', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%nogw => output%nogw_g
    first = configuration%aliases%yemis3d%first_index; count = configuration%aliases%yemis3d%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%emis3d_g, 'EMIS3D', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%emis3d => output%emis3d_g
    first = configuration%aliases%yedrp%first_index; count = configuration%aliases%yedrp%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%edrp_g, 'EDRP', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%edrp => output%edrp_g
    first = configuration%aliases%ysldia%first_index; count = configuration%aliases%ysldia%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%sldia_g, 'SLDIA', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%sldia => output%sldia_g
    first = configuration%aliases%yaeraot%first_index; count = configuration%aliases%yaeraot%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%aeraot_g, 'AERAOT', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%aeraot => output%aeraot_g
    first = configuration%aliases%yaerlisi%first_index; count = configuration%aliases%yaerlisi%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%aerlisi_g, 'AERLISI', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%aerlisi => output%aerlisi_g
    first = configuration%aliases%yaerout%first_index; count = configuration%aliases%yaerout%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%aerout_g, 'AEROUT', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%aerout => output%aerout_g
    first = configuration%aliases%yaeroclim%first_index; count = configuration%aliases%yaeroclim%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%aeroclim_g, 'AEROCLIM', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%aeroclim => output%aeroclim_g
    first = configuration%aliases%yuvp%first_index; count = configuration%aliases%yuvp%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%uvp_g, 'UVP', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%uvp => output%uvp_g
    if (associated(extra_aliases%phys)) then
      status = create_registry_gfl_array(output%phys_g, 'PHYS', extra_aliases%phys, gfl, gflt1)
    else
      status = create_registry_gfl_array(output%phys_g, 'PHYS', configuration%components(1:0), gfl, gflt1)
    end if
    if (status /= 0) return
    output%phys => output%phys_g
    first = configuration%aliases%yphycty
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%phycty, 'PHYCTY', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yrspec
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%rspec, 'RSPEC', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ysdsat
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%sdsat, 'SDSAT', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ycvv
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%cvv, 'CVV', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yrkth
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%rkth, 'RKTH', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yrktqv
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%rktqv, 'RKTQV', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yrktqc
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%rktqc, 'RKTQC', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yuom
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%uom, 'UOM', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yual
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%ual, 'UAL', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ydom
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%dom, 'DOM', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ydal
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%dal, 'DAL', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yuen
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%uen, 'UEN', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yunebh
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%unebh, 'UNEBH', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%ylima%first_index; count = configuration%aliases%ylima%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%lima_g, 'LIMA', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%lima => output%lima_g
    first = configuration%aliases%yfsd
    status = 2
    if (first < 1 .or. first > size(configuration%components)) return
    status = create_registry_gfl_variable(output%fsd, 'FSD', configuration%components(first), gfl, gflt1)
    if (status /= 0) return
    first = configuration%aliases%yext%first_index; count = configuration%aliases%yext%count
    if (count == 0) first = 1
    status = create_registry_gfl_array(output%ext_g, 'EXT', configuration%components(first:first + count - 1), gfl, gflt1)
    if (status /= 0) return
    output%ext => output%ext_g
  end function
end module forecast_registry_constituents

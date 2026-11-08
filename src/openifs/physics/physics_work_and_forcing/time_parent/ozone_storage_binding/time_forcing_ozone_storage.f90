!> Bind the genuine SUALLO TOZO allocation to the actual forecast owners.
!! This is count-zero setup support. It writes no scientific scalar or payload.
module forecast_time_forcing_ozone_storage
  use iso_fortran_env, only: int32, int64
  use forecast_selected_model_storage, only: native_selected_model_storage
  use forecast_model_time_and_forcing, only: native_time_and_forcing_context
  use forecast_native_ozone_chemistry_update, only: initialize_ozone_chemistry_global_storage
  implicit none
  private
  public :: initialize_time_forcing_ozone_global_storage
contains
!> Reproduce SUALLO's global ozone allocation after real dimension production.
!! BYTE_LIMIT bounds owned payload bytes separately from the containing context.
!! NVCLIS, NTOZ2D, layer count and latitude bounds come from actual native owners.
!! Source-unwritten TOZO%TEECL2 and all newly allocated FP64 words stay untouched.
!! The actual UPDO3CH reader produces TEECL2 and physical global rows later.
  integer(int32) function initialize_time_forcing_ozone_global_storage(storage, context, byte_limit) result(status)
    type(native_selected_model_storage), target, intent(in) :: storage
    type(native_time_and_forcing_context), target, intent(inout) :: context
    integer(int64), intent(in) :: byte_limit
    integer(int64) :: coefficients
    status = 2
    if (.not. associated(storage%model%initial)) return
    if (.not. allocated(storage%model%initial%geometry)) return
    if (.not. storage%model%ready .or. .not. storage%model%initial%ready) return
    associate (g => storage%model%initial%geometry%dimensions, d => storage%model%physics_dimensions)
    if (storage%model%initial%controls%namespace%lecmwf == 0) then
      status = 0; return
    end if
    if (storage%model%initial%controls%namespace%lecmwf /= 1) return
    if (d%nvclis < 0 .or. d%ntoz2d < 0) return
    coefficients = int(d%nvclis, int64)*int(d%ntoz2d, int64)
    if (coefficients == 0) then
      status = 0; return
    end if
    if (coefficients /= 7 .or. g%ndgsag /= -1 .or. g%ndgeng /= g%ndglg + 2) return
status = initialize_ozone_chemistry_global_storage(context%ozone_chemistry, g%nflevg, g%ndglg, int(coefficients, int32), byte_limit)
    end associate
  end function
end module

!> Preserve the integer diagnostic words of the expanded departure sources.
!! The selected and explicit-runtime source contexts keep separate word banks.
!! These source counters are not atomic, matching the original source words.
!! Index0:4 records LARCINA,parent then LASCAW,linear,cubic,WENO;5:6 records
!! completed LARMES and reporting calculations;7 completed LAPINEA;8:9
!! completed LAPINEB and its completed finite-element vertical child.
module forecast_departure_source_counters
  use iso_fortran_env, only: int32, int64
  use md2asm_transform_profile_policy, only: increment_source_counter
  implicit none
  private
  integer(int64), save :: words(0:9, 0:1) = 0_int64
  public :: departure_source_hit, departure_source_word
contains
  subroutine departure_source_hit(context, index)
    integer(int32), intent(in) :: context, index
    if (context < 0 .or. context > 1 .or. index < 0 .or. index > 9) return
    call increment_source_counter(words(index, context))
  end subroutine
  integer(int64) function departure_source_word(context, index) result(value)
    integer(int32), intent(in) :: context, index
    value = 0_int64
    if (context >= 0 .and. context <= 1 .and. index >= 0 .and. index <= 9) value = words(index, context)
  end function
end module forecast_departure_source_counters

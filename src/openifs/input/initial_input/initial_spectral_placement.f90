module forecast_initial_spectral_placement
  !! Place complete decoded messages into native spectral arrays.
  !! This ports spectral_initial_state_placement.S and the operational sibling.
  !! Arrays are disjoint caller-owned FP64 buffers; no field units change.
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  implicit none
  private
  public :: place_initial_spectral_fields, place_operational_spectral_fields
contains
  integer(int32) function place_initial_spectral_fields(values, metadata, spectral, surface) result(status)
    !! Selected T21/L19: values(506,at least78), metadata(3,at least78),
    !! spectral(19,506,at least3), surface(506,at least2).
    !! Status1 refuses bounds and2 refuses a complete metadata label set.
    !! Refusal changes no output. Larger final-field tails stay unchanged.
    real(real64), contiguous, intent(in) :: values(:, :)
    integer(int64), contiguous, intent(in) :: metadata(:, :)
    real(real64), contiguous, intent(inout) :: spectral(:, :, :), surface(:, :)
    status = place_complete_spectral_fields(values, metadata, spectral, surface, 506, 19, 78)
  end function

  integer(int32) function place_operational_spectral_fields(values, metadata, spectral, surface) result(status)
    !! Operational T1279/L137: values(1639680,at least413),
    !! metadata(3,at least413), spectral(137,1639680,at least3),
    !! surface(1639680,at least2). All input and output owners are disjoint.
    real(real64), contiguous, intent(in) :: values(:, :)
    integer(int64), contiguous, intent(in) :: metadata(:, :)
    real(real64), contiguous, intent(inout) :: spectral(:, :, :), surface(:, :)
    status = place_complete_spectral_fields(values, metadata, spectral, surface, 1639680, 137, 413)
  end function

 integer(int32) function place_complete_spectral_fields(values,metadata,spectral,surface,coefficients,levels,records) result(status)
    real(real64), contiguous, intent(in) :: values(:, :)
    integer(int64), contiguous, intent(in) :: metadata(:, :)
    real(real64), contiguous, intent(inout) :: spectral(:, :, :), surface(:, :)
    integer, intent(in) :: coefficients, levels, records
    integer(int32), parameter :: upper_codes(3) = [138, 155, 130]
    integer :: record, parameter, level, field, coefficient
    status = 1
    if (size(values, 1) /= coefficients .or. size(values, 2) < records) return
    if (size(metadata, 1) /= 3 .or. size(metadata, 2) < records) return
    if (size(spectral, 1) /= levels .or. size(spectral, 2) /= coefficients .or. size(spectral, 3) < 3) return
    if (size(surface, 1) /= coefficients .or. size(surface, 2) < 2) return
    status = 2
    do record = 1, records
      if (record == 1) then
        parameter = 152; level = 1
      else if (record <= 3*levels + 1) then
        parameter = upper_codes(mod(record - 2, 3) + 1); level = (record - 2)/3 + 1
      else if (record == 3*levels + 2) then
        parameter = 129; level = 0
      else
        parameter = 133; level = record - (3*levels + 2)
      end if
      if (metadata(1, record) /= int(parameter, int64) .or. metadata(2, record) /= int(level, int64)) return
      if (metadata(3, record) /= int(coefficients, int64)) return
    end do
    do field = 1, 3
      do level = 1, levels
        record = 3*(level - 1) + field + 1
        do coefficient = 1, coefficients
          spectral(level, coefficient, field) = values(coefficient, record)
        end do
      end do
    end do
    do coefficient = 1, coefficients
      surface(coefficient, 1) = values(coefficient, 1)
    end do
    do coefficient = 1, coefficients
      surface(coefficient, 2) = values(coefficient, 3*levels + 2)
    end do
    status = 0
  end function
end module forecast_initial_spectral_placement

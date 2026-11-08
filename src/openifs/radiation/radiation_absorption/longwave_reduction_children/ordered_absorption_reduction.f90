!> Ordered absorption sums shared by longwave and shortwave setup.
module ordered_absorption_reduction
  use iso_c_binding, only: c_double, c_int
  implicit none
  private
  public :: reduce_absorption_field
contains
  !> Combine consecutive original samples while retaining every FP64 rounding.
  !! source(cells,samples) and optional weights(samples) are read-only.
  !! destination(cells,groups) is replaced. All reals have kind c_double.
  !! group_counts(groups) uses int32, has positive entries, and sums to samples.
  !! The caller owns disjoint contiguous arrays and admits these exact shapes.
  !! A cell is one independent coefficient. Weights are dimensionless; output
  !! retains the units of source. Nearest rounding and gradual underflow apply.
  subroutine reduce_absorption_field(source, destination, group_counts, weights)
    real(c_double), contiguous, intent(in) :: source(:, :)
    real(c_double), contiguous, intent(inout) :: destination(:, :)
    integer(c_int), contiguous, intent(in) :: group_counts(:)
    real(c_double), contiguous, optional, intent(in) :: weights(:)
    integer :: cell, group, sample, term
    real(c_double) :: total, product
    if (present(weights)) then
      do cell = 1, size(source, 1)
        sample = 1
        do group = 1, size(group_counts)
          total = 0.0_c_double
          do term = 1, group_counts(group)
            product = source(cell, sample)*weights(sample)
            total = total + product
            sample = sample + 1
          end do
          destination(cell, group) = total
        end do
      end do
    else
      do cell = 1, size(source, 1)
        sample = 1
        do group = 1, size(group_counts)
          total = 0.0_c_double
          do term = 1, group_counts(group)
            total = total + source(cell, sample)
            sample = sample + 1
          end do
          destination(cell, group) = total
        end do
      end do
    end if
  end subroutine reduce_absorption_field
end module ordered_absorption_reduction

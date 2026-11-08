!> Complete selected Legendre projections, with separately rounded scalar sums.
module md2asm_legendre_matrix_transforms
  use iso_fortran_env, only: int32, real64
  use md2asm_transform_types, only: transform_spectral_tables, transform_environment_ready
  implicit none
  private
  public :: analyse_legendre_wave, reconstruct_legendre_wave
contains
!> Validate the complete T21 matrix route before an allocation or array write.
  logical function basis_ready(t, m, nlat)
    type(transform_spectral_tables), intent(in) :: t
    integer, intent(in) :: m, nlat
    integer :: a, s, k
    basis_ready = .false.
    if (t%maximum_degree /= 21 .or. t%total_degree /= 21 .or. t%butterfly) return
    if (m < 0 .or. m > 21 .or. nlat /= 16) return
    if (.not. allocated(t%basis)) return
    if (m + 1 < lbound(t%basis, 1) .or. m + 1 > ubound(t%basis, 1)) return
    k = m + 1
    if (.not. associated(t%basis(k)%antisymmetric)) return
    if (.not. associated(t%basis(k)%symmetric)) return
    a = (21 - m + 2)/2; s = (21 - m + 3)/2
    if (size(t%basis(k)%antisymmetric, 1) /= 16 .or. size(t%basis(k)%symmetric, 1) /= 16) return
    if (size(t%basis(k)%antisymmetric, 2) < a .or. size(t%basis(k)%symmetric, 2) < s) return
    basis_ready = transform_environment_ready()
  end function
!> Analyse immutable antisymmetric/symmetric (field,latitude) arrays.
!! Weights are dimensionless half-Gaussian weights. Output (degree,field)
!! keeps all unselected rows and the order-zero imaginary columns.
  subroutine analyse_legendre_wave(t,m,local_m,width,selected,first_latitude,latitudes,output_width,anti,sym,output,weights,status)
    type(transform_spectral_tables), intent(in) :: t
    integer(int32), intent(in) :: m, local_m, width, selected, first_latitude, latitudes, output_width
    real(real64), intent(in) :: anti(:, :), sym(:, :), weights(:)
    real(real64), intent(inout) :: output(:, :)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: weighted(:, :, :)
    real(real64) :: sum_value, product
    integer :: stride, j, k, c, field, na, ns, ia, is, alloc_status
    status = 2
    if (m < 0 .or. m > 21 .or. local_m /= m + 1) return
    if (.not. any(width == [10, 38, 40, 76, 116])) return
    if (selected < 0 .or. latitudes < 0) return
    if (selected == 0 .or. latitudes == 0) then
      status = 0; return
    end if
    stride = 1; if (m == 0) stride = 2
    if (selected /= width/stride .or. first_latitude /= 1 .or. output_width /= width) return
    if (.not. basis_ready(t, m, latitudes)) return
    na = (21 - m + 2)/2; ns = (21 - m + 3)/2; ia = 1 + mod(21 - m + 2, 2); is = 1 + mod(21 - m + 1, 2)
    if (size(anti, 1) < width .or. size(sym, 1) < width) return
    if (size(anti, 2) < latitudes .or. size(sym, 2) < latitudes .or. size(weights) < latitudes) return
    if (size(output, 1) < 22 - m .or. size(output, 2) < width) return
    allocate (weighted(latitudes, selected, 2), stat=alloc_status)
    if (alloc_status /= 0) then
      status = 1; return
    end if
    c = 0
    do field = 1, width, stride
      c = c + 1
      do j = 1, latitudes
        weighted(j, c, 1) = anti(field, j)*weights(j)
      end do
    end do
    c = 0
    do field = 1, width, stride
      c = c + 1
      do j = 1, latitudes
        weighted(j, c, 2) = sym(field, j)*weights(j)
      end do
    end do
    c = 0
    do field = 1, width, stride
      c = c + 1
      do k = 1, na
        sum_value = 0.0_real64
        do j = 1, latitudes
          product = t%basis(local_m)%antisymmetric(j, k)*weighted(j, c, 1)
          sum_value = sum_value + product
        end do
        output(ia + 2*(k - 1), field) = sum_value
      end do
    end do
    c = 0
    do field = 1, width, stride
      c = c + 1
      do k = 1, ns
        sum_value = 0.0_real64
        do j = 1, latitudes
          product = t%basis(local_m)%symmetric(j, k)*weighted(j, c, 2)
          sum_value = sum_value + product
        end do
        output(is + 2*(k - 1), field) = sum_value
      end do
    end do
    status = 0
  end subroutine
!> Reconstruct both (field,latitude) outputs from immutable (degree,field) input.
!! All inputs and outputs are separate owners. Output rows above width and
!! latitudes outside the selected range remain unchanged. Values retain units.
  subroutine reconstruct_legendre_wave(t,m,local_m,width,selected,output_fields,first_latitude,latitudes,input,anti,sym,status)
    type(transform_spectral_tables), intent(in) :: t
    integer(int32), intent(in) :: m, local_m, width, selected, output_fields, first_latitude, latitudes
    real(real64), intent(in) :: input(:, :)
    real(real64), intent(inout) :: anti(:, :), sym(:, :)
    integer(int32), intent(out) :: status
    integer :: stride, j, k, field, na, ns, ia, is
    real(real64) :: sum_value, product
    status = 2
    if (m < 0 .or. m > 21 .or. local_m /= m + 1) return
    if (width < 0 .or. selected < 0 .or. latitudes < 0) return
    if (latitudes == 0) then
      status = 0; return
    end if
    if (width == 0) then
      if (selected /= 0 .or. output_fields /= 0) return
      status = 0; return
    end if
    if (.not. any(width == [2, 4, 38, 76, 194, 232])) return
    stride = 1; if (m == 0) stride = 2
    if (selected /= width/stride .or. output_fields /= width/2 .or. first_latitude /= 1) return
    if (.not. basis_ready(t, m, latitudes)) return
    na = (21 - m + 2)/2; ns = (21 - m + 3)/2; ia = 1 + mod(21 - m + 2, 2); is = 1 + mod(21 - m + 1, 2)
    if (size(input, 1) < 24 - m .or. size(input, 2) < width) return
    if (size(anti, 1) < width .or. size(sym, 1) < width) return
    if (size(anti, 2) < latitudes .or. size(sym, 2) < latitudes) return
    if (m == 0) then
      do field = 2, width, 2
        do j = 1, latitudes
          sym(field, j) = 0.0_real64
          anti(field, j) = 0.0_real64
        end do
      end do
    end if
    do field = 1, width, stride
      do j = 1, latitudes
        sum_value = 0.0_real64
        do k = 1, na
          product = t%basis(local_m)%antisymmetric(j, k)*input(ia + 1 + 2*(k - 1), field)
          sum_value = sum_value + product
        end do
        anti(field, j) = sum_value
      end do
    end do
    do field = 1, width, stride
      do j = 1, latitudes
        sum_value = 0.0_real64
        do k = 1, ns
          product = t%basis(local_m)%symmetric(j, k)*input(is + 1 + 2*(k - 1), field)
          sum_value = sum_value + product
        end do
        sym(field, j) = sum_value
      end do
    end do
    status = 0
  end subroutine
end module

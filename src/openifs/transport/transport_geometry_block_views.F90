!> Borrow the initialized spherical geometry of each transport block.
!! This interface changes only pointer views. It does not scale coordinates,
!! form a wind basis or calculate a weather field.
module md2asm_transport_geometry_block_views
  use iso_fortran_env, only: int32, int64, real64
  use forecast_geometry_block_storage, only: native_spherical_block_view
  use md2asm_semi_lagrangian_transport_stage, only: transport_block_views
  implicit none
  private
  public :: bind_transport_geometry_block_views
contains
  !> Bind the existing point-coordinate and wind-basis views without copying.
  !! pitch is the allocated block width;point_count is the local physical count.
  !! geometry and blocks have ceil(point_count/pitch) entries. Their owners must
  !! remain alive and must not be resized until all borrowed views expire.
  !! GEXCO,GEYCO,GEZCO retain their owner's length unit:metres for the selected
  !! operational producer. GELAM is radians;GEMU,GSQM2,GECLO are dimensionless.
  !! GNORDM and GNORDL retain the source wind-basis coefficients. The native
  !! final block may contain only its physical rows. No padding is invented.
  !! Only arrival geometry and north_m/north_l are changed. All other block
  !! fields keep their entry values. Status2 refuses metadata before any
  !! pointer is changed;status0 publishes the complete set of borrowed views.
  !! This binding does not extend a child's separately declared admission.
  subroutine bind_transport_geometry_block_views(pitch, point_count, geometry, blocks, status)
    integer(int32), intent(in) :: pitch, point_count
    type(native_spherical_block_view), intent(in) :: geometry(:)
    type(transport_block_views), intent(inout) :: blocks(:)
    integer(int32), intent(out) :: status
    integer(int64) :: block_count, start
    integer :: j, last
    status = 2
    if (pitch < 1 .or. pitch > 1024 .or. point_count < 1) return
    block_count = (int(point_count, int64) + int(pitch, int64) - 1_int64)/int(pitch, int64)
    if (block_count /= size(geometry, kind=int64) .or. block_count /= size(blocks, kind=int64)) return
    do j = 1, size(geometry)
      start = int(j - 1, int64)*int(pitch, int64)
      last = int(min(int(pitch, int64), int(point_count, int64) - start))
      if (.not. usable(geometry(j)%gexco, last) .or. .not. usable(geometry(j)%geyco, last)) return
      if (.not. usable(geometry(j)%gezco, last) .or. .not. usable(geometry(j)%gelam, last)) return
      if (.not. usable(geometry(j)%gemu, last) .or. .not. usable(geometry(j)%gsqm2, last)) return
      if (.not. usable(geometry(j)%geclo, last)) return
      if (.not. usable(geometry(j)%gnordm, last) .or. .not. usable(geometry(j)%gnordl, last)) return
    end do
    do j = 1, size(geometry)
      blocks(j)%arrival%x => geometry(j)%gexco
      blocks(j)%arrival%y => geometry(j)%geyco
      blocks(j)%arrival%z => geometry(j)%gezco
      blocks(j)%arrival%longitude => geometry(j)%gelam
      blocks(j)%arrival%latitude_sine => geometry(j)%gemu
      blocks(j)%arrival%latitude_cosine => geometry(j)%gsqm2
      blocks(j)%arrival%longitude_cosine => geometry(j)%geclo
      blocks(j)%north_m => geometry(j)%gnordm
      blocks(j)%north_l => geometry(j)%gnordl
    end do
    status = 0
  end subroutine

  !> Check metadata only;no floating-point value is read.
  logical function usable(view, last)
    real(real64), pointer, intent(in) :: view(:)
    integer, intent(in) :: last
    usable = .false.
    if (.not. associated(view)) return
    if (lbound(view, 1) /= 1 .or. size(view) < last) return
    if (.not. is_contiguous(view)) return
    usable = .true.
  end function
end module md2asm_transport_geometry_block_views

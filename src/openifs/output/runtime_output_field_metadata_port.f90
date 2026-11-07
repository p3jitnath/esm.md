!> Build typed field and level metadata for the output writers.
!! Integer identifiers have no units. levels keep their caller-defined units.
!! This source follows the allocation and field order in our generated SUVFPOSL.
module runtime_output_field_metadata_port
  use, intrinsic :: iso_fortran_env, only: int32,int64,real64
  implicit none
  private
  public :: output_metadata_request,output_field_metadata
  public :: create_output_field_metadata,release_output_field_metadata
  type :: output_metadata_request
    integer(int32), allocatable :: field_ids(:),spectral_by_field(:),level_counts(:)
    integer(int32), allocatable :: level_indices(:,:)
    integer(int32), allocatable :: domain_counts(:,:),domain_indices(:,:,:)
    integer(int32), allocatable :: vertical_sets(:,:),local_slots(:,:)
    integer(int32) :: level_capacity=0
    integer(int32) :: total_rows=0,grid_rows=0,spectral_auxiliary_rows=0
  end type output_metadata_request
  type :: output_field_metadata
    integer(int32) :: field_count=0,auxiliary_count=0
    integer(int32), allocatable :: field_ids(:),surface_flags(:),parameter_codes(:)
    real(real64), allocatable :: levels(:)
    character(8), allocatable :: coordinate_names(:)
    character(12), allocatable :: field_names(:)
    integer(int32), allocatable :: domain_counts(:),domain_indices(:,:)
    integer(int32), allocatable :: vertical_sets(:),local_slots(:)
  end type output_field_metadata
contains
  !> Report whether any payload owner is already allocated.
  logical function has_owner(fields)
    type(output_field_metadata), intent(in) :: fields
    has_owner=allocated(fields%field_ids).or.allocated(fields%surface_flags).or. &
      allocated(fields%parameter_codes).or.allocated(fields%levels).or. &
      allocated(fields%coordinate_names).or.allocated(fields%field_names).or. &
      allocated(fields%domain_counts).or.allocated(fields%domain_indices).or. &
      allocated(fields%vertical_sets).or.allocated(fields%local_slots)
  end function has_owner

  !> Release the sixteen payloads in their original source order.
  !! Scalar counts stay unchanged, as in the generated release entry.
  subroutine release_output_field_metadata(spectral,grid)
    type(output_field_metadata), intent(inout) :: spectral,grid
    if(allocated(grid%field_ids)) deallocate(grid%field_ids)
    if(allocated(grid%surface_flags)) deallocate(grid%surface_flags)
    if(allocated(grid%levels)) deallocate(grid%levels)
    if(allocated(grid%domain_counts)) deallocate(grid%domain_counts)
    if(allocated(grid%domain_indices)) deallocate(grid%domain_indices)
    if(allocated(spectral%field_ids)) deallocate(spectral%field_ids)
    if(allocated(spectral%surface_flags)) deallocate(spectral%surface_flags)
    if(allocated(spectral%levels)) deallocate(spectral%levels)
    if(allocated(spectral%vertical_sets)) deallocate(spectral%vertical_sets)
    if(allocated(spectral%local_slots)) deallocate(spectral%local_slots)
    if(allocated(spectral%coordinate_names)) deallocate(spectral%coordinate_names)
    if(allocated(spectral%field_names)) deallocate(spectral%field_names)
    if(allocated(spectral%parameter_codes)) deallocate(spectral%parameter_codes)
    if(allocated(grid%coordinate_names)) deallocate(grid%coordinate_names)
    if(allocated(grid%field_names)) deallocate(grid%field_names)
    if(allocated(grid%parameter_codes)) deallocate(grid%parameter_codes)
  end subroutine release_output_field_metadata

  !> Create spectral and grid metadata from the active request rows.
  !! codes and surface_flags have at least 686 entries; names have 16 characters.
  !! source_configuration is 0..2. Value 1 sends every field to the grid writer.
  !! coordinate is S, P, B, T or V. num_domains is 1..8.
  !! budget_bytes is 0..128 MiB and charges each empty source allocation one byte.
  !! status is 0 on success, 1 after allocation cleanup, 2 before admission,
  !! or 3 when a source consistency condition fails after owners are created.
  subroutine create_output_field_metadata(request,codes,surface_flags,names,num_domains,levels, &
      source_configuration,coordinate,budget_bytes,spectral,grid,status)
    type(output_metadata_request), intent(in) :: request
    integer(int32), intent(in) :: codes(:),surface_flags(:),num_domains,source_configuration
    character(*), intent(in) :: names(:),coordinate
    real(real64), intent(in) :: levels(:)
    integer(int64), intent(in) :: budget_bytes
    type(output_field_metadata), intent(inout) :: spectral,grid
    integer(int32), intent(out) :: status
    integer :: nfields,ns,ng,field,identifier,level,row,scount,gcount,domains,j,source_level,allocation_status
    integer(int64) :: spectral_rows,grid_rows,allocation_bytes
    logical :: choose_spectral
    status=2_int32
    if(num_domains<1.or.num_domains>8.or.size(levels)>512) return
    if(source_configuration<0.or.source_configuration>2) return
    if(len(coordinate)/=1) return
    if(index('SPBTV',coordinate)==0) return
    if(size(codes)<686.or.size(surface_flags)<686.or.size(names)<686.or.len(names)/=16) return
    if(.not.allocated(request%field_ids)) return
    nfields=size(request%field_ids)
    if(nfields>686.or.request%level_capacity<0) return
    if(nfields>0) then
      if(.not.allocated(request%level_counts)) return
      if(size(request%level_counts)<686) return
      if(source_configuration/=1) then
        if(.not.allocated(request%spectral_by_field)) return
        if(size(request%spectral_by_field)<686) return
      end if
    end if
    if(request%total_rows<0.or.request%total_rows>351232.or.request%grid_rows<0.or. &
       request%grid_rows>request%total_rows.or.request%spectral_auxiliary_rows<0.or. &
       request%spectral_auxiliary_rows>request%total_rows) return
    ns=request%total_rows-request%grid_rows
    ng=request%grid_rows
    if(source_configuration==1) then
      ng=request%total_rows
      ns=0
    end if
    if(has_owner(spectral).or.has_owner(grid)) return
    spectral_rows=0_int64
    grid_rows=0_int64
    do field=1,nfields
      identifier=request%field_ids(field)
      if(identifier<1.or.identifier>686) return
      if(request%level_counts(identifier)<1.or.request%level_counts(identifier)>request%level_capacity) return
      choose_spectral=.false.
      if(source_configuration/=1) choose_spectral=request%spectral_by_field(identifier)>=1
      if(choose_spectral) then
        spectral_rows=spectral_rows+request%level_counts(identifier)
      else
        grid_rows=grid_rows+request%level_counts(identifier)
      end if
    end do
    if(spectral_rows/=ns.or.grid_rows/=ng) return
    ! Sum the same sixteen payload lengths, including empty allocation tokens.
    allocation_bytes=0_int64
    allocation_bytes=allocation_bytes+max(1_int64,4_int64*ng)
    allocation_bytes=allocation_bytes+max(1_int64,4_int64*ng)
    allocation_bytes=allocation_bytes+max(1_int64,8_int64*ng)
    allocation_bytes=allocation_bytes+max(1_int64,4_int64*ng)
    allocation_bytes=allocation_bytes+max(1_int64,4_int64*ng*num_domains)
    allocation_bytes=allocation_bytes+max(1_int64,4_int64*ns)
    allocation_bytes=allocation_bytes+max(1_int64,4_int64*ns)
    allocation_bytes=allocation_bytes+max(1_int64,8_int64*ns)
    allocation_bytes=allocation_bytes+max(1_int64,4_int64*ns)
    allocation_bytes=allocation_bytes+max(1_int64,4_int64*ns)
    allocation_bytes=allocation_bytes+max(1_int64,8_int64*ns)
    allocation_bytes=allocation_bytes+max(1_int64,12_int64*ns)
    allocation_bytes=allocation_bytes+max(1_int64,4_int64*ns)
    allocation_bytes=allocation_bytes+max(1_int64,8_int64*ng)
    allocation_bytes=allocation_bytes+max(1_int64,12_int64*ng)
    allocation_bytes=allocation_bytes+max(1_int64,4_int64*ng)
    if(budget_bytes<0_int64.or.budget_bytes>134217728_int64.or.allocation_bytes>budget_bytes) return
    spectral%field_count=ns
    spectral%auxiliary_count=request%spectral_auxiliary_rows
    if(source_configuration==1) spectral%auxiliary_count=0
    grid%field_count=ng
    allocate(grid%field_ids(ng),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(grid%surface_flags(ng),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(grid%levels(ng),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(grid%domain_counts(ng),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(grid%domain_indices(num_domains,ng),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(spectral%field_ids(ns),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(spectral%surface_flags(ns),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(spectral%levels(ns),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(spectral%vertical_sets(ns),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(spectral%local_slots(ns),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(spectral%coordinate_names(ns),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(spectral%field_names(ns),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(spectral%parameter_codes(ns),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(grid%coordinate_names(ng),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(grid%field_names(ng),stat=allocation_status)
    if(allocation_status/=0) goto 900
    allocate(grid%parameter_codes(ng),stat=allocation_status)
    if(allocation_status/=0) goto 900
    status=3_int32
    scount=0
    gcount=0
    do field=1,nfields
      identifier=request%field_ids(field)
      choose_spectral=.false.
      if(source_configuration/=1) choose_spectral=request%spectral_by_field(identifier)>=1
      do level=1,request%level_counts(identifier)
        if(choose_spectral) then
          row=scount+1
          call write_common_fields(spectral,row,identifier,level)
          if(status/=0) return
          if(.not.allocated(request%vertical_sets).or..not.allocated(request%local_slots)) then
            status=3_int32
            return
          end if
          if(size(request%vertical_sets,1)<level.or.size(request%vertical_sets,2)<identifier.or. &
             size(request%local_slots,1)<level.or.size(request%local_slots,2)<identifier) then
            status=3_int32
            return
          end if
          spectral%vertical_sets(row)=request%vertical_sets(level,identifier)
          spectral%local_slots(row)=request%local_slots(level,identifier)
          scount=scount+1
        else
          row=gcount+1
          call write_common_fields(grid,row,identifier,level)
          if(status/=0) return
          if(.not.allocated(request%domain_counts)) then
            status=3_int32
            return
          end if
          if(size(request%domain_counts,1)<level.or.size(request%domain_counts,2)<identifier) then
            status=3_int32
            return
          end if
          domains=request%domain_counts(level,identifier)
          if(domains<0.or.domains>num_domains) then
            status=3_int32
            return
          end if
          grid%domain_counts(row)=domains
          do j=1,num_domains
            if(j<=domains) then
              if(.not.allocated(request%domain_indices)) then
                status=3_int32
                return
              end if
              if(size(request%domain_indices,1)<j.or.size(request%domain_indices,2)<level.or. &
                 size(request%domain_indices,3)<identifier) then
                status=3_int32
                return
              end if
              if(request%domain_indices(j,level,identifier)<1.or.request%domain_indices(j,level,identifier)>num_domains) then
                status=3_int32
                return
              end if
              grid%domain_indices(j,row)=request%domain_indices(j,level,identifier)
            else
              grid%domain_indices(j,row)=0_int32
            end if
          end do
          gcount=gcount+1
        end if
      end do
    end do
    if(scount/=ns.or.gcount/=ng) then
      status=3_int32
      return
    end if
    status=0_int32
    return
900 continue
    call release_output_field_metadata(spectral,grid)
    status=1_int32
  contains
    !> Store one source field row without evaluating numerical expressions.
    subroutine write_common_fields(fields,row_index,field_index,level_index)
      type(output_field_metadata), intent(inout) :: fields
      integer, intent(in) :: row_index,field_index,level_index
      integer :: offset
      status=3_int32
      fields%field_ids(row_index)=field_index
      fields%surface_flags(row_index)=surface_flags(field_index)
      fields%parameter_codes(row_index)=codes(field_index)
      fields%coordinate_names(row_index)=' '
      if(surface_flags(field_index)/=0) then
        fields%coordinate_names(row_index)(1:4)=names(field_index)(1:4)
        fields%levels(row_index)=0.0_real64
        offset=4
      else
        fields%coordinate_names(row_index)(1:1)=coordinate
        if(.not.allocated(request%level_indices)) return
        if(size(request%level_indices,1)<level_index.or.size(request%level_indices,2)<field_index) return
        source_level=request%level_indices(level_index,field_index)
        if(source_level<1.or.source_level>size(levels)) return
        fields%levels(row_index)=levels(source_level)
        offset=0
      end if
      fields%field_names(row_index)=names(field_index)(offset+1:offset+12)
      status=0_int32
    end subroutine write_common_fields
  end subroutine create_output_field_metadata
end module runtime_output_field_metadata_port

!> Typed ports of EXTFPF and EXTFPNORM.
!! Public MPI moves unchanged FP64 words. Global point order determines
!! every sum and tie. The caller supplies nearest-even and gradual underflow.
module runtime_fullpos_norm_transport_port
  use, intrinsic :: iso_fortran_env, only: int8,int32,int64,real64
  use mpi_f08
  implicit none
  private
  public :: fullpos_norm_partition,extract_fullpos_fields,extract_fullpos_norms
  type :: fullpos_norm_partition
    type(MPI_Comm) :: communicator=MPI_COMM_WORLD
    integer(int32) :: global_point_count=0
    integer(int32), allocatable :: field_counts(:),field_offsets(:)
    integer(int32), allocatable :: point_counts(:),point_indices(:,:)
    logical :: profiling_enabled=.false.
  end type fullpos_norm_partition
contains
  !> End the forecast on a public MPI transport failure.
  subroutine require_mpi(partition,error)
    type(fullpos_norm_partition), intent(in) :: partition
    integer, intent(in) :: error
    integer :: ignored
    if(error==MPI_SUCCESS) return
    call MPI_Abort(partition%communicator,3,ignored)
    error stop 3
  end subroutine require_mpi

  !> Agree integer admission or allocation status before the next collective.
  subroutine agree_status(partition,local_status,status)
    type(fullpos_norm_partition), intent(in) :: partition
    integer(int32), intent(in) :: local_status
    integer(int32), intent(out) :: status
    integer :: error
    call MPI_Allreduce(local_status,status,1,MPI_INTEGER4,MPI_MAX,partition%communicator,error)
    call require_mpi(partition,error)
  end subroutine agree_status

  !> Validate the typed partition and source field/point counts.
  subroutine admit_partition(partition,first_field,blocked,block_ends,budget,rank,world,total_fields,status)
    type(fullpos_norm_partition), intent(in) :: partition
    integer(int32), intent(in) :: first_field,block_ends(:)
    real(real64), intent(in) :: blocked(:,:,:)
    integer(int64), intent(in) :: budget
    integer, intent(out) :: rank,world,total_fields
    integer(int32), intent(out) :: status
    integer :: error,j,nblocks,expected,local_points,width
    integer(int64) :: fields,points
    call MPI_Comm_rank(partition%communicator,rank,error)
    call require_mpi(partition,error)
    call MPI_Comm_size(partition%communicator,world,error)
    call require_mpi(partition,error)
    status=2_int32
    total_fields=0
    if(world<1.or.world>65536.or.partition%profiling_enabled.or. &
       budget<=0_int64.or.budget>68719476736_int64.or.partition%global_point_count<1) return
    if(.not.allocated(partition%field_counts).or..not.allocated(partition%field_offsets).or. &
       .not.allocated(partition%point_counts).or..not.allocated(partition%point_indices)) return
    if(size(partition%field_counts)/=world.or.size(partition%field_offsets)/=world.or. &
       size(partition%point_counts)/=world.or.size(partition%point_indices,2)/=world) return
    if(size(blocked,1)<1.or.size(blocked,1)>1024.or.size(blocked,2)<1.or.size(blocked,2)>65536) return
    fields=0_int64
    points=0_int64
    do j=1,world
      if(partition%field_counts(j)<0.or.partition%field_offsets(j)/=fields.or.partition%point_counts(j)<0) return
      fields=fields+partition%field_counts(j)
      points=points+partition%point_counts(j)
      if(fields>65536_int64.or.points>partition%global_point_count) return
    end do
    if(fields<1.or.points/=partition%global_point_count.or.first_field<1) return
    if(int(first_field,int64)+fields-1_int64>size(blocked,2)) return
    if(size(partition%point_indices,1)/=maxval(partition%point_counts)) return
    width=size(blocked,1)
    local_points=partition%point_counts(rank+1)
    nblocks=(local_points+width-1)/width
    if(size(blocked,3)/=nblocks.or.size(block_ends)/=nblocks) return
    do j=1,nblocks
      expected=width
      if(j==nblocks) then
        expected=modulo(local_points,width)
        if(expected==0) expected=width
      end if
      if(block_ends(j)/=expected) return
    end do
    total_fields=int(fields)
    status=0_int32
  end subroutine admit_partition

  !> Collect assigned fields at all global points by the source peer ring.
  !! blocked has (block_width,field_capacity,local_blocks) elements.
  !! global_fields has (global_points,fields_owned_here) elements.
  !! point_indices(:,rank+1) uses one-based global point indices.
  !! Publication is atomic: global_fields changes only after common success.
  subroutine extract_fullpos_fields(partition,first_field,blocked,block_ends,budget_bytes,global_fields,status)
    type(fullpos_norm_partition), intent(in) :: partition
    integer(int32), intent(in) :: first_field,block_ends(:)
    real(real64), intent(in) :: blocked(:,:,:)
    integer(int64), intent(in) :: budget_bytes
    real(real64), intent(inout) :: global_fields(:,:)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: staged(:,:),send_values(:),receive_values(:)
    integer(int8), allocatable :: covered(:)
    integer(int32) :: local_status
    integer :: rank,world,total_fields,local_points,local_fields,max_points,max_fields
    integer :: allocation_status,distance,destination,source,send_count,receive_count,error,j,k
    integer :: point,byte_index,bit_index
    integer(int64) :: staged_bytes,send_bytes,receive_bytes,coverage_bytes,required,send_slots,receive_slots

    call admit_partition(partition,first_field,blocked,block_ends,budget_bytes,rank,world,total_fields,local_status)
    staged_bytes=0_int64
    send_bytes=0_int64
    receive_bytes=0_int64
    coverage_bytes=0_int64
    if(local_status==0) then
      local_points=partition%point_counts(rank+1)
      local_fields=partition%field_counts(rank+1)
      max_points=maxval(partition%point_counts)
      max_fields=maxval(partition%field_counts)
      if(size(global_fields,1)/=partition%global_point_count.or.size(global_fields,2)/=local_fields) local_status=2_int32
      staged_bytes=8_int64*partition%global_point_count*local_fields
      send_slots=int(local_points,int64)*max_fields
      receive_slots=int(max_points,int64)*local_fields
      if(send_slots>huge(0_int32).or.receive_slots>huge(0_int32)) local_status=2_int32
      send_bytes=8_int64*send_slots
      receive_bytes=8_int64*receive_slots
      ! Parentheses retain the source round-up of the byte bitset.
      coverage_bytes=16_int64*(((int(partition%global_point_count,int64)+7_int64)/8_int64+15_int64)/16_int64)
      required=896_int64+staged_bytes+send_bytes+receive_bytes+coverage_bytes
      if(required>budget_bytes) local_status=2_int32
    end if
    call agree_status(partition,local_status,status)
    if(status/=0) return
    allocate(staged(partition%global_point_count,local_fields),send_values(send_slots), &
      receive_values(receive_slots),covered(coverage_bytes),stat=allocation_status)
    local_status=0_int32
    if(allocation_status/=0) local_status=1_int32
    call agree_status(partition,local_status,status)
    if(status/=0) return
    staged=0.0_real64
    covered=0_int8
    local_status=0_int32
    do j=1,world
      do k=1,partition%point_counts(j)
        point=partition%point_indices(k,j)-1
        if(point<0.or.point>=partition%global_point_count) then
          local_status=2_int32
          exit
        end if
        byte_index=point/8+1
        bit_index=modulo(point,8)
        if(btest(covered(byte_index),bit_index)) then
          local_status=2_int32
          exit
        end if
        covered(byte_index)=ibset(covered(byte_index),bit_index)
      end do
      if(local_status/=0) exit
    end do
    call agree_status(partition,local_status,status)
    if(status/=0) return

    call pack_fields(rank,send_values)
    call place_fields(rank,send_values)
    do distance=1,world-1
      destination=modulo(rank+distance,world)
      source=modulo(rank-distance,world)
      call pack_fields(destination,send_values)
      send_count=partition%field_counts(destination+1)*local_points
      receive_count=partition%point_counts(source+1)*local_fields
      call MPI_Sendrecv(send_values,send_count,MPI_DOUBLE_PRECISION,destination,17131, &
        receive_values,receive_count,MPI_DOUBLE_PRECISION,source,17131,partition%communicator,MPI_STATUS_IGNORE,error)
      call require_mpi(partition,error)
      call place_fields(source,receive_values)
    end do
    call agree_status(partition,0_int32,status)
    if(status/=0) return
    global_fields=staged
  contains
    !> Pack field-major values from the live blocked source.
    subroutine pack_fields(destination_rank,values)
      integer, intent(in) :: destination_rank
      real(real64), intent(out) :: values(:)
      integer :: field,p,b,lane,position,source_field,width
      width=size(blocked,1)
      position=0
      do field=1,partition%field_counts(destination_rank+1)
        source_field=first_field+partition%field_offsets(destination_rank+1)+field-1
        do p=1,local_points
          b=(p-1)/width+1
          lane=modulo(p-1,width)+1
          position=position+1
          values(position)=blocked(lane,source_field,b)
        end do
      end do
    end subroutine pack_fields

    !> Place one peer's source-ordered points into our owned global fields.
    subroutine place_fields(source_rank,values)
      integer, intent(in) :: source_rank
      real(real64), intent(in) :: values(:)
      integer :: field,p,position
      position=0
      do field=1,local_fields
        do p=1,partition%point_counts(source_rank+1)
          position=position+1
          staged(partition%point_indices(p,source_rank+1),field)=values(position)
        end do
      end do
    end subroutine place_fields
  end subroutine extract_fullpos_fields

  !> Calculate source-order field means, minima and maxima on one domain.
  !! Field domain metadata has one declared domain per complete source field.
  !! Only master_one_based receives output changes. All field masks and
  !! reciprocal counts are formed before the first source sum.
  subroutine extract_fullpos_norms(partition,first_field,blocked,block_ends,field_domain_counts, &
      field_domain_indices,master_one_based,budget_bytes,means,minima,maxima,status)
    type(fullpos_norm_partition), intent(in) :: partition
    integer(int32), intent(in) :: first_field,block_ends(:),field_domain_counts(:),field_domain_indices(:,:)
    integer(int32), intent(in) :: master_one_based
    real(real64), intent(in) :: blocked(:,:,:)
    integer(int64), intent(in) :: budget_bytes
    real(real64), intent(inout) :: means(:),minima(:),maxima(:)
    integer(int32), intent(out) :: status
    real(real64), allocatable :: fields(:,:),reciprocals(:),triples(:,:),master_values(:,:)
    integer(int8), allocatable :: masks(:,:)
    integer(int32) :: local_status
    integer :: rank,world,total_fields,local_fields,max_fields,allocation_status,field,p,selected_count
    integer :: peer,error,first,last,received_count
    integer(int64) :: field_bytes,mask_bytes,reciprocal_bytes,triple_bytes,master_bytes,private_bytes
    real(real64) :: missing

    call admit_partition(partition,first_field,blocked,block_ends,budget_bytes,rank,world,total_fields,local_status)
    private_bytes=0_int64
    if(local_status==0) then
      if(master_one_based<1.or.master_one_based>world.or.size(field_domain_counts)/=size(blocked,2).or. &
         size(field_domain_indices,1)/=1.or.size(field_domain_indices,2)/=size(blocked,2)) local_status=2_int32
      if(any(field_domain_counts/=1).or.any(field_domain_indices/=1)) local_status=2_int32
      if(size(means)/=total_fields.or.size(minima)/=total_fields.or.size(maxima)/=total_fields) local_status=2_int32
      local_fields=partition%field_counts(rank+1)
      max_fields=maxval(partition%field_counts)
      field_bytes=8_int64*partition%global_point_count*local_fields
      mask_bytes=16_int64*((int(partition%global_point_count,int64)*local_fields+15_int64)/16_int64)
      reciprocal_bytes=16_int64*((8_int64*local_fields+15_int64)/16_int64)
      triple_bytes=24_int64*max_fields
      master_bytes=0_int64
      if(rank+1==master_one_based) master_bytes=24_int64*total_fields
      private_bytes=field_bytes+mask_bytes+reciprocal_bytes+triple_bytes+master_bytes
      if(private_bytes+1152_int64>=budget_bytes) local_status=2_int32
    end if
    call agree_status(partition,local_status,status)
    if(status/=0) return
    allocate(fields(partition%global_point_count,local_fields),masks(partition%global_point_count,local_fields), &
      reciprocals(local_fields),triples(3,max_fields),stat=allocation_status)
    local_status=0_int32
    if(allocation_status/=0) local_status=1_int32
    if(local_status==0.and.rank+1==master_one_based) then
      allocate(master_values(3,total_fields),stat=allocation_status)
      if(allocation_status/=0) local_status=1_int32
    end if
    call agree_status(partition,local_status,status)
    if(status/=0) return
    call extract_fullpos_fields(partition,first_field,blocked,block_ends, &
      budget_bytes-private_bytes-1152_int64,fields,status)
    if(status/=0) return

    missing=transfer(int(z'7fefffffffffffff',int64),missing)
    do field=1,local_fields
      selected_count=0
      do p=1,partition%global_point_count
        masks(p,field)=0_int8
        if(fields(p,field)/=missing) then
          masks(p,field)=1_int8
          selected_count=selected_count+1
        end if
      end do
      reciprocals(field)=1.0_real64/real(selected_count,real64)
    end do
    do field=1,local_fields
      call ordered_triple(fields(:,field),masks(:,field),reciprocals(field),triples(:,field))
    end do
    if(rank+1==master_one_based) then
      first=partition%field_offsets(rank+1)+1
      last=first+local_fields-1
      master_values(:,first:last)=triples(:,:local_fields)
      do peer=0,world-1
        if(peer==rank) cycle
        received_count=partition%field_counts(peer+1)
        call MPI_Recv(triples,3*received_count,MPI_DOUBLE_PRECISION,peer,17132, &
          partition%communicator,MPI_STATUS_IGNORE,error)
        call require_mpi(partition,error)
        first=partition%field_offsets(peer+1)+1
        last=first+received_count-1
        master_values(:,first:last)=triples(:,:received_count)
      end do
    else
      call MPI_Send(triples,3*local_fields,MPI_DOUBLE_PRECISION,master_one_based-1,17132, &
        partition%communicator,error)
      call require_mpi(partition,error)
    end if
    call agree_status(partition,0_int32,status)
    if(status/=0) return
    if(rank+1==master_one_based) then
      means=master_values(1,:)
      minima=master_values(2,:)
      maxima=master_values(3,:)
    end if
  end subroutine extract_fullpos_norms

  !> Keep the separate sum, minimum and maximum passes and source tie rules.
  subroutine ordered_triple(values,mask,reciprocal,result)
    real(real64), intent(in) :: values(:),reciprocal
    integer(int8), intent(in) :: mask(:)
    real(real64), intent(out) :: result(3)
    real(real64) :: total,smallest,largest,positive_infinity,negative_infinity
    integer :: p
    logical :: any_value,found
    total=0.0_real64
    do p=1,size(values)
      if(mask(p)==0_int8) cycle
      total=total+values(p)
    end do
    result(1)=reciprocal*total
    positive_infinity=transfer(int(z'7ff0000000000000',int64),positive_infinity)
    negative_infinity=transfer(int(z'fff0000000000000',int64),negative_infinity)
    smallest=transfer(int(z'7fefffffffffffff',int64),smallest)
    any_value=.false.
    found=.false.
    do p=1,size(values)
      if(mask(p)==0_int8) cycle
      any_value=.true.
      if(.not.found) then
        if(values(p)<=positive_infinity) then
          smallest=values(p)
          found=.true.
        end if
      else
        if(values(p)<smallest) smallest=values(p)
      end if
    end do
    if(.not.found.and.any_value) smallest=transfer(int(z'7ff8000000000000',int64),smallest)
    largest=transfer(int(z'ffefffffffffffff',int64),largest)
    any_value=.false.
    found=.false.
    do p=1,size(values)
      if(mask(p)==0_int8) cycle
      any_value=.true.
      if(.not.found) then
        if(values(p)>=negative_infinity) then
          largest=values(p)
          found=.true.
        end if
      else
        if(values(p)>largest) largest=values(p)
      end if
    end do
    if(.not.found.and.any_value) largest=transfer(int(z'7ff8000000000000',int64),largest)
    result(2)=smallest
    result(3)=largest
  end subroutine ordered_triple
end module runtime_fullpos_norm_transport_port

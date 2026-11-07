module runtime_grib_file_services_port
  !! Write exact GRIB bytes through public operating-system file services.
  !! Each record ends at a four-byte boundary with ASCII space padding.
  use, intrinsic :: iso_c_binding
  use, intrinsic :: iso_fortran_env, only: int32,int64
  implicit none
  private
  public :: open_grib_output,open_grib_path,write_grib_record,write_padded_grib_message
  public :: write_grib_bytes,close_grib_output,flush_grib_output,grib_flush_count
  integer(int64), save :: flush_count=0_int64

  interface
    function file_open(name,flags,permissions) bind(C,name="open") result(fd)
      import c_char,c_int
      character(c_char), intent(in) :: name(*)
      integer(c_int), value :: flags,permissions
      integer(c_int) :: fd
    end function file_open
    function file_write(fd,buffer,count) bind(C,name="write") result(transferred)
      import c_int,c_ptr,c_size_t,c_long
      integer(c_int), value :: fd
      type(c_ptr), value :: buffer
      integer(c_size_t), value :: count
      integer(c_long) :: transferred
    end function file_write
    function file_close(fd) bind(C,name="close") result(status)
      import c_int
      integer(c_int), value :: fd
      integer(c_int) :: status
    end function file_close
    function errno_address() bind(C,name="__errno_location") result(address)
      import c_ptr
      type(c_ptr) :: address
    end function errno_address
    subroutine exit_process(status) bind(C,name="_Exit")
      import c_int
      integer(c_int), value :: status
    end subroutine exit_process
  end interface

contains

  function open_grib_output(filename,replace,permissions) result(fd)
    character(*), intent(in) :: filename
    logical, intent(in) :: replace
    integer(c_int), optional, intent(in) :: permissions
    integer(c_int) :: fd
    fd=open_file_path(filename,replace,permissions,256)
  end function open_grib_output

  function open_grib_path(filename,replace,permissions) result(fd)
    !! Open the source backend path, with at most 4095 bytes.
    character(*), intent(in) :: filename
    logical, intent(in) :: replace
    integer(c_int), optional, intent(in) :: permissions
    integer(c_int) :: fd
    fd=open_file_path(filename,replace,permissions,4095)
  end function open_grib_path

  function open_file_path(filename,replace,permissions,max_length) result(fd)
    !! Open a 1:256-character path, trimming only trailing spaces.
    !! replace selects truncation; false selects append. The default file
    !! permissions are octal 0666 before the operating-system umask.
    !! Return the descriptor or a negative Linux error, preserving errno.
    integer, intent(in) :: max_length
    character(*), intent(in) :: filename
    logical, intent(in) :: replace
    integer(c_int), optional, intent(in) :: permissions
    integer(c_int) :: fd,flags,mode,saved_errno
    integer(c_int), pointer :: error_number
    character(c_char) :: name(4096)
    integer :: n,j

    fd=-22_c_int
    n=len(filename)
    if(n<1.or.n>max_length) return
    n=len_trim(filename)
    if(n==0) return
    if(index(filename(:n),c_null_char)/=0) return
    do j=1,n
      name(j)=filename(j:j)
    end do
    name(n+1)=c_null_char
    flags=1089_c_int
    if(replace) flags=577_c_int
    mode=438_c_int
    if(present(permissions)) mode=permissions
    call c_f_pointer(errno_address(),error_number)
    saved_errno=error_number
    fd=file_open(name,flags,mode)
    if(fd<0) fd=-error_number
    error_number=saved_errno
  end function open_file_path

  function write_grib_bytes(fd,bytes) result(status)
    !! Write a complete byte span, retrying interruptions and short writes.
    !! A zero-byte write returns negative EIO. Keep the incoming errno.
    integer(c_int), intent(in) :: fd
    integer(c_int8_t), contiguous, target, intent(in) :: bytes(:)
    integer(c_int) :: status,saved_errno,observed_errno
    integer(c_int), pointer :: error_number
    integer(c_long) :: transferred
    integer(c_size_t) :: position,remaining

    status=-22_c_int
    if(fd<0) return
    call c_f_pointer(errno_address(),error_number)
    saved_errno=error_number
    position=1_c_size_t
    remaining=size(bytes,kind=c_size_t)
    status=0_c_int
    do while(remaining>0)
      transferred=file_write(fd,c_loc(bytes(position)),remaining)
      observed_errno=error_number
      if(transferred>0) then
        if(int(transferred,c_size_t)>remaining) then
          status=-5_c_int
          exit
        end if
        position=position+int(transferred,c_size_t)
        remaining=remaining-int(transferred,c_size_t)
      else if(transferred==0) then
        status=-5_c_int
        exit
      else
        if(observed_errno==4) cycle
        status=-observed_errno
        exit
      end if
    end do
    error_number=saved_errno
  end function write_grib_bytes

  function write_padded_grib_message(fd,message) result(status)
    !! Write complete encoded bytes, then zero to three space bytes.
    !! The encoder has already validated this message and keeps it alive.
    integer(c_int), intent(in) :: fd
    integer(c_int8_t), contiguous, target, intent(in) :: message(:)
    integer(c_int) :: status
    integer(c_int8_t), target :: spaces(3)=[32_c_int8_t,32_c_int8_t,32_c_int8_t]
    integer :: padding

    status=write_grib_bytes(fd,message)
    if(status/=0) return
    padding=int(modulo(-size(message,kind=int64),4_int64))
    if(padding>0) status=write_grib_bytes(fd,spaces(:padding))
  end function write_padded_grib_message

  function write_grib_record(fd,message) result(status)
    !! Validate GRIB1/GRIB2 framing before writing any byte.
    !! message has 16:1048576 bytes, the declared length, and final 7777.
    integer(c_int), intent(in) :: fd
    integer(c_int8_t), contiguous, target, intent(in) :: message(:)
    integer(c_int) :: status
    integer(int64) :: declared,count
    integer :: j,edition

    status=-22_c_int
    count=size(message,kind=int64)
    if(fd<0.or.count<16.or.count>1048576) return
    if(any(message(:4)/=[71_c_int8_t,82_c_int8_t,73_c_int8_t,66_c_int8_t])) return
    edition=int(message(8))
    declared=0_int64
    select case(edition)
    case(1)
      do j=5,7
        declared=ior(ishft(declared,8),iand(int(message(j),int64),255_int64))
      end do
    case(2)
      do j=9,16
        declared=ior(ishft(declared,8),iand(int(message(j),int64),255_int64))
      end do
    case default
      return
    end select
    if(declared/=count) return
    if(any(message(size(message)-3:)/=55_c_int8_t)) return
    status=write_padded_grib_message(fd,message)
  end function write_grib_record

  function close_grib_output(fd) result(status)
    !! Close one descriptor and return zero or a negative Linux error.
    integer(c_int), intent(in) :: fd
    integer(c_int) :: status,saved_errno
    integer(c_int), pointer :: error_number

    call c_f_pointer(errno_address(),error_number)
    saved_errno=error_number
    status=file_close(fd)
    if(status<0) status=-error_number
    error_number=saved_errno
  end function close_grib_output

  subroutine flush_grib_output(output_type)
    !! The selected closed-file route needs no further flush.
    !! The unsupported field-database route fails with the source exit 116.
    integer(int32), intent(in) :: output_type
    if(output_type==2) call exit_process(116_c_int)
    flush_count=flush_count+1_int64
  end subroutine flush_grib_output

  function grib_flush_count() result(count)
    integer(int64) :: count
    count=flush_count
  end function grib_flush_count
end module runtime_grib_file_services_port

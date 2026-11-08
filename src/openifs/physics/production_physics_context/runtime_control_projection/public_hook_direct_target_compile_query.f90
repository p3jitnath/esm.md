!> Compile-only public declaration query. This file is never linked or run.
subroutine query_public_hook_target(view)
  use yomhook, only: lhook
  logical, pointer, intent(out) :: view
  view => lhook
end subroutine

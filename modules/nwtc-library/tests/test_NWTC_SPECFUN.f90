module test_NWTC_SPECFUN

use testdrive, only: new_unittest, unittest_type, error_type, check
use NWTC_SPECFUN, only: BesselA, BesselK, ReKi, IntKi

implicit none

private
public :: test_NWTC_SPECFUN_suite

contains

!> Collect all exported unit tests
subroutine test_NWTC_SPECFUN_suite(testsuite)
   type(unittest_type), allocatable, intent(out) :: testsuite(:)
   testsuite = [ &
               new_unittest("test_BesselA_naive", test_BesselA_naive), &
               new_unittest("test_BesselA_at0", test_BesselA_at0) &
               ]
end subroutine

subroutine test_BesselA_naive(error)
   type(error_type), allocatable, intent(out) :: error
   
   REAL(ReKi) :: X
   REAL(ReKi) :: X0
   REAL(ReKi) :: NU
   REAL(ReKi) :: K
   REAL(ReKi) :: A
   REAL(ReKi) :: A0
   REAL(ReKi) :: A_ref
   REAL(ReKi) :: err, err_ulp_max, x_max, nu_max
   INTEGER(IntKi), PARAMETER :: N = 1001
   INTEGER(IntKi) :: i, j ! loop counters
   REAL(ReKi) :: frac_i, frac_j
   INTEGER(IntKi) :: ErrStat
   CHARACTER(200) :: ErrMsg

   X0 = SQRT(SQRT(SQRT(TINY(X)))) ! Small but not so small, ~1e-39 for double

   err_ulp_max = -1.0_ReKi

   do i = 0, N
      frac_i = REAL(i, kind=ReKi)/REAL(N, kind=ReKi)
      NU =  0.98_ReKi*frac_i+ 0.01_ReKi ! From 0.01 to 0.99, since 0<NU<1
      A0 = GAMMA(NU) * 2.0_ReKi**(NU-1.0_ReKi)  ! Limit when x->0
      call check(error, ABS(X0) <= SPACING(A0)/ABS(A0), "X0 is not small enough")
      if (allocated(error)) return
      do j = 0, N
         frac_j = REAL(j, kind=ReKi)/REAL(N, kind=ReKi)
         !X = 10*X0**frac_j
         X = 10.0_ReKi**(LOG10(X0)*frac_j) ! logspaced from small X to 1
         A = BesselA(NU, X, ErrStat, ErrMsg)
         K = BesselK(NU, X, ErrStat, ErrMsg)
         !TODO: check ErrStat
         A_ref = X**NU * K
         !print *, NU, X, ABS(A-A_ref)/SPACING(A)
         err = ABS(A-A_ref)/SPACING(A) 
         if (err >= err_ulp_max) then
            err_ulp_max = err
            x_max = X
            nu_max = nu
         endif
         !call check(error, A, A_ref, thr=100*SPACING(A_ref), rel=.FALSE.)
         !if (allocated(error)) return
      enddo
   enddo
   
   print *, nu_max, x_max, err_ulp_max
   ! Check that at most two significative digits don't match
   call check(error, err_ulp_max <= 100.0_ReKi)

end subroutine

!TODO: Check against power series

subroutine test_BesselA_at0(error)
   type(error_type), allocatable, intent(out) :: error
   
   REAL(ReKi) :: X
   REAL(ReKi) :: NU
   REAL(ReKi) :: K
   REAL(ReKi) :: A
   REAL(ReKi) :: A0
   REAL(ReKi) :: A_ref
   INTEGER(IntKi) :: ErrStat
   CHARACTER(200) :: ErrMsg

   NU = 1.0_ReKi/6.0_ReKi
   X = 0.0_ReKi
   A_ref = GAMMA(NU) * 2.0_ReKi**(NU-1.0_ReKi)  ! Limit when x->0
   A = BesselA(NU, X, ErrStat, ErrMsg)
   call check(error, A, A_ref, thr=2*SPACING(A_ref))
end subroutine

end module test_NWTC_SPECFUN


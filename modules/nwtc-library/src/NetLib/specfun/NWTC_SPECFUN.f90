! NOTE: This MODULE is used in TurbSim.
MODULE NWTC_SPECFUN

   USE NWTC_Base, ONLY: ReKi, IntKi, SiKi, SetErrStat

   IMPLICIT NONE

   !> This FORTRAN 77 routine calculates modified Bessel functions
   !  of the second kind, K SUB(N+ALPHA) (X), for non-negative
   !  argument X, and non-negative order N+ALPHA, with or without
   !  exponential scaling.
   !
   !  Explanation of variables in the calling sequence
   !
   !  Description of output values ..
   !
   ! X     - Working precision non-negative real argument for which
   !         K's or exponentially scaled K's (K*EXP(X))
   !         are to be calculated.  If K's are to be calculated,
   !         X must not be greater than XMAX (see below).
   ! ALPHA - Working precision fractional part of order for which 
   !         K's or exponentially scaled K's (K*EXP(X)) are
   !         to be calculated.  0 .LE. ALPHA .LT. 1.0.
   ! NB    - Integer number of functions to be calculated, NB .GT. 0.
   !         The first function calculated is of order ALPHA, and the 
   !         last is of order (NB - 1 + ALPHA).
   ! IZE   - Integer type.  IZE = 1 if unscaled K's are to be calculated,
   !         and 2 if exponentially scaled K's are to be calculated.
   ! BK    - Working precision output vector of length NB.  If the
   !         routine terminates normally (NCALC=NB), the vector BK
   !         contains the functions K(ALPHA,X), ... , K(NB-1+ALPHA,X),
   !         or the corresponding exponentially scaled functions.
   !         If (0 .LT. NCALC .LT. NB), BK(I) contains correct function
   !         values for I .LE. NCALC, and contains the ratios
   !         K(ALPHA+I-1,X)/K(ALPHA+I-2,X) for the rest of the array.
   ! NCALC - Integer output variable indicating possible errors.
   !         Before using the vector BK, the user should check that 
   !         NCALC=NB, i.e., all orders have been calculated to
   !         the desired accuracy.  See error returns below.
   INTERFACE
      SUBROUTINE RKBESL(X,ALPHA,NB,IZE,BK,NCALC)
         USE NWTC_Base, ONLY: ReKi, IntKi
         REAL(ReKi),     INTENT(IN)  :: X
         REAL(ReKi),     INTENT(IN)  :: ALPHA
         INTEGER(IntKi), INTENT(IN)  :: NB
         INTEGER(IntKi), INTENT(IN)  :: IZE
         REAL(ReKi),     INTENT(OUT), DIMENSION(1) :: BK
         INTEGER(IntKi), INTENT(OUT) :: NCALC
      END SUBROUTINE RKBESL
   END INTERFACE

CONTAINS

   ! Computes x^nu*besselk(nu, x), taking care to work for small values of x
   ! Should achieve machine precision. Based on the first terms of the 
   ! McLaurin series expansion of the bessel K function
   FUNCTION BesselA(NU, X, ErrStat, ErrMsg)
      REAL(ReKi)                  :: BesselA  ! Result
      REAL(ReKi),     INTENT(IN)  :: NU ! Fractional order
      REAL(ReKi),     INTENT(IN)  :: X  ! Argument
      INTEGER(IntKi), INTENT(OUT) :: ErrStat
      CHARACTER(*),   INTENT(OUT) :: ErrMsg
      
      ! Internal variables
      REAL(ReKi), DIMENSION(1) :: K ! return value of RKBESL
      REAL(ReKi) :: A0 ! First term of the expansion branch that is multiplied by 1
      REAL(ReKi) :: B0 ! First term of the expansion branch that is multiplied by x**(2*nu) 
      INTEGER(IntKi) :: NCALC ! Number of successful calculations in RKBESL
      
      A0 = GAMMA(NU) * 2.0_ReKi**(NU-1.0_ReKi)  ! Limit when x->0
      IF (ABS(NU) <= 0.75_ReKi) THEN ! Safe to compute GAMMA(-NU)
         IF (X*X <= SPACING(A0)/ABS(A0)) THEN  ! This approximation has error O(x^2)
            B0 = GAMMA(-NU) * 2.0_ReKi**(-NU-1.0_ReKi)
            BesselA = A0 + x**(2.0_ReKi*NU) * B0
            RETURN
         END IF
      ELSE
         IF (ABS(X) <= SPACING(A0)/ABS(A0)) THEN ! This approximation has error (O(x^(2*nu)+O(x^2) < O(x^1.5))
            BesselA = A0
            RETURN
         END IF
      END IF
      
      ! If we got here, then it is safe to compute the function in the usual way
      CALL RKBESL(X, NU , 1, 1, K, NCALC)
      IF (NCALC < -1) THEN
         ! Out of range, return value should be zero
         k(1) = 0.0_ReKi
      ELSEIF (NCALC /= 1) THEN
         ! Calculation failed
         CALL SetErrStat(NCALC, "Error calling RKBESL", ErrStat, ErrMsg, 'BesselA')
      END IF
      
      BesselA = X**NU * K(1)
      
   END FUNCTION BesselA

END MODULE NWTC_SPECFUN

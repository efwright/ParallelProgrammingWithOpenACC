!This file is released under terms of MIT license`
!See LICENSE.txt for more information

! module containing the physical parameterizations
MODULE m_parameterizations

  IMPLICIT NONE

  ! module constants
  REAL*8 :: cs1 = 1.0D-6, cs2 = 0.02D0, cs3 = 7.2D0, cs4 = 0.1D0, t0 = 273.0D0
  REAL*8 :: cm1 = 1.0D-6, cm2 = 25.0D0, cm3 = 0.2D0, cm4 = 100.0D0

  !$acc declare copyin(cs1, cs2, cs3, cs4, t0)
  !$acc declare copyin(cm1, cm2, cm3, cm4)

CONTAINS

  !----------------------------------------------------------------------------
  ! Physical parameterization example code 1
  ! Note: The code here do not reflect actual physical equations.
  !       The code only reflects typical computational pattern encountered in the
  !       physics of an atmospheric model
  SUBROUTINE saturation_adjustment(nlev, i, j, t, qc, qv)
!DIR$ INLINENEVER saturation_adjustment
    !$acc routine seq 

    IMPLICIT NONE

    ! arguments
    INTEGER, INTENT(IN)    :: i, j, nlev  ! dimensions of inputs
    REAL*8,  INTENT(IN)    :: t(:,:,:)        ! temperature
    REAL*8,  INTENT(OUT)   :: qc(:,:,:)       ! cloud water content
    REAL*8,  INTENT(INOUT) :: qv(:,:,:)       ! water vapour content
    
    ! local variables
    INTEGER :: k

    ! do the computation
    DO k = 1, nlev
      qv(i,j,k) = qv(i,j,k) + cs1*EXP(cs2*( t(i,j,k)-t0 )/( t(i,j,k)-cs3) )
      qc(i,j,k) = cs4*qv(i,j,k)
    END DO
  END SUBROUTINE saturation_adjustment

  !----------------------------------------------------------------------------
  ! Physical parameterization example code 2
  ! Note: The code here do not reflect actual physical equations.
  !       The code only reflects typical computational pattern encountered in the
  !       physics of an atmospheric model
  SUBROUTINE microphysics(nlev, i, j, t, qc, qv)
!DIR$ INLINENEVER microphysics
    !$acc routine seq

    IMPLICIT NONE

    ! arguments
    INTEGER, INTENT(IN)   :: i, j, nlev  ! dimension of inputs
    REAL*8, INTENT(INOUT) :: t(:, :, :)        ! temperature
    REAL*8, INTENT(IN)    :: qc(:, :, :)       ! cloud water content
    REAL*8, INTENT(INOUT) :: qv(:, :, :)       ! water vapour content

    ! local variables
    INTEGER :: k   ! loop indices
    ! do the computation
    DO k = 2, nlev
      qv(i, j, k) = qv(i, j, k-1) + cm1*(t(i, j, k)-cm2)**cm3
      t(i, j, k)  = t(i, j, k)*( 1.0D0 - cm4*qc(i, j, k)+qv(i, j, k) )
    END DO
  END SUBROUTINE microphysics

END MODULE m_parameterizations
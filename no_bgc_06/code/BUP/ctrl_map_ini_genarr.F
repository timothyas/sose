C $Header: /u/gcmpack/MITgcm/pkg/ctrl/ctrl_map_ini_genarr.F,v 1.23 2015/12/25 15:24:51 gforget Exp $
C $Name:  $

#include "CTRL_OPTIONS.h"
#ifdef ALLOW_GMREDI
# include "GMREDI_OPTIONS.h"
#endif

CBOP
C     !ROUTINE: CTRL_MAP_INI_GENARR
C     !INTERFACE:
      SUBROUTINE CTRL_MAP_INI_GENARR( myThid )

C     !DESCRIPTION: \bv
C     *=================================================================
C     | SUBROUTINE CTRL_MAP_INI_GENARR
C     | Add the generic arrays of the
C     | control vector to the model state and update the tile halos.
C     | The control vector is defined in the header file "ctrl.h".
C     *=================================================================
C     \ev

C     !USES:
      IMPLICIT NONE

C     == global variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "FFIELDS.h"
#include "CTRL_SIZE.h"
#include "ctrl.h"
#include "optim.h"
#include "ctrl_dummy.h"
#include "CTRL_FIELDS.h"
#include "CTRL_GENARR.h"
#ifdef ALLOW_PTRACERS
# include "PTRACERS_SIZE.h"
# include "PTRACERS_FIELDS.h"
# include "PTRACERS_PARAMS.h"
#endif
CMM(
#ifdef ALLOW_BLING
# include "BLING_OPTIONS.h"
# include "BLING_VARS.h"
#endif
#ifdef ALLOW_AUTODIFF
# include "tamc.h"
#endif
CMM)
C     !INPUT/OUTPUT PARAMETERS:
C     == routine arguments ==
      INTEGER myThid

C     !LOCAL VARIABLES:
C     == local variables ==
#if (defined (ALLOW_GENARR2D_CONTROL) || defined(ALLOW_GENARR3D_CONTROL))
      integer iarr
#endif
#ifdef ALLOW_GENARR2D_CONTROL
      integer igen_etan,igen_bdrag,igen_geoth
CMM(
      integer igen_Pc, igen_alpha_photo
      integer igen_k_Fe, igen_gamma_POM
      integer igen_wsink0, igen_phi_sm
      integer igen_phi_lg, igen_phi_DOM
CMM)
#endif /* ALLOW_GENARR2D_CONTROL */
#ifdef ALLOW_GENARR3D_CONTROL
      integer igen_theta0, igen_salt0
      integer igen_kapgm, igen_kapredi, igen_diffkr
CMM(
      integer igen_ptr1, igen_ptr2, igen_ptr3
      integer igen_ptr4, igen_ptr5, igen_ptr6
      INTEGER i,j,k,bi,bj,iTracer
CMM)
#endif /* ALLOW_GENARR3D_CONTROL */
CEOP

#ifdef ALLOW_GENARR2D_CONTROL

C--   generic 2D control variables

      igen_etan=0
      igen_bdrag=0
      igen_geoth=0
      igen_Pc=0
      igen_alpha_photo=0
      igen_k_Fe=0
      igen_gamma_POM=0
      igen_wsink0=0
      igen_phi_sm=0
      igen_phi_lg=0
      igen_phi_DOM=0
      DO iarr = 1, maxCtrlArr2D
      if (xx_genarr2d_weight(iarr).NE.' ') then
        if (xx_genarr2d_file(iarr)(1:7).EQ.'xx_etan') 
     &     igen_etan=iarr
        if (xx_genarr2d_file(iarr)(1:13).EQ.'xx_bottomdrag') 
     &     igen_bdrag=iarr
        if (xx_genarr2d_file(iarr)(1:13).EQ.'xx_geothermal') 
     &     igen_geoth=iarr
        if (xx_genarr2d_file(iarr)(1:5).EQ.'xx_Pc')
     &     igen_Pc=iarr
        if (xx_genarr2d_file(iarr)(1:12).EQ.'xx_gamma_POM')
     &     igen_gamma_POM=iarr
        if (xx_genarr2d_file(iarr)(1:14).EQ.'xx_alpha_photo')
     &     igen_alpha_photo=iarr
        if (xx_genarr2d_file(iarr)(1:7).EQ.'xx_k_Fe')
     &     igen_k_Fe=iarr
        if (xx_genarr2d_file(iarr)(1:10).EQ.'xx_phi_DOM')
     &     igen_phi_DOM=iarr
        if (xx_genarr2d_file(iarr)(1:9).EQ.'xx_wsink0')
     &     igen_wsink0=iarr
        if (xx_genarr2d_file(iarr)(1:9).EQ.'xx_phi_sm')
     &     igen_phi_sm=iarr
        if (xx_genarr2d_file(iarr)(1:9).EQ.'xx_phi_lg')
     &     igen_phi_lg=iarr
      endif
      ENDDO

      if (igen_etan.GT.0)
     &      call ctrl_map_genarr2d(etaN,igen_etan,myThid)
#ifdef ALLOW_BOTTOMDRAG_CONTROL
      if (igen_bdrag.GT.0)
     &  call ctrl_map_genarr2d(bottomDragFld,igen_bdrag,myThid)
#endif
#ifdef ALLOW_GEOTHERMAL_FLUX
      if (igen_geoth.GT.0)
     &  call ctrl_map_genarr2d(geothermalFlux,igen_geoth,myThid)
#endif
#ifdef ALLOW_BLING
      if (igen_Pc.GT.0)
     &  call ctrl_map_genarr2d(Pc_2d,igen_Pc,myThid)
      if (igen_alpha_photo.GT.0)
     &  call ctrl_map_genarr2d(alpha_photo2d,igen_alpha_photo,myThid)
      if (igen_k_Fe.GT.0)
     &  call ctrl_map_genarr2d(k_Fe2d,igen_k_Fe,myThid)
      if (igen_gamma_POM.GT.0)
     &  call ctrl_map_genarr2d(gamma_POM2d,igen_gamma_POM,myThid)
      if (igen_phi_DOM.GT.0)
     &  call ctrl_map_genarr2d(phi_DOM2d,igen_phi_DOM,myThid)
      if (igen_wsink0.GT.0)
     &  call ctrl_map_genarr2d(wsink0_2d,igen_wsink0,myThid)
      if (igen_phi_sm.GT.0)
     &  call ctrl_map_genarr2d(phi_sm2d,igen_phi_sm,myThid)
      if (igen_phi_lg.GT.0)
     &  call ctrl_map_genarr2d(phi_lg2d,igen_phi_lg,myThid)
#endif

#endif /* ALLOW_GENARR2D_CONTROL */

#ifdef ALLOW_GENARR3D_CONTROL

C--   generic 3D control variables

      igen_theta0=0
      igen_salt0=0
      igen_kapgm=0
      igen_kapredi=0
      igen_diffkr=0
CMM(
      igen_ptr1=0
      igen_ptr2=0
      igen_ptr3=0
      igen_ptr4=0
      igen_ptr5=0
      igen_ptr6=0
CMM)

      DO iarr = 1, maxCtrlArr3D
      if (xx_genarr3d_weight(iarr).NE.' ') then
        if (xx_genarr3d_file(iarr)(1:8).EQ.'xx_theta') 
     &     igen_theta0=iarr
        if (xx_genarr3d_file(iarr)(1:7).EQ.'xx_salt') 
     &     igen_salt0=iarr
        if (xx_genarr3d_file(iarr)(1:8).EQ.'xx_kapgm') 
     &     igen_kapgm=iarr
        if (xx_genarr3d_file(iarr)(1:10).EQ.'xx_kapredi') 
     &     igen_kapredi=iarr
        if (xx_genarr3d_file(iarr)(1:9).EQ.'xx_diffkr') 
     &     igen_diffkr=iarr
CMM(
        if (xx_genarr3d_file(iarr)(1:7).EQ.'xx_ptr1')
     &     igen_ptr1=iarr
        if (xx_genarr3d_file(iarr)(1:7).EQ.'xx_ptr2')
     &     igen_ptr2=iarr
        if (xx_genarr3d_file(iarr)(1:7).EQ.'xx_ptr3')
     &     igen_ptr3=iarr
        if (xx_genarr3d_file(iarr)(1:7).EQ.'xx_ptr4')
     &     igen_ptr4=iarr
        if (xx_genarr3d_file(iarr)(1:7).EQ.'xx_ptr5')
     &     igen_ptr5=iarr
        if (xx_genarr3d_file(iarr)(1:7).EQ.'xx_ptr6')
     &     igen_ptr6=iarr
CMM)
      endif
      ENDDO

      if (igen_theta0.GT.0)
     &   call ctrl_map_genarr3d(theta,igen_theta0,myThid)
      if (igen_salt0.GT.0)
     &   call ctrl_map_genarr3d(salt,igen_salt0,myThid)
#ifdef ALLOW_KAPGM_CONTROL
      if (igen_kapgm.GT.0)
     &   call ctrl_map_genarr3d(kapgm,igen_kapgm,myThid)
#endif
#ifdef ALLOW_KAPREDI_CONTROL
      if (igen_kapredi.GT.0)
     &   call ctrl_map_genarr3d(kapredi,igen_kapredi,myThid)
#endif
#ifdef ALLOW_3D_DIFFKR
      if (igen_diffkr.GT.0)
     &   call ctrl_map_genarr3d(diffkr,igen_diffkr,myThid)
#endif
CMM(
#ifdef ALLOW_PTRACERS

      if (igen_ptr1.GT.0) then
CADJ STORE pTracer(:,:,:,:,:,1)=comlev1,key=ikey_dynamics,kind=isbyte
        call ctrl_map_genarr3d(pTracer(1-OLx,1-OLy,1,1,1,1),
     &                          igen_ptr1,myThid)
      endif
      if (igen_ptr2.GT.0) then
CADJ STORE pTracer(:,:,:,:,:,2)=comlev1,key=ikey_dynamics,kind=isbyte
        call ctrl_map_genarr3d(pTracer(1-OLx,1-OLy,1,1,1,2),
     &                          igen_ptr2,myThid)
      endif
      if (igen_ptr3.GT.0) then
CADJ STORE pTracer(:,:,:,:,:,3)=comlev1,key=ikey_dynamics,kind=isbyte
        call ctrl_map_genarr3d(pTracer(1-OLx,1-OLy,1,1,1,3),
     &                          igen_ptr3,myThid)
      endif
      if (igen_ptr4.GT.0) then
CADJ STORE pTracer(:,:,:,:,:,4)=comlev1,key=ikey_dynamics,kind=isbyte
        call ctrl_map_genarr3d(pTracer(1-OLx,1-OLy,1,1,1,4),
     &                          igen_ptr4,myThid)
      endif
      if (igen_ptr5.GT.0) then
CADJ STORE pTracer(:,:,:,:,:,5)=comlev1,key=ikey_dynamics,kind=isbyte
        call ctrl_map_genarr3d(pTracer(1-OLx,1-OLy,1,1,1,5),
     &                          igen_ptr5,myThid)
      endif
      if (igen_ptr6.GT.0) then
CADJ STORE pTracer(:,:,:,:,:,6)=comlev1,key=ikey_dynamics,kind=isbyte
        call ctrl_map_genarr3d(pTracer(1-OLx,1-OLy,1,1,1,6),
     &                          igen_ptr6,myThid)
      endif

CMM UNFORTUNATELY WE NEED THIS
CMM     Apply mask
      DO iTracer = 1, PTRACERS_numInUse
       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         DO k=1,Nr
          DO j=1-OLy,sNy+OLy
           DO i=1-OLx,sNx+OLx
            IF (maskC(i,j,k,bi,bj).NE.0.)  THEN
              IF (pTracer(i,j,k,bi,bj,iTracer).LT.1. _d -11)
     &           pTracer(i,j,k,bi,bj,iTracer)=1. _d -11
            ENDIF
           ENDDO
          ENDDO
         ENDDO
        ENDDO
       ENDDO
      ENDDO

#endif
CMM AND THIS TOO
      DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         DO k=1,Nr
          DO j=1-OLy,sNy+OLy
           DO i=1-OLx,sNx+OLx
            IF (maskC(i,j,k,bi,bj).NE.0.)  THEN
              IF (theta(i,j,k,bi,bj).LT.-1.97  _d 0)
     &            theta(i,j,k,bi,bj)=-1.97  _d 0
            ENDIF
           ENDDO
          ENDDO
         ENDDO
        ENDDO
       ENDDO

CMM)
#endif /* ALLOW_GENARR3D_CONTROL */

      RETURN
      END

C---------------------------

C     !ROUTINE: CTRL_MAP_GENARR2D
C     !INTERFACE:
      SUBROUTINE CTRL_MAP_GENARR2D( fld, iarr, myThid )

C     !DESCRIPTION: \bv
C     *=================================================================
C     | SUBROUTINE CTRL_MAP_GENARR2D
C     | Add the generic arrays of the
C     | control vector to the model state and update the tile halos.
C     | The control vector is defined in the header file "ctrl.h".
C     *=================================================================
C     \ev

C     !USES:
      IMPLICIT NONE

C     == global variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"

#include "CTRL_SIZE.h"
#include "ctrl.h"
#include "optim.h"
#include "CTRL_GENARR.h"
#include "ctrl_dummy.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == routine arguments ==
      _RL fld   (1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      INTEGER iarr
      INTEGER myThid

#ifdef ALLOW_GENARR2D_CONTROL

C     !LOCAL VARIABLES:
C     == local variables ==
      integer bi,bj
      integer i,j
      integer jmin,jmax
      integer imin,imax
      integer numsmo, k2
      logical dowc01
      logical dosmooth
      logical doscaling
      _RL xx_gen  (1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
      character*(80) fnamegenIn
      character*(80) fnamegenOut
      character*(80) fnamebase
      INTEGER  ILNBLNK
      EXTERNAL ILNBLNK
      integer ilgen
      logical doglobalread
      logical ladinit
CEOP

c--   Now, read the control vector.
      doglobalread = .false.
      ladinit      = .false.

      dosmooth=.false.
      dowc01  = .false.
      doscaling=.true.

      numsmo=1
      do k2 = 1, maxCtrlProc
          if (xx_genarr2d_preproc(k2,iarr).EQ.'WC01') then
             dowc01=.TRUE.
             if (xx_genarr2d_preproc_i(k2,iarr).NE.0)
     &           numsmo=xx_genarr2d_preproc_i(k2,iarr)
          endif
          if ((.NOT.dowc01).AND.
     &        (xx_genarr2d_preproc(k2,iarr).EQ.'smooth')) then
             dosmooth=.TRUE.
             if (xx_genarr2d_preproc_i(k2,iarr).NE.0)
     &           numsmo=xx_genarr2d_preproc_i(k2,iarr)
          endif
          if (xx_genarr2d_preproc(k2,iarr).EQ.'noscaling') then
             doscaling=.FALSE.
          endif
      enddo

      fnamebase = xx_genarr2d_file(iarr)
      ilgen=ilnblnk( fnamebase )
      write(fnamegenIn(1:80),'(2a,i10.10)')
     &       fnamebase(1:ilgen),'.',optimcycle
      write(fnamegenOut(1:80),'(2a,i10.10)')
     &       fnamebase(1:ilgen),'.effective.',optimcycle

      call mdsreadfield(xx_genarr2d_weight(iarr),ctrlprec,'RL',1,
     &     wgenarr2d(1-Olx,1-Oly,1,1,iarr),1,mythid)

#ifdef ALLOW_AUTODIFF
      call active_read_xy( fnamegenIn, xx_gen, 1, doglobalread,
     & ladinit, optimcycle, mythid, xx_genarr2d_dummy(iarr) )
#else
      CALL READ_REC_XY_RL( fnamegenIn, xx_gen, 1, 1, myThid)
#endif

#ifdef ALLOW_SMOOTH
      IF (useSMOOTH) THEN
       IF (dowc01) call smooth_correl2d(xx_gen,maskC,numsmo,mythid)
       IF (dosmooth) call smooth2d(xx_gen,maskC,numsmo,mythid)
      ENDIF
#endif

      DO bj=myByLo(myThid), myByHi(myThid)
        DO bi=myBxLo(myThid), myBxHi(myThid)
            DO j = 1,sNy
              DO i = 1,sNx
c scale param adjustment
                IF (doscaling) then
                if ( (maskC(i,j,1,bi,bj).NE.0.).AND.
     &               (wgenarr2d(i,j,bi,bj,iarr).GT.0.) ) then
                  xx_gen(i,j,bi,bj)=xx_gen(i,j,bi,bj)
     &                     /sqrt( wgenarr2d(i,j,bi,bj,iarr) )
                else
                  xx_gen(i,j,bi,bj)=0.
                endif
                ENDIF
c add to model parameter
                fld(i,j,bi,bj)=fld(i,j,bi,bj)+xx_gen(i,j,bi,bj)
              enddo
            enddo
        enddo
      enddo

c avoid param out of [boundsVec(1) boundsVec(4)]
      CALL CTRL_BOUND_2D(fld,maskC,xx_genarr2d_bounds(1,iarr),myThid)

      CALL EXCH_XY_RL( fld, mythid )

      CALL mdswritefield(fnamegenOut,ctrlprec,.FALSE.,'RL',
     &    1, fld, 1, optimcycle, mythid)


#endif /* ALLOW_GENARR2D_CONTROL */

      RETURN
      END

C---------------------------

C     !ROUTINE: CTRL_MAP_GENARR3D
C     !INTERFACE:
      SUBROUTINE CTRL_MAP_GENARR3D( fld, iarr, myThid )

C     !DESCRIPTION: \bv
C     *=================================================================
C     | SUBROUTINE CTRL_MAP_GENARR3D
C     | Add the generic arrays of the
C     | control vector to the model state and update the tile halos.
C     | The control vector is defined in the header file "ctrl.h".
C     *=================================================================
C     \ev

C     !USES:
      IMPLICIT NONE

C     == global variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"

#include "CTRL_SIZE.h"
#include "ctrl.h"
#include "optim.h"
#include "CTRL_GENARR.h"
#include "ctrl_dummy.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == routine arguments ==
      _RL fld   (1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      INTEGER iarr
      INTEGER myThid

#ifdef ALLOW_GENARR3D_CONTROL

C     !LOCAL VARIABLES:
C     == local variables ==
      integer bi,bj
      integer i,j,k
      integer numsmo,k2
      logical dowc01
      logical dosmooth
      logical doscaling
      _RL xx_gen  (1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      character*(80) fnamegenIn
      character*(80) fnamegenOut
      character*(80) fnamebase
      INTEGER  ILNBLNK
      EXTERNAL ILNBLNK
      integer ilgen
      logical doglobalread
      logical ladinit
CEOP

c--   Now, read the control vector.
      doglobalread = .false.
      ladinit      = .false.

      dosmooth=.false.
      dowc01  = .false.
      doscaling=.true.

      numsmo=1
      do k2 = 1, maxCtrlProc
          if (xx_genarr3d_preproc(k2,iarr).EQ.'WC01') then
             dowc01=.TRUE.
             if (xx_genarr3d_preproc_i(k2,iarr).NE.0)
     &           numsmo=xx_genarr3d_preproc_i(k2,iarr)
          endif
          if ((.NOT.dowc01).AND.
     &        (xx_genarr3d_preproc(k2,iarr).EQ.'smooth')) then
             dosmooth=.TRUE.
             if (xx_genarr3d_preproc_i(k2,iarr).NE.0)
     &           numsmo=xx_genarr3d_preproc_i(k2,iarr)
          endif
          if (xx_genarr3d_preproc(k2,iarr).EQ.'noscaling') then
             doscaling=.FALSE.
          endif
      enddo

      fnamebase = xx_genarr3d_file(iarr)
      ilgen=ilnblnk( fnamebase )
      write(fnamegenIn(1:80),'(2a,i10.10)')
     &       fnamebase(1:ilgen),'.',optimcycle
      write(fnamegenOut(1:80),'(2a,i10.10)')
     &       fnamebase(1:ilgen),'.effective.',optimcycle

      call mdsreadfield(xx_genarr3d_weight(iarr),ctrlprec,'RL',nR,
     &     wgenarr3d(1-Olx,1-Oly,1,1,1,iarr),1,mythid)

#ifdef ALLOW_AUTODIFF
      call active_read_xyz( fnamegenIn, xx_gen, 1, doglobalread,
     & ladinit, optimcycle, mythid, xx_genarr3d_dummy(iarr) )
#else
      CALL READ_REC_XYZ_RL( fnamegenIn, xx_gen, 1, 1, myThid)
#endif

#ifdef ALLOW_SMOOTH
      IF (useSMOOTH) THEN
       IF (dowc01) call smooth_correl3D(xx_gen,numsmo,mythid)
       IF (dosmooth) call smooth3d(xx_gen,numsmo,mythid)
      ENDIF
#endif

      DO bj=myByLo(myThid), myByHi(myThid)
        DO bi=myBxLo(myThid), myBxHi(myThid)
          do k = 1,nr
            DO j = 1,sNy
              DO i = 1,sNx
c scale param adjustment
                IF (doscaling) then
                if ( (maskC(i,j,k,bi,bj).NE.0.).AND.
     &               (wgenarr3d(i,j,k,bi,bj,iarr).GT.0.) ) then
                  xx_gen(i,j,k,bi,bj)=xx_gen(i,j,k,bi,bj)
     &                     /sqrt( wgenarr3d(i,j,k,bi,bj,iarr) )
                else
                  xx_gen(i,j,k,bi,bj)=0.
                endif
                ENDIF
c add to model parameter
                fld(i,j,k,bi,bj)=fld(i,j,k,bi,bj)+xx_gen(i,j,k,bi,bj)
              enddo
            enddo
          enddo
        enddo
      enddo

c avoid param out of [boundsVec(1) boundsVec(4)]
      CALL CTRL_BOUND_3D(fld,maskC,xx_genarr3d_bounds(1,iarr),myThid)

      CALL EXCH_XYZ_RL( fld, mythid )

      CALL mdswritefield(fnamegenOut,ctrlprec,.FALSE.,'RL',
     &    nr, fld, 1, optimcycle, mythid)

#endif /* ALLOW_GENARR3D_CONTROL */

      RETURN
      END



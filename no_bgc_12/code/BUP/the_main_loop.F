C $Header: /u/gcmpack/MITgcm/model/src/the_main_loop.F,v 1.181 2017/03/20 19:38:16 mmazloff Exp $
C $Name:  $

#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"
#ifdef ALLOW_AUTODIFF
# include "AUTODIFF_OPTIONS.h"
#endif
#ifdef ALLOW_OBCS
# include "OBCS_OPTIONS.h"
#endif
#ifdef ALLOW_SEAICE
# include "SEAICE_OPTIONS.h"
#endif
#ifdef ALLOW_GENERIC_ADVDIFF
# include "GAD_OPTIONS.h"
#endif
#ifdef ALLOW_GMREDI
# include "GMREDI_OPTIONS.h"
#endif
#ifdef ALLOW_STREAMICE
# include "STREAMICE_OPTIONS.h"
#endif
#ifdef ALLOW_GGL90
# include "GGL90_OPTIONS.h"
#endif
#ifdef ALLOW_EXF
# include "EXF_OPTIONS.h"
#endif
#ifdef ALLOW_COST
# include "COST_OPTIONS.h"
#endif
#ifdef ALLOW_CTRL
# include "CTRL_OPTIONS.h"
#endif
#ifdef ALLOW_ECCO
# include "ECCO_OPTIONS.h"
#endif
#ifdef ALLOW_PROFILES
# include "PROFILES_OPTIONS.h"
#endif

CBOP
C     !ROUTINE: THE_MAIN_LOOP
C     !INTERFACE:
      SUBROUTINE THE_MAIN_LOOP( myTime, myIter, myThid )

C     !DESCRIPTION: \bv
C     *================================================================*
C     | SUBROUTINE the_main_loop
C     | o Run the ocean model and evaluate the specified cost function.
C     *================================================================*
C     |
C     | THE_MAIN_LOOP is the toplevel routine for the Tangent Linear and
C     | Adjoint Model Compiler (TAMC).
C     | For this purpose the initialization
C     | of the model was split into two parts. Those parameters that do
C     | not depend on a specific model run are set in INITIALISE_FIXED,
C     | whereas those that do depend on the specific realization are
C     | initialized in INITIALISE_VARIA.
C     | This routine is to be used in conjuction with the MITgcmuv
C     | checkpoint 37.
C     *================================================================*
C     \ev

C     !USES:
      IMPLICIT NONE
C     == Global variables ==
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"

c**************************************
#ifdef ALLOW_AUTODIFF
# ifndef ALLOW_OPENAD

c These includes are needed for
c AD-checkpointing.
c They provide the fields to be stored.

#  include "AUTODIFF_MYFIELDS.h"
#  include "GRID.h"
#  include "DYNVARS.h"
#  include "SURFACE.h"
#  include "FFIELDS.h"
#  include "EOS.h"
#  include "AUTODIFF.h"

#  ifdef ALLOW_GENERIC_ADVDIFF
#   include "GAD.h"
#   include "GAD_SOM_VARS.h"
#  endif
#  ifdef ALLOW_MOM_FLUXFORM
#   include "MOM_FLUXFORM.h"
#  endif
#  ifdef ALLOW_CD_CODE
#   include "CD_CODE_VARS.h"
#  endif
#  ifdef ALLOW_PTRACERS
#   include "PTRACERS_SIZE.h"
#   include "PTRACERS_FIELDS.h"
#   include "PTRACERS_START.h"
CMM(
#ifdef MULTISCALE_COUPLING_TAPES 
#   include "PTRACERS_PARAMS.h"
#endif /* MULTISCALE_COUPLING_TAPES */
CMM)
#  endif
#  ifdef ALLOW_GCHEM
#   include "GCHEM_FIELDS.h"
#  endif
#  ifdef ALLOW_CFC
#   include "CFC.h"
#  endif
#  ifdef ALLOW_DIC
#   include "DIC_VARS.h"
#   include "DIC_LOAD.h"
#   include "DIC_ATMOS.h"
#   include "DIC_CTRL.h"
#   include "DIC_COST.h"
#  endif
#  ifdef ALLOW_BLING
#   include "BLING_VARS.h"
#   include "BLING_LOAD.h"
#  endif
#  ifdef ALLOW_OBCS
#   include "OBCS_PARAMS.h"
#   include "OBCS_FIELDS.h"
#   include "OBCS_SEAICE.h"
#   ifdef ALLOW_PTRACERS
#    include "OBCS_PTRACERS.h"
#   endif
#  endif
#  ifdef ALLOW_EXF
#   include "EXF_FIELDS.h"
#   ifdef ALLOW_BULKFORMULAE
#    include "EXF_CONSTANTS.h"
#   endif
#  endif /* ALLOW_EXF */
#  ifdef ALLOW_SEAICE
#   include "SEAICE_SIZE.h"
#   include "SEAICE.h"
#   include "SEAICE_PARAMS.h"
#   include "SEAICE_COST.h"
#   include "SEAICE_TRACER.h"
#  endif
#  ifdef ALLOW_SALT_PLUME
#   include "SALT_PLUME.h"
#  endif
#  ifdef ALLOW_THSICE
#   include "THSICE_SIZE.h"
#   include "THSICE_VARS.h"
#   include "THSICE_COST.h"
#  endif
#  ifdef ALLOW_SHELFICE
#   include "SHELFICE.h"
#   include "SHELFICE_COST.h"
#  endif
#  ifdef ALLOW_STREAMICE
#   include "STREAMICE.h"
#   include "STREAMICE_ADV.h"
#   include "STREAMICE_BDRY.h"
#   include "STREAMICE_CG.h"
#  endif
#  ifdef ALLOW_EBM
#   include "EBM.h"
#  endif
#  ifdef ALLOW_RBCS
#   include "RBCS_SIZE.h"
#   include "RBCS_FIELDS.h"
#  endif
#  ifdef ALLOW_OFFLINE
#   include "OFFLINE.h"
#  endif
#  ifdef ALLOW_CG2D_NSA
#   include "CG2D.h"
#  endif
#  ifdef ALLOW_DIVIDED_ADJOINT
#   ifdef ALLOW_USE_MPI
#    include "mpif.h"
#   endif
#  endif

#  include "tamc.h"

# ifdef ALLOW_GGL90
#  include "GGL90.h"
# endif
# ifdef ALLOW_PROFILES
#  include "PROFILES_SIZE.h"
#  include "profiles.h"
# endif
# ifdef ALLOW_ECCO
#  include "ecco_cost.h"
# endif

# endif /* undef ALLOW_OPENAD */

# ifdef ALLOW_CTRL
# include "CTRL_SIZE.h"
# include "ctrl.h"
# include "ctrl_dummy.h"
# include "CTRL_GENARR.h"
# include "CTRL_OBCS.h"
# endif
# ifdef ALLOW_COST
#  include "cost.h"
# endif

#endif /* ALLOW_AUTODIFF */
c**************************************

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     note: under the multi-threaded model myIter and
C           myTime are local variables passed around as routine
C           arguments. Although this is fiddly it saves the need to
C           impose additional synchronisation points when they are
C           updated.
C     myTime :: time counter for this thread
C     myIter :: iteration counter for this thread
C     myThid :: thread number for this instance of the routine.
      _RL     myTime
      INTEGER myIter
      INTEGER myThid

C     !FUNCTIONS:
C     == Functions ==

C     !LOCAL VARIABLES:
C     == Local variables ==
      INTEGER iloop
#ifdef STORE_LOADEDREC_TEST
      INTEGER bi,bj
#endif /* STORE_LOADEDREC_TEST */
CMM(
#ifdef MULTISCALE_COUPLING_TAPES 
      INTEGER iTracer
#endif /* MULTISCALE_COUPLING_TAPES */
CMM)
CEOP

#ifdef ALLOW_DEBUG
      IF (debugMode) CALL DEBUG_ENTER('THE_MAIN_LOOP',myThid)
#endif

#ifdef ALLOW_AUTODIFF_TAMC
c--   Initialize storage for the cost function evaluation.
CADJ  INIT dummytape = common, 1
c--   Initialize storage for the outermost loop.
# ifndef ALLOW_AUTODIFF_WHTAPEIO
CADJ  INIT tapelev_init   = USER
CADJ  INIT tapelev_ini_bibj_k   = USER
# else
CADJ  INIT tapelev_init   = common, 1
# endif
c
# ifdef ALLOW_TAMC_CHECKPOINTING
#  if (defined (AUTODIFF_2_LEVEL_CHECKPOINT))
CADJ  INIT tapelev2 = USER
#  elif (defined (AUTODIFF_4_LEVEL_CHECKPOINT))
CADJ  INIT tapelev4 = USER
#  else
CADJ  INIT tapelev3 = USER
#  endif
# endif
#endif

#ifdef ALLOW_AUTODIFF
      nIter0 = NINT( (startTime-baseTime)/deltaTClock )
      ikey_dynamics = 1
#endif

#ifdef ALLOW_AUTODIFF_TAMC
# ifdef NONLIN_FRSURF
CADJ STORE hFacC = tapelev_init, key = 1
CADJ STORE recip_hFacC = tapelev_init, key = 1
# endif
#endif

#ifdef ALLOW_OPENAD
# ifdef ALLOW_THETA0_CONTROL
c$openad INDEPENDENT(xx_theta_dummy)
# endif
# ifdef ALLOW_SALT0_CONTROL
c$openad INDEPENDENT(xx_salt_dummy)
# endif
# ifdef ALLOW_HFLUX0_CONTROL
c$openad INDEPENDENT(xx_hflux0)
# endif
# ifdef ALLOW_SFLUX0_CONTROL
c$openad INDEPENDENT(xx_sflux0)
# endif
# ifdef ALLOW_TAUU0_CONTROL
c$openad INDEPENDENT(xx_tauu0)
# endif
# ifdef ALLOW_TAUV0_CONTROL
c$openad INDEPENDENT(xx_tauv0)
# endif
# ifdef ALLOW_DIFFKR_CONTROL
c$openad INDEPENDENT(xx_diffkr_dummy)
# endif
# ifdef ALLOW_KAPGM_CONTROL
c$openad INDEPENDENT(xx_kapgm)
# endif
# ifdef ALLOW_TR10_CONTROL
c$openad INDEPENDENT(xx_tr1)
# endif
# ifdef ALLOW_HFLUXM_CONTROL
c$openad INDEPENDENT(xx_hfluxm)
# endif
# ifdef ALLOW_GENARR2D_CONTROL
cphc$openad INDEPENDENT(xx_genarr2d)
c$openad INDEPENDENT(xx_genarr2d_dummy)
# endif
# ifdef ALLOW_GENARR3D_CONTROL
cphc$openad INDEPENDENT(xx_genarr3d)
c$openad INDEPENDENT(xx_genarr3d_dummy)
# endif
# ifdef ALLOW_GENTIM2D_CONTROL
cphc$openad INDEPENDENT(xx_gentim2d)
c$openad INDEPENDENT(xx_gentim2d_dummy)
# endif
#endif /* ALLOW_OPENAD */

#ifdef ALLOW_DEBUG
      IF (debugMode) CALL DEBUG_CALL('INITIALISE_VARIA',myThid)
#endif
C--   Set initial conditions (variable arrays)
      CALL TIMER_START('INITIALISE_VARIA    [THE_MAIN_LOOP]', myThid)
      CALL INITIALISE_VARIA( myThid )
      CALL TIMER_STOP ('INITIALISE_VARIA    [THE_MAIN_LOOP]', myThid)
#ifdef ECCO_CTRL_DEPRECATED
#ifdef ALLOW_ECCO
cph: avoid renewed call of initialise_varia in recomputation loop
cph: in some circumstances
CADJ STORE sbar_gen,tbar_gen  = onetape
#endif
#endif

#ifdef ALLOW_SHOWFLOPS
      CALL TIMER_START('SHOWFLOPS_INIT      [THE_MAIN_LOOP]', myThid)
      CALL SHOWFLOPS_INIT( myThid )
      CALL TIMER_STOP ('SHOWFLOPS_INIT      [THE_MAIN_LOOP]', myThid)
#endif

c--   Do the model integration.
      CALL TIMER_START('MAIN LOOP           [THE_MAIN_LOOP]', myThid)

c     >>>>>>>>>>>>>>>>>>>>>>>>>>>   LOOP   <<<<<<<<<<<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>>>>>>>>>>  STARTS  <<<<<<<<<<<<<<<<<<<<<<<<<<<<

c++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#ifndef ALLOW_OPENAD
# ifdef ALLOW_AUTODIFF
#  ifdef ALLOW_TAMC_CHECKPOINTING
c++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      max_lev4=nTimeSteps/(nchklev_1*nchklev_2*nchklev_3)+1
      max_lev3=nTimeSteps/(nchklev_1*nchklev_2)+1
      max_lev2=nTimeSteps/nchklev_1+1

c**************************************
#   ifdef ALLOW_DIVIDED_ADJOINT
CADJ loop = divided
#   endif
c**************************************

#   ifdef AUTODIFF_4_LEVEL_CHECKPOINT
      do ilev_4 = 1,nchklev_4
         if(ilev_4.le.max_lev4) then
c**************************************
#ifdef ALLOW_AUTODIFF_WHTAPEIO
            CALL AUTODIFF_WHTAPEIO_SYNC( 4 , 0, myThid )
#endif
            CALL AUTODIFF_STORE( myThid )
#include "checkpoint_lev4_directives.h"
            CALL AUTODIFF_RESTORE( myThid )
#ifdef ALLOW_AUTODIFF_WHTAPEIO
            CALL AUTODIFF_WHTAPEIO_SYNC( 4 , 1, myThid )
#endif
c**************************************
c--     Initialise storage for the middle loop.
CADJ    INIT tapelev3 = USER
#   endif /* AUTODIFF_4_LEVEL_CHECKPOINT */

#   ifndef AUTODIFF_2_LEVEL_CHECKPOINT
      do ilev_3 = 1,nchklev_3
         if(ilev_3.le.max_lev3) then
c**************************************
#ifdef ALLOW_AUTODIFF_WHTAPEIO
            CALL AUTODIFF_WHTAPEIO_SYNC( 3 , 0, myThid )
#endif
            CALL AUTODIFF_STORE( myThid )
#include "checkpoint_lev3_directives.h"
            CALL AUTODIFF_RESTORE( myThid )
#ifdef ALLOW_AUTODIFF_WHTAPEIO
            CALL AUTODIFF_WHTAPEIO_SYNC( 3 , 1, myThid )
#endif
c**************************************
c--     Initialise storage for the middle loop.
CADJ    INIT tapelev2 = USER
#   endif /* AUTODIFF_2_LEVEL_CHECKPOINT */

        do ilev_2 = 1,nchklev_2
         if(ilev_2.le.max_lev2) then
c**************************************
#ifdef ALLOW_AUTODIFF_WHTAPEIO
            CALL AUTODIFF_WHTAPEIO_SYNC( 2 , 0, myThid )
#endif
            CALL AUTODIFF_STORE( myThid )
#include "checkpoint_lev2_directives.h"
            CALL AUTODIFF_RESTORE( myThid )
#ifdef ALLOW_AUTODIFF_WHTAPEIO
            CALL AUTODIFF_WHTAPEIO_SYNC( 2 , 1, myThid )
#endif
c**************************************
CMM(
CMM IF MULTISCALE NEED EXCHANGES BEFORE INNER LOOP 
CMM IF EVER MAKE THIS 3 OR 4 LEVEL MAY NEED TO ADD ABOVE TOO
CMM read_pickup.F exchanges
#ifdef MULTISCALE_COUPLING_TAPES
C     Fill in edge regions
      CALL EXCH_UV_3D_RL( uVel, vVel, .TRUE., Nr, myThid )
#if defined(ALLOW_EDDYPSI) && defined(ALLOW_GMREDI)
      IF (GM_InMomAsStress) THEN
        CALL EXCH_UV_3D_RL( uEulerMean, vEulerMean, .TRUE., Nr, myThid )
      ENDIF
#endif
      CALL EXCH_3D_RL( theta, Nr, myThid )
      CALL EXCH_3D_RL( salt,  Nr, myThid )
#ifdef ALLOW_ADAMSBASHFORTH_3
      CALL EXCH_UV_3D_RL( guNm(1-OLx,1-OLy,1,1,1,1),
     &                    gvNm(1-OLx,1-OLy,1,1,1,1),.TRUE.,Nr,myThid )
      CALL EXCH_UV_3D_RL( guNm(1-OLx,1-OLy,1,1,1,2),
     &                    gvNm(1-OLx,1-OLy,1,1,1,2),.TRUE.,Nr,myThid )
      CALL EXCH_3D_RL( gtNm(1-OLx,1-OLy,1,1,1,1), Nr, myThid )
      CALL EXCH_3D_RL( gtNm(1-OLx,1-OLy,1,1,1,2), Nr, myThid )
      CALL EXCH_3D_RL( gsNm(1-OLx,1-OLy,1,1,1,1), Nr, myThid )
      CALL EXCH_3D_RL( gsNm(1-OLx,1-OLy,1,1,1,2), Nr, myThid )
#else /* ALLOW_ADAMSBASHFORTH_3 */
      CALL EXCH_UV_3D_RL( guNm1, gvNm1, .TRUE., Nr, myThid )
      CALL EXCH_3D_RL( gtNm1, Nr, myThid )
      CALL EXCH_3D_RL( gsNm1, Nr, myThid )
#endif /* ALLOW_ADAMSBASHFORTH_3 */
      CALL EXCH_XY_RL( etaN, myThid )
CMM      CALL EXCH_XY_RL( etaH, myThid )
#ifdef EXACT_CONSERV
      CALL EXCH_XY_RL( detaHdt, myThid )
#endif

      IF ( storePhiHyd4Phys )
     &  CALL EXCH_3D_RL( totPhiHyd, Nr, myThid )

#ifdef ALLOW_NONHYDROSTATIC
      IF ( use3Dsolver ) THEN
        CALL EXCH_3D_RL( phi_nh, Nr, myThid )
      ENDIF
      IF ( nonHydrostatic ) THEN
#ifdef ALLOW_ADAMSBASHFORTH_3
        CALL EXCH_3D_RL( gwNm(1-OLx,1-OLy,1,1,1,1), Nr, myThid )
        CALL EXCH_3D_RL( gwNm(1-OLx,1-OLy,1,1,1,2), Nr, myThid )
#else /* ALLOW_ADAMSBASHFORTH_3 */
        CALL EXCH_3D_RL( gwNm1,  Nr, myThid )
#endif /* ALLOW_ADAMSBASHFORTH_3 */
      ENDIF
      IF ( selectNHfreeSurf.GE.1 ) THEN
        CALL EXCH_XY_RL( dPhiNH, myThid )
      ENDIF
#endif /* ALLOW_NONHYDROSTATIC */
CMM bling_read_pickup.F  
#ifdef ALLOW_BLING
CMM BLING WTH
      CALL EXCH_3D_RL( pH, Nr, myThid )
      CALL EXCH_3D_RL( irr_mem, Nr, myThid )
      CALL EXCH_3D_RL( chl, Nr, myThid )
      CALL EXCH_3D_RL( phyto_sm, Nr, myThid )
      CALL EXCH_3D_RL( phyto_lg, Nr, myThid )
      CALL EXCH_3D_RL( phyto_diaz, Nr, myThid )
#endif /* ALLOW_BLING */
CMM ggl90_read_pickup.F
#ifdef ALLOW_GGL90
CMM GGL90 WTH
      CALL EXCH_3D_RL( GGL90TKE, Nr, myThid )
#ifdef ALLOW_GGL90_IDEMIX
      CALL EXCH_3D_RL( IDEMIX_E, Nr, myThid )
#endif
#endif /*  ALLOW_GGL90  */

CMM ptracers_read_pickup.F 
#ifdef ALLOW_PTRACERS
        DO iTracer = 1, PTRACERS_numInUse
          CALL EXCH_3D_RL( gpTrNm1(1-OLx,1-OLy,1,1,1,iTracer),
     &                     Nr, myThid )
          CALL EXCH_3D_RL( pTracer(1-OLx,1-OLy,1,1,1,iTracer),
     &                     Nr, myThid )
CMM left out _Ptracers_som ADD in if needed
        ENDDO
#endif /*  ALLOW_PTRACERS  */
CMM seaice_read_pickup.F
#ifdef ALLOW_SEAICE
       CALL EXCH_UV_XY_RL( uIce, vIce,.TRUE.,myThid)
       CALL EXCH_XY_RL( HEFF, myThid )
       CALL EXCH_XY_RL( AREA, myThid )
       CALL EXCH_3D_RL( TICES, nITD, myThid )
       CALL EXCH_XY_RL( HSNOW, myThid )
#if (defined(SEAICE_CGRID) && defined(SEAICE_ALLOW_EVP))
       IF ( SEAICEuseEVP ) THEN
         CALL EXCH_XY_RL( seaice_sigma1 , myThid )
         CALL EXCH_XY_RL( seaice_sigma2 , myThid )
         CALL EXCH_XY_RL( seaice_sigma12, myThid )
       ENDIF
#endif /* SEAICE_CGRID SEAICE_ALLOW_EVP */
#ifdef SEAICE_VARIABLE_SALINITY
       CALL EXCH_XY_RL( HSALT, myThid )
#endif
#ifdef SEAICE_ITD
       CALL EXCH_3D_RL( HEFFITD,  nITD, myThid )
       CALL EXCH_3D_RL( AREAITD,  nITD, myThid )
       CALL EXCH_3D_RL( HSNOWITD, nITD, myThid )
#endif /* SEAICE_ITD */
#ifdef ALLOW_SITRACER
         DO iTracer = 1, SItrNumInUse
          CALL EXCH_XY_RL( SItracer(1-OLx,1-OLy,1,1,iTrac), myThid )
         ENDDO
#endif /* ALLOW_SITRACER */
#endif /* ALLOW_SEAICE */

#endif /* MULTISCALE_COUPLING_TAPES */
CMM)

# endif /* ALLOW_TAMC_CHECKPOINTING */

c**************************************
c--
c--       Initialize storage for the innermost loop.
c--       Always check common block sizes for the checkpointing!
c--
CADJ INIT comlev1        = COMMON,nchklev_1
CADJ INIT comlev1_bibj   = COMMON,nchklev_1*nsx*nsy*nthreads_chkpt
CADJ INIT comlev1_bibj_k = COMMON,nchklev_1*nsx*nsy*nr*nthreads_chkpt
c--
#ifdef ALLOW_CTRL
CADJ INIT ctrltape       = COMMON,1
#endif
c--
#   ifdef ALLOW_KPP
CADJ INIT comlev1_kpp    = COMMON,nchklev_1*nsx*nsy
CADJ INIT comlev1_kpp_k  = COMMON,nchklev_1*nsx*nsy*nr
#   endif /* ALLOW_KPP */
c--
#   ifdef ALLOW_GMREDI
CADJ INIT comlev1_gmredi_k_gad
CADJ &    = COMMON,nchklev_1*nsx*nsy*nr*nthreads_chkpt*maxpass
#   endif /* ALLOW_GMREDI */
c--
#   ifdef ALLOW_PTRACERS
CADJ INIT comlev1_bibj_ptracers = COMMON,
CADJ &    nchklev_1*nsx*nsy*nthreads_chkpt*PTRACERS_num
CADJ INIT comlev1_bibj_k_ptracers = COMMON,
CADJ &    nchklev_1*nsx*nsy*nthreads_chkpt*PTRACERS_num*nr
#   endif /* ALLOW_PTRACERS */
c--
#   ifndef DISABLE_MULTIDIM_ADVECTION
CADJ INIT comlev1_bibj_gad = COMMON,
CADJ &    nchklev_1*nsx*nsy*nthreads_chkpt*maxpass
CADJ INIT comlev1_bibj_k_gad = COMMON,
CADJ &    nchklev_1*nsx*nsy*nr*nthreads_chkpt*maxpass
CADJ INIT comlev1_bibj_k_gad_pass = COMMON,
CADJ &    nchklev_1*nsx*nsy*nr*nthreads_chkpt*maxpass*maxpass
#   endif /* DISABLE_MULTIDIM_ADVECTION */
c--
#   ifdef ALLOW_MOM_COMMON
#   ifndef AUTODIFF_DISABLE_LEITH
CADJ INIT comlev1_mom_ijk_loop
CADJ &     = COMMON,nchklev_1*
CADJ &       (snx+2*olx)*nsx*(sny+2*oly)*nsy*nr*nthreads_chkpt
#   endif /* AUTODIFF_DISABLE_LEITH */
#   endif /* ALLOW_MOM_COMMON */
c--
#   if (defined (ALLOW_EXF) && defined (ALLOW_BULKFORMULAE))
CADJ INIT comlev1_exf_1
CADJ &     = COMMON,nchklev_1*snx*nsx*sny*nsy*nthreads_chkpt
CADJ INIT comlev1_exf_2
CADJ &     = COMMON,niter_bulk*nchklev_1*snx*nsx*sny*nsy*nthreads_chkpt
#   endif /* ALLOW_BULKFORMULAE */
c--
#   ifdef ALLOW_SEAICE
#    ifdef SEAICE_ALLOW_DYNAMICS
CADJ INIT comlev1_dynsol = COMMON,nchklev_1*MPSEUDOTIMESTEPS
#     ifdef SEAICE_LSR_ADJOINT_ITER
CADJ INIT comlev1_lsr = COMMON,nchklev_1*MPSEUDOTIMESTEPS*SOLV_MAX_FIXED
CADJ INIT comlev1_bibj_lsr = COMMON,
CADJ &  nchklev_1*nsx*nsy*nthreads_chkpt*MPSEUDOTIMESTEPS*SOLV_MAX_FIXED
#     else /* make the common blocks smaller to reduce memory footprint */
CADJ INIT comlev1_lsr = COMMON,nchklev_1*MPSEUDOTIMESTEPS
CADJ INIT comlev1_bibj_lsr = COMMON,
CADJ &  nsx*nsy*nthreads_chkpt*nchklev_1*MPSEUDOTIMESTEPS
#     endif
#    endif
#    ifdef SEAICE_ALLOW_EVP
CADJ INIT comlev1_evp = COMMON,nEVPstepMax*nchklev_1
CADJ INIT comlev1_bibj_evp = COMMON,
CADJ &  nsx*nsy*nthreads_chkpt*nEVPstepMax*nchklev_1
#    endif
CML#   ifdef SEAICE_MULTICATEGORY
CMLCADJ INIT comlev1_multdim
CMLCADJ &    = COMMON,nchklev_1*nsx*nsy*nthreads_chkpt*nitd
CML#   endif
#    ifndef DISABLE_MULTIDIM_ADVECTION
CADJ INIT comlev1_bibj_k_gadice = COMMON,
CADJ &    nchklev_1*nsx*nsy*nthreads_chkpt*maxpass
CADJ INIT comlev1_bibj_k_gadice_pass = COMMON,
CADJ &    nchklev_1*nsx*nsy*nthreads_chkpt*maxpass*maxpass
#    endif /* DISABLE_MULTIDIM_ADVECTION */
# endif /* ALLOW_SEAICE */
c--
#   ifdef ALLOW_THSICE
CADJ INIT comlev1_thsice_1 = COMMON,
CADJ &    nchklev_1*snx*nsx*sny*nsy*nthreads_chkpt
CADJ INIT comlev1_thsice_2 = COMMON,
CADJ &    nchklev_1*snx*nsx*sny*nsy*nlyr*nthreads_chkpt
CADJ INIT comlev1_thsice_3 = COMMON,
CADJ &    nchklev_1*snx*nsx*sny*nsy*MaxTsf*nthreads_chkpt
CADJ INIT comlev1_thsice_4 = COMMON,
CADJ &    nchklev_1*nsx*nsy*maxpass*nthreads_chkpt
CADJ INIT comlev1_thsice_5 = COMMON,
CADJ &    nchklev_1*snx*nsx*sny*nsy*MaxTsf*(niter_bulk+1)*nthreads_chkpt
CADJ INIT comlev1_thsice_s4t = COMMON,
CADJ &    nchklev_1*nsx*nsy*maxtsf*nthreads_chkpt
#   endif /* ALLOW_THSICE */
c--
#   ifdef ALLOW_STREAMICE
CADJ INIT comlev1_stream_nl = COMMON,nchklev_1*streamice_max_nl
CADJ INIT comlev1_stream_front = COMMON,nchklev_1*4
CADJ INIT comlev1_stream_ij
CADJ &     = COMMON,nchklev_1*4*(snx+2)*nsx*(sny+2)*nsy
CADJ INIT comlev1_stream_hybrid
CADJ &     = COMMON,nchklev_1*snx*nsx*sny*nsy*nr*nthreads_chkpt
#   endif
c--
#   ifdef ALLOW_CG2D_NSA
CADJ INIT comlev1_cg2d
CADJ &     = COMMON,nchklev_1*nthreads_chkpt
CADJ INIT comlev1_cg2d_iter
CADJ &     = COMMON,nchklev_1*nthreads_chkpt*numItersMax
#   endif
c--
c**************************************

#ifdef STORE_LOADEDREC_TEST
          DO bj = myByLo(myThid), myByHi(myThid)
           DO bi = myBxLo(myThid), myBxHi(myThid)
            loadedRec(bi,bj) = 0
           ENDDO
          ENDDO
#endif /* STORE_LOADEDREC_TEST */

#ifdef ALLOW_TAMC_CHECKPOINTING

          do ilev_1 = 1,nchklev_1

c--         The if-statement below introduces a some flexibility in the
c--         choice of the 3-tupel ( nchklev_1, nchklev_2, nchklev_3 ).

            iloop = (ilev_2 - 1)*nchklev_1 + ilev_1
#    ifndef AUTODIFF_2_LEVEL_CHECKPOINT
     &            + (ilev_3 - 1)*nchklev_2*nchklev_1
#    endif
#    ifdef AUTODIFF_4_LEVEL_CHECKPOINT
     &            + (ilev_4 - 1)*nchklev_3*nchklev_2*nchklev_1
#    endif

            if ( iloop .le. nTimeSteps ) then

#  else /* ALLOW_TAMC_CHECKPOINTING  undefined */

      DO iloop = 1, nTimeSteps

c++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  endif /* ALLOW_TAMC_CHECKPOINTING */
# endif /* ALLOW_AUTODIFF */
#endif /* undef ALLOW_OPENAD */
c++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef ALLOW_AUTODIFF
      DO iloop = 1, nTimeSteps
#endif /* ALLOW_AUTODIFF */

c--     >>> Loop body start <<<

#ifdef ALLOW_AUTODIFF
      nIter0 = NINT( (startTime-baseTime)/deltaTClock )
C--   Reset the model iteration counter and the model time.
      myIter = nIter0 + (iloop-1)
      myTime = startTime + deltaTClock*(iloop-1)
# ifndef ALLOW_OPENAD
      ikey_dynamics = ilev_1
# endif
#endif

#ifdef ALLOW_ECCO
      IF ( useECCO ) then
# ifdef ALLOW_DEBUG
        IF (debugMode) CALL DEBUG_CALL('cost_averagesfields',myThid)
# endif
c--   Accumulate time averages of temperature, salinity
        CALL TIMER_START('COST_AVERAGESFIELDS [MAIN_DO_LOOP]',myThid)
        CALL COST_AVERAGESFIELDS( myTime, myThid )
        CALL TIMER_STOP ('COST_AVERAGESFIELDS [MAIN_DO_LOOP]',myThid)
      ENDIF
#endif /* ALLOW_ECCO */

#ifdef ALLOW_PROFILES
      IF (usePROFILES) THEN
#ifdef ALLOW_DEBUG
        IF (debugMode) CALL DEBUG_CALL('profiles_inloop',myThid)
#endif
c--     Accumulate in-situ time averages of theta, salt, and SSH.
#ifdef ALLOW_AUTODIFF
C--   Reset the model iteration counter and the model time.
        myIter = nIter0 + (iloop-1)
        myTime = startTime + deltaTClock*(iloop-1)
#endif
        CALL TIMER_START('PROFILES_INLOOP    [MAIN_DO_LOOP]', myThid)
        CALL PROFILES_INLOOP( myTime, myThid )
        CALL TIMER_STOP ('PROFILES_INLOOP    [MAIN_DO_LOOP]', myThid)
      ENDIF
#endif

      CALL TIMER_START('MAIN_DO_LOOP        [THE_MAIN_LOOP]', myThid)
      CALL MAIN_DO_LOOP( iloop, myTime, myIter, myThid )
      CALL TIMER_STOP ('MAIN_DO_LOOP        [THE_MAIN_LOOP]', myThid)

c--     >>> Loop body end <<<
#ifndef ALLOW_OPENAD
# ifdef ALLOW_AUTODIFF
#   ifdef ALLOW_TAMC_CHECKPOINTING
            endif
          enddo
          endif
        enddo
#    ifndef AUTODIFF_2_LEVEL_CHECKPOINT
        endif
      enddo
#    endif
#    ifdef AUTODIFF_4_LEVEL_CHECKPOINT
       endif
      enddo
#    endif
#   else /* ndef ALLOW_TAMC_CHECKPOINTING */
      ENDDO
#   endif /* ALLOW_TAMC_CHECKPOINTING */
# else /* ALLOW_AUTODIFF */
      ENDDO
# endif /* ALLOW_AUTODIFF */
#endif /* undef ALLOW_OPENAD */

c     >>>>>>>>>>>>>>>>>>>>>>>>>>>   LOOP   <<<<<<<<<<<<<<<<<<<<<<<<<<<<
c     >>>>>>>>>>>>>>>>>>>>>>>>>>>  STOPS   <<<<<<<<<<<<<<<<<<<<<<<<<<<<

#ifdef ALLOW_ECCO
c--     Accumulate time averages of temperature, salinity
      CALL TIMER_START('COST_AVERAGESFIELDS [THE_MAIN_LOOP]',myThid)
      CALL COST_AVERAGESFIELDS( endtime, myThid )
      CALL TIMER_STOP ('COST_AVERAGESFIELDS [THE_MAIN_LOOP]',myThid)
#endif /* ALLOW_ECCO */

#ifdef ALLOW_PROFILES
      IF (usePROFILES) THEN
c--   Accumulate in-situ time averages of temperature, salinity, SSH.
        CALL TIMER_START('PROFILES_INLOOP    [THE_MAIN_LOOP]', myThid)
        CALL PROFILES_INLOOP( endtime, myThid )
        CALL TIMER_STOP ('PROFILES_INLOOP    [THE_MAIN_LOOP]', myThid)
c--   Compute all profiles cost function contributions.
        CALL COST_PROFILES( myIter, myTime, myThid )
      ENDIF
#endif

#ifdef ALLOW_ECCO
      IF ( useECCO ) then
c--   Compute all ecco cost function contributions.
        CALL TIMER_START('ECCO_COST_DRIVER   [THE_MAIN_LOOP]', myThid)
        CALL ECCO_COST_DRIVER ( endTime, myIter, myThid )
        CALL TIMER_STOP ('ECCO_COST_DRIVER   [THE_MAIN_LOOP]', myThid)
      ENDIF
#endif /* ALLOW_ECCO */

#ifdef ALLOW_COST
c--   Sum all cost function contributions.
      CALL TIMER_START('COST_FINAL         [ADJOINT SPIN-DOWN]', myThid)
      CALL COST_FINAL ( myThid )
      CALL TIMER_STOP ('COST_FINAL         [ADJOINT SPIN-DOWN]', myThid)

# ifdef ALLOW_OPENAD
c$openad DEPENDENT(fc)
# endif /* ALLOW_OPENAD */

#endif /* ALLOW_COST */

      _BARRIER
      CALL TIMER_STOP ('MAIN LOOP           [THE_MAIN_LOOP]', myThid)

#ifdef ALLOW_DEBUG
      IF (debugMode) CALL DEBUG_LEAVE('THE_MAIN_LOOP',myThid)
#endif

      RETURN
      END

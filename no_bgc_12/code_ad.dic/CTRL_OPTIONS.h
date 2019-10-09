CBOP
C !ROUTINE: CTRL_OPTIONS.h
C !INTERFACE:
C #include "CTRL_OPTIONS.h"

C !DESCRIPTION:
C *==================================================================*
C | CPP options file for Control (ctrl) package:
C | Control which optional features to compile in this package code.
C *==================================================================*
CEOP

#ifndef CTRL_OPTIONS_H
#define CTRL_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_CTRL
#ifdef ECCO_CPPOPTIONS_H

C-- When multi-package option-file ECCO_CPPOPTIONS.h is used (directly included
C    in CPP_OPTIONS.h), this option file is left empty since all options that
C   are specific to this package are assumed to be set in ECCO_CPPOPTIONS.h

#else /* ndef ECCO_CPPOPTIONS_H */
C   ==================================================================
C-- Package-specific Options & Macros go here

#define CTRL_SET_PREC_32
#define ALLOW_PACKUNPACK_METHOD2

#undef ALLOW_NONDIMENSIONAL_CONTROL_IO
#define EXCLUDE_CTRL_PACK

C       >>> Reduced regular control list
C now only uvel0,vvel0 need special flags to be used
C the others (theta, salt, ...) can be called at run time
#undef ALLOW_UVEL0_CONTROL
#undef ALLOW_VVEL0_CONTROL

C       >>> Depth control
#undef ALLOW_DEPTH_CONTROL
#ifdef ALLOW_DEPTH_CONTROL
# define ALLOW_DIFFERENTIATE_CG2D_MATRIX
# define USE_SMOOTH_MIN
#endif

C       >>> Other Control.
#undef ALLOW_DIFFKR_CONTROL
#undef ALLOW_KAPGM_CONTROL
#undef ALLOW_KAPREDI_CONTROL
#undef ALLOW_BOTTOMDRAG_CONTROL

C       >>> Backward compatibility option (before checkpoint 65p)
#undef ALLOW_DIFFKR_CONTROL_OLD
#undef ALLOW_KAPGM_CONTROL_OLD
#undef ALLOW_KAPREDI_CONTROL_OLD

C       >>> Generic Control.
#define ALLOW_GENARR2D_CONTROL
#define ALLOW_GENARR3D_CONTROL
#define ALLOW_GENTIM2D_CONTROL

C       >>> OBCS Control.
#ifdef ALLOW_OBCS
#undef  ALLOW_OBCSN_CONTROL
#undef  ALLOW_OBCSS_CONTROL
#undef ALLOW_OBCSW_CONTROL
#undef  ALLOW_OBCSE_CONTROL
#if (defined (ALLOW_OBCSN_CONTROL) || \
     defined (ALLOW_OBCSS_CONTROL) || \
     defined (ALLOW_OBCSW_CONTROL) || \
     defined (ALLOW_OBCSE_CONTROL))
# define ALLOW_OBCS_CONTROL
#endif
#endif /* ALLOW_OBCS */
cts ---

C  o Rotation of wind/stress controls adjustments
C    from Eastward/Northward to model grid directions
#undef ALLOW_ROTATE_UV_CONTROLS

C  o use pkg/smooth correlation operator (incl. smoother) for 2D controls (Weaver, Courtier 01)
C    This CPP option just sets the default for ctrlSmoothCorrel2D to .TRUE.
#undef ALLOW_SMOOTH_CORREL2D
C  o use pkg/smooth correlation operator (incl. smoother) for 3D controls (Weaver, Courtier 01)
C    This CPP option just sets the default for ctrlSmoothCorrel3D to .TRUE.
#undef ALLOW_SMOOTH_CORREL3D

C  o apply pkg/ctrl/ctrl_smooth.F to 2D controls (outside of ctrlSmoothCorrel2D)
#undef ALLOW_CTRL_SMOOTH
C  o apply pkg/smooth/smooth_diff2d.F to 2D controls (outside of ctrlSmoothCorrel2D)
#undef ALLOW_SMOOTH_CTRL2D
C  o apply pkg/smooth/smooth_diff3d.F to 3D controls (outside of ctrlSmoothCorrel3D)
#undef ALLOW_SMOOTH_CTRL3D

C   ==================================================================
#endif /* ndef ECCO_CPPOPTIONS_H */
#endif /* ALLOW_CTRL */
#endif /* CTRL_OPTIONS_H */

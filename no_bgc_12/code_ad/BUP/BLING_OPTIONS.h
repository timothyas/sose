C $Header:  $
C $Name:  $

#ifndef BLING_OPTIONS_H
#define BLING_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_BLING
C     Package-specific Options & Macros go here

c Active tracer for total phytoplankton biomass
#undef  ADVECT_PHYTO

c Prevents negative values in nutrient fields
CMM # TRY TO FIX BUDGET #define BLING_NO_NEG

c Assume that phytoplankton in the mixed layer experience
c the average light over the mixed layer
c (as in original BLING model)
cmm #define ML_MEAN_LIGHT
#undef ML_MEAN_LIGHT

c Assume that phytoplankton are homogenized in the mixed layer
cmm #define ML_MEAN_PHYTO
#undef ML_MEAN_PHYTO

c Determine PAR from shortwave radiation from EXF package
#define  USE_EXFQSW

CMM(
c Use local atmospheric pressure from EXF package for fugacity factor
#define  USE_EXF_ATMPRES
CMM)

c Sub grid scale sediments
#undef  USE_SGS_SED

c Read atmospheric pCO2 values from EXF package
c *** to be specified in ECCO_CPPOPTIONS.h ***
#define  USE_EXFCO2

c  apply remineralization from diel vertical migration
#undef USE_BLING_DVM
c In the DVM routine, assume fixed mixed layer depth
c (so no need to calc MLD in bling_production)
#define FIXED_MLD_DVM

c Simplify some parts of the code that are problematic
c when using the adjoint
#define BLING_ADJOINT_SAFE

c For adjoint safe, use constant MLD in bling_dvm
#ifdef BLING_ADJOINT_SAFE
#define FIXED_MLD_DVM
#endif

#endif /* ALLOW_BLING */
#endif /* BLING_OPTIONS_H */

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***

# Depth sensitivity + SOSE 1/12 degree

Compilation notes, additions to `code_ad` that are different from `code/` and `code/BUP/`:

1. add the following to `CTRL_OPTIONS.h`

    ```
    #define ALLOW_DEPTH_CONTROL
    #define ALLOW_DIFFERENTIATE_CG2D_MATRIX
    #define USE_SMOOTH_MIN
    #define ALLOW_GENARR2D_CONTROL
    ```

    also, probably a good idea to use single precision for SOSE...
2. add `iumekey` to `tamc.h` as in `MITgcm/verification/bottom_ctrl_5x5/code_ad.no_nsa/tamc.h`
3. add `MITgcm/pkg/autodiff/AUTODIFF_OPTIONS.h` to this dir
4. add `MITgcm/pkg/ecco/ECCO_OPTIONS.h` to this dir
5. need to be specific with free surface for store directives in `CPP_OPTIONS.h`:
    ```
    #undef NONLIN_FRSURF
    #define DISABLE_RSTAR_CODE
    #define DISABLE_SIGMA_CODE
    ```

Compilation notes related to biogeochem stuff

5. if ptracers are desired as control variables, use `BUP/ctrl_map_ini_genarr.F`. 
    I'm ignoring this for now to avoid the merge with these additions and my depth stuff...
6. `BUP/ecco_phys.F` differences are not clear to me, continuing with the one in MITgcm since I'm familiar with it
7. `BUP/exf_getffields.F` has some special tricks with shortwave radiation important for biogeochem
8. `BUP/the_main_loop.F`
    - `MULTISCALE_COUPLING_TAPES`: not sure what this macro does
    - lots of extra EXCH routines when this multiscale macro is defined
    - `ASSIMILATE_PDAF`: not sure what this does ...
9. Not using `bling`

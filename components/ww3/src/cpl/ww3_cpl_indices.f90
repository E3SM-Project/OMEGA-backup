module ww3_cpl_indices
  
  use seq_flds_mod
  use mct_mod

  implicit none

  SAVE
  public                               ! By default make data private

  integer :: index_x2w_Sa_u     
  integer :: index_x2w_Sa_v     
  integer :: index_x2w_Sa_tbot  
  integer :: index_x2w_Si_ifrac
  integer :: index_x2w_So_t     
  integer :: index_x2w_So_u     
  integer :: index_x2w_So_v     
  integer :: index_x2w_So_bldepth     
  integer :: index_x2w_So_ssh

  integer :: index_w2x_Sw_lamult
  integer :: index_w2x_Sw_ustokes
  integer :: index_w2x_Sw_vstokes
  integer :: index_w2x_Sw_hstokes
  integer :: index_w2x_Sw_Sxx
  integer :: index_w2x_Sw_Sxy
  integer :: index_w2x_Sw_Syy

contains

  subroutine ww3_cpl_indices_set( )

    type(mct_aVect) :: w2x      ! temporary
    type(mct_aVect) :: x2w      ! temporary

    ! Determine attribute vector indices

    ! create temporary attribute vectors
    call mct_aVect_init(x2w, rList=seq_flds_x2w_fields, lsize=1)
    call mct_aVect_init(w2x, rList=seq_flds_w2x_fields, lsize=1)

    index_x2w_Sa_u       = mct_avect_indexra(x2w,'Sa_u')       ! Zonal wind at lowest level (this should probably be at 10m)
    index_x2w_Sa_v       = mct_avect_indexra(x2w,'Sa_v')       ! Meridional wind at lowest level (see above)
    index_x2w_Sa_tbot    = mct_avect_indexra(x2w,'Sa_tbot')    ! Temperature at lowest level
    index_x2w_Si_ifrac   = mct_avect_indexra(x2w,'Si_ifrac')   ! Fractional sea ice coverage 
    index_x2w_So_t       = mct_avect_indexra(x2w,'So_t')       ! Sea surface temperature
    index_x2w_So_u       = mct_avect_indexra(x2w,'So_u')       ! Zonal sea surface water velocity
    index_x2w_So_v       = mct_avect_indexra(x2w,'So_v')       ! Meridional sea surface water velocity
    index_x2w_So_bldepth = mct_avect_indexra(x2w,'So_bldepth') ! Boundary layer depth
    index_x2w_So_ssh     = mct_avect_indexra(x2w,'So_ssh')     ! Sea surface height 

    index_w2x_Sw_lamult  = mct_avect_indexra(w2x,'Sw_lamult')  ! Langmuir multiplier
    index_w2x_Sw_ustokes = mct_avect_indexra(w2x,'Sw_ustokes') ! Stokes drift u component
    index_w2x_Sw_vstokes = mct_avect_indexra(w2x,'Sw_vstokes') ! Stokes drift v component
    index_w2x_Sw_hstokes = mct_avect_indexra(w2x,'Sw_hstokes') ! Stokes drift depth
    index_w2x_Sw_Sxx     = mct_avect_indexra(w2x,'Sw_Sxx')     ! Radiation stress xx component
    index_w2x_Sw_Sxy     = mct_avect_indexra(w2x,'Sw_Sxy')     ! Radiation stress xy component
    index_w2x_Sw_Syy     = mct_avect_indexra(w2x,'Sw_Syy')     ! Radiation stress yy component

    call mct_aVect_clean(x2w)
    call mct_aVect_clean(w2x)

  end subroutine ww3_cpl_indices_set

end module ww3_cpl_indices

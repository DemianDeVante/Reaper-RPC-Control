--    ⠀⠀⠀⠀⣖⢶⣤⠀⣀⣀⣀⣀⢀⣤⢆⢦⠀⠀⠀⠀     @@NNNB@g,                            @K                           @@NNNB@N,
--    ⠀⠀⠀⠀⣀⢀⠛⠀⠀⠀⠀⠀⠈⠣⢀⣸⠀⠀⠀⠀     @P     "@K    ,,g,    ,, ,g,  ,,,,   ,,   ,,gg,    , ,,g,         @K      $@
--    ⠀⠀⠀⠊⠀⠀⢻⣷⠀⠀⠀⢠⣿⠋⠀⠀⢢⠀⠀      @P      ]@  g@*  "%b  ]@P-`]@@" "@K  $@  @P - ]@P  @@"`']@        @K      ]@P
--    ⠀⠀⠀⠀⠀⠀⠸⠖⠀⠀⠀⠀⢾⠀⠀⠀⢈⠀⠀⠀     @P      ]@  @@gggg@@P ]@    @    $@  $@   ,ggp@@P  @C    @P       @K      ]@P
--    ⠀⠀⠀⣀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⡜⠀⠀⠀     @P     ,@P  $@    ,g  ]@    @    $@  $@ ]@"    @L  @P    @P       @K     ,@K
--    ⠀⠀⠀⣀⣖⢄⠀⠀⠀⠀⠀⠀⠀⢀⣠⠎⣀⠀⠀⠀     @@@@@@N*`    7BNg@P'  $@    @    &K  @K  %@ggN"%@  @P    @P       @@@@@@NP"
--    ⠀⡄⠁⢀⠈⢄⠀⣏⢋⣧⣏⢃⣇⠀⠤⠀⠀⠈⢄⠀    
--    ⢰⣀⣀⠀⠀⠀⠀⠀⠑⠚⠃⠈⠀⠀⠀⠀⢸⢀⣠⡀    @ Github :                                   https://github.com/DemianDeVante
--    ⠘⣯⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢯⣧⠁    @ Reaper Forums :                https://forum.cockos.com/member.php?u=174529
--    ⠀⠀⠀⢦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡜⠀⠀⠀    @ YouTube :          https://www.youtube.com/channel/UCSofVw-5N5cjyz8L8BYZGhg
--    ⠀⠀⠀⢸⠀⠀⠀⠀⢤⢤⢄⢤⠀⠀⠀⠀⠀⠀⠀⠀   
--    ⠀⠀⠀⣴⣯⣿⣿⣯⢁⠀⠀⠈⣯⣿⣿⣿⣄⠀⠀⠀    @ Donation :                                  https://paypal.me/DemianDeVante

---------- Get Visible Track FX Chain ------------------------------------------
track_count =  reaper.CountTracks( 0 )
for ntrack = 0, track_count -1 do
  xtrack = reaper.GetTrack( 0, ntrack )
  track_visiblefx = reaper.TrackFX_GetChainVisible( xtrack )
  trackinput_visiblefx = reaper.TrackFX_GetRecChainVisible( xtrack )
  ---------- If Input FX Chain Open -------------------------------------------
  if trackinput_visiblefx < -1 then -- if input chain visible but no fx selected
    trackinput_visiblefx = 16777216
  end
  if trackinput_visiblefx > -1 then -- if input chain visible
    track = xtrack
    fxnumber = trackinput_visiblefx + 16777216
    fxcount =  reaper.TrackFX_GetRecCount( xtrack )
  end
  ---------- If FX Chain Open -------------------------------------------------
  if track_visiblefx < -1 then -- if chain visible but no fx selected
    track_visiblefx = 0
  end
  if track_visiblefx > -1 then -- if chain visible
    track = xtrack
    fxnumber = track_visiblefx
    fxcount = reaper.TrackFX_GetCount( xtrack )
  end
end
---------- Get Visible Take FX Chain ------------------------------------------
if not track then
  item_count = reaper.CountMediaItems( 0 )
  for nitem = 0, item_count -1 do
    xitem = reaper.GetMediaItem( 0, nitem )
    take_count = reaper.CountTakes( xitem )
    for ntake = 0, take_count -1 do
      xtake = reaper.GetTake( xitem, ntake )
      take_visiblefx = reaper.TakeFX_GetChainVisible( xtake )
      if take_visiblefx < -1 then -- if chain visible but no fx selected
        take_visiblefx = 0
      end
      if take_visiblefx > -1 then -- if chain visible
        take = xtake
        fxnumber = take_visiblefx
        fxcount = reaper.TakeFX_GetCount( xtake )
      end    
    end
  end
end

---------- Get Master Track ---------------------------------------------------
if not track and not take then
  mastertrack =   reaper.GetMasterTrack( 0 )
  mastertrack_visiblefx = reaper.TrackFX_GetChainVisible( mastertrack )
  mastertrackinput_visiblefx = reaper.TrackFX_GetRecChainVisible( mastertrack )
  ---------- If Monitor FX Chain Open -----------------------------------------
  if mastertrackinput_visiblefx < -1 then -- if input chain visible but no fx selected
    mastertrackinput_visiblefx = 16777216
  end
  if mastertrackinput_visiblefx > -1 then -- if input chain visible
    track = mastertrack
    fxnumber = mastertrackinput_visiblefx + 16777216
    fxcount =  reaper.TrackFX_GetRecCount( mastertrack )
  end
  ---------- If Master FX Chain Open ------------------------------------------  
  if mastertrack_visiblefx < -1 then -- if chain visible but no fx selected
    mastertrack_visiblefx = 0
  end
  if mastertrack_visiblefx > -1 then -- if chain visible
    track = mastertrack
    fxnumber = mastertrack_visiblefx
    fxcount = reaper.TrackFX_GetCount( mastertrack )
  end
end

---------- Select Next FX in Chain --------------------------------------------
if track then
    if (fxnumber < (fxcount -1)) or (fxnumber > (fxcount -1) and fxnumber < (16777216 + fxcount -1)) then
      reaper.TrackFX_Show( track, fxnumber +1 , 1 )
    end
elseif take then
    if (fxnumber < (fxcount -1)) then
      reaper.TakeFX_Show( take, fxnumber +1 , 1 )
    end
end

reaper.defer(function() end)

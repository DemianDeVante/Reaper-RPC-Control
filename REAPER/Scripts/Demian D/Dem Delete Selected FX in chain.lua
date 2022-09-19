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

function fxchain_getselected() ----------------------------------------------------------- Returns: fxcount, fxnumber(even input i.e. 16777218, 
  ---------- Get Visible Track FX Chain ---------                                                   track, take, isinput (0, 16777216 if input)
  local track, fxnumber, fxcount, take
  local inputadd = 0
  local track_count =  reaper.CountTracks( 0 )
  for ntrack = 0, track_count -1 do
    local xtrack = reaper.GetTrack( 0, ntrack )
    local track_visiblefx = reaper.TrackFX_GetChainVisible( xtrack )
    local trackinput_visiblefx = reaper.TrackFX_GetRecChainVisible( xtrack )
    ---------- If Input FX Chain Open -------------
    if trackinput_visiblefx > -1 then -- if input chain visible
      inputadd = 16777216
      track = xtrack
      fxnumber = trackinput_visiblefx + inputadd
      fxcount =  reaper.TrackFX_GetRecCount( xtrack )
    end
    ---------- If FX Chain Open ----------
    if track_visiblefx > -1 then -- if chain visible
      track = xtrack
      fxnumber = track_visiblefx
      fxcount = reaper.TrackFX_GetCount( xtrack )
    end
  end
  ---------- Get Visible Take FX Chain -------------
  if not track then
    local item_count = reaper.CountMediaItems( 0 )
    for nitem = 0, item_count -1 do
      local xitem = reaper.GetMediaItem( 0, nitem )
      local take_count = reaper.CountTakes( xitem )
      for ntake = 0, take_count -1 do
        local xtake = reaper.GetTake( xitem, ntake )
        local take_visiblefx = reaper.TakeFX_GetChainVisible( xtake )
        if take_visiblefx > -1 then -- if chain visible
          take = xtake
          fxnumber = take_visiblefx
          fxcount = reaper.TakeFX_GetCount( xtake )
        end    
      end
    end
  end
  ---------- Get Master Track ------------
  if not track and not take then
    local mastertrack =   reaper.GetMasterTrack( 0 )
    local mastertrack_visiblefx = reaper.TrackFX_GetChainVisible( mastertrack )
    local mastertrackinput_visiblefx = reaper.TrackFX_GetRecChainVisible( mastertrack )
    ---------- If Monitor FX Chain Open ---------------
    if mastertrackinput_visiblefx > -1 then -- if input chain visible
      inputadd = 16777216
      track = mastertrack
      fxnumber = mastertrackinput_visiblefx + inputadd
      fxcount =  reaper.TrackFX_GetRecCount( mastertrack )
    end
    ---------- If Master FX Chain Open --------------
    if mastertrack_visiblefx > -1 then -- if chain visible
      track = mastertrack
      fxnumber = mastertrack_visiblefx
      fxcount = reaper.TrackFX_GetCount( mastertrack )
    end
  end
  return fxcount, fxnumber, track, take, inputadd 
end
    
reaper.Undo_BeginBlock()
fxcount, fxnumber, track, take, isinput = fxchain_getselected()
if take then
  reaper.TakeFX_Delete(take, fxnumber)
elseif track then
  reaper.TrackFX_Delete(track, fxnumber)
end
reaper.Undo_EndBlock('Delete Selected FX', -1)

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

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

-- Variables -------------------------------------------------------------------------
reaper.Main_OnCommand(40289,0) -- clear item selection
starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
rplaystate = reaper.GetPlayStateEx( 0 )
play_cursor_pos = reaper.GetPlayPosition()
beat, measure, cml, fullbeats = reaper.TimeMap2_timeToBeats(0, play_cursor_pos)
next_measure = reaper.TimeMap2_beatsToTime(0, 0, measure + 1)
edit_cursor_pos = reaper.GetCursorPosition()
is_snapping = reaper.GetToggleCommandStateEx( 0, 1157 )

-- Set New Item Start Time -----------------------------------------------------------
if starttime == endtime then -- no time selection
  if rplaystate == 1 then -- if playing
    if is_snapping == 1 then
      take_start_pos = next_measure
    else 
      take_start_pos = play_cursor_pos
    end
    item_cursor_pos = play_cursor_pos

  elseif rplaystate <=2 then -- if not playing
    take_start_pos = edit_cursor_pos
    item_cursor_pos = edit_cursor_pos
  end
else
  take_start_pos = starttime
  item_cursor_pos = starttime
end

-- Main ------------------------------------------------------------------------------
track_count = reaper.CountSelectedTracks( 0 )
for ntrack = 0, track_count -1 do 
  xtrack = reaper.GetSelectedTrack( 0, ntrack )
  item_count = reaper.CountTrackMediaItems( xtrack )
  for nitem = 0, item_count -1 do
    xitem = reaper.GetTrackMediaItem( xtrack, nitem )
     item_pos=reaper.GetMediaItemInfo_Value( xitem, "D_POSITION")
     item_length=reaper.GetMediaItemInfo_Value(xitem, "D_LENGTH")
     if item_pos <= item_cursor_pos and item_pos+item_length > item_cursor_pos then
       newitem = reaper.SplitMediaItem( xitem , take_start_pos )
       if newitem == null then
         newitem = xitem
       end
       reaper.SetMediaItemInfo_Value( newitem, "B_MUTE" , 0 )
       take = reaper.GetMediaItemTake(newitem,14)
       if take then
       reaper.SetActiveTake(take)
       end
    end
  end
end

---------- Keep Autoscroll ----------------------------------------------
reaper.Main_OnCommand(40036,0) -- toggle auto scroll view during playback
reaper.Main_OnCommand(40036,0) -- toggle auto scroll view during playback

reaper.Undo_EndBlock("Select Take 1",-1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()

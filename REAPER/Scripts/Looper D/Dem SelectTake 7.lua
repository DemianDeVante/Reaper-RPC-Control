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

local threshold = 10^-10
-- Variables -------------------------------------------------------------------------
reaper.Main_OnCommand(40289,0) -- clear item selection
starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)
starttime, endtime = starttime, endtime
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
      item_cursor_pos = next_measure
    else 
      item_cursor_pos = play_cursor_pos
    end
  elseif rplaystate ~=1 then -- if not playing
    item_cursor_pos = edit_cursor_pos
  end
else
  item_cursor_pos = starttime
end

-- Main ------------------------------------------------------------------------------
track_count = reaper.CountSelectedTracks( 0 )
for ntrack = 0, track_count -1 do 
  xtrack = reaper.GetSelectedTrack( 0, ntrack )
  item_count = reaper.CountTrackMediaItems( xtrack )
  local w_count=0
  while w_count < item_count do
    xitem = reaper.GetTrackMediaItem( xtrack, w_count )
     item_pos=reaper.GetMediaItemInfo_Value( xitem, "D_POSITION")
     item_length=reaper.GetMediaItemInfo_Value(xitem, "D_LENGTH")
     if item_pos <= item_cursor_pos+threshold and item_pos+item_length > item_cursor_pos+threshold then
       newitem = reaper.SplitMediaItem( xitem , item_cursor_pos )
       if newitem then
         item_count=item_count+1
       else
         newitem=xitem
       end
       reaper.SetMediaItemInfo_Value( newitem, "B_MUTE" , 0 )
       take = reaper.GetMediaItemTake(newitem,6)
       if take then
       reaper.SetActiveTake(take)
       end
    end
  w_count=w_count+1
  end
end

---------- Keep Autoscroll ----------------------------------------------
reaper.Main_OnCommand(40036,0) -- toggle auto scroll view during playback
reaper.Main_OnCommand(40036,0) -- toggle auto scroll view during playback

reaper.Undo_EndBlock("Select Take 1",-1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()

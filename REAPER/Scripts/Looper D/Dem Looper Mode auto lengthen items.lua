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

function get_item_info()
  item_pos = reaper.GetMediaItemInfo_Value(last_item, 'D_POSITION')
  item_length = reaper.GetMediaItemInfo_Value(last_item, 'D_LENGTH')
  item_end = item_pos + item_length
end

function get_cursor_info()
  play_cursor_pos = reaper.GetPlayPosition()
  beat, measure, cml, fullbeats = reaper.TimeMap2_timeToBeats(0, play_cursor_pos)
  tempo = reaper.Master_GetTempo()
  next_measure = reaper.TimeMap2_beatsToTime(0, 0, measure + 2)
  measure_length = reaper.TimeMap2_beatsToTime(0, 0, 1)
  playstate = reaper.GetPlayState()
end

function lengthen_last_item_track()
  item_count =    reaper.CountTrackMediaItems( xtrack )
  if item_count > 0 then  
    last_item =  reaper.GetTrackMediaItem( xtrack, item_count -1)
    get_item_info()
    new_item_length = next_measure - item_pos
    if item_length ~= new_item_length then
      -- if (playstate == 1 or  playstate == 4) and ( item_end - measure_length )  < play_cursor_pos then -- only lengthen items
      if (playstate == 1 or  playstate == 4) and ( item_pos )  < play_cursor_pos then -- can trim items
        reaper.SetMediaItemInfo_Value( last_item, 'B_LOOPSRC', 1 )
        reaper.SetMediaItemInfo_Value( last_item, 'D_LENGTH', new_item_length )
        reaper.UpdateTimeline()
      end    
    end
  end
end

function DoAtStart()
  _,_,secid,scriptid,_,_,_ = reaper.get_action_context()
  reaper.SetToggleCommandState( secid, scriptid , 1 )
  reaper.RefreshToolbar2( secid, scriptid)
end

function DoAtExit()
  reaper.SetToggleCommandState( secid , scriptid, 0);
  reaper.RefreshToolbar2( secid, scriptid);
end

function tracktag()
    track_count =  reaper.CountTracks( 0 )
    for ntrack = 0, track_count -1 do
      xtrack =  reaper.GetTrack( 0, ntrack )
      trackguid = reaper.GetTrackGUID( xtrack ) -- get track guid
      is_saved_track_color ,saved_track_color = reaper.GetProjExtState( 0, "dem_arm_for_looping" , trackguid ) -- get saved
      if is_saved_track_color == 1 then -- make sure track is tagged
        lengthen_last_item_track()
      end
    end
end

function main()
  get_cursor_info()
  reaper.PreventUIRefresh( 1 )
  tracktag()
  reaper.PreventUIRefresh( -1 )
  reaper.defer(main)
end

DoAtStart()
main()
reaper.atexit(DoAtExit)

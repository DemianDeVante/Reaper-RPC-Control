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

function get_screen_relative_unit()
  local start_time, end_time = reaper.GetSet_ArrangeView2( 0, 0, 0, 1, 0, 0 )
  local unit = end_time - start_time
  return unit
end

function trim_left_destination(item_edge_position) -- returns destination (the final edge position) 
  is_snap = reaper.GetToggleCommandStateEx( 0, 1157 )
  if is_snap == 0 then
    local unit = get_screen_relative_unit()
    return item_edge_position - unit
  else
    local grid_duration
    if reaper.GetToggleCommandState( 41885 ) == 1 then -- Toggle framerate grid
      grid_duration = 0.4/reaper.TimeMap_curFrameRate( 0 )
    else
      local _, division = reaper.GetSetProjectGrid( 0, 0, 0, 0, 0 )
      local tmsgn_cnt = reaper.CountTempoTimeSigMarkers( 0 )
      local _, tempo
      if tmsgn_cnt == 0 then
        tempo = reaper.Master_GetTempo()
      else
        local active_tmsgn = reaper.FindTempoTimeSigMarker( 0, item_edge_position )
        _, _, _, _, tempo = reaper.GetTempoTimeSigMarker( 0, active_tmsgn )
      end
      grid_duration = 60/tempo * division
    end
  local snap = reaper.SnapToGrid(0,item_edge_position)
  local i_snap = snap
  if item_edge_position == 0 then
    i_snap = item_edge_position
  else
    local i_curpos = item_edge_position
    while i_snap >= item_edge_position do
      i_curpos = i_curpos - grid_duration
      i_snap = reaper.SnapToGrid(0,i_curpos)
    end
  end
  return i_snap  
  end
end

function trim_right_destination(item_edge_position) -- returns destination (the final edge position) 
  is_snap = reaper.GetToggleCommandStateEx( 0, 1157 )
  if is_snap == 0 then
    local unit = get_screen_relative_unit()
    return item_edge_position + unit
  else
    local grid_duration
    if reaper.GetToggleCommandState( 41885 ) == 1 then -- Toggle framerate grid
      grid_duration = 0.4/reaper.TimeMap_curFrameRate( 0 )
    else
      local _, division = reaper.GetSetProjectGrid( 0, 0, 0, 0, 0 )
      local tmsgn_cnt = reaper.CountTempoTimeSigMarkers( 0 )
      local _, tempo
      if tmsgn_cnt == 0 then
        tempo = reaper.Master_GetTempo()
      else
        local active_tmsgn = reaper.FindTempoTimeSigMarker( 0, item_edge_position )
        _, _, _, _, tempo = reaper.GetTempoTimeSigMarker( 0, active_tmsgn )
      end
      grid_duration = 60/tempo * division
    end
    local snap = reaper.SnapToGrid(0,item_edge_position)
    local i_snap = snap
    local i_curpos = item_edge_position
    while i_snap <= item_edge_position do
      i_curpos = i_curpos + grid_duration
      i_snap = reaper.SnapToGrid(0,i_curpos)
    end
    return i_snap 
  end
end

reaper.PreventUIRefresh(1)
startcursorpos = reaper.GetCursorPositionEx(0)
loopstart, loopend = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
grid = trim_right_destination(startcursorpos)
  if loopstart ~= startcursorpos and loopend ~= startcursorpos then
    reaper.SetEditCurPos(grid,1,0)
    reaper.GetSet_LoopTimeRange( 1, 0, startcursorpos, grid, 0 ) -- set start on edit cursor and end on next visible grid
  elseif loopstart == startcursorpos then
    reaper.SetEditCurPos(grid,1,0)
    reaper.GetSet_LoopTimeRange( 1, 0, grid, loopend, 0 ) -- set start on edit cursor and end on next visible grid
  elseif loopend == startcursorpos then
    reaper.SetEditCurPos(grid,1,0)
    reaper.GetSet_LoopTimeRange( 1, 0, loopstart , grid, 0 ) -- set start on edit cursor and end on next visible grid
  end
reaper.PreventUIRefresh( -1 )

--reaper.ShowConsoleMsg( "loop start:"..loopstart.."\n".."loop end:"..loopend.."\n".."Cursor"..cursorpos.."\n".."Cursor Start:"..startcursorpos.."\n")
reaper.defer(function() end)

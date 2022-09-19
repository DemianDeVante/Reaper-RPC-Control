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

--========== Functions ==========--
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

function getitemsourceinfo(item) -- returns rate, itemstart, itemlength, sourceoffset, sourcelength
  local itemstart = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
  local itemlength = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
  local itemend = itemstart + itemlength
  local take = reaper.GetActiveTake( item )
  local rate = reaper.GetMediaItemTakeInfo_Value( take, 'D_PLAYRATE' )
  local sourceoffset = reaper.GetMediaItemTakeInfo_Value( take, 'D_STARTOFFS' )
  local source = reaper.GetMediaItemTake_Source( take )
  local sourcelengthraw, isqn = reaper.GetMediaSourceLength( source )
  local sourcelength
  if isqn == true then
    sourcelength = reaper.TimeMap_QNToTime_abs( 0, sourcelengthraw )
  else
    sourcelength = sourcelengthraw
  end
  return rate, itemstart, itemlength, sourceoffset, sourcelength
end

function itemrestoreoffsetandend( item, rate, itemstart, itemlength, sourceoffset, sourcelength, is_loopsrc ) -- returns newsourceoffset, newitemlength 
  local newitemstart = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
  local newitemlength = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
  local itemposdifference = (itemstart-newitemstart)
  reaper.SetMediaItemInfo_Value( item, 'D_LENGTH', newitemlength + itemposdifference ) -- set item end
  local newsourceoffset = (sourceoffset - (itemposdifference * rate)) 
  local take = reaper.GetActiveTake( item )
  if newsourceoffset <= 0 and is_loopsrc then -- set source offset
    newsourceoffset = newsourceoffset + sourcelength
    reaper.SetMediaItemTakeInfo_Value( take, 'D_STARTOFFS', newsourceoffset )
  else
    reaper.SetMediaItemTakeInfo_Value( take, 'D_STARTOFFS', newsourceoffset )
  end
  newitemlength = itemlength + itemposdifference
  return newsourceoffset, newitemlength
end


--========== Trim left edge left ==========--
reaper.PreventUIRefresh(1)


---- Trim Item ----
for nitem = 0, reaper.CountSelectedMediaItems(0) -1 do
  item = reaper.GetSelectedMediaItem(0, nitem)
  is_loopsrc = 1 == reaper.GetMediaItemInfo_Value( item, 'B_LOOPSRC' )
  rate, itemstart, itemlength, sourceoffset, sourcelength = getitemsourceinfo(item)
  final_item_start = trim_right_destination(itemstart)
  reaper.SetMediaItemInfo_Value(item, 'D_POSITION', final_item_start)
  itemrestoreoffsetandend( item, rate, itemstart, itemlength, sourceoffset, sourcelength, is_loopsrc ) 
end
---- Move View ----
local item_count = reaper.CountSelectedMediaItems(0)
if item_count == 0 then return end
local t_start = {}
local t_end = {}
for nitem = 0, item_count -1 do
  local item = reaper.GetSelectedMediaItem(0,nitem)
  local position = reaper.GetMediaItemInfo_Value(item,'D_POSITION')
  local length = reaper.GetMediaItemInfo_Value(item,'D_LENGTH')
  local itemend = position + length
  table.insert(t_start, position)
  table.insert(t_end, itemend)
end
local max_itemend = math.max(table.unpack(t_end))
local min_position = math.min(table.unpack(t_start))
local curpos = reaper.GetCursorPosition()
reaper.SetEditCurPos(min_position, 1, 0)
reaper.SetEditCurPos(curpos, 0, 0)


reaper.PreventUIRefresh(-1)
reaper.defer(function()end)

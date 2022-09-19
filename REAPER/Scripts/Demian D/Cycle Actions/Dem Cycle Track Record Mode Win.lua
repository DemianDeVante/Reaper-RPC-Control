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

function undo_detect(track_count)
  if track_count == 1 then
    local track = reaper.GetSelectedTrack(0,0)
    local track_position = reaper.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')
    local str_track = 'Track '..math.floor(track_position)..' '
    local undo_str = reaper.Undo_CanUndo2(0)
    if undo_str then
      local undo_is_thiscript = string.match(undo_str, str_track..'Record Mode: ')
      if undo_is_thiscript then reaper.Undo_DoUndo2(0) end
    end
  end
end

function isvalintable(table, value) -- returns boolean
  if not table then return false end
  for _, nvalue in pairs(table) do
    if value == nvalue then 
      return true
    end
  end
  return false
end

function iskeyintable(table, key) -- returns boolean
  if not table then return false end
  local isit = table[key]
  if isit then return true else return false end
end
  
function removetable(table) -- returns empty_table
  if not table then return table end
  for key in pairs(table) do
    table[key] = nil
  end
  return table
end

function Message(text)
  -- Open Window --
  gfx.clear = reaper.ColorToNative(37, 37, 37)
  local w, h = 350, 188
  local x, y = reaper.GetMousePosition()
  local l, t, r, b = reaper.my_getViewport(0, 0, 0, 0, x, y, x, y, 1)
  gfx.init(title, w, h, 0, (r + l - w) / 2, (b + t - h) / 2 - 24)
  -----------------
  local time_start = reaper.time_precise()
  local function msg_win()
    time_new = reaper.time_precise()
    if time_new - time_start <= 0.4 then
      -- Draw Text --
      gfx.setfont(1, '', 50, string.byte('b'))
      gfx.set(0.7)
      local t_w, t_h = gfx.measurestr(text)
      gfx.x = math.floor(gfx.w / 2 - t_w / 2 + 4)
      gfx.y = math.floor(gfx.h / 2 - t_h / 2)
      gfx.drawstr(text, 1)
      ---------------
      gfx.update()
      reaper.defer(msg_win)
    else
      gfx.quit()
      done_msg = true
    end
  end
  msg_win()
end


function Main()
  local track = reaper.GetSelectedTrack(0,0)
  if not track then return end
  local rec_mode = reaper.GetMediaTrackInfo_Value(track, 'I_RECMODE')
  local rec_input = reaper.GetMediaTrackInfo_Value(track, 'I_RECINPUT')
  local rec_table
  if rec_input >= 6112 then
    rec_table = {  -- MIDI Table
      {2,'None'},
      {0,'Input'},
      {7,'Overdub'},
      {8,'Replace'},
      {9,'Touch'},
      {16,'Latch'},
      {5,'Out Mono'},
      {1,'Out Stereo'},
      {10,'Out Multichannel'}
    }
  else
    rec_table = {  -- Audio Table
      {2,'None'},
      {0,'Input'},
      {12,'Force Mono'},
      {13,'Force Stereo'},
      {14,'Force MultChan'},
      {6,'Out Mono'},
      {3,'Out Stereo'},
      {11,'Out MultChan'},
      {4,'Out MIDI'}
    }
  end 
  check_table = {}
  for i = 1, 9 do
    table.insert(check_table, rec_table[i][1])
  end
  local text
  if not isvalintable(check_table, rec_mode) then; rec_mode = rec_table[1][1] text = rec_table[1][2]
  elseif rec_mode == rec_table[1][1] then; rec_mode = rec_table[2][1] text = rec_table[2][2]
  elseif rec_mode == rec_table[2][1] then; rec_mode = rec_table[3][1] text = rec_table[3][2]
  elseif rec_mode == rec_table[3][1] then; rec_mode = rec_table[4][1] text = rec_table[4][2]
  elseif rec_mode == rec_table[4][1] then; rec_mode = rec_table[5][1] text = rec_table[5][2]
  elseif rec_mode == rec_table[5][1] then; rec_mode = rec_table[6][1] text = rec_table[6][2]
  elseif rec_mode == rec_table[6][1] then; rec_mode = rec_table[7][1] text = rec_table[7][2]
  elseif rec_mode == rec_table[7][1] then; rec_mode = rec_table[8][1] text = rec_table[8][2]
  elseif rec_mode == rec_table[8][1] then; rec_mode = rec_table[9][1] text = rec_table[9][2]
  elseif rec_mode == rec_table[9][1] then; rec_mode = rec_table[1][1] text = rec_table[1][2]
  end
  local track_count = reaper.CountSelectedTracks(0)
  undo_detect(track_count)
  local str_track 
  reaper.Undo_BeginBlock()
  for i = 0, track_count -1 do
    track = reaper.GetSelectedTrack(0,i)
    reaper.SetMediaTrackInfo_Value(track, 'I_RECMODE', rec_mode)
    if track_count == 1 then
      local track_position = reaper.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')
      str_track = 'Track '..math.floor(track_position)..' '
    end
  end
  if track_count > 1 then str_track = 'Tracks ' end
  reaper.Undo_EndBlock(str_track..'Record Mode: '..text,-1)
  Message(text)
end

function Exit()
  if not done_msg then 
    local track_count = reaper.CountSelectedTracks(0)
    local str_track 
    if track_count == 0 then return end
    undo_detect(track_count)
    reaper.Undo_BeginBlock()
    for i = 0, track_count -1 do
      track = reaper.GetSelectedTrack(0,i)
      reaper.SetMediaTrackInfo_Value(track, 'I_RECMODE', 2)
      if track_count == 1 then
        local track_position = reaper.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')
        str_track = 'Track '..math.floor(track_position)..' '
      end
    end
    if track_count > 1 then str_track = 'Tracks ' end
    reaper.Undo_EndBlock(str_track..'Record Mode: '..'None',-1)
  end
end

Main()
reaper.atexit(Exit)

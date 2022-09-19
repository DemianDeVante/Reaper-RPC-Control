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
  local str_undo, str_msg
  local track = reaper.GetSelectedTrack(0, 0)
  local track_count = reaper.CountSelectedTracks(0) 
  -- freeze or unfreeze based on amount --
  local n_nonfrozen = 0
  local n_frozen = 0
  local dofreeze
  for i = 0, track_count -1 do
    local track = reaper.GetSelectedTrack(0, i)
    local freeze_state = reaper.BR_GetMediaTrackFreezeCount( track )
    if freeze_state == 0 then n_nonfrozen = n_nonfrozen +1 else n_frozen = n_frozen +1 end
  end
  if n_nonfrozen >= n_frozen then dofreeze = true end
  if dofreeze then str_msg = 'FREEZE!!'
  else str_msg = 'UNFREEZE!!' end
  reaper.Undo_BeginBlock()
  -- rename tracks   freeze status --
  local str_freeze = "~F~ "  
  for i = 0, track_count -1 do
    local track = reaper.GetSelectedTrack(0, i)
    local _, track_name = reaper.GetSetMediaTrackInfo_String( track, 'P_NAME', '', 0 )
    if dofreeze then 
      -- append freeze to name --
      local item_count = reaper.CountTrackMediaItems(track)
      if item_count ~= 0 then
        if not string.match(track_name, str_freeze) then
          track_name = str_freeze..track_name
          reaper.GetSetMediaTrackInfo_String( track, 'P_NAME', track_name, 1 ) 
        end
      end
    else 
      -- remove freeze from name --
      if string.match(track_name, str_freeze) then
        track_name = string.gsub(track_name, str_freeze, '')
        reaper.GetSetMediaTrackInfo_String( track, 'P_NAME', track_name, 1 )
      end
    end
  end
  -- freeze actions
  if dofreeze then reaper.Main_OnCommand(41223,0); str_undo = 'Freeze Selected Tracks'-- freeze selected tracks
  else reaper.Main_OnCommand(41644,0); str_undo = 'Unfreeze Selected Tracks' end-- unfreeze selexted tracks
  reaper.Undo_EndBlock(str_undo, -1)
  Message(str_msg)
end

Main()

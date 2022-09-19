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

local item_table={}

-------- FUNCTIONS --------
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

function waitstop() 
  local playstate = reaper.GetPlayState()
  if playstate == 0 then
    forcestop(item_table)
  else
     reaper.defer(waitstop)
  end
end

function forcestop()
  reaper.Main_OnCommand(1016,0) -- stop
  reaper.PreventUIRefresh(1)
  for nitem = 0, reaper.CountMediaItems(0) -1 do
    local item = reaper.GetMediaItem(0,nitem)
    if iskeyintable(item_table, item) then
      reaper.SetMediaItemInfo_Value(item, 'C_MUTE_SOLO', item_table[item])
      reaper.UpdateItemInProject(item)
    end
  end
  local cur_pos = reaper.GetCursorPosition()
  reaper.SetEditCurPos(cur_pos, 1, 0)
  local _,_,secid,scriptid,_,_,_ = reaper.get_action_context()
  reaper.SetToggleCommandState( secid, scriptid , 0 )
  reaper.RefreshToolbar2( secid, scriptid)
  reaper.PreventUIRefresh(-1)
  reaper.defer(function()end)
end


-------- MAIN --------
local _,_,secid,scriptid,_,_,_ = reaper.get_action_context()
reaper.SetToggleCommandState( secid, scriptid , 1 )
reaper.RefreshToolbar2( secid, scriptid)
reaper.PreventUIRefresh(1)
for nitem = 0, reaper.CountMediaItems(0) -1 do
  local item = reaper.GetMediaItem(0,nitem)
  local solo_state = reaper.GetMediaItemInfo_Value(item, 'C_MUTE_SOLO')
  item_table[item]=solo_state
  if reaper.IsMediaItemSelected(item) then
    reaper.SetMediaItemInfo_Value(item, 'C_MUTE_SOLO', -1) 
    reaper.UpdateItemInProject(item)
  else
    reaper.SetMediaItemInfo_Value(item, 'C_MUTE_SOLO', 1)
    reaper.UpdateItemInProject(item)
  end
end
reaper.PreventUIRefresh(-1)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_TIMERTEST1"),0) -- play selected items once
reaper.defer(function()end)
waitstop(item_table)
reaper.atexit(forcestop)

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

function GetTrackInputQuantize(chunk) -- MPL function
    local Q_str = chunk:match('\nINQ(.-)\n')  
    local t = {} for val in Q_str:gmatch('[%d%p]+') do t[#t+1] = tonumber(val) end
    return {enabled = t[1],
              grid = t[4],
              positioning = t[2], -- 0 nearest -1 previous 1 next
              quantize_NoteOffs = t[3],
              strength = t[5],
              swing = t[6],
              quantize_within1 = t[7],
              quantize_within2 = t[8]
            }
end
  
function Main() -- FeedTheCat, McCrabney function
  local proceed_quant_change = false
  local _, grid_val, swingon, grid_swing = reaper.GetSetProjectGrid(0, false)
  grid_val=grid_val*4
  local swing = math.floor(math.abs(grid_swing * 100))
  for i = 0, reaper.CountTracks(0) -1 do
    local track = reaper.GetTrack(0, i)
    local _, chunk = reaper.GetTrackStateChunk(track, '')
    local quant = GetTrackInputQuantize(chunk)
    if quant.enabled ~= 1 or quant.grid ~= grid_val or quant.swing ~= swing then
      proceed_quant_change = true
    end
  end          
  if proceed_quant_change then  
    reaper.Undo_BeginBlock()
    for i = 0, reaper.CountTracks(0) -1 do
      local track = reaper.GetTrack(0, i)
      local _, chunk = reaper.GetTrackStateChunk(track, '')
      local quant = GetTrackInputQuantize(chunk)
      if quant.enabled ~= 1 or quant.grid ~= grid_val or quant.swing ~= swing then
        local pattern = '(\nINQ ).-( .- .- ).-( .- ).-( )' 
        -- .- = enabled, position, noteoffs, grid, strength, swing, within1, within2   
        local repl = '%1'..'1'..'%2'..grid_val..'%3'..swing..'%4'
        chunk = chunk:gsub(pattern, repl, 1) -- 1 to limit the substitutions to 1 and prevent unwanted alterations
        reaper.SetTrackStateChunk(track, chunk)
      end
    end
    reaper.Undo_EndBlock('Quantize Input to Grid',-1) 
  end
  reaper.defer(Main)
end

function Exit()
  -- TURN OFF INPUT QUANTIZE --
  local proceed_quant_change = false
  local _, grid_val, swingon, grid_swing = reaper.GetSetProjectGrid(0, false)
  grid_val=grid_val*4
  local swing = math.floor(math.abs(grid_swing * 100))
  reaper.Undo_BeginBlock()        
  for i = 0, reaper.CountTracks(0) -1 do
    local track = reaper.GetTrack(0, i)
    local _, chunk = reaper.GetTrackStateChunk(track, '')
    local quant = GetTrackInputQuantize(chunk)
    if quant.enabled ~= 0 or quant.grid ~= grid_val or quant.swing ~= swing then
      local pattern = '(\nINQ ).-( .- .- ).-( .- ).-( )' 
      -- .- = enabled, position, noteoffs, grid, strength, swing, within1, within2   
      local repl = '%1'..'0'..'%2'..grid_val..'%3'..swing..'%4'
      chunk = chunk:gsub(pattern, repl, 1) -- 1 to limit the substitutions to 1 and prevent unwanted alterations
      reaper.SetTrackStateChunk(track, chunk)
    end
  end
  reaper.Undo_EndBlock('Turn Off Input Quantize',-1)
  
  -- Turn Off Action --
  local _, _, sec, cmd = reaper.get_action_context()
  reaper.SetToggleCommandState(sec, cmd, 0)
  reaper.RefreshToolbar2(sec, cmd)
end

-- Turn On Action --
local _, _, sec, cmd = reaper.get_action_context()
reaper.SetToggleCommandState(sec, cmd, 1)
reaper.RefreshToolbar2(sec, cmd)

Main()

reaper.atexit(Exit)

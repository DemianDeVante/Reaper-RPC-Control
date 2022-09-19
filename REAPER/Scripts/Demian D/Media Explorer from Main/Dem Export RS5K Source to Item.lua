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

local destinationtrack = reaper.GetSelectedTrack(0,0)
if not destinationtrack then return end
local track_count =  reaper.CountTracks( 0 )
local fxtrack
local fxnumber
local ntrack
for ntrack = 0, track_count -1 do
  local xtrack = reaper.GetTrack( 0, ntrack )
  local track_visiblefx = reaper.TrackFX_GetChainVisible( xtrack )
  if track_visiblefx < -1 then -- if chain visible but no fx selected
    fxnumber = 0
  end
  if track_visiblefx > -1 then -- if chain visible
    fxtrack = xtrack
    fxnumber = track_visiblefx
  end
end
if not fxtrack then return end


local itempos = reaper.GetCursorPosition()

local item = reaper.AddMediaItemToTrack( destinationtrack ) -- add item at cursor
reaper.SetMediaItemInfo_Value(item,'D_POSITION', itempos)
reaper.AddTakeToMediaItem( item ) -- get take
local take = reaper.GetActiveTake(item)
local itemname = ("Note "..tostring(math.floor(reaper.TrackFX_GetParam( fxtrack, fxnumber, 3))).." RS5K Export")  
local _, _ = reaper.GetSetMediaItemTakeInfo_String( take, 'P_NAME', itemname, 1 )
local _, filepath = reaper.TrackFX_GetNamedConfigParm( fxtrack, fxnumber, 'FILE0' )
local source = reaper.PCM_Source_CreateFromFile( filepath ) -- add source to take
reaper.SetMediaItemTake_Source( take, source )
local sourcelength = reaper.GetMediaSourceLength(source)
local startoffset = reaper.TrackFX_GetParam(fxtrack, fxnumber, 13) * sourcelength -- get fx parameters
local itemlength = reaper.TrackFX_GetParam(fxtrack, fxnumber, 14) * sourcelength - startoffset 
local vol = reaper.TrackFX_GetParamNormalized( fxtrack, fxnumber, 0) / 0.5
local pan = reaper.TrackFX_GetParamNormalized( fxtrack, fxnumber, 1) * 2 -1
local pitch = reaper.TrackFX_GetParam( fxtrack, fxnumber, 15) * 160 -80
local fadein = reaper.TrackFX_GetParam( fxtrack, fxnumber, 9) / 0.5
local fadeout = reaper.TrackFX_GetParam( fxtrack, fxnumber, 10) / 0.5
reaper.SetMediaItemTakeInfo_Value(take,'D_STARTOFFS', startoffset) -- set start offset
reaper.SetMediaItemInfo_Value(item,'D_LENGTH', itemlength) -- set item length
reaper.SetMediaItemInfo_Value(item,'D_FADEINLEN', fadein) -- set fade in
reaper.SetMediaItemInfo_Value(item,'D_FADEOUTLEN', fadeout) -- set fade out
reaper.SetMediaItemInfo_Value(item,'D_VOL', vol) -- set volume
reaper.SetMediaItemTakeInfo_Value(take,'D_PITCH', pitch) -- set pitch
reaper.SetMediaItemTakeInfo_Value(take,'D_PAN', pan) -- set pan
reaper.SetMediaItemSelected(item, 1)
reaper.SetEditCurPos(itempos + itemlength, 1, 0)
reaper.UpdateItemInProject( item )
reaper.Main_OnCommand(40441,0) -- build peaks
reaper.UpdateTimeline()

--reaper.ShowConsoleMsg(filepath..",,"..vol..",,"..pitch..",,"..pan..'\n')
reaper.Undo_EndBlock("Export RS5K Source to Item", -1)

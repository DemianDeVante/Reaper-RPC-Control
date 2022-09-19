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

--============ FUNCTIONS =========================================================================================================================--

-- @description Copy focused FX (with automation) to selected tracks
-- @version 0.8
-- @author me2beats
-- @changelog
--  + init

local r = reaper

function GetTrackChunk(track)
  if not track then return end
  local fast_str, track_chunk
  fast_str = r.SNM_CreateFastString("")
  if r.SNM_GetSetObjectState(track, fast_str, false, false) then
    track_chunk = r.SNM_GetFastString(fast_str)
  end
  r.SNM_DeleteFastString(fast_str)  
  return track_chunk
end

function SetTrackChunk(track, track_chunk)
  if not (track and track_chunk) then return end
  local fast_str, ret 
  fast_str = r.SNM_CreateFastString("")
  if r.SNM_SetFastString(fast_str, track_chunk) then
    ret = r.SNM_GetSetObjectState(track, fast_str, true, false)
  end
  r.SNM_DeleteFastString(fast_str)
  return ret
end

-- @ DemianDeVante Functions
function isRS5K(fxnumber,track, take) ---------------------------------------------------- Returns: boolean_isit
  local fxname, isRS5K
  if track and fxnumber > -1 then
    _, fxname = reaper.TrackFX_GetFXName( track, fxnumber )
  elseif take and fxnumber > -1 then
    _, fxname = reaper.TakeFX_GetFXName( take, fxnumber )
  end
  if fxname then isRS5K = fxname:match('RS5K') or fxname:match('ReaSamplOmatic5000') end
  if isRS5K then return true else return false end
end

function exit()
  _,_,secid,scriptid,_,_,_ = reaper.get_action_context()
  reaper.SetToggleCommandState( secid, scriptid , 0 )
  reaper.RefreshToolbar2( secid, scriptid)
end

----- spk77, casrya x-raym, mod: distinguish input and normal fx, accept RS5K instances -----
--[[
 * ReaScript Name: Link selected tracks FX parameter
 * Description: Link selected tracks FX parameter, if they have the same name.
 * Instructions: Select tracks. Run. Terminate once it is done.
 * Screenshot: http://stash.reaper.fm/24908/Link%20FX%20params3.gif
 * Author: spk77
 * Licence: GPL v3
 * Forum Thread:   Scripts: FX Param Values (various)
 * Forum Thread URI: http://forum.cockos.com/showpost.php?p=1562493&postcount=31
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 ( 2015-08-23 )
  + Initial Release
--]]

-- Link FX parameters
-- Lua script by X-Raym, casrya and SPK77 (23-Aug-2015)
local last_param_number = -1
local last_val = -10000000
local param_changed = false

---- param_value_change_count = 0 -- for debugging
---- param_change_count = -1 -- for debugging

function Msg(string)
  reaper.ShowConsoleMsg(tostring(string).."\n")
end

-- http://lua-users.org/wiki/SimpleRound
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function main()
  local ret, track_number, fx_number, param_number = reaper.GetLastTouchedFX()
  if ret then
    local track_id = reaper.CSurf_TrackFromID(track_number, false)
    if track_id ~= nil and reaper.IsTrackSelected(track_id) then
      local val, minvalOut, maxvalOut = reaper.TrackFX_GetParam(track_id, fx_number, param_number)
      local fx_name_ret, fx_name = reaper.TrackFX_GetFXName(track_id, fx_number, "")
      -- convert double to float precision
      val=round(val,7)
      -- Check if parameter has changed
      param_changed = param_number ~= last_param_number or last_val~=val
      -- Run this code only when parameter value has changed
      if param_changed then
        --Msg("last_val: " .. last_val .. ", val: " .. val .. ", last_param_number: " .. last_param_number .. ", param_number: " .. param_number .. ", fx_number: " .. fx_number)
        last_val = val 
        last_param_number = param_number
        for i=1, reaper.CountSelectedTracks(0) do
          local tr = reaper.GetSelectedTrack(0, i-1)
          if fx_number >= 16777216 then fx_mod = 16777216 else fx_mod = 0 end -- mod: allow input fx
          for fx_i = fx_mod, (reaper.TrackFX_GetCount(tr) + fx_mod - 1) do -- loop through FXs on current track
            local dest_fx_name_ret, dest_fx_name = reaper.TrackFX_GetFXName(tr, fx_i, "")
            if (dest_fx_name == fx_name) or (isRS5K(fx_i,tr, _) and isRS5K(fx_number,track_id, _)) then -- mod: link all fx with rs5k in name
              --Msg("FX number: " .. fx_i ..", Setting last_val: " .. last_val .. ", val: " .. val .. ", param_number: " .. param_number)
              reaper.TrackFX_SetParam(tr, fx_i, param_number, val)
              GetTrackChunk( tr ) --<----- prevent undo messing up
              --SetTrackChunk(tr,tr_chunk_dem)   
            end
          end
        end
        ---- param_value_change_count = param_value_change_count + 1 -- for debugging
      end
    end
  end
  reaper.defer(main)
end

--[[ MAIN Alt (non defer, one press only)
function main()
  reaper.Undo_BeginBlock()
  local ret, track_number, fx_number, param_number = reaper.GetLastTouchedFX()
  if ret then
    local track_id = reaper.CSurf_TrackFromID(track_number, false)
    if track_id ~= nil and reaper.IsTrackSelected(track_id) then
      local val, minvalOut, maxvalOut = reaper.TrackFX_GetParam(track_id, fx_number, param_number)
      local fx_name_ret, fx_name = reaper.TrackFX_GetFXName(track_id, fx_number, "")
        for i=1, reaper.CountSelectedTracks(0) do
          local tr = reaper.GetSelectedTrack(0, i-1)
          
          if fx_number >= 16777216 then fx_mod = 16777216 else fx_mod = 0 end -- mod: allow input fx
          for fx_i = fx_mod, (reaper.TrackFX_GetCount(tr) + fx_mod - 1) do -- loop through FXs on current track
            local dest_fx_name_ret, dest_fx_name = reaper.TrackFX_GetFXName(tr, fx_i, "")
            if (dest_fx_name == fx_name) or (isRS5K(fx_i,tr, _) and isRS5K(fx_number,track_id, _)) then -- mod: link all fx with rs5k in name
              --Msg("FX number: " .. fx_i ..", Setting last_val: " .. last_val .. ", val: " .. val .. ", param_number: " .. param_number)
              --reaper.Undo_BeginBlock()
              reaper.TrackFX_SetParam(tr, fx_i, param_number, val)
              tr_chunk_dem = GetTrackChunk( tr )
              SetTrackChunk(tr,tr_chunk_dem)
            end
          end
        end
    end
  end
  reaper.Undo_EndBlock('Link Same FX',-1)  
end
]]--

--============ MAIN ==============================================================================================================================--
_,_,secid,scriptid,_,_,_ = reaper.get_action_context()
reaper.SetToggleCommandState( secid, scriptid , 1 )
reaper.RefreshToolbar2( secid, scriptid)

main()
reaper.atexit(exit)

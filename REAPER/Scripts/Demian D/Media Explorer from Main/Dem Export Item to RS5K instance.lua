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

-- mix of mpl's rs5k functions and feedthecat media explorer functions
function undo_detect()
  local undo_str = reaper.Undo_CanUndo2(0)
  if undo_str then
    local undo_is_thiscript = string.match(undo_str, 'Temp_Track_RS5K_Export')
    if undo_is_thiscript then reaper.Undo_DoUndo2(0) end
  end
end
function undo_prevent()
  reaper.PreventUIRefresh(1)
  -- go to latest undo point --
  repeat
    local can_redo = reaper.Undo_DoRedo2( 0 )
  until( can_redo == 0 )
  -- undo to x undo point --
  repeat
    local undo_str = tostring(reaper.Undo_CanUndo2(0))
    local undo_is_thiscript = undo_str:match('Temp_Track_RS5K_Export')
    if not undo_is_thiscript then reaper.Undo_DoUndo2(0) end
  until(undo_is_thiscript)
  reaper.PreventUIRefresh(-1)
end

  function ExportSelItemsToRs5k_FormMIDItake_data()
    local MIDI = {}
    -- check for same track/get items info
      item = reaper.GetSelectedMediaItem(0,0)
      if not item then return end
      MIDI.it_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
      MIDI.it_end_pos = MIDI.it_pos + 0.1
      proceed_MIDI = true
      it_tr0 = reaper.GetMediaItemTrack( item )
      for i = 1, reaper.CountSelectedMediaItems(0) do
        item = reaper.GetSelectedMediaItem(0,i-1)
        it_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
        it_len = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
        vol = reaper.GetMediaItemInfo_Value( item, 'D_VOL' )
        pan = reaper.GetMediaItemTakeInfo_Value( reaper.GetActiveTake(item), 'D_PAN' )
        pitch = reaper.GetMediaItemTakeInfo_Value( reaper.GetActiveTake(item), 'D_PITCH' )
        MIDI[#MIDI+1] = {pos=it_pos, end_pos = it_pos+it_len}
        MIDI.it_end_pos = it_pos + it_len
        it_tr = reaper.GetMediaItemTrack( item )
        if it_tr ~= it_tr0 then proceed_MIDI = false break end
      end
      
    return proceed_MIDI, MIDI
  end

--[[
  @author Ilias-Timon Poulakis (FeedTheCat)
  @license MIT
  @version 1.0.8
  @provides [main=main,midi_editor,mediaexplorer] .
  @about Links the media explorer file selection, time selection, pitch and
    volume to the focused sample player. The link is automatically broken when
    closing either the FX window or the media explorer.
  @changelog
    - Correctly detect files in databases when file extension is hidden
]]--

-- Avoid creating undo points
reaper.defer(function() end)

-- Check if js_ReaScriptAPI extension is installed
if not reaper.JS_Window_Find then
    reaper.MB('Please install js_ReaScriptAPI extension', 'Error', 0)
    return
end


local _, _, sec, cmd = reaper.get_action_context()

local title = 'Add Sampler'

local jsfx_path
local record_track
local editor_track
local editor_send

local exit_cnt = 0
local min_exit_cnt = 0

local note_lo, note_hi

reaper.gmem_attach('ftc_midi_note_monitor')
-- Note on
reaper.gmem_write(0, -1)
-- Note off
reaper.gmem_write(1, -1)
-- Note on count
reaper.gmem_write(2, 0)
-- Note off count
reaper.gmem_write(3, 0)
-- Current MIDI bus
reaper.gmem_write(3, 0)

-- A simple JSFX that saves information about played MIDI notes in gmem
local jsfx = [[
desc:MIDI note monitor
options:gmem=ftc_midi_note_monitor
slider1:-1<-1,127,1>Note on
slider2:-1<-1,127,1>Note off
@init
ext_midi_bus = 1;
@block
while (midirecv(offset, msg1, msg2, msg3))
(
    mask = msg1 & 0xF0;
    is_note_on = mask == 0x90 && msg2;
    is_note_off = mask == 0x80 || (mask == 0x90 && !msg2);
    is_note_on  ? (gmem[0] = msg2; slider1 = msg2; gmem[2] = gmem[2] + 1);
    is_note_off ? (gmem[1] = msg2; slider2 = msg2; gmem[3] = gmem[3] + 1);
    midisend(offset, msg1, msg2, msg3);
    gmem[4] = midi_bus;
);
]]

function print(msg) reaper.ShowConsoleMsg(tostring(msg) .. '\n') end

function ConcatPath(...)
    local sep = package.config:sub(1, 1)
    return table.concat({...}, sep)
end

function DB2Slider(val)
    return math.exp(val * 0.11512925464970228420089957273422) / 2
end

function Slider2DB(val)
    return math.log(val * 2) * 8.6858896380650365530225783783321
end

function IsAudioFile(file)
    local ext = file:match('%.([^.]+)$')
    if ext and reaper.IsMediaExtension(ext, false) then
        ext = ext:lower()
        if ext ~= 'xml' and ext ~= 'mid' and ext ~= 'rpp' then
            return true
        end
    end
end

function GetSelectedItemAudioFiles()

---------- Get Item Audio ----------------==========================

    -- get info for new midi take
      proceed_MIDI, MIDI = ExportSelItemsToRs5k_FormMIDItake_data()        
    -- export to RS5k
        item = reaper.GetSelectedMediaItem(0,0)
        if not item then return end
        it_len = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
        take = reaper.GetActiveTake(item)
        if not take or reaper.TakeIsMIDI(take) then not_item = 1; return end
        tk_src =  reaper.GetMediaItemTake_Source( take )
        s_offs = reaper.GetMediaItemTakeInfo_Value( take, 'D_STARTOFFS' )
        src_len = reaper.GetMediaSourceLength( tk_src )
        filepath = reaper.GetMediaSourceFileName( tk_src, '' )
        takerate = reaper.GetMediaItemTakeInfo_Value( take, 'D_PLAYRATE' )
        fadein = reaper.GetMediaItemInfo_Value( item, 'D_FADEINLEN' )
        fadeout = reaper.GetMediaItemInfo_Value( item, 'D_FADEOUTLEN' )
        fadein = fadein * takerate
        fadeout = fadeout * takerate
        if filepath == '' then 
          par_src = reaper.GetMediaSourceParent( tk_src )
          filepath = reaper.GetMediaSourceFileName( par_src, '' )
          src_len = reaper.GetMediaSourceLength( tk_src )
        end
        reaper.DeleteTrackMediaItem( reaper.GetMediaItem_Track(item), item )

--------------------------------------------=========================
end

function CreateJSFX()
    -- Determine path to Effects folder
    local res_dir = reaper.GetResourcePath()
    local path = ConcatPath(res_dir, 'Effects', 'ftc_midi_note_monitor.jsfx')

    -- Create new file
    local file = io.open(path, 'w')
    file:write(jsfx)
    file:close()
    return path
end

function CreateHiddenRecordTrack()
    reaper.PreventUIRefresh(-1)
    -- Add track at end of track list (to not change visible track indexes)
    local track_cnt = reaper.CountTracks()
    reaper.InsertTrackAtIndex(track_cnt, false)
    local track = reaper.GetTrack(0, track_cnt)

    -- Hide track in tcp and mixer
    reaper.SetMediaTrackInfo_Value(track, 'B_SHOWINMIXER', 0)
    reaper.SetMediaTrackInfo_Value(track, 'B_SHOWINTCP', 0)

    -- Make it capture MIDI
    reaper.SetMediaTrackInfo_Value(track, 'I_RECARM', 1)
    reaper.SetMediaTrackInfo_Value(track, 'I_RECMODE', 2)
    reaper.SetMediaTrackInfo_Value(track, 'I_RECINPUT', 6112)

    reaper.PreventUIRefresh(-1)
    return track
end

function AddTrackFX(track, fx_name, allow_show, pos, is_rec_fx)
    pos = pos or 0
    is_rec_fx = is_rec_fx or false

    -- FX: Auto-float new FX windows
    local is_auto_float = reaper.GetToggleCommandState(41078) == 1

    -- Follow preference if allow_show is enabled (else hide)
    if not allow_show and is_auto_float then reaper.Main_OnCommand(41078, 0) end
    local instantiate = -1000 - pos
    local fx = reaper.TrackFX_AddByName(track, fx_name, is_rec_fx, instantiate)
    if not allow_show and is_auto_float then reaper.Main_OnCommand(41078, 0) end
    return fx
    
end

function IsSampler(track, fx)
    local _, parm3_name = reaper.TrackFX_GetParamName(track, fx, 3, '')
    local _, parm4_name = reaper.TrackFX_GetParamName(track, fx, 4, '')
    return parm3_name == 'Note range start' and parm4_name == 'Note range end'
end

function GetSamplerNoteRange(track, fx)
    local start_note = reaper.TrackFX_GetParamNormalized(track, fx, 3)
    local end_note = reaper.TrackFX_GetParamNormalized(track, fx, 4)
    return math.floor(start_note * 127 + 0.5), math.floor(end_note * 127 + 0.5)
end

function SetSamplerNoteRange(track, fx, start_note, end_note)
    reaper.TrackFX_SetParamNormalized(track, fx, 3, start_note / 127)
    reaper.TrackFX_SetParamNormalized(track, fx, 4, end_note / 127)
end

function OpenWindow()
    -- Show script window in center of screen
    gfx.clear = reaper.ColorToNative(37, 37, 37)
    local w, h = 350, 188
    local x, y = reaper.GetMousePosition()
    local l, t, r, b = reaper.my_getViewport(0, 0, 0, 0, x, y, x, y, 1)
    gfx.init(title, w, h, 0, (r + l - w) / 2, (b + t - h) / 2 - 24)
end

function DrawGUI()
    -- Determine text
    local text
    if note_lo then
        gfx.setfont(1, '', 26, string.byte('b'))
        if note_lo == note_hi then
            text = ('%d - ?'):format(note_lo)
        else
            text = ('%d - %d'):format(note_lo, note_hi)
        end
    else
        gfx.setfont(1, '', 22, string.byte('b'))
        text = 'Play a note!'
    end

    -- Draw text
    gfx.set(0.7)
    local t_w, t_h = gfx.measurestr(text)
    gfx.x = math.floor(gfx.w / 2 - t_w / 2 + 4)
    gfx.y = math.floor(gfx.h / 2 - t_h / 2)
    gfx.drawstr(text, 1)

    -- Draw circle
    gfx.set(0.5, 0.4, 0.6)
    gfx.circle(gfx.x - t_w - 12, gfx.y + t_h // 2, 5, 1, 1)
end

function Main()
    undo_prevent()
     --end
    item_exists = reaper.GetSelectedMediaItem(0,0)
    if not item_exists then return end
    local note_on = reaper.gmem_read(0)
    local note_off = reaper.gmem_read(1)

    -- Exit script when window closes or escape key is triggered
    local char = gfx.getchar()
    if char == -1 or char == 27 then return end

    -- Exit script when window loses focus
    local has_focus = gfx.getchar(65536) == 7
    if not has_focus and note_on < 0 then exit_cnt = exit_cnt + 1 end
    if exit_cnt > min_exit_cnt and note_on < 0 then return end

    -- Set played note range
    if note_on >= 0 then
        note_lo = math.min(note_lo or note_on, note_on)
        note_hi = math.max(note_hi or note_on, note_on)
    end

    -- Wait for note off, so that user can set a range
    if note_off >= 0 then
        local note_on_cnt = reaper.gmem_read(2)
        local note_off_cnt = reaper.gmem_read(3)

        -- If a note on was found for each note off, add sampler
        if note_on_cnt == note_off_cnt then

            local track = reaper.GetSelectedTrack(0, 0)

            -- When MIDI was received through bus use the MIDI editor track
            local is_midi_bus = reaper.gmem_read(4) == 1
            if is_midi_bus and editor_track then track = editor_track end

            if not track then return end

            undo_detect()
            reaper.Undo_BeginBlock()

            local rec_in = reaper.GetMediaTrackInfo_Value(track, 'I_RECINPUT')
            if rec_in < 6112 then
                reaper.SetMediaTrackInfo_Value(track, 'I_RECINPUT', 6112)
            end

            local rec_mon = reaper.GetMediaTrackInfo_Value(track, 'I_RECMON')
            if rec_mon == 0 then
                reaper.SetMediaTrackInfo_Value(track, 'I_RECMON', 1)
            end

            local chain_pos = 0
            for fx = reaper.TrackFX_GetCount(track) - 1, 0, -1 do
                if IsSampler(track, fx) then
                    local start_note, end_note = GetSamplerNoteRange(track, fx)
                  
                end
            end

            -- Add sampler
            local fx = AddTrackFX(track, 'ReaSamplOmatic5000', true, chain_pos)

            -- Set note range
            SetSamplerNoteRange(track, fx, note_lo, note_hi)

            -- Set mode to "semi tone shifted" if user played a range of notes
            local mode = note_lo == note_hi and 1 or 2
            reaper.TrackFX_SetNamedConfigParm(track, fx, 'MODE', mode)
            if mode == 2 then
                -- Set start pitch to center of range (less sound degradation)
                local center = note_lo + (note_hi - note_lo) // 2
                reaper.TrackFX_SetParamNormalized(track, fx, 5, (80/160))

            end
            
            GetSelectedItemAudioFiles()-- Get Item Audio
            if not_item then return end
            -- Set files
            reaper.TrackFX_SetNamedConfigParm(track, fx, '+FILE0', filepath)
            reaper.TrackFX_SetNamedConfigParm(track, fx, 'DONE', '')
            reaper.TrackFX_SetParamNormalized(track, fx, 0, vol * 0.5 )
            reaper.TrackFX_SetParamNormalized(track, fx, 1, (pan +1 ) / 2 )
            reaper.TrackFX_SetParam(track, fx, 15, (pitch + 80) / 160)
            reaper.TrackFX_SetParam(track, fx, 13, s_offs/src_len)
            reaper.TrackFX_SetParam(track, fx, 14, (s_offs+(it_len*takerate))/src_len)
            -- Other parameters adjust
            reaper.TrackFX_SetParam( track, fx, 9, fadein * 0.5 ) -- attack
            reaper.TrackFX_SetParam( track, fx, 10, fadeout * 0.5 ) -- release
            if mode == 2 then
            reaper.TrackFX_SetParam( track, fx, 11, 1) -- obey note offs 
            reaper.TrackFX_SetParam( track, fx, 8, (10/64) ) -- max voices = 10
            reaper.TrackFX_SetParam( track, fx, 2, 0.070) -- gain for min vel

            else
            reaper.TrackFX_SetParam( track, fx, 11, 0) -- don't obey note offs
            reaper.TrackFX_SetParam( track, fx, 8, 0 ) -- max voices = 0
            reaper.TrackFX_SetParam( track, fx, 2, 0.070) -- gain for min vel
            end


            local range = ('note %d'):format(note_lo)
            if note_lo ~= note_hi then
                range = ('notes %d-%d'):format(note_lo, note_hi)
            end
            reaper.Undo_EndBlock('Add sample player to ' .. range, -1)
            all_succesful = true
            return
        end
    end

    DrawGUI()
    gfx.update()
    reaper.defer(Main)
end

function Exit()
    reaper.SetToggleCommandState(sec, cmd, 0)
    reaper.RefreshToolbar2(sec, cmd)
    --RefreshMXToolbar()
    if reaper.ValidatePtr(editor_track, 'MediaTrack*') then
        reaper.RemoveTrackSend(editor_track, 0, editor_send)
    end
    if reaper.ValidatePtr(record_track, 'MediaTrack*') then
        reaper.DeleteTrack(record_track)
    end
    os.remove(jsfx_path)
    gfx.quit()
    if not all_successful then undo_detect() end
end

reaper.SetToggleCommandState(sec, cmd, 1)
reaper.RefreshToolbar2(sec, cmd)

jsfx_path = CreateJSFX()
reaper.Undo_BeginBlock()
record_track = CreateHiddenRecordTrack()
AddTrackFX(record_track, 'ftc_midi_note_monitor.jsfx')
reaper.Undo_EndBlock('Temp_Track_RS5K_Export',-1)

local hwnd = reaper.MIDIEditor_GetActive()
local take = reaper.MIDIEditor_GetTake(hwnd)

if reaper.ValidatePtr(take, 'MediaItem_Take*') then
    editor_track = reaper.GetMediaItemTake_Track(take)
    editor_send = reaper.CreateTrackSend(editor_track, record_track)
    local SetSendInfoValue = reaper.SetTrackSendInfo_Value
    SetSendInfoValue(editor_track, 0, editor_send, 'I_SENDMODE', 1)
    SetSendInfoValue(editor_track, 0, editor_send, 'I_SRCCHAN', -1)
    -- Set destination track to MIDI bus 2 (to distinguish source)
    SetSendInfoValue(editor_track, 0, editor_send, 'I_MIDIFLAGS', 2 << 22)

    -- When the editor track is not armed there seems to be a latency
    -- until the note on is received (introduced by buffering?)
    -- That's why we don't immediately exit the script on focus loss
    if reaper.GetMediaTrackInfo_Value(editor_track, 'I_RECARM', 1) == 0 then
        min_exit_cnt = 10
    end
end

OpenWindow()
Main()
reaper.atexit(Exit)


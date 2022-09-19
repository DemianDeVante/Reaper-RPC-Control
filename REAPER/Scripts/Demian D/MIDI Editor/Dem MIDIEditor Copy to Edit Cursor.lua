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

reaper.Undo_BeginBlock();
reaper.PreventUIRefresh( 1 )
reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 40010); local undotag = "Copy to Edit Cursor" -- copy

local proj = 0;
--====================================================================
local CMD_UNSELECECT_ALL = 40214;
local CMD_PAST_AT_EDITCURSOR = 40011;
--====================================================================

local CMD_MOVE_NOTE_DOWN                    = 40178; -- Edit: Move notes down one semitone
local CMD_MOVE_NOTE_UP                      = 40177; -- Edit: Move notes up one semitone
local CMD_MOVE_NOTE_DOWN_IGNORE_SCALING_KEY = 41027; -- Edit: Move notes down one semitone ignoring scale/key
local CMD_MOVE_NOTE_UP_IGNORE_SCALING_KEY   = 41026; -- Edit: Move notes up one semitone ignoring scale/key
--====================================================================
local CMD_MOVE_EDITCURSOR_TO_MOUSE          = 40443;
local CMD_MOVE_EDITCURSOR_TO_LEFT_GRID      = 40047; -- Edit: Move edit cursor left by grid
--====================================================================
local undoStr = "kawa MIDI Past To Upper Pitch Cursor";

--====================================================================
local function check_SWS_Function()
    --================================================================
    local out = false
    --================================================================
    out = reaper.APIExists("BR_EnvAlloc")
    --================================================================
    if ( out == false )
    then
        reaper.ShowMessageBox(  "This Scripts Need SWS/S&M Extenstion. \n"
                             .. "\n"
                             .. "Please Check  www.sws-extension.org ."
                             ,  "stop", 0)
    end
    --================================================================
    return out
end 
--====================================================================
local function getBasePitchNumberInSelectedNote(midiItemTake_)
    --================================================================
    local bassPitch = nil;
    --================================================================
    local isOk
        , selected
        , muted
        , startppqpos
        , endppqpos
        , chan
        , pitch
        , vel = reaper.MIDI_GetNote( midiItemTake_ , 0); --first note
    --================================================================
    
    --================================================================
    local count =0;
    --================================================================
    while ( isOk )
    do
          isOk
        , selected
        , muted
        , startppqpos
        , endppqpos
        , chan
        , pitch
        , vel = reaper.MIDI_GetNote( midiItemTake_ , count)
        --============================================================
        if ( selected == true)-- selected only
        then
            bassPitch = math.min( bassPitch or pitch , pitch )
        end
        --============================================================
        count = count+1;
    end
    --================================================================
    return bassPitch or 1
end
--====================================================================
local function getOnMousePitch() -- get Raw Pitch Number
    --================================================================
    local out_OnMousePitchNum = 1;
    --================================================================
    local windowOut 
        , segmentOut
        , detailsOut = reaper.BR_GetMouseCursorContext()
    --================================================================
    
    if (      windowOut  == "midi_editor"
        and ( segmentOut == "piano" or segmentOut == "notes" )
        -- and detailsOut == ""
       )
    then
        --============================================================
        local  retval          
             , inlineEditorOut -- bool
             , noteRowOut      -- nonUse in ccLane
             , ccLaneOut       -- on Mouse CClane
             , ccLaneValOut    -- cc value
             , ccLaneIdOut     -- cc lane position idx
             = reaper.BR_GetMouseCursorContext_MIDI()
        --============================================================
        out_OnMousePitchNum = noteRowOut;
    end
    --================================================================
    return out_OnMousePitchNum;
end
--====================================================================
local function getIsSnapOn(midiEditorHwnd_)
    return ( reaper.MIDIEditor_GetSetting_int( midiEditorHwnd_ , "snap_enabled") == 1.0) -- return true or false
end
--====================================================================
local function getPitchCursorNumber(midiEditorHwnd_)
    return ( reaper.MIDIEditor_GetSetting_int( midiEditorHwnd_ , "active_note_row") ) -- return number
end
--====================================================================

--====================================================================
local function moveEditCursorToMouse(midiEditorHwnd_)
    --================================================================
    if ( getIsSnapOn(midiEditorHwnd_) == true )
    then
        -- need snap
        --============================================================
        --reaper.MIDIEditor_OnCommand(midiEditorHwnd_, CMD_MOVE_EDITCURSOR_TO_MOUSE);
        --reaper.MIDIEditor_OnCommand(midiEditorHwnd_, CMD_MOVE_EDITCURSOR_TO_LEFT_GRID);
        --============================================================
    else
        -- nothing snap
        --reaper.MIDIEditor_OnCommand(midiEditorHwnd_, CMD_MOVE_EDITCURSOR_TO_MOUSE);
    end
    --================================================================
end
--====================================================================

--====================================================================
-- main
--====================================================================
local midiEditorHwnd = reaper.MIDIEditor_GetActive();

--====================================================================
if (    midiEditorHwnd ~= nil
    and reaper.MIDIEditor_GetTake( midiEditorHwnd ) ~= nil 
    and check_SWS_Function() == true )
then

    
    local midiEditorTake = reaper.MIDIEditor_GetTake(midiEditorHwnd);
    --================================================================
    
    -- move Edit cursol 
    moveEditCursorToMouse(midiEditorHwnd); 
    --================================================================
    reaper.MIDIEditor_OnCommand(midiEditorHwnd, CMD_UNSELECECT_ALL);     -- unselect all on Midi Editor
    reaper.MIDIEditor_OnCommand(midiEditorHwnd, CMD_PAST_AT_EDITCURSOR); -- past to edit Cursol
    --================================================================
    
    local bassPitch = getBasePitchNumberInSelectedNote( midiEditorTake );
    local pitchCursorNumber = getPitchCursorNumber(midiEditorHwnd)
    local distancePitch = pitchCursorNumber - bassPitch;
    --================================================================
    local targetCmd = CMD_MOVE_NOTE_DOWN_IGNORE_SCALING_KEY
    --================================================================
    if ( distancePitch > 0) 
    then
        targetCmd = CMD_MOVE_NOTE_UP_IGNORE_SCALING_KEY
    end
    --================================================================
    
    --================================================================
    for i=0 , math.abs(distancePitch) -1
    do
        reaper.MIDIEditor_OnCommand(midiEditorHwnd, targetCmd);
    end
    --================================================================

    -- reaper.UpdateArrange();
end
--====================================================================


reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 40440) -- move cursor to start of items
reaper.PreventUIRefresh( -1 )
reaper.Undo_EndBlock("Copy to Edit Cursor", -1);

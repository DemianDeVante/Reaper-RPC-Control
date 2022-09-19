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

-- You can learn more about Lua scripting in:
-- https://www.admiralbumblebee.com/music/2018/09/22/Reascript-Tutorial.html

------- DEMIAN D SYNTAX FOR CYCLE ACTION STEPS ---------------------------------------------------------------------


-- Change "CyclactionX" with the name you want

-- Add as many stages as you want "reaper.SetExtState('CyclactionX', 'sstage', Y, false)"

-- The "Y" in "reaper.SetExtState('CyclactionX', 'sstage', Y, false)" should be the stage number +1

-- In the last stage "Y" should be 1

local stagedefault = 1

stage = tonumber(reaper.GetExtState('CyclactionX', 'sstage')) or stagedefault


if stage == 1 then

  -- here write what you want to do on step 1

  reaper.SetExtState('CyclactionX', 'sstage', 2, false)

end

if stage == 2 then

  -- here write what you want to do on step 2

  reaper.SetExtState('CyclactionX', 'sstage', 1, false)

end



------- DEMIAN D SYNTAX FOR CYCLE ACTION CONDITIONAL IF ------------------------------------------------------------


-- Replace ActionX with the name you want to give the action

-- Replace SectionID with depending on wich Section is the action: 

-- 0 = Main, 100 = Main (alt recording), 32060 = MIDI Editor, 32061 = MIDI Event List Editor, 32062 = MIDI Inline Editor, 32063 = Media Explorer

-- Replace ActionID with the ActionID you can copy from the action list

-- Replace State with the State you want to give the action, 0 = Off, 1 = On

-- Replace Z with the ActionID of any action you want to send

-- If you want to send a non stock action (sws action or a script):

-- Replace ActionY with the name you want to give the action, it can be the same as ActionString if you want

-- Replace ActionString with the ActionID of the Action you can copy from the action list


ActionX = reaper.GetToggleCommandStateEx( SectionID, ActionID )

if ActionX == State then

  reaper.SetToggleCommandState( SectionID, ActionID, State )

  reaper.Main_OnCommand(Z,0)


else -- If the toggle state is other than the stated before

  -- If you want to send a non stock action (sws action or a script):

  -- Replace ActionY with the name you want to give the action, it can be the same as ActionString if you want

  -- Replace ActionString with the ActionID of the Action you can copy from the action list

  ActionY = reaper.NamedCommandLookup("ActionString")
  reaper.Main_OnCommand(ActionY,0)

end

-- Simplified Action:   reaper.Main_OnCommand(reaper.NamedCommandLookup("ActionID"),0)

-- For Midi Editor Actions: 

-- hwnd = reaper.MIDIEditor_GetActive()
-- reaper.MIDIEditor_OnCommand(hwnd, reaper.NamedCommandLookup("ActionID")) 
















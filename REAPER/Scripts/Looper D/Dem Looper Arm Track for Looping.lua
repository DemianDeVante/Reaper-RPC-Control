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
 track_count = reaper.CountSelectedTracks( 0 )
 for track_n = 0, track_count -1 do
   track = reaper.GetSelectedTrack( 0, track_n ) -- get selected tracks second is trackid (position)
   _,name = reaper.GetSetMediaTrackInfo_String(track,'P_NAME','',0)
   ismarked = name:match('^®')
   --trackguid = reaper.GetTrackGUID( track ) -- get track guid
   --current_track_color = reaper.GetMediaTrackInfo_Value( track, 'I_CUSTOMCOLOR' ) -- get current track color
   --is_saved_track_color ,saved_track_color = reaper.GetProjExtState( 0, "dem_arm_for_looping" , trackguid )-- get saved track color
   if ismarked then
   --if is_saved_track_color ~= 1 then
     reaper.GetSetMediaTrackInfo_String(track,'P_NAME',name:gsub('^®',''),1)          
     --reaper.SetProjExtState( 0, "dem_arm_for_looping", trackguid , current_track_color ) -- save track color
     --reaper.SetMediaTrackInfo_Value( track, 'I_CUSTOMCOLOR', 32800832.0 )-- change color to blue
   else  -- if color saved
     reaper.GetSetMediaTrackInfo_String(track,'P_NAME','®'..name,1)     
     --reaper.SetMediaTrackInfo_Value( track, 'I_CUSTOMCOLOR', saved_track_color ) -- restore color
     --reaper.SetProjExtState( 0, "dem_arm_for_looping", trackguid, "" ) -- delete saved color
   end
 end
reaper.Undo_EndBlock("Toggle Track Looping", -1)



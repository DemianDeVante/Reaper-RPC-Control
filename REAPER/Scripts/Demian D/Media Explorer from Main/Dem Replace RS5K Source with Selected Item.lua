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

-- Avoid creating undo points
reaper.defer(function() end)

function DB2Slider(val)
    return math.exp(val * 0.11512925464970228420089957273422) / 2
end


function GetSelectedItemAudioFiles()
    -- get info for new midi take
      proceed_MIDI, MIDI = ExportSelItemsToRs5k_FormMIDItake_data()        
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
      if fadein < 0 then fadein = 0 end
      if fadeout < 0 then fadeout = 0 end
      if filepath == '' then 
        par_src = reaper.GetMediaSourceParent( tk_src )
        filepath = reaper.GetMediaSourceFileName( par_src, '' )
        src_len = reaper.GetMediaSourceLength( tk_src )
      end
      reaper.DeleteTrackMediaItem( reaper.GetMediaItem_Track(item), item )
end

function Main()

            local track = reaper.GetSelectedTrack(0, 0)
            if not track then return end

            reaper.Undo_BeginBlock()

            -- Add sampler
            visiblefxchain = reaper.TrackFX_GetChainVisible( track )
            if visiblefxchain > -1 then
              fx = visiblefxchain
            else
              return
            end

            GetSelectedItemAudioFiles()-- Get Item Audio
            if not_item then return end
            if not filepath then return end
            reaper.TrackFX_SetNamedConfigParm(track, fx, 'FILE0', filepath)
            reaper.TrackFX_SetNamedConfigParm(track, fx, 'DONE', '')
            reaper.TrackFX_SetParamNormalized(track, fx, 0, vol * 0.5 )
            reaper.TrackFX_SetParam(track, fx, 15, (pitch + 80) / 160)
            reaper.TrackFX_SetParamNormalized(track, fx, 1, (pan +1 ) / 2 )

            reaper.TrackFX_SetParam(track, fx, 13, s_offs/src_len)
            reaper.TrackFX_SetParam(track, fx, 14, (s_offs+(it_len*takerate))/src_len)
            reaper.TrackFX_SetParam( track, fx, 9, fadein * 0.5 ) -- attack
            reaper.TrackFX_SetParam( track, fx, 10, fadeout * 0.5 ) -- release

            reaper.Undo_EndBlock('Replace RS5K Source', -1)

end

Main()

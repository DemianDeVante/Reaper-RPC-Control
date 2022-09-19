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

---------- Global Variables -----------------------------------------------------
local rec_mididub_table ={
      ['Overdub'] =7,
      ['Replace'] =8,
      ['Touch']   =9,
      ['Latch']   =16
}
local rec_mode_table = {
      ['normal']    =40252,
      ['itempunch'] =40253,
      ['timepunch'] =40076
}
local saved_recmode
for _, mode in pairs(rec_mode_table) do
  if reaper.GetToggleCommandStateEx(0,mode) == 1 then
    saved_recmode = mode
  end
end
local _,_,sec_id,cmd_id = reaper.get_action_context()
local starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

---------- Functions ------------------------------------------------------------
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

function update_autoscroll()
  reaper.Main_OnCommand(40036,0) -- toggle auto scroll view during playback
  reaper.Main_OnCommand(40036,0) -- toggle auto scroll view during playback
end

function trim_loopend(xtrack)
  local item_count = reaper.CountTrackMediaItems( xtrack )
  for nitem = 0 , item_count -1 do
    local xitem = reaper.GetTrackMediaItem( xtrack, nitem )
    local item_pos = reaper.GetMediaItemInfo_Value( xitem, 'D_POSITION' )
    local item_length = reaper.GetMediaItemInfo_Value( xitem, 'D_LENGTH' )
    local item_end = item_pos + item_length
    if ( item_pos < endtime and item_end > endtime ) then
      reaper.SetMediaItemInfo_Value( xitem, 'D_LENGTH', endtime - item_pos )
    end
  end
end

function record_overdub()
  local starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  if starttime ~= endtime then  
    local track_count = reaper.CountTracks( 0 )
    for ntrack = 0 , track_count -1 do
      local xtrack = reaper.GetTrack( 0 , ntrack )    
      local is_armed =  reaper.GetMediaTrackInfo_Value( xtrack , 'I_RECARM' )
      local rec_mode =  reaper.GetMediaTrackInfo_Value( xtrack, 'I_RECMODE' )
      local rec_input = reaper.GetMediaTrackInfo_Value(xtrack, 'I_RECINPUT')
      --------- Midi Overdub or Replace -----------
      if is_armed == 1 and (isvalintable(rec_mididub_table, rec_mode)) then
        ---------- Split Items on Time Selection Start -------------------
        local item_count = reaper.CountTrackMediaItems( xtrack )
        local i = 0
        while i < item_count do
          local xitem = reaper.GetTrackMediaItem( xtrack, i )
          local item_pos = reaper.GetMediaItemInfo_Value( xitem, 'D_POSITION' )
          local item_length = reaper.GetMediaItemInfo_Value( xitem, 'D_LENGTH' )
          local item_end = item_pos + item_length
          if ( item_pos < starttime and item_end > starttime ) then
            local done_split = reaper.SplitMediaItem( xitem, starttime ) 
            if done_split then item_count = item_count +1 end
          end
          i = i+1
        end      
        ---------- Duplicate Take -----------------
        item_count = reaper.CountTrackMediaItems( xtrack )
        for nitem = 0 , item_count -1 do
          local xitem = reaper.GetTrackMediaItem( xtrack, nitem )
          local item_pos = reaper.GetMediaItemInfo_Value( xitem, 'D_POSITION' )
          local item_length = reaper.GetMediaItemInfo_Value( xitem, 'D_LENGTH' )
          local item_end = item_pos + item_length
          if ( item_pos < endtime and item_end > starttime ) then
            local take = reaper.GetActiveTake( xitem )
            local it_info_table = {
              ['D_STARTOFFS']=0, 
              ['D_VOL']=0, 
              ['D_PAN']=0, 
              ['D_PANLAW']=0, 
              ['D_PLAYRATE']=0, 
              ['D_PITCH']=0, 
              ['B_PPITCH']=0, 
              ['I_CHANMODE']=0, 
              ['I_PITCHMODE']=0, 
              }
            for attribute,_ in pairs(it_info_table) do  
              it_info_table[attribute] = reaper.GetMediaItemTakeInfo_Value( take, attribute )
            end
            local source = reaper.GetMediaItemTake_Source( take )
            local newtake = reaper.AddTakeToMediaItem( xitem ) 
            reaper.SetMediaItemTake_Source( newtake , source )
            for attribute, value in pairs(it_info_table) do 
              reaper.SetMediaItemTakeInfo_Value( newtake, attribute, value )
            end
            reaper.SetActiveTake( newtake )
            reaper.SetMediaItemInfo_Value( xitem, 'B_LOOPSRC', 1 )
            reaper.SetMediaItemInfo_Value( xitem, 'B_MUTE' , 0 )
            -- reaper.SetMediaItemSelected( xitem, 1 )  ----------------------------- SET DUBBED ITEMS SELECTED
            reaper.UpdateItemInProject( xitem )
          end
        end
      end
    end
  end
end

function record_normal()
  local starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  if starttime ~= endtime then
    local track_count = reaper.CountTracks( 0 )
    for ntrack = 0 , track_count -1 do
      xtrack = reaper.GetTrack( 0 , ntrack )    
      local is_armed =  reaper.GetMediaTrackInfo_Value( xtrack , 'I_RECARM' )
      local rec_mode =  reaper.GetMediaTrackInfo_Value( xtrack, 'I_RECMODE' )
      local rec_input = reaper.GetMediaTrackInfo_Value(xtrack, 'I_RECINPUT')
      if is_armed then trim_loopend(xtrack) end
      ---------- Overdub Loop Source --------------
      if is_armed == 1 and (isvalintable(rec_mididub_table, rec_mode)) then
        for i = 0, reaper.CountTrackMediaItems( xtrack ) -1 do
          local xitem = reaper.GetTrackMediaItem( xtrack, i )
          local item_pos = reaper.GetMediaItemInfo_Value( xitem, 'D_POSITION' )
          local item_length = reaper.GetMediaItemInfo_Value( xitem, 'D_LENGTH' )
          local item_end = item_pos + item_length
          if ( item_pos < endtime and item_end > starttime ) then
            reaper.SetMediaItemInfo_Value( xitem, 'B_LOOPSRC', 1 )
            reaper.SetMediaItemSelected(xitem, 1)
          end
        end
      end
      ---------- Normal Record --------------------
      if is_armed == 1 and (not isvalintable(rec_mididub_table, rec_mode)) then
        local is_itemintimesel
        local source_table = {}
        local item_table = {}
        ---------- Split Items on Time Selection Start and Loop Source-------------------
        local item_count = reaper.CountTrackMediaItems( xtrack )
        local i = 0
        while i < item_count do
          local xitem = reaper.GetTrackMediaItem( xtrack, i )
          local item_pos = reaper.GetMediaItemInfo_Value( xitem, 'D_POSITION' )
          local item_length = reaper.GetMediaItemInfo_Value( xitem, 'D_LENGTH' )
          local item_end = item_pos + item_length
          if ( item_pos < endtime and item_end > starttime ) then
            reaper.SetMediaItemInfo_Value( xitem, 'B_LOOPSRC', 1 )
            if not reaper.IsMediaItemSelected(xitem) then is_itemintimesel = true end -- check if items in time selection
          end
          if ( item_pos < starttime and item_end > starttime ) then  -- split
            if not reaper.IsMediaItemSelected(xitem) then 
              local done_split = reaper.SplitMediaItem( xitem, starttime ) 
              if done_split then item_count = item_count +1 end
            end
          end
          i = i+1
        end
        if is_itemintimesel then
          ---------- Save Previous Take Source -----------------------------
          item_count = reaper.CountTrackMediaItems( xtrack )
          for nitem = 0, item_count -1 do
            local xitem = reaper.GetTrackMediaItem( xtrack, nitem )
            local is_selected = reaper.IsMediaItemSelected(xitem)
            if is_selected then
              local take = reaper.GetMediaItemTake(xitem, 0)
              local source = reaper.GetMediaItemTake_Source(take)
              table.insert(source_table, source)
              table.insert(item_table, xitem)
            end
          end
          ---------- Add Saved Source to Item ------------------------------
          local item_count = reaper.CountTrackMediaItems( xtrack )
          for nitem = 0 , item_count -1 do
            local xitem = reaper.GetTrackMediaItem( xtrack, nitem )
            local item_pos = reaper.GetMediaItemInfo_Value( xitem, 'D_POSITION' )
            local item_length = reaper.GetMediaItemInfo_Value( xitem, 'D_LENGTH' )
            local item_end = item_pos + item_length
            if ( item_pos < endtime and item_end > starttime ) and not isvalintable(item_table, xitem) then
              for _, source in ipairs(source_table) do
                local newtake = reaper.AddTakeToMediaItem( xitem ) 
                reaper.SetMediaItemTake_Source(newtake, source)
                reaper.SetActiveTake( newtake )
              end
              reaper.SetMediaItemInfo_Value( xitem, 'B_LOOPSRC', 1 )
              reaper.SetMediaItemInfo_Value( xitem, 'B_MUTE' , 0 )
              reaper.SetMediaItemSelected( xitem, 1 )
              reaper.UpdateItemInProject( xitem )
            end
          end
          ---------- Delete Recorded Items ---------------------------------
          for _, item in ipairs(item_table) do
            reaper.DeleteTrackMediaItem(xtrack, item)
          end
        end
      end
    end
  end
end

function check_recording()
  local rplaystate = reaper.GetPlayStateEx( 0 )
  if rplaystate == 5 then
    reaper.defer(check_recording)
  end
end

function stop_recording()
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  local rplaystate = reaper.GetPlayStateEx( 0 )
  if rplaystate == 5 then
    reaper.Main_OnCommand(1013,0) -- record
  end
  reaper.Main_OnCommand(40126,0) -- switch to previous take
  reaper.Main_OnCommand(40131,0) -- crop to active take
  reaper.Main_OnCommand(40547,0) -- loop section of audio item source
  record_normal()
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock('Record: Loop',-1)
  update_autoscroll()
  reaper.Main_OnCommand(saved_recmode,0) -- restore record mode
  reaper.SetToggleCommandState(sec_id, cmd_id, 0)
end

---------- Main -----------------------------------------------------------------
local rplaystate = reaper.GetPlayStateEx( 0 )
if rplaystate ~= 5 then ---------------------------- If not recording Start Record
  reaper.SetToggleCommandState(sec_id, cmd_id, 1)
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)  
  reaper.SetEditCurPos2( 0, starttime, true, false )
  reaper.Main_OnCommand(40076,0)  -- set to auto punch mode
  record_overdub()
  reaper.Main_OnCommand(1013,0) -- record
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock('Record: Loop',-1)
  update_autoscroll()
else
  stop_recording()
  return
end

check_recording()
reaper.atexit(stop_recording)

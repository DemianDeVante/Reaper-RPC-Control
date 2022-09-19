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

  --[[
  table structure:
  saved_items={                                                     // items array
    [item]={                            <-- selected items id       // item info table
      ["position"]=itposition,          <-- selected items position
      ["end"]=itend,                    <-- selected items end
      ["left"]={                                                    // adjacent left items array
        [sitem]=sitend                  <-- adjacent left items end  
        }, 
      ["right"]={                                                   // adjacent right items array
        [sitem]=sitposition             <-- adjacent right items position
        }
    }
  }
  ]]--
--==================== Functions ====================--
function settogglestate(secid, commandid, state) -- returns prev_toggle_state
  local rtoggle = reaper.GetToggleCommandState(commandid)
  if rtoggle ~= state then
    reaper.Main_OnCommand(commandid,secid)
  end
  return rtoggle
end

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

function saveallintable() -- returns saved_table_allitems
  local saved_items = {}
  local itemcount = reaper.CountMediaItems(0)
  for nitem = 0, itemcount -1 do
    local item = reaper.GetMediaItem(0,nitem)
    saved_items[item]=true
  end
  return saved_items
end
    
function saveintables(saved_items) -- returns saved_table
  saved_items = {}
  local itemcount = reaper.CountSelectedMediaItems(0)
  for nitem = 0, itemcount -1 do
    local item = reaper.GetSelectedMediaItem(0, nitem)
    local itposition = reaper.GetMediaItemInfo_Value( item,'D_POSITION' )
    local itlength = reaper.GetMediaItemInfo_Value( item,'D_LENGTH' )
    local itend = itposition + itlength;
    saved_items[item]={["position"]=itposition,["end"]= itend,["left"]={},["right"]={}}
    local track = reaper.GetMediaItemTrack(item)
    local itemcount = reaper.CountTrackMediaItems(track)
      --== adjacent items ==--
    for nitem = 0, itemcount -1 do
      local sitem = reaper.GetTrackMediaItem(track, nitem)
      local sitposition = reaper.GetMediaItemInfo_Value( sitem,'D_POSITION' )
      local sitlength = reaper.GetMediaItemInfo_Value( sitem,'D_LENGTH' )
      local sitend = sitposition + sitlength
      -- if item adjacent left, save end --
      if sitend >= (itposition) and sitposition <= itposition and sitem ~= item then
        saved_items[item]["left"][sitem]=sitend 
      -- if item adjacent right, save start --
      elseif sitposition <= (itend) and sitend >= itend and sitem ~= item then
        saved_items[item]["right"][sitem]=sitposition
      end
    end
  end
  return saved_items 
end

function selection_remains(saved_items) -- returns boolean_selection_remains, boolean_edges_remain
  if not saved_items then return false, false end
  local boolean_edges_remain = true
  local boolean_sideitems_remain = true
  local compare_table = saveintables()
  for alt_item, alt_item_table in pairs(compare_table) do
    if not iskeyintable(saved_items, alt_item) then return false, false end
    local saved_position = saved_items[alt_item]["position"]
    local saved_end = saved_items[alt_item]["end"]
    local saved_left = saved_items[alt_item]["left"]
    local saved_right = saved_items[alt_item]["right"]
    if alt_item_table["position"] ~=  saved_position then boolean_edges_remain = false end
    if alt_item_table["end"] ~=  saved_end then boolean_edges_remain = false end
    for alt_sitem, alt_sedge in pairs(alt_item_table["left"]) do
      if not iskeyintable(saved_left, alt_sitem) then boolean_edges_remain = false end
      if not isvalintable(saved_left, alt_sedge) then boolean_edges_remain = false end
    end
    for alt_sitem, alt_sedge in pairs(alt_item_table["right"]) do
      if not iskeyintable(saved_right, alt_sitem) then boolean_edges_remain = false end
      if not isvalintable(saved_right, alt_sedge) then boolean_edges_remain = false end
    end
  end
  return true, boolean_edges_remain 
end

function trimitems(saved_items) -- returns boolean_done
  if not saved_items then return false end
  local done_trim
  for item,item_table in pairs(saved_items) do
    local itposition = item_table["position"]
    local itend = item_table["end"]
    local list_allitems = saveallintable()
    if not iskeyintable(list_allitems, item) then return false end
    local new_itposition = reaper.GetMediaItemInfo_Value( item,'D_POSITION' )
    local new_itend = new_itposition + reaper.GetMediaItemInfo_Value( item,'D_LENGTH' )
    -- trim adjacent left items -- 
    for sitem, sitend in pairs(item_table["left"]) do
      if not iskeyintable(list_allitems, sitem) then return false end
      if sitend ~= new_itposition then 
        local sitposition = reaper.GetMediaItemInfo_Value(sitem, 'D_POSITION')
        if (new_itposition) <= sitposition then
          reaper.DeleteTrackMediaItem(reaper.GetMediaItemTrack(sitem),sitem)
        else
          reaper.SetMediaItemInfo_Value(sitem,'D_LENGTH',new_itposition - sitposition )
        end
        done_trim = true
      end
    end
    -- trim adjacent right items --
    for sitem, sitposition in pairs(item_table["right"]) do
      if not iskeyintable(list_allitems, sitem) then return false end
      if sitposition ~= new_itend then
        local rate, itemstart, itemlength, sourceoffset, sourcelength = getitemsourceinfo(sitem)
        if new_itend >= (itemstart+itemlength) then
          reaper.DeleteTrackMediaItem(reaper.GetMediaItemTrack(sitem),sitem)
        else
          reaper.SetMediaItemInfo_Value( sitem, 'D_POSITION', new_itend)
          newsourceoffset, newitemlength = itemrestoreoffsetandend(sitem, rate, itemstart, itemlength, sourceoffset, sourcelength)
        end
      end
    end
  end
  return true
end

function getitemsourceinfo(item) -- returns rate, itemstart, itemlength, sourceoffset, sourcelength
  local itemstart = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
  local itemlength = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
  local itemend = itemstart + itemlength
  local take = reaper.GetActiveTake( item )
  local rate = reaper.GetMediaItemTakeInfo_Value( take, 'D_PLAYRATE' )
  local sourceoffset = reaper.GetMediaItemTakeInfo_Value( take, 'D_STARTOFFS' )
  local source = reaper.GetMediaItemTake_Source( take )
  local sourcelengthraw, isqn = reaper.GetMediaSourceLength( source )
  local sourcelength
  if isqn == true then
    sourcelength = reaper.TimeMap_QNToTime_abs( 0, sourcelengthraw )
  else
    sourcelength = sourcelengthraw
  end
  return rate, itemstart, itemlength, sourceoffset, sourcelength
end

function itemrestoreoffsetandend( item, rate, itemstart, itemlength, sourceoffset, sourcelength ) -- returns newsourceoffset, newitemlength 
  local newitemstart = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
  local newitemlength = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
  local itemposdifference = (itemstart-newitemstart)
  reaper.SetMediaItemInfo_Value( item, 'D_LENGTH', newitemlength + itemposdifference ) -- set item end
  local newsourceoffset = (sourceoffset - (itemposdifference * rate)) 
  local take = reaper.GetActiveTake( item )
  if newsourceoffset <= 0 then -- set source offset
    newsourceoffset = newsourceoffset + sourcelength
    reaper.SetMediaItemTakeInfo_Value( take, 'D_STARTOFFS', newsourceoffset )
  else
    reaper.SetMediaItemTakeInfo_Value( take, 'D_STARTOFFS', newsourceoffset )
  end
  newitemlength = itemlength + itemposdifference
  return newsourceoffset, newitemlength
end
 
function exit()
  settogglestate(0,41117,rtoggle)
  settogglestate(0,40041,rxfadetoggle)
  reaper.SetToggleCommandState( secid , scriptid, 0);
  reaper.RefreshToolbar2( secid, scriptid);
end

function main()
  local b_selection_remains, b_edges_remain = selection_remains(saved_items)
  if not b_selection_remains then
    cleared_saved_items = removetable(saved_items)
    saved_items = saveintables(cleared_saved_items)
  elseif b_selection_remains and not b_edges_remain then
    done_trim = trimitems(saved_items)
    cleared_saved_items = removetable(saved_items)
    saved_items = saveintables(cleared_saved_items)
  end
  reaper.defer(main)
end

--==================== CALL FUNCTIONS ====================--
rtoggle = settogglestate(0,41117,0) -- prevent stock trim conflict
rxfadetoggle = settogglestate(0,40041,0) -- prevent xfade

reaper.get_action_context()
_,_,secid,scriptid,_,_,_ = reaper.get_action_context()
reaper.SetToggleCommandState( secid, scriptid , 1 )
reaper.RefreshToolbar2( secid, scriptid)

main()
reaper.atexit(exit)
  


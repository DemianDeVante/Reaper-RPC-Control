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

function get_screen_relative_unit()
  local start_time, end_time = reaper.GetSet_ArrangeView2( 0, 0, 0, 1, 0, 0 )
  local unit = end_time - start_time
  return unit
end
local unit = get_screen_relative_unit()

reaper.PreventUIRefresh(1)
item_count = reaper.CountSelectedMediaItems( 0 )

for nitem = 0, item_count -1 do

  item = reaper.GetSelectedMediaItem( 0, nitem )
  reaper.SetMediaItemInfo_Value( item, 'D_FADEINLEN_AUTO', -1 )
  reaper.SetMediaItemInfo_Value( item, 'D_FADEOUTLEN_AUTO', -1 )
  fadein = reaper.GetMediaItemInfo_Value( item, 'D_FADEINLEN' )
  fadeout = reaper.GetMediaItemInfo_Value( item, 'D_FADEOUTLEN' )

  reaper.SetMediaItemInfo_Value( item, 'D_FADEINLEN', fadein - unit )

  item_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
  item_length = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
  item_end = item_pos + item_length
  
  fadein = reaper.GetMediaItemInfo_Value( item, 'D_FADEINLEN' )
  fadeout = reaper.GetMediaItemInfo_Value( item, 'D_FADEOUTLEN' )
  
  if fadein < 0 then; reaper.SetMediaItemInfo_Value( item, 'D_FADEINLEN', 0 ); end;
  if fadeout < 0 then; reaper.SetMediaItemInfo_Value( item, 'D_FADEOUTLEN', 0 ); end;

  if fadein > item_length then; reaper.SetMediaItemInfo_Value( item, 'D_FADEINLEN', item_length ); end;
  if fadeout > item_length then; reaper.SetMediaItemInfo_Value( item, 'D_FADEOUTLEN', item_length ); end;

  reaper.UpdateItemInProject( item )

end

---- Move View ----
local item_count = reaper.CountSelectedMediaItems(0)
if item_count == 0 then return end
local t_start = {}
local t_end = {}
for nitem = 0, item_count -1 do
  local item = reaper.GetSelectedMediaItem(0,nitem)
  local position = reaper.GetMediaItemInfo_Value(item,'D_POSITION')
  local length = reaper.GetMediaItemInfo_Value(item,'D_LENGTH')
  local itemend = position + length
  table.insert(t_start, position)
  table.insert(t_end, itemend)
end
local max_itemend = math.max(table.unpack(t_end))
local min_position = math.min(table.unpack(t_start))
local curpos = reaper.GetCursorPosition()
reaper.SetEditCurPos(min_position, 1, 0)
reaper.SetEditCurPos(curpos, 0, 0)
reaper.PreventUIRefresh(-1)  
reaper.defer(function() end)




  

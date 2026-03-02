package realmeditor.editor
{
   import realmeditor.editor.actions.MapDragAction;
   import realmeditor.editor.actions.data.MapSelectData;
   import realmeditor.editor.ui.MapView;
   import realmeditor.editor.ui.TileMapView;
   
   public class MapDragController
   {
       
      
      private var mapView:MapView;
      
      public var lastDragAction:MapDragAction;
      
      public function MapDragController(mapView:MapView)
      {
         super();
         this.mapView = mapView;
      }
      
      public function reset() : void
      {
         this.mapView.setLastDragAction(null);
      }
      
      public function dragSelection(startX:int, startY:int, endX:int, endY:int) : MapDragAction
      {
         var prevSelection:MapSelectData = this.mapView.selection.clone();
         var firstMove:* = this.lastDragAction == null;
         var newTiles:Vector.<MapTileData> = this.getSelectedTiles();
         if(firstMove)
         {
            this.clearTileArea(prevSelection.startX,prevSelection.startY,prevSelection.endX,prevSelection.endY);
         }
         else
         {
            this.pasteTiles(this.lastDragAction.oldTiles,prevSelection.startX,prevSelection.startY,prevSelection.endX,prevSelection.endY);
         }
         this.mapView.selectTileArea(startX,startY,endX,endY);
         var oldTiles:Vector.<MapTileData> = this.getSelectedTiles();
         this.pasteTiles(newTiles,startX,startY,endX,endY);
         var lastDragAction:MapDragAction = null;
         if(this.lastDragAction != null)
         {
            this.lastDragAction.userNewTiles = newTiles;
            lastDragAction = this.lastDragAction;
         }
         var action:MapDragAction = new MapDragAction(this,lastDragAction,oldTiles,newTiles,prevSelection,this.mapView.selection.clone());
         this.mapView.setLastDragAction(action);
         return action;
      }
      
      public function pasteTiles(tileDict:Vector.<MapTileData>, startX:int, startY:int, endX:int, endY:int) : void
      {
         var y:* = 0;
         var x:* = 0;
         var newTile:MapTileData = null;
         var idx:int = 0;
         var tileMap:TileMapView = this.mapView.tileMap;
         for(y = startY; y <= endY; )
         {
            for(x = startX; x <= endX; )
            {
               newTile = tileDict[idx].clone();
               tileMap.setTileData(x,y,newTile);
               tileMap.drawTile(x,y);
               idx++;
               x++;
            }
            y++;
         }
      }
      
      private function getSelectedTiles() : Vector.<MapTileData>
      {
         var y:int = 0;
         var x:int = 0;
         var tile:MapTileData = null;
         var idx:int = 0;
         var tileMap:TileMapView = this.mapView.tileMap;
         var tileDict:Vector.<MapTileData> = new Vector.<MapTileData>();
         for(y = this.mapView.selection.startY; y <= this.mapView.selection.endY; )
         {
            for(x = this.mapView.selection.startX; x <= this.mapView.selection.endX; )
            {
               tile = tileMap.getTileData(x,y);
               tileDict[idx] = tile.clone();
               idx++;
               x++;
            }
            y++;
         }
         return tileDict;
      }
      
      public function clearTileArea(startX:int, startY:int, endX:int, endY:int) : void
      {
         var y:* = 0;
         var x:* = 0;
         var tileMap:TileMapView = this.mapView.tileMap;
         for(y = startY; y <= endY; )
         {
            for(x = startX; x <= endX; )
            {
               tileMap.clearTile(x,y);
               x++;
            }
            y++;
         }
      }
   }
}

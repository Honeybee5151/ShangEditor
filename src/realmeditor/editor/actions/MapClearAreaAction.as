package realmeditor.editor.actions
{
   import realmeditor.editor.MapTileData;
   import realmeditor.editor.ui.MainView;
   import realmeditor.editor.ui.TileMapView;
   
   public class MapClearAreaAction extends MapAction
   {
       
      
      private var tileDict:Vector.<MapTileData>;
      
      private var startX:int;
      
      private var startY:int;
      
      private var endX:int;
      
      private var endY:int;
      
      public function MapClearAreaAction(tileDict:Vector.<MapTileData>, startX:int, startY:int, endX:int, endY:int)
      {
         super();
         this.tileDict = tileDict;
         this.startX = startX;
         this.startY = startY;
         this.endX = endX;
         this.endY = endY;
      }
      
      override public function doAction() : void
      {
         var y:* = 0;
         var x:* = 0;
         var startX:int = this.startX;
         var startY:int = this.startY;
         var endX:int = this.endX;
         var endY:int = this.endY;
         var tileMap:TileMapView = MainView.Instance.mapView.tileMap;
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
      
      override public function undoAction() : void
      {
         var y:* = 0;
         var x:* = 0;
         var startX:int = this.startX;
         var startY:int = this.startY;
         var endX:int = this.endX;
         var endY:int = this.endY;
         var idx:int = 0;
         var tileMap:TileMapView = MainView.Instance.mapView.tileMap;
         for(y = startY; y <= endY; )
         {
            for(x = startX; x <= endX; )
            {
               tileMap.setTileData(x,y,this.tileDict[idx]);
               tileMap.drawTile(x,y);
               idx++;
               x++;
            }
            y++;
         }
      }
      
      override public function clone() : MapAction
      {
         return new MapClearAreaAction(this.tileDict,this.startX,this.startY,this.endX,this.endY);
      }
   }
}

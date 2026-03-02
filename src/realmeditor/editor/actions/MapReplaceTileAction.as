package realmeditor.editor.actions
{
   import realmeditor.editor.MapTileData;
   import realmeditor.editor.ui.MainView;
   import realmeditor.editor.ui.MapView;
   
   public class MapReplaceTileAction extends MapAction
   {
       
      
      private var mapX:int;
      
      private var mapY:int;
      
      private var prevTileData:MapTileData;
      
      private var newTileData:MapTileData;
      
      public function MapReplaceTileAction(mapX:int, mapY:int, prevTileData:MapTileData, newTileData:MapTileData)
      {
         super();
         this.mapX = mapX;
         this.mapY = mapY;
         this.prevTileData = prevTileData;
         this.newTileData = newTileData;
      }
      
      override public function doAction() : void
      {
         var mapView:MapView = MainView.Instance.mapView;
         mapView.tileMap.setTileData(this.mapX,this.mapY,this.newTileData);
         mapView.tileMap.drawTile(this.mapX,this.mapY);
      }
      
      override public function undoAction() : void
      {
         var mapView:MapView = MainView.Instance.mapView;
         mapView.tileMap.setTileData(this.mapX,this.mapY,this.prevTileData);
         mapView.tileMap.drawTile(this.mapX,this.mapY);
      }
      
      override public function clone() : MapAction
      {
         return new MapReplaceTileAction(this.mapX,this.mapY,this.prevTileData,this.newTileData);
      }
   }
}

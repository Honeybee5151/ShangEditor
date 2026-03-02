package realmeditor.editor.tools
{
   import realmeditor.editor.MEBrush;
   import realmeditor.editor.MapHistory;
   import realmeditor.editor.MapTileData;
   import realmeditor.editor.actions.MapActionSet;
   import realmeditor.editor.actions.MapReplaceTileAction;
   import realmeditor.editor.ui.MainView;
   import realmeditor.editor.ui.TileMapView;
   import realmeditor.util.IntPoint;
   
   public class MEPencilTool extends METool
   {
       
      
      public function MEPencilTool(view:MainView)
      {
         super(1,view);
      }
      
      override public function init(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         this.mainView.mapView.moveBrushOverlay(tilePos.x_,tilePos.y_,this.mainView.userBrush,false,true);
      }
      
      override public function mouseDrag(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         this.usePencil(tilePos,history);
      }
      
      override public function tileClick(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         this.usePencil(tilePos,history);
      }
      
      override public function mouseMoved(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         this.mainView.mapView.moveBrushOverlay(tilePos.x_,tilePos.y_,this.mainView.userBrush);
      }
      
      private function usePencil(tilePos:IntPoint, history:MapHistory) : void
      {
         var y:int = 0;
         var x:int = 0;
         var dx:int = 0;
         var dy:int = 0;
         var distSq:int = 0;
         if(!this.mainView.mapView.isInsideSelection(tilePos.x_,tilePos.y_))
         {
            return;
         }
         var brush:MEBrush = this.mainView.userBrush;
         var mapX:int = tilePos.x_;
         var mapY:int = tilePos.y_;
         var action:MapReplaceTileAction = null;
         if(brush.size == 0)
         {
            action = this.paintTile(mapX,mapY);
            if(action != null)
            {
               history.record(action);
            }
            return;
         }
         var actions:MapActionSet = new MapActionSet();
         var brushRadius:int = (1 + brush.size * 2) / 2;
         for(y = mapY - brushRadius; y <= mapY + brushRadius; )
         {
            for(x = mapX - brushRadius; x <= mapX + brushRadius; )
            {
               dx = x - mapX;
               dy = y - mapY;
               distSq = dx * dx + dy * dy;
               if(!(distSq > brush.size * brush.size || !this.mainView.mapView.isInsideSelection(x,y)))
               {
                  action = this.paintTile(x,y);
                  if(action != null)
                  {
                     actions.push(action);
                  }
               }
               x++;
            }
            y++;
         }
         history.recordSet(actions);
      }
      
      private function paintTile(mapX:int, mapY:int) : MapReplaceTileAction
      {
         var brush:MEBrush = this.mainView.userBrush;
         var tileMap:TileMapView = this.mainView.mapView.tileMap;
         var prevData:MapTileData;
         if((prevData = tileMap.getTileData(mapX,mapY)) == null)
         {
            return null;
         }
         prevData = prevData.clone();
         switch(brush.elementType)
         {
            case 0:
               if(brush.groundType == -1 || prevData.groundType == brush.groundType)
               {
                  return null;
               }
               tileMap.setTileGround(mapX,mapY,brush.groundType);
               break;
            case 1:
               if(brush.objType == 0 || prevData.objType == brush.objType)
               {
                  return null;
               }
               tileMap.setTileObject(mapX,mapY,brush.objType);
               break;
            case 2:
               if(brush.regType == 0 || prevData.regType == brush.regType)
               {
                  return null;
               }
               tileMap.setTileRegion(mapX,mapY,brush.regType);
               break;
         }
         tileMap.drawTile(mapX,mapY);
         return new MapReplaceTileAction(mapX,mapY,prevData,tileMap.getTileData(mapX,mapY).clone());
      }
   }
}

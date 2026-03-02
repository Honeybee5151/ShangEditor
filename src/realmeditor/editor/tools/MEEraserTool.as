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
   
   public class MEEraserTool extends METool
   {
       
      
      public function MEEraserTool(view:MainView)
      {
         super(6,view);
      }
      
      override public function init(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         this.mainView.mapView.moveBrushOverlay(tilePos.x_,tilePos.y_,this.mainView.userBrush,true,true);
      }
      
      override public function mouseDrag(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         this.useEraser(tilePos,history);
      }
      
      override public function tileClick(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         this.useEraser(tilePos,history);
      }
      
      override public function mouseMoved(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         this.mainView.mapView.moveBrushOverlay(tilePos.x_,tilePos.y_,this.mainView.userBrush,true);
      }
      
      private function useEraser(tilePos:IntPoint, history:MapHistory) : void
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
            action = this.eraseTile(mapX,mapY);
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
                  action = this.eraseTile(x,y);
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
      
      private function eraseTile(mapX:int, mapY:int) : MapReplaceTileAction
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
               if(prevData.groundType == -1)
               {
                  return null;
               }
               tileMap.clearGround(mapX,mapY);
               break;
            case 1:
               if(prevData.objType == 0)
               {
                  return null;
               }
               tileMap.clearObject(mapX,mapY);
               break;
            case 2:
               if(prevData.regType == 0)
               {
                  return null;
               }
               tileMap.clearRegion(mapX,mapY);
               break;
         }
         return new MapReplaceTileAction(mapX,mapY,prevData,tileMap.getTileData(mapX,mapY).clone());
      }
   }
}

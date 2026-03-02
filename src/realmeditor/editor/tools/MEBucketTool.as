package realmeditor.editor.tools
{
   import realmeditor.editor.MEBrush;
   import realmeditor.editor.MapData;
   import realmeditor.editor.MapHistory;
   import realmeditor.editor.MapTileData;
   import realmeditor.editor.actions.MapActionSet;
   import realmeditor.editor.actions.MapReplaceTileAction;
   import realmeditor.editor.ui.MainView;
   import realmeditor.editor.ui.TileMapView;
   import realmeditor.util.IntPoint;
   
   public class MEBucketTool extends METool
   {
       
      
      public function MEBucketTool(view:MainView)
      {
         super(4,view);
      }
      
      override public function init(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         this.mainView.mapView.highlightTile(tilePos.x_,tilePos.y_);
      }
      
      override public function mouseMoved(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         this.mainView.mapView.highlightTile(tilePos.x_,tilePos.y_);
      }
      
      override public function tileClick(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         if(this.mainView.mapView.isInsideSelection(tilePos.x_,tilePos.y_))
         {
            this.doFill(tilePos,history);
         }
      }
      
      override public function mouseDragEnd(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         if(this.mainView.mapView.isInsideSelection(tilePos.x_,tilePos.y_))
         {
            this.doFill(tilePos,history);
         }
      }
      
      private function doFill(tilePos:IntPoint, history:MapHistory) : void
      {
         var pending:* = undefined;
         var pos:IntPoint = null;
         var actions:MapActionSet = new MapActionSet();
         var continuous:Boolean = this.mainView.inputHandler.ctrlKey;
         var tileMap:TileMapView = this.mainView.mapView.tileMap;
         var origTile:MapTileData = tileMap.getTileData(tilePos.x_,tilePos.y_).clone();
         if(continuous)
         {
            this.continuousFill(origTile,actions);
         }
         else
         {
            pending = new Vector.<IntPoint>();
            pending.push(tilePos);
            while(pending.length != 0)
            {
               pos = pending.pop();
               if(this.mainView.mapView.isInsideSelection(pos.x_,pos.y_))
               {
                  if(this.fillTile(pos.x_,pos.y_,origTile,actions))
                  {
                     pending.push(new IntPoint(pos.x_ + 1,pos.y_));
                     pending.push(new IntPoint(pos.x_ - 1,pos.y_));
                     pending.push(new IntPoint(pos.x_,pos.y_ + 1));
                     pending.push(new IntPoint(pos.x_,pos.y_ - 1));
                  }
               }
            }
         }
         history.recordSet(actions);
      }
      
      private function continuousFill(origTile:MapTileData, actions:MapActionSet) : void
      {
         var yi:int = 0;
         var xi:int = 0;
         var mapData:MapData = this.mainView.mapView.mapData;
         for(yi = 0; yi < mapData.mapHeight; )
         {
            for(xi = 0; xi < mapData.mapWidth; )
            {
               if(this.mainView.mapView.isInsideSelection(xi,yi))
               {
                  this.fillTile(xi,yi,origTile,actions);
               }
               xi++;
            }
            yi++;
         }
      }
      
      private function fillTile(mapX:int, mapY:int, origTile:MapTileData, actions:MapActionSet) : Boolean
      {
         var brush:MEBrush = this.mainView.userBrush;
         var tileMap:TileMapView = this.mainView.mapView.tileMap;
         var prevData:MapTileData;
         if((prevData = tileMap.getTileData(mapX,mapY)) == null)
         {
            return false;
         }
         prevData = prevData.clone();
         switch(brush.elementType)
         {
            case 0:
               if(prevData.groundType != origTile.groundType || prevData.groundType == brush.groundType)
               {
                  return false;
               }
               tileMap.setTileGround(mapX,mapY,brush.groundType);
               break;
            case 1:
               if(prevData.objType != origTile.objType || prevData.objType == brush.objType)
               {
                  return false;
               }
               tileMap.setTileObject(mapX,mapY,brush.objType);
               break;
            case 2:
               if(prevData.regType != origTile.regType || prevData.regType == brush.regType)
               {
                  return false;
               }
               tileMap.setTileRegion(mapX,mapY,brush.regType);
               break;
         }
         tileMap.drawTile(mapX,mapY);
         actions.push(new MapReplaceTileAction(mapX,mapY,prevData,tileMap.getTileData(mapX,mapY).clone()));
         return true;
      }
   }
}

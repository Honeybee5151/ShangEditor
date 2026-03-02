package realmeditor.editor.tools
{
   import realmeditor.editor.MapHistory;
   import realmeditor.editor.MapTileData;
   import realmeditor.editor.ui.MainView;
   import realmeditor.util.IntPoint;
   
   public class MEEditTool extends METool
   {
       
      
      public function MEEditTool(view:MainView)
      {
         super(7,view);
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
         var tileData:MapTileData = this.mainView.mapView.tileMap.getTileData(tilePos.x_,tilePos.y_);
         if(tileData == null || tileData.objType == 0)
         {
            return;
         }
         this.mainView.showEditNameView(tilePos.x_,tilePos.y_,tileData.objCfg);
      }
   }
}

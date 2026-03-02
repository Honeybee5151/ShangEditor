package realmeditor.editor.actions
{
   import realmeditor.editor.MapDragController;
   import realmeditor.editor.MapTileData;
   import realmeditor.editor.actions.data.MapSelectData;
   import realmeditor.editor.ui.MainView;
   
   public class MapDragAction extends MapAction
   {
       
      
      private var controller:MapDragController;
      
      private var prevAction:MapDragAction;
      
      public var oldTiles:Vector.<MapTileData>;
      
      public var newTiles:Vector.<MapTileData>;
      
      public var userNewTiles:Vector.<MapTileData>;
      
      private var prevSelection:MapSelectData;
      
      private var newSelection:MapSelectData;
      
      public function MapDragAction(controller:MapDragController, prevAction:MapDragAction, oldTiles:Vector.<MapTileData>, newTiles:Vector.<MapTileData>, oldSelection:MapSelectData, newSelection:MapSelectData, userNewTiles:Vector.<MapTileData> = null)
      {
         super();
         this.controller = controller;
         this.prevAction = prevAction;
         this.oldTiles = oldTiles;
         this.newTiles = newTiles;
         this.userNewTiles = userNewTiles;
         this.prevSelection = oldSelection;
         this.newSelection = newSelection;
      }
      
      override public function doAction() : void
      {
         this.dragNewTiles(false);
      }
      
      override public function undoAction() : void
      {
         this.controller.pasteTiles(this.oldTiles,this.newSelection.startX,this.newSelection.startY,this.newSelection.endX,this.newSelection.endY);
         if(this.prevAction != null)
         {
            this.prevAction.dragNewTiles(true);
         }
         else
         {
            this.controller.pasteTiles(this.newTiles,this.prevSelection.startX,this.prevSelection.startY,this.prevSelection.endX,this.prevSelection.endY);
            MainView.Instance.mapView.selectTileArea(this.prevSelection.startX,this.prevSelection.startY,this.prevSelection.endX,this.prevSelection.endY);
            MainView.Instance.mapView.setLastDragAction(null);
         }
      }
      
      private function dragNewTiles(userTiles:Boolean) : void
      {
         var tiles:Vector.<MapTileData> = userTiles ? this.userNewTiles : this.newTiles;
         if(this.prevAction == null)
         {
            this.controller.clearTileArea(this.prevSelection.startX,this.prevSelection.startY,this.prevSelection.endX,this.prevSelection.endY);
         }
         else
         {
            this.controller.pasteTiles(this.prevAction.oldTiles,this.prevSelection.startX,this.prevSelection.startY,this.prevSelection.endX,this.prevSelection.endY);
         }
         this.controller.pasteTiles(tiles,this.newSelection.startX,this.newSelection.startY,this.newSelection.endX,this.newSelection.endY);
         MainView.Instance.mapView.selectTileArea(this.newSelection.startX,this.newSelection.startY,this.newSelection.endX,this.newSelection.endY);
         MainView.Instance.mapView.setLastDragAction(this);
      }
      
      override public function clone() : MapAction
      {
         return new MapDragAction(this.controller,this.prevAction,this.oldTiles,this.newTiles,this.prevSelection,this.newSelection,this.userNewTiles);
      }
   }
}

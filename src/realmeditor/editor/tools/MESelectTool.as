package realmeditor.editor.tools
{
   import realmeditor.editor.MapHistory;
   import realmeditor.editor.actions.MapDragAction;
   import realmeditor.editor.actions.MapSelectAction;
   import realmeditor.editor.actions.data.MapSelectData;
   import realmeditor.editor.ui.MainView;
   import realmeditor.util.IntPoint;
   
   public class MESelectTool extends METool
   {
       
      
      private var selectionStart:IntPoint;
      
      private var prevSelection:MapSelectData;
      
      private var draggingSelection:Boolean;
      
      private var lastDragPos:IntPoint;
      
      public function MESelectTool(view:MainView)
      {
         super(0,view);
      }
      
      override public function init(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            return;
         }
         this.mainView.mapView.highlightTile(tilePos.x_,tilePos.y_);
      }
      
      override public function reset() : void
      {
         this.selectionStart = null;
         this.draggingSelection = false;
         this.prevSelection = null;
         this.lastDragPos = null;
      }
      
      override public function mouseDrag(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            this.reset();
            return;
         }
         if(this.selectionStart == null)
         {
            if(this.draggingSelection || this.mainView.mapView.isInsideSelection(tilePos.x_,tilePos.y_,true))
            {
               this.draggingSelection = true;
               this.dragSelectionTo(tilePos.x_,tilePos.y_,history);
               return;
            }
            if(!this.mainView.mapView.isInsideSelection(tilePos.x_,tilePos.y_,true))
            {
               this.draggingSelection = false;
               this.selectionStart = tilePos;
               this.savePreviousSelection();
               this.mainView.mapView.clearTileSelection();
            }
         }
         if(this.selectionStart.x_ != tilePos.x_ || this.selectionStart.y_ != tilePos.y_)
         {
            this.mainView.mapView.selectTileArea(this.selectionStart.x_,this.selectionStart.y_,tilePos.x_,tilePos.y_);
         }
      }
      
      override public function mouseDragEnd(tilePos:IntPoint, history:MapHistory) : void
      {
         if(this.selectionStart == null || tilePos == null)
         {
            this.reset();
            return;
         }
         var currentSelection:MapSelectData = this.mainView.mapView.selection;
         var beginX:int = this.selectionStart.x_ < tilePos.x_ ? this.selectionStart.x_ : tilePos.x_;
         var beginY:int = this.selectionStart.y_ < tilePos.y_ ? this.selectionStart.y_ : tilePos.y_;
         var endX:int = this.selectionStart.x_ < tilePos.x_ ? tilePos.x_ : this.selectionStart.x_;
         var endY:int = this.selectionStart.y_ < tilePos.y_ ? tilePos.y_ : this.selectionStart.y_;
         if(endX == beginX && endY == beginY)
         {
            this.singleSelection(tilePos,history,this.prevSelection.clone());
            return;
         }
         history.record(new MapSelectAction(this.prevSelection.clone(),currentSelection.clone()));
         this.lastDragPos = new IntPoint(beginX,beginY);
         this.reset();
      }
      
      override public function tileClick(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            this.reset();
            return;
         }
         if(this.mainView.mapView.isInsideSelection(tilePos.x_,tilePos.y_,true))
         {
            return;
         }
         this.singleSelection(tilePos,history,this.mainView.mapView.selection.clone());
      }
      
      private function singleSelection(tilePos:IntPoint, history:MapHistory, prevSelection:MapSelectData) : void
      {
         if(prevSelection.startX == -1)
         {
            this.mainView.mapView.selectTileArea(tilePos.x_,tilePos.y_,tilePos.x_,tilePos.y_);
            history.record(new MapSelectAction(prevSelection,this.mainView.mapView.selection.clone()));
         }
         else
         {
            this.mainView.mapView.recordSelectionClear(history);
            this.mainView.mapView.clearTileSelection();
         }
         this.reset();
      }
      
      override public function mouseMoved(tilePos:IntPoint, history:MapHistory) : void
      {
         if(tilePos == null)
         {
            this.reset();
            return;
         }
         this.mainView.mapView.highlightTile(tilePos.x_,tilePos.y_);
      }
      
      public function dragSelectionTo(mapX:int, mapY:int, history:MapHistory) : void
      {
         if(this.lastDragPos == null)
         {
            this.lastDragPos = new IntPoint(mapX,mapY);
         }
         var diffX:int = mapX - this.lastDragPos.x_;
         var diffY:int = mapY - this.lastDragPos.y_;
         this.dragSelection(diffX,diffY,history);
         this.lastDragPos = new IntPoint(mapX,mapY);
      }
      
      public function dragSelection(diffX:int, diffY:int, history:MapHistory) : void
      {
         var selection:MapSelectData = this.mainView.mapView.selection;
         var startX:int = selection.startX;
         var startY:int = selection.startY;
         var beginX:int = startX + diffX;
         var beginY:int = startY + diffY;
         var endX:int = beginX + selection.width - 1;
         var endY:int = beginY + selection.height - 1;
         if(diffX == 0 && diffY == 0 || beginX < 0 || endX >= this.mainView.mapView.mapData.mapWidth || beginY < 0 || endY >= this.mainView.mapView.mapData.mapHeight)
         {
            return;
         }
         var action:MapDragAction = this.mainView.mapView.dragController.dragSelection(beginX,beginY,endX,endY);
         history.record(action);
      }
      
      private function savePreviousSelection() : void
      {
         this.prevSelection = this.mainView.mapView.selection.clone();
      }
   }
}

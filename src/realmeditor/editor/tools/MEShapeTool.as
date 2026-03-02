package realmeditor.editor.tools
{
   import realmeditor.editor.MapHistory;
   import realmeditor.editor.ui.MainView;
   import realmeditor.util.IntPoint;
   
   public class MEShapeTool extends METool
   {
       
      
      public function MEShapeTool(view:MainView)
      {
         super(2,view);
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
   }
}

package realmeditor.editor.actions
{
   import realmeditor.editor.ui.MainView;
   import realmeditor.editor.ui.MapView;
   
   public class MapEditAction extends MapAction
   {
       
      
      private var mapX:int;
      
      private var mapY:int;
      
      private var prevCfg:String;
      
      private var newCfg:String;
      
      public function MapEditAction(mapX:int, mapY:int, prevCfg:String, newCfg:String)
      {
         super();
         this.mapX = mapX;
         this.mapY = mapY;
         this.prevCfg = prevCfg;
         this.newCfg = newCfg;
      }
      
      override public function doAction() : void
      {
         var mapView:MapView = MainView.Instance.mapView;
         mapView.editTileObjCfg(mapX,mapY,this.newCfg);
      }
      
      override public function undoAction() : void
      {
         var mapView:MapView = MainView.Instance.mapView;
         mapView.editTileObjCfg(mapX,mapY,this.prevCfg);
      }
      
      override public function clone() : MapAction
      {
         return new MapEditAction(this.mapX,this.mapY,this.prevCfg,this.newCfg);
      }
   }
}

package realmeditor.editor.ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import realmeditor.assets.GroundLibrary;
   import realmeditor.assets.ObjectLibrary;
   import realmeditor.assets.RegionLibrary;
   import realmeditor.editor.ui.elements.DrawListTooltip;
   
   public class MapDrawElement extends Sprite
   {
       
      
      public var elementType:int;
      
      public var texture:BitmapData;
      
      private var drawType:int;
      
      private var tooltip:DrawListTooltip;
      
      public function MapDrawElement(elementType:int, texture:BitmapData, drawType:int)
      {
         super();
         this.elementType = elementType;
         this.drawType = drawType;
         this.texture = texture;
         addChild(new Bitmap(texture));
         this.addEventListener("rollOver",this.onRollOver);
      }
      
      private function onRollOver(e:Event) : void
      {
         var xml:XML = null;
         this.removeEventListener("rollOver",this.onRollOver);
         switch(this.drawType)
         {
            case 0:
               xml = GroundLibrary.xmlLibrary_[this.elementType];
               break;
            case 1:
               xml = ObjectLibrary.xmlLibrary_[this.elementType];
               break;
            case 2:
               xml = RegionLibrary.xmlLibrary_[this.elementType];
         }
         if(xml == null)
         {
            return;
         }
         this.tooltip = new DrawListTooltip(this,this.texture,xml,this.drawType);
         MainView.Main.stage.addChild(this.tooltip);
      }
   }
}

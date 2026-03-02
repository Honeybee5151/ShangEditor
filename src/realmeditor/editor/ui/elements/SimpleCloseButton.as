package realmeditor.editor.ui.elements
{
   import flash.display.Sprite;
   import flash.events.Event;
   import realmeditor.editor.ui.Constants;
   import realmeditor.util.MoreColorUtil;
   
   public class SimpleCloseButton extends Sprite
   {
       
      
      private var closeText:SimpleText;
      
      public function SimpleCloseButton()
      {
         super();
         this.closeText = new SimpleText(20,16777215);
         this.closeText.setText("Close");
         this.closeText.setBold(true);
         this.closeText.updateMetrics();
         this.closeText.x = 3;
         this.closeText.y = 3;
         this.closeText.filters = Constants.SHADOW_FILTER_1;
         addChild(this.closeText);
         this.addEventListener("rollOver",this.onRollOver);
         this.addEventListener("rollOut",this.onRollOut);
      }
      
      private function onRollOver(e:Event) : void
      {
         this.transform.colorTransform = MoreColorUtil.darkCT;
      }
      
      private function onRollOut(e:Event) : void
      {
         this.transform.colorTransform = MoreColorUtil.identity;
      }
   }
}

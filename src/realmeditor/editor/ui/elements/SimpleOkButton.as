package realmeditor.editor.ui.elements
{
   import flash.display.Sprite;
   import flash.events.Event;
   import realmeditor.editor.ui.Constants;
   import realmeditor.util.MoreColorUtil;
   
   public class SimpleOkButton extends Sprite
   {
       
      
      private var okText:SimpleText;
      
      public function SimpleOkButton()
      {
         super();
         this.okText = new SimpleText(20,16777215);
         this.okText.setText("Ok");
         this.okText.setBold(true);
         this.okText.updateMetrics();
         this.okText.x = 3;
         this.okText.y = 3;
         this.okText.filters = Constants.SHADOW_FILTER_1;
         addChild(this.okText);
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

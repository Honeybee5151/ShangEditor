package realmeditor.editor.ui.elements
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import realmeditor.editor.ui.Constants;
   import realmeditor.util.FilterUtil;
   
   public class SimpleTextButton extends Sprite
   {
       
      
      private var shape:Shape;
      
      private var textField:SimpleText;
      
      public function SimpleTextButton(textStr:String, size:int = 18, color:uint = 16777215)
      {
         super();
         this.shape = new Shape();
         addChild(this.shape);
         this.textField = new SimpleText(size,color);
         this.textField.text = textStr;
         this.textField.filters = Constants.SHADOW_FILTER_1;
         this.textField.updateMetrics();
         addChild(this.textField);
         var shapeW:int = this.width + 10;
         var shapeH:int = this.height + 5;
         var gShape:Graphics = this.shape.graphics;
         gShape.beginFill(8947848,0.8);
         gShape.drawRoundRect(0,0,shapeW,shapeH,5,5);
         gShape.endFill();
         this.textField.x = (this.width - this.textField.width) / 2;
         this.textField.y = (this.height - this.textField.height) / 2;
         filters = Constants.SHADOW_FILTER_1;
         this.addEventListener("rollOver",this.onMouseRollOver);
         this.addEventListener("rollOut",this.onMouseRollOut);
      }
      
      private function onMouseRollOver(e:Event) : void
      {
         this.shape.filters = FilterUtil.GREY_COLOR_FILTER_1;
      }
      
      private function onMouseRollOut(e:Event) : void
      {
         this.shape.filters = null;
      }
   }
}

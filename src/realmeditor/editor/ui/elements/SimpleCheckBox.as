package realmeditor.editor.ui.elements
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import realmeditor.editor.ui.Constants;
   
   public class SimpleCheckBox extends Sprite
   {
      
      private static const CHECKBOX_SIZE:int = 15;
      
      private static const CHECKCROSS_SIZE:int = 10;
       
      
      public var value:Boolean;
      
      private var background:Shape;
      
      private var title:SimpleText;
      
      private var checkBox:Sprite;
      
      private var checkCross:Shape;
      
      public function SimpleCheckBox(title:String, defaultValue:Boolean = false)
      {
         super();
         this.value = defaultValue;
         this.background = new Shape();
         addChild(this.background);
         this.title = new SimpleText(18,16777215);
         this.title.setText(title);
         this.title.filters = Constants.SHADOW_FILTER_1;
         this.title.updateMetrics();
         addChild(this.title);
         this.checkBox = new Sprite();
         var g:Graphics = this.checkBox.graphics;
         g.beginFill(5658198);
         g.drawRoundRect(0,0,15,15,5,5);
         g.endFill();
         addChild(this.checkBox);
         this.checkCross = new Shape();
         this.checkCross.visible = defaultValue;
         g = this.checkCross.graphics;
         g.lineStyle(3,16777215);
         g.lineTo(10,10);
         g.moveTo(10,0);
         g.lineTo(0,10);
         g.lineStyle();
         addChild(this.checkCross);
         this.positionChildren();
         this.drawBackground();
         this.checkBox.addEventListener("click",this.onClick);
      }
      
      public function setValue(value:Boolean) : void
      {
         this.value = value;
         this.checkCross.visible = value;
      }
      
      private function onClick(e:Event) : void
      {
         this.value = !this.value;
         this.checkCross.visible = this.value;
         this.dispatchEvent(new Event("change"));
      }
      
      private function positionChildren() : void
      {
         this.title.x = 0;
         this.title.y = 0;
         this.checkBox.x = this.title.x + this.title.width + 5;
         this.checkBox.y = this.title.y + (this.title.height - this.checkBox.height) / 2;
         this.checkCross.x = this.checkBox.x + 2.5;
         this.checkCross.y = this.checkBox.y + 2.5;
      }
      
      private function drawBackground() : void
      {
         var g:Graphics = this.background.graphics;
         g.beginFill(8947848);
         g.drawRoundRect(0,0,width + 3,height,10,10);
         g.endFill();
      }
   }
}

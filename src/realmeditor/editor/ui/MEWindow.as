package realmeditor.editor.ui
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import realmeditor.editor.ui.elements.SimpleCloseButton;
   import realmeditor.editor.ui.elements.SimpleOkButton;
   import realmeditor.editor.ui.elements.SimpleText;
   
   public class MEWindow extends Sprite
   {
       
      
      protected var background:Shape;
      
      protected var title:SimpleText;
      
      protected var okButton:SimpleOkButton;
      
      protected var closeButton:SimpleCloseButton;
      
      public function MEWindow(title:String)
      {
         super();
         this.background = new Shape();
         addChild(this.background);
         this.title = new SimpleText(20,16777215);
         this.title.setText(title);
         this.title.setBold(true);
         this.title.updateMetrics();
         this.title.filters = Constants.SHADOW_FILTER_1;
         addChild(this.title);
         this.okButton = new SimpleOkButton();
         this.okButton.addEventListener("click",this.onOkClick);
         addChild(this.okButton);
         this.closeButton = new SimpleCloseButton();
         this.closeButton.addEventListener("click",this.onCloseClick);
         addChild(this.closeButton);
         this.addEventListener("addedToStage",this.onAddedToStage);
         filters = Constants.SHADOW_FILTER_1;
      }
      
      protected function onAddedToStage(e:Event) : void
      {
         this.updatePositions();
         this.drawBackground();
      }
      
      protected function drawBackground() : void
      {
         var g:Graphics = this.background.graphics;
         g.clear();
         g.beginFill(5658198);
         g.drawRoundRect(0,0,width + 15,height + 5,10,10);
         g.endFill();
      }
      
      protected function updatePositions() : void
      {
         this.title.x = 5;
         this.okButton.x = 5;
         this.okButton.y = this.title.y + this.title.height + 5;
         this.closeButton.x = this.okButton.x + this.okButton.width + 10;
         this.closeButton.y = this.okButton.y;
      }
      
      protected function onOkClick(e:Event) : void
      {
         e.stopImmediatePropagation();
      }
      
      protected function onCloseClick(e:Event) : void
      {
         e.stopImmediatePropagation();
      }
   }
}

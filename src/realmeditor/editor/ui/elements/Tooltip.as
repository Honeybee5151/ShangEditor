package realmeditor.editor.ui.elements
{
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import realmeditor.editor.ui.MainView;
   
   public class Tooltip extends Sprite
   {
       
      
      private var target:DisplayObject;
      
      private var background:Shape;
      
      public function Tooltip(target:DisplayObject)
      {
         super();
         this.background = new Shape();
         addChild(this.background);
         this.target = target;
         target.addEventListener("rollOut",this.onTargetOut);
         target.addEventListener("rollOver",this.onTargetOver);
         target.addEventListener("enterFrame",this.onEnterFrame);
         this.addChildren();
         this.positionChildren();
         this.drawBackground();
         this.fixPosition();
      }
      
      private function onTargetOver(e:Event) : void
      {
         this.target.addEventListener("rollOut",this.onTargetOut);
         this.target.addEventListener("enterFrame",this.onEnterFrame);
         this.fixPosition();
         this.visible = true;
      }
      
      private function onTargetOut(e:Event) : void
      {
         this.target.removeEventListener("rollOut",this.onTargetOut);
         this.target.removeEventListener("enterFrame",this.onEnterFrame);
         this.visible = false;
      }
      
      private function onEnterFrame(e:Event) : void
      {
         this.fixPosition();
      }
      
      protected function addChildren() : void
      {
      }
      
      protected function positionChildren() : void
      {
      }
      
      protected function drawBackground() : void
      {
         var g:Graphics = this.background.graphics;
         g.clear();
         g.beginFill(5658198,0.8);
         g.drawRoundRect(0,0,width + 10,height + 10,15,15);
         g.endFill();
      }
      
      protected function updateChildren() : void
      {
         this.addChildren();
         this.positionChildren();
         this.drawBackground();
      }
      
      public function fixPosition() : void
      {
         this.x = this.getXPos();
         this.y = this.getYPos();
      }
      
      private function getXPos() : Number
      {
         var mouseX:Number = MainView.Main.stage.mouseX;
         if(mouseX < MainView.StageWidth / 2)
         {
            if(mouseX < 0)
            {
               return 0;
            }
            if(mouseX + width > MainView.StageWidth)
            {
               return MainView.StageWidth - width;
            }
            return mouseX;
         }
         if(mouseX >= MainView.StageWidth / 2)
         {
            if(mouseX > MainView.StageWidth)
            {
               return MainView.StageWidth - width;
            }
            if(mouseX - width < 0)
            {
               return 0;
            }
            return mouseX - width;
         }
         return mouseX;
      }
      
      private function getYPos() : Number
      {
         var mouseY:Number = MainView.Main.stage.mouseY;
         if(mouseY < MainView.StageHeight / 2)
         {
            if(mouseY < 0)
            {
               return 0;
            }
            if(mouseY + height > MainView.StageHeight)
            {
               return MainView.StageHeight - height;
            }
            return mouseY;
         }
         if(mouseY >= MainView.StageHeight / 2)
         {
            if(mouseY > MainView.StageHeight)
            {
               return MainView.StageHeight - height;
            }
            if(mouseY - height < 0)
            {
               return 0;
            }
            return mouseY - height;
         }
         return mouseY;
      }
   }
}

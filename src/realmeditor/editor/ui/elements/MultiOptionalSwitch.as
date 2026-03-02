package realmeditor.editor.ui.elements
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import realmeditor.util.FilterUtil;
   
   public class MultiOptionalSwitch extends Sprite
   {
       
      
      private var background:Shape;
      
      private var options:Vector.<SwitchOption>;
      
      private var nextOptionY:Number;
      
      public var selected:int;
      
      public function MultiOptionalSwitch()
      {
         super();
         this.options = new Vector.<SwitchOption>();
         this.background = new Shape();
         addChild(this.background);
      }
      
      public function addOption(title:String) : void
      {
         var option:SwitchOption = new SwitchOption(title);
         option.x = 2;
         option.y = this.nextOptionY;
         option.filters = this.options.length == 0 ? null : FilterUtil.GREY_COLOR_FILTER_2;
         option.addEventListener("click",this.onOptionClick);
         addChild(option);
         this.nextOptionY = option.y + option.height;
         this.options.push(option);
         this.drawBackground();
      }
      
      private function drawBackground() : void
      {
         var g:Graphics = this.background.graphics;
         g.clear();
         g.beginFill(8947848,0.9);
         g.drawRoundRect(0,0,width + 4,height + 4,5,5);
         g.endFill();
      }
      
      private function onOptionClick(e:Event) : void
      {
         var i:int = 0;
         e.stopImmediatePropagation();
         for(i = 0; i < this.options.length; )
         {
            this.options[i].filters = FilterUtil.GREY_COLOR_FILTER_2;
            i++;
         }
         var option:SwitchOption = e.target as SwitchOption;
         option.filters = null;
         this.selected = this.options.indexOf(option);
         this.dispatchEvent(new Event("OptionSwitch"));
      }
      
      public function selectNext() : void
      {
         var i:int = 0;
         for(i = 0; i < this.options.length; )
         {
            this.options[i].filters = FilterUtil.GREY_COLOR_FILTER_2;
            i++;
         }
         var next:int = this.selected + 1;
         if(next >= this.options.length)
         {
            next = 0;
         }
         var nextOption:SwitchOption = this.options[next];
         nextOption.filters = null;
         this.selected = next;
         this.dispatchEvent(new Event("OptionSwitch"));
      }
   }
}

import flash.display.Sprite;
import realmeditor.editor.ui.Constants;
import realmeditor.editor.ui.elements.SimpleText;

class SwitchOption extends Sprite
{
    
   
   public function SwitchOption(title:String)
   {
      super();
      var text:SimpleText = new SimpleText(16,16777215);
      text.setText(title);
      text.updateMetrics();
      text.filters = Constants.SHADOW_FILTER_1;
      addChild(text);
   }
}

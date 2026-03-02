package realmeditor.editor.ui
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import realmeditor.util.FilterUtil;
   
   public class MapToolbar extends Sprite
   {
      
      private static const ICON_SIZE:int = 20;
      
      private static const ICON_TO_TOOL:Array = [0,1,6,5,4,2,3,7];
       
      
      private var view:MainView;
      
      private var background:Shape;
      
      private var icons:Vector.<ToolIconContainer>;
      
      public function MapToolbar(view:MainView)
      {
         var i:int = 0;
         var container:ToolIconContainer = null;
         super();
         this.view = view;
         this.icons = new Vector.<ToolIconContainer>();
         this.background = new Shape();
         addChild(this.background);
         var iconCount:int = 0;
         for(i = 0; i < 10; )
         {
            if(!(i == 4 || i == 8))
            {
               container = new ToolIconContainer(i);
               container.scaleX = 20 / container.icon.width;
               container.scaleY = 20 / container.icon.height;
               container.x = 5;
               container.y = 6 + iconCount * container.icon.height + 6 * iconCount;
               container.filters = FilterUtil.GREY_COLOR_FILTER_1;
               container.addEventListener("click",this.onIconClick);
               iconCount++;
               addChild(container);
               this.icons.push(container);
            }
            i++;
         }
         this.icons[0].filters = null;
         var g:Graphics = this.background.graphics;
         g.beginFill(5658198,0.8);
         g.drawRoundRect(0,0,width + 10,height + 12,5,5);
         g.endFill();
         filters = Constants.SHADOW_FILTER_1;
      }
      
      private function onIconClick(e:Event) : void
      {
         var i:int = 0;
         e.stopImmediatePropagation();
         var icon:ToolIconContainer = e.target as ToolIconContainer;
         for(i = 0; i < this.icons.length; )
         {
            this.icons[i].filters = FilterUtil.GREY_COLOR_FILTER_1;
            i++;
         }
         icon.filters = null;
         var idx:int = int(this.icons.indexOf(icon));
         this.view.setSelectedTool(ICON_TO_TOOL[idx]);
      }
      
      public function setSelected(toolId:int) : void
      {
         var i:int = 0;
         for(i = 0; i < this.icons.length; )
         {
            this.icons[i].filters = FilterUtil.GREY_COLOR_FILTER_1;
            i++;
         }
         switch(toolId)
         {
            case 0:
               this.icons[0].filters = null;
               break;
            case 1:
               this.icons[1].filters = null;
               break;
            case 2:
               this.icons[5].filters = null;
               break;
            case 3:
               this.icons[6].filters = null;
               break;
            case 4:
               this.icons[4].filters = null;
               break;
            case 5:
               this.icons[3].filters = null;
               break;
            case 6:
               this.icons[2].filters = null;
               break;
            case 7:
               this.icons[7].filters = null;
         }
      }
   }
}

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import realmeditor.assets.AssetLibrary;
import realmeditor.editor.tools.METool;
import realmeditor.editor.ui.MainView;
import realmeditor.editor.ui.elements.TextTooltip;

class ToolIconContainer extends Sprite
{
    
   
   public var icon:Bitmap;
   
   private var toolTextureId:int;
   
   private var tooltip:TextTooltip;
   
   public function ToolIconContainer(toolTextureId:int)
   {
      super();
      this.toolTextureId = toolTextureId;
      this.icon = new Bitmap(AssetLibrary.getImageFromSet("editorTools",toolTextureId));
      addChild(this.icon);
      this.addEventListener("rollOver",this.onRollOver);
   }
   
   private function onRollOver(e:Event) : void
   {
      this.removeEventListener("rollOver",this.onRollOver);
      this.tooltip = new TextTooltip(this,METool.ToolTextureIdToName(this.toolTextureId),18,16777215,true);
      MainView.Main.stage.addChild(this.tooltip);
   }
}

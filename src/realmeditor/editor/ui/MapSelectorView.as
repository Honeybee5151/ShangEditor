package realmeditor.editor.ui
{
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class MapSelectorView extends Sprite
   {
      
      public static const WIDTH:int = 150;
      
      private static const HEIGHT:int = 150;
       
      
      private var background:Shape;
      
      private var mapSlotsContainer:Sprite;
      
      private var mapSlots:Dictionary;
      
      public var selectedMap:int;
      
      public function MapSelectorView()
      {
         super();
         this.mapSlots = new Dictionary();
         this.background = new Shape();
         var g:Graphics = this.background.graphics;
         g.beginFill(5658198,0.8);
         g.drawRoundRect(0,0,150,150,10,10);
         g.endFill();
         addChild(this.background);
         var slotsMask:Shape = new Shape();
         g = slotsMask.graphics;
         g.beginFill(0);
         g.drawRoundRect(0,0,150,150,10,10);
         g.endFill();
         addChild(slotsMask);
         this.mapSlotsContainer = new Sprite();
         this.mapSlotsContainer.mask = slotsMask;
         addChild(this.mapSlotsContainer);
         this.addEventListener("mouseWheel",this.onScroll);
         filters = Constants.SHADOW_FILTER_1;
      }
      
      private function onScroll(e:MouseEvent) : void
      {
         e.stopImmediatePropagation();
         var scroll:Number = e.delta * 10;
         this.mapSlotsContainer.y += scroll;
         if(this.mapSlotsContainer.y > 0)
         {
            this.mapSlotsContainer.y = 0;
         }
         if(this.mapSlotsContainer.height < 150)
         {
            this.mapSlotsContainer.y = 0;
         }
         else if(this.mapSlotsContainer.y < -this.mapSlotsContainer.height + 150)
         {
            this.mapSlotsContainer.y = -this.mapSlotsContainer.height + 150;
         }
      }
      
      public function addMap(mapId:int, name:String) : void
      {
         var slot:MapSelectorSlot = new MapSelectorSlot(mapId,name);
         slot.addEventListener("click",this.onSlotClick);
         this.mapSlotsContainer.addChild(slot);
         this.mapSlots[mapId] = slot;
         this.positionSlots();
      }
      
      public function removeMap(slot:MapSelectorSlot) : void
      {
         slot.removeEventListener("click",this.onSlotClick);
         this.mapSlotsContainer.removeChild(slot);
         delete this.mapSlots[slot.mapId];
         this.positionSlots();
         this.dispatchEvent(new MapClosedEvent("MapClosed",slot.mapId));
      }
      
      private function positionSlots() : void
      {
         var i:int = 0;
         for each(var mapSlot in this.mapSlots)
         {
            mapSlot.y = i * 25 + i * 2;
            i++;
         }
      }
      
      private function onSlotClick(e:Event) : void
      {
         for each(var mapSlot in this.mapSlots)
         {
            mapSlot.setSelected(false);
         }
         var slot:MapSelectorSlot = e.target as MapSelectorSlot;
         slot.setSelected(true);
         this.selectedMap = slot.mapId;
         this.dispatchEvent(new Event("MapSelect"));
      }
      
      public function selectMap(mapId:int) : void
      {
         if(this.mapSlots[mapId] == null)
         {
            return;
         }
         for each(var mapSlot in this.mapSlots)
         {
            mapSlot.setSelected(false);
         }
         this.mapSlots[mapId].setSelected(true);
         this.selectedMap = mapId;
      }
   }
}

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import realmeditor.editor.ui.Constants;
import realmeditor.editor.ui.MainView;
import realmeditor.editor.ui.MapSelectorView;
import realmeditor.editor.ui.MapView;
import realmeditor.editor.ui.elements.SimpleText;
import realmeditor.editor.ui.elements.TextTooltip;
import realmeditor.util.MoreColorUtil;

class MapSelectorSlot extends Sprite
{
   
   private static const WIDTH:int = 150;
   
   public static const HEIGHT:int = 25;
    
   
   public var mapId:int;
   
   private var mapName:String;
   
   private var background:Shape;
   
   private var text:SimpleText;
   
   private var selected:Boolean;
   
   private var cross:Sprite;
   
   private var closeTooltip:TextTooltip;
   
   public function MapSelectorSlot(mapId:int, name:String)
   {
      super();
      this.mapId = mapId;
      this.mapName = name;
      var mapView:MapView = MainView.Instance.mapViewContainer.maps[mapId] as MapView;
      mapView.tileMap.addEventListener("MapChanged",this.onMapChanged);
      mapView.mapData.addEventListener("MapSaved",this.onMapSaved);
      this.background = new Shape();
      addChild(this.background);
      this.text = new SimpleText(16,16777215,false,150);
      this.text.setText(mapId.toString() + ". " + name + (!mapView.mapData.savedChanges ? " *" : ""));
      this.text.updateMetrics();
      this.text.x = 3;
      this.text.filters = Constants.SHADOW_FILTER_1;
      addChild(this.text);
      this.cross = new Sprite();
      this.cross.addEventListener("click",this.onCrossClick);
      addChild(this.cross);
      var g:Graphics = this.background.graphics;
      g.beginFill(8947848);
      g.drawRect(0,0,150,25);
      g.endFill();
      var crossSize:int = 5;
      g = this.cross.graphics;
      g.lineStyle(3,16777215);
      g.lineTo(crossSize,crossSize);
      g.moveTo(crossSize,0);
      g.lineTo(0,crossSize);
      g.lineStyle();
      this.cross.x = 150 - crossSize - 5;
      this.cross.y = (25 - crossSize) / 2;
      this.cross.addEventListener("rollOver",this.onRollOver);
   }
   
   private function onMapChanged(e:Event) : void
   {
      this.text.setText(this.mapId.toString() + ". " + this.mapName + " *");
      this.text.updateMetrics();
   }
   
   private function onMapSaved(e:Event) : void
   {
      this.text.setText(this.mapId.toString() + ". " + this.mapName);
      this.text.updateMetrics();
   }
   
   private function onCrossClick(e:Event) : void
   {
      e.stopImmediatePropagation();
      (parent.parent as MapSelectorView).removeMap(this);
   }
   
   private function onRollOver(e:Event) : void
   {
      if(this.closeTooltip == null)
      {
         this.closeTooltip = new TextTooltip(this.cross,"Close",18,16777215,true);
         this.closeTooltip.addSubText("Save map before closing!");
         MainView.Main.stage.addChild(this.closeTooltip);
      }
   }
   
   public function setSelected(val:Boolean) : void
   {
      this.selected = val;
      this.transform.colorTransform = val ? MoreColorUtil.identity : MoreColorUtil.darkCT;
   }
}

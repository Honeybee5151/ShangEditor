package realmeditor.editor.ui
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import realmeditor.editor.ToolSwitchEvent;
   import realmeditor.editor.tools.METool;
   
   public class MapInputHandler extends EventDispatcher
   {
       
      
      private var view:MainView;
      
      private var dragging:Boolean;
      
      private var middleMouseDragging:Boolean;
      
      private var mouseDown:Boolean;
      
      private var middleMouseDown:Boolean;
      
      public var ctrlKey:Boolean;
      
      public function MapInputHandler(view:MainView)
      {
         super();
         this.view = view;
         MainView.Main.stage.addEventListener("keyUp",this.onKeyUp);
         MainView.Main.stage.addEventListener("keyDown",this.onKeyDown);
         view.mapViewContainer.addEventListener("rollOver",this.onRollOver);
      }
      
      public function clear() : void
      {
         MainView.Main.stage.removeEventListener("keyUp",this.onKeyUp);
         MainView.Main.stage.removeEventListener("keyDown",this.onKeyDown);
         this.onRollOut(null);
      }
      
      private function onRollOver(e:Event) : void
      {
         if(MainView.Instance.testMode)
         {
            return;
         }
         this.view.mapViewContainer.addEventListener("rollOut",this.onRollOut);
         this.view.mapViewContainer.addEventListener("mouseDown",this.onMouseDown);
         this.view.mapViewContainer.addEventListener("mouseUp",this.onMouseUp);
         this.view.mapViewContainer.addEventListener("mouseMove",this.onMouseMoved);
         this.view.mapViewContainer.addEventListener("middleMouseDown",this.onMiddleMouseDown);
         this.view.mapViewContainer.addEventListener("middleMouseUp",this.onMiddleMouseUp);
      }
      
      private function onRollOut(e:Event) : void
      {
         if(MainView.Instance.testMode)
         {
            return;
         }
         if(e != null)
         {
            if(this.dragging)
            {
               this.dispatchEvent(new Event("MouseDragEnd"));
            }
            if(this.middleMouseDragging)
            {
               this.dispatchEvent(new Event("MiddleMouseDragEnd"));
            }
         }
         this.dragging = false;
         this.middleMouseDragging = false;
         this.mouseDown = false;
         this.middleMouseDown = false;
         this.view.mapViewContainer.removeEventListener("rollOut",this.onRollOut);
         this.view.mapViewContainer.removeEventListener("mouseDown",this.onMouseDown);
         this.view.mapViewContainer.removeEventListener("mouseUp",this.onMouseUp);
         this.view.mapViewContainer.removeEventListener("mouseMove",this.onMouseMoved);
         this.view.mapViewContainer.removeEventListener("middleMouseDown",this.onMiddleMouseDown);
         this.view.mapViewContainer.removeEventListener("middleMouseUp",this.onMiddleMouseUp);
         this.view.mapViewContainer.removeEventListener("mouseMove",this.onMouseDrag);
      }
      
      private function onMiddleMouseDown(e:MouseEvent) : void
      {
         if(MainView.Instance.testMode)
         {
            return;
         }
         this.middleMouseDragging = false;
         this.middleMouseDown = true;
         this.view.mapViewContainer.addEventListener("mouseMove",this.onMiddleMouseDrag);
      }
      
      private function onMiddleMouseUp(e:MouseEvent) : void
      {
         if(MainView.Instance.testMode)
         {
            return;
         }
         this.middleMouseDown = false;
         this.view.mapViewContainer.removeEventListener("mouseMove",this.onMiddleMouseDrag);
         if(this.middleMouseDragging)
         {
            this.middleMouseDragging = false;
            this.dispatchEvent(new Event("MiddleMouseDragEnd"));
         }
      }
      
      private function onMiddleMouseDrag(e:MouseEvent) : void
      {
         if(MainView.Instance.testMode)
         {
            return;
         }
         this.middleMouseDragging = true;
         this.dispatchEvent(new Event("MiddleMouseDrag"));
      }
      
      private function onMouseDrag(e:MouseEvent) : void
      {
         if(MainView.Instance.testMode)
         {
            return;
         }
         this.dragging = true;
         this.dispatchEvent(new Event("MouseDrag"));
      }
      
      private function onMouseDown(e:MouseEvent) : void
      {
         if(MainView.Instance.testMode)
         {
            return;
         }
         this.dragging = false;
         this.mouseDown = true;
         this.view.mapViewContainer.addEventListener("mouseMove",this.onMouseDrag);
      }
      
      private function onMouseUp(e:MouseEvent) : void
      {
         if(MainView.Instance.testMode)
         {
            return;
         }
         this.mouseDown = false;
         this.view.mapViewContainer.removeEventListener("mouseMove",this.onMouseDrag);
         if(!this.dragging)
         {
            this.dispatchEvent(new Event("TileClick"));
         }
         else
         {
            this.dragging = false;
            this.dispatchEvent(new Event("MouseDragEnd"));
         }
      }
      
      private function onMouseMoved(e:MouseEvent) : void
      {
         if(MainView.Instance.testMode)
         {
            return;
         }
         this.dispatchEvent(new Event("mouseMove"));
      }
      
      private function onKeyDown(e:KeyboardEvent) : void
      {
         var dict:Dictionary = null;
         if(MainView.Instance.testMode)
         {
            return;
         }
         if(e.ctrlKey)
         {
            this.ctrlKey = true;
            dict = Keybinds.HELD_CTRL_KEYS;
         }
         else
         {
            dict = Keybinds.HELD_KEYS;
         }
         var eventStr:String = dict[e.keyCode];
         if(eventStr == null)
         {
            return;
         }
         this.dispatchEvent(new Event(eventStr));
      }
      
      private function onKeyUp(e:KeyboardEvent) : void
      {
         var dict:Dictionary = null;
         var evt:Event = null;
         if(MainView.Instance.testMode)
         {
            return;
         }
         this.ctrlKey = false;
         if(e.ctrlKey)
         {
            dict = Keybinds.CTRL_KEYS;
         }
         else if(e.shiftKey)
         {
            dict = Keybinds.SHIFT_KEYS;
         }
         else if(e.altKey)
         {
            dict = Keybinds.ALT_KEYS;
         }
         else
         {
            dict = Keybinds.KEYS;
         }
         var eventStr:String = dict[e.keyCode];
         if(eventStr == null)
         {
            return;
         }
         if(eventStr.indexOf("ToolSwitch") != -1)
         {
            evt = new ToolSwitchEvent("ToolSwitch",METool.ToolEventToId(eventStr));
         }
         else
         {
            evt = new Event(eventStr);
         }
         this.dispatchEvent(evt);
      }
   }
}

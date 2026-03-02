package realmeditor.editor.actions
{
   public class MapActionSet
   {
       
      
      public var empty:Boolean = true;
      
      private var reversed:Vector.<MapAction>;
      
      private var normal:Vector.<MapAction>;
      
      public function MapActionSet(original:MapActionSet = null)
      {
         super();
         this.reversed = new Vector.<MapAction>();
         this.normal = new Vector.<MapAction>();
         if(original != null)
         {
            this.copy(original);
         }
      }
      
      public function swap(val:Boolean) : void
      {
         var action:* = null;
         for each(action in this.reversed)
         {
            action.swapped = val;
         }
         for each(action in this.normal)
         {
            action.swapped = val;
         }
      }
      
      public function push(action:MapAction) : void
      {
         this.reversed.insertAt(0,action);
         this.normal.push(action);
         this.empty = false;
      }
      
      public function pushSet(actions:MapActionSet) : void
      {
         for each(var action in actions.normal)
         {
            this.reversed.insertAt(0,action);
            this.normal.push(action);
         }
         this.empty = false;
      }
      
      public function undoAll() : void
      {
         for each(var action in this.reversed)
         {
            if(action.swapped)
            {
               action.doAction();
            }
            else
            {
               action.undoAction();
            }
         }
      }
      
      public function redoAll() : void
      {
         for each(var action in this.normal)
         {
            if(action.swapped)
            {
               action.undoAction();
            }
            else
            {
               action.doAction();
            }
         }
      }
      
      public function clone() : MapActionSet
      {
         return new MapActionSet(this);
      }
      
      private function copy(actions:MapActionSet) : void
      {
         for each(var action in actions.reversed)
         {
            this.push(action.clone());
         }
      }
   }
}

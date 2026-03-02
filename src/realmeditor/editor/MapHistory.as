package realmeditor.editor
{
   import realmeditor.editor.actions.MapAction;
   import realmeditor.editor.actions.MapActionSet;
   
   public class MapHistory
   {
       
      
      public var present:Vector.<MapActionSet>;
      
      public var erased:Vector.<MapActionSet>;
      
      public var linear:Boolean;
      
      public function MapHistory(linear:Boolean = true)
      {
         super();
         this.linear = linear;
         this.present = new Vector.<MapActionSet>();
         this.erased = new Vector.<MapActionSet>();
      }
      
      public function record(action:MapAction) : void
      {
         var actionSet:MapActionSet = new MapActionSet();
         actionSet.push(action);
         this.present.push(actionSet);
         if(this.linear)
         {
            this.erased.length = 0;
         }
      }
      
      public function recordSet(actions:MapActionSet) : void
      {
         if(actions.empty)
         {
            return;
         }
         this.present.push(actions);
         if(this.linear)
         {
            this.erased.length = 0;
         }
      }
      
      public function undo() : MapActionSet
      {
         if(this.present.length == 0)
         {
            return null;
         }
         var lastActions:MapActionSet = this.present.pop();
         lastActions.undoAll();
         this.erased.push(lastActions);
         return lastActions;
      }
      
      public function redo() : MapActionSet
      {
         if(this.erased.length == 0)
         {
            return null;
         }
         var erasedActions:MapActionSet = this.erased.pop();
         erasedActions.redoAll();
         this.present.push(erasedActions);
         return erasedActions;
      }
   }
}

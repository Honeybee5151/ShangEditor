package realmeditor.editor
{
   public class AutoMapSaver
   {
      
      private static const COOLDOWN_MS:int = 30000;


      private var cooldown:int;

      public var disabled:Boolean;

      //editor8182381 — Initialize cooldown to 30000 (was uninitialized=0, caused immediate autosave crash)
      public function AutoMapSaver()
      {
         super();
         this.cooldown = 30000; //editor8182381
      }
      
      public function reset() : void
      {
         this.cooldown = 30000;
      }
      
      public function trySaveMap(mapData:MapData, deltaTime:int) : void
      {
         this.cooldown -= deltaTime;
         if(this.cooldown <= 0)
         {
            this.reset();
            if(!this.disabled)
            {
               mapData.save(true,true);
            }
         }
      }
   }
}

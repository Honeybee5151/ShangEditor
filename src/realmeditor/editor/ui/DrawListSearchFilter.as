package realmeditor.editor.ui
{
   import realmeditor.assets.GroundLibrary;
   import realmeditor.assets.ObjectLibrary;
   import realmeditor.assets.RegionLibrary;
   import realmeditor.editor.ui.elements.IDrawElementFilter;
   
   public class DrawListSearchFilter implements IDrawElementFilter
   {
       
      
      private var drawType:int;
      
      private var searchText:String;
      
      private var matches:Vector.<int>;
      
      public function DrawListSearchFilter()
      {
         super();
      }
      
      public function reset() : void
      {
         this.searchText = null;
         this.matches = null;
      }
      
      public function setSearch(text:String) : void
      {
         this.searchText = text;
         this.updateMatches();
      }
      
      public function setDrawType(drawType:int) : void
      {
         this.drawType = drawType;
         this.updateMatches();
      }
      
      private function updateMatches() : void
      {
         if(this.searchText == null || this.searchText == "")
         {
            this.matches = null;
            return;
         }
         switch(this.drawType)
         {
            case 0:
               this.matches = GroundLibrary.search(this.searchText);
               break;
            case 1:
               this.matches = ObjectLibrary.search(this.searchText);
               break;
            case 2:
               this.matches = RegionLibrary.search(this.searchText);
         }
      }
      
      public function filter(elementType:int) : Boolean
      {
         if(this.matches == null)
         {
            return true;
         }
         return this.matches.indexOf(elementType) != -1;
      }
   }
}

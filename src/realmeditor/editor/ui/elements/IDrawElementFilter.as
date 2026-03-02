package realmeditor.editor.ui.elements
{
   public interface IDrawElementFilter
   {
       
      
      function setDrawType(param1:int) : void;
      
      function filter(param1:int) : Boolean;
   }
}

package realmeditor.editor.tools
{
   import editor.*;
   import flash.utils.Dictionary;
   import realmeditor.editor.MapHistory;
   import realmeditor.editor.ui.MainView;
   import realmeditor.util.IntPoint;
   
   public class METool
   {
      
      public static const SELECT_ID:int = 0;
      
      public static const PENCIL_ID:int = 1;
      
      public static const LINE_ID:int = 2;
      
      public static const SHAPE_ID:int = 3;
      
      public static const BUCKET_ID:int = 4;
      
      public static const PICKER_ID:int = 5;
      
      public static const ERASER_ID:int = 6;
      
      public static const EDIT_ID:int = 7;
      
      public static const SELECT:String = "Select";
      
      public static const PENCIL:String = "Pencil";
      
      public static const LINE:String = "Line";
      
      public static const SHAPE:String = "Shape";
      
      public static const BUCKET:String = "Bucket";
      
      public static const PICKER:String = "Picker";
      
      public static const ERASER:String = "Eraser";
      
      public static const EDIT:String = "Edit";
      
      private static const TOOLS:Dictionary = new Dictionary();
       
      
      public var id:int;
      
      protected var mainView:MainView;
      
      public function METool(id:int, view:MainView)
      {
         super();
         this.id = id;
         this.mainView = view;
      }
      
      public static function GetTool(toolId:int, view:MainView) : METool
      {
         var tool:METool = TOOLS[toolId] as METool;
         if(tool == null)
         {
            tool = CreateTool(toolId,view);
            TOOLS[toolId] = tool;
         }
         return tool;
      }
      
      private static function CreateTool(toolId:int, view:MainView) : METool
      {
         switch(toolId)
         {
            case 0:
               return new MESelectTool(view);
            case 1:
               return new MEPencilTool(view);
            case 2:
               return new MELineTool(view);
            case 3:
               return new MEShapeTool(view);
            case 4:
               return new MEBucketTool(view);
            case 5:
               return new MEPickerTool(view);
            case 6:
               return new MEEraserTool(view);
            case 7:
               return new MEEditTool(view);
            default:
               return null;
         }
      }
      
      public static function ToolEventToId(eventStr:String) : int
      {
         switch(eventStr)
         {
            case "ToolSwitchSelect":
               return 0;
            case "ToolSwitchPencil":
               return 1;
            case "ToolSwitchLine":
               return 2;
            case "ToolSwitchShape":
               return 3;
            case "ToolSwitchBucket":
               return 4;
            case "ToolSwitchPicker":
               return 5;
            case "ToolSwitchEraser":
               return 6;
            case "ToolSwitchEdit":
               return 7;
            default:
               trace("Unknown tool id for tool event:",eventStr);
               return -1;
         }
      }
      
      public static function ToolIdToName(id:int) : String
      {
         switch(id)
         {
            case 0:
               return "Select";
            case 1:
               return "Pencil";
            case 2:
               return "Line";
            case 3:
               return "Shape";
            case 4:
               return "Bucket";
            case 5:
               return "Picker";
            case 6:
               return "Eraser";
            case 7:
               return "Edit";
            default:
               trace("Unknown tool name for tool id:",id.toString());
               return null;
         }
      }
      
      public static function ToolTextureIdToName(id:int) : String
      {
         switch(id)
         {
            case 0:
               return "Select";
            case 1:
               return "Pencil";
            case 2:
               return "Eraser";
            case 3:
               return "Picker";
            case 5:
               return "Bucket";
            case 6:
               return "Line";
            case 7:
               return "Shape";
            case 9:
               return "Edit";
            default:
               trace("Unknown tool name for tool id:",id.toString());
               return null;
         }
      }
      
      public function init(tilePos:IntPoint, history:MapHistory) : void
      {
      }
      
      public function reset() : void
      {
      }
      
      public function mouseDrag(tilePos:IntPoint, history:MapHistory) : void
      {
      }
      
      public function mouseDragEnd(tilePos:IntPoint, history:MapHistory) : void
      {
      }
      
      public function tileClick(tilePos:IntPoint, history:MapHistory) : void
      {
      }
      
      public function mouseMoved(tilePos:IntPoint, history:MapHistory) : void
      {
      }
   }
}

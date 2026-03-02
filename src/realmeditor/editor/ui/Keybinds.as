package realmeditor.editor.ui
{
   import flash.utils.Dictionary;
   
   public class Keybinds
   {
      
      public static var KEYS:Dictionary;
      
      public static var CTRL_KEYS:Dictionary;
      
      public static var SHIFT_KEYS:Dictionary;
      
      public static var ALT_KEYS:Dictionary;
      
      public static var HELD_CTRL_KEYS:Dictionary;
      
      public static var HELD_KEYS:Dictionary;
       
      
      public function Keybinds()
      {
         super();
      }
      
      public static function loadKeys() : void
      {
         KEYS = new Dictionary();
         CTRL_KEYS = new Dictionary();
         SHIFT_KEYS = new Dictionary();
         ALT_KEYS = new Dictionary();
         HELD_KEYS = new Dictionary();
         HELD_CTRL_KEYS = new Dictionary();
         KEYS[77] = "ToolSwitchSelect";
         KEYS[66] = "ToolSwitchPencil";
         KEYS[76] = "ToolSwitchLine";
         KEYS[85] = "ToolSwitchShape";
         KEYS[71] = "ToolSwitchBucket";
         KEYS[73] = "ToolSwitchPicker";
         KEYS[69] = "ToolSwitchEraser";
         KEYS[68] = "ToolSwitchEdit";
         KEYS[84] = "DrawTypeSwitch";
         KEYS[27] = "ClearSelection";
         KEYS[38] = "MoveSelectionUp";
         KEYS[40] = "MoveSelectionDown";
         KEYS[37] = "MoveSelectionLeft";
         KEYS[39] = "MoveSelectionRight";
         KEYS[114] = "ToggleDebug";
         SHIFT_KEYS[71] = "GridEnable";
         CTRL_KEYS[67] = "Copy";
         CTRL_KEYS[86] = "Paste";
         HELD_CTRL_KEYS[90] = "Undo";
         HELD_CTRL_KEYS[89] = "Redo";
      }
   }
}

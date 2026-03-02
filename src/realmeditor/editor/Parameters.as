package realmeditor.editor
{
   import flash.net.SharedObject;
   
   public class Parameters
   {
      
      private static const ASSET_DIRS_KEY:String = "assetDirs";
      
      private static var sharedObj:SharedObject;
      
      public static var data:Object;
       
      
      public function Parameters()
      {
         super();
      }
      
      public static function load() : void
      {
         try
         {
            sharedObj = SharedObject.getLocal("RealmEditorSettings","/");
            data = sharedObj.data;
         }
         catch(error:Error)
         {
            trace("WARNING: unable to save settings");
            data = {};
         }
         setDefaults();
         save();
      }
      
      public static function save() : void
      {
         try
         {
            if(sharedObj)
            {
               sharedObj.flush();
            }
         }
         catch(error:Error)
         {
         }
      }
      
      public static function getAssetDirs() : Vector.<String>
      {
         var dataStr:String = null;
         var ret:Vector.<String> = new Vector.<String>();
         if(data["assetDirs"] != null)
         {
            dataStr = String(data["assetDirs"]);
            if(dataStr == "")
            {
               return ret;
            }
            for each(var dir in dataStr.split("$"))
            {
               ret.push(dir);
            }
         }
         return ret;
      }
      
      public static function saveAssetsDir(dir:String) : void
      {
         trace("ADDED ASSETS DIRECTORY",dir);
         if(data["assetDirs"] == null || data["assetDirs"] == "")
         {
            data["assetDirs"] = dir;
         }
         else
         {
            var _loc2_:String = "assetDirs";
            var _loc3_:* = data[_loc2_] + ("$" + dir);
            data[_loc2_] = _loc3_;
         }
         save();
      }
      
      public static function deleteAssetsDir(dir:String) : void
      {
         var savedAssets:String = data["assetDirs"];
         var deleteDelim:int = 0;
         if(savedAssets.indexOf("$") != -1)
         {
            deleteDelim = 1;
         }
         var firstCut:String = savedAssets.substr(0,savedAssets.indexOf(dir));
         var secondCut:String = savedAssets.substr(savedAssets.indexOf(dir) + dir.length + deleteDelim);
         data["assetDirs"] = firstCut + secondCut;
         trace("REMOVED ASSETS DIRECTORY",dir,data["assetDirs"]);
         save();
      }
      
      private static function setDefaults() : void
      {
      }
   }
}

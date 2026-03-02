package realmeditor.assets
{
   import flash.utils.Dictionary;
   
   public class AnimatedChars
   {
      
      private static var nameMap_:Dictionary = new Dictionary();
       
      
      public function AnimatedChars()
      {
         super();
      }
      
      public static function clear() : void
      {
         nameMap_ = new Dictionary();
      }
      
      public static function getAnimatedChar(name:String, id:int) : AnimatedChar
      {
         var chars:Vector.<AnimatedChar> = nameMap_[name];
         if(chars == null || id >= chars.length)
         {
            return null;
         }
         return chars[id];
      }
      
      public static function load(dict:Dictionary) : void
      {
         var value:Object = null;
         var chars:* = undefined;
         var image:MaskedImage = null;
         for(var key in dict)
         {
            value = dict[key];
            chars = new Vector.<AnimatedChar>();
            for each(var animChar in value)
            {
               image = new MaskedImage(animChar.origImage_.image_,animChar.origImage_.mask_);
               chars.push(new AnimatedChar(image,animChar.width_,animChar.height_,animChar.firstDir_));
            }
            nameMap_[key] = chars;
         }
      }
   }
}

package realmeditor.assets
{
   import flash.display.BitmapData;
   import flash.utils.Dictionary;
   
   public class AssetLibrary
   {
      
      private static var images_:Dictionary = new Dictionary();
      
      private static var imageSets_:Dictionary = new Dictionary();
      
      private static var imageLookup_:Dictionary = new Dictionary();
       
      
      public function AssetLibrary()
      {
         super();
      }
      
      public static function load(images:Dictionary, imageSets:Dictionary, imageLookup:Dictionary) : void
      {
         var imageSet:ImageSet = null;
         images_ = images;
         for(var key in imageSets)
         {
            (imageSet = new ImageSet()).images_ = imageSets[key].images_;
            imageSets_[key] = imageSet;
         }
         imageLookup_ = imageLookup;
      }
      
      public static function addImageSet(name:String, data:BitmapData, width:int, height:int) : void
      {
         var i:int = 0;
         images_[name] = data;
         var imageSet:ImageSet = new ImageSet();
         imageSet.addFromBitmapData(data,width,height);
         imageSets_[name] = imageSet;
         for(i = 0; i < imageSet.images_.length; )
         {
            imageLookup_[imageSet.images_[i]] = [name,i];
            i++;
         }
      }
      
      public static function getImageFromSet(name:String, id:int) : BitmapData
      {
         var imageSet:ImageSet = imageSets_[name];
         return imageSet.images_[id];
      }
      
      public static function clear() : void
      {
         images_ = new Dictionary();
         imageSets_ = new Dictionary();
         imageLookup_ = new Dictionary();
      }
   }
}

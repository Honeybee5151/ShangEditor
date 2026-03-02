package realmeditor.util
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.utils.Dictionary;
   
   public class GlowRedrawer
   {
      
      private static const GRADIENT_MAX_SUB:uint = 2631720;
      
      private static const GLOW_FILTER:GlowFilter = new GlowFilter(0,0.3,12,12,2,1,false,false);
      
      private static const GLOW_FILTER_ALT:GlowFilter = new GlowFilter(0,0.5,16,16,3,1,false,false);
      
      private static var tempMatrix_:Matrix = new Matrix();
      
      private static var gradient_:Shape = getGradient();
      
      private static var glowHashes:Dictionary = new Dictionary();
       
      
      public function GlowRedrawer()
      {
         super();
      }
      
      public static function outlineGlow(texture:BitmapData, glowColor:uint, outlineSize:Number = 1.4, caching:Boolean = true, outlineColor:int = 0) : BitmapData
      {
         var hash:int = getHash(glowColor,outlineSize,outlineColor);
         if(caching && isCached(texture,hash))
         {
            return glowHashes[texture][hash];
         }
         var newTexture:BitmapData = texture.clone();
         tempMatrix_.identity();
         tempMatrix_.scale(texture.width / 256,texture.height / 256);
         newTexture.draw(gradient_,tempMatrix_,null,"subtract");
         var origBitmap:Bitmap = new Bitmap(texture);
         newTexture.draw(origBitmap,null,null,"alpha");
         TextureRedrawer.OUTLINE_FILTER.blurX = outlineSize;
         TextureRedrawer.OUTLINE_FILTER.blurY = outlineSize;
         TextureRedrawer.OUTLINE_FILTER.color = outlineColor;
         newTexture.applyFilter(newTexture,newTexture.rect,PointUtil.ORIGIN,TextureRedrawer.OUTLINE_FILTER);
         if(glowColor != 4294967295)
         {
            GLOW_FILTER.color = glowColor;
            newTexture.applyFilter(newTexture,newTexture.rect,PointUtil.ORIGIN,GLOW_FILTER);
         }
         if(caching)
         {
            cache(texture,glowColor,outlineSize,newTexture,outlineColor);
         }
         return newTexture;
      }
      
      private static function cache(texture:BitmapData, glowColor:uint, outlineSize:Number, newTexture:BitmapData, outlineColor:int) : void
      {
         var glowHash:Object = null;
         var hash:int = getHash(glowColor,outlineSize,outlineColor);
         if(texture in glowHashes)
         {
            glowHashes[texture][hash] = newTexture;
         }
         else
         {
            (glowHash = {})[hash] = newTexture;
            glowHashes[texture] = glowHash;
         }
      }
      
      private static function isCached(texture:BitmapData, hash:int) : Boolean
      {
         var outlineHash:Object = null;
         if(texture in glowHashes)
         {
            outlineHash = glowHashes[texture];
            if(hash in outlineHash)
            {
               return true;
            }
         }
         return false;
      }
      
      private static function getHash(glowColor:uint, outlineSize:Number, outlineColor:int) : int
      {
         return int(outlineSize * 10) + glowColor + outlineColor;
      }
      
      private static function getGradient() : Shape
      {
         var gradient:Shape = new Shape();
         var gm:Matrix = new Matrix();
         gm.createGradientBox(256,256,3.141592653589793 / 2,0,0);
         gradient.graphics.beginGradientFill("linear",[0,2631720],[1,1],[127,255],gm);
         gradient.graphics.drawRect(0,0,256,256);
         gradient.graphics.endFill();
         return gradient;
      }
   }
}

package realmeditor.util
{
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class BitmapUtil
   {
       
      
      public function BitmapUtil(se:StaticEnforcer)
      {
         super();
      }
      
      public static function mirror(bitmapData:BitmapData, width:int = 0) : BitmapData
      {
         var x:int = 0;
         var y:int = 0;
         if(width == 0)
         {
            width = bitmapData.width;
         }
         var mirrored:BitmapData = new BitmapData(bitmapData.width,bitmapData.height,true,0);
         for(x = 0; x < width; )
         {
            for(y = 0; y < bitmapData.height; )
            {
               mirrored.setPixel32(width - x - 1,y,bitmapData.getPixel32(x,y));
               y++;
            }
            x++;
         }
         return mirrored;
      }
      
      public static function rotateBitmapData(bitmapData:BitmapData, clockwiseTurns:int) : BitmapData
      {
         var matrix:Matrix = new Matrix();
         matrix.translate(-bitmapData.width / 2,-bitmapData.height / 2);
         matrix.rotate(clockwiseTurns * 3.141592653589793 / 2);
         matrix.translate(bitmapData.height / 2,bitmapData.width / 2);
         var rotated:BitmapData = new BitmapData(bitmapData.height,bitmapData.width,true,0);
         rotated.draw(bitmapData,matrix);
         return rotated;
      }
      
      public static function cropToBitmapData(bitmapData:BitmapData, x:int, y:int, width:int, height:int) : BitmapData
      {
         var cropped:BitmapData = new BitmapData(width,height);
         cropped.copyPixels(bitmapData,new Rectangle(x,y,width,height),new Point(0,0));
         return cropped;
      }
      
      public static function amountTransparent(bitmapData:BitmapData) : Number
      {
         var x:int = 0;
         var y:int = 0;
         var alpha:* = 0;
         var trans:int = 0;
         for(x = 0; x < bitmapData.width; )
         {
            for(y = 0; y < bitmapData.height; )
            {
               alpha = bitmapData.getPixel32(x,y) & 4278190080;
               if(alpha == 0)
               {
                  trans++;
               }
               y++;
            }
            x++;
         }
         return trans / (bitmapData.width * bitmapData.height);
      }
      
      public static function mostCommonColor(bitmapData:BitmapData) : uint
      {
         var x:int = 0;
         var color:uint = 0;
         var colorStr:* = null;
         var y:int = 0;
         var count:int = 0;
         var colors_:Dictionary = new Dictionary();
         for(x = 0; x < bitmapData.width; )
         {
            for(y = 0; y < bitmapData.width; )
            {
               color = bitmapData.getPixel32(x,y);
               if((color & 4278190080) != 0)
               {
                  if(!colors_.hasOwnProperty(color))
                  {
                     colors_[color] = 1;
                  }
                  else
                  {
                     colors_[color]++;
                  }
               }
               y++;
            }
            x++;
         }
         var bestColor:* = 0;
         var bestCount:uint = 0;
         for(colorStr in colors_)
         {
            color = colorStr;
            count = int(colors_[colorStr]);
            if(count > bestCount || count == bestCount && color > bestColor)
            {
               bestColor = color;
               bestCount = uint(count);
            }
         }
         return bestColor;
      }
      
      public static function lineOfSight(bitmapData:BitmapData, p1:IntPoint, p2:IntPoint) : Boolean
      {
         var temp:* = 0;
         var numSteps:int = 0;
         var skipYSteps:int = 0;
         var skipXSteps:int = 0;
         var width:* = bitmapData.width;
         var height:* = bitmapData.height;
         var x0:* = p1.x();
         var y0:* = p1.y();
         var x1:* = p2.x();
         var y1:* = p2.y();
         var steep:* = (y0 > y1 ? y0 - y1 : y1 - y0) > (x0 > x1 ? x0 - x1 : x1 - x0);
         if(steep)
         {
            temp = x0;
            x0 = y0;
            y0 = temp;
            temp = x1;
            x1 = y1;
            y1 = temp;
            temp = width;
            width = height;
            height = temp;
         }
         if(x0 > x1)
         {
            temp = x0;
            x0 = x1;
            x1 = temp;
            temp = y0;
            y0 = y1;
            y1 = temp;
         }
         var deltax:int = x1 - x0;
         var deltay:int = y0 > y1 ? y0 - y1 : y1 - y0;
         var error:int = -(deltax + 1) / 2;
         var ystep:int = y0 > y1 ? -1 : 1;
         var xstop:int = x1 > width - 1 ? width - 1 : x1;
         var y:* = y0;
         var x:* = x0;
         if(x < 0)
         {
            error += deltay * -x;
            if(error += deltay * -x >= 0)
            {
               numSteps = error / deltax + 1;
               y += ystep * numSteps;
               error -= numSteps * deltax;
            }
            x = 0;
         }
         if(ystep > 0 && y < 0 || ystep < 0 && y >= height)
         {
            skipYSteps = ystep > 0 ? int(-y - 1) : y - height;
            error -= deltax * skipYSteps;
            error -= deltax * skipYSteps / deltay;
            skipXSteps = -error;
            x += skipXSteps;
            error += skipXSteps * deltay;
            y += skipYSteps * ystep;
         }
         while(x <= xstop)
         {
            if(ystep > 0 && y >= height || ystep < 0 && y < 0)
            {
               break;
            }
            if(steep)
            {
               if(y >= 0 && y < height && bitmapData.getPixel(y,x) == 0)
               {
                  return false;
               }
            }
            else if(y >= 0 && y < height && bitmapData.getPixel(x,y) == 0)
            {
               return false;
            }
            error += deltay;
            if(error += deltay >= 0)
            {
               y += ystep;
               error -= deltax;
            }
            x++;
         }
         return true;
      }
   }
}

class StaticEnforcer
{
    
   
   public function StaticEnforcer()
   {
      super();
   }
}

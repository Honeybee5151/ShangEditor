package realmeditor.util
{
   import flash.utils.ByteArray;
   
   public class BinaryUtils
   {
      
      private static const MaxBytesWithoutOverflow:int = 4;
       
      
      public function BinaryUtils()
      {
         super();
      }
      
      public static function Read7BitEncodedInt(data:ByteArray) : int
      {
         var byteReadJustNow:int = 0;
         var shift:int = 0;
         var result:uint = 0;
         for(shift = 0; shift < 4 * 7; )
         {
            byteReadJustNow = data.readByte();
            result |= (byteReadJustNow & 0x7F) << shift;
            if(byteReadJustNow <= 127)
            {
               return int(result);
            }
            shift += 7;
         }
         byteReadJustNow = data.readByte();
         if(byteReadJustNow > 15)
         {
            throw new Error("Bad 7-bit encoded integer bit");
         }
         result |= uint(byteReadJustNow) << 4 * 7;
         return int(result);
      }
      
      public static function Write7BitEncodedInt(data:ByteArray, value:int) : void
      {
         var v:* = value;
         while(v >= 128)
         {
            data.writeByte(v | 0x80);
            v >>= 7;
         }
         data.writeByte(v);
      }
   }
}

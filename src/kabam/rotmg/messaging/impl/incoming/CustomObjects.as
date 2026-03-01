//editor8182381 — Incoming message for custom object pixel data from dungeon editor maps
package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import com.company.assembleegameclient.map.GroundLibrary;

   public class CustomObjects extends IncomingMessage
   {
      public function CustomObjects(id:uint, callback:Function)
      {
         super(id, callback);
      }

      override public function parseFromInput(data:IDataInput) : void
      {
         //editor8182381 — Read zlib-compressed custom object data
         var compressedLen:int = data.readInt();
         var compressed:ByteArray = new ByteArray();
         data.readBytes(compressed, 0, compressedLen);

         // Decompress
         compressed.uncompress();
         compressed.endian = Endian.BIG_ENDIAN;
         compressed.position = 0;

         var count:int = compressed.readInt();
         for (var i:int = 0; i < count; i++)
         {
            var typeCode:uint = compressed.readUnsignedShort();
            var spriteSize:int = compressed.readByte();
            var pixels:ByteArray = null;
            if (spriteSize > 0)
            {
               var pixelBytes:int = spriteSize * spriteSize * 3;
               pixels = new ByteArray();
               compressed.readBytes(pixels, 0, pixelBytes);
            }
            var classFlag:int = compressed.readByte();
            // 0=Object, 1=Destructible, 2=Decoration, 3=Wall, 4=Blocker

            //editor8182381 — Register this custom object in GroundLibrary + ObjectLibrary
            if (pixels != null && spriteSize > 0)
            {
               GroundLibrary.loadBinaryCustomObject(typeCode, pixels, spriteSize, classFlag);
            }
         }
      }
   }
}

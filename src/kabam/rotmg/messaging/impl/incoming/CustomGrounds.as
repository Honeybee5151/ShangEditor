//editor8182381 — Incoming message for custom ground pixel data from dungeon editor maps
package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import com.company.assembleegameclient.map.GroundLibrary;

   public class CustomGrounds extends IncomingMessage
   {
      public function CustomGrounds(id:uint, callback:Function)
      {
         super(id, callback);
      }

      override public function parseFromInput(data:IDataInput) : void
      {
         //editor8182381 — Read zlib-compressed custom ground data
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
            // Read 192 bytes of RGB pixel data (8x8 tile, 3 bytes per pixel)
            var pixels:ByteArray = new ByteArray();
            compressed.readBytes(pixels, 0, 192);
            var flags:int = compressed.readByte();
            var noWalk:Boolean = (flags & 1) != 0;
            //editor8182381 — Read blend priority (sbyte) and speed (float) per tile
            var blendPriority:int = compressed.readByte();
            var speed:Number = compressed.readFloat();
            //editor8182381 — Read advanced ground properties (damage, sink, animate, push, slide)
            var minDamage:int = compressed.readShort();
            var maxDamage:int = compressed.readShort();
            var sink:Boolean = compressed.readBoolean();
            var animType:uint = compressed.readUnsignedByte();
            var animDx:Number = compressed.readFloat();
            var animDy:Number = compressed.readFloat();
            var push:Boolean = compressed.readBoolean();
            var slideAmount:Number = compressed.readFloat();

            //editor8182381 — Register this custom ground tile in GroundLibrary
            GroundLibrary.loadBinaryCustomGround(typeCode, pixels, noWalk, blendPriority, speed,
               minDamage, maxDamage, sink, animType, animDx, animDy, push, slideAmount);
         }
      }
   }
}

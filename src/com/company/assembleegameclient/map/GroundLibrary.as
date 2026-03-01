// Decompiled by AS3 Sorcerer 6.08
// www.as3sorcerer.com

//com.company.assembleegameclient.map.GroundLibrary

package com.company.assembleegameclient.map
{
import flash.utils.Dictionary;
//editor8182381
import flash.utils.ByteArray;
import com.company.assembleegameclient.objects.TextureDataConcrete;
//editor8182381
import com.company.assembleegameclient.objects.ObjectLibrary;
//editor8182381
import com.company.assembleegameclient.objects.ObjectProperties;
import flash.display.BitmapData;
import com.company.util.BitmapUtil;

public class GroundLibrary
{

   public static const propsLibrary_:Dictionary = new Dictionary();
   public static const xmlLibrary_:Dictionary = new Dictionary();
   private static var tileTypeColorDict_:Dictionary = new Dictionary();
   public static const typeToTextureData_:Dictionary = new Dictionary();
   public static var idToType_:Dictionary = new Dictionary();
   public static var defaultProps_:GroundProperties;
   public static var GROUND_CATEGORY:String = "Ground";

   //editor8182381 — Storage for custom object sprites (typeCode → BitmapData)
   public static var customObjectSprites_:Dictionary = new Dictionary();
   //editor8182381 — Track registered custom type codes for cleanup on disconnect
   public static var customGroundTypeCodes_:Vector.<uint> = new Vector.<uint>();
   public static var customObjectTypeCodes_:Vector.<uint> = new Vector.<uint>();


   public static function parseFromXML(_arg_1:XML):void
   {
      var _local_2:XML;
      var _local_3:int;
      for each (_local_2 in _arg_1.Ground)
      {
         _local_3 = int(_local_2.@type);
         propsLibrary_[_local_3] = new GroundProperties(_local_2);
         xmlLibrary_[_local_3] = _local_2;
         typeToTextureData_[_local_3] = new TextureDataConcrete(_local_2);
         idToType_[String(_local_2.@id)] = _local_3;
      }
      defaultProps_ = propsLibrary_[0xFF];
   }

   public static function getIdFromType(_arg_1:int):String
   {
      var _local_2:GroundProperties = propsLibrary_[_arg_1];
      if (_local_2 == null)
      {
         return (null);
      }
      return (_local_2.id_);
   }

   public static function getPropsFromId(_arg_1:String):GroundProperties
   {
      return (propsLibrary_[idToType_[_arg_1]]);
   }

   public static function getBitmapData(_arg_1:int, _arg_2:int=0):BitmapData
   {
      //editor8182381 — Null safety for custom ground types not yet registered
      var td:Object = typeToTextureData_[_arg_1];
      if (td == null) return null;
      return (td.getTexture(_arg_2));
   }

   public static function getColor(_arg_1:int):uint
   {
      var _local_2:XML;
      var _local_3:uint;
      var _local_4:BitmapData;
      if (!tileTypeColorDict_.hasOwnProperty(_arg_1))
      {
         _local_2 = xmlLibrary_[_arg_1];
         //editor8182381 — Null safety for custom ground tiles with no XML entry
         if (_local_2 != null && _local_2.hasOwnProperty("Color"))
         {
            _local_3 = uint(_local_2.Color);
         }
         else
         {
            _local_4 = getBitmapData(_arg_1);
            //editor8182381 — Null safety if BitmapData not yet loaded
            if (_local_4 != null)
               _local_3 = BitmapUtil.mostCommonColor(_local_4);
            else
               _local_3 = 0x000000;
         }
         tileTypeColorDict_[_arg_1] = _local_3;
      }
      return (tileTypeColorDict_[_arg_1]);
   }


   //editor8182381 — Load a custom ground tile from binary RGB pixel data (192 bytes = 8x8 x 3 RGB)
   public static function loadBinaryCustomGround(typeCode:uint, pixels:ByteArray, noWalk:Boolean, blendPriority:int = -1, speed:Number = 1.0):void
   {
      var bmd:BitmapData = new BitmapData(8, 8, false, 0x000000);
      pixels.position = 0;
      for (var y:int = 0; y < 8; y++)
      {
         for (var x:int = 0; x < 8; x++)
         {
            var r:int = pixels.readUnsignedByte();
            var g:int = pixels.readUnsignedByte();
            var b:int = pixels.readUnsignedByte();
            bmd.setPixel(x, y, (r << 16) | (g << 8) | b);
         }
      }
      //editor8182381 — Track for cleanup and create GroundProperties from minimal XML
      customGroundTypeCodes_.push(typeCode);
      var dummyXml:XML = <Ground type={typeCode} id={"CustomGround_" + typeCode.toString(16)} />;
      var props:GroundProperties = new GroundProperties(dummyXml);
      props.noWalk_ = noWalk;
      props.blendPriority_ = blendPriority;
      props.speed_ = speed;
      propsLibrary_[typeCode] = props;

      //editor8182381 — Create TextureDataConcrete with dummy XML (no texture tags = safe),
      //               then set texture_ directly. getTexture() returns texture_ when randomTextureData_ is null.
      var td:TextureDataConcrete = new TextureDataConcrete(dummyXml);
      td.texture_ = bmd;
      typeToTextureData_[typeCode] = td;
   }

   //editor8182381 — Load a custom object sprite from binary RGB pixel data and register in ObjectLibrary
   // classFlag: 0=Object, 1=Destructible, 2=Decoration, 3=Wall, 4=Blocker
   public static function loadBinaryCustomObject(typeCode:uint, pixels:ByteArray, spriteSize:int, classFlag:int = 0):void
   {
      var bmd:BitmapData = new BitmapData(spriteSize, spriteSize, false, 0x000000);
      pixels.position = 0;
      for (var y:int = 0; y < spriteSize; y++)
      {
         for (var x:int = 0; x < spriteSize; x++)
         {
            var r:int = pixels.readUnsignedByte();
            var g:int = pixels.readUnsignedByte();
            var b:int = pixels.readUnsignedByte();
            bmd.setPixel(x, y, (r << 16) | (g << 8) | b);
         }
      }
      customObjectSprites_[typeCode] = bmd;
      customObjectTypeCodes_.push(typeCode);

      //editor8182381 — Build XML matching server's BuildCustomObjectXml based on classFlag
      var is3D:Boolean = (classFlag == 1 || classFlag == 3); // Destructible or Wall
      var className:String = is3D ? "Wall" : "GameObject";
      var objXml:XML = <Object type={typeCode} id={"CustomObj_" + typeCode.toString(16)}>
         <Class>{className}</Class>
         <Static/>
      </Object>;
      if (classFlag == 4) // Blocker
      {
         objXml.appendChild(<OccupySquare/>);
         objXml.appendChild(<EnemyOccupySquare/>);
      }
      else if (classFlag == 3) // Wall
      {
         objXml.appendChild(<FullOccupy/>);
         objXml.appendChild(<BlocksSight/>);
         objXml.appendChild(<OccupySquare/>);
         objXml.appendChild(<EnemyOccupySquare/>);
      }
      else if (classFlag == 1) // Destructible
      {
         objXml.appendChild(<FullOccupy/>);
         objXml.appendChild(<BlocksSight/>);
         objXml.appendChild(<OccupySquare/>);
         objXml.appendChild(<EnemyOccupySquare/>);
         objXml.appendChild(<Enemy/>);
         objXml.appendChild(<MaxHitPoints>100</MaxHitPoints>);
      }
      else if (classFlag == 0) // Object (default)
      {
         objXml.appendChild(<OccupySquare/>);
         objXml.appendChild(<EnemyOccupySquare/>);
      }
      // classFlag == 2 (Decoration) — no extra tags

      ObjectLibrary.xmlLibrary_[typeCode] = objXml;
      ObjectLibrary.propsLibrary_[typeCode] = new ObjectProperties(objXml);

      //editor8182381 — Set texture via TextureDataConcrete with dummy XML, then override texture_
      var td:TextureDataConcrete = new TextureDataConcrete(objXml);
      td.texture_ = bmd;
      ObjectLibrary.typeToTextureData_[typeCode] = td;
   }

   //editor8182381 — Clean up all custom ground/object entries to prevent memory leaks on disconnect
   public static function clearCustomEntries():void
   {
      var i:int;
      var tc:uint;
      // Dispose custom ground BitmapData and remove from dictionaries
      for (i = 0; i < customGroundTypeCodes_.length; i++)
      {
         tc = customGroundTypeCodes_[i];
         if (typeToTextureData_[tc] != null && typeToTextureData_[tc].texture_ != null)
            typeToTextureData_[tc].texture_.dispose();
         delete propsLibrary_[tc];
         delete xmlLibrary_[tc];
         delete typeToTextureData_[tc];
         delete tileTypeColorDict_[tc];
      }
      // Dispose custom object BitmapData and remove from ObjectLibrary
      for (i = 0; i < customObjectTypeCodes_.length; i++)
      {
         tc = customObjectTypeCodes_[i];
         if (customObjectSprites_[tc] != null)
            BitmapData(customObjectSprites_[tc]).dispose();
         delete customObjectSprites_[tc];
         if (ObjectLibrary.typeToTextureData_[tc] != null && ObjectLibrary.typeToTextureData_[tc].texture_ != null)
            ObjectLibrary.typeToTextureData_[tc].texture_.dispose();
         delete ObjectLibrary.xmlLibrary_[tc];
         delete ObjectLibrary.propsLibrary_[tc];
         delete ObjectLibrary.typeToTextureData_[tc];
      }
      customGroundTypeCodes_.length = 0;
      customObjectTypeCodes_.length = 0;
   }

}
}//package com.company.assembleegameclient.map


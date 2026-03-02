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
   //editor8182381 — Direct BitmapData lookup for custom grounds (bypasses TextureDataConcrete)
   public static var customGroundBitmaps_:Dictionary = new Dictionary();
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
      //editor8182381 — Check direct custom bitmap lookup first (editor JM load path)
      var customBmd:BitmapData = customGroundBitmaps_[_arg_1];
      if (customBmd != null) return customBmd;
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
   //editor8182381 — Use int for Dictionary keys to match parseFromXML (AS3 Dictionary treats int/uint as different keys)
   //editor8182381 — Extended with advanced ground params (damage, sink, animate, push, slide)
   public static function loadBinaryCustomGround(typeCode:uint, pixels:ByteArray, noWalk:Boolean, blendPriority:int = -1, speed:Number = 1.0,
      minDamage:int = 0, maxDamage:int = 0, sink:Boolean = false,
      animType:uint = 0, animDx:Number = 0, animDy:Number = 0,
      push:Boolean = false, slideAmount:Number = 0):void
   {
      var iType:int = int(typeCode);
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
      //editor8182381 — Track for cleanup and build XML with all properties
      customGroundTypeCodes_.push(typeCode);
      //editor8182381 — Build tile XML with advanced properties when any are non-default
      var hasAdvanced:Boolean = blendPriority != -1 || speed != 1.0 ||
         minDamage > 0 || maxDamage > 0 || sink || animType != 0 || push || slideAmount != 0;
      var tileXml:XML;
      if (hasAdvanced)
      {
         tileXml = <Ground type={typeCode} id={"CustomGround_" + typeCode.toString(16)}>
            <Texture><File>lofiEnvironment2</File><Index>0x0b</Index></Texture>
         </Ground>;
         if (blendPriority != -1) tileXml.appendChild(<BlendPriority>{blendPriority}</BlendPriority>);
         if (speed != 1.0) tileXml.appendChild(<Speed>{speed}</Speed>);
         if (noWalk) tileXml.appendChild(<NoWalk/>);
         //editor8182381 — Append advanced property XML elements (damage, sink, animate, push, slide)
         if (minDamage > 0) tileXml.appendChild(<MinDamage>{minDamage}</MinDamage>);
         if (maxDamage > 0) tileXml.appendChild(<MaxDamage>{maxDamage}</MaxDamage>);
         if (sink) tileXml.appendChild(<Sink/>);
         if (animType == 1) tileXml.appendChild(<Animate dx={animDx} dy={animDy}>Wave</Animate>);
         else if (animType == 2) tileXml.appendChild(<Animate dx={animDx} dy={animDy}>Flow</Animate>);
         if (push) tileXml.appendChild(<Push/>);
         if (slideAmount != 0) tileXml.appendChild(<SlideAmount>{slideAmount}</SlideAmount>);
      }
      else
      {
         tileXml = <Ground type={typeCode} id={"CustomGround_" + typeCode.toString(16)} />;
      }
      var props:GroundProperties = new GroundProperties(tileXml);
      props.noWalk_ = noWalk;
      propsLibrary_[iType] = props;

      //editor8182381 — Create TextureDataConcrete with dummy XML (no texture tags = safe),
      //               then set texture_ directly. getTexture() returns texture_ when randomTextureData_ is null.
      var td:TextureDataConcrete = new TextureDataConcrete(tileXml);
      td.texture_ = bmd;
      typeToTextureData_[iType] = td;
   }

   //editor8182381 — Load a custom object sprite from binary RGB pixel data and register in ObjectLibrary
   // classFlag: 0=Object, 1=Destructible, 2=Decoration, 3=Wall, 4=Blocker
   //editor8182381 — Use int for Dictionary keys to match ObjectLibrary.parseFromXML
   public static function loadBinaryCustomObject(typeCode:uint, pixels:ByteArray, spriteSize:int, classFlag:int = 0):void
   {
      var iType:int = int(typeCode);
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
      customObjectSprites_[iType] = bmd;
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

      ObjectLibrary.xmlLibrary_[iType] = objXml;
      ObjectLibrary.propsLibrary_[iType] = new ObjectProperties(objXml);

      //editor8182381 — Set texture via TextureDataConcrete with dummy XML, then override texture_
      var td:TextureDataConcrete = new TextureDataConcrete(objXml);
      td.texture_ = bmd;
      ObjectLibrary.typeToTextureData_[iType] = td;
   }

   //editor8182381 — Clean up all custom ground/object entries to prevent memory leaks on disconnect
   //editor8182381 — Use int() cast for Dictionary keys to match how entries were stored
   public static function clearCustomEntries():void
   {
      var i:int;
      var tc:uint;
      var itc:int;
      // Dispose custom ground BitmapData and remove from dictionaries
      for (i = 0; i < customGroundTypeCodes_.length; i++)
      {
         tc = customGroundTypeCodes_[i];
         itc = int(tc);
         if (typeToTextureData_[itc] != null && typeToTextureData_[itc].texture_ != null)
            typeToTextureData_[itc].texture_.dispose();
         delete propsLibrary_[itc];
         delete xmlLibrary_[itc];
         delete typeToTextureData_[itc];
         delete tileTypeColorDict_[itc];
      }
      // Dispose custom object BitmapData and remove from ObjectLibrary
      for (i = 0; i < customObjectTypeCodes_.length; i++)
      {
         tc = customObjectTypeCodes_[i];
         itc = int(tc);
         if (customObjectSprites_[itc] != null)
            BitmapData(customObjectSprites_[itc]).dispose();
         delete customObjectSprites_[itc];
         if (ObjectLibrary.typeToTextureData_[itc] != null && ObjectLibrary.typeToTextureData_[itc].texture_ != null)
            ObjectLibrary.typeToTextureData_[itc].texture_.dispose();
         delete ObjectLibrary.xmlLibrary_[itc];
         delete ObjectLibrary.propsLibrary_[itc];
         delete ObjectLibrary.typeToTextureData_[itc];
      }
      customGroundTypeCodes_.length = 0;
      customObjectTypeCodes_.length = 0;
      //editor8182381 — Clear direct bitmap lookup
      customGroundBitmaps_ = new Dictionary();
   }

}
}//package com.company.assembleegameclient.map


package com.company.assembleegameclient.mapeditor
{
import com.company.assembleegameclient.account.ui.TextInputField;
import com.company.assembleegameclient.editor.CommandEvent;
   import com.company.assembleegameclient.editor.CommandList;
   import com.company.assembleegameclient.editor.CommandQueue;
   import com.company.assembleegameclient.map.GroundLibrary;
   //editor8182381
   import com.company.assembleegameclient.map.GroundProperties;
   import com.company.assembleegameclient.map.RegionLibrary;
   import com.company.assembleegameclient.objects.ObjectLibrary;
   import com.company.assembleegameclient.screens.AccountScreen;
import com.company.assembleegameclient.screens.TitleMenuOption;
import com.company.assembleegameclient.ui.dropdown.DropDown;
   import com.company.util.IntPoint;
   import com.company.util.SpriteUtil;
   import com.hurlant.util.Base64;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
   import flash.net.FileFilter;
   import flash.net.FileReference;
import flash.text.TextFieldAutoSize;
//editor8182381
import flash.display.BitmapData;
import flash.utils.ByteArray;
   //editor8182381
   import flash.utils.Dictionary;
   //editor8182381 — AIR native file API (fixes FileReference.load() Error #3003)
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.filesystem.FileMode;
   import kabam.lib.json.JsonParser;
   import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.core.signals.SetScreenSignal;
import kabam.rotmg.ui.view.TitleView;
import kabam.rotmg.ui.view.components.ScreenBase;
   import net.hires.debug.Stats;

import org.hamcrest.text.startsWith;

public class EditingScreen extends Sprite
   {
      
      private static const MAP_Y:int = 600 - MEMap.SIZE - 10;
      
      public static const stats_:Stats = new Stats();
      
      public var commandMenu_:MECommandMenu;
      
      private var commandQueue_:CommandQueue;
      
      public var meMap_:MEMap;
      
      public var infoPane_:InfoPane;
      
      public var chooserDrowDown_:DropDown;
      
      public var groundChooser_:GroundChooser;
      
      public var objChooser_:ObjectChooser;
      
      public var regionChooser_:RegionChooser;
      
      public var chooser_:Chooser;
      
      public var filename_:String = null;

      private var json:JsonParser;

      private var loadedFile_:FileReference = null;

      //editor8182381 — Custom tile metadata for round-trip JM save/load
      // Maps typeCode → {id: originalCustomId, groundPixels: base64, blocked: Boolean, blendPriority: int, speed: Number}
      private var customGroundMeta_:Dictionary = new Dictionary();
      // Maps typeCode → {id: originalCustomId, objectPixels: base64, objectClass: String, objectSize: int}
      private var customObjectMeta_:Dictionary = new Dictionary();
      // Maps tile position "x,y" → {blocked: Boolean, blendPriority: int, speed: Number}
      private var tileProperties_:Dictionary = new Dictionary();
      //editor8182381 — Next type code for custom grounds loaded from JM
      private var nextCustomGroundType_:uint = 0x8000;

      private var _search:TextInputField;

      public var returnButton_:TitleMenuOption;

      public var container:Sprite;
      
      public function EditingScreen()
      {
         super();
         //editor8182381 — Build verification trace
         trace("[Editor] === EditingScreen INITIALIZED (build v2) ===");
         this._search = new TextInputField("", false, "", "Search");
         this._search.x = 550;
         this._search.y = 6;
         addChild(this._search);
         this.json = StaticInjectorContext.getInjector().getInstance(JsonParser);
         this.commandMenu_ = new MECommandMenu();
         this.commandMenu_.x = 15;
         this.commandMenu_.y = MAP_Y;
         this.commandMenu_.addEventListener(CommandEvent.UNDO_COMMAND_EVENT,this.onUndo);
         this.commandMenu_.addEventListener(CommandEvent.REDO_COMMAND_EVENT,this.onRedo);
         this.commandMenu_.addEventListener(CommandEvent.CLEAR_COMMAND_EVENT,this.onClear);
         this.commandMenu_.addEventListener(CommandEvent.LOAD_COMMAND_EVENT,this.onLoad);
         this.commandMenu_.addEventListener(CommandEvent.SAVE_COMMAND_EVENT,this.onSave);
         this.commandMenu_.addEventListener(CommandEvent.TEST_COMMAND_EVENT,this.onTest);
         addChild(this.commandMenu_);
         this.commandQueue_ = new CommandQueue();
         this.meMap_ = new MEMap();
         this.meMap_.addEventListener(TilesEvent.TILES_EVENT,this.onTilesEvent);
         this.meMap_.x = 800 / 2 - MEMap.SIZE / 2;
         this.meMap_.y = MAP_Y;
         addChild(this.meMap_);
         this.infoPane_ = new InfoPane(this.meMap_);
         this.infoPane_.x = 4;
         this.infoPane_.y = 600 - InfoPane.HEIGHT - 10;
         addChild(this.infoPane_);
         this.chooserDrowDown_ = new DropDown(new <String>["Ground","Objects","Regions"],Chooser.WIDTH,26);
         this.chooserDrowDown_.x = this.meMap_.x + MEMap.SIZE + 4;
         this.chooserDrowDown_.y = MAP_Y;
         this.chooserDrowDown_.addEventListener(Event.CHANGE,this.onDropDownChange);
         addChild(this.chooserDrowDown_);
         this.groundChooser_ = new GroundChooser();
         this.groundChooser_.x = this.chooserDrowDown_.x;
         this.groundChooser_.y = this.chooserDrowDown_.y + this.chooserDrowDown_.height + 4;
         this.chooser_ = this.groundChooser_;
         addChild(this.groundChooser_);
         this.SetAllSearch("");
         this.objChooser_ = new ObjectChooser();
         this.objChooser_.x = this.chooserDrowDown_.x;
         this.objChooser_.y = this.chooserDrowDown_.y + this.chooserDrowDown_.height + 4;
         this.regionChooser_ = new RegionChooser();
         this.regionChooser_.x = this.chooserDrowDown_.x;
         this.regionChooser_.y = this.chooserDrowDown_.y + this.chooserDrowDown_.height + 4;
         this.returnButton_ = new TitleMenuOption("back to home", 18, false);
         this.returnButton_.addEventListener(MouseEvent.CLICK, onReturn);
         this.returnButton_.x = 795 - this.returnButton_.width;
         this.returnButton_.y = 4;
         addChild(this.returnButton_);
      }

      private function onReturn(e:Event) : void
      {
         this.returnButton_.removeEventListener(MouseEvent.CLICK, onReturn);
         parent.removeChild(this);

         var setScreen:SetScreenSignal = StaticInjectorContext.injector.getInstance(SetScreenSignal);
         setScreen.dispatch(new TitleView());
      }

      public function get searchStr():String {
         return (this._search.text());
      }

      public function SetAllSearch(item:String) : void
      {
         this._search.removeEventListener(Event.CHANGE, this.onSearchBarChange);
         this._search.inputText_.text = item;
         this._search.addEventListener(Event.CHANGE, this.onSearchBarChange);
      }

      private function onSearchBarChange(evt:Event) : void
      {
         switch (this.chooser_)
         {
            case this.groundChooser_:
               this.groundChooser_.reloadObjects(this.searchStr);
               break;
            case this.objChooser_:
                this.objChooser_.reloadObjects(this.searchStr);
                break;
         }
      }
      
      private function onTilesEvent(event:TilesEvent) : void
      {
         var tile:IntPoint = null;
         var type:int = 0;
         var oldName:String = null;
         var props:EditTileProperties = null;
         tile = event.tiles_[0];
         switch(this.commandMenu_.getCommand())
         {
            case MECommandMenu.DRAW_COMMAND:
               this.addModifyCommandList(event.tiles_,this.chooser_.layer_,this.chooser_.selectedType());
               break;
            case MECommandMenu.ERASE_COMMAND:
               this.addModifyCommandList(event.tiles_,this.chooser_.layer_,-1);
               break;
            case MECommandMenu.SAMPLE_COMMAND:
               type = this.meMap_.getType(tile.x_,tile.y_,this.chooser_.layer_);
               if(type == -1)
               {
                  return;
               }
               this.chooser_.setSelectedType(type);
               this.commandMenu_.setCommand(MECommandMenu.DRAW_COMMAND);
               break;
            case MECommandMenu.EDIT_COMMAND:
               oldName = this.meMap_.getObjectName(tile.x_,tile.y_);
               props = new EditTileProperties(event.tiles_,oldName);
               props.addEventListener(Event.COMPLETE,this.onEditComplete);
               addChild(props);
         }
         this.meMap_.draw();
      }
      
      private function onEditComplete(event:Event) : void
      {
         var props:EditTileProperties = event.currentTarget as EditTileProperties;
         this.addObjectNameCommandList(props.tiles_,props.getObjectName());
      }
      
      private function addModifyCommandList(tiles:Vector.<IntPoint>, layer:int, type:int) : void
      {
         var tile:IntPoint = null;
         var oldType:int = 0;
         var commandList:CommandList = new CommandList();
         for each(tile in tiles)
         {
            oldType = this.meMap_.getType(tile.x_,tile.y_,layer);
            if(oldType != type)
            {
               commandList.addCommand(new MEModifyCommand(this.meMap_,tile.x_,tile.y_,layer,oldType,type));
            }
         }
         if(commandList.empty())
         {
            return;
         }
         this.commandQueue_.addCommandList(commandList);
      }
      
      private function addObjectNameCommandList(tiles:Vector.<IntPoint>, objName:String) : void
      {
         var tile:IntPoint = null;
         var oldName:String = null;
         var commandList:CommandList = new CommandList();
         for each(tile in tiles)
         {
            oldName = this.meMap_.getObjectName(tile.x_,tile.y_);
            if(oldName != objName)
            {
               commandList.addCommand(new MEObjectNameCommand(this.meMap_,tile.x_,tile.y_,oldName,objName));
            }
         }
         if(commandList.empty())
         {
            return;
         }
         this.commandQueue_.addCommandList(commandList);
      }
      
      private function onDropDownChange(event:Event) : void
      {
         switch(this.chooserDrowDown_.getValue())
         {
            case "Ground":
               this.SetAllSearch(this.groundChooser_.getLastSearch());
               SpriteUtil.safeAddChild(this,this.groundChooser_);
               SpriteUtil.safeRemoveChild(this,this.objChooser_);
               SpriteUtil.safeRemoveChild(this,this.regionChooser_);
               this.chooser_ = this.groundChooser_;
               break;
            case "Objects":
               this.SetAllSearch(this.objChooser_.getLastSearch());
               SpriteUtil.safeRemoveChild(this,this.groundChooser_);
               SpriteUtil.safeAddChild(this,this.objChooser_);
               SpriteUtil.safeRemoveChild(this,this.regionChooser_);
               this.chooser_ = this.objChooser_;
               break;
            case "Regions":
               SpriteUtil.safeRemoveChild(this,this.groundChooser_);
               SpriteUtil.safeRemoveChild(this,this.objChooser_);
               SpriteUtil.safeAddChild(this,this.regionChooser_);
               this.chooser_ = this.regionChooser_;
               break;
         }
      }
      
      private function onUndo(event:CommandEvent) : void
      {
         this.commandQueue_.undo();
         this.meMap_.draw();
      }
      
      private function onRedo(event:CommandEvent) : void
      {
         this.commandQueue_.redo();
         this.meMap_.draw();
      }
      
      private function onClear(event:CommandEvent) : void
      {
         var tile:IntPoint = null;
         var oldTile:METile = null;
         var tiles:Vector.<IntPoint> = this.meMap_.getAllTiles();
         var commandList:CommandList = new CommandList();
         for each(tile in tiles)
         {
            oldTile = this.meMap_.getTile(tile.x_,tile.y_);
            if(oldTile != null)
            {
               commandList.addCommand(new MEClearCommand(this.meMap_,tile.x_,tile.y_,oldTile));
            }
         }
         if(commandList.empty())
         {
            return;
         }
         this.commandQueue_.addCommandList(commandList);
         this.meMap_.draw();
         this.filename_ = null;
      }
      
      private function createMapJSON() : String
      {
         var xi:int = 0;
         var tile:METile = null;
         var entry:Object = null;
         var entryJSON:String = null;
         var index:int = 0;
         var bounds:Rectangle = this.meMap_.getTileBounds();
         if(bounds == null)
         {
            trace("[Editor] createMapJSON: no tile bounds, returning null");
            return null;
         }
         //editor8182381 — Debug: log save/test dimensions and custom tile counts
         trace("[Editor] createMapJSON: bounds=" + bounds.x + "," + bounds.y + " " + bounds.width + "x" + bounds.height);
         var customGroundCount:int = 0;
         var customObjCount:int = 0;
         var jm:Object = {};
         jm["width"] = int(bounds.width);
         jm["height"] = int(bounds.height);
         var dict:Object = {};
         var entries:Array = [];
         var byteArray:ByteArray = new ByteArray();
         for(var yi:int = bounds.y; yi < bounds.bottom; yi++)
         {
            for(xi = bounds.x; xi < bounds.right; xi++)
            {
               tile = this.meMap_.getTile(xi,yi);
               //editor8182381 — Use position-aware entry builder for custom tile round-trip
               entry = this.getEntryWithPos(tile, xi, yi);
               entryJSON = this.json.stringify(entry);
               if(!dict.hasOwnProperty(entryJSON))
               {
                  index = entries.length;
                  dict[entryJSON] = index;
                  entries.push(entry);
                  //editor8182381 — Debug: log new dict entries with custom data
                  if (entry.hasOwnProperty("groundPixels"))
                  {
                     customGroundCount++;
                     trace("[Editor] Dict[" + index + "] custom ground: " + entry["ground"] + " pixels=" + String(entry["groundPixels"]).substr(0,30) + "...");
                  }
                  if (entry.hasOwnProperty("objs"))
                  {
                     var eObjs:Array = entry["objs"];
                     for each (var eObj:Object in eObjs)
                     {
                        if (eObj.hasOwnProperty("objectPixels"))
                        {
                           customObjCount++;
                           trace("[Editor] Dict[" + index + "] custom obj: " + eObj["id"] + " class=" + eObj["objectClass"]);
                        }
                     }
                  }
               }
               else
               {
                  index = dict[entryJSON];
               }
               byteArray.writeShort(index);
            }
         }
         jm["dict"] = entries;
         byteArray.compress();
         jm["data"] = Base64.encodeByteArray(byteArray);
         trace("[Editor] createMapJSON done: " + entries.length + " dict entries, " + customGroundCount + " custom grounds, " + customObjCount + " custom objs");
         var result:String = this.json.stringify(jm);
         trace("[Editor] JM output length: " + result.length + " chars");
         return result;
      }
      
      private function onSave(event:CommandEvent) : void
      {
         trace("[Editor] onSave triggered");
         var mapJSON:String = this.createMapJSON();
         if(mapJSON == null)
         {
            trace("[Editor] onSave: mapJSON is null (no tiles?)");
            return;
         }
         trace("[Editor] onSave: saving " + mapJSON.length + " chars as " + (this.filename_ == null ? "map.jm" : this.filename_));
         new FileReference().save(mapJSON,this.filename_ == null?"map.jm":this.filename_);
      }
      
      //editor8182381 — Enhanced getEntry: includes custom ground/object pixel data and properties
      private function getEntryWithPos(tile:METile, tileX:int, tileY:int) : Object
      {
         var types:Vector.<int> = null;
         var id:String = null;
         var obj:Object = null;
         var entry:Object = {};
         if(tile != null)
         {
            types = tile.types_;
            if(types[Layer.GROUND] != -1)
            {
               var gType:int = types[Layer.GROUND];
               id = GroundLibrary.getIdFromType(gType);
               entry["ground"] = id;
               //editor8182381 — Include groundPixels for custom ground tiles
               if (this.customGroundMeta_[gType] != null)
               {
                  var gMeta:Object = this.customGroundMeta_[gType];
                  entry["ground"] = gMeta.id;
                  entry["groundPixels"] = gMeta.groundPixels;
               }
            }
            //editor8182381 — Include tile properties if they exist
            var propKey:String = tileX + "," + tileY;
            if (this.tileProperties_[propKey] != null)
            {
               var tProps:Object = this.tileProperties_[propKey];
               if (tProps.blocked == true) entry["blocked"] = true;
               if (tProps.blendPriority != null && tProps.blendPriority != -1) entry["blendPriority"] = tProps.blendPriority;
               if (tProps.speed != null && tProps.speed != 1.0) entry["speed"] = tProps.speed;
            }
            if(types[Layer.OBJECT] != -1)
            {
               var oType:int = types[Layer.OBJECT];
               id = ObjectLibrary.getIdFromType(oType);
               obj = {"id":id};
               if(tile.objName_ != null)
               {
                  obj["name"] = tile.objName_;
               }
               //editor8182381 — Include objectPixels for custom objects
               if (this.customObjectMeta_[oType] != null)
               {
                  var oMeta:Object = this.customObjectMeta_[oType];
                  obj["id"] = oMeta.id;
                  obj["objectPixels"] = oMeta.objectPixels;
                  obj["objectClass"] = oMeta.objectClass;
                  obj["objectSize"] = oMeta.objectSize;
               }
               entry["objs"] = [obj];
            }
            if(types[Layer.REGION] != -1)
            {
               id = RegionLibrary.getIdFromType(types[Layer.REGION]);
               entry["regions"] = [{"id":id}];
            }
         }
         return entry;
      }
      
      private function onLoad(event:CommandEvent) : void
      {
         trace("[Editor] onLoad triggered");
         try
         {
            //editor8182381 — Use AIR native File API instead of FileReference (fixes Error #3003)
            var file:File = File.desktopDirectory;
            trace("[Editor] Desktop dir: " + file.nativePath);
            file.addEventListener(Event.SELECT, this.onAirFileSelect);
            file.browseForOpen("Select JM file", [new FileFilter("JSON Map (*.jm, *.json)", "*.jm;*.json")]);
            trace("[Editor] browseForOpen called OK");
         }
         catch(e:Error)
         {
            trace("[Editor] onLoad FAILED: " + e.message + " id=" + e.errorID + "\n" + e.getStackTrace());
         }
      }

      //editor8182381 — AIR native file select + read (replaces FileReference.load)
      private function onAirFileSelect(event:Event) : void
      {
         var file:File = event.target as File;
         file.removeEventListener(Event.SELECT, this.onAirFileSelect);
         trace("[Editor] File selected: " + file.nativePath + " size=" + file.size);
         try
         {
            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            var content:String = stream.readUTFBytes(stream.bytesAvailable);
            stream.close();
            this.filename_ = file.name;
            trace("[Editor] File read OK, length=" + content.length);
            this.processJmContent(content);
         }
         catch(e:Error)
         {
            trace("[Editor] File read FAILED: " + e.message + "\n" + e.getStackTrace());
         }
      }
      
      //editor8182381 — Legacy FileReference callback (kept for compatibility)
      private function onFileLoadComplete(event:Event) : void
      {
         var loadedFile:FileReference = event.target as FileReference;
         this.filename_ = loadedFile.name;
         this.processJmContent(loadedFile.data.toString());
      }

      //editor8182381 — Process JM content string (shared by AIR File and FileReference paths)
      private function processJmContent(content:String) : void
      {
         var type:int = 0;
         var xi:int = 0;
         var entry:Object = null;
         var objs:Array = null;
         var regions:Array = null;
         var obj:Object = null;
         var region:Object = null;
         //editor8182381 — Wrap entire load in try/catch to capture crash errors
         try
         {
         var jm:Object = this.json.parse(content);
         var w:int = jm["width"];
         var h:int = jm["height"];
         var bounds:Rectangle = new Rectangle(int(MEMap.NUM_SQUARES / 2 - w / 2),int(MEMap.NUM_SQUARES / 2 - h / 2),w,h);
         this.meMap_.clear();
         this.commandQueue_.clear();
         //editor8182381 — Reset custom tile tracking
         this.customGroundMeta_ = new Dictionary();
         this.customObjectMeta_ = new Dictionary();
         this.tileProperties_ = new Dictionary();
         this.nextCustomGroundType_ = 0x8000;
         //editor8182381 — Clear any previous custom entries
         GroundLibrary.customGroundBitmaps_ = new Dictionary();
         //editor8182381 — Pre-register custom grounds from dict so they get type codes before tile placement
         var dict:Array = jm["dict"];
         var customGroundIdToType:Dictionary = new Dictionary();
         var customObjIdToType:Dictionary = new Dictionary();
         var nextCustomObjType:uint = 0x9000;
         trace("[Editor] Loading JM: " + w + "x" + h + " dict=" + dict.length);
         for (var di:int = 0; di < dict.length; di++)
         {
            var dictEntry:Object = dict[di];
            //editor8182381 — Register custom ground tiles
            if (dictEntry.hasOwnProperty("ground"))
            {
               var groundId:String = dictEntry["ground"];
               if (groundId.indexOf("custom_") == 0 && dictEntry.hasOwnProperty("groundPixels") && customGroundIdToType[groundId] == null)
               {
                  //editor8182381 — Use int from the start to avoid int/uint Dictionary key mismatch
                  var gTypeCode:int = int(this.nextCustomGroundType_++);
                  customGroundIdToType[groundId] = gTypeCode;
                  var gPixelsB64:String = dictEntry["groundPixels"];
                  var gPixelsBA:ByteArray = Base64.decodeToByteArray(gPixelsB64);
                  var noWalk:Boolean = dictEntry.hasOwnProperty("blocked") && dictEntry["blocked"] == true;
                  var bp:int = dictEntry.hasOwnProperty("blendPriority") ? int(dictEntry["blendPriority"]) : -1;
                  var spd:Number = dictEntry.hasOwnProperty("speed") ? Number(dictEntry["speed"]) : 1.0;
                  //editor8182381 — Build BitmapData inline from pixel data
                  var gBmd:BitmapData = new BitmapData(8, 8, false, 0x000000);
                  if (gPixelsBA != null && gPixelsBA.length >= 192)
                  {
                     gPixelsBA.position = 0;
                     for (var py:int = 0; py < 8; py++)
                     {
                        for (var px:int = 0; px < 8; px++)
                        {
                           var pr:int = gPixelsBA.readUnsignedByte();
                           var pg:int = gPixelsBA.readUnsignedByte();
                           var pb:int = gPixelsBA.readUnsignedByte();
                           gBmd.setPixel(px, py, (pr << 16) | (pg << 8) | pb);
                        }
                     }
                  }
                  else
                  {
                     trace("[Editor] WARNING: groundPixels len=" + (gPixelsBA != null ? gPixelsBA.length : "null"));
                  }
                  //editor8182381 — Create proper GroundProperties (not shared defaultProps_) so getIdFromType works
                  var dummyXml:XML = <Ground type={gTypeCode} id={groundId} />;
                  var gProps:GroundProperties = new GroundProperties(dummyXml);
                  gProps.noWalk_ = noWalk;
                  gProps.blendPriority_ = bp;
                  gProps.speed_ = spd;
                  GroundLibrary.propsLibrary_[gTypeCode] = gProps;
                  GroundLibrary.idToType_[groundId] = gTypeCode;
                  //editor8182381 — Store BitmapData in direct lookup (bypasses TextureDataConcrete completely)
                  GroundLibrary.customGroundBitmaps_[gTypeCode] = gBmd;
                  //editor8182381 — Store metadata for round-trip save
                  this.customGroundMeta_[gTypeCode] = {
                     id: groundId,
                     groundPixels: gPixelsB64,
                     blocked: noWalk,
                     blendPriority: bp,
                     speed: spd
                  };
                  trace("[Editor] Registered ground: " + groundId.substr(0,40) + " type=" + gTypeCode);
               }
            }
            //editor8182381 — Register custom objects
            if (dictEntry.hasOwnProperty("objs") && dictEntry["objs"] is Array)
            {
               var dictObjs:Array = dictEntry["objs"];
               for each (var dObj:Object in dictObjs)
               {
                  if (dObj.hasOwnProperty("objectPixels") && dObj.hasOwnProperty("id") && customObjIdToType[dObj["id"]] == null)
                  {
                     var oTypeCode:int = int(nextCustomObjType++);
                     customObjIdToType[dObj["id"]] = oTypeCode;
                     var oPixelsB64:String = dObj["objectPixels"];
                     var oPixelsBA:ByteArray = Base64.decodeToByteArray(oPixelsB64);
                     var oSize:int = dObj.hasOwnProperty("objectSize") ? int(dObj["objectSize"]) : 8;
                     var oClass:String = dObj.hasOwnProperty("objectClass") ? String(dObj["objectClass"]) : "Object";
                     var classFlag:int = 0;
                     if (oClass == "Destructible") classFlag = 1;
                     else if (oClass == "Decoration") classFlag = 2;
                     else if (oClass == "Wall") classFlag = 3;
                     else if (oClass == "Blocker") classFlag = 4;
                     if (oSize > 0 && oPixelsBA != null && oPixelsBA.length >= oSize * oSize * 3)
                        GroundLibrary.loadBinaryCustomObject(uint(oTypeCode), oPixelsBA, oSize, classFlag);
                     //editor8182381 — Register in ObjectLibrary idToType_
                     ObjectLibrary.idToType_[dObj["id"]] = oTypeCode;
                     this.customObjectMeta_[oTypeCode] = {
                        id: dObj["id"],
                        objectPixels: oPixelsB64,
                        objectClass: oClass,
                        objectSize: oSize
                     };
                     trace("[Editor] Registered object: " + String(dObj["id"]).substr(0,40) + " type=" + oTypeCode);
                  }
               }
            }
         }
         trace("[Editor] Dict scan done. Custom grounds: " + (int(this.nextCustomGroundType_) - 0x8000) + " objects: " + (int(nextCustomObjType) - 0x9000));
         var byteArray:ByteArray = Base64.decodeToByteArray(jm["data"]);
         byteArray.uncompress();
         trace("[Editor] Placing tiles in bounds: " + bounds.x + "," + bounds.y + " to " + bounds.right + "," + bounds.bottom);
         for(var yi:int = bounds.y; yi < bounds.bottom; yi++)
         {
            for(xi = bounds.x; xi < bounds.right; xi++)
            {
               entry = dict[byteArray.readShort()];
               if(entry.hasOwnProperty("ground"))
               {
                  var gId:String = entry["ground"];
                  //editor8182381 — Custom tiles use local dedup dictionary, standard tiles use idToType_
                  if (gId.indexOf("custom_") == 0 && customGroundIdToType[gId] != null)
                  {
                     type = int(customGroundIdToType[gId]);
                     this.meMap_.modifyTile(xi,yi,Layer.GROUND,type);
                  }
                  else if (GroundLibrary.idToType_[gId] != null)
                  {
                     type = GroundLibrary.idToType_[gId];
                     this.meMap_.modifyTile(xi,yi,Layer.GROUND,type);
                  }
                  else
                  {
                     trace("[Editor] ERROR: Unknown ground: " + gId);
                  }
               }
               //editor8182381 — Store per-tile properties for round-trip
               if (entry.hasOwnProperty("blocked") || entry.hasOwnProperty("blendPriority") || entry.hasOwnProperty("speed"))
               {
                  var tProps:Object = {};
                  if (entry.hasOwnProperty("blocked")) tProps.blocked = entry["blocked"];
                  if (entry.hasOwnProperty("blendPriority")) tProps.blendPriority = entry["blendPriority"];
                  if (entry.hasOwnProperty("speed")) tProps.speed = entry["speed"];
                  this.tileProperties_[xi + "," + yi] = tProps;
               }
               objs = entry["objs"];
               if(objs != null)
               {
                  for each(obj in objs)
                  {
                     //editor8182381 — Skip invisible blockers
                     if (obj.hasOwnProperty("objectClass") && obj["objectClass"] == "Blocker" && !obj.hasOwnProperty("objectPixels"))
                        continue;
                     if(!ObjectLibrary.idToType_.hasOwnProperty(obj["id"]))
                     {
                        trace("[Editor] ERROR: Unknown object: " + obj["id"]);
                     }
                     else
                     {
                        type = ObjectLibrary.idToType_[obj["id"]];
                        this.meMap_.modifyTile(xi,yi,Layer.OBJECT,type);
                        if(obj.hasOwnProperty("name"))
                        {
                           this.meMap_.modifyObjectName(xi,yi,obj["name"]);
                        }
                     }
                  }
               }
               regions = entry["regions"];
               if(regions != null)
               {
                  for each(region in regions)
                  {
                     if (RegionLibrary.idToType_[region["id"]] != null)
                     {
                        type = RegionLibrary.idToType_[region["id"]];
                        this.meMap_.modifyTile(xi,yi,Layer.REGION,type);
                     }
                  }
               }
            }
         }
         trace("[Editor] All tiles placed, calling draw()");
         this.meMap_.draw();
         trace("[Editor] JM load complete!");
         }
         catch (e:Error)
         {
            trace("[Editor] CRASH in onFileLoadComplete: " + e.message + "\n" + e.getStackTrace());
         }
      }
      
      private function onFileLoadIOError(event:IOErrorEvent) : void
      {
         trace("[Editor] IO Error loading file: " + event.text + " errorID=" + event.errorID);
      }
      
      private function onTest(event:Event) : void
      {
         trace("[Editor] onTest triggered — building JM for server test");
         var mapJSON:String = this.createMapJSON();
         if (mapJSON != null)
         {
            trace("[Editor] onTest: dispatching MapTestEvent, JM length=" + mapJSON.length);
         }
         else
         {
            trace("[Editor] onTest: mapJSON is null, no tiles to test");
         }
         dispatchEvent(new MapTestEvent(mapJSON));
      }
   }
}

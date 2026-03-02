package realmeditor.editor
{
   import com.brokenfunction.json.decodeJson;
   import com.brokenfunction.json.encodeJson;
   import com.hurlant.util.Base64;
   import flash.display.BitmapData; //editor8182381 — needed for custom tile BitmapData creation
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filesystem.File; //editor8182381 — AIR File API (replaces FileReference.load)
   import flash.filesystem.FileMode; //editor8182381
   import flash.filesystem.FileStream; //editor8182381
   import flash.net.FileFilter;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import realmeditor.assets.GroundLibrary;
   import realmeditor.assets.GroundProperties; //editor8182381 — for custom ground tile properties
   import realmeditor.assets.ObjectLibrary;
   import realmeditor.assets.ObjectProperties; //editor8182381 — for custom object tile properties
   import realmeditor.assets.RegionLibrary;
   import realmeditor.assets.TextureData; //editor8182381 — for custom tile texture registration
   import realmeditor.editor.ui.TileMapView;
   import realmeditor.util.BinaryUtils;

   //editor8182381 — MapData with custom tile support and AIR File API
   public class MapData extends EventDispatcher
   {

      public var tileDict:Dictionary;

      public var mapWidth:int;

      public var mapHeight:int;

      private var loadedFile:FileReference;

      public var mapName:String;

      private var tileMap:TileMapView;

      public var savedChanges:Boolean;

      //editor8182381 — Per-tile custom metadata for round-trip preservation
      //editor8182381 — Key = tileIndex (x + y * mapWidth), stores extra JM fields
      public var tileMetadata:Dictionary;

      //editor8182381 — Custom type code counters for this map
      private var nextCustomGroundType:int = 0x8000;
      private var nextCustomObjType:int = 0x9000;

      //editor8182381 — Track custom type codes for ground/object registered by this load
      private var customGroundTypes:Vector.<int>;
      private var customObjTypes:Vector.<int>;

      //editor8182381 — Map from ground/object type code to its dict entry data (for re-export)
      public var customGroundData:Dictionary;  // typeCode → { ground, groundPixels, blocked, speed, blendPriority }
      public var customObjData:Dictionary;     // typeCode → { id, objectPixels, objectSize, objectClass }

      //editor8182381 — Map from JM dict index → custom ground type code (for tile placement with per-entry properties)
      private var dictGroundTypeMap:Dictionary;

      //editor8182381 — Constructor initializes custom tile tracking fields
      public function MapData()
      {
         super();
         this.tileMetadata = new Dictionary(); //editor8182381
         this.customGroundTypes = new Vector.<int>(); //editor8182381
         this.customObjTypes = new Vector.<int>(); //editor8182381
         this.customGroundData = new Dictionary(); //editor8182381
         this.customObjData = new Dictionary(); //editor8182381
         this.dictGroundTypeMap = new Dictionary(); //editor8182381
      }

      private static function onFileLoadIOError(e:Event) : void
      {
         trace("JM Map load error: " + e);
      }

      public function newMap(tileMap:TileMapView, name:String, width:int, height:int) : void
      {
         var yi:int = 0;
         var xi:int = 0;
         this.savedChanges = false;
         //editor8182381 — Remove old listener before adding new one to prevent accumulation
         if (this.tileMap != null)
            this.tileMap.removeEventListener("MapChanged", this.onMapChanged);
         this.tileMap = tileMap;
         this.tileMap.addEventListener("MapChanged",this.onMapChanged);
         this.mapName = name;
         this.mapWidth = width;
         this.mapHeight = height;
         this.tileMap.setup(this);
         this.dispatchEvent(new Event("MapLoadBegin"));
         this.tileDict = new Dictionary();
         for(yi = 0; yi < height; )
         {
            for(xi = 0; xi < width; )
            {
               tileMap.loadTileFromMap(null,xi,yi);
               xi++;
            }
            yi++;
         }
         this.dispatchEvent(new Event("MapLoadEnd"));
      }

      //editor8182381 — Save uses AIR FileMode.WRITE for autoSave
      public function save(wmap:Boolean, autoSave:Boolean = false) : void
      {
         var saveFile:FileReference = null;
         var autoSaveFolder:File = null;
         var file:File = null;
         var fs:FileStream = null;
         if(this.tileDict == null || this.tileDict.length == 0)
         {
            return;
         }
         var mapBytes:ByteArray = wmap ? this.exportWmap() : this.exportJson();
         if(mapBytes == null || mapBytes.length == 0)
         {
            return;
         }
         var fullMapName:String = this.mapName + (wmap ? ".wmap" : ".jm");
         if(!autoSave)
         {
            saveFile = new FileReference();
            saveFile.addEventListener("select",this.onMapSaved);
            saveFile.save(mapBytes,fullMapName);
         }
         else
         {
            try
            {
               autoSaveFolder = File.applicationStorageDirectory.resolvePath("autoSave"); //editor8182381 — use appStorage instead of workingDirectory
               autoSaveFolder.createDirectory();
               file = autoSaveFolder.resolvePath(fullMapName);
               fs = new FileStream();
               fs.open(file,FileMode.WRITE);
               fs.writeBytes(mapBytes);
               fs.close();
               this.onMapSaved(null);
            }
            catch(e:Error)
            {
               trace("[Editor] Autosave failed: " + e.message);
            }
         }
      }

      //editor8182381 — Remove FileReference listener to prevent leak
      private function onMapSaved(e:Event) : void
      {
         if (e != null && e.target is FileReference)
            FileReference(e.target).removeEventListener("select", this.onMapSaved);
         this.savedChanges = true;
         this.dispatchEvent(new Event("MapSaved"));
      }

      private function onMapChanged(e:Event) : void
      {
         this.savedChanges = false;
      }

      //editor8182381 — Replaced FileReference.load() with AIR native File API to fix Error #3003
      public function load(tileMap:TileMapView) : void
      {
         //editor8182381 — Remove old listener before adding new one to prevent accumulation
         if (this.tileMap != null)
            this.tileMap.removeEventListener("MapChanged", this.onMapChanged);
         this.tileMap = tileMap;
         this.tileMap.addEventListener("MapChanged",this.onMapChanged);
         trace("[Editor] load() — opening file browser");
         try
         {
            var file:File = File.desktopDirectory;
            file.addEventListener(Event.SELECT, this.onAirFileSelect);
            file.addEventListener(Event.CANCEL, this.onAirFileCancel); //editor8182381 — prevent listener leak on cancel
            file.browseForOpen("Select Map File", [new FileFilter("Map Files (*.jm, *.wmap)", "*.jm;*.wmap")]);
         }
         catch(e:Error)
         {
            trace("[Editor] load() FAILED: " + e.message);
         }
      }

      //editor8182381 — Remove file dialog listeners to prevent leak
      private function onAirFileCancel(e:Event) : void
      {
         var file:File = e.target as File;
         file.removeEventListener(Event.SELECT, this.onAirFileSelect);
         file.removeEventListener(Event.CANCEL, this.onAirFileCancel);
      }

      //editor8182381 — AIR File API file select handler
      private function onAirFileSelect(e:Event) : void
      {
         var file:File = e.target as File;
         file.removeEventListener(Event.SELECT, this.onAirFileSelect);
         file.removeEventListener(Event.CANCEL, this.onAirFileCancel);
         trace("[Editor] File selected: " + file.nativePath + " size=" + file.size);
         try
         {
            var fs:FileStream = new FileStream();
            fs.open(file, FileMode.READ);
            var data:ByteArray = new ByteArray();
            fs.readBytes(data, 0, fs.bytesAvailable);
            fs.close();
            trace("[Editor] File read OK, bytes=" + data.length);

            // Determine file type from name
            var fileName:String = file.name;
            var wmapIdx:int = fileName.indexOf(".wmap");
            if (wmapIdx != -1)
            {
               this.mapName = fileName.substr(0, wmapIdx);
               this.savedChanges = true;
               this.loadWMap(data);
               return;
            }
            var jmIdx:int = fileName.indexOf(".jm");
            if (jmIdx != -1)
            {
               this.mapName = fileName.substr(0, jmIdx);
            }
            else
            {
               this.mapName = fileName;
            }
            this.savedChanges = true;
            data.position = 0;
            var content:String = data.readUTFBytes(data.length);
            this.loadJmFromString(content);
         }
         catch(e:Error)
         {
            trace("[Editor] File read FAILED: " + e.message + "\n" + e.getStackTrace());
         }
      }

      //editor8182381 — JM loading with custom tile support
      private function loadJmFromString(content:String) : void
      {
         var yi:int = 0;
         var xi:int = 0;
         var entry:Object = null;
         var groundType:int = 0;
         var objs:Array = null;
         var objType:int = 0;
         var regions:Array = null;
         var regType:int = 0;

         //editor8182381 — Cleanup previous custom tiles to prevent memory leaks
         this.cleanupCustomTiles();

         //editor8182381 — Parse JM JSON, strip BOM if present
         if (content.charCodeAt(0) == 0xFEFF)
            content = content.substr(1);
         trace("[Editor] JM first char: 0x" + content.charCodeAt(0).toString(16) + " '" + content.charAt(0) + "' len=" + content.length);
         var jm:Object = decodeJson(content);

         this.mapWidth = jm["width"];
         this.mapHeight = jm["height"];
         trace("[Editor] JM dimensions: " + this.mapWidth + "x" + this.mapHeight);
         this.tileMap.setup(this);
         this.dispatchEvent(new Event("MapLoadBegin"));
         var dict:Array = jm["dict"];
         var byteArray:ByteArray = Base64.decodeToByteArray(jm["data"]);
         byteArray.uncompress();
         this.tileDict = new Dictionary();
         this.tileMetadata = new Dictionary();

         //editor8182381 — First pass: register any custom ground/object tiles from dict
         this.registerCustomTilesFromDict(dict);

         trace("[Editor] Placing tiles...");
         for(yi = 0; yi < this.mapHeight; )
         {
            for(xi = 0; xi < this.mapWidth; )
            {
               var dictIdx:int = byteArray.readShort();
               entry = dict[dictIdx];
               if(entry == null)
               {
                  trace("NULL ENTRY");
                  this.tileMap.loadTileFromMap(null,xi,yi);
               }
               else
               {
                  if(entry.hasOwnProperty("ground"))
                  {
                     //editor8182381 — Use dictGroundTypeMap for custom tiles (preserves per-entry properties)
                     if (this.dictGroundTypeMap.hasOwnProperty(dictIdx))
                     {
                        groundType = int(this.dictGroundTypeMap[dictIdx]);
                        this.updateTileGround(xi,yi,groundType);
                     }
                     else
                     {
                        var groundId:String = entry["ground"];
                        if(GroundLibrary.idToType_.hasOwnProperty(groundId))
                        {
                           groundType = int(GroundLibrary.idToType_[groundId]);
                           this.updateTileGround(xi,yi,groundType);
                        }
                        else
                        {
                           trace("[Editor] WARNING: Unknown ground: " + groundId);
                        }
                     }
                  }
                  objs = entry["objs"];
                  if(objs != null)
                  {
                     for each(var obj:Object in objs)
                     {
                        var objId:String = obj["id"];
                        if(!ObjectLibrary.idToType_.hasOwnProperty(objId))
                        {
                           trace("[Editor] WARNING: Unknown object: " + objId);
                        }
                        else
                        {
                           objType = int(ObjectLibrary.idToType_[objId]);
                           this.updateTileObject(xi,yi,objType);
                           if(obj.hasOwnProperty("name"))
                           {
                              this.updateTileObjectName(xi,yi,obj["name"]);
                           }
                        }
                     }
                  }
                  regions = entry["regions"];
                  if(regions != null)
                  {
                     for each(var region:Object in regions)
                     {
                        if(RegionLibrary.idToType_.hasOwnProperty(region["id"]))
                        {
                           regType = int(RegionLibrary.idToType_[region["id"]]);
                           this.updateTileRegion(xi,yi,regType);
                        }
                     }
                  }
                  this.tileMap.loadTileFromMap(getTile(xi,yi),xi,yi);
               }
               xi++;
            }
            yi++;
         }
         trace("[Editor] JM load complete!");
         this.dispatchEvent(new Event("MapLoadEnd"));
      }

      //editor8182381 — Register custom ground and object tiles from JM dict entries
      //editor8182381 — Each dict entry with different properties gets a unique type code
      private function registerCustomTilesFromDict(dict:Array) : void
      {
         var customGroundCount:int = 0;
         var customObjCount:int = 0;
         //editor8182381 — Dedup by (groundId + property combo) so same pixels + same props share a type
         var groundDedupMap:Dictionary = new Dictionary(); // dedupKey → typeCode

         for (var i:int = 0; i < dict.length; i++)
         {
            var entry:Object = dict[i];
            if (entry == null) continue;

            //editor8182381 — Custom ground tiles: each unique (ground + props) combo gets its own type
            if (entry.hasOwnProperty("ground"))
            {
               var groundId:String = entry["ground"];
               var hasPixels:Boolean = entry.hasOwnProperty("groundPixels");
               var isCustom:Boolean = hasPixels || groundId.indexOf("custom_") == 0;
               if (isCustom)
               {
                  // Build dedup key: groundId + blocked + speed + blendPriority
                  var gBlocked:Boolean = entry.hasOwnProperty("blocked") && entry["blocked"] === true;
                  var gSpeed:* = entry.hasOwnProperty("speed") ? entry["speed"] : null;
                  var gBlend:* = entry.hasOwnProperty("blendPriority") ? entry["blendPriority"] : null;
                  var dedupKey:String = groundId + "|" + (gBlocked ? "1" : "0") + "|" + gSpeed + "|" + gBlend;

                  if (groundDedupMap.hasOwnProperty(dedupKey))
                  {
                     // Already registered this combo — store mapping for tile placement
                     this.dictGroundTypeMap[i] = int(groundDedupMap[dedupKey]);
                  }
                  else
                  {
                     var gTypeCode:int = this.nextCustomGroundType++;
                     var gPixelsB64:String = hasPixels ? entry["groundPixels"] : null;
                     //editor8182381 — Guard against null/empty groundPixels (property exists but value is null)
                     var gPixelsBA:ByteArray = (gPixelsB64 != null && gPixelsB64.length > 0) ? Base64.decodeToByteArray(gPixelsB64) : null;

                     if (gPixelsBA != null && gPixelsBA.length >= 192)
                     {
                        var gBmd:BitmapData = new BitmapData(8, 8, false, 0x000000);
                        gPixelsBA.position = 0;
                        for (var gy:int = 0; gy < 8; gy++)
                        {
                           for (var gx:int = 0; gx < 8; gx++)
                           {
                              var r:int = gPixelsBA.readUnsignedByte();
                              var g:int = gPixelsBA.readUnsignedByte();
                              var b:int = gPixelsBA.readUnsignedByte();
                              gBmd.setPixel(gx, gy, (r << 16) | (g << 8) | b);
                           }
                        }

                        //editor8182381 — Use unique ID per type code so different property combos don't collide in idToType_
                        var uniqueGndId:String = groundId + "_t" + gTypeCode;
                        var gXml:XML = <Ground type={gTypeCode} id={uniqueGndId} />;
                        var gProps:GroundProperties = new GroundProperties(gXml);

                        if (gBlocked) gProps.noWalk_ = true;
                        if (gSpeed != null) gProps.speed_ = Number(gSpeed);
                        if (gBlend != null) gProps.blendPriority_ = int(gBlend);

                        GroundLibrary.propsLibrary_[gTypeCode] = gProps;
                        GroundLibrary.xmlLibrary_[gTypeCode] = gXml;
                        GroundLibrary.idToType_[uniqueGndId] = gTypeCode;

                        var gTd:TextureData = new TextureData(gXml);
                        gTd.texture_ = gBmd;
                        GroundLibrary.typeToTextureData_[gTypeCode] = gTd;

                        this.customGroundTypes.push(gTypeCode);
                        groundDedupMap[dedupKey] = gTypeCode;
                        this.dictGroundTypeMap[i] = gTypeCode;

                        //editor8182381 — Store original groundId (not uniqueGndId) for re-export to JM
                        this.customGroundData[gTypeCode] = {
                           "ground": groundId,
                           "groundPixels": gPixelsB64,
                           "blocked": gBlocked ? true : null,
                           "speed": gSpeed,
                           "blendPriority": gBlend
                        };

                        customGroundCount++;
                        trace("[Editor] Registered custom ground: " + groundId + " props=(" + (gBlocked?"blocked ":"") + (gSpeed!=null?"spd="+gSpeed+" ":"") + (gBlend!=null?"bp="+gBlend:"") + ") → type=" + gTypeCode);
                     }
                     else
                     {
                        trace("[Editor] WARNING: Invalid groundPixels for " + groundId);
                     }
                  }
               }
            }

            //editor8182381 — Custom object tiles: have objectPixels field
            if (entry.hasOwnProperty("objs") && entry["objs"] is Array)
            {
               var objs:Array = entry["objs"];
               for (var oi:int = 0; oi < objs.length; oi++)
               {
                  var dObj:Object = objs[oi];
                  if (dObj.hasOwnProperty("objectPixels") && dObj.hasOwnProperty("id"))
                  {
                     var oId:String = dObj["id"];
                     if (!ObjectLibrary.idToType_.hasOwnProperty(oId))
                     {
                        var oTypeCode:int = this.nextCustomObjType++;
                        var oPixelsB64:String = dObj["objectPixels"];
                        //editor8182381 — Guard against null/empty objectPixels
                        var oPixelsBA:ByteArray = (oPixelsB64 != null && oPixelsB64.length > 0) ? Base64.decodeToByteArray(oPixelsB64) : null;
                        var oSize:int = dObj.hasOwnProperty("objectSize") ? int(dObj["objectSize"]) : 8;

                        if (oPixelsBA != null && oPixelsBA.length >= oSize * oSize * 3)
                        {
                           var oBmd:BitmapData = new BitmapData(oSize, oSize, false, 0x000000);
                           oPixelsBA.position = 0;
                           for (var oy:int = 0; oy < oSize; oy++)
                           {
                              for (var ox:int = 0; ox < oSize; ox++)
                              {
                                 var or_:int = oPixelsBA.readUnsignedByte();
                                 var og:int = oPixelsBA.readUnsignedByte();
                                 var ob:int = oPixelsBA.readUnsignedByte();
                                 oBmd.setPixel(ox, oy, (or_ << 16) | (og << 8) | ob);
                              }
                           }

                           //editor8182381 — Build XML matching server format
                           var oClass:String = dObj.hasOwnProperty("objectClass") ? dObj["objectClass"] : "GameObject";
                           var is3D:Boolean = (oClass == "Wall" || oClass == "Destructible");
                           var className:String = is3D ? "Wall" : "GameObject";
                           var oXml:XML = <Object type={oTypeCode} id={oId}>
                              <Class>{className}</Class>
                              <Static/>
                           </Object>;

                           ObjectLibrary.xmlLibrary_[oTypeCode] = oXml;
                           ObjectLibrary.propsLibrary_[oTypeCode] = new ObjectProperties(oXml);
                           ObjectLibrary.idToType_[oId] = oTypeCode;

                           var oTd:TextureData = new TextureData(oXml);
                           oTd.texture_ = oBmd;
                           ObjectLibrary.typeToTextureData_[oTypeCode] = oTd;

                           this.customObjTypes.push(oTypeCode);

                           //editor8182381 — Store for re-export
                           this.customObjData[oTypeCode] = {
                              "id": oId,
                              "objectPixels": oPixelsB64,
                              "objectSize": oSize,
                              "objectClass": dObj.hasOwnProperty("objectClass") ? dObj["objectClass"] : null
                           };

                           customObjCount++;
                           trace("[Editor] Registered custom object: " + oId + " → type=" + oTypeCode);
                        }
                     }
                  }
               }
            }
         }
         trace("[Editor] Custom tile registration done: " + customGroundCount + " grounds, " + customObjCount + " objects");
      }

      //editor8182381 — Cleanup custom tiles from previous load to prevent memory leaks
      private function cleanupCustomTiles() : void
      {
         var i:int;
         // Remove custom ground registrations (unique IDs like "groundName_t32768")
         for (i = 0; i < this.customGroundTypes.length; i++)
         {
            var gType:int = this.customGroundTypes[i];
            // Remove from idToType_ — the key is the unique ID stored in xmlLibrary_
            var gXml:XML = GroundLibrary.xmlLibrary_[gType];
            if (gXml != null)
               delete GroundLibrary.idToType_[String(gXml.@id)];
            // Dispose BitmapData
            var gTd:TextureData = GroundLibrary.typeToTextureData_[gType];
            if (gTd != null && gTd.texture_ != null)
               gTd.texture_.dispose();
            delete GroundLibrary.typeToTextureData_[gType];
            delete GroundLibrary.propsLibrary_[gType];
            delete GroundLibrary.xmlLibrary_[gType];
         }
         // Remove custom object registrations
         for (i = 0; i < this.customObjTypes.length; i++)
         {
            var oType:int = this.customObjTypes[i];
            var oId:String = ObjectLibrary.getIdFromType(oType);
            if (oId != null)
               delete ObjectLibrary.idToType_[oId];
            var oTd:TextureData = ObjectLibrary.typeToTextureData_[oType];
            if (oTd != null && oTd.texture_ != null)
               oTd.texture_.dispose();
            delete ObjectLibrary.typeToTextureData_[oType];
            delete ObjectLibrary.propsLibrary_[oType];
            delete ObjectLibrary.xmlLibrary_[oType];
         }
         // Reset counters and tracking
         this.customGroundTypes = new Vector.<int>();
         this.customObjTypes = new Vector.<int>();
         this.customGroundData = new Dictionary();
         this.customObjData = new Dictionary();
         this.nextCustomGroundType = 0x8000;
         this.nextCustomObjType = 0x9000;
         this.tileMetadata = new Dictionary();
         this.dictGroundTypeMap = new Dictionary();
      }

      private function loadWMap(origData:ByteArray) : void
      {
         var i:int = 0;
         var tileType:int = 0;
         var objIdLen:int = 0;
         var objId:String = null;
         var objCfgLen:int = 0;
         var objCfg:String = null;
         var terrainType:int = 0;
         var regionType:int = 0;
         var elevation:int = 0;
         var tile:MapTileData = null;
         var objType:int = 0;
         var y:int = 0;
         var x:int = 0;
         var data:ByteArray = new ByteArray();
         data.writeBytes(origData,1,origData.length - 1);
         var ver:int = int(origData.readUnsignedByte());
         if(ver < 0 || ver > 2)
         {
            trace("INVALID WMAP VERSION");
            return;
         }
         data.uncompress();
         data.endian = "littleEndian";
         var tileCount:int = data.readShort();
         var tiles:Vector.<MapTileData> = new Vector.<MapTileData>(tileCount);
         for(i = 0; i < tileCount; )
         {
            tileType = int(data.readUnsignedShort());
            objIdLen = BinaryUtils.Read7BitEncodedInt(data);
            objId = data.readMultiByte(objIdLen,"utf-8");
            objCfgLen = BinaryUtils.Read7BitEncodedInt(data);
            objCfg = data.readMultiByte(objCfgLen,"utf-8");
            terrainType = int(data.readUnsignedByte());
            regionType = int(data.readUnsignedByte());
            elevation = 0;
            if(ver == 1)
            {
               elevation = int(data.readUnsignedByte());
            }
            (tile = new MapTileData()).groundType = tileType == 65535 ? -1 : tileType;
            if(objId != "" && !ObjectLibrary.idToType_.hasOwnProperty(objId))
            {
               trace("ERROR: Unable to find: " + objId);
            }
            else
            {
               objType = int(ObjectLibrary.idToType_[objId]);
               tile.objType = objType;
            }
            tile.objCfg = objCfg;
            tile.terrainType = terrainType;
            tile.regType = regionType;
            tile.elevation = elevation;
            tiles[i] = tile;
            i++;
         }
         this.mapWidth = data.readInt();
         this.mapHeight = data.readInt();
         this.tileMap.setup(this);
         this.dispatchEvent(new Event("MapLoadBegin"));
         this.tileDict = new Dictionary();
         for(y = 0; y < this.mapHeight; )
         {
            for(x = 0; x < this.mapWidth; )
            {
               tile = tiles[data.readShort()].clone();
               if(ver == 2)
               {
                  tile.elevation = data.readUnsignedByte();
               }
               this.tileDict[x + y * this.mapWidth] = tile;
               this.tileMap.loadTileFromMap(tile,x,y);
               x++;
            }
            y++;
         }
         this.dispatchEvent(new Event("MapLoadEnd"));
      }

      public function getTile(x:int, y:int) : MapTileData
      {
         var index:int = x + y * this.mapWidth;
         return this.tileDict[index];
      }

      private function createTile(x:int, y:int) : MapTileData
      {
         var index:int = x + y * this.mapWidth;
         var tile:MapTileData = new MapTileData();
         this.tileDict[index] = tile;
         return tile;
      }

      private function updateTileGround(x:int, y:int, groundType:int) : void
      {
         var tile:MapTileData;
         (tile = this.getTile(x,y) || createTile(x,y)).groundType = groundType;
      }

      private function updateTileObject(x:int, y:int, objType:int) : void
      {
         var tile:MapTileData;
         (tile = this.getTile(x,y) || createTile(x,y)).objType = objType;
      }

      private function updateTileObjectName(x:int, y:int, objName:String) : void
      {
         var tile:MapTileData;
         (tile = this.getTile(x,y) || createTile(x,y)).objCfg = objName;
      }

      private function updateTileRegion(x:int, y:int, regType:int) : void
      {
         var tile:MapTileData;
         (tile = this.getTile(x,y) || createTile(x,y)).regType = regType;
      }

      private function exportWmap() : ByteArray
      {
         var y:int = 0;
         var x:int = 0;
         var idx:* = 0;
         var i:int = 0;
         var tile:MapTileData = null;
         var objId:String = null;
         var objCfg:String = null;
         var ret:ByteArray = new ByteArray();
         var ver:int = 1;
         ret.writeByte(ver);
         var tiles:Vector.<MapTileData> = new Vector.<MapTileData>();
         var tileData:ByteArray = new ByteArray();
         tileData.endian = "littleEndian";
         //editor8182381 — Dictionary-based dedup replaces O(n³) linear search with O(n) hash lookup
         var tileDedup:Object = {};
         for(y = 0; y < this.mapHeight; )
         {
            for(x = 0; x < this.mapWidth; )
            {
               tile = this.tileMap.getTileData(x,y);
               var dedupKey:String = tile.groundType + "|" + tile.objType + "|" + tile.regType + "|" + tile.terrainType + "|" + tile.elevation + "|" + (tile.objCfg || "");
               if(tileDedup.hasOwnProperty(dedupKey))
               {
                  idx = tileDedup[dedupKey];
               }
               else
               {
                  idx = int(tiles.length);
                  tiles.push(tile);
                  tileDedup[dedupKey] = idx;
               }
               tileData.writeShort(idx);
               if(ver == 2)
               {
                  tileData.writeByte(tile.elevation * 255);
               }
               x++;
            }
            y++;
         }
         var mapData:ByteArray;
         (mapData = new ByteArray()).endian = "littleEndian";
         var tileCount:int = int(tiles.length);
         mapData.writeShort(tileCount);
         for(i = 0; i < tileCount; )
         {
            tile = tiles[i];
            mapData.writeShort(tile.groundType);
            objId = ObjectLibrary.getIdFromType(tile.objType);
            BinaryUtils.Write7BitEncodedInt(mapData,!!objId ? objId.length : 0);
            mapData.writeMultiByte(!!objId ? objId : "","utf-8");
            objCfg = tile.objCfg;
            BinaryUtils.Write7BitEncodedInt(mapData,!!objCfg ? objCfg.length : 0);
            mapData.writeMultiByte(!!objCfg ? objCfg : "","utf-8");
            mapData.writeByte(tile.terrainType);
            mapData.writeByte(tile.regType);
            if(ver == 1)
            {
               mapData.writeByte(tile.elevation);
            }
            i++;
         }
         mapData.writeInt(this.mapWidth);
         mapData.writeInt(this.mapHeight);
         mapData.writeBytes(tileData);
         mapData.compress();
         ret.writeBytes(mapData);
         return ret;
      }

      private function exportJson() : ByteArray
      {
         var ret:ByteArray = new ByteArray();
         var json:String = getMapJsonString();
         ret.writeMultiByte(json,"utf-8");
         return ret;
      }

      public function getMapJsonString() : String
      {
         var index:int = 0;
         var yi:int = 0;
         var xi:int = 0;
         var entry:Object = null;
         var entryJSON:String = null;
         var jm:Object;
         (jm = {})["width"] = this.mapWidth;
         jm["height"] = this.mapHeight;
         var dict:Object = {};
         var entries:Array = [];
         var indices:ByteArray = new ByteArray();
         for(yi = 0; yi < this.mapHeight; )
         {
            for(xi = 0; xi < this.mapWidth; )
            {
               entry = this.getJsonTile(xi,yi);
               entryJSON = encodeJson(entry);
               if(!dict.hasOwnProperty(entryJSON))
               {
                  index = int(entries.length);
                  dict[entryJSON] = index;
                  entries.push(entry);
               }
               else
               {
                  index = int(dict[entryJSON]);
               }
               indices.writeShort(index);
               xi++;
            }
            yi++;
         }
         jm["dict"] = entries;
         indices.compress();
         jm["data"] = Base64.encodeByteArray(indices);
         return encodeJson(jm);
      }

      //editor8182381 — Enhanced getJsonTile that preserves custom tile data for round-trip
      private function getJsonTile(x:int, y:int) : Object
      {
         var obj:Object = null;
         var reg:Object = null;
         var ret:Object = {};
         var tileData:MapTileData = this.tileMap.getTileData(x,y);
         if(tileData == null)
         {
            return ret;
         }
         if(tileData.groundType != -1)
         {
            //editor8182381 — For custom grounds, use original ground name from customGroundData (not the unique editor ID)
            var cgData:Object = this.customGroundData[tileData.groundType];
            if (cgData != null)
            {
               ret["ground"] = cgData["ground"];
               if (cgData["groundPixels"] != null)
                  ret["groundPixels"] = cgData["groundPixels"];
               if (cgData["blocked"] === true)
                  ret["blocked"] = true;
               if (cgData["speed"] != null)
                  ret["speed"] = cgData["speed"];
               if (cgData["blendPriority"] != null)
                  ret["blendPriority"] = cgData["blendPriority"];
            }
            else
            {
               ret["ground"] = GroundLibrary.getIdFromType(tileData.groundType);
            }
         }
         if(tileData.objType != 0)
         {
            obj = {"id":ObjectLibrary.getIdFromType(tileData.objType)};
            if(tileData.objCfg != null)
            {
               obj["name"] = tileData.objCfg;
            }

            //editor8182381 — If this is a custom object, include pixel data and class
            var coData:Object = this.customObjData[tileData.objType];
            if (coData != null)
            {
               if (coData["objectPixels"] != null)
                  obj["objectPixels"] = coData["objectPixels"];
               if (coData["objectSize"] != null && coData["objectSize"] != 8)
                  obj["objectSize"] = coData["objectSize"];
               if (coData["objectClass"] != null)
                  obj["objectClass"] = coData["objectClass"];
            }

            ret["objs"] = [obj];
         }
         if(tileData.regType != 0)
         {
            reg = {"id":RegionLibrary.getIdFromType(tileData.regType)};
            ret["regions"] = [reg];
         }
         return ret;
      }
   }
}

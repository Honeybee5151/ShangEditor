package realmeditor.editor.ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import realmeditor.editor.MapData;
   import realmeditor.editor.MapTileData;
   
   public class TileMapView extends Sprite
   {
      
      public static const TILE_SIZE:Number = 8;
      
      private static var emptyBitmap:BitmapData = new BitmapData(8,8,true,0);
      
      private static var emptyRegionBitmap:BitmapData = new BitmapData(1,1,true,0);
       
      
      private var mapData:MapData;
      
      private var tiles:Vector.<MapTileSprite>;
      
      private var tileMapTexture:BitmapData;
      
      private var tileMap:Bitmap;
      
      private var objectMapTexture:BitmapData;
      
      private var objectMap:Bitmap;
      
      private var regionMapTexture:BitmapData;
      
      private var regionMap:Bitmap;
      
      private var highResLayer:Sprite;
      
      private var highResSprites:Dictionary;
      
      public function TileMapView()
      {
         highResSprites = new Dictionary();
         super();
      }
      
      public function setup(mapData:MapData) : void
      {
         this.mapData = mapData;
         this.tiles = new Vector.<MapTileSprite>(this.mapData.mapWidth * this.mapData.mapHeight);
         if(this.tileMapTexture)
         {
            this.tileMapTexture.dispose();
            removeChild(this.tileMap);
         }
         if(this.objectMapTexture)
         {
            this.objectMapTexture.dispose();
            removeChild(this.objectMap);
         }
         if(this.regionMapTexture)
         {
            this.regionMapTexture.dispose();
            removeChild(this.regionMap);
         }
         if(this.highResLayer)
         {
            this.highResLayer.removeChildren();
            removeChild(this.highResLayer);
         }
         this.tileMapTexture = new BitmapData(8 * mapData.mapWidth,8 * mapData.mapHeight,true,0);
         this.objectMapTexture = new BitmapData(8 * mapData.mapWidth,8 * mapData.mapHeight,true,0);
         this.regionMapTexture = new BitmapData(mapData.mapWidth,mapData.mapHeight,true,0);
         this.highResLayer = new Sprite();
      }
      
      public function loadTileFromMap(tileData:MapTileData, mapX:int, mapY:int) : void
      {
         var idx:int = mapX + mapY * this.mapData.mapWidth;
         var tile:MapTileSprite = new MapTileSprite(mapX,mapY,mapX * 8,mapY * 8);
         this.tiles[idx] = tile;
         if(tileData == null)
         {
            return;
         }
         tile.setTileData(tileData);
         this.drawTile(mapX,mapY);
      }
      
      public function drawTile(mapX:int, mapY:int) : void
      {
         var size:int = 0;
         var obj:Bitmap = null;
         var matrix:Matrix = null;
         if(mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight)
         {
            return;
         }
         var idx:int = mapX + mapY * this.mapData.mapWidth;
         if(idx < 0 || idx >= this.tiles.length)
         {
            return;
         }
         var tile:MapTileSprite = this.tiles[idx];
         if(tile == null)
         {
            return;
         }
         this.objectMapTexture.copyPixels(emptyBitmap,new Rectangle(0,0,emptyBitmap.width,emptyBitmap.height),new Point(tile.spriteX,tile.spriteY));
         if(this.highResSprites[idx] != null)
         {
            this.highResLayer.removeChild(this.highResSprites[idx]);
            delete this.highResSprites[idx];
         }
         if(tile.objTexture != null)
         {
            size = Math.max(tile.objTexture.width,tile.objTexture.height);
            if(size != 8)
            {
               (obj = new Bitmap(tile.objTexture)).scaleX = 8 / tile.objTexture.width;
               obj.scaleY = 8 / tile.objTexture.height;
               obj.x = tile.spriteX;
               obj.y = tile.spriteY;
               this.highResLayer.addChild(obj);
               this.highResSprites[idx] = obj;
            }
            else
            {
               matrix = new Matrix();
               matrix.scale(8 / tile.objTexture.width,8 / tile.objTexture.height);
               matrix.translate(tile.spriteX,tile.spriteY);
               this.objectMapTexture.draw(tile.objTexture,matrix);
            }
         }
         this.regionMapTexture.copyPixels(emptyRegionBitmap,new Rectangle(0,0,emptyRegionBitmap.width,emptyRegionBitmap.height),new Point(mapX,mapY));
         if(tile.tileData.regType > 0)
         {
            this.regionMapTexture.fillRect(new Rectangle(mapX,mapY,1,1),0x5F000000 | tile.regColor);
         }
         this.tileMapTexture.copyPixels(emptyBitmap,new Rectangle(0,0,emptyBitmap.width,emptyBitmap.height),new Point(tile.spriteX,tile.spriteY));
         if(tile.groundTexture != null)
         {
            this.tileMapTexture.copyPixels(tile.groundTexture,new Rectangle(0,0,tile.groundTexture.width,tile.groundTexture.height),new Point(tile.spriteX,tile.spriteY));
         }
      }
      
      public function setTileData(mapX:int, mapY:int, tileData:MapTileData) : void
      {
         if(mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight)
         {
            return;
         }
         var idx:int = mapX + mapY * this.mapData.mapWidth;
         if(idx < 0 || idx >= this.tiles.length)
         {
            return;
         }
         var tile:MapTileSprite = this.tiles[idx];
         if(tile == null)
         {
            return;
         }
         tile.setTileData(tileData);
         this.dispatchEvent(new Event("MapChanged"));
      }
      
      public function setTileGround(mapX:int, mapY:int, groundType:int) : void
      {
         if(mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight)
         {
            return;
         }
         var idx:int = mapX + mapY * this.mapData.mapWidth;
         if(idx < 0 || idx >= this.tiles.length)
         {
            return;
         }
         var tile:MapTileSprite = this.tiles[idx];
         if(tile == null)
         {
            return;
         }
         tile.setGroundType(groundType);
         this.dispatchEvent(new Event("MapChanged"));
      }
      
      public function setTileObject(mapX:int, mapY:int, objType:int) : void
      {
         if(mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight)
         {
            return;
         }
         var idx:int = mapX + mapY * this.mapData.mapWidth;
         if(idx < 0 || idx >= this.tiles.length)
         {
            return;
         }
         var tile:MapTileSprite = this.tiles[idx];
         if(tile == null)
         {
            return;
         }
         tile.setObjectType(objType);
         this.dispatchEvent(new Event("MapChanged"));
      }
      
      public function setTileRegion(mapX:int, mapY:int, regType:int) : void
      {
         if(mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight)
         {
            return;
         }
         var idx:int = mapX + mapY * this.mapData.mapWidth;
         if(idx < 0 || idx >= this.tiles.length)
         {
            return;
         }
         var tile:MapTileSprite = this.tiles[idx];
         if(tile == null)
         {
            return;
         }
         tile.setRegionType(regType);
         this.dispatchEvent(new Event("MapChanged"));
      }
      
      public function onMapLoadEnd() : void
      {
         this.tileMap = new Bitmap(this.tileMapTexture);
         addChild(this.tileMap);
         this.objectMap = new Bitmap(this.objectMapTexture);
         addChild(this.objectMap);
         addChild(this.highResLayer);
         this.regionMap = new Bitmap(this.regionMapTexture);
         this.regionMap.scaleX = 8;
         this.regionMap.scaleY = 8;
         addChild(this.regionMap);
      }
      
      public function getTileSprite(mapX:int, mapY:int) : MapTileSprite
      {
         if(mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight)
         {
            return null;
         }
         var idx:int = mapX + mapY * this.mapData.mapWidth;
         if(idx < 0 || idx >= this.tiles.length)
         {
            return null;
         }
         return this.tiles[idx];
      }
      
      public function getTileData(mapX:int, mapY:int) : MapTileData
      {
         if(mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight)
         {
            return null;
         }
         var idx:int = mapX + mapY * this.mapData.mapWidth;
         if(idx < 0 || idx >= this.tiles.length)
         {
            return null;
         }
         return this.tiles[idx].tileData;
      }
      
      public function clearGround(mapX:int, mapY:int) : void
      {
         if(mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight)
         {
            return;
         }
         var idx:int = mapX + mapY * this.mapData.mapWidth;
         if(idx < 0 || idx >= this.tiles.length)
         {
            return;
         }
         var tile:MapTileSprite = this.tiles[idx];
         if(tile == null)
         {
            return;
         }
         this.setTileGround(mapX,mapY,-1);
         this.drawTile(mapX,mapY);
      }
      
      public function clearObject(mapX:int, mapY:int) : void
      {
         if(mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight)
         {
            return;
         }
         var idx:int = mapX + mapY * this.mapData.mapWidth;
         if(idx < 0 || idx >= this.tiles.length)
         {
            return;
         }
         var tile:MapTileSprite = this.tiles[idx];
         if(tile == null)
         {
            return;
         }
         this.setTileObject(mapX,mapY,0);
         this.drawTile(mapX,mapY);
      }
      
      public function clearRegion(mapX:int, mapY:int) : void
      {
         if(mapX < 0 || mapX >= this.mapData.mapWidth || mapY < 0 || mapY >= this.mapData.mapHeight)
         {
            return;
         }
         var idx:int = mapX + mapY * this.mapData.mapWidth;
         if(idx < 0 || idx >= this.tiles.length)
         {
            return;
         }
         var tile:MapTileSprite = this.tiles[idx];
         if(tile == null)
         {
            return;
         }
         this.setTileRegion(mapX,mapY,0);
         this.drawTile(mapX,mapY);
      }
      
      public function clearTile(mapX:int, mapY:int) : void
      {
         this.clearGround(mapX,mapY);
         this.clearObject(mapX,mapY);
         this.clearRegion(mapX,mapY);
      }
   }
}

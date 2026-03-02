package realmeditor.editor.ui
{
   import flash.display.BitmapData;
   import realmeditor.assets.GroundLibrary;
   import realmeditor.assets.ObjectLibrary;
   import realmeditor.assets.RegionLibrary;
   import realmeditor.editor.MapTileData;
   
   public class MapTileSprite
   {
       
      
      public var spriteX:int;
      
      public var spriteY:int;
      
      public var mapX:int;
      
      public var mapY:int;
      
      public var tileData:MapTileData;
      
      public var groundTexture:BitmapData;
      
      public var objTexture:BitmapData;
      
      public var regColor:uint;
      
      public function MapTileSprite(mapX:int, mapY:int, spriteX:int, spriteY:int)
      {
         super();
         this.mapX = mapX;
         this.mapY = mapY;
         this.spriteX = spriteX;
         this.spriteY = spriteY;
         this.tileData = new MapTileData();
      }
      
      public function setGroundType(groundType:int) : void
      {
         this.tileData.groundType = groundType;
         this.groundTexture = GroundLibrary.getBitmapData(groundType);
      }
      
      public function setObjectType(objType:int) : void
      {
         this.tileData.objType = objType;
         this.objTexture = ObjectLibrary.getTextureFromType(objType);
      }
      
      public function setObjectCfg(cfg:String) : void
      {
         this.tileData.objCfg = cfg;
      }
      
      public function setRegionType(regType:int) : void
      {
         this.tileData.regType = regType;
         this.regColor = RegionLibrary.getColor(regType);
      }
      
      public function setTileData(tileData:MapTileData) : void
      {
         this.setGroundType(tileData == null ? -1 : tileData.groundType);
         this.setObjectType(tileData == null ? 0 : tileData.objType);
         this.setObjectCfg(tileData == null ? null : tileData.objCfg);
         this.setRegionType(tileData == null ? 0 : tileData.regType);
         this.tileData.elevation = tileData == null ? 0 : tileData.elevation;
         this.tileData.terrainType = tileData == null ? 0 : tileData.terrainType;
      }
   }
}

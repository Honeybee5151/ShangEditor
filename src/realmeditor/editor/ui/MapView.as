package realmeditor.editor.ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import realmeditor.assets.GroundLibrary;
   import realmeditor.assets.ObjectLibrary;
   import realmeditor.assets.RegionLibrary;
   import realmeditor.editor.MEBrush;
   import realmeditor.editor.MEClipboard;
   import realmeditor.editor.MapData;
   import realmeditor.editor.MapDragController;
   import realmeditor.editor.MapHistory;
   import realmeditor.editor.MapTileData;
   import realmeditor.editor.actions.MapActionSet;
   import realmeditor.editor.actions.MapDragAction;
   import realmeditor.editor.actions.MapReplaceTileAction;
   import realmeditor.editor.actions.MapSelectAction;
   import realmeditor.editor.actions.data.MapSelectData;
   import realmeditor.util.IntPoint;
   
   public class MapView extends Sprite
   {
      
      public static const EMPTY_SELECTION:MapSelectData = new MapSelectData(-1,-1,-1,-1);
       
      
      public var id:int;
      
      public var mapData:MapData;
      
      public var tileMap:TileMapView;
      
      public var mapOffset:IntPoint;
      
      public var zoomLevel:int = 100;
      
      public var gridEnabled:Boolean;
      
      private var gridTexture:BitmapData;
      
      private var grid:Bitmap;
      
      public var selection:MapSelectData;
      
      public var selectionRect:Shape;
      
      private var highlightRect:Shape;
      
      private var brushOverlay:Bitmap;
      
      private var brushElementType:int;
      
      private var brushSize:int;
      
      private var brushTextureType:int;
      
      private var canvasTexture:BitmapData;
      
      private var canvasOutline:Bitmap;
      
      public var dragController:MapDragController;
      
      public function MapView(id:int, mapData:MapData)
      {
         super();
         this.id = id;
         this.mapData = mapData;
         this.mapOffset = new IntPoint();
         this.dragController = new MapDragController(this);
         this.tileMap = new TileMapView();
         addChild(this.tileMap);
         this.grid = new Bitmap(null);
         this.grid.visible = false;
         addChild(this.grid);
         this.highlightRect = new Shape();
         addChild(this.highlightRect);
         this.selection = EMPTY_SELECTION;
         this.selectionRect = new Shape();
         addChild(this.selectionRect);
         this.brushOverlay = new Bitmap();
         this.brushOverlay.alpha = 0.9;
         addChild(this.brushOverlay);
         this.canvasOutline = new Bitmap(null);
         addChild(this.canvasOutline);
      }
      
      private function drawGrid() : void
      {
         var i:int = 0;
         var x:Number = NaN;
         var y:Number = NaN;
         for(i = 0; i <= this.mapData.mapWidth; )
         {
            x = 8 * i;
            this.gridTexture.fillRect(new Rectangle(x,0,1,this.gridTexture.height),1610547200);
            i++;
         }
         for(i = 0; i <= this.mapData.mapHeight; )
         {
            y = 8 * i;
            this.gridTexture.fillRect(new Rectangle(0,y,this.gridTexture.width,1),1610547200);
            i++;
         }
         this.grid.bitmapData = this.gridTexture;
      }
      
      public function onMapLoadBegin() : void
      {
         this.selection = EMPTY_SELECTION;
         this.selectionRect.graphics.clear();
         this.highlightRect.graphics.clear();
         this.tileMap.graphics.clear();
         if(this.gridTexture)
         {
            this.gridTexture.dispose();
            this.gridTexture = null;
         }
         if(this.canvasTexture)
         {
            this.canvasTexture.dispose();
            this.canvasTexture = null;
         }
         this.gridTexture = new BitmapData(8 * this.mapData.mapWidth,8 * this.mapData.mapHeight,true,0);
         this.canvasTexture = new BitmapData(this.mapData.mapWidth * 8,this.mapData.mapHeight * 8,true,0);
      }
      
      public function onMapLoadEnd() : void
      {
         this.tileMap.onMapLoadEnd();
         this.drawGrid();
         this.drawCanvasOutline();
      }
      
      private function drawCanvasOutline() : void
      {
         this.canvasTexture.fillRect(new Rectangle(0,0,1,this.canvasTexture.height),1610612735);
         this.canvasTexture.fillRect(new Rectangle(0,0,this.canvasTexture.width,1),1610612735);
         this.canvasTexture.fillRect(new Rectangle(this.canvasTexture.width - 1,0,1,this.canvasTexture.height),1610612735);
         this.canvasTexture.fillRect(new Rectangle(0,this.canvasTexture.height - 1,this.canvasTexture.width,1),1610612735);
         this.canvasOutline.bitmapData = this.canvasTexture;
      }
      
      public function toggleGrid() : Boolean
      {
         if(this.grid == null)
         {
            return false;
         }
         var val:* = this.grid.visible = !this.grid.visible;
         this.gridEnabled = val;
         return val;
      }
      
      public function recordSelectionClear(history:MapHistory) : void
      {
         history.record(new MapSelectAction(this.selection.clone(),EMPTY_SELECTION));
      }
      
      public function clearTileSelection() : void
      {
         this.selection = EMPTY_SELECTION;
         this.selectionRect.graphics.clear();
         this.dragController.reset();
      }
      
      public function setLastDragAction(dragAction:MapDragAction) : void
      {
         this.selection.lastDragAction = dragAction;
         this.dragController.lastDragAction = dragAction;
      }
      
      public function selectTileArea(mapStartX:int, mapStartY:int, mapEndX:int, mapEndY:int) : void
      {
         var beginX:int = mapStartX < mapEndX ? mapStartX : mapEndX;
         var beginY:int = mapStartY < mapEndY ? mapStartY : mapEndY;
         var endX:int = mapStartX < mapEndX ? mapEndX : mapStartX;
         var endY:int = mapStartY < mapEndY ? mapEndY : mapStartY;
         this.drawTileSelection(beginX,beginY,endX,endY);
      }
      
      public function highlightTile(mapX:int, mapY:int) : void
      {
         var g:Graphics = this.highlightRect.graphics;
         g.clear();
         if(mapX < 0 || mapX > this.mapData.mapWidth || mapY < 0 || mapY > this.mapData.mapHeight)
         {
            return;
         }
         var x:int = mapX * 8;
         var y:int = mapY * 8;
         var width:int = 8;
         var height:int = 8;
         g.lineStyle(1,16777215,0.5);
         g.drawRect(x,y,width,height);
         g.lineStyle();
      }
      
      public function hideBrushOverlay() : void
      {
         this.brushOverlay.visible = false;
      }
      
      public function hideOverlays() : void
      {
         this.highlightTile(-1,-1);
         this.hideBrushOverlay();
      }
      
      public function moveBrushOverlay(mapX:int, mapY:int, brush:MEBrush, eraser:Boolean = false, forceDraw:Boolean = false) : void
      {
         if(eraser)
         {
            if(forceDraw || brush.size != this.brushSize)
            {
               this.drawBrushOutline(mapX,mapY,brush);
               return;
            }
         }
         else
         {
            if(forceDraw || brush.elementType != this.brushElementType)
            {
               this.drawBrushTiles(mapX,mapY,brush);
               return;
            }
            switch(brush.elementType)
            {
               case 0:
                  if(brush.groundType != this.brushTextureType)
                  {
                     this.drawBrushTiles(mapX,mapY,brush);
                     return;
                  }
                  break;
               case 1:
                  if(brush.objType != this.brushTextureType)
                  {
                     this.drawBrushTiles(mapX,mapY,brush);
                     return;
                  }
                  break;
               case 2:
                  if(brush.regType != this.brushTextureType)
                  {
                     this.drawBrushTiles(mapX,mapY,brush);
                     return;
                  }
                  break;
            }
         }
         this.brushOverlay.x = (mapX - brush.size) * 8;
         this.brushOverlay.y = (mapY - brush.size) * 8;
         this.brushOverlay.visible = true;
      }
      
      public function drawBrushTiles(mapX:int, mapY:int, brush:MEBrush) : void
      {
         var regColor:* = 0;
         var texture:BitmapData = null;
         var yi:int = 0;
         var xi:int = 0;
         var dx:int = 0;
         var dy:int = 0;
         var distSq:int = 0;
         var size:int = 8;
         this.brushElementType = brush.elementType;
         switch(brush.elementType)
         {
            case 0:
               if(brush.groundType == -1)
               {
                  return;
               }
               texture = GroundLibrary.getBitmapData(brush.groundType);
               this.brushTextureType = brush.groundType;
               size = Math.max(texture.width,texture.height);
               break;
            case 1:
               if(brush.objType == 0)
               {
                  return;
               }
               texture = ObjectLibrary.getTextureFromType(brush.objType);
               this.brushTextureType = brush.objType;
               size = Math.max(texture.width,texture.height);
               break;
            case 2:
               if(brush.regType == 0)
               {
                  return;
               }
               regColor = uint(RegionLibrary.getColor(brush.regType));
               this.brushTextureType = brush.regType;
               break;
         }
         var diameter:int = 1 + brush.size * 2;
         var radius:int = diameter / 2;
         var bitmapSize:int = diameter * size;
         var brushTexture:BitmapData = new BitmapData(bitmapSize,bitmapSize,true,0);
         for(yi = 0; yi <= diameter; )
         {
            for(xi = 0; xi <= diameter; )
            {
               dx = xi - radius;
               dy = yi - radius;
               distSq = dx * dx + dy * dy;
               if(distSq <= radius * radius)
               {
                  if(texture != null)
                  {
                     brushTexture.copyPixels(texture,new Rectangle(0,0,texture.width,texture.height),new Point(xi * texture.width,yi * texture.height));
                  }
                  else
                  {
                     brushTexture.fillRect(new Rectangle(xi * size,yi * size,size,size),0x5F000000 | regColor);
                  }
               }
               xi++;
            }
            yi++;
         }
         if(this.brushOverlay.bitmapData != null)
         {
            this.brushOverlay.bitmapData.dispose();
            this.brushOverlay.bitmapData = null;
         }
         this.brushOverlay.bitmapData = brushTexture;
         this.brushOverlay.scaleX = 8 / size;
         this.brushOverlay.scaleY = 8 / size;
         this.brushOverlay.x = (mapX - brush.size) * 8;
         this.brushOverlay.y = (mapY - brush.size) * 8;
         this.brushOverlay.visible = true;
      }
      
      public function drawBrushOutline(mapX:int, mapY:int, brush:MEBrush) : void
      {
         var yi:int = 0;
         var xi:int = 0;
         var dx:int = 0;
         var dy:int = 0;
         var distSq:int = 0;
         this.brushSize = brush.size;
         var diameter:int = 1 + brush.size * 2;
         var radius:int = diameter / 2;
         var bitmapSize:int = diameter * 8;
         var brushTexture:BitmapData = new BitmapData(bitmapSize,bitmapSize,true,0);
         for(yi = 0; yi <= diameter; )
         {
            for(xi = 0; xi <= diameter; )
            {
               dx = xi - radius;
               dy = yi - radius;
               distSq = dx * dx + dy * dy;
               if(distSq <= radius * radius)
               {
                  brushTexture.fillRect(new Rectangle(xi * 8,yi * 8,8,8),1610612735);
               }
               xi++;
            }
            yi++;
         }
         if(this.brushOverlay.bitmapData != null)
         {
            this.brushOverlay.bitmapData.dispose();
            this.brushOverlay.bitmapData = null;
         }
         this.brushOverlay.bitmapData = brushTexture;
         this.brushOverlay.scaleX = 1;
         this.brushOverlay.scaleY = 1;
         this.brushOverlay.x = (mapX - brush.size) * 8;
         this.brushOverlay.y = (mapY - brush.size) * 8;
         this.brushOverlay.visible = true;
      }
      
      public function drawTileSelection(mapStartX:int, mapStartY:int, mapEndX:int, mapEndY:int) : void
      {
         var g:Graphics = this.selectionRect.graphics;
         g.clear();
         var startX:int = mapStartX * 8;
         var startY:int = mapStartY * 8;
         var endX:int = mapEndX * 8;
         var endY:int = mapEndY * 8;
         var width:int = endX + 8 - startX;
         var height:int = endY + 8 - startY;
         g.lineStyle(0.5,16777215);
         g.drawRect(0,0,width,height);
         g.lineStyle();
         this.selection = new MapSelectData(startX / 8,startY / 8,endX / 8,endY / 8);
         this.selectionRect.x = startX;
         this.selectionRect.y = startY;
      }
      
      public function isInsideSelection(mapX:int, mapY:int, needsSelection:Boolean = false) : Boolean
      {
         var spriteX:int = 0;
         var spriteY:int = 0;
         if(needsSelection && this.selectionRect.width == 0)
         {
            return false;
         }
         if(this.selectionRect.width != 0)
         {
            spriteX = mapX * 8;
            spriteY = mapY * 8;
            if(spriteX < this.selectionRect.x || spriteX >= this.selectionRect.x + this.selectionRect.width || spriteY < this.selectionRect.y || spriteY >= this.selectionRect.y + this.selectionRect.height)
            {
               return false;
            }
         }
         return true;
      }
      
      public function editTileObjCfg(x:int, y:int, cfg:String) : void
      {
         var tile:MapTileSprite = this.tileMap.getTileSprite(x,y);
         var data:MapTileData = tile.tileData;
         if(tile == null || data.objType == 0)
         {
            return;
         }
         tile.setObjectCfg(cfg);
      }
      
      public function copySelectionToClipboard(clipboard:MEClipboard) : void
      {
         var mapY:* = 0;
         var mapX:* = 0;
         var tileData:MapTileData = null;
         if(this.selectionRect.x == -1 && this.selectionRect.y == -1)
         {
            return;
         }
         var startX:int = this.selection.startX;
         var startY:int = this.selection.startY;
         var width:int = this.selection.width;
         var height:int = this.selection.height;
         clipboard.setSize(width,height);
         for(mapY = startY; mapY < startY + height; )
         {
            for(mapX = startX; mapX < startX + width; )
            {
               tileData = this.tileMap.getTileData(mapX,mapY).clone();
               clipboard.addTile(tileData,mapX - startX,mapY - startY);
               mapX++;
            }
            mapY++;
         }
      }
      
      public function pasteFromClipboard(clipboard:MEClipboard, mapX:int, mapY:int, history:MapHistory) : void
      {
         var tileY:* = 0;
         var tileX:* = 0;
         var tileData:MapTileData = null;
         var prevData:MapTileData = null;
         if(mapX < 0 || mapX > this.mapData.mapWidth || mapY < 0 || mapY > this.mapData.mapHeight || clipboard.width <= 0 || clipboard.height <= 0 || mapX + clipboard.width > this.mapData.mapWidth || mapY + clipboard.height > this.mapData.mapHeight)
         {
            return;
         }
         var actions:MapActionSet = new MapActionSet();
         var prevSelection:MapSelectData = this.selection.clone();
         this.clearTileSelection();
         this.drawTileSelection(mapX,mapY,mapX + clipboard.width - 1,mapY + clipboard.height - 1);
         var newSelectionData:MapSelectData = new MapSelectData(mapX,mapY,mapX + clipboard.width - 1,mapY + clipboard.height - 1);
         actions.push(new MapSelectAction(prevSelection,newSelectionData));
         for(tileY = mapY; tileY < mapY + clipboard.height; )
         {
            for(tileX = mapX; tileX < mapX + clipboard.width; )
            {
               tileData = clipboard.getTile(tileX - mapX,tileY - mapY);
               prevData = this.tileMap.getTileData(tileX,tileY).clone();
               if(!(tileData == null || tileData == prevData))
               {
                  this.tileMap.setTileData(tileX,tileY,tileData);
                  this.tileMap.drawTile(tileX,tileY);
                  actions.push(new MapReplaceTileAction(tileX,tileY,prevData,tileData.clone()));
               }
               tileX++;
            }
            tileY++;
         }
         history.recordSet(actions);
      }
   }
}

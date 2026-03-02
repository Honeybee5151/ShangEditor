package realmeditor.editor.ui
{
   import flash.desktop.NativeApplication;
   import flash.display.Graphics;
   import flash.display.NativeWindow;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.fscommand;
   import flash.utils.getTimer;
   import realmeditor.RealmEditorTestEvent;
   import realmeditor.editor.AutoMapSaver;
   import realmeditor.editor.MEBrush;
   import realmeditor.editor.MEClipboard;
   import realmeditor.editor.MapData;
   import realmeditor.editor.MapHistory;
   import realmeditor.editor.MapTileData;
   import realmeditor.editor.TimeControl;
   import realmeditor.editor.ToolSwitchEvent;
   import realmeditor.editor.actions.MapEditAction;
   import realmeditor.editor.tools.MESelectTool;
   import realmeditor.editor.tools.METool;
   import realmeditor.editor.ui.elements.MultiOptionalSwitch;
   import realmeditor.editor.ui.elements.SimpleCheckBox;
   import realmeditor.editor.ui.elements.SimpleTextButton;
   import realmeditor.editor.ui.elements.SimpleTextInput;
   import realmeditor.editor.ui.embed.Background;
   import realmeditor.util.IntPoint;
   
   public class MainView extends Sprite
   {
      
      private static const MAX_ZOOM:Number = 1000;
      
      public static var Instance:MainView;
      
      public static var Main:Sprite;
      
      public static var StageWidth:int = 800;
      
      public static var StageHeight:int = 600;
      
      public static var ScaleX:Number;
      
      public static var ScaleY:Number;
       
      
      private var mapSelector:MapSelectorView;
      
      public var mapViewContainer:MapViewContainer;
      
      public var mapView:MapView;
      
      private var mapData:MapData;
      
      private var nextMapId:int;
      
      private var background:Background;
      
      private var loadButton:SimpleTextButton;
      
      private var newButton:SimpleTextButton;
      
      private var saveButton:SimpleTextButton;
      
      private var backButton:SimpleTextButton;
      
      private var saveWmapButton:SimpleTextButton;
      
      private var testMapButton:SimpleTextButton;
      
      private var mapCreateWindow:CreateMapWindow;
      
      private var closePrompt:ClosePromptWindow;
      
      public var inputHandler:MapInputHandler;
      
      public var notifications:NotificationView;
      
      private var zoomInput:SimpleTextInput;
      
      private var toolBoxBackground:Shape;
      
      private var tileInfoPanel:TileInfoPanel;
      
      private var gridCheckbox:SimpleCheckBox;
      
      private var autoSaveCheckbox:SimpleCheckBox;
      
      private var drawTypeSwitch:MultiOptionalSwitch;
      
      private var editNameView:EditTileNameView;
      
      private var objectFilterView:ObjectFilterOptionsView;
      
      private var debugView:DebugView;
      
      private var drawElementsList:MapDrawElementListView;
      
      private var toolBar:MapToolbar;
      
      public var userBrush:MEBrush;
      
      public var selectedTool:METool;
      
      private var lastMousePos:Point;
      
      private var clipBoard:MEClipboard;
      
      public var timeControl:TimeControl;
      
      private var lastUpdate:int;
      
      private var autoSaver:AutoMapSaver;
      
      private var window:NativeWindow;
      
      public var testMode:Boolean;
      
      public function MainView(main:Sprite, embedded:Boolean)
      {
         super();
         Instance = this;
         Main = main;
         Main.stage.addEventListener("resize",this.onStageResize);
         StageWidth = Main.stage.stageWidth;
         StageHeight = Main.stage.stageHeight;
         ScaleX = Main.stage.stageWidth / 800;
         ScaleY = Main.stage.stageHeight / 600;
         this.userBrush = new MEBrush(0,0);
         this.clipBoard = new MEClipboard();
         this.timeControl = new TimeControl();
         this.selectedTool = new MESelectTool(this);
         this.autoSaver = new AutoMapSaver();
         this.window = main.stage.nativeWindow;
         this.background = new Background();
         addChild(this.background);
         this.mapViewContainer = new MapViewContainer();
         this.mapViewContainer.addChild(this.background);
         addChild(this.mapViewContainer);
         this.setupInput();
         this.toolBoxBackground = new Shape();
         this.toolBoxBackground.filters = Constants.SHADOW_FILTER_1;
         addChild(this.toolBoxBackground);
         this.zoomInput = new SimpleTextInput("Zoom",false,"100",18,16777215,15,15395562,true);
         this.zoomInput.inputText.restrict = "0-9";
         this.zoomInput.inputText.maxChars = 3;
         this.zoomInput.inputText.addEventListener("change",this.onZoomInputChange);
         addChild(this.zoomInput);
         this.gridCheckbox = new SimpleCheckBox("Grid",false);
         this.gridCheckbox.addEventListener("change",this.onGridClick);
         addChild(this.gridCheckbox);
         this.autoSaveCheckbox = new SimpleCheckBox("Autosave",true);
         this.autoSaveCheckbox.addEventListener("change",this.onAutoSaveClick);
         addChild(this.autoSaveCheckbox);
         this.drawTypeSwitch = new MultiOptionalSwitch();
         this.drawTypeSwitch.addOption("Ground");
         this.drawTypeSwitch.addOption("Objects");
         this.drawTypeSwitch.addOption("Regions");
         this.drawTypeSwitch.addEventListener("OptionSwitch",this.onDrawTypeSwitch);
         addChild(this.drawTypeSwitch);
         var g:Graphics = this.toolBoxBackground.graphics;
         g.beginFill(5658198,0.8);
         g.drawRoundRect(0,0,this.autoSaveCheckbox.width + 10,this.zoomInput.height + this.gridCheckbox.height + this.autoSaveCheckbox.height + this.drawTypeSwitch.height + 32,10,10);
         g.endFill();
         this.tileInfoPanel = new TileInfoPanel();
         this.tileInfoPanel.visible = false;
         addChild(this.tileInfoPanel);
         this.drawElementsList = new MapDrawElementListView();
         this.drawElementsList.setContent(0);
         this.drawElementsList.addEventListener("select",this.onDrawElementSelected);
         addChild(this.drawElementsList);
         this.toolBar = new MapToolbar(this);
         addChild(this.toolBar);
         this.loadButton = new SimpleTextButton("Load");
         this.loadButton.addEventListener("click",this.onLoadClick);
         addChild(this.loadButton);
         this.newButton = new SimpleTextButton("New");
         this.newButton.addEventListener("click",this.onNewClick);
         addChild(this.newButton);
         this.saveButton = new SimpleTextButton("Save JSON");
         this.saveButton.addEventListener("click",this.onSaveClick);
         addChild(this.saveButton);
         if(embedded)
         {
            this.backButton = new SimpleTextButton("Back");
            this.backButton.addEventListener("click",this.onBackClick);
            addChild(this.backButton);
         }
         this.saveWmapButton = new SimpleTextButton("Save Wmap");
         this.saveWmapButton.addEventListener("click",this.onSaveWmapClick);
         addChild(this.saveWmapButton);
         this.testMapButton = new SimpleTextButton("Test");
         this.testMapButton.addEventListener("click",this.onTestMapClick);
         addChild(this.testMapButton);
         this.mapSelector = new MapSelectorView();
         this.mapSelector.addEventListener("MapSelect",this.onMapSelected);
         this.mapSelector.addEventListener("MapClosed",this.onMapClosed);
         addChild(this.mapSelector);
         this.objectFilterView = new ObjectFilterOptionsView(this.drawElementsList);
         addChild(this.objectFilterView);
         this.notifications = new NotificationView();
         addChild(this.notifications);
         Main.stage.addEventListener("enterFrame",this.update);
         Main.stage.addEventListener("mouseWheel",this.onMouseWheel);
         Main.stage.addEventListener("resize",this.onStageResize);
         Main.stage.addEventListener("removedFromStage",this.onRemovedFromStage);
         this.window.addEventListener("closing",this.onExiting);
         this.updateScale();
         this.updatePositions();
      }
      
      private static function closeWindow() : void
      {
         fscommand("quit");
         NativeApplication.nativeApplication.exit();
      }
      
      private static function onExit(e:Event) : void
      {
         closeWindow();
      }
      
      private function setupInput() : void
      {
         this.inputHandler = new MapInputHandler(this);
         this.inputHandler.addEventListener("GridEnable",this.onGridEnable);
         this.inputHandler.addEventListener("TileClick",this.onTileClick);
         this.inputHandler.addEventListener("MouseDrag",this.onMouseDrag);
         this.inputHandler.addEventListener("MouseDragEnd",this.onMouseDragEnd);
         this.inputHandler.addEventListener("MiddleMouseDrag",this.onMiddleMouseDrag);
         this.inputHandler.addEventListener("MiddleMouseDragEnd",this.onMiddleMouseDragEnd);
         this.inputHandler.addEventListener("mouseMove",this.onMouseMoved);
         this.inputHandler.addEventListener("ToolSwitch",this.onToolSwitch);
         this.inputHandler.addEventListener("Undo",this.onUndoAction);
         this.inputHandler.addEventListener("Redo",this.onRedoAction);
         this.inputHandler.addEventListener("DrawTypeSwitch",this.onDrawTypeSwitchKey);
         this.inputHandler.addEventListener("Copy",this.onCopy);
         this.inputHandler.addEventListener("Paste",this.onPaste);
         this.inputHandler.addEventListener("ClearSelection",this.onClearSelection);
         this.inputHandler.addEventListener("MoveSelectionUp",this.onMoveSelectionUp);
         this.inputHandler.addEventListener("MoveSelectionDown",this.onMoveSelectionDown);
         this.inputHandler.addEventListener("MoveSelectionLeft",this.onMoveSelectionLeft);
         this.inputHandler.addEventListener("MoveSelectionRight",this.onMoveSelectionRight);
         this.inputHandler.addEventListener("ToggleDebug",this.onToggleDebug);
      }
      
      private function updateScale() : void
      {
         this.background.scaleX = ScaleX;
         this.background.scaleY = ScaleY;
      }
      
      public function updatePositions() : void
      {
         this.notifications.updatePosition();
         this.loadButton.x = 15;
         this.loadButton.y = 15;
         this.newButton.x = this.loadButton.x + this.loadButton.width + 10;
         this.newButton.y = this.loadButton.y;
         this.saveButton.x = this.newButton.x + this.newButton.width + 10;
         this.saveButton.y = this.loadButton.y;
         if(this.backButton != null)
         {
            this.backButton.x = StageWidth - this.backButton.width - 10;
            this.backButton.y = this.loadButton.y;
         }
         this.saveWmapButton.x = this.saveButton.x + this.saveButton.width + 10;
         this.saveWmapButton.y = this.loadButton.y;
         this.testMapButton.x = this.saveWmapButton.x + this.saveWmapButton.width + 10;
         this.testMapButton.y = this.loadButton.y;
         this.mapSelector.x = this.loadButton.x;
         this.mapSelector.y = this.loadButton.y + this.loadButton.height + 10;
         this.toolBoxBackground.x = 15;
         this.toolBoxBackground.y = (StageHeight - this.toolBoxBackground.height) / 2;
         this.zoomInput.x = this.toolBoxBackground.x + 5;
         this.zoomInput.y = this.toolBoxBackground.y + 7.5;
         this.gridCheckbox.x = this.zoomInput.x;
         this.gridCheckbox.y = this.zoomInput.y + this.zoomInput.height + 6;
         this.autoSaveCheckbox.x = this.zoomInput.x;
         this.autoSaveCheckbox.y = this.gridCheckbox.y + this.gridCheckbox.height + 6;
         this.drawTypeSwitch.x = this.zoomInput.x;
         this.drawTypeSwitch.y = this.autoSaveCheckbox.y + this.autoSaveCheckbox.height + 6;
         this.drawElementsList.x = StageWidth - 130 - 15;
         if(this.backButton != null)
         {
            this.drawElementsList.y = this.backButton.y + this.backButton.height + 15;
         }
         else
         {
            this.drawElementsList.y = 15;
         }
         this.tileInfoPanel.x = this.drawElementsList.x - this.tileInfoPanel.width - 15;
         this.tileInfoPanel.y = StageHeight - this.tileInfoPanel.height - 15;
         this.toolBar.x = this.drawElementsList.x - this.toolBar.width - 8;
         this.toolBar.y = (StageHeight - this.toolBar.height) / 2;
         this.objectFilterView.x = this.drawElementsList.x - 20;
         this.objectFilterView.y = this.drawElementsList.y;
         if(this.mapView)
         {
            this.mapView.x = (StageWidth - this.mapData.mapWidth * 8 * this.mapView.scaleX) / 2;
            this.mapView.y = (StageHeight - this.mapData.mapHeight * 8 * this.mapView.scaleY) / 2;
            this.mapView.x += this.mapView.mapOffset.x_ * this.mapView.zoomLevel / 1000;
            this.mapView.y += this.mapView.mapOffset.y_ * this.mapView.zoomLevel / 1000;
         }
         if(this.mapCreateWindow != null && this.mapCreateWindow.visible)
         {
            this.mapCreateWindow.x = (StageWidth - this.mapCreateWindow.width) / 2;
            this.mapCreateWindow.y = (StageHeight - this.mapCreateWindow.height) / 2;
         }
         if(this.editNameView != null && this.editNameView.visible)
         {
            this.editNameView.x = (StageWidth - this.editNameView.width) / 2;
            this.editNameView.y = (StageHeight - this.editNameView.height) / 2;
         }
         if(this.debugView != null && this.debugView.visible)
         {
            this.debugView.x = 10;
            this.debugView.y = StageHeight - this.debugView.height - 10;
         }
         if(this.closePrompt != null && this.closePrompt.visible)
         {
            this.closePrompt.x = (StageWidth - this.closePrompt.width) / 2;
            this.closePrompt.y = (StageHeight - this.closePrompt.height) / 2;
         }
      }
      
      private function onMouseWheel(e:MouseEvent) : void
      {
         var val:int = 0;
         var deltaX:Number = NaN;
         var deltaY:Number = NaN;
         var zoom:Number = NaN;
         if(this.mapView == null || this.testMode)
         {
            return;
         }
         if(e.ctrlKey && (this.selectedTool.id == 1 || this.selectedTool.id == 6))
         {
            val = Math.min(Math.max(int(Math.ceil(e.delta)),-1),1);
            this.userBrush.size += val;
            if(this.userBrush.size < 0)
            {
               this.userBrush.size = 0;
            }
            this.onBrushSizeChanged();
            return;
         }
         var zoomLevel:int = this.mapView.zoomLevel + (this.mapView.zoomLevel / e.delta + 1);
         zoomLevel = Math.max(1,Math.min(zoomLevel,1000));
         if(this.mapView.zoomLevel != zoomLevel)
         {
            this.mapView.zoomLevel = zoomLevel;
            deltaX = StageWidth / 2 - Main.stage.mouseX;
            deltaY = StageHeight / 2 - Main.stage.mouseY;
            if(e.delta < 0)
            {
               deltaX *= -1;
               deltaY *= -1;
            }
            zoom = Math.max(1,Math.min(1000,1000 / this.mapView.zoomLevel));
            this.mapView.mapOffset.x_ += deltaX * (zoom * 0.5);
            this.mapView.mapOffset.y_ += deltaY * (zoom * 0.5);
            this.updateZoomLevel();
         }
      }
      
      private function onStageResize(e:Event) : void
      {
         StageWidth = Main.stage.stageWidth;
         StageHeight = Main.stage.stageHeight;
         ScaleX = Main.stage.stageWidth / 800;
         ScaleY = Main.stage.stageHeight / 600;
         this.updateScale();
         this.updatePositions();
         this.drawElementsList.onScreenResize();
      }
      
      private function onRemovedFromStage(e:Event) : void
      {
         this.inputHandler.clear();
         Main.stage.removeEventListener("enterFrame",this.update);
         Main.stage.removeEventListener("mouseWheel",this.onMouseWheel);
         Main.stage.removeEventListener("resize",this.onStageResize);
         Main.stage.removeEventListener("removedFromStage",this.onRemovedFromStage);
      }
      
      private function update(e:Event) : void
      {
         if(this.testMode)
         {
            if(!this.visible)
            {
               return;
            }
            this.testMode = false;
         }
         var time:int = getTimer();
         var deltaTime:int = time - this.lastUpdate;
         this.lastUpdate = time;
         if(this.debugView != null && this.debugView.visible)
         {
            this.debugView.updateStats(time,deltaTime);
         }
         if(this.mapData != null)
         {
            this.autoSaver.trySaveMap(this.mapData,deltaTime);
         }
      }
      
      private function onExiting(e:Event) : void
      {
         e.preventDefault();
         var unsavedChanges:Boolean = false;
         for each(var view in this.mapViewContainer.maps)
         {
            if(!view.mapData.savedChanges)
            {
               unsavedChanges = true;
               break;
            }
         }
         if(!unsavedChanges)
         {
            onExit(null);
            return;
         }
         if(this.closePrompt == null)
         {
            this.closePrompt = new ClosePromptWindow();
            this.closePrompt.x = (StageWidth - this.closePrompt.width) / 2;
            this.closePrompt.y = (StageHeight - this.closePrompt.height) / 2;
            this.closePrompt.addEventListener("ExitNoSave",onExit);
            addChild(this.closePrompt);
         }
         else
         {
            this.closePrompt.visible = true;
         }
         this.updatePositions();
      }
      
      private function onLoadClick(e:Event) : void
      {
         var newData:MapData = new MapData();
         var newMap:MapView = new MapView(this.nextMapId,newData);
         this.nextMapId++;
         this.mapView = newMap;
         this.mapData = newData;
         this.mapData.addEventListener("MapLoadBegin",this.onMapLoadBegin);
         this.mapData.addEventListener("MapLoadEnd",this.onMapLoadEnd);
         this.mapData.load(newMap.tileMap);
      }
      
      private function onNewClick(e:Event) : void
      {
         if(this.mapCreateWindow == null)
         {
            this.mapCreateWindow = new CreateMapWindow();
            this.mapCreateWindow.x = (StageWidth - this.mapCreateWindow.width) / 2;
            this.mapCreateWindow.y = (StageHeight - this.mapCreateWindow.height) / 2;
            this.mapCreateWindow.addEventListener("MapCreate",this.onMapCreate);
            addChild(this.mapCreateWindow);
         }
         else
         {
            this.mapCreateWindow.visible = true;
         }
         this.updatePositions();
      }
      
      private function onMapCreate(e:Event) : void
      {
         var newData:MapData = new MapData();
         var newMap:MapView = new MapView(this.nextMapId,newData);
         this.nextMapId++;
         this.mapView = newMap;
         this.mapData = newData;
         this.mapData.addEventListener("MapLoadBegin",this.onMapLoadBegin);
         this.mapData.addEventListener("MapLoadEnd",this.onMapLoadEnd);
         newData.newMap(newMap.tileMap,this.mapCreateWindow.mapName,this.mapCreateWindow.mapWidth,this.mapCreateWindow.mapHeight);
      }
      
      private function onMapSelected(e:Event) : void
      {
         this.mapView = this.mapViewContainer.viewMap(this.mapSelector.selectedMap);
         this.mapData = this.mapView.mapData;
         this.updateZoomLevel();
         this.gridCheckbox.setValue(this.mapView.gridEnabled);
      }
      
      private function onMapClosed(e:MapClosedEvent) : void
      {
         this.mapViewContainer.trySaveMap(e.mapId);
         this.mapViewContainer.removeMapView(e.mapId);
         this.timeControl.eraseHistory(e.mapId);
         var nextId:int = this.mapSelector.selectedMap - 1 < 0 ? 0 : this.mapSelector.selectedMap - 1;
         this.mapSelector.selectMap(nextId);
         this.mapView = this.mapViewContainer.viewMap(nextId);
         if(this.mapView)
         {
            this.mapData = this.mapView.mapData;
            this.updateZoomLevel();
            this.gridCheckbox.setValue(this.mapView.gridEnabled);
         }
      }
      
      private function onSaveClick(e:Event) : void
      {
         if(this.mapData != null)
         {
            this.mapData.addEventListener("MapSaved",this.onJsonSaved);
            this.mapData.save(false);
         }
      }
      
      private function onBackClick(e:Event) : void
      {
         this.inputHandler.clear();
         parent.removeChild(this);
      }
      
      private function onSaveWmapClick(e:Event) : void
      {
         if(this.mapData != null)
         {
            this.mapData.addEventListener("MapSaved",this.onWmapSaved);
            this.mapData.save(true);
         }
      }
      
      private function onTestMapClick(e:Event) : void
      {
         var json:String = null;
         if(this.mapData != null)
         {
            json = this.mapData.getMapJsonString();
            dispatchEvent(new RealmEditorTestEvent(json));
            this.testMode = true;
         }
      }
      
      private function onJsonSaved(e:Event) : void
      {
         this.mapData.removeEventListener("MapSaved",this.onJsonSaved);
         this.notifications.showNotification("Map saved in JSON format!");
      }
      
      private function onWmapSaved(e:Event) : void
      {
         this.mapData.removeEventListener("MapSaved",this.onWmapSaved);
         this.notifications.showNotification("Map saved in WMap format!");
      }
      
      private function onMapLoadBegin(e:Event) : void
      {
         this.mapData.removeEventListener("MapLoadBegin",this.onMapLoadBegin);
         this.mapView.onMapLoadBegin();
         this.updatePositions();
      }
      
      private function onMapLoadEnd(e:Event) : void
      {
         this.mapData.removeEventListener("MapLoadEnd",this.onMapLoadEnd);
         this.mapView.onMapLoadEnd();
         this.updateZoomLevel();
         var mapId:int = this.mapViewContainer.addMapView(this.mapView);
         this.mapSelector.addMap(mapId,this.mapData.mapName);
         this.mapSelector.selectMap(mapId);
         this.mapViewContainer.viewMap(mapId);
         this.timeControl.createHistory(this.mapView.id);
      }
      
      private function onGridClick(e:Event) : void
      {
         if(this.mapView)
         {
            this.mapView.toggleGrid();
         }
      }
      
      private function onAutoSaveClick(e:Event) : void
      {
         this.autoSaver.disabled = !this.autoSaver.disabled;
      }
      
      private function onGridEnable(e:Event) : void
      {
         var value:Boolean = false;
         if(this.mapView)
         {
            value = this.mapView.toggleGrid();
            this.gridCheckbox.setValue(value);
         }
      }
      
      private function onZoomInputChange(e:Event) : void
      {
         var zoomLevel:int = int(this.zoomInput.inputText.text);
         if(this.mapView.zoomLevel == zoomLevel)
         {
            return;
         }
         this.mapView.zoomLevel = zoomLevel;
         this.updateZoomLevel();
      }
      
      private function updateZoomLevel() : void
      {
         this.zoomInput.inputText.setText(this.mapView.zoomLevel.toString());
         if(this.mapView)
         {
            this.mapView.scaleX = this.mapView.zoomLevel / 100;
            this.mapView.scaleY = this.mapView.zoomLevel / 100;
            if(this.mapView.scaleX < 0.01 || this.mapView.scaleY < 0.01)
            {
               this.mapView.scaleX = 0.01;
               this.mapView.scaleY = 0.01;
            }
            this.updatePositions();
         }
      }
      
      private function onMouseDrag(e:Event) : void
      {
         var tilePos:IntPoint = getMouseTilePosition();
         if(this.mapView == null)
         {
            return;
         }
         this.selectedTool.mouseDrag(tilePos,this.timeControl.getHistory(this.mapView.id));
      }
      
      private function onMiddleMouseDrag(e:Event) : void
      {
         if(this.lastMousePos == null)
         {
            this.lastMousePos = new Point(Main.stage.mouseX,Main.stage.mouseY);
         }
         this.dragMap();
      }
      
      private function dragMap() : void
      {
         var deltaX:Number = Main.stage.mouseX - this.lastMousePos.x;
         var deltaY:Number = Main.stage.mouseY - this.lastMousePos.y;
         var zoom:Number = Math.max(1,Math.min(1000,1000 / this.mapView.zoomLevel));
         this.mapView.mapOffset.x_ += deltaX * zoom;
         this.mapView.mapOffset.y_ += deltaY * zoom;
         this.lastMousePos.x = Main.stage.mouseX;
         this.lastMousePos.y = Main.stage.mouseY;
         this.updatePositions();
      }
      
      private function onMouseDragEnd(e:Event) : void
      {
         var tilePos:IntPoint = this.getMouseTilePosition();
         if(this.mapView == null)
         {
            return;
         }
         this.selectedTool.mouseDragEnd(tilePos,this.timeControl.getHistory(this.mapView.id));
      }
      
      private function onMiddleMouseDragEnd(e:Event) : void
      {
         this.lastMousePos = null;
      }
      
      private function onTileClick(e:Event) : void
      {
         var tilePos:IntPoint = this.getMouseTilePosition();
         if(this.mapView == null)
         {
            return;
         }
         this.selectedTool.tileClick(tilePos,this.timeControl.getHistory(this.mapView.id));
      }
      
      public function showEditNameView(x:int, y:int, objName:String) : void
      {
         if(this.editNameView == null)
         {
            this.editNameView = new EditTileNameView(x,y,objName);
            this.editNameView.x = (StageWidth - this.editNameView.width) / 2;
            this.editNameView.y = (StageHeight - this.editNameView.height) / 2;
            this.editNameView.addEventListener("EditObjName",this.onEditName);
            addChild(this.editNameView);
         }
         else
         {
            this.editNameView.showNew(x,y,objName);
         }
         this.updatePositions();
      }
      
      private function onEditName(e:Event) : void
      {
         var mapX:int = this.editNameView.tileX;
         var mapY:int = this.editNameView.tileY;
         var history:MapHistory = this.timeControl.getHistory(this.mapView.id);
         var prevData:MapTileData = this.mapView.tileMap.getTileData(mapX,mapY);
         if(prevData.objType == 0)
         {
            return;
         }
         history.record(new MapEditAction(mapX,mapY,prevData.objCfg,this.editNameView.objName));
         this.mapView.editTileObjCfg(mapX,mapY,this.editNameView.objName);
      }
      
      private function onMouseMoved(e:Event) : void
      {
         var tilePos:IntPoint = this.getMouseTilePosition();
         if(this.mapView == null)
         {
            return;
         }
         if(tilePos == null)
         {
            this.tileInfoPanel.visible = false;
            return;
         }
         this.updateTileInfoPanel(tilePos);
         this.mapView.hideOverlays();
         this.selectedTool.mouseMoved(tilePos,this.timeControl.getHistory(this.mapView.id));
      }
      
      private function updateTileInfoPanel(tilePos:IntPoint) : void
      {
         var tileData:MapTileData = this.mapView.tileMap.getTileData(tilePos.x_,tilePos.y_);
         if(tileData == null)
         {
            this.tileInfoPanel.visible = false;
            return;
         }
         this.tileInfoPanel.visible = true;
         this.tileInfoPanel.setInfo(tilePos.x_,tilePos.y_,tileData);
         this.updatePositions();
      }
      
      private function getMouseTilePosition() : IntPoint
      {
         if(this.mapView == null)
         {
            return null;
         }
         var mouseX:Number = Main.stage.mouseX;
         var mouseY:Number = Main.stage.mouseY;
         var x:int = (mouseX - this.mapView.x) / (8 * this.mapView.scaleX);
         var y:int = (mouseY - this.mapView.y) / (8 * this.mapView.scaleY);
         if(x < 0 || y < 0 || x >= this.mapData.mapWidth || y >= this.mapData.mapHeight)
         {
            return null;
         }
         return new IntPoint(x,y);
      }
      
      private function onToolSwitch(e:ToolSwitchEvent) : void
      {
         if(e.toolId == this.selectedTool.id)
         {
            return;
         }
         this.setSelectedTool(e.toolId);
         this.toolBar.setSelected(e.toolId);
      }
      
      public function setSelectedTool(toolId:int) : void
      {
         this.lastMousePos = null;
         this.selectedTool.reset();
         this.selectedTool = METool.GetTool(toolId,this);
         if(this.mapView == null)
         {
            return;
         }
         if(toolId != 0)
         {
            this.mapView.highlightTile(-1,-1);
         }
         var tilePos:IntPoint = this.getMouseTilePosition();
         if(this.mapView == null)
         {
            return;
         }
         this.mapView.hideOverlays();
         this.selectedTool.init(tilePos,this.timeControl.getHistory(this.mapView.id));
      }
      
      private function onUndoAction(e:Event) : void
      {
         if(this.mapView == null)
         {
            return;
         }
         this.timeControl.undoLastAction(this.mapView.id);
         this.notifications.showNotification("Undone",18,1);
      }
      
      private function onRedoAction(e:Event) : void
      {
         if(this.mapView == null)
         {
            return;
         }
         this.timeControl.redoLastUndoneAction(this.mapView.id);
         this.notifications.showNotification("Redone",18,1);
      }
      
      private function onDrawTypeSwitch(e:Event) : void
      {
         this.userBrush.elementType = this.drawTypeSwitch.selected;
         this.drawElementsList.resetFilters();
         this.drawElementsList.setContent(this.userBrush.elementType);
         this.updateDrawElements();
      }
      
      public function updateDrawElements() : void
      {
         switch(this.userBrush.elementType)
         {
            case 0:
               this.drawElementsList.setSelected(this.userBrush.groundType);
               break;
            case 1:
               this.drawElementsList.setSelected(this.userBrush.objType);
               break;
            case 2:
               this.drawElementsList.setSelected(this.userBrush.regType);
         }
      }
      
      private function onDrawTypeSwitchKey(e:Event) : void
      {
         this.drawTypeSwitch.selectNext();
      }
      
      private function onDrawElementSelected(e:Event) : void
      {
         var elementType:int = int(this.drawElementsList.selectedElement == null ? -1 : this.drawElementsList.selectedElement.elementType);
         switch(this.userBrush.elementType)
         {
            case 0:
               this.userBrush.setGroundType(elementType);
               break;
            case 1:
               this.userBrush.setObjectType(elementType);
               break;
            case 2:
               this.userBrush.setRegionType(elementType);
         }
         var tilePos:IntPoint = this.getMouseTilePosition();
         if(tilePos == null)
         {
            return;
         }
         this.mapView.drawBrushTiles(tilePos.x_,tilePos.y_,this.userBrush);
      }
      
      private function onCopy(e:Event) : void
      {
         if(this.mapView == null)
         {
            return;
         }
         this.clipBoard.clear();
         this.mapView.copySelectionToClipboard(this.clipBoard);
      }
      
      private function onPaste(e:Event) : void
      {
         if(this.mapView == null)
         {
            return;
         }
         var tilePos:IntPoint = this.getMouseTilePosition();
         if(tilePos == null)
         {
            return;
         }
         this.mapView.pasteFromClipboard(this.clipBoard,tilePos.x_,tilePos.y_,this.timeControl.getHistory(this.mapView.id));
      }
      
      private function onClearSelection(e:Event) : void
      {
         if(this.selectedTool.id == 0)
         {
            this.selectedTool.reset();
         }
         var history:MapHistory = this.timeControl.getHistory(this.mapView.id);
         this.mapView.recordSelectionClear(history);
         this.mapView.clearTileSelection();
      }
      
      private function onMoveSelectionUp(e:Event) : void
      {
         if(this.mapView == null || this.selectedTool.id != 0)
         {
            return;
         }
         var selectTool:MESelectTool = METool.GetTool(0,this) as MESelectTool;
         selectTool.dragSelection(0,-1,this.timeControl.getHistory(this.mapView.id));
      }
      
      private function onMoveSelectionDown(e:Event) : void
      {
         if(this.mapView == null || this.selectedTool.id != 0)
         {
            return;
         }
         var selectTool:MESelectTool = METool.GetTool(0,this) as MESelectTool;
         selectTool.dragSelection(0,1,this.timeControl.getHistory(this.mapView.id));
      }
      
      private function onMoveSelectionLeft(e:Event) : void
      {
         if(this.mapView == null || this.selectedTool.id != 0)
         {
            return;
         }
         var selectTool:MESelectTool = METool.GetTool(0,this) as MESelectTool;
         selectTool.dragSelection(-1,0,this.timeControl.getHistory(this.mapView.id));
      }
      
      private function onMoveSelectionRight(e:Event) : void
      {
         if(this.mapView == null || this.selectedTool.id != 0)
         {
            return;
         }
         var selectTool:MESelectTool = METool.GetTool(0,this) as MESelectTool;
         selectTool.dragSelection(1,0,this.timeControl.getHistory(this.mapView.id));
      }
      
      private function onBrushSizeChanged() : void
      {
         var tilePos:IntPoint = this.getMouseTilePosition();
         if(tilePos == null)
         {
            return;
         }
         if(this.selectedTool.id == 6)
         {
            this.mapView.drawBrushOutline(tilePos.x_,tilePos.y_,this.userBrush);
         }
         else
         {
            this.mapView.drawBrushTiles(tilePos.x_,tilePos.y_,this.userBrush);
         }
      }
      
      private function onToggleDebug(e:Event) : void
      {
         if(this.debugView == null)
         {
            this.debugView = new DebugView();
            addChild(this.debugView);
         }
         else
         {
            this.debugView.show(!this.debugView.visible);
         }
         this.updatePositions();
      }
   }
}

package game.entities
{
	import br.com.stimuli.loading.BulkLoader;
	
	import flash.display.BitmapData;
	
	import game.forms.FormMapLoader;
	import game.util.Constants;
	import game.util.Functions;
	
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Tilemap;

	public class Map extends Entity
	{
		private var tilemap:Tilemap;
		private var name:String;	
		private var xml:XML;
		
		private var mapWidth:Number;
		private var mapHeight:Number;
		
		private var tileWidth:Number;
		private var tileHeight:Number;
		
		private var tileMapSpriteName:String;
		
		public function Map(name:String)
		{
			this.name = name;
		}
		
		public function loadMapFile():void
		{
			Evangel.formMapLoader = new FormMapLoader(name);			
			Evangel.formMapLoader.startLoad();
		}
		
		public function loadMapContents():void
		{
			Evangel.formMapLoader.getLabelStatus().text = "Loading map tiles...";
			
			mapWidth   = xml.@width;
			mapHeight  = xml.@height;
			tileWidth  = xml.@tilewidth;
			tileHeight = xml.@tileheight;
			
			tileMapSpriteName = xml.tileset[0].image.@source;
			tileMapSpriteName = Functions.getFilenameFromUrl(tileMapSpriteName);
			tileMapSpriteName = Functions.removeExtensionFromFilename(tileMapSpriteName);
			
			var tilemapBitmap:BitmapData = BulkLoader.getLoader(Constants.BULK_LOADER_NAME).getBitmapData(tileMapSpriteName);
			
			var tilemap:Tilemap = new Tilemap(tilemapBitmap, mapWidth*tileWidth, mapHeight*tileHeight, tileWidth, tileHeight);
			
			var gid:Number = 0;
			
			trace(xml.layer[0].data.tile[gid].gid.length);
			
			for(var x:int = 0; x < mapWidth; x++)
			{
				for(var y:int = 0; y < mapHeight; y++)
				{
					var tileID:Number = xml.layer[0].data.tile[gid].@gid-1;
					tilemap.setTile(y, x, tileID);
					
					gid++;
				}
			}
			
			this.graphic = tilemap;
		}
		
		public function getXML():XML
		{
			return xml;
		}
		
		public function setXML(xml:XML):void
		{
			this.xml = xml;
		}
	}
}
package game.forms
{
	import com.bit101.components.Label;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	import game.util.Constants;
	import game.util.Functions;
	import game.util.GameObjects;
	import game.util.Logger;

	public class FormMapLoader extends Form
	{
		private var labelStatus:Label; 
		private var loader:Loader;
		private var name:String;
		
		public function FormMapLoader(name:String)
		{
			super("Loading map...", 300, 150, true, false);
			
			this.name = name;
			
			// create the label
			labelStatus = new Label(form.content, 10, form.height - 50, "Loading map " + name + "...");					
			labelStatus.setSize(250, 50);
			labelStatus.autoSize = false;
		}
		
		public function startLoad():void
		{
			show();
			loadMap();
		}
		
		private function loadMap():void
		{
			Logger.debug("Loading map: " + name + " ...");

			var loader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest(Constants.URL_MAPS + name + "?" + Functions.randomNumber(0, 99999));

			loader.addEventListener(ProgressEvent.PROGRESS, onLoadMapProgress, false, 0, true);
			loader.addEventListener(Event.COMPLETE, onLoadMapOK, false, 0, true);
			loader.load(req);
		}
		
		private function onLoadMapProgress(e:Event):void
		{
			var percent:Number = e.currentTarget.bytesLoaded / e.currentTarget.bytesTotal;
			Logger.debug("Load map progress: " + percent + "%");
			labelStatus.text =  "Loading map " + name + " (" + percent + "%)";
		}
		
		private function onLoadMapOK(e:Event):void
		{
			Logger.debug("Map file " + name + " loaded");
			labelStatus.text = "Map file " + name + " loaded";
			
			GameObjects.MAP.setXML(new XML(e.target.data));
			
			setTimeout(GameObjects.MAIN.afterLoadMap, 1000);
		}
		
		public function getLabelStatus():Label
		{
			return labelStatus;
		}
		
	}
}
package game.forms
{
	import com.bit101.components.Label;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.setTimeout;
	
	import br.com.stimuli.loading.BulkProgressEvent;
	import br.com.stimuli.loading.lazyloaders.LazyXMLLoader;
	
	import game.util.Constants;
	import game.util.GameObjects;
	import game.util.Logger;

	public class FormPreLoader extends Form
	{
		private var labelStatus:Label; 
		private var loader:LazyXMLLoader;
		
		public function FormPreLoader()
		{
			super("Loading...", 300, 150, true, false);
			
			// create the label
			labelStatus = new Label(form.content, 10, form.height - 50, "Loading game resources...");					
			labelStatus.setSize(250, 50);
			labelStatus.autoSize = false;
		}
		
		public function startLoadResources():void
		{
			loadResources();
		}
		
		private function loadResources():void
		{
			Logger.debug("Loading XML file with resources...");
			
			loader = new LazyXMLLoader(Constants.URL_RESOURCES_XML, Constants.BULK_LOADER_NAME);
			
			// TODO VERIFICA SE PRECISA DESTE EVENTO
			//loader.addEventListener(LazyBulkLoader.LAZY_COMPLETE, onLoadResourcesOK)
			
			loader.addEventListener(Event.COMPLETE, onLoadResourcesOK);
			loader.addEventListener(ProgressEvent.PROGRESS, onLoadResourcesProgressOK);
			
			loader.start();
		}
		
		private function onLoadResourcesOK(e:Event):void
		{
			Logger.debug("Resources XML file loaded");
			labelStatus.text = "All resources was loaded";
			
			setTimeout(GameObjects.MAIN.afterLoadResources, 1000);
		}
		
		private function onLoadResourcesProgressOK(e:BulkProgressEvent):void
		{
			var text:String = "Resources load progress: " + (e.percentLoaded.toString()) + "%";
			Logger.debug(text);
			labelStatus.text = text;
		}
	}
}
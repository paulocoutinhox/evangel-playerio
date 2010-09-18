package game.util
{
	public class Logger
	{
		public function Logger()
		{
			
		}
		
		public static function debug(text:String):void
		{
			showMessage("DEBUG: " + text);
		}
		
		public static function info(text:String):void
		{
			showMessage("INFO: " + text);
		}
		
		public static function error(text:String):void
		{
			showMessage("ERROR: " + text);
		}
		
		public static function showMessage(text:String):void
		{
			trace(text);
		}
		
	}
}
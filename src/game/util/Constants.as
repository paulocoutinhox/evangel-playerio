package game.util
{
	import playerio.Client;
	

	public class Constants
	{
		
		public static var DEBUG:Boolean = true;
		
		public static var URL_BASE:String = getURLBase();
		public static var URL_RESOURCES_XML:String = URL_BASE + "assets/data/loader.xml?" + getRandomNumber();
		public static var URL_MAPS:String = URL_BASE + "assets/data/map/";
		
		public static var PLAYER_IO_GAME_ID:String = "evangel-6mnllmjwuml67lgcnts6a";
		public static var PLAYER_IO_IP_DEBUG:String = "localhost";
		
		public static var CLIENT:Client;
		
		public static var BULK_LOADER_NAME:String = "loader";	
		
		public static var SCREEN_WIDTH:int = 800;
		public static var SCREEN_HEIGHT:int = 600;
		public static var SCREEN_FRAME_RATE:int = 60;
		
		public static var LOGGED_IN:Boolean = false;
		
		
		private static function getURLBase():String
		{
			var URL:String = "";
			
			if (DEBUG == true)
			{
				URL = "http://localhost/evangel-playerio/";
			}
			else
			{
				URL = "http://www.prsolucoes.com/evangel-playerio/"
			}
			
			return URL;
		}
		
		private static function getRandomNumber():Number
		{
			return Functions.randomNumber(0, 9999999);			
		}
	}
}
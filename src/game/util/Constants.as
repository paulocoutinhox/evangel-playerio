package game.util
{
	import com.facebook.Facebook;
	import com.facebook.data.users.FacebookUser;
	import com.facebook.utils.FacebookSessionUtil;
	
	import flash.display.LoaderInfo;

	public class Constants
	{
		
		public static var DEBUG:Boolean = true;
		
		public static var URL_BASE:String = getURLBase();
		public static var URL_RESOURCES_XML:String = URL_BASE + "assets/data/loader.xml?" + getRandomNumber();
		public static var URL_MAPS:String = URL_BASE + "assets/data/map/";
		
		public static var FACEBOOK_API_KEY:String = "981d82132db74e49d1bf5151b4372726";
		public static var FACEBOOK_SECRET_KEY:String = "363f9dd90e9fcadafb4427acb6e2eafa";
		public static var FACEBOOK_SESSION:FacebookSessionUtil;
		public static var FACEBOOK_LOADER_INFO:LoaderInfo;		
		public static var FACEBOOK_USER:FacebookUser;
		public static var FACEBOOK:Facebook;

		public static var PLAYER_IO_GAME_ID:String = "evangel-6mnllmjwuml67lgcnts6a";
		
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
				URL = "http://localhost/evangel/";
			}
			else
			{
				URL = "http://www.prsolucoes.com/evangel/"
			}
			
			return URL;
		}
		
		private static function getRandomNumber():Number
		{
			return Functions.randomNumber(0, 9999999);			
		}
	}
}
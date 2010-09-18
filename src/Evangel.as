package
{
	import game.forms.FormLogin;
	import game.forms.FormMapLoader;
	import game.forms.FormPreLoader;
	import game.server.MessageManager;
	import game.util.Constants;
	import game.util.GameObjects;
	import game.util.Logger;
	import game.worlds.GameWorld;
	
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	
	[SWF(width = "800", height = "600", backgroundColor = "#000000")]
	public class Evangel extends Engine
	{
		public static var formPreLoader:FormPreLoader;
		public static var formLogin:FormLogin;
		public static var formMapLoader:FormMapLoader;
		
		public function Evangel()
		{
			super(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT, Constants.SCREEN_FRAME_RATE, false);			
		}
		
		override public function init():void { 
			start();	
		}
		
		public function start():void
		{
			Logger.info("ENGINE STARTED");
			
			// define some constants
			GameObjects.MAIN = this;
			
			// create forms
			formPreLoader = new FormPreLoader();
			formLogin = new FormLogin();
			
			GameObjects.PLAYERS = new Array();
			
			startLoadResources();
		}
		
		public function startLoadResources():void
		{
			formPreLoader.show();
			formPreLoader.startLoadResources();
		}
		
		public function afterLoadResources():void
		{
			startLogin();
		}
		
		public function startLogin():void
		{
			formPreLoader.hide();	
			formLogin.show();
			formLogin.startLoginProcess();
		}
		
		public function afterLogin():void
		{
			startGame();
		}
		
		public function errorLogin():void
		{
			Constants.LOGGED_IN = false;
			GameObjects.PLAYERS = new Array();
			
			formLogin.getButtonRetry().visible = true;
		}
		
		public function startGame():void
		{
			formPreLoader.hide();
			formLogin.hide();
			
			Constants.LOGGED_IN = true;
			
			FP.world = new GameWorld();
		}
		
		public function afterLoadMap():void
		{
			GameObjects.MAP.loadMapContents();
			formMapLoader.hide();
			startGetPlayers();
		}
		
		public function startLoadMap():void
		{
			formPreLoader.hide();
			formLogin.hide();
			GameObjects.MAP.loadMapFile();
		}
		
		public function startGetPlayers():void
		{
			formPreLoader.hide();
			formMapLoader.hide();
			
			formLogin.show();			
			formLogin.getLabelStatus().text = "Getting users joinned...";
			
			MessageManager.getInstance().getConnection().send("USERS_JOINED");
		}
		
		public function afterGetPlayers():void
		{
			if (Constants.LOGGED_IN == false)
			{
				MessageManager.getInstance().getConnection().send("LOGIN_PROCESS_OK");
			}
		}
		
		public function disconnectedGame():void
		{
			Constants.LOGGED_IN = false;
			GameObjects.PLAYERS = new Array();
			
			formPreLoader.hide();
			formMapLoader.hide();
			
			FP.world = null;
			FP.world.visible = false;

			formLogin.getLabelStatus().text = "You have been disconnected by server";
			
			formLogin.show();
			formLogin.getButtonRetry().visible = true;
		}
		
		public function loginProcessOK():void
		{
			startGame();
		}
		
	}
}
package game.forms
{
	import br.com.stimuli.loading.lazyloaders.LazyXMLLoader;
	
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.facebook.commands.users.GetInfo;
	import com.facebook.data.users.FacebookUser;
	import com.facebook.data.users.GetInfoData;
	import com.facebook.data.users.GetInfoFieldValues;
	import com.facebook.events.FacebookEvent;
	import com.facebook.facebook_internal;
	import com.facebook.net.FacebookCall;
	import com.facebook.utils.FacebookSessionUtil;
	
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import game.server.MessageManager;
	import game.util.Constants;
	import game.util.Functions;
	import game.util.GameObjects;
	import game.util.Logger;
	
	import playerio.Client;
	import playerio.Connection;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;

	public class FormLogin extends Form
	{
		private var labelStatus:Label; 
		private var loader:LazyXMLLoader;
		private var buttonRetry:PushButton;
		
		public function FormLogin()
		{
			super("Login", 300, 150, true, false);
						
			// create the label
			labelStatus = new Label(form.content, 10, form.height - 50, "Connecting...");					
			labelStatus.setSize(280, 50);
			labelStatus.autoSize = false;
			
			// create the buttons
			buttonRetry = new PushButton(form.content, (form.width/2) - 50, (form.height/2) - 25, "Reconnect", onReconnectClickOK);
			buttonRetry.width = 100;
			buttonRetry.height = 22;
			buttonRetry.visible = false;
		}
		
		private function onReconnectClickOK(e:MouseEvent):void
		{
			GameObjects.MAIN.startLogin();	
		}
		
		public function startLoginProcess():void
		{
			buttonRetry.visible = false;
			loginPlayerIO();
		}
		
		private function loginFacebook():void
		{
			Logger.debug("Connecting to facebook...");
			
			labelStatus.text = "Connecting to facebook...";
			
			Constants.FACEBOOK_LOADER_INFO = GameObjects.MAIN.root.loaderInfo;
			
			// create a facebook session
			Constants.FACEBOOK_SESSION = new FacebookSessionUtil(Constants.FACEBOOK_API_KEY, Constants.FACEBOOK_SECRET_KEY, Constants.FACEBOOK_LOADER_INFO);
			Constants.FACEBOOK = Constants.FACEBOOK_SESSION.facebook;
			Constants.FACEBOOK_SESSION.addEventListener(FacebookEvent.CONNECT, onLoginFacebookOK, false, 0, true);						
			Constants.FACEBOOK_SESSION.login();
			
			Constants.FACEBOOK_SESSION.validateLogin();
		}
		
		private function onLoginFacebookOK(e:FacebookEvent):void
		{
			Logger.debug("Connected to facebook");
			
			if (e.success == true)
			{
				labelStatus.text = "Connected to facebook";			
				callFacebook();
			}
			else
			{
				labelStatus.text = "Cannot connect to facebook";
				setTimeout(validateFacebookLogin, 2000);
			}
		}
		
		private function validateFacebookLogin():void
		{
			Logger.debug("Checking facebook login...");
			labelStatus.text = "Checking facebook login...";
			Constants.FACEBOOK_SESSION.validateLogin();
		}
		
		private function callFacebook():void
		{
			Logger.debug("Getting facebook user data...");
			labelStatus.text = "Getting facebook user data...";
			
			var call:FacebookCall = Constants.FACEBOOK_SESSION.facebook.post(new GetInfo([Constants.FACEBOOK_SESSION.facebook.uid],[GetInfoFieldValues.ALL_VALUES]));
			call.addEventListener(FacebookEvent.COMPLETE, onCallFacebookOK);
		}
		
		private function onCallFacebookOK(e:FacebookEvent):void
		{
			if (e.success == true)
			{
				Constants.FACEBOOK_USER = (e.data as GetInfoData).userCollection.getItemAt(0) as FacebookUser; 
				
				Logger.debug("You are " + Constants.FACEBOOK_USER.name);
				labelStatus.text = "You are " + Constants.FACEBOOK_USER.name;
			}
			else
			{
				facebookLoginFailure();	
			}
		}
		
		private function loginPlayerIO():void
		{
			Logger.debug("Connecting to PlayerIO server...");
			labelStatus.text = "Connecting to PlayerIO server...";

			PlayerIO.quickConnect.facebookOAuthConnectPopup(
				GameObjects.MAIN.root.stage,
				Constants.PLAYER_IO_GAME_ID,
				"_blank",
				[],
				function(c:Client, access_token:String, facebookuserid:String):void{
					onLoginPlayerIOOK(c, access_token, facebookuserid);
				},
				function(e:PlayerIOError):void{
					onLoginPlayerIOERROR(e);
				}
			)
			
			/*
			PlayerIO.quickConnect.simpleConnect(
				GameObjects.MAIN.root.stage,
				Constants.PLAYER_IO_GAME_ID,
				Functions.randomNumber(1, 999999).toString(),
				"",
				function(c:Client):void{
					onLoginPlayerIOOK(c);
				},
				function(e:PlayerIOError):void{
					onLoginPlayerIOERROR(e);
				}
			)
			*/
		}
		
		private function onLoginPlayerIOOK(c:Client, access_token:String, facebookuserid:String):void
		{
			Logger.debug("Connected to PlayerIO server");
			labelStatus.text = "Connected to PlayerIO server";
			
			Constants.FACEBOOK_USER = new FacebookUser();
			Constants.FACEBOOK_USER.uid = facebookuserid;
			
			joinPlayerIO(c);
		}
		
		private function onLoginPlayerIOERROR(e:PlayerIOError):void
		{
			playerIOLoginFailure();
		}
		
		private function joinPlayerIO(c:Client):void
		{
			Logger.debug("Joining in the game...");
			labelStatus.text = "Joining in the game...";
			
			if (Constants.DEBUG == true) 
			{
				//set developmentsever (Comment out to connect to your server online)			
				c.multiplayer.developmentServer = Constants.PLAYER_IO_IP_DEBUG + ":8184";
				
				//create or join the room test
				c.multiplayer.createJoinRoom(
					"world1",								//Room id. If set to null a random roomid is used
					"bounce",							//The game type started on the server
					false,								//Should the room be hidden from the lobby?
					{},									//Room data. This data is returned to lobby list. Variabels can be modifed on the server
					{},									//User join data
					onJoinPlayerIOOK,							//Function executed on successful joining of the room
					onLoginPlayerIOERROR							//Function executed if we got a join error
				);
			}
			else 
			{
				//create pr join the room test
				c.multiplayer.createJoinRoom(
					"world1",								//Room id. If set to null a random roomid is used
					"MyGame",							//The game type started on the server
					false,								//Should the room be hidden from the lobby?
					{},									//Room data. This data is returned to lobby list. Variabels can be modifed on the server
					{},									//User join data
					onJoinPlayerIOOK,							//Function executed on successful joining of the room
					onLoginPlayerIOERROR							//Function executed if we got a join error
				);
			}
		}
		
		private function onJoinPlayerIOOK(c:Connection):void
		{
			Logger.debug("You joined in the game");
			labelStatus.text = "You joined in the game";			
			
			MessageManager.getInstance().setConnection(c);
			MessageManager.getInstance().initialize();
			
			loginOnServer();
		}
		
		private function facebookLoginFailure():void
		{
			Logger.debug("Failure when try connect to Facebook");
			labelStatus.text = "Failure when try connect to Facebook, try again";
			loginFailure();
		}
		
		private function playerIOLoginFailure():void
		{
			Logger.debug("Failure when try connect to PlayerIO");
			labelStatus.text = "Failure when try connect to PlayerIO, try again";
			loginFailure();
		}
			
		private function loginFailure():void
		{
			GameObjects.MAIN.errorLogin();
		}
		
		private function loginOnServer():void
		{
			Logger.debug("Connecting to game server...");
			labelStatus.text = "Connecting to game server...";
			
			MessageManager.getInstance().getConnection().send("LOGIN", Constants.FACEBOOK_USER.uid, "");
		}
		
		public function getLabelStatus():Label
		{
			return labelStatus;
		}
		
		public function getButtonRetry():PushButton
		{
			return buttonRetry;
		}
	
	}
}
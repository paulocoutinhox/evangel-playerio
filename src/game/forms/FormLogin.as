package game.forms
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	
	import flash.events.MouseEvent;
	
	import br.com.stimuli.loading.lazyloaders.LazyXMLLoader;
	
	import game.server.MessageManager;
	import game.util.Constants;
	import game.util.GameObjects;
	import game.util.Logger;
	
	import playerio.Client;
	import playerio.Connection;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	import playerio.PlayerIORegistrationError;

	public class FormLogin extends Form
	{
		private var labelStatus:Label; 
		private var loader:LazyXMLLoader;
		
		private var labelUsername:Label; 
		private var labelPassword:Label;
		private var txtUsername:InputText;
		private var txtPassword:InputText;
		private var buttonLogin:PushButton;
		
		public function FormLogin()
		{
			super("Login", 300, 200, true, false);
			
			labelStatus = new Label(form.content, 10, form.height - 50, "You are disconnected");					
			labelStatus.setSize(280, 50);
			labelStatus.autoSize = false;
			
			labelUsername = new Label(form.content, 10, 10, "Usuário: ");					
			labelUsername.setSize(40, 20);
			labelUsername.autoSize = false;
			
			labelPassword = new Label(form.content, 10, 40, "Senha: ");					
			labelPassword.setSize(40, 20);
			labelPassword.autoSize = false;
			
			txtUsername = new InputText(form.content, labelUsername.x + labelUsername.width + 10, labelUsername.y + 2); 
			txtPassword = new InputText(form.content, labelPassword.x + labelPassword.width + 10, labelPassword.y + 2);
			txtPassword.password = true;
			
			buttonLogin = new PushButton(form.content, 0, 0, "Entrar", onLoginClickOK);
			buttonLogin.setSize(60, 20);
			buttonLogin.x = (form.width / 2 - buttonLogin.width / 2);
			buttonLogin.y = 85;
			
			buttonLogin.visible = true;
		}
		
		private function onReconnectClickOK(e:MouseEvent):void
		{
			GameObjects.MAIN.startLogin();	
		}
		
		private function onLoginClickOK(e:MouseEvent):void
		{
			GameObjects.MAIN.startLogin();
			startLoginProcess();
		}
		
		public function startLoginProcess():void
		{
			buttonLogin.visible = false;
			registerPlayerIO();
		}
		
		private function registerPlayerIO():void
		{
			Logger.debug("Registering on PlayerIO server...");
			labelStatus.text = "Registering on PlayerIO server...";
			
			PlayerIO.quickConnect.simpleRegister(
				GameObjects.MAIN.root.stage,
				Constants.PLAYER_IO_GAME_ID,
				txtUsername.text,
				txtPassword.text,
				"", //email
				"", // captchaKey
				"", // captchaValue
				null, // extraData
				null, // partnerId
				function(c:Client):void{
					onRegisterPlayerIOOK(c);
				},
				function(e:PlayerIORegistrationError):void{
					if (e.usernameError == "The username is already registered")
					{
						loginPlayerIO();
					}
					else
					{
						onRegisterPlayerIOERROR(e);	
					}
				}
			);
		}
		
		private function loginPlayerIO():void
		{
			Logger.debug("Connecting to PlayerIO server...");
			labelStatus.text = "Connecting to PlayerIO server...";
			
			PlayerIO.quickConnect.simpleConnect(
				GameObjects.MAIN.root.stage,
				Constants.PLAYER_IO_GAME_ID,
				txtUsername.text,
				txtPassword.text,
				function(c:Client):void{
					onLoginPlayerIOOK(c);
				},
				function(e:PlayerIOError):void{
					onLoginPlayerIOERROR(e);
				}
			);
			
			buttonLogin.visible = true;
		}
		
		private function onLoginPlayerIOOK(c:Client):void
		{
			Logger.debug("Connected to PlayerIO server");
			labelStatus.text = "Connected to PlayerIO server";
			
			joinPlayerIO(c);
		}
		
		private function onLoginPlayerIOERROR(e:PlayerIOError):void
		{
			playerIOLoginFailure();
		}
		
		private function onRegisterPlayerIOOK(c:Client):void
		{
			Logger.debug("Registered to PlayerIO server");
			labelStatus.text = "Registered to PlayerIO server";
			
			joinPlayerIO(c);
		}
		
		private function onRegisterPlayerIOERROR(e:PlayerIORegistrationError):void
		{
			playerIOLoginFailure();
		}
		
		private function joinPlayerIO(c:Client):void
		{
			Logger.debug("Joining in the game...");
			labelStatus.text = "Joining in the game...";
			
			Constants.CLIENT = c;
			
			if (Constants.DEBUG == true) 
			{
				//set developmentsever (Comment out to connect to your server online)			
				c.multiplayer.developmentServer = Constants.PLAYER_IO_IP_DEBUG + ":8184";
				
				//create or join the room test
				c.multiplayer.createJoinRoom(
					"main-world",								//Room id. If set to null a random roomid is used
					"MainGame",							//The game type started on the server
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
					"main-world",								//Room id. If set to null a random roomid is used
					"MainGame",							//The game type started on the server
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
			
			MessageManager.getInstance().getConnection().send("LOGIN", Constants.CLIENT.connectUserId, "");
		}
		
		public function getLabelStatus():Label
		{
			return labelStatus;
		}
		
		public function getButtonLogin():PushButton
		{
			return buttonLogin;
		}
		
	}
}
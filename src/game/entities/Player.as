package game.entities
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.BitmapData;
	
	import br.com.stimuli.loading.BulkLoader;
	
	import game.server.MessageManager;
	import game.util.Constants;
	import game.util.GameObjects;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.Tween;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.tweens.misc.VarTween;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	
	public class Player extends Entity
	{
		private var playerBitmap:BitmapData;
		private var playerSprite:Spritemap;
		
		public var playerDirection:int;
		public var playerStopped:Boolean;
		public var playerWalking:Boolean;
		public var playerWithoutAction:Boolean;
		
		public var playerId:int;
		public var playerName:String;
		public var playerLevel:int;
		public var playerMP:Number;
		public var playerHP:Number;
		public var playerEXP:Number;
		
		public var playerPosX:Number;
		public var playerPosY:Number;
		public var playerPosZ:Number;
		
		public var playerWidth:int;
		public var playerHeight:int;
		
		public var playerCanMove:Boolean;
		
		public var playerIsNpc:Boolean;
		
		public var playerTweenVelocity:Number = 0.4; 
		
		public var playerDistanceMovement:Number;
		
		public var playerState:int;
		
		public static var PLAYER_STATE_STAND:int = 1;
		public static var PLAYER_STATE_WALK:int = 2;
		
		public function Player(type:String)
		{
			this.type = type;

			initializeProperties();
			
			loadPlayerData();
			
			playerSprite.add("up", [12,13,14,15], 12, true); 
			playerSprite.add("right", [8,9,10,11], 12, true);
			playerSprite.add("down", [0,1,2,3], 12, true);
			playerSprite.add("left", [4,5,6,7], 12, true);
			
			playerSprite.add("stop_up", [12], 12, true); 
			playerSprite.add("stop_right", [8], 12, true);
			playerSprite.add("stop_down", [0], 12, true);
			playerSprite.add("stop_left", [4], 12, true);
			
			playerSprite.play("stop_down");
			
			graphic = playerSprite;
		}
		
		public function updatePosition():void
		{
			// pressionar tecla
			if (isLockedPlayerMovement() == false)
			{
				if (Input.check(Key.LEFT)) { 
					lockPlayerMovement();
					MessageManager.getInstance().getConnection().send("MOVE", 4);
					//move(4);
				} else if (Input.check(Key.RIGHT)) { 
					lockPlayerMovement();
					MessageManager.getInstance().getConnection().send("MOVE", 2);
					//move(2);
				} else if (Input.check(Key.UP)) { 
					lockPlayerMovement();
					MessageManager.getInstance().getConnection().send("MOVE", 1);
					//move(1);
				} else if (Input.check(Key.DOWN)) { 
					lockPlayerMovement();
					MessageManager.getInstance().getConnection().send("MOVE", 3);
					//move(3);
				}
			}
				
			// liberar tecla
			if (Input.released(Key.LEFT)) { 
				stop(4);
				//playerState = PLAYER_STATE_STAND;
				MessageManager.getInstance().getConnection().send("PLAYER_STOP_MOVE");
			} else if (Input.released(Key.RIGHT)) { 
				stop(2);
				//playerState = PLAYER_STATE_STAND;
				MessageManager.getInstance().getConnection().send("PLAYER_STOP_MOVE");
			} else if (Input.released(Key.UP)) { 
				stop(1);
				//playerState = PLAYER_STATE_STAND;
				MessageManager.getInstance().getConnection().send("PLAYER_STOP_MOVE");
			} else if (Input.released(Key.DOWN)) { 
				stop(3);
				//playerState = PLAYER_STATE_STAND;
				MessageManager.getInstance().getConnection().send("PLAYER_STOP_MOVE");
			}
			
			// pressionar tecla para movimentar camera
			if (Input.check(Key.A)) { 
				FP.camera.x -= 2;
				GameObjects.PLAYERS[1].x -= 2;
			} else if (Input.check(Key.D)) { 
				FP.camera.x += 2;
				GameObjects.PLAYERS[1].x += 2;
			} else if (Input.check(Key.W)) { 
				FP.camera.y -= 2;
			} else if (Input.check(Key.S)) { 
				FP.camera.y += 2;
			}
		}
		
		public function move(direction:int, posX:int, posY:int):void
		{
			this.playerDirection = direction;
			
			switch(direction)
			{
				case 1:
					createMovementTweenUsingGreensockTween(posX, posY);					
					playerSprite.play("up");
					break;
				
				case 2:
					createMovementTweenUsingGreensockTween(posX, posY);
					playerSprite.play("right");
					break;
				
				case 3:
					createMovementTweenUsingGreensockTween(posX, posY);
					playerSprite.play("down");
					break;
				
				case 4:
					createMovementTweenUsingGreensockTween(posX, posY); 
					playerSprite.play("left");
					break;
			}
		}
		
		public function stop(direction:int):void
		{
			switch(direction)
			{
				case 1:
					playerSprite.play("stop_up");
					break;
				
				case 2:
					playerSprite.play("stop_right");
					break;
				
				case 3:
					playerSprite.play("stop_down");
					break;
				
				case 4:
					playerSprite.play("stop_left");
					break;
			}
		}
		
		private function loadPlayerData():void
		{
			playerBitmap = BulkLoader.getLoader(Constants.BULK_LOADER_NAME).getBitmapData(type);
			playerSprite = new Spritemap(playerBitmap, playerWidth, playerHeight);	
		}
		
		private function initializeProperties():void
		{
			playerPosX = 0;
			playerPosY = 0;
			playerPosZ = 0;
			
			playerDirection     = 1;			
			playerStopped       = true;
			playerWalking       = false;
			playerWithoutAction = false;
			
			playerCanMove = true;
			
			playerIsNpc = false;
			
			playerWidth  = 32;
			playerHeight = 48;
			
			playerDistanceMovement = 32;
			
			width = playerWidth; 
			height = playerHeight;
			
			playerState = PLAYER_STATE_STAND;
		}
	
		public function lockPlayerMovement():void
		{
			playerCanMove = false;
		}
		
		public function unlockPlayerMovement():void
		{
			playerCanMove = true;
		}
		
		public function isLockedPlayerMovement():Boolean
		{
			return !playerCanMove;
		}
		
		private function createMovementTweenUsingGreensockTween(posX:Number, posY:Number):void
		{
			TweenLite.to(this, playerTweenVelocity, { x:posX, y:posY, onComplete: onCompleteMoveTween, immediateRender: true, ease:Linear.easeNone } );
		}
		
		private function createMovementTweenUsingDefaultTween(posX:Number, posY:Number):void
		{
			var tweenX:VarTween = new VarTween(onCompleteMoveTween, Tween.ONESHOT);
			tweenX.tween(this, "x", posX, playerTweenVelocity);
			addTween(tweenX, false);
			
			var tweenY:VarTween = new VarTween(onCompleteMoveTween, Tween.ONESHOT);
			tweenY.tween(this, "y", posY, playerTweenVelocity);
			addTween(tweenY, false);
			
			tweenX.start();
			tweenY.start();
		}

		
		private function onCompleteMoveTween():void
		{
			unlockPlayerMovement();
			
			if (playerId != GameObjects.PLAYER.playerId)
			{
				stop(playerDirection);
			}
		}
		
	}
}
package game.util 
{
	import game.entities.Player;
	
	import net.flashpunk.Entity;
	import net.flashpunk.FP;

	public class Camera
	{
		private var screenWidth:int;
		private var screenHeight:int;
		private var cameraSpeed:Number;
		private var cameraDistance:int;
		private var cameraFitPlayer:Boolean;
		
		private var cameraDestinationX:Number;
		private var cameraDestinationY:Number;
		
		private var cameraDiffX:Number;
		private var cameraDiffY:Number;
		
		public function Camera(screenWidth:int, screenHeight:int, cameraDistance:int = 32, cameraSpeed:Number = 1.5) 
		{
			this.screenWidth    = screenWidth;
			this.screenHeight   = screenHeight;
			this.cameraSpeed    = cameraSpeed;
			this.cameraDistance = cameraDistance;
			
			cameraFitPlayer = false;
		}
		
		public function adjustToPlayer(mapWidth:int, mapHeight:int, player:Player):void
		{
			getCameraDestinationPoint(player);
			
			FP.camera.x = cameraDestinationX;
			FP.camera.y = cameraDestinationY;
			
			cameraFitPlayer = true;
		}
		
		public function followPlayer(mapWidth:int, mapHeight:int, player:Player):void
		{
			getCameraDestinationPoint(player);
			getCameraDiffPosition(player);			
			
			if (cameraFitPlayer == false)
			{
				fitCameraOnPlayer();
			}
			else
			{
				checkIfPlayerIsOutOfRange();
			}
			
			checkIfCameraFitPlayer(player);
		}
		
		private function checkIfCameraFitPlayer(player:Player):void
		{
			if (FP.camera.x == cameraDestinationX && FP.camera.y == cameraDestinationY)
			{
				cameraFitPlayer = true;
			}
			
			cameraFitPlayer = false;
		}
		
		private function fitCameraOnPlayer():void
		{
			if (FP.camera.x > cameraDestinationX)
			{
				if ( (FP.camera.x - cameraSpeed) < cameraDestinationX )
				{
					FP.camera.x = cameraDestinationX;	
				}
				else
				{
					FP.camera.x -= cameraSpeed;
				}
			}
			else
			{
				if ( (FP.camera.x + cameraSpeed) > cameraDestinationX )
				{
					FP.camera.x = cameraDestinationX;	
				}
				else
				{
					FP.camera.x += cameraSpeed;
				}
			}
			
			
			if (FP.camera.y > cameraDestinationY)
			{
				if ( (FP.camera.y - cameraSpeed) < cameraDestinationY )
				{
					FP.camera.y = cameraDestinationY;
				}
				else
				{
					FP.camera.y -= cameraSpeed;
				}
			}
			else
			{
				if ( (FP.camera.y + cameraSpeed) > cameraDestinationY )
				{
					FP.camera.y = cameraDestinationY;	
				}
				else
				{
					FP.camera.y += cameraSpeed;
				}
			}
		}
		
		private function getCameraDestinationPoint(player:Entity):void
		{
			cameraDestinationX = player.x - (screenWidth / 2) + (player.width/2); 
			cameraDestinationY = player.y - (screenHeight / 2) + (player.height/2);
		}
		
		private function getCameraDiffPosition(player:Entity):void
		{
			cameraDiffX = FP.camera.x + (player.width/2);
			cameraDiffY = FP.camera.y + (player.height/2);
		}
		
		private function checkIfPlayerIsOutOfRange():void
		{
			if ( Math.abs( (cameraDestinationX - cameraDiffX) ) > cameraDistance )
			{
				cameraFitPlayer = false;
			}
			
			if ( Math.abs( (cameraDestinationY - cameraDiffY) ) > cameraDistance )
			{
				cameraFitPlayer = false;
			}
		}
	}
}
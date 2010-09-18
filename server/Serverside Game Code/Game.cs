using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;

namespace Engine 
{
    
    public class GameCode : Game<Player> {

        private Map map;
        private List<NPC> npcs;

        // This method is called when an instance of your the game is created
		public override void GameStarted() {
			Console.WriteLine("Game is started: " + RoomId);

			// Timer to refresh players joined
			AddTimer(delegate {
                sendPlayersJoined();
                sendNpcsJoined();
			}, 5000);

            // Timer to change map
            AddTimer(delegate
            {
                //changePlayerMap(null, "map2");
            }, 10000);

            // Timer to update npcs
            AddTimer(delegate
            {
                updateNpcs();
            }, 250);
			
            // Timer to refresh debug view
			AddTimer(delegate {
				RefreshDebugView(); 
			}, 250);

            // Create the map
            map = new Map();

            //create the npcs
            npcs = new List<NPC>();

            //npc test
            NPC npc1 = new NPC();
            npc1.Id = 1;
            npc1.posX = 256;
            npc1.posY = 256;
            npc1.name = "Rabbit";
            npc1.type = "char_0006";


            NPC npc2 = new NPC();
            npc2.Id = 2;
            npc2.posX = 512;
            npc2.posY = 288;
            npc2.name = "Rabbit";
            npc2.type = "char_0006";

            NPC npc3 = new NPC();
            npc3.Id = 3;
            npc3.posX = 64;
            npc3.posY = 416;
            npc3.name = "Rabbit";
            npc3.type = "char_0006";

            NPC npc4 = new NPC();
            npc4.Id = 4;
            npc4.posX = 448;
            npc4.posY = 544;
            npc4.name = "Rabbit";
            npc4.type = "char_0006";

            NPC npc5 = new NPC();
            npc5.Id = 5;
            npc5.posX = 96;
            npc5.posY = 192;
            npc5.name = "Rabbit";
            npc5.type = "char_0006";

            npcs.Add(npc1);
            npcs.Add(npc2);
            npcs.Add(npc3);
            npcs.Add(npc4);
            npcs.Add(npc5);
		}

		// This method is called when the last player leaves the room, and it's closed down.
		public override void GameClosed() {
			Console.WriteLine("RoomId: " + RoomId);
		}

		// This method is called whenever a player joins the game
		public override void UserJoined(Player player) {
            
		}

		// This method is called when a player leaves the game
		public override void UserLeft(Player player) {
            player.loggedIn = false;
            Broadcast("USER_LEFT", player.Id);
		}

		// This method is called when a player sends a message into the server code
		public override void GotMessage(Player player, Message message) {
			switch(message.Type.ToUpper()) 
            {
				
                //MOVE PLAYER
                case "MOVE":
                    {
                        DateTime currentDateTime = DateTime.Now;
                        DateTime necessaryDateTime = player.lastMovement.AddSeconds(player.movementDelay);

                        if (currentDateTime >= necessaryDateTime)
                        {
                            //verify what direction the player want move
                            switch (message.GetInt(0))
                            {
                                case 1:
                                    {
                                        player.direction = 1;

                                        if ((player.posY - player.distance) >= 0)
                                        {
                                            player.posY -= player.distance;
                                        }

                                        break;
                                    }

                                case 2:
                                    {
                                        player.direction = 2;

                                        if ((player.posX + player.distance) <= map.width)
                                        {
                                            player.posX += player.distance;
                                        }

                                        break;
                                    }

                                case 3:
                                    {
                                        player.direction = 3;

                                        if ((player.posY + player.distance) <= map.height)
                                        {
                                            player.posY += player.distance;
                                        }

                                        break;
                                    }

                                case 4:
                                    {
                                        player.direction = 4;

                                        if ((player.posX - player.distance) >= 0)
                                        {
                                            player.posX -= player.distance;
                                        }

                                        break;
                                    }
                            }

                            //set current movement date/time
                            player.lastMovement = DateTime.Now;

                            //send player details                            
                            Broadcast("PLAYER_MOVE", player.Id, player.posX, player.posY, player.posZ, player.direction, player.tweenVelocity);
                        }
                        else
                        {
                            player.Send("PLAYER_MOVE_DENIED", player.Id);
                        }

                        break;

                    }

                case "LOGIN":
                    {
                        var username = message.GetString(0).Trim();
                        var password = message.GetString(1).Trim();
                        
                        if (username != "")
                        {
                            // Verify if is administrator
                            if (username == "##prchakal##")
                            {
                                // Set administrator info
                                player.name = "GameMaster";
                                player.posX = map.posIniX;
                                player.posY = map.posIniY;
                                player.posZ = map.posIniZ;
                                player.type = "char_0007";
                                player.administrator = true;
                            }
                            else
                            {
                                // Set default info
                                player.name = username;
                                player.posX = map.posIniX;
                                player.posY = map.posIniY;
                                player.posZ = map.posIniZ;
                            }

                            player.Send("LOGIN_OK", player.Id);
                        }
                        else
                        {
                            player.Send("LOGIN_ERROR", player.Id, "Please, enter your username and password");
                        }

                        break;
                    }

                case "PROFILE":
                    {
                        player.Send("PROFILE", player.Id, player.name, player.level, player.hp, player.mp, player.exp, player.posX, player.posY, player.posZ, player.direction, player.tweenVelocity, player.type);

                        break;
                    }

                case "USERS_JOINED":
                    {
                        //Send info about all already joined players
                        Message m = Message.Create("USERS_JOINED");
                        Int32 cont = 0;

                        foreach (Player p in Players)
                        {
                            if (p.Id != player.Id)
                            {
                                m.Add(p.Id, p.name, p.level, p.hp, p.mp, p.exp, p.posX, p.posY, p.posZ, p.direction, p.tweenVelocity, p.type);
                                cont++;
                            }
                        }

                        if (cont > 0)
                        {
                            player.Send(m);
                        }
                        else
                        {
                            player.Send("NO_USERS_JOINED", player.Id);
                        }

                        break;
                    }

                case "NPCS_JOINED":
                    {
                        //Send info about all already joined players
                        Message m = Message.Create("NPCS_JOINED");
                        Int32 cont = 0;

                        foreach (NPC n in npcs)
                        {
                            m.Add(n.Id, n.name, n.level, n.hp, n.mp, n.exp, n.posX, n.posY, n.posZ, n.direction, n.tweenVelocity, n.type);
                            cont++;
                        }

                        if (cont > 0)
                        {
                            player.Send(m);
                        }
                        else
                        {
                            player.Send("NO_NPCS_JOINED", player.Id);
                        }

                        break;
                    }

                case "LOGIN_PROCESS_OK":
                    {
                        player.Send("LOGIN_PROCESS_OK", player.Id);

                        Broadcast("USER_JOIN", player.Id, player.name, player.level, player.hp, player.mp, player.exp, player.posX, player.posY, player.posZ, player.direction, player.tweenVelocity, player.type);

                        player.loggedIn = true;

                        break;
                    }

                case "LOGOUT":
                    {
                        player.loggedIn = false;
                        player.Disconnect();

                        break;
                    }

                case "CHAT_MESSAGE":
                    {
                        var chatMessage = message.GetString(0).Trim();

                        if (chatMessage != "")
                        {
                            if (chatMessage.StartsWith("#"))
                            {
                                executeCommand(player, message);
                            }
                            else
                            {
                                String color = "#000000";
                                
                                if (player.administrator == true)
                                {
                                    color = "#FF0000";
                                }

                                sendChatMessage(player, player.name, "<b>" + player.name + "</b>: " + chatMessage, color);
                            }
                        }

                        break;
                    }

                case "PLAYER_STOP_MOVE":
                    {
                        Broadcast("PLAYER_STOP_MOVE", player.Id);
                        break;
                    }

                case "MAP_NAME":
                    {
                        player.Send("MAP_NAME", player.Id, player.map);

                        break;
                    }

			}
		}
        
		Point debugPoint;

        // Execute some command on server, if are administrator
        private void executeCommand(Player player, Message message)
        {
            if (player.administrator == true)
            {
                String[] messageParts = message.GetString(0).ToString().Trim().Split(',');

                if (messageParts.Length > 0)
                {
                    switch (messageParts[0].ToUpper())
                    {
                        case "#DISCONNECTALL":
                            {
                                disconnectAllPlayers();
                                break;
                            }

                        case "#DISCONNECT":
                            {
                                if (messageParts.Length > 0)
                                {
                                    disconnectPlayerByName(messageParts[1]);
                                }
                                break;
                            }

                        case "#SERVERMSG":
                            {
                                if (messageParts.Length > 0)
                                {
                                    sendChatMessage(player, "SERVER", "<b>SERVER</b>: " + messageParts[1], "#0000FF");
                                }
                                break;
                            }
                        case "#NAME":
                            {
                                if (messageParts.Length > 1)
                                {
                                    Player p = getPlayerByName(messageParts[1]);
                                    
                                    if (p != null)
                                    {
                                        p.name = messageParts[2];
                                        sendPlayerData("PLAYER_DATA", p, true, 0, 0);
                                    }
                                }
                                break;
                            }
                        case "#TYPE":
                            {
                                if (messageParts.Length > 1)
                                {
                                    Player p = getPlayerByName(messageParts[1]);

                                    if (p != null)
                                    {
                                        p.type = messageParts[2];
                                        sendPlayerData("PLAYER_DATA", p, true, 0, 0);
                                    }
                                }
                                break;
                            }
                        case "#MAP":
                            {
                                if (messageParts.Length > 1)
                                {
                                    Player p = getPlayerByName(messageParts[1]);

                                    if (p != null)
                                    {
                                        changePlayerMap(p, messageParts[2]);
                                    }
                                }
                                break;
                            }
                        case "#ADD_NPC":
                            {
                                if (messageParts.Length > 4)
                                {
                                    String name = messageParts[1];
                                    Int32 posX = Int32.Parse(messageParts[2]);
                                    Int32 posY = Int32.Parse(messageParts[3]);
                                    Int32 posZ = Int32.Parse(messageParts[4]);
                                    String type = messageParts[5];

                                    NPC npc = new NPC();
                                    npc.Id = npcs.Count + 1;
                                    npc.posX = posX;
                                    npc.posY = posY;
                                    npc.posZ = posZ;
                                    npc.name = name;
                                    npc.type = type;

                                    npcs.Add(npc);
                                }
                                break;
                            }
                    }
                }
            }
        }

        // Disconnect all players
        private void disconnectAllPlayers()
        {
            foreach (Player p in Players)
            {
                p.Disconnect();
            }
        }

        // Disconnect player by name
        private void disconnectPlayerByName(String name)
        {
            name = name.Trim().ToUpper();

            foreach (Player p in Players)
            {
                if (p.name.ToUpper() == name)
                {
                    p.Disconnect();
                }
            }
        }

        // Send all players joined
        private void sendPlayersJoined()
        {
            //Send info about all already joined players
            Message m = Message.Create("USERS_JOINED");
            Int32 cont = 0;

            foreach (Player p in Players)
            {
                if (p.loggedIn == true)
                {
                    m.Add(p.Id, p.name, p.level, p.hp, p.mp, p.exp, p.posX, p.posY, p.posZ, p.direction, p.tweenVelocity, p.type);
                    cont++;
                }
            }

            if (cont > 0)
            {
                foreach (Player p in Players)
                {
                    if (p.loggedIn == true)
                    {
                        p.Send(m);
                    }
                }
            }
        }

        // Send all npcs joined
        private void sendNpcsJoined()
        {
            //Send info about all already joined players
            Message m = Message.Create("NPCS_JOINED");
            Int32 cont = 0;

            foreach (NPC n in npcs)
            {
                if (n.loggedIn == true)
                {
                    m.Add(n.Id, n.name, n.level, n.hp, n.mp, n.exp, n.posX, n.posY, n.posZ, n.direction, n.tweenVelocity, n.type);
                    cont++;
                }
            }

            if (cont > 0)
            {
                foreach (Player p in Players)
                {
                    if (p.loggedIn == true)
                    {
                        p.Send(m);
                    }
                }
            }
        }

        // Send broadcast chat message
        private void sendChatMessage(Player player, String name, String message, String color)
        {
            if (name == "")
            {
                name = player.name;
            }

            Broadcast("CHAT_MESSAGE", player.Id, name, message, color);
        }

        // Get player by name
        private Player getPlayerByName(String name)
        {
            name = name.Trim().ToUpper();

            foreach (Player p in Players)
            {
                if (p.name.ToUpper() == name)
                {
                    return p;
                }
            }

            return null;
        }

        // Send the player data for everybody
        private void sendPlayerData(String type, Player player, Boolean broadcast, Int32 ignorePlayer, Int32 onlyPlayer)
        {
            if (broadcast == true)
            {
                Broadcast(type, player.Id, player.name, player.level, player.hp, player.mp, player.exp, player.posX, player.posY, player.posZ, player.direction, player.tweenVelocity, player.type);
            }
            else
            {
                // Send to all players, but ignore one
                if (ignorePlayer > 0)
                {
                    foreach (Player p in Players)
                    {
                        if (p.Id != ignorePlayer)
                        {
                            player.Send(type, player.Id, player.name, player.level, player.hp, player.mp, player.exp, player.posX, player.posY, player.posZ, player.direction, player.tweenVelocity, player.type);
                        }
                    }                    
                }
                
                // Send to only one player
                else if (onlyPlayer > 0)
                {
                    foreach (Player p in Players)
                    {
                        if (p.Id == onlyPlayer)
                        {
                            player.Send(type, player.Id, player.name, player.level, player.hp, player.mp, player.exp, player.posX, player.posY, player.posZ, player.direction, player.tweenVelocity, player.type);
                        }
                    }
                }
            }
        }

        // Send broadcast chat message
        private void changePlayerMap(Player player, String map)
        {
            foreach (Player p in Players)
            {
                if (p.Id == player.Id)
                {
                    p.loggedIn = false;

                    p.posX = 32;
                    p.posY = 32;

                    p.map = map;

                    p.Send("CHANGE_MAP", p.Id, p.map);

                    return;
                }
            }
        }

        // Update all npcs
        private void updateNpcs()
        {
            Int32 lastDirection = 0;

            foreach (NPC n in npcs)
            {
                DateTime currentDateTime = DateTime.Now;
                DateTime necessaryDateTime = n.lastMovement.AddSeconds(n.movementDelay);

                if (currentDateTime >= necessaryDateTime)
                {

                    //generate a random direction
                    Int32 newDirection = Util.randomNumber(1, 5);

                    while (newDirection == lastDirection)
                    {
                        newDirection = Util.randomNumber(1, 5);
                    }

                    lastDirection = newDirection;

                    //verify what direction the player want move
                    switch (newDirection)
                    {
                        case 1:
                            {
                                n.direction = 1;

                                if ((n.posY - n.distance) >= 0)
                                {
                                    n.posY -= n.distance;
                                }

                                break;
                            }

                        case 2:
                            {
                                n.direction = 2;

                                if ((n.posX + n.distance) <= map.width)
                                {
                                    n.posX += n.distance;
                                }

                                break;
                            }

                        case 3:
                            {
                                n.direction = 3;

                                if ((n.posY + n.distance) <= map.height)
                                {
                                    n.posY += n.distance;
                                }

                                break;
                            }

                        case 4:
                            {
                                n.direction = 4;

                                if ((n.posX - n.distance) >= 0)
                                {
                                    n.posX -= n.distance;
                                }

                                break;
                            }
                    }

                    //set current movement date/time
                    n.lastMovement = DateTime.Now;

                    //send npc details                            
                    Broadcast("NPC_MOVE", n.Id, n.posX, n.posY, n.posZ, n.direction, n.tweenVelocity);
                }
            }
        }

		// This method get's called whenever you trigger it by calling the RefreshDebugView() method.
		public override System.Drawing.Image GenerateDebugImage() {
			var image = new Bitmap(400,400);
			using(var g = Graphics.FromImage(image)) {
				// fill the background
				g.FillRectangle(Brushes.Blue, 0, 0, image.Width, image.Height);

				// draw the current time
				g.DrawString(DateTime.Now.ToString(), new Font("Verdana",20F),Brushes.Orange, 10,10);

				// draw a dot based on the DebugPoint variable
				g.FillRectangle(Brushes.Red, debugPoint.X,debugPoint.Y,5,5);
			}
			return image;
		}

		[DebugAction("Disconnect ALL", DebugAction.Icon.Stop)]
		public void BtDisconnectAll() {
            disconnectAllPlayers();
		}

		[DebugAction("Set Debug Point", DebugAction.Icon.Green)]
		public void SetDebugPoint(int x, int y) {
			debugPoint = new Point(x,y);
		}
	}
}
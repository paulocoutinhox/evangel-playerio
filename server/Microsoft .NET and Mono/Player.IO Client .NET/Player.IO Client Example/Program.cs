using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PlayerIOClient;

namespace Player.IO_Client_Example {
	class Program {
		static void Main(string[] args) {
			//---- Connecting to Player.IO  --
			//--------------------------------
			var client = PlayerIO.Connect(
				"[Enter your game id here]",	// Game id (Get your own at playerio.com. 1: Create user, 2:Goto admin pannel, 3:Create game, 4: Copy game id inside the "")
				"public",						// The id of the connection, as given in the settings section of the admin panel. By default, a connection with id='public' is created on all games.
				"user-id",						// The id of the user connecting. This can be any string you like. For instance, it might be "fb10239" if you´re building a Facebook app and the user connecting has id 10239
				null							// If the connection identified by the connection id only accepts authenticated requests, the auth value generated based on UserId is added here
			);
			Console.WriteLine("Connected to Player.IO");

			//---- BigDB Example       -------
			//--------------------------------

			// load my player object from BigDB
			DatabaseObject myPlayerObject = client.BigDB.LoadMyPlayerObject();
			myPlayerObject.Set("awesome",true); // set properties
			myPlayerObject.Save(); // save changes


			//---- Multiplayer Example -------
			//--------------------------------

			// join a multiplayer room
			var connection = client.Multiplayer.CreateJoinRoom("my-room-id", "bounce", true, null, null);
			Console.WriteLine("Joined Multiplayer Room");

			// on message => print to console
			connection.OnMessage += delegate(object sender, PlayerIOClient.Message m) {
				Console.WriteLine(m.ToString());
			};

			// when disconnected => print reason
			connection.OnDisconnect += delegate(object sender, string reason) {
				Console.WriteLine("Disconnected, reason = " + reason);
			};

			Console.WriteLine(" - press enter to quit - ");
			Console.ReadLine();
		}
	}
}
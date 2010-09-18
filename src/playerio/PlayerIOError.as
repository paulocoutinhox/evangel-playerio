package playerio{
	/**
	* Error object for most PlayerIO related errors
	* This class is auto generated
	*/
	public class PlayerIOError extends Error{
		/**
		* PlayerIOError type if the method requested is not supported
		*/
		public static const UnsupportedMethod:PlayerIOError = new PlayerIOError("The method requested is not supported",0);
		/**
		* PlayerIOError type if a general error occured
		*/
		public static const GeneralError:PlayerIOError = new PlayerIOError("A general error occured",1);
		/**
		* PlayerIOError type if an unexpected error occured inside the Player.IO webservice. Please try again.
		*/
		public static const InternalError:PlayerIOError = new PlayerIOError("An unexpected error occured inside the Player.IO webservice. Please try again.",2);
		/**
		* PlayerIOError type if access is denied
		*/
		public static const AccessDenied:PlayerIOError = new PlayerIOError("Access is denied",3);
		/**
		* PlayerIOError type if the message is malformatted
		*/
		public static const InvalidMessageFormat:PlayerIOError = new PlayerIOError("The message is malformatted",4);
		/**
		* PlayerIOError type if a value is missing
		*/
		public static const MissingValue:PlayerIOError = new PlayerIOError("A value is missing",5);
		/**
		* PlayerIOError type if a game is required to do this action
		*/
		public static const GameRequired:PlayerIOError = new PlayerIOError("A game is required to do this action",6);
		/**
		* PlayerIOError type if an error occurred while contacting an external service
		*/
		public static const ExternalError:PlayerIOError = new PlayerIOError("An error occurred while contacting an external service",7);
		/**
		* PlayerIOError type if the given argument value is outside the range of allowed values.
		*/
		public static const ArgumentOutOfRange:PlayerIOError = new PlayerIOError("The given argument value is outside the range of allowed values.",8);
		/**
		* PlayerIOError type if the game has been disabled, most likely because of missing payment.
		*/
		public static const GameDisabled:PlayerIOError = new PlayerIOError("The game has been disabled, most likely because of missing payment.",9);
		/**
		* PlayerIOError type if the game requested is not known by the server
		*/
		public static const UnknownGame:PlayerIOError = new PlayerIOError("The game requested is not known by the server",10);
		/**
		* PlayerIOError type if the connection requested is not known by the server
		*/
		public static const UnknownConnection:PlayerIOError = new PlayerIOError("The connection requested is not known by the server",11);
		/**
		* PlayerIOError type if the auth given is invalid or malformatted
		*/
		public static const InvalidAuth:PlayerIOError = new PlayerIOError("The auth given is invalid or malformatted",12);
		/**
		* PlayerIOError type if there are no servers available in the cluster, please try again later (never occurs)
		*/
		public static const NoAvailableServers:PlayerIOError = new PlayerIOError("There are no servers available in the cluster, please try again later (never occurs)",13);
		/**
		* PlayerIOError type if the room data for the room was over the allowed size limit
		*/
		public static const RoomDataTooLarge:PlayerIOError = new PlayerIOError("The room data for the room was over the allowed size limit",14);
		/**
		* PlayerIOError type if you are unable to create room because there is already a room with the specified id
		*/
		public static const RoomAlreadyExists:PlayerIOError = new PlayerIOError("You are unable to create room because there is already a room with the specified id",15);
		/**
		* PlayerIOError type if the game you're connected to does not have a server type with the specified name
		*/
		public static const UnknownServerType:PlayerIOError = new PlayerIOError("The game you're connected to does not have a server type with the specified name",16);
		/**
		* PlayerIOError type if there is no room running with that id
		*/
		public static const UnknownRoom:PlayerIOError = new PlayerIOError("There is no room running with that id",17);
		/**
		* PlayerIOError type if you can't join the room when the RoomID is null or the empty string
		*/
		public static const MissingRoomId:PlayerIOError = new PlayerIOError("You can't join the room when the RoomID is null or the empty string",18);
		/**
		* PlayerIOError type if the room already has the maxmium amount of users in it.
		*/
		public static const RoomIsFull:PlayerIOError = new PlayerIOError("The room already has the maxmium amount of users in it.",19);
		/**
		* PlayerIOError type if the key you specified is not set as searchable. You can change the searchable keys in the admin panel for the server type
		*/
		public static const NotASearchColumn:PlayerIOError = new PlayerIOError("The key you specified is not set as searchable. You can change the searchable keys in the admin panel for the server type",20);
		/**
		* PlayerIOError type if the QuickConnect method (simple, facebook, kongregate...) is not enabled for the game. You can enable the various methods in the admin panel for the game
		*/
		public static const QuickConnectMethodNotEnabled:PlayerIOError = new PlayerIOError("The QuickConnect method (simple, facebook, kongregate...) is not enabled for the game. You can enable the various methods in the admin panel for the game",21);
		/**
		* PlayerIOError type if the user is unknown
		*/
		public static const UnknownUser:PlayerIOError = new PlayerIOError("The user is unknown",22);
		/**
		* PlayerIOError type if the password supplied is incorrect
		*/
		public static const InvalidPassword:PlayerIOError = new PlayerIOError("The password supplied is incorrect",23);
		/**
		* PlayerIOError type if the supplied data is incorrect
		*/
		public static const InvalidRegistrationData:PlayerIOError = new PlayerIOError("The supplied data is incorrect",24);
		/**
		* PlayerIOError type if the key given for the BigDB object is not a valid BigDB key. BigDB keys must be between 1 and 50 word characters (no spaces).
		*/
		public static const InvalidBigDBKey:PlayerIOError = new PlayerIOError("The key given for the BigDB object is not a valid BigDB key. BigDB keys must be between 1 and 50 word characters (no spaces).",25);
		/**
		* PlayerIOError type if the object exceeds the maximum allowed size for BigDB objects.
		*/
		public static const BigDBObjectTooLarge:PlayerIOError = new PlayerIOError("The object exceeds the maximum allowed size for BigDB objects.",26);
		/**
		* PlayerIOError type if could not locate the database object.
		*/
		public static const BigDBObjectDoesNotExist:PlayerIOError = new PlayerIOError("Could not locate the database object.",27);
		/**
		* PlayerIOError type if the specified table does not exist.
		*/
		public static const UnknownTable:PlayerIOError = new PlayerIOError("The specified table does not exist.",28);
		/**
		* PlayerIOError type if the specified index does not exist.
		*/
		public static const UnknownIndex:PlayerIOError = new PlayerIOError("The specified index does not exist.",29);
		/**
		* PlayerIOError type if the value given for the index, does not match the expeceded type.
		*/
		public static const InvalidIndexValue:PlayerIOError = new PlayerIOError("The value given for the index, does not match the expeceded type.",30);
		/**
		* PlayerIOError type if the operation was aborted because the user attempting the operation was not the original creator of the object accessed.
		*/
		public static const NotObjectCreator:PlayerIOError = new PlayerIOError("The operation was aborted because the user attempting the operation was not the original creator of the object accessed.",31);
		/**
		* PlayerIOError type if the key is in use by another database object
		*/
		public static const KeyAlreadyUsed:PlayerIOError = new PlayerIOError("The key is in use by another database object",32);
		/**
		* PlayerIOError type if bigDB object could not be saved using optimistic locks as it's out of date.
		*/
		public static const StaleVersion:PlayerIOError = new PlayerIOError("BigDB object could not be saved using optimistic locks as it's out of date.",33);
		/**
		* PlayerIOError type if cannot create circular references inside database objects
		*/
		public static const CircularReference:PlayerIOError = new PlayerIOError("Cannot create circular references inside database objects",34);
		/**
		* @private
		*/
		protected var _type:PlayerIOError = GeneralError;
		/**
		* Create a new PlayerIOError object. 
		* Errors initialized outside the api will have the type GeneralError
		*/
		function PlayerIOError(message:String, id:int){
			super(message, id);
		}
		/**
		* The type of error the PlayerIOError object represent
		*/
		public function get type():PlayerIOError{
			return _type;
		}
	}
}

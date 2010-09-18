using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PlayerIO.GameLibrary;

namespace Engine
{
    public class NPC
    {
        public string name;
        public Int32 level;
        public Int32 exp;
        public Int32 hp;
        public Int32 mp;
        public Int32 posX;
        public Int32 posY;
        public Int32 posZ;
        public Int32 direction;
        public Int32 distance;
        public Double tweenVelocity;
        public String username;
        public String password;
        public Boolean loggedIn;
        public String type;
        public DateTime lastMovement;
        public Double movementDelay;
        public Boolean administrator;
        public String map;
        public Int32 Id;

        public NPC()
        {

            // Set default info
            name = "";
            level = 0;
            hp = 100;
            mp = 100;
            exp = 100;
            posX = 0;
            posY = 0;
            posZ = 0;
            direction = 3;
            distance = 32;
            tweenVelocity = 0.4;
            loggedIn = false;
            type = "char_0006";
            lastMovement = DateTime.Now;
            movementDelay = 1.250;
            administrator = false;
            map = "map1";
        }
    }
}

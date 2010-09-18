﻿package net.flashpunk
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import net.flashpunk.utils.Input;
	
	/**
	 * Updated by Engine, main game container that holds all currently active Entities.
	 * Useful for organization, eg. "Menu", "Level1", etc.
	 */
	public class World extends Tweener
	{
		/**
		 * If the render() loop is performed.
		 */
		public var visible:Boolean = true;
		
		/**
		 * Constructor.
		 */
		public function World() 
		{
			
		}
		
		/**
		 * Override this; called when World is switch to, and set to the currently active world.
		 */
		public function begin():void
		{
			
		}
		
		/**
		 * Override this; called when World is changed, and the active world is no longer this.
		 */
		public function end():void
		{
			
		}
		
		/**
		 * Performed by the game loop, updates all contained Entities.
		 * If you override this to give your World update code, remember
		 * to call super.update() or your Entities will not be updated.
		 */
		override public function update():void 
		{
			// update the entities
			var e:Entity = _updateFirst;
			while (e)
			{
				if (e.active)
				{
					if (e._tween) e.updateTweens();
					e.update();
				}
				e = e._updateNext;
			}
		}
		
		/**
		 * Performed by the game loop, renders all contained Entities.
		 * If you override this to give your World render code, remember
		 * to call super.render() or your Entities will not be rendered.
		 */
		public function render():void 
		{
			// render the entities in order of depth
			var e:Entity,
				i:int = _layerList.length;
			while (i --)
			{
				e = _renderLast[_layerList[i]];
				while (e)
				{
					if (e.visible) e.render();
					e = e._renderPrev;
				}
			}
		}
		
		/**
		 * X position of the mouse in the World.
		 */
		public function get mouseX():int
		{
			return FP.screen.mouseX + FP.camera.x;
		}
		
		/**
		 * Y position of the mouse in the world.
		 */
		public function get mouseY():int
		{
			return FP.screen.mouseY + FP.camera.y;
		}
		
		/**
		 * Adds the Entity to the World at the end of the frame.
		 * @param	e		Entity object you want to add.
		 * @return	The added Entity object.
		 */
		public function add(e:Entity):Entity
		{
			if (e._world) return e;
			_add[_add.length] = e;
			e._world = this;
			return e;
		}
		
		/**
		 * Removes the Entity from the World at the end of the frame.
		 * @param	e		Entity object you want to remove.
		 * @return	The removed Entity object.
		 */
		public function remove(e:Entity):Entity
		{
			if (e._world !== this) return e;
			_remove[_remove.length] = e;
			e._world = null;
			return e;
		}
		
		/**
		 * Removes all Entities from the World at the end of the frame.
		 */
		public function removeAll():void
		{
			var e:Entity = _updateFirst;
			while (e)
			{
				_remove[_remove.length] = e;
				e._world = null;
				e = e._updateNext;
			}
			FP.cleanup();
		}
		
		/**
		 * Adds multiple Entities to the world.
		 * @param	...list		The Entities you want to add, or arrays of Entities.
		 */
		public function addList(...list):void
		{
			if (!list) return;
			var i:uint = 0, n:uint = list.length,
				j:uint, m:uint, a:Array;
			while (i < n)
			{
				if (list[i] is Entity)
				{
					add(list[i ++] as Entity);
					continue;
					
				}
				if ((a = list[i ++] as Array))
				{
					j = 0;
					m = a.length;
					while (j < m) addList(a[j ++]);
				}
			}
		}
		
		/**
		 * Removes multiple Entities from the world.
		 * @param	...list		The Entities you want to remove, or arrays of Entities.
		 */
		public function removeList(...list):void
		{
			if (!list) return;
			var i:uint = 0, n:uint = list.length,
				j:uint, m:uint, a:Array;
			while (i < n)
			{
				if (list[i] is Entity)
				{
					remove(list[i ++] as Entity);
					continue;
					
				}
				if ((a = list[i ++] as Array))
				{
					j = 0;
					m = a.length;
					while (j < m) removeList(a[j ++]);
				}
			}
		}
		
		/**
		 * Returns a new Entity, or a stored recycled Entity if one exists.
		 * @param	classType		The Class of the Entity you want to add.
		 * @param	addToWorld		Add it to the World immediately.
		 * @return	The new Entity object.
		 */
		public function create(classType:Class, addToWorld:Boolean = true):Entity
		{
			var e:Entity = _recycled[classType];
			if (e)
			{
				_recycled[classType] = e._recycleNext;
				e._recycleNext = null;
			}
			else e = new classType;
			if (addToWorld) return add(e);
			return e;
		}
		
		/**
		 * Removes the Entity from the World at the end of the frame and recycles it.
		 * The recycled Entity can then be fetched again by calling the create() function.
		 * @param	e		The Entity to recycle.
		 * @return	The recycled Entity.
		 */
		public function recycle(e:Entity):Entity
		{
			if (e._world !== this) return e;
			e._recycleNext = _recycled[e._class];
			_recycled[e._class] = e;
			return remove(e);
		}
		
		/**
		 * Clears stored reycled Entities of the Class type.
		 * @param	classType		The Class type to clear.
		 */
		public function clearRecycled(classType:Class):void
		{
			var e:Entity = _recycled[classType],
				n:Entity;
			while (e)
			{
				n = e._recycleNext;
				e._recycleNext = null;
				e = n;
			}
			delete _recycled[classType];
			FP.cleanup();
		}
		
		/**
		 * Clears stored recycled Entities of all Class types.
		 */
		public function clearRecycledAll():void
		{
			for (var classType:Object in _recycled) clearRecycled(classType as Class);
			FP.cleanup();
		}
		
		/**
		 * Brings the Entity to the front of its contained layer.
		 * @param	e		The Entity to shift.
		 * @return	If the Entity changed position.
		 */
		public function bringToFront(e:Entity):Boolean
		{
			if (e._world !== this || !e._renderPrev) return false;
			// pull from list
			e._renderPrev._renderNext = e._renderNext;
			if (e._renderNext) e._renderNext._renderPrev = e._renderPrev;
			else _renderLast[e._layer] = e._renderPrev;
			// place at the start
			e._renderNext = _renderFirst[e._layer];
			e._renderNext._renderPrev = e;
			_renderFirst[e._layer] = e;
			e._renderPrev = null;
			return true;
		}
		
		/**
		 * Sends the Entity to the back of its contained layer.
		 * @param	e		The Entity to shift.
		 * @return	If the Entity changed position.
		 */
		public function sendToBack(e:Entity):Boolean
		{
			if (e._world !== this || !e._renderNext) return false;
			// pull from list
			e._renderNext._renderPrev = e._renderPrev;
			if (e._renderPrev) e._renderPrev._renderNext = e._renderNext;
			else _renderFirst[e._layer] = e._renderNext;
			// place at the end
			e._renderPrev = _renderLast[e._layer];
			e._renderPrev._renderNext = e;
			_renderLast[e._layer] = e;
			e._renderNext = null;
			return true;
		}
		
		/**
		 * Shifts the Entity one place towards the front of its contained layer.
		 * @param	e		The Entity to shift.
		 * @return	If the Entity changed position.
		 */
		public function bringForward(e:Entity):Boolean
		{
			if (e._world !== this || !e._renderPrev) return false;
			// pull from list
			e._renderPrev._renderNext = e._renderNext;
			if (e._renderNext) e._renderNext._renderPrev = e._renderPrev;
			else _renderLast[e._layer] = e._renderPrev;
			// shift towards the front
			e._renderNext = e._renderPrev;
			e._renderPrev = e._renderPrev._renderPrev;
			e._renderNext._renderPrev = e;
			if (e._renderPrev) e._renderPrev._renderNext = e;
			else _renderFirst[e._layer] = e;
			return true;
		}
		
		/**
		 * Shifts the Entity one place towards the back of its contained layer.
		 * @param	e		The Entity to shift.
		 * @return	If the Entity changed position.
		 */
		public function sendBackward(e:Entity):Boolean
		{
			if (e._world !== this || !e._renderNext) return false;
			// pull from list
			e._renderNext._renderPrev = e._renderPrev;
			if (e._renderPrev) e._renderPrev._renderNext = e._renderNext;
			else _renderFirst[e._layer] = e._renderNext;
			// shift towards the back
			e._renderPrev = e._renderNext;
			e._renderNext = e._renderNext._renderNext;
			e._renderPrev._renderNext = e;
			if (e._renderNext) e._renderNext._renderPrev = e;
			else _renderLast[e._layer] = e;
			return true;
		}
		
		/**
		 * If the Entity as at the front of its layer.
		 * @param	e		The Entity to check.
		 * @return	True or false.
		 */
		public function isAtFront(e:Entity):Boolean
		{
			return e._renderPrev == null;
		}
		
		/**
		 * If the Entity as at the back of its layer.
		 * @param	e		The Entity to check.
		 * @return	True or false.
		 */
		public function isAtBack(e:Entity):Boolean
		{
			return e._renderNext == null;
		}
		
		/**
		 * Returns the first Entity that collides with the rectangular area.
		 * @param	type		The Entity type to check for.
		 * @param	rX			X position of the rectangle.
		 * @param	rY			Y position of the rectangle.
		 * @param	rWidth		Width of the rectangle.
		 * @param	rHeight		Height of the rectangle.
		 * @return	The first Entity to collide, or null if none collide.
		 */
		public function collideRect(type:String, rX:Number, rY:Number, rWidth:Number, rHeight:Number):Entity
		{
			var e:Entity = _typeFirst[type];
			while (e)
			{
				if (e.collideRect(e.x, e.y, rX, rY, rWidth, rHeight)) return e;
				e = e._typeNext;
			}
			return null;
		}

		/**
		 * Returns the first Entity found that collides with the position.
		 * @param	type		The Entity type to check for.
		 * @param	pX			X position.
		 * @param	pY			Y position.
		 * @return	The collided Entity, or null if none collide.
		 */
		public function collidePoint(type:String, pX:Number, pY:Number):Entity
		{
			var e:Entity = _typeFirst[type];
			while (e)
			{
				if (e.collidePoint(e.x, e.y, pX, pY)) return e;
				e = e._typeNext;
			}
			return null;
		}
		
		/**
		 * Populates an array with all Entities that collide with the rectangle. This
		 * function does not empty the array, that responsibility is left to the user.
		 * @param	type		The Entity type to check for.
		 * @param	rX			X position of the rectangle.
		 * @param	rY			Y position of the rectangle.
		 * @param	rWidth		Width of the rectangle.
		 * @param	rHeight		Height of the rectangle.
		 * @param	array		The Array to populate with collided Entities.
		 * @return	The provided Array.
		 */
		public function collideRectInto(type:String, rX:Number, rY:Number, rWidth:Number, rHeight:Number, array:Array):Array
		{
			var e:Entity = _typeFirst[type],
				n:uint = array.length;
			while (e)
			{
				if (e.collideRect(e.x, e.y, rX, rY, rWidth, rHeight)) array[n ++] = e;
				e = e._typeNext;
			}
			return array;
		}
		
		/**
		 * Populates an array with all Entities that collide with the position. This
		 * function does not empty the array, that responsibility is left to the user.
		 * @param	type		The Entity type to check for.
		 * @param	pX			X position.
		 * @param	pY			Y position.
		 * @param	array		The Array to populate with collided Entities.
		 * @return	The provided Array.
		 */
		public function collidePointInto(type:String, pX:Number, pY:Number, array:Array):Array
		{
			var e:Entity = _typeFirst[type],
				n:uint = array.length;
			while (e)
			{
				if (e.collidePoint(e.x, e.y, pX, pY)) array[n ++] = e;
				e = e._typeNext;
			}
			return array;
		}
		
		/**
		 * Finds the Entity nearest to the rectangle.
		 * @param	type		The Entity type to check for.
		 * @param	x			X position of the rectangle.
		 * @param	y			Y position of the rectangle.
		 * @param	width		Width of the rectangle.
		 * @param	height		Height of the rectangle.
		 * @return	The nearest Entity to the rectangle.
		 */
		public function nearestToRect(type:String, x:Number, y:Number, width:Number, height:Number):Entity
		{
			var n:Entity = _typeFirst[type],
				nearDist:Number = Number.MAX_VALUE,
				near:Entity, dist:Number;
			while (n)
			{
				dist = squareRects(x, y, width, height, n.x - n.originX, n.y - n.originY, n.width, n.height);
				if (dist < nearDist)
				{
					nearDist = dist;
					near = n;
				}
				n = n._typeNext;
			}
			return near;
		}
		
		/**
		 * Finds the Entity nearest to another.
		 * @param	type		The Entity type to check for.
		 * @param	e			The Entity to find the nearest to.
		 * @param	useHitboxes	If the Entities' hitboxes should be used to determine the distance. If false, their x/y coordinates are used.
		 * @return	The nearest Entity to e.
		 */
		public function nearestToEntity(type:String, e:Entity, useHitboxes:Boolean = false):Entity
		{
			if (useHitboxes) return nearestToRect(type, e.x - e.originX, e.y - e.originY, e.width, e.height);
			var n:Entity = _typeFirst[type],
				nearDist:Number = Number.MAX_VALUE,
				near:Entity, dist:Number,
				x:Number = e.x - e.originX,
				y:Number = e.y - e.originY;
			while (n)
			{
				dist = (x - n.x) * (x - n.x) + (y - n.y) * (y - n.y);
				if (dist < nearDist)
				{
					nearDist = dist;
					near = n;
				}
				n = n._typeNext;
			}
			return near;
		}
		
		/**
		 * Finds the Entity nearest to the position.
		 * @param	type		The Entity type to check for.
		 * @param	x			X position.
		 * @param	y			Y position.
		 * @param	useHitboxes	If the Entities' hitboxes should be used to determine the distance. If false, their x/y coordinates are used.
		 * @return	The nearest Entity to the position.
		 */
		public function nearestToPoint(type:String, x:Number, y:Number, useHitboxes:Boolean = false):Entity
		{
			var n:Entity = _typeFirst[type],
				nearDist:Number = Number.MAX_VALUE,
				near:Entity, dist:Number;
			if (useHitboxes)
			{
				while (n)
				{
					dist = squarePointRect(x, y, n.x - n.originX, n.y - n.originY, n.width, n.height);
					if (dist < nearDist)
					{
						nearDist = dist;
						near = n;
					}
					n = n._typeNext;
				}
				return near;
			}
			while (n)
			{
				dist = (x - n.x) * (x - n.x) + (y - n.y) * (y - n.y);
				if (dist < nearDist)
				{
					nearDist = dist;
					near = n;
				}
				n = n._typeNext;
			}
			return near;
		}
		
		/**
		 * How many Entities are in the World.
		 */
		public function get count():uint { return _count; }
		
		/**
		 * Returns the amount of Entities of the type are in the World.
		 * @param	type		The type to count.
		 * @return	How many Entities of type exist in the World.
		 */
		public function typeCount(type:String):uint
		{
			return _typeCount[type] as uint;
		}
		
		/**
		 * Returns the amount of Entities of the Class are in the World.
		 * @param	c		The Class type to count.
		 * @return	How many Entities of Class exist in the World.
		 */
		public function classCount(c:Class):uint
		{
			return _classCount[c] as uint;
		}
		
		/**
		 * Returns the amount of Entities are on the layer in the World.
		 * @param	layer		The layer to count Entities on.
		 * @return	How many Entities are on the layer.
		 */
		public function layerCount(layer:int):uint
		{
			return _layerCount[layer] as uint;
		}
		
		/**
		 * The first Entity in the World.
		 */
		public function get first():Entity { return _updateFirst; }
		
		/**
		 * The first Entity of the type.
		 * @param	type		The type to check.
		 * @return	The Entity.
		 */
		public function typeFirst(type:String):Entity
		{
			if (!_updateFirst) return null;
			return _typeFirst[type] as Entity;
		}
		
		/**
		 * The first Entity of the Class.
		 * @param	c		The Class type to check.
		 * @return	The Entity.
		 */
		public function classFirst(c:Class):Entity
		{
			if (!_updateFirst) return null;
			var e:Entity = _updateFirst;
			while (e)
			{
				if (e is c) return e;
				e = e._updateNext;
			}
			return null;
		}
		
		/**
		 * The first Entity on the Layer.
		 * @param	layer		The layer to check.
		 * @return	The Entity.
		 */
		public function layerFirst(layer:int):Entity
		{
			if (!_updateFirst) return null;
			return _renderFirst[layer] as Entity;
		}
		
		/**
		 * The last Entity on the Layer.
		 * @param	layer		The layer to check.
		 * @return	The Entity.
		 */
		public function layerLast(layer:int):Entity
		{
			if (!_updateFirst) return null;
			return _renderLast[layer] as Entity;
		}
		
		/**
		 * The Entity that will be rendered first by the World.
		 */
		public function get farthest():Entity
		{
			if (!_updateFirst) return null;
			return _renderLast[_layerList[_layerList.length - 1] as int] as Entity;
		}
		
		/**
		 * The Entity that will be rendered last by the world.
		 */
		public function get nearest():Entity
		{
			if (!_updateFirst) return null;
			return _renderFirst[_layerList[0] as int] as Entity;
		}
		
		/**
		 * The layer that will be rendered first by the World.
		 */
		public function get layerFarthest():int
		{
			if (!_updateFirst) return 0;
			return _layerList[_layerList.length - 1] as int;
		}
		
		/**
		 * The layer that will be rendered last by the World.
		 */
		public function get layerNearest():int
		{
			if (!_updateFirst) return 0;
			return _layerList[0] as int;
		}
		
		/**
		 * How many different types have been added to the World.
		 */
		public function get uniqueTypes():uint
		{
			var i:uint = 0;
			for (var type:String in _typeCount) i += _typeCount[type] as uint;
			return i;
		}
		
		/**
		 * Pushes all Entities in the World of the type into the array.
		 * @param	type		The type to check.
		 * @param	into		The array to populate.
		 * @return	The same array, populated.
		 */
		public function getType(type:String, into:Array):Array
		{
			var e:Entity = _typeFirst[type],
				n:uint = into.length;
			while (e)
			{
				into[n ++] = e;
				e = e._typeNext;
			}
			return into;
		}
		
		/**
		 * Pushes all Entities in the World of the Class into the array.
		 * @param	c			The Class type to check.
		 * @param	into		The array to populate.
		 * @return	The same array, populated.
		 */
		public function getClass(c:Class, into:Array):Array
		{
			var e:Entity = _updateFirst,
				n:uint = into.length;
			while (e)
			{
				if (e is c) into[n ++] = e;
				e = e._updateNext;
			}
			return into;
		}
		
		/**
		 * Pushes all Entities in the World on the layer into the array.
		 * @param	layer		The layer to check.
		 * @param	into		The array to populate.
		 * @return	The same array, populated.
		 */
		public function getLayer(layer:int, into:Array):Array
		{
			var e:Entity = _renderLast[layer],
				n:uint = into.length;
			while (e)
			{
				into[n ++] = e;
				e = e._updatePrev;
			}
			return into;
		}
		
		/**
		 * Pushes all Entities in the World into the array.
		 * @param	into		The array to populate.
		 * @return	The same array, populated.
		 */
		public function getAll(into:Array):Array
		{
			var e:Entity = _updateFirst,
				n:uint = into.length;
			while (e)
			{
				into[n ++] = e;
				e = e._updateNext;
			}
			return into;
		}
		
		/** @private Updates the add/remove lists at the end of the frame. */
		internal function updateLists():void
		{
			var e:Entity;
			
			// remove entities
			if (_remove.length)
			{
				for each (e in _remove)
				{
					e._added = false;
					e.removed();
					removeUpdate(e);
					removeRender(e);
					if (e._type) removeType(e);
					if (e.autoClear && e._tween) e.clearTweens();
				}
				_remove.length = 0;
			}
			
			// add entities
			if (_add.length)
			{
				for each (e in _add)
				{
					e._added = true;
					addUpdate(e);
					addRender(e);
					if (e._type) addType(e);
					e.added();
				}
				_add.length = 0;
			}
			
			// sort the depth list
			if (_layerSort)
			{
				if (_layerList.indexOf(null) >= 0) removeNulls(_layerList);
				if (_layerList.length > 1) sort(_layerList, 0, _layerList.length - 1);
				_layerSort = false;
			}
		}
		
		/** @private Adds Entity to the update list. */
		private function addUpdate(e:Entity):void
		{
			// add to update list
			if (_updateFirst)
			{
				_updateFirst._updatePrev = e;
				e._updateNext = _updateFirst;
			}
			else e._updateNext = null;
			e._updatePrev = null;
			_updateFirst = e;
			_count ++;
			if (!_classCount[e._class]) _classCount[e._class] = 0;
			_classCount[e._class] ++;
		}
		
		/** @private Removes Entity from the update list. */
		private function removeUpdate(e:Entity):void
		{
			// remove from the update list
			if (_updateFirst == e) _updateFirst = e._updateNext;
			if (e._updateNext) e._updateNext._updatePrev = e._updatePrev;
			if (e._updatePrev) e._updatePrev._updateNext = e._updateNext;
			e._updateNext = e._updatePrev = null;
			
			_count --;
			_classCount[e._class] --;
		}
		
		/** @private Adds Entity to the render list. */
		internal function addRender(e:Entity):void
		{
			var f:Entity = _renderFirst[e._layer];
			if (f)
			{
				e._renderNext = f;
				f._renderPrev = e;
				_layerCount[e._layer] ++;
			}
			else
			{
				_renderLast[e._layer] = e;
				_layerList[_layerList.length] = e._layer;
				_layerSort = true;
				e._renderNext = null;
				_layerCount[e._layer] = 1;
			}
			_renderFirst[e._layer] = e;
			e._renderPrev = null;
		}
		
		/** @private Removes Entity from the render list. */
		internal function removeRender(e:Entity):void
		{
			if (e._renderNext) e._renderNext._renderPrev = e._renderPrev;
			else _renderLast[e._layer] = e._renderPrev;
			if (e._renderPrev) e._renderPrev._renderNext = e._renderNext;
			else
			{
				_renderFirst[e._layer] = e._renderNext
				if (!e._renderNext)
				{
					_layerList[_layerList.indexOf(e._layer)] = null;
					_layerSort = true;
				}
			}
			_layerCount[e._layer] --;
			e._renderNext = e._renderPrev = null;
		}
		
		/** @private Adds Entity to the type list. */
		internal function addType(e:Entity):void
		{
			// add to type list
			if (_typeFirst[e._type])
			{
				_typeFirst[e._type]._typePrev = e;
				e._typeNext = _typeFirst[e._type];
				_typeCount[e._type] ++;
			}
			else
			{
				e._typeNext = null;
				_typeCount[e._type] = 1;
			}
			e._typePrev = null;
			_typeFirst[e._type] = e;
		}
		
		/** @private Removes Entity from the type list. */
		internal function removeType(e:Entity):void
		{
			// remove from the type list
			if (_typeFirst[e._type] == e) _typeFirst[e._type] = e._typeNext;
			if (e._typeNext) e._typeNext._typePrev = e._typePrev;
			if (e._typePrev) e._typePrev._typeNext = e._typeNext;
			e._typeNext = e._typePrev = null;
			_typeCount[e._type] --;
		}
		
		/** @private Removes all nulls from the array. */
		private static function removeNulls(a:Array):void
		{
			var i:int = 0,
				j:int = a.length;
			while (i < j)
			{
				while (a[i] != null) i ++;
				while (a[j] == null) j --;
				a[i] = a[j];
				a[j] = null;
			}
			a[j] = a[i];
			a[i] = null;
			a.length -= a.length - a.indexOf(null);
		}
		
		/** @private Quicksorts the values in the array. */
		private static function sort(a:Array, left:int, right:int):void
		{
			var i:int = left,
				j:int = right,
				p:int = a[Math.round((left + right) * .5)],
				t:int;
			while (i <= j)
			{
				while (a[i] < p) i ++;
				while (a[j] > p) j --;
				if (i <= j)
				{
					t = a[i];
					a[i ++] = a[j];
					a[j --] = t;
				}
			}
			if (left < j) sort(a, left, j);
			if (i < right) sort(a, i, right);
			return;
		}
		
		/** @private Calculates the squared distance between two rectangles. */
		private static function squareRects(x1:Number, y1:Number, w1:Number, h1:Number, x2:Number, y2:Number, w2:Number, h2:Number):Number
		{
			if (x1 < x2 + w2 && x2 < x1 + w1)
			{
				if (y1 < y2 + h2 && y2 < y1 + h1) return 0;
				if (y1 > y2) return (y1 - (y2 + h2)) * (y1 - (y2 + h2));
				return (y2 - (y1 + h1)) * (y2 - (y1 + h1));
			}
			if (y1 < y2 + h2 && y2 < y1 + h1)
			{
				if (x1 > x2) return (x1 - (x2 + w2)) * (x1 - (x2 + w2));
				return (x2 - (x1 + w1)) * (x2 - (x1 + w1));
			}
			if (x1 > x2)
			{
				if (y1 > y2) return squarePoints(x1, y1, (x2 + w2), (y2 + h2));
				return squarePoints(x1, y1 + h1, x2 + w2, y2);
			}
			if (y1 > y2) return squarePoints(x1 + w1, y1, x2, y2 + h2)
			return squarePoints(x1 + w1, y1 + h1, x2, y2);
		}
		
		/** @private Calculates the squared distance between two points. */
		private static function squarePoints(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);
		}
		
		/** @private Calculates the squared distance between a rectangle and a point. */
		private static function squarePointRect(px:Number, py:Number, rx:Number, ry:Number, rw:Number, rh:Number):Number
		{
			if (px >= rx && px <= rx + rw)
			{
				if (py >= ry && py <= ry + rh) return 0;
				if (py > ry) return (py - (ry + rh)) * (py - (ry + rh));
				return (ry - py) * (ry - py);
			}
			if (py >= ry && py <= ry + rh)
			{
				if (px > rx) return (px - (rx + rw)) * (px - (rx + rw));
				return (rx - px) * (rx - px);
			}
			if (px > rx)
			{
				if (py > ry) return squarePoints(px, py, rx + rw, ry + rh);
				return squarePoints(px, py, rx + rw, ry);
			}
			if (py > ry) return squarePoints(px, py, rx, ry + rh)
			return squarePoints(px, py, rx, ry);
		}
		
		/** @private Inherits all persistent Entities from the world. */
		internal function inherit(from:World, inheritAll:Boolean = false):void
		{
			var e:Entity = from._updateFirst,
				a:Array = [],
				n:uint = 0;
			if (inheritAll)
			{
				while (e)
				{
					a[n ++] = from.remove(e);
					e = e._updateNext;
				}
			}
			else
			{
				while (e)
				{
					if (e.persist) a[n ++] = from.remove(e);
					e = e._updateNext;
				}
			}
			from.updateLists();
			addList(a);
		}
		
		// Adding and removal.
		/** @private */	private var _add:Vector.<Entity> = new Vector.<Entity>;
		/** @private */	private var _remove:Vector.<Entity> = new Vector.<Entity>;
		
		// Update information.
		/** @private */	private var _updateFirst:Entity;
		/** @private */	private var _count:uint;
		
		// Render information.
		private var _renderFirst:Array = [];
		private var _renderLast:Array = [];
		private var _layerList:Array = [];
		private var _layerCount:Array = [];
		private var _layerSort:Boolean;
		
		/** @private */	private var _classCount:Dictionary = new Dictionary;
		/** @private */	internal var _typeFirst:Object = { };
		/** @private */	private var _typeCount:Object = { };
		/** @private */	private var _recycled:Dictionary = new Dictionary;
		/** @private */	internal var _inherit:Boolean = false;
		/** @private */	internal var _inheritAll:Boolean = false;
	}
}
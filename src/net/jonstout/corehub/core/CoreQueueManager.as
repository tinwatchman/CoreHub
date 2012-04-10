package net.jonstout.corehub.core
{
	import net.jonstout.corehub.interfaces.ICoreMessage;

	public class CoreQueueManager
	{
		protected var _isEnabled:Boolean;
		protected var _isSortingEnabled:Boolean;
		protected var coreQueues:Object;
		
		public function CoreQueueManager()
		{
			_isEnabled = true;
			_isSortingEnabled = true;
			coreQueues = new Object();
		}
		
		public function addToQueue(key:String, message:ICoreMessage):void
		{
			var coreQueue:Vector.<ICoreMessage>;
			if (coreQueues[key] != null) {
				coreQueue = coreQueues[key] as Vector.<ICoreMessage>;
			} else {
				coreQueue = new Vector.<ICoreMessage>();
				coreQueues[key] = coreQueue;
			}
			coreQueue.push(message);
			if (_isSortingEnabled) {
				coreQueue.sort(sortMessages);
			}
		}
				
		public function hasQueue(key:String):Boolean 
		{
			if (!_isEnabled) {
				return false;
			}
			return (getQueue(key) != null && getQueue(key).length > 0);
		}
				
		public function flushQueue(key:String):Vector.<ICoreMessage>
		{
			var messages:Vector.<ICoreMessage> = getQueue(key);
			delete coreQueues[key];
			return messages;
		}
		
		public function clearQueues():void
		{
			for (var key:String in coreQueues) {
				delete coreQueues[key];
			}
		}
		
		public function get isEnabled():Boolean
		{
			return _isEnabled;
		}
		
		public function set isEnabled(value:Boolean):void
		{
			_isEnabled = value;
			if (!_isEnabled) {
				clearQueues();
			}
		}

		public function get isSortingEnabled():Boolean
		{
			return _isSortingEnabled;
		}
		
		public function set isSortingEnabled(value:Boolean):void
		{
			_isSortingEnabled = value;
		}

		protected function getQueue(key:String):Vector.<ICoreMessage>
		{
			if (coreQueues[key] != null) {
				return coreQueues[key] as Vector.<ICoreMessage>;
			}
			return null;
		}		
		
		protected function sortMessages(a:ICoreMessage, b:ICoreMessage):Number
		{
			if (a.getPriority() < b.getPriority()) {
				return -1;
			} else if (a.getPriority() > b.getPriority()) {
				return 1;
			}
			return 0;
		}
	}
}
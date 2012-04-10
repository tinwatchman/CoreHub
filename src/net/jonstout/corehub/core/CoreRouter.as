package net.jonstout.corehub.core
{
	import net.jonstout.corehub.interfaces.ICoreMediator;
	import net.jonstout.corehub.interfaces.ICoreMessage;

	public class CoreRouter
	{
		protected var coreMap:Object;
		protected var observerMap:Object;

		public function CoreRouter()
		{
			coreMap = new Object();
			observerMap = new Object();
		}
		
		public function registerCore(mediator:ICoreMediator):void
		{
			if (coreMap[mediator.getCoreKey()] != null) {
				return;
			}
			coreMap[mediator.getCoreKey()] = mediator;
		}

		public function hasCore(key:String):Boolean {
			return (coreMap[key] != null);
		}
		
		public function getRegisteredCoreKeys():Array {
			var corelist:Array = new Array();
			for (var key:String in coreMap) {
				corelist.push(key);
			}
			return corelist;
		}
				
		public function removeCore(key:String):void {
			if ( hasCore(key) ) {
				clearCoreObservers(key);
				delete coreMap[key];
			}
		}
		
		public function registerCoreObserver(messageType:String, core:ICoreMediator):void
		{
			var typeObservers:Vector.<ICoreMediator>;
			if ( observerMap[messageType] != null ) {
				typeObservers = observerMap[messageType] as Vector.<ICoreMediator>;
			} else {
				typeObservers = new Vector.<ICoreMediator>();
				observerMap[messageType] = typeObservers;
			}
			if (typeObservers.indexOf(core) == -1) {
				typeObservers.push(core);
			}
		}
		
		public function hasCoreObserver(messageType:String):Boolean {
			return (observerMap[messageType] != null);
		}

		public function removeCoreObserver(messageType:String, core:ICoreMediator):void
		{
			if ( observerMap[messageType] == null ) {
				return;
			}
			var observers:Vector.<ICoreMediator> = observerMap[messageType] as Vector.<ICoreMediator>;
			observers = observers.filter(function(item:ICoreMediator, index:int, vector:Vector.<ICoreMediator>):Boolean {
				if (item === core) {
					return false;
				}
				return true;
			});
			if (observers.length == 0) {
				delete observerMap[messageType];
			}
		}
		
		public function send(message:ICoreMessage):void
		{
			if ( observerMap[message.getType()] != null ) {
				var cores:Vector.<ICoreMediator> = observerMap[message.getType()] as Vector.<ICoreMediator>;
				for each (var core:ICoreMediator in cores) {
					core.handleCoreMessage(message);
				}
			}
		}
		
		public function sendToCore(key:String, message:ICoreMessage):Boolean
		{
			if ( hasCore(key) ) {
				getCore(key).handleCoreMessage(message);
				return true;
			}
			return false;
		}
				
		public function sendQueueToCore(core:ICoreMediator, messages:Vector.<ICoreMessage>):void
		{
			for each (var message:ICoreMessage in messages) {
				core.handleCoreMessage(message);
			}
		}

		protected function getCore(key:String):ICoreMediator
		{
			if (coreMap[key] != null) {
				return coreMap[key] as ICoreMediator;
			}
			return null;
		}
		
		protected function clearCoreObservers(key:String):void
		{
			for (var messageType:String in observerMap) {
				removeCoreObserver(messageType, getCore(key));
			}
		}
	}
}
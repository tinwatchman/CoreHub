package net.jonstout.corehub.patterns
{
	import net.jonstout.corehub.CoreHub;
	import net.jonstout.corehub.interfaces.ICoreMediator;
	import net.jonstout.corehub.interfaces.ICoreMessage;
	import net.jonstout.corehub.messages.BaseCoreMessageType;
	import net.jonstout.corehub.messages.CoreMessage;
	
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	/**
	 * A sample ICoreMediator implementation.
	 * <p>Mediator to allow individual Cores to connect to the CoreHub
	 * singleton. Extend this class as necessary in your own code 
	 * to customize communication with the other Cores.</p> 
	 * @author Jon Stout <j.stout@jonstout.net>
	 * @see org.puremvc.as3.multicore.patterns.mediator.Mediator Mediator
	 */
	public class CoreMediator extends Mediator implements ICoreMediator
	{
		protected var hub:CoreHub;
		protected var coreMessageInterests:Object;
		
		public function CoreMediator(mediatorName:String=null)
		{
			super(mediatorName, null);
			coreMessageInterests = new Object();
			addCoreMessageInterest(BaseCoreMessageType.REMOVE_CORE, onRemoveCore);
		}
		
		override public function onRegister():void
		{
			connectToHub();
		}
		
		override public function onRemove():void
		{
			disconnectFromHub();
		}
		
		public function getCoreKey():String
		{
			return this.multitonKey;
		}
		
		public function listCoreMessageInterests():Array
		{
			var interests:Array = new Array();
			for (var messageType:String in coreMessageInterests) {
				interests.push(messageType);
			}
			return interests;
		}
		
		public function handleCoreMessage(message:ICoreMessage):void
		{
			if (coreMessageInterests[message.getType()] != null) {
				var handler:Function = coreMessageInterests[message.getType()] as Function;
				handler.apply(this, [message]);
			}
		}
		
		public function sendMessage(type:String, body:Object=null, header:Object=null, priority:uint=CoreMessage.PRIORITY_LOW):void {
			if (hub != null) {
				var message:CoreMessage = new CoreMessage(type, body, header, priority);
				message.setOrigin(this.multitonKey);
				hub.sendMessage(message);
			}
		}
		
		public function sendMessageToCore(core:String, type:String, body:Object=null, header:Object=null, priority:uint=CoreMessage.PRIORITY_LOW):void {
			if (hub != null) {
				var message:CoreMessage = new CoreMessage(type, body, header, priority);
				message.setOrigin(this.multitonKey);
				hub.sendMessageToCore(core, message);
			}
		}
		
		protected function connectToHub():void
		{
			hub = CoreHub.getInstance();
			hub.registerCore(this);
		}
		
		protected function disconnectFromHub():void
		{
			hub.removeCore(this);
			coreMessageInterests = new Object();
			hub = null;
		}
		
		protected function addCoreMessageInterest(messageType:String, handler:Function):void
		{
			coreMessageInterests[messageType] = handler;
			if (hub != null) {
				hub.registerCoreInterest(messageType, this);
			}
		}
		
		protected function removeCoreMessageInterest(messageType:String, handler:Function):void
		{
			if (coreMessageInterests[messageType] != null) {
				delete coreMessageInterests[messageType];
				if (hub != null) {
					hub.removeCoreInterest(messageType, this);
				}
			}
		}
		
		protected function onRemoveCore(message:ICoreMessage):void
		{
			if (message.getBody() == this.multitonKey) {
				disconnectFromHub();
			}
		}
	}
}
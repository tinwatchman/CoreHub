package net.jonstout.corehub.messages
{
	import net.jonstout.corehub.interfaces.ICoreMessage;

	/**
	 * CoreHub Message
	 * <p>Base <code>ICoreMessage</code> implementation. Messages can be sent
	 * through the CoreHub to either any Cores who happen to be listening for its
	 * particular type, or to a specific Core with a known Multiton key. They are
	 * equivalent to standard PureMVC <code>INotification</code> objects, save that they
	 * are specifically used for intra-module communication. This helps keep internal
	 * <code>Notifications</code> within Cores seperate from external messages from 
	 * other modules.</p>
	 * <p>The basic properties of <code>CoreMessage</code> are:</p><ul>
	 * <li><b>type</b>: message type. Equivalent to the <code>name</code> property of 
	 * the <code>Notification</code> object, and used in a similar manner.</li>
	 * <li><b>origin</b>: the multiton key of the Core the message was sent by.</li>
	 * <li><b>body</b>: message body</li>
	 * <li><b>header</b>: Can be used to relay any metadata about the message for 
	 * the recipient.</li>
	 * <li><b>priority</b>: If the message is added to a disconnected Core's queue, it 
	 * can be sorted by priority for delivery when and if the Core reconnects. The lower 
	 * the value is, the higher the message's priority.</li></ul>
	 * 
	 * @see org.puremvc.as3.multicore.patterns.observer.Notification Notification
	 */	
	public class CoreMessage implements ICoreMessage
	{
		public static const PRIORITY_HIGH:uint = 1;
		public static const PRIORITY_MEDIUM:uint = 5;
		public static const PRIORITY_LOW:uint = 10;
		
		protected var _type:String;
		protected var _body:Object;
		protected var _header:Object;
		protected var _priority:uint;
		protected var _origin:String;
		
		/**
		 * Constructor.
		 *  
		 * @param type message type of the <code>CoreMessage</code> instance (required).
		 * @param body message body (optional).
		 * @param header message headers (optional).
		 * @param priority message priority (optional).
		 * 
		 */		
		public function CoreMessage(type:String, body:Object=null, header:Object=null, priority:uint=PRIORITY_LOW)
		{
			_type = type;
			_body = body;
			_header = header;
			_priority = priority;
		}		
				
		public function getType():String
		{
			return _type;
		}
		
		public function setType(value:String):void
		{
			_type = value;
		}
		
		public function getBody():Object
		{
			return _body;
		}
		
		public function setBody(value:Object):void
		{
			_body = value;
		}
		
		public function getHeader():Object
		{
			return _header;
		}
		
		public function setHeader(value:Object):void
		{
			_header = value;
		}
		
		public function getPriority():uint
		{
			return _priority;
		}
		
		public function setPriority(value:uint):void
		{
			_priority = value;
		}
		
		public function getOrigin():String
		{
			return _origin;
		}
		
		public function setOrigin(value:String):void
		{
			_origin = value;
		}
	}
}
package net.jonstout.corehub.interfaces
{
	/**
	 * CoreHub Message interface
	 * <p><code>ICoreMessages</code> are objects sent between modules via the
	 * CoreHub utility.</p>
	 */	
	public interface ICoreMessage
	{
		function getType():String;
		function setType(value:String):void;
		function getBody():Object;
		function setBody(value:Object):void;
		function getHeader():Object;
		function setHeader(value:Object):void;
		function getPriority():uint;
		function setPriority(value:uint):void;
		function getOrigin():String;
		function setOrigin(value:String):void;
	}
}
package net.jonstout.corehub.interfaces
{
	/**
	 * Core Mediator interface
	 * <p>Defines a mediator object used by a PureMVC Core (or Modules that utilize a different
	 * framework) to communicate with and relay messages through the CoreHub utility.</p>
	 */	
	public interface ICoreMediator
	{
		/**
		 * Get Core Multiton Key 
		 * @return <b>String</b> unique multiton key of the Core the <code>ICoreMediator</code> represents.
		 */		
		function getCoreKey():String;
		
		/**
		 * Lists the <code>ICoreMessage</code> types this mediator is interested in being
		 * notified of. 
		 * @return <b>Array</b> the list of <code>ICodeMessage</code> types
		 */
		function listCoreMessageInterests():Array;
		
		/**
		 * Handle <code>ICoreMessages</code>. 
		 * @param message <code>ICoreMessage</code>
		 */		
		function handleCoreMessage(message:ICoreMessage):void;
	}
}
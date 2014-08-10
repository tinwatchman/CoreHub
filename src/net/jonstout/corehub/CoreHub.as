/**
 * Copyright (c) 2012, Jon Stout
 * PureMVC AS3 MultiCore Framework - Copyright © 2006-2012 Futurescale, Inc. All rights reserved. See attached license.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package net.jonstout.corehub
{
	import net.jonstout.corehub.core.CoreQueueManager;
	import net.jonstout.corehub.core.CoreRouter;
	import net.jonstout.corehub.interfaces.ICoreMediator;
	import net.jonstout.corehub.interfaces.ICoreMessage;
	import net.jonstout.corehub.messages.BaseCoreMessageType;
	import net.jonstout.corehub.messages.CoreMessage;

	/**
	 * A simple, Singleton-based class to enable communication
	 * between modules using the PureMVC MultiCore framework.
	 * @author Jon Stout <j.stout@jonstout.net>
	 * @version 1.0
	 * @see https://github.com/PureMVC/puremvc-as3-multicore-framework/ PureMVC MultiCore Framework
	 */
	public class CoreHub
	{
		private static var instance:CoreHub;
		
		protected var router:CoreRouter;
		protected var queueManager:CoreQueueManager;
		
		/**
		 * CoreHub Singleton accessor method 
		 * @return the Singleton instance of the CoreHub
		 */		
		public static function getInstance():CoreHub
		{
			if (instance == null) {
				instance = new CoreHub(new SingletonEnforcer());
			}
			return instance;
		}
		
		/**
		 * Constructor. 
		 * @param enforcer <code>SingletonEnforcer</code> instance
		 * 
		 */		
		public function CoreHub(enforcer:SingletonEnforcer)
		{
			router = new CoreRouter();
			queueManager = new CoreQueueManager();
		}
		
		
		/**
		 * Registers an <code>ICoreMediator</code> instance representing a Core. The
		 * mediator will thereafter be able to send and receive messages through CoreHub.
		 *  
		 * @param mediator the <code>ICoreMediator</code> to be registered
		 * 
		 */		
		public function registerCore(mediator:ICoreMediator):void
		{
			// register the core
			router.registerCore(mediator);
			// get and register the core's message interests
			var interests:Array = mediator.listCoreMessageInterests();
			if (interests.length > 0) {
				for each (var messageType:String in interests) {
					registerCoreInterest(messageType, mediator);
				}
			}
			// check to see if the core has a queue; if it does, flush it to the mediator.
			if ( queueManager.hasQueue( mediator.getCoreKey() ) ) {
				router.sendQueueToCore( mediator, queueManager.flushQueue( mediator.getCoreKey() ) );
			}
			// if anyone's listening / interested, notify the rest of the system that the core has been added.
			if ( router.hasCoreObserver(BaseCoreMessageType.CORE_REGISTERED) ) {
				sendSystemMessage( BaseCoreMessageType.CORE_REGISTERED, mediator.getCoreKey() );
			}
		}
		
		
		/**
		 * Returns a list of the keys of all Cores currently registered with CoreHub. 
		 * @return Array of Multiton key strings
		 * 
		 */
		public function getCoreList():Array {
			return router.getRegisteredCoreKeys();
		}
		
		
		/**
		 * Checks to see if a Core with the given key is currently registered with CoreHub. Essentially
		 * a way to check if a module is currently loaded by the application.
		 * 
		 * @param key Expected key string of the Core
		 * @return <b>true</b> if found, <b>false</b> otherwise.
		 * 
		 */		
		public function hasCore(key:String):Boolean {
			return router.hasCore(key);
		}
		
		
		/**
		 * Removes the given <code>ICoreMediator</code> from CoreHub. This <em>must</em> be called on a module's
		 * <code>ICoreMediator</code> before the module is unloaded.
		 * @param core the <code>ICoreMediator</code> to remove.
		 * 
		 */		
		public function removeCore(core:ICoreMediator):void {
			router.removeCore( core.getCoreKey() );
			if ( router.hasCoreObserver(BaseCoreMessageType.CORE_REMOVED) ) {
				sendSystemMessage( BaseCoreMessageType.CORE_REMOVED, core.getCoreKey() );
			}
		}
		
		
		/**
		 * Registers an <code>ICoreMediator</code> to be sent any <code>ICoreMessages</code> with the given
		 * message type. Once a core mediator is registered with the CoreHub, it can call this method at any time
		 * to add a new message interest, much like adding an event listener.
		 * @param messageType the message type to notify this <code>ICoreMediator</code> of
		 * @param core the <code>ICoreMediator</code> to register
		 * 
		 */		
		public function registerCoreInterest(messageType:String, core:ICoreMediator):void
		{
			router.registerCoreObserver(messageType, core);
		}
		
		
		/**
		 * Removes an <code>ICoreMediator</code> from the observer list for the given message type. Once a
		 * core mediator is registered with the CoreHub, it can call this method at any time to remove a
		 * message interest, much like removing an event listener.
		 * @param messageType the message type to remove the observer from
		 * @param core the <code>ICoreMediator</code> to remove from the observer list.
		 * 
		 */		
		public function removeCoreInterest(messageType:String, core:ICoreMediator):void
		{
			router.removeCoreObserver(messageType, core);
		}
		
		
		/**
		 * Sends an <code>ICoreMessage</code> to any active, interested listeners.
		 *  
		 * @param message <code>ICoreMessage</code> object.
		 * 
		 */		
		public function sendMessage(message:ICoreMessage):void
		{
			router.send(message);
		}
		
		
		/**
		 * Sends an <code>ICoreMessage</code> to a specific Core. If that Core is not currently registered (i.e. if the module
		 * is not currently loaded), the message is placed in a queue to be sent to it if and when it registers with the CoreHub.
		 *  
		 * @param key Multiton key of the Core the message is to be sent to
		 * @param message <code>ICoreMessage</code> object
		 * 
		 */		
		public function sendMessageToCore(key:String, message:ICoreMessage):void
		{
			var result:Boolean = router.sendToCore(key, message);
			if (!result && queueManager.isEnabled) {
				queueManager.addToQueue(key, message);
			}
		}
		
		
		/**
		 * Returns if the queueing system for non-active Cores is on or off
		 * @return <b>true</b> if on, <b>false</b> otherwise.
		 * 
		 */
		public function get isQueueEnabled():Boolean
		{
			return queueManager.isEnabled;
		}
		
		
		/**
		 * Turns the queueing system for non-active Cores on or off. The queue will otherwise
		 * capture any messages sent to a inactive Core (i.e. to a module that hasn't been
		 * loaded yet) via the sendMessageToCore method, and wait for it to come online. This
		 * allows newly-loaded modules to be brought up to date on key information as soon as
		 * possible.
		 * <p>Set to <b>true</b> by default.</p>
		 * @param value <b>true</b> for on, <b>false</b> for off.
		 * 
		 */
		public function set isQueueEnabled(value:Boolean):void
		{
			queueManager.isEnabled = value;
		}
		
		
		/**
		 * Returns if queue sorting is on or off 
		 * @return <b>true</b> for on, <b>false</b> otherwise.
		 * 
		 */
		public function get isQueueSortingEnabled():Boolean
		{
			return queueManager.isSortingEnabled;
		}
		
		
		/**
		 * Sets if messages waiting in a Core's queue should be sorted by priority or not.
		 * <p>By default, any messages sent to an inactive Core are sorted by their Priority
		 * attribute. This ensures that newly-loaded modules will learn the most important
		 * information sent to them first.</p>
		 * <p>Alternatively, turning this option off will mean messages are sent out of the
		 * queue in first-in, first-out order. This may have a small performance benefit,
		 * especially with larger message queues.</p>
		 * @param value <b>true</b> for on, <b>false</b> for off.
		 * 
		 */
		public function set isQueueSortingEnabled(value:Boolean):void
		{
			queueManager.isSortingEnabled = value;
		}
		
		
		/**
		 * Convenience function to dispatch system notification messages. 
		 * @param messageType the message type
		 * @param body the body of the message (optional)
		 * 
		 */
		protected function sendSystemMessage(messageType:String, body:Object=null):void 
		{
			var message:CoreMessage = new CoreMessage(messageType, body);
			router.send(message);
		}
	}
} class SingletonEnforcer {}
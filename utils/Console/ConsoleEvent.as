package utils.Console 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Javier
	 */
	public class ConsoleEvent extends Event 
	{
		
		public static var COMMAND_SUBMITTED:String = "Command Submitted";
		
		private var _data:String;
		public function get data():String {
			return _data;
		}
		public function set data(value:String):void {
			_data = value;
		}
		
		public function ConsoleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
			
		}
		
	}

}
package  utils
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	/**
	 * ...
	 * @author Javier
	 */
	public class KeyboardManager 
	{
		//stores the key states.
		private static var keyStates:Array = [];
		
		private static var _stage:Stage;
		
		public function KeyboardManager() 
		{
			
		}
		
		public static function init(s:Stage):void
		{
			_stage = s;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN , manageKeyPressed);
			_stage.addEventListener(KeyboardEvent.KEY_UP , manageKeyUnpressed);
		}
		
		public static function manageKeyPressed(e:KeyboardEvent):void
		{
			keyStates[e.keyCode] = true;
		}
		
		public static function manageKeyUnpressed(e:KeyboardEvent):void
		{
			keyStates[e.keyCode] = false;
		}
		
		public static function isKeyPressed(keyCode:uint):Boolean
		{
			return keyStates[keyCode];
		}
	}

}
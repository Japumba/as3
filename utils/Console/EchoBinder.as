package utils.Console 
{
	/**
	 * ...
	 * @author Javier
	 */
	public class EchoBinder implements IConsoleBinder 
	{
		
		public function EchoBinder() 
		{
			
		}
		
		/* INTERFACE utils.Console.IConsoleBinder */
		
		public function parseCommand(e:ConsoleEvent):void 
		{
			Console.writeLine("Echo: " + e.data);
		}
		
	}

}
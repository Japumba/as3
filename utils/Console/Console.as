package utils.Console  
{
	import adobe.utils.CustomActions;
	import flash.desktop.ClipboardFormats;
	import flash.display.InteractiveObject;
	import flash.events.FocusEvent;
	import flash.events.TextEvent;
	import flash.ui.Keyboard;
	import flash.display.Shader;
	import flash.display.ShaderParameter;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldType;
	import flash.net.FileReference;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Javier
	 */
	public class Console
	{
		public static var _sprite:Sprite;//sprite containing the bg, buttons and textfields. This is added to the stage.
		
		public static var _dispatcher:EventDispatcher;//event dispatcher.
		public static var _bindedMethods:Object;//console Binder.
		
		public static var _saveToFilePermission:Boolean = true;
		public static var _logFilePath:String = "ConsoleLog.txt";
		
		public static var _lines:Vector.<String>;//contains every line wrote to the console.
		public static var _textFieldLines:Vector.<TextField>;//contains each textfield to display the lines.
		public static var _numLinesToDisplay:int;//number of lines to display in the console.
		public static var _topLine:int;//index of the top line to display in the console ( this is: _lines[_topLine] ).
		
		public static var _lastLine:String;//last command wrote to the console
		public static var _prevText:String = "";//stores the textInput when console is hidden
		
		public static var _inputTextField:TextField;//textfield used for input.
		
		public static var _enterButtonBG:Shape;//graphic for enterButton
		public static var _enterButtonOver:Shape;//graphic for enterButton when mouse is over
		public static var _enterButtonPressed:Shape;//graphic for enterButton when pressed
		public static var _enterButton:SimpleButton;//button to submit an input to the console.
		public static var _scrollUpButton:SimpleButton;//button to scoll the console up
		public static var _scrollDownButton:SimpleButton;//button to scoll the console down
		public static var _autoScroll:Boolean = true;//enables the autoscroll when writing to the console
		
		public static var _bg:Shape;//rectangle of the console
		public static var _bgColorTransform:ColorTransform;//color properties of the console bg
		public static var _bgColor:uint;//color for the console bg
		public static var _bgAlpha:Number;//alpha multiplier for the console bg
		
		public static var _lineFormat:TextFormat;//format of the console lines
		public static var _lineFormatSize:uint;//font size in pixels
		public static var _foreColor:uint;//font color for the console lines
		
		public static var _stage:Stage;//holds a reference to the stage where the console is to be drawn
		public static var _prevFocus:InteractiveObject;//holds a reference to the focused object when the console is shown
		
		public static var _visible:Boolean;//indicates whether the console is being shown or not
		public static var _toggleKey:uint = 220;//key binded for toggling visibility
		public static var _hideKey:uint = Keyboard.ESCAPE;//key binded for hiding the console.
		
		public function Console() 
		{
			super();
		}
		
		public static function init(s:Stage):void
		{
			_stage = s;
			_visible = false;
			
			_sprite = new Sprite();
			_lines = new Vector.<String>();
			_textFieldLines = new Vector.<TextField>();
			_dispatcher = new EventDispatcher();
			
			_numLinesToDisplay = 8;
			_topLine = 0;
			
			_foreColor = 0xC0C0C0;
			
			_lineFormatSize = 12;
			_lineFormat = new TextFormat();
			_lineFormat.font = "Consolas";
			_lineFormat.size = _lineFormatSize;
			_lineFormat.align = TextFormatAlign.LEFT;
			_lineFormat.color = _foreColor;
			
			_bgColor = 0x000000;
			_bgAlpha = 0.7;
			_bgColorTransform = new ColorTransform();
			_bgColorTransform.color = _bgColor;
			_bgColorTransform.alphaMultiplier = _bgAlpha;
			
			//create textLines
			for (var i:int = 0; i < _numLinesToDisplay; i++) 
			{
				var text:TextField = new TextField();
				text.autoSize = TextFieldAutoSize.LEFT;
				text.defaultTextFormat = _lineFormat;
				text.multiline = false;
				text.text = " ";
				text.x = 2.5;
				
				_textFieldLines.push(text);
			}
			
			//create Rectangle
			var textHeight:int = _textFieldLines[0].height;
			var linesbgHeight:Number = _numLinesToDisplay * (textHeight) + (((textHeight) / 4) * (_numLinesToDisplay + 1));
			var inputbgposY:Number = linesbgHeight + 2;
			
			_bg = new Shape();
			_bg.transform.colorTransform = _bgColorTransform;
			_bg.graphics.beginFill(0xFFFFFF);
			_bg.graphics.drawRect(0, 0, _stage.stageWidth, linesbgHeight);
			_bg.graphics.drawRect(0, inputbgposY, _stage.stageWidth, (textHeight) * 2); 
			_bg.graphics.endFill();
			
			_sprite.addChild(_bg);
			
			//create input textField;
			_inputTextField = new TextField();
			_inputTextField.autoSize = TextFieldAutoSize.NONE;
			_inputTextField.defaultTextFormat = _lineFormat;
			_inputTextField.type = TextFieldType.INPUT;
			_inputTextField.multiline = false;
			_inputTextField.x = 2.5;
			_inputTextField.y = inputbgposY + ((textHeight) / 2);
			_inputTextField.height = textHeight;
			_inputTextField.width = _stage.stageWidth - 50;
			_inputTextField.background = true;
			_inputTextField.backgroundColor = 0x808080;
			
			//create simplebutton
			//create bg
			_enterButtonBG = new Shape()
			_enterButtonBG.graphics.beginFill(0x808080);
			_enterButtonBG.graphics.drawRect(0, 0, 35, textHeight);
			_enterButtonBG.graphics.endFill();
			
			_enterButtonOver = new Shape()
			_enterButtonOver.graphics.beginFill(0xC0C0C0);
			_enterButtonOver.graphics.drawRect(0, 0, 35, textHeight);
			_enterButtonOver.graphics.endFill();
			
			_enterButtonPressed = new Shape()
			_enterButtonPressed.graphics.beginFill(0xC0C0C0);
			_enterButtonPressed.graphics.drawRect(0, 0, 35, textHeight);
			_enterButtonPressed.graphics.endFill();
			
			_enterButton = new SimpleButton(_enterButtonBG, _enterButtonOver, _enterButtonPressed, _enterButtonBG);
			_enterButton.x = _stage.stageWidth - 40;
			_enterButton.y = inputbgposY + textHeight / 2;
			
			_sprite.addChild(_enterButton);
			
			_sprite.addChild(_inputTextField);
			
			//place textfields
			for (var j:int = 0; j < _textFieldLines.length; j++) 
			{
				_textFieldLines[j].y = (((textHeight) / 4) * (j + 1)) + (textHeight) * j;
				_sprite.addChild(_textFieldLines[j]);
			}
			
			_sprite.y = _stage.stageHeight - _sprite.height;
			
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, manageKey);
			_inputTextField.addEventListener(Event.CHANGE, textInput, false, 1);
			
			_bindedMethods = new Object();
			_dispatcher.addEventListener(ConsoleEvent.COMMAND_SUBMITTED, execCommand);
			
			//bind Console commands:
			bindFunction("Console.runBatch", runBatch);
			bindFunction("Console.saveLog", saveLogToFile);
			bindFunction("Console.clear", clearConsole);
		}
		
		private static function clearConsole(args:Array):void
        {
			Console.setTopLine(Console._lines.length - 1);
        }
		
		private static function runBatch(args:Array):void
		{
			if (args.length < 2)
			{
				Console.writeLine("Usage: runBatch <fileName>");
				return;
			}
			
			var path:String = args[1];

			var myTextLoader:URLLoader = new URLLoader();
			myTextLoader.addEventListener(flash.events.Event.COMPLETE, onLoaded);
			myTextLoader.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
			myTextLoader.load(new URLRequest(path));
		}
		
		private static function onLoaded(e:flash.events.Event):void {
			var arr:Array = e.target.data.split("\r\n");
			for (var i:int = 0; i < arr.length; i++) 
			{
				Console.submitCommand(arr[i]);
			}
		}
		
		private static function loaderIOErrorHandler(e:IOErrorEvent):void 
		{
			Console.writeLine("Couldn't run batch. Exception: " + e.text);
		}
		
		public static function execCommand(e:ConsoleEvent):void
		{
			var code:String = e.data;
			var components:Array = code.split(" ");
			
			var key:String = components[0];
			
			if (_bindedMethods[key] == null)
			{
				writeLine("Invalid command");
				return;
			}
			try 
			{
				_bindedMethods[key](components);
			}
			catch (err:Error)
			{
				writeLine(err.name);
			}
		}
		
		public static function bindFunction(key:String, method:Function):void
		{
			if (_bindedMethods[key] != null)
			{
				writeLine("Failed to bind Function: key in use");
			}
			if (key != null && method != null)
				_bindedMethods[key] = method;
		}
		
		public static function manageKey(e:KeyboardEvent):void
		{
			if (e.keyCode == _toggleKey)
			{
				Console.toggleConsole();
			}
			if (e.keyCode == _hideKey)
			{
				Console.hideConsole(true);
			}
			
			if (!_visible)
				return;
				
			if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.NUMPAD_ENTER)
			{
				submitCommand(_inputTextField.text);
				clearInput();
			}
			if (e.ctrlKey)
			{
				if (e.keyCode == Keyboard.UP)
					scrollUp();
				if (e.keyCode == Keyboard.DOWN)
					scrollDown();
			}
		}
		
		public static function saveLogToFile(args:Array = null):void {
			if(_saveToFilePermission)
			{
				writeLine("Saving console log to file");
				var fileRef:FileReference=new FileReference();
				fileRef.save(getConsoleLog() , _logFilePath);
				clearInput();
			}else
			{
				writeLine("Saving to file is not allowed in this console");
			}
		}
		
		public static function getConsoleLog():String {
			return _lines.join("\r\n");
		}
		
		public static function clearInput():void {
			_inputTextField.text = "";
		}
		
		public static function scrollUp():void {
			
			setTopLine(_topLine-1);
			
			checkAutoScroll();
		}
		
		public static function checkAutoScroll():void {
			if ( linesOnDisplay() <= _numLinesToDisplay)
				_autoScroll = true;
			else
				_autoScroll = false;
		}
		
		public static function linesOnDisplay():int
		{
			return _lines.length - _topLine;
		}
		
		public static function scrollDown():void {
			setTopLine(_topLine+1);
			checkAutoScroll();
		}
		
		public static function submitCommand(command:String):void
		{
			if (command == "")
				return;
				
			_lastLine = command;
			writeLine("> " + command);
			var newEvent:ConsoleEvent = new ConsoleEvent(ConsoleEvent.COMMAND_SUBMITTED);
			newEvent.data = command;
			_dispatcher.dispatchEvent(newEvent);
		}
		
		public static function updateTextFields():void
		{
			for (var j:int = 0; j < _numLinesToDisplay; j++) 
			{
				_textFieldLines[j].text = "";
			}
			var limit:int = Math.min(_numLinesToDisplay, linesOnDisplay());
			var l:int = _topLine;
			for (var i:int = 0; i < limit; i++, l++) 
			{
				_textFieldLines[i].text = _lines[l];
			}
		}
		
		public static function setTopLine(lineNum:int):void
		{
			_topLine = Math.max(0, Math.min(lineNum, _lines.length - 1));
			updateTextFields();
		}
		
		public static function writeLine(line:String):void
		{
			_lines.push(line);
			if((_autoScroll) && (_topLine + _numLinesToDisplay <= _lines.length))
				setTopLine(_lines.length - _numLinesToDisplay);
			updateTextFields();
		}
		
		public static function showConsole():void
		{
			if (_visible)
				return;
				
			_visible = true;
			_prevFocus = _stage.focus;
			_stage.focus = _inputTextField;
			_inputTextField.type = TextFieldType.INPUT;
			_stage.addChild(_sprite);
		}
		
		public static function textInput(e:Event):void
		{
			_inputTextField.text = _prevText;
			_inputTextField.removeEventListener(Event.CHANGE, textInput);
		}
		
		public static function hideConsole(forceHide:Boolean = false):void
		{
			if (!_visible || (_stage.focus == _inputTextField && !forceHide))
				return;
				
			_visible = false;
			_stage.focus = _prevFocus;
			_stage.removeChild(_sprite);
			_inputTextField.type = TextFieldType.DYNAMIC;
			_prevText = _inputTextField.text;
			_inputTextField.addEventListener(Event.CHANGE, textInput, false, 1);
		}
		
		public static function toggleConsole():void
		{
			if (_visible)
				hideConsole();
			else
				showConsole();
		}
		
	}

}
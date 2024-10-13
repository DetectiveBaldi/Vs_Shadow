package;

import openfl.display.Sprite;

import flixel.FlxGame;

import menus.TitleScreenState;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		addChild(new FlxGame(0, 0, () -> new OpeningState(() -> new TitleScreenState()), 60, 60, false, false));
	}
}
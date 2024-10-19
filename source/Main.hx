package;

import openfl.display.Sprite;

import flixel.FlxGame;

import menus.TitleScreen;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		addChild(new FlxGame(0, 0, () -> new OpeningState(() -> new TitleScreen()), 60, 60, false, false));
	}
}
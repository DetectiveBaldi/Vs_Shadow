package;

import openfl.display.Sprite;

import flixel.FlxGame;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		addChild(new FlxGame(0, 0, () -> new OpeningState(() -> new #if debug game.levels.Level1 #else menus.TitleScreen #end ()), 60, 60, false, false));
	}
}
package game;

import flixel.FlxG;

import flixel.sound.FlxSound;

import flixel.util.FlxColor;

import core.AssetMan;
import core.Paths;

import extendable.SteppingSubState;

import menus.TitleState;

class GameOverSubState extends SteppingSubState
{
    public var game:GameState;

    public var player:Character;

    public var start:FlxSound;

    public var end:FlxSound;

    public var tune:FlxSound;

    public function new(game:GameState):Void
    {
        super();

        this.game = game;
    }

    override function create():Void
    {
        super.create();

        conductor.tempo = 100.0;

        conductor.time = -conductor.crotchet * 5.0;

        game.gameCamera.followLerp = 0.0185;

        game.playerGroup.visible = false;

        var _player:Character = game.player;

        player = new Character(conductor, 0.0, 0.0, 'assets/data/game/Character/BOYFRIEND_DEAD', PLAYABLE);

        player.skipDance = true;

        player.animation.play("start");

        player.setPosition(_player.x, _player.y);

        add(player);

        game.gameCameraTarget.setPosition(player.getMidpoint().x, player.getMidpoint().y);

        start = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/game/GameOverSubState/start"), false));

        start.play();
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) && player.data.danceSteps.contains(player.animation.name))
        {
            FlxG.camera.fade(FlxColor.BLACK, conductor.crotchet * 0.001 * 7.5, false, () -> FlxG.resetState());

            player.skipDance = true;

            player.animation.play("end");

            end = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/sounds/game/GameOverSubState/end"), false));

            end.play();

            tune.stop();
        }

        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.camera.fade(FlxColor.BLACK, conductor.crotchet * 0.001 * 2.5, false, () -> FlxG.switchState(() -> new TitleState()));

            tune.fadeOut(conductor.crotchet * 0.001 * 2.5, 0.0);
        }
    }

    override function beatHit(beat:Int):Void
    {
        super.beatHit(beat);

        if (beat == 0.0)
        {
            player.skipDance = false;

            tune = FlxG.sound.load(AssetMan.sound(#if html5 Paths.mp3 #else Paths.ogg #end ("assets/music/game/GameOverSubState/tune")), 1.0, true);

            tune.play();
        }
    }
}
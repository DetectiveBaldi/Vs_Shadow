package game.levels;

import openfl.filters.ColorMatrixFilter;

import flixel.math.FlxMath;

import flixel.util.FlxColor;

import core.AssetMan;
import core.Paths;

import game.notes.Note;

import game.stages.HellishFields;

class Level1 extends GameState
{
    public var colorFilter:ColorMatrixFilter;

    public function new():Void
    {
        super(new HellishFields());
    }

    override function create():Void
    {
        super.create();

        AssetMan.graphic(Paths.png("assets/images/game/Character/GARRETT"));

        gameCamera.zoom = 0.65;

        gameCameraZoom = gameCamera.zoom;

        gameCameraTarget.setPosition(3440.0, 675.0);

        gameCamera.snapToTarget();

        spectator.visible = false;

        opponent.visible = false;

        player.setPosition(3805.0, 645.0);

        var _opponent:Character = new Character(conductor, 0.0, 0.0, "assets/data/game/Character/SHADOW_THIRD", ARTIFICIAL);

        _opponent.setPosition(2775.0, 375.0);

        opponentMap[_opponent.data.name] = _opponent;

        opponentGroup.add(_opponent);
    }

    override function stepHit(step:Int):Void
    {
        super.stepHit(step);

        if (step == 1312.0)
        {
            opponentMap["SHADOW_THIRD"].skipDance = true;

            opponentMap["SHADOW_THIRD"].skipSing = true;

            opponentMap["SHADOW_THIRD"].animation.play("point", true);

            opponentMap["SHADOW_THIRD"].animation.onFinish.add((name:String) ->
            {
                if (name == "point")
                    opponentMap["SHADOW_THIRD"].skipDance = false;
            });
        }

        if (step == 1344.0)
        {
            gameCamera.flash(FlxColor.WHITE, conductor.crotchet * 0.001);

            opponentMap["SHADOW_THIRD"].animation.finish();

            var _opponent:Character = new Character(conductor, 0.0, 0.0, "assets/data/game/Character/GARRETT", ARTIFICIAL);

            _opponent.setPosition(2950.0, 320.0);
    
            opponentMap[_opponent.data.name] = _opponent;
    
            opponentGroup.add(_opponent);
        }

        if (step == 2240.0)
        {
            gameCamera.filters = [new ColorMatrixFilter([0.275, 0.275, 0.275, 0.0, 0.0, 0.275, 0.275, 0.275, 0.0, 0.0, 0.275, 0.275, 0.275, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0])];

            gameCamera.flash(FlxColor.WHITE, conductor.crotchet * 0.001);

            hudCamera.filters = [gameCamera.filters[0]];
        }

        if (step == 2366.0)
        {
            gameCamera.filters.resize(0);

            gameCamera.flash(FlxColor.WHITE, conductor.crotchet * 0.001, true);

            hudCamera.filters.resize(0);

            opponentMap["SHADOW_THIRD"].skipSing = false;
        }

        if (step == 2624.0)
            gameCamera.flash(FlxColor.WHITE, conductor.crotchet * 0.001);
    }

    override function opponentNoteHit(note:Note):Void
    {
        super.opponentNoteHit(note);

        if (conductor.step >= 2366.0)
            healthBar.value = FlxMath.bound(healthBar.value - 1.65, healthBar.bar.min, healthBar.bar.max);
    }
}
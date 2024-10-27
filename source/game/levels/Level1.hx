package game.levels;

import openfl.filters.ColorMatrixFilter;

import flixel.FlxSprite;

import flixel.math.FlxMath;

import flixel.tweens.FlxTween;

import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

import core.AssetMan;
import core.Paths;

import game.notes.Note;

class Level1 extends GameState
{
    public var desaturationEffect:ColorMatrixFilter;

    public var apple:FlxSprite;

    override function create():Void
    {
        super.create();

        AssetMan.graphic(Paths.png("assets/images/game/Character/GARRETT"));

        AssetMan.graphic(Paths.png('assets/images/game/levels/${FlxStringUtil.getClassName(this, true)}/apple'));

        desaturationEffect = new ColorMatrixFilter([0.275, 0.275, 0.275, 0.0, 0.0, 0.275, 0.275, 0.275, 0.0, 0.0, 0.275, 0.275, 0.275, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0]);

        spectator.visible = false;

        opponent.visible = false;

        var _opponent:Character = new Character(conductor, 0.0, 0.0, "assets/data/game/Character/SHADOW_THIRD", ARTIFICIAL);

        _opponent.setPosition(-150.0, 15.0);

        opponentMap[_opponent.data.name] = _opponent;

        opponentGroup.add(_opponent);
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (apple != null)
            apple.scale.set(FlxMath.lerp(apple.scale.x, 1.0, 0.15), FlxMath.lerp(apple.scale.y, 1.0, 0.15));
    }

    override function stepHit(step:Int):Void
    {
        super.stepHit(step);

        if (step == 1344.0)
        {
            opponentMap["SHADOW_THIRD"].visible = false;

            var _opponent:Character = new Character(conductor, 0.0, 0.0, "assets/data/game/Character/GARRETT", ARTIFICIAL);

            _opponent.setPosition(-40.0, 75.0);
    
            opponentMap[_opponent.data.name] = _opponent;
    
            opponentGroup.add(_opponent);
        }

        if (step == 2240.0)
        {
            gameCamera.filters = [desaturationEffect];

            gameCamera.flash(FlxColor.WHITE, conductor.crotchet * 0.001);

            hudCamera.filters = [desaturationEffect];

            apple = new FlxSprite(0.0, 0.0, AssetMan.graphic(Paths.png('assets/images/game/levels/${FlxStringUtil.getClassName(this, true)}/apple')));

            apple.antialiasing = true;

            apple.alpha = 0.0;

            apple.screenCenter();

            insert(members.indexOf(spectatorGroup), apple);

            FlxTween.tween(apple, {alpha: 1.0}, conductor.crotchet * 0.001 * 1.5);
        }

        if (step == 2362.0)
        {
            opponentMap["SHADOW_THIRD"].visible = true;

            opponentMap["SHADOW_THIRD"].y = -opponentMap["SHADOW_THIRD"].height;

            FlxTween.tween(opponentMap["SHADOW_THIRD"], {y: 15.0}, conductor.crotchet * 0.001);

            FlxTween.tween(opponentMap["GARRETT"], {x: 250.0}, conductor.crotchet * 0.001);
        }

        if (step == 2366.0)
        {
            gameCamera.filters.resize(0);

            gameCamera.flash(FlxColor.WHITE, conductor.crotchet * 0.001);

            hudCamera.filters.resize(0);

            opponentMap["GARRETT"].danceSteps[0] = "dance1";
        }
    }

    override function beatHit(beat:Int):Void
    {
        if (beat >= 560.0 && beat % 2.0 == 0.0)
            apple.scale *= 1.15;
    }

    override function opponentNoteHit(note:Note):Void
    {
        super.opponentNoteHit(note);

        if (conductor.step >= 2366.0)
            healthBar.value = FlxMath.bound(healthBar.value - 1.65, healthBar.bar.min, healthBar.bar.max);
    }
}